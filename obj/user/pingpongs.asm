
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
  800040:	e8 f8 0f 00 00       	call   80103d <sfork>
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
  800057:	e8 ff 0f 00 00       	call   80105b <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80005c:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  800062:	8b 7b 48             	mov    0x48(%ebx),%edi
  800065:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800068:	a1 04 20 80 00       	mov    0x802004,%eax
  80006d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800070:	e8 94 0b 00 00       	call   800c09 <sys_getenvid>
  800075:	83 c4 08             	add    $0x8,%esp
  800078:	57                   	push   %edi
  800079:	53                   	push   %ebx
  80007a:	56                   	push   %esi
  80007b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80007e:	50                   	push   %eax
  80007f:	68 f0 14 80 00       	push   $0x8014f0
  800084:	e8 7b 01 00 00       	call   800204 <cprintf>
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
  8000a7:	e8 06 10 00 00       	call   8010b2 <ipc_send>
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
  8000c6:	e8 3e 0b 00 00       	call   800c09 <sys_getenvid>
  8000cb:	83 ec 04             	sub    $0x4,%esp
  8000ce:	53                   	push   %ebx
  8000cf:	50                   	push   %eax
  8000d0:	68 c0 14 80 00       	push   $0x8014c0
  8000d5:	e8 2a 01 00 00       	call   800204 <cprintf>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  8000da:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8000dd:	e8 27 0b 00 00       	call   800c09 <sys_getenvid>
  8000e2:	83 c4 0c             	add    $0xc,%esp
  8000e5:	53                   	push   %ebx
  8000e6:	50                   	push   %eax
  8000e7:	68 da 14 80 00       	push   $0x8014da
  8000ec:	e8 13 01 00 00       	call   800204 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000f1:	6a 00                	push   $0x0
  8000f3:	6a 00                	push   $0x0
  8000f5:	6a 00                	push   $0x0
  8000f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000fa:	e8 b3 0f 00 00       	call   8010b2 <ipc_send>
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
    envid_t envid = sys_getenvid();
  800116:	e8 ee 0a 00 00       	call   800c09 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  80011b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800120:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800123:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800128:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012d:	85 db                	test   %ebx,%ebx
  80012f:	7e 07                	jle    800138 <libmain+0x31>
		binaryname = argv[0];
  800131:	8b 06                	mov    (%esi),%eax
  800133:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800138:	83 ec 08             	sub    $0x8,%esp
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
  80013d:	e8 f1 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800142:	e8 0a 00 00 00       	call   800151 <exit>
}
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014d:	5b                   	pop    %ebx
  80014e:	5e                   	pop    %esi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800151:	f3 0f 1e fb          	endbr32 
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80015b:	6a 00                	push   $0x0
  80015d:	e8 62 0a 00 00       	call   800bc4 <sys_env_destroy>
}
  800162:	83 c4 10             	add    $0x10,%esp
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800167:	f3 0f 1e fb          	endbr32 
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	53                   	push   %ebx
  80016f:	83 ec 04             	sub    $0x4,%esp
  800172:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800175:	8b 13                	mov    (%ebx),%edx
  800177:	8d 42 01             	lea    0x1(%edx),%eax
  80017a:	89 03                	mov    %eax,(%ebx)
  80017c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800183:	3d ff 00 00 00       	cmp    $0xff,%eax
  800188:	74 09                	je     800193 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80018a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80018e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800191:	c9                   	leave  
  800192:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800193:	83 ec 08             	sub    $0x8,%esp
  800196:	68 ff 00 00 00       	push   $0xff
  80019b:	8d 43 08             	lea    0x8(%ebx),%eax
  80019e:	50                   	push   %eax
  80019f:	e8 db 09 00 00       	call   800b7f <sys_cputs>
		b->idx = 0;
  8001a4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001aa:	83 c4 10             	add    $0x10,%esp
  8001ad:	eb db                	jmp    80018a <putch+0x23>

008001af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001af:	f3 0f 1e fb          	endbr32 
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c3:	00 00 00 
	b.cnt = 0;
  8001c6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d0:	ff 75 0c             	pushl  0xc(%ebp)
  8001d3:	ff 75 08             	pushl  0x8(%ebp)
  8001d6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001dc:	50                   	push   %eax
  8001dd:	68 67 01 80 00       	push   $0x800167
  8001e2:	e8 20 01 00 00       	call   800307 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e7:	83 c4 08             	add    $0x8,%esp
  8001ea:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f6:	50                   	push   %eax
  8001f7:	e8 83 09 00 00       	call   800b7f <sys_cputs>

	return b.cnt;
}
  8001fc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800204:	f3 0f 1e fb          	endbr32 
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800211:	50                   	push   %eax
  800212:	ff 75 08             	pushl  0x8(%ebp)
  800215:	e8 95 ff ff ff       	call   8001af <vcprintf>
	va_end(ap);

	return cnt;
}
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 1c             	sub    $0x1c,%esp
  800225:	89 c7                	mov    %eax,%edi
  800227:	89 d6                	mov    %edx,%esi
  800229:	8b 45 08             	mov    0x8(%ebp),%eax
  80022c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022f:	89 d1                	mov    %edx,%ecx
  800231:	89 c2                	mov    %eax,%edx
  800233:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800236:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800239:	8b 45 10             	mov    0x10(%ebp),%eax
  80023c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800242:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800249:	39 c2                	cmp    %eax,%edx
  80024b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80024e:	72 3e                	jb     80028e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	ff 75 18             	pushl  0x18(%ebp)
  800256:	83 eb 01             	sub    $0x1,%ebx
  800259:	53                   	push   %ebx
  80025a:	50                   	push   %eax
  80025b:	83 ec 08             	sub    $0x8,%esp
  80025e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800261:	ff 75 e0             	pushl  -0x20(%ebp)
  800264:	ff 75 dc             	pushl  -0x24(%ebp)
  800267:	ff 75 d8             	pushl  -0x28(%ebp)
  80026a:	e8 e1 0f 00 00       	call   801250 <__udivdi3>
  80026f:	83 c4 18             	add    $0x18,%esp
  800272:	52                   	push   %edx
  800273:	50                   	push   %eax
  800274:	89 f2                	mov    %esi,%edx
  800276:	89 f8                	mov    %edi,%eax
  800278:	e8 9f ff ff ff       	call   80021c <printnum>
  80027d:	83 c4 20             	add    $0x20,%esp
  800280:	eb 13                	jmp    800295 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800282:	83 ec 08             	sub    $0x8,%esp
  800285:	56                   	push   %esi
  800286:	ff 75 18             	pushl  0x18(%ebp)
  800289:	ff d7                	call   *%edi
  80028b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80028e:	83 eb 01             	sub    $0x1,%ebx
  800291:	85 db                	test   %ebx,%ebx
  800293:	7f ed                	jg     800282 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800295:	83 ec 08             	sub    $0x8,%esp
  800298:	56                   	push   %esi
  800299:	83 ec 04             	sub    $0x4,%esp
  80029c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029f:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a8:	e8 b3 10 00 00       	call   801360 <__umoddi3>
  8002ad:	83 c4 14             	add    $0x14,%esp
  8002b0:	0f be 80 20 15 80 00 	movsbl 0x801520(%eax),%eax
  8002b7:	50                   	push   %eax
  8002b8:	ff d7                	call   *%edi
}
  8002ba:	83 c4 10             	add    $0x10,%esp
  8002bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5f                   	pop    %edi
  8002c3:	5d                   	pop    %ebp
  8002c4:	c3                   	ret    

008002c5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c5:	f3 0f 1e fb          	endbr32 
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d3:	8b 10                	mov    (%eax),%edx
  8002d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d8:	73 0a                	jae    8002e4 <sprintputch+0x1f>
		*b->buf++ = ch;
  8002da:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	88 02                	mov    %al,(%edx)
}
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <printfmt>:
{
  8002e6:	f3 0f 1e fb          	endbr32 
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f3:	50                   	push   %eax
  8002f4:	ff 75 10             	pushl  0x10(%ebp)
  8002f7:	ff 75 0c             	pushl  0xc(%ebp)
  8002fa:	ff 75 08             	pushl  0x8(%ebp)
  8002fd:	e8 05 00 00 00       	call   800307 <vprintfmt>
}
  800302:	83 c4 10             	add    $0x10,%esp
  800305:	c9                   	leave  
  800306:	c3                   	ret    

00800307 <vprintfmt>:
{
  800307:	f3 0f 1e fb          	endbr32 
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	57                   	push   %edi
  80030f:	56                   	push   %esi
  800310:	53                   	push   %ebx
  800311:	83 ec 3c             	sub    $0x3c,%esp
  800314:	8b 75 08             	mov    0x8(%ebp),%esi
  800317:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80031d:	e9 4a 03 00 00       	jmp    80066c <vprintfmt+0x365>
		padc = ' ';
  800322:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800326:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80032d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800334:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80033b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8d 47 01             	lea    0x1(%edi),%eax
  800343:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800346:	0f b6 17             	movzbl (%edi),%edx
  800349:	8d 42 dd             	lea    -0x23(%edx),%eax
  80034c:	3c 55                	cmp    $0x55,%al
  80034e:	0f 87 de 03 00 00    	ja     800732 <vprintfmt+0x42b>
  800354:	0f b6 c0             	movzbl %al,%eax
  800357:	3e ff 24 85 e0 15 80 	notrack jmp *0x8015e0(,%eax,4)
  80035e:	00 
  80035f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800362:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800366:	eb d8                	jmp    800340 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036b:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80036f:	eb cf                	jmp    800340 <vprintfmt+0x39>
  800371:	0f b6 d2             	movzbl %dl,%edx
  800374:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800377:	b8 00 00 00 00       	mov    $0x0,%eax
  80037c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80037f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800382:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800386:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800389:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80038c:	83 f9 09             	cmp    $0x9,%ecx
  80038f:	77 55                	ja     8003e6 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800391:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800394:	eb e9                	jmp    80037f <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800396:	8b 45 14             	mov    0x14(%ebp),%eax
  800399:	8b 00                	mov    (%eax),%eax
  80039b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039e:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a1:	8d 40 04             	lea    0x4(%eax),%eax
  8003a4:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003aa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ae:	79 90                	jns    800340 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003bd:	eb 81                	jmp    800340 <vprintfmt+0x39>
  8003bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c2:	85 c0                	test   %eax,%eax
  8003c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c9:	0f 49 d0             	cmovns %eax,%edx
  8003cc:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003d2:	e9 69 ff ff ff       	jmp    800340 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003da:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003e1:	e9 5a ff ff ff       	jmp    800340 <vprintfmt+0x39>
  8003e6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ec:	eb bc                	jmp    8003aa <vprintfmt+0xa3>
			lflag++;
  8003ee:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f4:	e9 47 ff ff ff       	jmp    800340 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fc:	8d 78 04             	lea    0x4(%eax),%edi
  8003ff:	83 ec 08             	sub    $0x8,%esp
  800402:	53                   	push   %ebx
  800403:	ff 30                	pushl  (%eax)
  800405:	ff d6                	call   *%esi
			break;
  800407:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80040a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80040d:	e9 57 02 00 00       	jmp    800669 <vprintfmt+0x362>
			err = va_arg(ap, int);
  800412:	8b 45 14             	mov    0x14(%ebp),%eax
  800415:	8d 78 04             	lea    0x4(%eax),%edi
  800418:	8b 00                	mov    (%eax),%eax
  80041a:	99                   	cltd   
  80041b:	31 d0                	xor    %edx,%eax
  80041d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041f:	83 f8 08             	cmp    $0x8,%eax
  800422:	7f 23                	jg     800447 <vprintfmt+0x140>
  800424:	8b 14 85 40 17 80 00 	mov    0x801740(,%eax,4),%edx
  80042b:	85 d2                	test   %edx,%edx
  80042d:	74 18                	je     800447 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80042f:	52                   	push   %edx
  800430:	68 41 15 80 00       	push   $0x801541
  800435:	53                   	push   %ebx
  800436:	56                   	push   %esi
  800437:	e8 aa fe ff ff       	call   8002e6 <printfmt>
  80043c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800442:	e9 22 02 00 00       	jmp    800669 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800447:	50                   	push   %eax
  800448:	68 38 15 80 00       	push   $0x801538
  80044d:	53                   	push   %ebx
  80044e:	56                   	push   %esi
  80044f:	e8 92 fe ff ff       	call   8002e6 <printfmt>
  800454:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800457:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80045a:	e9 0a 02 00 00       	jmp    800669 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  80045f:	8b 45 14             	mov    0x14(%ebp),%eax
  800462:	83 c0 04             	add    $0x4,%eax
  800465:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80046d:	85 d2                	test   %edx,%edx
  80046f:	b8 31 15 80 00       	mov    $0x801531,%eax
  800474:	0f 45 c2             	cmovne %edx,%eax
  800477:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80047a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047e:	7e 06                	jle    800486 <vprintfmt+0x17f>
  800480:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800484:	75 0d                	jne    800493 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800489:	89 c7                	mov    %eax,%edi
  80048b:	03 45 e0             	add    -0x20(%ebp),%eax
  80048e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800491:	eb 55                	jmp    8004e8 <vprintfmt+0x1e1>
  800493:	83 ec 08             	sub    $0x8,%esp
  800496:	ff 75 d8             	pushl  -0x28(%ebp)
  800499:	ff 75 cc             	pushl  -0x34(%ebp)
  80049c:	e8 45 03 00 00       	call   8007e6 <strnlen>
  8004a1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004a4:	29 c2                	sub    %eax,%edx
  8004a6:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004a9:	83 c4 10             	add    $0x10,%esp
  8004ac:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004ae:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b5:	85 ff                	test   %edi,%edi
  8004b7:	7e 11                	jle    8004ca <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	53                   	push   %ebx
  8004bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c2:	83 ef 01             	sub    $0x1,%edi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	eb eb                	jmp    8004b5 <vprintfmt+0x1ae>
  8004ca:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004cd:	85 d2                	test   %edx,%edx
  8004cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d4:	0f 49 c2             	cmovns %edx,%eax
  8004d7:	29 c2                	sub    %eax,%edx
  8004d9:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004dc:	eb a8                	jmp    800486 <vprintfmt+0x17f>
					putch(ch, putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	53                   	push   %ebx
  8004e2:	52                   	push   %edx
  8004e3:	ff d6                	call   *%esi
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004eb:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ed:	83 c7 01             	add    $0x1,%edi
  8004f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f4:	0f be d0             	movsbl %al,%edx
  8004f7:	85 d2                	test   %edx,%edx
  8004f9:	74 4b                	je     800546 <vprintfmt+0x23f>
  8004fb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ff:	78 06                	js     800507 <vprintfmt+0x200>
  800501:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800505:	78 1e                	js     800525 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800507:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80050b:	74 d1                	je     8004de <vprintfmt+0x1d7>
  80050d:	0f be c0             	movsbl %al,%eax
  800510:	83 e8 20             	sub    $0x20,%eax
  800513:	83 f8 5e             	cmp    $0x5e,%eax
  800516:	76 c6                	jbe    8004de <vprintfmt+0x1d7>
					putch('?', putdat);
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	53                   	push   %ebx
  80051c:	6a 3f                	push   $0x3f
  80051e:	ff d6                	call   *%esi
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	eb c3                	jmp    8004e8 <vprintfmt+0x1e1>
  800525:	89 cf                	mov    %ecx,%edi
  800527:	eb 0e                	jmp    800537 <vprintfmt+0x230>
				putch(' ', putdat);
  800529:	83 ec 08             	sub    $0x8,%esp
  80052c:	53                   	push   %ebx
  80052d:	6a 20                	push   $0x20
  80052f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800531:	83 ef 01             	sub    $0x1,%edi
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	85 ff                	test   %edi,%edi
  800539:	7f ee                	jg     800529 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80053b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80053e:	89 45 14             	mov    %eax,0x14(%ebp)
  800541:	e9 23 01 00 00       	jmp    800669 <vprintfmt+0x362>
  800546:	89 cf                	mov    %ecx,%edi
  800548:	eb ed                	jmp    800537 <vprintfmt+0x230>
	if (lflag >= 2)
  80054a:	83 f9 01             	cmp    $0x1,%ecx
  80054d:	7f 1b                	jg     80056a <vprintfmt+0x263>
	else if (lflag)
  80054f:	85 c9                	test   %ecx,%ecx
  800551:	74 63                	je     8005b6 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800553:	8b 45 14             	mov    0x14(%ebp),%eax
  800556:	8b 00                	mov    (%eax),%eax
  800558:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055b:	99                   	cltd   
  80055c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8d 40 04             	lea    0x4(%eax),%eax
  800565:	89 45 14             	mov    %eax,0x14(%ebp)
  800568:	eb 17                	jmp    800581 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80056a:	8b 45 14             	mov    0x14(%ebp),%eax
  80056d:	8b 50 04             	mov    0x4(%eax),%edx
  800570:	8b 00                	mov    (%eax),%eax
  800572:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800575:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8d 40 08             	lea    0x8(%eax),%eax
  80057e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800581:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800584:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800587:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80058c:	85 c9                	test   %ecx,%ecx
  80058e:	0f 89 bb 00 00 00    	jns    80064f <vprintfmt+0x348>
				putch('-', putdat);
  800594:	83 ec 08             	sub    $0x8,%esp
  800597:	53                   	push   %ebx
  800598:	6a 2d                	push   $0x2d
  80059a:	ff d6                	call   *%esi
				num = -(long long) num;
  80059c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a2:	f7 da                	neg    %edx
  8005a4:	83 d1 00             	adc    $0x0,%ecx
  8005a7:	f7 d9                	neg    %ecx
  8005a9:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005ac:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b1:	e9 99 00 00 00       	jmp    80064f <vprintfmt+0x348>
		return va_arg(*ap, int);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8b 00                	mov    (%eax),%eax
  8005bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005be:	99                   	cltd   
  8005bf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 40 04             	lea    0x4(%eax),%eax
  8005c8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005cb:	eb b4                	jmp    800581 <vprintfmt+0x27a>
	if (lflag >= 2)
  8005cd:	83 f9 01             	cmp    $0x1,%ecx
  8005d0:	7f 1b                	jg     8005ed <vprintfmt+0x2e6>
	else if (lflag)
  8005d2:	85 c9                	test   %ecx,%ecx
  8005d4:	74 2c                	je     800602 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8b 10                	mov    (%eax),%edx
  8005db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e0:	8d 40 04             	lea    0x4(%eax),%eax
  8005e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e6:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005eb:	eb 62                	jmp    80064f <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8b 10                	mov    (%eax),%edx
  8005f2:	8b 48 04             	mov    0x4(%eax),%ecx
  8005f5:	8d 40 08             	lea    0x8(%eax),%eax
  8005f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fb:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800600:	eb 4d                	jmp    80064f <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8b 10                	mov    (%eax),%edx
  800607:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060c:	8d 40 04             	lea    0x4(%eax),%eax
  80060f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800612:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800617:	eb 36                	jmp    80064f <vprintfmt+0x348>
	if (lflag >= 2)
  800619:	83 f9 01             	cmp    $0x1,%ecx
  80061c:	7f 17                	jg     800635 <vprintfmt+0x32e>
	else if (lflag)
  80061e:	85 c9                	test   %ecx,%ecx
  800620:	74 6e                	je     800690 <vprintfmt+0x389>
		return va_arg(*ap, long);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8b 10                	mov    (%eax),%edx
  800627:	89 d0                	mov    %edx,%eax
  800629:	99                   	cltd   
  80062a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80062d:	8d 49 04             	lea    0x4(%ecx),%ecx
  800630:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800633:	eb 11                	jmp    800646 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8b 50 04             	mov    0x4(%eax),%edx
  80063b:	8b 00                	mov    (%eax),%eax
  80063d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800640:	8d 49 08             	lea    0x8(%ecx),%ecx
  800643:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800646:	89 d1                	mov    %edx,%ecx
  800648:	89 c2                	mov    %eax,%edx
            base = 8;
  80064a:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80064f:	83 ec 0c             	sub    $0xc,%esp
  800652:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800656:	57                   	push   %edi
  800657:	ff 75 e0             	pushl  -0x20(%ebp)
  80065a:	50                   	push   %eax
  80065b:	51                   	push   %ecx
  80065c:	52                   	push   %edx
  80065d:	89 da                	mov    %ebx,%edx
  80065f:	89 f0                	mov    %esi,%eax
  800661:	e8 b6 fb ff ff       	call   80021c <printnum>
			break;
  800666:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800669:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80066c:	83 c7 01             	add    $0x1,%edi
  80066f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800673:	83 f8 25             	cmp    $0x25,%eax
  800676:	0f 84 a6 fc ff ff    	je     800322 <vprintfmt+0x1b>
			if (ch == '\0')
  80067c:	85 c0                	test   %eax,%eax
  80067e:	0f 84 ce 00 00 00    	je     800752 <vprintfmt+0x44b>
			putch(ch, putdat);
  800684:	83 ec 08             	sub    $0x8,%esp
  800687:	53                   	push   %ebx
  800688:	50                   	push   %eax
  800689:	ff d6                	call   *%esi
  80068b:	83 c4 10             	add    $0x10,%esp
  80068e:	eb dc                	jmp    80066c <vprintfmt+0x365>
		return va_arg(*ap, int);
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8b 10                	mov    (%eax),%edx
  800695:	89 d0                	mov    %edx,%eax
  800697:	99                   	cltd   
  800698:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80069b:	8d 49 04             	lea    0x4(%ecx),%ecx
  80069e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006a1:	eb a3                	jmp    800646 <vprintfmt+0x33f>
			putch('0', putdat);
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	6a 30                	push   $0x30
  8006a9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ab:	83 c4 08             	add    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	6a 78                	push   $0x78
  8006b1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 10                	mov    (%eax),%edx
  8006b8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006bd:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006c0:	8d 40 04             	lea    0x4(%eax),%eax
  8006c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006cb:	eb 82                	jmp    80064f <vprintfmt+0x348>
	if (lflag >= 2)
  8006cd:	83 f9 01             	cmp    $0x1,%ecx
  8006d0:	7f 1e                	jg     8006f0 <vprintfmt+0x3e9>
	else if (lflag)
  8006d2:	85 c9                	test   %ecx,%ecx
  8006d4:	74 32                	je     800708 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8b 10                	mov    (%eax),%edx
  8006db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e0:	8d 40 04             	lea    0x4(%eax),%eax
  8006e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e6:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006eb:	e9 5f ff ff ff       	jmp    80064f <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8006f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f3:	8b 10                	mov    (%eax),%edx
  8006f5:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f8:	8d 40 08             	lea    0x8(%eax),%eax
  8006fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006fe:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800703:	e9 47 ff ff ff       	jmp    80064f <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800708:	8b 45 14             	mov    0x14(%ebp),%eax
  80070b:	8b 10                	mov    (%eax),%edx
  80070d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800712:	8d 40 04             	lea    0x4(%eax),%eax
  800715:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800718:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80071d:	e9 2d ff ff ff       	jmp    80064f <vprintfmt+0x348>
			putch(ch, putdat);
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	53                   	push   %ebx
  800726:	6a 25                	push   $0x25
  800728:	ff d6                	call   *%esi
			break;
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	e9 37 ff ff ff       	jmp    800669 <vprintfmt+0x362>
			putch('%', putdat);
  800732:	83 ec 08             	sub    $0x8,%esp
  800735:	53                   	push   %ebx
  800736:	6a 25                	push   $0x25
  800738:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073a:	83 c4 10             	add    $0x10,%esp
  80073d:	89 f8                	mov    %edi,%eax
  80073f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800743:	74 05                	je     80074a <vprintfmt+0x443>
  800745:	83 e8 01             	sub    $0x1,%eax
  800748:	eb f5                	jmp    80073f <vprintfmt+0x438>
  80074a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80074d:	e9 17 ff ff ff       	jmp    800669 <vprintfmt+0x362>
}
  800752:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800755:	5b                   	pop    %ebx
  800756:	5e                   	pop    %esi
  800757:	5f                   	pop    %edi
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075a:	f3 0f 1e fb          	endbr32 
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	83 ec 18             	sub    $0x18,%esp
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800771:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800774:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077b:	85 c0                	test   %eax,%eax
  80077d:	74 26                	je     8007a5 <vsnprintf+0x4b>
  80077f:	85 d2                	test   %edx,%edx
  800781:	7e 22                	jle    8007a5 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800783:	ff 75 14             	pushl  0x14(%ebp)
  800786:	ff 75 10             	pushl  0x10(%ebp)
  800789:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80078c:	50                   	push   %eax
  80078d:	68 c5 02 80 00       	push   $0x8002c5
  800792:	e8 70 fb ff ff       	call   800307 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800797:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a0:	83 c4 10             	add    $0x10,%esp
}
  8007a3:	c9                   	leave  
  8007a4:	c3                   	ret    
		return -E_INVAL;
  8007a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007aa:	eb f7                	jmp    8007a3 <vsnprintf+0x49>

008007ac <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ac:	f3 0f 1e fb          	endbr32 
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b9:	50                   	push   %eax
  8007ba:	ff 75 10             	pushl  0x10(%ebp)
  8007bd:	ff 75 0c             	pushl  0xc(%ebp)
  8007c0:	ff 75 08             	pushl  0x8(%ebp)
  8007c3:	e8 92 ff ff ff       	call   80075a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c8:	c9                   	leave  
  8007c9:	c3                   	ret    

008007ca <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ca:	f3 0f 1e fb          	endbr32 
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007dd:	74 05                	je     8007e4 <strlen+0x1a>
		n++;
  8007df:	83 c0 01             	add    $0x1,%eax
  8007e2:	eb f5                	jmp    8007d9 <strlen+0xf>
	return n;
}
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e6:	f3 0f 1e fb          	endbr32 
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f8:	39 d0                	cmp    %edx,%eax
  8007fa:	74 0d                	je     800809 <strnlen+0x23>
  8007fc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800800:	74 05                	je     800807 <strnlen+0x21>
		n++;
  800802:	83 c0 01             	add    $0x1,%eax
  800805:	eb f1                	jmp    8007f8 <strnlen+0x12>
  800807:	89 c2                	mov    %eax,%edx
	return n;
}
  800809:	89 d0                	mov    %edx,%eax
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080d:	f3 0f 1e fb          	endbr32 
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	53                   	push   %ebx
  800815:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800818:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081b:	b8 00 00 00 00       	mov    $0x0,%eax
  800820:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800824:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800827:	83 c0 01             	add    $0x1,%eax
  80082a:	84 d2                	test   %dl,%dl
  80082c:	75 f2                	jne    800820 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80082e:	89 c8                	mov    %ecx,%eax
  800830:	5b                   	pop    %ebx
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800833:	f3 0f 1e fb          	endbr32 
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	53                   	push   %ebx
  80083b:	83 ec 10             	sub    $0x10,%esp
  80083e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800841:	53                   	push   %ebx
  800842:	e8 83 ff ff ff       	call   8007ca <strlen>
  800847:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80084a:	ff 75 0c             	pushl  0xc(%ebp)
  80084d:	01 d8                	add    %ebx,%eax
  80084f:	50                   	push   %eax
  800850:	e8 b8 ff ff ff       	call   80080d <strcpy>
	return dst;
}
  800855:	89 d8                	mov    %ebx,%eax
  800857:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085a:	c9                   	leave  
  80085b:	c3                   	ret    

0080085c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80085c:	f3 0f 1e fb          	endbr32 
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	56                   	push   %esi
  800864:	53                   	push   %ebx
  800865:	8b 75 08             	mov    0x8(%ebp),%esi
  800868:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086b:	89 f3                	mov    %esi,%ebx
  80086d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800870:	89 f0                	mov    %esi,%eax
  800872:	39 d8                	cmp    %ebx,%eax
  800874:	74 11                	je     800887 <strncpy+0x2b>
		*dst++ = *src;
  800876:	83 c0 01             	add    $0x1,%eax
  800879:	0f b6 0a             	movzbl (%edx),%ecx
  80087c:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80087f:	80 f9 01             	cmp    $0x1,%cl
  800882:	83 da ff             	sbb    $0xffffffff,%edx
  800885:	eb eb                	jmp    800872 <strncpy+0x16>
	}
	return ret;
}
  800887:	89 f0                	mov    %esi,%eax
  800889:	5b                   	pop    %ebx
  80088a:	5e                   	pop    %esi
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80088d:	f3 0f 1e fb          	endbr32 
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	56                   	push   %esi
  800895:	53                   	push   %ebx
  800896:	8b 75 08             	mov    0x8(%ebp),%esi
  800899:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089c:	8b 55 10             	mov    0x10(%ebp),%edx
  80089f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a1:	85 d2                	test   %edx,%edx
  8008a3:	74 21                	je     8008c6 <strlcpy+0x39>
  8008a5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008a9:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008ab:	39 c2                	cmp    %eax,%edx
  8008ad:	74 14                	je     8008c3 <strlcpy+0x36>
  8008af:	0f b6 19             	movzbl (%ecx),%ebx
  8008b2:	84 db                	test   %bl,%bl
  8008b4:	74 0b                	je     8008c1 <strlcpy+0x34>
			*dst++ = *src++;
  8008b6:	83 c1 01             	add    $0x1,%ecx
  8008b9:	83 c2 01             	add    $0x1,%edx
  8008bc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008bf:	eb ea                	jmp    8008ab <strlcpy+0x1e>
  8008c1:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008c3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008c6:	29 f0                	sub    %esi,%eax
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	5e                   	pop    %esi
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008cc:	f3 0f 1e fb          	endbr32 
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d9:	0f b6 01             	movzbl (%ecx),%eax
  8008dc:	84 c0                	test   %al,%al
  8008de:	74 0c                	je     8008ec <strcmp+0x20>
  8008e0:	3a 02                	cmp    (%edx),%al
  8008e2:	75 08                	jne    8008ec <strcmp+0x20>
		p++, q++;
  8008e4:	83 c1 01             	add    $0x1,%ecx
  8008e7:	83 c2 01             	add    $0x1,%edx
  8008ea:	eb ed                	jmp    8008d9 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ec:	0f b6 c0             	movzbl %al,%eax
  8008ef:	0f b6 12             	movzbl (%edx),%edx
  8008f2:	29 d0                	sub    %edx,%eax
}
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f6:	f3 0f 1e fb          	endbr32 
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	53                   	push   %ebx
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	8b 55 0c             	mov    0xc(%ebp),%edx
  800904:	89 c3                	mov    %eax,%ebx
  800906:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800909:	eb 06                	jmp    800911 <strncmp+0x1b>
		n--, p++, q++;
  80090b:	83 c0 01             	add    $0x1,%eax
  80090e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800911:	39 d8                	cmp    %ebx,%eax
  800913:	74 16                	je     80092b <strncmp+0x35>
  800915:	0f b6 08             	movzbl (%eax),%ecx
  800918:	84 c9                	test   %cl,%cl
  80091a:	74 04                	je     800920 <strncmp+0x2a>
  80091c:	3a 0a                	cmp    (%edx),%cl
  80091e:	74 eb                	je     80090b <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800920:	0f b6 00             	movzbl (%eax),%eax
  800923:	0f b6 12             	movzbl (%edx),%edx
  800926:	29 d0                	sub    %edx,%eax
}
  800928:	5b                   	pop    %ebx
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    
		return 0;
  80092b:	b8 00 00 00 00       	mov    $0x0,%eax
  800930:	eb f6                	jmp    800928 <strncmp+0x32>

00800932 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800932:	f3 0f 1e fb          	endbr32 
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800940:	0f b6 10             	movzbl (%eax),%edx
  800943:	84 d2                	test   %dl,%dl
  800945:	74 09                	je     800950 <strchr+0x1e>
		if (*s == c)
  800947:	38 ca                	cmp    %cl,%dl
  800949:	74 0a                	je     800955 <strchr+0x23>
	for (; *s; s++)
  80094b:	83 c0 01             	add    $0x1,%eax
  80094e:	eb f0                	jmp    800940 <strchr+0xe>
			return (char *) s;
	return 0;
  800950:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800957:	f3 0f 1e fb          	endbr32 
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800965:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800968:	38 ca                	cmp    %cl,%dl
  80096a:	74 09                	je     800975 <strfind+0x1e>
  80096c:	84 d2                	test   %dl,%dl
  80096e:	74 05                	je     800975 <strfind+0x1e>
	for (; *s; s++)
  800970:	83 c0 01             	add    $0x1,%eax
  800973:	eb f0                	jmp    800965 <strfind+0xe>
			break;
	return (char *) s;
}
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800977:	f3 0f 1e fb          	endbr32 
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	57                   	push   %edi
  80097f:	56                   	push   %esi
  800980:	53                   	push   %ebx
  800981:	8b 7d 08             	mov    0x8(%ebp),%edi
  800984:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800987:	85 c9                	test   %ecx,%ecx
  800989:	74 31                	je     8009bc <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098b:	89 f8                	mov    %edi,%eax
  80098d:	09 c8                	or     %ecx,%eax
  80098f:	a8 03                	test   $0x3,%al
  800991:	75 23                	jne    8009b6 <memset+0x3f>
		c &= 0xFF;
  800993:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800997:	89 d3                	mov    %edx,%ebx
  800999:	c1 e3 08             	shl    $0x8,%ebx
  80099c:	89 d0                	mov    %edx,%eax
  80099e:	c1 e0 18             	shl    $0x18,%eax
  8009a1:	89 d6                	mov    %edx,%esi
  8009a3:	c1 e6 10             	shl    $0x10,%esi
  8009a6:	09 f0                	or     %esi,%eax
  8009a8:	09 c2                	or     %eax,%edx
  8009aa:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ac:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009af:	89 d0                	mov    %edx,%eax
  8009b1:	fc                   	cld    
  8009b2:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b4:	eb 06                	jmp    8009bc <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b9:	fc                   	cld    
  8009ba:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009bc:	89 f8                	mov    %edi,%eax
  8009be:	5b                   	pop    %ebx
  8009bf:	5e                   	pop    %esi
  8009c0:	5f                   	pop    %edi
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c3:	f3 0f 1e fb          	endbr32 
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	57                   	push   %edi
  8009cb:	56                   	push   %esi
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d5:	39 c6                	cmp    %eax,%esi
  8009d7:	73 32                	jae    800a0b <memmove+0x48>
  8009d9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009dc:	39 c2                	cmp    %eax,%edx
  8009de:	76 2b                	jbe    800a0b <memmove+0x48>
		s += n;
		d += n;
  8009e0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e3:	89 fe                	mov    %edi,%esi
  8009e5:	09 ce                	or     %ecx,%esi
  8009e7:	09 d6                	or     %edx,%esi
  8009e9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ef:	75 0e                	jne    8009ff <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009f1:	83 ef 04             	sub    $0x4,%edi
  8009f4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009fa:	fd                   	std    
  8009fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fd:	eb 09                	jmp    800a08 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ff:	83 ef 01             	sub    $0x1,%edi
  800a02:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a05:	fd                   	std    
  800a06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a08:	fc                   	cld    
  800a09:	eb 1a                	jmp    800a25 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0b:	89 c2                	mov    %eax,%edx
  800a0d:	09 ca                	or     %ecx,%edx
  800a0f:	09 f2                	or     %esi,%edx
  800a11:	f6 c2 03             	test   $0x3,%dl
  800a14:	75 0a                	jne    800a20 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a16:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a19:	89 c7                	mov    %eax,%edi
  800a1b:	fc                   	cld    
  800a1c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1e:	eb 05                	jmp    800a25 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a20:	89 c7                	mov    %eax,%edi
  800a22:	fc                   	cld    
  800a23:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a25:	5e                   	pop    %esi
  800a26:	5f                   	pop    %edi
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a29:	f3 0f 1e fb          	endbr32 
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a33:	ff 75 10             	pushl  0x10(%ebp)
  800a36:	ff 75 0c             	pushl  0xc(%ebp)
  800a39:	ff 75 08             	pushl  0x8(%ebp)
  800a3c:	e8 82 ff ff ff       	call   8009c3 <memmove>
}
  800a41:	c9                   	leave  
  800a42:	c3                   	ret    

00800a43 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a43:	f3 0f 1e fb          	endbr32 
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	56                   	push   %esi
  800a4b:	53                   	push   %ebx
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a52:	89 c6                	mov    %eax,%esi
  800a54:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a57:	39 f0                	cmp    %esi,%eax
  800a59:	74 1c                	je     800a77 <memcmp+0x34>
		if (*s1 != *s2)
  800a5b:	0f b6 08             	movzbl (%eax),%ecx
  800a5e:	0f b6 1a             	movzbl (%edx),%ebx
  800a61:	38 d9                	cmp    %bl,%cl
  800a63:	75 08                	jne    800a6d <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a65:	83 c0 01             	add    $0x1,%eax
  800a68:	83 c2 01             	add    $0x1,%edx
  800a6b:	eb ea                	jmp    800a57 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a6d:	0f b6 c1             	movzbl %cl,%eax
  800a70:	0f b6 db             	movzbl %bl,%ebx
  800a73:	29 d8                	sub    %ebx,%eax
  800a75:	eb 05                	jmp    800a7c <memcmp+0x39>
	}

	return 0;
  800a77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7c:	5b                   	pop    %ebx
  800a7d:	5e                   	pop    %esi
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a80:	f3 0f 1e fb          	endbr32 
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a8d:	89 c2                	mov    %eax,%edx
  800a8f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a92:	39 d0                	cmp    %edx,%eax
  800a94:	73 09                	jae    800a9f <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a96:	38 08                	cmp    %cl,(%eax)
  800a98:	74 05                	je     800a9f <memfind+0x1f>
	for (; s < ends; s++)
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	eb f3                	jmp    800a92 <memfind+0x12>
			break;
	return (void *) s;
}
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa1:	f3 0f 1e fb          	endbr32 
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	57                   	push   %edi
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
  800aab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab1:	eb 03                	jmp    800ab6 <strtol+0x15>
		s++;
  800ab3:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ab6:	0f b6 01             	movzbl (%ecx),%eax
  800ab9:	3c 20                	cmp    $0x20,%al
  800abb:	74 f6                	je     800ab3 <strtol+0x12>
  800abd:	3c 09                	cmp    $0x9,%al
  800abf:	74 f2                	je     800ab3 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ac1:	3c 2b                	cmp    $0x2b,%al
  800ac3:	74 2a                	je     800aef <strtol+0x4e>
	int neg = 0;
  800ac5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800aca:	3c 2d                	cmp    $0x2d,%al
  800acc:	74 2b                	je     800af9 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ace:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ad4:	75 0f                	jne    800ae5 <strtol+0x44>
  800ad6:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad9:	74 28                	je     800b03 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800adb:	85 db                	test   %ebx,%ebx
  800add:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ae2:	0f 44 d8             	cmove  %eax,%ebx
  800ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aea:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aed:	eb 46                	jmp    800b35 <strtol+0x94>
		s++;
  800aef:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800af2:	bf 00 00 00 00       	mov    $0x0,%edi
  800af7:	eb d5                	jmp    800ace <strtol+0x2d>
		s++, neg = 1;
  800af9:	83 c1 01             	add    $0x1,%ecx
  800afc:	bf 01 00 00 00       	mov    $0x1,%edi
  800b01:	eb cb                	jmp    800ace <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b03:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b07:	74 0e                	je     800b17 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b09:	85 db                	test   %ebx,%ebx
  800b0b:	75 d8                	jne    800ae5 <strtol+0x44>
		s++, base = 8;
  800b0d:	83 c1 01             	add    $0x1,%ecx
  800b10:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b15:	eb ce                	jmp    800ae5 <strtol+0x44>
		s += 2, base = 16;
  800b17:	83 c1 02             	add    $0x2,%ecx
  800b1a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b1f:	eb c4                	jmp    800ae5 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b21:	0f be d2             	movsbl %dl,%edx
  800b24:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b27:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b2a:	7d 3a                	jge    800b66 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b2c:	83 c1 01             	add    $0x1,%ecx
  800b2f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b33:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b35:	0f b6 11             	movzbl (%ecx),%edx
  800b38:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b3b:	89 f3                	mov    %esi,%ebx
  800b3d:	80 fb 09             	cmp    $0x9,%bl
  800b40:	76 df                	jbe    800b21 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b42:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b45:	89 f3                	mov    %esi,%ebx
  800b47:	80 fb 19             	cmp    $0x19,%bl
  800b4a:	77 08                	ja     800b54 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b4c:	0f be d2             	movsbl %dl,%edx
  800b4f:	83 ea 57             	sub    $0x57,%edx
  800b52:	eb d3                	jmp    800b27 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b54:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b57:	89 f3                	mov    %esi,%ebx
  800b59:	80 fb 19             	cmp    $0x19,%bl
  800b5c:	77 08                	ja     800b66 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b5e:	0f be d2             	movsbl %dl,%edx
  800b61:	83 ea 37             	sub    $0x37,%edx
  800b64:	eb c1                	jmp    800b27 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6a:	74 05                	je     800b71 <strtol+0xd0>
		*endptr = (char *) s;
  800b6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b71:	89 c2                	mov    %eax,%edx
  800b73:	f7 da                	neg    %edx
  800b75:	85 ff                	test   %edi,%edi
  800b77:	0f 45 c2             	cmovne %edx,%eax
}
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b7f:	f3 0f 1e fb          	endbr32 
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b89:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b94:	89 c3                	mov    %eax,%ebx
  800b96:	89 c7                	mov    %eax,%edi
  800b98:	89 c6                	mov    %eax,%esi
  800b9a:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba1:	f3 0f 1e fb          	endbr32 
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bab:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb0:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb5:	89 d1                	mov    %edx,%ecx
  800bb7:	89 d3                	mov    %edx,%ebx
  800bb9:	89 d7                	mov    %edx,%edi
  800bbb:	89 d6                	mov    %edx,%esi
  800bbd:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc4:	f3 0f 1e fb          	endbr32 
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	57                   	push   %edi
  800bcc:	56                   	push   %esi
  800bcd:	53                   	push   %ebx
  800bce:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd9:	b8 03 00 00 00       	mov    $0x3,%eax
  800bde:	89 cb                	mov    %ecx,%ebx
  800be0:	89 cf                	mov    %ecx,%edi
  800be2:	89 ce                	mov    %ecx,%esi
  800be4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be6:	85 c0                	test   %eax,%eax
  800be8:	7f 08                	jg     800bf2 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf2:	83 ec 0c             	sub    $0xc,%esp
  800bf5:	50                   	push   %eax
  800bf6:	6a 03                	push   $0x3
  800bf8:	68 64 17 80 00       	push   $0x801764
  800bfd:	6a 23                	push   $0x23
  800bff:	68 81 17 80 00       	push   $0x801781
  800c04:	e8 4c 05 00 00       	call   801155 <_panic>

00800c09 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c09:	f3 0f 1e fb          	endbr32 
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c13:	ba 00 00 00 00       	mov    $0x0,%edx
  800c18:	b8 02 00 00 00       	mov    $0x2,%eax
  800c1d:	89 d1                	mov    %edx,%ecx
  800c1f:	89 d3                	mov    %edx,%ebx
  800c21:	89 d7                	mov    %edx,%edi
  800c23:	89 d6                	mov    %edx,%esi
  800c25:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <sys_yield>:

void
sys_yield(void)
{
  800c2c:	f3 0f 1e fb          	endbr32 
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	57                   	push   %edi
  800c34:	56                   	push   %esi
  800c35:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c36:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c40:	89 d1                	mov    %edx,%ecx
  800c42:	89 d3                	mov    %edx,%ebx
  800c44:	89 d7                	mov    %edx,%edi
  800c46:	89 d6                	mov    %edx,%esi
  800c48:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c4f:	f3 0f 1e fb          	endbr32 
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5c:	be 00 00 00 00       	mov    $0x0,%esi
  800c61:	8b 55 08             	mov    0x8(%ebp),%edx
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c67:	b8 04 00 00 00       	mov    $0x4,%eax
  800c6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6f:	89 f7                	mov    %esi,%edi
  800c71:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c73:	85 c0                	test   %eax,%eax
  800c75:	7f 08                	jg     800c7f <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7f:	83 ec 0c             	sub    $0xc,%esp
  800c82:	50                   	push   %eax
  800c83:	6a 04                	push   $0x4
  800c85:	68 64 17 80 00       	push   $0x801764
  800c8a:	6a 23                	push   $0x23
  800c8c:	68 81 17 80 00       	push   $0x801781
  800c91:	e8 bf 04 00 00       	call   801155 <_panic>

00800c96 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c96:	f3 0f 1e fb          	endbr32 
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ca3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	b8 05 00 00 00       	mov    $0x5,%eax
  800cae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb4:	8b 75 18             	mov    0x18(%ebp),%esi
  800cb7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	7f 08                	jg     800cc5 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc5:	83 ec 0c             	sub    $0xc,%esp
  800cc8:	50                   	push   %eax
  800cc9:	6a 05                	push   $0x5
  800ccb:	68 64 17 80 00       	push   $0x801764
  800cd0:	6a 23                	push   $0x23
  800cd2:	68 81 17 80 00       	push   $0x801781
  800cd7:	e8 79 04 00 00       	call   801155 <_panic>

00800cdc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cdc:	f3 0f 1e fb          	endbr32 
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cee:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf4:	b8 06 00 00 00       	mov    $0x6,%eax
  800cf9:	89 df                	mov    %ebx,%edi
  800cfb:	89 de                	mov    %ebx,%esi
  800cfd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cff:	85 c0                	test   %eax,%eax
  800d01:	7f 08                	jg     800d0b <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	50                   	push   %eax
  800d0f:	6a 06                	push   $0x6
  800d11:	68 64 17 80 00       	push   $0x801764
  800d16:	6a 23                	push   $0x23
  800d18:	68 81 17 80 00       	push   $0x801781
  800d1d:	e8 33 04 00 00       	call   801155 <_panic>

00800d22 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d22:	f3 0f 1e fb          	endbr32 
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3a:	b8 08 00 00 00       	mov    $0x8,%eax
  800d3f:	89 df                	mov    %ebx,%edi
  800d41:	89 de                	mov    %ebx,%esi
  800d43:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d45:	85 c0                	test   %eax,%eax
  800d47:	7f 08                	jg     800d51 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4c:	5b                   	pop    %ebx
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d51:	83 ec 0c             	sub    $0xc,%esp
  800d54:	50                   	push   %eax
  800d55:	6a 08                	push   $0x8
  800d57:	68 64 17 80 00       	push   $0x801764
  800d5c:	6a 23                	push   $0x23
  800d5e:	68 81 17 80 00       	push   $0x801781
  800d63:	e8 ed 03 00 00       	call   801155 <_panic>

00800d68 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d68:	f3 0f 1e fb          	endbr32 
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d80:	b8 09 00 00 00       	mov    $0x9,%eax
  800d85:	89 df                	mov    %ebx,%edi
  800d87:	89 de                	mov    %ebx,%esi
  800d89:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	7f 08                	jg     800d97 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d97:	83 ec 0c             	sub    $0xc,%esp
  800d9a:	50                   	push   %eax
  800d9b:	6a 09                	push   $0x9
  800d9d:	68 64 17 80 00       	push   $0x801764
  800da2:	6a 23                	push   $0x23
  800da4:	68 81 17 80 00       	push   $0x801781
  800da9:	e8 a7 03 00 00       	call   801155 <_panic>

00800dae <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dae:	f3 0f 1e fb          	endbr32 
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbe:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dc3:	be 00 00 00 00       	mov    $0x0,%esi
  800dc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dcb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dce:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    

00800dd5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dd5:	f3 0f 1e fb          	endbr32 
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	57                   	push   %edi
  800ddd:	56                   	push   %esi
  800dde:	53                   	push   %ebx
  800ddf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800de2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dea:	b8 0c 00 00 00       	mov    $0xc,%eax
  800def:	89 cb                	mov    %ecx,%ebx
  800df1:	89 cf                	mov    %ecx,%edi
  800df3:	89 ce                	mov    %ecx,%esi
  800df5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800df7:	85 c0                	test   %eax,%eax
  800df9:	7f 08                	jg     800e03 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e03:	83 ec 0c             	sub    $0xc,%esp
  800e06:	50                   	push   %eax
  800e07:	6a 0c                	push   $0xc
  800e09:	68 64 17 80 00       	push   $0x801764
  800e0e:	6a 23                	push   $0x23
  800e10:	68 81 17 80 00       	push   $0x801781
  800e15:	e8 3b 03 00 00       	call   801155 <_panic>

00800e1a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e1a:	f3 0f 1e fb          	endbr32 
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	53                   	push   %ebx
  800e22:	83 ec 04             	sub    $0x4,%esp
  800e25:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e28:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if ( !(err & FEC_WR) ||
  800e2a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e2e:	74 75                	je     800ea5 <pgfault+0x8b>
            !(uvpt[PGNUM(addr)] | PTE_COW) ) {
  800e30:	89 d8                	mov    %ebx,%eax
  800e32:	c1 e8 0c             	shr    $0xc,%eax
  800e35:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0) {
  800e3c:	83 ec 04             	sub    $0x4,%esp
  800e3f:	6a 07                	push   $0x7
  800e41:	68 00 f0 7f 00       	push   $0x7ff000
  800e46:	6a 00                	push   $0x0
  800e48:	e8 02 fe ff ff       	call   800c4f <sys_page_alloc>
  800e4d:	83 c4 10             	add    $0x10,%esp
  800e50:	85 c0                	test   %eax,%eax
  800e52:	78 65                	js     800eb9 <pgfault+0x9f>
        panic("sys_page_alloc failed %e\n", r);
    }
    memmove((void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);
  800e54:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800e5a:	83 ec 04             	sub    $0x4,%esp
  800e5d:	68 00 10 00 00       	push   $0x1000
  800e62:	53                   	push   %ebx
  800e63:	68 00 f0 7f 00       	push   $0x7ff000
  800e68:	e8 56 fb ff ff       	call   8009c3 <memmove>
    if ((r = sys_page_map(0, (void *)PFTEMP,
  800e6d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e74:	53                   	push   %ebx
  800e75:	6a 00                	push   $0x0
  800e77:	68 00 f0 7f 00       	push   $0x7ff000
  800e7c:	6a 00                	push   $0x0
  800e7e:	e8 13 fe ff ff       	call   800c96 <sys_page_map>
  800e83:	83 c4 20             	add    $0x20,%esp
  800e86:	85 c0                	test   %eax,%eax
  800e88:	78 41                	js     800ecb <pgfault+0xb1>
                0, (void *)PTE_ADDR(addr), PTE_P | PTE_U | PTE_W)) < 0) {
        panic("sys_page_map failed %e\n", r);
    }
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0) {
  800e8a:	83 ec 08             	sub    $0x8,%esp
  800e8d:	68 00 f0 7f 00       	push   $0x7ff000
  800e92:	6a 00                	push   $0x0
  800e94:	e8 43 fe ff ff       	call   800cdc <sys_page_unmap>
  800e99:	83 c4 10             	add    $0x10,%esp
  800e9c:	85 c0                	test   %eax,%eax
  800e9e:	78 3d                	js     800edd <pgfault+0xc3>
        panic("sys_page_unmap failed %e\n", r);
    }

}
  800ea0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea3:	c9                   	leave  
  800ea4:	c3                   	ret    
        panic("Not a copy-on-write page");
  800ea5:	83 ec 04             	sub    $0x4,%esp
  800ea8:	68 8f 17 80 00       	push   $0x80178f
  800ead:	6a 1e                	push   $0x1e
  800eaf:	68 a8 17 80 00       	push   $0x8017a8
  800eb4:	e8 9c 02 00 00       	call   801155 <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800eb9:	50                   	push   %eax
  800eba:	68 b3 17 80 00       	push   $0x8017b3
  800ebf:	6a 2a                	push   $0x2a
  800ec1:	68 a8 17 80 00       	push   $0x8017a8
  800ec6:	e8 8a 02 00 00       	call   801155 <_panic>
        panic("sys_page_map failed %e\n", r);
  800ecb:	50                   	push   %eax
  800ecc:	68 cd 17 80 00       	push   $0x8017cd
  800ed1:	6a 2f                	push   $0x2f
  800ed3:	68 a8 17 80 00       	push   $0x8017a8
  800ed8:	e8 78 02 00 00       	call   801155 <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800edd:	50                   	push   %eax
  800ede:	68 e5 17 80 00       	push   $0x8017e5
  800ee3:	6a 32                	push   $0x32
  800ee5:	68 a8 17 80 00       	push   $0x8017a8
  800eea:	e8 66 02 00 00       	call   801155 <_panic>

00800eef <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eef:	f3 0f 1e fb          	endbr32 
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	57                   	push   %edi
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");

    // 1. set pgfault handler.
    set_pgfault_handler(pgfault);
  800efc:	68 1a 0e 80 00       	push   $0x800e1a
  800f01:	e8 99 02 00 00       	call   80119f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f06:	b8 07 00 00 00       	mov    $0x7,%eax
  800f0b:	cd 30                	int    $0x30
  800f0d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f10:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 2. exofork.
    envid_t envid = sys_exofork();

    if (envid < 0)
  800f13:	83 c4 10             	add    $0x10,%esp
  800f16:	85 c0                	test   %eax,%eax
  800f18:	78 2a                	js     800f44 <fork+0x55>
        thisenv = &envs[ENVX(my_envid)];
        return 0;
    }
    else {
        // parent
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f1a:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800f1f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f23:	75 4e                	jne    800f73 <fork+0x84>
        envid_t my_envid = sys_getenvid();
  800f25:	e8 df fc ff ff       	call   800c09 <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800f2a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f2f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f32:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f37:	a3 08 20 80 00       	mov    %eax,0x802008
        return 0;
  800f3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f3f:	e9 f1 00 00 00       	jmp    801035 <fork+0x146>
        panic("fork, sys_exofork %e", envid);
  800f44:	50                   	push   %eax
  800f45:	68 ff 17 80 00       	push   $0x8017ff
  800f4a:	6a 7b                	push   $0x7b
  800f4c:	68 a8 17 80 00       	push   $0x8017a8
  800f51:	e8 ff 01 00 00       	call   801155 <_panic>
        panic("sys_page_map others failed %e\n", r);
  800f56:	50                   	push   %eax
  800f57:	68 48 18 80 00       	push   $0x801848
  800f5c:	6a 51                	push   $0x51
  800f5e:	68 a8 17 80 00       	push   $0x8017a8
  800f63:	e8 ed 01 00 00       	call   801155 <_panic>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f68:	83 c3 01             	add    $0x1,%ebx
  800f6b:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800f71:	74 7c                	je     800fef <fork+0x100>
  800f73:	89 de                	mov    %ebx,%esi
  800f75:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800f78:	89 f0                	mov    %esi,%eax
  800f7a:	c1 e8 16             	shr    $0x16,%eax
  800f7d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f84:	a8 01                	test   $0x1,%al
  800f86:	74 e0                	je     800f68 <fork+0x79>
                    (uvpt[pn] & PTE_P) ) {
  800f88:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800f8f:	a8 01                	test   $0x1,%al
  800f91:	74 d5                	je     800f68 <fork+0x79>
    pte_t pte = uvpt[pn];
  800f93:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    if ( (pte & PTE_W) || (pte & PTE_COW) ) {
  800f9a:	25 02 08 00 00       	and    $0x802,%eax
        perm |= PTE_COW;
  800f9f:	83 f8 01             	cmp    $0x1,%eax
  800fa2:	19 ff                	sbb    %edi,%edi
  800fa4:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  800faa:	81 c7 05 08 00 00    	add    $0x805,%edi
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  800fb0:	83 ec 0c             	sub    $0xc,%esp
  800fb3:	57                   	push   %edi
  800fb4:	56                   	push   %esi
  800fb5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb8:	56                   	push   %esi
  800fb9:	6a 00                	push   $0x0
  800fbb:	e8 d6 fc ff ff       	call   800c96 <sys_page_map>
  800fc0:	83 c4 20             	add    $0x20,%esp
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	78 8f                	js     800f56 <fork+0x67>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  800fc7:	83 ec 0c             	sub    $0xc,%esp
  800fca:	57                   	push   %edi
  800fcb:	56                   	push   %esi
  800fcc:	6a 00                	push   $0x0
  800fce:	56                   	push   %esi
  800fcf:	6a 00                	push   $0x0
  800fd1:	e8 c0 fc ff ff       	call   800c96 <sys_page_map>
  800fd6:	83 c4 20             	add    $0x20,%esp
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	79 8b                	jns    800f68 <fork+0x79>
            panic("sys_page_map mine failed %e\n", r);
  800fdd:	50                   	push   %eax
  800fde:	68 14 18 80 00       	push   $0x801814
  800fe3:	6a 56                	push   $0x56
  800fe5:	68 a8 17 80 00       	push   $0x8017a8
  800fea:	e8 66 01 00 00       	call   801155 <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  800fef:	83 ec 04             	sub    $0x4,%esp
  800ff2:	6a 07                	push   $0x7
  800ff4:	68 00 f0 bf ee       	push   $0xeebff000
  800ff9:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800ffc:	57                   	push   %edi
  800ffd:	e8 4d fc ff ff       	call   800c4f <sys_page_alloc>
  801002:	83 c4 10             	add    $0x10,%esp
  801005:	85 c0                	test   %eax,%eax
  801007:	78 2c                	js     801035 <fork+0x146>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  801009:	a1 08 20 80 00       	mov    0x802008,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  80100e:	8b 40 64             	mov    0x64(%eax),%eax
  801011:	83 ec 08             	sub    $0x8,%esp
  801014:	50                   	push   %eax
  801015:	57                   	push   %edi
  801016:	e8 4d fd ff ff       	call   800d68 <sys_env_set_pgfault_upcall>
  80101b:	83 c4 10             	add    $0x10,%esp
  80101e:	85 c0                	test   %eax,%eax
  801020:	78 13                	js     801035 <fork+0x146>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801022:	83 ec 08             	sub    $0x8,%esp
  801025:	6a 02                	push   $0x2
  801027:	57                   	push   %edi
  801028:	e8 f5 fc ff ff       	call   800d22 <sys_env_set_status>
  80102d:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  801030:	85 c0                	test   %eax,%eax
  801032:	0f 49 c7             	cmovns %edi,%eax
    }

}
  801035:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801038:	5b                   	pop    %ebx
  801039:	5e                   	pop    %esi
  80103a:	5f                   	pop    %edi
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    

0080103d <sfork>:

// Challenge!
int
sfork(void)
{
  80103d:	f3 0f 1e fb          	endbr32 
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801047:	68 31 18 80 00       	push   $0x801831
  80104c:	68 a5 00 00 00       	push   $0xa5
  801051:	68 a8 17 80 00       	push   $0x8017a8
  801056:	e8 fa 00 00 00       	call   801155 <_panic>

0080105b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80105b:	f3 0f 1e fb          	endbr32 
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
  801062:	56                   	push   %esi
  801063:	53                   	push   %ebx
  801064:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801067:	8b 45 0c             	mov    0xc(%ebp),%eax
  80106a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  80106d:	85 c0                	test   %eax,%eax
  80106f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801074:	0f 44 c2             	cmove  %edx,%eax
  801077:	83 ec 0c             	sub    $0xc,%esp
  80107a:	50                   	push   %eax
  80107b:	e8 55 fd ff ff       	call   800dd5 <sys_ipc_recv>
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	85 c0                	test   %eax,%eax
  801085:	78 24                	js     8010ab <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801087:	85 f6                	test   %esi,%esi
  801089:	74 0a                	je     801095 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  80108b:	a1 08 20 80 00       	mov    0x802008,%eax
  801090:	8b 40 78             	mov    0x78(%eax),%eax
  801093:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801095:	85 db                	test   %ebx,%ebx
  801097:	74 0a                	je     8010a3 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801099:	a1 08 20 80 00       	mov    0x802008,%eax
  80109e:	8b 40 74             	mov    0x74(%eax),%eax
  8010a1:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  8010a3:	a1 08 20 80 00       	mov    0x802008,%eax
  8010a8:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ae:	5b                   	pop    %ebx
  8010af:	5e                   	pop    %esi
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    

008010b2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010b2:	f3 0f 1e fb          	endbr32 
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	57                   	push   %edi
  8010ba:	56                   	push   %esi
  8010bb:	53                   	push   %ebx
  8010bc:	83 ec 1c             	sub    $0x1c,%esp
  8010bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8010c9:	0f 45 d0             	cmovne %eax,%edx
  8010cc:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  8010ce:	be 01 00 00 00       	mov    $0x1,%esi
  8010d3:	eb 1f                	jmp    8010f4 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  8010d5:	e8 52 fb ff ff       	call   800c2c <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  8010da:	83 c3 01             	add    $0x1,%ebx
  8010dd:	39 de                	cmp    %ebx,%esi
  8010df:	7f f4                	jg     8010d5 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  8010e1:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  8010e3:	83 fe 11             	cmp    $0x11,%esi
  8010e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010eb:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  8010ee:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  8010f2:	75 1c                	jne    801110 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  8010f4:	ff 75 14             	pushl  0x14(%ebp)
  8010f7:	57                   	push   %edi
  8010f8:	ff 75 0c             	pushl  0xc(%ebp)
  8010fb:	ff 75 08             	pushl  0x8(%ebp)
  8010fe:	e8 ab fc ff ff       	call   800dae <sys_ipc_try_send>
  801103:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	bb 00 00 00 00       	mov    $0x0,%ebx
  80110e:	eb cd                	jmp    8010dd <ipc_send+0x2b>
}
  801110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801113:	5b                   	pop    %ebx
  801114:	5e                   	pop    %esi
  801115:	5f                   	pop    %edi
  801116:	5d                   	pop    %ebp
  801117:	c3                   	ret    

00801118 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801118:	f3 0f 1e fb          	endbr32 
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801122:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801127:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80112a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801130:	8b 52 50             	mov    0x50(%edx),%edx
  801133:	39 ca                	cmp    %ecx,%edx
  801135:	74 11                	je     801148 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801137:	83 c0 01             	add    $0x1,%eax
  80113a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80113f:	75 e6                	jne    801127 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801141:	b8 00 00 00 00       	mov    $0x0,%eax
  801146:	eb 0b                	jmp    801153 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801148:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80114b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801150:	8b 40 48             	mov    0x48(%eax),%eax
}
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801155:	f3 0f 1e fb          	endbr32 
  801159:	55                   	push   %ebp
  80115a:	89 e5                	mov    %esp,%ebp
  80115c:	56                   	push   %esi
  80115d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80115e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801161:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801167:	e8 9d fa ff ff       	call   800c09 <sys_getenvid>
  80116c:	83 ec 0c             	sub    $0xc,%esp
  80116f:	ff 75 0c             	pushl  0xc(%ebp)
  801172:	ff 75 08             	pushl  0x8(%ebp)
  801175:	56                   	push   %esi
  801176:	50                   	push   %eax
  801177:	68 68 18 80 00       	push   $0x801868
  80117c:	e8 83 f0 ff ff       	call   800204 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801181:	83 c4 18             	add    $0x18,%esp
  801184:	53                   	push   %ebx
  801185:	ff 75 10             	pushl  0x10(%ebp)
  801188:	e8 22 f0 ff ff       	call   8001af <vcprintf>
	cprintf("\n");
  80118d:	c7 04 24 98 18 80 00 	movl   $0x801898,(%esp)
  801194:	e8 6b f0 ff ff       	call   800204 <cprintf>
  801199:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80119c:	cc                   	int3   
  80119d:	eb fd                	jmp    80119c <_panic+0x47>

0080119f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80119f:	f3 0f 1e fb          	endbr32 
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8011a9:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8011b0:	74 0a                	je     8011bc <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b5:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  8011ba:	c9                   	leave  
  8011bb:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  8011bc:	83 ec 0c             	sub    $0xc,%esp
  8011bf:	68 8b 18 80 00       	push   $0x80188b
  8011c4:	e8 3b f0 ff ff       	call   800204 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  8011c9:	83 c4 0c             	add    $0xc,%esp
  8011cc:	6a 07                	push   $0x7
  8011ce:	68 00 f0 bf ee       	push   $0xeebff000
  8011d3:	6a 00                	push   $0x0
  8011d5:	e8 75 fa ff ff       	call   800c4f <sys_page_alloc>
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	85 c0                	test   %eax,%eax
  8011df:	78 2a                	js     80120b <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  8011e1:	83 ec 08             	sub    $0x8,%esp
  8011e4:	68 1f 12 80 00       	push   $0x80121f
  8011e9:	6a 00                	push   $0x0
  8011eb:	e8 78 fb ff ff       	call   800d68 <sys_env_set_pgfault_upcall>
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	79 bb                	jns    8011b2 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  8011f7:	83 ec 04             	sub    $0x4,%esp
  8011fa:	68 c8 18 80 00       	push   $0x8018c8
  8011ff:	6a 25                	push   $0x25
  801201:	68 b8 18 80 00       	push   $0x8018b8
  801206:	e8 4a ff ff ff       	call   801155 <_panic>
            panic("Allocation of UXSTACK failed!");
  80120b:	83 ec 04             	sub    $0x4,%esp
  80120e:	68 9a 18 80 00       	push   $0x80189a
  801213:	6a 22                	push   $0x22
  801215:	68 b8 18 80 00       	push   $0x8018b8
  80121a:	e8 36 ff ff ff       	call   801155 <_panic>

0080121f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80121f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801220:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801225:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801227:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  80122a:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  80122e:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  801232:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  801235:	83 c4 08             	add    $0x8,%esp
    popa
  801238:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $0x4, %esp
  801239:	83 c4 04             	add    $0x4,%esp
    popf
  80123c:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  80123d:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  801240:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  801244:	c3                   	ret    
  801245:	66 90                	xchg   %ax,%ax
  801247:	66 90                	xchg   %ax,%ax
  801249:	66 90                	xchg   %ax,%ax
  80124b:	66 90                	xchg   %ax,%ax
  80124d:	66 90                	xchg   %ax,%ax
  80124f:	90                   	nop

00801250 <__udivdi3>:
  801250:	f3 0f 1e fb          	endbr32 
  801254:	55                   	push   %ebp
  801255:	57                   	push   %edi
  801256:	56                   	push   %esi
  801257:	53                   	push   %ebx
  801258:	83 ec 1c             	sub    $0x1c,%esp
  80125b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80125f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801263:	8b 74 24 34          	mov    0x34(%esp),%esi
  801267:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80126b:	85 d2                	test   %edx,%edx
  80126d:	75 19                	jne    801288 <__udivdi3+0x38>
  80126f:	39 f3                	cmp    %esi,%ebx
  801271:	76 4d                	jbe    8012c0 <__udivdi3+0x70>
  801273:	31 ff                	xor    %edi,%edi
  801275:	89 e8                	mov    %ebp,%eax
  801277:	89 f2                	mov    %esi,%edx
  801279:	f7 f3                	div    %ebx
  80127b:	89 fa                	mov    %edi,%edx
  80127d:	83 c4 1c             	add    $0x1c,%esp
  801280:	5b                   	pop    %ebx
  801281:	5e                   	pop    %esi
  801282:	5f                   	pop    %edi
  801283:	5d                   	pop    %ebp
  801284:	c3                   	ret    
  801285:	8d 76 00             	lea    0x0(%esi),%esi
  801288:	39 f2                	cmp    %esi,%edx
  80128a:	76 14                	jbe    8012a0 <__udivdi3+0x50>
  80128c:	31 ff                	xor    %edi,%edi
  80128e:	31 c0                	xor    %eax,%eax
  801290:	89 fa                	mov    %edi,%edx
  801292:	83 c4 1c             	add    $0x1c,%esp
  801295:	5b                   	pop    %ebx
  801296:	5e                   	pop    %esi
  801297:	5f                   	pop    %edi
  801298:	5d                   	pop    %ebp
  801299:	c3                   	ret    
  80129a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012a0:	0f bd fa             	bsr    %edx,%edi
  8012a3:	83 f7 1f             	xor    $0x1f,%edi
  8012a6:	75 48                	jne    8012f0 <__udivdi3+0xa0>
  8012a8:	39 f2                	cmp    %esi,%edx
  8012aa:	72 06                	jb     8012b2 <__udivdi3+0x62>
  8012ac:	31 c0                	xor    %eax,%eax
  8012ae:	39 eb                	cmp    %ebp,%ebx
  8012b0:	77 de                	ja     801290 <__udivdi3+0x40>
  8012b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8012b7:	eb d7                	jmp    801290 <__udivdi3+0x40>
  8012b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012c0:	89 d9                	mov    %ebx,%ecx
  8012c2:	85 db                	test   %ebx,%ebx
  8012c4:	75 0b                	jne    8012d1 <__udivdi3+0x81>
  8012c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8012cb:	31 d2                	xor    %edx,%edx
  8012cd:	f7 f3                	div    %ebx
  8012cf:	89 c1                	mov    %eax,%ecx
  8012d1:	31 d2                	xor    %edx,%edx
  8012d3:	89 f0                	mov    %esi,%eax
  8012d5:	f7 f1                	div    %ecx
  8012d7:	89 c6                	mov    %eax,%esi
  8012d9:	89 e8                	mov    %ebp,%eax
  8012db:	89 f7                	mov    %esi,%edi
  8012dd:	f7 f1                	div    %ecx
  8012df:	89 fa                	mov    %edi,%edx
  8012e1:	83 c4 1c             	add    $0x1c,%esp
  8012e4:	5b                   	pop    %ebx
  8012e5:	5e                   	pop    %esi
  8012e6:	5f                   	pop    %edi
  8012e7:	5d                   	pop    %ebp
  8012e8:	c3                   	ret    
  8012e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012f0:	89 f9                	mov    %edi,%ecx
  8012f2:	b8 20 00 00 00       	mov    $0x20,%eax
  8012f7:	29 f8                	sub    %edi,%eax
  8012f9:	d3 e2                	shl    %cl,%edx
  8012fb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012ff:	89 c1                	mov    %eax,%ecx
  801301:	89 da                	mov    %ebx,%edx
  801303:	d3 ea                	shr    %cl,%edx
  801305:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801309:	09 d1                	or     %edx,%ecx
  80130b:	89 f2                	mov    %esi,%edx
  80130d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801311:	89 f9                	mov    %edi,%ecx
  801313:	d3 e3                	shl    %cl,%ebx
  801315:	89 c1                	mov    %eax,%ecx
  801317:	d3 ea                	shr    %cl,%edx
  801319:	89 f9                	mov    %edi,%ecx
  80131b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80131f:	89 eb                	mov    %ebp,%ebx
  801321:	d3 e6                	shl    %cl,%esi
  801323:	89 c1                	mov    %eax,%ecx
  801325:	d3 eb                	shr    %cl,%ebx
  801327:	09 de                	or     %ebx,%esi
  801329:	89 f0                	mov    %esi,%eax
  80132b:	f7 74 24 08          	divl   0x8(%esp)
  80132f:	89 d6                	mov    %edx,%esi
  801331:	89 c3                	mov    %eax,%ebx
  801333:	f7 64 24 0c          	mull   0xc(%esp)
  801337:	39 d6                	cmp    %edx,%esi
  801339:	72 15                	jb     801350 <__udivdi3+0x100>
  80133b:	89 f9                	mov    %edi,%ecx
  80133d:	d3 e5                	shl    %cl,%ebp
  80133f:	39 c5                	cmp    %eax,%ebp
  801341:	73 04                	jae    801347 <__udivdi3+0xf7>
  801343:	39 d6                	cmp    %edx,%esi
  801345:	74 09                	je     801350 <__udivdi3+0x100>
  801347:	89 d8                	mov    %ebx,%eax
  801349:	31 ff                	xor    %edi,%edi
  80134b:	e9 40 ff ff ff       	jmp    801290 <__udivdi3+0x40>
  801350:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801353:	31 ff                	xor    %edi,%edi
  801355:	e9 36 ff ff ff       	jmp    801290 <__udivdi3+0x40>
  80135a:	66 90                	xchg   %ax,%ax
  80135c:	66 90                	xchg   %ax,%ax
  80135e:	66 90                	xchg   %ax,%ax

00801360 <__umoddi3>:
  801360:	f3 0f 1e fb          	endbr32 
  801364:	55                   	push   %ebp
  801365:	57                   	push   %edi
  801366:	56                   	push   %esi
  801367:	53                   	push   %ebx
  801368:	83 ec 1c             	sub    $0x1c,%esp
  80136b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80136f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801373:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801377:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80137b:	85 c0                	test   %eax,%eax
  80137d:	75 19                	jne    801398 <__umoddi3+0x38>
  80137f:	39 df                	cmp    %ebx,%edi
  801381:	76 5d                	jbe    8013e0 <__umoddi3+0x80>
  801383:	89 f0                	mov    %esi,%eax
  801385:	89 da                	mov    %ebx,%edx
  801387:	f7 f7                	div    %edi
  801389:	89 d0                	mov    %edx,%eax
  80138b:	31 d2                	xor    %edx,%edx
  80138d:	83 c4 1c             	add    $0x1c,%esp
  801390:	5b                   	pop    %ebx
  801391:	5e                   	pop    %esi
  801392:	5f                   	pop    %edi
  801393:	5d                   	pop    %ebp
  801394:	c3                   	ret    
  801395:	8d 76 00             	lea    0x0(%esi),%esi
  801398:	89 f2                	mov    %esi,%edx
  80139a:	39 d8                	cmp    %ebx,%eax
  80139c:	76 12                	jbe    8013b0 <__umoddi3+0x50>
  80139e:	89 f0                	mov    %esi,%eax
  8013a0:	89 da                	mov    %ebx,%edx
  8013a2:	83 c4 1c             	add    $0x1c,%esp
  8013a5:	5b                   	pop    %ebx
  8013a6:	5e                   	pop    %esi
  8013a7:	5f                   	pop    %edi
  8013a8:	5d                   	pop    %ebp
  8013a9:	c3                   	ret    
  8013aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013b0:	0f bd e8             	bsr    %eax,%ebp
  8013b3:	83 f5 1f             	xor    $0x1f,%ebp
  8013b6:	75 50                	jne    801408 <__umoddi3+0xa8>
  8013b8:	39 d8                	cmp    %ebx,%eax
  8013ba:	0f 82 e0 00 00 00    	jb     8014a0 <__umoddi3+0x140>
  8013c0:	89 d9                	mov    %ebx,%ecx
  8013c2:	39 f7                	cmp    %esi,%edi
  8013c4:	0f 86 d6 00 00 00    	jbe    8014a0 <__umoddi3+0x140>
  8013ca:	89 d0                	mov    %edx,%eax
  8013cc:	89 ca                	mov    %ecx,%edx
  8013ce:	83 c4 1c             	add    $0x1c,%esp
  8013d1:	5b                   	pop    %ebx
  8013d2:	5e                   	pop    %esi
  8013d3:	5f                   	pop    %edi
  8013d4:	5d                   	pop    %ebp
  8013d5:	c3                   	ret    
  8013d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013dd:	8d 76 00             	lea    0x0(%esi),%esi
  8013e0:	89 fd                	mov    %edi,%ebp
  8013e2:	85 ff                	test   %edi,%edi
  8013e4:	75 0b                	jne    8013f1 <__umoddi3+0x91>
  8013e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013eb:	31 d2                	xor    %edx,%edx
  8013ed:	f7 f7                	div    %edi
  8013ef:	89 c5                	mov    %eax,%ebp
  8013f1:	89 d8                	mov    %ebx,%eax
  8013f3:	31 d2                	xor    %edx,%edx
  8013f5:	f7 f5                	div    %ebp
  8013f7:	89 f0                	mov    %esi,%eax
  8013f9:	f7 f5                	div    %ebp
  8013fb:	89 d0                	mov    %edx,%eax
  8013fd:	31 d2                	xor    %edx,%edx
  8013ff:	eb 8c                	jmp    80138d <__umoddi3+0x2d>
  801401:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801408:	89 e9                	mov    %ebp,%ecx
  80140a:	ba 20 00 00 00       	mov    $0x20,%edx
  80140f:	29 ea                	sub    %ebp,%edx
  801411:	d3 e0                	shl    %cl,%eax
  801413:	89 44 24 08          	mov    %eax,0x8(%esp)
  801417:	89 d1                	mov    %edx,%ecx
  801419:	89 f8                	mov    %edi,%eax
  80141b:	d3 e8                	shr    %cl,%eax
  80141d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801421:	89 54 24 04          	mov    %edx,0x4(%esp)
  801425:	8b 54 24 04          	mov    0x4(%esp),%edx
  801429:	09 c1                	or     %eax,%ecx
  80142b:	89 d8                	mov    %ebx,%eax
  80142d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801431:	89 e9                	mov    %ebp,%ecx
  801433:	d3 e7                	shl    %cl,%edi
  801435:	89 d1                	mov    %edx,%ecx
  801437:	d3 e8                	shr    %cl,%eax
  801439:	89 e9                	mov    %ebp,%ecx
  80143b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80143f:	d3 e3                	shl    %cl,%ebx
  801441:	89 c7                	mov    %eax,%edi
  801443:	89 d1                	mov    %edx,%ecx
  801445:	89 f0                	mov    %esi,%eax
  801447:	d3 e8                	shr    %cl,%eax
  801449:	89 e9                	mov    %ebp,%ecx
  80144b:	89 fa                	mov    %edi,%edx
  80144d:	d3 e6                	shl    %cl,%esi
  80144f:	09 d8                	or     %ebx,%eax
  801451:	f7 74 24 08          	divl   0x8(%esp)
  801455:	89 d1                	mov    %edx,%ecx
  801457:	89 f3                	mov    %esi,%ebx
  801459:	f7 64 24 0c          	mull   0xc(%esp)
  80145d:	89 c6                	mov    %eax,%esi
  80145f:	89 d7                	mov    %edx,%edi
  801461:	39 d1                	cmp    %edx,%ecx
  801463:	72 06                	jb     80146b <__umoddi3+0x10b>
  801465:	75 10                	jne    801477 <__umoddi3+0x117>
  801467:	39 c3                	cmp    %eax,%ebx
  801469:	73 0c                	jae    801477 <__umoddi3+0x117>
  80146b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80146f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801473:	89 d7                	mov    %edx,%edi
  801475:	89 c6                	mov    %eax,%esi
  801477:	89 ca                	mov    %ecx,%edx
  801479:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80147e:	29 f3                	sub    %esi,%ebx
  801480:	19 fa                	sbb    %edi,%edx
  801482:	89 d0                	mov    %edx,%eax
  801484:	d3 e0                	shl    %cl,%eax
  801486:	89 e9                	mov    %ebp,%ecx
  801488:	d3 eb                	shr    %cl,%ebx
  80148a:	d3 ea                	shr    %cl,%edx
  80148c:	09 d8                	or     %ebx,%eax
  80148e:	83 c4 1c             	add    $0x1c,%esp
  801491:	5b                   	pop    %ebx
  801492:	5e                   	pop    %esi
  801493:	5f                   	pop    %edi
  801494:	5d                   	pop    %ebp
  801495:	c3                   	ret    
  801496:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80149d:	8d 76 00             	lea    0x0(%esi),%esi
  8014a0:	29 fe                	sub    %edi,%esi
  8014a2:	19 c3                	sbb    %eax,%ebx
  8014a4:	89 f2                	mov    %esi,%edx
  8014a6:	89 d9                	mov    %ebx,%ecx
  8014a8:	e9 1d ff ff ff       	jmp    8013ca <__umoddi3+0x6a>
