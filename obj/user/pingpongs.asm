
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
  800040:	e8 50 10 00 00       	call   801095 <sfork>
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
  800057:	e8 57 10 00 00       	call   8010b3 <ipc_recv>
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
  80007f:	68 90 22 80 00       	push   $0x802290
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
  8000a7:	e8 5e 10 00 00       	call   80110a <ipc_send>
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
  8000d0:	68 60 22 80 00       	push   $0x802260
  8000d5:	e8 3c 01 00 00       	call   800216 <cprintf>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  8000da:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8000dd:	e8 39 0b 00 00       	call   800c1b <sys_getenvid>
  8000e2:	83 c4 0c             	add    $0xc,%esp
  8000e5:	53                   	push   %ebx
  8000e6:	50                   	push   %eax
  8000e7:	68 7a 22 80 00       	push   $0x80227a
  8000ec:	e8 25 01 00 00       	call   800216 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000f1:	6a 00                	push   $0x0
  8000f3:	6a 00                	push   $0x0
  8000f5:	6a 00                	push   $0x0
  8000f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000fa:	e8 0b 10 00 00       	call   80110a <ipc_send>
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
  800165:	e8 32 12 00 00       	call   80139c <close_all>
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
  80027c:	e8 7f 1d 00 00       	call   802000 <__udivdi3>
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
  8002ba:	e8 51 1e 00 00       	call   802110 <__umoddi3>
  8002bf:	83 c4 14             	add    $0x14,%esp
  8002c2:	0f be 80 c0 22 80 00 	movsbl 0x8022c0(%eax),%eax
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
  800369:	3e ff 24 85 00 24 80 	notrack jmp *0x802400(,%eax,4)
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
  800436:	8b 14 85 60 25 80 00 	mov    0x802560(,%eax,4),%edx
  80043d:	85 d2                	test   %edx,%edx
  80043f:	74 18                	je     800459 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800441:	52                   	push   %edx
  800442:	68 92 27 80 00       	push   $0x802792
  800447:	53                   	push   %ebx
  800448:	56                   	push   %esi
  800449:	e8 aa fe ff ff       	call   8002f8 <printfmt>
  80044e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800451:	89 7d 14             	mov    %edi,0x14(%ebp)
  800454:	e9 22 02 00 00       	jmp    80067b <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800459:	50                   	push   %eax
  80045a:	68 d8 22 80 00       	push   $0x8022d8
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
  800481:	b8 d1 22 80 00       	mov    $0x8022d1,%eax
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
  800c0a:	68 bf 25 80 00       	push   $0x8025bf
  800c0f:	6a 23                	push   $0x23
  800c11:	68 dc 25 80 00       	push   $0x8025dc
  800c16:	e8 ab 12 00 00       	call   801ec6 <_panic>

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
  800c97:	68 bf 25 80 00       	push   $0x8025bf
  800c9c:	6a 23                	push   $0x23
  800c9e:	68 dc 25 80 00       	push   $0x8025dc
  800ca3:	e8 1e 12 00 00       	call   801ec6 <_panic>

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
  800cdd:	68 bf 25 80 00       	push   $0x8025bf
  800ce2:	6a 23                	push   $0x23
  800ce4:	68 dc 25 80 00       	push   $0x8025dc
  800ce9:	e8 d8 11 00 00       	call   801ec6 <_panic>

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
  800d23:	68 bf 25 80 00       	push   $0x8025bf
  800d28:	6a 23                	push   $0x23
  800d2a:	68 dc 25 80 00       	push   $0x8025dc
  800d2f:	e8 92 11 00 00       	call   801ec6 <_panic>

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
  800d69:	68 bf 25 80 00       	push   $0x8025bf
  800d6e:	6a 23                	push   $0x23
  800d70:	68 dc 25 80 00       	push   $0x8025dc
  800d75:	e8 4c 11 00 00       	call   801ec6 <_panic>

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
  800daf:	68 bf 25 80 00       	push   $0x8025bf
  800db4:	6a 23                	push   $0x23
  800db6:	68 dc 25 80 00       	push   $0x8025dc
  800dbb:	e8 06 11 00 00       	call   801ec6 <_panic>

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
  800df5:	68 bf 25 80 00       	push   $0x8025bf
  800dfa:	6a 23                	push   $0x23
  800dfc:	68 dc 25 80 00       	push   $0x8025dc
  800e01:	e8 c0 10 00 00       	call   801ec6 <_panic>

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
  800e61:	68 bf 25 80 00       	push   $0x8025bf
  800e66:	6a 23                	push   $0x23
  800e68:	68 dc 25 80 00       	push   $0x8025dc
  800e6d:	e8 54 10 00 00       	call   801ec6 <_panic>

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
  800f00:	68 ea 25 80 00       	push   $0x8025ea
  800f05:	6a 1e                	push   $0x1e
  800f07:	68 03 26 80 00       	push   $0x802603
  800f0c:	e8 b5 0f 00 00       	call   801ec6 <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800f11:	50                   	push   %eax
  800f12:	68 0e 26 80 00       	push   $0x80260e
  800f17:	6a 2a                	push   $0x2a
  800f19:	68 03 26 80 00       	push   $0x802603
  800f1e:	e8 a3 0f 00 00       	call   801ec6 <_panic>
        panic("sys_page_map failed %e\n", r);
  800f23:	50                   	push   %eax
  800f24:	68 28 26 80 00       	push   $0x802628
  800f29:	6a 2f                	push   $0x2f
  800f2b:	68 03 26 80 00       	push   $0x802603
  800f30:	e8 91 0f 00 00       	call   801ec6 <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800f35:	50                   	push   %eax
  800f36:	68 40 26 80 00       	push   $0x802640
  800f3b:	6a 32                	push   $0x32
  800f3d:	68 03 26 80 00       	push   $0x802603
  800f42:	e8 7f 0f 00 00       	call   801ec6 <_panic>

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
  800f59:	e8 b2 0f 00 00       	call   801f10 <set_pgfault_handler>
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
  800f7b:	75 4e                	jne    800fcb <fork+0x84>
        envid_t my_envid = sys_getenvid();
  800f7d:	e8 99 fc ff ff       	call   800c1b <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800f82:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f87:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f8a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f8f:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  800f94:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f97:	e9 f1 00 00 00       	jmp    80108d <fork+0x146>
        panic("fork, sys_exofork %e", envid);
  800f9c:	50                   	push   %eax
  800f9d:	68 5a 26 80 00       	push   $0x80265a
  800fa2:	6a 7b                	push   $0x7b
  800fa4:	68 03 26 80 00       	push   $0x802603
  800fa9:	e8 18 0f 00 00       	call   801ec6 <_panic>
        panic("sys_page_map others failed %e\n", r);
  800fae:	50                   	push   %eax
  800faf:	68 a4 26 80 00       	push   $0x8026a4
  800fb4:	6a 51                	push   $0x51
  800fb6:	68 03 26 80 00       	push   $0x802603
  800fbb:	e8 06 0f 00 00       	call   801ec6 <_panic>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800fc0:	83 c3 01             	add    $0x1,%ebx
  800fc3:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800fc9:	74 7c                	je     801047 <fork+0x100>
  800fcb:	89 de                	mov    %ebx,%esi
  800fcd:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800fd0:	89 f0                	mov    %esi,%eax
  800fd2:	c1 e8 16             	shr    $0x16,%eax
  800fd5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fdc:	a8 01                	test   $0x1,%al
  800fde:	74 e0                	je     800fc0 <fork+0x79>
                    (uvpt[pn] & PTE_P) ) {
  800fe0:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800fe7:	a8 01                	test   $0x1,%al
  800fe9:	74 d5                	je     800fc0 <fork+0x79>
    pte_t pte = uvpt[pn];
  800feb:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    if ( (pte & PTE_W) || (pte & PTE_COW) ) {
  800ff2:	25 02 08 00 00       	and    $0x802,%eax
        perm |= PTE_COW;
  800ff7:	83 f8 01             	cmp    $0x1,%eax
  800ffa:	19 ff                	sbb    %edi,%edi
  800ffc:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  801002:	81 c7 05 08 00 00    	add    $0x805,%edi
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	57                   	push   %edi
  80100c:	56                   	push   %esi
  80100d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801010:	56                   	push   %esi
  801011:	6a 00                	push   $0x0
  801013:	e8 90 fc ff ff       	call   800ca8 <sys_page_map>
  801018:	83 c4 20             	add    $0x20,%esp
  80101b:	85 c0                	test   %eax,%eax
  80101d:	78 8f                	js     800fae <fork+0x67>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  80101f:	83 ec 0c             	sub    $0xc,%esp
  801022:	57                   	push   %edi
  801023:	56                   	push   %esi
  801024:	6a 00                	push   $0x0
  801026:	56                   	push   %esi
  801027:	6a 00                	push   $0x0
  801029:	e8 7a fc ff ff       	call   800ca8 <sys_page_map>
  80102e:	83 c4 20             	add    $0x20,%esp
  801031:	85 c0                	test   %eax,%eax
  801033:	79 8b                	jns    800fc0 <fork+0x79>
            panic("sys_page_map mine failed %e\n", r);
  801035:	50                   	push   %eax
  801036:	68 6f 26 80 00       	push   $0x80266f
  80103b:	6a 56                	push   $0x56
  80103d:	68 03 26 80 00       	push   $0x802603
  801042:	e8 7f 0e 00 00       	call   801ec6 <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  801047:	83 ec 04             	sub    $0x4,%esp
  80104a:	6a 07                	push   $0x7
  80104c:	68 00 f0 bf ee       	push   $0xeebff000
  801051:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801054:	57                   	push   %edi
  801055:	e8 07 fc ff ff       	call   800c61 <sys_page_alloc>
  80105a:	83 c4 10             	add    $0x10,%esp
  80105d:	85 c0                	test   %eax,%eax
  80105f:	78 2c                	js     80108d <fork+0x146>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  801061:	a1 08 40 80 00       	mov    0x804008,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  801066:	8b 40 64             	mov    0x64(%eax),%eax
  801069:	83 ec 08             	sub    $0x8,%esp
  80106c:	50                   	push   %eax
  80106d:	57                   	push   %edi
  80106e:	e8 4d fd ff ff       	call   800dc0 <sys_env_set_pgfault_upcall>
  801073:	83 c4 10             	add    $0x10,%esp
  801076:	85 c0                	test   %eax,%eax
  801078:	78 13                	js     80108d <fork+0x146>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  80107a:	83 ec 08             	sub    $0x8,%esp
  80107d:	6a 02                	push   $0x2
  80107f:	57                   	push   %edi
  801080:	e8 af fc ff ff       	call   800d34 <sys_env_set_status>
  801085:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  801088:	85 c0                	test   %eax,%eax
  80108a:	0f 49 c7             	cmovns %edi,%eax
    }

}
  80108d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    

00801095 <sfork>:

// Challenge!
int
sfork(void)
{
  801095:	f3 0f 1e fb          	endbr32 
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80109f:	68 8c 26 80 00       	push   $0x80268c
  8010a4:	68 a5 00 00 00       	push   $0xa5
  8010a9:	68 03 26 80 00       	push   $0x802603
  8010ae:	e8 13 0e 00 00       	call   801ec6 <_panic>

008010b3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010b3:	f3 0f 1e fb          	endbr32 
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	56                   	push   %esi
  8010bb:	53                   	push   %ebx
  8010bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8010bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8010cc:	0f 44 c2             	cmove  %edx,%eax
  8010cf:	83 ec 0c             	sub    $0xc,%esp
  8010d2:	50                   	push   %eax
  8010d3:	e8 55 fd ff ff       	call   800e2d <sys_ipc_recv>
  8010d8:	83 c4 10             	add    $0x10,%esp
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	78 24                	js     801103 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  8010df:	85 f6                	test   %esi,%esi
  8010e1:	74 0a                	je     8010ed <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  8010e3:	a1 08 40 80 00       	mov    0x804008,%eax
  8010e8:	8b 40 78             	mov    0x78(%eax),%eax
  8010eb:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  8010ed:	85 db                	test   %ebx,%ebx
  8010ef:	74 0a                	je     8010fb <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  8010f1:	a1 08 40 80 00       	mov    0x804008,%eax
  8010f6:	8b 40 74             	mov    0x74(%eax),%eax
  8010f9:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  8010fb:	a1 08 40 80 00       	mov    0x804008,%eax
  801100:	8b 40 70             	mov    0x70(%eax),%eax
}
  801103:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801106:	5b                   	pop    %ebx
  801107:	5e                   	pop    %esi
  801108:	5d                   	pop    %ebp
  801109:	c3                   	ret    

0080110a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80110a:	f3 0f 1e fb          	endbr32 
  80110e:	55                   	push   %ebp
  80110f:	89 e5                	mov    %esp,%ebp
  801111:	57                   	push   %edi
  801112:	56                   	push   %esi
  801113:	53                   	push   %ebx
  801114:	83 ec 1c             	sub    $0x1c,%esp
  801117:	8b 45 10             	mov    0x10(%ebp),%eax
  80111a:	85 c0                	test   %eax,%eax
  80111c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801121:	0f 45 d0             	cmovne %eax,%edx
  801124:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801126:	be 01 00 00 00       	mov    $0x1,%esi
  80112b:	eb 1f                	jmp    80114c <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  80112d:	e8 0c fb ff ff       	call   800c3e <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801132:	83 c3 01             	add    $0x1,%ebx
  801135:	39 de                	cmp    %ebx,%esi
  801137:	7f f4                	jg     80112d <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801139:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  80113b:	83 fe 11             	cmp    $0x11,%esi
  80113e:	b8 01 00 00 00       	mov    $0x1,%eax
  801143:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801146:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  80114a:	75 1c                	jne    801168 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  80114c:	ff 75 14             	pushl  0x14(%ebp)
  80114f:	57                   	push   %edi
  801150:	ff 75 0c             	pushl  0xc(%ebp)
  801153:	ff 75 08             	pushl  0x8(%ebp)
  801156:	e8 ab fc ff ff       	call   800e06 <sys_ipc_try_send>
  80115b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  80115e:	83 c4 10             	add    $0x10,%esp
  801161:	bb 00 00 00 00       	mov    $0x0,%ebx
  801166:	eb cd                	jmp    801135 <ipc_send+0x2b>
}
  801168:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116b:	5b                   	pop    %ebx
  80116c:	5e                   	pop    %esi
  80116d:	5f                   	pop    %edi
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    

00801170 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801170:	f3 0f 1e fb          	endbr32 
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80117a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80117f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801182:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801188:	8b 52 50             	mov    0x50(%edx),%edx
  80118b:	39 ca                	cmp    %ecx,%edx
  80118d:	74 11                	je     8011a0 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  80118f:	83 c0 01             	add    $0x1,%eax
  801192:	3d 00 04 00 00       	cmp    $0x400,%eax
  801197:	75 e6                	jne    80117f <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801199:	b8 00 00 00 00       	mov    $0x0,%eax
  80119e:	eb 0b                	jmp    8011ab <ipc_find_env+0x3b>
			return envs[i].env_id;
  8011a0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011a3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011a8:	8b 40 48             	mov    0x48(%eax),%eax
}
  8011ab:	5d                   	pop    %ebp
  8011ac:	c3                   	ret    

008011ad <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011ad:	f3 0f 1e fb          	endbr32 
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b7:	05 00 00 00 30       	add    $0x30000000,%eax
  8011bc:	c1 e8 0c             	shr    $0xc,%eax
}
  8011bf:	5d                   	pop    %ebp
  8011c0:	c3                   	ret    

008011c1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011c1:	f3 0f 1e fb          	endbr32 
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cb:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011d5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011da:	5d                   	pop    %ebp
  8011db:	c3                   	ret    

008011dc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011dc:	f3 0f 1e fb          	endbr32 
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011e8:	89 c2                	mov    %eax,%edx
  8011ea:	c1 ea 16             	shr    $0x16,%edx
  8011ed:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f4:	f6 c2 01             	test   $0x1,%dl
  8011f7:	74 2d                	je     801226 <fd_alloc+0x4a>
  8011f9:	89 c2                	mov    %eax,%edx
  8011fb:	c1 ea 0c             	shr    $0xc,%edx
  8011fe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801205:	f6 c2 01             	test   $0x1,%dl
  801208:	74 1c                	je     801226 <fd_alloc+0x4a>
  80120a:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80120f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801214:	75 d2                	jne    8011e8 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801216:	8b 45 08             	mov    0x8(%ebp),%eax
  801219:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80121f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801224:	eb 0a                	jmp    801230 <fd_alloc+0x54>
			*fd_store = fd;
  801226:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801229:	89 01                	mov    %eax,(%ecx)
			return 0;
  80122b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    

00801232 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801232:	f3 0f 1e fb          	endbr32 
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80123c:	83 f8 1f             	cmp    $0x1f,%eax
  80123f:	77 30                	ja     801271 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801241:	c1 e0 0c             	shl    $0xc,%eax
  801244:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801249:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80124f:	f6 c2 01             	test   $0x1,%dl
  801252:	74 24                	je     801278 <fd_lookup+0x46>
  801254:	89 c2                	mov    %eax,%edx
  801256:	c1 ea 0c             	shr    $0xc,%edx
  801259:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801260:	f6 c2 01             	test   $0x1,%dl
  801263:	74 1a                	je     80127f <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801265:	8b 55 0c             	mov    0xc(%ebp),%edx
  801268:	89 02                	mov    %eax,(%edx)
	return 0;
  80126a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80126f:	5d                   	pop    %ebp
  801270:	c3                   	ret    
		return -E_INVAL;
  801271:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801276:	eb f7                	jmp    80126f <fd_lookup+0x3d>
		return -E_INVAL;
  801278:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127d:	eb f0                	jmp    80126f <fd_lookup+0x3d>
  80127f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801284:	eb e9                	jmp    80126f <fd_lookup+0x3d>

00801286 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801286:	f3 0f 1e fb          	endbr32 
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	83 ec 08             	sub    $0x8,%esp
  801290:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801293:	ba 40 27 80 00       	mov    $0x802740,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801298:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80129d:	39 08                	cmp    %ecx,(%eax)
  80129f:	74 33                	je     8012d4 <dev_lookup+0x4e>
  8012a1:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8012a4:	8b 02                	mov    (%edx),%eax
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	75 f3                	jne    80129d <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012aa:	a1 08 40 80 00       	mov    0x804008,%eax
  8012af:	8b 40 48             	mov    0x48(%eax),%eax
  8012b2:	83 ec 04             	sub    $0x4,%esp
  8012b5:	51                   	push   %ecx
  8012b6:	50                   	push   %eax
  8012b7:	68 c4 26 80 00       	push   $0x8026c4
  8012bc:	e8 55 ef ff ff       	call   800216 <cprintf>
	*dev = 0;
  8012c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012ca:	83 c4 10             	add    $0x10,%esp
  8012cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012d2:	c9                   	leave  
  8012d3:	c3                   	ret    
			*dev = devtab[i];
  8012d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012de:	eb f2                	jmp    8012d2 <dev_lookup+0x4c>

008012e0 <fd_close>:
{
  8012e0:	f3 0f 1e fb          	endbr32 
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	57                   	push   %edi
  8012e8:	56                   	push   %esi
  8012e9:	53                   	push   %ebx
  8012ea:	83 ec 24             	sub    $0x24,%esp
  8012ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8012f0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012f3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012f6:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012f7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012fd:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801300:	50                   	push   %eax
  801301:	e8 2c ff ff ff       	call   801232 <fd_lookup>
  801306:	89 c3                	mov    %eax,%ebx
  801308:	83 c4 10             	add    $0x10,%esp
  80130b:	85 c0                	test   %eax,%eax
  80130d:	78 05                	js     801314 <fd_close+0x34>
	    || fd != fd2)
  80130f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801312:	74 16                	je     80132a <fd_close+0x4a>
		return (must_exist ? r : 0);
  801314:	89 f8                	mov    %edi,%eax
  801316:	84 c0                	test   %al,%al
  801318:	b8 00 00 00 00       	mov    $0x0,%eax
  80131d:	0f 44 d8             	cmove  %eax,%ebx
}
  801320:	89 d8                	mov    %ebx,%eax
  801322:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801325:	5b                   	pop    %ebx
  801326:	5e                   	pop    %esi
  801327:	5f                   	pop    %edi
  801328:	5d                   	pop    %ebp
  801329:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80132a:	83 ec 08             	sub    $0x8,%esp
  80132d:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801330:	50                   	push   %eax
  801331:	ff 36                	pushl  (%esi)
  801333:	e8 4e ff ff ff       	call   801286 <dev_lookup>
  801338:	89 c3                	mov    %eax,%ebx
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	85 c0                	test   %eax,%eax
  80133f:	78 1a                	js     80135b <fd_close+0x7b>
		if (dev->dev_close)
  801341:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801344:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801347:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80134c:	85 c0                	test   %eax,%eax
  80134e:	74 0b                	je     80135b <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801350:	83 ec 0c             	sub    $0xc,%esp
  801353:	56                   	push   %esi
  801354:	ff d0                	call   *%eax
  801356:	89 c3                	mov    %eax,%ebx
  801358:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80135b:	83 ec 08             	sub    $0x8,%esp
  80135e:	56                   	push   %esi
  80135f:	6a 00                	push   $0x0
  801361:	e8 88 f9 ff ff       	call   800cee <sys_page_unmap>
	return r;
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	eb b5                	jmp    801320 <fd_close+0x40>

0080136b <close>:

int
close(int fdnum)
{
  80136b:	f3 0f 1e fb          	endbr32 
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801375:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801378:	50                   	push   %eax
  801379:	ff 75 08             	pushl  0x8(%ebp)
  80137c:	e8 b1 fe ff ff       	call   801232 <fd_lookup>
  801381:	83 c4 10             	add    $0x10,%esp
  801384:	85 c0                	test   %eax,%eax
  801386:	79 02                	jns    80138a <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801388:	c9                   	leave  
  801389:	c3                   	ret    
		return fd_close(fd, 1);
  80138a:	83 ec 08             	sub    $0x8,%esp
  80138d:	6a 01                	push   $0x1
  80138f:	ff 75 f4             	pushl  -0xc(%ebp)
  801392:	e8 49 ff ff ff       	call   8012e0 <fd_close>
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	eb ec                	jmp    801388 <close+0x1d>

0080139c <close_all>:

void
close_all(void)
{
  80139c:	f3 0f 1e fb          	endbr32 
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
  8013a3:	53                   	push   %ebx
  8013a4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013ac:	83 ec 0c             	sub    $0xc,%esp
  8013af:	53                   	push   %ebx
  8013b0:	e8 b6 ff ff ff       	call   80136b <close>
	for (i = 0; i < MAXFD; i++)
  8013b5:	83 c3 01             	add    $0x1,%ebx
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	83 fb 20             	cmp    $0x20,%ebx
  8013be:	75 ec                	jne    8013ac <close_all+0x10>
}
  8013c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c3:	c9                   	leave  
  8013c4:	c3                   	ret    

008013c5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013c5:	f3 0f 1e fb          	endbr32 
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
  8013cc:	57                   	push   %edi
  8013cd:	56                   	push   %esi
  8013ce:	53                   	push   %ebx
  8013cf:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013d2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d5:	50                   	push   %eax
  8013d6:	ff 75 08             	pushl  0x8(%ebp)
  8013d9:	e8 54 fe ff ff       	call   801232 <fd_lookup>
  8013de:	89 c3                	mov    %eax,%ebx
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	0f 88 81 00 00 00    	js     80146c <dup+0xa7>
		return r;
	close(newfdnum);
  8013eb:	83 ec 0c             	sub    $0xc,%esp
  8013ee:	ff 75 0c             	pushl  0xc(%ebp)
  8013f1:	e8 75 ff ff ff       	call   80136b <close>

	newfd = INDEX2FD(newfdnum);
  8013f6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013f9:	c1 e6 0c             	shl    $0xc,%esi
  8013fc:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801402:	83 c4 04             	add    $0x4,%esp
  801405:	ff 75 e4             	pushl  -0x1c(%ebp)
  801408:	e8 b4 fd ff ff       	call   8011c1 <fd2data>
  80140d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80140f:	89 34 24             	mov    %esi,(%esp)
  801412:	e8 aa fd ff ff       	call   8011c1 <fd2data>
  801417:	83 c4 10             	add    $0x10,%esp
  80141a:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80141c:	89 d8                	mov    %ebx,%eax
  80141e:	c1 e8 16             	shr    $0x16,%eax
  801421:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801428:	a8 01                	test   $0x1,%al
  80142a:	74 11                	je     80143d <dup+0x78>
  80142c:	89 d8                	mov    %ebx,%eax
  80142e:	c1 e8 0c             	shr    $0xc,%eax
  801431:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801438:	f6 c2 01             	test   $0x1,%dl
  80143b:	75 39                	jne    801476 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80143d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801440:	89 d0                	mov    %edx,%eax
  801442:	c1 e8 0c             	shr    $0xc,%eax
  801445:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80144c:	83 ec 0c             	sub    $0xc,%esp
  80144f:	25 07 0e 00 00       	and    $0xe07,%eax
  801454:	50                   	push   %eax
  801455:	56                   	push   %esi
  801456:	6a 00                	push   $0x0
  801458:	52                   	push   %edx
  801459:	6a 00                	push   $0x0
  80145b:	e8 48 f8 ff ff       	call   800ca8 <sys_page_map>
  801460:	89 c3                	mov    %eax,%ebx
  801462:	83 c4 20             	add    $0x20,%esp
  801465:	85 c0                	test   %eax,%eax
  801467:	78 31                	js     80149a <dup+0xd5>
		goto err;

	return newfdnum;
  801469:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80146c:	89 d8                	mov    %ebx,%eax
  80146e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801471:	5b                   	pop    %ebx
  801472:	5e                   	pop    %esi
  801473:	5f                   	pop    %edi
  801474:	5d                   	pop    %ebp
  801475:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801476:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80147d:	83 ec 0c             	sub    $0xc,%esp
  801480:	25 07 0e 00 00       	and    $0xe07,%eax
  801485:	50                   	push   %eax
  801486:	57                   	push   %edi
  801487:	6a 00                	push   $0x0
  801489:	53                   	push   %ebx
  80148a:	6a 00                	push   $0x0
  80148c:	e8 17 f8 ff ff       	call   800ca8 <sys_page_map>
  801491:	89 c3                	mov    %eax,%ebx
  801493:	83 c4 20             	add    $0x20,%esp
  801496:	85 c0                	test   %eax,%eax
  801498:	79 a3                	jns    80143d <dup+0x78>
	sys_page_unmap(0, newfd);
  80149a:	83 ec 08             	sub    $0x8,%esp
  80149d:	56                   	push   %esi
  80149e:	6a 00                	push   $0x0
  8014a0:	e8 49 f8 ff ff       	call   800cee <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014a5:	83 c4 08             	add    $0x8,%esp
  8014a8:	57                   	push   %edi
  8014a9:	6a 00                	push   $0x0
  8014ab:	e8 3e f8 ff ff       	call   800cee <sys_page_unmap>
	return r;
  8014b0:	83 c4 10             	add    $0x10,%esp
  8014b3:	eb b7                	jmp    80146c <dup+0xa7>

008014b5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014b5:	f3 0f 1e fb          	endbr32 
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
  8014bc:	53                   	push   %ebx
  8014bd:	83 ec 1c             	sub    $0x1c,%esp
  8014c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c6:	50                   	push   %eax
  8014c7:	53                   	push   %ebx
  8014c8:	e8 65 fd ff ff       	call   801232 <fd_lookup>
  8014cd:	83 c4 10             	add    $0x10,%esp
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	78 3f                	js     801513 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d4:	83 ec 08             	sub    $0x8,%esp
  8014d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014da:	50                   	push   %eax
  8014db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014de:	ff 30                	pushl  (%eax)
  8014e0:	e8 a1 fd ff ff       	call   801286 <dev_lookup>
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	78 27                	js     801513 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ef:	8b 42 08             	mov    0x8(%edx),%eax
  8014f2:	83 e0 03             	and    $0x3,%eax
  8014f5:	83 f8 01             	cmp    $0x1,%eax
  8014f8:	74 1e                	je     801518 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fd:	8b 40 08             	mov    0x8(%eax),%eax
  801500:	85 c0                	test   %eax,%eax
  801502:	74 35                	je     801539 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801504:	83 ec 04             	sub    $0x4,%esp
  801507:	ff 75 10             	pushl  0x10(%ebp)
  80150a:	ff 75 0c             	pushl  0xc(%ebp)
  80150d:	52                   	push   %edx
  80150e:	ff d0                	call   *%eax
  801510:	83 c4 10             	add    $0x10,%esp
}
  801513:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801516:	c9                   	leave  
  801517:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801518:	a1 08 40 80 00       	mov    0x804008,%eax
  80151d:	8b 40 48             	mov    0x48(%eax),%eax
  801520:	83 ec 04             	sub    $0x4,%esp
  801523:	53                   	push   %ebx
  801524:	50                   	push   %eax
  801525:	68 05 27 80 00       	push   $0x802705
  80152a:	e8 e7 ec ff ff       	call   800216 <cprintf>
		return -E_INVAL;
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801537:	eb da                	jmp    801513 <read+0x5e>
		return -E_NOT_SUPP;
  801539:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80153e:	eb d3                	jmp    801513 <read+0x5e>

00801540 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801540:	f3 0f 1e fb          	endbr32 
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	57                   	push   %edi
  801548:	56                   	push   %esi
  801549:	53                   	push   %ebx
  80154a:	83 ec 0c             	sub    $0xc,%esp
  80154d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801550:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801553:	bb 00 00 00 00       	mov    $0x0,%ebx
  801558:	eb 02                	jmp    80155c <readn+0x1c>
  80155a:	01 c3                	add    %eax,%ebx
  80155c:	39 f3                	cmp    %esi,%ebx
  80155e:	73 21                	jae    801581 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801560:	83 ec 04             	sub    $0x4,%esp
  801563:	89 f0                	mov    %esi,%eax
  801565:	29 d8                	sub    %ebx,%eax
  801567:	50                   	push   %eax
  801568:	89 d8                	mov    %ebx,%eax
  80156a:	03 45 0c             	add    0xc(%ebp),%eax
  80156d:	50                   	push   %eax
  80156e:	57                   	push   %edi
  80156f:	e8 41 ff ff ff       	call   8014b5 <read>
		if (m < 0)
  801574:	83 c4 10             	add    $0x10,%esp
  801577:	85 c0                	test   %eax,%eax
  801579:	78 04                	js     80157f <readn+0x3f>
			return m;
		if (m == 0)
  80157b:	75 dd                	jne    80155a <readn+0x1a>
  80157d:	eb 02                	jmp    801581 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80157f:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801581:	89 d8                	mov    %ebx,%eax
  801583:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801586:	5b                   	pop    %ebx
  801587:	5e                   	pop    %esi
  801588:	5f                   	pop    %edi
  801589:	5d                   	pop    %ebp
  80158a:	c3                   	ret    

0080158b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80158b:	f3 0f 1e fb          	endbr32 
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	53                   	push   %ebx
  801593:	83 ec 1c             	sub    $0x1c,%esp
  801596:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801599:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159c:	50                   	push   %eax
  80159d:	53                   	push   %ebx
  80159e:	e8 8f fc ff ff       	call   801232 <fd_lookup>
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	85 c0                	test   %eax,%eax
  8015a8:	78 3a                	js     8015e4 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015aa:	83 ec 08             	sub    $0x8,%esp
  8015ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b0:	50                   	push   %eax
  8015b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b4:	ff 30                	pushl  (%eax)
  8015b6:	e8 cb fc ff ff       	call   801286 <dev_lookup>
  8015bb:	83 c4 10             	add    $0x10,%esp
  8015be:	85 c0                	test   %eax,%eax
  8015c0:	78 22                	js     8015e4 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015c9:	74 1e                	je     8015e9 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ce:	8b 52 0c             	mov    0xc(%edx),%edx
  8015d1:	85 d2                	test   %edx,%edx
  8015d3:	74 35                	je     80160a <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015d5:	83 ec 04             	sub    $0x4,%esp
  8015d8:	ff 75 10             	pushl  0x10(%ebp)
  8015db:	ff 75 0c             	pushl  0xc(%ebp)
  8015de:	50                   	push   %eax
  8015df:	ff d2                	call   *%edx
  8015e1:	83 c4 10             	add    $0x10,%esp
}
  8015e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e7:	c9                   	leave  
  8015e8:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015e9:	a1 08 40 80 00       	mov    0x804008,%eax
  8015ee:	8b 40 48             	mov    0x48(%eax),%eax
  8015f1:	83 ec 04             	sub    $0x4,%esp
  8015f4:	53                   	push   %ebx
  8015f5:	50                   	push   %eax
  8015f6:	68 21 27 80 00       	push   $0x802721
  8015fb:	e8 16 ec ff ff       	call   800216 <cprintf>
		return -E_INVAL;
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801608:	eb da                	jmp    8015e4 <write+0x59>
		return -E_NOT_SUPP;
  80160a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80160f:	eb d3                	jmp    8015e4 <write+0x59>

00801611 <seek>:

int
seek(int fdnum, off_t offset)
{
  801611:	f3 0f 1e fb          	endbr32 
  801615:	55                   	push   %ebp
  801616:	89 e5                	mov    %esp,%ebp
  801618:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80161b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161e:	50                   	push   %eax
  80161f:	ff 75 08             	pushl  0x8(%ebp)
  801622:	e8 0b fc ff ff       	call   801232 <fd_lookup>
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 0e                	js     80163c <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80162e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801631:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801634:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801637:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80163c:	c9                   	leave  
  80163d:	c3                   	ret    

0080163e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80163e:	f3 0f 1e fb          	endbr32 
  801642:	55                   	push   %ebp
  801643:	89 e5                	mov    %esp,%ebp
  801645:	53                   	push   %ebx
  801646:	83 ec 1c             	sub    $0x1c,%esp
  801649:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164f:	50                   	push   %eax
  801650:	53                   	push   %ebx
  801651:	e8 dc fb ff ff       	call   801232 <fd_lookup>
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	85 c0                	test   %eax,%eax
  80165b:	78 37                	js     801694 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165d:	83 ec 08             	sub    $0x8,%esp
  801660:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801663:	50                   	push   %eax
  801664:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801667:	ff 30                	pushl  (%eax)
  801669:	e8 18 fc ff ff       	call   801286 <dev_lookup>
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	85 c0                	test   %eax,%eax
  801673:	78 1f                	js     801694 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801675:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801678:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80167c:	74 1b                	je     801699 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80167e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801681:	8b 52 18             	mov    0x18(%edx),%edx
  801684:	85 d2                	test   %edx,%edx
  801686:	74 32                	je     8016ba <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801688:	83 ec 08             	sub    $0x8,%esp
  80168b:	ff 75 0c             	pushl  0xc(%ebp)
  80168e:	50                   	push   %eax
  80168f:	ff d2                	call   *%edx
  801691:	83 c4 10             	add    $0x10,%esp
}
  801694:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801697:	c9                   	leave  
  801698:	c3                   	ret    
			thisenv->env_id, fdnum);
  801699:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80169e:	8b 40 48             	mov    0x48(%eax),%eax
  8016a1:	83 ec 04             	sub    $0x4,%esp
  8016a4:	53                   	push   %ebx
  8016a5:	50                   	push   %eax
  8016a6:	68 e4 26 80 00       	push   $0x8026e4
  8016ab:	e8 66 eb ff ff       	call   800216 <cprintf>
		return -E_INVAL;
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016b8:	eb da                	jmp    801694 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8016ba:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016bf:	eb d3                	jmp    801694 <ftruncate+0x56>

008016c1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016c1:	f3 0f 1e fb          	endbr32 
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	53                   	push   %ebx
  8016c9:	83 ec 1c             	sub    $0x1c,%esp
  8016cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d2:	50                   	push   %eax
  8016d3:	ff 75 08             	pushl  0x8(%ebp)
  8016d6:	e8 57 fb ff ff       	call   801232 <fd_lookup>
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	78 4b                	js     80172d <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e2:	83 ec 08             	sub    $0x8,%esp
  8016e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e8:	50                   	push   %eax
  8016e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ec:	ff 30                	pushl  (%eax)
  8016ee:	e8 93 fb ff ff       	call   801286 <dev_lookup>
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	78 33                	js     80172d <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8016fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016fd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801701:	74 2f                	je     801732 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801703:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801706:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80170d:	00 00 00 
	stat->st_isdir = 0;
  801710:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801717:	00 00 00 
	stat->st_dev = dev;
  80171a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801720:	83 ec 08             	sub    $0x8,%esp
  801723:	53                   	push   %ebx
  801724:	ff 75 f0             	pushl  -0x10(%ebp)
  801727:	ff 50 14             	call   *0x14(%eax)
  80172a:	83 c4 10             	add    $0x10,%esp
}
  80172d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801730:	c9                   	leave  
  801731:	c3                   	ret    
		return -E_NOT_SUPP;
  801732:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801737:	eb f4                	jmp    80172d <fstat+0x6c>

00801739 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801739:	f3 0f 1e fb          	endbr32 
  80173d:	55                   	push   %ebp
  80173e:	89 e5                	mov    %esp,%ebp
  801740:	56                   	push   %esi
  801741:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801742:	83 ec 08             	sub    $0x8,%esp
  801745:	6a 00                	push   $0x0
  801747:	ff 75 08             	pushl  0x8(%ebp)
  80174a:	e8 cf 01 00 00       	call   80191e <open>
  80174f:	89 c3                	mov    %eax,%ebx
  801751:	83 c4 10             	add    $0x10,%esp
  801754:	85 c0                	test   %eax,%eax
  801756:	78 1b                	js     801773 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801758:	83 ec 08             	sub    $0x8,%esp
  80175b:	ff 75 0c             	pushl  0xc(%ebp)
  80175e:	50                   	push   %eax
  80175f:	e8 5d ff ff ff       	call   8016c1 <fstat>
  801764:	89 c6                	mov    %eax,%esi
	close(fd);
  801766:	89 1c 24             	mov    %ebx,(%esp)
  801769:	e8 fd fb ff ff       	call   80136b <close>
	return r;
  80176e:	83 c4 10             	add    $0x10,%esp
  801771:	89 f3                	mov    %esi,%ebx
}
  801773:	89 d8                	mov    %ebx,%eax
  801775:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801778:	5b                   	pop    %ebx
  801779:	5e                   	pop    %esi
  80177a:	5d                   	pop    %ebp
  80177b:	c3                   	ret    

0080177c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	56                   	push   %esi
  801780:	53                   	push   %ebx
  801781:	89 c6                	mov    %eax,%esi
  801783:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801785:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80178c:	74 27                	je     8017b5 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80178e:	6a 07                	push   $0x7
  801790:	68 00 50 80 00       	push   $0x805000
  801795:	56                   	push   %esi
  801796:	ff 35 00 40 80 00    	pushl  0x804000
  80179c:	e8 69 f9 ff ff       	call   80110a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017a1:	83 c4 0c             	add    $0xc,%esp
  8017a4:	6a 00                	push   $0x0
  8017a6:	53                   	push   %ebx
  8017a7:	6a 00                	push   $0x0
  8017a9:	e8 05 f9 ff ff       	call   8010b3 <ipc_recv>
}
  8017ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b1:	5b                   	pop    %ebx
  8017b2:	5e                   	pop    %esi
  8017b3:	5d                   	pop    %ebp
  8017b4:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017b5:	83 ec 0c             	sub    $0xc,%esp
  8017b8:	6a 01                	push   $0x1
  8017ba:	e8 b1 f9 ff ff       	call   801170 <ipc_find_env>
  8017bf:	a3 00 40 80 00       	mov    %eax,0x804000
  8017c4:	83 c4 10             	add    $0x10,%esp
  8017c7:	eb c5                	jmp    80178e <fsipc+0x12>

008017c9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017c9:	f3 0f 1e fb          	endbr32 
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017eb:	b8 02 00 00 00       	mov    $0x2,%eax
  8017f0:	e8 87 ff ff ff       	call   80177c <fsipc>
}
  8017f5:	c9                   	leave  
  8017f6:	c3                   	ret    

008017f7 <devfile_flush>:
{
  8017f7:	f3 0f 1e fb          	endbr32 
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801801:	8b 45 08             	mov    0x8(%ebp),%eax
  801804:	8b 40 0c             	mov    0xc(%eax),%eax
  801807:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80180c:	ba 00 00 00 00       	mov    $0x0,%edx
  801811:	b8 06 00 00 00       	mov    $0x6,%eax
  801816:	e8 61 ff ff ff       	call   80177c <fsipc>
}
  80181b:	c9                   	leave  
  80181c:	c3                   	ret    

0080181d <devfile_stat>:
{
  80181d:	f3 0f 1e fb          	endbr32 
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	53                   	push   %ebx
  801825:	83 ec 04             	sub    $0x4,%esp
  801828:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80182b:	8b 45 08             	mov    0x8(%ebp),%eax
  80182e:	8b 40 0c             	mov    0xc(%eax),%eax
  801831:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801836:	ba 00 00 00 00       	mov    $0x0,%edx
  80183b:	b8 05 00 00 00       	mov    $0x5,%eax
  801840:	e8 37 ff ff ff       	call   80177c <fsipc>
  801845:	85 c0                	test   %eax,%eax
  801847:	78 2c                	js     801875 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801849:	83 ec 08             	sub    $0x8,%esp
  80184c:	68 00 50 80 00       	push   $0x805000
  801851:	53                   	push   %ebx
  801852:	e8 c8 ef ff ff       	call   80081f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801857:	a1 80 50 80 00       	mov    0x805080,%eax
  80185c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801862:	a1 84 50 80 00       	mov    0x805084,%eax
  801867:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80186d:	83 c4 10             	add    $0x10,%esp
  801870:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801875:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801878:	c9                   	leave  
  801879:	c3                   	ret    

0080187a <devfile_write>:
{
  80187a:	f3 0f 1e fb          	endbr32 
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	83 ec 0c             	sub    $0xc,%esp
	panic("devfile_write not implemented");
  801884:	68 50 27 80 00       	push   $0x802750
  801889:	68 90 00 00 00       	push   $0x90
  80188e:	68 6e 27 80 00       	push   $0x80276e
  801893:	e8 2e 06 00 00       	call   801ec6 <_panic>

00801898 <devfile_read>:
{
  801898:	f3 0f 1e fb          	endbr32 
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	56                   	push   %esi
  8018a0:	53                   	push   %ebx
  8018a1:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018aa:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018af:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ba:	b8 03 00 00 00       	mov    $0x3,%eax
  8018bf:	e8 b8 fe ff ff       	call   80177c <fsipc>
  8018c4:	89 c3                	mov    %eax,%ebx
  8018c6:	85 c0                	test   %eax,%eax
  8018c8:	78 1f                	js     8018e9 <devfile_read+0x51>
	assert(r <= n);
  8018ca:	39 f0                	cmp    %esi,%eax
  8018cc:	77 24                	ja     8018f2 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8018ce:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018d3:	7f 33                	jg     801908 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018d5:	83 ec 04             	sub    $0x4,%esp
  8018d8:	50                   	push   %eax
  8018d9:	68 00 50 80 00       	push   $0x805000
  8018de:	ff 75 0c             	pushl  0xc(%ebp)
  8018e1:	e8 ef f0 ff ff       	call   8009d5 <memmove>
	return r;
  8018e6:	83 c4 10             	add    $0x10,%esp
}
  8018e9:	89 d8                	mov    %ebx,%eax
  8018eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ee:	5b                   	pop    %ebx
  8018ef:	5e                   	pop    %esi
  8018f0:	5d                   	pop    %ebp
  8018f1:	c3                   	ret    
	assert(r <= n);
  8018f2:	68 79 27 80 00       	push   $0x802779
  8018f7:	68 80 27 80 00       	push   $0x802780
  8018fc:	6a 7c                	push   $0x7c
  8018fe:	68 6e 27 80 00       	push   $0x80276e
  801903:	e8 be 05 00 00       	call   801ec6 <_panic>
	assert(r <= PGSIZE);
  801908:	68 95 27 80 00       	push   $0x802795
  80190d:	68 80 27 80 00       	push   $0x802780
  801912:	6a 7d                	push   $0x7d
  801914:	68 6e 27 80 00       	push   $0x80276e
  801919:	e8 a8 05 00 00       	call   801ec6 <_panic>

0080191e <open>:
{
  80191e:	f3 0f 1e fb          	endbr32 
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
  801925:	56                   	push   %esi
  801926:	53                   	push   %ebx
  801927:	83 ec 1c             	sub    $0x1c,%esp
  80192a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80192d:	56                   	push   %esi
  80192e:	e8 a9 ee ff ff       	call   8007dc <strlen>
  801933:	83 c4 10             	add    $0x10,%esp
  801936:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80193b:	7f 6c                	jg     8019a9 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80193d:	83 ec 0c             	sub    $0xc,%esp
  801940:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801943:	50                   	push   %eax
  801944:	e8 93 f8 ff ff       	call   8011dc <fd_alloc>
  801949:	89 c3                	mov    %eax,%ebx
  80194b:	83 c4 10             	add    $0x10,%esp
  80194e:	85 c0                	test   %eax,%eax
  801950:	78 3c                	js     80198e <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801952:	83 ec 08             	sub    $0x8,%esp
  801955:	56                   	push   %esi
  801956:	68 00 50 80 00       	push   $0x805000
  80195b:	e8 bf ee ff ff       	call   80081f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801960:	8b 45 0c             	mov    0xc(%ebp),%eax
  801963:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801968:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80196b:	b8 01 00 00 00       	mov    $0x1,%eax
  801970:	e8 07 fe ff ff       	call   80177c <fsipc>
  801975:	89 c3                	mov    %eax,%ebx
  801977:	83 c4 10             	add    $0x10,%esp
  80197a:	85 c0                	test   %eax,%eax
  80197c:	78 19                	js     801997 <open+0x79>
	return fd2num(fd);
  80197e:	83 ec 0c             	sub    $0xc,%esp
  801981:	ff 75 f4             	pushl  -0xc(%ebp)
  801984:	e8 24 f8 ff ff       	call   8011ad <fd2num>
  801989:	89 c3                	mov    %eax,%ebx
  80198b:	83 c4 10             	add    $0x10,%esp
}
  80198e:	89 d8                	mov    %ebx,%eax
  801990:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801993:	5b                   	pop    %ebx
  801994:	5e                   	pop    %esi
  801995:	5d                   	pop    %ebp
  801996:	c3                   	ret    
		fd_close(fd, 0);
  801997:	83 ec 08             	sub    $0x8,%esp
  80199a:	6a 00                	push   $0x0
  80199c:	ff 75 f4             	pushl  -0xc(%ebp)
  80199f:	e8 3c f9 ff ff       	call   8012e0 <fd_close>
		return r;
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	eb e5                	jmp    80198e <open+0x70>
		return -E_BAD_PATH;
  8019a9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019ae:	eb de                	jmp    80198e <open+0x70>

008019b0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019b0:	f3 0f 1e fb          	endbr32 
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8019bf:	b8 08 00 00 00       	mov    $0x8,%eax
  8019c4:	e8 b3 fd ff ff       	call   80177c <fsipc>
}
  8019c9:	c9                   	leave  
  8019ca:	c3                   	ret    

008019cb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019cb:	f3 0f 1e fb          	endbr32 
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	56                   	push   %esi
  8019d3:	53                   	push   %ebx
  8019d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019d7:	83 ec 0c             	sub    $0xc,%esp
  8019da:	ff 75 08             	pushl  0x8(%ebp)
  8019dd:	e8 df f7 ff ff       	call   8011c1 <fd2data>
  8019e2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019e4:	83 c4 08             	add    $0x8,%esp
  8019e7:	68 a1 27 80 00       	push   $0x8027a1
  8019ec:	53                   	push   %ebx
  8019ed:	e8 2d ee ff ff       	call   80081f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019f2:	8b 46 04             	mov    0x4(%esi),%eax
  8019f5:	2b 06                	sub    (%esi),%eax
  8019f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019fd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a04:	00 00 00 
	stat->st_dev = &devpipe;
  801a07:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a0e:	30 80 00 
	return 0;
}
  801a11:	b8 00 00 00 00       	mov    $0x0,%eax
  801a16:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a19:	5b                   	pop    %ebx
  801a1a:	5e                   	pop    %esi
  801a1b:	5d                   	pop    %ebp
  801a1c:	c3                   	ret    

00801a1d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a1d:	f3 0f 1e fb          	endbr32 
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	53                   	push   %ebx
  801a25:	83 ec 0c             	sub    $0xc,%esp
  801a28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a2b:	53                   	push   %ebx
  801a2c:	6a 00                	push   $0x0
  801a2e:	e8 bb f2 ff ff       	call   800cee <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a33:	89 1c 24             	mov    %ebx,(%esp)
  801a36:	e8 86 f7 ff ff       	call   8011c1 <fd2data>
  801a3b:	83 c4 08             	add    $0x8,%esp
  801a3e:	50                   	push   %eax
  801a3f:	6a 00                	push   $0x0
  801a41:	e8 a8 f2 ff ff       	call   800cee <sys_page_unmap>
}
  801a46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a49:	c9                   	leave  
  801a4a:	c3                   	ret    

00801a4b <_pipeisclosed>:
{
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	57                   	push   %edi
  801a4f:	56                   	push   %esi
  801a50:	53                   	push   %ebx
  801a51:	83 ec 1c             	sub    $0x1c,%esp
  801a54:	89 c7                	mov    %eax,%edi
  801a56:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a58:	a1 08 40 80 00       	mov    0x804008,%eax
  801a5d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a60:	83 ec 0c             	sub    $0xc,%esp
  801a63:	57                   	push   %edi
  801a64:	e8 4d 05 00 00       	call   801fb6 <pageref>
  801a69:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a6c:	89 34 24             	mov    %esi,(%esp)
  801a6f:	e8 42 05 00 00       	call   801fb6 <pageref>
		nn = thisenv->env_runs;
  801a74:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a7a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a7d:	83 c4 10             	add    $0x10,%esp
  801a80:	39 cb                	cmp    %ecx,%ebx
  801a82:	74 1b                	je     801a9f <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801a84:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a87:	75 cf                	jne    801a58 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a89:	8b 42 58             	mov    0x58(%edx),%eax
  801a8c:	6a 01                	push   $0x1
  801a8e:	50                   	push   %eax
  801a8f:	53                   	push   %ebx
  801a90:	68 a8 27 80 00       	push   $0x8027a8
  801a95:	e8 7c e7 ff ff       	call   800216 <cprintf>
  801a9a:	83 c4 10             	add    $0x10,%esp
  801a9d:	eb b9                	jmp    801a58 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801a9f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801aa2:	0f 94 c0             	sete   %al
  801aa5:	0f b6 c0             	movzbl %al,%eax
}
  801aa8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aab:	5b                   	pop    %ebx
  801aac:	5e                   	pop    %esi
  801aad:	5f                   	pop    %edi
  801aae:	5d                   	pop    %ebp
  801aaf:	c3                   	ret    

00801ab0 <devpipe_write>:
{
  801ab0:	f3 0f 1e fb          	endbr32 
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	57                   	push   %edi
  801ab8:	56                   	push   %esi
  801ab9:	53                   	push   %ebx
  801aba:	83 ec 28             	sub    $0x28,%esp
  801abd:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ac0:	56                   	push   %esi
  801ac1:	e8 fb f6 ff ff       	call   8011c1 <fd2data>
  801ac6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ac8:	83 c4 10             	add    $0x10,%esp
  801acb:	bf 00 00 00 00       	mov    $0x0,%edi
  801ad0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ad3:	74 4f                	je     801b24 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ad5:	8b 43 04             	mov    0x4(%ebx),%eax
  801ad8:	8b 0b                	mov    (%ebx),%ecx
  801ada:	8d 51 20             	lea    0x20(%ecx),%edx
  801add:	39 d0                	cmp    %edx,%eax
  801adf:	72 14                	jb     801af5 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801ae1:	89 da                	mov    %ebx,%edx
  801ae3:	89 f0                	mov    %esi,%eax
  801ae5:	e8 61 ff ff ff       	call   801a4b <_pipeisclosed>
  801aea:	85 c0                	test   %eax,%eax
  801aec:	75 3b                	jne    801b29 <devpipe_write+0x79>
			sys_yield();
  801aee:	e8 4b f1 ff ff       	call   800c3e <sys_yield>
  801af3:	eb e0                	jmp    801ad5 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801af5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801af8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801afc:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801aff:	89 c2                	mov    %eax,%edx
  801b01:	c1 fa 1f             	sar    $0x1f,%edx
  801b04:	89 d1                	mov    %edx,%ecx
  801b06:	c1 e9 1b             	shr    $0x1b,%ecx
  801b09:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b0c:	83 e2 1f             	and    $0x1f,%edx
  801b0f:	29 ca                	sub    %ecx,%edx
  801b11:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b15:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b19:	83 c0 01             	add    $0x1,%eax
  801b1c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b1f:	83 c7 01             	add    $0x1,%edi
  801b22:	eb ac                	jmp    801ad0 <devpipe_write+0x20>
	return i;
  801b24:	8b 45 10             	mov    0x10(%ebp),%eax
  801b27:	eb 05                	jmp    801b2e <devpipe_write+0x7e>
				return 0;
  801b29:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b31:	5b                   	pop    %ebx
  801b32:	5e                   	pop    %esi
  801b33:	5f                   	pop    %edi
  801b34:	5d                   	pop    %ebp
  801b35:	c3                   	ret    

00801b36 <devpipe_read>:
{
  801b36:	f3 0f 1e fb          	endbr32 
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	57                   	push   %edi
  801b3e:	56                   	push   %esi
  801b3f:	53                   	push   %ebx
  801b40:	83 ec 18             	sub    $0x18,%esp
  801b43:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b46:	57                   	push   %edi
  801b47:	e8 75 f6 ff ff       	call   8011c1 <fd2data>
  801b4c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b4e:	83 c4 10             	add    $0x10,%esp
  801b51:	be 00 00 00 00       	mov    $0x0,%esi
  801b56:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b59:	75 14                	jne    801b6f <devpipe_read+0x39>
	return i;
  801b5b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b5e:	eb 02                	jmp    801b62 <devpipe_read+0x2c>
				return i;
  801b60:	89 f0                	mov    %esi,%eax
}
  801b62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b65:	5b                   	pop    %ebx
  801b66:	5e                   	pop    %esi
  801b67:	5f                   	pop    %edi
  801b68:	5d                   	pop    %ebp
  801b69:	c3                   	ret    
			sys_yield();
  801b6a:	e8 cf f0 ff ff       	call   800c3e <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801b6f:	8b 03                	mov    (%ebx),%eax
  801b71:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b74:	75 18                	jne    801b8e <devpipe_read+0x58>
			if (i > 0)
  801b76:	85 f6                	test   %esi,%esi
  801b78:	75 e6                	jne    801b60 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801b7a:	89 da                	mov    %ebx,%edx
  801b7c:	89 f8                	mov    %edi,%eax
  801b7e:	e8 c8 fe ff ff       	call   801a4b <_pipeisclosed>
  801b83:	85 c0                	test   %eax,%eax
  801b85:	74 e3                	je     801b6a <devpipe_read+0x34>
				return 0;
  801b87:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8c:	eb d4                	jmp    801b62 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b8e:	99                   	cltd   
  801b8f:	c1 ea 1b             	shr    $0x1b,%edx
  801b92:	01 d0                	add    %edx,%eax
  801b94:	83 e0 1f             	and    $0x1f,%eax
  801b97:	29 d0                	sub    %edx,%eax
  801b99:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba1:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ba4:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801ba7:	83 c6 01             	add    $0x1,%esi
  801baa:	eb aa                	jmp    801b56 <devpipe_read+0x20>

00801bac <pipe>:
{
  801bac:	f3 0f 1e fb          	endbr32 
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	56                   	push   %esi
  801bb4:	53                   	push   %ebx
  801bb5:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801bb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bbb:	50                   	push   %eax
  801bbc:	e8 1b f6 ff ff       	call   8011dc <fd_alloc>
  801bc1:	89 c3                	mov    %eax,%ebx
  801bc3:	83 c4 10             	add    $0x10,%esp
  801bc6:	85 c0                	test   %eax,%eax
  801bc8:	0f 88 23 01 00 00    	js     801cf1 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bce:	83 ec 04             	sub    $0x4,%esp
  801bd1:	68 07 04 00 00       	push   $0x407
  801bd6:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd9:	6a 00                	push   $0x0
  801bdb:	e8 81 f0 ff ff       	call   800c61 <sys_page_alloc>
  801be0:	89 c3                	mov    %eax,%ebx
  801be2:	83 c4 10             	add    $0x10,%esp
  801be5:	85 c0                	test   %eax,%eax
  801be7:	0f 88 04 01 00 00    	js     801cf1 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801bed:	83 ec 0c             	sub    $0xc,%esp
  801bf0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bf3:	50                   	push   %eax
  801bf4:	e8 e3 f5 ff ff       	call   8011dc <fd_alloc>
  801bf9:	89 c3                	mov    %eax,%ebx
  801bfb:	83 c4 10             	add    $0x10,%esp
  801bfe:	85 c0                	test   %eax,%eax
  801c00:	0f 88 db 00 00 00    	js     801ce1 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c06:	83 ec 04             	sub    $0x4,%esp
  801c09:	68 07 04 00 00       	push   $0x407
  801c0e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c11:	6a 00                	push   $0x0
  801c13:	e8 49 f0 ff ff       	call   800c61 <sys_page_alloc>
  801c18:	89 c3                	mov    %eax,%ebx
  801c1a:	83 c4 10             	add    $0x10,%esp
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	0f 88 bc 00 00 00    	js     801ce1 <pipe+0x135>
	va = fd2data(fd0);
  801c25:	83 ec 0c             	sub    $0xc,%esp
  801c28:	ff 75 f4             	pushl  -0xc(%ebp)
  801c2b:	e8 91 f5 ff ff       	call   8011c1 <fd2data>
  801c30:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c32:	83 c4 0c             	add    $0xc,%esp
  801c35:	68 07 04 00 00       	push   $0x407
  801c3a:	50                   	push   %eax
  801c3b:	6a 00                	push   $0x0
  801c3d:	e8 1f f0 ff ff       	call   800c61 <sys_page_alloc>
  801c42:	89 c3                	mov    %eax,%ebx
  801c44:	83 c4 10             	add    $0x10,%esp
  801c47:	85 c0                	test   %eax,%eax
  801c49:	0f 88 82 00 00 00    	js     801cd1 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4f:	83 ec 0c             	sub    $0xc,%esp
  801c52:	ff 75 f0             	pushl  -0x10(%ebp)
  801c55:	e8 67 f5 ff ff       	call   8011c1 <fd2data>
  801c5a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c61:	50                   	push   %eax
  801c62:	6a 00                	push   $0x0
  801c64:	56                   	push   %esi
  801c65:	6a 00                	push   $0x0
  801c67:	e8 3c f0 ff ff       	call   800ca8 <sys_page_map>
  801c6c:	89 c3                	mov    %eax,%ebx
  801c6e:	83 c4 20             	add    $0x20,%esp
  801c71:	85 c0                	test   %eax,%eax
  801c73:	78 4e                	js     801cc3 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801c75:	a1 20 30 80 00       	mov    0x803020,%eax
  801c7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c7d:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801c7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c82:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801c89:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c8c:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801c8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c91:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c98:	83 ec 0c             	sub    $0xc,%esp
  801c9b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9e:	e8 0a f5 ff ff       	call   8011ad <fd2num>
  801ca3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ca8:	83 c4 04             	add    $0x4,%esp
  801cab:	ff 75 f0             	pushl  -0x10(%ebp)
  801cae:	e8 fa f4 ff ff       	call   8011ad <fd2num>
  801cb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cb9:	83 c4 10             	add    $0x10,%esp
  801cbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cc1:	eb 2e                	jmp    801cf1 <pipe+0x145>
	sys_page_unmap(0, va);
  801cc3:	83 ec 08             	sub    $0x8,%esp
  801cc6:	56                   	push   %esi
  801cc7:	6a 00                	push   $0x0
  801cc9:	e8 20 f0 ff ff       	call   800cee <sys_page_unmap>
  801cce:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801cd1:	83 ec 08             	sub    $0x8,%esp
  801cd4:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd7:	6a 00                	push   $0x0
  801cd9:	e8 10 f0 ff ff       	call   800cee <sys_page_unmap>
  801cde:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801ce1:	83 ec 08             	sub    $0x8,%esp
  801ce4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce7:	6a 00                	push   $0x0
  801ce9:	e8 00 f0 ff ff       	call   800cee <sys_page_unmap>
  801cee:	83 c4 10             	add    $0x10,%esp
}
  801cf1:	89 d8                	mov    %ebx,%eax
  801cf3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf6:	5b                   	pop    %ebx
  801cf7:	5e                   	pop    %esi
  801cf8:	5d                   	pop    %ebp
  801cf9:	c3                   	ret    

00801cfa <pipeisclosed>:
{
  801cfa:	f3 0f 1e fb          	endbr32 
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d07:	50                   	push   %eax
  801d08:	ff 75 08             	pushl  0x8(%ebp)
  801d0b:	e8 22 f5 ff ff       	call   801232 <fd_lookup>
  801d10:	83 c4 10             	add    $0x10,%esp
  801d13:	85 c0                	test   %eax,%eax
  801d15:	78 18                	js     801d2f <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801d17:	83 ec 0c             	sub    $0xc,%esp
  801d1a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1d:	e8 9f f4 ff ff       	call   8011c1 <fd2data>
  801d22:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d27:	e8 1f fd ff ff       	call   801a4b <_pipeisclosed>
  801d2c:	83 c4 10             	add    $0x10,%esp
}
  801d2f:	c9                   	leave  
  801d30:	c3                   	ret    

00801d31 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d31:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801d35:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3a:	c3                   	ret    

00801d3b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d3b:	f3 0f 1e fb          	endbr32 
  801d3f:	55                   	push   %ebp
  801d40:	89 e5                	mov    %esp,%ebp
  801d42:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d45:	68 c0 27 80 00       	push   $0x8027c0
  801d4a:	ff 75 0c             	pushl  0xc(%ebp)
  801d4d:	e8 cd ea ff ff       	call   80081f <strcpy>
	return 0;
}
  801d52:	b8 00 00 00 00       	mov    $0x0,%eax
  801d57:	c9                   	leave  
  801d58:	c3                   	ret    

00801d59 <devcons_write>:
{
  801d59:	f3 0f 1e fb          	endbr32 
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
  801d60:	57                   	push   %edi
  801d61:	56                   	push   %esi
  801d62:	53                   	push   %ebx
  801d63:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d69:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d6e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d74:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d77:	73 31                	jae    801daa <devcons_write+0x51>
		m = n - tot;
  801d79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d7c:	29 f3                	sub    %esi,%ebx
  801d7e:	83 fb 7f             	cmp    $0x7f,%ebx
  801d81:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d86:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d89:	83 ec 04             	sub    $0x4,%esp
  801d8c:	53                   	push   %ebx
  801d8d:	89 f0                	mov    %esi,%eax
  801d8f:	03 45 0c             	add    0xc(%ebp),%eax
  801d92:	50                   	push   %eax
  801d93:	57                   	push   %edi
  801d94:	e8 3c ec ff ff       	call   8009d5 <memmove>
		sys_cputs(buf, m);
  801d99:	83 c4 08             	add    $0x8,%esp
  801d9c:	53                   	push   %ebx
  801d9d:	57                   	push   %edi
  801d9e:	e8 ee ed ff ff       	call   800b91 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801da3:	01 de                	add    %ebx,%esi
  801da5:	83 c4 10             	add    $0x10,%esp
  801da8:	eb ca                	jmp    801d74 <devcons_write+0x1b>
}
  801daa:	89 f0                	mov    %esi,%eax
  801dac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801daf:	5b                   	pop    %ebx
  801db0:	5e                   	pop    %esi
  801db1:	5f                   	pop    %edi
  801db2:	5d                   	pop    %ebp
  801db3:	c3                   	ret    

00801db4 <devcons_read>:
{
  801db4:	f3 0f 1e fb          	endbr32 
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	83 ec 08             	sub    $0x8,%esp
  801dbe:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801dc3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dc7:	74 21                	je     801dea <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801dc9:	e8 e5 ed ff ff       	call   800bb3 <sys_cgetc>
  801dce:	85 c0                	test   %eax,%eax
  801dd0:	75 07                	jne    801dd9 <devcons_read+0x25>
		sys_yield();
  801dd2:	e8 67 ee ff ff       	call   800c3e <sys_yield>
  801dd7:	eb f0                	jmp    801dc9 <devcons_read+0x15>
	if (c < 0)
  801dd9:	78 0f                	js     801dea <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801ddb:	83 f8 04             	cmp    $0x4,%eax
  801dde:	74 0c                	je     801dec <devcons_read+0x38>
	*(char*)vbuf = c;
  801de0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801de3:	88 02                	mov    %al,(%edx)
	return 1;
  801de5:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801dea:	c9                   	leave  
  801deb:	c3                   	ret    
		return 0;
  801dec:	b8 00 00 00 00       	mov    $0x0,%eax
  801df1:	eb f7                	jmp    801dea <devcons_read+0x36>

00801df3 <cputchar>:
{
  801df3:	f3 0f 1e fb          	endbr32 
  801df7:	55                   	push   %ebp
  801df8:	89 e5                	mov    %esp,%ebp
  801dfa:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dfd:	8b 45 08             	mov    0x8(%ebp),%eax
  801e00:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e03:	6a 01                	push   $0x1
  801e05:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e08:	50                   	push   %eax
  801e09:	e8 83 ed ff ff       	call   800b91 <sys_cputs>
}
  801e0e:	83 c4 10             	add    $0x10,%esp
  801e11:	c9                   	leave  
  801e12:	c3                   	ret    

00801e13 <getchar>:
{
  801e13:	f3 0f 1e fb          	endbr32 
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801e1d:	6a 01                	push   $0x1
  801e1f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e22:	50                   	push   %eax
  801e23:	6a 00                	push   $0x0
  801e25:	e8 8b f6 ff ff       	call   8014b5 <read>
	if (r < 0)
  801e2a:	83 c4 10             	add    $0x10,%esp
  801e2d:	85 c0                	test   %eax,%eax
  801e2f:	78 06                	js     801e37 <getchar+0x24>
	if (r < 1)
  801e31:	74 06                	je     801e39 <getchar+0x26>
	return c;
  801e33:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e37:	c9                   	leave  
  801e38:	c3                   	ret    
		return -E_EOF;
  801e39:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e3e:	eb f7                	jmp    801e37 <getchar+0x24>

00801e40 <iscons>:
{
  801e40:	f3 0f 1e fb          	endbr32 
  801e44:	55                   	push   %ebp
  801e45:	89 e5                	mov    %esp,%ebp
  801e47:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e4d:	50                   	push   %eax
  801e4e:	ff 75 08             	pushl  0x8(%ebp)
  801e51:	e8 dc f3 ff ff       	call   801232 <fd_lookup>
  801e56:	83 c4 10             	add    $0x10,%esp
  801e59:	85 c0                	test   %eax,%eax
  801e5b:	78 11                	js     801e6e <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e60:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e66:	39 10                	cmp    %edx,(%eax)
  801e68:	0f 94 c0             	sete   %al
  801e6b:	0f b6 c0             	movzbl %al,%eax
}
  801e6e:	c9                   	leave  
  801e6f:	c3                   	ret    

00801e70 <opencons>:
{
  801e70:	f3 0f 1e fb          	endbr32 
  801e74:	55                   	push   %ebp
  801e75:	89 e5                	mov    %esp,%ebp
  801e77:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7d:	50                   	push   %eax
  801e7e:	e8 59 f3 ff ff       	call   8011dc <fd_alloc>
  801e83:	83 c4 10             	add    $0x10,%esp
  801e86:	85 c0                	test   %eax,%eax
  801e88:	78 3a                	js     801ec4 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e8a:	83 ec 04             	sub    $0x4,%esp
  801e8d:	68 07 04 00 00       	push   $0x407
  801e92:	ff 75 f4             	pushl  -0xc(%ebp)
  801e95:	6a 00                	push   $0x0
  801e97:	e8 c5 ed ff ff       	call   800c61 <sys_page_alloc>
  801e9c:	83 c4 10             	add    $0x10,%esp
  801e9f:	85 c0                	test   %eax,%eax
  801ea1:	78 21                	js     801ec4 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eac:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801eb8:	83 ec 0c             	sub    $0xc,%esp
  801ebb:	50                   	push   %eax
  801ebc:	e8 ec f2 ff ff       	call   8011ad <fd2num>
  801ec1:	83 c4 10             	add    $0x10,%esp
}
  801ec4:	c9                   	leave  
  801ec5:	c3                   	ret    

00801ec6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ec6:	f3 0f 1e fb          	endbr32 
  801eca:	55                   	push   %ebp
  801ecb:	89 e5                	mov    %esp,%ebp
  801ecd:	56                   	push   %esi
  801ece:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ecf:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ed2:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ed8:	e8 3e ed ff ff       	call   800c1b <sys_getenvid>
  801edd:	83 ec 0c             	sub    $0xc,%esp
  801ee0:	ff 75 0c             	pushl  0xc(%ebp)
  801ee3:	ff 75 08             	pushl  0x8(%ebp)
  801ee6:	56                   	push   %esi
  801ee7:	50                   	push   %eax
  801ee8:	68 cc 27 80 00       	push   $0x8027cc
  801eed:	e8 24 e3 ff ff       	call   800216 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ef2:	83 c4 18             	add    $0x18,%esp
  801ef5:	53                   	push   %ebx
  801ef6:	ff 75 10             	pushl  0x10(%ebp)
  801ef9:	e8 c3 e2 ff ff       	call   8001c1 <vcprintf>
	cprintf("\n");
  801efe:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  801f05:	e8 0c e3 ff ff       	call   800216 <cprintf>
  801f0a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f0d:	cc                   	int3   
  801f0e:	eb fd                	jmp    801f0d <_panic+0x47>

00801f10 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f10:	f3 0f 1e fb          	endbr32 
  801f14:	55                   	push   %ebp
  801f15:	89 e5                	mov    %esp,%ebp
  801f17:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f1a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f21:	74 0a                	je     801f2d <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f23:	8b 45 08             	mov    0x8(%ebp),%eax
  801f26:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f2b:	c9                   	leave  
  801f2c:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801f2d:	83 ec 0c             	sub    $0xc,%esp
  801f30:	68 ef 27 80 00       	push   $0x8027ef
  801f35:	e8 dc e2 ff ff       	call   800216 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  801f3a:	83 c4 0c             	add    $0xc,%esp
  801f3d:	6a 07                	push   $0x7
  801f3f:	68 00 f0 bf ee       	push   $0xeebff000
  801f44:	6a 00                	push   $0x0
  801f46:	e8 16 ed ff ff       	call   800c61 <sys_page_alloc>
  801f4b:	83 c4 10             	add    $0x10,%esp
  801f4e:	85 c0                	test   %eax,%eax
  801f50:	78 2a                	js     801f7c <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801f52:	83 ec 08             	sub    $0x8,%esp
  801f55:	68 90 1f 80 00       	push   $0x801f90
  801f5a:	6a 00                	push   $0x0
  801f5c:	e8 5f ee ff ff       	call   800dc0 <sys_env_set_pgfault_upcall>
  801f61:	83 c4 10             	add    $0x10,%esp
  801f64:	85 c0                	test   %eax,%eax
  801f66:	79 bb                	jns    801f23 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  801f68:	83 ec 04             	sub    $0x4,%esp
  801f6b:	68 2c 28 80 00       	push   $0x80282c
  801f70:	6a 25                	push   $0x25
  801f72:	68 1c 28 80 00       	push   $0x80281c
  801f77:	e8 4a ff ff ff       	call   801ec6 <_panic>
            panic("Allocation of UXSTACK failed!");
  801f7c:	83 ec 04             	sub    $0x4,%esp
  801f7f:	68 fe 27 80 00       	push   $0x8027fe
  801f84:	6a 22                	push   $0x22
  801f86:	68 1c 28 80 00       	push   $0x80281c
  801f8b:	e8 36 ff ff ff       	call   801ec6 <_panic>

00801f90 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f90:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f91:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f96:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f98:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  801f9b:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  801f9f:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  801fa3:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  801fa6:	83 c4 08             	add    $0x8,%esp
    popa
  801fa9:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  801faa:	83 c4 04             	add    $0x4,%esp
    popf
  801fad:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  801fae:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  801fb1:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  801fb5:	c3                   	ret    

00801fb6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fb6:	f3 0f 1e fb          	endbr32 
  801fba:	55                   	push   %ebp
  801fbb:	89 e5                	mov    %esp,%ebp
  801fbd:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fc0:	89 c2                	mov    %eax,%edx
  801fc2:	c1 ea 16             	shr    $0x16,%edx
  801fc5:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fcc:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fd1:	f6 c1 01             	test   $0x1,%cl
  801fd4:	74 1c                	je     801ff2 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801fd6:	c1 e8 0c             	shr    $0xc,%eax
  801fd9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fe0:	a8 01                	test   $0x1,%al
  801fe2:	74 0e                	je     801ff2 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fe4:	c1 e8 0c             	shr    $0xc,%eax
  801fe7:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801fee:	ef 
  801fef:	0f b7 d2             	movzwl %dx,%edx
}
  801ff2:	89 d0                	mov    %edx,%eax
  801ff4:	5d                   	pop    %ebp
  801ff5:	c3                   	ret    
  801ff6:	66 90                	xchg   %ax,%ax
  801ff8:	66 90                	xchg   %ax,%ax
  801ffa:	66 90                	xchg   %ax,%ax
  801ffc:	66 90                	xchg   %ax,%ax
  801ffe:	66 90                	xchg   %ax,%ax

00802000 <__udivdi3>:
  802000:	f3 0f 1e fb          	endbr32 
  802004:	55                   	push   %ebp
  802005:	57                   	push   %edi
  802006:	56                   	push   %esi
  802007:	53                   	push   %ebx
  802008:	83 ec 1c             	sub    $0x1c,%esp
  80200b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80200f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802013:	8b 74 24 34          	mov    0x34(%esp),%esi
  802017:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80201b:	85 d2                	test   %edx,%edx
  80201d:	75 19                	jne    802038 <__udivdi3+0x38>
  80201f:	39 f3                	cmp    %esi,%ebx
  802021:	76 4d                	jbe    802070 <__udivdi3+0x70>
  802023:	31 ff                	xor    %edi,%edi
  802025:	89 e8                	mov    %ebp,%eax
  802027:	89 f2                	mov    %esi,%edx
  802029:	f7 f3                	div    %ebx
  80202b:	89 fa                	mov    %edi,%edx
  80202d:	83 c4 1c             	add    $0x1c,%esp
  802030:	5b                   	pop    %ebx
  802031:	5e                   	pop    %esi
  802032:	5f                   	pop    %edi
  802033:	5d                   	pop    %ebp
  802034:	c3                   	ret    
  802035:	8d 76 00             	lea    0x0(%esi),%esi
  802038:	39 f2                	cmp    %esi,%edx
  80203a:	76 14                	jbe    802050 <__udivdi3+0x50>
  80203c:	31 ff                	xor    %edi,%edi
  80203e:	31 c0                	xor    %eax,%eax
  802040:	89 fa                	mov    %edi,%edx
  802042:	83 c4 1c             	add    $0x1c,%esp
  802045:	5b                   	pop    %ebx
  802046:	5e                   	pop    %esi
  802047:	5f                   	pop    %edi
  802048:	5d                   	pop    %ebp
  802049:	c3                   	ret    
  80204a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802050:	0f bd fa             	bsr    %edx,%edi
  802053:	83 f7 1f             	xor    $0x1f,%edi
  802056:	75 48                	jne    8020a0 <__udivdi3+0xa0>
  802058:	39 f2                	cmp    %esi,%edx
  80205a:	72 06                	jb     802062 <__udivdi3+0x62>
  80205c:	31 c0                	xor    %eax,%eax
  80205e:	39 eb                	cmp    %ebp,%ebx
  802060:	77 de                	ja     802040 <__udivdi3+0x40>
  802062:	b8 01 00 00 00       	mov    $0x1,%eax
  802067:	eb d7                	jmp    802040 <__udivdi3+0x40>
  802069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802070:	89 d9                	mov    %ebx,%ecx
  802072:	85 db                	test   %ebx,%ebx
  802074:	75 0b                	jne    802081 <__udivdi3+0x81>
  802076:	b8 01 00 00 00       	mov    $0x1,%eax
  80207b:	31 d2                	xor    %edx,%edx
  80207d:	f7 f3                	div    %ebx
  80207f:	89 c1                	mov    %eax,%ecx
  802081:	31 d2                	xor    %edx,%edx
  802083:	89 f0                	mov    %esi,%eax
  802085:	f7 f1                	div    %ecx
  802087:	89 c6                	mov    %eax,%esi
  802089:	89 e8                	mov    %ebp,%eax
  80208b:	89 f7                	mov    %esi,%edi
  80208d:	f7 f1                	div    %ecx
  80208f:	89 fa                	mov    %edi,%edx
  802091:	83 c4 1c             	add    $0x1c,%esp
  802094:	5b                   	pop    %ebx
  802095:	5e                   	pop    %esi
  802096:	5f                   	pop    %edi
  802097:	5d                   	pop    %ebp
  802098:	c3                   	ret    
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	89 f9                	mov    %edi,%ecx
  8020a2:	b8 20 00 00 00       	mov    $0x20,%eax
  8020a7:	29 f8                	sub    %edi,%eax
  8020a9:	d3 e2                	shl    %cl,%edx
  8020ab:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020af:	89 c1                	mov    %eax,%ecx
  8020b1:	89 da                	mov    %ebx,%edx
  8020b3:	d3 ea                	shr    %cl,%edx
  8020b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020b9:	09 d1                	or     %edx,%ecx
  8020bb:	89 f2                	mov    %esi,%edx
  8020bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020c1:	89 f9                	mov    %edi,%ecx
  8020c3:	d3 e3                	shl    %cl,%ebx
  8020c5:	89 c1                	mov    %eax,%ecx
  8020c7:	d3 ea                	shr    %cl,%edx
  8020c9:	89 f9                	mov    %edi,%ecx
  8020cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020cf:	89 eb                	mov    %ebp,%ebx
  8020d1:	d3 e6                	shl    %cl,%esi
  8020d3:	89 c1                	mov    %eax,%ecx
  8020d5:	d3 eb                	shr    %cl,%ebx
  8020d7:	09 de                	or     %ebx,%esi
  8020d9:	89 f0                	mov    %esi,%eax
  8020db:	f7 74 24 08          	divl   0x8(%esp)
  8020df:	89 d6                	mov    %edx,%esi
  8020e1:	89 c3                	mov    %eax,%ebx
  8020e3:	f7 64 24 0c          	mull   0xc(%esp)
  8020e7:	39 d6                	cmp    %edx,%esi
  8020e9:	72 15                	jb     802100 <__udivdi3+0x100>
  8020eb:	89 f9                	mov    %edi,%ecx
  8020ed:	d3 e5                	shl    %cl,%ebp
  8020ef:	39 c5                	cmp    %eax,%ebp
  8020f1:	73 04                	jae    8020f7 <__udivdi3+0xf7>
  8020f3:	39 d6                	cmp    %edx,%esi
  8020f5:	74 09                	je     802100 <__udivdi3+0x100>
  8020f7:	89 d8                	mov    %ebx,%eax
  8020f9:	31 ff                	xor    %edi,%edi
  8020fb:	e9 40 ff ff ff       	jmp    802040 <__udivdi3+0x40>
  802100:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802103:	31 ff                	xor    %edi,%edi
  802105:	e9 36 ff ff ff       	jmp    802040 <__udivdi3+0x40>
  80210a:	66 90                	xchg   %ax,%ax
  80210c:	66 90                	xchg   %ax,%ax
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__umoddi3>:
  802110:	f3 0f 1e fb          	endbr32 
  802114:	55                   	push   %ebp
  802115:	57                   	push   %edi
  802116:	56                   	push   %esi
  802117:	53                   	push   %ebx
  802118:	83 ec 1c             	sub    $0x1c,%esp
  80211b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80211f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802123:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802127:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80212b:	85 c0                	test   %eax,%eax
  80212d:	75 19                	jne    802148 <__umoddi3+0x38>
  80212f:	39 df                	cmp    %ebx,%edi
  802131:	76 5d                	jbe    802190 <__umoddi3+0x80>
  802133:	89 f0                	mov    %esi,%eax
  802135:	89 da                	mov    %ebx,%edx
  802137:	f7 f7                	div    %edi
  802139:	89 d0                	mov    %edx,%eax
  80213b:	31 d2                	xor    %edx,%edx
  80213d:	83 c4 1c             	add    $0x1c,%esp
  802140:	5b                   	pop    %ebx
  802141:	5e                   	pop    %esi
  802142:	5f                   	pop    %edi
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    
  802145:	8d 76 00             	lea    0x0(%esi),%esi
  802148:	89 f2                	mov    %esi,%edx
  80214a:	39 d8                	cmp    %ebx,%eax
  80214c:	76 12                	jbe    802160 <__umoddi3+0x50>
  80214e:	89 f0                	mov    %esi,%eax
  802150:	89 da                	mov    %ebx,%edx
  802152:	83 c4 1c             	add    $0x1c,%esp
  802155:	5b                   	pop    %ebx
  802156:	5e                   	pop    %esi
  802157:	5f                   	pop    %edi
  802158:	5d                   	pop    %ebp
  802159:	c3                   	ret    
  80215a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802160:	0f bd e8             	bsr    %eax,%ebp
  802163:	83 f5 1f             	xor    $0x1f,%ebp
  802166:	75 50                	jne    8021b8 <__umoddi3+0xa8>
  802168:	39 d8                	cmp    %ebx,%eax
  80216a:	0f 82 e0 00 00 00    	jb     802250 <__umoddi3+0x140>
  802170:	89 d9                	mov    %ebx,%ecx
  802172:	39 f7                	cmp    %esi,%edi
  802174:	0f 86 d6 00 00 00    	jbe    802250 <__umoddi3+0x140>
  80217a:	89 d0                	mov    %edx,%eax
  80217c:	89 ca                	mov    %ecx,%edx
  80217e:	83 c4 1c             	add    $0x1c,%esp
  802181:	5b                   	pop    %ebx
  802182:	5e                   	pop    %esi
  802183:	5f                   	pop    %edi
  802184:	5d                   	pop    %ebp
  802185:	c3                   	ret    
  802186:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80218d:	8d 76 00             	lea    0x0(%esi),%esi
  802190:	89 fd                	mov    %edi,%ebp
  802192:	85 ff                	test   %edi,%edi
  802194:	75 0b                	jne    8021a1 <__umoddi3+0x91>
  802196:	b8 01 00 00 00       	mov    $0x1,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	f7 f7                	div    %edi
  80219f:	89 c5                	mov    %eax,%ebp
  8021a1:	89 d8                	mov    %ebx,%eax
  8021a3:	31 d2                	xor    %edx,%edx
  8021a5:	f7 f5                	div    %ebp
  8021a7:	89 f0                	mov    %esi,%eax
  8021a9:	f7 f5                	div    %ebp
  8021ab:	89 d0                	mov    %edx,%eax
  8021ad:	31 d2                	xor    %edx,%edx
  8021af:	eb 8c                	jmp    80213d <__umoddi3+0x2d>
  8021b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	89 e9                	mov    %ebp,%ecx
  8021ba:	ba 20 00 00 00       	mov    $0x20,%edx
  8021bf:	29 ea                	sub    %ebp,%edx
  8021c1:	d3 e0                	shl    %cl,%eax
  8021c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021c7:	89 d1                	mov    %edx,%ecx
  8021c9:	89 f8                	mov    %edi,%eax
  8021cb:	d3 e8                	shr    %cl,%eax
  8021cd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8021d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021d5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021d9:	09 c1                	or     %eax,%ecx
  8021db:	89 d8                	mov    %ebx,%eax
  8021dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021e1:	89 e9                	mov    %ebp,%ecx
  8021e3:	d3 e7                	shl    %cl,%edi
  8021e5:	89 d1                	mov    %edx,%ecx
  8021e7:	d3 e8                	shr    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021ef:	d3 e3                	shl    %cl,%ebx
  8021f1:	89 c7                	mov    %eax,%edi
  8021f3:	89 d1                	mov    %edx,%ecx
  8021f5:	89 f0                	mov    %esi,%eax
  8021f7:	d3 e8                	shr    %cl,%eax
  8021f9:	89 e9                	mov    %ebp,%ecx
  8021fb:	89 fa                	mov    %edi,%edx
  8021fd:	d3 e6                	shl    %cl,%esi
  8021ff:	09 d8                	or     %ebx,%eax
  802201:	f7 74 24 08          	divl   0x8(%esp)
  802205:	89 d1                	mov    %edx,%ecx
  802207:	89 f3                	mov    %esi,%ebx
  802209:	f7 64 24 0c          	mull   0xc(%esp)
  80220d:	89 c6                	mov    %eax,%esi
  80220f:	89 d7                	mov    %edx,%edi
  802211:	39 d1                	cmp    %edx,%ecx
  802213:	72 06                	jb     80221b <__umoddi3+0x10b>
  802215:	75 10                	jne    802227 <__umoddi3+0x117>
  802217:	39 c3                	cmp    %eax,%ebx
  802219:	73 0c                	jae    802227 <__umoddi3+0x117>
  80221b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80221f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802223:	89 d7                	mov    %edx,%edi
  802225:	89 c6                	mov    %eax,%esi
  802227:	89 ca                	mov    %ecx,%edx
  802229:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80222e:	29 f3                	sub    %esi,%ebx
  802230:	19 fa                	sbb    %edi,%edx
  802232:	89 d0                	mov    %edx,%eax
  802234:	d3 e0                	shl    %cl,%eax
  802236:	89 e9                	mov    %ebp,%ecx
  802238:	d3 eb                	shr    %cl,%ebx
  80223a:	d3 ea                	shr    %cl,%edx
  80223c:	09 d8                	or     %ebx,%eax
  80223e:	83 c4 1c             	add    $0x1c,%esp
  802241:	5b                   	pop    %ebx
  802242:	5e                   	pop    %esi
  802243:	5f                   	pop    %edi
  802244:	5d                   	pop    %ebp
  802245:	c3                   	ret    
  802246:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80224d:	8d 76 00             	lea    0x0(%esi),%esi
  802250:	29 fe                	sub    %edi,%esi
  802252:	19 c3                	sbb    %eax,%ebx
  802254:	89 f2                	mov    %esi,%edx
  802256:	89 d9                	mov    %ebx,%ecx
  802258:	e9 1d ff ff ff       	jmp    80217a <__umoddi3+0x6a>
