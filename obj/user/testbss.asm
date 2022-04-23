
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
  80003d:	68 e0 10 80 00       	push   $0x8010e0
  800042:	e8 ea 01 00 00       	call   800231 <cprintf>
  800047:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  80004a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004f:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
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
  800068:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  80006f:	83 c0 01             	add    $0x1,%eax
  800072:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800077:	75 ef                	jne    800068 <umain+0x35>
	for (i = 0; i < ARRAYSIZE; i++)
  800079:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  80007e:	39 04 85 20 20 80 00 	cmp    %eax,0x802020(,%eax,4)
  800085:	75 47                	jne    8000ce <umain+0x9b>
	for (i = 0; i < ARRAYSIZE; i++)
  800087:	83 c0 01             	add    $0x1,%eax
  80008a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008f:	75 ed                	jne    80007e <umain+0x4b>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  800091:	83 ec 0c             	sub    $0xc,%esp
  800094:	68 28 11 80 00       	push   $0x801128
  800099:	e8 93 01 00 00       	call   800231 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  80009e:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000a5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000a8:	83 c4 0c             	add    $0xc,%esp
  8000ab:	68 87 11 80 00       	push   $0x801187
  8000b0:	6a 1a                	push   $0x1a
  8000b2:	68 78 11 80 00       	push   $0x801178
  8000b7:	e8 8e 00 00 00       	call   80014a <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000bc:	50                   	push   %eax
  8000bd:	68 5b 11 80 00       	push   $0x80115b
  8000c2:	6a 11                	push   $0x11
  8000c4:	68 78 11 80 00       	push   $0x801178
  8000c9:	e8 7c 00 00 00       	call   80014a <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ce:	50                   	push   %eax
  8000cf:	68 00 11 80 00       	push   $0x801100
  8000d4:	6a 16                	push   $0x16
  8000d6:	68 78 11 80 00       	push   $0x801178
  8000db:	e8 6a 00 00 00       	call   80014a <_panic>

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
  8000ef:	c7 05 20 20 c0 00 00 	movl   $0x0,0xc02020
  8000f6:	00 00 00 
    envid_t envid = sys_getenvid();
  8000f9:	e8 38 0b 00 00       	call   800c36 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8000fe:	25 ff 03 00 00       	and    $0x3ff,%eax
  800103:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800106:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010b:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800110:	85 db                	test   %ebx,%ebx
  800112:	7e 07                	jle    80011b <libmain+0x3b>
		binaryname = argv[0];
  800114:	8b 06                	mov    (%esi),%eax
  800116:	a3 00 20 80 00       	mov    %eax,0x802000

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
  80013b:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  80013e:	6a 00                	push   $0x0
  800140:	e8 ac 0a 00 00       	call   800bf1 <sys_env_destroy>
}
  800145:	83 c4 10             	add    $0x10,%esp
  800148:	c9                   	leave  
  800149:	c3                   	ret    

0080014a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014a:	f3 0f 1e fb          	endbr32 
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800153:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800156:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80015c:	e8 d5 0a 00 00       	call   800c36 <sys_getenvid>
  800161:	83 ec 0c             	sub    $0xc,%esp
  800164:	ff 75 0c             	pushl  0xc(%ebp)
  800167:	ff 75 08             	pushl  0x8(%ebp)
  80016a:	56                   	push   %esi
  80016b:	50                   	push   %eax
  80016c:	68 a8 11 80 00       	push   $0x8011a8
  800171:	e8 bb 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800176:	83 c4 18             	add    $0x18,%esp
  800179:	53                   	push   %ebx
  80017a:	ff 75 10             	pushl  0x10(%ebp)
  80017d:	e8 5a 00 00 00       	call   8001dc <vcprintf>
	cprintf("\n");
  800182:	c7 04 24 76 11 80 00 	movl   $0x801176,(%esp)
  800189:	e8 a3 00 00 00       	call   800231 <cprintf>
  80018e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800191:	cc                   	int3   
  800192:	eb fd                	jmp    800191 <_panic+0x47>

00800194 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800194:	f3 0f 1e fb          	endbr32 
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	53                   	push   %ebx
  80019c:	83 ec 04             	sub    $0x4,%esp
  80019f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a2:	8b 13                	mov    (%ebx),%edx
  8001a4:	8d 42 01             	lea    0x1(%edx),%eax
  8001a7:	89 03                	mov    %eax,(%ebx)
  8001a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ac:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b5:	74 09                	je     8001c0 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001b7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001c0:	83 ec 08             	sub    $0x8,%esp
  8001c3:	68 ff 00 00 00       	push   $0xff
  8001c8:	8d 43 08             	lea    0x8(%ebx),%eax
  8001cb:	50                   	push   %eax
  8001cc:	e8 db 09 00 00       	call   800bac <sys_cputs>
		b->idx = 0;
  8001d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d7:	83 c4 10             	add    $0x10,%esp
  8001da:	eb db                	jmp    8001b7 <putch+0x23>

008001dc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001dc:	f3 0f 1e fb          	endbr32 
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f0:	00 00 00 
	b.cnt = 0;
  8001f3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fd:	ff 75 0c             	pushl  0xc(%ebp)
  800200:	ff 75 08             	pushl  0x8(%ebp)
  800203:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800209:	50                   	push   %eax
  80020a:	68 94 01 80 00       	push   $0x800194
  80020f:	e8 20 01 00 00       	call   800334 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800214:	83 c4 08             	add    $0x8,%esp
  800217:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800223:	50                   	push   %eax
  800224:	e8 83 09 00 00       	call   800bac <sys_cputs>

	return b.cnt;
}
  800229:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800231:	f3 0f 1e fb          	endbr32 
  800235:	55                   	push   %ebp
  800236:	89 e5                	mov    %esp,%ebp
  800238:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023e:	50                   	push   %eax
  80023f:	ff 75 08             	pushl  0x8(%ebp)
  800242:	e8 95 ff ff ff       	call   8001dc <vcprintf>
	va_end(ap);

	return cnt;
}
  800247:	c9                   	leave  
  800248:	c3                   	ret    

00800249 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800249:	55                   	push   %ebp
  80024a:	89 e5                	mov    %esp,%ebp
  80024c:	57                   	push   %edi
  80024d:	56                   	push   %esi
  80024e:	53                   	push   %ebx
  80024f:	83 ec 1c             	sub    $0x1c,%esp
  800252:	89 c7                	mov    %eax,%edi
  800254:	89 d6                	mov    %edx,%esi
  800256:	8b 45 08             	mov    0x8(%ebp),%eax
  800259:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025c:	89 d1                	mov    %edx,%ecx
  80025e:	89 c2                	mov    %eax,%edx
  800260:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800263:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800266:	8b 45 10             	mov    0x10(%ebp),%eax
  800269:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80026c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80026f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800276:	39 c2                	cmp    %eax,%edx
  800278:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80027b:	72 3e                	jb     8002bb <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027d:	83 ec 0c             	sub    $0xc,%esp
  800280:	ff 75 18             	pushl  0x18(%ebp)
  800283:	83 eb 01             	sub    $0x1,%ebx
  800286:	53                   	push   %ebx
  800287:	50                   	push   %eax
  800288:	83 ec 08             	sub    $0x8,%esp
  80028b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028e:	ff 75 e0             	pushl  -0x20(%ebp)
  800291:	ff 75 dc             	pushl  -0x24(%ebp)
  800294:	ff 75 d8             	pushl  -0x28(%ebp)
  800297:	e8 d4 0b 00 00       	call   800e70 <__udivdi3>
  80029c:	83 c4 18             	add    $0x18,%esp
  80029f:	52                   	push   %edx
  8002a0:	50                   	push   %eax
  8002a1:	89 f2                	mov    %esi,%edx
  8002a3:	89 f8                	mov    %edi,%eax
  8002a5:	e8 9f ff ff ff       	call   800249 <printnum>
  8002aa:	83 c4 20             	add    $0x20,%esp
  8002ad:	eb 13                	jmp    8002c2 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002af:	83 ec 08             	sub    $0x8,%esp
  8002b2:	56                   	push   %esi
  8002b3:	ff 75 18             	pushl  0x18(%ebp)
  8002b6:	ff d7                	call   *%edi
  8002b8:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002bb:	83 eb 01             	sub    $0x1,%ebx
  8002be:	85 db                	test   %ebx,%ebx
  8002c0:	7f ed                	jg     8002af <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c2:	83 ec 08             	sub    $0x8,%esp
  8002c5:	56                   	push   %esi
  8002c6:	83 ec 04             	sub    $0x4,%esp
  8002c9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8002cf:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d2:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d5:	e8 a6 0c 00 00       	call   800f80 <__umoddi3>
  8002da:	83 c4 14             	add    $0x14,%esp
  8002dd:	0f be 80 cb 11 80 00 	movsbl 0x8011cb(%eax),%eax
  8002e4:	50                   	push   %eax
  8002e5:	ff d7                	call   *%edi
}
  8002e7:	83 c4 10             	add    $0x10,%esp
  8002ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ed:	5b                   	pop    %ebx
  8002ee:	5e                   	pop    %esi
  8002ef:	5f                   	pop    %edi
  8002f0:	5d                   	pop    %ebp
  8002f1:	c3                   	ret    

008002f2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f2:	f3 0f 1e fb          	endbr32 
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800300:	8b 10                	mov    (%eax),%edx
  800302:	3b 50 04             	cmp    0x4(%eax),%edx
  800305:	73 0a                	jae    800311 <sprintputch+0x1f>
		*b->buf++ = ch;
  800307:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030a:	89 08                	mov    %ecx,(%eax)
  80030c:	8b 45 08             	mov    0x8(%ebp),%eax
  80030f:	88 02                	mov    %al,(%edx)
}
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <printfmt>:
{
  800313:	f3 0f 1e fb          	endbr32 
  800317:	55                   	push   %ebp
  800318:	89 e5                	mov    %esp,%ebp
  80031a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80031d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800320:	50                   	push   %eax
  800321:	ff 75 10             	pushl  0x10(%ebp)
  800324:	ff 75 0c             	pushl  0xc(%ebp)
  800327:	ff 75 08             	pushl  0x8(%ebp)
  80032a:	e8 05 00 00 00       	call   800334 <vprintfmt>
}
  80032f:	83 c4 10             	add    $0x10,%esp
  800332:	c9                   	leave  
  800333:	c3                   	ret    

00800334 <vprintfmt>:
{
  800334:	f3 0f 1e fb          	endbr32 
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	57                   	push   %edi
  80033c:	56                   	push   %esi
  80033d:	53                   	push   %ebx
  80033e:	83 ec 3c             	sub    $0x3c,%esp
  800341:	8b 75 08             	mov    0x8(%ebp),%esi
  800344:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800347:	8b 7d 10             	mov    0x10(%ebp),%edi
  80034a:	e9 4a 03 00 00       	jmp    800699 <vprintfmt+0x365>
		padc = ' ';
  80034f:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800353:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80035a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800361:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800368:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	8d 47 01             	lea    0x1(%edi),%eax
  800370:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800373:	0f b6 17             	movzbl (%edi),%edx
  800376:	8d 42 dd             	lea    -0x23(%edx),%eax
  800379:	3c 55                	cmp    $0x55,%al
  80037b:	0f 87 de 03 00 00    	ja     80075f <vprintfmt+0x42b>
  800381:	0f b6 c0             	movzbl %al,%eax
  800384:	3e ff 24 85 20 13 80 	notrack jmp *0x801320(,%eax,4)
  80038b:	00 
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80038f:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800393:	eb d8                	jmp    80036d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800398:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80039c:	eb cf                	jmp    80036d <vprintfmt+0x39>
  80039e:	0f b6 d2             	movzbl %dl,%edx
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003ac:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003af:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003b3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003b6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003b9:	83 f9 09             	cmp    $0x9,%ecx
  8003bc:	77 55                	ja     800413 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003be:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003c1:	eb e9                	jmp    8003ac <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c6:	8b 00                	mov    (%eax),%eax
  8003c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ce:	8d 40 04             	lea    0x4(%eax),%eax
  8003d1:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003d7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003db:	79 90                	jns    80036d <vprintfmt+0x39>
				width = precision, precision = -1;
  8003dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e3:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003ea:	eb 81                	jmp    80036d <vprintfmt+0x39>
  8003ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ef:	85 c0                	test   %eax,%eax
  8003f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f6:	0f 49 d0             	cmovns %eax,%edx
  8003f9:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ff:	e9 69 ff ff ff       	jmp    80036d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800407:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80040e:	e9 5a ff ff ff       	jmp    80036d <vprintfmt+0x39>
  800413:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800416:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800419:	eb bc                	jmp    8003d7 <vprintfmt+0xa3>
			lflag++;
  80041b:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800421:	e9 47 ff ff ff       	jmp    80036d <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800426:	8b 45 14             	mov    0x14(%ebp),%eax
  800429:	8d 78 04             	lea    0x4(%eax),%edi
  80042c:	83 ec 08             	sub    $0x8,%esp
  80042f:	53                   	push   %ebx
  800430:	ff 30                	pushl  (%eax)
  800432:	ff d6                	call   *%esi
			break;
  800434:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800437:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80043a:	e9 57 02 00 00       	jmp    800696 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8d 78 04             	lea    0x4(%eax),%edi
  800445:	8b 00                	mov    (%eax),%eax
  800447:	99                   	cltd   
  800448:	31 d0                	xor    %edx,%eax
  80044a:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044c:	83 f8 0f             	cmp    $0xf,%eax
  80044f:	7f 23                	jg     800474 <vprintfmt+0x140>
  800451:	8b 14 85 80 14 80 00 	mov    0x801480(,%eax,4),%edx
  800458:	85 d2                	test   %edx,%edx
  80045a:	74 18                	je     800474 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80045c:	52                   	push   %edx
  80045d:	68 ec 11 80 00       	push   $0x8011ec
  800462:	53                   	push   %ebx
  800463:	56                   	push   %esi
  800464:	e8 aa fe ff ff       	call   800313 <printfmt>
  800469:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80046c:	89 7d 14             	mov    %edi,0x14(%ebp)
  80046f:	e9 22 02 00 00       	jmp    800696 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800474:	50                   	push   %eax
  800475:	68 e3 11 80 00       	push   $0x8011e3
  80047a:	53                   	push   %ebx
  80047b:	56                   	push   %esi
  80047c:	e8 92 fe ff ff       	call   800313 <printfmt>
  800481:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800484:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800487:	e9 0a 02 00 00       	jmp    800696 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	83 c0 04             	add    $0x4,%eax
  800492:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80049a:	85 d2                	test   %edx,%edx
  80049c:	b8 dc 11 80 00       	mov    $0x8011dc,%eax
  8004a1:	0f 45 c2             	cmovne %edx,%eax
  8004a4:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004a7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ab:	7e 06                	jle    8004b3 <vprintfmt+0x17f>
  8004ad:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004b1:	75 0d                	jne    8004c0 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004b6:	89 c7                	mov    %eax,%edi
  8004b8:	03 45 e0             	add    -0x20(%ebp),%eax
  8004bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004be:	eb 55                	jmp    800515 <vprintfmt+0x1e1>
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c6:	ff 75 cc             	pushl  -0x34(%ebp)
  8004c9:	e8 45 03 00 00       	call   800813 <strnlen>
  8004ce:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004d1:	29 c2                	sub    %eax,%edx
  8004d3:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004d6:	83 c4 10             	add    $0x10,%esp
  8004d9:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004db:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004df:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e2:	85 ff                	test   %edi,%edi
  8004e4:	7e 11                	jle    8004f7 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	53                   	push   %ebx
  8004ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ed:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ef:	83 ef 01             	sub    $0x1,%edi
  8004f2:	83 c4 10             	add    $0x10,%esp
  8004f5:	eb eb                	jmp    8004e2 <vprintfmt+0x1ae>
  8004f7:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004fa:	85 d2                	test   %edx,%edx
  8004fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800501:	0f 49 c2             	cmovns %edx,%eax
  800504:	29 c2                	sub    %eax,%edx
  800506:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800509:	eb a8                	jmp    8004b3 <vprintfmt+0x17f>
					putch(ch, putdat);
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	53                   	push   %ebx
  80050f:	52                   	push   %edx
  800510:	ff d6                	call   *%esi
  800512:	83 c4 10             	add    $0x10,%esp
  800515:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800518:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051a:	83 c7 01             	add    $0x1,%edi
  80051d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800521:	0f be d0             	movsbl %al,%edx
  800524:	85 d2                	test   %edx,%edx
  800526:	74 4b                	je     800573 <vprintfmt+0x23f>
  800528:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80052c:	78 06                	js     800534 <vprintfmt+0x200>
  80052e:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800532:	78 1e                	js     800552 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800534:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800538:	74 d1                	je     80050b <vprintfmt+0x1d7>
  80053a:	0f be c0             	movsbl %al,%eax
  80053d:	83 e8 20             	sub    $0x20,%eax
  800540:	83 f8 5e             	cmp    $0x5e,%eax
  800543:	76 c6                	jbe    80050b <vprintfmt+0x1d7>
					putch('?', putdat);
  800545:	83 ec 08             	sub    $0x8,%esp
  800548:	53                   	push   %ebx
  800549:	6a 3f                	push   $0x3f
  80054b:	ff d6                	call   *%esi
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	eb c3                	jmp    800515 <vprintfmt+0x1e1>
  800552:	89 cf                	mov    %ecx,%edi
  800554:	eb 0e                	jmp    800564 <vprintfmt+0x230>
				putch(' ', putdat);
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	53                   	push   %ebx
  80055a:	6a 20                	push   $0x20
  80055c:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80055e:	83 ef 01             	sub    $0x1,%edi
  800561:	83 c4 10             	add    $0x10,%esp
  800564:	85 ff                	test   %edi,%edi
  800566:	7f ee                	jg     800556 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800568:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80056b:	89 45 14             	mov    %eax,0x14(%ebp)
  80056e:	e9 23 01 00 00       	jmp    800696 <vprintfmt+0x362>
  800573:	89 cf                	mov    %ecx,%edi
  800575:	eb ed                	jmp    800564 <vprintfmt+0x230>
	if (lflag >= 2)
  800577:	83 f9 01             	cmp    $0x1,%ecx
  80057a:	7f 1b                	jg     800597 <vprintfmt+0x263>
	else if (lflag)
  80057c:	85 c9                	test   %ecx,%ecx
  80057e:	74 63                	je     8005e3 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8b 00                	mov    (%eax),%eax
  800585:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800588:	99                   	cltd   
  800589:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8d 40 04             	lea    0x4(%eax),%eax
  800592:	89 45 14             	mov    %eax,0x14(%ebp)
  800595:	eb 17                	jmp    8005ae <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8b 50 04             	mov    0x4(%eax),%edx
  80059d:	8b 00                	mov    (%eax),%eax
  80059f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8d 40 08             	lea    0x8(%eax),%eax
  8005ab:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005ae:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005b4:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005b9:	85 c9                	test   %ecx,%ecx
  8005bb:	0f 89 bb 00 00 00    	jns    80067c <vprintfmt+0x348>
				putch('-', putdat);
  8005c1:	83 ec 08             	sub    $0x8,%esp
  8005c4:	53                   	push   %ebx
  8005c5:	6a 2d                	push   $0x2d
  8005c7:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005cc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005cf:	f7 da                	neg    %edx
  8005d1:	83 d1 00             	adc    $0x0,%ecx
  8005d4:	f7 d9                	neg    %ecx
  8005d6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005de:	e9 99 00 00 00       	jmp    80067c <vprintfmt+0x348>
		return va_arg(*ap, int);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8b 00                	mov    (%eax),%eax
  8005e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005eb:	99                   	cltd   
  8005ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 40 04             	lea    0x4(%eax),%eax
  8005f5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f8:	eb b4                	jmp    8005ae <vprintfmt+0x27a>
	if (lflag >= 2)
  8005fa:	83 f9 01             	cmp    $0x1,%ecx
  8005fd:	7f 1b                	jg     80061a <vprintfmt+0x2e6>
	else if (lflag)
  8005ff:	85 c9                	test   %ecx,%ecx
  800601:	74 2c                	je     80062f <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8b 10                	mov    (%eax),%edx
  800608:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060d:	8d 40 04             	lea    0x4(%eax),%eax
  800610:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800613:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800618:	eb 62                	jmp    80067c <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8b 10                	mov    (%eax),%edx
  80061f:	8b 48 04             	mov    0x4(%eax),%ecx
  800622:	8d 40 08             	lea    0x8(%eax),%eax
  800625:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800628:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80062d:	eb 4d                	jmp    80067c <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8b 10                	mov    (%eax),%edx
  800634:	b9 00 00 00 00       	mov    $0x0,%ecx
  800639:	8d 40 04             	lea    0x4(%eax),%eax
  80063c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80063f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800644:	eb 36                	jmp    80067c <vprintfmt+0x348>
	if (lflag >= 2)
  800646:	83 f9 01             	cmp    $0x1,%ecx
  800649:	7f 17                	jg     800662 <vprintfmt+0x32e>
	else if (lflag)
  80064b:	85 c9                	test   %ecx,%ecx
  80064d:	74 6e                	je     8006bd <vprintfmt+0x389>
		return va_arg(*ap, long);
  80064f:	8b 45 14             	mov    0x14(%ebp),%eax
  800652:	8b 10                	mov    (%eax),%edx
  800654:	89 d0                	mov    %edx,%eax
  800656:	99                   	cltd   
  800657:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80065a:	8d 49 04             	lea    0x4(%ecx),%ecx
  80065d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800660:	eb 11                	jmp    800673 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8b 50 04             	mov    0x4(%eax),%edx
  800668:	8b 00                	mov    (%eax),%eax
  80066a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80066d:	8d 49 08             	lea    0x8(%ecx),%ecx
  800670:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800673:	89 d1                	mov    %edx,%ecx
  800675:	89 c2                	mov    %eax,%edx
            base = 8;
  800677:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80067c:	83 ec 0c             	sub    $0xc,%esp
  80067f:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800683:	57                   	push   %edi
  800684:	ff 75 e0             	pushl  -0x20(%ebp)
  800687:	50                   	push   %eax
  800688:	51                   	push   %ecx
  800689:	52                   	push   %edx
  80068a:	89 da                	mov    %ebx,%edx
  80068c:	89 f0                	mov    %esi,%eax
  80068e:	e8 b6 fb ff ff       	call   800249 <printnum>
			break;
  800693:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800696:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800699:	83 c7 01             	add    $0x1,%edi
  80069c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006a0:	83 f8 25             	cmp    $0x25,%eax
  8006a3:	0f 84 a6 fc ff ff    	je     80034f <vprintfmt+0x1b>
			if (ch == '\0')
  8006a9:	85 c0                	test   %eax,%eax
  8006ab:	0f 84 ce 00 00 00    	je     80077f <vprintfmt+0x44b>
			putch(ch, putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	53                   	push   %ebx
  8006b5:	50                   	push   %eax
  8006b6:	ff d6                	call   *%esi
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	eb dc                	jmp    800699 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8b 10                	mov    (%eax),%edx
  8006c2:	89 d0                	mov    %edx,%eax
  8006c4:	99                   	cltd   
  8006c5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006c8:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006cb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006ce:	eb a3                	jmp    800673 <vprintfmt+0x33f>
			putch('0', putdat);
  8006d0:	83 ec 08             	sub    $0x8,%esp
  8006d3:	53                   	push   %ebx
  8006d4:	6a 30                	push   $0x30
  8006d6:	ff d6                	call   *%esi
			putch('x', putdat);
  8006d8:	83 c4 08             	add    $0x8,%esp
  8006db:	53                   	push   %ebx
  8006dc:	6a 78                	push   $0x78
  8006de:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8b 10                	mov    (%eax),%edx
  8006e5:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006ea:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006ed:	8d 40 04             	lea    0x4(%eax),%eax
  8006f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006f8:	eb 82                	jmp    80067c <vprintfmt+0x348>
	if (lflag >= 2)
  8006fa:	83 f9 01             	cmp    $0x1,%ecx
  8006fd:	7f 1e                	jg     80071d <vprintfmt+0x3e9>
	else if (lflag)
  8006ff:	85 c9                	test   %ecx,%ecx
  800701:	74 32                	je     800735 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800703:	8b 45 14             	mov    0x14(%ebp),%eax
  800706:	8b 10                	mov    (%eax),%edx
  800708:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070d:	8d 40 04             	lea    0x4(%eax),%eax
  800710:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800713:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800718:	e9 5f ff ff ff       	jmp    80067c <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80071d:	8b 45 14             	mov    0x14(%ebp),%eax
  800720:	8b 10                	mov    (%eax),%edx
  800722:	8b 48 04             	mov    0x4(%eax),%ecx
  800725:	8d 40 08             	lea    0x8(%eax),%eax
  800728:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800730:	e9 47 ff ff ff       	jmp    80067c <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800735:	8b 45 14             	mov    0x14(%ebp),%eax
  800738:	8b 10                	mov    (%eax),%edx
  80073a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073f:	8d 40 04             	lea    0x4(%eax),%eax
  800742:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800745:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80074a:	e9 2d ff ff ff       	jmp    80067c <vprintfmt+0x348>
			putch(ch, putdat);
  80074f:	83 ec 08             	sub    $0x8,%esp
  800752:	53                   	push   %ebx
  800753:	6a 25                	push   $0x25
  800755:	ff d6                	call   *%esi
			break;
  800757:	83 c4 10             	add    $0x10,%esp
  80075a:	e9 37 ff ff ff       	jmp    800696 <vprintfmt+0x362>
			putch('%', putdat);
  80075f:	83 ec 08             	sub    $0x8,%esp
  800762:	53                   	push   %ebx
  800763:	6a 25                	push   $0x25
  800765:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800767:	83 c4 10             	add    $0x10,%esp
  80076a:	89 f8                	mov    %edi,%eax
  80076c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800770:	74 05                	je     800777 <vprintfmt+0x443>
  800772:	83 e8 01             	sub    $0x1,%eax
  800775:	eb f5                	jmp    80076c <vprintfmt+0x438>
  800777:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80077a:	e9 17 ff ff ff       	jmp    800696 <vprintfmt+0x362>
}
  80077f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800782:	5b                   	pop    %ebx
  800783:	5e                   	pop    %esi
  800784:	5f                   	pop    %edi
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800787:	f3 0f 1e fb          	endbr32 
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	83 ec 18             	sub    $0x18,%esp
  800791:	8b 45 08             	mov    0x8(%ebp),%eax
  800794:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800797:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80079a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80079e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007a8:	85 c0                	test   %eax,%eax
  8007aa:	74 26                	je     8007d2 <vsnprintf+0x4b>
  8007ac:	85 d2                	test   %edx,%edx
  8007ae:	7e 22                	jle    8007d2 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b0:	ff 75 14             	pushl  0x14(%ebp)
  8007b3:	ff 75 10             	pushl  0x10(%ebp)
  8007b6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b9:	50                   	push   %eax
  8007ba:	68 f2 02 80 00       	push   $0x8002f2
  8007bf:	e8 70 fb ff ff       	call   800334 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007cd:	83 c4 10             	add    $0x10,%esp
}
  8007d0:	c9                   	leave  
  8007d1:	c3                   	ret    
		return -E_INVAL;
  8007d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d7:	eb f7                	jmp    8007d0 <vsnprintf+0x49>

008007d9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d9:	f3 0f 1e fb          	endbr32 
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007e3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007e6:	50                   	push   %eax
  8007e7:	ff 75 10             	pushl  0x10(%ebp)
  8007ea:	ff 75 0c             	pushl  0xc(%ebp)
  8007ed:	ff 75 08             	pushl  0x8(%ebp)
  8007f0:	e8 92 ff ff ff       	call   800787 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f5:	c9                   	leave  
  8007f6:	c3                   	ret    

008007f7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f7:	f3 0f 1e fb          	endbr32 
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800801:	b8 00 00 00 00       	mov    $0x0,%eax
  800806:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80080a:	74 05                	je     800811 <strlen+0x1a>
		n++;
  80080c:	83 c0 01             	add    $0x1,%eax
  80080f:	eb f5                	jmp    800806 <strlen+0xf>
	return n;
}
  800811:	5d                   	pop    %ebp
  800812:	c3                   	ret    

00800813 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800813:	f3 0f 1e fb          	endbr32 
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800820:	b8 00 00 00 00       	mov    $0x0,%eax
  800825:	39 d0                	cmp    %edx,%eax
  800827:	74 0d                	je     800836 <strnlen+0x23>
  800829:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80082d:	74 05                	je     800834 <strnlen+0x21>
		n++;
  80082f:	83 c0 01             	add    $0x1,%eax
  800832:	eb f1                	jmp    800825 <strnlen+0x12>
  800834:	89 c2                	mov    %eax,%edx
	return n;
}
  800836:	89 d0                	mov    %edx,%eax
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80083a:	f3 0f 1e fb          	endbr32 
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	53                   	push   %ebx
  800842:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800845:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800848:	b8 00 00 00 00       	mov    $0x0,%eax
  80084d:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800851:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800854:	83 c0 01             	add    $0x1,%eax
  800857:	84 d2                	test   %dl,%dl
  800859:	75 f2                	jne    80084d <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80085b:	89 c8                	mov    %ecx,%eax
  80085d:	5b                   	pop    %ebx
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800860:	f3 0f 1e fb          	endbr32 
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	53                   	push   %ebx
  800868:	83 ec 10             	sub    $0x10,%esp
  80086b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80086e:	53                   	push   %ebx
  80086f:	e8 83 ff ff ff       	call   8007f7 <strlen>
  800874:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800877:	ff 75 0c             	pushl  0xc(%ebp)
  80087a:	01 d8                	add    %ebx,%eax
  80087c:	50                   	push   %eax
  80087d:	e8 b8 ff ff ff       	call   80083a <strcpy>
	return dst;
}
  800882:	89 d8                	mov    %ebx,%eax
  800884:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800887:	c9                   	leave  
  800888:	c3                   	ret    

00800889 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800889:	f3 0f 1e fb          	endbr32 
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	56                   	push   %esi
  800891:	53                   	push   %ebx
  800892:	8b 75 08             	mov    0x8(%ebp),%esi
  800895:	8b 55 0c             	mov    0xc(%ebp),%edx
  800898:	89 f3                	mov    %esi,%ebx
  80089a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089d:	89 f0                	mov    %esi,%eax
  80089f:	39 d8                	cmp    %ebx,%eax
  8008a1:	74 11                	je     8008b4 <strncpy+0x2b>
		*dst++ = *src;
  8008a3:	83 c0 01             	add    $0x1,%eax
  8008a6:	0f b6 0a             	movzbl (%edx),%ecx
  8008a9:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ac:	80 f9 01             	cmp    $0x1,%cl
  8008af:	83 da ff             	sbb    $0xffffffff,%edx
  8008b2:	eb eb                	jmp    80089f <strncpy+0x16>
	}
	return ret;
}
  8008b4:	89 f0                	mov    %esi,%eax
  8008b6:	5b                   	pop    %ebx
  8008b7:	5e                   	pop    %esi
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ba:	f3 0f 1e fb          	endbr32 
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	56                   	push   %esi
  8008c2:	53                   	push   %ebx
  8008c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c9:	8b 55 10             	mov    0x10(%ebp),%edx
  8008cc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ce:	85 d2                	test   %edx,%edx
  8008d0:	74 21                	je     8008f3 <strlcpy+0x39>
  8008d2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008d6:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008d8:	39 c2                	cmp    %eax,%edx
  8008da:	74 14                	je     8008f0 <strlcpy+0x36>
  8008dc:	0f b6 19             	movzbl (%ecx),%ebx
  8008df:	84 db                	test   %bl,%bl
  8008e1:	74 0b                	je     8008ee <strlcpy+0x34>
			*dst++ = *src++;
  8008e3:	83 c1 01             	add    $0x1,%ecx
  8008e6:	83 c2 01             	add    $0x1,%edx
  8008e9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ec:	eb ea                	jmp    8008d8 <strlcpy+0x1e>
  8008ee:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008f0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f3:	29 f0                	sub    %esi,%eax
}
  8008f5:	5b                   	pop    %ebx
  8008f6:	5e                   	pop    %esi
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f9:	f3 0f 1e fb          	endbr32 
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800903:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800906:	0f b6 01             	movzbl (%ecx),%eax
  800909:	84 c0                	test   %al,%al
  80090b:	74 0c                	je     800919 <strcmp+0x20>
  80090d:	3a 02                	cmp    (%edx),%al
  80090f:	75 08                	jne    800919 <strcmp+0x20>
		p++, q++;
  800911:	83 c1 01             	add    $0x1,%ecx
  800914:	83 c2 01             	add    $0x1,%edx
  800917:	eb ed                	jmp    800906 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800919:	0f b6 c0             	movzbl %al,%eax
  80091c:	0f b6 12             	movzbl (%edx),%edx
  80091f:	29 d0                	sub    %edx,%eax
}
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800923:	f3 0f 1e fb          	endbr32 
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	53                   	push   %ebx
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800931:	89 c3                	mov    %eax,%ebx
  800933:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800936:	eb 06                	jmp    80093e <strncmp+0x1b>
		n--, p++, q++;
  800938:	83 c0 01             	add    $0x1,%eax
  80093b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80093e:	39 d8                	cmp    %ebx,%eax
  800940:	74 16                	je     800958 <strncmp+0x35>
  800942:	0f b6 08             	movzbl (%eax),%ecx
  800945:	84 c9                	test   %cl,%cl
  800947:	74 04                	je     80094d <strncmp+0x2a>
  800949:	3a 0a                	cmp    (%edx),%cl
  80094b:	74 eb                	je     800938 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80094d:	0f b6 00             	movzbl (%eax),%eax
  800950:	0f b6 12             	movzbl (%edx),%edx
  800953:	29 d0                	sub    %edx,%eax
}
  800955:	5b                   	pop    %ebx
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    
		return 0;
  800958:	b8 00 00 00 00       	mov    $0x0,%eax
  80095d:	eb f6                	jmp    800955 <strncmp+0x32>

0080095f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80095f:	f3 0f 1e fb          	endbr32 
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80096d:	0f b6 10             	movzbl (%eax),%edx
  800970:	84 d2                	test   %dl,%dl
  800972:	74 09                	je     80097d <strchr+0x1e>
		if (*s == c)
  800974:	38 ca                	cmp    %cl,%dl
  800976:	74 0a                	je     800982 <strchr+0x23>
	for (; *s; s++)
  800978:	83 c0 01             	add    $0x1,%eax
  80097b:	eb f0                	jmp    80096d <strchr+0xe>
			return (char *) s;
	return 0;
  80097d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800984:	f3 0f 1e fb          	endbr32 
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800992:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800995:	38 ca                	cmp    %cl,%dl
  800997:	74 09                	je     8009a2 <strfind+0x1e>
  800999:	84 d2                	test   %dl,%dl
  80099b:	74 05                	je     8009a2 <strfind+0x1e>
	for (; *s; s++)
  80099d:	83 c0 01             	add    $0x1,%eax
  8009a0:	eb f0                	jmp    800992 <strfind+0xe>
			break;
	return (char *) s;
}
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a4:	f3 0f 1e fb          	endbr32 
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	57                   	push   %edi
  8009ac:	56                   	push   %esi
  8009ad:	53                   	push   %ebx
  8009ae:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b4:	85 c9                	test   %ecx,%ecx
  8009b6:	74 31                	je     8009e9 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b8:	89 f8                	mov    %edi,%eax
  8009ba:	09 c8                	or     %ecx,%eax
  8009bc:	a8 03                	test   $0x3,%al
  8009be:	75 23                	jne    8009e3 <memset+0x3f>
		c &= 0xFF;
  8009c0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c4:	89 d3                	mov    %edx,%ebx
  8009c6:	c1 e3 08             	shl    $0x8,%ebx
  8009c9:	89 d0                	mov    %edx,%eax
  8009cb:	c1 e0 18             	shl    $0x18,%eax
  8009ce:	89 d6                	mov    %edx,%esi
  8009d0:	c1 e6 10             	shl    $0x10,%esi
  8009d3:	09 f0                	or     %esi,%eax
  8009d5:	09 c2                	or     %eax,%edx
  8009d7:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009d9:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009dc:	89 d0                	mov    %edx,%eax
  8009de:	fc                   	cld    
  8009df:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e1:	eb 06                	jmp    8009e9 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e6:	fc                   	cld    
  8009e7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e9:	89 f8                	mov    %edi,%eax
  8009eb:	5b                   	pop    %ebx
  8009ec:	5e                   	pop    %esi
  8009ed:	5f                   	pop    %edi
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f0:	f3 0f 1e fb          	endbr32 
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	57                   	push   %edi
  8009f8:	56                   	push   %esi
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a02:	39 c6                	cmp    %eax,%esi
  800a04:	73 32                	jae    800a38 <memmove+0x48>
  800a06:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a09:	39 c2                	cmp    %eax,%edx
  800a0b:	76 2b                	jbe    800a38 <memmove+0x48>
		s += n;
		d += n;
  800a0d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a10:	89 fe                	mov    %edi,%esi
  800a12:	09 ce                	or     %ecx,%esi
  800a14:	09 d6                	or     %edx,%esi
  800a16:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a1c:	75 0e                	jne    800a2c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a1e:	83 ef 04             	sub    $0x4,%edi
  800a21:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a24:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a27:	fd                   	std    
  800a28:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2a:	eb 09                	jmp    800a35 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a2c:	83 ef 01             	sub    $0x1,%edi
  800a2f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a32:	fd                   	std    
  800a33:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a35:	fc                   	cld    
  800a36:	eb 1a                	jmp    800a52 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a38:	89 c2                	mov    %eax,%edx
  800a3a:	09 ca                	or     %ecx,%edx
  800a3c:	09 f2                	or     %esi,%edx
  800a3e:	f6 c2 03             	test   $0x3,%dl
  800a41:	75 0a                	jne    800a4d <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a43:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a46:	89 c7                	mov    %eax,%edi
  800a48:	fc                   	cld    
  800a49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4b:	eb 05                	jmp    800a52 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a4d:	89 c7                	mov    %eax,%edi
  800a4f:	fc                   	cld    
  800a50:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a52:	5e                   	pop    %esi
  800a53:	5f                   	pop    %edi
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a56:	f3 0f 1e fb          	endbr32 
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a60:	ff 75 10             	pushl  0x10(%ebp)
  800a63:	ff 75 0c             	pushl  0xc(%ebp)
  800a66:	ff 75 08             	pushl  0x8(%ebp)
  800a69:	e8 82 ff ff ff       	call   8009f0 <memmove>
}
  800a6e:	c9                   	leave  
  800a6f:	c3                   	ret    

00800a70 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a70:	f3 0f 1e fb          	endbr32 
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	56                   	push   %esi
  800a78:	53                   	push   %ebx
  800a79:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7f:	89 c6                	mov    %eax,%esi
  800a81:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a84:	39 f0                	cmp    %esi,%eax
  800a86:	74 1c                	je     800aa4 <memcmp+0x34>
		if (*s1 != *s2)
  800a88:	0f b6 08             	movzbl (%eax),%ecx
  800a8b:	0f b6 1a             	movzbl (%edx),%ebx
  800a8e:	38 d9                	cmp    %bl,%cl
  800a90:	75 08                	jne    800a9a <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a92:	83 c0 01             	add    $0x1,%eax
  800a95:	83 c2 01             	add    $0x1,%edx
  800a98:	eb ea                	jmp    800a84 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a9a:	0f b6 c1             	movzbl %cl,%eax
  800a9d:	0f b6 db             	movzbl %bl,%ebx
  800aa0:	29 d8                	sub    %ebx,%eax
  800aa2:	eb 05                	jmp    800aa9 <memcmp+0x39>
	}

	return 0;
  800aa4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aad:	f3 0f 1e fb          	endbr32 
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aba:	89 c2                	mov    %eax,%edx
  800abc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800abf:	39 d0                	cmp    %edx,%eax
  800ac1:	73 09                	jae    800acc <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac3:	38 08                	cmp    %cl,(%eax)
  800ac5:	74 05                	je     800acc <memfind+0x1f>
	for (; s < ends; s++)
  800ac7:	83 c0 01             	add    $0x1,%eax
  800aca:	eb f3                	jmp    800abf <memfind+0x12>
			break;
	return (void *) s;
}
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    

00800ace <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ace:	f3 0f 1e fb          	endbr32 
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	57                   	push   %edi
  800ad6:	56                   	push   %esi
  800ad7:	53                   	push   %ebx
  800ad8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800adb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ade:	eb 03                	jmp    800ae3 <strtol+0x15>
		s++;
  800ae0:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ae3:	0f b6 01             	movzbl (%ecx),%eax
  800ae6:	3c 20                	cmp    $0x20,%al
  800ae8:	74 f6                	je     800ae0 <strtol+0x12>
  800aea:	3c 09                	cmp    $0x9,%al
  800aec:	74 f2                	je     800ae0 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800aee:	3c 2b                	cmp    $0x2b,%al
  800af0:	74 2a                	je     800b1c <strtol+0x4e>
	int neg = 0;
  800af2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800af7:	3c 2d                	cmp    $0x2d,%al
  800af9:	74 2b                	je     800b26 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800afb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b01:	75 0f                	jne    800b12 <strtol+0x44>
  800b03:	80 39 30             	cmpb   $0x30,(%ecx)
  800b06:	74 28                	je     800b30 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b08:	85 db                	test   %ebx,%ebx
  800b0a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b0f:	0f 44 d8             	cmove  %eax,%ebx
  800b12:	b8 00 00 00 00       	mov    $0x0,%eax
  800b17:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b1a:	eb 46                	jmp    800b62 <strtol+0x94>
		s++;
  800b1c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b1f:	bf 00 00 00 00       	mov    $0x0,%edi
  800b24:	eb d5                	jmp    800afb <strtol+0x2d>
		s++, neg = 1;
  800b26:	83 c1 01             	add    $0x1,%ecx
  800b29:	bf 01 00 00 00       	mov    $0x1,%edi
  800b2e:	eb cb                	jmp    800afb <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b30:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b34:	74 0e                	je     800b44 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b36:	85 db                	test   %ebx,%ebx
  800b38:	75 d8                	jne    800b12 <strtol+0x44>
		s++, base = 8;
  800b3a:	83 c1 01             	add    $0x1,%ecx
  800b3d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b42:	eb ce                	jmp    800b12 <strtol+0x44>
		s += 2, base = 16;
  800b44:	83 c1 02             	add    $0x2,%ecx
  800b47:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b4c:	eb c4                	jmp    800b12 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b4e:	0f be d2             	movsbl %dl,%edx
  800b51:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b54:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b57:	7d 3a                	jge    800b93 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b59:	83 c1 01             	add    $0x1,%ecx
  800b5c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b60:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b62:	0f b6 11             	movzbl (%ecx),%edx
  800b65:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b68:	89 f3                	mov    %esi,%ebx
  800b6a:	80 fb 09             	cmp    $0x9,%bl
  800b6d:	76 df                	jbe    800b4e <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b6f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b72:	89 f3                	mov    %esi,%ebx
  800b74:	80 fb 19             	cmp    $0x19,%bl
  800b77:	77 08                	ja     800b81 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b79:	0f be d2             	movsbl %dl,%edx
  800b7c:	83 ea 57             	sub    $0x57,%edx
  800b7f:	eb d3                	jmp    800b54 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b81:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b84:	89 f3                	mov    %esi,%ebx
  800b86:	80 fb 19             	cmp    $0x19,%bl
  800b89:	77 08                	ja     800b93 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b8b:	0f be d2             	movsbl %dl,%edx
  800b8e:	83 ea 37             	sub    $0x37,%edx
  800b91:	eb c1                	jmp    800b54 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b93:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b97:	74 05                	je     800b9e <strtol+0xd0>
		*endptr = (char *) s;
  800b99:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b9c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b9e:	89 c2                	mov    %eax,%edx
  800ba0:	f7 da                	neg    %edx
  800ba2:	85 ff                	test   %edi,%edi
  800ba4:	0f 45 c2             	cmovne %edx,%eax
}
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bac:	f3 0f 1e fb          	endbr32 
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc1:	89 c3                	mov    %eax,%ebx
  800bc3:	89 c7                	mov    %eax,%edi
  800bc5:	89 c6                	mov    %eax,%esi
  800bc7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_cgetc>:

int
sys_cgetc(void)
{
  800bce:	f3 0f 1e fb          	endbr32 
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdd:	b8 01 00 00 00       	mov    $0x1,%eax
  800be2:	89 d1                	mov    %edx,%ecx
  800be4:	89 d3                	mov    %edx,%ebx
  800be6:	89 d7                	mov    %edx,%edi
  800be8:	89 d6                	mov    %edx,%esi
  800bea:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bf1:	f3 0f 1e fb          	endbr32 
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bfe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c03:	8b 55 08             	mov    0x8(%ebp),%edx
  800c06:	b8 03 00 00 00       	mov    $0x3,%eax
  800c0b:	89 cb                	mov    %ecx,%ebx
  800c0d:	89 cf                	mov    %ecx,%edi
  800c0f:	89 ce                	mov    %ecx,%esi
  800c11:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c13:	85 c0                	test   %eax,%eax
  800c15:	7f 08                	jg     800c1f <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1a:	5b                   	pop    %ebx
  800c1b:	5e                   	pop    %esi
  800c1c:	5f                   	pop    %edi
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1f:	83 ec 0c             	sub    $0xc,%esp
  800c22:	50                   	push   %eax
  800c23:	6a 03                	push   $0x3
  800c25:	68 df 14 80 00       	push   $0x8014df
  800c2a:	6a 23                	push   $0x23
  800c2c:	68 fc 14 80 00       	push   $0x8014fc
  800c31:	e8 14 f5 ff ff       	call   80014a <_panic>

00800c36 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c36:	f3 0f 1e fb          	endbr32 
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c40:	ba 00 00 00 00       	mov    $0x0,%edx
  800c45:	b8 02 00 00 00       	mov    $0x2,%eax
  800c4a:	89 d1                	mov    %edx,%ecx
  800c4c:	89 d3                	mov    %edx,%ebx
  800c4e:	89 d7                	mov    %edx,%edi
  800c50:	89 d6                	mov    %edx,%esi
  800c52:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <sys_yield>:

void
sys_yield(void)
{
  800c59:	f3 0f 1e fb          	endbr32 
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	57                   	push   %edi
  800c61:	56                   	push   %esi
  800c62:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c63:	ba 00 00 00 00       	mov    $0x0,%edx
  800c68:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c6d:	89 d1                	mov    %edx,%ecx
  800c6f:	89 d3                	mov    %edx,%ebx
  800c71:	89 d7                	mov    %edx,%edi
  800c73:	89 d6                	mov    %edx,%esi
  800c75:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c7c:	f3 0f 1e fb          	endbr32 
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
  800c86:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c89:	be 00 00 00 00       	mov    $0x0,%esi
  800c8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c94:	b8 04 00 00 00       	mov    $0x4,%eax
  800c99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9c:	89 f7                	mov    %esi,%edi
  800c9e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca0:	85 c0                	test   %eax,%eax
  800ca2:	7f 08                	jg     800cac <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ca4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	50                   	push   %eax
  800cb0:	6a 04                	push   $0x4
  800cb2:	68 df 14 80 00       	push   $0x8014df
  800cb7:	6a 23                	push   $0x23
  800cb9:	68 fc 14 80 00       	push   $0x8014fc
  800cbe:	e8 87 f4 ff ff       	call   80014a <_panic>

00800cc3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cc3:	f3 0f 1e fb          	endbr32 
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
  800ccd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd6:	b8 05 00 00 00       	mov    $0x5,%eax
  800cdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cde:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce1:	8b 75 18             	mov    0x18(%ebp),%esi
  800ce4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	7f 08                	jg     800cf2 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ced:	5b                   	pop    %ebx
  800cee:	5e                   	pop    %esi
  800cef:	5f                   	pop    %edi
  800cf0:	5d                   	pop    %ebp
  800cf1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf2:	83 ec 0c             	sub    $0xc,%esp
  800cf5:	50                   	push   %eax
  800cf6:	6a 05                	push   $0x5
  800cf8:	68 df 14 80 00       	push   $0x8014df
  800cfd:	6a 23                	push   $0x23
  800cff:	68 fc 14 80 00       	push   $0x8014fc
  800d04:	e8 41 f4 ff ff       	call   80014a <_panic>

00800d09 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d09:	f3 0f 1e fb          	endbr32 
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d21:	b8 06 00 00 00       	mov    $0x6,%eax
  800d26:	89 df                	mov    %ebx,%edi
  800d28:	89 de                	mov    %ebx,%esi
  800d2a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	7f 08                	jg     800d38 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d38:	83 ec 0c             	sub    $0xc,%esp
  800d3b:	50                   	push   %eax
  800d3c:	6a 06                	push   $0x6
  800d3e:	68 df 14 80 00       	push   $0x8014df
  800d43:	6a 23                	push   $0x23
  800d45:	68 fc 14 80 00       	push   $0x8014fc
  800d4a:	e8 fb f3 ff ff       	call   80014a <_panic>

00800d4f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d4f:	f3 0f 1e fb          	endbr32 
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
  800d59:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d67:	b8 08 00 00 00       	mov    $0x8,%eax
  800d6c:	89 df                	mov    %ebx,%edi
  800d6e:	89 de                	mov    %ebx,%esi
  800d70:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d72:	85 c0                	test   %eax,%eax
  800d74:	7f 08                	jg     800d7e <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7e:	83 ec 0c             	sub    $0xc,%esp
  800d81:	50                   	push   %eax
  800d82:	6a 08                	push   $0x8
  800d84:	68 df 14 80 00       	push   $0x8014df
  800d89:	6a 23                	push   $0x23
  800d8b:	68 fc 14 80 00       	push   $0x8014fc
  800d90:	e8 b5 f3 ff ff       	call   80014a <_panic>

00800d95 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d95:	f3 0f 1e fb          	endbr32 
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	57                   	push   %edi
  800d9d:	56                   	push   %esi
  800d9e:	53                   	push   %ebx
  800d9f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da7:	8b 55 08             	mov    0x8(%ebp),%edx
  800daa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dad:	b8 09 00 00 00       	mov    $0x9,%eax
  800db2:	89 df                	mov    %ebx,%edi
  800db4:	89 de                	mov    %ebx,%esi
  800db6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800db8:	85 c0                	test   %eax,%eax
  800dba:	7f 08                	jg     800dc4 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc4:	83 ec 0c             	sub    $0xc,%esp
  800dc7:	50                   	push   %eax
  800dc8:	6a 09                	push   $0x9
  800dca:	68 df 14 80 00       	push   $0x8014df
  800dcf:	6a 23                	push   $0x23
  800dd1:	68 fc 14 80 00       	push   $0x8014fc
  800dd6:	e8 6f f3 ff ff       	call   80014a <_panic>

00800ddb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ddb:	f3 0f 1e fb          	endbr32 
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	57                   	push   %edi
  800de3:	56                   	push   %esi
  800de4:	53                   	push   %ebx
  800de5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800de8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ded:	8b 55 08             	mov    0x8(%ebp),%edx
  800df0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df8:	89 df                	mov    %ebx,%edi
  800dfa:	89 de                	mov    %ebx,%esi
  800dfc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dfe:	85 c0                	test   %eax,%eax
  800e00:	7f 08                	jg     800e0a <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0a:	83 ec 0c             	sub    $0xc,%esp
  800e0d:	50                   	push   %eax
  800e0e:	6a 0a                	push   $0xa
  800e10:	68 df 14 80 00       	push   $0x8014df
  800e15:	6a 23                	push   $0x23
  800e17:	68 fc 14 80 00       	push   $0x8014fc
  800e1c:	e8 29 f3 ff ff       	call   80014a <_panic>

00800e21 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e21:	f3 0f 1e fb          	endbr32 
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e31:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e36:	be 00 00 00 00       	mov    $0x0,%esi
  800e3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e41:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e48:	f3 0f 1e fb          	endbr32 
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	57                   	push   %edi
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e57:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5f:	89 cb                	mov    %ecx,%ebx
  800e61:	89 cf                	mov    %ecx,%edi
  800e63:	89 ce                	mov    %ecx,%esi
  800e65:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 0, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e67:	5b                   	pop    %ebx
  800e68:	5e                   	pop    %esi
  800e69:	5f                   	pop    %edi
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    
  800e6c:	66 90                	xchg   %ax,%ax
  800e6e:	66 90                	xchg   %ax,%ax

00800e70 <__udivdi3>:
  800e70:	f3 0f 1e fb          	endbr32 
  800e74:	55                   	push   %ebp
  800e75:	57                   	push   %edi
  800e76:	56                   	push   %esi
  800e77:	53                   	push   %ebx
  800e78:	83 ec 1c             	sub    $0x1c,%esp
  800e7b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e7f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e83:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e87:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e8b:	85 d2                	test   %edx,%edx
  800e8d:	75 19                	jne    800ea8 <__udivdi3+0x38>
  800e8f:	39 f3                	cmp    %esi,%ebx
  800e91:	76 4d                	jbe    800ee0 <__udivdi3+0x70>
  800e93:	31 ff                	xor    %edi,%edi
  800e95:	89 e8                	mov    %ebp,%eax
  800e97:	89 f2                	mov    %esi,%edx
  800e99:	f7 f3                	div    %ebx
  800e9b:	89 fa                	mov    %edi,%edx
  800e9d:	83 c4 1c             	add    $0x1c,%esp
  800ea0:	5b                   	pop    %ebx
  800ea1:	5e                   	pop    %esi
  800ea2:	5f                   	pop    %edi
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    
  800ea5:	8d 76 00             	lea    0x0(%esi),%esi
  800ea8:	39 f2                	cmp    %esi,%edx
  800eaa:	76 14                	jbe    800ec0 <__udivdi3+0x50>
  800eac:	31 ff                	xor    %edi,%edi
  800eae:	31 c0                	xor    %eax,%eax
  800eb0:	89 fa                	mov    %edi,%edx
  800eb2:	83 c4 1c             	add    $0x1c,%esp
  800eb5:	5b                   	pop    %ebx
  800eb6:	5e                   	pop    %esi
  800eb7:	5f                   	pop    %edi
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    
  800eba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ec0:	0f bd fa             	bsr    %edx,%edi
  800ec3:	83 f7 1f             	xor    $0x1f,%edi
  800ec6:	75 48                	jne    800f10 <__udivdi3+0xa0>
  800ec8:	39 f2                	cmp    %esi,%edx
  800eca:	72 06                	jb     800ed2 <__udivdi3+0x62>
  800ecc:	31 c0                	xor    %eax,%eax
  800ece:	39 eb                	cmp    %ebp,%ebx
  800ed0:	77 de                	ja     800eb0 <__udivdi3+0x40>
  800ed2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ed7:	eb d7                	jmp    800eb0 <__udivdi3+0x40>
  800ed9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ee0:	89 d9                	mov    %ebx,%ecx
  800ee2:	85 db                	test   %ebx,%ebx
  800ee4:	75 0b                	jne    800ef1 <__udivdi3+0x81>
  800ee6:	b8 01 00 00 00       	mov    $0x1,%eax
  800eeb:	31 d2                	xor    %edx,%edx
  800eed:	f7 f3                	div    %ebx
  800eef:	89 c1                	mov    %eax,%ecx
  800ef1:	31 d2                	xor    %edx,%edx
  800ef3:	89 f0                	mov    %esi,%eax
  800ef5:	f7 f1                	div    %ecx
  800ef7:	89 c6                	mov    %eax,%esi
  800ef9:	89 e8                	mov    %ebp,%eax
  800efb:	89 f7                	mov    %esi,%edi
  800efd:	f7 f1                	div    %ecx
  800eff:	89 fa                	mov    %edi,%edx
  800f01:	83 c4 1c             	add    $0x1c,%esp
  800f04:	5b                   	pop    %ebx
  800f05:	5e                   	pop    %esi
  800f06:	5f                   	pop    %edi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    
  800f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f10:	89 f9                	mov    %edi,%ecx
  800f12:	b8 20 00 00 00       	mov    $0x20,%eax
  800f17:	29 f8                	sub    %edi,%eax
  800f19:	d3 e2                	shl    %cl,%edx
  800f1b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f1f:	89 c1                	mov    %eax,%ecx
  800f21:	89 da                	mov    %ebx,%edx
  800f23:	d3 ea                	shr    %cl,%edx
  800f25:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f29:	09 d1                	or     %edx,%ecx
  800f2b:	89 f2                	mov    %esi,%edx
  800f2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f31:	89 f9                	mov    %edi,%ecx
  800f33:	d3 e3                	shl    %cl,%ebx
  800f35:	89 c1                	mov    %eax,%ecx
  800f37:	d3 ea                	shr    %cl,%edx
  800f39:	89 f9                	mov    %edi,%ecx
  800f3b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f3f:	89 eb                	mov    %ebp,%ebx
  800f41:	d3 e6                	shl    %cl,%esi
  800f43:	89 c1                	mov    %eax,%ecx
  800f45:	d3 eb                	shr    %cl,%ebx
  800f47:	09 de                	or     %ebx,%esi
  800f49:	89 f0                	mov    %esi,%eax
  800f4b:	f7 74 24 08          	divl   0x8(%esp)
  800f4f:	89 d6                	mov    %edx,%esi
  800f51:	89 c3                	mov    %eax,%ebx
  800f53:	f7 64 24 0c          	mull   0xc(%esp)
  800f57:	39 d6                	cmp    %edx,%esi
  800f59:	72 15                	jb     800f70 <__udivdi3+0x100>
  800f5b:	89 f9                	mov    %edi,%ecx
  800f5d:	d3 e5                	shl    %cl,%ebp
  800f5f:	39 c5                	cmp    %eax,%ebp
  800f61:	73 04                	jae    800f67 <__udivdi3+0xf7>
  800f63:	39 d6                	cmp    %edx,%esi
  800f65:	74 09                	je     800f70 <__udivdi3+0x100>
  800f67:	89 d8                	mov    %ebx,%eax
  800f69:	31 ff                	xor    %edi,%edi
  800f6b:	e9 40 ff ff ff       	jmp    800eb0 <__udivdi3+0x40>
  800f70:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f73:	31 ff                	xor    %edi,%edi
  800f75:	e9 36 ff ff ff       	jmp    800eb0 <__udivdi3+0x40>
  800f7a:	66 90                	xchg   %ax,%ax
  800f7c:	66 90                	xchg   %ax,%ax
  800f7e:	66 90                	xchg   %ax,%ax

00800f80 <__umoddi3>:
  800f80:	f3 0f 1e fb          	endbr32 
  800f84:	55                   	push   %ebp
  800f85:	57                   	push   %edi
  800f86:	56                   	push   %esi
  800f87:	53                   	push   %ebx
  800f88:	83 ec 1c             	sub    $0x1c,%esp
  800f8b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f8f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f93:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f97:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	75 19                	jne    800fb8 <__umoddi3+0x38>
  800f9f:	39 df                	cmp    %ebx,%edi
  800fa1:	76 5d                	jbe    801000 <__umoddi3+0x80>
  800fa3:	89 f0                	mov    %esi,%eax
  800fa5:	89 da                	mov    %ebx,%edx
  800fa7:	f7 f7                	div    %edi
  800fa9:	89 d0                	mov    %edx,%eax
  800fab:	31 d2                	xor    %edx,%edx
  800fad:	83 c4 1c             	add    $0x1c,%esp
  800fb0:	5b                   	pop    %ebx
  800fb1:	5e                   	pop    %esi
  800fb2:	5f                   	pop    %edi
  800fb3:	5d                   	pop    %ebp
  800fb4:	c3                   	ret    
  800fb5:	8d 76 00             	lea    0x0(%esi),%esi
  800fb8:	89 f2                	mov    %esi,%edx
  800fba:	39 d8                	cmp    %ebx,%eax
  800fbc:	76 12                	jbe    800fd0 <__umoddi3+0x50>
  800fbe:	89 f0                	mov    %esi,%eax
  800fc0:	89 da                	mov    %ebx,%edx
  800fc2:	83 c4 1c             	add    $0x1c,%esp
  800fc5:	5b                   	pop    %ebx
  800fc6:	5e                   	pop    %esi
  800fc7:	5f                   	pop    %edi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    
  800fca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fd0:	0f bd e8             	bsr    %eax,%ebp
  800fd3:	83 f5 1f             	xor    $0x1f,%ebp
  800fd6:	75 50                	jne    801028 <__umoddi3+0xa8>
  800fd8:	39 d8                	cmp    %ebx,%eax
  800fda:	0f 82 e0 00 00 00    	jb     8010c0 <__umoddi3+0x140>
  800fe0:	89 d9                	mov    %ebx,%ecx
  800fe2:	39 f7                	cmp    %esi,%edi
  800fe4:	0f 86 d6 00 00 00    	jbe    8010c0 <__umoddi3+0x140>
  800fea:	89 d0                	mov    %edx,%eax
  800fec:	89 ca                	mov    %ecx,%edx
  800fee:	83 c4 1c             	add    $0x1c,%esp
  800ff1:	5b                   	pop    %ebx
  800ff2:	5e                   	pop    %esi
  800ff3:	5f                   	pop    %edi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    
  800ff6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ffd:	8d 76 00             	lea    0x0(%esi),%esi
  801000:	89 fd                	mov    %edi,%ebp
  801002:	85 ff                	test   %edi,%edi
  801004:	75 0b                	jne    801011 <__umoddi3+0x91>
  801006:	b8 01 00 00 00       	mov    $0x1,%eax
  80100b:	31 d2                	xor    %edx,%edx
  80100d:	f7 f7                	div    %edi
  80100f:	89 c5                	mov    %eax,%ebp
  801011:	89 d8                	mov    %ebx,%eax
  801013:	31 d2                	xor    %edx,%edx
  801015:	f7 f5                	div    %ebp
  801017:	89 f0                	mov    %esi,%eax
  801019:	f7 f5                	div    %ebp
  80101b:	89 d0                	mov    %edx,%eax
  80101d:	31 d2                	xor    %edx,%edx
  80101f:	eb 8c                	jmp    800fad <__umoddi3+0x2d>
  801021:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801028:	89 e9                	mov    %ebp,%ecx
  80102a:	ba 20 00 00 00       	mov    $0x20,%edx
  80102f:	29 ea                	sub    %ebp,%edx
  801031:	d3 e0                	shl    %cl,%eax
  801033:	89 44 24 08          	mov    %eax,0x8(%esp)
  801037:	89 d1                	mov    %edx,%ecx
  801039:	89 f8                	mov    %edi,%eax
  80103b:	d3 e8                	shr    %cl,%eax
  80103d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801041:	89 54 24 04          	mov    %edx,0x4(%esp)
  801045:	8b 54 24 04          	mov    0x4(%esp),%edx
  801049:	09 c1                	or     %eax,%ecx
  80104b:	89 d8                	mov    %ebx,%eax
  80104d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801051:	89 e9                	mov    %ebp,%ecx
  801053:	d3 e7                	shl    %cl,%edi
  801055:	89 d1                	mov    %edx,%ecx
  801057:	d3 e8                	shr    %cl,%eax
  801059:	89 e9                	mov    %ebp,%ecx
  80105b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80105f:	d3 e3                	shl    %cl,%ebx
  801061:	89 c7                	mov    %eax,%edi
  801063:	89 d1                	mov    %edx,%ecx
  801065:	89 f0                	mov    %esi,%eax
  801067:	d3 e8                	shr    %cl,%eax
  801069:	89 e9                	mov    %ebp,%ecx
  80106b:	89 fa                	mov    %edi,%edx
  80106d:	d3 e6                	shl    %cl,%esi
  80106f:	09 d8                	or     %ebx,%eax
  801071:	f7 74 24 08          	divl   0x8(%esp)
  801075:	89 d1                	mov    %edx,%ecx
  801077:	89 f3                	mov    %esi,%ebx
  801079:	f7 64 24 0c          	mull   0xc(%esp)
  80107d:	89 c6                	mov    %eax,%esi
  80107f:	89 d7                	mov    %edx,%edi
  801081:	39 d1                	cmp    %edx,%ecx
  801083:	72 06                	jb     80108b <__umoddi3+0x10b>
  801085:	75 10                	jne    801097 <__umoddi3+0x117>
  801087:	39 c3                	cmp    %eax,%ebx
  801089:	73 0c                	jae    801097 <__umoddi3+0x117>
  80108b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80108f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801093:	89 d7                	mov    %edx,%edi
  801095:	89 c6                	mov    %eax,%esi
  801097:	89 ca                	mov    %ecx,%edx
  801099:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80109e:	29 f3                	sub    %esi,%ebx
  8010a0:	19 fa                	sbb    %edi,%edx
  8010a2:	89 d0                	mov    %edx,%eax
  8010a4:	d3 e0                	shl    %cl,%eax
  8010a6:	89 e9                	mov    %ebp,%ecx
  8010a8:	d3 eb                	shr    %cl,%ebx
  8010aa:	d3 ea                	shr    %cl,%edx
  8010ac:	09 d8                	or     %ebx,%eax
  8010ae:	83 c4 1c             	add    $0x1c,%esp
  8010b1:	5b                   	pop    %ebx
  8010b2:	5e                   	pop    %esi
  8010b3:	5f                   	pop    %edi
  8010b4:	5d                   	pop    %ebp
  8010b5:	c3                   	ret    
  8010b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010bd:	8d 76 00             	lea    0x0(%esi),%esi
  8010c0:	29 fe                	sub    %edi,%esi
  8010c2:	19 c3                	sbb    %eax,%ebx
  8010c4:	89 f2                	mov    %esi,%edx
  8010c6:	89 d9                	mov    %ebx,%ecx
  8010c8:	e9 1d ff ff ff       	jmp    800fea <__umoddi3+0x6a>
