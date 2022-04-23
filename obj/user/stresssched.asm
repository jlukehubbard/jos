
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
  80003c:	e8 fc 0b 00 00       	call   800c3d <sys_getenvid>
  800041:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  800043:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800048:	e8 1c 0f 00 00       	call   800f69 <fork>
  80004d:	85 c0                	test   %eax,%eax
  80004f:	74 0f                	je     800060 <umain+0x2d>
	for (i = 0; i < 20; i++)
  800051:	83 c3 01             	add    $0x1,%ebx
  800054:	83 fb 14             	cmp    $0x14,%ebx
  800057:	75 ef                	jne    800048 <umain+0x15>
			break;
	if (i == 20) {
		sys_yield();
  800059:	e8 02 0c 00 00       	call   800c60 <sys_yield>
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
  80007f:	e8 dc 0b 00 00       	call   800c60 <sys_yield>
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
  8000bc:	68 5b 14 80 00       	push   $0x80145b
  8000c1:	e8 72 01 00 00       	call   800238 <cprintf>
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
  8000d6:	68 20 14 80 00       	push   $0x801420
  8000db:	6a 21                	push   $0x21
  8000dd:	68 48 14 80 00       	push   $0x801448
  8000e2:	e8 6a 00 00 00       	call   800151 <_panic>

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
  8000f6:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  8000fd:	00 00 00 
    envid_t envid = sys_getenvid();
  800100:	e8 38 0b 00 00       	call   800c3d <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800105:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800112:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800117:	85 db                	test   %ebx,%ebx
  800119:	7e 07                	jle    800122 <libmain+0x3b>
		binaryname = argv[0];
  80011b:	8b 06                	mov    (%esi),%eax
  80011d:	a3 00 20 80 00       	mov    %eax,0x802000

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
  800142:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800145:	6a 00                	push   $0x0
  800147:	e8 ac 0a 00 00       	call   800bf8 <sys_env_destroy>
}
  80014c:	83 c4 10             	add    $0x10,%esp
  80014f:	c9                   	leave  
  800150:	c3                   	ret    

00800151 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800151:	f3 0f 1e fb          	endbr32 
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	56                   	push   %esi
  800159:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800163:	e8 d5 0a 00 00       	call   800c3d <sys_getenvid>
  800168:	83 ec 0c             	sub    $0xc,%esp
  80016b:	ff 75 0c             	pushl  0xc(%ebp)
  80016e:	ff 75 08             	pushl  0x8(%ebp)
  800171:	56                   	push   %esi
  800172:	50                   	push   %eax
  800173:	68 84 14 80 00       	push   $0x801484
  800178:	e8 bb 00 00 00       	call   800238 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80017d:	83 c4 18             	add    $0x18,%esp
  800180:	53                   	push   %ebx
  800181:	ff 75 10             	pushl  0x10(%ebp)
  800184:	e8 5a 00 00 00       	call   8001e3 <vcprintf>
	cprintf("\n");
  800189:	c7 04 24 b0 18 80 00 	movl   $0x8018b0,(%esp)
  800190:	e8 a3 00 00 00       	call   800238 <cprintf>
  800195:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800198:	cc                   	int3   
  800199:	eb fd                	jmp    800198 <_panic+0x47>

0080019b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019b:	f3 0f 1e fb          	endbr32 
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 04             	sub    $0x4,%esp
  8001a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a9:	8b 13                	mov    (%ebx),%edx
  8001ab:	8d 42 01             	lea    0x1(%edx),%eax
  8001ae:	89 03                	mov    %eax,(%ebx)
  8001b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bc:	74 09                	je     8001c7 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001be:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c5:	c9                   	leave  
  8001c6:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	68 ff 00 00 00       	push   $0xff
  8001cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d2:	50                   	push   %eax
  8001d3:	e8 db 09 00 00       	call   800bb3 <sys_cputs>
		b->idx = 0;
  8001d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001de:	83 c4 10             	add    $0x10,%esp
  8001e1:	eb db                	jmp    8001be <putch+0x23>

008001e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e3:	f3 0f 1e fb          	endbr32 
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001f0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f7:	00 00 00 
	b.cnt = 0;
  8001fa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800201:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800204:	ff 75 0c             	pushl  0xc(%ebp)
  800207:	ff 75 08             	pushl  0x8(%ebp)
  80020a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800210:	50                   	push   %eax
  800211:	68 9b 01 80 00       	push   $0x80019b
  800216:	e8 20 01 00 00       	call   80033b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021b:	83 c4 08             	add    $0x8,%esp
  80021e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800224:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022a:	50                   	push   %eax
  80022b:	e8 83 09 00 00       	call   800bb3 <sys_cputs>

	return b.cnt;
}
  800230:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800238:	f3 0f 1e fb          	endbr32 
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800242:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800245:	50                   	push   %eax
  800246:	ff 75 08             	pushl  0x8(%ebp)
  800249:	e8 95 ff ff ff       	call   8001e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	57                   	push   %edi
  800254:	56                   	push   %esi
  800255:	53                   	push   %ebx
  800256:	83 ec 1c             	sub    $0x1c,%esp
  800259:	89 c7                	mov    %eax,%edi
  80025b:	89 d6                	mov    %edx,%esi
  80025d:	8b 45 08             	mov    0x8(%ebp),%eax
  800260:	8b 55 0c             	mov    0xc(%ebp),%edx
  800263:	89 d1                	mov    %edx,%ecx
  800265:	89 c2                	mov    %eax,%edx
  800267:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80026a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80026d:	8b 45 10             	mov    0x10(%ebp),%eax
  800270:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800273:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800276:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80027d:	39 c2                	cmp    %eax,%edx
  80027f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800282:	72 3e                	jb     8002c2 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800284:	83 ec 0c             	sub    $0xc,%esp
  800287:	ff 75 18             	pushl  0x18(%ebp)
  80028a:	83 eb 01             	sub    $0x1,%ebx
  80028d:	53                   	push   %ebx
  80028e:	50                   	push   %eax
  80028f:	83 ec 08             	sub    $0x8,%esp
  800292:	ff 75 e4             	pushl  -0x1c(%ebp)
  800295:	ff 75 e0             	pushl  -0x20(%ebp)
  800298:	ff 75 dc             	pushl  -0x24(%ebp)
  80029b:	ff 75 d8             	pushl  -0x28(%ebp)
  80029e:	e8 1d 0f 00 00       	call   8011c0 <__udivdi3>
  8002a3:	83 c4 18             	add    $0x18,%esp
  8002a6:	52                   	push   %edx
  8002a7:	50                   	push   %eax
  8002a8:	89 f2                	mov    %esi,%edx
  8002aa:	89 f8                	mov    %edi,%eax
  8002ac:	e8 9f ff ff ff       	call   800250 <printnum>
  8002b1:	83 c4 20             	add    $0x20,%esp
  8002b4:	eb 13                	jmp    8002c9 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b6:	83 ec 08             	sub    $0x8,%esp
  8002b9:	56                   	push   %esi
  8002ba:	ff 75 18             	pushl  0x18(%ebp)
  8002bd:	ff d7                	call   *%edi
  8002bf:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002c2:	83 eb 01             	sub    $0x1,%ebx
  8002c5:	85 db                	test   %ebx,%ebx
  8002c7:	7f ed                	jg     8002b6 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c9:	83 ec 08             	sub    $0x8,%esp
  8002cc:	56                   	push   %esi
  8002cd:	83 ec 04             	sub    $0x4,%esp
  8002d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002dc:	e8 ef 0f 00 00       	call   8012d0 <__umoddi3>
  8002e1:	83 c4 14             	add    $0x14,%esp
  8002e4:	0f be 80 a7 14 80 00 	movsbl 0x8014a7(%eax),%eax
  8002eb:	50                   	push   %eax
  8002ec:	ff d7                	call   *%edi
}
  8002ee:	83 c4 10             	add    $0x10,%esp
  8002f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f4:	5b                   	pop    %ebx
  8002f5:	5e                   	pop    %esi
  8002f6:	5f                   	pop    %edi
  8002f7:	5d                   	pop    %ebp
  8002f8:	c3                   	ret    

008002f9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f9:	f3 0f 1e fb          	endbr32 
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800303:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800307:	8b 10                	mov    (%eax),%edx
  800309:	3b 50 04             	cmp    0x4(%eax),%edx
  80030c:	73 0a                	jae    800318 <sprintputch+0x1f>
		*b->buf++ = ch;
  80030e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 45 08             	mov    0x8(%ebp),%eax
  800316:	88 02                	mov    %al,(%edx)
}
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <printfmt>:
{
  80031a:	f3 0f 1e fb          	endbr32 
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800324:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800327:	50                   	push   %eax
  800328:	ff 75 10             	pushl  0x10(%ebp)
  80032b:	ff 75 0c             	pushl  0xc(%ebp)
  80032e:	ff 75 08             	pushl  0x8(%ebp)
  800331:	e8 05 00 00 00       	call   80033b <vprintfmt>
}
  800336:	83 c4 10             	add    $0x10,%esp
  800339:	c9                   	leave  
  80033a:	c3                   	ret    

0080033b <vprintfmt>:
{
  80033b:	f3 0f 1e fb          	endbr32 
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	57                   	push   %edi
  800343:	56                   	push   %esi
  800344:	53                   	push   %ebx
  800345:	83 ec 3c             	sub    $0x3c,%esp
  800348:	8b 75 08             	mov    0x8(%ebp),%esi
  80034b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80034e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800351:	e9 4a 03 00 00       	jmp    8006a0 <vprintfmt+0x365>
		padc = ' ';
  800356:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80035a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800361:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800368:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80036f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800374:	8d 47 01             	lea    0x1(%edi),%eax
  800377:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80037a:	0f b6 17             	movzbl (%edi),%edx
  80037d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800380:	3c 55                	cmp    $0x55,%al
  800382:	0f 87 de 03 00 00    	ja     800766 <vprintfmt+0x42b>
  800388:	0f b6 c0             	movzbl %al,%eax
  80038b:	3e ff 24 85 e0 15 80 	notrack jmp *0x8015e0(,%eax,4)
  800392:	00 
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800396:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80039a:	eb d8                	jmp    800374 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039f:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003a3:	eb cf                	jmp    800374 <vprintfmt+0x39>
  8003a5:	0f b6 d2             	movzbl %dl,%edx
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003b3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003ba:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003bd:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003c0:	83 f9 09             	cmp    $0x9,%ecx
  8003c3:	77 55                	ja     80041a <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003c5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003c8:	eb e9                	jmp    8003b3 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	8b 00                	mov    (%eax),%eax
  8003cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8d 40 04             	lea    0x4(%eax),%eax
  8003d8:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003de:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e2:	79 90                	jns    800374 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ea:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003f1:	eb 81                	jmp    800374 <vprintfmt+0x39>
  8003f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f6:	85 c0                	test   %eax,%eax
  8003f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fd:	0f 49 d0             	cmovns %eax,%edx
  800400:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800406:	e9 69 ff ff ff       	jmp    800374 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80040e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800415:	e9 5a ff ff ff       	jmp    800374 <vprintfmt+0x39>
  80041a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80041d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800420:	eb bc                	jmp    8003de <vprintfmt+0xa3>
			lflag++;
  800422:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800428:	e9 47 ff ff ff       	jmp    800374 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80042d:	8b 45 14             	mov    0x14(%ebp),%eax
  800430:	8d 78 04             	lea    0x4(%eax),%edi
  800433:	83 ec 08             	sub    $0x8,%esp
  800436:	53                   	push   %ebx
  800437:	ff 30                	pushl  (%eax)
  800439:	ff d6                	call   *%esi
			break;
  80043b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80043e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800441:	e9 57 02 00 00       	jmp    80069d <vprintfmt+0x362>
			err = va_arg(ap, int);
  800446:	8b 45 14             	mov    0x14(%ebp),%eax
  800449:	8d 78 04             	lea    0x4(%eax),%edi
  80044c:	8b 00                	mov    (%eax),%eax
  80044e:	99                   	cltd   
  80044f:	31 d0                	xor    %edx,%eax
  800451:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800453:	83 f8 0f             	cmp    $0xf,%eax
  800456:	7f 23                	jg     80047b <vprintfmt+0x140>
  800458:	8b 14 85 40 17 80 00 	mov    0x801740(,%eax,4),%edx
  80045f:	85 d2                	test   %edx,%edx
  800461:	74 18                	je     80047b <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800463:	52                   	push   %edx
  800464:	68 c8 14 80 00       	push   $0x8014c8
  800469:	53                   	push   %ebx
  80046a:	56                   	push   %esi
  80046b:	e8 aa fe ff ff       	call   80031a <printfmt>
  800470:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800473:	89 7d 14             	mov    %edi,0x14(%ebp)
  800476:	e9 22 02 00 00       	jmp    80069d <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  80047b:	50                   	push   %eax
  80047c:	68 bf 14 80 00       	push   $0x8014bf
  800481:	53                   	push   %ebx
  800482:	56                   	push   %esi
  800483:	e8 92 fe ff ff       	call   80031a <printfmt>
  800488:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80048b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80048e:	e9 0a 02 00 00       	jmp    80069d <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800493:	8b 45 14             	mov    0x14(%ebp),%eax
  800496:	83 c0 04             	add    $0x4,%eax
  800499:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80049c:	8b 45 14             	mov    0x14(%ebp),%eax
  80049f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004a1:	85 d2                	test   %edx,%edx
  8004a3:	b8 b8 14 80 00       	mov    $0x8014b8,%eax
  8004a8:	0f 45 c2             	cmovne %edx,%eax
  8004ab:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004ae:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b2:	7e 06                	jle    8004ba <vprintfmt+0x17f>
  8004b4:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004b8:	75 0d                	jne    8004c7 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ba:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004bd:	89 c7                	mov    %eax,%edi
  8004bf:	03 45 e0             	add    -0x20(%ebp),%eax
  8004c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c5:	eb 55                	jmp    80051c <vprintfmt+0x1e1>
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	ff 75 d8             	pushl  -0x28(%ebp)
  8004cd:	ff 75 cc             	pushl  -0x34(%ebp)
  8004d0:	e8 45 03 00 00       	call   80081a <strnlen>
  8004d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004d8:	29 c2                	sub    %eax,%edx
  8004da:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004dd:	83 c4 10             	add    $0x10,%esp
  8004e0:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004e2:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e9:	85 ff                	test   %edi,%edi
  8004eb:	7e 11                	jle    8004fe <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	53                   	push   %ebx
  8004f1:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f4:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f6:	83 ef 01             	sub    $0x1,%edi
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	eb eb                	jmp    8004e9 <vprintfmt+0x1ae>
  8004fe:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800501:	85 d2                	test   %edx,%edx
  800503:	b8 00 00 00 00       	mov    $0x0,%eax
  800508:	0f 49 c2             	cmovns %edx,%eax
  80050b:	29 c2                	sub    %eax,%edx
  80050d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800510:	eb a8                	jmp    8004ba <vprintfmt+0x17f>
					putch(ch, putdat);
  800512:	83 ec 08             	sub    $0x8,%esp
  800515:	53                   	push   %ebx
  800516:	52                   	push   %edx
  800517:	ff d6                	call   *%esi
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80051f:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800521:	83 c7 01             	add    $0x1,%edi
  800524:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800528:	0f be d0             	movsbl %al,%edx
  80052b:	85 d2                	test   %edx,%edx
  80052d:	74 4b                	je     80057a <vprintfmt+0x23f>
  80052f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800533:	78 06                	js     80053b <vprintfmt+0x200>
  800535:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800539:	78 1e                	js     800559 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80053b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80053f:	74 d1                	je     800512 <vprintfmt+0x1d7>
  800541:	0f be c0             	movsbl %al,%eax
  800544:	83 e8 20             	sub    $0x20,%eax
  800547:	83 f8 5e             	cmp    $0x5e,%eax
  80054a:	76 c6                	jbe    800512 <vprintfmt+0x1d7>
					putch('?', putdat);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	53                   	push   %ebx
  800550:	6a 3f                	push   $0x3f
  800552:	ff d6                	call   *%esi
  800554:	83 c4 10             	add    $0x10,%esp
  800557:	eb c3                	jmp    80051c <vprintfmt+0x1e1>
  800559:	89 cf                	mov    %ecx,%edi
  80055b:	eb 0e                	jmp    80056b <vprintfmt+0x230>
				putch(' ', putdat);
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	53                   	push   %ebx
  800561:	6a 20                	push   $0x20
  800563:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800565:	83 ef 01             	sub    $0x1,%edi
  800568:	83 c4 10             	add    $0x10,%esp
  80056b:	85 ff                	test   %edi,%edi
  80056d:	7f ee                	jg     80055d <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80056f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800572:	89 45 14             	mov    %eax,0x14(%ebp)
  800575:	e9 23 01 00 00       	jmp    80069d <vprintfmt+0x362>
  80057a:	89 cf                	mov    %ecx,%edi
  80057c:	eb ed                	jmp    80056b <vprintfmt+0x230>
	if (lflag >= 2)
  80057e:	83 f9 01             	cmp    $0x1,%ecx
  800581:	7f 1b                	jg     80059e <vprintfmt+0x263>
	else if (lflag)
  800583:	85 c9                	test   %ecx,%ecx
  800585:	74 63                	je     8005ea <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800587:	8b 45 14             	mov    0x14(%ebp),%eax
  80058a:	8b 00                	mov    (%eax),%eax
  80058c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058f:	99                   	cltd   
  800590:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800593:	8b 45 14             	mov    0x14(%ebp),%eax
  800596:	8d 40 04             	lea    0x4(%eax),%eax
  800599:	89 45 14             	mov    %eax,0x14(%ebp)
  80059c:	eb 17                	jmp    8005b5 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8b 50 04             	mov    0x4(%eax),%edx
  8005a4:	8b 00                	mov    (%eax),%eax
  8005a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8d 40 08             	lea    0x8(%eax),%eax
  8005b2:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005b5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005bb:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005c0:	85 c9                	test   %ecx,%ecx
  8005c2:	0f 89 bb 00 00 00    	jns    800683 <vprintfmt+0x348>
				putch('-', putdat);
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	53                   	push   %ebx
  8005cc:	6a 2d                	push   $0x2d
  8005ce:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005d6:	f7 da                	neg    %edx
  8005d8:	83 d1 00             	adc    $0x0,%ecx
  8005db:	f7 d9                	neg    %ecx
  8005dd:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005e0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e5:	e9 99 00 00 00       	jmp    800683 <vprintfmt+0x348>
		return va_arg(*ap, int);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8b 00                	mov    (%eax),%eax
  8005ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f2:	99                   	cltd   
  8005f3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8d 40 04             	lea    0x4(%eax),%eax
  8005fc:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ff:	eb b4                	jmp    8005b5 <vprintfmt+0x27a>
	if (lflag >= 2)
  800601:	83 f9 01             	cmp    $0x1,%ecx
  800604:	7f 1b                	jg     800621 <vprintfmt+0x2e6>
	else if (lflag)
  800606:	85 c9                	test   %ecx,%ecx
  800608:	74 2c                	je     800636 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80060a:	8b 45 14             	mov    0x14(%ebp),%eax
  80060d:	8b 10                	mov    (%eax),%edx
  80060f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800614:	8d 40 04             	lea    0x4(%eax),%eax
  800617:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80061a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80061f:	eb 62                	jmp    800683 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8b 10                	mov    (%eax),%edx
  800626:	8b 48 04             	mov    0x4(%eax),%ecx
  800629:	8d 40 08             	lea    0x8(%eax),%eax
  80062c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80062f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800634:	eb 4d                	jmp    800683 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8b 10                	mov    (%eax),%edx
  80063b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800640:	8d 40 04             	lea    0x4(%eax),%eax
  800643:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800646:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80064b:	eb 36                	jmp    800683 <vprintfmt+0x348>
	if (lflag >= 2)
  80064d:	83 f9 01             	cmp    $0x1,%ecx
  800650:	7f 17                	jg     800669 <vprintfmt+0x32e>
	else if (lflag)
  800652:	85 c9                	test   %ecx,%ecx
  800654:	74 6e                	je     8006c4 <vprintfmt+0x389>
		return va_arg(*ap, long);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8b 10                	mov    (%eax),%edx
  80065b:	89 d0                	mov    %edx,%eax
  80065d:	99                   	cltd   
  80065e:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800661:	8d 49 04             	lea    0x4(%ecx),%ecx
  800664:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800667:	eb 11                	jmp    80067a <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8b 50 04             	mov    0x4(%eax),%edx
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800674:	8d 49 08             	lea    0x8(%ecx),%ecx
  800677:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80067a:	89 d1                	mov    %edx,%ecx
  80067c:	89 c2                	mov    %eax,%edx
            base = 8;
  80067e:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800683:	83 ec 0c             	sub    $0xc,%esp
  800686:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80068a:	57                   	push   %edi
  80068b:	ff 75 e0             	pushl  -0x20(%ebp)
  80068e:	50                   	push   %eax
  80068f:	51                   	push   %ecx
  800690:	52                   	push   %edx
  800691:	89 da                	mov    %ebx,%edx
  800693:	89 f0                	mov    %esi,%eax
  800695:	e8 b6 fb ff ff       	call   800250 <printnum>
			break;
  80069a:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80069d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006a0:	83 c7 01             	add    $0x1,%edi
  8006a3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006a7:	83 f8 25             	cmp    $0x25,%eax
  8006aa:	0f 84 a6 fc ff ff    	je     800356 <vprintfmt+0x1b>
			if (ch == '\0')
  8006b0:	85 c0                	test   %eax,%eax
  8006b2:	0f 84 ce 00 00 00    	je     800786 <vprintfmt+0x44b>
			putch(ch, putdat);
  8006b8:	83 ec 08             	sub    $0x8,%esp
  8006bb:	53                   	push   %ebx
  8006bc:	50                   	push   %eax
  8006bd:	ff d6                	call   *%esi
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	eb dc                	jmp    8006a0 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8b 10                	mov    (%eax),%edx
  8006c9:	89 d0                	mov    %edx,%eax
  8006cb:	99                   	cltd   
  8006cc:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006cf:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006d2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006d5:	eb a3                	jmp    80067a <vprintfmt+0x33f>
			putch('0', putdat);
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	53                   	push   %ebx
  8006db:	6a 30                	push   $0x30
  8006dd:	ff d6                	call   *%esi
			putch('x', putdat);
  8006df:	83 c4 08             	add    $0x8,%esp
  8006e2:	53                   	push   %ebx
  8006e3:	6a 78                	push   $0x78
  8006e5:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8b 10                	mov    (%eax),%edx
  8006ec:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006f1:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006f4:	8d 40 04             	lea    0x4(%eax),%eax
  8006f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006fa:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006ff:	eb 82                	jmp    800683 <vprintfmt+0x348>
	if (lflag >= 2)
  800701:	83 f9 01             	cmp    $0x1,%ecx
  800704:	7f 1e                	jg     800724 <vprintfmt+0x3e9>
	else if (lflag)
  800706:	85 c9                	test   %ecx,%ecx
  800708:	74 32                	je     80073c <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8b 10                	mov    (%eax),%edx
  80070f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800714:	8d 40 04             	lea    0x4(%eax),%eax
  800717:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80071f:	e9 5f ff ff ff       	jmp    800683 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800724:	8b 45 14             	mov    0x14(%ebp),%eax
  800727:	8b 10                	mov    (%eax),%edx
  800729:	8b 48 04             	mov    0x4(%eax),%ecx
  80072c:	8d 40 08             	lea    0x8(%eax),%eax
  80072f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800732:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800737:	e9 47 ff ff ff       	jmp    800683 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80073c:	8b 45 14             	mov    0x14(%ebp),%eax
  80073f:	8b 10                	mov    (%eax),%edx
  800741:	b9 00 00 00 00       	mov    $0x0,%ecx
  800746:	8d 40 04             	lea    0x4(%eax),%eax
  800749:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80074c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800751:	e9 2d ff ff ff       	jmp    800683 <vprintfmt+0x348>
			putch(ch, putdat);
  800756:	83 ec 08             	sub    $0x8,%esp
  800759:	53                   	push   %ebx
  80075a:	6a 25                	push   $0x25
  80075c:	ff d6                	call   *%esi
			break;
  80075e:	83 c4 10             	add    $0x10,%esp
  800761:	e9 37 ff ff ff       	jmp    80069d <vprintfmt+0x362>
			putch('%', putdat);
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	53                   	push   %ebx
  80076a:	6a 25                	push   $0x25
  80076c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80076e:	83 c4 10             	add    $0x10,%esp
  800771:	89 f8                	mov    %edi,%eax
  800773:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800777:	74 05                	je     80077e <vprintfmt+0x443>
  800779:	83 e8 01             	sub    $0x1,%eax
  80077c:	eb f5                	jmp    800773 <vprintfmt+0x438>
  80077e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800781:	e9 17 ff ff ff       	jmp    80069d <vprintfmt+0x362>
}
  800786:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800789:	5b                   	pop    %ebx
  80078a:	5e                   	pop    %esi
  80078b:	5f                   	pop    %edi
  80078c:	5d                   	pop    %ebp
  80078d:	c3                   	ret    

0080078e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80078e:	f3 0f 1e fb          	endbr32 
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	83 ec 18             	sub    $0x18,%esp
  800798:	8b 45 08             	mov    0x8(%ebp),%eax
  80079b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80079e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	74 26                	je     8007d9 <vsnprintf+0x4b>
  8007b3:	85 d2                	test   %edx,%edx
  8007b5:	7e 22                	jle    8007d9 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b7:	ff 75 14             	pushl  0x14(%ebp)
  8007ba:	ff 75 10             	pushl  0x10(%ebp)
  8007bd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c0:	50                   	push   %eax
  8007c1:	68 f9 02 80 00       	push   $0x8002f9
  8007c6:	e8 70 fb ff ff       	call   80033b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ce:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d4:	83 c4 10             	add    $0x10,%esp
}
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    
		return -E_INVAL;
  8007d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007de:	eb f7                	jmp    8007d7 <vsnprintf+0x49>

008007e0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e0:	f3 0f 1e fb          	endbr32 
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ea:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ed:	50                   	push   %eax
  8007ee:	ff 75 10             	pushl  0x10(%ebp)
  8007f1:	ff 75 0c             	pushl  0xc(%ebp)
  8007f4:	ff 75 08             	pushl  0x8(%ebp)
  8007f7:	e8 92 ff ff ff       	call   80078e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007fe:	f3 0f 1e fb          	endbr32 
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800808:	b8 00 00 00 00       	mov    $0x0,%eax
  80080d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800811:	74 05                	je     800818 <strlen+0x1a>
		n++;
  800813:	83 c0 01             	add    $0x1,%eax
  800816:	eb f5                	jmp    80080d <strlen+0xf>
	return n;
}
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80081a:	f3 0f 1e fb          	endbr32 
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800824:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800827:	b8 00 00 00 00       	mov    $0x0,%eax
  80082c:	39 d0                	cmp    %edx,%eax
  80082e:	74 0d                	je     80083d <strnlen+0x23>
  800830:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800834:	74 05                	je     80083b <strnlen+0x21>
		n++;
  800836:	83 c0 01             	add    $0x1,%eax
  800839:	eb f1                	jmp    80082c <strnlen+0x12>
  80083b:	89 c2                	mov    %eax,%edx
	return n;
}
  80083d:	89 d0                	mov    %edx,%eax
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800841:	f3 0f 1e fb          	endbr32 
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	53                   	push   %ebx
  800849:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80084f:	b8 00 00 00 00       	mov    $0x0,%eax
  800854:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800858:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80085b:	83 c0 01             	add    $0x1,%eax
  80085e:	84 d2                	test   %dl,%dl
  800860:	75 f2                	jne    800854 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800862:	89 c8                	mov    %ecx,%eax
  800864:	5b                   	pop    %ebx
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800867:	f3 0f 1e fb          	endbr32 
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	53                   	push   %ebx
  80086f:	83 ec 10             	sub    $0x10,%esp
  800872:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800875:	53                   	push   %ebx
  800876:	e8 83 ff ff ff       	call   8007fe <strlen>
  80087b:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80087e:	ff 75 0c             	pushl  0xc(%ebp)
  800881:	01 d8                	add    %ebx,%eax
  800883:	50                   	push   %eax
  800884:	e8 b8 ff ff ff       	call   800841 <strcpy>
	return dst;
}
  800889:	89 d8                	mov    %ebx,%eax
  80088b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088e:	c9                   	leave  
  80088f:	c3                   	ret    

00800890 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800890:	f3 0f 1e fb          	endbr32 
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	56                   	push   %esi
  800898:	53                   	push   %ebx
  800899:	8b 75 08             	mov    0x8(%ebp),%esi
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089f:	89 f3                	mov    %esi,%ebx
  8008a1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a4:	89 f0                	mov    %esi,%eax
  8008a6:	39 d8                	cmp    %ebx,%eax
  8008a8:	74 11                	je     8008bb <strncpy+0x2b>
		*dst++ = *src;
  8008aa:	83 c0 01             	add    $0x1,%eax
  8008ad:	0f b6 0a             	movzbl (%edx),%ecx
  8008b0:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b3:	80 f9 01             	cmp    $0x1,%cl
  8008b6:	83 da ff             	sbb    $0xffffffff,%edx
  8008b9:	eb eb                	jmp    8008a6 <strncpy+0x16>
	}
	return ret;
}
  8008bb:	89 f0                	mov    %esi,%eax
  8008bd:	5b                   	pop    %ebx
  8008be:	5e                   	pop    %esi
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c1:	f3 0f 1e fb          	endbr32 
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	56                   	push   %esi
  8008c9:	53                   	push   %ebx
  8008ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8008cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d0:	8b 55 10             	mov    0x10(%ebp),%edx
  8008d3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d5:	85 d2                	test   %edx,%edx
  8008d7:	74 21                	je     8008fa <strlcpy+0x39>
  8008d9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008dd:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008df:	39 c2                	cmp    %eax,%edx
  8008e1:	74 14                	je     8008f7 <strlcpy+0x36>
  8008e3:	0f b6 19             	movzbl (%ecx),%ebx
  8008e6:	84 db                	test   %bl,%bl
  8008e8:	74 0b                	je     8008f5 <strlcpy+0x34>
			*dst++ = *src++;
  8008ea:	83 c1 01             	add    $0x1,%ecx
  8008ed:	83 c2 01             	add    $0x1,%edx
  8008f0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008f3:	eb ea                	jmp    8008df <strlcpy+0x1e>
  8008f5:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008f7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008fa:	29 f0                	sub    %esi,%eax
}
  8008fc:	5b                   	pop    %ebx
  8008fd:	5e                   	pop    %esi
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800900:	f3 0f 1e fb          	endbr32 
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80090d:	0f b6 01             	movzbl (%ecx),%eax
  800910:	84 c0                	test   %al,%al
  800912:	74 0c                	je     800920 <strcmp+0x20>
  800914:	3a 02                	cmp    (%edx),%al
  800916:	75 08                	jne    800920 <strcmp+0x20>
		p++, q++;
  800918:	83 c1 01             	add    $0x1,%ecx
  80091b:	83 c2 01             	add    $0x1,%edx
  80091e:	eb ed                	jmp    80090d <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800920:	0f b6 c0             	movzbl %al,%eax
  800923:	0f b6 12             	movzbl (%edx),%edx
  800926:	29 d0                	sub    %edx,%eax
}
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80092a:	f3 0f 1e fb          	endbr32 
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	53                   	push   %ebx
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	8b 55 0c             	mov    0xc(%ebp),%edx
  800938:	89 c3                	mov    %eax,%ebx
  80093a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80093d:	eb 06                	jmp    800945 <strncmp+0x1b>
		n--, p++, q++;
  80093f:	83 c0 01             	add    $0x1,%eax
  800942:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800945:	39 d8                	cmp    %ebx,%eax
  800947:	74 16                	je     80095f <strncmp+0x35>
  800949:	0f b6 08             	movzbl (%eax),%ecx
  80094c:	84 c9                	test   %cl,%cl
  80094e:	74 04                	je     800954 <strncmp+0x2a>
  800950:	3a 0a                	cmp    (%edx),%cl
  800952:	74 eb                	je     80093f <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800954:	0f b6 00             	movzbl (%eax),%eax
  800957:	0f b6 12             	movzbl (%edx),%edx
  80095a:	29 d0                	sub    %edx,%eax
}
  80095c:	5b                   	pop    %ebx
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    
		return 0;
  80095f:	b8 00 00 00 00       	mov    $0x0,%eax
  800964:	eb f6                	jmp    80095c <strncmp+0x32>

00800966 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800966:	f3 0f 1e fb          	endbr32 
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800974:	0f b6 10             	movzbl (%eax),%edx
  800977:	84 d2                	test   %dl,%dl
  800979:	74 09                	je     800984 <strchr+0x1e>
		if (*s == c)
  80097b:	38 ca                	cmp    %cl,%dl
  80097d:	74 0a                	je     800989 <strchr+0x23>
	for (; *s; s++)
  80097f:	83 c0 01             	add    $0x1,%eax
  800982:	eb f0                	jmp    800974 <strchr+0xe>
			return (char *) s;
	return 0;
  800984:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098b:	f3 0f 1e fb          	endbr32 
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800999:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80099c:	38 ca                	cmp    %cl,%dl
  80099e:	74 09                	je     8009a9 <strfind+0x1e>
  8009a0:	84 d2                	test   %dl,%dl
  8009a2:	74 05                	je     8009a9 <strfind+0x1e>
	for (; *s; s++)
  8009a4:	83 c0 01             	add    $0x1,%eax
  8009a7:	eb f0                	jmp    800999 <strfind+0xe>
			break;
	return (char *) s;
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009ab:	f3 0f 1e fb          	endbr32 
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	57                   	push   %edi
  8009b3:	56                   	push   %esi
  8009b4:	53                   	push   %ebx
  8009b5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009bb:	85 c9                	test   %ecx,%ecx
  8009bd:	74 31                	je     8009f0 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009bf:	89 f8                	mov    %edi,%eax
  8009c1:	09 c8                	or     %ecx,%eax
  8009c3:	a8 03                	test   $0x3,%al
  8009c5:	75 23                	jne    8009ea <memset+0x3f>
		c &= 0xFF;
  8009c7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009cb:	89 d3                	mov    %edx,%ebx
  8009cd:	c1 e3 08             	shl    $0x8,%ebx
  8009d0:	89 d0                	mov    %edx,%eax
  8009d2:	c1 e0 18             	shl    $0x18,%eax
  8009d5:	89 d6                	mov    %edx,%esi
  8009d7:	c1 e6 10             	shl    $0x10,%esi
  8009da:	09 f0                	or     %esi,%eax
  8009dc:	09 c2                	or     %eax,%edx
  8009de:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009e0:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009e3:	89 d0                	mov    %edx,%eax
  8009e5:	fc                   	cld    
  8009e6:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e8:	eb 06                	jmp    8009f0 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ed:	fc                   	cld    
  8009ee:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009f0:	89 f8                	mov    %edi,%eax
  8009f2:	5b                   	pop    %ebx
  8009f3:	5e                   	pop    %esi
  8009f4:	5f                   	pop    %edi
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f7:	f3 0f 1e fb          	endbr32 
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	57                   	push   %edi
  8009ff:	56                   	push   %esi
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a06:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a09:	39 c6                	cmp    %eax,%esi
  800a0b:	73 32                	jae    800a3f <memmove+0x48>
  800a0d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a10:	39 c2                	cmp    %eax,%edx
  800a12:	76 2b                	jbe    800a3f <memmove+0x48>
		s += n;
		d += n;
  800a14:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a17:	89 fe                	mov    %edi,%esi
  800a19:	09 ce                	or     %ecx,%esi
  800a1b:	09 d6                	or     %edx,%esi
  800a1d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a23:	75 0e                	jne    800a33 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a25:	83 ef 04             	sub    $0x4,%edi
  800a28:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a2b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a2e:	fd                   	std    
  800a2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a31:	eb 09                	jmp    800a3c <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a33:	83 ef 01             	sub    $0x1,%edi
  800a36:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a39:	fd                   	std    
  800a3a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a3c:	fc                   	cld    
  800a3d:	eb 1a                	jmp    800a59 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3f:	89 c2                	mov    %eax,%edx
  800a41:	09 ca                	or     %ecx,%edx
  800a43:	09 f2                	or     %esi,%edx
  800a45:	f6 c2 03             	test   $0x3,%dl
  800a48:	75 0a                	jne    800a54 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a4a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a4d:	89 c7                	mov    %eax,%edi
  800a4f:	fc                   	cld    
  800a50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a52:	eb 05                	jmp    800a59 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a54:	89 c7                	mov    %eax,%edi
  800a56:	fc                   	cld    
  800a57:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a59:	5e                   	pop    %esi
  800a5a:	5f                   	pop    %edi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5d:	f3 0f 1e fb          	endbr32 
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a67:	ff 75 10             	pushl  0x10(%ebp)
  800a6a:	ff 75 0c             	pushl  0xc(%ebp)
  800a6d:	ff 75 08             	pushl  0x8(%ebp)
  800a70:	e8 82 ff ff ff       	call   8009f7 <memmove>
}
  800a75:	c9                   	leave  
  800a76:	c3                   	ret    

00800a77 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a77:	f3 0f 1e fb          	endbr32 
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a86:	89 c6                	mov    %eax,%esi
  800a88:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8b:	39 f0                	cmp    %esi,%eax
  800a8d:	74 1c                	je     800aab <memcmp+0x34>
		if (*s1 != *s2)
  800a8f:	0f b6 08             	movzbl (%eax),%ecx
  800a92:	0f b6 1a             	movzbl (%edx),%ebx
  800a95:	38 d9                	cmp    %bl,%cl
  800a97:	75 08                	jne    800aa1 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a99:	83 c0 01             	add    $0x1,%eax
  800a9c:	83 c2 01             	add    $0x1,%edx
  800a9f:	eb ea                	jmp    800a8b <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800aa1:	0f b6 c1             	movzbl %cl,%eax
  800aa4:	0f b6 db             	movzbl %bl,%ebx
  800aa7:	29 d8                	sub    %ebx,%eax
  800aa9:	eb 05                	jmp    800ab0 <memcmp+0x39>
	}

	return 0;
  800aab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab4:	f3 0f 1e fb          	endbr32 
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
  800abb:	8b 45 08             	mov    0x8(%ebp),%eax
  800abe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ac1:	89 c2                	mov    %eax,%edx
  800ac3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ac6:	39 d0                	cmp    %edx,%eax
  800ac8:	73 09                	jae    800ad3 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aca:	38 08                	cmp    %cl,(%eax)
  800acc:	74 05                	je     800ad3 <memfind+0x1f>
	for (; s < ends; s++)
  800ace:	83 c0 01             	add    $0x1,%eax
  800ad1:	eb f3                	jmp    800ac6 <memfind+0x12>
			break;
	return (void *) s;
}
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ad5:	f3 0f 1e fb          	endbr32 
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	57                   	push   %edi
  800add:	56                   	push   %esi
  800ade:	53                   	push   %ebx
  800adf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae5:	eb 03                	jmp    800aea <strtol+0x15>
		s++;
  800ae7:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800aea:	0f b6 01             	movzbl (%ecx),%eax
  800aed:	3c 20                	cmp    $0x20,%al
  800aef:	74 f6                	je     800ae7 <strtol+0x12>
  800af1:	3c 09                	cmp    $0x9,%al
  800af3:	74 f2                	je     800ae7 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800af5:	3c 2b                	cmp    $0x2b,%al
  800af7:	74 2a                	je     800b23 <strtol+0x4e>
	int neg = 0;
  800af9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800afe:	3c 2d                	cmp    $0x2d,%al
  800b00:	74 2b                	je     800b2d <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b02:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b08:	75 0f                	jne    800b19 <strtol+0x44>
  800b0a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b0d:	74 28                	je     800b37 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b0f:	85 db                	test   %ebx,%ebx
  800b11:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b16:	0f 44 d8             	cmove  %eax,%ebx
  800b19:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b21:	eb 46                	jmp    800b69 <strtol+0x94>
		s++;
  800b23:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b26:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2b:	eb d5                	jmp    800b02 <strtol+0x2d>
		s++, neg = 1;
  800b2d:	83 c1 01             	add    $0x1,%ecx
  800b30:	bf 01 00 00 00       	mov    $0x1,%edi
  800b35:	eb cb                	jmp    800b02 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b37:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b3b:	74 0e                	je     800b4b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b3d:	85 db                	test   %ebx,%ebx
  800b3f:	75 d8                	jne    800b19 <strtol+0x44>
		s++, base = 8;
  800b41:	83 c1 01             	add    $0x1,%ecx
  800b44:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b49:	eb ce                	jmp    800b19 <strtol+0x44>
		s += 2, base = 16;
  800b4b:	83 c1 02             	add    $0x2,%ecx
  800b4e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b53:	eb c4                	jmp    800b19 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b55:	0f be d2             	movsbl %dl,%edx
  800b58:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b5b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b5e:	7d 3a                	jge    800b9a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b60:	83 c1 01             	add    $0x1,%ecx
  800b63:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b67:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b69:	0f b6 11             	movzbl (%ecx),%edx
  800b6c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b6f:	89 f3                	mov    %esi,%ebx
  800b71:	80 fb 09             	cmp    $0x9,%bl
  800b74:	76 df                	jbe    800b55 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b76:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b79:	89 f3                	mov    %esi,%ebx
  800b7b:	80 fb 19             	cmp    $0x19,%bl
  800b7e:	77 08                	ja     800b88 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b80:	0f be d2             	movsbl %dl,%edx
  800b83:	83 ea 57             	sub    $0x57,%edx
  800b86:	eb d3                	jmp    800b5b <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b88:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b8b:	89 f3                	mov    %esi,%ebx
  800b8d:	80 fb 19             	cmp    $0x19,%bl
  800b90:	77 08                	ja     800b9a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b92:	0f be d2             	movsbl %dl,%edx
  800b95:	83 ea 37             	sub    $0x37,%edx
  800b98:	eb c1                	jmp    800b5b <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b9a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b9e:	74 05                	je     800ba5 <strtol+0xd0>
		*endptr = (char *) s;
  800ba0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba3:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ba5:	89 c2                	mov    %eax,%edx
  800ba7:	f7 da                	neg    %edx
  800ba9:	85 ff                	test   %edi,%edi
  800bab:	0f 45 c2             	cmovne %edx,%eax
}
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb3:	f3 0f 1e fb          	endbr32 
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc8:	89 c3                	mov    %eax,%ebx
  800bca:	89 c7                	mov    %eax,%edi
  800bcc:	89 c6                	mov    %eax,%esi
  800bce:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bd5:	f3 0f 1e fb          	endbr32 
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bdf:	ba 00 00 00 00       	mov    $0x0,%edx
  800be4:	b8 01 00 00 00       	mov    $0x1,%eax
  800be9:	89 d1                	mov    %edx,%ecx
  800beb:	89 d3                	mov    %edx,%ebx
  800bed:	89 d7                	mov    %edx,%edi
  800bef:	89 d6                	mov    %edx,%esi
  800bf1:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bf3:	5b                   	pop    %ebx
  800bf4:	5e                   	pop    %esi
  800bf5:	5f                   	pop    %edi
  800bf6:	5d                   	pop    %ebp
  800bf7:	c3                   	ret    

00800bf8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bf8:	f3 0f 1e fb          	endbr32 
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c05:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0d:	b8 03 00 00 00       	mov    $0x3,%eax
  800c12:	89 cb                	mov    %ecx,%ebx
  800c14:	89 cf                	mov    %ecx,%edi
  800c16:	89 ce                	mov    %ecx,%esi
  800c18:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	7f 08                	jg     800c26 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c26:	83 ec 0c             	sub    $0xc,%esp
  800c29:	50                   	push   %eax
  800c2a:	6a 03                	push   $0x3
  800c2c:	68 9f 17 80 00       	push   $0x80179f
  800c31:	6a 23                	push   $0x23
  800c33:	68 bc 17 80 00       	push   $0x8017bc
  800c38:	e8 14 f5 ff ff       	call   800151 <_panic>

00800c3d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c3d:	f3 0f 1e fb          	endbr32 
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c47:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4c:	b8 02 00 00 00       	mov    $0x2,%eax
  800c51:	89 d1                	mov    %edx,%ecx
  800c53:	89 d3                	mov    %edx,%ebx
  800c55:	89 d7                	mov    %edx,%edi
  800c57:	89 d6                	mov    %edx,%esi
  800c59:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_yield>:

void
sys_yield(void)
{
  800c60:	f3 0f 1e fb          	endbr32 
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c74:	89 d1                	mov    %edx,%ecx
  800c76:	89 d3                	mov    %edx,%ebx
  800c78:	89 d7                	mov    %edx,%edi
  800c7a:	89 d6                	mov    %edx,%esi
  800c7c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c83:	f3 0f 1e fb          	endbr32 
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c90:	be 00 00 00 00       	mov    $0x0,%esi
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca3:	89 f7                	mov    %esi,%edi
  800ca5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7f 08                	jg     800cb3 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cae:	5b                   	pop    %ebx
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb3:	83 ec 0c             	sub    $0xc,%esp
  800cb6:	50                   	push   %eax
  800cb7:	6a 04                	push   $0x4
  800cb9:	68 9f 17 80 00       	push   $0x80179f
  800cbe:	6a 23                	push   $0x23
  800cc0:	68 bc 17 80 00       	push   $0x8017bc
  800cc5:	e8 87 f4 ff ff       	call   800151 <_panic>

00800cca <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cca:	f3 0f 1e fb          	endbr32 
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
  800cd4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdd:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce8:	8b 75 18             	mov    0x18(%ebp),%esi
  800ceb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ced:	85 c0                	test   %eax,%eax
  800cef:	7f 08                	jg     800cf9 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf9:	83 ec 0c             	sub    $0xc,%esp
  800cfc:	50                   	push   %eax
  800cfd:	6a 05                	push   $0x5
  800cff:	68 9f 17 80 00       	push   $0x80179f
  800d04:	6a 23                	push   $0x23
  800d06:	68 bc 17 80 00       	push   $0x8017bc
  800d0b:	e8 41 f4 ff ff       	call   800151 <_panic>

00800d10 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d10:	f3 0f 1e fb          	endbr32 
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
  800d1a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d28:	b8 06 00 00 00       	mov    $0x6,%eax
  800d2d:	89 df                	mov    %ebx,%edi
  800d2f:	89 de                	mov    %ebx,%esi
  800d31:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d33:	85 c0                	test   %eax,%eax
  800d35:	7f 08                	jg     800d3f <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3a:	5b                   	pop    %ebx
  800d3b:	5e                   	pop    %esi
  800d3c:	5f                   	pop    %edi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	50                   	push   %eax
  800d43:	6a 06                	push   $0x6
  800d45:	68 9f 17 80 00       	push   $0x80179f
  800d4a:	6a 23                	push   $0x23
  800d4c:	68 bc 17 80 00       	push   $0x8017bc
  800d51:	e8 fb f3 ff ff       	call   800151 <_panic>

00800d56 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d56:	f3 0f 1e fb          	endbr32 
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
  800d60:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6e:	b8 08 00 00 00       	mov    $0x8,%eax
  800d73:	89 df                	mov    %ebx,%edi
  800d75:	89 de                	mov    %ebx,%esi
  800d77:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7f 08                	jg     800d85 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d85:	83 ec 0c             	sub    $0xc,%esp
  800d88:	50                   	push   %eax
  800d89:	6a 08                	push   $0x8
  800d8b:	68 9f 17 80 00       	push   $0x80179f
  800d90:	6a 23                	push   $0x23
  800d92:	68 bc 17 80 00       	push   $0x8017bc
  800d97:	e8 b5 f3 ff ff       	call   800151 <_panic>

00800d9c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d9c:	f3 0f 1e fb          	endbr32 
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dae:	8b 55 08             	mov    0x8(%ebp),%edx
  800db1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db4:	b8 09 00 00 00       	mov    $0x9,%eax
  800db9:	89 df                	mov    %ebx,%edi
  800dbb:	89 de                	mov    %ebx,%esi
  800dbd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7f 08                	jg     800dcb <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc6:	5b                   	pop    %ebx
  800dc7:	5e                   	pop    %esi
  800dc8:	5f                   	pop    %edi
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcb:	83 ec 0c             	sub    $0xc,%esp
  800dce:	50                   	push   %eax
  800dcf:	6a 09                	push   $0x9
  800dd1:	68 9f 17 80 00       	push   $0x80179f
  800dd6:	6a 23                	push   $0x23
  800dd8:	68 bc 17 80 00       	push   $0x8017bc
  800ddd:	e8 6f f3 ff ff       	call   800151 <_panic>

00800de2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de2:	f3 0f 1e fb          	endbr32 
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	57                   	push   %edi
  800dea:	56                   	push   %esi
  800deb:	53                   	push   %ebx
  800dec:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800def:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dff:	89 df                	mov    %ebx,%edi
  800e01:	89 de                	mov    %ebx,%esi
  800e03:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e05:	85 c0                	test   %eax,%eax
  800e07:	7f 08                	jg     800e11 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0c:	5b                   	pop    %ebx
  800e0d:	5e                   	pop    %esi
  800e0e:	5f                   	pop    %edi
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e11:	83 ec 0c             	sub    $0xc,%esp
  800e14:	50                   	push   %eax
  800e15:	6a 0a                	push   $0xa
  800e17:	68 9f 17 80 00       	push   $0x80179f
  800e1c:	6a 23                	push   $0x23
  800e1e:	68 bc 17 80 00       	push   $0x8017bc
  800e23:	e8 29 f3 ff ff       	call   800151 <_panic>

00800e28 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e28:	f3 0f 1e fb          	endbr32 
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	57                   	push   %edi
  800e30:	56                   	push   %esi
  800e31:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e32:	8b 55 08             	mov    0x8(%ebp),%edx
  800e35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e38:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e3d:	be 00 00 00 00       	mov    $0x0,%esi
  800e42:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e45:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e48:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e4a:	5b                   	pop    %ebx
  800e4b:	5e                   	pop    %esi
  800e4c:	5f                   	pop    %edi
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e4f:	f3 0f 1e fb          	endbr32 
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	57                   	push   %edi
  800e57:	56                   	push   %esi
  800e58:	53                   	push   %ebx
  800e59:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e5c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e61:	8b 55 08             	mov    0x8(%ebp),%edx
  800e64:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e69:	89 cb                	mov    %ecx,%ebx
  800e6b:	89 cf                	mov    %ecx,%edi
  800e6d:	89 ce                	mov    %ecx,%esi
  800e6f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e71:	85 c0                	test   %eax,%eax
  800e73:	7f 08                	jg     800e7d <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e78:	5b                   	pop    %ebx
  800e79:	5e                   	pop    %esi
  800e7a:	5f                   	pop    %edi
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7d:	83 ec 0c             	sub    $0xc,%esp
  800e80:	50                   	push   %eax
  800e81:	6a 0d                	push   $0xd
  800e83:	68 9f 17 80 00       	push   $0x80179f
  800e88:	6a 23                	push   $0x23
  800e8a:	68 bc 17 80 00       	push   $0x8017bc
  800e8f:	e8 bd f2 ff ff       	call   800151 <_panic>

00800e94 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e94:	f3 0f 1e fb          	endbr32 
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	53                   	push   %ebx
  800e9c:	83 ec 04             	sub    $0x4,%esp
  800e9f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ea2:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if ( !(err & FEC_WR) ||
  800ea4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ea8:	74 75                	je     800f1f <pgfault+0x8b>
            !(uvpt[PGNUM(addr)] | PTE_COW) ) {
  800eaa:	89 d8                	mov    %ebx,%eax
  800eac:	c1 e8 0c             	shr    $0xc,%eax
  800eaf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0) {
  800eb6:	83 ec 04             	sub    $0x4,%esp
  800eb9:	6a 07                	push   $0x7
  800ebb:	68 00 f0 7f 00       	push   $0x7ff000
  800ec0:	6a 00                	push   $0x0
  800ec2:	e8 bc fd ff ff       	call   800c83 <sys_page_alloc>
  800ec7:	83 c4 10             	add    $0x10,%esp
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	78 65                	js     800f33 <pgfault+0x9f>
        panic("sys_page_alloc failed %e\n", r);
    }
    memmove((void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);
  800ece:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800ed4:	83 ec 04             	sub    $0x4,%esp
  800ed7:	68 00 10 00 00       	push   $0x1000
  800edc:	53                   	push   %ebx
  800edd:	68 00 f0 7f 00       	push   $0x7ff000
  800ee2:	e8 10 fb ff ff       	call   8009f7 <memmove>
    if ((r = sys_page_map(0, (void *)PFTEMP,
  800ee7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eee:	53                   	push   %ebx
  800eef:	6a 00                	push   $0x0
  800ef1:	68 00 f0 7f 00       	push   $0x7ff000
  800ef6:	6a 00                	push   $0x0
  800ef8:	e8 cd fd ff ff       	call   800cca <sys_page_map>
  800efd:	83 c4 20             	add    $0x20,%esp
  800f00:	85 c0                	test   %eax,%eax
  800f02:	78 41                	js     800f45 <pgfault+0xb1>
                0, (void *)PTE_ADDR(addr), PTE_P | PTE_U | PTE_W)) < 0) {
        panic("sys_page_map failed %e\n", r);
    }
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0) {
  800f04:	83 ec 08             	sub    $0x8,%esp
  800f07:	68 00 f0 7f 00       	push   $0x7ff000
  800f0c:	6a 00                	push   $0x0
  800f0e:	e8 fd fd ff ff       	call   800d10 <sys_page_unmap>
  800f13:	83 c4 10             	add    $0x10,%esp
  800f16:	85 c0                	test   %eax,%eax
  800f18:	78 3d                	js     800f57 <pgfault+0xc3>
        panic("sys_page_unmap failed %e\n", r);
    }

}
  800f1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1d:	c9                   	leave  
  800f1e:	c3                   	ret    
        panic("Not a copy-on-write page");
  800f1f:	83 ec 04             	sub    $0x4,%esp
  800f22:	68 ca 17 80 00       	push   $0x8017ca
  800f27:	6a 1e                	push   $0x1e
  800f29:	68 e3 17 80 00       	push   $0x8017e3
  800f2e:	e8 1e f2 ff ff       	call   800151 <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800f33:	50                   	push   %eax
  800f34:	68 ee 17 80 00       	push   $0x8017ee
  800f39:	6a 2a                	push   $0x2a
  800f3b:	68 e3 17 80 00       	push   $0x8017e3
  800f40:	e8 0c f2 ff ff       	call   800151 <_panic>
        panic("sys_page_map failed %e\n", r);
  800f45:	50                   	push   %eax
  800f46:	68 08 18 80 00       	push   $0x801808
  800f4b:	6a 2f                	push   $0x2f
  800f4d:	68 e3 17 80 00       	push   $0x8017e3
  800f52:	e8 fa f1 ff ff       	call   800151 <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800f57:	50                   	push   %eax
  800f58:	68 20 18 80 00       	push   $0x801820
  800f5d:	6a 32                	push   $0x32
  800f5f:	68 e3 17 80 00       	push   $0x8017e3
  800f64:	e8 e8 f1 ff ff       	call   800151 <_panic>

00800f69 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f69:	f3 0f 1e fb          	endbr32 
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	57                   	push   %edi
  800f71:	56                   	push   %esi
  800f72:	53                   	push   %ebx
  800f73:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");

    // 1. set pgfault handler.
    set_pgfault_handler(pgfault);
  800f76:	68 94 0e 80 00       	push   $0x800e94
  800f7b:	e8 93 01 00 00       	call   801113 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f80:	b8 07 00 00 00       	mov    $0x7,%eax
  800f85:	cd 30                	int    $0x30
  800f87:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 2. exofork.
    envid_t envid = sys_exofork();

    if (envid < 0)
  800f8d:	83 c4 10             	add    $0x10,%esp
  800f90:	85 c0                	test   %eax,%eax
  800f92:	78 2a                	js     800fbe <fork+0x55>
        thisenv = &envs[ENVX(my_envid)];
        return 0;
    }
    else {
        // parent
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f94:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800f99:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f9d:	75 63                	jne    801002 <fork+0x99>
        envid_t my_envid = sys_getenvid();
  800f9f:	e8 99 fc ff ff       	call   800c3d <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800fa4:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fa9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fac:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fb1:	a3 08 20 80 00       	mov    %eax,0x802008
        return 0;
  800fb6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fb9:	e9 2f 01 00 00       	jmp    8010ed <fork+0x184>
        panic("fork, sys_exofork %e", envid);
  800fbe:	50                   	push   %eax
  800fbf:	68 3a 18 80 00       	push   $0x80183a
  800fc4:	68 82 00 00 00       	push   $0x82
  800fc9:	68 e3 17 80 00       	push   $0x8017e3
  800fce:	e8 7e f1 ff ff       	call   800151 <_panic>
    	if ((r = sys_page_map(0, addr, envid, addr, pte & PTE_SYSCALL)) < 0) {
  800fd3:	83 ec 0c             	sub    $0xc,%esp
  800fd6:	25 07 0e 00 00       	and    $0xe07,%eax
  800fdb:	50                   	push   %eax
  800fdc:	56                   	push   %esi
  800fdd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fe0:	56                   	push   %esi
  800fe1:	6a 00                	push   $0x0
  800fe3:	e8 e2 fc ff ff       	call   800cca <sys_page_map>
  800fe8:	83 c4 20             	add    $0x20,%esp
  800feb:	85 c0                	test   %eax,%eax
  800fed:	0f 88 90 00 00 00    	js     801083 <fork+0x11a>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800ff3:	83 c3 01             	add    $0x1,%ebx
  800ff6:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800ffc:	0f 84 a5 00 00 00    	je     8010a7 <fork+0x13e>
  801002:	89 de                	mov    %ebx,%esi
  801004:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  801007:	89 f0                	mov    %esi,%eax
  801009:	c1 e8 16             	shr    $0x16,%eax
  80100c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801013:	a8 01                	test   $0x1,%al
  801015:	74 dc                	je     800ff3 <fork+0x8a>
                    (uvpt[pn] & PTE_P) ) {
  801017:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  80101e:	a8 01                	test   $0x1,%al
  801020:	74 d1                	je     800ff3 <fork+0x8a>
    pte_t pte = uvpt[pn];
  801022:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    if ( pte & PTE_SHARE) {
  801029:	f6 c4 04             	test   $0x4,%ah
  80102c:	75 a5                	jne    800fd3 <fork+0x6a>
    if ( ((pte & PTE_W) || (pte & PTE_COW)) && !(pte & PTE_SHARE)) {
  80102e:	25 02 08 00 00       	and    $0x802,%eax
        perm |= PTE_COW;
  801033:	83 f8 01             	cmp    $0x1,%eax
  801036:	19 ff                	sbb    %edi,%edi
  801038:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  80103e:	81 c7 05 08 00 00    	add    $0x805,%edi
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  801044:	83 ec 0c             	sub    $0xc,%esp
  801047:	57                   	push   %edi
  801048:	56                   	push   %esi
  801049:	ff 75 e4             	pushl  -0x1c(%ebp)
  80104c:	56                   	push   %esi
  80104d:	6a 00                	push   $0x0
  80104f:	e8 76 fc ff ff       	call   800cca <sys_page_map>
  801054:	83 c4 20             	add    $0x20,%esp
  801057:	85 c0                	test   %eax,%eax
  801059:	78 3a                	js     801095 <fork+0x12c>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	57                   	push   %edi
  80105f:	56                   	push   %esi
  801060:	6a 00                	push   $0x0
  801062:	56                   	push   %esi
  801063:	6a 00                	push   $0x0
  801065:	e8 60 fc ff ff       	call   800cca <sys_page_map>
  80106a:	83 c4 20             	add    $0x20,%esp
  80106d:	85 c0                	test   %eax,%eax
  80106f:	79 82                	jns    800ff3 <fork+0x8a>
            panic("sys_page_map mine failed %e\n", r);
  801071:	50                   	push   %eax
  801072:	68 4f 18 80 00       	push   $0x80184f
  801077:	6a 5d                	push   $0x5d
  801079:	68 e3 17 80 00       	push   $0x8017e3
  80107e:	e8 ce f0 ff ff       	call   800151 <_panic>
    	    panic("sys_page_map others failed %e\n", r);
  801083:	50                   	push   %eax
  801084:	68 84 18 80 00       	push   $0x801884
  801089:	6a 4d                	push   $0x4d
  80108b:	68 e3 17 80 00       	push   $0x8017e3
  801090:	e8 bc f0 ff ff       	call   800151 <_panic>
        panic("sys_page_map others failed %e\n", r);
  801095:	50                   	push   %eax
  801096:	68 84 18 80 00       	push   $0x801884
  80109b:	6a 58                	push   $0x58
  80109d:	68 e3 17 80 00       	push   $0x8017e3
  8010a2:	e8 aa f0 ff ff       	call   800151 <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  8010a7:	83 ec 04             	sub    $0x4,%esp
  8010aa:	6a 07                	push   $0x7
  8010ac:	68 00 f0 bf ee       	push   $0xeebff000
  8010b1:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8010b4:	57                   	push   %edi
  8010b5:	e8 c9 fb ff ff       	call   800c83 <sys_page_alloc>
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	78 2c                	js     8010ed <fork+0x184>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  8010c1:	a1 08 20 80 00       	mov    0x802008,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  8010c6:	8b 40 64             	mov    0x64(%eax),%eax
  8010c9:	83 ec 08             	sub    $0x8,%esp
  8010cc:	50                   	push   %eax
  8010cd:	57                   	push   %edi
  8010ce:	e8 0f fd ff ff       	call   800de2 <sys_env_set_pgfault_upcall>
  8010d3:	83 c4 10             	add    $0x10,%esp
  8010d6:	85 c0                	test   %eax,%eax
  8010d8:	78 13                	js     8010ed <fork+0x184>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8010da:	83 ec 08             	sub    $0x8,%esp
  8010dd:	6a 02                	push   $0x2
  8010df:	57                   	push   %edi
  8010e0:	e8 71 fc ff ff       	call   800d56 <sys_env_set_status>
  8010e5:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  8010e8:	85 c0                	test   %eax,%eax
  8010ea:	0f 49 c7             	cmovns %edi,%eax
    }

}
  8010ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <sfork>:

// Challenge!
int
sfork(void)
{
  8010f5:	f3 0f 1e fb          	endbr32 
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010ff:	68 6c 18 80 00       	push   $0x80186c
  801104:	68 ac 00 00 00       	push   $0xac
  801109:	68 e3 17 80 00       	push   $0x8017e3
  80110e:	e8 3e f0 ff ff       	call   800151 <_panic>

00801113 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801113:	f3 0f 1e fb          	endbr32 
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80111d:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801124:	74 0a                	je     801130 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801126:	8b 45 08             	mov    0x8(%ebp),%eax
  801129:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  80112e:	c9                   	leave  
  80112f:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801130:	83 ec 0c             	sub    $0xc,%esp
  801133:	68 a3 18 80 00       	push   $0x8018a3
  801138:	e8 fb f0 ff ff       	call   800238 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  80113d:	83 c4 0c             	add    $0xc,%esp
  801140:	6a 07                	push   $0x7
  801142:	68 00 f0 bf ee       	push   $0xeebff000
  801147:	6a 00                	push   $0x0
  801149:	e8 35 fb ff ff       	call   800c83 <sys_page_alloc>
  80114e:	83 c4 10             	add    $0x10,%esp
  801151:	85 c0                	test   %eax,%eax
  801153:	78 2a                	js     80117f <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801155:	83 ec 08             	sub    $0x8,%esp
  801158:	68 93 11 80 00       	push   $0x801193
  80115d:	6a 00                	push   $0x0
  80115f:	e8 7e fc ff ff       	call   800de2 <sys_env_set_pgfault_upcall>
  801164:	83 c4 10             	add    $0x10,%esp
  801167:	85 c0                	test   %eax,%eax
  801169:	79 bb                	jns    801126 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  80116b:	83 ec 04             	sub    $0x4,%esp
  80116e:	68 e0 18 80 00       	push   $0x8018e0
  801173:	6a 25                	push   $0x25
  801175:	68 d0 18 80 00       	push   $0x8018d0
  80117a:	e8 d2 ef ff ff       	call   800151 <_panic>
            panic("Allocation of UXSTACK failed!");
  80117f:	83 ec 04             	sub    $0x4,%esp
  801182:	68 b2 18 80 00       	push   $0x8018b2
  801187:	6a 22                	push   $0x22
  801189:	68 d0 18 80 00       	push   $0x8018d0
  80118e:	e8 be ef ff ff       	call   800151 <_panic>

00801193 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801193:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801194:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801199:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80119b:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  80119e:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  8011a2:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  8011a6:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  8011a9:	83 c4 08             	add    $0x8,%esp
    popa
  8011ac:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  8011ad:	83 c4 04             	add    $0x4,%esp
    popf
  8011b0:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  8011b1:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  8011b4:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  8011b8:	c3                   	ret    
  8011b9:	66 90                	xchg   %ax,%ax
  8011bb:	66 90                	xchg   %ax,%ax
  8011bd:	66 90                	xchg   %ax,%ax
  8011bf:	90                   	nop

008011c0 <__udivdi3>:
  8011c0:	f3 0f 1e fb          	endbr32 
  8011c4:	55                   	push   %ebp
  8011c5:	57                   	push   %edi
  8011c6:	56                   	push   %esi
  8011c7:	53                   	push   %ebx
  8011c8:	83 ec 1c             	sub    $0x1c,%esp
  8011cb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8011cf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8011d3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8011d7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8011db:	85 d2                	test   %edx,%edx
  8011dd:	75 19                	jne    8011f8 <__udivdi3+0x38>
  8011df:	39 f3                	cmp    %esi,%ebx
  8011e1:	76 4d                	jbe    801230 <__udivdi3+0x70>
  8011e3:	31 ff                	xor    %edi,%edi
  8011e5:	89 e8                	mov    %ebp,%eax
  8011e7:	89 f2                	mov    %esi,%edx
  8011e9:	f7 f3                	div    %ebx
  8011eb:	89 fa                	mov    %edi,%edx
  8011ed:	83 c4 1c             	add    $0x1c,%esp
  8011f0:	5b                   	pop    %ebx
  8011f1:	5e                   	pop    %esi
  8011f2:	5f                   	pop    %edi
  8011f3:	5d                   	pop    %ebp
  8011f4:	c3                   	ret    
  8011f5:	8d 76 00             	lea    0x0(%esi),%esi
  8011f8:	39 f2                	cmp    %esi,%edx
  8011fa:	76 14                	jbe    801210 <__udivdi3+0x50>
  8011fc:	31 ff                	xor    %edi,%edi
  8011fe:	31 c0                	xor    %eax,%eax
  801200:	89 fa                	mov    %edi,%edx
  801202:	83 c4 1c             	add    $0x1c,%esp
  801205:	5b                   	pop    %ebx
  801206:	5e                   	pop    %esi
  801207:	5f                   	pop    %edi
  801208:	5d                   	pop    %ebp
  801209:	c3                   	ret    
  80120a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801210:	0f bd fa             	bsr    %edx,%edi
  801213:	83 f7 1f             	xor    $0x1f,%edi
  801216:	75 48                	jne    801260 <__udivdi3+0xa0>
  801218:	39 f2                	cmp    %esi,%edx
  80121a:	72 06                	jb     801222 <__udivdi3+0x62>
  80121c:	31 c0                	xor    %eax,%eax
  80121e:	39 eb                	cmp    %ebp,%ebx
  801220:	77 de                	ja     801200 <__udivdi3+0x40>
  801222:	b8 01 00 00 00       	mov    $0x1,%eax
  801227:	eb d7                	jmp    801200 <__udivdi3+0x40>
  801229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801230:	89 d9                	mov    %ebx,%ecx
  801232:	85 db                	test   %ebx,%ebx
  801234:	75 0b                	jne    801241 <__udivdi3+0x81>
  801236:	b8 01 00 00 00       	mov    $0x1,%eax
  80123b:	31 d2                	xor    %edx,%edx
  80123d:	f7 f3                	div    %ebx
  80123f:	89 c1                	mov    %eax,%ecx
  801241:	31 d2                	xor    %edx,%edx
  801243:	89 f0                	mov    %esi,%eax
  801245:	f7 f1                	div    %ecx
  801247:	89 c6                	mov    %eax,%esi
  801249:	89 e8                	mov    %ebp,%eax
  80124b:	89 f7                	mov    %esi,%edi
  80124d:	f7 f1                	div    %ecx
  80124f:	89 fa                	mov    %edi,%edx
  801251:	83 c4 1c             	add    $0x1c,%esp
  801254:	5b                   	pop    %ebx
  801255:	5e                   	pop    %esi
  801256:	5f                   	pop    %edi
  801257:	5d                   	pop    %ebp
  801258:	c3                   	ret    
  801259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801260:	89 f9                	mov    %edi,%ecx
  801262:	b8 20 00 00 00       	mov    $0x20,%eax
  801267:	29 f8                	sub    %edi,%eax
  801269:	d3 e2                	shl    %cl,%edx
  80126b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80126f:	89 c1                	mov    %eax,%ecx
  801271:	89 da                	mov    %ebx,%edx
  801273:	d3 ea                	shr    %cl,%edx
  801275:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801279:	09 d1                	or     %edx,%ecx
  80127b:	89 f2                	mov    %esi,%edx
  80127d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801281:	89 f9                	mov    %edi,%ecx
  801283:	d3 e3                	shl    %cl,%ebx
  801285:	89 c1                	mov    %eax,%ecx
  801287:	d3 ea                	shr    %cl,%edx
  801289:	89 f9                	mov    %edi,%ecx
  80128b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80128f:	89 eb                	mov    %ebp,%ebx
  801291:	d3 e6                	shl    %cl,%esi
  801293:	89 c1                	mov    %eax,%ecx
  801295:	d3 eb                	shr    %cl,%ebx
  801297:	09 de                	or     %ebx,%esi
  801299:	89 f0                	mov    %esi,%eax
  80129b:	f7 74 24 08          	divl   0x8(%esp)
  80129f:	89 d6                	mov    %edx,%esi
  8012a1:	89 c3                	mov    %eax,%ebx
  8012a3:	f7 64 24 0c          	mull   0xc(%esp)
  8012a7:	39 d6                	cmp    %edx,%esi
  8012a9:	72 15                	jb     8012c0 <__udivdi3+0x100>
  8012ab:	89 f9                	mov    %edi,%ecx
  8012ad:	d3 e5                	shl    %cl,%ebp
  8012af:	39 c5                	cmp    %eax,%ebp
  8012b1:	73 04                	jae    8012b7 <__udivdi3+0xf7>
  8012b3:	39 d6                	cmp    %edx,%esi
  8012b5:	74 09                	je     8012c0 <__udivdi3+0x100>
  8012b7:	89 d8                	mov    %ebx,%eax
  8012b9:	31 ff                	xor    %edi,%edi
  8012bb:	e9 40 ff ff ff       	jmp    801200 <__udivdi3+0x40>
  8012c0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8012c3:	31 ff                	xor    %edi,%edi
  8012c5:	e9 36 ff ff ff       	jmp    801200 <__udivdi3+0x40>
  8012ca:	66 90                	xchg   %ax,%ax
  8012cc:	66 90                	xchg   %ax,%ax
  8012ce:	66 90                	xchg   %ax,%ax

008012d0 <__umoddi3>:
  8012d0:	f3 0f 1e fb          	endbr32 
  8012d4:	55                   	push   %ebp
  8012d5:	57                   	push   %edi
  8012d6:	56                   	push   %esi
  8012d7:	53                   	push   %ebx
  8012d8:	83 ec 1c             	sub    $0x1c,%esp
  8012db:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8012df:	8b 74 24 30          	mov    0x30(%esp),%esi
  8012e3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8012e7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	75 19                	jne    801308 <__umoddi3+0x38>
  8012ef:	39 df                	cmp    %ebx,%edi
  8012f1:	76 5d                	jbe    801350 <__umoddi3+0x80>
  8012f3:	89 f0                	mov    %esi,%eax
  8012f5:	89 da                	mov    %ebx,%edx
  8012f7:	f7 f7                	div    %edi
  8012f9:	89 d0                	mov    %edx,%eax
  8012fb:	31 d2                	xor    %edx,%edx
  8012fd:	83 c4 1c             	add    $0x1c,%esp
  801300:	5b                   	pop    %ebx
  801301:	5e                   	pop    %esi
  801302:	5f                   	pop    %edi
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    
  801305:	8d 76 00             	lea    0x0(%esi),%esi
  801308:	89 f2                	mov    %esi,%edx
  80130a:	39 d8                	cmp    %ebx,%eax
  80130c:	76 12                	jbe    801320 <__umoddi3+0x50>
  80130e:	89 f0                	mov    %esi,%eax
  801310:	89 da                	mov    %ebx,%edx
  801312:	83 c4 1c             	add    $0x1c,%esp
  801315:	5b                   	pop    %ebx
  801316:	5e                   	pop    %esi
  801317:	5f                   	pop    %edi
  801318:	5d                   	pop    %ebp
  801319:	c3                   	ret    
  80131a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801320:	0f bd e8             	bsr    %eax,%ebp
  801323:	83 f5 1f             	xor    $0x1f,%ebp
  801326:	75 50                	jne    801378 <__umoddi3+0xa8>
  801328:	39 d8                	cmp    %ebx,%eax
  80132a:	0f 82 e0 00 00 00    	jb     801410 <__umoddi3+0x140>
  801330:	89 d9                	mov    %ebx,%ecx
  801332:	39 f7                	cmp    %esi,%edi
  801334:	0f 86 d6 00 00 00    	jbe    801410 <__umoddi3+0x140>
  80133a:	89 d0                	mov    %edx,%eax
  80133c:	89 ca                	mov    %ecx,%edx
  80133e:	83 c4 1c             	add    $0x1c,%esp
  801341:	5b                   	pop    %ebx
  801342:	5e                   	pop    %esi
  801343:	5f                   	pop    %edi
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    
  801346:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80134d:	8d 76 00             	lea    0x0(%esi),%esi
  801350:	89 fd                	mov    %edi,%ebp
  801352:	85 ff                	test   %edi,%edi
  801354:	75 0b                	jne    801361 <__umoddi3+0x91>
  801356:	b8 01 00 00 00       	mov    $0x1,%eax
  80135b:	31 d2                	xor    %edx,%edx
  80135d:	f7 f7                	div    %edi
  80135f:	89 c5                	mov    %eax,%ebp
  801361:	89 d8                	mov    %ebx,%eax
  801363:	31 d2                	xor    %edx,%edx
  801365:	f7 f5                	div    %ebp
  801367:	89 f0                	mov    %esi,%eax
  801369:	f7 f5                	div    %ebp
  80136b:	89 d0                	mov    %edx,%eax
  80136d:	31 d2                	xor    %edx,%edx
  80136f:	eb 8c                	jmp    8012fd <__umoddi3+0x2d>
  801371:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801378:	89 e9                	mov    %ebp,%ecx
  80137a:	ba 20 00 00 00       	mov    $0x20,%edx
  80137f:	29 ea                	sub    %ebp,%edx
  801381:	d3 e0                	shl    %cl,%eax
  801383:	89 44 24 08          	mov    %eax,0x8(%esp)
  801387:	89 d1                	mov    %edx,%ecx
  801389:	89 f8                	mov    %edi,%eax
  80138b:	d3 e8                	shr    %cl,%eax
  80138d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801391:	89 54 24 04          	mov    %edx,0x4(%esp)
  801395:	8b 54 24 04          	mov    0x4(%esp),%edx
  801399:	09 c1                	or     %eax,%ecx
  80139b:	89 d8                	mov    %ebx,%eax
  80139d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013a1:	89 e9                	mov    %ebp,%ecx
  8013a3:	d3 e7                	shl    %cl,%edi
  8013a5:	89 d1                	mov    %edx,%ecx
  8013a7:	d3 e8                	shr    %cl,%eax
  8013a9:	89 e9                	mov    %ebp,%ecx
  8013ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013af:	d3 e3                	shl    %cl,%ebx
  8013b1:	89 c7                	mov    %eax,%edi
  8013b3:	89 d1                	mov    %edx,%ecx
  8013b5:	89 f0                	mov    %esi,%eax
  8013b7:	d3 e8                	shr    %cl,%eax
  8013b9:	89 e9                	mov    %ebp,%ecx
  8013bb:	89 fa                	mov    %edi,%edx
  8013bd:	d3 e6                	shl    %cl,%esi
  8013bf:	09 d8                	or     %ebx,%eax
  8013c1:	f7 74 24 08          	divl   0x8(%esp)
  8013c5:	89 d1                	mov    %edx,%ecx
  8013c7:	89 f3                	mov    %esi,%ebx
  8013c9:	f7 64 24 0c          	mull   0xc(%esp)
  8013cd:	89 c6                	mov    %eax,%esi
  8013cf:	89 d7                	mov    %edx,%edi
  8013d1:	39 d1                	cmp    %edx,%ecx
  8013d3:	72 06                	jb     8013db <__umoddi3+0x10b>
  8013d5:	75 10                	jne    8013e7 <__umoddi3+0x117>
  8013d7:	39 c3                	cmp    %eax,%ebx
  8013d9:	73 0c                	jae    8013e7 <__umoddi3+0x117>
  8013db:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8013df:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8013e3:	89 d7                	mov    %edx,%edi
  8013e5:	89 c6                	mov    %eax,%esi
  8013e7:	89 ca                	mov    %ecx,%edx
  8013e9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013ee:	29 f3                	sub    %esi,%ebx
  8013f0:	19 fa                	sbb    %edi,%edx
  8013f2:	89 d0                	mov    %edx,%eax
  8013f4:	d3 e0                	shl    %cl,%eax
  8013f6:	89 e9                	mov    %ebp,%ecx
  8013f8:	d3 eb                	shr    %cl,%ebx
  8013fa:	d3 ea                	shr    %cl,%edx
  8013fc:	09 d8                	or     %ebx,%eax
  8013fe:	83 c4 1c             	add    $0x1c,%esp
  801401:	5b                   	pop    %ebx
  801402:	5e                   	pop    %esi
  801403:	5f                   	pop    %edi
  801404:	5d                   	pop    %ebp
  801405:	c3                   	ret    
  801406:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80140d:	8d 76 00             	lea    0x0(%esi),%esi
  801410:	29 fe                	sub    %edi,%esi
  801412:	19 c3                	sbb    %eax,%ebx
  801414:	89 f2                	mov    %esi,%edx
  801416:	89 d9                	mov    %ebx,%ecx
  801418:	e9 1d ff ff ff       	jmp    80133a <__umoddi3+0x6a>
