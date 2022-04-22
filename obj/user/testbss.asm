
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
  80003d:	68 80 1f 80 00       	push   $0x801f80
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
  800094:	68 c8 1f 80 00       	push   $0x801fc8
  800099:	e8 9b 01 00 00       	call   800239 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  80009e:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000a5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000a8:	83 c4 0c             	add    $0xc,%esp
  8000ab:	68 27 20 80 00       	push   $0x802027
  8000b0:	6a 1a                	push   $0x1a
  8000b2:	68 18 20 80 00       	push   $0x802018
  8000b7:	e8 96 00 00 00       	call   800152 <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000bc:	50                   	push   %eax
  8000bd:	68 fb 1f 80 00       	push   $0x801ffb
  8000c2:	6a 11                	push   $0x11
  8000c4:	68 18 20 80 00       	push   $0x802018
  8000c9:	e8 84 00 00 00       	call   800152 <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ce:	50                   	push   %eax
  8000cf:	68 a0 1f 80 00       	push   $0x801fa0
  8000d4:	6a 16                	push   $0x16
  8000d6:	68 18 20 80 00       	push   $0x802018
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
  800174:	68 48 20 80 00       	push   $0x802048
  800179:	e8 bb 00 00 00       	call   800239 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80017e:	83 c4 18             	add    $0x18,%esp
  800181:	53                   	push   %ebx
  800182:	ff 75 10             	pushl  0x10(%ebp)
  800185:	e8 5a 00 00 00       	call   8001e4 <vcprintf>
	cprintf("\n");
  80018a:	c7 04 24 16 20 80 00 	movl   $0x802016,(%esp)
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
  80029f:	e8 7c 1a 00 00       	call   801d20 <__udivdi3>
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
  8002dd:	e8 4e 1b 00 00       	call   801e30 <__umoddi3>
  8002e2:	83 c4 14             	add    $0x14,%esp
  8002e5:	0f be 80 6b 20 80 00 	movsbl 0x80206b(%eax),%eax
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
  80038c:	3e ff 24 85 a0 21 80 	notrack jmp *0x8021a0(,%eax,4)
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
  800459:	8b 14 85 00 23 80 00 	mov    0x802300(,%eax,4),%edx
  800460:	85 d2                	test   %edx,%edx
  800462:	74 18                	je     80047c <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800464:	52                   	push   %edx
  800465:	68 31 24 80 00       	push   $0x802431
  80046a:	53                   	push   %ebx
  80046b:	56                   	push   %esi
  80046c:	e8 aa fe ff ff       	call   80031b <printfmt>
  800471:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800474:	89 7d 14             	mov    %edi,0x14(%ebp)
  800477:	e9 22 02 00 00       	jmp    80069e <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  80047c:	50                   	push   %eax
  80047d:	68 83 20 80 00       	push   $0x802083
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
  8004a4:	b8 7c 20 80 00       	mov    $0x80207c,%eax
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
  800c2d:	68 5f 23 80 00       	push   $0x80235f
  800c32:	6a 23                	push   $0x23
  800c34:	68 7c 23 80 00       	push   $0x80237c
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
  800cba:	68 5f 23 80 00       	push   $0x80235f
  800cbf:	6a 23                	push   $0x23
  800cc1:	68 7c 23 80 00       	push   $0x80237c
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
  800d00:	68 5f 23 80 00       	push   $0x80235f
  800d05:	6a 23                	push   $0x23
  800d07:	68 7c 23 80 00       	push   $0x80237c
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
  800d46:	68 5f 23 80 00       	push   $0x80235f
  800d4b:	6a 23                	push   $0x23
  800d4d:	68 7c 23 80 00       	push   $0x80237c
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
  800d8c:	68 5f 23 80 00       	push   $0x80235f
  800d91:	6a 23                	push   $0x23
  800d93:	68 7c 23 80 00       	push   $0x80237c
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
  800dd2:	68 5f 23 80 00       	push   $0x80235f
  800dd7:	6a 23                	push   $0x23
  800dd9:	68 7c 23 80 00       	push   $0x80237c
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
  800e18:	68 5f 23 80 00       	push   $0x80235f
  800e1d:	6a 23                	push   $0x23
  800e1f:	68 7c 23 80 00       	push   $0x80237c
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
  800e84:	68 5f 23 80 00       	push   $0x80235f
  800e89:	6a 23                	push   $0x23
  800e8b:	68 7c 23 80 00       	push   $0x80237c
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
  800f7b:	ba 08 24 80 00       	mov    $0x802408,%edx
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
  800f9f:	68 8c 23 80 00       	push   $0x80238c
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
  80120d:	68 cd 23 80 00       	push   $0x8023cd
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
  8012de:	68 e9 23 80 00       	push   $0x8023e9
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
  80138e:	68 ac 23 80 00       	push   $0x8023ac
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
  801432:	e8 fb 01 00 00       	call   801632 <open>
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
  801484:	e8 a8 07 00 00       	call   801c31 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801489:	83 c4 0c             	add    $0xc,%esp
  80148c:	6a 00                	push   $0x0
  80148e:	53                   	push   %ebx
  80148f:	6a 00                	push   $0x0
  801491:	e8 44 07 00 00       	call   801bda <ipc_recv>
}
  801496:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801499:	5b                   	pop    %ebx
  80149a:	5e                   	pop    %esi
  80149b:	5d                   	pop    %ebp
  80149c:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80149d:	83 ec 0c             	sub    $0xc,%esp
  8014a0:	6a 01                	push   $0x1
  8014a2:	e8 f0 07 00 00       	call   801c97 <ipc_find_env>
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
  80156c:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  80156f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801574:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801579:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80157c:	8b 55 08             	mov    0x8(%ebp),%edx
  80157f:	8b 52 0c             	mov    0xc(%edx),%edx
  801582:	89 15 00 50 c0 00    	mov    %edx,0xc05000
	fsipcbuf.write.req_n = n;
  801588:	a3 04 50 c0 00       	mov    %eax,0xc05004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80158d:	50                   	push   %eax
  80158e:	ff 75 0c             	pushl  0xc(%ebp)
  801591:	68 08 50 c0 00       	push   $0xc05008
  801596:	e8 5d f4 ff ff       	call   8009f8 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80159b:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a0:	b8 04 00 00 00       	mov    $0x4,%eax
  8015a5:	e8 ba fe ff ff       	call   801464 <fsipc>
}
  8015aa:	c9                   	leave  
  8015ab:	c3                   	ret    

008015ac <devfile_read>:
{
  8015ac:	f3 0f 1e fb          	endbr32 
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	56                   	push   %esi
  8015b4:	53                   	push   %ebx
  8015b5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8015be:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  8015c3:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ce:	b8 03 00 00 00       	mov    $0x3,%eax
  8015d3:	e8 8c fe ff ff       	call   801464 <fsipc>
  8015d8:	89 c3                	mov    %eax,%ebx
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 1f                	js     8015fd <devfile_read+0x51>
	assert(r <= n);
  8015de:	39 f0                	cmp    %esi,%eax
  8015e0:	77 24                	ja     801606 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8015e2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015e7:	7f 33                	jg     80161c <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015e9:	83 ec 04             	sub    $0x4,%esp
  8015ec:	50                   	push   %eax
  8015ed:	68 00 50 c0 00       	push   $0xc05000
  8015f2:	ff 75 0c             	pushl  0xc(%ebp)
  8015f5:	e8 fe f3 ff ff       	call   8009f8 <memmove>
	return r;
  8015fa:	83 c4 10             	add    $0x10,%esp
}
  8015fd:	89 d8                	mov    %ebx,%eax
  8015ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801602:	5b                   	pop    %ebx
  801603:	5e                   	pop    %esi
  801604:	5d                   	pop    %ebp
  801605:	c3                   	ret    
	assert(r <= n);
  801606:	68 18 24 80 00       	push   $0x802418
  80160b:	68 1f 24 80 00       	push   $0x80241f
  801610:	6a 7c                	push   $0x7c
  801612:	68 34 24 80 00       	push   $0x802434
  801617:	e8 36 eb ff ff       	call   800152 <_panic>
	assert(r <= PGSIZE);
  80161c:	68 3f 24 80 00       	push   $0x80243f
  801621:	68 1f 24 80 00       	push   $0x80241f
  801626:	6a 7d                	push   $0x7d
  801628:	68 34 24 80 00       	push   $0x802434
  80162d:	e8 20 eb ff ff       	call   800152 <_panic>

00801632 <open>:
{
  801632:	f3 0f 1e fb          	endbr32 
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	56                   	push   %esi
  80163a:	53                   	push   %ebx
  80163b:	83 ec 1c             	sub    $0x1c,%esp
  80163e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801641:	56                   	push   %esi
  801642:	e8 b8 f1 ff ff       	call   8007ff <strlen>
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80164f:	7f 6c                	jg     8016bd <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801651:	83 ec 0c             	sub    $0xc,%esp
  801654:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801657:	50                   	push   %eax
  801658:	e8 67 f8 ff ff       	call   800ec4 <fd_alloc>
  80165d:	89 c3                	mov    %eax,%ebx
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	85 c0                	test   %eax,%eax
  801664:	78 3c                	js     8016a2 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801666:	83 ec 08             	sub    $0x8,%esp
  801669:	56                   	push   %esi
  80166a:	68 00 50 c0 00       	push   $0xc05000
  80166f:	e8 ce f1 ff ff       	call   800842 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801674:	8b 45 0c             	mov    0xc(%ebp),%eax
  801677:	a3 00 54 c0 00       	mov    %eax,0xc05400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80167c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80167f:	b8 01 00 00 00       	mov    $0x1,%eax
  801684:	e8 db fd ff ff       	call   801464 <fsipc>
  801689:	89 c3                	mov    %eax,%ebx
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	85 c0                	test   %eax,%eax
  801690:	78 19                	js     8016ab <open+0x79>
	return fd2num(fd);
  801692:	83 ec 0c             	sub    $0xc,%esp
  801695:	ff 75 f4             	pushl  -0xc(%ebp)
  801698:	e8 f8 f7 ff ff       	call   800e95 <fd2num>
  80169d:	89 c3                	mov    %eax,%ebx
  80169f:	83 c4 10             	add    $0x10,%esp
}
  8016a2:	89 d8                	mov    %ebx,%eax
  8016a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a7:	5b                   	pop    %ebx
  8016a8:	5e                   	pop    %esi
  8016a9:	5d                   	pop    %ebp
  8016aa:	c3                   	ret    
		fd_close(fd, 0);
  8016ab:	83 ec 08             	sub    $0x8,%esp
  8016ae:	6a 00                	push   $0x0
  8016b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b3:	e8 10 f9 ff ff       	call   800fc8 <fd_close>
		return r;
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	eb e5                	jmp    8016a2 <open+0x70>
		return -E_BAD_PATH;
  8016bd:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8016c2:	eb de                	jmp    8016a2 <open+0x70>

008016c4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016c4:	f3 0f 1e fb          	endbr32 
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d3:	b8 08 00 00 00       	mov    $0x8,%eax
  8016d8:	e8 87 fd ff ff       	call   801464 <fsipc>
}
  8016dd:	c9                   	leave  
  8016de:	c3                   	ret    

008016df <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016df:	f3 0f 1e fb          	endbr32 
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	56                   	push   %esi
  8016e7:	53                   	push   %ebx
  8016e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016eb:	83 ec 0c             	sub    $0xc,%esp
  8016ee:	ff 75 08             	pushl  0x8(%ebp)
  8016f1:	e8 b3 f7 ff ff       	call   800ea9 <fd2data>
  8016f6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016f8:	83 c4 08             	add    $0x8,%esp
  8016fb:	68 4b 24 80 00       	push   $0x80244b
  801700:	53                   	push   %ebx
  801701:	e8 3c f1 ff ff       	call   800842 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801706:	8b 46 04             	mov    0x4(%esi),%eax
  801709:	2b 06                	sub    (%esi),%eax
  80170b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801711:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801718:	00 00 00 
	stat->st_dev = &devpipe;
  80171b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801722:	30 80 00 
	return 0;
}
  801725:	b8 00 00 00 00       	mov    $0x0,%eax
  80172a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172d:	5b                   	pop    %ebx
  80172e:	5e                   	pop    %esi
  80172f:	5d                   	pop    %ebp
  801730:	c3                   	ret    

00801731 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801731:	f3 0f 1e fb          	endbr32 
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	53                   	push   %ebx
  801739:	83 ec 0c             	sub    $0xc,%esp
  80173c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80173f:	53                   	push   %ebx
  801740:	6a 00                	push   $0x0
  801742:	e8 ca f5 ff ff       	call   800d11 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801747:	89 1c 24             	mov    %ebx,(%esp)
  80174a:	e8 5a f7 ff ff       	call   800ea9 <fd2data>
  80174f:	83 c4 08             	add    $0x8,%esp
  801752:	50                   	push   %eax
  801753:	6a 00                	push   $0x0
  801755:	e8 b7 f5 ff ff       	call   800d11 <sys_page_unmap>
}
  80175a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175d:	c9                   	leave  
  80175e:	c3                   	ret    

0080175f <_pipeisclosed>:
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	57                   	push   %edi
  801763:	56                   	push   %esi
  801764:	53                   	push   %ebx
  801765:	83 ec 1c             	sub    $0x1c,%esp
  801768:	89 c7                	mov    %eax,%edi
  80176a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80176c:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801771:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801774:	83 ec 0c             	sub    $0xc,%esp
  801777:	57                   	push   %edi
  801778:	e8 57 05 00 00       	call   801cd4 <pageref>
  80177d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801780:	89 34 24             	mov    %esi,(%esp)
  801783:	e8 4c 05 00 00       	call   801cd4 <pageref>
		nn = thisenv->env_runs;
  801788:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  80178e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801791:	83 c4 10             	add    $0x10,%esp
  801794:	39 cb                	cmp    %ecx,%ebx
  801796:	74 1b                	je     8017b3 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801798:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80179b:	75 cf                	jne    80176c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80179d:	8b 42 58             	mov    0x58(%edx),%eax
  8017a0:	6a 01                	push   $0x1
  8017a2:	50                   	push   %eax
  8017a3:	53                   	push   %ebx
  8017a4:	68 52 24 80 00       	push   $0x802452
  8017a9:	e8 8b ea ff ff       	call   800239 <cprintf>
  8017ae:	83 c4 10             	add    $0x10,%esp
  8017b1:	eb b9                	jmp    80176c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8017b3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8017b6:	0f 94 c0             	sete   %al
  8017b9:	0f b6 c0             	movzbl %al,%eax
}
  8017bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017bf:	5b                   	pop    %ebx
  8017c0:	5e                   	pop    %esi
  8017c1:	5f                   	pop    %edi
  8017c2:	5d                   	pop    %ebp
  8017c3:	c3                   	ret    

008017c4 <devpipe_write>:
{
  8017c4:	f3 0f 1e fb          	endbr32 
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	57                   	push   %edi
  8017cc:	56                   	push   %esi
  8017cd:	53                   	push   %ebx
  8017ce:	83 ec 28             	sub    $0x28,%esp
  8017d1:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8017d4:	56                   	push   %esi
  8017d5:	e8 cf f6 ff ff       	call   800ea9 <fd2data>
  8017da:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8017dc:	83 c4 10             	add    $0x10,%esp
  8017df:	bf 00 00 00 00       	mov    $0x0,%edi
  8017e4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017e7:	74 4f                	je     801838 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017e9:	8b 43 04             	mov    0x4(%ebx),%eax
  8017ec:	8b 0b                	mov    (%ebx),%ecx
  8017ee:	8d 51 20             	lea    0x20(%ecx),%edx
  8017f1:	39 d0                	cmp    %edx,%eax
  8017f3:	72 14                	jb     801809 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8017f5:	89 da                	mov    %ebx,%edx
  8017f7:	89 f0                	mov    %esi,%eax
  8017f9:	e8 61 ff ff ff       	call   80175f <_pipeisclosed>
  8017fe:	85 c0                	test   %eax,%eax
  801800:	75 3b                	jne    80183d <devpipe_write+0x79>
			sys_yield();
  801802:	e8 5a f4 ff ff       	call   800c61 <sys_yield>
  801807:	eb e0                	jmp    8017e9 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801809:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80180c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801810:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801813:	89 c2                	mov    %eax,%edx
  801815:	c1 fa 1f             	sar    $0x1f,%edx
  801818:	89 d1                	mov    %edx,%ecx
  80181a:	c1 e9 1b             	shr    $0x1b,%ecx
  80181d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801820:	83 e2 1f             	and    $0x1f,%edx
  801823:	29 ca                	sub    %ecx,%edx
  801825:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801829:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80182d:	83 c0 01             	add    $0x1,%eax
  801830:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801833:	83 c7 01             	add    $0x1,%edi
  801836:	eb ac                	jmp    8017e4 <devpipe_write+0x20>
	return i;
  801838:	8b 45 10             	mov    0x10(%ebp),%eax
  80183b:	eb 05                	jmp    801842 <devpipe_write+0x7e>
				return 0;
  80183d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801842:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801845:	5b                   	pop    %ebx
  801846:	5e                   	pop    %esi
  801847:	5f                   	pop    %edi
  801848:	5d                   	pop    %ebp
  801849:	c3                   	ret    

0080184a <devpipe_read>:
{
  80184a:	f3 0f 1e fb          	endbr32 
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	57                   	push   %edi
  801852:	56                   	push   %esi
  801853:	53                   	push   %ebx
  801854:	83 ec 18             	sub    $0x18,%esp
  801857:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80185a:	57                   	push   %edi
  80185b:	e8 49 f6 ff ff       	call   800ea9 <fd2data>
  801860:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801862:	83 c4 10             	add    $0x10,%esp
  801865:	be 00 00 00 00       	mov    $0x0,%esi
  80186a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80186d:	75 14                	jne    801883 <devpipe_read+0x39>
	return i;
  80186f:	8b 45 10             	mov    0x10(%ebp),%eax
  801872:	eb 02                	jmp    801876 <devpipe_read+0x2c>
				return i;
  801874:	89 f0                	mov    %esi,%eax
}
  801876:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801879:	5b                   	pop    %ebx
  80187a:	5e                   	pop    %esi
  80187b:	5f                   	pop    %edi
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    
			sys_yield();
  80187e:	e8 de f3 ff ff       	call   800c61 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801883:	8b 03                	mov    (%ebx),%eax
  801885:	3b 43 04             	cmp    0x4(%ebx),%eax
  801888:	75 18                	jne    8018a2 <devpipe_read+0x58>
			if (i > 0)
  80188a:	85 f6                	test   %esi,%esi
  80188c:	75 e6                	jne    801874 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  80188e:	89 da                	mov    %ebx,%edx
  801890:	89 f8                	mov    %edi,%eax
  801892:	e8 c8 fe ff ff       	call   80175f <_pipeisclosed>
  801897:	85 c0                	test   %eax,%eax
  801899:	74 e3                	je     80187e <devpipe_read+0x34>
				return 0;
  80189b:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a0:	eb d4                	jmp    801876 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018a2:	99                   	cltd   
  8018a3:	c1 ea 1b             	shr    $0x1b,%edx
  8018a6:	01 d0                	add    %edx,%eax
  8018a8:	83 e0 1f             	and    $0x1f,%eax
  8018ab:	29 d0                	sub    %edx,%eax
  8018ad:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8018b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018b5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8018b8:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8018bb:	83 c6 01             	add    $0x1,%esi
  8018be:	eb aa                	jmp    80186a <devpipe_read+0x20>

008018c0 <pipe>:
{
  8018c0:	f3 0f 1e fb          	endbr32 
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	56                   	push   %esi
  8018c8:	53                   	push   %ebx
  8018c9:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8018cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018cf:	50                   	push   %eax
  8018d0:	e8 ef f5 ff ff       	call   800ec4 <fd_alloc>
  8018d5:	89 c3                	mov    %eax,%ebx
  8018d7:	83 c4 10             	add    $0x10,%esp
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	0f 88 23 01 00 00    	js     801a05 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018e2:	83 ec 04             	sub    $0x4,%esp
  8018e5:	68 07 04 00 00       	push   $0x407
  8018ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ed:	6a 00                	push   $0x0
  8018ef:	e8 90 f3 ff ff       	call   800c84 <sys_page_alloc>
  8018f4:	89 c3                	mov    %eax,%ebx
  8018f6:	83 c4 10             	add    $0x10,%esp
  8018f9:	85 c0                	test   %eax,%eax
  8018fb:	0f 88 04 01 00 00    	js     801a05 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801901:	83 ec 0c             	sub    $0xc,%esp
  801904:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801907:	50                   	push   %eax
  801908:	e8 b7 f5 ff ff       	call   800ec4 <fd_alloc>
  80190d:	89 c3                	mov    %eax,%ebx
  80190f:	83 c4 10             	add    $0x10,%esp
  801912:	85 c0                	test   %eax,%eax
  801914:	0f 88 db 00 00 00    	js     8019f5 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80191a:	83 ec 04             	sub    $0x4,%esp
  80191d:	68 07 04 00 00       	push   $0x407
  801922:	ff 75 f0             	pushl  -0x10(%ebp)
  801925:	6a 00                	push   $0x0
  801927:	e8 58 f3 ff ff       	call   800c84 <sys_page_alloc>
  80192c:	89 c3                	mov    %eax,%ebx
  80192e:	83 c4 10             	add    $0x10,%esp
  801931:	85 c0                	test   %eax,%eax
  801933:	0f 88 bc 00 00 00    	js     8019f5 <pipe+0x135>
	va = fd2data(fd0);
  801939:	83 ec 0c             	sub    $0xc,%esp
  80193c:	ff 75 f4             	pushl  -0xc(%ebp)
  80193f:	e8 65 f5 ff ff       	call   800ea9 <fd2data>
  801944:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801946:	83 c4 0c             	add    $0xc,%esp
  801949:	68 07 04 00 00       	push   $0x407
  80194e:	50                   	push   %eax
  80194f:	6a 00                	push   $0x0
  801951:	e8 2e f3 ff ff       	call   800c84 <sys_page_alloc>
  801956:	89 c3                	mov    %eax,%ebx
  801958:	83 c4 10             	add    $0x10,%esp
  80195b:	85 c0                	test   %eax,%eax
  80195d:	0f 88 82 00 00 00    	js     8019e5 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801963:	83 ec 0c             	sub    $0xc,%esp
  801966:	ff 75 f0             	pushl  -0x10(%ebp)
  801969:	e8 3b f5 ff ff       	call   800ea9 <fd2data>
  80196e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801975:	50                   	push   %eax
  801976:	6a 00                	push   $0x0
  801978:	56                   	push   %esi
  801979:	6a 00                	push   $0x0
  80197b:	e8 4b f3 ff ff       	call   800ccb <sys_page_map>
  801980:	89 c3                	mov    %eax,%ebx
  801982:	83 c4 20             	add    $0x20,%esp
  801985:	85 c0                	test   %eax,%eax
  801987:	78 4e                	js     8019d7 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801989:	a1 20 30 80 00       	mov    0x803020,%eax
  80198e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801991:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801993:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801996:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80199d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019a0:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8019a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019a5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8019ac:	83 ec 0c             	sub    $0xc,%esp
  8019af:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b2:	e8 de f4 ff ff       	call   800e95 <fd2num>
  8019b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019ba:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8019bc:	83 c4 04             	add    $0x4,%esp
  8019bf:	ff 75 f0             	pushl  -0x10(%ebp)
  8019c2:	e8 ce f4 ff ff       	call   800e95 <fd2num>
  8019c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019ca:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8019cd:	83 c4 10             	add    $0x10,%esp
  8019d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019d5:	eb 2e                	jmp    801a05 <pipe+0x145>
	sys_page_unmap(0, va);
  8019d7:	83 ec 08             	sub    $0x8,%esp
  8019da:	56                   	push   %esi
  8019db:	6a 00                	push   $0x0
  8019dd:	e8 2f f3 ff ff       	call   800d11 <sys_page_unmap>
  8019e2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8019e5:	83 ec 08             	sub    $0x8,%esp
  8019e8:	ff 75 f0             	pushl  -0x10(%ebp)
  8019eb:	6a 00                	push   $0x0
  8019ed:	e8 1f f3 ff ff       	call   800d11 <sys_page_unmap>
  8019f2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8019f5:	83 ec 08             	sub    $0x8,%esp
  8019f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019fb:	6a 00                	push   $0x0
  8019fd:	e8 0f f3 ff ff       	call   800d11 <sys_page_unmap>
  801a02:	83 c4 10             	add    $0x10,%esp
}
  801a05:	89 d8                	mov    %ebx,%eax
  801a07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0a:	5b                   	pop    %ebx
  801a0b:	5e                   	pop    %esi
  801a0c:	5d                   	pop    %ebp
  801a0d:	c3                   	ret    

00801a0e <pipeisclosed>:
{
  801a0e:	f3 0f 1e fb          	endbr32 
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1b:	50                   	push   %eax
  801a1c:	ff 75 08             	pushl  0x8(%ebp)
  801a1f:	e8 f6 f4 ff ff       	call   800f1a <fd_lookup>
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	85 c0                	test   %eax,%eax
  801a29:	78 18                	js     801a43 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801a2b:	83 ec 0c             	sub    $0xc,%esp
  801a2e:	ff 75 f4             	pushl  -0xc(%ebp)
  801a31:	e8 73 f4 ff ff       	call   800ea9 <fd2data>
  801a36:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a3b:	e8 1f fd ff ff       	call   80175f <_pipeisclosed>
  801a40:	83 c4 10             	add    $0x10,%esp
}
  801a43:	c9                   	leave  
  801a44:	c3                   	ret    

00801a45 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a45:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801a49:	b8 00 00 00 00       	mov    $0x0,%eax
  801a4e:	c3                   	ret    

00801a4f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a4f:	f3 0f 1e fb          	endbr32 
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a59:	68 6a 24 80 00       	push   $0x80246a
  801a5e:	ff 75 0c             	pushl  0xc(%ebp)
  801a61:	e8 dc ed ff ff       	call   800842 <strcpy>
	return 0;
}
  801a66:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6b:	c9                   	leave  
  801a6c:	c3                   	ret    

00801a6d <devcons_write>:
{
  801a6d:	f3 0f 1e fb          	endbr32 
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	57                   	push   %edi
  801a75:	56                   	push   %esi
  801a76:	53                   	push   %ebx
  801a77:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801a7d:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801a82:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801a88:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a8b:	73 31                	jae    801abe <devcons_write+0x51>
		m = n - tot;
  801a8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a90:	29 f3                	sub    %esi,%ebx
  801a92:	83 fb 7f             	cmp    $0x7f,%ebx
  801a95:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801a9a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a9d:	83 ec 04             	sub    $0x4,%esp
  801aa0:	53                   	push   %ebx
  801aa1:	89 f0                	mov    %esi,%eax
  801aa3:	03 45 0c             	add    0xc(%ebp),%eax
  801aa6:	50                   	push   %eax
  801aa7:	57                   	push   %edi
  801aa8:	e8 4b ef ff ff       	call   8009f8 <memmove>
		sys_cputs(buf, m);
  801aad:	83 c4 08             	add    $0x8,%esp
  801ab0:	53                   	push   %ebx
  801ab1:	57                   	push   %edi
  801ab2:	e8 fd f0 ff ff       	call   800bb4 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801ab7:	01 de                	add    %ebx,%esi
  801ab9:	83 c4 10             	add    $0x10,%esp
  801abc:	eb ca                	jmp    801a88 <devcons_write+0x1b>
}
  801abe:	89 f0                	mov    %esi,%eax
  801ac0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac3:	5b                   	pop    %ebx
  801ac4:	5e                   	pop    %esi
  801ac5:	5f                   	pop    %edi
  801ac6:	5d                   	pop    %ebp
  801ac7:	c3                   	ret    

00801ac8 <devcons_read>:
{
  801ac8:	f3 0f 1e fb          	endbr32 
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	83 ec 08             	sub    $0x8,%esp
  801ad2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801ad7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801adb:	74 21                	je     801afe <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801add:	e8 f4 f0 ff ff       	call   800bd6 <sys_cgetc>
  801ae2:	85 c0                	test   %eax,%eax
  801ae4:	75 07                	jne    801aed <devcons_read+0x25>
		sys_yield();
  801ae6:	e8 76 f1 ff ff       	call   800c61 <sys_yield>
  801aeb:	eb f0                	jmp    801add <devcons_read+0x15>
	if (c < 0)
  801aed:	78 0f                	js     801afe <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801aef:	83 f8 04             	cmp    $0x4,%eax
  801af2:	74 0c                	je     801b00 <devcons_read+0x38>
	*(char*)vbuf = c;
  801af4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801af7:	88 02                	mov    %al,(%edx)
	return 1;
  801af9:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801afe:	c9                   	leave  
  801aff:	c3                   	ret    
		return 0;
  801b00:	b8 00 00 00 00       	mov    $0x0,%eax
  801b05:	eb f7                	jmp    801afe <devcons_read+0x36>

00801b07 <cputchar>:
{
  801b07:	f3 0f 1e fb          	endbr32 
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b11:	8b 45 08             	mov    0x8(%ebp),%eax
  801b14:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801b17:	6a 01                	push   $0x1
  801b19:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b1c:	50                   	push   %eax
  801b1d:	e8 92 f0 ff ff       	call   800bb4 <sys_cputs>
}
  801b22:	83 c4 10             	add    $0x10,%esp
  801b25:	c9                   	leave  
  801b26:	c3                   	ret    

00801b27 <getchar>:
{
  801b27:	f3 0f 1e fb          	endbr32 
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801b31:	6a 01                	push   $0x1
  801b33:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b36:	50                   	push   %eax
  801b37:	6a 00                	push   $0x0
  801b39:	e8 5f f6 ff ff       	call   80119d <read>
	if (r < 0)
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	85 c0                	test   %eax,%eax
  801b43:	78 06                	js     801b4b <getchar+0x24>
	if (r < 1)
  801b45:	74 06                	je     801b4d <getchar+0x26>
	return c;
  801b47:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801b4b:	c9                   	leave  
  801b4c:	c3                   	ret    
		return -E_EOF;
  801b4d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801b52:	eb f7                	jmp    801b4b <getchar+0x24>

00801b54 <iscons>:
{
  801b54:	f3 0f 1e fb          	endbr32 
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b61:	50                   	push   %eax
  801b62:	ff 75 08             	pushl  0x8(%ebp)
  801b65:	e8 b0 f3 ff ff       	call   800f1a <fd_lookup>
  801b6a:	83 c4 10             	add    $0x10,%esp
  801b6d:	85 c0                	test   %eax,%eax
  801b6f:	78 11                	js     801b82 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b74:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b7a:	39 10                	cmp    %edx,(%eax)
  801b7c:	0f 94 c0             	sete   %al
  801b7f:	0f b6 c0             	movzbl %al,%eax
}
  801b82:	c9                   	leave  
  801b83:	c3                   	ret    

00801b84 <opencons>:
{
  801b84:	f3 0f 1e fb          	endbr32 
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801b8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b91:	50                   	push   %eax
  801b92:	e8 2d f3 ff ff       	call   800ec4 <fd_alloc>
  801b97:	83 c4 10             	add    $0x10,%esp
  801b9a:	85 c0                	test   %eax,%eax
  801b9c:	78 3a                	js     801bd8 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b9e:	83 ec 04             	sub    $0x4,%esp
  801ba1:	68 07 04 00 00       	push   $0x407
  801ba6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba9:	6a 00                	push   $0x0
  801bab:	e8 d4 f0 ff ff       	call   800c84 <sys_page_alloc>
  801bb0:	83 c4 10             	add    $0x10,%esp
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	78 21                	js     801bd8 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bba:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bc0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801bcc:	83 ec 0c             	sub    $0xc,%esp
  801bcf:	50                   	push   %eax
  801bd0:	e8 c0 f2 ff ff       	call   800e95 <fd2num>
  801bd5:	83 c4 10             	add    $0x10,%esp
}
  801bd8:	c9                   	leave  
  801bd9:	c3                   	ret    

00801bda <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bda:	f3 0f 1e fb          	endbr32 
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
  801be1:	56                   	push   %esi
  801be2:	53                   	push   %ebx
  801be3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801be6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be9:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801bec:	85 c0                	test   %eax,%eax
  801bee:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801bf3:	0f 44 c2             	cmove  %edx,%eax
  801bf6:	83 ec 0c             	sub    $0xc,%esp
  801bf9:	50                   	push   %eax
  801bfa:	e8 51 f2 ff ff       	call   800e50 <sys_ipc_recv>
  801bff:	83 c4 10             	add    $0x10,%esp
  801c02:	85 c0                	test   %eax,%eax
  801c04:	78 24                	js     801c2a <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801c06:	85 f6                	test   %esi,%esi
  801c08:	74 0a                	je     801c14 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801c0a:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801c0f:	8b 40 78             	mov    0x78(%eax),%eax
  801c12:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801c14:	85 db                	test   %ebx,%ebx
  801c16:	74 0a                	je     801c22 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801c18:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801c1d:	8b 40 74             	mov    0x74(%eax),%eax
  801c20:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801c22:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801c27:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c2a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c2d:	5b                   	pop    %ebx
  801c2e:	5e                   	pop    %esi
  801c2f:	5d                   	pop    %ebp
  801c30:	c3                   	ret    

00801c31 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c31:	f3 0f 1e fb          	endbr32 
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	57                   	push   %edi
  801c39:	56                   	push   %esi
  801c3a:	53                   	push   %ebx
  801c3b:	83 ec 1c             	sub    $0x1c,%esp
  801c3e:	8b 45 10             	mov    0x10(%ebp),%eax
  801c41:	85 c0                	test   %eax,%eax
  801c43:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801c48:	0f 45 d0             	cmovne %eax,%edx
  801c4b:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801c4d:	be 01 00 00 00       	mov    $0x1,%esi
  801c52:	eb 1f                	jmp    801c73 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801c54:	e8 08 f0 ff ff       	call   800c61 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801c59:	83 c3 01             	add    $0x1,%ebx
  801c5c:	39 de                	cmp    %ebx,%esi
  801c5e:	7f f4                	jg     801c54 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801c60:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801c62:	83 fe 11             	cmp    $0x11,%esi
  801c65:	b8 01 00 00 00       	mov    $0x1,%eax
  801c6a:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801c6d:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801c71:	75 1c                	jne    801c8f <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801c73:	ff 75 14             	pushl  0x14(%ebp)
  801c76:	57                   	push   %edi
  801c77:	ff 75 0c             	pushl  0xc(%ebp)
  801c7a:	ff 75 08             	pushl  0x8(%ebp)
  801c7d:	e8 a7 f1 ff ff       	call   800e29 <sys_ipc_try_send>
  801c82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801c85:	83 c4 10             	add    $0x10,%esp
  801c88:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c8d:	eb cd                	jmp    801c5c <ipc_send+0x2b>
}
  801c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c92:	5b                   	pop    %ebx
  801c93:	5e                   	pop    %esi
  801c94:	5f                   	pop    %edi
  801c95:	5d                   	pop    %ebp
  801c96:	c3                   	ret    

00801c97 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c97:	f3 0f 1e fb          	endbr32 
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ca1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ca6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ca9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801caf:	8b 52 50             	mov    0x50(%edx),%edx
  801cb2:	39 ca                	cmp    %ecx,%edx
  801cb4:	74 11                	je     801cc7 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801cb6:	83 c0 01             	add    $0x1,%eax
  801cb9:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cbe:	75 e6                	jne    801ca6 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801cc0:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc5:	eb 0b                	jmp    801cd2 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801cc7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801cca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ccf:	8b 40 48             	mov    0x48(%eax),%eax
}
  801cd2:	5d                   	pop    %ebp
  801cd3:	c3                   	ret    

00801cd4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cd4:	f3 0f 1e fb          	endbr32 
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cde:	89 c2                	mov    %eax,%edx
  801ce0:	c1 ea 16             	shr    $0x16,%edx
  801ce3:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801cea:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801cef:	f6 c1 01             	test   $0x1,%cl
  801cf2:	74 1c                	je     801d10 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801cf4:	c1 e8 0c             	shr    $0xc,%eax
  801cf7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801cfe:	a8 01                	test   $0x1,%al
  801d00:	74 0e                	je     801d10 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d02:	c1 e8 0c             	shr    $0xc,%eax
  801d05:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801d0c:	ef 
  801d0d:	0f b7 d2             	movzwl %dx,%edx
}
  801d10:	89 d0                	mov    %edx,%eax
  801d12:	5d                   	pop    %ebp
  801d13:	c3                   	ret    
  801d14:	66 90                	xchg   %ax,%ax
  801d16:	66 90                	xchg   %ax,%ax
  801d18:	66 90                	xchg   %ax,%ax
  801d1a:	66 90                	xchg   %ax,%ax
  801d1c:	66 90                	xchg   %ax,%ax
  801d1e:	66 90                	xchg   %ax,%ax

00801d20 <__udivdi3>:
  801d20:	f3 0f 1e fb          	endbr32 
  801d24:	55                   	push   %ebp
  801d25:	57                   	push   %edi
  801d26:	56                   	push   %esi
  801d27:	53                   	push   %ebx
  801d28:	83 ec 1c             	sub    $0x1c,%esp
  801d2b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d2f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801d33:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d37:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801d3b:	85 d2                	test   %edx,%edx
  801d3d:	75 19                	jne    801d58 <__udivdi3+0x38>
  801d3f:	39 f3                	cmp    %esi,%ebx
  801d41:	76 4d                	jbe    801d90 <__udivdi3+0x70>
  801d43:	31 ff                	xor    %edi,%edi
  801d45:	89 e8                	mov    %ebp,%eax
  801d47:	89 f2                	mov    %esi,%edx
  801d49:	f7 f3                	div    %ebx
  801d4b:	89 fa                	mov    %edi,%edx
  801d4d:	83 c4 1c             	add    $0x1c,%esp
  801d50:	5b                   	pop    %ebx
  801d51:	5e                   	pop    %esi
  801d52:	5f                   	pop    %edi
  801d53:	5d                   	pop    %ebp
  801d54:	c3                   	ret    
  801d55:	8d 76 00             	lea    0x0(%esi),%esi
  801d58:	39 f2                	cmp    %esi,%edx
  801d5a:	76 14                	jbe    801d70 <__udivdi3+0x50>
  801d5c:	31 ff                	xor    %edi,%edi
  801d5e:	31 c0                	xor    %eax,%eax
  801d60:	89 fa                	mov    %edi,%edx
  801d62:	83 c4 1c             	add    $0x1c,%esp
  801d65:	5b                   	pop    %ebx
  801d66:	5e                   	pop    %esi
  801d67:	5f                   	pop    %edi
  801d68:	5d                   	pop    %ebp
  801d69:	c3                   	ret    
  801d6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d70:	0f bd fa             	bsr    %edx,%edi
  801d73:	83 f7 1f             	xor    $0x1f,%edi
  801d76:	75 48                	jne    801dc0 <__udivdi3+0xa0>
  801d78:	39 f2                	cmp    %esi,%edx
  801d7a:	72 06                	jb     801d82 <__udivdi3+0x62>
  801d7c:	31 c0                	xor    %eax,%eax
  801d7e:	39 eb                	cmp    %ebp,%ebx
  801d80:	77 de                	ja     801d60 <__udivdi3+0x40>
  801d82:	b8 01 00 00 00       	mov    $0x1,%eax
  801d87:	eb d7                	jmp    801d60 <__udivdi3+0x40>
  801d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d90:	89 d9                	mov    %ebx,%ecx
  801d92:	85 db                	test   %ebx,%ebx
  801d94:	75 0b                	jne    801da1 <__udivdi3+0x81>
  801d96:	b8 01 00 00 00       	mov    $0x1,%eax
  801d9b:	31 d2                	xor    %edx,%edx
  801d9d:	f7 f3                	div    %ebx
  801d9f:	89 c1                	mov    %eax,%ecx
  801da1:	31 d2                	xor    %edx,%edx
  801da3:	89 f0                	mov    %esi,%eax
  801da5:	f7 f1                	div    %ecx
  801da7:	89 c6                	mov    %eax,%esi
  801da9:	89 e8                	mov    %ebp,%eax
  801dab:	89 f7                	mov    %esi,%edi
  801dad:	f7 f1                	div    %ecx
  801daf:	89 fa                	mov    %edi,%edx
  801db1:	83 c4 1c             	add    $0x1c,%esp
  801db4:	5b                   	pop    %ebx
  801db5:	5e                   	pop    %esi
  801db6:	5f                   	pop    %edi
  801db7:	5d                   	pop    %ebp
  801db8:	c3                   	ret    
  801db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	89 f9                	mov    %edi,%ecx
  801dc2:	b8 20 00 00 00       	mov    $0x20,%eax
  801dc7:	29 f8                	sub    %edi,%eax
  801dc9:	d3 e2                	shl    %cl,%edx
  801dcb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dcf:	89 c1                	mov    %eax,%ecx
  801dd1:	89 da                	mov    %ebx,%edx
  801dd3:	d3 ea                	shr    %cl,%edx
  801dd5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801dd9:	09 d1                	or     %edx,%ecx
  801ddb:	89 f2                	mov    %esi,%edx
  801ddd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801de1:	89 f9                	mov    %edi,%ecx
  801de3:	d3 e3                	shl    %cl,%ebx
  801de5:	89 c1                	mov    %eax,%ecx
  801de7:	d3 ea                	shr    %cl,%edx
  801de9:	89 f9                	mov    %edi,%ecx
  801deb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801def:	89 eb                	mov    %ebp,%ebx
  801df1:	d3 e6                	shl    %cl,%esi
  801df3:	89 c1                	mov    %eax,%ecx
  801df5:	d3 eb                	shr    %cl,%ebx
  801df7:	09 de                	or     %ebx,%esi
  801df9:	89 f0                	mov    %esi,%eax
  801dfb:	f7 74 24 08          	divl   0x8(%esp)
  801dff:	89 d6                	mov    %edx,%esi
  801e01:	89 c3                	mov    %eax,%ebx
  801e03:	f7 64 24 0c          	mull   0xc(%esp)
  801e07:	39 d6                	cmp    %edx,%esi
  801e09:	72 15                	jb     801e20 <__udivdi3+0x100>
  801e0b:	89 f9                	mov    %edi,%ecx
  801e0d:	d3 e5                	shl    %cl,%ebp
  801e0f:	39 c5                	cmp    %eax,%ebp
  801e11:	73 04                	jae    801e17 <__udivdi3+0xf7>
  801e13:	39 d6                	cmp    %edx,%esi
  801e15:	74 09                	je     801e20 <__udivdi3+0x100>
  801e17:	89 d8                	mov    %ebx,%eax
  801e19:	31 ff                	xor    %edi,%edi
  801e1b:	e9 40 ff ff ff       	jmp    801d60 <__udivdi3+0x40>
  801e20:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801e23:	31 ff                	xor    %edi,%edi
  801e25:	e9 36 ff ff ff       	jmp    801d60 <__udivdi3+0x40>
  801e2a:	66 90                	xchg   %ax,%ax
  801e2c:	66 90                	xchg   %ax,%ax
  801e2e:	66 90                	xchg   %ax,%ax

00801e30 <__umoddi3>:
  801e30:	f3 0f 1e fb          	endbr32 
  801e34:	55                   	push   %ebp
  801e35:	57                   	push   %edi
  801e36:	56                   	push   %esi
  801e37:	53                   	push   %ebx
  801e38:	83 ec 1c             	sub    $0x1c,%esp
  801e3b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801e3f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801e43:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801e47:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e4b:	85 c0                	test   %eax,%eax
  801e4d:	75 19                	jne    801e68 <__umoddi3+0x38>
  801e4f:	39 df                	cmp    %ebx,%edi
  801e51:	76 5d                	jbe    801eb0 <__umoddi3+0x80>
  801e53:	89 f0                	mov    %esi,%eax
  801e55:	89 da                	mov    %ebx,%edx
  801e57:	f7 f7                	div    %edi
  801e59:	89 d0                	mov    %edx,%eax
  801e5b:	31 d2                	xor    %edx,%edx
  801e5d:	83 c4 1c             	add    $0x1c,%esp
  801e60:	5b                   	pop    %ebx
  801e61:	5e                   	pop    %esi
  801e62:	5f                   	pop    %edi
  801e63:	5d                   	pop    %ebp
  801e64:	c3                   	ret    
  801e65:	8d 76 00             	lea    0x0(%esi),%esi
  801e68:	89 f2                	mov    %esi,%edx
  801e6a:	39 d8                	cmp    %ebx,%eax
  801e6c:	76 12                	jbe    801e80 <__umoddi3+0x50>
  801e6e:	89 f0                	mov    %esi,%eax
  801e70:	89 da                	mov    %ebx,%edx
  801e72:	83 c4 1c             	add    $0x1c,%esp
  801e75:	5b                   	pop    %ebx
  801e76:	5e                   	pop    %esi
  801e77:	5f                   	pop    %edi
  801e78:	5d                   	pop    %ebp
  801e79:	c3                   	ret    
  801e7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e80:	0f bd e8             	bsr    %eax,%ebp
  801e83:	83 f5 1f             	xor    $0x1f,%ebp
  801e86:	75 50                	jne    801ed8 <__umoddi3+0xa8>
  801e88:	39 d8                	cmp    %ebx,%eax
  801e8a:	0f 82 e0 00 00 00    	jb     801f70 <__umoddi3+0x140>
  801e90:	89 d9                	mov    %ebx,%ecx
  801e92:	39 f7                	cmp    %esi,%edi
  801e94:	0f 86 d6 00 00 00    	jbe    801f70 <__umoddi3+0x140>
  801e9a:	89 d0                	mov    %edx,%eax
  801e9c:	89 ca                	mov    %ecx,%edx
  801e9e:	83 c4 1c             	add    $0x1c,%esp
  801ea1:	5b                   	pop    %ebx
  801ea2:	5e                   	pop    %esi
  801ea3:	5f                   	pop    %edi
  801ea4:	5d                   	pop    %ebp
  801ea5:	c3                   	ret    
  801ea6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ead:	8d 76 00             	lea    0x0(%esi),%esi
  801eb0:	89 fd                	mov    %edi,%ebp
  801eb2:	85 ff                	test   %edi,%edi
  801eb4:	75 0b                	jne    801ec1 <__umoddi3+0x91>
  801eb6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ebb:	31 d2                	xor    %edx,%edx
  801ebd:	f7 f7                	div    %edi
  801ebf:	89 c5                	mov    %eax,%ebp
  801ec1:	89 d8                	mov    %ebx,%eax
  801ec3:	31 d2                	xor    %edx,%edx
  801ec5:	f7 f5                	div    %ebp
  801ec7:	89 f0                	mov    %esi,%eax
  801ec9:	f7 f5                	div    %ebp
  801ecb:	89 d0                	mov    %edx,%eax
  801ecd:	31 d2                	xor    %edx,%edx
  801ecf:	eb 8c                	jmp    801e5d <__umoddi3+0x2d>
  801ed1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ed8:	89 e9                	mov    %ebp,%ecx
  801eda:	ba 20 00 00 00       	mov    $0x20,%edx
  801edf:	29 ea                	sub    %ebp,%edx
  801ee1:	d3 e0                	shl    %cl,%eax
  801ee3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ee7:	89 d1                	mov    %edx,%ecx
  801ee9:	89 f8                	mov    %edi,%eax
  801eeb:	d3 e8                	shr    %cl,%eax
  801eed:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801ef1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ef5:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ef9:	09 c1                	or     %eax,%ecx
  801efb:	89 d8                	mov    %ebx,%eax
  801efd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f01:	89 e9                	mov    %ebp,%ecx
  801f03:	d3 e7                	shl    %cl,%edi
  801f05:	89 d1                	mov    %edx,%ecx
  801f07:	d3 e8                	shr    %cl,%eax
  801f09:	89 e9                	mov    %ebp,%ecx
  801f0b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f0f:	d3 e3                	shl    %cl,%ebx
  801f11:	89 c7                	mov    %eax,%edi
  801f13:	89 d1                	mov    %edx,%ecx
  801f15:	89 f0                	mov    %esi,%eax
  801f17:	d3 e8                	shr    %cl,%eax
  801f19:	89 e9                	mov    %ebp,%ecx
  801f1b:	89 fa                	mov    %edi,%edx
  801f1d:	d3 e6                	shl    %cl,%esi
  801f1f:	09 d8                	or     %ebx,%eax
  801f21:	f7 74 24 08          	divl   0x8(%esp)
  801f25:	89 d1                	mov    %edx,%ecx
  801f27:	89 f3                	mov    %esi,%ebx
  801f29:	f7 64 24 0c          	mull   0xc(%esp)
  801f2d:	89 c6                	mov    %eax,%esi
  801f2f:	89 d7                	mov    %edx,%edi
  801f31:	39 d1                	cmp    %edx,%ecx
  801f33:	72 06                	jb     801f3b <__umoddi3+0x10b>
  801f35:	75 10                	jne    801f47 <__umoddi3+0x117>
  801f37:	39 c3                	cmp    %eax,%ebx
  801f39:	73 0c                	jae    801f47 <__umoddi3+0x117>
  801f3b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801f3f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801f43:	89 d7                	mov    %edx,%edi
  801f45:	89 c6                	mov    %eax,%esi
  801f47:	89 ca                	mov    %ecx,%edx
  801f49:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801f4e:	29 f3                	sub    %esi,%ebx
  801f50:	19 fa                	sbb    %edi,%edx
  801f52:	89 d0                	mov    %edx,%eax
  801f54:	d3 e0                	shl    %cl,%eax
  801f56:	89 e9                	mov    %ebp,%ecx
  801f58:	d3 eb                	shr    %cl,%ebx
  801f5a:	d3 ea                	shr    %cl,%edx
  801f5c:	09 d8                	or     %ebx,%eax
  801f5e:	83 c4 1c             	add    $0x1c,%esp
  801f61:	5b                   	pop    %ebx
  801f62:	5e                   	pop    %esi
  801f63:	5f                   	pop    %edi
  801f64:	5d                   	pop    %ebp
  801f65:	c3                   	ret    
  801f66:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f6d:	8d 76 00             	lea    0x0(%esi),%esi
  801f70:	29 fe                	sub    %edi,%esi
  801f72:	19 c3                	sbb    %eax,%ebx
  801f74:	89 f2                	mov    %esi,%edx
  801f76:	89 d9                	mov    %ebx,%ecx
  801f78:	e9 1d ff ff ff       	jmp    801e9a <__umoddi3+0x6a>
