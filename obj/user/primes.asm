
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
  80004b:	e8 a4 10 00 00       	call   8010f4 <ipc_recv>
  800050:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  800052:	a1 04 40 80 00       	mov    0x804004,%eax
  800057:	8b 40 5c             	mov    0x5c(%eax),%eax
  80005a:	83 c4 0c             	add    $0xc,%esp
  80005d:	53                   	push   %ebx
  80005e:	50                   	push   %eax
  80005f:	68 60 22 80 00       	push   $0x802260
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
  80007f:	68 6c 22 80 00       	push   $0x80226c
  800084:	6a 1a                	push   $0x1a
  800086:	68 75 22 80 00       	push   $0x802275
  80008b:	e8 e0 00 00 00       	call   800170 <_panic>
		if (i % p)
			ipc_send(id, i, 0, 0);
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	51                   	push   %ecx
  800095:	57                   	push   %edi
  800096:	e8 b0 10 00 00       	call   80114b <ipc_send>
  80009b:	83 c4 10             	add    $0x10,%esp
		i = ipc_recv(&envid, 0, 0);
  80009e:	83 ec 04             	sub    $0x4,%esp
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	56                   	push   %esi
  8000a6:	e8 49 10 00 00       	call   8010f4 <ipc_recv>
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
  8000da:	e8 6c 10 00 00       	call   80114b <ipc_send>
	for (i = 2; ; i++)
  8000df:	83 c3 01             	add    $0x1,%ebx
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb ed                	jmp    8000d4 <umain+0x1b>
		panic("fork: %e", id);
  8000e7:	50                   	push   %eax
  8000e8:	68 6c 22 80 00       	push   $0x80226c
  8000ed:	6a 2d                	push   $0x2d
  8000ef:	68 75 22 80 00       	push   $0x802275
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
  80015c:	e8 7c 12 00 00       	call   8013dd <close_all>
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
  800192:	68 90 22 80 00       	push   $0x802290
  800197:	e8 bb 00 00 00       	call   800257 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80019c:	83 c4 18             	add    $0x18,%esp
  80019f:	53                   	push   %ebx
  8001a0:	ff 75 10             	pushl  0x10(%ebp)
  8001a3:	e8 5a 00 00 00       	call   800202 <vcprintf>
	cprintf("\n");
  8001a8:	c7 04 24 d9 27 80 00 	movl   $0x8027d9,(%esp)
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
  8002bd:	e8 2e 1d 00 00       	call   801ff0 <__udivdi3>
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
  8002fb:	e8 00 1e 00 00       	call   802100 <__umoddi3>
  800300:	83 c4 14             	add    $0x14,%esp
  800303:	0f be 80 b3 22 80 00 	movsbl 0x8022b3(%eax),%eax
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
  8003aa:	3e ff 24 85 00 24 80 	notrack jmp *0x802400(,%eax,4)
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
  800477:	8b 14 85 60 25 80 00 	mov    0x802560(,%eax,4),%edx
  80047e:	85 d2                	test   %edx,%edx
  800480:	74 18                	je     80049a <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800482:	52                   	push   %edx
  800483:	68 92 27 80 00       	push   $0x802792
  800488:	53                   	push   %ebx
  800489:	56                   	push   %esi
  80048a:	e8 aa fe ff ff       	call   800339 <printfmt>
  80048f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800492:	89 7d 14             	mov    %edi,0x14(%ebp)
  800495:	e9 22 02 00 00       	jmp    8006bc <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  80049a:	50                   	push   %eax
  80049b:	68 cb 22 80 00       	push   $0x8022cb
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
  8004c2:	b8 c4 22 80 00       	mov    $0x8022c4,%eax
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
  800c4b:	68 bf 25 80 00       	push   $0x8025bf
  800c50:	6a 23                	push   $0x23
  800c52:	68 dc 25 80 00       	push   $0x8025dc
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
  800cd8:	68 bf 25 80 00       	push   $0x8025bf
  800cdd:	6a 23                	push   $0x23
  800cdf:	68 dc 25 80 00       	push   $0x8025dc
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
  800d1e:	68 bf 25 80 00       	push   $0x8025bf
  800d23:	6a 23                	push   $0x23
  800d25:	68 dc 25 80 00       	push   $0x8025dc
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
  800d64:	68 bf 25 80 00       	push   $0x8025bf
  800d69:	6a 23                	push   $0x23
  800d6b:	68 dc 25 80 00       	push   $0x8025dc
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
  800daa:	68 bf 25 80 00       	push   $0x8025bf
  800daf:	6a 23                	push   $0x23
  800db1:	68 dc 25 80 00       	push   $0x8025dc
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
  800df0:	68 bf 25 80 00       	push   $0x8025bf
  800df5:	6a 23                	push   $0x23
  800df7:	68 dc 25 80 00       	push   $0x8025dc
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
  800e36:	68 bf 25 80 00       	push   $0x8025bf
  800e3b:	6a 23                	push   $0x23
  800e3d:	68 dc 25 80 00       	push   $0x8025dc
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
  800ea2:	68 bf 25 80 00       	push   $0x8025bf
  800ea7:	6a 23                	push   $0x23
  800ea9:	68 dc 25 80 00       	push   $0x8025dc
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
  800f41:	68 ea 25 80 00       	push   $0x8025ea
  800f46:	6a 1e                	push   $0x1e
  800f48:	68 03 26 80 00       	push   $0x802603
  800f4d:	e8 1e f2 ff ff       	call   800170 <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800f52:	50                   	push   %eax
  800f53:	68 0e 26 80 00       	push   $0x80260e
  800f58:	6a 2a                	push   $0x2a
  800f5a:	68 03 26 80 00       	push   $0x802603
  800f5f:	e8 0c f2 ff ff       	call   800170 <_panic>
        panic("sys_page_map failed %e\n", r);
  800f64:	50                   	push   %eax
  800f65:	68 28 26 80 00       	push   $0x802628
  800f6a:	6a 2f                	push   $0x2f
  800f6c:	68 03 26 80 00       	push   $0x802603
  800f71:	e8 fa f1 ff ff       	call   800170 <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800f76:	50                   	push   %eax
  800f77:	68 40 26 80 00       	push   $0x802640
  800f7c:	6a 32                	push   $0x32
  800f7e:	68 03 26 80 00       	push   $0x802603
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
  800f9a:	e8 68 0f 00 00       	call   801f07 <set_pgfault_handler>
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
  800fbc:	75 4e                	jne    80100c <fork+0x84>
        envid_t my_envid = sys_getenvid();
  800fbe:	e8 99 fc ff ff       	call   800c5c <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800fc3:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fc8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fcb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fd0:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  800fd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fd8:	e9 f1 00 00 00       	jmp    8010ce <fork+0x146>
        panic("fork, sys_exofork %e", envid);
  800fdd:	50                   	push   %eax
  800fde:	68 5a 26 80 00       	push   $0x80265a
  800fe3:	6a 7b                	push   $0x7b
  800fe5:	68 03 26 80 00       	push   $0x802603
  800fea:	e8 81 f1 ff ff       	call   800170 <_panic>
        panic("sys_page_map others failed %e\n", r);
  800fef:	50                   	push   %eax
  800ff0:	68 a4 26 80 00       	push   $0x8026a4
  800ff5:	6a 51                	push   $0x51
  800ff7:	68 03 26 80 00       	push   $0x802603
  800ffc:	e8 6f f1 ff ff       	call   800170 <_panic>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  801001:	83 c3 01             	add    $0x1,%ebx
  801004:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  80100a:	74 7c                	je     801088 <fork+0x100>
  80100c:	89 de                	mov    %ebx,%esi
  80100e:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  801011:	89 f0                	mov    %esi,%eax
  801013:	c1 e8 16             	shr    $0x16,%eax
  801016:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80101d:	a8 01                	test   $0x1,%al
  80101f:	74 e0                	je     801001 <fork+0x79>
                    (uvpt[pn] & PTE_P) ) {
  801021:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  801028:	a8 01                	test   $0x1,%al
  80102a:	74 d5                	je     801001 <fork+0x79>
    pte_t pte = uvpt[pn];
  80102c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    if ( (pte & PTE_W) || (pte & PTE_COW) ) {
  801033:	25 02 08 00 00       	and    $0x802,%eax
        perm |= PTE_COW;
  801038:	83 f8 01             	cmp    $0x1,%eax
  80103b:	19 ff                	sbb    %edi,%edi
  80103d:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  801043:	81 c7 05 08 00 00    	add    $0x805,%edi
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  801049:	83 ec 0c             	sub    $0xc,%esp
  80104c:	57                   	push   %edi
  80104d:	56                   	push   %esi
  80104e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801051:	56                   	push   %esi
  801052:	6a 00                	push   $0x0
  801054:	e8 90 fc ff ff       	call   800ce9 <sys_page_map>
  801059:	83 c4 20             	add    $0x20,%esp
  80105c:	85 c0                	test   %eax,%eax
  80105e:	78 8f                	js     800fef <fork+0x67>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  801060:	83 ec 0c             	sub    $0xc,%esp
  801063:	57                   	push   %edi
  801064:	56                   	push   %esi
  801065:	6a 00                	push   $0x0
  801067:	56                   	push   %esi
  801068:	6a 00                	push   $0x0
  80106a:	e8 7a fc ff ff       	call   800ce9 <sys_page_map>
  80106f:	83 c4 20             	add    $0x20,%esp
  801072:	85 c0                	test   %eax,%eax
  801074:	79 8b                	jns    801001 <fork+0x79>
            panic("sys_page_map mine failed %e\n", r);
  801076:	50                   	push   %eax
  801077:	68 6f 26 80 00       	push   $0x80266f
  80107c:	6a 56                	push   $0x56
  80107e:	68 03 26 80 00       	push   $0x802603
  801083:	e8 e8 f0 ff ff       	call   800170 <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  801088:	83 ec 04             	sub    $0x4,%esp
  80108b:	6a 07                	push   $0x7
  80108d:	68 00 f0 bf ee       	push   $0xeebff000
  801092:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801095:	57                   	push   %edi
  801096:	e8 07 fc ff ff       	call   800ca2 <sys_page_alloc>
  80109b:	83 c4 10             	add    $0x10,%esp
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	78 2c                	js     8010ce <fork+0x146>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  8010a2:	a1 04 40 80 00       	mov    0x804004,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  8010a7:	8b 40 64             	mov    0x64(%eax),%eax
  8010aa:	83 ec 08             	sub    $0x8,%esp
  8010ad:	50                   	push   %eax
  8010ae:	57                   	push   %edi
  8010af:	e8 4d fd ff ff       	call   800e01 <sys_env_set_pgfault_upcall>
  8010b4:	83 c4 10             	add    $0x10,%esp
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	78 13                	js     8010ce <fork+0x146>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8010bb:	83 ec 08             	sub    $0x8,%esp
  8010be:	6a 02                	push   $0x2
  8010c0:	57                   	push   %edi
  8010c1:	e8 af fc ff ff       	call   800d75 <sys_env_set_status>
  8010c6:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  8010c9:	85 c0                	test   %eax,%eax
  8010cb:	0f 49 c7             	cmovns %edi,%eax
    }

}
  8010ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d1:	5b                   	pop    %ebx
  8010d2:	5e                   	pop    %esi
  8010d3:	5f                   	pop    %edi
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    

008010d6 <sfork>:

// Challenge!
int
sfork(void)
{
  8010d6:	f3 0f 1e fb          	endbr32 
  8010da:	55                   	push   %ebp
  8010db:	89 e5                	mov    %esp,%ebp
  8010dd:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010e0:	68 8c 26 80 00       	push   $0x80268c
  8010e5:	68 a5 00 00 00       	push   $0xa5
  8010ea:	68 03 26 80 00       	push   $0x802603
  8010ef:	e8 7c f0 ff ff       	call   800170 <_panic>

008010f4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010f4:	f3 0f 1e fb          	endbr32 
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	56                   	push   %esi
  8010fc:	53                   	push   %ebx
  8010fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801100:	8b 45 0c             	mov    0xc(%ebp),%eax
  801103:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801106:	85 c0                	test   %eax,%eax
  801108:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80110d:	0f 44 c2             	cmove  %edx,%eax
  801110:	83 ec 0c             	sub    $0xc,%esp
  801113:	50                   	push   %eax
  801114:	e8 55 fd ff ff       	call   800e6e <sys_ipc_recv>
  801119:	83 c4 10             	add    $0x10,%esp
  80111c:	85 c0                	test   %eax,%eax
  80111e:	78 24                	js     801144 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801120:	85 f6                	test   %esi,%esi
  801122:	74 0a                	je     80112e <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801124:	a1 04 40 80 00       	mov    0x804004,%eax
  801129:	8b 40 78             	mov    0x78(%eax),%eax
  80112c:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  80112e:	85 db                	test   %ebx,%ebx
  801130:	74 0a                	je     80113c <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801132:	a1 04 40 80 00       	mov    0x804004,%eax
  801137:	8b 40 74             	mov    0x74(%eax),%eax
  80113a:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  80113c:	a1 04 40 80 00       	mov    0x804004,%eax
  801141:	8b 40 70             	mov    0x70(%eax),%eax
}
  801144:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801147:	5b                   	pop    %ebx
  801148:	5e                   	pop    %esi
  801149:	5d                   	pop    %ebp
  80114a:	c3                   	ret    

0080114b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80114b:	f3 0f 1e fb          	endbr32 
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	57                   	push   %edi
  801153:	56                   	push   %esi
  801154:	53                   	push   %ebx
  801155:	83 ec 1c             	sub    $0x1c,%esp
  801158:	8b 45 10             	mov    0x10(%ebp),%eax
  80115b:	85 c0                	test   %eax,%eax
  80115d:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801162:	0f 45 d0             	cmovne %eax,%edx
  801165:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801167:	be 01 00 00 00       	mov    $0x1,%esi
  80116c:	eb 1f                	jmp    80118d <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  80116e:	e8 0c fb ff ff       	call   800c7f <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801173:	83 c3 01             	add    $0x1,%ebx
  801176:	39 de                	cmp    %ebx,%esi
  801178:	7f f4                	jg     80116e <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  80117a:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  80117c:	83 fe 11             	cmp    $0x11,%esi
  80117f:	b8 01 00 00 00       	mov    $0x1,%eax
  801184:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801187:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  80118b:	75 1c                	jne    8011a9 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  80118d:	ff 75 14             	pushl  0x14(%ebp)
  801190:	57                   	push   %edi
  801191:	ff 75 0c             	pushl  0xc(%ebp)
  801194:	ff 75 08             	pushl  0x8(%ebp)
  801197:	e8 ab fc ff ff       	call   800e47 <sys_ipc_try_send>
  80119c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  80119f:	83 c4 10             	add    $0x10,%esp
  8011a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a7:	eb cd                	jmp    801176 <ipc_send+0x2b>
}
  8011a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ac:	5b                   	pop    %ebx
  8011ad:	5e                   	pop    %esi
  8011ae:	5f                   	pop    %edi
  8011af:	5d                   	pop    %ebp
  8011b0:	c3                   	ret    

008011b1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011b1:	f3 0f 1e fb          	endbr32 
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011bb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011c0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011c3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011c9:	8b 52 50             	mov    0x50(%edx),%edx
  8011cc:	39 ca                	cmp    %ecx,%edx
  8011ce:	74 11                	je     8011e1 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8011d0:	83 c0 01             	add    $0x1,%eax
  8011d3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011d8:	75 e6                	jne    8011c0 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8011da:	b8 00 00 00 00       	mov    $0x0,%eax
  8011df:	eb 0b                	jmp    8011ec <ipc_find_env+0x3b>
			return envs[i].env_id;
  8011e1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011e9:	8b 40 48             	mov    0x48(%eax),%eax
}
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    

008011ee <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011ee:	f3 0f 1e fb          	endbr32 
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f8:	05 00 00 00 30       	add    $0x30000000,%eax
  8011fd:	c1 e8 0c             	shr    $0xc,%eax
}
  801200:	5d                   	pop    %ebp
  801201:	c3                   	ret    

00801202 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801202:	f3 0f 1e fb          	endbr32 
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801209:	8b 45 08             	mov    0x8(%ebp),%eax
  80120c:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801211:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801216:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80121b:	5d                   	pop    %ebp
  80121c:	c3                   	ret    

0080121d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80121d:	f3 0f 1e fb          	endbr32 
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801229:	89 c2                	mov    %eax,%edx
  80122b:	c1 ea 16             	shr    $0x16,%edx
  80122e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801235:	f6 c2 01             	test   $0x1,%dl
  801238:	74 2d                	je     801267 <fd_alloc+0x4a>
  80123a:	89 c2                	mov    %eax,%edx
  80123c:	c1 ea 0c             	shr    $0xc,%edx
  80123f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801246:	f6 c2 01             	test   $0x1,%dl
  801249:	74 1c                	je     801267 <fd_alloc+0x4a>
  80124b:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801250:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801255:	75 d2                	jne    801229 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801257:	8b 45 08             	mov    0x8(%ebp),%eax
  80125a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801260:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801265:	eb 0a                	jmp    801271 <fd_alloc+0x54>
			*fd_store = fd;
  801267:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80126c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    

00801273 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801273:	f3 0f 1e fb          	endbr32 
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80127d:	83 f8 1f             	cmp    $0x1f,%eax
  801280:	77 30                	ja     8012b2 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801282:	c1 e0 0c             	shl    $0xc,%eax
  801285:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80128a:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801290:	f6 c2 01             	test   $0x1,%dl
  801293:	74 24                	je     8012b9 <fd_lookup+0x46>
  801295:	89 c2                	mov    %eax,%edx
  801297:	c1 ea 0c             	shr    $0xc,%edx
  80129a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a1:	f6 c2 01             	test   $0x1,%dl
  8012a4:	74 1a                	je     8012c0 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a9:	89 02                	mov    %eax,(%edx)
	return 0;
  8012ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012b0:	5d                   	pop    %ebp
  8012b1:	c3                   	ret    
		return -E_INVAL;
  8012b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b7:	eb f7                	jmp    8012b0 <fd_lookup+0x3d>
		return -E_INVAL;
  8012b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012be:	eb f0                	jmp    8012b0 <fd_lookup+0x3d>
  8012c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c5:	eb e9                	jmp    8012b0 <fd_lookup+0x3d>

008012c7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012c7:	f3 0f 1e fb          	endbr32 
  8012cb:	55                   	push   %ebp
  8012cc:	89 e5                	mov    %esp,%ebp
  8012ce:	83 ec 08             	sub    $0x8,%esp
  8012d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d4:	ba 40 27 80 00       	mov    $0x802740,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012d9:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8012de:	39 08                	cmp    %ecx,(%eax)
  8012e0:	74 33                	je     801315 <dev_lookup+0x4e>
  8012e2:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8012e5:	8b 02                	mov    (%edx),%eax
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	75 f3                	jne    8012de <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012eb:	a1 04 40 80 00       	mov    0x804004,%eax
  8012f0:	8b 40 48             	mov    0x48(%eax),%eax
  8012f3:	83 ec 04             	sub    $0x4,%esp
  8012f6:	51                   	push   %ecx
  8012f7:	50                   	push   %eax
  8012f8:	68 c4 26 80 00       	push   $0x8026c4
  8012fd:	e8 55 ef ff ff       	call   800257 <cprintf>
	*dev = 0;
  801302:	8b 45 0c             	mov    0xc(%ebp),%eax
  801305:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80130b:	83 c4 10             	add    $0x10,%esp
  80130e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801313:	c9                   	leave  
  801314:	c3                   	ret    
			*dev = devtab[i];
  801315:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801318:	89 01                	mov    %eax,(%ecx)
			return 0;
  80131a:	b8 00 00 00 00       	mov    $0x0,%eax
  80131f:	eb f2                	jmp    801313 <dev_lookup+0x4c>

00801321 <fd_close>:
{
  801321:	f3 0f 1e fb          	endbr32 
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	57                   	push   %edi
  801329:	56                   	push   %esi
  80132a:	53                   	push   %ebx
  80132b:	83 ec 24             	sub    $0x24,%esp
  80132e:	8b 75 08             	mov    0x8(%ebp),%esi
  801331:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801334:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801337:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801338:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80133e:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801341:	50                   	push   %eax
  801342:	e8 2c ff ff ff       	call   801273 <fd_lookup>
  801347:	89 c3                	mov    %eax,%ebx
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	85 c0                	test   %eax,%eax
  80134e:	78 05                	js     801355 <fd_close+0x34>
	    || fd != fd2)
  801350:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801353:	74 16                	je     80136b <fd_close+0x4a>
		return (must_exist ? r : 0);
  801355:	89 f8                	mov    %edi,%eax
  801357:	84 c0                	test   %al,%al
  801359:	b8 00 00 00 00       	mov    $0x0,%eax
  80135e:	0f 44 d8             	cmove  %eax,%ebx
}
  801361:	89 d8                	mov    %ebx,%eax
  801363:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801366:	5b                   	pop    %ebx
  801367:	5e                   	pop    %esi
  801368:	5f                   	pop    %edi
  801369:	5d                   	pop    %ebp
  80136a:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80136b:	83 ec 08             	sub    $0x8,%esp
  80136e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801371:	50                   	push   %eax
  801372:	ff 36                	pushl  (%esi)
  801374:	e8 4e ff ff ff       	call   8012c7 <dev_lookup>
  801379:	89 c3                	mov    %eax,%ebx
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	85 c0                	test   %eax,%eax
  801380:	78 1a                	js     80139c <fd_close+0x7b>
		if (dev->dev_close)
  801382:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801385:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801388:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80138d:	85 c0                	test   %eax,%eax
  80138f:	74 0b                	je     80139c <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801391:	83 ec 0c             	sub    $0xc,%esp
  801394:	56                   	push   %esi
  801395:	ff d0                	call   *%eax
  801397:	89 c3                	mov    %eax,%ebx
  801399:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80139c:	83 ec 08             	sub    $0x8,%esp
  80139f:	56                   	push   %esi
  8013a0:	6a 00                	push   $0x0
  8013a2:	e8 88 f9 ff ff       	call   800d2f <sys_page_unmap>
	return r;
  8013a7:	83 c4 10             	add    $0x10,%esp
  8013aa:	eb b5                	jmp    801361 <fd_close+0x40>

008013ac <close>:

int
close(int fdnum)
{
  8013ac:	f3 0f 1e fb          	endbr32 
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b9:	50                   	push   %eax
  8013ba:	ff 75 08             	pushl  0x8(%ebp)
  8013bd:	e8 b1 fe ff ff       	call   801273 <fd_lookup>
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	79 02                	jns    8013cb <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8013c9:	c9                   	leave  
  8013ca:	c3                   	ret    
		return fd_close(fd, 1);
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	6a 01                	push   $0x1
  8013d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8013d3:	e8 49 ff ff ff       	call   801321 <fd_close>
  8013d8:	83 c4 10             	add    $0x10,%esp
  8013db:	eb ec                	jmp    8013c9 <close+0x1d>

008013dd <close_all>:

void
close_all(void)
{
  8013dd:	f3 0f 1e fb          	endbr32 
  8013e1:	55                   	push   %ebp
  8013e2:	89 e5                	mov    %esp,%ebp
  8013e4:	53                   	push   %ebx
  8013e5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013e8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013ed:	83 ec 0c             	sub    $0xc,%esp
  8013f0:	53                   	push   %ebx
  8013f1:	e8 b6 ff ff ff       	call   8013ac <close>
	for (i = 0; i < MAXFD; i++)
  8013f6:	83 c3 01             	add    $0x1,%ebx
  8013f9:	83 c4 10             	add    $0x10,%esp
  8013fc:	83 fb 20             	cmp    $0x20,%ebx
  8013ff:	75 ec                	jne    8013ed <close_all+0x10>
}
  801401:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801404:	c9                   	leave  
  801405:	c3                   	ret    

00801406 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801406:	f3 0f 1e fb          	endbr32 
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	57                   	push   %edi
  80140e:	56                   	push   %esi
  80140f:	53                   	push   %ebx
  801410:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801413:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801416:	50                   	push   %eax
  801417:	ff 75 08             	pushl  0x8(%ebp)
  80141a:	e8 54 fe ff ff       	call   801273 <fd_lookup>
  80141f:	89 c3                	mov    %eax,%ebx
  801421:	83 c4 10             	add    $0x10,%esp
  801424:	85 c0                	test   %eax,%eax
  801426:	0f 88 81 00 00 00    	js     8014ad <dup+0xa7>
		return r;
	close(newfdnum);
  80142c:	83 ec 0c             	sub    $0xc,%esp
  80142f:	ff 75 0c             	pushl  0xc(%ebp)
  801432:	e8 75 ff ff ff       	call   8013ac <close>

	newfd = INDEX2FD(newfdnum);
  801437:	8b 75 0c             	mov    0xc(%ebp),%esi
  80143a:	c1 e6 0c             	shl    $0xc,%esi
  80143d:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801443:	83 c4 04             	add    $0x4,%esp
  801446:	ff 75 e4             	pushl  -0x1c(%ebp)
  801449:	e8 b4 fd ff ff       	call   801202 <fd2data>
  80144e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801450:	89 34 24             	mov    %esi,(%esp)
  801453:	e8 aa fd ff ff       	call   801202 <fd2data>
  801458:	83 c4 10             	add    $0x10,%esp
  80145b:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80145d:	89 d8                	mov    %ebx,%eax
  80145f:	c1 e8 16             	shr    $0x16,%eax
  801462:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801469:	a8 01                	test   $0x1,%al
  80146b:	74 11                	je     80147e <dup+0x78>
  80146d:	89 d8                	mov    %ebx,%eax
  80146f:	c1 e8 0c             	shr    $0xc,%eax
  801472:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801479:	f6 c2 01             	test   $0x1,%dl
  80147c:	75 39                	jne    8014b7 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80147e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801481:	89 d0                	mov    %edx,%eax
  801483:	c1 e8 0c             	shr    $0xc,%eax
  801486:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80148d:	83 ec 0c             	sub    $0xc,%esp
  801490:	25 07 0e 00 00       	and    $0xe07,%eax
  801495:	50                   	push   %eax
  801496:	56                   	push   %esi
  801497:	6a 00                	push   $0x0
  801499:	52                   	push   %edx
  80149a:	6a 00                	push   $0x0
  80149c:	e8 48 f8 ff ff       	call   800ce9 <sys_page_map>
  8014a1:	89 c3                	mov    %eax,%ebx
  8014a3:	83 c4 20             	add    $0x20,%esp
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	78 31                	js     8014db <dup+0xd5>
		goto err;

	return newfdnum;
  8014aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014ad:	89 d8                	mov    %ebx,%eax
  8014af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b2:	5b                   	pop    %ebx
  8014b3:	5e                   	pop    %esi
  8014b4:	5f                   	pop    %edi
  8014b5:	5d                   	pop    %ebp
  8014b6:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014be:	83 ec 0c             	sub    $0xc,%esp
  8014c1:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c6:	50                   	push   %eax
  8014c7:	57                   	push   %edi
  8014c8:	6a 00                	push   $0x0
  8014ca:	53                   	push   %ebx
  8014cb:	6a 00                	push   $0x0
  8014cd:	e8 17 f8 ff ff       	call   800ce9 <sys_page_map>
  8014d2:	89 c3                	mov    %eax,%ebx
  8014d4:	83 c4 20             	add    $0x20,%esp
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	79 a3                	jns    80147e <dup+0x78>
	sys_page_unmap(0, newfd);
  8014db:	83 ec 08             	sub    $0x8,%esp
  8014de:	56                   	push   %esi
  8014df:	6a 00                	push   $0x0
  8014e1:	e8 49 f8 ff ff       	call   800d2f <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014e6:	83 c4 08             	add    $0x8,%esp
  8014e9:	57                   	push   %edi
  8014ea:	6a 00                	push   $0x0
  8014ec:	e8 3e f8 ff ff       	call   800d2f <sys_page_unmap>
	return r;
  8014f1:	83 c4 10             	add    $0x10,%esp
  8014f4:	eb b7                	jmp    8014ad <dup+0xa7>

008014f6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014f6:	f3 0f 1e fb          	endbr32 
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	53                   	push   %ebx
  8014fe:	83 ec 1c             	sub    $0x1c,%esp
  801501:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801504:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801507:	50                   	push   %eax
  801508:	53                   	push   %ebx
  801509:	e8 65 fd ff ff       	call   801273 <fd_lookup>
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	85 c0                	test   %eax,%eax
  801513:	78 3f                	js     801554 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801515:	83 ec 08             	sub    $0x8,%esp
  801518:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151b:	50                   	push   %eax
  80151c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151f:	ff 30                	pushl  (%eax)
  801521:	e8 a1 fd ff ff       	call   8012c7 <dev_lookup>
  801526:	83 c4 10             	add    $0x10,%esp
  801529:	85 c0                	test   %eax,%eax
  80152b:	78 27                	js     801554 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80152d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801530:	8b 42 08             	mov    0x8(%edx),%eax
  801533:	83 e0 03             	and    $0x3,%eax
  801536:	83 f8 01             	cmp    $0x1,%eax
  801539:	74 1e                	je     801559 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80153b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80153e:	8b 40 08             	mov    0x8(%eax),%eax
  801541:	85 c0                	test   %eax,%eax
  801543:	74 35                	je     80157a <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801545:	83 ec 04             	sub    $0x4,%esp
  801548:	ff 75 10             	pushl  0x10(%ebp)
  80154b:	ff 75 0c             	pushl  0xc(%ebp)
  80154e:	52                   	push   %edx
  80154f:	ff d0                	call   *%eax
  801551:	83 c4 10             	add    $0x10,%esp
}
  801554:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801557:	c9                   	leave  
  801558:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801559:	a1 04 40 80 00       	mov    0x804004,%eax
  80155e:	8b 40 48             	mov    0x48(%eax),%eax
  801561:	83 ec 04             	sub    $0x4,%esp
  801564:	53                   	push   %ebx
  801565:	50                   	push   %eax
  801566:	68 05 27 80 00       	push   $0x802705
  80156b:	e8 e7 ec ff ff       	call   800257 <cprintf>
		return -E_INVAL;
  801570:	83 c4 10             	add    $0x10,%esp
  801573:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801578:	eb da                	jmp    801554 <read+0x5e>
		return -E_NOT_SUPP;
  80157a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80157f:	eb d3                	jmp    801554 <read+0x5e>

00801581 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801581:	f3 0f 1e fb          	endbr32 
  801585:	55                   	push   %ebp
  801586:	89 e5                	mov    %esp,%ebp
  801588:	57                   	push   %edi
  801589:	56                   	push   %esi
  80158a:	53                   	push   %ebx
  80158b:	83 ec 0c             	sub    $0xc,%esp
  80158e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801591:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801594:	bb 00 00 00 00       	mov    $0x0,%ebx
  801599:	eb 02                	jmp    80159d <readn+0x1c>
  80159b:	01 c3                	add    %eax,%ebx
  80159d:	39 f3                	cmp    %esi,%ebx
  80159f:	73 21                	jae    8015c2 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015a1:	83 ec 04             	sub    $0x4,%esp
  8015a4:	89 f0                	mov    %esi,%eax
  8015a6:	29 d8                	sub    %ebx,%eax
  8015a8:	50                   	push   %eax
  8015a9:	89 d8                	mov    %ebx,%eax
  8015ab:	03 45 0c             	add    0xc(%ebp),%eax
  8015ae:	50                   	push   %eax
  8015af:	57                   	push   %edi
  8015b0:	e8 41 ff ff ff       	call   8014f6 <read>
		if (m < 0)
  8015b5:	83 c4 10             	add    $0x10,%esp
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	78 04                	js     8015c0 <readn+0x3f>
			return m;
		if (m == 0)
  8015bc:	75 dd                	jne    80159b <readn+0x1a>
  8015be:	eb 02                	jmp    8015c2 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015c0:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8015c2:	89 d8                	mov    %ebx,%eax
  8015c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c7:	5b                   	pop    %ebx
  8015c8:	5e                   	pop    %esi
  8015c9:	5f                   	pop    %edi
  8015ca:	5d                   	pop    %ebp
  8015cb:	c3                   	ret    

008015cc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015cc:	f3 0f 1e fb          	endbr32 
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	53                   	push   %ebx
  8015d4:	83 ec 1c             	sub    $0x1c,%esp
  8015d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015dd:	50                   	push   %eax
  8015de:	53                   	push   %ebx
  8015df:	e8 8f fc ff ff       	call   801273 <fd_lookup>
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	78 3a                	js     801625 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015eb:	83 ec 08             	sub    $0x8,%esp
  8015ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f1:	50                   	push   %eax
  8015f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f5:	ff 30                	pushl  (%eax)
  8015f7:	e8 cb fc ff ff       	call   8012c7 <dev_lookup>
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	85 c0                	test   %eax,%eax
  801601:	78 22                	js     801625 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801603:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801606:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80160a:	74 1e                	je     80162a <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80160c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80160f:	8b 52 0c             	mov    0xc(%edx),%edx
  801612:	85 d2                	test   %edx,%edx
  801614:	74 35                	je     80164b <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801616:	83 ec 04             	sub    $0x4,%esp
  801619:	ff 75 10             	pushl  0x10(%ebp)
  80161c:	ff 75 0c             	pushl  0xc(%ebp)
  80161f:	50                   	push   %eax
  801620:	ff d2                	call   *%edx
  801622:	83 c4 10             	add    $0x10,%esp
}
  801625:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801628:	c9                   	leave  
  801629:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80162a:	a1 04 40 80 00       	mov    0x804004,%eax
  80162f:	8b 40 48             	mov    0x48(%eax),%eax
  801632:	83 ec 04             	sub    $0x4,%esp
  801635:	53                   	push   %ebx
  801636:	50                   	push   %eax
  801637:	68 21 27 80 00       	push   $0x802721
  80163c:	e8 16 ec ff ff       	call   800257 <cprintf>
		return -E_INVAL;
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801649:	eb da                	jmp    801625 <write+0x59>
		return -E_NOT_SUPP;
  80164b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801650:	eb d3                	jmp    801625 <write+0x59>

00801652 <seek>:

int
seek(int fdnum, off_t offset)
{
  801652:	f3 0f 1e fb          	endbr32 
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80165c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165f:	50                   	push   %eax
  801660:	ff 75 08             	pushl  0x8(%ebp)
  801663:	e8 0b fc ff ff       	call   801273 <fd_lookup>
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	85 c0                	test   %eax,%eax
  80166d:	78 0e                	js     80167d <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80166f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801672:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801675:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801678:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80167d:	c9                   	leave  
  80167e:	c3                   	ret    

0080167f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80167f:	f3 0f 1e fb          	endbr32 
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	53                   	push   %ebx
  801687:	83 ec 1c             	sub    $0x1c,%esp
  80168a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801690:	50                   	push   %eax
  801691:	53                   	push   %ebx
  801692:	e8 dc fb ff ff       	call   801273 <fd_lookup>
  801697:	83 c4 10             	add    $0x10,%esp
  80169a:	85 c0                	test   %eax,%eax
  80169c:	78 37                	js     8016d5 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169e:	83 ec 08             	sub    $0x8,%esp
  8016a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a4:	50                   	push   %eax
  8016a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a8:	ff 30                	pushl  (%eax)
  8016aa:	e8 18 fc ff ff       	call   8012c7 <dev_lookup>
  8016af:	83 c4 10             	add    $0x10,%esp
  8016b2:	85 c0                	test   %eax,%eax
  8016b4:	78 1f                	js     8016d5 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016bd:	74 1b                	je     8016da <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8016bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c2:	8b 52 18             	mov    0x18(%edx),%edx
  8016c5:	85 d2                	test   %edx,%edx
  8016c7:	74 32                	je     8016fb <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016c9:	83 ec 08             	sub    $0x8,%esp
  8016cc:	ff 75 0c             	pushl  0xc(%ebp)
  8016cf:	50                   	push   %eax
  8016d0:	ff d2                	call   *%edx
  8016d2:	83 c4 10             	add    $0x10,%esp
}
  8016d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d8:	c9                   	leave  
  8016d9:	c3                   	ret    
			thisenv->env_id, fdnum);
  8016da:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016df:	8b 40 48             	mov    0x48(%eax),%eax
  8016e2:	83 ec 04             	sub    $0x4,%esp
  8016e5:	53                   	push   %ebx
  8016e6:	50                   	push   %eax
  8016e7:	68 e4 26 80 00       	push   $0x8026e4
  8016ec:	e8 66 eb ff ff       	call   800257 <cprintf>
		return -E_INVAL;
  8016f1:	83 c4 10             	add    $0x10,%esp
  8016f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016f9:	eb da                	jmp    8016d5 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8016fb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801700:	eb d3                	jmp    8016d5 <ftruncate+0x56>

00801702 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801702:	f3 0f 1e fb          	endbr32 
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	53                   	push   %ebx
  80170a:	83 ec 1c             	sub    $0x1c,%esp
  80170d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801710:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801713:	50                   	push   %eax
  801714:	ff 75 08             	pushl  0x8(%ebp)
  801717:	e8 57 fb ff ff       	call   801273 <fd_lookup>
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	85 c0                	test   %eax,%eax
  801721:	78 4b                	js     80176e <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801723:	83 ec 08             	sub    $0x8,%esp
  801726:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801729:	50                   	push   %eax
  80172a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172d:	ff 30                	pushl  (%eax)
  80172f:	e8 93 fb ff ff       	call   8012c7 <dev_lookup>
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	85 c0                	test   %eax,%eax
  801739:	78 33                	js     80176e <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80173b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80173e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801742:	74 2f                	je     801773 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801744:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801747:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80174e:	00 00 00 
	stat->st_isdir = 0;
  801751:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801758:	00 00 00 
	stat->st_dev = dev;
  80175b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801761:	83 ec 08             	sub    $0x8,%esp
  801764:	53                   	push   %ebx
  801765:	ff 75 f0             	pushl  -0x10(%ebp)
  801768:	ff 50 14             	call   *0x14(%eax)
  80176b:	83 c4 10             	add    $0x10,%esp
}
  80176e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801771:	c9                   	leave  
  801772:	c3                   	ret    
		return -E_NOT_SUPP;
  801773:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801778:	eb f4                	jmp    80176e <fstat+0x6c>

0080177a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80177a:	f3 0f 1e fb          	endbr32 
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	56                   	push   %esi
  801782:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801783:	83 ec 08             	sub    $0x8,%esp
  801786:	6a 00                	push   $0x0
  801788:	ff 75 08             	pushl  0x8(%ebp)
  80178b:	e8 cf 01 00 00       	call   80195f <open>
  801790:	89 c3                	mov    %eax,%ebx
  801792:	83 c4 10             	add    $0x10,%esp
  801795:	85 c0                	test   %eax,%eax
  801797:	78 1b                	js     8017b4 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801799:	83 ec 08             	sub    $0x8,%esp
  80179c:	ff 75 0c             	pushl  0xc(%ebp)
  80179f:	50                   	push   %eax
  8017a0:	e8 5d ff ff ff       	call   801702 <fstat>
  8017a5:	89 c6                	mov    %eax,%esi
	close(fd);
  8017a7:	89 1c 24             	mov    %ebx,(%esp)
  8017aa:	e8 fd fb ff ff       	call   8013ac <close>
	return r;
  8017af:	83 c4 10             	add    $0x10,%esp
  8017b2:	89 f3                	mov    %esi,%ebx
}
  8017b4:	89 d8                	mov    %ebx,%eax
  8017b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b9:	5b                   	pop    %ebx
  8017ba:	5e                   	pop    %esi
  8017bb:	5d                   	pop    %ebp
  8017bc:	c3                   	ret    

008017bd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	56                   	push   %esi
  8017c1:	53                   	push   %ebx
  8017c2:	89 c6                	mov    %eax,%esi
  8017c4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017c6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017cd:	74 27                	je     8017f6 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017cf:	6a 07                	push   $0x7
  8017d1:	68 00 50 80 00       	push   $0x805000
  8017d6:	56                   	push   %esi
  8017d7:	ff 35 00 40 80 00    	pushl  0x804000
  8017dd:	e8 69 f9 ff ff       	call   80114b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017e2:	83 c4 0c             	add    $0xc,%esp
  8017e5:	6a 00                	push   $0x0
  8017e7:	53                   	push   %ebx
  8017e8:	6a 00                	push   $0x0
  8017ea:	e8 05 f9 ff ff       	call   8010f4 <ipc_recv>
}
  8017ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f2:	5b                   	pop    %ebx
  8017f3:	5e                   	pop    %esi
  8017f4:	5d                   	pop    %ebp
  8017f5:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017f6:	83 ec 0c             	sub    $0xc,%esp
  8017f9:	6a 01                	push   $0x1
  8017fb:	e8 b1 f9 ff ff       	call   8011b1 <ipc_find_env>
  801800:	a3 00 40 80 00       	mov    %eax,0x804000
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	eb c5                	jmp    8017cf <fsipc+0x12>

0080180a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80180a:	f3 0f 1e fb          	endbr32 
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801814:	8b 45 08             	mov    0x8(%ebp),%eax
  801817:	8b 40 0c             	mov    0xc(%eax),%eax
  80181a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80181f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801822:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801827:	ba 00 00 00 00       	mov    $0x0,%edx
  80182c:	b8 02 00 00 00       	mov    $0x2,%eax
  801831:	e8 87 ff ff ff       	call   8017bd <fsipc>
}
  801836:	c9                   	leave  
  801837:	c3                   	ret    

00801838 <devfile_flush>:
{
  801838:	f3 0f 1e fb          	endbr32 
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801842:	8b 45 08             	mov    0x8(%ebp),%eax
  801845:	8b 40 0c             	mov    0xc(%eax),%eax
  801848:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80184d:	ba 00 00 00 00       	mov    $0x0,%edx
  801852:	b8 06 00 00 00       	mov    $0x6,%eax
  801857:	e8 61 ff ff ff       	call   8017bd <fsipc>
}
  80185c:	c9                   	leave  
  80185d:	c3                   	ret    

0080185e <devfile_stat>:
{
  80185e:	f3 0f 1e fb          	endbr32 
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	53                   	push   %ebx
  801866:	83 ec 04             	sub    $0x4,%esp
  801869:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80186c:	8b 45 08             	mov    0x8(%ebp),%eax
  80186f:	8b 40 0c             	mov    0xc(%eax),%eax
  801872:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801877:	ba 00 00 00 00       	mov    $0x0,%edx
  80187c:	b8 05 00 00 00       	mov    $0x5,%eax
  801881:	e8 37 ff ff ff       	call   8017bd <fsipc>
  801886:	85 c0                	test   %eax,%eax
  801888:	78 2c                	js     8018b6 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80188a:	83 ec 08             	sub    $0x8,%esp
  80188d:	68 00 50 80 00       	push   $0x805000
  801892:	53                   	push   %ebx
  801893:	e8 c8 ef ff ff       	call   800860 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801898:	a1 80 50 80 00       	mov    0x805080,%eax
  80189d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018a3:	a1 84 50 80 00       	mov    0x805084,%eax
  8018a8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018ae:	83 c4 10             	add    $0x10,%esp
  8018b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b9:	c9                   	leave  
  8018ba:	c3                   	ret    

008018bb <devfile_write>:
{
  8018bb:	f3 0f 1e fb          	endbr32 
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	83 ec 0c             	sub    $0xc,%esp
	panic("devfile_write not implemented");
  8018c5:	68 50 27 80 00       	push   $0x802750
  8018ca:	68 90 00 00 00       	push   $0x90
  8018cf:	68 6e 27 80 00       	push   $0x80276e
  8018d4:	e8 97 e8 ff ff       	call   800170 <_panic>

008018d9 <devfile_read>:
{
  8018d9:	f3 0f 1e fb          	endbr32 
  8018dd:	55                   	push   %ebp
  8018de:	89 e5                	mov    %esp,%ebp
  8018e0:	56                   	push   %esi
  8018e1:	53                   	push   %ebx
  8018e2:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018eb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018f0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fb:	b8 03 00 00 00       	mov    $0x3,%eax
  801900:	e8 b8 fe ff ff       	call   8017bd <fsipc>
  801905:	89 c3                	mov    %eax,%ebx
  801907:	85 c0                	test   %eax,%eax
  801909:	78 1f                	js     80192a <devfile_read+0x51>
	assert(r <= n);
  80190b:	39 f0                	cmp    %esi,%eax
  80190d:	77 24                	ja     801933 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  80190f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801914:	7f 33                	jg     801949 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801916:	83 ec 04             	sub    $0x4,%esp
  801919:	50                   	push   %eax
  80191a:	68 00 50 80 00       	push   $0x805000
  80191f:	ff 75 0c             	pushl  0xc(%ebp)
  801922:	e8 ef f0 ff ff       	call   800a16 <memmove>
	return r;
  801927:	83 c4 10             	add    $0x10,%esp
}
  80192a:	89 d8                	mov    %ebx,%eax
  80192c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192f:	5b                   	pop    %ebx
  801930:	5e                   	pop    %esi
  801931:	5d                   	pop    %ebp
  801932:	c3                   	ret    
	assert(r <= n);
  801933:	68 79 27 80 00       	push   $0x802779
  801938:	68 80 27 80 00       	push   $0x802780
  80193d:	6a 7c                	push   $0x7c
  80193f:	68 6e 27 80 00       	push   $0x80276e
  801944:	e8 27 e8 ff ff       	call   800170 <_panic>
	assert(r <= PGSIZE);
  801949:	68 95 27 80 00       	push   $0x802795
  80194e:	68 80 27 80 00       	push   $0x802780
  801953:	6a 7d                	push   $0x7d
  801955:	68 6e 27 80 00       	push   $0x80276e
  80195a:	e8 11 e8 ff ff       	call   800170 <_panic>

0080195f <open>:
{
  80195f:	f3 0f 1e fb          	endbr32 
  801963:	55                   	push   %ebp
  801964:	89 e5                	mov    %esp,%ebp
  801966:	56                   	push   %esi
  801967:	53                   	push   %ebx
  801968:	83 ec 1c             	sub    $0x1c,%esp
  80196b:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80196e:	56                   	push   %esi
  80196f:	e8 a9 ee ff ff       	call   80081d <strlen>
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80197c:	7f 6c                	jg     8019ea <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80197e:	83 ec 0c             	sub    $0xc,%esp
  801981:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801984:	50                   	push   %eax
  801985:	e8 93 f8 ff ff       	call   80121d <fd_alloc>
  80198a:	89 c3                	mov    %eax,%ebx
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	85 c0                	test   %eax,%eax
  801991:	78 3c                	js     8019cf <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801993:	83 ec 08             	sub    $0x8,%esp
  801996:	56                   	push   %esi
  801997:	68 00 50 80 00       	push   $0x805000
  80199c:	e8 bf ee ff ff       	call   800860 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a4:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8019b1:	e8 07 fe ff ff       	call   8017bd <fsipc>
  8019b6:	89 c3                	mov    %eax,%ebx
  8019b8:	83 c4 10             	add    $0x10,%esp
  8019bb:	85 c0                	test   %eax,%eax
  8019bd:	78 19                	js     8019d8 <open+0x79>
	return fd2num(fd);
  8019bf:	83 ec 0c             	sub    $0xc,%esp
  8019c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c5:	e8 24 f8 ff ff       	call   8011ee <fd2num>
  8019ca:	89 c3                	mov    %eax,%ebx
  8019cc:	83 c4 10             	add    $0x10,%esp
}
  8019cf:	89 d8                	mov    %ebx,%eax
  8019d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d4:	5b                   	pop    %ebx
  8019d5:	5e                   	pop    %esi
  8019d6:	5d                   	pop    %ebp
  8019d7:	c3                   	ret    
		fd_close(fd, 0);
  8019d8:	83 ec 08             	sub    $0x8,%esp
  8019db:	6a 00                	push   $0x0
  8019dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e0:	e8 3c f9 ff ff       	call   801321 <fd_close>
		return r;
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	eb e5                	jmp    8019cf <open+0x70>
		return -E_BAD_PATH;
  8019ea:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019ef:	eb de                	jmp    8019cf <open+0x70>

008019f1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019f1:	f3 0f 1e fb          	endbr32 
  8019f5:	55                   	push   %ebp
  8019f6:	89 e5                	mov    %esp,%ebp
  8019f8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801a00:	b8 08 00 00 00       	mov    $0x8,%eax
  801a05:	e8 b3 fd ff ff       	call   8017bd <fsipc>
}
  801a0a:	c9                   	leave  
  801a0b:	c3                   	ret    

00801a0c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a0c:	f3 0f 1e fb          	endbr32 
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	56                   	push   %esi
  801a14:	53                   	push   %ebx
  801a15:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a18:	83 ec 0c             	sub    $0xc,%esp
  801a1b:	ff 75 08             	pushl  0x8(%ebp)
  801a1e:	e8 df f7 ff ff       	call   801202 <fd2data>
  801a23:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a25:	83 c4 08             	add    $0x8,%esp
  801a28:	68 a1 27 80 00       	push   $0x8027a1
  801a2d:	53                   	push   %ebx
  801a2e:	e8 2d ee ff ff       	call   800860 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a33:	8b 46 04             	mov    0x4(%esi),%eax
  801a36:	2b 06                	sub    (%esi),%eax
  801a38:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a3e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a45:	00 00 00 
	stat->st_dev = &devpipe;
  801a48:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a4f:	30 80 00 
	return 0;
}
  801a52:	b8 00 00 00 00       	mov    $0x0,%eax
  801a57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a5a:	5b                   	pop    %ebx
  801a5b:	5e                   	pop    %esi
  801a5c:	5d                   	pop    %ebp
  801a5d:	c3                   	ret    

00801a5e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a5e:	f3 0f 1e fb          	endbr32 
  801a62:	55                   	push   %ebp
  801a63:	89 e5                	mov    %esp,%ebp
  801a65:	53                   	push   %ebx
  801a66:	83 ec 0c             	sub    $0xc,%esp
  801a69:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a6c:	53                   	push   %ebx
  801a6d:	6a 00                	push   $0x0
  801a6f:	e8 bb f2 ff ff       	call   800d2f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a74:	89 1c 24             	mov    %ebx,(%esp)
  801a77:	e8 86 f7 ff ff       	call   801202 <fd2data>
  801a7c:	83 c4 08             	add    $0x8,%esp
  801a7f:	50                   	push   %eax
  801a80:	6a 00                	push   $0x0
  801a82:	e8 a8 f2 ff ff       	call   800d2f <sys_page_unmap>
}
  801a87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a8a:	c9                   	leave  
  801a8b:	c3                   	ret    

00801a8c <_pipeisclosed>:
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	57                   	push   %edi
  801a90:	56                   	push   %esi
  801a91:	53                   	push   %ebx
  801a92:	83 ec 1c             	sub    $0x1c,%esp
  801a95:	89 c7                	mov    %eax,%edi
  801a97:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a99:	a1 04 40 80 00       	mov    0x804004,%eax
  801a9e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801aa1:	83 ec 0c             	sub    $0xc,%esp
  801aa4:	57                   	push   %edi
  801aa5:	e8 03 05 00 00       	call   801fad <pageref>
  801aaa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801aad:	89 34 24             	mov    %esi,(%esp)
  801ab0:	e8 f8 04 00 00       	call   801fad <pageref>
		nn = thisenv->env_runs;
  801ab5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801abb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801abe:	83 c4 10             	add    $0x10,%esp
  801ac1:	39 cb                	cmp    %ecx,%ebx
  801ac3:	74 1b                	je     801ae0 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801ac5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ac8:	75 cf                	jne    801a99 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aca:	8b 42 58             	mov    0x58(%edx),%eax
  801acd:	6a 01                	push   $0x1
  801acf:	50                   	push   %eax
  801ad0:	53                   	push   %ebx
  801ad1:	68 a8 27 80 00       	push   $0x8027a8
  801ad6:	e8 7c e7 ff ff       	call   800257 <cprintf>
  801adb:	83 c4 10             	add    $0x10,%esp
  801ade:	eb b9                	jmp    801a99 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801ae0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ae3:	0f 94 c0             	sete   %al
  801ae6:	0f b6 c0             	movzbl %al,%eax
}
  801ae9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aec:	5b                   	pop    %ebx
  801aed:	5e                   	pop    %esi
  801aee:	5f                   	pop    %edi
  801aef:	5d                   	pop    %ebp
  801af0:	c3                   	ret    

00801af1 <devpipe_write>:
{
  801af1:	f3 0f 1e fb          	endbr32 
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	57                   	push   %edi
  801af9:	56                   	push   %esi
  801afa:	53                   	push   %ebx
  801afb:	83 ec 28             	sub    $0x28,%esp
  801afe:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b01:	56                   	push   %esi
  801b02:	e8 fb f6 ff ff       	call   801202 <fd2data>
  801b07:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b09:	83 c4 10             	add    $0x10,%esp
  801b0c:	bf 00 00 00 00       	mov    $0x0,%edi
  801b11:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b14:	74 4f                	je     801b65 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b16:	8b 43 04             	mov    0x4(%ebx),%eax
  801b19:	8b 0b                	mov    (%ebx),%ecx
  801b1b:	8d 51 20             	lea    0x20(%ecx),%edx
  801b1e:	39 d0                	cmp    %edx,%eax
  801b20:	72 14                	jb     801b36 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801b22:	89 da                	mov    %ebx,%edx
  801b24:	89 f0                	mov    %esi,%eax
  801b26:	e8 61 ff ff ff       	call   801a8c <_pipeisclosed>
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	75 3b                	jne    801b6a <devpipe_write+0x79>
			sys_yield();
  801b2f:	e8 4b f1 ff ff       	call   800c7f <sys_yield>
  801b34:	eb e0                	jmp    801b16 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b39:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b3d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b40:	89 c2                	mov    %eax,%edx
  801b42:	c1 fa 1f             	sar    $0x1f,%edx
  801b45:	89 d1                	mov    %edx,%ecx
  801b47:	c1 e9 1b             	shr    $0x1b,%ecx
  801b4a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b4d:	83 e2 1f             	and    $0x1f,%edx
  801b50:	29 ca                	sub    %ecx,%edx
  801b52:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b56:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b5a:	83 c0 01             	add    $0x1,%eax
  801b5d:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b60:	83 c7 01             	add    $0x1,%edi
  801b63:	eb ac                	jmp    801b11 <devpipe_write+0x20>
	return i;
  801b65:	8b 45 10             	mov    0x10(%ebp),%eax
  801b68:	eb 05                	jmp    801b6f <devpipe_write+0x7e>
				return 0;
  801b6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b72:	5b                   	pop    %ebx
  801b73:	5e                   	pop    %esi
  801b74:	5f                   	pop    %edi
  801b75:	5d                   	pop    %ebp
  801b76:	c3                   	ret    

00801b77 <devpipe_read>:
{
  801b77:	f3 0f 1e fb          	endbr32 
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	57                   	push   %edi
  801b7f:	56                   	push   %esi
  801b80:	53                   	push   %ebx
  801b81:	83 ec 18             	sub    $0x18,%esp
  801b84:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b87:	57                   	push   %edi
  801b88:	e8 75 f6 ff ff       	call   801202 <fd2data>
  801b8d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	be 00 00 00 00       	mov    $0x0,%esi
  801b97:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b9a:	75 14                	jne    801bb0 <devpipe_read+0x39>
	return i;
  801b9c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b9f:	eb 02                	jmp    801ba3 <devpipe_read+0x2c>
				return i;
  801ba1:	89 f0                	mov    %esi,%eax
}
  801ba3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba6:	5b                   	pop    %ebx
  801ba7:	5e                   	pop    %esi
  801ba8:	5f                   	pop    %edi
  801ba9:	5d                   	pop    %ebp
  801baa:	c3                   	ret    
			sys_yield();
  801bab:	e8 cf f0 ff ff       	call   800c7f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801bb0:	8b 03                	mov    (%ebx),%eax
  801bb2:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bb5:	75 18                	jne    801bcf <devpipe_read+0x58>
			if (i > 0)
  801bb7:	85 f6                	test   %esi,%esi
  801bb9:	75 e6                	jne    801ba1 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801bbb:	89 da                	mov    %ebx,%edx
  801bbd:	89 f8                	mov    %edi,%eax
  801bbf:	e8 c8 fe ff ff       	call   801a8c <_pipeisclosed>
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	74 e3                	je     801bab <devpipe_read+0x34>
				return 0;
  801bc8:	b8 00 00 00 00       	mov    $0x0,%eax
  801bcd:	eb d4                	jmp    801ba3 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bcf:	99                   	cltd   
  801bd0:	c1 ea 1b             	shr    $0x1b,%edx
  801bd3:	01 d0                	add    %edx,%eax
  801bd5:	83 e0 1f             	and    $0x1f,%eax
  801bd8:	29 d0                	sub    %edx,%eax
  801bda:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801bdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be2:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801be5:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801be8:	83 c6 01             	add    $0x1,%esi
  801beb:	eb aa                	jmp    801b97 <devpipe_read+0x20>

00801bed <pipe>:
{
  801bed:	f3 0f 1e fb          	endbr32 
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
  801bf4:	56                   	push   %esi
  801bf5:	53                   	push   %ebx
  801bf6:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801bf9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bfc:	50                   	push   %eax
  801bfd:	e8 1b f6 ff ff       	call   80121d <fd_alloc>
  801c02:	89 c3                	mov    %eax,%ebx
  801c04:	83 c4 10             	add    $0x10,%esp
  801c07:	85 c0                	test   %eax,%eax
  801c09:	0f 88 23 01 00 00    	js     801d32 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0f:	83 ec 04             	sub    $0x4,%esp
  801c12:	68 07 04 00 00       	push   $0x407
  801c17:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1a:	6a 00                	push   $0x0
  801c1c:	e8 81 f0 ff ff       	call   800ca2 <sys_page_alloc>
  801c21:	89 c3                	mov    %eax,%ebx
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	85 c0                	test   %eax,%eax
  801c28:	0f 88 04 01 00 00    	js     801d32 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801c2e:	83 ec 0c             	sub    $0xc,%esp
  801c31:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c34:	50                   	push   %eax
  801c35:	e8 e3 f5 ff ff       	call   80121d <fd_alloc>
  801c3a:	89 c3                	mov    %eax,%ebx
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	0f 88 db 00 00 00    	js     801d22 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c47:	83 ec 04             	sub    $0x4,%esp
  801c4a:	68 07 04 00 00       	push   $0x407
  801c4f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c52:	6a 00                	push   $0x0
  801c54:	e8 49 f0 ff ff       	call   800ca2 <sys_page_alloc>
  801c59:	89 c3                	mov    %eax,%ebx
  801c5b:	83 c4 10             	add    $0x10,%esp
  801c5e:	85 c0                	test   %eax,%eax
  801c60:	0f 88 bc 00 00 00    	js     801d22 <pipe+0x135>
	va = fd2data(fd0);
  801c66:	83 ec 0c             	sub    $0xc,%esp
  801c69:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6c:	e8 91 f5 ff ff       	call   801202 <fd2data>
  801c71:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c73:	83 c4 0c             	add    $0xc,%esp
  801c76:	68 07 04 00 00       	push   $0x407
  801c7b:	50                   	push   %eax
  801c7c:	6a 00                	push   $0x0
  801c7e:	e8 1f f0 ff ff       	call   800ca2 <sys_page_alloc>
  801c83:	89 c3                	mov    %eax,%ebx
  801c85:	83 c4 10             	add    $0x10,%esp
  801c88:	85 c0                	test   %eax,%eax
  801c8a:	0f 88 82 00 00 00    	js     801d12 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c90:	83 ec 0c             	sub    $0xc,%esp
  801c93:	ff 75 f0             	pushl  -0x10(%ebp)
  801c96:	e8 67 f5 ff ff       	call   801202 <fd2data>
  801c9b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ca2:	50                   	push   %eax
  801ca3:	6a 00                	push   $0x0
  801ca5:	56                   	push   %esi
  801ca6:	6a 00                	push   $0x0
  801ca8:	e8 3c f0 ff ff       	call   800ce9 <sys_page_map>
  801cad:	89 c3                	mov    %eax,%ebx
  801caf:	83 c4 20             	add    $0x20,%esp
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	78 4e                	js     801d04 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801cb6:	a1 20 30 80 00       	mov    0x803020,%eax
  801cbb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cbe:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801cc0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cc3:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801cca:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ccd:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801ccf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801cd9:	83 ec 0c             	sub    $0xc,%esp
  801cdc:	ff 75 f4             	pushl  -0xc(%ebp)
  801cdf:	e8 0a f5 ff ff       	call   8011ee <fd2num>
  801ce4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ce7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ce9:	83 c4 04             	add    $0x4,%esp
  801cec:	ff 75 f0             	pushl  -0x10(%ebp)
  801cef:	e8 fa f4 ff ff       	call   8011ee <fd2num>
  801cf4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cf7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cfa:	83 c4 10             	add    $0x10,%esp
  801cfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d02:	eb 2e                	jmp    801d32 <pipe+0x145>
	sys_page_unmap(0, va);
  801d04:	83 ec 08             	sub    $0x8,%esp
  801d07:	56                   	push   %esi
  801d08:	6a 00                	push   $0x0
  801d0a:	e8 20 f0 ff ff       	call   800d2f <sys_page_unmap>
  801d0f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d12:	83 ec 08             	sub    $0x8,%esp
  801d15:	ff 75 f0             	pushl  -0x10(%ebp)
  801d18:	6a 00                	push   $0x0
  801d1a:	e8 10 f0 ff ff       	call   800d2f <sys_page_unmap>
  801d1f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801d22:	83 ec 08             	sub    $0x8,%esp
  801d25:	ff 75 f4             	pushl  -0xc(%ebp)
  801d28:	6a 00                	push   $0x0
  801d2a:	e8 00 f0 ff ff       	call   800d2f <sys_page_unmap>
  801d2f:	83 c4 10             	add    $0x10,%esp
}
  801d32:	89 d8                	mov    %ebx,%eax
  801d34:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d37:	5b                   	pop    %ebx
  801d38:	5e                   	pop    %esi
  801d39:	5d                   	pop    %ebp
  801d3a:	c3                   	ret    

00801d3b <pipeisclosed>:
{
  801d3b:	f3 0f 1e fb          	endbr32 
  801d3f:	55                   	push   %ebp
  801d40:	89 e5                	mov    %esp,%ebp
  801d42:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d45:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d48:	50                   	push   %eax
  801d49:	ff 75 08             	pushl  0x8(%ebp)
  801d4c:	e8 22 f5 ff ff       	call   801273 <fd_lookup>
  801d51:	83 c4 10             	add    $0x10,%esp
  801d54:	85 c0                	test   %eax,%eax
  801d56:	78 18                	js     801d70 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801d58:	83 ec 0c             	sub    $0xc,%esp
  801d5b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d5e:	e8 9f f4 ff ff       	call   801202 <fd2data>
  801d63:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d68:	e8 1f fd ff ff       	call   801a8c <_pipeisclosed>
  801d6d:	83 c4 10             	add    $0x10,%esp
}
  801d70:	c9                   	leave  
  801d71:	c3                   	ret    

00801d72 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d72:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801d76:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7b:	c3                   	ret    

00801d7c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d7c:	f3 0f 1e fb          	endbr32 
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d86:	68 c0 27 80 00       	push   $0x8027c0
  801d8b:	ff 75 0c             	pushl  0xc(%ebp)
  801d8e:	e8 cd ea ff ff       	call   800860 <strcpy>
	return 0;
}
  801d93:	b8 00 00 00 00       	mov    $0x0,%eax
  801d98:	c9                   	leave  
  801d99:	c3                   	ret    

00801d9a <devcons_write>:
{
  801d9a:	f3 0f 1e fb          	endbr32 
  801d9e:	55                   	push   %ebp
  801d9f:	89 e5                	mov    %esp,%ebp
  801da1:	57                   	push   %edi
  801da2:	56                   	push   %esi
  801da3:	53                   	push   %ebx
  801da4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801daa:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801daf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801db5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801db8:	73 31                	jae    801deb <devcons_write+0x51>
		m = n - tot;
  801dba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dbd:	29 f3                	sub    %esi,%ebx
  801dbf:	83 fb 7f             	cmp    $0x7f,%ebx
  801dc2:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801dc7:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801dca:	83 ec 04             	sub    $0x4,%esp
  801dcd:	53                   	push   %ebx
  801dce:	89 f0                	mov    %esi,%eax
  801dd0:	03 45 0c             	add    0xc(%ebp),%eax
  801dd3:	50                   	push   %eax
  801dd4:	57                   	push   %edi
  801dd5:	e8 3c ec ff ff       	call   800a16 <memmove>
		sys_cputs(buf, m);
  801dda:	83 c4 08             	add    $0x8,%esp
  801ddd:	53                   	push   %ebx
  801dde:	57                   	push   %edi
  801ddf:	e8 ee ed ff ff       	call   800bd2 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801de4:	01 de                	add    %ebx,%esi
  801de6:	83 c4 10             	add    $0x10,%esp
  801de9:	eb ca                	jmp    801db5 <devcons_write+0x1b>
}
  801deb:	89 f0                	mov    %esi,%eax
  801ded:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df0:	5b                   	pop    %ebx
  801df1:	5e                   	pop    %esi
  801df2:	5f                   	pop    %edi
  801df3:	5d                   	pop    %ebp
  801df4:	c3                   	ret    

00801df5 <devcons_read>:
{
  801df5:	f3 0f 1e fb          	endbr32 
  801df9:	55                   	push   %ebp
  801dfa:	89 e5                	mov    %esp,%ebp
  801dfc:	83 ec 08             	sub    $0x8,%esp
  801dff:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e04:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e08:	74 21                	je     801e2b <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801e0a:	e8 e5 ed ff ff       	call   800bf4 <sys_cgetc>
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	75 07                	jne    801e1a <devcons_read+0x25>
		sys_yield();
  801e13:	e8 67 ee ff ff       	call   800c7f <sys_yield>
  801e18:	eb f0                	jmp    801e0a <devcons_read+0x15>
	if (c < 0)
  801e1a:	78 0f                	js     801e2b <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801e1c:	83 f8 04             	cmp    $0x4,%eax
  801e1f:	74 0c                	je     801e2d <devcons_read+0x38>
	*(char*)vbuf = c;
  801e21:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e24:	88 02                	mov    %al,(%edx)
	return 1;
  801e26:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801e2b:	c9                   	leave  
  801e2c:	c3                   	ret    
		return 0;
  801e2d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e32:	eb f7                	jmp    801e2b <devcons_read+0x36>

00801e34 <cputchar>:
{
  801e34:	f3 0f 1e fb          	endbr32 
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e41:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e44:	6a 01                	push   $0x1
  801e46:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e49:	50                   	push   %eax
  801e4a:	e8 83 ed ff ff       	call   800bd2 <sys_cputs>
}
  801e4f:	83 c4 10             	add    $0x10,%esp
  801e52:	c9                   	leave  
  801e53:	c3                   	ret    

00801e54 <getchar>:
{
  801e54:	f3 0f 1e fb          	endbr32 
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801e5e:	6a 01                	push   $0x1
  801e60:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e63:	50                   	push   %eax
  801e64:	6a 00                	push   $0x0
  801e66:	e8 8b f6 ff ff       	call   8014f6 <read>
	if (r < 0)
  801e6b:	83 c4 10             	add    $0x10,%esp
  801e6e:	85 c0                	test   %eax,%eax
  801e70:	78 06                	js     801e78 <getchar+0x24>
	if (r < 1)
  801e72:	74 06                	je     801e7a <getchar+0x26>
	return c;
  801e74:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e78:	c9                   	leave  
  801e79:	c3                   	ret    
		return -E_EOF;
  801e7a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e7f:	eb f7                	jmp    801e78 <getchar+0x24>

00801e81 <iscons>:
{
  801e81:	f3 0f 1e fb          	endbr32 
  801e85:	55                   	push   %ebp
  801e86:	89 e5                	mov    %esp,%ebp
  801e88:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e8e:	50                   	push   %eax
  801e8f:	ff 75 08             	pushl  0x8(%ebp)
  801e92:	e8 dc f3 ff ff       	call   801273 <fd_lookup>
  801e97:	83 c4 10             	add    $0x10,%esp
  801e9a:	85 c0                	test   %eax,%eax
  801e9c:	78 11                	js     801eaf <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ea7:	39 10                	cmp    %edx,(%eax)
  801ea9:	0f 94 c0             	sete   %al
  801eac:	0f b6 c0             	movzbl %al,%eax
}
  801eaf:	c9                   	leave  
  801eb0:	c3                   	ret    

00801eb1 <opencons>:
{
  801eb1:	f3 0f 1e fb          	endbr32 
  801eb5:	55                   	push   %ebp
  801eb6:	89 e5                	mov    %esp,%ebp
  801eb8:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801ebb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ebe:	50                   	push   %eax
  801ebf:	e8 59 f3 ff ff       	call   80121d <fd_alloc>
  801ec4:	83 c4 10             	add    $0x10,%esp
  801ec7:	85 c0                	test   %eax,%eax
  801ec9:	78 3a                	js     801f05 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ecb:	83 ec 04             	sub    $0x4,%esp
  801ece:	68 07 04 00 00       	push   $0x407
  801ed3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed6:	6a 00                	push   $0x0
  801ed8:	e8 c5 ed ff ff       	call   800ca2 <sys_page_alloc>
  801edd:	83 c4 10             	add    $0x10,%esp
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	78 21                	js     801f05 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eed:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ef9:	83 ec 0c             	sub    $0xc,%esp
  801efc:	50                   	push   %eax
  801efd:	e8 ec f2 ff ff       	call   8011ee <fd2num>
  801f02:	83 c4 10             	add    $0x10,%esp
}
  801f05:	c9                   	leave  
  801f06:	c3                   	ret    

00801f07 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f07:	f3 0f 1e fb          	endbr32 
  801f0b:	55                   	push   %ebp
  801f0c:	89 e5                	mov    %esp,%ebp
  801f0e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f11:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f18:	74 0a                	je     801f24 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1d:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f22:	c9                   	leave  
  801f23:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801f24:	83 ec 0c             	sub    $0xc,%esp
  801f27:	68 cc 27 80 00       	push   $0x8027cc
  801f2c:	e8 26 e3 ff ff       	call   800257 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  801f31:	83 c4 0c             	add    $0xc,%esp
  801f34:	6a 07                	push   $0x7
  801f36:	68 00 f0 bf ee       	push   $0xeebff000
  801f3b:	6a 00                	push   $0x0
  801f3d:	e8 60 ed ff ff       	call   800ca2 <sys_page_alloc>
  801f42:	83 c4 10             	add    $0x10,%esp
  801f45:	85 c0                	test   %eax,%eax
  801f47:	78 2a                	js     801f73 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801f49:	83 ec 08             	sub    $0x8,%esp
  801f4c:	68 87 1f 80 00       	push   $0x801f87
  801f51:	6a 00                	push   $0x0
  801f53:	e8 a9 ee ff ff       	call   800e01 <sys_env_set_pgfault_upcall>
  801f58:	83 c4 10             	add    $0x10,%esp
  801f5b:	85 c0                	test   %eax,%eax
  801f5d:	79 bb                	jns    801f1a <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  801f5f:	83 ec 04             	sub    $0x4,%esp
  801f62:	68 08 28 80 00       	push   $0x802808
  801f67:	6a 25                	push   $0x25
  801f69:	68 f9 27 80 00       	push   $0x8027f9
  801f6e:	e8 fd e1 ff ff       	call   800170 <_panic>
            panic("Allocation of UXSTACK failed!");
  801f73:	83 ec 04             	sub    $0x4,%esp
  801f76:	68 db 27 80 00       	push   $0x8027db
  801f7b:	6a 22                	push   $0x22
  801f7d:	68 f9 27 80 00       	push   $0x8027f9
  801f82:	e8 e9 e1 ff ff       	call   800170 <_panic>

00801f87 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f87:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f88:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f8d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f8f:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  801f92:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  801f96:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  801f9a:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  801f9d:	83 c4 08             	add    $0x8,%esp
    popa
  801fa0:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  801fa1:	83 c4 04             	add    $0x4,%esp
    popf
  801fa4:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  801fa5:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  801fa8:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  801fac:	c3                   	ret    

00801fad <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fad:	f3 0f 1e fb          	endbr32 
  801fb1:	55                   	push   %ebp
  801fb2:	89 e5                	mov    %esp,%ebp
  801fb4:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb7:	89 c2                	mov    %eax,%edx
  801fb9:	c1 ea 16             	shr    $0x16,%edx
  801fbc:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fc3:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fc8:	f6 c1 01             	test   $0x1,%cl
  801fcb:	74 1c                	je     801fe9 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801fcd:	c1 e8 0c             	shr    $0xc,%eax
  801fd0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fd7:	a8 01                	test   $0x1,%al
  801fd9:	74 0e                	je     801fe9 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fdb:	c1 e8 0c             	shr    $0xc,%eax
  801fde:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801fe5:	ef 
  801fe6:	0f b7 d2             	movzwl %dx,%edx
}
  801fe9:	89 d0                	mov    %edx,%eax
  801feb:	5d                   	pop    %ebp
  801fec:	c3                   	ret    
  801fed:	66 90                	xchg   %ax,%ax
  801fef:	90                   	nop

00801ff0 <__udivdi3>:
  801ff0:	f3 0f 1e fb          	endbr32 
  801ff4:	55                   	push   %ebp
  801ff5:	57                   	push   %edi
  801ff6:	56                   	push   %esi
  801ff7:	53                   	push   %ebx
  801ff8:	83 ec 1c             	sub    $0x1c,%esp
  801ffb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801fff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802003:	8b 74 24 34          	mov    0x34(%esp),%esi
  802007:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80200b:	85 d2                	test   %edx,%edx
  80200d:	75 19                	jne    802028 <__udivdi3+0x38>
  80200f:	39 f3                	cmp    %esi,%ebx
  802011:	76 4d                	jbe    802060 <__udivdi3+0x70>
  802013:	31 ff                	xor    %edi,%edi
  802015:	89 e8                	mov    %ebp,%eax
  802017:	89 f2                	mov    %esi,%edx
  802019:	f7 f3                	div    %ebx
  80201b:	89 fa                	mov    %edi,%edx
  80201d:	83 c4 1c             	add    $0x1c,%esp
  802020:	5b                   	pop    %ebx
  802021:	5e                   	pop    %esi
  802022:	5f                   	pop    %edi
  802023:	5d                   	pop    %ebp
  802024:	c3                   	ret    
  802025:	8d 76 00             	lea    0x0(%esi),%esi
  802028:	39 f2                	cmp    %esi,%edx
  80202a:	76 14                	jbe    802040 <__udivdi3+0x50>
  80202c:	31 ff                	xor    %edi,%edi
  80202e:	31 c0                	xor    %eax,%eax
  802030:	89 fa                	mov    %edi,%edx
  802032:	83 c4 1c             	add    $0x1c,%esp
  802035:	5b                   	pop    %ebx
  802036:	5e                   	pop    %esi
  802037:	5f                   	pop    %edi
  802038:	5d                   	pop    %ebp
  802039:	c3                   	ret    
  80203a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802040:	0f bd fa             	bsr    %edx,%edi
  802043:	83 f7 1f             	xor    $0x1f,%edi
  802046:	75 48                	jne    802090 <__udivdi3+0xa0>
  802048:	39 f2                	cmp    %esi,%edx
  80204a:	72 06                	jb     802052 <__udivdi3+0x62>
  80204c:	31 c0                	xor    %eax,%eax
  80204e:	39 eb                	cmp    %ebp,%ebx
  802050:	77 de                	ja     802030 <__udivdi3+0x40>
  802052:	b8 01 00 00 00       	mov    $0x1,%eax
  802057:	eb d7                	jmp    802030 <__udivdi3+0x40>
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	89 d9                	mov    %ebx,%ecx
  802062:	85 db                	test   %ebx,%ebx
  802064:	75 0b                	jne    802071 <__udivdi3+0x81>
  802066:	b8 01 00 00 00       	mov    $0x1,%eax
  80206b:	31 d2                	xor    %edx,%edx
  80206d:	f7 f3                	div    %ebx
  80206f:	89 c1                	mov    %eax,%ecx
  802071:	31 d2                	xor    %edx,%edx
  802073:	89 f0                	mov    %esi,%eax
  802075:	f7 f1                	div    %ecx
  802077:	89 c6                	mov    %eax,%esi
  802079:	89 e8                	mov    %ebp,%eax
  80207b:	89 f7                	mov    %esi,%edi
  80207d:	f7 f1                	div    %ecx
  80207f:	89 fa                	mov    %edi,%edx
  802081:	83 c4 1c             	add    $0x1c,%esp
  802084:	5b                   	pop    %ebx
  802085:	5e                   	pop    %esi
  802086:	5f                   	pop    %edi
  802087:	5d                   	pop    %ebp
  802088:	c3                   	ret    
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	89 f9                	mov    %edi,%ecx
  802092:	b8 20 00 00 00       	mov    $0x20,%eax
  802097:	29 f8                	sub    %edi,%eax
  802099:	d3 e2                	shl    %cl,%edx
  80209b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80209f:	89 c1                	mov    %eax,%ecx
  8020a1:	89 da                	mov    %ebx,%edx
  8020a3:	d3 ea                	shr    %cl,%edx
  8020a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020a9:	09 d1                	or     %edx,%ecx
  8020ab:	89 f2                	mov    %esi,%edx
  8020ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020b1:	89 f9                	mov    %edi,%ecx
  8020b3:	d3 e3                	shl    %cl,%ebx
  8020b5:	89 c1                	mov    %eax,%ecx
  8020b7:	d3 ea                	shr    %cl,%edx
  8020b9:	89 f9                	mov    %edi,%ecx
  8020bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020bf:	89 eb                	mov    %ebp,%ebx
  8020c1:	d3 e6                	shl    %cl,%esi
  8020c3:	89 c1                	mov    %eax,%ecx
  8020c5:	d3 eb                	shr    %cl,%ebx
  8020c7:	09 de                	or     %ebx,%esi
  8020c9:	89 f0                	mov    %esi,%eax
  8020cb:	f7 74 24 08          	divl   0x8(%esp)
  8020cf:	89 d6                	mov    %edx,%esi
  8020d1:	89 c3                	mov    %eax,%ebx
  8020d3:	f7 64 24 0c          	mull   0xc(%esp)
  8020d7:	39 d6                	cmp    %edx,%esi
  8020d9:	72 15                	jb     8020f0 <__udivdi3+0x100>
  8020db:	89 f9                	mov    %edi,%ecx
  8020dd:	d3 e5                	shl    %cl,%ebp
  8020df:	39 c5                	cmp    %eax,%ebp
  8020e1:	73 04                	jae    8020e7 <__udivdi3+0xf7>
  8020e3:	39 d6                	cmp    %edx,%esi
  8020e5:	74 09                	je     8020f0 <__udivdi3+0x100>
  8020e7:	89 d8                	mov    %ebx,%eax
  8020e9:	31 ff                	xor    %edi,%edi
  8020eb:	e9 40 ff ff ff       	jmp    802030 <__udivdi3+0x40>
  8020f0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8020f3:	31 ff                	xor    %edi,%edi
  8020f5:	e9 36 ff ff ff       	jmp    802030 <__udivdi3+0x40>
  8020fa:	66 90                	xchg   %ax,%ax
  8020fc:	66 90                	xchg   %ax,%ax
  8020fe:	66 90                	xchg   %ax,%ax

00802100 <__umoddi3>:
  802100:	f3 0f 1e fb          	endbr32 
  802104:	55                   	push   %ebp
  802105:	57                   	push   %edi
  802106:	56                   	push   %esi
  802107:	53                   	push   %ebx
  802108:	83 ec 1c             	sub    $0x1c,%esp
  80210b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80210f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802113:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802117:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80211b:	85 c0                	test   %eax,%eax
  80211d:	75 19                	jne    802138 <__umoddi3+0x38>
  80211f:	39 df                	cmp    %ebx,%edi
  802121:	76 5d                	jbe    802180 <__umoddi3+0x80>
  802123:	89 f0                	mov    %esi,%eax
  802125:	89 da                	mov    %ebx,%edx
  802127:	f7 f7                	div    %edi
  802129:	89 d0                	mov    %edx,%eax
  80212b:	31 d2                	xor    %edx,%edx
  80212d:	83 c4 1c             	add    $0x1c,%esp
  802130:	5b                   	pop    %ebx
  802131:	5e                   	pop    %esi
  802132:	5f                   	pop    %edi
  802133:	5d                   	pop    %ebp
  802134:	c3                   	ret    
  802135:	8d 76 00             	lea    0x0(%esi),%esi
  802138:	89 f2                	mov    %esi,%edx
  80213a:	39 d8                	cmp    %ebx,%eax
  80213c:	76 12                	jbe    802150 <__umoddi3+0x50>
  80213e:	89 f0                	mov    %esi,%eax
  802140:	89 da                	mov    %ebx,%edx
  802142:	83 c4 1c             	add    $0x1c,%esp
  802145:	5b                   	pop    %ebx
  802146:	5e                   	pop    %esi
  802147:	5f                   	pop    %edi
  802148:	5d                   	pop    %ebp
  802149:	c3                   	ret    
  80214a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802150:	0f bd e8             	bsr    %eax,%ebp
  802153:	83 f5 1f             	xor    $0x1f,%ebp
  802156:	75 50                	jne    8021a8 <__umoddi3+0xa8>
  802158:	39 d8                	cmp    %ebx,%eax
  80215a:	0f 82 e0 00 00 00    	jb     802240 <__umoddi3+0x140>
  802160:	89 d9                	mov    %ebx,%ecx
  802162:	39 f7                	cmp    %esi,%edi
  802164:	0f 86 d6 00 00 00    	jbe    802240 <__umoddi3+0x140>
  80216a:	89 d0                	mov    %edx,%eax
  80216c:	89 ca                	mov    %ecx,%edx
  80216e:	83 c4 1c             	add    $0x1c,%esp
  802171:	5b                   	pop    %ebx
  802172:	5e                   	pop    %esi
  802173:	5f                   	pop    %edi
  802174:	5d                   	pop    %ebp
  802175:	c3                   	ret    
  802176:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80217d:	8d 76 00             	lea    0x0(%esi),%esi
  802180:	89 fd                	mov    %edi,%ebp
  802182:	85 ff                	test   %edi,%edi
  802184:	75 0b                	jne    802191 <__umoddi3+0x91>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f7                	div    %edi
  80218f:	89 c5                	mov    %eax,%ebp
  802191:	89 d8                	mov    %ebx,%eax
  802193:	31 d2                	xor    %edx,%edx
  802195:	f7 f5                	div    %ebp
  802197:	89 f0                	mov    %esi,%eax
  802199:	f7 f5                	div    %ebp
  80219b:	89 d0                	mov    %edx,%eax
  80219d:	31 d2                	xor    %edx,%edx
  80219f:	eb 8c                	jmp    80212d <__umoddi3+0x2d>
  8021a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	89 e9                	mov    %ebp,%ecx
  8021aa:	ba 20 00 00 00       	mov    $0x20,%edx
  8021af:	29 ea                	sub    %ebp,%edx
  8021b1:	d3 e0                	shl    %cl,%eax
  8021b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021b7:	89 d1                	mov    %edx,%ecx
  8021b9:	89 f8                	mov    %edi,%eax
  8021bb:	d3 e8                	shr    %cl,%eax
  8021bd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8021c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021c5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021c9:	09 c1                	or     %eax,%ecx
  8021cb:	89 d8                	mov    %ebx,%eax
  8021cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021d1:	89 e9                	mov    %ebp,%ecx
  8021d3:	d3 e7                	shl    %cl,%edi
  8021d5:	89 d1                	mov    %edx,%ecx
  8021d7:	d3 e8                	shr    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021df:	d3 e3                	shl    %cl,%ebx
  8021e1:	89 c7                	mov    %eax,%edi
  8021e3:	89 d1                	mov    %edx,%ecx
  8021e5:	89 f0                	mov    %esi,%eax
  8021e7:	d3 e8                	shr    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	89 fa                	mov    %edi,%edx
  8021ed:	d3 e6                	shl    %cl,%esi
  8021ef:	09 d8                	or     %ebx,%eax
  8021f1:	f7 74 24 08          	divl   0x8(%esp)
  8021f5:	89 d1                	mov    %edx,%ecx
  8021f7:	89 f3                	mov    %esi,%ebx
  8021f9:	f7 64 24 0c          	mull   0xc(%esp)
  8021fd:	89 c6                	mov    %eax,%esi
  8021ff:	89 d7                	mov    %edx,%edi
  802201:	39 d1                	cmp    %edx,%ecx
  802203:	72 06                	jb     80220b <__umoddi3+0x10b>
  802205:	75 10                	jne    802217 <__umoddi3+0x117>
  802207:	39 c3                	cmp    %eax,%ebx
  802209:	73 0c                	jae    802217 <__umoddi3+0x117>
  80220b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80220f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802213:	89 d7                	mov    %edx,%edi
  802215:	89 c6                	mov    %eax,%esi
  802217:	89 ca                	mov    %ecx,%edx
  802219:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80221e:	29 f3                	sub    %esi,%ebx
  802220:	19 fa                	sbb    %edi,%edx
  802222:	89 d0                	mov    %edx,%eax
  802224:	d3 e0                	shl    %cl,%eax
  802226:	89 e9                	mov    %ebp,%ecx
  802228:	d3 eb                	shr    %cl,%ebx
  80222a:	d3 ea                	shr    %cl,%edx
  80222c:	09 d8                	or     %ebx,%eax
  80222e:	83 c4 1c             	add    $0x1c,%esp
  802231:	5b                   	pop    %ebx
  802232:	5e                   	pop    %esi
  802233:	5f                   	pop    %edi
  802234:	5d                   	pop    %ebp
  802235:	c3                   	ret    
  802236:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80223d:	8d 76 00             	lea    0x0(%esi),%esi
  802240:	29 fe                	sub    %edi,%esi
  802242:	19 c3                	sbb    %eax,%ebx
  802244:	89 f2                	mov    %esi,%edx
  802246:	89 d9                	mov    %ebx,%ecx
  802248:	e9 1d ff ff ff       	jmp    80216a <__umoddi3+0x6a>
