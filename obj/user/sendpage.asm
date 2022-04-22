
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
  80003d:	e8 b7 0f 00 00       	call   800ff9 <fork>
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
  800060:	e8 ae 0c 00 00       	call   800d13 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800065:	83 c4 04             	add    $0x4,%esp
  800068:	ff 35 04 20 80 00    	pushl  0x802004
  80006e:	e8 1b 08 00 00       	call   80088e <strlen>
  800073:	83 c4 0c             	add    $0xc,%esp
  800076:	83 c0 01             	add    $0x1,%eax
  800079:	50                   	push   %eax
  80007a:	ff 35 04 20 80 00    	pushl  0x802004
  800080:	68 00 00 a0 00       	push   $0xa00000
  800085:	e8 63 0a 00 00       	call   800aed <memcpy>
    cprintf("parent sent\n");
  80008a:	c7 04 24 e0 15 80 00 	movl   $0x8015e0,(%esp)
  800091:	e8 32 02 00 00       	call   8002c8 <cprintf>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800096:	6a 07                	push   $0x7
  800098:	68 00 00 a0 00       	push   $0xa00000
  80009d:	6a 00                	push   $0x0
  80009f:	ff 75 f4             	pushl  -0xc(%ebp)
  8000a2:	e8 20 11 00 00       	call   8011c7 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  8000a7:	83 c4 1c             	add    $0x1c,%esp
  8000aa:	6a 00                	push   $0x0
  8000ac:	68 00 00 a0 00       	push   $0xa00000
  8000b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b4:	50                   	push   %eax
  8000b5:	e8 b6 10 00 00       	call   801170 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	68 00 00 a0 00       	push   $0xa00000
  8000c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8000c5:	68 c0 15 80 00       	push   $0x8015c0
  8000ca:	e8 f9 01 00 00       	call   8002c8 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8000cf:	83 c4 04             	add    $0x4,%esp
  8000d2:	ff 35 00 20 80 00    	pushl  0x802000
  8000d8:	e8 b1 07 00 00       	call   80088e <strlen>
  8000dd:	83 c4 0c             	add    $0xc,%esp
  8000e0:	50                   	push   %eax
  8000e1:	ff 35 00 20 80 00    	pushl  0x802000
  8000e7:	68 00 00 a0 00       	push   $0xa00000
  8000ec:	e8 c9 08 00 00       	call   8009ba <strncmp>
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
  80010c:	e8 5f 10 00 00       	call   801170 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800111:	83 c4 0c             	add    $0xc,%esp
  800114:	68 00 00 b0 00       	push   $0xb00000
  800119:	ff 75 f4             	pushl  -0xc(%ebp)
  80011c:	68 c0 15 80 00       	push   $0x8015c0
  800121:	e8 a2 01 00 00       	call   8002c8 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800126:	83 c4 04             	add    $0x4,%esp
  800129:	ff 35 04 20 80 00    	pushl  0x802004
  80012f:	e8 5a 07 00 00       	call   80088e <strlen>
  800134:	83 c4 0c             	add    $0xc,%esp
  800137:	50                   	push   %eax
  800138:	ff 35 04 20 80 00    	pushl  0x802004
  80013e:	68 00 00 b0 00       	push   $0xb00000
  800143:	e8 72 08 00 00       	call   8009ba <strncmp>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	85 c0                	test   %eax,%eax
  80014d:	74 4b                	je     80019a <umain+0x167>
		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	ff 35 00 20 80 00    	pushl  0x802000
  800158:	e8 31 07 00 00       	call   80088e <strlen>
  80015d:	83 c4 0c             	add    $0xc,%esp
  800160:	83 c0 01             	add    $0x1,%eax
  800163:	50                   	push   %eax
  800164:	ff 35 00 20 80 00    	pushl  0x802000
  80016a:	68 00 00 b0 00       	push   $0xb00000
  80016f:	e8 79 09 00 00       	call   800aed <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  800174:	6a 07                	push   $0x7
  800176:	68 00 00 b0 00       	push   $0xb00000
  80017b:	6a 00                	push   $0x0
  80017d:	ff 75 f4             	pushl  -0xc(%ebp)
  800180:	e8 42 10 00 00       	call   8011c7 <ipc_send>
        cprintf("child sent\n");
  800185:	83 c4 14             	add    $0x14,%esp
  800188:	68 d4 15 80 00       	push   $0x8015d4
  80018d:	e8 36 01 00 00       	call   8002c8 <cprintf>
		return;
  800192:	83 c4 10             	add    $0x10,%esp
  800195:	e9 62 ff ff ff       	jmp    8000fc <umain+0xc9>
			cprintf("child received correct message\n");
  80019a:	83 ec 0c             	sub    $0xc,%esp
  80019d:	68 f0 15 80 00       	push   $0x8015f0
  8001a2:	e8 21 01 00 00       	call   8002c8 <cprintf>
  8001a7:	83 c4 10             	add    $0x10,%esp
  8001aa:	eb a3                	jmp    80014f <umain+0x11c>
		cprintf("parent received correct message\n");
  8001ac:	83 ec 0c             	sub    $0xc,%esp
  8001af:	68 10 16 80 00       	push   $0x801610
  8001b4:	e8 0f 01 00 00       	call   8002c8 <cprintf>
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
  8001d0:	c7 05 0c 20 80 00 00 	movl   $0x0,0x80200c
  8001d7:	00 00 00 
    envid_t envid = sys_getenvid();
  8001da:	e8 ee 0a 00 00       	call   800ccd <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8001df:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001e7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001ec:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f1:	85 db                	test   %ebx,%ebx
  8001f3:	7e 07                	jle    8001fc <libmain+0x3b>
		binaryname = argv[0];
  8001f5:	8b 06                	mov    (%esi),%eax
  8001f7:	a3 08 20 80 00       	mov    %eax,0x802008

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
  80021c:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  80021f:	6a 00                	push   $0x0
  800221:	e8 62 0a 00 00       	call   800c88 <sys_env_destroy>
}
  800226:	83 c4 10             	add    $0x10,%esp
  800229:	c9                   	leave  
  80022a:	c3                   	ret    

0080022b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022b:	f3 0f 1e fb          	endbr32 
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	53                   	push   %ebx
  800233:	83 ec 04             	sub    $0x4,%esp
  800236:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800239:	8b 13                	mov    (%ebx),%edx
  80023b:	8d 42 01             	lea    0x1(%edx),%eax
  80023e:	89 03                	mov    %eax,(%ebx)
  800240:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800243:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800247:	3d ff 00 00 00       	cmp    $0xff,%eax
  80024c:	74 09                	je     800257 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80024e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800252:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800255:	c9                   	leave  
  800256:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800257:	83 ec 08             	sub    $0x8,%esp
  80025a:	68 ff 00 00 00       	push   $0xff
  80025f:	8d 43 08             	lea    0x8(%ebx),%eax
  800262:	50                   	push   %eax
  800263:	e8 db 09 00 00       	call   800c43 <sys_cputs>
		b->idx = 0;
  800268:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80026e:	83 c4 10             	add    $0x10,%esp
  800271:	eb db                	jmp    80024e <putch+0x23>

00800273 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800273:	f3 0f 1e fb          	endbr32 
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800280:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800287:	00 00 00 
	b.cnt = 0;
  80028a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800291:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800294:	ff 75 0c             	pushl  0xc(%ebp)
  800297:	ff 75 08             	pushl  0x8(%ebp)
  80029a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002a0:	50                   	push   %eax
  8002a1:	68 2b 02 80 00       	push   $0x80022b
  8002a6:	e8 20 01 00 00       	call   8003cb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ab:	83 c4 08             	add    $0x8,%esp
  8002ae:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002b4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002ba:	50                   	push   %eax
  8002bb:	e8 83 09 00 00       	call   800c43 <sys_cputs>

	return b.cnt;
}
  8002c0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002c6:	c9                   	leave  
  8002c7:	c3                   	ret    

008002c8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002c8:	f3 0f 1e fb          	endbr32 
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002d5:	50                   	push   %eax
  8002d6:	ff 75 08             	pushl  0x8(%ebp)
  8002d9:	e8 95 ff ff ff       	call   800273 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002de:	c9                   	leave  
  8002df:	c3                   	ret    

008002e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 1c             	sub    $0x1c,%esp
  8002e9:	89 c7                	mov    %eax,%edi
  8002eb:	89 d6                	mov    %edx,%esi
  8002ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002f3:	89 d1                	mov    %edx,%ecx
  8002f5:	89 c2                	mov    %eax,%edx
  8002f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002fd:	8b 45 10             	mov    0x10(%ebp),%eax
  800300:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800303:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800306:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80030d:	39 c2                	cmp    %eax,%edx
  80030f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800312:	72 3e                	jb     800352 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800314:	83 ec 0c             	sub    $0xc,%esp
  800317:	ff 75 18             	pushl  0x18(%ebp)
  80031a:	83 eb 01             	sub    $0x1,%ebx
  80031d:	53                   	push   %ebx
  80031e:	50                   	push   %eax
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	ff 75 e4             	pushl  -0x1c(%ebp)
  800325:	ff 75 e0             	pushl  -0x20(%ebp)
  800328:	ff 75 dc             	pushl  -0x24(%ebp)
  80032b:	ff 75 d8             	pushl  -0x28(%ebp)
  80032e:	e8 2d 10 00 00       	call   801360 <__udivdi3>
  800333:	83 c4 18             	add    $0x18,%esp
  800336:	52                   	push   %edx
  800337:	50                   	push   %eax
  800338:	89 f2                	mov    %esi,%edx
  80033a:	89 f8                	mov    %edi,%eax
  80033c:	e8 9f ff ff ff       	call   8002e0 <printnum>
  800341:	83 c4 20             	add    $0x20,%esp
  800344:	eb 13                	jmp    800359 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800346:	83 ec 08             	sub    $0x8,%esp
  800349:	56                   	push   %esi
  80034a:	ff 75 18             	pushl  0x18(%ebp)
  80034d:	ff d7                	call   *%edi
  80034f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800352:	83 eb 01             	sub    $0x1,%ebx
  800355:	85 db                	test   %ebx,%ebx
  800357:	7f ed                	jg     800346 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800359:	83 ec 08             	sub    $0x8,%esp
  80035c:	56                   	push   %esi
  80035d:	83 ec 04             	sub    $0x4,%esp
  800360:	ff 75 e4             	pushl  -0x1c(%ebp)
  800363:	ff 75 e0             	pushl  -0x20(%ebp)
  800366:	ff 75 dc             	pushl  -0x24(%ebp)
  800369:	ff 75 d8             	pushl  -0x28(%ebp)
  80036c:	e8 ff 10 00 00       	call   801470 <__umoddi3>
  800371:	83 c4 14             	add    $0x14,%esp
  800374:	0f be 80 88 16 80 00 	movsbl 0x801688(%eax),%eax
  80037b:	50                   	push   %eax
  80037c:	ff d7                	call   *%edi
}
  80037e:	83 c4 10             	add    $0x10,%esp
  800381:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800384:	5b                   	pop    %ebx
  800385:	5e                   	pop    %esi
  800386:	5f                   	pop    %edi
  800387:	5d                   	pop    %ebp
  800388:	c3                   	ret    

00800389 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800389:	f3 0f 1e fb          	endbr32 
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800393:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800397:	8b 10                	mov    (%eax),%edx
  800399:	3b 50 04             	cmp    0x4(%eax),%edx
  80039c:	73 0a                	jae    8003a8 <sprintputch+0x1f>
		*b->buf++ = ch;
  80039e:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003a1:	89 08                	mov    %ecx,(%eax)
  8003a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a6:	88 02                	mov    %al,(%edx)
}
  8003a8:	5d                   	pop    %ebp
  8003a9:	c3                   	ret    

008003aa <printfmt>:
{
  8003aa:	f3 0f 1e fb          	endbr32 
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003b4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b7:	50                   	push   %eax
  8003b8:	ff 75 10             	pushl  0x10(%ebp)
  8003bb:	ff 75 0c             	pushl  0xc(%ebp)
  8003be:	ff 75 08             	pushl  0x8(%ebp)
  8003c1:	e8 05 00 00 00       	call   8003cb <vprintfmt>
}
  8003c6:	83 c4 10             	add    $0x10,%esp
  8003c9:	c9                   	leave  
  8003ca:	c3                   	ret    

008003cb <vprintfmt>:
{
  8003cb:	f3 0f 1e fb          	endbr32 
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	57                   	push   %edi
  8003d3:	56                   	push   %esi
  8003d4:	53                   	push   %ebx
  8003d5:	83 ec 3c             	sub    $0x3c,%esp
  8003d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8003db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003de:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003e1:	e9 4a 03 00 00       	jmp    800730 <vprintfmt+0x365>
		padc = ' ';
  8003e6:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003ea:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003f1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003f8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003ff:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8d 47 01             	lea    0x1(%edi),%eax
  800407:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040a:	0f b6 17             	movzbl (%edi),%edx
  80040d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800410:	3c 55                	cmp    $0x55,%al
  800412:	0f 87 de 03 00 00    	ja     8007f6 <vprintfmt+0x42b>
  800418:	0f b6 c0             	movzbl %al,%eax
  80041b:	3e ff 24 85 c0 17 80 	notrack jmp *0x8017c0(,%eax,4)
  800422:	00 
  800423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800426:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80042a:	eb d8                	jmp    800404 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80042f:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800433:	eb cf                	jmp    800404 <vprintfmt+0x39>
  800435:	0f b6 d2             	movzbl %dl,%edx
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80043b:	b8 00 00 00 00       	mov    $0x0,%eax
  800440:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800443:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800446:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80044a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80044d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800450:	83 f9 09             	cmp    $0x9,%ecx
  800453:	77 55                	ja     8004aa <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800455:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800458:	eb e9                	jmp    800443 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80045a:	8b 45 14             	mov    0x14(%ebp),%eax
  80045d:	8b 00                	mov    (%eax),%eax
  80045f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800462:	8b 45 14             	mov    0x14(%ebp),%eax
  800465:	8d 40 04             	lea    0x4(%eax),%eax
  800468:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80046e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800472:	79 90                	jns    800404 <vprintfmt+0x39>
				width = precision, precision = -1;
  800474:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800477:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800481:	eb 81                	jmp    800404 <vprintfmt+0x39>
  800483:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800486:	85 c0                	test   %eax,%eax
  800488:	ba 00 00 00 00       	mov    $0x0,%edx
  80048d:	0f 49 d0             	cmovns %eax,%edx
  800490:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800493:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800496:	e9 69 ff ff ff       	jmp    800404 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80049e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004a5:	e9 5a ff ff ff       	jmp    800404 <vprintfmt+0x39>
  8004aa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b0:	eb bc                	jmp    80046e <vprintfmt+0xa3>
			lflag++;
  8004b2:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004b8:	e9 47 ff ff ff       	jmp    800404 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8004bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c0:	8d 78 04             	lea    0x4(%eax),%edi
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	53                   	push   %ebx
  8004c7:	ff 30                	pushl  (%eax)
  8004c9:	ff d6                	call   *%esi
			break;
  8004cb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004ce:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004d1:	e9 57 02 00 00       	jmp    80072d <vprintfmt+0x362>
			err = va_arg(ap, int);
  8004d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d9:	8d 78 04             	lea    0x4(%eax),%edi
  8004dc:	8b 00                	mov    (%eax),%eax
  8004de:	99                   	cltd   
  8004df:	31 d0                	xor    %edx,%eax
  8004e1:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e3:	83 f8 0f             	cmp    $0xf,%eax
  8004e6:	7f 23                	jg     80050b <vprintfmt+0x140>
  8004e8:	8b 14 85 20 19 80 00 	mov    0x801920(,%eax,4),%edx
  8004ef:	85 d2                	test   %edx,%edx
  8004f1:	74 18                	je     80050b <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8004f3:	52                   	push   %edx
  8004f4:	68 a9 16 80 00       	push   $0x8016a9
  8004f9:	53                   	push   %ebx
  8004fa:	56                   	push   %esi
  8004fb:	e8 aa fe ff ff       	call   8003aa <printfmt>
  800500:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800503:	89 7d 14             	mov    %edi,0x14(%ebp)
  800506:	e9 22 02 00 00       	jmp    80072d <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  80050b:	50                   	push   %eax
  80050c:	68 a0 16 80 00       	push   $0x8016a0
  800511:	53                   	push   %ebx
  800512:	56                   	push   %esi
  800513:	e8 92 fe ff ff       	call   8003aa <printfmt>
  800518:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80051b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80051e:	e9 0a 02 00 00       	jmp    80072d <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	83 c0 04             	add    $0x4,%eax
  800529:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800531:	85 d2                	test   %edx,%edx
  800533:	b8 99 16 80 00       	mov    $0x801699,%eax
  800538:	0f 45 c2             	cmovne %edx,%eax
  80053b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80053e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800542:	7e 06                	jle    80054a <vprintfmt+0x17f>
  800544:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800548:	75 0d                	jne    800557 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80054a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80054d:	89 c7                	mov    %eax,%edi
  80054f:	03 45 e0             	add    -0x20(%ebp),%eax
  800552:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800555:	eb 55                	jmp    8005ac <vprintfmt+0x1e1>
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	ff 75 d8             	pushl  -0x28(%ebp)
  80055d:	ff 75 cc             	pushl  -0x34(%ebp)
  800560:	e8 45 03 00 00       	call   8008aa <strnlen>
  800565:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800568:	29 c2                	sub    %eax,%edx
  80056a:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80056d:	83 c4 10             	add    $0x10,%esp
  800570:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800572:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800576:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800579:	85 ff                	test   %edi,%edi
  80057b:	7e 11                	jle    80058e <vprintfmt+0x1c3>
					putch(padc, putdat);
  80057d:	83 ec 08             	sub    $0x8,%esp
  800580:	53                   	push   %ebx
  800581:	ff 75 e0             	pushl  -0x20(%ebp)
  800584:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800586:	83 ef 01             	sub    $0x1,%edi
  800589:	83 c4 10             	add    $0x10,%esp
  80058c:	eb eb                	jmp    800579 <vprintfmt+0x1ae>
  80058e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800591:	85 d2                	test   %edx,%edx
  800593:	b8 00 00 00 00       	mov    $0x0,%eax
  800598:	0f 49 c2             	cmovns %edx,%eax
  80059b:	29 c2                	sub    %eax,%edx
  80059d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005a0:	eb a8                	jmp    80054a <vprintfmt+0x17f>
					putch(ch, putdat);
  8005a2:	83 ec 08             	sub    $0x8,%esp
  8005a5:	53                   	push   %ebx
  8005a6:	52                   	push   %edx
  8005a7:	ff d6                	call   *%esi
  8005a9:	83 c4 10             	add    $0x10,%esp
  8005ac:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005af:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b1:	83 c7 01             	add    $0x1,%edi
  8005b4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005b8:	0f be d0             	movsbl %al,%edx
  8005bb:	85 d2                	test   %edx,%edx
  8005bd:	74 4b                	je     80060a <vprintfmt+0x23f>
  8005bf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c3:	78 06                	js     8005cb <vprintfmt+0x200>
  8005c5:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005c9:	78 1e                	js     8005e9 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8005cb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005cf:	74 d1                	je     8005a2 <vprintfmt+0x1d7>
  8005d1:	0f be c0             	movsbl %al,%eax
  8005d4:	83 e8 20             	sub    $0x20,%eax
  8005d7:	83 f8 5e             	cmp    $0x5e,%eax
  8005da:	76 c6                	jbe    8005a2 <vprintfmt+0x1d7>
					putch('?', putdat);
  8005dc:	83 ec 08             	sub    $0x8,%esp
  8005df:	53                   	push   %ebx
  8005e0:	6a 3f                	push   $0x3f
  8005e2:	ff d6                	call   *%esi
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	eb c3                	jmp    8005ac <vprintfmt+0x1e1>
  8005e9:	89 cf                	mov    %ecx,%edi
  8005eb:	eb 0e                	jmp    8005fb <vprintfmt+0x230>
				putch(' ', putdat);
  8005ed:	83 ec 08             	sub    $0x8,%esp
  8005f0:	53                   	push   %ebx
  8005f1:	6a 20                	push   $0x20
  8005f3:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005f5:	83 ef 01             	sub    $0x1,%edi
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	85 ff                	test   %edi,%edi
  8005fd:	7f ee                	jg     8005ed <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8005ff:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800602:	89 45 14             	mov    %eax,0x14(%ebp)
  800605:	e9 23 01 00 00       	jmp    80072d <vprintfmt+0x362>
  80060a:	89 cf                	mov    %ecx,%edi
  80060c:	eb ed                	jmp    8005fb <vprintfmt+0x230>
	if (lflag >= 2)
  80060e:	83 f9 01             	cmp    $0x1,%ecx
  800611:	7f 1b                	jg     80062e <vprintfmt+0x263>
	else if (lflag)
  800613:	85 c9                	test   %ecx,%ecx
  800615:	74 63                	je     80067a <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8b 00                	mov    (%eax),%eax
  80061c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061f:	99                   	cltd   
  800620:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 40 04             	lea    0x4(%eax),%eax
  800629:	89 45 14             	mov    %eax,0x14(%ebp)
  80062c:	eb 17                	jmp    800645 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8b 50 04             	mov    0x4(%eax),%edx
  800634:	8b 00                	mov    (%eax),%eax
  800636:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800639:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8d 40 08             	lea    0x8(%eax),%eax
  800642:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800645:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800648:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80064b:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800650:	85 c9                	test   %ecx,%ecx
  800652:	0f 89 bb 00 00 00    	jns    800713 <vprintfmt+0x348>
				putch('-', putdat);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	53                   	push   %ebx
  80065c:	6a 2d                	push   $0x2d
  80065e:	ff d6                	call   *%esi
				num = -(long long) num;
  800660:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800663:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800666:	f7 da                	neg    %edx
  800668:	83 d1 00             	adc    $0x0,%ecx
  80066b:	f7 d9                	neg    %ecx
  80066d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800670:	b8 0a 00 00 00       	mov    $0xa,%eax
  800675:	e9 99 00 00 00       	jmp    800713 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8b 00                	mov    (%eax),%eax
  80067f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800682:	99                   	cltd   
  800683:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8d 40 04             	lea    0x4(%eax),%eax
  80068c:	89 45 14             	mov    %eax,0x14(%ebp)
  80068f:	eb b4                	jmp    800645 <vprintfmt+0x27a>
	if (lflag >= 2)
  800691:	83 f9 01             	cmp    $0x1,%ecx
  800694:	7f 1b                	jg     8006b1 <vprintfmt+0x2e6>
	else if (lflag)
  800696:	85 c9                	test   %ecx,%ecx
  800698:	74 2c                	je     8006c6 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8b 10                	mov    (%eax),%edx
  80069f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a4:	8d 40 04             	lea    0x4(%eax),%eax
  8006a7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006aa:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8006af:	eb 62                	jmp    800713 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8b 10                	mov    (%eax),%edx
  8006b6:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b9:	8d 40 08             	lea    0x8(%eax),%eax
  8006bc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006bf:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8006c4:	eb 4d                	jmp    800713 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8b 10                	mov    (%eax),%edx
  8006cb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d0:	8d 40 04             	lea    0x4(%eax),%eax
  8006d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d6:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8006db:	eb 36                	jmp    800713 <vprintfmt+0x348>
	if (lflag >= 2)
  8006dd:	83 f9 01             	cmp    $0x1,%ecx
  8006e0:	7f 17                	jg     8006f9 <vprintfmt+0x32e>
	else if (lflag)
  8006e2:	85 c9                	test   %ecx,%ecx
  8006e4:	74 6e                	je     800754 <vprintfmt+0x389>
		return va_arg(*ap, long);
  8006e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e9:	8b 10                	mov    (%eax),%edx
  8006eb:	89 d0                	mov    %edx,%eax
  8006ed:	99                   	cltd   
  8006ee:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006f1:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006f4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006f7:	eb 11                	jmp    80070a <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8006f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fc:	8b 50 04             	mov    0x4(%eax),%edx
  8006ff:	8b 00                	mov    (%eax),%eax
  800701:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800704:	8d 49 08             	lea    0x8(%ecx),%ecx
  800707:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80070a:	89 d1                	mov    %edx,%ecx
  80070c:	89 c2                	mov    %eax,%edx
            base = 8;
  80070e:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800713:	83 ec 0c             	sub    $0xc,%esp
  800716:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80071a:	57                   	push   %edi
  80071b:	ff 75 e0             	pushl  -0x20(%ebp)
  80071e:	50                   	push   %eax
  80071f:	51                   	push   %ecx
  800720:	52                   	push   %edx
  800721:	89 da                	mov    %ebx,%edx
  800723:	89 f0                	mov    %esi,%eax
  800725:	e8 b6 fb ff ff       	call   8002e0 <printnum>
			break;
  80072a:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80072d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800730:	83 c7 01             	add    $0x1,%edi
  800733:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800737:	83 f8 25             	cmp    $0x25,%eax
  80073a:	0f 84 a6 fc ff ff    	je     8003e6 <vprintfmt+0x1b>
			if (ch == '\0')
  800740:	85 c0                	test   %eax,%eax
  800742:	0f 84 ce 00 00 00    	je     800816 <vprintfmt+0x44b>
			putch(ch, putdat);
  800748:	83 ec 08             	sub    $0x8,%esp
  80074b:	53                   	push   %ebx
  80074c:	50                   	push   %eax
  80074d:	ff d6                	call   *%esi
  80074f:	83 c4 10             	add    $0x10,%esp
  800752:	eb dc                	jmp    800730 <vprintfmt+0x365>
		return va_arg(*ap, int);
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8b 10                	mov    (%eax),%edx
  800759:	89 d0                	mov    %edx,%eax
  80075b:	99                   	cltd   
  80075c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80075f:	8d 49 04             	lea    0x4(%ecx),%ecx
  800762:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800765:	eb a3                	jmp    80070a <vprintfmt+0x33f>
			putch('0', putdat);
  800767:	83 ec 08             	sub    $0x8,%esp
  80076a:	53                   	push   %ebx
  80076b:	6a 30                	push   $0x30
  80076d:	ff d6                	call   *%esi
			putch('x', putdat);
  80076f:	83 c4 08             	add    $0x8,%esp
  800772:	53                   	push   %ebx
  800773:	6a 78                	push   $0x78
  800775:	ff d6                	call   *%esi
			num = (unsigned long long)
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	8b 10                	mov    (%eax),%edx
  80077c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800781:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800784:	8d 40 04             	lea    0x4(%eax),%eax
  800787:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80078a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80078f:	eb 82                	jmp    800713 <vprintfmt+0x348>
	if (lflag >= 2)
  800791:	83 f9 01             	cmp    $0x1,%ecx
  800794:	7f 1e                	jg     8007b4 <vprintfmt+0x3e9>
	else if (lflag)
  800796:	85 c9                	test   %ecx,%ecx
  800798:	74 32                	je     8007cc <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80079a:	8b 45 14             	mov    0x14(%ebp),%eax
  80079d:	8b 10                	mov    (%eax),%edx
  80079f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007a4:	8d 40 04             	lea    0x4(%eax),%eax
  8007a7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007aa:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8007af:	e9 5f ff ff ff       	jmp    800713 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8007b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b7:	8b 10                	mov    (%eax),%edx
  8007b9:	8b 48 04             	mov    0x4(%eax),%ecx
  8007bc:	8d 40 08             	lea    0x8(%eax),%eax
  8007bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c2:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8007c7:	e9 47 ff ff ff       	jmp    800713 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8007cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cf:	8b 10                	mov    (%eax),%edx
  8007d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d6:	8d 40 04             	lea    0x4(%eax),%eax
  8007d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007dc:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8007e1:	e9 2d ff ff ff       	jmp    800713 <vprintfmt+0x348>
			putch(ch, putdat);
  8007e6:	83 ec 08             	sub    $0x8,%esp
  8007e9:	53                   	push   %ebx
  8007ea:	6a 25                	push   $0x25
  8007ec:	ff d6                	call   *%esi
			break;
  8007ee:	83 c4 10             	add    $0x10,%esp
  8007f1:	e9 37 ff ff ff       	jmp    80072d <vprintfmt+0x362>
			putch('%', putdat);
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	53                   	push   %ebx
  8007fa:	6a 25                	push   $0x25
  8007fc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007fe:	83 c4 10             	add    $0x10,%esp
  800801:	89 f8                	mov    %edi,%eax
  800803:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800807:	74 05                	je     80080e <vprintfmt+0x443>
  800809:	83 e8 01             	sub    $0x1,%eax
  80080c:	eb f5                	jmp    800803 <vprintfmt+0x438>
  80080e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800811:	e9 17 ff ff ff       	jmp    80072d <vprintfmt+0x362>
}
  800816:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800819:	5b                   	pop    %ebx
  80081a:	5e                   	pop    %esi
  80081b:	5f                   	pop    %edi
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80081e:	f3 0f 1e fb          	endbr32 
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	83 ec 18             	sub    $0x18,%esp
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80082e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800831:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800835:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800838:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083f:	85 c0                	test   %eax,%eax
  800841:	74 26                	je     800869 <vsnprintf+0x4b>
  800843:	85 d2                	test   %edx,%edx
  800845:	7e 22                	jle    800869 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800847:	ff 75 14             	pushl  0x14(%ebp)
  80084a:	ff 75 10             	pushl  0x10(%ebp)
  80084d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800850:	50                   	push   %eax
  800851:	68 89 03 80 00       	push   $0x800389
  800856:	e8 70 fb ff ff       	call   8003cb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80085b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800861:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800864:	83 c4 10             	add    $0x10,%esp
}
  800867:	c9                   	leave  
  800868:	c3                   	ret    
		return -E_INVAL;
  800869:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80086e:	eb f7                	jmp    800867 <vsnprintf+0x49>

00800870 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800870:	f3 0f 1e fb          	endbr32 
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80087a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80087d:	50                   	push   %eax
  80087e:	ff 75 10             	pushl  0x10(%ebp)
  800881:	ff 75 0c             	pushl  0xc(%ebp)
  800884:	ff 75 08             	pushl  0x8(%ebp)
  800887:	e8 92 ff ff ff       	call   80081e <vsnprintf>
	va_end(ap);

	return rc;
}
  80088c:	c9                   	leave  
  80088d:	c3                   	ret    

0080088e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80088e:	f3 0f 1e fb          	endbr32 
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800898:	b8 00 00 00 00       	mov    $0x0,%eax
  80089d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a1:	74 05                	je     8008a8 <strlen+0x1a>
		n++;
  8008a3:	83 c0 01             	add    $0x1,%eax
  8008a6:	eb f5                	jmp    80089d <strlen+0xf>
	return n;
}
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008aa:	f3 0f 1e fb          	endbr32 
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bc:	39 d0                	cmp    %edx,%eax
  8008be:	74 0d                	je     8008cd <strnlen+0x23>
  8008c0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008c4:	74 05                	je     8008cb <strnlen+0x21>
		n++;
  8008c6:	83 c0 01             	add    $0x1,%eax
  8008c9:	eb f1                	jmp    8008bc <strnlen+0x12>
  8008cb:	89 c2                	mov    %eax,%edx
	return n;
}
  8008cd:	89 d0                	mov    %edx,%eax
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008d1:	f3 0f 1e fb          	endbr32 
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	53                   	push   %ebx
  8008d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008df:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e4:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008e8:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008eb:	83 c0 01             	add    $0x1,%eax
  8008ee:	84 d2                	test   %dl,%dl
  8008f0:	75 f2                	jne    8008e4 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8008f2:	89 c8                	mov    %ecx,%eax
  8008f4:	5b                   	pop    %ebx
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f7:	f3 0f 1e fb          	endbr32 
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	53                   	push   %ebx
  8008ff:	83 ec 10             	sub    $0x10,%esp
  800902:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800905:	53                   	push   %ebx
  800906:	e8 83 ff ff ff       	call   80088e <strlen>
  80090b:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80090e:	ff 75 0c             	pushl  0xc(%ebp)
  800911:	01 d8                	add    %ebx,%eax
  800913:	50                   	push   %eax
  800914:	e8 b8 ff ff ff       	call   8008d1 <strcpy>
	return dst;
}
  800919:	89 d8                	mov    %ebx,%eax
  80091b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80091e:	c9                   	leave  
  80091f:	c3                   	ret    

00800920 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800920:	f3 0f 1e fb          	endbr32 
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	56                   	push   %esi
  800928:	53                   	push   %ebx
  800929:	8b 75 08             	mov    0x8(%ebp),%esi
  80092c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092f:	89 f3                	mov    %esi,%ebx
  800931:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800934:	89 f0                	mov    %esi,%eax
  800936:	39 d8                	cmp    %ebx,%eax
  800938:	74 11                	je     80094b <strncpy+0x2b>
		*dst++ = *src;
  80093a:	83 c0 01             	add    $0x1,%eax
  80093d:	0f b6 0a             	movzbl (%edx),%ecx
  800940:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800943:	80 f9 01             	cmp    $0x1,%cl
  800946:	83 da ff             	sbb    $0xffffffff,%edx
  800949:	eb eb                	jmp    800936 <strncpy+0x16>
	}
	return ret;
}
  80094b:	89 f0                	mov    %esi,%eax
  80094d:	5b                   	pop    %ebx
  80094e:	5e                   	pop    %esi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800951:	f3 0f 1e fb          	endbr32 
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	56                   	push   %esi
  800959:	53                   	push   %ebx
  80095a:	8b 75 08             	mov    0x8(%ebp),%esi
  80095d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800960:	8b 55 10             	mov    0x10(%ebp),%edx
  800963:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800965:	85 d2                	test   %edx,%edx
  800967:	74 21                	je     80098a <strlcpy+0x39>
  800969:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80096d:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80096f:	39 c2                	cmp    %eax,%edx
  800971:	74 14                	je     800987 <strlcpy+0x36>
  800973:	0f b6 19             	movzbl (%ecx),%ebx
  800976:	84 db                	test   %bl,%bl
  800978:	74 0b                	je     800985 <strlcpy+0x34>
			*dst++ = *src++;
  80097a:	83 c1 01             	add    $0x1,%ecx
  80097d:	83 c2 01             	add    $0x1,%edx
  800980:	88 5a ff             	mov    %bl,-0x1(%edx)
  800983:	eb ea                	jmp    80096f <strlcpy+0x1e>
  800985:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800987:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80098a:	29 f0                	sub    %esi,%eax
}
  80098c:	5b                   	pop    %ebx
  80098d:	5e                   	pop    %esi
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800990:	f3 0f 1e fb          	endbr32 
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80099d:	0f b6 01             	movzbl (%ecx),%eax
  8009a0:	84 c0                	test   %al,%al
  8009a2:	74 0c                	je     8009b0 <strcmp+0x20>
  8009a4:	3a 02                	cmp    (%edx),%al
  8009a6:	75 08                	jne    8009b0 <strcmp+0x20>
		p++, q++;
  8009a8:	83 c1 01             	add    $0x1,%ecx
  8009ab:	83 c2 01             	add    $0x1,%edx
  8009ae:	eb ed                	jmp    80099d <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b0:	0f b6 c0             	movzbl %al,%eax
  8009b3:	0f b6 12             	movzbl (%edx),%edx
  8009b6:	29 d0                	sub    %edx,%eax
}
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009ba:	f3 0f 1e fb          	endbr32 
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	53                   	push   %ebx
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c8:	89 c3                	mov    %eax,%ebx
  8009ca:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009cd:	eb 06                	jmp    8009d5 <strncmp+0x1b>
		n--, p++, q++;
  8009cf:	83 c0 01             	add    $0x1,%eax
  8009d2:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009d5:	39 d8                	cmp    %ebx,%eax
  8009d7:	74 16                	je     8009ef <strncmp+0x35>
  8009d9:	0f b6 08             	movzbl (%eax),%ecx
  8009dc:	84 c9                	test   %cl,%cl
  8009de:	74 04                	je     8009e4 <strncmp+0x2a>
  8009e0:	3a 0a                	cmp    (%edx),%cl
  8009e2:	74 eb                	je     8009cf <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e4:	0f b6 00             	movzbl (%eax),%eax
  8009e7:	0f b6 12             	movzbl (%edx),%edx
  8009ea:	29 d0                	sub    %edx,%eax
}
  8009ec:	5b                   	pop    %ebx
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    
		return 0;
  8009ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f4:	eb f6                	jmp    8009ec <strncmp+0x32>

008009f6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009f6:	f3 0f 1e fb          	endbr32 
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a04:	0f b6 10             	movzbl (%eax),%edx
  800a07:	84 d2                	test   %dl,%dl
  800a09:	74 09                	je     800a14 <strchr+0x1e>
		if (*s == c)
  800a0b:	38 ca                	cmp    %cl,%dl
  800a0d:	74 0a                	je     800a19 <strchr+0x23>
	for (; *s; s++)
  800a0f:	83 c0 01             	add    $0x1,%eax
  800a12:	eb f0                	jmp    800a04 <strchr+0xe>
			return (char *) s;
	return 0;
  800a14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1b:	f3 0f 1e fb          	endbr32 
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a29:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a2c:	38 ca                	cmp    %cl,%dl
  800a2e:	74 09                	je     800a39 <strfind+0x1e>
  800a30:	84 d2                	test   %dl,%dl
  800a32:	74 05                	je     800a39 <strfind+0x1e>
	for (; *s; s++)
  800a34:	83 c0 01             	add    $0x1,%eax
  800a37:	eb f0                	jmp    800a29 <strfind+0xe>
			break;
	return (char *) s;
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a3b:	f3 0f 1e fb          	endbr32 
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	57                   	push   %edi
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
  800a45:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a48:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a4b:	85 c9                	test   %ecx,%ecx
  800a4d:	74 31                	je     800a80 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4f:	89 f8                	mov    %edi,%eax
  800a51:	09 c8                	or     %ecx,%eax
  800a53:	a8 03                	test   $0x3,%al
  800a55:	75 23                	jne    800a7a <memset+0x3f>
		c &= 0xFF;
  800a57:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5b:	89 d3                	mov    %edx,%ebx
  800a5d:	c1 e3 08             	shl    $0x8,%ebx
  800a60:	89 d0                	mov    %edx,%eax
  800a62:	c1 e0 18             	shl    $0x18,%eax
  800a65:	89 d6                	mov    %edx,%esi
  800a67:	c1 e6 10             	shl    $0x10,%esi
  800a6a:	09 f0                	or     %esi,%eax
  800a6c:	09 c2                	or     %eax,%edx
  800a6e:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a70:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a73:	89 d0                	mov    %edx,%eax
  800a75:	fc                   	cld    
  800a76:	f3 ab                	rep stos %eax,%es:(%edi)
  800a78:	eb 06                	jmp    800a80 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7d:	fc                   	cld    
  800a7e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a80:	89 f8                	mov    %edi,%eax
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5f                   	pop    %edi
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a87:	f3 0f 1e fb          	endbr32 
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a96:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a99:	39 c6                	cmp    %eax,%esi
  800a9b:	73 32                	jae    800acf <memmove+0x48>
  800a9d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa0:	39 c2                	cmp    %eax,%edx
  800aa2:	76 2b                	jbe    800acf <memmove+0x48>
		s += n;
		d += n;
  800aa4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa7:	89 fe                	mov    %edi,%esi
  800aa9:	09 ce                	or     %ecx,%esi
  800aab:	09 d6                	or     %edx,%esi
  800aad:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab3:	75 0e                	jne    800ac3 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ab5:	83 ef 04             	sub    $0x4,%edi
  800ab8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800abb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800abe:	fd                   	std    
  800abf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac1:	eb 09                	jmp    800acc <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ac3:	83 ef 01             	sub    $0x1,%edi
  800ac6:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ac9:	fd                   	std    
  800aca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800acc:	fc                   	cld    
  800acd:	eb 1a                	jmp    800ae9 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acf:	89 c2                	mov    %eax,%edx
  800ad1:	09 ca                	or     %ecx,%edx
  800ad3:	09 f2                	or     %esi,%edx
  800ad5:	f6 c2 03             	test   $0x3,%dl
  800ad8:	75 0a                	jne    800ae4 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ada:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800add:	89 c7                	mov    %eax,%edi
  800adf:	fc                   	cld    
  800ae0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae2:	eb 05                	jmp    800ae9 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800ae4:	89 c7                	mov    %eax,%edi
  800ae6:	fc                   	cld    
  800ae7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ae9:	5e                   	pop    %esi
  800aea:	5f                   	pop    %edi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aed:	f3 0f 1e fb          	endbr32 
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800af7:	ff 75 10             	pushl  0x10(%ebp)
  800afa:	ff 75 0c             	pushl  0xc(%ebp)
  800afd:	ff 75 08             	pushl  0x8(%ebp)
  800b00:	e8 82 ff ff ff       	call   800a87 <memmove>
}
  800b05:	c9                   	leave  
  800b06:	c3                   	ret    

00800b07 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b07:	f3 0f 1e fb          	endbr32 
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b16:	89 c6                	mov    %eax,%esi
  800b18:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1b:	39 f0                	cmp    %esi,%eax
  800b1d:	74 1c                	je     800b3b <memcmp+0x34>
		if (*s1 != *s2)
  800b1f:	0f b6 08             	movzbl (%eax),%ecx
  800b22:	0f b6 1a             	movzbl (%edx),%ebx
  800b25:	38 d9                	cmp    %bl,%cl
  800b27:	75 08                	jne    800b31 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b29:	83 c0 01             	add    $0x1,%eax
  800b2c:	83 c2 01             	add    $0x1,%edx
  800b2f:	eb ea                	jmp    800b1b <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800b31:	0f b6 c1             	movzbl %cl,%eax
  800b34:	0f b6 db             	movzbl %bl,%ebx
  800b37:	29 d8                	sub    %ebx,%eax
  800b39:	eb 05                	jmp    800b40 <memcmp+0x39>
	}

	return 0;
  800b3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b44:	f3 0f 1e fb          	endbr32 
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b51:	89 c2                	mov    %eax,%edx
  800b53:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b56:	39 d0                	cmp    %edx,%eax
  800b58:	73 09                	jae    800b63 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b5a:	38 08                	cmp    %cl,(%eax)
  800b5c:	74 05                	je     800b63 <memfind+0x1f>
	for (; s < ends; s++)
  800b5e:	83 c0 01             	add    $0x1,%eax
  800b61:	eb f3                	jmp    800b56 <memfind+0x12>
			break;
	return (void *) s;
}
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b65:	f3 0f 1e fb          	endbr32 
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
  800b6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b72:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b75:	eb 03                	jmp    800b7a <strtol+0x15>
		s++;
  800b77:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b7a:	0f b6 01             	movzbl (%ecx),%eax
  800b7d:	3c 20                	cmp    $0x20,%al
  800b7f:	74 f6                	je     800b77 <strtol+0x12>
  800b81:	3c 09                	cmp    $0x9,%al
  800b83:	74 f2                	je     800b77 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b85:	3c 2b                	cmp    $0x2b,%al
  800b87:	74 2a                	je     800bb3 <strtol+0x4e>
	int neg = 0;
  800b89:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b8e:	3c 2d                	cmp    $0x2d,%al
  800b90:	74 2b                	je     800bbd <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b92:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b98:	75 0f                	jne    800ba9 <strtol+0x44>
  800b9a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b9d:	74 28                	je     800bc7 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b9f:	85 db                	test   %ebx,%ebx
  800ba1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ba6:	0f 44 d8             	cmove  %eax,%ebx
  800ba9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bae:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bb1:	eb 46                	jmp    800bf9 <strtol+0x94>
		s++;
  800bb3:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bb6:	bf 00 00 00 00       	mov    $0x0,%edi
  800bbb:	eb d5                	jmp    800b92 <strtol+0x2d>
		s++, neg = 1;
  800bbd:	83 c1 01             	add    $0x1,%ecx
  800bc0:	bf 01 00 00 00       	mov    $0x1,%edi
  800bc5:	eb cb                	jmp    800b92 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bcb:	74 0e                	je     800bdb <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bcd:	85 db                	test   %ebx,%ebx
  800bcf:	75 d8                	jne    800ba9 <strtol+0x44>
		s++, base = 8;
  800bd1:	83 c1 01             	add    $0x1,%ecx
  800bd4:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bd9:	eb ce                	jmp    800ba9 <strtol+0x44>
		s += 2, base = 16;
  800bdb:	83 c1 02             	add    $0x2,%ecx
  800bde:	bb 10 00 00 00       	mov    $0x10,%ebx
  800be3:	eb c4                	jmp    800ba9 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800be5:	0f be d2             	movsbl %dl,%edx
  800be8:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800beb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bee:	7d 3a                	jge    800c2a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bf0:	83 c1 01             	add    $0x1,%ecx
  800bf3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bf7:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bf9:	0f b6 11             	movzbl (%ecx),%edx
  800bfc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bff:	89 f3                	mov    %esi,%ebx
  800c01:	80 fb 09             	cmp    $0x9,%bl
  800c04:	76 df                	jbe    800be5 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800c06:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c09:	89 f3                	mov    %esi,%ebx
  800c0b:	80 fb 19             	cmp    $0x19,%bl
  800c0e:	77 08                	ja     800c18 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c10:	0f be d2             	movsbl %dl,%edx
  800c13:	83 ea 57             	sub    $0x57,%edx
  800c16:	eb d3                	jmp    800beb <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800c18:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c1b:	89 f3                	mov    %esi,%ebx
  800c1d:	80 fb 19             	cmp    $0x19,%bl
  800c20:	77 08                	ja     800c2a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c22:	0f be d2             	movsbl %dl,%edx
  800c25:	83 ea 37             	sub    $0x37,%edx
  800c28:	eb c1                	jmp    800beb <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c2a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c2e:	74 05                	je     800c35 <strtol+0xd0>
		*endptr = (char *) s;
  800c30:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c33:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c35:	89 c2                	mov    %eax,%edx
  800c37:	f7 da                	neg    %edx
  800c39:	85 ff                	test   %edi,%edi
  800c3b:	0f 45 c2             	cmovne %edx,%eax
}
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c43:	f3 0f 1e fb          	endbr32 
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c52:	8b 55 08             	mov    0x8(%ebp),%edx
  800c55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c58:	89 c3                	mov    %eax,%ebx
  800c5a:	89 c7                	mov    %eax,%edi
  800c5c:	89 c6                	mov    %eax,%esi
  800c5e:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c65:	f3 0f 1e fb          	endbr32 
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c74:	b8 01 00 00 00       	mov    $0x1,%eax
  800c79:	89 d1                	mov    %edx,%ecx
  800c7b:	89 d3                	mov    %edx,%ebx
  800c7d:	89 d7                	mov    %edx,%edi
  800c7f:	89 d6                	mov    %edx,%esi
  800c81:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c88:	f3 0f 1e fb          	endbr32 
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	b8 03 00 00 00       	mov    $0x3,%eax
  800ca2:	89 cb                	mov    %ecx,%ebx
  800ca4:	89 cf                	mov    %ecx,%edi
  800ca6:	89 ce                	mov    %ecx,%esi
  800ca8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800caa:	85 c0                	test   %eax,%eax
  800cac:	7f 08                	jg     800cb6 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb6:	83 ec 0c             	sub    $0xc,%esp
  800cb9:	50                   	push   %eax
  800cba:	6a 03                	push   $0x3
  800cbc:	68 7f 19 80 00       	push   $0x80197f
  800cc1:	6a 23                	push   $0x23
  800cc3:	68 9c 19 80 00       	push   $0x80199c
  800cc8:	e8 9d 05 00 00       	call   80126a <_panic>

00800ccd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ccd:	f3 0f 1e fb          	endbr32 
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdc:	b8 02 00 00 00       	mov    $0x2,%eax
  800ce1:	89 d1                	mov    %edx,%ecx
  800ce3:	89 d3                	mov    %edx,%ebx
  800ce5:	89 d7                	mov    %edx,%edi
  800ce7:	89 d6                	mov    %edx,%esi
  800ce9:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <sys_yield>:

void
sys_yield(void)
{
  800cf0:	f3 0f 1e fb          	endbr32 
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cfa:	ba 00 00 00 00       	mov    $0x0,%edx
  800cff:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d04:	89 d1                	mov    %edx,%ecx
  800d06:	89 d3                	mov    %edx,%ebx
  800d08:	89 d7                	mov    %edx,%edi
  800d0a:	89 d6                	mov    %edx,%esi
  800d0c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d13:	f3 0f 1e fb          	endbr32 
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
  800d1d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d20:	be 00 00 00 00       	mov    $0x0,%esi
  800d25:	8b 55 08             	mov    0x8(%ebp),%edx
  800d28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2b:	b8 04 00 00 00       	mov    $0x4,%eax
  800d30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d33:	89 f7                	mov    %esi,%edi
  800d35:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d37:	85 c0                	test   %eax,%eax
  800d39:	7f 08                	jg     800d43 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d43:	83 ec 0c             	sub    $0xc,%esp
  800d46:	50                   	push   %eax
  800d47:	6a 04                	push   $0x4
  800d49:	68 7f 19 80 00       	push   $0x80197f
  800d4e:	6a 23                	push   $0x23
  800d50:	68 9c 19 80 00       	push   $0x80199c
  800d55:	e8 10 05 00 00       	call   80126a <_panic>

00800d5a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d5a:	f3 0f 1e fb          	endbr32 
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d67:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6d:	b8 05 00 00 00       	mov    $0x5,%eax
  800d72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d75:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d78:	8b 75 18             	mov    0x18(%ebp),%esi
  800d7b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7f 08                	jg     800d89 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d89:	83 ec 0c             	sub    $0xc,%esp
  800d8c:	50                   	push   %eax
  800d8d:	6a 05                	push   $0x5
  800d8f:	68 7f 19 80 00       	push   $0x80197f
  800d94:	6a 23                	push   $0x23
  800d96:	68 9c 19 80 00       	push   $0x80199c
  800d9b:	e8 ca 04 00 00       	call   80126a <_panic>

00800da0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800da0:	f3 0f 1e fb          	endbr32 
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
  800daa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	b8 06 00 00 00       	mov    $0x6,%eax
  800dbd:	89 df                	mov    %ebx,%edi
  800dbf:	89 de                	mov    %ebx,%esi
  800dc1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	7f 08                	jg     800dcf <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dca:	5b                   	pop    %ebx
  800dcb:	5e                   	pop    %esi
  800dcc:	5f                   	pop    %edi
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcf:	83 ec 0c             	sub    $0xc,%esp
  800dd2:	50                   	push   %eax
  800dd3:	6a 06                	push   $0x6
  800dd5:	68 7f 19 80 00       	push   $0x80197f
  800dda:	6a 23                	push   $0x23
  800ddc:	68 9c 19 80 00       	push   $0x80199c
  800de1:	e8 84 04 00 00       	call   80126a <_panic>

00800de6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800de6:	f3 0f 1e fb          	endbr32 
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	57                   	push   %edi
  800dee:	56                   	push   %esi
  800def:	53                   	push   %ebx
  800df0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800df3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfe:	b8 08 00 00 00       	mov    $0x8,%eax
  800e03:	89 df                	mov    %ebx,%edi
  800e05:	89 de                	mov    %ebx,%esi
  800e07:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	7f 08                	jg     800e15 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e15:	83 ec 0c             	sub    $0xc,%esp
  800e18:	50                   	push   %eax
  800e19:	6a 08                	push   $0x8
  800e1b:	68 7f 19 80 00       	push   $0x80197f
  800e20:	6a 23                	push   $0x23
  800e22:	68 9c 19 80 00       	push   $0x80199c
  800e27:	e8 3e 04 00 00       	call   80126a <_panic>

00800e2c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e2c:	f3 0f 1e fb          	endbr32 
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	57                   	push   %edi
  800e34:	56                   	push   %esi
  800e35:	53                   	push   %ebx
  800e36:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e44:	b8 09 00 00 00       	mov    $0x9,%eax
  800e49:	89 df                	mov    %ebx,%edi
  800e4b:	89 de                	mov    %ebx,%esi
  800e4d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	7f 08                	jg     800e5b <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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
  800e5f:	6a 09                	push   $0x9
  800e61:	68 7f 19 80 00       	push   $0x80197f
  800e66:	6a 23                	push   $0x23
  800e68:	68 9c 19 80 00       	push   $0x80199c
  800e6d:	e8 f8 03 00 00       	call   80126a <_panic>

00800e72 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e72:	f3 0f 1e fb          	endbr32 
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	57                   	push   %edi
  800e7a:	56                   	push   %esi
  800e7b:	53                   	push   %ebx
  800e7c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e84:	8b 55 08             	mov    0x8(%ebp),%edx
  800e87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e8f:	89 df                	mov    %ebx,%edi
  800e91:	89 de                	mov    %ebx,%esi
  800e93:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e95:	85 c0                	test   %eax,%eax
  800e97:	7f 08                	jg     800ea1 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9c:	5b                   	pop    %ebx
  800e9d:	5e                   	pop    %esi
  800e9e:	5f                   	pop    %edi
  800e9f:	5d                   	pop    %ebp
  800ea0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea1:	83 ec 0c             	sub    $0xc,%esp
  800ea4:	50                   	push   %eax
  800ea5:	6a 0a                	push   $0xa
  800ea7:	68 7f 19 80 00       	push   $0x80197f
  800eac:	6a 23                	push   $0x23
  800eae:	68 9c 19 80 00       	push   $0x80199c
  800eb3:	e8 b2 03 00 00       	call   80126a <_panic>

00800eb8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eb8:	f3 0f 1e fb          	endbr32 
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	57                   	push   %edi
  800ec0:	56                   	push   %esi
  800ec1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ec2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ecd:	be 00 00 00 00       	mov    $0x0,%esi
  800ed2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ed8:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eda:	5b                   	pop    %ebx
  800edb:	5e                   	pop    %esi
  800edc:	5f                   	pop    %edi
  800edd:	5d                   	pop    %ebp
  800ede:	c3                   	ret    

00800edf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800edf:	f3 0f 1e fb          	endbr32 
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	57                   	push   %edi
  800ee7:	56                   	push   %esi
  800ee8:	53                   	push   %ebx
  800ee9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800eec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ef1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef4:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ef9:	89 cb                	mov    %ecx,%ebx
  800efb:	89 cf                	mov    %ecx,%edi
  800efd:	89 ce                	mov    %ecx,%esi
  800eff:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f01:	85 c0                	test   %eax,%eax
  800f03:	7f 08                	jg     800f0d <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f08:	5b                   	pop    %ebx
  800f09:	5e                   	pop    %esi
  800f0a:	5f                   	pop    %edi
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0d:	83 ec 0c             	sub    $0xc,%esp
  800f10:	50                   	push   %eax
  800f11:	6a 0d                	push   $0xd
  800f13:	68 7f 19 80 00       	push   $0x80197f
  800f18:	6a 23                	push   $0x23
  800f1a:	68 9c 19 80 00       	push   $0x80199c
  800f1f:	e8 46 03 00 00       	call   80126a <_panic>

00800f24 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f24:	f3 0f 1e fb          	endbr32 
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	53                   	push   %ebx
  800f2c:	83 ec 04             	sub    $0x4,%esp
  800f2f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f32:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if ( !(err & FEC_WR) ||
  800f34:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f38:	74 75                	je     800faf <pgfault+0x8b>
            !(uvpt[PGNUM(addr)] | PTE_COW) ) {
  800f3a:	89 d8                	mov    %ebx,%eax
  800f3c:	c1 e8 0c             	shr    $0xc,%eax
  800f3f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0) {
  800f46:	83 ec 04             	sub    $0x4,%esp
  800f49:	6a 07                	push   $0x7
  800f4b:	68 00 f0 7f 00       	push   $0x7ff000
  800f50:	6a 00                	push   $0x0
  800f52:	e8 bc fd ff ff       	call   800d13 <sys_page_alloc>
  800f57:	83 c4 10             	add    $0x10,%esp
  800f5a:	85 c0                	test   %eax,%eax
  800f5c:	78 65                	js     800fc3 <pgfault+0x9f>
        panic("sys_page_alloc failed %e\n", r);
    }
    memmove((void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);
  800f5e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800f64:	83 ec 04             	sub    $0x4,%esp
  800f67:	68 00 10 00 00       	push   $0x1000
  800f6c:	53                   	push   %ebx
  800f6d:	68 00 f0 7f 00       	push   $0x7ff000
  800f72:	e8 10 fb ff ff       	call   800a87 <memmove>
    if ((r = sys_page_map(0, (void *)PFTEMP,
  800f77:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f7e:	53                   	push   %ebx
  800f7f:	6a 00                	push   $0x0
  800f81:	68 00 f0 7f 00       	push   $0x7ff000
  800f86:	6a 00                	push   $0x0
  800f88:	e8 cd fd ff ff       	call   800d5a <sys_page_map>
  800f8d:	83 c4 20             	add    $0x20,%esp
  800f90:	85 c0                	test   %eax,%eax
  800f92:	78 41                	js     800fd5 <pgfault+0xb1>
                0, (void *)PTE_ADDR(addr), PTE_P | PTE_U | PTE_W)) < 0) {
        panic("sys_page_map failed %e\n", r);
    }
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0) {
  800f94:	83 ec 08             	sub    $0x8,%esp
  800f97:	68 00 f0 7f 00       	push   $0x7ff000
  800f9c:	6a 00                	push   $0x0
  800f9e:	e8 fd fd ff ff       	call   800da0 <sys_page_unmap>
  800fa3:	83 c4 10             	add    $0x10,%esp
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	78 3d                	js     800fe7 <pgfault+0xc3>
        panic("sys_page_unmap failed %e\n", r);
    }

}
  800faa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fad:	c9                   	leave  
  800fae:	c3                   	ret    
        panic("Not a copy-on-write page");
  800faf:	83 ec 04             	sub    $0x4,%esp
  800fb2:	68 aa 19 80 00       	push   $0x8019aa
  800fb7:	6a 1e                	push   $0x1e
  800fb9:	68 c3 19 80 00       	push   $0x8019c3
  800fbe:	e8 a7 02 00 00       	call   80126a <_panic>
        panic("sys_page_alloc failed %e\n", r);
  800fc3:	50                   	push   %eax
  800fc4:	68 ce 19 80 00       	push   $0x8019ce
  800fc9:	6a 2a                	push   $0x2a
  800fcb:	68 c3 19 80 00       	push   $0x8019c3
  800fd0:	e8 95 02 00 00       	call   80126a <_panic>
        panic("sys_page_map failed %e\n", r);
  800fd5:	50                   	push   %eax
  800fd6:	68 e8 19 80 00       	push   $0x8019e8
  800fdb:	6a 2f                	push   $0x2f
  800fdd:	68 c3 19 80 00       	push   $0x8019c3
  800fe2:	e8 83 02 00 00       	call   80126a <_panic>
        panic("sys_page_unmap failed %e\n", r);
  800fe7:	50                   	push   %eax
  800fe8:	68 00 1a 80 00       	push   $0x801a00
  800fed:	6a 32                	push   $0x32
  800fef:	68 c3 19 80 00       	push   $0x8019c3
  800ff4:	e8 71 02 00 00       	call   80126a <_panic>

00800ff9 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ff9:	f3 0f 1e fb          	endbr32 
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	57                   	push   %edi
  801001:	56                   	push   %esi
  801002:	53                   	push   %ebx
  801003:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");

    // 1. set pgfault handler.
    set_pgfault_handler(pgfault);
  801006:	68 24 0f 80 00       	push   $0x800f24
  80100b:	e8 a4 02 00 00       	call   8012b4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801010:	b8 07 00 00 00       	mov    $0x7,%eax
  801015:	cd 30                	int    $0x30
  801017:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80101a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 2. exofork.
    envid_t envid = sys_exofork();

    if (envid < 0)
  80101d:	83 c4 10             	add    $0x10,%esp
  801020:	85 c0                	test   %eax,%eax
  801022:	78 2a                	js     80104e <fork+0x55>
        thisenv = &envs[ENVX(my_envid)];
        return 0;
    }
    else {
        // parent
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  801024:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  801029:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80102d:	75 69                	jne    801098 <fork+0x9f>
        envid_t my_envid = sys_getenvid();
  80102f:	e8 99 fc ff ff       	call   800ccd <sys_getenvid>
        thisenv = &envs[ENVX(my_envid)];
  801034:	25 ff 03 00 00       	and    $0x3ff,%eax
  801039:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80103c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801041:	a3 0c 20 80 00       	mov    %eax,0x80200c
        return 0;
  801046:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801049:	e9 fc 00 00 00       	jmp    80114a <fork+0x151>
        panic("fork, sys_exofork %e", envid);
  80104e:	50                   	push   %eax
  80104f:	68 1a 1a 80 00       	push   $0x801a1a
  801054:	6a 7b                	push   $0x7b
  801056:	68 c3 19 80 00       	push   $0x8019c3
  80105b:	e8 0a 02 00 00       	call   80126a <_panic>
    if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0) {
  801060:	83 ec 0c             	sub    $0xc,%esp
  801063:	57                   	push   %edi
  801064:	56                   	push   %esi
  801065:	ff 75 e4             	pushl  -0x1c(%ebp)
  801068:	56                   	push   %esi
  801069:	6a 00                	push   $0x0
  80106b:	e8 ea fc ff ff       	call   800d5a <sys_page_map>
  801070:	83 c4 20             	add    $0x20,%esp
  801073:	85 c0                	test   %eax,%eax
  801075:	78 69                	js     8010e0 <fork+0xe7>
        if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0) {
  801077:	83 ec 0c             	sub    $0xc,%esp
  80107a:	57                   	push   %edi
  80107b:	56                   	push   %esi
  80107c:	6a 00                	push   $0x0
  80107e:	56                   	push   %esi
  80107f:	6a 00                	push   $0x0
  801081:	e8 d4 fc ff ff       	call   800d5a <sys_page_map>
  801086:	83 c4 20             	add    $0x20,%esp
  801089:	85 c0                	test   %eax,%eax
  80108b:	78 65                	js     8010f2 <fork+0xf9>
        for (uint32_t pn = 0; pn < (USTACKTOP >> PGSHIFT); ++pn) {
  80108d:	83 c3 01             	add    $0x1,%ebx
  801090:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801096:	74 6c                	je     801104 <fork+0x10b>
  801098:	89 de                	mov    %ebx,%esi
  80109a:	c1 e6 0c             	shl    $0xc,%esi
            uintptr_t pgaddr = pn << PGSHIFT;
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  80109d:	89 f0                	mov    %esi,%eax
  80109f:	c1 e8 16             	shr    $0x16,%eax
  8010a2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010a9:	a8 01                	test   $0x1,%al
  8010ab:	74 e0                	je     80108d <fork+0x94>
                    (uvpt[pn] & PTE_P) ) {
  8010ad:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
            if ( (uvpd[PDX(pgaddr)] & PTE_P) &&
  8010b4:	a8 01                	test   $0x1,%al
  8010b6:	74 d5                	je     80108d <fork+0x94>
    pte_t pte = uvpt[pn];
  8010b8:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    int perm = PTE_U | PTE_P;
  8010bf:	bf 05 00 00 00       	mov    $0x5,%edi
    if ( ((pte & PTE_W) || (pte & PTE_COW)) && !(pte & PTE_SHARE)) {
  8010c4:	a9 02 08 00 00       	test   $0x802,%eax
  8010c9:	74 95                	je     801060 <fork+0x67>
  8010cb:	25 00 04 00 00       	and    $0x400,%eax
        perm |= PTE_COW;
  8010d0:	83 f8 01             	cmp    $0x1,%eax
  8010d3:	19 ff                	sbb    %edi,%edi
  8010d5:	81 e7 00 08 00 00    	and    $0x800,%edi
  8010db:	83 c7 05             	add    $0x5,%edi
  8010de:	eb 80                	jmp    801060 <fork+0x67>
        panic("sys_page_map others failed %e\n", r);
  8010e0:	50                   	push   %eax
  8010e1:	68 64 1a 80 00       	push   $0x801a64
  8010e6:	6a 51                	push   $0x51
  8010e8:	68 c3 19 80 00       	push   $0x8019c3
  8010ed:	e8 78 01 00 00       	call   80126a <_panic>
            panic("sys_page_map mine failed %e\n", r);
  8010f2:	50                   	push   %eax
  8010f3:	68 2f 1a 80 00       	push   $0x801a2f
  8010f8:	6a 56                	push   $0x56
  8010fa:	68 c3 19 80 00       	push   $0x8019c3
  8010ff:	e8 66 01 00 00       	call   80126a <_panic>
            }
        }

        int r;

        if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),
  801104:	83 ec 04             	sub    $0x4,%esp
  801107:	6a 07                	push   $0x7
  801109:	68 00 f0 bf ee       	push   $0xeebff000
  80110e:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801111:	57                   	push   %edi
  801112:	e8 fc fb ff ff       	call   800d13 <sys_page_alloc>
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	85 c0                	test   %eax,%eax
  80111c:	78 2c                	js     80114a <fork+0x151>
                    PTE_U | PTE_W | PTE_P)) < 0) {
            return r;
        }

        if ((r = sys_env_set_pgfault_upcall(envid,
                        thisenv->env_pgfault_upcall)) < 0) {
  80111e:	a1 0c 20 80 00       	mov    0x80200c,%eax
        if ((r = sys_env_set_pgfault_upcall(envid,
  801123:	8b 40 64             	mov    0x64(%eax),%eax
  801126:	83 ec 08             	sub    $0x8,%esp
  801129:	50                   	push   %eax
  80112a:	57                   	push   %edi
  80112b:	e8 42 fd ff ff       	call   800e72 <sys_env_set_pgfault_upcall>
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	85 c0                	test   %eax,%eax
  801135:	78 13                	js     80114a <fork+0x151>
            return r;
        }

        if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801137:	83 ec 08             	sub    $0x8,%esp
  80113a:	6a 02                	push   $0x2
  80113c:	57                   	push   %edi
  80113d:	e8 a4 fc ff ff       	call   800de6 <sys_env_set_status>
  801142:	83 c4 10             	add    $0x10,%esp
            return r;
        }
        return envid;
  801145:	85 c0                	test   %eax,%eax
  801147:	0f 49 c7             	cmovns %edi,%eax
    }

}
  80114a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114d:	5b                   	pop    %ebx
  80114e:	5e                   	pop    %esi
  80114f:	5f                   	pop    %edi
  801150:	5d                   	pop    %ebp
  801151:	c3                   	ret    

00801152 <sfork>:

// Challenge!
int
sfork(void)
{
  801152:	f3 0f 1e fb          	endbr32 
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80115c:	68 4c 1a 80 00       	push   $0x801a4c
  801161:	68 a5 00 00 00       	push   $0xa5
  801166:	68 c3 19 80 00       	push   $0x8019c3
  80116b:	e8 fa 00 00 00       	call   80126a <_panic>

00801170 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801170:	f3 0f 1e fb          	endbr32 
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	56                   	push   %esi
  801178:	53                   	push   %ebx
  801179:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80117c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117f:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801182:	85 c0                	test   %eax,%eax
  801184:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801189:	0f 44 c2             	cmove  %edx,%eax
  80118c:	83 ec 0c             	sub    $0xc,%esp
  80118f:	50                   	push   %eax
  801190:	e8 4a fd ff ff       	call   800edf <sys_ipc_recv>
  801195:	83 c4 10             	add    $0x10,%esp
  801198:	85 c0                	test   %eax,%eax
  80119a:	78 24                	js     8011c0 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  80119c:	85 f6                	test   %esi,%esi
  80119e:	74 0a                	je     8011aa <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  8011a0:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8011a5:	8b 40 78             	mov    0x78(%eax),%eax
  8011a8:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  8011aa:	85 db                	test   %ebx,%ebx
  8011ac:	74 0a                	je     8011b8 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  8011ae:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8011b3:	8b 40 74             	mov    0x74(%eax),%eax
  8011b6:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  8011b8:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8011bd:	8b 40 70             	mov    0x70(%eax),%eax
}
  8011c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011c3:	5b                   	pop    %ebx
  8011c4:	5e                   	pop    %esi
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011c7:	f3 0f 1e fb          	endbr32 
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	57                   	push   %edi
  8011cf:	56                   	push   %esi
  8011d0:	53                   	push   %ebx
  8011d1:	83 ec 1c             	sub    $0x1c,%esp
  8011d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8011de:	0f 45 d0             	cmovne %eax,%edx
  8011e1:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  8011e3:	be 01 00 00 00       	mov    $0x1,%esi
  8011e8:	eb 1f                	jmp    801209 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  8011ea:	e8 01 fb ff ff       	call   800cf0 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  8011ef:	83 c3 01             	add    $0x1,%ebx
  8011f2:	39 de                	cmp    %ebx,%esi
  8011f4:	7f f4                	jg     8011ea <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  8011f6:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  8011f8:	83 fe 11             	cmp    $0x11,%esi
  8011fb:	b8 01 00 00 00       	mov    $0x1,%eax
  801200:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801203:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801207:	75 1c                	jne    801225 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801209:	ff 75 14             	pushl  0x14(%ebp)
  80120c:	57                   	push   %edi
  80120d:	ff 75 0c             	pushl  0xc(%ebp)
  801210:	ff 75 08             	pushl  0x8(%ebp)
  801213:	e8 a0 fc ff ff       	call   800eb8 <sys_ipc_try_send>
  801218:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  80121b:	83 c4 10             	add    $0x10,%esp
  80121e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801223:	eb cd                	jmp    8011f2 <ipc_send+0x2b>
}
  801225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801228:	5b                   	pop    %ebx
  801229:	5e                   	pop    %esi
  80122a:	5f                   	pop    %edi
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80122d:	f3 0f 1e fb          	endbr32 
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
  801234:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801237:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80123c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80123f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801245:	8b 52 50             	mov    0x50(%edx),%edx
  801248:	39 ca                	cmp    %ecx,%edx
  80124a:	74 11                	je     80125d <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  80124c:	83 c0 01             	add    $0x1,%eax
  80124f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801254:	75 e6                	jne    80123c <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801256:	b8 00 00 00 00       	mov    $0x0,%eax
  80125b:	eb 0b                	jmp    801268 <ipc_find_env+0x3b>
			return envs[i].env_id;
  80125d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801260:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801265:	8b 40 48             	mov    0x48(%eax),%eax
}
  801268:	5d                   	pop    %ebp
  801269:	c3                   	ret    

0080126a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80126a:	f3 0f 1e fb          	endbr32 
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	56                   	push   %esi
  801272:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801273:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801276:	8b 35 08 20 80 00    	mov    0x802008,%esi
  80127c:	e8 4c fa ff ff       	call   800ccd <sys_getenvid>
  801281:	83 ec 0c             	sub    $0xc,%esp
  801284:	ff 75 0c             	pushl  0xc(%ebp)
  801287:	ff 75 08             	pushl  0x8(%ebp)
  80128a:	56                   	push   %esi
  80128b:	50                   	push   %eax
  80128c:	68 84 1a 80 00       	push   $0x801a84
  801291:	e8 32 f0 ff ff       	call   8002c8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801296:	83 c4 18             	add    $0x18,%esp
  801299:	53                   	push   %ebx
  80129a:	ff 75 10             	pushl  0x10(%ebp)
  80129d:	e8 d1 ef ff ff       	call   800273 <vcprintf>
	cprintf("\n");
  8012a2:	c7 04 24 b4 1a 80 00 	movl   $0x801ab4,(%esp)
  8012a9:	e8 1a f0 ff ff       	call   8002c8 <cprintf>
  8012ae:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8012b1:	cc                   	int3   
  8012b2:	eb fd                	jmp    8012b1 <_panic+0x47>

008012b4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012b4:	f3 0f 1e fb          	endbr32 
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012be:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  8012c5:	74 0a                	je     8012d1 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ca:	a3 10 20 80 00       	mov    %eax,0x802010
}
  8012cf:	c9                   	leave  
  8012d0:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  8012d1:	83 ec 0c             	sub    $0xc,%esp
  8012d4:	68 a7 1a 80 00       	push   $0x801aa7
  8012d9:	e8 ea ef ff ff       	call   8002c8 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  8012de:	83 c4 0c             	add    $0xc,%esp
  8012e1:	6a 07                	push   $0x7
  8012e3:	68 00 f0 bf ee       	push   $0xeebff000
  8012e8:	6a 00                	push   $0x0
  8012ea:	e8 24 fa ff ff       	call   800d13 <sys_page_alloc>
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	78 2a                	js     801320 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  8012f6:	83 ec 08             	sub    $0x8,%esp
  8012f9:	68 34 13 80 00       	push   $0x801334
  8012fe:	6a 00                	push   $0x0
  801300:	e8 6d fb ff ff       	call   800e72 <sys_env_set_pgfault_upcall>
  801305:	83 c4 10             	add    $0x10,%esp
  801308:	85 c0                	test   %eax,%eax
  80130a:	79 bb                	jns    8012c7 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  80130c:	83 ec 04             	sub    $0x4,%esp
  80130f:	68 e4 1a 80 00       	push   $0x801ae4
  801314:	6a 25                	push   $0x25
  801316:	68 d4 1a 80 00       	push   $0x801ad4
  80131b:	e8 4a ff ff ff       	call   80126a <_panic>
            panic("Allocation of UXSTACK failed!");
  801320:	83 ec 04             	sub    $0x4,%esp
  801323:	68 b6 1a 80 00       	push   $0x801ab6
  801328:	6a 22                	push   $0x22
  80132a:	68 d4 1a 80 00       	push   $0x801ad4
  80132f:	e8 36 ff ff ff       	call   80126a <_panic>

00801334 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801334:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801335:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  80133a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80133c:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  80133f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  801343:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  801347:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  80134a:	83 c4 08             	add    $0x8,%esp
    popa
  80134d:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  80134e:	83 c4 04             	add    $0x4,%esp
    popf
  801351:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  801352:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  801355:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  801359:	c3                   	ret    
  80135a:	66 90                	xchg   %ax,%ax
  80135c:	66 90                	xchg   %ax,%ax
  80135e:	66 90                	xchg   %ax,%ax

00801360 <__udivdi3>:
  801360:	f3 0f 1e fb          	endbr32 
  801364:	55                   	push   %ebp
  801365:	57                   	push   %edi
  801366:	56                   	push   %esi
  801367:	53                   	push   %ebx
  801368:	83 ec 1c             	sub    $0x1c,%esp
  80136b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80136f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801373:	8b 74 24 34          	mov    0x34(%esp),%esi
  801377:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80137b:	85 d2                	test   %edx,%edx
  80137d:	75 19                	jne    801398 <__udivdi3+0x38>
  80137f:	39 f3                	cmp    %esi,%ebx
  801381:	76 4d                	jbe    8013d0 <__udivdi3+0x70>
  801383:	31 ff                	xor    %edi,%edi
  801385:	89 e8                	mov    %ebp,%eax
  801387:	89 f2                	mov    %esi,%edx
  801389:	f7 f3                	div    %ebx
  80138b:	89 fa                	mov    %edi,%edx
  80138d:	83 c4 1c             	add    $0x1c,%esp
  801390:	5b                   	pop    %ebx
  801391:	5e                   	pop    %esi
  801392:	5f                   	pop    %edi
  801393:	5d                   	pop    %ebp
  801394:	c3                   	ret    
  801395:	8d 76 00             	lea    0x0(%esi),%esi
  801398:	39 f2                	cmp    %esi,%edx
  80139a:	76 14                	jbe    8013b0 <__udivdi3+0x50>
  80139c:	31 ff                	xor    %edi,%edi
  80139e:	31 c0                	xor    %eax,%eax
  8013a0:	89 fa                	mov    %edi,%edx
  8013a2:	83 c4 1c             	add    $0x1c,%esp
  8013a5:	5b                   	pop    %ebx
  8013a6:	5e                   	pop    %esi
  8013a7:	5f                   	pop    %edi
  8013a8:	5d                   	pop    %ebp
  8013a9:	c3                   	ret    
  8013aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013b0:	0f bd fa             	bsr    %edx,%edi
  8013b3:	83 f7 1f             	xor    $0x1f,%edi
  8013b6:	75 48                	jne    801400 <__udivdi3+0xa0>
  8013b8:	39 f2                	cmp    %esi,%edx
  8013ba:	72 06                	jb     8013c2 <__udivdi3+0x62>
  8013bc:	31 c0                	xor    %eax,%eax
  8013be:	39 eb                	cmp    %ebp,%ebx
  8013c0:	77 de                	ja     8013a0 <__udivdi3+0x40>
  8013c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8013c7:	eb d7                	jmp    8013a0 <__udivdi3+0x40>
  8013c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013d0:	89 d9                	mov    %ebx,%ecx
  8013d2:	85 db                	test   %ebx,%ebx
  8013d4:	75 0b                	jne    8013e1 <__udivdi3+0x81>
  8013d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013db:	31 d2                	xor    %edx,%edx
  8013dd:	f7 f3                	div    %ebx
  8013df:	89 c1                	mov    %eax,%ecx
  8013e1:	31 d2                	xor    %edx,%edx
  8013e3:	89 f0                	mov    %esi,%eax
  8013e5:	f7 f1                	div    %ecx
  8013e7:	89 c6                	mov    %eax,%esi
  8013e9:	89 e8                	mov    %ebp,%eax
  8013eb:	89 f7                	mov    %esi,%edi
  8013ed:	f7 f1                	div    %ecx
  8013ef:	89 fa                	mov    %edi,%edx
  8013f1:	83 c4 1c             	add    $0x1c,%esp
  8013f4:	5b                   	pop    %ebx
  8013f5:	5e                   	pop    %esi
  8013f6:	5f                   	pop    %edi
  8013f7:	5d                   	pop    %ebp
  8013f8:	c3                   	ret    
  8013f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801400:	89 f9                	mov    %edi,%ecx
  801402:	b8 20 00 00 00       	mov    $0x20,%eax
  801407:	29 f8                	sub    %edi,%eax
  801409:	d3 e2                	shl    %cl,%edx
  80140b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80140f:	89 c1                	mov    %eax,%ecx
  801411:	89 da                	mov    %ebx,%edx
  801413:	d3 ea                	shr    %cl,%edx
  801415:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801419:	09 d1                	or     %edx,%ecx
  80141b:	89 f2                	mov    %esi,%edx
  80141d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801421:	89 f9                	mov    %edi,%ecx
  801423:	d3 e3                	shl    %cl,%ebx
  801425:	89 c1                	mov    %eax,%ecx
  801427:	d3 ea                	shr    %cl,%edx
  801429:	89 f9                	mov    %edi,%ecx
  80142b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80142f:	89 eb                	mov    %ebp,%ebx
  801431:	d3 e6                	shl    %cl,%esi
  801433:	89 c1                	mov    %eax,%ecx
  801435:	d3 eb                	shr    %cl,%ebx
  801437:	09 de                	or     %ebx,%esi
  801439:	89 f0                	mov    %esi,%eax
  80143b:	f7 74 24 08          	divl   0x8(%esp)
  80143f:	89 d6                	mov    %edx,%esi
  801441:	89 c3                	mov    %eax,%ebx
  801443:	f7 64 24 0c          	mull   0xc(%esp)
  801447:	39 d6                	cmp    %edx,%esi
  801449:	72 15                	jb     801460 <__udivdi3+0x100>
  80144b:	89 f9                	mov    %edi,%ecx
  80144d:	d3 e5                	shl    %cl,%ebp
  80144f:	39 c5                	cmp    %eax,%ebp
  801451:	73 04                	jae    801457 <__udivdi3+0xf7>
  801453:	39 d6                	cmp    %edx,%esi
  801455:	74 09                	je     801460 <__udivdi3+0x100>
  801457:	89 d8                	mov    %ebx,%eax
  801459:	31 ff                	xor    %edi,%edi
  80145b:	e9 40 ff ff ff       	jmp    8013a0 <__udivdi3+0x40>
  801460:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801463:	31 ff                	xor    %edi,%edi
  801465:	e9 36 ff ff ff       	jmp    8013a0 <__udivdi3+0x40>
  80146a:	66 90                	xchg   %ax,%ax
  80146c:	66 90                	xchg   %ax,%ax
  80146e:	66 90                	xchg   %ax,%ax

00801470 <__umoddi3>:
  801470:	f3 0f 1e fb          	endbr32 
  801474:	55                   	push   %ebp
  801475:	57                   	push   %edi
  801476:	56                   	push   %esi
  801477:	53                   	push   %ebx
  801478:	83 ec 1c             	sub    $0x1c,%esp
  80147b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80147f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801483:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801487:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80148b:	85 c0                	test   %eax,%eax
  80148d:	75 19                	jne    8014a8 <__umoddi3+0x38>
  80148f:	39 df                	cmp    %ebx,%edi
  801491:	76 5d                	jbe    8014f0 <__umoddi3+0x80>
  801493:	89 f0                	mov    %esi,%eax
  801495:	89 da                	mov    %ebx,%edx
  801497:	f7 f7                	div    %edi
  801499:	89 d0                	mov    %edx,%eax
  80149b:	31 d2                	xor    %edx,%edx
  80149d:	83 c4 1c             	add    $0x1c,%esp
  8014a0:	5b                   	pop    %ebx
  8014a1:	5e                   	pop    %esi
  8014a2:	5f                   	pop    %edi
  8014a3:	5d                   	pop    %ebp
  8014a4:	c3                   	ret    
  8014a5:	8d 76 00             	lea    0x0(%esi),%esi
  8014a8:	89 f2                	mov    %esi,%edx
  8014aa:	39 d8                	cmp    %ebx,%eax
  8014ac:	76 12                	jbe    8014c0 <__umoddi3+0x50>
  8014ae:	89 f0                	mov    %esi,%eax
  8014b0:	89 da                	mov    %ebx,%edx
  8014b2:	83 c4 1c             	add    $0x1c,%esp
  8014b5:	5b                   	pop    %ebx
  8014b6:	5e                   	pop    %esi
  8014b7:	5f                   	pop    %edi
  8014b8:	5d                   	pop    %ebp
  8014b9:	c3                   	ret    
  8014ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014c0:	0f bd e8             	bsr    %eax,%ebp
  8014c3:	83 f5 1f             	xor    $0x1f,%ebp
  8014c6:	75 50                	jne    801518 <__umoddi3+0xa8>
  8014c8:	39 d8                	cmp    %ebx,%eax
  8014ca:	0f 82 e0 00 00 00    	jb     8015b0 <__umoddi3+0x140>
  8014d0:	89 d9                	mov    %ebx,%ecx
  8014d2:	39 f7                	cmp    %esi,%edi
  8014d4:	0f 86 d6 00 00 00    	jbe    8015b0 <__umoddi3+0x140>
  8014da:	89 d0                	mov    %edx,%eax
  8014dc:	89 ca                	mov    %ecx,%edx
  8014de:	83 c4 1c             	add    $0x1c,%esp
  8014e1:	5b                   	pop    %ebx
  8014e2:	5e                   	pop    %esi
  8014e3:	5f                   	pop    %edi
  8014e4:	5d                   	pop    %ebp
  8014e5:	c3                   	ret    
  8014e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014ed:	8d 76 00             	lea    0x0(%esi),%esi
  8014f0:	89 fd                	mov    %edi,%ebp
  8014f2:	85 ff                	test   %edi,%edi
  8014f4:	75 0b                	jne    801501 <__umoddi3+0x91>
  8014f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014fb:	31 d2                	xor    %edx,%edx
  8014fd:	f7 f7                	div    %edi
  8014ff:	89 c5                	mov    %eax,%ebp
  801501:	89 d8                	mov    %ebx,%eax
  801503:	31 d2                	xor    %edx,%edx
  801505:	f7 f5                	div    %ebp
  801507:	89 f0                	mov    %esi,%eax
  801509:	f7 f5                	div    %ebp
  80150b:	89 d0                	mov    %edx,%eax
  80150d:	31 d2                	xor    %edx,%edx
  80150f:	eb 8c                	jmp    80149d <__umoddi3+0x2d>
  801511:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801518:	89 e9                	mov    %ebp,%ecx
  80151a:	ba 20 00 00 00       	mov    $0x20,%edx
  80151f:	29 ea                	sub    %ebp,%edx
  801521:	d3 e0                	shl    %cl,%eax
  801523:	89 44 24 08          	mov    %eax,0x8(%esp)
  801527:	89 d1                	mov    %edx,%ecx
  801529:	89 f8                	mov    %edi,%eax
  80152b:	d3 e8                	shr    %cl,%eax
  80152d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801531:	89 54 24 04          	mov    %edx,0x4(%esp)
  801535:	8b 54 24 04          	mov    0x4(%esp),%edx
  801539:	09 c1                	or     %eax,%ecx
  80153b:	89 d8                	mov    %ebx,%eax
  80153d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801541:	89 e9                	mov    %ebp,%ecx
  801543:	d3 e7                	shl    %cl,%edi
  801545:	89 d1                	mov    %edx,%ecx
  801547:	d3 e8                	shr    %cl,%eax
  801549:	89 e9                	mov    %ebp,%ecx
  80154b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80154f:	d3 e3                	shl    %cl,%ebx
  801551:	89 c7                	mov    %eax,%edi
  801553:	89 d1                	mov    %edx,%ecx
  801555:	89 f0                	mov    %esi,%eax
  801557:	d3 e8                	shr    %cl,%eax
  801559:	89 e9                	mov    %ebp,%ecx
  80155b:	89 fa                	mov    %edi,%edx
  80155d:	d3 e6                	shl    %cl,%esi
  80155f:	09 d8                	or     %ebx,%eax
  801561:	f7 74 24 08          	divl   0x8(%esp)
  801565:	89 d1                	mov    %edx,%ecx
  801567:	89 f3                	mov    %esi,%ebx
  801569:	f7 64 24 0c          	mull   0xc(%esp)
  80156d:	89 c6                	mov    %eax,%esi
  80156f:	89 d7                	mov    %edx,%edi
  801571:	39 d1                	cmp    %edx,%ecx
  801573:	72 06                	jb     80157b <__umoddi3+0x10b>
  801575:	75 10                	jne    801587 <__umoddi3+0x117>
  801577:	39 c3                	cmp    %eax,%ebx
  801579:	73 0c                	jae    801587 <__umoddi3+0x117>
  80157b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80157f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801583:	89 d7                	mov    %edx,%edi
  801585:	89 c6                	mov    %eax,%esi
  801587:	89 ca                	mov    %ecx,%edx
  801589:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80158e:	29 f3                	sub    %esi,%ebx
  801590:	19 fa                	sbb    %edi,%edx
  801592:	89 d0                	mov    %edx,%eax
  801594:	d3 e0                	shl    %cl,%eax
  801596:	89 e9                	mov    %ebp,%ecx
  801598:	d3 eb                	shr    %cl,%ebx
  80159a:	d3 ea                	shr    %cl,%edx
  80159c:	09 d8                	or     %ebx,%eax
  80159e:	83 c4 1c             	add    $0x1c,%esp
  8015a1:	5b                   	pop    %ebx
  8015a2:	5e                   	pop    %esi
  8015a3:	5f                   	pop    %edi
  8015a4:	5d                   	pop    %ebp
  8015a5:	c3                   	ret    
  8015a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8015ad:	8d 76 00             	lea    0x0(%esi),%esi
  8015b0:	29 fe                	sub    %edi,%esi
  8015b2:	19 c3                	sbb    %eax,%ebx
  8015b4:	89 f2                	mov    %esi,%edx
  8015b6:	89 d9                	mov    %ebx,%ecx
  8015b8:	e9 1d ff ff ff       	jmp    8014da <__umoddi3+0x6a>
