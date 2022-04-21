
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 af 00 00 00       	call   8000e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003d:	68 60 1f 80 00       	push   $0x801f60
  800042:	e8 f2 01 00 00       	call   800239 <cprintf>
  800047:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  80004a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004f:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800056:	00 
  800057:	75 63                	jne    8000bc <umain+0x89>
	for (i = 0; i < ARRAYSIZE; i++)
  800059:	83 c0 01             	add    $0x1,%eax
  80005c:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800061:	75 ec                	jne    80004f <umain+0x1c>
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  800063:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
  800068:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  80006f:	83 c0 01             	add    $0x1,%eax
  800072:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800077:	75 ef                	jne    800068 <umain+0x35>
	for (i = 0; i < ARRAYSIZE; i++)
  800079:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  80007e:	39 04 85 20 40 80 00 	cmp    %eax,0x804020(,%eax,4)
  800085:	75 47                	jne    8000ce <umain+0x9b>
	for (i = 0; i < ARRAYSIZE; i++)
  800087:	83 c0 01             	add    $0x1,%eax
  80008a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008f:	75 ed                	jne    80007e <umain+0x4b>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  800091:	83 ec 0c             	sub    $0xc,%esp
  800094:	68 a8 1f 80 00       	push   $0x801fa8
  800099:	e8 9b 01 00 00       	call   800239 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  80009e:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000a5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000a8:	83 c4 0c             	add    $0xc,%esp
  8000ab:	68 07 20 80 00       	push   $0x802007
  8000b0:	6a 1a                	push   $0x1a
  8000b2:	68 f8 1f 80 00       	push   $0x801ff8
  8000b7:	e8 96 00 00 00       	call   800152 <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000bc:	50                   	push   %eax
  8000bd:	68 db 1f 80 00       	push   $0x801fdb
  8000c2:	6a 11                	push   $0x11
  8000c4:	68 f8 1f 80 00       	push   $0x801ff8
  8000c9:	e8 84 00 00 00       	call   800152 <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ce:	50                   	push   %eax
  8000cf:	68 80 1f 80 00       	push   $0x801f80
  8000d4:	6a 16                	push   $0x16
  8000d6:	68 f8 1f 80 00       	push   $0x801ff8
  8000db:	e8 72 00 00 00       	call   800152 <_panic>

008000e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e0:	f3 0f 1e fb          	endbr32 
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000ef:	c7 05 20 40 c0 00 00 	movl   $0x0,0xc04020
  8000f6:	00 00 00 
    envid_t envid = sys_getenvid();
  8000f9:	e8 40 0b 00 00       	call   800c3e <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8000fe:	25 ff 03 00 00       	and    $0x3ff,%eax
  800103:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800106:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010b:	a3 20 40 c0 00       	mov    %eax,0xc04020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800110:	85 db                	test   %ebx,%ebx
  800112:	7e 07                	jle    80011b <libmain+0x3b>
		binaryname = argv[0];
  800114:	8b 06                	mov    (%esi),%eax
  800116:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80011b:	83 ec 08             	sub    $0x8,%esp
  80011e:	56                   	push   %esi
  80011f:	53                   	push   %ebx
  800120:	e8 0e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800125:	e8 0a 00 00 00       	call   800134 <exit>
}
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5d                   	pop    %ebp
  800133:	c3                   	ret    

00800134 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800134:	f3 0f 1e fb          	endbr32 
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80013e:	e8 41 0f 00 00       	call   801084 <close_all>
	sys_env_destroy(0);
  800143:	83 ec 0c             	sub    $0xc,%esp
  800146:	6a 00                	push   $0x0
  800148:	e8 ac 0a 00 00       	call   800bf9 <sys_env_destroy>
}
  80014d:	83 c4 10             	add    $0x10,%esp
  800150:	c9                   	leave  
  800151:	c3                   	ret    

00800152 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800152:	f3 0f 1e fb          	endbr32 
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800164:	e8 d5 0a 00 00       	call   800c3e <sys_getenvid>
  800169:	83 ec 0c             	sub    $0xc,%esp
  80016c:	ff 75 0c             	pushl  0xc(%ebp)
  80016f:	ff 75 08             	pushl  0x8(%ebp)
  800172:	56                   	push   %esi
  800173:	50                   	push   %eax
  800174:	68 28 20 80 00       	push   $0x802028
  800179:	e8 bb 00 00 00       	call   800239 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80017e:	83 c4 18             	add    $0x18,%esp
  800181:	53                   	push   %ebx
  800182:	ff 75 10             	pushl  0x10(%ebp)
  800185:	e8 5a 00 00 00       	call   8001e4 <vcprintf>
	cprintf("\n");
  80018a:	c7 04 24 f6 1f 80 00 	movl   $0x801ff6,(%esp)
  800191:	e8 a3 00 00 00       	call   800239 <cprintf>
  800196:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800199:	cc                   	int3   
  80019a:	eb fd                	jmp    800199 <_panic+0x47>

0080019c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019c:	f3 0f 1e fb          	endbr32 
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 04             	sub    $0x4,%esp
  8001a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001aa:	8b 13                	mov    (%ebx),%edx
  8001ac:	8d 42 01             	lea    0x1(%edx),%eax
  8001af:	89 03                	mov    %eax,(%ebx)
  8001b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bd:	74 09                	je     8001c8 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001bf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 ff 00 00 00       	push   $0xff
  8001d0:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d3:	50                   	push   %eax
  8001d4:	e8 db 09 00 00       	call   800bb4 <sys_cputs>
		b->idx = 0;
  8001d9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001df:	83 c4 10             	add    $0x10,%esp
  8001e2:	eb db                	jmp    8001bf <putch+0x23>

008001e4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e4:	f3 0f 1e fb          	endbr32 
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001f1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f8:	00 00 00 
	b.cnt = 0;
  8001fb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800202:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800205:	ff 75 0c             	pushl  0xc(%ebp)
  800208:	ff 75 08             	pushl  0x8(%ebp)
  80020b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800211:	50                   	push   %eax
  800212:	68 9c 01 80 00       	push   $0x80019c
  800217:	e8 20 01 00 00       	call   80033c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021c:	83 c4 08             	add    $0x8,%esp
  80021f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800225:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022b:	50                   	push   %eax
  80022c:	e8 83 09 00 00       	call   800bb4 <sys_cputs>

	return b.cnt;
}
  800231:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800237:	c9                   	leave  
  800238:	c3                   	ret    

00800239 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800239:	f3 0f 1e fb          	endbr32 
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800243:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800246:	50                   	push   %eax
  800247:	ff 75 08             	pushl  0x8(%ebp)
  80024a:	e8 95 ff ff ff       	call   8001e4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80024f:	c9                   	leave  
  800250:	c3                   	ret    

00800251 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800251:	55                   	push   %ebp
  800252:	89 e5                	mov    %esp,%ebp
  800254:	57                   	push   %edi
  800255:	56                   	push   %esi
  800256:	53                   	push   %ebx
  800257:	83 ec 1c             	sub    $0x1c,%esp
  80025a:	89 c7                	mov    %eax,%edi
  80025c:	89 d6                	mov    %edx,%esi
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	8b 55 0c             	mov    0xc(%ebp),%edx
  800264:	89 d1                	mov    %edx,%ecx
  800266:	89 c2                	mov    %eax,%edx
  800268:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80026b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80026e:	8b 45 10             	mov    0x10(%ebp),%eax
  800271:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800274:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800277:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80027e:	39 c2                	cmp    %eax,%edx
  800280:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800283:	72 3e                	jb     8002c3 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800285:	83 ec 0c             	sub    $0xc,%esp
  800288:	ff 75 18             	pushl  0x18(%ebp)
  80028b:	83 eb 01             	sub    $0x1,%ebx
  80028e:	53                   	push   %ebx
  80028f:	50                   	push   %eax
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	ff 75 e4             	pushl  -0x1c(%ebp)
  800296:	ff 75 e0             	pushl  -0x20(%ebp)
  800299:	ff 75 dc             	pushl  -0x24(%ebp)
  80029c:	ff 75 d8             	pushl  -0x28(%ebp)
  80029f:	e8 4c 1a 00 00       	call   801cf0 <__udivdi3>
  8002a4:	83 c4 18             	add    $0x18,%esp
  8002a7:	52                   	push   %edx
  8002a8:	50                   	push   %eax
  8002a9:	89 f2                	mov    %esi,%edx
  8002ab:	89 f8                	mov    %edi,%eax
  8002ad:	e8 9f ff ff ff       	call   800251 <printnum>
  8002b2:	83 c4 20             	add    $0x20,%esp
  8002b5:	eb 13                	jmp    8002ca <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b7:	83 ec 08             	sub    $0x8,%esp
  8002ba:	56                   	push   %esi
  8002bb:	ff 75 18             	pushl  0x18(%ebp)
  8002be:	ff d7                	call   *%edi
  8002c0:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002c3:	83 eb 01             	sub    $0x1,%ebx
  8002c6:	85 db                	test   %ebx,%ebx
  8002c8:	7f ed                	jg     8002b7 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ca:	83 ec 08             	sub    $0x8,%esp
  8002cd:	56                   	push   %esi
  8002ce:	83 ec 04             	sub    $0x4,%esp
  8002d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d7:	ff 75 dc             	pushl  -0x24(%ebp)
  8002da:	ff 75 d8             	pushl  -0x28(%ebp)
  8002dd:	e8 1e 1b 00 00       	call   801e00 <__umoddi3>
  8002e2:	83 c4 14             	add    $0x14,%esp
  8002e5:	0f be 80 4b 20 80 00 	movsbl 0x80204b(%eax),%eax
  8002ec:	50                   	push   %eax
  8002ed:	ff d7                	call   *%edi
}
  8002ef:	83 c4 10             	add    $0x10,%esp
  8002f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f5:	5b                   	pop    %ebx
  8002f6:	5e                   	pop    %esi
  8002f7:	5f                   	pop    %edi
  8002f8:	5d                   	pop    %ebp
  8002f9:	c3                   	ret    

008002fa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002fa:	f3 0f 1e fb          	endbr32 
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
  800301:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800304:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800308:	8b 10                	mov    (%eax),%edx
  80030a:	3b 50 04             	cmp    0x4(%eax),%edx
  80030d:	73 0a                	jae    800319 <sprintputch+0x1f>
		*b->buf++ = ch;
  80030f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800312:	89 08                	mov    %ecx,(%eax)
  800314:	8b 45 08             	mov    0x8(%ebp),%eax
  800317:	88 02                	mov    %al,(%edx)
}
  800319:	5d                   	pop    %ebp
  80031a:	c3                   	ret    

0080031b <printfmt>:
{
  80031b:	f3 0f 1e fb          	endbr32 
  80031f:	55                   	push   %ebp
  800320:	89 e5                	mov    %esp,%ebp
  800322:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800325:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800328:	50                   	push   %eax
  800329:	ff 75 10             	pushl  0x10(%ebp)
  80032c:	ff 75 0c             	pushl  0xc(%ebp)
  80032f:	ff 75 08             	pushl  0x8(%ebp)
  800332:	e8 05 00 00 00       	call   80033c <vprintfmt>
}
  800337:	83 c4 10             	add    $0x10,%esp
  80033a:	c9                   	leave  
  80033b:	c3                   	ret    

0080033c <vprintfmt>:
{
  80033c:	f3 0f 1e fb          	endbr32 
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	57                   	push   %edi
  800344:	56                   	push   %esi
  800345:	53                   	push   %ebx
  800346:	83 ec 3c             	sub    $0x3c,%esp
  800349:	8b 75 08             	mov    0x8(%ebp),%esi
  80034c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80034f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800352:	e9 4a 03 00 00       	jmp    8006a1 <vprintfmt+0x365>
		padc = ' ';
  800357:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80035b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800362:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800369:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800370:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8d 47 01             	lea    0x1(%edi),%eax
  800378:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80037b:	0f b6 17             	movzbl (%edi),%edx
  80037e:	8d 42 dd             	lea    -0x23(%edx),%eax
  800381:	3c 55                	cmp    $0x55,%al
  800383:	0f 87 de 03 00 00    	ja     800767 <vprintfmt+0x42b>
  800389:	0f b6 c0             	movzbl %al,%eax
  80038c:	3e ff 24 85 80 21 80 	notrack jmp *0x802180(,%eax,4)
  800393:	00 
  800394:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800397:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80039b:	eb d8                	jmp    800375 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a0:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003a4:	eb cf                	jmp    800375 <vprintfmt+0x39>
  8003a6:	0f b6 d2             	movzbl %dl,%edx
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003b4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b7:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003bb:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003be:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003c1:	83 f9 09             	cmp    $0x9,%ecx
  8003c4:	77 55                	ja     80041b <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003c6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003c9:	eb e9                	jmp    8003b4 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ce:	8b 00                	mov    (%eax),%eax
  8003d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d6:	8d 40 04             	lea    0x4(%eax),%eax
  8003d9:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e3:	79 90                	jns    800375 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003e5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003eb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003f2:	eb 81                	jmp    800375 <vprintfmt+0x39>
  8003f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f7:	85 c0                	test   %eax,%eax
  8003f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fe:	0f 49 d0             	cmovns %eax,%edx
  800401:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800407:	e9 69 ff ff ff       	jmp    800375 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80040f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800416:	e9 5a ff ff ff       	jmp    800375 <vprintfmt+0x39>
  80041b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80041e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800421:	eb bc                	jmp    8003df <vprintfmt+0xa3>
			lflag++;
  800423:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800429:	e9 47 ff ff ff       	jmp    800375 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 78 04             	lea    0x4(%eax),%edi
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	53                   	push   %ebx
  800438:	ff 30                	pushl  (%eax)
  80043a:	ff d6                	call   *%esi
			break;
  80043c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80043f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800442:	e9 57 02 00 00       	jmp    80069e <vprintfmt+0x362>
			err = va_arg(ap, int);
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 78 04             	lea    0x4(%eax),%edi
  80044d:	8b 00                	mov    (%eax),%eax
  80044f:	99                   	cltd   
  800450:	31 d0                	xor    %edx,%eax
  800452:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800454:	83 f8 0f             	cmp    $0xf,%eax
  800457:	7f 23                	jg     80047c <vprintfmt+0x140>
  800459:	8b 14 85 e0 22 80 00 	mov    0x8022e0(,%eax,4),%edx
  800460:	85 d2                	test   %edx,%edx
  800462:	74 18                	je     80047c <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800464:	52                   	push   %edx
  800465:	68 3a 24 80 00       	push   $0x80243a
  80046a:	53                   	push   %ebx
  80046b:	56                   	push   %esi
  80046c:	e8 aa fe ff ff       	call   80031b <printfmt>
  800471:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800474:	89 7d 14             	mov    %edi,0x14(%ebp)
  800477:	e9 22 02 00 00       	jmp    80069e <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  80047c:	50                   	push   %eax
  80047d:	68 63 20 80 00       	push   $0x802063
  800482:	53                   	push   %ebx
  800483:	56                   	push   %esi
  800484:	e8 92 fe ff ff       	call   80031b <printfmt>
  800489:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80048c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80048f:	e9 0a 02 00 00       	jmp    80069e <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	83 c0 04             	add    $0x4,%eax
  80049a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80049d:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a0:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004a2:	85 d2                	test   %edx,%edx
  8004a4:	b8 5c 20 80 00       	mov    $0x80205c,%eax
  8004a9:	0f 45 c2             	cmovne %edx,%eax
  8004ac:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b3:	7e 06                	jle    8004bb <vprintfmt+0x17f>
  8004b5:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004b9:	75 0d                	jne    8004c8 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bb:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004be:	89 c7                	mov    %eax,%edi
  8004c0:	03 45 e0             	add    -0x20(%ebp),%eax
  8004c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c6:	eb 55                	jmp    80051d <vprintfmt+0x1e1>
  8004c8:	83 ec 08             	sub    $0x8,%esp
  8004cb:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ce:	ff 75 cc             	pushl  -0x34(%ebp)
  8004d1:	e8 45 03 00 00       	call   80081b <strnlen>
  8004d6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004d9:	29 c2                	sub    %eax,%edx
  8004db:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004de:	83 c4 10             	add    $0x10,%esp
  8004e1:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004e3:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ea:	85 ff                	test   %edi,%edi
  8004ec:	7e 11                	jle    8004ff <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	53                   	push   %ebx
  8004f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f7:	83 ef 01             	sub    $0x1,%edi
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	eb eb                	jmp    8004ea <vprintfmt+0x1ae>
  8004ff:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800502:	85 d2                	test   %edx,%edx
  800504:	b8 00 00 00 00       	mov    $0x0,%eax
  800509:	0f 49 c2             	cmovns %edx,%eax
  80050c:	29 c2                	sub    %eax,%edx
  80050e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800511:	eb a8                	jmp    8004bb <vprintfmt+0x17f>
					putch(ch, putdat);
  800513:	83 ec 08             	sub    $0x8,%esp
  800516:	53                   	push   %ebx
  800517:	52                   	push   %edx
  800518:	ff d6                	call   *%esi
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800520:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800522:	83 c7 01             	add    $0x1,%edi
  800525:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800529:	0f be d0             	movsbl %al,%edx
  80052c:	85 d2                	test   %edx,%edx
  80052e:	74 4b                	je     80057b <vprintfmt+0x23f>
  800530:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800534:	78 06                	js     80053c <vprintfmt+0x200>
  800536:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80053a:	78 1e                	js     80055a <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80053c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800540:	74 d1                	je     800513 <vprintfmt+0x1d7>
  800542:	0f be c0             	movsbl %al,%eax
  800545:	83 e8 20             	sub    $0x20,%eax
  800548:	83 f8 5e             	cmp    $0x5e,%eax
  80054b:	76 c6                	jbe    800513 <vprintfmt+0x1d7>
					putch('?', putdat);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	53                   	push   %ebx
  800551:	6a 3f                	push   $0x3f
  800553:	ff d6                	call   *%esi
  800555:	83 c4 10             	add    $0x10,%esp
  800558:	eb c3                	jmp    80051d <vprintfmt+0x1e1>
  80055a:	89 cf                	mov    %ecx,%edi
  80055c:	eb 0e                	jmp    80056c <vprintfmt+0x230>
				putch(' ', putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	53                   	push   %ebx
  800562:	6a 20                	push   $0x20
  800564:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800566:	83 ef 01             	sub    $0x1,%edi
  800569:	83 c4 10             	add    $0x10,%esp
  80056c:	85 ff                	test   %edi,%edi
  80056e:	7f ee                	jg     80055e <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800570:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800573:	89 45 14             	mov    %eax,0x14(%ebp)
  800576:	e9 23 01 00 00       	jmp    80069e <vprintfmt+0x362>
  80057b:	89 cf                	mov    %ecx,%edi
  80057d:	eb ed                	jmp    80056c <vprintfmt+0x230>
	if (lflag >= 2)
  80057f:	83 f9 01             	cmp    $0x1,%ecx
  800582:	7f 1b                	jg     80059f <vprintfmt+0x263>
	else if (lflag)
  800584:	85 c9                	test   %ecx,%ecx
  800586:	74 63                	je     8005eb <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8b 00                	mov    (%eax),%eax
  80058d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800590:	99                   	cltd   
  800591:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 40 04             	lea    0x4(%eax),%eax
  80059a:	89 45 14             	mov    %eax,0x14(%ebp)
  80059d:	eb 17                	jmp    8005b6 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8b 50 04             	mov    0x4(%eax),%edx
  8005a5:	8b 00                	mov    (%eax),%eax
  8005a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005aa:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8d 40 08             	lea    0x8(%eax),%eax
  8005b3:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005b6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005bc:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005c1:	85 c9                	test   %ecx,%ecx
  8005c3:	0f 89 bb 00 00 00    	jns    800684 <vprintfmt+0x348>
				putch('-', putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	53                   	push   %ebx
  8005cd:	6a 2d                	push   $0x2d
  8005cf:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005d7:	f7 da                	neg    %edx
  8005d9:	83 d1 00             	adc    $0x0,%ecx
  8005dc:	f7 d9                	neg    %ecx
  8005de:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005e1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e6:	e9 99 00 00 00       	jmp    800684 <vprintfmt+0x348>
		return va_arg(*ap, int);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8b 00                	mov    (%eax),%eax
  8005f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f3:	99                   	cltd   
  8005f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8d 40 04             	lea    0x4(%eax),%eax
  8005fd:	89 45 14             	mov    %eax,0x14(%ebp)
  800600:	eb b4                	jmp    8005b6 <vprintfmt+0x27a>
	if (lflag >= 2)
  800602:	83 f9 01             	cmp    $0x1,%ecx
  800605:	7f 1b                	jg     800622 <vprintfmt+0x2e6>
	else if (lflag)
  800607:	85 c9                	test   %ecx,%ecx
  800609:	74 2c                	je     800637 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8b 10                	mov    (%eax),%edx
  800610:	b9 00 00 00 00       	mov    $0x0,%ecx
  800615:	8d 40 04             	lea    0x4(%eax),%eax
  800618:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80061b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800620:	eb 62                	jmp    800684 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8b 10                	mov    (%eax),%edx
  800627:	8b 48 04             	mov    0x4(%eax),%ecx
  80062a:	8d 40 08             	lea    0x8(%eax),%eax
  80062d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800630:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800635:	eb 4d                	jmp    800684 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800637:	8b 45 14             	mov    0x14(%ebp),%eax
  80063a:	8b 10                	mov    (%eax),%edx
  80063c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800641:	8d 40 04             	lea    0x4(%eax),%eax
  800644:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800647:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80064c:	eb 36                	jmp    800684 <vprintfmt+0x348>
	if (lflag >= 2)
  80064e:	83 f9 01             	cmp    $0x1,%ecx
  800651:	7f 17                	jg     80066a <vprintfmt+0x32e>
	else if (lflag)
  800653:	85 c9                	test   %ecx,%ecx
  800655:	74 6e                	je     8006c5 <vprintfmt+0x389>
		return va_arg(*ap, long);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8b 10                	mov    (%eax),%edx
  80065c:	89 d0                	mov    %edx,%eax
  80065e:	99                   	cltd   
  80065f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800662:	8d 49 04             	lea    0x4(%ecx),%ecx
  800665:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800668:	eb 11                	jmp    80067b <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8b 50 04             	mov    0x4(%eax),%edx
  800670:	8b 00                	mov    (%eax),%eax
  800672:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800675:	8d 49 08             	lea    0x8(%ecx),%ecx
  800678:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80067b:	89 d1                	mov    %edx,%ecx
  80067d:	89 c2                	mov    %eax,%edx
            base = 8;
  80067f:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800684:	83 ec 0c             	sub    $0xc,%esp
  800687:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80068b:	57                   	push   %edi
  80068c:	ff 75 e0             	pushl  -0x20(%ebp)
  80068f:	50                   	push   %eax
  800690:	51                   	push   %ecx
  800691:	52                   	push   %edx
  800692:	89 da                	mov    %ebx,%edx
  800694:	89 f0                	mov    %esi,%eax
  800696:	e8 b6 fb ff ff       	call   800251 <printnum>
			break;
  80069b:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80069e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006a1:	83 c7 01             	add    $0x1,%edi
  8006a4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006a8:	83 f8 25             	cmp    $0x25,%eax
  8006ab:	0f 84 a6 fc ff ff    	je     800357 <vprintfmt+0x1b>
			if (ch == '\0')
  8006b1:	85 c0                	test   %eax,%eax
  8006b3:	0f 84 ce 00 00 00    	je     800787 <vprintfmt+0x44b>
			putch(ch, putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	53                   	push   %ebx
  8006bd:	50                   	push   %eax
  8006be:	ff d6                	call   *%esi
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	eb dc                	jmp    8006a1 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8b 10                	mov    (%eax),%edx
  8006ca:	89 d0                	mov    %edx,%eax
  8006cc:	99                   	cltd   
  8006cd:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006d0:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006d3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006d6:	eb a3                	jmp    80067b <vprintfmt+0x33f>
			putch('0', putdat);
  8006d8:	83 ec 08             	sub    $0x8,%esp
  8006db:	53                   	push   %ebx
  8006dc:	6a 30                	push   $0x30
  8006de:	ff d6                	call   *%esi
			putch('x', putdat);
  8006e0:	83 c4 08             	add    $0x8,%esp
  8006e3:	53                   	push   %ebx
  8006e4:	6a 78                	push   $0x78
  8006e6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8b 10                	mov    (%eax),%edx
  8006ed:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006f2:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006f5:	8d 40 04             	lea    0x4(%eax),%eax
  8006f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006fb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800700:	eb 82                	jmp    800684 <vprintfmt+0x348>
	if (lflag >= 2)
  800702:	83 f9 01             	cmp    $0x1,%ecx
  800705:	7f 1e                	jg     800725 <vprintfmt+0x3e9>
	else if (lflag)
  800707:	85 c9                	test   %ecx,%ecx
  800709:	74 32                	je     80073d <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80070b:	8b 45 14             	mov    0x14(%ebp),%eax
  80070e:	8b 10                	mov    (%eax),%edx
  800710:	b9 00 00 00 00       	mov    $0x0,%ecx
  800715:	8d 40 04             	lea    0x4(%eax),%eax
  800718:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800720:	e9 5f ff ff ff       	jmp    800684 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800725:	8b 45 14             	mov    0x14(%ebp),%eax
  800728:	8b 10                	mov    (%eax),%edx
  80072a:	8b 48 04             	mov    0x4(%eax),%ecx
  80072d:	8d 40 08             	lea    0x8(%eax),%eax
  800730:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800733:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800738:	e9 47 ff ff ff       	jmp    800684 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80073d:	8b 45 14             	mov    0x14(%ebp),%eax
  800740:	8b 10                	mov    (%eax),%edx
  800742:	b9 00 00 00 00       	mov    $0x0,%ecx
  800747:	8d 40 04             	lea    0x4(%eax),%eax
  80074a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80074d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800752:	e9 2d ff ff ff       	jmp    800684 <vprintfmt+0x348>
			putch(ch, putdat);
  800757:	83 ec 08             	sub    $0x8,%esp
  80075a:	53                   	push   %ebx
  80075b:	6a 25                	push   $0x25
  80075d:	ff d6                	call   *%esi
			break;
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	e9 37 ff ff ff       	jmp    80069e <vprintfmt+0x362>
			putch('%', putdat);
  800767:	83 ec 08             	sub    $0x8,%esp
  80076a:	53                   	push   %ebx
  80076b:	6a 25                	push   $0x25
  80076d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80076f:	83 c4 10             	add    $0x10,%esp
  800772:	89 f8                	mov    %edi,%eax
  800774:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800778:	74 05                	je     80077f <vprintfmt+0x443>
  80077a:	83 e8 01             	sub    $0x1,%eax
  80077d:	eb f5                	jmp    800774 <vprintfmt+0x438>
  80077f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800782:	e9 17 ff ff ff       	jmp    80069e <vprintfmt+0x362>
}
  800787:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078a:	5b                   	pop    %ebx
  80078b:	5e                   	pop    %esi
  80078c:	5f                   	pop    %edi
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80078f:	f3 0f 1e fb          	endbr32 
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	83 ec 18             	sub    $0x18,%esp
  800799:	8b 45 08             	mov    0x8(%ebp),%eax
  80079c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80079f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b0:	85 c0                	test   %eax,%eax
  8007b2:	74 26                	je     8007da <vsnprintf+0x4b>
  8007b4:	85 d2                	test   %edx,%edx
  8007b6:	7e 22                	jle    8007da <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b8:	ff 75 14             	pushl  0x14(%ebp)
  8007bb:	ff 75 10             	pushl  0x10(%ebp)
  8007be:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c1:	50                   	push   %eax
  8007c2:	68 fa 02 80 00       	push   $0x8002fa
  8007c7:	e8 70 fb ff ff       	call   80033c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007cf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d5:	83 c4 10             	add    $0x10,%esp
}
  8007d8:	c9                   	leave  
  8007d9:	c3                   	ret    
		return -E_INVAL;
  8007da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007df:	eb f7                	jmp    8007d8 <vsnprintf+0x49>

008007e1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e1:	f3 0f 1e fb          	endbr32 
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007eb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ee:	50                   	push   %eax
  8007ef:	ff 75 10             	pushl  0x10(%ebp)
  8007f2:	ff 75 0c             	pushl  0xc(%ebp)
  8007f5:	ff 75 08             	pushl  0x8(%ebp)
  8007f8:	e8 92 ff ff ff       	call   80078f <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    

008007ff <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ff:	f3 0f 1e fb          	endbr32 
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800809:	b8 00 00 00 00       	mov    $0x0,%eax
  80080e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800812:	74 05                	je     800819 <strlen+0x1a>
		n++;
  800814:	83 c0 01             	add    $0x1,%eax
  800817:	eb f5                	jmp    80080e <strlen+0xf>
	return n;
}
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80081b:	f3 0f 1e fb          	endbr32 
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800825:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800828:	b8 00 00 00 00       	mov    $0x0,%eax
  80082d:	39 d0                	cmp    %edx,%eax
  80082f:	74 0d                	je     80083e <strnlen+0x23>
  800831:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800835:	74 05                	je     80083c <strnlen+0x21>
		n++;
  800837:	83 c0 01             	add    $0x1,%eax
  80083a:	eb f1                	jmp    80082d <strnlen+0x12>
  80083c:	89 c2                	mov    %eax,%edx
	return n;
}
  80083e:	89 d0                	mov    %edx,%eax
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800842:	f3 0f 1e fb          	endbr32 
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	53                   	push   %ebx
  80084a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800850:	b8 00 00 00 00       	mov    $0x0,%eax
  800855:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800859:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80085c:	83 c0 01             	add    $0x1,%eax
  80085f:	84 d2                	test   %dl,%dl
  800861:	75 f2                	jne    800855 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800863:	89 c8                	mov    %ecx,%eax
  800865:	5b                   	pop    %ebx
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800868:	f3 0f 1e fb          	endbr32 
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	53                   	push   %ebx
  800870:	83 ec 10             	sub    $0x10,%esp
  800873:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800876:	53                   	push   %ebx
  800877:	e8 83 ff ff ff       	call   8007ff <strlen>
  80087c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80087f:	ff 75 0c             	pushl  0xc(%ebp)
  800882:	01 d8                	add    %ebx,%eax
  800884:	50                   	push   %eax
  800885:	e8 b8 ff ff ff       	call   800842 <strcpy>
	return dst;
}
  80088a:	89 d8                	mov    %ebx,%eax
  80088c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088f:	c9                   	leave  
  800890:	c3                   	ret    

00800891 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800891:	f3 0f 1e fb          	endbr32 
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	56                   	push   %esi
  800899:	53                   	push   %ebx
  80089a:	8b 75 08             	mov    0x8(%ebp),%esi
  80089d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a0:	89 f3                	mov    %esi,%ebx
  8008a2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a5:	89 f0                	mov    %esi,%eax
  8008a7:	39 d8                	cmp    %ebx,%eax
  8008a9:	74 11                	je     8008bc <strncpy+0x2b>
		*dst++ = *src;
  8008ab:	83 c0 01             	add    $0x1,%eax
  8008ae:	0f b6 0a             	movzbl (%edx),%ecx
  8008b1:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b4:	80 f9 01             	cmp    $0x1,%cl
  8008b7:	83 da ff             	sbb    $0xffffffff,%edx
  8008ba:	eb eb                	jmp    8008a7 <strncpy+0x16>
	}
	return ret;
}
  8008bc:	89 f0                	mov    %esi,%eax
  8008be:	5b                   	pop    %ebx
  8008bf:	5e                   	pop    %esi
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c2:	f3 0f 1e fb          	endbr32 
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
  8008cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d1:	8b 55 10             	mov    0x10(%ebp),%edx
  8008d4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d6:	85 d2                	test   %edx,%edx
  8008d8:	74 21                	je     8008fb <strlcpy+0x39>
  8008da:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008de:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008e0:	39 c2                	cmp    %eax,%edx
  8008e2:	74 14                	je     8008f8 <strlcpy+0x36>
  8008e4:	0f b6 19             	movzbl (%ecx),%ebx
  8008e7:	84 db                	test   %bl,%bl
  8008e9:	74 0b                	je     8008f6 <strlcpy+0x34>
			*dst++ = *src++;
  8008eb:	83 c1 01             	add    $0x1,%ecx
  8008ee:	83 c2 01             	add    $0x1,%edx
  8008f1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008f4:	eb ea                	jmp    8008e0 <strlcpy+0x1e>
  8008f6:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008f8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008fb:	29 f0                	sub    %esi,%eax
}
  8008fd:	5b                   	pop    %ebx
  8008fe:	5e                   	pop    %esi
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800901:	f3 0f 1e fb          	endbr32 
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80090e:	0f b6 01             	movzbl (%ecx),%eax
  800911:	84 c0                	test   %al,%al
  800913:	74 0c                	je     800921 <strcmp+0x20>
  800915:	3a 02                	cmp    (%edx),%al
  800917:	75 08                	jne    800921 <strcmp+0x20>
		p++, q++;
  800919:	83 c1 01             	add    $0x1,%ecx
  80091c:	83 c2 01             	add    $0x1,%edx
  80091f:	eb ed                	jmp    80090e <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800921:	0f b6 c0             	movzbl %al,%eax
  800924:	0f b6 12             	movzbl (%edx),%edx
  800927:	29 d0                	sub    %edx,%eax
}
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80092b:	f3 0f 1e fb          	endbr32 
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	53                   	push   %ebx
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	8b 55 0c             	mov    0xc(%ebp),%edx
  800939:	89 c3                	mov    %eax,%ebx
  80093b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80093e:	eb 06                	jmp    800946 <strncmp+0x1b>
		n--, p++, q++;
  800940:	83 c0 01             	add    $0x1,%eax
  800943:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800946:	39 d8                	cmp    %ebx,%eax
  800948:	74 16                	je     800960 <strncmp+0x35>
  80094a:	0f b6 08             	movzbl (%eax),%ecx
  80094d:	84 c9                	test   %cl,%cl
  80094f:	74 04                	je     800955 <strncmp+0x2a>
  800951:	3a 0a                	cmp    (%edx),%cl
  800953:	74 eb                	je     800940 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800955:	0f b6 00             	movzbl (%eax),%eax
  800958:	0f b6 12             	movzbl (%edx),%edx
  80095b:	29 d0                	sub    %edx,%eax
}
  80095d:	5b                   	pop    %ebx
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    
		return 0;
  800960:	b8 00 00 00 00       	mov    $0x0,%eax
  800965:	eb f6                	jmp    80095d <strncmp+0x32>

00800967 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800967:	f3 0f 1e fb          	endbr32 
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800975:	0f b6 10             	movzbl (%eax),%edx
  800978:	84 d2                	test   %dl,%dl
  80097a:	74 09                	je     800985 <strchr+0x1e>
		if (*s == c)
  80097c:	38 ca                	cmp    %cl,%dl
  80097e:	74 0a                	je     80098a <strchr+0x23>
	for (; *s; s++)
  800980:	83 c0 01             	add    $0x1,%eax
  800983:	eb f0                	jmp    800975 <strchr+0xe>
			return (char *) s;
	return 0;
  800985:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098c:	f3 0f 1e fb          	endbr32 
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80099a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80099d:	38 ca                	cmp    %cl,%dl
  80099f:	74 09                	je     8009aa <strfind+0x1e>
  8009a1:	84 d2                	test   %dl,%dl
  8009a3:	74 05                	je     8009aa <strfind+0x1e>
	for (; *s; s++)
  8009a5:	83 c0 01             	add    $0x1,%eax
  8009a8:	eb f0                	jmp    80099a <strfind+0xe>
			break;
	return (char *) s;
}
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009ac:	f3 0f 1e fb          	endbr32 
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	57                   	push   %edi
  8009b4:	56                   	push   %esi
  8009b5:	53                   	push   %ebx
  8009b6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009bc:	85 c9                	test   %ecx,%ecx
  8009be:	74 31                	je     8009f1 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c0:	89 f8                	mov    %edi,%eax
  8009c2:	09 c8                	or     %ecx,%eax
  8009c4:	a8 03                	test   $0x3,%al
  8009c6:	75 23                	jne    8009eb <memset+0x3f>
		c &= 0xFF;
  8009c8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009cc:	89 d3                	mov    %edx,%ebx
  8009ce:	c1 e3 08             	shl    $0x8,%ebx
  8009d1:	89 d0                	mov    %edx,%eax
  8009d3:	c1 e0 18             	shl    $0x18,%eax
  8009d6:	89 d6                	mov    %edx,%esi
  8009d8:	c1 e6 10             	shl    $0x10,%esi
  8009db:	09 f0                	or     %esi,%eax
  8009dd:	09 c2                	or     %eax,%edx
  8009df:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009e1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009e4:	89 d0                	mov    %edx,%eax
  8009e6:	fc                   	cld    
  8009e7:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e9:	eb 06                	jmp    8009f1 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ee:	fc                   	cld    
  8009ef:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009f1:	89 f8                	mov    %edi,%eax
  8009f3:	5b                   	pop    %ebx
  8009f4:	5e                   	pop    %esi
  8009f5:	5f                   	pop    %edi
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f8:	f3 0f 1e fb          	endbr32 
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	57                   	push   %edi
  800a00:	56                   	push   %esi
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
  800a04:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a07:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a0a:	39 c6                	cmp    %eax,%esi
  800a0c:	73 32                	jae    800a40 <memmove+0x48>
  800a0e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a11:	39 c2                	cmp    %eax,%edx
  800a13:	76 2b                	jbe    800a40 <memmove+0x48>
		s += n;
		d += n;
  800a15:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a18:	89 fe                	mov    %edi,%esi
  800a1a:	09 ce                	or     %ecx,%esi
  800a1c:	09 d6                	or     %edx,%esi
  800a1e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a24:	75 0e                	jne    800a34 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a26:	83 ef 04             	sub    $0x4,%edi
  800a29:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a2c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a2f:	fd                   	std    
  800a30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a32:	eb 09                	jmp    800a3d <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a34:	83 ef 01             	sub    $0x1,%edi
  800a37:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a3a:	fd                   	std    
  800a3b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a3d:	fc                   	cld    
  800a3e:	eb 1a                	jmp    800a5a <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a40:	89 c2                	mov    %eax,%edx
  800a42:	09 ca                	or     %ecx,%edx
  800a44:	09 f2                	or     %esi,%edx
  800a46:	f6 c2 03             	test   $0x3,%dl
  800a49:	75 0a                	jne    800a55 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a4b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a4e:	89 c7                	mov    %eax,%edi
  800a50:	fc                   	cld    
  800a51:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a53:	eb 05                	jmp    800a5a <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a55:	89 c7                	mov    %eax,%edi
  800a57:	fc                   	cld    
  800a58:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a5a:	5e                   	pop    %esi
  800a5b:	5f                   	pop    %edi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5e:	f3 0f 1e fb          	endbr32 
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a68:	ff 75 10             	pushl  0x10(%ebp)
  800a6b:	ff 75 0c             	pushl  0xc(%ebp)
  800a6e:	ff 75 08             	pushl  0x8(%ebp)
  800a71:	e8 82 ff ff ff       	call   8009f8 <memmove>
}
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a78:	f3 0f 1e fb          	endbr32 
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
  800a84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a87:	89 c6                	mov    %eax,%esi
  800a89:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8c:	39 f0                	cmp    %esi,%eax
  800a8e:	74 1c                	je     800aac <memcmp+0x34>
		if (*s1 != *s2)
  800a90:	0f b6 08             	movzbl (%eax),%ecx
  800a93:	0f b6 1a             	movzbl (%edx),%ebx
  800a96:	38 d9                	cmp    %bl,%cl
  800a98:	75 08                	jne    800aa2 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	83 c2 01             	add    $0x1,%edx
  800aa0:	eb ea                	jmp    800a8c <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800aa2:	0f b6 c1             	movzbl %cl,%eax
  800aa5:	0f b6 db             	movzbl %bl,%ebx
  800aa8:	29 d8                	sub    %ebx,%eax
  800aaa:	eb 05                	jmp    800ab1 <memcmp+0x39>
	}

	return 0;
  800aac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab1:	5b                   	pop    %ebx
  800ab2:	5e                   	pop    %esi
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab5:	f3 0f 1e fb          	endbr32 
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	8b 45 08             	mov    0x8(%ebp),%eax
  800abf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ac2:	89 c2                	mov    %eax,%edx
  800ac4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ac7:	39 d0                	cmp    %edx,%eax
  800ac9:	73 09                	jae    800ad4 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800acb:	38 08                	cmp    %cl,(%eax)
  800acd:	74 05                	je     800ad4 <memfind+0x1f>
	for (; s < ends; s++)
  800acf:	83 c0 01             	add    $0x1,%eax
  800ad2:	eb f3                	jmp    800ac7 <memfind+0x12>
			break;
	return (void *) s;
}
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ad6:	f3 0f 1e fb          	endbr32 
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	57                   	push   %edi
  800ade:	56                   	push   %esi
  800adf:	53                   	push   %ebx
  800ae0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae6:	eb 03                	jmp    800aeb <strtol+0x15>
		s++;
  800ae8:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800aeb:	0f b6 01             	movzbl (%ecx),%eax
  800aee:	3c 20                	cmp    $0x20,%al
  800af0:	74 f6                	je     800ae8 <strtol+0x12>
  800af2:	3c 09                	cmp    $0x9,%al
  800af4:	74 f2                	je     800ae8 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800af6:	3c 2b                	cmp    $0x2b,%al
  800af8:	74 2a                	je     800b24 <strtol+0x4e>
	int neg = 0;
  800afa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800aff:	3c 2d                	cmp    $0x2d,%al
  800b01:	74 2b                	je     800b2e <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b03:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b09:	75 0f                	jne    800b1a <strtol+0x44>
  800b0b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b0e:	74 28                	je     800b38 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b10:	85 db                	test   %ebx,%ebx
  800b12:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b17:	0f 44 d8             	cmove  %eax,%ebx
  800b1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b22:	eb 46                	jmp    800b6a <strtol+0x94>
		s++;
  800b24:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b27:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2c:	eb d5                	jmp    800b03 <strtol+0x2d>
		s++, neg = 1;
  800b2e:	83 c1 01             	add    $0x1,%ecx
  800b31:	bf 01 00 00 00       	mov    $0x1,%edi
  800b36:	eb cb                	jmp    800b03 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b38:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b3c:	74 0e                	je     800b4c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b3e:	85 db                	test   %ebx,%ebx
  800b40:	75 d8                	jne    800b1a <strtol+0x44>
		s++, base = 8;
  800b42:	83 c1 01             	add    $0x1,%ecx
  800b45:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b4a:	eb ce                	jmp    800b1a <strtol+0x44>
		s += 2, base = 16;
  800b4c:	83 c1 02             	add    $0x2,%ecx
  800b4f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b54:	eb c4                	jmp    800b1a <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b56:	0f be d2             	movsbl %dl,%edx
  800b59:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b5c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b5f:	7d 3a                	jge    800b9b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b61:	83 c1 01             	add    $0x1,%ecx
  800b64:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b68:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b6a:	0f b6 11             	movzbl (%ecx),%edx
  800b6d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b70:	89 f3                	mov    %esi,%ebx
  800b72:	80 fb 09             	cmp    $0x9,%bl
  800b75:	76 df                	jbe    800b56 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b77:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b7a:	89 f3                	mov    %esi,%ebx
  800b7c:	80 fb 19             	cmp    $0x19,%bl
  800b7f:	77 08                	ja     800b89 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b81:	0f be d2             	movsbl %dl,%edx
  800b84:	83 ea 57             	sub    $0x57,%edx
  800b87:	eb d3                	jmp    800b5c <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b89:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b8c:	89 f3                	mov    %esi,%ebx
  800b8e:	80 fb 19             	cmp    $0x19,%bl
  800b91:	77 08                	ja     800b9b <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b93:	0f be d2             	movsbl %dl,%edx
  800b96:	83 ea 37             	sub    $0x37,%edx
  800b99:	eb c1                	jmp    800b5c <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b9b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b9f:	74 05                	je     800ba6 <strtol+0xd0>
		*endptr = (char *) s;
  800ba1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba4:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ba6:	89 c2                	mov    %eax,%edx
  800ba8:	f7 da                	neg    %edx
  800baa:	85 ff                	test   %edi,%edi
  800bac:	0f 45 c2             	cmovne %edx,%eax
}
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb4:	f3 0f 1e fb          	endbr32 
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc9:	89 c3                	mov    %eax,%ebx
  800bcb:	89 c7                	mov    %eax,%edi
  800bcd:	89 c6                	mov    %eax,%esi
  800bcf:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bd6:	f3 0f 1e fb          	endbr32 
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be0:	ba 00 00 00 00       	mov    $0x0,%edx
  800be5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bea:	89 d1                	mov    %edx,%ecx
  800bec:	89 d3                	mov    %edx,%ebx
  800bee:	89 d7                	mov    %edx,%edi
  800bf0:	89 d6                	mov    %edx,%esi
  800bf2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bf9:	f3 0f 1e fb          	endbr32 
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c06:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c13:	89 cb                	mov    %ecx,%ebx
  800c15:	89 cf                	mov    %ecx,%edi
  800c17:	89 ce                	mov    %ecx,%esi
  800c19:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	7f 08                	jg     800c27 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	50                   	push   %eax
  800c2b:	6a 03                	push   $0x3
  800c2d:	68 3f 23 80 00       	push   $0x80233f
  800c32:	6a 23                	push   $0x23
  800c34:	68 5c 23 80 00       	push   $0x80235c
  800c39:	e8 14 f5 ff ff       	call   800152 <_panic>

00800c3e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c3e:	f3 0f 1e fb          	endbr32 
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c48:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4d:	b8 02 00 00 00       	mov    $0x2,%eax
  800c52:	89 d1                	mov    %edx,%ecx
  800c54:	89 d3                	mov    %edx,%ebx
  800c56:	89 d7                	mov    %edx,%edi
  800c58:	89 d6                	mov    %edx,%esi
  800c5a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_yield>:

void
sys_yield(void)
{
  800c61:	f3 0f 1e fb          	endbr32 
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c70:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c75:	89 d1                	mov    %edx,%ecx
  800c77:	89 d3                	mov    %edx,%ebx
  800c79:	89 d7                	mov    %edx,%edi
  800c7b:	89 d6                	mov    %edx,%esi
  800c7d:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c84:	f3 0f 1e fb          	endbr32 
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
  800c8e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c91:	be 00 00 00 00       	mov    $0x0,%esi
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9c:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca4:	89 f7                	mov    %esi,%edi
  800ca6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	7f 08                	jg     800cb4 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb4:	83 ec 0c             	sub    $0xc,%esp
  800cb7:	50                   	push   %eax
  800cb8:	6a 04                	push   $0x4
  800cba:	68 3f 23 80 00       	push   $0x80233f
  800cbf:	6a 23                	push   $0x23
  800cc1:	68 5c 23 80 00       	push   $0x80235c
  800cc6:	e8 87 f4 ff ff       	call   800152 <_panic>

00800ccb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ccb:	f3 0f 1e fb          	endbr32 
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
  800cd5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cde:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce9:	8b 75 18             	mov    0x18(%ebp),%esi
  800cec:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	7f 08                	jg     800cfa <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfa:	83 ec 0c             	sub    $0xc,%esp
  800cfd:	50                   	push   %eax
  800cfe:	6a 05                	push   $0x5
  800d00:	68 3f 23 80 00       	push   $0x80233f
  800d05:	6a 23                	push   $0x23
  800d07:	68 5c 23 80 00       	push   $0x80235c
  800d0c:	e8 41 f4 ff ff       	call   800152 <_panic>

00800d11 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d11:	f3 0f 1e fb          	endbr32 
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	57                   	push   %edi
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
  800d1b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d29:	b8 06 00 00 00       	mov    $0x6,%eax
  800d2e:	89 df                	mov    %ebx,%edi
  800d30:	89 de                	mov    %ebx,%esi
  800d32:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d34:	85 c0                	test   %eax,%eax
  800d36:	7f 08                	jg     800d40 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d40:	83 ec 0c             	sub    $0xc,%esp
  800d43:	50                   	push   %eax
  800d44:	6a 06                	push   $0x6
  800d46:	68 3f 23 80 00       	push   $0x80233f
  800d4b:	6a 23                	push   $0x23
  800d4d:	68 5c 23 80 00       	push   $0x80235c
  800d52:	e8 fb f3 ff ff       	call   800152 <_panic>

00800d57 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d57:	f3 0f 1e fb          	endbr32 
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6f:	b8 08 00 00 00       	mov    $0x8,%eax
  800d74:	89 df                	mov    %ebx,%edi
  800d76:	89 de                	mov    %ebx,%esi
  800d78:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	7f 08                	jg     800d86 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d86:	83 ec 0c             	sub    $0xc,%esp
  800d89:	50                   	push   %eax
  800d8a:	6a 08                	push   $0x8
  800d8c:	68 3f 23 80 00       	push   $0x80233f
  800d91:	6a 23                	push   $0x23
  800d93:	68 5c 23 80 00       	push   $0x80235c
  800d98:	e8 b5 f3 ff ff       	call   800152 <_panic>

00800d9d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d9d:	f3 0f 1e fb          	endbr32 
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
  800da7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800daa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800daf:	8b 55 08             	mov    0x8(%ebp),%edx
  800db2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db5:	b8 09 00 00 00       	mov    $0x9,%eax
  800dba:	89 df                	mov    %ebx,%edi
  800dbc:	89 de                	mov    %ebx,%esi
  800dbe:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	7f 08                	jg     800dcc <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcc:	83 ec 0c             	sub    $0xc,%esp
  800dcf:	50                   	push   %eax
  800dd0:	6a 09                	push   $0x9
  800dd2:	68 3f 23 80 00       	push   $0x80233f
  800dd7:	6a 23                	push   $0x23
  800dd9:	68 5c 23 80 00       	push   $0x80235c
  800dde:	e8 6f f3 ff ff       	call   800152 <_panic>

00800de3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de3:	f3 0f 1e fb          	endbr32 
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	57                   	push   %edi
  800deb:	56                   	push   %esi
  800dec:	53                   	push   %ebx
  800ded:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800df0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df5:	8b 55 08             	mov    0x8(%ebp),%edx
  800df8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e00:	89 df                	mov    %ebx,%edi
  800e02:	89 de                	mov    %ebx,%esi
  800e04:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e06:	85 c0                	test   %eax,%eax
  800e08:	7f 08                	jg     800e12 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e12:	83 ec 0c             	sub    $0xc,%esp
  800e15:	50                   	push   %eax
  800e16:	6a 0a                	push   $0xa
  800e18:	68 3f 23 80 00       	push   $0x80233f
  800e1d:	6a 23                	push   $0x23
  800e1f:	68 5c 23 80 00       	push   $0x80235c
  800e24:	e8 29 f3 ff ff       	call   800152 <_panic>

00800e29 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e29:	f3 0f 1e fb          	endbr32 
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	57                   	push   %edi
  800e31:	56                   	push   %esi
  800e32:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e33:	8b 55 08             	mov    0x8(%ebp),%edx
  800e36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e39:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e3e:	be 00 00 00 00       	mov    $0x0,%esi
  800e43:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e46:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e49:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e4b:	5b                   	pop    %ebx
  800e4c:	5e                   	pop    %esi
  800e4d:	5f                   	pop    %edi
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e50:	f3 0f 1e fb          	endbr32 
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	57                   	push   %edi
  800e58:	56                   	push   %esi
  800e59:	53                   	push   %ebx
  800e5a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e62:	8b 55 08             	mov    0x8(%ebp),%edx
  800e65:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e6a:	89 cb                	mov    %ecx,%ebx
  800e6c:	89 cf                	mov    %ecx,%edi
  800e6e:	89 ce                	mov    %ecx,%esi
  800e70:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e72:	85 c0                	test   %eax,%eax
  800e74:	7f 08                	jg     800e7e <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e79:	5b                   	pop    %ebx
  800e7a:	5e                   	pop    %esi
  800e7b:	5f                   	pop    %edi
  800e7c:	5d                   	pop    %ebp
  800e7d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7e:	83 ec 0c             	sub    $0xc,%esp
  800e81:	50                   	push   %eax
  800e82:	6a 0d                	push   $0xd
  800e84:	68 3f 23 80 00       	push   $0x80233f
  800e89:	6a 23                	push   $0x23
  800e8b:	68 5c 23 80 00       	push   $0x80235c
  800e90:	e8 bd f2 ff ff       	call   800152 <_panic>

00800e95 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e95:	f3 0f 1e fb          	endbr32 
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9f:	05 00 00 00 30       	add    $0x30000000,%eax
  800ea4:	c1 e8 0c             	shr    $0xc,%eax
}
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ea9:	f3 0f 1e fb          	endbr32 
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb3:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800eb8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ebd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ec4:	f3 0f 1e fb          	endbr32 
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ed0:	89 c2                	mov    %eax,%edx
  800ed2:	c1 ea 16             	shr    $0x16,%edx
  800ed5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800edc:	f6 c2 01             	test   $0x1,%dl
  800edf:	74 2d                	je     800f0e <fd_alloc+0x4a>
  800ee1:	89 c2                	mov    %eax,%edx
  800ee3:	c1 ea 0c             	shr    $0xc,%edx
  800ee6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eed:	f6 c2 01             	test   $0x1,%dl
  800ef0:	74 1c                	je     800f0e <fd_alloc+0x4a>
  800ef2:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800ef7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800efc:	75 d2                	jne    800ed0 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800efe:	8b 45 08             	mov    0x8(%ebp),%eax
  800f01:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800f07:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800f0c:	eb 0a                	jmp    800f18 <fd_alloc+0x54>
			*fd_store = fd;
  800f0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f11:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f1a:	f3 0f 1e fb          	endbr32 
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f24:	83 f8 1f             	cmp    $0x1f,%eax
  800f27:	77 30                	ja     800f59 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f29:	c1 e0 0c             	shl    $0xc,%eax
  800f2c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f31:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f37:	f6 c2 01             	test   $0x1,%dl
  800f3a:	74 24                	je     800f60 <fd_lookup+0x46>
  800f3c:	89 c2                	mov    %eax,%edx
  800f3e:	c1 ea 0c             	shr    $0xc,%edx
  800f41:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f48:	f6 c2 01             	test   $0x1,%dl
  800f4b:	74 1a                	je     800f67 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f50:	89 02                	mov    %eax,(%edx)
	return 0;
  800f52:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    
		return -E_INVAL;
  800f59:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f5e:	eb f7                	jmp    800f57 <fd_lookup+0x3d>
		return -E_INVAL;
  800f60:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f65:	eb f0                	jmp    800f57 <fd_lookup+0x3d>
  800f67:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f6c:	eb e9                	jmp    800f57 <fd_lookup+0x3d>

00800f6e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f6e:	f3 0f 1e fb          	endbr32 
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	83 ec 08             	sub    $0x8,%esp
  800f78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f7b:	ba e8 23 80 00       	mov    $0x8023e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f80:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800f85:	39 08                	cmp    %ecx,(%eax)
  800f87:	74 33                	je     800fbc <dev_lookup+0x4e>
  800f89:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800f8c:	8b 02                	mov    (%edx),%eax
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	75 f3                	jne    800f85 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f92:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800f97:	8b 40 48             	mov    0x48(%eax),%eax
  800f9a:	83 ec 04             	sub    $0x4,%esp
  800f9d:	51                   	push   %ecx
  800f9e:	50                   	push   %eax
  800f9f:	68 6c 23 80 00       	push   $0x80236c
  800fa4:	e8 90 f2 ff ff       	call   800239 <cprintf>
	*dev = 0;
  800fa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fba:	c9                   	leave  
  800fbb:	c3                   	ret    
			*dev = devtab[i];
  800fbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbf:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc6:	eb f2                	jmp    800fba <dev_lookup+0x4c>

00800fc8 <fd_close>:
{
  800fc8:	f3 0f 1e fb          	endbr32 
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	57                   	push   %edi
  800fd0:	56                   	push   %esi
  800fd1:	53                   	push   %ebx
  800fd2:	83 ec 24             	sub    $0x24,%esp
  800fd5:	8b 75 08             	mov    0x8(%ebp),%esi
  800fd8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fdb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fde:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fdf:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fe5:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fe8:	50                   	push   %eax
  800fe9:	e8 2c ff ff ff       	call   800f1a <fd_lookup>
  800fee:	89 c3                	mov    %eax,%ebx
  800ff0:	83 c4 10             	add    $0x10,%esp
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	78 05                	js     800ffc <fd_close+0x34>
	    || fd != fd2)
  800ff7:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800ffa:	74 16                	je     801012 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800ffc:	89 f8                	mov    %edi,%eax
  800ffe:	84 c0                	test   %al,%al
  801000:	b8 00 00 00 00       	mov    $0x0,%eax
  801005:	0f 44 d8             	cmove  %eax,%ebx
}
  801008:	89 d8                	mov    %ebx,%eax
  80100a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100d:	5b                   	pop    %ebx
  80100e:	5e                   	pop    %esi
  80100f:	5f                   	pop    %edi
  801010:	5d                   	pop    %ebp
  801011:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801012:	83 ec 08             	sub    $0x8,%esp
  801015:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801018:	50                   	push   %eax
  801019:	ff 36                	pushl  (%esi)
  80101b:	e8 4e ff ff ff       	call   800f6e <dev_lookup>
  801020:	89 c3                	mov    %eax,%ebx
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	85 c0                	test   %eax,%eax
  801027:	78 1a                	js     801043 <fd_close+0x7b>
		if (dev->dev_close)
  801029:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80102c:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80102f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801034:	85 c0                	test   %eax,%eax
  801036:	74 0b                	je     801043 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801038:	83 ec 0c             	sub    $0xc,%esp
  80103b:	56                   	push   %esi
  80103c:	ff d0                	call   *%eax
  80103e:	89 c3                	mov    %eax,%ebx
  801040:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801043:	83 ec 08             	sub    $0x8,%esp
  801046:	56                   	push   %esi
  801047:	6a 00                	push   $0x0
  801049:	e8 c3 fc ff ff       	call   800d11 <sys_page_unmap>
	return r;
  80104e:	83 c4 10             	add    $0x10,%esp
  801051:	eb b5                	jmp    801008 <fd_close+0x40>

00801053 <close>:

int
close(int fdnum)
{
  801053:	f3 0f 1e fb          	endbr32 
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80105d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801060:	50                   	push   %eax
  801061:	ff 75 08             	pushl  0x8(%ebp)
  801064:	e8 b1 fe ff ff       	call   800f1a <fd_lookup>
  801069:	83 c4 10             	add    $0x10,%esp
  80106c:	85 c0                	test   %eax,%eax
  80106e:	79 02                	jns    801072 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801070:	c9                   	leave  
  801071:	c3                   	ret    
		return fd_close(fd, 1);
  801072:	83 ec 08             	sub    $0x8,%esp
  801075:	6a 01                	push   $0x1
  801077:	ff 75 f4             	pushl  -0xc(%ebp)
  80107a:	e8 49 ff ff ff       	call   800fc8 <fd_close>
  80107f:	83 c4 10             	add    $0x10,%esp
  801082:	eb ec                	jmp    801070 <close+0x1d>

00801084 <close_all>:

void
close_all(void)
{
  801084:	f3 0f 1e fb          	endbr32 
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	53                   	push   %ebx
  80108c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80108f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801094:	83 ec 0c             	sub    $0xc,%esp
  801097:	53                   	push   %ebx
  801098:	e8 b6 ff ff ff       	call   801053 <close>
	for (i = 0; i < MAXFD; i++)
  80109d:	83 c3 01             	add    $0x1,%ebx
  8010a0:	83 c4 10             	add    $0x10,%esp
  8010a3:	83 fb 20             	cmp    $0x20,%ebx
  8010a6:	75 ec                	jne    801094 <close_all+0x10>
}
  8010a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ab:	c9                   	leave  
  8010ac:	c3                   	ret    

008010ad <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010ad:	f3 0f 1e fb          	endbr32 
  8010b1:	55                   	push   %ebp
  8010b2:	89 e5                	mov    %esp,%ebp
  8010b4:	57                   	push   %edi
  8010b5:	56                   	push   %esi
  8010b6:	53                   	push   %ebx
  8010b7:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010ba:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010bd:	50                   	push   %eax
  8010be:	ff 75 08             	pushl  0x8(%ebp)
  8010c1:	e8 54 fe ff ff       	call   800f1a <fd_lookup>
  8010c6:	89 c3                	mov    %eax,%ebx
  8010c8:	83 c4 10             	add    $0x10,%esp
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	0f 88 81 00 00 00    	js     801154 <dup+0xa7>
		return r;
	close(newfdnum);
  8010d3:	83 ec 0c             	sub    $0xc,%esp
  8010d6:	ff 75 0c             	pushl  0xc(%ebp)
  8010d9:	e8 75 ff ff ff       	call   801053 <close>

	newfd = INDEX2FD(newfdnum);
  8010de:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010e1:	c1 e6 0c             	shl    $0xc,%esi
  8010e4:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010ea:	83 c4 04             	add    $0x4,%esp
  8010ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f0:	e8 b4 fd ff ff       	call   800ea9 <fd2data>
  8010f5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010f7:	89 34 24             	mov    %esi,(%esp)
  8010fa:	e8 aa fd ff ff       	call   800ea9 <fd2data>
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801104:	89 d8                	mov    %ebx,%eax
  801106:	c1 e8 16             	shr    $0x16,%eax
  801109:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801110:	a8 01                	test   $0x1,%al
  801112:	74 11                	je     801125 <dup+0x78>
  801114:	89 d8                	mov    %ebx,%eax
  801116:	c1 e8 0c             	shr    $0xc,%eax
  801119:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801120:	f6 c2 01             	test   $0x1,%dl
  801123:	75 39                	jne    80115e <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801125:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801128:	89 d0                	mov    %edx,%eax
  80112a:	c1 e8 0c             	shr    $0xc,%eax
  80112d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801134:	83 ec 0c             	sub    $0xc,%esp
  801137:	25 07 0e 00 00       	and    $0xe07,%eax
  80113c:	50                   	push   %eax
  80113d:	56                   	push   %esi
  80113e:	6a 00                	push   $0x0
  801140:	52                   	push   %edx
  801141:	6a 00                	push   $0x0
  801143:	e8 83 fb ff ff       	call   800ccb <sys_page_map>
  801148:	89 c3                	mov    %eax,%ebx
  80114a:	83 c4 20             	add    $0x20,%esp
  80114d:	85 c0                	test   %eax,%eax
  80114f:	78 31                	js     801182 <dup+0xd5>
		goto err;

	return newfdnum;
  801151:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801154:	89 d8                	mov    %ebx,%eax
  801156:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801159:	5b                   	pop    %ebx
  80115a:	5e                   	pop    %esi
  80115b:	5f                   	pop    %edi
  80115c:	5d                   	pop    %ebp
  80115d:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80115e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801165:	83 ec 0c             	sub    $0xc,%esp
  801168:	25 07 0e 00 00       	and    $0xe07,%eax
  80116d:	50                   	push   %eax
  80116e:	57                   	push   %edi
  80116f:	6a 00                	push   $0x0
  801171:	53                   	push   %ebx
  801172:	6a 00                	push   $0x0
  801174:	e8 52 fb ff ff       	call   800ccb <sys_page_map>
  801179:	89 c3                	mov    %eax,%ebx
  80117b:	83 c4 20             	add    $0x20,%esp
  80117e:	85 c0                	test   %eax,%eax
  801180:	79 a3                	jns    801125 <dup+0x78>
	sys_page_unmap(0, newfd);
  801182:	83 ec 08             	sub    $0x8,%esp
  801185:	56                   	push   %esi
  801186:	6a 00                	push   $0x0
  801188:	e8 84 fb ff ff       	call   800d11 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80118d:	83 c4 08             	add    $0x8,%esp
  801190:	57                   	push   %edi
  801191:	6a 00                	push   $0x0
  801193:	e8 79 fb ff ff       	call   800d11 <sys_page_unmap>
	return r;
  801198:	83 c4 10             	add    $0x10,%esp
  80119b:	eb b7                	jmp    801154 <dup+0xa7>

0080119d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80119d:	f3 0f 1e fb          	endbr32 
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
  8011a4:	53                   	push   %ebx
  8011a5:	83 ec 1c             	sub    $0x1c,%esp
  8011a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ae:	50                   	push   %eax
  8011af:	53                   	push   %ebx
  8011b0:	e8 65 fd ff ff       	call   800f1a <fd_lookup>
  8011b5:	83 c4 10             	add    $0x10,%esp
  8011b8:	85 c0                	test   %eax,%eax
  8011ba:	78 3f                	js     8011fb <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011bc:	83 ec 08             	sub    $0x8,%esp
  8011bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c2:	50                   	push   %eax
  8011c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c6:	ff 30                	pushl  (%eax)
  8011c8:	e8 a1 fd ff ff       	call   800f6e <dev_lookup>
  8011cd:	83 c4 10             	add    $0x10,%esp
  8011d0:	85 c0                	test   %eax,%eax
  8011d2:	78 27                	js     8011fb <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011d7:	8b 42 08             	mov    0x8(%edx),%eax
  8011da:	83 e0 03             	and    $0x3,%eax
  8011dd:	83 f8 01             	cmp    $0x1,%eax
  8011e0:	74 1e                	je     801200 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e5:	8b 40 08             	mov    0x8(%eax),%eax
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	74 35                	je     801221 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011ec:	83 ec 04             	sub    $0x4,%esp
  8011ef:	ff 75 10             	pushl  0x10(%ebp)
  8011f2:	ff 75 0c             	pushl  0xc(%ebp)
  8011f5:	52                   	push   %edx
  8011f6:	ff d0                	call   *%eax
  8011f8:	83 c4 10             	add    $0x10,%esp
}
  8011fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011fe:	c9                   	leave  
  8011ff:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801200:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801205:	8b 40 48             	mov    0x48(%eax),%eax
  801208:	83 ec 04             	sub    $0x4,%esp
  80120b:	53                   	push   %ebx
  80120c:	50                   	push   %eax
  80120d:	68 ad 23 80 00       	push   $0x8023ad
  801212:	e8 22 f0 ff ff       	call   800239 <cprintf>
		return -E_INVAL;
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80121f:	eb da                	jmp    8011fb <read+0x5e>
		return -E_NOT_SUPP;
  801221:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801226:	eb d3                	jmp    8011fb <read+0x5e>

00801228 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801228:	f3 0f 1e fb          	endbr32 
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	57                   	push   %edi
  801230:	56                   	push   %esi
  801231:	53                   	push   %ebx
  801232:	83 ec 0c             	sub    $0xc,%esp
  801235:	8b 7d 08             	mov    0x8(%ebp),%edi
  801238:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80123b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801240:	eb 02                	jmp    801244 <readn+0x1c>
  801242:	01 c3                	add    %eax,%ebx
  801244:	39 f3                	cmp    %esi,%ebx
  801246:	73 21                	jae    801269 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801248:	83 ec 04             	sub    $0x4,%esp
  80124b:	89 f0                	mov    %esi,%eax
  80124d:	29 d8                	sub    %ebx,%eax
  80124f:	50                   	push   %eax
  801250:	89 d8                	mov    %ebx,%eax
  801252:	03 45 0c             	add    0xc(%ebp),%eax
  801255:	50                   	push   %eax
  801256:	57                   	push   %edi
  801257:	e8 41 ff ff ff       	call   80119d <read>
		if (m < 0)
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	85 c0                	test   %eax,%eax
  801261:	78 04                	js     801267 <readn+0x3f>
			return m;
		if (m == 0)
  801263:	75 dd                	jne    801242 <readn+0x1a>
  801265:	eb 02                	jmp    801269 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801267:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801269:	89 d8                	mov    %ebx,%eax
  80126b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80126e:	5b                   	pop    %ebx
  80126f:	5e                   	pop    %esi
  801270:	5f                   	pop    %edi
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    

00801273 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801273:	f3 0f 1e fb          	endbr32 
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	53                   	push   %ebx
  80127b:	83 ec 1c             	sub    $0x1c,%esp
  80127e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801281:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801284:	50                   	push   %eax
  801285:	53                   	push   %ebx
  801286:	e8 8f fc ff ff       	call   800f1a <fd_lookup>
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	85 c0                	test   %eax,%eax
  801290:	78 3a                	js     8012cc <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801292:	83 ec 08             	sub    $0x8,%esp
  801295:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801298:	50                   	push   %eax
  801299:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129c:	ff 30                	pushl  (%eax)
  80129e:	e8 cb fc ff ff       	call   800f6e <dev_lookup>
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	78 22                	js     8012cc <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ad:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b1:	74 1e                	je     8012d1 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b6:	8b 52 0c             	mov    0xc(%edx),%edx
  8012b9:	85 d2                	test   %edx,%edx
  8012bb:	74 35                	je     8012f2 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012bd:	83 ec 04             	sub    $0x4,%esp
  8012c0:	ff 75 10             	pushl  0x10(%ebp)
  8012c3:	ff 75 0c             	pushl  0xc(%ebp)
  8012c6:	50                   	push   %eax
  8012c7:	ff d2                	call   *%edx
  8012c9:	83 c4 10             	add    $0x10,%esp
}
  8012cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012cf:	c9                   	leave  
  8012d0:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012d1:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8012d6:	8b 40 48             	mov    0x48(%eax),%eax
  8012d9:	83 ec 04             	sub    $0x4,%esp
  8012dc:	53                   	push   %ebx
  8012dd:	50                   	push   %eax
  8012de:	68 c9 23 80 00       	push   $0x8023c9
  8012e3:	e8 51 ef ff ff       	call   800239 <cprintf>
		return -E_INVAL;
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f0:	eb da                	jmp    8012cc <write+0x59>
		return -E_NOT_SUPP;
  8012f2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012f7:	eb d3                	jmp    8012cc <write+0x59>

008012f9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012f9:	f3 0f 1e fb          	endbr32 
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801303:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801306:	50                   	push   %eax
  801307:	ff 75 08             	pushl  0x8(%ebp)
  80130a:	e8 0b fc ff ff       	call   800f1a <fd_lookup>
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	85 c0                	test   %eax,%eax
  801314:	78 0e                	js     801324 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801316:	8b 55 0c             	mov    0xc(%ebp),%edx
  801319:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80131c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80131f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801324:	c9                   	leave  
  801325:	c3                   	ret    

00801326 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801326:	f3 0f 1e fb          	endbr32 
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	53                   	push   %ebx
  80132e:	83 ec 1c             	sub    $0x1c,%esp
  801331:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801334:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801337:	50                   	push   %eax
  801338:	53                   	push   %ebx
  801339:	e8 dc fb ff ff       	call   800f1a <fd_lookup>
  80133e:	83 c4 10             	add    $0x10,%esp
  801341:	85 c0                	test   %eax,%eax
  801343:	78 37                	js     80137c <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801345:	83 ec 08             	sub    $0x8,%esp
  801348:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134b:	50                   	push   %eax
  80134c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134f:	ff 30                	pushl  (%eax)
  801351:	e8 18 fc ff ff       	call   800f6e <dev_lookup>
  801356:	83 c4 10             	add    $0x10,%esp
  801359:	85 c0                	test   %eax,%eax
  80135b:	78 1f                	js     80137c <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80135d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801360:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801364:	74 1b                	je     801381 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801366:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801369:	8b 52 18             	mov    0x18(%edx),%edx
  80136c:	85 d2                	test   %edx,%edx
  80136e:	74 32                	je     8013a2 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801370:	83 ec 08             	sub    $0x8,%esp
  801373:	ff 75 0c             	pushl  0xc(%ebp)
  801376:	50                   	push   %eax
  801377:	ff d2                	call   *%edx
  801379:	83 c4 10             	add    $0x10,%esp
}
  80137c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137f:	c9                   	leave  
  801380:	c3                   	ret    
			thisenv->env_id, fdnum);
  801381:	a1 20 40 c0 00       	mov    0xc04020,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801386:	8b 40 48             	mov    0x48(%eax),%eax
  801389:	83 ec 04             	sub    $0x4,%esp
  80138c:	53                   	push   %ebx
  80138d:	50                   	push   %eax
  80138e:	68 8c 23 80 00       	push   $0x80238c
  801393:	e8 a1 ee ff ff       	call   800239 <cprintf>
		return -E_INVAL;
  801398:	83 c4 10             	add    $0x10,%esp
  80139b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a0:	eb da                	jmp    80137c <ftruncate+0x56>
		return -E_NOT_SUPP;
  8013a2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013a7:	eb d3                	jmp    80137c <ftruncate+0x56>

008013a9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013a9:	f3 0f 1e fb          	endbr32 
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	53                   	push   %ebx
  8013b1:	83 ec 1c             	sub    $0x1c,%esp
  8013b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ba:	50                   	push   %eax
  8013bb:	ff 75 08             	pushl  0x8(%ebp)
  8013be:	e8 57 fb ff ff       	call   800f1a <fd_lookup>
  8013c3:	83 c4 10             	add    $0x10,%esp
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	78 4b                	js     801415 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ca:	83 ec 08             	sub    $0x8,%esp
  8013cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d0:	50                   	push   %eax
  8013d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d4:	ff 30                	pushl  (%eax)
  8013d6:	e8 93 fb ff ff       	call   800f6e <dev_lookup>
  8013db:	83 c4 10             	add    $0x10,%esp
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	78 33                	js     801415 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8013e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013e9:	74 2f                	je     80141a <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013eb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013ee:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013f5:	00 00 00 
	stat->st_isdir = 0;
  8013f8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013ff:	00 00 00 
	stat->st_dev = dev;
  801402:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801408:	83 ec 08             	sub    $0x8,%esp
  80140b:	53                   	push   %ebx
  80140c:	ff 75 f0             	pushl  -0x10(%ebp)
  80140f:	ff 50 14             	call   *0x14(%eax)
  801412:	83 c4 10             	add    $0x10,%esp
}
  801415:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801418:	c9                   	leave  
  801419:	c3                   	ret    
		return -E_NOT_SUPP;
  80141a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80141f:	eb f4                	jmp    801415 <fstat+0x6c>

00801421 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801421:	f3 0f 1e fb          	endbr32 
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	56                   	push   %esi
  801429:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80142a:	83 ec 08             	sub    $0x8,%esp
  80142d:	6a 00                	push   $0x0
  80142f:	ff 75 08             	pushl  0x8(%ebp)
  801432:	e8 cf 01 00 00       	call   801606 <open>
  801437:	89 c3                	mov    %eax,%ebx
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 1b                	js     80145b <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801440:	83 ec 08             	sub    $0x8,%esp
  801443:	ff 75 0c             	pushl  0xc(%ebp)
  801446:	50                   	push   %eax
  801447:	e8 5d ff ff ff       	call   8013a9 <fstat>
  80144c:	89 c6                	mov    %eax,%esi
	close(fd);
  80144e:	89 1c 24             	mov    %ebx,(%esp)
  801451:	e8 fd fb ff ff       	call   801053 <close>
	return r;
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	89 f3                	mov    %esi,%ebx
}
  80145b:	89 d8                	mov    %ebx,%eax
  80145d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801460:	5b                   	pop    %ebx
  801461:	5e                   	pop    %esi
  801462:	5d                   	pop    %ebp
  801463:	c3                   	ret    

00801464 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	56                   	push   %esi
  801468:	53                   	push   %ebx
  801469:	89 c6                	mov    %eax,%esi
  80146b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80146d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801474:	74 27                	je     80149d <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801476:	6a 07                	push   $0x7
  801478:	68 00 50 c0 00       	push   $0xc05000
  80147d:	56                   	push   %esi
  80147e:	ff 35 00 40 80 00    	pushl  0x804000
  801484:	e8 7c 07 00 00       	call   801c05 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801489:	83 c4 0c             	add    $0xc,%esp
  80148c:	6a 00                	push   $0x0
  80148e:	53                   	push   %ebx
  80148f:	6a 00                	push   $0x0
  801491:	e8 18 07 00 00       	call   801bae <ipc_recv>
}
  801496:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801499:	5b                   	pop    %ebx
  80149a:	5e                   	pop    %esi
  80149b:	5d                   	pop    %ebp
  80149c:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80149d:	83 ec 0c             	sub    $0xc,%esp
  8014a0:	6a 01                	push   $0x1
  8014a2:	e8 c4 07 00 00       	call   801c6b <ipc_find_env>
  8014a7:	a3 00 40 80 00       	mov    %eax,0x804000
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	eb c5                	jmp    801476 <fsipc+0x12>

008014b1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014b1:	f3 0f 1e fb          	endbr32 
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014be:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c1:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  8014c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c9:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d3:	b8 02 00 00 00       	mov    $0x2,%eax
  8014d8:	e8 87 ff ff ff       	call   801464 <fsipc>
}
  8014dd:	c9                   	leave  
  8014de:	c3                   	ret    

008014df <devfile_flush>:
{
  8014df:	f3 0f 1e fb          	endbr32 
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
  8014e6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ef:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  8014f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f9:	b8 06 00 00 00       	mov    $0x6,%eax
  8014fe:	e8 61 ff ff ff       	call   801464 <fsipc>
}
  801503:	c9                   	leave  
  801504:	c3                   	ret    

00801505 <devfile_stat>:
{
  801505:	f3 0f 1e fb          	endbr32 
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	53                   	push   %ebx
  80150d:	83 ec 04             	sub    $0x4,%esp
  801510:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801513:	8b 45 08             	mov    0x8(%ebp),%eax
  801516:	8b 40 0c             	mov    0xc(%eax),%eax
  801519:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80151e:	ba 00 00 00 00       	mov    $0x0,%edx
  801523:	b8 05 00 00 00       	mov    $0x5,%eax
  801528:	e8 37 ff ff ff       	call   801464 <fsipc>
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 2c                	js     80155d <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801531:	83 ec 08             	sub    $0x8,%esp
  801534:	68 00 50 c0 00       	push   $0xc05000
  801539:	53                   	push   %ebx
  80153a:	e8 03 f3 ff ff       	call   800842 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80153f:	a1 80 50 c0 00       	mov    0xc05080,%eax
  801544:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80154a:	a1 84 50 c0 00       	mov    0xc05084,%eax
  80154f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80155d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801560:	c9                   	leave  
  801561:	c3                   	ret    

00801562 <devfile_write>:
{
  801562:	f3 0f 1e fb          	endbr32 
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	83 ec 0c             	sub    $0xc,%esp
	panic("devfile_write not implemented");
  80156c:	68 f8 23 80 00       	push   $0x8023f8
  801571:	68 90 00 00 00       	push   $0x90
  801576:	68 16 24 80 00       	push   $0x802416
  80157b:	e8 d2 eb ff ff       	call   800152 <_panic>

00801580 <devfile_read>:
{
  801580:	f3 0f 1e fb          	endbr32 
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
  801587:	56                   	push   %esi
  801588:	53                   	push   %ebx
  801589:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80158c:	8b 45 08             	mov    0x8(%ebp),%eax
  80158f:	8b 40 0c             	mov    0xc(%eax),%eax
  801592:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  801597:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80159d:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a2:	b8 03 00 00 00       	mov    $0x3,%eax
  8015a7:	e8 b8 fe ff ff       	call   801464 <fsipc>
  8015ac:	89 c3                	mov    %eax,%ebx
  8015ae:	85 c0                	test   %eax,%eax
  8015b0:	78 1f                	js     8015d1 <devfile_read+0x51>
	assert(r <= n);
  8015b2:	39 f0                	cmp    %esi,%eax
  8015b4:	77 24                	ja     8015da <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8015b6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015bb:	7f 33                	jg     8015f0 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015bd:	83 ec 04             	sub    $0x4,%esp
  8015c0:	50                   	push   %eax
  8015c1:	68 00 50 c0 00       	push   $0xc05000
  8015c6:	ff 75 0c             	pushl  0xc(%ebp)
  8015c9:	e8 2a f4 ff ff       	call   8009f8 <memmove>
	return r;
  8015ce:	83 c4 10             	add    $0x10,%esp
}
  8015d1:	89 d8                	mov    %ebx,%eax
  8015d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d6:	5b                   	pop    %ebx
  8015d7:	5e                   	pop    %esi
  8015d8:	5d                   	pop    %ebp
  8015d9:	c3                   	ret    
	assert(r <= n);
  8015da:	68 21 24 80 00       	push   $0x802421
  8015df:	68 28 24 80 00       	push   $0x802428
  8015e4:	6a 7c                	push   $0x7c
  8015e6:	68 16 24 80 00       	push   $0x802416
  8015eb:	e8 62 eb ff ff       	call   800152 <_panic>
	assert(r <= PGSIZE);
  8015f0:	68 3d 24 80 00       	push   $0x80243d
  8015f5:	68 28 24 80 00       	push   $0x802428
  8015fa:	6a 7d                	push   $0x7d
  8015fc:	68 16 24 80 00       	push   $0x802416
  801601:	e8 4c eb ff ff       	call   800152 <_panic>

00801606 <open>:
{
  801606:	f3 0f 1e fb          	endbr32 
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	56                   	push   %esi
  80160e:	53                   	push   %ebx
  80160f:	83 ec 1c             	sub    $0x1c,%esp
  801612:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801615:	56                   	push   %esi
  801616:	e8 e4 f1 ff ff       	call   8007ff <strlen>
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801623:	7f 6c                	jg     801691 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801625:	83 ec 0c             	sub    $0xc,%esp
  801628:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162b:	50                   	push   %eax
  80162c:	e8 93 f8 ff ff       	call   800ec4 <fd_alloc>
  801631:	89 c3                	mov    %eax,%ebx
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	85 c0                	test   %eax,%eax
  801638:	78 3c                	js     801676 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  80163a:	83 ec 08             	sub    $0x8,%esp
  80163d:	56                   	push   %esi
  80163e:	68 00 50 c0 00       	push   $0xc05000
  801643:	e8 fa f1 ff ff       	call   800842 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801648:	8b 45 0c             	mov    0xc(%ebp),%eax
  80164b:	a3 00 54 c0 00       	mov    %eax,0xc05400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801650:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801653:	b8 01 00 00 00       	mov    $0x1,%eax
  801658:	e8 07 fe ff ff       	call   801464 <fsipc>
  80165d:	89 c3                	mov    %eax,%ebx
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	85 c0                	test   %eax,%eax
  801664:	78 19                	js     80167f <open+0x79>
	return fd2num(fd);
  801666:	83 ec 0c             	sub    $0xc,%esp
  801669:	ff 75 f4             	pushl  -0xc(%ebp)
  80166c:	e8 24 f8 ff ff       	call   800e95 <fd2num>
  801671:	89 c3                	mov    %eax,%ebx
  801673:	83 c4 10             	add    $0x10,%esp
}
  801676:	89 d8                	mov    %ebx,%eax
  801678:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167b:	5b                   	pop    %ebx
  80167c:	5e                   	pop    %esi
  80167d:	5d                   	pop    %ebp
  80167e:	c3                   	ret    
		fd_close(fd, 0);
  80167f:	83 ec 08             	sub    $0x8,%esp
  801682:	6a 00                	push   $0x0
  801684:	ff 75 f4             	pushl  -0xc(%ebp)
  801687:	e8 3c f9 ff ff       	call   800fc8 <fd_close>
		return r;
  80168c:	83 c4 10             	add    $0x10,%esp
  80168f:	eb e5                	jmp    801676 <open+0x70>
		return -E_BAD_PATH;
  801691:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801696:	eb de                	jmp    801676 <open+0x70>

00801698 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801698:	f3 0f 1e fb          	endbr32 
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a7:	b8 08 00 00 00       	mov    $0x8,%eax
  8016ac:	e8 b3 fd ff ff       	call   801464 <fsipc>
}
  8016b1:	c9                   	leave  
  8016b2:	c3                   	ret    

008016b3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016b3:	f3 0f 1e fb          	endbr32 
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	56                   	push   %esi
  8016bb:	53                   	push   %ebx
  8016bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016bf:	83 ec 0c             	sub    $0xc,%esp
  8016c2:	ff 75 08             	pushl  0x8(%ebp)
  8016c5:	e8 df f7 ff ff       	call   800ea9 <fd2data>
  8016ca:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016cc:	83 c4 08             	add    $0x8,%esp
  8016cf:	68 49 24 80 00       	push   $0x802449
  8016d4:	53                   	push   %ebx
  8016d5:	e8 68 f1 ff ff       	call   800842 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016da:	8b 46 04             	mov    0x4(%esi),%eax
  8016dd:	2b 06                	sub    (%esi),%eax
  8016df:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016e5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016ec:	00 00 00 
	stat->st_dev = &devpipe;
  8016ef:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016f6:	30 80 00 
	return 0;
}
  8016f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8016fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801701:	5b                   	pop    %ebx
  801702:	5e                   	pop    %esi
  801703:	5d                   	pop    %ebp
  801704:	c3                   	ret    

00801705 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801705:	f3 0f 1e fb          	endbr32 
  801709:	55                   	push   %ebp
  80170a:	89 e5                	mov    %esp,%ebp
  80170c:	53                   	push   %ebx
  80170d:	83 ec 0c             	sub    $0xc,%esp
  801710:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801713:	53                   	push   %ebx
  801714:	6a 00                	push   $0x0
  801716:	e8 f6 f5 ff ff       	call   800d11 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80171b:	89 1c 24             	mov    %ebx,(%esp)
  80171e:	e8 86 f7 ff ff       	call   800ea9 <fd2data>
  801723:	83 c4 08             	add    $0x8,%esp
  801726:	50                   	push   %eax
  801727:	6a 00                	push   $0x0
  801729:	e8 e3 f5 ff ff       	call   800d11 <sys_page_unmap>
}
  80172e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801731:	c9                   	leave  
  801732:	c3                   	ret    

00801733 <_pipeisclosed>:
{
  801733:	55                   	push   %ebp
  801734:	89 e5                	mov    %esp,%ebp
  801736:	57                   	push   %edi
  801737:	56                   	push   %esi
  801738:	53                   	push   %ebx
  801739:	83 ec 1c             	sub    $0x1c,%esp
  80173c:	89 c7                	mov    %eax,%edi
  80173e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801740:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801745:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801748:	83 ec 0c             	sub    $0xc,%esp
  80174b:	57                   	push   %edi
  80174c:	e8 57 05 00 00       	call   801ca8 <pageref>
  801751:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801754:	89 34 24             	mov    %esi,(%esp)
  801757:	e8 4c 05 00 00       	call   801ca8 <pageref>
		nn = thisenv->env_runs;
  80175c:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801762:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801765:	83 c4 10             	add    $0x10,%esp
  801768:	39 cb                	cmp    %ecx,%ebx
  80176a:	74 1b                	je     801787 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80176c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80176f:	75 cf                	jne    801740 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801771:	8b 42 58             	mov    0x58(%edx),%eax
  801774:	6a 01                	push   $0x1
  801776:	50                   	push   %eax
  801777:	53                   	push   %ebx
  801778:	68 50 24 80 00       	push   $0x802450
  80177d:	e8 b7 ea ff ff       	call   800239 <cprintf>
  801782:	83 c4 10             	add    $0x10,%esp
  801785:	eb b9                	jmp    801740 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801787:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80178a:	0f 94 c0             	sete   %al
  80178d:	0f b6 c0             	movzbl %al,%eax
}
  801790:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801793:	5b                   	pop    %ebx
  801794:	5e                   	pop    %esi
  801795:	5f                   	pop    %edi
  801796:	5d                   	pop    %ebp
  801797:	c3                   	ret    

00801798 <devpipe_write>:
{
  801798:	f3 0f 1e fb          	endbr32 
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	57                   	push   %edi
  8017a0:	56                   	push   %esi
  8017a1:	53                   	push   %ebx
  8017a2:	83 ec 28             	sub    $0x28,%esp
  8017a5:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8017a8:	56                   	push   %esi
  8017a9:	e8 fb f6 ff ff       	call   800ea9 <fd2data>
  8017ae:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8017b0:	83 c4 10             	add    $0x10,%esp
  8017b3:	bf 00 00 00 00       	mov    $0x0,%edi
  8017b8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017bb:	74 4f                	je     80180c <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017bd:	8b 43 04             	mov    0x4(%ebx),%eax
  8017c0:	8b 0b                	mov    (%ebx),%ecx
  8017c2:	8d 51 20             	lea    0x20(%ecx),%edx
  8017c5:	39 d0                	cmp    %edx,%eax
  8017c7:	72 14                	jb     8017dd <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8017c9:	89 da                	mov    %ebx,%edx
  8017cb:	89 f0                	mov    %esi,%eax
  8017cd:	e8 61 ff ff ff       	call   801733 <_pipeisclosed>
  8017d2:	85 c0                	test   %eax,%eax
  8017d4:	75 3b                	jne    801811 <devpipe_write+0x79>
			sys_yield();
  8017d6:	e8 86 f4 ff ff       	call   800c61 <sys_yield>
  8017db:	eb e0                	jmp    8017bd <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017e0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017e4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017e7:	89 c2                	mov    %eax,%edx
  8017e9:	c1 fa 1f             	sar    $0x1f,%edx
  8017ec:	89 d1                	mov    %edx,%ecx
  8017ee:	c1 e9 1b             	shr    $0x1b,%ecx
  8017f1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017f4:	83 e2 1f             	and    $0x1f,%edx
  8017f7:	29 ca                	sub    %ecx,%edx
  8017f9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017fd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801801:	83 c0 01             	add    $0x1,%eax
  801804:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801807:	83 c7 01             	add    $0x1,%edi
  80180a:	eb ac                	jmp    8017b8 <devpipe_write+0x20>
	return i;
  80180c:	8b 45 10             	mov    0x10(%ebp),%eax
  80180f:	eb 05                	jmp    801816 <devpipe_write+0x7e>
				return 0;
  801811:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801816:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801819:	5b                   	pop    %ebx
  80181a:	5e                   	pop    %esi
  80181b:	5f                   	pop    %edi
  80181c:	5d                   	pop    %ebp
  80181d:	c3                   	ret    

0080181e <devpipe_read>:
{
  80181e:	f3 0f 1e fb          	endbr32 
  801822:	55                   	push   %ebp
  801823:	89 e5                	mov    %esp,%ebp
  801825:	57                   	push   %edi
  801826:	56                   	push   %esi
  801827:	53                   	push   %ebx
  801828:	83 ec 18             	sub    $0x18,%esp
  80182b:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80182e:	57                   	push   %edi
  80182f:	e8 75 f6 ff ff       	call   800ea9 <fd2data>
  801834:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801836:	83 c4 10             	add    $0x10,%esp
  801839:	be 00 00 00 00       	mov    $0x0,%esi
  80183e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801841:	75 14                	jne    801857 <devpipe_read+0x39>
	return i;
  801843:	8b 45 10             	mov    0x10(%ebp),%eax
  801846:	eb 02                	jmp    80184a <devpipe_read+0x2c>
				return i;
  801848:	89 f0                	mov    %esi,%eax
}
  80184a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80184d:	5b                   	pop    %ebx
  80184e:	5e                   	pop    %esi
  80184f:	5f                   	pop    %edi
  801850:	5d                   	pop    %ebp
  801851:	c3                   	ret    
			sys_yield();
  801852:	e8 0a f4 ff ff       	call   800c61 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801857:	8b 03                	mov    (%ebx),%eax
  801859:	3b 43 04             	cmp    0x4(%ebx),%eax
  80185c:	75 18                	jne    801876 <devpipe_read+0x58>
			if (i > 0)
  80185e:	85 f6                	test   %esi,%esi
  801860:	75 e6                	jne    801848 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801862:	89 da                	mov    %ebx,%edx
  801864:	89 f8                	mov    %edi,%eax
  801866:	e8 c8 fe ff ff       	call   801733 <_pipeisclosed>
  80186b:	85 c0                	test   %eax,%eax
  80186d:	74 e3                	je     801852 <devpipe_read+0x34>
				return 0;
  80186f:	b8 00 00 00 00       	mov    $0x0,%eax
  801874:	eb d4                	jmp    80184a <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801876:	99                   	cltd   
  801877:	c1 ea 1b             	shr    $0x1b,%edx
  80187a:	01 d0                	add    %edx,%eax
  80187c:	83 e0 1f             	and    $0x1f,%eax
  80187f:	29 d0                	sub    %edx,%eax
  801881:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801886:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801889:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80188c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80188f:	83 c6 01             	add    $0x1,%esi
  801892:	eb aa                	jmp    80183e <devpipe_read+0x20>

00801894 <pipe>:
{
  801894:	f3 0f 1e fb          	endbr32 
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	56                   	push   %esi
  80189c:	53                   	push   %ebx
  80189d:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8018a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a3:	50                   	push   %eax
  8018a4:	e8 1b f6 ff ff       	call   800ec4 <fd_alloc>
  8018a9:	89 c3                	mov    %eax,%ebx
  8018ab:	83 c4 10             	add    $0x10,%esp
  8018ae:	85 c0                	test   %eax,%eax
  8018b0:	0f 88 23 01 00 00    	js     8019d9 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018b6:	83 ec 04             	sub    $0x4,%esp
  8018b9:	68 07 04 00 00       	push   $0x407
  8018be:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c1:	6a 00                	push   $0x0
  8018c3:	e8 bc f3 ff ff       	call   800c84 <sys_page_alloc>
  8018c8:	89 c3                	mov    %eax,%ebx
  8018ca:	83 c4 10             	add    $0x10,%esp
  8018cd:	85 c0                	test   %eax,%eax
  8018cf:	0f 88 04 01 00 00    	js     8019d9 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8018d5:	83 ec 0c             	sub    $0xc,%esp
  8018d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018db:	50                   	push   %eax
  8018dc:	e8 e3 f5 ff ff       	call   800ec4 <fd_alloc>
  8018e1:	89 c3                	mov    %eax,%ebx
  8018e3:	83 c4 10             	add    $0x10,%esp
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	0f 88 db 00 00 00    	js     8019c9 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ee:	83 ec 04             	sub    $0x4,%esp
  8018f1:	68 07 04 00 00       	push   $0x407
  8018f6:	ff 75 f0             	pushl  -0x10(%ebp)
  8018f9:	6a 00                	push   $0x0
  8018fb:	e8 84 f3 ff ff       	call   800c84 <sys_page_alloc>
  801900:	89 c3                	mov    %eax,%ebx
  801902:	83 c4 10             	add    $0x10,%esp
  801905:	85 c0                	test   %eax,%eax
  801907:	0f 88 bc 00 00 00    	js     8019c9 <pipe+0x135>
	va = fd2data(fd0);
  80190d:	83 ec 0c             	sub    $0xc,%esp
  801910:	ff 75 f4             	pushl  -0xc(%ebp)
  801913:	e8 91 f5 ff ff       	call   800ea9 <fd2data>
  801918:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80191a:	83 c4 0c             	add    $0xc,%esp
  80191d:	68 07 04 00 00       	push   $0x407
  801922:	50                   	push   %eax
  801923:	6a 00                	push   $0x0
  801925:	e8 5a f3 ff ff       	call   800c84 <sys_page_alloc>
  80192a:	89 c3                	mov    %eax,%ebx
  80192c:	83 c4 10             	add    $0x10,%esp
  80192f:	85 c0                	test   %eax,%eax
  801931:	0f 88 82 00 00 00    	js     8019b9 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801937:	83 ec 0c             	sub    $0xc,%esp
  80193a:	ff 75 f0             	pushl  -0x10(%ebp)
  80193d:	e8 67 f5 ff ff       	call   800ea9 <fd2data>
  801942:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801949:	50                   	push   %eax
  80194a:	6a 00                	push   $0x0
  80194c:	56                   	push   %esi
  80194d:	6a 00                	push   $0x0
  80194f:	e8 77 f3 ff ff       	call   800ccb <sys_page_map>
  801954:	89 c3                	mov    %eax,%ebx
  801956:	83 c4 20             	add    $0x20,%esp
  801959:	85 c0                	test   %eax,%eax
  80195b:	78 4e                	js     8019ab <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  80195d:	a1 20 30 80 00       	mov    0x803020,%eax
  801962:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801965:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801967:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80196a:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801971:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801974:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801976:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801979:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801980:	83 ec 0c             	sub    $0xc,%esp
  801983:	ff 75 f4             	pushl  -0xc(%ebp)
  801986:	e8 0a f5 ff ff       	call   800e95 <fd2num>
  80198b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80198e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801990:	83 c4 04             	add    $0x4,%esp
  801993:	ff 75 f0             	pushl  -0x10(%ebp)
  801996:	e8 fa f4 ff ff       	call   800e95 <fd2num>
  80199b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80199e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8019a1:	83 c4 10             	add    $0x10,%esp
  8019a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019a9:	eb 2e                	jmp    8019d9 <pipe+0x145>
	sys_page_unmap(0, va);
  8019ab:	83 ec 08             	sub    $0x8,%esp
  8019ae:	56                   	push   %esi
  8019af:	6a 00                	push   $0x0
  8019b1:	e8 5b f3 ff ff       	call   800d11 <sys_page_unmap>
  8019b6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8019b9:	83 ec 08             	sub    $0x8,%esp
  8019bc:	ff 75 f0             	pushl  -0x10(%ebp)
  8019bf:	6a 00                	push   $0x0
  8019c1:	e8 4b f3 ff ff       	call   800d11 <sys_page_unmap>
  8019c6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8019c9:	83 ec 08             	sub    $0x8,%esp
  8019cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8019cf:	6a 00                	push   $0x0
  8019d1:	e8 3b f3 ff ff       	call   800d11 <sys_page_unmap>
  8019d6:	83 c4 10             	add    $0x10,%esp
}
  8019d9:	89 d8                	mov    %ebx,%eax
  8019db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019de:	5b                   	pop    %ebx
  8019df:	5e                   	pop    %esi
  8019e0:	5d                   	pop    %ebp
  8019e1:	c3                   	ret    

008019e2 <pipeisclosed>:
{
  8019e2:	f3 0f 1e fb          	endbr32 
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ef:	50                   	push   %eax
  8019f0:	ff 75 08             	pushl  0x8(%ebp)
  8019f3:	e8 22 f5 ff ff       	call   800f1a <fd_lookup>
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	85 c0                	test   %eax,%eax
  8019fd:	78 18                	js     801a17 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  8019ff:	83 ec 0c             	sub    $0xc,%esp
  801a02:	ff 75 f4             	pushl  -0xc(%ebp)
  801a05:	e8 9f f4 ff ff       	call   800ea9 <fd2data>
  801a0a:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0f:	e8 1f fd ff ff       	call   801733 <_pipeisclosed>
  801a14:	83 c4 10             	add    $0x10,%esp
}
  801a17:	c9                   	leave  
  801a18:	c3                   	ret    

00801a19 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a19:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801a1d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a22:	c3                   	ret    

00801a23 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a23:	f3 0f 1e fb          	endbr32 
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a2d:	68 68 24 80 00       	push   $0x802468
  801a32:	ff 75 0c             	pushl  0xc(%ebp)
  801a35:	e8 08 ee ff ff       	call   800842 <strcpy>
	return 0;
}
  801a3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    

00801a41 <devcons_write>:
{
  801a41:	f3 0f 1e fb          	endbr32 
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	57                   	push   %edi
  801a49:	56                   	push   %esi
  801a4a:	53                   	push   %ebx
  801a4b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801a51:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801a56:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801a5c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a5f:	73 31                	jae    801a92 <devcons_write+0x51>
		m = n - tot;
  801a61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a64:	29 f3                	sub    %esi,%ebx
  801a66:	83 fb 7f             	cmp    $0x7f,%ebx
  801a69:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801a6e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a71:	83 ec 04             	sub    $0x4,%esp
  801a74:	53                   	push   %ebx
  801a75:	89 f0                	mov    %esi,%eax
  801a77:	03 45 0c             	add    0xc(%ebp),%eax
  801a7a:	50                   	push   %eax
  801a7b:	57                   	push   %edi
  801a7c:	e8 77 ef ff ff       	call   8009f8 <memmove>
		sys_cputs(buf, m);
  801a81:	83 c4 08             	add    $0x8,%esp
  801a84:	53                   	push   %ebx
  801a85:	57                   	push   %edi
  801a86:	e8 29 f1 ff ff       	call   800bb4 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801a8b:	01 de                	add    %ebx,%esi
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	eb ca                	jmp    801a5c <devcons_write+0x1b>
}
  801a92:	89 f0                	mov    %esi,%eax
  801a94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a97:	5b                   	pop    %ebx
  801a98:	5e                   	pop    %esi
  801a99:	5f                   	pop    %edi
  801a9a:	5d                   	pop    %ebp
  801a9b:	c3                   	ret    

00801a9c <devcons_read>:
{
  801a9c:	f3 0f 1e fb          	endbr32 
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	83 ec 08             	sub    $0x8,%esp
  801aa6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801aab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801aaf:	74 21                	je     801ad2 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801ab1:	e8 20 f1 ff ff       	call   800bd6 <sys_cgetc>
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	75 07                	jne    801ac1 <devcons_read+0x25>
		sys_yield();
  801aba:	e8 a2 f1 ff ff       	call   800c61 <sys_yield>
  801abf:	eb f0                	jmp    801ab1 <devcons_read+0x15>
	if (c < 0)
  801ac1:	78 0f                	js     801ad2 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801ac3:	83 f8 04             	cmp    $0x4,%eax
  801ac6:	74 0c                	je     801ad4 <devcons_read+0x38>
	*(char*)vbuf = c;
  801ac8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801acb:	88 02                	mov    %al,(%edx)
	return 1;
  801acd:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801ad2:	c9                   	leave  
  801ad3:	c3                   	ret    
		return 0;
  801ad4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad9:	eb f7                	jmp    801ad2 <devcons_read+0x36>

00801adb <cputchar>:
{
  801adb:	f3 0f 1e fb          	endbr32 
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae8:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801aeb:	6a 01                	push   $0x1
  801aed:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801af0:	50                   	push   %eax
  801af1:	e8 be f0 ff ff       	call   800bb4 <sys_cputs>
}
  801af6:	83 c4 10             	add    $0x10,%esp
  801af9:	c9                   	leave  
  801afa:	c3                   	ret    

00801afb <getchar>:
{
  801afb:	f3 0f 1e fb          	endbr32 
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801b05:	6a 01                	push   $0x1
  801b07:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b0a:	50                   	push   %eax
  801b0b:	6a 00                	push   $0x0
  801b0d:	e8 8b f6 ff ff       	call   80119d <read>
	if (r < 0)
  801b12:	83 c4 10             	add    $0x10,%esp
  801b15:	85 c0                	test   %eax,%eax
  801b17:	78 06                	js     801b1f <getchar+0x24>
	if (r < 1)
  801b19:	74 06                	je     801b21 <getchar+0x26>
	return c;
  801b1b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801b1f:	c9                   	leave  
  801b20:	c3                   	ret    
		return -E_EOF;
  801b21:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801b26:	eb f7                	jmp    801b1f <getchar+0x24>

00801b28 <iscons>:
{
  801b28:	f3 0f 1e fb          	endbr32 
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b35:	50                   	push   %eax
  801b36:	ff 75 08             	pushl  0x8(%ebp)
  801b39:	e8 dc f3 ff ff       	call   800f1a <fd_lookup>
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	85 c0                	test   %eax,%eax
  801b43:	78 11                	js     801b56 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b48:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b4e:	39 10                	cmp    %edx,(%eax)
  801b50:	0f 94 c0             	sete   %al
  801b53:	0f b6 c0             	movzbl %al,%eax
}
  801b56:	c9                   	leave  
  801b57:	c3                   	ret    

00801b58 <opencons>:
{
  801b58:	f3 0f 1e fb          	endbr32 
  801b5c:	55                   	push   %ebp
  801b5d:	89 e5                	mov    %esp,%ebp
  801b5f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801b62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b65:	50                   	push   %eax
  801b66:	e8 59 f3 ff ff       	call   800ec4 <fd_alloc>
  801b6b:	83 c4 10             	add    $0x10,%esp
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	78 3a                	js     801bac <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b72:	83 ec 04             	sub    $0x4,%esp
  801b75:	68 07 04 00 00       	push   $0x407
  801b7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b7d:	6a 00                	push   $0x0
  801b7f:	e8 00 f1 ff ff       	call   800c84 <sys_page_alloc>
  801b84:	83 c4 10             	add    $0x10,%esp
  801b87:	85 c0                	test   %eax,%eax
  801b89:	78 21                	js     801bac <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b94:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b99:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ba0:	83 ec 0c             	sub    $0xc,%esp
  801ba3:	50                   	push   %eax
  801ba4:	e8 ec f2 ff ff       	call   800e95 <fd2num>
  801ba9:	83 c4 10             	add    $0x10,%esp
}
  801bac:	c9                   	leave  
  801bad:	c3                   	ret    

00801bae <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bae:	f3 0f 1e fb          	endbr32 
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	56                   	push   %esi
  801bb6:	53                   	push   %ebx
  801bb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801bba:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bbd:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801bc0:	85 c0                	test   %eax,%eax
  801bc2:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801bc7:	0f 44 c2             	cmove  %edx,%eax
  801bca:	83 ec 0c             	sub    $0xc,%esp
  801bcd:	50                   	push   %eax
  801bce:	e8 7d f2 ff ff       	call   800e50 <sys_ipc_recv>
  801bd3:	83 c4 10             	add    $0x10,%esp
  801bd6:	85 c0                	test   %eax,%eax
  801bd8:	78 24                	js     801bfe <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801bda:	85 f6                	test   %esi,%esi
  801bdc:	74 0a                	je     801be8 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801bde:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801be3:	8b 40 78             	mov    0x78(%eax),%eax
  801be6:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801be8:	85 db                	test   %ebx,%ebx
  801bea:	74 0a                	je     801bf6 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801bec:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801bf1:	8b 40 74             	mov    0x74(%eax),%eax
  801bf4:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801bf6:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801bfb:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bfe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c01:	5b                   	pop    %ebx
  801c02:	5e                   	pop    %esi
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    

00801c05 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c05:	f3 0f 1e fb          	endbr32 
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	57                   	push   %edi
  801c0d:	56                   	push   %esi
  801c0e:	53                   	push   %ebx
  801c0f:	83 ec 1c             	sub    $0x1c,%esp
  801c12:	8b 45 10             	mov    0x10(%ebp),%eax
  801c15:	85 c0                	test   %eax,%eax
  801c17:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801c1c:	0f 45 d0             	cmovne %eax,%edx
  801c1f:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801c21:	be 01 00 00 00       	mov    $0x1,%esi
  801c26:	eb 1f                	jmp    801c47 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801c28:	e8 34 f0 ff ff       	call   800c61 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801c2d:	83 c3 01             	add    $0x1,%ebx
  801c30:	39 de                	cmp    %ebx,%esi
  801c32:	7f f4                	jg     801c28 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801c34:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801c36:	83 fe 11             	cmp    $0x11,%esi
  801c39:	b8 01 00 00 00       	mov    $0x1,%eax
  801c3e:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801c41:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801c45:	75 1c                	jne    801c63 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801c47:	ff 75 14             	pushl  0x14(%ebp)
  801c4a:	57                   	push   %edi
  801c4b:	ff 75 0c             	pushl  0xc(%ebp)
  801c4e:	ff 75 08             	pushl  0x8(%ebp)
  801c51:	e8 d3 f1 ff ff       	call   800e29 <sys_ipc_try_send>
  801c56:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801c59:	83 c4 10             	add    $0x10,%esp
  801c5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c61:	eb cd                	jmp    801c30 <ipc_send+0x2b>
}
  801c63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c66:	5b                   	pop    %ebx
  801c67:	5e                   	pop    %esi
  801c68:	5f                   	pop    %edi
  801c69:	5d                   	pop    %ebp
  801c6a:	c3                   	ret    

00801c6b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c6b:	f3 0f 1e fb          	endbr32 
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c75:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c7a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c7d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c83:	8b 52 50             	mov    0x50(%edx),%edx
  801c86:	39 ca                	cmp    %ecx,%edx
  801c88:	74 11                	je     801c9b <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801c8a:	83 c0 01             	add    $0x1,%eax
  801c8d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c92:	75 e6                	jne    801c7a <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801c94:	b8 00 00 00 00       	mov    $0x0,%eax
  801c99:	eb 0b                	jmp    801ca6 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c9b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c9e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ca3:	8b 40 48             	mov    0x48(%eax),%eax
}
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    

00801ca8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ca8:	f3 0f 1e fb          	endbr32 
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cb2:	89 c2                	mov    %eax,%edx
  801cb4:	c1 ea 16             	shr    $0x16,%edx
  801cb7:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801cbe:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801cc3:	f6 c1 01             	test   $0x1,%cl
  801cc6:	74 1c                	je     801ce4 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801cc8:	c1 e8 0c             	shr    $0xc,%eax
  801ccb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801cd2:	a8 01                	test   $0x1,%al
  801cd4:	74 0e                	je     801ce4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801cd6:	c1 e8 0c             	shr    $0xc,%eax
  801cd9:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801ce0:	ef 
  801ce1:	0f b7 d2             	movzwl %dx,%edx
}
  801ce4:	89 d0                	mov    %edx,%eax
  801ce6:	5d                   	pop    %ebp
  801ce7:	c3                   	ret    
  801ce8:	66 90                	xchg   %ax,%ax
  801cea:	66 90                	xchg   %ax,%ax
  801cec:	66 90                	xchg   %ax,%ax
  801cee:	66 90                	xchg   %ax,%ax

00801cf0 <__udivdi3>:
  801cf0:	f3 0f 1e fb          	endbr32 
  801cf4:	55                   	push   %ebp
  801cf5:	57                   	push   %edi
  801cf6:	56                   	push   %esi
  801cf7:	53                   	push   %ebx
  801cf8:	83 ec 1c             	sub    $0x1c,%esp
  801cfb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801d03:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d07:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801d0b:	85 d2                	test   %edx,%edx
  801d0d:	75 19                	jne    801d28 <__udivdi3+0x38>
  801d0f:	39 f3                	cmp    %esi,%ebx
  801d11:	76 4d                	jbe    801d60 <__udivdi3+0x70>
  801d13:	31 ff                	xor    %edi,%edi
  801d15:	89 e8                	mov    %ebp,%eax
  801d17:	89 f2                	mov    %esi,%edx
  801d19:	f7 f3                	div    %ebx
  801d1b:	89 fa                	mov    %edi,%edx
  801d1d:	83 c4 1c             	add    $0x1c,%esp
  801d20:	5b                   	pop    %ebx
  801d21:	5e                   	pop    %esi
  801d22:	5f                   	pop    %edi
  801d23:	5d                   	pop    %ebp
  801d24:	c3                   	ret    
  801d25:	8d 76 00             	lea    0x0(%esi),%esi
  801d28:	39 f2                	cmp    %esi,%edx
  801d2a:	76 14                	jbe    801d40 <__udivdi3+0x50>
  801d2c:	31 ff                	xor    %edi,%edi
  801d2e:	31 c0                	xor    %eax,%eax
  801d30:	89 fa                	mov    %edi,%edx
  801d32:	83 c4 1c             	add    $0x1c,%esp
  801d35:	5b                   	pop    %ebx
  801d36:	5e                   	pop    %esi
  801d37:	5f                   	pop    %edi
  801d38:	5d                   	pop    %ebp
  801d39:	c3                   	ret    
  801d3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d40:	0f bd fa             	bsr    %edx,%edi
  801d43:	83 f7 1f             	xor    $0x1f,%edi
  801d46:	75 48                	jne    801d90 <__udivdi3+0xa0>
  801d48:	39 f2                	cmp    %esi,%edx
  801d4a:	72 06                	jb     801d52 <__udivdi3+0x62>
  801d4c:	31 c0                	xor    %eax,%eax
  801d4e:	39 eb                	cmp    %ebp,%ebx
  801d50:	77 de                	ja     801d30 <__udivdi3+0x40>
  801d52:	b8 01 00 00 00       	mov    $0x1,%eax
  801d57:	eb d7                	jmp    801d30 <__udivdi3+0x40>
  801d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d60:	89 d9                	mov    %ebx,%ecx
  801d62:	85 db                	test   %ebx,%ebx
  801d64:	75 0b                	jne    801d71 <__udivdi3+0x81>
  801d66:	b8 01 00 00 00       	mov    $0x1,%eax
  801d6b:	31 d2                	xor    %edx,%edx
  801d6d:	f7 f3                	div    %ebx
  801d6f:	89 c1                	mov    %eax,%ecx
  801d71:	31 d2                	xor    %edx,%edx
  801d73:	89 f0                	mov    %esi,%eax
  801d75:	f7 f1                	div    %ecx
  801d77:	89 c6                	mov    %eax,%esi
  801d79:	89 e8                	mov    %ebp,%eax
  801d7b:	89 f7                	mov    %esi,%edi
  801d7d:	f7 f1                	div    %ecx
  801d7f:	89 fa                	mov    %edi,%edx
  801d81:	83 c4 1c             	add    $0x1c,%esp
  801d84:	5b                   	pop    %ebx
  801d85:	5e                   	pop    %esi
  801d86:	5f                   	pop    %edi
  801d87:	5d                   	pop    %ebp
  801d88:	c3                   	ret    
  801d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d90:	89 f9                	mov    %edi,%ecx
  801d92:	b8 20 00 00 00       	mov    $0x20,%eax
  801d97:	29 f8                	sub    %edi,%eax
  801d99:	d3 e2                	shl    %cl,%edx
  801d9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d9f:	89 c1                	mov    %eax,%ecx
  801da1:	89 da                	mov    %ebx,%edx
  801da3:	d3 ea                	shr    %cl,%edx
  801da5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801da9:	09 d1                	or     %edx,%ecx
  801dab:	89 f2                	mov    %esi,%edx
  801dad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801db1:	89 f9                	mov    %edi,%ecx
  801db3:	d3 e3                	shl    %cl,%ebx
  801db5:	89 c1                	mov    %eax,%ecx
  801db7:	d3 ea                	shr    %cl,%edx
  801db9:	89 f9                	mov    %edi,%ecx
  801dbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801dbf:	89 eb                	mov    %ebp,%ebx
  801dc1:	d3 e6                	shl    %cl,%esi
  801dc3:	89 c1                	mov    %eax,%ecx
  801dc5:	d3 eb                	shr    %cl,%ebx
  801dc7:	09 de                	or     %ebx,%esi
  801dc9:	89 f0                	mov    %esi,%eax
  801dcb:	f7 74 24 08          	divl   0x8(%esp)
  801dcf:	89 d6                	mov    %edx,%esi
  801dd1:	89 c3                	mov    %eax,%ebx
  801dd3:	f7 64 24 0c          	mull   0xc(%esp)
  801dd7:	39 d6                	cmp    %edx,%esi
  801dd9:	72 15                	jb     801df0 <__udivdi3+0x100>
  801ddb:	89 f9                	mov    %edi,%ecx
  801ddd:	d3 e5                	shl    %cl,%ebp
  801ddf:	39 c5                	cmp    %eax,%ebp
  801de1:	73 04                	jae    801de7 <__udivdi3+0xf7>
  801de3:	39 d6                	cmp    %edx,%esi
  801de5:	74 09                	je     801df0 <__udivdi3+0x100>
  801de7:	89 d8                	mov    %ebx,%eax
  801de9:	31 ff                	xor    %edi,%edi
  801deb:	e9 40 ff ff ff       	jmp    801d30 <__udivdi3+0x40>
  801df0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801df3:	31 ff                	xor    %edi,%edi
  801df5:	e9 36 ff ff ff       	jmp    801d30 <__udivdi3+0x40>
  801dfa:	66 90                	xchg   %ax,%ax
  801dfc:	66 90                	xchg   %ax,%ax
  801dfe:	66 90                	xchg   %ax,%ax

00801e00 <__umoddi3>:
  801e00:	f3 0f 1e fb          	endbr32 
  801e04:	55                   	push   %ebp
  801e05:	57                   	push   %edi
  801e06:	56                   	push   %esi
  801e07:	53                   	push   %ebx
  801e08:	83 ec 1c             	sub    $0x1c,%esp
  801e0b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801e0f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801e13:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801e17:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e1b:	85 c0                	test   %eax,%eax
  801e1d:	75 19                	jne    801e38 <__umoddi3+0x38>
  801e1f:	39 df                	cmp    %ebx,%edi
  801e21:	76 5d                	jbe    801e80 <__umoddi3+0x80>
  801e23:	89 f0                	mov    %esi,%eax
  801e25:	89 da                	mov    %ebx,%edx
  801e27:	f7 f7                	div    %edi
  801e29:	89 d0                	mov    %edx,%eax
  801e2b:	31 d2                	xor    %edx,%edx
  801e2d:	83 c4 1c             	add    $0x1c,%esp
  801e30:	5b                   	pop    %ebx
  801e31:	5e                   	pop    %esi
  801e32:	5f                   	pop    %edi
  801e33:	5d                   	pop    %ebp
  801e34:	c3                   	ret    
  801e35:	8d 76 00             	lea    0x0(%esi),%esi
  801e38:	89 f2                	mov    %esi,%edx
  801e3a:	39 d8                	cmp    %ebx,%eax
  801e3c:	76 12                	jbe    801e50 <__umoddi3+0x50>
  801e3e:	89 f0                	mov    %esi,%eax
  801e40:	89 da                	mov    %ebx,%edx
  801e42:	83 c4 1c             	add    $0x1c,%esp
  801e45:	5b                   	pop    %ebx
  801e46:	5e                   	pop    %esi
  801e47:	5f                   	pop    %edi
  801e48:	5d                   	pop    %ebp
  801e49:	c3                   	ret    
  801e4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e50:	0f bd e8             	bsr    %eax,%ebp
  801e53:	83 f5 1f             	xor    $0x1f,%ebp
  801e56:	75 50                	jne    801ea8 <__umoddi3+0xa8>
  801e58:	39 d8                	cmp    %ebx,%eax
  801e5a:	0f 82 e0 00 00 00    	jb     801f40 <__umoddi3+0x140>
  801e60:	89 d9                	mov    %ebx,%ecx
  801e62:	39 f7                	cmp    %esi,%edi
  801e64:	0f 86 d6 00 00 00    	jbe    801f40 <__umoddi3+0x140>
  801e6a:	89 d0                	mov    %edx,%eax
  801e6c:	89 ca                	mov    %ecx,%edx
  801e6e:	83 c4 1c             	add    $0x1c,%esp
  801e71:	5b                   	pop    %ebx
  801e72:	5e                   	pop    %esi
  801e73:	5f                   	pop    %edi
  801e74:	5d                   	pop    %ebp
  801e75:	c3                   	ret    
  801e76:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e7d:	8d 76 00             	lea    0x0(%esi),%esi
  801e80:	89 fd                	mov    %edi,%ebp
  801e82:	85 ff                	test   %edi,%edi
  801e84:	75 0b                	jne    801e91 <__umoddi3+0x91>
  801e86:	b8 01 00 00 00       	mov    $0x1,%eax
  801e8b:	31 d2                	xor    %edx,%edx
  801e8d:	f7 f7                	div    %edi
  801e8f:	89 c5                	mov    %eax,%ebp
  801e91:	89 d8                	mov    %ebx,%eax
  801e93:	31 d2                	xor    %edx,%edx
  801e95:	f7 f5                	div    %ebp
  801e97:	89 f0                	mov    %esi,%eax
  801e99:	f7 f5                	div    %ebp
  801e9b:	89 d0                	mov    %edx,%eax
  801e9d:	31 d2                	xor    %edx,%edx
  801e9f:	eb 8c                	jmp    801e2d <__umoddi3+0x2d>
  801ea1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ea8:	89 e9                	mov    %ebp,%ecx
  801eaa:	ba 20 00 00 00       	mov    $0x20,%edx
  801eaf:	29 ea                	sub    %ebp,%edx
  801eb1:	d3 e0                	shl    %cl,%eax
  801eb3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eb7:	89 d1                	mov    %edx,%ecx
  801eb9:	89 f8                	mov    %edi,%eax
  801ebb:	d3 e8                	shr    %cl,%eax
  801ebd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801ec1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ec5:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ec9:	09 c1                	or     %eax,%ecx
  801ecb:	89 d8                	mov    %ebx,%eax
  801ecd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ed1:	89 e9                	mov    %ebp,%ecx
  801ed3:	d3 e7                	shl    %cl,%edi
  801ed5:	89 d1                	mov    %edx,%ecx
  801ed7:	d3 e8                	shr    %cl,%eax
  801ed9:	89 e9                	mov    %ebp,%ecx
  801edb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801edf:	d3 e3                	shl    %cl,%ebx
  801ee1:	89 c7                	mov    %eax,%edi
  801ee3:	89 d1                	mov    %edx,%ecx
  801ee5:	89 f0                	mov    %esi,%eax
  801ee7:	d3 e8                	shr    %cl,%eax
  801ee9:	89 e9                	mov    %ebp,%ecx
  801eeb:	89 fa                	mov    %edi,%edx
  801eed:	d3 e6                	shl    %cl,%esi
  801eef:	09 d8                	or     %ebx,%eax
  801ef1:	f7 74 24 08          	divl   0x8(%esp)
  801ef5:	89 d1                	mov    %edx,%ecx
  801ef7:	89 f3                	mov    %esi,%ebx
  801ef9:	f7 64 24 0c          	mull   0xc(%esp)
  801efd:	89 c6                	mov    %eax,%esi
  801eff:	89 d7                	mov    %edx,%edi
  801f01:	39 d1                	cmp    %edx,%ecx
  801f03:	72 06                	jb     801f0b <__umoddi3+0x10b>
  801f05:	75 10                	jne    801f17 <__umoddi3+0x117>
  801f07:	39 c3                	cmp    %eax,%ebx
  801f09:	73 0c                	jae    801f17 <__umoddi3+0x117>
  801f0b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801f0f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801f13:	89 d7                	mov    %edx,%edi
  801f15:	89 c6                	mov    %eax,%esi
  801f17:	89 ca                	mov    %ecx,%edx
  801f19:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801f1e:	29 f3                	sub    %esi,%ebx
  801f20:	19 fa                	sbb    %edi,%edx
  801f22:	89 d0                	mov    %edx,%eax
  801f24:	d3 e0                	shl    %cl,%eax
  801f26:	89 e9                	mov    %ebp,%ecx
  801f28:	d3 eb                	shr    %cl,%ebx
  801f2a:	d3 ea                	shr    %cl,%edx
  801f2c:	09 d8                	or     %ebx,%eax
  801f2e:	83 c4 1c             	add    $0x1c,%esp
  801f31:	5b                   	pop    %ebx
  801f32:	5e                   	pop    %esi
  801f33:	5f                   	pop    %edi
  801f34:	5d                   	pop    %ebp
  801f35:	c3                   	ret    
  801f36:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f3d:	8d 76 00             	lea    0x0(%esi),%esi
  801f40:	29 fe                	sub    %edi,%esi
  801f42:	19 c3                	sbb    %eax,%ebx
  801f44:	89 f2                	mov    %esi,%edx
  801f46:	89 d9                	mov    %ebx,%ecx
  801f48:	e9 1d ff ff ff       	jmp    801e6a <__umoddi3+0x6a>
