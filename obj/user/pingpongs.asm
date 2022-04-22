
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 d6 00 00 00       	call   800107 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  800040:	e8 53 10 00 00       	call   801098 <sfork>
  800045:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800048:	85 c0                	test   %eax,%eax
  80004a:	75 74                	jne    8000c0 <umain+0x8d>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80004c:	83 ec 04             	sub    $0x4,%esp
  80004f:	6a 00                	push   $0x0
  800051:	6a 00                	push   $0x0
  800053:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 5a 10 00 00       	call   8010b6 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80005c:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  800062:	8b 7b 48             	mov    0x48(%ebx),%edi
  800065:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800068:	a1 04 20 80 00       	mov    0x802004,%eax
  80006d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800070:	e8 9e 0b 00 00       	call   800c13 <sys_getenvid>
  800075:	83 c4 08             	add    $0x8,%esp
  800078:	57                   	push   %edi
  800079:	53                   	push   %ebx
  80007a:	56                   	push   %esi
  80007b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80007e:	50                   	push   %eax
  80007f:	68 30 15 80 00       	push   $0x801530
  800084:	e8 85 01 00 00       	call   80020e <cprintf>
		if (val == 10)
  800089:	a1 04 20 80 00       	mov    0x802004,%eax
  80008e:	83 c4 20             	add    $0x20,%esp
  800091:	83 f8 0a             	cmp    $0xa,%eax
  800094:	74 22                	je     8000b8 <umain+0x85>
			return;
		++val;
  800096:	83 c0 01             	add    $0x1,%eax
  800099:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  80009e:	6a 00                	push   $0x0
  8000a0:	6a 00                	push   $0x0
  8000a2:	6a 00                	push   $0x0
  8000a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a7:	e8 61 10 00 00       	call   80110d <ipc_send>
		if (val == 10)
  8000ac:	83 c4 10             	add    $0x10,%esp
  8000af:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  8000b6:	75 94                	jne    80004c <umain+0x19>
			return;
	}

}
  8000b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  8000c0:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000c6:	e8 48 0b 00 00       	call   800c13 <sys_getenvid>
  8000cb:	83 ec 04             	sub    $0x4,%esp
  8000ce:	53                   	push   %ebx
  8000cf:	50                   	push   %eax
  8000d0:	68 00 15 80 00       	push   $0x801500
  8000d5:	e8 34 01 00 00       	call   80020e <cprintf>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  8000da:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8000dd:	e8 31 0b 00 00       	call   800c13 <sys_getenvid>
  8000e2:	83 c4 0c             	add    $0xc,%esp
  8000e5:	53                   	push   %ebx
  8000e6:	50                   	push   %eax
  8000e7:	68 1a 15 80 00       	push   $0x80151a
  8000ec:	e8 1d 01 00 00       	call   80020e <cprintf>
		ipc_send(who, 0, 0, 0);
  8000f1:	6a 00                	push   $0x0
  8000f3:	6a 00                	push   $0x0
  8000f5:	6a 00                	push   $0x0
  8000f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000fa:	e8 0e 10 00 00       	call   80110d <ipc_send>
  8000ff:	83 c4 20             	add    $0x20,%esp
  800102:	e9 45 ff ff ff       	jmp    80004c <umain+0x19>

00800107 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800107:	f3 0f 1e fb          	endbr32 
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	56                   	push   %esi
  80010f:	53                   	push   %ebx
  800110:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800113:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800116:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  80011d:	00 00 00 
    envid_t envid = sys_getenvid();
  800120:	e8 ee 0a 00 00       	call   800c13 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800125:	25 ff 03 00 00       	and    $0x3ff,%eax
  80012a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80012d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800132:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800137:	85 db                	test   %ebx,%ebx
  800139:	7e 07                	jle    800142 <libmain+0x3b>
		binaryname = argv[0];
  80013b:	8b 06                	mov    (%esi),%eax
  80013d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800142:	83 ec 08             	sub    $0x8,%esp
  800145:	56                   	push   %esi
  800146:	53                   	push   %ebx
  800147:	e8 e7 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80014c:	e8 0a 00 00 00       	call   80015b <exit>
}
  800151:	83 c4 10             	add    $0x10,%esp
  800154:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800157:	5b                   	pop    %ebx
  800158:	5e                   	pop    %esi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80015b:	f3 0f 1e fb          	endbr32 
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800165:	6a 00                	push   $0x0
  800167:	e8 62 0a 00 00       	call   800bce <sys_env_destroy>
}
  80016c:	83 c4 10             	add    $0x10,%esp
  80016f:	c9                   	leave  
  800170:	c3                   	ret    

00800171 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800171:	f3 0f 1e fb          	endbr32 
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	53                   	push   %ebx
  800179:	83 ec 04             	sub    $0x4,%esp
  80017c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017f:	8b 13                	mov    (%ebx),%edx
  800181:	8d 42 01             	lea    0x1(%edx),%eax
  800184:	89 03                	mov    %eax,(%ebx)
  800186:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800189:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80018d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800192:	74 09                	je     80019d <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800194:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80019d:	83 ec 08             	sub    $0x8,%esp
  8001a0:	68 ff 00 00 00       	push   $0xff
  8001a5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a8:	50                   	push   %eax
  8001a9:	e8 db 09 00 00       	call   800b89 <sys_cputs>
		b->idx = 0;
  8001ae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	eb db                	jmp    800194 <putch+0x23>

008001b9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b9:	f3 0f 1e fb          	endbr32 
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cd:	00 00 00 
	b.cnt = 0;
  8001d0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001da:	ff 75 0c             	pushl  0xc(%ebp)
  8001dd:	ff 75 08             	pushl  0x8(%ebp)
  8001e0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e6:	50                   	push   %eax
  8001e7:	68 71 01 80 00       	push   $0x800171
  8001ec:	e8 20 01 00 00       	call   800311 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f1:	83 c4 08             	add    $0x8,%esp
  8001f4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001fa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800200:	50                   	push   %eax
  800201:	e8 83 09 00 00       	call   800b89 <sys_cputs>

	return b.cnt;
}
  800206:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020c:	c9                   	leave  
  80020d:	c3                   	ret    

0080020e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020e:	f3 0f 1e fb          	endbr32 
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800218:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021b:	50                   	push   %eax
  80021c:	ff 75 08             	pushl  0x8(%ebp)
  80021f:	e8 95 ff ff ff       	call   8001b9 <vcprintf>
	va_end(ap);

	return cnt;
}
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	57                   	push   %edi
  80022a:	56                   	push   %esi
  80022b:	53                   	push   %ebx
  80022c:	83 ec 1c             	sub    $0x1c,%esp
  80022f:	89 c7                	mov    %eax,%edi
  800231:	89 d6                	mov    %edx,%esi
  800233:	8b 45 08             	mov    0x8(%ebp),%eax
  800236:	8b 55 0c             	mov    0xc(%ebp),%edx
  800239:	89 d1                	mov    %edx,%ecx
  80023b:	89 c2                	mov    %eax,%edx
  80023d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800240:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800243:	8b 45 10             	mov    0x10(%ebp),%eax
  800246:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800249:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80024c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800253:	39 c2                	cmp    %eax,%edx
  800255:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800258:	72 3e                	jb     800298 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	ff 75 18             	pushl  0x18(%ebp)
  800260:	83 eb 01             	sub    $0x1,%ebx
  800263:	53                   	push   %ebx
  800264:	50                   	push   %eax
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026b:	ff 75 e0             	pushl  -0x20(%ebp)
  80026e:	ff 75 dc             	pushl  -0x24(%ebp)
  800271:	ff 75 d8             	pushl  -0x28(%ebp)
  800274:	e8 27 10 00 00       	call   8012a0 <__udivdi3>
  800279:	83 c4 18             	add    $0x18,%esp
  80027c:	52                   	push   %edx
  80027d:	50                   	push   %eax
  80027e:	89 f2                	mov    %esi,%edx
  800280:	89 f8                	mov    %edi,%eax
  800282:	e8 9f ff ff ff       	call   800226 <printnum>
  800287:	83 c4 20             	add    $0x20,%esp
  80028a:	eb 13                	jmp    80029f <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028c:	83 ec 08             	sub    $0x8,%esp
  80028f:	56                   	push   %esi
  800290:	ff 75 18             	pushl  0x18(%ebp)
  800293:	ff d7                	call   *%edi
  800295:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800298:	83 eb 01             	sub    $0x1,%ebx
  80029b:	85 db                	test   %ebx,%ebx
  80029d:	7f ed                	jg     80028c <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029f:	83 ec 08             	sub    $0x8,%esp
  8002a2:	56                   	push   %esi
  8002a3:	83 ec 04             	sub    $0x4,%esp
  8002a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ac:	ff 75 dc             	pushl  -0x24(%ebp)
  8002af:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b2:	e8 f9 10 00 00       	call   8013b0 <__umoddi3>
  8002b7:	83 c4 14             	add    $0x14,%esp
  8002ba:	0f be 80 60 15 80 00 	movsbl 0x801560(%eax),%eax
  8002c1:	50                   	push   %eax
  8002c2:	ff d7                	call   *%edi
}
  8002c4:	83 c4 10             	add    $0x10,%esp
  8002c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ca:	5b                   	pop    %ebx
  8002cb:	5e                   	pop    %esi
  8002cc:	5f                   	pop    %edi
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cf:	f3 0f 1e fb          	endbr32 
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
  8002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e2:	73 0a                	jae    8002ee <sprintputch+0x1f>
		*b->buf++ = ch;
  8002e4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e7:	89 08                	mov    %ecx,(%eax)
  8002e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ec:	88 02                	mov    %al,(%edx)
}
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <printfmt>:
{
  8002f0:	f3 0f 1e fb          	endbr32 
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002fa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fd:	50                   	push   %eax
  8002fe:	ff 75 10             	pushl  0x10(%ebp)
  800301:	ff 75 0c             	pushl  0xc(%ebp)
  800304:	ff 75 08             	pushl  0x8(%ebp)
  800307:	e8 05 00 00 00       	call   800311 <vprintfmt>
}
  80030c:	83 c4 10             	add    $0x10,%esp
  80030f:	c9                   	leave  
  800310:	c3                   	ret    

00800311 <vprintfmt>:
{
  800311:	f3 0f 1e fb          	endbr32 
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	57                   	push   %edi
  800319:	56                   	push   %esi
  80031a:	53                   	push   %ebx
  80031b:	83 ec 3c             	sub    $0x3c,%esp
  80031e:	8b 75 08             	mov    0x8(%ebp),%esi
  800321:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800324:	8b 7d 10             	mov    0x10(%ebp),%edi
  800327:	e9 4a 03 00 00       	jmp    800676 <vprintfmt+0x365>
		padc = ' ';
  80032c:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800330:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800337:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80033e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800345:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	8d 47 01             	lea    0x1(%edi),%eax
  80034d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800350:	0f b6 17             	movzbl (%edi),%edx
  800353:	8d 42 dd             	lea    -0x23(%edx),%eax
  800356:	3c 55                	cmp    $0x55,%al
  800358:	0f 87 de 03 00 00    	ja     80073c <vprintfmt+0x42b>
  80035e:	0f b6 c0             	movzbl %al,%eax
  800361:	3e ff 24 85 a0 16 80 	notrack jmp *0x8016a0(,%eax,4)
  800368:	00 
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80036c:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800370:	eb d8                	jmp    80034a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800375:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800379:	eb cf                	jmp    80034a <vprintfmt+0x39>
  80037b:	0f b6 d2             	movzbl %dl,%edx
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800381:	b8 00 00 00 00       	mov    $0x0,%eax
  800386:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800389:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80038c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800390:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800393:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800396:	83 f9 09             	cmp    $0x9,%ecx
  800399:	77 55                	ja     8003f0 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80039b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80039e:	eb e9                	jmp    800389 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a3:	8b 00                	mov    (%eax),%eax
  8003a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ab:	8d 40 04             	lea    0x4(%eax),%eax
  8003ae:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003b4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b8:	79 90                	jns    80034a <vprintfmt+0x39>
				width = precision, precision = -1;
  8003ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003c7:	eb 81                	jmp    80034a <vprintfmt+0x39>
  8003c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003cc:	85 c0                	test   %eax,%eax
  8003ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d3:	0f 49 d0             	cmovns %eax,%edx
  8003d6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003dc:	e9 69 ff ff ff       	jmp    80034a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003e4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003eb:	e9 5a ff ff ff       	jmp    80034a <vprintfmt+0x39>
  8003f0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f6:	eb bc                	jmp    8003b4 <vprintfmt+0xa3>
			lflag++;
  8003f8:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003fe:	e9 47 ff ff ff       	jmp    80034a <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800403:	8b 45 14             	mov    0x14(%ebp),%eax
  800406:	8d 78 04             	lea    0x4(%eax),%edi
  800409:	83 ec 08             	sub    $0x8,%esp
  80040c:	53                   	push   %ebx
  80040d:	ff 30                	pushl  (%eax)
  80040f:	ff d6                	call   *%esi
			break;
  800411:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800414:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800417:	e9 57 02 00 00       	jmp    800673 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	8d 78 04             	lea    0x4(%eax),%edi
  800422:	8b 00                	mov    (%eax),%eax
  800424:	99                   	cltd   
  800425:	31 d0                	xor    %edx,%eax
  800427:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800429:	83 f8 0f             	cmp    $0xf,%eax
  80042c:	7f 23                	jg     800451 <vprintfmt+0x140>
  80042e:	8b 14 85 00 18 80 00 	mov    0x801800(,%eax,4),%edx
  800435:	85 d2                	test   %edx,%edx
  800437:	74 18                	je     800451 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800439:	52                   	push   %edx
  80043a:	68 81 15 80 00       	push   $0x801581
  80043f:	53                   	push   %ebx
  800440:	56                   	push   %esi
  800441:	e8 aa fe ff ff       	call   8002f0 <printfmt>
  800446:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800449:	89 7d 14             	mov    %edi,0x14(%ebp)
  80044c:	e9 22 02 00 00       	jmp    800673 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800451:	50                   	push   %eax
  800452:	68 78 15 80 00       	push   $0x801578
  800457:	53                   	push   %ebx
  800458:	56                   	push   %esi
  800459:	e8 92 fe ff ff       	call   8002f0 <printfmt>
  80045e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800461:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800464:	e9 0a 02 00 00       	jmp    800673 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800469:	8b 45 14             	mov    0x14(%ebp),%eax
  80046c:	83 c0 04             	add    $0x4,%eax
  80046f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800472:	8b 45 14             	mov    0x14(%ebp),%eax
  800475:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800477:	85 d2                	test   %edx,%edx
  800479:	b8 71 15 80 00       	mov    $0x801571,%eax
  80047e:	0f 45 c2             	cmovne %edx,%eax
  800481:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800484:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800488:	7e 06                	jle    800490 <vprintfmt+0x17f>
  80048a:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80048e:	75 0d                	jne    80049d <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800490:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800493:	89 c7                	mov    %eax,%edi
  800495:	03 45 e0             	add    -0x20(%ebp),%eax
  800498:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049b:	eb 55                	jmp    8004f2 <vprintfmt+0x1e1>
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a3:	ff 75 cc             	pushl  -0x34(%ebp)
  8004a6:	e8 45 03 00 00       	call   8007f0 <strnlen>
  8004ab:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004ae:	29 c2                	sub    %eax,%edx
  8004b0:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004b8:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bf:	85 ff                	test   %edi,%edi
  8004c1:	7e 11                	jle    8004d4 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	53                   	push   %ebx
  8004c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ca:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cc:	83 ef 01             	sub    $0x1,%edi
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	eb eb                	jmp    8004bf <vprintfmt+0x1ae>
  8004d4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004d7:	85 d2                	test   %edx,%edx
  8004d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004de:	0f 49 c2             	cmovns %edx,%eax
  8004e1:	29 c2                	sub    %eax,%edx
  8004e3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004e6:	eb a8                	jmp    800490 <vprintfmt+0x17f>
					putch(ch, putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	53                   	push   %ebx
  8004ec:	52                   	push   %edx
  8004ed:	ff d6                	call   *%esi
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f5:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f7:	83 c7 01             	add    $0x1,%edi
  8004fa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004fe:	0f be d0             	movsbl %al,%edx
  800501:	85 d2                	test   %edx,%edx
  800503:	74 4b                	je     800550 <vprintfmt+0x23f>
  800505:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800509:	78 06                	js     800511 <vprintfmt+0x200>
  80050b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80050f:	78 1e                	js     80052f <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800511:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800515:	74 d1                	je     8004e8 <vprintfmt+0x1d7>
  800517:	0f be c0             	movsbl %al,%eax
  80051a:	83 e8 20             	sub    $0x20,%eax
  80051d:	83 f8 5e             	cmp    $0x5e,%eax
  800520:	76 c6                	jbe    8004e8 <vprintfmt+0x1d7>
					putch('?', putdat);
  800522:	83 ec 08             	sub    $0x8,%esp
  800525:	53                   	push   %ebx
  800526:	6a 3f                	push   $0x3f
  800528:	ff d6                	call   *%esi
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	eb c3                	jmp    8004f2 <vprintfmt+0x1e1>
  80052f:	89 cf                	mov    %ecx,%edi
  800531:	eb 0e                	jmp    800541 <vprintfmt+0x230>
				putch(' ', putdat);
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	53                   	push   %ebx
  800537:	6a 20                	push   $0x20
  800539:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80053b:	83 ef 01             	sub    $0x1,%edi
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	85 ff                	test   %edi,%edi
  800543:	7f ee                	jg     800533 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800545:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800548:	89 45 14             	mov    %eax,0x14(%ebp)
  80054b:	e9 23 01 00 00       	jmp    800673 <vprintfmt+0x362>
  800550:	89 cf                	mov    %ecx,%edi
  800552:	eb ed                	jmp    800541 <vprintfmt+0x230>
	if (lflag >= 2)
  800554:	83 f9 01             	cmp    $0x1,%ecx
  800557:	7f 1b                	jg     800574 <vprintfmt+0x263>
	else if (lflag)
  800559:	85 c9                	test   %ecx,%ecx
  80055b:	74 63                	je     8005c0 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	99                   	cltd   
  800566:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8d 40 04             	lea    0x4(%eax),%eax
  80056f:	89 45 14             	mov    %eax,0x14(%ebp)
  800572:	eb 17                	jmp    80058b <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8b 50 04             	mov    0x4(%eax),%edx
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8d 40 08             	lea    0x8(%eax),%eax
  800588:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80058b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80058e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800591:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800596:	85 c9                	test   %ecx,%ecx
  800598:	0f 89 bb 00 00 00    	jns    800659 <vprintfmt+0x348>
				putch('-', putdat);
  80059e:	83 ec 08             	sub    $0x8,%esp
  8005a1:	53                   	push   %ebx
  8005a2:	6a 2d                	push   $0x2d
  8005a4:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ac:	f7 da                	neg    %edx
  8005ae:	83 d1 00             	adc    $0x0,%ecx
  8005b1:	f7 d9                	neg    %ecx
  8005b3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005b6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bb:	e9 99 00 00 00       	jmp    800659 <vprintfmt+0x348>
		return va_arg(*ap, int);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8b 00                	mov    (%eax),%eax
  8005c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c8:	99                   	cltd   
  8005c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 40 04             	lea    0x4(%eax),%eax
  8005d2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d5:	eb b4                	jmp    80058b <vprintfmt+0x27a>
	if (lflag >= 2)
  8005d7:	83 f9 01             	cmp    $0x1,%ecx
  8005da:	7f 1b                	jg     8005f7 <vprintfmt+0x2e6>
	else if (lflag)
  8005dc:	85 c9                	test   %ecx,%ecx
  8005de:	74 2c                	je     80060c <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8b 10                	mov    (%eax),%edx
  8005e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ea:	8d 40 04             	lea    0x4(%eax),%eax
  8005ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f0:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005f5:	eb 62                	jmp    800659 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8b 10                	mov    (%eax),%edx
  8005fc:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ff:	8d 40 08             	lea    0x8(%eax),%eax
  800602:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800605:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80060a:	eb 4d                	jmp    800659 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8b 10                	mov    (%eax),%edx
  800611:	b9 00 00 00 00       	mov    $0x0,%ecx
  800616:	8d 40 04             	lea    0x4(%eax),%eax
  800619:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80061c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800621:	eb 36                	jmp    800659 <vprintfmt+0x348>
	if (lflag >= 2)
  800623:	83 f9 01             	cmp    $0x1,%ecx
  800626:	7f 17                	jg     80063f <vprintfmt+0x32e>
	else if (lflag)
  800628:	85 c9                	test   %ecx,%ecx
  80062a:	74 6e                	je     80069a <vprintfmt+0x389>
		return va_arg(*ap, long);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8b 10                	mov    (%eax),%edx
  800631:	89 d0                	mov    %edx,%eax
  800633:	99                   	cltd   
  800634:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800637:	8d 49 04             	lea    0x4(%ecx),%ecx
  80063a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80063d:	eb 11                	jmp    800650 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8b 50 04             	mov    0x4(%eax),%edx
  800645:	8b 00                	mov    (%eax),%eax
  800647:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80064a:	8d 49 08             	lea    0x8(%ecx),%ecx
  80064d:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800650:	89 d1                	mov    %edx,%ecx
  800652:	89 c2                	mov    %eax,%edx
            base = 8;
  800654:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800659:	83 ec 0c             	sub    $0xc,%esp
  80065c:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800660:	57                   	push   %edi
  800661:	ff 75 e0             	pushl  -0x20(%ebp)
  800664:	50                   	push   %eax
  800665:	51                   	push   %ecx
  800666:	52                   	push   %edx
  800667:	89 da                	mov    %ebx,%edx
  800669:	89 f0                	mov    %esi,%eax
  80066b:	e8 b6 fb ff ff       	call   800226 <printnum>
			break;
  800670:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800673:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800676:	83 c7 01             	add    $0x1,%edi
  800679:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80067d:	83 f8 25             	cmp    $0x25,%eax
  800680:	0f 84 a6 fc ff ff    	je     80032c <vprintfmt+0x1b>
			if (ch == '\0')
  800686:	85 c0                	test   %eax,%eax
  800688:	0f 84 ce 00 00 00    	je     80075c <vprintfmt+0x44b>
			putch(ch, putdat);
  80068e:	83 ec 08             	sub    $0x8,%esp
  800691:	53                   	push   %ebx
  800692:	50                   	push   %eax
  800693:	ff d6                	call   *%esi
  800695:	83 c4 10             	add    $0x10,%esp
  800698:	eb dc                	jmp    800676 <vprintfmt+0x365>
		return va_arg(*ap, int);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8b 10                	mov    (%eax),%edx
  80069f:	89 d0                	mov    %edx,%eax
  8006a1:	99                   	cltd   
  8006a2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006a5:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006a8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006ab:	eb a3                	jmp    800650 <vprintfmt+0x33f>
			putch('0', putdat);
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	53                   	push   %ebx
  8006b1:	6a 30                	push   $0x30
  8006b3:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b5:	83 c4 08             	add    $0x8,%esp
  8006b8:	53                   	push   %ebx
  8006b9:	6a 78                	push   $0x78
  8006bb:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8b 10                	mov    (%eax),%edx
  8006c2:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006c7:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006ca:	8d 40 04             	lea    0x4(%eax),%eax
  8006cd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006d5:	eb 82                	jmp    800659 <vprintfmt+0x348>
	if (lflag >= 2)
  8006d7:	83 f9 01             	cmp    $0x1,%ecx
  8006da:	7f 1e                	jg     8006fa <vprintfmt+0x3e9>
	else if (lflag)
  8006dc:	85 c9                	test   %ecx,%ecx
  8006de:	74 32                	je     800712 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8b 10                	mov    (%eax),%edx
  8006e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ea:	8d 40 04             	lea    0x4(%eax),%eax
  8006ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f0:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006f5:	e9 5f ff ff ff       	jmp    800659 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8b 10                	mov    (%eax),%edx
  8006ff:	8b 48 04             	mov    0x4(%eax),%ecx
  800702:	8d 40 08             	lea    0x8(%eax),%eax
  800705:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800708:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80070d:	e9 47 ff ff ff       	jmp    800659 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8b 10                	mov    (%eax),%edx
  800717:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071c:	8d 40 04             	lea    0x4(%eax),%eax
  80071f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800722:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800727:	e9 2d ff ff ff       	jmp    800659 <vprintfmt+0x348>
			putch(ch, putdat);
  80072c:	83 ec 08             	sub    $0x8,%esp
  80072f:	53                   	push   %ebx
  800730:	6a 25                	push   $0x25
  800732:	ff d6                	call   *%esi
			break;
  800734:	83 c4 10             	add    $0x10,%esp
  800737:	e9 37 ff ff ff       	jmp    800673 <vprintfmt+0x362>
			putch('%', putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	53                   	push   %ebx
  800740:	6a 25                	push   $0x25
  800742:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800744:	83 c4 10             	add    $0x10,%esp
  800747:	89 f8                	mov    %edi,%eax
  800749:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80074d:	74 05                	je     800754 <vprintfmt+0x443>
  80074f:	83 e8 01             	sub    $0x1,%eax
  800752:	eb f5                	jmp    800749 <vprintfmt+0x438>
  800754:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800757:	e9 17 ff ff ff       	jmp    800673 <vprintfmt+0x362>
}
  80075c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80075f:	5b                   	pop    %ebx
  800760:	5e                   	pop    %esi
  800761:	5f                   	pop    %edi
  800762:	5d                   	pop    %ebp
  800763:	c3                   	ret    

00800764 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800764:	f3 0f 1e fb          	endbr32 
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	83 ec 18             	sub    $0x18,%esp
  80076e:	8b 45 08             	mov    0x8(%ebp),%eax
  800771:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800774:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800777:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80077b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80077e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800785:	85 c0                	test   %eax,%eax
  800787:	74 26                	je     8007af <vsnprintf+0x4b>
  800789:	85 d2                	test   %edx,%edx
  80078b:	7e 22                	jle    8007af <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078d:	ff 75 14             	pushl  0x14(%ebp)
  800790:	ff 75 10             	pushl  0x10(%ebp)
  800793:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800796:	50                   	push   %eax
  800797:	68 cf 02 80 00       	push   $0x8002cf
  80079c:	e8 70 fb ff ff       	call   800311 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007aa:	83 c4 10             	add    $0x10,%esp
}
  8007ad:	c9                   	leave  
  8007ae:	c3                   	ret    
		return -E_INVAL;
  8007af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b4:	eb f7                	jmp    8007ad <vsnprintf+0x49>

008007b6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b6:	f3 0f 1e fb          	endbr32 
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c3:	50                   	push   %eax
  8007c4:	ff 75 10             	pushl  0x10(%ebp)
  8007c7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ca:	ff 75 08             	pushl  0x8(%ebp)
  8007cd:	e8 92 ff ff ff       	call   800764 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d2:	c9                   	leave  
  8007d3:	c3                   	ret    

008007d4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d4:	f3 0f 1e fb          	endbr32 
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e7:	74 05                	je     8007ee <strlen+0x1a>
		n++;
  8007e9:	83 c0 01             	add    $0x1,%eax
  8007ec:	eb f5                	jmp    8007e3 <strlen+0xf>
	return n;
}
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f0:	f3 0f 1e fb          	endbr32 
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fa:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800802:	39 d0                	cmp    %edx,%eax
  800804:	74 0d                	je     800813 <strnlen+0x23>
  800806:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80080a:	74 05                	je     800811 <strnlen+0x21>
		n++;
  80080c:	83 c0 01             	add    $0x1,%eax
  80080f:	eb f1                	jmp    800802 <strnlen+0x12>
  800811:	89 c2                	mov    %eax,%edx
	return n;
}
  800813:	89 d0                	mov    %edx,%eax
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800817:	f3 0f 1e fb          	endbr32 
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800822:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800825:	b8 00 00 00 00       	mov    $0x0,%eax
  80082a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80082e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800831:	83 c0 01             	add    $0x1,%eax
  800834:	84 d2                	test   %dl,%dl
  800836:	75 f2                	jne    80082a <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800838:	89 c8                	mov    %ecx,%eax
  80083a:	5b                   	pop    %ebx
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80083d:	f3 0f 1e fb          	endbr32 
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	53                   	push   %ebx
  800845:	83 ec 10             	sub    $0x10,%esp
  800848:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80084b:	53                   	push   %ebx
  80084c:	e8 83 ff ff ff       	call   8007d4 <strlen>
  800851:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800854:	ff 75 0c             	pushl  0xc(%ebp)
  800857:	01 d8                	add    %ebx,%eax
  800859:	50                   	push   %eax
  80085a:	e8 b8 ff ff ff       	call   800817 <strcpy>
	return dst;
}
  80085f:	89 d8                	mov    %ebx,%eax
  800861:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800864:	c9                   	leave  
  800865:	c3                   	ret    

00800866 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800866:	f3 0f 1e fb          	endbr32 
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	56                   	push   %esi
  80086e:	53                   	push   %ebx
  80086f:	8b 75 08             	mov    0x8(%ebp),%esi
  800872:	8b 55 0c             	mov    0xc(%ebp),%edx
  800875:	89 f3                	mov    %esi,%ebx
  800877:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087a:	89 f0                	mov    %esi,%eax
  80087c:	39 d8                	cmp    %ebx,%eax
  80087e:	74 11                	je     800891 <strncpy+0x2b>
		*dst++ = *src;
  800880:	83 c0 01             	add    $0x1,%eax
  800883:	0f b6 0a             	movzbl (%edx),%ecx
  800886:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800889:	80 f9 01             	cmp    $0x1,%cl
  80088c:	83 da ff             	sbb    $0xffffffff,%edx
  80088f:	eb eb                	jmp    80087c <strncpy+0x16>
	}
	return ret;
}
  800891:	89 f0                	mov    %esi,%eax
  800893:	5b                   	pop    %ebx
  800894:	5e                   	pop    %esi
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800897:	f3 0f 1e fb          	endbr32 
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	56                   	push   %esi
  80089f:	53                   	push   %ebx
  8008a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a6:	8b 55 10             	mov    0x10(%ebp),%edx
  8008a9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ab:	85 d2                	test   %edx,%edx
  8008ad:	74 21                	je     8008d0 <strlcpy+0x39>
  8008af:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008b3:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008b5:	39 c2                	cmp    %eax,%edx
  8008b7:	74 14                	je     8008cd <strlcpy+0x36>
  8008b9:	0f b6 19             	movzbl (%ecx),%ebx
  8008bc:	84 db                	test   %bl,%bl
  8008be:	74 0b                	je     8008cb <strlcpy+0x34>
			*dst++ = *src++;
  8008c0:	83 c1 01             	add    $0x1,%ecx
  8008c3:	83 c2 01             	add    $0x1,%edx
  8008c6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008c9:	eb ea                	jmp    8008b5 <strlcpy+0x1e>
  8008cb:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008cd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008d0:	29 f0                	sub    %esi,%eax
}
  8008d2:	5b                   	pop    %ebx
  8008d3:	5e                   	pop    %esi
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d6:	f3 0f 1e fb          	endbr32 
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e3:	0f b6 01             	movzbl (%ecx),%eax
  8008e6:	84 c0                	test   %al,%al
  8008e8:	74 0c                	je     8008f6 <strcmp+0x20>
  8008ea:	3a 02                	cmp    (%edx),%al
  8008ec:	75 08                	jne    8008f6 <strcmp+0x20>
		p++, q++;
  8008ee:	83 c1 01             	add    $0x1,%ecx
  8008f1:	83 c2 01             	add    $0x1,%edx
  8008f4:	eb ed                	jmp    8008e3 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f6:	0f b6 c0             	movzbl %al,%eax
  8008f9:	0f b6 12             	movzbl (%edx),%edx
  8008fc:	29 d0                	sub    %edx,%eax
}
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800900:	f3 0f 1e fb          	endbr32 
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	53                   	push   %ebx
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090e:	89 c3                	mov    %eax,%ebx
  800910:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800913:	eb 06                	jmp    80091b <strncmp+0x1b>
		n--, p++, q++;
  800915:	83 c0 01             	add    $0x1,%eax
  800918:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80091b:	39 d8                	cmp    %ebx,%eax
  80091d:	74 16                	je     800935 <strncmp+0x35>
  80091f:	0f b6 08             	movzbl (%eax),%ecx
  800922:	84 c9                	test   %cl,%cl
  800924:	74 04                	je     80092a <strncmp+0x2a>
  800926:	3a 0a                	cmp    (%edx),%cl
  800928:	74 eb                	je     800915 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092a:	0f b6 00             	movzbl (%eax),%eax
  80092d:	0f b6 12             	movzbl (%edx),%edx
  800930:	29 d0                	sub    %edx,%eax
}
  800932:	5b                   	pop    %ebx
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    
		return 0;
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
  80093a:	eb f6                	jmp    800932 <strncmp+0x32>

0080093c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093c:	f3 0f 1e fb          	endbr32 
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80094a:	0f b6 10             	movzbl (%eax),%edx
  80094d:	84 d2                	test   %dl,%dl
  80094f:	74 09                	je     80095a <strchr+0x1e>
		if (*s == c)
  800951:	38 ca                	cmp    %cl,%dl
  800953:	74 0a                	je     80095f <strchr+0x23>
	for (; *s; s++)
  800955:	83 c0 01             	add    $0x1,%eax
  800958:	eb f0                	jmp    80094a <strchr+0xe>
			return (char *) s;
	return 0;
  80095a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800961:	f3 0f 1e fb          	endbr32 
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80096f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800972:	38 ca                	cmp    %cl,%dl
  800974:	74 09                	je     80097f <strfind+0x1e>
  800976:	84 d2                	test   %dl,%dl
  800978:	74 05                	je     80097f <strfind+0x1e>
	for (; *s; s++)
  80097a:	83 c0 01             	add    $0x1,%eax
  80097d:	eb f0                	jmp    80096f <strfind+0xe>
			break;
	return (char *) s;
}
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800981:	f3 0f 1e fb          	endbr32 
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	57                   	push   %edi
  800989:	56                   	push   %esi
  80098a:	53                   	push   %ebx
  80098b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80098e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800991:	85 c9                	test   %ecx,%ecx
  800993:	74 31                	je     8009c6 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800995:	89 f8                	mov    %edi,%eax
  800997:	09 c8                	or     %ecx,%eax
  800999:	a8 03                	test   $0x3,%al
  80099b:	75 23                	jne    8009c0 <memset+0x3f>
		c &= 0xFF;
  80099d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a1:	89 d3                	mov    %edx,%ebx
  8009a3:	c1 e3 08             	shl    $0x8,%ebx
  8009a6:	89 d0                	mov    %edx,%eax
  8009a8:	c1 e0 18             	shl    $0x18,%eax
  8009ab:	89 d6                	mov    %edx,%esi
  8009ad:	c1 e6 10             	shl    $0x10,%esi
  8009b0:	09 f0                	or     %esi,%eax
  8009b2:	09 c2                	or     %eax,%edx
  8009b4:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009b6:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009b9:	89 d0                	mov    %edx,%eax
  8009bb:	fc                   	cld    
  8009bc:	f3 ab                	rep stos %eax,%es:(%edi)
  8009be:	eb 06                	jmp    8009c6 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c3:	fc                   	cld    
  8009c4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c6:	89 f8                	mov    %edi,%eax
  8009c8:	5b                   	pop    %ebx
  8009c9:	5e                   	pop    %esi
  8009ca:	5f                   	pop    %edi
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009cd:	f3 0f 1e fb          	endbr32 
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	57                   	push   %edi
  8009d5:	56                   	push   %esi
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009df:	39 c6                	cmp    %eax,%esi
  8009e1:	73 32                	jae    800a15 <memmove+0x48>
  8009e3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e6:	39 c2                	cmp    %eax,%edx
  8009e8:	76 2b                	jbe    800a15 <memmove+0x48>
		s += n;
		d += n;
  8009ea:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ed:	89 fe                	mov    %edi,%esi
  8009ef:	09 ce                	or     %ecx,%esi
  8009f1:	09 d6                	or     %edx,%esi
  8009f3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f9:	75 0e                	jne    800a09 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009fb:	83 ef 04             	sub    $0x4,%edi
  8009fe:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a01:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a04:	fd                   	std    
  800a05:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a07:	eb 09                	jmp    800a12 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a09:	83 ef 01             	sub    $0x1,%edi
  800a0c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a0f:	fd                   	std    
  800a10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a12:	fc                   	cld    
  800a13:	eb 1a                	jmp    800a2f <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a15:	89 c2                	mov    %eax,%edx
  800a17:	09 ca                	or     %ecx,%edx
  800a19:	09 f2                	or     %esi,%edx
  800a1b:	f6 c2 03             	test   $0x3,%dl
  800a1e:	75 0a                	jne    800a2a <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a20:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a23:	89 c7                	mov    %eax,%edi
  800a25:	fc                   	cld    
  800a26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a28:	eb 05                	jmp    800a2f <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a2a:	89 c7                	mov    %eax,%edi
  800a2c:	fc                   	cld    
  800a2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a2f:	5e                   	pop    %esi
  800a30:	5f                   	pop    %edi
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a33:	f3 0f 1e fb          	endbr32 
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a3d:	ff 75 10             	pushl  0x10(%ebp)
  800a40:	ff 75 0c             	pushl  0xc(%ebp)
  800a43:	ff 75 08             	pushl  0x8(%ebp)
  800a46:	e8 82 ff ff ff       	call   8009cd <memmove>
}
  800a4b:	c9                   	leave  
  800a4c:	c3                   	ret    

00800a4d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a4d:	f3 0f 1e fb          	endbr32 
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	56                   	push   %esi
  800a55:	53                   	push   %ebx
  800a56:	8b 45 08             	mov    0x8(%ebp),%eax
  800a59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5c:	89 c6                	mov    %eax,%esi
  800a5e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a61:	39 f0                	cmp    %esi,%eax
  800a63:	74 1c                	je     800a81 <memcmp+0x34>
		if (*s1 != *s2)
  800a65:	0f b6 08             	movzbl (%eax),%ecx
  800a68:	0f b6 1a             	movzbl (%edx),%ebx
  800a6b:	38 d9                	cmp    %bl,%cl
  800a6d:	75 08                	jne    800a77 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a6f:	83 c0 01             	add    $0x1,%eax
  800a72:	83 c2 01             	add    $0x1,%edx
  800a75:	eb ea                	jmp    800a61 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a77:	0f b6 c1             	movzbl %cl,%eax
  800a7a:	0f b6 db             	movzbl %bl,%ebx
  800a7d:	29 d8                	sub    %ebx,%eax
  800a7f:	eb 05                	jmp    800a86 <memcmp+0x39>
	}

	return 0;
  800a81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a86:	5b                   	pop    %ebx
  800a87:	5e                   	pop    %esi
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a8a:	f3 0f 1e fb          	endbr32 
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	8b 45 08             	mov    0x8(%ebp),%eax
  800a94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a97:	89 c2                	mov    %eax,%edx
  800a99:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a9c:	39 d0                	cmp    %edx,%eax
  800a9e:	73 09                	jae    800aa9 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa0:	38 08                	cmp    %cl,(%eax)
  800aa2:	74 05                	je     800aa9 <memfind+0x1f>
	for (; s < ends; s++)
  800aa4:	83 c0 01             	add    $0x1,%eax
  800aa7:	eb f3                	jmp    800a9c <memfind+0x12>
			break;
	return (void *) s;
}
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aab:	f3 0f 1e fb          	endbr32 
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	57                   	push   %edi
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
  800ab5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800abb:	eb 03                	jmp    800ac0 <strtol+0x15>
		s++;
  800abd:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ac0:	0f b6 01             	movzbl (%ecx),%eax
  800ac3:	3c 20                	cmp    $0x20,%al
  800ac5:	74 f6                	je     800abd <strtol+0x12>
  800ac7:	3c 09                	cmp    $0x9,%al
  800ac9:	74 f2                	je     800abd <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800acb:	3c 2b                	cmp    $0x2b,%al
  800acd:	74 2a                	je     800af9 <strtol+0x4e>
	int neg = 0;
  800acf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ad4:	3c 2d                	cmp    $0x2d,%al
  800ad6:	74 2b                	je     800b03 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ade:	75 0f                	jne    800aef <strtol+0x44>
  800ae0:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae3:	74 28                	je     800b0d <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ae5:	85 db                	test   %ebx,%ebx
  800ae7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aec:	0f 44 d8             	cmove  %eax,%ebx
  800aef:	b8 00 00 00 00       	mov    $0x0,%eax
  800af4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800af7:	eb 46                	jmp    800b3f <strtol+0x94>
		s++;
  800af9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800afc:	bf 00 00 00 00       	mov    $0x0,%edi
  800b01:	eb d5                	jmp    800ad8 <strtol+0x2d>
		s++, neg = 1;
  800b03:	83 c1 01             	add    $0x1,%ecx
  800b06:	bf 01 00 00 00       	mov    $0x1,%edi
  800b0b:	eb cb                	jmp    800ad8 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b0d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b11:	74 0e                	je     800b21 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b13:	85 db                	test   %ebx,%ebx
  800b15:	75 d8                	jne    800aef <strtol+0x44>
		s++, base = 8;
  800b17:	83 c1 01             	add    $0x1,%ecx
  800b1a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b1f:	eb ce                	jmp    800aef <strtol+0x44>
		s += 2, base = 16;
  800b21:	83 c1 02             	add    $0x2,%ecx
  800b24:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b29:	eb c4                	jmp    800aef <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b2b:	0f be d2             	movsbl %dl,%edx
  800b2e:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b31:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b34:	7d 3a                	jge    800b70 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b36:	83 c1 01             	add    $0x1,%ecx
  800b39:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b3d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b3f:	0f b6 11             	movzbl (%ecx),%edx
  800b42:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b45:	89 f3                	mov    %esi,%ebx
  800b47:	80 fb 09             	cmp    $0x9,%bl
  800b4a:	76 df                	jbe    800b2b <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b4c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b4f:	89 f3                	mov    %esi,%ebx
  800b51:	80 fb 19             	cmp    $0x19,%bl
  800b54:	77 08                	ja     800b5e <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b56:	0f be d2             	movsbl %dl,%edx
  800b59:	83 ea 57             	sub    $0x57,%edx
  800b5c:	eb d3                	jmp    800b31 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b5e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b61:	89 f3                	mov    %esi,%ebx
  800b63:	80 fb 19             	cmp    $0x19,%bl
  800b66:	77 08                	ja     800b70 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b68:	0f be d2             	movsbl %dl,%edx
  800b6b:	83 ea 37             	sub    $0x37,%edx
  800b6e:	eb c1                	jmp    800b31 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b70:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b74:	74 05                	je     800b7b <strtol+0xd0>
		*endptr = (char *) s;
  800b76:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b79:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b7b:	89 c2                	mov    %eax,%edx
  800b7d:	f7 da                	neg    %edx
  800b7f:	85 ff                	test   %edi,%edi
  800b81:	0f 45 c2             	cmovne %edx,%eax
}
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b89:	f3 0f 1e fb          	endbr32 
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
  800b98:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9e:	89 c3                	mov    %eax,%ebx
  800ba0:	89 c7                	mov    %eax,%edi
  800ba2:	89 c6                	mov    %eax,%esi
  800ba4:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba6:	5b                   	pop    %ebx
  800ba7:	5e                   	pop    %esi
  800ba8:	5f                   	pop    %edi
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <sys_cgetc>:

int
sys_cgetc(void)
{
  800bab:	f3 0f 1e fb          	endbr32 
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bba:	b8 01 00 00 00       	mov    $0x1,%eax
  800bbf:	89 d1                	mov    %edx,%ecx
  800bc1:	89 d3                	mov    %edx,%ebx
  800bc3:	89 d7                	mov    %edx,%edi
  800bc5:	89 d6                	mov    %edx,%esi
  800bc7:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bce:	f3 0f 1e fb          	endbr32 
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
  800bd8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bdb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be0:	8b 55 08             	mov    0x8(%ebp),%edx
  800be3:	b8 03 00 00 00       	mov    $0x3,%eax
  800be8:	89 cb                	mov    %ecx,%ebx
  800bea:	89 cf                	mov    %ecx,%edi
  800bec:	89 ce                	mov    %ecx,%esi
  800bee:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bf0:	85 c0                	test   %eax,%eax
  800bf2:	7f 08                	jg     800bfc <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfc:	83 ec 0c             	sub    $0xc,%esp
  800bff:	50                   	push   %eax
  800c00:	6a 03                	push   $0x3
  800c02:	68 5f 18 80 00       	push   $0x80185f
  800c07:	6a 23                	push   $0x23
  800c09:	68 7c 18 80 00       	push   $0x80187c
  800c0e:	e8 9d 05 00 00       	call   8011b0 <_panic>

00800c13 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c13:	f3 0f 1e fb          	endbr32 
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c22:	b8 02 00 00 00       	mov    $0x2,%eax
  800c27:	89 d1                	mov    %edx,%ecx
  800c29:	89 d3                	mov    %edx,%ebx
  800c2b:	89 d7                	mov    %edx,%edi
  800c2d:	89 d6                	mov    %edx,%esi
  800c2f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <sys_yield>:

void
sys_yield(void)
{
  800c36:	f3 0f 1e fb          	endbr32 
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c40:	ba 00 00 00 00       	mov    $0x0,%edx
  800c45:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c4a:	89 d1                	mov    %edx,%ecx
  800c4c:	89 d3                	mov    %edx,%ebx
  800c4e:	89 d7                	mov    %edx,%edi
  800c50:	89 d6                	mov    %edx,%esi
  800c52:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c59:	f3 0f 1e fb          	endbr32 
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	57                   	push   %edi
  800c61:	56                   	push   %esi
  800c62:	53                   	push   %ebx
  800c63:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c66:	be 00 00 00 00       	mov    $0x0,%esi
  800c6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c71:	b8 04 00 00 00       	mov    $0x4,%eax
  800c76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c79:	89 f7                	mov    %esi,%edi
  800c7b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	7f 08                	jg     800c89 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c89:	83 ec 0c             	sub    $0xc,%esp
  800c8c:	50                   	push   %eax
  800c8d:	6a 04                	push   $0x4
  800c8f:	68 5f 18 80 00       	push   $0x80185f
  800c94:	6a 23                	push   $0x23
  800c96:	68 7c 18 80 00       	push   $0x80187c
  800c9b:	e8 10 05 00 00       	call   8011b0 <_panic>

00800ca0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca0:	f3 0f 1e fb          	endbr32 
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
  800caa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	b8 05 00 00 00       	mov    $0x5,%eax
  800cb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cbe:	8b 75 18             	mov    0x18(%ebp),%esi
  800cc1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc3:	85 c0                	test   %eax,%eax
  800cc5:	7f 08                	jg     800ccf <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cca:	5b                   	pop    %ebx
  800ccb:	5e                   	pop    %esi
  800ccc:	5f                   	pop    %edi
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	50                   	push   %eax
  800cd3:	6a 05                	push   $0x5
  800cd5:	68 5f 18 80 00       	push   $0x80185f
  800cda:	6a 23                	push   $0x23
  800cdc:	68 7c 18 80 00       	push   $0x80187c
  800ce1:	e8 ca 04 00 00       	call   8011b0 <_panic>

00800ce6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ce6:	f3 0f 1e fb          	endbr32 
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
  800cf0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	b8 06 00 00 00       	mov    $0x6,%eax
  800d03:	89 df                	mov    %ebx,%edi
  800d05:	89 de                	mov    %ebx,%esi
  800d07:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	7f 08                	jg     800d15 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d15:	83 ec 0c             	sub    $0xc,%esp
  800d18:	50                   	push   %eax
  800d19:	6a 06                	push   $0x6
  800d1b:	68 5f 18 80 00       	push   $0x80185f
  800d20:	6a 23                	push   $0x23
  800d22:	68 7c 18 80 00       	push   $0x80187c
  800d27:	e8 84 04 00 00       	call   8011b0 <_panic>

00800d2c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d2c:	f3 0f 1e fb          	endbr32 
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d44:	b8 08 00 00 00       	mov    $0x8,%eax
  800d49:	89 df                	mov    %ebx,%edi
  800d4b:	89 de                	mov    %ebx,%esi
  800d4d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	7f 08                	jg     800d5b <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5b:	83 ec 0c             	sub    $0xc,%esp
  800d5e:	50                   	push   %eax
  800d5f:	6a 08                	push   $0x8
  800d61:	68 5f 18 80 00       	push   $0x80185f
  800d66:	6a 23                	push   $0x23
  800d68:	68 7c 18 80 00       	push   $0x80187c
  800d6d:	e8 3e 04 00 00       	call   8011b0 <_panic>

00800d72 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d72:	f3 0f 1e fb          	endbr32 
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	57                   	push   %edi
  800d7a:	56                   	push   %esi
  800d7b:	53                   	push   %ebx
  800d7c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d84:	8b 55 08             	mov    0x8(%ebp),%edx
  800d87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d8f:	89 df                	mov    %ebx,%edi
  800d91:	89 de                	mov    %ebx,%esi
  800d93:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d95:	85 c0                	test   %eax,%eax
  800d97:	7f 08                	jg     800da1 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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
  800da5:	6a 09                	push   $0x9
  800da7:	68 5f 18 80 00       	push   $0x80185f
  800dac:	6a 23                	push   $0x23
  800dae:	68 7c 18 80 00       	push   $0x80187c
  800db3:	e8 f8 03 00 00       	call   8011b0 <_panic>

00800db8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800db8:	f3 0f 1e fb          	endbr32 
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	57                   	push   %edi
  800dc0:	56                   	push   %esi
  800dc1:	53                   	push   %ebx
  800dc2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dca:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dd5:	89 df                	mov    %ebx,%edi
  800dd7:	89 de                	mov    %ebx,%esi
  800dd9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	7f 08                	jg     800de7 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ddf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de7:	83 ec 0c             	sub    $0xc,%esp
  800dea:	50                   	push   %eax
  800deb:	6a 0a                	push   $0xa
  800ded:	68 5f 18 80 00       	push   $0x80185f
  800df2:	6a 23                	push   $0x23
  800df4:	68 7c 18 80 00       	push   $0x80187c
  800df9:	e8 b2 03 00 00       	call   8011b0 <_panic>

00800dfe <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dfe:	f3 0f 1e fb          	endbr32 
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e08:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e13:	be 00 00 00 00       	mov    $0x0,%esi
  800e18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e1e:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e25:	f3 0f 1e fb          	endbr32 
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e37:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e3f:	89 cb                	mov    %ecx,%ebx
  800e41:	89 cf                	mov    %ecx,%edi
  800e43:	89 ce                	mov    %ecx,%esi
  800e45:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e47:	85 c0                	test   %eax,%eax
  800e49:	7f 08                	jg     800e53 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e53:	83 ec 0c             	sub    $0xc,%esp
  800e56:	50                   	push   %eax
  800e57:	6a 0d                	push   $0xd
  800e59:	68 5f 18 80 00       	push   $0x80185f
  800e5e:	6a 23                	push   $0x23
  800e60:	68 7c 18 80 00       	push   $0x80187c
  800e65:	e8 46 03 00 00       	call   8011b0 <_panic>

00800e6a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e6a:	f3 0f 1e fb          	endbr32 
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	53                   	push   %ebx
  800e72:	83 ec 04             	sub    $0x4,%esp
  800e75:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e78:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if ( !(err & FEC_WR) ||
  800e7a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e7e:	74 75                	je     800ef5 <pgfault+0x8b>
            !(uvpt[PGNUM(addr)] | PTE_COW) ) {
  800e80:	89 d8                	mov    %ebx,%eax
  800e82:	c1 e8 0c             	shr    $0xc,%eax
  800e85:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0) {
  800e8c:	83 ec 04             	sub    $0x4,%esp
  800e8f:	6a 07                	push   $0x7
  800e91:	68 00 f0 7f 00       	push   $0x7ff000
  800e96:	6a 00                	push   $0x0
  800e98:	e8 bc fd ff ff       	call   800c59 <sys_page_alloc>
  800e9d:	83 c4 10             	add    $0x10,%esp
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	78 65                	js     800f09 <pgfault+0x9f>
        panic("sys_page_alloc failed %e\n", r);
    }
    memmove((void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);
  800ea4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800eaa:	83 ec 04             	sub    $0x4,%esp
  800ead:	68 00 10 00 00       	push   $0x1000
  800eb2:	53                   	push   %ebx
  800eb3:	68 00 f0 7f 00       	push   $0x7ff000
  800eb8:	e8 10 fb ff ff       	call   8009cd <memmove>
    if ((r = sys_page_map(0, (void *)PFTEMP,
  800ebd:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ec4:	53                   	push   %ebx
  800ec5:	6a 00                	push   $0x0
  800ec7:	68 00 f0 7f 00       	push   $0x7ff000
  800ecc:	6a 00                	push   $0x0
  800ece:	e8 cd fd ff ff       	call   800ca0 <sys_page_map>
  800ed3:	83 c4 20             	add    $0x20,%esp
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	78 41                	js     800f1b <pgfault+0xb1>
                0, (void *)PTE_ADDR(addr), PTE_P | PTE_U | PTE_W)) < 0) {
        panic("sys_page_map failed %e\n", r);
    }
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0) {
  800eda:	83 ec 08             	sub    $0x8,%esp
  800edd:	68 00 f0 7f 00       	push   $0x7ff000
  800ee2:	6a 00                	push   $0x0
  800ee4:	e8 fd fd ff ff       	call   800ce6 <sys_page_unmap>
  800ee9:	83 c4 10             	add    $0x10,%esp
  800eec:	85 c0                	test   %eax,%eax
  800eee:	78 3d                	js     800f2d <pgfault+0xc3>
        panic("sys_page_unmap failed %e\n", r);
    }

}
  800ef0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef3:	c9                   	leave  
  800ef4:	c3                   	ret    
        panic("Not a copy-on-write page");
  800ef5:	83 ec 04             	sub    $0x4,%esp
  800ef8:	68 8a 18 80 00       	push   $0x80188a
  800efd:	6a 1e                	push   $0x1e
  800eff:	68 a3 18 80 00       	push   $0x8018a3
  800f04:	e8 a7 02 00 00       	call   8011b0 <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800f09:	50                   	push   %eax
  800f0a:	68 ae 18 80 00       	push   $0x8018ae
  800f0f:	6a 2a                	push   $0x2a
  800f11:	68 a3 18 80 00       	push   $0x8018a3
  800f16:	e8 95 02 00 00       	call   8011b0 <_panic>
        panic("sys_page_map failed %e\n", r);
  800f1b:	50                   	push   %eax
  800f1c:	68 c8 18 80 00       	push   $0x8018c8
  800f21:	6a 2f                	push   $0x2f
  800f23:	68 a3 18 80 00       	push   $0x8018a3
  800f28:	e8 83 02 00 00       	call   8011b0 <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800f2d:	50                   	push   %eax
  800f2e:	68 e0 18 80 00       	push   $0x8018e0
  800f33:	6a 32                	push   $0x32
  800f35:	68 a3 18 80 00       	push   $0x8018a3
  800f3a:	e8 71 02 00 00       	call   8011b0 <_panic>

00800f3f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f3f:	f3 0f 1e fb          	endbr32 
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	57                   	push   %edi
  800f47:	56                   	push   %esi
  800f48:	53                   	push   %ebx
  800f49:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");

    // 1. set pgfault handler.
    set_pgfault_handler(pgfault);
  800f4c:	68 6a 0e 80 00       	push   $0x800e6a
  800f51:	e8 a4 02 00 00       	call   8011fa <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f56:	b8 07 00 00 00       	mov    $0x7,%eax
  800f5b:	cd 30                	int    $0x30
  800f5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f60:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 2. exofork.
    envid_t envid = sys_exofork();

    if (envid < 0)
  800f63:	83 c4 10             	add    $0x10,%esp
  800f66:	85 c0                	test   %eax,%eax
  800f68:	78 2a                	js     800f94 <fork+0x55>
        thisenv = &envs[ENVX(my_envid)];
        return 0;
    }
    else {
        // parent
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f6a:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800f6f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f73:	75 69                	jne    800fde <fork+0x9f>
        envid_t my_envid = sys_getenvid();
  800f75:	e8 99 fc ff ff       	call   800c13 <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800f7a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f7f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f82:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f87:	a3 08 20 80 00       	mov    %eax,0x802008
        return 0;
  800f8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f8f:	e9 fc 00 00 00       	jmp    801090 <fork+0x151>
        panic("fork, sys_exofork %e", envid);
  800f94:	50                   	push   %eax
  800f95:	68 fa 18 80 00       	push   $0x8018fa
  800f9a:	6a 7b                	push   $0x7b
  800f9c:	68 a3 18 80 00       	push   $0x8018a3
  800fa1:	e8 0a 02 00 00       	call   8011b0 <_panic>
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  800fa6:	83 ec 0c             	sub    $0xc,%esp
  800fa9:	57                   	push   %edi
  800faa:	56                   	push   %esi
  800fab:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fae:	56                   	push   %esi
  800faf:	6a 00                	push   $0x0
  800fb1:	e8 ea fc ff ff       	call   800ca0 <sys_page_map>
  800fb6:	83 c4 20             	add    $0x20,%esp
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	78 69                	js     801026 <fork+0xe7>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  800fbd:	83 ec 0c             	sub    $0xc,%esp
  800fc0:	57                   	push   %edi
  800fc1:	56                   	push   %esi
  800fc2:	6a 00                	push   $0x0
  800fc4:	56                   	push   %esi
  800fc5:	6a 00                	push   $0x0
  800fc7:	e8 d4 fc ff ff       	call   800ca0 <sys_page_map>
  800fcc:	83 c4 20             	add    $0x20,%esp
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	78 65                	js     801038 <fork+0xf9>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800fd3:	83 c3 01             	add    $0x1,%ebx
  800fd6:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800fdc:	74 6c                	je     80104a <fork+0x10b>
  800fde:	89 de                	mov    %ebx,%esi
  800fe0:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800fe3:	89 f0                	mov    %esi,%eax
  800fe5:	c1 e8 16             	shr    $0x16,%eax
  800fe8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fef:	a8 01                	test   $0x1,%al
  800ff1:	74 e0                	je     800fd3 <fork+0x94>
                    (uvpt[pn] & PTE_P) ) {
  800ff3:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800ffa:	a8 01                	test   $0x1,%al
  800ffc:	74 d5                	je     800fd3 <fork+0x94>
    pte_t pte = uvpt[pn];
  800ffe:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    int perm = PTE_U | PTE_P;
  801005:	bf 05 00 00 00       	mov    $0x5,%edi
    if ( ((pte & PTE_W) || (pte & PTE_COW)) && !(pte & PTE_SHARE)) {
  80100a:	a9 02 08 00 00       	test   $0x802,%eax
  80100f:	74 95                	je     800fa6 <fork+0x67>
  801011:	25 00 04 00 00       	and    $0x400,%eax
        perm |= PTE_COW;
  801016:	83 f8 01             	cmp    $0x1,%eax
  801019:	19 ff                	sbb    %edi,%edi
  80101b:	81 e7 00 08 00 00    	and    $0x800,%edi
  801021:	83 c7 05             	add    $0x5,%edi
  801024:	eb 80                	jmp    800fa6 <fork+0x67>
        panic("sys_page_map others failed %e\n", r);
  801026:	50                   	push   %eax
  801027:	68 44 19 80 00       	push   $0x801944
  80102c:	6a 51                	push   $0x51
  80102e:	68 a3 18 80 00       	push   $0x8018a3
  801033:	e8 78 01 00 00       	call   8011b0 <_panic>
            panic("sys_page_map mine failed %e\n", r);
  801038:	50                   	push   %eax
  801039:	68 0f 19 80 00       	push   $0x80190f
  80103e:	6a 56                	push   $0x56
  801040:	68 a3 18 80 00       	push   $0x8018a3
  801045:	e8 66 01 00 00       	call   8011b0 <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  80104a:	83 ec 04             	sub    $0x4,%esp
  80104d:	6a 07                	push   $0x7
  80104f:	68 00 f0 bf ee       	push   $0xeebff000
  801054:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801057:	57                   	push   %edi
  801058:	e8 fc fb ff ff       	call   800c59 <sys_page_alloc>
  80105d:	83 c4 10             	add    $0x10,%esp
  801060:	85 c0                	test   %eax,%eax
  801062:	78 2c                	js     801090 <fork+0x151>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  801064:	a1 08 20 80 00       	mov    0x802008,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  801069:	8b 40 64             	mov    0x64(%eax),%eax
  80106c:	83 ec 08             	sub    $0x8,%esp
  80106f:	50                   	push   %eax
  801070:	57                   	push   %edi
  801071:	e8 42 fd ff ff       	call   800db8 <sys_env_set_pgfault_upcall>
  801076:	83 c4 10             	add    $0x10,%esp
  801079:	85 c0                	test   %eax,%eax
  80107b:	78 13                	js     801090 <fork+0x151>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  80107d:	83 ec 08             	sub    $0x8,%esp
  801080:	6a 02                	push   $0x2
  801082:	57                   	push   %edi
  801083:	e8 a4 fc ff ff       	call   800d2c <sys_env_set_status>
  801088:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  80108b:	85 c0                	test   %eax,%eax
  80108d:	0f 49 c7             	cmovns %edi,%eax
    }

}
  801090:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801093:	5b                   	pop    %ebx
  801094:	5e                   	pop    %esi
  801095:	5f                   	pop    %edi
  801096:	5d                   	pop    %ebp
  801097:	c3                   	ret    

00801098 <sfork>:

// Challenge!
int
sfork(void)
{
  801098:	f3 0f 1e fb          	endbr32 
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010a2:	68 2c 19 80 00       	push   $0x80192c
  8010a7:	68 a5 00 00 00       	push   $0xa5
  8010ac:	68 a3 18 80 00       	push   $0x8018a3
  8010b1:	e8 fa 00 00 00       	call   8011b0 <_panic>

008010b6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010b6:	f3 0f 1e fb          	endbr32 
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	56                   	push   %esi
  8010be:	53                   	push   %ebx
  8010bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8010c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c5:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  8010c8:	85 c0                	test   %eax,%eax
  8010ca:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8010cf:	0f 44 c2             	cmove  %edx,%eax
  8010d2:	83 ec 0c             	sub    $0xc,%esp
  8010d5:	50                   	push   %eax
  8010d6:	e8 4a fd ff ff       	call   800e25 <sys_ipc_recv>
  8010db:	83 c4 10             	add    $0x10,%esp
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	78 24                	js     801106 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  8010e2:	85 f6                	test   %esi,%esi
  8010e4:	74 0a                	je     8010f0 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  8010e6:	a1 08 20 80 00       	mov    0x802008,%eax
  8010eb:	8b 40 78             	mov    0x78(%eax),%eax
  8010ee:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  8010f0:	85 db                	test   %ebx,%ebx
  8010f2:	74 0a                	je     8010fe <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  8010f4:	a1 08 20 80 00       	mov    0x802008,%eax
  8010f9:	8b 40 74             	mov    0x74(%eax),%eax
  8010fc:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  8010fe:	a1 08 20 80 00       	mov    0x802008,%eax
  801103:	8b 40 70             	mov    0x70(%eax),%eax
}
  801106:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801109:	5b                   	pop    %ebx
  80110a:	5e                   	pop    %esi
  80110b:	5d                   	pop    %ebp
  80110c:	c3                   	ret    

0080110d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80110d:	f3 0f 1e fb          	endbr32 
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	57                   	push   %edi
  801115:	56                   	push   %esi
  801116:	53                   	push   %ebx
  801117:	83 ec 1c             	sub    $0x1c,%esp
  80111a:	8b 45 10             	mov    0x10(%ebp),%eax
  80111d:	85 c0                	test   %eax,%eax
  80111f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801124:	0f 45 d0             	cmovne %eax,%edx
  801127:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801129:	be 01 00 00 00       	mov    $0x1,%esi
  80112e:	eb 1f                	jmp    80114f <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801130:	e8 01 fb ff ff       	call   800c36 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801135:	83 c3 01             	add    $0x1,%ebx
  801138:	39 de                	cmp    %ebx,%esi
  80113a:	7f f4                	jg     801130 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  80113c:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  80113e:	83 fe 11             	cmp    $0x11,%esi
  801141:	b8 01 00 00 00       	mov    $0x1,%eax
  801146:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801149:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  80114d:	75 1c                	jne    80116b <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  80114f:	ff 75 14             	pushl  0x14(%ebp)
  801152:	57                   	push   %edi
  801153:	ff 75 0c             	pushl  0xc(%ebp)
  801156:	ff 75 08             	pushl  0x8(%ebp)
  801159:	e8 a0 fc ff ff       	call   800dfe <sys_ipc_try_send>
  80115e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801161:	83 c4 10             	add    $0x10,%esp
  801164:	bb 00 00 00 00       	mov    $0x0,%ebx
  801169:	eb cd                	jmp    801138 <ipc_send+0x2b>
}
  80116b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116e:	5b                   	pop    %ebx
  80116f:	5e                   	pop    %esi
  801170:	5f                   	pop    %edi
  801171:	5d                   	pop    %ebp
  801172:	c3                   	ret    

00801173 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801173:	f3 0f 1e fb          	endbr32 
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80117d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801182:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801185:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80118b:	8b 52 50             	mov    0x50(%edx),%edx
  80118e:	39 ca                	cmp    %ecx,%edx
  801190:	74 11                	je     8011a3 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801192:	83 c0 01             	add    $0x1,%eax
  801195:	3d 00 04 00 00       	cmp    $0x400,%eax
  80119a:	75 e6                	jne    801182 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80119c:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a1:	eb 0b                	jmp    8011ae <ipc_find_env+0x3b>
			return envs[i].env_id;
  8011a3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011a6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011ab:	8b 40 48             	mov    0x48(%eax),%eax
}
  8011ae:	5d                   	pop    %ebp
  8011af:	c3                   	ret    

008011b0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8011b0:	f3 0f 1e fb          	endbr32 
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	56                   	push   %esi
  8011b8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8011b9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8011bc:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8011c2:	e8 4c fa ff ff       	call   800c13 <sys_getenvid>
  8011c7:	83 ec 0c             	sub    $0xc,%esp
  8011ca:	ff 75 0c             	pushl  0xc(%ebp)
  8011cd:	ff 75 08             	pushl  0x8(%ebp)
  8011d0:	56                   	push   %esi
  8011d1:	50                   	push   %eax
  8011d2:	68 64 19 80 00       	push   $0x801964
  8011d7:	e8 32 f0 ff ff       	call   80020e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011dc:	83 c4 18             	add    $0x18,%esp
  8011df:	53                   	push   %ebx
  8011e0:	ff 75 10             	pushl  0x10(%ebp)
  8011e3:	e8 d1 ef ff ff       	call   8001b9 <vcprintf>
	cprintf("\n");
  8011e8:	c7 04 24 94 19 80 00 	movl   $0x801994,(%esp)
  8011ef:	e8 1a f0 ff ff       	call   80020e <cprintf>
  8011f4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011f7:	cc                   	int3   
  8011f8:	eb fd                	jmp    8011f7 <_panic+0x47>

008011fa <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011fa:	f3 0f 1e fb          	endbr32 
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801204:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  80120b:	74 0a                	je     801217 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80120d:	8b 45 08             	mov    0x8(%ebp),%eax
  801210:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  801215:	c9                   	leave  
  801216:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801217:	83 ec 0c             	sub    $0xc,%esp
  80121a:	68 87 19 80 00       	push   $0x801987
  80121f:	e8 ea ef ff ff       	call   80020e <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  801224:	83 c4 0c             	add    $0xc,%esp
  801227:	6a 07                	push   $0x7
  801229:	68 00 f0 bf ee       	push   $0xeebff000
  80122e:	6a 00                	push   $0x0
  801230:	e8 24 fa ff ff       	call   800c59 <sys_page_alloc>
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	85 c0                	test   %eax,%eax
  80123a:	78 2a                	js     801266 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  80123c:	83 ec 08             	sub    $0x8,%esp
  80123f:	68 7a 12 80 00       	push   $0x80127a
  801244:	6a 00                	push   $0x0
  801246:	e8 6d fb ff ff       	call   800db8 <sys_env_set_pgfault_upcall>
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	85 c0                	test   %eax,%eax
  801250:	79 bb                	jns    80120d <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  801252:	83 ec 04             	sub    $0x4,%esp
  801255:	68 c4 19 80 00       	push   $0x8019c4
  80125a:	6a 25                	push   $0x25
  80125c:	68 b4 19 80 00       	push   $0x8019b4
  801261:	e8 4a ff ff ff       	call   8011b0 <_panic>
            panic("Allocation of UXSTACK failed!");
  801266:	83 ec 04             	sub    $0x4,%esp
  801269:	68 96 19 80 00       	push   $0x801996
  80126e:	6a 22                	push   $0x22
  801270:	68 b4 19 80 00       	push   $0x8019b4
  801275:	e8 36 ff ff ff       	call   8011b0 <_panic>

0080127a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80127a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80127b:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801280:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801282:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  801285:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  801289:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  80128d:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  801290:	83 c4 08             	add    $0x8,%esp
    popa
  801293:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  801294:	83 c4 04             	add    $0x4,%esp
    popf
  801297:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  801298:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  80129b:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  80129f:	c3                   	ret    

008012a0 <__udivdi3>:
  8012a0:	f3 0f 1e fb          	endbr32 
  8012a4:	55                   	push   %ebp
  8012a5:	57                   	push   %edi
  8012a6:	56                   	push   %esi
  8012a7:	53                   	push   %ebx
  8012a8:	83 ec 1c             	sub    $0x1c,%esp
  8012ab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8012af:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8012b3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8012b7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8012bb:	85 d2                	test   %edx,%edx
  8012bd:	75 19                	jne    8012d8 <__udivdi3+0x38>
  8012bf:	39 f3                	cmp    %esi,%ebx
  8012c1:	76 4d                	jbe    801310 <__udivdi3+0x70>
  8012c3:	31 ff                	xor    %edi,%edi
  8012c5:	89 e8                	mov    %ebp,%eax
  8012c7:	89 f2                	mov    %esi,%edx
  8012c9:	f7 f3                	div    %ebx
  8012cb:	89 fa                	mov    %edi,%edx
  8012cd:	83 c4 1c             	add    $0x1c,%esp
  8012d0:	5b                   	pop    %ebx
  8012d1:	5e                   	pop    %esi
  8012d2:	5f                   	pop    %edi
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    
  8012d5:	8d 76 00             	lea    0x0(%esi),%esi
  8012d8:	39 f2                	cmp    %esi,%edx
  8012da:	76 14                	jbe    8012f0 <__udivdi3+0x50>
  8012dc:	31 ff                	xor    %edi,%edi
  8012de:	31 c0                	xor    %eax,%eax
  8012e0:	89 fa                	mov    %edi,%edx
  8012e2:	83 c4 1c             	add    $0x1c,%esp
  8012e5:	5b                   	pop    %ebx
  8012e6:	5e                   	pop    %esi
  8012e7:	5f                   	pop    %edi
  8012e8:	5d                   	pop    %ebp
  8012e9:	c3                   	ret    
  8012ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012f0:	0f bd fa             	bsr    %edx,%edi
  8012f3:	83 f7 1f             	xor    $0x1f,%edi
  8012f6:	75 48                	jne    801340 <__udivdi3+0xa0>
  8012f8:	39 f2                	cmp    %esi,%edx
  8012fa:	72 06                	jb     801302 <__udivdi3+0x62>
  8012fc:	31 c0                	xor    %eax,%eax
  8012fe:	39 eb                	cmp    %ebp,%ebx
  801300:	77 de                	ja     8012e0 <__udivdi3+0x40>
  801302:	b8 01 00 00 00       	mov    $0x1,%eax
  801307:	eb d7                	jmp    8012e0 <__udivdi3+0x40>
  801309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801310:	89 d9                	mov    %ebx,%ecx
  801312:	85 db                	test   %ebx,%ebx
  801314:	75 0b                	jne    801321 <__udivdi3+0x81>
  801316:	b8 01 00 00 00       	mov    $0x1,%eax
  80131b:	31 d2                	xor    %edx,%edx
  80131d:	f7 f3                	div    %ebx
  80131f:	89 c1                	mov    %eax,%ecx
  801321:	31 d2                	xor    %edx,%edx
  801323:	89 f0                	mov    %esi,%eax
  801325:	f7 f1                	div    %ecx
  801327:	89 c6                	mov    %eax,%esi
  801329:	89 e8                	mov    %ebp,%eax
  80132b:	89 f7                	mov    %esi,%edi
  80132d:	f7 f1                	div    %ecx
  80132f:	89 fa                	mov    %edi,%edx
  801331:	83 c4 1c             	add    $0x1c,%esp
  801334:	5b                   	pop    %ebx
  801335:	5e                   	pop    %esi
  801336:	5f                   	pop    %edi
  801337:	5d                   	pop    %ebp
  801338:	c3                   	ret    
  801339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801340:	89 f9                	mov    %edi,%ecx
  801342:	b8 20 00 00 00       	mov    $0x20,%eax
  801347:	29 f8                	sub    %edi,%eax
  801349:	d3 e2                	shl    %cl,%edx
  80134b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80134f:	89 c1                	mov    %eax,%ecx
  801351:	89 da                	mov    %ebx,%edx
  801353:	d3 ea                	shr    %cl,%edx
  801355:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801359:	09 d1                	or     %edx,%ecx
  80135b:	89 f2                	mov    %esi,%edx
  80135d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801361:	89 f9                	mov    %edi,%ecx
  801363:	d3 e3                	shl    %cl,%ebx
  801365:	89 c1                	mov    %eax,%ecx
  801367:	d3 ea                	shr    %cl,%edx
  801369:	89 f9                	mov    %edi,%ecx
  80136b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80136f:	89 eb                	mov    %ebp,%ebx
  801371:	d3 e6                	shl    %cl,%esi
  801373:	89 c1                	mov    %eax,%ecx
  801375:	d3 eb                	shr    %cl,%ebx
  801377:	09 de                	or     %ebx,%esi
  801379:	89 f0                	mov    %esi,%eax
  80137b:	f7 74 24 08          	divl   0x8(%esp)
  80137f:	89 d6                	mov    %edx,%esi
  801381:	89 c3                	mov    %eax,%ebx
  801383:	f7 64 24 0c          	mull   0xc(%esp)
  801387:	39 d6                	cmp    %edx,%esi
  801389:	72 15                	jb     8013a0 <__udivdi3+0x100>
  80138b:	89 f9                	mov    %edi,%ecx
  80138d:	d3 e5                	shl    %cl,%ebp
  80138f:	39 c5                	cmp    %eax,%ebp
  801391:	73 04                	jae    801397 <__udivdi3+0xf7>
  801393:	39 d6                	cmp    %edx,%esi
  801395:	74 09                	je     8013a0 <__udivdi3+0x100>
  801397:	89 d8                	mov    %ebx,%eax
  801399:	31 ff                	xor    %edi,%edi
  80139b:	e9 40 ff ff ff       	jmp    8012e0 <__udivdi3+0x40>
  8013a0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8013a3:	31 ff                	xor    %edi,%edi
  8013a5:	e9 36 ff ff ff       	jmp    8012e0 <__udivdi3+0x40>
  8013aa:	66 90                	xchg   %ax,%ax
  8013ac:	66 90                	xchg   %ax,%ax
  8013ae:	66 90                	xchg   %ax,%ax

008013b0 <__umoddi3>:
  8013b0:	f3 0f 1e fb          	endbr32 
  8013b4:	55                   	push   %ebp
  8013b5:	57                   	push   %edi
  8013b6:	56                   	push   %esi
  8013b7:	53                   	push   %ebx
  8013b8:	83 ec 1c             	sub    $0x1c,%esp
  8013bb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8013bf:	8b 74 24 30          	mov    0x30(%esp),%esi
  8013c3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8013c7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	75 19                	jne    8013e8 <__umoddi3+0x38>
  8013cf:	39 df                	cmp    %ebx,%edi
  8013d1:	76 5d                	jbe    801430 <__umoddi3+0x80>
  8013d3:	89 f0                	mov    %esi,%eax
  8013d5:	89 da                	mov    %ebx,%edx
  8013d7:	f7 f7                	div    %edi
  8013d9:	89 d0                	mov    %edx,%eax
  8013db:	31 d2                	xor    %edx,%edx
  8013dd:	83 c4 1c             	add    $0x1c,%esp
  8013e0:	5b                   	pop    %ebx
  8013e1:	5e                   	pop    %esi
  8013e2:	5f                   	pop    %edi
  8013e3:	5d                   	pop    %ebp
  8013e4:	c3                   	ret    
  8013e5:	8d 76 00             	lea    0x0(%esi),%esi
  8013e8:	89 f2                	mov    %esi,%edx
  8013ea:	39 d8                	cmp    %ebx,%eax
  8013ec:	76 12                	jbe    801400 <__umoddi3+0x50>
  8013ee:	89 f0                	mov    %esi,%eax
  8013f0:	89 da                	mov    %ebx,%edx
  8013f2:	83 c4 1c             	add    $0x1c,%esp
  8013f5:	5b                   	pop    %ebx
  8013f6:	5e                   	pop    %esi
  8013f7:	5f                   	pop    %edi
  8013f8:	5d                   	pop    %ebp
  8013f9:	c3                   	ret    
  8013fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801400:	0f bd e8             	bsr    %eax,%ebp
  801403:	83 f5 1f             	xor    $0x1f,%ebp
  801406:	75 50                	jne    801458 <__umoddi3+0xa8>
  801408:	39 d8                	cmp    %ebx,%eax
  80140a:	0f 82 e0 00 00 00    	jb     8014f0 <__umoddi3+0x140>
  801410:	89 d9                	mov    %ebx,%ecx
  801412:	39 f7                	cmp    %esi,%edi
  801414:	0f 86 d6 00 00 00    	jbe    8014f0 <__umoddi3+0x140>
  80141a:	89 d0                	mov    %edx,%eax
  80141c:	89 ca                	mov    %ecx,%edx
  80141e:	83 c4 1c             	add    $0x1c,%esp
  801421:	5b                   	pop    %ebx
  801422:	5e                   	pop    %esi
  801423:	5f                   	pop    %edi
  801424:	5d                   	pop    %ebp
  801425:	c3                   	ret    
  801426:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80142d:	8d 76 00             	lea    0x0(%esi),%esi
  801430:	89 fd                	mov    %edi,%ebp
  801432:	85 ff                	test   %edi,%edi
  801434:	75 0b                	jne    801441 <__umoddi3+0x91>
  801436:	b8 01 00 00 00       	mov    $0x1,%eax
  80143b:	31 d2                	xor    %edx,%edx
  80143d:	f7 f7                	div    %edi
  80143f:	89 c5                	mov    %eax,%ebp
  801441:	89 d8                	mov    %ebx,%eax
  801443:	31 d2                	xor    %edx,%edx
  801445:	f7 f5                	div    %ebp
  801447:	89 f0                	mov    %esi,%eax
  801449:	f7 f5                	div    %ebp
  80144b:	89 d0                	mov    %edx,%eax
  80144d:	31 d2                	xor    %edx,%edx
  80144f:	eb 8c                	jmp    8013dd <__umoddi3+0x2d>
  801451:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801458:	89 e9                	mov    %ebp,%ecx
  80145a:	ba 20 00 00 00       	mov    $0x20,%edx
  80145f:	29 ea                	sub    %ebp,%edx
  801461:	d3 e0                	shl    %cl,%eax
  801463:	89 44 24 08          	mov    %eax,0x8(%esp)
  801467:	89 d1                	mov    %edx,%ecx
  801469:	89 f8                	mov    %edi,%eax
  80146b:	d3 e8                	shr    %cl,%eax
  80146d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801471:	89 54 24 04          	mov    %edx,0x4(%esp)
  801475:	8b 54 24 04          	mov    0x4(%esp),%edx
  801479:	09 c1                	or     %eax,%ecx
  80147b:	89 d8                	mov    %ebx,%eax
  80147d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801481:	89 e9                	mov    %ebp,%ecx
  801483:	d3 e7                	shl    %cl,%edi
  801485:	89 d1                	mov    %edx,%ecx
  801487:	d3 e8                	shr    %cl,%eax
  801489:	89 e9                	mov    %ebp,%ecx
  80148b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80148f:	d3 e3                	shl    %cl,%ebx
  801491:	89 c7                	mov    %eax,%edi
  801493:	89 d1                	mov    %edx,%ecx
  801495:	89 f0                	mov    %esi,%eax
  801497:	d3 e8                	shr    %cl,%eax
  801499:	89 e9                	mov    %ebp,%ecx
  80149b:	89 fa                	mov    %edi,%edx
  80149d:	d3 e6                	shl    %cl,%esi
  80149f:	09 d8                	or     %ebx,%eax
  8014a1:	f7 74 24 08          	divl   0x8(%esp)
  8014a5:	89 d1                	mov    %edx,%ecx
  8014a7:	89 f3                	mov    %esi,%ebx
  8014a9:	f7 64 24 0c          	mull   0xc(%esp)
  8014ad:	89 c6                	mov    %eax,%esi
  8014af:	89 d7                	mov    %edx,%edi
  8014b1:	39 d1                	cmp    %edx,%ecx
  8014b3:	72 06                	jb     8014bb <__umoddi3+0x10b>
  8014b5:	75 10                	jne    8014c7 <__umoddi3+0x117>
  8014b7:	39 c3                	cmp    %eax,%ebx
  8014b9:	73 0c                	jae    8014c7 <__umoddi3+0x117>
  8014bb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8014bf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8014c3:	89 d7                	mov    %edx,%edi
  8014c5:	89 c6                	mov    %eax,%esi
  8014c7:	89 ca                	mov    %ecx,%edx
  8014c9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8014ce:	29 f3                	sub    %esi,%ebx
  8014d0:	19 fa                	sbb    %edi,%edx
  8014d2:	89 d0                	mov    %edx,%eax
  8014d4:	d3 e0                	shl    %cl,%eax
  8014d6:	89 e9                	mov    %ebp,%ecx
  8014d8:	d3 eb                	shr    %cl,%ebx
  8014da:	d3 ea                	shr    %cl,%edx
  8014dc:	09 d8                	or     %ebx,%eax
  8014de:	83 c4 1c             	add    $0x1c,%esp
  8014e1:	5b                   	pop    %ebx
  8014e2:	5e                   	pop    %esi
  8014e3:	5f                   	pop    %edi
  8014e4:	5d                   	pop    %ebp
  8014e5:	c3                   	ret    
  8014e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014ed:	8d 76 00             	lea    0x0(%esi),%esi
  8014f0:	29 fe                	sub    %edi,%esi
  8014f2:	19 c3                	sbb    %eax,%ebx
  8014f4:	89 f2                	mov    %esi,%edx
  8014f6:	89 d9                	mov    %ebx,%ecx
  8014f8:	e9 1d ff ff ff       	jmp    80141a <__umoddi3+0x6a>
