
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
  800044:	68 20 11 80 00       	push   $0x801120
  800049:	e8 b6 01 00 00       	call   800204 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004e:	83 c4 0c             	add    $0xc,%esp
  800051:	6a 07                	push   $0x7
  800053:	89 d8                	mov    %ebx,%eax
  800055:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005a:	50                   	push   %eax
  80005b:	6a 00                	push   $0x0
  80005d:	e8 ed 0b 00 00       	call   800c4f <sys_page_alloc>
  800062:	83 c4 10             	add    $0x10,%esp
  800065:	85 c0                	test   %eax,%eax
  800067:	78 16                	js     80007f <handler+0x4c>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800069:	53                   	push   %ebx
  80006a:	68 6c 11 80 00       	push   $0x80116c
  80006f:	6a 64                	push   $0x64
  800071:	53                   	push   %ebx
  800072:	e8 35 07 00 00       	call   8007ac <snprintf>
}
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007d:	c9                   	leave  
  80007e:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007f:	83 ec 0c             	sub    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	53                   	push   %ebx
  800084:	68 40 11 80 00       	push   $0x801140
  800089:	6a 0f                	push   $0xf
  80008b:	68 2a 11 80 00       	push   $0x80112a
  800090:	e8 88 00 00 00       	call   80011d <_panic>

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
  8000a4:	e8 71 0d 00 00       	call   800e1a <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a9:	83 c4 08             	add    $0x8,%esp
  8000ac:	6a 04                	push   $0x4
  8000ae:	68 ef be ad de       	push   $0xdeadbeef
  8000b3:	e8 c7 0a 00 00       	call   800b7f <sys_cputs>
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
    envid_t envid = sys_getenvid();
  8000cc:	e8 38 0b 00 00       	call   800c09 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8000d1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000de:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e3:	85 db                	test   %ebx,%ebx
  8000e5:	7e 07                	jle    8000ee <libmain+0x31>
		binaryname = argv[0];
  8000e7:	8b 06                	mov    (%esi),%eax
  8000e9:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ee:	83 ec 08             	sub    $0x8,%esp
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	e8 9d ff ff ff       	call   800095 <umain>

	// exit gracefully
	exit();
  8000f8:	e8 0a 00 00 00       	call   800107 <exit>
}
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800107:	f3 0f 1e fb          	endbr32 
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800111:	6a 00                	push   $0x0
  800113:	e8 ac 0a 00 00       	call   800bc4 <sys_env_destroy>
}
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	c9                   	leave  
  80011c:	c3                   	ret    

0080011d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80011d:	f3 0f 1e fb          	endbr32 
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800126:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800129:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80012f:	e8 d5 0a 00 00       	call   800c09 <sys_getenvid>
  800134:	83 ec 0c             	sub    $0xc,%esp
  800137:	ff 75 0c             	pushl  0xc(%ebp)
  80013a:	ff 75 08             	pushl  0x8(%ebp)
  80013d:	56                   	push   %esi
  80013e:	50                   	push   %eax
  80013f:	68 98 11 80 00       	push   $0x801198
  800144:	e8 bb 00 00 00       	call   800204 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800149:	83 c4 18             	add    $0x18,%esp
  80014c:	53                   	push   %ebx
  80014d:	ff 75 10             	pushl  0x10(%ebp)
  800150:	e8 5a 00 00 00       	call   8001af <vcprintf>
	cprintf("\n");
  800155:	c7 04 24 3c 14 80 00 	movl   $0x80143c,(%esp)
  80015c:	e8 a3 00 00 00       	call   800204 <cprintf>
  800161:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800164:	cc                   	int3   
  800165:	eb fd                	jmp    800164 <_panic+0x47>

00800167 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800167:	f3 0f 1e fb          	endbr32 
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	53                   	push   %ebx
  80016f:	83 ec 04             	sub    $0x4,%esp
  800172:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800175:	8b 13                	mov    (%ebx),%edx
  800177:	8d 42 01             	lea    0x1(%edx),%eax
  80017a:	89 03                	mov    %eax,(%ebx)
  80017c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800183:	3d ff 00 00 00       	cmp    $0xff,%eax
  800188:	74 09                	je     800193 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80018a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80018e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800191:	c9                   	leave  
  800192:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800193:	83 ec 08             	sub    $0x8,%esp
  800196:	68 ff 00 00 00       	push   $0xff
  80019b:	8d 43 08             	lea    0x8(%ebx),%eax
  80019e:	50                   	push   %eax
  80019f:	e8 db 09 00 00       	call   800b7f <sys_cputs>
		b->idx = 0;
  8001a4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001aa:	83 c4 10             	add    $0x10,%esp
  8001ad:	eb db                	jmp    80018a <putch+0x23>

008001af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001af:	f3 0f 1e fb          	endbr32 
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c3:	00 00 00 
	b.cnt = 0;
  8001c6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d0:	ff 75 0c             	pushl  0xc(%ebp)
  8001d3:	ff 75 08             	pushl  0x8(%ebp)
  8001d6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001dc:	50                   	push   %eax
  8001dd:	68 67 01 80 00       	push   $0x800167
  8001e2:	e8 20 01 00 00       	call   800307 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e7:	83 c4 08             	add    $0x8,%esp
  8001ea:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f6:	50                   	push   %eax
  8001f7:	e8 83 09 00 00       	call   800b7f <sys_cputs>

	return b.cnt;
}
  8001fc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800204:	f3 0f 1e fb          	endbr32 
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800211:	50                   	push   %eax
  800212:	ff 75 08             	pushl  0x8(%ebp)
  800215:	e8 95 ff ff ff       	call   8001af <vcprintf>
	va_end(ap);

	return cnt;
}
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 1c             	sub    $0x1c,%esp
  800225:	89 c7                	mov    %eax,%edi
  800227:	89 d6                	mov    %edx,%esi
  800229:	8b 45 08             	mov    0x8(%ebp),%eax
  80022c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022f:	89 d1                	mov    %edx,%ecx
  800231:	89 c2                	mov    %eax,%edx
  800233:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800236:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800239:	8b 45 10             	mov    0x10(%ebp),%eax
  80023c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800242:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800249:	39 c2                	cmp    %eax,%edx
  80024b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80024e:	72 3e                	jb     80028e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	ff 75 18             	pushl  0x18(%ebp)
  800256:	83 eb 01             	sub    $0x1,%ebx
  800259:	53                   	push   %ebx
  80025a:	50                   	push   %eax
  80025b:	83 ec 08             	sub    $0x8,%esp
  80025e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800261:	ff 75 e0             	pushl  -0x20(%ebp)
  800264:	ff 75 dc             	pushl  -0x24(%ebp)
  800267:	ff 75 d8             	pushl  -0x28(%ebp)
  80026a:	e8 51 0c 00 00       	call   800ec0 <__udivdi3>
  80026f:	83 c4 18             	add    $0x18,%esp
  800272:	52                   	push   %edx
  800273:	50                   	push   %eax
  800274:	89 f2                	mov    %esi,%edx
  800276:	89 f8                	mov    %edi,%eax
  800278:	e8 9f ff ff ff       	call   80021c <printnum>
  80027d:	83 c4 20             	add    $0x20,%esp
  800280:	eb 13                	jmp    800295 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800282:	83 ec 08             	sub    $0x8,%esp
  800285:	56                   	push   %esi
  800286:	ff 75 18             	pushl  0x18(%ebp)
  800289:	ff d7                	call   *%edi
  80028b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80028e:	83 eb 01             	sub    $0x1,%ebx
  800291:	85 db                	test   %ebx,%ebx
  800293:	7f ed                	jg     800282 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800295:	83 ec 08             	sub    $0x8,%esp
  800298:	56                   	push   %esi
  800299:	83 ec 04             	sub    $0x4,%esp
  80029c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029f:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a8:	e8 23 0d 00 00       	call   800fd0 <__umoddi3>
  8002ad:	83 c4 14             	add    $0x14,%esp
  8002b0:	0f be 80 bb 11 80 00 	movsbl 0x8011bb(%eax),%eax
  8002b7:	50                   	push   %eax
  8002b8:	ff d7                	call   *%edi
}
  8002ba:	83 c4 10             	add    $0x10,%esp
  8002bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5f                   	pop    %edi
  8002c3:	5d                   	pop    %ebp
  8002c4:	c3                   	ret    

008002c5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c5:	f3 0f 1e fb          	endbr32 
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d3:	8b 10                	mov    (%eax),%edx
  8002d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d8:	73 0a                	jae    8002e4 <sprintputch+0x1f>
		*b->buf++ = ch;
  8002da:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	88 02                	mov    %al,(%edx)
}
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <printfmt>:
{
  8002e6:	f3 0f 1e fb          	endbr32 
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f3:	50                   	push   %eax
  8002f4:	ff 75 10             	pushl  0x10(%ebp)
  8002f7:	ff 75 0c             	pushl  0xc(%ebp)
  8002fa:	ff 75 08             	pushl  0x8(%ebp)
  8002fd:	e8 05 00 00 00       	call   800307 <vprintfmt>
}
  800302:	83 c4 10             	add    $0x10,%esp
  800305:	c9                   	leave  
  800306:	c3                   	ret    

00800307 <vprintfmt>:
{
  800307:	f3 0f 1e fb          	endbr32 
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	57                   	push   %edi
  80030f:	56                   	push   %esi
  800310:	53                   	push   %ebx
  800311:	83 ec 3c             	sub    $0x3c,%esp
  800314:	8b 75 08             	mov    0x8(%ebp),%esi
  800317:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80031d:	e9 4a 03 00 00       	jmp    80066c <vprintfmt+0x365>
		padc = ' ';
  800322:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800326:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80032d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800334:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80033b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8d 47 01             	lea    0x1(%edi),%eax
  800343:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800346:	0f b6 17             	movzbl (%edi),%edx
  800349:	8d 42 dd             	lea    -0x23(%edx),%eax
  80034c:	3c 55                	cmp    $0x55,%al
  80034e:	0f 87 de 03 00 00    	ja     800732 <vprintfmt+0x42b>
  800354:	0f b6 c0             	movzbl %al,%eax
  800357:	3e ff 24 85 80 12 80 	notrack jmp *0x801280(,%eax,4)
  80035e:	00 
  80035f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800362:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800366:	eb d8                	jmp    800340 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036b:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80036f:	eb cf                	jmp    800340 <vprintfmt+0x39>
  800371:	0f b6 d2             	movzbl %dl,%edx
  800374:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800377:	b8 00 00 00 00       	mov    $0x0,%eax
  80037c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80037f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800382:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800386:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800389:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80038c:	83 f9 09             	cmp    $0x9,%ecx
  80038f:	77 55                	ja     8003e6 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800391:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800394:	eb e9                	jmp    80037f <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800396:	8b 45 14             	mov    0x14(%ebp),%eax
  800399:	8b 00                	mov    (%eax),%eax
  80039b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039e:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a1:	8d 40 04             	lea    0x4(%eax),%eax
  8003a4:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003aa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ae:	79 90                	jns    800340 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003bd:	eb 81                	jmp    800340 <vprintfmt+0x39>
  8003bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c2:	85 c0                	test   %eax,%eax
  8003c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c9:	0f 49 d0             	cmovns %eax,%edx
  8003cc:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003d2:	e9 69 ff ff ff       	jmp    800340 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003da:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003e1:	e9 5a ff ff ff       	jmp    800340 <vprintfmt+0x39>
  8003e6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ec:	eb bc                	jmp    8003aa <vprintfmt+0xa3>
			lflag++;
  8003ee:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f4:	e9 47 ff ff ff       	jmp    800340 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fc:	8d 78 04             	lea    0x4(%eax),%edi
  8003ff:	83 ec 08             	sub    $0x8,%esp
  800402:	53                   	push   %ebx
  800403:	ff 30                	pushl  (%eax)
  800405:	ff d6                	call   *%esi
			break;
  800407:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80040a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80040d:	e9 57 02 00 00       	jmp    800669 <vprintfmt+0x362>
			err = va_arg(ap, int);
  800412:	8b 45 14             	mov    0x14(%ebp),%eax
  800415:	8d 78 04             	lea    0x4(%eax),%edi
  800418:	8b 00                	mov    (%eax),%eax
  80041a:	99                   	cltd   
  80041b:	31 d0                	xor    %edx,%eax
  80041d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041f:	83 f8 08             	cmp    $0x8,%eax
  800422:	7f 23                	jg     800447 <vprintfmt+0x140>
  800424:	8b 14 85 e0 13 80 00 	mov    0x8013e0(,%eax,4),%edx
  80042b:	85 d2                	test   %edx,%edx
  80042d:	74 18                	je     800447 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80042f:	52                   	push   %edx
  800430:	68 dc 11 80 00       	push   $0x8011dc
  800435:	53                   	push   %ebx
  800436:	56                   	push   %esi
  800437:	e8 aa fe ff ff       	call   8002e6 <printfmt>
  80043c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800442:	e9 22 02 00 00       	jmp    800669 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800447:	50                   	push   %eax
  800448:	68 d3 11 80 00       	push   $0x8011d3
  80044d:	53                   	push   %ebx
  80044e:	56                   	push   %esi
  80044f:	e8 92 fe ff ff       	call   8002e6 <printfmt>
  800454:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800457:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80045a:	e9 0a 02 00 00       	jmp    800669 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  80045f:	8b 45 14             	mov    0x14(%ebp),%eax
  800462:	83 c0 04             	add    $0x4,%eax
  800465:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80046d:	85 d2                	test   %edx,%edx
  80046f:	b8 cc 11 80 00       	mov    $0x8011cc,%eax
  800474:	0f 45 c2             	cmovne %edx,%eax
  800477:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80047a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047e:	7e 06                	jle    800486 <vprintfmt+0x17f>
  800480:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800484:	75 0d                	jne    800493 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800489:	89 c7                	mov    %eax,%edi
  80048b:	03 45 e0             	add    -0x20(%ebp),%eax
  80048e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800491:	eb 55                	jmp    8004e8 <vprintfmt+0x1e1>
  800493:	83 ec 08             	sub    $0x8,%esp
  800496:	ff 75 d8             	pushl  -0x28(%ebp)
  800499:	ff 75 cc             	pushl  -0x34(%ebp)
  80049c:	e8 45 03 00 00       	call   8007e6 <strnlen>
  8004a1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004a4:	29 c2                	sub    %eax,%edx
  8004a6:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004a9:	83 c4 10             	add    $0x10,%esp
  8004ac:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004ae:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b5:	85 ff                	test   %edi,%edi
  8004b7:	7e 11                	jle    8004ca <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	53                   	push   %ebx
  8004bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c2:	83 ef 01             	sub    $0x1,%edi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	eb eb                	jmp    8004b5 <vprintfmt+0x1ae>
  8004ca:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004cd:	85 d2                	test   %edx,%edx
  8004cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d4:	0f 49 c2             	cmovns %edx,%eax
  8004d7:	29 c2                	sub    %eax,%edx
  8004d9:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004dc:	eb a8                	jmp    800486 <vprintfmt+0x17f>
					putch(ch, putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	53                   	push   %ebx
  8004e2:	52                   	push   %edx
  8004e3:	ff d6                	call   *%esi
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004eb:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ed:	83 c7 01             	add    $0x1,%edi
  8004f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f4:	0f be d0             	movsbl %al,%edx
  8004f7:	85 d2                	test   %edx,%edx
  8004f9:	74 4b                	je     800546 <vprintfmt+0x23f>
  8004fb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ff:	78 06                	js     800507 <vprintfmt+0x200>
  800501:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800505:	78 1e                	js     800525 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800507:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80050b:	74 d1                	je     8004de <vprintfmt+0x1d7>
  80050d:	0f be c0             	movsbl %al,%eax
  800510:	83 e8 20             	sub    $0x20,%eax
  800513:	83 f8 5e             	cmp    $0x5e,%eax
  800516:	76 c6                	jbe    8004de <vprintfmt+0x1d7>
					putch('?', putdat);
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	53                   	push   %ebx
  80051c:	6a 3f                	push   $0x3f
  80051e:	ff d6                	call   *%esi
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	eb c3                	jmp    8004e8 <vprintfmt+0x1e1>
  800525:	89 cf                	mov    %ecx,%edi
  800527:	eb 0e                	jmp    800537 <vprintfmt+0x230>
				putch(' ', putdat);
  800529:	83 ec 08             	sub    $0x8,%esp
  80052c:	53                   	push   %ebx
  80052d:	6a 20                	push   $0x20
  80052f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800531:	83 ef 01             	sub    $0x1,%edi
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	85 ff                	test   %edi,%edi
  800539:	7f ee                	jg     800529 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80053b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80053e:	89 45 14             	mov    %eax,0x14(%ebp)
  800541:	e9 23 01 00 00       	jmp    800669 <vprintfmt+0x362>
  800546:	89 cf                	mov    %ecx,%edi
  800548:	eb ed                	jmp    800537 <vprintfmt+0x230>
	if (lflag >= 2)
  80054a:	83 f9 01             	cmp    $0x1,%ecx
  80054d:	7f 1b                	jg     80056a <vprintfmt+0x263>
	else if (lflag)
  80054f:	85 c9                	test   %ecx,%ecx
  800551:	74 63                	je     8005b6 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800553:	8b 45 14             	mov    0x14(%ebp),%eax
  800556:	8b 00                	mov    (%eax),%eax
  800558:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055b:	99                   	cltd   
  80055c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8d 40 04             	lea    0x4(%eax),%eax
  800565:	89 45 14             	mov    %eax,0x14(%ebp)
  800568:	eb 17                	jmp    800581 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80056a:	8b 45 14             	mov    0x14(%ebp),%eax
  80056d:	8b 50 04             	mov    0x4(%eax),%edx
  800570:	8b 00                	mov    (%eax),%eax
  800572:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800575:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8d 40 08             	lea    0x8(%eax),%eax
  80057e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800581:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800584:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800587:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80058c:	85 c9                	test   %ecx,%ecx
  80058e:	0f 89 bb 00 00 00    	jns    80064f <vprintfmt+0x348>
				putch('-', putdat);
  800594:	83 ec 08             	sub    $0x8,%esp
  800597:	53                   	push   %ebx
  800598:	6a 2d                	push   $0x2d
  80059a:	ff d6                	call   *%esi
				num = -(long long) num;
  80059c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a2:	f7 da                	neg    %edx
  8005a4:	83 d1 00             	adc    $0x0,%ecx
  8005a7:	f7 d9                	neg    %ecx
  8005a9:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005ac:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b1:	e9 99 00 00 00       	jmp    80064f <vprintfmt+0x348>
		return va_arg(*ap, int);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8b 00                	mov    (%eax),%eax
  8005bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005be:	99                   	cltd   
  8005bf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 40 04             	lea    0x4(%eax),%eax
  8005c8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005cb:	eb b4                	jmp    800581 <vprintfmt+0x27a>
	if (lflag >= 2)
  8005cd:	83 f9 01             	cmp    $0x1,%ecx
  8005d0:	7f 1b                	jg     8005ed <vprintfmt+0x2e6>
	else if (lflag)
  8005d2:	85 c9                	test   %ecx,%ecx
  8005d4:	74 2c                	je     800602 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8b 10                	mov    (%eax),%edx
  8005db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e0:	8d 40 04             	lea    0x4(%eax),%eax
  8005e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e6:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005eb:	eb 62                	jmp    80064f <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8b 10                	mov    (%eax),%edx
  8005f2:	8b 48 04             	mov    0x4(%eax),%ecx
  8005f5:	8d 40 08             	lea    0x8(%eax),%eax
  8005f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fb:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800600:	eb 4d                	jmp    80064f <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8b 10                	mov    (%eax),%edx
  800607:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060c:	8d 40 04             	lea    0x4(%eax),%eax
  80060f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800612:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800617:	eb 36                	jmp    80064f <vprintfmt+0x348>
	if (lflag >= 2)
  800619:	83 f9 01             	cmp    $0x1,%ecx
  80061c:	7f 17                	jg     800635 <vprintfmt+0x32e>
	else if (lflag)
  80061e:	85 c9                	test   %ecx,%ecx
  800620:	74 6e                	je     800690 <vprintfmt+0x389>
		return va_arg(*ap, long);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8b 10                	mov    (%eax),%edx
  800627:	89 d0                	mov    %edx,%eax
  800629:	99                   	cltd   
  80062a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80062d:	8d 49 04             	lea    0x4(%ecx),%ecx
  800630:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800633:	eb 11                	jmp    800646 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8b 50 04             	mov    0x4(%eax),%edx
  80063b:	8b 00                	mov    (%eax),%eax
  80063d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800640:	8d 49 08             	lea    0x8(%ecx),%ecx
  800643:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800646:	89 d1                	mov    %edx,%ecx
  800648:	89 c2                	mov    %eax,%edx
            base = 8;
  80064a:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80064f:	83 ec 0c             	sub    $0xc,%esp
  800652:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800656:	57                   	push   %edi
  800657:	ff 75 e0             	pushl  -0x20(%ebp)
  80065a:	50                   	push   %eax
  80065b:	51                   	push   %ecx
  80065c:	52                   	push   %edx
  80065d:	89 da                	mov    %ebx,%edx
  80065f:	89 f0                	mov    %esi,%eax
  800661:	e8 b6 fb ff ff       	call   80021c <printnum>
			break;
  800666:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800669:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80066c:	83 c7 01             	add    $0x1,%edi
  80066f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800673:	83 f8 25             	cmp    $0x25,%eax
  800676:	0f 84 a6 fc ff ff    	je     800322 <vprintfmt+0x1b>
			if (ch == '\0')
  80067c:	85 c0                	test   %eax,%eax
  80067e:	0f 84 ce 00 00 00    	je     800752 <vprintfmt+0x44b>
			putch(ch, putdat);
  800684:	83 ec 08             	sub    $0x8,%esp
  800687:	53                   	push   %ebx
  800688:	50                   	push   %eax
  800689:	ff d6                	call   *%esi
  80068b:	83 c4 10             	add    $0x10,%esp
  80068e:	eb dc                	jmp    80066c <vprintfmt+0x365>
		return va_arg(*ap, int);
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8b 10                	mov    (%eax),%edx
  800695:	89 d0                	mov    %edx,%eax
  800697:	99                   	cltd   
  800698:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80069b:	8d 49 04             	lea    0x4(%ecx),%ecx
  80069e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006a1:	eb a3                	jmp    800646 <vprintfmt+0x33f>
			putch('0', putdat);
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	6a 30                	push   $0x30
  8006a9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ab:	83 c4 08             	add    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	6a 78                	push   $0x78
  8006b1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 10                	mov    (%eax),%edx
  8006b8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006bd:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006c0:	8d 40 04             	lea    0x4(%eax),%eax
  8006c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006cb:	eb 82                	jmp    80064f <vprintfmt+0x348>
	if (lflag >= 2)
  8006cd:	83 f9 01             	cmp    $0x1,%ecx
  8006d0:	7f 1e                	jg     8006f0 <vprintfmt+0x3e9>
	else if (lflag)
  8006d2:	85 c9                	test   %ecx,%ecx
  8006d4:	74 32                	je     800708 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8b 10                	mov    (%eax),%edx
  8006db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e0:	8d 40 04             	lea    0x4(%eax),%eax
  8006e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e6:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006eb:	e9 5f ff ff ff       	jmp    80064f <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8006f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f3:	8b 10                	mov    (%eax),%edx
  8006f5:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f8:	8d 40 08             	lea    0x8(%eax),%eax
  8006fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006fe:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800703:	e9 47 ff ff ff       	jmp    80064f <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800708:	8b 45 14             	mov    0x14(%ebp),%eax
  80070b:	8b 10                	mov    (%eax),%edx
  80070d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800712:	8d 40 04             	lea    0x4(%eax),%eax
  800715:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800718:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80071d:	e9 2d ff ff ff       	jmp    80064f <vprintfmt+0x348>
			putch(ch, putdat);
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	53                   	push   %ebx
  800726:	6a 25                	push   $0x25
  800728:	ff d6                	call   *%esi
			break;
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	e9 37 ff ff ff       	jmp    800669 <vprintfmt+0x362>
			putch('%', putdat);
  800732:	83 ec 08             	sub    $0x8,%esp
  800735:	53                   	push   %ebx
  800736:	6a 25                	push   $0x25
  800738:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073a:	83 c4 10             	add    $0x10,%esp
  80073d:	89 f8                	mov    %edi,%eax
  80073f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800743:	74 05                	je     80074a <vprintfmt+0x443>
  800745:	83 e8 01             	sub    $0x1,%eax
  800748:	eb f5                	jmp    80073f <vprintfmt+0x438>
  80074a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80074d:	e9 17 ff ff ff       	jmp    800669 <vprintfmt+0x362>
}
  800752:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800755:	5b                   	pop    %ebx
  800756:	5e                   	pop    %esi
  800757:	5f                   	pop    %edi
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075a:	f3 0f 1e fb          	endbr32 
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	83 ec 18             	sub    $0x18,%esp
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800771:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800774:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077b:	85 c0                	test   %eax,%eax
  80077d:	74 26                	je     8007a5 <vsnprintf+0x4b>
  80077f:	85 d2                	test   %edx,%edx
  800781:	7e 22                	jle    8007a5 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800783:	ff 75 14             	pushl  0x14(%ebp)
  800786:	ff 75 10             	pushl  0x10(%ebp)
  800789:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80078c:	50                   	push   %eax
  80078d:	68 c5 02 80 00       	push   $0x8002c5
  800792:	e8 70 fb ff ff       	call   800307 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800797:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a0:	83 c4 10             	add    $0x10,%esp
}
  8007a3:	c9                   	leave  
  8007a4:	c3                   	ret    
		return -E_INVAL;
  8007a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007aa:	eb f7                	jmp    8007a3 <vsnprintf+0x49>

008007ac <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ac:	f3 0f 1e fb          	endbr32 
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b9:	50                   	push   %eax
  8007ba:	ff 75 10             	pushl  0x10(%ebp)
  8007bd:	ff 75 0c             	pushl  0xc(%ebp)
  8007c0:	ff 75 08             	pushl  0x8(%ebp)
  8007c3:	e8 92 ff ff ff       	call   80075a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c8:	c9                   	leave  
  8007c9:	c3                   	ret    

008007ca <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ca:	f3 0f 1e fb          	endbr32 
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007dd:	74 05                	je     8007e4 <strlen+0x1a>
		n++;
  8007df:	83 c0 01             	add    $0x1,%eax
  8007e2:	eb f5                	jmp    8007d9 <strlen+0xf>
	return n;
}
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e6:	f3 0f 1e fb          	endbr32 
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f8:	39 d0                	cmp    %edx,%eax
  8007fa:	74 0d                	je     800809 <strnlen+0x23>
  8007fc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800800:	74 05                	je     800807 <strnlen+0x21>
		n++;
  800802:	83 c0 01             	add    $0x1,%eax
  800805:	eb f1                	jmp    8007f8 <strnlen+0x12>
  800807:	89 c2                	mov    %eax,%edx
	return n;
}
  800809:	89 d0                	mov    %edx,%eax
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080d:	f3 0f 1e fb          	endbr32 
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	53                   	push   %ebx
  800815:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800818:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081b:	b8 00 00 00 00       	mov    $0x0,%eax
  800820:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800824:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800827:	83 c0 01             	add    $0x1,%eax
  80082a:	84 d2                	test   %dl,%dl
  80082c:	75 f2                	jne    800820 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80082e:	89 c8                	mov    %ecx,%eax
  800830:	5b                   	pop    %ebx
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800833:	f3 0f 1e fb          	endbr32 
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	53                   	push   %ebx
  80083b:	83 ec 10             	sub    $0x10,%esp
  80083e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800841:	53                   	push   %ebx
  800842:	e8 83 ff ff ff       	call   8007ca <strlen>
  800847:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80084a:	ff 75 0c             	pushl  0xc(%ebp)
  80084d:	01 d8                	add    %ebx,%eax
  80084f:	50                   	push   %eax
  800850:	e8 b8 ff ff ff       	call   80080d <strcpy>
	return dst;
}
  800855:	89 d8                	mov    %ebx,%eax
  800857:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085a:	c9                   	leave  
  80085b:	c3                   	ret    

0080085c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80085c:	f3 0f 1e fb          	endbr32 
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	56                   	push   %esi
  800864:	53                   	push   %ebx
  800865:	8b 75 08             	mov    0x8(%ebp),%esi
  800868:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086b:	89 f3                	mov    %esi,%ebx
  80086d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800870:	89 f0                	mov    %esi,%eax
  800872:	39 d8                	cmp    %ebx,%eax
  800874:	74 11                	je     800887 <strncpy+0x2b>
		*dst++ = *src;
  800876:	83 c0 01             	add    $0x1,%eax
  800879:	0f b6 0a             	movzbl (%edx),%ecx
  80087c:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80087f:	80 f9 01             	cmp    $0x1,%cl
  800882:	83 da ff             	sbb    $0xffffffff,%edx
  800885:	eb eb                	jmp    800872 <strncpy+0x16>
	}
	return ret;
}
  800887:	89 f0                	mov    %esi,%eax
  800889:	5b                   	pop    %ebx
  80088a:	5e                   	pop    %esi
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80088d:	f3 0f 1e fb          	endbr32 
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	56                   	push   %esi
  800895:	53                   	push   %ebx
  800896:	8b 75 08             	mov    0x8(%ebp),%esi
  800899:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089c:	8b 55 10             	mov    0x10(%ebp),%edx
  80089f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a1:	85 d2                	test   %edx,%edx
  8008a3:	74 21                	je     8008c6 <strlcpy+0x39>
  8008a5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008a9:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008ab:	39 c2                	cmp    %eax,%edx
  8008ad:	74 14                	je     8008c3 <strlcpy+0x36>
  8008af:	0f b6 19             	movzbl (%ecx),%ebx
  8008b2:	84 db                	test   %bl,%bl
  8008b4:	74 0b                	je     8008c1 <strlcpy+0x34>
			*dst++ = *src++;
  8008b6:	83 c1 01             	add    $0x1,%ecx
  8008b9:	83 c2 01             	add    $0x1,%edx
  8008bc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008bf:	eb ea                	jmp    8008ab <strlcpy+0x1e>
  8008c1:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008c3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008c6:	29 f0                	sub    %esi,%eax
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	5e                   	pop    %esi
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008cc:	f3 0f 1e fb          	endbr32 
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d9:	0f b6 01             	movzbl (%ecx),%eax
  8008dc:	84 c0                	test   %al,%al
  8008de:	74 0c                	je     8008ec <strcmp+0x20>
  8008e0:	3a 02                	cmp    (%edx),%al
  8008e2:	75 08                	jne    8008ec <strcmp+0x20>
		p++, q++;
  8008e4:	83 c1 01             	add    $0x1,%ecx
  8008e7:	83 c2 01             	add    $0x1,%edx
  8008ea:	eb ed                	jmp    8008d9 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ec:	0f b6 c0             	movzbl %al,%eax
  8008ef:	0f b6 12             	movzbl (%edx),%edx
  8008f2:	29 d0                	sub    %edx,%eax
}
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f6:	f3 0f 1e fb          	endbr32 
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	53                   	push   %ebx
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	8b 55 0c             	mov    0xc(%ebp),%edx
  800904:	89 c3                	mov    %eax,%ebx
  800906:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800909:	eb 06                	jmp    800911 <strncmp+0x1b>
		n--, p++, q++;
  80090b:	83 c0 01             	add    $0x1,%eax
  80090e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800911:	39 d8                	cmp    %ebx,%eax
  800913:	74 16                	je     80092b <strncmp+0x35>
  800915:	0f b6 08             	movzbl (%eax),%ecx
  800918:	84 c9                	test   %cl,%cl
  80091a:	74 04                	je     800920 <strncmp+0x2a>
  80091c:	3a 0a                	cmp    (%edx),%cl
  80091e:	74 eb                	je     80090b <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800920:	0f b6 00             	movzbl (%eax),%eax
  800923:	0f b6 12             	movzbl (%edx),%edx
  800926:	29 d0                	sub    %edx,%eax
}
  800928:	5b                   	pop    %ebx
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    
		return 0;
  80092b:	b8 00 00 00 00       	mov    $0x0,%eax
  800930:	eb f6                	jmp    800928 <strncmp+0x32>

00800932 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800932:	f3 0f 1e fb          	endbr32 
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800940:	0f b6 10             	movzbl (%eax),%edx
  800943:	84 d2                	test   %dl,%dl
  800945:	74 09                	je     800950 <strchr+0x1e>
		if (*s == c)
  800947:	38 ca                	cmp    %cl,%dl
  800949:	74 0a                	je     800955 <strchr+0x23>
	for (; *s; s++)
  80094b:	83 c0 01             	add    $0x1,%eax
  80094e:	eb f0                	jmp    800940 <strchr+0xe>
			return (char *) s;
	return 0;
  800950:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800957:	f3 0f 1e fb          	endbr32 
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800965:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800968:	38 ca                	cmp    %cl,%dl
  80096a:	74 09                	je     800975 <strfind+0x1e>
  80096c:	84 d2                	test   %dl,%dl
  80096e:	74 05                	je     800975 <strfind+0x1e>
	for (; *s; s++)
  800970:	83 c0 01             	add    $0x1,%eax
  800973:	eb f0                	jmp    800965 <strfind+0xe>
			break;
	return (char *) s;
}
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800977:	f3 0f 1e fb          	endbr32 
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	57                   	push   %edi
  80097f:	56                   	push   %esi
  800980:	53                   	push   %ebx
  800981:	8b 7d 08             	mov    0x8(%ebp),%edi
  800984:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800987:	85 c9                	test   %ecx,%ecx
  800989:	74 31                	je     8009bc <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098b:	89 f8                	mov    %edi,%eax
  80098d:	09 c8                	or     %ecx,%eax
  80098f:	a8 03                	test   $0x3,%al
  800991:	75 23                	jne    8009b6 <memset+0x3f>
		c &= 0xFF;
  800993:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800997:	89 d3                	mov    %edx,%ebx
  800999:	c1 e3 08             	shl    $0x8,%ebx
  80099c:	89 d0                	mov    %edx,%eax
  80099e:	c1 e0 18             	shl    $0x18,%eax
  8009a1:	89 d6                	mov    %edx,%esi
  8009a3:	c1 e6 10             	shl    $0x10,%esi
  8009a6:	09 f0                	or     %esi,%eax
  8009a8:	09 c2                	or     %eax,%edx
  8009aa:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ac:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009af:	89 d0                	mov    %edx,%eax
  8009b1:	fc                   	cld    
  8009b2:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b4:	eb 06                	jmp    8009bc <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b9:	fc                   	cld    
  8009ba:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009bc:	89 f8                	mov    %edi,%eax
  8009be:	5b                   	pop    %ebx
  8009bf:	5e                   	pop    %esi
  8009c0:	5f                   	pop    %edi
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c3:	f3 0f 1e fb          	endbr32 
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	57                   	push   %edi
  8009cb:	56                   	push   %esi
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d5:	39 c6                	cmp    %eax,%esi
  8009d7:	73 32                	jae    800a0b <memmove+0x48>
  8009d9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009dc:	39 c2                	cmp    %eax,%edx
  8009de:	76 2b                	jbe    800a0b <memmove+0x48>
		s += n;
		d += n;
  8009e0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e3:	89 fe                	mov    %edi,%esi
  8009e5:	09 ce                	or     %ecx,%esi
  8009e7:	09 d6                	or     %edx,%esi
  8009e9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ef:	75 0e                	jne    8009ff <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009f1:	83 ef 04             	sub    $0x4,%edi
  8009f4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009fa:	fd                   	std    
  8009fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fd:	eb 09                	jmp    800a08 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ff:	83 ef 01             	sub    $0x1,%edi
  800a02:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a05:	fd                   	std    
  800a06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a08:	fc                   	cld    
  800a09:	eb 1a                	jmp    800a25 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0b:	89 c2                	mov    %eax,%edx
  800a0d:	09 ca                	or     %ecx,%edx
  800a0f:	09 f2                	or     %esi,%edx
  800a11:	f6 c2 03             	test   $0x3,%dl
  800a14:	75 0a                	jne    800a20 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a16:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a19:	89 c7                	mov    %eax,%edi
  800a1b:	fc                   	cld    
  800a1c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1e:	eb 05                	jmp    800a25 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a20:	89 c7                	mov    %eax,%edi
  800a22:	fc                   	cld    
  800a23:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a25:	5e                   	pop    %esi
  800a26:	5f                   	pop    %edi
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a29:	f3 0f 1e fb          	endbr32 
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a33:	ff 75 10             	pushl  0x10(%ebp)
  800a36:	ff 75 0c             	pushl  0xc(%ebp)
  800a39:	ff 75 08             	pushl  0x8(%ebp)
  800a3c:	e8 82 ff ff ff       	call   8009c3 <memmove>
}
  800a41:	c9                   	leave  
  800a42:	c3                   	ret    

00800a43 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a43:	f3 0f 1e fb          	endbr32 
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	56                   	push   %esi
  800a4b:	53                   	push   %ebx
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a52:	89 c6                	mov    %eax,%esi
  800a54:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a57:	39 f0                	cmp    %esi,%eax
  800a59:	74 1c                	je     800a77 <memcmp+0x34>
		if (*s1 != *s2)
  800a5b:	0f b6 08             	movzbl (%eax),%ecx
  800a5e:	0f b6 1a             	movzbl (%edx),%ebx
  800a61:	38 d9                	cmp    %bl,%cl
  800a63:	75 08                	jne    800a6d <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a65:	83 c0 01             	add    $0x1,%eax
  800a68:	83 c2 01             	add    $0x1,%edx
  800a6b:	eb ea                	jmp    800a57 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a6d:	0f b6 c1             	movzbl %cl,%eax
  800a70:	0f b6 db             	movzbl %bl,%ebx
  800a73:	29 d8                	sub    %ebx,%eax
  800a75:	eb 05                	jmp    800a7c <memcmp+0x39>
	}

	return 0;
  800a77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7c:	5b                   	pop    %ebx
  800a7d:	5e                   	pop    %esi
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a80:	f3 0f 1e fb          	endbr32 
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a8d:	89 c2                	mov    %eax,%edx
  800a8f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a92:	39 d0                	cmp    %edx,%eax
  800a94:	73 09                	jae    800a9f <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a96:	38 08                	cmp    %cl,(%eax)
  800a98:	74 05                	je     800a9f <memfind+0x1f>
	for (; s < ends; s++)
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	eb f3                	jmp    800a92 <memfind+0x12>
			break;
	return (void *) s;
}
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa1:	f3 0f 1e fb          	endbr32 
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	57                   	push   %edi
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
  800aab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab1:	eb 03                	jmp    800ab6 <strtol+0x15>
		s++;
  800ab3:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ab6:	0f b6 01             	movzbl (%ecx),%eax
  800ab9:	3c 20                	cmp    $0x20,%al
  800abb:	74 f6                	je     800ab3 <strtol+0x12>
  800abd:	3c 09                	cmp    $0x9,%al
  800abf:	74 f2                	je     800ab3 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ac1:	3c 2b                	cmp    $0x2b,%al
  800ac3:	74 2a                	je     800aef <strtol+0x4e>
	int neg = 0;
  800ac5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800aca:	3c 2d                	cmp    $0x2d,%al
  800acc:	74 2b                	je     800af9 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ace:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ad4:	75 0f                	jne    800ae5 <strtol+0x44>
  800ad6:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad9:	74 28                	je     800b03 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800adb:	85 db                	test   %ebx,%ebx
  800add:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ae2:	0f 44 d8             	cmove  %eax,%ebx
  800ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aea:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aed:	eb 46                	jmp    800b35 <strtol+0x94>
		s++;
  800aef:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800af2:	bf 00 00 00 00       	mov    $0x0,%edi
  800af7:	eb d5                	jmp    800ace <strtol+0x2d>
		s++, neg = 1;
  800af9:	83 c1 01             	add    $0x1,%ecx
  800afc:	bf 01 00 00 00       	mov    $0x1,%edi
  800b01:	eb cb                	jmp    800ace <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b03:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b07:	74 0e                	je     800b17 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b09:	85 db                	test   %ebx,%ebx
  800b0b:	75 d8                	jne    800ae5 <strtol+0x44>
		s++, base = 8;
  800b0d:	83 c1 01             	add    $0x1,%ecx
  800b10:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b15:	eb ce                	jmp    800ae5 <strtol+0x44>
		s += 2, base = 16;
  800b17:	83 c1 02             	add    $0x2,%ecx
  800b1a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b1f:	eb c4                	jmp    800ae5 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b21:	0f be d2             	movsbl %dl,%edx
  800b24:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b27:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b2a:	7d 3a                	jge    800b66 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b2c:	83 c1 01             	add    $0x1,%ecx
  800b2f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b33:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b35:	0f b6 11             	movzbl (%ecx),%edx
  800b38:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b3b:	89 f3                	mov    %esi,%ebx
  800b3d:	80 fb 09             	cmp    $0x9,%bl
  800b40:	76 df                	jbe    800b21 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b42:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b45:	89 f3                	mov    %esi,%ebx
  800b47:	80 fb 19             	cmp    $0x19,%bl
  800b4a:	77 08                	ja     800b54 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b4c:	0f be d2             	movsbl %dl,%edx
  800b4f:	83 ea 57             	sub    $0x57,%edx
  800b52:	eb d3                	jmp    800b27 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b54:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b57:	89 f3                	mov    %esi,%ebx
  800b59:	80 fb 19             	cmp    $0x19,%bl
  800b5c:	77 08                	ja     800b66 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b5e:	0f be d2             	movsbl %dl,%edx
  800b61:	83 ea 37             	sub    $0x37,%edx
  800b64:	eb c1                	jmp    800b27 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6a:	74 05                	je     800b71 <strtol+0xd0>
		*endptr = (char *) s;
  800b6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b71:	89 c2                	mov    %eax,%edx
  800b73:	f7 da                	neg    %edx
  800b75:	85 ff                	test   %edi,%edi
  800b77:	0f 45 c2             	cmovne %edx,%eax
}
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b7f:	f3 0f 1e fb          	endbr32 
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b89:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b94:	89 c3                	mov    %eax,%ebx
  800b96:	89 c7                	mov    %eax,%edi
  800b98:	89 c6                	mov    %eax,%esi
  800b9a:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba1:	f3 0f 1e fb          	endbr32 
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bab:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb0:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb5:	89 d1                	mov    %edx,%ecx
  800bb7:	89 d3                	mov    %edx,%ebx
  800bb9:	89 d7                	mov    %edx,%edi
  800bbb:	89 d6                	mov    %edx,%esi
  800bbd:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc4:	f3 0f 1e fb          	endbr32 
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	57                   	push   %edi
  800bcc:	56                   	push   %esi
  800bcd:	53                   	push   %ebx
  800bce:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd9:	b8 03 00 00 00       	mov    $0x3,%eax
  800bde:	89 cb                	mov    %ecx,%ebx
  800be0:	89 cf                	mov    %ecx,%edi
  800be2:	89 ce                	mov    %ecx,%esi
  800be4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be6:	85 c0                	test   %eax,%eax
  800be8:	7f 08                	jg     800bf2 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf2:	83 ec 0c             	sub    $0xc,%esp
  800bf5:	50                   	push   %eax
  800bf6:	6a 03                	push   $0x3
  800bf8:	68 04 14 80 00       	push   $0x801404
  800bfd:	6a 23                	push   $0x23
  800bff:	68 21 14 80 00       	push   $0x801421
  800c04:	e8 14 f5 ff ff       	call   80011d <_panic>

00800c09 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c09:	f3 0f 1e fb          	endbr32 
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c13:	ba 00 00 00 00       	mov    $0x0,%edx
  800c18:	b8 02 00 00 00       	mov    $0x2,%eax
  800c1d:	89 d1                	mov    %edx,%ecx
  800c1f:	89 d3                	mov    %edx,%ebx
  800c21:	89 d7                	mov    %edx,%edi
  800c23:	89 d6                	mov    %edx,%esi
  800c25:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <sys_yield>:

void
sys_yield(void)
{
  800c2c:	f3 0f 1e fb          	endbr32 
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	57                   	push   %edi
  800c34:	56                   	push   %esi
  800c35:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c36:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c40:	89 d1                	mov    %edx,%ecx
  800c42:	89 d3                	mov    %edx,%ebx
  800c44:	89 d7                	mov    %edx,%edi
  800c46:	89 d6                	mov    %edx,%esi
  800c48:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c4f:	f3 0f 1e fb          	endbr32 
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5c:	be 00 00 00 00       	mov    $0x0,%esi
  800c61:	8b 55 08             	mov    0x8(%ebp),%edx
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c67:	b8 04 00 00 00       	mov    $0x4,%eax
  800c6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6f:	89 f7                	mov    %esi,%edi
  800c71:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c73:	85 c0                	test   %eax,%eax
  800c75:	7f 08                	jg     800c7f <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7f:	83 ec 0c             	sub    $0xc,%esp
  800c82:	50                   	push   %eax
  800c83:	6a 04                	push   $0x4
  800c85:	68 04 14 80 00       	push   $0x801404
  800c8a:	6a 23                	push   $0x23
  800c8c:	68 21 14 80 00       	push   $0x801421
  800c91:	e8 87 f4 ff ff       	call   80011d <_panic>

00800c96 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c96:	f3 0f 1e fb          	endbr32 
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ca3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	b8 05 00 00 00       	mov    $0x5,%eax
  800cae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb4:	8b 75 18             	mov    0x18(%ebp),%esi
  800cb7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	7f 08                	jg     800cc5 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc5:	83 ec 0c             	sub    $0xc,%esp
  800cc8:	50                   	push   %eax
  800cc9:	6a 05                	push   $0x5
  800ccb:	68 04 14 80 00       	push   $0x801404
  800cd0:	6a 23                	push   $0x23
  800cd2:	68 21 14 80 00       	push   $0x801421
  800cd7:	e8 41 f4 ff ff       	call   80011d <_panic>

00800cdc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cdc:	f3 0f 1e fb          	endbr32 
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cee:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf4:	b8 06 00 00 00       	mov    $0x6,%eax
  800cf9:	89 df                	mov    %ebx,%edi
  800cfb:	89 de                	mov    %ebx,%esi
  800cfd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cff:	85 c0                	test   %eax,%eax
  800d01:	7f 08                	jg     800d0b <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	50                   	push   %eax
  800d0f:	6a 06                	push   $0x6
  800d11:	68 04 14 80 00       	push   $0x801404
  800d16:	6a 23                	push   $0x23
  800d18:	68 21 14 80 00       	push   $0x801421
  800d1d:	e8 fb f3 ff ff       	call   80011d <_panic>

00800d22 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d22:	f3 0f 1e fb          	endbr32 
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3a:	b8 08 00 00 00       	mov    $0x8,%eax
  800d3f:	89 df                	mov    %ebx,%edi
  800d41:	89 de                	mov    %ebx,%esi
  800d43:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d45:	85 c0                	test   %eax,%eax
  800d47:	7f 08                	jg     800d51 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4c:	5b                   	pop    %ebx
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d51:	83 ec 0c             	sub    $0xc,%esp
  800d54:	50                   	push   %eax
  800d55:	6a 08                	push   $0x8
  800d57:	68 04 14 80 00       	push   $0x801404
  800d5c:	6a 23                	push   $0x23
  800d5e:	68 21 14 80 00       	push   $0x801421
  800d63:	e8 b5 f3 ff ff       	call   80011d <_panic>

00800d68 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d68:	f3 0f 1e fb          	endbr32 
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d80:	b8 09 00 00 00       	mov    $0x9,%eax
  800d85:	89 df                	mov    %ebx,%edi
  800d87:	89 de                	mov    %ebx,%esi
  800d89:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	7f 08                	jg     800d97 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d97:	83 ec 0c             	sub    $0xc,%esp
  800d9a:	50                   	push   %eax
  800d9b:	6a 09                	push   $0x9
  800d9d:	68 04 14 80 00       	push   $0x801404
  800da2:	6a 23                	push   $0x23
  800da4:	68 21 14 80 00       	push   $0x801421
  800da9:	e8 6f f3 ff ff       	call   80011d <_panic>

00800dae <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dae:	f3 0f 1e fb          	endbr32 
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbe:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dc3:	be 00 00 00 00       	mov    $0x0,%esi
  800dc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dcb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dce:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    

00800dd5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dd5:	f3 0f 1e fb          	endbr32 
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	57                   	push   %edi
  800ddd:	56                   	push   %esi
  800dde:	53                   	push   %ebx
  800ddf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800de2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dea:	b8 0c 00 00 00       	mov    $0xc,%eax
  800def:	89 cb                	mov    %ecx,%ebx
  800df1:	89 cf                	mov    %ecx,%edi
  800df3:	89 ce                	mov    %ecx,%esi
  800df5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800df7:	85 c0                	test   %eax,%eax
  800df9:	7f 08                	jg     800e03 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e03:	83 ec 0c             	sub    $0xc,%esp
  800e06:	50                   	push   %eax
  800e07:	6a 0c                	push   $0xc
  800e09:	68 04 14 80 00       	push   $0x801404
  800e0e:	6a 23                	push   $0x23
  800e10:	68 21 14 80 00       	push   $0x801421
  800e15:	e8 03 f3 ff ff       	call   80011d <_panic>

00800e1a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e1a:	f3 0f 1e fb          	endbr32 
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e24:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e2b:	74 0a                	je     800e37 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e30:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800e35:	c9                   	leave  
  800e36:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  800e37:	83 ec 0c             	sub    $0xc,%esp
  800e3a:	68 2f 14 80 00       	push   $0x80142f
  800e3f:	e8 c0 f3 ff ff       	call   800204 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  800e44:	83 c4 0c             	add    $0xc,%esp
  800e47:	6a 07                	push   $0x7
  800e49:	68 00 f0 bf ee       	push   $0xeebff000
  800e4e:	6a 00                	push   $0x0
  800e50:	e8 fa fd ff ff       	call   800c4f <sys_page_alloc>
  800e55:	83 c4 10             	add    $0x10,%esp
  800e58:	85 c0                	test   %eax,%eax
  800e5a:	78 2a                	js     800e86 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  800e5c:	83 ec 08             	sub    $0x8,%esp
  800e5f:	68 9a 0e 80 00       	push   $0x800e9a
  800e64:	6a 00                	push   $0x0
  800e66:	e8 fd fe ff ff       	call   800d68 <sys_env_set_pgfault_upcall>
  800e6b:	83 c4 10             	add    $0x10,%esp
  800e6e:	85 c0                	test   %eax,%eax
  800e70:	79 bb                	jns    800e2d <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  800e72:	83 ec 04             	sub    $0x4,%esp
  800e75:	68 6c 14 80 00       	push   $0x80146c
  800e7a:	6a 25                	push   $0x25
  800e7c:	68 5c 14 80 00       	push   $0x80145c
  800e81:	e8 97 f2 ff ff       	call   80011d <_panic>
            panic("Allocation of UXSTACK failed!");
  800e86:	83 ec 04             	sub    $0x4,%esp
  800e89:	68 3e 14 80 00       	push   $0x80143e
  800e8e:	6a 22                	push   $0x22
  800e90:	68 5c 14 80 00       	push   $0x80145c
  800e95:	e8 83 f2 ff ff       	call   80011d <_panic>

00800e9a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e9a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e9b:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800ea0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800ea2:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  800ea5:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  800ea9:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  800ead:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  800eb0:	83 c4 08             	add    $0x8,%esp
    popa
  800eb3:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $0x4, %esp
  800eb4:	83 c4 04             	add    $0x4,%esp
    popf
  800eb7:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  800eb8:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  800ebb:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  800ebf:	c3                   	ret    

00800ec0 <__udivdi3>:
  800ec0:	f3 0f 1e fb          	endbr32 
  800ec4:	55                   	push   %ebp
  800ec5:	57                   	push   %edi
  800ec6:	56                   	push   %esi
  800ec7:	53                   	push   %ebx
  800ec8:	83 ec 1c             	sub    $0x1c,%esp
  800ecb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800ecf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800ed3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ed7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800edb:	85 d2                	test   %edx,%edx
  800edd:	75 19                	jne    800ef8 <__udivdi3+0x38>
  800edf:	39 f3                	cmp    %esi,%ebx
  800ee1:	76 4d                	jbe    800f30 <__udivdi3+0x70>
  800ee3:	31 ff                	xor    %edi,%edi
  800ee5:	89 e8                	mov    %ebp,%eax
  800ee7:	89 f2                	mov    %esi,%edx
  800ee9:	f7 f3                	div    %ebx
  800eeb:	89 fa                	mov    %edi,%edx
  800eed:	83 c4 1c             	add    $0x1c,%esp
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    
  800ef5:	8d 76 00             	lea    0x0(%esi),%esi
  800ef8:	39 f2                	cmp    %esi,%edx
  800efa:	76 14                	jbe    800f10 <__udivdi3+0x50>
  800efc:	31 ff                	xor    %edi,%edi
  800efe:	31 c0                	xor    %eax,%eax
  800f00:	89 fa                	mov    %edi,%edx
  800f02:	83 c4 1c             	add    $0x1c,%esp
  800f05:	5b                   	pop    %ebx
  800f06:	5e                   	pop    %esi
  800f07:	5f                   	pop    %edi
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    
  800f0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f10:	0f bd fa             	bsr    %edx,%edi
  800f13:	83 f7 1f             	xor    $0x1f,%edi
  800f16:	75 48                	jne    800f60 <__udivdi3+0xa0>
  800f18:	39 f2                	cmp    %esi,%edx
  800f1a:	72 06                	jb     800f22 <__udivdi3+0x62>
  800f1c:	31 c0                	xor    %eax,%eax
  800f1e:	39 eb                	cmp    %ebp,%ebx
  800f20:	77 de                	ja     800f00 <__udivdi3+0x40>
  800f22:	b8 01 00 00 00       	mov    $0x1,%eax
  800f27:	eb d7                	jmp    800f00 <__udivdi3+0x40>
  800f29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f30:	89 d9                	mov    %ebx,%ecx
  800f32:	85 db                	test   %ebx,%ebx
  800f34:	75 0b                	jne    800f41 <__udivdi3+0x81>
  800f36:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3b:	31 d2                	xor    %edx,%edx
  800f3d:	f7 f3                	div    %ebx
  800f3f:	89 c1                	mov    %eax,%ecx
  800f41:	31 d2                	xor    %edx,%edx
  800f43:	89 f0                	mov    %esi,%eax
  800f45:	f7 f1                	div    %ecx
  800f47:	89 c6                	mov    %eax,%esi
  800f49:	89 e8                	mov    %ebp,%eax
  800f4b:	89 f7                	mov    %esi,%edi
  800f4d:	f7 f1                	div    %ecx
  800f4f:	89 fa                	mov    %edi,%edx
  800f51:	83 c4 1c             	add    $0x1c,%esp
  800f54:	5b                   	pop    %ebx
  800f55:	5e                   	pop    %esi
  800f56:	5f                   	pop    %edi
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    
  800f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f60:	89 f9                	mov    %edi,%ecx
  800f62:	b8 20 00 00 00       	mov    $0x20,%eax
  800f67:	29 f8                	sub    %edi,%eax
  800f69:	d3 e2                	shl    %cl,%edx
  800f6b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f6f:	89 c1                	mov    %eax,%ecx
  800f71:	89 da                	mov    %ebx,%edx
  800f73:	d3 ea                	shr    %cl,%edx
  800f75:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f79:	09 d1                	or     %edx,%ecx
  800f7b:	89 f2                	mov    %esi,%edx
  800f7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f81:	89 f9                	mov    %edi,%ecx
  800f83:	d3 e3                	shl    %cl,%ebx
  800f85:	89 c1                	mov    %eax,%ecx
  800f87:	d3 ea                	shr    %cl,%edx
  800f89:	89 f9                	mov    %edi,%ecx
  800f8b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f8f:	89 eb                	mov    %ebp,%ebx
  800f91:	d3 e6                	shl    %cl,%esi
  800f93:	89 c1                	mov    %eax,%ecx
  800f95:	d3 eb                	shr    %cl,%ebx
  800f97:	09 de                	or     %ebx,%esi
  800f99:	89 f0                	mov    %esi,%eax
  800f9b:	f7 74 24 08          	divl   0x8(%esp)
  800f9f:	89 d6                	mov    %edx,%esi
  800fa1:	89 c3                	mov    %eax,%ebx
  800fa3:	f7 64 24 0c          	mull   0xc(%esp)
  800fa7:	39 d6                	cmp    %edx,%esi
  800fa9:	72 15                	jb     800fc0 <__udivdi3+0x100>
  800fab:	89 f9                	mov    %edi,%ecx
  800fad:	d3 e5                	shl    %cl,%ebp
  800faf:	39 c5                	cmp    %eax,%ebp
  800fb1:	73 04                	jae    800fb7 <__udivdi3+0xf7>
  800fb3:	39 d6                	cmp    %edx,%esi
  800fb5:	74 09                	je     800fc0 <__udivdi3+0x100>
  800fb7:	89 d8                	mov    %ebx,%eax
  800fb9:	31 ff                	xor    %edi,%edi
  800fbb:	e9 40 ff ff ff       	jmp    800f00 <__udivdi3+0x40>
  800fc0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800fc3:	31 ff                	xor    %edi,%edi
  800fc5:	e9 36 ff ff ff       	jmp    800f00 <__udivdi3+0x40>
  800fca:	66 90                	xchg   %ax,%ax
  800fcc:	66 90                	xchg   %ax,%ax
  800fce:	66 90                	xchg   %ax,%ax

00800fd0 <__umoddi3>:
  800fd0:	f3 0f 1e fb          	endbr32 
  800fd4:	55                   	push   %ebp
  800fd5:	57                   	push   %edi
  800fd6:	56                   	push   %esi
  800fd7:	53                   	push   %ebx
  800fd8:	83 ec 1c             	sub    $0x1c,%esp
  800fdb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800fdf:	8b 74 24 30          	mov    0x30(%esp),%esi
  800fe3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800fe7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800feb:	85 c0                	test   %eax,%eax
  800fed:	75 19                	jne    801008 <__umoddi3+0x38>
  800fef:	39 df                	cmp    %ebx,%edi
  800ff1:	76 5d                	jbe    801050 <__umoddi3+0x80>
  800ff3:	89 f0                	mov    %esi,%eax
  800ff5:	89 da                	mov    %ebx,%edx
  800ff7:	f7 f7                	div    %edi
  800ff9:	89 d0                	mov    %edx,%eax
  800ffb:	31 d2                	xor    %edx,%edx
  800ffd:	83 c4 1c             	add    $0x1c,%esp
  801000:	5b                   	pop    %ebx
  801001:	5e                   	pop    %esi
  801002:	5f                   	pop    %edi
  801003:	5d                   	pop    %ebp
  801004:	c3                   	ret    
  801005:	8d 76 00             	lea    0x0(%esi),%esi
  801008:	89 f2                	mov    %esi,%edx
  80100a:	39 d8                	cmp    %ebx,%eax
  80100c:	76 12                	jbe    801020 <__umoddi3+0x50>
  80100e:	89 f0                	mov    %esi,%eax
  801010:	89 da                	mov    %ebx,%edx
  801012:	83 c4 1c             	add    $0x1c,%esp
  801015:	5b                   	pop    %ebx
  801016:	5e                   	pop    %esi
  801017:	5f                   	pop    %edi
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    
  80101a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801020:	0f bd e8             	bsr    %eax,%ebp
  801023:	83 f5 1f             	xor    $0x1f,%ebp
  801026:	75 50                	jne    801078 <__umoddi3+0xa8>
  801028:	39 d8                	cmp    %ebx,%eax
  80102a:	0f 82 e0 00 00 00    	jb     801110 <__umoddi3+0x140>
  801030:	89 d9                	mov    %ebx,%ecx
  801032:	39 f7                	cmp    %esi,%edi
  801034:	0f 86 d6 00 00 00    	jbe    801110 <__umoddi3+0x140>
  80103a:	89 d0                	mov    %edx,%eax
  80103c:	89 ca                	mov    %ecx,%edx
  80103e:	83 c4 1c             	add    $0x1c,%esp
  801041:	5b                   	pop    %ebx
  801042:	5e                   	pop    %esi
  801043:	5f                   	pop    %edi
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    
  801046:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80104d:	8d 76 00             	lea    0x0(%esi),%esi
  801050:	89 fd                	mov    %edi,%ebp
  801052:	85 ff                	test   %edi,%edi
  801054:	75 0b                	jne    801061 <__umoddi3+0x91>
  801056:	b8 01 00 00 00       	mov    $0x1,%eax
  80105b:	31 d2                	xor    %edx,%edx
  80105d:	f7 f7                	div    %edi
  80105f:	89 c5                	mov    %eax,%ebp
  801061:	89 d8                	mov    %ebx,%eax
  801063:	31 d2                	xor    %edx,%edx
  801065:	f7 f5                	div    %ebp
  801067:	89 f0                	mov    %esi,%eax
  801069:	f7 f5                	div    %ebp
  80106b:	89 d0                	mov    %edx,%eax
  80106d:	31 d2                	xor    %edx,%edx
  80106f:	eb 8c                	jmp    800ffd <__umoddi3+0x2d>
  801071:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801078:	89 e9                	mov    %ebp,%ecx
  80107a:	ba 20 00 00 00       	mov    $0x20,%edx
  80107f:	29 ea                	sub    %ebp,%edx
  801081:	d3 e0                	shl    %cl,%eax
  801083:	89 44 24 08          	mov    %eax,0x8(%esp)
  801087:	89 d1                	mov    %edx,%ecx
  801089:	89 f8                	mov    %edi,%eax
  80108b:	d3 e8                	shr    %cl,%eax
  80108d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801091:	89 54 24 04          	mov    %edx,0x4(%esp)
  801095:	8b 54 24 04          	mov    0x4(%esp),%edx
  801099:	09 c1                	or     %eax,%ecx
  80109b:	89 d8                	mov    %ebx,%eax
  80109d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010a1:	89 e9                	mov    %ebp,%ecx
  8010a3:	d3 e7                	shl    %cl,%edi
  8010a5:	89 d1                	mov    %edx,%ecx
  8010a7:	d3 e8                	shr    %cl,%eax
  8010a9:	89 e9                	mov    %ebp,%ecx
  8010ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010af:	d3 e3                	shl    %cl,%ebx
  8010b1:	89 c7                	mov    %eax,%edi
  8010b3:	89 d1                	mov    %edx,%ecx
  8010b5:	89 f0                	mov    %esi,%eax
  8010b7:	d3 e8                	shr    %cl,%eax
  8010b9:	89 e9                	mov    %ebp,%ecx
  8010bb:	89 fa                	mov    %edi,%edx
  8010bd:	d3 e6                	shl    %cl,%esi
  8010bf:	09 d8                	or     %ebx,%eax
  8010c1:	f7 74 24 08          	divl   0x8(%esp)
  8010c5:	89 d1                	mov    %edx,%ecx
  8010c7:	89 f3                	mov    %esi,%ebx
  8010c9:	f7 64 24 0c          	mull   0xc(%esp)
  8010cd:	89 c6                	mov    %eax,%esi
  8010cf:	89 d7                	mov    %edx,%edi
  8010d1:	39 d1                	cmp    %edx,%ecx
  8010d3:	72 06                	jb     8010db <__umoddi3+0x10b>
  8010d5:	75 10                	jne    8010e7 <__umoddi3+0x117>
  8010d7:	39 c3                	cmp    %eax,%ebx
  8010d9:	73 0c                	jae    8010e7 <__umoddi3+0x117>
  8010db:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8010df:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8010e3:	89 d7                	mov    %edx,%edi
  8010e5:	89 c6                	mov    %eax,%esi
  8010e7:	89 ca                	mov    %ecx,%edx
  8010e9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010ee:	29 f3                	sub    %esi,%ebx
  8010f0:	19 fa                	sbb    %edi,%edx
  8010f2:	89 d0                	mov    %edx,%eax
  8010f4:	d3 e0                	shl    %cl,%eax
  8010f6:	89 e9                	mov    %ebp,%ecx
  8010f8:	d3 eb                	shr    %cl,%ebx
  8010fa:	d3 ea                	shr    %cl,%edx
  8010fc:	09 d8                	or     %ebx,%eax
  8010fe:	83 c4 1c             	add    $0x1c,%esp
  801101:	5b                   	pop    %ebx
  801102:	5e                   	pop    %esi
  801103:	5f                   	pop    %edi
  801104:	5d                   	pop    %ebp
  801105:	c3                   	ret    
  801106:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80110d:	8d 76 00             	lea    0x0(%esi),%esi
  801110:	29 fe                	sub    %edi,%esi
  801112:	19 c3                	sbb    %eax,%ebx
  801114:	89 f2                	mov    %esi,%edx
  801116:	89 d9                	mov    %ebx,%ecx
  801118:	e9 1d ff ff ff       	jmp    80103a <__umoddi3+0x6a>
