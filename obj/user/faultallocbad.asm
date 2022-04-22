
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 8c 00 00 00       	call   8000bd <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	53                   	push   %ebx
  80003b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003e:	8b 45 08             	mov    0x8(%ebp),%eax
  800041:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800043:	53                   	push   %ebx
  800044:	68 80 11 80 00       	push   $0x801180
  800049:	e8 c0 01 00 00       	call   80020e <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004e:	83 c4 0c             	add    $0xc,%esp
  800051:	6a 07                	push   $0x7
  800053:	89 d8                	mov    %ebx,%eax
  800055:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005a:	50                   	push   %eax
  80005b:	6a 00                	push   $0x0
  80005d:	e8 f7 0b 00 00       	call   800c59 <sys_page_alloc>
  800062:	83 c4 10             	add    $0x10,%esp
  800065:	85 c0                	test   %eax,%eax
  800067:	78 16                	js     80007f <handler+0x4c>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800069:	53                   	push   %ebx
  80006a:	68 cc 11 80 00       	push   $0x8011cc
  80006f:	6a 64                	push   $0x64
  800071:	53                   	push   %ebx
  800072:	e8 3f 07 00 00       	call   8007b6 <snprintf>
}
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007d:	c9                   	leave  
  80007e:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007f:	83 ec 0c             	sub    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	53                   	push   %ebx
  800084:	68 a0 11 80 00       	push   $0x8011a0
  800089:	6a 0f                	push   $0xf
  80008b:	68 8a 11 80 00       	push   $0x80118a
  800090:	e8 92 00 00 00       	call   800127 <_panic>

00800095 <umain>:

void
umain(int argc, char **argv)
{
  800095:	f3 0f 1e fb          	endbr32 
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  80009f:	68 33 00 80 00       	push   $0x800033
  8000a4:	e8 c1 0d 00 00       	call   800e6a <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a9:	83 c4 08             	add    $0x8,%esp
  8000ac:	6a 04                	push   $0x4
  8000ae:	68 ef be ad de       	push   $0xdeadbeef
  8000b3:	e8 d1 0a 00 00       	call   800b89 <sys_cputs>
}
  8000b8:	83 c4 10             	add    $0x10,%esp
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000bd:	f3 0f 1e fb          	endbr32 
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
  8000c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000cc:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000d3:	00 00 00 
    envid_t envid = sys_getenvid();
  8000d6:	e8 38 0b 00 00       	call   800c13 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8000db:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e8:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ed:	85 db                	test   %ebx,%ebx
  8000ef:	7e 07                	jle    8000f8 <libmain+0x3b>
		binaryname = argv[0];
  8000f1:	8b 06                	mov    (%esi),%eax
  8000f3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f8:	83 ec 08             	sub    $0x8,%esp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	e8 93 ff ff ff       	call   800095 <umain>

	// exit gracefully
	exit();
  800102:	e8 0a 00 00 00       	call   800111 <exit>
}
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010d:	5b                   	pop    %ebx
  80010e:	5e                   	pop    %esi
  80010f:	5d                   	pop    %ebp
  800110:	c3                   	ret    

00800111 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800111:	f3 0f 1e fb          	endbr32 
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  80011b:	6a 00                	push   $0x0
  80011d:	e8 ac 0a 00 00       	call   800bce <sys_env_destroy>
}
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	c9                   	leave  
  800126:	c3                   	ret    

00800127 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800127:	f3 0f 1e fb          	endbr32 
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800130:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800133:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800139:	e8 d5 0a 00 00       	call   800c13 <sys_getenvid>
  80013e:	83 ec 0c             	sub    $0xc,%esp
  800141:	ff 75 0c             	pushl  0xc(%ebp)
  800144:	ff 75 08             	pushl  0x8(%ebp)
  800147:	56                   	push   %esi
  800148:	50                   	push   %eax
  800149:	68 f8 11 80 00       	push   $0x8011f8
  80014e:	e8 bb 00 00 00       	call   80020e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800153:	83 c4 18             	add    $0x18,%esp
  800156:	53                   	push   %ebx
  800157:	ff 75 10             	pushl  0x10(%ebp)
  80015a:	e8 5a 00 00 00       	call   8001b9 <vcprintf>
	cprintf("\n");
  80015f:	c7 04 24 57 15 80 00 	movl   $0x801557,(%esp)
  800166:	e8 a3 00 00 00       	call   80020e <cprintf>
  80016b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016e:	cc                   	int3   
  80016f:	eb fd                	jmp    80016e <_panic+0x47>

00800171 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800171:	f3 0f 1e fb          	endbr32 
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	53                   	push   %ebx
  800179:	83 ec 04             	sub    $0x4,%esp
  80017c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017f:	8b 13                	mov    (%ebx),%edx
  800181:	8d 42 01             	lea    0x1(%edx),%eax
  800184:	89 03                	mov    %eax,(%ebx)
  800186:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800189:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80018d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800192:	74 09                	je     80019d <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800194:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80019d:	83 ec 08             	sub    $0x8,%esp
  8001a0:	68 ff 00 00 00       	push   $0xff
  8001a5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a8:	50                   	push   %eax
  8001a9:	e8 db 09 00 00       	call   800b89 <sys_cputs>
		b->idx = 0;
  8001ae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	eb db                	jmp    800194 <putch+0x23>

008001b9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b9:	f3 0f 1e fb          	endbr32 
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cd:	00 00 00 
	b.cnt = 0;
  8001d0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001da:	ff 75 0c             	pushl  0xc(%ebp)
  8001dd:	ff 75 08             	pushl  0x8(%ebp)
  8001e0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e6:	50                   	push   %eax
  8001e7:	68 71 01 80 00       	push   $0x800171
  8001ec:	e8 20 01 00 00       	call   800311 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f1:	83 c4 08             	add    $0x8,%esp
  8001f4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001fa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800200:	50                   	push   %eax
  800201:	e8 83 09 00 00       	call   800b89 <sys_cputs>

	return b.cnt;
}
  800206:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020c:	c9                   	leave  
  80020d:	c3                   	ret    

0080020e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020e:	f3 0f 1e fb          	endbr32 
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800218:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021b:	50                   	push   %eax
  80021c:	ff 75 08             	pushl  0x8(%ebp)
  80021f:	e8 95 ff ff ff       	call   8001b9 <vcprintf>
	va_end(ap);

	return cnt;
}
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	57                   	push   %edi
  80022a:	56                   	push   %esi
  80022b:	53                   	push   %ebx
  80022c:	83 ec 1c             	sub    $0x1c,%esp
  80022f:	89 c7                	mov    %eax,%edi
  800231:	89 d6                	mov    %edx,%esi
  800233:	8b 45 08             	mov    0x8(%ebp),%eax
  800236:	8b 55 0c             	mov    0xc(%ebp),%edx
  800239:	89 d1                	mov    %edx,%ecx
  80023b:	89 c2                	mov    %eax,%edx
  80023d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800240:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800243:	8b 45 10             	mov    0x10(%ebp),%eax
  800246:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800249:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80024c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800253:	39 c2                	cmp    %eax,%edx
  800255:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800258:	72 3e                	jb     800298 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	ff 75 18             	pushl  0x18(%ebp)
  800260:	83 eb 01             	sub    $0x1,%ebx
  800263:	53                   	push   %ebx
  800264:	50                   	push   %eax
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026b:	ff 75 e0             	pushl  -0x20(%ebp)
  80026e:	ff 75 dc             	pushl  -0x24(%ebp)
  800271:	ff 75 d8             	pushl  -0x28(%ebp)
  800274:	e8 97 0c 00 00       	call   800f10 <__udivdi3>
  800279:	83 c4 18             	add    $0x18,%esp
  80027c:	52                   	push   %edx
  80027d:	50                   	push   %eax
  80027e:	89 f2                	mov    %esi,%edx
  800280:	89 f8                	mov    %edi,%eax
  800282:	e8 9f ff ff ff       	call   800226 <printnum>
  800287:	83 c4 20             	add    $0x20,%esp
  80028a:	eb 13                	jmp    80029f <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028c:	83 ec 08             	sub    $0x8,%esp
  80028f:	56                   	push   %esi
  800290:	ff 75 18             	pushl  0x18(%ebp)
  800293:	ff d7                	call   *%edi
  800295:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800298:	83 eb 01             	sub    $0x1,%ebx
  80029b:	85 db                	test   %ebx,%ebx
  80029d:	7f ed                	jg     80028c <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029f:	83 ec 08             	sub    $0x8,%esp
  8002a2:	56                   	push   %esi
  8002a3:	83 ec 04             	sub    $0x4,%esp
  8002a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ac:	ff 75 dc             	pushl  -0x24(%ebp)
  8002af:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b2:	e8 69 0d 00 00       	call   801020 <__umoddi3>
  8002b7:	83 c4 14             	add    $0x14,%esp
  8002ba:	0f be 80 1b 12 80 00 	movsbl 0x80121b(%eax),%eax
  8002c1:	50                   	push   %eax
  8002c2:	ff d7                	call   *%edi
}
  8002c4:	83 c4 10             	add    $0x10,%esp
  8002c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ca:	5b                   	pop    %ebx
  8002cb:	5e                   	pop    %esi
  8002cc:	5f                   	pop    %edi
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cf:	f3 0f 1e fb          	endbr32 
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
  8002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e2:	73 0a                	jae    8002ee <sprintputch+0x1f>
		*b->buf++ = ch;
  8002e4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e7:	89 08                	mov    %ecx,(%eax)
  8002e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ec:	88 02                	mov    %al,(%edx)
}
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <printfmt>:
{
  8002f0:	f3 0f 1e fb          	endbr32 
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002fa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fd:	50                   	push   %eax
  8002fe:	ff 75 10             	pushl  0x10(%ebp)
  800301:	ff 75 0c             	pushl  0xc(%ebp)
  800304:	ff 75 08             	pushl  0x8(%ebp)
  800307:	e8 05 00 00 00       	call   800311 <vprintfmt>
}
  80030c:	83 c4 10             	add    $0x10,%esp
  80030f:	c9                   	leave  
  800310:	c3                   	ret    

00800311 <vprintfmt>:
{
  800311:	f3 0f 1e fb          	endbr32 
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	57                   	push   %edi
  800319:	56                   	push   %esi
  80031a:	53                   	push   %ebx
  80031b:	83 ec 3c             	sub    $0x3c,%esp
  80031e:	8b 75 08             	mov    0x8(%ebp),%esi
  800321:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800324:	8b 7d 10             	mov    0x10(%ebp),%edi
  800327:	e9 4a 03 00 00       	jmp    800676 <vprintfmt+0x365>
		padc = ' ';
  80032c:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800330:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800337:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80033e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800345:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	8d 47 01             	lea    0x1(%edi),%eax
  80034d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800350:	0f b6 17             	movzbl (%edi),%edx
  800353:	8d 42 dd             	lea    -0x23(%edx),%eax
  800356:	3c 55                	cmp    $0x55,%al
  800358:	0f 87 de 03 00 00    	ja     80073c <vprintfmt+0x42b>
  80035e:	0f b6 c0             	movzbl %al,%eax
  800361:	3e ff 24 85 60 13 80 	notrack jmp *0x801360(,%eax,4)
  800368:	00 
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80036c:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800370:	eb d8                	jmp    80034a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800375:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800379:	eb cf                	jmp    80034a <vprintfmt+0x39>
  80037b:	0f b6 d2             	movzbl %dl,%edx
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800381:	b8 00 00 00 00       	mov    $0x0,%eax
  800386:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800389:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80038c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800390:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800393:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800396:	83 f9 09             	cmp    $0x9,%ecx
  800399:	77 55                	ja     8003f0 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80039b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80039e:	eb e9                	jmp    800389 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a3:	8b 00                	mov    (%eax),%eax
  8003a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ab:	8d 40 04             	lea    0x4(%eax),%eax
  8003ae:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003b4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b8:	79 90                	jns    80034a <vprintfmt+0x39>
				width = precision, precision = -1;
  8003ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003c7:	eb 81                	jmp    80034a <vprintfmt+0x39>
  8003c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003cc:	85 c0                	test   %eax,%eax
  8003ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d3:	0f 49 d0             	cmovns %eax,%edx
  8003d6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003dc:	e9 69 ff ff ff       	jmp    80034a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003e4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003eb:	e9 5a ff ff ff       	jmp    80034a <vprintfmt+0x39>
  8003f0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f6:	eb bc                	jmp    8003b4 <vprintfmt+0xa3>
			lflag++;
  8003f8:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003fe:	e9 47 ff ff ff       	jmp    80034a <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800403:	8b 45 14             	mov    0x14(%ebp),%eax
  800406:	8d 78 04             	lea    0x4(%eax),%edi
  800409:	83 ec 08             	sub    $0x8,%esp
  80040c:	53                   	push   %ebx
  80040d:	ff 30                	pushl  (%eax)
  80040f:	ff d6                	call   *%esi
			break;
  800411:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800414:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800417:	e9 57 02 00 00       	jmp    800673 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	8d 78 04             	lea    0x4(%eax),%edi
  800422:	8b 00                	mov    (%eax),%eax
  800424:	99                   	cltd   
  800425:	31 d0                	xor    %edx,%eax
  800427:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800429:	83 f8 0f             	cmp    $0xf,%eax
  80042c:	7f 23                	jg     800451 <vprintfmt+0x140>
  80042e:	8b 14 85 c0 14 80 00 	mov    0x8014c0(,%eax,4),%edx
  800435:	85 d2                	test   %edx,%edx
  800437:	74 18                	je     800451 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800439:	52                   	push   %edx
  80043a:	68 3c 12 80 00       	push   $0x80123c
  80043f:	53                   	push   %ebx
  800440:	56                   	push   %esi
  800441:	e8 aa fe ff ff       	call   8002f0 <printfmt>
  800446:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800449:	89 7d 14             	mov    %edi,0x14(%ebp)
  80044c:	e9 22 02 00 00       	jmp    800673 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800451:	50                   	push   %eax
  800452:	68 33 12 80 00       	push   $0x801233
  800457:	53                   	push   %ebx
  800458:	56                   	push   %esi
  800459:	e8 92 fe ff ff       	call   8002f0 <printfmt>
  80045e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800461:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800464:	e9 0a 02 00 00       	jmp    800673 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800469:	8b 45 14             	mov    0x14(%ebp),%eax
  80046c:	83 c0 04             	add    $0x4,%eax
  80046f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800472:	8b 45 14             	mov    0x14(%ebp),%eax
  800475:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800477:	85 d2                	test   %edx,%edx
  800479:	b8 2c 12 80 00       	mov    $0x80122c,%eax
  80047e:	0f 45 c2             	cmovne %edx,%eax
  800481:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800484:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800488:	7e 06                	jle    800490 <vprintfmt+0x17f>
  80048a:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80048e:	75 0d                	jne    80049d <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800490:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800493:	89 c7                	mov    %eax,%edi
  800495:	03 45 e0             	add    -0x20(%ebp),%eax
  800498:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049b:	eb 55                	jmp    8004f2 <vprintfmt+0x1e1>
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a3:	ff 75 cc             	pushl  -0x34(%ebp)
  8004a6:	e8 45 03 00 00       	call   8007f0 <strnlen>
  8004ab:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004ae:	29 c2                	sub    %eax,%edx
  8004b0:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004b8:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bf:	85 ff                	test   %edi,%edi
  8004c1:	7e 11                	jle    8004d4 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	53                   	push   %ebx
  8004c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ca:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cc:	83 ef 01             	sub    $0x1,%edi
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	eb eb                	jmp    8004bf <vprintfmt+0x1ae>
  8004d4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004d7:	85 d2                	test   %edx,%edx
  8004d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004de:	0f 49 c2             	cmovns %edx,%eax
  8004e1:	29 c2                	sub    %eax,%edx
  8004e3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004e6:	eb a8                	jmp    800490 <vprintfmt+0x17f>
					putch(ch, putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	53                   	push   %ebx
  8004ec:	52                   	push   %edx
  8004ed:	ff d6                	call   *%esi
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f5:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f7:	83 c7 01             	add    $0x1,%edi
  8004fa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004fe:	0f be d0             	movsbl %al,%edx
  800501:	85 d2                	test   %edx,%edx
  800503:	74 4b                	je     800550 <vprintfmt+0x23f>
  800505:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800509:	78 06                	js     800511 <vprintfmt+0x200>
  80050b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80050f:	78 1e                	js     80052f <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800511:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800515:	74 d1                	je     8004e8 <vprintfmt+0x1d7>
  800517:	0f be c0             	movsbl %al,%eax
  80051a:	83 e8 20             	sub    $0x20,%eax
  80051d:	83 f8 5e             	cmp    $0x5e,%eax
  800520:	76 c6                	jbe    8004e8 <vprintfmt+0x1d7>
					putch('?', putdat);
  800522:	83 ec 08             	sub    $0x8,%esp
  800525:	53                   	push   %ebx
  800526:	6a 3f                	push   $0x3f
  800528:	ff d6                	call   *%esi
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	eb c3                	jmp    8004f2 <vprintfmt+0x1e1>
  80052f:	89 cf                	mov    %ecx,%edi
  800531:	eb 0e                	jmp    800541 <vprintfmt+0x230>
				putch(' ', putdat);
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	53                   	push   %ebx
  800537:	6a 20                	push   $0x20
  800539:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80053b:	83 ef 01             	sub    $0x1,%edi
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	85 ff                	test   %edi,%edi
  800543:	7f ee                	jg     800533 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800545:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800548:	89 45 14             	mov    %eax,0x14(%ebp)
  80054b:	e9 23 01 00 00       	jmp    800673 <vprintfmt+0x362>
  800550:	89 cf                	mov    %ecx,%edi
  800552:	eb ed                	jmp    800541 <vprintfmt+0x230>
	if (lflag >= 2)
  800554:	83 f9 01             	cmp    $0x1,%ecx
  800557:	7f 1b                	jg     800574 <vprintfmt+0x263>
	else if (lflag)
  800559:	85 c9                	test   %ecx,%ecx
  80055b:	74 63                	je     8005c0 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	99                   	cltd   
  800566:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8d 40 04             	lea    0x4(%eax),%eax
  80056f:	89 45 14             	mov    %eax,0x14(%ebp)
  800572:	eb 17                	jmp    80058b <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8b 50 04             	mov    0x4(%eax),%edx
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8d 40 08             	lea    0x8(%eax),%eax
  800588:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80058b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80058e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800591:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800596:	85 c9                	test   %ecx,%ecx
  800598:	0f 89 bb 00 00 00    	jns    800659 <vprintfmt+0x348>
				putch('-', putdat);
  80059e:	83 ec 08             	sub    $0x8,%esp
  8005a1:	53                   	push   %ebx
  8005a2:	6a 2d                	push   $0x2d
  8005a4:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ac:	f7 da                	neg    %edx
  8005ae:	83 d1 00             	adc    $0x0,%ecx
  8005b1:	f7 d9                	neg    %ecx
  8005b3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005b6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bb:	e9 99 00 00 00       	jmp    800659 <vprintfmt+0x348>
		return va_arg(*ap, int);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8b 00                	mov    (%eax),%eax
  8005c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c8:	99                   	cltd   
  8005c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 40 04             	lea    0x4(%eax),%eax
  8005d2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d5:	eb b4                	jmp    80058b <vprintfmt+0x27a>
	if (lflag >= 2)
  8005d7:	83 f9 01             	cmp    $0x1,%ecx
  8005da:	7f 1b                	jg     8005f7 <vprintfmt+0x2e6>
	else if (lflag)
  8005dc:	85 c9                	test   %ecx,%ecx
  8005de:	74 2c                	je     80060c <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8b 10                	mov    (%eax),%edx
  8005e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ea:	8d 40 04             	lea    0x4(%eax),%eax
  8005ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f0:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005f5:	eb 62                	jmp    800659 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8b 10                	mov    (%eax),%edx
  8005fc:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ff:	8d 40 08             	lea    0x8(%eax),%eax
  800602:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800605:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80060a:	eb 4d                	jmp    800659 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8b 10                	mov    (%eax),%edx
  800611:	b9 00 00 00 00       	mov    $0x0,%ecx
  800616:	8d 40 04             	lea    0x4(%eax),%eax
  800619:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80061c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800621:	eb 36                	jmp    800659 <vprintfmt+0x348>
	if (lflag >= 2)
  800623:	83 f9 01             	cmp    $0x1,%ecx
  800626:	7f 17                	jg     80063f <vprintfmt+0x32e>
	else if (lflag)
  800628:	85 c9                	test   %ecx,%ecx
  80062a:	74 6e                	je     80069a <vprintfmt+0x389>
		return va_arg(*ap, long);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8b 10                	mov    (%eax),%edx
  800631:	89 d0                	mov    %edx,%eax
  800633:	99                   	cltd   
  800634:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800637:	8d 49 04             	lea    0x4(%ecx),%ecx
  80063a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80063d:	eb 11                	jmp    800650 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8b 50 04             	mov    0x4(%eax),%edx
  800645:	8b 00                	mov    (%eax),%eax
  800647:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80064a:	8d 49 08             	lea    0x8(%ecx),%ecx
  80064d:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800650:	89 d1                	mov    %edx,%ecx
  800652:	89 c2                	mov    %eax,%edx
            base = 8;
  800654:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800659:	83 ec 0c             	sub    $0xc,%esp
  80065c:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800660:	57                   	push   %edi
  800661:	ff 75 e0             	pushl  -0x20(%ebp)
  800664:	50                   	push   %eax
  800665:	51                   	push   %ecx
  800666:	52                   	push   %edx
  800667:	89 da                	mov    %ebx,%edx
  800669:	89 f0                	mov    %esi,%eax
  80066b:	e8 b6 fb ff ff       	call   800226 <printnum>
			break;
  800670:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800673:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800676:	83 c7 01             	add    $0x1,%edi
  800679:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80067d:	83 f8 25             	cmp    $0x25,%eax
  800680:	0f 84 a6 fc ff ff    	je     80032c <vprintfmt+0x1b>
			if (ch == '\0')
  800686:	85 c0                	test   %eax,%eax
  800688:	0f 84 ce 00 00 00    	je     80075c <vprintfmt+0x44b>
			putch(ch, putdat);
  80068e:	83 ec 08             	sub    $0x8,%esp
  800691:	53                   	push   %ebx
  800692:	50                   	push   %eax
  800693:	ff d6                	call   *%esi
  800695:	83 c4 10             	add    $0x10,%esp
  800698:	eb dc                	jmp    800676 <vprintfmt+0x365>
		return va_arg(*ap, int);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8b 10                	mov    (%eax),%edx
  80069f:	89 d0                	mov    %edx,%eax
  8006a1:	99                   	cltd   
  8006a2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006a5:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006a8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006ab:	eb a3                	jmp    800650 <vprintfmt+0x33f>
			putch('0', putdat);
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	53                   	push   %ebx
  8006b1:	6a 30                	push   $0x30
  8006b3:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b5:	83 c4 08             	add    $0x8,%esp
  8006b8:	53                   	push   %ebx
  8006b9:	6a 78                	push   $0x78
  8006bb:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8b 10                	mov    (%eax),%edx
  8006c2:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006c7:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006ca:	8d 40 04             	lea    0x4(%eax),%eax
  8006cd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006d5:	eb 82                	jmp    800659 <vprintfmt+0x348>
	if (lflag >= 2)
  8006d7:	83 f9 01             	cmp    $0x1,%ecx
  8006da:	7f 1e                	jg     8006fa <vprintfmt+0x3e9>
	else if (lflag)
  8006dc:	85 c9                	test   %ecx,%ecx
  8006de:	74 32                	je     800712 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8b 10                	mov    (%eax),%edx
  8006e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ea:	8d 40 04             	lea    0x4(%eax),%eax
  8006ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f0:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006f5:	e9 5f ff ff ff       	jmp    800659 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8b 10                	mov    (%eax),%edx
  8006ff:	8b 48 04             	mov    0x4(%eax),%ecx
  800702:	8d 40 08             	lea    0x8(%eax),%eax
  800705:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800708:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80070d:	e9 47 ff ff ff       	jmp    800659 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8b 10                	mov    (%eax),%edx
  800717:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071c:	8d 40 04             	lea    0x4(%eax),%eax
  80071f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800722:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800727:	e9 2d ff ff ff       	jmp    800659 <vprintfmt+0x348>
			putch(ch, putdat);
  80072c:	83 ec 08             	sub    $0x8,%esp
  80072f:	53                   	push   %ebx
  800730:	6a 25                	push   $0x25
  800732:	ff d6                	call   *%esi
			break;
  800734:	83 c4 10             	add    $0x10,%esp
  800737:	e9 37 ff ff ff       	jmp    800673 <vprintfmt+0x362>
			putch('%', putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	53                   	push   %ebx
  800740:	6a 25                	push   $0x25
  800742:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800744:	83 c4 10             	add    $0x10,%esp
  800747:	89 f8                	mov    %edi,%eax
  800749:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80074d:	74 05                	je     800754 <vprintfmt+0x443>
  80074f:	83 e8 01             	sub    $0x1,%eax
  800752:	eb f5                	jmp    800749 <vprintfmt+0x438>
  800754:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800757:	e9 17 ff ff ff       	jmp    800673 <vprintfmt+0x362>
}
  80075c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80075f:	5b                   	pop    %ebx
  800760:	5e                   	pop    %esi
  800761:	5f                   	pop    %edi
  800762:	5d                   	pop    %ebp
  800763:	c3                   	ret    

00800764 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800764:	f3 0f 1e fb          	endbr32 
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	83 ec 18             	sub    $0x18,%esp
  80076e:	8b 45 08             	mov    0x8(%ebp),%eax
  800771:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800774:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800777:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80077b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80077e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800785:	85 c0                	test   %eax,%eax
  800787:	74 26                	je     8007af <vsnprintf+0x4b>
  800789:	85 d2                	test   %edx,%edx
  80078b:	7e 22                	jle    8007af <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078d:	ff 75 14             	pushl  0x14(%ebp)
  800790:	ff 75 10             	pushl  0x10(%ebp)
  800793:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800796:	50                   	push   %eax
  800797:	68 cf 02 80 00       	push   $0x8002cf
  80079c:	e8 70 fb ff ff       	call   800311 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007aa:	83 c4 10             	add    $0x10,%esp
}
  8007ad:	c9                   	leave  
  8007ae:	c3                   	ret    
		return -E_INVAL;
  8007af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b4:	eb f7                	jmp    8007ad <vsnprintf+0x49>

008007b6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b6:	f3 0f 1e fb          	endbr32 
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c3:	50                   	push   %eax
  8007c4:	ff 75 10             	pushl  0x10(%ebp)
  8007c7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ca:	ff 75 08             	pushl  0x8(%ebp)
  8007cd:	e8 92 ff ff ff       	call   800764 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d2:	c9                   	leave  
  8007d3:	c3                   	ret    

008007d4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d4:	f3 0f 1e fb          	endbr32 
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e7:	74 05                	je     8007ee <strlen+0x1a>
		n++;
  8007e9:	83 c0 01             	add    $0x1,%eax
  8007ec:	eb f5                	jmp    8007e3 <strlen+0xf>
	return n;
}
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f0:	f3 0f 1e fb          	endbr32 
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fa:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800802:	39 d0                	cmp    %edx,%eax
  800804:	74 0d                	je     800813 <strnlen+0x23>
  800806:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80080a:	74 05                	je     800811 <strnlen+0x21>
		n++;
  80080c:	83 c0 01             	add    $0x1,%eax
  80080f:	eb f1                	jmp    800802 <strnlen+0x12>
  800811:	89 c2                	mov    %eax,%edx
	return n;
}
  800813:	89 d0                	mov    %edx,%eax
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800817:	f3 0f 1e fb          	endbr32 
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800822:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800825:	b8 00 00 00 00       	mov    $0x0,%eax
  80082a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80082e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800831:	83 c0 01             	add    $0x1,%eax
  800834:	84 d2                	test   %dl,%dl
  800836:	75 f2                	jne    80082a <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800838:	89 c8                	mov    %ecx,%eax
  80083a:	5b                   	pop    %ebx
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80083d:	f3 0f 1e fb          	endbr32 
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	53                   	push   %ebx
  800845:	83 ec 10             	sub    $0x10,%esp
  800848:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80084b:	53                   	push   %ebx
  80084c:	e8 83 ff ff ff       	call   8007d4 <strlen>
  800851:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800854:	ff 75 0c             	pushl  0xc(%ebp)
  800857:	01 d8                	add    %ebx,%eax
  800859:	50                   	push   %eax
  80085a:	e8 b8 ff ff ff       	call   800817 <strcpy>
	return dst;
}
  80085f:	89 d8                	mov    %ebx,%eax
  800861:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800864:	c9                   	leave  
  800865:	c3                   	ret    

00800866 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800866:	f3 0f 1e fb          	endbr32 
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	56                   	push   %esi
  80086e:	53                   	push   %ebx
  80086f:	8b 75 08             	mov    0x8(%ebp),%esi
  800872:	8b 55 0c             	mov    0xc(%ebp),%edx
  800875:	89 f3                	mov    %esi,%ebx
  800877:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087a:	89 f0                	mov    %esi,%eax
  80087c:	39 d8                	cmp    %ebx,%eax
  80087e:	74 11                	je     800891 <strncpy+0x2b>
		*dst++ = *src;
  800880:	83 c0 01             	add    $0x1,%eax
  800883:	0f b6 0a             	movzbl (%edx),%ecx
  800886:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800889:	80 f9 01             	cmp    $0x1,%cl
  80088c:	83 da ff             	sbb    $0xffffffff,%edx
  80088f:	eb eb                	jmp    80087c <strncpy+0x16>
	}
	return ret;
}
  800891:	89 f0                	mov    %esi,%eax
  800893:	5b                   	pop    %ebx
  800894:	5e                   	pop    %esi
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800897:	f3 0f 1e fb          	endbr32 
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	56                   	push   %esi
  80089f:	53                   	push   %ebx
  8008a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a6:	8b 55 10             	mov    0x10(%ebp),%edx
  8008a9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ab:	85 d2                	test   %edx,%edx
  8008ad:	74 21                	je     8008d0 <strlcpy+0x39>
  8008af:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008b3:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008b5:	39 c2                	cmp    %eax,%edx
  8008b7:	74 14                	je     8008cd <strlcpy+0x36>
  8008b9:	0f b6 19             	movzbl (%ecx),%ebx
  8008bc:	84 db                	test   %bl,%bl
  8008be:	74 0b                	je     8008cb <strlcpy+0x34>
			*dst++ = *src++;
  8008c0:	83 c1 01             	add    $0x1,%ecx
  8008c3:	83 c2 01             	add    $0x1,%edx
  8008c6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008c9:	eb ea                	jmp    8008b5 <strlcpy+0x1e>
  8008cb:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008cd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008d0:	29 f0                	sub    %esi,%eax
}
  8008d2:	5b                   	pop    %ebx
  8008d3:	5e                   	pop    %esi
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d6:	f3 0f 1e fb          	endbr32 
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e3:	0f b6 01             	movzbl (%ecx),%eax
  8008e6:	84 c0                	test   %al,%al
  8008e8:	74 0c                	je     8008f6 <strcmp+0x20>
  8008ea:	3a 02                	cmp    (%edx),%al
  8008ec:	75 08                	jne    8008f6 <strcmp+0x20>
		p++, q++;
  8008ee:	83 c1 01             	add    $0x1,%ecx
  8008f1:	83 c2 01             	add    $0x1,%edx
  8008f4:	eb ed                	jmp    8008e3 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f6:	0f b6 c0             	movzbl %al,%eax
  8008f9:	0f b6 12             	movzbl (%edx),%edx
  8008fc:	29 d0                	sub    %edx,%eax
}
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800900:	f3 0f 1e fb          	endbr32 
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	53                   	push   %ebx
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090e:	89 c3                	mov    %eax,%ebx
  800910:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800913:	eb 06                	jmp    80091b <strncmp+0x1b>
		n--, p++, q++;
  800915:	83 c0 01             	add    $0x1,%eax
  800918:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80091b:	39 d8                	cmp    %ebx,%eax
  80091d:	74 16                	je     800935 <strncmp+0x35>
  80091f:	0f b6 08             	movzbl (%eax),%ecx
  800922:	84 c9                	test   %cl,%cl
  800924:	74 04                	je     80092a <strncmp+0x2a>
  800926:	3a 0a                	cmp    (%edx),%cl
  800928:	74 eb                	je     800915 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092a:	0f b6 00             	movzbl (%eax),%eax
  80092d:	0f b6 12             	movzbl (%edx),%edx
  800930:	29 d0                	sub    %edx,%eax
}
  800932:	5b                   	pop    %ebx
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    
		return 0;
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
  80093a:	eb f6                	jmp    800932 <strncmp+0x32>

0080093c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093c:	f3 0f 1e fb          	endbr32 
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80094a:	0f b6 10             	movzbl (%eax),%edx
  80094d:	84 d2                	test   %dl,%dl
  80094f:	74 09                	je     80095a <strchr+0x1e>
		if (*s == c)
  800951:	38 ca                	cmp    %cl,%dl
  800953:	74 0a                	je     80095f <strchr+0x23>
	for (; *s; s++)
  800955:	83 c0 01             	add    $0x1,%eax
  800958:	eb f0                	jmp    80094a <strchr+0xe>
			return (char *) s;
	return 0;
  80095a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800961:	f3 0f 1e fb          	endbr32 
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80096f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800972:	38 ca                	cmp    %cl,%dl
  800974:	74 09                	je     80097f <strfind+0x1e>
  800976:	84 d2                	test   %dl,%dl
  800978:	74 05                	je     80097f <strfind+0x1e>
	for (; *s; s++)
  80097a:	83 c0 01             	add    $0x1,%eax
  80097d:	eb f0                	jmp    80096f <strfind+0xe>
			break;
	return (char *) s;
}
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800981:	f3 0f 1e fb          	endbr32 
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	57                   	push   %edi
  800989:	56                   	push   %esi
  80098a:	53                   	push   %ebx
  80098b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80098e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800991:	85 c9                	test   %ecx,%ecx
  800993:	74 31                	je     8009c6 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800995:	89 f8                	mov    %edi,%eax
  800997:	09 c8                	or     %ecx,%eax
  800999:	a8 03                	test   $0x3,%al
  80099b:	75 23                	jne    8009c0 <memset+0x3f>
		c &= 0xFF;
  80099d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a1:	89 d3                	mov    %edx,%ebx
  8009a3:	c1 e3 08             	shl    $0x8,%ebx
  8009a6:	89 d0                	mov    %edx,%eax
  8009a8:	c1 e0 18             	shl    $0x18,%eax
  8009ab:	89 d6                	mov    %edx,%esi
  8009ad:	c1 e6 10             	shl    $0x10,%esi
  8009b0:	09 f0                	or     %esi,%eax
  8009b2:	09 c2                	or     %eax,%edx
  8009b4:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009b6:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009b9:	89 d0                	mov    %edx,%eax
  8009bb:	fc                   	cld    
  8009bc:	f3 ab                	rep stos %eax,%es:(%edi)
  8009be:	eb 06                	jmp    8009c6 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c3:	fc                   	cld    
  8009c4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c6:	89 f8                	mov    %edi,%eax
  8009c8:	5b                   	pop    %ebx
  8009c9:	5e                   	pop    %esi
  8009ca:	5f                   	pop    %edi
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009cd:	f3 0f 1e fb          	endbr32 
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	57                   	push   %edi
  8009d5:	56                   	push   %esi
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009df:	39 c6                	cmp    %eax,%esi
  8009e1:	73 32                	jae    800a15 <memmove+0x48>
  8009e3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e6:	39 c2                	cmp    %eax,%edx
  8009e8:	76 2b                	jbe    800a15 <memmove+0x48>
		s += n;
		d += n;
  8009ea:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ed:	89 fe                	mov    %edi,%esi
  8009ef:	09 ce                	or     %ecx,%esi
  8009f1:	09 d6                	or     %edx,%esi
  8009f3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f9:	75 0e                	jne    800a09 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009fb:	83 ef 04             	sub    $0x4,%edi
  8009fe:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a01:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a04:	fd                   	std    
  800a05:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a07:	eb 09                	jmp    800a12 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a09:	83 ef 01             	sub    $0x1,%edi
  800a0c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a0f:	fd                   	std    
  800a10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a12:	fc                   	cld    
  800a13:	eb 1a                	jmp    800a2f <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a15:	89 c2                	mov    %eax,%edx
  800a17:	09 ca                	or     %ecx,%edx
  800a19:	09 f2                	or     %esi,%edx
  800a1b:	f6 c2 03             	test   $0x3,%dl
  800a1e:	75 0a                	jne    800a2a <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a20:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a23:	89 c7                	mov    %eax,%edi
  800a25:	fc                   	cld    
  800a26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a28:	eb 05                	jmp    800a2f <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a2a:	89 c7                	mov    %eax,%edi
  800a2c:	fc                   	cld    
  800a2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a2f:	5e                   	pop    %esi
  800a30:	5f                   	pop    %edi
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a33:	f3 0f 1e fb          	endbr32 
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a3d:	ff 75 10             	pushl  0x10(%ebp)
  800a40:	ff 75 0c             	pushl  0xc(%ebp)
  800a43:	ff 75 08             	pushl  0x8(%ebp)
  800a46:	e8 82 ff ff ff       	call   8009cd <memmove>
}
  800a4b:	c9                   	leave  
  800a4c:	c3                   	ret    

00800a4d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a4d:	f3 0f 1e fb          	endbr32 
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	56                   	push   %esi
  800a55:	53                   	push   %ebx
  800a56:	8b 45 08             	mov    0x8(%ebp),%eax
  800a59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5c:	89 c6                	mov    %eax,%esi
  800a5e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a61:	39 f0                	cmp    %esi,%eax
  800a63:	74 1c                	je     800a81 <memcmp+0x34>
		if (*s1 != *s2)
  800a65:	0f b6 08             	movzbl (%eax),%ecx
  800a68:	0f b6 1a             	movzbl (%edx),%ebx
  800a6b:	38 d9                	cmp    %bl,%cl
  800a6d:	75 08                	jne    800a77 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a6f:	83 c0 01             	add    $0x1,%eax
  800a72:	83 c2 01             	add    $0x1,%edx
  800a75:	eb ea                	jmp    800a61 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a77:	0f b6 c1             	movzbl %cl,%eax
  800a7a:	0f b6 db             	movzbl %bl,%ebx
  800a7d:	29 d8                	sub    %ebx,%eax
  800a7f:	eb 05                	jmp    800a86 <memcmp+0x39>
	}

	return 0;
  800a81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a86:	5b                   	pop    %ebx
  800a87:	5e                   	pop    %esi
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a8a:	f3 0f 1e fb          	endbr32 
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	8b 45 08             	mov    0x8(%ebp),%eax
  800a94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a97:	89 c2                	mov    %eax,%edx
  800a99:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a9c:	39 d0                	cmp    %edx,%eax
  800a9e:	73 09                	jae    800aa9 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa0:	38 08                	cmp    %cl,(%eax)
  800aa2:	74 05                	je     800aa9 <memfind+0x1f>
	for (; s < ends; s++)
  800aa4:	83 c0 01             	add    $0x1,%eax
  800aa7:	eb f3                	jmp    800a9c <memfind+0x12>
			break;
	return (void *) s;
}
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aab:	f3 0f 1e fb          	endbr32 
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	57                   	push   %edi
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
  800ab5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800abb:	eb 03                	jmp    800ac0 <strtol+0x15>
		s++;
  800abd:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ac0:	0f b6 01             	movzbl (%ecx),%eax
  800ac3:	3c 20                	cmp    $0x20,%al
  800ac5:	74 f6                	je     800abd <strtol+0x12>
  800ac7:	3c 09                	cmp    $0x9,%al
  800ac9:	74 f2                	je     800abd <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800acb:	3c 2b                	cmp    $0x2b,%al
  800acd:	74 2a                	je     800af9 <strtol+0x4e>
	int neg = 0;
  800acf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ad4:	3c 2d                	cmp    $0x2d,%al
  800ad6:	74 2b                	je     800b03 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ade:	75 0f                	jne    800aef <strtol+0x44>
  800ae0:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae3:	74 28                	je     800b0d <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ae5:	85 db                	test   %ebx,%ebx
  800ae7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aec:	0f 44 d8             	cmove  %eax,%ebx
  800aef:	b8 00 00 00 00       	mov    $0x0,%eax
  800af4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800af7:	eb 46                	jmp    800b3f <strtol+0x94>
		s++;
  800af9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800afc:	bf 00 00 00 00       	mov    $0x0,%edi
  800b01:	eb d5                	jmp    800ad8 <strtol+0x2d>
		s++, neg = 1;
  800b03:	83 c1 01             	add    $0x1,%ecx
  800b06:	bf 01 00 00 00       	mov    $0x1,%edi
  800b0b:	eb cb                	jmp    800ad8 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b0d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b11:	74 0e                	je     800b21 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b13:	85 db                	test   %ebx,%ebx
  800b15:	75 d8                	jne    800aef <strtol+0x44>
		s++, base = 8;
  800b17:	83 c1 01             	add    $0x1,%ecx
  800b1a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b1f:	eb ce                	jmp    800aef <strtol+0x44>
		s += 2, base = 16;
  800b21:	83 c1 02             	add    $0x2,%ecx
  800b24:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b29:	eb c4                	jmp    800aef <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b2b:	0f be d2             	movsbl %dl,%edx
  800b2e:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b31:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b34:	7d 3a                	jge    800b70 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b36:	83 c1 01             	add    $0x1,%ecx
  800b39:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b3d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b3f:	0f b6 11             	movzbl (%ecx),%edx
  800b42:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b45:	89 f3                	mov    %esi,%ebx
  800b47:	80 fb 09             	cmp    $0x9,%bl
  800b4a:	76 df                	jbe    800b2b <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b4c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b4f:	89 f3                	mov    %esi,%ebx
  800b51:	80 fb 19             	cmp    $0x19,%bl
  800b54:	77 08                	ja     800b5e <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b56:	0f be d2             	movsbl %dl,%edx
  800b59:	83 ea 57             	sub    $0x57,%edx
  800b5c:	eb d3                	jmp    800b31 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b5e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b61:	89 f3                	mov    %esi,%ebx
  800b63:	80 fb 19             	cmp    $0x19,%bl
  800b66:	77 08                	ja     800b70 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b68:	0f be d2             	movsbl %dl,%edx
  800b6b:	83 ea 37             	sub    $0x37,%edx
  800b6e:	eb c1                	jmp    800b31 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b70:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b74:	74 05                	je     800b7b <strtol+0xd0>
		*endptr = (char *) s;
  800b76:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b79:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b7b:	89 c2                	mov    %eax,%edx
  800b7d:	f7 da                	neg    %edx
  800b7f:	85 ff                	test   %edi,%edi
  800b81:	0f 45 c2             	cmovne %edx,%eax
}
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b89:	f3 0f 1e fb          	endbr32 
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
  800b98:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9e:	89 c3                	mov    %eax,%ebx
  800ba0:	89 c7                	mov    %eax,%edi
  800ba2:	89 c6                	mov    %eax,%esi
  800ba4:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba6:	5b                   	pop    %ebx
  800ba7:	5e                   	pop    %esi
  800ba8:	5f                   	pop    %edi
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <sys_cgetc>:

int
sys_cgetc(void)
{
  800bab:	f3 0f 1e fb          	endbr32 
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bba:	b8 01 00 00 00       	mov    $0x1,%eax
  800bbf:	89 d1                	mov    %edx,%ecx
  800bc1:	89 d3                	mov    %edx,%ebx
  800bc3:	89 d7                	mov    %edx,%edi
  800bc5:	89 d6                	mov    %edx,%esi
  800bc7:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bce:	f3 0f 1e fb          	endbr32 
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
  800bd8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bdb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be0:	8b 55 08             	mov    0x8(%ebp),%edx
  800be3:	b8 03 00 00 00       	mov    $0x3,%eax
  800be8:	89 cb                	mov    %ecx,%ebx
  800bea:	89 cf                	mov    %ecx,%edi
  800bec:	89 ce                	mov    %ecx,%esi
  800bee:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bf0:	85 c0                	test   %eax,%eax
  800bf2:	7f 08                	jg     800bfc <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfc:	83 ec 0c             	sub    $0xc,%esp
  800bff:	50                   	push   %eax
  800c00:	6a 03                	push   $0x3
  800c02:	68 1f 15 80 00       	push   $0x80151f
  800c07:	6a 23                	push   $0x23
  800c09:	68 3c 15 80 00       	push   $0x80153c
  800c0e:	e8 14 f5 ff ff       	call   800127 <_panic>

00800c13 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c13:	f3 0f 1e fb          	endbr32 
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c22:	b8 02 00 00 00       	mov    $0x2,%eax
  800c27:	89 d1                	mov    %edx,%ecx
  800c29:	89 d3                	mov    %edx,%ebx
  800c2b:	89 d7                	mov    %edx,%edi
  800c2d:	89 d6                	mov    %edx,%esi
  800c2f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <sys_yield>:

void
sys_yield(void)
{
  800c36:	f3 0f 1e fb          	endbr32 
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c40:	ba 00 00 00 00       	mov    $0x0,%edx
  800c45:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c4a:	89 d1                	mov    %edx,%ecx
  800c4c:	89 d3                	mov    %edx,%ebx
  800c4e:	89 d7                	mov    %edx,%edi
  800c50:	89 d6                	mov    %edx,%esi
  800c52:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c59:	f3 0f 1e fb          	endbr32 
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	57                   	push   %edi
  800c61:	56                   	push   %esi
  800c62:	53                   	push   %ebx
  800c63:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c66:	be 00 00 00 00       	mov    $0x0,%esi
  800c6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c71:	b8 04 00 00 00       	mov    $0x4,%eax
  800c76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c79:	89 f7                	mov    %esi,%edi
  800c7b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	7f 08                	jg     800c89 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c89:	83 ec 0c             	sub    $0xc,%esp
  800c8c:	50                   	push   %eax
  800c8d:	6a 04                	push   $0x4
  800c8f:	68 1f 15 80 00       	push   $0x80151f
  800c94:	6a 23                	push   $0x23
  800c96:	68 3c 15 80 00       	push   $0x80153c
  800c9b:	e8 87 f4 ff ff       	call   800127 <_panic>

00800ca0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca0:	f3 0f 1e fb          	endbr32 
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
  800caa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	b8 05 00 00 00       	mov    $0x5,%eax
  800cb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cbe:	8b 75 18             	mov    0x18(%ebp),%esi
  800cc1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc3:	85 c0                	test   %eax,%eax
  800cc5:	7f 08                	jg     800ccf <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cca:	5b                   	pop    %ebx
  800ccb:	5e                   	pop    %esi
  800ccc:	5f                   	pop    %edi
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	50                   	push   %eax
  800cd3:	6a 05                	push   $0x5
  800cd5:	68 1f 15 80 00       	push   $0x80151f
  800cda:	6a 23                	push   $0x23
  800cdc:	68 3c 15 80 00       	push   $0x80153c
  800ce1:	e8 41 f4 ff ff       	call   800127 <_panic>

00800ce6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ce6:	f3 0f 1e fb          	endbr32 
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
  800cf0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	b8 06 00 00 00       	mov    $0x6,%eax
  800d03:	89 df                	mov    %ebx,%edi
  800d05:	89 de                	mov    %ebx,%esi
  800d07:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	7f 08                	jg     800d15 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d15:	83 ec 0c             	sub    $0xc,%esp
  800d18:	50                   	push   %eax
  800d19:	6a 06                	push   $0x6
  800d1b:	68 1f 15 80 00       	push   $0x80151f
  800d20:	6a 23                	push   $0x23
  800d22:	68 3c 15 80 00       	push   $0x80153c
  800d27:	e8 fb f3 ff ff       	call   800127 <_panic>

00800d2c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d2c:	f3 0f 1e fb          	endbr32 
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d44:	b8 08 00 00 00       	mov    $0x8,%eax
  800d49:	89 df                	mov    %ebx,%edi
  800d4b:	89 de                	mov    %ebx,%esi
  800d4d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	7f 08                	jg     800d5b <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5b:	83 ec 0c             	sub    $0xc,%esp
  800d5e:	50                   	push   %eax
  800d5f:	6a 08                	push   $0x8
  800d61:	68 1f 15 80 00       	push   $0x80151f
  800d66:	6a 23                	push   $0x23
  800d68:	68 3c 15 80 00       	push   $0x80153c
  800d6d:	e8 b5 f3 ff ff       	call   800127 <_panic>

00800d72 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d72:	f3 0f 1e fb          	endbr32 
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	57                   	push   %edi
  800d7a:	56                   	push   %esi
  800d7b:	53                   	push   %ebx
  800d7c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d84:	8b 55 08             	mov    0x8(%ebp),%edx
  800d87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d8f:	89 df                	mov    %ebx,%edi
  800d91:	89 de                	mov    %ebx,%esi
  800d93:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d95:	85 c0                	test   %eax,%eax
  800d97:	7f 08                	jg     800da1 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da1:	83 ec 0c             	sub    $0xc,%esp
  800da4:	50                   	push   %eax
  800da5:	6a 09                	push   $0x9
  800da7:	68 1f 15 80 00       	push   $0x80151f
  800dac:	6a 23                	push   $0x23
  800dae:	68 3c 15 80 00       	push   $0x80153c
  800db3:	e8 6f f3 ff ff       	call   800127 <_panic>

00800db8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800db8:	f3 0f 1e fb          	endbr32 
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	57                   	push   %edi
  800dc0:	56                   	push   %esi
  800dc1:	53                   	push   %ebx
  800dc2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dca:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dd5:	89 df                	mov    %ebx,%edi
  800dd7:	89 de                	mov    %ebx,%esi
  800dd9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	7f 08                	jg     800de7 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ddf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de7:	83 ec 0c             	sub    $0xc,%esp
  800dea:	50                   	push   %eax
  800deb:	6a 0a                	push   $0xa
  800ded:	68 1f 15 80 00       	push   $0x80151f
  800df2:	6a 23                	push   $0x23
  800df4:	68 3c 15 80 00       	push   $0x80153c
  800df9:	e8 29 f3 ff ff       	call   800127 <_panic>

00800dfe <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dfe:	f3 0f 1e fb          	endbr32 
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e08:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e13:	be 00 00 00 00       	mov    $0x0,%esi
  800e18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e1e:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e25:	f3 0f 1e fb          	endbr32 
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e37:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e3f:	89 cb                	mov    %ecx,%ebx
  800e41:	89 cf                	mov    %ecx,%edi
  800e43:	89 ce                	mov    %ecx,%esi
  800e45:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e47:	85 c0                	test   %eax,%eax
  800e49:	7f 08                	jg     800e53 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e53:	83 ec 0c             	sub    $0xc,%esp
  800e56:	50                   	push   %eax
  800e57:	6a 0d                	push   $0xd
  800e59:	68 1f 15 80 00       	push   $0x80151f
  800e5e:	6a 23                	push   $0x23
  800e60:	68 3c 15 80 00       	push   $0x80153c
  800e65:	e8 bd f2 ff ff       	call   800127 <_panic>

00800e6a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e6a:	f3 0f 1e fb          	endbr32 
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e74:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e7b:	74 0a                	je     800e87 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e80:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800e85:	c9                   	leave  
  800e86:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  800e87:	83 ec 0c             	sub    $0xc,%esp
  800e8a:	68 4a 15 80 00       	push   $0x80154a
  800e8f:	e8 7a f3 ff ff       	call   80020e <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  800e94:	83 c4 0c             	add    $0xc,%esp
  800e97:	6a 07                	push   $0x7
  800e99:	68 00 f0 bf ee       	push   $0xeebff000
  800e9e:	6a 00                	push   $0x0
  800ea0:	e8 b4 fd ff ff       	call   800c59 <sys_page_alloc>
  800ea5:	83 c4 10             	add    $0x10,%esp
  800ea8:	85 c0                	test   %eax,%eax
  800eaa:	78 2a                	js     800ed6 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  800eac:	83 ec 08             	sub    $0x8,%esp
  800eaf:	68 ea 0e 80 00       	push   $0x800eea
  800eb4:	6a 00                	push   $0x0
  800eb6:	e8 fd fe ff ff       	call   800db8 <sys_env_set_pgfault_upcall>
  800ebb:	83 c4 10             	add    $0x10,%esp
  800ebe:	85 c0                	test   %eax,%eax
  800ec0:	79 bb                	jns    800e7d <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  800ec2:	83 ec 04             	sub    $0x4,%esp
  800ec5:	68 88 15 80 00       	push   $0x801588
  800eca:	6a 25                	push   $0x25
  800ecc:	68 77 15 80 00       	push   $0x801577
  800ed1:	e8 51 f2 ff ff       	call   800127 <_panic>
            panic("Allocation of UXSTACK failed!");
  800ed6:	83 ec 04             	sub    $0x4,%esp
  800ed9:	68 59 15 80 00       	push   $0x801559
  800ede:	6a 22                	push   $0x22
  800ee0:	68 77 15 80 00       	push   $0x801577
  800ee5:	e8 3d f2 ff ff       	call   800127 <_panic>

00800eea <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800eea:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800eeb:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800ef0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800ef2:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  800ef5:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  800ef9:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  800efd:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  800f00:	83 c4 08             	add    $0x8,%esp
    popa
  800f03:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  800f04:	83 c4 04             	add    $0x4,%esp
    popf
  800f07:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  800f08:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  800f0b:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  800f0f:	c3                   	ret    

00800f10 <__udivdi3>:
  800f10:	f3 0f 1e fb          	endbr32 
  800f14:	55                   	push   %ebp
  800f15:	57                   	push   %edi
  800f16:	56                   	push   %esi
  800f17:	53                   	push   %ebx
  800f18:	83 ec 1c             	sub    $0x1c,%esp
  800f1b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f1f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800f23:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f27:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800f2b:	85 d2                	test   %edx,%edx
  800f2d:	75 19                	jne    800f48 <__udivdi3+0x38>
  800f2f:	39 f3                	cmp    %esi,%ebx
  800f31:	76 4d                	jbe    800f80 <__udivdi3+0x70>
  800f33:	31 ff                	xor    %edi,%edi
  800f35:	89 e8                	mov    %ebp,%eax
  800f37:	89 f2                	mov    %esi,%edx
  800f39:	f7 f3                	div    %ebx
  800f3b:	89 fa                	mov    %edi,%edx
  800f3d:	83 c4 1c             	add    $0x1c,%esp
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    
  800f45:	8d 76 00             	lea    0x0(%esi),%esi
  800f48:	39 f2                	cmp    %esi,%edx
  800f4a:	76 14                	jbe    800f60 <__udivdi3+0x50>
  800f4c:	31 ff                	xor    %edi,%edi
  800f4e:	31 c0                	xor    %eax,%eax
  800f50:	89 fa                	mov    %edi,%edx
  800f52:	83 c4 1c             	add    $0x1c,%esp
  800f55:	5b                   	pop    %ebx
  800f56:	5e                   	pop    %esi
  800f57:	5f                   	pop    %edi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    
  800f5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f60:	0f bd fa             	bsr    %edx,%edi
  800f63:	83 f7 1f             	xor    $0x1f,%edi
  800f66:	75 48                	jne    800fb0 <__udivdi3+0xa0>
  800f68:	39 f2                	cmp    %esi,%edx
  800f6a:	72 06                	jb     800f72 <__udivdi3+0x62>
  800f6c:	31 c0                	xor    %eax,%eax
  800f6e:	39 eb                	cmp    %ebp,%ebx
  800f70:	77 de                	ja     800f50 <__udivdi3+0x40>
  800f72:	b8 01 00 00 00       	mov    $0x1,%eax
  800f77:	eb d7                	jmp    800f50 <__udivdi3+0x40>
  800f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f80:	89 d9                	mov    %ebx,%ecx
  800f82:	85 db                	test   %ebx,%ebx
  800f84:	75 0b                	jne    800f91 <__udivdi3+0x81>
  800f86:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8b:	31 d2                	xor    %edx,%edx
  800f8d:	f7 f3                	div    %ebx
  800f8f:	89 c1                	mov    %eax,%ecx
  800f91:	31 d2                	xor    %edx,%edx
  800f93:	89 f0                	mov    %esi,%eax
  800f95:	f7 f1                	div    %ecx
  800f97:	89 c6                	mov    %eax,%esi
  800f99:	89 e8                	mov    %ebp,%eax
  800f9b:	89 f7                	mov    %esi,%edi
  800f9d:	f7 f1                	div    %ecx
  800f9f:	89 fa                	mov    %edi,%edx
  800fa1:	83 c4 1c             	add    $0x1c,%esp
  800fa4:	5b                   	pop    %ebx
  800fa5:	5e                   	pop    %esi
  800fa6:	5f                   	pop    %edi
  800fa7:	5d                   	pop    %ebp
  800fa8:	c3                   	ret    
  800fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fb0:	89 f9                	mov    %edi,%ecx
  800fb2:	b8 20 00 00 00       	mov    $0x20,%eax
  800fb7:	29 f8                	sub    %edi,%eax
  800fb9:	d3 e2                	shl    %cl,%edx
  800fbb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fbf:	89 c1                	mov    %eax,%ecx
  800fc1:	89 da                	mov    %ebx,%edx
  800fc3:	d3 ea                	shr    %cl,%edx
  800fc5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fc9:	09 d1                	or     %edx,%ecx
  800fcb:	89 f2                	mov    %esi,%edx
  800fcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fd1:	89 f9                	mov    %edi,%ecx
  800fd3:	d3 e3                	shl    %cl,%ebx
  800fd5:	89 c1                	mov    %eax,%ecx
  800fd7:	d3 ea                	shr    %cl,%edx
  800fd9:	89 f9                	mov    %edi,%ecx
  800fdb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fdf:	89 eb                	mov    %ebp,%ebx
  800fe1:	d3 e6                	shl    %cl,%esi
  800fe3:	89 c1                	mov    %eax,%ecx
  800fe5:	d3 eb                	shr    %cl,%ebx
  800fe7:	09 de                	or     %ebx,%esi
  800fe9:	89 f0                	mov    %esi,%eax
  800feb:	f7 74 24 08          	divl   0x8(%esp)
  800fef:	89 d6                	mov    %edx,%esi
  800ff1:	89 c3                	mov    %eax,%ebx
  800ff3:	f7 64 24 0c          	mull   0xc(%esp)
  800ff7:	39 d6                	cmp    %edx,%esi
  800ff9:	72 15                	jb     801010 <__udivdi3+0x100>
  800ffb:	89 f9                	mov    %edi,%ecx
  800ffd:	d3 e5                	shl    %cl,%ebp
  800fff:	39 c5                	cmp    %eax,%ebp
  801001:	73 04                	jae    801007 <__udivdi3+0xf7>
  801003:	39 d6                	cmp    %edx,%esi
  801005:	74 09                	je     801010 <__udivdi3+0x100>
  801007:	89 d8                	mov    %ebx,%eax
  801009:	31 ff                	xor    %edi,%edi
  80100b:	e9 40 ff ff ff       	jmp    800f50 <__udivdi3+0x40>
  801010:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801013:	31 ff                	xor    %edi,%edi
  801015:	e9 36 ff ff ff       	jmp    800f50 <__udivdi3+0x40>
  80101a:	66 90                	xchg   %ax,%ax
  80101c:	66 90                	xchg   %ax,%ax
  80101e:	66 90                	xchg   %ax,%ax

00801020 <__umoddi3>:
  801020:	f3 0f 1e fb          	endbr32 
  801024:	55                   	push   %ebp
  801025:	57                   	push   %edi
  801026:	56                   	push   %esi
  801027:	53                   	push   %ebx
  801028:	83 ec 1c             	sub    $0x1c,%esp
  80102b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80102f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801033:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801037:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80103b:	85 c0                	test   %eax,%eax
  80103d:	75 19                	jne    801058 <__umoddi3+0x38>
  80103f:	39 df                	cmp    %ebx,%edi
  801041:	76 5d                	jbe    8010a0 <__umoddi3+0x80>
  801043:	89 f0                	mov    %esi,%eax
  801045:	89 da                	mov    %ebx,%edx
  801047:	f7 f7                	div    %edi
  801049:	89 d0                	mov    %edx,%eax
  80104b:	31 d2                	xor    %edx,%edx
  80104d:	83 c4 1c             	add    $0x1c,%esp
  801050:	5b                   	pop    %ebx
  801051:	5e                   	pop    %esi
  801052:	5f                   	pop    %edi
  801053:	5d                   	pop    %ebp
  801054:	c3                   	ret    
  801055:	8d 76 00             	lea    0x0(%esi),%esi
  801058:	89 f2                	mov    %esi,%edx
  80105a:	39 d8                	cmp    %ebx,%eax
  80105c:	76 12                	jbe    801070 <__umoddi3+0x50>
  80105e:	89 f0                	mov    %esi,%eax
  801060:	89 da                	mov    %ebx,%edx
  801062:	83 c4 1c             	add    $0x1c,%esp
  801065:	5b                   	pop    %ebx
  801066:	5e                   	pop    %esi
  801067:	5f                   	pop    %edi
  801068:	5d                   	pop    %ebp
  801069:	c3                   	ret    
  80106a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801070:	0f bd e8             	bsr    %eax,%ebp
  801073:	83 f5 1f             	xor    $0x1f,%ebp
  801076:	75 50                	jne    8010c8 <__umoddi3+0xa8>
  801078:	39 d8                	cmp    %ebx,%eax
  80107a:	0f 82 e0 00 00 00    	jb     801160 <__umoddi3+0x140>
  801080:	89 d9                	mov    %ebx,%ecx
  801082:	39 f7                	cmp    %esi,%edi
  801084:	0f 86 d6 00 00 00    	jbe    801160 <__umoddi3+0x140>
  80108a:	89 d0                	mov    %edx,%eax
  80108c:	89 ca                	mov    %ecx,%edx
  80108e:	83 c4 1c             	add    $0x1c,%esp
  801091:	5b                   	pop    %ebx
  801092:	5e                   	pop    %esi
  801093:	5f                   	pop    %edi
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    
  801096:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80109d:	8d 76 00             	lea    0x0(%esi),%esi
  8010a0:	89 fd                	mov    %edi,%ebp
  8010a2:	85 ff                	test   %edi,%edi
  8010a4:	75 0b                	jne    8010b1 <__umoddi3+0x91>
  8010a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ab:	31 d2                	xor    %edx,%edx
  8010ad:	f7 f7                	div    %edi
  8010af:	89 c5                	mov    %eax,%ebp
  8010b1:	89 d8                	mov    %ebx,%eax
  8010b3:	31 d2                	xor    %edx,%edx
  8010b5:	f7 f5                	div    %ebp
  8010b7:	89 f0                	mov    %esi,%eax
  8010b9:	f7 f5                	div    %ebp
  8010bb:	89 d0                	mov    %edx,%eax
  8010bd:	31 d2                	xor    %edx,%edx
  8010bf:	eb 8c                	jmp    80104d <__umoddi3+0x2d>
  8010c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010c8:	89 e9                	mov    %ebp,%ecx
  8010ca:	ba 20 00 00 00       	mov    $0x20,%edx
  8010cf:	29 ea                	sub    %ebp,%edx
  8010d1:	d3 e0                	shl    %cl,%eax
  8010d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010d7:	89 d1                	mov    %edx,%ecx
  8010d9:	89 f8                	mov    %edi,%eax
  8010db:	d3 e8                	shr    %cl,%eax
  8010dd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8010e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010e5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010e9:	09 c1                	or     %eax,%ecx
  8010eb:	89 d8                	mov    %ebx,%eax
  8010ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010f1:	89 e9                	mov    %ebp,%ecx
  8010f3:	d3 e7                	shl    %cl,%edi
  8010f5:	89 d1                	mov    %edx,%ecx
  8010f7:	d3 e8                	shr    %cl,%eax
  8010f9:	89 e9                	mov    %ebp,%ecx
  8010fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010ff:	d3 e3                	shl    %cl,%ebx
  801101:	89 c7                	mov    %eax,%edi
  801103:	89 d1                	mov    %edx,%ecx
  801105:	89 f0                	mov    %esi,%eax
  801107:	d3 e8                	shr    %cl,%eax
  801109:	89 e9                	mov    %ebp,%ecx
  80110b:	89 fa                	mov    %edi,%edx
  80110d:	d3 e6                	shl    %cl,%esi
  80110f:	09 d8                	or     %ebx,%eax
  801111:	f7 74 24 08          	divl   0x8(%esp)
  801115:	89 d1                	mov    %edx,%ecx
  801117:	89 f3                	mov    %esi,%ebx
  801119:	f7 64 24 0c          	mull   0xc(%esp)
  80111d:	89 c6                	mov    %eax,%esi
  80111f:	89 d7                	mov    %edx,%edi
  801121:	39 d1                	cmp    %edx,%ecx
  801123:	72 06                	jb     80112b <__umoddi3+0x10b>
  801125:	75 10                	jne    801137 <__umoddi3+0x117>
  801127:	39 c3                	cmp    %eax,%ebx
  801129:	73 0c                	jae    801137 <__umoddi3+0x117>
  80112b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80112f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801133:	89 d7                	mov    %edx,%edi
  801135:	89 c6                	mov    %eax,%esi
  801137:	89 ca                	mov    %ecx,%edx
  801139:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80113e:	29 f3                	sub    %esi,%ebx
  801140:	19 fa                	sbb    %edi,%edx
  801142:	89 d0                	mov    %edx,%eax
  801144:	d3 e0                	shl    %cl,%eax
  801146:	89 e9                	mov    %ebp,%ecx
  801148:	d3 eb                	shr    %cl,%ebx
  80114a:	d3 ea                	shr    %cl,%edx
  80114c:	09 d8                	or     %ebx,%eax
  80114e:	83 c4 1c             	add    $0x1c,%esp
  801151:	5b                   	pop    %ebx
  801152:	5e                   	pop    %esi
  801153:	5f                   	pop    %edi
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    
  801156:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80115d:	8d 76 00             	lea    0x0(%esi),%esi
  801160:	29 fe                	sub    %edi,%esi
  801162:	19 c3                	sbb    %eax,%ebx
  801164:	89 f2                	mov    %esi,%edx
  801166:	89 d9                	mov    %ebx,%ecx
  801168:	e9 1d ff ff ff       	jmp    80108a <__umoddi3+0x6a>
