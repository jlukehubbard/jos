
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
  80003c:	e8 04 0c 00 00       	call   800c45 <sys_getenvid>
  800041:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  800043:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800048:	e8 24 0f 00 00       	call   800f71 <fork>
  80004d:	85 c0                	test   %eax,%eax
  80004f:	74 0f                	je     800060 <umain+0x2d>
	for (i = 0; i < 20; i++)
  800051:	83 c3 01             	add    $0x1,%ebx
  800054:	83 fb 14             	cmp    $0x14,%ebx
  800057:	75 ef                	jne    800048 <umain+0x15>
			break;
	if (i == 20) {
		sys_yield();
  800059:	e8 0a 0c 00 00       	call   800c68 <sys_yield>
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
  80007f:	e8 e4 0b 00 00       	call   800c68 <sys_yield>
  800084:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  800089:	a1 04 40 80 00       	mov    0x804004,%eax
  80008e:	83 c0 01             	add    $0x1,%eax
  800091:	a3 04 40 80 00       	mov    %eax,0x804004
		for (j = 0; j < 10000; j++)
  800096:	83 ea 01             	sub    $0x1,%edx
  800099:	75 ee                	jne    800089 <umain+0x56>
	for (i = 0; i < 10; i++) {
  80009b:	83 eb 01             	sub    $0x1,%ebx
  80009e:	75 df                	jne    80007f <umain+0x4c>
	}

	if (counter != 10*10000)
  8000a0:	a1 04 40 80 00       	mov    0x804004,%eax
  8000a5:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000aa:	75 24                	jne    8000d0 <umain+0x9d>
		panic("ran on two CPUs at once (counter is %d)", counter);

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000ac:	a1 08 40 80 00       	mov    0x804008,%eax
  8000b1:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000b4:	8b 40 48             	mov    0x48(%eax),%eax
  8000b7:	83 ec 04             	sub    $0x4,%esp
  8000ba:	52                   	push   %edx
  8000bb:	50                   	push   %eax
  8000bc:	68 bb 22 80 00       	push   $0x8022bb
  8000c1:	e8 7a 01 00 00       	call   800240 <cprintf>
  8000c6:	83 c4 10             	add    $0x10,%esp

}
  8000c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5d                   	pop    %ebp
  8000cf:	c3                   	ret    
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000d0:	a1 04 40 80 00       	mov    0x804004,%eax
  8000d5:	50                   	push   %eax
  8000d6:	68 80 22 80 00       	push   $0x802280
  8000db:	6a 21                	push   $0x21
  8000dd:	68 a8 22 80 00       	push   $0x8022a8
  8000e2:	e8 72 00 00 00       	call   800159 <_panic>

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
	thisenv = 0;
  8000f6:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  8000fd:	00 00 00 
    envid_t envid = sys_getenvid();
  800100:	e8 40 0b 00 00       	call   800c45 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800105:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800112:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800117:	85 db                	test   %ebx,%ebx
  800119:	7e 07                	jle    800122 <libmain+0x3b>
		binaryname = argv[0];
  80011b:	8b 06                	mov    (%esi),%eax
  80011d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	56                   	push   %esi
  800126:	53                   	push   %ebx
  800127:	e8 07 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80012c:	e8 0a 00 00 00       	call   80013b <exit>
}
  800131:	83 c4 10             	add    $0x10,%esp
  800134:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800137:	5b                   	pop    %ebx
  800138:	5e                   	pop    %esi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013b:	f3 0f 1e fb          	endbr32 
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800145:	e8 8d 11 00 00       	call   8012d7 <close_all>
	sys_env_destroy(0);
  80014a:	83 ec 0c             	sub    $0xc,%esp
  80014d:	6a 00                	push   $0x0
  80014f:	e8 ac 0a 00 00       	call   800c00 <sys_env_destroy>
}
  800154:	83 c4 10             	add    $0x10,%esp
  800157:	c9                   	leave  
  800158:	c3                   	ret    

00800159 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800159:	f3 0f 1e fb          	endbr32 
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	56                   	push   %esi
  800161:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800162:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800165:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80016b:	e8 d5 0a 00 00       	call   800c45 <sys_getenvid>
  800170:	83 ec 0c             	sub    $0xc,%esp
  800173:	ff 75 0c             	pushl  0xc(%ebp)
  800176:	ff 75 08             	pushl  0x8(%ebp)
  800179:	56                   	push   %esi
  80017a:	50                   	push   %eax
  80017b:	68 e4 22 80 00       	push   $0x8022e4
  800180:	e8 bb 00 00 00       	call   800240 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800185:	83 c4 18             	add    $0x18,%esp
  800188:	53                   	push   %ebx
  800189:	ff 75 10             	pushl  0x10(%ebp)
  80018c:	e8 5a 00 00 00       	call   8001eb <vcprintf>
	cprintf("\n");
  800191:	c7 04 24 fb 27 80 00 	movl   $0x8027fb,(%esp)
  800198:	e8 a3 00 00 00       	call   800240 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a0:	cc                   	int3   
  8001a1:	eb fd                	jmp    8001a0 <_panic+0x47>

008001a3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a3:	f3 0f 1e fb          	endbr32 
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 04             	sub    $0x4,%esp
  8001ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b1:	8b 13                	mov    (%ebx),%edx
  8001b3:	8d 42 01             	lea    0x1(%edx),%eax
  8001b6:	89 03                	mov    %eax,(%ebx)
  8001b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001bb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001bf:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c4:	74 09                	je     8001cf <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001c6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001cd:	c9                   	leave  
  8001ce:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001cf:	83 ec 08             	sub    $0x8,%esp
  8001d2:	68 ff 00 00 00       	push   $0xff
  8001d7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001da:	50                   	push   %eax
  8001db:	e8 db 09 00 00       	call   800bbb <sys_cputs>
		b->idx = 0;
  8001e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001e6:	83 c4 10             	add    $0x10,%esp
  8001e9:	eb db                	jmp    8001c6 <putch+0x23>

008001eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001eb:	f3 0f 1e fb          	endbr32 
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001f8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ff:	00 00 00 
	b.cnt = 0;
  800202:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800209:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80020c:	ff 75 0c             	pushl  0xc(%ebp)
  80020f:	ff 75 08             	pushl  0x8(%ebp)
  800212:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800218:	50                   	push   %eax
  800219:	68 a3 01 80 00       	push   $0x8001a3
  80021e:	e8 20 01 00 00       	call   800343 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800223:	83 c4 08             	add    $0x8,%esp
  800226:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80022c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800232:	50                   	push   %eax
  800233:	e8 83 09 00 00       	call   800bbb <sys_cputs>

	return b.cnt;
}
  800238:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800240:	f3 0f 1e fb          	endbr32 
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80024a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80024d:	50                   	push   %eax
  80024e:	ff 75 08             	pushl  0x8(%ebp)
  800251:	e8 95 ff ff ff       	call   8001eb <vcprintf>
	va_end(ap);

	return cnt;
}
  800256:	c9                   	leave  
  800257:	c3                   	ret    

00800258 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	57                   	push   %edi
  80025c:	56                   	push   %esi
  80025d:	53                   	push   %ebx
  80025e:	83 ec 1c             	sub    $0x1c,%esp
  800261:	89 c7                	mov    %eax,%edi
  800263:	89 d6                	mov    %edx,%esi
  800265:	8b 45 08             	mov    0x8(%ebp),%eax
  800268:	8b 55 0c             	mov    0xc(%ebp),%edx
  80026b:	89 d1                	mov    %edx,%ecx
  80026d:	89 c2                	mov    %eax,%edx
  80026f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800272:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800275:	8b 45 10             	mov    0x10(%ebp),%eax
  800278:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80027b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80027e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800285:	39 c2                	cmp    %eax,%edx
  800287:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80028a:	72 3e                	jb     8002ca <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	ff 75 18             	pushl  0x18(%ebp)
  800292:	83 eb 01             	sub    $0x1,%ebx
  800295:	53                   	push   %ebx
  800296:	50                   	push   %eax
  800297:	83 ec 08             	sub    $0x8,%esp
  80029a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029d:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a6:	e8 65 1d 00 00       	call   802010 <__udivdi3>
  8002ab:	83 c4 18             	add    $0x18,%esp
  8002ae:	52                   	push   %edx
  8002af:	50                   	push   %eax
  8002b0:	89 f2                	mov    %esi,%edx
  8002b2:	89 f8                	mov    %edi,%eax
  8002b4:	e8 9f ff ff ff       	call   800258 <printnum>
  8002b9:	83 c4 20             	add    $0x20,%esp
  8002bc:	eb 13                	jmp    8002d1 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002be:	83 ec 08             	sub    $0x8,%esp
  8002c1:	56                   	push   %esi
  8002c2:	ff 75 18             	pushl  0x18(%ebp)
  8002c5:	ff d7                	call   *%edi
  8002c7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002ca:	83 eb 01             	sub    $0x1,%ebx
  8002cd:	85 db                	test   %ebx,%ebx
  8002cf:	7f ed                	jg     8002be <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002d1:	83 ec 08             	sub    $0x8,%esp
  8002d4:	56                   	push   %esi
  8002d5:	83 ec 04             	sub    $0x4,%esp
  8002d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002db:	ff 75 e0             	pushl  -0x20(%ebp)
  8002de:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e4:	e8 37 1e 00 00       	call   802120 <__umoddi3>
  8002e9:	83 c4 14             	add    $0x14,%esp
  8002ec:	0f be 80 07 23 80 00 	movsbl 0x802307(%eax),%eax
  8002f3:	50                   	push   %eax
  8002f4:	ff d7                	call   *%edi
}
  8002f6:	83 c4 10             	add    $0x10,%esp
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800301:	f3 0f 1e fb          	endbr32 
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80030b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030f:	8b 10                	mov    (%eax),%edx
  800311:	3b 50 04             	cmp    0x4(%eax),%edx
  800314:	73 0a                	jae    800320 <sprintputch+0x1f>
		*b->buf++ = ch;
  800316:	8d 4a 01             	lea    0x1(%edx),%ecx
  800319:	89 08                	mov    %ecx,(%eax)
  80031b:	8b 45 08             	mov    0x8(%ebp),%eax
  80031e:	88 02                	mov    %al,(%edx)
}
  800320:	5d                   	pop    %ebp
  800321:	c3                   	ret    

00800322 <printfmt>:
{
  800322:	f3 0f 1e fb          	endbr32 
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80032c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80032f:	50                   	push   %eax
  800330:	ff 75 10             	pushl  0x10(%ebp)
  800333:	ff 75 0c             	pushl  0xc(%ebp)
  800336:	ff 75 08             	pushl  0x8(%ebp)
  800339:	e8 05 00 00 00       	call   800343 <vprintfmt>
}
  80033e:	83 c4 10             	add    $0x10,%esp
  800341:	c9                   	leave  
  800342:	c3                   	ret    

00800343 <vprintfmt>:
{
  800343:	f3 0f 1e fb          	endbr32 
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	57                   	push   %edi
  80034b:	56                   	push   %esi
  80034c:	53                   	push   %ebx
  80034d:	83 ec 3c             	sub    $0x3c,%esp
  800350:	8b 75 08             	mov    0x8(%ebp),%esi
  800353:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800356:	8b 7d 10             	mov    0x10(%ebp),%edi
  800359:	e9 4a 03 00 00       	jmp    8006a8 <vprintfmt+0x365>
		padc = ' ';
  80035e:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800362:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800369:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800370:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800377:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8d 47 01             	lea    0x1(%edi),%eax
  80037f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800382:	0f b6 17             	movzbl (%edi),%edx
  800385:	8d 42 dd             	lea    -0x23(%edx),%eax
  800388:	3c 55                	cmp    $0x55,%al
  80038a:	0f 87 de 03 00 00    	ja     80076e <vprintfmt+0x42b>
  800390:	0f b6 c0             	movzbl %al,%eax
  800393:	3e ff 24 85 40 24 80 	notrack jmp *0x802440(,%eax,4)
  80039a:	00 
  80039b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80039e:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003a2:	eb d8                	jmp    80037c <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a7:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003ab:	eb cf                	jmp    80037c <vprintfmt+0x39>
  8003ad:	0f b6 d2             	movzbl %dl,%edx
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003bb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003be:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003c2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003c5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003c8:	83 f9 09             	cmp    $0x9,%ecx
  8003cb:	77 55                	ja     800422 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003cd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003d0:	eb e9                	jmp    8003bb <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8b 00                	mov    (%eax),%eax
  8003d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003da:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dd:	8d 40 04             	lea    0x4(%eax),%eax
  8003e0:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003e6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ea:	79 90                	jns    80037c <vprintfmt+0x39>
				width = precision, precision = -1;
  8003ec:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f2:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003f9:	eb 81                	jmp    80037c <vprintfmt+0x39>
  8003fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003fe:	85 c0                	test   %eax,%eax
  800400:	ba 00 00 00 00       	mov    $0x0,%edx
  800405:	0f 49 d0             	cmovns %eax,%edx
  800408:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80040e:	e9 69 ff ff ff       	jmp    80037c <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800413:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800416:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80041d:	e9 5a ff ff ff       	jmp    80037c <vprintfmt+0x39>
  800422:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800425:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800428:	eb bc                	jmp    8003e6 <vprintfmt+0xa3>
			lflag++;
  80042a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800430:	e9 47 ff ff ff       	jmp    80037c <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 78 04             	lea    0x4(%eax),%edi
  80043b:	83 ec 08             	sub    $0x8,%esp
  80043e:	53                   	push   %ebx
  80043f:	ff 30                	pushl  (%eax)
  800441:	ff d6                	call   *%esi
			break;
  800443:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800446:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800449:	e9 57 02 00 00       	jmp    8006a5 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80044e:	8b 45 14             	mov    0x14(%ebp),%eax
  800451:	8d 78 04             	lea    0x4(%eax),%edi
  800454:	8b 00                	mov    (%eax),%eax
  800456:	99                   	cltd   
  800457:	31 d0                	xor    %edx,%eax
  800459:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045b:	83 f8 0f             	cmp    $0xf,%eax
  80045e:	7f 23                	jg     800483 <vprintfmt+0x140>
  800460:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  800467:	85 d2                	test   %edx,%edx
  800469:	74 18                	je     800483 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80046b:	52                   	push   %edx
  80046c:	68 a9 27 80 00       	push   $0x8027a9
  800471:	53                   	push   %ebx
  800472:	56                   	push   %esi
  800473:	e8 aa fe ff ff       	call   800322 <printfmt>
  800478:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80047b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80047e:	e9 22 02 00 00       	jmp    8006a5 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800483:	50                   	push   %eax
  800484:	68 1f 23 80 00       	push   $0x80231f
  800489:	53                   	push   %ebx
  80048a:	56                   	push   %esi
  80048b:	e8 92 fe ff ff       	call   800322 <printfmt>
  800490:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800493:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800496:	e9 0a 02 00 00       	jmp    8006a5 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  80049b:	8b 45 14             	mov    0x14(%ebp),%eax
  80049e:	83 c0 04             	add    $0x4,%eax
  8004a1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a7:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004a9:	85 d2                	test   %edx,%edx
  8004ab:	b8 18 23 80 00       	mov    $0x802318,%eax
  8004b0:	0f 45 c2             	cmovne %edx,%eax
  8004b3:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ba:	7e 06                	jle    8004c2 <vprintfmt+0x17f>
  8004bc:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004c0:	75 0d                	jne    8004cf <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004c5:	89 c7                	mov    %eax,%edi
  8004c7:	03 45 e0             	add    -0x20(%ebp),%eax
  8004ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004cd:	eb 55                	jmp    800524 <vprintfmt+0x1e1>
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	ff 75 d8             	pushl  -0x28(%ebp)
  8004d5:	ff 75 cc             	pushl  -0x34(%ebp)
  8004d8:	e8 45 03 00 00       	call   800822 <strnlen>
  8004dd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004e0:	29 c2                	sub    %eax,%edx
  8004e2:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004ea:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f1:	85 ff                	test   %edi,%edi
  8004f3:	7e 11                	jle    800506 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	53                   	push   %ebx
  8004f9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004fc:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fe:	83 ef 01             	sub    $0x1,%edi
  800501:	83 c4 10             	add    $0x10,%esp
  800504:	eb eb                	jmp    8004f1 <vprintfmt+0x1ae>
  800506:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800509:	85 d2                	test   %edx,%edx
  80050b:	b8 00 00 00 00       	mov    $0x0,%eax
  800510:	0f 49 c2             	cmovns %edx,%eax
  800513:	29 c2                	sub    %eax,%edx
  800515:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800518:	eb a8                	jmp    8004c2 <vprintfmt+0x17f>
					putch(ch, putdat);
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	53                   	push   %ebx
  80051e:	52                   	push   %edx
  80051f:	ff d6                	call   *%esi
  800521:	83 c4 10             	add    $0x10,%esp
  800524:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800527:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800529:	83 c7 01             	add    $0x1,%edi
  80052c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800530:	0f be d0             	movsbl %al,%edx
  800533:	85 d2                	test   %edx,%edx
  800535:	74 4b                	je     800582 <vprintfmt+0x23f>
  800537:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053b:	78 06                	js     800543 <vprintfmt+0x200>
  80053d:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800541:	78 1e                	js     800561 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800543:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800547:	74 d1                	je     80051a <vprintfmt+0x1d7>
  800549:	0f be c0             	movsbl %al,%eax
  80054c:	83 e8 20             	sub    $0x20,%eax
  80054f:	83 f8 5e             	cmp    $0x5e,%eax
  800552:	76 c6                	jbe    80051a <vprintfmt+0x1d7>
					putch('?', putdat);
  800554:	83 ec 08             	sub    $0x8,%esp
  800557:	53                   	push   %ebx
  800558:	6a 3f                	push   $0x3f
  80055a:	ff d6                	call   *%esi
  80055c:	83 c4 10             	add    $0x10,%esp
  80055f:	eb c3                	jmp    800524 <vprintfmt+0x1e1>
  800561:	89 cf                	mov    %ecx,%edi
  800563:	eb 0e                	jmp    800573 <vprintfmt+0x230>
				putch(' ', putdat);
  800565:	83 ec 08             	sub    $0x8,%esp
  800568:	53                   	push   %ebx
  800569:	6a 20                	push   $0x20
  80056b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80056d:	83 ef 01             	sub    $0x1,%edi
  800570:	83 c4 10             	add    $0x10,%esp
  800573:	85 ff                	test   %edi,%edi
  800575:	7f ee                	jg     800565 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800577:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80057a:	89 45 14             	mov    %eax,0x14(%ebp)
  80057d:	e9 23 01 00 00       	jmp    8006a5 <vprintfmt+0x362>
  800582:	89 cf                	mov    %ecx,%edi
  800584:	eb ed                	jmp    800573 <vprintfmt+0x230>
	if (lflag >= 2)
  800586:	83 f9 01             	cmp    $0x1,%ecx
  800589:	7f 1b                	jg     8005a6 <vprintfmt+0x263>
	else if (lflag)
  80058b:	85 c9                	test   %ecx,%ecx
  80058d:	74 63                	je     8005f2 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8b 00                	mov    (%eax),%eax
  800594:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800597:	99                   	cltd   
  800598:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8d 40 04             	lea    0x4(%eax),%eax
  8005a1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a4:	eb 17                	jmp    8005bd <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8b 50 04             	mov    0x4(%eax),%edx
  8005ac:	8b 00                	mov    (%eax),%eax
  8005ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 40 08             	lea    0x8(%eax),%eax
  8005ba:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005bd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005c3:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005c8:	85 c9                	test   %ecx,%ecx
  8005ca:	0f 89 bb 00 00 00    	jns    80068b <vprintfmt+0x348>
				putch('-', putdat);
  8005d0:	83 ec 08             	sub    $0x8,%esp
  8005d3:	53                   	push   %ebx
  8005d4:	6a 2d                	push   $0x2d
  8005d6:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005db:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005de:	f7 da                	neg    %edx
  8005e0:	83 d1 00             	adc    $0x0,%ecx
  8005e3:	f7 d9                	neg    %ecx
  8005e5:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005e8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ed:	e9 99 00 00 00       	jmp    80068b <vprintfmt+0x348>
		return va_arg(*ap, int);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8b 00                	mov    (%eax),%eax
  8005f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fa:	99                   	cltd   
  8005fb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8d 40 04             	lea    0x4(%eax),%eax
  800604:	89 45 14             	mov    %eax,0x14(%ebp)
  800607:	eb b4                	jmp    8005bd <vprintfmt+0x27a>
	if (lflag >= 2)
  800609:	83 f9 01             	cmp    $0x1,%ecx
  80060c:	7f 1b                	jg     800629 <vprintfmt+0x2e6>
	else if (lflag)
  80060e:	85 c9                	test   %ecx,%ecx
  800610:	74 2c                	je     80063e <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8b 10                	mov    (%eax),%edx
  800617:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061c:	8d 40 04             	lea    0x4(%eax),%eax
  80061f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800622:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800627:	eb 62                	jmp    80068b <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8b 10                	mov    (%eax),%edx
  80062e:	8b 48 04             	mov    0x4(%eax),%ecx
  800631:	8d 40 08             	lea    0x8(%eax),%eax
  800634:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800637:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80063c:	eb 4d                	jmp    80068b <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8b 10                	mov    (%eax),%edx
  800643:	b9 00 00 00 00       	mov    $0x0,%ecx
  800648:	8d 40 04             	lea    0x4(%eax),%eax
  80064b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80064e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800653:	eb 36                	jmp    80068b <vprintfmt+0x348>
	if (lflag >= 2)
  800655:	83 f9 01             	cmp    $0x1,%ecx
  800658:	7f 17                	jg     800671 <vprintfmt+0x32e>
	else if (lflag)
  80065a:	85 c9                	test   %ecx,%ecx
  80065c:	74 6e                	je     8006cc <vprintfmt+0x389>
		return va_arg(*ap, long);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8b 10                	mov    (%eax),%edx
  800663:	89 d0                	mov    %edx,%eax
  800665:	99                   	cltd   
  800666:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800669:	8d 49 04             	lea    0x4(%ecx),%ecx
  80066c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80066f:	eb 11                	jmp    800682 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8b 50 04             	mov    0x4(%eax),%edx
  800677:	8b 00                	mov    (%eax),%eax
  800679:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80067c:	8d 49 08             	lea    0x8(%ecx),%ecx
  80067f:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800682:	89 d1                	mov    %edx,%ecx
  800684:	89 c2                	mov    %eax,%edx
            base = 8;
  800686:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80068b:	83 ec 0c             	sub    $0xc,%esp
  80068e:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800692:	57                   	push   %edi
  800693:	ff 75 e0             	pushl  -0x20(%ebp)
  800696:	50                   	push   %eax
  800697:	51                   	push   %ecx
  800698:	52                   	push   %edx
  800699:	89 da                	mov    %ebx,%edx
  80069b:	89 f0                	mov    %esi,%eax
  80069d:	e8 b6 fb ff ff       	call   800258 <printnum>
			break;
  8006a2:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006a8:	83 c7 01             	add    $0x1,%edi
  8006ab:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006af:	83 f8 25             	cmp    $0x25,%eax
  8006b2:	0f 84 a6 fc ff ff    	je     80035e <vprintfmt+0x1b>
			if (ch == '\0')
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	0f 84 ce 00 00 00    	je     80078e <vprintfmt+0x44b>
			putch(ch, putdat);
  8006c0:	83 ec 08             	sub    $0x8,%esp
  8006c3:	53                   	push   %ebx
  8006c4:	50                   	push   %eax
  8006c5:	ff d6                	call   *%esi
  8006c7:	83 c4 10             	add    $0x10,%esp
  8006ca:	eb dc                	jmp    8006a8 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8b 10                	mov    (%eax),%edx
  8006d1:	89 d0                	mov    %edx,%eax
  8006d3:	99                   	cltd   
  8006d4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006d7:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006da:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006dd:	eb a3                	jmp    800682 <vprintfmt+0x33f>
			putch('0', putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	53                   	push   %ebx
  8006e3:	6a 30                	push   $0x30
  8006e5:	ff d6                	call   *%esi
			putch('x', putdat);
  8006e7:	83 c4 08             	add    $0x8,%esp
  8006ea:	53                   	push   %ebx
  8006eb:	6a 78                	push   $0x78
  8006ed:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8b 10                	mov    (%eax),%edx
  8006f4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006f9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006fc:	8d 40 04             	lea    0x4(%eax),%eax
  8006ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800702:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800707:	eb 82                	jmp    80068b <vprintfmt+0x348>
	if (lflag >= 2)
  800709:	83 f9 01             	cmp    $0x1,%ecx
  80070c:	7f 1e                	jg     80072c <vprintfmt+0x3e9>
	else if (lflag)
  80070e:	85 c9                	test   %ecx,%ecx
  800710:	74 32                	je     800744 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8b 10                	mov    (%eax),%edx
  800717:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071c:	8d 40 04             	lea    0x4(%eax),%eax
  80071f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800722:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800727:	e9 5f ff ff ff       	jmp    80068b <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8b 10                	mov    (%eax),%edx
  800731:	8b 48 04             	mov    0x4(%eax),%ecx
  800734:	8d 40 08             	lea    0x8(%eax),%eax
  800737:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80073f:	e9 47 ff ff ff       	jmp    80068b <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800744:	8b 45 14             	mov    0x14(%ebp),%eax
  800747:	8b 10                	mov    (%eax),%edx
  800749:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074e:	8d 40 04             	lea    0x4(%eax),%eax
  800751:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800754:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800759:	e9 2d ff ff ff       	jmp    80068b <vprintfmt+0x348>
			putch(ch, putdat);
  80075e:	83 ec 08             	sub    $0x8,%esp
  800761:	53                   	push   %ebx
  800762:	6a 25                	push   $0x25
  800764:	ff d6                	call   *%esi
			break;
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	e9 37 ff ff ff       	jmp    8006a5 <vprintfmt+0x362>
			putch('%', putdat);
  80076e:	83 ec 08             	sub    $0x8,%esp
  800771:	53                   	push   %ebx
  800772:	6a 25                	push   $0x25
  800774:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800776:	83 c4 10             	add    $0x10,%esp
  800779:	89 f8                	mov    %edi,%eax
  80077b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80077f:	74 05                	je     800786 <vprintfmt+0x443>
  800781:	83 e8 01             	sub    $0x1,%eax
  800784:	eb f5                	jmp    80077b <vprintfmt+0x438>
  800786:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800789:	e9 17 ff ff ff       	jmp    8006a5 <vprintfmt+0x362>
}
  80078e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800791:	5b                   	pop    %ebx
  800792:	5e                   	pop    %esi
  800793:	5f                   	pop    %edi
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800796:	f3 0f 1e fb          	endbr32 
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	83 ec 18             	sub    $0x18,%esp
  8007a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ad:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b7:	85 c0                	test   %eax,%eax
  8007b9:	74 26                	je     8007e1 <vsnprintf+0x4b>
  8007bb:	85 d2                	test   %edx,%edx
  8007bd:	7e 22                	jle    8007e1 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007bf:	ff 75 14             	pushl  0x14(%ebp)
  8007c2:	ff 75 10             	pushl  0x10(%ebp)
  8007c5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c8:	50                   	push   %eax
  8007c9:	68 01 03 80 00       	push   $0x800301
  8007ce:	e8 70 fb ff ff       	call   800343 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007dc:	83 c4 10             	add    $0x10,%esp
}
  8007df:	c9                   	leave  
  8007e0:	c3                   	ret    
		return -E_INVAL;
  8007e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e6:	eb f7                	jmp    8007df <vsnprintf+0x49>

008007e8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e8:	f3 0f 1e fb          	endbr32 
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f5:	50                   	push   %eax
  8007f6:	ff 75 10             	pushl  0x10(%ebp)
  8007f9:	ff 75 0c             	pushl  0xc(%ebp)
  8007fc:	ff 75 08             	pushl  0x8(%ebp)
  8007ff:	e8 92 ff ff ff       	call   800796 <vsnprintf>
	va_end(ap);

	return rc;
}
  800804:	c9                   	leave  
  800805:	c3                   	ret    

00800806 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800806:	f3 0f 1e fb          	endbr32 
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800810:	b8 00 00 00 00       	mov    $0x0,%eax
  800815:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800819:	74 05                	je     800820 <strlen+0x1a>
		n++;
  80081b:	83 c0 01             	add    $0x1,%eax
  80081e:	eb f5                	jmp    800815 <strlen+0xf>
	return n;
}
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800822:	f3 0f 1e fb          	endbr32 
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082f:	b8 00 00 00 00       	mov    $0x0,%eax
  800834:	39 d0                	cmp    %edx,%eax
  800836:	74 0d                	je     800845 <strnlen+0x23>
  800838:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80083c:	74 05                	je     800843 <strnlen+0x21>
		n++;
  80083e:	83 c0 01             	add    $0x1,%eax
  800841:	eb f1                	jmp    800834 <strnlen+0x12>
  800843:	89 c2                	mov    %eax,%edx
	return n;
}
  800845:	89 d0                	mov    %edx,%eax
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800849:	f3 0f 1e fb          	endbr32 
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	53                   	push   %ebx
  800851:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800854:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800857:	b8 00 00 00 00       	mov    $0x0,%eax
  80085c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800860:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800863:	83 c0 01             	add    $0x1,%eax
  800866:	84 d2                	test   %dl,%dl
  800868:	75 f2                	jne    80085c <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80086a:	89 c8                	mov    %ecx,%eax
  80086c:	5b                   	pop    %ebx
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80086f:	f3 0f 1e fb          	endbr32 
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	53                   	push   %ebx
  800877:	83 ec 10             	sub    $0x10,%esp
  80087a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80087d:	53                   	push   %ebx
  80087e:	e8 83 ff ff ff       	call   800806 <strlen>
  800883:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800886:	ff 75 0c             	pushl  0xc(%ebp)
  800889:	01 d8                	add    %ebx,%eax
  80088b:	50                   	push   %eax
  80088c:	e8 b8 ff ff ff       	call   800849 <strcpy>
	return dst;
}
  800891:	89 d8                	mov    %ebx,%eax
  800893:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800896:	c9                   	leave  
  800897:	c3                   	ret    

00800898 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800898:	f3 0f 1e fb          	endbr32 
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	56                   	push   %esi
  8008a0:	53                   	push   %ebx
  8008a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a7:	89 f3                	mov    %esi,%ebx
  8008a9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ac:	89 f0                	mov    %esi,%eax
  8008ae:	39 d8                	cmp    %ebx,%eax
  8008b0:	74 11                	je     8008c3 <strncpy+0x2b>
		*dst++ = *src;
  8008b2:	83 c0 01             	add    $0x1,%eax
  8008b5:	0f b6 0a             	movzbl (%edx),%ecx
  8008b8:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008bb:	80 f9 01             	cmp    $0x1,%cl
  8008be:	83 da ff             	sbb    $0xffffffff,%edx
  8008c1:	eb eb                	jmp    8008ae <strncpy+0x16>
	}
	return ret;
}
  8008c3:	89 f0                	mov    %esi,%eax
  8008c5:	5b                   	pop    %ebx
  8008c6:	5e                   	pop    %esi
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c9:	f3 0f 1e fb          	endbr32 
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
  8008d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d8:	8b 55 10             	mov    0x10(%ebp),%edx
  8008db:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008dd:	85 d2                	test   %edx,%edx
  8008df:	74 21                	je     800902 <strlcpy+0x39>
  8008e1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008e5:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008e7:	39 c2                	cmp    %eax,%edx
  8008e9:	74 14                	je     8008ff <strlcpy+0x36>
  8008eb:	0f b6 19             	movzbl (%ecx),%ebx
  8008ee:	84 db                	test   %bl,%bl
  8008f0:	74 0b                	je     8008fd <strlcpy+0x34>
			*dst++ = *src++;
  8008f2:	83 c1 01             	add    $0x1,%ecx
  8008f5:	83 c2 01             	add    $0x1,%edx
  8008f8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008fb:	eb ea                	jmp    8008e7 <strlcpy+0x1e>
  8008fd:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008ff:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800902:	29 f0                	sub    %esi,%eax
}
  800904:	5b                   	pop    %ebx
  800905:	5e                   	pop    %esi
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800908:	f3 0f 1e fb          	endbr32 
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800912:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800915:	0f b6 01             	movzbl (%ecx),%eax
  800918:	84 c0                	test   %al,%al
  80091a:	74 0c                	je     800928 <strcmp+0x20>
  80091c:	3a 02                	cmp    (%edx),%al
  80091e:	75 08                	jne    800928 <strcmp+0x20>
		p++, q++;
  800920:	83 c1 01             	add    $0x1,%ecx
  800923:	83 c2 01             	add    $0x1,%edx
  800926:	eb ed                	jmp    800915 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800928:	0f b6 c0             	movzbl %al,%eax
  80092b:	0f b6 12             	movzbl (%edx),%edx
  80092e:	29 d0                	sub    %edx,%eax
}
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800932:	f3 0f 1e fb          	endbr32 
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	53                   	push   %ebx
  80093a:	8b 45 08             	mov    0x8(%ebp),%eax
  80093d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800940:	89 c3                	mov    %eax,%ebx
  800942:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800945:	eb 06                	jmp    80094d <strncmp+0x1b>
		n--, p++, q++;
  800947:	83 c0 01             	add    $0x1,%eax
  80094a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80094d:	39 d8                	cmp    %ebx,%eax
  80094f:	74 16                	je     800967 <strncmp+0x35>
  800951:	0f b6 08             	movzbl (%eax),%ecx
  800954:	84 c9                	test   %cl,%cl
  800956:	74 04                	je     80095c <strncmp+0x2a>
  800958:	3a 0a                	cmp    (%edx),%cl
  80095a:	74 eb                	je     800947 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80095c:	0f b6 00             	movzbl (%eax),%eax
  80095f:	0f b6 12             	movzbl (%edx),%edx
  800962:	29 d0                	sub    %edx,%eax
}
  800964:	5b                   	pop    %ebx
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    
		return 0;
  800967:	b8 00 00 00 00       	mov    $0x0,%eax
  80096c:	eb f6                	jmp    800964 <strncmp+0x32>

0080096e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80096e:	f3 0f 1e fb          	endbr32 
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80097c:	0f b6 10             	movzbl (%eax),%edx
  80097f:	84 d2                	test   %dl,%dl
  800981:	74 09                	je     80098c <strchr+0x1e>
		if (*s == c)
  800983:	38 ca                	cmp    %cl,%dl
  800985:	74 0a                	je     800991 <strchr+0x23>
	for (; *s; s++)
  800987:	83 c0 01             	add    $0x1,%eax
  80098a:	eb f0                	jmp    80097c <strchr+0xe>
			return (char *) s;
	return 0;
  80098c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800993:	f3 0f 1e fb          	endbr32 
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009a4:	38 ca                	cmp    %cl,%dl
  8009a6:	74 09                	je     8009b1 <strfind+0x1e>
  8009a8:	84 d2                	test   %dl,%dl
  8009aa:	74 05                	je     8009b1 <strfind+0x1e>
	for (; *s; s++)
  8009ac:	83 c0 01             	add    $0x1,%eax
  8009af:	eb f0                	jmp    8009a1 <strfind+0xe>
			break;
	return (char *) s;
}
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b3:	f3 0f 1e fb          	endbr32 
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	57                   	push   %edi
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c3:	85 c9                	test   %ecx,%ecx
  8009c5:	74 31                	je     8009f8 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c7:	89 f8                	mov    %edi,%eax
  8009c9:	09 c8                	or     %ecx,%eax
  8009cb:	a8 03                	test   $0x3,%al
  8009cd:	75 23                	jne    8009f2 <memset+0x3f>
		c &= 0xFF;
  8009cf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d3:	89 d3                	mov    %edx,%ebx
  8009d5:	c1 e3 08             	shl    $0x8,%ebx
  8009d8:	89 d0                	mov    %edx,%eax
  8009da:	c1 e0 18             	shl    $0x18,%eax
  8009dd:	89 d6                	mov    %edx,%esi
  8009df:	c1 e6 10             	shl    $0x10,%esi
  8009e2:	09 f0                	or     %esi,%eax
  8009e4:	09 c2                	or     %eax,%edx
  8009e6:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009e8:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009eb:	89 d0                	mov    %edx,%eax
  8009ed:	fc                   	cld    
  8009ee:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f0:	eb 06                	jmp    8009f8 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f5:	fc                   	cld    
  8009f6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009f8:	89 f8                	mov    %edi,%eax
  8009fa:	5b                   	pop    %ebx
  8009fb:	5e                   	pop    %esi
  8009fc:	5f                   	pop    %edi
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ff:	f3 0f 1e fb          	endbr32 
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	57                   	push   %edi
  800a07:	56                   	push   %esi
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a11:	39 c6                	cmp    %eax,%esi
  800a13:	73 32                	jae    800a47 <memmove+0x48>
  800a15:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a18:	39 c2                	cmp    %eax,%edx
  800a1a:	76 2b                	jbe    800a47 <memmove+0x48>
		s += n;
		d += n;
  800a1c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1f:	89 fe                	mov    %edi,%esi
  800a21:	09 ce                	or     %ecx,%esi
  800a23:	09 d6                	or     %edx,%esi
  800a25:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a2b:	75 0e                	jne    800a3b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a2d:	83 ef 04             	sub    $0x4,%edi
  800a30:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a33:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a36:	fd                   	std    
  800a37:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a39:	eb 09                	jmp    800a44 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a3b:	83 ef 01             	sub    $0x1,%edi
  800a3e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a41:	fd                   	std    
  800a42:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a44:	fc                   	cld    
  800a45:	eb 1a                	jmp    800a61 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a47:	89 c2                	mov    %eax,%edx
  800a49:	09 ca                	or     %ecx,%edx
  800a4b:	09 f2                	or     %esi,%edx
  800a4d:	f6 c2 03             	test   $0x3,%dl
  800a50:	75 0a                	jne    800a5c <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a52:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a55:	89 c7                	mov    %eax,%edi
  800a57:	fc                   	cld    
  800a58:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5a:	eb 05                	jmp    800a61 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a5c:	89 c7                	mov    %eax,%edi
  800a5e:	fc                   	cld    
  800a5f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a61:	5e                   	pop    %esi
  800a62:	5f                   	pop    %edi
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a65:	f3 0f 1e fb          	endbr32 
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a6f:	ff 75 10             	pushl  0x10(%ebp)
  800a72:	ff 75 0c             	pushl  0xc(%ebp)
  800a75:	ff 75 08             	pushl  0x8(%ebp)
  800a78:	e8 82 ff ff ff       	call   8009ff <memmove>
}
  800a7d:	c9                   	leave  
  800a7e:	c3                   	ret    

00800a7f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a7f:	f3 0f 1e fb          	endbr32 
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8e:	89 c6                	mov    %eax,%esi
  800a90:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a93:	39 f0                	cmp    %esi,%eax
  800a95:	74 1c                	je     800ab3 <memcmp+0x34>
		if (*s1 != *s2)
  800a97:	0f b6 08             	movzbl (%eax),%ecx
  800a9a:	0f b6 1a             	movzbl (%edx),%ebx
  800a9d:	38 d9                	cmp    %bl,%cl
  800a9f:	75 08                	jne    800aa9 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800aa1:	83 c0 01             	add    $0x1,%eax
  800aa4:	83 c2 01             	add    $0x1,%edx
  800aa7:	eb ea                	jmp    800a93 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800aa9:	0f b6 c1             	movzbl %cl,%eax
  800aac:	0f b6 db             	movzbl %bl,%ebx
  800aaf:	29 d8                	sub    %ebx,%eax
  800ab1:	eb 05                	jmp    800ab8 <memcmp+0x39>
	}

	return 0;
  800ab3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800abc:	f3 0f 1e fb          	endbr32 
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ac9:	89 c2                	mov    %eax,%edx
  800acb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ace:	39 d0                	cmp    %edx,%eax
  800ad0:	73 09                	jae    800adb <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad2:	38 08                	cmp    %cl,(%eax)
  800ad4:	74 05                	je     800adb <memfind+0x1f>
	for (; s < ends; s++)
  800ad6:	83 c0 01             	add    $0x1,%eax
  800ad9:	eb f3                	jmp    800ace <memfind+0x12>
			break;
	return (void *) s;
}
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800add:	f3 0f 1e fb          	endbr32 
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
  800ae7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aed:	eb 03                	jmp    800af2 <strtol+0x15>
		s++;
  800aef:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800af2:	0f b6 01             	movzbl (%ecx),%eax
  800af5:	3c 20                	cmp    $0x20,%al
  800af7:	74 f6                	je     800aef <strtol+0x12>
  800af9:	3c 09                	cmp    $0x9,%al
  800afb:	74 f2                	je     800aef <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800afd:	3c 2b                	cmp    $0x2b,%al
  800aff:	74 2a                	je     800b2b <strtol+0x4e>
	int neg = 0;
  800b01:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b06:	3c 2d                	cmp    $0x2d,%al
  800b08:	74 2b                	je     800b35 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b0a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b10:	75 0f                	jne    800b21 <strtol+0x44>
  800b12:	80 39 30             	cmpb   $0x30,(%ecx)
  800b15:	74 28                	je     800b3f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b17:	85 db                	test   %ebx,%ebx
  800b19:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b1e:	0f 44 d8             	cmove  %eax,%ebx
  800b21:	b8 00 00 00 00       	mov    $0x0,%eax
  800b26:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b29:	eb 46                	jmp    800b71 <strtol+0x94>
		s++;
  800b2b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b2e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b33:	eb d5                	jmp    800b0a <strtol+0x2d>
		s++, neg = 1;
  800b35:	83 c1 01             	add    $0x1,%ecx
  800b38:	bf 01 00 00 00       	mov    $0x1,%edi
  800b3d:	eb cb                	jmp    800b0a <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b3f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b43:	74 0e                	je     800b53 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b45:	85 db                	test   %ebx,%ebx
  800b47:	75 d8                	jne    800b21 <strtol+0x44>
		s++, base = 8;
  800b49:	83 c1 01             	add    $0x1,%ecx
  800b4c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b51:	eb ce                	jmp    800b21 <strtol+0x44>
		s += 2, base = 16;
  800b53:	83 c1 02             	add    $0x2,%ecx
  800b56:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b5b:	eb c4                	jmp    800b21 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b5d:	0f be d2             	movsbl %dl,%edx
  800b60:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b63:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b66:	7d 3a                	jge    800ba2 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b68:	83 c1 01             	add    $0x1,%ecx
  800b6b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b6f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b71:	0f b6 11             	movzbl (%ecx),%edx
  800b74:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b77:	89 f3                	mov    %esi,%ebx
  800b79:	80 fb 09             	cmp    $0x9,%bl
  800b7c:	76 df                	jbe    800b5d <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b7e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b81:	89 f3                	mov    %esi,%ebx
  800b83:	80 fb 19             	cmp    $0x19,%bl
  800b86:	77 08                	ja     800b90 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b88:	0f be d2             	movsbl %dl,%edx
  800b8b:	83 ea 57             	sub    $0x57,%edx
  800b8e:	eb d3                	jmp    800b63 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b90:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b93:	89 f3                	mov    %esi,%ebx
  800b95:	80 fb 19             	cmp    $0x19,%bl
  800b98:	77 08                	ja     800ba2 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b9a:	0f be d2             	movsbl %dl,%edx
  800b9d:	83 ea 37             	sub    $0x37,%edx
  800ba0:	eb c1                	jmp    800b63 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ba2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba6:	74 05                	je     800bad <strtol+0xd0>
		*endptr = (char *) s;
  800ba8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bab:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bad:	89 c2                	mov    %eax,%edx
  800baf:	f7 da                	neg    %edx
  800bb1:	85 ff                	test   %edi,%edi
  800bb3:	0f 45 c2             	cmovne %edx,%eax
}
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bbb:	f3 0f 1e fb          	endbr32 
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bca:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd0:	89 c3                	mov    %eax,%ebx
  800bd2:	89 c7                	mov    %eax,%edi
  800bd4:	89 c6                	mov    %eax,%esi
  800bd6:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_cgetc>:

int
sys_cgetc(void)
{
  800bdd:	f3 0f 1e fb          	endbr32 
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bec:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf1:	89 d1                	mov    %edx,%ecx
  800bf3:	89 d3                	mov    %edx,%ebx
  800bf5:	89 d7                	mov    %edx,%edi
  800bf7:	89 d6                	mov    %edx,%esi
  800bf9:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c00:	f3 0f 1e fb          	endbr32 
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c12:	8b 55 08             	mov    0x8(%ebp),%edx
  800c15:	b8 03 00 00 00       	mov    $0x3,%eax
  800c1a:	89 cb                	mov    %ecx,%ebx
  800c1c:	89 cf                	mov    %ecx,%edi
  800c1e:	89 ce                	mov    %ecx,%esi
  800c20:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c22:	85 c0                	test   %eax,%eax
  800c24:	7f 08                	jg     800c2e <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2e:	83 ec 0c             	sub    $0xc,%esp
  800c31:	50                   	push   %eax
  800c32:	6a 03                	push   $0x3
  800c34:	68 ff 25 80 00       	push   $0x8025ff
  800c39:	6a 23                	push   $0x23
  800c3b:	68 1c 26 80 00       	push   $0x80261c
  800c40:	e8 14 f5 ff ff       	call   800159 <_panic>

00800c45 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c45:	f3 0f 1e fb          	endbr32 
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c54:	b8 02 00 00 00       	mov    $0x2,%eax
  800c59:	89 d1                	mov    %edx,%ecx
  800c5b:	89 d3                	mov    %edx,%ebx
  800c5d:	89 d7                	mov    %edx,%edi
  800c5f:	89 d6                	mov    %edx,%esi
  800c61:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_yield>:

void
sys_yield(void)
{
  800c68:	f3 0f 1e fb          	endbr32 
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c72:	ba 00 00 00 00       	mov    $0x0,%edx
  800c77:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c7c:	89 d1                	mov    %edx,%ecx
  800c7e:	89 d3                	mov    %edx,%ebx
  800c80:	89 d7                	mov    %edx,%edi
  800c82:	89 d6                	mov    %edx,%esi
  800c84:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c8b:	f3 0f 1e fb          	endbr32 
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c98:	be 00 00 00 00       	mov    $0x0,%esi
  800c9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca3:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cab:	89 f7                	mov    %esi,%edi
  800cad:	cd 30                	int    $0x30
	if(check && ret > 0)
  800caf:	85 c0                	test   %eax,%eax
  800cb1:	7f 08                	jg     800cbb <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbb:	83 ec 0c             	sub    $0xc,%esp
  800cbe:	50                   	push   %eax
  800cbf:	6a 04                	push   $0x4
  800cc1:	68 ff 25 80 00       	push   $0x8025ff
  800cc6:	6a 23                	push   $0x23
  800cc8:	68 1c 26 80 00       	push   $0x80261c
  800ccd:	e8 87 f4 ff ff       	call   800159 <_panic>

00800cd2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd2:	f3 0f 1e fb          	endbr32 
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
  800cdc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce5:	b8 05 00 00 00       	mov    $0x5,%eax
  800cea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ced:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf0:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	7f 08                	jg     800d01 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d01:	83 ec 0c             	sub    $0xc,%esp
  800d04:	50                   	push   %eax
  800d05:	6a 05                	push   $0x5
  800d07:	68 ff 25 80 00       	push   $0x8025ff
  800d0c:	6a 23                	push   $0x23
  800d0e:	68 1c 26 80 00       	push   $0x80261c
  800d13:	e8 41 f4 ff ff       	call   800159 <_panic>

00800d18 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d18:	f3 0f 1e fb          	endbr32 
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
  800d22:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d30:	b8 06 00 00 00       	mov    $0x6,%eax
  800d35:	89 df                	mov    %ebx,%edi
  800d37:	89 de                	mov    %ebx,%esi
  800d39:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	7f 08                	jg     800d47 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d47:	83 ec 0c             	sub    $0xc,%esp
  800d4a:	50                   	push   %eax
  800d4b:	6a 06                	push   $0x6
  800d4d:	68 ff 25 80 00       	push   $0x8025ff
  800d52:	6a 23                	push   $0x23
  800d54:	68 1c 26 80 00       	push   $0x80261c
  800d59:	e8 fb f3 ff ff       	call   800159 <_panic>

00800d5e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d5e:	f3 0f 1e fb          	endbr32 
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
  800d68:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
  800d73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d76:	b8 08 00 00 00       	mov    $0x8,%eax
  800d7b:	89 df                	mov    %ebx,%edi
  800d7d:	89 de                	mov    %ebx,%esi
  800d7f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d81:	85 c0                	test   %eax,%eax
  800d83:	7f 08                	jg     800d8d <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8d:	83 ec 0c             	sub    $0xc,%esp
  800d90:	50                   	push   %eax
  800d91:	6a 08                	push   $0x8
  800d93:	68 ff 25 80 00       	push   $0x8025ff
  800d98:	6a 23                	push   $0x23
  800d9a:	68 1c 26 80 00       	push   $0x80261c
  800d9f:	e8 b5 f3 ff ff       	call   800159 <_panic>

00800da4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da4:	f3 0f 1e fb          	endbr32 
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	57                   	push   %edi
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
  800dae:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbc:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc1:	89 df                	mov    %ebx,%edi
  800dc3:	89 de                	mov    %ebx,%esi
  800dc5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc7:	85 c0                	test   %eax,%eax
  800dc9:	7f 08                	jg     800dd3 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd3:	83 ec 0c             	sub    $0xc,%esp
  800dd6:	50                   	push   %eax
  800dd7:	6a 09                	push   $0x9
  800dd9:	68 ff 25 80 00       	push   $0x8025ff
  800dde:	6a 23                	push   $0x23
  800de0:	68 1c 26 80 00       	push   $0x80261c
  800de5:	e8 6f f3 ff ff       	call   800159 <_panic>

00800dea <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dea:	f3 0f 1e fb          	endbr32 
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
  800df4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800df7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e02:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e07:	89 df                	mov    %ebx,%edi
  800e09:	89 de                	mov    %ebx,%esi
  800e0b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e0d:	85 c0                	test   %eax,%eax
  800e0f:	7f 08                	jg     800e19 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e14:	5b                   	pop    %ebx
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e19:	83 ec 0c             	sub    $0xc,%esp
  800e1c:	50                   	push   %eax
  800e1d:	6a 0a                	push   $0xa
  800e1f:	68 ff 25 80 00       	push   $0x8025ff
  800e24:	6a 23                	push   $0x23
  800e26:	68 1c 26 80 00       	push   $0x80261c
  800e2b:	e8 29 f3 ff ff       	call   800159 <_panic>

00800e30 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e30:	f3 0f 1e fb          	endbr32 
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	57                   	push   %edi
  800e38:	56                   	push   %esi
  800e39:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e40:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e45:	be 00 00 00 00       	mov    $0x0,%esi
  800e4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e4d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e50:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e52:	5b                   	pop    %ebx
  800e53:	5e                   	pop    %esi
  800e54:	5f                   	pop    %edi
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    

00800e57 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e57:	f3 0f 1e fb          	endbr32 
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	57                   	push   %edi
  800e5f:	56                   	push   %esi
  800e60:	53                   	push   %ebx
  800e61:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e64:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e69:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e71:	89 cb                	mov    %ecx,%ebx
  800e73:	89 cf                	mov    %ecx,%edi
  800e75:	89 ce                	mov    %ecx,%esi
  800e77:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	7f 08                	jg     800e85 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e85:	83 ec 0c             	sub    $0xc,%esp
  800e88:	50                   	push   %eax
  800e89:	6a 0d                	push   $0xd
  800e8b:	68 ff 25 80 00       	push   $0x8025ff
  800e90:	6a 23                	push   $0x23
  800e92:	68 1c 26 80 00       	push   $0x80261c
  800e97:	e8 bd f2 ff ff       	call   800159 <_panic>

00800e9c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e9c:	f3 0f 1e fb          	endbr32 
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	53                   	push   %ebx
  800ea4:	83 ec 04             	sub    $0x4,%esp
  800ea7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eaa:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if ( !(err & FEC_WR) ||
  800eac:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800eb0:	74 75                	je     800f27 <pgfault+0x8b>
            !(uvpt[PGNUM(addr)] | PTE_COW) ) {
  800eb2:	89 d8                	mov    %ebx,%eax
  800eb4:	c1 e8 0c             	shr    $0xc,%eax
  800eb7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0) {
  800ebe:	83 ec 04             	sub    $0x4,%esp
  800ec1:	6a 07                	push   $0x7
  800ec3:	68 00 f0 7f 00       	push   $0x7ff000
  800ec8:	6a 00                	push   $0x0
  800eca:	e8 bc fd ff ff       	call   800c8b <sys_page_alloc>
  800ecf:	83 c4 10             	add    $0x10,%esp
  800ed2:	85 c0                	test   %eax,%eax
  800ed4:	78 65                	js     800f3b <pgfault+0x9f>
        panic("sys_page_alloc failed %e\n", r);
    }
    memmove((void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);
  800ed6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800edc:	83 ec 04             	sub    $0x4,%esp
  800edf:	68 00 10 00 00       	push   $0x1000
  800ee4:	53                   	push   %ebx
  800ee5:	68 00 f0 7f 00       	push   $0x7ff000
  800eea:	e8 10 fb ff ff       	call   8009ff <memmove>
    if ((r = sys_page_map(0, (void *)PFTEMP,
  800eef:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ef6:	53                   	push   %ebx
  800ef7:	6a 00                	push   $0x0
  800ef9:	68 00 f0 7f 00       	push   $0x7ff000
  800efe:	6a 00                	push   $0x0
  800f00:	e8 cd fd ff ff       	call   800cd2 <sys_page_map>
  800f05:	83 c4 20             	add    $0x20,%esp
  800f08:	85 c0                	test   %eax,%eax
  800f0a:	78 41                	js     800f4d <pgfault+0xb1>
                0, (void *)PTE_ADDR(addr), PTE_P | PTE_U | PTE_W)) < 0) {
        panic("sys_page_map failed %e\n", r);
    }
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0) {
  800f0c:	83 ec 08             	sub    $0x8,%esp
  800f0f:	68 00 f0 7f 00       	push   $0x7ff000
  800f14:	6a 00                	push   $0x0
  800f16:	e8 fd fd ff ff       	call   800d18 <sys_page_unmap>
  800f1b:	83 c4 10             	add    $0x10,%esp
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	78 3d                	js     800f5f <pgfault+0xc3>
        panic("sys_page_unmap failed %e\n", r);
    }

}
  800f22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f25:	c9                   	leave  
  800f26:	c3                   	ret    
        panic("Not a copy-on-write page");
  800f27:	83 ec 04             	sub    $0x4,%esp
  800f2a:	68 2a 26 80 00       	push   $0x80262a
  800f2f:	6a 1e                	push   $0x1e
  800f31:	68 43 26 80 00       	push   $0x802643
  800f36:	e8 1e f2 ff ff       	call   800159 <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800f3b:	50                   	push   %eax
  800f3c:	68 4e 26 80 00       	push   $0x80264e
  800f41:	6a 2a                	push   $0x2a
  800f43:	68 43 26 80 00       	push   $0x802643
  800f48:	e8 0c f2 ff ff       	call   800159 <_panic>
        panic("sys_page_map failed %e\n", r);
  800f4d:	50                   	push   %eax
  800f4e:	68 68 26 80 00       	push   $0x802668
  800f53:	6a 2f                	push   $0x2f
  800f55:	68 43 26 80 00       	push   $0x802643
  800f5a:	e8 fa f1 ff ff       	call   800159 <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800f5f:	50                   	push   %eax
  800f60:	68 80 26 80 00       	push   $0x802680
  800f65:	6a 32                	push   $0x32
  800f67:	68 43 26 80 00       	push   $0x802643
  800f6c:	e8 e8 f1 ff ff       	call   800159 <_panic>

00800f71 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f71:	f3 0f 1e fb          	endbr32 
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	57                   	push   %edi
  800f79:	56                   	push   %esi
  800f7a:	53                   	push   %ebx
  800f7b:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");

    // 1. set pgfault handler.
    set_pgfault_handler(pgfault);
  800f7e:	68 9c 0e 80 00       	push   $0x800e9c
  800f83:	e8 a5 0e 00 00       	call   801e2d <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f88:	b8 07 00 00 00       	mov    $0x7,%eax
  800f8d:	cd 30                	int    $0x30
  800f8f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f92:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 2. exofork.
    envid_t envid = sys_exofork();

    if (envid < 0)
  800f95:	83 c4 10             	add    $0x10,%esp
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	78 2a                	js     800fc6 <fork+0x55>
        thisenv = &envs[ENVX(my_envid)];
        return 0;
    }
    else {
        // parent
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f9c:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800fa1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800fa5:	75 69                	jne    801010 <fork+0x9f>
        envid_t my_envid = sys_getenvid();
  800fa7:	e8 99 fc ff ff       	call   800c45 <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800fac:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fb1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fb4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fb9:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  800fbe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fc1:	e9 fc 00 00 00       	jmp    8010c2 <fork+0x151>
        panic("fork, sys_exofork %e", envid);
  800fc6:	50                   	push   %eax
  800fc7:	68 9a 26 80 00       	push   $0x80269a
  800fcc:	6a 7b                	push   $0x7b
  800fce:	68 43 26 80 00       	push   $0x802643
  800fd3:	e8 81 f1 ff ff       	call   800159 <_panic>
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  800fd8:	83 ec 0c             	sub    $0xc,%esp
  800fdb:	57                   	push   %edi
  800fdc:	56                   	push   %esi
  800fdd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fe0:	56                   	push   %esi
  800fe1:	6a 00                	push   $0x0
  800fe3:	e8 ea fc ff ff       	call   800cd2 <sys_page_map>
  800fe8:	83 c4 20             	add    $0x20,%esp
  800feb:	85 c0                	test   %eax,%eax
  800fed:	78 69                	js     801058 <fork+0xe7>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  800fef:	83 ec 0c             	sub    $0xc,%esp
  800ff2:	57                   	push   %edi
  800ff3:	56                   	push   %esi
  800ff4:	6a 00                	push   $0x0
  800ff6:	56                   	push   %esi
  800ff7:	6a 00                	push   $0x0
  800ff9:	e8 d4 fc ff ff       	call   800cd2 <sys_page_map>
  800ffe:	83 c4 20             	add    $0x20,%esp
  801001:	85 c0                	test   %eax,%eax
  801003:	78 65                	js     80106a <fork+0xf9>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  801005:	83 c3 01             	add    $0x1,%ebx
  801008:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  80100e:	74 6c                	je     80107c <fork+0x10b>
  801010:	89 de                	mov    %ebx,%esi
  801012:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  801015:	89 f0                	mov    %esi,%eax
  801017:	c1 e8 16             	shr    $0x16,%eax
  80101a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801021:	a8 01                	test   $0x1,%al
  801023:	74 e0                	je     801005 <fork+0x94>
                    (uvpt[pn] & PTE_P) ) {
  801025:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  80102c:	a8 01                	test   $0x1,%al
  80102e:	74 d5                	je     801005 <fork+0x94>
    pte_t pte = uvpt[pn];
  801030:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    int perm = PTE_U | PTE_P;
  801037:	bf 05 00 00 00       	mov    $0x5,%edi
    if ( ((pte & PTE_W) || (pte & PTE_COW)) && !(pte & PTE_SHARE)) {
  80103c:	a9 02 08 00 00       	test   $0x802,%eax
  801041:	74 95                	je     800fd8 <fork+0x67>
  801043:	25 00 04 00 00       	and    $0x400,%eax
        perm |= PTE_COW;
  801048:	83 f8 01             	cmp    $0x1,%eax
  80104b:	19 ff                	sbb    %edi,%edi
  80104d:	81 e7 00 08 00 00    	and    $0x800,%edi
  801053:	83 c7 05             	add    $0x5,%edi
  801056:	eb 80                	jmp    800fd8 <fork+0x67>
        panic("sys_page_map others failed %e\n", r);
  801058:	50                   	push   %eax
  801059:	68 e4 26 80 00       	push   $0x8026e4
  80105e:	6a 51                	push   $0x51
  801060:	68 43 26 80 00       	push   $0x802643
  801065:	e8 ef f0 ff ff       	call   800159 <_panic>
            panic("sys_page_map mine failed %e\n", r);
  80106a:	50                   	push   %eax
  80106b:	68 af 26 80 00       	push   $0x8026af
  801070:	6a 56                	push   $0x56
  801072:	68 43 26 80 00       	push   $0x802643
  801077:	e8 dd f0 ff ff       	call   800159 <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  80107c:	83 ec 04             	sub    $0x4,%esp
  80107f:	6a 07                	push   $0x7
  801081:	68 00 f0 bf ee       	push   $0xeebff000
  801086:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801089:	57                   	push   %edi
  80108a:	e8 fc fb ff ff       	call   800c8b <sys_page_alloc>
  80108f:	83 c4 10             	add    $0x10,%esp
  801092:	85 c0                	test   %eax,%eax
  801094:	78 2c                	js     8010c2 <fork+0x151>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  801096:	a1 08 40 80 00       	mov    0x804008,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  80109b:	8b 40 64             	mov    0x64(%eax),%eax
  80109e:	83 ec 08             	sub    $0x8,%esp
  8010a1:	50                   	push   %eax
  8010a2:	57                   	push   %edi
  8010a3:	e8 42 fd ff ff       	call   800dea <sys_env_set_pgfault_upcall>
  8010a8:	83 c4 10             	add    $0x10,%esp
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	78 13                	js     8010c2 <fork+0x151>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8010af:	83 ec 08             	sub    $0x8,%esp
  8010b2:	6a 02                	push   $0x2
  8010b4:	57                   	push   %edi
  8010b5:	e8 a4 fc ff ff       	call   800d5e <sys_env_set_status>
  8010ba:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	0f 49 c7             	cmovns %edi,%eax
    }

}
  8010c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c5:	5b                   	pop    %ebx
  8010c6:	5e                   	pop    %esi
  8010c7:	5f                   	pop    %edi
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <sfork>:

// Challenge!
int
sfork(void)
{
  8010ca:	f3 0f 1e fb          	endbr32 
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010d4:	68 cc 26 80 00       	push   $0x8026cc
  8010d9:	68 a5 00 00 00       	push   $0xa5
  8010de:	68 43 26 80 00       	push   $0x802643
  8010e3:	e8 71 f0 ff ff       	call   800159 <_panic>

008010e8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010e8:	f3 0f 1e fb          	endbr32 
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f2:	05 00 00 00 30       	add    $0x30000000,%eax
  8010f7:	c1 e8 0c             	shr    $0xc,%eax
}
  8010fa:	5d                   	pop    %ebp
  8010fb:	c3                   	ret    

008010fc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010fc:	f3 0f 1e fb          	endbr32 
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801103:	8b 45 08             	mov    0x8(%ebp),%eax
  801106:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80110b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801110:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801115:	5d                   	pop    %ebp
  801116:	c3                   	ret    

00801117 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801117:	f3 0f 1e fb          	endbr32 
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801123:	89 c2                	mov    %eax,%edx
  801125:	c1 ea 16             	shr    $0x16,%edx
  801128:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80112f:	f6 c2 01             	test   $0x1,%dl
  801132:	74 2d                	je     801161 <fd_alloc+0x4a>
  801134:	89 c2                	mov    %eax,%edx
  801136:	c1 ea 0c             	shr    $0xc,%edx
  801139:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801140:	f6 c2 01             	test   $0x1,%dl
  801143:	74 1c                	je     801161 <fd_alloc+0x4a>
  801145:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80114a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80114f:	75 d2                	jne    801123 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801151:	8b 45 08             	mov    0x8(%ebp),%eax
  801154:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80115a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80115f:	eb 0a                	jmp    80116b <fd_alloc+0x54>
			*fd_store = fd;
  801161:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801164:	89 01                	mov    %eax,(%ecx)
			return 0;
  801166:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80116b:	5d                   	pop    %ebp
  80116c:	c3                   	ret    

0080116d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80116d:	f3 0f 1e fb          	endbr32 
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801177:	83 f8 1f             	cmp    $0x1f,%eax
  80117a:	77 30                	ja     8011ac <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80117c:	c1 e0 0c             	shl    $0xc,%eax
  80117f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801184:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80118a:	f6 c2 01             	test   $0x1,%dl
  80118d:	74 24                	je     8011b3 <fd_lookup+0x46>
  80118f:	89 c2                	mov    %eax,%edx
  801191:	c1 ea 0c             	shr    $0xc,%edx
  801194:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80119b:	f6 c2 01             	test   $0x1,%dl
  80119e:	74 1a                	je     8011ba <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a3:	89 02                	mov    %eax,(%edx)
	return 0;
  8011a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011aa:	5d                   	pop    %ebp
  8011ab:	c3                   	ret    
		return -E_INVAL;
  8011ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b1:	eb f7                	jmp    8011aa <fd_lookup+0x3d>
		return -E_INVAL;
  8011b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b8:	eb f0                	jmp    8011aa <fd_lookup+0x3d>
  8011ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011bf:	eb e9                	jmp    8011aa <fd_lookup+0x3d>

008011c1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011c1:	f3 0f 1e fb          	endbr32 
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
  8011c8:	83 ec 08             	sub    $0x8,%esp
  8011cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ce:	ba 80 27 80 00       	mov    $0x802780,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011d3:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8011d8:	39 08                	cmp    %ecx,(%eax)
  8011da:	74 33                	je     80120f <dev_lookup+0x4e>
  8011dc:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8011df:	8b 02                	mov    (%edx),%eax
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	75 f3                	jne    8011d8 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011e5:	a1 08 40 80 00       	mov    0x804008,%eax
  8011ea:	8b 40 48             	mov    0x48(%eax),%eax
  8011ed:	83 ec 04             	sub    $0x4,%esp
  8011f0:	51                   	push   %ecx
  8011f1:	50                   	push   %eax
  8011f2:	68 04 27 80 00       	push   $0x802704
  8011f7:	e8 44 f0 ff ff       	call   800240 <cprintf>
	*dev = 0;
  8011fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801205:	83 c4 10             	add    $0x10,%esp
  801208:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80120d:	c9                   	leave  
  80120e:	c3                   	ret    
			*dev = devtab[i];
  80120f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801212:	89 01                	mov    %eax,(%ecx)
			return 0;
  801214:	b8 00 00 00 00       	mov    $0x0,%eax
  801219:	eb f2                	jmp    80120d <dev_lookup+0x4c>

0080121b <fd_close>:
{
  80121b:	f3 0f 1e fb          	endbr32 
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	57                   	push   %edi
  801223:	56                   	push   %esi
  801224:	53                   	push   %ebx
  801225:	83 ec 24             	sub    $0x24,%esp
  801228:	8b 75 08             	mov    0x8(%ebp),%esi
  80122b:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80122e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801231:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801232:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801238:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80123b:	50                   	push   %eax
  80123c:	e8 2c ff ff ff       	call   80116d <fd_lookup>
  801241:	89 c3                	mov    %eax,%ebx
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	85 c0                	test   %eax,%eax
  801248:	78 05                	js     80124f <fd_close+0x34>
	    || fd != fd2)
  80124a:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80124d:	74 16                	je     801265 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80124f:	89 f8                	mov    %edi,%eax
  801251:	84 c0                	test   %al,%al
  801253:	b8 00 00 00 00       	mov    $0x0,%eax
  801258:	0f 44 d8             	cmove  %eax,%ebx
}
  80125b:	89 d8                	mov    %ebx,%eax
  80125d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801260:	5b                   	pop    %ebx
  801261:	5e                   	pop    %esi
  801262:	5f                   	pop    %edi
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801265:	83 ec 08             	sub    $0x8,%esp
  801268:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80126b:	50                   	push   %eax
  80126c:	ff 36                	pushl  (%esi)
  80126e:	e8 4e ff ff ff       	call   8011c1 <dev_lookup>
  801273:	89 c3                	mov    %eax,%ebx
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	85 c0                	test   %eax,%eax
  80127a:	78 1a                	js     801296 <fd_close+0x7b>
		if (dev->dev_close)
  80127c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80127f:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801282:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801287:	85 c0                	test   %eax,%eax
  801289:	74 0b                	je     801296 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80128b:	83 ec 0c             	sub    $0xc,%esp
  80128e:	56                   	push   %esi
  80128f:	ff d0                	call   *%eax
  801291:	89 c3                	mov    %eax,%ebx
  801293:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801296:	83 ec 08             	sub    $0x8,%esp
  801299:	56                   	push   %esi
  80129a:	6a 00                	push   $0x0
  80129c:	e8 77 fa ff ff       	call   800d18 <sys_page_unmap>
	return r;
  8012a1:	83 c4 10             	add    $0x10,%esp
  8012a4:	eb b5                	jmp    80125b <fd_close+0x40>

008012a6 <close>:

int
close(int fdnum)
{
  8012a6:	f3 0f 1e fb          	endbr32 
  8012aa:	55                   	push   %ebp
  8012ab:	89 e5                	mov    %esp,%ebp
  8012ad:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b3:	50                   	push   %eax
  8012b4:	ff 75 08             	pushl  0x8(%ebp)
  8012b7:	e8 b1 fe ff ff       	call   80116d <fd_lookup>
  8012bc:	83 c4 10             	add    $0x10,%esp
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	79 02                	jns    8012c5 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8012c3:	c9                   	leave  
  8012c4:	c3                   	ret    
		return fd_close(fd, 1);
  8012c5:	83 ec 08             	sub    $0x8,%esp
  8012c8:	6a 01                	push   $0x1
  8012ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8012cd:	e8 49 ff ff ff       	call   80121b <fd_close>
  8012d2:	83 c4 10             	add    $0x10,%esp
  8012d5:	eb ec                	jmp    8012c3 <close+0x1d>

008012d7 <close_all>:

void
close_all(void)
{
  8012d7:	f3 0f 1e fb          	endbr32 
  8012db:	55                   	push   %ebp
  8012dc:	89 e5                	mov    %esp,%ebp
  8012de:	53                   	push   %ebx
  8012df:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012e2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012e7:	83 ec 0c             	sub    $0xc,%esp
  8012ea:	53                   	push   %ebx
  8012eb:	e8 b6 ff ff ff       	call   8012a6 <close>
	for (i = 0; i < MAXFD; i++)
  8012f0:	83 c3 01             	add    $0x1,%ebx
  8012f3:	83 c4 10             	add    $0x10,%esp
  8012f6:	83 fb 20             	cmp    $0x20,%ebx
  8012f9:	75 ec                	jne    8012e7 <close_all+0x10>
}
  8012fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012fe:	c9                   	leave  
  8012ff:	c3                   	ret    

00801300 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801300:	f3 0f 1e fb          	endbr32 
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	57                   	push   %edi
  801308:	56                   	push   %esi
  801309:	53                   	push   %ebx
  80130a:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80130d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801310:	50                   	push   %eax
  801311:	ff 75 08             	pushl  0x8(%ebp)
  801314:	e8 54 fe ff ff       	call   80116d <fd_lookup>
  801319:	89 c3                	mov    %eax,%ebx
  80131b:	83 c4 10             	add    $0x10,%esp
  80131e:	85 c0                	test   %eax,%eax
  801320:	0f 88 81 00 00 00    	js     8013a7 <dup+0xa7>
		return r;
	close(newfdnum);
  801326:	83 ec 0c             	sub    $0xc,%esp
  801329:	ff 75 0c             	pushl  0xc(%ebp)
  80132c:	e8 75 ff ff ff       	call   8012a6 <close>

	newfd = INDEX2FD(newfdnum);
  801331:	8b 75 0c             	mov    0xc(%ebp),%esi
  801334:	c1 e6 0c             	shl    $0xc,%esi
  801337:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80133d:	83 c4 04             	add    $0x4,%esp
  801340:	ff 75 e4             	pushl  -0x1c(%ebp)
  801343:	e8 b4 fd ff ff       	call   8010fc <fd2data>
  801348:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80134a:	89 34 24             	mov    %esi,(%esp)
  80134d:	e8 aa fd ff ff       	call   8010fc <fd2data>
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801357:	89 d8                	mov    %ebx,%eax
  801359:	c1 e8 16             	shr    $0x16,%eax
  80135c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801363:	a8 01                	test   $0x1,%al
  801365:	74 11                	je     801378 <dup+0x78>
  801367:	89 d8                	mov    %ebx,%eax
  801369:	c1 e8 0c             	shr    $0xc,%eax
  80136c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801373:	f6 c2 01             	test   $0x1,%dl
  801376:	75 39                	jne    8013b1 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801378:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80137b:	89 d0                	mov    %edx,%eax
  80137d:	c1 e8 0c             	shr    $0xc,%eax
  801380:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801387:	83 ec 0c             	sub    $0xc,%esp
  80138a:	25 07 0e 00 00       	and    $0xe07,%eax
  80138f:	50                   	push   %eax
  801390:	56                   	push   %esi
  801391:	6a 00                	push   $0x0
  801393:	52                   	push   %edx
  801394:	6a 00                	push   $0x0
  801396:	e8 37 f9 ff ff       	call   800cd2 <sys_page_map>
  80139b:	89 c3                	mov    %eax,%ebx
  80139d:	83 c4 20             	add    $0x20,%esp
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	78 31                	js     8013d5 <dup+0xd5>
		goto err;

	return newfdnum;
  8013a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013a7:	89 d8                	mov    %ebx,%eax
  8013a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ac:	5b                   	pop    %ebx
  8013ad:	5e                   	pop    %esi
  8013ae:	5f                   	pop    %edi
  8013af:	5d                   	pop    %ebp
  8013b0:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013b1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013b8:	83 ec 0c             	sub    $0xc,%esp
  8013bb:	25 07 0e 00 00       	and    $0xe07,%eax
  8013c0:	50                   	push   %eax
  8013c1:	57                   	push   %edi
  8013c2:	6a 00                	push   $0x0
  8013c4:	53                   	push   %ebx
  8013c5:	6a 00                	push   $0x0
  8013c7:	e8 06 f9 ff ff       	call   800cd2 <sys_page_map>
  8013cc:	89 c3                	mov    %eax,%ebx
  8013ce:	83 c4 20             	add    $0x20,%esp
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	79 a3                	jns    801378 <dup+0x78>
	sys_page_unmap(0, newfd);
  8013d5:	83 ec 08             	sub    $0x8,%esp
  8013d8:	56                   	push   %esi
  8013d9:	6a 00                	push   $0x0
  8013db:	e8 38 f9 ff ff       	call   800d18 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013e0:	83 c4 08             	add    $0x8,%esp
  8013e3:	57                   	push   %edi
  8013e4:	6a 00                	push   $0x0
  8013e6:	e8 2d f9 ff ff       	call   800d18 <sys_page_unmap>
	return r;
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	eb b7                	jmp    8013a7 <dup+0xa7>

008013f0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013f0:	f3 0f 1e fb          	endbr32 
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	53                   	push   %ebx
  8013f8:	83 ec 1c             	sub    $0x1c,%esp
  8013fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801401:	50                   	push   %eax
  801402:	53                   	push   %ebx
  801403:	e8 65 fd ff ff       	call   80116d <fd_lookup>
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	85 c0                	test   %eax,%eax
  80140d:	78 3f                	js     80144e <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80140f:	83 ec 08             	sub    $0x8,%esp
  801412:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801415:	50                   	push   %eax
  801416:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801419:	ff 30                	pushl  (%eax)
  80141b:	e8 a1 fd ff ff       	call   8011c1 <dev_lookup>
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	85 c0                	test   %eax,%eax
  801425:	78 27                	js     80144e <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801427:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80142a:	8b 42 08             	mov    0x8(%edx),%eax
  80142d:	83 e0 03             	and    $0x3,%eax
  801430:	83 f8 01             	cmp    $0x1,%eax
  801433:	74 1e                	je     801453 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801435:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801438:	8b 40 08             	mov    0x8(%eax),%eax
  80143b:	85 c0                	test   %eax,%eax
  80143d:	74 35                	je     801474 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80143f:	83 ec 04             	sub    $0x4,%esp
  801442:	ff 75 10             	pushl  0x10(%ebp)
  801445:	ff 75 0c             	pushl  0xc(%ebp)
  801448:	52                   	push   %edx
  801449:	ff d0                	call   *%eax
  80144b:	83 c4 10             	add    $0x10,%esp
}
  80144e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801451:	c9                   	leave  
  801452:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801453:	a1 08 40 80 00       	mov    0x804008,%eax
  801458:	8b 40 48             	mov    0x48(%eax),%eax
  80145b:	83 ec 04             	sub    $0x4,%esp
  80145e:	53                   	push   %ebx
  80145f:	50                   	push   %eax
  801460:	68 45 27 80 00       	push   $0x802745
  801465:	e8 d6 ed ff ff       	call   800240 <cprintf>
		return -E_INVAL;
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801472:	eb da                	jmp    80144e <read+0x5e>
		return -E_NOT_SUPP;
  801474:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801479:	eb d3                	jmp    80144e <read+0x5e>

0080147b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80147b:	f3 0f 1e fb          	endbr32 
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	57                   	push   %edi
  801483:	56                   	push   %esi
  801484:	53                   	push   %ebx
  801485:	83 ec 0c             	sub    $0xc,%esp
  801488:	8b 7d 08             	mov    0x8(%ebp),%edi
  80148b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80148e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801493:	eb 02                	jmp    801497 <readn+0x1c>
  801495:	01 c3                	add    %eax,%ebx
  801497:	39 f3                	cmp    %esi,%ebx
  801499:	73 21                	jae    8014bc <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80149b:	83 ec 04             	sub    $0x4,%esp
  80149e:	89 f0                	mov    %esi,%eax
  8014a0:	29 d8                	sub    %ebx,%eax
  8014a2:	50                   	push   %eax
  8014a3:	89 d8                	mov    %ebx,%eax
  8014a5:	03 45 0c             	add    0xc(%ebp),%eax
  8014a8:	50                   	push   %eax
  8014a9:	57                   	push   %edi
  8014aa:	e8 41 ff ff ff       	call   8013f0 <read>
		if (m < 0)
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	85 c0                	test   %eax,%eax
  8014b4:	78 04                	js     8014ba <readn+0x3f>
			return m;
		if (m == 0)
  8014b6:	75 dd                	jne    801495 <readn+0x1a>
  8014b8:	eb 02                	jmp    8014bc <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014ba:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8014bc:	89 d8                	mov    %ebx,%eax
  8014be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c1:	5b                   	pop    %ebx
  8014c2:	5e                   	pop    %esi
  8014c3:	5f                   	pop    %edi
  8014c4:	5d                   	pop    %ebp
  8014c5:	c3                   	ret    

008014c6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014c6:	f3 0f 1e fb          	endbr32 
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	53                   	push   %ebx
  8014ce:	83 ec 1c             	sub    $0x1c,%esp
  8014d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d7:	50                   	push   %eax
  8014d8:	53                   	push   %ebx
  8014d9:	e8 8f fc ff ff       	call   80116d <fd_lookup>
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	78 3a                	js     80151f <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e5:	83 ec 08             	sub    $0x8,%esp
  8014e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014eb:	50                   	push   %eax
  8014ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ef:	ff 30                	pushl  (%eax)
  8014f1:	e8 cb fc ff ff       	call   8011c1 <dev_lookup>
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	78 22                	js     80151f <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801500:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801504:	74 1e                	je     801524 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801506:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801509:	8b 52 0c             	mov    0xc(%edx),%edx
  80150c:	85 d2                	test   %edx,%edx
  80150e:	74 35                	je     801545 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801510:	83 ec 04             	sub    $0x4,%esp
  801513:	ff 75 10             	pushl  0x10(%ebp)
  801516:	ff 75 0c             	pushl  0xc(%ebp)
  801519:	50                   	push   %eax
  80151a:	ff d2                	call   *%edx
  80151c:	83 c4 10             	add    $0x10,%esp
}
  80151f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801522:	c9                   	leave  
  801523:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801524:	a1 08 40 80 00       	mov    0x804008,%eax
  801529:	8b 40 48             	mov    0x48(%eax),%eax
  80152c:	83 ec 04             	sub    $0x4,%esp
  80152f:	53                   	push   %ebx
  801530:	50                   	push   %eax
  801531:	68 61 27 80 00       	push   $0x802761
  801536:	e8 05 ed ff ff       	call   800240 <cprintf>
		return -E_INVAL;
  80153b:	83 c4 10             	add    $0x10,%esp
  80153e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801543:	eb da                	jmp    80151f <write+0x59>
		return -E_NOT_SUPP;
  801545:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80154a:	eb d3                	jmp    80151f <write+0x59>

0080154c <seek>:

int
seek(int fdnum, off_t offset)
{
  80154c:	f3 0f 1e fb          	endbr32 
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801556:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801559:	50                   	push   %eax
  80155a:	ff 75 08             	pushl  0x8(%ebp)
  80155d:	e8 0b fc ff ff       	call   80116d <fd_lookup>
  801562:	83 c4 10             	add    $0x10,%esp
  801565:	85 c0                	test   %eax,%eax
  801567:	78 0e                	js     801577 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801569:	8b 55 0c             	mov    0xc(%ebp),%edx
  80156c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80156f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801572:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801577:	c9                   	leave  
  801578:	c3                   	ret    

00801579 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801579:	f3 0f 1e fb          	endbr32 
  80157d:	55                   	push   %ebp
  80157e:	89 e5                	mov    %esp,%ebp
  801580:	53                   	push   %ebx
  801581:	83 ec 1c             	sub    $0x1c,%esp
  801584:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801587:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158a:	50                   	push   %eax
  80158b:	53                   	push   %ebx
  80158c:	e8 dc fb ff ff       	call   80116d <fd_lookup>
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	85 c0                	test   %eax,%eax
  801596:	78 37                	js     8015cf <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801598:	83 ec 08             	sub    $0x8,%esp
  80159b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159e:	50                   	push   %eax
  80159f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a2:	ff 30                	pushl  (%eax)
  8015a4:	e8 18 fc ff ff       	call   8011c1 <dev_lookup>
  8015a9:	83 c4 10             	add    $0x10,%esp
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	78 1f                	js     8015cf <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015b7:	74 1b                	je     8015d4 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8015b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015bc:	8b 52 18             	mov    0x18(%edx),%edx
  8015bf:	85 d2                	test   %edx,%edx
  8015c1:	74 32                	je     8015f5 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015c3:	83 ec 08             	sub    $0x8,%esp
  8015c6:	ff 75 0c             	pushl  0xc(%ebp)
  8015c9:	50                   	push   %eax
  8015ca:	ff d2                	call   *%edx
  8015cc:	83 c4 10             	add    $0x10,%esp
}
  8015cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d2:	c9                   	leave  
  8015d3:	c3                   	ret    
			thisenv->env_id, fdnum);
  8015d4:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015d9:	8b 40 48             	mov    0x48(%eax),%eax
  8015dc:	83 ec 04             	sub    $0x4,%esp
  8015df:	53                   	push   %ebx
  8015e0:	50                   	push   %eax
  8015e1:	68 24 27 80 00       	push   $0x802724
  8015e6:	e8 55 ec ff ff       	call   800240 <cprintf>
		return -E_INVAL;
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015f3:	eb da                	jmp    8015cf <ftruncate+0x56>
		return -E_NOT_SUPP;
  8015f5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015fa:	eb d3                	jmp    8015cf <ftruncate+0x56>

008015fc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015fc:	f3 0f 1e fb          	endbr32 
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	53                   	push   %ebx
  801604:	83 ec 1c             	sub    $0x1c,%esp
  801607:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160d:	50                   	push   %eax
  80160e:	ff 75 08             	pushl  0x8(%ebp)
  801611:	e8 57 fb ff ff       	call   80116d <fd_lookup>
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 4b                	js     801668 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161d:	83 ec 08             	sub    $0x8,%esp
  801620:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801623:	50                   	push   %eax
  801624:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801627:	ff 30                	pushl  (%eax)
  801629:	e8 93 fb ff ff       	call   8011c1 <dev_lookup>
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	85 c0                	test   %eax,%eax
  801633:	78 33                	js     801668 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801635:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801638:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80163c:	74 2f                	je     80166d <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80163e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801641:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801648:	00 00 00 
	stat->st_isdir = 0;
  80164b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801652:	00 00 00 
	stat->st_dev = dev;
  801655:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80165b:	83 ec 08             	sub    $0x8,%esp
  80165e:	53                   	push   %ebx
  80165f:	ff 75 f0             	pushl  -0x10(%ebp)
  801662:	ff 50 14             	call   *0x14(%eax)
  801665:	83 c4 10             	add    $0x10,%esp
}
  801668:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166b:	c9                   	leave  
  80166c:	c3                   	ret    
		return -E_NOT_SUPP;
  80166d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801672:	eb f4                	jmp    801668 <fstat+0x6c>

00801674 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801674:	f3 0f 1e fb          	endbr32 
  801678:	55                   	push   %ebp
  801679:	89 e5                	mov    %esp,%ebp
  80167b:	56                   	push   %esi
  80167c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80167d:	83 ec 08             	sub    $0x8,%esp
  801680:	6a 00                	push   $0x0
  801682:	ff 75 08             	pushl  0x8(%ebp)
  801685:	e8 fb 01 00 00       	call   801885 <open>
  80168a:	89 c3                	mov    %eax,%ebx
  80168c:	83 c4 10             	add    $0x10,%esp
  80168f:	85 c0                	test   %eax,%eax
  801691:	78 1b                	js     8016ae <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801693:	83 ec 08             	sub    $0x8,%esp
  801696:	ff 75 0c             	pushl  0xc(%ebp)
  801699:	50                   	push   %eax
  80169a:	e8 5d ff ff ff       	call   8015fc <fstat>
  80169f:	89 c6                	mov    %eax,%esi
	close(fd);
  8016a1:	89 1c 24             	mov    %ebx,(%esp)
  8016a4:	e8 fd fb ff ff       	call   8012a6 <close>
	return r;
  8016a9:	83 c4 10             	add    $0x10,%esp
  8016ac:	89 f3                	mov    %esi,%ebx
}
  8016ae:	89 d8                	mov    %ebx,%eax
  8016b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b3:	5b                   	pop    %ebx
  8016b4:	5e                   	pop    %esi
  8016b5:	5d                   	pop    %ebp
  8016b6:	c3                   	ret    

008016b7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	56                   	push   %esi
  8016bb:	53                   	push   %ebx
  8016bc:	89 c6                	mov    %eax,%esi
  8016be:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016c0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016c7:	74 27                	je     8016f0 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016c9:	6a 07                	push   $0x7
  8016cb:	68 00 50 80 00       	push   $0x805000
  8016d0:	56                   	push   %esi
  8016d1:	ff 35 00 40 80 00    	pushl  0x804000
  8016d7:	e8 4e 08 00 00       	call   801f2a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016dc:	83 c4 0c             	add    $0xc,%esp
  8016df:	6a 00                	push   $0x0
  8016e1:	53                   	push   %ebx
  8016e2:	6a 00                	push   $0x0
  8016e4:	e8 ea 07 00 00       	call   801ed3 <ipc_recv>
}
  8016e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ec:	5b                   	pop    %ebx
  8016ed:	5e                   	pop    %esi
  8016ee:	5d                   	pop    %ebp
  8016ef:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016f0:	83 ec 0c             	sub    $0xc,%esp
  8016f3:	6a 01                	push   $0x1
  8016f5:	e8 96 08 00 00       	call   801f90 <ipc_find_env>
  8016fa:	a3 00 40 80 00       	mov    %eax,0x804000
  8016ff:	83 c4 10             	add    $0x10,%esp
  801702:	eb c5                	jmp    8016c9 <fsipc+0x12>

00801704 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801704:	f3 0f 1e fb          	endbr32 
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80170e:	8b 45 08             	mov    0x8(%ebp),%eax
  801711:	8b 40 0c             	mov    0xc(%eax),%eax
  801714:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801719:	8b 45 0c             	mov    0xc(%ebp),%eax
  80171c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801721:	ba 00 00 00 00       	mov    $0x0,%edx
  801726:	b8 02 00 00 00       	mov    $0x2,%eax
  80172b:	e8 87 ff ff ff       	call   8016b7 <fsipc>
}
  801730:	c9                   	leave  
  801731:	c3                   	ret    

00801732 <devfile_flush>:
{
  801732:	f3 0f 1e fb          	endbr32 
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80173c:	8b 45 08             	mov    0x8(%ebp),%eax
  80173f:	8b 40 0c             	mov    0xc(%eax),%eax
  801742:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801747:	ba 00 00 00 00       	mov    $0x0,%edx
  80174c:	b8 06 00 00 00       	mov    $0x6,%eax
  801751:	e8 61 ff ff ff       	call   8016b7 <fsipc>
}
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <devfile_stat>:
{
  801758:	f3 0f 1e fb          	endbr32 
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	53                   	push   %ebx
  801760:	83 ec 04             	sub    $0x4,%esp
  801763:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801766:	8b 45 08             	mov    0x8(%ebp),%eax
  801769:	8b 40 0c             	mov    0xc(%eax),%eax
  80176c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801771:	ba 00 00 00 00       	mov    $0x0,%edx
  801776:	b8 05 00 00 00       	mov    $0x5,%eax
  80177b:	e8 37 ff ff ff       	call   8016b7 <fsipc>
  801780:	85 c0                	test   %eax,%eax
  801782:	78 2c                	js     8017b0 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801784:	83 ec 08             	sub    $0x8,%esp
  801787:	68 00 50 80 00       	push   $0x805000
  80178c:	53                   	push   %ebx
  80178d:	e8 b7 f0 ff ff       	call   800849 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801792:	a1 80 50 80 00       	mov    0x805080,%eax
  801797:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80179d:	a1 84 50 80 00       	mov    0x805084,%eax
  8017a2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017a8:	83 c4 10             	add    $0x10,%esp
  8017ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b3:	c9                   	leave  
  8017b4:	c3                   	ret    

008017b5 <devfile_write>:
{
  8017b5:	f3 0f 1e fb          	endbr32 
  8017b9:	55                   	push   %ebp
  8017ba:	89 e5                	mov    %esp,%ebp
  8017bc:	83 ec 0c             	sub    $0xc,%esp
  8017bf:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  8017c2:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017c7:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017cc:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8017d2:	8b 52 0c             	mov    0xc(%edx),%edx
  8017d5:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017db:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017e0:	50                   	push   %eax
  8017e1:	ff 75 0c             	pushl  0xc(%ebp)
  8017e4:	68 08 50 80 00       	push   $0x805008
  8017e9:	e8 11 f2 ff ff       	call   8009ff <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f3:	b8 04 00 00 00       	mov    $0x4,%eax
  8017f8:	e8 ba fe ff ff       	call   8016b7 <fsipc>
}
  8017fd:	c9                   	leave  
  8017fe:	c3                   	ret    

008017ff <devfile_read>:
{
  8017ff:	f3 0f 1e fb          	endbr32 
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	56                   	push   %esi
  801807:	53                   	push   %ebx
  801808:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80180b:	8b 45 08             	mov    0x8(%ebp),%eax
  80180e:	8b 40 0c             	mov    0xc(%eax),%eax
  801811:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801816:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80181c:	ba 00 00 00 00       	mov    $0x0,%edx
  801821:	b8 03 00 00 00       	mov    $0x3,%eax
  801826:	e8 8c fe ff ff       	call   8016b7 <fsipc>
  80182b:	89 c3                	mov    %eax,%ebx
  80182d:	85 c0                	test   %eax,%eax
  80182f:	78 1f                	js     801850 <devfile_read+0x51>
	assert(r <= n);
  801831:	39 f0                	cmp    %esi,%eax
  801833:	77 24                	ja     801859 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801835:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80183a:	7f 33                	jg     80186f <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80183c:	83 ec 04             	sub    $0x4,%esp
  80183f:	50                   	push   %eax
  801840:	68 00 50 80 00       	push   $0x805000
  801845:	ff 75 0c             	pushl  0xc(%ebp)
  801848:	e8 b2 f1 ff ff       	call   8009ff <memmove>
	return r;
  80184d:	83 c4 10             	add    $0x10,%esp
}
  801850:	89 d8                	mov    %ebx,%eax
  801852:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801855:	5b                   	pop    %ebx
  801856:	5e                   	pop    %esi
  801857:	5d                   	pop    %ebp
  801858:	c3                   	ret    
	assert(r <= n);
  801859:	68 90 27 80 00       	push   $0x802790
  80185e:	68 97 27 80 00       	push   $0x802797
  801863:	6a 7c                	push   $0x7c
  801865:	68 ac 27 80 00       	push   $0x8027ac
  80186a:	e8 ea e8 ff ff       	call   800159 <_panic>
	assert(r <= PGSIZE);
  80186f:	68 b7 27 80 00       	push   $0x8027b7
  801874:	68 97 27 80 00       	push   $0x802797
  801879:	6a 7d                	push   $0x7d
  80187b:	68 ac 27 80 00       	push   $0x8027ac
  801880:	e8 d4 e8 ff ff       	call   800159 <_panic>

00801885 <open>:
{
  801885:	f3 0f 1e fb          	endbr32 
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
  80188c:	56                   	push   %esi
  80188d:	53                   	push   %ebx
  80188e:	83 ec 1c             	sub    $0x1c,%esp
  801891:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801894:	56                   	push   %esi
  801895:	e8 6c ef ff ff       	call   800806 <strlen>
  80189a:	83 c4 10             	add    $0x10,%esp
  80189d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018a2:	7f 6c                	jg     801910 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8018a4:	83 ec 0c             	sub    $0xc,%esp
  8018a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018aa:	50                   	push   %eax
  8018ab:	e8 67 f8 ff ff       	call   801117 <fd_alloc>
  8018b0:	89 c3                	mov    %eax,%ebx
  8018b2:	83 c4 10             	add    $0x10,%esp
  8018b5:	85 c0                	test   %eax,%eax
  8018b7:	78 3c                	js     8018f5 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8018b9:	83 ec 08             	sub    $0x8,%esp
  8018bc:	56                   	push   %esi
  8018bd:	68 00 50 80 00       	push   $0x805000
  8018c2:	e8 82 ef ff ff       	call   800849 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ca:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8018d7:	e8 db fd ff ff       	call   8016b7 <fsipc>
  8018dc:	89 c3                	mov    %eax,%ebx
  8018de:	83 c4 10             	add    $0x10,%esp
  8018e1:	85 c0                	test   %eax,%eax
  8018e3:	78 19                	js     8018fe <open+0x79>
	return fd2num(fd);
  8018e5:	83 ec 0c             	sub    $0xc,%esp
  8018e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018eb:	e8 f8 f7 ff ff       	call   8010e8 <fd2num>
  8018f0:	89 c3                	mov    %eax,%ebx
  8018f2:	83 c4 10             	add    $0x10,%esp
}
  8018f5:	89 d8                	mov    %ebx,%eax
  8018f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fa:	5b                   	pop    %ebx
  8018fb:	5e                   	pop    %esi
  8018fc:	5d                   	pop    %ebp
  8018fd:	c3                   	ret    
		fd_close(fd, 0);
  8018fe:	83 ec 08             	sub    $0x8,%esp
  801901:	6a 00                	push   $0x0
  801903:	ff 75 f4             	pushl  -0xc(%ebp)
  801906:	e8 10 f9 ff ff       	call   80121b <fd_close>
		return r;
  80190b:	83 c4 10             	add    $0x10,%esp
  80190e:	eb e5                	jmp    8018f5 <open+0x70>
		return -E_BAD_PATH;
  801910:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801915:	eb de                	jmp    8018f5 <open+0x70>

00801917 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801917:	f3 0f 1e fb          	endbr32 
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
  80191e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801921:	ba 00 00 00 00       	mov    $0x0,%edx
  801926:	b8 08 00 00 00       	mov    $0x8,%eax
  80192b:	e8 87 fd ff ff       	call   8016b7 <fsipc>
}
  801930:	c9                   	leave  
  801931:	c3                   	ret    

00801932 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801932:	f3 0f 1e fb          	endbr32 
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	56                   	push   %esi
  80193a:	53                   	push   %ebx
  80193b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80193e:	83 ec 0c             	sub    $0xc,%esp
  801941:	ff 75 08             	pushl  0x8(%ebp)
  801944:	e8 b3 f7 ff ff       	call   8010fc <fd2data>
  801949:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80194b:	83 c4 08             	add    $0x8,%esp
  80194e:	68 c3 27 80 00       	push   $0x8027c3
  801953:	53                   	push   %ebx
  801954:	e8 f0 ee ff ff       	call   800849 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801959:	8b 46 04             	mov    0x4(%esi),%eax
  80195c:	2b 06                	sub    (%esi),%eax
  80195e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801964:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80196b:	00 00 00 
	stat->st_dev = &devpipe;
  80196e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801975:	30 80 00 
	return 0;
}
  801978:	b8 00 00 00 00       	mov    $0x0,%eax
  80197d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801980:	5b                   	pop    %ebx
  801981:	5e                   	pop    %esi
  801982:	5d                   	pop    %ebp
  801983:	c3                   	ret    

00801984 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801984:	f3 0f 1e fb          	endbr32 
  801988:	55                   	push   %ebp
  801989:	89 e5                	mov    %esp,%ebp
  80198b:	53                   	push   %ebx
  80198c:	83 ec 0c             	sub    $0xc,%esp
  80198f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801992:	53                   	push   %ebx
  801993:	6a 00                	push   $0x0
  801995:	e8 7e f3 ff ff       	call   800d18 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80199a:	89 1c 24             	mov    %ebx,(%esp)
  80199d:	e8 5a f7 ff ff       	call   8010fc <fd2data>
  8019a2:	83 c4 08             	add    $0x8,%esp
  8019a5:	50                   	push   %eax
  8019a6:	6a 00                	push   $0x0
  8019a8:	e8 6b f3 ff ff       	call   800d18 <sys_page_unmap>
}
  8019ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b0:	c9                   	leave  
  8019b1:	c3                   	ret    

008019b2 <_pipeisclosed>:
{
  8019b2:	55                   	push   %ebp
  8019b3:	89 e5                	mov    %esp,%ebp
  8019b5:	57                   	push   %edi
  8019b6:	56                   	push   %esi
  8019b7:	53                   	push   %ebx
  8019b8:	83 ec 1c             	sub    $0x1c,%esp
  8019bb:	89 c7                	mov    %eax,%edi
  8019bd:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8019bf:	a1 08 40 80 00       	mov    0x804008,%eax
  8019c4:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019c7:	83 ec 0c             	sub    $0xc,%esp
  8019ca:	57                   	push   %edi
  8019cb:	e8 fd 05 00 00       	call   801fcd <pageref>
  8019d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8019d3:	89 34 24             	mov    %esi,(%esp)
  8019d6:	e8 f2 05 00 00       	call   801fcd <pageref>
		nn = thisenv->env_runs;
  8019db:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8019e1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019e4:	83 c4 10             	add    $0x10,%esp
  8019e7:	39 cb                	cmp    %ecx,%ebx
  8019e9:	74 1b                	je     801a06 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8019eb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8019ee:	75 cf                	jne    8019bf <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019f0:	8b 42 58             	mov    0x58(%edx),%eax
  8019f3:	6a 01                	push   $0x1
  8019f5:	50                   	push   %eax
  8019f6:	53                   	push   %ebx
  8019f7:	68 ca 27 80 00       	push   $0x8027ca
  8019fc:	e8 3f e8 ff ff       	call   800240 <cprintf>
  801a01:	83 c4 10             	add    $0x10,%esp
  801a04:	eb b9                	jmp    8019bf <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801a06:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a09:	0f 94 c0             	sete   %al
  801a0c:	0f b6 c0             	movzbl %al,%eax
}
  801a0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a12:	5b                   	pop    %ebx
  801a13:	5e                   	pop    %esi
  801a14:	5f                   	pop    %edi
  801a15:	5d                   	pop    %ebp
  801a16:	c3                   	ret    

00801a17 <devpipe_write>:
{
  801a17:	f3 0f 1e fb          	endbr32 
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	57                   	push   %edi
  801a1f:	56                   	push   %esi
  801a20:	53                   	push   %ebx
  801a21:	83 ec 28             	sub    $0x28,%esp
  801a24:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801a27:	56                   	push   %esi
  801a28:	e8 cf f6 ff ff       	call   8010fc <fd2data>
  801a2d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a2f:	83 c4 10             	add    $0x10,%esp
  801a32:	bf 00 00 00 00       	mov    $0x0,%edi
  801a37:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a3a:	74 4f                	je     801a8b <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a3c:	8b 43 04             	mov    0x4(%ebx),%eax
  801a3f:	8b 0b                	mov    (%ebx),%ecx
  801a41:	8d 51 20             	lea    0x20(%ecx),%edx
  801a44:	39 d0                	cmp    %edx,%eax
  801a46:	72 14                	jb     801a5c <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801a48:	89 da                	mov    %ebx,%edx
  801a4a:	89 f0                	mov    %esi,%eax
  801a4c:	e8 61 ff ff ff       	call   8019b2 <_pipeisclosed>
  801a51:	85 c0                	test   %eax,%eax
  801a53:	75 3b                	jne    801a90 <devpipe_write+0x79>
			sys_yield();
  801a55:	e8 0e f2 ff ff       	call   800c68 <sys_yield>
  801a5a:	eb e0                	jmp    801a3c <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a5f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a63:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a66:	89 c2                	mov    %eax,%edx
  801a68:	c1 fa 1f             	sar    $0x1f,%edx
  801a6b:	89 d1                	mov    %edx,%ecx
  801a6d:	c1 e9 1b             	shr    $0x1b,%ecx
  801a70:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a73:	83 e2 1f             	and    $0x1f,%edx
  801a76:	29 ca                	sub    %ecx,%edx
  801a78:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a7c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a80:	83 c0 01             	add    $0x1,%eax
  801a83:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801a86:	83 c7 01             	add    $0x1,%edi
  801a89:	eb ac                	jmp    801a37 <devpipe_write+0x20>
	return i;
  801a8b:	8b 45 10             	mov    0x10(%ebp),%eax
  801a8e:	eb 05                	jmp    801a95 <devpipe_write+0x7e>
				return 0;
  801a90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a98:	5b                   	pop    %ebx
  801a99:	5e                   	pop    %esi
  801a9a:	5f                   	pop    %edi
  801a9b:	5d                   	pop    %ebp
  801a9c:	c3                   	ret    

00801a9d <devpipe_read>:
{
  801a9d:	f3 0f 1e fb          	endbr32 
  801aa1:	55                   	push   %ebp
  801aa2:	89 e5                	mov    %esp,%ebp
  801aa4:	57                   	push   %edi
  801aa5:	56                   	push   %esi
  801aa6:	53                   	push   %ebx
  801aa7:	83 ec 18             	sub    $0x18,%esp
  801aaa:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801aad:	57                   	push   %edi
  801aae:	e8 49 f6 ff ff       	call   8010fc <fd2data>
  801ab3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ab5:	83 c4 10             	add    $0x10,%esp
  801ab8:	be 00 00 00 00       	mov    $0x0,%esi
  801abd:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ac0:	75 14                	jne    801ad6 <devpipe_read+0x39>
	return i;
  801ac2:	8b 45 10             	mov    0x10(%ebp),%eax
  801ac5:	eb 02                	jmp    801ac9 <devpipe_read+0x2c>
				return i;
  801ac7:	89 f0                	mov    %esi,%eax
}
  801ac9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801acc:	5b                   	pop    %ebx
  801acd:	5e                   	pop    %esi
  801ace:	5f                   	pop    %edi
  801acf:	5d                   	pop    %ebp
  801ad0:	c3                   	ret    
			sys_yield();
  801ad1:	e8 92 f1 ff ff       	call   800c68 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801ad6:	8b 03                	mov    (%ebx),%eax
  801ad8:	3b 43 04             	cmp    0x4(%ebx),%eax
  801adb:	75 18                	jne    801af5 <devpipe_read+0x58>
			if (i > 0)
  801add:	85 f6                	test   %esi,%esi
  801adf:	75 e6                	jne    801ac7 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801ae1:	89 da                	mov    %ebx,%edx
  801ae3:	89 f8                	mov    %edi,%eax
  801ae5:	e8 c8 fe ff ff       	call   8019b2 <_pipeisclosed>
  801aea:	85 c0                	test   %eax,%eax
  801aec:	74 e3                	je     801ad1 <devpipe_read+0x34>
				return 0;
  801aee:	b8 00 00 00 00       	mov    $0x0,%eax
  801af3:	eb d4                	jmp    801ac9 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801af5:	99                   	cltd   
  801af6:	c1 ea 1b             	shr    $0x1b,%edx
  801af9:	01 d0                	add    %edx,%eax
  801afb:	83 e0 1f             	and    $0x1f,%eax
  801afe:	29 d0                	sub    %edx,%eax
  801b00:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b08:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b0b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b0e:	83 c6 01             	add    $0x1,%esi
  801b11:	eb aa                	jmp    801abd <devpipe_read+0x20>

00801b13 <pipe>:
{
  801b13:	f3 0f 1e fb          	endbr32 
  801b17:	55                   	push   %ebp
  801b18:	89 e5                	mov    %esp,%ebp
  801b1a:	56                   	push   %esi
  801b1b:	53                   	push   %ebx
  801b1c:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801b1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b22:	50                   	push   %eax
  801b23:	e8 ef f5 ff ff       	call   801117 <fd_alloc>
  801b28:	89 c3                	mov    %eax,%ebx
  801b2a:	83 c4 10             	add    $0x10,%esp
  801b2d:	85 c0                	test   %eax,%eax
  801b2f:	0f 88 23 01 00 00    	js     801c58 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b35:	83 ec 04             	sub    $0x4,%esp
  801b38:	68 07 04 00 00       	push   $0x407
  801b3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b40:	6a 00                	push   $0x0
  801b42:	e8 44 f1 ff ff       	call   800c8b <sys_page_alloc>
  801b47:	89 c3                	mov    %eax,%ebx
  801b49:	83 c4 10             	add    $0x10,%esp
  801b4c:	85 c0                	test   %eax,%eax
  801b4e:	0f 88 04 01 00 00    	js     801c58 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801b54:	83 ec 0c             	sub    $0xc,%esp
  801b57:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b5a:	50                   	push   %eax
  801b5b:	e8 b7 f5 ff ff       	call   801117 <fd_alloc>
  801b60:	89 c3                	mov    %eax,%ebx
  801b62:	83 c4 10             	add    $0x10,%esp
  801b65:	85 c0                	test   %eax,%eax
  801b67:	0f 88 db 00 00 00    	js     801c48 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b6d:	83 ec 04             	sub    $0x4,%esp
  801b70:	68 07 04 00 00       	push   $0x407
  801b75:	ff 75 f0             	pushl  -0x10(%ebp)
  801b78:	6a 00                	push   $0x0
  801b7a:	e8 0c f1 ff ff       	call   800c8b <sys_page_alloc>
  801b7f:	89 c3                	mov    %eax,%ebx
  801b81:	83 c4 10             	add    $0x10,%esp
  801b84:	85 c0                	test   %eax,%eax
  801b86:	0f 88 bc 00 00 00    	js     801c48 <pipe+0x135>
	va = fd2data(fd0);
  801b8c:	83 ec 0c             	sub    $0xc,%esp
  801b8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b92:	e8 65 f5 ff ff       	call   8010fc <fd2data>
  801b97:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b99:	83 c4 0c             	add    $0xc,%esp
  801b9c:	68 07 04 00 00       	push   $0x407
  801ba1:	50                   	push   %eax
  801ba2:	6a 00                	push   $0x0
  801ba4:	e8 e2 f0 ff ff       	call   800c8b <sys_page_alloc>
  801ba9:	89 c3                	mov    %eax,%ebx
  801bab:	83 c4 10             	add    $0x10,%esp
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	0f 88 82 00 00 00    	js     801c38 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb6:	83 ec 0c             	sub    $0xc,%esp
  801bb9:	ff 75 f0             	pushl  -0x10(%ebp)
  801bbc:	e8 3b f5 ff ff       	call   8010fc <fd2data>
  801bc1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bc8:	50                   	push   %eax
  801bc9:	6a 00                	push   $0x0
  801bcb:	56                   	push   %esi
  801bcc:	6a 00                	push   $0x0
  801bce:	e8 ff f0 ff ff       	call   800cd2 <sys_page_map>
  801bd3:	89 c3                	mov    %eax,%ebx
  801bd5:	83 c4 20             	add    $0x20,%esp
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	78 4e                	js     801c2a <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801bdc:	a1 20 30 80 00       	mov    0x803020,%eax
  801be1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801be4:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801be6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801be9:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801bf0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bf3:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801bf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bf8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801bff:	83 ec 0c             	sub    $0xc,%esp
  801c02:	ff 75 f4             	pushl  -0xc(%ebp)
  801c05:	e8 de f4 ff ff       	call   8010e8 <fd2num>
  801c0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c0d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c0f:	83 c4 04             	add    $0x4,%esp
  801c12:	ff 75 f0             	pushl  -0x10(%ebp)
  801c15:	e8 ce f4 ff ff       	call   8010e8 <fd2num>
  801c1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c1d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c20:	83 c4 10             	add    $0x10,%esp
  801c23:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c28:	eb 2e                	jmp    801c58 <pipe+0x145>
	sys_page_unmap(0, va);
  801c2a:	83 ec 08             	sub    $0x8,%esp
  801c2d:	56                   	push   %esi
  801c2e:	6a 00                	push   $0x0
  801c30:	e8 e3 f0 ff ff       	call   800d18 <sys_page_unmap>
  801c35:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801c38:	83 ec 08             	sub    $0x8,%esp
  801c3b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c3e:	6a 00                	push   $0x0
  801c40:	e8 d3 f0 ff ff       	call   800d18 <sys_page_unmap>
  801c45:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801c48:	83 ec 08             	sub    $0x8,%esp
  801c4b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4e:	6a 00                	push   $0x0
  801c50:	e8 c3 f0 ff ff       	call   800d18 <sys_page_unmap>
  801c55:	83 c4 10             	add    $0x10,%esp
}
  801c58:	89 d8                	mov    %ebx,%eax
  801c5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5d                   	pop    %ebp
  801c60:	c3                   	ret    

00801c61 <pipeisclosed>:
{
  801c61:	f3 0f 1e fb          	endbr32 
  801c65:	55                   	push   %ebp
  801c66:	89 e5                	mov    %esp,%ebp
  801c68:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c6e:	50                   	push   %eax
  801c6f:	ff 75 08             	pushl  0x8(%ebp)
  801c72:	e8 f6 f4 ff ff       	call   80116d <fd_lookup>
  801c77:	83 c4 10             	add    $0x10,%esp
  801c7a:	85 c0                	test   %eax,%eax
  801c7c:	78 18                	js     801c96 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801c7e:	83 ec 0c             	sub    $0xc,%esp
  801c81:	ff 75 f4             	pushl  -0xc(%ebp)
  801c84:	e8 73 f4 ff ff       	call   8010fc <fd2data>
  801c89:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8e:	e8 1f fd ff ff       	call   8019b2 <_pipeisclosed>
  801c93:	83 c4 10             	add    $0x10,%esp
}
  801c96:	c9                   	leave  
  801c97:	c3                   	ret    

00801c98 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c98:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801c9c:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca1:	c3                   	ret    

00801ca2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ca2:	f3 0f 1e fb          	endbr32 
  801ca6:	55                   	push   %ebp
  801ca7:	89 e5                	mov    %esp,%ebp
  801ca9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cac:	68 e2 27 80 00       	push   $0x8027e2
  801cb1:	ff 75 0c             	pushl  0xc(%ebp)
  801cb4:	e8 90 eb ff ff       	call   800849 <strcpy>
	return 0;
}
  801cb9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cbe:	c9                   	leave  
  801cbf:	c3                   	ret    

00801cc0 <devcons_write>:
{
  801cc0:	f3 0f 1e fb          	endbr32 
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
  801cc7:	57                   	push   %edi
  801cc8:	56                   	push   %esi
  801cc9:	53                   	push   %ebx
  801cca:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801cd0:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801cd5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801cdb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cde:	73 31                	jae    801d11 <devcons_write+0x51>
		m = n - tot;
  801ce0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ce3:	29 f3                	sub    %esi,%ebx
  801ce5:	83 fb 7f             	cmp    $0x7f,%ebx
  801ce8:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801ced:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801cf0:	83 ec 04             	sub    $0x4,%esp
  801cf3:	53                   	push   %ebx
  801cf4:	89 f0                	mov    %esi,%eax
  801cf6:	03 45 0c             	add    0xc(%ebp),%eax
  801cf9:	50                   	push   %eax
  801cfa:	57                   	push   %edi
  801cfb:	e8 ff ec ff ff       	call   8009ff <memmove>
		sys_cputs(buf, m);
  801d00:	83 c4 08             	add    $0x8,%esp
  801d03:	53                   	push   %ebx
  801d04:	57                   	push   %edi
  801d05:	e8 b1 ee ff ff       	call   800bbb <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801d0a:	01 de                	add    %ebx,%esi
  801d0c:	83 c4 10             	add    $0x10,%esp
  801d0f:	eb ca                	jmp    801cdb <devcons_write+0x1b>
}
  801d11:	89 f0                	mov    %esi,%eax
  801d13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d16:	5b                   	pop    %ebx
  801d17:	5e                   	pop    %esi
  801d18:	5f                   	pop    %edi
  801d19:	5d                   	pop    %ebp
  801d1a:	c3                   	ret    

00801d1b <devcons_read>:
{
  801d1b:	f3 0f 1e fb          	endbr32 
  801d1f:	55                   	push   %ebp
  801d20:	89 e5                	mov    %esp,%ebp
  801d22:	83 ec 08             	sub    $0x8,%esp
  801d25:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801d2a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d2e:	74 21                	je     801d51 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801d30:	e8 a8 ee ff ff       	call   800bdd <sys_cgetc>
  801d35:	85 c0                	test   %eax,%eax
  801d37:	75 07                	jne    801d40 <devcons_read+0x25>
		sys_yield();
  801d39:	e8 2a ef ff ff       	call   800c68 <sys_yield>
  801d3e:	eb f0                	jmp    801d30 <devcons_read+0x15>
	if (c < 0)
  801d40:	78 0f                	js     801d51 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801d42:	83 f8 04             	cmp    $0x4,%eax
  801d45:	74 0c                	je     801d53 <devcons_read+0x38>
	*(char*)vbuf = c;
  801d47:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d4a:	88 02                	mov    %al,(%edx)
	return 1;
  801d4c:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801d51:	c9                   	leave  
  801d52:	c3                   	ret    
		return 0;
  801d53:	b8 00 00 00 00       	mov    $0x0,%eax
  801d58:	eb f7                	jmp    801d51 <devcons_read+0x36>

00801d5a <cputchar>:
{
  801d5a:	f3 0f 1e fb          	endbr32 
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d64:	8b 45 08             	mov    0x8(%ebp),%eax
  801d67:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801d6a:	6a 01                	push   $0x1
  801d6c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d6f:	50                   	push   %eax
  801d70:	e8 46 ee ff ff       	call   800bbb <sys_cputs>
}
  801d75:	83 c4 10             	add    $0x10,%esp
  801d78:	c9                   	leave  
  801d79:	c3                   	ret    

00801d7a <getchar>:
{
  801d7a:	f3 0f 1e fb          	endbr32 
  801d7e:	55                   	push   %ebp
  801d7f:	89 e5                	mov    %esp,%ebp
  801d81:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801d84:	6a 01                	push   $0x1
  801d86:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d89:	50                   	push   %eax
  801d8a:	6a 00                	push   $0x0
  801d8c:	e8 5f f6 ff ff       	call   8013f0 <read>
	if (r < 0)
  801d91:	83 c4 10             	add    $0x10,%esp
  801d94:	85 c0                	test   %eax,%eax
  801d96:	78 06                	js     801d9e <getchar+0x24>
	if (r < 1)
  801d98:	74 06                	je     801da0 <getchar+0x26>
	return c;
  801d9a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801d9e:	c9                   	leave  
  801d9f:	c3                   	ret    
		return -E_EOF;
  801da0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801da5:	eb f7                	jmp    801d9e <getchar+0x24>

00801da7 <iscons>:
{
  801da7:	f3 0f 1e fb          	endbr32 
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801db1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db4:	50                   	push   %eax
  801db5:	ff 75 08             	pushl  0x8(%ebp)
  801db8:	e8 b0 f3 ff ff       	call   80116d <fd_lookup>
  801dbd:	83 c4 10             	add    $0x10,%esp
  801dc0:	85 c0                	test   %eax,%eax
  801dc2:	78 11                	js     801dd5 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dcd:	39 10                	cmp    %edx,(%eax)
  801dcf:	0f 94 c0             	sete   %al
  801dd2:	0f b6 c0             	movzbl %al,%eax
}
  801dd5:	c9                   	leave  
  801dd6:	c3                   	ret    

00801dd7 <opencons>:
{
  801dd7:	f3 0f 1e fb          	endbr32 
  801ddb:	55                   	push   %ebp
  801ddc:	89 e5                	mov    %esp,%ebp
  801dde:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801de1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de4:	50                   	push   %eax
  801de5:	e8 2d f3 ff ff       	call   801117 <fd_alloc>
  801dea:	83 c4 10             	add    $0x10,%esp
  801ded:	85 c0                	test   %eax,%eax
  801def:	78 3a                	js     801e2b <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801df1:	83 ec 04             	sub    $0x4,%esp
  801df4:	68 07 04 00 00       	push   $0x407
  801df9:	ff 75 f4             	pushl  -0xc(%ebp)
  801dfc:	6a 00                	push   $0x0
  801dfe:	e8 88 ee ff ff       	call   800c8b <sys_page_alloc>
  801e03:	83 c4 10             	add    $0x10,%esp
  801e06:	85 c0                	test   %eax,%eax
  801e08:	78 21                	js     801e2b <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e13:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e18:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e1f:	83 ec 0c             	sub    $0xc,%esp
  801e22:	50                   	push   %eax
  801e23:	e8 c0 f2 ff ff       	call   8010e8 <fd2num>
  801e28:	83 c4 10             	add    $0x10,%esp
}
  801e2b:	c9                   	leave  
  801e2c:	c3                   	ret    

00801e2d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e2d:	f3 0f 1e fb          	endbr32 
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e37:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e3e:	74 0a                	je     801e4a <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e40:	8b 45 08             	mov    0x8(%ebp),%eax
  801e43:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e48:	c9                   	leave  
  801e49:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801e4a:	83 ec 0c             	sub    $0xc,%esp
  801e4d:	68 ee 27 80 00       	push   $0x8027ee
  801e52:	e8 e9 e3 ff ff       	call   800240 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  801e57:	83 c4 0c             	add    $0xc,%esp
  801e5a:	6a 07                	push   $0x7
  801e5c:	68 00 f0 bf ee       	push   $0xeebff000
  801e61:	6a 00                	push   $0x0
  801e63:	e8 23 ee ff ff       	call   800c8b <sys_page_alloc>
  801e68:	83 c4 10             	add    $0x10,%esp
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	78 2a                	js     801e99 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801e6f:	83 ec 08             	sub    $0x8,%esp
  801e72:	68 ad 1e 80 00       	push   $0x801ead
  801e77:	6a 00                	push   $0x0
  801e79:	e8 6c ef ff ff       	call   800dea <sys_env_set_pgfault_upcall>
  801e7e:	83 c4 10             	add    $0x10,%esp
  801e81:	85 c0                	test   %eax,%eax
  801e83:	79 bb                	jns    801e40 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  801e85:	83 ec 04             	sub    $0x4,%esp
  801e88:	68 2c 28 80 00       	push   $0x80282c
  801e8d:	6a 25                	push   $0x25
  801e8f:	68 1b 28 80 00       	push   $0x80281b
  801e94:	e8 c0 e2 ff ff       	call   800159 <_panic>
            panic("Allocation of UXSTACK failed!");
  801e99:	83 ec 04             	sub    $0x4,%esp
  801e9c:	68 fd 27 80 00       	push   $0x8027fd
  801ea1:	6a 22                	push   $0x22
  801ea3:	68 1b 28 80 00       	push   $0x80281b
  801ea8:	e8 ac e2 ff ff       	call   800159 <_panic>

00801ead <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ead:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801eae:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801eb3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801eb5:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  801eb8:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  801ebc:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  801ec0:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  801ec3:	83 c4 08             	add    $0x8,%esp
    popa
  801ec6:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  801ec7:	83 c4 04             	add    $0x4,%esp
    popf
  801eca:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  801ecb:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  801ece:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  801ed2:	c3                   	ret    

00801ed3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ed3:	f3 0f 1e fb          	endbr32 
  801ed7:	55                   	push   %ebp
  801ed8:	89 e5                	mov    %esp,%ebp
  801eda:	56                   	push   %esi
  801edb:	53                   	push   %ebx
  801edc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801edf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801eec:	0f 44 c2             	cmove  %edx,%eax
  801eef:	83 ec 0c             	sub    $0xc,%esp
  801ef2:	50                   	push   %eax
  801ef3:	e8 5f ef ff ff       	call   800e57 <sys_ipc_recv>
  801ef8:	83 c4 10             	add    $0x10,%esp
  801efb:	85 c0                	test   %eax,%eax
  801efd:	78 24                	js     801f23 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801eff:	85 f6                	test   %esi,%esi
  801f01:	74 0a                	je     801f0d <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801f03:	a1 08 40 80 00       	mov    0x804008,%eax
  801f08:	8b 40 78             	mov    0x78(%eax),%eax
  801f0b:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801f0d:	85 db                	test   %ebx,%ebx
  801f0f:	74 0a                	je     801f1b <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801f11:	a1 08 40 80 00       	mov    0x804008,%eax
  801f16:	8b 40 74             	mov    0x74(%eax),%eax
  801f19:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801f1b:	a1 08 40 80 00       	mov    0x804008,%eax
  801f20:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f23:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f26:	5b                   	pop    %ebx
  801f27:	5e                   	pop    %esi
  801f28:	5d                   	pop    %ebp
  801f29:	c3                   	ret    

00801f2a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f2a:	f3 0f 1e fb          	endbr32 
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	57                   	push   %edi
  801f32:	56                   	push   %esi
  801f33:	53                   	push   %ebx
  801f34:	83 ec 1c             	sub    $0x1c,%esp
  801f37:	8b 45 10             	mov    0x10(%ebp),%eax
  801f3a:	85 c0                	test   %eax,%eax
  801f3c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801f41:	0f 45 d0             	cmovne %eax,%edx
  801f44:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801f46:	be 01 00 00 00       	mov    $0x1,%esi
  801f4b:	eb 1f                	jmp    801f6c <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801f4d:	e8 16 ed ff ff       	call   800c68 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801f52:	83 c3 01             	add    $0x1,%ebx
  801f55:	39 de                	cmp    %ebx,%esi
  801f57:	7f f4                	jg     801f4d <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801f59:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801f5b:	83 fe 11             	cmp    $0x11,%esi
  801f5e:	b8 01 00 00 00       	mov    $0x1,%eax
  801f63:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801f66:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801f6a:	75 1c                	jne    801f88 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801f6c:	ff 75 14             	pushl  0x14(%ebp)
  801f6f:	57                   	push   %edi
  801f70:	ff 75 0c             	pushl  0xc(%ebp)
  801f73:	ff 75 08             	pushl  0x8(%ebp)
  801f76:	e8 b5 ee ff ff       	call   800e30 <sys_ipc_try_send>
  801f7b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801f7e:	83 c4 10             	add    $0x10,%esp
  801f81:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f86:	eb cd                	jmp    801f55 <ipc_send+0x2b>
}
  801f88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f8b:	5b                   	pop    %ebx
  801f8c:	5e                   	pop    %esi
  801f8d:	5f                   	pop    %edi
  801f8e:	5d                   	pop    %ebp
  801f8f:	c3                   	ret    

00801f90 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f90:	f3 0f 1e fb          	endbr32 
  801f94:	55                   	push   %ebp
  801f95:	89 e5                	mov    %esp,%ebp
  801f97:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f9a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f9f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fa2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fa8:	8b 52 50             	mov    0x50(%edx),%edx
  801fab:	39 ca                	cmp    %ecx,%edx
  801fad:	74 11                	je     801fc0 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801faf:	83 c0 01             	add    $0x1,%eax
  801fb2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fb7:	75 e6                	jne    801f9f <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801fb9:	b8 00 00 00 00       	mov    $0x0,%eax
  801fbe:	eb 0b                	jmp    801fcb <ipc_find_env+0x3b>
			return envs[i].env_id;
  801fc0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fc3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fc8:	8b 40 48             	mov    0x48(%eax),%eax
}
  801fcb:	5d                   	pop    %ebp
  801fcc:	c3                   	ret    

00801fcd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fcd:	f3 0f 1e fb          	endbr32 
  801fd1:	55                   	push   %ebp
  801fd2:	89 e5                	mov    %esp,%ebp
  801fd4:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fd7:	89 c2                	mov    %eax,%edx
  801fd9:	c1 ea 16             	shr    $0x16,%edx
  801fdc:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fe3:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fe8:	f6 c1 01             	test   $0x1,%cl
  801feb:	74 1c                	je     802009 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801fed:	c1 e8 0c             	shr    $0xc,%eax
  801ff0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ff7:	a8 01                	test   $0x1,%al
  801ff9:	74 0e                	je     802009 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ffb:	c1 e8 0c             	shr    $0xc,%eax
  801ffe:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802005:	ef 
  802006:	0f b7 d2             	movzwl %dx,%edx
}
  802009:	89 d0                	mov    %edx,%eax
  80200b:	5d                   	pop    %ebp
  80200c:	c3                   	ret    
  80200d:	66 90                	xchg   %ax,%ax
  80200f:	90                   	nop

00802010 <__udivdi3>:
  802010:	f3 0f 1e fb          	endbr32 
  802014:	55                   	push   %ebp
  802015:	57                   	push   %edi
  802016:	56                   	push   %esi
  802017:	53                   	push   %ebx
  802018:	83 ec 1c             	sub    $0x1c,%esp
  80201b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80201f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802023:	8b 74 24 34          	mov    0x34(%esp),%esi
  802027:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80202b:	85 d2                	test   %edx,%edx
  80202d:	75 19                	jne    802048 <__udivdi3+0x38>
  80202f:	39 f3                	cmp    %esi,%ebx
  802031:	76 4d                	jbe    802080 <__udivdi3+0x70>
  802033:	31 ff                	xor    %edi,%edi
  802035:	89 e8                	mov    %ebp,%eax
  802037:	89 f2                	mov    %esi,%edx
  802039:	f7 f3                	div    %ebx
  80203b:	89 fa                	mov    %edi,%edx
  80203d:	83 c4 1c             	add    $0x1c,%esp
  802040:	5b                   	pop    %ebx
  802041:	5e                   	pop    %esi
  802042:	5f                   	pop    %edi
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    
  802045:	8d 76 00             	lea    0x0(%esi),%esi
  802048:	39 f2                	cmp    %esi,%edx
  80204a:	76 14                	jbe    802060 <__udivdi3+0x50>
  80204c:	31 ff                	xor    %edi,%edi
  80204e:	31 c0                	xor    %eax,%eax
  802050:	89 fa                	mov    %edi,%edx
  802052:	83 c4 1c             	add    $0x1c,%esp
  802055:	5b                   	pop    %ebx
  802056:	5e                   	pop    %esi
  802057:	5f                   	pop    %edi
  802058:	5d                   	pop    %ebp
  802059:	c3                   	ret    
  80205a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802060:	0f bd fa             	bsr    %edx,%edi
  802063:	83 f7 1f             	xor    $0x1f,%edi
  802066:	75 48                	jne    8020b0 <__udivdi3+0xa0>
  802068:	39 f2                	cmp    %esi,%edx
  80206a:	72 06                	jb     802072 <__udivdi3+0x62>
  80206c:	31 c0                	xor    %eax,%eax
  80206e:	39 eb                	cmp    %ebp,%ebx
  802070:	77 de                	ja     802050 <__udivdi3+0x40>
  802072:	b8 01 00 00 00       	mov    $0x1,%eax
  802077:	eb d7                	jmp    802050 <__udivdi3+0x40>
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	89 d9                	mov    %ebx,%ecx
  802082:	85 db                	test   %ebx,%ebx
  802084:	75 0b                	jne    802091 <__udivdi3+0x81>
  802086:	b8 01 00 00 00       	mov    $0x1,%eax
  80208b:	31 d2                	xor    %edx,%edx
  80208d:	f7 f3                	div    %ebx
  80208f:	89 c1                	mov    %eax,%ecx
  802091:	31 d2                	xor    %edx,%edx
  802093:	89 f0                	mov    %esi,%eax
  802095:	f7 f1                	div    %ecx
  802097:	89 c6                	mov    %eax,%esi
  802099:	89 e8                	mov    %ebp,%eax
  80209b:	89 f7                	mov    %esi,%edi
  80209d:	f7 f1                	div    %ecx
  80209f:	89 fa                	mov    %edi,%edx
  8020a1:	83 c4 1c             	add    $0x1c,%esp
  8020a4:	5b                   	pop    %ebx
  8020a5:	5e                   	pop    %esi
  8020a6:	5f                   	pop    %edi
  8020a7:	5d                   	pop    %ebp
  8020a8:	c3                   	ret    
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 f9                	mov    %edi,%ecx
  8020b2:	b8 20 00 00 00       	mov    $0x20,%eax
  8020b7:	29 f8                	sub    %edi,%eax
  8020b9:	d3 e2                	shl    %cl,%edx
  8020bb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020bf:	89 c1                	mov    %eax,%ecx
  8020c1:	89 da                	mov    %ebx,%edx
  8020c3:	d3 ea                	shr    %cl,%edx
  8020c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020c9:	09 d1                	or     %edx,%ecx
  8020cb:	89 f2                	mov    %esi,%edx
  8020cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020d1:	89 f9                	mov    %edi,%ecx
  8020d3:	d3 e3                	shl    %cl,%ebx
  8020d5:	89 c1                	mov    %eax,%ecx
  8020d7:	d3 ea                	shr    %cl,%edx
  8020d9:	89 f9                	mov    %edi,%ecx
  8020db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020df:	89 eb                	mov    %ebp,%ebx
  8020e1:	d3 e6                	shl    %cl,%esi
  8020e3:	89 c1                	mov    %eax,%ecx
  8020e5:	d3 eb                	shr    %cl,%ebx
  8020e7:	09 de                	or     %ebx,%esi
  8020e9:	89 f0                	mov    %esi,%eax
  8020eb:	f7 74 24 08          	divl   0x8(%esp)
  8020ef:	89 d6                	mov    %edx,%esi
  8020f1:	89 c3                	mov    %eax,%ebx
  8020f3:	f7 64 24 0c          	mull   0xc(%esp)
  8020f7:	39 d6                	cmp    %edx,%esi
  8020f9:	72 15                	jb     802110 <__udivdi3+0x100>
  8020fb:	89 f9                	mov    %edi,%ecx
  8020fd:	d3 e5                	shl    %cl,%ebp
  8020ff:	39 c5                	cmp    %eax,%ebp
  802101:	73 04                	jae    802107 <__udivdi3+0xf7>
  802103:	39 d6                	cmp    %edx,%esi
  802105:	74 09                	je     802110 <__udivdi3+0x100>
  802107:	89 d8                	mov    %ebx,%eax
  802109:	31 ff                	xor    %edi,%edi
  80210b:	e9 40 ff ff ff       	jmp    802050 <__udivdi3+0x40>
  802110:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802113:	31 ff                	xor    %edi,%edi
  802115:	e9 36 ff ff ff       	jmp    802050 <__udivdi3+0x40>
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__umoddi3>:
  802120:	f3 0f 1e fb          	endbr32 
  802124:	55                   	push   %ebp
  802125:	57                   	push   %edi
  802126:	56                   	push   %esi
  802127:	53                   	push   %ebx
  802128:	83 ec 1c             	sub    $0x1c,%esp
  80212b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80212f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802133:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802137:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80213b:	85 c0                	test   %eax,%eax
  80213d:	75 19                	jne    802158 <__umoddi3+0x38>
  80213f:	39 df                	cmp    %ebx,%edi
  802141:	76 5d                	jbe    8021a0 <__umoddi3+0x80>
  802143:	89 f0                	mov    %esi,%eax
  802145:	89 da                	mov    %ebx,%edx
  802147:	f7 f7                	div    %edi
  802149:	89 d0                	mov    %edx,%eax
  80214b:	31 d2                	xor    %edx,%edx
  80214d:	83 c4 1c             	add    $0x1c,%esp
  802150:	5b                   	pop    %ebx
  802151:	5e                   	pop    %esi
  802152:	5f                   	pop    %edi
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    
  802155:	8d 76 00             	lea    0x0(%esi),%esi
  802158:	89 f2                	mov    %esi,%edx
  80215a:	39 d8                	cmp    %ebx,%eax
  80215c:	76 12                	jbe    802170 <__umoddi3+0x50>
  80215e:	89 f0                	mov    %esi,%eax
  802160:	89 da                	mov    %ebx,%edx
  802162:	83 c4 1c             	add    $0x1c,%esp
  802165:	5b                   	pop    %ebx
  802166:	5e                   	pop    %esi
  802167:	5f                   	pop    %edi
  802168:	5d                   	pop    %ebp
  802169:	c3                   	ret    
  80216a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802170:	0f bd e8             	bsr    %eax,%ebp
  802173:	83 f5 1f             	xor    $0x1f,%ebp
  802176:	75 50                	jne    8021c8 <__umoddi3+0xa8>
  802178:	39 d8                	cmp    %ebx,%eax
  80217a:	0f 82 e0 00 00 00    	jb     802260 <__umoddi3+0x140>
  802180:	89 d9                	mov    %ebx,%ecx
  802182:	39 f7                	cmp    %esi,%edi
  802184:	0f 86 d6 00 00 00    	jbe    802260 <__umoddi3+0x140>
  80218a:	89 d0                	mov    %edx,%eax
  80218c:	89 ca                	mov    %ecx,%edx
  80218e:	83 c4 1c             	add    $0x1c,%esp
  802191:	5b                   	pop    %ebx
  802192:	5e                   	pop    %esi
  802193:	5f                   	pop    %edi
  802194:	5d                   	pop    %ebp
  802195:	c3                   	ret    
  802196:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80219d:	8d 76 00             	lea    0x0(%esi),%esi
  8021a0:	89 fd                	mov    %edi,%ebp
  8021a2:	85 ff                	test   %edi,%edi
  8021a4:	75 0b                	jne    8021b1 <__umoddi3+0x91>
  8021a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ab:	31 d2                	xor    %edx,%edx
  8021ad:	f7 f7                	div    %edi
  8021af:	89 c5                	mov    %eax,%ebp
  8021b1:	89 d8                	mov    %ebx,%eax
  8021b3:	31 d2                	xor    %edx,%edx
  8021b5:	f7 f5                	div    %ebp
  8021b7:	89 f0                	mov    %esi,%eax
  8021b9:	f7 f5                	div    %ebp
  8021bb:	89 d0                	mov    %edx,%eax
  8021bd:	31 d2                	xor    %edx,%edx
  8021bf:	eb 8c                	jmp    80214d <__umoddi3+0x2d>
  8021c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c8:	89 e9                	mov    %ebp,%ecx
  8021ca:	ba 20 00 00 00       	mov    $0x20,%edx
  8021cf:	29 ea                	sub    %ebp,%edx
  8021d1:	d3 e0                	shl    %cl,%eax
  8021d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021d7:	89 d1                	mov    %edx,%ecx
  8021d9:	89 f8                	mov    %edi,%eax
  8021db:	d3 e8                	shr    %cl,%eax
  8021dd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8021e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021e5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021e9:	09 c1                	or     %eax,%ecx
  8021eb:	89 d8                	mov    %ebx,%eax
  8021ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021f1:	89 e9                	mov    %ebp,%ecx
  8021f3:	d3 e7                	shl    %cl,%edi
  8021f5:	89 d1                	mov    %edx,%ecx
  8021f7:	d3 e8                	shr    %cl,%eax
  8021f9:	89 e9                	mov    %ebp,%ecx
  8021fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021ff:	d3 e3                	shl    %cl,%ebx
  802201:	89 c7                	mov    %eax,%edi
  802203:	89 d1                	mov    %edx,%ecx
  802205:	89 f0                	mov    %esi,%eax
  802207:	d3 e8                	shr    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	89 fa                	mov    %edi,%edx
  80220d:	d3 e6                	shl    %cl,%esi
  80220f:	09 d8                	or     %ebx,%eax
  802211:	f7 74 24 08          	divl   0x8(%esp)
  802215:	89 d1                	mov    %edx,%ecx
  802217:	89 f3                	mov    %esi,%ebx
  802219:	f7 64 24 0c          	mull   0xc(%esp)
  80221d:	89 c6                	mov    %eax,%esi
  80221f:	89 d7                	mov    %edx,%edi
  802221:	39 d1                	cmp    %edx,%ecx
  802223:	72 06                	jb     80222b <__umoddi3+0x10b>
  802225:	75 10                	jne    802237 <__umoddi3+0x117>
  802227:	39 c3                	cmp    %eax,%ebx
  802229:	73 0c                	jae    802237 <__umoddi3+0x117>
  80222b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80222f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802233:	89 d7                	mov    %edx,%edi
  802235:	89 c6                	mov    %eax,%esi
  802237:	89 ca                	mov    %ecx,%edx
  802239:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80223e:	29 f3                	sub    %esi,%ebx
  802240:	19 fa                	sbb    %edi,%edx
  802242:	89 d0                	mov    %edx,%eax
  802244:	d3 e0                	shl    %cl,%eax
  802246:	89 e9                	mov    %ebp,%ecx
  802248:	d3 eb                	shr    %cl,%ebx
  80224a:	d3 ea                	shr    %cl,%edx
  80224c:	09 d8                	or     %ebx,%eax
  80224e:	83 c4 1c             	add    $0x1c,%esp
  802251:	5b                   	pop    %ebx
  802252:	5e                   	pop    %esi
  802253:	5f                   	pop    %edi
  802254:	5d                   	pop    %ebp
  802255:	c3                   	ret    
  802256:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80225d:	8d 76 00             	lea    0x0(%esi),%esi
  802260:	29 fe                	sub    %edi,%esi
  802262:	19 c3                	sbb    %eax,%ebx
  802264:	89 f2                	mov    %esi,%edx
  802266:	89 d9                	mov    %ebx,%ecx
  802268:	e9 1d ff ff ff       	jmp    80218a <__umoddi3+0x6a>
