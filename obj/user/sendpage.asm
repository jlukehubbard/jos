
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
  80003d:	e8 bf 0f 00 00       	call   801001 <fork>
  800042:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	0f 84 b1 00 00 00    	je     8000fe <umain+0xcb>
        cprintf("child sent\n");
		return;
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80004d:	a1 04 40 80 00       	mov    0x804004,%eax
  800052:	8b 40 48             	mov    0x48(%eax),%eax
  800055:	83 ec 04             	sub    $0x4,%esp
  800058:	6a 07                	push   $0x7
  80005a:	68 00 00 a0 00       	push   $0xa00000
  80005f:	50                   	push   %eax
  800060:	e8 b6 0c 00 00       	call   800d1b <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800065:	83 c4 04             	add    $0x4,%esp
  800068:	ff 35 04 30 80 00    	pushl  0x803004
  80006e:	e8 23 08 00 00       	call   800896 <strlen>
  800073:	83 c4 0c             	add    $0xc,%esp
  800076:	83 c0 01             	add    $0x1,%eax
  800079:	50                   	push   %eax
  80007a:	ff 35 04 30 80 00    	pushl  0x803004
  800080:	68 00 00 a0 00       	push   $0xa00000
  800085:	e8 6b 0a 00 00       	call   800af5 <memcpy>
    cprintf("parent sent\n");
  80008a:	c7 04 24 40 23 80 00 	movl   $0x802340,(%esp)
  800091:	e8 3a 02 00 00       	call   8002d0 <cprintf>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800096:	6a 07                	push   $0x7
  800098:	68 00 00 a0 00       	push   $0xa00000
  80009d:	6a 00                	push   $0x0
  80009f:	ff 75 f4             	pushl  -0xc(%ebp)
  8000a2:	e8 1d 11 00 00       	call   8011c4 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  8000a7:	83 c4 1c             	add    $0x1c,%esp
  8000aa:	6a 00                	push   $0x0
  8000ac:	68 00 00 a0 00       	push   $0xa00000
  8000b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b4:	50                   	push   %eax
  8000b5:	e8 b3 10 00 00       	call   80116d <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	68 00 00 a0 00       	push   $0xa00000
  8000c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8000c5:	68 20 23 80 00       	push   $0x802320
  8000ca:	e8 01 02 00 00       	call   8002d0 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8000cf:	83 c4 04             	add    $0x4,%esp
  8000d2:	ff 35 00 30 80 00    	pushl  0x803000
  8000d8:	e8 b9 07 00 00       	call   800896 <strlen>
  8000dd:	83 c4 0c             	add    $0xc,%esp
  8000e0:	50                   	push   %eax
  8000e1:	ff 35 00 30 80 00    	pushl  0x803000
  8000e7:	68 00 00 a0 00       	push   $0xa00000
  8000ec:	e8 d1 08 00 00       	call   8009c2 <strncmp>
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
  80010c:	e8 5c 10 00 00       	call   80116d <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800111:	83 c4 0c             	add    $0xc,%esp
  800114:	68 00 00 b0 00       	push   $0xb00000
  800119:	ff 75 f4             	pushl  -0xc(%ebp)
  80011c:	68 20 23 80 00       	push   $0x802320
  800121:	e8 aa 01 00 00       	call   8002d0 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800126:	83 c4 04             	add    $0x4,%esp
  800129:	ff 35 04 30 80 00    	pushl  0x803004
  80012f:	e8 62 07 00 00       	call   800896 <strlen>
  800134:	83 c4 0c             	add    $0xc,%esp
  800137:	50                   	push   %eax
  800138:	ff 35 04 30 80 00    	pushl  0x803004
  80013e:	68 00 00 b0 00       	push   $0xb00000
  800143:	e8 7a 08 00 00       	call   8009c2 <strncmp>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	85 c0                	test   %eax,%eax
  80014d:	74 4b                	je     80019a <umain+0x167>
		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	ff 35 00 30 80 00    	pushl  0x803000
  800158:	e8 39 07 00 00       	call   800896 <strlen>
  80015d:	83 c4 0c             	add    $0xc,%esp
  800160:	83 c0 01             	add    $0x1,%eax
  800163:	50                   	push   %eax
  800164:	ff 35 00 30 80 00    	pushl  0x803000
  80016a:	68 00 00 b0 00       	push   $0xb00000
  80016f:	e8 81 09 00 00       	call   800af5 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  800174:	6a 07                	push   $0x7
  800176:	68 00 00 b0 00       	push   $0xb00000
  80017b:	6a 00                	push   $0x0
  80017d:	ff 75 f4             	pushl  -0xc(%ebp)
  800180:	e8 3f 10 00 00       	call   8011c4 <ipc_send>
        cprintf("child sent\n");
  800185:	83 c4 14             	add    $0x14,%esp
  800188:	68 34 23 80 00       	push   $0x802334
  80018d:	e8 3e 01 00 00       	call   8002d0 <cprintf>
		return;
  800192:	83 c4 10             	add    $0x10,%esp
  800195:	e9 62 ff ff ff       	jmp    8000fc <umain+0xc9>
			cprintf("child received correct message\n");
  80019a:	83 ec 0c             	sub    $0xc,%esp
  80019d:	68 50 23 80 00       	push   $0x802350
  8001a2:	e8 29 01 00 00       	call   8002d0 <cprintf>
  8001a7:	83 c4 10             	add    $0x10,%esp
  8001aa:	eb a3                	jmp    80014f <umain+0x11c>
		cprintf("parent received correct message\n");
  8001ac:	83 ec 0c             	sub    $0xc,%esp
  8001af:	68 70 23 80 00       	push   $0x802370
  8001b4:	e8 17 01 00 00       	call   8002d0 <cprintf>
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
	thisenv = 0;
  8001d0:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8001d7:	00 00 00 
    envid_t envid = sys_getenvid();
  8001da:	e8 f6 0a 00 00       	call   800cd5 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8001df:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001e7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001ec:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f1:	85 db                	test   %ebx,%ebx
  8001f3:	7e 07                	jle    8001fc <libmain+0x3b>
		binaryname = argv[0];
  8001f5:	8b 06                	mov    (%esi),%eax
  8001f7:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001fc:	83 ec 08             	sub    $0x8,%esp
  8001ff:	56                   	push   %esi
  800200:	53                   	push   %ebx
  800201:	e8 2d fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800206:	e8 0a 00 00 00       	call   800215 <exit>
}
  80020b:	83 c4 10             	add    $0x10,%esp
  80020e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800211:	5b                   	pop    %ebx
  800212:	5e                   	pop    %esi
  800213:	5d                   	pop    %ebp
  800214:	c3                   	ret    

00800215 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800215:	f3 0f 1e fb          	endbr32 
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80021f:	e8 32 12 00 00       	call   801456 <close_all>
	sys_env_destroy(0);
  800224:	83 ec 0c             	sub    $0xc,%esp
  800227:	6a 00                	push   $0x0
  800229:	e8 62 0a 00 00       	call   800c90 <sys_env_destroy>
}
  80022e:	83 c4 10             	add    $0x10,%esp
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800233:	f3 0f 1e fb          	endbr32 
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	53                   	push   %ebx
  80023b:	83 ec 04             	sub    $0x4,%esp
  80023e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800241:	8b 13                	mov    (%ebx),%edx
  800243:	8d 42 01             	lea    0x1(%edx),%eax
  800246:	89 03                	mov    %eax,(%ebx)
  800248:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80024b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80024f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800254:	74 09                	je     80025f <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800256:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80025d:	c9                   	leave  
  80025e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80025f:	83 ec 08             	sub    $0x8,%esp
  800262:	68 ff 00 00 00       	push   $0xff
  800267:	8d 43 08             	lea    0x8(%ebx),%eax
  80026a:	50                   	push   %eax
  80026b:	e8 db 09 00 00       	call   800c4b <sys_cputs>
		b->idx = 0;
  800270:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800276:	83 c4 10             	add    $0x10,%esp
  800279:	eb db                	jmp    800256 <putch+0x23>

0080027b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80027b:	f3 0f 1e fb          	endbr32 
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800288:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80028f:	00 00 00 
	b.cnt = 0;
  800292:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800299:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80029c:	ff 75 0c             	pushl  0xc(%ebp)
  80029f:	ff 75 08             	pushl  0x8(%ebp)
  8002a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002a8:	50                   	push   %eax
  8002a9:	68 33 02 80 00       	push   $0x800233
  8002ae:	e8 20 01 00 00       	call   8003d3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002b3:	83 c4 08             	add    $0x8,%esp
  8002b6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002bc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002c2:	50                   	push   %eax
  8002c3:	e8 83 09 00 00       	call   800c4b <sys_cputs>

	return b.cnt;
}
  8002c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ce:	c9                   	leave  
  8002cf:	c3                   	ret    

008002d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002d0:	f3 0f 1e fb          	endbr32 
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002dd:	50                   	push   %eax
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	e8 95 ff ff ff       	call   80027b <vcprintf>
	va_end(ap);

	return cnt;
}
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	57                   	push   %edi
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
  8002ee:	83 ec 1c             	sub    $0x1c,%esp
  8002f1:	89 c7                	mov    %eax,%edi
  8002f3:	89 d6                	mov    %edx,%esi
  8002f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002fb:	89 d1                	mov    %edx,%ecx
  8002fd:	89 c2                	mov    %eax,%edx
  8002ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800302:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800305:	8b 45 10             	mov    0x10(%ebp),%eax
  800308:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80030b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80030e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800315:	39 c2                	cmp    %eax,%edx
  800317:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80031a:	72 3e                	jb     80035a <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80031c:	83 ec 0c             	sub    $0xc,%esp
  80031f:	ff 75 18             	pushl  0x18(%ebp)
  800322:	83 eb 01             	sub    $0x1,%ebx
  800325:	53                   	push   %ebx
  800326:	50                   	push   %eax
  800327:	83 ec 08             	sub    $0x8,%esp
  80032a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80032d:	ff 75 e0             	pushl  -0x20(%ebp)
  800330:	ff 75 dc             	pushl  -0x24(%ebp)
  800333:	ff 75 d8             	pushl  -0x28(%ebp)
  800336:	e8 75 1d 00 00       	call   8020b0 <__udivdi3>
  80033b:	83 c4 18             	add    $0x18,%esp
  80033e:	52                   	push   %edx
  80033f:	50                   	push   %eax
  800340:	89 f2                	mov    %esi,%edx
  800342:	89 f8                	mov    %edi,%eax
  800344:	e8 9f ff ff ff       	call   8002e8 <printnum>
  800349:	83 c4 20             	add    $0x20,%esp
  80034c:	eb 13                	jmp    800361 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80034e:	83 ec 08             	sub    $0x8,%esp
  800351:	56                   	push   %esi
  800352:	ff 75 18             	pushl  0x18(%ebp)
  800355:	ff d7                	call   *%edi
  800357:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80035a:	83 eb 01             	sub    $0x1,%ebx
  80035d:	85 db                	test   %ebx,%ebx
  80035f:	7f ed                	jg     80034e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800361:	83 ec 08             	sub    $0x8,%esp
  800364:	56                   	push   %esi
  800365:	83 ec 04             	sub    $0x4,%esp
  800368:	ff 75 e4             	pushl  -0x1c(%ebp)
  80036b:	ff 75 e0             	pushl  -0x20(%ebp)
  80036e:	ff 75 dc             	pushl  -0x24(%ebp)
  800371:	ff 75 d8             	pushl  -0x28(%ebp)
  800374:	e8 47 1e 00 00       	call   8021c0 <__umoddi3>
  800379:	83 c4 14             	add    $0x14,%esp
  80037c:	0f be 80 e8 23 80 00 	movsbl 0x8023e8(%eax),%eax
  800383:	50                   	push   %eax
  800384:	ff d7                	call   *%edi
}
  800386:	83 c4 10             	add    $0x10,%esp
  800389:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80038c:	5b                   	pop    %ebx
  80038d:	5e                   	pop    %esi
  80038e:	5f                   	pop    %edi
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800391:	f3 0f 1e fb          	endbr32 
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80039b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80039f:	8b 10                	mov    (%eax),%edx
  8003a1:	3b 50 04             	cmp    0x4(%eax),%edx
  8003a4:	73 0a                	jae    8003b0 <sprintputch+0x1f>
		*b->buf++ = ch;
  8003a6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003a9:	89 08                	mov    %ecx,(%eax)
  8003ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ae:	88 02                	mov    %al,(%edx)
}
  8003b0:	5d                   	pop    %ebp
  8003b1:	c3                   	ret    

008003b2 <printfmt>:
{
  8003b2:	f3 0f 1e fb          	endbr32 
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003bc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003bf:	50                   	push   %eax
  8003c0:	ff 75 10             	pushl  0x10(%ebp)
  8003c3:	ff 75 0c             	pushl  0xc(%ebp)
  8003c6:	ff 75 08             	pushl  0x8(%ebp)
  8003c9:	e8 05 00 00 00       	call   8003d3 <vprintfmt>
}
  8003ce:	83 c4 10             	add    $0x10,%esp
  8003d1:	c9                   	leave  
  8003d2:	c3                   	ret    

008003d3 <vprintfmt>:
{
  8003d3:	f3 0f 1e fb          	endbr32 
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
  8003da:	57                   	push   %edi
  8003db:	56                   	push   %esi
  8003dc:	53                   	push   %ebx
  8003dd:	83 ec 3c             	sub    $0x3c,%esp
  8003e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8003e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003e6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003e9:	e9 4a 03 00 00       	jmp    800738 <vprintfmt+0x365>
		padc = ' ';
  8003ee:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003f2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003f9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800400:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800407:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8d 47 01             	lea    0x1(%edi),%eax
  80040f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800412:	0f b6 17             	movzbl (%edi),%edx
  800415:	8d 42 dd             	lea    -0x23(%edx),%eax
  800418:	3c 55                	cmp    $0x55,%al
  80041a:	0f 87 de 03 00 00    	ja     8007fe <vprintfmt+0x42b>
  800420:	0f b6 c0             	movzbl %al,%eax
  800423:	3e ff 24 85 20 25 80 	notrack jmp *0x802520(,%eax,4)
  80042a:	00 
  80042b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80042e:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800432:	eb d8                	jmp    80040c <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800434:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800437:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80043b:	eb cf                	jmp    80040c <vprintfmt+0x39>
  80043d:	0f b6 d2             	movzbl %dl,%edx
  800440:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800443:	b8 00 00 00 00       	mov    $0x0,%eax
  800448:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80044b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80044e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800452:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800455:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800458:	83 f9 09             	cmp    $0x9,%ecx
  80045b:	77 55                	ja     8004b2 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80045d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800460:	eb e9                	jmp    80044b <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800462:	8b 45 14             	mov    0x14(%ebp),%eax
  800465:	8b 00                	mov    (%eax),%eax
  800467:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80046a:	8b 45 14             	mov    0x14(%ebp),%eax
  80046d:	8d 40 04             	lea    0x4(%eax),%eax
  800470:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800476:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047a:	79 90                	jns    80040c <vprintfmt+0x39>
				width = precision, precision = -1;
  80047c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80047f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800482:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800489:	eb 81                	jmp    80040c <vprintfmt+0x39>
  80048b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80048e:	85 c0                	test   %eax,%eax
  800490:	ba 00 00 00 00       	mov    $0x0,%edx
  800495:	0f 49 d0             	cmovns %eax,%edx
  800498:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80049e:	e9 69 ff ff ff       	jmp    80040c <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8004a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004a6:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004ad:	e9 5a ff ff ff       	jmp    80040c <vprintfmt+0x39>
  8004b2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b8:	eb bc                	jmp    800476 <vprintfmt+0xa3>
			lflag++;
  8004ba:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004c0:	e9 47 ff ff ff       	jmp    80040c <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8004c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c8:	8d 78 04             	lea    0x4(%eax),%edi
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	53                   	push   %ebx
  8004cf:	ff 30                	pushl  (%eax)
  8004d1:	ff d6                	call   *%esi
			break;
  8004d3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004d6:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004d9:	e9 57 02 00 00       	jmp    800735 <vprintfmt+0x362>
			err = va_arg(ap, int);
  8004de:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e1:	8d 78 04             	lea    0x4(%eax),%edi
  8004e4:	8b 00                	mov    (%eax),%eax
  8004e6:	99                   	cltd   
  8004e7:	31 d0                	xor    %edx,%eax
  8004e9:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004eb:	83 f8 0f             	cmp    $0xf,%eax
  8004ee:	7f 23                	jg     800513 <vprintfmt+0x140>
  8004f0:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  8004f7:	85 d2                	test   %edx,%edx
  8004f9:	74 18                	je     800513 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8004fb:	52                   	push   %edx
  8004fc:	68 b2 28 80 00       	push   $0x8028b2
  800501:	53                   	push   %ebx
  800502:	56                   	push   %esi
  800503:	e8 aa fe ff ff       	call   8003b2 <printfmt>
  800508:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80050b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80050e:	e9 22 02 00 00       	jmp    800735 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800513:	50                   	push   %eax
  800514:	68 00 24 80 00       	push   $0x802400
  800519:	53                   	push   %ebx
  80051a:	56                   	push   %esi
  80051b:	e8 92 fe ff ff       	call   8003b2 <printfmt>
  800520:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800523:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800526:	e9 0a 02 00 00       	jmp    800735 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	83 c0 04             	add    $0x4,%eax
  800531:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800539:	85 d2                	test   %edx,%edx
  80053b:	b8 f9 23 80 00       	mov    $0x8023f9,%eax
  800540:	0f 45 c2             	cmovne %edx,%eax
  800543:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800546:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80054a:	7e 06                	jle    800552 <vprintfmt+0x17f>
  80054c:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800550:	75 0d                	jne    80055f <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800552:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800555:	89 c7                	mov    %eax,%edi
  800557:	03 45 e0             	add    -0x20(%ebp),%eax
  80055a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055d:	eb 55                	jmp    8005b4 <vprintfmt+0x1e1>
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	ff 75 d8             	pushl  -0x28(%ebp)
  800565:	ff 75 cc             	pushl  -0x34(%ebp)
  800568:	e8 45 03 00 00       	call   8008b2 <strnlen>
  80056d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800570:	29 c2                	sub    %eax,%edx
  800572:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80057a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80057e:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800581:	85 ff                	test   %edi,%edi
  800583:	7e 11                	jle    800596 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800585:	83 ec 08             	sub    $0x8,%esp
  800588:	53                   	push   %ebx
  800589:	ff 75 e0             	pushl  -0x20(%ebp)
  80058c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80058e:	83 ef 01             	sub    $0x1,%edi
  800591:	83 c4 10             	add    $0x10,%esp
  800594:	eb eb                	jmp    800581 <vprintfmt+0x1ae>
  800596:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800599:	85 d2                	test   %edx,%edx
  80059b:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a0:	0f 49 c2             	cmovns %edx,%eax
  8005a3:	29 c2                	sub    %eax,%edx
  8005a5:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005a8:	eb a8                	jmp    800552 <vprintfmt+0x17f>
					putch(ch, putdat);
  8005aa:	83 ec 08             	sub    $0x8,%esp
  8005ad:	53                   	push   %ebx
  8005ae:	52                   	push   %edx
  8005af:	ff d6                	call   *%esi
  8005b1:	83 c4 10             	add    $0x10,%esp
  8005b4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005b7:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b9:	83 c7 01             	add    $0x1,%edi
  8005bc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005c0:	0f be d0             	movsbl %al,%edx
  8005c3:	85 d2                	test   %edx,%edx
  8005c5:	74 4b                	je     800612 <vprintfmt+0x23f>
  8005c7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005cb:	78 06                	js     8005d3 <vprintfmt+0x200>
  8005cd:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005d1:	78 1e                	js     8005f1 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8005d3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005d7:	74 d1                	je     8005aa <vprintfmt+0x1d7>
  8005d9:	0f be c0             	movsbl %al,%eax
  8005dc:	83 e8 20             	sub    $0x20,%eax
  8005df:	83 f8 5e             	cmp    $0x5e,%eax
  8005e2:	76 c6                	jbe    8005aa <vprintfmt+0x1d7>
					putch('?', putdat);
  8005e4:	83 ec 08             	sub    $0x8,%esp
  8005e7:	53                   	push   %ebx
  8005e8:	6a 3f                	push   $0x3f
  8005ea:	ff d6                	call   *%esi
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	eb c3                	jmp    8005b4 <vprintfmt+0x1e1>
  8005f1:	89 cf                	mov    %ecx,%edi
  8005f3:	eb 0e                	jmp    800603 <vprintfmt+0x230>
				putch(' ', putdat);
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	53                   	push   %ebx
  8005f9:	6a 20                	push   $0x20
  8005fb:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005fd:	83 ef 01             	sub    $0x1,%edi
  800600:	83 c4 10             	add    $0x10,%esp
  800603:	85 ff                	test   %edi,%edi
  800605:	7f ee                	jg     8005f5 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800607:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80060a:	89 45 14             	mov    %eax,0x14(%ebp)
  80060d:	e9 23 01 00 00       	jmp    800735 <vprintfmt+0x362>
  800612:	89 cf                	mov    %ecx,%edi
  800614:	eb ed                	jmp    800603 <vprintfmt+0x230>
	if (lflag >= 2)
  800616:	83 f9 01             	cmp    $0x1,%ecx
  800619:	7f 1b                	jg     800636 <vprintfmt+0x263>
	else if (lflag)
  80061b:	85 c9                	test   %ecx,%ecx
  80061d:	74 63                	je     800682 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8b 00                	mov    (%eax),%eax
  800624:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800627:	99                   	cltd   
  800628:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8d 40 04             	lea    0x4(%eax),%eax
  800631:	89 45 14             	mov    %eax,0x14(%ebp)
  800634:	eb 17                	jmp    80064d <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8b 50 04             	mov    0x4(%eax),%edx
  80063c:	8b 00                	mov    (%eax),%eax
  80063e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800641:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 40 08             	lea    0x8(%eax),%eax
  80064a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80064d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800650:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800653:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800658:	85 c9                	test   %ecx,%ecx
  80065a:	0f 89 bb 00 00 00    	jns    80071b <vprintfmt+0x348>
				putch('-', putdat);
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	53                   	push   %ebx
  800664:	6a 2d                	push   $0x2d
  800666:	ff d6                	call   *%esi
				num = -(long long) num;
  800668:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80066b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80066e:	f7 da                	neg    %edx
  800670:	83 d1 00             	adc    $0x0,%ecx
  800673:	f7 d9                	neg    %ecx
  800675:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800678:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067d:	e9 99 00 00 00       	jmp    80071b <vprintfmt+0x348>
		return va_arg(*ap, int);
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8b 00                	mov    (%eax),%eax
  800687:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068a:	99                   	cltd   
  80068b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8d 40 04             	lea    0x4(%eax),%eax
  800694:	89 45 14             	mov    %eax,0x14(%ebp)
  800697:	eb b4                	jmp    80064d <vprintfmt+0x27a>
	if (lflag >= 2)
  800699:	83 f9 01             	cmp    $0x1,%ecx
  80069c:	7f 1b                	jg     8006b9 <vprintfmt+0x2e6>
	else if (lflag)
  80069e:	85 c9                	test   %ecx,%ecx
  8006a0:	74 2c                	je     8006ce <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8b 10                	mov    (%eax),%edx
  8006a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ac:	8d 40 04             	lea    0x4(%eax),%eax
  8006af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006b2:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8006b7:	eb 62                	jmp    80071b <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	8b 10                	mov    (%eax),%edx
  8006be:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c1:	8d 40 08             	lea    0x8(%eax),%eax
  8006c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c7:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8006cc:	eb 4d                	jmp    80071b <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8b 10                	mov    (%eax),%edx
  8006d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d8:	8d 40 04             	lea    0x4(%eax),%eax
  8006db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006de:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8006e3:	eb 36                	jmp    80071b <vprintfmt+0x348>
	if (lflag >= 2)
  8006e5:	83 f9 01             	cmp    $0x1,%ecx
  8006e8:	7f 17                	jg     800701 <vprintfmt+0x32e>
	else if (lflag)
  8006ea:	85 c9                	test   %ecx,%ecx
  8006ec:	74 6e                	je     80075c <vprintfmt+0x389>
		return va_arg(*ap, long);
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8b 10                	mov    (%eax),%edx
  8006f3:	89 d0                	mov    %edx,%eax
  8006f5:	99                   	cltd   
  8006f6:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006f9:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006fc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006ff:	eb 11                	jmp    800712 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8b 50 04             	mov    0x4(%eax),%edx
  800707:	8b 00                	mov    (%eax),%eax
  800709:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80070c:	8d 49 08             	lea    0x8(%ecx),%ecx
  80070f:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800712:	89 d1                	mov    %edx,%ecx
  800714:	89 c2                	mov    %eax,%edx
            base = 8;
  800716:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80071b:	83 ec 0c             	sub    $0xc,%esp
  80071e:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800722:	57                   	push   %edi
  800723:	ff 75 e0             	pushl  -0x20(%ebp)
  800726:	50                   	push   %eax
  800727:	51                   	push   %ecx
  800728:	52                   	push   %edx
  800729:	89 da                	mov    %ebx,%edx
  80072b:	89 f0                	mov    %esi,%eax
  80072d:	e8 b6 fb ff ff       	call   8002e8 <printnum>
			break;
  800732:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800735:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800738:	83 c7 01             	add    $0x1,%edi
  80073b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80073f:	83 f8 25             	cmp    $0x25,%eax
  800742:	0f 84 a6 fc ff ff    	je     8003ee <vprintfmt+0x1b>
			if (ch == '\0')
  800748:	85 c0                	test   %eax,%eax
  80074a:	0f 84 ce 00 00 00    	je     80081e <vprintfmt+0x44b>
			putch(ch, putdat);
  800750:	83 ec 08             	sub    $0x8,%esp
  800753:	53                   	push   %ebx
  800754:	50                   	push   %eax
  800755:	ff d6                	call   *%esi
  800757:	83 c4 10             	add    $0x10,%esp
  80075a:	eb dc                	jmp    800738 <vprintfmt+0x365>
		return va_arg(*ap, int);
  80075c:	8b 45 14             	mov    0x14(%ebp),%eax
  80075f:	8b 10                	mov    (%eax),%edx
  800761:	89 d0                	mov    %edx,%eax
  800763:	99                   	cltd   
  800764:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800767:	8d 49 04             	lea    0x4(%ecx),%ecx
  80076a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80076d:	eb a3                	jmp    800712 <vprintfmt+0x33f>
			putch('0', putdat);
  80076f:	83 ec 08             	sub    $0x8,%esp
  800772:	53                   	push   %ebx
  800773:	6a 30                	push   $0x30
  800775:	ff d6                	call   *%esi
			putch('x', putdat);
  800777:	83 c4 08             	add    $0x8,%esp
  80077a:	53                   	push   %ebx
  80077b:	6a 78                	push   $0x78
  80077d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	8b 10                	mov    (%eax),%edx
  800784:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800789:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80078c:	8d 40 04             	lea    0x4(%eax),%eax
  80078f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800792:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800797:	eb 82                	jmp    80071b <vprintfmt+0x348>
	if (lflag >= 2)
  800799:	83 f9 01             	cmp    $0x1,%ecx
  80079c:	7f 1e                	jg     8007bc <vprintfmt+0x3e9>
	else if (lflag)
  80079e:	85 c9                	test   %ecx,%ecx
  8007a0:	74 32                	je     8007d4 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  8007a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a5:	8b 10                	mov    (%eax),%edx
  8007a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ac:	8d 40 04             	lea    0x4(%eax),%eax
  8007af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b2:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8007b7:	e9 5f ff ff ff       	jmp    80071b <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8007bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bf:	8b 10                	mov    (%eax),%edx
  8007c1:	8b 48 04             	mov    0x4(%eax),%ecx
  8007c4:	8d 40 08             	lea    0x8(%eax),%eax
  8007c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ca:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8007cf:	e9 47 ff ff ff       	jmp    80071b <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	8b 10                	mov    (%eax),%edx
  8007d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007de:	8d 40 04             	lea    0x4(%eax),%eax
  8007e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007e4:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8007e9:	e9 2d ff ff ff       	jmp    80071b <vprintfmt+0x348>
			putch(ch, putdat);
  8007ee:	83 ec 08             	sub    $0x8,%esp
  8007f1:	53                   	push   %ebx
  8007f2:	6a 25                	push   $0x25
  8007f4:	ff d6                	call   *%esi
			break;
  8007f6:	83 c4 10             	add    $0x10,%esp
  8007f9:	e9 37 ff ff ff       	jmp    800735 <vprintfmt+0x362>
			putch('%', putdat);
  8007fe:	83 ec 08             	sub    $0x8,%esp
  800801:	53                   	push   %ebx
  800802:	6a 25                	push   $0x25
  800804:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	89 f8                	mov    %edi,%eax
  80080b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80080f:	74 05                	je     800816 <vprintfmt+0x443>
  800811:	83 e8 01             	sub    $0x1,%eax
  800814:	eb f5                	jmp    80080b <vprintfmt+0x438>
  800816:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800819:	e9 17 ff ff ff       	jmp    800735 <vprintfmt+0x362>
}
  80081e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800821:	5b                   	pop    %ebx
  800822:	5e                   	pop    %esi
  800823:	5f                   	pop    %edi
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800826:	f3 0f 1e fb          	endbr32 
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	83 ec 18             	sub    $0x18,%esp
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800836:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800839:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80083d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800840:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800847:	85 c0                	test   %eax,%eax
  800849:	74 26                	je     800871 <vsnprintf+0x4b>
  80084b:	85 d2                	test   %edx,%edx
  80084d:	7e 22                	jle    800871 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80084f:	ff 75 14             	pushl  0x14(%ebp)
  800852:	ff 75 10             	pushl  0x10(%ebp)
  800855:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800858:	50                   	push   %eax
  800859:	68 91 03 80 00       	push   $0x800391
  80085e:	e8 70 fb ff ff       	call   8003d3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800863:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800866:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800869:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80086c:	83 c4 10             	add    $0x10,%esp
}
  80086f:	c9                   	leave  
  800870:	c3                   	ret    
		return -E_INVAL;
  800871:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800876:	eb f7                	jmp    80086f <vsnprintf+0x49>

00800878 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800878:	f3 0f 1e fb          	endbr32 
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800882:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800885:	50                   	push   %eax
  800886:	ff 75 10             	pushl  0x10(%ebp)
  800889:	ff 75 0c             	pushl  0xc(%ebp)
  80088c:	ff 75 08             	pushl  0x8(%ebp)
  80088f:	e8 92 ff ff ff       	call   800826 <vsnprintf>
	va_end(ap);

	return rc;
}
  800894:	c9                   	leave  
  800895:	c3                   	ret    

00800896 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800896:	f3 0f 1e fb          	endbr32 
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a9:	74 05                	je     8008b0 <strlen+0x1a>
		n++;
  8008ab:	83 c0 01             	add    $0x1,%eax
  8008ae:	eb f5                	jmp    8008a5 <strlen+0xf>
	return n;
}
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b2:	f3 0f 1e fb          	endbr32 
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c4:	39 d0                	cmp    %edx,%eax
  8008c6:	74 0d                	je     8008d5 <strnlen+0x23>
  8008c8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008cc:	74 05                	je     8008d3 <strnlen+0x21>
		n++;
  8008ce:	83 c0 01             	add    $0x1,%eax
  8008d1:	eb f1                	jmp    8008c4 <strnlen+0x12>
  8008d3:	89 c2                	mov    %eax,%edx
	return n;
}
  8008d5:	89 d0                	mov    %edx,%eax
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008d9:	f3 0f 1e fb          	endbr32 
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	53                   	push   %ebx
  8008e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ec:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008f0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008f3:	83 c0 01             	add    $0x1,%eax
  8008f6:	84 d2                	test   %dl,%dl
  8008f8:	75 f2                	jne    8008ec <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8008fa:	89 c8                	mov    %ecx,%eax
  8008fc:	5b                   	pop    %ebx
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ff:	f3 0f 1e fb          	endbr32 
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	53                   	push   %ebx
  800907:	83 ec 10             	sub    $0x10,%esp
  80090a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80090d:	53                   	push   %ebx
  80090e:	e8 83 ff ff ff       	call   800896 <strlen>
  800913:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800916:	ff 75 0c             	pushl  0xc(%ebp)
  800919:	01 d8                	add    %ebx,%eax
  80091b:	50                   	push   %eax
  80091c:	e8 b8 ff ff ff       	call   8008d9 <strcpy>
	return dst;
}
  800921:	89 d8                	mov    %ebx,%eax
  800923:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800926:	c9                   	leave  
  800927:	c3                   	ret    

00800928 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800928:	f3 0f 1e fb          	endbr32 
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	56                   	push   %esi
  800930:	53                   	push   %ebx
  800931:	8b 75 08             	mov    0x8(%ebp),%esi
  800934:	8b 55 0c             	mov    0xc(%ebp),%edx
  800937:	89 f3                	mov    %esi,%ebx
  800939:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80093c:	89 f0                	mov    %esi,%eax
  80093e:	39 d8                	cmp    %ebx,%eax
  800940:	74 11                	je     800953 <strncpy+0x2b>
		*dst++ = *src;
  800942:	83 c0 01             	add    $0x1,%eax
  800945:	0f b6 0a             	movzbl (%edx),%ecx
  800948:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80094b:	80 f9 01             	cmp    $0x1,%cl
  80094e:	83 da ff             	sbb    $0xffffffff,%edx
  800951:	eb eb                	jmp    80093e <strncpy+0x16>
	}
	return ret;
}
  800953:	89 f0                	mov    %esi,%eax
  800955:	5b                   	pop    %ebx
  800956:	5e                   	pop    %esi
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800959:	f3 0f 1e fb          	endbr32 
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	56                   	push   %esi
  800961:	53                   	push   %ebx
  800962:	8b 75 08             	mov    0x8(%ebp),%esi
  800965:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800968:	8b 55 10             	mov    0x10(%ebp),%edx
  80096b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80096d:	85 d2                	test   %edx,%edx
  80096f:	74 21                	je     800992 <strlcpy+0x39>
  800971:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800975:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800977:	39 c2                	cmp    %eax,%edx
  800979:	74 14                	je     80098f <strlcpy+0x36>
  80097b:	0f b6 19             	movzbl (%ecx),%ebx
  80097e:	84 db                	test   %bl,%bl
  800980:	74 0b                	je     80098d <strlcpy+0x34>
			*dst++ = *src++;
  800982:	83 c1 01             	add    $0x1,%ecx
  800985:	83 c2 01             	add    $0x1,%edx
  800988:	88 5a ff             	mov    %bl,-0x1(%edx)
  80098b:	eb ea                	jmp    800977 <strlcpy+0x1e>
  80098d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80098f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800992:	29 f0                	sub    %esi,%eax
}
  800994:	5b                   	pop    %ebx
  800995:	5e                   	pop    %esi
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800998:	f3 0f 1e fb          	endbr32 
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a5:	0f b6 01             	movzbl (%ecx),%eax
  8009a8:	84 c0                	test   %al,%al
  8009aa:	74 0c                	je     8009b8 <strcmp+0x20>
  8009ac:	3a 02                	cmp    (%edx),%al
  8009ae:	75 08                	jne    8009b8 <strcmp+0x20>
		p++, q++;
  8009b0:	83 c1 01             	add    $0x1,%ecx
  8009b3:	83 c2 01             	add    $0x1,%edx
  8009b6:	eb ed                	jmp    8009a5 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b8:	0f b6 c0             	movzbl %al,%eax
  8009bb:	0f b6 12             	movzbl (%edx),%edx
  8009be:	29 d0                	sub    %edx,%eax
}
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c2:	f3 0f 1e fb          	endbr32 
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	53                   	push   %ebx
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d0:	89 c3                	mov    %eax,%ebx
  8009d2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009d5:	eb 06                	jmp    8009dd <strncmp+0x1b>
		n--, p++, q++;
  8009d7:	83 c0 01             	add    $0x1,%eax
  8009da:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009dd:	39 d8                	cmp    %ebx,%eax
  8009df:	74 16                	je     8009f7 <strncmp+0x35>
  8009e1:	0f b6 08             	movzbl (%eax),%ecx
  8009e4:	84 c9                	test   %cl,%cl
  8009e6:	74 04                	je     8009ec <strncmp+0x2a>
  8009e8:	3a 0a                	cmp    (%edx),%cl
  8009ea:	74 eb                	je     8009d7 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ec:	0f b6 00             	movzbl (%eax),%eax
  8009ef:	0f b6 12             	movzbl (%edx),%edx
  8009f2:	29 d0                	sub    %edx,%eax
}
  8009f4:	5b                   	pop    %ebx
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    
		return 0;
  8009f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fc:	eb f6                	jmp    8009f4 <strncmp+0x32>

008009fe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009fe:	f3 0f 1e fb          	endbr32 
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a0c:	0f b6 10             	movzbl (%eax),%edx
  800a0f:	84 d2                	test   %dl,%dl
  800a11:	74 09                	je     800a1c <strchr+0x1e>
		if (*s == c)
  800a13:	38 ca                	cmp    %cl,%dl
  800a15:	74 0a                	je     800a21 <strchr+0x23>
	for (; *s; s++)
  800a17:	83 c0 01             	add    $0x1,%eax
  800a1a:	eb f0                	jmp    800a0c <strchr+0xe>
			return (char *) s;
	return 0;
  800a1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a23:	f3 0f 1e fb          	endbr32 
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a31:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a34:	38 ca                	cmp    %cl,%dl
  800a36:	74 09                	je     800a41 <strfind+0x1e>
  800a38:	84 d2                	test   %dl,%dl
  800a3a:	74 05                	je     800a41 <strfind+0x1e>
	for (; *s; s++)
  800a3c:	83 c0 01             	add    $0x1,%eax
  800a3f:	eb f0                	jmp    800a31 <strfind+0xe>
			break;
	return (char *) s;
}
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a43:	f3 0f 1e fb          	endbr32 
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	57                   	push   %edi
  800a4b:	56                   	push   %esi
  800a4c:	53                   	push   %ebx
  800a4d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a50:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a53:	85 c9                	test   %ecx,%ecx
  800a55:	74 31                	je     800a88 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a57:	89 f8                	mov    %edi,%eax
  800a59:	09 c8                	or     %ecx,%eax
  800a5b:	a8 03                	test   $0x3,%al
  800a5d:	75 23                	jne    800a82 <memset+0x3f>
		c &= 0xFF;
  800a5f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a63:	89 d3                	mov    %edx,%ebx
  800a65:	c1 e3 08             	shl    $0x8,%ebx
  800a68:	89 d0                	mov    %edx,%eax
  800a6a:	c1 e0 18             	shl    $0x18,%eax
  800a6d:	89 d6                	mov    %edx,%esi
  800a6f:	c1 e6 10             	shl    $0x10,%esi
  800a72:	09 f0                	or     %esi,%eax
  800a74:	09 c2                	or     %eax,%edx
  800a76:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a78:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a7b:	89 d0                	mov    %edx,%eax
  800a7d:	fc                   	cld    
  800a7e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a80:	eb 06                	jmp    800a88 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a85:	fc                   	cld    
  800a86:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a88:	89 f8                	mov    %edi,%eax
  800a8a:	5b                   	pop    %ebx
  800a8b:	5e                   	pop    %esi
  800a8c:	5f                   	pop    %edi
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    

00800a8f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a8f:	f3 0f 1e fb          	endbr32 
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	57                   	push   %edi
  800a97:	56                   	push   %esi
  800a98:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa1:	39 c6                	cmp    %eax,%esi
  800aa3:	73 32                	jae    800ad7 <memmove+0x48>
  800aa5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa8:	39 c2                	cmp    %eax,%edx
  800aaa:	76 2b                	jbe    800ad7 <memmove+0x48>
		s += n;
		d += n;
  800aac:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aaf:	89 fe                	mov    %edi,%esi
  800ab1:	09 ce                	or     %ecx,%esi
  800ab3:	09 d6                	or     %edx,%esi
  800ab5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800abb:	75 0e                	jne    800acb <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800abd:	83 ef 04             	sub    $0x4,%edi
  800ac0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ac6:	fd                   	std    
  800ac7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac9:	eb 09                	jmp    800ad4 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800acb:	83 ef 01             	sub    $0x1,%edi
  800ace:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ad1:	fd                   	std    
  800ad2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ad4:	fc                   	cld    
  800ad5:	eb 1a                	jmp    800af1 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad7:	89 c2                	mov    %eax,%edx
  800ad9:	09 ca                	or     %ecx,%edx
  800adb:	09 f2                	or     %esi,%edx
  800add:	f6 c2 03             	test   $0x3,%dl
  800ae0:	75 0a                	jne    800aec <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ae2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ae5:	89 c7                	mov    %eax,%edi
  800ae7:	fc                   	cld    
  800ae8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aea:	eb 05                	jmp    800af1 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800aec:	89 c7                	mov    %eax,%edi
  800aee:	fc                   	cld    
  800aef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800af1:	5e                   	pop    %esi
  800af2:	5f                   	pop    %edi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800af5:	f3 0f 1e fb          	endbr32 
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aff:	ff 75 10             	pushl  0x10(%ebp)
  800b02:	ff 75 0c             	pushl  0xc(%ebp)
  800b05:	ff 75 08             	pushl  0x8(%ebp)
  800b08:	e8 82 ff ff ff       	call   800a8f <memmove>
}
  800b0d:	c9                   	leave  
  800b0e:	c3                   	ret    

00800b0f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b0f:	f3 0f 1e fb          	endbr32 
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	56                   	push   %esi
  800b17:	53                   	push   %ebx
  800b18:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1e:	89 c6                	mov    %eax,%esi
  800b20:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b23:	39 f0                	cmp    %esi,%eax
  800b25:	74 1c                	je     800b43 <memcmp+0x34>
		if (*s1 != *s2)
  800b27:	0f b6 08             	movzbl (%eax),%ecx
  800b2a:	0f b6 1a             	movzbl (%edx),%ebx
  800b2d:	38 d9                	cmp    %bl,%cl
  800b2f:	75 08                	jne    800b39 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b31:	83 c0 01             	add    $0x1,%eax
  800b34:	83 c2 01             	add    $0x1,%edx
  800b37:	eb ea                	jmp    800b23 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800b39:	0f b6 c1             	movzbl %cl,%eax
  800b3c:	0f b6 db             	movzbl %bl,%ebx
  800b3f:	29 d8                	sub    %ebx,%eax
  800b41:	eb 05                	jmp    800b48 <memcmp+0x39>
	}

	return 0;
  800b43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b4c:	f3 0f 1e fb          	endbr32 
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	8b 45 08             	mov    0x8(%ebp),%eax
  800b56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b59:	89 c2                	mov    %eax,%edx
  800b5b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b5e:	39 d0                	cmp    %edx,%eax
  800b60:	73 09                	jae    800b6b <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b62:	38 08                	cmp    %cl,(%eax)
  800b64:	74 05                	je     800b6b <memfind+0x1f>
	for (; s < ends; s++)
  800b66:	83 c0 01             	add    $0x1,%eax
  800b69:	eb f3                	jmp    800b5e <memfind+0x12>
			break;
	return (void *) s;
}
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b6d:	f3 0f 1e fb          	endbr32 
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b7d:	eb 03                	jmp    800b82 <strtol+0x15>
		s++;
  800b7f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b82:	0f b6 01             	movzbl (%ecx),%eax
  800b85:	3c 20                	cmp    $0x20,%al
  800b87:	74 f6                	je     800b7f <strtol+0x12>
  800b89:	3c 09                	cmp    $0x9,%al
  800b8b:	74 f2                	je     800b7f <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b8d:	3c 2b                	cmp    $0x2b,%al
  800b8f:	74 2a                	je     800bbb <strtol+0x4e>
	int neg = 0;
  800b91:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b96:	3c 2d                	cmp    $0x2d,%al
  800b98:	74 2b                	je     800bc5 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b9a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ba0:	75 0f                	jne    800bb1 <strtol+0x44>
  800ba2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ba5:	74 28                	je     800bcf <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ba7:	85 db                	test   %ebx,%ebx
  800ba9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bae:	0f 44 d8             	cmove  %eax,%ebx
  800bb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb6:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bb9:	eb 46                	jmp    800c01 <strtol+0x94>
		s++;
  800bbb:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bbe:	bf 00 00 00 00       	mov    $0x0,%edi
  800bc3:	eb d5                	jmp    800b9a <strtol+0x2d>
		s++, neg = 1;
  800bc5:	83 c1 01             	add    $0x1,%ecx
  800bc8:	bf 01 00 00 00       	mov    $0x1,%edi
  800bcd:	eb cb                	jmp    800b9a <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bcf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bd3:	74 0e                	je     800be3 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bd5:	85 db                	test   %ebx,%ebx
  800bd7:	75 d8                	jne    800bb1 <strtol+0x44>
		s++, base = 8;
  800bd9:	83 c1 01             	add    $0x1,%ecx
  800bdc:	bb 08 00 00 00       	mov    $0x8,%ebx
  800be1:	eb ce                	jmp    800bb1 <strtol+0x44>
		s += 2, base = 16;
  800be3:	83 c1 02             	add    $0x2,%ecx
  800be6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800beb:	eb c4                	jmp    800bb1 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bed:	0f be d2             	movsbl %dl,%edx
  800bf0:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bf3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bf6:	7d 3a                	jge    800c32 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bf8:	83 c1 01             	add    $0x1,%ecx
  800bfb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bff:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c01:	0f b6 11             	movzbl (%ecx),%edx
  800c04:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c07:	89 f3                	mov    %esi,%ebx
  800c09:	80 fb 09             	cmp    $0x9,%bl
  800c0c:	76 df                	jbe    800bed <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800c0e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c11:	89 f3                	mov    %esi,%ebx
  800c13:	80 fb 19             	cmp    $0x19,%bl
  800c16:	77 08                	ja     800c20 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c18:	0f be d2             	movsbl %dl,%edx
  800c1b:	83 ea 57             	sub    $0x57,%edx
  800c1e:	eb d3                	jmp    800bf3 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800c20:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c23:	89 f3                	mov    %esi,%ebx
  800c25:	80 fb 19             	cmp    $0x19,%bl
  800c28:	77 08                	ja     800c32 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c2a:	0f be d2             	movsbl %dl,%edx
  800c2d:	83 ea 37             	sub    $0x37,%edx
  800c30:	eb c1                	jmp    800bf3 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c32:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c36:	74 05                	je     800c3d <strtol+0xd0>
		*endptr = (char *) s;
  800c38:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c3b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c3d:	89 c2                	mov    %eax,%edx
  800c3f:	f7 da                	neg    %edx
  800c41:	85 ff                	test   %edi,%edi
  800c43:	0f 45 c2             	cmovne %edx,%eax
}
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c4b:	f3 0f 1e fb          	endbr32 
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c55:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c60:	89 c3                	mov    %eax,%ebx
  800c62:	89 c7                	mov    %eax,%edi
  800c64:	89 c6                	mov    %eax,%esi
  800c66:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <sys_cgetc>:

int
sys_cgetc(void)
{
  800c6d:	f3 0f 1e fb          	endbr32 
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	57                   	push   %edi
  800c75:	56                   	push   %esi
  800c76:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c77:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7c:	b8 01 00 00 00       	mov    $0x1,%eax
  800c81:	89 d1                	mov    %edx,%ecx
  800c83:	89 d3                	mov    %edx,%ebx
  800c85:	89 d7                	mov    %edx,%edi
  800c87:	89 d6                	mov    %edx,%esi
  800c89:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c90:	f3 0f 1e fb          	endbr32 
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca5:	b8 03 00 00 00       	mov    $0x3,%eax
  800caa:	89 cb                	mov    %ecx,%ebx
  800cac:	89 cf                	mov    %ecx,%edi
  800cae:	89 ce                	mov    %ecx,%esi
  800cb0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb2:	85 c0                	test   %eax,%eax
  800cb4:	7f 08                	jg     800cbe <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbe:	83 ec 0c             	sub    $0xc,%esp
  800cc1:	50                   	push   %eax
  800cc2:	6a 03                	push   $0x3
  800cc4:	68 df 26 80 00       	push   $0x8026df
  800cc9:	6a 23                	push   $0x23
  800ccb:	68 fc 26 80 00       	push   $0x8026fc
  800cd0:	e8 ab 12 00 00       	call   801f80 <_panic>

00800cd5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cd5:	f3 0f 1e fb          	endbr32 
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cdf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce4:	b8 02 00 00 00       	mov    $0x2,%eax
  800ce9:	89 d1                	mov    %edx,%ecx
  800ceb:	89 d3                	mov    %edx,%ebx
  800ced:	89 d7                	mov    %edx,%edi
  800cef:	89 d6                	mov    %edx,%esi
  800cf1:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <sys_yield>:

void
sys_yield(void)
{
  800cf8:	f3 0f 1e fb          	endbr32 
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	57                   	push   %edi
  800d00:	56                   	push   %esi
  800d01:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d02:	ba 00 00 00 00       	mov    $0x0,%edx
  800d07:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d0c:	89 d1                	mov    %edx,%ecx
  800d0e:	89 d3                	mov    %edx,%ebx
  800d10:	89 d7                	mov    %edx,%edi
  800d12:	89 d6                	mov    %edx,%esi
  800d14:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d1b:	f3 0f 1e fb          	endbr32 
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	57                   	push   %edi
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
  800d25:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d28:	be 00 00 00 00       	mov    $0x0,%esi
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	b8 04 00 00 00       	mov    $0x4,%eax
  800d38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3b:	89 f7                	mov    %esi,%edi
  800d3d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	7f 08                	jg     800d4b <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	50                   	push   %eax
  800d4f:	6a 04                	push   $0x4
  800d51:	68 df 26 80 00       	push   $0x8026df
  800d56:	6a 23                	push   $0x23
  800d58:	68 fc 26 80 00       	push   $0x8026fc
  800d5d:	e8 1e 12 00 00       	call   801f80 <_panic>

00800d62 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d62:	f3 0f 1e fb          	endbr32 
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
  800d6c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d75:	b8 05 00 00 00       	mov    $0x5,%eax
  800d7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d80:	8b 75 18             	mov    0x18(%ebp),%esi
  800d83:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d85:	85 c0                	test   %eax,%eax
  800d87:	7f 08                	jg     800d91 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d91:	83 ec 0c             	sub    $0xc,%esp
  800d94:	50                   	push   %eax
  800d95:	6a 05                	push   $0x5
  800d97:	68 df 26 80 00       	push   $0x8026df
  800d9c:	6a 23                	push   $0x23
  800d9e:	68 fc 26 80 00       	push   $0x8026fc
  800da3:	e8 d8 11 00 00       	call   801f80 <_panic>

00800da8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800da8:	f3 0f 1e fb          	endbr32 
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	57                   	push   %edi
  800db0:	56                   	push   %esi
  800db1:	53                   	push   %ebx
  800db2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dba:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc0:	b8 06 00 00 00       	mov    $0x6,%eax
  800dc5:	89 df                	mov    %ebx,%edi
  800dc7:	89 de                	mov    %ebx,%esi
  800dc9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	7f 08                	jg     800dd7 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd2:	5b                   	pop    %ebx
  800dd3:	5e                   	pop    %esi
  800dd4:	5f                   	pop    %edi
  800dd5:	5d                   	pop    %ebp
  800dd6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd7:	83 ec 0c             	sub    $0xc,%esp
  800dda:	50                   	push   %eax
  800ddb:	6a 06                	push   $0x6
  800ddd:	68 df 26 80 00       	push   $0x8026df
  800de2:	6a 23                	push   $0x23
  800de4:	68 fc 26 80 00       	push   $0x8026fc
  800de9:	e8 92 11 00 00       	call   801f80 <_panic>

00800dee <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dee:	f3 0f 1e fb          	endbr32 
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e00:	8b 55 08             	mov    0x8(%ebp),%edx
  800e03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e06:	b8 08 00 00 00       	mov    $0x8,%eax
  800e0b:	89 df                	mov    %ebx,%edi
  800e0d:	89 de                	mov    %ebx,%esi
  800e0f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e11:	85 c0                	test   %eax,%eax
  800e13:	7f 08                	jg     800e1d <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e18:	5b                   	pop    %ebx
  800e19:	5e                   	pop    %esi
  800e1a:	5f                   	pop    %edi
  800e1b:	5d                   	pop    %ebp
  800e1c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1d:	83 ec 0c             	sub    $0xc,%esp
  800e20:	50                   	push   %eax
  800e21:	6a 08                	push   $0x8
  800e23:	68 df 26 80 00       	push   $0x8026df
  800e28:	6a 23                	push   $0x23
  800e2a:	68 fc 26 80 00       	push   $0x8026fc
  800e2f:	e8 4c 11 00 00       	call   801f80 <_panic>

00800e34 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e34:	f3 0f 1e fb          	endbr32 
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	57                   	push   %edi
  800e3c:	56                   	push   %esi
  800e3d:	53                   	push   %ebx
  800e3e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e41:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e46:	8b 55 08             	mov    0x8(%ebp),%edx
  800e49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4c:	b8 09 00 00 00       	mov    $0x9,%eax
  800e51:	89 df                	mov    %ebx,%edi
  800e53:	89 de                	mov    %ebx,%esi
  800e55:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e57:	85 c0                	test   %eax,%eax
  800e59:	7f 08                	jg     800e63 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5e:	5b                   	pop    %ebx
  800e5f:	5e                   	pop    %esi
  800e60:	5f                   	pop    %edi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e63:	83 ec 0c             	sub    $0xc,%esp
  800e66:	50                   	push   %eax
  800e67:	6a 09                	push   $0x9
  800e69:	68 df 26 80 00       	push   $0x8026df
  800e6e:	6a 23                	push   $0x23
  800e70:	68 fc 26 80 00       	push   $0x8026fc
  800e75:	e8 06 11 00 00       	call   801f80 <_panic>

00800e7a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e7a:	f3 0f 1e fb          	endbr32 
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	57                   	push   %edi
  800e82:	56                   	push   %esi
  800e83:	53                   	push   %ebx
  800e84:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e87:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e92:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e97:	89 df                	mov    %ebx,%edi
  800e99:	89 de                	mov    %ebx,%esi
  800e9b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	7f 08                	jg     800ea9 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ea1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea9:	83 ec 0c             	sub    $0xc,%esp
  800eac:	50                   	push   %eax
  800ead:	6a 0a                	push   $0xa
  800eaf:	68 df 26 80 00       	push   $0x8026df
  800eb4:	6a 23                	push   $0x23
  800eb6:	68 fc 26 80 00       	push   $0x8026fc
  800ebb:	e8 c0 10 00 00       	call   801f80 <_panic>

00800ec0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ec0:	f3 0f 1e fb          	endbr32 
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	57                   	push   %edi
  800ec8:	56                   	push   %esi
  800ec9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ed5:	be 00 00 00 00       	mov    $0x0,%esi
  800eda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800edd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ee0:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ee2:	5b                   	pop    %ebx
  800ee3:	5e                   	pop    %esi
  800ee4:	5f                   	pop    %edi
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ee7:	f3 0f 1e fb          	endbr32 
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	57                   	push   %edi
  800eef:	56                   	push   %esi
  800ef0:	53                   	push   %ebx
  800ef1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ef4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ef9:	8b 55 08             	mov    0x8(%ebp),%edx
  800efc:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f01:	89 cb                	mov    %ecx,%ebx
  800f03:	89 cf                	mov    %ecx,%edi
  800f05:	89 ce                	mov    %ecx,%esi
  800f07:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	7f 08                	jg     800f15 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f10:	5b                   	pop    %ebx
  800f11:	5e                   	pop    %esi
  800f12:	5f                   	pop    %edi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f15:	83 ec 0c             	sub    $0xc,%esp
  800f18:	50                   	push   %eax
  800f19:	6a 0d                	push   $0xd
  800f1b:	68 df 26 80 00       	push   $0x8026df
  800f20:	6a 23                	push   $0x23
  800f22:	68 fc 26 80 00       	push   $0x8026fc
  800f27:	e8 54 10 00 00       	call   801f80 <_panic>

00800f2c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f2c:	f3 0f 1e fb          	endbr32 
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	53                   	push   %ebx
  800f34:	83 ec 04             	sub    $0x4,%esp
  800f37:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f3a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if ( !(err & FEC_WR) ||
  800f3c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f40:	74 75                	je     800fb7 <pgfault+0x8b>
            !(uvpt[PGNUM(addr)] | PTE_COW) ) {
  800f42:	89 d8                	mov    %ebx,%eax
  800f44:	c1 e8 0c             	shr    $0xc,%eax
  800f47:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0) {
  800f4e:	83 ec 04             	sub    $0x4,%esp
  800f51:	6a 07                	push   $0x7
  800f53:	68 00 f0 7f 00       	push   $0x7ff000
  800f58:	6a 00                	push   $0x0
  800f5a:	e8 bc fd ff ff       	call   800d1b <sys_page_alloc>
  800f5f:	83 c4 10             	add    $0x10,%esp
  800f62:	85 c0                	test   %eax,%eax
  800f64:	78 65                	js     800fcb <pgfault+0x9f>
        panic("sys_page_alloc failed %e\n", r);
    }
    memmove((void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);
  800f66:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800f6c:	83 ec 04             	sub    $0x4,%esp
  800f6f:	68 00 10 00 00       	push   $0x1000
  800f74:	53                   	push   %ebx
  800f75:	68 00 f0 7f 00       	push   $0x7ff000
  800f7a:	e8 10 fb ff ff       	call   800a8f <memmove>
    if ((r = sys_page_map(0, (void *)PFTEMP,
  800f7f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f86:	53                   	push   %ebx
  800f87:	6a 00                	push   $0x0
  800f89:	68 00 f0 7f 00       	push   $0x7ff000
  800f8e:	6a 00                	push   $0x0
  800f90:	e8 cd fd ff ff       	call   800d62 <sys_page_map>
  800f95:	83 c4 20             	add    $0x20,%esp
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	78 41                	js     800fdd <pgfault+0xb1>
                0, (void *)PTE_ADDR(addr), PTE_P | PTE_U | PTE_W)) < 0) {
        panic("sys_page_map failed %e\n", r);
    }
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0) {
  800f9c:	83 ec 08             	sub    $0x8,%esp
  800f9f:	68 00 f0 7f 00       	push   $0x7ff000
  800fa4:	6a 00                	push   $0x0
  800fa6:	e8 fd fd ff ff       	call   800da8 <sys_page_unmap>
  800fab:	83 c4 10             	add    $0x10,%esp
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	78 3d                	js     800fef <pgfault+0xc3>
        panic("sys_page_unmap failed %e\n", r);
    }

}
  800fb2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb5:	c9                   	leave  
  800fb6:	c3                   	ret    
        panic("Not a copy-on-write page");
  800fb7:	83 ec 04             	sub    $0x4,%esp
  800fba:	68 0a 27 80 00       	push   $0x80270a
  800fbf:	6a 1e                	push   $0x1e
  800fc1:	68 23 27 80 00       	push   $0x802723
  800fc6:	e8 b5 0f 00 00       	call   801f80 <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800fcb:	50                   	push   %eax
  800fcc:	68 2e 27 80 00       	push   $0x80272e
  800fd1:	6a 2a                	push   $0x2a
  800fd3:	68 23 27 80 00       	push   $0x802723
  800fd8:	e8 a3 0f 00 00       	call   801f80 <_panic>
        panic("sys_page_map failed %e\n", r);
  800fdd:	50                   	push   %eax
  800fde:	68 48 27 80 00       	push   $0x802748
  800fe3:	6a 2f                	push   $0x2f
  800fe5:	68 23 27 80 00       	push   $0x802723
  800fea:	e8 91 0f 00 00       	call   801f80 <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800fef:	50                   	push   %eax
  800ff0:	68 60 27 80 00       	push   $0x802760
  800ff5:	6a 32                	push   $0x32
  800ff7:	68 23 27 80 00       	push   $0x802723
  800ffc:	e8 7f 0f 00 00       	call   801f80 <_panic>

00801001 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801001:	f3 0f 1e fb          	endbr32 
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
  801008:	57                   	push   %edi
  801009:	56                   	push   %esi
  80100a:	53                   	push   %ebx
  80100b:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");

    // 1. set pgfault handler.
    set_pgfault_handler(pgfault);
  80100e:	68 2c 0f 80 00       	push   $0x800f2c
  801013:	e8 b2 0f 00 00       	call   801fca <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801018:	b8 07 00 00 00       	mov    $0x7,%eax
  80101d:	cd 30                	int    $0x30
  80101f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801022:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 2. exofork.
    envid_t envid = sys_exofork();

    if (envid < 0)
  801025:	83 c4 10             	add    $0x10,%esp
  801028:	85 c0                	test   %eax,%eax
  80102a:	78 2a                	js     801056 <fork+0x55>
        thisenv = &envs[ENVX(my_envid)];
        return 0;
    }
    else {
        // parent
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  80102c:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  801031:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801035:	75 4e                	jne    801085 <fork+0x84>
        envid_t my_envid = sys_getenvid();
  801037:	e8 99 fc ff ff       	call   800cd5 <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  80103c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801041:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801044:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801049:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  80104e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801051:	e9 f1 00 00 00       	jmp    801147 <fork+0x146>
        panic("fork, sys_exofork %e", envid);
  801056:	50                   	push   %eax
  801057:	68 7a 27 80 00       	push   $0x80277a
  80105c:	6a 7b                	push   $0x7b
  80105e:	68 23 27 80 00       	push   $0x802723
  801063:	e8 18 0f 00 00       	call   801f80 <_panic>
        panic("sys_page_map others failed %e\n", r);
  801068:	50                   	push   %eax
  801069:	68 c4 27 80 00       	push   $0x8027c4
  80106e:	6a 51                	push   $0x51
  801070:	68 23 27 80 00       	push   $0x802723
  801075:	e8 06 0f 00 00       	call   801f80 <_panic>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  80107a:	83 c3 01             	add    $0x1,%ebx
  80107d:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801083:	74 7c                	je     801101 <fork+0x100>
  801085:	89 de                	mov    %ebx,%esi
  801087:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  80108a:	89 f0                	mov    %esi,%eax
  80108c:	c1 e8 16             	shr    $0x16,%eax
  80108f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801096:	a8 01                	test   $0x1,%al
  801098:	74 e0                	je     80107a <fork+0x79>
                    (uvpt[pn] & PTE_P) ) {
  80109a:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  8010a1:	a8 01                	test   $0x1,%al
  8010a3:	74 d5                	je     80107a <fork+0x79>
    pte_t pte = uvpt[pn];
  8010a5:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    if ( (pte & PTE_W) || (pte & PTE_COW) ) {
  8010ac:	25 02 08 00 00       	and    $0x802,%eax
        perm |= PTE_COW;
  8010b1:	83 f8 01             	cmp    $0x1,%eax
  8010b4:	19 ff                	sbb    %edi,%edi
  8010b6:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  8010bc:	81 c7 05 08 00 00    	add    $0x805,%edi
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  8010c2:	83 ec 0c             	sub    $0xc,%esp
  8010c5:	57                   	push   %edi
  8010c6:	56                   	push   %esi
  8010c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ca:	56                   	push   %esi
  8010cb:	6a 00                	push   $0x0
  8010cd:	e8 90 fc ff ff       	call   800d62 <sys_page_map>
  8010d2:	83 c4 20             	add    $0x20,%esp
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	78 8f                	js     801068 <fork+0x67>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  8010d9:	83 ec 0c             	sub    $0xc,%esp
  8010dc:	57                   	push   %edi
  8010dd:	56                   	push   %esi
  8010de:	6a 00                	push   $0x0
  8010e0:	56                   	push   %esi
  8010e1:	6a 00                	push   $0x0
  8010e3:	e8 7a fc ff ff       	call   800d62 <sys_page_map>
  8010e8:	83 c4 20             	add    $0x20,%esp
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	79 8b                	jns    80107a <fork+0x79>
            panic("sys_page_map mine failed %e\n", r);
  8010ef:	50                   	push   %eax
  8010f0:	68 8f 27 80 00       	push   $0x80278f
  8010f5:	6a 56                	push   $0x56
  8010f7:	68 23 27 80 00       	push   $0x802723
  8010fc:	e8 7f 0e 00 00       	call   801f80 <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  801101:	83 ec 04             	sub    $0x4,%esp
  801104:	6a 07                	push   $0x7
  801106:	68 00 f0 bf ee       	push   $0xeebff000
  80110b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80110e:	57                   	push   %edi
  80110f:	e8 07 fc ff ff       	call   800d1b <sys_page_alloc>
  801114:	83 c4 10             	add    $0x10,%esp
  801117:	85 c0                	test   %eax,%eax
  801119:	78 2c                	js     801147 <fork+0x146>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  80111b:	a1 04 40 80 00       	mov    0x804004,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  801120:	8b 40 64             	mov    0x64(%eax),%eax
  801123:	83 ec 08             	sub    $0x8,%esp
  801126:	50                   	push   %eax
  801127:	57                   	push   %edi
  801128:	e8 4d fd ff ff       	call   800e7a <sys_env_set_pgfault_upcall>
  80112d:	83 c4 10             	add    $0x10,%esp
  801130:	85 c0                	test   %eax,%eax
  801132:	78 13                	js     801147 <fork+0x146>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801134:	83 ec 08             	sub    $0x8,%esp
  801137:	6a 02                	push   $0x2
  801139:	57                   	push   %edi
  80113a:	e8 af fc ff ff       	call   800dee <sys_env_set_status>
  80113f:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  801142:	85 c0                	test   %eax,%eax
  801144:	0f 49 c7             	cmovns %edi,%eax
    }

}
  801147:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114a:	5b                   	pop    %ebx
  80114b:	5e                   	pop    %esi
  80114c:	5f                   	pop    %edi
  80114d:	5d                   	pop    %ebp
  80114e:	c3                   	ret    

0080114f <sfork>:

// Challenge!
int
sfork(void)
{
  80114f:	f3 0f 1e fb          	endbr32 
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801159:	68 ac 27 80 00       	push   $0x8027ac
  80115e:	68 a5 00 00 00       	push   $0xa5
  801163:	68 23 27 80 00       	push   $0x802723
  801168:	e8 13 0e 00 00       	call   801f80 <_panic>

0080116d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80116d:	f3 0f 1e fb          	endbr32 
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	56                   	push   %esi
  801175:	53                   	push   %ebx
  801176:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801179:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117c:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  80117f:	85 c0                	test   %eax,%eax
  801181:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801186:	0f 44 c2             	cmove  %edx,%eax
  801189:	83 ec 0c             	sub    $0xc,%esp
  80118c:	50                   	push   %eax
  80118d:	e8 55 fd ff ff       	call   800ee7 <sys_ipc_recv>
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	85 c0                	test   %eax,%eax
  801197:	78 24                	js     8011bd <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801199:	85 f6                	test   %esi,%esi
  80119b:	74 0a                	je     8011a7 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  80119d:	a1 04 40 80 00       	mov    0x804004,%eax
  8011a2:	8b 40 78             	mov    0x78(%eax),%eax
  8011a5:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  8011a7:	85 db                	test   %ebx,%ebx
  8011a9:	74 0a                	je     8011b5 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  8011ab:	a1 04 40 80 00       	mov    0x804004,%eax
  8011b0:	8b 40 74             	mov    0x74(%eax),%eax
  8011b3:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  8011b5:	a1 04 40 80 00       	mov    0x804004,%eax
  8011ba:	8b 40 70             	mov    0x70(%eax),%eax
}
  8011bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011c0:	5b                   	pop    %ebx
  8011c1:	5e                   	pop    %esi
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    

008011c4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011c4:	f3 0f 1e fb          	endbr32 
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	57                   	push   %edi
  8011cc:	56                   	push   %esi
  8011cd:	53                   	push   %ebx
  8011ce:	83 ec 1c             	sub    $0x1c,%esp
  8011d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d4:	85 c0                	test   %eax,%eax
  8011d6:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8011db:	0f 45 d0             	cmovne %eax,%edx
  8011de:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  8011e0:	be 01 00 00 00       	mov    $0x1,%esi
  8011e5:	eb 1f                	jmp    801206 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  8011e7:	e8 0c fb ff ff       	call   800cf8 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  8011ec:	83 c3 01             	add    $0x1,%ebx
  8011ef:	39 de                	cmp    %ebx,%esi
  8011f1:	7f f4                	jg     8011e7 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  8011f3:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  8011f5:	83 fe 11             	cmp    $0x11,%esi
  8011f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8011fd:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801200:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801204:	75 1c                	jne    801222 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801206:	ff 75 14             	pushl  0x14(%ebp)
  801209:	57                   	push   %edi
  80120a:	ff 75 0c             	pushl  0xc(%ebp)
  80120d:	ff 75 08             	pushl  0x8(%ebp)
  801210:	e8 ab fc ff ff       	call   800ec0 <sys_ipc_try_send>
  801215:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801220:	eb cd                	jmp    8011ef <ipc_send+0x2b>
}
  801222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801225:	5b                   	pop    %ebx
  801226:	5e                   	pop    %esi
  801227:	5f                   	pop    %edi
  801228:	5d                   	pop    %ebp
  801229:	c3                   	ret    

0080122a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80122a:	f3 0f 1e fb          	endbr32 
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801234:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801239:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80123c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801242:	8b 52 50             	mov    0x50(%edx),%edx
  801245:	39 ca                	cmp    %ecx,%edx
  801247:	74 11                	je     80125a <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801249:	83 c0 01             	add    $0x1,%eax
  80124c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801251:	75 e6                	jne    801239 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801253:	b8 00 00 00 00       	mov    $0x0,%eax
  801258:	eb 0b                	jmp    801265 <ipc_find_env+0x3b>
			return envs[i].env_id;
  80125a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80125d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801262:	8b 40 48             	mov    0x48(%eax),%eax
}
  801265:	5d                   	pop    %ebp
  801266:	c3                   	ret    

00801267 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801267:	f3 0f 1e fb          	endbr32 
  80126b:	55                   	push   %ebp
  80126c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80126e:	8b 45 08             	mov    0x8(%ebp),%eax
  801271:	05 00 00 00 30       	add    $0x30000000,%eax
  801276:	c1 e8 0c             	shr    $0xc,%eax
}
  801279:	5d                   	pop    %ebp
  80127a:	c3                   	ret    

0080127b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80127b:	f3 0f 1e fb          	endbr32 
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801282:	8b 45 08             	mov    0x8(%ebp),%eax
  801285:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80128a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80128f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801294:	5d                   	pop    %ebp
  801295:	c3                   	ret    

00801296 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801296:	f3 0f 1e fb          	endbr32 
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012a2:	89 c2                	mov    %eax,%edx
  8012a4:	c1 ea 16             	shr    $0x16,%edx
  8012a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ae:	f6 c2 01             	test   $0x1,%dl
  8012b1:	74 2d                	je     8012e0 <fd_alloc+0x4a>
  8012b3:	89 c2                	mov    %eax,%edx
  8012b5:	c1 ea 0c             	shr    $0xc,%edx
  8012b8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012bf:	f6 c2 01             	test   $0x1,%dl
  8012c2:	74 1c                	je     8012e0 <fd_alloc+0x4a>
  8012c4:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8012c9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012ce:	75 d2                	jne    8012a2 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8012d9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8012de:	eb 0a                	jmp    8012ea <fd_alloc+0x54>
			*fd_store = fd;
  8012e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ea:	5d                   	pop    %ebp
  8012eb:	c3                   	ret    

008012ec <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012ec:	f3 0f 1e fb          	endbr32 
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012f6:	83 f8 1f             	cmp    $0x1f,%eax
  8012f9:	77 30                	ja     80132b <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012fb:	c1 e0 0c             	shl    $0xc,%eax
  8012fe:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801303:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801309:	f6 c2 01             	test   $0x1,%dl
  80130c:	74 24                	je     801332 <fd_lookup+0x46>
  80130e:	89 c2                	mov    %eax,%edx
  801310:	c1 ea 0c             	shr    $0xc,%edx
  801313:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80131a:	f6 c2 01             	test   $0x1,%dl
  80131d:	74 1a                	je     801339 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80131f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801322:	89 02                	mov    %eax,(%edx)
	return 0;
  801324:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801329:	5d                   	pop    %ebp
  80132a:	c3                   	ret    
		return -E_INVAL;
  80132b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801330:	eb f7                	jmp    801329 <fd_lookup+0x3d>
		return -E_INVAL;
  801332:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801337:	eb f0                	jmp    801329 <fd_lookup+0x3d>
  801339:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80133e:	eb e9                	jmp    801329 <fd_lookup+0x3d>

00801340 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801340:	f3 0f 1e fb          	endbr32 
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	83 ec 08             	sub    $0x8,%esp
  80134a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80134d:	ba 60 28 80 00       	mov    $0x802860,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801352:	b8 0c 30 80 00       	mov    $0x80300c,%eax
		if (devtab[i]->dev_id == dev_id) {
  801357:	39 08                	cmp    %ecx,(%eax)
  801359:	74 33                	je     80138e <dev_lookup+0x4e>
  80135b:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80135e:	8b 02                	mov    (%edx),%eax
  801360:	85 c0                	test   %eax,%eax
  801362:	75 f3                	jne    801357 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801364:	a1 04 40 80 00       	mov    0x804004,%eax
  801369:	8b 40 48             	mov    0x48(%eax),%eax
  80136c:	83 ec 04             	sub    $0x4,%esp
  80136f:	51                   	push   %ecx
  801370:	50                   	push   %eax
  801371:	68 e4 27 80 00       	push   $0x8027e4
  801376:	e8 55 ef ff ff       	call   8002d0 <cprintf>
	*dev = 0;
  80137b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80137e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80138c:	c9                   	leave  
  80138d:	c3                   	ret    
			*dev = devtab[i];
  80138e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801391:	89 01                	mov    %eax,(%ecx)
			return 0;
  801393:	b8 00 00 00 00       	mov    $0x0,%eax
  801398:	eb f2                	jmp    80138c <dev_lookup+0x4c>

0080139a <fd_close>:
{
  80139a:	f3 0f 1e fb          	endbr32 
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	57                   	push   %edi
  8013a2:	56                   	push   %esi
  8013a3:	53                   	push   %ebx
  8013a4:	83 ec 24             	sub    $0x24,%esp
  8013a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8013aa:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013ad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013b0:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013b1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013b7:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013ba:	50                   	push   %eax
  8013bb:	e8 2c ff ff ff       	call   8012ec <fd_lookup>
  8013c0:	89 c3                	mov    %eax,%ebx
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	78 05                	js     8013ce <fd_close+0x34>
	    || fd != fd2)
  8013c9:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8013cc:	74 16                	je     8013e4 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8013ce:	89 f8                	mov    %edi,%eax
  8013d0:	84 c0                	test   %al,%al
  8013d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d7:	0f 44 d8             	cmove  %eax,%ebx
}
  8013da:	89 d8                	mov    %ebx,%eax
  8013dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013df:	5b                   	pop    %ebx
  8013e0:	5e                   	pop    %esi
  8013e1:	5f                   	pop    %edi
  8013e2:	5d                   	pop    %ebp
  8013e3:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013e4:	83 ec 08             	sub    $0x8,%esp
  8013e7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013ea:	50                   	push   %eax
  8013eb:	ff 36                	pushl  (%esi)
  8013ed:	e8 4e ff ff ff       	call   801340 <dev_lookup>
  8013f2:	89 c3                	mov    %eax,%ebx
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	78 1a                	js     801415 <fd_close+0x7b>
		if (dev->dev_close)
  8013fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013fe:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801401:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801406:	85 c0                	test   %eax,%eax
  801408:	74 0b                	je     801415 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80140a:	83 ec 0c             	sub    $0xc,%esp
  80140d:	56                   	push   %esi
  80140e:	ff d0                	call   *%eax
  801410:	89 c3                	mov    %eax,%ebx
  801412:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801415:	83 ec 08             	sub    $0x8,%esp
  801418:	56                   	push   %esi
  801419:	6a 00                	push   $0x0
  80141b:	e8 88 f9 ff ff       	call   800da8 <sys_page_unmap>
	return r;
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	eb b5                	jmp    8013da <fd_close+0x40>

00801425 <close>:

int
close(int fdnum)
{
  801425:	f3 0f 1e fb          	endbr32 
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80142f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801432:	50                   	push   %eax
  801433:	ff 75 08             	pushl  0x8(%ebp)
  801436:	e8 b1 fe ff ff       	call   8012ec <fd_lookup>
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	85 c0                	test   %eax,%eax
  801440:	79 02                	jns    801444 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801442:	c9                   	leave  
  801443:	c3                   	ret    
		return fd_close(fd, 1);
  801444:	83 ec 08             	sub    $0x8,%esp
  801447:	6a 01                	push   $0x1
  801449:	ff 75 f4             	pushl  -0xc(%ebp)
  80144c:	e8 49 ff ff ff       	call   80139a <fd_close>
  801451:	83 c4 10             	add    $0x10,%esp
  801454:	eb ec                	jmp    801442 <close+0x1d>

00801456 <close_all>:

void
close_all(void)
{
  801456:	f3 0f 1e fb          	endbr32 
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	53                   	push   %ebx
  80145e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801461:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801466:	83 ec 0c             	sub    $0xc,%esp
  801469:	53                   	push   %ebx
  80146a:	e8 b6 ff ff ff       	call   801425 <close>
	for (i = 0; i < MAXFD; i++)
  80146f:	83 c3 01             	add    $0x1,%ebx
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	83 fb 20             	cmp    $0x20,%ebx
  801478:	75 ec                	jne    801466 <close_all+0x10>
}
  80147a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147d:	c9                   	leave  
  80147e:	c3                   	ret    

0080147f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80147f:	f3 0f 1e fb          	endbr32 
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
  801486:	57                   	push   %edi
  801487:	56                   	push   %esi
  801488:	53                   	push   %ebx
  801489:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80148c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80148f:	50                   	push   %eax
  801490:	ff 75 08             	pushl  0x8(%ebp)
  801493:	e8 54 fe ff ff       	call   8012ec <fd_lookup>
  801498:	89 c3                	mov    %eax,%ebx
  80149a:	83 c4 10             	add    $0x10,%esp
  80149d:	85 c0                	test   %eax,%eax
  80149f:	0f 88 81 00 00 00    	js     801526 <dup+0xa7>
		return r;
	close(newfdnum);
  8014a5:	83 ec 0c             	sub    $0xc,%esp
  8014a8:	ff 75 0c             	pushl  0xc(%ebp)
  8014ab:	e8 75 ff ff ff       	call   801425 <close>

	newfd = INDEX2FD(newfdnum);
  8014b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014b3:	c1 e6 0c             	shl    $0xc,%esi
  8014b6:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8014bc:	83 c4 04             	add    $0x4,%esp
  8014bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014c2:	e8 b4 fd ff ff       	call   80127b <fd2data>
  8014c7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014c9:	89 34 24             	mov    %esi,(%esp)
  8014cc:	e8 aa fd ff ff       	call   80127b <fd2data>
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014d6:	89 d8                	mov    %ebx,%eax
  8014d8:	c1 e8 16             	shr    $0x16,%eax
  8014db:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014e2:	a8 01                	test   $0x1,%al
  8014e4:	74 11                	je     8014f7 <dup+0x78>
  8014e6:	89 d8                	mov    %ebx,%eax
  8014e8:	c1 e8 0c             	shr    $0xc,%eax
  8014eb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014f2:	f6 c2 01             	test   $0x1,%dl
  8014f5:	75 39                	jne    801530 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014fa:	89 d0                	mov    %edx,%eax
  8014fc:	c1 e8 0c             	shr    $0xc,%eax
  8014ff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801506:	83 ec 0c             	sub    $0xc,%esp
  801509:	25 07 0e 00 00       	and    $0xe07,%eax
  80150e:	50                   	push   %eax
  80150f:	56                   	push   %esi
  801510:	6a 00                	push   $0x0
  801512:	52                   	push   %edx
  801513:	6a 00                	push   $0x0
  801515:	e8 48 f8 ff ff       	call   800d62 <sys_page_map>
  80151a:	89 c3                	mov    %eax,%ebx
  80151c:	83 c4 20             	add    $0x20,%esp
  80151f:	85 c0                	test   %eax,%eax
  801521:	78 31                	js     801554 <dup+0xd5>
		goto err;

	return newfdnum;
  801523:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801526:	89 d8                	mov    %ebx,%eax
  801528:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152b:	5b                   	pop    %ebx
  80152c:	5e                   	pop    %esi
  80152d:	5f                   	pop    %edi
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801530:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801537:	83 ec 0c             	sub    $0xc,%esp
  80153a:	25 07 0e 00 00       	and    $0xe07,%eax
  80153f:	50                   	push   %eax
  801540:	57                   	push   %edi
  801541:	6a 00                	push   $0x0
  801543:	53                   	push   %ebx
  801544:	6a 00                	push   $0x0
  801546:	e8 17 f8 ff ff       	call   800d62 <sys_page_map>
  80154b:	89 c3                	mov    %eax,%ebx
  80154d:	83 c4 20             	add    $0x20,%esp
  801550:	85 c0                	test   %eax,%eax
  801552:	79 a3                	jns    8014f7 <dup+0x78>
	sys_page_unmap(0, newfd);
  801554:	83 ec 08             	sub    $0x8,%esp
  801557:	56                   	push   %esi
  801558:	6a 00                	push   $0x0
  80155a:	e8 49 f8 ff ff       	call   800da8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80155f:	83 c4 08             	add    $0x8,%esp
  801562:	57                   	push   %edi
  801563:	6a 00                	push   $0x0
  801565:	e8 3e f8 ff ff       	call   800da8 <sys_page_unmap>
	return r;
  80156a:	83 c4 10             	add    $0x10,%esp
  80156d:	eb b7                	jmp    801526 <dup+0xa7>

0080156f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80156f:	f3 0f 1e fb          	endbr32 
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	53                   	push   %ebx
  801577:	83 ec 1c             	sub    $0x1c,%esp
  80157a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80157d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801580:	50                   	push   %eax
  801581:	53                   	push   %ebx
  801582:	e8 65 fd ff ff       	call   8012ec <fd_lookup>
  801587:	83 c4 10             	add    $0x10,%esp
  80158a:	85 c0                	test   %eax,%eax
  80158c:	78 3f                	js     8015cd <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158e:	83 ec 08             	sub    $0x8,%esp
  801591:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801594:	50                   	push   %eax
  801595:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801598:	ff 30                	pushl  (%eax)
  80159a:	e8 a1 fd ff ff       	call   801340 <dev_lookup>
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	85 c0                	test   %eax,%eax
  8015a4:	78 27                	js     8015cd <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015a9:	8b 42 08             	mov    0x8(%edx),%eax
  8015ac:	83 e0 03             	and    $0x3,%eax
  8015af:	83 f8 01             	cmp    $0x1,%eax
  8015b2:	74 1e                	je     8015d2 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8015b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b7:	8b 40 08             	mov    0x8(%eax),%eax
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	74 35                	je     8015f3 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015be:	83 ec 04             	sub    $0x4,%esp
  8015c1:	ff 75 10             	pushl  0x10(%ebp)
  8015c4:	ff 75 0c             	pushl  0xc(%ebp)
  8015c7:	52                   	push   %edx
  8015c8:	ff d0                	call   *%eax
  8015ca:	83 c4 10             	add    $0x10,%esp
}
  8015cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d0:	c9                   	leave  
  8015d1:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d2:	a1 04 40 80 00       	mov    0x804004,%eax
  8015d7:	8b 40 48             	mov    0x48(%eax),%eax
  8015da:	83 ec 04             	sub    $0x4,%esp
  8015dd:	53                   	push   %ebx
  8015de:	50                   	push   %eax
  8015df:	68 25 28 80 00       	push   $0x802825
  8015e4:	e8 e7 ec ff ff       	call   8002d0 <cprintf>
		return -E_INVAL;
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015f1:	eb da                	jmp    8015cd <read+0x5e>
		return -E_NOT_SUPP;
  8015f3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015f8:	eb d3                	jmp    8015cd <read+0x5e>

008015fa <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015fa:	f3 0f 1e fb          	endbr32 
  8015fe:	55                   	push   %ebp
  8015ff:	89 e5                	mov    %esp,%ebp
  801601:	57                   	push   %edi
  801602:	56                   	push   %esi
  801603:	53                   	push   %ebx
  801604:	83 ec 0c             	sub    $0xc,%esp
  801607:	8b 7d 08             	mov    0x8(%ebp),%edi
  80160a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80160d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801612:	eb 02                	jmp    801616 <readn+0x1c>
  801614:	01 c3                	add    %eax,%ebx
  801616:	39 f3                	cmp    %esi,%ebx
  801618:	73 21                	jae    80163b <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80161a:	83 ec 04             	sub    $0x4,%esp
  80161d:	89 f0                	mov    %esi,%eax
  80161f:	29 d8                	sub    %ebx,%eax
  801621:	50                   	push   %eax
  801622:	89 d8                	mov    %ebx,%eax
  801624:	03 45 0c             	add    0xc(%ebp),%eax
  801627:	50                   	push   %eax
  801628:	57                   	push   %edi
  801629:	e8 41 ff ff ff       	call   80156f <read>
		if (m < 0)
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	85 c0                	test   %eax,%eax
  801633:	78 04                	js     801639 <readn+0x3f>
			return m;
		if (m == 0)
  801635:	75 dd                	jne    801614 <readn+0x1a>
  801637:	eb 02                	jmp    80163b <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801639:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80163b:	89 d8                	mov    %ebx,%eax
  80163d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801640:	5b                   	pop    %ebx
  801641:	5e                   	pop    %esi
  801642:	5f                   	pop    %edi
  801643:	5d                   	pop    %ebp
  801644:	c3                   	ret    

00801645 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801645:	f3 0f 1e fb          	endbr32 
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	53                   	push   %ebx
  80164d:	83 ec 1c             	sub    $0x1c,%esp
  801650:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801653:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801656:	50                   	push   %eax
  801657:	53                   	push   %ebx
  801658:	e8 8f fc ff ff       	call   8012ec <fd_lookup>
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	85 c0                	test   %eax,%eax
  801662:	78 3a                	js     80169e <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801664:	83 ec 08             	sub    $0x8,%esp
  801667:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166a:	50                   	push   %eax
  80166b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166e:	ff 30                	pushl  (%eax)
  801670:	e8 cb fc ff ff       	call   801340 <dev_lookup>
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	85 c0                	test   %eax,%eax
  80167a:	78 22                	js     80169e <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80167c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801683:	74 1e                	je     8016a3 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801685:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801688:	8b 52 0c             	mov    0xc(%edx),%edx
  80168b:	85 d2                	test   %edx,%edx
  80168d:	74 35                	je     8016c4 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80168f:	83 ec 04             	sub    $0x4,%esp
  801692:	ff 75 10             	pushl  0x10(%ebp)
  801695:	ff 75 0c             	pushl  0xc(%ebp)
  801698:	50                   	push   %eax
  801699:	ff d2                	call   *%edx
  80169b:	83 c4 10             	add    $0x10,%esp
}
  80169e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a1:	c9                   	leave  
  8016a2:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016a3:	a1 04 40 80 00       	mov    0x804004,%eax
  8016a8:	8b 40 48             	mov    0x48(%eax),%eax
  8016ab:	83 ec 04             	sub    $0x4,%esp
  8016ae:	53                   	push   %ebx
  8016af:	50                   	push   %eax
  8016b0:	68 41 28 80 00       	push   $0x802841
  8016b5:	e8 16 ec ff ff       	call   8002d0 <cprintf>
		return -E_INVAL;
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016c2:	eb da                	jmp    80169e <write+0x59>
		return -E_NOT_SUPP;
  8016c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016c9:	eb d3                	jmp    80169e <write+0x59>

008016cb <seek>:

int
seek(int fdnum, off_t offset)
{
  8016cb:	f3 0f 1e fb          	endbr32 
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d8:	50                   	push   %eax
  8016d9:	ff 75 08             	pushl  0x8(%ebp)
  8016dc:	e8 0b fc ff ff       	call   8012ec <fd_lookup>
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	85 c0                	test   %eax,%eax
  8016e6:	78 0e                	js     8016f6 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8016e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ee:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    

008016f8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016f8:	f3 0f 1e fb          	endbr32 
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	53                   	push   %ebx
  801700:	83 ec 1c             	sub    $0x1c,%esp
  801703:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801706:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801709:	50                   	push   %eax
  80170a:	53                   	push   %ebx
  80170b:	e8 dc fb ff ff       	call   8012ec <fd_lookup>
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	85 c0                	test   %eax,%eax
  801715:	78 37                	js     80174e <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801717:	83 ec 08             	sub    $0x8,%esp
  80171a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171d:	50                   	push   %eax
  80171e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801721:	ff 30                	pushl  (%eax)
  801723:	e8 18 fc ff ff       	call   801340 <dev_lookup>
  801728:	83 c4 10             	add    $0x10,%esp
  80172b:	85 c0                	test   %eax,%eax
  80172d:	78 1f                	js     80174e <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80172f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801732:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801736:	74 1b                	je     801753 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801738:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80173b:	8b 52 18             	mov    0x18(%edx),%edx
  80173e:	85 d2                	test   %edx,%edx
  801740:	74 32                	je     801774 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801742:	83 ec 08             	sub    $0x8,%esp
  801745:	ff 75 0c             	pushl  0xc(%ebp)
  801748:	50                   	push   %eax
  801749:	ff d2                	call   *%edx
  80174b:	83 c4 10             	add    $0x10,%esp
}
  80174e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801751:	c9                   	leave  
  801752:	c3                   	ret    
			thisenv->env_id, fdnum);
  801753:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801758:	8b 40 48             	mov    0x48(%eax),%eax
  80175b:	83 ec 04             	sub    $0x4,%esp
  80175e:	53                   	push   %ebx
  80175f:	50                   	push   %eax
  801760:	68 04 28 80 00       	push   $0x802804
  801765:	e8 66 eb ff ff       	call   8002d0 <cprintf>
		return -E_INVAL;
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801772:	eb da                	jmp    80174e <ftruncate+0x56>
		return -E_NOT_SUPP;
  801774:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801779:	eb d3                	jmp    80174e <ftruncate+0x56>

0080177b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80177b:	f3 0f 1e fb          	endbr32 
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	53                   	push   %ebx
  801783:	83 ec 1c             	sub    $0x1c,%esp
  801786:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801789:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80178c:	50                   	push   %eax
  80178d:	ff 75 08             	pushl  0x8(%ebp)
  801790:	e8 57 fb ff ff       	call   8012ec <fd_lookup>
  801795:	83 c4 10             	add    $0x10,%esp
  801798:	85 c0                	test   %eax,%eax
  80179a:	78 4b                	js     8017e7 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179c:	83 ec 08             	sub    $0x8,%esp
  80179f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a2:	50                   	push   %eax
  8017a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a6:	ff 30                	pushl  (%eax)
  8017a8:	e8 93 fb ff ff       	call   801340 <dev_lookup>
  8017ad:	83 c4 10             	add    $0x10,%esp
  8017b0:	85 c0                	test   %eax,%eax
  8017b2:	78 33                	js     8017e7 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8017b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017bb:	74 2f                	je     8017ec <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017bd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017c0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017c7:	00 00 00 
	stat->st_isdir = 0;
  8017ca:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017d1:	00 00 00 
	stat->st_dev = dev;
  8017d4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017da:	83 ec 08             	sub    $0x8,%esp
  8017dd:	53                   	push   %ebx
  8017de:	ff 75 f0             	pushl  -0x10(%ebp)
  8017e1:	ff 50 14             	call   *0x14(%eax)
  8017e4:	83 c4 10             	add    $0x10,%esp
}
  8017e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ea:	c9                   	leave  
  8017eb:	c3                   	ret    
		return -E_NOT_SUPP;
  8017ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017f1:	eb f4                	jmp    8017e7 <fstat+0x6c>

008017f3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017f3:	f3 0f 1e fb          	endbr32 
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	56                   	push   %esi
  8017fb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017fc:	83 ec 08             	sub    $0x8,%esp
  8017ff:	6a 00                	push   $0x0
  801801:	ff 75 08             	pushl  0x8(%ebp)
  801804:	e8 cf 01 00 00       	call   8019d8 <open>
  801809:	89 c3                	mov    %eax,%ebx
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	85 c0                	test   %eax,%eax
  801810:	78 1b                	js     80182d <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801812:	83 ec 08             	sub    $0x8,%esp
  801815:	ff 75 0c             	pushl  0xc(%ebp)
  801818:	50                   	push   %eax
  801819:	e8 5d ff ff ff       	call   80177b <fstat>
  80181e:	89 c6                	mov    %eax,%esi
	close(fd);
  801820:	89 1c 24             	mov    %ebx,(%esp)
  801823:	e8 fd fb ff ff       	call   801425 <close>
	return r;
  801828:	83 c4 10             	add    $0x10,%esp
  80182b:	89 f3                	mov    %esi,%ebx
}
  80182d:	89 d8                	mov    %ebx,%eax
  80182f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801832:	5b                   	pop    %ebx
  801833:	5e                   	pop    %esi
  801834:	5d                   	pop    %ebp
  801835:	c3                   	ret    

00801836 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	56                   	push   %esi
  80183a:	53                   	push   %ebx
  80183b:	89 c6                	mov    %eax,%esi
  80183d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80183f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801846:	74 27                	je     80186f <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801848:	6a 07                	push   $0x7
  80184a:	68 00 50 80 00       	push   $0x805000
  80184f:	56                   	push   %esi
  801850:	ff 35 00 40 80 00    	pushl  0x804000
  801856:	e8 69 f9 ff ff       	call   8011c4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80185b:	83 c4 0c             	add    $0xc,%esp
  80185e:	6a 00                	push   $0x0
  801860:	53                   	push   %ebx
  801861:	6a 00                	push   $0x0
  801863:	e8 05 f9 ff ff       	call   80116d <ipc_recv>
}
  801868:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80186b:	5b                   	pop    %ebx
  80186c:	5e                   	pop    %esi
  80186d:	5d                   	pop    %ebp
  80186e:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80186f:	83 ec 0c             	sub    $0xc,%esp
  801872:	6a 01                	push   $0x1
  801874:	e8 b1 f9 ff ff       	call   80122a <ipc_find_env>
  801879:	a3 00 40 80 00       	mov    %eax,0x804000
  80187e:	83 c4 10             	add    $0x10,%esp
  801881:	eb c5                	jmp    801848 <fsipc+0x12>

00801883 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801883:	f3 0f 1e fb          	endbr32 
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80188d:	8b 45 08             	mov    0x8(%ebp),%eax
  801890:	8b 40 0c             	mov    0xc(%eax),%eax
  801893:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801898:	8b 45 0c             	mov    0xc(%ebp),%eax
  80189b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a5:	b8 02 00 00 00       	mov    $0x2,%eax
  8018aa:	e8 87 ff ff ff       	call   801836 <fsipc>
}
  8018af:	c9                   	leave  
  8018b0:	c3                   	ret    

008018b1 <devfile_flush>:
{
  8018b1:	f3 0f 1e fb          	endbr32 
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018be:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cb:	b8 06 00 00 00       	mov    $0x6,%eax
  8018d0:	e8 61 ff ff ff       	call   801836 <fsipc>
}
  8018d5:	c9                   	leave  
  8018d6:	c3                   	ret    

008018d7 <devfile_stat>:
{
  8018d7:	f3 0f 1e fb          	endbr32 
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	53                   	push   %ebx
  8018df:	83 ec 04             	sub    $0x4,%esp
  8018e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018eb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f5:	b8 05 00 00 00       	mov    $0x5,%eax
  8018fa:	e8 37 ff ff ff       	call   801836 <fsipc>
  8018ff:	85 c0                	test   %eax,%eax
  801901:	78 2c                	js     80192f <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801903:	83 ec 08             	sub    $0x8,%esp
  801906:	68 00 50 80 00       	push   $0x805000
  80190b:	53                   	push   %ebx
  80190c:	e8 c8 ef ff ff       	call   8008d9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801911:	a1 80 50 80 00       	mov    0x805080,%eax
  801916:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80191c:	a1 84 50 80 00       	mov    0x805084,%eax
  801921:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801927:	83 c4 10             	add    $0x10,%esp
  80192a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80192f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801932:	c9                   	leave  
  801933:	c3                   	ret    

00801934 <devfile_write>:
{
  801934:	f3 0f 1e fb          	endbr32 
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	83 ec 0c             	sub    $0xc,%esp
	panic("devfile_write not implemented");
  80193e:	68 70 28 80 00       	push   $0x802870
  801943:	68 90 00 00 00       	push   $0x90
  801948:	68 8e 28 80 00       	push   $0x80288e
  80194d:	e8 2e 06 00 00       	call   801f80 <_panic>

00801952 <devfile_read>:
{
  801952:	f3 0f 1e fb          	endbr32 
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	56                   	push   %esi
  80195a:	53                   	push   %ebx
  80195b:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80195e:	8b 45 08             	mov    0x8(%ebp),%eax
  801961:	8b 40 0c             	mov    0xc(%eax),%eax
  801964:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801969:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80196f:	ba 00 00 00 00       	mov    $0x0,%edx
  801974:	b8 03 00 00 00       	mov    $0x3,%eax
  801979:	e8 b8 fe ff ff       	call   801836 <fsipc>
  80197e:	89 c3                	mov    %eax,%ebx
  801980:	85 c0                	test   %eax,%eax
  801982:	78 1f                	js     8019a3 <devfile_read+0x51>
	assert(r <= n);
  801984:	39 f0                	cmp    %esi,%eax
  801986:	77 24                	ja     8019ac <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801988:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80198d:	7f 33                	jg     8019c2 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80198f:	83 ec 04             	sub    $0x4,%esp
  801992:	50                   	push   %eax
  801993:	68 00 50 80 00       	push   $0x805000
  801998:	ff 75 0c             	pushl  0xc(%ebp)
  80199b:	e8 ef f0 ff ff       	call   800a8f <memmove>
	return r;
  8019a0:	83 c4 10             	add    $0x10,%esp
}
  8019a3:	89 d8                	mov    %ebx,%eax
  8019a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a8:	5b                   	pop    %ebx
  8019a9:	5e                   	pop    %esi
  8019aa:	5d                   	pop    %ebp
  8019ab:	c3                   	ret    
	assert(r <= n);
  8019ac:	68 99 28 80 00       	push   $0x802899
  8019b1:	68 a0 28 80 00       	push   $0x8028a0
  8019b6:	6a 7c                	push   $0x7c
  8019b8:	68 8e 28 80 00       	push   $0x80288e
  8019bd:	e8 be 05 00 00       	call   801f80 <_panic>
	assert(r <= PGSIZE);
  8019c2:	68 b5 28 80 00       	push   $0x8028b5
  8019c7:	68 a0 28 80 00       	push   $0x8028a0
  8019cc:	6a 7d                	push   $0x7d
  8019ce:	68 8e 28 80 00       	push   $0x80288e
  8019d3:	e8 a8 05 00 00       	call   801f80 <_panic>

008019d8 <open>:
{
  8019d8:	f3 0f 1e fb          	endbr32 
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	56                   	push   %esi
  8019e0:	53                   	push   %ebx
  8019e1:	83 ec 1c             	sub    $0x1c,%esp
  8019e4:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8019e7:	56                   	push   %esi
  8019e8:	e8 a9 ee ff ff       	call   800896 <strlen>
  8019ed:	83 c4 10             	add    $0x10,%esp
  8019f0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019f5:	7f 6c                	jg     801a63 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8019f7:	83 ec 0c             	sub    $0xc,%esp
  8019fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019fd:	50                   	push   %eax
  8019fe:	e8 93 f8 ff ff       	call   801296 <fd_alloc>
  801a03:	89 c3                	mov    %eax,%ebx
  801a05:	83 c4 10             	add    $0x10,%esp
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	78 3c                	js     801a48 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801a0c:	83 ec 08             	sub    $0x8,%esp
  801a0f:	56                   	push   %esi
  801a10:	68 00 50 80 00       	push   $0x805000
  801a15:	e8 bf ee ff ff       	call   8008d9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1d:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a22:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a25:	b8 01 00 00 00       	mov    $0x1,%eax
  801a2a:	e8 07 fe ff ff       	call   801836 <fsipc>
  801a2f:	89 c3                	mov    %eax,%ebx
  801a31:	83 c4 10             	add    $0x10,%esp
  801a34:	85 c0                	test   %eax,%eax
  801a36:	78 19                	js     801a51 <open+0x79>
	return fd2num(fd);
  801a38:	83 ec 0c             	sub    $0xc,%esp
  801a3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a3e:	e8 24 f8 ff ff       	call   801267 <fd2num>
  801a43:	89 c3                	mov    %eax,%ebx
  801a45:	83 c4 10             	add    $0x10,%esp
}
  801a48:	89 d8                	mov    %ebx,%eax
  801a4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a4d:	5b                   	pop    %ebx
  801a4e:	5e                   	pop    %esi
  801a4f:	5d                   	pop    %ebp
  801a50:	c3                   	ret    
		fd_close(fd, 0);
  801a51:	83 ec 08             	sub    $0x8,%esp
  801a54:	6a 00                	push   $0x0
  801a56:	ff 75 f4             	pushl  -0xc(%ebp)
  801a59:	e8 3c f9 ff ff       	call   80139a <fd_close>
		return r;
  801a5e:	83 c4 10             	add    $0x10,%esp
  801a61:	eb e5                	jmp    801a48 <open+0x70>
		return -E_BAD_PATH;
  801a63:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a68:	eb de                	jmp    801a48 <open+0x70>

00801a6a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a6a:	f3 0f 1e fb          	endbr32 
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a74:	ba 00 00 00 00       	mov    $0x0,%edx
  801a79:	b8 08 00 00 00       	mov    $0x8,%eax
  801a7e:	e8 b3 fd ff ff       	call   801836 <fsipc>
}
  801a83:	c9                   	leave  
  801a84:	c3                   	ret    

00801a85 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a85:	f3 0f 1e fb          	endbr32 
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	56                   	push   %esi
  801a8d:	53                   	push   %ebx
  801a8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a91:	83 ec 0c             	sub    $0xc,%esp
  801a94:	ff 75 08             	pushl  0x8(%ebp)
  801a97:	e8 df f7 ff ff       	call   80127b <fd2data>
  801a9c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a9e:	83 c4 08             	add    $0x8,%esp
  801aa1:	68 c1 28 80 00       	push   $0x8028c1
  801aa6:	53                   	push   %ebx
  801aa7:	e8 2d ee ff ff       	call   8008d9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aac:	8b 46 04             	mov    0x4(%esi),%eax
  801aaf:	2b 06                	sub    (%esi),%eax
  801ab1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ab7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801abe:	00 00 00 
	stat->st_dev = &devpipe;
  801ac1:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801ac8:	30 80 00 
	return 0;
}
  801acb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad3:	5b                   	pop    %ebx
  801ad4:	5e                   	pop    %esi
  801ad5:	5d                   	pop    %ebp
  801ad6:	c3                   	ret    

00801ad7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ad7:	f3 0f 1e fb          	endbr32 
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	53                   	push   %ebx
  801adf:	83 ec 0c             	sub    $0xc,%esp
  801ae2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ae5:	53                   	push   %ebx
  801ae6:	6a 00                	push   $0x0
  801ae8:	e8 bb f2 ff ff       	call   800da8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801aed:	89 1c 24             	mov    %ebx,(%esp)
  801af0:	e8 86 f7 ff ff       	call   80127b <fd2data>
  801af5:	83 c4 08             	add    $0x8,%esp
  801af8:	50                   	push   %eax
  801af9:	6a 00                	push   $0x0
  801afb:	e8 a8 f2 ff ff       	call   800da8 <sys_page_unmap>
}
  801b00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b03:	c9                   	leave  
  801b04:	c3                   	ret    

00801b05 <_pipeisclosed>:
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	57                   	push   %edi
  801b09:	56                   	push   %esi
  801b0a:	53                   	push   %ebx
  801b0b:	83 ec 1c             	sub    $0x1c,%esp
  801b0e:	89 c7                	mov    %eax,%edi
  801b10:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b12:	a1 04 40 80 00       	mov    0x804004,%eax
  801b17:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b1a:	83 ec 0c             	sub    $0xc,%esp
  801b1d:	57                   	push   %edi
  801b1e:	e8 4d 05 00 00       	call   802070 <pageref>
  801b23:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b26:	89 34 24             	mov    %esi,(%esp)
  801b29:	e8 42 05 00 00       	call   802070 <pageref>
		nn = thisenv->env_runs;
  801b2e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b34:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b37:	83 c4 10             	add    $0x10,%esp
  801b3a:	39 cb                	cmp    %ecx,%ebx
  801b3c:	74 1b                	je     801b59 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b3e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b41:	75 cf                	jne    801b12 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b43:	8b 42 58             	mov    0x58(%edx),%eax
  801b46:	6a 01                	push   $0x1
  801b48:	50                   	push   %eax
  801b49:	53                   	push   %ebx
  801b4a:	68 c8 28 80 00       	push   $0x8028c8
  801b4f:	e8 7c e7 ff ff       	call   8002d0 <cprintf>
  801b54:	83 c4 10             	add    $0x10,%esp
  801b57:	eb b9                	jmp    801b12 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b59:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b5c:	0f 94 c0             	sete   %al
  801b5f:	0f b6 c0             	movzbl %al,%eax
}
  801b62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b65:	5b                   	pop    %ebx
  801b66:	5e                   	pop    %esi
  801b67:	5f                   	pop    %edi
  801b68:	5d                   	pop    %ebp
  801b69:	c3                   	ret    

00801b6a <devpipe_write>:
{
  801b6a:	f3 0f 1e fb          	endbr32 
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	57                   	push   %edi
  801b72:	56                   	push   %esi
  801b73:	53                   	push   %ebx
  801b74:	83 ec 28             	sub    $0x28,%esp
  801b77:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b7a:	56                   	push   %esi
  801b7b:	e8 fb f6 ff ff       	call   80127b <fd2data>
  801b80:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b82:	83 c4 10             	add    $0x10,%esp
  801b85:	bf 00 00 00 00       	mov    $0x0,%edi
  801b8a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b8d:	74 4f                	je     801bde <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b8f:	8b 43 04             	mov    0x4(%ebx),%eax
  801b92:	8b 0b                	mov    (%ebx),%ecx
  801b94:	8d 51 20             	lea    0x20(%ecx),%edx
  801b97:	39 d0                	cmp    %edx,%eax
  801b99:	72 14                	jb     801baf <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801b9b:	89 da                	mov    %ebx,%edx
  801b9d:	89 f0                	mov    %esi,%eax
  801b9f:	e8 61 ff ff ff       	call   801b05 <_pipeisclosed>
  801ba4:	85 c0                	test   %eax,%eax
  801ba6:	75 3b                	jne    801be3 <devpipe_write+0x79>
			sys_yield();
  801ba8:	e8 4b f1 ff ff       	call   800cf8 <sys_yield>
  801bad:	eb e0                	jmp    801b8f <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801baf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bb6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bb9:	89 c2                	mov    %eax,%edx
  801bbb:	c1 fa 1f             	sar    $0x1f,%edx
  801bbe:	89 d1                	mov    %edx,%ecx
  801bc0:	c1 e9 1b             	shr    $0x1b,%ecx
  801bc3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bc6:	83 e2 1f             	and    $0x1f,%edx
  801bc9:	29 ca                	sub    %ecx,%edx
  801bcb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bcf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bd3:	83 c0 01             	add    $0x1,%eax
  801bd6:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801bd9:	83 c7 01             	add    $0x1,%edi
  801bdc:	eb ac                	jmp    801b8a <devpipe_write+0x20>
	return i;
  801bde:	8b 45 10             	mov    0x10(%ebp),%eax
  801be1:	eb 05                	jmp    801be8 <devpipe_write+0x7e>
				return 0;
  801be3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801be8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801beb:	5b                   	pop    %ebx
  801bec:	5e                   	pop    %esi
  801bed:	5f                   	pop    %edi
  801bee:	5d                   	pop    %ebp
  801bef:	c3                   	ret    

00801bf0 <devpipe_read>:
{
  801bf0:	f3 0f 1e fb          	endbr32 
  801bf4:	55                   	push   %ebp
  801bf5:	89 e5                	mov    %esp,%ebp
  801bf7:	57                   	push   %edi
  801bf8:	56                   	push   %esi
  801bf9:	53                   	push   %ebx
  801bfa:	83 ec 18             	sub    $0x18,%esp
  801bfd:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801c00:	57                   	push   %edi
  801c01:	e8 75 f6 ff ff       	call   80127b <fd2data>
  801c06:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c08:	83 c4 10             	add    $0x10,%esp
  801c0b:	be 00 00 00 00       	mov    $0x0,%esi
  801c10:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c13:	75 14                	jne    801c29 <devpipe_read+0x39>
	return i;
  801c15:	8b 45 10             	mov    0x10(%ebp),%eax
  801c18:	eb 02                	jmp    801c1c <devpipe_read+0x2c>
				return i;
  801c1a:	89 f0                	mov    %esi,%eax
}
  801c1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c1f:	5b                   	pop    %ebx
  801c20:	5e                   	pop    %esi
  801c21:	5f                   	pop    %edi
  801c22:	5d                   	pop    %ebp
  801c23:	c3                   	ret    
			sys_yield();
  801c24:	e8 cf f0 ff ff       	call   800cf8 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801c29:	8b 03                	mov    (%ebx),%eax
  801c2b:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c2e:	75 18                	jne    801c48 <devpipe_read+0x58>
			if (i > 0)
  801c30:	85 f6                	test   %esi,%esi
  801c32:	75 e6                	jne    801c1a <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801c34:	89 da                	mov    %ebx,%edx
  801c36:	89 f8                	mov    %edi,%eax
  801c38:	e8 c8 fe ff ff       	call   801b05 <_pipeisclosed>
  801c3d:	85 c0                	test   %eax,%eax
  801c3f:	74 e3                	je     801c24 <devpipe_read+0x34>
				return 0;
  801c41:	b8 00 00 00 00       	mov    $0x0,%eax
  801c46:	eb d4                	jmp    801c1c <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c48:	99                   	cltd   
  801c49:	c1 ea 1b             	shr    $0x1b,%edx
  801c4c:	01 d0                	add    %edx,%eax
  801c4e:	83 e0 1f             	and    $0x1f,%eax
  801c51:	29 d0                	sub    %edx,%eax
  801c53:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c5b:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c5e:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c61:	83 c6 01             	add    $0x1,%esi
  801c64:	eb aa                	jmp    801c10 <devpipe_read+0x20>

00801c66 <pipe>:
{
  801c66:	f3 0f 1e fb          	endbr32 
  801c6a:	55                   	push   %ebp
  801c6b:	89 e5                	mov    %esp,%ebp
  801c6d:	56                   	push   %esi
  801c6e:	53                   	push   %ebx
  801c6f:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c75:	50                   	push   %eax
  801c76:	e8 1b f6 ff ff       	call   801296 <fd_alloc>
  801c7b:	89 c3                	mov    %eax,%ebx
  801c7d:	83 c4 10             	add    $0x10,%esp
  801c80:	85 c0                	test   %eax,%eax
  801c82:	0f 88 23 01 00 00    	js     801dab <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c88:	83 ec 04             	sub    $0x4,%esp
  801c8b:	68 07 04 00 00       	push   $0x407
  801c90:	ff 75 f4             	pushl  -0xc(%ebp)
  801c93:	6a 00                	push   $0x0
  801c95:	e8 81 f0 ff ff       	call   800d1b <sys_page_alloc>
  801c9a:	89 c3                	mov    %eax,%ebx
  801c9c:	83 c4 10             	add    $0x10,%esp
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	0f 88 04 01 00 00    	js     801dab <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801ca7:	83 ec 0c             	sub    $0xc,%esp
  801caa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cad:	50                   	push   %eax
  801cae:	e8 e3 f5 ff ff       	call   801296 <fd_alloc>
  801cb3:	89 c3                	mov    %eax,%ebx
  801cb5:	83 c4 10             	add    $0x10,%esp
  801cb8:	85 c0                	test   %eax,%eax
  801cba:	0f 88 db 00 00 00    	js     801d9b <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc0:	83 ec 04             	sub    $0x4,%esp
  801cc3:	68 07 04 00 00       	push   $0x407
  801cc8:	ff 75 f0             	pushl  -0x10(%ebp)
  801ccb:	6a 00                	push   $0x0
  801ccd:	e8 49 f0 ff ff       	call   800d1b <sys_page_alloc>
  801cd2:	89 c3                	mov    %eax,%ebx
  801cd4:	83 c4 10             	add    $0x10,%esp
  801cd7:	85 c0                	test   %eax,%eax
  801cd9:	0f 88 bc 00 00 00    	js     801d9b <pipe+0x135>
	va = fd2data(fd0);
  801cdf:	83 ec 0c             	sub    $0xc,%esp
  801ce2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce5:	e8 91 f5 ff ff       	call   80127b <fd2data>
  801cea:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cec:	83 c4 0c             	add    $0xc,%esp
  801cef:	68 07 04 00 00       	push   $0x407
  801cf4:	50                   	push   %eax
  801cf5:	6a 00                	push   $0x0
  801cf7:	e8 1f f0 ff ff       	call   800d1b <sys_page_alloc>
  801cfc:	89 c3                	mov    %eax,%ebx
  801cfe:	83 c4 10             	add    $0x10,%esp
  801d01:	85 c0                	test   %eax,%eax
  801d03:	0f 88 82 00 00 00    	js     801d8b <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d09:	83 ec 0c             	sub    $0xc,%esp
  801d0c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d0f:	e8 67 f5 ff ff       	call   80127b <fd2data>
  801d14:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d1b:	50                   	push   %eax
  801d1c:	6a 00                	push   $0x0
  801d1e:	56                   	push   %esi
  801d1f:	6a 00                	push   $0x0
  801d21:	e8 3c f0 ff ff       	call   800d62 <sys_page_map>
  801d26:	89 c3                	mov    %eax,%ebx
  801d28:	83 c4 20             	add    $0x20,%esp
  801d2b:	85 c0                	test   %eax,%eax
  801d2d:	78 4e                	js     801d7d <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801d2f:	a1 28 30 80 00       	mov    0x803028,%eax
  801d34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d37:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801d39:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d3c:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801d43:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d46:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801d48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d4b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d52:	83 ec 0c             	sub    $0xc,%esp
  801d55:	ff 75 f4             	pushl  -0xc(%ebp)
  801d58:	e8 0a f5 ff ff       	call   801267 <fd2num>
  801d5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d60:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d62:	83 c4 04             	add    $0x4,%esp
  801d65:	ff 75 f0             	pushl  -0x10(%ebp)
  801d68:	e8 fa f4 ff ff       	call   801267 <fd2num>
  801d6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d70:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d73:	83 c4 10             	add    $0x10,%esp
  801d76:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d7b:	eb 2e                	jmp    801dab <pipe+0x145>
	sys_page_unmap(0, va);
  801d7d:	83 ec 08             	sub    $0x8,%esp
  801d80:	56                   	push   %esi
  801d81:	6a 00                	push   $0x0
  801d83:	e8 20 f0 ff ff       	call   800da8 <sys_page_unmap>
  801d88:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d8b:	83 ec 08             	sub    $0x8,%esp
  801d8e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d91:	6a 00                	push   $0x0
  801d93:	e8 10 f0 ff ff       	call   800da8 <sys_page_unmap>
  801d98:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801d9b:	83 ec 08             	sub    $0x8,%esp
  801d9e:	ff 75 f4             	pushl  -0xc(%ebp)
  801da1:	6a 00                	push   $0x0
  801da3:	e8 00 f0 ff ff       	call   800da8 <sys_page_unmap>
  801da8:	83 c4 10             	add    $0x10,%esp
}
  801dab:	89 d8                	mov    %ebx,%eax
  801dad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db0:	5b                   	pop    %ebx
  801db1:	5e                   	pop    %esi
  801db2:	5d                   	pop    %ebp
  801db3:	c3                   	ret    

00801db4 <pipeisclosed>:
{
  801db4:	f3 0f 1e fb          	endbr32 
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dbe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc1:	50                   	push   %eax
  801dc2:	ff 75 08             	pushl  0x8(%ebp)
  801dc5:	e8 22 f5 ff ff       	call   8012ec <fd_lookup>
  801dca:	83 c4 10             	add    $0x10,%esp
  801dcd:	85 c0                	test   %eax,%eax
  801dcf:	78 18                	js     801de9 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801dd1:	83 ec 0c             	sub    $0xc,%esp
  801dd4:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd7:	e8 9f f4 ff ff       	call   80127b <fd2data>
  801ddc:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de1:	e8 1f fd ff ff       	call   801b05 <_pipeisclosed>
  801de6:	83 c4 10             	add    $0x10,%esp
}
  801de9:	c9                   	leave  
  801dea:	c3                   	ret    

00801deb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801deb:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801def:	b8 00 00 00 00       	mov    $0x0,%eax
  801df4:	c3                   	ret    

00801df5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801df5:	f3 0f 1e fb          	endbr32 
  801df9:	55                   	push   %ebp
  801dfa:	89 e5                	mov    %esp,%ebp
  801dfc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dff:	68 e0 28 80 00       	push   $0x8028e0
  801e04:	ff 75 0c             	pushl  0xc(%ebp)
  801e07:	e8 cd ea ff ff       	call   8008d9 <strcpy>
	return 0;
}
  801e0c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e11:	c9                   	leave  
  801e12:	c3                   	ret    

00801e13 <devcons_write>:
{
  801e13:	f3 0f 1e fb          	endbr32 
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	57                   	push   %edi
  801e1b:	56                   	push   %esi
  801e1c:	53                   	push   %ebx
  801e1d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e23:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e28:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e2e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e31:	73 31                	jae    801e64 <devcons_write+0x51>
		m = n - tot;
  801e33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e36:	29 f3                	sub    %esi,%ebx
  801e38:	83 fb 7f             	cmp    $0x7f,%ebx
  801e3b:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e40:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e43:	83 ec 04             	sub    $0x4,%esp
  801e46:	53                   	push   %ebx
  801e47:	89 f0                	mov    %esi,%eax
  801e49:	03 45 0c             	add    0xc(%ebp),%eax
  801e4c:	50                   	push   %eax
  801e4d:	57                   	push   %edi
  801e4e:	e8 3c ec ff ff       	call   800a8f <memmove>
		sys_cputs(buf, m);
  801e53:	83 c4 08             	add    $0x8,%esp
  801e56:	53                   	push   %ebx
  801e57:	57                   	push   %edi
  801e58:	e8 ee ed ff ff       	call   800c4b <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e5d:	01 de                	add    %ebx,%esi
  801e5f:	83 c4 10             	add    $0x10,%esp
  801e62:	eb ca                	jmp    801e2e <devcons_write+0x1b>
}
  801e64:	89 f0                	mov    %esi,%eax
  801e66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e69:	5b                   	pop    %ebx
  801e6a:	5e                   	pop    %esi
  801e6b:	5f                   	pop    %edi
  801e6c:	5d                   	pop    %ebp
  801e6d:	c3                   	ret    

00801e6e <devcons_read>:
{
  801e6e:	f3 0f 1e fb          	endbr32 
  801e72:	55                   	push   %ebp
  801e73:	89 e5                	mov    %esp,%ebp
  801e75:	83 ec 08             	sub    $0x8,%esp
  801e78:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e7d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e81:	74 21                	je     801ea4 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801e83:	e8 e5 ed ff ff       	call   800c6d <sys_cgetc>
  801e88:	85 c0                	test   %eax,%eax
  801e8a:	75 07                	jne    801e93 <devcons_read+0x25>
		sys_yield();
  801e8c:	e8 67 ee ff ff       	call   800cf8 <sys_yield>
  801e91:	eb f0                	jmp    801e83 <devcons_read+0x15>
	if (c < 0)
  801e93:	78 0f                	js     801ea4 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801e95:	83 f8 04             	cmp    $0x4,%eax
  801e98:	74 0c                	je     801ea6 <devcons_read+0x38>
	*(char*)vbuf = c;
  801e9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e9d:	88 02                	mov    %al,(%edx)
	return 1;
  801e9f:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801ea4:	c9                   	leave  
  801ea5:	c3                   	ret    
		return 0;
  801ea6:	b8 00 00 00 00       	mov    $0x0,%eax
  801eab:	eb f7                	jmp    801ea4 <devcons_read+0x36>

00801ead <cputchar>:
{
  801ead:	f3 0f 1e fb          	endbr32 
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eba:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ebd:	6a 01                	push   $0x1
  801ebf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ec2:	50                   	push   %eax
  801ec3:	e8 83 ed ff ff       	call   800c4b <sys_cputs>
}
  801ec8:	83 c4 10             	add    $0x10,%esp
  801ecb:	c9                   	leave  
  801ecc:	c3                   	ret    

00801ecd <getchar>:
{
  801ecd:	f3 0f 1e fb          	endbr32 
  801ed1:	55                   	push   %ebp
  801ed2:	89 e5                	mov    %esp,%ebp
  801ed4:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ed7:	6a 01                	push   $0x1
  801ed9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801edc:	50                   	push   %eax
  801edd:	6a 00                	push   $0x0
  801edf:	e8 8b f6 ff ff       	call   80156f <read>
	if (r < 0)
  801ee4:	83 c4 10             	add    $0x10,%esp
  801ee7:	85 c0                	test   %eax,%eax
  801ee9:	78 06                	js     801ef1 <getchar+0x24>
	if (r < 1)
  801eeb:	74 06                	je     801ef3 <getchar+0x26>
	return c;
  801eed:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ef1:	c9                   	leave  
  801ef2:	c3                   	ret    
		return -E_EOF;
  801ef3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ef8:	eb f7                	jmp    801ef1 <getchar+0x24>

00801efa <iscons>:
{
  801efa:	f3 0f 1e fb          	endbr32 
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f07:	50                   	push   %eax
  801f08:	ff 75 08             	pushl  0x8(%ebp)
  801f0b:	e8 dc f3 ff ff       	call   8012ec <fd_lookup>
  801f10:	83 c4 10             	add    $0x10,%esp
  801f13:	85 c0                	test   %eax,%eax
  801f15:	78 11                	js     801f28 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801f17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1a:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801f20:	39 10                	cmp    %edx,(%eax)
  801f22:	0f 94 c0             	sete   %al
  801f25:	0f b6 c0             	movzbl %al,%eax
}
  801f28:	c9                   	leave  
  801f29:	c3                   	ret    

00801f2a <opencons>:
{
  801f2a:	f3 0f 1e fb          	endbr32 
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f37:	50                   	push   %eax
  801f38:	e8 59 f3 ff ff       	call   801296 <fd_alloc>
  801f3d:	83 c4 10             	add    $0x10,%esp
  801f40:	85 c0                	test   %eax,%eax
  801f42:	78 3a                	js     801f7e <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f44:	83 ec 04             	sub    $0x4,%esp
  801f47:	68 07 04 00 00       	push   $0x407
  801f4c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f4f:	6a 00                	push   $0x0
  801f51:	e8 c5 ed ff ff       	call   800d1b <sys_page_alloc>
  801f56:	83 c4 10             	add    $0x10,%esp
  801f59:	85 c0                	test   %eax,%eax
  801f5b:	78 21                	js     801f7e <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f60:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801f66:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f72:	83 ec 0c             	sub    $0xc,%esp
  801f75:	50                   	push   %eax
  801f76:	e8 ec f2 ff ff       	call   801267 <fd2num>
  801f7b:	83 c4 10             	add    $0x10,%esp
}
  801f7e:	c9                   	leave  
  801f7f:	c3                   	ret    

00801f80 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f80:	f3 0f 1e fb          	endbr32 
  801f84:	55                   	push   %ebp
  801f85:	89 e5                	mov    %esp,%ebp
  801f87:	56                   	push   %esi
  801f88:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f89:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f8c:	8b 35 08 30 80 00    	mov    0x803008,%esi
  801f92:	e8 3e ed ff ff       	call   800cd5 <sys_getenvid>
  801f97:	83 ec 0c             	sub    $0xc,%esp
  801f9a:	ff 75 0c             	pushl  0xc(%ebp)
  801f9d:	ff 75 08             	pushl  0x8(%ebp)
  801fa0:	56                   	push   %esi
  801fa1:	50                   	push   %eax
  801fa2:	68 ec 28 80 00       	push   $0x8028ec
  801fa7:	e8 24 e3 ff ff       	call   8002d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fac:	83 c4 18             	add    $0x18,%esp
  801faf:	53                   	push   %ebx
  801fb0:	ff 75 10             	pushl  0x10(%ebp)
  801fb3:	e8 c3 e2 ff ff       	call   80027b <vcprintf>
	cprintf("\n");
  801fb8:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  801fbf:	e8 0c e3 ff ff       	call   8002d0 <cprintf>
  801fc4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fc7:	cc                   	int3   
  801fc8:	eb fd                	jmp    801fc7 <_panic+0x47>

00801fca <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fca:	f3 0f 1e fb          	endbr32 
  801fce:	55                   	push   %ebp
  801fcf:	89 e5                	mov    %esp,%ebp
  801fd1:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fd4:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fdb:	74 0a                	je     801fe7 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fdd:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe0:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801fe5:	c9                   	leave  
  801fe6:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801fe7:	83 ec 0c             	sub    $0xc,%esp
  801fea:	68 0f 29 80 00       	push   $0x80290f
  801fef:	e8 dc e2 ff ff       	call   8002d0 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  801ff4:	83 c4 0c             	add    $0xc,%esp
  801ff7:	6a 07                	push   $0x7
  801ff9:	68 00 f0 bf ee       	push   $0xeebff000
  801ffe:	6a 00                	push   $0x0
  802000:	e8 16 ed ff ff       	call   800d1b <sys_page_alloc>
  802005:	83 c4 10             	add    $0x10,%esp
  802008:	85 c0                	test   %eax,%eax
  80200a:	78 2a                	js     802036 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  80200c:	83 ec 08             	sub    $0x8,%esp
  80200f:	68 4a 20 80 00       	push   $0x80204a
  802014:	6a 00                	push   $0x0
  802016:	e8 5f ee ff ff       	call   800e7a <sys_env_set_pgfault_upcall>
  80201b:	83 c4 10             	add    $0x10,%esp
  80201e:	85 c0                	test   %eax,%eax
  802020:	79 bb                	jns    801fdd <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  802022:	83 ec 04             	sub    $0x4,%esp
  802025:	68 4c 29 80 00       	push   $0x80294c
  80202a:	6a 25                	push   $0x25
  80202c:	68 3c 29 80 00       	push   $0x80293c
  802031:	e8 4a ff ff ff       	call   801f80 <_panic>
            panic("Allocation of UXSTACK failed!");
  802036:	83 ec 04             	sub    $0x4,%esp
  802039:	68 1e 29 80 00       	push   $0x80291e
  80203e:	6a 22                	push   $0x22
  802040:	68 3c 29 80 00       	push   $0x80293c
  802045:	e8 36 ff ff ff       	call   801f80 <_panic>

0080204a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80204a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80204b:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802050:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802052:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  802055:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  802059:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  80205d:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  802060:	83 c4 08             	add    $0x8,%esp
    popa
  802063:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  802064:	83 c4 04             	add    $0x4,%esp
    popf
  802067:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  802068:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  80206b:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  80206f:	c3                   	ret    

00802070 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802070:	f3 0f 1e fb          	endbr32 
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80207a:	89 c2                	mov    %eax,%edx
  80207c:	c1 ea 16             	shr    $0x16,%edx
  80207f:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802086:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80208b:	f6 c1 01             	test   $0x1,%cl
  80208e:	74 1c                	je     8020ac <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802090:	c1 e8 0c             	shr    $0xc,%eax
  802093:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80209a:	a8 01                	test   $0x1,%al
  80209c:	74 0e                	je     8020ac <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80209e:	c1 e8 0c             	shr    $0xc,%eax
  8020a1:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8020a8:	ef 
  8020a9:	0f b7 d2             	movzwl %dx,%edx
}
  8020ac:	89 d0                	mov    %edx,%eax
  8020ae:	5d                   	pop    %ebp
  8020af:	c3                   	ret    

008020b0 <__udivdi3>:
  8020b0:	f3 0f 1e fb          	endbr32 
  8020b4:	55                   	push   %ebp
  8020b5:	57                   	push   %edi
  8020b6:	56                   	push   %esi
  8020b7:	53                   	push   %ebx
  8020b8:	83 ec 1c             	sub    $0x1c,%esp
  8020bb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020bf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8020c3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020c7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8020cb:	85 d2                	test   %edx,%edx
  8020cd:	75 19                	jne    8020e8 <__udivdi3+0x38>
  8020cf:	39 f3                	cmp    %esi,%ebx
  8020d1:	76 4d                	jbe    802120 <__udivdi3+0x70>
  8020d3:	31 ff                	xor    %edi,%edi
  8020d5:	89 e8                	mov    %ebp,%eax
  8020d7:	89 f2                	mov    %esi,%edx
  8020d9:	f7 f3                	div    %ebx
  8020db:	89 fa                	mov    %edi,%edx
  8020dd:	83 c4 1c             	add    $0x1c,%esp
  8020e0:	5b                   	pop    %ebx
  8020e1:	5e                   	pop    %esi
  8020e2:	5f                   	pop    %edi
  8020e3:	5d                   	pop    %ebp
  8020e4:	c3                   	ret    
  8020e5:	8d 76 00             	lea    0x0(%esi),%esi
  8020e8:	39 f2                	cmp    %esi,%edx
  8020ea:	76 14                	jbe    802100 <__udivdi3+0x50>
  8020ec:	31 ff                	xor    %edi,%edi
  8020ee:	31 c0                	xor    %eax,%eax
  8020f0:	89 fa                	mov    %edi,%edx
  8020f2:	83 c4 1c             	add    $0x1c,%esp
  8020f5:	5b                   	pop    %ebx
  8020f6:	5e                   	pop    %esi
  8020f7:	5f                   	pop    %edi
  8020f8:	5d                   	pop    %ebp
  8020f9:	c3                   	ret    
  8020fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802100:	0f bd fa             	bsr    %edx,%edi
  802103:	83 f7 1f             	xor    $0x1f,%edi
  802106:	75 48                	jne    802150 <__udivdi3+0xa0>
  802108:	39 f2                	cmp    %esi,%edx
  80210a:	72 06                	jb     802112 <__udivdi3+0x62>
  80210c:	31 c0                	xor    %eax,%eax
  80210e:	39 eb                	cmp    %ebp,%ebx
  802110:	77 de                	ja     8020f0 <__udivdi3+0x40>
  802112:	b8 01 00 00 00       	mov    $0x1,%eax
  802117:	eb d7                	jmp    8020f0 <__udivdi3+0x40>
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	89 d9                	mov    %ebx,%ecx
  802122:	85 db                	test   %ebx,%ebx
  802124:	75 0b                	jne    802131 <__udivdi3+0x81>
  802126:	b8 01 00 00 00       	mov    $0x1,%eax
  80212b:	31 d2                	xor    %edx,%edx
  80212d:	f7 f3                	div    %ebx
  80212f:	89 c1                	mov    %eax,%ecx
  802131:	31 d2                	xor    %edx,%edx
  802133:	89 f0                	mov    %esi,%eax
  802135:	f7 f1                	div    %ecx
  802137:	89 c6                	mov    %eax,%esi
  802139:	89 e8                	mov    %ebp,%eax
  80213b:	89 f7                	mov    %esi,%edi
  80213d:	f7 f1                	div    %ecx
  80213f:	89 fa                	mov    %edi,%edx
  802141:	83 c4 1c             	add    $0x1c,%esp
  802144:	5b                   	pop    %ebx
  802145:	5e                   	pop    %esi
  802146:	5f                   	pop    %edi
  802147:	5d                   	pop    %ebp
  802148:	c3                   	ret    
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	89 f9                	mov    %edi,%ecx
  802152:	b8 20 00 00 00       	mov    $0x20,%eax
  802157:	29 f8                	sub    %edi,%eax
  802159:	d3 e2                	shl    %cl,%edx
  80215b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80215f:	89 c1                	mov    %eax,%ecx
  802161:	89 da                	mov    %ebx,%edx
  802163:	d3 ea                	shr    %cl,%edx
  802165:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802169:	09 d1                	or     %edx,%ecx
  80216b:	89 f2                	mov    %esi,%edx
  80216d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802171:	89 f9                	mov    %edi,%ecx
  802173:	d3 e3                	shl    %cl,%ebx
  802175:	89 c1                	mov    %eax,%ecx
  802177:	d3 ea                	shr    %cl,%edx
  802179:	89 f9                	mov    %edi,%ecx
  80217b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80217f:	89 eb                	mov    %ebp,%ebx
  802181:	d3 e6                	shl    %cl,%esi
  802183:	89 c1                	mov    %eax,%ecx
  802185:	d3 eb                	shr    %cl,%ebx
  802187:	09 de                	or     %ebx,%esi
  802189:	89 f0                	mov    %esi,%eax
  80218b:	f7 74 24 08          	divl   0x8(%esp)
  80218f:	89 d6                	mov    %edx,%esi
  802191:	89 c3                	mov    %eax,%ebx
  802193:	f7 64 24 0c          	mull   0xc(%esp)
  802197:	39 d6                	cmp    %edx,%esi
  802199:	72 15                	jb     8021b0 <__udivdi3+0x100>
  80219b:	89 f9                	mov    %edi,%ecx
  80219d:	d3 e5                	shl    %cl,%ebp
  80219f:	39 c5                	cmp    %eax,%ebp
  8021a1:	73 04                	jae    8021a7 <__udivdi3+0xf7>
  8021a3:	39 d6                	cmp    %edx,%esi
  8021a5:	74 09                	je     8021b0 <__udivdi3+0x100>
  8021a7:	89 d8                	mov    %ebx,%eax
  8021a9:	31 ff                	xor    %edi,%edi
  8021ab:	e9 40 ff ff ff       	jmp    8020f0 <__udivdi3+0x40>
  8021b0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8021b3:	31 ff                	xor    %edi,%edi
  8021b5:	e9 36 ff ff ff       	jmp    8020f0 <__udivdi3+0x40>
  8021ba:	66 90                	xchg   %ax,%ax
  8021bc:	66 90                	xchg   %ax,%ax
  8021be:	66 90                	xchg   %ax,%ax

008021c0 <__umoddi3>:
  8021c0:	f3 0f 1e fb          	endbr32 
  8021c4:	55                   	push   %ebp
  8021c5:	57                   	push   %edi
  8021c6:	56                   	push   %esi
  8021c7:	53                   	push   %ebx
  8021c8:	83 ec 1c             	sub    $0x1c,%esp
  8021cb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8021cf:	8b 74 24 30          	mov    0x30(%esp),%esi
  8021d3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8021d7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021db:	85 c0                	test   %eax,%eax
  8021dd:	75 19                	jne    8021f8 <__umoddi3+0x38>
  8021df:	39 df                	cmp    %ebx,%edi
  8021e1:	76 5d                	jbe    802240 <__umoddi3+0x80>
  8021e3:	89 f0                	mov    %esi,%eax
  8021e5:	89 da                	mov    %ebx,%edx
  8021e7:	f7 f7                	div    %edi
  8021e9:	89 d0                	mov    %edx,%eax
  8021eb:	31 d2                	xor    %edx,%edx
  8021ed:	83 c4 1c             	add    $0x1c,%esp
  8021f0:	5b                   	pop    %ebx
  8021f1:	5e                   	pop    %esi
  8021f2:	5f                   	pop    %edi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    
  8021f5:	8d 76 00             	lea    0x0(%esi),%esi
  8021f8:	89 f2                	mov    %esi,%edx
  8021fa:	39 d8                	cmp    %ebx,%eax
  8021fc:	76 12                	jbe    802210 <__umoddi3+0x50>
  8021fe:	89 f0                	mov    %esi,%eax
  802200:	89 da                	mov    %ebx,%edx
  802202:	83 c4 1c             	add    $0x1c,%esp
  802205:	5b                   	pop    %ebx
  802206:	5e                   	pop    %esi
  802207:	5f                   	pop    %edi
  802208:	5d                   	pop    %ebp
  802209:	c3                   	ret    
  80220a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802210:	0f bd e8             	bsr    %eax,%ebp
  802213:	83 f5 1f             	xor    $0x1f,%ebp
  802216:	75 50                	jne    802268 <__umoddi3+0xa8>
  802218:	39 d8                	cmp    %ebx,%eax
  80221a:	0f 82 e0 00 00 00    	jb     802300 <__umoddi3+0x140>
  802220:	89 d9                	mov    %ebx,%ecx
  802222:	39 f7                	cmp    %esi,%edi
  802224:	0f 86 d6 00 00 00    	jbe    802300 <__umoddi3+0x140>
  80222a:	89 d0                	mov    %edx,%eax
  80222c:	89 ca                	mov    %ecx,%edx
  80222e:	83 c4 1c             	add    $0x1c,%esp
  802231:	5b                   	pop    %ebx
  802232:	5e                   	pop    %esi
  802233:	5f                   	pop    %edi
  802234:	5d                   	pop    %ebp
  802235:	c3                   	ret    
  802236:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80223d:	8d 76 00             	lea    0x0(%esi),%esi
  802240:	89 fd                	mov    %edi,%ebp
  802242:	85 ff                	test   %edi,%edi
  802244:	75 0b                	jne    802251 <__umoddi3+0x91>
  802246:	b8 01 00 00 00       	mov    $0x1,%eax
  80224b:	31 d2                	xor    %edx,%edx
  80224d:	f7 f7                	div    %edi
  80224f:	89 c5                	mov    %eax,%ebp
  802251:	89 d8                	mov    %ebx,%eax
  802253:	31 d2                	xor    %edx,%edx
  802255:	f7 f5                	div    %ebp
  802257:	89 f0                	mov    %esi,%eax
  802259:	f7 f5                	div    %ebp
  80225b:	89 d0                	mov    %edx,%eax
  80225d:	31 d2                	xor    %edx,%edx
  80225f:	eb 8c                	jmp    8021ed <__umoddi3+0x2d>
  802261:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802268:	89 e9                	mov    %ebp,%ecx
  80226a:	ba 20 00 00 00       	mov    $0x20,%edx
  80226f:	29 ea                	sub    %ebp,%edx
  802271:	d3 e0                	shl    %cl,%eax
  802273:	89 44 24 08          	mov    %eax,0x8(%esp)
  802277:	89 d1                	mov    %edx,%ecx
  802279:	89 f8                	mov    %edi,%eax
  80227b:	d3 e8                	shr    %cl,%eax
  80227d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802281:	89 54 24 04          	mov    %edx,0x4(%esp)
  802285:	8b 54 24 04          	mov    0x4(%esp),%edx
  802289:	09 c1                	or     %eax,%ecx
  80228b:	89 d8                	mov    %ebx,%eax
  80228d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802291:	89 e9                	mov    %ebp,%ecx
  802293:	d3 e7                	shl    %cl,%edi
  802295:	89 d1                	mov    %edx,%ecx
  802297:	d3 e8                	shr    %cl,%eax
  802299:	89 e9                	mov    %ebp,%ecx
  80229b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80229f:	d3 e3                	shl    %cl,%ebx
  8022a1:	89 c7                	mov    %eax,%edi
  8022a3:	89 d1                	mov    %edx,%ecx
  8022a5:	89 f0                	mov    %esi,%eax
  8022a7:	d3 e8                	shr    %cl,%eax
  8022a9:	89 e9                	mov    %ebp,%ecx
  8022ab:	89 fa                	mov    %edi,%edx
  8022ad:	d3 e6                	shl    %cl,%esi
  8022af:	09 d8                	or     %ebx,%eax
  8022b1:	f7 74 24 08          	divl   0x8(%esp)
  8022b5:	89 d1                	mov    %edx,%ecx
  8022b7:	89 f3                	mov    %esi,%ebx
  8022b9:	f7 64 24 0c          	mull   0xc(%esp)
  8022bd:	89 c6                	mov    %eax,%esi
  8022bf:	89 d7                	mov    %edx,%edi
  8022c1:	39 d1                	cmp    %edx,%ecx
  8022c3:	72 06                	jb     8022cb <__umoddi3+0x10b>
  8022c5:	75 10                	jne    8022d7 <__umoddi3+0x117>
  8022c7:	39 c3                	cmp    %eax,%ebx
  8022c9:	73 0c                	jae    8022d7 <__umoddi3+0x117>
  8022cb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8022cf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8022d3:	89 d7                	mov    %edx,%edi
  8022d5:	89 c6                	mov    %eax,%esi
  8022d7:	89 ca                	mov    %ecx,%edx
  8022d9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022de:	29 f3                	sub    %esi,%ebx
  8022e0:	19 fa                	sbb    %edi,%edx
  8022e2:	89 d0                	mov    %edx,%eax
  8022e4:	d3 e0                	shl    %cl,%eax
  8022e6:	89 e9                	mov    %ebp,%ecx
  8022e8:	d3 eb                	shr    %cl,%ebx
  8022ea:	d3 ea                	shr    %cl,%edx
  8022ec:	09 d8                	or     %ebx,%eax
  8022ee:	83 c4 1c             	add    $0x1c,%esp
  8022f1:	5b                   	pop    %ebx
  8022f2:	5e                   	pop    %esi
  8022f3:	5f                   	pop    %edi
  8022f4:	5d                   	pop    %ebp
  8022f5:	c3                   	ret    
  8022f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022fd:	8d 76 00             	lea    0x0(%esi),%esi
  802300:	29 fe                	sub    %edi,%esi
  802302:	19 c3                	sbb    %eax,%ebx
  802304:	89 f2                	mov    %esi,%edx
  802306:	89 d9                	mov    %ebx,%ecx
  802308:	e9 1d ff ff ff       	jmp    80222a <__umoddi3+0x6a>
