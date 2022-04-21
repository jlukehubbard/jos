
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
  800044:	68 31 25 80 00       	push   $0x802531
  800049:	68 00 25 80 00       	push   $0x802500
  80004e:	e8 ef 06 00 00       	call   800742 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 10 25 80 00       	push   $0x802510
  80005c:	68 14 25 80 00       	push   $0x802514
  800061:	e8 dc 06 00 00       	call   800742 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	0f 84 2e 02 00 00    	je     8002a1 <check_regs+0x26e>
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	68 28 25 80 00       	push   $0x802528
  80007b:	e8 c2 06 00 00       	call   800742 <cprintf>
  800080:	83 c4 10             	add    $0x10,%esp
  800083:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  800088:	ff 73 04             	pushl  0x4(%ebx)
  80008b:	ff 76 04             	pushl  0x4(%esi)
  80008e:	68 32 25 80 00       	push   $0x802532
  800093:	68 14 25 80 00       	push   $0x802514
  800098:	e8 a5 06 00 00       	call   800742 <cprintf>
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8000a3:	39 46 04             	cmp    %eax,0x4(%esi)
  8000a6:	0f 84 0f 02 00 00    	je     8002bb <check_regs+0x288>
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 28 25 80 00       	push   $0x802528
  8000b4:	e8 89 06 00 00       	call   800742 <cprintf>
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000c1:	ff 73 08             	pushl  0x8(%ebx)
  8000c4:	ff 76 08             	pushl  0x8(%esi)
  8000c7:	68 36 25 80 00       	push   $0x802536
  8000cc:	68 14 25 80 00       	push   $0x802514
  8000d1:	e8 6c 06 00 00       	call   800742 <cprintf>
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8b 43 08             	mov    0x8(%ebx),%eax
  8000dc:	39 46 08             	cmp    %eax,0x8(%esi)
  8000df:	0f 84 eb 01 00 00    	je     8002d0 <check_regs+0x29d>
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	68 28 25 80 00       	push   $0x802528
  8000ed:	e8 50 06 00 00       	call   800742 <cprintf>
  8000f2:	83 c4 10             	add    $0x10,%esp
  8000f5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  8000fa:	ff 73 10             	pushl  0x10(%ebx)
  8000fd:	ff 76 10             	pushl  0x10(%esi)
  800100:	68 3a 25 80 00       	push   $0x80253a
  800105:	68 14 25 80 00       	push   $0x802514
  80010a:	e8 33 06 00 00       	call   800742 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	8b 43 10             	mov    0x10(%ebx),%eax
  800115:	39 46 10             	cmp    %eax,0x10(%esi)
  800118:	0f 84 c7 01 00 00    	je     8002e5 <check_regs+0x2b2>
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	68 28 25 80 00       	push   $0x802528
  800126:	e8 17 06 00 00       	call   800742 <cprintf>
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800133:	ff 73 14             	pushl  0x14(%ebx)
  800136:	ff 76 14             	pushl  0x14(%esi)
  800139:	68 3e 25 80 00       	push   $0x80253e
  80013e:	68 14 25 80 00       	push   $0x802514
  800143:	e8 fa 05 00 00       	call   800742 <cprintf>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	8b 43 14             	mov    0x14(%ebx),%eax
  80014e:	39 46 14             	cmp    %eax,0x14(%esi)
  800151:	0f 84 a3 01 00 00    	je     8002fa <check_regs+0x2c7>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	68 28 25 80 00       	push   $0x802528
  80015f:	e8 de 05 00 00       	call   800742 <cprintf>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  80016c:	ff 73 18             	pushl  0x18(%ebx)
  80016f:	ff 76 18             	pushl  0x18(%esi)
  800172:	68 42 25 80 00       	push   $0x802542
  800177:	68 14 25 80 00       	push   $0x802514
  80017c:	e8 c1 05 00 00       	call   800742 <cprintf>
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	8b 43 18             	mov    0x18(%ebx),%eax
  800187:	39 46 18             	cmp    %eax,0x18(%esi)
  80018a:	0f 84 7f 01 00 00    	je     80030f <check_regs+0x2dc>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 28 25 80 00       	push   $0x802528
  800198:	e8 a5 05 00 00       	call   800742 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001a5:	ff 73 1c             	pushl  0x1c(%ebx)
  8001a8:	ff 76 1c             	pushl  0x1c(%esi)
  8001ab:	68 46 25 80 00       	push   $0x802546
  8001b0:	68 14 25 80 00       	push   $0x802514
  8001b5:	e8 88 05 00 00       	call   800742 <cprintf>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	8b 43 1c             	mov    0x1c(%ebx),%eax
  8001c0:	39 46 1c             	cmp    %eax,0x1c(%esi)
  8001c3:	0f 84 5b 01 00 00    	je     800324 <check_regs+0x2f1>
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	68 28 25 80 00       	push   $0x802528
  8001d1:	e8 6c 05 00 00       	call   800742 <cprintf>
  8001d6:	83 c4 10             	add    $0x10,%esp
  8001d9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  8001de:	ff 73 20             	pushl  0x20(%ebx)
  8001e1:	ff 76 20             	pushl  0x20(%esi)
  8001e4:	68 4a 25 80 00       	push   $0x80254a
  8001e9:	68 14 25 80 00       	push   $0x802514
  8001ee:	e8 4f 05 00 00       	call   800742 <cprintf>
  8001f3:	83 c4 10             	add    $0x10,%esp
  8001f6:	8b 43 20             	mov    0x20(%ebx),%eax
  8001f9:	39 46 20             	cmp    %eax,0x20(%esi)
  8001fc:	0f 84 37 01 00 00    	je     800339 <check_regs+0x306>
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	68 28 25 80 00       	push   $0x802528
  80020a:	e8 33 05 00 00       	call   800742 <cprintf>
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  800217:	ff 73 24             	pushl  0x24(%ebx)
  80021a:	ff 76 24             	pushl  0x24(%esi)
  80021d:	68 4e 25 80 00       	push   $0x80254e
  800222:	68 14 25 80 00       	push   $0x802514
  800227:	e8 16 05 00 00       	call   800742 <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8b 43 24             	mov    0x24(%ebx),%eax
  800232:	39 46 24             	cmp    %eax,0x24(%esi)
  800235:	0f 84 13 01 00 00    	je     80034e <check_regs+0x31b>
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	68 28 25 80 00       	push   $0x802528
  800243:	e8 fa 04 00 00       	call   800742 <cprintf>
	CHECK(esp, esp);
  800248:	ff 73 28             	pushl  0x28(%ebx)
  80024b:	ff 76 28             	pushl  0x28(%esi)
  80024e:	68 55 25 80 00       	push   $0x802555
  800253:	68 14 25 80 00       	push   $0x802514
  800258:	e8 e5 04 00 00       	call   800742 <cprintf>
  80025d:	83 c4 20             	add    $0x20,%esp
  800260:	8b 43 28             	mov    0x28(%ebx),%eax
  800263:	39 46 28             	cmp    %eax,0x28(%esi)
  800266:	0f 84 53 01 00 00    	je     8003bf <check_regs+0x38c>
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	68 28 25 80 00       	push   $0x802528
  800274:	e8 c9 04 00 00       	call   800742 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800279:	83 c4 08             	add    $0x8,%esp
  80027c:	ff 75 0c             	pushl  0xc(%ebp)
  80027f:	68 59 25 80 00       	push   $0x802559
  800284:	e8 b9 04 00 00       	call   800742 <cprintf>
  800289:	83 c4 10             	add    $0x10,%esp
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	68 28 25 80 00       	push   $0x802528
  800294:	e8 a9 04 00 00       	call   800742 <cprintf>
  800299:	83 c4 10             	add    $0x10,%esp
}
  80029c:	e9 16 01 00 00       	jmp    8003b7 <check_regs+0x384>
	CHECK(edi, regs.reg_edi);
  8002a1:	83 ec 0c             	sub    $0xc,%esp
  8002a4:	68 24 25 80 00       	push   $0x802524
  8002a9:	e8 94 04 00 00       	call   800742 <cprintf>
  8002ae:	83 c4 10             	add    $0x10,%esp
	int mismatch = 0;
  8002b1:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b6:	e9 cd fd ff ff       	jmp    800088 <check_regs+0x55>
	CHECK(esi, regs.reg_esi);
  8002bb:	83 ec 0c             	sub    $0xc,%esp
  8002be:	68 24 25 80 00       	push   $0x802524
  8002c3:	e8 7a 04 00 00       	call   800742 <cprintf>
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	e9 f1 fd ff ff       	jmp    8000c1 <check_regs+0x8e>
	CHECK(ebp, regs.reg_ebp);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	68 24 25 80 00       	push   $0x802524
  8002d8:	e8 65 04 00 00       	call   800742 <cprintf>
  8002dd:	83 c4 10             	add    $0x10,%esp
  8002e0:	e9 15 fe ff ff       	jmp    8000fa <check_regs+0xc7>
	CHECK(ebx, regs.reg_ebx);
  8002e5:	83 ec 0c             	sub    $0xc,%esp
  8002e8:	68 24 25 80 00       	push   $0x802524
  8002ed:	e8 50 04 00 00       	call   800742 <cprintf>
  8002f2:	83 c4 10             	add    $0x10,%esp
  8002f5:	e9 39 fe ff ff       	jmp    800133 <check_regs+0x100>
	CHECK(edx, regs.reg_edx);
  8002fa:	83 ec 0c             	sub    $0xc,%esp
  8002fd:	68 24 25 80 00       	push   $0x802524
  800302:	e8 3b 04 00 00       	call   800742 <cprintf>
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	e9 5d fe ff ff       	jmp    80016c <check_regs+0x139>
	CHECK(ecx, regs.reg_ecx);
  80030f:	83 ec 0c             	sub    $0xc,%esp
  800312:	68 24 25 80 00       	push   $0x802524
  800317:	e8 26 04 00 00       	call   800742 <cprintf>
  80031c:	83 c4 10             	add    $0x10,%esp
  80031f:	e9 81 fe ff ff       	jmp    8001a5 <check_regs+0x172>
	CHECK(eax, regs.reg_eax);
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	68 24 25 80 00       	push   $0x802524
  80032c:	e8 11 04 00 00       	call   800742 <cprintf>
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	e9 a5 fe ff ff       	jmp    8001de <check_regs+0x1ab>
	CHECK(eip, eip);
  800339:	83 ec 0c             	sub    $0xc,%esp
  80033c:	68 24 25 80 00       	push   $0x802524
  800341:	e8 fc 03 00 00       	call   800742 <cprintf>
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	e9 c9 fe ff ff       	jmp    800217 <check_regs+0x1e4>
	CHECK(eflags, eflags);
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	68 24 25 80 00       	push   $0x802524
  800356:	e8 e7 03 00 00       	call   800742 <cprintf>
	CHECK(esp, esp);
  80035b:	ff 73 28             	pushl  0x28(%ebx)
  80035e:	ff 76 28             	pushl  0x28(%esi)
  800361:	68 55 25 80 00       	push   $0x802555
  800366:	68 14 25 80 00       	push   $0x802514
  80036b:	e8 d2 03 00 00       	call   800742 <cprintf>
  800370:	83 c4 20             	add    $0x20,%esp
  800373:	8b 43 28             	mov    0x28(%ebx),%eax
  800376:	39 46 28             	cmp    %eax,0x28(%esi)
  800379:	0f 85 ed fe ff ff    	jne    80026c <check_regs+0x239>
  80037f:	83 ec 0c             	sub    $0xc,%esp
  800382:	68 24 25 80 00       	push   $0x802524
  800387:	e8 b6 03 00 00       	call   800742 <cprintf>
	cprintf("Registers %s ", testname);
  80038c:	83 c4 08             	add    $0x8,%esp
  80038f:	ff 75 0c             	pushl  0xc(%ebp)
  800392:	68 59 25 80 00       	push   $0x802559
  800397:	e8 a6 03 00 00       	call   800742 <cprintf>
	if (!mismatch)
  80039c:	83 c4 10             	add    $0x10,%esp
  80039f:	85 ff                	test   %edi,%edi
  8003a1:	0f 85 e5 fe ff ff    	jne    80028c <check_regs+0x259>
		cprintf("OK\n");
  8003a7:	83 ec 0c             	sub    $0xc,%esp
  8003aa:	68 24 25 80 00       	push   $0x802524
  8003af:	e8 8e 03 00 00       	call   800742 <cprintf>
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
  8003c2:	68 24 25 80 00       	push   $0x802524
  8003c7:	e8 76 03 00 00       	call   800742 <cprintf>
	cprintf("Registers %s ", testname);
  8003cc:	83 c4 08             	add    $0x8,%esp
  8003cf:	ff 75 0c             	pushl  0xc(%ebp)
  8003d2:	68 59 25 80 00       	push   $0x802559
  8003d7:	e8 66 03 00 00       	call   800742 <cprintf>
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
  800402:	89 15 40 40 80 00    	mov    %edx,0x804040
  800408:	8b 50 0c             	mov    0xc(%eax),%edx
  80040b:	89 15 44 40 80 00    	mov    %edx,0x804044
  800411:	8b 50 10             	mov    0x10(%eax),%edx
  800414:	89 15 48 40 80 00    	mov    %edx,0x804048
  80041a:	8b 50 14             	mov    0x14(%eax),%edx
  80041d:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  800423:	8b 50 18             	mov    0x18(%eax),%edx
  800426:	89 15 50 40 80 00    	mov    %edx,0x804050
  80042c:	8b 50 1c             	mov    0x1c(%eax),%edx
  80042f:	89 15 54 40 80 00    	mov    %edx,0x804054
  800435:	8b 50 20             	mov    0x20(%eax),%edx
  800438:	89 15 58 40 80 00    	mov    %edx,0x804058
  80043e:	8b 50 24             	mov    0x24(%eax),%edx
  800441:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800447:	8b 50 28             	mov    0x28(%eax),%edx
  80044a:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags & ~FL_RF;
  800450:	8b 50 2c             	mov    0x2c(%eax),%edx
  800453:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800459:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  80045f:	8b 40 30             	mov    0x30(%eax),%eax
  800462:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	68 7f 25 80 00       	push   $0x80257f
  80046f:	68 8d 25 80 00       	push   $0x80258d
  800474:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800479:	ba 78 25 80 00       	mov    $0x802578,%edx
  80047e:	b8 80 40 80 00       	mov    $0x804080,%eax
  800483:	e8 ab fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800488:	83 c4 0c             	add    $0xc,%esp
  80048b:	6a 07                	push   $0x7
  80048d:	68 00 00 40 00       	push   $0x400000
  800492:	6a 00                	push   $0x0
  800494:	e8 f4 0c 00 00       	call   80118d <sys_page_alloc>
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
  8004a9:	68 c0 25 80 00       	push   $0x8025c0
  8004ae:	6a 50                	push   $0x50
  8004b0:	68 67 25 80 00       	push   $0x802567
  8004b5:	e8 a1 01 00 00       	call   80065b <_panic>
		panic("sys_page_alloc: %e", r);
  8004ba:	50                   	push   %eax
  8004bb:	68 94 25 80 00       	push   $0x802594
  8004c0:	6a 5c                	push   $0x5c
  8004c2:	68 67 25 80 00       	push   $0x802567
  8004c7:	e8 8f 01 00 00       	call   80065b <_panic>

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
  8004db:	e8 be 0e 00 00       	call   80139e <set_pgfault_handler>

	asm volatile(
  8004e0:	50                   	push   %eax
  8004e1:	9c                   	pushf  
  8004e2:	58                   	pop    %eax
  8004e3:	0d d5 08 00 00       	or     $0x8d5,%eax
  8004e8:	50                   	push   %eax
  8004e9:	9d                   	popf   
  8004ea:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  8004ef:	8d 05 2a 05 80 00    	lea    0x80052a,%eax
  8004f5:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004fa:	58                   	pop    %eax
  8004fb:	89 3d 80 40 80 00    	mov    %edi,0x804080
  800501:	89 35 84 40 80 00    	mov    %esi,0x804084
  800507:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  80050d:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  800513:	89 15 94 40 80 00    	mov    %edx,0x804094
  800519:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  80051f:	a3 9c 40 80 00       	mov    %eax,0x80409c
  800524:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  80052a:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  800531:	00 00 00 
  800534:	89 3d 00 40 80 00    	mov    %edi,0x804000
  80053a:	89 35 04 40 80 00    	mov    %esi,0x804004
  800540:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  800546:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  80054c:	89 15 14 40 80 00    	mov    %edx,0x804014
  800552:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  800558:	a3 1c 40 80 00       	mov    %eax,0x80401c
  80055d:	89 25 28 40 80 00    	mov    %esp,0x804028
  800563:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  800569:	8b 35 84 40 80 00    	mov    0x804084,%esi
  80056f:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  800575:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  80057b:	8b 15 94 40 80 00    	mov    0x804094,%edx
  800581:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  800587:	a1 9c 40 80 00       	mov    0x80409c,%eax
  80058c:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  800592:	50                   	push   %eax
  800593:	9c                   	pushf  
  800594:	58                   	pop    %eax
  800595:	a3 24 40 80 00       	mov    %eax,0x804024
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
  8005a7:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  8005ac:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	68 a7 25 80 00       	push   $0x8025a7
  8005b9:	68 b8 25 80 00       	push   $0x8025b8
  8005be:	b9 00 40 80 00       	mov    $0x804000,%ecx
  8005c3:	ba 78 25 80 00       	mov    $0x802578,%edx
  8005c8:	b8 80 40 80 00       	mov    $0x804080,%eax
  8005cd:	e8 61 fa ff ff       	call   800033 <check_regs>
}
  8005d2:	83 c4 10             	add    $0x10,%esp
  8005d5:	c9                   	leave  
  8005d6:	c3                   	ret    
		cprintf("EIP after page-fault MISMATCH\n");
  8005d7:	83 ec 0c             	sub    $0xc,%esp
  8005da:	68 f4 25 80 00       	push   $0x8025f4
  8005df:	e8 5e 01 00 00       	call   800742 <cprintf>
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
  8005f8:	c7 05 b0 40 80 00 00 	movl   $0x0,0x8040b0
  8005ff:	00 00 00 
    envid_t envid = sys_getenvid();
  800602:	e8 40 0b 00 00       	call   801147 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800607:	25 ff 03 00 00       	and    $0x3ff,%eax
  80060c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80060f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800614:	a3 b0 40 80 00       	mov    %eax,0x8040b0

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800619:	85 db                	test   %ebx,%ebx
  80061b:	7e 07                	jle    800624 <libmain+0x3b>
		binaryname = argv[0];
  80061d:	8b 06                	mov    (%esi),%eax
  80061f:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800644:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800647:	e8 e7 0f 00 00       	call   801633 <close_all>
	sys_env_destroy(0);
  80064c:	83 ec 0c             	sub    $0xc,%esp
  80064f:	6a 00                	push   $0x0
  800651:	e8 ac 0a 00 00       	call   801102 <sys_env_destroy>
}
  800656:	83 c4 10             	add    $0x10,%esp
  800659:	c9                   	leave  
  80065a:	c3                   	ret    

0080065b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80065b:	f3 0f 1e fb          	endbr32 
  80065f:	55                   	push   %ebp
  800660:	89 e5                	mov    %esp,%ebp
  800662:	56                   	push   %esi
  800663:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800664:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800667:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80066d:	e8 d5 0a 00 00       	call   801147 <sys_getenvid>
  800672:	83 ec 0c             	sub    $0xc,%esp
  800675:	ff 75 0c             	pushl  0xc(%ebp)
  800678:	ff 75 08             	pushl  0x8(%ebp)
  80067b:	56                   	push   %esi
  80067c:	50                   	push   %eax
  80067d:	68 20 26 80 00       	push   $0x802620
  800682:	e8 bb 00 00 00       	call   800742 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800687:	83 c4 18             	add    $0x18,%esp
  80068a:	53                   	push   %ebx
  80068b:	ff 75 10             	pushl  0x10(%ebp)
  80068e:	e8 5a 00 00 00       	call   8006ed <vcprintf>
	cprintf("\n");
  800693:	c7 04 24 30 25 80 00 	movl   $0x802530,(%esp)
  80069a:	e8 a3 00 00 00       	call   800742 <cprintf>
  80069f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006a2:	cc                   	int3   
  8006a3:	eb fd                	jmp    8006a2 <_panic+0x47>

008006a5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006a5:	f3 0f 1e fb          	endbr32 
  8006a9:	55                   	push   %ebp
  8006aa:	89 e5                	mov    %esp,%ebp
  8006ac:	53                   	push   %ebx
  8006ad:	83 ec 04             	sub    $0x4,%esp
  8006b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006b3:	8b 13                	mov    (%ebx),%edx
  8006b5:	8d 42 01             	lea    0x1(%edx),%eax
  8006b8:	89 03                	mov    %eax,(%ebx)
  8006ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006bd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006c1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006c6:	74 09                	je     8006d1 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8006c8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006cf:	c9                   	leave  
  8006d0:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8006d1:	83 ec 08             	sub    $0x8,%esp
  8006d4:	68 ff 00 00 00       	push   $0xff
  8006d9:	8d 43 08             	lea    0x8(%ebx),%eax
  8006dc:	50                   	push   %eax
  8006dd:	e8 db 09 00 00       	call   8010bd <sys_cputs>
		b->idx = 0;
  8006e2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006e8:	83 c4 10             	add    $0x10,%esp
  8006eb:	eb db                	jmp    8006c8 <putch+0x23>

008006ed <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006ed:	f3 0f 1e fb          	endbr32 
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006fa:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800701:	00 00 00 
	b.cnt = 0;
  800704:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80070b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80070e:	ff 75 0c             	pushl  0xc(%ebp)
  800711:	ff 75 08             	pushl  0x8(%ebp)
  800714:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80071a:	50                   	push   %eax
  80071b:	68 a5 06 80 00       	push   $0x8006a5
  800720:	e8 20 01 00 00       	call   800845 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800725:	83 c4 08             	add    $0x8,%esp
  800728:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80072e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800734:	50                   	push   %eax
  800735:	e8 83 09 00 00       	call   8010bd <sys_cputs>

	return b.cnt;
}
  80073a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800740:	c9                   	leave  
  800741:	c3                   	ret    

00800742 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800742:	f3 0f 1e fb          	endbr32 
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80074c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80074f:	50                   	push   %eax
  800750:	ff 75 08             	pushl  0x8(%ebp)
  800753:	e8 95 ff ff ff       	call   8006ed <vcprintf>
	va_end(ap);

	return cnt;
}
  800758:	c9                   	leave  
  800759:	c3                   	ret    

0080075a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	57                   	push   %edi
  80075e:	56                   	push   %esi
  80075f:	53                   	push   %ebx
  800760:	83 ec 1c             	sub    $0x1c,%esp
  800763:	89 c7                	mov    %eax,%edi
  800765:	89 d6                	mov    %edx,%esi
  800767:	8b 45 08             	mov    0x8(%ebp),%eax
  80076a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80076d:	89 d1                	mov    %edx,%ecx
  80076f:	89 c2                	mov    %eax,%edx
  800771:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800774:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800777:	8b 45 10             	mov    0x10(%ebp),%eax
  80077a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80077d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800780:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800787:	39 c2                	cmp    %eax,%edx
  800789:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80078c:	72 3e                	jb     8007cc <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80078e:	83 ec 0c             	sub    $0xc,%esp
  800791:	ff 75 18             	pushl  0x18(%ebp)
  800794:	83 eb 01             	sub    $0x1,%ebx
  800797:	53                   	push   %ebx
  800798:	50                   	push   %eax
  800799:	83 ec 08             	sub    $0x8,%esp
  80079c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80079f:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a2:	ff 75 dc             	pushl  -0x24(%ebp)
  8007a5:	ff 75 d8             	pushl  -0x28(%ebp)
  8007a8:	e8 f3 1a 00 00       	call   8022a0 <__udivdi3>
  8007ad:	83 c4 18             	add    $0x18,%esp
  8007b0:	52                   	push   %edx
  8007b1:	50                   	push   %eax
  8007b2:	89 f2                	mov    %esi,%edx
  8007b4:	89 f8                	mov    %edi,%eax
  8007b6:	e8 9f ff ff ff       	call   80075a <printnum>
  8007bb:	83 c4 20             	add    $0x20,%esp
  8007be:	eb 13                	jmp    8007d3 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007c0:	83 ec 08             	sub    $0x8,%esp
  8007c3:	56                   	push   %esi
  8007c4:	ff 75 18             	pushl  0x18(%ebp)
  8007c7:	ff d7                	call   *%edi
  8007c9:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8007cc:	83 eb 01             	sub    $0x1,%ebx
  8007cf:	85 db                	test   %ebx,%ebx
  8007d1:	7f ed                	jg     8007c0 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007d3:	83 ec 08             	sub    $0x8,%esp
  8007d6:	56                   	push   %esi
  8007d7:	83 ec 04             	sub    $0x4,%esp
  8007da:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007dd:	ff 75 e0             	pushl  -0x20(%ebp)
  8007e0:	ff 75 dc             	pushl  -0x24(%ebp)
  8007e3:	ff 75 d8             	pushl  -0x28(%ebp)
  8007e6:	e8 c5 1b 00 00       	call   8023b0 <__umoddi3>
  8007eb:	83 c4 14             	add    $0x14,%esp
  8007ee:	0f be 80 43 26 80 00 	movsbl 0x802643(%eax),%eax
  8007f5:	50                   	push   %eax
  8007f6:	ff d7                	call   *%edi
}
  8007f8:	83 c4 10             	add    $0x10,%esp
  8007fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007fe:	5b                   	pop    %ebx
  8007ff:	5e                   	pop    %esi
  800800:	5f                   	pop    %edi
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800803:	f3 0f 1e fb          	endbr32 
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80080d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800811:	8b 10                	mov    (%eax),%edx
  800813:	3b 50 04             	cmp    0x4(%eax),%edx
  800816:	73 0a                	jae    800822 <sprintputch+0x1f>
		*b->buf++ = ch;
  800818:	8d 4a 01             	lea    0x1(%edx),%ecx
  80081b:	89 08                	mov    %ecx,(%eax)
  80081d:	8b 45 08             	mov    0x8(%ebp),%eax
  800820:	88 02                	mov    %al,(%edx)
}
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <printfmt>:
{
  800824:	f3 0f 1e fb          	endbr32 
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80082e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800831:	50                   	push   %eax
  800832:	ff 75 10             	pushl  0x10(%ebp)
  800835:	ff 75 0c             	pushl  0xc(%ebp)
  800838:	ff 75 08             	pushl  0x8(%ebp)
  80083b:	e8 05 00 00 00       	call   800845 <vprintfmt>
}
  800840:	83 c4 10             	add    $0x10,%esp
  800843:	c9                   	leave  
  800844:	c3                   	ret    

00800845 <vprintfmt>:
{
  800845:	f3 0f 1e fb          	endbr32 
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	57                   	push   %edi
  80084d:	56                   	push   %esi
  80084e:	53                   	push   %ebx
  80084f:	83 ec 3c             	sub    $0x3c,%esp
  800852:	8b 75 08             	mov    0x8(%ebp),%esi
  800855:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800858:	8b 7d 10             	mov    0x10(%ebp),%edi
  80085b:	e9 4a 03 00 00       	jmp    800baa <vprintfmt+0x365>
		padc = ' ';
  800860:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800864:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80086b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800872:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800879:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80087e:	8d 47 01             	lea    0x1(%edi),%eax
  800881:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800884:	0f b6 17             	movzbl (%edi),%edx
  800887:	8d 42 dd             	lea    -0x23(%edx),%eax
  80088a:	3c 55                	cmp    $0x55,%al
  80088c:	0f 87 de 03 00 00    	ja     800c70 <vprintfmt+0x42b>
  800892:	0f b6 c0             	movzbl %al,%eax
  800895:	3e ff 24 85 80 27 80 	notrack jmp *0x802780(,%eax,4)
  80089c:	00 
  80089d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8008a0:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8008a4:	eb d8                	jmp    80087e <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8008a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008a9:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8008ad:	eb cf                	jmp    80087e <vprintfmt+0x39>
  8008af:	0f b6 d2             	movzbl %dl,%edx
  8008b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8008b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ba:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8008bd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8008c0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8008c4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8008c7:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8008ca:	83 f9 09             	cmp    $0x9,%ecx
  8008cd:	77 55                	ja     800924 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8008cf:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8008d2:	eb e9                	jmp    8008bd <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8008d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d7:	8b 00                	mov    (%eax),%eax
  8008d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008df:	8d 40 04             	lea    0x4(%eax),%eax
  8008e2:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8008e8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008ec:	79 90                	jns    80087e <vprintfmt+0x39>
				width = precision, precision = -1;
  8008ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008f4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8008fb:	eb 81                	jmp    80087e <vprintfmt+0x39>
  8008fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800900:	85 c0                	test   %eax,%eax
  800902:	ba 00 00 00 00       	mov    $0x0,%edx
  800907:	0f 49 d0             	cmovns %eax,%edx
  80090a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80090d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800910:	e9 69 ff ff ff       	jmp    80087e <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800915:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800918:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80091f:	e9 5a ff ff ff       	jmp    80087e <vprintfmt+0x39>
  800924:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800927:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80092a:	eb bc                	jmp    8008e8 <vprintfmt+0xa3>
			lflag++;
  80092c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80092f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800932:	e9 47 ff ff ff       	jmp    80087e <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800937:	8b 45 14             	mov    0x14(%ebp),%eax
  80093a:	8d 78 04             	lea    0x4(%eax),%edi
  80093d:	83 ec 08             	sub    $0x8,%esp
  800940:	53                   	push   %ebx
  800941:	ff 30                	pushl  (%eax)
  800943:	ff d6                	call   *%esi
			break;
  800945:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800948:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80094b:	e9 57 02 00 00       	jmp    800ba7 <vprintfmt+0x362>
			err = va_arg(ap, int);
  800950:	8b 45 14             	mov    0x14(%ebp),%eax
  800953:	8d 78 04             	lea    0x4(%eax),%edi
  800956:	8b 00                	mov    (%eax),%eax
  800958:	99                   	cltd   
  800959:	31 d0                	xor    %edx,%eax
  80095b:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80095d:	83 f8 0f             	cmp    $0xf,%eax
  800960:	7f 23                	jg     800985 <vprintfmt+0x140>
  800962:	8b 14 85 e0 28 80 00 	mov    0x8028e0(,%eax,4),%edx
  800969:	85 d2                	test   %edx,%edx
  80096b:	74 18                	je     800985 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80096d:	52                   	push   %edx
  80096e:	68 9a 2a 80 00       	push   $0x802a9a
  800973:	53                   	push   %ebx
  800974:	56                   	push   %esi
  800975:	e8 aa fe ff ff       	call   800824 <printfmt>
  80097a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80097d:	89 7d 14             	mov    %edi,0x14(%ebp)
  800980:	e9 22 02 00 00       	jmp    800ba7 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800985:	50                   	push   %eax
  800986:	68 5b 26 80 00       	push   $0x80265b
  80098b:	53                   	push   %ebx
  80098c:	56                   	push   %esi
  80098d:	e8 92 fe ff ff       	call   800824 <printfmt>
  800992:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800995:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800998:	e9 0a 02 00 00       	jmp    800ba7 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  80099d:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a0:	83 c0 04             	add    $0x4,%eax
  8009a3:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8009a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a9:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8009ab:	85 d2                	test   %edx,%edx
  8009ad:	b8 54 26 80 00       	mov    $0x802654,%eax
  8009b2:	0f 45 c2             	cmovne %edx,%eax
  8009b5:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8009b8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009bc:	7e 06                	jle    8009c4 <vprintfmt+0x17f>
  8009be:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8009c2:	75 0d                	jne    8009d1 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009c7:	89 c7                	mov    %eax,%edi
  8009c9:	03 45 e0             	add    -0x20(%ebp),%eax
  8009cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009cf:	eb 55                	jmp    800a26 <vprintfmt+0x1e1>
  8009d1:	83 ec 08             	sub    $0x8,%esp
  8009d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8009d7:	ff 75 cc             	pushl  -0x34(%ebp)
  8009da:	e8 45 03 00 00       	call   800d24 <strnlen>
  8009df:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8009e2:	29 c2                	sub    %eax,%edx
  8009e4:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8009e7:	83 c4 10             	add    $0x10,%esp
  8009ea:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8009ec:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8009f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8009f3:	85 ff                	test   %edi,%edi
  8009f5:	7e 11                	jle    800a08 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8009f7:	83 ec 08             	sub    $0x8,%esp
  8009fa:	53                   	push   %ebx
  8009fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8009fe:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800a00:	83 ef 01             	sub    $0x1,%edi
  800a03:	83 c4 10             	add    $0x10,%esp
  800a06:	eb eb                	jmp    8009f3 <vprintfmt+0x1ae>
  800a08:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800a0b:	85 d2                	test   %edx,%edx
  800a0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a12:	0f 49 c2             	cmovns %edx,%eax
  800a15:	29 c2                	sub    %eax,%edx
  800a17:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800a1a:	eb a8                	jmp    8009c4 <vprintfmt+0x17f>
					putch(ch, putdat);
  800a1c:	83 ec 08             	sub    $0x8,%esp
  800a1f:	53                   	push   %ebx
  800a20:	52                   	push   %edx
  800a21:	ff d6                	call   *%esi
  800a23:	83 c4 10             	add    $0x10,%esp
  800a26:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a29:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a2b:	83 c7 01             	add    $0x1,%edi
  800a2e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a32:	0f be d0             	movsbl %al,%edx
  800a35:	85 d2                	test   %edx,%edx
  800a37:	74 4b                	je     800a84 <vprintfmt+0x23f>
  800a39:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a3d:	78 06                	js     800a45 <vprintfmt+0x200>
  800a3f:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800a43:	78 1e                	js     800a63 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800a45:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800a49:	74 d1                	je     800a1c <vprintfmt+0x1d7>
  800a4b:	0f be c0             	movsbl %al,%eax
  800a4e:	83 e8 20             	sub    $0x20,%eax
  800a51:	83 f8 5e             	cmp    $0x5e,%eax
  800a54:	76 c6                	jbe    800a1c <vprintfmt+0x1d7>
					putch('?', putdat);
  800a56:	83 ec 08             	sub    $0x8,%esp
  800a59:	53                   	push   %ebx
  800a5a:	6a 3f                	push   $0x3f
  800a5c:	ff d6                	call   *%esi
  800a5e:	83 c4 10             	add    $0x10,%esp
  800a61:	eb c3                	jmp    800a26 <vprintfmt+0x1e1>
  800a63:	89 cf                	mov    %ecx,%edi
  800a65:	eb 0e                	jmp    800a75 <vprintfmt+0x230>
				putch(' ', putdat);
  800a67:	83 ec 08             	sub    $0x8,%esp
  800a6a:	53                   	push   %ebx
  800a6b:	6a 20                	push   $0x20
  800a6d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800a6f:	83 ef 01             	sub    $0x1,%edi
  800a72:	83 c4 10             	add    $0x10,%esp
  800a75:	85 ff                	test   %edi,%edi
  800a77:	7f ee                	jg     800a67 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800a79:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800a7c:	89 45 14             	mov    %eax,0x14(%ebp)
  800a7f:	e9 23 01 00 00       	jmp    800ba7 <vprintfmt+0x362>
  800a84:	89 cf                	mov    %ecx,%edi
  800a86:	eb ed                	jmp    800a75 <vprintfmt+0x230>
	if (lflag >= 2)
  800a88:	83 f9 01             	cmp    $0x1,%ecx
  800a8b:	7f 1b                	jg     800aa8 <vprintfmt+0x263>
	else if (lflag)
  800a8d:	85 c9                	test   %ecx,%ecx
  800a8f:	74 63                	je     800af4 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800a91:	8b 45 14             	mov    0x14(%ebp),%eax
  800a94:	8b 00                	mov    (%eax),%eax
  800a96:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a99:	99                   	cltd   
  800a9a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a9d:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa0:	8d 40 04             	lea    0x4(%eax),%eax
  800aa3:	89 45 14             	mov    %eax,0x14(%ebp)
  800aa6:	eb 17                	jmp    800abf <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800aa8:	8b 45 14             	mov    0x14(%ebp),%eax
  800aab:	8b 50 04             	mov    0x4(%eax),%edx
  800aae:	8b 00                	mov    (%eax),%eax
  800ab0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ab3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ab6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab9:	8d 40 08             	lea    0x8(%eax),%eax
  800abc:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800abf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ac2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800ac5:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800aca:	85 c9                	test   %ecx,%ecx
  800acc:	0f 89 bb 00 00 00    	jns    800b8d <vprintfmt+0x348>
				putch('-', putdat);
  800ad2:	83 ec 08             	sub    $0x8,%esp
  800ad5:	53                   	push   %ebx
  800ad6:	6a 2d                	push   $0x2d
  800ad8:	ff d6                	call   *%esi
				num = -(long long) num;
  800ada:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800add:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800ae0:	f7 da                	neg    %edx
  800ae2:	83 d1 00             	adc    $0x0,%ecx
  800ae5:	f7 d9                	neg    %ecx
  800ae7:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800aea:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aef:	e9 99 00 00 00       	jmp    800b8d <vprintfmt+0x348>
		return va_arg(*ap, int);
  800af4:	8b 45 14             	mov    0x14(%ebp),%eax
  800af7:	8b 00                	mov    (%eax),%eax
  800af9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800afc:	99                   	cltd   
  800afd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b00:	8b 45 14             	mov    0x14(%ebp),%eax
  800b03:	8d 40 04             	lea    0x4(%eax),%eax
  800b06:	89 45 14             	mov    %eax,0x14(%ebp)
  800b09:	eb b4                	jmp    800abf <vprintfmt+0x27a>
	if (lflag >= 2)
  800b0b:	83 f9 01             	cmp    $0x1,%ecx
  800b0e:	7f 1b                	jg     800b2b <vprintfmt+0x2e6>
	else if (lflag)
  800b10:	85 c9                	test   %ecx,%ecx
  800b12:	74 2c                	je     800b40 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800b14:	8b 45 14             	mov    0x14(%ebp),%eax
  800b17:	8b 10                	mov    (%eax),%edx
  800b19:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1e:	8d 40 04             	lea    0x4(%eax),%eax
  800b21:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b24:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800b29:	eb 62                	jmp    800b8d <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800b2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2e:	8b 10                	mov    (%eax),%edx
  800b30:	8b 48 04             	mov    0x4(%eax),%ecx
  800b33:	8d 40 08             	lea    0x8(%eax),%eax
  800b36:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b39:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800b3e:	eb 4d                	jmp    800b8d <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800b40:	8b 45 14             	mov    0x14(%ebp),%eax
  800b43:	8b 10                	mov    (%eax),%edx
  800b45:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4a:	8d 40 04             	lea    0x4(%eax),%eax
  800b4d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b50:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800b55:	eb 36                	jmp    800b8d <vprintfmt+0x348>
	if (lflag >= 2)
  800b57:	83 f9 01             	cmp    $0x1,%ecx
  800b5a:	7f 17                	jg     800b73 <vprintfmt+0x32e>
	else if (lflag)
  800b5c:	85 c9                	test   %ecx,%ecx
  800b5e:	74 6e                	je     800bce <vprintfmt+0x389>
		return va_arg(*ap, long);
  800b60:	8b 45 14             	mov    0x14(%ebp),%eax
  800b63:	8b 10                	mov    (%eax),%edx
  800b65:	89 d0                	mov    %edx,%eax
  800b67:	99                   	cltd   
  800b68:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800b6b:	8d 49 04             	lea    0x4(%ecx),%ecx
  800b6e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800b71:	eb 11                	jmp    800b84 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800b73:	8b 45 14             	mov    0x14(%ebp),%eax
  800b76:	8b 50 04             	mov    0x4(%eax),%edx
  800b79:	8b 00                	mov    (%eax),%eax
  800b7b:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800b7e:	8d 49 08             	lea    0x8(%ecx),%ecx
  800b81:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800b84:	89 d1                	mov    %edx,%ecx
  800b86:	89 c2                	mov    %eax,%edx
            base = 8;
  800b88:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800b8d:	83 ec 0c             	sub    $0xc,%esp
  800b90:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800b94:	57                   	push   %edi
  800b95:	ff 75 e0             	pushl  -0x20(%ebp)
  800b98:	50                   	push   %eax
  800b99:	51                   	push   %ecx
  800b9a:	52                   	push   %edx
  800b9b:	89 da                	mov    %ebx,%edx
  800b9d:	89 f0                	mov    %esi,%eax
  800b9f:	e8 b6 fb ff ff       	call   80075a <printnum>
			break;
  800ba4:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800ba7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800baa:	83 c7 01             	add    $0x1,%edi
  800bad:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800bb1:	83 f8 25             	cmp    $0x25,%eax
  800bb4:	0f 84 a6 fc ff ff    	je     800860 <vprintfmt+0x1b>
			if (ch == '\0')
  800bba:	85 c0                	test   %eax,%eax
  800bbc:	0f 84 ce 00 00 00    	je     800c90 <vprintfmt+0x44b>
			putch(ch, putdat);
  800bc2:	83 ec 08             	sub    $0x8,%esp
  800bc5:	53                   	push   %ebx
  800bc6:	50                   	push   %eax
  800bc7:	ff d6                	call   *%esi
  800bc9:	83 c4 10             	add    $0x10,%esp
  800bcc:	eb dc                	jmp    800baa <vprintfmt+0x365>
		return va_arg(*ap, int);
  800bce:	8b 45 14             	mov    0x14(%ebp),%eax
  800bd1:	8b 10                	mov    (%eax),%edx
  800bd3:	89 d0                	mov    %edx,%eax
  800bd5:	99                   	cltd   
  800bd6:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800bd9:	8d 49 04             	lea    0x4(%ecx),%ecx
  800bdc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800bdf:	eb a3                	jmp    800b84 <vprintfmt+0x33f>
			putch('0', putdat);
  800be1:	83 ec 08             	sub    $0x8,%esp
  800be4:	53                   	push   %ebx
  800be5:	6a 30                	push   $0x30
  800be7:	ff d6                	call   *%esi
			putch('x', putdat);
  800be9:	83 c4 08             	add    $0x8,%esp
  800bec:	53                   	push   %ebx
  800bed:	6a 78                	push   $0x78
  800bef:	ff d6                	call   *%esi
			num = (unsigned long long)
  800bf1:	8b 45 14             	mov    0x14(%ebp),%eax
  800bf4:	8b 10                	mov    (%eax),%edx
  800bf6:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800bfb:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800bfe:	8d 40 04             	lea    0x4(%eax),%eax
  800c01:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c04:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800c09:	eb 82                	jmp    800b8d <vprintfmt+0x348>
	if (lflag >= 2)
  800c0b:	83 f9 01             	cmp    $0x1,%ecx
  800c0e:	7f 1e                	jg     800c2e <vprintfmt+0x3e9>
	else if (lflag)
  800c10:	85 c9                	test   %ecx,%ecx
  800c12:	74 32                	je     800c46 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800c14:	8b 45 14             	mov    0x14(%ebp),%eax
  800c17:	8b 10                	mov    (%eax),%edx
  800c19:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c1e:	8d 40 04             	lea    0x4(%eax),%eax
  800c21:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c24:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800c29:	e9 5f ff ff ff       	jmp    800b8d <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800c2e:	8b 45 14             	mov    0x14(%ebp),%eax
  800c31:	8b 10                	mov    (%eax),%edx
  800c33:	8b 48 04             	mov    0x4(%eax),%ecx
  800c36:	8d 40 08             	lea    0x8(%eax),%eax
  800c39:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c3c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800c41:	e9 47 ff ff ff       	jmp    800b8d <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800c46:	8b 45 14             	mov    0x14(%ebp),%eax
  800c49:	8b 10                	mov    (%eax),%edx
  800c4b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c50:	8d 40 04             	lea    0x4(%eax),%eax
  800c53:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c56:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800c5b:	e9 2d ff ff ff       	jmp    800b8d <vprintfmt+0x348>
			putch(ch, putdat);
  800c60:	83 ec 08             	sub    $0x8,%esp
  800c63:	53                   	push   %ebx
  800c64:	6a 25                	push   $0x25
  800c66:	ff d6                	call   *%esi
			break;
  800c68:	83 c4 10             	add    $0x10,%esp
  800c6b:	e9 37 ff ff ff       	jmp    800ba7 <vprintfmt+0x362>
			putch('%', putdat);
  800c70:	83 ec 08             	sub    $0x8,%esp
  800c73:	53                   	push   %ebx
  800c74:	6a 25                	push   $0x25
  800c76:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c78:	83 c4 10             	add    $0x10,%esp
  800c7b:	89 f8                	mov    %edi,%eax
  800c7d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800c81:	74 05                	je     800c88 <vprintfmt+0x443>
  800c83:	83 e8 01             	sub    $0x1,%eax
  800c86:	eb f5                	jmp    800c7d <vprintfmt+0x438>
  800c88:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c8b:	e9 17 ff ff ff       	jmp    800ba7 <vprintfmt+0x362>
}
  800c90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5f                   	pop    %edi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c98:	f3 0f 1e fb          	endbr32 
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	83 ec 18             	sub    $0x18,%esp
  800ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ca8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cab:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800caf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cb2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	74 26                	je     800ce3 <vsnprintf+0x4b>
  800cbd:	85 d2                	test   %edx,%edx
  800cbf:	7e 22                	jle    800ce3 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cc1:	ff 75 14             	pushl  0x14(%ebp)
  800cc4:	ff 75 10             	pushl  0x10(%ebp)
  800cc7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cca:	50                   	push   %eax
  800ccb:	68 03 08 80 00       	push   $0x800803
  800cd0:	e8 70 fb ff ff       	call   800845 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cd5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cd8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cde:	83 c4 10             	add    $0x10,%esp
}
  800ce1:	c9                   	leave  
  800ce2:	c3                   	ret    
		return -E_INVAL;
  800ce3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ce8:	eb f7                	jmp    800ce1 <vsnprintf+0x49>

00800cea <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cea:	f3 0f 1e fb          	endbr32 
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cf4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cf7:	50                   	push   %eax
  800cf8:	ff 75 10             	pushl  0x10(%ebp)
  800cfb:	ff 75 0c             	pushl  0xc(%ebp)
  800cfe:	ff 75 08             	pushl  0x8(%ebp)
  800d01:	e8 92 ff ff ff       	call   800c98 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d06:	c9                   	leave  
  800d07:	c3                   	ret    

00800d08 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d08:	f3 0f 1e fb          	endbr32 
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d12:	b8 00 00 00 00       	mov    $0x0,%eax
  800d17:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d1b:	74 05                	je     800d22 <strlen+0x1a>
		n++;
  800d1d:	83 c0 01             	add    $0x1,%eax
  800d20:	eb f5                	jmp    800d17 <strlen+0xf>
	return n;
}
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d24:	f3 0f 1e fb          	endbr32 
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d2e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d31:	b8 00 00 00 00       	mov    $0x0,%eax
  800d36:	39 d0                	cmp    %edx,%eax
  800d38:	74 0d                	je     800d47 <strnlen+0x23>
  800d3a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d3e:	74 05                	je     800d45 <strnlen+0x21>
		n++;
  800d40:	83 c0 01             	add    $0x1,%eax
  800d43:	eb f1                	jmp    800d36 <strnlen+0x12>
  800d45:	89 c2                	mov    %eax,%edx
	return n;
}
  800d47:	89 d0                	mov    %edx,%eax
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d4b:	f3 0f 1e fb          	endbr32 
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	53                   	push   %ebx
  800d53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d59:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5e:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800d62:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800d65:	83 c0 01             	add    $0x1,%eax
  800d68:	84 d2                	test   %dl,%dl
  800d6a:	75 f2                	jne    800d5e <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800d6c:	89 c8                	mov    %ecx,%eax
  800d6e:	5b                   	pop    %ebx
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    

00800d71 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d71:	f3 0f 1e fb          	endbr32 
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	53                   	push   %ebx
  800d79:	83 ec 10             	sub    $0x10,%esp
  800d7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d7f:	53                   	push   %ebx
  800d80:	e8 83 ff ff ff       	call   800d08 <strlen>
  800d85:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800d88:	ff 75 0c             	pushl  0xc(%ebp)
  800d8b:	01 d8                	add    %ebx,%eax
  800d8d:	50                   	push   %eax
  800d8e:	e8 b8 ff ff ff       	call   800d4b <strcpy>
	return dst;
}
  800d93:	89 d8                	mov    %ebx,%eax
  800d95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d98:	c9                   	leave  
  800d99:	c3                   	ret    

00800d9a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d9a:	f3 0f 1e fb          	endbr32 
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	56                   	push   %esi
  800da2:	53                   	push   %ebx
  800da3:	8b 75 08             	mov    0x8(%ebp),%esi
  800da6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da9:	89 f3                	mov    %esi,%ebx
  800dab:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dae:	89 f0                	mov    %esi,%eax
  800db0:	39 d8                	cmp    %ebx,%eax
  800db2:	74 11                	je     800dc5 <strncpy+0x2b>
		*dst++ = *src;
  800db4:	83 c0 01             	add    $0x1,%eax
  800db7:	0f b6 0a             	movzbl (%edx),%ecx
  800dba:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800dbd:	80 f9 01             	cmp    $0x1,%cl
  800dc0:	83 da ff             	sbb    $0xffffffff,%edx
  800dc3:	eb eb                	jmp    800db0 <strncpy+0x16>
	}
	return ret;
}
  800dc5:	89 f0                	mov    %esi,%eax
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dcb:	f3 0f 1e fb          	endbr32 
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	8b 75 08             	mov    0x8(%ebp),%esi
  800dd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dda:	8b 55 10             	mov    0x10(%ebp),%edx
  800ddd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ddf:	85 d2                	test   %edx,%edx
  800de1:	74 21                	je     800e04 <strlcpy+0x39>
  800de3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800de7:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800de9:	39 c2                	cmp    %eax,%edx
  800deb:	74 14                	je     800e01 <strlcpy+0x36>
  800ded:	0f b6 19             	movzbl (%ecx),%ebx
  800df0:	84 db                	test   %bl,%bl
  800df2:	74 0b                	je     800dff <strlcpy+0x34>
			*dst++ = *src++;
  800df4:	83 c1 01             	add    $0x1,%ecx
  800df7:	83 c2 01             	add    $0x1,%edx
  800dfa:	88 5a ff             	mov    %bl,-0x1(%edx)
  800dfd:	eb ea                	jmp    800de9 <strlcpy+0x1e>
  800dff:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800e01:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e04:	29 f0                	sub    %esi,%eax
}
  800e06:	5b                   	pop    %ebx
  800e07:	5e                   	pop    %esi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e0a:	f3 0f 1e fb          	endbr32 
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e14:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e17:	0f b6 01             	movzbl (%ecx),%eax
  800e1a:	84 c0                	test   %al,%al
  800e1c:	74 0c                	je     800e2a <strcmp+0x20>
  800e1e:	3a 02                	cmp    (%edx),%al
  800e20:	75 08                	jne    800e2a <strcmp+0x20>
		p++, q++;
  800e22:	83 c1 01             	add    $0x1,%ecx
  800e25:	83 c2 01             	add    $0x1,%edx
  800e28:	eb ed                	jmp    800e17 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e2a:	0f b6 c0             	movzbl %al,%eax
  800e2d:	0f b6 12             	movzbl (%edx),%edx
  800e30:	29 d0                	sub    %edx,%eax
}
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    

00800e34 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e34:	f3 0f 1e fb          	endbr32 
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	53                   	push   %ebx
  800e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e42:	89 c3                	mov    %eax,%ebx
  800e44:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e47:	eb 06                	jmp    800e4f <strncmp+0x1b>
		n--, p++, q++;
  800e49:	83 c0 01             	add    $0x1,%eax
  800e4c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800e4f:	39 d8                	cmp    %ebx,%eax
  800e51:	74 16                	je     800e69 <strncmp+0x35>
  800e53:	0f b6 08             	movzbl (%eax),%ecx
  800e56:	84 c9                	test   %cl,%cl
  800e58:	74 04                	je     800e5e <strncmp+0x2a>
  800e5a:	3a 0a                	cmp    (%edx),%cl
  800e5c:	74 eb                	je     800e49 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e5e:	0f b6 00             	movzbl (%eax),%eax
  800e61:	0f b6 12             	movzbl (%edx),%edx
  800e64:	29 d0                	sub    %edx,%eax
}
  800e66:	5b                   	pop    %ebx
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    
		return 0;
  800e69:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6e:	eb f6                	jmp    800e66 <strncmp+0x32>

00800e70 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e70:	f3 0f 1e fb          	endbr32 
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e7e:	0f b6 10             	movzbl (%eax),%edx
  800e81:	84 d2                	test   %dl,%dl
  800e83:	74 09                	je     800e8e <strchr+0x1e>
		if (*s == c)
  800e85:	38 ca                	cmp    %cl,%dl
  800e87:	74 0a                	je     800e93 <strchr+0x23>
	for (; *s; s++)
  800e89:	83 c0 01             	add    $0x1,%eax
  800e8c:	eb f0                	jmp    800e7e <strchr+0xe>
			return (char *) s;
	return 0;
  800e8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    

00800e95 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e95:	f3 0f 1e fb          	endbr32 
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ea3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ea6:	38 ca                	cmp    %cl,%dl
  800ea8:	74 09                	je     800eb3 <strfind+0x1e>
  800eaa:	84 d2                	test   %dl,%dl
  800eac:	74 05                	je     800eb3 <strfind+0x1e>
	for (; *s; s++)
  800eae:	83 c0 01             	add    $0x1,%eax
  800eb1:	eb f0                	jmp    800ea3 <strfind+0xe>
			break;
	return (char *) s;
}
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    

00800eb5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800eb5:	f3 0f 1e fb          	endbr32 
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	57                   	push   %edi
  800ebd:	56                   	push   %esi
  800ebe:	53                   	push   %ebx
  800ebf:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ec2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ec5:	85 c9                	test   %ecx,%ecx
  800ec7:	74 31                	je     800efa <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ec9:	89 f8                	mov    %edi,%eax
  800ecb:	09 c8                	or     %ecx,%eax
  800ecd:	a8 03                	test   $0x3,%al
  800ecf:	75 23                	jne    800ef4 <memset+0x3f>
		c &= 0xFF;
  800ed1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ed5:	89 d3                	mov    %edx,%ebx
  800ed7:	c1 e3 08             	shl    $0x8,%ebx
  800eda:	89 d0                	mov    %edx,%eax
  800edc:	c1 e0 18             	shl    $0x18,%eax
  800edf:	89 d6                	mov    %edx,%esi
  800ee1:	c1 e6 10             	shl    $0x10,%esi
  800ee4:	09 f0                	or     %esi,%eax
  800ee6:	09 c2                	or     %eax,%edx
  800ee8:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800eea:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800eed:	89 d0                	mov    %edx,%eax
  800eef:	fc                   	cld    
  800ef0:	f3 ab                	rep stos %eax,%es:(%edi)
  800ef2:	eb 06                	jmp    800efa <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ef4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef7:	fc                   	cld    
  800ef8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800efa:	89 f8                	mov    %edi,%eax
  800efc:	5b                   	pop    %ebx
  800efd:	5e                   	pop    %esi
  800efe:	5f                   	pop    %edi
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    

00800f01 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f01:	f3 0f 1e fb          	endbr32 
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	57                   	push   %edi
  800f09:	56                   	push   %esi
  800f0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f10:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f13:	39 c6                	cmp    %eax,%esi
  800f15:	73 32                	jae    800f49 <memmove+0x48>
  800f17:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f1a:	39 c2                	cmp    %eax,%edx
  800f1c:	76 2b                	jbe    800f49 <memmove+0x48>
		s += n;
		d += n;
  800f1e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f21:	89 fe                	mov    %edi,%esi
  800f23:	09 ce                	or     %ecx,%esi
  800f25:	09 d6                	or     %edx,%esi
  800f27:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f2d:	75 0e                	jne    800f3d <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f2f:	83 ef 04             	sub    $0x4,%edi
  800f32:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f35:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800f38:	fd                   	std    
  800f39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f3b:	eb 09                	jmp    800f46 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f3d:	83 ef 01             	sub    $0x1,%edi
  800f40:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800f43:	fd                   	std    
  800f44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f46:	fc                   	cld    
  800f47:	eb 1a                	jmp    800f63 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f49:	89 c2                	mov    %eax,%edx
  800f4b:	09 ca                	or     %ecx,%edx
  800f4d:	09 f2                	or     %esi,%edx
  800f4f:	f6 c2 03             	test   $0x3,%dl
  800f52:	75 0a                	jne    800f5e <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f54:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800f57:	89 c7                	mov    %eax,%edi
  800f59:	fc                   	cld    
  800f5a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f5c:	eb 05                	jmp    800f63 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800f5e:	89 c7                	mov    %eax,%edi
  800f60:	fc                   	cld    
  800f61:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f63:	5e                   	pop    %esi
  800f64:	5f                   	pop    %edi
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    

00800f67 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f67:	f3 0f 1e fb          	endbr32 
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f71:	ff 75 10             	pushl  0x10(%ebp)
  800f74:	ff 75 0c             	pushl  0xc(%ebp)
  800f77:	ff 75 08             	pushl  0x8(%ebp)
  800f7a:	e8 82 ff ff ff       	call   800f01 <memmove>
}
  800f7f:	c9                   	leave  
  800f80:	c3                   	ret    

00800f81 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f81:	f3 0f 1e fb          	endbr32 
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	56                   	push   %esi
  800f89:	53                   	push   %ebx
  800f8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f90:	89 c6                	mov    %eax,%esi
  800f92:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f95:	39 f0                	cmp    %esi,%eax
  800f97:	74 1c                	je     800fb5 <memcmp+0x34>
		if (*s1 != *s2)
  800f99:	0f b6 08             	movzbl (%eax),%ecx
  800f9c:	0f b6 1a             	movzbl (%edx),%ebx
  800f9f:	38 d9                	cmp    %bl,%cl
  800fa1:	75 08                	jne    800fab <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800fa3:	83 c0 01             	add    $0x1,%eax
  800fa6:	83 c2 01             	add    $0x1,%edx
  800fa9:	eb ea                	jmp    800f95 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800fab:	0f b6 c1             	movzbl %cl,%eax
  800fae:	0f b6 db             	movzbl %bl,%ebx
  800fb1:	29 d8                	sub    %ebx,%eax
  800fb3:	eb 05                	jmp    800fba <memcmp+0x39>
	}

	return 0;
  800fb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fba:	5b                   	pop    %ebx
  800fbb:	5e                   	pop    %esi
  800fbc:	5d                   	pop    %ebp
  800fbd:	c3                   	ret    

00800fbe <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fbe:	f3 0f 1e fb          	endbr32 
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800fcb:	89 c2                	mov    %eax,%edx
  800fcd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800fd0:	39 d0                	cmp    %edx,%eax
  800fd2:	73 09                	jae    800fdd <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fd4:	38 08                	cmp    %cl,(%eax)
  800fd6:	74 05                	je     800fdd <memfind+0x1f>
	for (; s < ends; s++)
  800fd8:	83 c0 01             	add    $0x1,%eax
  800fdb:	eb f3                	jmp    800fd0 <memfind+0x12>
			break;
	return (void *) s;
}
  800fdd:	5d                   	pop    %ebp
  800fde:	c3                   	ret    

00800fdf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fdf:	f3 0f 1e fb          	endbr32 
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	57                   	push   %edi
  800fe7:	56                   	push   %esi
  800fe8:	53                   	push   %ebx
  800fe9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fef:	eb 03                	jmp    800ff4 <strtol+0x15>
		s++;
  800ff1:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ff4:	0f b6 01             	movzbl (%ecx),%eax
  800ff7:	3c 20                	cmp    $0x20,%al
  800ff9:	74 f6                	je     800ff1 <strtol+0x12>
  800ffb:	3c 09                	cmp    $0x9,%al
  800ffd:	74 f2                	je     800ff1 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800fff:	3c 2b                	cmp    $0x2b,%al
  801001:	74 2a                	je     80102d <strtol+0x4e>
	int neg = 0;
  801003:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801008:	3c 2d                	cmp    $0x2d,%al
  80100a:	74 2b                	je     801037 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80100c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801012:	75 0f                	jne    801023 <strtol+0x44>
  801014:	80 39 30             	cmpb   $0x30,(%ecx)
  801017:	74 28                	je     801041 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801019:	85 db                	test   %ebx,%ebx
  80101b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801020:	0f 44 d8             	cmove  %eax,%ebx
  801023:	b8 00 00 00 00       	mov    $0x0,%eax
  801028:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80102b:	eb 46                	jmp    801073 <strtol+0x94>
		s++;
  80102d:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801030:	bf 00 00 00 00       	mov    $0x0,%edi
  801035:	eb d5                	jmp    80100c <strtol+0x2d>
		s++, neg = 1;
  801037:	83 c1 01             	add    $0x1,%ecx
  80103a:	bf 01 00 00 00       	mov    $0x1,%edi
  80103f:	eb cb                	jmp    80100c <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801041:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801045:	74 0e                	je     801055 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801047:	85 db                	test   %ebx,%ebx
  801049:	75 d8                	jne    801023 <strtol+0x44>
		s++, base = 8;
  80104b:	83 c1 01             	add    $0x1,%ecx
  80104e:	bb 08 00 00 00       	mov    $0x8,%ebx
  801053:	eb ce                	jmp    801023 <strtol+0x44>
		s += 2, base = 16;
  801055:	83 c1 02             	add    $0x2,%ecx
  801058:	bb 10 00 00 00       	mov    $0x10,%ebx
  80105d:	eb c4                	jmp    801023 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  80105f:	0f be d2             	movsbl %dl,%edx
  801062:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801065:	3b 55 10             	cmp    0x10(%ebp),%edx
  801068:	7d 3a                	jge    8010a4 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  80106a:	83 c1 01             	add    $0x1,%ecx
  80106d:	0f af 45 10          	imul   0x10(%ebp),%eax
  801071:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801073:	0f b6 11             	movzbl (%ecx),%edx
  801076:	8d 72 d0             	lea    -0x30(%edx),%esi
  801079:	89 f3                	mov    %esi,%ebx
  80107b:	80 fb 09             	cmp    $0x9,%bl
  80107e:	76 df                	jbe    80105f <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801080:	8d 72 9f             	lea    -0x61(%edx),%esi
  801083:	89 f3                	mov    %esi,%ebx
  801085:	80 fb 19             	cmp    $0x19,%bl
  801088:	77 08                	ja     801092 <strtol+0xb3>
			dig = *s - 'a' + 10;
  80108a:	0f be d2             	movsbl %dl,%edx
  80108d:	83 ea 57             	sub    $0x57,%edx
  801090:	eb d3                	jmp    801065 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801092:	8d 72 bf             	lea    -0x41(%edx),%esi
  801095:	89 f3                	mov    %esi,%ebx
  801097:	80 fb 19             	cmp    $0x19,%bl
  80109a:	77 08                	ja     8010a4 <strtol+0xc5>
			dig = *s - 'A' + 10;
  80109c:	0f be d2             	movsbl %dl,%edx
  80109f:	83 ea 37             	sub    $0x37,%edx
  8010a2:	eb c1                	jmp    801065 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  8010a4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010a8:	74 05                	je     8010af <strtol+0xd0>
		*endptr = (char *) s;
  8010aa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010ad:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8010af:	89 c2                	mov    %eax,%edx
  8010b1:	f7 da                	neg    %edx
  8010b3:	85 ff                	test   %edi,%edi
  8010b5:	0f 45 c2             	cmovne %edx,%eax
}
  8010b8:	5b                   	pop    %ebx
  8010b9:	5e                   	pop    %esi
  8010ba:	5f                   	pop    %edi
  8010bb:	5d                   	pop    %ebp
  8010bc:	c3                   	ret    

008010bd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010bd:	f3 0f 1e fb          	endbr32 
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	57                   	push   %edi
  8010c5:	56                   	push   %esi
  8010c6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8010cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8010cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010d2:	89 c3                	mov    %eax,%ebx
  8010d4:	89 c7                	mov    %eax,%edi
  8010d6:	89 c6                	mov    %eax,%esi
  8010d8:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8010da:	5b                   	pop    %ebx
  8010db:	5e                   	pop    %esi
  8010dc:	5f                   	pop    %edi
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    

008010df <sys_cgetc>:

int
sys_cgetc(void)
{
  8010df:	f3 0f 1e fb          	endbr32 
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	57                   	push   %edi
  8010e7:	56                   	push   %esi
  8010e8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8010f3:	89 d1                	mov    %edx,%ecx
  8010f5:	89 d3                	mov    %edx,%ebx
  8010f7:	89 d7                	mov    %edx,%edi
  8010f9:	89 d6                	mov    %edx,%esi
  8010fb:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010fd:	5b                   	pop    %ebx
  8010fe:	5e                   	pop    %esi
  8010ff:	5f                   	pop    %edi
  801100:	5d                   	pop    %ebp
  801101:	c3                   	ret    

00801102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801102:	f3 0f 1e fb          	endbr32 
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	57                   	push   %edi
  80110a:	56                   	push   %esi
  80110b:	53                   	push   %ebx
  80110c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80110f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801114:	8b 55 08             	mov    0x8(%ebp),%edx
  801117:	b8 03 00 00 00       	mov    $0x3,%eax
  80111c:	89 cb                	mov    %ecx,%ebx
  80111e:	89 cf                	mov    %ecx,%edi
  801120:	89 ce                	mov    %ecx,%esi
  801122:	cd 30                	int    $0x30
	if(check && ret > 0)
  801124:	85 c0                	test   %eax,%eax
  801126:	7f 08                	jg     801130 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801128:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112b:	5b                   	pop    %ebx
  80112c:	5e                   	pop    %esi
  80112d:	5f                   	pop    %edi
  80112e:	5d                   	pop    %ebp
  80112f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801130:	83 ec 0c             	sub    $0xc,%esp
  801133:	50                   	push   %eax
  801134:	6a 03                	push   $0x3
  801136:	68 3f 29 80 00       	push   $0x80293f
  80113b:	6a 23                	push   $0x23
  80113d:	68 5c 29 80 00       	push   $0x80295c
  801142:	e8 14 f5 ff ff       	call   80065b <_panic>

00801147 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801147:	f3 0f 1e fb          	endbr32 
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
  80114e:	57                   	push   %edi
  80114f:	56                   	push   %esi
  801150:	53                   	push   %ebx
	asm volatile("int %1\n"
  801151:	ba 00 00 00 00       	mov    $0x0,%edx
  801156:	b8 02 00 00 00       	mov    $0x2,%eax
  80115b:	89 d1                	mov    %edx,%ecx
  80115d:	89 d3                	mov    %edx,%ebx
  80115f:	89 d7                	mov    %edx,%edi
  801161:	89 d6                	mov    %edx,%esi
  801163:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801165:	5b                   	pop    %ebx
  801166:	5e                   	pop    %esi
  801167:	5f                   	pop    %edi
  801168:	5d                   	pop    %ebp
  801169:	c3                   	ret    

0080116a <sys_yield>:

void
sys_yield(void)
{
  80116a:	f3 0f 1e fb          	endbr32 
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	57                   	push   %edi
  801172:	56                   	push   %esi
  801173:	53                   	push   %ebx
	asm volatile("int %1\n"
  801174:	ba 00 00 00 00       	mov    $0x0,%edx
  801179:	b8 0b 00 00 00       	mov    $0xb,%eax
  80117e:	89 d1                	mov    %edx,%ecx
  801180:	89 d3                	mov    %edx,%ebx
  801182:	89 d7                	mov    %edx,%edi
  801184:	89 d6                	mov    %edx,%esi
  801186:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801188:	5b                   	pop    %ebx
  801189:	5e                   	pop    %esi
  80118a:	5f                   	pop    %edi
  80118b:	5d                   	pop    %ebp
  80118c:	c3                   	ret    

0080118d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80118d:	f3 0f 1e fb          	endbr32 
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	57                   	push   %edi
  801195:	56                   	push   %esi
  801196:	53                   	push   %ebx
  801197:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80119a:	be 00 00 00 00       	mov    $0x0,%esi
  80119f:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a5:	b8 04 00 00 00       	mov    $0x4,%eax
  8011aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011ad:	89 f7                	mov    %esi,%edi
  8011af:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	7f 08                	jg     8011bd <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b8:	5b                   	pop    %ebx
  8011b9:	5e                   	pop    %esi
  8011ba:	5f                   	pop    %edi
  8011bb:	5d                   	pop    %ebp
  8011bc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011bd:	83 ec 0c             	sub    $0xc,%esp
  8011c0:	50                   	push   %eax
  8011c1:	6a 04                	push   $0x4
  8011c3:	68 3f 29 80 00       	push   $0x80293f
  8011c8:	6a 23                	push   $0x23
  8011ca:	68 5c 29 80 00       	push   $0x80295c
  8011cf:	e8 87 f4 ff ff       	call   80065b <_panic>

008011d4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011d4:	f3 0f 1e fb          	endbr32 
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	57                   	push   %edi
  8011dc:	56                   	push   %esi
  8011dd:	53                   	push   %ebx
  8011de:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8011e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e7:	b8 05 00 00 00       	mov    $0x5,%eax
  8011ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011ef:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011f2:	8b 75 18             	mov    0x18(%ebp),%esi
  8011f5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	7f 08                	jg     801203 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8011fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fe:	5b                   	pop    %ebx
  8011ff:	5e                   	pop    %esi
  801200:	5f                   	pop    %edi
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801203:	83 ec 0c             	sub    $0xc,%esp
  801206:	50                   	push   %eax
  801207:	6a 05                	push   $0x5
  801209:	68 3f 29 80 00       	push   $0x80293f
  80120e:	6a 23                	push   $0x23
  801210:	68 5c 29 80 00       	push   $0x80295c
  801215:	e8 41 f4 ff ff       	call   80065b <_panic>

0080121a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80121a:	f3 0f 1e fb          	endbr32 
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	57                   	push   %edi
  801222:	56                   	push   %esi
  801223:	53                   	push   %ebx
  801224:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801227:	bb 00 00 00 00       	mov    $0x0,%ebx
  80122c:	8b 55 08             	mov    0x8(%ebp),%edx
  80122f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801232:	b8 06 00 00 00       	mov    $0x6,%eax
  801237:	89 df                	mov    %ebx,%edi
  801239:	89 de                	mov    %ebx,%esi
  80123b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80123d:	85 c0                	test   %eax,%eax
  80123f:	7f 08                	jg     801249 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801241:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801244:	5b                   	pop    %ebx
  801245:	5e                   	pop    %esi
  801246:	5f                   	pop    %edi
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801249:	83 ec 0c             	sub    $0xc,%esp
  80124c:	50                   	push   %eax
  80124d:	6a 06                	push   $0x6
  80124f:	68 3f 29 80 00       	push   $0x80293f
  801254:	6a 23                	push   $0x23
  801256:	68 5c 29 80 00       	push   $0x80295c
  80125b:	e8 fb f3 ff ff       	call   80065b <_panic>

00801260 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801260:	f3 0f 1e fb          	endbr32 
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	57                   	push   %edi
  801268:	56                   	push   %esi
  801269:	53                   	push   %ebx
  80126a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80126d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801272:	8b 55 08             	mov    0x8(%ebp),%edx
  801275:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801278:	b8 08 00 00 00       	mov    $0x8,%eax
  80127d:	89 df                	mov    %ebx,%edi
  80127f:	89 de                	mov    %ebx,%esi
  801281:	cd 30                	int    $0x30
	if(check && ret > 0)
  801283:	85 c0                	test   %eax,%eax
  801285:	7f 08                	jg     80128f <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801287:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80128a:	5b                   	pop    %ebx
  80128b:	5e                   	pop    %esi
  80128c:	5f                   	pop    %edi
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80128f:	83 ec 0c             	sub    $0xc,%esp
  801292:	50                   	push   %eax
  801293:	6a 08                	push   $0x8
  801295:	68 3f 29 80 00       	push   $0x80293f
  80129a:	6a 23                	push   $0x23
  80129c:	68 5c 29 80 00       	push   $0x80295c
  8012a1:	e8 b5 f3 ff ff       	call   80065b <_panic>

008012a6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8012a6:	f3 0f 1e fb          	endbr32 
  8012aa:	55                   	push   %ebp
  8012ab:	89 e5                	mov    %esp,%ebp
  8012ad:	57                   	push   %edi
  8012ae:	56                   	push   %esi
  8012af:	53                   	push   %ebx
  8012b0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8012bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012be:	b8 09 00 00 00       	mov    $0x9,%eax
  8012c3:	89 df                	mov    %ebx,%edi
  8012c5:	89 de                	mov    %ebx,%esi
  8012c7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	7f 08                	jg     8012d5 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8012cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d0:	5b                   	pop    %ebx
  8012d1:	5e                   	pop    %esi
  8012d2:	5f                   	pop    %edi
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8012d5:	83 ec 0c             	sub    $0xc,%esp
  8012d8:	50                   	push   %eax
  8012d9:	6a 09                	push   $0x9
  8012db:	68 3f 29 80 00       	push   $0x80293f
  8012e0:	6a 23                	push   $0x23
  8012e2:	68 5c 29 80 00       	push   $0x80295c
  8012e7:	e8 6f f3 ff ff       	call   80065b <_panic>

008012ec <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012ec:	f3 0f 1e fb          	endbr32 
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	57                   	push   %edi
  8012f4:	56                   	push   %esi
  8012f5:	53                   	push   %ebx
  8012f6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801301:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801304:	b8 0a 00 00 00       	mov    $0xa,%eax
  801309:	89 df                	mov    %ebx,%edi
  80130b:	89 de                	mov    %ebx,%esi
  80130d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80130f:	85 c0                	test   %eax,%eax
  801311:	7f 08                	jg     80131b <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801313:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801316:	5b                   	pop    %ebx
  801317:	5e                   	pop    %esi
  801318:	5f                   	pop    %edi
  801319:	5d                   	pop    %ebp
  80131a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80131b:	83 ec 0c             	sub    $0xc,%esp
  80131e:	50                   	push   %eax
  80131f:	6a 0a                	push   $0xa
  801321:	68 3f 29 80 00       	push   $0x80293f
  801326:	6a 23                	push   $0x23
  801328:	68 5c 29 80 00       	push   $0x80295c
  80132d:	e8 29 f3 ff ff       	call   80065b <_panic>

00801332 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801332:	f3 0f 1e fb          	endbr32 
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	57                   	push   %edi
  80133a:	56                   	push   %esi
  80133b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80133c:	8b 55 08             	mov    0x8(%ebp),%edx
  80133f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801342:	b8 0c 00 00 00       	mov    $0xc,%eax
  801347:	be 00 00 00 00       	mov    $0x0,%esi
  80134c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80134f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801352:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801354:	5b                   	pop    %ebx
  801355:	5e                   	pop    %esi
  801356:	5f                   	pop    %edi
  801357:	5d                   	pop    %ebp
  801358:	c3                   	ret    

00801359 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801359:	f3 0f 1e fb          	endbr32 
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	57                   	push   %edi
  801361:	56                   	push   %esi
  801362:	53                   	push   %ebx
  801363:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801366:	b9 00 00 00 00       	mov    $0x0,%ecx
  80136b:	8b 55 08             	mov    0x8(%ebp),%edx
  80136e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801373:	89 cb                	mov    %ecx,%ebx
  801375:	89 cf                	mov    %ecx,%edi
  801377:	89 ce                	mov    %ecx,%esi
  801379:	cd 30                	int    $0x30
	if(check && ret > 0)
  80137b:	85 c0                	test   %eax,%eax
  80137d:	7f 08                	jg     801387 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80137f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801382:	5b                   	pop    %ebx
  801383:	5e                   	pop    %esi
  801384:	5f                   	pop    %edi
  801385:	5d                   	pop    %ebp
  801386:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801387:	83 ec 0c             	sub    $0xc,%esp
  80138a:	50                   	push   %eax
  80138b:	6a 0d                	push   $0xd
  80138d:	68 3f 29 80 00       	push   $0x80293f
  801392:	6a 23                	push   $0x23
  801394:	68 5c 29 80 00       	push   $0x80295c
  801399:	e8 bd f2 ff ff       	call   80065b <_panic>

0080139e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80139e:	f3 0f 1e fb          	endbr32 
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
  8013a5:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8013a8:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  8013af:	74 0a                	je     8013bb <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8013b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b4:	a3 b4 40 80 00       	mov    %eax,0x8040b4
}
  8013b9:	c9                   	leave  
  8013ba:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  8013bb:	83 ec 0c             	sub    $0xc,%esp
  8013be:	68 6a 29 80 00       	push   $0x80296a
  8013c3:	e8 7a f3 ff ff       	call   800742 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  8013c8:	83 c4 0c             	add    $0xc,%esp
  8013cb:	6a 07                	push   $0x7
  8013cd:	68 00 f0 bf ee       	push   $0xeebff000
  8013d2:	6a 00                	push   $0x0
  8013d4:	e8 b4 fd ff ff       	call   80118d <sys_page_alloc>
  8013d9:	83 c4 10             	add    $0x10,%esp
  8013dc:	85 c0                	test   %eax,%eax
  8013de:	78 2a                	js     80140a <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  8013e0:	83 ec 08             	sub    $0x8,%esp
  8013e3:	68 1e 14 80 00       	push   $0x80141e
  8013e8:	6a 00                	push   $0x0
  8013ea:	e8 fd fe ff ff       	call   8012ec <sys_env_set_pgfault_upcall>
  8013ef:	83 c4 10             	add    $0x10,%esp
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	79 bb                	jns    8013b1 <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  8013f6:	83 ec 04             	sub    $0x4,%esp
  8013f9:	68 a8 29 80 00       	push   $0x8029a8
  8013fe:	6a 25                	push   $0x25
  801400:	68 97 29 80 00       	push   $0x802997
  801405:	e8 51 f2 ff ff       	call   80065b <_panic>
            panic("Allocation of UXSTACK failed!");
  80140a:	83 ec 04             	sub    $0x4,%esp
  80140d:	68 79 29 80 00       	push   $0x802979
  801412:	6a 22                	push   $0x22
  801414:	68 97 29 80 00       	push   $0x802997
  801419:	e8 3d f2 ff ff       	call   80065b <_panic>

0080141e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80141e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80141f:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  801424:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801426:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  801429:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  80142d:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  801431:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  801434:	83 c4 08             	add    $0x8,%esp
    popa
  801437:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  801438:	83 c4 04             	add    $0x4,%esp
    popf
  80143b:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  80143c:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  80143f:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  801443:	c3                   	ret    

00801444 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801444:	f3 0f 1e fb          	endbr32 
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80144b:	8b 45 08             	mov    0x8(%ebp),%eax
  80144e:	05 00 00 00 30       	add    $0x30000000,%eax
  801453:	c1 e8 0c             	shr    $0xc,%eax
}
  801456:	5d                   	pop    %ebp
  801457:	c3                   	ret    

00801458 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801458:	f3 0f 1e fb          	endbr32 
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80145f:	8b 45 08             	mov    0x8(%ebp),%eax
  801462:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801467:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80146c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801471:	5d                   	pop    %ebp
  801472:	c3                   	ret    

00801473 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801473:	f3 0f 1e fb          	endbr32 
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80147f:	89 c2                	mov    %eax,%edx
  801481:	c1 ea 16             	shr    $0x16,%edx
  801484:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80148b:	f6 c2 01             	test   $0x1,%dl
  80148e:	74 2d                	je     8014bd <fd_alloc+0x4a>
  801490:	89 c2                	mov    %eax,%edx
  801492:	c1 ea 0c             	shr    $0xc,%edx
  801495:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80149c:	f6 c2 01             	test   $0x1,%dl
  80149f:	74 1c                	je     8014bd <fd_alloc+0x4a>
  8014a1:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8014a6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014ab:	75 d2                	jne    80147f <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8014b6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8014bb:	eb 0a                	jmp    8014c7 <fd_alloc+0x54>
			*fd_store = fd;
  8014bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014c0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c7:	5d                   	pop    %ebp
  8014c8:	c3                   	ret    

008014c9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014c9:	f3 0f 1e fb          	endbr32 
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014d3:	83 f8 1f             	cmp    $0x1f,%eax
  8014d6:	77 30                	ja     801508 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014d8:	c1 e0 0c             	shl    $0xc,%eax
  8014db:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014e0:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8014e6:	f6 c2 01             	test   $0x1,%dl
  8014e9:	74 24                	je     80150f <fd_lookup+0x46>
  8014eb:	89 c2                	mov    %eax,%edx
  8014ed:	c1 ea 0c             	shr    $0xc,%edx
  8014f0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014f7:	f6 c2 01             	test   $0x1,%dl
  8014fa:	74 1a                	je     801516 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ff:	89 02                	mov    %eax,(%edx)
	return 0;
  801501:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801506:	5d                   	pop    %ebp
  801507:	c3                   	ret    
		return -E_INVAL;
  801508:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80150d:	eb f7                	jmp    801506 <fd_lookup+0x3d>
		return -E_INVAL;
  80150f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801514:	eb f0                	jmp    801506 <fd_lookup+0x3d>
  801516:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80151b:	eb e9                	jmp    801506 <fd_lookup+0x3d>

0080151d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80151d:	f3 0f 1e fb          	endbr32 
  801521:	55                   	push   %ebp
  801522:	89 e5                	mov    %esp,%ebp
  801524:	83 ec 08             	sub    $0x8,%esp
  801527:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80152a:	ba 48 2a 80 00       	mov    $0x802a48,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80152f:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801534:	39 08                	cmp    %ecx,(%eax)
  801536:	74 33                	je     80156b <dev_lookup+0x4e>
  801538:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80153b:	8b 02                	mov    (%edx),%eax
  80153d:	85 c0                	test   %eax,%eax
  80153f:	75 f3                	jne    801534 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801541:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801546:	8b 40 48             	mov    0x48(%eax),%eax
  801549:	83 ec 04             	sub    $0x4,%esp
  80154c:	51                   	push   %ecx
  80154d:	50                   	push   %eax
  80154e:	68 cc 29 80 00       	push   $0x8029cc
  801553:	e8 ea f1 ff ff       	call   800742 <cprintf>
	*dev = 0;
  801558:	8b 45 0c             	mov    0xc(%ebp),%eax
  80155b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801561:	83 c4 10             	add    $0x10,%esp
  801564:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801569:	c9                   	leave  
  80156a:	c3                   	ret    
			*dev = devtab[i];
  80156b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80156e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801570:	b8 00 00 00 00       	mov    $0x0,%eax
  801575:	eb f2                	jmp    801569 <dev_lookup+0x4c>

00801577 <fd_close>:
{
  801577:	f3 0f 1e fb          	endbr32 
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	57                   	push   %edi
  80157f:	56                   	push   %esi
  801580:	53                   	push   %ebx
  801581:	83 ec 24             	sub    $0x24,%esp
  801584:	8b 75 08             	mov    0x8(%ebp),%esi
  801587:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80158a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80158d:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80158e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801594:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801597:	50                   	push   %eax
  801598:	e8 2c ff ff ff       	call   8014c9 <fd_lookup>
  80159d:	89 c3                	mov    %eax,%ebx
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	85 c0                	test   %eax,%eax
  8015a4:	78 05                	js     8015ab <fd_close+0x34>
	    || fd != fd2)
  8015a6:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8015a9:	74 16                	je     8015c1 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8015ab:	89 f8                	mov    %edi,%eax
  8015ad:	84 c0                	test   %al,%al
  8015af:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b4:	0f 44 d8             	cmove  %eax,%ebx
}
  8015b7:	89 d8                	mov    %ebx,%eax
  8015b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015bc:	5b                   	pop    %ebx
  8015bd:	5e                   	pop    %esi
  8015be:	5f                   	pop    %edi
  8015bf:	5d                   	pop    %ebp
  8015c0:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015c1:	83 ec 08             	sub    $0x8,%esp
  8015c4:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8015c7:	50                   	push   %eax
  8015c8:	ff 36                	pushl  (%esi)
  8015ca:	e8 4e ff ff ff       	call   80151d <dev_lookup>
  8015cf:	89 c3                	mov    %eax,%ebx
  8015d1:	83 c4 10             	add    $0x10,%esp
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 1a                	js     8015f2 <fd_close+0x7b>
		if (dev->dev_close)
  8015d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015db:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8015de:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	74 0b                	je     8015f2 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8015e7:	83 ec 0c             	sub    $0xc,%esp
  8015ea:	56                   	push   %esi
  8015eb:	ff d0                	call   *%eax
  8015ed:	89 c3                	mov    %eax,%ebx
  8015ef:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8015f2:	83 ec 08             	sub    $0x8,%esp
  8015f5:	56                   	push   %esi
  8015f6:	6a 00                	push   $0x0
  8015f8:	e8 1d fc ff ff       	call   80121a <sys_page_unmap>
	return r;
  8015fd:	83 c4 10             	add    $0x10,%esp
  801600:	eb b5                	jmp    8015b7 <fd_close+0x40>

00801602 <close>:

int
close(int fdnum)
{
  801602:	f3 0f 1e fb          	endbr32 
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
  801609:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80160c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160f:	50                   	push   %eax
  801610:	ff 75 08             	pushl  0x8(%ebp)
  801613:	e8 b1 fe ff ff       	call   8014c9 <fd_lookup>
  801618:	83 c4 10             	add    $0x10,%esp
  80161b:	85 c0                	test   %eax,%eax
  80161d:	79 02                	jns    801621 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  80161f:	c9                   	leave  
  801620:	c3                   	ret    
		return fd_close(fd, 1);
  801621:	83 ec 08             	sub    $0x8,%esp
  801624:	6a 01                	push   $0x1
  801626:	ff 75 f4             	pushl  -0xc(%ebp)
  801629:	e8 49 ff ff ff       	call   801577 <fd_close>
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	eb ec                	jmp    80161f <close+0x1d>

00801633 <close_all>:

void
close_all(void)
{
  801633:	f3 0f 1e fb          	endbr32 
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	53                   	push   %ebx
  80163b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80163e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801643:	83 ec 0c             	sub    $0xc,%esp
  801646:	53                   	push   %ebx
  801647:	e8 b6 ff ff ff       	call   801602 <close>
	for (i = 0; i < MAXFD; i++)
  80164c:	83 c3 01             	add    $0x1,%ebx
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	83 fb 20             	cmp    $0x20,%ebx
  801655:	75 ec                	jne    801643 <close_all+0x10>
}
  801657:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80165c:	f3 0f 1e fb          	endbr32 
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	57                   	push   %edi
  801664:	56                   	push   %esi
  801665:	53                   	push   %ebx
  801666:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801669:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80166c:	50                   	push   %eax
  80166d:	ff 75 08             	pushl  0x8(%ebp)
  801670:	e8 54 fe ff ff       	call   8014c9 <fd_lookup>
  801675:	89 c3                	mov    %eax,%ebx
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	85 c0                	test   %eax,%eax
  80167c:	0f 88 81 00 00 00    	js     801703 <dup+0xa7>
		return r;
	close(newfdnum);
  801682:	83 ec 0c             	sub    $0xc,%esp
  801685:	ff 75 0c             	pushl  0xc(%ebp)
  801688:	e8 75 ff ff ff       	call   801602 <close>

	newfd = INDEX2FD(newfdnum);
  80168d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801690:	c1 e6 0c             	shl    $0xc,%esi
  801693:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801699:	83 c4 04             	add    $0x4,%esp
  80169c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80169f:	e8 b4 fd ff ff       	call   801458 <fd2data>
  8016a4:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016a6:	89 34 24             	mov    %esi,(%esp)
  8016a9:	e8 aa fd ff ff       	call   801458 <fd2data>
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016b3:	89 d8                	mov    %ebx,%eax
  8016b5:	c1 e8 16             	shr    $0x16,%eax
  8016b8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016bf:	a8 01                	test   $0x1,%al
  8016c1:	74 11                	je     8016d4 <dup+0x78>
  8016c3:	89 d8                	mov    %ebx,%eax
  8016c5:	c1 e8 0c             	shr    $0xc,%eax
  8016c8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016cf:	f6 c2 01             	test   $0x1,%dl
  8016d2:	75 39                	jne    80170d <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016d7:	89 d0                	mov    %edx,%eax
  8016d9:	c1 e8 0c             	shr    $0xc,%eax
  8016dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016e3:	83 ec 0c             	sub    $0xc,%esp
  8016e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8016eb:	50                   	push   %eax
  8016ec:	56                   	push   %esi
  8016ed:	6a 00                	push   $0x0
  8016ef:	52                   	push   %edx
  8016f0:	6a 00                	push   $0x0
  8016f2:	e8 dd fa ff ff       	call   8011d4 <sys_page_map>
  8016f7:	89 c3                	mov    %eax,%ebx
  8016f9:	83 c4 20             	add    $0x20,%esp
  8016fc:	85 c0                	test   %eax,%eax
  8016fe:	78 31                	js     801731 <dup+0xd5>
		goto err;

	return newfdnum;
  801700:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801703:	89 d8                	mov    %ebx,%eax
  801705:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801708:	5b                   	pop    %ebx
  801709:	5e                   	pop    %esi
  80170a:	5f                   	pop    %edi
  80170b:	5d                   	pop    %ebp
  80170c:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80170d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801714:	83 ec 0c             	sub    $0xc,%esp
  801717:	25 07 0e 00 00       	and    $0xe07,%eax
  80171c:	50                   	push   %eax
  80171d:	57                   	push   %edi
  80171e:	6a 00                	push   $0x0
  801720:	53                   	push   %ebx
  801721:	6a 00                	push   $0x0
  801723:	e8 ac fa ff ff       	call   8011d4 <sys_page_map>
  801728:	89 c3                	mov    %eax,%ebx
  80172a:	83 c4 20             	add    $0x20,%esp
  80172d:	85 c0                	test   %eax,%eax
  80172f:	79 a3                	jns    8016d4 <dup+0x78>
	sys_page_unmap(0, newfd);
  801731:	83 ec 08             	sub    $0x8,%esp
  801734:	56                   	push   %esi
  801735:	6a 00                	push   $0x0
  801737:	e8 de fa ff ff       	call   80121a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80173c:	83 c4 08             	add    $0x8,%esp
  80173f:	57                   	push   %edi
  801740:	6a 00                	push   $0x0
  801742:	e8 d3 fa ff ff       	call   80121a <sys_page_unmap>
	return r;
  801747:	83 c4 10             	add    $0x10,%esp
  80174a:	eb b7                	jmp    801703 <dup+0xa7>

0080174c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80174c:	f3 0f 1e fb          	endbr32 
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	53                   	push   %ebx
  801754:	83 ec 1c             	sub    $0x1c,%esp
  801757:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80175a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175d:	50                   	push   %eax
  80175e:	53                   	push   %ebx
  80175f:	e8 65 fd ff ff       	call   8014c9 <fd_lookup>
  801764:	83 c4 10             	add    $0x10,%esp
  801767:	85 c0                	test   %eax,%eax
  801769:	78 3f                	js     8017aa <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176b:	83 ec 08             	sub    $0x8,%esp
  80176e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801771:	50                   	push   %eax
  801772:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801775:	ff 30                	pushl  (%eax)
  801777:	e8 a1 fd ff ff       	call   80151d <dev_lookup>
  80177c:	83 c4 10             	add    $0x10,%esp
  80177f:	85 c0                	test   %eax,%eax
  801781:	78 27                	js     8017aa <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801783:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801786:	8b 42 08             	mov    0x8(%edx),%eax
  801789:	83 e0 03             	and    $0x3,%eax
  80178c:	83 f8 01             	cmp    $0x1,%eax
  80178f:	74 1e                	je     8017af <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801791:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801794:	8b 40 08             	mov    0x8(%eax),%eax
  801797:	85 c0                	test   %eax,%eax
  801799:	74 35                	je     8017d0 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80179b:	83 ec 04             	sub    $0x4,%esp
  80179e:	ff 75 10             	pushl  0x10(%ebp)
  8017a1:	ff 75 0c             	pushl  0xc(%ebp)
  8017a4:	52                   	push   %edx
  8017a5:	ff d0                	call   *%eax
  8017a7:	83 c4 10             	add    $0x10,%esp
}
  8017aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ad:	c9                   	leave  
  8017ae:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017af:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8017b4:	8b 40 48             	mov    0x48(%eax),%eax
  8017b7:	83 ec 04             	sub    $0x4,%esp
  8017ba:	53                   	push   %ebx
  8017bb:	50                   	push   %eax
  8017bc:	68 0d 2a 80 00       	push   $0x802a0d
  8017c1:	e8 7c ef ff ff       	call   800742 <cprintf>
		return -E_INVAL;
  8017c6:	83 c4 10             	add    $0x10,%esp
  8017c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017ce:	eb da                	jmp    8017aa <read+0x5e>
		return -E_NOT_SUPP;
  8017d0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017d5:	eb d3                	jmp    8017aa <read+0x5e>

008017d7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017d7:	f3 0f 1e fb          	endbr32 
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	57                   	push   %edi
  8017df:	56                   	push   %esi
  8017e0:	53                   	push   %ebx
  8017e1:	83 ec 0c             	sub    $0xc,%esp
  8017e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017e7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017ef:	eb 02                	jmp    8017f3 <readn+0x1c>
  8017f1:	01 c3                	add    %eax,%ebx
  8017f3:	39 f3                	cmp    %esi,%ebx
  8017f5:	73 21                	jae    801818 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017f7:	83 ec 04             	sub    $0x4,%esp
  8017fa:	89 f0                	mov    %esi,%eax
  8017fc:	29 d8                	sub    %ebx,%eax
  8017fe:	50                   	push   %eax
  8017ff:	89 d8                	mov    %ebx,%eax
  801801:	03 45 0c             	add    0xc(%ebp),%eax
  801804:	50                   	push   %eax
  801805:	57                   	push   %edi
  801806:	e8 41 ff ff ff       	call   80174c <read>
		if (m < 0)
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	85 c0                	test   %eax,%eax
  801810:	78 04                	js     801816 <readn+0x3f>
			return m;
		if (m == 0)
  801812:	75 dd                	jne    8017f1 <readn+0x1a>
  801814:	eb 02                	jmp    801818 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801816:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801818:	89 d8                	mov    %ebx,%eax
  80181a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80181d:	5b                   	pop    %ebx
  80181e:	5e                   	pop    %esi
  80181f:	5f                   	pop    %edi
  801820:	5d                   	pop    %ebp
  801821:	c3                   	ret    

00801822 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801822:	f3 0f 1e fb          	endbr32 
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	53                   	push   %ebx
  80182a:	83 ec 1c             	sub    $0x1c,%esp
  80182d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801830:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801833:	50                   	push   %eax
  801834:	53                   	push   %ebx
  801835:	e8 8f fc ff ff       	call   8014c9 <fd_lookup>
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	85 c0                	test   %eax,%eax
  80183f:	78 3a                	js     80187b <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801841:	83 ec 08             	sub    $0x8,%esp
  801844:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801847:	50                   	push   %eax
  801848:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184b:	ff 30                	pushl  (%eax)
  80184d:	e8 cb fc ff ff       	call   80151d <dev_lookup>
  801852:	83 c4 10             	add    $0x10,%esp
  801855:	85 c0                	test   %eax,%eax
  801857:	78 22                	js     80187b <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801859:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801860:	74 1e                	je     801880 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801862:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801865:	8b 52 0c             	mov    0xc(%edx),%edx
  801868:	85 d2                	test   %edx,%edx
  80186a:	74 35                	je     8018a1 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80186c:	83 ec 04             	sub    $0x4,%esp
  80186f:	ff 75 10             	pushl  0x10(%ebp)
  801872:	ff 75 0c             	pushl  0xc(%ebp)
  801875:	50                   	push   %eax
  801876:	ff d2                	call   *%edx
  801878:	83 c4 10             	add    $0x10,%esp
}
  80187b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801880:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801885:	8b 40 48             	mov    0x48(%eax),%eax
  801888:	83 ec 04             	sub    $0x4,%esp
  80188b:	53                   	push   %ebx
  80188c:	50                   	push   %eax
  80188d:	68 29 2a 80 00       	push   $0x802a29
  801892:	e8 ab ee ff ff       	call   800742 <cprintf>
		return -E_INVAL;
  801897:	83 c4 10             	add    $0x10,%esp
  80189a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80189f:	eb da                	jmp    80187b <write+0x59>
		return -E_NOT_SUPP;
  8018a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018a6:	eb d3                	jmp    80187b <write+0x59>

008018a8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018a8:	f3 0f 1e fb          	endbr32 
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b5:	50                   	push   %eax
  8018b6:	ff 75 08             	pushl  0x8(%ebp)
  8018b9:	e8 0b fc ff ff       	call   8014c9 <fd_lookup>
  8018be:	83 c4 10             	add    $0x10,%esp
  8018c1:	85 c0                	test   %eax,%eax
  8018c3:	78 0e                	js     8018d3 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8018c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018cb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d3:	c9                   	leave  
  8018d4:	c3                   	ret    

008018d5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018d5:	f3 0f 1e fb          	endbr32 
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
  8018dc:	53                   	push   %ebx
  8018dd:	83 ec 1c             	sub    $0x1c,%esp
  8018e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e6:	50                   	push   %eax
  8018e7:	53                   	push   %ebx
  8018e8:	e8 dc fb ff ff       	call   8014c9 <fd_lookup>
  8018ed:	83 c4 10             	add    $0x10,%esp
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	78 37                	js     80192b <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f4:	83 ec 08             	sub    $0x8,%esp
  8018f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018fa:	50                   	push   %eax
  8018fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fe:	ff 30                	pushl  (%eax)
  801900:	e8 18 fc ff ff       	call   80151d <dev_lookup>
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	85 c0                	test   %eax,%eax
  80190a:	78 1f                	js     80192b <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80190c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801913:	74 1b                	je     801930 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801915:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801918:	8b 52 18             	mov    0x18(%edx),%edx
  80191b:	85 d2                	test   %edx,%edx
  80191d:	74 32                	je     801951 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80191f:	83 ec 08             	sub    $0x8,%esp
  801922:	ff 75 0c             	pushl  0xc(%ebp)
  801925:	50                   	push   %eax
  801926:	ff d2                	call   *%edx
  801928:	83 c4 10             	add    $0x10,%esp
}
  80192b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192e:	c9                   	leave  
  80192f:	c3                   	ret    
			thisenv->env_id, fdnum);
  801930:	a1 b0 40 80 00       	mov    0x8040b0,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801935:	8b 40 48             	mov    0x48(%eax),%eax
  801938:	83 ec 04             	sub    $0x4,%esp
  80193b:	53                   	push   %ebx
  80193c:	50                   	push   %eax
  80193d:	68 ec 29 80 00       	push   $0x8029ec
  801942:	e8 fb ed ff ff       	call   800742 <cprintf>
		return -E_INVAL;
  801947:	83 c4 10             	add    $0x10,%esp
  80194a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80194f:	eb da                	jmp    80192b <ftruncate+0x56>
		return -E_NOT_SUPP;
  801951:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801956:	eb d3                	jmp    80192b <ftruncate+0x56>

00801958 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801958:	f3 0f 1e fb          	endbr32 
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	53                   	push   %ebx
  801960:	83 ec 1c             	sub    $0x1c,%esp
  801963:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801966:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801969:	50                   	push   %eax
  80196a:	ff 75 08             	pushl  0x8(%ebp)
  80196d:	e8 57 fb ff ff       	call   8014c9 <fd_lookup>
  801972:	83 c4 10             	add    $0x10,%esp
  801975:	85 c0                	test   %eax,%eax
  801977:	78 4b                	js     8019c4 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801979:	83 ec 08             	sub    $0x8,%esp
  80197c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197f:	50                   	push   %eax
  801980:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801983:	ff 30                	pushl  (%eax)
  801985:	e8 93 fb ff ff       	call   80151d <dev_lookup>
  80198a:	83 c4 10             	add    $0x10,%esp
  80198d:	85 c0                	test   %eax,%eax
  80198f:	78 33                	js     8019c4 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801991:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801994:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801998:	74 2f                	je     8019c9 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80199a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80199d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019a4:	00 00 00 
	stat->st_isdir = 0;
  8019a7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019ae:	00 00 00 
	stat->st_dev = dev;
  8019b1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019b7:	83 ec 08             	sub    $0x8,%esp
  8019ba:	53                   	push   %ebx
  8019bb:	ff 75 f0             	pushl  -0x10(%ebp)
  8019be:	ff 50 14             	call   *0x14(%eax)
  8019c1:	83 c4 10             	add    $0x10,%esp
}
  8019c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c7:	c9                   	leave  
  8019c8:	c3                   	ret    
		return -E_NOT_SUPP;
  8019c9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019ce:	eb f4                	jmp    8019c4 <fstat+0x6c>

008019d0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019d0:	f3 0f 1e fb          	endbr32 
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	56                   	push   %esi
  8019d8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019d9:	83 ec 08             	sub    $0x8,%esp
  8019dc:	6a 00                	push   $0x0
  8019de:	ff 75 08             	pushl  0x8(%ebp)
  8019e1:	e8 cf 01 00 00       	call   801bb5 <open>
  8019e6:	89 c3                	mov    %eax,%ebx
  8019e8:	83 c4 10             	add    $0x10,%esp
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	78 1b                	js     801a0a <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8019ef:	83 ec 08             	sub    $0x8,%esp
  8019f2:	ff 75 0c             	pushl  0xc(%ebp)
  8019f5:	50                   	push   %eax
  8019f6:	e8 5d ff ff ff       	call   801958 <fstat>
  8019fb:	89 c6                	mov    %eax,%esi
	close(fd);
  8019fd:	89 1c 24             	mov    %ebx,(%esp)
  801a00:	e8 fd fb ff ff       	call   801602 <close>
	return r;
  801a05:	83 c4 10             	add    $0x10,%esp
  801a08:	89 f3                	mov    %esi,%ebx
}
  801a0a:	89 d8                	mov    %ebx,%eax
  801a0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0f:	5b                   	pop    %ebx
  801a10:	5e                   	pop    %esi
  801a11:	5d                   	pop    %ebp
  801a12:	c3                   	ret    

00801a13 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	56                   	push   %esi
  801a17:	53                   	push   %ebx
  801a18:	89 c6                	mov    %eax,%esi
  801a1a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a1c:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  801a23:	74 27                	je     801a4c <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a25:	6a 07                	push   $0x7
  801a27:	68 00 50 80 00       	push   $0x805000
  801a2c:	56                   	push   %esi
  801a2d:	ff 35 ac 40 80 00    	pushl  0x8040ac
  801a33:	e8 7c 07 00 00       	call   8021b4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a38:	83 c4 0c             	add    $0xc,%esp
  801a3b:	6a 00                	push   $0x0
  801a3d:	53                   	push   %ebx
  801a3e:	6a 00                	push   $0x0
  801a40:	e8 18 07 00 00       	call   80215d <ipc_recv>
}
  801a45:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a48:	5b                   	pop    %ebx
  801a49:	5e                   	pop    %esi
  801a4a:	5d                   	pop    %ebp
  801a4b:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a4c:	83 ec 0c             	sub    $0xc,%esp
  801a4f:	6a 01                	push   $0x1
  801a51:	e8 c4 07 00 00       	call   80221a <ipc_find_env>
  801a56:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	eb c5                	jmp    801a25 <fsipc+0x12>

00801a60 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a60:	f3 0f 1e fb          	endbr32 
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a70:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a75:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a78:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a7d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a82:	b8 02 00 00 00       	mov    $0x2,%eax
  801a87:	e8 87 ff ff ff       	call   801a13 <fsipc>
}
  801a8c:	c9                   	leave  
  801a8d:	c3                   	ret    

00801a8e <devfile_flush>:
{
  801a8e:	f3 0f 1e fb          	endbr32 
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a98:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a9e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801aa3:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa8:	b8 06 00 00 00       	mov    $0x6,%eax
  801aad:	e8 61 ff ff ff       	call   801a13 <fsipc>
}
  801ab2:	c9                   	leave  
  801ab3:	c3                   	ret    

00801ab4 <devfile_stat>:
{
  801ab4:	f3 0f 1e fb          	endbr32 
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	53                   	push   %ebx
  801abc:	83 ec 04             	sub    $0x4,%esp
  801abf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac5:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801acd:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad2:	b8 05 00 00 00       	mov    $0x5,%eax
  801ad7:	e8 37 ff ff ff       	call   801a13 <fsipc>
  801adc:	85 c0                	test   %eax,%eax
  801ade:	78 2c                	js     801b0c <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ae0:	83 ec 08             	sub    $0x8,%esp
  801ae3:	68 00 50 80 00       	push   $0x805000
  801ae8:	53                   	push   %ebx
  801ae9:	e8 5d f2 ff ff       	call   800d4b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801aee:	a1 80 50 80 00       	mov    0x805080,%eax
  801af3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801af9:	a1 84 50 80 00       	mov    0x805084,%eax
  801afe:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b04:	83 c4 10             	add    $0x10,%esp
  801b07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0f:	c9                   	leave  
  801b10:	c3                   	ret    

00801b11 <devfile_write>:
{
  801b11:	f3 0f 1e fb          	endbr32 
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	83 ec 0c             	sub    $0xc,%esp
	panic("devfile_write not implemented");
  801b1b:	68 58 2a 80 00       	push   $0x802a58
  801b20:	68 90 00 00 00       	push   $0x90
  801b25:	68 76 2a 80 00       	push   $0x802a76
  801b2a:	e8 2c eb ff ff       	call   80065b <_panic>

00801b2f <devfile_read>:
{
  801b2f:	f3 0f 1e fb          	endbr32 
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	56                   	push   %esi
  801b37:	53                   	push   %ebx
  801b38:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3e:	8b 40 0c             	mov    0xc(%eax),%eax
  801b41:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b46:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b4c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b51:	b8 03 00 00 00       	mov    $0x3,%eax
  801b56:	e8 b8 fe ff ff       	call   801a13 <fsipc>
  801b5b:	89 c3                	mov    %eax,%ebx
  801b5d:	85 c0                	test   %eax,%eax
  801b5f:	78 1f                	js     801b80 <devfile_read+0x51>
	assert(r <= n);
  801b61:	39 f0                	cmp    %esi,%eax
  801b63:	77 24                	ja     801b89 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801b65:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b6a:	7f 33                	jg     801b9f <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b6c:	83 ec 04             	sub    $0x4,%esp
  801b6f:	50                   	push   %eax
  801b70:	68 00 50 80 00       	push   $0x805000
  801b75:	ff 75 0c             	pushl  0xc(%ebp)
  801b78:	e8 84 f3 ff ff       	call   800f01 <memmove>
	return r;
  801b7d:	83 c4 10             	add    $0x10,%esp
}
  801b80:	89 d8                	mov    %ebx,%eax
  801b82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b85:	5b                   	pop    %ebx
  801b86:	5e                   	pop    %esi
  801b87:	5d                   	pop    %ebp
  801b88:	c3                   	ret    
	assert(r <= n);
  801b89:	68 81 2a 80 00       	push   $0x802a81
  801b8e:	68 88 2a 80 00       	push   $0x802a88
  801b93:	6a 7c                	push   $0x7c
  801b95:	68 76 2a 80 00       	push   $0x802a76
  801b9a:	e8 bc ea ff ff       	call   80065b <_panic>
	assert(r <= PGSIZE);
  801b9f:	68 9d 2a 80 00       	push   $0x802a9d
  801ba4:	68 88 2a 80 00       	push   $0x802a88
  801ba9:	6a 7d                	push   $0x7d
  801bab:	68 76 2a 80 00       	push   $0x802a76
  801bb0:	e8 a6 ea ff ff       	call   80065b <_panic>

00801bb5 <open>:
{
  801bb5:	f3 0f 1e fb          	endbr32 
  801bb9:	55                   	push   %ebp
  801bba:	89 e5                	mov    %esp,%ebp
  801bbc:	56                   	push   %esi
  801bbd:	53                   	push   %ebx
  801bbe:	83 ec 1c             	sub    $0x1c,%esp
  801bc1:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801bc4:	56                   	push   %esi
  801bc5:	e8 3e f1 ff ff       	call   800d08 <strlen>
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bd2:	7f 6c                	jg     801c40 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801bd4:	83 ec 0c             	sub    $0xc,%esp
  801bd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bda:	50                   	push   %eax
  801bdb:	e8 93 f8 ff ff       	call   801473 <fd_alloc>
  801be0:	89 c3                	mov    %eax,%ebx
  801be2:	83 c4 10             	add    $0x10,%esp
  801be5:	85 c0                	test   %eax,%eax
  801be7:	78 3c                	js     801c25 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801be9:	83 ec 08             	sub    $0x8,%esp
  801bec:	56                   	push   %esi
  801bed:	68 00 50 80 00       	push   $0x805000
  801bf2:	e8 54 f1 ff ff       	call   800d4b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bf7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bfa:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c02:	b8 01 00 00 00       	mov    $0x1,%eax
  801c07:	e8 07 fe ff ff       	call   801a13 <fsipc>
  801c0c:	89 c3                	mov    %eax,%ebx
  801c0e:	83 c4 10             	add    $0x10,%esp
  801c11:	85 c0                	test   %eax,%eax
  801c13:	78 19                	js     801c2e <open+0x79>
	return fd2num(fd);
  801c15:	83 ec 0c             	sub    $0xc,%esp
  801c18:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1b:	e8 24 f8 ff ff       	call   801444 <fd2num>
  801c20:	89 c3                	mov    %eax,%ebx
  801c22:	83 c4 10             	add    $0x10,%esp
}
  801c25:	89 d8                	mov    %ebx,%eax
  801c27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c2a:	5b                   	pop    %ebx
  801c2b:	5e                   	pop    %esi
  801c2c:	5d                   	pop    %ebp
  801c2d:	c3                   	ret    
		fd_close(fd, 0);
  801c2e:	83 ec 08             	sub    $0x8,%esp
  801c31:	6a 00                	push   $0x0
  801c33:	ff 75 f4             	pushl  -0xc(%ebp)
  801c36:	e8 3c f9 ff ff       	call   801577 <fd_close>
		return r;
  801c3b:	83 c4 10             	add    $0x10,%esp
  801c3e:	eb e5                	jmp    801c25 <open+0x70>
		return -E_BAD_PATH;
  801c40:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801c45:	eb de                	jmp    801c25 <open+0x70>

00801c47 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c47:	f3 0f 1e fb          	endbr32 
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c51:	ba 00 00 00 00       	mov    $0x0,%edx
  801c56:	b8 08 00 00 00       	mov    $0x8,%eax
  801c5b:	e8 b3 fd ff ff       	call   801a13 <fsipc>
}
  801c60:	c9                   	leave  
  801c61:	c3                   	ret    

00801c62 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c62:	f3 0f 1e fb          	endbr32 
  801c66:	55                   	push   %ebp
  801c67:	89 e5                	mov    %esp,%ebp
  801c69:	56                   	push   %esi
  801c6a:	53                   	push   %ebx
  801c6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c6e:	83 ec 0c             	sub    $0xc,%esp
  801c71:	ff 75 08             	pushl  0x8(%ebp)
  801c74:	e8 df f7 ff ff       	call   801458 <fd2data>
  801c79:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c7b:	83 c4 08             	add    $0x8,%esp
  801c7e:	68 a9 2a 80 00       	push   $0x802aa9
  801c83:	53                   	push   %ebx
  801c84:	e8 c2 f0 ff ff       	call   800d4b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c89:	8b 46 04             	mov    0x4(%esi),%eax
  801c8c:	2b 06                	sub    (%esi),%eax
  801c8e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c94:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c9b:	00 00 00 
	stat->st_dev = &devpipe;
  801c9e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ca5:	30 80 00 
	return 0;
}
  801ca8:	b8 00 00 00 00       	mov    $0x0,%eax
  801cad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb0:	5b                   	pop    %ebx
  801cb1:	5e                   	pop    %esi
  801cb2:	5d                   	pop    %ebp
  801cb3:	c3                   	ret    

00801cb4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cb4:	f3 0f 1e fb          	endbr32 
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	53                   	push   %ebx
  801cbc:	83 ec 0c             	sub    $0xc,%esp
  801cbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cc2:	53                   	push   %ebx
  801cc3:	6a 00                	push   $0x0
  801cc5:	e8 50 f5 ff ff       	call   80121a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cca:	89 1c 24             	mov    %ebx,(%esp)
  801ccd:	e8 86 f7 ff ff       	call   801458 <fd2data>
  801cd2:	83 c4 08             	add    $0x8,%esp
  801cd5:	50                   	push   %eax
  801cd6:	6a 00                	push   $0x0
  801cd8:	e8 3d f5 ff ff       	call   80121a <sys_page_unmap>
}
  801cdd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ce0:	c9                   	leave  
  801ce1:	c3                   	ret    

00801ce2 <_pipeisclosed>:
{
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	57                   	push   %edi
  801ce6:	56                   	push   %esi
  801ce7:	53                   	push   %ebx
  801ce8:	83 ec 1c             	sub    $0x1c,%esp
  801ceb:	89 c7                	mov    %eax,%edi
  801ced:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801cef:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801cf4:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cf7:	83 ec 0c             	sub    $0xc,%esp
  801cfa:	57                   	push   %edi
  801cfb:	e8 57 05 00 00       	call   802257 <pageref>
  801d00:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d03:	89 34 24             	mov    %esi,(%esp)
  801d06:	e8 4c 05 00 00       	call   802257 <pageref>
		nn = thisenv->env_runs;
  801d0b:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801d11:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d14:	83 c4 10             	add    $0x10,%esp
  801d17:	39 cb                	cmp    %ecx,%ebx
  801d19:	74 1b                	je     801d36 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801d1b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d1e:	75 cf                	jne    801cef <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d20:	8b 42 58             	mov    0x58(%edx),%eax
  801d23:	6a 01                	push   $0x1
  801d25:	50                   	push   %eax
  801d26:	53                   	push   %ebx
  801d27:	68 b0 2a 80 00       	push   $0x802ab0
  801d2c:	e8 11 ea ff ff       	call   800742 <cprintf>
  801d31:	83 c4 10             	add    $0x10,%esp
  801d34:	eb b9                	jmp    801cef <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801d36:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d39:	0f 94 c0             	sete   %al
  801d3c:	0f b6 c0             	movzbl %al,%eax
}
  801d3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d42:	5b                   	pop    %ebx
  801d43:	5e                   	pop    %esi
  801d44:	5f                   	pop    %edi
  801d45:	5d                   	pop    %ebp
  801d46:	c3                   	ret    

00801d47 <devpipe_write>:
{
  801d47:	f3 0f 1e fb          	endbr32 
  801d4b:	55                   	push   %ebp
  801d4c:	89 e5                	mov    %esp,%ebp
  801d4e:	57                   	push   %edi
  801d4f:	56                   	push   %esi
  801d50:	53                   	push   %ebx
  801d51:	83 ec 28             	sub    $0x28,%esp
  801d54:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d57:	56                   	push   %esi
  801d58:	e8 fb f6 ff ff       	call   801458 <fd2data>
  801d5d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d5f:	83 c4 10             	add    $0x10,%esp
  801d62:	bf 00 00 00 00       	mov    $0x0,%edi
  801d67:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d6a:	74 4f                	je     801dbb <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d6c:	8b 43 04             	mov    0x4(%ebx),%eax
  801d6f:	8b 0b                	mov    (%ebx),%ecx
  801d71:	8d 51 20             	lea    0x20(%ecx),%edx
  801d74:	39 d0                	cmp    %edx,%eax
  801d76:	72 14                	jb     801d8c <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801d78:	89 da                	mov    %ebx,%edx
  801d7a:	89 f0                	mov    %esi,%eax
  801d7c:	e8 61 ff ff ff       	call   801ce2 <_pipeisclosed>
  801d81:	85 c0                	test   %eax,%eax
  801d83:	75 3b                	jne    801dc0 <devpipe_write+0x79>
			sys_yield();
  801d85:	e8 e0 f3 ff ff       	call   80116a <sys_yield>
  801d8a:	eb e0                	jmp    801d6c <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d8f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d93:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d96:	89 c2                	mov    %eax,%edx
  801d98:	c1 fa 1f             	sar    $0x1f,%edx
  801d9b:	89 d1                	mov    %edx,%ecx
  801d9d:	c1 e9 1b             	shr    $0x1b,%ecx
  801da0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801da3:	83 e2 1f             	and    $0x1f,%edx
  801da6:	29 ca                	sub    %ecx,%edx
  801da8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801dac:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801db0:	83 c0 01             	add    $0x1,%eax
  801db3:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801db6:	83 c7 01             	add    $0x1,%edi
  801db9:	eb ac                	jmp    801d67 <devpipe_write+0x20>
	return i;
  801dbb:	8b 45 10             	mov    0x10(%ebp),%eax
  801dbe:	eb 05                	jmp    801dc5 <devpipe_write+0x7e>
				return 0;
  801dc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc8:	5b                   	pop    %ebx
  801dc9:	5e                   	pop    %esi
  801dca:	5f                   	pop    %edi
  801dcb:	5d                   	pop    %ebp
  801dcc:	c3                   	ret    

00801dcd <devpipe_read>:
{
  801dcd:	f3 0f 1e fb          	endbr32 
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	57                   	push   %edi
  801dd5:	56                   	push   %esi
  801dd6:	53                   	push   %ebx
  801dd7:	83 ec 18             	sub    $0x18,%esp
  801dda:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801ddd:	57                   	push   %edi
  801dde:	e8 75 f6 ff ff       	call   801458 <fd2data>
  801de3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801de5:	83 c4 10             	add    $0x10,%esp
  801de8:	be 00 00 00 00       	mov    $0x0,%esi
  801ded:	3b 75 10             	cmp    0x10(%ebp),%esi
  801df0:	75 14                	jne    801e06 <devpipe_read+0x39>
	return i;
  801df2:	8b 45 10             	mov    0x10(%ebp),%eax
  801df5:	eb 02                	jmp    801df9 <devpipe_read+0x2c>
				return i;
  801df7:	89 f0                	mov    %esi,%eax
}
  801df9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dfc:	5b                   	pop    %ebx
  801dfd:	5e                   	pop    %esi
  801dfe:	5f                   	pop    %edi
  801dff:	5d                   	pop    %ebp
  801e00:	c3                   	ret    
			sys_yield();
  801e01:	e8 64 f3 ff ff       	call   80116a <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801e06:	8b 03                	mov    (%ebx),%eax
  801e08:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e0b:	75 18                	jne    801e25 <devpipe_read+0x58>
			if (i > 0)
  801e0d:	85 f6                	test   %esi,%esi
  801e0f:	75 e6                	jne    801df7 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801e11:	89 da                	mov    %ebx,%edx
  801e13:	89 f8                	mov    %edi,%eax
  801e15:	e8 c8 fe ff ff       	call   801ce2 <_pipeisclosed>
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	74 e3                	je     801e01 <devpipe_read+0x34>
				return 0;
  801e1e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e23:	eb d4                	jmp    801df9 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e25:	99                   	cltd   
  801e26:	c1 ea 1b             	shr    $0x1b,%edx
  801e29:	01 d0                	add    %edx,%eax
  801e2b:	83 e0 1f             	and    $0x1f,%eax
  801e2e:	29 d0                	sub    %edx,%eax
  801e30:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e38:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e3b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e3e:	83 c6 01             	add    $0x1,%esi
  801e41:	eb aa                	jmp    801ded <devpipe_read+0x20>

00801e43 <pipe>:
{
  801e43:	f3 0f 1e fb          	endbr32 
  801e47:	55                   	push   %ebp
  801e48:	89 e5                	mov    %esp,%ebp
  801e4a:	56                   	push   %esi
  801e4b:	53                   	push   %ebx
  801e4c:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e52:	50                   	push   %eax
  801e53:	e8 1b f6 ff ff       	call   801473 <fd_alloc>
  801e58:	89 c3                	mov    %eax,%ebx
  801e5a:	83 c4 10             	add    $0x10,%esp
  801e5d:	85 c0                	test   %eax,%eax
  801e5f:	0f 88 23 01 00 00    	js     801f88 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e65:	83 ec 04             	sub    $0x4,%esp
  801e68:	68 07 04 00 00       	push   $0x407
  801e6d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e70:	6a 00                	push   $0x0
  801e72:	e8 16 f3 ff ff       	call   80118d <sys_page_alloc>
  801e77:	89 c3                	mov    %eax,%ebx
  801e79:	83 c4 10             	add    $0x10,%esp
  801e7c:	85 c0                	test   %eax,%eax
  801e7e:	0f 88 04 01 00 00    	js     801f88 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801e84:	83 ec 0c             	sub    $0xc,%esp
  801e87:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e8a:	50                   	push   %eax
  801e8b:	e8 e3 f5 ff ff       	call   801473 <fd_alloc>
  801e90:	89 c3                	mov    %eax,%ebx
  801e92:	83 c4 10             	add    $0x10,%esp
  801e95:	85 c0                	test   %eax,%eax
  801e97:	0f 88 db 00 00 00    	js     801f78 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e9d:	83 ec 04             	sub    $0x4,%esp
  801ea0:	68 07 04 00 00       	push   $0x407
  801ea5:	ff 75 f0             	pushl  -0x10(%ebp)
  801ea8:	6a 00                	push   $0x0
  801eaa:	e8 de f2 ff ff       	call   80118d <sys_page_alloc>
  801eaf:	89 c3                	mov    %eax,%ebx
  801eb1:	83 c4 10             	add    $0x10,%esp
  801eb4:	85 c0                	test   %eax,%eax
  801eb6:	0f 88 bc 00 00 00    	js     801f78 <pipe+0x135>
	va = fd2data(fd0);
  801ebc:	83 ec 0c             	sub    $0xc,%esp
  801ebf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec2:	e8 91 f5 ff ff       	call   801458 <fd2data>
  801ec7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec9:	83 c4 0c             	add    $0xc,%esp
  801ecc:	68 07 04 00 00       	push   $0x407
  801ed1:	50                   	push   %eax
  801ed2:	6a 00                	push   $0x0
  801ed4:	e8 b4 f2 ff ff       	call   80118d <sys_page_alloc>
  801ed9:	89 c3                	mov    %eax,%ebx
  801edb:	83 c4 10             	add    $0x10,%esp
  801ede:	85 c0                	test   %eax,%eax
  801ee0:	0f 88 82 00 00 00    	js     801f68 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ee6:	83 ec 0c             	sub    $0xc,%esp
  801ee9:	ff 75 f0             	pushl  -0x10(%ebp)
  801eec:	e8 67 f5 ff ff       	call   801458 <fd2data>
  801ef1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ef8:	50                   	push   %eax
  801ef9:	6a 00                	push   $0x0
  801efb:	56                   	push   %esi
  801efc:	6a 00                	push   $0x0
  801efe:	e8 d1 f2 ff ff       	call   8011d4 <sys_page_map>
  801f03:	89 c3                	mov    %eax,%ebx
  801f05:	83 c4 20             	add    $0x20,%esp
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	78 4e                	js     801f5a <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801f0c:	a1 20 30 80 00       	mov    0x803020,%eax
  801f11:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f14:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801f16:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f19:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801f20:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f23:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801f25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f28:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f2f:	83 ec 0c             	sub    $0xc,%esp
  801f32:	ff 75 f4             	pushl  -0xc(%ebp)
  801f35:	e8 0a f5 ff ff       	call   801444 <fd2num>
  801f3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f3d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f3f:	83 c4 04             	add    $0x4,%esp
  801f42:	ff 75 f0             	pushl  -0x10(%ebp)
  801f45:	e8 fa f4 ff ff       	call   801444 <fd2num>
  801f4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f4d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f50:	83 c4 10             	add    $0x10,%esp
  801f53:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f58:	eb 2e                	jmp    801f88 <pipe+0x145>
	sys_page_unmap(0, va);
  801f5a:	83 ec 08             	sub    $0x8,%esp
  801f5d:	56                   	push   %esi
  801f5e:	6a 00                	push   $0x0
  801f60:	e8 b5 f2 ff ff       	call   80121a <sys_page_unmap>
  801f65:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801f68:	83 ec 08             	sub    $0x8,%esp
  801f6b:	ff 75 f0             	pushl  -0x10(%ebp)
  801f6e:	6a 00                	push   $0x0
  801f70:	e8 a5 f2 ff ff       	call   80121a <sys_page_unmap>
  801f75:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801f78:	83 ec 08             	sub    $0x8,%esp
  801f7b:	ff 75 f4             	pushl  -0xc(%ebp)
  801f7e:	6a 00                	push   $0x0
  801f80:	e8 95 f2 ff ff       	call   80121a <sys_page_unmap>
  801f85:	83 c4 10             	add    $0x10,%esp
}
  801f88:	89 d8                	mov    %ebx,%eax
  801f8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f8d:	5b                   	pop    %ebx
  801f8e:	5e                   	pop    %esi
  801f8f:	5d                   	pop    %ebp
  801f90:	c3                   	ret    

00801f91 <pipeisclosed>:
{
  801f91:	f3 0f 1e fb          	endbr32 
  801f95:	55                   	push   %ebp
  801f96:	89 e5                	mov    %esp,%ebp
  801f98:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f9e:	50                   	push   %eax
  801f9f:	ff 75 08             	pushl  0x8(%ebp)
  801fa2:	e8 22 f5 ff ff       	call   8014c9 <fd_lookup>
  801fa7:	83 c4 10             	add    $0x10,%esp
  801faa:	85 c0                	test   %eax,%eax
  801fac:	78 18                	js     801fc6 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801fae:	83 ec 0c             	sub    $0xc,%esp
  801fb1:	ff 75 f4             	pushl  -0xc(%ebp)
  801fb4:	e8 9f f4 ff ff       	call   801458 <fd2data>
  801fb9:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbe:	e8 1f fd ff ff       	call   801ce2 <_pipeisclosed>
  801fc3:	83 c4 10             	add    $0x10,%esp
}
  801fc6:	c9                   	leave  
  801fc7:	c3                   	ret    

00801fc8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fc8:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801fcc:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd1:	c3                   	ret    

00801fd2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fd2:	f3 0f 1e fb          	endbr32 
  801fd6:	55                   	push   %ebp
  801fd7:	89 e5                	mov    %esp,%ebp
  801fd9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fdc:	68 c8 2a 80 00       	push   $0x802ac8
  801fe1:	ff 75 0c             	pushl  0xc(%ebp)
  801fe4:	e8 62 ed ff ff       	call   800d4b <strcpy>
	return 0;
}
  801fe9:	b8 00 00 00 00       	mov    $0x0,%eax
  801fee:	c9                   	leave  
  801fef:	c3                   	ret    

00801ff0 <devcons_write>:
{
  801ff0:	f3 0f 1e fb          	endbr32 
  801ff4:	55                   	push   %ebp
  801ff5:	89 e5                	mov    %esp,%ebp
  801ff7:	57                   	push   %edi
  801ff8:	56                   	push   %esi
  801ff9:	53                   	push   %ebx
  801ffa:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802000:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802005:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80200b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80200e:	73 31                	jae    802041 <devcons_write+0x51>
		m = n - tot;
  802010:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802013:	29 f3                	sub    %esi,%ebx
  802015:	83 fb 7f             	cmp    $0x7f,%ebx
  802018:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80201d:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802020:	83 ec 04             	sub    $0x4,%esp
  802023:	53                   	push   %ebx
  802024:	89 f0                	mov    %esi,%eax
  802026:	03 45 0c             	add    0xc(%ebp),%eax
  802029:	50                   	push   %eax
  80202a:	57                   	push   %edi
  80202b:	e8 d1 ee ff ff       	call   800f01 <memmove>
		sys_cputs(buf, m);
  802030:	83 c4 08             	add    $0x8,%esp
  802033:	53                   	push   %ebx
  802034:	57                   	push   %edi
  802035:	e8 83 f0 ff ff       	call   8010bd <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80203a:	01 de                	add    %ebx,%esi
  80203c:	83 c4 10             	add    $0x10,%esp
  80203f:	eb ca                	jmp    80200b <devcons_write+0x1b>
}
  802041:	89 f0                	mov    %esi,%eax
  802043:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802046:	5b                   	pop    %ebx
  802047:	5e                   	pop    %esi
  802048:	5f                   	pop    %edi
  802049:	5d                   	pop    %ebp
  80204a:	c3                   	ret    

0080204b <devcons_read>:
{
  80204b:	f3 0f 1e fb          	endbr32 
  80204f:	55                   	push   %ebp
  802050:	89 e5                	mov    %esp,%ebp
  802052:	83 ec 08             	sub    $0x8,%esp
  802055:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80205a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80205e:	74 21                	je     802081 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  802060:	e8 7a f0 ff ff       	call   8010df <sys_cgetc>
  802065:	85 c0                	test   %eax,%eax
  802067:	75 07                	jne    802070 <devcons_read+0x25>
		sys_yield();
  802069:	e8 fc f0 ff ff       	call   80116a <sys_yield>
  80206e:	eb f0                	jmp    802060 <devcons_read+0x15>
	if (c < 0)
  802070:	78 0f                	js     802081 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  802072:	83 f8 04             	cmp    $0x4,%eax
  802075:	74 0c                	je     802083 <devcons_read+0x38>
	*(char*)vbuf = c;
  802077:	8b 55 0c             	mov    0xc(%ebp),%edx
  80207a:	88 02                	mov    %al,(%edx)
	return 1;
  80207c:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802081:	c9                   	leave  
  802082:	c3                   	ret    
		return 0;
  802083:	b8 00 00 00 00       	mov    $0x0,%eax
  802088:	eb f7                	jmp    802081 <devcons_read+0x36>

0080208a <cputchar>:
{
  80208a:	f3 0f 1e fb          	endbr32 
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802094:	8b 45 08             	mov    0x8(%ebp),%eax
  802097:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80209a:	6a 01                	push   $0x1
  80209c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80209f:	50                   	push   %eax
  8020a0:	e8 18 f0 ff ff       	call   8010bd <sys_cputs>
}
  8020a5:	83 c4 10             	add    $0x10,%esp
  8020a8:	c9                   	leave  
  8020a9:	c3                   	ret    

008020aa <getchar>:
{
  8020aa:	f3 0f 1e fb          	endbr32 
  8020ae:	55                   	push   %ebp
  8020af:	89 e5                	mov    %esp,%ebp
  8020b1:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8020b4:	6a 01                	push   $0x1
  8020b6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020b9:	50                   	push   %eax
  8020ba:	6a 00                	push   $0x0
  8020bc:	e8 8b f6 ff ff       	call   80174c <read>
	if (r < 0)
  8020c1:	83 c4 10             	add    $0x10,%esp
  8020c4:	85 c0                	test   %eax,%eax
  8020c6:	78 06                	js     8020ce <getchar+0x24>
	if (r < 1)
  8020c8:	74 06                	je     8020d0 <getchar+0x26>
	return c;
  8020ca:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8020ce:	c9                   	leave  
  8020cf:	c3                   	ret    
		return -E_EOF;
  8020d0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8020d5:	eb f7                	jmp    8020ce <getchar+0x24>

008020d7 <iscons>:
{
  8020d7:	f3 0f 1e fb          	endbr32 
  8020db:	55                   	push   %ebp
  8020dc:	89 e5                	mov    %esp,%ebp
  8020de:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020e4:	50                   	push   %eax
  8020e5:	ff 75 08             	pushl  0x8(%ebp)
  8020e8:	e8 dc f3 ff ff       	call   8014c9 <fd_lookup>
  8020ed:	83 c4 10             	add    $0x10,%esp
  8020f0:	85 c0                	test   %eax,%eax
  8020f2:	78 11                	js     802105 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8020f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020fd:	39 10                	cmp    %edx,(%eax)
  8020ff:	0f 94 c0             	sete   %al
  802102:	0f b6 c0             	movzbl %al,%eax
}
  802105:	c9                   	leave  
  802106:	c3                   	ret    

00802107 <opencons>:
{
  802107:	f3 0f 1e fb          	endbr32 
  80210b:	55                   	push   %ebp
  80210c:	89 e5                	mov    %esp,%ebp
  80210e:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802111:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802114:	50                   	push   %eax
  802115:	e8 59 f3 ff ff       	call   801473 <fd_alloc>
  80211a:	83 c4 10             	add    $0x10,%esp
  80211d:	85 c0                	test   %eax,%eax
  80211f:	78 3a                	js     80215b <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802121:	83 ec 04             	sub    $0x4,%esp
  802124:	68 07 04 00 00       	push   $0x407
  802129:	ff 75 f4             	pushl  -0xc(%ebp)
  80212c:	6a 00                	push   $0x0
  80212e:	e8 5a f0 ff ff       	call   80118d <sys_page_alloc>
  802133:	83 c4 10             	add    $0x10,%esp
  802136:	85 c0                	test   %eax,%eax
  802138:	78 21                	js     80215b <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80213a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802143:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802145:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802148:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80214f:	83 ec 0c             	sub    $0xc,%esp
  802152:	50                   	push   %eax
  802153:	e8 ec f2 ff ff       	call   801444 <fd2num>
  802158:	83 c4 10             	add    $0x10,%esp
}
  80215b:	c9                   	leave  
  80215c:	c3                   	ret    

0080215d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80215d:	f3 0f 1e fb          	endbr32 
  802161:	55                   	push   %ebp
  802162:	89 e5                	mov    %esp,%ebp
  802164:	56                   	push   %esi
  802165:	53                   	push   %ebx
  802166:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802169:	8b 45 0c             	mov    0xc(%ebp),%eax
  80216c:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  80216f:	85 c0                	test   %eax,%eax
  802171:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  802176:	0f 44 c2             	cmove  %edx,%eax
  802179:	83 ec 0c             	sub    $0xc,%esp
  80217c:	50                   	push   %eax
  80217d:	e8 d7 f1 ff ff       	call   801359 <sys_ipc_recv>
  802182:	83 c4 10             	add    $0x10,%esp
  802185:	85 c0                	test   %eax,%eax
  802187:	78 24                	js     8021ad <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  802189:	85 f6                	test   %esi,%esi
  80218b:	74 0a                	je     802197 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  80218d:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802192:	8b 40 78             	mov    0x78(%eax),%eax
  802195:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  802197:	85 db                	test   %ebx,%ebx
  802199:	74 0a                	je     8021a5 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  80219b:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8021a0:	8b 40 74             	mov    0x74(%eax),%eax
  8021a3:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  8021a5:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8021aa:	8b 40 70             	mov    0x70(%eax),%eax
}
  8021ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021b0:	5b                   	pop    %ebx
  8021b1:	5e                   	pop    %esi
  8021b2:	5d                   	pop    %ebp
  8021b3:	c3                   	ret    

008021b4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021b4:	f3 0f 1e fb          	endbr32 
  8021b8:	55                   	push   %ebp
  8021b9:	89 e5                	mov    %esp,%ebp
  8021bb:	57                   	push   %edi
  8021bc:	56                   	push   %esi
  8021bd:	53                   	push   %ebx
  8021be:	83 ec 1c             	sub    $0x1c,%esp
  8021c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8021c4:	85 c0                	test   %eax,%eax
  8021c6:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8021cb:	0f 45 d0             	cmovne %eax,%edx
  8021ce:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  8021d0:	be 01 00 00 00       	mov    $0x1,%esi
  8021d5:	eb 1f                	jmp    8021f6 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  8021d7:	e8 8e ef ff ff       	call   80116a <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  8021dc:	83 c3 01             	add    $0x1,%ebx
  8021df:	39 de                	cmp    %ebx,%esi
  8021e1:	7f f4                	jg     8021d7 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  8021e3:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  8021e5:	83 fe 11             	cmp    $0x11,%esi
  8021e8:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ed:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  8021f0:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  8021f4:	75 1c                	jne    802212 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  8021f6:	ff 75 14             	pushl  0x14(%ebp)
  8021f9:	57                   	push   %edi
  8021fa:	ff 75 0c             	pushl  0xc(%ebp)
  8021fd:	ff 75 08             	pushl  0x8(%ebp)
  802200:	e8 2d f1 ff ff       	call   801332 <sys_ipc_try_send>
  802205:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  802208:	83 c4 10             	add    $0x10,%esp
  80220b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802210:	eb cd                	jmp    8021df <ipc_send+0x2b>
}
  802212:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802215:	5b                   	pop    %ebx
  802216:	5e                   	pop    %esi
  802217:	5f                   	pop    %edi
  802218:	5d                   	pop    %ebp
  802219:	c3                   	ret    

0080221a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80221a:	f3 0f 1e fb          	endbr32 
  80221e:	55                   	push   %ebp
  80221f:	89 e5                	mov    %esp,%ebp
  802221:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802224:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802229:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80222c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802232:	8b 52 50             	mov    0x50(%edx),%edx
  802235:	39 ca                	cmp    %ecx,%edx
  802237:	74 11                	je     80224a <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802239:	83 c0 01             	add    $0x1,%eax
  80223c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802241:	75 e6                	jne    802229 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802243:	b8 00 00 00 00       	mov    $0x0,%eax
  802248:	eb 0b                	jmp    802255 <ipc_find_env+0x3b>
			return envs[i].env_id;
  80224a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80224d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802252:	8b 40 48             	mov    0x48(%eax),%eax
}
  802255:	5d                   	pop    %ebp
  802256:	c3                   	ret    

00802257 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802257:	f3 0f 1e fb          	endbr32 
  80225b:	55                   	push   %ebp
  80225c:	89 e5                	mov    %esp,%ebp
  80225e:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802261:	89 c2                	mov    %eax,%edx
  802263:	c1 ea 16             	shr    $0x16,%edx
  802266:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80226d:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802272:	f6 c1 01             	test   $0x1,%cl
  802275:	74 1c                	je     802293 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802277:	c1 e8 0c             	shr    $0xc,%eax
  80227a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802281:	a8 01                	test   $0x1,%al
  802283:	74 0e                	je     802293 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802285:	c1 e8 0c             	shr    $0xc,%eax
  802288:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80228f:	ef 
  802290:	0f b7 d2             	movzwl %dx,%edx
}
  802293:	89 d0                	mov    %edx,%eax
  802295:	5d                   	pop    %ebp
  802296:	c3                   	ret    
  802297:	66 90                	xchg   %ax,%ax
  802299:	66 90                	xchg   %ax,%ax
  80229b:	66 90                	xchg   %ax,%ax
  80229d:	66 90                	xchg   %ax,%ax
  80229f:	90                   	nop

008022a0 <__udivdi3>:
  8022a0:	f3 0f 1e fb          	endbr32 
  8022a4:	55                   	push   %ebp
  8022a5:	57                   	push   %edi
  8022a6:	56                   	push   %esi
  8022a7:	53                   	push   %ebx
  8022a8:	83 ec 1c             	sub    $0x1c,%esp
  8022ab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022af:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8022b3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022b7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8022bb:	85 d2                	test   %edx,%edx
  8022bd:	75 19                	jne    8022d8 <__udivdi3+0x38>
  8022bf:	39 f3                	cmp    %esi,%ebx
  8022c1:	76 4d                	jbe    802310 <__udivdi3+0x70>
  8022c3:	31 ff                	xor    %edi,%edi
  8022c5:	89 e8                	mov    %ebp,%eax
  8022c7:	89 f2                	mov    %esi,%edx
  8022c9:	f7 f3                	div    %ebx
  8022cb:	89 fa                	mov    %edi,%edx
  8022cd:	83 c4 1c             	add    $0x1c,%esp
  8022d0:	5b                   	pop    %ebx
  8022d1:	5e                   	pop    %esi
  8022d2:	5f                   	pop    %edi
  8022d3:	5d                   	pop    %ebp
  8022d4:	c3                   	ret    
  8022d5:	8d 76 00             	lea    0x0(%esi),%esi
  8022d8:	39 f2                	cmp    %esi,%edx
  8022da:	76 14                	jbe    8022f0 <__udivdi3+0x50>
  8022dc:	31 ff                	xor    %edi,%edi
  8022de:	31 c0                	xor    %eax,%eax
  8022e0:	89 fa                	mov    %edi,%edx
  8022e2:	83 c4 1c             	add    $0x1c,%esp
  8022e5:	5b                   	pop    %ebx
  8022e6:	5e                   	pop    %esi
  8022e7:	5f                   	pop    %edi
  8022e8:	5d                   	pop    %ebp
  8022e9:	c3                   	ret    
  8022ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f0:	0f bd fa             	bsr    %edx,%edi
  8022f3:	83 f7 1f             	xor    $0x1f,%edi
  8022f6:	75 48                	jne    802340 <__udivdi3+0xa0>
  8022f8:	39 f2                	cmp    %esi,%edx
  8022fa:	72 06                	jb     802302 <__udivdi3+0x62>
  8022fc:	31 c0                	xor    %eax,%eax
  8022fe:	39 eb                	cmp    %ebp,%ebx
  802300:	77 de                	ja     8022e0 <__udivdi3+0x40>
  802302:	b8 01 00 00 00       	mov    $0x1,%eax
  802307:	eb d7                	jmp    8022e0 <__udivdi3+0x40>
  802309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802310:	89 d9                	mov    %ebx,%ecx
  802312:	85 db                	test   %ebx,%ebx
  802314:	75 0b                	jne    802321 <__udivdi3+0x81>
  802316:	b8 01 00 00 00       	mov    $0x1,%eax
  80231b:	31 d2                	xor    %edx,%edx
  80231d:	f7 f3                	div    %ebx
  80231f:	89 c1                	mov    %eax,%ecx
  802321:	31 d2                	xor    %edx,%edx
  802323:	89 f0                	mov    %esi,%eax
  802325:	f7 f1                	div    %ecx
  802327:	89 c6                	mov    %eax,%esi
  802329:	89 e8                	mov    %ebp,%eax
  80232b:	89 f7                	mov    %esi,%edi
  80232d:	f7 f1                	div    %ecx
  80232f:	89 fa                	mov    %edi,%edx
  802331:	83 c4 1c             	add    $0x1c,%esp
  802334:	5b                   	pop    %ebx
  802335:	5e                   	pop    %esi
  802336:	5f                   	pop    %edi
  802337:	5d                   	pop    %ebp
  802338:	c3                   	ret    
  802339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802340:	89 f9                	mov    %edi,%ecx
  802342:	b8 20 00 00 00       	mov    $0x20,%eax
  802347:	29 f8                	sub    %edi,%eax
  802349:	d3 e2                	shl    %cl,%edx
  80234b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80234f:	89 c1                	mov    %eax,%ecx
  802351:	89 da                	mov    %ebx,%edx
  802353:	d3 ea                	shr    %cl,%edx
  802355:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802359:	09 d1                	or     %edx,%ecx
  80235b:	89 f2                	mov    %esi,%edx
  80235d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802361:	89 f9                	mov    %edi,%ecx
  802363:	d3 e3                	shl    %cl,%ebx
  802365:	89 c1                	mov    %eax,%ecx
  802367:	d3 ea                	shr    %cl,%edx
  802369:	89 f9                	mov    %edi,%ecx
  80236b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80236f:	89 eb                	mov    %ebp,%ebx
  802371:	d3 e6                	shl    %cl,%esi
  802373:	89 c1                	mov    %eax,%ecx
  802375:	d3 eb                	shr    %cl,%ebx
  802377:	09 de                	or     %ebx,%esi
  802379:	89 f0                	mov    %esi,%eax
  80237b:	f7 74 24 08          	divl   0x8(%esp)
  80237f:	89 d6                	mov    %edx,%esi
  802381:	89 c3                	mov    %eax,%ebx
  802383:	f7 64 24 0c          	mull   0xc(%esp)
  802387:	39 d6                	cmp    %edx,%esi
  802389:	72 15                	jb     8023a0 <__udivdi3+0x100>
  80238b:	89 f9                	mov    %edi,%ecx
  80238d:	d3 e5                	shl    %cl,%ebp
  80238f:	39 c5                	cmp    %eax,%ebp
  802391:	73 04                	jae    802397 <__udivdi3+0xf7>
  802393:	39 d6                	cmp    %edx,%esi
  802395:	74 09                	je     8023a0 <__udivdi3+0x100>
  802397:	89 d8                	mov    %ebx,%eax
  802399:	31 ff                	xor    %edi,%edi
  80239b:	e9 40 ff ff ff       	jmp    8022e0 <__udivdi3+0x40>
  8023a0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8023a3:	31 ff                	xor    %edi,%edi
  8023a5:	e9 36 ff ff ff       	jmp    8022e0 <__udivdi3+0x40>
  8023aa:	66 90                	xchg   %ax,%ax
  8023ac:	66 90                	xchg   %ax,%ax
  8023ae:	66 90                	xchg   %ax,%ax

008023b0 <__umoddi3>:
  8023b0:	f3 0f 1e fb          	endbr32 
  8023b4:	55                   	push   %ebp
  8023b5:	57                   	push   %edi
  8023b6:	56                   	push   %esi
  8023b7:	53                   	push   %ebx
  8023b8:	83 ec 1c             	sub    $0x1c,%esp
  8023bb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8023bf:	8b 74 24 30          	mov    0x30(%esp),%esi
  8023c3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8023c7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023cb:	85 c0                	test   %eax,%eax
  8023cd:	75 19                	jne    8023e8 <__umoddi3+0x38>
  8023cf:	39 df                	cmp    %ebx,%edi
  8023d1:	76 5d                	jbe    802430 <__umoddi3+0x80>
  8023d3:	89 f0                	mov    %esi,%eax
  8023d5:	89 da                	mov    %ebx,%edx
  8023d7:	f7 f7                	div    %edi
  8023d9:	89 d0                	mov    %edx,%eax
  8023db:	31 d2                	xor    %edx,%edx
  8023dd:	83 c4 1c             	add    $0x1c,%esp
  8023e0:	5b                   	pop    %ebx
  8023e1:	5e                   	pop    %esi
  8023e2:	5f                   	pop    %edi
  8023e3:	5d                   	pop    %ebp
  8023e4:	c3                   	ret    
  8023e5:	8d 76 00             	lea    0x0(%esi),%esi
  8023e8:	89 f2                	mov    %esi,%edx
  8023ea:	39 d8                	cmp    %ebx,%eax
  8023ec:	76 12                	jbe    802400 <__umoddi3+0x50>
  8023ee:	89 f0                	mov    %esi,%eax
  8023f0:	89 da                	mov    %ebx,%edx
  8023f2:	83 c4 1c             	add    $0x1c,%esp
  8023f5:	5b                   	pop    %ebx
  8023f6:	5e                   	pop    %esi
  8023f7:	5f                   	pop    %edi
  8023f8:	5d                   	pop    %ebp
  8023f9:	c3                   	ret    
  8023fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802400:	0f bd e8             	bsr    %eax,%ebp
  802403:	83 f5 1f             	xor    $0x1f,%ebp
  802406:	75 50                	jne    802458 <__umoddi3+0xa8>
  802408:	39 d8                	cmp    %ebx,%eax
  80240a:	0f 82 e0 00 00 00    	jb     8024f0 <__umoddi3+0x140>
  802410:	89 d9                	mov    %ebx,%ecx
  802412:	39 f7                	cmp    %esi,%edi
  802414:	0f 86 d6 00 00 00    	jbe    8024f0 <__umoddi3+0x140>
  80241a:	89 d0                	mov    %edx,%eax
  80241c:	89 ca                	mov    %ecx,%edx
  80241e:	83 c4 1c             	add    $0x1c,%esp
  802421:	5b                   	pop    %ebx
  802422:	5e                   	pop    %esi
  802423:	5f                   	pop    %edi
  802424:	5d                   	pop    %ebp
  802425:	c3                   	ret    
  802426:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80242d:	8d 76 00             	lea    0x0(%esi),%esi
  802430:	89 fd                	mov    %edi,%ebp
  802432:	85 ff                	test   %edi,%edi
  802434:	75 0b                	jne    802441 <__umoddi3+0x91>
  802436:	b8 01 00 00 00       	mov    $0x1,%eax
  80243b:	31 d2                	xor    %edx,%edx
  80243d:	f7 f7                	div    %edi
  80243f:	89 c5                	mov    %eax,%ebp
  802441:	89 d8                	mov    %ebx,%eax
  802443:	31 d2                	xor    %edx,%edx
  802445:	f7 f5                	div    %ebp
  802447:	89 f0                	mov    %esi,%eax
  802449:	f7 f5                	div    %ebp
  80244b:	89 d0                	mov    %edx,%eax
  80244d:	31 d2                	xor    %edx,%edx
  80244f:	eb 8c                	jmp    8023dd <__umoddi3+0x2d>
  802451:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802458:	89 e9                	mov    %ebp,%ecx
  80245a:	ba 20 00 00 00       	mov    $0x20,%edx
  80245f:	29 ea                	sub    %ebp,%edx
  802461:	d3 e0                	shl    %cl,%eax
  802463:	89 44 24 08          	mov    %eax,0x8(%esp)
  802467:	89 d1                	mov    %edx,%ecx
  802469:	89 f8                	mov    %edi,%eax
  80246b:	d3 e8                	shr    %cl,%eax
  80246d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802471:	89 54 24 04          	mov    %edx,0x4(%esp)
  802475:	8b 54 24 04          	mov    0x4(%esp),%edx
  802479:	09 c1                	or     %eax,%ecx
  80247b:	89 d8                	mov    %ebx,%eax
  80247d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802481:	89 e9                	mov    %ebp,%ecx
  802483:	d3 e7                	shl    %cl,%edi
  802485:	89 d1                	mov    %edx,%ecx
  802487:	d3 e8                	shr    %cl,%eax
  802489:	89 e9                	mov    %ebp,%ecx
  80248b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80248f:	d3 e3                	shl    %cl,%ebx
  802491:	89 c7                	mov    %eax,%edi
  802493:	89 d1                	mov    %edx,%ecx
  802495:	89 f0                	mov    %esi,%eax
  802497:	d3 e8                	shr    %cl,%eax
  802499:	89 e9                	mov    %ebp,%ecx
  80249b:	89 fa                	mov    %edi,%edx
  80249d:	d3 e6                	shl    %cl,%esi
  80249f:	09 d8                	or     %ebx,%eax
  8024a1:	f7 74 24 08          	divl   0x8(%esp)
  8024a5:	89 d1                	mov    %edx,%ecx
  8024a7:	89 f3                	mov    %esi,%ebx
  8024a9:	f7 64 24 0c          	mull   0xc(%esp)
  8024ad:	89 c6                	mov    %eax,%esi
  8024af:	89 d7                	mov    %edx,%edi
  8024b1:	39 d1                	cmp    %edx,%ecx
  8024b3:	72 06                	jb     8024bb <__umoddi3+0x10b>
  8024b5:	75 10                	jne    8024c7 <__umoddi3+0x117>
  8024b7:	39 c3                	cmp    %eax,%ebx
  8024b9:	73 0c                	jae    8024c7 <__umoddi3+0x117>
  8024bb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8024bf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8024c3:	89 d7                	mov    %edx,%edi
  8024c5:	89 c6                	mov    %eax,%esi
  8024c7:	89 ca                	mov    %ecx,%edx
  8024c9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8024ce:	29 f3                	sub    %esi,%ebx
  8024d0:	19 fa                	sbb    %edi,%edx
  8024d2:	89 d0                	mov    %edx,%eax
  8024d4:	d3 e0                	shl    %cl,%eax
  8024d6:	89 e9                	mov    %ebp,%ecx
  8024d8:	d3 eb                	shr    %cl,%ebx
  8024da:	d3 ea                	shr    %cl,%edx
  8024dc:	09 d8                	or     %ebx,%eax
  8024de:	83 c4 1c             	add    $0x1c,%esp
  8024e1:	5b                   	pop    %ebx
  8024e2:	5e                   	pop    %esi
  8024e3:	5f                   	pop    %edi
  8024e4:	5d                   	pop    %ebp
  8024e5:	c3                   	ret    
  8024e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024ed:	8d 76 00             	lea    0x0(%esi),%esi
  8024f0:	29 fe                	sub    %edi,%esi
  8024f2:	19 c3                	sbb    %eax,%ebx
  8024f4:	89 f2                	mov    %esi,%edx
  8024f6:	89 d9                	mov    %ebx,%ecx
  8024f8:	e9 1d ff ff ff       	jmp    80241a <__umoddi3+0x6a>
