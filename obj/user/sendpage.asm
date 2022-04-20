
obj/user/sendpage:     file format elf32-i386


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
  80002c:	e8 90 01 00 00       	call   8001c1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  80003d:	e8 67 0f 00 00       	call   800fa9 <fork>
  800042:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	0f 84 b1 00 00 00    	je     8000fe <umain+0xcb>
        cprintf("child sent\n");
		return;
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80004d:	a1 0c 20 80 00       	mov    0x80200c,%eax
  800052:	8b 40 48             	mov    0x48(%eax),%eax
  800055:	83 ec 04             	sub    $0x4,%esp
  800058:	6a 07                	push   $0x7
  80005a:	68 00 00 a0 00       	push   $0xa00000
  80005f:	50                   	push   %eax
  800060:	e8 a4 0c 00 00       	call   800d09 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800065:	83 c4 04             	add    $0x4,%esp
  800068:	ff 35 04 20 80 00    	pushl  0x802004
  80006e:	e8 11 08 00 00       	call   800884 <strlen>
  800073:	83 c4 0c             	add    $0xc,%esp
  800076:	83 c0 01             	add    $0x1,%eax
  800079:	50                   	push   %eax
  80007a:	ff 35 04 20 80 00    	pushl  0x802004
  800080:	68 00 00 a0 00       	push   $0xa00000
  800085:	e8 59 0a 00 00       	call   800ae3 <memcpy>
    cprintf("parent sent\n");
  80008a:	c7 04 24 80 15 80 00 	movl   $0x801580,(%esp)
  800091:	e8 28 02 00 00       	call   8002be <cprintf>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800096:	6a 07                	push   $0x7
  800098:	68 00 00 a0 00       	push   $0xa00000
  80009d:	6a 00                	push   $0x0
  80009f:	ff 75 f4             	pushl  -0xc(%ebp)
  8000a2:	e8 c5 10 00 00       	call   80116c <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  8000a7:	83 c4 1c             	add    $0x1c,%esp
  8000aa:	6a 00                	push   $0x0
  8000ac:	68 00 00 a0 00       	push   $0xa00000
  8000b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b4:	50                   	push   %eax
  8000b5:	e8 5b 10 00 00       	call   801115 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	68 00 00 a0 00       	push   $0xa00000
  8000c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8000c5:	68 60 15 80 00       	push   $0x801560
  8000ca:	e8 ef 01 00 00       	call   8002be <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8000cf:	83 c4 04             	add    $0x4,%esp
  8000d2:	ff 35 00 20 80 00    	pushl  0x802000
  8000d8:	e8 a7 07 00 00       	call   800884 <strlen>
  8000dd:	83 c4 0c             	add    $0xc,%esp
  8000e0:	50                   	push   %eax
  8000e1:	ff 35 00 20 80 00    	pushl  0x802000
  8000e7:	68 00 00 a0 00       	push   $0xa00000
  8000ec:	e8 bf 08 00 00       	call   8009b0 <strncmp>
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	0f 84 b0 00 00 00    	je     8001ac <umain+0x179>
		cprintf("parent received correct message\n");
	return;
}
  8000fc:	c9                   	leave  
  8000fd:	c3                   	ret    
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  8000fe:	83 ec 04             	sub    $0x4,%esp
  800101:	6a 00                	push   $0x0
  800103:	68 00 00 b0 00       	push   $0xb00000
  800108:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80010b:	50                   	push   %eax
  80010c:	e8 04 10 00 00       	call   801115 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800111:	83 c4 0c             	add    $0xc,%esp
  800114:	68 00 00 b0 00       	push   $0xb00000
  800119:	ff 75 f4             	pushl  -0xc(%ebp)
  80011c:	68 60 15 80 00       	push   $0x801560
  800121:	e8 98 01 00 00       	call   8002be <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800126:	83 c4 04             	add    $0x4,%esp
  800129:	ff 35 04 20 80 00    	pushl  0x802004
  80012f:	e8 50 07 00 00       	call   800884 <strlen>
  800134:	83 c4 0c             	add    $0xc,%esp
  800137:	50                   	push   %eax
  800138:	ff 35 04 20 80 00    	pushl  0x802004
  80013e:	68 00 00 b0 00       	push   $0xb00000
  800143:	e8 68 08 00 00       	call   8009b0 <strncmp>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	85 c0                	test   %eax,%eax
  80014d:	74 4b                	je     80019a <umain+0x167>
		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	ff 35 00 20 80 00    	pushl  0x802000
  800158:	e8 27 07 00 00       	call   800884 <strlen>
  80015d:	83 c4 0c             	add    $0xc,%esp
  800160:	83 c0 01             	add    $0x1,%eax
  800163:	50                   	push   %eax
  800164:	ff 35 00 20 80 00    	pushl  0x802000
  80016a:	68 00 00 b0 00       	push   $0xb00000
  80016f:	e8 6f 09 00 00       	call   800ae3 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  800174:	6a 07                	push   $0x7
  800176:	68 00 00 b0 00       	push   $0xb00000
  80017b:	6a 00                	push   $0x0
  80017d:	ff 75 f4             	pushl  -0xc(%ebp)
  800180:	e8 e7 0f 00 00       	call   80116c <ipc_send>
        cprintf("child sent\n");
  800185:	83 c4 14             	add    $0x14,%esp
  800188:	68 74 15 80 00       	push   $0x801574
  80018d:	e8 2c 01 00 00       	call   8002be <cprintf>
		return;
  800192:	83 c4 10             	add    $0x10,%esp
  800195:	e9 62 ff ff ff       	jmp    8000fc <umain+0xc9>
			cprintf("child received correct message\n");
  80019a:	83 ec 0c             	sub    $0xc,%esp
  80019d:	68 90 15 80 00       	push   $0x801590
  8001a2:	e8 17 01 00 00       	call   8002be <cprintf>
  8001a7:	83 c4 10             	add    $0x10,%esp
  8001aa:	eb a3                	jmp    80014f <umain+0x11c>
		cprintf("parent received correct message\n");
  8001ac:	83 ec 0c             	sub    $0xc,%esp
  8001af:	68 b0 15 80 00       	push   $0x8015b0
  8001b4:	e8 05 01 00 00       	call   8002be <cprintf>
  8001b9:	83 c4 10             	add    $0x10,%esp
  8001bc:	e9 3b ff ff ff       	jmp    8000fc <umain+0xc9>

008001c1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001c1:	f3 0f 1e fb          	endbr32 
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001cd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    envid_t envid = sys_getenvid();
  8001d0:	e8 ee 0a 00 00       	call   800cc3 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8001d5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001da:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001dd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e2:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001e7:	85 db                	test   %ebx,%ebx
  8001e9:	7e 07                	jle    8001f2 <libmain+0x31>
		binaryname = argv[0];
  8001eb:	8b 06                	mov    (%esi),%eax
  8001ed:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  8001f2:	83 ec 08             	sub    $0x8,%esp
  8001f5:	56                   	push   %esi
  8001f6:	53                   	push   %ebx
  8001f7:	e8 37 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001fc:	e8 0a 00 00 00       	call   80020b <exit>
}
  800201:	83 c4 10             	add    $0x10,%esp
  800204:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800207:	5b                   	pop    %ebx
  800208:	5e                   	pop    %esi
  800209:	5d                   	pop    %ebp
  80020a:	c3                   	ret    

0080020b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80020b:	f3 0f 1e fb          	endbr32 
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800215:	6a 00                	push   $0x0
  800217:	e8 62 0a 00 00       	call   800c7e <sys_env_destroy>
}
  80021c:	83 c4 10             	add    $0x10,%esp
  80021f:	c9                   	leave  
  800220:	c3                   	ret    

00800221 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800221:	f3 0f 1e fb          	endbr32 
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	53                   	push   %ebx
  800229:	83 ec 04             	sub    $0x4,%esp
  80022c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80022f:	8b 13                	mov    (%ebx),%edx
  800231:	8d 42 01             	lea    0x1(%edx),%eax
  800234:	89 03                	mov    %eax,(%ebx)
  800236:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800239:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80023d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800242:	74 09                	je     80024d <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800244:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800248:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80024b:	c9                   	leave  
  80024c:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80024d:	83 ec 08             	sub    $0x8,%esp
  800250:	68 ff 00 00 00       	push   $0xff
  800255:	8d 43 08             	lea    0x8(%ebx),%eax
  800258:	50                   	push   %eax
  800259:	e8 db 09 00 00       	call   800c39 <sys_cputs>
		b->idx = 0;
  80025e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800264:	83 c4 10             	add    $0x10,%esp
  800267:	eb db                	jmp    800244 <putch+0x23>

00800269 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800269:	f3 0f 1e fb          	endbr32 
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800276:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027d:	00 00 00 
	b.cnt = 0;
  800280:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800287:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80028a:	ff 75 0c             	pushl  0xc(%ebp)
  80028d:	ff 75 08             	pushl  0x8(%ebp)
  800290:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800296:	50                   	push   %eax
  800297:	68 21 02 80 00       	push   $0x800221
  80029c:	e8 20 01 00 00       	call   8003c1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a1:	83 c4 08             	add    $0x8,%esp
  8002a4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b0:	50                   	push   %eax
  8002b1:	e8 83 09 00 00       	call   800c39 <sys_cputs>

	return b.cnt;
}
  8002b6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002be:	f3 0f 1e fb          	endbr32 
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002cb:	50                   	push   %eax
  8002cc:	ff 75 08             	pushl  0x8(%ebp)
  8002cf:	e8 95 ff ff ff       	call   800269 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d4:	c9                   	leave  
  8002d5:	c3                   	ret    

008002d6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 1c             	sub    $0x1c,%esp
  8002df:	89 c7                	mov    %eax,%edi
  8002e1:	89 d6                	mov    %edx,%esi
  8002e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e9:	89 d1                	mov    %edx,%ecx
  8002eb:	89 c2                	mov    %eax,%edx
  8002ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002fc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800303:	39 c2                	cmp    %eax,%edx
  800305:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800308:	72 3e                	jb     800348 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	ff 75 18             	pushl  0x18(%ebp)
  800310:	83 eb 01             	sub    $0x1,%ebx
  800313:	53                   	push   %ebx
  800314:	50                   	push   %eax
  800315:	83 ec 08             	sub    $0x8,%esp
  800318:	ff 75 e4             	pushl  -0x1c(%ebp)
  80031b:	ff 75 e0             	pushl  -0x20(%ebp)
  80031e:	ff 75 dc             	pushl  -0x24(%ebp)
  800321:	ff 75 d8             	pushl  -0x28(%ebp)
  800324:	e8 d7 0f 00 00       	call   801300 <__udivdi3>
  800329:	83 c4 18             	add    $0x18,%esp
  80032c:	52                   	push   %edx
  80032d:	50                   	push   %eax
  80032e:	89 f2                	mov    %esi,%edx
  800330:	89 f8                	mov    %edi,%eax
  800332:	e8 9f ff ff ff       	call   8002d6 <printnum>
  800337:	83 c4 20             	add    $0x20,%esp
  80033a:	eb 13                	jmp    80034f <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80033c:	83 ec 08             	sub    $0x8,%esp
  80033f:	56                   	push   %esi
  800340:	ff 75 18             	pushl  0x18(%ebp)
  800343:	ff d7                	call   *%edi
  800345:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800348:	83 eb 01             	sub    $0x1,%ebx
  80034b:	85 db                	test   %ebx,%ebx
  80034d:	7f ed                	jg     80033c <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80034f:	83 ec 08             	sub    $0x8,%esp
  800352:	56                   	push   %esi
  800353:	83 ec 04             	sub    $0x4,%esp
  800356:	ff 75 e4             	pushl  -0x1c(%ebp)
  800359:	ff 75 e0             	pushl  -0x20(%ebp)
  80035c:	ff 75 dc             	pushl  -0x24(%ebp)
  80035f:	ff 75 d8             	pushl  -0x28(%ebp)
  800362:	e8 a9 10 00 00       	call   801410 <__umoddi3>
  800367:	83 c4 14             	add    $0x14,%esp
  80036a:	0f be 80 28 16 80 00 	movsbl 0x801628(%eax),%eax
  800371:	50                   	push   %eax
  800372:	ff d7                	call   *%edi
}
  800374:	83 c4 10             	add    $0x10,%esp
  800377:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80037a:	5b                   	pop    %ebx
  80037b:	5e                   	pop    %esi
  80037c:	5f                   	pop    %edi
  80037d:	5d                   	pop    %ebp
  80037e:	c3                   	ret    

0080037f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80037f:	f3 0f 1e fb          	endbr32 
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800389:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	3b 50 04             	cmp    0x4(%eax),%edx
  800392:	73 0a                	jae    80039e <sprintputch+0x1f>
		*b->buf++ = ch;
  800394:	8d 4a 01             	lea    0x1(%edx),%ecx
  800397:	89 08                	mov    %ecx,(%eax)
  800399:	8b 45 08             	mov    0x8(%ebp),%eax
  80039c:	88 02                	mov    %al,(%edx)
}
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <printfmt>:
{
  8003a0:	f3 0f 1e fb          	endbr32 
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003aa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003ad:	50                   	push   %eax
  8003ae:	ff 75 10             	pushl  0x10(%ebp)
  8003b1:	ff 75 0c             	pushl  0xc(%ebp)
  8003b4:	ff 75 08             	pushl  0x8(%ebp)
  8003b7:	e8 05 00 00 00       	call   8003c1 <vprintfmt>
}
  8003bc:	83 c4 10             	add    $0x10,%esp
  8003bf:	c9                   	leave  
  8003c0:	c3                   	ret    

008003c1 <vprintfmt>:
{
  8003c1:	f3 0f 1e fb          	endbr32 
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	57                   	push   %edi
  8003c9:	56                   	push   %esi
  8003ca:	53                   	push   %ebx
  8003cb:	83 ec 3c             	sub    $0x3c,%esp
  8003ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8003d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003d7:	e9 4a 03 00 00       	jmp    800726 <vprintfmt+0x365>
		padc = ' ';
  8003dc:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003e0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003e7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003ee:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003f5:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8d 47 01             	lea    0x1(%edi),%eax
  8003fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800400:	0f b6 17             	movzbl (%edi),%edx
  800403:	8d 42 dd             	lea    -0x23(%edx),%eax
  800406:	3c 55                	cmp    $0x55,%al
  800408:	0f 87 de 03 00 00    	ja     8007ec <vprintfmt+0x42b>
  80040e:	0f b6 c0             	movzbl %al,%eax
  800411:	3e ff 24 85 e0 16 80 	notrack jmp *0x8016e0(,%eax,4)
  800418:	00 
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80041c:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800420:	eb d8                	jmp    8003fa <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800425:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800429:	eb cf                	jmp    8003fa <vprintfmt+0x39>
  80042b:	0f b6 d2             	movzbl %dl,%edx
  80042e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800431:	b8 00 00 00 00       	mov    $0x0,%eax
  800436:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800439:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80043c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800440:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800443:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800446:	83 f9 09             	cmp    $0x9,%ecx
  800449:	77 55                	ja     8004a0 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80044b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80044e:	eb e9                	jmp    800439 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8b 00                	mov    (%eax),%eax
  800455:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800458:	8b 45 14             	mov    0x14(%ebp),%eax
  80045b:	8d 40 04             	lea    0x4(%eax),%eax
  80045e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800461:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800464:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800468:	79 90                	jns    8003fa <vprintfmt+0x39>
				width = precision, precision = -1;
  80046a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80046d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800470:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800477:	eb 81                	jmp    8003fa <vprintfmt+0x39>
  800479:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80047c:	85 c0                	test   %eax,%eax
  80047e:	ba 00 00 00 00       	mov    $0x0,%edx
  800483:	0f 49 d0             	cmovns %eax,%edx
  800486:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80048c:	e9 69 ff ff ff       	jmp    8003fa <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800494:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80049b:	e9 5a ff ff ff       	jmp    8003fa <vprintfmt+0x39>
  8004a0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004a6:	eb bc                	jmp    800464 <vprintfmt+0xa3>
			lflag++;
  8004a8:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004ae:	e9 47 ff ff ff       	jmp    8003fa <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8004b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b6:	8d 78 04             	lea    0x4(%eax),%edi
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	53                   	push   %ebx
  8004bd:	ff 30                	pushl  (%eax)
  8004bf:	ff d6                	call   *%esi
			break;
  8004c1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004c4:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004c7:	e9 57 02 00 00       	jmp    800723 <vprintfmt+0x362>
			err = va_arg(ap, int);
  8004cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cf:	8d 78 04             	lea    0x4(%eax),%edi
  8004d2:	8b 00                	mov    (%eax),%eax
  8004d4:	99                   	cltd   
  8004d5:	31 d0                	xor    %edx,%eax
  8004d7:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d9:	83 f8 08             	cmp    $0x8,%eax
  8004dc:	7f 23                	jg     800501 <vprintfmt+0x140>
  8004de:	8b 14 85 40 18 80 00 	mov    0x801840(,%eax,4),%edx
  8004e5:	85 d2                	test   %edx,%edx
  8004e7:	74 18                	je     800501 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8004e9:	52                   	push   %edx
  8004ea:	68 49 16 80 00       	push   $0x801649
  8004ef:	53                   	push   %ebx
  8004f0:	56                   	push   %esi
  8004f1:	e8 aa fe ff ff       	call   8003a0 <printfmt>
  8004f6:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004f9:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004fc:	e9 22 02 00 00       	jmp    800723 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800501:	50                   	push   %eax
  800502:	68 40 16 80 00       	push   $0x801640
  800507:	53                   	push   %ebx
  800508:	56                   	push   %esi
  800509:	e8 92 fe ff ff       	call   8003a0 <printfmt>
  80050e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800511:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800514:	e9 0a 02 00 00       	jmp    800723 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
  80051c:	83 c0 04             	add    $0x4,%eax
  80051f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800527:	85 d2                	test   %edx,%edx
  800529:	b8 39 16 80 00       	mov    $0x801639,%eax
  80052e:	0f 45 c2             	cmovne %edx,%eax
  800531:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800534:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800538:	7e 06                	jle    800540 <vprintfmt+0x17f>
  80053a:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80053e:	75 0d                	jne    80054d <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800540:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800543:	89 c7                	mov    %eax,%edi
  800545:	03 45 e0             	add    -0x20(%ebp),%eax
  800548:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80054b:	eb 55                	jmp    8005a2 <vprintfmt+0x1e1>
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	ff 75 d8             	pushl  -0x28(%ebp)
  800553:	ff 75 cc             	pushl  -0x34(%ebp)
  800556:	e8 45 03 00 00       	call   8008a0 <strnlen>
  80055b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80055e:	29 c2                	sub    %eax,%edx
  800560:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800563:	83 c4 10             	add    $0x10,%esp
  800566:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800568:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80056c:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80056f:	85 ff                	test   %edi,%edi
  800571:	7e 11                	jle    800584 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800573:	83 ec 08             	sub    $0x8,%esp
  800576:	53                   	push   %ebx
  800577:	ff 75 e0             	pushl  -0x20(%ebp)
  80057a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80057c:	83 ef 01             	sub    $0x1,%edi
  80057f:	83 c4 10             	add    $0x10,%esp
  800582:	eb eb                	jmp    80056f <vprintfmt+0x1ae>
  800584:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800587:	85 d2                	test   %edx,%edx
  800589:	b8 00 00 00 00       	mov    $0x0,%eax
  80058e:	0f 49 c2             	cmovns %edx,%eax
  800591:	29 c2                	sub    %eax,%edx
  800593:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800596:	eb a8                	jmp    800540 <vprintfmt+0x17f>
					putch(ch, putdat);
  800598:	83 ec 08             	sub    $0x8,%esp
  80059b:	53                   	push   %ebx
  80059c:	52                   	push   %edx
  80059d:	ff d6                	call   *%esi
  80059f:	83 c4 10             	add    $0x10,%esp
  8005a2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005a5:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a7:	83 c7 01             	add    $0x1,%edi
  8005aa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ae:	0f be d0             	movsbl %al,%edx
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	74 4b                	je     800600 <vprintfmt+0x23f>
  8005b5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b9:	78 06                	js     8005c1 <vprintfmt+0x200>
  8005bb:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005bf:	78 1e                	js     8005df <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8005c1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005c5:	74 d1                	je     800598 <vprintfmt+0x1d7>
  8005c7:	0f be c0             	movsbl %al,%eax
  8005ca:	83 e8 20             	sub    $0x20,%eax
  8005cd:	83 f8 5e             	cmp    $0x5e,%eax
  8005d0:	76 c6                	jbe    800598 <vprintfmt+0x1d7>
					putch('?', putdat);
  8005d2:	83 ec 08             	sub    $0x8,%esp
  8005d5:	53                   	push   %ebx
  8005d6:	6a 3f                	push   $0x3f
  8005d8:	ff d6                	call   *%esi
  8005da:	83 c4 10             	add    $0x10,%esp
  8005dd:	eb c3                	jmp    8005a2 <vprintfmt+0x1e1>
  8005df:	89 cf                	mov    %ecx,%edi
  8005e1:	eb 0e                	jmp    8005f1 <vprintfmt+0x230>
				putch(' ', putdat);
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	53                   	push   %ebx
  8005e7:	6a 20                	push   $0x20
  8005e9:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005eb:	83 ef 01             	sub    $0x1,%edi
  8005ee:	83 c4 10             	add    $0x10,%esp
  8005f1:	85 ff                	test   %edi,%edi
  8005f3:	7f ee                	jg     8005e3 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8005f5:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005f8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fb:	e9 23 01 00 00       	jmp    800723 <vprintfmt+0x362>
  800600:	89 cf                	mov    %ecx,%edi
  800602:	eb ed                	jmp    8005f1 <vprintfmt+0x230>
	if (lflag >= 2)
  800604:	83 f9 01             	cmp    $0x1,%ecx
  800607:	7f 1b                	jg     800624 <vprintfmt+0x263>
	else if (lflag)
  800609:	85 c9                	test   %ecx,%ecx
  80060b:	74 63                	je     800670 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8b 00                	mov    (%eax),%eax
  800612:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800615:	99                   	cltd   
  800616:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8d 40 04             	lea    0x4(%eax),%eax
  80061f:	89 45 14             	mov    %eax,0x14(%ebp)
  800622:	eb 17                	jmp    80063b <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8b 50 04             	mov    0x4(%eax),%edx
  80062a:	8b 00                	mov    (%eax),%eax
  80062c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 40 08             	lea    0x8(%eax),%eax
  800638:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80063b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80063e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800641:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800646:	85 c9                	test   %ecx,%ecx
  800648:	0f 89 bb 00 00 00    	jns    800709 <vprintfmt+0x348>
				putch('-', putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	53                   	push   %ebx
  800652:	6a 2d                	push   $0x2d
  800654:	ff d6                	call   *%esi
				num = -(long long) num;
  800656:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800659:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80065c:	f7 da                	neg    %edx
  80065e:	83 d1 00             	adc    $0x0,%ecx
  800661:	f7 d9                	neg    %ecx
  800663:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800666:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066b:	e9 99 00 00 00       	jmp    800709 <vprintfmt+0x348>
		return va_arg(*ap, int);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8b 00                	mov    (%eax),%eax
  800675:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800678:	99                   	cltd   
  800679:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8d 40 04             	lea    0x4(%eax),%eax
  800682:	89 45 14             	mov    %eax,0x14(%ebp)
  800685:	eb b4                	jmp    80063b <vprintfmt+0x27a>
	if (lflag >= 2)
  800687:	83 f9 01             	cmp    $0x1,%ecx
  80068a:	7f 1b                	jg     8006a7 <vprintfmt+0x2e6>
	else if (lflag)
  80068c:	85 c9                	test   %ecx,%ecx
  80068e:	74 2c                	je     8006bc <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8b 10                	mov    (%eax),%edx
  800695:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069a:	8d 40 04             	lea    0x4(%eax),%eax
  80069d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006a0:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8006a5:	eb 62                	jmp    800709 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	8b 48 04             	mov    0x4(%eax),%ecx
  8006af:	8d 40 08             	lea    0x8(%eax),%eax
  8006b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006b5:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8006ba:	eb 4d                	jmp    800709 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8006bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bf:	8b 10                	mov    (%eax),%edx
  8006c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c6:	8d 40 04             	lea    0x4(%eax),%eax
  8006c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006cc:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8006d1:	eb 36                	jmp    800709 <vprintfmt+0x348>
	if (lflag >= 2)
  8006d3:	83 f9 01             	cmp    $0x1,%ecx
  8006d6:	7f 17                	jg     8006ef <vprintfmt+0x32e>
	else if (lflag)
  8006d8:	85 c9                	test   %ecx,%ecx
  8006da:	74 6e                	je     80074a <vprintfmt+0x389>
		return va_arg(*ap, long);
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8b 10                	mov    (%eax),%edx
  8006e1:	89 d0                	mov    %edx,%eax
  8006e3:	99                   	cltd   
  8006e4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006e7:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006ea:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006ed:	eb 11                	jmp    800700 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8b 50 04             	mov    0x4(%eax),%edx
  8006f5:	8b 00                	mov    (%eax),%eax
  8006f7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006fa:	8d 49 08             	lea    0x8(%ecx),%ecx
  8006fd:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800700:	89 d1                	mov    %edx,%ecx
  800702:	89 c2                	mov    %eax,%edx
            base = 8;
  800704:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800709:	83 ec 0c             	sub    $0xc,%esp
  80070c:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800710:	57                   	push   %edi
  800711:	ff 75 e0             	pushl  -0x20(%ebp)
  800714:	50                   	push   %eax
  800715:	51                   	push   %ecx
  800716:	52                   	push   %edx
  800717:	89 da                	mov    %ebx,%edx
  800719:	89 f0                	mov    %esi,%eax
  80071b:	e8 b6 fb ff ff       	call   8002d6 <printnum>
			break;
  800720:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800723:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800726:	83 c7 01             	add    $0x1,%edi
  800729:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80072d:	83 f8 25             	cmp    $0x25,%eax
  800730:	0f 84 a6 fc ff ff    	je     8003dc <vprintfmt+0x1b>
			if (ch == '\0')
  800736:	85 c0                	test   %eax,%eax
  800738:	0f 84 ce 00 00 00    	je     80080c <vprintfmt+0x44b>
			putch(ch, putdat);
  80073e:	83 ec 08             	sub    $0x8,%esp
  800741:	53                   	push   %ebx
  800742:	50                   	push   %eax
  800743:	ff d6                	call   *%esi
  800745:	83 c4 10             	add    $0x10,%esp
  800748:	eb dc                	jmp    800726 <vprintfmt+0x365>
		return va_arg(*ap, int);
  80074a:	8b 45 14             	mov    0x14(%ebp),%eax
  80074d:	8b 10                	mov    (%eax),%edx
  80074f:	89 d0                	mov    %edx,%eax
  800751:	99                   	cltd   
  800752:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800755:	8d 49 04             	lea    0x4(%ecx),%ecx
  800758:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80075b:	eb a3                	jmp    800700 <vprintfmt+0x33f>
			putch('0', putdat);
  80075d:	83 ec 08             	sub    $0x8,%esp
  800760:	53                   	push   %ebx
  800761:	6a 30                	push   $0x30
  800763:	ff d6                	call   *%esi
			putch('x', putdat);
  800765:	83 c4 08             	add    $0x8,%esp
  800768:	53                   	push   %ebx
  800769:	6a 78                	push   $0x78
  80076b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80076d:	8b 45 14             	mov    0x14(%ebp),%eax
  800770:	8b 10                	mov    (%eax),%edx
  800772:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800777:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80077a:	8d 40 04             	lea    0x4(%eax),%eax
  80077d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800780:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800785:	eb 82                	jmp    800709 <vprintfmt+0x348>
	if (lflag >= 2)
  800787:	83 f9 01             	cmp    $0x1,%ecx
  80078a:	7f 1e                	jg     8007aa <vprintfmt+0x3e9>
	else if (lflag)
  80078c:	85 c9                	test   %ecx,%ecx
  80078e:	74 32                	je     8007c2 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800790:	8b 45 14             	mov    0x14(%ebp),%eax
  800793:	8b 10                	mov    (%eax),%edx
  800795:	b9 00 00 00 00       	mov    $0x0,%ecx
  80079a:	8d 40 04             	lea    0x4(%eax),%eax
  80079d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a0:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8007a5:	e9 5f ff ff ff       	jmp    800709 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	8b 10                	mov    (%eax),%edx
  8007af:	8b 48 04             	mov    0x4(%eax),%ecx
  8007b2:	8d 40 08             	lea    0x8(%eax),%eax
  8007b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b8:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8007bd:	e9 47 ff ff ff       	jmp    800709 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8007c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c5:	8b 10                	mov    (%eax),%edx
  8007c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007cc:	8d 40 04             	lea    0x4(%eax),%eax
  8007cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d2:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8007d7:	e9 2d ff ff ff       	jmp    800709 <vprintfmt+0x348>
			putch(ch, putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	53                   	push   %ebx
  8007e0:	6a 25                	push   $0x25
  8007e2:	ff d6                	call   *%esi
			break;
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	e9 37 ff ff ff       	jmp    800723 <vprintfmt+0x362>
			putch('%', putdat);
  8007ec:	83 ec 08             	sub    $0x8,%esp
  8007ef:	53                   	push   %ebx
  8007f0:	6a 25                	push   $0x25
  8007f2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f4:	83 c4 10             	add    $0x10,%esp
  8007f7:	89 f8                	mov    %edi,%eax
  8007f9:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007fd:	74 05                	je     800804 <vprintfmt+0x443>
  8007ff:	83 e8 01             	sub    $0x1,%eax
  800802:	eb f5                	jmp    8007f9 <vprintfmt+0x438>
  800804:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800807:	e9 17 ff ff ff       	jmp    800723 <vprintfmt+0x362>
}
  80080c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80080f:	5b                   	pop    %ebx
  800810:	5e                   	pop    %esi
  800811:	5f                   	pop    %edi
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800814:	f3 0f 1e fb          	endbr32 
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	83 ec 18             	sub    $0x18,%esp
  80081e:	8b 45 08             	mov    0x8(%ebp),%eax
  800821:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800824:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800827:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80082b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80082e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800835:	85 c0                	test   %eax,%eax
  800837:	74 26                	je     80085f <vsnprintf+0x4b>
  800839:	85 d2                	test   %edx,%edx
  80083b:	7e 22                	jle    80085f <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80083d:	ff 75 14             	pushl  0x14(%ebp)
  800840:	ff 75 10             	pushl  0x10(%ebp)
  800843:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800846:	50                   	push   %eax
  800847:	68 7f 03 80 00       	push   $0x80037f
  80084c:	e8 70 fb ff ff       	call   8003c1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800851:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800854:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800857:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085a:	83 c4 10             	add    $0x10,%esp
}
  80085d:	c9                   	leave  
  80085e:	c3                   	ret    
		return -E_INVAL;
  80085f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800864:	eb f7                	jmp    80085d <vsnprintf+0x49>

00800866 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800866:	f3 0f 1e fb          	endbr32 
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800870:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800873:	50                   	push   %eax
  800874:	ff 75 10             	pushl  0x10(%ebp)
  800877:	ff 75 0c             	pushl  0xc(%ebp)
  80087a:	ff 75 08             	pushl  0x8(%ebp)
  80087d:	e8 92 ff ff ff       	call   800814 <vsnprintf>
	va_end(ap);

	return rc;
}
  800882:	c9                   	leave  
  800883:	c3                   	ret    

00800884 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800884:	f3 0f 1e fb          	endbr32 
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80088e:	b8 00 00 00 00       	mov    $0x0,%eax
  800893:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800897:	74 05                	je     80089e <strlen+0x1a>
		n++;
  800899:	83 c0 01             	add    $0x1,%eax
  80089c:	eb f5                	jmp    800893 <strlen+0xf>
	return n;
}
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008a0:	f3 0f 1e fb          	endbr32 
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008aa:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b2:	39 d0                	cmp    %edx,%eax
  8008b4:	74 0d                	je     8008c3 <strnlen+0x23>
  8008b6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008ba:	74 05                	je     8008c1 <strnlen+0x21>
		n++;
  8008bc:	83 c0 01             	add    $0x1,%eax
  8008bf:	eb f1                	jmp    8008b2 <strnlen+0x12>
  8008c1:	89 c2                	mov    %eax,%edx
	return n;
}
  8008c3:	89 d0                	mov    %edx,%eax
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008c7:	f3 0f 1e fb          	endbr32 
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	53                   	push   %ebx
  8008cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008da:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008de:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008e1:	83 c0 01             	add    $0x1,%eax
  8008e4:	84 d2                	test   %dl,%dl
  8008e6:	75 f2                	jne    8008da <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8008e8:	89 c8                	mov    %ecx,%eax
  8008ea:	5b                   	pop    %ebx
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ed:	f3 0f 1e fb          	endbr32 
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	53                   	push   %ebx
  8008f5:	83 ec 10             	sub    $0x10,%esp
  8008f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008fb:	53                   	push   %ebx
  8008fc:	e8 83 ff ff ff       	call   800884 <strlen>
  800901:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800904:	ff 75 0c             	pushl  0xc(%ebp)
  800907:	01 d8                	add    %ebx,%eax
  800909:	50                   	push   %eax
  80090a:	e8 b8 ff ff ff       	call   8008c7 <strcpy>
	return dst;
}
  80090f:	89 d8                	mov    %ebx,%eax
  800911:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800914:	c9                   	leave  
  800915:	c3                   	ret    

00800916 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800916:	f3 0f 1e fb          	endbr32 
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	56                   	push   %esi
  80091e:	53                   	push   %ebx
  80091f:	8b 75 08             	mov    0x8(%ebp),%esi
  800922:	8b 55 0c             	mov    0xc(%ebp),%edx
  800925:	89 f3                	mov    %esi,%ebx
  800927:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80092a:	89 f0                	mov    %esi,%eax
  80092c:	39 d8                	cmp    %ebx,%eax
  80092e:	74 11                	je     800941 <strncpy+0x2b>
		*dst++ = *src;
  800930:	83 c0 01             	add    $0x1,%eax
  800933:	0f b6 0a             	movzbl (%edx),%ecx
  800936:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800939:	80 f9 01             	cmp    $0x1,%cl
  80093c:	83 da ff             	sbb    $0xffffffff,%edx
  80093f:	eb eb                	jmp    80092c <strncpy+0x16>
	}
	return ret;
}
  800941:	89 f0                	mov    %esi,%eax
  800943:	5b                   	pop    %ebx
  800944:	5e                   	pop    %esi
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800947:	f3 0f 1e fb          	endbr32 
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	56                   	push   %esi
  80094f:	53                   	push   %ebx
  800950:	8b 75 08             	mov    0x8(%ebp),%esi
  800953:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800956:	8b 55 10             	mov    0x10(%ebp),%edx
  800959:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80095b:	85 d2                	test   %edx,%edx
  80095d:	74 21                	je     800980 <strlcpy+0x39>
  80095f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800963:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800965:	39 c2                	cmp    %eax,%edx
  800967:	74 14                	je     80097d <strlcpy+0x36>
  800969:	0f b6 19             	movzbl (%ecx),%ebx
  80096c:	84 db                	test   %bl,%bl
  80096e:	74 0b                	je     80097b <strlcpy+0x34>
			*dst++ = *src++;
  800970:	83 c1 01             	add    $0x1,%ecx
  800973:	83 c2 01             	add    $0x1,%edx
  800976:	88 5a ff             	mov    %bl,-0x1(%edx)
  800979:	eb ea                	jmp    800965 <strlcpy+0x1e>
  80097b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80097d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800980:	29 f0                	sub    %esi,%eax
}
  800982:	5b                   	pop    %ebx
  800983:	5e                   	pop    %esi
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800986:	f3 0f 1e fb          	endbr32 
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800990:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800993:	0f b6 01             	movzbl (%ecx),%eax
  800996:	84 c0                	test   %al,%al
  800998:	74 0c                	je     8009a6 <strcmp+0x20>
  80099a:	3a 02                	cmp    (%edx),%al
  80099c:	75 08                	jne    8009a6 <strcmp+0x20>
		p++, q++;
  80099e:	83 c1 01             	add    $0x1,%ecx
  8009a1:	83 c2 01             	add    $0x1,%edx
  8009a4:	eb ed                	jmp    800993 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a6:	0f b6 c0             	movzbl %al,%eax
  8009a9:	0f b6 12             	movzbl (%edx),%edx
  8009ac:	29 d0                	sub    %edx,%eax
}
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b0:	f3 0f 1e fb          	endbr32 
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	53                   	push   %ebx
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009be:	89 c3                	mov    %eax,%ebx
  8009c0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009c3:	eb 06                	jmp    8009cb <strncmp+0x1b>
		n--, p++, q++;
  8009c5:	83 c0 01             	add    $0x1,%eax
  8009c8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009cb:	39 d8                	cmp    %ebx,%eax
  8009cd:	74 16                	je     8009e5 <strncmp+0x35>
  8009cf:	0f b6 08             	movzbl (%eax),%ecx
  8009d2:	84 c9                	test   %cl,%cl
  8009d4:	74 04                	je     8009da <strncmp+0x2a>
  8009d6:	3a 0a                	cmp    (%edx),%cl
  8009d8:	74 eb                	je     8009c5 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009da:	0f b6 00             	movzbl (%eax),%eax
  8009dd:	0f b6 12             	movzbl (%edx),%edx
  8009e0:	29 d0                	sub    %edx,%eax
}
  8009e2:	5b                   	pop    %ebx
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    
		return 0;
  8009e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ea:	eb f6                	jmp    8009e2 <strncmp+0x32>

008009ec <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ec:	f3 0f 1e fb          	endbr32 
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009fa:	0f b6 10             	movzbl (%eax),%edx
  8009fd:	84 d2                	test   %dl,%dl
  8009ff:	74 09                	je     800a0a <strchr+0x1e>
		if (*s == c)
  800a01:	38 ca                	cmp    %cl,%dl
  800a03:	74 0a                	je     800a0f <strchr+0x23>
	for (; *s; s++)
  800a05:	83 c0 01             	add    $0x1,%eax
  800a08:	eb f0                	jmp    8009fa <strchr+0xe>
			return (char *) s;
	return 0;
  800a0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a11:	f3 0f 1e fb          	endbr32 
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a1f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a22:	38 ca                	cmp    %cl,%dl
  800a24:	74 09                	je     800a2f <strfind+0x1e>
  800a26:	84 d2                	test   %dl,%dl
  800a28:	74 05                	je     800a2f <strfind+0x1e>
	for (; *s; s++)
  800a2a:	83 c0 01             	add    $0x1,%eax
  800a2d:	eb f0                	jmp    800a1f <strfind+0xe>
			break;
	return (char *) s;
}
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a31:	f3 0f 1e fb          	endbr32 
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	57                   	push   %edi
  800a39:	56                   	push   %esi
  800a3a:	53                   	push   %ebx
  800a3b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a41:	85 c9                	test   %ecx,%ecx
  800a43:	74 31                	je     800a76 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a45:	89 f8                	mov    %edi,%eax
  800a47:	09 c8                	or     %ecx,%eax
  800a49:	a8 03                	test   $0x3,%al
  800a4b:	75 23                	jne    800a70 <memset+0x3f>
		c &= 0xFF;
  800a4d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a51:	89 d3                	mov    %edx,%ebx
  800a53:	c1 e3 08             	shl    $0x8,%ebx
  800a56:	89 d0                	mov    %edx,%eax
  800a58:	c1 e0 18             	shl    $0x18,%eax
  800a5b:	89 d6                	mov    %edx,%esi
  800a5d:	c1 e6 10             	shl    $0x10,%esi
  800a60:	09 f0                	or     %esi,%eax
  800a62:	09 c2                	or     %eax,%edx
  800a64:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a66:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a69:	89 d0                	mov    %edx,%eax
  800a6b:	fc                   	cld    
  800a6c:	f3 ab                	rep stos %eax,%es:(%edi)
  800a6e:	eb 06                	jmp    800a76 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a73:	fc                   	cld    
  800a74:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a76:	89 f8                	mov    %edi,%eax
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5f                   	pop    %edi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a7d:	f3 0f 1e fb          	endbr32 
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	57                   	push   %edi
  800a85:	56                   	push   %esi
  800a86:	8b 45 08             	mov    0x8(%ebp),%eax
  800a89:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a8f:	39 c6                	cmp    %eax,%esi
  800a91:	73 32                	jae    800ac5 <memmove+0x48>
  800a93:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a96:	39 c2                	cmp    %eax,%edx
  800a98:	76 2b                	jbe    800ac5 <memmove+0x48>
		s += n;
		d += n;
  800a9a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9d:	89 fe                	mov    %edi,%esi
  800a9f:	09 ce                	or     %ecx,%esi
  800aa1:	09 d6                	or     %edx,%esi
  800aa3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aa9:	75 0e                	jne    800ab9 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aab:	83 ef 04             	sub    $0x4,%edi
  800aae:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ab1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ab4:	fd                   	std    
  800ab5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab7:	eb 09                	jmp    800ac2 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ab9:	83 ef 01             	sub    $0x1,%edi
  800abc:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800abf:	fd                   	std    
  800ac0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ac2:	fc                   	cld    
  800ac3:	eb 1a                	jmp    800adf <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac5:	89 c2                	mov    %eax,%edx
  800ac7:	09 ca                	or     %ecx,%edx
  800ac9:	09 f2                	or     %esi,%edx
  800acb:	f6 c2 03             	test   $0x3,%dl
  800ace:	75 0a                	jne    800ada <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ad0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ad3:	89 c7                	mov    %eax,%edi
  800ad5:	fc                   	cld    
  800ad6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad8:	eb 05                	jmp    800adf <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800ada:	89 c7                	mov    %eax,%edi
  800adc:	fc                   	cld    
  800add:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ae3:	f3 0f 1e fb          	endbr32 
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aed:	ff 75 10             	pushl  0x10(%ebp)
  800af0:	ff 75 0c             	pushl  0xc(%ebp)
  800af3:	ff 75 08             	pushl  0x8(%ebp)
  800af6:	e8 82 ff ff ff       	call   800a7d <memmove>
}
  800afb:	c9                   	leave  
  800afc:	c3                   	ret    

00800afd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800afd:	f3 0f 1e fb          	endbr32 
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
  800b06:	8b 45 08             	mov    0x8(%ebp),%eax
  800b09:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0c:	89 c6                	mov    %eax,%esi
  800b0e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b11:	39 f0                	cmp    %esi,%eax
  800b13:	74 1c                	je     800b31 <memcmp+0x34>
		if (*s1 != *s2)
  800b15:	0f b6 08             	movzbl (%eax),%ecx
  800b18:	0f b6 1a             	movzbl (%edx),%ebx
  800b1b:	38 d9                	cmp    %bl,%cl
  800b1d:	75 08                	jne    800b27 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b1f:	83 c0 01             	add    $0x1,%eax
  800b22:	83 c2 01             	add    $0x1,%edx
  800b25:	eb ea                	jmp    800b11 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800b27:	0f b6 c1             	movzbl %cl,%eax
  800b2a:	0f b6 db             	movzbl %bl,%ebx
  800b2d:	29 d8                	sub    %ebx,%eax
  800b2f:	eb 05                	jmp    800b36 <memcmp+0x39>
	}

	return 0;
  800b31:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b3a:	f3 0f 1e fb          	endbr32 
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	8b 45 08             	mov    0x8(%ebp),%eax
  800b44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b47:	89 c2                	mov    %eax,%edx
  800b49:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b4c:	39 d0                	cmp    %edx,%eax
  800b4e:	73 09                	jae    800b59 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b50:	38 08                	cmp    %cl,(%eax)
  800b52:	74 05                	je     800b59 <memfind+0x1f>
	for (; s < ends; s++)
  800b54:	83 c0 01             	add    $0x1,%eax
  800b57:	eb f3                	jmp    800b4c <memfind+0x12>
			break;
	return (void *) s;
}
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5b:	f3 0f 1e fb          	endbr32 
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6b:	eb 03                	jmp    800b70 <strtol+0x15>
		s++;
  800b6d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b70:	0f b6 01             	movzbl (%ecx),%eax
  800b73:	3c 20                	cmp    $0x20,%al
  800b75:	74 f6                	je     800b6d <strtol+0x12>
  800b77:	3c 09                	cmp    $0x9,%al
  800b79:	74 f2                	je     800b6d <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b7b:	3c 2b                	cmp    $0x2b,%al
  800b7d:	74 2a                	je     800ba9 <strtol+0x4e>
	int neg = 0;
  800b7f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b84:	3c 2d                	cmp    $0x2d,%al
  800b86:	74 2b                	je     800bb3 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b88:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b8e:	75 0f                	jne    800b9f <strtol+0x44>
  800b90:	80 39 30             	cmpb   $0x30,(%ecx)
  800b93:	74 28                	je     800bbd <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b95:	85 db                	test   %ebx,%ebx
  800b97:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b9c:	0f 44 d8             	cmove  %eax,%ebx
  800b9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ba7:	eb 46                	jmp    800bef <strtol+0x94>
		s++;
  800ba9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bac:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb1:	eb d5                	jmp    800b88 <strtol+0x2d>
		s++, neg = 1;
  800bb3:	83 c1 01             	add    $0x1,%ecx
  800bb6:	bf 01 00 00 00       	mov    $0x1,%edi
  800bbb:	eb cb                	jmp    800b88 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bbd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bc1:	74 0e                	je     800bd1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bc3:	85 db                	test   %ebx,%ebx
  800bc5:	75 d8                	jne    800b9f <strtol+0x44>
		s++, base = 8;
  800bc7:	83 c1 01             	add    $0x1,%ecx
  800bca:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bcf:	eb ce                	jmp    800b9f <strtol+0x44>
		s += 2, base = 16;
  800bd1:	83 c1 02             	add    $0x2,%ecx
  800bd4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bd9:	eb c4                	jmp    800b9f <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bdb:	0f be d2             	movsbl %dl,%edx
  800bde:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800be1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800be4:	7d 3a                	jge    800c20 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800be6:	83 c1 01             	add    $0x1,%ecx
  800be9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bed:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bef:	0f b6 11             	movzbl (%ecx),%edx
  800bf2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bf5:	89 f3                	mov    %esi,%ebx
  800bf7:	80 fb 09             	cmp    $0x9,%bl
  800bfa:	76 df                	jbe    800bdb <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800bfc:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bff:	89 f3                	mov    %esi,%ebx
  800c01:	80 fb 19             	cmp    $0x19,%bl
  800c04:	77 08                	ja     800c0e <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c06:	0f be d2             	movsbl %dl,%edx
  800c09:	83 ea 57             	sub    $0x57,%edx
  800c0c:	eb d3                	jmp    800be1 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800c0e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c11:	89 f3                	mov    %esi,%ebx
  800c13:	80 fb 19             	cmp    $0x19,%bl
  800c16:	77 08                	ja     800c20 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c18:	0f be d2             	movsbl %dl,%edx
  800c1b:	83 ea 37             	sub    $0x37,%edx
  800c1e:	eb c1                	jmp    800be1 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c20:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c24:	74 05                	je     800c2b <strtol+0xd0>
		*endptr = (char *) s;
  800c26:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c29:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c2b:	89 c2                	mov    %eax,%edx
  800c2d:	f7 da                	neg    %edx
  800c2f:	85 ff                	test   %edi,%edi
  800c31:	0f 45 c2             	cmovne %edx,%eax
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c39:	f3 0f 1e fb          	endbr32 
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c43:	b8 00 00 00 00       	mov    $0x0,%eax
  800c48:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4e:	89 c3                	mov    %eax,%ebx
  800c50:	89 c7                	mov    %eax,%edi
  800c52:	89 c6                	mov    %eax,%esi
  800c54:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_cgetc>:

int
sys_cgetc(void)
{
  800c5b:	f3 0f 1e fb          	endbr32 
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c65:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c6f:	89 d1                	mov    %edx,%ecx
  800c71:	89 d3                	mov    %edx,%ebx
  800c73:	89 d7                	mov    %edx,%edi
  800c75:	89 d6                	mov    %edx,%esi
  800c77:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c7e:	f3 0f 1e fb          	endbr32 
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c8b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	b8 03 00 00 00       	mov    $0x3,%eax
  800c98:	89 cb                	mov    %ecx,%ebx
  800c9a:	89 cf                	mov    %ecx,%edi
  800c9c:	89 ce                	mov    %ecx,%esi
  800c9e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca0:	85 c0                	test   %eax,%eax
  800ca2:	7f 08                	jg     800cac <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
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
  800cb0:	6a 03                	push   $0x3
  800cb2:	68 64 18 80 00       	push   $0x801864
  800cb7:	6a 23                	push   $0x23
  800cb9:	68 81 18 80 00       	push   $0x801881
  800cbe:	e8 4c 05 00 00       	call   80120f <_panic>

00800cc3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cc3:	f3 0f 1e fb          	endbr32 
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ccd:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd2:	b8 02 00 00 00       	mov    $0x2,%eax
  800cd7:	89 d1                	mov    %edx,%ecx
  800cd9:	89 d3                	mov    %edx,%ebx
  800cdb:	89 d7                	mov    %edx,%edi
  800cdd:	89 d6                	mov    %edx,%esi
  800cdf:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_yield>:

void
sys_yield(void)
{
  800ce6:	f3 0f 1e fb          	endbr32 
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cfa:	89 d1                	mov    %edx,%ecx
  800cfc:	89 d3                	mov    %edx,%ebx
  800cfe:	89 d7                	mov    %edx,%edi
  800d00:	89 d6                	mov    %edx,%esi
  800d02:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d09:	f3 0f 1e fb          	endbr32 
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d16:	be 00 00 00 00       	mov    $0x0,%esi
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d21:	b8 04 00 00 00       	mov    $0x4,%eax
  800d26:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d29:	89 f7                	mov    %esi,%edi
  800d2b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	7f 08                	jg     800d39 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d39:	83 ec 0c             	sub    $0xc,%esp
  800d3c:	50                   	push   %eax
  800d3d:	6a 04                	push   $0x4
  800d3f:	68 64 18 80 00       	push   $0x801864
  800d44:	6a 23                	push   $0x23
  800d46:	68 81 18 80 00       	push   $0x801881
  800d4b:	e8 bf 04 00 00       	call   80120f <_panic>

00800d50 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d50:	f3 0f 1e fb          	endbr32 
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d63:	b8 05 00 00 00       	mov    $0x5,%eax
  800d68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6e:	8b 75 18             	mov    0x18(%ebp),%esi
  800d71:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d73:	85 c0                	test   %eax,%eax
  800d75:	7f 08                	jg     800d7f <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7f:	83 ec 0c             	sub    $0xc,%esp
  800d82:	50                   	push   %eax
  800d83:	6a 05                	push   $0x5
  800d85:	68 64 18 80 00       	push   $0x801864
  800d8a:	6a 23                	push   $0x23
  800d8c:	68 81 18 80 00       	push   $0x801881
  800d91:	e8 79 04 00 00       	call   80120f <_panic>

00800d96 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d96:	f3 0f 1e fb          	endbr32 
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	57                   	push   %edi
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
  800da0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dae:	b8 06 00 00 00       	mov    $0x6,%eax
  800db3:	89 df                	mov    %ebx,%edi
  800db5:	89 de                	mov    %ebx,%esi
  800db7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	7f 08                	jg     800dc5 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc5:	83 ec 0c             	sub    $0xc,%esp
  800dc8:	50                   	push   %eax
  800dc9:	6a 06                	push   $0x6
  800dcb:	68 64 18 80 00       	push   $0x801864
  800dd0:	6a 23                	push   $0x23
  800dd2:	68 81 18 80 00       	push   $0x801881
  800dd7:	e8 33 04 00 00       	call   80120f <_panic>

00800ddc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ddc:	f3 0f 1e fb          	endbr32 
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	57                   	push   %edi
  800de4:	56                   	push   %esi
  800de5:	53                   	push   %ebx
  800de6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800de9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dee:	8b 55 08             	mov    0x8(%ebp),%edx
  800df1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df4:	b8 08 00 00 00       	mov    $0x8,%eax
  800df9:	89 df                	mov    %ebx,%edi
  800dfb:	89 de                	mov    %ebx,%esi
  800dfd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dff:	85 c0                	test   %eax,%eax
  800e01:	7f 08                	jg     800e0b <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e06:	5b                   	pop    %ebx
  800e07:	5e                   	pop    %esi
  800e08:	5f                   	pop    %edi
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0b:	83 ec 0c             	sub    $0xc,%esp
  800e0e:	50                   	push   %eax
  800e0f:	6a 08                	push   $0x8
  800e11:	68 64 18 80 00       	push   $0x801864
  800e16:	6a 23                	push   $0x23
  800e18:	68 81 18 80 00       	push   $0x801881
  800e1d:	e8 ed 03 00 00       	call   80120f <_panic>

00800e22 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e22:	f3 0f 1e fb          	endbr32 
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	57                   	push   %edi
  800e2a:	56                   	push   %esi
  800e2b:	53                   	push   %ebx
  800e2c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e34:	8b 55 08             	mov    0x8(%ebp),%edx
  800e37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3a:	b8 09 00 00 00       	mov    $0x9,%eax
  800e3f:	89 df                	mov    %ebx,%edi
  800e41:	89 de                	mov    %ebx,%esi
  800e43:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e45:	85 c0                	test   %eax,%eax
  800e47:	7f 08                	jg     800e51 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5f                   	pop    %edi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e51:	83 ec 0c             	sub    $0xc,%esp
  800e54:	50                   	push   %eax
  800e55:	6a 09                	push   $0x9
  800e57:	68 64 18 80 00       	push   $0x801864
  800e5c:	6a 23                	push   $0x23
  800e5e:	68 81 18 80 00       	push   $0x801881
  800e63:	e8 a7 03 00 00       	call   80120f <_panic>

00800e68 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e68:	f3 0f 1e fb          	endbr32 
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	57                   	push   %edi
  800e70:	56                   	push   %esi
  800e71:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e72:	8b 55 08             	mov    0x8(%ebp),%edx
  800e75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e78:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e7d:	be 00 00 00 00       	mov    $0x0,%esi
  800e82:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e85:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e88:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e8a:	5b                   	pop    %ebx
  800e8b:	5e                   	pop    %esi
  800e8c:	5f                   	pop    %edi
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e8f:	f3 0f 1e fb          	endbr32 
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	57                   	push   %edi
  800e97:	56                   	push   %esi
  800e98:	53                   	push   %ebx
  800e99:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ea9:	89 cb                	mov    %ecx,%ebx
  800eab:	89 cf                	mov    %ecx,%edi
  800ead:	89 ce                	mov    %ecx,%esi
  800eaf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eb1:	85 c0                	test   %eax,%eax
  800eb3:	7f 08                	jg     800ebd <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb8:	5b                   	pop    %ebx
  800eb9:	5e                   	pop    %esi
  800eba:	5f                   	pop    %edi
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebd:	83 ec 0c             	sub    $0xc,%esp
  800ec0:	50                   	push   %eax
  800ec1:	6a 0c                	push   $0xc
  800ec3:	68 64 18 80 00       	push   $0x801864
  800ec8:	6a 23                	push   $0x23
  800eca:	68 81 18 80 00       	push   $0x801881
  800ecf:	e8 3b 03 00 00       	call   80120f <_panic>

00800ed4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ed4:	f3 0f 1e fb          	endbr32 
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	53                   	push   %ebx
  800edc:	83 ec 04             	sub    $0x4,%esp
  800edf:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ee2:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if ( !(err & FEC_WR) ||
  800ee4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ee8:	74 75                	je     800f5f <pgfault+0x8b>
            !(uvpt[PGNUM(addr)] | PTE_COW) ) {
  800eea:	89 d8                	mov    %ebx,%eax
  800eec:	c1 e8 0c             	shr    $0xc,%eax
  800eef:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0) {
  800ef6:	83 ec 04             	sub    $0x4,%esp
  800ef9:	6a 07                	push   $0x7
  800efb:	68 00 f0 7f 00       	push   $0x7ff000
  800f00:	6a 00                	push   $0x0
  800f02:	e8 02 fe ff ff       	call   800d09 <sys_page_alloc>
  800f07:	83 c4 10             	add    $0x10,%esp
  800f0a:	85 c0                	test   %eax,%eax
  800f0c:	78 65                	js     800f73 <pgfault+0x9f>
        panic("sys_page_alloc failed %e\n", r);
    }
    memmove((void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);
  800f0e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800f14:	83 ec 04             	sub    $0x4,%esp
  800f17:	68 00 10 00 00       	push   $0x1000
  800f1c:	53                   	push   %ebx
  800f1d:	68 00 f0 7f 00       	push   $0x7ff000
  800f22:	e8 56 fb ff ff       	call   800a7d <memmove>
    if ((r = sys_page_map(0, (void *)PFTEMP,
  800f27:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f2e:	53                   	push   %ebx
  800f2f:	6a 00                	push   $0x0
  800f31:	68 00 f0 7f 00       	push   $0x7ff000
  800f36:	6a 00                	push   $0x0
  800f38:	e8 13 fe ff ff       	call   800d50 <sys_page_map>
  800f3d:	83 c4 20             	add    $0x20,%esp
  800f40:	85 c0                	test   %eax,%eax
  800f42:	78 41                	js     800f85 <pgfault+0xb1>
                0, (void *)PTE_ADDR(addr), PTE_P | PTE_U | PTE_W)) < 0) {
        panic("sys_page_map failed %e\n", r);
    }
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0) {
  800f44:	83 ec 08             	sub    $0x8,%esp
  800f47:	68 00 f0 7f 00       	push   $0x7ff000
  800f4c:	6a 00                	push   $0x0
  800f4e:	e8 43 fe ff ff       	call   800d96 <sys_page_unmap>
  800f53:	83 c4 10             	add    $0x10,%esp
  800f56:	85 c0                	test   %eax,%eax
  800f58:	78 3d                	js     800f97 <pgfault+0xc3>
        panic("sys_page_unmap failed %e\n", r);
    }

}
  800f5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f5d:	c9                   	leave  
  800f5e:	c3                   	ret    
        panic("Not a copy-on-write page");
  800f5f:	83 ec 04             	sub    $0x4,%esp
  800f62:	68 8f 18 80 00       	push   $0x80188f
  800f67:	6a 1e                	push   $0x1e
  800f69:	68 a8 18 80 00       	push   $0x8018a8
  800f6e:	e8 9c 02 00 00       	call   80120f <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800f73:	50                   	push   %eax
  800f74:	68 b3 18 80 00       	push   $0x8018b3
  800f79:	6a 2a                	push   $0x2a
  800f7b:	68 a8 18 80 00       	push   $0x8018a8
  800f80:	e8 8a 02 00 00       	call   80120f <_panic>
        panic("sys_page_map failed %e\n", r);
  800f85:	50                   	push   %eax
  800f86:	68 cd 18 80 00       	push   $0x8018cd
  800f8b:	6a 2f                	push   $0x2f
  800f8d:	68 a8 18 80 00       	push   $0x8018a8
  800f92:	e8 78 02 00 00       	call   80120f <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800f97:	50                   	push   %eax
  800f98:	68 e5 18 80 00       	push   $0x8018e5
  800f9d:	6a 32                	push   $0x32
  800f9f:	68 a8 18 80 00       	push   $0x8018a8
  800fa4:	e8 66 02 00 00       	call   80120f <_panic>

00800fa9 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fa9:	f3 0f 1e fb          	endbr32 
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	57                   	push   %edi
  800fb1:	56                   	push   %esi
  800fb2:	53                   	push   %ebx
  800fb3:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");

    // 1. set pgfault handler.
    set_pgfault_handler(pgfault);
  800fb6:	68 d4 0e 80 00       	push   $0x800ed4
  800fbb:	e8 99 02 00 00       	call   801259 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fc0:	b8 07 00 00 00       	mov    $0x7,%eax
  800fc5:	cd 30                	int    $0x30
  800fc7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fca:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 2. exofork.
    envid_t envid = sys_exofork();

    if (envid < 0)
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 2a                	js     800ffe <fork+0x55>
        thisenv = &envs[ENVX(my_envid)];
        return 0;
    }
    else {
        // parent
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  800fd4:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800fd9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800fdd:	75 4e                	jne    80102d <fork+0x84>
        envid_t my_envid = sys_getenvid();
  800fdf:	e8 df fc ff ff       	call   800cc3 <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  800fe4:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fe9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fec:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ff1:	a3 0c 20 80 00       	mov    %eax,0x80200c
        return 0;
  800ff6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ff9:	e9 f1 00 00 00       	jmp    8010ef <fork+0x146>
        panic("fork, sys_exofork %e", envid);
  800ffe:	50                   	push   %eax
  800fff:	68 ff 18 80 00       	push   $0x8018ff
  801004:	6a 7b                	push   $0x7b
  801006:	68 a8 18 80 00       	push   $0x8018a8
  80100b:	e8 ff 01 00 00       	call   80120f <_panic>
        panic("sys_page_map others failed %e\n", r);
  801010:	50                   	push   %eax
  801011:	68 48 19 80 00       	push   $0x801948
  801016:	6a 51                	push   $0x51
  801018:	68 a8 18 80 00       	push   $0x8018a8
  80101d:	e8 ed 01 00 00       	call   80120f <_panic>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  801022:	83 c3 01             	add    $0x1,%ebx
  801025:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  80102b:	74 7c                	je     8010a9 <fork+0x100>
  80102d:	89 de                	mov    %ebx,%esi
  80102f:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  801032:	89 f0                	mov    %esi,%eax
  801034:	c1 e8 16             	shr    $0x16,%eax
  801037:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80103e:	a8 01                	test   $0x1,%al
  801040:	74 e0                	je     801022 <fork+0x79>
                    (uvpt[pn] & PTE_P) ) {
  801042:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  801049:	a8 01                	test   $0x1,%al
  80104b:	74 d5                	je     801022 <fork+0x79>
    pte_t pte = uvpt[pn];
  80104d:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    if ( (pte & PTE_W) || (pte & PTE_COW) ) {
  801054:	25 02 08 00 00       	and    $0x802,%eax
        perm |= PTE_COW;
  801059:	83 f8 01             	cmp    $0x1,%eax
  80105c:	19 ff                	sbb    %edi,%edi
  80105e:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  801064:	81 c7 05 08 00 00    	add    $0x805,%edi
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  80106a:	83 ec 0c             	sub    $0xc,%esp
  80106d:	57                   	push   %edi
  80106e:	56                   	push   %esi
  80106f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801072:	56                   	push   %esi
  801073:	6a 00                	push   $0x0
  801075:	e8 d6 fc ff ff       	call   800d50 <sys_page_map>
  80107a:	83 c4 20             	add    $0x20,%esp
  80107d:	85 c0                	test   %eax,%eax
  80107f:	78 8f                	js     801010 <fork+0x67>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  801081:	83 ec 0c             	sub    $0xc,%esp
  801084:	57                   	push   %edi
  801085:	56                   	push   %esi
  801086:	6a 00                	push   $0x0
  801088:	56                   	push   %esi
  801089:	6a 00                	push   $0x0
  80108b:	e8 c0 fc ff ff       	call   800d50 <sys_page_map>
  801090:	83 c4 20             	add    $0x20,%esp
  801093:	85 c0                	test   %eax,%eax
  801095:	79 8b                	jns    801022 <fork+0x79>
            panic("sys_page_map mine failed %e\n", r);
  801097:	50                   	push   %eax
  801098:	68 14 19 80 00       	push   $0x801914
  80109d:	6a 56                	push   $0x56
  80109f:	68 a8 18 80 00       	push   $0x8018a8
  8010a4:	e8 66 01 00 00       	call   80120f <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  8010a9:	83 ec 04             	sub    $0x4,%esp
  8010ac:	6a 07                	push   $0x7
  8010ae:	68 00 f0 bf ee       	push   $0xeebff000
  8010b3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8010b6:	57                   	push   %edi
  8010b7:	e8 4d fc ff ff       	call   800d09 <sys_page_alloc>
  8010bc:	83 c4 10             	add    $0x10,%esp
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	78 2c                	js     8010ef <fork+0x146>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  8010c3:	a1 0c 20 80 00       	mov    0x80200c,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  8010c8:	8b 40 64             	mov    0x64(%eax),%eax
  8010cb:	83 ec 08             	sub    $0x8,%esp
  8010ce:	50                   	push   %eax
  8010cf:	57                   	push   %edi
  8010d0:	e8 4d fd ff ff       	call   800e22 <sys_env_set_pgfault_upcall>
  8010d5:	83 c4 10             	add    $0x10,%esp
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	78 13                	js     8010ef <fork+0x146>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8010dc:	83 ec 08             	sub    $0x8,%esp
  8010df:	6a 02                	push   $0x2
  8010e1:	57                   	push   %edi
  8010e2:	e8 f5 fc ff ff       	call   800ddc <sys_env_set_status>
  8010e7:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	0f 49 c7             	cmovns %edi,%eax
    }

}
  8010ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f2:	5b                   	pop    %ebx
  8010f3:	5e                   	pop    %esi
  8010f4:	5f                   	pop    %edi
  8010f5:	5d                   	pop    %ebp
  8010f6:	c3                   	ret    

008010f7 <sfork>:

// Challenge!
int
sfork(void)
{
  8010f7:	f3 0f 1e fb          	endbr32 
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801101:	68 31 19 80 00       	push   $0x801931
  801106:	68 a5 00 00 00       	push   $0xa5
  80110b:	68 a8 18 80 00       	push   $0x8018a8
  801110:	e8 fa 00 00 00       	call   80120f <_panic>

00801115 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801115:	f3 0f 1e fb          	endbr32 
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	56                   	push   %esi
  80111d:	53                   	push   %ebx
  80111e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801121:	8b 45 0c             	mov    0xc(%ebp),%eax
  801124:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801127:	85 c0                	test   %eax,%eax
  801129:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80112e:	0f 44 c2             	cmove  %edx,%eax
  801131:	83 ec 0c             	sub    $0xc,%esp
  801134:	50                   	push   %eax
  801135:	e8 55 fd ff ff       	call   800e8f <sys_ipc_recv>
  80113a:	83 c4 10             	add    $0x10,%esp
  80113d:	85 c0                	test   %eax,%eax
  80113f:	78 24                	js     801165 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801141:	85 f6                	test   %esi,%esi
  801143:	74 0a                	je     80114f <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801145:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80114a:	8b 40 78             	mov    0x78(%eax),%eax
  80114d:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  80114f:	85 db                	test   %ebx,%ebx
  801151:	74 0a                	je     80115d <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801153:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801158:	8b 40 74             	mov    0x74(%eax),%eax
  80115b:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  80115d:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801162:	8b 40 70             	mov    0x70(%eax),%eax
}
  801165:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801168:	5b                   	pop    %ebx
  801169:	5e                   	pop    %esi
  80116a:	5d                   	pop    %ebp
  80116b:	c3                   	ret    

0080116c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80116c:	f3 0f 1e fb          	endbr32 
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	57                   	push   %edi
  801174:	56                   	push   %esi
  801175:	53                   	push   %ebx
  801176:	83 ec 1c             	sub    $0x1c,%esp
  801179:	8b 45 10             	mov    0x10(%ebp),%eax
  80117c:	85 c0                	test   %eax,%eax
  80117e:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801183:	0f 45 d0             	cmovne %eax,%edx
  801186:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801188:	be 01 00 00 00       	mov    $0x1,%esi
  80118d:	eb 1f                	jmp    8011ae <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  80118f:	e8 52 fb ff ff       	call   800ce6 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801194:	83 c3 01             	add    $0x1,%ebx
  801197:	39 de                	cmp    %ebx,%esi
  801199:	7f f4                	jg     80118f <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  80119b:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  80119d:	83 fe 11             	cmp    $0x11,%esi
  8011a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8011a5:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  8011a8:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  8011ac:	75 1c                	jne    8011ca <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  8011ae:	ff 75 14             	pushl  0x14(%ebp)
  8011b1:	57                   	push   %edi
  8011b2:	ff 75 0c             	pushl  0xc(%ebp)
  8011b5:	ff 75 08             	pushl  0x8(%ebp)
  8011b8:	e8 ab fc ff ff       	call   800e68 <sys_ipc_try_send>
  8011bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c8:	eb cd                	jmp    801197 <ipc_send+0x2b>
}
  8011ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011cd:	5b                   	pop    %ebx
  8011ce:	5e                   	pop    %esi
  8011cf:	5f                   	pop    %edi
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011d2:	f3 0f 1e fb          	endbr32 
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011dc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011e1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011e4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011ea:	8b 52 50             	mov    0x50(%edx),%edx
  8011ed:	39 ca                	cmp    %ecx,%edx
  8011ef:	74 11                	je     801202 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8011f1:	83 c0 01             	add    $0x1,%eax
  8011f4:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011f9:	75 e6                	jne    8011e1 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8011fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801200:	eb 0b                	jmp    80120d <ipc_find_env+0x3b>
			return envs[i].env_id;
  801202:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801205:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80120a:	8b 40 48             	mov    0x48(%eax),%eax
}
  80120d:	5d                   	pop    %ebp
  80120e:	c3                   	ret    

0080120f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80120f:	f3 0f 1e fb          	endbr32 
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
  801216:	56                   	push   %esi
  801217:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801218:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80121b:	8b 35 08 20 80 00    	mov    0x802008,%esi
  801221:	e8 9d fa ff ff       	call   800cc3 <sys_getenvid>
  801226:	83 ec 0c             	sub    $0xc,%esp
  801229:	ff 75 0c             	pushl  0xc(%ebp)
  80122c:	ff 75 08             	pushl  0x8(%ebp)
  80122f:	56                   	push   %esi
  801230:	50                   	push   %eax
  801231:	68 68 19 80 00       	push   $0x801968
  801236:	e8 83 f0 ff ff       	call   8002be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80123b:	83 c4 18             	add    $0x18,%esp
  80123e:	53                   	push   %ebx
  80123f:	ff 75 10             	pushl  0x10(%ebp)
  801242:	e8 22 f0 ff ff       	call   800269 <vcprintf>
	cprintf("\n");
  801247:	c7 04 24 98 19 80 00 	movl   $0x801998,(%esp)
  80124e:	e8 6b f0 ff ff       	call   8002be <cprintf>
  801253:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801256:	cc                   	int3   
  801257:	eb fd                	jmp    801256 <_panic+0x47>

00801259 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801259:	f3 0f 1e fb          	endbr32 
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801263:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  80126a:	74 0a                	je     801276 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80126c:	8b 45 08             	mov    0x8(%ebp),%eax
  80126f:	a3 10 20 80 00       	mov    %eax,0x802010
}
  801274:	c9                   	leave  
  801275:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801276:	83 ec 0c             	sub    $0xc,%esp
  801279:	68 8b 19 80 00       	push   $0x80198b
  80127e:	e8 3b f0 ff ff       	call   8002be <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  801283:	83 c4 0c             	add    $0xc,%esp
  801286:	6a 07                	push   $0x7
  801288:	68 00 f0 bf ee       	push   $0xeebff000
  80128d:	6a 00                	push   $0x0
  80128f:	e8 75 fa ff ff       	call   800d09 <sys_page_alloc>
  801294:	83 c4 10             	add    $0x10,%esp
  801297:	85 c0                	test   %eax,%eax
  801299:	78 2a                	js     8012c5 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  80129b:	83 ec 08             	sub    $0x8,%esp
  80129e:	68 d9 12 80 00       	push   $0x8012d9
  8012a3:	6a 00                	push   $0x0
  8012a5:	e8 78 fb ff ff       	call   800e22 <sys_env_set_pgfault_upcall>
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	79 bb                	jns    80126c <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  8012b1:	83 ec 04             	sub    $0x4,%esp
  8012b4:	68 c8 19 80 00       	push   $0x8019c8
  8012b9:	6a 25                	push   $0x25
  8012bb:	68 b8 19 80 00       	push   $0x8019b8
  8012c0:	e8 4a ff ff ff       	call   80120f <_panic>
            panic("Allocation of UXSTACK failed!");
  8012c5:	83 ec 04             	sub    $0x4,%esp
  8012c8:	68 9a 19 80 00       	push   $0x80199a
  8012cd:	6a 22                	push   $0x22
  8012cf:	68 b8 19 80 00       	push   $0x8019b8
  8012d4:	e8 36 ff ff ff       	call   80120f <_panic>

008012d9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012d9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012da:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  8012df:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012e1:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  8012e4:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  8012e8:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  8012ec:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  8012ef:	83 c4 08             	add    $0x8,%esp
    popa
  8012f2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $0x4, %esp
  8012f3:	83 c4 04             	add    $0x4,%esp
    popf
  8012f6:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  8012f7:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  8012fa:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  8012fe:	c3                   	ret    
  8012ff:	90                   	nop

00801300 <__udivdi3>:
  801300:	f3 0f 1e fb          	endbr32 
  801304:	55                   	push   %ebp
  801305:	57                   	push   %edi
  801306:	56                   	push   %esi
  801307:	53                   	push   %ebx
  801308:	83 ec 1c             	sub    $0x1c,%esp
  80130b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80130f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801313:	8b 74 24 34          	mov    0x34(%esp),%esi
  801317:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80131b:	85 d2                	test   %edx,%edx
  80131d:	75 19                	jne    801338 <__udivdi3+0x38>
  80131f:	39 f3                	cmp    %esi,%ebx
  801321:	76 4d                	jbe    801370 <__udivdi3+0x70>
  801323:	31 ff                	xor    %edi,%edi
  801325:	89 e8                	mov    %ebp,%eax
  801327:	89 f2                	mov    %esi,%edx
  801329:	f7 f3                	div    %ebx
  80132b:	89 fa                	mov    %edi,%edx
  80132d:	83 c4 1c             	add    $0x1c,%esp
  801330:	5b                   	pop    %ebx
  801331:	5e                   	pop    %esi
  801332:	5f                   	pop    %edi
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    
  801335:	8d 76 00             	lea    0x0(%esi),%esi
  801338:	39 f2                	cmp    %esi,%edx
  80133a:	76 14                	jbe    801350 <__udivdi3+0x50>
  80133c:	31 ff                	xor    %edi,%edi
  80133e:	31 c0                	xor    %eax,%eax
  801340:	89 fa                	mov    %edi,%edx
  801342:	83 c4 1c             	add    $0x1c,%esp
  801345:	5b                   	pop    %ebx
  801346:	5e                   	pop    %esi
  801347:	5f                   	pop    %edi
  801348:	5d                   	pop    %ebp
  801349:	c3                   	ret    
  80134a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801350:	0f bd fa             	bsr    %edx,%edi
  801353:	83 f7 1f             	xor    $0x1f,%edi
  801356:	75 48                	jne    8013a0 <__udivdi3+0xa0>
  801358:	39 f2                	cmp    %esi,%edx
  80135a:	72 06                	jb     801362 <__udivdi3+0x62>
  80135c:	31 c0                	xor    %eax,%eax
  80135e:	39 eb                	cmp    %ebp,%ebx
  801360:	77 de                	ja     801340 <__udivdi3+0x40>
  801362:	b8 01 00 00 00       	mov    $0x1,%eax
  801367:	eb d7                	jmp    801340 <__udivdi3+0x40>
  801369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801370:	89 d9                	mov    %ebx,%ecx
  801372:	85 db                	test   %ebx,%ebx
  801374:	75 0b                	jne    801381 <__udivdi3+0x81>
  801376:	b8 01 00 00 00       	mov    $0x1,%eax
  80137b:	31 d2                	xor    %edx,%edx
  80137d:	f7 f3                	div    %ebx
  80137f:	89 c1                	mov    %eax,%ecx
  801381:	31 d2                	xor    %edx,%edx
  801383:	89 f0                	mov    %esi,%eax
  801385:	f7 f1                	div    %ecx
  801387:	89 c6                	mov    %eax,%esi
  801389:	89 e8                	mov    %ebp,%eax
  80138b:	89 f7                	mov    %esi,%edi
  80138d:	f7 f1                	div    %ecx
  80138f:	89 fa                	mov    %edi,%edx
  801391:	83 c4 1c             	add    $0x1c,%esp
  801394:	5b                   	pop    %ebx
  801395:	5e                   	pop    %esi
  801396:	5f                   	pop    %edi
  801397:	5d                   	pop    %ebp
  801398:	c3                   	ret    
  801399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013a0:	89 f9                	mov    %edi,%ecx
  8013a2:	b8 20 00 00 00       	mov    $0x20,%eax
  8013a7:	29 f8                	sub    %edi,%eax
  8013a9:	d3 e2                	shl    %cl,%edx
  8013ab:	89 54 24 08          	mov    %edx,0x8(%esp)
  8013af:	89 c1                	mov    %eax,%ecx
  8013b1:	89 da                	mov    %ebx,%edx
  8013b3:	d3 ea                	shr    %cl,%edx
  8013b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8013b9:	09 d1                	or     %edx,%ecx
  8013bb:	89 f2                	mov    %esi,%edx
  8013bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013c1:	89 f9                	mov    %edi,%ecx
  8013c3:	d3 e3                	shl    %cl,%ebx
  8013c5:	89 c1                	mov    %eax,%ecx
  8013c7:	d3 ea                	shr    %cl,%edx
  8013c9:	89 f9                	mov    %edi,%ecx
  8013cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8013cf:	89 eb                	mov    %ebp,%ebx
  8013d1:	d3 e6                	shl    %cl,%esi
  8013d3:	89 c1                	mov    %eax,%ecx
  8013d5:	d3 eb                	shr    %cl,%ebx
  8013d7:	09 de                	or     %ebx,%esi
  8013d9:	89 f0                	mov    %esi,%eax
  8013db:	f7 74 24 08          	divl   0x8(%esp)
  8013df:	89 d6                	mov    %edx,%esi
  8013e1:	89 c3                	mov    %eax,%ebx
  8013e3:	f7 64 24 0c          	mull   0xc(%esp)
  8013e7:	39 d6                	cmp    %edx,%esi
  8013e9:	72 15                	jb     801400 <__udivdi3+0x100>
  8013eb:	89 f9                	mov    %edi,%ecx
  8013ed:	d3 e5                	shl    %cl,%ebp
  8013ef:	39 c5                	cmp    %eax,%ebp
  8013f1:	73 04                	jae    8013f7 <__udivdi3+0xf7>
  8013f3:	39 d6                	cmp    %edx,%esi
  8013f5:	74 09                	je     801400 <__udivdi3+0x100>
  8013f7:	89 d8                	mov    %ebx,%eax
  8013f9:	31 ff                	xor    %edi,%edi
  8013fb:	e9 40 ff ff ff       	jmp    801340 <__udivdi3+0x40>
  801400:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801403:	31 ff                	xor    %edi,%edi
  801405:	e9 36 ff ff ff       	jmp    801340 <__udivdi3+0x40>
  80140a:	66 90                	xchg   %ax,%ax
  80140c:	66 90                	xchg   %ax,%ax
  80140e:	66 90                	xchg   %ax,%ax

00801410 <__umoddi3>:
  801410:	f3 0f 1e fb          	endbr32 
  801414:	55                   	push   %ebp
  801415:	57                   	push   %edi
  801416:	56                   	push   %esi
  801417:	53                   	push   %ebx
  801418:	83 ec 1c             	sub    $0x1c,%esp
  80141b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80141f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801423:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801427:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80142b:	85 c0                	test   %eax,%eax
  80142d:	75 19                	jne    801448 <__umoddi3+0x38>
  80142f:	39 df                	cmp    %ebx,%edi
  801431:	76 5d                	jbe    801490 <__umoddi3+0x80>
  801433:	89 f0                	mov    %esi,%eax
  801435:	89 da                	mov    %ebx,%edx
  801437:	f7 f7                	div    %edi
  801439:	89 d0                	mov    %edx,%eax
  80143b:	31 d2                	xor    %edx,%edx
  80143d:	83 c4 1c             	add    $0x1c,%esp
  801440:	5b                   	pop    %ebx
  801441:	5e                   	pop    %esi
  801442:	5f                   	pop    %edi
  801443:	5d                   	pop    %ebp
  801444:	c3                   	ret    
  801445:	8d 76 00             	lea    0x0(%esi),%esi
  801448:	89 f2                	mov    %esi,%edx
  80144a:	39 d8                	cmp    %ebx,%eax
  80144c:	76 12                	jbe    801460 <__umoddi3+0x50>
  80144e:	89 f0                	mov    %esi,%eax
  801450:	89 da                	mov    %ebx,%edx
  801452:	83 c4 1c             	add    $0x1c,%esp
  801455:	5b                   	pop    %ebx
  801456:	5e                   	pop    %esi
  801457:	5f                   	pop    %edi
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    
  80145a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801460:	0f bd e8             	bsr    %eax,%ebp
  801463:	83 f5 1f             	xor    $0x1f,%ebp
  801466:	75 50                	jne    8014b8 <__umoddi3+0xa8>
  801468:	39 d8                	cmp    %ebx,%eax
  80146a:	0f 82 e0 00 00 00    	jb     801550 <__umoddi3+0x140>
  801470:	89 d9                	mov    %ebx,%ecx
  801472:	39 f7                	cmp    %esi,%edi
  801474:	0f 86 d6 00 00 00    	jbe    801550 <__umoddi3+0x140>
  80147a:	89 d0                	mov    %edx,%eax
  80147c:	89 ca                	mov    %ecx,%edx
  80147e:	83 c4 1c             	add    $0x1c,%esp
  801481:	5b                   	pop    %ebx
  801482:	5e                   	pop    %esi
  801483:	5f                   	pop    %edi
  801484:	5d                   	pop    %ebp
  801485:	c3                   	ret    
  801486:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80148d:	8d 76 00             	lea    0x0(%esi),%esi
  801490:	89 fd                	mov    %edi,%ebp
  801492:	85 ff                	test   %edi,%edi
  801494:	75 0b                	jne    8014a1 <__umoddi3+0x91>
  801496:	b8 01 00 00 00       	mov    $0x1,%eax
  80149b:	31 d2                	xor    %edx,%edx
  80149d:	f7 f7                	div    %edi
  80149f:	89 c5                	mov    %eax,%ebp
  8014a1:	89 d8                	mov    %ebx,%eax
  8014a3:	31 d2                	xor    %edx,%edx
  8014a5:	f7 f5                	div    %ebp
  8014a7:	89 f0                	mov    %esi,%eax
  8014a9:	f7 f5                	div    %ebp
  8014ab:	89 d0                	mov    %edx,%eax
  8014ad:	31 d2                	xor    %edx,%edx
  8014af:	eb 8c                	jmp    80143d <__umoddi3+0x2d>
  8014b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014b8:	89 e9                	mov    %ebp,%ecx
  8014ba:	ba 20 00 00 00       	mov    $0x20,%edx
  8014bf:	29 ea                	sub    %ebp,%edx
  8014c1:	d3 e0                	shl    %cl,%eax
  8014c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014c7:	89 d1                	mov    %edx,%ecx
  8014c9:	89 f8                	mov    %edi,%eax
  8014cb:	d3 e8                	shr    %cl,%eax
  8014cd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8014d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014d5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8014d9:	09 c1                	or     %eax,%ecx
  8014db:	89 d8                	mov    %ebx,%eax
  8014dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014e1:	89 e9                	mov    %ebp,%ecx
  8014e3:	d3 e7                	shl    %cl,%edi
  8014e5:	89 d1                	mov    %edx,%ecx
  8014e7:	d3 e8                	shr    %cl,%eax
  8014e9:	89 e9                	mov    %ebp,%ecx
  8014eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014ef:	d3 e3                	shl    %cl,%ebx
  8014f1:	89 c7                	mov    %eax,%edi
  8014f3:	89 d1                	mov    %edx,%ecx
  8014f5:	89 f0                	mov    %esi,%eax
  8014f7:	d3 e8                	shr    %cl,%eax
  8014f9:	89 e9                	mov    %ebp,%ecx
  8014fb:	89 fa                	mov    %edi,%edx
  8014fd:	d3 e6                	shl    %cl,%esi
  8014ff:	09 d8                	or     %ebx,%eax
  801501:	f7 74 24 08          	divl   0x8(%esp)
  801505:	89 d1                	mov    %edx,%ecx
  801507:	89 f3                	mov    %esi,%ebx
  801509:	f7 64 24 0c          	mull   0xc(%esp)
  80150d:	89 c6                	mov    %eax,%esi
  80150f:	89 d7                	mov    %edx,%edi
  801511:	39 d1                	cmp    %edx,%ecx
  801513:	72 06                	jb     80151b <__umoddi3+0x10b>
  801515:	75 10                	jne    801527 <__umoddi3+0x117>
  801517:	39 c3                	cmp    %eax,%ebx
  801519:	73 0c                	jae    801527 <__umoddi3+0x117>
  80151b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80151f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801523:	89 d7                	mov    %edx,%edi
  801525:	89 c6                	mov    %eax,%esi
  801527:	89 ca                	mov    %ecx,%edx
  801529:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80152e:	29 f3                	sub    %esi,%ebx
  801530:	19 fa                	sbb    %edi,%edx
  801532:	89 d0                	mov    %edx,%eax
  801534:	d3 e0                	shl    %cl,%eax
  801536:	89 e9                	mov    %ebp,%ecx
  801538:	d3 eb                	shr    %cl,%ebx
  80153a:	d3 ea                	shr    %cl,%edx
  80153c:	09 d8                	or     %ebx,%eax
  80153e:	83 c4 1c             	add    $0x1c,%esp
  801541:	5b                   	pop    %ebx
  801542:	5e                   	pop    %esi
  801543:	5f                   	pop    %edi
  801544:	5d                   	pop    %ebp
  801545:	c3                   	ret    
  801546:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80154d:	8d 76 00             	lea    0x0(%esi),%esi
  801550:	29 fe                	sub    %edi,%esi
  801552:	19 c3                	sbb    %eax,%ebx
  801554:	89 f2                	mov    %esi,%edx
  801556:	89 d9                	mov    %ebx,%ecx
  801558:	e9 1d ff ff ff       	jmp    80147a <__umoddi3+0x6a>
