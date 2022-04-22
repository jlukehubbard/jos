
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
  800040:	e8 5b 10 00 00       	call   8010a0 <sfork>
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
  800057:	e8 62 10 00 00       	call   8010be <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80005c:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  800062:	8b 7b 48             	mov    0x48(%ebx),%edi
  800065:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800068:	a1 04 40 80 00       	mov    0x804004,%eax
  80006d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800070:	e8 a6 0b 00 00       	call   800c1b <sys_getenvid>
  800075:	83 c4 08             	add    $0x8,%esp
  800078:	57                   	push   %edi
  800079:	53                   	push   %ebx
  80007a:	56                   	push   %esi
  80007b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80007e:	50                   	push   %eax
  80007f:	68 d0 22 80 00       	push   $0x8022d0
  800084:	e8 8d 01 00 00       	call   800216 <cprintf>
		if (val == 10)
  800089:	a1 04 40 80 00       	mov    0x804004,%eax
  80008e:	83 c4 20             	add    $0x20,%esp
  800091:	83 f8 0a             	cmp    $0xa,%eax
  800094:	74 22                	je     8000b8 <umain+0x85>
			return;
		++val;
  800096:	83 c0 01             	add    $0x1,%eax
  800099:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  80009e:	6a 00                	push   $0x0
  8000a0:	6a 00                	push   $0x0
  8000a2:	6a 00                	push   $0x0
  8000a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a7:	e8 69 10 00 00       	call   801115 <ipc_send>
		if (val == 10)
  8000ac:	83 c4 10             	add    $0x10,%esp
  8000af:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
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
  8000c0:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000c6:	e8 50 0b 00 00       	call   800c1b <sys_getenvid>
  8000cb:	83 ec 04             	sub    $0x4,%esp
  8000ce:	53                   	push   %ebx
  8000cf:	50                   	push   %eax
  8000d0:	68 a0 22 80 00       	push   $0x8022a0
  8000d5:	e8 3c 01 00 00       	call   800216 <cprintf>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  8000da:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8000dd:	e8 39 0b 00 00       	call   800c1b <sys_getenvid>
  8000e2:	83 c4 0c             	add    $0xc,%esp
  8000e5:	53                   	push   %ebx
  8000e6:	50                   	push   %eax
  8000e7:	68 ba 22 80 00       	push   $0x8022ba
  8000ec:	e8 25 01 00 00       	call   800216 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000f1:	6a 00                	push   $0x0
  8000f3:	6a 00                	push   $0x0
  8000f5:	6a 00                	push   $0x0
  8000f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000fa:	e8 16 10 00 00       	call   801115 <ipc_send>
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
  800116:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  80011d:	00 00 00 
    envid_t envid = sys_getenvid();
  800120:	e8 f6 0a 00 00       	call   800c1b <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800125:	25 ff 03 00 00       	and    $0x3ff,%eax
  80012a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80012d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800132:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800137:	85 db                	test   %ebx,%ebx
  800139:	7e 07                	jle    800142 <libmain+0x3b>
		binaryname = argv[0];
  80013b:	8b 06                	mov    (%esi),%eax
  80013d:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800162:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800165:	e8 3d 12 00 00       	call   8013a7 <close_all>
	sys_env_destroy(0);
  80016a:	83 ec 0c             	sub    $0xc,%esp
  80016d:	6a 00                	push   $0x0
  80016f:	e8 62 0a 00 00       	call   800bd6 <sys_env_destroy>
}
  800174:	83 c4 10             	add    $0x10,%esp
  800177:	c9                   	leave  
  800178:	c3                   	ret    

00800179 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800179:	f3 0f 1e fb          	endbr32 
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	53                   	push   %ebx
  800181:	83 ec 04             	sub    $0x4,%esp
  800184:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800187:	8b 13                	mov    (%ebx),%edx
  800189:	8d 42 01             	lea    0x1(%edx),%eax
  80018c:	89 03                	mov    %eax,(%ebx)
  80018e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800191:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800195:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019a:	74 09                	je     8001a5 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80019c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a3:	c9                   	leave  
  8001a4:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	68 ff 00 00 00       	push   $0xff
  8001ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b0:	50                   	push   %eax
  8001b1:	e8 db 09 00 00       	call   800b91 <sys_cputs>
		b->idx = 0;
  8001b6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001bc:	83 c4 10             	add    $0x10,%esp
  8001bf:	eb db                	jmp    80019c <putch+0x23>

008001c1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c1:	f3 0f 1e fb          	endbr32 
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ce:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d5:	00 00 00 
	b.cnt = 0;
  8001d8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001df:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e2:	ff 75 0c             	pushl  0xc(%ebp)
  8001e5:	ff 75 08             	pushl  0x8(%ebp)
  8001e8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ee:	50                   	push   %eax
  8001ef:	68 79 01 80 00       	push   $0x800179
  8001f4:	e8 20 01 00 00       	call   800319 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f9:	83 c4 08             	add    $0x8,%esp
  8001fc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800202:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800208:	50                   	push   %eax
  800209:	e8 83 09 00 00       	call   800b91 <sys_cputs>

	return b.cnt;
}
  80020e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800214:	c9                   	leave  
  800215:	c3                   	ret    

00800216 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800216:	f3 0f 1e fb          	endbr32 
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800220:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800223:	50                   	push   %eax
  800224:	ff 75 08             	pushl  0x8(%ebp)
  800227:	e8 95 ff ff ff       	call   8001c1 <vcprintf>
	va_end(ap);

	return cnt;
}
  80022c:	c9                   	leave  
  80022d:	c3                   	ret    

0080022e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	57                   	push   %edi
  800232:	56                   	push   %esi
  800233:	53                   	push   %ebx
  800234:	83 ec 1c             	sub    $0x1c,%esp
  800237:	89 c7                	mov    %eax,%edi
  800239:	89 d6                	mov    %edx,%esi
  80023b:	8b 45 08             	mov    0x8(%ebp),%eax
  80023e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800241:	89 d1                	mov    %edx,%ecx
  800243:	89 c2                	mov    %eax,%edx
  800245:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800248:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80024b:	8b 45 10             	mov    0x10(%ebp),%eax
  80024e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800251:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800254:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80025b:	39 c2                	cmp    %eax,%edx
  80025d:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800260:	72 3e                	jb     8002a0 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800262:	83 ec 0c             	sub    $0xc,%esp
  800265:	ff 75 18             	pushl  0x18(%ebp)
  800268:	83 eb 01             	sub    $0x1,%ebx
  80026b:	53                   	push   %ebx
  80026c:	50                   	push   %eax
  80026d:	83 ec 08             	sub    $0x8,%esp
  800270:	ff 75 e4             	pushl  -0x1c(%ebp)
  800273:	ff 75 e0             	pushl  -0x20(%ebp)
  800276:	ff 75 dc             	pushl  -0x24(%ebp)
  800279:	ff 75 d8             	pushl  -0x28(%ebp)
  80027c:	e8 af 1d 00 00       	call   802030 <__udivdi3>
  800281:	83 c4 18             	add    $0x18,%esp
  800284:	52                   	push   %edx
  800285:	50                   	push   %eax
  800286:	89 f2                	mov    %esi,%edx
  800288:	89 f8                	mov    %edi,%eax
  80028a:	e8 9f ff ff ff       	call   80022e <printnum>
  80028f:	83 c4 20             	add    $0x20,%esp
  800292:	eb 13                	jmp    8002a7 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	56                   	push   %esi
  800298:	ff 75 18             	pushl  0x18(%ebp)
  80029b:	ff d7                	call   *%edi
  80029d:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002a0:	83 eb 01             	sub    $0x1,%ebx
  8002a3:	85 db                	test   %ebx,%ebx
  8002a5:	7f ed                	jg     800294 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a7:	83 ec 08             	sub    $0x8,%esp
  8002aa:	56                   	push   %esi
  8002ab:	83 ec 04             	sub    $0x4,%esp
  8002ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ba:	e8 81 1e 00 00       	call   802140 <__umoddi3>
  8002bf:	83 c4 14             	add    $0x14,%esp
  8002c2:	0f be 80 00 23 80 00 	movsbl 0x802300(%eax),%eax
  8002c9:	50                   	push   %eax
  8002ca:	ff d7                	call   *%edi
}
  8002cc:	83 c4 10             	add    $0x10,%esp
  8002cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d2:	5b                   	pop    %ebx
  8002d3:	5e                   	pop    %esi
  8002d4:	5f                   	pop    %edi
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    

008002d7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d7:	f3 0f 1e fb          	endbr32 
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e5:	8b 10                	mov    (%eax),%edx
  8002e7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ea:	73 0a                	jae    8002f6 <sprintputch+0x1f>
		*b->buf++ = ch;
  8002ec:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ef:	89 08                	mov    %ecx,(%eax)
  8002f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f4:	88 02                	mov    %al,(%edx)
}
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <printfmt>:
{
  8002f8:	f3 0f 1e fb          	endbr32 
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800302:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800305:	50                   	push   %eax
  800306:	ff 75 10             	pushl  0x10(%ebp)
  800309:	ff 75 0c             	pushl  0xc(%ebp)
  80030c:	ff 75 08             	pushl  0x8(%ebp)
  80030f:	e8 05 00 00 00       	call   800319 <vprintfmt>
}
  800314:	83 c4 10             	add    $0x10,%esp
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <vprintfmt>:
{
  800319:	f3 0f 1e fb          	endbr32 
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	57                   	push   %edi
  800321:	56                   	push   %esi
  800322:	53                   	push   %ebx
  800323:	83 ec 3c             	sub    $0x3c,%esp
  800326:	8b 75 08             	mov    0x8(%ebp),%esi
  800329:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80032f:	e9 4a 03 00 00       	jmp    80067e <vprintfmt+0x365>
		padc = ' ';
  800334:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800338:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80033f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800346:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80034d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8d 47 01             	lea    0x1(%edi),%eax
  800355:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800358:	0f b6 17             	movzbl (%edi),%edx
  80035b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80035e:	3c 55                	cmp    $0x55,%al
  800360:	0f 87 de 03 00 00    	ja     800744 <vprintfmt+0x42b>
  800366:	0f b6 c0             	movzbl %al,%eax
  800369:	3e ff 24 85 40 24 80 	notrack jmp *0x802440(,%eax,4)
  800370:	00 
  800371:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800374:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800378:	eb d8                	jmp    800352 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800381:	eb cf                	jmp    800352 <vprintfmt+0x39>
  800383:	0f b6 d2             	movzbl %dl,%edx
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800389:	b8 00 00 00 00       	mov    $0x0,%eax
  80038e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800391:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800394:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800398:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80039b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80039e:	83 f9 09             	cmp    $0x9,%ecx
  8003a1:	77 55                	ja     8003f8 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003a3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003a6:	eb e9                	jmp    800391 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ab:	8b 00                	mov    (%eax),%eax
  8003ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 40 04             	lea    0x4(%eax),%eax
  8003b6:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003bc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c0:	79 90                	jns    800352 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003cf:	eb 81                	jmp    800352 <vprintfmt+0x39>
  8003d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d4:	85 c0                	test   %eax,%eax
  8003d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003db:	0f 49 d0             	cmovns %eax,%edx
  8003de:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003e4:	e9 69 ff ff ff       	jmp    800352 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003ec:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003f3:	e9 5a ff ff ff       	jmp    800352 <vprintfmt+0x39>
  8003f8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003fe:	eb bc                	jmp    8003bc <vprintfmt+0xa3>
			lflag++;
  800400:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800406:	e9 47 ff ff ff       	jmp    800352 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80040b:	8b 45 14             	mov    0x14(%ebp),%eax
  80040e:	8d 78 04             	lea    0x4(%eax),%edi
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	53                   	push   %ebx
  800415:	ff 30                	pushl  (%eax)
  800417:	ff d6                	call   *%esi
			break;
  800419:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80041c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80041f:	e9 57 02 00 00       	jmp    80067b <vprintfmt+0x362>
			err = va_arg(ap, int);
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	8d 78 04             	lea    0x4(%eax),%edi
  80042a:	8b 00                	mov    (%eax),%eax
  80042c:	99                   	cltd   
  80042d:	31 d0                	xor    %edx,%eax
  80042f:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800431:	83 f8 0f             	cmp    $0xf,%eax
  800434:	7f 23                	jg     800459 <vprintfmt+0x140>
  800436:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  80043d:	85 d2                	test   %edx,%edx
  80043f:	74 18                	je     800459 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800441:	52                   	push   %edx
  800442:	68 a9 27 80 00       	push   $0x8027a9
  800447:	53                   	push   %ebx
  800448:	56                   	push   %esi
  800449:	e8 aa fe ff ff       	call   8002f8 <printfmt>
  80044e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800451:	89 7d 14             	mov    %edi,0x14(%ebp)
  800454:	e9 22 02 00 00       	jmp    80067b <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800459:	50                   	push   %eax
  80045a:	68 18 23 80 00       	push   $0x802318
  80045f:	53                   	push   %ebx
  800460:	56                   	push   %esi
  800461:	e8 92 fe ff ff       	call   8002f8 <printfmt>
  800466:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800469:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80046c:	e9 0a 02 00 00       	jmp    80067b <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800471:	8b 45 14             	mov    0x14(%ebp),%eax
  800474:	83 c0 04             	add    $0x4,%eax
  800477:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80047a:	8b 45 14             	mov    0x14(%ebp),%eax
  80047d:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80047f:	85 d2                	test   %edx,%edx
  800481:	b8 11 23 80 00       	mov    $0x802311,%eax
  800486:	0f 45 c2             	cmovne %edx,%eax
  800489:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80048c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800490:	7e 06                	jle    800498 <vprintfmt+0x17f>
  800492:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800496:	75 0d                	jne    8004a5 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800498:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80049b:	89 c7                	mov    %eax,%edi
  80049d:	03 45 e0             	add    -0x20(%ebp),%eax
  8004a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a3:	eb 55                	jmp    8004fa <vprintfmt+0x1e1>
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ab:	ff 75 cc             	pushl  -0x34(%ebp)
  8004ae:	e8 45 03 00 00       	call   8007f8 <strnlen>
  8004b3:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004b6:	29 c2                	sub    %eax,%edx
  8004b8:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004bb:	83 c4 10             	add    $0x10,%esp
  8004be:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004c0:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c7:	85 ff                	test   %edi,%edi
  8004c9:	7e 11                	jle    8004dc <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	53                   	push   %ebx
  8004cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d4:	83 ef 01             	sub    $0x1,%edi
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	eb eb                	jmp    8004c7 <vprintfmt+0x1ae>
  8004dc:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004df:	85 d2                	test   %edx,%edx
  8004e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e6:	0f 49 c2             	cmovns %edx,%eax
  8004e9:	29 c2                	sub    %eax,%edx
  8004eb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004ee:	eb a8                	jmp    800498 <vprintfmt+0x17f>
					putch(ch, putdat);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	53                   	push   %ebx
  8004f4:	52                   	push   %edx
  8004f5:	ff d6                	call   *%esi
  8004f7:	83 c4 10             	add    $0x10,%esp
  8004fa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004fd:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ff:	83 c7 01             	add    $0x1,%edi
  800502:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800506:	0f be d0             	movsbl %al,%edx
  800509:	85 d2                	test   %edx,%edx
  80050b:	74 4b                	je     800558 <vprintfmt+0x23f>
  80050d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800511:	78 06                	js     800519 <vprintfmt+0x200>
  800513:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800517:	78 1e                	js     800537 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800519:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80051d:	74 d1                	je     8004f0 <vprintfmt+0x1d7>
  80051f:	0f be c0             	movsbl %al,%eax
  800522:	83 e8 20             	sub    $0x20,%eax
  800525:	83 f8 5e             	cmp    $0x5e,%eax
  800528:	76 c6                	jbe    8004f0 <vprintfmt+0x1d7>
					putch('?', putdat);
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	53                   	push   %ebx
  80052e:	6a 3f                	push   $0x3f
  800530:	ff d6                	call   *%esi
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	eb c3                	jmp    8004fa <vprintfmt+0x1e1>
  800537:	89 cf                	mov    %ecx,%edi
  800539:	eb 0e                	jmp    800549 <vprintfmt+0x230>
				putch(' ', putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	53                   	push   %ebx
  80053f:	6a 20                	push   $0x20
  800541:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800543:	83 ef 01             	sub    $0x1,%edi
  800546:	83 c4 10             	add    $0x10,%esp
  800549:	85 ff                	test   %edi,%edi
  80054b:	7f ee                	jg     80053b <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80054d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800550:	89 45 14             	mov    %eax,0x14(%ebp)
  800553:	e9 23 01 00 00       	jmp    80067b <vprintfmt+0x362>
  800558:	89 cf                	mov    %ecx,%edi
  80055a:	eb ed                	jmp    800549 <vprintfmt+0x230>
	if (lflag >= 2)
  80055c:	83 f9 01             	cmp    $0x1,%ecx
  80055f:	7f 1b                	jg     80057c <vprintfmt+0x263>
	else if (lflag)
  800561:	85 c9                	test   %ecx,%ecx
  800563:	74 63                	je     8005c8 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8b 00                	mov    (%eax),%eax
  80056a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056d:	99                   	cltd   
  80056e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 40 04             	lea    0x4(%eax),%eax
  800577:	89 45 14             	mov    %eax,0x14(%ebp)
  80057a:	eb 17                	jmp    800593 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8b 50 04             	mov    0x4(%eax),%edx
  800582:	8b 00                	mov    (%eax),%eax
  800584:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800587:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	8d 40 08             	lea    0x8(%eax),%eax
  800590:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800593:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800596:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800599:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80059e:	85 c9                	test   %ecx,%ecx
  8005a0:	0f 89 bb 00 00 00    	jns    800661 <vprintfmt+0x348>
				putch('-', putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	53                   	push   %ebx
  8005aa:	6a 2d                	push   $0x2d
  8005ac:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ae:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005b4:	f7 da                	neg    %edx
  8005b6:	83 d1 00             	adc    $0x0,%ecx
  8005b9:	f7 d9                	neg    %ecx
  8005bb:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c3:	e9 99 00 00 00       	jmp    800661 <vprintfmt+0x348>
		return va_arg(*ap, int);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8b 00                	mov    (%eax),%eax
  8005cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d0:	99                   	cltd   
  8005d1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 40 04             	lea    0x4(%eax),%eax
  8005da:	89 45 14             	mov    %eax,0x14(%ebp)
  8005dd:	eb b4                	jmp    800593 <vprintfmt+0x27a>
	if (lflag >= 2)
  8005df:	83 f9 01             	cmp    $0x1,%ecx
  8005e2:	7f 1b                	jg     8005ff <vprintfmt+0x2e6>
	else if (lflag)
  8005e4:	85 c9                	test   %ecx,%ecx
  8005e6:	74 2c                	je     800614 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8b 10                	mov    (%eax),%edx
  8005ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f2:	8d 40 04             	lea    0x4(%eax),%eax
  8005f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f8:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005fd:	eb 62                	jmp    800661 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8b 10                	mov    (%eax),%edx
  800604:	8b 48 04             	mov    0x4(%eax),%ecx
  800607:	8d 40 08             	lea    0x8(%eax),%eax
  80060a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800612:	eb 4d                	jmp    800661 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8b 10                	mov    (%eax),%edx
  800619:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061e:	8d 40 04             	lea    0x4(%eax),%eax
  800621:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800624:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800629:	eb 36                	jmp    800661 <vprintfmt+0x348>
	if (lflag >= 2)
  80062b:	83 f9 01             	cmp    $0x1,%ecx
  80062e:	7f 17                	jg     800647 <vprintfmt+0x32e>
	else if (lflag)
  800630:	85 c9                	test   %ecx,%ecx
  800632:	74 6e                	je     8006a2 <vprintfmt+0x389>
		return va_arg(*ap, long);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8b 10                	mov    (%eax),%edx
  800639:	89 d0                	mov    %edx,%eax
  80063b:	99                   	cltd   
  80063c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80063f:	8d 49 04             	lea    0x4(%ecx),%ecx
  800642:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800645:	eb 11                	jmp    800658 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8b 50 04             	mov    0x4(%eax),%edx
  80064d:	8b 00                	mov    (%eax),%eax
  80064f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800652:	8d 49 08             	lea    0x8(%ecx),%ecx
  800655:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800658:	89 d1                	mov    %edx,%ecx
  80065a:	89 c2                	mov    %eax,%edx
            base = 8;
  80065c:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800661:	83 ec 0c             	sub    $0xc,%esp
  800664:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800668:	57                   	push   %edi
  800669:	ff 75 e0             	pushl  -0x20(%ebp)
  80066c:	50                   	push   %eax
  80066d:	51                   	push   %ecx
  80066e:	52                   	push   %edx
  80066f:	89 da                	mov    %ebx,%edx
  800671:	89 f0                	mov    %esi,%eax
  800673:	e8 b6 fb ff ff       	call   80022e <printnum>
			break;
  800678:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80067b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80067e:	83 c7 01             	add    $0x1,%edi
  800681:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800685:	83 f8 25             	cmp    $0x25,%eax
  800688:	0f 84 a6 fc ff ff    	je     800334 <vprintfmt+0x1b>
			if (ch == '\0')
  80068e:	85 c0                	test   %eax,%eax
  800690:	0f 84 ce 00 00 00    	je     800764 <vprintfmt+0x44b>
			putch(ch, putdat);
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	53                   	push   %ebx
  80069a:	50                   	push   %eax
  80069b:	ff d6                	call   *%esi
  80069d:	83 c4 10             	add    $0x10,%esp
  8006a0:	eb dc                	jmp    80067e <vprintfmt+0x365>
		return va_arg(*ap, int);
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8b 10                	mov    (%eax),%edx
  8006a7:	89 d0                	mov    %edx,%eax
  8006a9:	99                   	cltd   
  8006aa:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006ad:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006b0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006b3:	eb a3                	jmp    800658 <vprintfmt+0x33f>
			putch('0', putdat);
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	53                   	push   %ebx
  8006b9:	6a 30                	push   $0x30
  8006bb:	ff d6                	call   *%esi
			putch('x', putdat);
  8006bd:	83 c4 08             	add    $0x8,%esp
  8006c0:	53                   	push   %ebx
  8006c1:	6a 78                	push   $0x78
  8006c3:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8b 10                	mov    (%eax),%edx
  8006ca:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006cf:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006d2:	8d 40 04             	lea    0x4(%eax),%eax
  8006d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d8:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006dd:	eb 82                	jmp    800661 <vprintfmt+0x348>
	if (lflag >= 2)
  8006df:	83 f9 01             	cmp    $0x1,%ecx
  8006e2:	7f 1e                	jg     800702 <vprintfmt+0x3e9>
	else if (lflag)
  8006e4:	85 c9                	test   %ecx,%ecx
  8006e6:	74 32                	je     80071a <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8b 10                	mov    (%eax),%edx
  8006ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f2:	8d 40 04             	lea    0x4(%eax),%eax
  8006f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f8:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006fd:	e9 5f ff ff ff       	jmp    800661 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	8b 10                	mov    (%eax),%edx
  800707:	8b 48 04             	mov    0x4(%eax),%ecx
  80070a:	8d 40 08             	lea    0x8(%eax),%eax
  80070d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800710:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800715:	e9 47 ff ff ff       	jmp    800661 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8b 10                	mov    (%eax),%edx
  80071f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800724:	8d 40 04             	lea    0x4(%eax),%eax
  800727:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80072f:	e9 2d ff ff ff       	jmp    800661 <vprintfmt+0x348>
			putch(ch, putdat);
  800734:	83 ec 08             	sub    $0x8,%esp
  800737:	53                   	push   %ebx
  800738:	6a 25                	push   $0x25
  80073a:	ff d6                	call   *%esi
			break;
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	e9 37 ff ff ff       	jmp    80067b <vprintfmt+0x362>
			putch('%', putdat);
  800744:	83 ec 08             	sub    $0x8,%esp
  800747:	53                   	push   %ebx
  800748:	6a 25                	push   $0x25
  80074a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	89 f8                	mov    %edi,%eax
  800751:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800755:	74 05                	je     80075c <vprintfmt+0x443>
  800757:	83 e8 01             	sub    $0x1,%eax
  80075a:	eb f5                	jmp    800751 <vprintfmt+0x438>
  80075c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80075f:	e9 17 ff ff ff       	jmp    80067b <vprintfmt+0x362>
}
  800764:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800767:	5b                   	pop    %ebx
  800768:	5e                   	pop    %esi
  800769:	5f                   	pop    %edi
  80076a:	5d                   	pop    %ebp
  80076b:	c3                   	ret    

0080076c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80076c:	f3 0f 1e fb          	endbr32 
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	83 ec 18             	sub    $0x18,%esp
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800783:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800786:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078d:	85 c0                	test   %eax,%eax
  80078f:	74 26                	je     8007b7 <vsnprintf+0x4b>
  800791:	85 d2                	test   %edx,%edx
  800793:	7e 22                	jle    8007b7 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800795:	ff 75 14             	pushl  0x14(%ebp)
  800798:	ff 75 10             	pushl  0x10(%ebp)
  80079b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079e:	50                   	push   %eax
  80079f:	68 d7 02 80 00       	push   $0x8002d7
  8007a4:	e8 70 fb ff ff       	call   800319 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ac:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b2:	83 c4 10             	add    $0x10,%esp
}
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    
		return -E_INVAL;
  8007b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007bc:	eb f7                	jmp    8007b5 <vsnprintf+0x49>

008007be <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007be:	f3 0f 1e fb          	endbr32 
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007cb:	50                   	push   %eax
  8007cc:	ff 75 10             	pushl  0x10(%ebp)
  8007cf:	ff 75 0c             	pushl  0xc(%ebp)
  8007d2:	ff 75 08             	pushl  0x8(%ebp)
  8007d5:	e8 92 ff ff ff       	call   80076c <vsnprintf>
	va_end(ap);

	return rc;
}
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007dc:	f3 0f 1e fb          	endbr32 
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007eb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ef:	74 05                	je     8007f6 <strlen+0x1a>
		n++;
  8007f1:	83 c0 01             	add    $0x1,%eax
  8007f4:	eb f5                	jmp    8007eb <strlen+0xf>
	return n;
}
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f8:	f3 0f 1e fb          	endbr32 
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800802:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800805:	b8 00 00 00 00       	mov    $0x0,%eax
  80080a:	39 d0                	cmp    %edx,%eax
  80080c:	74 0d                	je     80081b <strnlen+0x23>
  80080e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800812:	74 05                	je     800819 <strnlen+0x21>
		n++;
  800814:	83 c0 01             	add    $0x1,%eax
  800817:	eb f1                	jmp    80080a <strnlen+0x12>
  800819:	89 c2                	mov    %eax,%edx
	return n;
}
  80081b:	89 d0                	mov    %edx,%eax
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081f:	f3 0f 1e fb          	endbr32 
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	53                   	push   %ebx
  800827:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80082d:	b8 00 00 00 00       	mov    $0x0,%eax
  800832:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800836:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800839:	83 c0 01             	add    $0x1,%eax
  80083c:	84 d2                	test   %dl,%dl
  80083e:	75 f2                	jne    800832 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800840:	89 c8                	mov    %ecx,%eax
  800842:	5b                   	pop    %ebx
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800845:	f3 0f 1e fb          	endbr32 
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	53                   	push   %ebx
  80084d:	83 ec 10             	sub    $0x10,%esp
  800850:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800853:	53                   	push   %ebx
  800854:	e8 83 ff ff ff       	call   8007dc <strlen>
  800859:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80085c:	ff 75 0c             	pushl  0xc(%ebp)
  80085f:	01 d8                	add    %ebx,%eax
  800861:	50                   	push   %eax
  800862:	e8 b8 ff ff ff       	call   80081f <strcpy>
	return dst;
}
  800867:	89 d8                	mov    %ebx,%eax
  800869:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086c:	c9                   	leave  
  80086d:	c3                   	ret    

0080086e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80086e:	f3 0f 1e fb          	endbr32 
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	56                   	push   %esi
  800876:	53                   	push   %ebx
  800877:	8b 75 08             	mov    0x8(%ebp),%esi
  80087a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087d:	89 f3                	mov    %esi,%ebx
  80087f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800882:	89 f0                	mov    %esi,%eax
  800884:	39 d8                	cmp    %ebx,%eax
  800886:	74 11                	je     800899 <strncpy+0x2b>
		*dst++ = *src;
  800888:	83 c0 01             	add    $0x1,%eax
  80088b:	0f b6 0a             	movzbl (%edx),%ecx
  80088e:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800891:	80 f9 01             	cmp    $0x1,%cl
  800894:	83 da ff             	sbb    $0xffffffff,%edx
  800897:	eb eb                	jmp    800884 <strncpy+0x16>
	}
	return ret;
}
  800899:	89 f0                	mov    %esi,%eax
  80089b:	5b                   	pop    %ebx
  80089c:	5e                   	pop    %esi
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80089f:	f3 0f 1e fb          	endbr32 
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	56                   	push   %esi
  8008a7:	53                   	push   %ebx
  8008a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ae:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b3:	85 d2                	test   %edx,%edx
  8008b5:	74 21                	je     8008d8 <strlcpy+0x39>
  8008b7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008bb:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008bd:	39 c2                	cmp    %eax,%edx
  8008bf:	74 14                	je     8008d5 <strlcpy+0x36>
  8008c1:	0f b6 19             	movzbl (%ecx),%ebx
  8008c4:	84 db                	test   %bl,%bl
  8008c6:	74 0b                	je     8008d3 <strlcpy+0x34>
			*dst++ = *src++;
  8008c8:	83 c1 01             	add    $0x1,%ecx
  8008cb:	83 c2 01             	add    $0x1,%edx
  8008ce:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008d1:	eb ea                	jmp    8008bd <strlcpy+0x1e>
  8008d3:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008d5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008d8:	29 f0                	sub    %esi,%eax
}
  8008da:	5b                   	pop    %ebx
  8008db:	5e                   	pop    %esi
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008de:	f3 0f 1e fb          	endbr32 
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008eb:	0f b6 01             	movzbl (%ecx),%eax
  8008ee:	84 c0                	test   %al,%al
  8008f0:	74 0c                	je     8008fe <strcmp+0x20>
  8008f2:	3a 02                	cmp    (%edx),%al
  8008f4:	75 08                	jne    8008fe <strcmp+0x20>
		p++, q++;
  8008f6:	83 c1 01             	add    $0x1,%ecx
  8008f9:	83 c2 01             	add    $0x1,%edx
  8008fc:	eb ed                	jmp    8008eb <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fe:	0f b6 c0             	movzbl %al,%eax
  800901:	0f b6 12             	movzbl (%edx),%edx
  800904:	29 d0                	sub    %edx,%eax
}
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800908:	f3 0f 1e fb          	endbr32 
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	53                   	push   %ebx
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	8b 55 0c             	mov    0xc(%ebp),%edx
  800916:	89 c3                	mov    %eax,%ebx
  800918:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80091b:	eb 06                	jmp    800923 <strncmp+0x1b>
		n--, p++, q++;
  80091d:	83 c0 01             	add    $0x1,%eax
  800920:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800923:	39 d8                	cmp    %ebx,%eax
  800925:	74 16                	je     80093d <strncmp+0x35>
  800927:	0f b6 08             	movzbl (%eax),%ecx
  80092a:	84 c9                	test   %cl,%cl
  80092c:	74 04                	je     800932 <strncmp+0x2a>
  80092e:	3a 0a                	cmp    (%edx),%cl
  800930:	74 eb                	je     80091d <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800932:	0f b6 00             	movzbl (%eax),%eax
  800935:	0f b6 12             	movzbl (%edx),%edx
  800938:	29 d0                	sub    %edx,%eax
}
  80093a:	5b                   	pop    %ebx
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    
		return 0;
  80093d:	b8 00 00 00 00       	mov    $0x0,%eax
  800942:	eb f6                	jmp    80093a <strncmp+0x32>

00800944 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800944:	f3 0f 1e fb          	endbr32 
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800952:	0f b6 10             	movzbl (%eax),%edx
  800955:	84 d2                	test   %dl,%dl
  800957:	74 09                	je     800962 <strchr+0x1e>
		if (*s == c)
  800959:	38 ca                	cmp    %cl,%dl
  80095b:	74 0a                	je     800967 <strchr+0x23>
	for (; *s; s++)
  80095d:	83 c0 01             	add    $0x1,%eax
  800960:	eb f0                	jmp    800952 <strchr+0xe>
			return (char *) s;
	return 0;
  800962:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800969:	f3 0f 1e fb          	endbr32 
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800977:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80097a:	38 ca                	cmp    %cl,%dl
  80097c:	74 09                	je     800987 <strfind+0x1e>
  80097e:	84 d2                	test   %dl,%dl
  800980:	74 05                	je     800987 <strfind+0x1e>
	for (; *s; s++)
  800982:	83 c0 01             	add    $0x1,%eax
  800985:	eb f0                	jmp    800977 <strfind+0xe>
			break;
	return (char *) s;
}
  800987:	5d                   	pop    %ebp
  800988:	c3                   	ret    

00800989 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800989:	f3 0f 1e fb          	endbr32 
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	57                   	push   %edi
  800991:	56                   	push   %esi
  800992:	53                   	push   %ebx
  800993:	8b 7d 08             	mov    0x8(%ebp),%edi
  800996:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800999:	85 c9                	test   %ecx,%ecx
  80099b:	74 31                	je     8009ce <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80099d:	89 f8                	mov    %edi,%eax
  80099f:	09 c8                	or     %ecx,%eax
  8009a1:	a8 03                	test   $0x3,%al
  8009a3:	75 23                	jne    8009c8 <memset+0x3f>
		c &= 0xFF;
  8009a5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a9:	89 d3                	mov    %edx,%ebx
  8009ab:	c1 e3 08             	shl    $0x8,%ebx
  8009ae:	89 d0                	mov    %edx,%eax
  8009b0:	c1 e0 18             	shl    $0x18,%eax
  8009b3:	89 d6                	mov    %edx,%esi
  8009b5:	c1 e6 10             	shl    $0x10,%esi
  8009b8:	09 f0                	or     %esi,%eax
  8009ba:	09 c2                	or     %eax,%edx
  8009bc:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009be:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009c1:	89 d0                	mov    %edx,%eax
  8009c3:	fc                   	cld    
  8009c4:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c6:	eb 06                	jmp    8009ce <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cb:	fc                   	cld    
  8009cc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ce:	89 f8                	mov    %edi,%eax
  8009d0:	5b                   	pop    %ebx
  8009d1:	5e                   	pop    %esi
  8009d2:	5f                   	pop    %edi
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d5:	f3 0f 1e fb          	endbr32 
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	57                   	push   %edi
  8009dd:	56                   	push   %esi
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e7:	39 c6                	cmp    %eax,%esi
  8009e9:	73 32                	jae    800a1d <memmove+0x48>
  8009eb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ee:	39 c2                	cmp    %eax,%edx
  8009f0:	76 2b                	jbe    800a1d <memmove+0x48>
		s += n;
		d += n;
  8009f2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f5:	89 fe                	mov    %edi,%esi
  8009f7:	09 ce                	or     %ecx,%esi
  8009f9:	09 d6                	or     %edx,%esi
  8009fb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a01:	75 0e                	jne    800a11 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a03:	83 ef 04             	sub    $0x4,%edi
  800a06:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a09:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a0c:	fd                   	std    
  800a0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0f:	eb 09                	jmp    800a1a <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a11:	83 ef 01             	sub    $0x1,%edi
  800a14:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a17:	fd                   	std    
  800a18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a1a:	fc                   	cld    
  800a1b:	eb 1a                	jmp    800a37 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1d:	89 c2                	mov    %eax,%edx
  800a1f:	09 ca                	or     %ecx,%edx
  800a21:	09 f2                	or     %esi,%edx
  800a23:	f6 c2 03             	test   $0x3,%dl
  800a26:	75 0a                	jne    800a32 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a28:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a2b:	89 c7                	mov    %eax,%edi
  800a2d:	fc                   	cld    
  800a2e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a30:	eb 05                	jmp    800a37 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a32:	89 c7                	mov    %eax,%edi
  800a34:	fc                   	cld    
  800a35:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a37:	5e                   	pop    %esi
  800a38:	5f                   	pop    %edi
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a3b:	f3 0f 1e fb          	endbr32 
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a45:	ff 75 10             	pushl  0x10(%ebp)
  800a48:	ff 75 0c             	pushl  0xc(%ebp)
  800a4b:	ff 75 08             	pushl  0x8(%ebp)
  800a4e:	e8 82 ff ff ff       	call   8009d5 <memmove>
}
  800a53:	c9                   	leave  
  800a54:	c3                   	ret    

00800a55 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a55:	f3 0f 1e fb          	endbr32 
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	56                   	push   %esi
  800a5d:	53                   	push   %ebx
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a64:	89 c6                	mov    %eax,%esi
  800a66:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a69:	39 f0                	cmp    %esi,%eax
  800a6b:	74 1c                	je     800a89 <memcmp+0x34>
		if (*s1 != *s2)
  800a6d:	0f b6 08             	movzbl (%eax),%ecx
  800a70:	0f b6 1a             	movzbl (%edx),%ebx
  800a73:	38 d9                	cmp    %bl,%cl
  800a75:	75 08                	jne    800a7f <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a77:	83 c0 01             	add    $0x1,%eax
  800a7a:	83 c2 01             	add    $0x1,%edx
  800a7d:	eb ea                	jmp    800a69 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a7f:	0f b6 c1             	movzbl %cl,%eax
  800a82:	0f b6 db             	movzbl %bl,%ebx
  800a85:	29 d8                	sub    %ebx,%eax
  800a87:	eb 05                	jmp    800a8e <memcmp+0x39>
	}

	return 0;
  800a89:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a8e:	5b                   	pop    %ebx
  800a8f:	5e                   	pop    %esi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a92:	f3 0f 1e fb          	endbr32 
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a9f:	89 c2                	mov    %eax,%edx
  800aa1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa4:	39 d0                	cmp    %edx,%eax
  800aa6:	73 09                	jae    800ab1 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa8:	38 08                	cmp    %cl,(%eax)
  800aaa:	74 05                	je     800ab1 <memfind+0x1f>
	for (; s < ends; s++)
  800aac:	83 c0 01             	add    $0x1,%eax
  800aaf:	eb f3                	jmp    800aa4 <memfind+0x12>
			break;
	return (void *) s;
}
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ab3:	f3 0f 1e fb          	endbr32 
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	57                   	push   %edi
  800abb:	56                   	push   %esi
  800abc:	53                   	push   %ebx
  800abd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac3:	eb 03                	jmp    800ac8 <strtol+0x15>
		s++;
  800ac5:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ac8:	0f b6 01             	movzbl (%ecx),%eax
  800acb:	3c 20                	cmp    $0x20,%al
  800acd:	74 f6                	je     800ac5 <strtol+0x12>
  800acf:	3c 09                	cmp    $0x9,%al
  800ad1:	74 f2                	je     800ac5 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ad3:	3c 2b                	cmp    $0x2b,%al
  800ad5:	74 2a                	je     800b01 <strtol+0x4e>
	int neg = 0;
  800ad7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800adc:	3c 2d                	cmp    $0x2d,%al
  800ade:	74 2b                	je     800b0b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae6:	75 0f                	jne    800af7 <strtol+0x44>
  800ae8:	80 39 30             	cmpb   $0x30,(%ecx)
  800aeb:	74 28                	je     800b15 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aed:	85 db                	test   %ebx,%ebx
  800aef:	b8 0a 00 00 00       	mov    $0xa,%eax
  800af4:	0f 44 d8             	cmove  %eax,%ebx
  800af7:	b8 00 00 00 00       	mov    $0x0,%eax
  800afc:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aff:	eb 46                	jmp    800b47 <strtol+0x94>
		s++;
  800b01:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b04:	bf 00 00 00 00       	mov    $0x0,%edi
  800b09:	eb d5                	jmp    800ae0 <strtol+0x2d>
		s++, neg = 1;
  800b0b:	83 c1 01             	add    $0x1,%ecx
  800b0e:	bf 01 00 00 00       	mov    $0x1,%edi
  800b13:	eb cb                	jmp    800ae0 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b15:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b19:	74 0e                	je     800b29 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b1b:	85 db                	test   %ebx,%ebx
  800b1d:	75 d8                	jne    800af7 <strtol+0x44>
		s++, base = 8;
  800b1f:	83 c1 01             	add    $0x1,%ecx
  800b22:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b27:	eb ce                	jmp    800af7 <strtol+0x44>
		s += 2, base = 16;
  800b29:	83 c1 02             	add    $0x2,%ecx
  800b2c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b31:	eb c4                	jmp    800af7 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b33:	0f be d2             	movsbl %dl,%edx
  800b36:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b39:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b3c:	7d 3a                	jge    800b78 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b3e:	83 c1 01             	add    $0x1,%ecx
  800b41:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b45:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b47:	0f b6 11             	movzbl (%ecx),%edx
  800b4a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b4d:	89 f3                	mov    %esi,%ebx
  800b4f:	80 fb 09             	cmp    $0x9,%bl
  800b52:	76 df                	jbe    800b33 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b54:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b57:	89 f3                	mov    %esi,%ebx
  800b59:	80 fb 19             	cmp    $0x19,%bl
  800b5c:	77 08                	ja     800b66 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b5e:	0f be d2             	movsbl %dl,%edx
  800b61:	83 ea 57             	sub    $0x57,%edx
  800b64:	eb d3                	jmp    800b39 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b66:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b69:	89 f3                	mov    %esi,%ebx
  800b6b:	80 fb 19             	cmp    $0x19,%bl
  800b6e:	77 08                	ja     800b78 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b70:	0f be d2             	movsbl %dl,%edx
  800b73:	83 ea 37             	sub    $0x37,%edx
  800b76:	eb c1                	jmp    800b39 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b78:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b7c:	74 05                	je     800b83 <strtol+0xd0>
		*endptr = (char *) s;
  800b7e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b81:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b83:	89 c2                	mov    %eax,%edx
  800b85:	f7 da                	neg    %edx
  800b87:	85 ff                	test   %edi,%edi
  800b89:	0f 45 c2             	cmovne %edx,%eax
}
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b91:	f3 0f 1e fb          	endbr32 
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	57                   	push   %edi
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba6:	89 c3                	mov    %eax,%ebx
  800ba8:	89 c7                	mov    %eax,%edi
  800baa:	89 c6                	mov    %eax,%esi
  800bac:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bb3:	f3 0f 1e fb          	endbr32 
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc2:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc7:	89 d1                	mov    %edx,%ecx
  800bc9:	89 d3                	mov    %edx,%ebx
  800bcb:	89 d7                	mov    %edx,%edi
  800bcd:	89 d6                	mov    %edx,%esi
  800bcf:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd6:	f3 0f 1e fb          	endbr32 
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800be3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf0:	89 cb                	mov    %ecx,%ebx
  800bf2:	89 cf                	mov    %ecx,%edi
  800bf4:	89 ce                	mov    %ecx,%esi
  800bf6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bf8:	85 c0                	test   %eax,%eax
  800bfa:	7f 08                	jg     800c04 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	50                   	push   %eax
  800c08:	6a 03                	push   $0x3
  800c0a:	68 ff 25 80 00       	push   $0x8025ff
  800c0f:	6a 23                	push   $0x23
  800c11:	68 1c 26 80 00       	push   $0x80261c
  800c16:	e8 e2 12 00 00       	call   801efd <_panic>

00800c1b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c1b:	f3 0f 1e fb          	endbr32 
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c25:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c2f:	89 d1                	mov    %edx,%ecx
  800c31:	89 d3                	mov    %edx,%ebx
  800c33:	89 d7                	mov    %edx,%edi
  800c35:	89 d6                	mov    %edx,%esi
  800c37:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <sys_yield>:

void
sys_yield(void)
{
  800c3e:	f3 0f 1e fb          	endbr32 
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c48:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c52:	89 d1                	mov    %edx,%ecx
  800c54:	89 d3                	mov    %edx,%ebx
  800c56:	89 d7                	mov    %edx,%edi
  800c58:	89 d6                	mov    %edx,%esi
  800c5a:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c61:	f3 0f 1e fb          	endbr32 
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c6e:	be 00 00 00 00       	mov    $0x0,%esi
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c79:	b8 04 00 00 00       	mov    $0x4,%eax
  800c7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c81:	89 f7                	mov    %esi,%edi
  800c83:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c85:	85 c0                	test   %eax,%eax
  800c87:	7f 08                	jg     800c91 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c91:	83 ec 0c             	sub    $0xc,%esp
  800c94:	50                   	push   %eax
  800c95:	6a 04                	push   $0x4
  800c97:	68 ff 25 80 00       	push   $0x8025ff
  800c9c:	6a 23                	push   $0x23
  800c9e:	68 1c 26 80 00       	push   $0x80261c
  800ca3:	e8 55 12 00 00       	call   801efd <_panic>

00800ca8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca8:	f3 0f 1e fb          	endbr32 
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	53                   	push   %ebx
  800cb2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	b8 05 00 00 00       	mov    $0x5,%eax
  800cc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc6:	8b 75 18             	mov    0x18(%ebp),%esi
  800cc9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	7f 08                	jg     800cd7 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ccf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd7:	83 ec 0c             	sub    $0xc,%esp
  800cda:	50                   	push   %eax
  800cdb:	6a 05                	push   $0x5
  800cdd:	68 ff 25 80 00       	push   $0x8025ff
  800ce2:	6a 23                	push   $0x23
  800ce4:	68 1c 26 80 00       	push   $0x80261c
  800ce9:	e8 0f 12 00 00       	call   801efd <_panic>

00800cee <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cee:	f3 0f 1e fb          	endbr32 
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	57                   	push   %edi
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
  800cf8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d06:	b8 06 00 00 00       	mov    $0x6,%eax
  800d0b:	89 df                	mov    %ebx,%edi
  800d0d:	89 de                	mov    %ebx,%esi
  800d0f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d11:	85 c0                	test   %eax,%eax
  800d13:	7f 08                	jg     800d1d <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1d:	83 ec 0c             	sub    $0xc,%esp
  800d20:	50                   	push   %eax
  800d21:	6a 06                	push   $0x6
  800d23:	68 ff 25 80 00       	push   $0x8025ff
  800d28:	6a 23                	push   $0x23
  800d2a:	68 1c 26 80 00       	push   $0x80261c
  800d2f:	e8 c9 11 00 00       	call   801efd <_panic>

00800d34 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d34:	f3 0f 1e fb          	endbr32 
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	57                   	push   %edi
  800d3c:	56                   	push   %esi
  800d3d:	53                   	push   %ebx
  800d3e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d41:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4c:	b8 08 00 00 00       	mov    $0x8,%eax
  800d51:	89 df                	mov    %ebx,%edi
  800d53:	89 de                	mov    %ebx,%esi
  800d55:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d57:	85 c0                	test   %eax,%eax
  800d59:	7f 08                	jg     800d63 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	50                   	push   %eax
  800d67:	6a 08                	push   $0x8
  800d69:	68 ff 25 80 00       	push   $0x8025ff
  800d6e:	6a 23                	push   $0x23
  800d70:	68 1c 26 80 00       	push   $0x80261c
  800d75:	e8 83 11 00 00       	call   801efd <_panic>

00800d7a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d7a:	f3 0f 1e fb          	endbr32 
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d87:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d92:	b8 09 00 00 00       	mov    $0x9,%eax
  800d97:	89 df                	mov    %ebx,%edi
  800d99:	89 de                	mov    %ebx,%esi
  800d9b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	7f 08                	jg     800da9 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800da1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da9:	83 ec 0c             	sub    $0xc,%esp
  800dac:	50                   	push   %eax
  800dad:	6a 09                	push   $0x9
  800daf:	68 ff 25 80 00       	push   $0x8025ff
  800db4:	6a 23                	push   $0x23
  800db6:	68 1c 26 80 00       	push   $0x80261c
  800dbb:	e8 3d 11 00 00       	call   801efd <_panic>

00800dc0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dc0:	f3 0f 1e fb          	endbr32 
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dcd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ddd:	89 df                	mov    %ebx,%edi
  800ddf:	89 de                	mov    %ebx,%esi
  800de1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800de3:	85 c0                	test   %eax,%eax
  800de5:	7f 08                	jg     800def <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800de7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dea:	5b                   	pop    %ebx
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800def:	83 ec 0c             	sub    $0xc,%esp
  800df2:	50                   	push   %eax
  800df3:	6a 0a                	push   $0xa
  800df5:	68 ff 25 80 00       	push   $0x8025ff
  800dfa:	6a 23                	push   $0x23
  800dfc:	68 1c 26 80 00       	push   $0x80261c
  800e01:	e8 f7 10 00 00       	call   801efd <_panic>

00800e06 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e06:	f3 0f 1e fb          	endbr32 
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e10:	8b 55 08             	mov    0x8(%ebp),%edx
  800e13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e16:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e1b:	be 00 00 00 00       	mov    $0x0,%esi
  800e20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e23:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e26:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e2d:	f3 0f 1e fb          	endbr32 
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	57                   	push   %edi
  800e35:	56                   	push   %esi
  800e36:	53                   	push   %ebx
  800e37:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e3a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e42:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e47:	89 cb                	mov    %ecx,%ebx
  800e49:	89 cf                	mov    %ecx,%edi
  800e4b:	89 ce                	mov    %ecx,%esi
  800e4d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	7f 08                	jg     800e5b <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e56:	5b                   	pop    %ebx
  800e57:	5e                   	pop    %esi
  800e58:	5f                   	pop    %edi
  800e59:	5d                   	pop    %ebp
  800e5a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5b:	83 ec 0c             	sub    $0xc,%esp
  800e5e:	50                   	push   %eax
  800e5f:	6a 0d                	push   $0xd
  800e61:	68 ff 25 80 00       	push   $0x8025ff
  800e66:	6a 23                	push   $0x23
  800e68:	68 1c 26 80 00       	push   $0x80261c
  800e6d:	e8 8b 10 00 00       	call   801efd <_panic>

00800e72 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e72:	f3 0f 1e fb          	endbr32 
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	53                   	push   %ebx
  800e7a:	83 ec 04             	sub    $0x4,%esp
  800e7d:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e80:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if ( !(err & FEC_WR) ||
  800e82:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e86:	74 75                	je     800efd <pgfault+0x8b>
            !(uvpt[PGNUM(addr)] | PTE_COW) ) {
  800e88:	89 d8                	mov    %ebx,%eax
  800e8a:	c1 e8 0c             	shr    $0xc,%eax
  800e8d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0) {
  800e94:	83 ec 04             	sub    $0x4,%esp
  800e97:	6a 07                	push   $0x7
  800e99:	68 00 f0 7f 00       	push   $0x7ff000
  800e9e:	6a 00                	push   $0x0
  800ea0:	e8 bc fd ff ff       	call   800c61 <sys_page_alloc>
  800ea5:	83 c4 10             	add    $0x10,%esp
  800ea8:	85 c0                	test   %eax,%eax
  800eaa:	78 65                	js     800f11 <pgfault+0x9f>
        panic("sys_page_alloc failed %e\n", r);
    }
    memmove((void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);
  800eac:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800eb2:	83 ec 04             	sub    $0x4,%esp
  800eb5:	68 00 10 00 00       	push   $0x1000
  800eba:	53                   	push   %ebx
  800ebb:	68 00 f0 7f 00       	push   $0x7ff000
  800ec0:	e8 10 fb ff ff       	call   8009d5 <memmove>
    if ((r = sys_page_map(0, (void *)PFTEMP,
  800ec5:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ecc:	53                   	push   %ebx
  800ecd:	6a 00                	push   $0x0
  800ecf:	68 00 f0 7f 00       	push   $0x7ff000
  800ed4:	6a 00                	push   $0x0
  800ed6:	e8 cd fd ff ff       	call   800ca8 <sys_page_map>
  800edb:	83 c4 20             	add    $0x20,%esp
  800ede:	85 c0                	test   %eax,%eax
  800ee0:	78 41                	js     800f23 <pgfault+0xb1>
                0, (void *)PTE_ADDR(addr), PTE_P | PTE_U | PTE_W)) < 0) {
        panic("sys_page_map failed %e\n", r);
    }
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0) {
  800ee2:	83 ec 08             	sub    $0x8,%esp
  800ee5:	68 00 f0 7f 00       	push   $0x7ff000
  800eea:	6a 00                	push   $0x0
  800eec:	e8 fd fd ff ff       	call   800cee <sys_page_unmap>
  800ef1:	83 c4 10             	add    $0x10,%esp
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	78 3d                	js     800f35 <pgfault+0xc3>
        panic("sys_page_unmap failed %e\n", r);
    }

}
  800ef8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800efb:	c9                   	leave  
  800efc:	c3                   	ret    
        panic("Not a copy-on-write page");
  800efd:	83 ec 04             	sub    $0x4,%esp
  800f00:	68 2a 26 80 00       	push   $0x80262a
  800f05:	6a 1e                	push   $0x1e
  800f07:	68 43 26 80 00       	push   $0x802643
  800f0c:	e8 ec 0f 00 00       	call   801efd <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800f11:	50                   	push   %eax
  800f12:	68 4e 26 80 00       	push   $0x80264e
  800f17:	6a 2a                	push   $0x2a
  800f19:	68 43 26 80 00       	push   $0x802643
  800f1e:	e8 da 0f 00 00       	call   801efd <_panic>
        panic("sys_page_map failed %e\n", r);
  800f23:	50                   	push   %eax
  800f24:	68 68 26 80 00       	push   $0x802668
  800f29:	6a 2f                	push   $0x2f
  800f2b:	68 43 26 80 00       	push   $0x802643
  800f30:	e8 c8 0f 00 00       	call   801efd <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800f35:	50                   	push   %eax
  800f36:	68 80 26 80 00       	push   $0x802680
  800f3b:	6a 32                	push   $0x32
  800f3d:	68 43 26 80 00       	push   $0x802643
  800f42:	e8 b6 0f 00 00       	call   801efd <_panic>

00800f47 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f47:	f3 0f 1e fb          	endbr32 
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	57                   	push   %edi
  800f4f:	56                   	push   %esi
  800f50:	53                   	push   %ebx
  800f51:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");

    // 1. set pgfault handler.
    set_pgfault_handler(pgfault);
  800f54:	68 72 0e 80 00       	push   $0x800e72
  800f59:	e8 e9 0f 00 00       	call   801f47 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f5e:	b8 07 00 00 00       	mov    $0x7,%eax
  800f63:	cd 30                	int    $0x30
  800f65:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f68:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 2. exofork.
    envid_t envid = sys_exofork();

    if (envid < 0)
  800f6b:	83 c4 10             	add    $0x10,%esp
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	78 2a                	js     800f9c <fork+0x55>
        thisenv = &envs[ENVX(my_envid)];
        return 0;
    }
    else {
        // parent
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f72:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800f77:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f7b:	75 69                	jne    800fe6 <fork+0x9f>
        envid_t my_envid = sys_getenvid();
  800f7d:	e8 99 fc ff ff       	call   800c1b <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800f82:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f87:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f8a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f8f:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  800f94:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f97:	e9 fc 00 00 00       	jmp    801098 <fork+0x151>
        panic("fork, sys_exofork %e", envid);
  800f9c:	50                   	push   %eax
  800f9d:	68 9a 26 80 00       	push   $0x80269a
  800fa2:	6a 7b                	push   $0x7b
  800fa4:	68 43 26 80 00       	push   $0x802643
  800fa9:	e8 4f 0f 00 00       	call   801efd <_panic>
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  800fae:	83 ec 0c             	sub    $0xc,%esp
  800fb1:	57                   	push   %edi
  800fb2:	56                   	push   %esi
  800fb3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb6:	56                   	push   %esi
  800fb7:	6a 00                	push   $0x0
  800fb9:	e8 ea fc ff ff       	call   800ca8 <sys_page_map>
  800fbe:	83 c4 20             	add    $0x20,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	78 69                	js     80102e <fork+0xe7>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  800fc5:	83 ec 0c             	sub    $0xc,%esp
  800fc8:	57                   	push   %edi
  800fc9:	56                   	push   %esi
  800fca:	6a 00                	push   $0x0
  800fcc:	56                   	push   %esi
  800fcd:	6a 00                	push   $0x0
  800fcf:	e8 d4 fc ff ff       	call   800ca8 <sys_page_map>
  800fd4:	83 c4 20             	add    $0x20,%esp
  800fd7:	85 c0                	test   %eax,%eax
  800fd9:	78 65                	js     801040 <fork+0xf9>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800fdb:	83 c3 01             	add    $0x1,%ebx
  800fde:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800fe4:	74 6c                	je     801052 <fork+0x10b>
  800fe6:	89 de                	mov    %ebx,%esi
  800fe8:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800feb:	89 f0                	mov    %esi,%eax
  800fed:	c1 e8 16             	shr    $0x16,%eax
  800ff0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff7:	a8 01                	test   $0x1,%al
  800ff9:	74 e0                	je     800fdb <fork+0x94>
                    (uvpt[pn] & PTE_P) ) {
  800ffb:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  801002:	a8 01                	test   $0x1,%al
  801004:	74 d5                	je     800fdb <fork+0x94>
    pte_t pte = uvpt[pn];
  801006:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    int perm = PTE_U | PTE_P;
  80100d:	bf 05 00 00 00       	mov    $0x5,%edi
    if ( ((pte & PTE_W) || (pte & PTE_COW)) && !(pte & PTE_SHARE)) {
  801012:	a9 02 08 00 00       	test   $0x802,%eax
  801017:	74 95                	je     800fae <fork+0x67>
  801019:	25 00 04 00 00       	and    $0x400,%eax
        perm |= PTE_COW;
  80101e:	83 f8 01             	cmp    $0x1,%eax
  801021:	19 ff                	sbb    %edi,%edi
  801023:	81 e7 00 08 00 00    	and    $0x800,%edi
  801029:	83 c7 05             	add    $0x5,%edi
  80102c:	eb 80                	jmp    800fae <fork+0x67>
        panic("sys_page_map others failed %e\n", r);
  80102e:	50                   	push   %eax
  80102f:	68 e4 26 80 00       	push   $0x8026e4
  801034:	6a 51                	push   $0x51
  801036:	68 43 26 80 00       	push   $0x802643
  80103b:	e8 bd 0e 00 00       	call   801efd <_panic>
            panic("sys_page_map mine failed %e\n", r);
  801040:	50                   	push   %eax
  801041:	68 af 26 80 00       	push   $0x8026af
  801046:	6a 56                	push   $0x56
  801048:	68 43 26 80 00       	push   $0x802643
  80104d:	e8 ab 0e 00 00       	call   801efd <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  801052:	83 ec 04             	sub    $0x4,%esp
  801055:	6a 07                	push   $0x7
  801057:	68 00 f0 bf ee       	push   $0xeebff000
  80105c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80105f:	57                   	push   %edi
  801060:	e8 fc fb ff ff       	call   800c61 <sys_page_alloc>
  801065:	83 c4 10             	add    $0x10,%esp
  801068:	85 c0                	test   %eax,%eax
  80106a:	78 2c                	js     801098 <fork+0x151>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  80106c:	a1 08 40 80 00       	mov    0x804008,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  801071:	8b 40 64             	mov    0x64(%eax),%eax
  801074:	83 ec 08             	sub    $0x8,%esp
  801077:	50                   	push   %eax
  801078:	57                   	push   %edi
  801079:	e8 42 fd ff ff       	call   800dc0 <sys_env_set_pgfault_upcall>
  80107e:	83 c4 10             	add    $0x10,%esp
  801081:	85 c0                	test   %eax,%eax
  801083:	78 13                	js     801098 <fork+0x151>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801085:	83 ec 08             	sub    $0x8,%esp
  801088:	6a 02                	push   $0x2
  80108a:	57                   	push   %edi
  80108b:	e8 a4 fc ff ff       	call   800d34 <sys_env_set_status>
  801090:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  801093:	85 c0                	test   %eax,%eax
  801095:	0f 49 c7             	cmovns %edi,%eax
    }

}
  801098:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80109b:	5b                   	pop    %ebx
  80109c:	5e                   	pop    %esi
  80109d:	5f                   	pop    %edi
  80109e:	5d                   	pop    %ebp
  80109f:	c3                   	ret    

008010a0 <sfork>:

// Challenge!
int
sfork(void)
{
  8010a0:	f3 0f 1e fb          	endbr32 
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010aa:	68 cc 26 80 00       	push   $0x8026cc
  8010af:	68 a5 00 00 00       	push   $0xa5
  8010b4:	68 43 26 80 00       	push   $0x802643
  8010b9:	e8 3f 0e 00 00       	call   801efd <_panic>

008010be <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010be:	f3 0f 1e fb          	endbr32 
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	56                   	push   %esi
  8010c6:	53                   	push   %ebx
  8010c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8010ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010cd:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8010d7:	0f 44 c2             	cmove  %edx,%eax
  8010da:	83 ec 0c             	sub    $0xc,%esp
  8010dd:	50                   	push   %eax
  8010de:	e8 4a fd ff ff       	call   800e2d <sys_ipc_recv>
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	78 24                	js     80110e <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  8010ea:	85 f6                	test   %esi,%esi
  8010ec:	74 0a                	je     8010f8 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  8010ee:	a1 08 40 80 00       	mov    0x804008,%eax
  8010f3:	8b 40 78             	mov    0x78(%eax),%eax
  8010f6:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  8010f8:	85 db                	test   %ebx,%ebx
  8010fa:	74 0a                	je     801106 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  8010fc:	a1 08 40 80 00       	mov    0x804008,%eax
  801101:	8b 40 74             	mov    0x74(%eax),%eax
  801104:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801106:	a1 08 40 80 00       	mov    0x804008,%eax
  80110b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80110e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801111:	5b                   	pop    %ebx
  801112:	5e                   	pop    %esi
  801113:	5d                   	pop    %ebp
  801114:	c3                   	ret    

00801115 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801115:	f3 0f 1e fb          	endbr32 
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	57                   	push   %edi
  80111d:	56                   	push   %esi
  80111e:	53                   	push   %ebx
  80111f:	83 ec 1c             	sub    $0x1c,%esp
  801122:	8b 45 10             	mov    0x10(%ebp),%eax
  801125:	85 c0                	test   %eax,%eax
  801127:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80112c:	0f 45 d0             	cmovne %eax,%edx
  80112f:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801131:	be 01 00 00 00       	mov    $0x1,%esi
  801136:	eb 1f                	jmp    801157 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801138:	e8 01 fb ff ff       	call   800c3e <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  80113d:	83 c3 01             	add    $0x1,%ebx
  801140:	39 de                	cmp    %ebx,%esi
  801142:	7f f4                	jg     801138 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801144:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801146:	83 fe 11             	cmp    $0x11,%esi
  801149:	b8 01 00 00 00       	mov    $0x1,%eax
  80114e:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801151:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801155:	75 1c                	jne    801173 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801157:	ff 75 14             	pushl  0x14(%ebp)
  80115a:	57                   	push   %edi
  80115b:	ff 75 0c             	pushl  0xc(%ebp)
  80115e:	ff 75 08             	pushl  0x8(%ebp)
  801161:	e8 a0 fc ff ff       	call   800e06 <sys_ipc_try_send>
  801166:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801171:	eb cd                	jmp    801140 <ipc_send+0x2b>
}
  801173:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801176:	5b                   	pop    %ebx
  801177:	5e                   	pop    %esi
  801178:	5f                   	pop    %edi
  801179:	5d                   	pop    %ebp
  80117a:	c3                   	ret    

0080117b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80117b:	f3 0f 1e fb          	endbr32 
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801185:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80118a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80118d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801193:	8b 52 50             	mov    0x50(%edx),%edx
  801196:	39 ca                	cmp    %ecx,%edx
  801198:	74 11                	je     8011ab <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  80119a:	83 c0 01             	add    $0x1,%eax
  80119d:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011a2:	75 e6                	jne    80118a <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8011a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a9:	eb 0b                	jmp    8011b6 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8011ab:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011ae:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011b3:	8b 40 48             	mov    0x48(%eax),%eax
}
  8011b6:	5d                   	pop    %ebp
  8011b7:	c3                   	ret    

008011b8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011b8:	f3 0f 1e fb          	endbr32 
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c2:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c7:	c1 e8 0c             	shr    $0xc,%eax
}
  8011ca:	5d                   	pop    %ebp
  8011cb:	c3                   	ret    

008011cc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011cc:	f3 0f 1e fb          	endbr32 
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011e0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011e7:	f3 0f 1e fb          	endbr32 
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011f3:	89 c2                	mov    %eax,%edx
  8011f5:	c1 ea 16             	shr    $0x16,%edx
  8011f8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ff:	f6 c2 01             	test   $0x1,%dl
  801202:	74 2d                	je     801231 <fd_alloc+0x4a>
  801204:	89 c2                	mov    %eax,%edx
  801206:	c1 ea 0c             	shr    $0xc,%edx
  801209:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801210:	f6 c2 01             	test   $0x1,%dl
  801213:	74 1c                	je     801231 <fd_alloc+0x4a>
  801215:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80121a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80121f:	75 d2                	jne    8011f3 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801221:	8b 45 08             	mov    0x8(%ebp),%eax
  801224:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80122a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80122f:	eb 0a                	jmp    80123b <fd_alloc+0x54>
			*fd_store = fd;
  801231:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801234:	89 01                	mov    %eax,(%ecx)
			return 0;
  801236:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80123b:	5d                   	pop    %ebp
  80123c:	c3                   	ret    

0080123d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80123d:	f3 0f 1e fb          	endbr32 
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801247:	83 f8 1f             	cmp    $0x1f,%eax
  80124a:	77 30                	ja     80127c <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80124c:	c1 e0 0c             	shl    $0xc,%eax
  80124f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801254:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80125a:	f6 c2 01             	test   $0x1,%dl
  80125d:	74 24                	je     801283 <fd_lookup+0x46>
  80125f:	89 c2                	mov    %eax,%edx
  801261:	c1 ea 0c             	shr    $0xc,%edx
  801264:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80126b:	f6 c2 01             	test   $0x1,%dl
  80126e:	74 1a                	je     80128a <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801270:	8b 55 0c             	mov    0xc(%ebp),%edx
  801273:	89 02                	mov    %eax,(%edx)
	return 0;
  801275:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80127a:	5d                   	pop    %ebp
  80127b:	c3                   	ret    
		return -E_INVAL;
  80127c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801281:	eb f7                	jmp    80127a <fd_lookup+0x3d>
		return -E_INVAL;
  801283:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801288:	eb f0                	jmp    80127a <fd_lookup+0x3d>
  80128a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128f:	eb e9                	jmp    80127a <fd_lookup+0x3d>

00801291 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801291:	f3 0f 1e fb          	endbr32 
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	83 ec 08             	sub    $0x8,%esp
  80129b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80129e:	ba 80 27 80 00       	mov    $0x802780,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012a3:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8012a8:	39 08                	cmp    %ecx,(%eax)
  8012aa:	74 33                	je     8012df <dev_lookup+0x4e>
  8012ac:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8012af:	8b 02                	mov    (%edx),%eax
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	75 f3                	jne    8012a8 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012b5:	a1 08 40 80 00       	mov    0x804008,%eax
  8012ba:	8b 40 48             	mov    0x48(%eax),%eax
  8012bd:	83 ec 04             	sub    $0x4,%esp
  8012c0:	51                   	push   %ecx
  8012c1:	50                   	push   %eax
  8012c2:	68 04 27 80 00       	push   $0x802704
  8012c7:	e8 4a ef ff ff       	call   800216 <cprintf>
	*dev = 0;
  8012cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012d5:	83 c4 10             	add    $0x10,%esp
  8012d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012dd:	c9                   	leave  
  8012de:	c3                   	ret    
			*dev = devtab[i];
  8012df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e9:	eb f2                	jmp    8012dd <dev_lookup+0x4c>

008012eb <fd_close>:
{
  8012eb:	f3 0f 1e fb          	endbr32 
  8012ef:	55                   	push   %ebp
  8012f0:	89 e5                	mov    %esp,%ebp
  8012f2:	57                   	push   %edi
  8012f3:	56                   	push   %esi
  8012f4:	53                   	push   %ebx
  8012f5:	83 ec 24             	sub    $0x24,%esp
  8012f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8012fb:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012fe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801301:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801302:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801308:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80130b:	50                   	push   %eax
  80130c:	e8 2c ff ff ff       	call   80123d <fd_lookup>
  801311:	89 c3                	mov    %eax,%ebx
  801313:	83 c4 10             	add    $0x10,%esp
  801316:	85 c0                	test   %eax,%eax
  801318:	78 05                	js     80131f <fd_close+0x34>
	    || fd != fd2)
  80131a:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80131d:	74 16                	je     801335 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80131f:	89 f8                	mov    %edi,%eax
  801321:	84 c0                	test   %al,%al
  801323:	b8 00 00 00 00       	mov    $0x0,%eax
  801328:	0f 44 d8             	cmove  %eax,%ebx
}
  80132b:	89 d8                	mov    %ebx,%eax
  80132d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801330:	5b                   	pop    %ebx
  801331:	5e                   	pop    %esi
  801332:	5f                   	pop    %edi
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801335:	83 ec 08             	sub    $0x8,%esp
  801338:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80133b:	50                   	push   %eax
  80133c:	ff 36                	pushl  (%esi)
  80133e:	e8 4e ff ff ff       	call   801291 <dev_lookup>
  801343:	89 c3                	mov    %eax,%ebx
  801345:	83 c4 10             	add    $0x10,%esp
  801348:	85 c0                	test   %eax,%eax
  80134a:	78 1a                	js     801366 <fd_close+0x7b>
		if (dev->dev_close)
  80134c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80134f:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801352:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801357:	85 c0                	test   %eax,%eax
  801359:	74 0b                	je     801366 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80135b:	83 ec 0c             	sub    $0xc,%esp
  80135e:	56                   	push   %esi
  80135f:	ff d0                	call   *%eax
  801361:	89 c3                	mov    %eax,%ebx
  801363:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	56                   	push   %esi
  80136a:	6a 00                	push   $0x0
  80136c:	e8 7d f9 ff ff       	call   800cee <sys_page_unmap>
	return r;
  801371:	83 c4 10             	add    $0x10,%esp
  801374:	eb b5                	jmp    80132b <fd_close+0x40>

00801376 <close>:

int
close(int fdnum)
{
  801376:	f3 0f 1e fb          	endbr32 
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801380:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801383:	50                   	push   %eax
  801384:	ff 75 08             	pushl  0x8(%ebp)
  801387:	e8 b1 fe ff ff       	call   80123d <fd_lookup>
  80138c:	83 c4 10             	add    $0x10,%esp
  80138f:	85 c0                	test   %eax,%eax
  801391:	79 02                	jns    801395 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801393:	c9                   	leave  
  801394:	c3                   	ret    
		return fd_close(fd, 1);
  801395:	83 ec 08             	sub    $0x8,%esp
  801398:	6a 01                	push   $0x1
  80139a:	ff 75 f4             	pushl  -0xc(%ebp)
  80139d:	e8 49 ff ff ff       	call   8012eb <fd_close>
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	eb ec                	jmp    801393 <close+0x1d>

008013a7 <close_all>:

void
close_all(void)
{
  8013a7:	f3 0f 1e fb          	endbr32 
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	53                   	push   %ebx
  8013af:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013b7:	83 ec 0c             	sub    $0xc,%esp
  8013ba:	53                   	push   %ebx
  8013bb:	e8 b6 ff ff ff       	call   801376 <close>
	for (i = 0; i < MAXFD; i++)
  8013c0:	83 c3 01             	add    $0x1,%ebx
  8013c3:	83 c4 10             	add    $0x10,%esp
  8013c6:	83 fb 20             	cmp    $0x20,%ebx
  8013c9:	75 ec                	jne    8013b7 <close_all+0x10>
}
  8013cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ce:	c9                   	leave  
  8013cf:	c3                   	ret    

008013d0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013d0:	f3 0f 1e fb          	endbr32 
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	57                   	push   %edi
  8013d8:	56                   	push   %esi
  8013d9:	53                   	push   %ebx
  8013da:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013dd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013e0:	50                   	push   %eax
  8013e1:	ff 75 08             	pushl  0x8(%ebp)
  8013e4:	e8 54 fe ff ff       	call   80123d <fd_lookup>
  8013e9:	89 c3                	mov    %eax,%ebx
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	0f 88 81 00 00 00    	js     801477 <dup+0xa7>
		return r;
	close(newfdnum);
  8013f6:	83 ec 0c             	sub    $0xc,%esp
  8013f9:	ff 75 0c             	pushl  0xc(%ebp)
  8013fc:	e8 75 ff ff ff       	call   801376 <close>

	newfd = INDEX2FD(newfdnum);
  801401:	8b 75 0c             	mov    0xc(%ebp),%esi
  801404:	c1 e6 0c             	shl    $0xc,%esi
  801407:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80140d:	83 c4 04             	add    $0x4,%esp
  801410:	ff 75 e4             	pushl  -0x1c(%ebp)
  801413:	e8 b4 fd ff ff       	call   8011cc <fd2data>
  801418:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80141a:	89 34 24             	mov    %esi,(%esp)
  80141d:	e8 aa fd ff ff       	call   8011cc <fd2data>
  801422:	83 c4 10             	add    $0x10,%esp
  801425:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801427:	89 d8                	mov    %ebx,%eax
  801429:	c1 e8 16             	shr    $0x16,%eax
  80142c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801433:	a8 01                	test   $0x1,%al
  801435:	74 11                	je     801448 <dup+0x78>
  801437:	89 d8                	mov    %ebx,%eax
  801439:	c1 e8 0c             	shr    $0xc,%eax
  80143c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801443:	f6 c2 01             	test   $0x1,%dl
  801446:	75 39                	jne    801481 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801448:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80144b:	89 d0                	mov    %edx,%eax
  80144d:	c1 e8 0c             	shr    $0xc,%eax
  801450:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801457:	83 ec 0c             	sub    $0xc,%esp
  80145a:	25 07 0e 00 00       	and    $0xe07,%eax
  80145f:	50                   	push   %eax
  801460:	56                   	push   %esi
  801461:	6a 00                	push   $0x0
  801463:	52                   	push   %edx
  801464:	6a 00                	push   $0x0
  801466:	e8 3d f8 ff ff       	call   800ca8 <sys_page_map>
  80146b:	89 c3                	mov    %eax,%ebx
  80146d:	83 c4 20             	add    $0x20,%esp
  801470:	85 c0                	test   %eax,%eax
  801472:	78 31                	js     8014a5 <dup+0xd5>
		goto err;

	return newfdnum;
  801474:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801477:	89 d8                	mov    %ebx,%eax
  801479:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80147c:	5b                   	pop    %ebx
  80147d:	5e                   	pop    %esi
  80147e:	5f                   	pop    %edi
  80147f:	5d                   	pop    %ebp
  801480:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801481:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801488:	83 ec 0c             	sub    $0xc,%esp
  80148b:	25 07 0e 00 00       	and    $0xe07,%eax
  801490:	50                   	push   %eax
  801491:	57                   	push   %edi
  801492:	6a 00                	push   $0x0
  801494:	53                   	push   %ebx
  801495:	6a 00                	push   $0x0
  801497:	e8 0c f8 ff ff       	call   800ca8 <sys_page_map>
  80149c:	89 c3                	mov    %eax,%ebx
  80149e:	83 c4 20             	add    $0x20,%esp
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	79 a3                	jns    801448 <dup+0x78>
	sys_page_unmap(0, newfd);
  8014a5:	83 ec 08             	sub    $0x8,%esp
  8014a8:	56                   	push   %esi
  8014a9:	6a 00                	push   $0x0
  8014ab:	e8 3e f8 ff ff       	call   800cee <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014b0:	83 c4 08             	add    $0x8,%esp
  8014b3:	57                   	push   %edi
  8014b4:	6a 00                	push   $0x0
  8014b6:	e8 33 f8 ff ff       	call   800cee <sys_page_unmap>
	return r;
  8014bb:	83 c4 10             	add    $0x10,%esp
  8014be:	eb b7                	jmp    801477 <dup+0xa7>

008014c0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014c0:	f3 0f 1e fb          	endbr32 
  8014c4:	55                   	push   %ebp
  8014c5:	89 e5                	mov    %esp,%ebp
  8014c7:	53                   	push   %ebx
  8014c8:	83 ec 1c             	sub    $0x1c,%esp
  8014cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d1:	50                   	push   %eax
  8014d2:	53                   	push   %ebx
  8014d3:	e8 65 fd ff ff       	call   80123d <fd_lookup>
  8014d8:	83 c4 10             	add    $0x10,%esp
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	78 3f                	js     80151e <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014df:	83 ec 08             	sub    $0x8,%esp
  8014e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e5:	50                   	push   %eax
  8014e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e9:	ff 30                	pushl  (%eax)
  8014eb:	e8 a1 fd ff ff       	call   801291 <dev_lookup>
  8014f0:	83 c4 10             	add    $0x10,%esp
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	78 27                	js     80151e <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014fa:	8b 42 08             	mov    0x8(%edx),%eax
  8014fd:	83 e0 03             	and    $0x3,%eax
  801500:	83 f8 01             	cmp    $0x1,%eax
  801503:	74 1e                	je     801523 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801505:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801508:	8b 40 08             	mov    0x8(%eax),%eax
  80150b:	85 c0                	test   %eax,%eax
  80150d:	74 35                	je     801544 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80150f:	83 ec 04             	sub    $0x4,%esp
  801512:	ff 75 10             	pushl  0x10(%ebp)
  801515:	ff 75 0c             	pushl  0xc(%ebp)
  801518:	52                   	push   %edx
  801519:	ff d0                	call   *%eax
  80151b:	83 c4 10             	add    $0x10,%esp
}
  80151e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801521:	c9                   	leave  
  801522:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801523:	a1 08 40 80 00       	mov    0x804008,%eax
  801528:	8b 40 48             	mov    0x48(%eax),%eax
  80152b:	83 ec 04             	sub    $0x4,%esp
  80152e:	53                   	push   %ebx
  80152f:	50                   	push   %eax
  801530:	68 45 27 80 00       	push   $0x802745
  801535:	e8 dc ec ff ff       	call   800216 <cprintf>
		return -E_INVAL;
  80153a:	83 c4 10             	add    $0x10,%esp
  80153d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801542:	eb da                	jmp    80151e <read+0x5e>
		return -E_NOT_SUPP;
  801544:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801549:	eb d3                	jmp    80151e <read+0x5e>

0080154b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80154b:	f3 0f 1e fb          	endbr32 
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	57                   	push   %edi
  801553:	56                   	push   %esi
  801554:	53                   	push   %ebx
  801555:	83 ec 0c             	sub    $0xc,%esp
  801558:	8b 7d 08             	mov    0x8(%ebp),%edi
  80155b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80155e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801563:	eb 02                	jmp    801567 <readn+0x1c>
  801565:	01 c3                	add    %eax,%ebx
  801567:	39 f3                	cmp    %esi,%ebx
  801569:	73 21                	jae    80158c <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80156b:	83 ec 04             	sub    $0x4,%esp
  80156e:	89 f0                	mov    %esi,%eax
  801570:	29 d8                	sub    %ebx,%eax
  801572:	50                   	push   %eax
  801573:	89 d8                	mov    %ebx,%eax
  801575:	03 45 0c             	add    0xc(%ebp),%eax
  801578:	50                   	push   %eax
  801579:	57                   	push   %edi
  80157a:	e8 41 ff ff ff       	call   8014c0 <read>
		if (m < 0)
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	85 c0                	test   %eax,%eax
  801584:	78 04                	js     80158a <readn+0x3f>
			return m;
		if (m == 0)
  801586:	75 dd                	jne    801565 <readn+0x1a>
  801588:	eb 02                	jmp    80158c <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80158a:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80158c:	89 d8                	mov    %ebx,%eax
  80158e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801591:	5b                   	pop    %ebx
  801592:	5e                   	pop    %esi
  801593:	5f                   	pop    %edi
  801594:	5d                   	pop    %ebp
  801595:	c3                   	ret    

00801596 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801596:	f3 0f 1e fb          	endbr32 
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	53                   	push   %ebx
  80159e:	83 ec 1c             	sub    $0x1c,%esp
  8015a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a7:	50                   	push   %eax
  8015a8:	53                   	push   %ebx
  8015a9:	e8 8f fc ff ff       	call   80123d <fd_lookup>
  8015ae:	83 c4 10             	add    $0x10,%esp
  8015b1:	85 c0                	test   %eax,%eax
  8015b3:	78 3a                	js     8015ef <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b5:	83 ec 08             	sub    $0x8,%esp
  8015b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bb:	50                   	push   %eax
  8015bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015bf:	ff 30                	pushl  (%eax)
  8015c1:	e8 cb fc ff ff       	call   801291 <dev_lookup>
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	78 22                	js     8015ef <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015d4:	74 1e                	je     8015f4 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d9:	8b 52 0c             	mov    0xc(%edx),%edx
  8015dc:	85 d2                	test   %edx,%edx
  8015de:	74 35                	je     801615 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015e0:	83 ec 04             	sub    $0x4,%esp
  8015e3:	ff 75 10             	pushl  0x10(%ebp)
  8015e6:	ff 75 0c             	pushl  0xc(%ebp)
  8015e9:	50                   	push   %eax
  8015ea:	ff d2                	call   *%edx
  8015ec:	83 c4 10             	add    $0x10,%esp
}
  8015ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f2:	c9                   	leave  
  8015f3:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f4:	a1 08 40 80 00       	mov    0x804008,%eax
  8015f9:	8b 40 48             	mov    0x48(%eax),%eax
  8015fc:	83 ec 04             	sub    $0x4,%esp
  8015ff:	53                   	push   %ebx
  801600:	50                   	push   %eax
  801601:	68 61 27 80 00       	push   $0x802761
  801606:	e8 0b ec ff ff       	call   800216 <cprintf>
		return -E_INVAL;
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801613:	eb da                	jmp    8015ef <write+0x59>
		return -E_NOT_SUPP;
  801615:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80161a:	eb d3                	jmp    8015ef <write+0x59>

0080161c <seek>:

int
seek(int fdnum, off_t offset)
{
  80161c:	f3 0f 1e fb          	endbr32 
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801626:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801629:	50                   	push   %eax
  80162a:	ff 75 08             	pushl  0x8(%ebp)
  80162d:	e8 0b fc ff ff       	call   80123d <fd_lookup>
  801632:	83 c4 10             	add    $0x10,%esp
  801635:	85 c0                	test   %eax,%eax
  801637:	78 0e                	js     801647 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801639:	8b 55 0c             	mov    0xc(%ebp),%edx
  80163c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80163f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801642:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801647:	c9                   	leave  
  801648:	c3                   	ret    

00801649 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801649:	f3 0f 1e fb          	endbr32 
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	53                   	push   %ebx
  801651:	83 ec 1c             	sub    $0x1c,%esp
  801654:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801657:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165a:	50                   	push   %eax
  80165b:	53                   	push   %ebx
  80165c:	e8 dc fb ff ff       	call   80123d <fd_lookup>
  801661:	83 c4 10             	add    $0x10,%esp
  801664:	85 c0                	test   %eax,%eax
  801666:	78 37                	js     80169f <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801668:	83 ec 08             	sub    $0x8,%esp
  80166b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166e:	50                   	push   %eax
  80166f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801672:	ff 30                	pushl  (%eax)
  801674:	e8 18 fc ff ff       	call   801291 <dev_lookup>
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	85 c0                	test   %eax,%eax
  80167e:	78 1f                	js     80169f <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801680:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801683:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801687:	74 1b                	je     8016a4 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801689:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80168c:	8b 52 18             	mov    0x18(%edx),%edx
  80168f:	85 d2                	test   %edx,%edx
  801691:	74 32                	je     8016c5 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801693:	83 ec 08             	sub    $0x8,%esp
  801696:	ff 75 0c             	pushl  0xc(%ebp)
  801699:	50                   	push   %eax
  80169a:	ff d2                	call   *%edx
  80169c:	83 c4 10             	add    $0x10,%esp
}
  80169f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a2:	c9                   	leave  
  8016a3:	c3                   	ret    
			thisenv->env_id, fdnum);
  8016a4:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016a9:	8b 40 48             	mov    0x48(%eax),%eax
  8016ac:	83 ec 04             	sub    $0x4,%esp
  8016af:	53                   	push   %ebx
  8016b0:	50                   	push   %eax
  8016b1:	68 24 27 80 00       	push   $0x802724
  8016b6:	e8 5b eb ff ff       	call   800216 <cprintf>
		return -E_INVAL;
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016c3:	eb da                	jmp    80169f <ftruncate+0x56>
		return -E_NOT_SUPP;
  8016c5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016ca:	eb d3                	jmp    80169f <ftruncate+0x56>

008016cc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016cc:	f3 0f 1e fb          	endbr32 
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	53                   	push   %ebx
  8016d4:	83 ec 1c             	sub    $0x1c,%esp
  8016d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016dd:	50                   	push   %eax
  8016de:	ff 75 08             	pushl  0x8(%ebp)
  8016e1:	e8 57 fb ff ff       	call   80123d <fd_lookup>
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	78 4b                	js     801738 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ed:	83 ec 08             	sub    $0x8,%esp
  8016f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f3:	50                   	push   %eax
  8016f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f7:	ff 30                	pushl  (%eax)
  8016f9:	e8 93 fb ff ff       	call   801291 <dev_lookup>
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	85 c0                	test   %eax,%eax
  801703:	78 33                	js     801738 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801705:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801708:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80170c:	74 2f                	je     80173d <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80170e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801711:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801718:	00 00 00 
	stat->st_isdir = 0;
  80171b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801722:	00 00 00 
	stat->st_dev = dev;
  801725:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80172b:	83 ec 08             	sub    $0x8,%esp
  80172e:	53                   	push   %ebx
  80172f:	ff 75 f0             	pushl  -0x10(%ebp)
  801732:	ff 50 14             	call   *0x14(%eax)
  801735:	83 c4 10             	add    $0x10,%esp
}
  801738:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173b:	c9                   	leave  
  80173c:	c3                   	ret    
		return -E_NOT_SUPP;
  80173d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801742:	eb f4                	jmp    801738 <fstat+0x6c>

00801744 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801744:	f3 0f 1e fb          	endbr32 
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	56                   	push   %esi
  80174c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80174d:	83 ec 08             	sub    $0x8,%esp
  801750:	6a 00                	push   $0x0
  801752:	ff 75 08             	pushl  0x8(%ebp)
  801755:	e8 fb 01 00 00       	call   801955 <open>
  80175a:	89 c3                	mov    %eax,%ebx
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 1b                	js     80177e <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801763:	83 ec 08             	sub    $0x8,%esp
  801766:	ff 75 0c             	pushl  0xc(%ebp)
  801769:	50                   	push   %eax
  80176a:	e8 5d ff ff ff       	call   8016cc <fstat>
  80176f:	89 c6                	mov    %eax,%esi
	close(fd);
  801771:	89 1c 24             	mov    %ebx,(%esp)
  801774:	e8 fd fb ff ff       	call   801376 <close>
	return r;
  801779:	83 c4 10             	add    $0x10,%esp
  80177c:	89 f3                	mov    %esi,%ebx
}
  80177e:	89 d8                	mov    %ebx,%eax
  801780:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801783:	5b                   	pop    %ebx
  801784:	5e                   	pop    %esi
  801785:	5d                   	pop    %ebp
  801786:	c3                   	ret    

00801787 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	56                   	push   %esi
  80178b:	53                   	push   %ebx
  80178c:	89 c6                	mov    %eax,%esi
  80178e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801790:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801797:	74 27                	je     8017c0 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801799:	6a 07                	push   $0x7
  80179b:	68 00 50 80 00       	push   $0x805000
  8017a0:	56                   	push   %esi
  8017a1:	ff 35 00 40 80 00    	pushl  0x804000
  8017a7:	e8 69 f9 ff ff       	call   801115 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017ac:	83 c4 0c             	add    $0xc,%esp
  8017af:	6a 00                	push   $0x0
  8017b1:	53                   	push   %ebx
  8017b2:	6a 00                	push   $0x0
  8017b4:	e8 05 f9 ff ff       	call   8010be <ipc_recv>
}
  8017b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017bc:	5b                   	pop    %ebx
  8017bd:	5e                   	pop    %esi
  8017be:	5d                   	pop    %ebp
  8017bf:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017c0:	83 ec 0c             	sub    $0xc,%esp
  8017c3:	6a 01                	push   $0x1
  8017c5:	e8 b1 f9 ff ff       	call   80117b <ipc_find_env>
  8017ca:	a3 00 40 80 00       	mov    %eax,0x804000
  8017cf:	83 c4 10             	add    $0x10,%esp
  8017d2:	eb c5                	jmp    801799 <fsipc+0x12>

008017d4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017d4:	f3 0f 1e fb          	endbr32 
  8017d8:	55                   	push   %ebp
  8017d9:	89 e5                	mov    %esp,%ebp
  8017db:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017de:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ec:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f6:	b8 02 00 00 00       	mov    $0x2,%eax
  8017fb:	e8 87 ff ff ff       	call   801787 <fsipc>
}
  801800:	c9                   	leave  
  801801:	c3                   	ret    

00801802 <devfile_flush>:
{
  801802:	f3 0f 1e fb          	endbr32 
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80180c:	8b 45 08             	mov    0x8(%ebp),%eax
  80180f:	8b 40 0c             	mov    0xc(%eax),%eax
  801812:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801817:	ba 00 00 00 00       	mov    $0x0,%edx
  80181c:	b8 06 00 00 00       	mov    $0x6,%eax
  801821:	e8 61 ff ff ff       	call   801787 <fsipc>
}
  801826:	c9                   	leave  
  801827:	c3                   	ret    

00801828 <devfile_stat>:
{
  801828:	f3 0f 1e fb          	endbr32 
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	53                   	push   %ebx
  801830:	83 ec 04             	sub    $0x4,%esp
  801833:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801836:	8b 45 08             	mov    0x8(%ebp),%eax
  801839:	8b 40 0c             	mov    0xc(%eax),%eax
  80183c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801841:	ba 00 00 00 00       	mov    $0x0,%edx
  801846:	b8 05 00 00 00       	mov    $0x5,%eax
  80184b:	e8 37 ff ff ff       	call   801787 <fsipc>
  801850:	85 c0                	test   %eax,%eax
  801852:	78 2c                	js     801880 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801854:	83 ec 08             	sub    $0x8,%esp
  801857:	68 00 50 80 00       	push   $0x805000
  80185c:	53                   	push   %ebx
  80185d:	e8 bd ef ff ff       	call   80081f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801862:	a1 80 50 80 00       	mov    0x805080,%eax
  801867:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80186d:	a1 84 50 80 00       	mov    0x805084,%eax
  801872:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801878:	83 c4 10             	add    $0x10,%esp
  80187b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801880:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801883:	c9                   	leave  
  801884:	c3                   	ret    

00801885 <devfile_write>:
{
  801885:	f3 0f 1e fb          	endbr32 
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
  80188c:	83 ec 0c             	sub    $0xc,%esp
  80188f:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  801892:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801897:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80189c:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80189f:	8b 55 08             	mov    0x8(%ebp),%edx
  8018a2:	8b 52 0c             	mov    0xc(%edx),%edx
  8018a5:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018ab:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018b0:	50                   	push   %eax
  8018b1:	ff 75 0c             	pushl  0xc(%ebp)
  8018b4:	68 08 50 80 00       	push   $0x805008
  8018b9:	e8 17 f1 ff ff       	call   8009d5 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018be:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c3:	b8 04 00 00 00       	mov    $0x4,%eax
  8018c8:	e8 ba fe ff ff       	call   801787 <fsipc>
}
  8018cd:	c9                   	leave  
  8018ce:	c3                   	ret    

008018cf <devfile_read>:
{
  8018cf:	f3 0f 1e fb          	endbr32 
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	56                   	push   %esi
  8018d7:	53                   	push   %ebx
  8018d8:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018db:	8b 45 08             	mov    0x8(%ebp),%eax
  8018de:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018e6:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f1:	b8 03 00 00 00       	mov    $0x3,%eax
  8018f6:	e8 8c fe ff ff       	call   801787 <fsipc>
  8018fb:	89 c3                	mov    %eax,%ebx
  8018fd:	85 c0                	test   %eax,%eax
  8018ff:	78 1f                	js     801920 <devfile_read+0x51>
	assert(r <= n);
  801901:	39 f0                	cmp    %esi,%eax
  801903:	77 24                	ja     801929 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801905:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80190a:	7f 33                	jg     80193f <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80190c:	83 ec 04             	sub    $0x4,%esp
  80190f:	50                   	push   %eax
  801910:	68 00 50 80 00       	push   $0x805000
  801915:	ff 75 0c             	pushl  0xc(%ebp)
  801918:	e8 b8 f0 ff ff       	call   8009d5 <memmove>
	return r;
  80191d:	83 c4 10             	add    $0x10,%esp
}
  801920:	89 d8                	mov    %ebx,%eax
  801922:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801925:	5b                   	pop    %ebx
  801926:	5e                   	pop    %esi
  801927:	5d                   	pop    %ebp
  801928:	c3                   	ret    
	assert(r <= n);
  801929:	68 90 27 80 00       	push   $0x802790
  80192e:	68 97 27 80 00       	push   $0x802797
  801933:	6a 7c                	push   $0x7c
  801935:	68 ac 27 80 00       	push   $0x8027ac
  80193a:	e8 be 05 00 00       	call   801efd <_panic>
	assert(r <= PGSIZE);
  80193f:	68 b7 27 80 00       	push   $0x8027b7
  801944:	68 97 27 80 00       	push   $0x802797
  801949:	6a 7d                	push   $0x7d
  80194b:	68 ac 27 80 00       	push   $0x8027ac
  801950:	e8 a8 05 00 00       	call   801efd <_panic>

00801955 <open>:
{
  801955:	f3 0f 1e fb          	endbr32 
  801959:	55                   	push   %ebp
  80195a:	89 e5                	mov    %esp,%ebp
  80195c:	56                   	push   %esi
  80195d:	53                   	push   %ebx
  80195e:	83 ec 1c             	sub    $0x1c,%esp
  801961:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801964:	56                   	push   %esi
  801965:	e8 72 ee ff ff       	call   8007dc <strlen>
  80196a:	83 c4 10             	add    $0x10,%esp
  80196d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801972:	7f 6c                	jg     8019e0 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801974:	83 ec 0c             	sub    $0xc,%esp
  801977:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197a:	50                   	push   %eax
  80197b:	e8 67 f8 ff ff       	call   8011e7 <fd_alloc>
  801980:	89 c3                	mov    %eax,%ebx
  801982:	83 c4 10             	add    $0x10,%esp
  801985:	85 c0                	test   %eax,%eax
  801987:	78 3c                	js     8019c5 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801989:	83 ec 08             	sub    $0x8,%esp
  80198c:	56                   	push   %esi
  80198d:	68 00 50 80 00       	push   $0x805000
  801992:	e8 88 ee ff ff       	call   80081f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801997:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199a:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80199f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8019a7:	e8 db fd ff ff       	call   801787 <fsipc>
  8019ac:	89 c3                	mov    %eax,%ebx
  8019ae:	83 c4 10             	add    $0x10,%esp
  8019b1:	85 c0                	test   %eax,%eax
  8019b3:	78 19                	js     8019ce <open+0x79>
	return fd2num(fd);
  8019b5:	83 ec 0c             	sub    $0xc,%esp
  8019b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019bb:	e8 f8 f7 ff ff       	call   8011b8 <fd2num>
  8019c0:	89 c3                	mov    %eax,%ebx
  8019c2:	83 c4 10             	add    $0x10,%esp
}
  8019c5:	89 d8                	mov    %ebx,%eax
  8019c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ca:	5b                   	pop    %ebx
  8019cb:	5e                   	pop    %esi
  8019cc:	5d                   	pop    %ebp
  8019cd:	c3                   	ret    
		fd_close(fd, 0);
  8019ce:	83 ec 08             	sub    $0x8,%esp
  8019d1:	6a 00                	push   $0x0
  8019d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d6:	e8 10 f9 ff ff       	call   8012eb <fd_close>
		return r;
  8019db:	83 c4 10             	add    $0x10,%esp
  8019de:	eb e5                	jmp    8019c5 <open+0x70>
		return -E_BAD_PATH;
  8019e0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019e5:	eb de                	jmp    8019c5 <open+0x70>

008019e7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019e7:	f3 0f 1e fb          	endbr32 
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
  8019ee:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f6:	b8 08 00 00 00       	mov    $0x8,%eax
  8019fb:	e8 87 fd ff ff       	call   801787 <fsipc>
}
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    

00801a02 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a02:	f3 0f 1e fb          	endbr32 
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	56                   	push   %esi
  801a0a:	53                   	push   %ebx
  801a0b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a0e:	83 ec 0c             	sub    $0xc,%esp
  801a11:	ff 75 08             	pushl  0x8(%ebp)
  801a14:	e8 b3 f7 ff ff       	call   8011cc <fd2data>
  801a19:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a1b:	83 c4 08             	add    $0x8,%esp
  801a1e:	68 c3 27 80 00       	push   $0x8027c3
  801a23:	53                   	push   %ebx
  801a24:	e8 f6 ed ff ff       	call   80081f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a29:	8b 46 04             	mov    0x4(%esi),%eax
  801a2c:	2b 06                	sub    (%esi),%eax
  801a2e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a34:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a3b:	00 00 00 
	stat->st_dev = &devpipe;
  801a3e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a45:	30 80 00 
	return 0;
}
  801a48:	b8 00 00 00 00       	mov    $0x0,%eax
  801a4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a50:	5b                   	pop    %ebx
  801a51:	5e                   	pop    %esi
  801a52:	5d                   	pop    %ebp
  801a53:	c3                   	ret    

00801a54 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a54:	f3 0f 1e fb          	endbr32 
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	53                   	push   %ebx
  801a5c:	83 ec 0c             	sub    $0xc,%esp
  801a5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a62:	53                   	push   %ebx
  801a63:	6a 00                	push   $0x0
  801a65:	e8 84 f2 ff ff       	call   800cee <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a6a:	89 1c 24             	mov    %ebx,(%esp)
  801a6d:	e8 5a f7 ff ff       	call   8011cc <fd2data>
  801a72:	83 c4 08             	add    $0x8,%esp
  801a75:	50                   	push   %eax
  801a76:	6a 00                	push   $0x0
  801a78:	e8 71 f2 ff ff       	call   800cee <sys_page_unmap>
}
  801a7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a80:	c9                   	leave  
  801a81:	c3                   	ret    

00801a82 <_pipeisclosed>:
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	57                   	push   %edi
  801a86:	56                   	push   %esi
  801a87:	53                   	push   %ebx
  801a88:	83 ec 1c             	sub    $0x1c,%esp
  801a8b:	89 c7                	mov    %eax,%edi
  801a8d:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a8f:	a1 08 40 80 00       	mov    0x804008,%eax
  801a94:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a97:	83 ec 0c             	sub    $0xc,%esp
  801a9a:	57                   	push   %edi
  801a9b:	e8 4d 05 00 00       	call   801fed <pageref>
  801aa0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801aa3:	89 34 24             	mov    %esi,(%esp)
  801aa6:	e8 42 05 00 00       	call   801fed <pageref>
		nn = thisenv->env_runs;
  801aab:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ab1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ab4:	83 c4 10             	add    $0x10,%esp
  801ab7:	39 cb                	cmp    %ecx,%ebx
  801ab9:	74 1b                	je     801ad6 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801abb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801abe:	75 cf                	jne    801a8f <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ac0:	8b 42 58             	mov    0x58(%edx),%eax
  801ac3:	6a 01                	push   $0x1
  801ac5:	50                   	push   %eax
  801ac6:	53                   	push   %ebx
  801ac7:	68 ca 27 80 00       	push   $0x8027ca
  801acc:	e8 45 e7 ff ff       	call   800216 <cprintf>
  801ad1:	83 c4 10             	add    $0x10,%esp
  801ad4:	eb b9                	jmp    801a8f <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801ad6:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ad9:	0f 94 c0             	sete   %al
  801adc:	0f b6 c0             	movzbl %al,%eax
}
  801adf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae2:	5b                   	pop    %ebx
  801ae3:	5e                   	pop    %esi
  801ae4:	5f                   	pop    %edi
  801ae5:	5d                   	pop    %ebp
  801ae6:	c3                   	ret    

00801ae7 <devpipe_write>:
{
  801ae7:	f3 0f 1e fb          	endbr32 
  801aeb:	55                   	push   %ebp
  801aec:	89 e5                	mov    %esp,%ebp
  801aee:	57                   	push   %edi
  801aef:	56                   	push   %esi
  801af0:	53                   	push   %ebx
  801af1:	83 ec 28             	sub    $0x28,%esp
  801af4:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801af7:	56                   	push   %esi
  801af8:	e8 cf f6 ff ff       	call   8011cc <fd2data>
  801afd:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801aff:	83 c4 10             	add    $0x10,%esp
  801b02:	bf 00 00 00 00       	mov    $0x0,%edi
  801b07:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b0a:	74 4f                	je     801b5b <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b0c:	8b 43 04             	mov    0x4(%ebx),%eax
  801b0f:	8b 0b                	mov    (%ebx),%ecx
  801b11:	8d 51 20             	lea    0x20(%ecx),%edx
  801b14:	39 d0                	cmp    %edx,%eax
  801b16:	72 14                	jb     801b2c <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801b18:	89 da                	mov    %ebx,%edx
  801b1a:	89 f0                	mov    %esi,%eax
  801b1c:	e8 61 ff ff ff       	call   801a82 <_pipeisclosed>
  801b21:	85 c0                	test   %eax,%eax
  801b23:	75 3b                	jne    801b60 <devpipe_write+0x79>
			sys_yield();
  801b25:	e8 14 f1 ff ff       	call   800c3e <sys_yield>
  801b2a:	eb e0                	jmp    801b0c <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b2f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b33:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b36:	89 c2                	mov    %eax,%edx
  801b38:	c1 fa 1f             	sar    $0x1f,%edx
  801b3b:	89 d1                	mov    %edx,%ecx
  801b3d:	c1 e9 1b             	shr    $0x1b,%ecx
  801b40:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b43:	83 e2 1f             	and    $0x1f,%edx
  801b46:	29 ca                	sub    %ecx,%edx
  801b48:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b4c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b50:	83 c0 01             	add    $0x1,%eax
  801b53:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b56:	83 c7 01             	add    $0x1,%edi
  801b59:	eb ac                	jmp    801b07 <devpipe_write+0x20>
	return i;
  801b5b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b5e:	eb 05                	jmp    801b65 <devpipe_write+0x7e>
				return 0;
  801b60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b68:	5b                   	pop    %ebx
  801b69:	5e                   	pop    %esi
  801b6a:	5f                   	pop    %edi
  801b6b:	5d                   	pop    %ebp
  801b6c:	c3                   	ret    

00801b6d <devpipe_read>:
{
  801b6d:	f3 0f 1e fb          	endbr32 
  801b71:	55                   	push   %ebp
  801b72:	89 e5                	mov    %esp,%ebp
  801b74:	57                   	push   %edi
  801b75:	56                   	push   %esi
  801b76:	53                   	push   %ebx
  801b77:	83 ec 18             	sub    $0x18,%esp
  801b7a:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b7d:	57                   	push   %edi
  801b7e:	e8 49 f6 ff ff       	call   8011cc <fd2data>
  801b83:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b85:	83 c4 10             	add    $0x10,%esp
  801b88:	be 00 00 00 00       	mov    $0x0,%esi
  801b8d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b90:	75 14                	jne    801ba6 <devpipe_read+0x39>
	return i;
  801b92:	8b 45 10             	mov    0x10(%ebp),%eax
  801b95:	eb 02                	jmp    801b99 <devpipe_read+0x2c>
				return i;
  801b97:	89 f0                	mov    %esi,%eax
}
  801b99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b9c:	5b                   	pop    %ebx
  801b9d:	5e                   	pop    %esi
  801b9e:	5f                   	pop    %edi
  801b9f:	5d                   	pop    %ebp
  801ba0:	c3                   	ret    
			sys_yield();
  801ba1:	e8 98 f0 ff ff       	call   800c3e <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801ba6:	8b 03                	mov    (%ebx),%eax
  801ba8:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bab:	75 18                	jne    801bc5 <devpipe_read+0x58>
			if (i > 0)
  801bad:	85 f6                	test   %esi,%esi
  801baf:	75 e6                	jne    801b97 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801bb1:	89 da                	mov    %ebx,%edx
  801bb3:	89 f8                	mov    %edi,%eax
  801bb5:	e8 c8 fe ff ff       	call   801a82 <_pipeisclosed>
  801bba:	85 c0                	test   %eax,%eax
  801bbc:	74 e3                	je     801ba1 <devpipe_read+0x34>
				return 0;
  801bbe:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc3:	eb d4                	jmp    801b99 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bc5:	99                   	cltd   
  801bc6:	c1 ea 1b             	shr    $0x1b,%edx
  801bc9:	01 d0                	add    %edx,%eax
  801bcb:	83 e0 1f             	and    $0x1f,%eax
  801bce:	29 d0                	sub    %edx,%eax
  801bd0:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801bd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd8:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801bdb:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801bde:	83 c6 01             	add    $0x1,%esi
  801be1:	eb aa                	jmp    801b8d <devpipe_read+0x20>

00801be3 <pipe>:
{
  801be3:	f3 0f 1e fb          	endbr32 
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	56                   	push   %esi
  801beb:	53                   	push   %ebx
  801bec:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801bef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf2:	50                   	push   %eax
  801bf3:	e8 ef f5 ff ff       	call   8011e7 <fd_alloc>
  801bf8:	89 c3                	mov    %eax,%ebx
  801bfa:	83 c4 10             	add    $0x10,%esp
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	0f 88 23 01 00 00    	js     801d28 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c05:	83 ec 04             	sub    $0x4,%esp
  801c08:	68 07 04 00 00       	push   $0x407
  801c0d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c10:	6a 00                	push   $0x0
  801c12:	e8 4a f0 ff ff       	call   800c61 <sys_page_alloc>
  801c17:	89 c3                	mov    %eax,%ebx
  801c19:	83 c4 10             	add    $0x10,%esp
  801c1c:	85 c0                	test   %eax,%eax
  801c1e:	0f 88 04 01 00 00    	js     801d28 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801c24:	83 ec 0c             	sub    $0xc,%esp
  801c27:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c2a:	50                   	push   %eax
  801c2b:	e8 b7 f5 ff ff       	call   8011e7 <fd_alloc>
  801c30:	89 c3                	mov    %eax,%ebx
  801c32:	83 c4 10             	add    $0x10,%esp
  801c35:	85 c0                	test   %eax,%eax
  801c37:	0f 88 db 00 00 00    	js     801d18 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c3d:	83 ec 04             	sub    $0x4,%esp
  801c40:	68 07 04 00 00       	push   $0x407
  801c45:	ff 75 f0             	pushl  -0x10(%ebp)
  801c48:	6a 00                	push   $0x0
  801c4a:	e8 12 f0 ff ff       	call   800c61 <sys_page_alloc>
  801c4f:	89 c3                	mov    %eax,%ebx
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	85 c0                	test   %eax,%eax
  801c56:	0f 88 bc 00 00 00    	js     801d18 <pipe+0x135>
	va = fd2data(fd0);
  801c5c:	83 ec 0c             	sub    $0xc,%esp
  801c5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c62:	e8 65 f5 ff ff       	call   8011cc <fd2data>
  801c67:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c69:	83 c4 0c             	add    $0xc,%esp
  801c6c:	68 07 04 00 00       	push   $0x407
  801c71:	50                   	push   %eax
  801c72:	6a 00                	push   $0x0
  801c74:	e8 e8 ef ff ff       	call   800c61 <sys_page_alloc>
  801c79:	89 c3                	mov    %eax,%ebx
  801c7b:	83 c4 10             	add    $0x10,%esp
  801c7e:	85 c0                	test   %eax,%eax
  801c80:	0f 88 82 00 00 00    	js     801d08 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c86:	83 ec 0c             	sub    $0xc,%esp
  801c89:	ff 75 f0             	pushl  -0x10(%ebp)
  801c8c:	e8 3b f5 ff ff       	call   8011cc <fd2data>
  801c91:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c98:	50                   	push   %eax
  801c99:	6a 00                	push   $0x0
  801c9b:	56                   	push   %esi
  801c9c:	6a 00                	push   $0x0
  801c9e:	e8 05 f0 ff ff       	call   800ca8 <sys_page_map>
  801ca3:	89 c3                	mov    %eax,%ebx
  801ca5:	83 c4 20             	add    $0x20,%esp
  801ca8:	85 c0                	test   %eax,%eax
  801caa:	78 4e                	js     801cfa <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801cac:	a1 20 30 80 00       	mov    0x803020,%eax
  801cb1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cb4:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801cb6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cb9:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801cc0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cc3:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801cc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cc8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801ccf:	83 ec 0c             	sub    $0xc,%esp
  801cd2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd5:	e8 de f4 ff ff       	call   8011b8 <fd2num>
  801cda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cdd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cdf:	83 c4 04             	add    $0x4,%esp
  801ce2:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce5:	e8 ce f4 ff ff       	call   8011b8 <fd2num>
  801cea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ced:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cf0:	83 c4 10             	add    $0x10,%esp
  801cf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cf8:	eb 2e                	jmp    801d28 <pipe+0x145>
	sys_page_unmap(0, va);
  801cfa:	83 ec 08             	sub    $0x8,%esp
  801cfd:	56                   	push   %esi
  801cfe:	6a 00                	push   $0x0
  801d00:	e8 e9 ef ff ff       	call   800cee <sys_page_unmap>
  801d05:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d08:	83 ec 08             	sub    $0x8,%esp
  801d0b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d0e:	6a 00                	push   $0x0
  801d10:	e8 d9 ef ff ff       	call   800cee <sys_page_unmap>
  801d15:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801d18:	83 ec 08             	sub    $0x8,%esp
  801d1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1e:	6a 00                	push   $0x0
  801d20:	e8 c9 ef ff ff       	call   800cee <sys_page_unmap>
  801d25:	83 c4 10             	add    $0x10,%esp
}
  801d28:	89 d8                	mov    %ebx,%eax
  801d2a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5d                   	pop    %ebp
  801d30:	c3                   	ret    

00801d31 <pipeisclosed>:
{
  801d31:	f3 0f 1e fb          	endbr32 
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d3e:	50                   	push   %eax
  801d3f:	ff 75 08             	pushl  0x8(%ebp)
  801d42:	e8 f6 f4 ff ff       	call   80123d <fd_lookup>
  801d47:	83 c4 10             	add    $0x10,%esp
  801d4a:	85 c0                	test   %eax,%eax
  801d4c:	78 18                	js     801d66 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801d4e:	83 ec 0c             	sub    $0xc,%esp
  801d51:	ff 75 f4             	pushl  -0xc(%ebp)
  801d54:	e8 73 f4 ff ff       	call   8011cc <fd2data>
  801d59:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5e:	e8 1f fd ff ff       	call   801a82 <_pipeisclosed>
  801d63:	83 c4 10             	add    $0x10,%esp
}
  801d66:	c9                   	leave  
  801d67:	c3                   	ret    

00801d68 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d68:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801d6c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d71:	c3                   	ret    

00801d72 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d72:	f3 0f 1e fb          	endbr32 
  801d76:	55                   	push   %ebp
  801d77:	89 e5                	mov    %esp,%ebp
  801d79:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d7c:	68 e2 27 80 00       	push   $0x8027e2
  801d81:	ff 75 0c             	pushl  0xc(%ebp)
  801d84:	e8 96 ea ff ff       	call   80081f <strcpy>
	return 0;
}
  801d89:	b8 00 00 00 00       	mov    $0x0,%eax
  801d8e:	c9                   	leave  
  801d8f:	c3                   	ret    

00801d90 <devcons_write>:
{
  801d90:	f3 0f 1e fb          	endbr32 
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	57                   	push   %edi
  801d98:	56                   	push   %esi
  801d99:	53                   	push   %ebx
  801d9a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801da0:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801da5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801dab:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dae:	73 31                	jae    801de1 <devcons_write+0x51>
		m = n - tot;
  801db0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801db3:	29 f3                	sub    %esi,%ebx
  801db5:	83 fb 7f             	cmp    $0x7f,%ebx
  801db8:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801dbd:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801dc0:	83 ec 04             	sub    $0x4,%esp
  801dc3:	53                   	push   %ebx
  801dc4:	89 f0                	mov    %esi,%eax
  801dc6:	03 45 0c             	add    0xc(%ebp),%eax
  801dc9:	50                   	push   %eax
  801dca:	57                   	push   %edi
  801dcb:	e8 05 ec ff ff       	call   8009d5 <memmove>
		sys_cputs(buf, m);
  801dd0:	83 c4 08             	add    $0x8,%esp
  801dd3:	53                   	push   %ebx
  801dd4:	57                   	push   %edi
  801dd5:	e8 b7 ed ff ff       	call   800b91 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801dda:	01 de                	add    %ebx,%esi
  801ddc:	83 c4 10             	add    $0x10,%esp
  801ddf:	eb ca                	jmp    801dab <devcons_write+0x1b>
}
  801de1:	89 f0                	mov    %esi,%eax
  801de3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de6:	5b                   	pop    %ebx
  801de7:	5e                   	pop    %esi
  801de8:	5f                   	pop    %edi
  801de9:	5d                   	pop    %ebp
  801dea:	c3                   	ret    

00801deb <devcons_read>:
{
  801deb:	f3 0f 1e fb          	endbr32 
  801def:	55                   	push   %ebp
  801df0:	89 e5                	mov    %esp,%ebp
  801df2:	83 ec 08             	sub    $0x8,%esp
  801df5:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801dfa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dfe:	74 21                	je     801e21 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801e00:	e8 ae ed ff ff       	call   800bb3 <sys_cgetc>
  801e05:	85 c0                	test   %eax,%eax
  801e07:	75 07                	jne    801e10 <devcons_read+0x25>
		sys_yield();
  801e09:	e8 30 ee ff ff       	call   800c3e <sys_yield>
  801e0e:	eb f0                	jmp    801e00 <devcons_read+0x15>
	if (c < 0)
  801e10:	78 0f                	js     801e21 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801e12:	83 f8 04             	cmp    $0x4,%eax
  801e15:	74 0c                	je     801e23 <devcons_read+0x38>
	*(char*)vbuf = c;
  801e17:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e1a:	88 02                	mov    %al,(%edx)
	return 1;
  801e1c:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801e21:	c9                   	leave  
  801e22:	c3                   	ret    
		return 0;
  801e23:	b8 00 00 00 00       	mov    $0x0,%eax
  801e28:	eb f7                	jmp    801e21 <devcons_read+0x36>

00801e2a <cputchar>:
{
  801e2a:	f3 0f 1e fb          	endbr32 
  801e2e:	55                   	push   %ebp
  801e2f:	89 e5                	mov    %esp,%ebp
  801e31:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e34:	8b 45 08             	mov    0x8(%ebp),%eax
  801e37:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e3a:	6a 01                	push   $0x1
  801e3c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e3f:	50                   	push   %eax
  801e40:	e8 4c ed ff ff       	call   800b91 <sys_cputs>
}
  801e45:	83 c4 10             	add    $0x10,%esp
  801e48:	c9                   	leave  
  801e49:	c3                   	ret    

00801e4a <getchar>:
{
  801e4a:	f3 0f 1e fb          	endbr32 
  801e4e:	55                   	push   %ebp
  801e4f:	89 e5                	mov    %esp,%ebp
  801e51:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801e54:	6a 01                	push   $0x1
  801e56:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e59:	50                   	push   %eax
  801e5a:	6a 00                	push   $0x0
  801e5c:	e8 5f f6 ff ff       	call   8014c0 <read>
	if (r < 0)
  801e61:	83 c4 10             	add    $0x10,%esp
  801e64:	85 c0                	test   %eax,%eax
  801e66:	78 06                	js     801e6e <getchar+0x24>
	if (r < 1)
  801e68:	74 06                	je     801e70 <getchar+0x26>
	return c;
  801e6a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e6e:	c9                   	leave  
  801e6f:	c3                   	ret    
		return -E_EOF;
  801e70:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e75:	eb f7                	jmp    801e6e <getchar+0x24>

00801e77 <iscons>:
{
  801e77:	f3 0f 1e fb          	endbr32 
  801e7b:	55                   	push   %ebp
  801e7c:	89 e5                	mov    %esp,%ebp
  801e7e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e84:	50                   	push   %eax
  801e85:	ff 75 08             	pushl  0x8(%ebp)
  801e88:	e8 b0 f3 ff ff       	call   80123d <fd_lookup>
  801e8d:	83 c4 10             	add    $0x10,%esp
  801e90:	85 c0                	test   %eax,%eax
  801e92:	78 11                	js     801ea5 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e97:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e9d:	39 10                	cmp    %edx,(%eax)
  801e9f:	0f 94 c0             	sete   %al
  801ea2:	0f b6 c0             	movzbl %al,%eax
}
  801ea5:	c9                   	leave  
  801ea6:	c3                   	ret    

00801ea7 <opencons>:
{
  801ea7:	f3 0f 1e fb          	endbr32 
  801eab:	55                   	push   %ebp
  801eac:	89 e5                	mov    %esp,%ebp
  801eae:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801eb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb4:	50                   	push   %eax
  801eb5:	e8 2d f3 ff ff       	call   8011e7 <fd_alloc>
  801eba:	83 c4 10             	add    $0x10,%esp
  801ebd:	85 c0                	test   %eax,%eax
  801ebf:	78 3a                	js     801efb <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ec1:	83 ec 04             	sub    $0x4,%esp
  801ec4:	68 07 04 00 00       	push   $0x407
  801ec9:	ff 75 f4             	pushl  -0xc(%ebp)
  801ecc:	6a 00                	push   $0x0
  801ece:	e8 8e ed ff ff       	call   800c61 <sys_page_alloc>
  801ed3:	83 c4 10             	add    $0x10,%esp
  801ed6:	85 c0                	test   %eax,%eax
  801ed8:	78 21                	js     801efb <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801edd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ee3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801eef:	83 ec 0c             	sub    $0xc,%esp
  801ef2:	50                   	push   %eax
  801ef3:	e8 c0 f2 ff ff       	call   8011b8 <fd2num>
  801ef8:	83 c4 10             	add    $0x10,%esp
}
  801efb:	c9                   	leave  
  801efc:	c3                   	ret    

00801efd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801efd:	f3 0f 1e fb          	endbr32 
  801f01:	55                   	push   %ebp
  801f02:	89 e5                	mov    %esp,%ebp
  801f04:	56                   	push   %esi
  801f05:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f06:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f09:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f0f:	e8 07 ed ff ff       	call   800c1b <sys_getenvid>
  801f14:	83 ec 0c             	sub    $0xc,%esp
  801f17:	ff 75 0c             	pushl  0xc(%ebp)
  801f1a:	ff 75 08             	pushl  0x8(%ebp)
  801f1d:	56                   	push   %esi
  801f1e:	50                   	push   %eax
  801f1f:	68 f0 27 80 00       	push   $0x8027f0
  801f24:	e8 ed e2 ff ff       	call   800216 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f29:	83 c4 18             	add    $0x18,%esp
  801f2c:	53                   	push   %ebx
  801f2d:	ff 75 10             	pushl  0x10(%ebp)
  801f30:	e8 8c e2 ff ff       	call   8001c1 <vcprintf>
	cprintf("\n");
  801f35:	c7 04 24 20 28 80 00 	movl   $0x802820,(%esp)
  801f3c:	e8 d5 e2 ff ff       	call   800216 <cprintf>
  801f41:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f44:	cc                   	int3   
  801f45:	eb fd                	jmp    801f44 <_panic+0x47>

00801f47 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f47:	f3 0f 1e fb          	endbr32 
  801f4b:	55                   	push   %ebp
  801f4c:	89 e5                	mov    %esp,%ebp
  801f4e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f51:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f58:	74 0a                	je     801f64 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5d:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f62:	c9                   	leave  
  801f63:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801f64:	83 ec 0c             	sub    $0xc,%esp
  801f67:	68 13 28 80 00       	push   $0x802813
  801f6c:	e8 a5 e2 ff ff       	call   800216 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  801f71:	83 c4 0c             	add    $0xc,%esp
  801f74:	6a 07                	push   $0x7
  801f76:	68 00 f0 bf ee       	push   $0xeebff000
  801f7b:	6a 00                	push   $0x0
  801f7d:	e8 df ec ff ff       	call   800c61 <sys_page_alloc>
  801f82:	83 c4 10             	add    $0x10,%esp
  801f85:	85 c0                	test   %eax,%eax
  801f87:	78 2a                	js     801fb3 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801f89:	83 ec 08             	sub    $0x8,%esp
  801f8c:	68 c7 1f 80 00       	push   $0x801fc7
  801f91:	6a 00                	push   $0x0
  801f93:	e8 28 ee ff ff       	call   800dc0 <sys_env_set_pgfault_upcall>
  801f98:	83 c4 10             	add    $0x10,%esp
  801f9b:	85 c0                	test   %eax,%eax
  801f9d:	79 bb                	jns    801f5a <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  801f9f:	83 ec 04             	sub    $0x4,%esp
  801fa2:	68 50 28 80 00       	push   $0x802850
  801fa7:	6a 25                	push   $0x25
  801fa9:	68 40 28 80 00       	push   $0x802840
  801fae:	e8 4a ff ff ff       	call   801efd <_panic>
            panic("Allocation of UXSTACK failed!");
  801fb3:	83 ec 04             	sub    $0x4,%esp
  801fb6:	68 22 28 80 00       	push   $0x802822
  801fbb:	6a 22                	push   $0x22
  801fbd:	68 40 28 80 00       	push   $0x802840
  801fc2:	e8 36 ff ff ff       	call   801efd <_panic>

00801fc7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fc7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fc8:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fcd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fcf:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  801fd2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  801fd6:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  801fda:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  801fdd:	83 c4 08             	add    $0x8,%esp
    popa
  801fe0:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  801fe1:	83 c4 04             	add    $0x4,%esp
    popf
  801fe4:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  801fe5:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  801fe8:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  801fec:	c3                   	ret    

00801fed <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fed:	f3 0f 1e fb          	endbr32 
  801ff1:	55                   	push   %ebp
  801ff2:	89 e5                	mov    %esp,%ebp
  801ff4:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ff7:	89 c2                	mov    %eax,%edx
  801ff9:	c1 ea 16             	shr    $0x16,%edx
  801ffc:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802003:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802008:	f6 c1 01             	test   $0x1,%cl
  80200b:	74 1c                	je     802029 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  80200d:	c1 e8 0c             	shr    $0xc,%eax
  802010:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802017:	a8 01                	test   $0x1,%al
  802019:	74 0e                	je     802029 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80201b:	c1 e8 0c             	shr    $0xc,%eax
  80201e:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802025:	ef 
  802026:	0f b7 d2             	movzwl %dx,%edx
}
  802029:	89 d0                	mov    %edx,%eax
  80202b:	5d                   	pop    %ebp
  80202c:	c3                   	ret    
  80202d:	66 90                	xchg   %ax,%ax
  80202f:	90                   	nop

00802030 <__udivdi3>:
  802030:	f3 0f 1e fb          	endbr32 
  802034:	55                   	push   %ebp
  802035:	57                   	push   %edi
  802036:	56                   	push   %esi
  802037:	53                   	push   %ebx
  802038:	83 ec 1c             	sub    $0x1c,%esp
  80203b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80203f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802043:	8b 74 24 34          	mov    0x34(%esp),%esi
  802047:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80204b:	85 d2                	test   %edx,%edx
  80204d:	75 19                	jne    802068 <__udivdi3+0x38>
  80204f:	39 f3                	cmp    %esi,%ebx
  802051:	76 4d                	jbe    8020a0 <__udivdi3+0x70>
  802053:	31 ff                	xor    %edi,%edi
  802055:	89 e8                	mov    %ebp,%eax
  802057:	89 f2                	mov    %esi,%edx
  802059:	f7 f3                	div    %ebx
  80205b:	89 fa                	mov    %edi,%edx
  80205d:	83 c4 1c             	add    $0x1c,%esp
  802060:	5b                   	pop    %ebx
  802061:	5e                   	pop    %esi
  802062:	5f                   	pop    %edi
  802063:	5d                   	pop    %ebp
  802064:	c3                   	ret    
  802065:	8d 76 00             	lea    0x0(%esi),%esi
  802068:	39 f2                	cmp    %esi,%edx
  80206a:	76 14                	jbe    802080 <__udivdi3+0x50>
  80206c:	31 ff                	xor    %edi,%edi
  80206e:	31 c0                	xor    %eax,%eax
  802070:	89 fa                	mov    %edi,%edx
  802072:	83 c4 1c             	add    $0x1c,%esp
  802075:	5b                   	pop    %ebx
  802076:	5e                   	pop    %esi
  802077:	5f                   	pop    %edi
  802078:	5d                   	pop    %ebp
  802079:	c3                   	ret    
  80207a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802080:	0f bd fa             	bsr    %edx,%edi
  802083:	83 f7 1f             	xor    $0x1f,%edi
  802086:	75 48                	jne    8020d0 <__udivdi3+0xa0>
  802088:	39 f2                	cmp    %esi,%edx
  80208a:	72 06                	jb     802092 <__udivdi3+0x62>
  80208c:	31 c0                	xor    %eax,%eax
  80208e:	39 eb                	cmp    %ebp,%ebx
  802090:	77 de                	ja     802070 <__udivdi3+0x40>
  802092:	b8 01 00 00 00       	mov    $0x1,%eax
  802097:	eb d7                	jmp    802070 <__udivdi3+0x40>
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	89 d9                	mov    %ebx,%ecx
  8020a2:	85 db                	test   %ebx,%ebx
  8020a4:	75 0b                	jne    8020b1 <__udivdi3+0x81>
  8020a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020ab:	31 d2                	xor    %edx,%edx
  8020ad:	f7 f3                	div    %ebx
  8020af:	89 c1                	mov    %eax,%ecx
  8020b1:	31 d2                	xor    %edx,%edx
  8020b3:	89 f0                	mov    %esi,%eax
  8020b5:	f7 f1                	div    %ecx
  8020b7:	89 c6                	mov    %eax,%esi
  8020b9:	89 e8                	mov    %ebp,%eax
  8020bb:	89 f7                	mov    %esi,%edi
  8020bd:	f7 f1                	div    %ecx
  8020bf:	89 fa                	mov    %edi,%edx
  8020c1:	83 c4 1c             	add    $0x1c,%esp
  8020c4:	5b                   	pop    %ebx
  8020c5:	5e                   	pop    %esi
  8020c6:	5f                   	pop    %edi
  8020c7:	5d                   	pop    %ebp
  8020c8:	c3                   	ret    
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	89 f9                	mov    %edi,%ecx
  8020d2:	b8 20 00 00 00       	mov    $0x20,%eax
  8020d7:	29 f8                	sub    %edi,%eax
  8020d9:	d3 e2                	shl    %cl,%edx
  8020db:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020df:	89 c1                	mov    %eax,%ecx
  8020e1:	89 da                	mov    %ebx,%edx
  8020e3:	d3 ea                	shr    %cl,%edx
  8020e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020e9:	09 d1                	or     %edx,%ecx
  8020eb:	89 f2                	mov    %esi,%edx
  8020ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020f1:	89 f9                	mov    %edi,%ecx
  8020f3:	d3 e3                	shl    %cl,%ebx
  8020f5:	89 c1                	mov    %eax,%ecx
  8020f7:	d3 ea                	shr    %cl,%edx
  8020f9:	89 f9                	mov    %edi,%ecx
  8020fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020ff:	89 eb                	mov    %ebp,%ebx
  802101:	d3 e6                	shl    %cl,%esi
  802103:	89 c1                	mov    %eax,%ecx
  802105:	d3 eb                	shr    %cl,%ebx
  802107:	09 de                	or     %ebx,%esi
  802109:	89 f0                	mov    %esi,%eax
  80210b:	f7 74 24 08          	divl   0x8(%esp)
  80210f:	89 d6                	mov    %edx,%esi
  802111:	89 c3                	mov    %eax,%ebx
  802113:	f7 64 24 0c          	mull   0xc(%esp)
  802117:	39 d6                	cmp    %edx,%esi
  802119:	72 15                	jb     802130 <__udivdi3+0x100>
  80211b:	89 f9                	mov    %edi,%ecx
  80211d:	d3 e5                	shl    %cl,%ebp
  80211f:	39 c5                	cmp    %eax,%ebp
  802121:	73 04                	jae    802127 <__udivdi3+0xf7>
  802123:	39 d6                	cmp    %edx,%esi
  802125:	74 09                	je     802130 <__udivdi3+0x100>
  802127:	89 d8                	mov    %ebx,%eax
  802129:	31 ff                	xor    %edi,%edi
  80212b:	e9 40 ff ff ff       	jmp    802070 <__udivdi3+0x40>
  802130:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802133:	31 ff                	xor    %edi,%edi
  802135:	e9 36 ff ff ff       	jmp    802070 <__udivdi3+0x40>
  80213a:	66 90                	xchg   %ax,%ax
  80213c:	66 90                	xchg   %ax,%ax
  80213e:	66 90                	xchg   %ax,%ax

00802140 <__umoddi3>:
  802140:	f3 0f 1e fb          	endbr32 
  802144:	55                   	push   %ebp
  802145:	57                   	push   %edi
  802146:	56                   	push   %esi
  802147:	53                   	push   %ebx
  802148:	83 ec 1c             	sub    $0x1c,%esp
  80214b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80214f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802153:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802157:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80215b:	85 c0                	test   %eax,%eax
  80215d:	75 19                	jne    802178 <__umoddi3+0x38>
  80215f:	39 df                	cmp    %ebx,%edi
  802161:	76 5d                	jbe    8021c0 <__umoddi3+0x80>
  802163:	89 f0                	mov    %esi,%eax
  802165:	89 da                	mov    %ebx,%edx
  802167:	f7 f7                	div    %edi
  802169:	89 d0                	mov    %edx,%eax
  80216b:	31 d2                	xor    %edx,%edx
  80216d:	83 c4 1c             	add    $0x1c,%esp
  802170:	5b                   	pop    %ebx
  802171:	5e                   	pop    %esi
  802172:	5f                   	pop    %edi
  802173:	5d                   	pop    %ebp
  802174:	c3                   	ret    
  802175:	8d 76 00             	lea    0x0(%esi),%esi
  802178:	89 f2                	mov    %esi,%edx
  80217a:	39 d8                	cmp    %ebx,%eax
  80217c:	76 12                	jbe    802190 <__umoddi3+0x50>
  80217e:	89 f0                	mov    %esi,%eax
  802180:	89 da                	mov    %ebx,%edx
  802182:	83 c4 1c             	add    $0x1c,%esp
  802185:	5b                   	pop    %ebx
  802186:	5e                   	pop    %esi
  802187:	5f                   	pop    %edi
  802188:	5d                   	pop    %ebp
  802189:	c3                   	ret    
  80218a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802190:	0f bd e8             	bsr    %eax,%ebp
  802193:	83 f5 1f             	xor    $0x1f,%ebp
  802196:	75 50                	jne    8021e8 <__umoddi3+0xa8>
  802198:	39 d8                	cmp    %ebx,%eax
  80219a:	0f 82 e0 00 00 00    	jb     802280 <__umoddi3+0x140>
  8021a0:	89 d9                	mov    %ebx,%ecx
  8021a2:	39 f7                	cmp    %esi,%edi
  8021a4:	0f 86 d6 00 00 00    	jbe    802280 <__umoddi3+0x140>
  8021aa:	89 d0                	mov    %edx,%eax
  8021ac:	89 ca                	mov    %ecx,%edx
  8021ae:	83 c4 1c             	add    $0x1c,%esp
  8021b1:	5b                   	pop    %ebx
  8021b2:	5e                   	pop    %esi
  8021b3:	5f                   	pop    %edi
  8021b4:	5d                   	pop    %ebp
  8021b5:	c3                   	ret    
  8021b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021bd:	8d 76 00             	lea    0x0(%esi),%esi
  8021c0:	89 fd                	mov    %edi,%ebp
  8021c2:	85 ff                	test   %edi,%edi
  8021c4:	75 0b                	jne    8021d1 <__umoddi3+0x91>
  8021c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021cb:	31 d2                	xor    %edx,%edx
  8021cd:	f7 f7                	div    %edi
  8021cf:	89 c5                	mov    %eax,%ebp
  8021d1:	89 d8                	mov    %ebx,%eax
  8021d3:	31 d2                	xor    %edx,%edx
  8021d5:	f7 f5                	div    %ebp
  8021d7:	89 f0                	mov    %esi,%eax
  8021d9:	f7 f5                	div    %ebp
  8021db:	89 d0                	mov    %edx,%eax
  8021dd:	31 d2                	xor    %edx,%edx
  8021df:	eb 8c                	jmp    80216d <__umoddi3+0x2d>
  8021e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e8:	89 e9                	mov    %ebp,%ecx
  8021ea:	ba 20 00 00 00       	mov    $0x20,%edx
  8021ef:	29 ea                	sub    %ebp,%edx
  8021f1:	d3 e0                	shl    %cl,%eax
  8021f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021f7:	89 d1                	mov    %edx,%ecx
  8021f9:	89 f8                	mov    %edi,%eax
  8021fb:	d3 e8                	shr    %cl,%eax
  8021fd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802201:	89 54 24 04          	mov    %edx,0x4(%esp)
  802205:	8b 54 24 04          	mov    0x4(%esp),%edx
  802209:	09 c1                	or     %eax,%ecx
  80220b:	89 d8                	mov    %ebx,%eax
  80220d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802211:	89 e9                	mov    %ebp,%ecx
  802213:	d3 e7                	shl    %cl,%edi
  802215:	89 d1                	mov    %edx,%ecx
  802217:	d3 e8                	shr    %cl,%eax
  802219:	89 e9                	mov    %ebp,%ecx
  80221b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80221f:	d3 e3                	shl    %cl,%ebx
  802221:	89 c7                	mov    %eax,%edi
  802223:	89 d1                	mov    %edx,%ecx
  802225:	89 f0                	mov    %esi,%eax
  802227:	d3 e8                	shr    %cl,%eax
  802229:	89 e9                	mov    %ebp,%ecx
  80222b:	89 fa                	mov    %edi,%edx
  80222d:	d3 e6                	shl    %cl,%esi
  80222f:	09 d8                	or     %ebx,%eax
  802231:	f7 74 24 08          	divl   0x8(%esp)
  802235:	89 d1                	mov    %edx,%ecx
  802237:	89 f3                	mov    %esi,%ebx
  802239:	f7 64 24 0c          	mull   0xc(%esp)
  80223d:	89 c6                	mov    %eax,%esi
  80223f:	89 d7                	mov    %edx,%edi
  802241:	39 d1                	cmp    %edx,%ecx
  802243:	72 06                	jb     80224b <__umoddi3+0x10b>
  802245:	75 10                	jne    802257 <__umoddi3+0x117>
  802247:	39 c3                	cmp    %eax,%ebx
  802249:	73 0c                	jae    802257 <__umoddi3+0x117>
  80224b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80224f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802253:	89 d7                	mov    %edx,%edi
  802255:	89 c6                	mov    %eax,%esi
  802257:	89 ca                	mov    %ecx,%edx
  802259:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80225e:	29 f3                	sub    %esi,%ebx
  802260:	19 fa                	sbb    %edi,%edx
  802262:	89 d0                	mov    %edx,%eax
  802264:	d3 e0                	shl    %cl,%eax
  802266:	89 e9                	mov    %ebp,%ecx
  802268:	d3 eb                	shr    %cl,%ebx
  80226a:	d3 ea                	shr    %cl,%edx
  80226c:	09 d8                	or     %ebx,%eax
  80226e:	83 c4 1c             	add    $0x1c,%esp
  802271:	5b                   	pop    %ebx
  802272:	5e                   	pop    %esi
  802273:	5f                   	pop    %edi
  802274:	5d                   	pop    %ebp
  802275:	c3                   	ret    
  802276:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80227d:	8d 76 00             	lea    0x0(%esi),%esi
  802280:	29 fe                	sub    %edi,%esi
  802282:	19 c3                	sbb    %eax,%ebx
  802284:	89 f2                	mov    %esi,%edx
  802286:	89 d9                	mov    %ebx,%ecx
  802288:	e9 1d ff ff ff       	jmp    8021aa <__umoddi3+0x6a>
