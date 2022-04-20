
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
  800044:	68 40 11 80 00       	push   $0x801140
  800049:	e8 cb 01 00 00       	call   800219 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004e:	83 c4 0c             	add    $0xc,%esp
  800051:	6a 07                	push   $0x7
  800053:	89 d8                	mov    %ebx,%eax
  800055:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005a:	50                   	push   %eax
  80005b:	6a 00                	push   $0x0
  80005d:	e8 02 0c 00 00       	call   800c64 <sys_page_alloc>
  800062:	83 c4 10             	add    $0x10,%esp
  800065:	85 c0                	test   %eax,%eax
  800067:	78 16                	js     80007f <handler+0x4c>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800069:	53                   	push   %ebx
  80006a:	68 8c 11 80 00       	push   $0x80118c
  80006f:	6a 64                	push   $0x64
  800071:	53                   	push   %ebx
  800072:	e8 4a 07 00 00       	call   8007c1 <snprintf>
}
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007d:	c9                   	leave  
  80007e:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007f:	83 ec 0c             	sub    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	53                   	push   %ebx
  800084:	68 60 11 80 00       	push   $0x801160
  800089:	6a 0e                	push   $0xe
  80008b:	68 4a 11 80 00       	push   $0x80114a
  800090:	e8 9d 00 00 00       	call   800132 <_panic>

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
  8000a4:	e8 86 0d 00 00       	call   800e2f <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a9:	83 c4 08             	add    $0x8,%esp
  8000ac:	68 ef be ad de       	push   $0xdeadbeef
  8000b1:	68 5c 11 80 00       	push   $0x80115c
  8000b6:	e8 5e 01 00 00       	call   800219 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000bb:	83 c4 08             	add    $0x8,%esp
  8000be:	68 fe bf fe ca       	push   $0xcafebffe
  8000c3:	68 5c 11 80 00       	push   $0x80115c
  8000c8:	e8 4c 01 00 00       	call   800219 <cprintf>
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
    envid_t envid = sys_getenvid();
  8000e1:	e8 38 0b 00 00       	call   800c1e <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8000e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f3:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f8:	85 db                	test   %ebx,%ebx
  8000fa:	7e 07                	jle    800103 <libmain+0x31>
		binaryname = argv[0];
  8000fc:	8b 06                	mov    (%esi),%eax
  8000fe:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800103:	83 ec 08             	sub    $0x8,%esp
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	e8 88 ff ff ff       	call   800095 <umain>

	// exit gracefully
	exit();
  80010d:	e8 0a 00 00 00       	call   80011c <exit>
}
  800112:	83 c4 10             	add    $0x10,%esp
  800115:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800118:	5b                   	pop    %ebx
  800119:	5e                   	pop    %esi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    

0080011c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80011c:	f3 0f 1e fb          	endbr32 
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800126:	6a 00                	push   $0x0
  800128:	e8 ac 0a 00 00       	call   800bd9 <sys_env_destroy>
}
  80012d:	83 c4 10             	add    $0x10,%esp
  800130:	c9                   	leave  
  800131:	c3                   	ret    

00800132 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800132:	f3 0f 1e fb          	endbr32 
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	56                   	push   %esi
  80013a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80013b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013e:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800144:	e8 d5 0a 00 00       	call   800c1e <sys_getenvid>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	ff 75 0c             	pushl  0xc(%ebp)
  80014f:	ff 75 08             	pushl  0x8(%ebp)
  800152:	56                   	push   %esi
  800153:	50                   	push   %eax
  800154:	68 b8 11 80 00       	push   $0x8011b8
  800159:	e8 bb 00 00 00       	call   800219 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015e:	83 c4 18             	add    $0x18,%esp
  800161:	53                   	push   %ebx
  800162:	ff 75 10             	pushl  0x10(%ebp)
  800165:	e8 5a 00 00 00       	call   8001c4 <vcprintf>
	cprintf("\n");
  80016a:	c7 04 24 5c 14 80 00 	movl   $0x80145c,(%esp)
  800171:	e8 a3 00 00 00       	call   800219 <cprintf>
  800176:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800179:	cc                   	int3   
  80017a:	eb fd                	jmp    800179 <_panic+0x47>

0080017c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017c:	f3 0f 1e fb          	endbr32 
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	53                   	push   %ebx
  800184:	83 ec 04             	sub    $0x4,%esp
  800187:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018a:	8b 13                	mov    (%ebx),%edx
  80018c:	8d 42 01             	lea    0x1(%edx),%eax
  80018f:	89 03                	mov    %eax,(%ebx)
  800191:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800194:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800198:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019d:	74 09                	je     8001a8 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80019f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001a8:	83 ec 08             	sub    $0x8,%esp
  8001ab:	68 ff 00 00 00       	push   $0xff
  8001b0:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b3:	50                   	push   %eax
  8001b4:	e8 db 09 00 00       	call   800b94 <sys_cputs>
		b->idx = 0;
  8001b9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001bf:	83 c4 10             	add    $0x10,%esp
  8001c2:	eb db                	jmp    80019f <putch+0x23>

008001c4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c4:	f3 0f 1e fb          	endbr32 
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d8:	00 00 00 
	b.cnt = 0;
  8001db:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e5:	ff 75 0c             	pushl  0xc(%ebp)
  8001e8:	ff 75 08             	pushl  0x8(%ebp)
  8001eb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f1:	50                   	push   %eax
  8001f2:	68 7c 01 80 00       	push   $0x80017c
  8001f7:	e8 20 01 00 00       	call   80031c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fc:	83 c4 08             	add    $0x8,%esp
  8001ff:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800205:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020b:	50                   	push   %eax
  80020c:	e8 83 09 00 00       	call   800b94 <sys_cputs>

	return b.cnt;
}
  800211:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800217:	c9                   	leave  
  800218:	c3                   	ret    

00800219 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800219:	f3 0f 1e fb          	endbr32 
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800223:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800226:	50                   	push   %eax
  800227:	ff 75 08             	pushl  0x8(%ebp)
  80022a:	e8 95 ff ff ff       	call   8001c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 1c             	sub    $0x1c,%esp
  80023a:	89 c7                	mov    %eax,%edi
  80023c:	89 d6                	mov    %edx,%esi
  80023e:	8b 45 08             	mov    0x8(%ebp),%eax
  800241:	8b 55 0c             	mov    0xc(%ebp),%edx
  800244:	89 d1                	mov    %edx,%ecx
  800246:	89 c2                	mov    %eax,%edx
  800248:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80024e:	8b 45 10             	mov    0x10(%ebp),%eax
  800251:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800254:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800257:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80025e:	39 c2                	cmp    %eax,%edx
  800260:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800263:	72 3e                	jb     8002a3 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	ff 75 18             	pushl  0x18(%ebp)
  80026b:	83 eb 01             	sub    $0x1,%ebx
  80026e:	53                   	push   %ebx
  80026f:	50                   	push   %eax
  800270:	83 ec 08             	sub    $0x8,%esp
  800273:	ff 75 e4             	pushl  -0x1c(%ebp)
  800276:	ff 75 e0             	pushl  -0x20(%ebp)
  800279:	ff 75 dc             	pushl  -0x24(%ebp)
  80027c:	ff 75 d8             	pushl  -0x28(%ebp)
  80027f:	e8 5c 0c 00 00       	call   800ee0 <__udivdi3>
  800284:	83 c4 18             	add    $0x18,%esp
  800287:	52                   	push   %edx
  800288:	50                   	push   %eax
  800289:	89 f2                	mov    %esi,%edx
  80028b:	89 f8                	mov    %edi,%eax
  80028d:	e8 9f ff ff ff       	call   800231 <printnum>
  800292:	83 c4 20             	add    $0x20,%esp
  800295:	eb 13                	jmp    8002aa <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800297:	83 ec 08             	sub    $0x8,%esp
  80029a:	56                   	push   %esi
  80029b:	ff 75 18             	pushl  0x18(%ebp)
  80029e:	ff d7                	call   *%edi
  8002a0:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002a3:	83 eb 01             	sub    $0x1,%ebx
  8002a6:	85 db                	test   %ebx,%ebx
  8002a8:	7f ed                	jg     800297 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002aa:	83 ec 08             	sub    $0x8,%esp
  8002ad:	56                   	push   %esi
  8002ae:	83 ec 04             	sub    $0x4,%esp
  8002b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ba:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bd:	e8 2e 0d 00 00       	call   800ff0 <__umoddi3>
  8002c2:	83 c4 14             	add    $0x14,%esp
  8002c5:	0f be 80 db 11 80 00 	movsbl 0x8011db(%eax),%eax
  8002cc:	50                   	push   %eax
  8002cd:	ff d7                	call   *%edi
}
  8002cf:	83 c4 10             	add    $0x10,%esp
  8002d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d5:	5b                   	pop    %ebx
  8002d6:	5e                   	pop    %esi
  8002d7:	5f                   	pop    %edi
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    

008002da <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002da:	f3 0f 1e fb          	endbr32 
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ed:	73 0a                	jae    8002f9 <sprintputch+0x1f>
		*b->buf++ = ch;
  8002ef:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f7:	88 02                	mov    %al,(%edx)
}
  8002f9:	5d                   	pop    %ebp
  8002fa:	c3                   	ret    

008002fb <printfmt>:
{
  8002fb:	f3 0f 1e fb          	endbr32 
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800305:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800308:	50                   	push   %eax
  800309:	ff 75 10             	pushl  0x10(%ebp)
  80030c:	ff 75 0c             	pushl  0xc(%ebp)
  80030f:	ff 75 08             	pushl  0x8(%ebp)
  800312:	e8 05 00 00 00       	call   80031c <vprintfmt>
}
  800317:	83 c4 10             	add    $0x10,%esp
  80031a:	c9                   	leave  
  80031b:	c3                   	ret    

0080031c <vprintfmt>:
{
  80031c:	f3 0f 1e fb          	endbr32 
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 3c             	sub    $0x3c,%esp
  800329:	8b 75 08             	mov    0x8(%ebp),%esi
  80032c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800332:	e9 4a 03 00 00       	jmp    800681 <vprintfmt+0x365>
		padc = ' ';
  800337:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80033b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800342:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800349:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800350:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8d 47 01             	lea    0x1(%edi),%eax
  800358:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035b:	0f b6 17             	movzbl (%edi),%edx
  80035e:	8d 42 dd             	lea    -0x23(%edx),%eax
  800361:	3c 55                	cmp    $0x55,%al
  800363:	0f 87 de 03 00 00    	ja     800747 <vprintfmt+0x42b>
  800369:	0f b6 c0             	movzbl %al,%eax
  80036c:	3e ff 24 85 a0 12 80 	notrack jmp *0x8012a0(,%eax,4)
  800373:	00 
  800374:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800377:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80037b:	eb d8                	jmp    800355 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80037d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800380:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800384:	eb cf                	jmp    800355 <vprintfmt+0x39>
  800386:	0f b6 d2             	movzbl %dl,%edx
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80038c:	b8 00 00 00 00       	mov    $0x0,%eax
  800391:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800394:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800397:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80039b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80039e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003a1:	83 f9 09             	cmp    $0x9,%ecx
  8003a4:	77 55                	ja     8003fb <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003a6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003a9:	eb e9                	jmp    800394 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ae:	8b 00                	mov    (%eax),%eax
  8003b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b6:	8d 40 04             	lea    0x4(%eax),%eax
  8003b9:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c3:	79 90                	jns    800355 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003cb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003d2:	eb 81                	jmp    800355 <vprintfmt+0x39>
  8003d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003de:	0f 49 d0             	cmovns %eax,%edx
  8003e1:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003e7:	e9 69 ff ff ff       	jmp    800355 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003ef:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003f6:	e9 5a ff ff ff       	jmp    800355 <vprintfmt+0x39>
  8003fb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800401:	eb bc                	jmp    8003bf <vprintfmt+0xa3>
			lflag++;
  800403:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800409:	e9 47 ff ff ff       	jmp    800355 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80040e:	8b 45 14             	mov    0x14(%ebp),%eax
  800411:	8d 78 04             	lea    0x4(%eax),%edi
  800414:	83 ec 08             	sub    $0x8,%esp
  800417:	53                   	push   %ebx
  800418:	ff 30                	pushl  (%eax)
  80041a:	ff d6                	call   *%esi
			break;
  80041c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80041f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800422:	e9 57 02 00 00       	jmp    80067e <vprintfmt+0x362>
			err = va_arg(ap, int);
  800427:	8b 45 14             	mov    0x14(%ebp),%eax
  80042a:	8d 78 04             	lea    0x4(%eax),%edi
  80042d:	8b 00                	mov    (%eax),%eax
  80042f:	99                   	cltd   
  800430:	31 d0                	xor    %edx,%eax
  800432:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800434:	83 f8 08             	cmp    $0x8,%eax
  800437:	7f 23                	jg     80045c <vprintfmt+0x140>
  800439:	8b 14 85 00 14 80 00 	mov    0x801400(,%eax,4),%edx
  800440:	85 d2                	test   %edx,%edx
  800442:	74 18                	je     80045c <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800444:	52                   	push   %edx
  800445:	68 fc 11 80 00       	push   $0x8011fc
  80044a:	53                   	push   %ebx
  80044b:	56                   	push   %esi
  80044c:	e8 aa fe ff ff       	call   8002fb <printfmt>
  800451:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800454:	89 7d 14             	mov    %edi,0x14(%ebp)
  800457:	e9 22 02 00 00       	jmp    80067e <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  80045c:	50                   	push   %eax
  80045d:	68 f3 11 80 00       	push   $0x8011f3
  800462:	53                   	push   %ebx
  800463:	56                   	push   %esi
  800464:	e8 92 fe ff ff       	call   8002fb <printfmt>
  800469:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80046c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80046f:	e9 0a 02 00 00       	jmp    80067e <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800474:	8b 45 14             	mov    0x14(%ebp),%eax
  800477:	83 c0 04             	add    $0x4,%eax
  80047a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80047d:	8b 45 14             	mov    0x14(%ebp),%eax
  800480:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800482:	85 d2                	test   %edx,%edx
  800484:	b8 ec 11 80 00       	mov    $0x8011ec,%eax
  800489:	0f 45 c2             	cmovne %edx,%eax
  80048c:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80048f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800493:	7e 06                	jle    80049b <vprintfmt+0x17f>
  800495:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800499:	75 0d                	jne    8004a8 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80049e:	89 c7                	mov    %eax,%edi
  8004a0:	03 45 e0             	add    -0x20(%ebp),%eax
  8004a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a6:	eb 55                	jmp    8004fd <vprintfmt+0x1e1>
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ae:	ff 75 cc             	pushl  -0x34(%ebp)
  8004b1:	e8 45 03 00 00       	call   8007fb <strnlen>
  8004b6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004b9:	29 c2                	sub    %eax,%edx
  8004bb:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004c3:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	85 ff                	test   %edi,%edi
  8004cc:	7e 11                	jle    8004df <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	53                   	push   %ebx
  8004d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d7:	83 ef 01             	sub    $0x1,%edi
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	eb eb                	jmp    8004ca <vprintfmt+0x1ae>
  8004df:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004e2:	85 d2                	test   %edx,%edx
  8004e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e9:	0f 49 c2             	cmovns %edx,%eax
  8004ec:	29 c2                	sub    %eax,%edx
  8004ee:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004f1:	eb a8                	jmp    80049b <vprintfmt+0x17f>
					putch(ch, putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	53                   	push   %ebx
  8004f7:	52                   	push   %edx
  8004f8:	ff d6                	call   *%esi
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800500:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800502:	83 c7 01             	add    $0x1,%edi
  800505:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800509:	0f be d0             	movsbl %al,%edx
  80050c:	85 d2                	test   %edx,%edx
  80050e:	74 4b                	je     80055b <vprintfmt+0x23f>
  800510:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800514:	78 06                	js     80051c <vprintfmt+0x200>
  800516:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80051a:	78 1e                	js     80053a <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80051c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800520:	74 d1                	je     8004f3 <vprintfmt+0x1d7>
  800522:	0f be c0             	movsbl %al,%eax
  800525:	83 e8 20             	sub    $0x20,%eax
  800528:	83 f8 5e             	cmp    $0x5e,%eax
  80052b:	76 c6                	jbe    8004f3 <vprintfmt+0x1d7>
					putch('?', putdat);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	53                   	push   %ebx
  800531:	6a 3f                	push   $0x3f
  800533:	ff d6                	call   *%esi
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	eb c3                	jmp    8004fd <vprintfmt+0x1e1>
  80053a:	89 cf                	mov    %ecx,%edi
  80053c:	eb 0e                	jmp    80054c <vprintfmt+0x230>
				putch(' ', putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	53                   	push   %ebx
  800542:	6a 20                	push   $0x20
  800544:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800546:	83 ef 01             	sub    $0x1,%edi
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	85 ff                	test   %edi,%edi
  80054e:	7f ee                	jg     80053e <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800550:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800553:	89 45 14             	mov    %eax,0x14(%ebp)
  800556:	e9 23 01 00 00       	jmp    80067e <vprintfmt+0x362>
  80055b:	89 cf                	mov    %ecx,%edi
  80055d:	eb ed                	jmp    80054c <vprintfmt+0x230>
	if (lflag >= 2)
  80055f:	83 f9 01             	cmp    $0x1,%ecx
  800562:	7f 1b                	jg     80057f <vprintfmt+0x263>
	else if (lflag)
  800564:	85 c9                	test   %ecx,%ecx
  800566:	74 63                	je     8005cb <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8b 00                	mov    (%eax),%eax
  80056d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800570:	99                   	cltd   
  800571:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 40 04             	lea    0x4(%eax),%eax
  80057a:	89 45 14             	mov    %eax,0x14(%ebp)
  80057d:	eb 17                	jmp    800596 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8b 50 04             	mov    0x4(%eax),%edx
  800585:	8b 00                	mov    (%eax),%eax
  800587:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8d 40 08             	lea    0x8(%eax),%eax
  800593:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800596:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800599:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80059c:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005a1:	85 c9                	test   %ecx,%ecx
  8005a3:	0f 89 bb 00 00 00    	jns    800664 <vprintfmt+0x348>
				putch('-', putdat);
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	53                   	push   %ebx
  8005ad:	6a 2d                	push   $0x2d
  8005af:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005b7:	f7 da                	neg    %edx
  8005b9:	83 d1 00             	adc    $0x0,%ecx
  8005bc:	f7 d9                	neg    %ecx
  8005be:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005c1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c6:	e9 99 00 00 00       	jmp    800664 <vprintfmt+0x348>
		return va_arg(*ap, int);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8b 00                	mov    (%eax),%eax
  8005d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d3:	99                   	cltd   
  8005d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8d 40 04             	lea    0x4(%eax),%eax
  8005dd:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e0:	eb b4                	jmp    800596 <vprintfmt+0x27a>
	if (lflag >= 2)
  8005e2:	83 f9 01             	cmp    $0x1,%ecx
  8005e5:	7f 1b                	jg     800602 <vprintfmt+0x2e6>
	else if (lflag)
  8005e7:	85 c9                	test   %ecx,%ecx
  8005e9:	74 2c                	je     800617 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8b 10                	mov    (%eax),%edx
  8005f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f5:	8d 40 04             	lea    0x4(%eax),%eax
  8005f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fb:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800600:	eb 62                	jmp    800664 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8b 10                	mov    (%eax),%edx
  800607:	8b 48 04             	mov    0x4(%eax),%ecx
  80060a:	8d 40 08             	lea    0x8(%eax),%eax
  80060d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800610:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800615:	eb 4d                	jmp    800664 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8b 10                	mov    (%eax),%edx
  80061c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800621:	8d 40 04             	lea    0x4(%eax),%eax
  800624:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800627:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80062c:	eb 36                	jmp    800664 <vprintfmt+0x348>
	if (lflag >= 2)
  80062e:	83 f9 01             	cmp    $0x1,%ecx
  800631:	7f 17                	jg     80064a <vprintfmt+0x32e>
	else if (lflag)
  800633:	85 c9                	test   %ecx,%ecx
  800635:	74 6e                	je     8006a5 <vprintfmt+0x389>
		return va_arg(*ap, long);
  800637:	8b 45 14             	mov    0x14(%ebp),%eax
  80063a:	8b 10                	mov    (%eax),%edx
  80063c:	89 d0                	mov    %edx,%eax
  80063e:	99                   	cltd   
  80063f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800642:	8d 49 04             	lea    0x4(%ecx),%ecx
  800645:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800648:	eb 11                	jmp    80065b <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8b 50 04             	mov    0x4(%eax),%edx
  800650:	8b 00                	mov    (%eax),%eax
  800652:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800655:	8d 49 08             	lea    0x8(%ecx),%ecx
  800658:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80065b:	89 d1                	mov    %edx,%ecx
  80065d:	89 c2                	mov    %eax,%edx
            base = 8;
  80065f:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800664:	83 ec 0c             	sub    $0xc,%esp
  800667:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80066b:	57                   	push   %edi
  80066c:	ff 75 e0             	pushl  -0x20(%ebp)
  80066f:	50                   	push   %eax
  800670:	51                   	push   %ecx
  800671:	52                   	push   %edx
  800672:	89 da                	mov    %ebx,%edx
  800674:	89 f0                	mov    %esi,%eax
  800676:	e8 b6 fb ff ff       	call   800231 <printnum>
			break;
  80067b:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80067e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800681:	83 c7 01             	add    $0x1,%edi
  800684:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800688:	83 f8 25             	cmp    $0x25,%eax
  80068b:	0f 84 a6 fc ff ff    	je     800337 <vprintfmt+0x1b>
			if (ch == '\0')
  800691:	85 c0                	test   %eax,%eax
  800693:	0f 84 ce 00 00 00    	je     800767 <vprintfmt+0x44b>
			putch(ch, putdat);
  800699:	83 ec 08             	sub    $0x8,%esp
  80069c:	53                   	push   %ebx
  80069d:	50                   	push   %eax
  80069e:	ff d6                	call   *%esi
  8006a0:	83 c4 10             	add    $0x10,%esp
  8006a3:	eb dc                	jmp    800681 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8b 10                	mov    (%eax),%edx
  8006aa:	89 d0                	mov    %edx,%eax
  8006ac:	99                   	cltd   
  8006ad:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006b0:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006b3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006b6:	eb a3                	jmp    80065b <vprintfmt+0x33f>
			putch('0', putdat);
  8006b8:	83 ec 08             	sub    $0x8,%esp
  8006bb:	53                   	push   %ebx
  8006bc:	6a 30                	push   $0x30
  8006be:	ff d6                	call   *%esi
			putch('x', putdat);
  8006c0:	83 c4 08             	add    $0x8,%esp
  8006c3:	53                   	push   %ebx
  8006c4:	6a 78                	push   $0x78
  8006c6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 10                	mov    (%eax),%edx
  8006cd:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006d2:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006d5:	8d 40 04             	lea    0x4(%eax),%eax
  8006d8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006db:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006e0:	eb 82                	jmp    800664 <vprintfmt+0x348>
	if (lflag >= 2)
  8006e2:	83 f9 01             	cmp    $0x1,%ecx
  8006e5:	7f 1e                	jg     800705 <vprintfmt+0x3e9>
	else if (lflag)
  8006e7:	85 c9                	test   %ecx,%ecx
  8006e9:	74 32                	je     80071d <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  8006eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ee:	8b 10                	mov    (%eax),%edx
  8006f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f5:	8d 40 04             	lea    0x4(%eax),%eax
  8006f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006fb:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800700:	e9 5f ff ff ff       	jmp    800664 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800705:	8b 45 14             	mov    0x14(%ebp),%eax
  800708:	8b 10                	mov    (%eax),%edx
  80070a:	8b 48 04             	mov    0x4(%eax),%ecx
  80070d:	8d 40 08             	lea    0x8(%eax),%eax
  800710:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800713:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800718:	e9 47 ff ff ff       	jmp    800664 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80071d:	8b 45 14             	mov    0x14(%ebp),%eax
  800720:	8b 10                	mov    (%eax),%edx
  800722:	b9 00 00 00 00       	mov    $0x0,%ecx
  800727:	8d 40 04             	lea    0x4(%eax),%eax
  80072a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800732:	e9 2d ff ff ff       	jmp    800664 <vprintfmt+0x348>
			putch(ch, putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	53                   	push   %ebx
  80073b:	6a 25                	push   $0x25
  80073d:	ff d6                	call   *%esi
			break;
  80073f:	83 c4 10             	add    $0x10,%esp
  800742:	e9 37 ff ff ff       	jmp    80067e <vprintfmt+0x362>
			putch('%', putdat);
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	53                   	push   %ebx
  80074b:	6a 25                	push   $0x25
  80074d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80074f:	83 c4 10             	add    $0x10,%esp
  800752:	89 f8                	mov    %edi,%eax
  800754:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800758:	74 05                	je     80075f <vprintfmt+0x443>
  80075a:	83 e8 01             	sub    $0x1,%eax
  80075d:	eb f5                	jmp    800754 <vprintfmt+0x438>
  80075f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800762:	e9 17 ff ff ff       	jmp    80067e <vprintfmt+0x362>
}
  800767:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076a:	5b                   	pop    %ebx
  80076b:	5e                   	pop    %esi
  80076c:	5f                   	pop    %edi
  80076d:	5d                   	pop    %ebp
  80076e:	c3                   	ret    

0080076f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80076f:	f3 0f 1e fb          	endbr32 
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	83 ec 18             	sub    $0x18,%esp
  800779:	8b 45 08             	mov    0x8(%ebp),%eax
  80077c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800782:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800786:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800789:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800790:	85 c0                	test   %eax,%eax
  800792:	74 26                	je     8007ba <vsnprintf+0x4b>
  800794:	85 d2                	test   %edx,%edx
  800796:	7e 22                	jle    8007ba <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800798:	ff 75 14             	pushl  0x14(%ebp)
  80079b:	ff 75 10             	pushl  0x10(%ebp)
  80079e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a1:	50                   	push   %eax
  8007a2:	68 da 02 80 00       	push   $0x8002da
  8007a7:	e8 70 fb ff ff       	call   80031c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007af:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b5:	83 c4 10             	add    $0x10,%esp
}
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    
		return -E_INVAL;
  8007ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007bf:	eb f7                	jmp    8007b8 <vsnprintf+0x49>

008007c1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c1:	f3 0f 1e fb          	endbr32 
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007cb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ce:	50                   	push   %eax
  8007cf:	ff 75 10             	pushl  0x10(%ebp)
  8007d2:	ff 75 0c             	pushl  0xc(%ebp)
  8007d5:	ff 75 08             	pushl  0x8(%ebp)
  8007d8:	e8 92 ff ff ff       	call   80076f <vsnprintf>
	va_end(ap);

	return rc;
}
  8007dd:	c9                   	leave  
  8007de:	c3                   	ret    

008007df <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007df:	f3 0f 1e fb          	endbr32 
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ee:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f2:	74 05                	je     8007f9 <strlen+0x1a>
		n++;
  8007f4:	83 c0 01             	add    $0x1,%eax
  8007f7:	eb f5                	jmp    8007ee <strlen+0xf>
	return n;
}
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007fb:	f3 0f 1e fb          	endbr32 
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800805:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800808:	b8 00 00 00 00       	mov    $0x0,%eax
  80080d:	39 d0                	cmp    %edx,%eax
  80080f:	74 0d                	je     80081e <strnlen+0x23>
  800811:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800815:	74 05                	je     80081c <strnlen+0x21>
		n++;
  800817:	83 c0 01             	add    $0x1,%eax
  80081a:	eb f1                	jmp    80080d <strnlen+0x12>
  80081c:	89 c2                	mov    %eax,%edx
	return n;
}
  80081e:	89 d0                	mov    %edx,%eax
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800822:	f3 0f 1e fb          	endbr32 
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	53                   	push   %ebx
  80082a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800830:	b8 00 00 00 00       	mov    $0x0,%eax
  800835:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800839:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80083c:	83 c0 01             	add    $0x1,%eax
  80083f:	84 d2                	test   %dl,%dl
  800841:	75 f2                	jne    800835 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800843:	89 c8                	mov    %ecx,%eax
  800845:	5b                   	pop    %ebx
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800848:	f3 0f 1e fb          	endbr32 
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	53                   	push   %ebx
  800850:	83 ec 10             	sub    $0x10,%esp
  800853:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800856:	53                   	push   %ebx
  800857:	e8 83 ff ff ff       	call   8007df <strlen>
  80085c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80085f:	ff 75 0c             	pushl  0xc(%ebp)
  800862:	01 d8                	add    %ebx,%eax
  800864:	50                   	push   %eax
  800865:	e8 b8 ff ff ff       	call   800822 <strcpy>
	return dst;
}
  80086a:	89 d8                	mov    %ebx,%eax
  80086c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086f:	c9                   	leave  
  800870:	c3                   	ret    

00800871 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800871:	f3 0f 1e fb          	endbr32 
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	56                   	push   %esi
  800879:	53                   	push   %ebx
  80087a:	8b 75 08             	mov    0x8(%ebp),%esi
  80087d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800880:	89 f3                	mov    %esi,%ebx
  800882:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800885:	89 f0                	mov    %esi,%eax
  800887:	39 d8                	cmp    %ebx,%eax
  800889:	74 11                	je     80089c <strncpy+0x2b>
		*dst++ = *src;
  80088b:	83 c0 01             	add    $0x1,%eax
  80088e:	0f b6 0a             	movzbl (%edx),%ecx
  800891:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800894:	80 f9 01             	cmp    $0x1,%cl
  800897:	83 da ff             	sbb    $0xffffffff,%edx
  80089a:	eb eb                	jmp    800887 <strncpy+0x16>
	}
	return ret;
}
  80089c:	89 f0                	mov    %esi,%eax
  80089e:	5b                   	pop    %ebx
  80089f:	5e                   	pop    %esi
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a2:	f3 0f 1e fb          	endbr32 
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	56                   	push   %esi
  8008aa:	53                   	push   %ebx
  8008ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b1:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b6:	85 d2                	test   %edx,%edx
  8008b8:	74 21                	je     8008db <strlcpy+0x39>
  8008ba:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008be:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008c0:	39 c2                	cmp    %eax,%edx
  8008c2:	74 14                	je     8008d8 <strlcpy+0x36>
  8008c4:	0f b6 19             	movzbl (%ecx),%ebx
  8008c7:	84 db                	test   %bl,%bl
  8008c9:	74 0b                	je     8008d6 <strlcpy+0x34>
			*dst++ = *src++;
  8008cb:	83 c1 01             	add    $0x1,%ecx
  8008ce:	83 c2 01             	add    $0x1,%edx
  8008d1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008d4:	eb ea                	jmp    8008c0 <strlcpy+0x1e>
  8008d6:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008d8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008db:	29 f0                	sub    %esi,%eax
}
  8008dd:	5b                   	pop    %ebx
  8008de:	5e                   	pop    %esi
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e1:	f3 0f 1e fb          	endbr32 
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ee:	0f b6 01             	movzbl (%ecx),%eax
  8008f1:	84 c0                	test   %al,%al
  8008f3:	74 0c                	je     800901 <strcmp+0x20>
  8008f5:	3a 02                	cmp    (%edx),%al
  8008f7:	75 08                	jne    800901 <strcmp+0x20>
		p++, q++;
  8008f9:	83 c1 01             	add    $0x1,%ecx
  8008fc:	83 c2 01             	add    $0x1,%edx
  8008ff:	eb ed                	jmp    8008ee <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800901:	0f b6 c0             	movzbl %al,%eax
  800904:	0f b6 12             	movzbl (%edx),%edx
  800907:	29 d0                	sub    %edx,%eax
}
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80090b:	f3 0f 1e fb          	endbr32 
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	53                   	push   %ebx
  800913:	8b 45 08             	mov    0x8(%ebp),%eax
  800916:	8b 55 0c             	mov    0xc(%ebp),%edx
  800919:	89 c3                	mov    %eax,%ebx
  80091b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80091e:	eb 06                	jmp    800926 <strncmp+0x1b>
		n--, p++, q++;
  800920:	83 c0 01             	add    $0x1,%eax
  800923:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800926:	39 d8                	cmp    %ebx,%eax
  800928:	74 16                	je     800940 <strncmp+0x35>
  80092a:	0f b6 08             	movzbl (%eax),%ecx
  80092d:	84 c9                	test   %cl,%cl
  80092f:	74 04                	je     800935 <strncmp+0x2a>
  800931:	3a 0a                	cmp    (%edx),%cl
  800933:	74 eb                	je     800920 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800935:	0f b6 00             	movzbl (%eax),%eax
  800938:	0f b6 12             	movzbl (%edx),%edx
  80093b:	29 d0                	sub    %edx,%eax
}
  80093d:	5b                   	pop    %ebx
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    
		return 0;
  800940:	b8 00 00 00 00       	mov    $0x0,%eax
  800945:	eb f6                	jmp    80093d <strncmp+0x32>

00800947 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800947:	f3 0f 1e fb          	endbr32 
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800955:	0f b6 10             	movzbl (%eax),%edx
  800958:	84 d2                	test   %dl,%dl
  80095a:	74 09                	je     800965 <strchr+0x1e>
		if (*s == c)
  80095c:	38 ca                	cmp    %cl,%dl
  80095e:	74 0a                	je     80096a <strchr+0x23>
	for (; *s; s++)
  800960:	83 c0 01             	add    $0x1,%eax
  800963:	eb f0                	jmp    800955 <strchr+0xe>
			return (char *) s;
	return 0;
  800965:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80096c:	f3 0f 1e fb          	endbr32 
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80097a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80097d:	38 ca                	cmp    %cl,%dl
  80097f:	74 09                	je     80098a <strfind+0x1e>
  800981:	84 d2                	test   %dl,%dl
  800983:	74 05                	je     80098a <strfind+0x1e>
	for (; *s; s++)
  800985:	83 c0 01             	add    $0x1,%eax
  800988:	eb f0                	jmp    80097a <strfind+0xe>
			break;
	return (char *) s;
}
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80098c:	f3 0f 1e fb          	endbr32 
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	57                   	push   %edi
  800994:	56                   	push   %esi
  800995:	53                   	push   %ebx
  800996:	8b 7d 08             	mov    0x8(%ebp),%edi
  800999:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80099c:	85 c9                	test   %ecx,%ecx
  80099e:	74 31                	je     8009d1 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a0:	89 f8                	mov    %edi,%eax
  8009a2:	09 c8                	or     %ecx,%eax
  8009a4:	a8 03                	test   $0x3,%al
  8009a6:	75 23                	jne    8009cb <memset+0x3f>
		c &= 0xFF;
  8009a8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ac:	89 d3                	mov    %edx,%ebx
  8009ae:	c1 e3 08             	shl    $0x8,%ebx
  8009b1:	89 d0                	mov    %edx,%eax
  8009b3:	c1 e0 18             	shl    $0x18,%eax
  8009b6:	89 d6                	mov    %edx,%esi
  8009b8:	c1 e6 10             	shl    $0x10,%esi
  8009bb:	09 f0                	or     %esi,%eax
  8009bd:	09 c2                	or     %eax,%edx
  8009bf:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009c1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009c4:	89 d0                	mov    %edx,%eax
  8009c6:	fc                   	cld    
  8009c7:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c9:	eb 06                	jmp    8009d1 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ce:	fc                   	cld    
  8009cf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009d1:	89 f8                	mov    %edi,%eax
  8009d3:	5b                   	pop    %ebx
  8009d4:	5e                   	pop    %esi
  8009d5:	5f                   	pop    %edi
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d8:	f3 0f 1e fb          	endbr32 
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	57                   	push   %edi
  8009e0:	56                   	push   %esi
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ea:	39 c6                	cmp    %eax,%esi
  8009ec:	73 32                	jae    800a20 <memmove+0x48>
  8009ee:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f1:	39 c2                	cmp    %eax,%edx
  8009f3:	76 2b                	jbe    800a20 <memmove+0x48>
		s += n;
		d += n;
  8009f5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f8:	89 fe                	mov    %edi,%esi
  8009fa:	09 ce                	or     %ecx,%esi
  8009fc:	09 d6                	or     %edx,%esi
  8009fe:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a04:	75 0e                	jne    800a14 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a06:	83 ef 04             	sub    $0x4,%edi
  800a09:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a0c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a0f:	fd                   	std    
  800a10:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a12:	eb 09                	jmp    800a1d <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a14:	83 ef 01             	sub    $0x1,%edi
  800a17:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a1a:	fd                   	std    
  800a1b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a1d:	fc                   	cld    
  800a1e:	eb 1a                	jmp    800a3a <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a20:	89 c2                	mov    %eax,%edx
  800a22:	09 ca                	or     %ecx,%edx
  800a24:	09 f2                	or     %esi,%edx
  800a26:	f6 c2 03             	test   $0x3,%dl
  800a29:	75 0a                	jne    800a35 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a2b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a2e:	89 c7                	mov    %eax,%edi
  800a30:	fc                   	cld    
  800a31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a33:	eb 05                	jmp    800a3a <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a35:	89 c7                	mov    %eax,%edi
  800a37:	fc                   	cld    
  800a38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a3a:	5e                   	pop    %esi
  800a3b:	5f                   	pop    %edi
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a3e:	f3 0f 1e fb          	endbr32 
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a48:	ff 75 10             	pushl  0x10(%ebp)
  800a4b:	ff 75 0c             	pushl  0xc(%ebp)
  800a4e:	ff 75 08             	pushl  0x8(%ebp)
  800a51:	e8 82 ff ff ff       	call   8009d8 <memmove>
}
  800a56:	c9                   	leave  
  800a57:	c3                   	ret    

00800a58 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a58:	f3 0f 1e fb          	endbr32 
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	56                   	push   %esi
  800a60:	53                   	push   %ebx
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
  800a64:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a67:	89 c6                	mov    %eax,%esi
  800a69:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6c:	39 f0                	cmp    %esi,%eax
  800a6e:	74 1c                	je     800a8c <memcmp+0x34>
		if (*s1 != *s2)
  800a70:	0f b6 08             	movzbl (%eax),%ecx
  800a73:	0f b6 1a             	movzbl (%edx),%ebx
  800a76:	38 d9                	cmp    %bl,%cl
  800a78:	75 08                	jne    800a82 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a7a:	83 c0 01             	add    $0x1,%eax
  800a7d:	83 c2 01             	add    $0x1,%edx
  800a80:	eb ea                	jmp    800a6c <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a82:	0f b6 c1             	movzbl %cl,%eax
  800a85:	0f b6 db             	movzbl %bl,%ebx
  800a88:	29 d8                	sub    %ebx,%eax
  800a8a:	eb 05                	jmp    800a91 <memcmp+0x39>
	}

	return 0;
  800a8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a91:	5b                   	pop    %ebx
  800a92:	5e                   	pop    %esi
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a95:	f3 0f 1e fb          	endbr32 
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aa2:	89 c2                	mov    %eax,%edx
  800aa4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa7:	39 d0                	cmp    %edx,%eax
  800aa9:	73 09                	jae    800ab4 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aab:	38 08                	cmp    %cl,(%eax)
  800aad:	74 05                	je     800ab4 <memfind+0x1f>
	for (; s < ends; s++)
  800aaf:	83 c0 01             	add    $0x1,%eax
  800ab2:	eb f3                	jmp    800aa7 <memfind+0x12>
			break;
	return (void *) s;
}
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ab6:	f3 0f 1e fb          	endbr32 
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
  800ac0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac6:	eb 03                	jmp    800acb <strtol+0x15>
		s++;
  800ac8:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800acb:	0f b6 01             	movzbl (%ecx),%eax
  800ace:	3c 20                	cmp    $0x20,%al
  800ad0:	74 f6                	je     800ac8 <strtol+0x12>
  800ad2:	3c 09                	cmp    $0x9,%al
  800ad4:	74 f2                	je     800ac8 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ad6:	3c 2b                	cmp    $0x2b,%al
  800ad8:	74 2a                	je     800b04 <strtol+0x4e>
	int neg = 0;
  800ada:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800adf:	3c 2d                	cmp    $0x2d,%al
  800ae1:	74 2b                	je     800b0e <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae9:	75 0f                	jne    800afa <strtol+0x44>
  800aeb:	80 39 30             	cmpb   $0x30,(%ecx)
  800aee:	74 28                	je     800b18 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800af0:	85 db                	test   %ebx,%ebx
  800af2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800af7:	0f 44 d8             	cmove  %eax,%ebx
  800afa:	b8 00 00 00 00       	mov    $0x0,%eax
  800aff:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b02:	eb 46                	jmp    800b4a <strtol+0x94>
		s++;
  800b04:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b07:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0c:	eb d5                	jmp    800ae3 <strtol+0x2d>
		s++, neg = 1;
  800b0e:	83 c1 01             	add    $0x1,%ecx
  800b11:	bf 01 00 00 00       	mov    $0x1,%edi
  800b16:	eb cb                	jmp    800ae3 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b18:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b1c:	74 0e                	je     800b2c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b1e:	85 db                	test   %ebx,%ebx
  800b20:	75 d8                	jne    800afa <strtol+0x44>
		s++, base = 8;
  800b22:	83 c1 01             	add    $0x1,%ecx
  800b25:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b2a:	eb ce                	jmp    800afa <strtol+0x44>
		s += 2, base = 16;
  800b2c:	83 c1 02             	add    $0x2,%ecx
  800b2f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b34:	eb c4                	jmp    800afa <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b36:	0f be d2             	movsbl %dl,%edx
  800b39:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b3c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b3f:	7d 3a                	jge    800b7b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b41:	83 c1 01             	add    $0x1,%ecx
  800b44:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b48:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b4a:	0f b6 11             	movzbl (%ecx),%edx
  800b4d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b50:	89 f3                	mov    %esi,%ebx
  800b52:	80 fb 09             	cmp    $0x9,%bl
  800b55:	76 df                	jbe    800b36 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b57:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b5a:	89 f3                	mov    %esi,%ebx
  800b5c:	80 fb 19             	cmp    $0x19,%bl
  800b5f:	77 08                	ja     800b69 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b61:	0f be d2             	movsbl %dl,%edx
  800b64:	83 ea 57             	sub    $0x57,%edx
  800b67:	eb d3                	jmp    800b3c <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b69:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b6c:	89 f3                	mov    %esi,%ebx
  800b6e:	80 fb 19             	cmp    $0x19,%bl
  800b71:	77 08                	ja     800b7b <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b73:	0f be d2             	movsbl %dl,%edx
  800b76:	83 ea 37             	sub    $0x37,%edx
  800b79:	eb c1                	jmp    800b3c <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b7b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b7f:	74 05                	je     800b86 <strtol+0xd0>
		*endptr = (char *) s;
  800b81:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b84:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b86:	89 c2                	mov    %eax,%edx
  800b88:	f7 da                	neg    %edx
  800b8a:	85 ff                	test   %edi,%edi
  800b8c:	0f 45 c2             	cmovne %edx,%eax
}
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b94:	f3 0f 1e fb          	endbr32 
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	57                   	push   %edi
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba9:	89 c3                	mov    %eax,%ebx
  800bab:	89 c7                	mov    %eax,%edi
  800bad:	89 c6                	mov    %eax,%esi
  800baf:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bb6:	f3 0f 1e fb          	endbr32 
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bca:	89 d1                	mov    %edx,%ecx
  800bcc:	89 d3                	mov    %edx,%ebx
  800bce:	89 d7                	mov    %edx,%edi
  800bd0:	89 d6                	mov    %edx,%esi
  800bd2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd9:	f3 0f 1e fb          	endbr32 
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800be6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800beb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bee:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf3:	89 cb                	mov    %ecx,%ebx
  800bf5:	89 cf                	mov    %ecx,%edi
  800bf7:	89 ce                	mov    %ecx,%esi
  800bf9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7f 08                	jg     800c07 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c07:	83 ec 0c             	sub    $0xc,%esp
  800c0a:	50                   	push   %eax
  800c0b:	6a 03                	push   $0x3
  800c0d:	68 24 14 80 00       	push   $0x801424
  800c12:	6a 23                	push   $0x23
  800c14:	68 41 14 80 00       	push   $0x801441
  800c19:	e8 14 f5 ff ff       	call   800132 <_panic>

00800c1e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c1e:	f3 0f 1e fb          	endbr32 
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c28:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2d:	b8 02 00 00 00       	mov    $0x2,%eax
  800c32:	89 d1                	mov    %edx,%ecx
  800c34:	89 d3                	mov    %edx,%ebx
  800c36:	89 d7                	mov    %edx,%edi
  800c38:	89 d6                	mov    %edx,%esi
  800c3a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_yield>:

void
sys_yield(void)
{
  800c41:	f3 0f 1e fb          	endbr32 
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c50:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c55:	89 d1                	mov    %edx,%ecx
  800c57:	89 d3                	mov    %edx,%ebx
  800c59:	89 d7                	mov    %edx,%edi
  800c5b:	89 d6                	mov    %edx,%esi
  800c5d:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c64:	f3 0f 1e fb          	endbr32 
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
  800c6e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c71:	be 00 00 00 00       	mov    $0x0,%esi
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c84:	89 f7                	mov    %esi,%edi
  800c86:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	7f 08                	jg     800c94 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c94:	83 ec 0c             	sub    $0xc,%esp
  800c97:	50                   	push   %eax
  800c98:	6a 04                	push   $0x4
  800c9a:	68 24 14 80 00       	push   $0x801424
  800c9f:	6a 23                	push   $0x23
  800ca1:	68 41 14 80 00       	push   $0x801441
  800ca6:	e8 87 f4 ff ff       	call   800132 <_panic>

00800cab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cab:	f3 0f 1e fb          	endbr32 
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	57                   	push   %edi
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
  800cb5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbe:	b8 05 00 00 00       	mov    $0x5,%eax
  800cc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc9:	8b 75 18             	mov    0x18(%ebp),%esi
  800ccc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	7f 08                	jg     800cda <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cda:	83 ec 0c             	sub    $0xc,%esp
  800cdd:	50                   	push   %eax
  800cde:	6a 05                	push   $0x5
  800ce0:	68 24 14 80 00       	push   $0x801424
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 41 14 80 00       	push   $0x801441
  800cec:	e8 41 f4 ff ff       	call   800132 <_panic>

00800cf1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cf1:	f3 0f 1e fb          	endbr32 
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	57                   	push   %edi
  800cf9:	56                   	push   %esi
  800cfa:	53                   	push   %ebx
  800cfb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d03:	8b 55 08             	mov    0x8(%ebp),%edx
  800d06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d09:	b8 06 00 00 00       	mov    $0x6,%eax
  800d0e:	89 df                	mov    %ebx,%edi
  800d10:	89 de                	mov    %ebx,%esi
  800d12:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d14:	85 c0                	test   %eax,%eax
  800d16:	7f 08                	jg     800d20 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1b:	5b                   	pop    %ebx
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d20:	83 ec 0c             	sub    $0xc,%esp
  800d23:	50                   	push   %eax
  800d24:	6a 06                	push   $0x6
  800d26:	68 24 14 80 00       	push   $0x801424
  800d2b:	6a 23                	push   $0x23
  800d2d:	68 41 14 80 00       	push   $0x801441
  800d32:	e8 fb f3 ff ff       	call   800132 <_panic>

00800d37 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d37:	f3 0f 1e fb          	endbr32 
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	b8 08 00 00 00       	mov    $0x8,%eax
  800d54:	89 df                	mov    %ebx,%edi
  800d56:	89 de                	mov    %ebx,%esi
  800d58:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	7f 08                	jg     800d66 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	50                   	push   %eax
  800d6a:	6a 08                	push   $0x8
  800d6c:	68 24 14 80 00       	push   $0x801424
  800d71:	6a 23                	push   $0x23
  800d73:	68 41 14 80 00       	push   $0x801441
  800d78:	e8 b5 f3 ff ff       	call   800132 <_panic>

00800d7d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d7d:	f3 0f 1e fb          	endbr32 
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
  800d87:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	b8 09 00 00 00       	mov    $0x9,%eax
  800d9a:	89 df                	mov    %ebx,%edi
  800d9c:	89 de                	mov    %ebx,%esi
  800d9e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da0:	85 c0                	test   %eax,%eax
  800da2:	7f 08                	jg     800dac <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800da4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da7:	5b                   	pop    %ebx
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dac:	83 ec 0c             	sub    $0xc,%esp
  800daf:	50                   	push   %eax
  800db0:	6a 09                	push   $0x9
  800db2:	68 24 14 80 00       	push   $0x801424
  800db7:	6a 23                	push   $0x23
  800db9:	68 41 14 80 00       	push   $0x801441
  800dbe:	e8 6f f3 ff ff       	call   800132 <_panic>

00800dc3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc3:	f3 0f 1e fb          	endbr32 
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	57                   	push   %edi
  800dcb:	56                   	push   %esi
  800dcc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dd8:	be 00 00 00 00       	mov    $0x0,%esi
  800ddd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de3:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dea:	f3 0f 1e fb          	endbr32 
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
  800df4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800df7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e04:	89 cb                	mov    %ecx,%ebx
  800e06:	89 cf                	mov    %ecx,%edi
  800e08:	89 ce                	mov    %ecx,%esi
  800e0a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	7f 08                	jg     800e18 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e18:	83 ec 0c             	sub    $0xc,%esp
  800e1b:	50                   	push   %eax
  800e1c:	6a 0c                	push   $0xc
  800e1e:	68 24 14 80 00       	push   $0x801424
  800e23:	6a 23                	push   $0x23
  800e25:	68 41 14 80 00       	push   $0x801441
  800e2a:	e8 03 f3 ff ff       	call   800132 <_panic>

00800e2f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e2f:	f3 0f 1e fb          	endbr32 
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e39:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e40:	74 0a                	je     800e4c <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e42:	8b 45 08             	mov    0x8(%ebp),%eax
  800e45:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800e4a:	c9                   	leave  
  800e4b:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  800e4c:	83 ec 0c             	sub    $0xc,%esp
  800e4f:	68 4f 14 80 00       	push   $0x80144f
  800e54:	e8 c0 f3 ff ff       	call   800219 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  800e59:	83 c4 0c             	add    $0xc,%esp
  800e5c:	6a 07                	push   $0x7
  800e5e:	68 00 f0 bf ee       	push   $0xeebff000
  800e63:	6a 00                	push   $0x0
  800e65:	e8 fa fd ff ff       	call   800c64 <sys_page_alloc>
  800e6a:	83 c4 10             	add    $0x10,%esp
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	78 2a                	js     800e9b <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  800e71:	83 ec 08             	sub    $0x8,%esp
  800e74:	68 af 0e 80 00       	push   $0x800eaf
  800e79:	6a 00                	push   $0x0
  800e7b:	e8 fd fe ff ff       	call   800d7d <sys_env_set_pgfault_upcall>
  800e80:	83 c4 10             	add    $0x10,%esp
  800e83:	85 c0                	test   %eax,%eax
  800e85:	79 bb                	jns    800e42 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  800e87:	83 ec 04             	sub    $0x4,%esp
  800e8a:	68 8c 14 80 00       	push   $0x80148c
  800e8f:	6a 25                	push   $0x25
  800e91:	68 7c 14 80 00       	push   $0x80147c
  800e96:	e8 97 f2 ff ff       	call   800132 <_panic>
            panic("Allocation of UXSTACK failed!");
  800e9b:	83 ec 04             	sub    $0x4,%esp
  800e9e:	68 5e 14 80 00       	push   $0x80145e
  800ea3:	6a 22                	push   $0x22
  800ea5:	68 7c 14 80 00       	push   $0x80147c
  800eaa:	e8 83 f2 ff ff       	call   800132 <_panic>

00800eaf <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800eaf:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800eb0:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800eb5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800eb7:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  800eba:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  800ebe:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  800ec2:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  800ec5:	83 c4 08             	add    $0x8,%esp
    popa
  800ec8:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $0x4, %esp
  800ec9:	83 c4 04             	add    $0x4,%esp
    popf
  800ecc:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  800ecd:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  800ed0:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  800ed4:	c3                   	ret    
  800ed5:	66 90                	xchg   %ax,%ax
  800ed7:	66 90                	xchg   %ax,%ax
  800ed9:	66 90                	xchg   %ax,%ax
  800edb:	66 90                	xchg   %ax,%ax
  800edd:	66 90                	xchg   %ax,%ax
  800edf:	90                   	nop

00800ee0 <__udivdi3>:
  800ee0:	f3 0f 1e fb          	endbr32 
  800ee4:	55                   	push   %ebp
  800ee5:	57                   	push   %edi
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
  800ee8:	83 ec 1c             	sub    $0x1c,%esp
  800eeb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800eef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800ef3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ef7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800efb:	85 d2                	test   %edx,%edx
  800efd:	75 19                	jne    800f18 <__udivdi3+0x38>
  800eff:	39 f3                	cmp    %esi,%ebx
  800f01:	76 4d                	jbe    800f50 <__udivdi3+0x70>
  800f03:	31 ff                	xor    %edi,%edi
  800f05:	89 e8                	mov    %ebp,%eax
  800f07:	89 f2                	mov    %esi,%edx
  800f09:	f7 f3                	div    %ebx
  800f0b:	89 fa                	mov    %edi,%edx
  800f0d:	83 c4 1c             	add    $0x1c,%esp
  800f10:	5b                   	pop    %ebx
  800f11:	5e                   	pop    %esi
  800f12:	5f                   	pop    %edi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    
  800f15:	8d 76 00             	lea    0x0(%esi),%esi
  800f18:	39 f2                	cmp    %esi,%edx
  800f1a:	76 14                	jbe    800f30 <__udivdi3+0x50>
  800f1c:	31 ff                	xor    %edi,%edi
  800f1e:	31 c0                	xor    %eax,%eax
  800f20:	89 fa                	mov    %edi,%edx
  800f22:	83 c4 1c             	add    $0x1c,%esp
  800f25:	5b                   	pop    %ebx
  800f26:	5e                   	pop    %esi
  800f27:	5f                   	pop    %edi
  800f28:	5d                   	pop    %ebp
  800f29:	c3                   	ret    
  800f2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f30:	0f bd fa             	bsr    %edx,%edi
  800f33:	83 f7 1f             	xor    $0x1f,%edi
  800f36:	75 48                	jne    800f80 <__udivdi3+0xa0>
  800f38:	39 f2                	cmp    %esi,%edx
  800f3a:	72 06                	jb     800f42 <__udivdi3+0x62>
  800f3c:	31 c0                	xor    %eax,%eax
  800f3e:	39 eb                	cmp    %ebp,%ebx
  800f40:	77 de                	ja     800f20 <__udivdi3+0x40>
  800f42:	b8 01 00 00 00       	mov    $0x1,%eax
  800f47:	eb d7                	jmp    800f20 <__udivdi3+0x40>
  800f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f50:	89 d9                	mov    %ebx,%ecx
  800f52:	85 db                	test   %ebx,%ebx
  800f54:	75 0b                	jne    800f61 <__udivdi3+0x81>
  800f56:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5b:	31 d2                	xor    %edx,%edx
  800f5d:	f7 f3                	div    %ebx
  800f5f:	89 c1                	mov    %eax,%ecx
  800f61:	31 d2                	xor    %edx,%edx
  800f63:	89 f0                	mov    %esi,%eax
  800f65:	f7 f1                	div    %ecx
  800f67:	89 c6                	mov    %eax,%esi
  800f69:	89 e8                	mov    %ebp,%eax
  800f6b:	89 f7                	mov    %esi,%edi
  800f6d:	f7 f1                	div    %ecx
  800f6f:	89 fa                	mov    %edi,%edx
  800f71:	83 c4 1c             	add    $0x1c,%esp
  800f74:	5b                   	pop    %ebx
  800f75:	5e                   	pop    %esi
  800f76:	5f                   	pop    %edi
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    
  800f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f80:	89 f9                	mov    %edi,%ecx
  800f82:	b8 20 00 00 00       	mov    $0x20,%eax
  800f87:	29 f8                	sub    %edi,%eax
  800f89:	d3 e2                	shl    %cl,%edx
  800f8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f8f:	89 c1                	mov    %eax,%ecx
  800f91:	89 da                	mov    %ebx,%edx
  800f93:	d3 ea                	shr    %cl,%edx
  800f95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f99:	09 d1                	or     %edx,%ecx
  800f9b:	89 f2                	mov    %esi,%edx
  800f9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fa1:	89 f9                	mov    %edi,%ecx
  800fa3:	d3 e3                	shl    %cl,%ebx
  800fa5:	89 c1                	mov    %eax,%ecx
  800fa7:	d3 ea                	shr    %cl,%edx
  800fa9:	89 f9                	mov    %edi,%ecx
  800fab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800faf:	89 eb                	mov    %ebp,%ebx
  800fb1:	d3 e6                	shl    %cl,%esi
  800fb3:	89 c1                	mov    %eax,%ecx
  800fb5:	d3 eb                	shr    %cl,%ebx
  800fb7:	09 de                	or     %ebx,%esi
  800fb9:	89 f0                	mov    %esi,%eax
  800fbb:	f7 74 24 08          	divl   0x8(%esp)
  800fbf:	89 d6                	mov    %edx,%esi
  800fc1:	89 c3                	mov    %eax,%ebx
  800fc3:	f7 64 24 0c          	mull   0xc(%esp)
  800fc7:	39 d6                	cmp    %edx,%esi
  800fc9:	72 15                	jb     800fe0 <__udivdi3+0x100>
  800fcb:	89 f9                	mov    %edi,%ecx
  800fcd:	d3 e5                	shl    %cl,%ebp
  800fcf:	39 c5                	cmp    %eax,%ebp
  800fd1:	73 04                	jae    800fd7 <__udivdi3+0xf7>
  800fd3:	39 d6                	cmp    %edx,%esi
  800fd5:	74 09                	je     800fe0 <__udivdi3+0x100>
  800fd7:	89 d8                	mov    %ebx,%eax
  800fd9:	31 ff                	xor    %edi,%edi
  800fdb:	e9 40 ff ff ff       	jmp    800f20 <__udivdi3+0x40>
  800fe0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800fe3:	31 ff                	xor    %edi,%edi
  800fe5:	e9 36 ff ff ff       	jmp    800f20 <__udivdi3+0x40>
  800fea:	66 90                	xchg   %ax,%ax
  800fec:	66 90                	xchg   %ax,%ax
  800fee:	66 90                	xchg   %ax,%ax

00800ff0 <__umoddi3>:
  800ff0:	f3 0f 1e fb          	endbr32 
  800ff4:	55                   	push   %ebp
  800ff5:	57                   	push   %edi
  800ff6:	56                   	push   %esi
  800ff7:	53                   	push   %ebx
  800ff8:	83 ec 1c             	sub    $0x1c,%esp
  800ffb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800fff:	8b 74 24 30          	mov    0x30(%esp),%esi
  801003:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801007:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80100b:	85 c0                	test   %eax,%eax
  80100d:	75 19                	jne    801028 <__umoddi3+0x38>
  80100f:	39 df                	cmp    %ebx,%edi
  801011:	76 5d                	jbe    801070 <__umoddi3+0x80>
  801013:	89 f0                	mov    %esi,%eax
  801015:	89 da                	mov    %ebx,%edx
  801017:	f7 f7                	div    %edi
  801019:	89 d0                	mov    %edx,%eax
  80101b:	31 d2                	xor    %edx,%edx
  80101d:	83 c4 1c             	add    $0x1c,%esp
  801020:	5b                   	pop    %ebx
  801021:	5e                   	pop    %esi
  801022:	5f                   	pop    %edi
  801023:	5d                   	pop    %ebp
  801024:	c3                   	ret    
  801025:	8d 76 00             	lea    0x0(%esi),%esi
  801028:	89 f2                	mov    %esi,%edx
  80102a:	39 d8                	cmp    %ebx,%eax
  80102c:	76 12                	jbe    801040 <__umoddi3+0x50>
  80102e:	89 f0                	mov    %esi,%eax
  801030:	89 da                	mov    %ebx,%edx
  801032:	83 c4 1c             	add    $0x1c,%esp
  801035:	5b                   	pop    %ebx
  801036:	5e                   	pop    %esi
  801037:	5f                   	pop    %edi
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    
  80103a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801040:	0f bd e8             	bsr    %eax,%ebp
  801043:	83 f5 1f             	xor    $0x1f,%ebp
  801046:	75 50                	jne    801098 <__umoddi3+0xa8>
  801048:	39 d8                	cmp    %ebx,%eax
  80104a:	0f 82 e0 00 00 00    	jb     801130 <__umoddi3+0x140>
  801050:	89 d9                	mov    %ebx,%ecx
  801052:	39 f7                	cmp    %esi,%edi
  801054:	0f 86 d6 00 00 00    	jbe    801130 <__umoddi3+0x140>
  80105a:	89 d0                	mov    %edx,%eax
  80105c:	89 ca                	mov    %ecx,%edx
  80105e:	83 c4 1c             	add    $0x1c,%esp
  801061:	5b                   	pop    %ebx
  801062:	5e                   	pop    %esi
  801063:	5f                   	pop    %edi
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    
  801066:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80106d:	8d 76 00             	lea    0x0(%esi),%esi
  801070:	89 fd                	mov    %edi,%ebp
  801072:	85 ff                	test   %edi,%edi
  801074:	75 0b                	jne    801081 <__umoddi3+0x91>
  801076:	b8 01 00 00 00       	mov    $0x1,%eax
  80107b:	31 d2                	xor    %edx,%edx
  80107d:	f7 f7                	div    %edi
  80107f:	89 c5                	mov    %eax,%ebp
  801081:	89 d8                	mov    %ebx,%eax
  801083:	31 d2                	xor    %edx,%edx
  801085:	f7 f5                	div    %ebp
  801087:	89 f0                	mov    %esi,%eax
  801089:	f7 f5                	div    %ebp
  80108b:	89 d0                	mov    %edx,%eax
  80108d:	31 d2                	xor    %edx,%edx
  80108f:	eb 8c                	jmp    80101d <__umoddi3+0x2d>
  801091:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801098:	89 e9                	mov    %ebp,%ecx
  80109a:	ba 20 00 00 00       	mov    $0x20,%edx
  80109f:	29 ea                	sub    %ebp,%edx
  8010a1:	d3 e0                	shl    %cl,%eax
  8010a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a7:	89 d1                	mov    %edx,%ecx
  8010a9:	89 f8                	mov    %edi,%eax
  8010ab:	d3 e8                	shr    %cl,%eax
  8010ad:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8010b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010b5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010b9:	09 c1                	or     %eax,%ecx
  8010bb:	89 d8                	mov    %ebx,%eax
  8010bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010c1:	89 e9                	mov    %ebp,%ecx
  8010c3:	d3 e7                	shl    %cl,%edi
  8010c5:	89 d1                	mov    %edx,%ecx
  8010c7:	d3 e8                	shr    %cl,%eax
  8010c9:	89 e9                	mov    %ebp,%ecx
  8010cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010cf:	d3 e3                	shl    %cl,%ebx
  8010d1:	89 c7                	mov    %eax,%edi
  8010d3:	89 d1                	mov    %edx,%ecx
  8010d5:	89 f0                	mov    %esi,%eax
  8010d7:	d3 e8                	shr    %cl,%eax
  8010d9:	89 e9                	mov    %ebp,%ecx
  8010db:	89 fa                	mov    %edi,%edx
  8010dd:	d3 e6                	shl    %cl,%esi
  8010df:	09 d8                	or     %ebx,%eax
  8010e1:	f7 74 24 08          	divl   0x8(%esp)
  8010e5:	89 d1                	mov    %edx,%ecx
  8010e7:	89 f3                	mov    %esi,%ebx
  8010e9:	f7 64 24 0c          	mull   0xc(%esp)
  8010ed:	89 c6                	mov    %eax,%esi
  8010ef:	89 d7                	mov    %edx,%edi
  8010f1:	39 d1                	cmp    %edx,%ecx
  8010f3:	72 06                	jb     8010fb <__umoddi3+0x10b>
  8010f5:	75 10                	jne    801107 <__umoddi3+0x117>
  8010f7:	39 c3                	cmp    %eax,%ebx
  8010f9:	73 0c                	jae    801107 <__umoddi3+0x117>
  8010fb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8010ff:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801103:	89 d7                	mov    %edx,%edi
  801105:	89 c6                	mov    %eax,%esi
  801107:	89 ca                	mov    %ecx,%edx
  801109:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80110e:	29 f3                	sub    %esi,%ebx
  801110:	19 fa                	sbb    %edi,%edx
  801112:	89 d0                	mov    %edx,%eax
  801114:	d3 e0                	shl    %cl,%eax
  801116:	89 e9                	mov    %ebp,%ecx
  801118:	d3 eb                	shr    %cl,%ebx
  80111a:	d3 ea                	shr    %cl,%edx
  80111c:	09 d8                	or     %ebx,%eax
  80111e:	83 c4 1c             	add    $0x1c,%esp
  801121:	5b                   	pop    %ebx
  801122:	5e                   	pop    %esi
  801123:	5f                   	pop    %edi
  801124:	5d                   	pop    %ebp
  801125:	c3                   	ret    
  801126:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80112d:	8d 76 00             	lea    0x0(%esi),%esi
  801130:	29 fe                	sub    %edi,%esi
  801132:	19 c3                	sbb    %eax,%ebx
  801134:	89 f2                	mov    %esi,%edx
  801136:	89 d9                	mov    %ebx,%ecx
  801138:	e9 1d ff ff ff       	jmp    80105a <__umoddi3+0x6a>
