
obj/user/faultregs:     file format elf32-i386


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
  80002c:	e8 b8 05 00 00       	call   8005e9 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 b1 16 80 00       	push   $0x8016b1
  800049:	68 80 16 80 00       	push   $0x801680
  80004e:	e8 e7 06 00 00       	call   80073a <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 90 16 80 00       	push   $0x801690
  80005c:	68 94 16 80 00       	push   $0x801694
  800061:	e8 d4 06 00 00       	call   80073a <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	0f 84 2e 02 00 00    	je     8002a1 <check_regs+0x26e>
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	68 a8 16 80 00       	push   $0x8016a8
  80007b:	e8 ba 06 00 00       	call   80073a <cprintf>
  800080:	83 c4 10             	add    $0x10,%esp
  800083:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  800088:	ff 73 04             	pushl  0x4(%ebx)
  80008b:	ff 76 04             	pushl  0x4(%esi)
  80008e:	68 b2 16 80 00       	push   $0x8016b2
  800093:	68 94 16 80 00       	push   $0x801694
  800098:	e8 9d 06 00 00       	call   80073a <cprintf>
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8000a3:	39 46 04             	cmp    %eax,0x4(%esi)
  8000a6:	0f 84 0f 02 00 00    	je     8002bb <check_regs+0x288>
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 a8 16 80 00       	push   $0x8016a8
  8000b4:	e8 81 06 00 00       	call   80073a <cprintf>
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000c1:	ff 73 08             	pushl  0x8(%ebx)
  8000c4:	ff 76 08             	pushl  0x8(%esi)
  8000c7:	68 b6 16 80 00       	push   $0x8016b6
  8000cc:	68 94 16 80 00       	push   $0x801694
  8000d1:	e8 64 06 00 00       	call   80073a <cprintf>
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8b 43 08             	mov    0x8(%ebx),%eax
  8000dc:	39 46 08             	cmp    %eax,0x8(%esi)
  8000df:	0f 84 eb 01 00 00    	je     8002d0 <check_regs+0x29d>
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	68 a8 16 80 00       	push   $0x8016a8
  8000ed:	e8 48 06 00 00       	call   80073a <cprintf>
  8000f2:	83 c4 10             	add    $0x10,%esp
  8000f5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  8000fa:	ff 73 10             	pushl  0x10(%ebx)
  8000fd:	ff 76 10             	pushl  0x10(%esi)
  800100:	68 ba 16 80 00       	push   $0x8016ba
  800105:	68 94 16 80 00       	push   $0x801694
  80010a:	e8 2b 06 00 00       	call   80073a <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	8b 43 10             	mov    0x10(%ebx),%eax
  800115:	39 46 10             	cmp    %eax,0x10(%esi)
  800118:	0f 84 c7 01 00 00    	je     8002e5 <check_regs+0x2b2>
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	68 a8 16 80 00       	push   $0x8016a8
  800126:	e8 0f 06 00 00       	call   80073a <cprintf>
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800133:	ff 73 14             	pushl  0x14(%ebx)
  800136:	ff 76 14             	pushl  0x14(%esi)
  800139:	68 be 16 80 00       	push   $0x8016be
  80013e:	68 94 16 80 00       	push   $0x801694
  800143:	e8 f2 05 00 00       	call   80073a <cprintf>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	8b 43 14             	mov    0x14(%ebx),%eax
  80014e:	39 46 14             	cmp    %eax,0x14(%esi)
  800151:	0f 84 a3 01 00 00    	je     8002fa <check_regs+0x2c7>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	68 a8 16 80 00       	push   $0x8016a8
  80015f:	e8 d6 05 00 00       	call   80073a <cprintf>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  80016c:	ff 73 18             	pushl  0x18(%ebx)
  80016f:	ff 76 18             	pushl  0x18(%esi)
  800172:	68 c2 16 80 00       	push   $0x8016c2
  800177:	68 94 16 80 00       	push   $0x801694
  80017c:	e8 b9 05 00 00       	call   80073a <cprintf>
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	8b 43 18             	mov    0x18(%ebx),%eax
  800187:	39 46 18             	cmp    %eax,0x18(%esi)
  80018a:	0f 84 7f 01 00 00    	je     80030f <check_regs+0x2dc>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 a8 16 80 00       	push   $0x8016a8
  800198:	e8 9d 05 00 00       	call   80073a <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001a5:	ff 73 1c             	pushl  0x1c(%ebx)
  8001a8:	ff 76 1c             	pushl  0x1c(%esi)
  8001ab:	68 c6 16 80 00       	push   $0x8016c6
  8001b0:	68 94 16 80 00       	push   $0x801694
  8001b5:	e8 80 05 00 00       	call   80073a <cprintf>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	8b 43 1c             	mov    0x1c(%ebx),%eax
  8001c0:	39 46 1c             	cmp    %eax,0x1c(%esi)
  8001c3:	0f 84 5b 01 00 00    	je     800324 <check_regs+0x2f1>
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	68 a8 16 80 00       	push   $0x8016a8
  8001d1:	e8 64 05 00 00       	call   80073a <cprintf>
  8001d6:	83 c4 10             	add    $0x10,%esp
  8001d9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  8001de:	ff 73 20             	pushl  0x20(%ebx)
  8001e1:	ff 76 20             	pushl  0x20(%esi)
  8001e4:	68 ca 16 80 00       	push   $0x8016ca
  8001e9:	68 94 16 80 00       	push   $0x801694
  8001ee:	e8 47 05 00 00       	call   80073a <cprintf>
  8001f3:	83 c4 10             	add    $0x10,%esp
  8001f6:	8b 43 20             	mov    0x20(%ebx),%eax
  8001f9:	39 46 20             	cmp    %eax,0x20(%esi)
  8001fc:	0f 84 37 01 00 00    	je     800339 <check_regs+0x306>
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	68 a8 16 80 00       	push   $0x8016a8
  80020a:	e8 2b 05 00 00       	call   80073a <cprintf>
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  800217:	ff 73 24             	pushl  0x24(%ebx)
  80021a:	ff 76 24             	pushl  0x24(%esi)
  80021d:	68 ce 16 80 00       	push   $0x8016ce
  800222:	68 94 16 80 00       	push   $0x801694
  800227:	e8 0e 05 00 00       	call   80073a <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8b 43 24             	mov    0x24(%ebx),%eax
  800232:	39 46 24             	cmp    %eax,0x24(%esi)
  800235:	0f 84 13 01 00 00    	je     80034e <check_regs+0x31b>
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	68 a8 16 80 00       	push   $0x8016a8
  800243:	e8 f2 04 00 00       	call   80073a <cprintf>
	CHECK(esp, esp);
  800248:	ff 73 28             	pushl  0x28(%ebx)
  80024b:	ff 76 28             	pushl  0x28(%esi)
  80024e:	68 d5 16 80 00       	push   $0x8016d5
  800253:	68 94 16 80 00       	push   $0x801694
  800258:	e8 dd 04 00 00       	call   80073a <cprintf>
  80025d:	83 c4 20             	add    $0x20,%esp
  800260:	8b 43 28             	mov    0x28(%ebx),%eax
  800263:	39 46 28             	cmp    %eax,0x28(%esi)
  800266:	0f 84 53 01 00 00    	je     8003bf <check_regs+0x38c>
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	68 a8 16 80 00       	push   $0x8016a8
  800274:	e8 c1 04 00 00       	call   80073a <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800279:	83 c4 08             	add    $0x8,%esp
  80027c:	ff 75 0c             	pushl  0xc(%ebp)
  80027f:	68 d9 16 80 00       	push   $0x8016d9
  800284:	e8 b1 04 00 00       	call   80073a <cprintf>
  800289:	83 c4 10             	add    $0x10,%esp
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	68 a8 16 80 00       	push   $0x8016a8
  800294:	e8 a1 04 00 00       	call   80073a <cprintf>
  800299:	83 c4 10             	add    $0x10,%esp
}
  80029c:	e9 16 01 00 00       	jmp    8003b7 <check_regs+0x384>
	CHECK(edi, regs.reg_edi);
  8002a1:	83 ec 0c             	sub    $0xc,%esp
  8002a4:	68 a4 16 80 00       	push   $0x8016a4
  8002a9:	e8 8c 04 00 00       	call   80073a <cprintf>
  8002ae:	83 c4 10             	add    $0x10,%esp
	int mismatch = 0;
  8002b1:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b6:	e9 cd fd ff ff       	jmp    800088 <check_regs+0x55>
	CHECK(esi, regs.reg_esi);
  8002bb:	83 ec 0c             	sub    $0xc,%esp
  8002be:	68 a4 16 80 00       	push   $0x8016a4
  8002c3:	e8 72 04 00 00       	call   80073a <cprintf>
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	e9 f1 fd ff ff       	jmp    8000c1 <check_regs+0x8e>
	CHECK(ebp, regs.reg_ebp);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	68 a4 16 80 00       	push   $0x8016a4
  8002d8:	e8 5d 04 00 00       	call   80073a <cprintf>
  8002dd:	83 c4 10             	add    $0x10,%esp
  8002e0:	e9 15 fe ff ff       	jmp    8000fa <check_regs+0xc7>
	CHECK(ebx, regs.reg_ebx);
  8002e5:	83 ec 0c             	sub    $0xc,%esp
  8002e8:	68 a4 16 80 00       	push   $0x8016a4
  8002ed:	e8 48 04 00 00       	call   80073a <cprintf>
  8002f2:	83 c4 10             	add    $0x10,%esp
  8002f5:	e9 39 fe ff ff       	jmp    800133 <check_regs+0x100>
	CHECK(edx, regs.reg_edx);
  8002fa:	83 ec 0c             	sub    $0xc,%esp
  8002fd:	68 a4 16 80 00       	push   $0x8016a4
  800302:	e8 33 04 00 00       	call   80073a <cprintf>
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	e9 5d fe ff ff       	jmp    80016c <check_regs+0x139>
	CHECK(ecx, regs.reg_ecx);
  80030f:	83 ec 0c             	sub    $0xc,%esp
  800312:	68 a4 16 80 00       	push   $0x8016a4
  800317:	e8 1e 04 00 00       	call   80073a <cprintf>
  80031c:	83 c4 10             	add    $0x10,%esp
  80031f:	e9 81 fe ff ff       	jmp    8001a5 <check_regs+0x172>
	CHECK(eax, regs.reg_eax);
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	68 a4 16 80 00       	push   $0x8016a4
  80032c:	e8 09 04 00 00       	call   80073a <cprintf>
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	e9 a5 fe ff ff       	jmp    8001de <check_regs+0x1ab>
	CHECK(eip, eip);
  800339:	83 ec 0c             	sub    $0xc,%esp
  80033c:	68 a4 16 80 00       	push   $0x8016a4
  800341:	e8 f4 03 00 00       	call   80073a <cprintf>
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	e9 c9 fe ff ff       	jmp    800217 <check_regs+0x1e4>
	CHECK(eflags, eflags);
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	68 a4 16 80 00       	push   $0x8016a4
  800356:	e8 df 03 00 00       	call   80073a <cprintf>
	CHECK(esp, esp);
  80035b:	ff 73 28             	pushl  0x28(%ebx)
  80035e:	ff 76 28             	pushl  0x28(%esi)
  800361:	68 d5 16 80 00       	push   $0x8016d5
  800366:	68 94 16 80 00       	push   $0x801694
  80036b:	e8 ca 03 00 00       	call   80073a <cprintf>
  800370:	83 c4 20             	add    $0x20,%esp
  800373:	8b 43 28             	mov    0x28(%ebx),%eax
  800376:	39 46 28             	cmp    %eax,0x28(%esi)
  800379:	0f 85 ed fe ff ff    	jne    80026c <check_regs+0x239>
  80037f:	83 ec 0c             	sub    $0xc,%esp
  800382:	68 a4 16 80 00       	push   $0x8016a4
  800387:	e8 ae 03 00 00       	call   80073a <cprintf>
	cprintf("Registers %s ", testname);
  80038c:	83 c4 08             	add    $0x8,%esp
  80038f:	ff 75 0c             	pushl  0xc(%ebp)
  800392:	68 d9 16 80 00       	push   $0x8016d9
  800397:	e8 9e 03 00 00       	call   80073a <cprintf>
	if (!mismatch)
  80039c:	83 c4 10             	add    $0x10,%esp
  80039f:	85 ff                	test   %edi,%edi
  8003a1:	0f 85 e5 fe ff ff    	jne    80028c <check_regs+0x259>
		cprintf("OK\n");
  8003a7:	83 ec 0c             	sub    $0xc,%esp
  8003aa:	68 a4 16 80 00       	push   $0x8016a4
  8003af:	e8 86 03 00 00       	call   80073a <cprintf>
  8003b4:	83 c4 10             	add    $0x10,%esp
}
  8003b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ba:	5b                   	pop    %ebx
  8003bb:	5e                   	pop    %esi
  8003bc:	5f                   	pop    %edi
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    
	CHECK(esp, esp);
  8003bf:	83 ec 0c             	sub    $0xc,%esp
  8003c2:	68 a4 16 80 00       	push   $0x8016a4
  8003c7:	e8 6e 03 00 00       	call   80073a <cprintf>
	cprintf("Registers %s ", testname);
  8003cc:	83 c4 08             	add    $0x8,%esp
  8003cf:	ff 75 0c             	pushl  0xc(%ebp)
  8003d2:	68 d9 16 80 00       	push   $0x8016d9
  8003d7:	e8 5e 03 00 00       	call   80073a <cprintf>
  8003dc:	83 c4 10             	add    $0x10,%esp
  8003df:	e9 a8 fe ff ff       	jmp    80028c <check_regs+0x259>

008003e4 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003e4:	f3 0f 1e fb          	endbr32 
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	83 ec 08             	sub    $0x8,%esp
  8003ee:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003f1:	8b 10                	mov    (%eax),%edx
  8003f3:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003f9:	0f 85 a3 00 00 00    	jne    8004a2 <pgfault+0xbe>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003ff:	8b 50 08             	mov    0x8(%eax),%edx
  800402:	89 15 60 20 80 00    	mov    %edx,0x802060
  800408:	8b 50 0c             	mov    0xc(%eax),%edx
  80040b:	89 15 64 20 80 00    	mov    %edx,0x802064
  800411:	8b 50 10             	mov    0x10(%eax),%edx
  800414:	89 15 68 20 80 00    	mov    %edx,0x802068
  80041a:	8b 50 14             	mov    0x14(%eax),%edx
  80041d:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  800423:	8b 50 18             	mov    0x18(%eax),%edx
  800426:	89 15 70 20 80 00    	mov    %edx,0x802070
  80042c:	8b 50 1c             	mov    0x1c(%eax),%edx
  80042f:	89 15 74 20 80 00    	mov    %edx,0x802074
  800435:	8b 50 20             	mov    0x20(%eax),%edx
  800438:	89 15 78 20 80 00    	mov    %edx,0x802078
  80043e:	8b 50 24             	mov    0x24(%eax),%edx
  800441:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800447:	8b 50 28             	mov    0x28(%eax),%edx
  80044a:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags & ~FL_RF;
  800450:	8b 50 2c             	mov    0x2c(%eax),%edx
  800453:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800459:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  80045f:	8b 40 30             	mov    0x30(%eax),%eax
  800462:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	68 ff 16 80 00       	push   $0x8016ff
  80046f:	68 0d 17 80 00       	push   $0x80170d
  800474:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800479:	ba f8 16 80 00       	mov    $0x8016f8,%edx
  80047e:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  800483:	e8 ab fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800488:	83 c4 0c             	add    $0xc,%esp
  80048b:	6a 07                	push   $0x7
  80048d:	68 00 00 40 00       	push   $0x400000
  800492:	6a 00                	push   $0x0
  800494:	e8 ec 0c 00 00       	call   801185 <sys_page_alloc>
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	85 c0                	test   %eax,%eax
  80049e:	78 1a                	js     8004ba <pgfault+0xd6>
		panic("sys_page_alloc: %e", r);
}
  8004a0:	c9                   	leave  
  8004a1:	c3                   	ret    
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8004a2:	83 ec 0c             	sub    $0xc,%esp
  8004a5:	ff 70 28             	pushl  0x28(%eax)
  8004a8:	52                   	push   %edx
  8004a9:	68 40 17 80 00       	push   $0x801740
  8004ae:	6a 50                	push   $0x50
  8004b0:	68 e7 16 80 00       	push   $0x8016e7
  8004b5:	e8 99 01 00 00       	call   800653 <_panic>
		panic("sys_page_alloc: %e", r);
  8004ba:	50                   	push   %eax
  8004bb:	68 14 17 80 00       	push   $0x801714
  8004c0:	6a 5c                	push   $0x5c
  8004c2:	68 e7 16 80 00       	push   $0x8016e7
  8004c7:	e8 87 01 00 00       	call   800653 <_panic>

008004cc <umain>:

void
umain(int argc, char **argv)
{
  8004cc:	f3 0f 1e fb          	endbr32 
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  8004d6:	68 e4 03 80 00       	push   $0x8003e4
  8004db:	e8 95 0e 00 00       	call   801375 <set_pgfault_handler>

	asm volatile(
  8004e0:	50                   	push   %eax
  8004e1:	9c                   	pushf  
  8004e2:	58                   	pop    %eax
  8004e3:	0d d5 08 00 00       	or     $0x8d5,%eax
  8004e8:	50                   	push   %eax
  8004e9:	9d                   	popf   
  8004ea:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  8004ef:	8d 05 2a 05 80 00    	lea    0x80052a,%eax
  8004f5:	a3 c0 20 80 00       	mov    %eax,0x8020c0
  8004fa:	58                   	pop    %eax
  8004fb:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  800501:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  800507:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  80050d:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  800513:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  800519:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  80051f:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  800524:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  80052a:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  800531:	00 00 00 
  800534:	89 3d 20 20 80 00    	mov    %edi,0x802020
  80053a:	89 35 24 20 80 00    	mov    %esi,0x802024
  800540:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  800546:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  80054c:	89 15 34 20 80 00    	mov    %edx,0x802034
  800552:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  800558:	a3 3c 20 80 00       	mov    %eax,0x80203c
  80055d:	89 25 48 20 80 00    	mov    %esp,0x802048
  800563:	8b 3d a0 20 80 00    	mov    0x8020a0,%edi
  800569:	8b 35 a4 20 80 00    	mov    0x8020a4,%esi
  80056f:	8b 2d a8 20 80 00    	mov    0x8020a8,%ebp
  800575:	8b 1d b0 20 80 00    	mov    0x8020b0,%ebx
  80057b:	8b 15 b4 20 80 00    	mov    0x8020b4,%edx
  800581:	8b 0d b8 20 80 00    	mov    0x8020b8,%ecx
  800587:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  80058c:	8b 25 c8 20 80 00    	mov    0x8020c8,%esp
  800592:	50                   	push   %eax
  800593:	9c                   	pushf  
  800594:	58                   	pop    %eax
  800595:	a3 44 20 80 00       	mov    %eax,0x802044
  80059a:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80059b:	83 c4 10             	add    $0x10,%esp
  80059e:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  8005a5:	75 30                	jne    8005d7 <umain+0x10b>
		cprintf("EIP after page-fault MISMATCH\n");
	after.eip = before.eip;
  8005a7:	a1 c0 20 80 00       	mov    0x8020c0,%eax
  8005ac:	a3 40 20 80 00       	mov    %eax,0x802040

	check_regs(&before, "before", &after, "after", "after page-fault");
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	68 27 17 80 00       	push   $0x801727
  8005b9:	68 38 17 80 00       	push   $0x801738
  8005be:	b9 20 20 80 00       	mov    $0x802020,%ecx
  8005c3:	ba f8 16 80 00       	mov    $0x8016f8,%edx
  8005c8:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  8005cd:	e8 61 fa ff ff       	call   800033 <check_regs>
}
  8005d2:	83 c4 10             	add    $0x10,%esp
  8005d5:	c9                   	leave  
  8005d6:	c3                   	ret    
		cprintf("EIP after page-fault MISMATCH\n");
  8005d7:	83 ec 0c             	sub    $0xc,%esp
  8005da:	68 74 17 80 00       	push   $0x801774
  8005df:	e8 56 01 00 00       	call   80073a <cprintf>
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	eb be                	jmp    8005a7 <umain+0xdb>

008005e9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8005e9:	f3 0f 1e fb          	endbr32 
  8005ed:	55                   	push   %ebp
  8005ee:	89 e5                	mov    %esp,%ebp
  8005f0:	56                   	push   %esi
  8005f1:	53                   	push   %ebx
  8005f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8005f8:	c7 05 cc 20 80 00 00 	movl   $0x0,0x8020cc
  8005ff:	00 00 00 
    envid_t envid = sys_getenvid();
  800602:	e8 38 0b 00 00       	call   80113f <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800607:	25 ff 03 00 00       	and    $0x3ff,%eax
  80060c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80060f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800614:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800619:	85 db                	test   %ebx,%ebx
  80061b:	7e 07                	jle    800624 <libmain+0x3b>
		binaryname = argv[0];
  80061d:	8b 06                	mov    (%esi),%eax
  80061f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	56                   	push   %esi
  800628:	53                   	push   %ebx
  800629:	e8 9e fe ff ff       	call   8004cc <umain>

	// exit gracefully
	exit();
  80062e:	e8 0a 00 00 00       	call   80063d <exit>
}
  800633:	83 c4 10             	add    $0x10,%esp
  800636:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800639:	5b                   	pop    %ebx
  80063a:	5e                   	pop    %esi
  80063b:	5d                   	pop    %ebp
  80063c:	c3                   	ret    

0080063d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80063d:	f3 0f 1e fb          	endbr32 
  800641:	55                   	push   %ebp
  800642:	89 e5                	mov    %esp,%ebp
  800644:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800647:	6a 00                	push   $0x0
  800649:	e8 ac 0a 00 00       	call   8010fa <sys_env_destroy>
}
  80064e:	83 c4 10             	add    $0x10,%esp
  800651:	c9                   	leave  
  800652:	c3                   	ret    

00800653 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800653:	f3 0f 1e fb          	endbr32 
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	56                   	push   %esi
  80065b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80065c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80065f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800665:	e8 d5 0a 00 00       	call   80113f <sys_getenvid>
  80066a:	83 ec 0c             	sub    $0xc,%esp
  80066d:	ff 75 0c             	pushl  0xc(%ebp)
  800670:	ff 75 08             	pushl  0x8(%ebp)
  800673:	56                   	push   %esi
  800674:	50                   	push   %eax
  800675:	68 a0 17 80 00       	push   $0x8017a0
  80067a:	e8 bb 00 00 00       	call   80073a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80067f:	83 c4 18             	add    $0x18,%esp
  800682:	53                   	push   %ebx
  800683:	ff 75 10             	pushl  0x10(%ebp)
  800686:	e8 5a 00 00 00       	call   8006e5 <vcprintf>
	cprintf("\n");
  80068b:	c7 04 24 b0 16 80 00 	movl   $0x8016b0,(%esp)
  800692:	e8 a3 00 00 00       	call   80073a <cprintf>
  800697:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80069a:	cc                   	int3   
  80069b:	eb fd                	jmp    80069a <_panic+0x47>

0080069d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80069d:	f3 0f 1e fb          	endbr32 
  8006a1:	55                   	push   %ebp
  8006a2:	89 e5                	mov    %esp,%ebp
  8006a4:	53                   	push   %ebx
  8006a5:	83 ec 04             	sub    $0x4,%esp
  8006a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006ab:	8b 13                	mov    (%ebx),%edx
  8006ad:	8d 42 01             	lea    0x1(%edx),%eax
  8006b0:	89 03                	mov    %eax,(%ebx)
  8006b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006b9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006be:	74 09                	je     8006c9 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8006c0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c7:	c9                   	leave  
  8006c8:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	68 ff 00 00 00       	push   $0xff
  8006d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8006d4:	50                   	push   %eax
  8006d5:	e8 db 09 00 00       	call   8010b5 <sys_cputs>
		b->idx = 0;
  8006da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	eb db                	jmp    8006c0 <putch+0x23>

008006e5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006e5:	f3 0f 1e fb          	endbr32 
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006f2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006f9:	00 00 00 
	b.cnt = 0;
  8006fc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800703:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800706:	ff 75 0c             	pushl  0xc(%ebp)
  800709:	ff 75 08             	pushl  0x8(%ebp)
  80070c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800712:	50                   	push   %eax
  800713:	68 9d 06 80 00       	push   $0x80069d
  800718:	e8 20 01 00 00       	call   80083d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80071d:	83 c4 08             	add    $0x8,%esp
  800720:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800726:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80072c:	50                   	push   %eax
  80072d:	e8 83 09 00 00       	call   8010b5 <sys_cputs>

	return b.cnt;
}
  800732:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800738:	c9                   	leave  
  800739:	c3                   	ret    

0080073a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80073a:	f3 0f 1e fb          	endbr32 
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800744:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800747:	50                   	push   %eax
  800748:	ff 75 08             	pushl  0x8(%ebp)
  80074b:	e8 95 ff ff ff       	call   8006e5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800750:	c9                   	leave  
  800751:	c3                   	ret    

00800752 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	57                   	push   %edi
  800756:	56                   	push   %esi
  800757:	53                   	push   %ebx
  800758:	83 ec 1c             	sub    $0x1c,%esp
  80075b:	89 c7                	mov    %eax,%edi
  80075d:	89 d6                	mov    %edx,%esi
  80075f:	8b 45 08             	mov    0x8(%ebp),%eax
  800762:	8b 55 0c             	mov    0xc(%ebp),%edx
  800765:	89 d1                	mov    %edx,%ecx
  800767:	89 c2                	mov    %eax,%edx
  800769:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80076c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80076f:	8b 45 10             	mov    0x10(%ebp),%eax
  800772:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800775:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800778:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80077f:	39 c2                	cmp    %eax,%edx
  800781:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800784:	72 3e                	jb     8007c4 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800786:	83 ec 0c             	sub    $0xc,%esp
  800789:	ff 75 18             	pushl  0x18(%ebp)
  80078c:	83 eb 01             	sub    $0x1,%ebx
  80078f:	53                   	push   %ebx
  800790:	50                   	push   %eax
  800791:	83 ec 08             	sub    $0x8,%esp
  800794:	ff 75 e4             	pushl  -0x1c(%ebp)
  800797:	ff 75 e0             	pushl  -0x20(%ebp)
  80079a:	ff 75 dc             	pushl  -0x24(%ebp)
  80079d:	ff 75 d8             	pushl  -0x28(%ebp)
  8007a0:	e8 7b 0c 00 00       	call   801420 <__udivdi3>
  8007a5:	83 c4 18             	add    $0x18,%esp
  8007a8:	52                   	push   %edx
  8007a9:	50                   	push   %eax
  8007aa:	89 f2                	mov    %esi,%edx
  8007ac:	89 f8                	mov    %edi,%eax
  8007ae:	e8 9f ff ff ff       	call   800752 <printnum>
  8007b3:	83 c4 20             	add    $0x20,%esp
  8007b6:	eb 13                	jmp    8007cb <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007b8:	83 ec 08             	sub    $0x8,%esp
  8007bb:	56                   	push   %esi
  8007bc:	ff 75 18             	pushl  0x18(%ebp)
  8007bf:	ff d7                	call   *%edi
  8007c1:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8007c4:	83 eb 01             	sub    $0x1,%ebx
  8007c7:	85 db                	test   %ebx,%ebx
  8007c9:	7f ed                	jg     8007b8 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007cb:	83 ec 08             	sub    $0x8,%esp
  8007ce:	56                   	push   %esi
  8007cf:	83 ec 04             	sub    $0x4,%esp
  8007d2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8007db:	ff 75 d8             	pushl  -0x28(%ebp)
  8007de:	e8 4d 0d 00 00       	call   801530 <__umoddi3>
  8007e3:	83 c4 14             	add    $0x14,%esp
  8007e6:	0f be 80 c3 17 80 00 	movsbl 0x8017c3(%eax),%eax
  8007ed:	50                   	push   %eax
  8007ee:	ff d7                	call   *%edi
}
  8007f0:	83 c4 10             	add    $0x10,%esp
  8007f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f6:	5b                   	pop    %ebx
  8007f7:	5e                   	pop    %esi
  8007f8:	5f                   	pop    %edi
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007fb:	f3 0f 1e fb          	endbr32 
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800805:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800809:	8b 10                	mov    (%eax),%edx
  80080b:	3b 50 04             	cmp    0x4(%eax),%edx
  80080e:	73 0a                	jae    80081a <sprintputch+0x1f>
		*b->buf++ = ch;
  800810:	8d 4a 01             	lea    0x1(%edx),%ecx
  800813:	89 08                	mov    %ecx,(%eax)
  800815:	8b 45 08             	mov    0x8(%ebp),%eax
  800818:	88 02                	mov    %al,(%edx)
}
  80081a:	5d                   	pop    %ebp
  80081b:	c3                   	ret    

0080081c <printfmt>:
{
  80081c:	f3 0f 1e fb          	endbr32 
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800826:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800829:	50                   	push   %eax
  80082a:	ff 75 10             	pushl  0x10(%ebp)
  80082d:	ff 75 0c             	pushl  0xc(%ebp)
  800830:	ff 75 08             	pushl  0x8(%ebp)
  800833:	e8 05 00 00 00       	call   80083d <vprintfmt>
}
  800838:	83 c4 10             	add    $0x10,%esp
  80083b:	c9                   	leave  
  80083c:	c3                   	ret    

0080083d <vprintfmt>:
{
  80083d:	f3 0f 1e fb          	endbr32 
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	57                   	push   %edi
  800845:	56                   	push   %esi
  800846:	53                   	push   %ebx
  800847:	83 ec 3c             	sub    $0x3c,%esp
  80084a:	8b 75 08             	mov    0x8(%ebp),%esi
  80084d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800850:	8b 7d 10             	mov    0x10(%ebp),%edi
  800853:	e9 4a 03 00 00       	jmp    800ba2 <vprintfmt+0x365>
		padc = ' ';
  800858:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80085c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800863:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80086a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800871:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800876:	8d 47 01             	lea    0x1(%edi),%eax
  800879:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80087c:	0f b6 17             	movzbl (%edi),%edx
  80087f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800882:	3c 55                	cmp    $0x55,%al
  800884:	0f 87 de 03 00 00    	ja     800c68 <vprintfmt+0x42b>
  80088a:	0f b6 c0             	movzbl %al,%eax
  80088d:	3e ff 24 85 00 19 80 	notrack jmp *0x801900(,%eax,4)
  800894:	00 
  800895:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800898:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80089c:	eb d8                	jmp    800876 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80089e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008a1:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8008a5:	eb cf                	jmp    800876 <vprintfmt+0x39>
  8008a7:	0f b6 d2             	movzbl %dl,%edx
  8008aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8008ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8008b5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8008b8:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8008bc:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8008bf:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8008c2:	83 f9 09             	cmp    $0x9,%ecx
  8008c5:	77 55                	ja     80091c <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8008c7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8008ca:	eb e9                	jmp    8008b5 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8008cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cf:	8b 00                	mov    (%eax),%eax
  8008d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d7:	8d 40 04             	lea    0x4(%eax),%eax
  8008da:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8008e0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008e4:	79 90                	jns    800876 <vprintfmt+0x39>
				width = precision, precision = -1;
  8008e6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008ec:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8008f3:	eb 81                	jmp    800876 <vprintfmt+0x39>
  8008f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008f8:	85 c0                	test   %eax,%eax
  8008fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ff:	0f 49 d0             	cmovns %eax,%edx
  800902:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800905:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800908:	e9 69 ff ff ff       	jmp    800876 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80090d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800910:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800917:	e9 5a ff ff ff       	jmp    800876 <vprintfmt+0x39>
  80091c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80091f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800922:	eb bc                	jmp    8008e0 <vprintfmt+0xa3>
			lflag++;
  800924:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800927:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80092a:	e9 47 ff ff ff       	jmp    800876 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80092f:	8b 45 14             	mov    0x14(%ebp),%eax
  800932:	8d 78 04             	lea    0x4(%eax),%edi
  800935:	83 ec 08             	sub    $0x8,%esp
  800938:	53                   	push   %ebx
  800939:	ff 30                	pushl  (%eax)
  80093b:	ff d6                	call   *%esi
			break;
  80093d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800940:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800943:	e9 57 02 00 00       	jmp    800b9f <vprintfmt+0x362>
			err = va_arg(ap, int);
  800948:	8b 45 14             	mov    0x14(%ebp),%eax
  80094b:	8d 78 04             	lea    0x4(%eax),%edi
  80094e:	8b 00                	mov    (%eax),%eax
  800950:	99                   	cltd   
  800951:	31 d0                	xor    %edx,%eax
  800953:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800955:	83 f8 0f             	cmp    $0xf,%eax
  800958:	7f 23                	jg     80097d <vprintfmt+0x140>
  80095a:	8b 14 85 60 1a 80 00 	mov    0x801a60(,%eax,4),%edx
  800961:	85 d2                	test   %edx,%edx
  800963:	74 18                	je     80097d <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800965:	52                   	push   %edx
  800966:	68 e4 17 80 00       	push   $0x8017e4
  80096b:	53                   	push   %ebx
  80096c:	56                   	push   %esi
  80096d:	e8 aa fe ff ff       	call   80081c <printfmt>
  800972:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800975:	89 7d 14             	mov    %edi,0x14(%ebp)
  800978:	e9 22 02 00 00       	jmp    800b9f <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  80097d:	50                   	push   %eax
  80097e:	68 db 17 80 00       	push   $0x8017db
  800983:	53                   	push   %ebx
  800984:	56                   	push   %esi
  800985:	e8 92 fe ff ff       	call   80081c <printfmt>
  80098a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80098d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800990:	e9 0a 02 00 00       	jmp    800b9f <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800995:	8b 45 14             	mov    0x14(%ebp),%eax
  800998:	83 c0 04             	add    $0x4,%eax
  80099b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80099e:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a1:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8009a3:	85 d2                	test   %edx,%edx
  8009a5:	b8 d4 17 80 00       	mov    $0x8017d4,%eax
  8009aa:	0f 45 c2             	cmovne %edx,%eax
  8009ad:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8009b0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009b4:	7e 06                	jle    8009bc <vprintfmt+0x17f>
  8009b6:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8009ba:	75 0d                	jne    8009c9 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009bc:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009bf:	89 c7                	mov    %eax,%edi
  8009c1:	03 45 e0             	add    -0x20(%ebp),%eax
  8009c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009c7:	eb 55                	jmp    800a1e <vprintfmt+0x1e1>
  8009c9:	83 ec 08             	sub    $0x8,%esp
  8009cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8009cf:	ff 75 cc             	pushl  -0x34(%ebp)
  8009d2:	e8 45 03 00 00       	call   800d1c <strnlen>
  8009d7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8009da:	29 c2                	sub    %eax,%edx
  8009dc:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8009df:	83 c4 10             	add    $0x10,%esp
  8009e2:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8009e4:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8009e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8009eb:	85 ff                	test   %edi,%edi
  8009ed:	7e 11                	jle    800a00 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8009ef:	83 ec 08             	sub    $0x8,%esp
  8009f2:	53                   	push   %ebx
  8009f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8009f6:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8009f8:	83 ef 01             	sub    $0x1,%edi
  8009fb:	83 c4 10             	add    $0x10,%esp
  8009fe:	eb eb                	jmp    8009eb <vprintfmt+0x1ae>
  800a00:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800a03:	85 d2                	test   %edx,%edx
  800a05:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0a:	0f 49 c2             	cmovns %edx,%eax
  800a0d:	29 c2                	sub    %eax,%edx
  800a0f:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800a12:	eb a8                	jmp    8009bc <vprintfmt+0x17f>
					putch(ch, putdat);
  800a14:	83 ec 08             	sub    $0x8,%esp
  800a17:	53                   	push   %ebx
  800a18:	52                   	push   %edx
  800a19:	ff d6                	call   *%esi
  800a1b:	83 c4 10             	add    $0x10,%esp
  800a1e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a21:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a23:	83 c7 01             	add    $0x1,%edi
  800a26:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a2a:	0f be d0             	movsbl %al,%edx
  800a2d:	85 d2                	test   %edx,%edx
  800a2f:	74 4b                	je     800a7c <vprintfmt+0x23f>
  800a31:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a35:	78 06                	js     800a3d <vprintfmt+0x200>
  800a37:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800a3b:	78 1e                	js     800a5b <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800a3d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800a41:	74 d1                	je     800a14 <vprintfmt+0x1d7>
  800a43:	0f be c0             	movsbl %al,%eax
  800a46:	83 e8 20             	sub    $0x20,%eax
  800a49:	83 f8 5e             	cmp    $0x5e,%eax
  800a4c:	76 c6                	jbe    800a14 <vprintfmt+0x1d7>
					putch('?', putdat);
  800a4e:	83 ec 08             	sub    $0x8,%esp
  800a51:	53                   	push   %ebx
  800a52:	6a 3f                	push   $0x3f
  800a54:	ff d6                	call   *%esi
  800a56:	83 c4 10             	add    $0x10,%esp
  800a59:	eb c3                	jmp    800a1e <vprintfmt+0x1e1>
  800a5b:	89 cf                	mov    %ecx,%edi
  800a5d:	eb 0e                	jmp    800a6d <vprintfmt+0x230>
				putch(' ', putdat);
  800a5f:	83 ec 08             	sub    $0x8,%esp
  800a62:	53                   	push   %ebx
  800a63:	6a 20                	push   $0x20
  800a65:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800a67:	83 ef 01             	sub    $0x1,%edi
  800a6a:	83 c4 10             	add    $0x10,%esp
  800a6d:	85 ff                	test   %edi,%edi
  800a6f:	7f ee                	jg     800a5f <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800a71:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800a74:	89 45 14             	mov    %eax,0x14(%ebp)
  800a77:	e9 23 01 00 00       	jmp    800b9f <vprintfmt+0x362>
  800a7c:	89 cf                	mov    %ecx,%edi
  800a7e:	eb ed                	jmp    800a6d <vprintfmt+0x230>
	if (lflag >= 2)
  800a80:	83 f9 01             	cmp    $0x1,%ecx
  800a83:	7f 1b                	jg     800aa0 <vprintfmt+0x263>
	else if (lflag)
  800a85:	85 c9                	test   %ecx,%ecx
  800a87:	74 63                	je     800aec <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800a89:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8c:	8b 00                	mov    (%eax),%eax
  800a8e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a91:	99                   	cltd   
  800a92:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a95:	8b 45 14             	mov    0x14(%ebp),%eax
  800a98:	8d 40 04             	lea    0x4(%eax),%eax
  800a9b:	89 45 14             	mov    %eax,0x14(%ebp)
  800a9e:	eb 17                	jmp    800ab7 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800aa0:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa3:	8b 50 04             	mov    0x4(%eax),%edx
  800aa6:	8b 00                	mov    (%eax),%eax
  800aa8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aab:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800aae:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab1:	8d 40 08             	lea    0x8(%eax),%eax
  800ab4:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800ab7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800aba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800abd:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800ac2:	85 c9                	test   %ecx,%ecx
  800ac4:	0f 89 bb 00 00 00    	jns    800b85 <vprintfmt+0x348>
				putch('-', putdat);
  800aca:	83 ec 08             	sub    $0x8,%esp
  800acd:	53                   	push   %ebx
  800ace:	6a 2d                	push   $0x2d
  800ad0:	ff d6                	call   *%esi
				num = -(long long) num;
  800ad2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ad5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800ad8:	f7 da                	neg    %edx
  800ada:	83 d1 00             	adc    $0x0,%ecx
  800add:	f7 d9                	neg    %ecx
  800adf:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800ae2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ae7:	e9 99 00 00 00       	jmp    800b85 <vprintfmt+0x348>
		return va_arg(*ap, int);
  800aec:	8b 45 14             	mov    0x14(%ebp),%eax
  800aef:	8b 00                	mov    (%eax),%eax
  800af1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800af4:	99                   	cltd   
  800af5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800af8:	8b 45 14             	mov    0x14(%ebp),%eax
  800afb:	8d 40 04             	lea    0x4(%eax),%eax
  800afe:	89 45 14             	mov    %eax,0x14(%ebp)
  800b01:	eb b4                	jmp    800ab7 <vprintfmt+0x27a>
	if (lflag >= 2)
  800b03:	83 f9 01             	cmp    $0x1,%ecx
  800b06:	7f 1b                	jg     800b23 <vprintfmt+0x2e6>
	else if (lflag)
  800b08:	85 c9                	test   %ecx,%ecx
  800b0a:	74 2c                	je     800b38 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800b0c:	8b 45 14             	mov    0x14(%ebp),%eax
  800b0f:	8b 10                	mov    (%eax),%edx
  800b11:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b16:	8d 40 04             	lea    0x4(%eax),%eax
  800b19:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b1c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800b21:	eb 62                	jmp    800b85 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800b23:	8b 45 14             	mov    0x14(%ebp),%eax
  800b26:	8b 10                	mov    (%eax),%edx
  800b28:	8b 48 04             	mov    0x4(%eax),%ecx
  800b2b:	8d 40 08             	lea    0x8(%eax),%eax
  800b2e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b31:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800b36:	eb 4d                	jmp    800b85 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800b38:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3b:	8b 10                	mov    (%eax),%edx
  800b3d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b42:	8d 40 04             	lea    0x4(%eax),%eax
  800b45:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b48:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800b4d:	eb 36                	jmp    800b85 <vprintfmt+0x348>
	if (lflag >= 2)
  800b4f:	83 f9 01             	cmp    $0x1,%ecx
  800b52:	7f 17                	jg     800b6b <vprintfmt+0x32e>
	else if (lflag)
  800b54:	85 c9                	test   %ecx,%ecx
  800b56:	74 6e                	je     800bc6 <vprintfmt+0x389>
		return va_arg(*ap, long);
  800b58:	8b 45 14             	mov    0x14(%ebp),%eax
  800b5b:	8b 10                	mov    (%eax),%edx
  800b5d:	89 d0                	mov    %edx,%eax
  800b5f:	99                   	cltd   
  800b60:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800b63:	8d 49 04             	lea    0x4(%ecx),%ecx
  800b66:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800b69:	eb 11                	jmp    800b7c <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800b6b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b6e:	8b 50 04             	mov    0x4(%eax),%edx
  800b71:	8b 00                	mov    (%eax),%eax
  800b73:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800b76:	8d 49 08             	lea    0x8(%ecx),%ecx
  800b79:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800b7c:	89 d1                	mov    %edx,%ecx
  800b7e:	89 c2                	mov    %eax,%edx
            base = 8;
  800b80:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800b85:	83 ec 0c             	sub    $0xc,%esp
  800b88:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800b8c:	57                   	push   %edi
  800b8d:	ff 75 e0             	pushl  -0x20(%ebp)
  800b90:	50                   	push   %eax
  800b91:	51                   	push   %ecx
  800b92:	52                   	push   %edx
  800b93:	89 da                	mov    %ebx,%edx
  800b95:	89 f0                	mov    %esi,%eax
  800b97:	e8 b6 fb ff ff       	call   800752 <printnum>
			break;
  800b9c:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800b9f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800ba2:	83 c7 01             	add    $0x1,%edi
  800ba5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ba9:	83 f8 25             	cmp    $0x25,%eax
  800bac:	0f 84 a6 fc ff ff    	je     800858 <vprintfmt+0x1b>
			if (ch == '\0')
  800bb2:	85 c0                	test   %eax,%eax
  800bb4:	0f 84 ce 00 00 00    	je     800c88 <vprintfmt+0x44b>
			putch(ch, putdat);
  800bba:	83 ec 08             	sub    $0x8,%esp
  800bbd:	53                   	push   %ebx
  800bbe:	50                   	push   %eax
  800bbf:	ff d6                	call   *%esi
  800bc1:	83 c4 10             	add    $0x10,%esp
  800bc4:	eb dc                	jmp    800ba2 <vprintfmt+0x365>
		return va_arg(*ap, int);
  800bc6:	8b 45 14             	mov    0x14(%ebp),%eax
  800bc9:	8b 10                	mov    (%eax),%edx
  800bcb:	89 d0                	mov    %edx,%eax
  800bcd:	99                   	cltd   
  800bce:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800bd1:	8d 49 04             	lea    0x4(%ecx),%ecx
  800bd4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800bd7:	eb a3                	jmp    800b7c <vprintfmt+0x33f>
			putch('0', putdat);
  800bd9:	83 ec 08             	sub    $0x8,%esp
  800bdc:	53                   	push   %ebx
  800bdd:	6a 30                	push   $0x30
  800bdf:	ff d6                	call   *%esi
			putch('x', putdat);
  800be1:	83 c4 08             	add    $0x8,%esp
  800be4:	53                   	push   %ebx
  800be5:	6a 78                	push   $0x78
  800be7:	ff d6                	call   *%esi
			num = (unsigned long long)
  800be9:	8b 45 14             	mov    0x14(%ebp),%eax
  800bec:	8b 10                	mov    (%eax),%edx
  800bee:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800bf3:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800bf6:	8d 40 04             	lea    0x4(%eax),%eax
  800bf9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800bfc:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800c01:	eb 82                	jmp    800b85 <vprintfmt+0x348>
	if (lflag >= 2)
  800c03:	83 f9 01             	cmp    $0x1,%ecx
  800c06:	7f 1e                	jg     800c26 <vprintfmt+0x3e9>
	else if (lflag)
  800c08:	85 c9                	test   %ecx,%ecx
  800c0a:	74 32                	je     800c3e <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800c0c:	8b 45 14             	mov    0x14(%ebp),%eax
  800c0f:	8b 10                	mov    (%eax),%edx
  800c11:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c16:	8d 40 04             	lea    0x4(%eax),%eax
  800c19:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c1c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800c21:	e9 5f ff ff ff       	jmp    800b85 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800c26:	8b 45 14             	mov    0x14(%ebp),%eax
  800c29:	8b 10                	mov    (%eax),%edx
  800c2b:	8b 48 04             	mov    0x4(%eax),%ecx
  800c2e:	8d 40 08             	lea    0x8(%eax),%eax
  800c31:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c34:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800c39:	e9 47 ff ff ff       	jmp    800b85 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800c3e:	8b 45 14             	mov    0x14(%ebp),%eax
  800c41:	8b 10                	mov    (%eax),%edx
  800c43:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c48:	8d 40 04             	lea    0x4(%eax),%eax
  800c4b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c4e:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800c53:	e9 2d ff ff ff       	jmp    800b85 <vprintfmt+0x348>
			putch(ch, putdat);
  800c58:	83 ec 08             	sub    $0x8,%esp
  800c5b:	53                   	push   %ebx
  800c5c:	6a 25                	push   $0x25
  800c5e:	ff d6                	call   *%esi
			break;
  800c60:	83 c4 10             	add    $0x10,%esp
  800c63:	e9 37 ff ff ff       	jmp    800b9f <vprintfmt+0x362>
			putch('%', putdat);
  800c68:	83 ec 08             	sub    $0x8,%esp
  800c6b:	53                   	push   %ebx
  800c6c:	6a 25                	push   $0x25
  800c6e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c70:	83 c4 10             	add    $0x10,%esp
  800c73:	89 f8                	mov    %edi,%eax
  800c75:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800c79:	74 05                	je     800c80 <vprintfmt+0x443>
  800c7b:	83 e8 01             	sub    $0x1,%eax
  800c7e:	eb f5                	jmp    800c75 <vprintfmt+0x438>
  800c80:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c83:	e9 17 ff ff ff       	jmp    800b9f <vprintfmt+0x362>
}
  800c88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c90:	f3 0f 1e fb          	endbr32 
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	83 ec 18             	sub    $0x18,%esp
  800c9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ca0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ca3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ca7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800caa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cb1:	85 c0                	test   %eax,%eax
  800cb3:	74 26                	je     800cdb <vsnprintf+0x4b>
  800cb5:	85 d2                	test   %edx,%edx
  800cb7:	7e 22                	jle    800cdb <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cb9:	ff 75 14             	pushl  0x14(%ebp)
  800cbc:	ff 75 10             	pushl  0x10(%ebp)
  800cbf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cc2:	50                   	push   %eax
  800cc3:	68 fb 07 80 00       	push   $0x8007fb
  800cc8:	e8 70 fb ff ff       	call   80083d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ccd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cd0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd6:	83 c4 10             	add    $0x10,%esp
}
  800cd9:	c9                   	leave  
  800cda:	c3                   	ret    
		return -E_INVAL;
  800cdb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ce0:	eb f7                	jmp    800cd9 <vsnprintf+0x49>

00800ce2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ce2:	f3 0f 1e fb          	endbr32 
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cec:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cef:	50                   	push   %eax
  800cf0:	ff 75 10             	pushl  0x10(%ebp)
  800cf3:	ff 75 0c             	pushl  0xc(%ebp)
  800cf6:	ff 75 08             	pushl  0x8(%ebp)
  800cf9:	e8 92 ff ff ff       	call   800c90 <vsnprintf>
	va_end(ap);

	return rc;
}
  800cfe:	c9                   	leave  
  800cff:	c3                   	ret    

00800d00 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d00:	f3 0f 1e fb          	endbr32 
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d13:	74 05                	je     800d1a <strlen+0x1a>
		n++;
  800d15:	83 c0 01             	add    $0x1,%eax
  800d18:	eb f5                	jmp    800d0f <strlen+0xf>
	return n;
}
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d1c:	f3 0f 1e fb          	endbr32 
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d26:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d29:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2e:	39 d0                	cmp    %edx,%eax
  800d30:	74 0d                	je     800d3f <strnlen+0x23>
  800d32:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d36:	74 05                	je     800d3d <strnlen+0x21>
		n++;
  800d38:	83 c0 01             	add    $0x1,%eax
  800d3b:	eb f1                	jmp    800d2e <strnlen+0x12>
  800d3d:	89 c2                	mov    %eax,%edx
	return n;
}
  800d3f:	89 d0                	mov    %edx,%eax
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d43:	f3 0f 1e fb          	endbr32 
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	53                   	push   %ebx
  800d4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d51:	b8 00 00 00 00       	mov    $0x0,%eax
  800d56:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800d5a:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800d5d:	83 c0 01             	add    $0x1,%eax
  800d60:	84 d2                	test   %dl,%dl
  800d62:	75 f2                	jne    800d56 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800d64:	89 c8                	mov    %ecx,%eax
  800d66:	5b                   	pop    %ebx
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d69:	f3 0f 1e fb          	endbr32 
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	53                   	push   %ebx
  800d71:	83 ec 10             	sub    $0x10,%esp
  800d74:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d77:	53                   	push   %ebx
  800d78:	e8 83 ff ff ff       	call   800d00 <strlen>
  800d7d:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800d80:	ff 75 0c             	pushl  0xc(%ebp)
  800d83:	01 d8                	add    %ebx,%eax
  800d85:	50                   	push   %eax
  800d86:	e8 b8 ff ff ff       	call   800d43 <strcpy>
	return dst;
}
  800d8b:	89 d8                	mov    %ebx,%eax
  800d8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d90:	c9                   	leave  
  800d91:	c3                   	ret    

00800d92 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d92:	f3 0f 1e fb          	endbr32 
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
  800d9b:	8b 75 08             	mov    0x8(%ebp),%esi
  800d9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da1:	89 f3                	mov    %esi,%ebx
  800da3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800da6:	89 f0                	mov    %esi,%eax
  800da8:	39 d8                	cmp    %ebx,%eax
  800daa:	74 11                	je     800dbd <strncpy+0x2b>
		*dst++ = *src;
  800dac:	83 c0 01             	add    $0x1,%eax
  800daf:	0f b6 0a             	movzbl (%edx),%ecx
  800db2:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800db5:	80 f9 01             	cmp    $0x1,%cl
  800db8:	83 da ff             	sbb    $0xffffffff,%edx
  800dbb:	eb eb                	jmp    800da8 <strncpy+0x16>
	}
	return ret;
}
  800dbd:	89 f0                	mov    %esi,%eax
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dc3:	f3 0f 1e fb          	endbr32 
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	56                   	push   %esi
  800dcb:	53                   	push   %ebx
  800dcc:	8b 75 08             	mov    0x8(%ebp),%esi
  800dcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd2:	8b 55 10             	mov    0x10(%ebp),%edx
  800dd5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800dd7:	85 d2                	test   %edx,%edx
  800dd9:	74 21                	je     800dfc <strlcpy+0x39>
  800ddb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ddf:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800de1:	39 c2                	cmp    %eax,%edx
  800de3:	74 14                	je     800df9 <strlcpy+0x36>
  800de5:	0f b6 19             	movzbl (%ecx),%ebx
  800de8:	84 db                	test   %bl,%bl
  800dea:	74 0b                	je     800df7 <strlcpy+0x34>
			*dst++ = *src++;
  800dec:	83 c1 01             	add    $0x1,%ecx
  800def:	83 c2 01             	add    $0x1,%edx
  800df2:	88 5a ff             	mov    %bl,-0x1(%edx)
  800df5:	eb ea                	jmp    800de1 <strlcpy+0x1e>
  800df7:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800df9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800dfc:	29 f0                	sub    %esi,%eax
}
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e02:	f3 0f 1e fb          	endbr32 
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e0f:	0f b6 01             	movzbl (%ecx),%eax
  800e12:	84 c0                	test   %al,%al
  800e14:	74 0c                	je     800e22 <strcmp+0x20>
  800e16:	3a 02                	cmp    (%edx),%al
  800e18:	75 08                	jne    800e22 <strcmp+0x20>
		p++, q++;
  800e1a:	83 c1 01             	add    $0x1,%ecx
  800e1d:	83 c2 01             	add    $0x1,%edx
  800e20:	eb ed                	jmp    800e0f <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e22:	0f b6 c0             	movzbl %al,%eax
  800e25:	0f b6 12             	movzbl (%edx),%edx
  800e28:	29 d0                	sub    %edx,%eax
}
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e2c:	f3 0f 1e fb          	endbr32 
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	53                   	push   %ebx
  800e34:	8b 45 08             	mov    0x8(%ebp),%eax
  800e37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e3a:	89 c3                	mov    %eax,%ebx
  800e3c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e3f:	eb 06                	jmp    800e47 <strncmp+0x1b>
		n--, p++, q++;
  800e41:	83 c0 01             	add    $0x1,%eax
  800e44:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800e47:	39 d8                	cmp    %ebx,%eax
  800e49:	74 16                	je     800e61 <strncmp+0x35>
  800e4b:	0f b6 08             	movzbl (%eax),%ecx
  800e4e:	84 c9                	test   %cl,%cl
  800e50:	74 04                	je     800e56 <strncmp+0x2a>
  800e52:	3a 0a                	cmp    (%edx),%cl
  800e54:	74 eb                	je     800e41 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e56:	0f b6 00             	movzbl (%eax),%eax
  800e59:	0f b6 12             	movzbl (%edx),%edx
  800e5c:	29 d0                	sub    %edx,%eax
}
  800e5e:	5b                   	pop    %ebx
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    
		return 0;
  800e61:	b8 00 00 00 00       	mov    $0x0,%eax
  800e66:	eb f6                	jmp    800e5e <strncmp+0x32>

00800e68 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e68:	f3 0f 1e fb          	endbr32 
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e72:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e76:	0f b6 10             	movzbl (%eax),%edx
  800e79:	84 d2                	test   %dl,%dl
  800e7b:	74 09                	je     800e86 <strchr+0x1e>
		if (*s == c)
  800e7d:	38 ca                	cmp    %cl,%dl
  800e7f:	74 0a                	je     800e8b <strchr+0x23>
	for (; *s; s++)
  800e81:	83 c0 01             	add    $0x1,%eax
  800e84:	eb f0                	jmp    800e76 <strchr+0xe>
			return (char *) s;
	return 0;
  800e86:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e8d:	f3 0f 1e fb          	endbr32 
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	8b 45 08             	mov    0x8(%ebp),%eax
  800e97:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e9b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e9e:	38 ca                	cmp    %cl,%dl
  800ea0:	74 09                	je     800eab <strfind+0x1e>
  800ea2:	84 d2                	test   %dl,%dl
  800ea4:	74 05                	je     800eab <strfind+0x1e>
	for (; *s; s++)
  800ea6:	83 c0 01             	add    $0x1,%eax
  800ea9:	eb f0                	jmp    800e9b <strfind+0xe>
			break;
	return (char *) s;
}
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ead:	f3 0f 1e fb          	endbr32 
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	57                   	push   %edi
  800eb5:	56                   	push   %esi
  800eb6:	53                   	push   %ebx
  800eb7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800eba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ebd:	85 c9                	test   %ecx,%ecx
  800ebf:	74 31                	je     800ef2 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ec1:	89 f8                	mov    %edi,%eax
  800ec3:	09 c8                	or     %ecx,%eax
  800ec5:	a8 03                	test   $0x3,%al
  800ec7:	75 23                	jne    800eec <memset+0x3f>
		c &= 0xFF;
  800ec9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ecd:	89 d3                	mov    %edx,%ebx
  800ecf:	c1 e3 08             	shl    $0x8,%ebx
  800ed2:	89 d0                	mov    %edx,%eax
  800ed4:	c1 e0 18             	shl    $0x18,%eax
  800ed7:	89 d6                	mov    %edx,%esi
  800ed9:	c1 e6 10             	shl    $0x10,%esi
  800edc:	09 f0                	or     %esi,%eax
  800ede:	09 c2                	or     %eax,%edx
  800ee0:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ee2:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ee5:	89 d0                	mov    %edx,%eax
  800ee7:	fc                   	cld    
  800ee8:	f3 ab                	rep stos %eax,%es:(%edi)
  800eea:	eb 06                	jmp    800ef2 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800eec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eef:	fc                   	cld    
  800ef0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ef2:	89 f8                	mov    %edi,%eax
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    

00800ef9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ef9:	f3 0f 1e fb          	endbr32 
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	57                   	push   %edi
  800f01:	56                   	push   %esi
  800f02:	8b 45 08             	mov    0x8(%ebp),%eax
  800f05:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f08:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f0b:	39 c6                	cmp    %eax,%esi
  800f0d:	73 32                	jae    800f41 <memmove+0x48>
  800f0f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f12:	39 c2                	cmp    %eax,%edx
  800f14:	76 2b                	jbe    800f41 <memmove+0x48>
		s += n;
		d += n;
  800f16:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f19:	89 fe                	mov    %edi,%esi
  800f1b:	09 ce                	or     %ecx,%esi
  800f1d:	09 d6                	or     %edx,%esi
  800f1f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f25:	75 0e                	jne    800f35 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f27:	83 ef 04             	sub    $0x4,%edi
  800f2a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f2d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800f30:	fd                   	std    
  800f31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f33:	eb 09                	jmp    800f3e <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f35:	83 ef 01             	sub    $0x1,%edi
  800f38:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800f3b:	fd                   	std    
  800f3c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f3e:	fc                   	cld    
  800f3f:	eb 1a                	jmp    800f5b <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f41:	89 c2                	mov    %eax,%edx
  800f43:	09 ca                	or     %ecx,%edx
  800f45:	09 f2                	or     %esi,%edx
  800f47:	f6 c2 03             	test   $0x3,%dl
  800f4a:	75 0a                	jne    800f56 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f4c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800f4f:	89 c7                	mov    %eax,%edi
  800f51:	fc                   	cld    
  800f52:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f54:	eb 05                	jmp    800f5b <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800f56:	89 c7                	mov    %eax,%edi
  800f58:	fc                   	cld    
  800f59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f5b:	5e                   	pop    %esi
  800f5c:	5f                   	pop    %edi
  800f5d:	5d                   	pop    %ebp
  800f5e:	c3                   	ret    

00800f5f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f5f:	f3 0f 1e fb          	endbr32 
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f69:	ff 75 10             	pushl  0x10(%ebp)
  800f6c:	ff 75 0c             	pushl  0xc(%ebp)
  800f6f:	ff 75 08             	pushl  0x8(%ebp)
  800f72:	e8 82 ff ff ff       	call   800ef9 <memmove>
}
  800f77:	c9                   	leave  
  800f78:	c3                   	ret    

00800f79 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f79:	f3 0f 1e fb          	endbr32 
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	56                   	push   %esi
  800f81:	53                   	push   %ebx
  800f82:	8b 45 08             	mov    0x8(%ebp),%eax
  800f85:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f88:	89 c6                	mov    %eax,%esi
  800f8a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f8d:	39 f0                	cmp    %esi,%eax
  800f8f:	74 1c                	je     800fad <memcmp+0x34>
		if (*s1 != *s2)
  800f91:	0f b6 08             	movzbl (%eax),%ecx
  800f94:	0f b6 1a             	movzbl (%edx),%ebx
  800f97:	38 d9                	cmp    %bl,%cl
  800f99:	75 08                	jne    800fa3 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800f9b:	83 c0 01             	add    $0x1,%eax
  800f9e:	83 c2 01             	add    $0x1,%edx
  800fa1:	eb ea                	jmp    800f8d <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800fa3:	0f b6 c1             	movzbl %cl,%eax
  800fa6:	0f b6 db             	movzbl %bl,%ebx
  800fa9:	29 d8                	sub    %ebx,%eax
  800fab:	eb 05                	jmp    800fb2 <memcmp+0x39>
	}

	return 0;
  800fad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fb2:	5b                   	pop    %ebx
  800fb3:	5e                   	pop    %esi
  800fb4:	5d                   	pop    %ebp
  800fb5:	c3                   	ret    

00800fb6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fb6:	f3 0f 1e fb          	endbr32 
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800fc3:	89 c2                	mov    %eax,%edx
  800fc5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800fc8:	39 d0                	cmp    %edx,%eax
  800fca:	73 09                	jae    800fd5 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fcc:	38 08                	cmp    %cl,(%eax)
  800fce:	74 05                	je     800fd5 <memfind+0x1f>
	for (; s < ends; s++)
  800fd0:	83 c0 01             	add    $0x1,%eax
  800fd3:	eb f3                	jmp    800fc8 <memfind+0x12>
			break;
	return (void *) s;
}
  800fd5:	5d                   	pop    %ebp
  800fd6:	c3                   	ret    

00800fd7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fd7:	f3 0f 1e fb          	endbr32 
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	57                   	push   %edi
  800fdf:	56                   	push   %esi
  800fe0:	53                   	push   %ebx
  800fe1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fe7:	eb 03                	jmp    800fec <strtol+0x15>
		s++;
  800fe9:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800fec:	0f b6 01             	movzbl (%ecx),%eax
  800fef:	3c 20                	cmp    $0x20,%al
  800ff1:	74 f6                	je     800fe9 <strtol+0x12>
  800ff3:	3c 09                	cmp    $0x9,%al
  800ff5:	74 f2                	je     800fe9 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ff7:	3c 2b                	cmp    $0x2b,%al
  800ff9:	74 2a                	je     801025 <strtol+0x4e>
	int neg = 0;
  800ffb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801000:	3c 2d                	cmp    $0x2d,%al
  801002:	74 2b                	je     80102f <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801004:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80100a:	75 0f                	jne    80101b <strtol+0x44>
  80100c:	80 39 30             	cmpb   $0x30,(%ecx)
  80100f:	74 28                	je     801039 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801011:	85 db                	test   %ebx,%ebx
  801013:	b8 0a 00 00 00       	mov    $0xa,%eax
  801018:	0f 44 d8             	cmove  %eax,%ebx
  80101b:	b8 00 00 00 00       	mov    $0x0,%eax
  801020:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801023:	eb 46                	jmp    80106b <strtol+0x94>
		s++;
  801025:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801028:	bf 00 00 00 00       	mov    $0x0,%edi
  80102d:	eb d5                	jmp    801004 <strtol+0x2d>
		s++, neg = 1;
  80102f:	83 c1 01             	add    $0x1,%ecx
  801032:	bf 01 00 00 00       	mov    $0x1,%edi
  801037:	eb cb                	jmp    801004 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801039:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80103d:	74 0e                	je     80104d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80103f:	85 db                	test   %ebx,%ebx
  801041:	75 d8                	jne    80101b <strtol+0x44>
		s++, base = 8;
  801043:	83 c1 01             	add    $0x1,%ecx
  801046:	bb 08 00 00 00       	mov    $0x8,%ebx
  80104b:	eb ce                	jmp    80101b <strtol+0x44>
		s += 2, base = 16;
  80104d:	83 c1 02             	add    $0x2,%ecx
  801050:	bb 10 00 00 00       	mov    $0x10,%ebx
  801055:	eb c4                	jmp    80101b <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801057:	0f be d2             	movsbl %dl,%edx
  80105a:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80105d:	3b 55 10             	cmp    0x10(%ebp),%edx
  801060:	7d 3a                	jge    80109c <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801062:	83 c1 01             	add    $0x1,%ecx
  801065:	0f af 45 10          	imul   0x10(%ebp),%eax
  801069:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  80106b:	0f b6 11             	movzbl (%ecx),%edx
  80106e:	8d 72 d0             	lea    -0x30(%edx),%esi
  801071:	89 f3                	mov    %esi,%ebx
  801073:	80 fb 09             	cmp    $0x9,%bl
  801076:	76 df                	jbe    801057 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801078:	8d 72 9f             	lea    -0x61(%edx),%esi
  80107b:	89 f3                	mov    %esi,%ebx
  80107d:	80 fb 19             	cmp    $0x19,%bl
  801080:	77 08                	ja     80108a <strtol+0xb3>
			dig = *s - 'a' + 10;
  801082:	0f be d2             	movsbl %dl,%edx
  801085:	83 ea 57             	sub    $0x57,%edx
  801088:	eb d3                	jmp    80105d <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  80108a:	8d 72 bf             	lea    -0x41(%edx),%esi
  80108d:	89 f3                	mov    %esi,%ebx
  80108f:	80 fb 19             	cmp    $0x19,%bl
  801092:	77 08                	ja     80109c <strtol+0xc5>
			dig = *s - 'A' + 10;
  801094:	0f be d2             	movsbl %dl,%edx
  801097:	83 ea 37             	sub    $0x37,%edx
  80109a:	eb c1                	jmp    80105d <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  80109c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010a0:	74 05                	je     8010a7 <strtol+0xd0>
		*endptr = (char *) s;
  8010a2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010a5:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8010a7:	89 c2                	mov    %eax,%edx
  8010a9:	f7 da                	neg    %edx
  8010ab:	85 ff                	test   %edi,%edi
  8010ad:	0f 45 c2             	cmovne %edx,%eax
}
  8010b0:	5b                   	pop    %ebx
  8010b1:	5e                   	pop    %esi
  8010b2:	5f                   	pop    %edi
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    

008010b5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010b5:	f3 0f 1e fb          	endbr32 
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	57                   	push   %edi
  8010bd:	56                   	push   %esi
  8010be:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ca:	89 c3                	mov    %eax,%ebx
  8010cc:	89 c7                	mov    %eax,%edi
  8010ce:	89 c6                	mov    %eax,%esi
  8010d0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8010d2:	5b                   	pop    %ebx
  8010d3:	5e                   	pop    %esi
  8010d4:	5f                   	pop    %edi
  8010d5:	5d                   	pop    %ebp
  8010d6:	c3                   	ret    

008010d7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8010d7:	f3 0f 1e fb          	endbr32 
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	57                   	push   %edi
  8010df:	56                   	push   %esi
  8010e0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8010e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010eb:	89 d1                	mov    %edx,%ecx
  8010ed:	89 d3                	mov    %edx,%ebx
  8010ef:	89 d7                	mov    %edx,%edi
  8010f1:	89 d6                	mov    %edx,%esi
  8010f3:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010f5:	5b                   	pop    %ebx
  8010f6:	5e                   	pop    %esi
  8010f7:	5f                   	pop    %edi
  8010f8:	5d                   	pop    %ebp
  8010f9:	c3                   	ret    

008010fa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010fa:	f3 0f 1e fb          	endbr32 
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
  801101:	57                   	push   %edi
  801102:	56                   	push   %esi
  801103:	53                   	push   %ebx
  801104:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801107:	b9 00 00 00 00       	mov    $0x0,%ecx
  80110c:	8b 55 08             	mov    0x8(%ebp),%edx
  80110f:	b8 03 00 00 00       	mov    $0x3,%eax
  801114:	89 cb                	mov    %ecx,%ebx
  801116:	89 cf                	mov    %ecx,%edi
  801118:	89 ce                	mov    %ecx,%esi
  80111a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80111c:	85 c0                	test   %eax,%eax
  80111e:	7f 08                	jg     801128 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801123:	5b                   	pop    %ebx
  801124:	5e                   	pop    %esi
  801125:	5f                   	pop    %edi
  801126:	5d                   	pop    %ebp
  801127:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801128:	83 ec 0c             	sub    $0xc,%esp
  80112b:	50                   	push   %eax
  80112c:	6a 03                	push   $0x3
  80112e:	68 bf 1a 80 00       	push   $0x801abf
  801133:	6a 23                	push   $0x23
  801135:	68 dc 1a 80 00       	push   $0x801adc
  80113a:	e8 14 f5 ff ff       	call   800653 <_panic>

0080113f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80113f:	f3 0f 1e fb          	endbr32 
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	57                   	push   %edi
  801147:	56                   	push   %esi
  801148:	53                   	push   %ebx
	asm volatile("int %1\n"
  801149:	ba 00 00 00 00       	mov    $0x0,%edx
  80114e:	b8 02 00 00 00       	mov    $0x2,%eax
  801153:	89 d1                	mov    %edx,%ecx
  801155:	89 d3                	mov    %edx,%ebx
  801157:	89 d7                	mov    %edx,%edi
  801159:	89 d6                	mov    %edx,%esi
  80115b:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80115d:	5b                   	pop    %ebx
  80115e:	5e                   	pop    %esi
  80115f:	5f                   	pop    %edi
  801160:	5d                   	pop    %ebp
  801161:	c3                   	ret    

00801162 <sys_yield>:

void
sys_yield(void)
{
  801162:	f3 0f 1e fb          	endbr32 
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	57                   	push   %edi
  80116a:	56                   	push   %esi
  80116b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80116c:	ba 00 00 00 00       	mov    $0x0,%edx
  801171:	b8 0b 00 00 00       	mov    $0xb,%eax
  801176:	89 d1                	mov    %edx,%ecx
  801178:	89 d3                	mov    %edx,%ebx
  80117a:	89 d7                	mov    %edx,%edi
  80117c:	89 d6                	mov    %edx,%esi
  80117e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801180:	5b                   	pop    %ebx
  801181:	5e                   	pop    %esi
  801182:	5f                   	pop    %edi
  801183:	5d                   	pop    %ebp
  801184:	c3                   	ret    

00801185 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801185:	f3 0f 1e fb          	endbr32 
  801189:	55                   	push   %ebp
  80118a:	89 e5                	mov    %esp,%ebp
  80118c:	57                   	push   %edi
  80118d:	56                   	push   %esi
  80118e:	53                   	push   %ebx
  80118f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801192:	be 00 00 00 00       	mov    $0x0,%esi
  801197:	8b 55 08             	mov    0x8(%ebp),%edx
  80119a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119d:	b8 04 00 00 00       	mov    $0x4,%eax
  8011a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011a5:	89 f7                	mov    %esi,%edi
  8011a7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	7f 08                	jg     8011b5 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b0:	5b                   	pop    %ebx
  8011b1:	5e                   	pop    %esi
  8011b2:	5f                   	pop    %edi
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011b5:	83 ec 0c             	sub    $0xc,%esp
  8011b8:	50                   	push   %eax
  8011b9:	6a 04                	push   $0x4
  8011bb:	68 bf 1a 80 00       	push   $0x801abf
  8011c0:	6a 23                	push   $0x23
  8011c2:	68 dc 1a 80 00       	push   $0x801adc
  8011c7:	e8 87 f4 ff ff       	call   800653 <_panic>

008011cc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011cc:	f3 0f 1e fb          	endbr32 
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	57                   	push   %edi
  8011d4:	56                   	push   %esi
  8011d5:	53                   	push   %ebx
  8011d6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8011d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011df:	b8 05 00 00 00       	mov    $0x5,%eax
  8011e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011e7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011ea:	8b 75 18             	mov    0x18(%ebp),%esi
  8011ed:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	7f 08                	jg     8011fb <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8011f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f6:	5b                   	pop    %ebx
  8011f7:	5e                   	pop    %esi
  8011f8:	5f                   	pop    %edi
  8011f9:	5d                   	pop    %ebp
  8011fa:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011fb:	83 ec 0c             	sub    $0xc,%esp
  8011fe:	50                   	push   %eax
  8011ff:	6a 05                	push   $0x5
  801201:	68 bf 1a 80 00       	push   $0x801abf
  801206:	6a 23                	push   $0x23
  801208:	68 dc 1a 80 00       	push   $0x801adc
  80120d:	e8 41 f4 ff ff       	call   800653 <_panic>

00801212 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801212:	f3 0f 1e fb          	endbr32 
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	57                   	push   %edi
  80121a:	56                   	push   %esi
  80121b:	53                   	push   %ebx
  80121c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80121f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801224:	8b 55 08             	mov    0x8(%ebp),%edx
  801227:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80122a:	b8 06 00 00 00       	mov    $0x6,%eax
  80122f:	89 df                	mov    %ebx,%edi
  801231:	89 de                	mov    %ebx,%esi
  801233:	cd 30                	int    $0x30
	if(check && ret > 0)
  801235:	85 c0                	test   %eax,%eax
  801237:	7f 08                	jg     801241 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801239:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123c:	5b                   	pop    %ebx
  80123d:	5e                   	pop    %esi
  80123e:	5f                   	pop    %edi
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801241:	83 ec 0c             	sub    $0xc,%esp
  801244:	50                   	push   %eax
  801245:	6a 06                	push   $0x6
  801247:	68 bf 1a 80 00       	push   $0x801abf
  80124c:	6a 23                	push   $0x23
  80124e:	68 dc 1a 80 00       	push   $0x801adc
  801253:	e8 fb f3 ff ff       	call   800653 <_panic>

00801258 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801258:	f3 0f 1e fb          	endbr32 
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	57                   	push   %edi
  801260:	56                   	push   %esi
  801261:	53                   	push   %ebx
  801262:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801265:	bb 00 00 00 00       	mov    $0x0,%ebx
  80126a:	8b 55 08             	mov    0x8(%ebp),%edx
  80126d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801270:	b8 08 00 00 00       	mov    $0x8,%eax
  801275:	89 df                	mov    %ebx,%edi
  801277:	89 de                	mov    %ebx,%esi
  801279:	cd 30                	int    $0x30
	if(check && ret > 0)
  80127b:	85 c0                	test   %eax,%eax
  80127d:	7f 08                	jg     801287 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80127f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801282:	5b                   	pop    %ebx
  801283:	5e                   	pop    %esi
  801284:	5f                   	pop    %edi
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801287:	83 ec 0c             	sub    $0xc,%esp
  80128a:	50                   	push   %eax
  80128b:	6a 08                	push   $0x8
  80128d:	68 bf 1a 80 00       	push   $0x801abf
  801292:	6a 23                	push   $0x23
  801294:	68 dc 1a 80 00       	push   $0x801adc
  801299:	e8 b5 f3 ff ff       	call   800653 <_panic>

0080129e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80129e:	f3 0f 1e fb          	endbr32 
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	57                   	push   %edi
  8012a6:	56                   	push   %esi
  8012a7:	53                   	push   %ebx
  8012a8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b6:	b8 09 00 00 00       	mov    $0x9,%eax
  8012bb:	89 df                	mov    %ebx,%edi
  8012bd:	89 de                	mov    %ebx,%esi
  8012bf:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012c1:	85 c0                	test   %eax,%eax
  8012c3:	7f 08                	jg     8012cd <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8012c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c8:	5b                   	pop    %ebx
  8012c9:	5e                   	pop    %esi
  8012ca:	5f                   	pop    %edi
  8012cb:	5d                   	pop    %ebp
  8012cc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8012cd:	83 ec 0c             	sub    $0xc,%esp
  8012d0:	50                   	push   %eax
  8012d1:	6a 09                	push   $0x9
  8012d3:	68 bf 1a 80 00       	push   $0x801abf
  8012d8:	6a 23                	push   $0x23
  8012da:	68 dc 1a 80 00       	push   $0x801adc
  8012df:	e8 6f f3 ff ff       	call   800653 <_panic>

008012e4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012e4:	f3 0f 1e fb          	endbr32 
  8012e8:	55                   	push   %ebp
  8012e9:	89 e5                	mov    %esp,%ebp
  8012eb:	57                   	push   %edi
  8012ec:	56                   	push   %esi
  8012ed:	53                   	push   %ebx
  8012ee:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012fc:	b8 0a 00 00 00       	mov    $0xa,%eax
  801301:	89 df                	mov    %ebx,%edi
  801303:	89 de                	mov    %ebx,%esi
  801305:	cd 30                	int    $0x30
	if(check && ret > 0)
  801307:	85 c0                	test   %eax,%eax
  801309:	7f 08                	jg     801313 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80130b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80130e:	5b                   	pop    %ebx
  80130f:	5e                   	pop    %esi
  801310:	5f                   	pop    %edi
  801311:	5d                   	pop    %ebp
  801312:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801313:	83 ec 0c             	sub    $0xc,%esp
  801316:	50                   	push   %eax
  801317:	6a 0a                	push   $0xa
  801319:	68 bf 1a 80 00       	push   $0x801abf
  80131e:	6a 23                	push   $0x23
  801320:	68 dc 1a 80 00       	push   $0x801adc
  801325:	e8 29 f3 ff ff       	call   800653 <_panic>

0080132a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80132a:	f3 0f 1e fb          	endbr32 
  80132e:	55                   	push   %ebp
  80132f:	89 e5                	mov    %esp,%ebp
  801331:	57                   	push   %edi
  801332:	56                   	push   %esi
  801333:	53                   	push   %ebx
	asm volatile("int %1\n"
  801334:	8b 55 08             	mov    0x8(%ebp),%edx
  801337:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80133a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80133f:	be 00 00 00 00       	mov    $0x0,%esi
  801344:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801347:	8b 7d 14             	mov    0x14(%ebp),%edi
  80134a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80134c:	5b                   	pop    %ebx
  80134d:	5e                   	pop    %esi
  80134e:	5f                   	pop    %edi
  80134f:	5d                   	pop    %ebp
  801350:	c3                   	ret    

00801351 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801351:	f3 0f 1e fb          	endbr32 
  801355:	55                   	push   %ebp
  801356:	89 e5                	mov    %esp,%ebp
  801358:	57                   	push   %edi
  801359:	56                   	push   %esi
  80135a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80135b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801360:	8b 55 08             	mov    0x8(%ebp),%edx
  801363:	b8 0d 00 00 00       	mov    $0xd,%eax
  801368:	89 cb                	mov    %ecx,%ebx
  80136a:	89 cf                	mov    %ecx,%edi
  80136c:	89 ce                	mov    %ecx,%esi
  80136e:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 0, (uint32_t)dstva, 0, 0, 0, 0);
}
  801370:	5b                   	pop    %ebx
  801371:	5e                   	pop    %esi
  801372:	5f                   	pop    %edi
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    

00801375 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801375:	f3 0f 1e fb          	endbr32 
  801379:	55                   	push   %ebp
  80137a:	89 e5                	mov    %esp,%ebp
  80137c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80137f:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  801386:	74 0a                	je     801392 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801388:	8b 45 08             	mov    0x8(%ebp),%eax
  80138b:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  801390:	c9                   	leave  
  801391:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801392:	83 ec 0c             	sub    $0xc,%esp
  801395:	68 ea 1a 80 00       	push   $0x801aea
  80139a:	e8 9b f3 ff ff       	call   80073a <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  80139f:	83 c4 0c             	add    $0xc,%esp
  8013a2:	6a 07                	push   $0x7
  8013a4:	68 00 f0 bf ee       	push   $0xeebff000
  8013a9:	6a 00                	push   $0x0
  8013ab:	e8 d5 fd ff ff       	call   801185 <sys_page_alloc>
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	78 2a                	js     8013e1 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  8013b7:	83 ec 08             	sub    $0x8,%esp
  8013ba:	68 f5 13 80 00       	push   $0x8013f5
  8013bf:	6a 00                	push   $0x0
  8013c1:	e8 1e ff ff ff       	call   8012e4 <sys_env_set_pgfault_upcall>
  8013c6:	83 c4 10             	add    $0x10,%esp
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	79 bb                	jns    801388 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  8013cd:	83 ec 04             	sub    $0x4,%esp
  8013d0:	68 28 1b 80 00       	push   $0x801b28
  8013d5:	6a 25                	push   $0x25
  8013d7:	68 17 1b 80 00       	push   $0x801b17
  8013dc:	e8 72 f2 ff ff       	call   800653 <_panic>
            panic("Allocation of UXSTACK failed!");
  8013e1:	83 ec 04             	sub    $0x4,%esp
  8013e4:	68 f9 1a 80 00       	push   $0x801af9
  8013e9:	6a 22                	push   $0x22
  8013eb:	68 17 1b 80 00       	push   $0x801b17
  8013f0:	e8 5e f2 ff ff       	call   800653 <_panic>

008013f5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8013f5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8013f6:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  8013fb:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8013fd:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  801400:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  801404:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  801408:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  80140b:	83 c4 08             	add    $0x8,%esp
    popa
  80140e:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  80140f:	83 c4 04             	add    $0x4,%esp
    popf
  801412:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  801413:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  801416:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  80141a:	c3                   	ret    
  80141b:	66 90                	xchg   %ax,%ax
  80141d:	66 90                	xchg   %ax,%ax
  80141f:	90                   	nop

00801420 <__udivdi3>:
  801420:	f3 0f 1e fb          	endbr32 
  801424:	55                   	push   %ebp
  801425:	57                   	push   %edi
  801426:	56                   	push   %esi
  801427:	53                   	push   %ebx
  801428:	83 ec 1c             	sub    $0x1c,%esp
  80142b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80142f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801433:	8b 74 24 34          	mov    0x34(%esp),%esi
  801437:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80143b:	85 d2                	test   %edx,%edx
  80143d:	75 19                	jne    801458 <__udivdi3+0x38>
  80143f:	39 f3                	cmp    %esi,%ebx
  801441:	76 4d                	jbe    801490 <__udivdi3+0x70>
  801443:	31 ff                	xor    %edi,%edi
  801445:	89 e8                	mov    %ebp,%eax
  801447:	89 f2                	mov    %esi,%edx
  801449:	f7 f3                	div    %ebx
  80144b:	89 fa                	mov    %edi,%edx
  80144d:	83 c4 1c             	add    $0x1c,%esp
  801450:	5b                   	pop    %ebx
  801451:	5e                   	pop    %esi
  801452:	5f                   	pop    %edi
  801453:	5d                   	pop    %ebp
  801454:	c3                   	ret    
  801455:	8d 76 00             	lea    0x0(%esi),%esi
  801458:	39 f2                	cmp    %esi,%edx
  80145a:	76 14                	jbe    801470 <__udivdi3+0x50>
  80145c:	31 ff                	xor    %edi,%edi
  80145e:	31 c0                	xor    %eax,%eax
  801460:	89 fa                	mov    %edi,%edx
  801462:	83 c4 1c             	add    $0x1c,%esp
  801465:	5b                   	pop    %ebx
  801466:	5e                   	pop    %esi
  801467:	5f                   	pop    %edi
  801468:	5d                   	pop    %ebp
  801469:	c3                   	ret    
  80146a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801470:	0f bd fa             	bsr    %edx,%edi
  801473:	83 f7 1f             	xor    $0x1f,%edi
  801476:	75 48                	jne    8014c0 <__udivdi3+0xa0>
  801478:	39 f2                	cmp    %esi,%edx
  80147a:	72 06                	jb     801482 <__udivdi3+0x62>
  80147c:	31 c0                	xor    %eax,%eax
  80147e:	39 eb                	cmp    %ebp,%ebx
  801480:	77 de                	ja     801460 <__udivdi3+0x40>
  801482:	b8 01 00 00 00       	mov    $0x1,%eax
  801487:	eb d7                	jmp    801460 <__udivdi3+0x40>
  801489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801490:	89 d9                	mov    %ebx,%ecx
  801492:	85 db                	test   %ebx,%ebx
  801494:	75 0b                	jne    8014a1 <__udivdi3+0x81>
  801496:	b8 01 00 00 00       	mov    $0x1,%eax
  80149b:	31 d2                	xor    %edx,%edx
  80149d:	f7 f3                	div    %ebx
  80149f:	89 c1                	mov    %eax,%ecx
  8014a1:	31 d2                	xor    %edx,%edx
  8014a3:	89 f0                	mov    %esi,%eax
  8014a5:	f7 f1                	div    %ecx
  8014a7:	89 c6                	mov    %eax,%esi
  8014a9:	89 e8                	mov    %ebp,%eax
  8014ab:	89 f7                	mov    %esi,%edi
  8014ad:	f7 f1                	div    %ecx
  8014af:	89 fa                	mov    %edi,%edx
  8014b1:	83 c4 1c             	add    $0x1c,%esp
  8014b4:	5b                   	pop    %ebx
  8014b5:	5e                   	pop    %esi
  8014b6:	5f                   	pop    %edi
  8014b7:	5d                   	pop    %ebp
  8014b8:	c3                   	ret    
  8014b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014c0:	89 f9                	mov    %edi,%ecx
  8014c2:	b8 20 00 00 00       	mov    $0x20,%eax
  8014c7:	29 f8                	sub    %edi,%eax
  8014c9:	d3 e2                	shl    %cl,%edx
  8014cb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8014cf:	89 c1                	mov    %eax,%ecx
  8014d1:	89 da                	mov    %ebx,%edx
  8014d3:	d3 ea                	shr    %cl,%edx
  8014d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8014d9:	09 d1                	or     %edx,%ecx
  8014db:	89 f2                	mov    %esi,%edx
  8014dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014e1:	89 f9                	mov    %edi,%ecx
  8014e3:	d3 e3                	shl    %cl,%ebx
  8014e5:	89 c1                	mov    %eax,%ecx
  8014e7:	d3 ea                	shr    %cl,%edx
  8014e9:	89 f9                	mov    %edi,%ecx
  8014eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8014ef:	89 eb                	mov    %ebp,%ebx
  8014f1:	d3 e6                	shl    %cl,%esi
  8014f3:	89 c1                	mov    %eax,%ecx
  8014f5:	d3 eb                	shr    %cl,%ebx
  8014f7:	09 de                	or     %ebx,%esi
  8014f9:	89 f0                	mov    %esi,%eax
  8014fb:	f7 74 24 08          	divl   0x8(%esp)
  8014ff:	89 d6                	mov    %edx,%esi
  801501:	89 c3                	mov    %eax,%ebx
  801503:	f7 64 24 0c          	mull   0xc(%esp)
  801507:	39 d6                	cmp    %edx,%esi
  801509:	72 15                	jb     801520 <__udivdi3+0x100>
  80150b:	89 f9                	mov    %edi,%ecx
  80150d:	d3 e5                	shl    %cl,%ebp
  80150f:	39 c5                	cmp    %eax,%ebp
  801511:	73 04                	jae    801517 <__udivdi3+0xf7>
  801513:	39 d6                	cmp    %edx,%esi
  801515:	74 09                	je     801520 <__udivdi3+0x100>
  801517:	89 d8                	mov    %ebx,%eax
  801519:	31 ff                	xor    %edi,%edi
  80151b:	e9 40 ff ff ff       	jmp    801460 <__udivdi3+0x40>
  801520:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801523:	31 ff                	xor    %edi,%edi
  801525:	e9 36 ff ff ff       	jmp    801460 <__udivdi3+0x40>
  80152a:	66 90                	xchg   %ax,%ax
  80152c:	66 90                	xchg   %ax,%ax
  80152e:	66 90                	xchg   %ax,%ax

00801530 <__umoddi3>:
  801530:	f3 0f 1e fb          	endbr32 
  801534:	55                   	push   %ebp
  801535:	57                   	push   %edi
  801536:	56                   	push   %esi
  801537:	53                   	push   %ebx
  801538:	83 ec 1c             	sub    $0x1c,%esp
  80153b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80153f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801543:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801547:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80154b:	85 c0                	test   %eax,%eax
  80154d:	75 19                	jne    801568 <__umoddi3+0x38>
  80154f:	39 df                	cmp    %ebx,%edi
  801551:	76 5d                	jbe    8015b0 <__umoddi3+0x80>
  801553:	89 f0                	mov    %esi,%eax
  801555:	89 da                	mov    %ebx,%edx
  801557:	f7 f7                	div    %edi
  801559:	89 d0                	mov    %edx,%eax
  80155b:	31 d2                	xor    %edx,%edx
  80155d:	83 c4 1c             	add    $0x1c,%esp
  801560:	5b                   	pop    %ebx
  801561:	5e                   	pop    %esi
  801562:	5f                   	pop    %edi
  801563:	5d                   	pop    %ebp
  801564:	c3                   	ret    
  801565:	8d 76 00             	lea    0x0(%esi),%esi
  801568:	89 f2                	mov    %esi,%edx
  80156a:	39 d8                	cmp    %ebx,%eax
  80156c:	76 12                	jbe    801580 <__umoddi3+0x50>
  80156e:	89 f0                	mov    %esi,%eax
  801570:	89 da                	mov    %ebx,%edx
  801572:	83 c4 1c             	add    $0x1c,%esp
  801575:	5b                   	pop    %ebx
  801576:	5e                   	pop    %esi
  801577:	5f                   	pop    %edi
  801578:	5d                   	pop    %ebp
  801579:	c3                   	ret    
  80157a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801580:	0f bd e8             	bsr    %eax,%ebp
  801583:	83 f5 1f             	xor    $0x1f,%ebp
  801586:	75 50                	jne    8015d8 <__umoddi3+0xa8>
  801588:	39 d8                	cmp    %ebx,%eax
  80158a:	0f 82 e0 00 00 00    	jb     801670 <__umoddi3+0x140>
  801590:	89 d9                	mov    %ebx,%ecx
  801592:	39 f7                	cmp    %esi,%edi
  801594:	0f 86 d6 00 00 00    	jbe    801670 <__umoddi3+0x140>
  80159a:	89 d0                	mov    %edx,%eax
  80159c:	89 ca                	mov    %ecx,%edx
  80159e:	83 c4 1c             	add    $0x1c,%esp
  8015a1:	5b                   	pop    %ebx
  8015a2:	5e                   	pop    %esi
  8015a3:	5f                   	pop    %edi
  8015a4:	5d                   	pop    %ebp
  8015a5:	c3                   	ret    
  8015a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8015ad:	8d 76 00             	lea    0x0(%esi),%esi
  8015b0:	89 fd                	mov    %edi,%ebp
  8015b2:	85 ff                	test   %edi,%edi
  8015b4:	75 0b                	jne    8015c1 <__umoddi3+0x91>
  8015b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8015bb:	31 d2                	xor    %edx,%edx
  8015bd:	f7 f7                	div    %edi
  8015bf:	89 c5                	mov    %eax,%ebp
  8015c1:	89 d8                	mov    %ebx,%eax
  8015c3:	31 d2                	xor    %edx,%edx
  8015c5:	f7 f5                	div    %ebp
  8015c7:	89 f0                	mov    %esi,%eax
  8015c9:	f7 f5                	div    %ebp
  8015cb:	89 d0                	mov    %edx,%eax
  8015cd:	31 d2                	xor    %edx,%edx
  8015cf:	eb 8c                	jmp    80155d <__umoddi3+0x2d>
  8015d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8015d8:	89 e9                	mov    %ebp,%ecx
  8015da:	ba 20 00 00 00       	mov    $0x20,%edx
  8015df:	29 ea                	sub    %ebp,%edx
  8015e1:	d3 e0                	shl    %cl,%eax
  8015e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015e7:	89 d1                	mov    %edx,%ecx
  8015e9:	89 f8                	mov    %edi,%eax
  8015eb:	d3 e8                	shr    %cl,%eax
  8015ed:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8015f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015f5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8015f9:	09 c1                	or     %eax,%ecx
  8015fb:	89 d8                	mov    %ebx,%eax
  8015fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801601:	89 e9                	mov    %ebp,%ecx
  801603:	d3 e7                	shl    %cl,%edi
  801605:	89 d1                	mov    %edx,%ecx
  801607:	d3 e8                	shr    %cl,%eax
  801609:	89 e9                	mov    %ebp,%ecx
  80160b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80160f:	d3 e3                	shl    %cl,%ebx
  801611:	89 c7                	mov    %eax,%edi
  801613:	89 d1                	mov    %edx,%ecx
  801615:	89 f0                	mov    %esi,%eax
  801617:	d3 e8                	shr    %cl,%eax
  801619:	89 e9                	mov    %ebp,%ecx
  80161b:	89 fa                	mov    %edi,%edx
  80161d:	d3 e6                	shl    %cl,%esi
  80161f:	09 d8                	or     %ebx,%eax
  801621:	f7 74 24 08          	divl   0x8(%esp)
  801625:	89 d1                	mov    %edx,%ecx
  801627:	89 f3                	mov    %esi,%ebx
  801629:	f7 64 24 0c          	mull   0xc(%esp)
  80162d:	89 c6                	mov    %eax,%esi
  80162f:	89 d7                	mov    %edx,%edi
  801631:	39 d1                	cmp    %edx,%ecx
  801633:	72 06                	jb     80163b <__umoddi3+0x10b>
  801635:	75 10                	jne    801647 <__umoddi3+0x117>
  801637:	39 c3                	cmp    %eax,%ebx
  801639:	73 0c                	jae    801647 <__umoddi3+0x117>
  80163b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80163f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801643:	89 d7                	mov    %edx,%edi
  801645:	89 c6                	mov    %eax,%esi
  801647:	89 ca                	mov    %ecx,%edx
  801649:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80164e:	29 f3                	sub    %esi,%ebx
  801650:	19 fa                	sbb    %edi,%edx
  801652:	89 d0                	mov    %edx,%eax
  801654:	d3 e0                	shl    %cl,%eax
  801656:	89 e9                	mov    %ebp,%ecx
  801658:	d3 eb                	shr    %cl,%ebx
  80165a:	d3 ea                	shr    %cl,%edx
  80165c:	09 d8                	or     %ebx,%eax
  80165e:	83 c4 1c             	add    $0x1c,%esp
  801661:	5b                   	pop    %ebx
  801662:	5e                   	pop    %esi
  801663:	5f                   	pop    %edi
  801664:	5d                   	pop    %ebp
  801665:	c3                   	ret    
  801666:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80166d:	8d 76 00             	lea    0x0(%esi),%esi
  801670:	29 fe                	sub    %edi,%esi
  801672:	19 c3                	sbb    %eax,%ebx
  801674:	89 f2                	mov    %esi,%edx
  801676:	89 d9                	mov    %ebx,%ecx
  801678:	e9 1d ff ff ff       	jmp    80159a <__umoddi3+0x6a>
