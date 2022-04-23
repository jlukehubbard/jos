
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  800040:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800043:	83 ec 04             	sub    $0x4,%esp
  800046:	6a 00                	push   $0x0
  800048:	6a 00                	push   $0x0
  80004a:	56                   	push   %esi
  80004b:	e8 da 10 00 00       	call   80112a <ipc_recv>
  800050:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  800052:	a1 04 20 80 00       	mov    0x802004,%eax
  800057:	8b 40 5c             	mov    0x5c(%eax),%eax
  80005a:	83 c4 0c             	add    $0xc,%esp
  80005d:	53                   	push   %ebx
  80005e:	50                   	push   %eax
  80005f:	68 40 15 80 00       	push   $0x801540
  800064:	e8 e6 01 00 00       	call   80024f <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800069:	e8 12 0f 00 00       	call   800f80 <fork>
  80006e:	89 c7                	mov    %eax,%edi
  800070:	83 c4 10             	add    $0x10,%esp
  800073:	85 c0                	test   %eax,%eax
  800075:	78 07                	js     80007e <primeproc+0x4b>
		panic("fork: %e", id);
	if (id == 0)
  800077:	74 ca                	je     800043 <primeproc+0x10>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800079:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80007c:	eb 20                	jmp    80009e <primeproc+0x6b>
		panic("fork: %e", id);
  80007e:	50                   	push   %eax
  80007f:	68 4c 15 80 00       	push   $0x80154c
  800084:	6a 1a                	push   $0x1a
  800086:	68 55 15 80 00       	push   $0x801555
  80008b:	e8 d8 00 00 00       	call   800168 <_panic>
		if (i % p)
			ipc_send(id, i, 0, 0);
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	51                   	push   %ecx
  800095:	57                   	push   %edi
  800096:	e8 e6 10 00 00       	call   801181 <ipc_send>
  80009b:	83 c4 10             	add    $0x10,%esp
		i = ipc_recv(&envid, 0, 0);
  80009e:	83 ec 04             	sub    $0x4,%esp
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	56                   	push   %esi
  8000a6:	e8 7f 10 00 00       	call   80112a <ipc_recv>
  8000ab:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000ad:	99                   	cltd   
  8000ae:	f7 fb                	idiv   %ebx
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	85 d2                	test   %edx,%edx
  8000b5:	74 e7                	je     80009e <primeproc+0x6b>
  8000b7:	eb d7                	jmp    800090 <primeproc+0x5d>

008000b9 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b9:	f3 0f 1e fb          	endbr32 
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000c2:	e8 b9 0e 00 00       	call   800f80 <fork>
  8000c7:	89 c6                	mov    %eax,%esi
  8000c9:	85 c0                	test   %eax,%eax
  8000cb:	78 1a                	js     8000e7 <umain+0x2e>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000cd:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000d2:	74 25                	je     8000f9 <umain+0x40>
		ipc_send(id, i, 0, 0);
  8000d4:	6a 00                	push   $0x0
  8000d6:	6a 00                	push   $0x0
  8000d8:	53                   	push   %ebx
  8000d9:	56                   	push   %esi
  8000da:	e8 a2 10 00 00       	call   801181 <ipc_send>
	for (i = 2; ; i++)
  8000df:	83 c3 01             	add    $0x1,%ebx
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb ed                	jmp    8000d4 <umain+0x1b>
		panic("fork: %e", id);
  8000e7:	50                   	push   %eax
  8000e8:	68 4c 15 80 00       	push   $0x80154c
  8000ed:	6a 2d                	push   $0x2d
  8000ef:	68 55 15 80 00       	push   $0x801555
  8000f4:	e8 6f 00 00 00       	call   800168 <_panic>
		primeproc();
  8000f9:	e8 35 ff ff ff       	call   800033 <primeproc>

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	f3 0f 1e fb          	endbr32 
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	56                   	push   %esi
  800106:	53                   	push   %ebx
  800107:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80010a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80010d:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800114:	00 00 00 
    envid_t envid = sys_getenvid();
  800117:	e8 38 0b 00 00       	call   800c54 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  80011c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800121:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800124:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800129:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012e:	85 db                	test   %ebx,%ebx
  800130:	7e 07                	jle    800139 <libmain+0x3b>
		binaryname = argv[0];
  800132:	8b 06                	mov    (%esi),%eax
  800134:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800139:	83 ec 08             	sub    $0x8,%esp
  80013c:	56                   	push   %esi
  80013d:	53                   	push   %ebx
  80013e:	e8 76 ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  800143:	e8 0a 00 00 00       	call   800152 <exit>
}
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014e:	5b                   	pop    %ebx
  80014f:	5e                   	pop    %esi
  800150:	5d                   	pop    %ebp
  800151:	c3                   	ret    

00800152 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800152:	f3 0f 1e fb          	endbr32 
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  80015c:	6a 00                	push   $0x0
  80015e:	e8 ac 0a 00 00       	call   800c0f <sys_env_destroy>
}
  800163:	83 c4 10             	add    $0x10,%esp
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800168:	f3 0f 1e fb          	endbr32 
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800171:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800174:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80017a:	e8 d5 0a 00 00       	call   800c54 <sys_getenvid>
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	ff 75 0c             	pushl  0xc(%ebp)
  800185:	ff 75 08             	pushl  0x8(%ebp)
  800188:	56                   	push   %esi
  800189:	50                   	push   %eax
  80018a:	68 70 15 80 00       	push   $0x801570
  80018f:	e8 bb 00 00 00       	call   80024f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800194:	83 c4 18             	add    $0x18,%esp
  800197:	53                   	push   %ebx
  800198:	ff 75 10             	pushl  0x10(%ebp)
  80019b:	e8 5a 00 00 00       	call   8001fa <vcprintf>
	cprintf("\n");
  8001a0:	c7 04 24 b0 19 80 00 	movl   $0x8019b0,(%esp)
  8001a7:	e8 a3 00 00 00       	call   80024f <cprintf>
  8001ac:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001af:	cc                   	int3   
  8001b0:	eb fd                	jmp    8001af <_panic+0x47>

008001b2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b2:	f3 0f 1e fb          	endbr32 
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	53                   	push   %ebx
  8001ba:	83 ec 04             	sub    $0x4,%esp
  8001bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c0:	8b 13                	mov    (%ebx),%edx
  8001c2:	8d 42 01             	lea    0x1(%edx),%eax
  8001c5:	89 03                	mov    %eax,(%ebx)
  8001c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d3:	74 09                	je     8001de <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001d5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001dc:	c9                   	leave  
  8001dd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001de:	83 ec 08             	sub    $0x8,%esp
  8001e1:	68 ff 00 00 00       	push   $0xff
  8001e6:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e9:	50                   	push   %eax
  8001ea:	e8 db 09 00 00       	call   800bca <sys_cputs>
		b->idx = 0;
  8001ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001f5:	83 c4 10             	add    $0x10,%esp
  8001f8:	eb db                	jmp    8001d5 <putch+0x23>

008001fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001fa:	f3 0f 1e fb          	endbr32 
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800207:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020e:	00 00 00 
	b.cnt = 0;
  800211:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800218:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80021b:	ff 75 0c             	pushl  0xc(%ebp)
  80021e:	ff 75 08             	pushl  0x8(%ebp)
  800221:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800227:	50                   	push   %eax
  800228:	68 b2 01 80 00       	push   $0x8001b2
  80022d:	e8 20 01 00 00       	call   800352 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800232:	83 c4 08             	add    $0x8,%esp
  800235:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80023b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800241:	50                   	push   %eax
  800242:	e8 83 09 00 00       	call   800bca <sys_cputs>

	return b.cnt;
}
  800247:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024d:	c9                   	leave  
  80024e:	c3                   	ret    

0080024f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024f:	f3 0f 1e fb          	endbr32 
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800259:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80025c:	50                   	push   %eax
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	e8 95 ff ff ff       	call   8001fa <vcprintf>
	va_end(ap);

	return cnt;
}
  800265:	c9                   	leave  
  800266:	c3                   	ret    

00800267 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 1c             	sub    $0x1c,%esp
  800270:	89 c7                	mov    %eax,%edi
  800272:	89 d6                	mov    %edx,%esi
  800274:	8b 45 08             	mov    0x8(%ebp),%eax
  800277:	8b 55 0c             	mov    0xc(%ebp),%edx
  80027a:	89 d1                	mov    %edx,%ecx
  80027c:	89 c2                	mov    %eax,%edx
  80027e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800281:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800284:	8b 45 10             	mov    0x10(%ebp),%eax
  800287:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80028a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80028d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800294:	39 c2                	cmp    %eax,%edx
  800296:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800299:	72 3e                	jb     8002d9 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80029b:	83 ec 0c             	sub    $0xc,%esp
  80029e:	ff 75 18             	pushl  0x18(%ebp)
  8002a1:	83 eb 01             	sub    $0x1,%ebx
  8002a4:	53                   	push   %ebx
  8002a5:	50                   	push   %eax
  8002a6:	83 ec 08             	sub    $0x8,%esp
  8002a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8002af:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b5:	e8 16 10 00 00       	call   8012d0 <__udivdi3>
  8002ba:	83 c4 18             	add    $0x18,%esp
  8002bd:	52                   	push   %edx
  8002be:	50                   	push   %eax
  8002bf:	89 f2                	mov    %esi,%edx
  8002c1:	89 f8                	mov    %edi,%eax
  8002c3:	e8 9f ff ff ff       	call   800267 <printnum>
  8002c8:	83 c4 20             	add    $0x20,%esp
  8002cb:	eb 13                	jmp    8002e0 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002cd:	83 ec 08             	sub    $0x8,%esp
  8002d0:	56                   	push   %esi
  8002d1:	ff 75 18             	pushl  0x18(%ebp)
  8002d4:	ff d7                	call   *%edi
  8002d6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002d9:	83 eb 01             	sub    $0x1,%ebx
  8002dc:	85 db                	test   %ebx,%ebx
  8002de:	7f ed                	jg     8002cd <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	56                   	push   %esi
  8002e4:	83 ec 04             	sub    $0x4,%esp
  8002e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ed:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f3:	e8 e8 10 00 00       	call   8013e0 <__umoddi3>
  8002f8:	83 c4 14             	add    $0x14,%esp
  8002fb:	0f be 80 93 15 80 00 	movsbl 0x801593(%eax),%eax
  800302:	50                   	push   %eax
  800303:	ff d7                	call   *%edi
}
  800305:	83 c4 10             	add    $0x10,%esp
  800308:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030b:	5b                   	pop    %ebx
  80030c:	5e                   	pop    %esi
  80030d:	5f                   	pop    %edi
  80030e:	5d                   	pop    %ebp
  80030f:	c3                   	ret    

00800310 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800310:	f3 0f 1e fb          	endbr32 
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80031a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	3b 50 04             	cmp    0x4(%eax),%edx
  800323:	73 0a                	jae    80032f <sprintputch+0x1f>
		*b->buf++ = ch;
  800325:	8d 4a 01             	lea    0x1(%edx),%ecx
  800328:	89 08                	mov    %ecx,(%eax)
  80032a:	8b 45 08             	mov    0x8(%ebp),%eax
  80032d:	88 02                	mov    %al,(%edx)
}
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <printfmt>:
{
  800331:	f3 0f 1e fb          	endbr32 
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80033b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80033e:	50                   	push   %eax
  80033f:	ff 75 10             	pushl  0x10(%ebp)
  800342:	ff 75 0c             	pushl  0xc(%ebp)
  800345:	ff 75 08             	pushl  0x8(%ebp)
  800348:	e8 05 00 00 00       	call   800352 <vprintfmt>
}
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	c9                   	leave  
  800351:	c3                   	ret    

00800352 <vprintfmt>:
{
  800352:	f3 0f 1e fb          	endbr32 
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
  800359:	57                   	push   %edi
  80035a:	56                   	push   %esi
  80035b:	53                   	push   %ebx
  80035c:	83 ec 3c             	sub    $0x3c,%esp
  80035f:	8b 75 08             	mov    0x8(%ebp),%esi
  800362:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800365:	8b 7d 10             	mov    0x10(%ebp),%edi
  800368:	e9 4a 03 00 00       	jmp    8006b7 <vprintfmt+0x365>
		padc = ' ';
  80036d:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800371:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800378:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80037f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800386:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8d 47 01             	lea    0x1(%edi),%eax
  80038e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800391:	0f b6 17             	movzbl (%edi),%edx
  800394:	8d 42 dd             	lea    -0x23(%edx),%eax
  800397:	3c 55                	cmp    $0x55,%al
  800399:	0f 87 de 03 00 00    	ja     80077d <vprintfmt+0x42b>
  80039f:	0f b6 c0             	movzbl %al,%eax
  8003a2:	3e ff 24 85 e0 16 80 	notrack jmp *0x8016e0(,%eax,4)
  8003a9:	00 
  8003aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003ad:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003b1:	eb d8                	jmp    80038b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b6:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003ba:	eb cf                	jmp    80038b <vprintfmt+0x39>
  8003bc:	0f b6 d2             	movzbl %dl,%edx
  8003bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003ca:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003cd:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003d1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003d4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003d7:	83 f9 09             	cmp    $0x9,%ecx
  8003da:	77 55                	ja     800431 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003dc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003df:	eb e9                	jmp    8003ca <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8b 00                	mov    (%eax),%eax
  8003e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ec:	8d 40 04             	lea    0x4(%eax),%eax
  8003ef:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f9:	79 90                	jns    80038b <vprintfmt+0x39>
				width = precision, precision = -1;
  8003fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800401:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800408:	eb 81                	jmp    80038b <vprintfmt+0x39>
  80040a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040d:	85 c0                	test   %eax,%eax
  80040f:	ba 00 00 00 00       	mov    $0x0,%edx
  800414:	0f 49 d0             	cmovns %eax,%edx
  800417:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80041d:	e9 69 ff ff ff       	jmp    80038b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800425:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80042c:	e9 5a ff ff ff       	jmp    80038b <vprintfmt+0x39>
  800431:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800434:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800437:	eb bc                	jmp    8003f5 <vprintfmt+0xa3>
			lflag++;
  800439:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80043f:	e9 47 ff ff ff       	jmp    80038b <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	8d 78 04             	lea    0x4(%eax),%edi
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	53                   	push   %ebx
  80044e:	ff 30                	pushl  (%eax)
  800450:	ff d6                	call   *%esi
			break;
  800452:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800455:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800458:	e9 57 02 00 00       	jmp    8006b4 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80045d:	8b 45 14             	mov    0x14(%ebp),%eax
  800460:	8d 78 04             	lea    0x4(%eax),%edi
  800463:	8b 00                	mov    (%eax),%eax
  800465:	99                   	cltd   
  800466:	31 d0                	xor    %edx,%eax
  800468:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046a:	83 f8 0f             	cmp    $0xf,%eax
  80046d:	7f 23                	jg     800492 <vprintfmt+0x140>
  80046f:	8b 14 85 40 18 80 00 	mov    0x801840(,%eax,4),%edx
  800476:	85 d2                	test   %edx,%edx
  800478:	74 18                	je     800492 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80047a:	52                   	push   %edx
  80047b:	68 b4 15 80 00       	push   $0x8015b4
  800480:	53                   	push   %ebx
  800481:	56                   	push   %esi
  800482:	e8 aa fe ff ff       	call   800331 <printfmt>
  800487:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80048a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80048d:	e9 22 02 00 00       	jmp    8006b4 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800492:	50                   	push   %eax
  800493:	68 ab 15 80 00       	push   $0x8015ab
  800498:	53                   	push   %ebx
  800499:	56                   	push   %esi
  80049a:	e8 92 fe ff ff       	call   800331 <printfmt>
  80049f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004a2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004a5:	e9 0a 02 00 00       	jmp    8006b4 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8004aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ad:	83 c0 04             	add    $0x4,%eax
  8004b0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b6:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004b8:	85 d2                	test   %edx,%edx
  8004ba:	b8 a4 15 80 00       	mov    $0x8015a4,%eax
  8004bf:	0f 45 c2             	cmovne %edx,%eax
  8004c2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c9:	7e 06                	jle    8004d1 <vprintfmt+0x17f>
  8004cb:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004cf:	75 0d                	jne    8004de <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004d4:	89 c7                	mov    %eax,%edi
  8004d6:	03 45 e0             	add    -0x20(%ebp),%eax
  8004d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004dc:	eb 55                	jmp    800533 <vprintfmt+0x1e1>
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	ff 75 d8             	pushl  -0x28(%ebp)
  8004e4:	ff 75 cc             	pushl  -0x34(%ebp)
  8004e7:	e8 45 03 00 00       	call   800831 <strnlen>
  8004ec:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004ef:	29 c2                	sub    %eax,%edx
  8004f1:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004f9:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800500:	85 ff                	test   %edi,%edi
  800502:	7e 11                	jle    800515 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	53                   	push   %ebx
  800508:	ff 75 e0             	pushl  -0x20(%ebp)
  80050b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80050d:	83 ef 01             	sub    $0x1,%edi
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	eb eb                	jmp    800500 <vprintfmt+0x1ae>
  800515:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800518:	85 d2                	test   %edx,%edx
  80051a:	b8 00 00 00 00       	mov    $0x0,%eax
  80051f:	0f 49 c2             	cmovns %edx,%eax
  800522:	29 c2                	sub    %eax,%edx
  800524:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800527:	eb a8                	jmp    8004d1 <vprintfmt+0x17f>
					putch(ch, putdat);
  800529:	83 ec 08             	sub    $0x8,%esp
  80052c:	53                   	push   %ebx
  80052d:	52                   	push   %edx
  80052e:	ff d6                	call   *%esi
  800530:	83 c4 10             	add    $0x10,%esp
  800533:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800536:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800538:	83 c7 01             	add    $0x1,%edi
  80053b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80053f:	0f be d0             	movsbl %al,%edx
  800542:	85 d2                	test   %edx,%edx
  800544:	74 4b                	je     800591 <vprintfmt+0x23f>
  800546:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80054a:	78 06                	js     800552 <vprintfmt+0x200>
  80054c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800550:	78 1e                	js     800570 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800552:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800556:	74 d1                	je     800529 <vprintfmt+0x1d7>
  800558:	0f be c0             	movsbl %al,%eax
  80055b:	83 e8 20             	sub    $0x20,%eax
  80055e:	83 f8 5e             	cmp    $0x5e,%eax
  800561:	76 c6                	jbe    800529 <vprintfmt+0x1d7>
					putch('?', putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	53                   	push   %ebx
  800567:	6a 3f                	push   $0x3f
  800569:	ff d6                	call   *%esi
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb c3                	jmp    800533 <vprintfmt+0x1e1>
  800570:	89 cf                	mov    %ecx,%edi
  800572:	eb 0e                	jmp    800582 <vprintfmt+0x230>
				putch(' ', putdat);
  800574:	83 ec 08             	sub    $0x8,%esp
  800577:	53                   	push   %ebx
  800578:	6a 20                	push   $0x20
  80057a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80057c:	83 ef 01             	sub    $0x1,%edi
  80057f:	83 c4 10             	add    $0x10,%esp
  800582:	85 ff                	test   %edi,%edi
  800584:	7f ee                	jg     800574 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800586:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800589:	89 45 14             	mov    %eax,0x14(%ebp)
  80058c:	e9 23 01 00 00       	jmp    8006b4 <vprintfmt+0x362>
  800591:	89 cf                	mov    %ecx,%edi
  800593:	eb ed                	jmp    800582 <vprintfmt+0x230>
	if (lflag >= 2)
  800595:	83 f9 01             	cmp    $0x1,%ecx
  800598:	7f 1b                	jg     8005b5 <vprintfmt+0x263>
	else if (lflag)
  80059a:	85 c9                	test   %ecx,%ecx
  80059c:	74 63                	je     800601 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8b 00                	mov    (%eax),%eax
  8005a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a6:	99                   	cltd   
  8005a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8d 40 04             	lea    0x4(%eax),%eax
  8005b0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b3:	eb 17                	jmp    8005cc <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8b 50 04             	mov    0x4(%eax),%edx
  8005bb:	8b 00                	mov    (%eax),%eax
  8005bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8d 40 08             	lea    0x8(%eax),%eax
  8005c9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005cf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005d2:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005d7:	85 c9                	test   %ecx,%ecx
  8005d9:	0f 89 bb 00 00 00    	jns    80069a <vprintfmt+0x348>
				putch('-', putdat);
  8005df:	83 ec 08             	sub    $0x8,%esp
  8005e2:	53                   	push   %ebx
  8005e3:	6a 2d                	push   $0x2d
  8005e5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005e7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ed:	f7 da                	neg    %edx
  8005ef:	83 d1 00             	adc    $0x0,%ecx
  8005f2:	f7 d9                	neg    %ecx
  8005f4:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fc:	e9 99 00 00 00       	jmp    80069a <vprintfmt+0x348>
		return va_arg(*ap, int);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8b 00                	mov    (%eax),%eax
  800606:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800609:	99                   	cltd   
  80060a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8d 40 04             	lea    0x4(%eax),%eax
  800613:	89 45 14             	mov    %eax,0x14(%ebp)
  800616:	eb b4                	jmp    8005cc <vprintfmt+0x27a>
	if (lflag >= 2)
  800618:	83 f9 01             	cmp    $0x1,%ecx
  80061b:	7f 1b                	jg     800638 <vprintfmt+0x2e6>
	else if (lflag)
  80061d:	85 c9                	test   %ecx,%ecx
  80061f:	74 2c                	je     80064d <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8b 10                	mov    (%eax),%edx
  800626:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062b:	8d 40 04             	lea    0x4(%eax),%eax
  80062e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800631:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800636:	eb 62                	jmp    80069a <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8b 10                	mov    (%eax),%edx
  80063d:	8b 48 04             	mov    0x4(%eax),%ecx
  800640:	8d 40 08             	lea    0x8(%eax),%eax
  800643:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800646:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80064b:	eb 4d                	jmp    80069a <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8b 10                	mov    (%eax),%edx
  800652:	b9 00 00 00 00       	mov    $0x0,%ecx
  800657:	8d 40 04             	lea    0x4(%eax),%eax
  80065a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80065d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800662:	eb 36                	jmp    80069a <vprintfmt+0x348>
	if (lflag >= 2)
  800664:	83 f9 01             	cmp    $0x1,%ecx
  800667:	7f 17                	jg     800680 <vprintfmt+0x32e>
	else if (lflag)
  800669:	85 c9                	test   %ecx,%ecx
  80066b:	74 6e                	je     8006db <vprintfmt+0x389>
		return va_arg(*ap, long);
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8b 10                	mov    (%eax),%edx
  800672:	89 d0                	mov    %edx,%eax
  800674:	99                   	cltd   
  800675:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800678:	8d 49 04             	lea    0x4(%ecx),%ecx
  80067b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80067e:	eb 11                	jmp    800691 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8b 50 04             	mov    0x4(%eax),%edx
  800686:	8b 00                	mov    (%eax),%eax
  800688:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80068b:	8d 49 08             	lea    0x8(%ecx),%ecx
  80068e:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800691:	89 d1                	mov    %edx,%ecx
  800693:	89 c2                	mov    %eax,%edx
            base = 8;
  800695:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80069a:	83 ec 0c             	sub    $0xc,%esp
  80069d:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006a1:	57                   	push   %edi
  8006a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a5:	50                   	push   %eax
  8006a6:	51                   	push   %ecx
  8006a7:	52                   	push   %edx
  8006a8:	89 da                	mov    %ebx,%edx
  8006aa:	89 f0                	mov    %esi,%eax
  8006ac:	e8 b6 fb ff ff       	call   800267 <printnum>
			break;
  8006b1:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006b7:	83 c7 01             	add    $0x1,%edi
  8006ba:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006be:	83 f8 25             	cmp    $0x25,%eax
  8006c1:	0f 84 a6 fc ff ff    	je     80036d <vprintfmt+0x1b>
			if (ch == '\0')
  8006c7:	85 c0                	test   %eax,%eax
  8006c9:	0f 84 ce 00 00 00    	je     80079d <vprintfmt+0x44b>
			putch(ch, putdat);
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	53                   	push   %ebx
  8006d3:	50                   	push   %eax
  8006d4:	ff d6                	call   *%esi
  8006d6:	83 c4 10             	add    $0x10,%esp
  8006d9:	eb dc                	jmp    8006b7 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8006db:	8b 45 14             	mov    0x14(%ebp),%eax
  8006de:	8b 10                	mov    (%eax),%edx
  8006e0:	89 d0                	mov    %edx,%eax
  8006e2:	99                   	cltd   
  8006e3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006e6:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006e9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006ec:	eb a3                	jmp    800691 <vprintfmt+0x33f>
			putch('0', putdat);
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	53                   	push   %ebx
  8006f2:	6a 30                	push   $0x30
  8006f4:	ff d6                	call   *%esi
			putch('x', putdat);
  8006f6:	83 c4 08             	add    $0x8,%esp
  8006f9:	53                   	push   %ebx
  8006fa:	6a 78                	push   $0x78
  8006fc:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8b 10                	mov    (%eax),%edx
  800703:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800708:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80070b:	8d 40 04             	lea    0x4(%eax),%eax
  80070e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800711:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800716:	eb 82                	jmp    80069a <vprintfmt+0x348>
	if (lflag >= 2)
  800718:	83 f9 01             	cmp    $0x1,%ecx
  80071b:	7f 1e                	jg     80073b <vprintfmt+0x3e9>
	else if (lflag)
  80071d:	85 c9                	test   %ecx,%ecx
  80071f:	74 32                	je     800753 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800721:	8b 45 14             	mov    0x14(%ebp),%eax
  800724:	8b 10                	mov    (%eax),%edx
  800726:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072b:	8d 40 04             	lea    0x4(%eax),%eax
  80072e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800731:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800736:	e9 5f ff ff ff       	jmp    80069a <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80073b:	8b 45 14             	mov    0x14(%ebp),%eax
  80073e:	8b 10                	mov    (%eax),%edx
  800740:	8b 48 04             	mov    0x4(%eax),%ecx
  800743:	8d 40 08             	lea    0x8(%eax),%eax
  800746:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800749:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80074e:	e9 47 ff ff ff       	jmp    80069a <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	8b 10                	mov    (%eax),%edx
  800758:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075d:	8d 40 04             	lea    0x4(%eax),%eax
  800760:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800763:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800768:	e9 2d ff ff ff       	jmp    80069a <vprintfmt+0x348>
			putch(ch, putdat);
  80076d:	83 ec 08             	sub    $0x8,%esp
  800770:	53                   	push   %ebx
  800771:	6a 25                	push   $0x25
  800773:	ff d6                	call   *%esi
			break;
  800775:	83 c4 10             	add    $0x10,%esp
  800778:	e9 37 ff ff ff       	jmp    8006b4 <vprintfmt+0x362>
			putch('%', putdat);
  80077d:	83 ec 08             	sub    $0x8,%esp
  800780:	53                   	push   %ebx
  800781:	6a 25                	push   $0x25
  800783:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800785:	83 c4 10             	add    $0x10,%esp
  800788:	89 f8                	mov    %edi,%eax
  80078a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80078e:	74 05                	je     800795 <vprintfmt+0x443>
  800790:	83 e8 01             	sub    $0x1,%eax
  800793:	eb f5                	jmp    80078a <vprintfmt+0x438>
  800795:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800798:	e9 17 ff ff ff       	jmp    8006b4 <vprintfmt+0x362>
}
  80079d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007a0:	5b                   	pop    %ebx
  8007a1:	5e                   	pop    %esi
  8007a2:	5f                   	pop    %edi
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a5:	f3 0f 1e fb          	endbr32 
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	83 ec 18             	sub    $0x18,%esp
  8007af:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007bc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c6:	85 c0                	test   %eax,%eax
  8007c8:	74 26                	je     8007f0 <vsnprintf+0x4b>
  8007ca:	85 d2                	test   %edx,%edx
  8007cc:	7e 22                	jle    8007f0 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ce:	ff 75 14             	pushl  0x14(%ebp)
  8007d1:	ff 75 10             	pushl  0x10(%ebp)
  8007d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d7:	50                   	push   %eax
  8007d8:	68 10 03 80 00       	push   $0x800310
  8007dd:	e8 70 fb ff ff       	call   800352 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007eb:	83 c4 10             	add    $0x10,%esp
}
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    
		return -E_INVAL;
  8007f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007f5:	eb f7                	jmp    8007ee <vsnprintf+0x49>

008007f7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f7:	f3 0f 1e fb          	endbr32 
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800801:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800804:	50                   	push   %eax
  800805:	ff 75 10             	pushl  0x10(%ebp)
  800808:	ff 75 0c             	pushl  0xc(%ebp)
  80080b:	ff 75 08             	pushl  0x8(%ebp)
  80080e:	e8 92 ff ff ff       	call   8007a5 <vsnprintf>
	va_end(ap);

	return rc;
}
  800813:	c9                   	leave  
  800814:	c3                   	ret    

00800815 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800815:	f3 0f 1e fb          	endbr32 
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80081f:	b8 00 00 00 00       	mov    $0x0,%eax
  800824:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800828:	74 05                	je     80082f <strlen+0x1a>
		n++;
  80082a:	83 c0 01             	add    $0x1,%eax
  80082d:	eb f5                	jmp    800824 <strlen+0xf>
	return n;
}
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800831:	f3 0f 1e fb          	endbr32 
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083e:	b8 00 00 00 00       	mov    $0x0,%eax
  800843:	39 d0                	cmp    %edx,%eax
  800845:	74 0d                	je     800854 <strnlen+0x23>
  800847:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80084b:	74 05                	je     800852 <strnlen+0x21>
		n++;
  80084d:	83 c0 01             	add    $0x1,%eax
  800850:	eb f1                	jmp    800843 <strnlen+0x12>
  800852:	89 c2                	mov    %eax,%edx
	return n;
}
  800854:	89 d0                	mov    %edx,%eax
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800858:	f3 0f 1e fb          	endbr32 
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	53                   	push   %ebx
  800860:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800863:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
  80086b:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80086f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800872:	83 c0 01             	add    $0x1,%eax
  800875:	84 d2                	test   %dl,%dl
  800877:	75 f2                	jne    80086b <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800879:	89 c8                	mov    %ecx,%eax
  80087b:	5b                   	pop    %ebx
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80087e:	f3 0f 1e fb          	endbr32 
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	53                   	push   %ebx
  800886:	83 ec 10             	sub    $0x10,%esp
  800889:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80088c:	53                   	push   %ebx
  80088d:	e8 83 ff ff ff       	call   800815 <strlen>
  800892:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800895:	ff 75 0c             	pushl  0xc(%ebp)
  800898:	01 d8                	add    %ebx,%eax
  80089a:	50                   	push   %eax
  80089b:	e8 b8 ff ff ff       	call   800858 <strcpy>
	return dst;
}
  8008a0:	89 d8                	mov    %ebx,%eax
  8008a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a5:	c9                   	leave  
  8008a6:	c3                   	ret    

008008a7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a7:	f3 0f 1e fb          	endbr32 
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	56                   	push   %esi
  8008af:	53                   	push   %ebx
  8008b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b6:	89 f3                	mov    %esi,%ebx
  8008b8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008bb:	89 f0                	mov    %esi,%eax
  8008bd:	39 d8                	cmp    %ebx,%eax
  8008bf:	74 11                	je     8008d2 <strncpy+0x2b>
		*dst++ = *src;
  8008c1:	83 c0 01             	add    $0x1,%eax
  8008c4:	0f b6 0a             	movzbl (%edx),%ecx
  8008c7:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ca:	80 f9 01             	cmp    $0x1,%cl
  8008cd:	83 da ff             	sbb    $0xffffffff,%edx
  8008d0:	eb eb                	jmp    8008bd <strncpy+0x16>
	}
	return ret;
}
  8008d2:	89 f0                	mov    %esi,%eax
  8008d4:	5b                   	pop    %ebx
  8008d5:	5e                   	pop    %esi
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d8:	f3 0f 1e fb          	endbr32 
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	56                   	push   %esi
  8008e0:	53                   	push   %ebx
  8008e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e7:	8b 55 10             	mov    0x10(%ebp),%edx
  8008ea:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ec:	85 d2                	test   %edx,%edx
  8008ee:	74 21                	je     800911 <strlcpy+0x39>
  8008f0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008f4:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008f6:	39 c2                	cmp    %eax,%edx
  8008f8:	74 14                	je     80090e <strlcpy+0x36>
  8008fa:	0f b6 19             	movzbl (%ecx),%ebx
  8008fd:	84 db                	test   %bl,%bl
  8008ff:	74 0b                	je     80090c <strlcpy+0x34>
			*dst++ = *src++;
  800901:	83 c1 01             	add    $0x1,%ecx
  800904:	83 c2 01             	add    $0x1,%edx
  800907:	88 5a ff             	mov    %bl,-0x1(%edx)
  80090a:	eb ea                	jmp    8008f6 <strlcpy+0x1e>
  80090c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80090e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800911:	29 f0                	sub    %esi,%eax
}
  800913:	5b                   	pop    %ebx
  800914:	5e                   	pop    %esi
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800917:	f3 0f 1e fb          	endbr32 
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800921:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800924:	0f b6 01             	movzbl (%ecx),%eax
  800927:	84 c0                	test   %al,%al
  800929:	74 0c                	je     800937 <strcmp+0x20>
  80092b:	3a 02                	cmp    (%edx),%al
  80092d:	75 08                	jne    800937 <strcmp+0x20>
		p++, q++;
  80092f:	83 c1 01             	add    $0x1,%ecx
  800932:	83 c2 01             	add    $0x1,%edx
  800935:	eb ed                	jmp    800924 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800937:	0f b6 c0             	movzbl %al,%eax
  80093a:	0f b6 12             	movzbl (%edx),%edx
  80093d:	29 d0                	sub    %edx,%eax
}
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800941:	f3 0f 1e fb          	endbr32 
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	53                   	push   %ebx
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094f:	89 c3                	mov    %eax,%ebx
  800951:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800954:	eb 06                	jmp    80095c <strncmp+0x1b>
		n--, p++, q++;
  800956:	83 c0 01             	add    $0x1,%eax
  800959:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80095c:	39 d8                	cmp    %ebx,%eax
  80095e:	74 16                	je     800976 <strncmp+0x35>
  800960:	0f b6 08             	movzbl (%eax),%ecx
  800963:	84 c9                	test   %cl,%cl
  800965:	74 04                	je     80096b <strncmp+0x2a>
  800967:	3a 0a                	cmp    (%edx),%cl
  800969:	74 eb                	je     800956 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80096b:	0f b6 00             	movzbl (%eax),%eax
  80096e:	0f b6 12             	movzbl (%edx),%edx
  800971:	29 d0                	sub    %edx,%eax
}
  800973:	5b                   	pop    %ebx
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    
		return 0;
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
  80097b:	eb f6                	jmp    800973 <strncmp+0x32>

0080097d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097d:	f3 0f 1e fb          	endbr32 
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80098b:	0f b6 10             	movzbl (%eax),%edx
  80098e:	84 d2                	test   %dl,%dl
  800990:	74 09                	je     80099b <strchr+0x1e>
		if (*s == c)
  800992:	38 ca                	cmp    %cl,%dl
  800994:	74 0a                	je     8009a0 <strchr+0x23>
	for (; *s; s++)
  800996:	83 c0 01             	add    $0x1,%eax
  800999:	eb f0                	jmp    80098b <strchr+0xe>
			return (char *) s;
	return 0;
  80099b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009a2:	f3 0f 1e fb          	endbr32 
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009b3:	38 ca                	cmp    %cl,%dl
  8009b5:	74 09                	je     8009c0 <strfind+0x1e>
  8009b7:	84 d2                	test   %dl,%dl
  8009b9:	74 05                	je     8009c0 <strfind+0x1e>
	for (; *s; s++)
  8009bb:	83 c0 01             	add    $0x1,%eax
  8009be:	eb f0                	jmp    8009b0 <strfind+0xe>
			break;
	return (char *) s;
}
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c2:	f3 0f 1e fb          	endbr32 
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	57                   	push   %edi
  8009ca:	56                   	push   %esi
  8009cb:	53                   	push   %ebx
  8009cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d2:	85 c9                	test   %ecx,%ecx
  8009d4:	74 31                	je     800a07 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d6:	89 f8                	mov    %edi,%eax
  8009d8:	09 c8                	or     %ecx,%eax
  8009da:	a8 03                	test   $0x3,%al
  8009dc:	75 23                	jne    800a01 <memset+0x3f>
		c &= 0xFF;
  8009de:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e2:	89 d3                	mov    %edx,%ebx
  8009e4:	c1 e3 08             	shl    $0x8,%ebx
  8009e7:	89 d0                	mov    %edx,%eax
  8009e9:	c1 e0 18             	shl    $0x18,%eax
  8009ec:	89 d6                	mov    %edx,%esi
  8009ee:	c1 e6 10             	shl    $0x10,%esi
  8009f1:	09 f0                	or     %esi,%eax
  8009f3:	09 c2                	or     %eax,%edx
  8009f5:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009f7:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009fa:	89 d0                	mov    %edx,%eax
  8009fc:	fc                   	cld    
  8009fd:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ff:	eb 06                	jmp    800a07 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a04:	fc                   	cld    
  800a05:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a07:	89 f8                	mov    %edi,%eax
  800a09:	5b                   	pop    %ebx
  800a0a:	5e                   	pop    %esi
  800a0b:	5f                   	pop    %edi
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a0e:	f3 0f 1e fb          	endbr32 
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	57                   	push   %edi
  800a16:	56                   	push   %esi
  800a17:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a20:	39 c6                	cmp    %eax,%esi
  800a22:	73 32                	jae    800a56 <memmove+0x48>
  800a24:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a27:	39 c2                	cmp    %eax,%edx
  800a29:	76 2b                	jbe    800a56 <memmove+0x48>
		s += n;
		d += n;
  800a2b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2e:	89 fe                	mov    %edi,%esi
  800a30:	09 ce                	or     %ecx,%esi
  800a32:	09 d6                	or     %edx,%esi
  800a34:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a3a:	75 0e                	jne    800a4a <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a3c:	83 ef 04             	sub    $0x4,%edi
  800a3f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a42:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a45:	fd                   	std    
  800a46:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a48:	eb 09                	jmp    800a53 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a4a:	83 ef 01             	sub    $0x1,%edi
  800a4d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a50:	fd                   	std    
  800a51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a53:	fc                   	cld    
  800a54:	eb 1a                	jmp    800a70 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a56:	89 c2                	mov    %eax,%edx
  800a58:	09 ca                	or     %ecx,%edx
  800a5a:	09 f2                	or     %esi,%edx
  800a5c:	f6 c2 03             	test   $0x3,%dl
  800a5f:	75 0a                	jne    800a6b <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a61:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a64:	89 c7                	mov    %eax,%edi
  800a66:	fc                   	cld    
  800a67:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a69:	eb 05                	jmp    800a70 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a6b:	89 c7                	mov    %eax,%edi
  800a6d:	fc                   	cld    
  800a6e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a70:	5e                   	pop    %esi
  800a71:	5f                   	pop    %edi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a74:	f3 0f 1e fb          	endbr32 
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a7e:	ff 75 10             	pushl  0x10(%ebp)
  800a81:	ff 75 0c             	pushl  0xc(%ebp)
  800a84:	ff 75 08             	pushl  0x8(%ebp)
  800a87:	e8 82 ff ff ff       	call   800a0e <memmove>
}
  800a8c:	c9                   	leave  
  800a8d:	c3                   	ret    

00800a8e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a8e:	f3 0f 1e fb          	endbr32 
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	56                   	push   %esi
  800a96:	53                   	push   %ebx
  800a97:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9d:	89 c6                	mov    %eax,%esi
  800a9f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa2:	39 f0                	cmp    %esi,%eax
  800aa4:	74 1c                	je     800ac2 <memcmp+0x34>
		if (*s1 != *s2)
  800aa6:	0f b6 08             	movzbl (%eax),%ecx
  800aa9:	0f b6 1a             	movzbl (%edx),%ebx
  800aac:	38 d9                	cmp    %bl,%cl
  800aae:	75 08                	jne    800ab8 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ab0:	83 c0 01             	add    $0x1,%eax
  800ab3:	83 c2 01             	add    $0x1,%edx
  800ab6:	eb ea                	jmp    800aa2 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ab8:	0f b6 c1             	movzbl %cl,%eax
  800abb:	0f b6 db             	movzbl %bl,%ebx
  800abe:	29 d8                	sub    %ebx,%eax
  800ac0:	eb 05                	jmp    800ac7 <memcmp+0x39>
	}

	return 0;
  800ac2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac7:	5b                   	pop    %ebx
  800ac8:	5e                   	pop    %esi
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800acb:	f3 0f 1e fb          	endbr32 
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ad8:	89 c2                	mov    %eax,%edx
  800ada:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800add:	39 d0                	cmp    %edx,%eax
  800adf:	73 09                	jae    800aea <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae1:	38 08                	cmp    %cl,(%eax)
  800ae3:	74 05                	je     800aea <memfind+0x1f>
	for (; s < ends; s++)
  800ae5:	83 c0 01             	add    $0x1,%eax
  800ae8:	eb f3                	jmp    800add <memfind+0x12>
			break;
	return (void *) s;
}
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aec:	f3 0f 1e fb          	endbr32 
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	57                   	push   %edi
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
  800af6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800afc:	eb 03                	jmp    800b01 <strtol+0x15>
		s++;
  800afe:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b01:	0f b6 01             	movzbl (%ecx),%eax
  800b04:	3c 20                	cmp    $0x20,%al
  800b06:	74 f6                	je     800afe <strtol+0x12>
  800b08:	3c 09                	cmp    $0x9,%al
  800b0a:	74 f2                	je     800afe <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b0c:	3c 2b                	cmp    $0x2b,%al
  800b0e:	74 2a                	je     800b3a <strtol+0x4e>
	int neg = 0;
  800b10:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b15:	3c 2d                	cmp    $0x2d,%al
  800b17:	74 2b                	je     800b44 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b19:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b1f:	75 0f                	jne    800b30 <strtol+0x44>
  800b21:	80 39 30             	cmpb   $0x30,(%ecx)
  800b24:	74 28                	je     800b4e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b26:	85 db                	test   %ebx,%ebx
  800b28:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b2d:	0f 44 d8             	cmove  %eax,%ebx
  800b30:	b8 00 00 00 00       	mov    $0x0,%eax
  800b35:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b38:	eb 46                	jmp    800b80 <strtol+0x94>
		s++;
  800b3a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b3d:	bf 00 00 00 00       	mov    $0x0,%edi
  800b42:	eb d5                	jmp    800b19 <strtol+0x2d>
		s++, neg = 1;
  800b44:	83 c1 01             	add    $0x1,%ecx
  800b47:	bf 01 00 00 00       	mov    $0x1,%edi
  800b4c:	eb cb                	jmp    800b19 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b4e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b52:	74 0e                	je     800b62 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b54:	85 db                	test   %ebx,%ebx
  800b56:	75 d8                	jne    800b30 <strtol+0x44>
		s++, base = 8;
  800b58:	83 c1 01             	add    $0x1,%ecx
  800b5b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b60:	eb ce                	jmp    800b30 <strtol+0x44>
		s += 2, base = 16;
  800b62:	83 c1 02             	add    $0x2,%ecx
  800b65:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b6a:	eb c4                	jmp    800b30 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b6c:	0f be d2             	movsbl %dl,%edx
  800b6f:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b72:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b75:	7d 3a                	jge    800bb1 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b77:	83 c1 01             	add    $0x1,%ecx
  800b7a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b7e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b80:	0f b6 11             	movzbl (%ecx),%edx
  800b83:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b86:	89 f3                	mov    %esi,%ebx
  800b88:	80 fb 09             	cmp    $0x9,%bl
  800b8b:	76 df                	jbe    800b6c <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b8d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b90:	89 f3                	mov    %esi,%ebx
  800b92:	80 fb 19             	cmp    $0x19,%bl
  800b95:	77 08                	ja     800b9f <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b97:	0f be d2             	movsbl %dl,%edx
  800b9a:	83 ea 57             	sub    $0x57,%edx
  800b9d:	eb d3                	jmp    800b72 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b9f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ba2:	89 f3                	mov    %esi,%ebx
  800ba4:	80 fb 19             	cmp    $0x19,%bl
  800ba7:	77 08                	ja     800bb1 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ba9:	0f be d2             	movsbl %dl,%edx
  800bac:	83 ea 37             	sub    $0x37,%edx
  800baf:	eb c1                	jmp    800b72 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bb1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bb5:	74 05                	je     800bbc <strtol+0xd0>
		*endptr = (char *) s;
  800bb7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bba:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bbc:	89 c2                	mov    %eax,%edx
  800bbe:	f7 da                	neg    %edx
  800bc0:	85 ff                	test   %edi,%edi
  800bc2:	0f 45 c2             	cmovne %edx,%eax
}
  800bc5:	5b                   	pop    %ebx
  800bc6:	5e                   	pop    %esi
  800bc7:	5f                   	pop    %edi
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bca:	f3 0f 1e fb          	endbr32 
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdf:	89 c3                	mov    %eax,%ebx
  800be1:	89 c7                	mov    %eax,%edi
  800be3:	89 c6                	mov    %eax,%esi
  800be5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <sys_cgetc>:

int
sys_cgetc(void)
{
  800bec:	f3 0f 1e fb          	endbr32 
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bf6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfb:	b8 01 00 00 00       	mov    $0x1,%eax
  800c00:	89 d1                	mov    %edx,%ecx
  800c02:	89 d3                	mov    %edx,%ebx
  800c04:	89 d7                	mov    %edx,%edi
  800c06:	89 d6                	mov    %edx,%esi
  800c08:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c0f:	f3 0f 1e fb          	endbr32 
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c21:	8b 55 08             	mov    0x8(%ebp),%edx
  800c24:	b8 03 00 00 00       	mov    $0x3,%eax
  800c29:	89 cb                	mov    %ecx,%ebx
  800c2b:	89 cf                	mov    %ecx,%edi
  800c2d:	89 ce                	mov    %ecx,%esi
  800c2f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c31:	85 c0                	test   %eax,%eax
  800c33:	7f 08                	jg     800c3d <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3d:	83 ec 0c             	sub    $0xc,%esp
  800c40:	50                   	push   %eax
  800c41:	6a 03                	push   $0x3
  800c43:	68 9f 18 80 00       	push   $0x80189f
  800c48:	6a 23                	push   $0x23
  800c4a:	68 bc 18 80 00       	push   $0x8018bc
  800c4f:	e8 14 f5 ff ff       	call   800168 <_panic>

00800c54 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c54:	f3 0f 1e fb          	endbr32 
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c63:	b8 02 00 00 00       	mov    $0x2,%eax
  800c68:	89 d1                	mov    %edx,%ecx
  800c6a:	89 d3                	mov    %edx,%ebx
  800c6c:	89 d7                	mov    %edx,%edi
  800c6e:	89 d6                	mov    %edx,%esi
  800c70:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c72:	5b                   	pop    %ebx
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <sys_yield>:

void
sys_yield(void)
{
  800c77:	f3 0f 1e fb          	endbr32 
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c81:	ba 00 00 00 00       	mov    $0x0,%edx
  800c86:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c8b:	89 d1                	mov    %edx,%ecx
  800c8d:	89 d3                	mov    %edx,%ebx
  800c8f:	89 d7                	mov    %edx,%edi
  800c91:	89 d6                	mov    %edx,%esi
  800c93:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c9a:	f3 0f 1e fb          	endbr32 
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ca7:	be 00 00 00 00       	mov    $0x0,%esi
  800cac:	8b 55 08             	mov    0x8(%ebp),%edx
  800caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb2:	b8 04 00 00 00       	mov    $0x4,%eax
  800cb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cba:	89 f7                	mov    %esi,%edi
  800cbc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cbe:	85 c0                	test   %eax,%eax
  800cc0:	7f 08                	jg     800cca <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cca:	83 ec 0c             	sub    $0xc,%esp
  800ccd:	50                   	push   %eax
  800cce:	6a 04                	push   $0x4
  800cd0:	68 9f 18 80 00       	push   $0x80189f
  800cd5:	6a 23                	push   $0x23
  800cd7:	68 bc 18 80 00       	push   $0x8018bc
  800cdc:	e8 87 f4 ff ff       	call   800168 <_panic>

00800ce1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce1:	f3 0f 1e fb          	endbr32 
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
  800ceb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cee:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf4:	b8 05 00 00 00       	mov    $0x5,%eax
  800cf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cff:	8b 75 18             	mov    0x18(%ebp),%esi
  800d02:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d04:	85 c0                	test   %eax,%eax
  800d06:	7f 08                	jg     800d10 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d10:	83 ec 0c             	sub    $0xc,%esp
  800d13:	50                   	push   %eax
  800d14:	6a 05                	push   $0x5
  800d16:	68 9f 18 80 00       	push   $0x80189f
  800d1b:	6a 23                	push   $0x23
  800d1d:	68 bc 18 80 00       	push   $0x8018bc
  800d22:	e8 41 f4 ff ff       	call   800168 <_panic>

00800d27 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d27:	f3 0f 1e fb          	endbr32 
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	57                   	push   %edi
  800d2f:	56                   	push   %esi
  800d30:	53                   	push   %ebx
  800d31:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3f:	b8 06 00 00 00       	mov    $0x6,%eax
  800d44:	89 df                	mov    %ebx,%edi
  800d46:	89 de                	mov    %ebx,%esi
  800d48:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	7f 08                	jg     800d56 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d56:	83 ec 0c             	sub    $0xc,%esp
  800d59:	50                   	push   %eax
  800d5a:	6a 06                	push   $0x6
  800d5c:	68 9f 18 80 00       	push   $0x80189f
  800d61:	6a 23                	push   $0x23
  800d63:	68 bc 18 80 00       	push   $0x8018bc
  800d68:	e8 fb f3 ff ff       	call   800168 <_panic>

00800d6d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d6d:	f3 0f 1e fb          	endbr32 
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	57                   	push   %edi
  800d75:	56                   	push   %esi
  800d76:	53                   	push   %ebx
  800d77:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d7a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d85:	b8 08 00 00 00       	mov    $0x8,%eax
  800d8a:	89 df                	mov    %ebx,%edi
  800d8c:	89 de                	mov    %ebx,%esi
  800d8e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d90:	85 c0                	test   %eax,%eax
  800d92:	7f 08                	jg     800d9c <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9c:	83 ec 0c             	sub    $0xc,%esp
  800d9f:	50                   	push   %eax
  800da0:	6a 08                	push   $0x8
  800da2:	68 9f 18 80 00       	push   $0x80189f
  800da7:	6a 23                	push   $0x23
  800da9:	68 bc 18 80 00       	push   $0x8018bc
  800dae:	e8 b5 f3 ff ff       	call   800168 <_panic>

00800db3 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800db3:	f3 0f 1e fb          	endbr32 
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	57                   	push   %edi
  800dbb:	56                   	push   %esi
  800dbc:	53                   	push   %ebx
  800dbd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcb:	b8 09 00 00 00       	mov    $0x9,%eax
  800dd0:	89 df                	mov    %ebx,%edi
  800dd2:	89 de                	mov    %ebx,%esi
  800dd4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	7f 08                	jg     800de2 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de2:	83 ec 0c             	sub    $0xc,%esp
  800de5:	50                   	push   %eax
  800de6:	6a 09                	push   $0x9
  800de8:	68 9f 18 80 00       	push   $0x80189f
  800ded:	6a 23                	push   $0x23
  800def:	68 bc 18 80 00       	push   $0x8018bc
  800df4:	e8 6f f3 ff ff       	call   800168 <_panic>

00800df9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df9:	f3 0f 1e fb          	endbr32 
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	57                   	push   %edi
  800e01:	56                   	push   %esi
  800e02:	53                   	push   %ebx
  800e03:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e11:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e16:	89 df                	mov    %ebx,%edi
  800e18:	89 de                	mov    %ebx,%esi
  800e1a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e1c:	85 c0                	test   %eax,%eax
  800e1e:	7f 08                	jg     800e28 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e28:	83 ec 0c             	sub    $0xc,%esp
  800e2b:	50                   	push   %eax
  800e2c:	6a 0a                	push   $0xa
  800e2e:	68 9f 18 80 00       	push   $0x80189f
  800e33:	6a 23                	push   $0x23
  800e35:	68 bc 18 80 00       	push   $0x8018bc
  800e3a:	e8 29 f3 ff ff       	call   800168 <_panic>

00800e3f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e3f:	f3 0f 1e fb          	endbr32 
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	57                   	push   %edi
  800e47:	56                   	push   %esi
  800e48:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e49:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e54:	be 00 00 00 00       	mov    $0x0,%esi
  800e59:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e5f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e61:	5b                   	pop    %ebx
  800e62:	5e                   	pop    %esi
  800e63:	5f                   	pop    %edi
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    

00800e66 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e66:	f3 0f 1e fb          	endbr32 
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	57                   	push   %edi
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e73:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e78:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e80:	89 cb                	mov    %ecx,%ebx
  800e82:	89 cf                	mov    %ecx,%edi
  800e84:	89 ce                	mov    %ecx,%esi
  800e86:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	7f 08                	jg     800e94 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e8f:	5b                   	pop    %ebx
  800e90:	5e                   	pop    %esi
  800e91:	5f                   	pop    %edi
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e94:	83 ec 0c             	sub    $0xc,%esp
  800e97:	50                   	push   %eax
  800e98:	6a 0d                	push   $0xd
  800e9a:	68 9f 18 80 00       	push   $0x80189f
  800e9f:	6a 23                	push   $0x23
  800ea1:	68 bc 18 80 00       	push   $0x8018bc
  800ea6:	e8 bd f2 ff ff       	call   800168 <_panic>

00800eab <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800eab:	f3 0f 1e fb          	endbr32 
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	53                   	push   %ebx
  800eb3:	83 ec 04             	sub    $0x4,%esp
  800eb6:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eb9:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if ( !(err & FEC_WR) ||
  800ebb:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ebf:	74 75                	je     800f36 <pgfault+0x8b>
            !(uvpt[PGNUM(addr)] | PTE_COW) ) {
  800ec1:	89 d8                	mov    %ebx,%eax
  800ec3:	c1 e8 0c             	shr    $0xc,%eax
  800ec6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0) {
  800ecd:	83 ec 04             	sub    $0x4,%esp
  800ed0:	6a 07                	push   $0x7
  800ed2:	68 00 f0 7f 00       	push   $0x7ff000
  800ed7:	6a 00                	push   $0x0
  800ed9:	e8 bc fd ff ff       	call   800c9a <sys_page_alloc>
  800ede:	83 c4 10             	add    $0x10,%esp
  800ee1:	85 c0                	test   %eax,%eax
  800ee3:	78 65                	js     800f4a <pgfault+0x9f>
        panic("sys_page_alloc failed %e\n", r);
    }
    memmove((void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);
  800ee5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800eeb:	83 ec 04             	sub    $0x4,%esp
  800eee:	68 00 10 00 00       	push   $0x1000
  800ef3:	53                   	push   %ebx
  800ef4:	68 00 f0 7f 00       	push   $0x7ff000
  800ef9:	e8 10 fb ff ff       	call   800a0e <memmove>
    if ((r = sys_page_map(0, (void *)PFTEMP,
  800efe:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f05:	53                   	push   %ebx
  800f06:	6a 00                	push   $0x0
  800f08:	68 00 f0 7f 00       	push   $0x7ff000
  800f0d:	6a 00                	push   $0x0
  800f0f:	e8 cd fd ff ff       	call   800ce1 <sys_page_map>
  800f14:	83 c4 20             	add    $0x20,%esp
  800f17:	85 c0                	test   %eax,%eax
  800f19:	78 41                	js     800f5c <pgfault+0xb1>
                0, (void *)PTE_ADDR(addr), PTE_P | PTE_U | PTE_W)) < 0) {
        panic("sys_page_map failed %e\n", r);
    }
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0) {
  800f1b:	83 ec 08             	sub    $0x8,%esp
  800f1e:	68 00 f0 7f 00       	push   $0x7ff000
  800f23:	6a 00                	push   $0x0
  800f25:	e8 fd fd ff ff       	call   800d27 <sys_page_unmap>
  800f2a:	83 c4 10             	add    $0x10,%esp
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	78 3d                	js     800f6e <pgfault+0xc3>
        panic("sys_page_unmap failed %e\n", r);
    }

}
  800f31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f34:	c9                   	leave  
  800f35:	c3                   	ret    
        panic("Not a copy-on-write page");
  800f36:	83 ec 04             	sub    $0x4,%esp
  800f39:	68 ca 18 80 00       	push   $0x8018ca
  800f3e:	6a 1e                	push   $0x1e
  800f40:	68 e3 18 80 00       	push   $0x8018e3
  800f45:	e8 1e f2 ff ff       	call   800168 <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800f4a:	50                   	push   %eax
  800f4b:	68 ee 18 80 00       	push   $0x8018ee
  800f50:	6a 2a                	push   $0x2a
  800f52:	68 e3 18 80 00       	push   $0x8018e3
  800f57:	e8 0c f2 ff ff       	call   800168 <_panic>
        panic("sys_page_map failed %e\n", r);
  800f5c:	50                   	push   %eax
  800f5d:	68 08 19 80 00       	push   $0x801908
  800f62:	6a 2f                	push   $0x2f
  800f64:	68 e3 18 80 00       	push   $0x8018e3
  800f69:	e8 fa f1 ff ff       	call   800168 <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800f6e:	50                   	push   %eax
  800f6f:	68 20 19 80 00       	push   $0x801920
  800f74:	6a 32                	push   $0x32
  800f76:	68 e3 18 80 00       	push   $0x8018e3
  800f7b:	e8 e8 f1 ff ff       	call   800168 <_panic>

00800f80 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f80:	f3 0f 1e fb          	endbr32 
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	57                   	push   %edi
  800f88:	56                   	push   %esi
  800f89:	53                   	push   %ebx
  800f8a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");

    // 1. set pgfault handler.
    set_pgfault_handler(pgfault);
  800f8d:	68 ab 0e 80 00       	push   $0x800eab
  800f92:	e8 8d 02 00 00       	call   801224 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f97:	b8 07 00 00 00       	mov    $0x7,%eax
  800f9c:	cd 30                	int    $0x30
  800f9e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fa1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 2. exofork.
    envid_t envid = sys_exofork();

    if (envid < 0)
  800fa4:	83 c4 10             	add    $0x10,%esp
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	78 2a                	js     800fd5 <fork+0x55>
        thisenv = &envs[ENVX(my_envid)];
        return 0;
    }
    else {
        // parent
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800fab:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800fb0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800fb4:	75 63                	jne    801019 <fork+0x99>
        envid_t my_envid = sys_getenvid();
  800fb6:	e8 99 fc ff ff       	call   800c54 <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800fbb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fc0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fc3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fc8:	a3 04 20 80 00       	mov    %eax,0x802004
        return 0;
  800fcd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fd0:	e9 2f 01 00 00       	jmp    801104 <fork+0x184>
        panic("fork, sys_exofork %e", envid);
  800fd5:	50                   	push   %eax
  800fd6:	68 3a 19 80 00       	push   $0x80193a
  800fdb:	68 82 00 00 00       	push   $0x82
  800fe0:	68 e3 18 80 00       	push   $0x8018e3
  800fe5:	e8 7e f1 ff ff       	call   800168 <_panic>
    	if ((r = sys_page_map(0, addr, envid, addr, pte & PTE_SYSCALL)) < 0) {
  800fea:	83 ec 0c             	sub    $0xc,%esp
  800fed:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff2:	50                   	push   %eax
  800ff3:	56                   	push   %esi
  800ff4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff7:	56                   	push   %esi
  800ff8:	6a 00                	push   $0x0
  800ffa:	e8 e2 fc ff ff       	call   800ce1 <sys_page_map>
  800fff:	83 c4 20             	add    $0x20,%esp
  801002:	85 c0                	test   %eax,%eax
  801004:	0f 88 90 00 00 00    	js     80109a <fork+0x11a>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  80100a:	83 c3 01             	add    $0x1,%ebx
  80100d:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801013:	0f 84 a5 00 00 00    	je     8010be <fork+0x13e>
  801019:	89 de                	mov    %ebx,%esi
  80101b:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  80101e:	89 f0                	mov    %esi,%eax
  801020:	c1 e8 16             	shr    $0x16,%eax
  801023:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80102a:	a8 01                	test   $0x1,%al
  80102c:	74 dc                	je     80100a <fork+0x8a>
                    (uvpt[pn] & PTE_P) ) {
  80102e:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  801035:	a8 01                	test   $0x1,%al
  801037:	74 d1                	je     80100a <fork+0x8a>
    pte_t pte = uvpt[pn];
  801039:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    if ( pte & PTE_SHARE) {
  801040:	f6 c4 04             	test   $0x4,%ah
  801043:	75 a5                	jne    800fea <fork+0x6a>
    if ( ((pte & PTE_W) || (pte & PTE_COW)) && !(pte & PTE_SHARE)) {
  801045:	25 02 08 00 00       	and    $0x802,%eax
        perm |= PTE_COW;
  80104a:	83 f8 01             	cmp    $0x1,%eax
  80104d:	19 ff                	sbb    %edi,%edi
  80104f:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  801055:	81 c7 05 08 00 00    	add    $0x805,%edi
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	57                   	push   %edi
  80105f:	56                   	push   %esi
  801060:	ff 75 e4             	pushl  -0x1c(%ebp)
  801063:	56                   	push   %esi
  801064:	6a 00                	push   $0x0
  801066:	e8 76 fc ff ff       	call   800ce1 <sys_page_map>
  80106b:	83 c4 20             	add    $0x20,%esp
  80106e:	85 c0                	test   %eax,%eax
  801070:	78 3a                	js     8010ac <fork+0x12c>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  801072:	83 ec 0c             	sub    $0xc,%esp
  801075:	57                   	push   %edi
  801076:	56                   	push   %esi
  801077:	6a 00                	push   $0x0
  801079:	56                   	push   %esi
  80107a:	6a 00                	push   $0x0
  80107c:	e8 60 fc ff ff       	call   800ce1 <sys_page_map>
  801081:	83 c4 20             	add    $0x20,%esp
  801084:	85 c0                	test   %eax,%eax
  801086:	79 82                	jns    80100a <fork+0x8a>
            panic("sys_page_map mine failed %e\n", r);
  801088:	50                   	push   %eax
  801089:	68 4f 19 80 00       	push   $0x80194f
  80108e:	6a 5d                	push   $0x5d
  801090:	68 e3 18 80 00       	push   $0x8018e3
  801095:	e8 ce f0 ff ff       	call   800168 <_panic>
    	    panic("sys_page_map others failed %e\n", r);
  80109a:	50                   	push   %eax
  80109b:	68 84 19 80 00       	push   $0x801984
  8010a0:	6a 4d                	push   $0x4d
  8010a2:	68 e3 18 80 00       	push   $0x8018e3
  8010a7:	e8 bc f0 ff ff       	call   800168 <_panic>
        panic("sys_page_map others failed %e\n", r);
  8010ac:	50                   	push   %eax
  8010ad:	68 84 19 80 00       	push   $0x801984
  8010b2:	6a 58                	push   $0x58
  8010b4:	68 e3 18 80 00       	push   $0x8018e3
  8010b9:	e8 aa f0 ff ff       	call   800168 <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  8010be:	83 ec 04             	sub    $0x4,%esp
  8010c1:	6a 07                	push   $0x7
  8010c3:	68 00 f0 bf ee       	push   $0xeebff000
  8010c8:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8010cb:	57                   	push   %edi
  8010cc:	e8 c9 fb ff ff       	call   800c9a <sys_page_alloc>
  8010d1:	83 c4 10             	add    $0x10,%esp
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	78 2c                	js     801104 <fork+0x184>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  8010d8:	a1 04 20 80 00       	mov    0x802004,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  8010dd:	8b 40 64             	mov    0x64(%eax),%eax
  8010e0:	83 ec 08             	sub    $0x8,%esp
  8010e3:	50                   	push   %eax
  8010e4:	57                   	push   %edi
  8010e5:	e8 0f fd ff ff       	call   800df9 <sys_env_set_pgfault_upcall>
  8010ea:	83 c4 10             	add    $0x10,%esp
  8010ed:	85 c0                	test   %eax,%eax
  8010ef:	78 13                	js     801104 <fork+0x184>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8010f1:	83 ec 08             	sub    $0x8,%esp
  8010f4:	6a 02                	push   $0x2
  8010f6:	57                   	push   %edi
  8010f7:	e8 71 fc ff ff       	call   800d6d <sys_env_set_status>
  8010fc:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  8010ff:	85 c0                	test   %eax,%eax
  801101:	0f 49 c7             	cmovns %edi,%eax
    }

}
  801104:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801107:	5b                   	pop    %ebx
  801108:	5e                   	pop    %esi
  801109:	5f                   	pop    %edi
  80110a:	5d                   	pop    %ebp
  80110b:	c3                   	ret    

0080110c <sfork>:

// Challenge!
int
sfork(void)
{
  80110c:	f3 0f 1e fb          	endbr32 
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801116:	68 6c 19 80 00       	push   $0x80196c
  80111b:	68 ac 00 00 00       	push   $0xac
  801120:	68 e3 18 80 00       	push   $0x8018e3
  801125:	e8 3e f0 ff ff       	call   800168 <_panic>

0080112a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80112a:	f3 0f 1e fb          	endbr32 
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	56                   	push   %esi
  801132:	53                   	push   %ebx
  801133:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801136:	8b 45 0c             	mov    0xc(%ebp),%eax
  801139:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)KERNBASE : pg)) < 0) {
  80113c:	85 c0                	test   %eax,%eax
  80113e:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801143:	0f 44 c2             	cmove  %edx,%eax
  801146:	83 ec 0c             	sub    $0xc,%esp
  801149:	50                   	push   %eax
  80114a:	e8 17 fd ff ff       	call   800e66 <sys_ipc_recv>
  80114f:	83 c4 10             	add    $0x10,%esp
  801152:	85 c0                	test   %eax,%eax
  801154:	78 24                	js     80117a <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801156:	85 f6                	test   %esi,%esi
  801158:	74 0a                	je     801164 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  80115a:	a1 04 20 80 00       	mov    0x802004,%eax
  80115f:	8b 40 78             	mov    0x78(%eax),%eax
  801162:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801164:	85 db                	test   %ebx,%ebx
  801166:	74 0a                	je     801172 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801168:	a1 04 20 80 00       	mov    0x802004,%eax
  80116d:	8b 40 74             	mov    0x74(%eax),%eax
  801170:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801172:	a1 04 20 80 00       	mov    0x802004,%eax
  801177:	8b 40 70             	mov    0x70(%eax),%eax
}
  80117a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80117d:	5b                   	pop    %ebx
  80117e:	5e                   	pop    %esi
  80117f:	5d                   	pop    %ebp
  801180:	c3                   	ret    

00801181 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801181:	f3 0f 1e fb          	endbr32 
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
  801188:	57                   	push   %edi
  801189:	56                   	push   %esi
  80118a:	53                   	push   %ebx
  80118b:	83 ec 1c             	sub    $0x1c,%esp
  80118e:	8b 45 10             	mov    0x10(%ebp),%eax
  801191:	85 c0                	test   %eax,%eax
  801193:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801198:	0f 45 d0             	cmovne %eax,%edx
  80119b:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  80119d:	be 01 00 00 00       	mov    $0x1,%esi
  8011a2:	eb 1f                	jmp    8011c3 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  8011a4:	e8 ce fa ff ff       	call   800c77 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  8011a9:	83 c3 01             	add    $0x1,%ebx
  8011ac:	39 de                	cmp    %ebx,%esi
  8011ae:	7f f4                	jg     8011a4 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  8011b0:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  8011b2:	83 fe 11             	cmp    $0x11,%esi
  8011b5:	b8 01 00 00 00       	mov    $0x1,%eax
  8011ba:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  8011bd:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  8011c1:	75 1c                	jne    8011df <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  8011c3:	ff 75 14             	pushl  0x14(%ebp)
  8011c6:	57                   	push   %edi
  8011c7:	ff 75 0c             	pushl  0xc(%ebp)
  8011ca:	ff 75 08             	pushl  0x8(%ebp)
  8011cd:	e8 6d fc ff ff       	call   800e3f <sys_ipc_try_send>
  8011d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011dd:	eb cd                	jmp    8011ac <ipc_send+0x2b>
}
  8011df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e2:	5b                   	pop    %ebx
  8011e3:	5e                   	pop    %esi
  8011e4:	5f                   	pop    %edi
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011e7:	f3 0f 1e fb          	endbr32 
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011f1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011f6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011f9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011ff:	8b 52 50             	mov    0x50(%edx),%edx
  801202:	39 ca                	cmp    %ecx,%edx
  801204:	74 11                	je     801217 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801206:	83 c0 01             	add    $0x1,%eax
  801209:	3d 00 04 00 00       	cmp    $0x400,%eax
  80120e:	75 e6                	jne    8011f6 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801210:	b8 00 00 00 00       	mov    $0x0,%eax
  801215:	eb 0b                	jmp    801222 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801217:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80121a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80121f:	8b 40 48             	mov    0x48(%eax),%eax
}
  801222:	5d                   	pop    %ebp
  801223:	c3                   	ret    

00801224 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801224:	f3 0f 1e fb          	endbr32 
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80122e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801235:	74 0a                	je     801241 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801237:	8b 45 08             	mov    0x8(%ebp),%eax
  80123a:	a3 08 20 80 00       	mov    %eax,0x802008
}
  80123f:	c9                   	leave  
  801240:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801241:	83 ec 0c             	sub    $0xc,%esp
  801244:	68 a3 19 80 00       	push   $0x8019a3
  801249:	e8 01 f0 ff ff       	call   80024f <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  80124e:	83 c4 0c             	add    $0xc,%esp
  801251:	6a 07                	push   $0x7
  801253:	68 00 f0 bf ee       	push   $0xeebff000
  801258:	6a 00                	push   $0x0
  80125a:	e8 3b fa ff ff       	call   800c9a <sys_page_alloc>
  80125f:	83 c4 10             	add    $0x10,%esp
  801262:	85 c0                	test   %eax,%eax
  801264:	78 2a                	js     801290 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801266:	83 ec 08             	sub    $0x8,%esp
  801269:	68 a4 12 80 00       	push   $0x8012a4
  80126e:	6a 00                	push   $0x0
  801270:	e8 84 fb ff ff       	call   800df9 <sys_env_set_pgfault_upcall>
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	85 c0                	test   %eax,%eax
  80127a:	79 bb                	jns    801237 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  80127c:	83 ec 04             	sub    $0x4,%esp
  80127f:	68 e0 19 80 00       	push   $0x8019e0
  801284:	6a 25                	push   $0x25
  801286:	68 d0 19 80 00       	push   $0x8019d0
  80128b:	e8 d8 ee ff ff       	call   800168 <_panic>
            panic("Allocation of UXSTACK failed!");
  801290:	83 ec 04             	sub    $0x4,%esp
  801293:	68 b2 19 80 00       	push   $0x8019b2
  801298:	6a 22                	push   $0x22
  80129a:	68 d0 19 80 00       	push   $0x8019d0
  80129f:	e8 c4 ee ff ff       	call   800168 <_panic>

008012a4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012a4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012a5:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8012aa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012ac:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  8012af:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  8012b3:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  8012b7:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  8012ba:	83 c4 08             	add    $0x8,%esp
    popa
  8012bd:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  8012be:	83 c4 04             	add    $0x4,%esp
    popf
  8012c1:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  8012c2:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  8012c5:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  8012c9:	c3                   	ret    
  8012ca:	66 90                	xchg   %ax,%ax
  8012cc:	66 90                	xchg   %ax,%ax
  8012ce:	66 90                	xchg   %ax,%ax

008012d0 <__udivdi3>:
  8012d0:	f3 0f 1e fb          	endbr32 
  8012d4:	55                   	push   %ebp
  8012d5:	57                   	push   %edi
  8012d6:	56                   	push   %esi
  8012d7:	53                   	push   %ebx
  8012d8:	83 ec 1c             	sub    $0x1c,%esp
  8012db:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8012df:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8012e3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8012e7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8012eb:	85 d2                	test   %edx,%edx
  8012ed:	75 19                	jne    801308 <__udivdi3+0x38>
  8012ef:	39 f3                	cmp    %esi,%ebx
  8012f1:	76 4d                	jbe    801340 <__udivdi3+0x70>
  8012f3:	31 ff                	xor    %edi,%edi
  8012f5:	89 e8                	mov    %ebp,%eax
  8012f7:	89 f2                	mov    %esi,%edx
  8012f9:	f7 f3                	div    %ebx
  8012fb:	89 fa                	mov    %edi,%edx
  8012fd:	83 c4 1c             	add    $0x1c,%esp
  801300:	5b                   	pop    %ebx
  801301:	5e                   	pop    %esi
  801302:	5f                   	pop    %edi
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    
  801305:	8d 76 00             	lea    0x0(%esi),%esi
  801308:	39 f2                	cmp    %esi,%edx
  80130a:	76 14                	jbe    801320 <__udivdi3+0x50>
  80130c:	31 ff                	xor    %edi,%edi
  80130e:	31 c0                	xor    %eax,%eax
  801310:	89 fa                	mov    %edi,%edx
  801312:	83 c4 1c             	add    $0x1c,%esp
  801315:	5b                   	pop    %ebx
  801316:	5e                   	pop    %esi
  801317:	5f                   	pop    %edi
  801318:	5d                   	pop    %ebp
  801319:	c3                   	ret    
  80131a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801320:	0f bd fa             	bsr    %edx,%edi
  801323:	83 f7 1f             	xor    $0x1f,%edi
  801326:	75 48                	jne    801370 <__udivdi3+0xa0>
  801328:	39 f2                	cmp    %esi,%edx
  80132a:	72 06                	jb     801332 <__udivdi3+0x62>
  80132c:	31 c0                	xor    %eax,%eax
  80132e:	39 eb                	cmp    %ebp,%ebx
  801330:	77 de                	ja     801310 <__udivdi3+0x40>
  801332:	b8 01 00 00 00       	mov    $0x1,%eax
  801337:	eb d7                	jmp    801310 <__udivdi3+0x40>
  801339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801340:	89 d9                	mov    %ebx,%ecx
  801342:	85 db                	test   %ebx,%ebx
  801344:	75 0b                	jne    801351 <__udivdi3+0x81>
  801346:	b8 01 00 00 00       	mov    $0x1,%eax
  80134b:	31 d2                	xor    %edx,%edx
  80134d:	f7 f3                	div    %ebx
  80134f:	89 c1                	mov    %eax,%ecx
  801351:	31 d2                	xor    %edx,%edx
  801353:	89 f0                	mov    %esi,%eax
  801355:	f7 f1                	div    %ecx
  801357:	89 c6                	mov    %eax,%esi
  801359:	89 e8                	mov    %ebp,%eax
  80135b:	89 f7                	mov    %esi,%edi
  80135d:	f7 f1                	div    %ecx
  80135f:	89 fa                	mov    %edi,%edx
  801361:	83 c4 1c             	add    $0x1c,%esp
  801364:	5b                   	pop    %ebx
  801365:	5e                   	pop    %esi
  801366:	5f                   	pop    %edi
  801367:	5d                   	pop    %ebp
  801368:	c3                   	ret    
  801369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801370:	89 f9                	mov    %edi,%ecx
  801372:	b8 20 00 00 00       	mov    $0x20,%eax
  801377:	29 f8                	sub    %edi,%eax
  801379:	d3 e2                	shl    %cl,%edx
  80137b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80137f:	89 c1                	mov    %eax,%ecx
  801381:	89 da                	mov    %ebx,%edx
  801383:	d3 ea                	shr    %cl,%edx
  801385:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801389:	09 d1                	or     %edx,%ecx
  80138b:	89 f2                	mov    %esi,%edx
  80138d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801391:	89 f9                	mov    %edi,%ecx
  801393:	d3 e3                	shl    %cl,%ebx
  801395:	89 c1                	mov    %eax,%ecx
  801397:	d3 ea                	shr    %cl,%edx
  801399:	89 f9                	mov    %edi,%ecx
  80139b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80139f:	89 eb                	mov    %ebp,%ebx
  8013a1:	d3 e6                	shl    %cl,%esi
  8013a3:	89 c1                	mov    %eax,%ecx
  8013a5:	d3 eb                	shr    %cl,%ebx
  8013a7:	09 de                	or     %ebx,%esi
  8013a9:	89 f0                	mov    %esi,%eax
  8013ab:	f7 74 24 08          	divl   0x8(%esp)
  8013af:	89 d6                	mov    %edx,%esi
  8013b1:	89 c3                	mov    %eax,%ebx
  8013b3:	f7 64 24 0c          	mull   0xc(%esp)
  8013b7:	39 d6                	cmp    %edx,%esi
  8013b9:	72 15                	jb     8013d0 <__udivdi3+0x100>
  8013bb:	89 f9                	mov    %edi,%ecx
  8013bd:	d3 e5                	shl    %cl,%ebp
  8013bf:	39 c5                	cmp    %eax,%ebp
  8013c1:	73 04                	jae    8013c7 <__udivdi3+0xf7>
  8013c3:	39 d6                	cmp    %edx,%esi
  8013c5:	74 09                	je     8013d0 <__udivdi3+0x100>
  8013c7:	89 d8                	mov    %ebx,%eax
  8013c9:	31 ff                	xor    %edi,%edi
  8013cb:	e9 40 ff ff ff       	jmp    801310 <__udivdi3+0x40>
  8013d0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8013d3:	31 ff                	xor    %edi,%edi
  8013d5:	e9 36 ff ff ff       	jmp    801310 <__udivdi3+0x40>
  8013da:	66 90                	xchg   %ax,%ax
  8013dc:	66 90                	xchg   %ax,%ax
  8013de:	66 90                	xchg   %ax,%ax

008013e0 <__umoddi3>:
  8013e0:	f3 0f 1e fb          	endbr32 
  8013e4:	55                   	push   %ebp
  8013e5:	57                   	push   %edi
  8013e6:	56                   	push   %esi
  8013e7:	53                   	push   %ebx
  8013e8:	83 ec 1c             	sub    $0x1c,%esp
  8013eb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8013ef:	8b 74 24 30          	mov    0x30(%esp),%esi
  8013f3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8013f7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	75 19                	jne    801418 <__umoddi3+0x38>
  8013ff:	39 df                	cmp    %ebx,%edi
  801401:	76 5d                	jbe    801460 <__umoddi3+0x80>
  801403:	89 f0                	mov    %esi,%eax
  801405:	89 da                	mov    %ebx,%edx
  801407:	f7 f7                	div    %edi
  801409:	89 d0                	mov    %edx,%eax
  80140b:	31 d2                	xor    %edx,%edx
  80140d:	83 c4 1c             	add    $0x1c,%esp
  801410:	5b                   	pop    %ebx
  801411:	5e                   	pop    %esi
  801412:	5f                   	pop    %edi
  801413:	5d                   	pop    %ebp
  801414:	c3                   	ret    
  801415:	8d 76 00             	lea    0x0(%esi),%esi
  801418:	89 f2                	mov    %esi,%edx
  80141a:	39 d8                	cmp    %ebx,%eax
  80141c:	76 12                	jbe    801430 <__umoddi3+0x50>
  80141e:	89 f0                	mov    %esi,%eax
  801420:	89 da                	mov    %ebx,%edx
  801422:	83 c4 1c             	add    $0x1c,%esp
  801425:	5b                   	pop    %ebx
  801426:	5e                   	pop    %esi
  801427:	5f                   	pop    %edi
  801428:	5d                   	pop    %ebp
  801429:	c3                   	ret    
  80142a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801430:	0f bd e8             	bsr    %eax,%ebp
  801433:	83 f5 1f             	xor    $0x1f,%ebp
  801436:	75 50                	jne    801488 <__umoddi3+0xa8>
  801438:	39 d8                	cmp    %ebx,%eax
  80143a:	0f 82 e0 00 00 00    	jb     801520 <__umoddi3+0x140>
  801440:	89 d9                	mov    %ebx,%ecx
  801442:	39 f7                	cmp    %esi,%edi
  801444:	0f 86 d6 00 00 00    	jbe    801520 <__umoddi3+0x140>
  80144a:	89 d0                	mov    %edx,%eax
  80144c:	89 ca                	mov    %ecx,%edx
  80144e:	83 c4 1c             	add    $0x1c,%esp
  801451:	5b                   	pop    %ebx
  801452:	5e                   	pop    %esi
  801453:	5f                   	pop    %edi
  801454:	5d                   	pop    %ebp
  801455:	c3                   	ret    
  801456:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80145d:	8d 76 00             	lea    0x0(%esi),%esi
  801460:	89 fd                	mov    %edi,%ebp
  801462:	85 ff                	test   %edi,%edi
  801464:	75 0b                	jne    801471 <__umoddi3+0x91>
  801466:	b8 01 00 00 00       	mov    $0x1,%eax
  80146b:	31 d2                	xor    %edx,%edx
  80146d:	f7 f7                	div    %edi
  80146f:	89 c5                	mov    %eax,%ebp
  801471:	89 d8                	mov    %ebx,%eax
  801473:	31 d2                	xor    %edx,%edx
  801475:	f7 f5                	div    %ebp
  801477:	89 f0                	mov    %esi,%eax
  801479:	f7 f5                	div    %ebp
  80147b:	89 d0                	mov    %edx,%eax
  80147d:	31 d2                	xor    %edx,%edx
  80147f:	eb 8c                	jmp    80140d <__umoddi3+0x2d>
  801481:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801488:	89 e9                	mov    %ebp,%ecx
  80148a:	ba 20 00 00 00       	mov    $0x20,%edx
  80148f:	29 ea                	sub    %ebp,%edx
  801491:	d3 e0                	shl    %cl,%eax
  801493:	89 44 24 08          	mov    %eax,0x8(%esp)
  801497:	89 d1                	mov    %edx,%ecx
  801499:	89 f8                	mov    %edi,%eax
  80149b:	d3 e8                	shr    %cl,%eax
  80149d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8014a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014a5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8014a9:	09 c1                	or     %eax,%ecx
  8014ab:	89 d8                	mov    %ebx,%eax
  8014ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014b1:	89 e9                	mov    %ebp,%ecx
  8014b3:	d3 e7                	shl    %cl,%edi
  8014b5:	89 d1                	mov    %edx,%ecx
  8014b7:	d3 e8                	shr    %cl,%eax
  8014b9:	89 e9                	mov    %ebp,%ecx
  8014bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014bf:	d3 e3                	shl    %cl,%ebx
  8014c1:	89 c7                	mov    %eax,%edi
  8014c3:	89 d1                	mov    %edx,%ecx
  8014c5:	89 f0                	mov    %esi,%eax
  8014c7:	d3 e8                	shr    %cl,%eax
  8014c9:	89 e9                	mov    %ebp,%ecx
  8014cb:	89 fa                	mov    %edi,%edx
  8014cd:	d3 e6                	shl    %cl,%esi
  8014cf:	09 d8                	or     %ebx,%eax
  8014d1:	f7 74 24 08          	divl   0x8(%esp)
  8014d5:	89 d1                	mov    %edx,%ecx
  8014d7:	89 f3                	mov    %esi,%ebx
  8014d9:	f7 64 24 0c          	mull   0xc(%esp)
  8014dd:	89 c6                	mov    %eax,%esi
  8014df:	89 d7                	mov    %edx,%edi
  8014e1:	39 d1                	cmp    %edx,%ecx
  8014e3:	72 06                	jb     8014eb <__umoddi3+0x10b>
  8014e5:	75 10                	jne    8014f7 <__umoddi3+0x117>
  8014e7:	39 c3                	cmp    %eax,%ebx
  8014e9:	73 0c                	jae    8014f7 <__umoddi3+0x117>
  8014eb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8014ef:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8014f3:	89 d7                	mov    %edx,%edi
  8014f5:	89 c6                	mov    %eax,%esi
  8014f7:	89 ca                	mov    %ecx,%edx
  8014f9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8014fe:	29 f3                	sub    %esi,%ebx
  801500:	19 fa                	sbb    %edi,%edx
  801502:	89 d0                	mov    %edx,%eax
  801504:	d3 e0                	shl    %cl,%eax
  801506:	89 e9                	mov    %ebp,%ecx
  801508:	d3 eb                	shr    %cl,%ebx
  80150a:	d3 ea                	shr    %cl,%edx
  80150c:	09 d8                	or     %ebx,%eax
  80150e:	83 c4 1c             	add    $0x1c,%esp
  801511:	5b                   	pop    %ebx
  801512:	5e                   	pop    %esi
  801513:	5f                   	pop    %edi
  801514:	5d                   	pop    %ebp
  801515:	c3                   	ret    
  801516:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80151d:	8d 76 00             	lea    0x0(%esi),%esi
  801520:	29 fe                	sub    %edi,%esi
  801522:	19 c3                	sbb    %eax,%ebx
  801524:	89 f2                	mov    %esi,%edx
  801526:	89 d9                	mov    %ebx,%ecx
  801528:	e9 1d ff ff ff       	jmp    80144a <__umoddi3+0x6a>
