
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
  800044:	68 00 20 80 00       	push   $0x802000
  800049:	e8 c8 01 00 00       	call   800216 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004e:	83 c4 0c             	add    $0xc,%esp
  800051:	6a 07                	push   $0x7
  800053:	89 d8                	mov    %ebx,%eax
  800055:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005a:	50                   	push   %eax
  80005b:	6a 00                	push   $0x0
  80005d:	e8 ff 0b 00 00       	call   800c61 <sys_page_alloc>
  800062:	83 c4 10             	add    $0x10,%esp
  800065:	85 c0                	test   %eax,%eax
  800067:	78 16                	js     80007f <handler+0x4c>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800069:	53                   	push   %ebx
  80006a:	68 4c 20 80 00       	push   $0x80204c
  80006f:	6a 64                	push   $0x64
  800071:	53                   	push   %ebx
  800072:	e8 47 07 00 00       	call   8007be <snprintf>
}
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007d:	c9                   	leave  
  80007e:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007f:	83 ec 0c             	sub    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	53                   	push   %ebx
  800084:	68 20 20 80 00       	push   $0x802020
  800089:	6a 0f                	push   $0xf
  80008b:	68 0a 20 80 00       	push   $0x80200a
  800090:	e8 9a 00 00 00       	call   80012f <_panic>

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
  8000a4:	e8 c9 0d 00 00       	call   800e72 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a9:	83 c4 08             	add    $0x8,%esp
  8000ac:	6a 04                	push   $0x4
  8000ae:	68 ef be ad de       	push   $0xdeadbeef
  8000b3:	e8 d9 0a 00 00       	call   800b91 <sys_cputs>
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
  8000cc:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8000d3:	00 00 00 
    envid_t envid = sys_getenvid();
  8000d6:	e8 40 0b 00 00       	call   800c1b <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8000db:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e8:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ed:	85 db                	test   %ebx,%ebx
  8000ef:	7e 07                	jle    8000f8 <libmain+0x3b>
		binaryname = argv[0];
  8000f1:	8b 06                	mov    (%esi),%eax
  8000f3:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800118:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80011b:	e8 e7 0f 00 00       	call   801107 <close_all>
	sys_env_destroy(0);
  800120:	83 ec 0c             	sub    $0xc,%esp
  800123:	6a 00                	push   $0x0
  800125:	e8 ac 0a 00 00       	call   800bd6 <sys_env_destroy>
}
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	c9                   	leave  
  80012e:	c3                   	ret    

0080012f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012f:	f3 0f 1e fb          	endbr32 
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800138:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800141:	e8 d5 0a 00 00       	call   800c1b <sys_getenvid>
  800146:	83 ec 0c             	sub    $0xc,%esp
  800149:	ff 75 0c             	pushl  0xc(%ebp)
  80014c:	ff 75 08             	pushl  0x8(%ebp)
  80014f:	56                   	push   %esi
  800150:	50                   	push   %eax
  800151:	68 78 20 80 00       	push   $0x802078
  800156:	e8 bb 00 00 00       	call   800216 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015b:	83 c4 18             	add    $0x18,%esp
  80015e:	53                   	push   %ebx
  80015f:	ff 75 10             	pushl  0x10(%ebp)
  800162:	e8 5a 00 00 00       	call   8001c1 <vcprintf>
	cprintf("\n");
  800167:	c7 04 24 d7 23 80 00 	movl   $0x8023d7,(%esp)
  80016e:	e8 a3 00 00 00       	call   800216 <cprintf>
  800173:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800176:	cc                   	int3   
  800177:	eb fd                	jmp    800176 <_panic+0x47>

00800179 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800179:	f3 0f 1e fb          	endbr32 
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	53                   	push   %ebx
  800181:	83 ec 04             	sub    $0x4,%esp
  800184:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800187:	8b 13                	mov    (%ebx),%edx
  800189:	8d 42 01             	lea    0x1(%edx),%eax
  80018c:	89 03                	mov    %eax,(%ebx)
  80018e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800191:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800195:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019a:	74 09                	je     8001a5 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80019c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a3:	c9                   	leave  
  8001a4:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	68 ff 00 00 00       	push   $0xff
  8001ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b0:	50                   	push   %eax
  8001b1:	e8 db 09 00 00       	call   800b91 <sys_cputs>
		b->idx = 0;
  8001b6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001bc:	83 c4 10             	add    $0x10,%esp
  8001bf:	eb db                	jmp    80019c <putch+0x23>

008001c1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c1:	f3 0f 1e fb          	endbr32 
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ce:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d5:	00 00 00 
	b.cnt = 0;
  8001d8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001df:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e2:	ff 75 0c             	pushl  0xc(%ebp)
  8001e5:	ff 75 08             	pushl  0x8(%ebp)
  8001e8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ee:	50                   	push   %eax
  8001ef:	68 79 01 80 00       	push   $0x800179
  8001f4:	e8 20 01 00 00       	call   800319 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f9:	83 c4 08             	add    $0x8,%esp
  8001fc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800202:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800208:	50                   	push   %eax
  800209:	e8 83 09 00 00       	call   800b91 <sys_cputs>

	return b.cnt;
}
  80020e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800214:	c9                   	leave  
  800215:	c3                   	ret    

00800216 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800216:	f3 0f 1e fb          	endbr32 
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800220:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800223:	50                   	push   %eax
  800224:	ff 75 08             	pushl  0x8(%ebp)
  800227:	e8 95 ff ff ff       	call   8001c1 <vcprintf>
	va_end(ap);

	return cnt;
}
  80022c:	c9                   	leave  
  80022d:	c3                   	ret    

0080022e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	57                   	push   %edi
  800232:	56                   	push   %esi
  800233:	53                   	push   %ebx
  800234:	83 ec 1c             	sub    $0x1c,%esp
  800237:	89 c7                	mov    %eax,%edi
  800239:	89 d6                	mov    %edx,%esi
  80023b:	8b 45 08             	mov    0x8(%ebp),%eax
  80023e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800241:	89 d1                	mov    %edx,%ecx
  800243:	89 c2                	mov    %eax,%edx
  800245:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800248:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80024b:	8b 45 10             	mov    0x10(%ebp),%eax
  80024e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800251:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800254:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80025b:	39 c2                	cmp    %eax,%edx
  80025d:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800260:	72 3e                	jb     8002a0 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800262:	83 ec 0c             	sub    $0xc,%esp
  800265:	ff 75 18             	pushl  0x18(%ebp)
  800268:	83 eb 01             	sub    $0x1,%ebx
  80026b:	53                   	push   %ebx
  80026c:	50                   	push   %eax
  80026d:	83 ec 08             	sub    $0x8,%esp
  800270:	ff 75 e4             	pushl  -0x1c(%ebp)
  800273:	ff 75 e0             	pushl  -0x20(%ebp)
  800276:	ff 75 dc             	pushl  -0x24(%ebp)
  800279:	ff 75 d8             	pushl  -0x28(%ebp)
  80027c:	e8 1f 1b 00 00       	call   801da0 <__udivdi3>
  800281:	83 c4 18             	add    $0x18,%esp
  800284:	52                   	push   %edx
  800285:	50                   	push   %eax
  800286:	89 f2                	mov    %esi,%edx
  800288:	89 f8                	mov    %edi,%eax
  80028a:	e8 9f ff ff ff       	call   80022e <printnum>
  80028f:	83 c4 20             	add    $0x20,%esp
  800292:	eb 13                	jmp    8002a7 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	56                   	push   %esi
  800298:	ff 75 18             	pushl  0x18(%ebp)
  80029b:	ff d7                	call   *%edi
  80029d:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002a0:	83 eb 01             	sub    $0x1,%ebx
  8002a3:	85 db                	test   %ebx,%ebx
  8002a5:	7f ed                	jg     800294 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a7:	83 ec 08             	sub    $0x8,%esp
  8002aa:	56                   	push   %esi
  8002ab:	83 ec 04             	sub    $0x4,%esp
  8002ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ba:	e8 f1 1b 00 00       	call   801eb0 <__umoddi3>
  8002bf:	83 c4 14             	add    $0x14,%esp
  8002c2:	0f be 80 9b 20 80 00 	movsbl 0x80209b(%eax),%eax
  8002c9:	50                   	push   %eax
  8002ca:	ff d7                	call   *%edi
}
  8002cc:	83 c4 10             	add    $0x10,%esp
  8002cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d2:	5b                   	pop    %ebx
  8002d3:	5e                   	pop    %esi
  8002d4:	5f                   	pop    %edi
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    

008002d7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d7:	f3 0f 1e fb          	endbr32 
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e5:	8b 10                	mov    (%eax),%edx
  8002e7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ea:	73 0a                	jae    8002f6 <sprintputch+0x1f>
		*b->buf++ = ch;
  8002ec:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ef:	89 08                	mov    %ecx,(%eax)
  8002f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f4:	88 02                	mov    %al,(%edx)
}
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <printfmt>:
{
  8002f8:	f3 0f 1e fb          	endbr32 
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800302:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800305:	50                   	push   %eax
  800306:	ff 75 10             	pushl  0x10(%ebp)
  800309:	ff 75 0c             	pushl  0xc(%ebp)
  80030c:	ff 75 08             	pushl  0x8(%ebp)
  80030f:	e8 05 00 00 00       	call   800319 <vprintfmt>
}
  800314:	83 c4 10             	add    $0x10,%esp
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <vprintfmt>:
{
  800319:	f3 0f 1e fb          	endbr32 
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	57                   	push   %edi
  800321:	56                   	push   %esi
  800322:	53                   	push   %ebx
  800323:	83 ec 3c             	sub    $0x3c,%esp
  800326:	8b 75 08             	mov    0x8(%ebp),%esi
  800329:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80032f:	e9 4a 03 00 00       	jmp    80067e <vprintfmt+0x365>
		padc = ' ';
  800334:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800338:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80033f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800346:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80034d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8d 47 01             	lea    0x1(%edi),%eax
  800355:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800358:	0f b6 17             	movzbl (%edi),%edx
  80035b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80035e:	3c 55                	cmp    $0x55,%al
  800360:	0f 87 de 03 00 00    	ja     800744 <vprintfmt+0x42b>
  800366:	0f b6 c0             	movzbl %al,%eax
  800369:	3e ff 24 85 e0 21 80 	notrack jmp *0x8021e0(,%eax,4)
  800370:	00 
  800371:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800374:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800378:	eb d8                	jmp    800352 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800381:	eb cf                	jmp    800352 <vprintfmt+0x39>
  800383:	0f b6 d2             	movzbl %dl,%edx
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800389:	b8 00 00 00 00       	mov    $0x0,%eax
  80038e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800391:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800394:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800398:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80039b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80039e:	83 f9 09             	cmp    $0x9,%ecx
  8003a1:	77 55                	ja     8003f8 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003a3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003a6:	eb e9                	jmp    800391 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ab:	8b 00                	mov    (%eax),%eax
  8003ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 40 04             	lea    0x4(%eax),%eax
  8003b6:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003bc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c0:	79 90                	jns    800352 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003cf:	eb 81                	jmp    800352 <vprintfmt+0x39>
  8003d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d4:	85 c0                	test   %eax,%eax
  8003d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003db:	0f 49 d0             	cmovns %eax,%edx
  8003de:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003e4:	e9 69 ff ff ff       	jmp    800352 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003ec:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003f3:	e9 5a ff ff ff       	jmp    800352 <vprintfmt+0x39>
  8003f8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003fe:	eb bc                	jmp    8003bc <vprintfmt+0xa3>
			lflag++;
  800400:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800406:	e9 47 ff ff ff       	jmp    800352 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80040b:	8b 45 14             	mov    0x14(%ebp),%eax
  80040e:	8d 78 04             	lea    0x4(%eax),%edi
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	53                   	push   %ebx
  800415:	ff 30                	pushl  (%eax)
  800417:	ff d6                	call   *%esi
			break;
  800419:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80041c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80041f:	e9 57 02 00 00       	jmp    80067b <vprintfmt+0x362>
			err = va_arg(ap, int);
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	8d 78 04             	lea    0x4(%eax),%edi
  80042a:	8b 00                	mov    (%eax),%eax
  80042c:	99                   	cltd   
  80042d:	31 d0                	xor    %edx,%eax
  80042f:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800431:	83 f8 0f             	cmp    $0xf,%eax
  800434:	7f 23                	jg     800459 <vprintfmt+0x140>
  800436:	8b 14 85 40 23 80 00 	mov    0x802340(,%eax,4),%edx
  80043d:	85 d2                	test   %edx,%edx
  80043f:	74 18                	je     800459 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800441:	52                   	push   %edx
  800442:	68 d1 24 80 00       	push   $0x8024d1
  800447:	53                   	push   %ebx
  800448:	56                   	push   %esi
  800449:	e8 aa fe ff ff       	call   8002f8 <printfmt>
  80044e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800451:	89 7d 14             	mov    %edi,0x14(%ebp)
  800454:	e9 22 02 00 00       	jmp    80067b <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800459:	50                   	push   %eax
  80045a:	68 b3 20 80 00       	push   $0x8020b3
  80045f:	53                   	push   %ebx
  800460:	56                   	push   %esi
  800461:	e8 92 fe ff ff       	call   8002f8 <printfmt>
  800466:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800469:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80046c:	e9 0a 02 00 00       	jmp    80067b <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800471:	8b 45 14             	mov    0x14(%ebp),%eax
  800474:	83 c0 04             	add    $0x4,%eax
  800477:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80047a:	8b 45 14             	mov    0x14(%ebp),%eax
  80047d:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80047f:	85 d2                	test   %edx,%edx
  800481:	b8 ac 20 80 00       	mov    $0x8020ac,%eax
  800486:	0f 45 c2             	cmovne %edx,%eax
  800489:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80048c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800490:	7e 06                	jle    800498 <vprintfmt+0x17f>
  800492:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800496:	75 0d                	jne    8004a5 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800498:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80049b:	89 c7                	mov    %eax,%edi
  80049d:	03 45 e0             	add    -0x20(%ebp),%eax
  8004a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a3:	eb 55                	jmp    8004fa <vprintfmt+0x1e1>
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ab:	ff 75 cc             	pushl  -0x34(%ebp)
  8004ae:	e8 45 03 00 00       	call   8007f8 <strnlen>
  8004b3:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004b6:	29 c2                	sub    %eax,%edx
  8004b8:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004bb:	83 c4 10             	add    $0x10,%esp
  8004be:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004c0:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c7:	85 ff                	test   %edi,%edi
  8004c9:	7e 11                	jle    8004dc <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	53                   	push   %ebx
  8004cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d4:	83 ef 01             	sub    $0x1,%edi
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	eb eb                	jmp    8004c7 <vprintfmt+0x1ae>
  8004dc:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004df:	85 d2                	test   %edx,%edx
  8004e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e6:	0f 49 c2             	cmovns %edx,%eax
  8004e9:	29 c2                	sub    %eax,%edx
  8004eb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004ee:	eb a8                	jmp    800498 <vprintfmt+0x17f>
					putch(ch, putdat);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	53                   	push   %ebx
  8004f4:	52                   	push   %edx
  8004f5:	ff d6                	call   *%esi
  8004f7:	83 c4 10             	add    $0x10,%esp
  8004fa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004fd:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ff:	83 c7 01             	add    $0x1,%edi
  800502:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800506:	0f be d0             	movsbl %al,%edx
  800509:	85 d2                	test   %edx,%edx
  80050b:	74 4b                	je     800558 <vprintfmt+0x23f>
  80050d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800511:	78 06                	js     800519 <vprintfmt+0x200>
  800513:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800517:	78 1e                	js     800537 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800519:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80051d:	74 d1                	je     8004f0 <vprintfmt+0x1d7>
  80051f:	0f be c0             	movsbl %al,%eax
  800522:	83 e8 20             	sub    $0x20,%eax
  800525:	83 f8 5e             	cmp    $0x5e,%eax
  800528:	76 c6                	jbe    8004f0 <vprintfmt+0x1d7>
					putch('?', putdat);
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	53                   	push   %ebx
  80052e:	6a 3f                	push   $0x3f
  800530:	ff d6                	call   *%esi
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	eb c3                	jmp    8004fa <vprintfmt+0x1e1>
  800537:	89 cf                	mov    %ecx,%edi
  800539:	eb 0e                	jmp    800549 <vprintfmt+0x230>
				putch(' ', putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	53                   	push   %ebx
  80053f:	6a 20                	push   $0x20
  800541:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800543:	83 ef 01             	sub    $0x1,%edi
  800546:	83 c4 10             	add    $0x10,%esp
  800549:	85 ff                	test   %edi,%edi
  80054b:	7f ee                	jg     80053b <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80054d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800550:	89 45 14             	mov    %eax,0x14(%ebp)
  800553:	e9 23 01 00 00       	jmp    80067b <vprintfmt+0x362>
  800558:	89 cf                	mov    %ecx,%edi
  80055a:	eb ed                	jmp    800549 <vprintfmt+0x230>
	if (lflag >= 2)
  80055c:	83 f9 01             	cmp    $0x1,%ecx
  80055f:	7f 1b                	jg     80057c <vprintfmt+0x263>
	else if (lflag)
  800561:	85 c9                	test   %ecx,%ecx
  800563:	74 63                	je     8005c8 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8b 00                	mov    (%eax),%eax
  80056a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056d:	99                   	cltd   
  80056e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 40 04             	lea    0x4(%eax),%eax
  800577:	89 45 14             	mov    %eax,0x14(%ebp)
  80057a:	eb 17                	jmp    800593 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8b 50 04             	mov    0x4(%eax),%edx
  800582:	8b 00                	mov    (%eax),%eax
  800584:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800587:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	8d 40 08             	lea    0x8(%eax),%eax
  800590:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800593:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800596:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800599:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80059e:	85 c9                	test   %ecx,%ecx
  8005a0:	0f 89 bb 00 00 00    	jns    800661 <vprintfmt+0x348>
				putch('-', putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	53                   	push   %ebx
  8005aa:	6a 2d                	push   $0x2d
  8005ac:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ae:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005b4:	f7 da                	neg    %edx
  8005b6:	83 d1 00             	adc    $0x0,%ecx
  8005b9:	f7 d9                	neg    %ecx
  8005bb:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c3:	e9 99 00 00 00       	jmp    800661 <vprintfmt+0x348>
		return va_arg(*ap, int);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8b 00                	mov    (%eax),%eax
  8005cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d0:	99                   	cltd   
  8005d1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 40 04             	lea    0x4(%eax),%eax
  8005da:	89 45 14             	mov    %eax,0x14(%ebp)
  8005dd:	eb b4                	jmp    800593 <vprintfmt+0x27a>
	if (lflag >= 2)
  8005df:	83 f9 01             	cmp    $0x1,%ecx
  8005e2:	7f 1b                	jg     8005ff <vprintfmt+0x2e6>
	else if (lflag)
  8005e4:	85 c9                	test   %ecx,%ecx
  8005e6:	74 2c                	je     800614 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8b 10                	mov    (%eax),%edx
  8005ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f2:	8d 40 04             	lea    0x4(%eax),%eax
  8005f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f8:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005fd:	eb 62                	jmp    800661 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8b 10                	mov    (%eax),%edx
  800604:	8b 48 04             	mov    0x4(%eax),%ecx
  800607:	8d 40 08             	lea    0x8(%eax),%eax
  80060a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800612:	eb 4d                	jmp    800661 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8b 10                	mov    (%eax),%edx
  800619:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061e:	8d 40 04             	lea    0x4(%eax),%eax
  800621:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800624:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800629:	eb 36                	jmp    800661 <vprintfmt+0x348>
	if (lflag >= 2)
  80062b:	83 f9 01             	cmp    $0x1,%ecx
  80062e:	7f 17                	jg     800647 <vprintfmt+0x32e>
	else if (lflag)
  800630:	85 c9                	test   %ecx,%ecx
  800632:	74 6e                	je     8006a2 <vprintfmt+0x389>
		return va_arg(*ap, long);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8b 10                	mov    (%eax),%edx
  800639:	89 d0                	mov    %edx,%eax
  80063b:	99                   	cltd   
  80063c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80063f:	8d 49 04             	lea    0x4(%ecx),%ecx
  800642:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800645:	eb 11                	jmp    800658 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8b 50 04             	mov    0x4(%eax),%edx
  80064d:	8b 00                	mov    (%eax),%eax
  80064f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800652:	8d 49 08             	lea    0x8(%ecx),%ecx
  800655:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800658:	89 d1                	mov    %edx,%ecx
  80065a:	89 c2                	mov    %eax,%edx
            base = 8;
  80065c:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800661:	83 ec 0c             	sub    $0xc,%esp
  800664:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800668:	57                   	push   %edi
  800669:	ff 75 e0             	pushl  -0x20(%ebp)
  80066c:	50                   	push   %eax
  80066d:	51                   	push   %ecx
  80066e:	52                   	push   %edx
  80066f:	89 da                	mov    %ebx,%edx
  800671:	89 f0                	mov    %esi,%eax
  800673:	e8 b6 fb ff ff       	call   80022e <printnum>
			break;
  800678:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80067b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80067e:	83 c7 01             	add    $0x1,%edi
  800681:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800685:	83 f8 25             	cmp    $0x25,%eax
  800688:	0f 84 a6 fc ff ff    	je     800334 <vprintfmt+0x1b>
			if (ch == '\0')
  80068e:	85 c0                	test   %eax,%eax
  800690:	0f 84 ce 00 00 00    	je     800764 <vprintfmt+0x44b>
			putch(ch, putdat);
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	53                   	push   %ebx
  80069a:	50                   	push   %eax
  80069b:	ff d6                	call   *%esi
  80069d:	83 c4 10             	add    $0x10,%esp
  8006a0:	eb dc                	jmp    80067e <vprintfmt+0x365>
		return va_arg(*ap, int);
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8b 10                	mov    (%eax),%edx
  8006a7:	89 d0                	mov    %edx,%eax
  8006a9:	99                   	cltd   
  8006aa:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006ad:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006b0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006b3:	eb a3                	jmp    800658 <vprintfmt+0x33f>
			putch('0', putdat);
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	53                   	push   %ebx
  8006b9:	6a 30                	push   $0x30
  8006bb:	ff d6                	call   *%esi
			putch('x', putdat);
  8006bd:	83 c4 08             	add    $0x8,%esp
  8006c0:	53                   	push   %ebx
  8006c1:	6a 78                	push   $0x78
  8006c3:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8b 10                	mov    (%eax),%edx
  8006ca:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006cf:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006d2:	8d 40 04             	lea    0x4(%eax),%eax
  8006d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d8:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006dd:	eb 82                	jmp    800661 <vprintfmt+0x348>
	if (lflag >= 2)
  8006df:	83 f9 01             	cmp    $0x1,%ecx
  8006e2:	7f 1e                	jg     800702 <vprintfmt+0x3e9>
	else if (lflag)
  8006e4:	85 c9                	test   %ecx,%ecx
  8006e6:	74 32                	je     80071a <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8b 10                	mov    (%eax),%edx
  8006ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f2:	8d 40 04             	lea    0x4(%eax),%eax
  8006f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f8:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006fd:	e9 5f ff ff ff       	jmp    800661 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	8b 10                	mov    (%eax),%edx
  800707:	8b 48 04             	mov    0x4(%eax),%ecx
  80070a:	8d 40 08             	lea    0x8(%eax),%eax
  80070d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800710:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800715:	e9 47 ff ff ff       	jmp    800661 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8b 10                	mov    (%eax),%edx
  80071f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800724:	8d 40 04             	lea    0x4(%eax),%eax
  800727:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80072f:	e9 2d ff ff ff       	jmp    800661 <vprintfmt+0x348>
			putch(ch, putdat);
  800734:	83 ec 08             	sub    $0x8,%esp
  800737:	53                   	push   %ebx
  800738:	6a 25                	push   $0x25
  80073a:	ff d6                	call   *%esi
			break;
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	e9 37 ff ff ff       	jmp    80067b <vprintfmt+0x362>
			putch('%', putdat);
  800744:	83 ec 08             	sub    $0x8,%esp
  800747:	53                   	push   %ebx
  800748:	6a 25                	push   $0x25
  80074a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	89 f8                	mov    %edi,%eax
  800751:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800755:	74 05                	je     80075c <vprintfmt+0x443>
  800757:	83 e8 01             	sub    $0x1,%eax
  80075a:	eb f5                	jmp    800751 <vprintfmt+0x438>
  80075c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80075f:	e9 17 ff ff ff       	jmp    80067b <vprintfmt+0x362>
}
  800764:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800767:	5b                   	pop    %ebx
  800768:	5e                   	pop    %esi
  800769:	5f                   	pop    %edi
  80076a:	5d                   	pop    %ebp
  80076b:	c3                   	ret    

0080076c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80076c:	f3 0f 1e fb          	endbr32 
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	83 ec 18             	sub    $0x18,%esp
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800783:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800786:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078d:	85 c0                	test   %eax,%eax
  80078f:	74 26                	je     8007b7 <vsnprintf+0x4b>
  800791:	85 d2                	test   %edx,%edx
  800793:	7e 22                	jle    8007b7 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800795:	ff 75 14             	pushl  0x14(%ebp)
  800798:	ff 75 10             	pushl  0x10(%ebp)
  80079b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079e:	50                   	push   %eax
  80079f:	68 d7 02 80 00       	push   $0x8002d7
  8007a4:	e8 70 fb ff ff       	call   800319 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ac:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b2:	83 c4 10             	add    $0x10,%esp
}
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    
		return -E_INVAL;
  8007b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007bc:	eb f7                	jmp    8007b5 <vsnprintf+0x49>

008007be <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007be:	f3 0f 1e fb          	endbr32 
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007cb:	50                   	push   %eax
  8007cc:	ff 75 10             	pushl  0x10(%ebp)
  8007cf:	ff 75 0c             	pushl  0xc(%ebp)
  8007d2:	ff 75 08             	pushl  0x8(%ebp)
  8007d5:	e8 92 ff ff ff       	call   80076c <vsnprintf>
	va_end(ap);

	return rc;
}
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007dc:	f3 0f 1e fb          	endbr32 
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007eb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ef:	74 05                	je     8007f6 <strlen+0x1a>
		n++;
  8007f1:	83 c0 01             	add    $0x1,%eax
  8007f4:	eb f5                	jmp    8007eb <strlen+0xf>
	return n;
}
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f8:	f3 0f 1e fb          	endbr32 
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800802:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800805:	b8 00 00 00 00       	mov    $0x0,%eax
  80080a:	39 d0                	cmp    %edx,%eax
  80080c:	74 0d                	je     80081b <strnlen+0x23>
  80080e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800812:	74 05                	je     800819 <strnlen+0x21>
		n++;
  800814:	83 c0 01             	add    $0x1,%eax
  800817:	eb f1                	jmp    80080a <strnlen+0x12>
  800819:	89 c2                	mov    %eax,%edx
	return n;
}
  80081b:	89 d0                	mov    %edx,%eax
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081f:	f3 0f 1e fb          	endbr32 
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	53                   	push   %ebx
  800827:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80082d:	b8 00 00 00 00       	mov    $0x0,%eax
  800832:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800836:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800839:	83 c0 01             	add    $0x1,%eax
  80083c:	84 d2                	test   %dl,%dl
  80083e:	75 f2                	jne    800832 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800840:	89 c8                	mov    %ecx,%eax
  800842:	5b                   	pop    %ebx
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800845:	f3 0f 1e fb          	endbr32 
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	53                   	push   %ebx
  80084d:	83 ec 10             	sub    $0x10,%esp
  800850:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800853:	53                   	push   %ebx
  800854:	e8 83 ff ff ff       	call   8007dc <strlen>
  800859:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80085c:	ff 75 0c             	pushl  0xc(%ebp)
  80085f:	01 d8                	add    %ebx,%eax
  800861:	50                   	push   %eax
  800862:	e8 b8 ff ff ff       	call   80081f <strcpy>
	return dst;
}
  800867:	89 d8                	mov    %ebx,%eax
  800869:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086c:	c9                   	leave  
  80086d:	c3                   	ret    

0080086e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80086e:	f3 0f 1e fb          	endbr32 
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	56                   	push   %esi
  800876:	53                   	push   %ebx
  800877:	8b 75 08             	mov    0x8(%ebp),%esi
  80087a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087d:	89 f3                	mov    %esi,%ebx
  80087f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800882:	89 f0                	mov    %esi,%eax
  800884:	39 d8                	cmp    %ebx,%eax
  800886:	74 11                	je     800899 <strncpy+0x2b>
		*dst++ = *src;
  800888:	83 c0 01             	add    $0x1,%eax
  80088b:	0f b6 0a             	movzbl (%edx),%ecx
  80088e:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800891:	80 f9 01             	cmp    $0x1,%cl
  800894:	83 da ff             	sbb    $0xffffffff,%edx
  800897:	eb eb                	jmp    800884 <strncpy+0x16>
	}
	return ret;
}
  800899:	89 f0                	mov    %esi,%eax
  80089b:	5b                   	pop    %ebx
  80089c:	5e                   	pop    %esi
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80089f:	f3 0f 1e fb          	endbr32 
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	56                   	push   %esi
  8008a7:	53                   	push   %ebx
  8008a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ae:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b3:	85 d2                	test   %edx,%edx
  8008b5:	74 21                	je     8008d8 <strlcpy+0x39>
  8008b7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008bb:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008bd:	39 c2                	cmp    %eax,%edx
  8008bf:	74 14                	je     8008d5 <strlcpy+0x36>
  8008c1:	0f b6 19             	movzbl (%ecx),%ebx
  8008c4:	84 db                	test   %bl,%bl
  8008c6:	74 0b                	je     8008d3 <strlcpy+0x34>
			*dst++ = *src++;
  8008c8:	83 c1 01             	add    $0x1,%ecx
  8008cb:	83 c2 01             	add    $0x1,%edx
  8008ce:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008d1:	eb ea                	jmp    8008bd <strlcpy+0x1e>
  8008d3:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008d5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008d8:	29 f0                	sub    %esi,%eax
}
  8008da:	5b                   	pop    %ebx
  8008db:	5e                   	pop    %esi
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008de:	f3 0f 1e fb          	endbr32 
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008eb:	0f b6 01             	movzbl (%ecx),%eax
  8008ee:	84 c0                	test   %al,%al
  8008f0:	74 0c                	je     8008fe <strcmp+0x20>
  8008f2:	3a 02                	cmp    (%edx),%al
  8008f4:	75 08                	jne    8008fe <strcmp+0x20>
		p++, q++;
  8008f6:	83 c1 01             	add    $0x1,%ecx
  8008f9:	83 c2 01             	add    $0x1,%edx
  8008fc:	eb ed                	jmp    8008eb <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fe:	0f b6 c0             	movzbl %al,%eax
  800901:	0f b6 12             	movzbl (%edx),%edx
  800904:	29 d0                	sub    %edx,%eax
}
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800908:	f3 0f 1e fb          	endbr32 
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	53                   	push   %ebx
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	8b 55 0c             	mov    0xc(%ebp),%edx
  800916:	89 c3                	mov    %eax,%ebx
  800918:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80091b:	eb 06                	jmp    800923 <strncmp+0x1b>
		n--, p++, q++;
  80091d:	83 c0 01             	add    $0x1,%eax
  800920:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800923:	39 d8                	cmp    %ebx,%eax
  800925:	74 16                	je     80093d <strncmp+0x35>
  800927:	0f b6 08             	movzbl (%eax),%ecx
  80092a:	84 c9                	test   %cl,%cl
  80092c:	74 04                	je     800932 <strncmp+0x2a>
  80092e:	3a 0a                	cmp    (%edx),%cl
  800930:	74 eb                	je     80091d <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800932:	0f b6 00             	movzbl (%eax),%eax
  800935:	0f b6 12             	movzbl (%edx),%edx
  800938:	29 d0                	sub    %edx,%eax
}
  80093a:	5b                   	pop    %ebx
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    
		return 0;
  80093d:	b8 00 00 00 00       	mov    $0x0,%eax
  800942:	eb f6                	jmp    80093a <strncmp+0x32>

00800944 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800944:	f3 0f 1e fb          	endbr32 
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800952:	0f b6 10             	movzbl (%eax),%edx
  800955:	84 d2                	test   %dl,%dl
  800957:	74 09                	je     800962 <strchr+0x1e>
		if (*s == c)
  800959:	38 ca                	cmp    %cl,%dl
  80095b:	74 0a                	je     800967 <strchr+0x23>
	for (; *s; s++)
  80095d:	83 c0 01             	add    $0x1,%eax
  800960:	eb f0                	jmp    800952 <strchr+0xe>
			return (char *) s;
	return 0;
  800962:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800969:	f3 0f 1e fb          	endbr32 
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800977:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80097a:	38 ca                	cmp    %cl,%dl
  80097c:	74 09                	je     800987 <strfind+0x1e>
  80097e:	84 d2                	test   %dl,%dl
  800980:	74 05                	je     800987 <strfind+0x1e>
	for (; *s; s++)
  800982:	83 c0 01             	add    $0x1,%eax
  800985:	eb f0                	jmp    800977 <strfind+0xe>
			break;
	return (char *) s;
}
  800987:	5d                   	pop    %ebp
  800988:	c3                   	ret    

00800989 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800989:	f3 0f 1e fb          	endbr32 
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	57                   	push   %edi
  800991:	56                   	push   %esi
  800992:	53                   	push   %ebx
  800993:	8b 7d 08             	mov    0x8(%ebp),%edi
  800996:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800999:	85 c9                	test   %ecx,%ecx
  80099b:	74 31                	je     8009ce <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80099d:	89 f8                	mov    %edi,%eax
  80099f:	09 c8                	or     %ecx,%eax
  8009a1:	a8 03                	test   $0x3,%al
  8009a3:	75 23                	jne    8009c8 <memset+0x3f>
		c &= 0xFF;
  8009a5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a9:	89 d3                	mov    %edx,%ebx
  8009ab:	c1 e3 08             	shl    $0x8,%ebx
  8009ae:	89 d0                	mov    %edx,%eax
  8009b0:	c1 e0 18             	shl    $0x18,%eax
  8009b3:	89 d6                	mov    %edx,%esi
  8009b5:	c1 e6 10             	shl    $0x10,%esi
  8009b8:	09 f0                	or     %esi,%eax
  8009ba:	09 c2                	or     %eax,%edx
  8009bc:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009be:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009c1:	89 d0                	mov    %edx,%eax
  8009c3:	fc                   	cld    
  8009c4:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c6:	eb 06                	jmp    8009ce <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cb:	fc                   	cld    
  8009cc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ce:	89 f8                	mov    %edi,%eax
  8009d0:	5b                   	pop    %ebx
  8009d1:	5e                   	pop    %esi
  8009d2:	5f                   	pop    %edi
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d5:	f3 0f 1e fb          	endbr32 
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	57                   	push   %edi
  8009dd:	56                   	push   %esi
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e7:	39 c6                	cmp    %eax,%esi
  8009e9:	73 32                	jae    800a1d <memmove+0x48>
  8009eb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ee:	39 c2                	cmp    %eax,%edx
  8009f0:	76 2b                	jbe    800a1d <memmove+0x48>
		s += n;
		d += n;
  8009f2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f5:	89 fe                	mov    %edi,%esi
  8009f7:	09 ce                	or     %ecx,%esi
  8009f9:	09 d6                	or     %edx,%esi
  8009fb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a01:	75 0e                	jne    800a11 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a03:	83 ef 04             	sub    $0x4,%edi
  800a06:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a09:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a0c:	fd                   	std    
  800a0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0f:	eb 09                	jmp    800a1a <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a11:	83 ef 01             	sub    $0x1,%edi
  800a14:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a17:	fd                   	std    
  800a18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a1a:	fc                   	cld    
  800a1b:	eb 1a                	jmp    800a37 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1d:	89 c2                	mov    %eax,%edx
  800a1f:	09 ca                	or     %ecx,%edx
  800a21:	09 f2                	or     %esi,%edx
  800a23:	f6 c2 03             	test   $0x3,%dl
  800a26:	75 0a                	jne    800a32 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a28:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a2b:	89 c7                	mov    %eax,%edi
  800a2d:	fc                   	cld    
  800a2e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a30:	eb 05                	jmp    800a37 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a32:	89 c7                	mov    %eax,%edi
  800a34:	fc                   	cld    
  800a35:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a37:	5e                   	pop    %esi
  800a38:	5f                   	pop    %edi
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a3b:	f3 0f 1e fb          	endbr32 
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a45:	ff 75 10             	pushl  0x10(%ebp)
  800a48:	ff 75 0c             	pushl  0xc(%ebp)
  800a4b:	ff 75 08             	pushl  0x8(%ebp)
  800a4e:	e8 82 ff ff ff       	call   8009d5 <memmove>
}
  800a53:	c9                   	leave  
  800a54:	c3                   	ret    

00800a55 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a55:	f3 0f 1e fb          	endbr32 
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	56                   	push   %esi
  800a5d:	53                   	push   %ebx
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a64:	89 c6                	mov    %eax,%esi
  800a66:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a69:	39 f0                	cmp    %esi,%eax
  800a6b:	74 1c                	je     800a89 <memcmp+0x34>
		if (*s1 != *s2)
  800a6d:	0f b6 08             	movzbl (%eax),%ecx
  800a70:	0f b6 1a             	movzbl (%edx),%ebx
  800a73:	38 d9                	cmp    %bl,%cl
  800a75:	75 08                	jne    800a7f <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a77:	83 c0 01             	add    $0x1,%eax
  800a7a:	83 c2 01             	add    $0x1,%edx
  800a7d:	eb ea                	jmp    800a69 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a7f:	0f b6 c1             	movzbl %cl,%eax
  800a82:	0f b6 db             	movzbl %bl,%ebx
  800a85:	29 d8                	sub    %ebx,%eax
  800a87:	eb 05                	jmp    800a8e <memcmp+0x39>
	}

	return 0;
  800a89:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a8e:	5b                   	pop    %ebx
  800a8f:	5e                   	pop    %esi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a92:	f3 0f 1e fb          	endbr32 
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a9f:	89 c2                	mov    %eax,%edx
  800aa1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa4:	39 d0                	cmp    %edx,%eax
  800aa6:	73 09                	jae    800ab1 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa8:	38 08                	cmp    %cl,(%eax)
  800aaa:	74 05                	je     800ab1 <memfind+0x1f>
	for (; s < ends; s++)
  800aac:	83 c0 01             	add    $0x1,%eax
  800aaf:	eb f3                	jmp    800aa4 <memfind+0x12>
			break;
	return (void *) s;
}
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ab3:	f3 0f 1e fb          	endbr32 
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	57                   	push   %edi
  800abb:	56                   	push   %esi
  800abc:	53                   	push   %ebx
  800abd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac3:	eb 03                	jmp    800ac8 <strtol+0x15>
		s++;
  800ac5:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ac8:	0f b6 01             	movzbl (%ecx),%eax
  800acb:	3c 20                	cmp    $0x20,%al
  800acd:	74 f6                	je     800ac5 <strtol+0x12>
  800acf:	3c 09                	cmp    $0x9,%al
  800ad1:	74 f2                	je     800ac5 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ad3:	3c 2b                	cmp    $0x2b,%al
  800ad5:	74 2a                	je     800b01 <strtol+0x4e>
	int neg = 0;
  800ad7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800adc:	3c 2d                	cmp    $0x2d,%al
  800ade:	74 2b                	je     800b0b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae6:	75 0f                	jne    800af7 <strtol+0x44>
  800ae8:	80 39 30             	cmpb   $0x30,(%ecx)
  800aeb:	74 28                	je     800b15 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aed:	85 db                	test   %ebx,%ebx
  800aef:	b8 0a 00 00 00       	mov    $0xa,%eax
  800af4:	0f 44 d8             	cmove  %eax,%ebx
  800af7:	b8 00 00 00 00       	mov    $0x0,%eax
  800afc:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aff:	eb 46                	jmp    800b47 <strtol+0x94>
		s++;
  800b01:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b04:	bf 00 00 00 00       	mov    $0x0,%edi
  800b09:	eb d5                	jmp    800ae0 <strtol+0x2d>
		s++, neg = 1;
  800b0b:	83 c1 01             	add    $0x1,%ecx
  800b0e:	bf 01 00 00 00       	mov    $0x1,%edi
  800b13:	eb cb                	jmp    800ae0 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b15:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b19:	74 0e                	je     800b29 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b1b:	85 db                	test   %ebx,%ebx
  800b1d:	75 d8                	jne    800af7 <strtol+0x44>
		s++, base = 8;
  800b1f:	83 c1 01             	add    $0x1,%ecx
  800b22:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b27:	eb ce                	jmp    800af7 <strtol+0x44>
		s += 2, base = 16;
  800b29:	83 c1 02             	add    $0x2,%ecx
  800b2c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b31:	eb c4                	jmp    800af7 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b33:	0f be d2             	movsbl %dl,%edx
  800b36:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b39:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b3c:	7d 3a                	jge    800b78 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b3e:	83 c1 01             	add    $0x1,%ecx
  800b41:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b45:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b47:	0f b6 11             	movzbl (%ecx),%edx
  800b4a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b4d:	89 f3                	mov    %esi,%ebx
  800b4f:	80 fb 09             	cmp    $0x9,%bl
  800b52:	76 df                	jbe    800b33 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b54:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b57:	89 f3                	mov    %esi,%ebx
  800b59:	80 fb 19             	cmp    $0x19,%bl
  800b5c:	77 08                	ja     800b66 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b5e:	0f be d2             	movsbl %dl,%edx
  800b61:	83 ea 57             	sub    $0x57,%edx
  800b64:	eb d3                	jmp    800b39 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b66:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b69:	89 f3                	mov    %esi,%ebx
  800b6b:	80 fb 19             	cmp    $0x19,%bl
  800b6e:	77 08                	ja     800b78 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b70:	0f be d2             	movsbl %dl,%edx
  800b73:	83 ea 37             	sub    $0x37,%edx
  800b76:	eb c1                	jmp    800b39 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b78:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b7c:	74 05                	je     800b83 <strtol+0xd0>
		*endptr = (char *) s;
  800b7e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b81:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b83:	89 c2                	mov    %eax,%edx
  800b85:	f7 da                	neg    %edx
  800b87:	85 ff                	test   %edi,%edi
  800b89:	0f 45 c2             	cmovne %edx,%eax
}
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b91:	f3 0f 1e fb          	endbr32 
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	57                   	push   %edi
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba6:	89 c3                	mov    %eax,%ebx
  800ba8:	89 c7                	mov    %eax,%edi
  800baa:	89 c6                	mov    %eax,%esi
  800bac:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bb3:	f3 0f 1e fb          	endbr32 
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc2:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc7:	89 d1                	mov    %edx,%ecx
  800bc9:	89 d3                	mov    %edx,%ebx
  800bcb:	89 d7                	mov    %edx,%edi
  800bcd:	89 d6                	mov    %edx,%esi
  800bcf:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd6:	f3 0f 1e fb          	endbr32 
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800be3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf0:	89 cb                	mov    %ecx,%ebx
  800bf2:	89 cf                	mov    %ecx,%edi
  800bf4:	89 ce                	mov    %ecx,%esi
  800bf6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bf8:	85 c0                	test   %eax,%eax
  800bfa:	7f 08                	jg     800c04 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	50                   	push   %eax
  800c08:	6a 03                	push   $0x3
  800c0a:	68 9f 23 80 00       	push   $0x80239f
  800c0f:	6a 23                	push   $0x23
  800c11:	68 bc 23 80 00       	push   $0x8023bc
  800c16:	e8 14 f5 ff ff       	call   80012f <_panic>

00800c1b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c1b:	f3 0f 1e fb          	endbr32 
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c25:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c2f:	89 d1                	mov    %edx,%ecx
  800c31:	89 d3                	mov    %edx,%ebx
  800c33:	89 d7                	mov    %edx,%edi
  800c35:	89 d6                	mov    %edx,%esi
  800c37:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <sys_yield>:

void
sys_yield(void)
{
  800c3e:	f3 0f 1e fb          	endbr32 
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c48:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c52:	89 d1                	mov    %edx,%ecx
  800c54:	89 d3                	mov    %edx,%ebx
  800c56:	89 d7                	mov    %edx,%edi
  800c58:	89 d6                	mov    %edx,%esi
  800c5a:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c61:	f3 0f 1e fb          	endbr32 
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c6e:	be 00 00 00 00       	mov    $0x0,%esi
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c79:	b8 04 00 00 00       	mov    $0x4,%eax
  800c7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c81:	89 f7                	mov    %esi,%edi
  800c83:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c85:	85 c0                	test   %eax,%eax
  800c87:	7f 08                	jg     800c91 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c91:	83 ec 0c             	sub    $0xc,%esp
  800c94:	50                   	push   %eax
  800c95:	6a 04                	push   $0x4
  800c97:	68 9f 23 80 00       	push   $0x80239f
  800c9c:	6a 23                	push   $0x23
  800c9e:	68 bc 23 80 00       	push   $0x8023bc
  800ca3:	e8 87 f4 ff ff       	call   80012f <_panic>

00800ca8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca8:	f3 0f 1e fb          	endbr32 
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	53                   	push   %ebx
  800cb2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	b8 05 00 00 00       	mov    $0x5,%eax
  800cc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc6:	8b 75 18             	mov    0x18(%ebp),%esi
  800cc9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	7f 08                	jg     800cd7 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ccf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd7:	83 ec 0c             	sub    $0xc,%esp
  800cda:	50                   	push   %eax
  800cdb:	6a 05                	push   $0x5
  800cdd:	68 9f 23 80 00       	push   $0x80239f
  800ce2:	6a 23                	push   $0x23
  800ce4:	68 bc 23 80 00       	push   $0x8023bc
  800ce9:	e8 41 f4 ff ff       	call   80012f <_panic>

00800cee <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cee:	f3 0f 1e fb          	endbr32 
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	57                   	push   %edi
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
  800cf8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d06:	b8 06 00 00 00       	mov    $0x6,%eax
  800d0b:	89 df                	mov    %ebx,%edi
  800d0d:	89 de                	mov    %ebx,%esi
  800d0f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d11:	85 c0                	test   %eax,%eax
  800d13:	7f 08                	jg     800d1d <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1d:	83 ec 0c             	sub    $0xc,%esp
  800d20:	50                   	push   %eax
  800d21:	6a 06                	push   $0x6
  800d23:	68 9f 23 80 00       	push   $0x80239f
  800d28:	6a 23                	push   $0x23
  800d2a:	68 bc 23 80 00       	push   $0x8023bc
  800d2f:	e8 fb f3 ff ff       	call   80012f <_panic>

00800d34 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d34:	f3 0f 1e fb          	endbr32 
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	57                   	push   %edi
  800d3c:	56                   	push   %esi
  800d3d:	53                   	push   %ebx
  800d3e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d41:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4c:	b8 08 00 00 00       	mov    $0x8,%eax
  800d51:	89 df                	mov    %ebx,%edi
  800d53:	89 de                	mov    %ebx,%esi
  800d55:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d57:	85 c0                	test   %eax,%eax
  800d59:	7f 08                	jg     800d63 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	50                   	push   %eax
  800d67:	6a 08                	push   $0x8
  800d69:	68 9f 23 80 00       	push   $0x80239f
  800d6e:	6a 23                	push   $0x23
  800d70:	68 bc 23 80 00       	push   $0x8023bc
  800d75:	e8 b5 f3 ff ff       	call   80012f <_panic>

00800d7a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d7a:	f3 0f 1e fb          	endbr32 
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d87:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d92:	b8 09 00 00 00       	mov    $0x9,%eax
  800d97:	89 df                	mov    %ebx,%edi
  800d99:	89 de                	mov    %ebx,%esi
  800d9b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	7f 08                	jg     800da9 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800da1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da9:	83 ec 0c             	sub    $0xc,%esp
  800dac:	50                   	push   %eax
  800dad:	6a 09                	push   $0x9
  800daf:	68 9f 23 80 00       	push   $0x80239f
  800db4:	6a 23                	push   $0x23
  800db6:	68 bc 23 80 00       	push   $0x8023bc
  800dbb:	e8 6f f3 ff ff       	call   80012f <_panic>

00800dc0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dc0:	f3 0f 1e fb          	endbr32 
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dcd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ddd:	89 df                	mov    %ebx,%edi
  800ddf:	89 de                	mov    %ebx,%esi
  800de1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800de3:	85 c0                	test   %eax,%eax
  800de5:	7f 08                	jg     800def <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800de7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dea:	5b                   	pop    %ebx
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800def:	83 ec 0c             	sub    $0xc,%esp
  800df2:	50                   	push   %eax
  800df3:	6a 0a                	push   $0xa
  800df5:	68 9f 23 80 00       	push   $0x80239f
  800dfa:	6a 23                	push   $0x23
  800dfc:	68 bc 23 80 00       	push   $0x8023bc
  800e01:	e8 29 f3 ff ff       	call   80012f <_panic>

00800e06 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e06:	f3 0f 1e fb          	endbr32 
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e10:	8b 55 08             	mov    0x8(%ebp),%edx
  800e13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e16:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e1b:	be 00 00 00 00       	mov    $0x0,%esi
  800e20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e23:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e26:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e2d:	f3 0f 1e fb          	endbr32 
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	57                   	push   %edi
  800e35:	56                   	push   %esi
  800e36:	53                   	push   %ebx
  800e37:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e3a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e42:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e47:	89 cb                	mov    %ecx,%ebx
  800e49:	89 cf                	mov    %ecx,%edi
  800e4b:	89 ce                	mov    %ecx,%esi
  800e4d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	7f 08                	jg     800e5b <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e56:	5b                   	pop    %ebx
  800e57:	5e                   	pop    %esi
  800e58:	5f                   	pop    %edi
  800e59:	5d                   	pop    %ebp
  800e5a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5b:	83 ec 0c             	sub    $0xc,%esp
  800e5e:	50                   	push   %eax
  800e5f:	6a 0d                	push   $0xd
  800e61:	68 9f 23 80 00       	push   $0x80239f
  800e66:	6a 23                	push   $0x23
  800e68:	68 bc 23 80 00       	push   $0x8023bc
  800e6d:	e8 bd f2 ff ff       	call   80012f <_panic>

00800e72 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e72:	f3 0f 1e fb          	endbr32 
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e7c:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e83:	74 0a                	je     800e8f <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e85:	8b 45 08             	mov    0x8(%ebp),%eax
  800e88:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800e8d:	c9                   	leave  
  800e8e:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  800e8f:	83 ec 0c             	sub    $0xc,%esp
  800e92:	68 ca 23 80 00       	push   $0x8023ca
  800e97:	e8 7a f3 ff ff       	call   800216 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  800e9c:	83 c4 0c             	add    $0xc,%esp
  800e9f:	6a 07                	push   $0x7
  800ea1:	68 00 f0 bf ee       	push   $0xeebff000
  800ea6:	6a 00                	push   $0x0
  800ea8:	e8 b4 fd ff ff       	call   800c61 <sys_page_alloc>
  800ead:	83 c4 10             	add    $0x10,%esp
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	78 2a                	js     800ede <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  800eb4:	83 ec 08             	sub    $0x8,%esp
  800eb7:	68 f2 0e 80 00       	push   $0x800ef2
  800ebc:	6a 00                	push   $0x0
  800ebe:	e8 fd fe ff ff       	call   800dc0 <sys_env_set_pgfault_upcall>
  800ec3:	83 c4 10             	add    $0x10,%esp
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	79 bb                	jns    800e85 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  800eca:	83 ec 04             	sub    $0x4,%esp
  800ecd:	68 08 24 80 00       	push   $0x802408
  800ed2:	6a 25                	push   $0x25
  800ed4:	68 f7 23 80 00       	push   $0x8023f7
  800ed9:	e8 51 f2 ff ff       	call   80012f <_panic>
            panic("Allocation of UXSTACK failed!");
  800ede:	83 ec 04             	sub    $0x4,%esp
  800ee1:	68 d9 23 80 00       	push   $0x8023d9
  800ee6:	6a 22                	push   $0x22
  800ee8:	68 f7 23 80 00       	push   $0x8023f7
  800eed:	e8 3d f2 ff ff       	call   80012f <_panic>

00800ef2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ef2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800ef3:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800ef8:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800efa:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  800efd:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  800f01:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  800f05:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  800f08:	83 c4 08             	add    $0x8,%esp
    popa
  800f0b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  800f0c:	83 c4 04             	add    $0x4,%esp
    popf
  800f0f:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  800f10:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  800f13:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  800f17:	c3                   	ret    

00800f18 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f18:	f3 0f 1e fb          	endbr32 
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f22:	05 00 00 00 30       	add    $0x30000000,%eax
  800f27:	c1 e8 0c             	shr    $0xc,%eax
}
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f2c:	f3 0f 1e fb          	endbr32 
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f33:	8b 45 08             	mov    0x8(%ebp),%eax
  800f36:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800f3b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f40:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f45:	5d                   	pop    %ebp
  800f46:	c3                   	ret    

00800f47 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f47:	f3 0f 1e fb          	endbr32 
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f53:	89 c2                	mov    %eax,%edx
  800f55:	c1 ea 16             	shr    $0x16,%edx
  800f58:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f5f:	f6 c2 01             	test   $0x1,%dl
  800f62:	74 2d                	je     800f91 <fd_alloc+0x4a>
  800f64:	89 c2                	mov    %eax,%edx
  800f66:	c1 ea 0c             	shr    $0xc,%edx
  800f69:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f70:	f6 c2 01             	test   $0x1,%dl
  800f73:	74 1c                	je     800f91 <fd_alloc+0x4a>
  800f75:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800f7a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f7f:	75 d2                	jne    800f53 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f81:	8b 45 08             	mov    0x8(%ebp),%eax
  800f84:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800f8a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800f8f:	eb 0a                	jmp    800f9b <fd_alloc+0x54>
			*fd_store = fd;
  800f91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f94:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f96:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f9b:	5d                   	pop    %ebp
  800f9c:	c3                   	ret    

00800f9d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f9d:	f3 0f 1e fb          	endbr32 
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fa7:	83 f8 1f             	cmp    $0x1f,%eax
  800faa:	77 30                	ja     800fdc <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fac:	c1 e0 0c             	shl    $0xc,%eax
  800faf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fb4:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800fba:	f6 c2 01             	test   $0x1,%dl
  800fbd:	74 24                	je     800fe3 <fd_lookup+0x46>
  800fbf:	89 c2                	mov    %eax,%edx
  800fc1:	c1 ea 0c             	shr    $0xc,%edx
  800fc4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fcb:	f6 c2 01             	test   $0x1,%dl
  800fce:	74 1a                	je     800fea <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fd0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fd3:	89 02                	mov    %eax,(%edx)
	return 0;
  800fd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    
		return -E_INVAL;
  800fdc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fe1:	eb f7                	jmp    800fda <fd_lookup+0x3d>
		return -E_INVAL;
  800fe3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fe8:	eb f0                	jmp    800fda <fd_lookup+0x3d>
  800fea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fef:	eb e9                	jmp    800fda <fd_lookup+0x3d>

00800ff1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ff1:	f3 0f 1e fb          	endbr32 
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	83 ec 08             	sub    $0x8,%esp
  800ffb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ffe:	ba a8 24 80 00       	mov    $0x8024a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801003:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801008:	39 08                	cmp    %ecx,(%eax)
  80100a:	74 33                	je     80103f <dev_lookup+0x4e>
  80100c:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80100f:	8b 02                	mov    (%edx),%eax
  801011:	85 c0                	test   %eax,%eax
  801013:	75 f3                	jne    801008 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801015:	a1 04 40 80 00       	mov    0x804004,%eax
  80101a:	8b 40 48             	mov    0x48(%eax),%eax
  80101d:	83 ec 04             	sub    $0x4,%esp
  801020:	51                   	push   %ecx
  801021:	50                   	push   %eax
  801022:	68 2c 24 80 00       	push   $0x80242c
  801027:	e8 ea f1 ff ff       	call   800216 <cprintf>
	*dev = 0;
  80102c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80102f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801035:	83 c4 10             	add    $0x10,%esp
  801038:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80103d:	c9                   	leave  
  80103e:	c3                   	ret    
			*dev = devtab[i];
  80103f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801042:	89 01                	mov    %eax,(%ecx)
			return 0;
  801044:	b8 00 00 00 00       	mov    $0x0,%eax
  801049:	eb f2                	jmp    80103d <dev_lookup+0x4c>

0080104b <fd_close>:
{
  80104b:	f3 0f 1e fb          	endbr32 
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	57                   	push   %edi
  801053:	56                   	push   %esi
  801054:	53                   	push   %ebx
  801055:	83 ec 24             	sub    $0x24,%esp
  801058:	8b 75 08             	mov    0x8(%ebp),%esi
  80105b:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80105e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801061:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801062:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801068:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80106b:	50                   	push   %eax
  80106c:	e8 2c ff ff ff       	call   800f9d <fd_lookup>
  801071:	89 c3                	mov    %eax,%ebx
  801073:	83 c4 10             	add    $0x10,%esp
  801076:	85 c0                	test   %eax,%eax
  801078:	78 05                	js     80107f <fd_close+0x34>
	    || fd != fd2)
  80107a:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80107d:	74 16                	je     801095 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80107f:	89 f8                	mov    %edi,%eax
  801081:	84 c0                	test   %al,%al
  801083:	b8 00 00 00 00       	mov    $0x0,%eax
  801088:	0f 44 d8             	cmove  %eax,%ebx
}
  80108b:	89 d8                	mov    %ebx,%eax
  80108d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801095:	83 ec 08             	sub    $0x8,%esp
  801098:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80109b:	50                   	push   %eax
  80109c:	ff 36                	pushl  (%esi)
  80109e:	e8 4e ff ff ff       	call   800ff1 <dev_lookup>
  8010a3:	89 c3                	mov    %eax,%ebx
  8010a5:	83 c4 10             	add    $0x10,%esp
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	78 1a                	js     8010c6 <fd_close+0x7b>
		if (dev->dev_close)
  8010ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010af:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8010b2:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	74 0b                	je     8010c6 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8010bb:	83 ec 0c             	sub    $0xc,%esp
  8010be:	56                   	push   %esi
  8010bf:	ff d0                	call   *%eax
  8010c1:	89 c3                	mov    %eax,%ebx
  8010c3:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8010c6:	83 ec 08             	sub    $0x8,%esp
  8010c9:	56                   	push   %esi
  8010ca:	6a 00                	push   $0x0
  8010cc:	e8 1d fc ff ff       	call   800cee <sys_page_unmap>
	return r;
  8010d1:	83 c4 10             	add    $0x10,%esp
  8010d4:	eb b5                	jmp    80108b <fd_close+0x40>

008010d6 <close>:

int
close(int fdnum)
{
  8010d6:	f3 0f 1e fb          	endbr32 
  8010da:	55                   	push   %ebp
  8010db:	89 e5                	mov    %esp,%ebp
  8010dd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e3:	50                   	push   %eax
  8010e4:	ff 75 08             	pushl  0x8(%ebp)
  8010e7:	e8 b1 fe ff ff       	call   800f9d <fd_lookup>
  8010ec:	83 c4 10             	add    $0x10,%esp
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	79 02                	jns    8010f5 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8010f3:	c9                   	leave  
  8010f4:	c3                   	ret    
		return fd_close(fd, 1);
  8010f5:	83 ec 08             	sub    $0x8,%esp
  8010f8:	6a 01                	push   $0x1
  8010fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8010fd:	e8 49 ff ff ff       	call   80104b <fd_close>
  801102:	83 c4 10             	add    $0x10,%esp
  801105:	eb ec                	jmp    8010f3 <close+0x1d>

00801107 <close_all>:

void
close_all(void)
{
  801107:	f3 0f 1e fb          	endbr32 
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	53                   	push   %ebx
  80110f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801112:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	53                   	push   %ebx
  80111b:	e8 b6 ff ff ff       	call   8010d6 <close>
	for (i = 0; i < MAXFD; i++)
  801120:	83 c3 01             	add    $0x1,%ebx
  801123:	83 c4 10             	add    $0x10,%esp
  801126:	83 fb 20             	cmp    $0x20,%ebx
  801129:	75 ec                	jne    801117 <close_all+0x10>
}
  80112b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80112e:	c9                   	leave  
  80112f:	c3                   	ret    

00801130 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801130:	f3 0f 1e fb          	endbr32 
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	57                   	push   %edi
  801138:	56                   	push   %esi
  801139:	53                   	push   %ebx
  80113a:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80113d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801140:	50                   	push   %eax
  801141:	ff 75 08             	pushl  0x8(%ebp)
  801144:	e8 54 fe ff ff       	call   800f9d <fd_lookup>
  801149:	89 c3                	mov    %eax,%ebx
  80114b:	83 c4 10             	add    $0x10,%esp
  80114e:	85 c0                	test   %eax,%eax
  801150:	0f 88 81 00 00 00    	js     8011d7 <dup+0xa7>
		return r;
	close(newfdnum);
  801156:	83 ec 0c             	sub    $0xc,%esp
  801159:	ff 75 0c             	pushl  0xc(%ebp)
  80115c:	e8 75 ff ff ff       	call   8010d6 <close>

	newfd = INDEX2FD(newfdnum);
  801161:	8b 75 0c             	mov    0xc(%ebp),%esi
  801164:	c1 e6 0c             	shl    $0xc,%esi
  801167:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80116d:	83 c4 04             	add    $0x4,%esp
  801170:	ff 75 e4             	pushl  -0x1c(%ebp)
  801173:	e8 b4 fd ff ff       	call   800f2c <fd2data>
  801178:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80117a:	89 34 24             	mov    %esi,(%esp)
  80117d:	e8 aa fd ff ff       	call   800f2c <fd2data>
  801182:	83 c4 10             	add    $0x10,%esp
  801185:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801187:	89 d8                	mov    %ebx,%eax
  801189:	c1 e8 16             	shr    $0x16,%eax
  80118c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801193:	a8 01                	test   $0x1,%al
  801195:	74 11                	je     8011a8 <dup+0x78>
  801197:	89 d8                	mov    %ebx,%eax
  801199:	c1 e8 0c             	shr    $0xc,%eax
  80119c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011a3:	f6 c2 01             	test   $0x1,%dl
  8011a6:	75 39                	jne    8011e1 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011ab:	89 d0                	mov    %edx,%eax
  8011ad:	c1 e8 0c             	shr    $0xc,%eax
  8011b0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b7:	83 ec 0c             	sub    $0xc,%esp
  8011ba:	25 07 0e 00 00       	and    $0xe07,%eax
  8011bf:	50                   	push   %eax
  8011c0:	56                   	push   %esi
  8011c1:	6a 00                	push   $0x0
  8011c3:	52                   	push   %edx
  8011c4:	6a 00                	push   $0x0
  8011c6:	e8 dd fa ff ff       	call   800ca8 <sys_page_map>
  8011cb:	89 c3                	mov    %eax,%ebx
  8011cd:	83 c4 20             	add    $0x20,%esp
  8011d0:	85 c0                	test   %eax,%eax
  8011d2:	78 31                	js     801205 <dup+0xd5>
		goto err;

	return newfdnum;
  8011d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011d7:	89 d8                	mov    %ebx,%eax
  8011d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011dc:	5b                   	pop    %ebx
  8011dd:	5e                   	pop    %esi
  8011de:	5f                   	pop    %edi
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011e1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011e8:	83 ec 0c             	sub    $0xc,%esp
  8011eb:	25 07 0e 00 00       	and    $0xe07,%eax
  8011f0:	50                   	push   %eax
  8011f1:	57                   	push   %edi
  8011f2:	6a 00                	push   $0x0
  8011f4:	53                   	push   %ebx
  8011f5:	6a 00                	push   $0x0
  8011f7:	e8 ac fa ff ff       	call   800ca8 <sys_page_map>
  8011fc:	89 c3                	mov    %eax,%ebx
  8011fe:	83 c4 20             	add    $0x20,%esp
  801201:	85 c0                	test   %eax,%eax
  801203:	79 a3                	jns    8011a8 <dup+0x78>
	sys_page_unmap(0, newfd);
  801205:	83 ec 08             	sub    $0x8,%esp
  801208:	56                   	push   %esi
  801209:	6a 00                	push   $0x0
  80120b:	e8 de fa ff ff       	call   800cee <sys_page_unmap>
	sys_page_unmap(0, nva);
  801210:	83 c4 08             	add    $0x8,%esp
  801213:	57                   	push   %edi
  801214:	6a 00                	push   $0x0
  801216:	e8 d3 fa ff ff       	call   800cee <sys_page_unmap>
	return r;
  80121b:	83 c4 10             	add    $0x10,%esp
  80121e:	eb b7                	jmp    8011d7 <dup+0xa7>

00801220 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801220:	f3 0f 1e fb          	endbr32 
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	53                   	push   %ebx
  801228:	83 ec 1c             	sub    $0x1c,%esp
  80122b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80122e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801231:	50                   	push   %eax
  801232:	53                   	push   %ebx
  801233:	e8 65 fd ff ff       	call   800f9d <fd_lookup>
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	85 c0                	test   %eax,%eax
  80123d:	78 3f                	js     80127e <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123f:	83 ec 08             	sub    $0x8,%esp
  801242:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801245:	50                   	push   %eax
  801246:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801249:	ff 30                	pushl  (%eax)
  80124b:	e8 a1 fd ff ff       	call   800ff1 <dev_lookup>
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	85 c0                	test   %eax,%eax
  801255:	78 27                	js     80127e <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801257:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80125a:	8b 42 08             	mov    0x8(%edx),%eax
  80125d:	83 e0 03             	and    $0x3,%eax
  801260:	83 f8 01             	cmp    $0x1,%eax
  801263:	74 1e                	je     801283 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801265:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801268:	8b 40 08             	mov    0x8(%eax),%eax
  80126b:	85 c0                	test   %eax,%eax
  80126d:	74 35                	je     8012a4 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80126f:	83 ec 04             	sub    $0x4,%esp
  801272:	ff 75 10             	pushl  0x10(%ebp)
  801275:	ff 75 0c             	pushl  0xc(%ebp)
  801278:	52                   	push   %edx
  801279:	ff d0                	call   *%eax
  80127b:	83 c4 10             	add    $0x10,%esp
}
  80127e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801281:	c9                   	leave  
  801282:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801283:	a1 04 40 80 00       	mov    0x804004,%eax
  801288:	8b 40 48             	mov    0x48(%eax),%eax
  80128b:	83 ec 04             	sub    $0x4,%esp
  80128e:	53                   	push   %ebx
  80128f:	50                   	push   %eax
  801290:	68 6d 24 80 00       	push   $0x80246d
  801295:	e8 7c ef ff ff       	call   800216 <cprintf>
		return -E_INVAL;
  80129a:	83 c4 10             	add    $0x10,%esp
  80129d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a2:	eb da                	jmp    80127e <read+0x5e>
		return -E_NOT_SUPP;
  8012a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012a9:	eb d3                	jmp    80127e <read+0x5e>

008012ab <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012ab:	f3 0f 1e fb          	endbr32 
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	57                   	push   %edi
  8012b3:	56                   	push   %esi
  8012b4:	53                   	push   %ebx
  8012b5:	83 ec 0c             	sub    $0xc,%esp
  8012b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012bb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012c3:	eb 02                	jmp    8012c7 <readn+0x1c>
  8012c5:	01 c3                	add    %eax,%ebx
  8012c7:	39 f3                	cmp    %esi,%ebx
  8012c9:	73 21                	jae    8012ec <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012cb:	83 ec 04             	sub    $0x4,%esp
  8012ce:	89 f0                	mov    %esi,%eax
  8012d0:	29 d8                	sub    %ebx,%eax
  8012d2:	50                   	push   %eax
  8012d3:	89 d8                	mov    %ebx,%eax
  8012d5:	03 45 0c             	add    0xc(%ebp),%eax
  8012d8:	50                   	push   %eax
  8012d9:	57                   	push   %edi
  8012da:	e8 41 ff ff ff       	call   801220 <read>
		if (m < 0)
  8012df:	83 c4 10             	add    $0x10,%esp
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	78 04                	js     8012ea <readn+0x3f>
			return m;
		if (m == 0)
  8012e6:	75 dd                	jne    8012c5 <readn+0x1a>
  8012e8:	eb 02                	jmp    8012ec <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012ea:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8012ec:	89 d8                	mov    %ebx,%eax
  8012ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f1:	5b                   	pop    %ebx
  8012f2:	5e                   	pop    %esi
  8012f3:	5f                   	pop    %edi
  8012f4:	5d                   	pop    %ebp
  8012f5:	c3                   	ret    

008012f6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012f6:	f3 0f 1e fb          	endbr32 
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	53                   	push   %ebx
  8012fe:	83 ec 1c             	sub    $0x1c,%esp
  801301:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801304:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801307:	50                   	push   %eax
  801308:	53                   	push   %ebx
  801309:	e8 8f fc ff ff       	call   800f9d <fd_lookup>
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	85 c0                	test   %eax,%eax
  801313:	78 3a                	js     80134f <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801315:	83 ec 08             	sub    $0x8,%esp
  801318:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131b:	50                   	push   %eax
  80131c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131f:	ff 30                	pushl  (%eax)
  801321:	e8 cb fc ff ff       	call   800ff1 <dev_lookup>
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	85 c0                	test   %eax,%eax
  80132b:	78 22                	js     80134f <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80132d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801330:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801334:	74 1e                	je     801354 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801336:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801339:	8b 52 0c             	mov    0xc(%edx),%edx
  80133c:	85 d2                	test   %edx,%edx
  80133e:	74 35                	je     801375 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801340:	83 ec 04             	sub    $0x4,%esp
  801343:	ff 75 10             	pushl  0x10(%ebp)
  801346:	ff 75 0c             	pushl  0xc(%ebp)
  801349:	50                   	push   %eax
  80134a:	ff d2                	call   *%edx
  80134c:	83 c4 10             	add    $0x10,%esp
}
  80134f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801352:	c9                   	leave  
  801353:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801354:	a1 04 40 80 00       	mov    0x804004,%eax
  801359:	8b 40 48             	mov    0x48(%eax),%eax
  80135c:	83 ec 04             	sub    $0x4,%esp
  80135f:	53                   	push   %ebx
  801360:	50                   	push   %eax
  801361:	68 89 24 80 00       	push   $0x802489
  801366:	e8 ab ee ff ff       	call   800216 <cprintf>
		return -E_INVAL;
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801373:	eb da                	jmp    80134f <write+0x59>
		return -E_NOT_SUPP;
  801375:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80137a:	eb d3                	jmp    80134f <write+0x59>

0080137c <seek>:

int
seek(int fdnum, off_t offset)
{
  80137c:	f3 0f 1e fb          	endbr32 
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801386:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801389:	50                   	push   %eax
  80138a:	ff 75 08             	pushl  0x8(%ebp)
  80138d:	e8 0b fc ff ff       	call   800f9d <fd_lookup>
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	85 c0                	test   %eax,%eax
  801397:	78 0e                	js     8013a7 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801399:	8b 55 0c             	mov    0xc(%ebp),%edx
  80139c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013a7:	c9                   	leave  
  8013a8:	c3                   	ret    

008013a9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013a9:	f3 0f 1e fb          	endbr32 
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	53                   	push   %ebx
  8013b1:	83 ec 1c             	sub    $0x1c,%esp
  8013b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ba:	50                   	push   %eax
  8013bb:	53                   	push   %ebx
  8013bc:	e8 dc fb ff ff       	call   800f9d <fd_lookup>
  8013c1:	83 c4 10             	add    $0x10,%esp
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	78 37                	js     8013ff <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c8:	83 ec 08             	sub    $0x8,%esp
  8013cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ce:	50                   	push   %eax
  8013cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d2:	ff 30                	pushl  (%eax)
  8013d4:	e8 18 fc ff ff       	call   800ff1 <dev_lookup>
  8013d9:	83 c4 10             	add    $0x10,%esp
  8013dc:	85 c0                	test   %eax,%eax
  8013de:	78 1f                	js     8013ff <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013e7:	74 1b                	je     801404 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8013e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013ec:	8b 52 18             	mov    0x18(%edx),%edx
  8013ef:	85 d2                	test   %edx,%edx
  8013f1:	74 32                	je     801425 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013f3:	83 ec 08             	sub    $0x8,%esp
  8013f6:	ff 75 0c             	pushl  0xc(%ebp)
  8013f9:	50                   	push   %eax
  8013fa:	ff d2                	call   *%edx
  8013fc:	83 c4 10             	add    $0x10,%esp
}
  8013ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801402:	c9                   	leave  
  801403:	c3                   	ret    
			thisenv->env_id, fdnum);
  801404:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801409:	8b 40 48             	mov    0x48(%eax),%eax
  80140c:	83 ec 04             	sub    $0x4,%esp
  80140f:	53                   	push   %ebx
  801410:	50                   	push   %eax
  801411:	68 4c 24 80 00       	push   $0x80244c
  801416:	e8 fb ed ff ff       	call   800216 <cprintf>
		return -E_INVAL;
  80141b:	83 c4 10             	add    $0x10,%esp
  80141e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801423:	eb da                	jmp    8013ff <ftruncate+0x56>
		return -E_NOT_SUPP;
  801425:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80142a:	eb d3                	jmp    8013ff <ftruncate+0x56>

0080142c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80142c:	f3 0f 1e fb          	endbr32 
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	53                   	push   %ebx
  801434:	83 ec 1c             	sub    $0x1c,%esp
  801437:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80143a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80143d:	50                   	push   %eax
  80143e:	ff 75 08             	pushl  0x8(%ebp)
  801441:	e8 57 fb ff ff       	call   800f9d <fd_lookup>
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 4b                	js     801498 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144d:	83 ec 08             	sub    $0x8,%esp
  801450:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801453:	50                   	push   %eax
  801454:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801457:	ff 30                	pushl  (%eax)
  801459:	e8 93 fb ff ff       	call   800ff1 <dev_lookup>
  80145e:	83 c4 10             	add    $0x10,%esp
  801461:	85 c0                	test   %eax,%eax
  801463:	78 33                	js     801498 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801465:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801468:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80146c:	74 2f                	je     80149d <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80146e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801471:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801478:	00 00 00 
	stat->st_isdir = 0;
  80147b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801482:	00 00 00 
	stat->st_dev = dev;
  801485:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80148b:	83 ec 08             	sub    $0x8,%esp
  80148e:	53                   	push   %ebx
  80148f:	ff 75 f0             	pushl  -0x10(%ebp)
  801492:	ff 50 14             	call   *0x14(%eax)
  801495:	83 c4 10             	add    $0x10,%esp
}
  801498:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149b:	c9                   	leave  
  80149c:	c3                   	ret    
		return -E_NOT_SUPP;
  80149d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014a2:	eb f4                	jmp    801498 <fstat+0x6c>

008014a4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014a4:	f3 0f 1e fb          	endbr32 
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	56                   	push   %esi
  8014ac:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014ad:	83 ec 08             	sub    $0x8,%esp
  8014b0:	6a 00                	push   $0x0
  8014b2:	ff 75 08             	pushl  0x8(%ebp)
  8014b5:	e8 fb 01 00 00       	call   8016b5 <open>
  8014ba:	89 c3                	mov    %eax,%ebx
  8014bc:	83 c4 10             	add    $0x10,%esp
  8014bf:	85 c0                	test   %eax,%eax
  8014c1:	78 1b                	js     8014de <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8014c3:	83 ec 08             	sub    $0x8,%esp
  8014c6:	ff 75 0c             	pushl  0xc(%ebp)
  8014c9:	50                   	push   %eax
  8014ca:	e8 5d ff ff ff       	call   80142c <fstat>
  8014cf:	89 c6                	mov    %eax,%esi
	close(fd);
  8014d1:	89 1c 24             	mov    %ebx,(%esp)
  8014d4:	e8 fd fb ff ff       	call   8010d6 <close>
	return r;
  8014d9:	83 c4 10             	add    $0x10,%esp
  8014dc:	89 f3                	mov    %esi,%ebx
}
  8014de:	89 d8                	mov    %ebx,%eax
  8014e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014e3:	5b                   	pop    %ebx
  8014e4:	5e                   	pop    %esi
  8014e5:	5d                   	pop    %ebp
  8014e6:	c3                   	ret    

008014e7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	56                   	push   %esi
  8014eb:	53                   	push   %ebx
  8014ec:	89 c6                	mov    %eax,%esi
  8014ee:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014f0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014f7:	74 27                	je     801520 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014f9:	6a 07                	push   $0x7
  8014fb:	68 00 50 80 00       	push   $0x805000
  801500:	56                   	push   %esi
  801501:	ff 35 00 40 80 00    	pushl  0x804000
  801507:	e8 a8 07 00 00       	call   801cb4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80150c:	83 c4 0c             	add    $0xc,%esp
  80150f:	6a 00                	push   $0x0
  801511:	53                   	push   %ebx
  801512:	6a 00                	push   $0x0
  801514:	e8 44 07 00 00       	call   801c5d <ipc_recv>
}
  801519:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80151c:	5b                   	pop    %ebx
  80151d:	5e                   	pop    %esi
  80151e:	5d                   	pop    %ebp
  80151f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801520:	83 ec 0c             	sub    $0xc,%esp
  801523:	6a 01                	push   $0x1
  801525:	e8 f0 07 00 00       	call   801d1a <ipc_find_env>
  80152a:	a3 00 40 80 00       	mov    %eax,0x804000
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	eb c5                	jmp    8014f9 <fsipc+0x12>

00801534 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801534:	f3 0f 1e fb          	endbr32 
  801538:	55                   	push   %ebp
  801539:	89 e5                	mov    %esp,%ebp
  80153b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80153e:	8b 45 08             	mov    0x8(%ebp),%eax
  801541:	8b 40 0c             	mov    0xc(%eax),%eax
  801544:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801549:	8b 45 0c             	mov    0xc(%ebp),%eax
  80154c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801551:	ba 00 00 00 00       	mov    $0x0,%edx
  801556:	b8 02 00 00 00       	mov    $0x2,%eax
  80155b:	e8 87 ff ff ff       	call   8014e7 <fsipc>
}
  801560:	c9                   	leave  
  801561:	c3                   	ret    

00801562 <devfile_flush>:
{
  801562:	f3 0f 1e fb          	endbr32 
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80156c:	8b 45 08             	mov    0x8(%ebp),%eax
  80156f:	8b 40 0c             	mov    0xc(%eax),%eax
  801572:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801577:	ba 00 00 00 00       	mov    $0x0,%edx
  80157c:	b8 06 00 00 00       	mov    $0x6,%eax
  801581:	e8 61 ff ff ff       	call   8014e7 <fsipc>
}
  801586:	c9                   	leave  
  801587:	c3                   	ret    

00801588 <devfile_stat>:
{
  801588:	f3 0f 1e fb          	endbr32 
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	53                   	push   %ebx
  801590:	83 ec 04             	sub    $0x4,%esp
  801593:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801596:	8b 45 08             	mov    0x8(%ebp),%eax
  801599:	8b 40 0c             	mov    0xc(%eax),%eax
  80159c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8015ab:	e8 37 ff ff ff       	call   8014e7 <fsipc>
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	78 2c                	js     8015e0 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015b4:	83 ec 08             	sub    $0x8,%esp
  8015b7:	68 00 50 80 00       	push   $0x805000
  8015bc:	53                   	push   %ebx
  8015bd:	e8 5d f2 ff ff       	call   80081f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015c2:	a1 80 50 80 00       	mov    0x805080,%eax
  8015c7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015cd:	a1 84 50 80 00       	mov    0x805084,%eax
  8015d2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e3:	c9                   	leave  
  8015e4:	c3                   	ret    

008015e5 <devfile_write>:
{
  8015e5:	f3 0f 1e fb          	endbr32 
  8015e9:	55                   	push   %ebp
  8015ea:	89 e5                	mov    %esp,%ebp
  8015ec:	83 ec 0c             	sub    $0xc,%esp
  8015ef:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  8015f2:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015f7:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8015fc:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801602:	8b 52 0c             	mov    0xc(%edx),%edx
  801605:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80160b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801610:	50                   	push   %eax
  801611:	ff 75 0c             	pushl  0xc(%ebp)
  801614:	68 08 50 80 00       	push   $0x805008
  801619:	e8 b7 f3 ff ff       	call   8009d5 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80161e:	ba 00 00 00 00       	mov    $0x0,%edx
  801623:	b8 04 00 00 00       	mov    $0x4,%eax
  801628:	e8 ba fe ff ff       	call   8014e7 <fsipc>
}
  80162d:	c9                   	leave  
  80162e:	c3                   	ret    

0080162f <devfile_read>:
{
  80162f:	f3 0f 1e fb          	endbr32 
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	56                   	push   %esi
  801637:	53                   	push   %ebx
  801638:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80163b:	8b 45 08             	mov    0x8(%ebp),%eax
  80163e:	8b 40 0c             	mov    0xc(%eax),%eax
  801641:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801646:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80164c:	ba 00 00 00 00       	mov    $0x0,%edx
  801651:	b8 03 00 00 00       	mov    $0x3,%eax
  801656:	e8 8c fe ff ff       	call   8014e7 <fsipc>
  80165b:	89 c3                	mov    %eax,%ebx
  80165d:	85 c0                	test   %eax,%eax
  80165f:	78 1f                	js     801680 <devfile_read+0x51>
	assert(r <= n);
  801661:	39 f0                	cmp    %esi,%eax
  801663:	77 24                	ja     801689 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801665:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80166a:	7f 33                	jg     80169f <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80166c:	83 ec 04             	sub    $0x4,%esp
  80166f:	50                   	push   %eax
  801670:	68 00 50 80 00       	push   $0x805000
  801675:	ff 75 0c             	pushl  0xc(%ebp)
  801678:	e8 58 f3 ff ff       	call   8009d5 <memmove>
	return r;
  80167d:	83 c4 10             	add    $0x10,%esp
}
  801680:	89 d8                	mov    %ebx,%eax
  801682:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801685:	5b                   	pop    %ebx
  801686:	5e                   	pop    %esi
  801687:	5d                   	pop    %ebp
  801688:	c3                   	ret    
	assert(r <= n);
  801689:	68 b8 24 80 00       	push   $0x8024b8
  80168e:	68 bf 24 80 00       	push   $0x8024bf
  801693:	6a 7c                	push   $0x7c
  801695:	68 d4 24 80 00       	push   $0x8024d4
  80169a:	e8 90 ea ff ff       	call   80012f <_panic>
	assert(r <= PGSIZE);
  80169f:	68 df 24 80 00       	push   $0x8024df
  8016a4:	68 bf 24 80 00       	push   $0x8024bf
  8016a9:	6a 7d                	push   $0x7d
  8016ab:	68 d4 24 80 00       	push   $0x8024d4
  8016b0:	e8 7a ea ff ff       	call   80012f <_panic>

008016b5 <open>:
{
  8016b5:	f3 0f 1e fb          	endbr32 
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	56                   	push   %esi
  8016bd:	53                   	push   %ebx
  8016be:	83 ec 1c             	sub    $0x1c,%esp
  8016c1:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8016c4:	56                   	push   %esi
  8016c5:	e8 12 f1 ff ff       	call   8007dc <strlen>
  8016ca:	83 c4 10             	add    $0x10,%esp
  8016cd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016d2:	7f 6c                	jg     801740 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8016d4:	83 ec 0c             	sub    $0xc,%esp
  8016d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016da:	50                   	push   %eax
  8016db:	e8 67 f8 ff ff       	call   800f47 <fd_alloc>
  8016e0:	89 c3                	mov    %eax,%ebx
  8016e2:	83 c4 10             	add    $0x10,%esp
  8016e5:	85 c0                	test   %eax,%eax
  8016e7:	78 3c                	js     801725 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8016e9:	83 ec 08             	sub    $0x8,%esp
  8016ec:	56                   	push   %esi
  8016ed:	68 00 50 80 00       	push   $0x805000
  8016f2:	e8 28 f1 ff ff       	call   80081f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016fa:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801702:	b8 01 00 00 00       	mov    $0x1,%eax
  801707:	e8 db fd ff ff       	call   8014e7 <fsipc>
  80170c:	89 c3                	mov    %eax,%ebx
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	85 c0                	test   %eax,%eax
  801713:	78 19                	js     80172e <open+0x79>
	return fd2num(fd);
  801715:	83 ec 0c             	sub    $0xc,%esp
  801718:	ff 75 f4             	pushl  -0xc(%ebp)
  80171b:	e8 f8 f7 ff ff       	call   800f18 <fd2num>
  801720:	89 c3                	mov    %eax,%ebx
  801722:	83 c4 10             	add    $0x10,%esp
}
  801725:	89 d8                	mov    %ebx,%eax
  801727:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172a:	5b                   	pop    %ebx
  80172b:	5e                   	pop    %esi
  80172c:	5d                   	pop    %ebp
  80172d:	c3                   	ret    
		fd_close(fd, 0);
  80172e:	83 ec 08             	sub    $0x8,%esp
  801731:	6a 00                	push   $0x0
  801733:	ff 75 f4             	pushl  -0xc(%ebp)
  801736:	e8 10 f9 ff ff       	call   80104b <fd_close>
		return r;
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	eb e5                	jmp    801725 <open+0x70>
		return -E_BAD_PATH;
  801740:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801745:	eb de                	jmp    801725 <open+0x70>

00801747 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801747:	f3 0f 1e fb          	endbr32 
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
  80174e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801751:	ba 00 00 00 00       	mov    $0x0,%edx
  801756:	b8 08 00 00 00       	mov    $0x8,%eax
  80175b:	e8 87 fd ff ff       	call   8014e7 <fsipc>
}
  801760:	c9                   	leave  
  801761:	c3                   	ret    

00801762 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801762:	f3 0f 1e fb          	endbr32 
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	56                   	push   %esi
  80176a:	53                   	push   %ebx
  80176b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80176e:	83 ec 0c             	sub    $0xc,%esp
  801771:	ff 75 08             	pushl  0x8(%ebp)
  801774:	e8 b3 f7 ff ff       	call   800f2c <fd2data>
  801779:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80177b:	83 c4 08             	add    $0x8,%esp
  80177e:	68 eb 24 80 00       	push   $0x8024eb
  801783:	53                   	push   %ebx
  801784:	e8 96 f0 ff ff       	call   80081f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801789:	8b 46 04             	mov    0x4(%esi),%eax
  80178c:	2b 06                	sub    (%esi),%eax
  80178e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801794:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80179b:	00 00 00 
	stat->st_dev = &devpipe;
  80179e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8017a5:	30 80 00 
	return 0;
}
  8017a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b0:	5b                   	pop    %ebx
  8017b1:	5e                   	pop    %esi
  8017b2:	5d                   	pop    %ebp
  8017b3:	c3                   	ret    

008017b4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017b4:	f3 0f 1e fb          	endbr32 
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	53                   	push   %ebx
  8017bc:	83 ec 0c             	sub    $0xc,%esp
  8017bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017c2:	53                   	push   %ebx
  8017c3:	6a 00                	push   $0x0
  8017c5:	e8 24 f5 ff ff       	call   800cee <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017ca:	89 1c 24             	mov    %ebx,(%esp)
  8017cd:	e8 5a f7 ff ff       	call   800f2c <fd2data>
  8017d2:	83 c4 08             	add    $0x8,%esp
  8017d5:	50                   	push   %eax
  8017d6:	6a 00                	push   $0x0
  8017d8:	e8 11 f5 ff ff       	call   800cee <sys_page_unmap>
}
  8017dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e0:	c9                   	leave  
  8017e1:	c3                   	ret    

008017e2 <_pipeisclosed>:
{
  8017e2:	55                   	push   %ebp
  8017e3:	89 e5                	mov    %esp,%ebp
  8017e5:	57                   	push   %edi
  8017e6:	56                   	push   %esi
  8017e7:	53                   	push   %ebx
  8017e8:	83 ec 1c             	sub    $0x1c,%esp
  8017eb:	89 c7                	mov    %eax,%edi
  8017ed:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8017ef:	a1 04 40 80 00       	mov    0x804004,%eax
  8017f4:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8017f7:	83 ec 0c             	sub    $0xc,%esp
  8017fa:	57                   	push   %edi
  8017fb:	e8 57 05 00 00       	call   801d57 <pageref>
  801800:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801803:	89 34 24             	mov    %esi,(%esp)
  801806:	e8 4c 05 00 00       	call   801d57 <pageref>
		nn = thisenv->env_runs;
  80180b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801811:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801814:	83 c4 10             	add    $0x10,%esp
  801817:	39 cb                	cmp    %ecx,%ebx
  801819:	74 1b                	je     801836 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80181b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80181e:	75 cf                	jne    8017ef <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801820:	8b 42 58             	mov    0x58(%edx),%eax
  801823:	6a 01                	push   $0x1
  801825:	50                   	push   %eax
  801826:	53                   	push   %ebx
  801827:	68 f2 24 80 00       	push   $0x8024f2
  80182c:	e8 e5 e9 ff ff       	call   800216 <cprintf>
  801831:	83 c4 10             	add    $0x10,%esp
  801834:	eb b9                	jmp    8017ef <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801836:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801839:	0f 94 c0             	sete   %al
  80183c:	0f b6 c0             	movzbl %al,%eax
}
  80183f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801842:	5b                   	pop    %ebx
  801843:	5e                   	pop    %esi
  801844:	5f                   	pop    %edi
  801845:	5d                   	pop    %ebp
  801846:	c3                   	ret    

00801847 <devpipe_write>:
{
  801847:	f3 0f 1e fb          	endbr32 
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	57                   	push   %edi
  80184f:	56                   	push   %esi
  801850:	53                   	push   %ebx
  801851:	83 ec 28             	sub    $0x28,%esp
  801854:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801857:	56                   	push   %esi
  801858:	e8 cf f6 ff ff       	call   800f2c <fd2data>
  80185d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	bf 00 00 00 00       	mov    $0x0,%edi
  801867:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80186a:	74 4f                	je     8018bb <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80186c:	8b 43 04             	mov    0x4(%ebx),%eax
  80186f:	8b 0b                	mov    (%ebx),%ecx
  801871:	8d 51 20             	lea    0x20(%ecx),%edx
  801874:	39 d0                	cmp    %edx,%eax
  801876:	72 14                	jb     80188c <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801878:	89 da                	mov    %ebx,%edx
  80187a:	89 f0                	mov    %esi,%eax
  80187c:	e8 61 ff ff ff       	call   8017e2 <_pipeisclosed>
  801881:	85 c0                	test   %eax,%eax
  801883:	75 3b                	jne    8018c0 <devpipe_write+0x79>
			sys_yield();
  801885:	e8 b4 f3 ff ff       	call   800c3e <sys_yield>
  80188a:	eb e0                	jmp    80186c <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80188c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80188f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801893:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801896:	89 c2                	mov    %eax,%edx
  801898:	c1 fa 1f             	sar    $0x1f,%edx
  80189b:	89 d1                	mov    %edx,%ecx
  80189d:	c1 e9 1b             	shr    $0x1b,%ecx
  8018a0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8018a3:	83 e2 1f             	and    $0x1f,%edx
  8018a6:	29 ca                	sub    %ecx,%edx
  8018a8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8018ac:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018b0:	83 c0 01             	add    $0x1,%eax
  8018b3:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8018b6:	83 c7 01             	add    $0x1,%edi
  8018b9:	eb ac                	jmp    801867 <devpipe_write+0x20>
	return i;
  8018bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8018be:	eb 05                	jmp    8018c5 <devpipe_write+0x7e>
				return 0;
  8018c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018c8:	5b                   	pop    %ebx
  8018c9:	5e                   	pop    %esi
  8018ca:	5f                   	pop    %edi
  8018cb:	5d                   	pop    %ebp
  8018cc:	c3                   	ret    

008018cd <devpipe_read>:
{
  8018cd:	f3 0f 1e fb          	endbr32 
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	57                   	push   %edi
  8018d5:	56                   	push   %esi
  8018d6:	53                   	push   %ebx
  8018d7:	83 ec 18             	sub    $0x18,%esp
  8018da:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8018dd:	57                   	push   %edi
  8018de:	e8 49 f6 ff ff       	call   800f2c <fd2data>
  8018e3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8018e5:	83 c4 10             	add    $0x10,%esp
  8018e8:	be 00 00 00 00       	mov    $0x0,%esi
  8018ed:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018f0:	75 14                	jne    801906 <devpipe_read+0x39>
	return i;
  8018f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8018f5:	eb 02                	jmp    8018f9 <devpipe_read+0x2c>
				return i;
  8018f7:	89 f0                	mov    %esi,%eax
}
  8018f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018fc:	5b                   	pop    %ebx
  8018fd:	5e                   	pop    %esi
  8018fe:	5f                   	pop    %edi
  8018ff:	5d                   	pop    %ebp
  801900:	c3                   	ret    
			sys_yield();
  801901:	e8 38 f3 ff ff       	call   800c3e <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801906:	8b 03                	mov    (%ebx),%eax
  801908:	3b 43 04             	cmp    0x4(%ebx),%eax
  80190b:	75 18                	jne    801925 <devpipe_read+0x58>
			if (i > 0)
  80190d:	85 f6                	test   %esi,%esi
  80190f:	75 e6                	jne    8018f7 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801911:	89 da                	mov    %ebx,%edx
  801913:	89 f8                	mov    %edi,%eax
  801915:	e8 c8 fe ff ff       	call   8017e2 <_pipeisclosed>
  80191a:	85 c0                	test   %eax,%eax
  80191c:	74 e3                	je     801901 <devpipe_read+0x34>
				return 0;
  80191e:	b8 00 00 00 00       	mov    $0x0,%eax
  801923:	eb d4                	jmp    8018f9 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801925:	99                   	cltd   
  801926:	c1 ea 1b             	shr    $0x1b,%edx
  801929:	01 d0                	add    %edx,%eax
  80192b:	83 e0 1f             	and    $0x1f,%eax
  80192e:	29 d0                	sub    %edx,%eax
  801930:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801935:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801938:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80193b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80193e:	83 c6 01             	add    $0x1,%esi
  801941:	eb aa                	jmp    8018ed <devpipe_read+0x20>

00801943 <pipe>:
{
  801943:	f3 0f 1e fb          	endbr32 
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	56                   	push   %esi
  80194b:	53                   	push   %ebx
  80194c:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80194f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801952:	50                   	push   %eax
  801953:	e8 ef f5 ff ff       	call   800f47 <fd_alloc>
  801958:	89 c3                	mov    %eax,%ebx
  80195a:	83 c4 10             	add    $0x10,%esp
  80195d:	85 c0                	test   %eax,%eax
  80195f:	0f 88 23 01 00 00    	js     801a88 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801965:	83 ec 04             	sub    $0x4,%esp
  801968:	68 07 04 00 00       	push   $0x407
  80196d:	ff 75 f4             	pushl  -0xc(%ebp)
  801970:	6a 00                	push   $0x0
  801972:	e8 ea f2 ff ff       	call   800c61 <sys_page_alloc>
  801977:	89 c3                	mov    %eax,%ebx
  801979:	83 c4 10             	add    $0x10,%esp
  80197c:	85 c0                	test   %eax,%eax
  80197e:	0f 88 04 01 00 00    	js     801a88 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801984:	83 ec 0c             	sub    $0xc,%esp
  801987:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80198a:	50                   	push   %eax
  80198b:	e8 b7 f5 ff ff       	call   800f47 <fd_alloc>
  801990:	89 c3                	mov    %eax,%ebx
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	85 c0                	test   %eax,%eax
  801997:	0f 88 db 00 00 00    	js     801a78 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80199d:	83 ec 04             	sub    $0x4,%esp
  8019a0:	68 07 04 00 00       	push   $0x407
  8019a5:	ff 75 f0             	pushl  -0x10(%ebp)
  8019a8:	6a 00                	push   $0x0
  8019aa:	e8 b2 f2 ff ff       	call   800c61 <sys_page_alloc>
  8019af:	89 c3                	mov    %eax,%ebx
  8019b1:	83 c4 10             	add    $0x10,%esp
  8019b4:	85 c0                	test   %eax,%eax
  8019b6:	0f 88 bc 00 00 00    	js     801a78 <pipe+0x135>
	va = fd2data(fd0);
  8019bc:	83 ec 0c             	sub    $0xc,%esp
  8019bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c2:	e8 65 f5 ff ff       	call   800f2c <fd2data>
  8019c7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019c9:	83 c4 0c             	add    $0xc,%esp
  8019cc:	68 07 04 00 00       	push   $0x407
  8019d1:	50                   	push   %eax
  8019d2:	6a 00                	push   $0x0
  8019d4:	e8 88 f2 ff ff       	call   800c61 <sys_page_alloc>
  8019d9:	89 c3                	mov    %eax,%ebx
  8019db:	83 c4 10             	add    $0x10,%esp
  8019de:	85 c0                	test   %eax,%eax
  8019e0:	0f 88 82 00 00 00    	js     801a68 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019e6:	83 ec 0c             	sub    $0xc,%esp
  8019e9:	ff 75 f0             	pushl  -0x10(%ebp)
  8019ec:	e8 3b f5 ff ff       	call   800f2c <fd2data>
  8019f1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8019f8:	50                   	push   %eax
  8019f9:	6a 00                	push   $0x0
  8019fb:	56                   	push   %esi
  8019fc:	6a 00                	push   $0x0
  8019fe:	e8 a5 f2 ff ff       	call   800ca8 <sys_page_map>
  801a03:	89 c3                	mov    %eax,%ebx
  801a05:	83 c4 20             	add    $0x20,%esp
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	78 4e                	js     801a5a <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801a0c:	a1 20 30 80 00       	mov    0x803020,%eax
  801a11:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a14:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801a16:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a19:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801a20:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a23:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801a25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a28:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801a2f:	83 ec 0c             	sub    $0xc,%esp
  801a32:	ff 75 f4             	pushl  -0xc(%ebp)
  801a35:	e8 de f4 ff ff       	call   800f18 <fd2num>
  801a3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a3d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a3f:	83 c4 04             	add    $0x4,%esp
  801a42:	ff 75 f0             	pushl  -0x10(%ebp)
  801a45:	e8 ce f4 ff ff       	call   800f18 <fd2num>
  801a4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a4d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a50:	83 c4 10             	add    $0x10,%esp
  801a53:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a58:	eb 2e                	jmp    801a88 <pipe+0x145>
	sys_page_unmap(0, va);
  801a5a:	83 ec 08             	sub    $0x8,%esp
  801a5d:	56                   	push   %esi
  801a5e:	6a 00                	push   $0x0
  801a60:	e8 89 f2 ff ff       	call   800cee <sys_page_unmap>
  801a65:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801a68:	83 ec 08             	sub    $0x8,%esp
  801a6b:	ff 75 f0             	pushl  -0x10(%ebp)
  801a6e:	6a 00                	push   $0x0
  801a70:	e8 79 f2 ff ff       	call   800cee <sys_page_unmap>
  801a75:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801a78:	83 ec 08             	sub    $0x8,%esp
  801a7b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a7e:	6a 00                	push   $0x0
  801a80:	e8 69 f2 ff ff       	call   800cee <sys_page_unmap>
  801a85:	83 c4 10             	add    $0x10,%esp
}
  801a88:	89 d8                	mov    %ebx,%eax
  801a8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8d:	5b                   	pop    %ebx
  801a8e:	5e                   	pop    %esi
  801a8f:	5d                   	pop    %ebp
  801a90:	c3                   	ret    

00801a91 <pipeisclosed>:
{
  801a91:	f3 0f 1e fb          	endbr32 
  801a95:	55                   	push   %ebp
  801a96:	89 e5                	mov    %esp,%ebp
  801a98:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a9e:	50                   	push   %eax
  801a9f:	ff 75 08             	pushl  0x8(%ebp)
  801aa2:	e8 f6 f4 ff ff       	call   800f9d <fd_lookup>
  801aa7:	83 c4 10             	add    $0x10,%esp
  801aaa:	85 c0                	test   %eax,%eax
  801aac:	78 18                	js     801ac6 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801aae:	83 ec 0c             	sub    $0xc,%esp
  801ab1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab4:	e8 73 f4 ff ff       	call   800f2c <fd2data>
  801ab9:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abe:	e8 1f fd ff ff       	call   8017e2 <_pipeisclosed>
  801ac3:	83 c4 10             	add    $0x10,%esp
}
  801ac6:	c9                   	leave  
  801ac7:	c3                   	ret    

00801ac8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ac8:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801acc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad1:	c3                   	ret    

00801ad2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ad2:	f3 0f 1e fb          	endbr32 
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801adc:	68 0a 25 80 00       	push   $0x80250a
  801ae1:	ff 75 0c             	pushl  0xc(%ebp)
  801ae4:	e8 36 ed ff ff       	call   80081f <strcpy>
	return 0;
}
  801ae9:	b8 00 00 00 00       	mov    $0x0,%eax
  801aee:	c9                   	leave  
  801aef:	c3                   	ret    

00801af0 <devcons_write>:
{
  801af0:	f3 0f 1e fb          	endbr32 
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	57                   	push   %edi
  801af8:	56                   	push   %esi
  801af9:	53                   	push   %ebx
  801afa:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801b00:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801b05:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801b0b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b0e:	73 31                	jae    801b41 <devcons_write+0x51>
		m = n - tot;
  801b10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b13:	29 f3                	sub    %esi,%ebx
  801b15:	83 fb 7f             	cmp    $0x7f,%ebx
  801b18:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801b1d:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801b20:	83 ec 04             	sub    $0x4,%esp
  801b23:	53                   	push   %ebx
  801b24:	89 f0                	mov    %esi,%eax
  801b26:	03 45 0c             	add    0xc(%ebp),%eax
  801b29:	50                   	push   %eax
  801b2a:	57                   	push   %edi
  801b2b:	e8 a5 ee ff ff       	call   8009d5 <memmove>
		sys_cputs(buf, m);
  801b30:	83 c4 08             	add    $0x8,%esp
  801b33:	53                   	push   %ebx
  801b34:	57                   	push   %edi
  801b35:	e8 57 f0 ff ff       	call   800b91 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801b3a:	01 de                	add    %ebx,%esi
  801b3c:	83 c4 10             	add    $0x10,%esp
  801b3f:	eb ca                	jmp    801b0b <devcons_write+0x1b>
}
  801b41:	89 f0                	mov    %esi,%eax
  801b43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b46:	5b                   	pop    %ebx
  801b47:	5e                   	pop    %esi
  801b48:	5f                   	pop    %edi
  801b49:	5d                   	pop    %ebp
  801b4a:	c3                   	ret    

00801b4b <devcons_read>:
{
  801b4b:	f3 0f 1e fb          	endbr32 
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	83 ec 08             	sub    $0x8,%esp
  801b55:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801b5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b5e:	74 21                	je     801b81 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801b60:	e8 4e f0 ff ff       	call   800bb3 <sys_cgetc>
  801b65:	85 c0                	test   %eax,%eax
  801b67:	75 07                	jne    801b70 <devcons_read+0x25>
		sys_yield();
  801b69:	e8 d0 f0 ff ff       	call   800c3e <sys_yield>
  801b6e:	eb f0                	jmp    801b60 <devcons_read+0x15>
	if (c < 0)
  801b70:	78 0f                	js     801b81 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801b72:	83 f8 04             	cmp    $0x4,%eax
  801b75:	74 0c                	je     801b83 <devcons_read+0x38>
	*(char*)vbuf = c;
  801b77:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b7a:	88 02                	mov    %al,(%edx)
	return 1;
  801b7c:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801b81:	c9                   	leave  
  801b82:	c3                   	ret    
		return 0;
  801b83:	b8 00 00 00 00       	mov    $0x0,%eax
  801b88:	eb f7                	jmp    801b81 <devcons_read+0x36>

00801b8a <cputchar>:
{
  801b8a:	f3 0f 1e fb          	endbr32 
  801b8e:	55                   	push   %ebp
  801b8f:	89 e5                	mov    %esp,%ebp
  801b91:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b94:	8b 45 08             	mov    0x8(%ebp),%eax
  801b97:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801b9a:	6a 01                	push   $0x1
  801b9c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b9f:	50                   	push   %eax
  801ba0:	e8 ec ef ff ff       	call   800b91 <sys_cputs>
}
  801ba5:	83 c4 10             	add    $0x10,%esp
  801ba8:	c9                   	leave  
  801ba9:	c3                   	ret    

00801baa <getchar>:
{
  801baa:	f3 0f 1e fb          	endbr32 
  801bae:	55                   	push   %ebp
  801baf:	89 e5                	mov    %esp,%ebp
  801bb1:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801bb4:	6a 01                	push   $0x1
  801bb6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bb9:	50                   	push   %eax
  801bba:	6a 00                	push   $0x0
  801bbc:	e8 5f f6 ff ff       	call   801220 <read>
	if (r < 0)
  801bc1:	83 c4 10             	add    $0x10,%esp
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	78 06                	js     801bce <getchar+0x24>
	if (r < 1)
  801bc8:	74 06                	je     801bd0 <getchar+0x26>
	return c;
  801bca:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801bce:	c9                   	leave  
  801bcf:	c3                   	ret    
		return -E_EOF;
  801bd0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801bd5:	eb f7                	jmp    801bce <getchar+0x24>

00801bd7 <iscons>:
{
  801bd7:	f3 0f 1e fb          	endbr32 
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801be1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be4:	50                   	push   %eax
  801be5:	ff 75 08             	pushl  0x8(%ebp)
  801be8:	e8 b0 f3 ff ff       	call   800f9d <fd_lookup>
  801bed:	83 c4 10             	add    $0x10,%esp
  801bf0:	85 c0                	test   %eax,%eax
  801bf2:	78 11                	js     801c05 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bfd:	39 10                	cmp    %edx,(%eax)
  801bff:	0f 94 c0             	sete   %al
  801c02:	0f b6 c0             	movzbl %al,%eax
}
  801c05:	c9                   	leave  
  801c06:	c3                   	ret    

00801c07 <opencons>:
{
  801c07:	f3 0f 1e fb          	endbr32 
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801c11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c14:	50                   	push   %eax
  801c15:	e8 2d f3 ff ff       	call   800f47 <fd_alloc>
  801c1a:	83 c4 10             	add    $0x10,%esp
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	78 3a                	js     801c5b <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c21:	83 ec 04             	sub    $0x4,%esp
  801c24:	68 07 04 00 00       	push   $0x407
  801c29:	ff 75 f4             	pushl  -0xc(%ebp)
  801c2c:	6a 00                	push   $0x0
  801c2e:	e8 2e f0 ff ff       	call   800c61 <sys_page_alloc>
  801c33:	83 c4 10             	add    $0x10,%esp
  801c36:	85 c0                	test   %eax,%eax
  801c38:	78 21                	js     801c5b <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c43:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c48:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c4f:	83 ec 0c             	sub    $0xc,%esp
  801c52:	50                   	push   %eax
  801c53:	e8 c0 f2 ff ff       	call   800f18 <fd2num>
  801c58:	83 c4 10             	add    $0x10,%esp
}
  801c5b:	c9                   	leave  
  801c5c:	c3                   	ret    

00801c5d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c5d:	f3 0f 1e fb          	endbr32 
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	56                   	push   %esi
  801c65:	53                   	push   %ebx
  801c66:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c69:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c6c:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801c76:	0f 44 c2             	cmove  %edx,%eax
  801c79:	83 ec 0c             	sub    $0xc,%esp
  801c7c:	50                   	push   %eax
  801c7d:	e8 ab f1 ff ff       	call   800e2d <sys_ipc_recv>
  801c82:	83 c4 10             	add    $0x10,%esp
  801c85:	85 c0                	test   %eax,%eax
  801c87:	78 24                	js     801cad <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801c89:	85 f6                	test   %esi,%esi
  801c8b:	74 0a                	je     801c97 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801c8d:	a1 04 40 80 00       	mov    0x804004,%eax
  801c92:	8b 40 78             	mov    0x78(%eax),%eax
  801c95:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801c97:	85 db                	test   %ebx,%ebx
  801c99:	74 0a                	je     801ca5 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801c9b:	a1 04 40 80 00       	mov    0x804004,%eax
  801ca0:	8b 40 74             	mov    0x74(%eax),%eax
  801ca3:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801ca5:	a1 04 40 80 00       	mov    0x804004,%eax
  801caa:	8b 40 70             	mov    0x70(%eax),%eax
}
  801cad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb0:	5b                   	pop    %ebx
  801cb1:	5e                   	pop    %esi
  801cb2:	5d                   	pop    %ebp
  801cb3:	c3                   	ret    

00801cb4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801cb4:	f3 0f 1e fb          	endbr32 
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	57                   	push   %edi
  801cbc:	56                   	push   %esi
  801cbd:	53                   	push   %ebx
  801cbe:	83 ec 1c             	sub    $0x1c,%esp
  801cc1:	8b 45 10             	mov    0x10(%ebp),%eax
  801cc4:	85 c0                	test   %eax,%eax
  801cc6:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801ccb:	0f 45 d0             	cmovne %eax,%edx
  801cce:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801cd0:	be 01 00 00 00       	mov    $0x1,%esi
  801cd5:	eb 1f                	jmp    801cf6 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801cd7:	e8 62 ef ff ff       	call   800c3e <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801cdc:	83 c3 01             	add    $0x1,%ebx
  801cdf:	39 de                	cmp    %ebx,%esi
  801ce1:	7f f4                	jg     801cd7 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801ce3:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801ce5:	83 fe 11             	cmp    $0x11,%esi
  801ce8:	b8 01 00 00 00       	mov    $0x1,%eax
  801ced:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801cf0:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801cf4:	75 1c                	jne    801d12 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801cf6:	ff 75 14             	pushl  0x14(%ebp)
  801cf9:	57                   	push   %edi
  801cfa:	ff 75 0c             	pushl  0xc(%ebp)
  801cfd:	ff 75 08             	pushl  0x8(%ebp)
  801d00:	e8 01 f1 ff ff       	call   800e06 <sys_ipc_try_send>
  801d05:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801d08:	83 c4 10             	add    $0x10,%esp
  801d0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d10:	eb cd                	jmp    801cdf <ipc_send+0x2b>
}
  801d12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d15:	5b                   	pop    %ebx
  801d16:	5e                   	pop    %esi
  801d17:	5f                   	pop    %edi
  801d18:	5d                   	pop    %ebp
  801d19:	c3                   	ret    

00801d1a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d1a:	f3 0f 1e fb          	endbr32 
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
  801d21:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d24:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d29:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d2c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d32:	8b 52 50             	mov    0x50(%edx),%edx
  801d35:	39 ca                	cmp    %ecx,%edx
  801d37:	74 11                	je     801d4a <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801d39:	83 c0 01             	add    $0x1,%eax
  801d3c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d41:	75 e6                	jne    801d29 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801d43:	b8 00 00 00 00       	mov    $0x0,%eax
  801d48:	eb 0b                	jmp    801d55 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801d4a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d4d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d52:	8b 40 48             	mov    0x48(%eax),%eax
}
  801d55:	5d                   	pop    %ebp
  801d56:	c3                   	ret    

00801d57 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d57:	f3 0f 1e fb          	endbr32 
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d61:	89 c2                	mov    %eax,%edx
  801d63:	c1 ea 16             	shr    $0x16,%edx
  801d66:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801d6d:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801d72:	f6 c1 01             	test   $0x1,%cl
  801d75:	74 1c                	je     801d93 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801d77:	c1 e8 0c             	shr    $0xc,%eax
  801d7a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d81:	a8 01                	test   $0x1,%al
  801d83:	74 0e                	je     801d93 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d85:	c1 e8 0c             	shr    $0xc,%eax
  801d88:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801d8f:	ef 
  801d90:	0f b7 d2             	movzwl %dx,%edx
}
  801d93:	89 d0                	mov    %edx,%eax
  801d95:	5d                   	pop    %ebp
  801d96:	c3                   	ret    
  801d97:	66 90                	xchg   %ax,%ax
  801d99:	66 90                	xchg   %ax,%ax
  801d9b:	66 90                	xchg   %ax,%ax
  801d9d:	66 90                	xchg   %ax,%ax
  801d9f:	90                   	nop

00801da0 <__udivdi3>:
  801da0:	f3 0f 1e fb          	endbr32 
  801da4:	55                   	push   %ebp
  801da5:	57                   	push   %edi
  801da6:	56                   	push   %esi
  801da7:	53                   	push   %ebx
  801da8:	83 ec 1c             	sub    $0x1c,%esp
  801dab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801daf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801db3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801db7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801dbb:	85 d2                	test   %edx,%edx
  801dbd:	75 19                	jne    801dd8 <__udivdi3+0x38>
  801dbf:	39 f3                	cmp    %esi,%ebx
  801dc1:	76 4d                	jbe    801e10 <__udivdi3+0x70>
  801dc3:	31 ff                	xor    %edi,%edi
  801dc5:	89 e8                	mov    %ebp,%eax
  801dc7:	89 f2                	mov    %esi,%edx
  801dc9:	f7 f3                	div    %ebx
  801dcb:	89 fa                	mov    %edi,%edx
  801dcd:	83 c4 1c             	add    $0x1c,%esp
  801dd0:	5b                   	pop    %ebx
  801dd1:	5e                   	pop    %esi
  801dd2:	5f                   	pop    %edi
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    
  801dd5:	8d 76 00             	lea    0x0(%esi),%esi
  801dd8:	39 f2                	cmp    %esi,%edx
  801dda:	76 14                	jbe    801df0 <__udivdi3+0x50>
  801ddc:	31 ff                	xor    %edi,%edi
  801dde:	31 c0                	xor    %eax,%eax
  801de0:	89 fa                	mov    %edi,%edx
  801de2:	83 c4 1c             	add    $0x1c,%esp
  801de5:	5b                   	pop    %ebx
  801de6:	5e                   	pop    %esi
  801de7:	5f                   	pop    %edi
  801de8:	5d                   	pop    %ebp
  801de9:	c3                   	ret    
  801dea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801df0:	0f bd fa             	bsr    %edx,%edi
  801df3:	83 f7 1f             	xor    $0x1f,%edi
  801df6:	75 48                	jne    801e40 <__udivdi3+0xa0>
  801df8:	39 f2                	cmp    %esi,%edx
  801dfa:	72 06                	jb     801e02 <__udivdi3+0x62>
  801dfc:	31 c0                	xor    %eax,%eax
  801dfe:	39 eb                	cmp    %ebp,%ebx
  801e00:	77 de                	ja     801de0 <__udivdi3+0x40>
  801e02:	b8 01 00 00 00       	mov    $0x1,%eax
  801e07:	eb d7                	jmp    801de0 <__udivdi3+0x40>
  801e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e10:	89 d9                	mov    %ebx,%ecx
  801e12:	85 db                	test   %ebx,%ebx
  801e14:	75 0b                	jne    801e21 <__udivdi3+0x81>
  801e16:	b8 01 00 00 00       	mov    $0x1,%eax
  801e1b:	31 d2                	xor    %edx,%edx
  801e1d:	f7 f3                	div    %ebx
  801e1f:	89 c1                	mov    %eax,%ecx
  801e21:	31 d2                	xor    %edx,%edx
  801e23:	89 f0                	mov    %esi,%eax
  801e25:	f7 f1                	div    %ecx
  801e27:	89 c6                	mov    %eax,%esi
  801e29:	89 e8                	mov    %ebp,%eax
  801e2b:	89 f7                	mov    %esi,%edi
  801e2d:	f7 f1                	div    %ecx
  801e2f:	89 fa                	mov    %edi,%edx
  801e31:	83 c4 1c             	add    $0x1c,%esp
  801e34:	5b                   	pop    %ebx
  801e35:	5e                   	pop    %esi
  801e36:	5f                   	pop    %edi
  801e37:	5d                   	pop    %ebp
  801e38:	c3                   	ret    
  801e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e40:	89 f9                	mov    %edi,%ecx
  801e42:	b8 20 00 00 00       	mov    $0x20,%eax
  801e47:	29 f8                	sub    %edi,%eax
  801e49:	d3 e2                	shl    %cl,%edx
  801e4b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e4f:	89 c1                	mov    %eax,%ecx
  801e51:	89 da                	mov    %ebx,%edx
  801e53:	d3 ea                	shr    %cl,%edx
  801e55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e59:	09 d1                	or     %edx,%ecx
  801e5b:	89 f2                	mov    %esi,%edx
  801e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e61:	89 f9                	mov    %edi,%ecx
  801e63:	d3 e3                	shl    %cl,%ebx
  801e65:	89 c1                	mov    %eax,%ecx
  801e67:	d3 ea                	shr    %cl,%edx
  801e69:	89 f9                	mov    %edi,%ecx
  801e6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801e6f:	89 eb                	mov    %ebp,%ebx
  801e71:	d3 e6                	shl    %cl,%esi
  801e73:	89 c1                	mov    %eax,%ecx
  801e75:	d3 eb                	shr    %cl,%ebx
  801e77:	09 de                	or     %ebx,%esi
  801e79:	89 f0                	mov    %esi,%eax
  801e7b:	f7 74 24 08          	divl   0x8(%esp)
  801e7f:	89 d6                	mov    %edx,%esi
  801e81:	89 c3                	mov    %eax,%ebx
  801e83:	f7 64 24 0c          	mull   0xc(%esp)
  801e87:	39 d6                	cmp    %edx,%esi
  801e89:	72 15                	jb     801ea0 <__udivdi3+0x100>
  801e8b:	89 f9                	mov    %edi,%ecx
  801e8d:	d3 e5                	shl    %cl,%ebp
  801e8f:	39 c5                	cmp    %eax,%ebp
  801e91:	73 04                	jae    801e97 <__udivdi3+0xf7>
  801e93:	39 d6                	cmp    %edx,%esi
  801e95:	74 09                	je     801ea0 <__udivdi3+0x100>
  801e97:	89 d8                	mov    %ebx,%eax
  801e99:	31 ff                	xor    %edi,%edi
  801e9b:	e9 40 ff ff ff       	jmp    801de0 <__udivdi3+0x40>
  801ea0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801ea3:	31 ff                	xor    %edi,%edi
  801ea5:	e9 36 ff ff ff       	jmp    801de0 <__udivdi3+0x40>
  801eaa:	66 90                	xchg   %ax,%ax
  801eac:	66 90                	xchg   %ax,%ax
  801eae:	66 90                	xchg   %ax,%ax

00801eb0 <__umoddi3>:
  801eb0:	f3 0f 1e fb          	endbr32 
  801eb4:	55                   	push   %ebp
  801eb5:	57                   	push   %edi
  801eb6:	56                   	push   %esi
  801eb7:	53                   	push   %ebx
  801eb8:	83 ec 1c             	sub    $0x1c,%esp
  801ebb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801ebf:	8b 74 24 30          	mov    0x30(%esp),%esi
  801ec3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801ec7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ecb:	85 c0                	test   %eax,%eax
  801ecd:	75 19                	jne    801ee8 <__umoddi3+0x38>
  801ecf:	39 df                	cmp    %ebx,%edi
  801ed1:	76 5d                	jbe    801f30 <__umoddi3+0x80>
  801ed3:	89 f0                	mov    %esi,%eax
  801ed5:	89 da                	mov    %ebx,%edx
  801ed7:	f7 f7                	div    %edi
  801ed9:	89 d0                	mov    %edx,%eax
  801edb:	31 d2                	xor    %edx,%edx
  801edd:	83 c4 1c             	add    $0x1c,%esp
  801ee0:	5b                   	pop    %ebx
  801ee1:	5e                   	pop    %esi
  801ee2:	5f                   	pop    %edi
  801ee3:	5d                   	pop    %ebp
  801ee4:	c3                   	ret    
  801ee5:	8d 76 00             	lea    0x0(%esi),%esi
  801ee8:	89 f2                	mov    %esi,%edx
  801eea:	39 d8                	cmp    %ebx,%eax
  801eec:	76 12                	jbe    801f00 <__umoddi3+0x50>
  801eee:	89 f0                	mov    %esi,%eax
  801ef0:	89 da                	mov    %ebx,%edx
  801ef2:	83 c4 1c             	add    $0x1c,%esp
  801ef5:	5b                   	pop    %ebx
  801ef6:	5e                   	pop    %esi
  801ef7:	5f                   	pop    %edi
  801ef8:	5d                   	pop    %ebp
  801ef9:	c3                   	ret    
  801efa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f00:	0f bd e8             	bsr    %eax,%ebp
  801f03:	83 f5 1f             	xor    $0x1f,%ebp
  801f06:	75 50                	jne    801f58 <__umoddi3+0xa8>
  801f08:	39 d8                	cmp    %ebx,%eax
  801f0a:	0f 82 e0 00 00 00    	jb     801ff0 <__umoddi3+0x140>
  801f10:	89 d9                	mov    %ebx,%ecx
  801f12:	39 f7                	cmp    %esi,%edi
  801f14:	0f 86 d6 00 00 00    	jbe    801ff0 <__umoddi3+0x140>
  801f1a:	89 d0                	mov    %edx,%eax
  801f1c:	89 ca                	mov    %ecx,%edx
  801f1e:	83 c4 1c             	add    $0x1c,%esp
  801f21:	5b                   	pop    %ebx
  801f22:	5e                   	pop    %esi
  801f23:	5f                   	pop    %edi
  801f24:	5d                   	pop    %ebp
  801f25:	c3                   	ret    
  801f26:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f2d:	8d 76 00             	lea    0x0(%esi),%esi
  801f30:	89 fd                	mov    %edi,%ebp
  801f32:	85 ff                	test   %edi,%edi
  801f34:	75 0b                	jne    801f41 <__umoddi3+0x91>
  801f36:	b8 01 00 00 00       	mov    $0x1,%eax
  801f3b:	31 d2                	xor    %edx,%edx
  801f3d:	f7 f7                	div    %edi
  801f3f:	89 c5                	mov    %eax,%ebp
  801f41:	89 d8                	mov    %ebx,%eax
  801f43:	31 d2                	xor    %edx,%edx
  801f45:	f7 f5                	div    %ebp
  801f47:	89 f0                	mov    %esi,%eax
  801f49:	f7 f5                	div    %ebp
  801f4b:	89 d0                	mov    %edx,%eax
  801f4d:	31 d2                	xor    %edx,%edx
  801f4f:	eb 8c                	jmp    801edd <__umoddi3+0x2d>
  801f51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f58:	89 e9                	mov    %ebp,%ecx
  801f5a:	ba 20 00 00 00       	mov    $0x20,%edx
  801f5f:	29 ea                	sub    %ebp,%edx
  801f61:	d3 e0                	shl    %cl,%eax
  801f63:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f67:	89 d1                	mov    %edx,%ecx
  801f69:	89 f8                	mov    %edi,%eax
  801f6b:	d3 e8                	shr    %cl,%eax
  801f6d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801f71:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f75:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f79:	09 c1                	or     %eax,%ecx
  801f7b:	89 d8                	mov    %ebx,%eax
  801f7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f81:	89 e9                	mov    %ebp,%ecx
  801f83:	d3 e7                	shl    %cl,%edi
  801f85:	89 d1                	mov    %edx,%ecx
  801f87:	d3 e8                	shr    %cl,%eax
  801f89:	89 e9                	mov    %ebp,%ecx
  801f8b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f8f:	d3 e3                	shl    %cl,%ebx
  801f91:	89 c7                	mov    %eax,%edi
  801f93:	89 d1                	mov    %edx,%ecx
  801f95:	89 f0                	mov    %esi,%eax
  801f97:	d3 e8                	shr    %cl,%eax
  801f99:	89 e9                	mov    %ebp,%ecx
  801f9b:	89 fa                	mov    %edi,%edx
  801f9d:	d3 e6                	shl    %cl,%esi
  801f9f:	09 d8                	or     %ebx,%eax
  801fa1:	f7 74 24 08          	divl   0x8(%esp)
  801fa5:	89 d1                	mov    %edx,%ecx
  801fa7:	89 f3                	mov    %esi,%ebx
  801fa9:	f7 64 24 0c          	mull   0xc(%esp)
  801fad:	89 c6                	mov    %eax,%esi
  801faf:	89 d7                	mov    %edx,%edi
  801fb1:	39 d1                	cmp    %edx,%ecx
  801fb3:	72 06                	jb     801fbb <__umoddi3+0x10b>
  801fb5:	75 10                	jne    801fc7 <__umoddi3+0x117>
  801fb7:	39 c3                	cmp    %eax,%ebx
  801fb9:	73 0c                	jae    801fc7 <__umoddi3+0x117>
  801fbb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801fbf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801fc3:	89 d7                	mov    %edx,%edi
  801fc5:	89 c6                	mov    %eax,%esi
  801fc7:	89 ca                	mov    %ecx,%edx
  801fc9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801fce:	29 f3                	sub    %esi,%ebx
  801fd0:	19 fa                	sbb    %edi,%edx
  801fd2:	89 d0                	mov    %edx,%eax
  801fd4:	d3 e0                	shl    %cl,%eax
  801fd6:	89 e9                	mov    %ebp,%ecx
  801fd8:	d3 eb                	shr    %cl,%ebx
  801fda:	d3 ea                	shr    %cl,%edx
  801fdc:	09 d8                	or     %ebx,%eax
  801fde:	83 c4 1c             	add    $0x1c,%esp
  801fe1:	5b                   	pop    %ebx
  801fe2:	5e                   	pop    %esi
  801fe3:	5f                   	pop    %edi
  801fe4:	5d                   	pop    %ebp
  801fe5:	c3                   	ret    
  801fe6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fed:	8d 76 00             	lea    0x0(%esi),%esi
  801ff0:	29 fe                	sub    %edi,%esi
  801ff2:	19 c3                	sbb    %eax,%ebx
  801ff4:	89 f2                	mov    %esi,%edx
  801ff6:	89 d9                	mov    %ebx,%ecx
  801ff8:	e9 1d ff ff ff       	jmp    801f1a <__umoddi3+0x6a>
