
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 b6 00 00 00       	call   8000e7 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  80003c:	e8 f2 0b 00 00       	call   800c33 <sys_getenvid>
  800041:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  800043:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800048:	e8 cc 0e 00 00       	call   800f19 <fork>
  80004d:	85 c0                	test   %eax,%eax
  80004f:	74 0f                	je     800060 <umain+0x2d>
	for (i = 0; i < 20; i++)
  800051:	83 c3 01             	add    $0x1,%ebx
  800054:	83 fb 14             	cmp    $0x14,%ebx
  800057:	75 ef                	jne    800048 <umain+0x15>
			break;
	if (i == 20) {
		sys_yield();
  800059:	e8 f8 0b 00 00       	call   800c56 <sys_yield>
		return;
  80005e:	eb 69                	jmp    8000c9 <umain+0x96>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800060:	89 f0                	mov    %esi,%eax
  800062:	25 ff 03 00 00       	and    $0x3ff,%eax
  800067:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006f:	eb 02                	jmp    800073 <umain+0x40>
		asm volatile("pause");
  800071:	f3 90                	pause  
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800073:	8b 50 54             	mov    0x54(%eax),%edx
  800076:	85 d2                	test   %edx,%edx
  800078:	75 f7                	jne    800071 <umain+0x3e>
  80007a:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  80007f:	e8 d2 0b 00 00       	call   800c56 <sys_yield>
  800084:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  800089:	a1 04 20 80 00       	mov    0x802004,%eax
  80008e:	83 c0 01             	add    $0x1,%eax
  800091:	a3 04 20 80 00       	mov    %eax,0x802004
		for (j = 0; j < 10000; j++)
  800096:	83 ea 01             	sub    $0x1,%edx
  800099:	75 ee                	jne    800089 <umain+0x56>
	for (i = 0; i < 10; i++) {
  80009b:	83 eb 01             	sub    $0x1,%ebx
  80009e:	75 df                	jne    80007f <umain+0x4c>
	}

	if (counter != 10*10000)
  8000a0:	a1 04 20 80 00       	mov    0x802004,%eax
  8000a5:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000aa:	75 24                	jne    8000d0 <umain+0x9d>
		panic("ran on two CPUs at once (counter is %d)", counter);

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000ac:	a1 08 20 80 00       	mov    0x802008,%eax
  8000b1:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000b4:	8b 40 48             	mov    0x48(%eax),%eax
  8000b7:	83 ec 04             	sub    $0x4,%esp
  8000ba:	52                   	push   %edx
  8000bb:	50                   	push   %eax
  8000bc:	68 db 13 80 00       	push   $0x8013db
  8000c1:	e8 68 01 00 00       	call   80022e <cprintf>
  8000c6:	83 c4 10             	add    $0x10,%esp

}
  8000c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5d                   	pop    %ebp
  8000cf:	c3                   	ret    
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000d0:	a1 04 20 80 00       	mov    0x802004,%eax
  8000d5:	50                   	push   %eax
  8000d6:	68 a0 13 80 00       	push   $0x8013a0
  8000db:	6a 21                	push   $0x21
  8000dd:	68 c8 13 80 00       	push   $0x8013c8
  8000e2:	e8 60 00 00 00       	call   800147 <_panic>

008000e7 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e7:	f3 0f 1e fb          	endbr32 
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    envid_t envid = sys_getenvid();
  8000f6:	e8 38 0b 00 00       	call   800c33 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8000fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800100:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800103:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800108:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010d:	85 db                	test   %ebx,%ebx
  80010f:	7e 07                	jle    800118 <libmain+0x31>
		binaryname = argv[0];
  800111:	8b 06                	mov    (%esi),%eax
  800113:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800118:	83 ec 08             	sub    $0x8,%esp
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
  80011d:	e8 11 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800122:	e8 0a 00 00 00       	call   800131 <exit>
}
  800127:	83 c4 10             	add    $0x10,%esp
  80012a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5d                   	pop    %ebp
  800130:	c3                   	ret    

00800131 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800131:	f3 0f 1e fb          	endbr32 
  800135:	55                   	push   %ebp
  800136:	89 e5                	mov    %esp,%ebp
  800138:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80013b:	6a 00                	push   $0x0
  80013d:	e8 ac 0a 00 00       	call   800bee <sys_env_destroy>
}
  800142:	83 c4 10             	add    $0x10,%esp
  800145:	c9                   	leave  
  800146:	c3                   	ret    

00800147 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800147:	f3 0f 1e fb          	endbr32 
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	56                   	push   %esi
  80014f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800150:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800153:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800159:	e8 d5 0a 00 00       	call   800c33 <sys_getenvid>
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	ff 75 0c             	pushl  0xc(%ebp)
  800164:	ff 75 08             	pushl  0x8(%ebp)
  800167:	56                   	push   %esi
  800168:	50                   	push   %eax
  800169:	68 04 14 80 00       	push   $0x801404
  80016e:	e8 bb 00 00 00       	call   80022e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800173:	83 c4 18             	add    $0x18,%esp
  800176:	53                   	push   %ebx
  800177:	ff 75 10             	pushl  0x10(%ebp)
  80017a:	e8 5a 00 00 00       	call   8001d9 <vcprintf>
	cprintf("\n");
  80017f:	c7 04 24 74 17 80 00 	movl   $0x801774,(%esp)
  800186:	e8 a3 00 00 00       	call   80022e <cprintf>
  80018b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018e:	cc                   	int3   
  80018f:	eb fd                	jmp    80018e <_panic+0x47>

00800191 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800191:	f3 0f 1e fb          	endbr32 
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	53                   	push   %ebx
  800199:	83 ec 04             	sub    $0x4,%esp
  80019c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019f:	8b 13                	mov    (%ebx),%edx
  8001a1:	8d 42 01             	lea    0x1(%edx),%eax
  8001a4:	89 03                	mov    %eax,(%ebx)
  8001a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ad:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b2:	74 09                	je     8001bd <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001b4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	68 ff 00 00 00       	push   $0xff
  8001c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c8:	50                   	push   %eax
  8001c9:	e8 db 09 00 00       	call   800ba9 <sys_cputs>
		b->idx = 0;
  8001ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d4:	83 c4 10             	add    $0x10,%esp
  8001d7:	eb db                	jmp    8001b4 <putch+0x23>

008001d9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d9:	f3 0f 1e fb          	endbr32 
  8001dd:	55                   	push   %ebp
  8001de:	89 e5                	mov    %esp,%ebp
  8001e0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ed:	00 00 00 
	b.cnt = 0;
  8001f0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fa:	ff 75 0c             	pushl  0xc(%ebp)
  8001fd:	ff 75 08             	pushl  0x8(%ebp)
  800200:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800206:	50                   	push   %eax
  800207:	68 91 01 80 00       	push   $0x800191
  80020c:	e8 20 01 00 00       	call   800331 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800211:	83 c4 08             	add    $0x8,%esp
  800214:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800220:	50                   	push   %eax
  800221:	e8 83 09 00 00       	call   800ba9 <sys_cputs>

	return b.cnt;
}
  800226:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022c:	c9                   	leave  
  80022d:	c3                   	ret    

0080022e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80022e:	f3 0f 1e fb          	endbr32 
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800238:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023b:	50                   	push   %eax
  80023c:	ff 75 08             	pushl  0x8(%ebp)
  80023f:	e8 95 ff ff ff       	call   8001d9 <vcprintf>
	va_end(ap);

	return cnt;
}
  800244:	c9                   	leave  
  800245:	c3                   	ret    

00800246 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	57                   	push   %edi
  80024a:	56                   	push   %esi
  80024b:	53                   	push   %ebx
  80024c:	83 ec 1c             	sub    $0x1c,%esp
  80024f:	89 c7                	mov    %eax,%edi
  800251:	89 d6                	mov    %edx,%esi
  800253:	8b 45 08             	mov    0x8(%ebp),%eax
  800256:	8b 55 0c             	mov    0xc(%ebp),%edx
  800259:	89 d1                	mov    %edx,%ecx
  80025b:	89 c2                	mov    %eax,%edx
  80025d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800260:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800263:	8b 45 10             	mov    0x10(%ebp),%eax
  800266:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800269:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80026c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800273:	39 c2                	cmp    %eax,%edx
  800275:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800278:	72 3e                	jb     8002b8 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	ff 75 18             	pushl  0x18(%ebp)
  800280:	83 eb 01             	sub    $0x1,%ebx
  800283:	53                   	push   %ebx
  800284:	50                   	push   %eax
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 97 0e 00 00       	call   801130 <__udivdi3>
  800299:	83 c4 18             	add    $0x18,%esp
  80029c:	52                   	push   %edx
  80029d:	50                   	push   %eax
  80029e:	89 f2                	mov    %esi,%edx
  8002a0:	89 f8                	mov    %edi,%eax
  8002a2:	e8 9f ff ff ff       	call   800246 <printnum>
  8002a7:	83 c4 20             	add    $0x20,%esp
  8002aa:	eb 13                	jmp    8002bf <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	ff 75 18             	pushl  0x18(%ebp)
  8002b3:	ff d7                	call   *%edi
  8002b5:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002b8:	83 eb 01             	sub    $0x1,%ebx
  8002bb:	85 db                	test   %ebx,%ebx
  8002bd:	7f ed                	jg     8002ac <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bf:	83 ec 08             	sub    $0x8,%esp
  8002c2:	56                   	push   %esi
  8002c3:	83 ec 04             	sub    $0x4,%esp
  8002c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8002cc:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cf:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d2:	e8 69 0f 00 00       	call   801240 <__umoddi3>
  8002d7:	83 c4 14             	add    $0x14,%esp
  8002da:	0f be 80 27 14 80 00 	movsbl 0x801427(%eax),%eax
  8002e1:	50                   	push   %eax
  8002e2:	ff d7                	call   *%edi
}
  8002e4:	83 c4 10             	add    $0x10,%esp
  8002e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ea:	5b                   	pop    %ebx
  8002eb:	5e                   	pop    %esi
  8002ec:	5f                   	pop    %edi
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ef:	f3 0f 1e fb          	endbr32 
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002fd:	8b 10                	mov    (%eax),%edx
  8002ff:	3b 50 04             	cmp    0x4(%eax),%edx
  800302:	73 0a                	jae    80030e <sprintputch+0x1f>
		*b->buf++ = ch;
  800304:	8d 4a 01             	lea    0x1(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 45 08             	mov    0x8(%ebp),%eax
  80030c:	88 02                	mov    %al,(%edx)
}
  80030e:	5d                   	pop    %ebp
  80030f:	c3                   	ret    

00800310 <printfmt>:
{
  800310:	f3 0f 1e fb          	endbr32 
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80031a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031d:	50                   	push   %eax
  80031e:	ff 75 10             	pushl  0x10(%ebp)
  800321:	ff 75 0c             	pushl  0xc(%ebp)
  800324:	ff 75 08             	pushl  0x8(%ebp)
  800327:	e8 05 00 00 00       	call   800331 <vprintfmt>
}
  80032c:	83 c4 10             	add    $0x10,%esp
  80032f:	c9                   	leave  
  800330:	c3                   	ret    

00800331 <vprintfmt>:
{
  800331:	f3 0f 1e fb          	endbr32 
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	57                   	push   %edi
  800339:	56                   	push   %esi
  80033a:	53                   	push   %ebx
  80033b:	83 ec 3c             	sub    $0x3c,%esp
  80033e:	8b 75 08             	mov    0x8(%ebp),%esi
  800341:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800344:	8b 7d 10             	mov    0x10(%ebp),%edi
  800347:	e9 4a 03 00 00       	jmp    800696 <vprintfmt+0x365>
		padc = ' ';
  80034c:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800350:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800357:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80035e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800365:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	8d 47 01             	lea    0x1(%edi),%eax
  80036d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800370:	0f b6 17             	movzbl (%edi),%edx
  800373:	8d 42 dd             	lea    -0x23(%edx),%eax
  800376:	3c 55                	cmp    $0x55,%al
  800378:	0f 87 de 03 00 00    	ja     80075c <vprintfmt+0x42b>
  80037e:	0f b6 c0             	movzbl %al,%eax
  800381:	3e ff 24 85 e0 14 80 	notrack jmp *0x8014e0(,%eax,4)
  800388:	00 
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80038c:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800390:	eb d8                	jmp    80036a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800395:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800399:	eb cf                	jmp    80036a <vprintfmt+0x39>
  80039b:	0f b6 d2             	movzbl %dl,%edx
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003a9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ac:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003b0:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003b3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003b6:	83 f9 09             	cmp    $0x9,%ecx
  8003b9:	77 55                	ja     800410 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003bb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003be:	eb e9                	jmp    8003a9 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c3:	8b 00                	mov    (%eax),%eax
  8003c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8d 40 04             	lea    0x4(%eax),%eax
  8003ce:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d8:	79 90                	jns    80036a <vprintfmt+0x39>
				width = precision, precision = -1;
  8003da:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003e7:	eb 81                	jmp    80036a <vprintfmt+0x39>
  8003e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ec:	85 c0                	test   %eax,%eax
  8003ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f3:	0f 49 d0             	cmovns %eax,%edx
  8003f6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003fc:	e9 69 ff ff ff       	jmp    80036a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800404:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80040b:	e9 5a ff ff ff       	jmp    80036a <vprintfmt+0x39>
  800410:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800413:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800416:	eb bc                	jmp    8003d4 <vprintfmt+0xa3>
			lflag++;
  800418:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80041e:	e9 47 ff ff ff       	jmp    80036a <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800423:	8b 45 14             	mov    0x14(%ebp),%eax
  800426:	8d 78 04             	lea    0x4(%eax),%edi
  800429:	83 ec 08             	sub    $0x8,%esp
  80042c:	53                   	push   %ebx
  80042d:	ff 30                	pushl  (%eax)
  80042f:	ff d6                	call   *%esi
			break;
  800431:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800434:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800437:	e9 57 02 00 00       	jmp    800693 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80043c:	8b 45 14             	mov    0x14(%ebp),%eax
  80043f:	8d 78 04             	lea    0x4(%eax),%edi
  800442:	8b 00                	mov    (%eax),%eax
  800444:	99                   	cltd   
  800445:	31 d0                	xor    %edx,%eax
  800447:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800449:	83 f8 08             	cmp    $0x8,%eax
  80044c:	7f 23                	jg     800471 <vprintfmt+0x140>
  80044e:	8b 14 85 40 16 80 00 	mov    0x801640(,%eax,4),%edx
  800455:	85 d2                	test   %edx,%edx
  800457:	74 18                	je     800471 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800459:	52                   	push   %edx
  80045a:	68 48 14 80 00       	push   $0x801448
  80045f:	53                   	push   %ebx
  800460:	56                   	push   %esi
  800461:	e8 aa fe ff ff       	call   800310 <printfmt>
  800466:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800469:	89 7d 14             	mov    %edi,0x14(%ebp)
  80046c:	e9 22 02 00 00       	jmp    800693 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800471:	50                   	push   %eax
  800472:	68 3f 14 80 00       	push   $0x80143f
  800477:	53                   	push   %ebx
  800478:	56                   	push   %esi
  800479:	e8 92 fe ff ff       	call   800310 <printfmt>
  80047e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800481:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800484:	e9 0a 02 00 00       	jmp    800693 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800489:	8b 45 14             	mov    0x14(%ebp),%eax
  80048c:	83 c0 04             	add    $0x4,%eax
  80048f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800497:	85 d2                	test   %edx,%edx
  800499:	b8 38 14 80 00       	mov    $0x801438,%eax
  80049e:	0f 45 c2             	cmovne %edx,%eax
  8004a1:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a8:	7e 06                	jle    8004b0 <vprintfmt+0x17f>
  8004aa:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004ae:	75 0d                	jne    8004bd <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004b3:	89 c7                	mov    %eax,%edi
  8004b5:	03 45 e0             	add    -0x20(%ebp),%eax
  8004b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004bb:	eb 55                	jmp    800512 <vprintfmt+0x1e1>
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c3:	ff 75 cc             	pushl  -0x34(%ebp)
  8004c6:	e8 45 03 00 00       	call   800810 <strnlen>
  8004cb:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004ce:	29 c2                	sub    %eax,%edx
  8004d0:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004d3:	83 c4 10             	add    $0x10,%esp
  8004d6:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004d8:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004df:	85 ff                	test   %edi,%edi
  8004e1:	7e 11                	jle    8004f4 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	53                   	push   %ebx
  8004e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ea:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ec:	83 ef 01             	sub    $0x1,%edi
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	eb eb                	jmp    8004df <vprintfmt+0x1ae>
  8004f4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004f7:	85 d2                	test   %edx,%edx
  8004f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fe:	0f 49 c2             	cmovns %edx,%eax
  800501:	29 c2                	sub    %eax,%edx
  800503:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800506:	eb a8                	jmp    8004b0 <vprintfmt+0x17f>
					putch(ch, putdat);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	53                   	push   %ebx
  80050c:	52                   	push   %edx
  80050d:	ff d6                	call   *%esi
  80050f:	83 c4 10             	add    $0x10,%esp
  800512:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800515:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800517:	83 c7 01             	add    $0x1,%edi
  80051a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80051e:	0f be d0             	movsbl %al,%edx
  800521:	85 d2                	test   %edx,%edx
  800523:	74 4b                	je     800570 <vprintfmt+0x23f>
  800525:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800529:	78 06                	js     800531 <vprintfmt+0x200>
  80052b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80052f:	78 1e                	js     80054f <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800531:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800535:	74 d1                	je     800508 <vprintfmt+0x1d7>
  800537:	0f be c0             	movsbl %al,%eax
  80053a:	83 e8 20             	sub    $0x20,%eax
  80053d:	83 f8 5e             	cmp    $0x5e,%eax
  800540:	76 c6                	jbe    800508 <vprintfmt+0x1d7>
					putch('?', putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	53                   	push   %ebx
  800546:	6a 3f                	push   $0x3f
  800548:	ff d6                	call   *%esi
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	eb c3                	jmp    800512 <vprintfmt+0x1e1>
  80054f:	89 cf                	mov    %ecx,%edi
  800551:	eb 0e                	jmp    800561 <vprintfmt+0x230>
				putch(' ', putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	53                   	push   %ebx
  800557:	6a 20                	push   $0x20
  800559:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80055b:	83 ef 01             	sub    $0x1,%edi
  80055e:	83 c4 10             	add    $0x10,%esp
  800561:	85 ff                	test   %edi,%edi
  800563:	7f ee                	jg     800553 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800565:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800568:	89 45 14             	mov    %eax,0x14(%ebp)
  80056b:	e9 23 01 00 00       	jmp    800693 <vprintfmt+0x362>
  800570:	89 cf                	mov    %ecx,%edi
  800572:	eb ed                	jmp    800561 <vprintfmt+0x230>
	if (lflag >= 2)
  800574:	83 f9 01             	cmp    $0x1,%ecx
  800577:	7f 1b                	jg     800594 <vprintfmt+0x263>
	else if (lflag)
  800579:	85 c9                	test   %ecx,%ecx
  80057b:	74 63                	je     8005e0 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800585:	99                   	cltd   
  800586:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8d 40 04             	lea    0x4(%eax),%eax
  80058f:	89 45 14             	mov    %eax,0x14(%ebp)
  800592:	eb 17                	jmp    8005ab <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8b 50 04             	mov    0x4(%eax),%edx
  80059a:	8b 00                	mov    (%eax),%eax
  80059c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 40 08             	lea    0x8(%eax),%eax
  8005a8:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005ab:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ae:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005b1:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005b6:	85 c9                	test   %ecx,%ecx
  8005b8:	0f 89 bb 00 00 00    	jns    800679 <vprintfmt+0x348>
				putch('-', putdat);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	53                   	push   %ebx
  8005c2:	6a 2d                	push   $0x2d
  8005c4:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005cc:	f7 da                	neg    %edx
  8005ce:	83 d1 00             	adc    $0x0,%ecx
  8005d1:	f7 d9                	neg    %ecx
  8005d3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005db:	e9 99 00 00 00       	jmp    800679 <vprintfmt+0x348>
		return va_arg(*ap, int);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8b 00                	mov    (%eax),%eax
  8005e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e8:	99                   	cltd   
  8005e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8d 40 04             	lea    0x4(%eax),%eax
  8005f2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f5:	eb b4                	jmp    8005ab <vprintfmt+0x27a>
	if (lflag >= 2)
  8005f7:	83 f9 01             	cmp    $0x1,%ecx
  8005fa:	7f 1b                	jg     800617 <vprintfmt+0x2e6>
	else if (lflag)
  8005fc:	85 c9                	test   %ecx,%ecx
  8005fe:	74 2c                	je     80062c <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8b 10                	mov    (%eax),%edx
  800605:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060a:	8d 40 04             	lea    0x4(%eax),%eax
  80060d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800610:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800615:	eb 62                	jmp    800679 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8b 10                	mov    (%eax),%edx
  80061c:	8b 48 04             	mov    0x4(%eax),%ecx
  80061f:	8d 40 08             	lea    0x8(%eax),%eax
  800622:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800625:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80062a:	eb 4d                	jmp    800679 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8b 10                	mov    (%eax),%edx
  800631:	b9 00 00 00 00       	mov    $0x0,%ecx
  800636:	8d 40 04             	lea    0x4(%eax),%eax
  800639:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80063c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800641:	eb 36                	jmp    800679 <vprintfmt+0x348>
	if (lflag >= 2)
  800643:	83 f9 01             	cmp    $0x1,%ecx
  800646:	7f 17                	jg     80065f <vprintfmt+0x32e>
	else if (lflag)
  800648:	85 c9                	test   %ecx,%ecx
  80064a:	74 6e                	je     8006ba <vprintfmt+0x389>
		return va_arg(*ap, long);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8b 10                	mov    (%eax),%edx
  800651:	89 d0                	mov    %edx,%eax
  800653:	99                   	cltd   
  800654:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800657:	8d 49 04             	lea    0x4(%ecx),%ecx
  80065a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80065d:	eb 11                	jmp    800670 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8b 50 04             	mov    0x4(%eax),%edx
  800665:	8b 00                	mov    (%eax),%eax
  800667:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80066a:	8d 49 08             	lea    0x8(%ecx),%ecx
  80066d:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800670:	89 d1                	mov    %edx,%ecx
  800672:	89 c2                	mov    %eax,%edx
            base = 8;
  800674:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800679:	83 ec 0c             	sub    $0xc,%esp
  80067c:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800680:	57                   	push   %edi
  800681:	ff 75 e0             	pushl  -0x20(%ebp)
  800684:	50                   	push   %eax
  800685:	51                   	push   %ecx
  800686:	52                   	push   %edx
  800687:	89 da                	mov    %ebx,%edx
  800689:	89 f0                	mov    %esi,%eax
  80068b:	e8 b6 fb ff ff       	call   800246 <printnum>
			break;
  800690:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800693:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800696:	83 c7 01             	add    $0x1,%edi
  800699:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80069d:	83 f8 25             	cmp    $0x25,%eax
  8006a0:	0f 84 a6 fc ff ff    	je     80034c <vprintfmt+0x1b>
			if (ch == '\0')
  8006a6:	85 c0                	test   %eax,%eax
  8006a8:	0f 84 ce 00 00 00    	je     80077c <vprintfmt+0x44b>
			putch(ch, putdat);
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	53                   	push   %ebx
  8006b2:	50                   	push   %eax
  8006b3:	ff d6                	call   *%esi
  8006b5:	83 c4 10             	add    $0x10,%esp
  8006b8:	eb dc                	jmp    800696 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8b 10                	mov    (%eax),%edx
  8006bf:	89 d0                	mov    %edx,%eax
  8006c1:	99                   	cltd   
  8006c2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006c5:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006c8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006cb:	eb a3                	jmp    800670 <vprintfmt+0x33f>
			putch('0', putdat);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	53                   	push   %ebx
  8006d1:	6a 30                	push   $0x30
  8006d3:	ff d6                	call   *%esi
			putch('x', putdat);
  8006d5:	83 c4 08             	add    $0x8,%esp
  8006d8:	53                   	push   %ebx
  8006d9:	6a 78                	push   $0x78
  8006db:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8b 10                	mov    (%eax),%edx
  8006e2:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006e7:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006ea:	8d 40 04             	lea    0x4(%eax),%eax
  8006ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006f5:	eb 82                	jmp    800679 <vprintfmt+0x348>
	if (lflag >= 2)
  8006f7:	83 f9 01             	cmp    $0x1,%ecx
  8006fa:	7f 1e                	jg     80071a <vprintfmt+0x3e9>
	else if (lflag)
  8006fc:	85 c9                	test   %ecx,%ecx
  8006fe:	74 32                	je     800732 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800700:	8b 45 14             	mov    0x14(%ebp),%eax
  800703:	8b 10                	mov    (%eax),%edx
  800705:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070a:	8d 40 04             	lea    0x4(%eax),%eax
  80070d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800710:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800715:	e9 5f ff ff ff       	jmp    800679 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8b 10                	mov    (%eax),%edx
  80071f:	8b 48 04             	mov    0x4(%eax),%ecx
  800722:	8d 40 08             	lea    0x8(%eax),%eax
  800725:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800728:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80072d:	e9 47 ff ff ff       	jmp    800679 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	8b 10                	mov    (%eax),%edx
  800737:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073c:	8d 40 04             	lea    0x4(%eax),%eax
  80073f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800742:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800747:	e9 2d ff ff ff       	jmp    800679 <vprintfmt+0x348>
			putch(ch, putdat);
  80074c:	83 ec 08             	sub    $0x8,%esp
  80074f:	53                   	push   %ebx
  800750:	6a 25                	push   $0x25
  800752:	ff d6                	call   *%esi
			break;
  800754:	83 c4 10             	add    $0x10,%esp
  800757:	e9 37 ff ff ff       	jmp    800693 <vprintfmt+0x362>
			putch('%', putdat);
  80075c:	83 ec 08             	sub    $0x8,%esp
  80075f:	53                   	push   %ebx
  800760:	6a 25                	push   $0x25
  800762:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800764:	83 c4 10             	add    $0x10,%esp
  800767:	89 f8                	mov    %edi,%eax
  800769:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80076d:	74 05                	je     800774 <vprintfmt+0x443>
  80076f:	83 e8 01             	sub    $0x1,%eax
  800772:	eb f5                	jmp    800769 <vprintfmt+0x438>
  800774:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800777:	e9 17 ff ff ff       	jmp    800693 <vprintfmt+0x362>
}
  80077c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80077f:	5b                   	pop    %ebx
  800780:	5e                   	pop    %esi
  800781:	5f                   	pop    %edi
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800784:	f3 0f 1e fb          	endbr32 
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	83 ec 18             	sub    $0x18,%esp
  80078e:	8b 45 08             	mov    0x8(%ebp),%eax
  800791:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800794:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800797:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80079b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80079e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007a5:	85 c0                	test   %eax,%eax
  8007a7:	74 26                	je     8007cf <vsnprintf+0x4b>
  8007a9:	85 d2                	test   %edx,%edx
  8007ab:	7e 22                	jle    8007cf <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ad:	ff 75 14             	pushl  0x14(%ebp)
  8007b0:	ff 75 10             	pushl  0x10(%ebp)
  8007b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b6:	50                   	push   %eax
  8007b7:	68 ef 02 80 00       	push   $0x8002ef
  8007bc:	e8 70 fb ff ff       	call   800331 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ca:	83 c4 10             	add    $0x10,%esp
}
  8007cd:	c9                   	leave  
  8007ce:	c3                   	ret    
		return -E_INVAL;
  8007cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d4:	eb f7                	jmp    8007cd <vsnprintf+0x49>

008007d6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d6:	f3 0f 1e fb          	endbr32 
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007e0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007e3:	50                   	push   %eax
  8007e4:	ff 75 10             	pushl  0x10(%ebp)
  8007e7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ea:	ff 75 08             	pushl  0x8(%ebp)
  8007ed:	e8 92 ff ff ff       	call   800784 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f2:	c9                   	leave  
  8007f3:	c3                   	ret    

008007f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f4:	f3 0f 1e fb          	endbr32 
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800803:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800807:	74 05                	je     80080e <strlen+0x1a>
		n++;
  800809:	83 c0 01             	add    $0x1,%eax
  80080c:	eb f5                	jmp    800803 <strlen+0xf>
	return n;
}
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800810:	f3 0f 1e fb          	endbr32 
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081d:	b8 00 00 00 00       	mov    $0x0,%eax
  800822:	39 d0                	cmp    %edx,%eax
  800824:	74 0d                	je     800833 <strnlen+0x23>
  800826:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80082a:	74 05                	je     800831 <strnlen+0x21>
		n++;
  80082c:	83 c0 01             	add    $0x1,%eax
  80082f:	eb f1                	jmp    800822 <strnlen+0x12>
  800831:	89 c2                	mov    %eax,%edx
	return n;
}
  800833:	89 d0                	mov    %edx,%eax
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800837:	f3 0f 1e fb          	endbr32 
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800842:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800845:	b8 00 00 00 00       	mov    $0x0,%eax
  80084a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80084e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800851:	83 c0 01             	add    $0x1,%eax
  800854:	84 d2                	test   %dl,%dl
  800856:	75 f2                	jne    80084a <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800858:	89 c8                	mov    %ecx,%eax
  80085a:	5b                   	pop    %ebx
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80085d:	f3 0f 1e fb          	endbr32 
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	53                   	push   %ebx
  800865:	83 ec 10             	sub    $0x10,%esp
  800868:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80086b:	53                   	push   %ebx
  80086c:	e8 83 ff ff ff       	call   8007f4 <strlen>
  800871:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800874:	ff 75 0c             	pushl  0xc(%ebp)
  800877:	01 d8                	add    %ebx,%eax
  800879:	50                   	push   %eax
  80087a:	e8 b8 ff ff ff       	call   800837 <strcpy>
	return dst;
}
  80087f:	89 d8                	mov    %ebx,%eax
  800881:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800884:	c9                   	leave  
  800885:	c3                   	ret    

00800886 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800886:	f3 0f 1e fb          	endbr32 
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	56                   	push   %esi
  80088e:	53                   	push   %ebx
  80088f:	8b 75 08             	mov    0x8(%ebp),%esi
  800892:	8b 55 0c             	mov    0xc(%ebp),%edx
  800895:	89 f3                	mov    %esi,%ebx
  800897:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089a:	89 f0                	mov    %esi,%eax
  80089c:	39 d8                	cmp    %ebx,%eax
  80089e:	74 11                	je     8008b1 <strncpy+0x2b>
		*dst++ = *src;
  8008a0:	83 c0 01             	add    $0x1,%eax
  8008a3:	0f b6 0a             	movzbl (%edx),%ecx
  8008a6:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008a9:	80 f9 01             	cmp    $0x1,%cl
  8008ac:	83 da ff             	sbb    $0xffffffff,%edx
  8008af:	eb eb                	jmp    80089c <strncpy+0x16>
	}
	return ret;
}
  8008b1:	89 f0                	mov    %esi,%eax
  8008b3:	5b                   	pop    %ebx
  8008b4:	5e                   	pop    %esi
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008b7:	f3 0f 1e fb          	endbr32 
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	56                   	push   %esi
  8008bf:	53                   	push   %ebx
  8008c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c6:	8b 55 10             	mov    0x10(%ebp),%edx
  8008c9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008cb:	85 d2                	test   %edx,%edx
  8008cd:	74 21                	je     8008f0 <strlcpy+0x39>
  8008cf:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008d3:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008d5:	39 c2                	cmp    %eax,%edx
  8008d7:	74 14                	je     8008ed <strlcpy+0x36>
  8008d9:	0f b6 19             	movzbl (%ecx),%ebx
  8008dc:	84 db                	test   %bl,%bl
  8008de:	74 0b                	je     8008eb <strlcpy+0x34>
			*dst++ = *src++;
  8008e0:	83 c1 01             	add    $0x1,%ecx
  8008e3:	83 c2 01             	add    $0x1,%edx
  8008e6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008e9:	eb ea                	jmp    8008d5 <strlcpy+0x1e>
  8008eb:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008ed:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f0:	29 f0                	sub    %esi,%eax
}
  8008f2:	5b                   	pop    %ebx
  8008f3:	5e                   	pop    %esi
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f6:	f3 0f 1e fb          	endbr32 
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800900:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800903:	0f b6 01             	movzbl (%ecx),%eax
  800906:	84 c0                	test   %al,%al
  800908:	74 0c                	je     800916 <strcmp+0x20>
  80090a:	3a 02                	cmp    (%edx),%al
  80090c:	75 08                	jne    800916 <strcmp+0x20>
		p++, q++;
  80090e:	83 c1 01             	add    $0x1,%ecx
  800911:	83 c2 01             	add    $0x1,%edx
  800914:	eb ed                	jmp    800903 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800916:	0f b6 c0             	movzbl %al,%eax
  800919:	0f b6 12             	movzbl (%edx),%edx
  80091c:	29 d0                	sub    %edx,%eax
}
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800920:	f3 0f 1e fb          	endbr32 
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	53                   	push   %ebx
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092e:	89 c3                	mov    %eax,%ebx
  800930:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800933:	eb 06                	jmp    80093b <strncmp+0x1b>
		n--, p++, q++;
  800935:	83 c0 01             	add    $0x1,%eax
  800938:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80093b:	39 d8                	cmp    %ebx,%eax
  80093d:	74 16                	je     800955 <strncmp+0x35>
  80093f:	0f b6 08             	movzbl (%eax),%ecx
  800942:	84 c9                	test   %cl,%cl
  800944:	74 04                	je     80094a <strncmp+0x2a>
  800946:	3a 0a                	cmp    (%edx),%cl
  800948:	74 eb                	je     800935 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80094a:	0f b6 00             	movzbl (%eax),%eax
  80094d:	0f b6 12             	movzbl (%edx),%edx
  800950:	29 d0                	sub    %edx,%eax
}
  800952:	5b                   	pop    %ebx
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    
		return 0;
  800955:	b8 00 00 00 00       	mov    $0x0,%eax
  80095a:	eb f6                	jmp    800952 <strncmp+0x32>

0080095c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80095c:	f3 0f 1e fb          	endbr32 
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	8b 45 08             	mov    0x8(%ebp),%eax
  800966:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80096a:	0f b6 10             	movzbl (%eax),%edx
  80096d:	84 d2                	test   %dl,%dl
  80096f:	74 09                	je     80097a <strchr+0x1e>
		if (*s == c)
  800971:	38 ca                	cmp    %cl,%dl
  800973:	74 0a                	je     80097f <strchr+0x23>
	for (; *s; s++)
  800975:	83 c0 01             	add    $0x1,%eax
  800978:	eb f0                	jmp    80096a <strchr+0xe>
			return (char *) s;
	return 0;
  80097a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800981:	f3 0f 1e fb          	endbr32 
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80098f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800992:	38 ca                	cmp    %cl,%dl
  800994:	74 09                	je     80099f <strfind+0x1e>
  800996:	84 d2                	test   %dl,%dl
  800998:	74 05                	je     80099f <strfind+0x1e>
	for (; *s; s++)
  80099a:	83 c0 01             	add    $0x1,%eax
  80099d:	eb f0                	jmp    80098f <strfind+0xe>
			break;
	return (char *) s;
}
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a1:	f3 0f 1e fb          	endbr32 
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	57                   	push   %edi
  8009a9:	56                   	push   %esi
  8009aa:	53                   	push   %ebx
  8009ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b1:	85 c9                	test   %ecx,%ecx
  8009b3:	74 31                	je     8009e6 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b5:	89 f8                	mov    %edi,%eax
  8009b7:	09 c8                	or     %ecx,%eax
  8009b9:	a8 03                	test   $0x3,%al
  8009bb:	75 23                	jne    8009e0 <memset+0x3f>
		c &= 0xFF;
  8009bd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c1:	89 d3                	mov    %edx,%ebx
  8009c3:	c1 e3 08             	shl    $0x8,%ebx
  8009c6:	89 d0                	mov    %edx,%eax
  8009c8:	c1 e0 18             	shl    $0x18,%eax
  8009cb:	89 d6                	mov    %edx,%esi
  8009cd:	c1 e6 10             	shl    $0x10,%esi
  8009d0:	09 f0                	or     %esi,%eax
  8009d2:	09 c2                	or     %eax,%edx
  8009d4:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009d6:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009d9:	89 d0                	mov    %edx,%eax
  8009db:	fc                   	cld    
  8009dc:	f3 ab                	rep stos %eax,%es:(%edi)
  8009de:	eb 06                	jmp    8009e6 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e3:	fc                   	cld    
  8009e4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e6:	89 f8                	mov    %edi,%eax
  8009e8:	5b                   	pop    %ebx
  8009e9:	5e                   	pop    %esi
  8009ea:	5f                   	pop    %edi
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ed:	f3 0f 1e fb          	endbr32 
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	57                   	push   %edi
  8009f5:	56                   	push   %esi
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009fc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ff:	39 c6                	cmp    %eax,%esi
  800a01:	73 32                	jae    800a35 <memmove+0x48>
  800a03:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a06:	39 c2                	cmp    %eax,%edx
  800a08:	76 2b                	jbe    800a35 <memmove+0x48>
		s += n;
		d += n;
  800a0a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0d:	89 fe                	mov    %edi,%esi
  800a0f:	09 ce                	or     %ecx,%esi
  800a11:	09 d6                	or     %edx,%esi
  800a13:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a19:	75 0e                	jne    800a29 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a1b:	83 ef 04             	sub    $0x4,%edi
  800a1e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a21:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a24:	fd                   	std    
  800a25:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a27:	eb 09                	jmp    800a32 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a29:	83 ef 01             	sub    $0x1,%edi
  800a2c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a2f:	fd                   	std    
  800a30:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a32:	fc                   	cld    
  800a33:	eb 1a                	jmp    800a4f <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a35:	89 c2                	mov    %eax,%edx
  800a37:	09 ca                	or     %ecx,%edx
  800a39:	09 f2                	or     %esi,%edx
  800a3b:	f6 c2 03             	test   $0x3,%dl
  800a3e:	75 0a                	jne    800a4a <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a40:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a43:	89 c7                	mov    %eax,%edi
  800a45:	fc                   	cld    
  800a46:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a48:	eb 05                	jmp    800a4f <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a4a:	89 c7                	mov    %eax,%edi
  800a4c:	fc                   	cld    
  800a4d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a4f:	5e                   	pop    %esi
  800a50:	5f                   	pop    %edi
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a53:	f3 0f 1e fb          	endbr32 
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a5d:	ff 75 10             	pushl  0x10(%ebp)
  800a60:	ff 75 0c             	pushl  0xc(%ebp)
  800a63:	ff 75 08             	pushl  0x8(%ebp)
  800a66:	e8 82 ff ff ff       	call   8009ed <memmove>
}
  800a6b:	c9                   	leave  
  800a6c:	c3                   	ret    

00800a6d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a6d:	f3 0f 1e fb          	endbr32 
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
  800a76:	8b 45 08             	mov    0x8(%ebp),%eax
  800a79:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7c:	89 c6                	mov    %eax,%esi
  800a7e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a81:	39 f0                	cmp    %esi,%eax
  800a83:	74 1c                	je     800aa1 <memcmp+0x34>
		if (*s1 != *s2)
  800a85:	0f b6 08             	movzbl (%eax),%ecx
  800a88:	0f b6 1a             	movzbl (%edx),%ebx
  800a8b:	38 d9                	cmp    %bl,%cl
  800a8d:	75 08                	jne    800a97 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a8f:	83 c0 01             	add    $0x1,%eax
  800a92:	83 c2 01             	add    $0x1,%edx
  800a95:	eb ea                	jmp    800a81 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a97:	0f b6 c1             	movzbl %cl,%eax
  800a9a:	0f b6 db             	movzbl %bl,%ebx
  800a9d:	29 d8                	sub    %ebx,%eax
  800a9f:	eb 05                	jmp    800aa6 <memcmp+0x39>
	}

	return 0;
  800aa1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa6:	5b                   	pop    %ebx
  800aa7:	5e                   	pop    %esi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aaa:	f3 0f 1e fb          	endbr32 
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ab7:	89 c2                	mov    %eax,%edx
  800ab9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800abc:	39 d0                	cmp    %edx,%eax
  800abe:	73 09                	jae    800ac9 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac0:	38 08                	cmp    %cl,(%eax)
  800ac2:	74 05                	je     800ac9 <memfind+0x1f>
	for (; s < ends; s++)
  800ac4:	83 c0 01             	add    $0x1,%eax
  800ac7:	eb f3                	jmp    800abc <memfind+0x12>
			break;
	return (void *) s;
}
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800acb:	f3 0f 1e fb          	endbr32 
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
  800ad5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800adb:	eb 03                	jmp    800ae0 <strtol+0x15>
		s++;
  800add:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ae0:	0f b6 01             	movzbl (%ecx),%eax
  800ae3:	3c 20                	cmp    $0x20,%al
  800ae5:	74 f6                	je     800add <strtol+0x12>
  800ae7:	3c 09                	cmp    $0x9,%al
  800ae9:	74 f2                	je     800add <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800aeb:	3c 2b                	cmp    $0x2b,%al
  800aed:	74 2a                	je     800b19 <strtol+0x4e>
	int neg = 0;
  800aef:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800af4:	3c 2d                	cmp    $0x2d,%al
  800af6:	74 2b                	je     800b23 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800afe:	75 0f                	jne    800b0f <strtol+0x44>
  800b00:	80 39 30             	cmpb   $0x30,(%ecx)
  800b03:	74 28                	je     800b2d <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b05:	85 db                	test   %ebx,%ebx
  800b07:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b0c:	0f 44 d8             	cmove  %eax,%ebx
  800b0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b14:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b17:	eb 46                	jmp    800b5f <strtol+0x94>
		s++;
  800b19:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b1c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b21:	eb d5                	jmp    800af8 <strtol+0x2d>
		s++, neg = 1;
  800b23:	83 c1 01             	add    $0x1,%ecx
  800b26:	bf 01 00 00 00       	mov    $0x1,%edi
  800b2b:	eb cb                	jmp    800af8 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b2d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b31:	74 0e                	je     800b41 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b33:	85 db                	test   %ebx,%ebx
  800b35:	75 d8                	jne    800b0f <strtol+0x44>
		s++, base = 8;
  800b37:	83 c1 01             	add    $0x1,%ecx
  800b3a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b3f:	eb ce                	jmp    800b0f <strtol+0x44>
		s += 2, base = 16;
  800b41:	83 c1 02             	add    $0x2,%ecx
  800b44:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b49:	eb c4                	jmp    800b0f <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b4b:	0f be d2             	movsbl %dl,%edx
  800b4e:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b51:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b54:	7d 3a                	jge    800b90 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b56:	83 c1 01             	add    $0x1,%ecx
  800b59:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b5d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b5f:	0f b6 11             	movzbl (%ecx),%edx
  800b62:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b65:	89 f3                	mov    %esi,%ebx
  800b67:	80 fb 09             	cmp    $0x9,%bl
  800b6a:	76 df                	jbe    800b4b <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b6c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b6f:	89 f3                	mov    %esi,%ebx
  800b71:	80 fb 19             	cmp    $0x19,%bl
  800b74:	77 08                	ja     800b7e <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b76:	0f be d2             	movsbl %dl,%edx
  800b79:	83 ea 57             	sub    $0x57,%edx
  800b7c:	eb d3                	jmp    800b51 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b7e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b81:	89 f3                	mov    %esi,%ebx
  800b83:	80 fb 19             	cmp    $0x19,%bl
  800b86:	77 08                	ja     800b90 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b88:	0f be d2             	movsbl %dl,%edx
  800b8b:	83 ea 37             	sub    $0x37,%edx
  800b8e:	eb c1                	jmp    800b51 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b90:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b94:	74 05                	je     800b9b <strtol+0xd0>
		*endptr = (char *) s;
  800b96:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b99:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b9b:	89 c2                	mov    %eax,%edx
  800b9d:	f7 da                	neg    %edx
  800b9f:	85 ff                	test   %edi,%edi
  800ba1:	0f 45 c2             	cmovne %edx,%eax
}
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba9:	f3 0f 1e fb          	endbr32 
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	57                   	push   %edi
  800bb1:	56                   	push   %esi
  800bb2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbe:	89 c3                	mov    %eax,%ebx
  800bc0:	89 c7                	mov    %eax,%edi
  800bc2:	89 c6                	mov    %eax,%esi
  800bc4:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5f                   	pop    %edi
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <sys_cgetc>:

int
sys_cgetc(void)
{
  800bcb:	f3 0f 1e fb          	endbr32 
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	57                   	push   %edi
  800bd3:	56                   	push   %esi
  800bd4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bda:	b8 01 00 00 00       	mov    $0x1,%eax
  800bdf:	89 d1                	mov    %edx,%ecx
  800be1:	89 d3                	mov    %edx,%ebx
  800be3:	89 d7                	mov    %edx,%edi
  800be5:	89 d6                	mov    %edx,%esi
  800be7:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5f                   	pop    %edi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    

00800bee <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bee:	f3 0f 1e fb          	endbr32 
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bfb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c00:	8b 55 08             	mov    0x8(%ebp),%edx
  800c03:	b8 03 00 00 00       	mov    $0x3,%eax
  800c08:	89 cb                	mov    %ecx,%ebx
  800c0a:	89 cf                	mov    %ecx,%edi
  800c0c:	89 ce                	mov    %ecx,%esi
  800c0e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7f 08                	jg     800c1c <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 03                	push   $0x3
  800c22:	68 64 16 80 00       	push   $0x801664
  800c27:	6a 23                	push   $0x23
  800c29:	68 81 16 80 00       	push   $0x801681
  800c2e:	e8 14 f5 ff ff       	call   800147 <_panic>

00800c33 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c33:	f3 0f 1e fb          	endbr32 
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c42:	b8 02 00 00 00       	mov    $0x2,%eax
  800c47:	89 d1                	mov    %edx,%ecx
  800c49:	89 d3                	mov    %edx,%ebx
  800c4b:	89 d7                	mov    %edx,%edi
  800c4d:	89 d6                	mov    %edx,%esi
  800c4f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <sys_yield>:

void
sys_yield(void)
{
  800c56:	f3 0f 1e fb          	endbr32 
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c60:	ba 00 00 00 00       	mov    $0x0,%edx
  800c65:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c6a:	89 d1                	mov    %edx,%ecx
  800c6c:	89 d3                	mov    %edx,%ebx
  800c6e:	89 d7                	mov    %edx,%edi
  800c70:	89 d6                	mov    %edx,%esi
  800c72:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c79:	f3 0f 1e fb          	endbr32 
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
  800c83:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c86:	be 00 00 00 00       	mov    $0x0,%esi
  800c8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c91:	b8 04 00 00 00       	mov    $0x4,%eax
  800c96:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c99:	89 f7                	mov    %esi,%edi
  800c9b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	7f 08                	jg     800ca9 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ca1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca9:	83 ec 0c             	sub    $0xc,%esp
  800cac:	50                   	push   %eax
  800cad:	6a 04                	push   $0x4
  800caf:	68 64 16 80 00       	push   $0x801664
  800cb4:	6a 23                	push   $0x23
  800cb6:	68 81 16 80 00       	push   $0x801681
  800cbb:	e8 87 f4 ff ff       	call   800147 <_panic>

00800cc0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cc0:	f3 0f 1e fb          	endbr32 
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd3:	b8 05 00 00 00       	mov    $0x5,%eax
  800cd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cde:	8b 75 18             	mov    0x18(%ebp),%esi
  800ce1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7f 08                	jg     800cef <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ce7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cef:	83 ec 0c             	sub    $0xc,%esp
  800cf2:	50                   	push   %eax
  800cf3:	6a 05                	push   $0x5
  800cf5:	68 64 16 80 00       	push   $0x801664
  800cfa:	6a 23                	push   $0x23
  800cfc:	68 81 16 80 00       	push   $0x801681
  800d01:	e8 41 f4 ff ff       	call   800147 <_panic>

00800d06 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d06:	f3 0f 1e fb          	endbr32 
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
  800d10:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d18:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d23:	89 df                	mov    %ebx,%edi
  800d25:	89 de                	mov    %ebx,%esi
  800d27:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	7f 08                	jg     800d35 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d35:	83 ec 0c             	sub    $0xc,%esp
  800d38:	50                   	push   %eax
  800d39:	6a 06                	push   $0x6
  800d3b:	68 64 16 80 00       	push   $0x801664
  800d40:	6a 23                	push   $0x23
  800d42:	68 81 16 80 00       	push   $0x801681
  800d47:	e8 fb f3 ff ff       	call   800147 <_panic>

00800d4c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d4c:	f3 0f 1e fb          	endbr32 
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d64:	b8 08 00 00 00       	mov    $0x8,%eax
  800d69:	89 df                	mov    %ebx,%edi
  800d6b:	89 de                	mov    %ebx,%esi
  800d6d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	7f 08                	jg     800d7b <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d76:	5b                   	pop    %ebx
  800d77:	5e                   	pop    %esi
  800d78:	5f                   	pop    %edi
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7b:	83 ec 0c             	sub    $0xc,%esp
  800d7e:	50                   	push   %eax
  800d7f:	6a 08                	push   $0x8
  800d81:	68 64 16 80 00       	push   $0x801664
  800d86:	6a 23                	push   $0x23
  800d88:	68 81 16 80 00       	push   $0x801681
  800d8d:	e8 b5 f3 ff ff       	call   800147 <_panic>

00800d92 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d92:	f3 0f 1e fb          	endbr32 
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	57                   	push   %edi
  800d9a:	56                   	push   %esi
  800d9b:	53                   	push   %ebx
  800d9c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daa:	b8 09 00 00 00       	mov    $0x9,%eax
  800daf:	89 df                	mov    %ebx,%edi
  800db1:	89 de                	mov    %ebx,%esi
  800db3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800db5:	85 c0                	test   %eax,%eax
  800db7:	7f 08                	jg     800dc1 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbc:	5b                   	pop    %ebx
  800dbd:	5e                   	pop    %esi
  800dbe:	5f                   	pop    %edi
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc1:	83 ec 0c             	sub    $0xc,%esp
  800dc4:	50                   	push   %eax
  800dc5:	6a 09                	push   $0x9
  800dc7:	68 64 16 80 00       	push   $0x801664
  800dcc:	6a 23                	push   $0x23
  800dce:	68 81 16 80 00       	push   $0x801681
  800dd3:	e8 6f f3 ff ff       	call   800147 <_panic>

00800dd8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd8:	f3 0f 1e fb          	endbr32 
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	57                   	push   %edi
  800de0:	56                   	push   %esi
  800de1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800de2:	8b 55 08             	mov    0x8(%ebp),%edx
  800de5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ded:	be 00 00 00 00       	mov    $0x0,%esi
  800df2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df8:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dfa:	5b                   	pop    %ebx
  800dfb:	5e                   	pop    %esi
  800dfc:	5f                   	pop    %edi
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dff:	f3 0f 1e fb          	endbr32 
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	57                   	push   %edi
  800e07:	56                   	push   %esi
  800e08:	53                   	push   %ebx
  800e09:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e0c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e11:	8b 55 08             	mov    0x8(%ebp),%edx
  800e14:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e19:	89 cb                	mov    %ecx,%ebx
  800e1b:	89 cf                	mov    %ecx,%edi
  800e1d:	89 ce                	mov    %ecx,%esi
  800e1f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e21:	85 c0                	test   %eax,%eax
  800e23:	7f 08                	jg     800e2d <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2d:	83 ec 0c             	sub    $0xc,%esp
  800e30:	50                   	push   %eax
  800e31:	6a 0c                	push   $0xc
  800e33:	68 64 16 80 00       	push   $0x801664
  800e38:	6a 23                	push   $0x23
  800e3a:	68 81 16 80 00       	push   $0x801681
  800e3f:	e8 03 f3 ff ff       	call   800147 <_panic>

00800e44 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e44:	f3 0f 1e fb          	endbr32 
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	53                   	push   %ebx
  800e4c:	83 ec 04             	sub    $0x4,%esp
  800e4f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e52:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if ( !(err & FEC_WR) ||
  800e54:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e58:	74 75                	je     800ecf <pgfault+0x8b>
            !(uvpt[PGNUM(addr)] | PTE_COW) ) {
  800e5a:	89 d8                	mov    %ebx,%eax
  800e5c:	c1 e8 0c             	shr    $0xc,%eax
  800e5f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0) {
  800e66:	83 ec 04             	sub    $0x4,%esp
  800e69:	6a 07                	push   $0x7
  800e6b:	68 00 f0 7f 00       	push   $0x7ff000
  800e70:	6a 00                	push   $0x0
  800e72:	e8 02 fe ff ff       	call   800c79 <sys_page_alloc>
  800e77:	83 c4 10             	add    $0x10,%esp
  800e7a:	85 c0                	test   %eax,%eax
  800e7c:	78 65                	js     800ee3 <pgfault+0x9f>
        panic("sys_page_alloc failed %e\n", r);
    }
    memmove((void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);
  800e7e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800e84:	83 ec 04             	sub    $0x4,%esp
  800e87:	68 00 10 00 00       	push   $0x1000
  800e8c:	53                   	push   %ebx
  800e8d:	68 00 f0 7f 00       	push   $0x7ff000
  800e92:	e8 56 fb ff ff       	call   8009ed <memmove>
    if ((r = sys_page_map(0, (void *)PFTEMP,
  800e97:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e9e:	53                   	push   %ebx
  800e9f:	6a 00                	push   $0x0
  800ea1:	68 00 f0 7f 00       	push   $0x7ff000
  800ea6:	6a 00                	push   $0x0
  800ea8:	e8 13 fe ff ff       	call   800cc0 <sys_page_map>
  800ead:	83 c4 20             	add    $0x20,%esp
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	78 41                	js     800ef5 <pgfault+0xb1>
                0, (void *)PTE_ADDR(addr), PTE_P | PTE_U | PTE_W)) < 0) {
        panic("sys_page_map failed %e\n", r);
    }
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0) {
  800eb4:	83 ec 08             	sub    $0x8,%esp
  800eb7:	68 00 f0 7f 00       	push   $0x7ff000
  800ebc:	6a 00                	push   $0x0
  800ebe:	e8 43 fe ff ff       	call   800d06 <sys_page_unmap>
  800ec3:	83 c4 10             	add    $0x10,%esp
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	78 3d                	js     800f07 <pgfault+0xc3>
        panic("sys_page_unmap failed %e\n", r);
    }

}
  800eca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ecd:	c9                   	leave  
  800ece:	c3                   	ret    
        panic("Not a copy-on-write page");
  800ecf:	83 ec 04             	sub    $0x4,%esp
  800ed2:	68 8f 16 80 00       	push   $0x80168f
  800ed7:	6a 1e                	push   $0x1e
  800ed9:	68 a8 16 80 00       	push   $0x8016a8
  800ede:	e8 64 f2 ff ff       	call   800147 <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800ee3:	50                   	push   %eax
  800ee4:	68 b3 16 80 00       	push   $0x8016b3
  800ee9:	6a 2a                	push   $0x2a
  800eeb:	68 a8 16 80 00       	push   $0x8016a8
  800ef0:	e8 52 f2 ff ff       	call   800147 <_panic>
        panic("sys_page_map failed %e\n", r);
  800ef5:	50                   	push   %eax
  800ef6:	68 cd 16 80 00       	push   $0x8016cd
  800efb:	6a 2f                	push   $0x2f
  800efd:	68 a8 16 80 00       	push   $0x8016a8
  800f02:	e8 40 f2 ff ff       	call   800147 <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800f07:	50                   	push   %eax
  800f08:	68 e5 16 80 00       	push   $0x8016e5
  800f0d:	6a 32                	push   $0x32
  800f0f:	68 a8 16 80 00       	push   $0x8016a8
  800f14:	e8 2e f2 ff ff       	call   800147 <_panic>

00800f19 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f19:	f3 0f 1e fb          	endbr32 
  800f1d:	55                   	push   %ebp
  800f1e:	89 e5                	mov    %esp,%ebp
  800f20:	57                   	push   %edi
  800f21:	56                   	push   %esi
  800f22:	53                   	push   %ebx
  800f23:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");

    // 1. set pgfault handler.
    set_pgfault_handler(pgfault);
  800f26:	68 44 0e 80 00       	push   $0x800e44
  800f2b:	e8 55 01 00 00       	call   801085 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f30:	b8 07 00 00 00       	mov    $0x7,%eax
  800f35:	cd 30                	int    $0x30
  800f37:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 2. exofork.
    envid_t envid = sys_exofork();

    if (envid < 0)
  800f3d:	83 c4 10             	add    $0x10,%esp
  800f40:	85 c0                	test   %eax,%eax
  800f42:	78 2a                	js     800f6e <fork+0x55>
        thisenv = &envs[ENVX(my_envid)];
        return 0;
    }
    else {
        // parent
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f44:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800f49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f4d:	75 4e                	jne    800f9d <fork+0x84>
        envid_t my_envid = sys_getenvid();
  800f4f:	e8 df fc ff ff       	call   800c33 <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800f54:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f59:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f5c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f61:	a3 08 20 80 00       	mov    %eax,0x802008
        return 0;
  800f66:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f69:	e9 f1 00 00 00       	jmp    80105f <fork+0x146>
        panic("fork, sys_exofork %e", envid);
  800f6e:	50                   	push   %eax
  800f6f:	68 ff 16 80 00       	push   $0x8016ff
  800f74:	6a 7b                	push   $0x7b
  800f76:	68 a8 16 80 00       	push   $0x8016a8
  800f7b:	e8 c7 f1 ff ff       	call   800147 <_panic>
        panic("sys_page_map others failed %e\n", r);
  800f80:	50                   	push   %eax
  800f81:	68 48 17 80 00       	push   $0x801748
  800f86:	6a 51                	push   $0x51
  800f88:	68 a8 16 80 00       	push   $0x8016a8
  800f8d:	e8 b5 f1 ff ff       	call   800147 <_panic>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f92:	83 c3 01             	add    $0x1,%ebx
  800f95:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800f9b:	74 7c                	je     801019 <fork+0x100>
  800f9d:	89 de                	mov    %ebx,%esi
  800f9f:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800fa2:	89 f0                	mov    %esi,%eax
  800fa4:	c1 e8 16             	shr    $0x16,%eax
  800fa7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fae:	a8 01                	test   $0x1,%al
  800fb0:	74 e0                	je     800f92 <fork+0x79>
                    (uvpt[pn] & PTE_P) ) {
  800fb2:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800fb9:	a8 01                	test   $0x1,%al
  800fbb:	74 d5                	je     800f92 <fork+0x79>
    pte_t pte = uvpt[pn];
  800fbd:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    if ( (pte & PTE_W) || (pte & PTE_COW) ) {
  800fc4:	25 02 08 00 00       	and    $0x802,%eax
        perm |= PTE_COW;
  800fc9:	83 f8 01             	cmp    $0x1,%eax
  800fcc:	19 ff                	sbb    %edi,%edi
  800fce:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  800fd4:	81 c7 05 08 00 00    	add    $0x805,%edi
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  800fda:	83 ec 0c             	sub    $0xc,%esp
  800fdd:	57                   	push   %edi
  800fde:	56                   	push   %esi
  800fdf:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fe2:	56                   	push   %esi
  800fe3:	6a 00                	push   $0x0
  800fe5:	e8 d6 fc ff ff       	call   800cc0 <sys_page_map>
  800fea:	83 c4 20             	add    $0x20,%esp
  800fed:	85 c0                	test   %eax,%eax
  800fef:	78 8f                	js     800f80 <fork+0x67>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	57                   	push   %edi
  800ff5:	56                   	push   %esi
  800ff6:	6a 00                	push   $0x0
  800ff8:	56                   	push   %esi
  800ff9:	6a 00                	push   $0x0
  800ffb:	e8 c0 fc ff ff       	call   800cc0 <sys_page_map>
  801000:	83 c4 20             	add    $0x20,%esp
  801003:	85 c0                	test   %eax,%eax
  801005:	79 8b                	jns    800f92 <fork+0x79>
            panic("sys_page_map mine failed %e\n", r);
  801007:	50                   	push   %eax
  801008:	68 14 17 80 00       	push   $0x801714
  80100d:	6a 56                	push   $0x56
  80100f:	68 a8 16 80 00       	push   $0x8016a8
  801014:	e8 2e f1 ff ff       	call   800147 <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  801019:	83 ec 04             	sub    $0x4,%esp
  80101c:	6a 07                	push   $0x7
  80101e:	68 00 f0 bf ee       	push   $0xeebff000
  801023:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801026:	57                   	push   %edi
  801027:	e8 4d fc ff ff       	call   800c79 <sys_page_alloc>
  80102c:	83 c4 10             	add    $0x10,%esp
  80102f:	85 c0                	test   %eax,%eax
  801031:	78 2c                	js     80105f <fork+0x146>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  801033:	a1 08 20 80 00       	mov    0x802008,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  801038:	8b 40 64             	mov    0x64(%eax),%eax
  80103b:	83 ec 08             	sub    $0x8,%esp
  80103e:	50                   	push   %eax
  80103f:	57                   	push   %edi
  801040:	e8 4d fd ff ff       	call   800d92 <sys_env_set_pgfault_upcall>
  801045:	83 c4 10             	add    $0x10,%esp
  801048:	85 c0                	test   %eax,%eax
  80104a:	78 13                	js     80105f <fork+0x146>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  80104c:	83 ec 08             	sub    $0x8,%esp
  80104f:	6a 02                	push   $0x2
  801051:	57                   	push   %edi
  801052:	e8 f5 fc ff ff       	call   800d4c <sys_env_set_status>
  801057:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  80105a:	85 c0                	test   %eax,%eax
  80105c:	0f 49 c7             	cmovns %edi,%eax
    }

}
  80105f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801062:	5b                   	pop    %ebx
  801063:	5e                   	pop    %esi
  801064:	5f                   	pop    %edi
  801065:	5d                   	pop    %ebp
  801066:	c3                   	ret    

00801067 <sfork>:

// Challenge!
int
sfork(void)
{
  801067:	f3 0f 1e fb          	endbr32 
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801071:	68 31 17 80 00       	push   $0x801731
  801076:	68 a5 00 00 00       	push   $0xa5
  80107b:	68 a8 16 80 00       	push   $0x8016a8
  801080:	e8 c2 f0 ff ff       	call   800147 <_panic>

00801085 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801085:	f3 0f 1e fb          	endbr32 
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80108f:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801096:	74 0a                	je     8010a2 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801098:	8b 45 08             	mov    0x8(%ebp),%eax
  80109b:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  8010a0:	c9                   	leave  
  8010a1:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  8010a2:	83 ec 0c             	sub    $0xc,%esp
  8010a5:	68 67 17 80 00       	push   $0x801767
  8010aa:	e8 7f f1 ff ff       	call   80022e <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  8010af:	83 c4 0c             	add    $0xc,%esp
  8010b2:	6a 07                	push   $0x7
  8010b4:	68 00 f0 bf ee       	push   $0xeebff000
  8010b9:	6a 00                	push   $0x0
  8010bb:	e8 b9 fb ff ff       	call   800c79 <sys_page_alloc>
  8010c0:	83 c4 10             	add    $0x10,%esp
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	78 2a                	js     8010f1 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  8010c7:	83 ec 08             	sub    $0x8,%esp
  8010ca:	68 05 11 80 00       	push   $0x801105
  8010cf:	6a 00                	push   $0x0
  8010d1:	e8 bc fc ff ff       	call   800d92 <sys_env_set_pgfault_upcall>
  8010d6:	83 c4 10             	add    $0x10,%esp
  8010d9:	85 c0                	test   %eax,%eax
  8010db:	79 bb                	jns    801098 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  8010dd:	83 ec 04             	sub    $0x4,%esp
  8010e0:	68 a4 17 80 00       	push   $0x8017a4
  8010e5:	6a 25                	push   $0x25
  8010e7:	68 94 17 80 00       	push   $0x801794
  8010ec:	e8 56 f0 ff ff       	call   800147 <_panic>
            panic("Allocation of UXSTACK failed!");
  8010f1:	83 ec 04             	sub    $0x4,%esp
  8010f4:	68 76 17 80 00       	push   $0x801776
  8010f9:	6a 22                	push   $0x22
  8010fb:	68 94 17 80 00       	push   $0x801794
  801100:	e8 42 f0 ff ff       	call   800147 <_panic>

00801105 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801105:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801106:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80110b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80110d:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  801110:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  801114:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  801118:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  80111b:	83 c4 08             	add    $0x8,%esp
    popa
  80111e:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $0x4, %esp
  80111f:	83 c4 04             	add    $0x4,%esp
    popf
  801122:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  801123:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  801126:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  80112a:	c3                   	ret    
  80112b:	66 90                	xchg   %ax,%ax
  80112d:	66 90                	xchg   %ax,%ax
  80112f:	90                   	nop

00801130 <__udivdi3>:
  801130:	f3 0f 1e fb          	endbr32 
  801134:	55                   	push   %ebp
  801135:	57                   	push   %edi
  801136:	56                   	push   %esi
  801137:	53                   	push   %ebx
  801138:	83 ec 1c             	sub    $0x1c,%esp
  80113b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80113f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801143:	8b 74 24 34          	mov    0x34(%esp),%esi
  801147:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80114b:	85 d2                	test   %edx,%edx
  80114d:	75 19                	jne    801168 <__udivdi3+0x38>
  80114f:	39 f3                	cmp    %esi,%ebx
  801151:	76 4d                	jbe    8011a0 <__udivdi3+0x70>
  801153:	31 ff                	xor    %edi,%edi
  801155:	89 e8                	mov    %ebp,%eax
  801157:	89 f2                	mov    %esi,%edx
  801159:	f7 f3                	div    %ebx
  80115b:	89 fa                	mov    %edi,%edx
  80115d:	83 c4 1c             	add    $0x1c,%esp
  801160:	5b                   	pop    %ebx
  801161:	5e                   	pop    %esi
  801162:	5f                   	pop    %edi
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    
  801165:	8d 76 00             	lea    0x0(%esi),%esi
  801168:	39 f2                	cmp    %esi,%edx
  80116a:	76 14                	jbe    801180 <__udivdi3+0x50>
  80116c:	31 ff                	xor    %edi,%edi
  80116e:	31 c0                	xor    %eax,%eax
  801170:	89 fa                	mov    %edi,%edx
  801172:	83 c4 1c             	add    $0x1c,%esp
  801175:	5b                   	pop    %ebx
  801176:	5e                   	pop    %esi
  801177:	5f                   	pop    %edi
  801178:	5d                   	pop    %ebp
  801179:	c3                   	ret    
  80117a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801180:	0f bd fa             	bsr    %edx,%edi
  801183:	83 f7 1f             	xor    $0x1f,%edi
  801186:	75 48                	jne    8011d0 <__udivdi3+0xa0>
  801188:	39 f2                	cmp    %esi,%edx
  80118a:	72 06                	jb     801192 <__udivdi3+0x62>
  80118c:	31 c0                	xor    %eax,%eax
  80118e:	39 eb                	cmp    %ebp,%ebx
  801190:	77 de                	ja     801170 <__udivdi3+0x40>
  801192:	b8 01 00 00 00       	mov    $0x1,%eax
  801197:	eb d7                	jmp    801170 <__udivdi3+0x40>
  801199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011a0:	89 d9                	mov    %ebx,%ecx
  8011a2:	85 db                	test   %ebx,%ebx
  8011a4:	75 0b                	jne    8011b1 <__udivdi3+0x81>
  8011a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8011ab:	31 d2                	xor    %edx,%edx
  8011ad:	f7 f3                	div    %ebx
  8011af:	89 c1                	mov    %eax,%ecx
  8011b1:	31 d2                	xor    %edx,%edx
  8011b3:	89 f0                	mov    %esi,%eax
  8011b5:	f7 f1                	div    %ecx
  8011b7:	89 c6                	mov    %eax,%esi
  8011b9:	89 e8                	mov    %ebp,%eax
  8011bb:	89 f7                	mov    %esi,%edi
  8011bd:	f7 f1                	div    %ecx
  8011bf:	89 fa                	mov    %edi,%edx
  8011c1:	83 c4 1c             	add    $0x1c,%esp
  8011c4:	5b                   	pop    %ebx
  8011c5:	5e                   	pop    %esi
  8011c6:	5f                   	pop    %edi
  8011c7:	5d                   	pop    %ebp
  8011c8:	c3                   	ret    
  8011c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011d0:	89 f9                	mov    %edi,%ecx
  8011d2:	b8 20 00 00 00       	mov    $0x20,%eax
  8011d7:	29 f8                	sub    %edi,%eax
  8011d9:	d3 e2                	shl    %cl,%edx
  8011db:	89 54 24 08          	mov    %edx,0x8(%esp)
  8011df:	89 c1                	mov    %eax,%ecx
  8011e1:	89 da                	mov    %ebx,%edx
  8011e3:	d3 ea                	shr    %cl,%edx
  8011e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8011e9:	09 d1                	or     %edx,%ecx
  8011eb:	89 f2                	mov    %esi,%edx
  8011ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011f1:	89 f9                	mov    %edi,%ecx
  8011f3:	d3 e3                	shl    %cl,%ebx
  8011f5:	89 c1                	mov    %eax,%ecx
  8011f7:	d3 ea                	shr    %cl,%edx
  8011f9:	89 f9                	mov    %edi,%ecx
  8011fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011ff:	89 eb                	mov    %ebp,%ebx
  801201:	d3 e6                	shl    %cl,%esi
  801203:	89 c1                	mov    %eax,%ecx
  801205:	d3 eb                	shr    %cl,%ebx
  801207:	09 de                	or     %ebx,%esi
  801209:	89 f0                	mov    %esi,%eax
  80120b:	f7 74 24 08          	divl   0x8(%esp)
  80120f:	89 d6                	mov    %edx,%esi
  801211:	89 c3                	mov    %eax,%ebx
  801213:	f7 64 24 0c          	mull   0xc(%esp)
  801217:	39 d6                	cmp    %edx,%esi
  801219:	72 15                	jb     801230 <__udivdi3+0x100>
  80121b:	89 f9                	mov    %edi,%ecx
  80121d:	d3 e5                	shl    %cl,%ebp
  80121f:	39 c5                	cmp    %eax,%ebp
  801221:	73 04                	jae    801227 <__udivdi3+0xf7>
  801223:	39 d6                	cmp    %edx,%esi
  801225:	74 09                	je     801230 <__udivdi3+0x100>
  801227:	89 d8                	mov    %ebx,%eax
  801229:	31 ff                	xor    %edi,%edi
  80122b:	e9 40 ff ff ff       	jmp    801170 <__udivdi3+0x40>
  801230:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801233:	31 ff                	xor    %edi,%edi
  801235:	e9 36 ff ff ff       	jmp    801170 <__udivdi3+0x40>
  80123a:	66 90                	xchg   %ax,%ax
  80123c:	66 90                	xchg   %ax,%ax
  80123e:	66 90                	xchg   %ax,%ax

00801240 <__umoddi3>:
  801240:	f3 0f 1e fb          	endbr32 
  801244:	55                   	push   %ebp
  801245:	57                   	push   %edi
  801246:	56                   	push   %esi
  801247:	53                   	push   %ebx
  801248:	83 ec 1c             	sub    $0x1c,%esp
  80124b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80124f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801253:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801257:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80125b:	85 c0                	test   %eax,%eax
  80125d:	75 19                	jne    801278 <__umoddi3+0x38>
  80125f:	39 df                	cmp    %ebx,%edi
  801261:	76 5d                	jbe    8012c0 <__umoddi3+0x80>
  801263:	89 f0                	mov    %esi,%eax
  801265:	89 da                	mov    %ebx,%edx
  801267:	f7 f7                	div    %edi
  801269:	89 d0                	mov    %edx,%eax
  80126b:	31 d2                	xor    %edx,%edx
  80126d:	83 c4 1c             	add    $0x1c,%esp
  801270:	5b                   	pop    %ebx
  801271:	5e                   	pop    %esi
  801272:	5f                   	pop    %edi
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    
  801275:	8d 76 00             	lea    0x0(%esi),%esi
  801278:	89 f2                	mov    %esi,%edx
  80127a:	39 d8                	cmp    %ebx,%eax
  80127c:	76 12                	jbe    801290 <__umoddi3+0x50>
  80127e:	89 f0                	mov    %esi,%eax
  801280:	89 da                	mov    %ebx,%edx
  801282:	83 c4 1c             	add    $0x1c,%esp
  801285:	5b                   	pop    %ebx
  801286:	5e                   	pop    %esi
  801287:	5f                   	pop    %edi
  801288:	5d                   	pop    %ebp
  801289:	c3                   	ret    
  80128a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801290:	0f bd e8             	bsr    %eax,%ebp
  801293:	83 f5 1f             	xor    $0x1f,%ebp
  801296:	75 50                	jne    8012e8 <__umoddi3+0xa8>
  801298:	39 d8                	cmp    %ebx,%eax
  80129a:	0f 82 e0 00 00 00    	jb     801380 <__umoddi3+0x140>
  8012a0:	89 d9                	mov    %ebx,%ecx
  8012a2:	39 f7                	cmp    %esi,%edi
  8012a4:	0f 86 d6 00 00 00    	jbe    801380 <__umoddi3+0x140>
  8012aa:	89 d0                	mov    %edx,%eax
  8012ac:	89 ca                	mov    %ecx,%edx
  8012ae:	83 c4 1c             	add    $0x1c,%esp
  8012b1:	5b                   	pop    %ebx
  8012b2:	5e                   	pop    %esi
  8012b3:	5f                   	pop    %edi
  8012b4:	5d                   	pop    %ebp
  8012b5:	c3                   	ret    
  8012b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012bd:	8d 76 00             	lea    0x0(%esi),%esi
  8012c0:	89 fd                	mov    %edi,%ebp
  8012c2:	85 ff                	test   %edi,%edi
  8012c4:	75 0b                	jne    8012d1 <__umoddi3+0x91>
  8012c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8012cb:	31 d2                	xor    %edx,%edx
  8012cd:	f7 f7                	div    %edi
  8012cf:	89 c5                	mov    %eax,%ebp
  8012d1:	89 d8                	mov    %ebx,%eax
  8012d3:	31 d2                	xor    %edx,%edx
  8012d5:	f7 f5                	div    %ebp
  8012d7:	89 f0                	mov    %esi,%eax
  8012d9:	f7 f5                	div    %ebp
  8012db:	89 d0                	mov    %edx,%eax
  8012dd:	31 d2                	xor    %edx,%edx
  8012df:	eb 8c                	jmp    80126d <__umoddi3+0x2d>
  8012e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012e8:	89 e9                	mov    %ebp,%ecx
  8012ea:	ba 20 00 00 00       	mov    $0x20,%edx
  8012ef:	29 ea                	sub    %ebp,%edx
  8012f1:	d3 e0                	shl    %cl,%eax
  8012f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012f7:	89 d1                	mov    %edx,%ecx
  8012f9:	89 f8                	mov    %edi,%eax
  8012fb:	d3 e8                	shr    %cl,%eax
  8012fd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801301:	89 54 24 04          	mov    %edx,0x4(%esp)
  801305:	8b 54 24 04          	mov    0x4(%esp),%edx
  801309:	09 c1                	or     %eax,%ecx
  80130b:	89 d8                	mov    %ebx,%eax
  80130d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801311:	89 e9                	mov    %ebp,%ecx
  801313:	d3 e7                	shl    %cl,%edi
  801315:	89 d1                	mov    %edx,%ecx
  801317:	d3 e8                	shr    %cl,%eax
  801319:	89 e9                	mov    %ebp,%ecx
  80131b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80131f:	d3 e3                	shl    %cl,%ebx
  801321:	89 c7                	mov    %eax,%edi
  801323:	89 d1                	mov    %edx,%ecx
  801325:	89 f0                	mov    %esi,%eax
  801327:	d3 e8                	shr    %cl,%eax
  801329:	89 e9                	mov    %ebp,%ecx
  80132b:	89 fa                	mov    %edi,%edx
  80132d:	d3 e6                	shl    %cl,%esi
  80132f:	09 d8                	or     %ebx,%eax
  801331:	f7 74 24 08          	divl   0x8(%esp)
  801335:	89 d1                	mov    %edx,%ecx
  801337:	89 f3                	mov    %esi,%ebx
  801339:	f7 64 24 0c          	mull   0xc(%esp)
  80133d:	89 c6                	mov    %eax,%esi
  80133f:	89 d7                	mov    %edx,%edi
  801341:	39 d1                	cmp    %edx,%ecx
  801343:	72 06                	jb     80134b <__umoddi3+0x10b>
  801345:	75 10                	jne    801357 <__umoddi3+0x117>
  801347:	39 c3                	cmp    %eax,%ebx
  801349:	73 0c                	jae    801357 <__umoddi3+0x117>
  80134b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80134f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801353:	89 d7                	mov    %edx,%edi
  801355:	89 c6                	mov    %eax,%esi
  801357:	89 ca                	mov    %ecx,%edx
  801359:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80135e:	29 f3                	sub    %esi,%ebx
  801360:	19 fa                	sbb    %edi,%edx
  801362:	89 d0                	mov    %edx,%eax
  801364:	d3 e0                	shl    %cl,%eax
  801366:	89 e9                	mov    %ebp,%ecx
  801368:	d3 eb                	shr    %cl,%ebx
  80136a:	d3 ea                	shr    %cl,%edx
  80136c:	09 d8                	or     %ebx,%eax
  80136e:	83 c4 1c             	add    $0x1c,%esp
  801371:	5b                   	pop    %ebx
  801372:	5e                   	pop    %esi
  801373:	5f                   	pop    %edi
  801374:	5d                   	pop    %ebp
  801375:	c3                   	ret    
  801376:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80137d:	8d 76 00             	lea    0x0(%esi),%esi
  801380:	29 fe                	sub    %edi,%esi
  801382:	19 c3                	sbb    %eax,%ebx
  801384:	89 f2                	mov    %esi,%edx
  801386:	89 d9                	mov    %ebx,%ecx
  801388:	e9 1d ff ff ff       	jmp    8012aa <__umoddi3+0x6a>
