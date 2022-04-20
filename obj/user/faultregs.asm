
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
  800044:	68 91 16 80 00       	push   $0x801691
  800049:	68 60 16 80 00       	push   $0x801660
  80004e:	e8 dd 06 00 00       	call   800730 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 70 16 80 00       	push   $0x801670
  80005c:	68 74 16 80 00       	push   $0x801674
  800061:	e8 ca 06 00 00       	call   800730 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	0f 84 2e 02 00 00    	je     8002a1 <check_regs+0x26e>
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	68 88 16 80 00       	push   $0x801688
  80007b:	e8 b0 06 00 00       	call   800730 <cprintf>
  800080:	83 c4 10             	add    $0x10,%esp
  800083:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  800088:	ff 73 04             	pushl  0x4(%ebx)
  80008b:	ff 76 04             	pushl  0x4(%esi)
  80008e:	68 92 16 80 00       	push   $0x801692
  800093:	68 74 16 80 00       	push   $0x801674
  800098:	e8 93 06 00 00       	call   800730 <cprintf>
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8000a3:	39 46 04             	cmp    %eax,0x4(%esi)
  8000a6:	0f 84 0f 02 00 00    	je     8002bb <check_regs+0x288>
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 88 16 80 00       	push   $0x801688
  8000b4:	e8 77 06 00 00       	call   800730 <cprintf>
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000c1:	ff 73 08             	pushl  0x8(%ebx)
  8000c4:	ff 76 08             	pushl  0x8(%esi)
  8000c7:	68 96 16 80 00       	push   $0x801696
  8000cc:	68 74 16 80 00       	push   $0x801674
  8000d1:	e8 5a 06 00 00       	call   800730 <cprintf>
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8b 43 08             	mov    0x8(%ebx),%eax
  8000dc:	39 46 08             	cmp    %eax,0x8(%esi)
  8000df:	0f 84 eb 01 00 00    	je     8002d0 <check_regs+0x29d>
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	68 88 16 80 00       	push   $0x801688
  8000ed:	e8 3e 06 00 00       	call   800730 <cprintf>
  8000f2:	83 c4 10             	add    $0x10,%esp
  8000f5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  8000fa:	ff 73 10             	pushl  0x10(%ebx)
  8000fd:	ff 76 10             	pushl  0x10(%esi)
  800100:	68 9a 16 80 00       	push   $0x80169a
  800105:	68 74 16 80 00       	push   $0x801674
  80010a:	e8 21 06 00 00       	call   800730 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	8b 43 10             	mov    0x10(%ebx),%eax
  800115:	39 46 10             	cmp    %eax,0x10(%esi)
  800118:	0f 84 c7 01 00 00    	je     8002e5 <check_regs+0x2b2>
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	68 88 16 80 00       	push   $0x801688
  800126:	e8 05 06 00 00       	call   800730 <cprintf>
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800133:	ff 73 14             	pushl  0x14(%ebx)
  800136:	ff 76 14             	pushl  0x14(%esi)
  800139:	68 9e 16 80 00       	push   $0x80169e
  80013e:	68 74 16 80 00       	push   $0x801674
  800143:	e8 e8 05 00 00       	call   800730 <cprintf>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	8b 43 14             	mov    0x14(%ebx),%eax
  80014e:	39 46 14             	cmp    %eax,0x14(%esi)
  800151:	0f 84 a3 01 00 00    	je     8002fa <check_regs+0x2c7>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	68 88 16 80 00       	push   $0x801688
  80015f:	e8 cc 05 00 00       	call   800730 <cprintf>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  80016c:	ff 73 18             	pushl  0x18(%ebx)
  80016f:	ff 76 18             	pushl  0x18(%esi)
  800172:	68 a2 16 80 00       	push   $0x8016a2
  800177:	68 74 16 80 00       	push   $0x801674
  80017c:	e8 af 05 00 00       	call   800730 <cprintf>
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	8b 43 18             	mov    0x18(%ebx),%eax
  800187:	39 46 18             	cmp    %eax,0x18(%esi)
  80018a:	0f 84 7f 01 00 00    	je     80030f <check_regs+0x2dc>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 88 16 80 00       	push   $0x801688
  800198:	e8 93 05 00 00       	call   800730 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001a5:	ff 73 1c             	pushl  0x1c(%ebx)
  8001a8:	ff 76 1c             	pushl  0x1c(%esi)
  8001ab:	68 a6 16 80 00       	push   $0x8016a6
  8001b0:	68 74 16 80 00       	push   $0x801674
  8001b5:	e8 76 05 00 00       	call   800730 <cprintf>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	8b 43 1c             	mov    0x1c(%ebx),%eax
  8001c0:	39 46 1c             	cmp    %eax,0x1c(%esi)
  8001c3:	0f 84 5b 01 00 00    	je     800324 <check_regs+0x2f1>
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	68 88 16 80 00       	push   $0x801688
  8001d1:	e8 5a 05 00 00       	call   800730 <cprintf>
  8001d6:	83 c4 10             	add    $0x10,%esp
  8001d9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  8001de:	ff 73 20             	pushl  0x20(%ebx)
  8001e1:	ff 76 20             	pushl  0x20(%esi)
  8001e4:	68 aa 16 80 00       	push   $0x8016aa
  8001e9:	68 74 16 80 00       	push   $0x801674
  8001ee:	e8 3d 05 00 00       	call   800730 <cprintf>
  8001f3:	83 c4 10             	add    $0x10,%esp
  8001f6:	8b 43 20             	mov    0x20(%ebx),%eax
  8001f9:	39 46 20             	cmp    %eax,0x20(%esi)
  8001fc:	0f 84 37 01 00 00    	je     800339 <check_regs+0x306>
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	68 88 16 80 00       	push   $0x801688
  80020a:	e8 21 05 00 00       	call   800730 <cprintf>
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  800217:	ff 73 24             	pushl  0x24(%ebx)
  80021a:	ff 76 24             	pushl  0x24(%esi)
  80021d:	68 ae 16 80 00       	push   $0x8016ae
  800222:	68 74 16 80 00       	push   $0x801674
  800227:	e8 04 05 00 00       	call   800730 <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8b 43 24             	mov    0x24(%ebx),%eax
  800232:	39 46 24             	cmp    %eax,0x24(%esi)
  800235:	0f 84 13 01 00 00    	je     80034e <check_regs+0x31b>
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	68 88 16 80 00       	push   $0x801688
  800243:	e8 e8 04 00 00       	call   800730 <cprintf>
	CHECK(esp, esp);
  800248:	ff 73 28             	pushl  0x28(%ebx)
  80024b:	ff 76 28             	pushl  0x28(%esi)
  80024e:	68 b5 16 80 00       	push   $0x8016b5
  800253:	68 74 16 80 00       	push   $0x801674
  800258:	e8 d3 04 00 00       	call   800730 <cprintf>
  80025d:	83 c4 20             	add    $0x20,%esp
  800260:	8b 43 28             	mov    0x28(%ebx),%eax
  800263:	39 46 28             	cmp    %eax,0x28(%esi)
  800266:	0f 84 53 01 00 00    	je     8003bf <check_regs+0x38c>
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	68 88 16 80 00       	push   $0x801688
  800274:	e8 b7 04 00 00       	call   800730 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800279:	83 c4 08             	add    $0x8,%esp
  80027c:	ff 75 0c             	pushl  0xc(%ebp)
  80027f:	68 b9 16 80 00       	push   $0x8016b9
  800284:	e8 a7 04 00 00       	call   800730 <cprintf>
  800289:	83 c4 10             	add    $0x10,%esp
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	68 88 16 80 00       	push   $0x801688
  800294:	e8 97 04 00 00       	call   800730 <cprintf>
  800299:	83 c4 10             	add    $0x10,%esp
}
  80029c:	e9 16 01 00 00       	jmp    8003b7 <check_regs+0x384>
	CHECK(edi, regs.reg_edi);
  8002a1:	83 ec 0c             	sub    $0xc,%esp
  8002a4:	68 84 16 80 00       	push   $0x801684
  8002a9:	e8 82 04 00 00       	call   800730 <cprintf>
  8002ae:	83 c4 10             	add    $0x10,%esp
	int mismatch = 0;
  8002b1:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b6:	e9 cd fd ff ff       	jmp    800088 <check_regs+0x55>
	CHECK(esi, regs.reg_esi);
  8002bb:	83 ec 0c             	sub    $0xc,%esp
  8002be:	68 84 16 80 00       	push   $0x801684
  8002c3:	e8 68 04 00 00       	call   800730 <cprintf>
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	e9 f1 fd ff ff       	jmp    8000c1 <check_regs+0x8e>
	CHECK(ebp, regs.reg_ebp);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	68 84 16 80 00       	push   $0x801684
  8002d8:	e8 53 04 00 00       	call   800730 <cprintf>
  8002dd:	83 c4 10             	add    $0x10,%esp
  8002e0:	e9 15 fe ff ff       	jmp    8000fa <check_regs+0xc7>
	CHECK(ebx, regs.reg_ebx);
  8002e5:	83 ec 0c             	sub    $0xc,%esp
  8002e8:	68 84 16 80 00       	push   $0x801684
  8002ed:	e8 3e 04 00 00       	call   800730 <cprintf>
  8002f2:	83 c4 10             	add    $0x10,%esp
  8002f5:	e9 39 fe ff ff       	jmp    800133 <check_regs+0x100>
	CHECK(edx, regs.reg_edx);
  8002fa:	83 ec 0c             	sub    $0xc,%esp
  8002fd:	68 84 16 80 00       	push   $0x801684
  800302:	e8 29 04 00 00       	call   800730 <cprintf>
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	e9 5d fe ff ff       	jmp    80016c <check_regs+0x139>
	CHECK(ecx, regs.reg_ecx);
  80030f:	83 ec 0c             	sub    $0xc,%esp
  800312:	68 84 16 80 00       	push   $0x801684
  800317:	e8 14 04 00 00       	call   800730 <cprintf>
  80031c:	83 c4 10             	add    $0x10,%esp
  80031f:	e9 81 fe ff ff       	jmp    8001a5 <check_regs+0x172>
	CHECK(eax, regs.reg_eax);
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	68 84 16 80 00       	push   $0x801684
  80032c:	e8 ff 03 00 00       	call   800730 <cprintf>
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	e9 a5 fe ff ff       	jmp    8001de <check_regs+0x1ab>
	CHECK(eip, eip);
  800339:	83 ec 0c             	sub    $0xc,%esp
  80033c:	68 84 16 80 00       	push   $0x801684
  800341:	e8 ea 03 00 00       	call   800730 <cprintf>
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	e9 c9 fe ff ff       	jmp    800217 <check_regs+0x1e4>
	CHECK(eflags, eflags);
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	68 84 16 80 00       	push   $0x801684
  800356:	e8 d5 03 00 00       	call   800730 <cprintf>
	CHECK(esp, esp);
  80035b:	ff 73 28             	pushl  0x28(%ebx)
  80035e:	ff 76 28             	pushl  0x28(%esi)
  800361:	68 b5 16 80 00       	push   $0x8016b5
  800366:	68 74 16 80 00       	push   $0x801674
  80036b:	e8 c0 03 00 00       	call   800730 <cprintf>
  800370:	83 c4 20             	add    $0x20,%esp
  800373:	8b 43 28             	mov    0x28(%ebx),%eax
  800376:	39 46 28             	cmp    %eax,0x28(%esi)
  800379:	0f 85 ed fe ff ff    	jne    80026c <check_regs+0x239>
  80037f:	83 ec 0c             	sub    $0xc,%esp
  800382:	68 84 16 80 00       	push   $0x801684
  800387:	e8 a4 03 00 00       	call   800730 <cprintf>
	cprintf("Registers %s ", testname);
  80038c:	83 c4 08             	add    $0x8,%esp
  80038f:	ff 75 0c             	pushl  0xc(%ebp)
  800392:	68 b9 16 80 00       	push   $0x8016b9
  800397:	e8 94 03 00 00       	call   800730 <cprintf>
	if (!mismatch)
  80039c:	83 c4 10             	add    $0x10,%esp
  80039f:	85 ff                	test   %edi,%edi
  8003a1:	0f 85 e5 fe ff ff    	jne    80028c <check_regs+0x259>
		cprintf("OK\n");
  8003a7:	83 ec 0c             	sub    $0xc,%esp
  8003aa:	68 84 16 80 00       	push   $0x801684
  8003af:	e8 7c 03 00 00       	call   800730 <cprintf>
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
  8003c2:	68 84 16 80 00       	push   $0x801684
  8003c7:	e8 64 03 00 00       	call   800730 <cprintf>
	cprintf("Registers %s ", testname);
  8003cc:	83 c4 08             	add    $0x8,%esp
  8003cf:	ff 75 0c             	pushl  0xc(%ebp)
  8003d2:	68 b9 16 80 00       	push   $0x8016b9
  8003d7:	e8 54 03 00 00       	call   800730 <cprintf>
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
  80046a:	68 df 16 80 00       	push   $0x8016df
  80046f:	68 ed 16 80 00       	push   $0x8016ed
  800474:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800479:	ba d8 16 80 00       	mov    $0x8016d8,%edx
  80047e:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  800483:	e8 ab fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800488:	83 c4 0c             	add    $0xc,%esp
  80048b:	6a 07                	push   $0x7
  80048d:	68 00 00 40 00       	push   $0x400000
  800492:	6a 00                	push   $0x0
  800494:	e8 e2 0c 00 00       	call   80117b <sys_page_alloc>
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
  8004a9:	68 20 17 80 00       	push   $0x801720
  8004ae:	6a 50                	push   $0x50
  8004b0:	68 c7 16 80 00       	push   $0x8016c7
  8004b5:	e8 8f 01 00 00       	call   800649 <_panic>
		panic("sys_page_alloc: %e", r);
  8004ba:	50                   	push   %eax
  8004bb:	68 f4 16 80 00       	push   $0x8016f4
  8004c0:	6a 5c                	push   $0x5c
  8004c2:	68 c7 16 80 00       	push   $0x8016c7
  8004c7:	e8 7d 01 00 00       	call   800649 <_panic>

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
  8004db:	e8 66 0e 00 00       	call   801346 <set_pgfault_handler>

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
  8005b4:	68 07 17 80 00       	push   $0x801707
  8005b9:	68 18 17 80 00       	push   $0x801718
  8005be:	b9 20 20 80 00       	mov    $0x802020,%ecx
  8005c3:	ba d8 16 80 00       	mov    $0x8016d8,%edx
  8005c8:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  8005cd:	e8 61 fa ff ff       	call   800033 <check_regs>
}
  8005d2:	83 c4 10             	add    $0x10,%esp
  8005d5:	c9                   	leave  
  8005d6:	c3                   	ret    
		cprintf("EIP after page-fault MISMATCH\n");
  8005d7:	83 ec 0c             	sub    $0xc,%esp
  8005da:	68 54 17 80 00       	push   $0x801754
  8005df:	e8 4c 01 00 00       	call   800730 <cprintf>
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
    envid_t envid = sys_getenvid();
  8005f8:	e8 38 0b 00 00       	call   801135 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  8005fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800602:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800605:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80060a:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80060f:	85 db                	test   %ebx,%ebx
  800611:	7e 07                	jle    80061a <libmain+0x31>
		binaryname = argv[0];
  800613:	8b 06                	mov    (%esi),%eax
  800615:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80061a:	83 ec 08             	sub    $0x8,%esp
  80061d:	56                   	push   %esi
  80061e:	53                   	push   %ebx
  80061f:	e8 a8 fe ff ff       	call   8004cc <umain>

	// exit gracefully
	exit();
  800624:	e8 0a 00 00 00       	call   800633 <exit>
}
  800629:	83 c4 10             	add    $0x10,%esp
  80062c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80062f:	5b                   	pop    %ebx
  800630:	5e                   	pop    %esi
  800631:	5d                   	pop    %ebp
  800632:	c3                   	ret    

00800633 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800633:	f3 0f 1e fb          	endbr32 
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80063d:	6a 00                	push   $0x0
  80063f:	e8 ac 0a 00 00       	call   8010f0 <sys_env_destroy>
}
  800644:	83 c4 10             	add    $0x10,%esp
  800647:	c9                   	leave  
  800648:	c3                   	ret    

00800649 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800649:	f3 0f 1e fb          	endbr32 
  80064d:	55                   	push   %ebp
  80064e:	89 e5                	mov    %esp,%ebp
  800650:	56                   	push   %esi
  800651:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800652:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800655:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80065b:	e8 d5 0a 00 00       	call   801135 <sys_getenvid>
  800660:	83 ec 0c             	sub    $0xc,%esp
  800663:	ff 75 0c             	pushl  0xc(%ebp)
  800666:	ff 75 08             	pushl  0x8(%ebp)
  800669:	56                   	push   %esi
  80066a:	50                   	push   %eax
  80066b:	68 80 17 80 00       	push   $0x801780
  800670:	e8 bb 00 00 00       	call   800730 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800675:	83 c4 18             	add    $0x18,%esp
  800678:	53                   	push   %ebx
  800679:	ff 75 10             	pushl  0x10(%ebp)
  80067c:	e8 5a 00 00 00       	call   8006db <vcprintf>
	cprintf("\n");
  800681:	c7 04 24 90 16 80 00 	movl   $0x801690,(%esp)
  800688:	e8 a3 00 00 00       	call   800730 <cprintf>
  80068d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800690:	cc                   	int3   
  800691:	eb fd                	jmp    800690 <_panic+0x47>

00800693 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800693:	f3 0f 1e fb          	endbr32 
  800697:	55                   	push   %ebp
  800698:	89 e5                	mov    %esp,%ebp
  80069a:	53                   	push   %ebx
  80069b:	83 ec 04             	sub    $0x4,%esp
  80069e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006a1:	8b 13                	mov    (%ebx),%edx
  8006a3:	8d 42 01             	lea    0x1(%edx),%eax
  8006a6:	89 03                	mov    %eax,(%ebx)
  8006a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ab:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006af:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006b4:	74 09                	je     8006bf <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8006b6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006bd:	c9                   	leave  
  8006be:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	68 ff 00 00 00       	push   $0xff
  8006c7:	8d 43 08             	lea    0x8(%ebx),%eax
  8006ca:	50                   	push   %eax
  8006cb:	e8 db 09 00 00       	call   8010ab <sys_cputs>
		b->idx = 0;
  8006d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006d6:	83 c4 10             	add    $0x10,%esp
  8006d9:	eb db                	jmp    8006b6 <putch+0x23>

008006db <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006db:	f3 0f 1e fb          	endbr32 
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006e8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006ef:	00 00 00 
	b.cnt = 0;
  8006f2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006f9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006fc:	ff 75 0c             	pushl  0xc(%ebp)
  8006ff:	ff 75 08             	pushl  0x8(%ebp)
  800702:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800708:	50                   	push   %eax
  800709:	68 93 06 80 00       	push   $0x800693
  80070e:	e8 20 01 00 00       	call   800833 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800713:	83 c4 08             	add    $0x8,%esp
  800716:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80071c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800722:	50                   	push   %eax
  800723:	e8 83 09 00 00       	call   8010ab <sys_cputs>

	return b.cnt;
}
  800728:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80072e:	c9                   	leave  
  80072f:	c3                   	ret    

00800730 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800730:	f3 0f 1e fb          	endbr32 
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80073a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80073d:	50                   	push   %eax
  80073e:	ff 75 08             	pushl  0x8(%ebp)
  800741:	e8 95 ff ff ff       	call   8006db <vcprintf>
	va_end(ap);

	return cnt;
}
  800746:	c9                   	leave  
  800747:	c3                   	ret    

00800748 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800748:	55                   	push   %ebp
  800749:	89 e5                	mov    %esp,%ebp
  80074b:	57                   	push   %edi
  80074c:	56                   	push   %esi
  80074d:	53                   	push   %ebx
  80074e:	83 ec 1c             	sub    $0x1c,%esp
  800751:	89 c7                	mov    %eax,%edi
  800753:	89 d6                	mov    %edx,%esi
  800755:	8b 45 08             	mov    0x8(%ebp),%eax
  800758:	8b 55 0c             	mov    0xc(%ebp),%edx
  80075b:	89 d1                	mov    %edx,%ecx
  80075d:	89 c2                	mov    %eax,%edx
  80075f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800762:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800765:	8b 45 10             	mov    0x10(%ebp),%eax
  800768:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80076b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80076e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800775:	39 c2                	cmp    %eax,%edx
  800777:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80077a:	72 3e                	jb     8007ba <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80077c:	83 ec 0c             	sub    $0xc,%esp
  80077f:	ff 75 18             	pushl  0x18(%ebp)
  800782:	83 eb 01             	sub    $0x1,%ebx
  800785:	53                   	push   %ebx
  800786:	50                   	push   %eax
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80078d:	ff 75 e0             	pushl  -0x20(%ebp)
  800790:	ff 75 dc             	pushl  -0x24(%ebp)
  800793:	ff 75 d8             	pushl  -0x28(%ebp)
  800796:	e8 55 0c 00 00       	call   8013f0 <__udivdi3>
  80079b:	83 c4 18             	add    $0x18,%esp
  80079e:	52                   	push   %edx
  80079f:	50                   	push   %eax
  8007a0:	89 f2                	mov    %esi,%edx
  8007a2:	89 f8                	mov    %edi,%eax
  8007a4:	e8 9f ff ff ff       	call   800748 <printnum>
  8007a9:	83 c4 20             	add    $0x20,%esp
  8007ac:	eb 13                	jmp    8007c1 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007ae:	83 ec 08             	sub    $0x8,%esp
  8007b1:	56                   	push   %esi
  8007b2:	ff 75 18             	pushl  0x18(%ebp)
  8007b5:	ff d7                	call   *%edi
  8007b7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8007ba:	83 eb 01             	sub    $0x1,%ebx
  8007bd:	85 db                	test   %ebx,%ebx
  8007bf:	7f ed                	jg     8007ae <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007c1:	83 ec 08             	sub    $0x8,%esp
  8007c4:	56                   	push   %esi
  8007c5:	83 ec 04             	sub    $0x4,%esp
  8007c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8007d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8007d4:	e8 27 0d 00 00       	call   801500 <__umoddi3>
  8007d9:	83 c4 14             	add    $0x14,%esp
  8007dc:	0f be 80 a3 17 80 00 	movsbl 0x8017a3(%eax),%eax
  8007e3:	50                   	push   %eax
  8007e4:	ff d7                	call   *%edi
}
  8007e6:	83 c4 10             	add    $0x10,%esp
  8007e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ec:	5b                   	pop    %ebx
  8007ed:	5e                   	pop    %esi
  8007ee:	5f                   	pop    %edi
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007f1:	f3 0f 1e fb          	endbr32 
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007fb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007ff:	8b 10                	mov    (%eax),%edx
  800801:	3b 50 04             	cmp    0x4(%eax),%edx
  800804:	73 0a                	jae    800810 <sprintputch+0x1f>
		*b->buf++ = ch;
  800806:	8d 4a 01             	lea    0x1(%edx),%ecx
  800809:	89 08                	mov    %ecx,(%eax)
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	88 02                	mov    %al,(%edx)
}
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <printfmt>:
{
  800812:	f3 0f 1e fb          	endbr32 
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80081c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80081f:	50                   	push   %eax
  800820:	ff 75 10             	pushl  0x10(%ebp)
  800823:	ff 75 0c             	pushl  0xc(%ebp)
  800826:	ff 75 08             	pushl  0x8(%ebp)
  800829:	e8 05 00 00 00       	call   800833 <vprintfmt>
}
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	c9                   	leave  
  800832:	c3                   	ret    

00800833 <vprintfmt>:
{
  800833:	f3 0f 1e fb          	endbr32 
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	57                   	push   %edi
  80083b:	56                   	push   %esi
  80083c:	53                   	push   %ebx
  80083d:	83 ec 3c             	sub    $0x3c,%esp
  800840:	8b 75 08             	mov    0x8(%ebp),%esi
  800843:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800846:	8b 7d 10             	mov    0x10(%ebp),%edi
  800849:	e9 4a 03 00 00       	jmp    800b98 <vprintfmt+0x365>
		padc = ' ';
  80084e:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800852:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800859:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800860:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800867:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80086c:	8d 47 01             	lea    0x1(%edi),%eax
  80086f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800872:	0f b6 17             	movzbl (%edi),%edx
  800875:	8d 42 dd             	lea    -0x23(%edx),%eax
  800878:	3c 55                	cmp    $0x55,%al
  80087a:	0f 87 de 03 00 00    	ja     800c5e <vprintfmt+0x42b>
  800880:	0f b6 c0             	movzbl %al,%eax
  800883:	3e ff 24 85 60 18 80 	notrack jmp *0x801860(,%eax,4)
  80088a:	00 
  80088b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80088e:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800892:	eb d8                	jmp    80086c <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800894:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800897:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80089b:	eb cf                	jmp    80086c <vprintfmt+0x39>
  80089d:	0f b6 d2             	movzbl %dl,%edx
  8008a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8008a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8008ab:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8008ae:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8008b2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8008b5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8008b8:	83 f9 09             	cmp    $0x9,%ecx
  8008bb:	77 55                	ja     800912 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8008bd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8008c0:	eb e9                	jmp    8008ab <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8008c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c5:	8b 00                	mov    (%eax),%eax
  8008c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cd:	8d 40 04             	lea    0x4(%eax),%eax
  8008d0:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8008d6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008da:	79 90                	jns    80086c <vprintfmt+0x39>
				width = precision, precision = -1;
  8008dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008df:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008e2:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8008e9:	eb 81                	jmp    80086c <vprintfmt+0x39>
  8008eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008ee:	85 c0                	test   %eax,%eax
  8008f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8008f5:	0f 49 d0             	cmovns %eax,%edx
  8008f8:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8008fe:	e9 69 ff ff ff       	jmp    80086c <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800903:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800906:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80090d:	e9 5a ff ff ff       	jmp    80086c <vprintfmt+0x39>
  800912:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800915:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800918:	eb bc                	jmp    8008d6 <vprintfmt+0xa3>
			lflag++;
  80091a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80091d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800920:	e9 47 ff ff ff       	jmp    80086c <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800925:	8b 45 14             	mov    0x14(%ebp),%eax
  800928:	8d 78 04             	lea    0x4(%eax),%edi
  80092b:	83 ec 08             	sub    $0x8,%esp
  80092e:	53                   	push   %ebx
  80092f:	ff 30                	pushl  (%eax)
  800931:	ff d6                	call   *%esi
			break;
  800933:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800936:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800939:	e9 57 02 00 00       	jmp    800b95 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80093e:	8b 45 14             	mov    0x14(%ebp),%eax
  800941:	8d 78 04             	lea    0x4(%eax),%edi
  800944:	8b 00                	mov    (%eax),%eax
  800946:	99                   	cltd   
  800947:	31 d0                	xor    %edx,%eax
  800949:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80094b:	83 f8 08             	cmp    $0x8,%eax
  80094e:	7f 23                	jg     800973 <vprintfmt+0x140>
  800950:	8b 14 85 c0 19 80 00 	mov    0x8019c0(,%eax,4),%edx
  800957:	85 d2                	test   %edx,%edx
  800959:	74 18                	je     800973 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80095b:	52                   	push   %edx
  80095c:	68 c4 17 80 00       	push   $0x8017c4
  800961:	53                   	push   %ebx
  800962:	56                   	push   %esi
  800963:	e8 aa fe ff ff       	call   800812 <printfmt>
  800968:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80096b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80096e:	e9 22 02 00 00       	jmp    800b95 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800973:	50                   	push   %eax
  800974:	68 bb 17 80 00       	push   $0x8017bb
  800979:	53                   	push   %ebx
  80097a:	56                   	push   %esi
  80097b:	e8 92 fe ff ff       	call   800812 <printfmt>
  800980:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800983:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800986:	e9 0a 02 00 00       	jmp    800b95 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  80098b:	8b 45 14             	mov    0x14(%ebp),%eax
  80098e:	83 c0 04             	add    $0x4,%eax
  800991:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800994:	8b 45 14             	mov    0x14(%ebp),%eax
  800997:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800999:	85 d2                	test   %edx,%edx
  80099b:	b8 b4 17 80 00       	mov    $0x8017b4,%eax
  8009a0:	0f 45 c2             	cmovne %edx,%eax
  8009a3:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8009a6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009aa:	7e 06                	jle    8009b2 <vprintfmt+0x17f>
  8009ac:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8009b0:	75 0d                	jne    8009bf <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009b2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009b5:	89 c7                	mov    %eax,%edi
  8009b7:	03 45 e0             	add    -0x20(%ebp),%eax
  8009ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009bd:	eb 55                	jmp    800a14 <vprintfmt+0x1e1>
  8009bf:	83 ec 08             	sub    $0x8,%esp
  8009c2:	ff 75 d8             	pushl  -0x28(%ebp)
  8009c5:	ff 75 cc             	pushl  -0x34(%ebp)
  8009c8:	e8 45 03 00 00       	call   800d12 <strnlen>
  8009cd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8009d0:	29 c2                	sub    %eax,%edx
  8009d2:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8009d5:	83 c4 10             	add    $0x10,%esp
  8009d8:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8009da:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8009de:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8009e1:	85 ff                	test   %edi,%edi
  8009e3:	7e 11                	jle    8009f6 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8009e5:	83 ec 08             	sub    $0x8,%esp
  8009e8:	53                   	push   %ebx
  8009e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8009ec:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ee:	83 ef 01             	sub    $0x1,%edi
  8009f1:	83 c4 10             	add    $0x10,%esp
  8009f4:	eb eb                	jmp    8009e1 <vprintfmt+0x1ae>
  8009f6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8009f9:	85 d2                	test   %edx,%edx
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800a00:	0f 49 c2             	cmovns %edx,%eax
  800a03:	29 c2                	sub    %eax,%edx
  800a05:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800a08:	eb a8                	jmp    8009b2 <vprintfmt+0x17f>
					putch(ch, putdat);
  800a0a:	83 ec 08             	sub    $0x8,%esp
  800a0d:	53                   	push   %ebx
  800a0e:	52                   	push   %edx
  800a0f:	ff d6                	call   *%esi
  800a11:	83 c4 10             	add    $0x10,%esp
  800a14:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a17:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a19:	83 c7 01             	add    $0x1,%edi
  800a1c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a20:	0f be d0             	movsbl %al,%edx
  800a23:	85 d2                	test   %edx,%edx
  800a25:	74 4b                	je     800a72 <vprintfmt+0x23f>
  800a27:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a2b:	78 06                	js     800a33 <vprintfmt+0x200>
  800a2d:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800a31:	78 1e                	js     800a51 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800a33:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800a37:	74 d1                	je     800a0a <vprintfmt+0x1d7>
  800a39:	0f be c0             	movsbl %al,%eax
  800a3c:	83 e8 20             	sub    $0x20,%eax
  800a3f:	83 f8 5e             	cmp    $0x5e,%eax
  800a42:	76 c6                	jbe    800a0a <vprintfmt+0x1d7>
					putch('?', putdat);
  800a44:	83 ec 08             	sub    $0x8,%esp
  800a47:	53                   	push   %ebx
  800a48:	6a 3f                	push   $0x3f
  800a4a:	ff d6                	call   *%esi
  800a4c:	83 c4 10             	add    $0x10,%esp
  800a4f:	eb c3                	jmp    800a14 <vprintfmt+0x1e1>
  800a51:	89 cf                	mov    %ecx,%edi
  800a53:	eb 0e                	jmp    800a63 <vprintfmt+0x230>
				putch(' ', putdat);
  800a55:	83 ec 08             	sub    $0x8,%esp
  800a58:	53                   	push   %ebx
  800a59:	6a 20                	push   $0x20
  800a5b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800a5d:	83 ef 01             	sub    $0x1,%edi
  800a60:	83 c4 10             	add    $0x10,%esp
  800a63:	85 ff                	test   %edi,%edi
  800a65:	7f ee                	jg     800a55 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800a67:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800a6a:	89 45 14             	mov    %eax,0x14(%ebp)
  800a6d:	e9 23 01 00 00       	jmp    800b95 <vprintfmt+0x362>
  800a72:	89 cf                	mov    %ecx,%edi
  800a74:	eb ed                	jmp    800a63 <vprintfmt+0x230>
	if (lflag >= 2)
  800a76:	83 f9 01             	cmp    $0x1,%ecx
  800a79:	7f 1b                	jg     800a96 <vprintfmt+0x263>
	else if (lflag)
  800a7b:	85 c9                	test   %ecx,%ecx
  800a7d:	74 63                	je     800ae2 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800a7f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a82:	8b 00                	mov    (%eax),%eax
  800a84:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a87:	99                   	cltd   
  800a88:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a8b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8e:	8d 40 04             	lea    0x4(%eax),%eax
  800a91:	89 45 14             	mov    %eax,0x14(%ebp)
  800a94:	eb 17                	jmp    800aad <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800a96:	8b 45 14             	mov    0x14(%ebp),%eax
  800a99:	8b 50 04             	mov    0x4(%eax),%edx
  800a9c:	8b 00                	mov    (%eax),%eax
  800a9e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aa1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800aa4:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa7:	8d 40 08             	lea    0x8(%eax),%eax
  800aaa:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800aad:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ab0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800ab3:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800ab8:	85 c9                	test   %ecx,%ecx
  800aba:	0f 89 bb 00 00 00    	jns    800b7b <vprintfmt+0x348>
				putch('-', putdat);
  800ac0:	83 ec 08             	sub    $0x8,%esp
  800ac3:	53                   	push   %ebx
  800ac4:	6a 2d                	push   $0x2d
  800ac6:	ff d6                	call   *%esi
				num = -(long long) num;
  800ac8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800acb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800ace:	f7 da                	neg    %edx
  800ad0:	83 d1 00             	adc    $0x0,%ecx
  800ad3:	f7 d9                	neg    %ecx
  800ad5:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800ad8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800add:	e9 99 00 00 00       	jmp    800b7b <vprintfmt+0x348>
		return va_arg(*ap, int);
  800ae2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae5:	8b 00                	mov    (%eax),%eax
  800ae7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aea:	99                   	cltd   
  800aeb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800aee:	8b 45 14             	mov    0x14(%ebp),%eax
  800af1:	8d 40 04             	lea    0x4(%eax),%eax
  800af4:	89 45 14             	mov    %eax,0x14(%ebp)
  800af7:	eb b4                	jmp    800aad <vprintfmt+0x27a>
	if (lflag >= 2)
  800af9:	83 f9 01             	cmp    $0x1,%ecx
  800afc:	7f 1b                	jg     800b19 <vprintfmt+0x2e6>
	else if (lflag)
  800afe:	85 c9                	test   %ecx,%ecx
  800b00:	74 2c                	je     800b2e <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800b02:	8b 45 14             	mov    0x14(%ebp),%eax
  800b05:	8b 10                	mov    (%eax),%edx
  800b07:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0c:	8d 40 04             	lea    0x4(%eax),%eax
  800b0f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b12:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800b17:	eb 62                	jmp    800b7b <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800b19:	8b 45 14             	mov    0x14(%ebp),%eax
  800b1c:	8b 10                	mov    (%eax),%edx
  800b1e:	8b 48 04             	mov    0x4(%eax),%ecx
  800b21:	8d 40 08             	lea    0x8(%eax),%eax
  800b24:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b27:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800b2c:	eb 4d                	jmp    800b7b <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800b2e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b31:	8b 10                	mov    (%eax),%edx
  800b33:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b38:	8d 40 04             	lea    0x4(%eax),%eax
  800b3b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b3e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800b43:	eb 36                	jmp    800b7b <vprintfmt+0x348>
	if (lflag >= 2)
  800b45:	83 f9 01             	cmp    $0x1,%ecx
  800b48:	7f 17                	jg     800b61 <vprintfmt+0x32e>
	else if (lflag)
  800b4a:	85 c9                	test   %ecx,%ecx
  800b4c:	74 6e                	je     800bbc <vprintfmt+0x389>
		return va_arg(*ap, long);
  800b4e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b51:	8b 10                	mov    (%eax),%edx
  800b53:	89 d0                	mov    %edx,%eax
  800b55:	99                   	cltd   
  800b56:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800b59:	8d 49 04             	lea    0x4(%ecx),%ecx
  800b5c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800b5f:	eb 11                	jmp    800b72 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800b61:	8b 45 14             	mov    0x14(%ebp),%eax
  800b64:	8b 50 04             	mov    0x4(%eax),%edx
  800b67:	8b 00                	mov    (%eax),%eax
  800b69:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800b6c:	8d 49 08             	lea    0x8(%ecx),%ecx
  800b6f:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800b72:	89 d1                	mov    %edx,%ecx
  800b74:	89 c2                	mov    %eax,%edx
            base = 8;
  800b76:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800b7b:	83 ec 0c             	sub    $0xc,%esp
  800b7e:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800b82:	57                   	push   %edi
  800b83:	ff 75 e0             	pushl  -0x20(%ebp)
  800b86:	50                   	push   %eax
  800b87:	51                   	push   %ecx
  800b88:	52                   	push   %edx
  800b89:	89 da                	mov    %ebx,%edx
  800b8b:	89 f0                	mov    %esi,%eax
  800b8d:	e8 b6 fb ff ff       	call   800748 <printnum>
			break;
  800b92:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800b95:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b98:	83 c7 01             	add    $0x1,%edi
  800b9b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800b9f:	83 f8 25             	cmp    $0x25,%eax
  800ba2:	0f 84 a6 fc ff ff    	je     80084e <vprintfmt+0x1b>
			if (ch == '\0')
  800ba8:	85 c0                	test   %eax,%eax
  800baa:	0f 84 ce 00 00 00    	je     800c7e <vprintfmt+0x44b>
			putch(ch, putdat);
  800bb0:	83 ec 08             	sub    $0x8,%esp
  800bb3:	53                   	push   %ebx
  800bb4:	50                   	push   %eax
  800bb5:	ff d6                	call   *%esi
  800bb7:	83 c4 10             	add    $0x10,%esp
  800bba:	eb dc                	jmp    800b98 <vprintfmt+0x365>
		return va_arg(*ap, int);
  800bbc:	8b 45 14             	mov    0x14(%ebp),%eax
  800bbf:	8b 10                	mov    (%eax),%edx
  800bc1:	89 d0                	mov    %edx,%eax
  800bc3:	99                   	cltd   
  800bc4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800bc7:	8d 49 04             	lea    0x4(%ecx),%ecx
  800bca:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800bcd:	eb a3                	jmp    800b72 <vprintfmt+0x33f>
			putch('0', putdat);
  800bcf:	83 ec 08             	sub    $0x8,%esp
  800bd2:	53                   	push   %ebx
  800bd3:	6a 30                	push   $0x30
  800bd5:	ff d6                	call   *%esi
			putch('x', putdat);
  800bd7:	83 c4 08             	add    $0x8,%esp
  800bda:	53                   	push   %ebx
  800bdb:	6a 78                	push   $0x78
  800bdd:	ff d6                	call   *%esi
			num = (unsigned long long)
  800bdf:	8b 45 14             	mov    0x14(%ebp),%eax
  800be2:	8b 10                	mov    (%eax),%edx
  800be4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800be9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800bec:	8d 40 04             	lea    0x4(%eax),%eax
  800bef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800bf2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800bf7:	eb 82                	jmp    800b7b <vprintfmt+0x348>
	if (lflag >= 2)
  800bf9:	83 f9 01             	cmp    $0x1,%ecx
  800bfc:	7f 1e                	jg     800c1c <vprintfmt+0x3e9>
	else if (lflag)
  800bfe:	85 c9                	test   %ecx,%ecx
  800c00:	74 32                	je     800c34 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800c02:	8b 45 14             	mov    0x14(%ebp),%eax
  800c05:	8b 10                	mov    (%eax),%edx
  800c07:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c0c:	8d 40 04             	lea    0x4(%eax),%eax
  800c0f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c12:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800c17:	e9 5f ff ff ff       	jmp    800b7b <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800c1c:	8b 45 14             	mov    0x14(%ebp),%eax
  800c1f:	8b 10                	mov    (%eax),%edx
  800c21:	8b 48 04             	mov    0x4(%eax),%ecx
  800c24:	8d 40 08             	lea    0x8(%eax),%eax
  800c27:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c2a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800c2f:	e9 47 ff ff ff       	jmp    800b7b <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800c34:	8b 45 14             	mov    0x14(%ebp),%eax
  800c37:	8b 10                	mov    (%eax),%edx
  800c39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3e:	8d 40 04             	lea    0x4(%eax),%eax
  800c41:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c44:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800c49:	e9 2d ff ff ff       	jmp    800b7b <vprintfmt+0x348>
			putch(ch, putdat);
  800c4e:	83 ec 08             	sub    $0x8,%esp
  800c51:	53                   	push   %ebx
  800c52:	6a 25                	push   $0x25
  800c54:	ff d6                	call   *%esi
			break;
  800c56:	83 c4 10             	add    $0x10,%esp
  800c59:	e9 37 ff ff ff       	jmp    800b95 <vprintfmt+0x362>
			putch('%', putdat);
  800c5e:	83 ec 08             	sub    $0x8,%esp
  800c61:	53                   	push   %ebx
  800c62:	6a 25                	push   $0x25
  800c64:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c66:	83 c4 10             	add    $0x10,%esp
  800c69:	89 f8                	mov    %edi,%eax
  800c6b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800c6f:	74 05                	je     800c76 <vprintfmt+0x443>
  800c71:	83 e8 01             	sub    $0x1,%eax
  800c74:	eb f5                	jmp    800c6b <vprintfmt+0x438>
  800c76:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c79:	e9 17 ff ff ff       	jmp    800b95 <vprintfmt+0x362>
}
  800c7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c86:	f3 0f 1e fb          	endbr32 
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	83 ec 18             	sub    $0x18,%esp
  800c90:	8b 45 08             	mov    0x8(%ebp),%eax
  800c93:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c96:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c99:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c9d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ca0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	74 26                	je     800cd1 <vsnprintf+0x4b>
  800cab:	85 d2                	test   %edx,%edx
  800cad:	7e 22                	jle    800cd1 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800caf:	ff 75 14             	pushl  0x14(%ebp)
  800cb2:	ff 75 10             	pushl  0x10(%ebp)
  800cb5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cb8:	50                   	push   %eax
  800cb9:	68 f1 07 80 00       	push   $0x8007f1
  800cbe:	e8 70 fb ff ff       	call   800833 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cc3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cc6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ccc:	83 c4 10             	add    $0x10,%esp
}
  800ccf:	c9                   	leave  
  800cd0:	c3                   	ret    
		return -E_INVAL;
  800cd1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800cd6:	eb f7                	jmp    800ccf <vsnprintf+0x49>

00800cd8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cd8:	f3 0f 1e fb          	endbr32 
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ce2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ce5:	50                   	push   %eax
  800ce6:	ff 75 10             	pushl  0x10(%ebp)
  800ce9:	ff 75 0c             	pushl  0xc(%ebp)
  800cec:	ff 75 08             	pushl  0x8(%ebp)
  800cef:	e8 92 ff ff ff       	call   800c86 <vsnprintf>
	va_end(ap);

	return rc;
}
  800cf4:	c9                   	leave  
  800cf5:	c3                   	ret    

00800cf6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cf6:	f3 0f 1e fb          	endbr32 
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d00:	b8 00 00 00 00       	mov    $0x0,%eax
  800d05:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d09:	74 05                	je     800d10 <strlen+0x1a>
		n++;
  800d0b:	83 c0 01             	add    $0x1,%eax
  800d0e:	eb f5                	jmp    800d05 <strlen+0xf>
	return n;
}
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d12:	f3 0f 1e fb          	endbr32 
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d24:	39 d0                	cmp    %edx,%eax
  800d26:	74 0d                	je     800d35 <strnlen+0x23>
  800d28:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d2c:	74 05                	je     800d33 <strnlen+0x21>
		n++;
  800d2e:	83 c0 01             	add    $0x1,%eax
  800d31:	eb f1                	jmp    800d24 <strnlen+0x12>
  800d33:	89 c2                	mov    %eax,%edx
	return n;
}
  800d35:	89 d0                	mov    %edx,%eax
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d39:	f3 0f 1e fb          	endbr32 
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	53                   	push   %ebx
  800d41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d47:	b8 00 00 00 00       	mov    $0x0,%eax
  800d4c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800d50:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800d53:	83 c0 01             	add    $0x1,%eax
  800d56:	84 d2                	test   %dl,%dl
  800d58:	75 f2                	jne    800d4c <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800d5a:	89 c8                	mov    %ecx,%eax
  800d5c:	5b                   	pop    %ebx
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d5f:	f3 0f 1e fb          	endbr32 
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	53                   	push   %ebx
  800d67:	83 ec 10             	sub    $0x10,%esp
  800d6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d6d:	53                   	push   %ebx
  800d6e:	e8 83 ff ff ff       	call   800cf6 <strlen>
  800d73:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800d76:	ff 75 0c             	pushl  0xc(%ebp)
  800d79:	01 d8                	add    %ebx,%eax
  800d7b:	50                   	push   %eax
  800d7c:	e8 b8 ff ff ff       	call   800d39 <strcpy>
	return dst;
}
  800d81:	89 d8                	mov    %ebx,%eax
  800d83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d86:	c9                   	leave  
  800d87:	c3                   	ret    

00800d88 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d88:	f3 0f 1e fb          	endbr32 
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
  800d91:	8b 75 08             	mov    0x8(%ebp),%esi
  800d94:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d97:	89 f3                	mov    %esi,%ebx
  800d99:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d9c:	89 f0                	mov    %esi,%eax
  800d9e:	39 d8                	cmp    %ebx,%eax
  800da0:	74 11                	je     800db3 <strncpy+0x2b>
		*dst++ = *src;
  800da2:	83 c0 01             	add    $0x1,%eax
  800da5:	0f b6 0a             	movzbl (%edx),%ecx
  800da8:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800dab:	80 f9 01             	cmp    $0x1,%cl
  800dae:	83 da ff             	sbb    $0xffffffff,%edx
  800db1:	eb eb                	jmp    800d9e <strncpy+0x16>
	}
	return ret;
}
  800db3:	89 f0                	mov    %esi,%eax
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5d                   	pop    %ebp
  800db8:	c3                   	ret    

00800db9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800db9:	f3 0f 1e fb          	endbr32 
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	56                   	push   %esi
  800dc1:	53                   	push   %ebx
  800dc2:	8b 75 08             	mov    0x8(%ebp),%esi
  800dc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc8:	8b 55 10             	mov    0x10(%ebp),%edx
  800dcb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800dcd:	85 d2                	test   %edx,%edx
  800dcf:	74 21                	je     800df2 <strlcpy+0x39>
  800dd1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800dd5:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800dd7:	39 c2                	cmp    %eax,%edx
  800dd9:	74 14                	je     800def <strlcpy+0x36>
  800ddb:	0f b6 19             	movzbl (%ecx),%ebx
  800dde:	84 db                	test   %bl,%bl
  800de0:	74 0b                	je     800ded <strlcpy+0x34>
			*dst++ = *src++;
  800de2:	83 c1 01             	add    $0x1,%ecx
  800de5:	83 c2 01             	add    $0x1,%edx
  800de8:	88 5a ff             	mov    %bl,-0x1(%edx)
  800deb:	eb ea                	jmp    800dd7 <strlcpy+0x1e>
  800ded:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800def:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800df2:	29 f0                	sub    %esi,%eax
}
  800df4:	5b                   	pop    %ebx
  800df5:	5e                   	pop    %esi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    

00800df8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800df8:	f3 0f 1e fb          	endbr32 
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e02:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e05:	0f b6 01             	movzbl (%ecx),%eax
  800e08:	84 c0                	test   %al,%al
  800e0a:	74 0c                	je     800e18 <strcmp+0x20>
  800e0c:	3a 02                	cmp    (%edx),%al
  800e0e:	75 08                	jne    800e18 <strcmp+0x20>
		p++, q++;
  800e10:	83 c1 01             	add    $0x1,%ecx
  800e13:	83 c2 01             	add    $0x1,%edx
  800e16:	eb ed                	jmp    800e05 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e18:	0f b6 c0             	movzbl %al,%eax
  800e1b:	0f b6 12             	movzbl (%edx),%edx
  800e1e:	29 d0                	sub    %edx,%eax
}
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e22:	f3 0f 1e fb          	endbr32 
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	53                   	push   %ebx
  800e2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e30:	89 c3                	mov    %eax,%ebx
  800e32:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e35:	eb 06                	jmp    800e3d <strncmp+0x1b>
		n--, p++, q++;
  800e37:	83 c0 01             	add    $0x1,%eax
  800e3a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800e3d:	39 d8                	cmp    %ebx,%eax
  800e3f:	74 16                	je     800e57 <strncmp+0x35>
  800e41:	0f b6 08             	movzbl (%eax),%ecx
  800e44:	84 c9                	test   %cl,%cl
  800e46:	74 04                	je     800e4c <strncmp+0x2a>
  800e48:	3a 0a                	cmp    (%edx),%cl
  800e4a:	74 eb                	je     800e37 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e4c:	0f b6 00             	movzbl (%eax),%eax
  800e4f:	0f b6 12             	movzbl (%edx),%edx
  800e52:	29 d0                	sub    %edx,%eax
}
  800e54:	5b                   	pop    %ebx
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    
		return 0;
  800e57:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5c:	eb f6                	jmp    800e54 <strncmp+0x32>

00800e5e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e5e:	f3 0f 1e fb          	endbr32 
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	8b 45 08             	mov    0x8(%ebp),%eax
  800e68:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e6c:	0f b6 10             	movzbl (%eax),%edx
  800e6f:	84 d2                	test   %dl,%dl
  800e71:	74 09                	je     800e7c <strchr+0x1e>
		if (*s == c)
  800e73:	38 ca                	cmp    %cl,%dl
  800e75:	74 0a                	je     800e81 <strchr+0x23>
	for (; *s; s++)
  800e77:	83 c0 01             	add    $0x1,%eax
  800e7a:	eb f0                	jmp    800e6c <strchr+0xe>
			return (char *) s;
	return 0;
  800e7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e83:	f3 0f 1e fb          	endbr32 
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e91:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e94:	38 ca                	cmp    %cl,%dl
  800e96:	74 09                	je     800ea1 <strfind+0x1e>
  800e98:	84 d2                	test   %dl,%dl
  800e9a:	74 05                	je     800ea1 <strfind+0x1e>
	for (; *s; s++)
  800e9c:	83 c0 01             	add    $0x1,%eax
  800e9f:	eb f0                	jmp    800e91 <strfind+0xe>
			break;
	return (char *) s;
}
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ea3:	f3 0f 1e fb          	endbr32 
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	57                   	push   %edi
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
  800ead:	8b 7d 08             	mov    0x8(%ebp),%edi
  800eb0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800eb3:	85 c9                	test   %ecx,%ecx
  800eb5:	74 31                	je     800ee8 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800eb7:	89 f8                	mov    %edi,%eax
  800eb9:	09 c8                	or     %ecx,%eax
  800ebb:	a8 03                	test   $0x3,%al
  800ebd:	75 23                	jne    800ee2 <memset+0x3f>
		c &= 0xFF;
  800ebf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ec3:	89 d3                	mov    %edx,%ebx
  800ec5:	c1 e3 08             	shl    $0x8,%ebx
  800ec8:	89 d0                	mov    %edx,%eax
  800eca:	c1 e0 18             	shl    $0x18,%eax
  800ecd:	89 d6                	mov    %edx,%esi
  800ecf:	c1 e6 10             	shl    $0x10,%esi
  800ed2:	09 f0                	or     %esi,%eax
  800ed4:	09 c2                	or     %eax,%edx
  800ed6:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ed8:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800edb:	89 d0                	mov    %edx,%eax
  800edd:	fc                   	cld    
  800ede:	f3 ab                	rep stos %eax,%es:(%edi)
  800ee0:	eb 06                	jmp    800ee8 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ee2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee5:	fc                   	cld    
  800ee6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ee8:	89 f8                	mov    %edi,%eax
  800eea:	5b                   	pop    %ebx
  800eeb:	5e                   	pop    %esi
  800eec:	5f                   	pop    %edi
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    

00800eef <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800eef:	f3 0f 1e fb          	endbr32 
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	57                   	push   %edi
  800ef7:	56                   	push   %esi
  800ef8:	8b 45 08             	mov    0x8(%ebp),%eax
  800efb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800efe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f01:	39 c6                	cmp    %eax,%esi
  800f03:	73 32                	jae    800f37 <memmove+0x48>
  800f05:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f08:	39 c2                	cmp    %eax,%edx
  800f0a:	76 2b                	jbe    800f37 <memmove+0x48>
		s += n;
		d += n;
  800f0c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f0f:	89 fe                	mov    %edi,%esi
  800f11:	09 ce                	or     %ecx,%esi
  800f13:	09 d6                	or     %edx,%esi
  800f15:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f1b:	75 0e                	jne    800f2b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f1d:	83 ef 04             	sub    $0x4,%edi
  800f20:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f23:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800f26:	fd                   	std    
  800f27:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f29:	eb 09                	jmp    800f34 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f2b:	83 ef 01             	sub    $0x1,%edi
  800f2e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800f31:	fd                   	std    
  800f32:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f34:	fc                   	cld    
  800f35:	eb 1a                	jmp    800f51 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f37:	89 c2                	mov    %eax,%edx
  800f39:	09 ca                	or     %ecx,%edx
  800f3b:	09 f2                	or     %esi,%edx
  800f3d:	f6 c2 03             	test   $0x3,%dl
  800f40:	75 0a                	jne    800f4c <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f42:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800f45:	89 c7                	mov    %eax,%edi
  800f47:	fc                   	cld    
  800f48:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f4a:	eb 05                	jmp    800f51 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800f4c:	89 c7                	mov    %eax,%edi
  800f4e:	fc                   	cld    
  800f4f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f51:	5e                   	pop    %esi
  800f52:	5f                   	pop    %edi
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    

00800f55 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f55:	f3 0f 1e fb          	endbr32 
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f5f:	ff 75 10             	pushl  0x10(%ebp)
  800f62:	ff 75 0c             	pushl  0xc(%ebp)
  800f65:	ff 75 08             	pushl  0x8(%ebp)
  800f68:	e8 82 ff ff ff       	call   800eef <memmove>
}
  800f6d:	c9                   	leave  
  800f6e:	c3                   	ret    

00800f6f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f6f:	f3 0f 1e fb          	endbr32 
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	56                   	push   %esi
  800f77:	53                   	push   %ebx
  800f78:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7e:	89 c6                	mov    %eax,%esi
  800f80:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f83:	39 f0                	cmp    %esi,%eax
  800f85:	74 1c                	je     800fa3 <memcmp+0x34>
		if (*s1 != *s2)
  800f87:	0f b6 08             	movzbl (%eax),%ecx
  800f8a:	0f b6 1a             	movzbl (%edx),%ebx
  800f8d:	38 d9                	cmp    %bl,%cl
  800f8f:	75 08                	jne    800f99 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800f91:	83 c0 01             	add    $0x1,%eax
  800f94:	83 c2 01             	add    $0x1,%edx
  800f97:	eb ea                	jmp    800f83 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800f99:	0f b6 c1             	movzbl %cl,%eax
  800f9c:	0f b6 db             	movzbl %bl,%ebx
  800f9f:	29 d8                	sub    %ebx,%eax
  800fa1:	eb 05                	jmp    800fa8 <memcmp+0x39>
	}

	return 0;
  800fa3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fa8:	5b                   	pop    %ebx
  800fa9:	5e                   	pop    %esi
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fac:	f3 0f 1e fb          	endbr32 
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800fb9:	89 c2                	mov    %eax,%edx
  800fbb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800fbe:	39 d0                	cmp    %edx,%eax
  800fc0:	73 09                	jae    800fcb <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fc2:	38 08                	cmp    %cl,(%eax)
  800fc4:	74 05                	je     800fcb <memfind+0x1f>
	for (; s < ends; s++)
  800fc6:	83 c0 01             	add    $0x1,%eax
  800fc9:	eb f3                	jmp    800fbe <memfind+0x12>
			break;
	return (void *) s;
}
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    

00800fcd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fcd:	f3 0f 1e fb          	endbr32 
  800fd1:	55                   	push   %ebp
  800fd2:	89 e5                	mov    %esp,%ebp
  800fd4:	57                   	push   %edi
  800fd5:	56                   	push   %esi
  800fd6:	53                   	push   %ebx
  800fd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fda:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fdd:	eb 03                	jmp    800fe2 <strtol+0x15>
		s++;
  800fdf:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800fe2:	0f b6 01             	movzbl (%ecx),%eax
  800fe5:	3c 20                	cmp    $0x20,%al
  800fe7:	74 f6                	je     800fdf <strtol+0x12>
  800fe9:	3c 09                	cmp    $0x9,%al
  800feb:	74 f2                	je     800fdf <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800fed:	3c 2b                	cmp    $0x2b,%al
  800fef:	74 2a                	je     80101b <strtol+0x4e>
	int neg = 0;
  800ff1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ff6:	3c 2d                	cmp    $0x2d,%al
  800ff8:	74 2b                	je     801025 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ffa:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801000:	75 0f                	jne    801011 <strtol+0x44>
  801002:	80 39 30             	cmpb   $0x30,(%ecx)
  801005:	74 28                	je     80102f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801007:	85 db                	test   %ebx,%ebx
  801009:	b8 0a 00 00 00       	mov    $0xa,%eax
  80100e:	0f 44 d8             	cmove  %eax,%ebx
  801011:	b8 00 00 00 00       	mov    $0x0,%eax
  801016:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801019:	eb 46                	jmp    801061 <strtol+0x94>
		s++;
  80101b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  80101e:	bf 00 00 00 00       	mov    $0x0,%edi
  801023:	eb d5                	jmp    800ffa <strtol+0x2d>
		s++, neg = 1;
  801025:	83 c1 01             	add    $0x1,%ecx
  801028:	bf 01 00 00 00       	mov    $0x1,%edi
  80102d:	eb cb                	jmp    800ffa <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80102f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801033:	74 0e                	je     801043 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801035:	85 db                	test   %ebx,%ebx
  801037:	75 d8                	jne    801011 <strtol+0x44>
		s++, base = 8;
  801039:	83 c1 01             	add    $0x1,%ecx
  80103c:	bb 08 00 00 00       	mov    $0x8,%ebx
  801041:	eb ce                	jmp    801011 <strtol+0x44>
		s += 2, base = 16;
  801043:	83 c1 02             	add    $0x2,%ecx
  801046:	bb 10 00 00 00       	mov    $0x10,%ebx
  80104b:	eb c4                	jmp    801011 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  80104d:	0f be d2             	movsbl %dl,%edx
  801050:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801053:	3b 55 10             	cmp    0x10(%ebp),%edx
  801056:	7d 3a                	jge    801092 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801058:	83 c1 01             	add    $0x1,%ecx
  80105b:	0f af 45 10          	imul   0x10(%ebp),%eax
  80105f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801061:	0f b6 11             	movzbl (%ecx),%edx
  801064:	8d 72 d0             	lea    -0x30(%edx),%esi
  801067:	89 f3                	mov    %esi,%ebx
  801069:	80 fb 09             	cmp    $0x9,%bl
  80106c:	76 df                	jbe    80104d <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  80106e:	8d 72 9f             	lea    -0x61(%edx),%esi
  801071:	89 f3                	mov    %esi,%ebx
  801073:	80 fb 19             	cmp    $0x19,%bl
  801076:	77 08                	ja     801080 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801078:	0f be d2             	movsbl %dl,%edx
  80107b:	83 ea 57             	sub    $0x57,%edx
  80107e:	eb d3                	jmp    801053 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801080:	8d 72 bf             	lea    -0x41(%edx),%esi
  801083:	89 f3                	mov    %esi,%ebx
  801085:	80 fb 19             	cmp    $0x19,%bl
  801088:	77 08                	ja     801092 <strtol+0xc5>
			dig = *s - 'A' + 10;
  80108a:	0f be d2             	movsbl %dl,%edx
  80108d:	83 ea 37             	sub    $0x37,%edx
  801090:	eb c1                	jmp    801053 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801092:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801096:	74 05                	je     80109d <strtol+0xd0>
		*endptr = (char *) s;
  801098:	8b 75 0c             	mov    0xc(%ebp),%esi
  80109b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  80109d:	89 c2                	mov    %eax,%edx
  80109f:	f7 da                	neg    %edx
  8010a1:	85 ff                	test   %edi,%edi
  8010a3:	0f 45 c2             	cmovne %edx,%eax
}
  8010a6:	5b                   	pop    %ebx
  8010a7:	5e                   	pop    %esi
  8010a8:	5f                   	pop    %edi
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    

008010ab <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010ab:	f3 0f 1e fb          	endbr32 
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	57                   	push   %edi
  8010b3:	56                   	push   %esi
  8010b4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c0:	89 c3                	mov    %eax,%ebx
  8010c2:	89 c7                	mov    %eax,%edi
  8010c4:	89 c6                	mov    %eax,%esi
  8010c6:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8010c8:	5b                   	pop    %ebx
  8010c9:	5e                   	pop    %esi
  8010ca:	5f                   	pop    %edi
  8010cb:	5d                   	pop    %ebp
  8010cc:	c3                   	ret    

008010cd <sys_cgetc>:

int
sys_cgetc(void)
{
  8010cd:	f3 0f 1e fb          	endbr32 
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	57                   	push   %edi
  8010d5:	56                   	push   %esi
  8010d6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8010dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e1:	89 d1                	mov    %edx,%ecx
  8010e3:	89 d3                	mov    %edx,%ebx
  8010e5:	89 d7                	mov    %edx,%edi
  8010e7:	89 d6                	mov    %edx,%esi
  8010e9:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010eb:	5b                   	pop    %ebx
  8010ec:	5e                   	pop    %esi
  8010ed:	5f                   	pop    %edi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010f0:	f3 0f 1e fb          	endbr32 
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	57                   	push   %edi
  8010f8:	56                   	push   %esi
  8010f9:	53                   	push   %ebx
  8010fa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  801102:	8b 55 08             	mov    0x8(%ebp),%edx
  801105:	b8 03 00 00 00       	mov    $0x3,%eax
  80110a:	89 cb                	mov    %ecx,%ebx
  80110c:	89 cf                	mov    %ecx,%edi
  80110e:	89 ce                	mov    %ecx,%esi
  801110:	cd 30                	int    $0x30
	if(check && ret > 0)
  801112:	85 c0                	test   %eax,%eax
  801114:	7f 08                	jg     80111e <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801116:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801119:	5b                   	pop    %ebx
  80111a:	5e                   	pop    %esi
  80111b:	5f                   	pop    %edi
  80111c:	5d                   	pop    %ebp
  80111d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80111e:	83 ec 0c             	sub    $0xc,%esp
  801121:	50                   	push   %eax
  801122:	6a 03                	push   $0x3
  801124:	68 e4 19 80 00       	push   $0x8019e4
  801129:	6a 23                	push   $0x23
  80112b:	68 01 1a 80 00       	push   $0x801a01
  801130:	e8 14 f5 ff ff       	call   800649 <_panic>

00801135 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801135:	f3 0f 1e fb          	endbr32 
  801139:	55                   	push   %ebp
  80113a:	89 e5                	mov    %esp,%ebp
  80113c:	57                   	push   %edi
  80113d:	56                   	push   %esi
  80113e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80113f:	ba 00 00 00 00       	mov    $0x0,%edx
  801144:	b8 02 00 00 00       	mov    $0x2,%eax
  801149:	89 d1                	mov    %edx,%ecx
  80114b:	89 d3                	mov    %edx,%ebx
  80114d:	89 d7                	mov    %edx,%edi
  80114f:	89 d6                	mov    %edx,%esi
  801151:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801153:	5b                   	pop    %ebx
  801154:	5e                   	pop    %esi
  801155:	5f                   	pop    %edi
  801156:	5d                   	pop    %ebp
  801157:	c3                   	ret    

00801158 <sys_yield>:

void
sys_yield(void)
{
  801158:	f3 0f 1e fb          	endbr32 
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	57                   	push   %edi
  801160:	56                   	push   %esi
  801161:	53                   	push   %ebx
	asm volatile("int %1\n"
  801162:	ba 00 00 00 00       	mov    $0x0,%edx
  801167:	b8 0a 00 00 00       	mov    $0xa,%eax
  80116c:	89 d1                	mov    %edx,%ecx
  80116e:	89 d3                	mov    %edx,%ebx
  801170:	89 d7                	mov    %edx,%edi
  801172:	89 d6                	mov    %edx,%esi
  801174:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801176:	5b                   	pop    %ebx
  801177:	5e                   	pop    %esi
  801178:	5f                   	pop    %edi
  801179:	5d                   	pop    %ebp
  80117a:	c3                   	ret    

0080117b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80117b:	f3 0f 1e fb          	endbr32 
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	57                   	push   %edi
  801183:	56                   	push   %esi
  801184:	53                   	push   %ebx
  801185:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801188:	be 00 00 00 00       	mov    $0x0,%esi
  80118d:	8b 55 08             	mov    0x8(%ebp),%edx
  801190:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801193:	b8 04 00 00 00       	mov    $0x4,%eax
  801198:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80119b:	89 f7                	mov    %esi,%edi
  80119d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	7f 08                	jg     8011ab <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a6:	5b                   	pop    %ebx
  8011a7:	5e                   	pop    %esi
  8011a8:	5f                   	pop    %edi
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ab:	83 ec 0c             	sub    $0xc,%esp
  8011ae:	50                   	push   %eax
  8011af:	6a 04                	push   $0x4
  8011b1:	68 e4 19 80 00       	push   $0x8019e4
  8011b6:	6a 23                	push   $0x23
  8011b8:	68 01 1a 80 00       	push   $0x801a01
  8011bd:	e8 87 f4 ff ff       	call   800649 <_panic>

008011c2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011c2:	f3 0f 1e fb          	endbr32 
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	57                   	push   %edi
  8011ca:	56                   	push   %esi
  8011cb:	53                   	push   %ebx
  8011cc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8011cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d5:	b8 05 00 00 00       	mov    $0x5,%eax
  8011da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011dd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011e0:	8b 75 18             	mov    0x18(%ebp),%esi
  8011e3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	7f 08                	jg     8011f1 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8011e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ec:	5b                   	pop    %ebx
  8011ed:	5e                   	pop    %esi
  8011ee:	5f                   	pop    %edi
  8011ef:	5d                   	pop    %ebp
  8011f0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011f1:	83 ec 0c             	sub    $0xc,%esp
  8011f4:	50                   	push   %eax
  8011f5:	6a 05                	push   $0x5
  8011f7:	68 e4 19 80 00       	push   $0x8019e4
  8011fc:	6a 23                	push   $0x23
  8011fe:	68 01 1a 80 00       	push   $0x801a01
  801203:	e8 41 f4 ff ff       	call   800649 <_panic>

00801208 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801208:	f3 0f 1e fb          	endbr32 
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	57                   	push   %edi
  801210:	56                   	push   %esi
  801211:	53                   	push   %ebx
  801212:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801215:	bb 00 00 00 00       	mov    $0x0,%ebx
  80121a:	8b 55 08             	mov    0x8(%ebp),%edx
  80121d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801220:	b8 06 00 00 00       	mov    $0x6,%eax
  801225:	89 df                	mov    %ebx,%edi
  801227:	89 de                	mov    %ebx,%esi
  801229:	cd 30                	int    $0x30
	if(check && ret > 0)
  80122b:	85 c0                	test   %eax,%eax
  80122d:	7f 08                	jg     801237 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80122f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801232:	5b                   	pop    %ebx
  801233:	5e                   	pop    %esi
  801234:	5f                   	pop    %edi
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801237:	83 ec 0c             	sub    $0xc,%esp
  80123a:	50                   	push   %eax
  80123b:	6a 06                	push   $0x6
  80123d:	68 e4 19 80 00       	push   $0x8019e4
  801242:	6a 23                	push   $0x23
  801244:	68 01 1a 80 00       	push   $0x801a01
  801249:	e8 fb f3 ff ff       	call   800649 <_panic>

0080124e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80124e:	f3 0f 1e fb          	endbr32 
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	57                   	push   %edi
  801256:	56                   	push   %esi
  801257:	53                   	push   %ebx
  801258:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80125b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801260:	8b 55 08             	mov    0x8(%ebp),%edx
  801263:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801266:	b8 08 00 00 00       	mov    $0x8,%eax
  80126b:	89 df                	mov    %ebx,%edi
  80126d:	89 de                	mov    %ebx,%esi
  80126f:	cd 30                	int    $0x30
	if(check && ret > 0)
  801271:	85 c0                	test   %eax,%eax
  801273:	7f 08                	jg     80127d <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801275:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801278:	5b                   	pop    %ebx
  801279:	5e                   	pop    %esi
  80127a:	5f                   	pop    %edi
  80127b:	5d                   	pop    %ebp
  80127c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80127d:	83 ec 0c             	sub    $0xc,%esp
  801280:	50                   	push   %eax
  801281:	6a 08                	push   $0x8
  801283:	68 e4 19 80 00       	push   $0x8019e4
  801288:	6a 23                	push   $0x23
  80128a:	68 01 1a 80 00       	push   $0x801a01
  80128f:	e8 b5 f3 ff ff       	call   800649 <_panic>

00801294 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801294:	f3 0f 1e fb          	endbr32 
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	57                   	push   %edi
  80129c:	56                   	push   %esi
  80129d:	53                   	push   %ebx
  80129e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ac:	b8 09 00 00 00       	mov    $0x9,%eax
  8012b1:	89 df                	mov    %ebx,%edi
  8012b3:	89 de                	mov    %ebx,%esi
  8012b5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	7f 08                	jg     8012c3 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012be:	5b                   	pop    %ebx
  8012bf:	5e                   	pop    %esi
  8012c0:	5f                   	pop    %edi
  8012c1:	5d                   	pop    %ebp
  8012c2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8012c3:	83 ec 0c             	sub    $0xc,%esp
  8012c6:	50                   	push   %eax
  8012c7:	6a 09                	push   $0x9
  8012c9:	68 e4 19 80 00       	push   $0x8019e4
  8012ce:	6a 23                	push   $0x23
  8012d0:	68 01 1a 80 00       	push   $0x801a01
  8012d5:	e8 6f f3 ff ff       	call   800649 <_panic>

008012da <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8012da:	f3 0f 1e fb          	endbr32 
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	57                   	push   %edi
  8012e2:	56                   	push   %esi
  8012e3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8012e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ea:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012ef:	be 00 00 00 00       	mov    $0x0,%esi
  8012f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012f7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012fa:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012fc:	5b                   	pop    %ebx
  8012fd:	5e                   	pop    %esi
  8012fe:	5f                   	pop    %edi
  8012ff:	5d                   	pop    %ebp
  801300:	c3                   	ret    

00801301 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801301:	f3 0f 1e fb          	endbr32 
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	57                   	push   %edi
  801309:	56                   	push   %esi
  80130a:	53                   	push   %ebx
  80130b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80130e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801313:	8b 55 08             	mov    0x8(%ebp),%edx
  801316:	b8 0c 00 00 00       	mov    $0xc,%eax
  80131b:	89 cb                	mov    %ecx,%ebx
  80131d:	89 cf                	mov    %ecx,%edi
  80131f:	89 ce                	mov    %ecx,%esi
  801321:	cd 30                	int    $0x30
	if(check && ret > 0)
  801323:	85 c0                	test   %eax,%eax
  801325:	7f 08                	jg     80132f <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801327:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80132a:	5b                   	pop    %ebx
  80132b:	5e                   	pop    %esi
  80132c:	5f                   	pop    %edi
  80132d:	5d                   	pop    %ebp
  80132e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80132f:	83 ec 0c             	sub    $0xc,%esp
  801332:	50                   	push   %eax
  801333:	6a 0c                	push   $0xc
  801335:	68 e4 19 80 00       	push   $0x8019e4
  80133a:	6a 23                	push   $0x23
  80133c:	68 01 1a 80 00       	push   $0x801a01
  801341:	e8 03 f3 ff ff       	call   800649 <_panic>

00801346 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801346:	f3 0f 1e fb          	endbr32 
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801350:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  801357:	74 0a                	je     801363 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801359:	8b 45 08             	mov    0x8(%ebp),%eax
  80135c:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  801361:	c9                   	leave  
  801362:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801363:	83 ec 0c             	sub    $0xc,%esp
  801366:	68 0f 1a 80 00       	push   $0x801a0f
  80136b:	e8 c0 f3 ff ff       	call   800730 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  801370:	83 c4 0c             	add    $0xc,%esp
  801373:	6a 07                	push   $0x7
  801375:	68 00 f0 bf ee       	push   $0xeebff000
  80137a:	6a 00                	push   $0x0
  80137c:	e8 fa fd ff ff       	call   80117b <sys_page_alloc>
  801381:	83 c4 10             	add    $0x10,%esp
  801384:	85 c0                	test   %eax,%eax
  801386:	78 2a                	js     8013b2 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	68 c6 13 80 00       	push   $0x8013c6
  801390:	6a 00                	push   $0x0
  801392:	e8 fd fe ff ff       	call   801294 <sys_env_set_pgfault_upcall>
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	85 c0                	test   %eax,%eax
  80139c:	79 bb                	jns    801359 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  80139e:	83 ec 04             	sub    $0x4,%esp
  8013a1:	68 4c 1a 80 00       	push   $0x801a4c
  8013a6:	6a 25                	push   $0x25
  8013a8:	68 3c 1a 80 00       	push   $0x801a3c
  8013ad:	e8 97 f2 ff ff       	call   800649 <_panic>
            panic("Allocation of UXSTACK failed!");
  8013b2:	83 ec 04             	sub    $0x4,%esp
  8013b5:	68 1e 1a 80 00       	push   $0x801a1e
  8013ba:	6a 22                	push   $0x22
  8013bc:	68 3c 1a 80 00       	push   $0x801a3c
  8013c1:	e8 83 f2 ff ff       	call   800649 <_panic>

008013c6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8013c6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8013c7:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  8013cc:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8013ce:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  8013d1:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  8013d5:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  8013d9:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  8013dc:	83 c4 08             	add    $0x8,%esp
    popa
  8013df:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $0x4, %esp
  8013e0:	83 c4 04             	add    $0x4,%esp
    popf
  8013e3:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  8013e4:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  8013e7:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  8013eb:	c3                   	ret    
  8013ec:	66 90                	xchg   %ax,%ax
  8013ee:	66 90                	xchg   %ax,%ax

008013f0 <__udivdi3>:
  8013f0:	f3 0f 1e fb          	endbr32 
  8013f4:	55                   	push   %ebp
  8013f5:	57                   	push   %edi
  8013f6:	56                   	push   %esi
  8013f7:	53                   	push   %ebx
  8013f8:	83 ec 1c             	sub    $0x1c,%esp
  8013fb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8013ff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801403:	8b 74 24 34          	mov    0x34(%esp),%esi
  801407:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80140b:	85 d2                	test   %edx,%edx
  80140d:	75 19                	jne    801428 <__udivdi3+0x38>
  80140f:	39 f3                	cmp    %esi,%ebx
  801411:	76 4d                	jbe    801460 <__udivdi3+0x70>
  801413:	31 ff                	xor    %edi,%edi
  801415:	89 e8                	mov    %ebp,%eax
  801417:	89 f2                	mov    %esi,%edx
  801419:	f7 f3                	div    %ebx
  80141b:	89 fa                	mov    %edi,%edx
  80141d:	83 c4 1c             	add    $0x1c,%esp
  801420:	5b                   	pop    %ebx
  801421:	5e                   	pop    %esi
  801422:	5f                   	pop    %edi
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    
  801425:	8d 76 00             	lea    0x0(%esi),%esi
  801428:	39 f2                	cmp    %esi,%edx
  80142a:	76 14                	jbe    801440 <__udivdi3+0x50>
  80142c:	31 ff                	xor    %edi,%edi
  80142e:	31 c0                	xor    %eax,%eax
  801430:	89 fa                	mov    %edi,%edx
  801432:	83 c4 1c             	add    $0x1c,%esp
  801435:	5b                   	pop    %ebx
  801436:	5e                   	pop    %esi
  801437:	5f                   	pop    %edi
  801438:	5d                   	pop    %ebp
  801439:	c3                   	ret    
  80143a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801440:	0f bd fa             	bsr    %edx,%edi
  801443:	83 f7 1f             	xor    $0x1f,%edi
  801446:	75 48                	jne    801490 <__udivdi3+0xa0>
  801448:	39 f2                	cmp    %esi,%edx
  80144a:	72 06                	jb     801452 <__udivdi3+0x62>
  80144c:	31 c0                	xor    %eax,%eax
  80144e:	39 eb                	cmp    %ebp,%ebx
  801450:	77 de                	ja     801430 <__udivdi3+0x40>
  801452:	b8 01 00 00 00       	mov    $0x1,%eax
  801457:	eb d7                	jmp    801430 <__udivdi3+0x40>
  801459:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801460:	89 d9                	mov    %ebx,%ecx
  801462:	85 db                	test   %ebx,%ebx
  801464:	75 0b                	jne    801471 <__udivdi3+0x81>
  801466:	b8 01 00 00 00       	mov    $0x1,%eax
  80146b:	31 d2                	xor    %edx,%edx
  80146d:	f7 f3                	div    %ebx
  80146f:	89 c1                	mov    %eax,%ecx
  801471:	31 d2                	xor    %edx,%edx
  801473:	89 f0                	mov    %esi,%eax
  801475:	f7 f1                	div    %ecx
  801477:	89 c6                	mov    %eax,%esi
  801479:	89 e8                	mov    %ebp,%eax
  80147b:	89 f7                	mov    %esi,%edi
  80147d:	f7 f1                	div    %ecx
  80147f:	89 fa                	mov    %edi,%edx
  801481:	83 c4 1c             	add    $0x1c,%esp
  801484:	5b                   	pop    %ebx
  801485:	5e                   	pop    %esi
  801486:	5f                   	pop    %edi
  801487:	5d                   	pop    %ebp
  801488:	c3                   	ret    
  801489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801490:	89 f9                	mov    %edi,%ecx
  801492:	b8 20 00 00 00       	mov    $0x20,%eax
  801497:	29 f8                	sub    %edi,%eax
  801499:	d3 e2                	shl    %cl,%edx
  80149b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80149f:	89 c1                	mov    %eax,%ecx
  8014a1:	89 da                	mov    %ebx,%edx
  8014a3:	d3 ea                	shr    %cl,%edx
  8014a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8014a9:	09 d1                	or     %edx,%ecx
  8014ab:	89 f2                	mov    %esi,%edx
  8014ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014b1:	89 f9                	mov    %edi,%ecx
  8014b3:	d3 e3                	shl    %cl,%ebx
  8014b5:	89 c1                	mov    %eax,%ecx
  8014b7:	d3 ea                	shr    %cl,%edx
  8014b9:	89 f9                	mov    %edi,%ecx
  8014bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8014bf:	89 eb                	mov    %ebp,%ebx
  8014c1:	d3 e6                	shl    %cl,%esi
  8014c3:	89 c1                	mov    %eax,%ecx
  8014c5:	d3 eb                	shr    %cl,%ebx
  8014c7:	09 de                	or     %ebx,%esi
  8014c9:	89 f0                	mov    %esi,%eax
  8014cb:	f7 74 24 08          	divl   0x8(%esp)
  8014cf:	89 d6                	mov    %edx,%esi
  8014d1:	89 c3                	mov    %eax,%ebx
  8014d3:	f7 64 24 0c          	mull   0xc(%esp)
  8014d7:	39 d6                	cmp    %edx,%esi
  8014d9:	72 15                	jb     8014f0 <__udivdi3+0x100>
  8014db:	89 f9                	mov    %edi,%ecx
  8014dd:	d3 e5                	shl    %cl,%ebp
  8014df:	39 c5                	cmp    %eax,%ebp
  8014e1:	73 04                	jae    8014e7 <__udivdi3+0xf7>
  8014e3:	39 d6                	cmp    %edx,%esi
  8014e5:	74 09                	je     8014f0 <__udivdi3+0x100>
  8014e7:	89 d8                	mov    %ebx,%eax
  8014e9:	31 ff                	xor    %edi,%edi
  8014eb:	e9 40 ff ff ff       	jmp    801430 <__udivdi3+0x40>
  8014f0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8014f3:	31 ff                	xor    %edi,%edi
  8014f5:	e9 36 ff ff ff       	jmp    801430 <__udivdi3+0x40>
  8014fa:	66 90                	xchg   %ax,%ax
  8014fc:	66 90                	xchg   %ax,%ax
  8014fe:	66 90                	xchg   %ax,%ax

00801500 <__umoddi3>:
  801500:	f3 0f 1e fb          	endbr32 
  801504:	55                   	push   %ebp
  801505:	57                   	push   %edi
  801506:	56                   	push   %esi
  801507:	53                   	push   %ebx
  801508:	83 ec 1c             	sub    $0x1c,%esp
  80150b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80150f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801513:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801517:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80151b:	85 c0                	test   %eax,%eax
  80151d:	75 19                	jne    801538 <__umoddi3+0x38>
  80151f:	39 df                	cmp    %ebx,%edi
  801521:	76 5d                	jbe    801580 <__umoddi3+0x80>
  801523:	89 f0                	mov    %esi,%eax
  801525:	89 da                	mov    %ebx,%edx
  801527:	f7 f7                	div    %edi
  801529:	89 d0                	mov    %edx,%eax
  80152b:	31 d2                	xor    %edx,%edx
  80152d:	83 c4 1c             	add    $0x1c,%esp
  801530:	5b                   	pop    %ebx
  801531:	5e                   	pop    %esi
  801532:	5f                   	pop    %edi
  801533:	5d                   	pop    %ebp
  801534:	c3                   	ret    
  801535:	8d 76 00             	lea    0x0(%esi),%esi
  801538:	89 f2                	mov    %esi,%edx
  80153a:	39 d8                	cmp    %ebx,%eax
  80153c:	76 12                	jbe    801550 <__umoddi3+0x50>
  80153e:	89 f0                	mov    %esi,%eax
  801540:	89 da                	mov    %ebx,%edx
  801542:	83 c4 1c             	add    $0x1c,%esp
  801545:	5b                   	pop    %ebx
  801546:	5e                   	pop    %esi
  801547:	5f                   	pop    %edi
  801548:	5d                   	pop    %ebp
  801549:	c3                   	ret    
  80154a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801550:	0f bd e8             	bsr    %eax,%ebp
  801553:	83 f5 1f             	xor    $0x1f,%ebp
  801556:	75 50                	jne    8015a8 <__umoddi3+0xa8>
  801558:	39 d8                	cmp    %ebx,%eax
  80155a:	0f 82 e0 00 00 00    	jb     801640 <__umoddi3+0x140>
  801560:	89 d9                	mov    %ebx,%ecx
  801562:	39 f7                	cmp    %esi,%edi
  801564:	0f 86 d6 00 00 00    	jbe    801640 <__umoddi3+0x140>
  80156a:	89 d0                	mov    %edx,%eax
  80156c:	89 ca                	mov    %ecx,%edx
  80156e:	83 c4 1c             	add    $0x1c,%esp
  801571:	5b                   	pop    %ebx
  801572:	5e                   	pop    %esi
  801573:	5f                   	pop    %edi
  801574:	5d                   	pop    %ebp
  801575:	c3                   	ret    
  801576:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80157d:	8d 76 00             	lea    0x0(%esi),%esi
  801580:	89 fd                	mov    %edi,%ebp
  801582:	85 ff                	test   %edi,%edi
  801584:	75 0b                	jne    801591 <__umoddi3+0x91>
  801586:	b8 01 00 00 00       	mov    $0x1,%eax
  80158b:	31 d2                	xor    %edx,%edx
  80158d:	f7 f7                	div    %edi
  80158f:	89 c5                	mov    %eax,%ebp
  801591:	89 d8                	mov    %ebx,%eax
  801593:	31 d2                	xor    %edx,%edx
  801595:	f7 f5                	div    %ebp
  801597:	89 f0                	mov    %esi,%eax
  801599:	f7 f5                	div    %ebp
  80159b:	89 d0                	mov    %edx,%eax
  80159d:	31 d2                	xor    %edx,%edx
  80159f:	eb 8c                	jmp    80152d <__umoddi3+0x2d>
  8015a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8015a8:	89 e9                	mov    %ebp,%ecx
  8015aa:	ba 20 00 00 00       	mov    $0x20,%edx
  8015af:	29 ea                	sub    %ebp,%edx
  8015b1:	d3 e0                	shl    %cl,%eax
  8015b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015b7:	89 d1                	mov    %edx,%ecx
  8015b9:	89 f8                	mov    %edi,%eax
  8015bb:	d3 e8                	shr    %cl,%eax
  8015bd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8015c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015c5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8015c9:	09 c1                	or     %eax,%ecx
  8015cb:	89 d8                	mov    %ebx,%eax
  8015cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015d1:	89 e9                	mov    %ebp,%ecx
  8015d3:	d3 e7                	shl    %cl,%edi
  8015d5:	89 d1                	mov    %edx,%ecx
  8015d7:	d3 e8                	shr    %cl,%eax
  8015d9:	89 e9                	mov    %ebp,%ecx
  8015db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015df:	d3 e3                	shl    %cl,%ebx
  8015e1:	89 c7                	mov    %eax,%edi
  8015e3:	89 d1                	mov    %edx,%ecx
  8015e5:	89 f0                	mov    %esi,%eax
  8015e7:	d3 e8                	shr    %cl,%eax
  8015e9:	89 e9                	mov    %ebp,%ecx
  8015eb:	89 fa                	mov    %edi,%edx
  8015ed:	d3 e6                	shl    %cl,%esi
  8015ef:	09 d8                	or     %ebx,%eax
  8015f1:	f7 74 24 08          	divl   0x8(%esp)
  8015f5:	89 d1                	mov    %edx,%ecx
  8015f7:	89 f3                	mov    %esi,%ebx
  8015f9:	f7 64 24 0c          	mull   0xc(%esp)
  8015fd:	89 c6                	mov    %eax,%esi
  8015ff:	89 d7                	mov    %edx,%edi
  801601:	39 d1                	cmp    %edx,%ecx
  801603:	72 06                	jb     80160b <__umoddi3+0x10b>
  801605:	75 10                	jne    801617 <__umoddi3+0x117>
  801607:	39 c3                	cmp    %eax,%ebx
  801609:	73 0c                	jae    801617 <__umoddi3+0x117>
  80160b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80160f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801613:	89 d7                	mov    %edx,%edi
  801615:	89 c6                	mov    %eax,%esi
  801617:	89 ca                	mov    %ecx,%edx
  801619:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80161e:	29 f3                	sub    %esi,%ebx
  801620:	19 fa                	sbb    %edi,%edx
  801622:	89 d0                	mov    %edx,%eax
  801624:	d3 e0                	shl    %cl,%eax
  801626:	89 e9                	mov    %ebp,%ecx
  801628:	d3 eb                	shr    %cl,%ebx
  80162a:	d3 ea                	shr    %cl,%edx
  80162c:	09 d8                	or     %ebx,%eax
  80162e:	83 c4 1c             	add    $0x1c,%esp
  801631:	5b                   	pop    %ebx
  801632:	5e                   	pop    %esi
  801633:	5f                   	pop    %edi
  801634:	5d                   	pop    %ebp
  801635:	c3                   	ret    
  801636:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80163d:	8d 76 00             	lea    0x0(%esi),%esi
  801640:	29 fe                	sub    %edi,%esi
  801642:	19 c3                	sbb    %eax,%ebx
  801644:	89 f2                	mov    %esi,%edx
  801646:	89 d9                	mov    %ebx,%ecx
  801648:	e9 1d ff ff ff       	jmp    80156a <__umoddi3+0x6a>
