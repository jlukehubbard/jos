
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
  80004b:	e8 4c 10 00 00       	call   80109c <ipc_recv>
  800050:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  800052:	a1 04 20 80 00       	mov    0x802004,%eax
  800057:	8b 40 5c             	mov    0x5c(%eax),%eax
  80005a:	83 c4 0c             	add    $0xc,%esp
  80005d:	53                   	push   %ebx
  80005e:	50                   	push   %eax
  80005f:	68 a0 14 80 00       	push   $0x8014a0
  800064:	e8 dc 01 00 00       	call   800245 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800069:	e8 c2 0e 00 00       	call   800f30 <fork>
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
  80007f:	68 ac 14 80 00       	push   $0x8014ac
  800084:	6a 1a                	push   $0x1a
  800086:	68 b5 14 80 00       	push   $0x8014b5
  80008b:	e8 ce 00 00 00       	call   80015e <_panic>
		if (i % p)
			ipc_send(id, i, 0, 0);
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	51                   	push   %ecx
  800095:	57                   	push   %edi
  800096:	e8 58 10 00 00       	call   8010f3 <ipc_send>
  80009b:	83 c4 10             	add    $0x10,%esp
		i = ipc_recv(&envid, 0, 0);
  80009e:	83 ec 04             	sub    $0x4,%esp
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	56                   	push   %esi
  8000a6:	e8 f1 0f 00 00       	call   80109c <ipc_recv>
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
  8000c2:	e8 69 0e 00 00       	call   800f30 <fork>
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
  8000da:	e8 14 10 00 00       	call   8010f3 <ipc_send>
	for (i = 2; ; i++)
  8000df:	83 c3 01             	add    $0x1,%ebx
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb ed                	jmp    8000d4 <umain+0x1b>
		panic("fork: %e", id);
  8000e7:	50                   	push   %eax
  8000e8:	68 ac 14 80 00       	push   $0x8014ac
  8000ed:	6a 2d                	push   $0x2d
  8000ef:	68 b5 14 80 00       	push   $0x8014b5
  8000f4:	e8 65 00 00 00       	call   80015e <_panic>
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
    envid_t envid = sys_getenvid();
  80010d:	e8 38 0b 00 00       	call   800c4a <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800112:	25 ff 03 00 00       	and    $0x3ff,%eax
  800117:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800124:	85 db                	test   %ebx,%ebx
  800126:	7e 07                	jle    80012f <libmain+0x31>
		binaryname = argv[0];
  800128:	8b 06                	mov    (%esi),%eax
  80012a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012f:	83 ec 08             	sub    $0x8,%esp
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
  800134:	e8 80 ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  800139:	e8 0a 00 00 00       	call   800148 <exit>
}
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5d                   	pop    %ebp
  800147:	c3                   	ret    

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	f3 0f 1e fb          	endbr32 
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800152:	6a 00                	push   $0x0
  800154:	e8 ac 0a 00 00       	call   800c05 <sys_env_destroy>
}
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	c9                   	leave  
  80015d:	c3                   	ret    

0080015e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015e:	f3 0f 1e fb          	endbr32 
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	56                   	push   %esi
  800166:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800167:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800170:	e8 d5 0a 00 00       	call   800c4a <sys_getenvid>
  800175:	83 ec 0c             	sub    $0xc,%esp
  800178:	ff 75 0c             	pushl  0xc(%ebp)
  80017b:	ff 75 08             	pushl  0x8(%ebp)
  80017e:	56                   	push   %esi
  80017f:	50                   	push   %eax
  800180:	68 d0 14 80 00       	push   $0x8014d0
  800185:	e8 bb 00 00 00       	call   800245 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80018a:	83 c4 18             	add    $0x18,%esp
  80018d:	53                   	push   %ebx
  80018e:	ff 75 10             	pushl  0x10(%ebp)
  800191:	e8 5a 00 00 00       	call   8001f0 <vcprintf>
	cprintf("\n");
  800196:	c7 04 24 54 18 80 00 	movl   $0x801854,(%esp)
  80019d:	e8 a3 00 00 00       	call   800245 <cprintf>
  8001a2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a5:	cc                   	int3   
  8001a6:	eb fd                	jmp    8001a5 <_panic+0x47>

008001a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a8:	f3 0f 1e fb          	endbr32 
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 04             	sub    $0x4,%esp
  8001b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b6:	8b 13                	mov    (%ebx),%edx
  8001b8:	8d 42 01             	lea    0x1(%edx),%eax
  8001bb:	89 03                	mov    %eax,(%ebx)
  8001bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001c4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c9:	74 09                	je     8001d4 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001cb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001d4:	83 ec 08             	sub    $0x8,%esp
  8001d7:	68 ff 00 00 00       	push   $0xff
  8001dc:	8d 43 08             	lea    0x8(%ebx),%eax
  8001df:	50                   	push   %eax
  8001e0:	e8 db 09 00 00       	call   800bc0 <sys_cputs>
		b->idx = 0;
  8001e5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001eb:	83 c4 10             	add    $0x10,%esp
  8001ee:	eb db                	jmp    8001cb <putch+0x23>

008001f0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f0:	f3 0f 1e fb          	endbr32 
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001fd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800204:	00 00 00 
	b.cnt = 0;
  800207:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80020e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800211:	ff 75 0c             	pushl  0xc(%ebp)
  800214:	ff 75 08             	pushl  0x8(%ebp)
  800217:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021d:	50                   	push   %eax
  80021e:	68 a8 01 80 00       	push   $0x8001a8
  800223:	e8 20 01 00 00       	call   800348 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800228:	83 c4 08             	add    $0x8,%esp
  80022b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800231:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800237:	50                   	push   %eax
  800238:	e8 83 09 00 00       	call   800bc0 <sys_cputs>

	return b.cnt;
}
  80023d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800245:	f3 0f 1e fb          	endbr32 
  800249:	55                   	push   %ebp
  80024a:	89 e5                	mov    %esp,%ebp
  80024c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80024f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800252:	50                   	push   %eax
  800253:	ff 75 08             	pushl  0x8(%ebp)
  800256:	e8 95 ff ff ff       	call   8001f0 <vcprintf>
	va_end(ap);

	return cnt;
}
  80025b:	c9                   	leave  
  80025c:	c3                   	ret    

0080025d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80025d:	55                   	push   %ebp
  80025e:	89 e5                	mov    %esp,%ebp
  800260:	57                   	push   %edi
  800261:	56                   	push   %esi
  800262:	53                   	push   %ebx
  800263:	83 ec 1c             	sub    $0x1c,%esp
  800266:	89 c7                	mov    %eax,%edi
  800268:	89 d6                	mov    %edx,%esi
  80026a:	8b 45 08             	mov    0x8(%ebp),%eax
  80026d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800270:	89 d1                	mov    %edx,%ecx
  800272:	89 c2                	mov    %eax,%edx
  800274:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800277:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80027a:	8b 45 10             	mov    0x10(%ebp),%eax
  80027d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800280:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800283:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80028a:	39 c2                	cmp    %eax,%edx
  80028c:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80028f:	72 3e                	jb     8002cf <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800291:	83 ec 0c             	sub    $0xc,%esp
  800294:	ff 75 18             	pushl  0x18(%ebp)
  800297:	83 eb 01             	sub    $0x1,%ebx
  80029a:	53                   	push   %ebx
  80029b:	50                   	push   %eax
  80029c:	83 ec 08             	sub    $0x8,%esp
  80029f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ab:	e8 90 0f 00 00       	call   801240 <__udivdi3>
  8002b0:	83 c4 18             	add    $0x18,%esp
  8002b3:	52                   	push   %edx
  8002b4:	50                   	push   %eax
  8002b5:	89 f2                	mov    %esi,%edx
  8002b7:	89 f8                	mov    %edi,%eax
  8002b9:	e8 9f ff ff ff       	call   80025d <printnum>
  8002be:	83 c4 20             	add    $0x20,%esp
  8002c1:	eb 13                	jmp    8002d6 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002c3:	83 ec 08             	sub    $0x8,%esp
  8002c6:	56                   	push   %esi
  8002c7:	ff 75 18             	pushl  0x18(%ebp)
  8002ca:	ff d7                	call   *%edi
  8002cc:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002cf:	83 eb 01             	sub    $0x1,%ebx
  8002d2:	85 db                	test   %ebx,%ebx
  8002d4:	7f ed                	jg     8002c3 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002d6:	83 ec 08             	sub    $0x8,%esp
  8002d9:	56                   	push   %esi
  8002da:	83 ec 04             	sub    $0x4,%esp
  8002dd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e9:	e8 62 10 00 00       	call   801350 <__umoddi3>
  8002ee:	83 c4 14             	add    $0x14,%esp
  8002f1:	0f be 80 f3 14 80 00 	movsbl 0x8014f3(%eax),%eax
  8002f8:	50                   	push   %eax
  8002f9:	ff d7                	call   *%edi
}
  8002fb:	83 c4 10             	add    $0x10,%esp
  8002fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800306:	f3 0f 1e fb          	endbr32 
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800310:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800314:	8b 10                	mov    (%eax),%edx
  800316:	3b 50 04             	cmp    0x4(%eax),%edx
  800319:	73 0a                	jae    800325 <sprintputch+0x1f>
		*b->buf++ = ch;
  80031b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80031e:	89 08                	mov    %ecx,(%eax)
  800320:	8b 45 08             	mov    0x8(%ebp),%eax
  800323:	88 02                	mov    %al,(%edx)
}
  800325:	5d                   	pop    %ebp
  800326:	c3                   	ret    

00800327 <printfmt>:
{
  800327:	f3 0f 1e fb          	endbr32 
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800331:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800334:	50                   	push   %eax
  800335:	ff 75 10             	pushl  0x10(%ebp)
  800338:	ff 75 0c             	pushl  0xc(%ebp)
  80033b:	ff 75 08             	pushl  0x8(%ebp)
  80033e:	e8 05 00 00 00       	call   800348 <vprintfmt>
}
  800343:	83 c4 10             	add    $0x10,%esp
  800346:	c9                   	leave  
  800347:	c3                   	ret    

00800348 <vprintfmt>:
{
  800348:	f3 0f 1e fb          	endbr32 
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	57                   	push   %edi
  800350:	56                   	push   %esi
  800351:	53                   	push   %ebx
  800352:	83 ec 3c             	sub    $0x3c,%esp
  800355:	8b 75 08             	mov    0x8(%ebp),%esi
  800358:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80035b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80035e:	e9 4a 03 00 00       	jmp    8006ad <vprintfmt+0x365>
		padc = ' ';
  800363:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800367:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80036e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800375:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80037c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8d 47 01             	lea    0x1(%edi),%eax
  800384:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800387:	0f b6 17             	movzbl (%edi),%edx
  80038a:	8d 42 dd             	lea    -0x23(%edx),%eax
  80038d:	3c 55                	cmp    $0x55,%al
  80038f:	0f 87 de 03 00 00    	ja     800773 <vprintfmt+0x42b>
  800395:	0f b6 c0             	movzbl %al,%eax
  800398:	3e ff 24 85 c0 15 80 	notrack jmp *0x8015c0(,%eax,4)
  80039f:	00 
  8003a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003a3:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003a7:	eb d8                	jmp    800381 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ac:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003b0:	eb cf                	jmp    800381 <vprintfmt+0x39>
  8003b2:	0f b6 d2             	movzbl %dl,%edx
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003bd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003c0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003c7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003ca:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003cd:	83 f9 09             	cmp    $0x9,%ecx
  8003d0:	77 55                	ja     800427 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003d2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003d5:	eb e9                	jmp    8003c0 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003da:	8b 00                	mov    (%eax),%eax
  8003dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003df:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e2:	8d 40 04             	lea    0x4(%eax),%eax
  8003e5:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003eb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ef:	79 90                	jns    800381 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003f1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003fe:	eb 81                	jmp    800381 <vprintfmt+0x39>
  800400:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800403:	85 c0                	test   %eax,%eax
  800405:	ba 00 00 00 00       	mov    $0x0,%edx
  80040a:	0f 49 d0             	cmovns %eax,%edx
  80040d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800413:	e9 69 ff ff ff       	jmp    800381 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80041b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800422:	e9 5a ff ff ff       	jmp    800381 <vprintfmt+0x39>
  800427:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80042a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80042d:	eb bc                	jmp    8003eb <vprintfmt+0xa3>
			lflag++;
  80042f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800435:	e9 47 ff ff ff       	jmp    800381 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8d 78 04             	lea    0x4(%eax),%edi
  800440:	83 ec 08             	sub    $0x8,%esp
  800443:	53                   	push   %ebx
  800444:	ff 30                	pushl  (%eax)
  800446:	ff d6                	call   *%esi
			break;
  800448:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80044b:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80044e:	e9 57 02 00 00       	jmp    8006aa <vprintfmt+0x362>
			err = va_arg(ap, int);
  800453:	8b 45 14             	mov    0x14(%ebp),%eax
  800456:	8d 78 04             	lea    0x4(%eax),%edi
  800459:	8b 00                	mov    (%eax),%eax
  80045b:	99                   	cltd   
  80045c:	31 d0                	xor    %edx,%eax
  80045e:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800460:	83 f8 08             	cmp    $0x8,%eax
  800463:	7f 23                	jg     800488 <vprintfmt+0x140>
  800465:	8b 14 85 20 17 80 00 	mov    0x801720(,%eax,4),%edx
  80046c:	85 d2                	test   %edx,%edx
  80046e:	74 18                	je     800488 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800470:	52                   	push   %edx
  800471:	68 14 15 80 00       	push   $0x801514
  800476:	53                   	push   %ebx
  800477:	56                   	push   %esi
  800478:	e8 aa fe ff ff       	call   800327 <printfmt>
  80047d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800480:	89 7d 14             	mov    %edi,0x14(%ebp)
  800483:	e9 22 02 00 00       	jmp    8006aa <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800488:	50                   	push   %eax
  800489:	68 0b 15 80 00       	push   $0x80150b
  80048e:	53                   	push   %ebx
  80048f:	56                   	push   %esi
  800490:	e8 92 fe ff ff       	call   800327 <printfmt>
  800495:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800498:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80049b:	e9 0a 02 00 00       	jmp    8006aa <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8004a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a3:	83 c0 04             	add    $0x4,%eax
  8004a6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004ae:	85 d2                	test   %edx,%edx
  8004b0:	b8 04 15 80 00       	mov    $0x801504,%eax
  8004b5:	0f 45 c2             	cmovne %edx,%eax
  8004b8:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004bf:	7e 06                	jle    8004c7 <vprintfmt+0x17f>
  8004c1:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004c5:	75 0d                	jne    8004d4 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c7:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004ca:	89 c7                	mov    %eax,%edi
  8004cc:	03 45 e0             	add    -0x20(%ebp),%eax
  8004cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d2:	eb 55                	jmp    800529 <vprintfmt+0x1e1>
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	ff 75 d8             	pushl  -0x28(%ebp)
  8004da:	ff 75 cc             	pushl  -0x34(%ebp)
  8004dd:	e8 45 03 00 00       	call   800827 <strnlen>
  8004e2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004e5:	29 c2                	sub    %eax,%edx
  8004e7:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004ef:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f6:	85 ff                	test   %edi,%edi
  8004f8:	7e 11                	jle    80050b <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	53                   	push   %ebx
  8004fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800501:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	83 ef 01             	sub    $0x1,%edi
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	eb eb                	jmp    8004f6 <vprintfmt+0x1ae>
  80050b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80050e:	85 d2                	test   %edx,%edx
  800510:	b8 00 00 00 00       	mov    $0x0,%eax
  800515:	0f 49 c2             	cmovns %edx,%eax
  800518:	29 c2                	sub    %eax,%edx
  80051a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80051d:	eb a8                	jmp    8004c7 <vprintfmt+0x17f>
					putch(ch, putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	53                   	push   %ebx
  800523:	52                   	push   %edx
  800524:	ff d6                	call   *%esi
  800526:	83 c4 10             	add    $0x10,%esp
  800529:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80052c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052e:	83 c7 01             	add    $0x1,%edi
  800531:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800535:	0f be d0             	movsbl %al,%edx
  800538:	85 d2                	test   %edx,%edx
  80053a:	74 4b                	je     800587 <vprintfmt+0x23f>
  80053c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800540:	78 06                	js     800548 <vprintfmt+0x200>
  800542:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800546:	78 1e                	js     800566 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800548:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80054c:	74 d1                	je     80051f <vprintfmt+0x1d7>
  80054e:	0f be c0             	movsbl %al,%eax
  800551:	83 e8 20             	sub    $0x20,%eax
  800554:	83 f8 5e             	cmp    $0x5e,%eax
  800557:	76 c6                	jbe    80051f <vprintfmt+0x1d7>
					putch('?', putdat);
  800559:	83 ec 08             	sub    $0x8,%esp
  80055c:	53                   	push   %ebx
  80055d:	6a 3f                	push   $0x3f
  80055f:	ff d6                	call   *%esi
  800561:	83 c4 10             	add    $0x10,%esp
  800564:	eb c3                	jmp    800529 <vprintfmt+0x1e1>
  800566:	89 cf                	mov    %ecx,%edi
  800568:	eb 0e                	jmp    800578 <vprintfmt+0x230>
				putch(' ', putdat);
  80056a:	83 ec 08             	sub    $0x8,%esp
  80056d:	53                   	push   %ebx
  80056e:	6a 20                	push   $0x20
  800570:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800572:	83 ef 01             	sub    $0x1,%edi
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	85 ff                	test   %edi,%edi
  80057a:	7f ee                	jg     80056a <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80057c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80057f:	89 45 14             	mov    %eax,0x14(%ebp)
  800582:	e9 23 01 00 00       	jmp    8006aa <vprintfmt+0x362>
  800587:	89 cf                	mov    %ecx,%edi
  800589:	eb ed                	jmp    800578 <vprintfmt+0x230>
	if (lflag >= 2)
  80058b:	83 f9 01             	cmp    $0x1,%ecx
  80058e:	7f 1b                	jg     8005ab <vprintfmt+0x263>
	else if (lflag)
  800590:	85 c9                	test   %ecx,%ecx
  800592:	74 63                	je     8005f7 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8b 00                	mov    (%eax),%eax
  800599:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059c:	99                   	cltd   
  80059d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	8d 40 04             	lea    0x4(%eax),%eax
  8005a6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a9:	eb 17                	jmp    8005c2 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8b 50 04             	mov    0x4(%eax),%edx
  8005b1:	8b 00                	mov    (%eax),%eax
  8005b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8d 40 08             	lea    0x8(%eax),%eax
  8005bf:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005c2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005c8:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005cd:	85 c9                	test   %ecx,%ecx
  8005cf:	0f 89 bb 00 00 00    	jns    800690 <vprintfmt+0x348>
				putch('-', putdat);
  8005d5:	83 ec 08             	sub    $0x8,%esp
  8005d8:	53                   	push   %ebx
  8005d9:	6a 2d                	push   $0x2d
  8005db:	ff d6                	call   *%esi
				num = -(long long) num;
  8005dd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005e0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005e3:	f7 da                	neg    %edx
  8005e5:	83 d1 00             	adc    $0x0,%ecx
  8005e8:	f7 d9                	neg    %ecx
  8005ea:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005ed:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f2:	e9 99 00 00 00       	jmp    800690 <vprintfmt+0x348>
		return va_arg(*ap, int);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8b 00                	mov    (%eax),%eax
  8005fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ff:	99                   	cltd   
  800600:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8d 40 04             	lea    0x4(%eax),%eax
  800609:	89 45 14             	mov    %eax,0x14(%ebp)
  80060c:	eb b4                	jmp    8005c2 <vprintfmt+0x27a>
	if (lflag >= 2)
  80060e:	83 f9 01             	cmp    $0x1,%ecx
  800611:	7f 1b                	jg     80062e <vprintfmt+0x2e6>
	else if (lflag)
  800613:	85 c9                	test   %ecx,%ecx
  800615:	74 2c                	je     800643 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8b 10                	mov    (%eax),%edx
  80061c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800621:	8d 40 04             	lea    0x4(%eax),%eax
  800624:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800627:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80062c:	eb 62                	jmp    800690 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8b 10                	mov    (%eax),%edx
  800633:	8b 48 04             	mov    0x4(%eax),%ecx
  800636:	8d 40 08             	lea    0x8(%eax),%eax
  800639:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80063c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800641:	eb 4d                	jmp    800690 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8b 10                	mov    (%eax),%edx
  800648:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064d:	8d 40 04             	lea    0x4(%eax),%eax
  800650:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800653:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800658:	eb 36                	jmp    800690 <vprintfmt+0x348>
	if (lflag >= 2)
  80065a:	83 f9 01             	cmp    $0x1,%ecx
  80065d:	7f 17                	jg     800676 <vprintfmt+0x32e>
	else if (lflag)
  80065f:	85 c9                	test   %ecx,%ecx
  800661:	74 6e                	je     8006d1 <vprintfmt+0x389>
		return va_arg(*ap, long);
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8b 10                	mov    (%eax),%edx
  800668:	89 d0                	mov    %edx,%eax
  80066a:	99                   	cltd   
  80066b:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80066e:	8d 49 04             	lea    0x4(%ecx),%ecx
  800671:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800674:	eb 11                	jmp    800687 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	8b 50 04             	mov    0x4(%eax),%edx
  80067c:	8b 00                	mov    (%eax),%eax
  80067e:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800681:	8d 49 08             	lea    0x8(%ecx),%ecx
  800684:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800687:	89 d1                	mov    %edx,%ecx
  800689:	89 c2                	mov    %eax,%edx
            base = 8;
  80068b:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800690:	83 ec 0c             	sub    $0xc,%esp
  800693:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800697:	57                   	push   %edi
  800698:	ff 75 e0             	pushl  -0x20(%ebp)
  80069b:	50                   	push   %eax
  80069c:	51                   	push   %ecx
  80069d:	52                   	push   %edx
  80069e:	89 da                	mov    %ebx,%edx
  8006a0:	89 f0                	mov    %esi,%eax
  8006a2:	e8 b6 fb ff ff       	call   80025d <printnum>
			break;
  8006a7:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006ad:	83 c7 01             	add    $0x1,%edi
  8006b0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006b4:	83 f8 25             	cmp    $0x25,%eax
  8006b7:	0f 84 a6 fc ff ff    	je     800363 <vprintfmt+0x1b>
			if (ch == '\0')
  8006bd:	85 c0                	test   %eax,%eax
  8006bf:	0f 84 ce 00 00 00    	je     800793 <vprintfmt+0x44b>
			putch(ch, putdat);
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	53                   	push   %ebx
  8006c9:	50                   	push   %eax
  8006ca:	ff d6                	call   *%esi
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	eb dc                	jmp    8006ad <vprintfmt+0x365>
		return va_arg(*ap, int);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8b 10                	mov    (%eax),%edx
  8006d6:	89 d0                	mov    %edx,%eax
  8006d8:	99                   	cltd   
  8006d9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006dc:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006df:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006e2:	eb a3                	jmp    800687 <vprintfmt+0x33f>
			putch('0', putdat);
  8006e4:	83 ec 08             	sub    $0x8,%esp
  8006e7:	53                   	push   %ebx
  8006e8:	6a 30                	push   $0x30
  8006ea:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ec:	83 c4 08             	add    $0x8,%esp
  8006ef:	53                   	push   %ebx
  8006f0:	6a 78                	push   $0x78
  8006f2:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8b 10                	mov    (%eax),%edx
  8006f9:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006fe:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800701:	8d 40 04             	lea    0x4(%eax),%eax
  800704:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800707:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80070c:	eb 82                	jmp    800690 <vprintfmt+0x348>
	if (lflag >= 2)
  80070e:	83 f9 01             	cmp    $0x1,%ecx
  800711:	7f 1e                	jg     800731 <vprintfmt+0x3e9>
	else if (lflag)
  800713:	85 c9                	test   %ecx,%ecx
  800715:	74 32                	je     800749 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	8b 10                	mov    (%eax),%edx
  80071c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800721:	8d 40 04             	lea    0x4(%eax),%eax
  800724:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800727:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80072c:	e9 5f ff ff ff       	jmp    800690 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8b 10                	mov    (%eax),%edx
  800736:	8b 48 04             	mov    0x4(%eax),%ecx
  800739:	8d 40 08             	lea    0x8(%eax),%eax
  80073c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800744:	e9 47 ff ff ff       	jmp    800690 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800749:	8b 45 14             	mov    0x14(%ebp),%eax
  80074c:	8b 10                	mov    (%eax),%edx
  80074e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800753:	8d 40 04             	lea    0x4(%eax),%eax
  800756:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800759:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80075e:	e9 2d ff ff ff       	jmp    800690 <vprintfmt+0x348>
			putch(ch, putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	53                   	push   %ebx
  800767:	6a 25                	push   $0x25
  800769:	ff d6                	call   *%esi
			break;
  80076b:	83 c4 10             	add    $0x10,%esp
  80076e:	e9 37 ff ff ff       	jmp    8006aa <vprintfmt+0x362>
			putch('%', putdat);
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	53                   	push   %ebx
  800777:	6a 25                	push   $0x25
  800779:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80077b:	83 c4 10             	add    $0x10,%esp
  80077e:	89 f8                	mov    %edi,%eax
  800780:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800784:	74 05                	je     80078b <vprintfmt+0x443>
  800786:	83 e8 01             	sub    $0x1,%eax
  800789:	eb f5                	jmp    800780 <vprintfmt+0x438>
  80078b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80078e:	e9 17 ff ff ff       	jmp    8006aa <vprintfmt+0x362>
}
  800793:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800796:	5b                   	pop    %ebx
  800797:	5e                   	pop    %esi
  800798:	5f                   	pop    %edi
  800799:	5d                   	pop    %ebp
  80079a:	c3                   	ret    

0080079b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079b:	f3 0f 1e fb          	endbr32 
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	83 ec 18             	sub    $0x18,%esp
  8007a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ae:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007bc:	85 c0                	test   %eax,%eax
  8007be:	74 26                	je     8007e6 <vsnprintf+0x4b>
  8007c0:	85 d2                	test   %edx,%edx
  8007c2:	7e 22                	jle    8007e6 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c4:	ff 75 14             	pushl  0x14(%ebp)
  8007c7:	ff 75 10             	pushl  0x10(%ebp)
  8007ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007cd:	50                   	push   %eax
  8007ce:	68 06 03 80 00       	push   $0x800306
  8007d3:	e8 70 fb ff ff       	call   800348 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007db:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e1:	83 c4 10             	add    $0x10,%esp
}
  8007e4:	c9                   	leave  
  8007e5:	c3                   	ret    
		return -E_INVAL;
  8007e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007eb:	eb f7                	jmp    8007e4 <vsnprintf+0x49>

008007ed <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ed:	f3 0f 1e fb          	endbr32 
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007fa:	50                   	push   %eax
  8007fb:	ff 75 10             	pushl  0x10(%ebp)
  8007fe:	ff 75 0c             	pushl  0xc(%ebp)
  800801:	ff 75 08             	pushl  0x8(%ebp)
  800804:	e8 92 ff ff ff       	call   80079b <vsnprintf>
	va_end(ap);

	return rc;
}
  800809:	c9                   	leave  
  80080a:	c3                   	ret    

0080080b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80080b:	f3 0f 1e fb          	endbr32 
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800815:	b8 00 00 00 00       	mov    $0x0,%eax
  80081a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80081e:	74 05                	je     800825 <strlen+0x1a>
		n++;
  800820:	83 c0 01             	add    $0x1,%eax
  800823:	eb f5                	jmp    80081a <strlen+0xf>
	return n;
}
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800827:	f3 0f 1e fb          	endbr32 
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800831:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800834:	b8 00 00 00 00       	mov    $0x0,%eax
  800839:	39 d0                	cmp    %edx,%eax
  80083b:	74 0d                	je     80084a <strnlen+0x23>
  80083d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800841:	74 05                	je     800848 <strnlen+0x21>
		n++;
  800843:	83 c0 01             	add    $0x1,%eax
  800846:	eb f1                	jmp    800839 <strnlen+0x12>
  800848:	89 c2                	mov    %eax,%edx
	return n;
}
  80084a:	89 d0                	mov    %edx,%eax
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80084e:	f3 0f 1e fb          	endbr32 
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	53                   	push   %ebx
  800856:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800859:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80085c:	b8 00 00 00 00       	mov    $0x0,%eax
  800861:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800865:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800868:	83 c0 01             	add    $0x1,%eax
  80086b:	84 d2                	test   %dl,%dl
  80086d:	75 f2                	jne    800861 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80086f:	89 c8                	mov    %ecx,%eax
  800871:	5b                   	pop    %ebx
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800874:	f3 0f 1e fb          	endbr32 
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	53                   	push   %ebx
  80087c:	83 ec 10             	sub    $0x10,%esp
  80087f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800882:	53                   	push   %ebx
  800883:	e8 83 ff ff ff       	call   80080b <strlen>
  800888:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80088b:	ff 75 0c             	pushl  0xc(%ebp)
  80088e:	01 d8                	add    %ebx,%eax
  800890:	50                   	push   %eax
  800891:	e8 b8 ff ff ff       	call   80084e <strcpy>
	return dst;
}
  800896:	89 d8                	mov    %ebx,%eax
  800898:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089b:	c9                   	leave  
  80089c:	c3                   	ret    

0080089d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80089d:	f3 0f 1e fb          	endbr32 
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	56                   	push   %esi
  8008a5:	53                   	push   %ebx
  8008a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ac:	89 f3                	mov    %esi,%ebx
  8008ae:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b1:	89 f0                	mov    %esi,%eax
  8008b3:	39 d8                	cmp    %ebx,%eax
  8008b5:	74 11                	je     8008c8 <strncpy+0x2b>
		*dst++ = *src;
  8008b7:	83 c0 01             	add    $0x1,%eax
  8008ba:	0f b6 0a             	movzbl (%edx),%ecx
  8008bd:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c0:	80 f9 01             	cmp    $0x1,%cl
  8008c3:	83 da ff             	sbb    $0xffffffff,%edx
  8008c6:	eb eb                	jmp    8008b3 <strncpy+0x16>
	}
	return ret;
}
  8008c8:	89 f0                	mov    %esi,%eax
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ce:	f3 0f 1e fb          	endbr32 
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	56                   	push   %esi
  8008d6:	53                   	push   %ebx
  8008d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008dd:	8b 55 10             	mov    0x10(%ebp),%edx
  8008e0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e2:	85 d2                	test   %edx,%edx
  8008e4:	74 21                	je     800907 <strlcpy+0x39>
  8008e6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008ea:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008ec:	39 c2                	cmp    %eax,%edx
  8008ee:	74 14                	je     800904 <strlcpy+0x36>
  8008f0:	0f b6 19             	movzbl (%ecx),%ebx
  8008f3:	84 db                	test   %bl,%bl
  8008f5:	74 0b                	je     800902 <strlcpy+0x34>
			*dst++ = *src++;
  8008f7:	83 c1 01             	add    $0x1,%ecx
  8008fa:	83 c2 01             	add    $0x1,%edx
  8008fd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800900:	eb ea                	jmp    8008ec <strlcpy+0x1e>
  800902:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800904:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800907:	29 f0                	sub    %esi,%eax
}
  800909:	5b                   	pop    %ebx
  80090a:	5e                   	pop    %esi
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80090d:	f3 0f 1e fb          	endbr32 
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800917:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80091a:	0f b6 01             	movzbl (%ecx),%eax
  80091d:	84 c0                	test   %al,%al
  80091f:	74 0c                	je     80092d <strcmp+0x20>
  800921:	3a 02                	cmp    (%edx),%al
  800923:	75 08                	jne    80092d <strcmp+0x20>
		p++, q++;
  800925:	83 c1 01             	add    $0x1,%ecx
  800928:	83 c2 01             	add    $0x1,%edx
  80092b:	eb ed                	jmp    80091a <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80092d:	0f b6 c0             	movzbl %al,%eax
  800930:	0f b6 12             	movzbl (%edx),%edx
  800933:	29 d0                	sub    %edx,%eax
}
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800937:	f3 0f 1e fb          	endbr32 
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	53                   	push   %ebx
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	8b 55 0c             	mov    0xc(%ebp),%edx
  800945:	89 c3                	mov    %eax,%ebx
  800947:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80094a:	eb 06                	jmp    800952 <strncmp+0x1b>
		n--, p++, q++;
  80094c:	83 c0 01             	add    $0x1,%eax
  80094f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800952:	39 d8                	cmp    %ebx,%eax
  800954:	74 16                	je     80096c <strncmp+0x35>
  800956:	0f b6 08             	movzbl (%eax),%ecx
  800959:	84 c9                	test   %cl,%cl
  80095b:	74 04                	je     800961 <strncmp+0x2a>
  80095d:	3a 0a                	cmp    (%edx),%cl
  80095f:	74 eb                	je     80094c <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800961:	0f b6 00             	movzbl (%eax),%eax
  800964:	0f b6 12             	movzbl (%edx),%edx
  800967:	29 d0                	sub    %edx,%eax
}
  800969:	5b                   	pop    %ebx
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    
		return 0;
  80096c:	b8 00 00 00 00       	mov    $0x0,%eax
  800971:	eb f6                	jmp    800969 <strncmp+0x32>

00800973 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800973:	f3 0f 1e fb          	endbr32 
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800981:	0f b6 10             	movzbl (%eax),%edx
  800984:	84 d2                	test   %dl,%dl
  800986:	74 09                	je     800991 <strchr+0x1e>
		if (*s == c)
  800988:	38 ca                	cmp    %cl,%dl
  80098a:	74 0a                	je     800996 <strchr+0x23>
	for (; *s; s++)
  80098c:	83 c0 01             	add    $0x1,%eax
  80098f:	eb f0                	jmp    800981 <strchr+0xe>
			return (char *) s;
	return 0;
  800991:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800998:	f3 0f 1e fb          	endbr32 
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009a9:	38 ca                	cmp    %cl,%dl
  8009ab:	74 09                	je     8009b6 <strfind+0x1e>
  8009ad:	84 d2                	test   %dl,%dl
  8009af:	74 05                	je     8009b6 <strfind+0x1e>
	for (; *s; s++)
  8009b1:	83 c0 01             	add    $0x1,%eax
  8009b4:	eb f0                	jmp    8009a6 <strfind+0xe>
			break;
	return (char *) s;
}
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b8:	f3 0f 1e fb          	endbr32 
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	57                   	push   %edi
  8009c0:	56                   	push   %esi
  8009c1:	53                   	push   %ebx
  8009c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c8:	85 c9                	test   %ecx,%ecx
  8009ca:	74 31                	je     8009fd <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009cc:	89 f8                	mov    %edi,%eax
  8009ce:	09 c8                	or     %ecx,%eax
  8009d0:	a8 03                	test   $0x3,%al
  8009d2:	75 23                	jne    8009f7 <memset+0x3f>
		c &= 0xFF;
  8009d4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d8:	89 d3                	mov    %edx,%ebx
  8009da:	c1 e3 08             	shl    $0x8,%ebx
  8009dd:	89 d0                	mov    %edx,%eax
  8009df:	c1 e0 18             	shl    $0x18,%eax
  8009e2:	89 d6                	mov    %edx,%esi
  8009e4:	c1 e6 10             	shl    $0x10,%esi
  8009e7:	09 f0                	or     %esi,%eax
  8009e9:	09 c2                	or     %eax,%edx
  8009eb:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ed:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009f0:	89 d0                	mov    %edx,%eax
  8009f2:	fc                   	cld    
  8009f3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f5:	eb 06                	jmp    8009fd <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fa:	fc                   	cld    
  8009fb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009fd:	89 f8                	mov    %edi,%eax
  8009ff:	5b                   	pop    %ebx
  800a00:	5e                   	pop    %esi
  800a01:	5f                   	pop    %edi
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a04:	f3 0f 1e fb          	endbr32 
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	57                   	push   %edi
  800a0c:	56                   	push   %esi
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a13:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a16:	39 c6                	cmp    %eax,%esi
  800a18:	73 32                	jae    800a4c <memmove+0x48>
  800a1a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a1d:	39 c2                	cmp    %eax,%edx
  800a1f:	76 2b                	jbe    800a4c <memmove+0x48>
		s += n;
		d += n;
  800a21:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a24:	89 fe                	mov    %edi,%esi
  800a26:	09 ce                	or     %ecx,%esi
  800a28:	09 d6                	or     %edx,%esi
  800a2a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a30:	75 0e                	jne    800a40 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a32:	83 ef 04             	sub    $0x4,%edi
  800a35:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a38:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a3b:	fd                   	std    
  800a3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3e:	eb 09                	jmp    800a49 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a40:	83 ef 01             	sub    $0x1,%edi
  800a43:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a46:	fd                   	std    
  800a47:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a49:	fc                   	cld    
  800a4a:	eb 1a                	jmp    800a66 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4c:	89 c2                	mov    %eax,%edx
  800a4e:	09 ca                	or     %ecx,%edx
  800a50:	09 f2                	or     %esi,%edx
  800a52:	f6 c2 03             	test   $0x3,%dl
  800a55:	75 0a                	jne    800a61 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a57:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a5a:	89 c7                	mov    %eax,%edi
  800a5c:	fc                   	cld    
  800a5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5f:	eb 05                	jmp    800a66 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a61:	89 c7                	mov    %eax,%edi
  800a63:	fc                   	cld    
  800a64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a66:	5e                   	pop    %esi
  800a67:	5f                   	pop    %edi
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a6a:	f3 0f 1e fb          	endbr32 
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a74:	ff 75 10             	pushl  0x10(%ebp)
  800a77:	ff 75 0c             	pushl  0xc(%ebp)
  800a7a:	ff 75 08             	pushl  0x8(%ebp)
  800a7d:	e8 82 ff ff ff       	call   800a04 <memmove>
}
  800a82:	c9                   	leave  
  800a83:	c3                   	ret    

00800a84 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a84:	f3 0f 1e fb          	endbr32 
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a93:	89 c6                	mov    %eax,%esi
  800a95:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a98:	39 f0                	cmp    %esi,%eax
  800a9a:	74 1c                	je     800ab8 <memcmp+0x34>
		if (*s1 != *s2)
  800a9c:	0f b6 08             	movzbl (%eax),%ecx
  800a9f:	0f b6 1a             	movzbl (%edx),%ebx
  800aa2:	38 d9                	cmp    %bl,%cl
  800aa4:	75 08                	jne    800aae <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800aa6:	83 c0 01             	add    $0x1,%eax
  800aa9:	83 c2 01             	add    $0x1,%edx
  800aac:	eb ea                	jmp    800a98 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800aae:	0f b6 c1             	movzbl %cl,%eax
  800ab1:	0f b6 db             	movzbl %bl,%ebx
  800ab4:	29 d8                	sub    %ebx,%eax
  800ab6:	eb 05                	jmp    800abd <memcmp+0x39>
	}

	return 0;
  800ab8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac1:	f3 0f 1e fb          	endbr32 
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  800acb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ace:	89 c2                	mov    %eax,%edx
  800ad0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ad3:	39 d0                	cmp    %edx,%eax
  800ad5:	73 09                	jae    800ae0 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad7:	38 08                	cmp    %cl,(%eax)
  800ad9:	74 05                	je     800ae0 <memfind+0x1f>
	for (; s < ends; s++)
  800adb:	83 c0 01             	add    $0x1,%eax
  800ade:	eb f3                	jmp    800ad3 <memfind+0x12>
			break;
	return (void *) s;
}
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae2:	f3 0f 1e fb          	endbr32 
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	57                   	push   %edi
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
  800aec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af2:	eb 03                	jmp    800af7 <strtol+0x15>
		s++;
  800af4:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800af7:	0f b6 01             	movzbl (%ecx),%eax
  800afa:	3c 20                	cmp    $0x20,%al
  800afc:	74 f6                	je     800af4 <strtol+0x12>
  800afe:	3c 09                	cmp    $0x9,%al
  800b00:	74 f2                	je     800af4 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b02:	3c 2b                	cmp    $0x2b,%al
  800b04:	74 2a                	je     800b30 <strtol+0x4e>
	int neg = 0;
  800b06:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b0b:	3c 2d                	cmp    $0x2d,%al
  800b0d:	74 2b                	je     800b3a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b0f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b15:	75 0f                	jne    800b26 <strtol+0x44>
  800b17:	80 39 30             	cmpb   $0x30,(%ecx)
  800b1a:	74 28                	je     800b44 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b1c:	85 db                	test   %ebx,%ebx
  800b1e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b23:	0f 44 d8             	cmove  %eax,%ebx
  800b26:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b2e:	eb 46                	jmp    800b76 <strtol+0x94>
		s++;
  800b30:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b33:	bf 00 00 00 00       	mov    $0x0,%edi
  800b38:	eb d5                	jmp    800b0f <strtol+0x2d>
		s++, neg = 1;
  800b3a:	83 c1 01             	add    $0x1,%ecx
  800b3d:	bf 01 00 00 00       	mov    $0x1,%edi
  800b42:	eb cb                	jmp    800b0f <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b44:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b48:	74 0e                	je     800b58 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b4a:	85 db                	test   %ebx,%ebx
  800b4c:	75 d8                	jne    800b26 <strtol+0x44>
		s++, base = 8;
  800b4e:	83 c1 01             	add    $0x1,%ecx
  800b51:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b56:	eb ce                	jmp    800b26 <strtol+0x44>
		s += 2, base = 16;
  800b58:	83 c1 02             	add    $0x2,%ecx
  800b5b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b60:	eb c4                	jmp    800b26 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b62:	0f be d2             	movsbl %dl,%edx
  800b65:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b68:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b6b:	7d 3a                	jge    800ba7 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b6d:	83 c1 01             	add    $0x1,%ecx
  800b70:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b74:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b76:	0f b6 11             	movzbl (%ecx),%edx
  800b79:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b7c:	89 f3                	mov    %esi,%ebx
  800b7e:	80 fb 09             	cmp    $0x9,%bl
  800b81:	76 df                	jbe    800b62 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b83:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b86:	89 f3                	mov    %esi,%ebx
  800b88:	80 fb 19             	cmp    $0x19,%bl
  800b8b:	77 08                	ja     800b95 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b8d:	0f be d2             	movsbl %dl,%edx
  800b90:	83 ea 57             	sub    $0x57,%edx
  800b93:	eb d3                	jmp    800b68 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b95:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b98:	89 f3                	mov    %esi,%ebx
  800b9a:	80 fb 19             	cmp    $0x19,%bl
  800b9d:	77 08                	ja     800ba7 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b9f:	0f be d2             	movsbl %dl,%edx
  800ba2:	83 ea 37             	sub    $0x37,%edx
  800ba5:	eb c1                	jmp    800b68 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ba7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bab:	74 05                	je     800bb2 <strtol+0xd0>
		*endptr = (char *) s;
  800bad:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bb2:	89 c2                	mov    %eax,%edx
  800bb4:	f7 da                	neg    %edx
  800bb6:	85 ff                	test   %edi,%edi
  800bb8:	0f 45 c2             	cmovne %edx,%eax
}
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5f                   	pop    %edi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bc0:	f3 0f 1e fb          	endbr32 
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bca:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd5:	89 c3                	mov    %eax,%ebx
  800bd7:	89 c7                	mov    %eax,%edi
  800bd9:	89 c6                	mov    %eax,%esi
  800bdb:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800be2:	f3 0f 1e fb          	endbr32 
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bec:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf1:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf6:	89 d1                	mov    %edx,%ecx
  800bf8:	89 d3                	mov    %edx,%ebx
  800bfa:	89 d7                	mov    %edx,%edi
  800bfc:	89 d6                	mov    %edx,%esi
  800bfe:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c05:	f3 0f 1e fb          	endbr32 
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
  800c0f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1a:	b8 03 00 00 00       	mov    $0x3,%eax
  800c1f:	89 cb                	mov    %ecx,%ebx
  800c21:	89 cf                	mov    %ecx,%edi
  800c23:	89 ce                	mov    %ecx,%esi
  800c25:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c27:	85 c0                	test   %eax,%eax
  800c29:	7f 08                	jg     800c33 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c33:	83 ec 0c             	sub    $0xc,%esp
  800c36:	50                   	push   %eax
  800c37:	6a 03                	push   $0x3
  800c39:	68 44 17 80 00       	push   $0x801744
  800c3e:	6a 23                	push   $0x23
  800c40:	68 61 17 80 00       	push   $0x801761
  800c45:	e8 14 f5 ff ff       	call   80015e <_panic>

00800c4a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c4a:	f3 0f 1e fb          	endbr32 
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	57                   	push   %edi
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c54:	ba 00 00 00 00       	mov    $0x0,%edx
  800c59:	b8 02 00 00 00       	mov    $0x2,%eax
  800c5e:	89 d1                	mov    %edx,%ecx
  800c60:	89 d3                	mov    %edx,%ebx
  800c62:	89 d7                	mov    %edx,%edi
  800c64:	89 d6                	mov    %edx,%esi
  800c66:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <sys_yield>:

void
sys_yield(void)
{
  800c6d:	f3 0f 1e fb          	endbr32 
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	57                   	push   %edi
  800c75:	56                   	push   %esi
  800c76:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c77:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c81:	89 d1                	mov    %edx,%ecx
  800c83:	89 d3                	mov    %edx,%ebx
  800c85:	89 d7                	mov    %edx,%edi
  800c87:	89 d6                	mov    %edx,%esi
  800c89:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c90:	f3 0f 1e fb          	endbr32 
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9d:	be 00 00 00 00       	mov    $0x0,%esi
  800ca2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca8:	b8 04 00 00 00       	mov    $0x4,%eax
  800cad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb0:	89 f7                	mov    %esi,%edi
  800cb2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	7f 08                	jg     800cc0 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 04                	push   $0x4
  800cc6:	68 44 17 80 00       	push   $0x801744
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 61 17 80 00       	push   $0x801761
  800cd2:	e8 87 f4 ff ff       	call   80015e <_panic>

00800cd7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd7:	f3 0f 1e fb          	endbr32 
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
  800ce1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cea:	b8 05 00 00 00       	mov    $0x5,%eax
  800cef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf5:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7f 08                	jg     800d06 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d06:	83 ec 0c             	sub    $0xc,%esp
  800d09:	50                   	push   %eax
  800d0a:	6a 05                	push   $0x5
  800d0c:	68 44 17 80 00       	push   $0x801744
  800d11:	6a 23                	push   $0x23
  800d13:	68 61 17 80 00       	push   $0x801761
  800d18:	e8 41 f4 ff ff       	call   80015e <_panic>

00800d1d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d1d:	f3 0f 1e fb          	endbr32 
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
  800d27:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d35:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3a:	89 df                	mov    %ebx,%edi
  800d3c:	89 de                	mov    %ebx,%esi
  800d3e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d40:	85 c0                	test   %eax,%eax
  800d42:	7f 08                	jg     800d4c <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4c:	83 ec 0c             	sub    $0xc,%esp
  800d4f:	50                   	push   %eax
  800d50:	6a 06                	push   $0x6
  800d52:	68 44 17 80 00       	push   $0x801744
  800d57:	6a 23                	push   $0x23
  800d59:	68 61 17 80 00       	push   $0x801761
  800d5e:	e8 fb f3 ff ff       	call   80015e <_panic>

00800d63 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d63:	f3 0f 1e fb          	endbr32 
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
  800d6d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d75:	8b 55 08             	mov    0x8(%ebp),%edx
  800d78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d80:	89 df                	mov    %ebx,%edi
  800d82:	89 de                	mov    %ebx,%esi
  800d84:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d86:	85 c0                	test   %eax,%eax
  800d88:	7f 08                	jg     800d92 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d92:	83 ec 0c             	sub    $0xc,%esp
  800d95:	50                   	push   %eax
  800d96:	6a 08                	push   $0x8
  800d98:	68 44 17 80 00       	push   $0x801744
  800d9d:	6a 23                	push   $0x23
  800d9f:	68 61 17 80 00       	push   $0x801761
  800da4:	e8 b5 f3 ff ff       	call   80015e <_panic>

00800da9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da9:	f3 0f 1e fb          	endbr32 
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc1:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc6:	89 df                	mov    %ebx,%edi
  800dc8:	89 de                	mov    %ebx,%esi
  800dca:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	7f 08                	jg     800dd8 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd8:	83 ec 0c             	sub    $0xc,%esp
  800ddb:	50                   	push   %eax
  800ddc:	6a 09                	push   $0x9
  800dde:	68 44 17 80 00       	push   $0x801744
  800de3:	6a 23                	push   $0x23
  800de5:	68 61 17 80 00       	push   $0x801761
  800dea:	e8 6f f3 ff ff       	call   80015e <_panic>

00800def <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800def:	f3 0f 1e fb          	endbr32 
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	57                   	push   %edi
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800df9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dff:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e04:	be 00 00 00 00       	mov    $0x0,%esi
  800e09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e0f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e16:	f3 0f 1e fb          	endbr32 
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	57                   	push   %edi
  800e1e:	56                   	push   %esi
  800e1f:	53                   	push   %ebx
  800e20:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e23:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e28:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e30:	89 cb                	mov    %ecx,%ebx
  800e32:	89 cf                	mov    %ecx,%edi
  800e34:	89 ce                	mov    %ecx,%esi
  800e36:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e38:	85 c0                	test   %eax,%eax
  800e3a:	7f 08                	jg     800e44 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3f:	5b                   	pop    %ebx
  800e40:	5e                   	pop    %esi
  800e41:	5f                   	pop    %edi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e44:	83 ec 0c             	sub    $0xc,%esp
  800e47:	50                   	push   %eax
  800e48:	6a 0c                	push   $0xc
  800e4a:	68 44 17 80 00       	push   $0x801744
  800e4f:	6a 23                	push   $0x23
  800e51:	68 61 17 80 00       	push   $0x801761
  800e56:	e8 03 f3 ff ff       	call   80015e <_panic>

00800e5b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e5b:	f3 0f 1e fb          	endbr32 
  800e5f:	55                   	push   %ebp
  800e60:	89 e5                	mov    %esp,%ebp
  800e62:	53                   	push   %ebx
  800e63:	83 ec 04             	sub    $0x4,%esp
  800e66:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e69:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if ( !(err & FEC_WR) ||
  800e6b:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e6f:	74 75                	je     800ee6 <pgfault+0x8b>
            !(uvpt[PGNUM(addr)] | PTE_COW) ) {
  800e71:	89 d8                	mov    %ebx,%eax
  800e73:	c1 e8 0c             	shr    $0xc,%eax
  800e76:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0) {
  800e7d:	83 ec 04             	sub    $0x4,%esp
  800e80:	6a 07                	push   $0x7
  800e82:	68 00 f0 7f 00       	push   $0x7ff000
  800e87:	6a 00                	push   $0x0
  800e89:	e8 02 fe ff ff       	call   800c90 <sys_page_alloc>
  800e8e:	83 c4 10             	add    $0x10,%esp
  800e91:	85 c0                	test   %eax,%eax
  800e93:	78 65                	js     800efa <pgfault+0x9f>
        panic("sys_page_alloc failed %e\n", r);
    }
    memmove((void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);
  800e95:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800e9b:	83 ec 04             	sub    $0x4,%esp
  800e9e:	68 00 10 00 00       	push   $0x1000
  800ea3:	53                   	push   %ebx
  800ea4:	68 00 f0 7f 00       	push   $0x7ff000
  800ea9:	e8 56 fb ff ff       	call   800a04 <memmove>
    if ((r = sys_page_map(0, (void *)PFTEMP,
  800eae:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eb5:	53                   	push   %ebx
  800eb6:	6a 00                	push   $0x0
  800eb8:	68 00 f0 7f 00       	push   $0x7ff000
  800ebd:	6a 00                	push   $0x0
  800ebf:	e8 13 fe ff ff       	call   800cd7 <sys_page_map>
  800ec4:	83 c4 20             	add    $0x20,%esp
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	78 41                	js     800f0c <pgfault+0xb1>
                0, (void *)PTE_ADDR(addr), PTE_P | PTE_U | PTE_W)) < 0) {
        panic("sys_page_map failed %e\n", r);
    }
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0) {
  800ecb:	83 ec 08             	sub    $0x8,%esp
  800ece:	68 00 f0 7f 00       	push   $0x7ff000
  800ed3:	6a 00                	push   $0x0
  800ed5:	e8 43 fe ff ff       	call   800d1d <sys_page_unmap>
  800eda:	83 c4 10             	add    $0x10,%esp
  800edd:	85 c0                	test   %eax,%eax
  800edf:	78 3d                	js     800f1e <pgfault+0xc3>
        panic("sys_page_unmap failed %e\n", r);
    }

}
  800ee1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee4:	c9                   	leave  
  800ee5:	c3                   	ret    
        panic("Not a copy-on-write page");
  800ee6:	83 ec 04             	sub    $0x4,%esp
  800ee9:	68 6f 17 80 00       	push   $0x80176f
  800eee:	6a 1e                	push   $0x1e
  800ef0:	68 88 17 80 00       	push   $0x801788
  800ef5:	e8 64 f2 ff ff       	call   80015e <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800efa:	50                   	push   %eax
  800efb:	68 93 17 80 00       	push   $0x801793
  800f00:	6a 2a                	push   $0x2a
  800f02:	68 88 17 80 00       	push   $0x801788
  800f07:	e8 52 f2 ff ff       	call   80015e <_panic>
        panic("sys_page_map failed %e\n", r);
  800f0c:	50                   	push   %eax
  800f0d:	68 ad 17 80 00       	push   $0x8017ad
  800f12:	6a 2f                	push   $0x2f
  800f14:	68 88 17 80 00       	push   $0x801788
  800f19:	e8 40 f2 ff ff       	call   80015e <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800f1e:	50                   	push   %eax
  800f1f:	68 c5 17 80 00       	push   $0x8017c5
  800f24:	6a 32                	push   $0x32
  800f26:	68 88 17 80 00       	push   $0x801788
  800f2b:	e8 2e f2 ff ff       	call   80015e <_panic>

00800f30 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f30:	f3 0f 1e fb          	endbr32 
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	57                   	push   %edi
  800f38:	56                   	push   %esi
  800f39:	53                   	push   %ebx
  800f3a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");

    // 1. set pgfault handler.
    set_pgfault_handler(pgfault);
  800f3d:	68 5b 0e 80 00       	push   $0x800e5b
  800f42:	e8 4f 02 00 00       	call   801196 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f47:	b8 07 00 00 00       	mov    $0x7,%eax
  800f4c:	cd 30                	int    $0x30
  800f4e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f51:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 2. exofork.
    envid_t envid = sys_exofork();

    if (envid < 0)
  800f54:	83 c4 10             	add    $0x10,%esp
  800f57:	85 c0                	test   %eax,%eax
  800f59:	78 2a                	js     800f85 <fork+0x55>
        thisenv = &envs[ENVX(my_envid)];
        return 0;
    }
    else {
        // parent
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800f5b:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800f60:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f64:	75 4e                	jne    800fb4 <fork+0x84>
        envid_t my_envid = sys_getenvid();
  800f66:	e8 df fc ff ff       	call   800c4a <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800f6b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f70:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f73:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f78:	a3 04 20 80 00       	mov    %eax,0x802004
        return 0;
  800f7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f80:	e9 f1 00 00 00       	jmp    801076 <fork+0x146>
        panic("fork, sys_exofork %e", envid);
  800f85:	50                   	push   %eax
  800f86:	68 df 17 80 00       	push   $0x8017df
  800f8b:	6a 7b                	push   $0x7b
  800f8d:	68 88 17 80 00       	push   $0x801788
  800f92:	e8 c7 f1 ff ff       	call   80015e <_panic>
        panic("sys_page_map others failed %e\n", r);
  800f97:	50                   	push   %eax
  800f98:	68 28 18 80 00       	push   $0x801828
  800f9d:	6a 51                	push   $0x51
  800f9f:	68 88 17 80 00       	push   $0x801788
  800fa4:	e8 b5 f1 ff ff       	call   80015e <_panic>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800fa9:	83 c3 01             	add    $0x1,%ebx
  800fac:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800fb2:	74 7c                	je     801030 <fork+0x100>
  800fb4:	89 de                	mov    %ebx,%esi
  800fb6:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800fb9:	89 f0                	mov    %esi,%eax
  800fbb:	c1 e8 16             	shr    $0x16,%eax
  800fbe:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc5:	a8 01                	test   $0x1,%al
  800fc7:	74 e0                	je     800fa9 <fork+0x79>
                    (uvpt[pn] & PTE_P) ) {
  800fc9:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  800fd0:	a8 01                	test   $0x1,%al
  800fd2:	74 d5                	je     800fa9 <fork+0x79>
    pte_t pte = uvpt[pn];
  800fd4:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    if ( (pte & PTE_W) || (pte & PTE_COW) ) {
  800fdb:	25 02 08 00 00       	and    $0x802,%eax
        perm |= PTE_COW;
  800fe0:	83 f8 01             	cmp    $0x1,%eax
  800fe3:	19 ff                	sbb    %edi,%edi
  800fe5:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  800feb:	81 c7 05 08 00 00    	add    $0x805,%edi
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	57                   	push   %edi
  800ff5:	56                   	push   %esi
  800ff6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff9:	56                   	push   %esi
  800ffa:	6a 00                	push   $0x0
  800ffc:	e8 d6 fc ff ff       	call   800cd7 <sys_page_map>
  801001:	83 c4 20             	add    $0x20,%esp
  801004:	85 c0                	test   %eax,%eax
  801006:	78 8f                	js     800f97 <fork+0x67>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	57                   	push   %edi
  80100c:	56                   	push   %esi
  80100d:	6a 00                	push   $0x0
  80100f:	56                   	push   %esi
  801010:	6a 00                	push   $0x0
  801012:	e8 c0 fc ff ff       	call   800cd7 <sys_page_map>
  801017:	83 c4 20             	add    $0x20,%esp
  80101a:	85 c0                	test   %eax,%eax
  80101c:	79 8b                	jns    800fa9 <fork+0x79>
            panic("sys_page_map mine failed %e\n", r);
  80101e:	50                   	push   %eax
  80101f:	68 f4 17 80 00       	push   $0x8017f4
  801024:	6a 56                	push   $0x56
  801026:	68 88 17 80 00       	push   $0x801788
  80102b:	e8 2e f1 ff ff       	call   80015e <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  801030:	83 ec 04             	sub    $0x4,%esp
  801033:	6a 07                	push   $0x7
  801035:	68 00 f0 bf ee       	push   $0xeebff000
  80103a:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80103d:	57                   	push   %edi
  80103e:	e8 4d fc ff ff       	call   800c90 <sys_page_alloc>
  801043:	83 c4 10             	add    $0x10,%esp
  801046:	85 c0                	test   %eax,%eax
  801048:	78 2c                	js     801076 <fork+0x146>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  80104a:	a1 04 20 80 00       	mov    0x802004,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  80104f:	8b 40 64             	mov    0x64(%eax),%eax
  801052:	83 ec 08             	sub    $0x8,%esp
  801055:	50                   	push   %eax
  801056:	57                   	push   %edi
  801057:	e8 4d fd ff ff       	call   800da9 <sys_env_set_pgfault_upcall>
  80105c:	83 c4 10             	add    $0x10,%esp
  80105f:	85 c0                	test   %eax,%eax
  801061:	78 13                	js     801076 <fork+0x146>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801063:	83 ec 08             	sub    $0x8,%esp
  801066:	6a 02                	push   $0x2
  801068:	57                   	push   %edi
  801069:	e8 f5 fc ff ff       	call   800d63 <sys_env_set_status>
  80106e:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  801071:	85 c0                	test   %eax,%eax
  801073:	0f 49 c7             	cmovns %edi,%eax
    }

}
  801076:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801079:	5b                   	pop    %ebx
  80107a:	5e                   	pop    %esi
  80107b:	5f                   	pop    %edi
  80107c:	5d                   	pop    %ebp
  80107d:	c3                   	ret    

0080107e <sfork>:

// Challenge!
int
sfork(void)
{
  80107e:	f3 0f 1e fb          	endbr32 
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801088:	68 11 18 80 00       	push   $0x801811
  80108d:	68 a5 00 00 00       	push   $0xa5
  801092:	68 88 17 80 00       	push   $0x801788
  801097:	e8 c2 f0 ff ff       	call   80015e <_panic>

0080109c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80109c:	f3 0f 1e fb          	endbr32 
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	56                   	push   %esi
  8010a4:	53                   	push   %ebx
  8010a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8010a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010ab:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8010b5:	0f 44 c2             	cmove  %edx,%eax
  8010b8:	83 ec 0c             	sub    $0xc,%esp
  8010bb:	50                   	push   %eax
  8010bc:	e8 55 fd ff ff       	call   800e16 <sys_ipc_recv>
  8010c1:	83 c4 10             	add    $0x10,%esp
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	78 24                	js     8010ec <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  8010c8:	85 f6                	test   %esi,%esi
  8010ca:	74 0a                	je     8010d6 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  8010cc:	a1 04 20 80 00       	mov    0x802004,%eax
  8010d1:	8b 40 78             	mov    0x78(%eax),%eax
  8010d4:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  8010d6:	85 db                	test   %ebx,%ebx
  8010d8:	74 0a                	je     8010e4 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  8010da:	a1 04 20 80 00       	mov    0x802004,%eax
  8010df:	8b 40 74             	mov    0x74(%eax),%eax
  8010e2:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  8010e4:	a1 04 20 80 00       	mov    0x802004,%eax
  8010e9:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ef:	5b                   	pop    %ebx
  8010f0:	5e                   	pop    %esi
  8010f1:	5d                   	pop    %ebp
  8010f2:	c3                   	ret    

008010f3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010f3:	f3 0f 1e fb          	endbr32 
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	57                   	push   %edi
  8010fb:	56                   	push   %esi
  8010fc:	53                   	push   %ebx
  8010fd:	83 ec 1c             	sub    $0x1c,%esp
  801100:	8b 45 10             	mov    0x10(%ebp),%eax
  801103:	85 c0                	test   %eax,%eax
  801105:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80110a:	0f 45 d0             	cmovne %eax,%edx
  80110d:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  80110f:	be 01 00 00 00       	mov    $0x1,%esi
  801114:	eb 1f                	jmp    801135 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801116:	e8 52 fb ff ff       	call   800c6d <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  80111b:	83 c3 01             	add    $0x1,%ebx
  80111e:	39 de                	cmp    %ebx,%esi
  801120:	7f f4                	jg     801116 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801122:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801124:	83 fe 11             	cmp    $0x11,%esi
  801127:	b8 01 00 00 00       	mov    $0x1,%eax
  80112c:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  80112f:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801133:	75 1c                	jne    801151 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801135:	ff 75 14             	pushl  0x14(%ebp)
  801138:	57                   	push   %edi
  801139:	ff 75 0c             	pushl  0xc(%ebp)
  80113c:	ff 75 08             	pushl  0x8(%ebp)
  80113f:	e8 ab fc ff ff       	call   800def <sys_ipc_try_send>
  801144:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801147:	83 c4 10             	add    $0x10,%esp
  80114a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114f:	eb cd                	jmp    80111e <ipc_send+0x2b>
}
  801151:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801154:	5b                   	pop    %ebx
  801155:	5e                   	pop    %esi
  801156:	5f                   	pop    %edi
  801157:	5d                   	pop    %ebp
  801158:	c3                   	ret    

00801159 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801159:	f3 0f 1e fb          	endbr32 
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
  801160:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801163:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801168:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80116b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801171:	8b 52 50             	mov    0x50(%edx),%edx
  801174:	39 ca                	cmp    %ecx,%edx
  801176:	74 11                	je     801189 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801178:	83 c0 01             	add    $0x1,%eax
  80117b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801180:	75 e6                	jne    801168 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801182:	b8 00 00 00 00       	mov    $0x0,%eax
  801187:	eb 0b                	jmp    801194 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801189:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80118c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801191:	8b 40 48             	mov    0x48(%eax),%eax
}
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    

00801196 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801196:	f3 0f 1e fb          	endbr32 
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8011a0:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8011a7:	74 0a                	je     8011b3 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ac:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8011b1:	c9                   	leave  
  8011b2:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  8011b3:	83 ec 0c             	sub    $0xc,%esp
  8011b6:	68 47 18 80 00       	push   $0x801847
  8011bb:	e8 85 f0 ff ff       	call   800245 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  8011c0:	83 c4 0c             	add    $0xc,%esp
  8011c3:	6a 07                	push   $0x7
  8011c5:	68 00 f0 bf ee       	push   $0xeebff000
  8011ca:	6a 00                	push   $0x0
  8011cc:	e8 bf fa ff ff       	call   800c90 <sys_page_alloc>
  8011d1:	83 c4 10             	add    $0x10,%esp
  8011d4:	85 c0                	test   %eax,%eax
  8011d6:	78 2a                	js     801202 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  8011d8:	83 ec 08             	sub    $0x8,%esp
  8011db:	68 16 12 80 00       	push   $0x801216
  8011e0:	6a 00                	push   $0x0
  8011e2:	e8 c2 fb ff ff       	call   800da9 <sys_env_set_pgfault_upcall>
  8011e7:	83 c4 10             	add    $0x10,%esp
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	79 bb                	jns    8011a9 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  8011ee:	83 ec 04             	sub    $0x4,%esp
  8011f1:	68 84 18 80 00       	push   $0x801884
  8011f6:	6a 25                	push   $0x25
  8011f8:	68 74 18 80 00       	push   $0x801874
  8011fd:	e8 5c ef ff ff       	call   80015e <_panic>
            panic("Allocation of UXSTACK failed!");
  801202:	83 ec 04             	sub    $0x4,%esp
  801205:	68 56 18 80 00       	push   $0x801856
  80120a:	6a 22                	push   $0x22
  80120c:	68 74 18 80 00       	push   $0x801874
  801211:	e8 48 ef ff ff       	call   80015e <_panic>

00801216 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801216:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801217:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80121c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80121e:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  801221:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  801225:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  801229:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  80122c:	83 c4 08             	add    $0x8,%esp
    popa
  80122f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $0x4, %esp
  801230:	83 c4 04             	add    $0x4,%esp
    popf
  801233:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  801234:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  801237:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  80123b:	c3                   	ret    
  80123c:	66 90                	xchg   %ax,%ax
  80123e:	66 90                	xchg   %ax,%ax

00801240 <__udivdi3>:
  801240:	f3 0f 1e fb          	endbr32 
  801244:	55                   	push   %ebp
  801245:	57                   	push   %edi
  801246:	56                   	push   %esi
  801247:	53                   	push   %ebx
  801248:	83 ec 1c             	sub    $0x1c,%esp
  80124b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80124f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801253:	8b 74 24 34          	mov    0x34(%esp),%esi
  801257:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80125b:	85 d2                	test   %edx,%edx
  80125d:	75 19                	jne    801278 <__udivdi3+0x38>
  80125f:	39 f3                	cmp    %esi,%ebx
  801261:	76 4d                	jbe    8012b0 <__udivdi3+0x70>
  801263:	31 ff                	xor    %edi,%edi
  801265:	89 e8                	mov    %ebp,%eax
  801267:	89 f2                	mov    %esi,%edx
  801269:	f7 f3                	div    %ebx
  80126b:	89 fa                	mov    %edi,%edx
  80126d:	83 c4 1c             	add    $0x1c,%esp
  801270:	5b                   	pop    %ebx
  801271:	5e                   	pop    %esi
  801272:	5f                   	pop    %edi
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    
  801275:	8d 76 00             	lea    0x0(%esi),%esi
  801278:	39 f2                	cmp    %esi,%edx
  80127a:	76 14                	jbe    801290 <__udivdi3+0x50>
  80127c:	31 ff                	xor    %edi,%edi
  80127e:	31 c0                	xor    %eax,%eax
  801280:	89 fa                	mov    %edi,%edx
  801282:	83 c4 1c             	add    $0x1c,%esp
  801285:	5b                   	pop    %ebx
  801286:	5e                   	pop    %esi
  801287:	5f                   	pop    %edi
  801288:	5d                   	pop    %ebp
  801289:	c3                   	ret    
  80128a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801290:	0f bd fa             	bsr    %edx,%edi
  801293:	83 f7 1f             	xor    $0x1f,%edi
  801296:	75 48                	jne    8012e0 <__udivdi3+0xa0>
  801298:	39 f2                	cmp    %esi,%edx
  80129a:	72 06                	jb     8012a2 <__udivdi3+0x62>
  80129c:	31 c0                	xor    %eax,%eax
  80129e:	39 eb                	cmp    %ebp,%ebx
  8012a0:	77 de                	ja     801280 <__udivdi3+0x40>
  8012a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8012a7:	eb d7                	jmp    801280 <__udivdi3+0x40>
  8012a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012b0:	89 d9                	mov    %ebx,%ecx
  8012b2:	85 db                	test   %ebx,%ebx
  8012b4:	75 0b                	jne    8012c1 <__udivdi3+0x81>
  8012b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8012bb:	31 d2                	xor    %edx,%edx
  8012bd:	f7 f3                	div    %ebx
  8012bf:	89 c1                	mov    %eax,%ecx
  8012c1:	31 d2                	xor    %edx,%edx
  8012c3:	89 f0                	mov    %esi,%eax
  8012c5:	f7 f1                	div    %ecx
  8012c7:	89 c6                	mov    %eax,%esi
  8012c9:	89 e8                	mov    %ebp,%eax
  8012cb:	89 f7                	mov    %esi,%edi
  8012cd:	f7 f1                	div    %ecx
  8012cf:	89 fa                	mov    %edi,%edx
  8012d1:	83 c4 1c             	add    $0x1c,%esp
  8012d4:	5b                   	pop    %ebx
  8012d5:	5e                   	pop    %esi
  8012d6:	5f                   	pop    %edi
  8012d7:	5d                   	pop    %ebp
  8012d8:	c3                   	ret    
  8012d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012e0:	89 f9                	mov    %edi,%ecx
  8012e2:	b8 20 00 00 00       	mov    $0x20,%eax
  8012e7:	29 f8                	sub    %edi,%eax
  8012e9:	d3 e2                	shl    %cl,%edx
  8012eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012ef:	89 c1                	mov    %eax,%ecx
  8012f1:	89 da                	mov    %ebx,%edx
  8012f3:	d3 ea                	shr    %cl,%edx
  8012f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8012f9:	09 d1                	or     %edx,%ecx
  8012fb:	89 f2                	mov    %esi,%edx
  8012fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801301:	89 f9                	mov    %edi,%ecx
  801303:	d3 e3                	shl    %cl,%ebx
  801305:	89 c1                	mov    %eax,%ecx
  801307:	d3 ea                	shr    %cl,%edx
  801309:	89 f9                	mov    %edi,%ecx
  80130b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80130f:	89 eb                	mov    %ebp,%ebx
  801311:	d3 e6                	shl    %cl,%esi
  801313:	89 c1                	mov    %eax,%ecx
  801315:	d3 eb                	shr    %cl,%ebx
  801317:	09 de                	or     %ebx,%esi
  801319:	89 f0                	mov    %esi,%eax
  80131b:	f7 74 24 08          	divl   0x8(%esp)
  80131f:	89 d6                	mov    %edx,%esi
  801321:	89 c3                	mov    %eax,%ebx
  801323:	f7 64 24 0c          	mull   0xc(%esp)
  801327:	39 d6                	cmp    %edx,%esi
  801329:	72 15                	jb     801340 <__udivdi3+0x100>
  80132b:	89 f9                	mov    %edi,%ecx
  80132d:	d3 e5                	shl    %cl,%ebp
  80132f:	39 c5                	cmp    %eax,%ebp
  801331:	73 04                	jae    801337 <__udivdi3+0xf7>
  801333:	39 d6                	cmp    %edx,%esi
  801335:	74 09                	je     801340 <__udivdi3+0x100>
  801337:	89 d8                	mov    %ebx,%eax
  801339:	31 ff                	xor    %edi,%edi
  80133b:	e9 40 ff ff ff       	jmp    801280 <__udivdi3+0x40>
  801340:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801343:	31 ff                	xor    %edi,%edi
  801345:	e9 36 ff ff ff       	jmp    801280 <__udivdi3+0x40>
  80134a:	66 90                	xchg   %ax,%ax
  80134c:	66 90                	xchg   %ax,%ax
  80134e:	66 90                	xchg   %ax,%ax

00801350 <__umoddi3>:
  801350:	f3 0f 1e fb          	endbr32 
  801354:	55                   	push   %ebp
  801355:	57                   	push   %edi
  801356:	56                   	push   %esi
  801357:	53                   	push   %ebx
  801358:	83 ec 1c             	sub    $0x1c,%esp
  80135b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80135f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801363:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801367:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80136b:	85 c0                	test   %eax,%eax
  80136d:	75 19                	jne    801388 <__umoddi3+0x38>
  80136f:	39 df                	cmp    %ebx,%edi
  801371:	76 5d                	jbe    8013d0 <__umoddi3+0x80>
  801373:	89 f0                	mov    %esi,%eax
  801375:	89 da                	mov    %ebx,%edx
  801377:	f7 f7                	div    %edi
  801379:	89 d0                	mov    %edx,%eax
  80137b:	31 d2                	xor    %edx,%edx
  80137d:	83 c4 1c             	add    $0x1c,%esp
  801380:	5b                   	pop    %ebx
  801381:	5e                   	pop    %esi
  801382:	5f                   	pop    %edi
  801383:	5d                   	pop    %ebp
  801384:	c3                   	ret    
  801385:	8d 76 00             	lea    0x0(%esi),%esi
  801388:	89 f2                	mov    %esi,%edx
  80138a:	39 d8                	cmp    %ebx,%eax
  80138c:	76 12                	jbe    8013a0 <__umoddi3+0x50>
  80138e:	89 f0                	mov    %esi,%eax
  801390:	89 da                	mov    %ebx,%edx
  801392:	83 c4 1c             	add    $0x1c,%esp
  801395:	5b                   	pop    %ebx
  801396:	5e                   	pop    %esi
  801397:	5f                   	pop    %edi
  801398:	5d                   	pop    %ebp
  801399:	c3                   	ret    
  80139a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013a0:	0f bd e8             	bsr    %eax,%ebp
  8013a3:	83 f5 1f             	xor    $0x1f,%ebp
  8013a6:	75 50                	jne    8013f8 <__umoddi3+0xa8>
  8013a8:	39 d8                	cmp    %ebx,%eax
  8013aa:	0f 82 e0 00 00 00    	jb     801490 <__umoddi3+0x140>
  8013b0:	89 d9                	mov    %ebx,%ecx
  8013b2:	39 f7                	cmp    %esi,%edi
  8013b4:	0f 86 d6 00 00 00    	jbe    801490 <__umoddi3+0x140>
  8013ba:	89 d0                	mov    %edx,%eax
  8013bc:	89 ca                	mov    %ecx,%edx
  8013be:	83 c4 1c             	add    $0x1c,%esp
  8013c1:	5b                   	pop    %ebx
  8013c2:	5e                   	pop    %esi
  8013c3:	5f                   	pop    %edi
  8013c4:	5d                   	pop    %ebp
  8013c5:	c3                   	ret    
  8013c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013cd:	8d 76 00             	lea    0x0(%esi),%esi
  8013d0:	89 fd                	mov    %edi,%ebp
  8013d2:	85 ff                	test   %edi,%edi
  8013d4:	75 0b                	jne    8013e1 <__umoddi3+0x91>
  8013d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013db:	31 d2                	xor    %edx,%edx
  8013dd:	f7 f7                	div    %edi
  8013df:	89 c5                	mov    %eax,%ebp
  8013e1:	89 d8                	mov    %ebx,%eax
  8013e3:	31 d2                	xor    %edx,%edx
  8013e5:	f7 f5                	div    %ebp
  8013e7:	89 f0                	mov    %esi,%eax
  8013e9:	f7 f5                	div    %ebp
  8013eb:	89 d0                	mov    %edx,%eax
  8013ed:	31 d2                	xor    %edx,%edx
  8013ef:	eb 8c                	jmp    80137d <__umoddi3+0x2d>
  8013f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013f8:	89 e9                	mov    %ebp,%ecx
  8013fa:	ba 20 00 00 00       	mov    $0x20,%edx
  8013ff:	29 ea                	sub    %ebp,%edx
  801401:	d3 e0                	shl    %cl,%eax
  801403:	89 44 24 08          	mov    %eax,0x8(%esp)
  801407:	89 d1                	mov    %edx,%ecx
  801409:	89 f8                	mov    %edi,%eax
  80140b:	d3 e8                	shr    %cl,%eax
  80140d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801411:	89 54 24 04          	mov    %edx,0x4(%esp)
  801415:	8b 54 24 04          	mov    0x4(%esp),%edx
  801419:	09 c1                	or     %eax,%ecx
  80141b:	89 d8                	mov    %ebx,%eax
  80141d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801421:	89 e9                	mov    %ebp,%ecx
  801423:	d3 e7                	shl    %cl,%edi
  801425:	89 d1                	mov    %edx,%ecx
  801427:	d3 e8                	shr    %cl,%eax
  801429:	89 e9                	mov    %ebp,%ecx
  80142b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80142f:	d3 e3                	shl    %cl,%ebx
  801431:	89 c7                	mov    %eax,%edi
  801433:	89 d1                	mov    %edx,%ecx
  801435:	89 f0                	mov    %esi,%eax
  801437:	d3 e8                	shr    %cl,%eax
  801439:	89 e9                	mov    %ebp,%ecx
  80143b:	89 fa                	mov    %edi,%edx
  80143d:	d3 e6                	shl    %cl,%esi
  80143f:	09 d8                	or     %ebx,%eax
  801441:	f7 74 24 08          	divl   0x8(%esp)
  801445:	89 d1                	mov    %edx,%ecx
  801447:	89 f3                	mov    %esi,%ebx
  801449:	f7 64 24 0c          	mull   0xc(%esp)
  80144d:	89 c6                	mov    %eax,%esi
  80144f:	89 d7                	mov    %edx,%edi
  801451:	39 d1                	cmp    %edx,%ecx
  801453:	72 06                	jb     80145b <__umoddi3+0x10b>
  801455:	75 10                	jne    801467 <__umoddi3+0x117>
  801457:	39 c3                	cmp    %eax,%ebx
  801459:	73 0c                	jae    801467 <__umoddi3+0x117>
  80145b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80145f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801463:	89 d7                	mov    %edx,%edi
  801465:	89 c6                	mov    %eax,%esi
  801467:	89 ca                	mov    %ecx,%edx
  801469:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80146e:	29 f3                	sub    %esi,%ebx
  801470:	19 fa                	sbb    %edi,%edx
  801472:	89 d0                	mov    %edx,%eax
  801474:	d3 e0                	shl    %cl,%eax
  801476:	89 e9                	mov    %ebp,%ecx
  801478:	d3 eb                	shr    %cl,%ebx
  80147a:	d3 ea                	shr    %cl,%edx
  80147c:	09 d8                	or     %ebx,%eax
  80147e:	83 c4 1c             	add    $0x1c,%esp
  801481:	5b                   	pop    %ebx
  801482:	5e                   	pop    %esi
  801483:	5f                   	pop    %edi
  801484:	5d                   	pop    %ebp
  801485:	c3                   	ret    
  801486:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80148d:	8d 76 00             	lea    0x0(%esi),%esi
  801490:	29 fe                	sub    %edi,%esi
  801492:	19 c3                	sbb    %eax,%ebx
  801494:	89 f2                	mov    %esi,%edx
  801496:	89 d9                	mov    %ebx,%ecx
  801498:	e9 1d ff ff ff       	jmp    8013ba <__umoddi3+0x6a>
