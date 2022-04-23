
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 a1 00 00 00       	call   8000d2 <libmain>
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
  800049:	e8 d5 01 00 00       	call   800223 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004e:	83 c4 0c             	add    $0xc,%esp
  800051:	6a 07                	push   $0x7
  800053:	89 d8                	mov    %ebx,%eax
  800055:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005a:	50                   	push   %eax
  80005b:	6a 00                	push   $0x0
  80005d:	e8 0c 0c 00 00       	call   800c6e <sys_page_alloc>
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
  800072:	e8 54 07 00 00       	call   8007cb <snprintf>
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
  800089:	6a 0e                	push   $0xe
  80008b:	68 8a 11 80 00       	push   $0x80118a
  800090:	e8 a7 00 00 00       	call   80013c <_panic>

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
  8000a4:	e8 b5 0d 00 00       	call   800e5e <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a9:	83 c4 08             	add    $0x8,%esp
  8000ac:	68 ef be ad de       	push   $0xdeadbeef
  8000b1:	68 9c 11 80 00       	push   $0x80119c
  8000b6:	e8 68 01 00 00       	call   800223 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000bb:	83 c4 08             	add    $0x8,%esp
  8000be:	68 fe bf fe ca       	push   $0xcafebffe
  8000c3:	68 9c 11 80 00       	push   $0x80119c
  8000c8:	e8 56 01 00 00       	call   800223 <cprintf>
}
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	c9                   	leave  
  8000d1:	c3                   	ret    

008000d2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000d2:	f3 0f 1e fb          	endbr32 
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
  8000db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000e1:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000e8:	00 00 00 
    envid_t envid = sys_getenvid();
  8000eb:	e8 38 0b 00 00       	call   800c28 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8000f0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fd:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800102:	85 db                	test   %ebx,%ebx
  800104:	7e 07                	jle    80010d <libmain+0x3b>
		binaryname = argv[0];
  800106:	8b 06                	mov    (%esi),%eax
  800108:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80010d:	83 ec 08             	sub    $0x8,%esp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
  800112:	e8 7e ff ff ff       	call   800095 <umain>

	// exit gracefully
	exit();
  800117:	e8 0a 00 00 00       	call   800126 <exit>
}
  80011c:	83 c4 10             	add    $0x10,%esp
  80011f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800122:	5b                   	pop    %ebx
  800123:	5e                   	pop    %esi
  800124:	5d                   	pop    %ebp
  800125:	c3                   	ret    

00800126 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800126:	f3 0f 1e fb          	endbr32 
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800130:	6a 00                	push   $0x0
  800132:	e8 ac 0a 00 00       	call   800be3 <sys_env_destroy>
}
  800137:	83 c4 10             	add    $0x10,%esp
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013c:	f3 0f 1e fb          	endbr32 
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800145:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800148:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80014e:	e8 d5 0a 00 00       	call   800c28 <sys_getenvid>
  800153:	83 ec 0c             	sub    $0xc,%esp
  800156:	ff 75 0c             	pushl  0xc(%ebp)
  800159:	ff 75 08             	pushl  0x8(%ebp)
  80015c:	56                   	push   %esi
  80015d:	50                   	push   %eax
  80015e:	68 f8 11 80 00       	push   $0x8011f8
  800163:	e8 bb 00 00 00       	call   800223 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800168:	83 c4 18             	add    $0x18,%esp
  80016b:	53                   	push   %ebx
  80016c:	ff 75 10             	pushl  0x10(%ebp)
  80016f:	e8 5a 00 00 00       	call   8001ce <vcprintf>
	cprintf("\n");
  800174:	c7 04 24 57 15 80 00 	movl   $0x801557,(%esp)
  80017b:	e8 a3 00 00 00       	call   800223 <cprintf>
  800180:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800183:	cc                   	int3   
  800184:	eb fd                	jmp    800183 <_panic+0x47>

00800186 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800186:	f3 0f 1e fb          	endbr32 
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	53                   	push   %ebx
  80018e:	83 ec 04             	sub    $0x4,%esp
  800191:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800194:	8b 13                	mov    (%ebx),%edx
  800196:	8d 42 01             	lea    0x1(%edx),%eax
  800199:	89 03                	mov    %eax,(%ebx)
  80019b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80019e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a7:	74 09                	je     8001b2 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001a9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	68 ff 00 00 00       	push   $0xff
  8001ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bd:	50                   	push   %eax
  8001be:	e8 db 09 00 00       	call   800b9e <sys_cputs>
		b->idx = 0;
  8001c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c9:	83 c4 10             	add    $0x10,%esp
  8001cc:	eb db                	jmp    8001a9 <putch+0x23>

008001ce <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ce:	f3 0f 1e fb          	endbr32 
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001db:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e2:	00 00 00 
	b.cnt = 0;
  8001e5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ec:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ef:	ff 75 0c             	pushl  0xc(%ebp)
  8001f2:	ff 75 08             	pushl  0x8(%ebp)
  8001f5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fb:	50                   	push   %eax
  8001fc:	68 86 01 80 00       	push   $0x800186
  800201:	e8 20 01 00 00       	call   800326 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800206:	83 c4 08             	add    $0x8,%esp
  800209:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800215:	50                   	push   %eax
  800216:	e8 83 09 00 00       	call   800b9e <sys_cputs>

	return b.cnt;
}
  80021b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800221:	c9                   	leave  
  800222:	c3                   	ret    

00800223 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800223:	f3 0f 1e fb          	endbr32 
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800230:	50                   	push   %eax
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	e8 95 ff ff ff       	call   8001ce <vcprintf>
	va_end(ap);

	return cnt;
}
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	57                   	push   %edi
  80023f:	56                   	push   %esi
  800240:	53                   	push   %ebx
  800241:	83 ec 1c             	sub    $0x1c,%esp
  800244:	89 c7                	mov    %eax,%edi
  800246:	89 d6                	mov    %edx,%esi
  800248:	8b 45 08             	mov    0x8(%ebp),%eax
  80024b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024e:	89 d1                	mov    %edx,%ecx
  800250:	89 c2                	mov    %eax,%edx
  800252:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800255:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800258:	8b 45 10             	mov    0x10(%ebp),%eax
  80025b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800261:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800268:	39 c2                	cmp    %eax,%edx
  80026a:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80026d:	72 3e                	jb     8002ad <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026f:	83 ec 0c             	sub    $0xc,%esp
  800272:	ff 75 18             	pushl  0x18(%ebp)
  800275:	83 eb 01             	sub    $0x1,%ebx
  800278:	53                   	push   %ebx
  800279:	50                   	push   %eax
  80027a:	83 ec 08             	sub    $0x8,%esp
  80027d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800280:	ff 75 e0             	pushl  -0x20(%ebp)
  800283:	ff 75 dc             	pushl  -0x24(%ebp)
  800286:	ff 75 d8             	pushl  -0x28(%ebp)
  800289:	e8 82 0c 00 00       	call   800f10 <__udivdi3>
  80028e:	83 c4 18             	add    $0x18,%esp
  800291:	52                   	push   %edx
  800292:	50                   	push   %eax
  800293:	89 f2                	mov    %esi,%edx
  800295:	89 f8                	mov    %edi,%eax
  800297:	e8 9f ff ff ff       	call   80023b <printnum>
  80029c:	83 c4 20             	add    $0x20,%esp
  80029f:	eb 13                	jmp    8002b4 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	ff 75 18             	pushl  0x18(%ebp)
  8002a8:	ff d7                	call   *%edi
  8002aa:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002ad:	83 eb 01             	sub    $0x1,%ebx
  8002b0:	85 db                	test   %ebx,%ebx
  8002b2:	7f ed                	jg     8002a1 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b4:	83 ec 08             	sub    $0x8,%esp
  8002b7:	56                   	push   %esi
  8002b8:	83 ec 04             	sub    $0x4,%esp
  8002bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002be:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c7:	e8 54 0d 00 00       	call   801020 <__umoddi3>
  8002cc:	83 c4 14             	add    $0x14,%esp
  8002cf:	0f be 80 1b 12 80 00 	movsbl 0x80121b(%eax),%eax
  8002d6:	50                   	push   %eax
  8002d7:	ff d7                	call   *%edi
}
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002df:	5b                   	pop    %ebx
  8002e0:	5e                   	pop    %esi
  8002e1:	5f                   	pop    %edi
  8002e2:	5d                   	pop    %ebp
  8002e3:	c3                   	ret    

008002e4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e4:	f3 0f 1e fb          	endbr32 
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ee:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f7:	73 0a                	jae    800303 <sprintputch+0x1f>
		*b->buf++ = ch;
  8002f9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fc:	89 08                	mov    %ecx,(%eax)
  8002fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800301:	88 02                	mov    %al,(%edx)
}
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <printfmt>:
{
  800305:	f3 0f 1e fb          	endbr32 
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80030f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800312:	50                   	push   %eax
  800313:	ff 75 10             	pushl  0x10(%ebp)
  800316:	ff 75 0c             	pushl  0xc(%ebp)
  800319:	ff 75 08             	pushl  0x8(%ebp)
  80031c:	e8 05 00 00 00       	call   800326 <vprintfmt>
}
  800321:	83 c4 10             	add    $0x10,%esp
  800324:	c9                   	leave  
  800325:	c3                   	ret    

00800326 <vprintfmt>:
{
  800326:	f3 0f 1e fb          	endbr32 
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
  80032d:	57                   	push   %edi
  80032e:	56                   	push   %esi
  80032f:	53                   	push   %ebx
  800330:	83 ec 3c             	sub    $0x3c,%esp
  800333:	8b 75 08             	mov    0x8(%ebp),%esi
  800336:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800339:	8b 7d 10             	mov    0x10(%ebp),%edi
  80033c:	e9 4a 03 00 00       	jmp    80068b <vprintfmt+0x365>
		padc = ' ';
  800341:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800345:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80034c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800353:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80035a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80035f:	8d 47 01             	lea    0x1(%edi),%eax
  800362:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800365:	0f b6 17             	movzbl (%edi),%edx
  800368:	8d 42 dd             	lea    -0x23(%edx),%eax
  80036b:	3c 55                	cmp    $0x55,%al
  80036d:	0f 87 de 03 00 00    	ja     800751 <vprintfmt+0x42b>
  800373:	0f b6 c0             	movzbl %al,%eax
  800376:	3e ff 24 85 60 13 80 	notrack jmp *0x801360(,%eax,4)
  80037d:	00 
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800381:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800385:	eb d8                	jmp    80035f <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800387:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038a:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80038e:	eb cf                	jmp    80035f <vprintfmt+0x39>
  800390:	0f b6 d2             	movzbl %dl,%edx
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800396:	b8 00 00 00 00       	mov    $0x0,%eax
  80039b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80039e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003a5:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003a8:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003ab:	83 f9 09             	cmp    $0x9,%ecx
  8003ae:	77 55                	ja     800405 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003b0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003b3:	eb e9                	jmp    80039e <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b8:	8b 00                	mov    (%eax),%eax
  8003ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c0:	8d 40 04             	lea    0x4(%eax),%eax
  8003c3:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003cd:	79 90                	jns    80035f <vprintfmt+0x39>
				width = precision, precision = -1;
  8003cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003dc:	eb 81                	jmp    80035f <vprintfmt+0x39>
  8003de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e1:	85 c0                	test   %eax,%eax
  8003e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e8:	0f 49 d0             	cmovns %eax,%edx
  8003eb:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f1:	e9 69 ff ff ff       	jmp    80035f <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003f9:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800400:	e9 5a ff ff ff       	jmp    80035f <vprintfmt+0x39>
  800405:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800408:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040b:	eb bc                	jmp    8003c9 <vprintfmt+0xa3>
			lflag++;
  80040d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800413:	e9 47 ff ff ff       	jmp    80035f <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800418:	8b 45 14             	mov    0x14(%ebp),%eax
  80041b:	8d 78 04             	lea    0x4(%eax),%edi
  80041e:	83 ec 08             	sub    $0x8,%esp
  800421:	53                   	push   %ebx
  800422:	ff 30                	pushl  (%eax)
  800424:	ff d6                	call   *%esi
			break;
  800426:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800429:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80042c:	e9 57 02 00 00       	jmp    800688 <vprintfmt+0x362>
			err = va_arg(ap, int);
  800431:	8b 45 14             	mov    0x14(%ebp),%eax
  800434:	8d 78 04             	lea    0x4(%eax),%edi
  800437:	8b 00                	mov    (%eax),%eax
  800439:	99                   	cltd   
  80043a:	31 d0                	xor    %edx,%eax
  80043c:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043e:	83 f8 0f             	cmp    $0xf,%eax
  800441:	7f 23                	jg     800466 <vprintfmt+0x140>
  800443:	8b 14 85 c0 14 80 00 	mov    0x8014c0(,%eax,4),%edx
  80044a:	85 d2                	test   %edx,%edx
  80044c:	74 18                	je     800466 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80044e:	52                   	push   %edx
  80044f:	68 3c 12 80 00       	push   $0x80123c
  800454:	53                   	push   %ebx
  800455:	56                   	push   %esi
  800456:	e8 aa fe ff ff       	call   800305 <printfmt>
  80045b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80045e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800461:	e9 22 02 00 00       	jmp    800688 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800466:	50                   	push   %eax
  800467:	68 33 12 80 00       	push   $0x801233
  80046c:	53                   	push   %ebx
  80046d:	56                   	push   %esi
  80046e:	e8 92 fe ff ff       	call   800305 <printfmt>
  800473:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800476:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800479:	e9 0a 02 00 00       	jmp    800688 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  80047e:	8b 45 14             	mov    0x14(%ebp),%eax
  800481:	83 c0 04             	add    $0x4,%eax
  800484:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800487:	8b 45 14             	mov    0x14(%ebp),%eax
  80048a:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80048c:	85 d2                	test   %edx,%edx
  80048e:	b8 2c 12 80 00       	mov    $0x80122c,%eax
  800493:	0f 45 c2             	cmovne %edx,%eax
  800496:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800499:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80049d:	7e 06                	jle    8004a5 <vprintfmt+0x17f>
  80049f:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004a3:	75 0d                	jne    8004b2 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004a8:	89 c7                	mov    %eax,%edi
  8004aa:	03 45 e0             	add    -0x20(%ebp),%eax
  8004ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b0:	eb 55                	jmp    800507 <vprintfmt+0x1e1>
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b8:	ff 75 cc             	pushl  -0x34(%ebp)
  8004bb:	e8 45 03 00 00       	call   800805 <strnlen>
  8004c0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004c3:	29 c2                	sub    %eax,%edx
  8004c5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004c8:	83 c4 10             	add    $0x10,%esp
  8004cb:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004cd:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d4:	85 ff                	test   %edi,%edi
  8004d6:	7e 11                	jle    8004e9 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	53                   	push   %ebx
  8004dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8004df:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e1:	83 ef 01             	sub    $0x1,%edi
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	eb eb                	jmp    8004d4 <vprintfmt+0x1ae>
  8004e9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004ec:	85 d2                	test   %edx,%edx
  8004ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f3:	0f 49 c2             	cmovns %edx,%eax
  8004f6:	29 c2                	sub    %eax,%edx
  8004f8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004fb:	eb a8                	jmp    8004a5 <vprintfmt+0x17f>
					putch(ch, putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	53                   	push   %ebx
  800501:	52                   	push   %edx
  800502:	ff d6                	call   *%esi
  800504:	83 c4 10             	add    $0x10,%esp
  800507:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80050a:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050c:	83 c7 01             	add    $0x1,%edi
  80050f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800513:	0f be d0             	movsbl %al,%edx
  800516:	85 d2                	test   %edx,%edx
  800518:	74 4b                	je     800565 <vprintfmt+0x23f>
  80051a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051e:	78 06                	js     800526 <vprintfmt+0x200>
  800520:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800524:	78 1e                	js     800544 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800526:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80052a:	74 d1                	je     8004fd <vprintfmt+0x1d7>
  80052c:	0f be c0             	movsbl %al,%eax
  80052f:	83 e8 20             	sub    $0x20,%eax
  800532:	83 f8 5e             	cmp    $0x5e,%eax
  800535:	76 c6                	jbe    8004fd <vprintfmt+0x1d7>
					putch('?', putdat);
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	53                   	push   %ebx
  80053b:	6a 3f                	push   $0x3f
  80053d:	ff d6                	call   *%esi
  80053f:	83 c4 10             	add    $0x10,%esp
  800542:	eb c3                	jmp    800507 <vprintfmt+0x1e1>
  800544:	89 cf                	mov    %ecx,%edi
  800546:	eb 0e                	jmp    800556 <vprintfmt+0x230>
				putch(' ', putdat);
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	53                   	push   %ebx
  80054c:	6a 20                	push   $0x20
  80054e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800550:	83 ef 01             	sub    $0x1,%edi
  800553:	83 c4 10             	add    $0x10,%esp
  800556:	85 ff                	test   %edi,%edi
  800558:	7f ee                	jg     800548 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80055a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80055d:	89 45 14             	mov    %eax,0x14(%ebp)
  800560:	e9 23 01 00 00       	jmp    800688 <vprintfmt+0x362>
  800565:	89 cf                	mov    %ecx,%edi
  800567:	eb ed                	jmp    800556 <vprintfmt+0x230>
	if (lflag >= 2)
  800569:	83 f9 01             	cmp    $0x1,%ecx
  80056c:	7f 1b                	jg     800589 <vprintfmt+0x263>
	else if (lflag)
  80056e:	85 c9                	test   %ecx,%ecx
  800570:	74 63                	je     8005d5 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8b 00                	mov    (%eax),%eax
  800577:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057a:	99                   	cltd   
  80057b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8d 40 04             	lea    0x4(%eax),%eax
  800584:	89 45 14             	mov    %eax,0x14(%ebp)
  800587:	eb 17                	jmp    8005a0 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8b 50 04             	mov    0x4(%eax),%edx
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800594:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8d 40 08             	lea    0x8(%eax),%eax
  80059d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005a0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005a6:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005ab:	85 c9                	test   %ecx,%ecx
  8005ad:	0f 89 bb 00 00 00    	jns    80066e <vprintfmt+0x348>
				putch('-', putdat);
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	53                   	push   %ebx
  8005b7:	6a 2d                	push   $0x2d
  8005b9:	ff d6                	call   *%esi
				num = -(long long) num;
  8005bb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005be:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c1:	f7 da                	neg    %edx
  8005c3:	83 d1 00             	adc    $0x0,%ecx
  8005c6:	f7 d9                	neg    %ecx
  8005c8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d0:	e9 99 00 00 00       	jmp    80066e <vprintfmt+0x348>
		return va_arg(*ap, int);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8b 00                	mov    (%eax),%eax
  8005da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005dd:	99                   	cltd   
  8005de:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8d 40 04             	lea    0x4(%eax),%eax
  8005e7:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ea:	eb b4                	jmp    8005a0 <vprintfmt+0x27a>
	if (lflag >= 2)
  8005ec:	83 f9 01             	cmp    $0x1,%ecx
  8005ef:	7f 1b                	jg     80060c <vprintfmt+0x2e6>
	else if (lflag)
  8005f1:	85 c9                	test   %ecx,%ecx
  8005f3:	74 2c                	je     800621 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8b 10                	mov    (%eax),%edx
  8005fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ff:	8d 40 04             	lea    0x4(%eax),%eax
  800602:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800605:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80060a:	eb 62                	jmp    80066e <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8b 10                	mov    (%eax),%edx
  800611:	8b 48 04             	mov    0x4(%eax),%ecx
  800614:	8d 40 08             	lea    0x8(%eax),%eax
  800617:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80061a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80061f:	eb 4d                	jmp    80066e <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8b 10                	mov    (%eax),%edx
  800626:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062b:	8d 40 04             	lea    0x4(%eax),%eax
  80062e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800631:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800636:	eb 36                	jmp    80066e <vprintfmt+0x348>
	if (lflag >= 2)
  800638:	83 f9 01             	cmp    $0x1,%ecx
  80063b:	7f 17                	jg     800654 <vprintfmt+0x32e>
	else if (lflag)
  80063d:	85 c9                	test   %ecx,%ecx
  80063f:	74 6e                	je     8006af <vprintfmt+0x389>
		return va_arg(*ap, long);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8b 10                	mov    (%eax),%edx
  800646:	89 d0                	mov    %edx,%eax
  800648:	99                   	cltd   
  800649:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80064c:	8d 49 04             	lea    0x4(%ecx),%ecx
  80064f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800652:	eb 11                	jmp    800665 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8b 50 04             	mov    0x4(%eax),%edx
  80065a:	8b 00                	mov    (%eax),%eax
  80065c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80065f:	8d 49 08             	lea    0x8(%ecx),%ecx
  800662:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800665:	89 d1                	mov    %edx,%ecx
  800667:	89 c2                	mov    %eax,%edx
            base = 8;
  800669:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80066e:	83 ec 0c             	sub    $0xc,%esp
  800671:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800675:	57                   	push   %edi
  800676:	ff 75 e0             	pushl  -0x20(%ebp)
  800679:	50                   	push   %eax
  80067a:	51                   	push   %ecx
  80067b:	52                   	push   %edx
  80067c:	89 da                	mov    %ebx,%edx
  80067e:	89 f0                	mov    %esi,%eax
  800680:	e8 b6 fb ff ff       	call   80023b <printnum>
			break;
  800685:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800688:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80068b:	83 c7 01             	add    $0x1,%edi
  80068e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800692:	83 f8 25             	cmp    $0x25,%eax
  800695:	0f 84 a6 fc ff ff    	je     800341 <vprintfmt+0x1b>
			if (ch == '\0')
  80069b:	85 c0                	test   %eax,%eax
  80069d:	0f 84 ce 00 00 00    	je     800771 <vprintfmt+0x44b>
			putch(ch, putdat);
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	50                   	push   %eax
  8006a8:	ff d6                	call   *%esi
  8006aa:	83 c4 10             	add    $0x10,%esp
  8006ad:	eb dc                	jmp    80068b <vprintfmt+0x365>
		return va_arg(*ap, int);
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8b 10                	mov    (%eax),%edx
  8006b4:	89 d0                	mov    %edx,%eax
  8006b6:	99                   	cltd   
  8006b7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006ba:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006bd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006c0:	eb a3                	jmp    800665 <vprintfmt+0x33f>
			putch('0', putdat);
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	53                   	push   %ebx
  8006c6:	6a 30                	push   $0x30
  8006c8:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ca:	83 c4 08             	add    $0x8,%esp
  8006cd:	53                   	push   %ebx
  8006ce:	6a 78                	push   $0x78
  8006d0:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8b 10                	mov    (%eax),%edx
  8006d7:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006dc:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006df:	8d 40 04             	lea    0x4(%eax),%eax
  8006e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e5:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006ea:	eb 82                	jmp    80066e <vprintfmt+0x348>
	if (lflag >= 2)
  8006ec:	83 f9 01             	cmp    $0x1,%ecx
  8006ef:	7f 1e                	jg     80070f <vprintfmt+0x3e9>
	else if (lflag)
  8006f1:	85 c9                	test   %ecx,%ecx
  8006f3:	74 32                	je     800727 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  8006f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f8:	8b 10                	mov    (%eax),%edx
  8006fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ff:	8d 40 04             	lea    0x4(%eax),%eax
  800702:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800705:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80070a:	e9 5f ff ff ff       	jmp    80066e <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8b 10                	mov    (%eax),%edx
  800714:	8b 48 04             	mov    0x4(%eax),%ecx
  800717:	8d 40 08             	lea    0x8(%eax),%eax
  80071a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800722:	e9 47 ff ff ff       	jmp    80066e <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800727:	8b 45 14             	mov    0x14(%ebp),%eax
  80072a:	8b 10                	mov    (%eax),%edx
  80072c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800731:	8d 40 04             	lea    0x4(%eax),%eax
  800734:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800737:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80073c:	e9 2d ff ff ff       	jmp    80066e <vprintfmt+0x348>
			putch(ch, putdat);
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	53                   	push   %ebx
  800745:	6a 25                	push   $0x25
  800747:	ff d6                	call   *%esi
			break;
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	e9 37 ff ff ff       	jmp    800688 <vprintfmt+0x362>
			putch('%', putdat);
  800751:	83 ec 08             	sub    $0x8,%esp
  800754:	53                   	push   %ebx
  800755:	6a 25                	push   $0x25
  800757:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	89 f8                	mov    %edi,%eax
  80075e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800762:	74 05                	je     800769 <vprintfmt+0x443>
  800764:	83 e8 01             	sub    $0x1,%eax
  800767:	eb f5                	jmp    80075e <vprintfmt+0x438>
  800769:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80076c:	e9 17 ff ff ff       	jmp    800688 <vprintfmt+0x362>
}
  800771:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800774:	5b                   	pop    %ebx
  800775:	5e                   	pop    %esi
  800776:	5f                   	pop    %edi
  800777:	5d                   	pop    %ebp
  800778:	c3                   	ret    

00800779 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800779:	f3 0f 1e fb          	endbr32 
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	83 ec 18             	sub    $0x18,%esp
  800783:	8b 45 08             	mov    0x8(%ebp),%eax
  800786:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800789:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80078c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800790:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800793:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80079a:	85 c0                	test   %eax,%eax
  80079c:	74 26                	je     8007c4 <vsnprintf+0x4b>
  80079e:	85 d2                	test   %edx,%edx
  8007a0:	7e 22                	jle    8007c4 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007a2:	ff 75 14             	pushl  0x14(%ebp)
  8007a5:	ff 75 10             	pushl  0x10(%ebp)
  8007a8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ab:	50                   	push   %eax
  8007ac:	68 e4 02 80 00       	push   $0x8002e4
  8007b1:	e8 70 fb ff ff       	call   800326 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007bf:	83 c4 10             	add    $0x10,%esp
}
  8007c2:	c9                   	leave  
  8007c3:	c3                   	ret    
		return -E_INVAL;
  8007c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c9:	eb f7                	jmp    8007c2 <vsnprintf+0x49>

008007cb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007cb:	f3 0f 1e fb          	endbr32 
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d8:	50                   	push   %eax
  8007d9:	ff 75 10             	pushl  0x10(%ebp)
  8007dc:	ff 75 0c             	pushl  0xc(%ebp)
  8007df:	ff 75 08             	pushl  0x8(%ebp)
  8007e2:	e8 92 ff ff ff       	call   800779 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e7:	c9                   	leave  
  8007e8:	c3                   	ret    

008007e9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e9:	f3 0f 1e fb          	endbr32 
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007fc:	74 05                	je     800803 <strlen+0x1a>
		n++;
  8007fe:	83 c0 01             	add    $0x1,%eax
  800801:	eb f5                	jmp    8007f8 <strlen+0xf>
	return n;
}
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800805:	f3 0f 1e fb          	endbr32 
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
  800817:	39 d0                	cmp    %edx,%eax
  800819:	74 0d                	je     800828 <strnlen+0x23>
  80081b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80081f:	74 05                	je     800826 <strnlen+0x21>
		n++;
  800821:	83 c0 01             	add    $0x1,%eax
  800824:	eb f1                	jmp    800817 <strnlen+0x12>
  800826:	89 c2                	mov    %eax,%edx
	return n;
}
  800828:	89 d0                	mov    %edx,%eax
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082c:	f3 0f 1e fb          	endbr32 
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	53                   	push   %ebx
  800834:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800837:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80083a:	b8 00 00 00 00       	mov    $0x0,%eax
  80083f:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800843:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800846:	83 c0 01             	add    $0x1,%eax
  800849:	84 d2                	test   %dl,%dl
  80084b:	75 f2                	jne    80083f <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80084d:	89 c8                	mov    %ecx,%eax
  80084f:	5b                   	pop    %ebx
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800852:	f3 0f 1e fb          	endbr32 
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	53                   	push   %ebx
  80085a:	83 ec 10             	sub    $0x10,%esp
  80085d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800860:	53                   	push   %ebx
  800861:	e8 83 ff ff ff       	call   8007e9 <strlen>
  800866:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800869:	ff 75 0c             	pushl  0xc(%ebp)
  80086c:	01 d8                	add    %ebx,%eax
  80086e:	50                   	push   %eax
  80086f:	e8 b8 ff ff ff       	call   80082c <strcpy>
	return dst;
}
  800874:	89 d8                	mov    %ebx,%eax
  800876:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800879:	c9                   	leave  
  80087a:	c3                   	ret    

0080087b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80087b:	f3 0f 1e fb          	endbr32 
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	56                   	push   %esi
  800883:	53                   	push   %ebx
  800884:	8b 75 08             	mov    0x8(%ebp),%esi
  800887:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088a:	89 f3                	mov    %esi,%ebx
  80088c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80088f:	89 f0                	mov    %esi,%eax
  800891:	39 d8                	cmp    %ebx,%eax
  800893:	74 11                	je     8008a6 <strncpy+0x2b>
		*dst++ = *src;
  800895:	83 c0 01             	add    $0x1,%eax
  800898:	0f b6 0a             	movzbl (%edx),%ecx
  80089b:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80089e:	80 f9 01             	cmp    $0x1,%cl
  8008a1:	83 da ff             	sbb    $0xffffffff,%edx
  8008a4:	eb eb                	jmp    800891 <strncpy+0x16>
	}
	return ret;
}
  8008a6:	89 f0                	mov    %esi,%eax
  8008a8:	5b                   	pop    %ebx
  8008a9:	5e                   	pop    %esi
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ac:	f3 0f 1e fb          	endbr32 
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	56                   	push   %esi
  8008b4:	53                   	push   %ebx
  8008b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008bb:	8b 55 10             	mov    0x10(%ebp),%edx
  8008be:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c0:	85 d2                	test   %edx,%edx
  8008c2:	74 21                	je     8008e5 <strlcpy+0x39>
  8008c4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008c8:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008ca:	39 c2                	cmp    %eax,%edx
  8008cc:	74 14                	je     8008e2 <strlcpy+0x36>
  8008ce:	0f b6 19             	movzbl (%ecx),%ebx
  8008d1:	84 db                	test   %bl,%bl
  8008d3:	74 0b                	je     8008e0 <strlcpy+0x34>
			*dst++ = *src++;
  8008d5:	83 c1 01             	add    $0x1,%ecx
  8008d8:	83 c2 01             	add    $0x1,%edx
  8008db:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008de:	eb ea                	jmp    8008ca <strlcpy+0x1e>
  8008e0:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008e2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008e5:	29 f0                	sub    %esi,%eax
}
  8008e7:	5b                   	pop    %ebx
  8008e8:	5e                   	pop    %esi
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008eb:	f3 0f 1e fb          	endbr32 
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f8:	0f b6 01             	movzbl (%ecx),%eax
  8008fb:	84 c0                	test   %al,%al
  8008fd:	74 0c                	je     80090b <strcmp+0x20>
  8008ff:	3a 02                	cmp    (%edx),%al
  800901:	75 08                	jne    80090b <strcmp+0x20>
		p++, q++;
  800903:	83 c1 01             	add    $0x1,%ecx
  800906:	83 c2 01             	add    $0x1,%edx
  800909:	eb ed                	jmp    8008f8 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80090b:	0f b6 c0             	movzbl %al,%eax
  80090e:	0f b6 12             	movzbl (%edx),%edx
  800911:	29 d0                	sub    %edx,%eax
}
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800915:	f3 0f 1e fb          	endbr32 
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	53                   	push   %ebx
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	8b 55 0c             	mov    0xc(%ebp),%edx
  800923:	89 c3                	mov    %eax,%ebx
  800925:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800928:	eb 06                	jmp    800930 <strncmp+0x1b>
		n--, p++, q++;
  80092a:	83 c0 01             	add    $0x1,%eax
  80092d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800930:	39 d8                	cmp    %ebx,%eax
  800932:	74 16                	je     80094a <strncmp+0x35>
  800934:	0f b6 08             	movzbl (%eax),%ecx
  800937:	84 c9                	test   %cl,%cl
  800939:	74 04                	je     80093f <strncmp+0x2a>
  80093b:	3a 0a                	cmp    (%edx),%cl
  80093d:	74 eb                	je     80092a <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80093f:	0f b6 00             	movzbl (%eax),%eax
  800942:	0f b6 12             	movzbl (%edx),%edx
  800945:	29 d0                	sub    %edx,%eax
}
  800947:	5b                   	pop    %ebx
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    
		return 0;
  80094a:	b8 00 00 00 00       	mov    $0x0,%eax
  80094f:	eb f6                	jmp    800947 <strncmp+0x32>

00800951 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800951:	f3 0f 1e fb          	endbr32 
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80095f:	0f b6 10             	movzbl (%eax),%edx
  800962:	84 d2                	test   %dl,%dl
  800964:	74 09                	je     80096f <strchr+0x1e>
		if (*s == c)
  800966:	38 ca                	cmp    %cl,%dl
  800968:	74 0a                	je     800974 <strchr+0x23>
	for (; *s; s++)
  80096a:	83 c0 01             	add    $0x1,%eax
  80096d:	eb f0                	jmp    80095f <strchr+0xe>
			return (char *) s;
	return 0;
  80096f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800976:	f3 0f 1e fb          	endbr32 
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800984:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800987:	38 ca                	cmp    %cl,%dl
  800989:	74 09                	je     800994 <strfind+0x1e>
  80098b:	84 d2                	test   %dl,%dl
  80098d:	74 05                	je     800994 <strfind+0x1e>
	for (; *s; s++)
  80098f:	83 c0 01             	add    $0x1,%eax
  800992:	eb f0                	jmp    800984 <strfind+0xe>
			break;
	return (char *) s;
}
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800996:	f3 0f 1e fb          	endbr32 
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	57                   	push   %edi
  80099e:	56                   	push   %esi
  80099f:	53                   	push   %ebx
  8009a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a6:	85 c9                	test   %ecx,%ecx
  8009a8:	74 31                	je     8009db <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009aa:	89 f8                	mov    %edi,%eax
  8009ac:	09 c8                	or     %ecx,%eax
  8009ae:	a8 03                	test   $0x3,%al
  8009b0:	75 23                	jne    8009d5 <memset+0x3f>
		c &= 0xFF;
  8009b2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b6:	89 d3                	mov    %edx,%ebx
  8009b8:	c1 e3 08             	shl    $0x8,%ebx
  8009bb:	89 d0                	mov    %edx,%eax
  8009bd:	c1 e0 18             	shl    $0x18,%eax
  8009c0:	89 d6                	mov    %edx,%esi
  8009c2:	c1 e6 10             	shl    $0x10,%esi
  8009c5:	09 f0                	or     %esi,%eax
  8009c7:	09 c2                	or     %eax,%edx
  8009c9:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009cb:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009ce:	89 d0                	mov    %edx,%eax
  8009d0:	fc                   	cld    
  8009d1:	f3 ab                	rep stos %eax,%es:(%edi)
  8009d3:	eb 06                	jmp    8009db <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d8:	fc                   	cld    
  8009d9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009db:	89 f8                	mov    %edi,%eax
  8009dd:	5b                   	pop    %ebx
  8009de:	5e                   	pop    %esi
  8009df:	5f                   	pop    %edi
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e2:	f3 0f 1e fb          	endbr32 
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	57                   	push   %edi
  8009ea:	56                   	push   %esi
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f4:	39 c6                	cmp    %eax,%esi
  8009f6:	73 32                	jae    800a2a <memmove+0x48>
  8009f8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009fb:	39 c2                	cmp    %eax,%edx
  8009fd:	76 2b                	jbe    800a2a <memmove+0x48>
		s += n;
		d += n;
  8009ff:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a02:	89 fe                	mov    %edi,%esi
  800a04:	09 ce                	or     %ecx,%esi
  800a06:	09 d6                	or     %edx,%esi
  800a08:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a0e:	75 0e                	jne    800a1e <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a10:	83 ef 04             	sub    $0x4,%edi
  800a13:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a16:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a19:	fd                   	std    
  800a1a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1c:	eb 09                	jmp    800a27 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a1e:	83 ef 01             	sub    $0x1,%edi
  800a21:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a24:	fd                   	std    
  800a25:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a27:	fc                   	cld    
  800a28:	eb 1a                	jmp    800a44 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2a:	89 c2                	mov    %eax,%edx
  800a2c:	09 ca                	or     %ecx,%edx
  800a2e:	09 f2                	or     %esi,%edx
  800a30:	f6 c2 03             	test   $0x3,%dl
  800a33:	75 0a                	jne    800a3f <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a35:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a38:	89 c7                	mov    %eax,%edi
  800a3a:	fc                   	cld    
  800a3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3d:	eb 05                	jmp    800a44 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a3f:	89 c7                	mov    %eax,%edi
  800a41:	fc                   	cld    
  800a42:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a44:	5e                   	pop    %esi
  800a45:	5f                   	pop    %edi
  800a46:	5d                   	pop    %ebp
  800a47:	c3                   	ret    

00800a48 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a48:	f3 0f 1e fb          	endbr32 
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a52:	ff 75 10             	pushl  0x10(%ebp)
  800a55:	ff 75 0c             	pushl  0xc(%ebp)
  800a58:	ff 75 08             	pushl  0x8(%ebp)
  800a5b:	e8 82 ff ff ff       	call   8009e2 <memmove>
}
  800a60:	c9                   	leave  
  800a61:	c3                   	ret    

00800a62 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a62:	f3 0f 1e fb          	endbr32 
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	56                   	push   %esi
  800a6a:	53                   	push   %ebx
  800a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a71:	89 c6                	mov    %eax,%esi
  800a73:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a76:	39 f0                	cmp    %esi,%eax
  800a78:	74 1c                	je     800a96 <memcmp+0x34>
		if (*s1 != *s2)
  800a7a:	0f b6 08             	movzbl (%eax),%ecx
  800a7d:	0f b6 1a             	movzbl (%edx),%ebx
  800a80:	38 d9                	cmp    %bl,%cl
  800a82:	75 08                	jne    800a8c <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a84:	83 c0 01             	add    $0x1,%eax
  800a87:	83 c2 01             	add    $0x1,%edx
  800a8a:	eb ea                	jmp    800a76 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a8c:	0f b6 c1             	movzbl %cl,%eax
  800a8f:	0f b6 db             	movzbl %bl,%ebx
  800a92:	29 d8                	sub    %ebx,%eax
  800a94:	eb 05                	jmp    800a9b <memcmp+0x39>
	}

	return 0;
  800a96:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a9f:	f3 0f 1e fb          	endbr32 
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aac:	89 c2                	mov    %eax,%edx
  800aae:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ab1:	39 d0                	cmp    %edx,%eax
  800ab3:	73 09                	jae    800abe <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab5:	38 08                	cmp    %cl,(%eax)
  800ab7:	74 05                	je     800abe <memfind+0x1f>
	for (; s < ends; s++)
  800ab9:	83 c0 01             	add    $0x1,%eax
  800abc:	eb f3                	jmp    800ab1 <memfind+0x12>
			break;
	return (void *) s;
}
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ac0:	f3 0f 1e fb          	endbr32 
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
  800aca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800acd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad0:	eb 03                	jmp    800ad5 <strtol+0x15>
		s++;
  800ad2:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ad5:	0f b6 01             	movzbl (%ecx),%eax
  800ad8:	3c 20                	cmp    $0x20,%al
  800ada:	74 f6                	je     800ad2 <strtol+0x12>
  800adc:	3c 09                	cmp    $0x9,%al
  800ade:	74 f2                	je     800ad2 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ae0:	3c 2b                	cmp    $0x2b,%al
  800ae2:	74 2a                	je     800b0e <strtol+0x4e>
	int neg = 0;
  800ae4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ae9:	3c 2d                	cmp    $0x2d,%al
  800aeb:	74 2b                	je     800b18 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aed:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800af3:	75 0f                	jne    800b04 <strtol+0x44>
  800af5:	80 39 30             	cmpb   $0x30,(%ecx)
  800af8:	74 28                	je     800b22 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800afa:	85 db                	test   %ebx,%ebx
  800afc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b01:	0f 44 d8             	cmove  %eax,%ebx
  800b04:	b8 00 00 00 00       	mov    $0x0,%eax
  800b09:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b0c:	eb 46                	jmp    800b54 <strtol+0x94>
		s++;
  800b0e:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b11:	bf 00 00 00 00       	mov    $0x0,%edi
  800b16:	eb d5                	jmp    800aed <strtol+0x2d>
		s++, neg = 1;
  800b18:	83 c1 01             	add    $0x1,%ecx
  800b1b:	bf 01 00 00 00       	mov    $0x1,%edi
  800b20:	eb cb                	jmp    800aed <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b22:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b26:	74 0e                	je     800b36 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b28:	85 db                	test   %ebx,%ebx
  800b2a:	75 d8                	jne    800b04 <strtol+0x44>
		s++, base = 8;
  800b2c:	83 c1 01             	add    $0x1,%ecx
  800b2f:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b34:	eb ce                	jmp    800b04 <strtol+0x44>
		s += 2, base = 16;
  800b36:	83 c1 02             	add    $0x2,%ecx
  800b39:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b3e:	eb c4                	jmp    800b04 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b40:	0f be d2             	movsbl %dl,%edx
  800b43:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b46:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b49:	7d 3a                	jge    800b85 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b4b:	83 c1 01             	add    $0x1,%ecx
  800b4e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b52:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b54:	0f b6 11             	movzbl (%ecx),%edx
  800b57:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b5a:	89 f3                	mov    %esi,%ebx
  800b5c:	80 fb 09             	cmp    $0x9,%bl
  800b5f:	76 df                	jbe    800b40 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b61:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b64:	89 f3                	mov    %esi,%ebx
  800b66:	80 fb 19             	cmp    $0x19,%bl
  800b69:	77 08                	ja     800b73 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b6b:	0f be d2             	movsbl %dl,%edx
  800b6e:	83 ea 57             	sub    $0x57,%edx
  800b71:	eb d3                	jmp    800b46 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b73:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b76:	89 f3                	mov    %esi,%ebx
  800b78:	80 fb 19             	cmp    $0x19,%bl
  800b7b:	77 08                	ja     800b85 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b7d:	0f be d2             	movsbl %dl,%edx
  800b80:	83 ea 37             	sub    $0x37,%edx
  800b83:	eb c1                	jmp    800b46 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b85:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b89:	74 05                	je     800b90 <strtol+0xd0>
		*endptr = (char *) s;
  800b8b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b8e:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b90:	89 c2                	mov    %eax,%edx
  800b92:	f7 da                	neg    %edx
  800b94:	85 ff                	test   %edi,%edi
  800b96:	0f 45 c2             	cmovne %edx,%eax
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b9e:	f3 0f 1e fb          	endbr32 
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bad:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb3:	89 c3                	mov    %eax,%ebx
  800bb5:	89 c7                	mov    %eax,%edi
  800bb7:	89 c6                	mov    %eax,%esi
  800bb9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5f                   	pop    %edi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bc0:	f3 0f 1e fb          	endbr32 
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bca:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcf:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd4:	89 d1                	mov    %edx,%ecx
  800bd6:	89 d3                	mov    %edx,%ebx
  800bd8:	89 d7                	mov    %edx,%edi
  800bda:	89 d6                	mov    %edx,%esi
  800bdc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800be3:	f3 0f 1e fb          	endbr32 
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf8:	b8 03 00 00 00       	mov    $0x3,%eax
  800bfd:	89 cb                	mov    %ecx,%ebx
  800bff:	89 cf                	mov    %ecx,%edi
  800c01:	89 ce                	mov    %ecx,%esi
  800c03:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c05:	85 c0                	test   %eax,%eax
  800c07:	7f 08                	jg     800c11 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5f                   	pop    %edi
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c11:	83 ec 0c             	sub    $0xc,%esp
  800c14:	50                   	push   %eax
  800c15:	6a 03                	push   $0x3
  800c17:	68 1f 15 80 00       	push   $0x80151f
  800c1c:	6a 23                	push   $0x23
  800c1e:	68 3c 15 80 00       	push   $0x80153c
  800c23:	e8 14 f5 ff ff       	call   80013c <_panic>

00800c28 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c28:	f3 0f 1e fb          	endbr32 
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c32:	ba 00 00 00 00       	mov    $0x0,%edx
  800c37:	b8 02 00 00 00       	mov    $0x2,%eax
  800c3c:	89 d1                	mov    %edx,%ecx
  800c3e:	89 d3                	mov    %edx,%ebx
  800c40:	89 d7                	mov    %edx,%edi
  800c42:	89 d6                	mov    %edx,%esi
  800c44:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <sys_yield>:

void
sys_yield(void)
{
  800c4b:	f3 0f 1e fb          	endbr32 
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c55:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c5f:	89 d1                	mov    %edx,%ecx
  800c61:	89 d3                	mov    %edx,%ebx
  800c63:	89 d7                	mov    %edx,%edi
  800c65:	89 d6                	mov    %edx,%esi
  800c67:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c6e:	f3 0f 1e fb          	endbr32 
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	57                   	push   %edi
  800c76:	56                   	push   %esi
  800c77:	53                   	push   %ebx
  800c78:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7b:	be 00 00 00 00       	mov    $0x0,%esi
  800c80:	8b 55 08             	mov    0x8(%ebp),%edx
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c86:	b8 04 00 00 00       	mov    $0x4,%eax
  800c8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8e:	89 f7                	mov    %esi,%edi
  800c90:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c92:	85 c0                	test   %eax,%eax
  800c94:	7f 08                	jg     800c9e <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9e:	83 ec 0c             	sub    $0xc,%esp
  800ca1:	50                   	push   %eax
  800ca2:	6a 04                	push   $0x4
  800ca4:	68 1f 15 80 00       	push   $0x80151f
  800ca9:	6a 23                	push   $0x23
  800cab:	68 3c 15 80 00       	push   $0x80153c
  800cb0:	e8 87 f4 ff ff       	call   80013c <_panic>

00800cb5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cb5:	f3 0f 1e fb          	endbr32 
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	57                   	push   %edi
  800cbd:	56                   	push   %esi
  800cbe:	53                   	push   %ebx
  800cbf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc8:	b8 05 00 00 00       	mov    $0x5,%eax
  800ccd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd3:	8b 75 18             	mov    0x18(%ebp),%esi
  800cd6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd8:	85 c0                	test   %eax,%eax
  800cda:	7f 08                	jg     800ce4 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	50                   	push   %eax
  800ce8:	6a 05                	push   $0x5
  800cea:	68 1f 15 80 00       	push   $0x80151f
  800cef:	6a 23                	push   $0x23
  800cf1:	68 3c 15 80 00       	push   $0x80153c
  800cf6:	e8 41 f4 ff ff       	call   80013c <_panic>

00800cfb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cfb:	f3 0f 1e fb          	endbr32 
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	57                   	push   %edi
  800d03:	56                   	push   %esi
  800d04:	53                   	push   %ebx
  800d05:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d13:	b8 06 00 00 00       	mov    $0x6,%eax
  800d18:	89 df                	mov    %ebx,%edi
  800d1a:	89 de                	mov    %ebx,%esi
  800d1c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d1e:	85 c0                	test   %eax,%eax
  800d20:	7f 08                	jg     800d2a <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	83 ec 0c             	sub    $0xc,%esp
  800d2d:	50                   	push   %eax
  800d2e:	6a 06                	push   $0x6
  800d30:	68 1f 15 80 00       	push   $0x80151f
  800d35:	6a 23                	push   $0x23
  800d37:	68 3c 15 80 00       	push   $0x80153c
  800d3c:	e8 fb f3 ff ff       	call   80013c <_panic>

00800d41 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d41:	f3 0f 1e fb          	endbr32 
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
  800d4b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	b8 08 00 00 00       	mov    $0x8,%eax
  800d5e:	89 df                	mov    %ebx,%edi
  800d60:	89 de                	mov    %ebx,%esi
  800d62:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d64:	85 c0                	test   %eax,%eax
  800d66:	7f 08                	jg     800d70 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d70:	83 ec 0c             	sub    $0xc,%esp
  800d73:	50                   	push   %eax
  800d74:	6a 08                	push   $0x8
  800d76:	68 1f 15 80 00       	push   $0x80151f
  800d7b:	6a 23                	push   $0x23
  800d7d:	68 3c 15 80 00       	push   $0x80153c
  800d82:	e8 b5 f3 ff ff       	call   80013c <_panic>

00800d87 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d87:	f3 0f 1e fb          	endbr32 
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
  800d91:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d94:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9f:	b8 09 00 00 00       	mov    $0x9,%eax
  800da4:	89 df                	mov    %ebx,%edi
  800da6:	89 de                	mov    %ebx,%esi
  800da8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800daa:	85 c0                	test   %eax,%eax
  800dac:	7f 08                	jg     800db6 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db6:	83 ec 0c             	sub    $0xc,%esp
  800db9:	50                   	push   %eax
  800dba:	6a 09                	push   $0x9
  800dbc:	68 1f 15 80 00       	push   $0x80151f
  800dc1:	6a 23                	push   $0x23
  800dc3:	68 3c 15 80 00       	push   $0x80153c
  800dc8:	e8 6f f3 ff ff       	call   80013c <_panic>

00800dcd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dcd:	f3 0f 1e fb          	endbr32 
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	57                   	push   %edi
  800dd5:	56                   	push   %esi
  800dd6:	53                   	push   %ebx
  800dd7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddf:	8b 55 08             	mov    0x8(%ebp),%edx
  800de2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dea:	89 df                	mov    %ebx,%edi
  800dec:	89 de                	mov    %ebx,%esi
  800dee:	cd 30                	int    $0x30
	if(check && ret > 0)
  800df0:	85 c0                	test   %eax,%eax
  800df2:	7f 08                	jg     800dfc <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800df4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df7:	5b                   	pop    %ebx
  800df8:	5e                   	pop    %esi
  800df9:	5f                   	pop    %edi
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfc:	83 ec 0c             	sub    $0xc,%esp
  800dff:	50                   	push   %eax
  800e00:	6a 0a                	push   $0xa
  800e02:	68 1f 15 80 00       	push   $0x80151f
  800e07:	6a 23                	push   $0x23
  800e09:	68 3c 15 80 00       	push   $0x80153c
  800e0e:	e8 29 f3 ff ff       	call   80013c <_panic>

00800e13 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e13:	f3 0f 1e fb          	endbr32 
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	57                   	push   %edi
  800e1b:	56                   	push   %esi
  800e1c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e23:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e28:	be 00 00 00 00       	mov    $0x0,%esi
  800e2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e30:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e33:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    

00800e3a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e3a:	f3 0f 1e fb          	endbr32 
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
  800e41:	57                   	push   %edi
  800e42:	56                   	push   %esi
  800e43:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e44:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e49:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e51:	89 cb                	mov    %ecx,%ebx
  800e53:	89 cf                	mov    %ecx,%edi
  800e55:	89 ce                	mov    %ecx,%esi
  800e57:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 0, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e59:	5b                   	pop    %ebx
  800e5a:	5e                   	pop    %esi
  800e5b:	5f                   	pop    %edi
  800e5c:	5d                   	pop    %ebp
  800e5d:	c3                   	ret    

00800e5e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e5e:	f3 0f 1e fb          	endbr32 
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e68:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e6f:	74 0a                	je     800e7b <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e71:	8b 45 08             	mov    0x8(%ebp),%eax
  800e74:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800e79:	c9                   	leave  
  800e7a:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  800e7b:	83 ec 0c             	sub    $0xc,%esp
  800e7e:	68 4a 15 80 00       	push   $0x80154a
  800e83:	e8 9b f3 ff ff       	call   800223 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  800e88:	83 c4 0c             	add    $0xc,%esp
  800e8b:	6a 07                	push   $0x7
  800e8d:	68 00 f0 bf ee       	push   $0xeebff000
  800e92:	6a 00                	push   $0x0
  800e94:	e8 d5 fd ff ff       	call   800c6e <sys_page_alloc>
  800e99:	83 c4 10             	add    $0x10,%esp
  800e9c:	85 c0                	test   %eax,%eax
  800e9e:	78 2a                	js     800eca <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  800ea0:	83 ec 08             	sub    $0x8,%esp
  800ea3:	68 de 0e 80 00       	push   $0x800ede
  800ea8:	6a 00                	push   $0x0
  800eaa:	e8 1e ff ff ff       	call   800dcd <sys_env_set_pgfault_upcall>
  800eaf:	83 c4 10             	add    $0x10,%esp
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	79 bb                	jns    800e71 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  800eb6:	83 ec 04             	sub    $0x4,%esp
  800eb9:	68 88 15 80 00       	push   $0x801588
  800ebe:	6a 25                	push   $0x25
  800ec0:	68 77 15 80 00       	push   $0x801577
  800ec5:	e8 72 f2 ff ff       	call   80013c <_panic>
            panic("Allocation of UXSTACK failed!");
  800eca:	83 ec 04             	sub    $0x4,%esp
  800ecd:	68 59 15 80 00       	push   $0x801559
  800ed2:	6a 22                	push   $0x22
  800ed4:	68 77 15 80 00       	push   $0x801577
  800ed9:	e8 5e f2 ff ff       	call   80013c <_panic>

00800ede <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ede:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800edf:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800ee4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800ee6:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  800ee9:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  800eed:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  800ef1:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  800ef4:	83 c4 08             	add    $0x8,%esp
    popa
  800ef7:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  800ef8:	83 c4 04             	add    $0x4,%esp
    popf
  800efb:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  800efc:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  800eff:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  800f03:	c3                   	ret    
  800f04:	66 90                	xchg   %ax,%ax
  800f06:	66 90                	xchg   %ax,%ax
  800f08:	66 90                	xchg   %ax,%ax
  800f0a:	66 90                	xchg   %ax,%ax
  800f0c:	66 90                	xchg   %ax,%ax
  800f0e:	66 90                	xchg   %ax,%ax

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
