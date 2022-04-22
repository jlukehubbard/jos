
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
  80004b:	e8 af 10 00 00       	call   8010ff <ipc_recv>
  800050:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  800052:	a1 04 40 80 00       	mov    0x804004,%eax
  800057:	8b 40 5c             	mov    0x5c(%eax),%eax
  80005a:	83 c4 0c             	add    $0xc,%esp
  80005d:	53                   	push   %ebx
  80005e:	50                   	push   %eax
  80005f:	68 a0 22 80 00       	push   $0x8022a0
  800064:	e8 ee 01 00 00       	call   800257 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800069:	e8 1a 0f 00 00       	call   800f88 <fork>
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
  80007f:	68 ac 22 80 00       	push   $0x8022ac
  800084:	6a 1a                	push   $0x1a
  800086:	68 b5 22 80 00       	push   $0x8022b5
  80008b:	e8 e0 00 00 00       	call   800170 <_panic>
		if (i % p)
			ipc_send(id, i, 0, 0);
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	51                   	push   %ecx
  800095:	57                   	push   %edi
  800096:	e8 bb 10 00 00       	call   801156 <ipc_send>
  80009b:	83 c4 10             	add    $0x10,%esp
		i = ipc_recv(&envid, 0, 0);
  80009e:	83 ec 04             	sub    $0x4,%esp
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	56                   	push   %esi
  8000a6:	e8 54 10 00 00       	call   8010ff <ipc_recv>
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
  8000c2:	e8 c1 0e 00 00       	call   800f88 <fork>
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
  8000da:	e8 77 10 00 00       	call   801156 <ipc_send>
	for (i = 2; ; i++)
  8000df:	83 c3 01             	add    $0x1,%ebx
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb ed                	jmp    8000d4 <umain+0x1b>
		panic("fork: %e", id);
  8000e7:	50                   	push   %eax
  8000e8:	68 ac 22 80 00       	push   $0x8022ac
  8000ed:	6a 2d                	push   $0x2d
  8000ef:	68 b5 22 80 00       	push   $0x8022b5
  8000f4:	e8 77 00 00 00       	call   800170 <_panic>
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
  80010d:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800114:	00 00 00 
    envid_t envid = sys_getenvid();
  800117:	e8 40 0b 00 00       	call   800c5c <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  80011c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800121:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800124:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800129:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012e:	85 db                	test   %ebx,%ebx
  800130:	7e 07                	jle    800139 <libmain+0x3b>
		binaryname = argv[0];
  800132:	8b 06                	mov    (%esi),%eax
  800134:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800159:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80015c:	e8 87 12 00 00       	call   8013e8 <close_all>
	sys_env_destroy(0);
  800161:	83 ec 0c             	sub    $0xc,%esp
  800164:	6a 00                	push   $0x0
  800166:	e8 ac 0a 00 00       	call   800c17 <sys_env_destroy>
}
  80016b:	83 c4 10             	add    $0x10,%esp
  80016e:	c9                   	leave  
  80016f:	c3                   	ret    

00800170 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800170:	f3 0f 1e fb          	endbr32 
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	56                   	push   %esi
  800178:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800179:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80017c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800182:	e8 d5 0a 00 00       	call   800c5c <sys_getenvid>
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	ff 75 0c             	pushl  0xc(%ebp)
  80018d:	ff 75 08             	pushl  0x8(%ebp)
  800190:	56                   	push   %esi
  800191:	50                   	push   %eax
  800192:	68 d0 22 80 00       	push   $0x8022d0
  800197:	e8 bb 00 00 00       	call   800257 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80019c:	83 c4 18             	add    $0x18,%esp
  80019f:	53                   	push   %ebx
  8001a0:	ff 75 10             	pushl  0x10(%ebp)
  8001a3:	e8 5a 00 00 00       	call   800202 <vcprintf>
	cprintf("\n");
  8001a8:	c7 04 24 fb 27 80 00 	movl   $0x8027fb,(%esp)
  8001af:	e8 a3 00 00 00       	call   800257 <cprintf>
  8001b4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b7:	cc                   	int3   
  8001b8:	eb fd                	jmp    8001b7 <_panic+0x47>

008001ba <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ba:	f3 0f 1e fb          	endbr32 
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 04             	sub    $0x4,%esp
  8001c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c8:	8b 13                	mov    (%ebx),%edx
  8001ca:	8d 42 01             	lea    0x1(%edx),%eax
  8001cd:	89 03                	mov    %eax,(%ebx)
  8001cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001db:	74 09                	je     8001e6 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001dd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001e6:	83 ec 08             	sub    $0x8,%esp
  8001e9:	68 ff 00 00 00       	push   $0xff
  8001ee:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f1:	50                   	push   %eax
  8001f2:	e8 db 09 00 00       	call   800bd2 <sys_cputs>
		b->idx = 0;
  8001f7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001fd:	83 c4 10             	add    $0x10,%esp
  800200:	eb db                	jmp    8001dd <putch+0x23>

00800202 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800202:	f3 0f 1e fb          	endbr32 
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80020f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800216:	00 00 00 
	b.cnt = 0;
  800219:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800220:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800223:	ff 75 0c             	pushl  0xc(%ebp)
  800226:	ff 75 08             	pushl  0x8(%ebp)
  800229:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80022f:	50                   	push   %eax
  800230:	68 ba 01 80 00       	push   $0x8001ba
  800235:	e8 20 01 00 00       	call   80035a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80023a:	83 c4 08             	add    $0x8,%esp
  80023d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800243:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800249:	50                   	push   %eax
  80024a:	e8 83 09 00 00       	call   800bd2 <sys_cputs>

	return b.cnt;
}
  80024f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800255:	c9                   	leave  
  800256:	c3                   	ret    

00800257 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800257:	f3 0f 1e fb          	endbr32 
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800261:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800264:	50                   	push   %eax
  800265:	ff 75 08             	pushl  0x8(%ebp)
  800268:	e8 95 ff ff ff       	call   800202 <vcprintf>
	va_end(ap);

	return cnt;
}
  80026d:	c9                   	leave  
  80026e:	c3                   	ret    

0080026f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 1c             	sub    $0x1c,%esp
  800278:	89 c7                	mov    %eax,%edi
  80027a:	89 d6                	mov    %edx,%esi
  80027c:	8b 45 08             	mov    0x8(%ebp),%eax
  80027f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800282:	89 d1                	mov    %edx,%ecx
  800284:	89 c2                	mov    %eax,%edx
  800286:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800289:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80028c:	8b 45 10             	mov    0x10(%ebp),%eax
  80028f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800292:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800295:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80029c:	39 c2                	cmp    %eax,%edx
  80029e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002a1:	72 3e                	jb     8002e1 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a3:	83 ec 0c             	sub    $0xc,%esp
  8002a6:	ff 75 18             	pushl  0x18(%ebp)
  8002a9:	83 eb 01             	sub    $0x1,%ebx
  8002ac:	53                   	push   %ebx
  8002ad:	50                   	push   %eax
  8002ae:	83 ec 08             	sub    $0x8,%esp
  8002b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ba:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bd:	e8 6e 1d 00 00       	call   802030 <__udivdi3>
  8002c2:	83 c4 18             	add    $0x18,%esp
  8002c5:	52                   	push   %edx
  8002c6:	50                   	push   %eax
  8002c7:	89 f2                	mov    %esi,%edx
  8002c9:	89 f8                	mov    %edi,%eax
  8002cb:	e8 9f ff ff ff       	call   80026f <printnum>
  8002d0:	83 c4 20             	add    $0x20,%esp
  8002d3:	eb 13                	jmp    8002e8 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d5:	83 ec 08             	sub    $0x8,%esp
  8002d8:	56                   	push   %esi
  8002d9:	ff 75 18             	pushl  0x18(%ebp)
  8002dc:	ff d7                	call   *%edi
  8002de:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002e1:	83 eb 01             	sub    $0x1,%ebx
  8002e4:	85 db                	test   %ebx,%ebx
  8002e6:	7f ed                	jg     8002d5 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	56                   	push   %esi
  8002ec:	83 ec 04             	sub    $0x4,%esp
  8002ef:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002f5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002fb:	e8 40 1e 00 00       	call   802140 <__umoddi3>
  800300:	83 c4 14             	add    $0x14,%esp
  800303:	0f be 80 f3 22 80 00 	movsbl 0x8022f3(%eax),%eax
  80030a:	50                   	push   %eax
  80030b:	ff d7                	call   *%edi
}
  80030d:	83 c4 10             	add    $0x10,%esp
  800310:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800313:	5b                   	pop    %ebx
  800314:	5e                   	pop    %esi
  800315:	5f                   	pop    %edi
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800318:	f3 0f 1e fb          	endbr32 
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800322:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800326:	8b 10                	mov    (%eax),%edx
  800328:	3b 50 04             	cmp    0x4(%eax),%edx
  80032b:	73 0a                	jae    800337 <sprintputch+0x1f>
		*b->buf++ = ch;
  80032d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800330:	89 08                	mov    %ecx,(%eax)
  800332:	8b 45 08             	mov    0x8(%ebp),%eax
  800335:	88 02                	mov    %al,(%edx)
}
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    

00800339 <printfmt>:
{
  800339:	f3 0f 1e fb          	endbr32 
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800343:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800346:	50                   	push   %eax
  800347:	ff 75 10             	pushl  0x10(%ebp)
  80034a:	ff 75 0c             	pushl  0xc(%ebp)
  80034d:	ff 75 08             	pushl  0x8(%ebp)
  800350:	e8 05 00 00 00       	call   80035a <vprintfmt>
}
  800355:	83 c4 10             	add    $0x10,%esp
  800358:	c9                   	leave  
  800359:	c3                   	ret    

0080035a <vprintfmt>:
{
  80035a:	f3 0f 1e fb          	endbr32 
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	57                   	push   %edi
  800362:	56                   	push   %esi
  800363:	53                   	push   %ebx
  800364:	83 ec 3c             	sub    $0x3c,%esp
  800367:	8b 75 08             	mov    0x8(%ebp),%esi
  80036a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800370:	e9 4a 03 00 00       	jmp    8006bf <vprintfmt+0x365>
		padc = ' ';
  800375:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800379:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800380:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800387:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80038e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8d 47 01             	lea    0x1(%edi),%eax
  800396:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800399:	0f b6 17             	movzbl (%edi),%edx
  80039c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80039f:	3c 55                	cmp    $0x55,%al
  8003a1:	0f 87 de 03 00 00    	ja     800785 <vprintfmt+0x42b>
  8003a7:	0f b6 c0             	movzbl %al,%eax
  8003aa:	3e ff 24 85 40 24 80 	notrack jmp *0x802440(,%eax,4)
  8003b1:	00 
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003b5:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003b9:	eb d8                	jmp    800393 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003be:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003c2:	eb cf                	jmp    800393 <vprintfmt+0x39>
  8003c4:	0f b6 d2             	movzbl %dl,%edx
  8003c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003d2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003d5:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003d9:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003dc:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003df:	83 f9 09             	cmp    $0x9,%ecx
  8003e2:	77 55                	ja     800439 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003e4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003e7:	eb e9                	jmp    8003d2 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ec:	8b 00                	mov    (%eax),%eax
  8003ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 40 04             	lea    0x4(%eax),%eax
  8003f7:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003fd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800401:	79 90                	jns    800393 <vprintfmt+0x39>
				width = precision, precision = -1;
  800403:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800406:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800409:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800410:	eb 81                	jmp    800393 <vprintfmt+0x39>
  800412:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800415:	85 c0                	test   %eax,%eax
  800417:	ba 00 00 00 00       	mov    $0x0,%edx
  80041c:	0f 49 d0             	cmovns %eax,%edx
  80041f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800425:	e9 69 ff ff ff       	jmp    800393 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80042d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800434:	e9 5a ff ff ff       	jmp    800393 <vprintfmt+0x39>
  800439:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80043c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80043f:	eb bc                	jmp    8003fd <vprintfmt+0xa3>
			lflag++;
  800441:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800447:	e9 47 ff ff ff       	jmp    800393 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80044c:	8b 45 14             	mov    0x14(%ebp),%eax
  80044f:	8d 78 04             	lea    0x4(%eax),%edi
  800452:	83 ec 08             	sub    $0x8,%esp
  800455:	53                   	push   %ebx
  800456:	ff 30                	pushl  (%eax)
  800458:	ff d6                	call   *%esi
			break;
  80045a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80045d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800460:	e9 57 02 00 00       	jmp    8006bc <vprintfmt+0x362>
			err = va_arg(ap, int);
  800465:	8b 45 14             	mov    0x14(%ebp),%eax
  800468:	8d 78 04             	lea    0x4(%eax),%edi
  80046b:	8b 00                	mov    (%eax),%eax
  80046d:	99                   	cltd   
  80046e:	31 d0                	xor    %edx,%eax
  800470:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800472:	83 f8 0f             	cmp    $0xf,%eax
  800475:	7f 23                	jg     80049a <vprintfmt+0x140>
  800477:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  80047e:	85 d2                	test   %edx,%edx
  800480:	74 18                	je     80049a <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800482:	52                   	push   %edx
  800483:	68 a9 27 80 00       	push   $0x8027a9
  800488:	53                   	push   %ebx
  800489:	56                   	push   %esi
  80048a:	e8 aa fe ff ff       	call   800339 <printfmt>
  80048f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800492:	89 7d 14             	mov    %edi,0x14(%ebp)
  800495:	e9 22 02 00 00       	jmp    8006bc <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  80049a:	50                   	push   %eax
  80049b:	68 0b 23 80 00       	push   $0x80230b
  8004a0:	53                   	push   %ebx
  8004a1:	56                   	push   %esi
  8004a2:	e8 92 fe ff ff       	call   800339 <printfmt>
  8004a7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004aa:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004ad:	e9 0a 02 00 00       	jmp    8006bc <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	83 c0 04             	add    $0x4,%eax
  8004b8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004be:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004c0:	85 d2                	test   %edx,%edx
  8004c2:	b8 04 23 80 00       	mov    $0x802304,%eax
  8004c7:	0f 45 c2             	cmovne %edx,%eax
  8004ca:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d1:	7e 06                	jle    8004d9 <vprintfmt+0x17f>
  8004d3:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004d7:	75 0d                	jne    8004e6 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004dc:	89 c7                	mov    %eax,%edi
  8004de:	03 45 e0             	add    -0x20(%ebp),%eax
  8004e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e4:	eb 55                	jmp    80053b <vprintfmt+0x1e1>
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ec:	ff 75 cc             	pushl  -0x34(%ebp)
  8004ef:	e8 45 03 00 00       	call   800839 <strnlen>
  8004f4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004f7:	29 c2                	sub    %eax,%edx
  8004f9:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004fc:	83 c4 10             	add    $0x10,%esp
  8004ff:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800501:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800505:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800508:	85 ff                	test   %edi,%edi
  80050a:	7e 11                	jle    80051d <vprintfmt+0x1c3>
					putch(padc, putdat);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 e0             	pushl  -0x20(%ebp)
  800513:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800515:	83 ef 01             	sub    $0x1,%edi
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	eb eb                	jmp    800508 <vprintfmt+0x1ae>
  80051d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800520:	85 d2                	test   %edx,%edx
  800522:	b8 00 00 00 00       	mov    $0x0,%eax
  800527:	0f 49 c2             	cmovns %edx,%eax
  80052a:	29 c2                	sub    %eax,%edx
  80052c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80052f:	eb a8                	jmp    8004d9 <vprintfmt+0x17f>
					putch(ch, putdat);
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	53                   	push   %ebx
  800535:	52                   	push   %edx
  800536:	ff d6                	call   *%esi
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80053e:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800540:	83 c7 01             	add    $0x1,%edi
  800543:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800547:	0f be d0             	movsbl %al,%edx
  80054a:	85 d2                	test   %edx,%edx
  80054c:	74 4b                	je     800599 <vprintfmt+0x23f>
  80054e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800552:	78 06                	js     80055a <vprintfmt+0x200>
  800554:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800558:	78 1e                	js     800578 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80055a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80055e:	74 d1                	je     800531 <vprintfmt+0x1d7>
  800560:	0f be c0             	movsbl %al,%eax
  800563:	83 e8 20             	sub    $0x20,%eax
  800566:	83 f8 5e             	cmp    $0x5e,%eax
  800569:	76 c6                	jbe    800531 <vprintfmt+0x1d7>
					putch('?', putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	53                   	push   %ebx
  80056f:	6a 3f                	push   $0x3f
  800571:	ff d6                	call   *%esi
  800573:	83 c4 10             	add    $0x10,%esp
  800576:	eb c3                	jmp    80053b <vprintfmt+0x1e1>
  800578:	89 cf                	mov    %ecx,%edi
  80057a:	eb 0e                	jmp    80058a <vprintfmt+0x230>
				putch(' ', putdat);
  80057c:	83 ec 08             	sub    $0x8,%esp
  80057f:	53                   	push   %ebx
  800580:	6a 20                	push   $0x20
  800582:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800584:	83 ef 01             	sub    $0x1,%edi
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	85 ff                	test   %edi,%edi
  80058c:	7f ee                	jg     80057c <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80058e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800591:	89 45 14             	mov    %eax,0x14(%ebp)
  800594:	e9 23 01 00 00       	jmp    8006bc <vprintfmt+0x362>
  800599:	89 cf                	mov    %ecx,%edi
  80059b:	eb ed                	jmp    80058a <vprintfmt+0x230>
	if (lflag >= 2)
  80059d:	83 f9 01             	cmp    $0x1,%ecx
  8005a0:	7f 1b                	jg     8005bd <vprintfmt+0x263>
	else if (lflag)
  8005a2:	85 c9                	test   %ecx,%ecx
  8005a4:	74 63                	je     800609 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8b 00                	mov    (%eax),%eax
  8005ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ae:	99                   	cltd   
  8005af:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8d 40 04             	lea    0x4(%eax),%eax
  8005b8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bb:	eb 17                	jmp    8005d4 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8b 50 04             	mov    0x4(%eax),%edx
  8005c3:	8b 00                	mov    (%eax),%eax
  8005c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 40 08             	lea    0x8(%eax),%eax
  8005d1:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005da:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005df:	85 c9                	test   %ecx,%ecx
  8005e1:	0f 89 bb 00 00 00    	jns    8006a2 <vprintfmt+0x348>
				putch('-', putdat);
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	53                   	push   %ebx
  8005eb:	6a 2d                	push   $0x2d
  8005ed:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ef:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005f2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005f5:	f7 da                	neg    %edx
  8005f7:	83 d1 00             	adc    $0x0,%ecx
  8005fa:	f7 d9                	neg    %ecx
  8005fc:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800604:	e9 99 00 00 00       	jmp    8006a2 <vprintfmt+0x348>
		return va_arg(*ap, int);
  800609:	8b 45 14             	mov    0x14(%ebp),%eax
  80060c:	8b 00                	mov    (%eax),%eax
  80060e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800611:	99                   	cltd   
  800612:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8d 40 04             	lea    0x4(%eax),%eax
  80061b:	89 45 14             	mov    %eax,0x14(%ebp)
  80061e:	eb b4                	jmp    8005d4 <vprintfmt+0x27a>
	if (lflag >= 2)
  800620:	83 f9 01             	cmp    $0x1,%ecx
  800623:	7f 1b                	jg     800640 <vprintfmt+0x2e6>
	else if (lflag)
  800625:	85 c9                	test   %ecx,%ecx
  800627:	74 2c                	je     800655 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8b 10                	mov    (%eax),%edx
  80062e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800633:	8d 40 04             	lea    0x4(%eax),%eax
  800636:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800639:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80063e:	eb 62                	jmp    8006a2 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8b 10                	mov    (%eax),%edx
  800645:	8b 48 04             	mov    0x4(%eax),%ecx
  800648:	8d 40 08             	lea    0x8(%eax),%eax
  80064b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80064e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800653:	eb 4d                	jmp    8006a2 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8b 10                	mov    (%eax),%edx
  80065a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065f:	8d 40 04             	lea    0x4(%eax),%eax
  800662:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800665:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80066a:	eb 36                	jmp    8006a2 <vprintfmt+0x348>
	if (lflag >= 2)
  80066c:	83 f9 01             	cmp    $0x1,%ecx
  80066f:	7f 17                	jg     800688 <vprintfmt+0x32e>
	else if (lflag)
  800671:	85 c9                	test   %ecx,%ecx
  800673:	74 6e                	je     8006e3 <vprintfmt+0x389>
		return va_arg(*ap, long);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8b 10                	mov    (%eax),%edx
  80067a:	89 d0                	mov    %edx,%eax
  80067c:	99                   	cltd   
  80067d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800680:	8d 49 04             	lea    0x4(%ecx),%ecx
  800683:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800686:	eb 11                	jmp    800699 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8b 50 04             	mov    0x4(%eax),%edx
  80068e:	8b 00                	mov    (%eax),%eax
  800690:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800693:	8d 49 08             	lea    0x8(%ecx),%ecx
  800696:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800699:	89 d1                	mov    %edx,%ecx
  80069b:	89 c2                	mov    %eax,%edx
            base = 8;
  80069d:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006a2:	83 ec 0c             	sub    $0xc,%esp
  8006a5:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006a9:	57                   	push   %edi
  8006aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ad:	50                   	push   %eax
  8006ae:	51                   	push   %ecx
  8006af:	52                   	push   %edx
  8006b0:	89 da                	mov    %ebx,%edx
  8006b2:	89 f0                	mov    %esi,%eax
  8006b4:	e8 b6 fb ff ff       	call   80026f <printnum>
			break;
  8006b9:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006bf:	83 c7 01             	add    $0x1,%edi
  8006c2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006c6:	83 f8 25             	cmp    $0x25,%eax
  8006c9:	0f 84 a6 fc ff ff    	je     800375 <vprintfmt+0x1b>
			if (ch == '\0')
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	0f 84 ce 00 00 00    	je     8007a5 <vprintfmt+0x44b>
			putch(ch, putdat);
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	53                   	push   %ebx
  8006db:	50                   	push   %eax
  8006dc:	ff d6                	call   *%esi
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	eb dc                	jmp    8006bf <vprintfmt+0x365>
		return va_arg(*ap, int);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8b 10                	mov    (%eax),%edx
  8006e8:	89 d0                	mov    %edx,%eax
  8006ea:	99                   	cltd   
  8006eb:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006ee:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006f1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006f4:	eb a3                	jmp    800699 <vprintfmt+0x33f>
			putch('0', putdat);
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	53                   	push   %ebx
  8006fa:	6a 30                	push   $0x30
  8006fc:	ff d6                	call   *%esi
			putch('x', putdat);
  8006fe:	83 c4 08             	add    $0x8,%esp
  800701:	53                   	push   %ebx
  800702:	6a 78                	push   $0x78
  800704:	ff d6                	call   *%esi
			num = (unsigned long long)
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8b 10                	mov    (%eax),%edx
  80070b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800710:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800713:	8d 40 04             	lea    0x4(%eax),%eax
  800716:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800719:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80071e:	eb 82                	jmp    8006a2 <vprintfmt+0x348>
	if (lflag >= 2)
  800720:	83 f9 01             	cmp    $0x1,%ecx
  800723:	7f 1e                	jg     800743 <vprintfmt+0x3e9>
	else if (lflag)
  800725:	85 c9                	test   %ecx,%ecx
  800727:	74 32                	je     80075b <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800729:	8b 45 14             	mov    0x14(%ebp),%eax
  80072c:	8b 10                	mov    (%eax),%edx
  80072e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800733:	8d 40 04             	lea    0x4(%eax),%eax
  800736:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800739:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80073e:	e9 5f ff ff ff       	jmp    8006a2 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800743:	8b 45 14             	mov    0x14(%ebp),%eax
  800746:	8b 10                	mov    (%eax),%edx
  800748:	8b 48 04             	mov    0x4(%eax),%ecx
  80074b:	8d 40 08             	lea    0x8(%eax),%eax
  80074e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800751:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800756:	e9 47 ff ff ff       	jmp    8006a2 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80075b:	8b 45 14             	mov    0x14(%ebp),%eax
  80075e:	8b 10                	mov    (%eax),%edx
  800760:	b9 00 00 00 00       	mov    $0x0,%ecx
  800765:	8d 40 04             	lea    0x4(%eax),%eax
  800768:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80076b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800770:	e9 2d ff ff ff       	jmp    8006a2 <vprintfmt+0x348>
			putch(ch, putdat);
  800775:	83 ec 08             	sub    $0x8,%esp
  800778:	53                   	push   %ebx
  800779:	6a 25                	push   $0x25
  80077b:	ff d6                	call   *%esi
			break;
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	e9 37 ff ff ff       	jmp    8006bc <vprintfmt+0x362>
			putch('%', putdat);
  800785:	83 ec 08             	sub    $0x8,%esp
  800788:	53                   	push   %ebx
  800789:	6a 25                	push   $0x25
  80078b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80078d:	83 c4 10             	add    $0x10,%esp
  800790:	89 f8                	mov    %edi,%eax
  800792:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800796:	74 05                	je     80079d <vprintfmt+0x443>
  800798:	83 e8 01             	sub    $0x1,%eax
  80079b:	eb f5                	jmp    800792 <vprintfmt+0x438>
  80079d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007a0:	e9 17 ff ff ff       	jmp    8006bc <vprintfmt+0x362>
}
  8007a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007a8:	5b                   	pop    %ebx
  8007a9:	5e                   	pop    %esi
  8007aa:	5f                   	pop    %edi
  8007ab:	5d                   	pop    %ebp
  8007ac:	c3                   	ret    

008007ad <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ad:	f3 0f 1e fb          	endbr32 
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	83 ec 18             	sub    $0x18,%esp
  8007b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ce:	85 c0                	test   %eax,%eax
  8007d0:	74 26                	je     8007f8 <vsnprintf+0x4b>
  8007d2:	85 d2                	test   %edx,%edx
  8007d4:	7e 22                	jle    8007f8 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d6:	ff 75 14             	pushl  0x14(%ebp)
  8007d9:	ff 75 10             	pushl  0x10(%ebp)
  8007dc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007df:	50                   	push   %eax
  8007e0:	68 18 03 80 00       	push   $0x800318
  8007e5:	e8 70 fb ff ff       	call   80035a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ed:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f3:	83 c4 10             	add    $0x10,%esp
}
  8007f6:	c9                   	leave  
  8007f7:	c3                   	ret    
		return -E_INVAL;
  8007f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007fd:	eb f7                	jmp    8007f6 <vsnprintf+0x49>

008007ff <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ff:	f3 0f 1e fb          	endbr32 
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800809:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80080c:	50                   	push   %eax
  80080d:	ff 75 10             	pushl  0x10(%ebp)
  800810:	ff 75 0c             	pushl  0xc(%ebp)
  800813:	ff 75 08             	pushl  0x8(%ebp)
  800816:	e8 92 ff ff ff       	call   8007ad <vsnprintf>
	va_end(ap);

	return rc;
}
  80081b:	c9                   	leave  
  80081c:	c3                   	ret    

0080081d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80081d:	f3 0f 1e fb          	endbr32 
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800827:	b8 00 00 00 00       	mov    $0x0,%eax
  80082c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800830:	74 05                	je     800837 <strlen+0x1a>
		n++;
  800832:	83 c0 01             	add    $0x1,%eax
  800835:	eb f5                	jmp    80082c <strlen+0xf>
	return n;
}
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800839:	f3 0f 1e fb          	endbr32 
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800843:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800846:	b8 00 00 00 00       	mov    $0x0,%eax
  80084b:	39 d0                	cmp    %edx,%eax
  80084d:	74 0d                	je     80085c <strnlen+0x23>
  80084f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800853:	74 05                	je     80085a <strnlen+0x21>
		n++;
  800855:	83 c0 01             	add    $0x1,%eax
  800858:	eb f1                	jmp    80084b <strnlen+0x12>
  80085a:	89 c2                	mov    %eax,%edx
	return n;
}
  80085c:	89 d0                	mov    %edx,%eax
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800860:	f3 0f 1e fb          	endbr32 
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	53                   	push   %ebx
  800868:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80086e:	b8 00 00 00 00       	mov    $0x0,%eax
  800873:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800877:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80087a:	83 c0 01             	add    $0x1,%eax
  80087d:	84 d2                	test   %dl,%dl
  80087f:	75 f2                	jne    800873 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800881:	89 c8                	mov    %ecx,%eax
  800883:	5b                   	pop    %ebx
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800886:	f3 0f 1e fb          	endbr32 
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	53                   	push   %ebx
  80088e:	83 ec 10             	sub    $0x10,%esp
  800891:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800894:	53                   	push   %ebx
  800895:	e8 83 ff ff ff       	call   80081d <strlen>
  80089a:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80089d:	ff 75 0c             	pushl  0xc(%ebp)
  8008a0:	01 d8                	add    %ebx,%eax
  8008a2:	50                   	push   %eax
  8008a3:	e8 b8 ff ff ff       	call   800860 <strcpy>
	return dst;
}
  8008a8:	89 d8                	mov    %ebx,%eax
  8008aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ad:	c9                   	leave  
  8008ae:	c3                   	ret    

008008af <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008af:	f3 0f 1e fb          	endbr32 
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	56                   	push   %esi
  8008b7:	53                   	push   %ebx
  8008b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008be:	89 f3                	mov    %esi,%ebx
  8008c0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c3:	89 f0                	mov    %esi,%eax
  8008c5:	39 d8                	cmp    %ebx,%eax
  8008c7:	74 11                	je     8008da <strncpy+0x2b>
		*dst++ = *src;
  8008c9:	83 c0 01             	add    $0x1,%eax
  8008cc:	0f b6 0a             	movzbl (%edx),%ecx
  8008cf:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d2:	80 f9 01             	cmp    $0x1,%cl
  8008d5:	83 da ff             	sbb    $0xffffffff,%edx
  8008d8:	eb eb                	jmp    8008c5 <strncpy+0x16>
	}
	return ret;
}
  8008da:	89 f0                	mov    %esi,%eax
  8008dc:	5b                   	pop    %ebx
  8008dd:	5e                   	pop    %esi
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e0:	f3 0f 1e fb          	endbr32 
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ef:	8b 55 10             	mov    0x10(%ebp),%edx
  8008f2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f4:	85 d2                	test   %edx,%edx
  8008f6:	74 21                	je     800919 <strlcpy+0x39>
  8008f8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008fc:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008fe:	39 c2                	cmp    %eax,%edx
  800900:	74 14                	je     800916 <strlcpy+0x36>
  800902:	0f b6 19             	movzbl (%ecx),%ebx
  800905:	84 db                	test   %bl,%bl
  800907:	74 0b                	je     800914 <strlcpy+0x34>
			*dst++ = *src++;
  800909:	83 c1 01             	add    $0x1,%ecx
  80090c:	83 c2 01             	add    $0x1,%edx
  80090f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800912:	eb ea                	jmp    8008fe <strlcpy+0x1e>
  800914:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800916:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800919:	29 f0                	sub    %esi,%eax
}
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80091f:	f3 0f 1e fb          	endbr32 
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800929:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80092c:	0f b6 01             	movzbl (%ecx),%eax
  80092f:	84 c0                	test   %al,%al
  800931:	74 0c                	je     80093f <strcmp+0x20>
  800933:	3a 02                	cmp    (%edx),%al
  800935:	75 08                	jne    80093f <strcmp+0x20>
		p++, q++;
  800937:	83 c1 01             	add    $0x1,%ecx
  80093a:	83 c2 01             	add    $0x1,%edx
  80093d:	eb ed                	jmp    80092c <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80093f:	0f b6 c0             	movzbl %al,%eax
  800942:	0f b6 12             	movzbl (%edx),%edx
  800945:	29 d0                	sub    %edx,%eax
}
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800949:	f3 0f 1e fb          	endbr32 
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	53                   	push   %ebx
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
  800954:	8b 55 0c             	mov    0xc(%ebp),%edx
  800957:	89 c3                	mov    %eax,%ebx
  800959:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80095c:	eb 06                	jmp    800964 <strncmp+0x1b>
		n--, p++, q++;
  80095e:	83 c0 01             	add    $0x1,%eax
  800961:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800964:	39 d8                	cmp    %ebx,%eax
  800966:	74 16                	je     80097e <strncmp+0x35>
  800968:	0f b6 08             	movzbl (%eax),%ecx
  80096b:	84 c9                	test   %cl,%cl
  80096d:	74 04                	je     800973 <strncmp+0x2a>
  80096f:	3a 0a                	cmp    (%edx),%cl
  800971:	74 eb                	je     80095e <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800973:	0f b6 00             	movzbl (%eax),%eax
  800976:	0f b6 12             	movzbl (%edx),%edx
  800979:	29 d0                	sub    %edx,%eax
}
  80097b:	5b                   	pop    %ebx
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    
		return 0;
  80097e:	b8 00 00 00 00       	mov    $0x0,%eax
  800983:	eb f6                	jmp    80097b <strncmp+0x32>

00800985 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800985:	f3 0f 1e fb          	endbr32 
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800993:	0f b6 10             	movzbl (%eax),%edx
  800996:	84 d2                	test   %dl,%dl
  800998:	74 09                	je     8009a3 <strchr+0x1e>
		if (*s == c)
  80099a:	38 ca                	cmp    %cl,%dl
  80099c:	74 0a                	je     8009a8 <strchr+0x23>
	for (; *s; s++)
  80099e:	83 c0 01             	add    $0x1,%eax
  8009a1:	eb f0                	jmp    800993 <strchr+0xe>
			return (char *) s;
	return 0;
  8009a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009aa:	f3 0f 1e fb          	endbr32 
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009bb:	38 ca                	cmp    %cl,%dl
  8009bd:	74 09                	je     8009c8 <strfind+0x1e>
  8009bf:	84 d2                	test   %dl,%dl
  8009c1:	74 05                	je     8009c8 <strfind+0x1e>
	for (; *s; s++)
  8009c3:	83 c0 01             	add    $0x1,%eax
  8009c6:	eb f0                	jmp    8009b8 <strfind+0xe>
			break;
	return (char *) s;
}
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009ca:	f3 0f 1e fb          	endbr32 
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	57                   	push   %edi
  8009d2:	56                   	push   %esi
  8009d3:	53                   	push   %ebx
  8009d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009da:	85 c9                	test   %ecx,%ecx
  8009dc:	74 31                	je     800a0f <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009de:	89 f8                	mov    %edi,%eax
  8009e0:	09 c8                	or     %ecx,%eax
  8009e2:	a8 03                	test   $0x3,%al
  8009e4:	75 23                	jne    800a09 <memset+0x3f>
		c &= 0xFF;
  8009e6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ea:	89 d3                	mov    %edx,%ebx
  8009ec:	c1 e3 08             	shl    $0x8,%ebx
  8009ef:	89 d0                	mov    %edx,%eax
  8009f1:	c1 e0 18             	shl    $0x18,%eax
  8009f4:	89 d6                	mov    %edx,%esi
  8009f6:	c1 e6 10             	shl    $0x10,%esi
  8009f9:	09 f0                	or     %esi,%eax
  8009fb:	09 c2                	or     %eax,%edx
  8009fd:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ff:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a02:	89 d0                	mov    %edx,%eax
  800a04:	fc                   	cld    
  800a05:	f3 ab                	rep stos %eax,%es:(%edi)
  800a07:	eb 06                	jmp    800a0f <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0c:	fc                   	cld    
  800a0d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a0f:	89 f8                	mov    %edi,%eax
  800a11:	5b                   	pop    %ebx
  800a12:	5e                   	pop    %esi
  800a13:	5f                   	pop    %edi
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a16:	f3 0f 1e fb          	endbr32 
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	57                   	push   %edi
  800a1e:	56                   	push   %esi
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a25:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a28:	39 c6                	cmp    %eax,%esi
  800a2a:	73 32                	jae    800a5e <memmove+0x48>
  800a2c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a2f:	39 c2                	cmp    %eax,%edx
  800a31:	76 2b                	jbe    800a5e <memmove+0x48>
		s += n;
		d += n;
  800a33:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a36:	89 fe                	mov    %edi,%esi
  800a38:	09 ce                	or     %ecx,%esi
  800a3a:	09 d6                	or     %edx,%esi
  800a3c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a42:	75 0e                	jne    800a52 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a44:	83 ef 04             	sub    $0x4,%edi
  800a47:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a4a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a4d:	fd                   	std    
  800a4e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a50:	eb 09                	jmp    800a5b <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a52:	83 ef 01             	sub    $0x1,%edi
  800a55:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a58:	fd                   	std    
  800a59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a5b:	fc                   	cld    
  800a5c:	eb 1a                	jmp    800a78 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5e:	89 c2                	mov    %eax,%edx
  800a60:	09 ca                	or     %ecx,%edx
  800a62:	09 f2                	or     %esi,%edx
  800a64:	f6 c2 03             	test   $0x3,%dl
  800a67:	75 0a                	jne    800a73 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a69:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a6c:	89 c7                	mov    %eax,%edi
  800a6e:	fc                   	cld    
  800a6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a71:	eb 05                	jmp    800a78 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a73:	89 c7                	mov    %eax,%edi
  800a75:	fc                   	cld    
  800a76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a78:	5e                   	pop    %esi
  800a79:	5f                   	pop    %edi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a7c:	f3 0f 1e fb          	endbr32 
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a86:	ff 75 10             	pushl  0x10(%ebp)
  800a89:	ff 75 0c             	pushl  0xc(%ebp)
  800a8c:	ff 75 08             	pushl  0x8(%ebp)
  800a8f:	e8 82 ff ff ff       	call   800a16 <memmove>
}
  800a94:	c9                   	leave  
  800a95:	c3                   	ret    

00800a96 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a96:	f3 0f 1e fb          	endbr32 
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	56                   	push   %esi
  800a9e:	53                   	push   %ebx
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa5:	89 c6                	mov    %eax,%esi
  800aa7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aaa:	39 f0                	cmp    %esi,%eax
  800aac:	74 1c                	je     800aca <memcmp+0x34>
		if (*s1 != *s2)
  800aae:	0f b6 08             	movzbl (%eax),%ecx
  800ab1:	0f b6 1a             	movzbl (%edx),%ebx
  800ab4:	38 d9                	cmp    %bl,%cl
  800ab6:	75 08                	jne    800ac0 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ab8:	83 c0 01             	add    $0x1,%eax
  800abb:	83 c2 01             	add    $0x1,%edx
  800abe:	eb ea                	jmp    800aaa <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ac0:	0f b6 c1             	movzbl %cl,%eax
  800ac3:	0f b6 db             	movzbl %bl,%ebx
  800ac6:	29 d8                	sub    %ebx,%eax
  800ac8:	eb 05                	jmp    800acf <memcmp+0x39>
	}

	return 0;
  800aca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800acf:	5b                   	pop    %ebx
  800ad0:	5e                   	pop    %esi
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad3:	f3 0f 1e fb          	endbr32 
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	8b 45 08             	mov    0x8(%ebp),%eax
  800add:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ae0:	89 c2                	mov    %eax,%edx
  800ae2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae5:	39 d0                	cmp    %edx,%eax
  800ae7:	73 09                	jae    800af2 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae9:	38 08                	cmp    %cl,(%eax)
  800aeb:	74 05                	je     800af2 <memfind+0x1f>
	for (; s < ends; s++)
  800aed:	83 c0 01             	add    $0x1,%eax
  800af0:	eb f3                	jmp    800ae5 <memfind+0x12>
			break;
	return (void *) s;
}
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af4:	f3 0f 1e fb          	endbr32 
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	57                   	push   %edi
  800afc:	56                   	push   %esi
  800afd:	53                   	push   %ebx
  800afe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b01:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b04:	eb 03                	jmp    800b09 <strtol+0x15>
		s++;
  800b06:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b09:	0f b6 01             	movzbl (%ecx),%eax
  800b0c:	3c 20                	cmp    $0x20,%al
  800b0e:	74 f6                	je     800b06 <strtol+0x12>
  800b10:	3c 09                	cmp    $0x9,%al
  800b12:	74 f2                	je     800b06 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b14:	3c 2b                	cmp    $0x2b,%al
  800b16:	74 2a                	je     800b42 <strtol+0x4e>
	int neg = 0;
  800b18:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b1d:	3c 2d                	cmp    $0x2d,%al
  800b1f:	74 2b                	je     800b4c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b21:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b27:	75 0f                	jne    800b38 <strtol+0x44>
  800b29:	80 39 30             	cmpb   $0x30,(%ecx)
  800b2c:	74 28                	je     800b56 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b2e:	85 db                	test   %ebx,%ebx
  800b30:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b35:	0f 44 d8             	cmove  %eax,%ebx
  800b38:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b40:	eb 46                	jmp    800b88 <strtol+0x94>
		s++;
  800b42:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b45:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4a:	eb d5                	jmp    800b21 <strtol+0x2d>
		s++, neg = 1;
  800b4c:	83 c1 01             	add    $0x1,%ecx
  800b4f:	bf 01 00 00 00       	mov    $0x1,%edi
  800b54:	eb cb                	jmp    800b21 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b56:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b5a:	74 0e                	je     800b6a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b5c:	85 db                	test   %ebx,%ebx
  800b5e:	75 d8                	jne    800b38 <strtol+0x44>
		s++, base = 8;
  800b60:	83 c1 01             	add    $0x1,%ecx
  800b63:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b68:	eb ce                	jmp    800b38 <strtol+0x44>
		s += 2, base = 16;
  800b6a:	83 c1 02             	add    $0x2,%ecx
  800b6d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b72:	eb c4                	jmp    800b38 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b74:	0f be d2             	movsbl %dl,%edx
  800b77:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b7a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b7d:	7d 3a                	jge    800bb9 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b7f:	83 c1 01             	add    $0x1,%ecx
  800b82:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b86:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b88:	0f b6 11             	movzbl (%ecx),%edx
  800b8b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b8e:	89 f3                	mov    %esi,%ebx
  800b90:	80 fb 09             	cmp    $0x9,%bl
  800b93:	76 df                	jbe    800b74 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b95:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b98:	89 f3                	mov    %esi,%ebx
  800b9a:	80 fb 19             	cmp    $0x19,%bl
  800b9d:	77 08                	ja     800ba7 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b9f:	0f be d2             	movsbl %dl,%edx
  800ba2:	83 ea 57             	sub    $0x57,%edx
  800ba5:	eb d3                	jmp    800b7a <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ba7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800baa:	89 f3                	mov    %esi,%ebx
  800bac:	80 fb 19             	cmp    $0x19,%bl
  800baf:	77 08                	ja     800bb9 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bb1:	0f be d2             	movsbl %dl,%edx
  800bb4:	83 ea 37             	sub    $0x37,%edx
  800bb7:	eb c1                	jmp    800b7a <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bb9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbd:	74 05                	je     800bc4 <strtol+0xd0>
		*endptr = (char *) s;
  800bbf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc2:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bc4:	89 c2                	mov    %eax,%edx
  800bc6:	f7 da                	neg    %edx
  800bc8:	85 ff                	test   %edi,%edi
  800bca:	0f 45 c2             	cmovne %edx,%eax
}
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bd2:	f3 0f 1e fb          	endbr32 
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bdc:	b8 00 00 00 00       	mov    $0x0,%eax
  800be1:	8b 55 08             	mov    0x8(%ebp),%edx
  800be4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be7:	89 c3                	mov    %eax,%ebx
  800be9:	89 c7                	mov    %eax,%edi
  800beb:	89 c6                	mov    %eax,%esi
  800bed:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf4:	f3 0f 1e fb          	endbr32 
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	57                   	push   %edi
  800bfc:	56                   	push   %esi
  800bfd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bfe:	ba 00 00 00 00       	mov    $0x0,%edx
  800c03:	b8 01 00 00 00       	mov    $0x1,%eax
  800c08:	89 d1                	mov    %edx,%ecx
  800c0a:	89 d3                	mov    %edx,%ebx
  800c0c:	89 d7                	mov    %edx,%edi
  800c0e:	89 d6                	mov    %edx,%esi
  800c10:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c17:	f3 0f 1e fb          	endbr32 
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
  800c21:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c24:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c29:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2c:	b8 03 00 00 00       	mov    $0x3,%eax
  800c31:	89 cb                	mov    %ecx,%ebx
  800c33:	89 cf                	mov    %ecx,%edi
  800c35:	89 ce                	mov    %ecx,%esi
  800c37:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	7f 08                	jg     800c45 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c45:	83 ec 0c             	sub    $0xc,%esp
  800c48:	50                   	push   %eax
  800c49:	6a 03                	push   $0x3
  800c4b:	68 ff 25 80 00       	push   $0x8025ff
  800c50:	6a 23                	push   $0x23
  800c52:	68 1c 26 80 00       	push   $0x80261c
  800c57:	e8 14 f5 ff ff       	call   800170 <_panic>

00800c5c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c5c:	f3 0f 1e fb          	endbr32 
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c66:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6b:	b8 02 00 00 00       	mov    $0x2,%eax
  800c70:	89 d1                	mov    %edx,%ecx
  800c72:	89 d3                	mov    %edx,%ebx
  800c74:	89 d7                	mov    %edx,%edi
  800c76:	89 d6                	mov    %edx,%esi
  800c78:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_yield>:

void
sys_yield(void)
{
  800c7f:	f3 0f 1e fb          	endbr32 
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c89:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c93:	89 d1                	mov    %edx,%ecx
  800c95:	89 d3                	mov    %edx,%ebx
  800c97:	89 d7                	mov    %edx,%edi
  800c99:	89 d6                	mov    %edx,%esi
  800c9b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca2:	f3 0f 1e fb          	endbr32 
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800caf:	be 00 00 00 00       	mov    $0x0,%esi
  800cb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cba:	b8 04 00 00 00       	mov    $0x4,%eax
  800cbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc2:	89 f7                	mov    %esi,%edi
  800cc4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	7f 08                	jg     800cd2 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd2:	83 ec 0c             	sub    $0xc,%esp
  800cd5:	50                   	push   %eax
  800cd6:	6a 04                	push   $0x4
  800cd8:	68 ff 25 80 00       	push   $0x8025ff
  800cdd:	6a 23                	push   $0x23
  800cdf:	68 1c 26 80 00       	push   $0x80261c
  800ce4:	e8 87 f4 ff ff       	call   800170 <_panic>

00800ce9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce9:	f3 0f 1e fb          	endbr32 
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	57                   	push   %edi
  800cf1:	56                   	push   %esi
  800cf2:	53                   	push   %ebx
  800cf3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfc:	b8 05 00 00 00       	mov    $0x5,%eax
  800d01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d04:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d07:	8b 75 18             	mov    0x18(%ebp),%esi
  800d0a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d0c:	85 c0                	test   %eax,%eax
  800d0e:	7f 08                	jg     800d18 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d13:	5b                   	pop    %ebx
  800d14:	5e                   	pop    %esi
  800d15:	5f                   	pop    %edi
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d18:	83 ec 0c             	sub    $0xc,%esp
  800d1b:	50                   	push   %eax
  800d1c:	6a 05                	push   $0x5
  800d1e:	68 ff 25 80 00       	push   $0x8025ff
  800d23:	6a 23                	push   $0x23
  800d25:	68 1c 26 80 00       	push   $0x80261c
  800d2a:	e8 41 f4 ff ff       	call   800170 <_panic>

00800d2f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d2f:	f3 0f 1e fb          	endbr32 
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d47:	b8 06 00 00 00       	mov    $0x6,%eax
  800d4c:	89 df                	mov    %ebx,%edi
  800d4e:	89 de                	mov    %ebx,%esi
  800d50:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d52:	85 c0                	test   %eax,%eax
  800d54:	7f 08                	jg     800d5e <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5e:	83 ec 0c             	sub    $0xc,%esp
  800d61:	50                   	push   %eax
  800d62:	6a 06                	push   $0x6
  800d64:	68 ff 25 80 00       	push   $0x8025ff
  800d69:	6a 23                	push   $0x23
  800d6b:	68 1c 26 80 00       	push   $0x80261c
  800d70:	e8 fb f3 ff ff       	call   800170 <_panic>

00800d75 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d75:	f3 0f 1e fb          	endbr32 
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	57                   	push   %edi
  800d7d:	56                   	push   %esi
  800d7e:	53                   	push   %ebx
  800d7f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d82:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d87:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d92:	89 df                	mov    %ebx,%edi
  800d94:	89 de                	mov    %ebx,%esi
  800d96:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	7f 08                	jg     800da4 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9f:	5b                   	pop    %ebx
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da4:	83 ec 0c             	sub    $0xc,%esp
  800da7:	50                   	push   %eax
  800da8:	6a 08                	push   $0x8
  800daa:	68 ff 25 80 00       	push   $0x8025ff
  800daf:	6a 23                	push   $0x23
  800db1:	68 1c 26 80 00       	push   $0x80261c
  800db6:	e8 b5 f3 ff ff       	call   800170 <_panic>

00800dbb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dbb:	f3 0f 1e fb          	endbr32 
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
  800dc5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd3:	b8 09 00 00 00       	mov    $0x9,%eax
  800dd8:	89 df                	mov    %ebx,%edi
  800dda:	89 de                	mov    %ebx,%esi
  800ddc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dde:	85 c0                	test   %eax,%eax
  800de0:	7f 08                	jg     800dea <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800de2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dea:	83 ec 0c             	sub    $0xc,%esp
  800ded:	50                   	push   %eax
  800dee:	6a 09                	push   $0x9
  800df0:	68 ff 25 80 00       	push   $0x8025ff
  800df5:	6a 23                	push   $0x23
  800df7:	68 1c 26 80 00       	push   $0x80261c
  800dfc:	e8 6f f3 ff ff       	call   800170 <_panic>

00800e01 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e01:	f3 0f 1e fb          	endbr32 
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	57                   	push   %edi
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
  800e0b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e13:	8b 55 08             	mov    0x8(%ebp),%edx
  800e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e19:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e1e:	89 df                	mov    %ebx,%edi
  800e20:	89 de                	mov    %ebx,%esi
  800e22:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e24:	85 c0                	test   %eax,%eax
  800e26:	7f 08                	jg     800e30 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e2b:	5b                   	pop    %ebx
  800e2c:	5e                   	pop    %esi
  800e2d:	5f                   	pop    %edi
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e30:	83 ec 0c             	sub    $0xc,%esp
  800e33:	50                   	push   %eax
  800e34:	6a 0a                	push   $0xa
  800e36:	68 ff 25 80 00       	push   $0x8025ff
  800e3b:	6a 23                	push   $0x23
  800e3d:	68 1c 26 80 00       	push   $0x80261c
  800e42:	e8 29 f3 ff ff       	call   800170 <_panic>

00800e47 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e47:	f3 0f 1e fb          	endbr32 
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	57                   	push   %edi
  800e4f:	56                   	push   %esi
  800e50:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e51:	8b 55 08             	mov    0x8(%ebp),%edx
  800e54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e57:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e5c:	be 00 00 00 00       	mov    $0x0,%esi
  800e61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e64:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e67:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e69:	5b                   	pop    %ebx
  800e6a:	5e                   	pop    %esi
  800e6b:	5f                   	pop    %edi
  800e6c:	5d                   	pop    %ebp
  800e6d:	c3                   	ret    

00800e6e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e6e:	f3 0f 1e fb          	endbr32 
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	57                   	push   %edi
  800e76:	56                   	push   %esi
  800e77:	53                   	push   %ebx
  800e78:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e7b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e80:	8b 55 08             	mov    0x8(%ebp),%edx
  800e83:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e88:	89 cb                	mov    %ecx,%ebx
  800e8a:	89 cf                	mov    %ecx,%edi
  800e8c:	89 ce                	mov    %ecx,%esi
  800e8e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e90:	85 c0                	test   %eax,%eax
  800e92:	7f 08                	jg     800e9c <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5f                   	pop    %edi
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9c:	83 ec 0c             	sub    $0xc,%esp
  800e9f:	50                   	push   %eax
  800ea0:	6a 0d                	push   $0xd
  800ea2:	68 ff 25 80 00       	push   $0x8025ff
  800ea7:	6a 23                	push   $0x23
  800ea9:	68 1c 26 80 00       	push   $0x80261c
  800eae:	e8 bd f2 ff ff       	call   800170 <_panic>

00800eb3 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800eb3:	f3 0f 1e fb          	endbr32 
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	53                   	push   %ebx
  800ebb:	83 ec 04             	sub    $0x4,%esp
  800ebe:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ec1:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if ( !(err & FEC_WR) ||
  800ec3:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ec7:	74 75                	je     800f3e <pgfault+0x8b>
            !(uvpt[PGNUM(addr)] | PTE_COW) ) {
  800ec9:	89 d8                	mov    %ebx,%eax
  800ecb:	c1 e8 0c             	shr    $0xc,%eax
  800ece:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0) {
  800ed5:	83 ec 04             	sub    $0x4,%esp
  800ed8:	6a 07                	push   $0x7
  800eda:	68 00 f0 7f 00       	push   $0x7ff000
  800edf:	6a 00                	push   $0x0
  800ee1:	e8 bc fd ff ff       	call   800ca2 <sys_page_alloc>
  800ee6:	83 c4 10             	add    $0x10,%esp
  800ee9:	85 c0                	test   %eax,%eax
  800eeb:	78 65                	js     800f52 <pgfault+0x9f>
        panic("sys_page_alloc failed %e\n", r);
    }
    memmove((void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);
  800eed:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800ef3:	83 ec 04             	sub    $0x4,%esp
  800ef6:	68 00 10 00 00       	push   $0x1000
  800efb:	53                   	push   %ebx
  800efc:	68 00 f0 7f 00       	push   $0x7ff000
  800f01:	e8 10 fb ff ff       	call   800a16 <memmove>
    if ((r = sys_page_map(0, (void *)PFTEMP,
  800f06:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f0d:	53                   	push   %ebx
  800f0e:	6a 00                	push   $0x0
  800f10:	68 00 f0 7f 00       	push   $0x7ff000
  800f15:	6a 00                	push   $0x0
  800f17:	e8 cd fd ff ff       	call   800ce9 <sys_page_map>
  800f1c:	83 c4 20             	add    $0x20,%esp
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	78 41                	js     800f64 <pgfault+0xb1>
                0, (void *)PTE_ADDR(addr), PTE_P | PTE_U | PTE_W)) < 0) {
        panic("sys_page_map failed %e\n", r);
    }
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0) {
  800f23:	83 ec 08             	sub    $0x8,%esp
  800f26:	68 00 f0 7f 00       	push   $0x7ff000
  800f2b:	6a 00                	push   $0x0
  800f2d:	e8 fd fd ff ff       	call   800d2f <sys_page_unmap>
  800f32:	83 c4 10             	add    $0x10,%esp
  800f35:	85 c0                	test   %eax,%eax
  800f37:	78 3d                	js     800f76 <pgfault+0xc3>
        panic("sys_page_unmap failed %e\n", r);
    }

}
  800f39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f3c:	c9                   	leave  
  800f3d:	c3                   	ret    
        panic("Not a copy-on-write page");
  800f3e:	83 ec 04             	sub    $0x4,%esp
  800f41:	68 2a 26 80 00       	push   $0x80262a
  800f46:	6a 1e                	push   $0x1e
  800f48:	68 43 26 80 00       	push   $0x802643
  800f4d:	e8 1e f2 ff ff       	call   800170 <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800f52:	50                   	push   %eax
  800f53:	68 4e 26 80 00       	push   $0x80264e
  800f58:	6a 2a                	push   $0x2a
  800f5a:	68 43 26 80 00       	push   $0x802643
  800f5f:	e8 0c f2 ff ff       	call   800170 <_panic>
        panic("sys_page_map failed %e\n", r);
  800f64:	50                   	push   %eax
  800f65:	68 68 26 80 00       	push   $0x802668
  800f6a:	6a 2f                	push   $0x2f
  800f6c:	68 43 26 80 00       	push   $0x802643
  800f71:	e8 fa f1 ff ff       	call   800170 <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800f76:	50                   	push   %eax
  800f77:	68 80 26 80 00       	push   $0x802680
  800f7c:	6a 32                	push   $0x32
  800f7e:	68 43 26 80 00       	push   $0x802643
  800f83:	e8 e8 f1 ff ff       	call   800170 <_panic>

00800f88 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f88:	f3 0f 1e fb          	endbr32 
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	57                   	push   %edi
  800f90:	56                   	push   %esi
  800f91:	53                   	push   %ebx
  800f92:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");

    // 1. set pgfault handler.
    set_pgfault_handler(pgfault);
  800f95:	68 b3 0e 80 00       	push   $0x800eb3
  800f9a:	e8 9f 0f 00 00       	call   801f3e <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f9f:	b8 07 00 00 00       	mov    $0x7,%eax
  800fa4:	cd 30                	int    $0x30
  800fa6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fa9:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 2. exofork.
    envid_t envid = sys_exofork();

    if (envid < 0)
  800fac:	83 c4 10             	add    $0x10,%esp
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	78 2a                	js     800fdd <fork+0x55>
        thisenv = &envs[ENVX(my_envid)];
        return 0;
    }
    else {
        // parent
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800fb3:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800fb8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800fbc:	75 69                	jne    801027 <fork+0x9f>
        envid_t my_envid = sys_getenvid();
  800fbe:	e8 99 fc ff ff       	call   800c5c <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800fc3:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fc8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fcb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fd0:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  800fd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fd8:	e9 fc 00 00 00       	jmp    8010d9 <fork+0x151>
        panic("fork, sys_exofork %e", envid);
  800fdd:	50                   	push   %eax
  800fde:	68 9a 26 80 00       	push   $0x80269a
  800fe3:	6a 7b                	push   $0x7b
  800fe5:	68 43 26 80 00       	push   $0x802643
  800fea:	e8 81 f1 ff ff       	call   800170 <_panic>
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  800fef:	83 ec 0c             	sub    $0xc,%esp
  800ff2:	57                   	push   %edi
  800ff3:	56                   	push   %esi
  800ff4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff7:	56                   	push   %esi
  800ff8:	6a 00                	push   $0x0
  800ffa:	e8 ea fc ff ff       	call   800ce9 <sys_page_map>
  800fff:	83 c4 20             	add    $0x20,%esp
  801002:	85 c0                	test   %eax,%eax
  801004:	78 69                	js     80106f <fork+0xe7>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  801006:	83 ec 0c             	sub    $0xc,%esp
  801009:	57                   	push   %edi
  80100a:	56                   	push   %esi
  80100b:	6a 00                	push   $0x0
  80100d:	56                   	push   %esi
  80100e:	6a 00                	push   $0x0
  801010:	e8 d4 fc ff ff       	call   800ce9 <sys_page_map>
  801015:	83 c4 20             	add    $0x20,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	78 65                	js     801081 <fork+0xf9>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  80101c:	83 c3 01             	add    $0x1,%ebx
  80101f:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801025:	74 6c                	je     801093 <fork+0x10b>
  801027:	89 de                	mov    %ebx,%esi
  801029:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  80102c:	89 f0                	mov    %esi,%eax
  80102e:	c1 e8 16             	shr    $0x16,%eax
  801031:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801038:	a8 01                	test   $0x1,%al
  80103a:	74 e0                	je     80101c <fork+0x94>
                    (uvpt[pn] & PTE_P) ) {
  80103c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  801043:	a8 01                	test   $0x1,%al
  801045:	74 d5                	je     80101c <fork+0x94>
    pte_t pte = uvpt[pn];
  801047:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    int perm = PTE_U | PTE_P;
  80104e:	bf 05 00 00 00       	mov    $0x5,%edi
    if ( ((pte & PTE_W) || (pte & PTE_COW)) && !(pte & PTE_SHARE)) {
  801053:	a9 02 08 00 00       	test   $0x802,%eax
  801058:	74 95                	je     800fef <fork+0x67>
  80105a:	25 00 04 00 00       	and    $0x400,%eax
        perm |= PTE_COW;
  80105f:	83 f8 01             	cmp    $0x1,%eax
  801062:	19 ff                	sbb    %edi,%edi
  801064:	81 e7 00 08 00 00    	and    $0x800,%edi
  80106a:	83 c7 05             	add    $0x5,%edi
  80106d:	eb 80                	jmp    800fef <fork+0x67>
        panic("sys_page_map others failed %e\n", r);
  80106f:	50                   	push   %eax
  801070:	68 e4 26 80 00       	push   $0x8026e4
  801075:	6a 51                	push   $0x51
  801077:	68 43 26 80 00       	push   $0x802643
  80107c:	e8 ef f0 ff ff       	call   800170 <_panic>
            panic("sys_page_map mine failed %e\n", r);
  801081:	50                   	push   %eax
  801082:	68 af 26 80 00       	push   $0x8026af
  801087:	6a 56                	push   $0x56
  801089:	68 43 26 80 00       	push   $0x802643
  80108e:	e8 dd f0 ff ff       	call   800170 <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  801093:	83 ec 04             	sub    $0x4,%esp
  801096:	6a 07                	push   $0x7
  801098:	68 00 f0 bf ee       	push   $0xeebff000
  80109d:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8010a0:	57                   	push   %edi
  8010a1:	e8 fc fb ff ff       	call   800ca2 <sys_page_alloc>
  8010a6:	83 c4 10             	add    $0x10,%esp
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	78 2c                	js     8010d9 <fork+0x151>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  8010ad:	a1 04 40 80 00       	mov    0x804004,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  8010b2:	8b 40 64             	mov    0x64(%eax),%eax
  8010b5:	83 ec 08             	sub    $0x8,%esp
  8010b8:	50                   	push   %eax
  8010b9:	57                   	push   %edi
  8010ba:	e8 42 fd ff ff       	call   800e01 <sys_env_set_pgfault_upcall>
  8010bf:	83 c4 10             	add    $0x10,%esp
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	78 13                	js     8010d9 <fork+0x151>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8010c6:	83 ec 08             	sub    $0x8,%esp
  8010c9:	6a 02                	push   $0x2
  8010cb:	57                   	push   %edi
  8010cc:	e8 a4 fc ff ff       	call   800d75 <sys_env_set_status>
  8010d1:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	0f 49 c7             	cmovns %edi,%eax
    }

}
  8010d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010dc:	5b                   	pop    %ebx
  8010dd:	5e                   	pop    %esi
  8010de:	5f                   	pop    %edi
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <sfork>:

// Challenge!
int
sfork(void)
{
  8010e1:	f3 0f 1e fb          	endbr32 
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010eb:	68 cc 26 80 00       	push   $0x8026cc
  8010f0:	68 a5 00 00 00       	push   $0xa5
  8010f5:	68 43 26 80 00       	push   $0x802643
  8010fa:	e8 71 f0 ff ff       	call   800170 <_panic>

008010ff <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010ff:	f3 0f 1e fb          	endbr32 
  801103:	55                   	push   %ebp
  801104:	89 e5                	mov    %esp,%ebp
  801106:	56                   	push   %esi
  801107:	53                   	push   %ebx
  801108:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80110b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80110e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801111:	85 c0                	test   %eax,%eax
  801113:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801118:	0f 44 c2             	cmove  %edx,%eax
  80111b:	83 ec 0c             	sub    $0xc,%esp
  80111e:	50                   	push   %eax
  80111f:	e8 4a fd ff ff       	call   800e6e <sys_ipc_recv>
  801124:	83 c4 10             	add    $0x10,%esp
  801127:	85 c0                	test   %eax,%eax
  801129:	78 24                	js     80114f <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  80112b:	85 f6                	test   %esi,%esi
  80112d:	74 0a                	je     801139 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  80112f:	a1 04 40 80 00       	mov    0x804004,%eax
  801134:	8b 40 78             	mov    0x78(%eax),%eax
  801137:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801139:	85 db                	test   %ebx,%ebx
  80113b:	74 0a                	je     801147 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  80113d:	a1 04 40 80 00       	mov    0x804004,%eax
  801142:	8b 40 74             	mov    0x74(%eax),%eax
  801145:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801147:	a1 04 40 80 00       	mov    0x804004,%eax
  80114c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80114f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801152:	5b                   	pop    %ebx
  801153:	5e                   	pop    %esi
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    

00801156 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801156:	f3 0f 1e fb          	endbr32 
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	57                   	push   %edi
  80115e:	56                   	push   %esi
  80115f:	53                   	push   %ebx
  801160:	83 ec 1c             	sub    $0x1c,%esp
  801163:	8b 45 10             	mov    0x10(%ebp),%eax
  801166:	85 c0                	test   %eax,%eax
  801168:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80116d:	0f 45 d0             	cmovne %eax,%edx
  801170:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801172:	be 01 00 00 00       	mov    $0x1,%esi
  801177:	eb 1f                	jmp    801198 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801179:	e8 01 fb ff ff       	call   800c7f <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  80117e:	83 c3 01             	add    $0x1,%ebx
  801181:	39 de                	cmp    %ebx,%esi
  801183:	7f f4                	jg     801179 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801185:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801187:	83 fe 11             	cmp    $0x11,%esi
  80118a:	b8 01 00 00 00       	mov    $0x1,%eax
  80118f:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801192:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801196:	75 1c                	jne    8011b4 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801198:	ff 75 14             	pushl  0x14(%ebp)
  80119b:	57                   	push   %edi
  80119c:	ff 75 0c             	pushl  0xc(%ebp)
  80119f:	ff 75 08             	pushl  0x8(%ebp)
  8011a2:	e8 a0 fc ff ff       	call   800e47 <sys_ipc_try_send>
  8011a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  8011aa:	83 c4 10             	add    $0x10,%esp
  8011ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b2:	eb cd                	jmp    801181 <ipc_send+0x2b>
}
  8011b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b7:	5b                   	pop    %ebx
  8011b8:	5e                   	pop    %esi
  8011b9:	5f                   	pop    %edi
  8011ba:	5d                   	pop    %ebp
  8011bb:	c3                   	ret    

008011bc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011bc:	f3 0f 1e fb          	endbr32 
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011c6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011cb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011ce:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011d4:	8b 52 50             	mov    0x50(%edx),%edx
  8011d7:	39 ca                	cmp    %ecx,%edx
  8011d9:	74 11                	je     8011ec <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8011db:	83 c0 01             	add    $0x1,%eax
  8011de:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011e3:	75 e6                	jne    8011cb <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8011e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ea:	eb 0b                	jmp    8011f7 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8011ec:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011ef:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011f4:	8b 40 48             	mov    0x48(%eax),%eax
}
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011f9:	f3 0f 1e fb          	endbr32 
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801200:	8b 45 08             	mov    0x8(%ebp),%eax
  801203:	05 00 00 00 30       	add    $0x30000000,%eax
  801208:	c1 e8 0c             	shr    $0xc,%eax
}
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    

0080120d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80120d:	f3 0f 1e fb          	endbr32 
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801214:	8b 45 08             	mov    0x8(%ebp),%eax
  801217:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80121c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801221:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    

00801228 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801228:	f3 0f 1e fb          	endbr32 
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801234:	89 c2                	mov    %eax,%edx
  801236:	c1 ea 16             	shr    $0x16,%edx
  801239:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801240:	f6 c2 01             	test   $0x1,%dl
  801243:	74 2d                	je     801272 <fd_alloc+0x4a>
  801245:	89 c2                	mov    %eax,%edx
  801247:	c1 ea 0c             	shr    $0xc,%edx
  80124a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801251:	f6 c2 01             	test   $0x1,%dl
  801254:	74 1c                	je     801272 <fd_alloc+0x4a>
  801256:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80125b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801260:	75 d2                	jne    801234 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801262:	8b 45 08             	mov    0x8(%ebp),%eax
  801265:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80126b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801270:	eb 0a                	jmp    80127c <fd_alloc+0x54>
			*fd_store = fd;
  801272:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801275:	89 01                	mov    %eax,(%ecx)
			return 0;
  801277:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80127c:	5d                   	pop    %ebp
  80127d:	c3                   	ret    

0080127e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80127e:	f3 0f 1e fb          	endbr32 
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801288:	83 f8 1f             	cmp    $0x1f,%eax
  80128b:	77 30                	ja     8012bd <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80128d:	c1 e0 0c             	shl    $0xc,%eax
  801290:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801295:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80129b:	f6 c2 01             	test   $0x1,%dl
  80129e:	74 24                	je     8012c4 <fd_lookup+0x46>
  8012a0:	89 c2                	mov    %eax,%edx
  8012a2:	c1 ea 0c             	shr    $0xc,%edx
  8012a5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ac:	f6 c2 01             	test   $0x1,%dl
  8012af:	74 1a                	je     8012cb <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b4:	89 02                	mov    %eax,(%edx)
	return 0;
  8012b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    
		return -E_INVAL;
  8012bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c2:	eb f7                	jmp    8012bb <fd_lookup+0x3d>
		return -E_INVAL;
  8012c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c9:	eb f0                	jmp    8012bb <fd_lookup+0x3d>
  8012cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d0:	eb e9                	jmp    8012bb <fd_lookup+0x3d>

008012d2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012d2:	f3 0f 1e fb          	endbr32 
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012df:	ba 80 27 80 00       	mov    $0x802780,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012e4:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8012e9:	39 08                	cmp    %ecx,(%eax)
  8012eb:	74 33                	je     801320 <dev_lookup+0x4e>
  8012ed:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8012f0:	8b 02                	mov    (%edx),%eax
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	75 f3                	jne    8012e9 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012f6:	a1 04 40 80 00       	mov    0x804004,%eax
  8012fb:	8b 40 48             	mov    0x48(%eax),%eax
  8012fe:	83 ec 04             	sub    $0x4,%esp
  801301:	51                   	push   %ecx
  801302:	50                   	push   %eax
  801303:	68 04 27 80 00       	push   $0x802704
  801308:	e8 4a ef ff ff       	call   800257 <cprintf>
	*dev = 0;
  80130d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801310:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801316:	83 c4 10             	add    $0x10,%esp
  801319:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80131e:	c9                   	leave  
  80131f:	c3                   	ret    
			*dev = devtab[i];
  801320:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801323:	89 01                	mov    %eax,(%ecx)
			return 0;
  801325:	b8 00 00 00 00       	mov    $0x0,%eax
  80132a:	eb f2                	jmp    80131e <dev_lookup+0x4c>

0080132c <fd_close>:
{
  80132c:	f3 0f 1e fb          	endbr32 
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	57                   	push   %edi
  801334:	56                   	push   %esi
  801335:	53                   	push   %ebx
  801336:	83 ec 24             	sub    $0x24,%esp
  801339:	8b 75 08             	mov    0x8(%ebp),%esi
  80133c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80133f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801342:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801343:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801349:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80134c:	50                   	push   %eax
  80134d:	e8 2c ff ff ff       	call   80127e <fd_lookup>
  801352:	89 c3                	mov    %eax,%ebx
  801354:	83 c4 10             	add    $0x10,%esp
  801357:	85 c0                	test   %eax,%eax
  801359:	78 05                	js     801360 <fd_close+0x34>
	    || fd != fd2)
  80135b:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80135e:	74 16                	je     801376 <fd_close+0x4a>
		return (must_exist ? r : 0);
  801360:	89 f8                	mov    %edi,%eax
  801362:	84 c0                	test   %al,%al
  801364:	b8 00 00 00 00       	mov    $0x0,%eax
  801369:	0f 44 d8             	cmove  %eax,%ebx
}
  80136c:	89 d8                	mov    %ebx,%eax
  80136e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801371:	5b                   	pop    %ebx
  801372:	5e                   	pop    %esi
  801373:	5f                   	pop    %edi
  801374:	5d                   	pop    %ebp
  801375:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801376:	83 ec 08             	sub    $0x8,%esp
  801379:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80137c:	50                   	push   %eax
  80137d:	ff 36                	pushl  (%esi)
  80137f:	e8 4e ff ff ff       	call   8012d2 <dev_lookup>
  801384:	89 c3                	mov    %eax,%ebx
  801386:	83 c4 10             	add    $0x10,%esp
  801389:	85 c0                	test   %eax,%eax
  80138b:	78 1a                	js     8013a7 <fd_close+0x7b>
		if (dev->dev_close)
  80138d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801390:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801393:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801398:	85 c0                	test   %eax,%eax
  80139a:	74 0b                	je     8013a7 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80139c:	83 ec 0c             	sub    $0xc,%esp
  80139f:	56                   	push   %esi
  8013a0:	ff d0                	call   *%eax
  8013a2:	89 c3                	mov    %eax,%ebx
  8013a4:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8013a7:	83 ec 08             	sub    $0x8,%esp
  8013aa:	56                   	push   %esi
  8013ab:	6a 00                	push   $0x0
  8013ad:	e8 7d f9 ff ff       	call   800d2f <sys_page_unmap>
	return r;
  8013b2:	83 c4 10             	add    $0x10,%esp
  8013b5:	eb b5                	jmp    80136c <fd_close+0x40>

008013b7 <close>:

int
close(int fdnum)
{
  8013b7:	f3 0f 1e fb          	endbr32 
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c4:	50                   	push   %eax
  8013c5:	ff 75 08             	pushl  0x8(%ebp)
  8013c8:	e8 b1 fe ff ff       	call   80127e <fd_lookup>
  8013cd:	83 c4 10             	add    $0x10,%esp
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	79 02                	jns    8013d6 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8013d4:	c9                   	leave  
  8013d5:	c3                   	ret    
		return fd_close(fd, 1);
  8013d6:	83 ec 08             	sub    $0x8,%esp
  8013d9:	6a 01                	push   $0x1
  8013db:	ff 75 f4             	pushl  -0xc(%ebp)
  8013de:	e8 49 ff ff ff       	call   80132c <fd_close>
  8013e3:	83 c4 10             	add    $0x10,%esp
  8013e6:	eb ec                	jmp    8013d4 <close+0x1d>

008013e8 <close_all>:

void
close_all(void)
{
  8013e8:	f3 0f 1e fb          	endbr32 
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	53                   	push   %ebx
  8013f0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013f8:	83 ec 0c             	sub    $0xc,%esp
  8013fb:	53                   	push   %ebx
  8013fc:	e8 b6 ff ff ff       	call   8013b7 <close>
	for (i = 0; i < MAXFD; i++)
  801401:	83 c3 01             	add    $0x1,%ebx
  801404:	83 c4 10             	add    $0x10,%esp
  801407:	83 fb 20             	cmp    $0x20,%ebx
  80140a:	75 ec                	jne    8013f8 <close_all+0x10>
}
  80140c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140f:	c9                   	leave  
  801410:	c3                   	ret    

00801411 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801411:	f3 0f 1e fb          	endbr32 
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	57                   	push   %edi
  801419:	56                   	push   %esi
  80141a:	53                   	push   %ebx
  80141b:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80141e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801421:	50                   	push   %eax
  801422:	ff 75 08             	pushl  0x8(%ebp)
  801425:	e8 54 fe ff ff       	call   80127e <fd_lookup>
  80142a:	89 c3                	mov    %eax,%ebx
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	85 c0                	test   %eax,%eax
  801431:	0f 88 81 00 00 00    	js     8014b8 <dup+0xa7>
		return r;
	close(newfdnum);
  801437:	83 ec 0c             	sub    $0xc,%esp
  80143a:	ff 75 0c             	pushl  0xc(%ebp)
  80143d:	e8 75 ff ff ff       	call   8013b7 <close>

	newfd = INDEX2FD(newfdnum);
  801442:	8b 75 0c             	mov    0xc(%ebp),%esi
  801445:	c1 e6 0c             	shl    $0xc,%esi
  801448:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80144e:	83 c4 04             	add    $0x4,%esp
  801451:	ff 75 e4             	pushl  -0x1c(%ebp)
  801454:	e8 b4 fd ff ff       	call   80120d <fd2data>
  801459:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80145b:	89 34 24             	mov    %esi,(%esp)
  80145e:	e8 aa fd ff ff       	call   80120d <fd2data>
  801463:	83 c4 10             	add    $0x10,%esp
  801466:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801468:	89 d8                	mov    %ebx,%eax
  80146a:	c1 e8 16             	shr    $0x16,%eax
  80146d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801474:	a8 01                	test   $0x1,%al
  801476:	74 11                	je     801489 <dup+0x78>
  801478:	89 d8                	mov    %ebx,%eax
  80147a:	c1 e8 0c             	shr    $0xc,%eax
  80147d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801484:	f6 c2 01             	test   $0x1,%dl
  801487:	75 39                	jne    8014c2 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801489:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80148c:	89 d0                	mov    %edx,%eax
  80148e:	c1 e8 0c             	shr    $0xc,%eax
  801491:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801498:	83 ec 0c             	sub    $0xc,%esp
  80149b:	25 07 0e 00 00       	and    $0xe07,%eax
  8014a0:	50                   	push   %eax
  8014a1:	56                   	push   %esi
  8014a2:	6a 00                	push   $0x0
  8014a4:	52                   	push   %edx
  8014a5:	6a 00                	push   $0x0
  8014a7:	e8 3d f8 ff ff       	call   800ce9 <sys_page_map>
  8014ac:	89 c3                	mov    %eax,%ebx
  8014ae:	83 c4 20             	add    $0x20,%esp
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	78 31                	js     8014e6 <dup+0xd5>
		goto err;

	return newfdnum;
  8014b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014b8:	89 d8                	mov    %ebx,%eax
  8014ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014bd:	5b                   	pop    %ebx
  8014be:	5e                   	pop    %esi
  8014bf:	5f                   	pop    %edi
  8014c0:	5d                   	pop    %ebp
  8014c1:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c9:	83 ec 0c             	sub    $0xc,%esp
  8014cc:	25 07 0e 00 00       	and    $0xe07,%eax
  8014d1:	50                   	push   %eax
  8014d2:	57                   	push   %edi
  8014d3:	6a 00                	push   $0x0
  8014d5:	53                   	push   %ebx
  8014d6:	6a 00                	push   $0x0
  8014d8:	e8 0c f8 ff ff       	call   800ce9 <sys_page_map>
  8014dd:	89 c3                	mov    %eax,%ebx
  8014df:	83 c4 20             	add    $0x20,%esp
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	79 a3                	jns    801489 <dup+0x78>
	sys_page_unmap(0, newfd);
  8014e6:	83 ec 08             	sub    $0x8,%esp
  8014e9:	56                   	push   %esi
  8014ea:	6a 00                	push   $0x0
  8014ec:	e8 3e f8 ff ff       	call   800d2f <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014f1:	83 c4 08             	add    $0x8,%esp
  8014f4:	57                   	push   %edi
  8014f5:	6a 00                	push   $0x0
  8014f7:	e8 33 f8 ff ff       	call   800d2f <sys_page_unmap>
	return r;
  8014fc:	83 c4 10             	add    $0x10,%esp
  8014ff:	eb b7                	jmp    8014b8 <dup+0xa7>

00801501 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801501:	f3 0f 1e fb          	endbr32 
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	53                   	push   %ebx
  801509:	83 ec 1c             	sub    $0x1c,%esp
  80150c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801512:	50                   	push   %eax
  801513:	53                   	push   %ebx
  801514:	e8 65 fd ff ff       	call   80127e <fd_lookup>
  801519:	83 c4 10             	add    $0x10,%esp
  80151c:	85 c0                	test   %eax,%eax
  80151e:	78 3f                	js     80155f <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801520:	83 ec 08             	sub    $0x8,%esp
  801523:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801526:	50                   	push   %eax
  801527:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152a:	ff 30                	pushl  (%eax)
  80152c:	e8 a1 fd ff ff       	call   8012d2 <dev_lookup>
  801531:	83 c4 10             	add    $0x10,%esp
  801534:	85 c0                	test   %eax,%eax
  801536:	78 27                	js     80155f <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801538:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80153b:	8b 42 08             	mov    0x8(%edx),%eax
  80153e:	83 e0 03             	and    $0x3,%eax
  801541:	83 f8 01             	cmp    $0x1,%eax
  801544:	74 1e                	je     801564 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801546:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801549:	8b 40 08             	mov    0x8(%eax),%eax
  80154c:	85 c0                	test   %eax,%eax
  80154e:	74 35                	je     801585 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801550:	83 ec 04             	sub    $0x4,%esp
  801553:	ff 75 10             	pushl  0x10(%ebp)
  801556:	ff 75 0c             	pushl  0xc(%ebp)
  801559:	52                   	push   %edx
  80155a:	ff d0                	call   *%eax
  80155c:	83 c4 10             	add    $0x10,%esp
}
  80155f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801562:	c9                   	leave  
  801563:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801564:	a1 04 40 80 00       	mov    0x804004,%eax
  801569:	8b 40 48             	mov    0x48(%eax),%eax
  80156c:	83 ec 04             	sub    $0x4,%esp
  80156f:	53                   	push   %ebx
  801570:	50                   	push   %eax
  801571:	68 45 27 80 00       	push   $0x802745
  801576:	e8 dc ec ff ff       	call   800257 <cprintf>
		return -E_INVAL;
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801583:	eb da                	jmp    80155f <read+0x5e>
		return -E_NOT_SUPP;
  801585:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80158a:	eb d3                	jmp    80155f <read+0x5e>

0080158c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80158c:	f3 0f 1e fb          	endbr32 
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	57                   	push   %edi
  801594:	56                   	push   %esi
  801595:	53                   	push   %ebx
  801596:	83 ec 0c             	sub    $0xc,%esp
  801599:	8b 7d 08             	mov    0x8(%ebp),%edi
  80159c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80159f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a4:	eb 02                	jmp    8015a8 <readn+0x1c>
  8015a6:	01 c3                	add    %eax,%ebx
  8015a8:	39 f3                	cmp    %esi,%ebx
  8015aa:	73 21                	jae    8015cd <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015ac:	83 ec 04             	sub    $0x4,%esp
  8015af:	89 f0                	mov    %esi,%eax
  8015b1:	29 d8                	sub    %ebx,%eax
  8015b3:	50                   	push   %eax
  8015b4:	89 d8                	mov    %ebx,%eax
  8015b6:	03 45 0c             	add    0xc(%ebp),%eax
  8015b9:	50                   	push   %eax
  8015ba:	57                   	push   %edi
  8015bb:	e8 41 ff ff ff       	call   801501 <read>
		if (m < 0)
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	78 04                	js     8015cb <readn+0x3f>
			return m;
		if (m == 0)
  8015c7:	75 dd                	jne    8015a6 <readn+0x1a>
  8015c9:	eb 02                	jmp    8015cd <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015cb:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8015cd:	89 d8                	mov    %ebx,%eax
  8015cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d2:	5b                   	pop    %ebx
  8015d3:	5e                   	pop    %esi
  8015d4:	5f                   	pop    %edi
  8015d5:	5d                   	pop    %ebp
  8015d6:	c3                   	ret    

008015d7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015d7:	f3 0f 1e fb          	endbr32 
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	53                   	push   %ebx
  8015df:	83 ec 1c             	sub    $0x1c,%esp
  8015e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e8:	50                   	push   %eax
  8015e9:	53                   	push   %ebx
  8015ea:	e8 8f fc ff ff       	call   80127e <fd_lookup>
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	78 3a                	js     801630 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f6:	83 ec 08             	sub    $0x8,%esp
  8015f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fc:	50                   	push   %eax
  8015fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801600:	ff 30                	pushl  (%eax)
  801602:	e8 cb fc ff ff       	call   8012d2 <dev_lookup>
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	85 c0                	test   %eax,%eax
  80160c:	78 22                	js     801630 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80160e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801611:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801615:	74 1e                	je     801635 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801617:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161a:	8b 52 0c             	mov    0xc(%edx),%edx
  80161d:	85 d2                	test   %edx,%edx
  80161f:	74 35                	je     801656 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801621:	83 ec 04             	sub    $0x4,%esp
  801624:	ff 75 10             	pushl  0x10(%ebp)
  801627:	ff 75 0c             	pushl  0xc(%ebp)
  80162a:	50                   	push   %eax
  80162b:	ff d2                	call   *%edx
  80162d:	83 c4 10             	add    $0x10,%esp
}
  801630:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801633:	c9                   	leave  
  801634:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801635:	a1 04 40 80 00       	mov    0x804004,%eax
  80163a:	8b 40 48             	mov    0x48(%eax),%eax
  80163d:	83 ec 04             	sub    $0x4,%esp
  801640:	53                   	push   %ebx
  801641:	50                   	push   %eax
  801642:	68 61 27 80 00       	push   $0x802761
  801647:	e8 0b ec ff ff       	call   800257 <cprintf>
		return -E_INVAL;
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801654:	eb da                	jmp    801630 <write+0x59>
		return -E_NOT_SUPP;
  801656:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80165b:	eb d3                	jmp    801630 <write+0x59>

0080165d <seek>:

int
seek(int fdnum, off_t offset)
{
  80165d:	f3 0f 1e fb          	endbr32 
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801667:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166a:	50                   	push   %eax
  80166b:	ff 75 08             	pushl  0x8(%ebp)
  80166e:	e8 0b fc ff ff       	call   80127e <fd_lookup>
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	85 c0                	test   %eax,%eax
  801678:	78 0e                	js     801688 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80167a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80167d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801680:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801683:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801688:	c9                   	leave  
  801689:	c3                   	ret    

0080168a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80168a:	f3 0f 1e fb          	endbr32 
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	53                   	push   %ebx
  801692:	83 ec 1c             	sub    $0x1c,%esp
  801695:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801698:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169b:	50                   	push   %eax
  80169c:	53                   	push   %ebx
  80169d:	e8 dc fb ff ff       	call   80127e <fd_lookup>
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	85 c0                	test   %eax,%eax
  8016a7:	78 37                	js     8016e0 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a9:	83 ec 08             	sub    $0x8,%esp
  8016ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016af:	50                   	push   %eax
  8016b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b3:	ff 30                	pushl  (%eax)
  8016b5:	e8 18 fc ff ff       	call   8012d2 <dev_lookup>
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	85 c0                	test   %eax,%eax
  8016bf:	78 1f                	js     8016e0 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c8:	74 1b                	je     8016e5 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8016ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016cd:	8b 52 18             	mov    0x18(%edx),%edx
  8016d0:	85 d2                	test   %edx,%edx
  8016d2:	74 32                	je     801706 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016d4:	83 ec 08             	sub    $0x8,%esp
  8016d7:	ff 75 0c             	pushl  0xc(%ebp)
  8016da:	50                   	push   %eax
  8016db:	ff d2                	call   *%edx
  8016dd:	83 c4 10             	add    $0x10,%esp
}
  8016e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e3:	c9                   	leave  
  8016e4:	c3                   	ret    
			thisenv->env_id, fdnum);
  8016e5:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016ea:	8b 40 48             	mov    0x48(%eax),%eax
  8016ed:	83 ec 04             	sub    $0x4,%esp
  8016f0:	53                   	push   %ebx
  8016f1:	50                   	push   %eax
  8016f2:	68 24 27 80 00       	push   $0x802724
  8016f7:	e8 5b eb ff ff       	call   800257 <cprintf>
		return -E_INVAL;
  8016fc:	83 c4 10             	add    $0x10,%esp
  8016ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801704:	eb da                	jmp    8016e0 <ftruncate+0x56>
		return -E_NOT_SUPP;
  801706:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80170b:	eb d3                	jmp    8016e0 <ftruncate+0x56>

0080170d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80170d:	f3 0f 1e fb          	endbr32 
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	53                   	push   %ebx
  801715:	83 ec 1c             	sub    $0x1c,%esp
  801718:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80171b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171e:	50                   	push   %eax
  80171f:	ff 75 08             	pushl  0x8(%ebp)
  801722:	e8 57 fb ff ff       	call   80127e <fd_lookup>
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	85 c0                	test   %eax,%eax
  80172c:	78 4b                	js     801779 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172e:	83 ec 08             	sub    $0x8,%esp
  801731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801734:	50                   	push   %eax
  801735:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801738:	ff 30                	pushl  (%eax)
  80173a:	e8 93 fb ff ff       	call   8012d2 <dev_lookup>
  80173f:	83 c4 10             	add    $0x10,%esp
  801742:	85 c0                	test   %eax,%eax
  801744:	78 33                	js     801779 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801746:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801749:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80174d:	74 2f                	je     80177e <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80174f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801752:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801759:	00 00 00 
	stat->st_isdir = 0;
  80175c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801763:	00 00 00 
	stat->st_dev = dev;
  801766:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80176c:	83 ec 08             	sub    $0x8,%esp
  80176f:	53                   	push   %ebx
  801770:	ff 75 f0             	pushl  -0x10(%ebp)
  801773:	ff 50 14             	call   *0x14(%eax)
  801776:	83 c4 10             	add    $0x10,%esp
}
  801779:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177c:	c9                   	leave  
  80177d:	c3                   	ret    
		return -E_NOT_SUPP;
  80177e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801783:	eb f4                	jmp    801779 <fstat+0x6c>

00801785 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801785:	f3 0f 1e fb          	endbr32 
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	56                   	push   %esi
  80178d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80178e:	83 ec 08             	sub    $0x8,%esp
  801791:	6a 00                	push   $0x0
  801793:	ff 75 08             	pushl  0x8(%ebp)
  801796:	e8 fb 01 00 00       	call   801996 <open>
  80179b:	89 c3                	mov    %eax,%ebx
  80179d:	83 c4 10             	add    $0x10,%esp
  8017a0:	85 c0                	test   %eax,%eax
  8017a2:	78 1b                	js     8017bf <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8017a4:	83 ec 08             	sub    $0x8,%esp
  8017a7:	ff 75 0c             	pushl  0xc(%ebp)
  8017aa:	50                   	push   %eax
  8017ab:	e8 5d ff ff ff       	call   80170d <fstat>
  8017b0:	89 c6                	mov    %eax,%esi
	close(fd);
  8017b2:	89 1c 24             	mov    %ebx,(%esp)
  8017b5:	e8 fd fb ff ff       	call   8013b7 <close>
	return r;
  8017ba:	83 c4 10             	add    $0x10,%esp
  8017bd:	89 f3                	mov    %esi,%ebx
}
  8017bf:	89 d8                	mov    %ebx,%eax
  8017c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c4:	5b                   	pop    %ebx
  8017c5:	5e                   	pop    %esi
  8017c6:	5d                   	pop    %ebp
  8017c7:	c3                   	ret    

008017c8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	56                   	push   %esi
  8017cc:	53                   	push   %ebx
  8017cd:	89 c6                	mov    %eax,%esi
  8017cf:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017d1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017d8:	74 27                	je     801801 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017da:	6a 07                	push   $0x7
  8017dc:	68 00 50 80 00       	push   $0x805000
  8017e1:	56                   	push   %esi
  8017e2:	ff 35 00 40 80 00    	pushl  0x804000
  8017e8:	e8 69 f9 ff ff       	call   801156 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017ed:	83 c4 0c             	add    $0xc,%esp
  8017f0:	6a 00                	push   $0x0
  8017f2:	53                   	push   %ebx
  8017f3:	6a 00                	push   $0x0
  8017f5:	e8 05 f9 ff ff       	call   8010ff <ipc_recv>
}
  8017fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017fd:	5b                   	pop    %ebx
  8017fe:	5e                   	pop    %esi
  8017ff:	5d                   	pop    %ebp
  801800:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801801:	83 ec 0c             	sub    $0xc,%esp
  801804:	6a 01                	push   $0x1
  801806:	e8 b1 f9 ff ff       	call   8011bc <ipc_find_env>
  80180b:	a3 00 40 80 00       	mov    %eax,0x804000
  801810:	83 c4 10             	add    $0x10,%esp
  801813:	eb c5                	jmp    8017da <fsipc+0x12>

00801815 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801815:	f3 0f 1e fb          	endbr32 
  801819:	55                   	push   %ebp
  80181a:	89 e5                	mov    %esp,%ebp
  80181c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80181f:	8b 45 08             	mov    0x8(%ebp),%eax
  801822:	8b 40 0c             	mov    0xc(%eax),%eax
  801825:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80182a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801832:	ba 00 00 00 00       	mov    $0x0,%edx
  801837:	b8 02 00 00 00       	mov    $0x2,%eax
  80183c:	e8 87 ff ff ff       	call   8017c8 <fsipc>
}
  801841:	c9                   	leave  
  801842:	c3                   	ret    

00801843 <devfile_flush>:
{
  801843:	f3 0f 1e fb          	endbr32 
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80184d:	8b 45 08             	mov    0x8(%ebp),%eax
  801850:	8b 40 0c             	mov    0xc(%eax),%eax
  801853:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801858:	ba 00 00 00 00       	mov    $0x0,%edx
  80185d:	b8 06 00 00 00       	mov    $0x6,%eax
  801862:	e8 61 ff ff ff       	call   8017c8 <fsipc>
}
  801867:	c9                   	leave  
  801868:	c3                   	ret    

00801869 <devfile_stat>:
{
  801869:	f3 0f 1e fb          	endbr32 
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
  801870:	53                   	push   %ebx
  801871:	83 ec 04             	sub    $0x4,%esp
  801874:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801877:	8b 45 08             	mov    0x8(%ebp),%eax
  80187a:	8b 40 0c             	mov    0xc(%eax),%eax
  80187d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801882:	ba 00 00 00 00       	mov    $0x0,%edx
  801887:	b8 05 00 00 00       	mov    $0x5,%eax
  80188c:	e8 37 ff ff ff       	call   8017c8 <fsipc>
  801891:	85 c0                	test   %eax,%eax
  801893:	78 2c                	js     8018c1 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801895:	83 ec 08             	sub    $0x8,%esp
  801898:	68 00 50 80 00       	push   $0x805000
  80189d:	53                   	push   %ebx
  80189e:	e8 bd ef ff ff       	call   800860 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018a3:	a1 80 50 80 00       	mov    0x805080,%eax
  8018a8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018ae:	a1 84 50 80 00       	mov    0x805084,%eax
  8018b3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018b9:	83 c4 10             	add    $0x10,%esp
  8018bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c4:	c9                   	leave  
  8018c5:	c3                   	ret    

008018c6 <devfile_write>:
{
  8018c6:	f3 0f 1e fb          	endbr32 
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	83 ec 0c             	sub    $0xc,%esp
  8018d0:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  8018d3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018d8:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018dd:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8018e3:	8b 52 0c             	mov    0xc(%edx),%edx
  8018e6:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018ec:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018f1:	50                   	push   %eax
  8018f2:	ff 75 0c             	pushl  0xc(%ebp)
  8018f5:	68 08 50 80 00       	push   $0x805008
  8018fa:	e8 17 f1 ff ff       	call   800a16 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801904:	b8 04 00 00 00       	mov    $0x4,%eax
  801909:	e8 ba fe ff ff       	call   8017c8 <fsipc>
}
  80190e:	c9                   	leave  
  80190f:	c3                   	ret    

00801910 <devfile_read>:
{
  801910:	f3 0f 1e fb          	endbr32 
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	56                   	push   %esi
  801918:	53                   	push   %ebx
  801919:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80191c:	8b 45 08             	mov    0x8(%ebp),%eax
  80191f:	8b 40 0c             	mov    0xc(%eax),%eax
  801922:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801927:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80192d:	ba 00 00 00 00       	mov    $0x0,%edx
  801932:	b8 03 00 00 00       	mov    $0x3,%eax
  801937:	e8 8c fe ff ff       	call   8017c8 <fsipc>
  80193c:	89 c3                	mov    %eax,%ebx
  80193e:	85 c0                	test   %eax,%eax
  801940:	78 1f                	js     801961 <devfile_read+0x51>
	assert(r <= n);
  801942:	39 f0                	cmp    %esi,%eax
  801944:	77 24                	ja     80196a <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801946:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80194b:	7f 33                	jg     801980 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80194d:	83 ec 04             	sub    $0x4,%esp
  801950:	50                   	push   %eax
  801951:	68 00 50 80 00       	push   $0x805000
  801956:	ff 75 0c             	pushl  0xc(%ebp)
  801959:	e8 b8 f0 ff ff       	call   800a16 <memmove>
	return r;
  80195e:	83 c4 10             	add    $0x10,%esp
}
  801961:	89 d8                	mov    %ebx,%eax
  801963:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801966:	5b                   	pop    %ebx
  801967:	5e                   	pop    %esi
  801968:	5d                   	pop    %ebp
  801969:	c3                   	ret    
	assert(r <= n);
  80196a:	68 90 27 80 00       	push   $0x802790
  80196f:	68 97 27 80 00       	push   $0x802797
  801974:	6a 7c                	push   $0x7c
  801976:	68 ac 27 80 00       	push   $0x8027ac
  80197b:	e8 f0 e7 ff ff       	call   800170 <_panic>
	assert(r <= PGSIZE);
  801980:	68 b7 27 80 00       	push   $0x8027b7
  801985:	68 97 27 80 00       	push   $0x802797
  80198a:	6a 7d                	push   $0x7d
  80198c:	68 ac 27 80 00       	push   $0x8027ac
  801991:	e8 da e7 ff ff       	call   800170 <_panic>

00801996 <open>:
{
  801996:	f3 0f 1e fb          	endbr32 
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	56                   	push   %esi
  80199e:	53                   	push   %ebx
  80199f:	83 ec 1c             	sub    $0x1c,%esp
  8019a2:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8019a5:	56                   	push   %esi
  8019a6:	e8 72 ee ff ff       	call   80081d <strlen>
  8019ab:	83 c4 10             	add    $0x10,%esp
  8019ae:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019b3:	7f 6c                	jg     801a21 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8019b5:	83 ec 0c             	sub    $0xc,%esp
  8019b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019bb:	50                   	push   %eax
  8019bc:	e8 67 f8 ff ff       	call   801228 <fd_alloc>
  8019c1:	89 c3                	mov    %eax,%ebx
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	85 c0                	test   %eax,%eax
  8019c8:	78 3c                	js     801a06 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8019ca:	83 ec 08             	sub    $0x8,%esp
  8019cd:	56                   	push   %esi
  8019ce:	68 00 50 80 00       	push   $0x805000
  8019d3:	e8 88 ee ff ff       	call   800860 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019db:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8019e8:	e8 db fd ff ff       	call   8017c8 <fsipc>
  8019ed:	89 c3                	mov    %eax,%ebx
  8019ef:	83 c4 10             	add    $0x10,%esp
  8019f2:	85 c0                	test   %eax,%eax
  8019f4:	78 19                	js     801a0f <open+0x79>
	return fd2num(fd);
  8019f6:	83 ec 0c             	sub    $0xc,%esp
  8019f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8019fc:	e8 f8 f7 ff ff       	call   8011f9 <fd2num>
  801a01:	89 c3                	mov    %eax,%ebx
  801a03:	83 c4 10             	add    $0x10,%esp
}
  801a06:	89 d8                	mov    %ebx,%eax
  801a08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0b:	5b                   	pop    %ebx
  801a0c:	5e                   	pop    %esi
  801a0d:	5d                   	pop    %ebp
  801a0e:	c3                   	ret    
		fd_close(fd, 0);
  801a0f:	83 ec 08             	sub    $0x8,%esp
  801a12:	6a 00                	push   $0x0
  801a14:	ff 75 f4             	pushl  -0xc(%ebp)
  801a17:	e8 10 f9 ff ff       	call   80132c <fd_close>
		return r;
  801a1c:	83 c4 10             	add    $0x10,%esp
  801a1f:	eb e5                	jmp    801a06 <open+0x70>
		return -E_BAD_PATH;
  801a21:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a26:	eb de                	jmp    801a06 <open+0x70>

00801a28 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a28:	f3 0f 1e fb          	endbr32 
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a32:	ba 00 00 00 00       	mov    $0x0,%edx
  801a37:	b8 08 00 00 00       	mov    $0x8,%eax
  801a3c:	e8 87 fd ff ff       	call   8017c8 <fsipc>
}
  801a41:	c9                   	leave  
  801a42:	c3                   	ret    

00801a43 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a43:	f3 0f 1e fb          	endbr32 
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	56                   	push   %esi
  801a4b:	53                   	push   %ebx
  801a4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a4f:	83 ec 0c             	sub    $0xc,%esp
  801a52:	ff 75 08             	pushl  0x8(%ebp)
  801a55:	e8 b3 f7 ff ff       	call   80120d <fd2data>
  801a5a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a5c:	83 c4 08             	add    $0x8,%esp
  801a5f:	68 c3 27 80 00       	push   $0x8027c3
  801a64:	53                   	push   %ebx
  801a65:	e8 f6 ed ff ff       	call   800860 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a6a:	8b 46 04             	mov    0x4(%esi),%eax
  801a6d:	2b 06                	sub    (%esi),%eax
  801a6f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a75:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a7c:	00 00 00 
	stat->st_dev = &devpipe;
  801a7f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a86:	30 80 00 
	return 0;
}
  801a89:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a91:	5b                   	pop    %ebx
  801a92:	5e                   	pop    %esi
  801a93:	5d                   	pop    %ebp
  801a94:	c3                   	ret    

00801a95 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a95:	f3 0f 1e fb          	endbr32 
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	53                   	push   %ebx
  801a9d:	83 ec 0c             	sub    $0xc,%esp
  801aa0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801aa3:	53                   	push   %ebx
  801aa4:	6a 00                	push   $0x0
  801aa6:	e8 84 f2 ff ff       	call   800d2f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801aab:	89 1c 24             	mov    %ebx,(%esp)
  801aae:	e8 5a f7 ff ff       	call   80120d <fd2data>
  801ab3:	83 c4 08             	add    $0x8,%esp
  801ab6:	50                   	push   %eax
  801ab7:	6a 00                	push   $0x0
  801ab9:	e8 71 f2 ff ff       	call   800d2f <sys_page_unmap>
}
  801abe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac1:	c9                   	leave  
  801ac2:	c3                   	ret    

00801ac3 <_pipeisclosed>:
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	57                   	push   %edi
  801ac7:	56                   	push   %esi
  801ac8:	53                   	push   %ebx
  801ac9:	83 ec 1c             	sub    $0x1c,%esp
  801acc:	89 c7                	mov    %eax,%edi
  801ace:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801ad0:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ad8:	83 ec 0c             	sub    $0xc,%esp
  801adb:	57                   	push   %edi
  801adc:	e8 03 05 00 00       	call   801fe4 <pageref>
  801ae1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ae4:	89 34 24             	mov    %esi,(%esp)
  801ae7:	e8 f8 04 00 00       	call   801fe4 <pageref>
		nn = thisenv->env_runs;
  801aec:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801af2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801af5:	83 c4 10             	add    $0x10,%esp
  801af8:	39 cb                	cmp    %ecx,%ebx
  801afa:	74 1b                	je     801b17 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801afc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801aff:	75 cf                	jne    801ad0 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b01:	8b 42 58             	mov    0x58(%edx),%eax
  801b04:	6a 01                	push   $0x1
  801b06:	50                   	push   %eax
  801b07:	53                   	push   %ebx
  801b08:	68 ca 27 80 00       	push   $0x8027ca
  801b0d:	e8 45 e7 ff ff       	call   800257 <cprintf>
  801b12:	83 c4 10             	add    $0x10,%esp
  801b15:	eb b9                	jmp    801ad0 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b17:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b1a:	0f 94 c0             	sete   %al
  801b1d:	0f b6 c0             	movzbl %al,%eax
}
  801b20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b23:	5b                   	pop    %ebx
  801b24:	5e                   	pop    %esi
  801b25:	5f                   	pop    %edi
  801b26:	5d                   	pop    %ebp
  801b27:	c3                   	ret    

00801b28 <devpipe_write>:
{
  801b28:	f3 0f 1e fb          	endbr32 
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	57                   	push   %edi
  801b30:	56                   	push   %esi
  801b31:	53                   	push   %ebx
  801b32:	83 ec 28             	sub    $0x28,%esp
  801b35:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b38:	56                   	push   %esi
  801b39:	e8 cf f6 ff ff       	call   80120d <fd2data>
  801b3e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b40:	83 c4 10             	add    $0x10,%esp
  801b43:	bf 00 00 00 00       	mov    $0x0,%edi
  801b48:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b4b:	74 4f                	je     801b9c <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b4d:	8b 43 04             	mov    0x4(%ebx),%eax
  801b50:	8b 0b                	mov    (%ebx),%ecx
  801b52:	8d 51 20             	lea    0x20(%ecx),%edx
  801b55:	39 d0                	cmp    %edx,%eax
  801b57:	72 14                	jb     801b6d <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801b59:	89 da                	mov    %ebx,%edx
  801b5b:	89 f0                	mov    %esi,%eax
  801b5d:	e8 61 ff ff ff       	call   801ac3 <_pipeisclosed>
  801b62:	85 c0                	test   %eax,%eax
  801b64:	75 3b                	jne    801ba1 <devpipe_write+0x79>
			sys_yield();
  801b66:	e8 14 f1 ff ff       	call   800c7f <sys_yield>
  801b6b:	eb e0                	jmp    801b4d <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b70:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b74:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b77:	89 c2                	mov    %eax,%edx
  801b79:	c1 fa 1f             	sar    $0x1f,%edx
  801b7c:	89 d1                	mov    %edx,%ecx
  801b7e:	c1 e9 1b             	shr    $0x1b,%ecx
  801b81:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b84:	83 e2 1f             	and    $0x1f,%edx
  801b87:	29 ca                	sub    %ecx,%edx
  801b89:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b8d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b91:	83 c0 01             	add    $0x1,%eax
  801b94:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b97:	83 c7 01             	add    $0x1,%edi
  801b9a:	eb ac                	jmp    801b48 <devpipe_write+0x20>
	return i;
  801b9c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b9f:	eb 05                	jmp    801ba6 <devpipe_write+0x7e>
				return 0;
  801ba1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ba6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba9:	5b                   	pop    %ebx
  801baa:	5e                   	pop    %esi
  801bab:	5f                   	pop    %edi
  801bac:	5d                   	pop    %ebp
  801bad:	c3                   	ret    

00801bae <devpipe_read>:
{
  801bae:	f3 0f 1e fb          	endbr32 
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	57                   	push   %edi
  801bb6:	56                   	push   %esi
  801bb7:	53                   	push   %ebx
  801bb8:	83 ec 18             	sub    $0x18,%esp
  801bbb:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801bbe:	57                   	push   %edi
  801bbf:	e8 49 f6 ff ff       	call   80120d <fd2data>
  801bc4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801bc6:	83 c4 10             	add    $0x10,%esp
  801bc9:	be 00 00 00 00       	mov    $0x0,%esi
  801bce:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bd1:	75 14                	jne    801be7 <devpipe_read+0x39>
	return i;
  801bd3:	8b 45 10             	mov    0x10(%ebp),%eax
  801bd6:	eb 02                	jmp    801bda <devpipe_read+0x2c>
				return i;
  801bd8:	89 f0                	mov    %esi,%eax
}
  801bda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bdd:	5b                   	pop    %ebx
  801bde:	5e                   	pop    %esi
  801bdf:	5f                   	pop    %edi
  801be0:	5d                   	pop    %ebp
  801be1:	c3                   	ret    
			sys_yield();
  801be2:	e8 98 f0 ff ff       	call   800c7f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801be7:	8b 03                	mov    (%ebx),%eax
  801be9:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bec:	75 18                	jne    801c06 <devpipe_read+0x58>
			if (i > 0)
  801bee:	85 f6                	test   %esi,%esi
  801bf0:	75 e6                	jne    801bd8 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801bf2:	89 da                	mov    %ebx,%edx
  801bf4:	89 f8                	mov    %edi,%eax
  801bf6:	e8 c8 fe ff ff       	call   801ac3 <_pipeisclosed>
  801bfb:	85 c0                	test   %eax,%eax
  801bfd:	74 e3                	je     801be2 <devpipe_read+0x34>
				return 0;
  801bff:	b8 00 00 00 00       	mov    $0x0,%eax
  801c04:	eb d4                	jmp    801bda <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c06:	99                   	cltd   
  801c07:	c1 ea 1b             	shr    $0x1b,%edx
  801c0a:	01 d0                	add    %edx,%eax
  801c0c:	83 e0 1f             	and    $0x1f,%eax
  801c0f:	29 d0                	sub    %edx,%eax
  801c11:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c19:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c1c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c1f:	83 c6 01             	add    $0x1,%esi
  801c22:	eb aa                	jmp    801bce <devpipe_read+0x20>

00801c24 <pipe>:
{
  801c24:	f3 0f 1e fb          	endbr32 
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
  801c2b:	56                   	push   %esi
  801c2c:	53                   	push   %ebx
  801c2d:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c33:	50                   	push   %eax
  801c34:	e8 ef f5 ff ff       	call   801228 <fd_alloc>
  801c39:	89 c3                	mov    %eax,%ebx
  801c3b:	83 c4 10             	add    $0x10,%esp
  801c3e:	85 c0                	test   %eax,%eax
  801c40:	0f 88 23 01 00 00    	js     801d69 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c46:	83 ec 04             	sub    $0x4,%esp
  801c49:	68 07 04 00 00       	push   $0x407
  801c4e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c51:	6a 00                	push   $0x0
  801c53:	e8 4a f0 ff ff       	call   800ca2 <sys_page_alloc>
  801c58:	89 c3                	mov    %eax,%ebx
  801c5a:	83 c4 10             	add    $0x10,%esp
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	0f 88 04 01 00 00    	js     801d69 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801c65:	83 ec 0c             	sub    $0xc,%esp
  801c68:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c6b:	50                   	push   %eax
  801c6c:	e8 b7 f5 ff ff       	call   801228 <fd_alloc>
  801c71:	89 c3                	mov    %eax,%ebx
  801c73:	83 c4 10             	add    $0x10,%esp
  801c76:	85 c0                	test   %eax,%eax
  801c78:	0f 88 db 00 00 00    	js     801d59 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c7e:	83 ec 04             	sub    $0x4,%esp
  801c81:	68 07 04 00 00       	push   $0x407
  801c86:	ff 75 f0             	pushl  -0x10(%ebp)
  801c89:	6a 00                	push   $0x0
  801c8b:	e8 12 f0 ff ff       	call   800ca2 <sys_page_alloc>
  801c90:	89 c3                	mov    %eax,%ebx
  801c92:	83 c4 10             	add    $0x10,%esp
  801c95:	85 c0                	test   %eax,%eax
  801c97:	0f 88 bc 00 00 00    	js     801d59 <pipe+0x135>
	va = fd2data(fd0);
  801c9d:	83 ec 0c             	sub    $0xc,%esp
  801ca0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca3:	e8 65 f5 ff ff       	call   80120d <fd2data>
  801ca8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801caa:	83 c4 0c             	add    $0xc,%esp
  801cad:	68 07 04 00 00       	push   $0x407
  801cb2:	50                   	push   %eax
  801cb3:	6a 00                	push   $0x0
  801cb5:	e8 e8 ef ff ff       	call   800ca2 <sys_page_alloc>
  801cba:	89 c3                	mov    %eax,%ebx
  801cbc:	83 c4 10             	add    $0x10,%esp
  801cbf:	85 c0                	test   %eax,%eax
  801cc1:	0f 88 82 00 00 00    	js     801d49 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc7:	83 ec 0c             	sub    $0xc,%esp
  801cca:	ff 75 f0             	pushl  -0x10(%ebp)
  801ccd:	e8 3b f5 ff ff       	call   80120d <fd2data>
  801cd2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cd9:	50                   	push   %eax
  801cda:	6a 00                	push   $0x0
  801cdc:	56                   	push   %esi
  801cdd:	6a 00                	push   $0x0
  801cdf:	e8 05 f0 ff ff       	call   800ce9 <sys_page_map>
  801ce4:	89 c3                	mov    %eax,%ebx
  801ce6:	83 c4 20             	add    $0x20,%esp
  801ce9:	85 c0                	test   %eax,%eax
  801ceb:	78 4e                	js     801d3b <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801ced:	a1 20 30 80 00       	mov    0x803020,%eax
  801cf2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cf5:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801cf7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cfa:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801d01:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d04:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801d06:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d09:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d10:	83 ec 0c             	sub    $0xc,%esp
  801d13:	ff 75 f4             	pushl  -0xc(%ebp)
  801d16:	e8 de f4 ff ff       	call   8011f9 <fd2num>
  801d1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d1e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d20:	83 c4 04             	add    $0x4,%esp
  801d23:	ff 75 f0             	pushl  -0x10(%ebp)
  801d26:	e8 ce f4 ff ff       	call   8011f9 <fd2num>
  801d2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d2e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d31:	83 c4 10             	add    $0x10,%esp
  801d34:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d39:	eb 2e                	jmp    801d69 <pipe+0x145>
	sys_page_unmap(0, va);
  801d3b:	83 ec 08             	sub    $0x8,%esp
  801d3e:	56                   	push   %esi
  801d3f:	6a 00                	push   $0x0
  801d41:	e8 e9 ef ff ff       	call   800d2f <sys_page_unmap>
  801d46:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d49:	83 ec 08             	sub    $0x8,%esp
  801d4c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d4f:	6a 00                	push   $0x0
  801d51:	e8 d9 ef ff ff       	call   800d2f <sys_page_unmap>
  801d56:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801d59:	83 ec 08             	sub    $0x8,%esp
  801d5c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d5f:	6a 00                	push   $0x0
  801d61:	e8 c9 ef ff ff       	call   800d2f <sys_page_unmap>
  801d66:	83 c4 10             	add    $0x10,%esp
}
  801d69:	89 d8                	mov    %ebx,%eax
  801d6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d6e:	5b                   	pop    %ebx
  801d6f:	5e                   	pop    %esi
  801d70:	5d                   	pop    %ebp
  801d71:	c3                   	ret    

00801d72 <pipeisclosed>:
{
  801d72:	f3 0f 1e fb          	endbr32 
  801d76:	55                   	push   %ebp
  801d77:	89 e5                	mov    %esp,%ebp
  801d79:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d7f:	50                   	push   %eax
  801d80:	ff 75 08             	pushl  0x8(%ebp)
  801d83:	e8 f6 f4 ff ff       	call   80127e <fd_lookup>
  801d88:	83 c4 10             	add    $0x10,%esp
  801d8b:	85 c0                	test   %eax,%eax
  801d8d:	78 18                	js     801da7 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801d8f:	83 ec 0c             	sub    $0xc,%esp
  801d92:	ff 75 f4             	pushl  -0xc(%ebp)
  801d95:	e8 73 f4 ff ff       	call   80120d <fd2data>
  801d9a:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9f:	e8 1f fd ff ff       	call   801ac3 <_pipeisclosed>
  801da4:	83 c4 10             	add    $0x10,%esp
}
  801da7:	c9                   	leave  
  801da8:	c3                   	ret    

00801da9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801da9:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801dad:	b8 00 00 00 00       	mov    $0x0,%eax
  801db2:	c3                   	ret    

00801db3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801db3:	f3 0f 1e fb          	endbr32 
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dbd:	68 e2 27 80 00       	push   $0x8027e2
  801dc2:	ff 75 0c             	pushl  0xc(%ebp)
  801dc5:	e8 96 ea ff ff       	call   800860 <strcpy>
	return 0;
}
  801dca:	b8 00 00 00 00       	mov    $0x0,%eax
  801dcf:	c9                   	leave  
  801dd0:	c3                   	ret    

00801dd1 <devcons_write>:
{
  801dd1:	f3 0f 1e fb          	endbr32 
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	57                   	push   %edi
  801dd9:	56                   	push   %esi
  801dda:	53                   	push   %ebx
  801ddb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801de1:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801de6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801dec:	3b 75 10             	cmp    0x10(%ebp),%esi
  801def:	73 31                	jae    801e22 <devcons_write+0x51>
		m = n - tot;
  801df1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801df4:	29 f3                	sub    %esi,%ebx
  801df6:	83 fb 7f             	cmp    $0x7f,%ebx
  801df9:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801dfe:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e01:	83 ec 04             	sub    $0x4,%esp
  801e04:	53                   	push   %ebx
  801e05:	89 f0                	mov    %esi,%eax
  801e07:	03 45 0c             	add    0xc(%ebp),%eax
  801e0a:	50                   	push   %eax
  801e0b:	57                   	push   %edi
  801e0c:	e8 05 ec ff ff       	call   800a16 <memmove>
		sys_cputs(buf, m);
  801e11:	83 c4 08             	add    $0x8,%esp
  801e14:	53                   	push   %ebx
  801e15:	57                   	push   %edi
  801e16:	e8 b7 ed ff ff       	call   800bd2 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e1b:	01 de                	add    %ebx,%esi
  801e1d:	83 c4 10             	add    $0x10,%esp
  801e20:	eb ca                	jmp    801dec <devcons_write+0x1b>
}
  801e22:	89 f0                	mov    %esi,%eax
  801e24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e27:	5b                   	pop    %ebx
  801e28:	5e                   	pop    %esi
  801e29:	5f                   	pop    %edi
  801e2a:	5d                   	pop    %ebp
  801e2b:	c3                   	ret    

00801e2c <devcons_read>:
{
  801e2c:	f3 0f 1e fb          	endbr32 
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
  801e33:	83 ec 08             	sub    $0x8,%esp
  801e36:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e3b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e3f:	74 21                	je     801e62 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801e41:	e8 ae ed ff ff       	call   800bf4 <sys_cgetc>
  801e46:	85 c0                	test   %eax,%eax
  801e48:	75 07                	jne    801e51 <devcons_read+0x25>
		sys_yield();
  801e4a:	e8 30 ee ff ff       	call   800c7f <sys_yield>
  801e4f:	eb f0                	jmp    801e41 <devcons_read+0x15>
	if (c < 0)
  801e51:	78 0f                	js     801e62 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801e53:	83 f8 04             	cmp    $0x4,%eax
  801e56:	74 0c                	je     801e64 <devcons_read+0x38>
	*(char*)vbuf = c;
  801e58:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e5b:	88 02                	mov    %al,(%edx)
	return 1;
  801e5d:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801e62:	c9                   	leave  
  801e63:	c3                   	ret    
		return 0;
  801e64:	b8 00 00 00 00       	mov    $0x0,%eax
  801e69:	eb f7                	jmp    801e62 <devcons_read+0x36>

00801e6b <cputchar>:
{
  801e6b:	f3 0f 1e fb          	endbr32 
  801e6f:	55                   	push   %ebp
  801e70:	89 e5                	mov    %esp,%ebp
  801e72:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e75:	8b 45 08             	mov    0x8(%ebp),%eax
  801e78:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e7b:	6a 01                	push   $0x1
  801e7d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e80:	50                   	push   %eax
  801e81:	e8 4c ed ff ff       	call   800bd2 <sys_cputs>
}
  801e86:	83 c4 10             	add    $0x10,%esp
  801e89:	c9                   	leave  
  801e8a:	c3                   	ret    

00801e8b <getchar>:
{
  801e8b:	f3 0f 1e fb          	endbr32 
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
  801e92:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801e95:	6a 01                	push   $0x1
  801e97:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e9a:	50                   	push   %eax
  801e9b:	6a 00                	push   $0x0
  801e9d:	e8 5f f6 ff ff       	call   801501 <read>
	if (r < 0)
  801ea2:	83 c4 10             	add    $0x10,%esp
  801ea5:	85 c0                	test   %eax,%eax
  801ea7:	78 06                	js     801eaf <getchar+0x24>
	if (r < 1)
  801ea9:	74 06                	je     801eb1 <getchar+0x26>
	return c;
  801eab:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801eaf:	c9                   	leave  
  801eb0:	c3                   	ret    
		return -E_EOF;
  801eb1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801eb6:	eb f7                	jmp    801eaf <getchar+0x24>

00801eb8 <iscons>:
{
  801eb8:	f3 0f 1e fb          	endbr32 
  801ebc:	55                   	push   %ebp
  801ebd:	89 e5                	mov    %esp,%ebp
  801ebf:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ec2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec5:	50                   	push   %eax
  801ec6:	ff 75 08             	pushl  0x8(%ebp)
  801ec9:	e8 b0 f3 ff ff       	call   80127e <fd_lookup>
  801ece:	83 c4 10             	add    $0x10,%esp
  801ed1:	85 c0                	test   %eax,%eax
  801ed3:	78 11                	js     801ee6 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801ed5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ede:	39 10                	cmp    %edx,(%eax)
  801ee0:	0f 94 c0             	sete   %al
  801ee3:	0f b6 c0             	movzbl %al,%eax
}
  801ee6:	c9                   	leave  
  801ee7:	c3                   	ret    

00801ee8 <opencons>:
{
  801ee8:	f3 0f 1e fb          	endbr32 
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801ef2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef5:	50                   	push   %eax
  801ef6:	e8 2d f3 ff ff       	call   801228 <fd_alloc>
  801efb:	83 c4 10             	add    $0x10,%esp
  801efe:	85 c0                	test   %eax,%eax
  801f00:	78 3a                	js     801f3c <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f02:	83 ec 04             	sub    $0x4,%esp
  801f05:	68 07 04 00 00       	push   $0x407
  801f0a:	ff 75 f4             	pushl  -0xc(%ebp)
  801f0d:	6a 00                	push   $0x0
  801f0f:	e8 8e ed ff ff       	call   800ca2 <sys_page_alloc>
  801f14:	83 c4 10             	add    $0x10,%esp
  801f17:	85 c0                	test   %eax,%eax
  801f19:	78 21                	js     801f3c <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f24:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f29:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f30:	83 ec 0c             	sub    $0xc,%esp
  801f33:	50                   	push   %eax
  801f34:	e8 c0 f2 ff ff       	call   8011f9 <fd2num>
  801f39:	83 c4 10             	add    $0x10,%esp
}
  801f3c:	c9                   	leave  
  801f3d:	c3                   	ret    

00801f3e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f3e:	f3 0f 1e fb          	endbr32 
  801f42:	55                   	push   %ebp
  801f43:	89 e5                	mov    %esp,%ebp
  801f45:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f48:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f4f:	74 0a                	je     801f5b <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f51:	8b 45 08             	mov    0x8(%ebp),%eax
  801f54:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f59:	c9                   	leave  
  801f5a:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801f5b:	83 ec 0c             	sub    $0xc,%esp
  801f5e:	68 ee 27 80 00       	push   $0x8027ee
  801f63:	e8 ef e2 ff ff       	call   800257 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  801f68:	83 c4 0c             	add    $0xc,%esp
  801f6b:	6a 07                	push   $0x7
  801f6d:	68 00 f0 bf ee       	push   $0xeebff000
  801f72:	6a 00                	push   $0x0
  801f74:	e8 29 ed ff ff       	call   800ca2 <sys_page_alloc>
  801f79:	83 c4 10             	add    $0x10,%esp
  801f7c:	85 c0                	test   %eax,%eax
  801f7e:	78 2a                	js     801faa <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801f80:	83 ec 08             	sub    $0x8,%esp
  801f83:	68 be 1f 80 00       	push   $0x801fbe
  801f88:	6a 00                	push   $0x0
  801f8a:	e8 72 ee ff ff       	call   800e01 <sys_env_set_pgfault_upcall>
  801f8f:	83 c4 10             	add    $0x10,%esp
  801f92:	85 c0                	test   %eax,%eax
  801f94:	79 bb                	jns    801f51 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  801f96:	83 ec 04             	sub    $0x4,%esp
  801f99:	68 2c 28 80 00       	push   $0x80282c
  801f9e:	6a 25                	push   $0x25
  801fa0:	68 1b 28 80 00       	push   $0x80281b
  801fa5:	e8 c6 e1 ff ff       	call   800170 <_panic>
            panic("Allocation of UXSTACK failed!");
  801faa:	83 ec 04             	sub    $0x4,%esp
  801fad:	68 fd 27 80 00       	push   $0x8027fd
  801fb2:	6a 22                	push   $0x22
  801fb4:	68 1b 28 80 00       	push   $0x80281b
  801fb9:	e8 b2 e1 ff ff       	call   800170 <_panic>

00801fbe <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fbe:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fbf:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fc4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fc6:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  801fc9:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  801fcd:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  801fd1:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  801fd4:	83 c4 08             	add    $0x8,%esp
    popa
  801fd7:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  801fd8:	83 c4 04             	add    $0x4,%esp
    popf
  801fdb:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  801fdc:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  801fdf:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  801fe3:	c3                   	ret    

00801fe4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fe4:	f3 0f 1e fb          	endbr32 
  801fe8:	55                   	push   %ebp
  801fe9:	89 e5                	mov    %esp,%ebp
  801feb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fee:	89 c2                	mov    %eax,%edx
  801ff0:	c1 ea 16             	shr    $0x16,%edx
  801ff3:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801ffa:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fff:	f6 c1 01             	test   $0x1,%cl
  802002:	74 1c                	je     802020 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802004:	c1 e8 0c             	shr    $0xc,%eax
  802007:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80200e:	a8 01                	test   $0x1,%al
  802010:	74 0e                	je     802020 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802012:	c1 e8 0c             	shr    $0xc,%eax
  802015:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80201c:	ef 
  80201d:	0f b7 d2             	movzwl %dx,%edx
}
  802020:	89 d0                	mov    %edx,%eax
  802022:	5d                   	pop    %ebp
  802023:	c3                   	ret    
  802024:	66 90                	xchg   %ax,%ax
  802026:	66 90                	xchg   %ax,%ax
  802028:	66 90                	xchg   %ax,%ax
  80202a:	66 90                	xchg   %ax,%ax
  80202c:	66 90                	xchg   %ax,%ax
  80202e:	66 90                	xchg   %ax,%ax

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
