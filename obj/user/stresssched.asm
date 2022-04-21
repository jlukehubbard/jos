
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
  8000bc:	68 7b 22 80 00       	push   $0x80227b
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
  8000d6:	68 40 22 80 00       	push   $0x802240
  8000db:	6a 21                	push   $0x21
  8000dd:	68 68 22 80 00       	push   $0x802268
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
  800145:	e8 82 11 00 00       	call   8012cc <close_all>
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
  80017b:	68 a4 22 80 00       	push   $0x8022a4
  800180:	e8 bb 00 00 00       	call   800240 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800185:	83 c4 18             	add    $0x18,%esp
  800188:	53                   	push   %ebx
  800189:	ff 75 10             	pushl  0x10(%ebp)
  80018c:	e8 5a 00 00 00       	call   8001eb <vcprintf>
	cprintf("\n");
  800191:	c7 04 24 d9 27 80 00 	movl   $0x8027d9,(%esp)
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
  8002a6:	e8 35 1d 00 00       	call   801fe0 <__udivdi3>
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
  8002e4:	e8 07 1e 00 00       	call   8020f0 <__umoddi3>
  8002e9:	83 c4 14             	add    $0x14,%esp
  8002ec:	0f be 80 c7 22 80 00 	movsbl 0x8022c7(%eax),%eax
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
  800393:	3e ff 24 85 00 24 80 	notrack jmp *0x802400(,%eax,4)
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
  800460:	8b 14 85 60 25 80 00 	mov    0x802560(,%eax,4),%edx
  800467:	85 d2                	test   %edx,%edx
  800469:	74 18                	je     800483 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80046b:	52                   	push   %edx
  80046c:	68 92 27 80 00       	push   $0x802792
  800471:	53                   	push   %ebx
  800472:	56                   	push   %esi
  800473:	e8 aa fe ff ff       	call   800322 <printfmt>
  800478:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80047b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80047e:	e9 22 02 00 00       	jmp    8006a5 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800483:	50                   	push   %eax
  800484:	68 df 22 80 00       	push   $0x8022df
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
  8004ab:	b8 d8 22 80 00       	mov    $0x8022d8,%eax
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
  800c34:	68 bf 25 80 00       	push   $0x8025bf
  800c39:	6a 23                	push   $0x23
  800c3b:	68 dc 25 80 00       	push   $0x8025dc
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
  800cc1:	68 bf 25 80 00       	push   $0x8025bf
  800cc6:	6a 23                	push   $0x23
  800cc8:	68 dc 25 80 00       	push   $0x8025dc
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
  800d07:	68 bf 25 80 00       	push   $0x8025bf
  800d0c:	6a 23                	push   $0x23
  800d0e:	68 dc 25 80 00       	push   $0x8025dc
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
  800d4d:	68 bf 25 80 00       	push   $0x8025bf
  800d52:	6a 23                	push   $0x23
  800d54:	68 dc 25 80 00       	push   $0x8025dc
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
  800d93:	68 bf 25 80 00       	push   $0x8025bf
  800d98:	6a 23                	push   $0x23
  800d9a:	68 dc 25 80 00       	push   $0x8025dc
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
  800dd9:	68 bf 25 80 00       	push   $0x8025bf
  800dde:	6a 23                	push   $0x23
  800de0:	68 dc 25 80 00       	push   $0x8025dc
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
  800e1f:	68 bf 25 80 00       	push   $0x8025bf
  800e24:	6a 23                	push   $0x23
  800e26:	68 dc 25 80 00       	push   $0x8025dc
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
  800e8b:	68 bf 25 80 00       	push   $0x8025bf
  800e90:	6a 23                	push   $0x23
  800e92:	68 dc 25 80 00       	push   $0x8025dc
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
  800f2a:	68 ea 25 80 00       	push   $0x8025ea
  800f2f:	6a 1e                	push   $0x1e
  800f31:	68 03 26 80 00       	push   $0x802603
  800f36:	e8 1e f2 ff ff       	call   800159 <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800f3b:	50                   	push   %eax
  800f3c:	68 0e 26 80 00       	push   $0x80260e
  800f41:	6a 2a                	push   $0x2a
  800f43:	68 03 26 80 00       	push   $0x802603
  800f48:	e8 0c f2 ff ff       	call   800159 <_panic>
        panic("sys_page_map failed %e\n", r);
  800f4d:	50                   	push   %eax
  800f4e:	68 28 26 80 00       	push   $0x802628
  800f53:	6a 2f                	push   $0x2f
  800f55:	68 03 26 80 00       	push   $0x802603
  800f5a:	e8 fa f1 ff ff       	call   800159 <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800f5f:	50                   	push   %eax
  800f60:	68 40 26 80 00       	push   $0x802640
  800f65:	6a 32                	push   $0x32
  800f67:	68 03 26 80 00       	push   $0x802603
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
  800f83:	e8 6e 0e 00 00       	call   801df6 <set_pgfault_handler>
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
  800fa5:	75 4e                	jne    800ff5 <fork+0x84>
        envid_t my_envid = sys_getenvid();
  800fa7:	e8 99 fc ff ff       	call   800c45 <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800fac:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fb1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fb4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fb9:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  800fbe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fc1:	e9 f1 00 00 00       	jmp    8010b7 <fork+0x146>
        panic("fork, sys_exofork %e", envid);
  800fc6:	50                   	push   %eax
  800fc7:	68 5a 26 80 00       	push   $0x80265a
  800fcc:	6a 7b                	push   $0x7b
  800fce:	68 03 26 80 00       	push   $0x802603
  800fd3:	e8 81 f1 ff ff       	call   800159 <_panic>
        panic("sys_page_map others failed %e\n", r);
  800fd8:	50                   	push   %eax
  800fd9:	68 a4 26 80 00       	push   $0x8026a4
  800fde:	6a 51                	push   $0x51
  800fe0:	68 03 26 80 00       	push   $0x802603
  800fe5:	e8 6f f1 ff ff       	call   800159 <_panic>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800fea:	83 c3 01             	add    $0x1,%ebx
  800fed:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800ff3:	74 7c                	je     801071 <fork+0x100>
  800ff5:	89 de                	mov    %ebx,%esi
  800ff7:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800ffa:	89 f0                	mov    %esi,%eax
  800ffc:	c1 e8 16             	shr    $0x16,%eax
  800fff:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801006:	a8 01                	test   $0x1,%al
  801008:	74 e0                	je     800fea <fork+0x79>
                    (uvpt[pn] & PTE_P) ) {
  80100a:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  801011:	a8 01                	test   $0x1,%al
  801013:	74 d5                	je     800fea <fork+0x79>
    pte_t pte = uvpt[pn];
  801015:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    if ( (pte & PTE_W) || (pte & PTE_COW) ) {
  80101c:	25 02 08 00 00       	and    $0x802,%eax
        perm |= PTE_COW;
  801021:	83 f8 01             	cmp    $0x1,%eax
  801024:	19 ff                	sbb    %edi,%edi
  801026:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  80102c:	81 c7 05 08 00 00    	add    $0x805,%edi
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  801032:	83 ec 0c             	sub    $0xc,%esp
  801035:	57                   	push   %edi
  801036:	56                   	push   %esi
  801037:	ff 75 e4             	pushl  -0x1c(%ebp)
  80103a:	56                   	push   %esi
  80103b:	6a 00                	push   $0x0
  80103d:	e8 90 fc ff ff       	call   800cd2 <sys_page_map>
  801042:	83 c4 20             	add    $0x20,%esp
  801045:	85 c0                	test   %eax,%eax
  801047:	78 8f                	js     800fd8 <fork+0x67>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  801049:	83 ec 0c             	sub    $0xc,%esp
  80104c:	57                   	push   %edi
  80104d:	56                   	push   %esi
  80104e:	6a 00                	push   $0x0
  801050:	56                   	push   %esi
  801051:	6a 00                	push   $0x0
  801053:	e8 7a fc ff ff       	call   800cd2 <sys_page_map>
  801058:	83 c4 20             	add    $0x20,%esp
  80105b:	85 c0                	test   %eax,%eax
  80105d:	79 8b                	jns    800fea <fork+0x79>
            panic("sys_page_map mine failed %e\n", r);
  80105f:	50                   	push   %eax
  801060:	68 6f 26 80 00       	push   $0x80266f
  801065:	6a 56                	push   $0x56
  801067:	68 03 26 80 00       	push   $0x802603
  80106c:	e8 e8 f0 ff ff       	call   800159 <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  801071:	83 ec 04             	sub    $0x4,%esp
  801074:	6a 07                	push   $0x7
  801076:	68 00 f0 bf ee       	push   $0xeebff000
  80107b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80107e:	57                   	push   %edi
  80107f:	e8 07 fc ff ff       	call   800c8b <sys_page_alloc>
  801084:	83 c4 10             	add    $0x10,%esp
  801087:	85 c0                	test   %eax,%eax
  801089:	78 2c                	js     8010b7 <fork+0x146>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  80108b:	a1 08 40 80 00       	mov    0x804008,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  801090:	8b 40 64             	mov    0x64(%eax),%eax
  801093:	83 ec 08             	sub    $0x8,%esp
  801096:	50                   	push   %eax
  801097:	57                   	push   %edi
  801098:	e8 4d fd ff ff       	call   800dea <sys_env_set_pgfault_upcall>
  80109d:	83 c4 10             	add    $0x10,%esp
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	78 13                	js     8010b7 <fork+0x146>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8010a4:	83 ec 08             	sub    $0x8,%esp
  8010a7:	6a 02                	push   $0x2
  8010a9:	57                   	push   %edi
  8010aa:	e8 af fc ff ff       	call   800d5e <sys_env_set_status>
  8010af:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	0f 49 c7             	cmovns %edi,%eax
    }

}
  8010b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ba:	5b                   	pop    %ebx
  8010bb:	5e                   	pop    %esi
  8010bc:	5f                   	pop    %edi
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    

008010bf <sfork>:

// Challenge!
int
sfork(void)
{
  8010bf:	f3 0f 1e fb          	endbr32 
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010c9:	68 8c 26 80 00       	push   $0x80268c
  8010ce:	68 a5 00 00 00       	push   $0xa5
  8010d3:	68 03 26 80 00       	push   $0x802603
  8010d8:	e8 7c f0 ff ff       	call   800159 <_panic>

008010dd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010dd:	f3 0f 1e fb          	endbr32 
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e7:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ec:	c1 e8 0c             	shr    $0xc,%eax
}
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    

008010f1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010f1:	f3 0f 1e fb          	endbr32 
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fb:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801100:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801105:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80110a:	5d                   	pop    %ebp
  80110b:	c3                   	ret    

0080110c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80110c:	f3 0f 1e fb          	endbr32 
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801118:	89 c2                	mov    %eax,%edx
  80111a:	c1 ea 16             	shr    $0x16,%edx
  80111d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801124:	f6 c2 01             	test   $0x1,%dl
  801127:	74 2d                	je     801156 <fd_alloc+0x4a>
  801129:	89 c2                	mov    %eax,%edx
  80112b:	c1 ea 0c             	shr    $0xc,%edx
  80112e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801135:	f6 c2 01             	test   $0x1,%dl
  801138:	74 1c                	je     801156 <fd_alloc+0x4a>
  80113a:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80113f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801144:	75 d2                	jne    801118 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801146:	8b 45 08             	mov    0x8(%ebp),%eax
  801149:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80114f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801154:	eb 0a                	jmp    801160 <fd_alloc+0x54>
			*fd_store = fd;
  801156:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801159:	89 01                	mov    %eax,(%ecx)
			return 0;
  80115b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801160:	5d                   	pop    %ebp
  801161:	c3                   	ret    

00801162 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801162:	f3 0f 1e fb          	endbr32 
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80116c:	83 f8 1f             	cmp    $0x1f,%eax
  80116f:	77 30                	ja     8011a1 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801171:	c1 e0 0c             	shl    $0xc,%eax
  801174:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801179:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80117f:	f6 c2 01             	test   $0x1,%dl
  801182:	74 24                	je     8011a8 <fd_lookup+0x46>
  801184:	89 c2                	mov    %eax,%edx
  801186:	c1 ea 0c             	shr    $0xc,%edx
  801189:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801190:	f6 c2 01             	test   $0x1,%dl
  801193:	74 1a                	je     8011af <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801195:	8b 55 0c             	mov    0xc(%ebp),%edx
  801198:	89 02                	mov    %eax,(%edx)
	return 0;
  80119a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80119f:	5d                   	pop    %ebp
  8011a0:	c3                   	ret    
		return -E_INVAL;
  8011a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a6:	eb f7                	jmp    80119f <fd_lookup+0x3d>
		return -E_INVAL;
  8011a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ad:	eb f0                	jmp    80119f <fd_lookup+0x3d>
  8011af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b4:	eb e9                	jmp    80119f <fd_lookup+0x3d>

008011b6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011b6:	f3 0f 1e fb          	endbr32 
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	83 ec 08             	sub    $0x8,%esp
  8011c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c3:	ba 40 27 80 00       	mov    $0x802740,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011c8:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8011cd:	39 08                	cmp    %ecx,(%eax)
  8011cf:	74 33                	je     801204 <dev_lookup+0x4e>
  8011d1:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8011d4:	8b 02                	mov    (%edx),%eax
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	75 f3                	jne    8011cd <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011da:	a1 08 40 80 00       	mov    0x804008,%eax
  8011df:	8b 40 48             	mov    0x48(%eax),%eax
  8011e2:	83 ec 04             	sub    $0x4,%esp
  8011e5:	51                   	push   %ecx
  8011e6:	50                   	push   %eax
  8011e7:	68 c4 26 80 00       	push   $0x8026c4
  8011ec:	e8 4f f0 ff ff       	call   800240 <cprintf>
	*dev = 0;
  8011f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011f4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011fa:	83 c4 10             	add    $0x10,%esp
  8011fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801202:	c9                   	leave  
  801203:	c3                   	ret    
			*dev = devtab[i];
  801204:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801207:	89 01                	mov    %eax,(%ecx)
			return 0;
  801209:	b8 00 00 00 00       	mov    $0x0,%eax
  80120e:	eb f2                	jmp    801202 <dev_lookup+0x4c>

00801210 <fd_close>:
{
  801210:	f3 0f 1e fb          	endbr32 
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	57                   	push   %edi
  801218:	56                   	push   %esi
  801219:	53                   	push   %ebx
  80121a:	83 ec 24             	sub    $0x24,%esp
  80121d:	8b 75 08             	mov    0x8(%ebp),%esi
  801220:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801223:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801226:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801227:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80122d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801230:	50                   	push   %eax
  801231:	e8 2c ff ff ff       	call   801162 <fd_lookup>
  801236:	89 c3                	mov    %eax,%ebx
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	85 c0                	test   %eax,%eax
  80123d:	78 05                	js     801244 <fd_close+0x34>
	    || fd != fd2)
  80123f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801242:	74 16                	je     80125a <fd_close+0x4a>
		return (must_exist ? r : 0);
  801244:	89 f8                	mov    %edi,%eax
  801246:	84 c0                	test   %al,%al
  801248:	b8 00 00 00 00       	mov    $0x0,%eax
  80124d:	0f 44 d8             	cmove  %eax,%ebx
}
  801250:	89 d8                	mov    %ebx,%eax
  801252:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801255:	5b                   	pop    %ebx
  801256:	5e                   	pop    %esi
  801257:	5f                   	pop    %edi
  801258:	5d                   	pop    %ebp
  801259:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80125a:	83 ec 08             	sub    $0x8,%esp
  80125d:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801260:	50                   	push   %eax
  801261:	ff 36                	pushl  (%esi)
  801263:	e8 4e ff ff ff       	call   8011b6 <dev_lookup>
  801268:	89 c3                	mov    %eax,%ebx
  80126a:	83 c4 10             	add    $0x10,%esp
  80126d:	85 c0                	test   %eax,%eax
  80126f:	78 1a                	js     80128b <fd_close+0x7b>
		if (dev->dev_close)
  801271:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801274:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801277:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80127c:	85 c0                	test   %eax,%eax
  80127e:	74 0b                	je     80128b <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801280:	83 ec 0c             	sub    $0xc,%esp
  801283:	56                   	push   %esi
  801284:	ff d0                	call   *%eax
  801286:	89 c3                	mov    %eax,%ebx
  801288:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80128b:	83 ec 08             	sub    $0x8,%esp
  80128e:	56                   	push   %esi
  80128f:	6a 00                	push   $0x0
  801291:	e8 82 fa ff ff       	call   800d18 <sys_page_unmap>
	return r;
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	eb b5                	jmp    801250 <fd_close+0x40>

0080129b <close>:

int
close(int fdnum)
{
  80129b:	f3 0f 1e fb          	endbr32 
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a8:	50                   	push   %eax
  8012a9:	ff 75 08             	pushl  0x8(%ebp)
  8012ac:	e8 b1 fe ff ff       	call   801162 <fd_lookup>
  8012b1:	83 c4 10             	add    $0x10,%esp
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	79 02                	jns    8012ba <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8012b8:	c9                   	leave  
  8012b9:	c3                   	ret    
		return fd_close(fd, 1);
  8012ba:	83 ec 08             	sub    $0x8,%esp
  8012bd:	6a 01                	push   $0x1
  8012bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8012c2:	e8 49 ff ff ff       	call   801210 <fd_close>
  8012c7:	83 c4 10             	add    $0x10,%esp
  8012ca:	eb ec                	jmp    8012b8 <close+0x1d>

008012cc <close_all>:

void
close_all(void)
{
  8012cc:	f3 0f 1e fb          	endbr32 
  8012d0:	55                   	push   %ebp
  8012d1:	89 e5                	mov    %esp,%ebp
  8012d3:	53                   	push   %ebx
  8012d4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012d7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012dc:	83 ec 0c             	sub    $0xc,%esp
  8012df:	53                   	push   %ebx
  8012e0:	e8 b6 ff ff ff       	call   80129b <close>
	for (i = 0; i < MAXFD; i++)
  8012e5:	83 c3 01             	add    $0x1,%ebx
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	83 fb 20             	cmp    $0x20,%ebx
  8012ee:	75 ec                	jne    8012dc <close_all+0x10>
}
  8012f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f3:	c9                   	leave  
  8012f4:	c3                   	ret    

008012f5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012f5:	f3 0f 1e fb          	endbr32 
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	57                   	push   %edi
  8012fd:	56                   	push   %esi
  8012fe:	53                   	push   %ebx
  8012ff:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801302:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801305:	50                   	push   %eax
  801306:	ff 75 08             	pushl  0x8(%ebp)
  801309:	e8 54 fe ff ff       	call   801162 <fd_lookup>
  80130e:	89 c3                	mov    %eax,%ebx
  801310:	83 c4 10             	add    $0x10,%esp
  801313:	85 c0                	test   %eax,%eax
  801315:	0f 88 81 00 00 00    	js     80139c <dup+0xa7>
		return r;
	close(newfdnum);
  80131b:	83 ec 0c             	sub    $0xc,%esp
  80131e:	ff 75 0c             	pushl  0xc(%ebp)
  801321:	e8 75 ff ff ff       	call   80129b <close>

	newfd = INDEX2FD(newfdnum);
  801326:	8b 75 0c             	mov    0xc(%ebp),%esi
  801329:	c1 e6 0c             	shl    $0xc,%esi
  80132c:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801332:	83 c4 04             	add    $0x4,%esp
  801335:	ff 75 e4             	pushl  -0x1c(%ebp)
  801338:	e8 b4 fd ff ff       	call   8010f1 <fd2data>
  80133d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80133f:	89 34 24             	mov    %esi,(%esp)
  801342:	e8 aa fd ff ff       	call   8010f1 <fd2data>
  801347:	83 c4 10             	add    $0x10,%esp
  80134a:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80134c:	89 d8                	mov    %ebx,%eax
  80134e:	c1 e8 16             	shr    $0x16,%eax
  801351:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801358:	a8 01                	test   $0x1,%al
  80135a:	74 11                	je     80136d <dup+0x78>
  80135c:	89 d8                	mov    %ebx,%eax
  80135e:	c1 e8 0c             	shr    $0xc,%eax
  801361:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801368:	f6 c2 01             	test   $0x1,%dl
  80136b:	75 39                	jne    8013a6 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80136d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801370:	89 d0                	mov    %edx,%eax
  801372:	c1 e8 0c             	shr    $0xc,%eax
  801375:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80137c:	83 ec 0c             	sub    $0xc,%esp
  80137f:	25 07 0e 00 00       	and    $0xe07,%eax
  801384:	50                   	push   %eax
  801385:	56                   	push   %esi
  801386:	6a 00                	push   $0x0
  801388:	52                   	push   %edx
  801389:	6a 00                	push   $0x0
  80138b:	e8 42 f9 ff ff       	call   800cd2 <sys_page_map>
  801390:	89 c3                	mov    %eax,%ebx
  801392:	83 c4 20             	add    $0x20,%esp
  801395:	85 c0                	test   %eax,%eax
  801397:	78 31                	js     8013ca <dup+0xd5>
		goto err;

	return newfdnum;
  801399:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80139c:	89 d8                	mov    %ebx,%eax
  80139e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013a1:	5b                   	pop    %ebx
  8013a2:	5e                   	pop    %esi
  8013a3:	5f                   	pop    %edi
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013a6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ad:	83 ec 0c             	sub    $0xc,%esp
  8013b0:	25 07 0e 00 00       	and    $0xe07,%eax
  8013b5:	50                   	push   %eax
  8013b6:	57                   	push   %edi
  8013b7:	6a 00                	push   $0x0
  8013b9:	53                   	push   %ebx
  8013ba:	6a 00                	push   $0x0
  8013bc:	e8 11 f9 ff ff       	call   800cd2 <sys_page_map>
  8013c1:	89 c3                	mov    %eax,%ebx
  8013c3:	83 c4 20             	add    $0x20,%esp
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	79 a3                	jns    80136d <dup+0x78>
	sys_page_unmap(0, newfd);
  8013ca:	83 ec 08             	sub    $0x8,%esp
  8013cd:	56                   	push   %esi
  8013ce:	6a 00                	push   $0x0
  8013d0:	e8 43 f9 ff ff       	call   800d18 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013d5:	83 c4 08             	add    $0x8,%esp
  8013d8:	57                   	push   %edi
  8013d9:	6a 00                	push   $0x0
  8013db:	e8 38 f9 ff ff       	call   800d18 <sys_page_unmap>
	return r;
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	eb b7                	jmp    80139c <dup+0xa7>

008013e5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013e5:	f3 0f 1e fb          	endbr32 
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
  8013ec:	53                   	push   %ebx
  8013ed:	83 ec 1c             	sub    $0x1c,%esp
  8013f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f6:	50                   	push   %eax
  8013f7:	53                   	push   %ebx
  8013f8:	e8 65 fd ff ff       	call   801162 <fd_lookup>
  8013fd:	83 c4 10             	add    $0x10,%esp
  801400:	85 c0                	test   %eax,%eax
  801402:	78 3f                	js     801443 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140a:	50                   	push   %eax
  80140b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140e:	ff 30                	pushl  (%eax)
  801410:	e8 a1 fd ff ff       	call   8011b6 <dev_lookup>
  801415:	83 c4 10             	add    $0x10,%esp
  801418:	85 c0                	test   %eax,%eax
  80141a:	78 27                	js     801443 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80141c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80141f:	8b 42 08             	mov    0x8(%edx),%eax
  801422:	83 e0 03             	and    $0x3,%eax
  801425:	83 f8 01             	cmp    $0x1,%eax
  801428:	74 1e                	je     801448 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80142a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80142d:	8b 40 08             	mov    0x8(%eax),%eax
  801430:	85 c0                	test   %eax,%eax
  801432:	74 35                	je     801469 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801434:	83 ec 04             	sub    $0x4,%esp
  801437:	ff 75 10             	pushl  0x10(%ebp)
  80143a:	ff 75 0c             	pushl  0xc(%ebp)
  80143d:	52                   	push   %edx
  80143e:	ff d0                	call   *%eax
  801440:	83 c4 10             	add    $0x10,%esp
}
  801443:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801446:	c9                   	leave  
  801447:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801448:	a1 08 40 80 00       	mov    0x804008,%eax
  80144d:	8b 40 48             	mov    0x48(%eax),%eax
  801450:	83 ec 04             	sub    $0x4,%esp
  801453:	53                   	push   %ebx
  801454:	50                   	push   %eax
  801455:	68 05 27 80 00       	push   $0x802705
  80145a:	e8 e1 ed ff ff       	call   800240 <cprintf>
		return -E_INVAL;
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801467:	eb da                	jmp    801443 <read+0x5e>
		return -E_NOT_SUPP;
  801469:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80146e:	eb d3                	jmp    801443 <read+0x5e>

00801470 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801470:	f3 0f 1e fb          	endbr32 
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	57                   	push   %edi
  801478:	56                   	push   %esi
  801479:	53                   	push   %ebx
  80147a:	83 ec 0c             	sub    $0xc,%esp
  80147d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801480:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801483:	bb 00 00 00 00       	mov    $0x0,%ebx
  801488:	eb 02                	jmp    80148c <readn+0x1c>
  80148a:	01 c3                	add    %eax,%ebx
  80148c:	39 f3                	cmp    %esi,%ebx
  80148e:	73 21                	jae    8014b1 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801490:	83 ec 04             	sub    $0x4,%esp
  801493:	89 f0                	mov    %esi,%eax
  801495:	29 d8                	sub    %ebx,%eax
  801497:	50                   	push   %eax
  801498:	89 d8                	mov    %ebx,%eax
  80149a:	03 45 0c             	add    0xc(%ebp),%eax
  80149d:	50                   	push   %eax
  80149e:	57                   	push   %edi
  80149f:	e8 41 ff ff ff       	call   8013e5 <read>
		if (m < 0)
  8014a4:	83 c4 10             	add    $0x10,%esp
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	78 04                	js     8014af <readn+0x3f>
			return m;
		if (m == 0)
  8014ab:	75 dd                	jne    80148a <readn+0x1a>
  8014ad:	eb 02                	jmp    8014b1 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014af:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8014b1:	89 d8                	mov    %ebx,%eax
  8014b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b6:	5b                   	pop    %ebx
  8014b7:	5e                   	pop    %esi
  8014b8:	5f                   	pop    %edi
  8014b9:	5d                   	pop    %ebp
  8014ba:	c3                   	ret    

008014bb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014bb:	f3 0f 1e fb          	endbr32 
  8014bf:	55                   	push   %ebp
  8014c0:	89 e5                	mov    %esp,%ebp
  8014c2:	53                   	push   %ebx
  8014c3:	83 ec 1c             	sub    $0x1c,%esp
  8014c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014cc:	50                   	push   %eax
  8014cd:	53                   	push   %ebx
  8014ce:	e8 8f fc ff ff       	call   801162 <fd_lookup>
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 3a                	js     801514 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014da:	83 ec 08             	sub    $0x8,%esp
  8014dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e0:	50                   	push   %eax
  8014e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e4:	ff 30                	pushl  (%eax)
  8014e6:	e8 cb fc ff ff       	call   8011b6 <dev_lookup>
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	78 22                	js     801514 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014f9:	74 1e                	je     801519 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014fe:	8b 52 0c             	mov    0xc(%edx),%edx
  801501:	85 d2                	test   %edx,%edx
  801503:	74 35                	je     80153a <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801505:	83 ec 04             	sub    $0x4,%esp
  801508:	ff 75 10             	pushl  0x10(%ebp)
  80150b:	ff 75 0c             	pushl  0xc(%ebp)
  80150e:	50                   	push   %eax
  80150f:	ff d2                	call   *%edx
  801511:	83 c4 10             	add    $0x10,%esp
}
  801514:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801517:	c9                   	leave  
  801518:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801519:	a1 08 40 80 00       	mov    0x804008,%eax
  80151e:	8b 40 48             	mov    0x48(%eax),%eax
  801521:	83 ec 04             	sub    $0x4,%esp
  801524:	53                   	push   %ebx
  801525:	50                   	push   %eax
  801526:	68 21 27 80 00       	push   $0x802721
  80152b:	e8 10 ed ff ff       	call   800240 <cprintf>
		return -E_INVAL;
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801538:	eb da                	jmp    801514 <write+0x59>
		return -E_NOT_SUPP;
  80153a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80153f:	eb d3                	jmp    801514 <write+0x59>

00801541 <seek>:

int
seek(int fdnum, off_t offset)
{
  801541:	f3 0f 1e fb          	endbr32 
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80154b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154e:	50                   	push   %eax
  80154f:	ff 75 08             	pushl  0x8(%ebp)
  801552:	e8 0b fc ff ff       	call   801162 <fd_lookup>
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	85 c0                	test   %eax,%eax
  80155c:	78 0e                	js     80156c <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80155e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801561:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801564:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801567:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80156c:	c9                   	leave  
  80156d:	c3                   	ret    

0080156e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80156e:	f3 0f 1e fb          	endbr32 
  801572:	55                   	push   %ebp
  801573:	89 e5                	mov    %esp,%ebp
  801575:	53                   	push   %ebx
  801576:	83 ec 1c             	sub    $0x1c,%esp
  801579:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80157c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80157f:	50                   	push   %eax
  801580:	53                   	push   %ebx
  801581:	e8 dc fb ff ff       	call   801162 <fd_lookup>
  801586:	83 c4 10             	add    $0x10,%esp
  801589:	85 c0                	test   %eax,%eax
  80158b:	78 37                	js     8015c4 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158d:	83 ec 08             	sub    $0x8,%esp
  801590:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801593:	50                   	push   %eax
  801594:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801597:	ff 30                	pushl  (%eax)
  801599:	e8 18 fc ff ff       	call   8011b6 <dev_lookup>
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	78 1f                	js     8015c4 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ac:	74 1b                	je     8015c9 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8015ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b1:	8b 52 18             	mov    0x18(%edx),%edx
  8015b4:	85 d2                	test   %edx,%edx
  8015b6:	74 32                	je     8015ea <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015b8:	83 ec 08             	sub    $0x8,%esp
  8015bb:	ff 75 0c             	pushl  0xc(%ebp)
  8015be:	50                   	push   %eax
  8015bf:	ff d2                	call   *%edx
  8015c1:	83 c4 10             	add    $0x10,%esp
}
  8015c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c7:	c9                   	leave  
  8015c8:	c3                   	ret    
			thisenv->env_id, fdnum);
  8015c9:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015ce:	8b 40 48             	mov    0x48(%eax),%eax
  8015d1:	83 ec 04             	sub    $0x4,%esp
  8015d4:	53                   	push   %ebx
  8015d5:	50                   	push   %eax
  8015d6:	68 e4 26 80 00       	push   $0x8026e4
  8015db:	e8 60 ec ff ff       	call   800240 <cprintf>
		return -E_INVAL;
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015e8:	eb da                	jmp    8015c4 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8015ea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015ef:	eb d3                	jmp    8015c4 <ftruncate+0x56>

008015f1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015f1:	f3 0f 1e fb          	endbr32 
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	53                   	push   %ebx
  8015f9:	83 ec 1c             	sub    $0x1c,%esp
  8015fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801602:	50                   	push   %eax
  801603:	ff 75 08             	pushl  0x8(%ebp)
  801606:	e8 57 fb ff ff       	call   801162 <fd_lookup>
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	85 c0                	test   %eax,%eax
  801610:	78 4b                	js     80165d <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801612:	83 ec 08             	sub    $0x8,%esp
  801615:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801618:	50                   	push   %eax
  801619:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161c:	ff 30                	pushl  (%eax)
  80161e:	e8 93 fb ff ff       	call   8011b6 <dev_lookup>
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	85 c0                	test   %eax,%eax
  801628:	78 33                	js     80165d <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80162a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801631:	74 2f                	je     801662 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801633:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801636:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80163d:	00 00 00 
	stat->st_isdir = 0;
  801640:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801647:	00 00 00 
	stat->st_dev = dev;
  80164a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801650:	83 ec 08             	sub    $0x8,%esp
  801653:	53                   	push   %ebx
  801654:	ff 75 f0             	pushl  -0x10(%ebp)
  801657:	ff 50 14             	call   *0x14(%eax)
  80165a:	83 c4 10             	add    $0x10,%esp
}
  80165d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801660:	c9                   	leave  
  801661:	c3                   	ret    
		return -E_NOT_SUPP;
  801662:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801667:	eb f4                	jmp    80165d <fstat+0x6c>

00801669 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801669:	f3 0f 1e fb          	endbr32 
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	56                   	push   %esi
  801671:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801672:	83 ec 08             	sub    $0x8,%esp
  801675:	6a 00                	push   $0x0
  801677:	ff 75 08             	pushl  0x8(%ebp)
  80167a:	e8 cf 01 00 00       	call   80184e <open>
  80167f:	89 c3                	mov    %eax,%ebx
  801681:	83 c4 10             	add    $0x10,%esp
  801684:	85 c0                	test   %eax,%eax
  801686:	78 1b                	js     8016a3 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801688:	83 ec 08             	sub    $0x8,%esp
  80168b:	ff 75 0c             	pushl  0xc(%ebp)
  80168e:	50                   	push   %eax
  80168f:	e8 5d ff ff ff       	call   8015f1 <fstat>
  801694:	89 c6                	mov    %eax,%esi
	close(fd);
  801696:	89 1c 24             	mov    %ebx,(%esp)
  801699:	e8 fd fb ff ff       	call   80129b <close>
	return r;
  80169e:	83 c4 10             	add    $0x10,%esp
  8016a1:	89 f3                	mov    %esi,%ebx
}
  8016a3:	89 d8                	mov    %ebx,%eax
  8016a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a8:	5b                   	pop    %ebx
  8016a9:	5e                   	pop    %esi
  8016aa:	5d                   	pop    %ebp
  8016ab:	c3                   	ret    

008016ac <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	56                   	push   %esi
  8016b0:	53                   	push   %ebx
  8016b1:	89 c6                	mov    %eax,%esi
  8016b3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016b5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016bc:	74 27                	je     8016e5 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016be:	6a 07                	push   $0x7
  8016c0:	68 00 50 80 00       	push   $0x805000
  8016c5:	56                   	push   %esi
  8016c6:	ff 35 00 40 80 00    	pushl  0x804000
  8016cc:	e8 22 08 00 00       	call   801ef3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016d1:	83 c4 0c             	add    $0xc,%esp
  8016d4:	6a 00                	push   $0x0
  8016d6:	53                   	push   %ebx
  8016d7:	6a 00                	push   $0x0
  8016d9:	e8 be 07 00 00       	call   801e9c <ipc_recv>
}
  8016de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e1:	5b                   	pop    %ebx
  8016e2:	5e                   	pop    %esi
  8016e3:	5d                   	pop    %ebp
  8016e4:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016e5:	83 ec 0c             	sub    $0xc,%esp
  8016e8:	6a 01                	push   $0x1
  8016ea:	e8 6a 08 00 00       	call   801f59 <ipc_find_env>
  8016ef:	a3 00 40 80 00       	mov    %eax,0x804000
  8016f4:	83 c4 10             	add    $0x10,%esp
  8016f7:	eb c5                	jmp    8016be <fsipc+0x12>

008016f9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016f9:	f3 0f 1e fb          	endbr32 
  8016fd:	55                   	push   %ebp
  8016fe:	89 e5                	mov    %esp,%ebp
  801700:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801703:	8b 45 08             	mov    0x8(%ebp),%eax
  801706:	8b 40 0c             	mov    0xc(%eax),%eax
  801709:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80170e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801711:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801716:	ba 00 00 00 00       	mov    $0x0,%edx
  80171b:	b8 02 00 00 00       	mov    $0x2,%eax
  801720:	e8 87 ff ff ff       	call   8016ac <fsipc>
}
  801725:	c9                   	leave  
  801726:	c3                   	ret    

00801727 <devfile_flush>:
{
  801727:	f3 0f 1e fb          	endbr32 
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801731:	8b 45 08             	mov    0x8(%ebp),%eax
  801734:	8b 40 0c             	mov    0xc(%eax),%eax
  801737:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80173c:	ba 00 00 00 00       	mov    $0x0,%edx
  801741:	b8 06 00 00 00       	mov    $0x6,%eax
  801746:	e8 61 ff ff ff       	call   8016ac <fsipc>
}
  80174b:	c9                   	leave  
  80174c:	c3                   	ret    

0080174d <devfile_stat>:
{
  80174d:	f3 0f 1e fb          	endbr32 
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	53                   	push   %ebx
  801755:	83 ec 04             	sub    $0x4,%esp
  801758:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80175b:	8b 45 08             	mov    0x8(%ebp),%eax
  80175e:	8b 40 0c             	mov    0xc(%eax),%eax
  801761:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801766:	ba 00 00 00 00       	mov    $0x0,%edx
  80176b:	b8 05 00 00 00       	mov    $0x5,%eax
  801770:	e8 37 ff ff ff       	call   8016ac <fsipc>
  801775:	85 c0                	test   %eax,%eax
  801777:	78 2c                	js     8017a5 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801779:	83 ec 08             	sub    $0x8,%esp
  80177c:	68 00 50 80 00       	push   $0x805000
  801781:	53                   	push   %ebx
  801782:	e8 c2 f0 ff ff       	call   800849 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801787:	a1 80 50 80 00       	mov    0x805080,%eax
  80178c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801792:	a1 84 50 80 00       	mov    0x805084,%eax
  801797:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80179d:	83 c4 10             	add    $0x10,%esp
  8017a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a8:	c9                   	leave  
  8017a9:	c3                   	ret    

008017aa <devfile_write>:
{
  8017aa:	f3 0f 1e fb          	endbr32 
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	83 ec 0c             	sub    $0xc,%esp
	panic("devfile_write not implemented");
  8017b4:	68 50 27 80 00       	push   $0x802750
  8017b9:	68 90 00 00 00       	push   $0x90
  8017be:	68 6e 27 80 00       	push   $0x80276e
  8017c3:	e8 91 e9 ff ff       	call   800159 <_panic>

008017c8 <devfile_read>:
{
  8017c8:	f3 0f 1e fb          	endbr32 
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	56                   	push   %esi
  8017d0:	53                   	push   %ebx
  8017d1:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017da:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017df:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ea:	b8 03 00 00 00       	mov    $0x3,%eax
  8017ef:	e8 b8 fe ff ff       	call   8016ac <fsipc>
  8017f4:	89 c3                	mov    %eax,%ebx
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	78 1f                	js     801819 <devfile_read+0x51>
	assert(r <= n);
  8017fa:	39 f0                	cmp    %esi,%eax
  8017fc:	77 24                	ja     801822 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8017fe:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801803:	7f 33                	jg     801838 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801805:	83 ec 04             	sub    $0x4,%esp
  801808:	50                   	push   %eax
  801809:	68 00 50 80 00       	push   $0x805000
  80180e:	ff 75 0c             	pushl  0xc(%ebp)
  801811:	e8 e9 f1 ff ff       	call   8009ff <memmove>
	return r;
  801816:	83 c4 10             	add    $0x10,%esp
}
  801819:	89 d8                	mov    %ebx,%eax
  80181b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80181e:	5b                   	pop    %ebx
  80181f:	5e                   	pop    %esi
  801820:	5d                   	pop    %ebp
  801821:	c3                   	ret    
	assert(r <= n);
  801822:	68 79 27 80 00       	push   $0x802779
  801827:	68 80 27 80 00       	push   $0x802780
  80182c:	6a 7c                	push   $0x7c
  80182e:	68 6e 27 80 00       	push   $0x80276e
  801833:	e8 21 e9 ff ff       	call   800159 <_panic>
	assert(r <= PGSIZE);
  801838:	68 95 27 80 00       	push   $0x802795
  80183d:	68 80 27 80 00       	push   $0x802780
  801842:	6a 7d                	push   $0x7d
  801844:	68 6e 27 80 00       	push   $0x80276e
  801849:	e8 0b e9 ff ff       	call   800159 <_panic>

0080184e <open>:
{
  80184e:	f3 0f 1e fb          	endbr32 
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
  801855:	56                   	push   %esi
  801856:	53                   	push   %ebx
  801857:	83 ec 1c             	sub    $0x1c,%esp
  80185a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80185d:	56                   	push   %esi
  80185e:	e8 a3 ef ff ff       	call   800806 <strlen>
  801863:	83 c4 10             	add    $0x10,%esp
  801866:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80186b:	7f 6c                	jg     8018d9 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80186d:	83 ec 0c             	sub    $0xc,%esp
  801870:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801873:	50                   	push   %eax
  801874:	e8 93 f8 ff ff       	call   80110c <fd_alloc>
  801879:	89 c3                	mov    %eax,%ebx
  80187b:	83 c4 10             	add    $0x10,%esp
  80187e:	85 c0                	test   %eax,%eax
  801880:	78 3c                	js     8018be <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801882:	83 ec 08             	sub    $0x8,%esp
  801885:	56                   	push   %esi
  801886:	68 00 50 80 00       	push   $0x805000
  80188b:	e8 b9 ef ff ff       	call   800849 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801890:	8b 45 0c             	mov    0xc(%ebp),%eax
  801893:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801898:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80189b:	b8 01 00 00 00       	mov    $0x1,%eax
  8018a0:	e8 07 fe ff ff       	call   8016ac <fsipc>
  8018a5:	89 c3                	mov    %eax,%ebx
  8018a7:	83 c4 10             	add    $0x10,%esp
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	78 19                	js     8018c7 <open+0x79>
	return fd2num(fd);
  8018ae:	83 ec 0c             	sub    $0xc,%esp
  8018b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b4:	e8 24 f8 ff ff       	call   8010dd <fd2num>
  8018b9:	89 c3                	mov    %eax,%ebx
  8018bb:	83 c4 10             	add    $0x10,%esp
}
  8018be:	89 d8                	mov    %ebx,%eax
  8018c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c3:	5b                   	pop    %ebx
  8018c4:	5e                   	pop    %esi
  8018c5:	5d                   	pop    %ebp
  8018c6:	c3                   	ret    
		fd_close(fd, 0);
  8018c7:	83 ec 08             	sub    $0x8,%esp
  8018ca:	6a 00                	push   $0x0
  8018cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8018cf:	e8 3c f9 ff ff       	call   801210 <fd_close>
		return r;
  8018d4:	83 c4 10             	add    $0x10,%esp
  8018d7:	eb e5                	jmp    8018be <open+0x70>
		return -E_BAD_PATH;
  8018d9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8018de:	eb de                	jmp    8018be <open+0x70>

008018e0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018e0:	f3 0f 1e fb          	endbr32 
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ef:	b8 08 00 00 00       	mov    $0x8,%eax
  8018f4:	e8 b3 fd ff ff       	call   8016ac <fsipc>
}
  8018f9:	c9                   	leave  
  8018fa:	c3                   	ret    

008018fb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018fb:	f3 0f 1e fb          	endbr32 
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	56                   	push   %esi
  801903:	53                   	push   %ebx
  801904:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801907:	83 ec 0c             	sub    $0xc,%esp
  80190a:	ff 75 08             	pushl  0x8(%ebp)
  80190d:	e8 df f7 ff ff       	call   8010f1 <fd2data>
  801912:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801914:	83 c4 08             	add    $0x8,%esp
  801917:	68 a1 27 80 00       	push   $0x8027a1
  80191c:	53                   	push   %ebx
  80191d:	e8 27 ef ff ff       	call   800849 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801922:	8b 46 04             	mov    0x4(%esi),%eax
  801925:	2b 06                	sub    (%esi),%eax
  801927:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80192d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801934:	00 00 00 
	stat->st_dev = &devpipe;
  801937:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80193e:	30 80 00 
	return 0;
}
  801941:	b8 00 00 00 00       	mov    $0x0,%eax
  801946:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801949:	5b                   	pop    %ebx
  80194a:	5e                   	pop    %esi
  80194b:	5d                   	pop    %ebp
  80194c:	c3                   	ret    

0080194d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80194d:	f3 0f 1e fb          	endbr32 
  801951:	55                   	push   %ebp
  801952:	89 e5                	mov    %esp,%ebp
  801954:	53                   	push   %ebx
  801955:	83 ec 0c             	sub    $0xc,%esp
  801958:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80195b:	53                   	push   %ebx
  80195c:	6a 00                	push   $0x0
  80195e:	e8 b5 f3 ff ff       	call   800d18 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801963:	89 1c 24             	mov    %ebx,(%esp)
  801966:	e8 86 f7 ff ff       	call   8010f1 <fd2data>
  80196b:	83 c4 08             	add    $0x8,%esp
  80196e:	50                   	push   %eax
  80196f:	6a 00                	push   $0x0
  801971:	e8 a2 f3 ff ff       	call   800d18 <sys_page_unmap>
}
  801976:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801979:	c9                   	leave  
  80197a:	c3                   	ret    

0080197b <_pipeisclosed>:
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	57                   	push   %edi
  80197f:	56                   	push   %esi
  801980:	53                   	push   %ebx
  801981:	83 ec 1c             	sub    $0x1c,%esp
  801984:	89 c7                	mov    %eax,%edi
  801986:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801988:	a1 08 40 80 00       	mov    0x804008,%eax
  80198d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801990:	83 ec 0c             	sub    $0xc,%esp
  801993:	57                   	push   %edi
  801994:	e8 fd 05 00 00       	call   801f96 <pageref>
  801999:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80199c:	89 34 24             	mov    %esi,(%esp)
  80199f:	e8 f2 05 00 00       	call   801f96 <pageref>
		nn = thisenv->env_runs;
  8019a4:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8019aa:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019ad:	83 c4 10             	add    $0x10,%esp
  8019b0:	39 cb                	cmp    %ecx,%ebx
  8019b2:	74 1b                	je     8019cf <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8019b4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8019b7:	75 cf                	jne    801988 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019b9:	8b 42 58             	mov    0x58(%edx),%eax
  8019bc:	6a 01                	push   $0x1
  8019be:	50                   	push   %eax
  8019bf:	53                   	push   %ebx
  8019c0:	68 a8 27 80 00       	push   $0x8027a8
  8019c5:	e8 76 e8 ff ff       	call   800240 <cprintf>
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	eb b9                	jmp    801988 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8019cf:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8019d2:	0f 94 c0             	sete   %al
  8019d5:	0f b6 c0             	movzbl %al,%eax
}
  8019d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019db:	5b                   	pop    %ebx
  8019dc:	5e                   	pop    %esi
  8019dd:	5f                   	pop    %edi
  8019de:	5d                   	pop    %ebp
  8019df:	c3                   	ret    

008019e0 <devpipe_write>:
{
  8019e0:	f3 0f 1e fb          	endbr32 
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	57                   	push   %edi
  8019e8:	56                   	push   %esi
  8019e9:	53                   	push   %ebx
  8019ea:	83 ec 28             	sub    $0x28,%esp
  8019ed:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8019f0:	56                   	push   %esi
  8019f1:	e8 fb f6 ff ff       	call   8010f1 <fd2data>
  8019f6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	bf 00 00 00 00       	mov    $0x0,%edi
  801a00:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a03:	74 4f                	je     801a54 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a05:	8b 43 04             	mov    0x4(%ebx),%eax
  801a08:	8b 0b                	mov    (%ebx),%ecx
  801a0a:	8d 51 20             	lea    0x20(%ecx),%edx
  801a0d:	39 d0                	cmp    %edx,%eax
  801a0f:	72 14                	jb     801a25 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801a11:	89 da                	mov    %ebx,%edx
  801a13:	89 f0                	mov    %esi,%eax
  801a15:	e8 61 ff ff ff       	call   80197b <_pipeisclosed>
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	75 3b                	jne    801a59 <devpipe_write+0x79>
			sys_yield();
  801a1e:	e8 45 f2 ff ff       	call   800c68 <sys_yield>
  801a23:	eb e0                	jmp    801a05 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a28:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a2c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a2f:	89 c2                	mov    %eax,%edx
  801a31:	c1 fa 1f             	sar    $0x1f,%edx
  801a34:	89 d1                	mov    %edx,%ecx
  801a36:	c1 e9 1b             	shr    $0x1b,%ecx
  801a39:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a3c:	83 e2 1f             	and    $0x1f,%edx
  801a3f:	29 ca                	sub    %ecx,%edx
  801a41:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a45:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a49:	83 c0 01             	add    $0x1,%eax
  801a4c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801a4f:	83 c7 01             	add    $0x1,%edi
  801a52:	eb ac                	jmp    801a00 <devpipe_write+0x20>
	return i;
  801a54:	8b 45 10             	mov    0x10(%ebp),%eax
  801a57:	eb 05                	jmp    801a5e <devpipe_write+0x7e>
				return 0;
  801a59:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a61:	5b                   	pop    %ebx
  801a62:	5e                   	pop    %esi
  801a63:	5f                   	pop    %edi
  801a64:	5d                   	pop    %ebp
  801a65:	c3                   	ret    

00801a66 <devpipe_read>:
{
  801a66:	f3 0f 1e fb          	endbr32 
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
  801a6d:	57                   	push   %edi
  801a6e:	56                   	push   %esi
  801a6f:	53                   	push   %ebx
  801a70:	83 ec 18             	sub    $0x18,%esp
  801a73:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801a76:	57                   	push   %edi
  801a77:	e8 75 f6 ff ff       	call   8010f1 <fd2data>
  801a7c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a7e:	83 c4 10             	add    $0x10,%esp
  801a81:	be 00 00 00 00       	mov    $0x0,%esi
  801a86:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a89:	75 14                	jne    801a9f <devpipe_read+0x39>
	return i;
  801a8b:	8b 45 10             	mov    0x10(%ebp),%eax
  801a8e:	eb 02                	jmp    801a92 <devpipe_read+0x2c>
				return i;
  801a90:	89 f0                	mov    %esi,%eax
}
  801a92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a95:	5b                   	pop    %ebx
  801a96:	5e                   	pop    %esi
  801a97:	5f                   	pop    %edi
  801a98:	5d                   	pop    %ebp
  801a99:	c3                   	ret    
			sys_yield();
  801a9a:	e8 c9 f1 ff ff       	call   800c68 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801a9f:	8b 03                	mov    (%ebx),%eax
  801aa1:	3b 43 04             	cmp    0x4(%ebx),%eax
  801aa4:	75 18                	jne    801abe <devpipe_read+0x58>
			if (i > 0)
  801aa6:	85 f6                	test   %esi,%esi
  801aa8:	75 e6                	jne    801a90 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801aaa:	89 da                	mov    %ebx,%edx
  801aac:	89 f8                	mov    %edi,%eax
  801aae:	e8 c8 fe ff ff       	call   80197b <_pipeisclosed>
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	74 e3                	je     801a9a <devpipe_read+0x34>
				return 0;
  801ab7:	b8 00 00 00 00       	mov    $0x0,%eax
  801abc:	eb d4                	jmp    801a92 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801abe:	99                   	cltd   
  801abf:	c1 ea 1b             	shr    $0x1b,%edx
  801ac2:	01 d0                	add    %edx,%eax
  801ac4:	83 e0 1f             	and    $0x1f,%eax
  801ac7:	29 d0                	sub    %edx,%eax
  801ac9:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801ace:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ad1:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ad4:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801ad7:	83 c6 01             	add    $0x1,%esi
  801ada:	eb aa                	jmp    801a86 <devpipe_read+0x20>

00801adc <pipe>:
{
  801adc:	f3 0f 1e fb          	endbr32 
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	56                   	push   %esi
  801ae4:	53                   	push   %ebx
  801ae5:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ae8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aeb:	50                   	push   %eax
  801aec:	e8 1b f6 ff ff       	call   80110c <fd_alloc>
  801af1:	89 c3                	mov    %eax,%ebx
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	85 c0                	test   %eax,%eax
  801af8:	0f 88 23 01 00 00    	js     801c21 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801afe:	83 ec 04             	sub    $0x4,%esp
  801b01:	68 07 04 00 00       	push   $0x407
  801b06:	ff 75 f4             	pushl  -0xc(%ebp)
  801b09:	6a 00                	push   $0x0
  801b0b:	e8 7b f1 ff ff       	call   800c8b <sys_page_alloc>
  801b10:	89 c3                	mov    %eax,%ebx
  801b12:	83 c4 10             	add    $0x10,%esp
  801b15:	85 c0                	test   %eax,%eax
  801b17:	0f 88 04 01 00 00    	js     801c21 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801b1d:	83 ec 0c             	sub    $0xc,%esp
  801b20:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b23:	50                   	push   %eax
  801b24:	e8 e3 f5 ff ff       	call   80110c <fd_alloc>
  801b29:	89 c3                	mov    %eax,%ebx
  801b2b:	83 c4 10             	add    $0x10,%esp
  801b2e:	85 c0                	test   %eax,%eax
  801b30:	0f 88 db 00 00 00    	js     801c11 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b36:	83 ec 04             	sub    $0x4,%esp
  801b39:	68 07 04 00 00       	push   $0x407
  801b3e:	ff 75 f0             	pushl  -0x10(%ebp)
  801b41:	6a 00                	push   $0x0
  801b43:	e8 43 f1 ff ff       	call   800c8b <sys_page_alloc>
  801b48:	89 c3                	mov    %eax,%ebx
  801b4a:	83 c4 10             	add    $0x10,%esp
  801b4d:	85 c0                	test   %eax,%eax
  801b4f:	0f 88 bc 00 00 00    	js     801c11 <pipe+0x135>
	va = fd2data(fd0);
  801b55:	83 ec 0c             	sub    $0xc,%esp
  801b58:	ff 75 f4             	pushl  -0xc(%ebp)
  801b5b:	e8 91 f5 ff ff       	call   8010f1 <fd2data>
  801b60:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b62:	83 c4 0c             	add    $0xc,%esp
  801b65:	68 07 04 00 00       	push   $0x407
  801b6a:	50                   	push   %eax
  801b6b:	6a 00                	push   $0x0
  801b6d:	e8 19 f1 ff ff       	call   800c8b <sys_page_alloc>
  801b72:	89 c3                	mov    %eax,%ebx
  801b74:	83 c4 10             	add    $0x10,%esp
  801b77:	85 c0                	test   %eax,%eax
  801b79:	0f 88 82 00 00 00    	js     801c01 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b7f:	83 ec 0c             	sub    $0xc,%esp
  801b82:	ff 75 f0             	pushl  -0x10(%ebp)
  801b85:	e8 67 f5 ff ff       	call   8010f1 <fd2data>
  801b8a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b91:	50                   	push   %eax
  801b92:	6a 00                	push   $0x0
  801b94:	56                   	push   %esi
  801b95:	6a 00                	push   $0x0
  801b97:	e8 36 f1 ff ff       	call   800cd2 <sys_page_map>
  801b9c:	89 c3                	mov    %eax,%ebx
  801b9e:	83 c4 20             	add    $0x20,%esp
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	78 4e                	js     801bf3 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801ba5:	a1 20 30 80 00       	mov    0x803020,%eax
  801baa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bad:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801baf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bb2:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801bb9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bbc:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801bbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bc1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801bc8:	83 ec 0c             	sub    $0xc,%esp
  801bcb:	ff 75 f4             	pushl  -0xc(%ebp)
  801bce:	e8 0a f5 ff ff       	call   8010dd <fd2num>
  801bd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bd6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bd8:	83 c4 04             	add    $0x4,%esp
  801bdb:	ff 75 f0             	pushl  -0x10(%ebp)
  801bde:	e8 fa f4 ff ff       	call   8010dd <fd2num>
  801be3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801be6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801be9:	83 c4 10             	add    $0x10,%esp
  801bec:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bf1:	eb 2e                	jmp    801c21 <pipe+0x145>
	sys_page_unmap(0, va);
  801bf3:	83 ec 08             	sub    $0x8,%esp
  801bf6:	56                   	push   %esi
  801bf7:	6a 00                	push   $0x0
  801bf9:	e8 1a f1 ff ff       	call   800d18 <sys_page_unmap>
  801bfe:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801c01:	83 ec 08             	sub    $0x8,%esp
  801c04:	ff 75 f0             	pushl  -0x10(%ebp)
  801c07:	6a 00                	push   $0x0
  801c09:	e8 0a f1 ff ff       	call   800d18 <sys_page_unmap>
  801c0e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801c11:	83 ec 08             	sub    $0x8,%esp
  801c14:	ff 75 f4             	pushl  -0xc(%ebp)
  801c17:	6a 00                	push   $0x0
  801c19:	e8 fa f0 ff ff       	call   800d18 <sys_page_unmap>
  801c1e:	83 c4 10             	add    $0x10,%esp
}
  801c21:	89 d8                	mov    %ebx,%eax
  801c23:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c26:	5b                   	pop    %ebx
  801c27:	5e                   	pop    %esi
  801c28:	5d                   	pop    %ebp
  801c29:	c3                   	ret    

00801c2a <pipeisclosed>:
{
  801c2a:	f3 0f 1e fb          	endbr32 
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c37:	50                   	push   %eax
  801c38:	ff 75 08             	pushl  0x8(%ebp)
  801c3b:	e8 22 f5 ff ff       	call   801162 <fd_lookup>
  801c40:	83 c4 10             	add    $0x10,%esp
  801c43:	85 c0                	test   %eax,%eax
  801c45:	78 18                	js     801c5f <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801c47:	83 ec 0c             	sub    $0xc,%esp
  801c4a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4d:	e8 9f f4 ff ff       	call   8010f1 <fd2data>
  801c52:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c57:	e8 1f fd ff ff       	call   80197b <_pipeisclosed>
  801c5c:	83 c4 10             	add    $0x10,%esp
}
  801c5f:	c9                   	leave  
  801c60:	c3                   	ret    

00801c61 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c61:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801c65:	b8 00 00 00 00       	mov    $0x0,%eax
  801c6a:	c3                   	ret    

00801c6b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c6b:	f3 0f 1e fb          	endbr32 
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c75:	68 c0 27 80 00       	push   $0x8027c0
  801c7a:	ff 75 0c             	pushl  0xc(%ebp)
  801c7d:	e8 c7 eb ff ff       	call   800849 <strcpy>
	return 0;
}
  801c82:	b8 00 00 00 00       	mov    $0x0,%eax
  801c87:	c9                   	leave  
  801c88:	c3                   	ret    

00801c89 <devcons_write>:
{
  801c89:	f3 0f 1e fb          	endbr32 
  801c8d:	55                   	push   %ebp
  801c8e:	89 e5                	mov    %esp,%ebp
  801c90:	57                   	push   %edi
  801c91:	56                   	push   %esi
  801c92:	53                   	push   %ebx
  801c93:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801c99:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801c9e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801ca4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ca7:	73 31                	jae    801cda <devcons_write+0x51>
		m = n - tot;
  801ca9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cac:	29 f3                	sub    %esi,%ebx
  801cae:	83 fb 7f             	cmp    $0x7f,%ebx
  801cb1:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801cb6:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801cb9:	83 ec 04             	sub    $0x4,%esp
  801cbc:	53                   	push   %ebx
  801cbd:	89 f0                	mov    %esi,%eax
  801cbf:	03 45 0c             	add    0xc(%ebp),%eax
  801cc2:	50                   	push   %eax
  801cc3:	57                   	push   %edi
  801cc4:	e8 36 ed ff ff       	call   8009ff <memmove>
		sys_cputs(buf, m);
  801cc9:	83 c4 08             	add    $0x8,%esp
  801ccc:	53                   	push   %ebx
  801ccd:	57                   	push   %edi
  801cce:	e8 e8 ee ff ff       	call   800bbb <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801cd3:	01 de                	add    %ebx,%esi
  801cd5:	83 c4 10             	add    $0x10,%esp
  801cd8:	eb ca                	jmp    801ca4 <devcons_write+0x1b>
}
  801cda:	89 f0                	mov    %esi,%eax
  801cdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cdf:	5b                   	pop    %ebx
  801ce0:	5e                   	pop    %esi
  801ce1:	5f                   	pop    %edi
  801ce2:	5d                   	pop    %ebp
  801ce3:	c3                   	ret    

00801ce4 <devcons_read>:
{
  801ce4:	f3 0f 1e fb          	endbr32 
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	83 ec 08             	sub    $0x8,%esp
  801cee:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801cf3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cf7:	74 21                	je     801d1a <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801cf9:	e8 df ee ff ff       	call   800bdd <sys_cgetc>
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	75 07                	jne    801d09 <devcons_read+0x25>
		sys_yield();
  801d02:	e8 61 ef ff ff       	call   800c68 <sys_yield>
  801d07:	eb f0                	jmp    801cf9 <devcons_read+0x15>
	if (c < 0)
  801d09:	78 0f                	js     801d1a <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801d0b:	83 f8 04             	cmp    $0x4,%eax
  801d0e:	74 0c                	je     801d1c <devcons_read+0x38>
	*(char*)vbuf = c;
  801d10:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d13:	88 02                	mov    %al,(%edx)
	return 1;
  801d15:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801d1a:	c9                   	leave  
  801d1b:	c3                   	ret    
		return 0;
  801d1c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d21:	eb f7                	jmp    801d1a <devcons_read+0x36>

00801d23 <cputchar>:
{
  801d23:	f3 0f 1e fb          	endbr32 
  801d27:	55                   	push   %ebp
  801d28:	89 e5                	mov    %esp,%ebp
  801d2a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d30:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801d33:	6a 01                	push   $0x1
  801d35:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d38:	50                   	push   %eax
  801d39:	e8 7d ee ff ff       	call   800bbb <sys_cputs>
}
  801d3e:	83 c4 10             	add    $0x10,%esp
  801d41:	c9                   	leave  
  801d42:	c3                   	ret    

00801d43 <getchar>:
{
  801d43:	f3 0f 1e fb          	endbr32 
  801d47:	55                   	push   %ebp
  801d48:	89 e5                	mov    %esp,%ebp
  801d4a:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801d4d:	6a 01                	push   $0x1
  801d4f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d52:	50                   	push   %eax
  801d53:	6a 00                	push   $0x0
  801d55:	e8 8b f6 ff ff       	call   8013e5 <read>
	if (r < 0)
  801d5a:	83 c4 10             	add    $0x10,%esp
  801d5d:	85 c0                	test   %eax,%eax
  801d5f:	78 06                	js     801d67 <getchar+0x24>
	if (r < 1)
  801d61:	74 06                	je     801d69 <getchar+0x26>
	return c;
  801d63:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801d67:	c9                   	leave  
  801d68:	c3                   	ret    
		return -E_EOF;
  801d69:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801d6e:	eb f7                	jmp    801d67 <getchar+0x24>

00801d70 <iscons>:
{
  801d70:	f3 0f 1e fb          	endbr32 
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
  801d77:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d7d:	50                   	push   %eax
  801d7e:	ff 75 08             	pushl  0x8(%ebp)
  801d81:	e8 dc f3 ff ff       	call   801162 <fd_lookup>
  801d86:	83 c4 10             	add    $0x10,%esp
  801d89:	85 c0                	test   %eax,%eax
  801d8b:	78 11                	js     801d9e <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d90:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d96:	39 10                	cmp    %edx,(%eax)
  801d98:	0f 94 c0             	sete   %al
  801d9b:	0f b6 c0             	movzbl %al,%eax
}
  801d9e:	c9                   	leave  
  801d9f:	c3                   	ret    

00801da0 <opencons>:
{
  801da0:	f3 0f 1e fb          	endbr32 
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801daa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dad:	50                   	push   %eax
  801dae:	e8 59 f3 ff ff       	call   80110c <fd_alloc>
  801db3:	83 c4 10             	add    $0x10,%esp
  801db6:	85 c0                	test   %eax,%eax
  801db8:	78 3a                	js     801df4 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dba:	83 ec 04             	sub    $0x4,%esp
  801dbd:	68 07 04 00 00       	push   $0x407
  801dc2:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc5:	6a 00                	push   $0x0
  801dc7:	e8 bf ee ff ff       	call   800c8b <sys_page_alloc>
  801dcc:	83 c4 10             	add    $0x10,%esp
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	78 21                	js     801df4 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801dd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ddc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801de8:	83 ec 0c             	sub    $0xc,%esp
  801deb:	50                   	push   %eax
  801dec:	e8 ec f2 ff ff       	call   8010dd <fd2num>
  801df1:	83 c4 10             	add    $0x10,%esp
}
  801df4:	c9                   	leave  
  801df5:	c3                   	ret    

00801df6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801df6:	f3 0f 1e fb          	endbr32 
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e00:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e07:	74 0a                	je     801e13 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e09:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e11:	c9                   	leave  
  801e12:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801e13:	83 ec 0c             	sub    $0xc,%esp
  801e16:	68 cc 27 80 00       	push   $0x8027cc
  801e1b:	e8 20 e4 ff ff       	call   800240 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  801e20:	83 c4 0c             	add    $0xc,%esp
  801e23:	6a 07                	push   $0x7
  801e25:	68 00 f0 bf ee       	push   $0xeebff000
  801e2a:	6a 00                	push   $0x0
  801e2c:	e8 5a ee ff ff       	call   800c8b <sys_page_alloc>
  801e31:	83 c4 10             	add    $0x10,%esp
  801e34:	85 c0                	test   %eax,%eax
  801e36:	78 2a                	js     801e62 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801e38:	83 ec 08             	sub    $0x8,%esp
  801e3b:	68 76 1e 80 00       	push   $0x801e76
  801e40:	6a 00                	push   $0x0
  801e42:	e8 a3 ef ff ff       	call   800dea <sys_env_set_pgfault_upcall>
  801e47:	83 c4 10             	add    $0x10,%esp
  801e4a:	85 c0                	test   %eax,%eax
  801e4c:	79 bb                	jns    801e09 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  801e4e:	83 ec 04             	sub    $0x4,%esp
  801e51:	68 08 28 80 00       	push   $0x802808
  801e56:	6a 25                	push   $0x25
  801e58:	68 f9 27 80 00       	push   $0x8027f9
  801e5d:	e8 f7 e2 ff ff       	call   800159 <_panic>
            panic("Allocation of UXSTACK failed!");
  801e62:	83 ec 04             	sub    $0x4,%esp
  801e65:	68 db 27 80 00       	push   $0x8027db
  801e6a:	6a 22                	push   $0x22
  801e6c:	68 f9 27 80 00       	push   $0x8027f9
  801e71:	e8 e3 e2 ff ff       	call   800159 <_panic>

00801e76 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e76:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e77:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e7c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e7e:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  801e81:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  801e85:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  801e89:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  801e8c:	83 c4 08             	add    $0x8,%esp
    popa
  801e8f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  801e90:	83 c4 04             	add    $0x4,%esp
    popf
  801e93:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  801e94:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  801e97:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  801e9b:	c3                   	ret    

00801e9c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e9c:	f3 0f 1e fb          	endbr32 
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
  801ea3:	56                   	push   %esi
  801ea4:	53                   	push   %ebx
  801ea5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eab:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801eb5:	0f 44 c2             	cmove  %edx,%eax
  801eb8:	83 ec 0c             	sub    $0xc,%esp
  801ebb:	50                   	push   %eax
  801ebc:	e8 96 ef ff ff       	call   800e57 <sys_ipc_recv>
  801ec1:	83 c4 10             	add    $0x10,%esp
  801ec4:	85 c0                	test   %eax,%eax
  801ec6:	78 24                	js     801eec <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801ec8:	85 f6                	test   %esi,%esi
  801eca:	74 0a                	je     801ed6 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801ecc:	a1 08 40 80 00       	mov    0x804008,%eax
  801ed1:	8b 40 78             	mov    0x78(%eax),%eax
  801ed4:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801ed6:	85 db                	test   %ebx,%ebx
  801ed8:	74 0a                	je     801ee4 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801eda:	a1 08 40 80 00       	mov    0x804008,%eax
  801edf:	8b 40 74             	mov    0x74(%eax),%eax
  801ee2:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801ee4:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee9:	8b 40 70             	mov    0x70(%eax),%eax
}
  801eec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eef:	5b                   	pop    %ebx
  801ef0:	5e                   	pop    %esi
  801ef1:	5d                   	pop    %ebp
  801ef2:	c3                   	ret    

00801ef3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ef3:	f3 0f 1e fb          	endbr32 
  801ef7:	55                   	push   %ebp
  801ef8:	89 e5                	mov    %esp,%ebp
  801efa:	57                   	push   %edi
  801efb:	56                   	push   %esi
  801efc:	53                   	push   %ebx
  801efd:	83 ec 1c             	sub    $0x1c,%esp
  801f00:	8b 45 10             	mov    0x10(%ebp),%eax
  801f03:	85 c0                	test   %eax,%eax
  801f05:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801f0a:	0f 45 d0             	cmovne %eax,%edx
  801f0d:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801f0f:	be 01 00 00 00       	mov    $0x1,%esi
  801f14:	eb 1f                	jmp    801f35 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801f16:	e8 4d ed ff ff       	call   800c68 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801f1b:	83 c3 01             	add    $0x1,%ebx
  801f1e:	39 de                	cmp    %ebx,%esi
  801f20:	7f f4                	jg     801f16 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801f22:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801f24:	83 fe 11             	cmp    $0x11,%esi
  801f27:	b8 01 00 00 00       	mov    $0x1,%eax
  801f2c:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801f2f:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801f33:	75 1c                	jne    801f51 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801f35:	ff 75 14             	pushl  0x14(%ebp)
  801f38:	57                   	push   %edi
  801f39:	ff 75 0c             	pushl  0xc(%ebp)
  801f3c:	ff 75 08             	pushl  0x8(%ebp)
  801f3f:	e8 ec ee ff ff       	call   800e30 <sys_ipc_try_send>
  801f44:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801f47:	83 c4 10             	add    $0x10,%esp
  801f4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f4f:	eb cd                	jmp    801f1e <ipc_send+0x2b>
}
  801f51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f54:	5b                   	pop    %ebx
  801f55:	5e                   	pop    %esi
  801f56:	5f                   	pop    %edi
  801f57:	5d                   	pop    %ebp
  801f58:	c3                   	ret    

00801f59 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f59:	f3 0f 1e fb          	endbr32 
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f63:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f68:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f6b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f71:	8b 52 50             	mov    0x50(%edx),%edx
  801f74:	39 ca                	cmp    %ecx,%edx
  801f76:	74 11                	je     801f89 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801f78:	83 c0 01             	add    $0x1,%eax
  801f7b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f80:	75 e6                	jne    801f68 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801f82:	b8 00 00 00 00       	mov    $0x0,%eax
  801f87:	eb 0b                	jmp    801f94 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801f89:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f8c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f91:	8b 40 48             	mov    0x48(%eax),%eax
}
  801f94:	5d                   	pop    %ebp
  801f95:	c3                   	ret    

00801f96 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f96:	f3 0f 1e fb          	endbr32 
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa0:	89 c2                	mov    %eax,%edx
  801fa2:	c1 ea 16             	shr    $0x16,%edx
  801fa5:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fac:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fb1:	f6 c1 01             	test   $0x1,%cl
  801fb4:	74 1c                	je     801fd2 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801fb6:	c1 e8 0c             	shr    $0xc,%eax
  801fb9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fc0:	a8 01                	test   $0x1,%al
  801fc2:	74 0e                	je     801fd2 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fc4:	c1 e8 0c             	shr    $0xc,%eax
  801fc7:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801fce:	ef 
  801fcf:	0f b7 d2             	movzwl %dx,%edx
}
  801fd2:	89 d0                	mov    %edx,%eax
  801fd4:	5d                   	pop    %ebp
  801fd5:	c3                   	ret    
  801fd6:	66 90                	xchg   %ax,%ax
  801fd8:	66 90                	xchg   %ax,%ax
  801fda:	66 90                	xchg   %ax,%ax
  801fdc:	66 90                	xchg   %ax,%ax
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
