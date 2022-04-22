
obj/user/faultbadhandler:     file format elf32-i386


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
  80002c:	e8 38 00 00 00       	call   800069 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003d:	6a 07                	push   $0x7
  80003f:	68 00 f0 bf ee       	push   $0xeebff000
  800044:	6a 00                	push   $0x0
  800046:	e8 58 01 00 00       	call   8001a3 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	68 ef be ad de       	push   $0xdeadbeef
  800053:	6a 00                	push   $0x0
  800055:	e8 a8 02 00 00       	call   800302 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80005a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800061:	00 00 00 
}
  800064:	83 c4 10             	add    $0x10,%esp
  800067:	c9                   	leave  
  800068:	c3                   	ret    

00800069 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800069:	f3 0f 1e fb          	endbr32 
  80006d:	55                   	push   %ebp
  80006e:	89 e5                	mov    %esp,%ebp
  800070:	56                   	push   %esi
  800071:	53                   	push   %ebx
  800072:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800075:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800078:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80007f:	00 00 00 
    envid_t envid = sys_getenvid();
  800082:	e8 d6 00 00 00       	call   80015d <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800087:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80008f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800094:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800099:	85 db                	test   %ebx,%ebx
  80009b:	7e 07                	jle    8000a4 <libmain+0x3b>
		binaryname = argv[0];
  80009d:	8b 06                	mov    (%esi),%eax
  80009f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	56                   	push   %esi
  8000a8:	53                   	push   %ebx
  8000a9:	e8 85 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ae:	e8 0a 00 00 00       	call   8000bd <exit>
}
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5d                   	pop    %ebp
  8000bc:	c3                   	ret    

008000bd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bd:	f3 0f 1e fb          	endbr32 
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  8000c7:	6a 00                	push   $0x0
  8000c9:	e8 4a 00 00 00       	call   800118 <sys_env_destroy>
}
  8000ce:	83 c4 10             	add    $0x10,%esp
  8000d1:	c9                   	leave  
  8000d2:	c3                   	ret    

008000d3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000d3:	f3 0f 1e fb          	endbr32 
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000e8:	89 c3                	mov    %eax,%ebx
  8000ea:	89 c7                	mov    %eax,%edi
  8000ec:	89 c6                	mov    %eax,%esi
  8000ee:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    

008000f5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f5:	f3 0f 1e fb          	endbr32 
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	57                   	push   %edi
  8000fd:	56                   	push   %esi
  8000fe:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800104:	b8 01 00 00 00       	mov    $0x1,%eax
  800109:	89 d1                	mov    %edx,%ecx
  80010b:	89 d3                	mov    %edx,%ebx
  80010d:	89 d7                	mov    %edx,%edi
  80010f:	89 d6                	mov    %edx,%esi
  800111:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800118:	f3 0f 1e fb          	endbr32 
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	57                   	push   %edi
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
  800122:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800125:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012a:	8b 55 08             	mov    0x8(%ebp),%edx
  80012d:	b8 03 00 00 00       	mov    $0x3,%eax
  800132:	89 cb                	mov    %ecx,%ebx
  800134:	89 cf                	mov    %ecx,%edi
  800136:	89 ce                	mov    %ecx,%esi
  800138:	cd 30                	int    $0x30
	if(check && ret > 0)
  80013a:	85 c0                	test   %eax,%eax
  80013c:	7f 08                	jg     800146 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800141:	5b                   	pop    %ebx
  800142:	5e                   	pop    %esi
  800143:	5f                   	pop    %edi
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800146:	83 ec 0c             	sub    $0xc,%esp
  800149:	50                   	push   %eax
  80014a:	6a 03                	push   $0x3
  80014c:	68 8a 10 80 00       	push   $0x80108a
  800151:	6a 23                	push   $0x23
  800153:	68 a7 10 80 00       	push   $0x8010a7
  800158:	e8 57 02 00 00       	call   8003b4 <_panic>

0080015d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80015d:	f3 0f 1e fb          	endbr32 
  800161:	55                   	push   %ebp
  800162:	89 e5                	mov    %esp,%ebp
  800164:	57                   	push   %edi
  800165:	56                   	push   %esi
  800166:	53                   	push   %ebx
	asm volatile("int %1\n"
  800167:	ba 00 00 00 00       	mov    $0x0,%edx
  80016c:	b8 02 00 00 00       	mov    $0x2,%eax
  800171:	89 d1                	mov    %edx,%ecx
  800173:	89 d3                	mov    %edx,%ebx
  800175:	89 d7                	mov    %edx,%edi
  800177:	89 d6                	mov    %edx,%esi
  800179:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80017b:	5b                   	pop    %ebx
  80017c:	5e                   	pop    %esi
  80017d:	5f                   	pop    %edi
  80017e:	5d                   	pop    %ebp
  80017f:	c3                   	ret    

00800180 <sys_yield>:

void
sys_yield(void)
{
  800180:	f3 0f 1e fb          	endbr32 
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	57                   	push   %edi
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
	asm volatile("int %1\n"
  80018a:	ba 00 00 00 00       	mov    $0x0,%edx
  80018f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800194:	89 d1                	mov    %edx,%ecx
  800196:	89 d3                	mov    %edx,%ebx
  800198:	89 d7                	mov    %edx,%edi
  80019a:	89 d6                	mov    %edx,%esi
  80019c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80019e:	5b                   	pop    %ebx
  80019f:	5e                   	pop    %esi
  8001a0:	5f                   	pop    %edi
  8001a1:	5d                   	pop    %ebp
  8001a2:	c3                   	ret    

008001a3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a3:	f3 0f 1e fb          	endbr32 
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	57                   	push   %edi
  8001ab:	56                   	push   %esi
  8001ac:	53                   	push   %ebx
  8001ad:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001b0:	be 00 00 00 00       	mov    $0x0,%esi
  8001b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bb:	b8 04 00 00 00       	mov    $0x4,%eax
  8001c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c3:	89 f7                	mov    %esi,%edi
  8001c5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001c7:	85 c0                	test   %eax,%eax
  8001c9:	7f 08                	jg     8001d3 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ce:	5b                   	pop    %ebx
  8001cf:	5e                   	pop    %esi
  8001d0:	5f                   	pop    %edi
  8001d1:	5d                   	pop    %ebp
  8001d2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	50                   	push   %eax
  8001d7:	6a 04                	push   $0x4
  8001d9:	68 8a 10 80 00       	push   $0x80108a
  8001de:	6a 23                	push   $0x23
  8001e0:	68 a7 10 80 00       	push   $0x8010a7
  8001e5:	e8 ca 01 00 00       	call   8003b4 <_panic>

008001ea <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ea:	f3 0f 1e fb          	endbr32 
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	57                   	push   %edi
  8001f2:	56                   	push   %esi
  8001f3:	53                   	push   %ebx
  8001f4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fd:	b8 05 00 00 00       	mov    $0x5,%eax
  800202:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800205:	8b 7d 14             	mov    0x14(%ebp),%edi
  800208:	8b 75 18             	mov    0x18(%ebp),%esi
  80020b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80020d:	85 c0                	test   %eax,%eax
  80020f:	7f 08                	jg     800219 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800211:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800214:	5b                   	pop    %ebx
  800215:	5e                   	pop    %esi
  800216:	5f                   	pop    %edi
  800217:	5d                   	pop    %ebp
  800218:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800219:	83 ec 0c             	sub    $0xc,%esp
  80021c:	50                   	push   %eax
  80021d:	6a 05                	push   $0x5
  80021f:	68 8a 10 80 00       	push   $0x80108a
  800224:	6a 23                	push   $0x23
  800226:	68 a7 10 80 00       	push   $0x8010a7
  80022b:	e8 84 01 00 00       	call   8003b4 <_panic>

00800230 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800230:	f3 0f 1e fb          	endbr32 
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	57                   	push   %edi
  800238:	56                   	push   %esi
  800239:	53                   	push   %ebx
  80023a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80023d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800242:	8b 55 08             	mov    0x8(%ebp),%edx
  800245:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800248:	b8 06 00 00 00       	mov    $0x6,%eax
  80024d:	89 df                	mov    %ebx,%edi
  80024f:	89 de                	mov    %ebx,%esi
  800251:	cd 30                	int    $0x30
	if(check && ret > 0)
  800253:	85 c0                	test   %eax,%eax
  800255:	7f 08                	jg     80025f <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80025f:	83 ec 0c             	sub    $0xc,%esp
  800262:	50                   	push   %eax
  800263:	6a 06                	push   $0x6
  800265:	68 8a 10 80 00       	push   $0x80108a
  80026a:	6a 23                	push   $0x23
  80026c:	68 a7 10 80 00       	push   $0x8010a7
  800271:	e8 3e 01 00 00       	call   8003b4 <_panic>

00800276 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800276:	f3 0f 1e fb          	endbr32 
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	57                   	push   %edi
  80027e:	56                   	push   %esi
  80027f:	53                   	push   %ebx
  800280:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800283:	bb 00 00 00 00       	mov    $0x0,%ebx
  800288:	8b 55 08             	mov    0x8(%ebp),%edx
  80028b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028e:	b8 08 00 00 00       	mov    $0x8,%eax
  800293:	89 df                	mov    %ebx,%edi
  800295:	89 de                	mov    %ebx,%esi
  800297:	cd 30                	int    $0x30
	if(check && ret > 0)
  800299:	85 c0                	test   %eax,%eax
  80029b:	7f 08                	jg     8002a5 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80029d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5e                   	pop    %esi
  8002a2:	5f                   	pop    %edi
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a5:	83 ec 0c             	sub    $0xc,%esp
  8002a8:	50                   	push   %eax
  8002a9:	6a 08                	push   $0x8
  8002ab:	68 8a 10 80 00       	push   $0x80108a
  8002b0:	6a 23                	push   $0x23
  8002b2:	68 a7 10 80 00       	push   $0x8010a7
  8002b7:	e8 f8 00 00 00       	call   8003b4 <_panic>

008002bc <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002bc:	f3 0f 1e fb          	endbr32 
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d4:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d9:	89 df                	mov    %ebx,%edi
  8002db:	89 de                	mov    %ebx,%esi
  8002dd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002df:	85 c0                	test   %eax,%eax
  8002e1:	7f 08                	jg     8002eb <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002eb:	83 ec 0c             	sub    $0xc,%esp
  8002ee:	50                   	push   %eax
  8002ef:	6a 09                	push   $0x9
  8002f1:	68 8a 10 80 00       	push   $0x80108a
  8002f6:	6a 23                	push   $0x23
  8002f8:	68 a7 10 80 00       	push   $0x8010a7
  8002fd:	e8 b2 00 00 00       	call   8003b4 <_panic>

00800302 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800302:	f3 0f 1e fb          	endbr32 
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80030f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800314:	8b 55 08             	mov    0x8(%ebp),%edx
  800317:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80031f:	89 df                	mov    %ebx,%edi
  800321:	89 de                	mov    %ebx,%esi
  800323:	cd 30                	int    $0x30
	if(check && ret > 0)
  800325:	85 c0                	test   %eax,%eax
  800327:	7f 08                	jg     800331 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800329:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800331:	83 ec 0c             	sub    $0xc,%esp
  800334:	50                   	push   %eax
  800335:	6a 0a                	push   $0xa
  800337:	68 8a 10 80 00       	push   $0x80108a
  80033c:	6a 23                	push   $0x23
  80033e:	68 a7 10 80 00       	push   $0x8010a7
  800343:	e8 6c 00 00 00       	call   8003b4 <_panic>

00800348 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800348:	f3 0f 1e fb          	endbr32 
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	57                   	push   %edi
  800350:	56                   	push   %esi
  800351:	53                   	push   %ebx
	asm volatile("int %1\n"
  800352:	8b 55 08             	mov    0x8(%ebp),%edx
  800355:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800358:	b8 0c 00 00 00       	mov    $0xc,%eax
  80035d:	be 00 00 00 00       	mov    $0x0,%esi
  800362:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800365:	8b 7d 14             	mov    0x14(%ebp),%edi
  800368:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80036a:	5b                   	pop    %ebx
  80036b:	5e                   	pop    %esi
  80036c:	5f                   	pop    %edi
  80036d:	5d                   	pop    %ebp
  80036e:	c3                   	ret    

0080036f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80036f:	f3 0f 1e fb          	endbr32 
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	57                   	push   %edi
  800377:	56                   	push   %esi
  800378:	53                   	push   %ebx
  800379:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80037c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800381:	8b 55 08             	mov    0x8(%ebp),%edx
  800384:	b8 0d 00 00 00       	mov    $0xd,%eax
  800389:	89 cb                	mov    %ecx,%ebx
  80038b:	89 cf                	mov    %ecx,%edi
  80038d:	89 ce                	mov    %ecx,%esi
  80038f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800391:	85 c0                	test   %eax,%eax
  800393:	7f 08                	jg     80039d <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800395:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800398:	5b                   	pop    %ebx
  800399:	5e                   	pop    %esi
  80039a:	5f                   	pop    %edi
  80039b:	5d                   	pop    %ebp
  80039c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80039d:	83 ec 0c             	sub    $0xc,%esp
  8003a0:	50                   	push   %eax
  8003a1:	6a 0d                	push   $0xd
  8003a3:	68 8a 10 80 00       	push   $0x80108a
  8003a8:	6a 23                	push   $0x23
  8003aa:	68 a7 10 80 00       	push   $0x8010a7
  8003af:	e8 00 00 00 00       	call   8003b4 <_panic>

008003b4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003b4:	f3 0f 1e fb          	endbr32 
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
  8003bb:	56                   	push   %esi
  8003bc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8003bd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003c0:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8003c6:	e8 92 fd ff ff       	call   80015d <sys_getenvid>
  8003cb:	83 ec 0c             	sub    $0xc,%esp
  8003ce:	ff 75 0c             	pushl  0xc(%ebp)
  8003d1:	ff 75 08             	pushl  0x8(%ebp)
  8003d4:	56                   	push   %esi
  8003d5:	50                   	push   %eax
  8003d6:	68 b8 10 80 00       	push   $0x8010b8
  8003db:	e8 bb 00 00 00       	call   80049b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003e0:	83 c4 18             	add    $0x18,%esp
  8003e3:	53                   	push   %ebx
  8003e4:	ff 75 10             	pushl  0x10(%ebp)
  8003e7:	e8 5a 00 00 00       	call   800446 <vcprintf>
	cprintf("\n");
  8003ec:	c7 04 24 db 10 80 00 	movl   $0x8010db,(%esp)
  8003f3:	e8 a3 00 00 00       	call   80049b <cprintf>
  8003f8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003fb:	cc                   	int3   
  8003fc:	eb fd                	jmp    8003fb <_panic+0x47>

008003fe <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003fe:	f3 0f 1e fb          	endbr32 
  800402:	55                   	push   %ebp
  800403:	89 e5                	mov    %esp,%ebp
  800405:	53                   	push   %ebx
  800406:	83 ec 04             	sub    $0x4,%esp
  800409:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80040c:	8b 13                	mov    (%ebx),%edx
  80040e:	8d 42 01             	lea    0x1(%edx),%eax
  800411:	89 03                	mov    %eax,(%ebx)
  800413:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800416:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80041a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80041f:	74 09                	je     80042a <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800421:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800425:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800428:	c9                   	leave  
  800429:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	68 ff 00 00 00       	push   $0xff
  800432:	8d 43 08             	lea    0x8(%ebx),%eax
  800435:	50                   	push   %eax
  800436:	e8 98 fc ff ff       	call   8000d3 <sys_cputs>
		b->idx = 0;
  80043b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800441:	83 c4 10             	add    $0x10,%esp
  800444:	eb db                	jmp    800421 <putch+0x23>

00800446 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800446:	f3 0f 1e fb          	endbr32 
  80044a:	55                   	push   %ebp
  80044b:	89 e5                	mov    %esp,%ebp
  80044d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800453:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80045a:	00 00 00 
	b.cnt = 0;
  80045d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800464:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800467:	ff 75 0c             	pushl  0xc(%ebp)
  80046a:	ff 75 08             	pushl  0x8(%ebp)
  80046d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800473:	50                   	push   %eax
  800474:	68 fe 03 80 00       	push   $0x8003fe
  800479:	e8 20 01 00 00       	call   80059e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80047e:	83 c4 08             	add    $0x8,%esp
  800481:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800487:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80048d:	50                   	push   %eax
  80048e:	e8 40 fc ff ff       	call   8000d3 <sys_cputs>

	return b.cnt;
}
  800493:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800499:	c9                   	leave  
  80049a:	c3                   	ret    

0080049b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80049b:	f3 0f 1e fb          	endbr32 
  80049f:	55                   	push   %ebp
  8004a0:	89 e5                	mov    %esp,%ebp
  8004a2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004a5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004a8:	50                   	push   %eax
  8004a9:	ff 75 08             	pushl  0x8(%ebp)
  8004ac:	e8 95 ff ff ff       	call   800446 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004b1:	c9                   	leave  
  8004b2:	c3                   	ret    

008004b3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004b3:	55                   	push   %ebp
  8004b4:	89 e5                	mov    %esp,%ebp
  8004b6:	57                   	push   %edi
  8004b7:	56                   	push   %esi
  8004b8:	53                   	push   %ebx
  8004b9:	83 ec 1c             	sub    $0x1c,%esp
  8004bc:	89 c7                	mov    %eax,%edi
  8004be:	89 d6                	mov    %edx,%esi
  8004c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004c6:	89 d1                	mov    %edx,%ecx
  8004c8:	89 c2                	mov    %eax,%edx
  8004ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004cd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004e0:	39 c2                	cmp    %eax,%edx
  8004e2:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8004e5:	72 3e                	jb     800525 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004e7:	83 ec 0c             	sub    $0xc,%esp
  8004ea:	ff 75 18             	pushl  0x18(%ebp)
  8004ed:	83 eb 01             	sub    $0x1,%ebx
  8004f0:	53                   	push   %ebx
  8004f1:	50                   	push   %eax
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004fb:	ff 75 dc             	pushl  -0x24(%ebp)
  8004fe:	ff 75 d8             	pushl  -0x28(%ebp)
  800501:	e8 1a 09 00 00       	call   800e20 <__udivdi3>
  800506:	83 c4 18             	add    $0x18,%esp
  800509:	52                   	push   %edx
  80050a:	50                   	push   %eax
  80050b:	89 f2                	mov    %esi,%edx
  80050d:	89 f8                	mov    %edi,%eax
  80050f:	e8 9f ff ff ff       	call   8004b3 <printnum>
  800514:	83 c4 20             	add    $0x20,%esp
  800517:	eb 13                	jmp    80052c <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	56                   	push   %esi
  80051d:	ff 75 18             	pushl  0x18(%ebp)
  800520:	ff d7                	call   *%edi
  800522:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800525:	83 eb 01             	sub    $0x1,%ebx
  800528:	85 db                	test   %ebx,%ebx
  80052a:	7f ed                	jg     800519 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	56                   	push   %esi
  800530:	83 ec 04             	sub    $0x4,%esp
  800533:	ff 75 e4             	pushl  -0x1c(%ebp)
  800536:	ff 75 e0             	pushl  -0x20(%ebp)
  800539:	ff 75 dc             	pushl  -0x24(%ebp)
  80053c:	ff 75 d8             	pushl  -0x28(%ebp)
  80053f:	e8 ec 09 00 00       	call   800f30 <__umoddi3>
  800544:	83 c4 14             	add    $0x14,%esp
  800547:	0f be 80 dd 10 80 00 	movsbl 0x8010dd(%eax),%eax
  80054e:	50                   	push   %eax
  80054f:	ff d7                	call   *%edi
}
  800551:	83 c4 10             	add    $0x10,%esp
  800554:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800557:	5b                   	pop    %ebx
  800558:	5e                   	pop    %esi
  800559:	5f                   	pop    %edi
  80055a:	5d                   	pop    %ebp
  80055b:	c3                   	ret    

0080055c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80055c:	f3 0f 1e fb          	endbr32 
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800566:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80056a:	8b 10                	mov    (%eax),%edx
  80056c:	3b 50 04             	cmp    0x4(%eax),%edx
  80056f:	73 0a                	jae    80057b <sprintputch+0x1f>
		*b->buf++ = ch;
  800571:	8d 4a 01             	lea    0x1(%edx),%ecx
  800574:	89 08                	mov    %ecx,(%eax)
  800576:	8b 45 08             	mov    0x8(%ebp),%eax
  800579:	88 02                	mov    %al,(%edx)
}
  80057b:	5d                   	pop    %ebp
  80057c:	c3                   	ret    

0080057d <printfmt>:
{
  80057d:	f3 0f 1e fb          	endbr32 
  800581:	55                   	push   %ebp
  800582:	89 e5                	mov    %esp,%ebp
  800584:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800587:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80058a:	50                   	push   %eax
  80058b:	ff 75 10             	pushl  0x10(%ebp)
  80058e:	ff 75 0c             	pushl  0xc(%ebp)
  800591:	ff 75 08             	pushl  0x8(%ebp)
  800594:	e8 05 00 00 00       	call   80059e <vprintfmt>
}
  800599:	83 c4 10             	add    $0x10,%esp
  80059c:	c9                   	leave  
  80059d:	c3                   	ret    

0080059e <vprintfmt>:
{
  80059e:	f3 0f 1e fb          	endbr32 
  8005a2:	55                   	push   %ebp
  8005a3:	89 e5                	mov    %esp,%ebp
  8005a5:	57                   	push   %edi
  8005a6:	56                   	push   %esi
  8005a7:	53                   	push   %ebx
  8005a8:	83 ec 3c             	sub    $0x3c,%esp
  8005ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005b4:	e9 4a 03 00 00       	jmp    800903 <vprintfmt+0x365>
		padc = ' ';
  8005b9:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8005bd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8005c4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8005cb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8005d2:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005d7:	8d 47 01             	lea    0x1(%edi),%eax
  8005da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005dd:	0f b6 17             	movzbl (%edi),%edx
  8005e0:	8d 42 dd             	lea    -0x23(%edx),%eax
  8005e3:	3c 55                	cmp    $0x55,%al
  8005e5:	0f 87 de 03 00 00    	ja     8009c9 <vprintfmt+0x42b>
  8005eb:	0f b6 c0             	movzbl %al,%eax
  8005ee:	3e ff 24 85 20 12 80 	notrack jmp *0x801220(,%eax,4)
  8005f5:	00 
  8005f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005f9:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005fd:	eb d8                	jmp    8005d7 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800602:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800606:	eb cf                	jmp    8005d7 <vprintfmt+0x39>
  800608:	0f b6 d2             	movzbl %dl,%edx
  80060b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80060e:	b8 00 00 00 00       	mov    $0x0,%eax
  800613:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800616:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800619:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80061d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800620:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800623:	83 f9 09             	cmp    $0x9,%ecx
  800626:	77 55                	ja     80067d <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800628:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80062b:	eb e9                	jmp    800616 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8b 00                	mov    (%eax),%eax
  800632:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8d 40 04             	lea    0x4(%eax),%eax
  80063b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80063e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800641:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800645:	79 90                	jns    8005d7 <vprintfmt+0x39>
				width = precision, precision = -1;
  800647:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80064a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80064d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800654:	eb 81                	jmp    8005d7 <vprintfmt+0x39>
  800656:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800659:	85 c0                	test   %eax,%eax
  80065b:	ba 00 00 00 00       	mov    $0x0,%edx
  800660:	0f 49 d0             	cmovns %eax,%edx
  800663:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800666:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800669:	e9 69 ff ff ff       	jmp    8005d7 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80066e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800671:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800678:	e9 5a ff ff ff       	jmp    8005d7 <vprintfmt+0x39>
  80067d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800680:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800683:	eb bc                	jmp    800641 <vprintfmt+0xa3>
			lflag++;
  800685:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800688:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80068b:	e9 47 ff ff ff       	jmp    8005d7 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8d 78 04             	lea    0x4(%eax),%edi
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	53                   	push   %ebx
  80069a:	ff 30                	pushl  (%eax)
  80069c:	ff d6                	call   *%esi
			break;
  80069e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8006a1:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8006a4:	e9 57 02 00 00       	jmp    800900 <vprintfmt+0x362>
			err = va_arg(ap, int);
  8006a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ac:	8d 78 04             	lea    0x4(%eax),%edi
  8006af:	8b 00                	mov    (%eax),%eax
  8006b1:	99                   	cltd   
  8006b2:	31 d0                	xor    %edx,%eax
  8006b4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006b6:	83 f8 0f             	cmp    $0xf,%eax
  8006b9:	7f 23                	jg     8006de <vprintfmt+0x140>
  8006bb:	8b 14 85 80 13 80 00 	mov    0x801380(,%eax,4),%edx
  8006c2:	85 d2                	test   %edx,%edx
  8006c4:	74 18                	je     8006de <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8006c6:	52                   	push   %edx
  8006c7:	68 fe 10 80 00       	push   $0x8010fe
  8006cc:	53                   	push   %ebx
  8006cd:	56                   	push   %esi
  8006ce:	e8 aa fe ff ff       	call   80057d <printfmt>
  8006d3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006d6:	89 7d 14             	mov    %edi,0x14(%ebp)
  8006d9:	e9 22 02 00 00       	jmp    800900 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8006de:	50                   	push   %eax
  8006df:	68 f5 10 80 00       	push   $0x8010f5
  8006e4:	53                   	push   %ebx
  8006e5:	56                   	push   %esi
  8006e6:	e8 92 fe ff ff       	call   80057d <printfmt>
  8006eb:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006ee:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8006f1:	e9 0a 02 00 00       	jmp    800900 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	83 c0 04             	add    $0x4,%eax
  8006fc:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800702:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800704:	85 d2                	test   %edx,%edx
  800706:	b8 ee 10 80 00       	mov    $0x8010ee,%eax
  80070b:	0f 45 c2             	cmovne %edx,%eax
  80070e:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800711:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800715:	7e 06                	jle    80071d <vprintfmt+0x17f>
  800717:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80071b:	75 0d                	jne    80072a <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80071d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800720:	89 c7                	mov    %eax,%edi
  800722:	03 45 e0             	add    -0x20(%ebp),%eax
  800725:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800728:	eb 55                	jmp    80077f <vprintfmt+0x1e1>
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	ff 75 d8             	pushl  -0x28(%ebp)
  800730:	ff 75 cc             	pushl  -0x34(%ebp)
  800733:	e8 45 03 00 00       	call   800a7d <strnlen>
  800738:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80073b:	29 c2                	sub    %eax,%edx
  80073d:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800740:	83 c4 10             	add    $0x10,%esp
  800743:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800745:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800749:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80074c:	85 ff                	test   %edi,%edi
  80074e:	7e 11                	jle    800761 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800750:	83 ec 08             	sub    $0x8,%esp
  800753:	53                   	push   %ebx
  800754:	ff 75 e0             	pushl  -0x20(%ebp)
  800757:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800759:	83 ef 01             	sub    $0x1,%edi
  80075c:	83 c4 10             	add    $0x10,%esp
  80075f:	eb eb                	jmp    80074c <vprintfmt+0x1ae>
  800761:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800764:	85 d2                	test   %edx,%edx
  800766:	b8 00 00 00 00       	mov    $0x0,%eax
  80076b:	0f 49 c2             	cmovns %edx,%eax
  80076e:	29 c2                	sub    %eax,%edx
  800770:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800773:	eb a8                	jmp    80071d <vprintfmt+0x17f>
					putch(ch, putdat);
  800775:	83 ec 08             	sub    $0x8,%esp
  800778:	53                   	push   %ebx
  800779:	52                   	push   %edx
  80077a:	ff d6                	call   *%esi
  80077c:	83 c4 10             	add    $0x10,%esp
  80077f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800782:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800784:	83 c7 01             	add    $0x1,%edi
  800787:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80078b:	0f be d0             	movsbl %al,%edx
  80078e:	85 d2                	test   %edx,%edx
  800790:	74 4b                	je     8007dd <vprintfmt+0x23f>
  800792:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800796:	78 06                	js     80079e <vprintfmt+0x200>
  800798:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80079c:	78 1e                	js     8007bc <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80079e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007a2:	74 d1                	je     800775 <vprintfmt+0x1d7>
  8007a4:	0f be c0             	movsbl %al,%eax
  8007a7:	83 e8 20             	sub    $0x20,%eax
  8007aa:	83 f8 5e             	cmp    $0x5e,%eax
  8007ad:	76 c6                	jbe    800775 <vprintfmt+0x1d7>
					putch('?', putdat);
  8007af:	83 ec 08             	sub    $0x8,%esp
  8007b2:	53                   	push   %ebx
  8007b3:	6a 3f                	push   $0x3f
  8007b5:	ff d6                	call   *%esi
  8007b7:	83 c4 10             	add    $0x10,%esp
  8007ba:	eb c3                	jmp    80077f <vprintfmt+0x1e1>
  8007bc:	89 cf                	mov    %ecx,%edi
  8007be:	eb 0e                	jmp    8007ce <vprintfmt+0x230>
				putch(' ', putdat);
  8007c0:	83 ec 08             	sub    $0x8,%esp
  8007c3:	53                   	push   %ebx
  8007c4:	6a 20                	push   $0x20
  8007c6:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8007c8:	83 ef 01             	sub    $0x1,%edi
  8007cb:	83 c4 10             	add    $0x10,%esp
  8007ce:	85 ff                	test   %edi,%edi
  8007d0:	7f ee                	jg     8007c0 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8007d2:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007d5:	89 45 14             	mov    %eax,0x14(%ebp)
  8007d8:	e9 23 01 00 00       	jmp    800900 <vprintfmt+0x362>
  8007dd:	89 cf                	mov    %ecx,%edi
  8007df:	eb ed                	jmp    8007ce <vprintfmt+0x230>
	if (lflag >= 2)
  8007e1:	83 f9 01             	cmp    $0x1,%ecx
  8007e4:	7f 1b                	jg     800801 <vprintfmt+0x263>
	else if (lflag)
  8007e6:	85 c9                	test   %ecx,%ecx
  8007e8:	74 63                	je     80084d <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8007ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ed:	8b 00                	mov    (%eax),%eax
  8007ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f2:	99                   	cltd   
  8007f3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f9:	8d 40 04             	lea    0x4(%eax),%eax
  8007fc:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ff:	eb 17                	jmp    800818 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800801:	8b 45 14             	mov    0x14(%ebp),%eax
  800804:	8b 50 04             	mov    0x4(%eax),%edx
  800807:	8b 00                	mov    (%eax),%eax
  800809:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80080c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80080f:	8b 45 14             	mov    0x14(%ebp),%eax
  800812:	8d 40 08             	lea    0x8(%eax),%eax
  800815:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800818:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80081b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80081e:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800823:	85 c9                	test   %ecx,%ecx
  800825:	0f 89 bb 00 00 00    	jns    8008e6 <vprintfmt+0x348>
				putch('-', putdat);
  80082b:	83 ec 08             	sub    $0x8,%esp
  80082e:	53                   	push   %ebx
  80082f:	6a 2d                	push   $0x2d
  800831:	ff d6                	call   *%esi
				num = -(long long) num;
  800833:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800836:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800839:	f7 da                	neg    %edx
  80083b:	83 d1 00             	adc    $0x0,%ecx
  80083e:	f7 d9                	neg    %ecx
  800840:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800843:	b8 0a 00 00 00       	mov    $0xa,%eax
  800848:	e9 99 00 00 00       	jmp    8008e6 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80084d:	8b 45 14             	mov    0x14(%ebp),%eax
  800850:	8b 00                	mov    (%eax),%eax
  800852:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800855:	99                   	cltd   
  800856:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800859:	8b 45 14             	mov    0x14(%ebp),%eax
  80085c:	8d 40 04             	lea    0x4(%eax),%eax
  80085f:	89 45 14             	mov    %eax,0x14(%ebp)
  800862:	eb b4                	jmp    800818 <vprintfmt+0x27a>
	if (lflag >= 2)
  800864:	83 f9 01             	cmp    $0x1,%ecx
  800867:	7f 1b                	jg     800884 <vprintfmt+0x2e6>
	else if (lflag)
  800869:	85 c9                	test   %ecx,%ecx
  80086b:	74 2c                	je     800899 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80086d:	8b 45 14             	mov    0x14(%ebp),%eax
  800870:	8b 10                	mov    (%eax),%edx
  800872:	b9 00 00 00 00       	mov    $0x0,%ecx
  800877:	8d 40 04             	lea    0x4(%eax),%eax
  80087a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80087d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800882:	eb 62                	jmp    8008e6 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800884:	8b 45 14             	mov    0x14(%ebp),%eax
  800887:	8b 10                	mov    (%eax),%edx
  800889:	8b 48 04             	mov    0x4(%eax),%ecx
  80088c:	8d 40 08             	lea    0x8(%eax),%eax
  80088f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800892:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800897:	eb 4d                	jmp    8008e6 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800899:	8b 45 14             	mov    0x14(%ebp),%eax
  80089c:	8b 10                	mov    (%eax),%edx
  80089e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008a3:	8d 40 04             	lea    0x4(%eax),%eax
  8008a6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8008a9:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8008ae:	eb 36                	jmp    8008e6 <vprintfmt+0x348>
	if (lflag >= 2)
  8008b0:	83 f9 01             	cmp    $0x1,%ecx
  8008b3:	7f 17                	jg     8008cc <vprintfmt+0x32e>
	else if (lflag)
  8008b5:	85 c9                	test   %ecx,%ecx
  8008b7:	74 6e                	je     800927 <vprintfmt+0x389>
		return va_arg(*ap, long);
  8008b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bc:	8b 10                	mov    (%eax),%edx
  8008be:	89 d0                	mov    %edx,%eax
  8008c0:	99                   	cltd   
  8008c1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008c4:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008c7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008ca:	eb 11                	jmp    8008dd <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8008cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cf:	8b 50 04             	mov    0x4(%eax),%edx
  8008d2:	8b 00                	mov    (%eax),%eax
  8008d4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008d7:	8d 49 08             	lea    0x8(%ecx),%ecx
  8008da:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8008dd:	89 d1                	mov    %edx,%ecx
  8008df:	89 c2                	mov    %eax,%edx
            base = 8;
  8008e1:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008e6:	83 ec 0c             	sub    $0xc,%esp
  8008e9:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008ed:	57                   	push   %edi
  8008ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8008f1:	50                   	push   %eax
  8008f2:	51                   	push   %ecx
  8008f3:	52                   	push   %edx
  8008f4:	89 da                	mov    %ebx,%edx
  8008f6:	89 f0                	mov    %esi,%eax
  8008f8:	e8 b6 fb ff ff       	call   8004b3 <printnum>
			break;
  8008fd:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800900:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800903:	83 c7 01             	add    $0x1,%edi
  800906:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80090a:	83 f8 25             	cmp    $0x25,%eax
  80090d:	0f 84 a6 fc ff ff    	je     8005b9 <vprintfmt+0x1b>
			if (ch == '\0')
  800913:	85 c0                	test   %eax,%eax
  800915:	0f 84 ce 00 00 00    	je     8009e9 <vprintfmt+0x44b>
			putch(ch, putdat);
  80091b:	83 ec 08             	sub    $0x8,%esp
  80091e:	53                   	push   %ebx
  80091f:	50                   	push   %eax
  800920:	ff d6                	call   *%esi
  800922:	83 c4 10             	add    $0x10,%esp
  800925:	eb dc                	jmp    800903 <vprintfmt+0x365>
		return va_arg(*ap, int);
  800927:	8b 45 14             	mov    0x14(%ebp),%eax
  80092a:	8b 10                	mov    (%eax),%edx
  80092c:	89 d0                	mov    %edx,%eax
  80092e:	99                   	cltd   
  80092f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800932:	8d 49 04             	lea    0x4(%ecx),%ecx
  800935:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800938:	eb a3                	jmp    8008dd <vprintfmt+0x33f>
			putch('0', putdat);
  80093a:	83 ec 08             	sub    $0x8,%esp
  80093d:	53                   	push   %ebx
  80093e:	6a 30                	push   $0x30
  800940:	ff d6                	call   *%esi
			putch('x', putdat);
  800942:	83 c4 08             	add    $0x8,%esp
  800945:	53                   	push   %ebx
  800946:	6a 78                	push   $0x78
  800948:	ff d6                	call   *%esi
			num = (unsigned long long)
  80094a:	8b 45 14             	mov    0x14(%ebp),%eax
  80094d:	8b 10                	mov    (%eax),%edx
  80094f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800954:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800957:	8d 40 04             	lea    0x4(%eax),%eax
  80095a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80095d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800962:	eb 82                	jmp    8008e6 <vprintfmt+0x348>
	if (lflag >= 2)
  800964:	83 f9 01             	cmp    $0x1,%ecx
  800967:	7f 1e                	jg     800987 <vprintfmt+0x3e9>
	else if (lflag)
  800969:	85 c9                	test   %ecx,%ecx
  80096b:	74 32                	je     80099f <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80096d:	8b 45 14             	mov    0x14(%ebp),%eax
  800970:	8b 10                	mov    (%eax),%edx
  800972:	b9 00 00 00 00       	mov    $0x0,%ecx
  800977:	8d 40 04             	lea    0x4(%eax),%eax
  80097a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80097d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800982:	e9 5f ff ff ff       	jmp    8008e6 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800987:	8b 45 14             	mov    0x14(%ebp),%eax
  80098a:	8b 10                	mov    (%eax),%edx
  80098c:	8b 48 04             	mov    0x4(%eax),%ecx
  80098f:	8d 40 08             	lea    0x8(%eax),%eax
  800992:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800995:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80099a:	e9 47 ff ff ff       	jmp    8008e6 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80099f:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a2:	8b 10                	mov    (%eax),%edx
  8009a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009a9:	8d 40 04             	lea    0x4(%eax),%eax
  8009ac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009af:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8009b4:	e9 2d ff ff ff       	jmp    8008e6 <vprintfmt+0x348>
			putch(ch, putdat);
  8009b9:	83 ec 08             	sub    $0x8,%esp
  8009bc:	53                   	push   %ebx
  8009bd:	6a 25                	push   $0x25
  8009bf:	ff d6                	call   *%esi
			break;
  8009c1:	83 c4 10             	add    $0x10,%esp
  8009c4:	e9 37 ff ff ff       	jmp    800900 <vprintfmt+0x362>
			putch('%', putdat);
  8009c9:	83 ec 08             	sub    $0x8,%esp
  8009cc:	53                   	push   %ebx
  8009cd:	6a 25                	push   $0x25
  8009cf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009d1:	83 c4 10             	add    $0x10,%esp
  8009d4:	89 f8                	mov    %edi,%eax
  8009d6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009da:	74 05                	je     8009e1 <vprintfmt+0x443>
  8009dc:	83 e8 01             	sub    $0x1,%eax
  8009df:	eb f5                	jmp    8009d6 <vprintfmt+0x438>
  8009e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009e4:	e9 17 ff ff ff       	jmp    800900 <vprintfmt+0x362>
}
  8009e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009ec:	5b                   	pop    %ebx
  8009ed:	5e                   	pop    %esi
  8009ee:	5f                   	pop    %edi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009f1:	f3 0f 1e fb          	endbr32 
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	83 ec 18             	sub    $0x18,%esp
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a01:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a04:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a08:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a0b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a12:	85 c0                	test   %eax,%eax
  800a14:	74 26                	je     800a3c <vsnprintf+0x4b>
  800a16:	85 d2                	test   %edx,%edx
  800a18:	7e 22                	jle    800a3c <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a1a:	ff 75 14             	pushl  0x14(%ebp)
  800a1d:	ff 75 10             	pushl  0x10(%ebp)
  800a20:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a23:	50                   	push   %eax
  800a24:	68 5c 05 80 00       	push   $0x80055c
  800a29:	e8 70 fb ff ff       	call   80059e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a31:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a37:	83 c4 10             	add    $0x10,%esp
}
  800a3a:	c9                   	leave  
  800a3b:	c3                   	ret    
		return -E_INVAL;
  800a3c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a41:	eb f7                	jmp    800a3a <vsnprintf+0x49>

00800a43 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a43:	f3 0f 1e fb          	endbr32 
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a4d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a50:	50                   	push   %eax
  800a51:	ff 75 10             	pushl  0x10(%ebp)
  800a54:	ff 75 0c             	pushl  0xc(%ebp)
  800a57:	ff 75 08             	pushl  0x8(%ebp)
  800a5a:	e8 92 ff ff ff       	call   8009f1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a5f:	c9                   	leave  
  800a60:	c3                   	ret    

00800a61 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a61:	f3 0f 1e fb          	endbr32 
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a70:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a74:	74 05                	je     800a7b <strlen+0x1a>
		n++;
  800a76:	83 c0 01             	add    $0x1,%eax
  800a79:	eb f5                	jmp    800a70 <strlen+0xf>
	return n;
}
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a7d:	f3 0f 1e fb          	endbr32 
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a87:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8f:	39 d0                	cmp    %edx,%eax
  800a91:	74 0d                	je     800aa0 <strnlen+0x23>
  800a93:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a97:	74 05                	je     800a9e <strnlen+0x21>
		n++;
  800a99:	83 c0 01             	add    $0x1,%eax
  800a9c:	eb f1                	jmp    800a8f <strnlen+0x12>
  800a9e:	89 c2                	mov    %eax,%edx
	return n;
}
  800aa0:	89 d0                	mov    %edx,%eax
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800aa4:	f3 0f 1e fb          	endbr32 
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	53                   	push   %ebx
  800aac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aaf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ab2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab7:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800abb:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800abe:	83 c0 01             	add    $0x1,%eax
  800ac1:	84 d2                	test   %dl,%dl
  800ac3:	75 f2                	jne    800ab7 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800ac5:	89 c8                	mov    %ecx,%eax
  800ac7:	5b                   	pop    %ebx
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    

00800aca <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aca:	f3 0f 1e fb          	endbr32 
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	53                   	push   %ebx
  800ad2:	83 ec 10             	sub    $0x10,%esp
  800ad5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ad8:	53                   	push   %ebx
  800ad9:	e8 83 ff ff ff       	call   800a61 <strlen>
  800ade:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800ae1:	ff 75 0c             	pushl  0xc(%ebp)
  800ae4:	01 d8                	add    %ebx,%eax
  800ae6:	50                   	push   %eax
  800ae7:	e8 b8 ff ff ff       	call   800aa4 <strcpy>
	return dst;
}
  800aec:	89 d8                	mov    %ebx,%eax
  800aee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800af1:	c9                   	leave  
  800af2:	c3                   	ret    

00800af3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800af3:	f3 0f 1e fb          	endbr32 
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
  800afc:	8b 75 08             	mov    0x8(%ebp),%esi
  800aff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b02:	89 f3                	mov    %esi,%ebx
  800b04:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b07:	89 f0                	mov    %esi,%eax
  800b09:	39 d8                	cmp    %ebx,%eax
  800b0b:	74 11                	je     800b1e <strncpy+0x2b>
		*dst++ = *src;
  800b0d:	83 c0 01             	add    $0x1,%eax
  800b10:	0f b6 0a             	movzbl (%edx),%ecx
  800b13:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b16:	80 f9 01             	cmp    $0x1,%cl
  800b19:	83 da ff             	sbb    $0xffffffff,%edx
  800b1c:	eb eb                	jmp    800b09 <strncpy+0x16>
	}
	return ret;
}
  800b1e:	89 f0                	mov    %esi,%eax
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b24:	f3 0f 1e fb          	endbr32 
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
  800b2d:	8b 75 08             	mov    0x8(%ebp),%esi
  800b30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b33:	8b 55 10             	mov    0x10(%ebp),%edx
  800b36:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b38:	85 d2                	test   %edx,%edx
  800b3a:	74 21                	je     800b5d <strlcpy+0x39>
  800b3c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b40:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b42:	39 c2                	cmp    %eax,%edx
  800b44:	74 14                	je     800b5a <strlcpy+0x36>
  800b46:	0f b6 19             	movzbl (%ecx),%ebx
  800b49:	84 db                	test   %bl,%bl
  800b4b:	74 0b                	je     800b58 <strlcpy+0x34>
			*dst++ = *src++;
  800b4d:	83 c1 01             	add    $0x1,%ecx
  800b50:	83 c2 01             	add    $0x1,%edx
  800b53:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b56:	eb ea                	jmp    800b42 <strlcpy+0x1e>
  800b58:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b5a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b5d:	29 f0                	sub    %esi,%eax
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b63:	f3 0f 1e fb          	endbr32 
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b70:	0f b6 01             	movzbl (%ecx),%eax
  800b73:	84 c0                	test   %al,%al
  800b75:	74 0c                	je     800b83 <strcmp+0x20>
  800b77:	3a 02                	cmp    (%edx),%al
  800b79:	75 08                	jne    800b83 <strcmp+0x20>
		p++, q++;
  800b7b:	83 c1 01             	add    $0x1,%ecx
  800b7e:	83 c2 01             	add    $0x1,%edx
  800b81:	eb ed                	jmp    800b70 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b83:	0f b6 c0             	movzbl %al,%eax
  800b86:	0f b6 12             	movzbl (%edx),%edx
  800b89:	29 d0                	sub    %edx,%eax
}
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b8d:	f3 0f 1e fb          	endbr32 
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	53                   	push   %ebx
  800b95:	8b 45 08             	mov    0x8(%ebp),%eax
  800b98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b9b:	89 c3                	mov    %eax,%ebx
  800b9d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ba0:	eb 06                	jmp    800ba8 <strncmp+0x1b>
		n--, p++, q++;
  800ba2:	83 c0 01             	add    $0x1,%eax
  800ba5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ba8:	39 d8                	cmp    %ebx,%eax
  800baa:	74 16                	je     800bc2 <strncmp+0x35>
  800bac:	0f b6 08             	movzbl (%eax),%ecx
  800baf:	84 c9                	test   %cl,%cl
  800bb1:	74 04                	je     800bb7 <strncmp+0x2a>
  800bb3:	3a 0a                	cmp    (%edx),%cl
  800bb5:	74 eb                	je     800ba2 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bb7:	0f b6 00             	movzbl (%eax),%eax
  800bba:	0f b6 12             	movzbl (%edx),%edx
  800bbd:	29 d0                	sub    %edx,%eax
}
  800bbf:	5b                   	pop    %ebx
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    
		return 0;
  800bc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc7:	eb f6                	jmp    800bbf <strncmp+0x32>

00800bc9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bc9:	f3 0f 1e fb          	endbr32 
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bd7:	0f b6 10             	movzbl (%eax),%edx
  800bda:	84 d2                	test   %dl,%dl
  800bdc:	74 09                	je     800be7 <strchr+0x1e>
		if (*s == c)
  800bde:	38 ca                	cmp    %cl,%dl
  800be0:	74 0a                	je     800bec <strchr+0x23>
	for (; *s; s++)
  800be2:	83 c0 01             	add    $0x1,%eax
  800be5:	eb f0                	jmp    800bd7 <strchr+0xe>
			return (char *) s;
	return 0;
  800be7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    

00800bee <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bee:	f3 0f 1e fb          	endbr32 
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bfc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bff:	38 ca                	cmp    %cl,%dl
  800c01:	74 09                	je     800c0c <strfind+0x1e>
  800c03:	84 d2                	test   %dl,%dl
  800c05:	74 05                	je     800c0c <strfind+0x1e>
	for (; *s; s++)
  800c07:	83 c0 01             	add    $0x1,%eax
  800c0a:	eb f0                	jmp    800bfc <strfind+0xe>
			break;
	return (char *) s;
}
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c0e:	f3 0f 1e fb          	endbr32 
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c1e:	85 c9                	test   %ecx,%ecx
  800c20:	74 31                	je     800c53 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c22:	89 f8                	mov    %edi,%eax
  800c24:	09 c8                	or     %ecx,%eax
  800c26:	a8 03                	test   $0x3,%al
  800c28:	75 23                	jne    800c4d <memset+0x3f>
		c &= 0xFF;
  800c2a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c2e:	89 d3                	mov    %edx,%ebx
  800c30:	c1 e3 08             	shl    $0x8,%ebx
  800c33:	89 d0                	mov    %edx,%eax
  800c35:	c1 e0 18             	shl    $0x18,%eax
  800c38:	89 d6                	mov    %edx,%esi
  800c3a:	c1 e6 10             	shl    $0x10,%esi
  800c3d:	09 f0                	or     %esi,%eax
  800c3f:	09 c2                	or     %eax,%edx
  800c41:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c43:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c46:	89 d0                	mov    %edx,%eax
  800c48:	fc                   	cld    
  800c49:	f3 ab                	rep stos %eax,%es:(%edi)
  800c4b:	eb 06                	jmp    800c53 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c50:	fc                   	cld    
  800c51:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c53:	89 f8                	mov    %edi,%eax
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c5a:	f3 0f 1e fb          	endbr32 
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	8b 45 08             	mov    0x8(%ebp),%eax
  800c66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c69:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c6c:	39 c6                	cmp    %eax,%esi
  800c6e:	73 32                	jae    800ca2 <memmove+0x48>
  800c70:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c73:	39 c2                	cmp    %eax,%edx
  800c75:	76 2b                	jbe    800ca2 <memmove+0x48>
		s += n;
		d += n;
  800c77:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c7a:	89 fe                	mov    %edi,%esi
  800c7c:	09 ce                	or     %ecx,%esi
  800c7e:	09 d6                	or     %edx,%esi
  800c80:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c86:	75 0e                	jne    800c96 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c88:	83 ef 04             	sub    $0x4,%edi
  800c8b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c8e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c91:	fd                   	std    
  800c92:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c94:	eb 09                	jmp    800c9f <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c96:	83 ef 01             	sub    $0x1,%edi
  800c99:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c9c:	fd                   	std    
  800c9d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c9f:	fc                   	cld    
  800ca0:	eb 1a                	jmp    800cbc <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ca2:	89 c2                	mov    %eax,%edx
  800ca4:	09 ca                	or     %ecx,%edx
  800ca6:	09 f2                	or     %esi,%edx
  800ca8:	f6 c2 03             	test   $0x3,%dl
  800cab:	75 0a                	jne    800cb7 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cad:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800cb0:	89 c7                	mov    %eax,%edi
  800cb2:	fc                   	cld    
  800cb3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cb5:	eb 05                	jmp    800cbc <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800cb7:	89 c7                	mov    %eax,%edi
  800cb9:	fc                   	cld    
  800cba:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cc0:	f3 0f 1e fb          	endbr32 
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cca:	ff 75 10             	pushl  0x10(%ebp)
  800ccd:	ff 75 0c             	pushl  0xc(%ebp)
  800cd0:	ff 75 08             	pushl  0x8(%ebp)
  800cd3:	e8 82 ff ff ff       	call   800c5a <memmove>
}
  800cd8:	c9                   	leave  
  800cd9:	c3                   	ret    

00800cda <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cda:	f3 0f 1e fb          	endbr32 
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
  800ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ce9:	89 c6                	mov    %eax,%esi
  800ceb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cee:	39 f0                	cmp    %esi,%eax
  800cf0:	74 1c                	je     800d0e <memcmp+0x34>
		if (*s1 != *s2)
  800cf2:	0f b6 08             	movzbl (%eax),%ecx
  800cf5:	0f b6 1a             	movzbl (%edx),%ebx
  800cf8:	38 d9                	cmp    %bl,%cl
  800cfa:	75 08                	jne    800d04 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cfc:	83 c0 01             	add    $0x1,%eax
  800cff:	83 c2 01             	add    $0x1,%edx
  800d02:	eb ea                	jmp    800cee <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800d04:	0f b6 c1             	movzbl %cl,%eax
  800d07:	0f b6 db             	movzbl %bl,%ebx
  800d0a:	29 d8                	sub    %ebx,%eax
  800d0c:	eb 05                	jmp    800d13 <memcmp+0x39>
	}

	return 0;
  800d0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d13:	5b                   	pop    %ebx
  800d14:	5e                   	pop    %esi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d17:	f3 0f 1e fb          	endbr32 
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d24:	89 c2                	mov    %eax,%edx
  800d26:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d29:	39 d0                	cmp    %edx,%eax
  800d2b:	73 09                	jae    800d36 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d2d:	38 08                	cmp    %cl,(%eax)
  800d2f:	74 05                	je     800d36 <memfind+0x1f>
	for (; s < ends; s++)
  800d31:	83 c0 01             	add    $0x1,%eax
  800d34:	eb f3                	jmp    800d29 <memfind+0x12>
			break;
	return (void *) s;
}
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d38:	f3 0f 1e fb          	endbr32 
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
  800d42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d45:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d48:	eb 03                	jmp    800d4d <strtol+0x15>
		s++;
  800d4a:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d4d:	0f b6 01             	movzbl (%ecx),%eax
  800d50:	3c 20                	cmp    $0x20,%al
  800d52:	74 f6                	je     800d4a <strtol+0x12>
  800d54:	3c 09                	cmp    $0x9,%al
  800d56:	74 f2                	je     800d4a <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d58:	3c 2b                	cmp    $0x2b,%al
  800d5a:	74 2a                	je     800d86 <strtol+0x4e>
	int neg = 0;
  800d5c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d61:	3c 2d                	cmp    $0x2d,%al
  800d63:	74 2b                	je     800d90 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d65:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d6b:	75 0f                	jne    800d7c <strtol+0x44>
  800d6d:	80 39 30             	cmpb   $0x30,(%ecx)
  800d70:	74 28                	je     800d9a <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d72:	85 db                	test   %ebx,%ebx
  800d74:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d79:	0f 44 d8             	cmove  %eax,%ebx
  800d7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d81:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d84:	eb 46                	jmp    800dcc <strtol+0x94>
		s++;
  800d86:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d89:	bf 00 00 00 00       	mov    $0x0,%edi
  800d8e:	eb d5                	jmp    800d65 <strtol+0x2d>
		s++, neg = 1;
  800d90:	83 c1 01             	add    $0x1,%ecx
  800d93:	bf 01 00 00 00       	mov    $0x1,%edi
  800d98:	eb cb                	jmp    800d65 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d9a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d9e:	74 0e                	je     800dae <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800da0:	85 db                	test   %ebx,%ebx
  800da2:	75 d8                	jne    800d7c <strtol+0x44>
		s++, base = 8;
  800da4:	83 c1 01             	add    $0x1,%ecx
  800da7:	bb 08 00 00 00       	mov    $0x8,%ebx
  800dac:	eb ce                	jmp    800d7c <strtol+0x44>
		s += 2, base = 16;
  800dae:	83 c1 02             	add    $0x2,%ecx
  800db1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800db6:	eb c4                	jmp    800d7c <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800db8:	0f be d2             	movsbl %dl,%edx
  800dbb:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800dbe:	3b 55 10             	cmp    0x10(%ebp),%edx
  800dc1:	7d 3a                	jge    800dfd <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800dc3:	83 c1 01             	add    $0x1,%ecx
  800dc6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800dca:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800dcc:	0f b6 11             	movzbl (%ecx),%edx
  800dcf:	8d 72 d0             	lea    -0x30(%edx),%esi
  800dd2:	89 f3                	mov    %esi,%ebx
  800dd4:	80 fb 09             	cmp    $0x9,%bl
  800dd7:	76 df                	jbe    800db8 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800dd9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ddc:	89 f3                	mov    %esi,%ebx
  800dde:	80 fb 19             	cmp    $0x19,%bl
  800de1:	77 08                	ja     800deb <strtol+0xb3>
			dig = *s - 'a' + 10;
  800de3:	0f be d2             	movsbl %dl,%edx
  800de6:	83 ea 57             	sub    $0x57,%edx
  800de9:	eb d3                	jmp    800dbe <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800deb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dee:	89 f3                	mov    %esi,%ebx
  800df0:	80 fb 19             	cmp    $0x19,%bl
  800df3:	77 08                	ja     800dfd <strtol+0xc5>
			dig = *s - 'A' + 10;
  800df5:	0f be d2             	movsbl %dl,%edx
  800df8:	83 ea 37             	sub    $0x37,%edx
  800dfb:	eb c1                	jmp    800dbe <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dfd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e01:	74 05                	je     800e08 <strtol+0xd0>
		*endptr = (char *) s;
  800e03:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e06:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800e08:	89 c2                	mov    %eax,%edx
  800e0a:	f7 da                	neg    %edx
  800e0c:	85 ff                	test   %edi,%edi
  800e0e:	0f 45 c2             	cmovne %edx,%eax
}
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    
  800e16:	66 90                	xchg   %ax,%ax
  800e18:	66 90                	xchg   %ax,%ax
  800e1a:	66 90                	xchg   %ax,%ax
  800e1c:	66 90                	xchg   %ax,%ax
  800e1e:	66 90                	xchg   %ax,%ax

00800e20 <__udivdi3>:
  800e20:	f3 0f 1e fb          	endbr32 
  800e24:	55                   	push   %ebp
  800e25:	57                   	push   %edi
  800e26:	56                   	push   %esi
  800e27:	53                   	push   %ebx
  800e28:	83 ec 1c             	sub    $0x1c,%esp
  800e2b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e2f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e33:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e37:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e3b:	85 d2                	test   %edx,%edx
  800e3d:	75 19                	jne    800e58 <__udivdi3+0x38>
  800e3f:	39 f3                	cmp    %esi,%ebx
  800e41:	76 4d                	jbe    800e90 <__udivdi3+0x70>
  800e43:	31 ff                	xor    %edi,%edi
  800e45:	89 e8                	mov    %ebp,%eax
  800e47:	89 f2                	mov    %esi,%edx
  800e49:	f7 f3                	div    %ebx
  800e4b:	89 fa                	mov    %edi,%edx
  800e4d:	83 c4 1c             	add    $0x1c,%esp
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    
  800e55:	8d 76 00             	lea    0x0(%esi),%esi
  800e58:	39 f2                	cmp    %esi,%edx
  800e5a:	76 14                	jbe    800e70 <__udivdi3+0x50>
  800e5c:	31 ff                	xor    %edi,%edi
  800e5e:	31 c0                	xor    %eax,%eax
  800e60:	89 fa                	mov    %edi,%edx
  800e62:	83 c4 1c             	add    $0x1c,%esp
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    
  800e6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e70:	0f bd fa             	bsr    %edx,%edi
  800e73:	83 f7 1f             	xor    $0x1f,%edi
  800e76:	75 48                	jne    800ec0 <__udivdi3+0xa0>
  800e78:	39 f2                	cmp    %esi,%edx
  800e7a:	72 06                	jb     800e82 <__udivdi3+0x62>
  800e7c:	31 c0                	xor    %eax,%eax
  800e7e:	39 eb                	cmp    %ebp,%ebx
  800e80:	77 de                	ja     800e60 <__udivdi3+0x40>
  800e82:	b8 01 00 00 00       	mov    $0x1,%eax
  800e87:	eb d7                	jmp    800e60 <__udivdi3+0x40>
  800e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e90:	89 d9                	mov    %ebx,%ecx
  800e92:	85 db                	test   %ebx,%ebx
  800e94:	75 0b                	jne    800ea1 <__udivdi3+0x81>
  800e96:	b8 01 00 00 00       	mov    $0x1,%eax
  800e9b:	31 d2                	xor    %edx,%edx
  800e9d:	f7 f3                	div    %ebx
  800e9f:	89 c1                	mov    %eax,%ecx
  800ea1:	31 d2                	xor    %edx,%edx
  800ea3:	89 f0                	mov    %esi,%eax
  800ea5:	f7 f1                	div    %ecx
  800ea7:	89 c6                	mov    %eax,%esi
  800ea9:	89 e8                	mov    %ebp,%eax
  800eab:	89 f7                	mov    %esi,%edi
  800ead:	f7 f1                	div    %ecx
  800eaf:	89 fa                	mov    %edi,%edx
  800eb1:	83 c4 1c             	add    $0x1c,%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    
  800eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	89 f9                	mov    %edi,%ecx
  800ec2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ec7:	29 f8                	sub    %edi,%eax
  800ec9:	d3 e2                	shl    %cl,%edx
  800ecb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ecf:	89 c1                	mov    %eax,%ecx
  800ed1:	89 da                	mov    %ebx,%edx
  800ed3:	d3 ea                	shr    %cl,%edx
  800ed5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ed9:	09 d1                	or     %edx,%ecx
  800edb:	89 f2                	mov    %esi,%edx
  800edd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ee1:	89 f9                	mov    %edi,%ecx
  800ee3:	d3 e3                	shl    %cl,%ebx
  800ee5:	89 c1                	mov    %eax,%ecx
  800ee7:	d3 ea                	shr    %cl,%edx
  800ee9:	89 f9                	mov    %edi,%ecx
  800eeb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800eef:	89 eb                	mov    %ebp,%ebx
  800ef1:	d3 e6                	shl    %cl,%esi
  800ef3:	89 c1                	mov    %eax,%ecx
  800ef5:	d3 eb                	shr    %cl,%ebx
  800ef7:	09 de                	or     %ebx,%esi
  800ef9:	89 f0                	mov    %esi,%eax
  800efb:	f7 74 24 08          	divl   0x8(%esp)
  800eff:	89 d6                	mov    %edx,%esi
  800f01:	89 c3                	mov    %eax,%ebx
  800f03:	f7 64 24 0c          	mull   0xc(%esp)
  800f07:	39 d6                	cmp    %edx,%esi
  800f09:	72 15                	jb     800f20 <__udivdi3+0x100>
  800f0b:	89 f9                	mov    %edi,%ecx
  800f0d:	d3 e5                	shl    %cl,%ebp
  800f0f:	39 c5                	cmp    %eax,%ebp
  800f11:	73 04                	jae    800f17 <__udivdi3+0xf7>
  800f13:	39 d6                	cmp    %edx,%esi
  800f15:	74 09                	je     800f20 <__udivdi3+0x100>
  800f17:	89 d8                	mov    %ebx,%eax
  800f19:	31 ff                	xor    %edi,%edi
  800f1b:	e9 40 ff ff ff       	jmp    800e60 <__udivdi3+0x40>
  800f20:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f23:	31 ff                	xor    %edi,%edi
  800f25:	e9 36 ff ff ff       	jmp    800e60 <__udivdi3+0x40>
  800f2a:	66 90                	xchg   %ax,%ax
  800f2c:	66 90                	xchg   %ax,%ax
  800f2e:	66 90                	xchg   %ax,%ax

00800f30 <__umoddi3>:
  800f30:	f3 0f 1e fb          	endbr32 
  800f34:	55                   	push   %ebp
  800f35:	57                   	push   %edi
  800f36:	56                   	push   %esi
  800f37:	53                   	push   %ebx
  800f38:	83 ec 1c             	sub    $0x1c,%esp
  800f3b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f3f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f43:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f47:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	75 19                	jne    800f68 <__umoddi3+0x38>
  800f4f:	39 df                	cmp    %ebx,%edi
  800f51:	76 5d                	jbe    800fb0 <__umoddi3+0x80>
  800f53:	89 f0                	mov    %esi,%eax
  800f55:	89 da                	mov    %ebx,%edx
  800f57:	f7 f7                	div    %edi
  800f59:	89 d0                	mov    %edx,%eax
  800f5b:	31 d2                	xor    %edx,%edx
  800f5d:	83 c4 1c             	add    $0x1c,%esp
  800f60:	5b                   	pop    %ebx
  800f61:	5e                   	pop    %esi
  800f62:	5f                   	pop    %edi
  800f63:	5d                   	pop    %ebp
  800f64:	c3                   	ret    
  800f65:	8d 76 00             	lea    0x0(%esi),%esi
  800f68:	89 f2                	mov    %esi,%edx
  800f6a:	39 d8                	cmp    %ebx,%eax
  800f6c:	76 12                	jbe    800f80 <__umoddi3+0x50>
  800f6e:	89 f0                	mov    %esi,%eax
  800f70:	89 da                	mov    %ebx,%edx
  800f72:	83 c4 1c             	add    $0x1c,%esp
  800f75:	5b                   	pop    %ebx
  800f76:	5e                   	pop    %esi
  800f77:	5f                   	pop    %edi
  800f78:	5d                   	pop    %ebp
  800f79:	c3                   	ret    
  800f7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f80:	0f bd e8             	bsr    %eax,%ebp
  800f83:	83 f5 1f             	xor    $0x1f,%ebp
  800f86:	75 50                	jne    800fd8 <__umoddi3+0xa8>
  800f88:	39 d8                	cmp    %ebx,%eax
  800f8a:	0f 82 e0 00 00 00    	jb     801070 <__umoddi3+0x140>
  800f90:	89 d9                	mov    %ebx,%ecx
  800f92:	39 f7                	cmp    %esi,%edi
  800f94:	0f 86 d6 00 00 00    	jbe    801070 <__umoddi3+0x140>
  800f9a:	89 d0                	mov    %edx,%eax
  800f9c:	89 ca                	mov    %ecx,%edx
  800f9e:	83 c4 1c             	add    $0x1c,%esp
  800fa1:	5b                   	pop    %ebx
  800fa2:	5e                   	pop    %esi
  800fa3:	5f                   	pop    %edi
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    
  800fa6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fad:	8d 76 00             	lea    0x0(%esi),%esi
  800fb0:	89 fd                	mov    %edi,%ebp
  800fb2:	85 ff                	test   %edi,%edi
  800fb4:	75 0b                	jne    800fc1 <__umoddi3+0x91>
  800fb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fbb:	31 d2                	xor    %edx,%edx
  800fbd:	f7 f7                	div    %edi
  800fbf:	89 c5                	mov    %eax,%ebp
  800fc1:	89 d8                	mov    %ebx,%eax
  800fc3:	31 d2                	xor    %edx,%edx
  800fc5:	f7 f5                	div    %ebp
  800fc7:	89 f0                	mov    %esi,%eax
  800fc9:	f7 f5                	div    %ebp
  800fcb:	89 d0                	mov    %edx,%eax
  800fcd:	31 d2                	xor    %edx,%edx
  800fcf:	eb 8c                	jmp    800f5d <__umoddi3+0x2d>
  800fd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fd8:	89 e9                	mov    %ebp,%ecx
  800fda:	ba 20 00 00 00       	mov    $0x20,%edx
  800fdf:	29 ea                	sub    %ebp,%edx
  800fe1:	d3 e0                	shl    %cl,%eax
  800fe3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fe7:	89 d1                	mov    %edx,%ecx
  800fe9:	89 f8                	mov    %edi,%eax
  800feb:	d3 e8                	shr    %cl,%eax
  800fed:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ff1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ff5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ff9:	09 c1                	or     %eax,%ecx
  800ffb:	89 d8                	mov    %ebx,%eax
  800ffd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801001:	89 e9                	mov    %ebp,%ecx
  801003:	d3 e7                	shl    %cl,%edi
  801005:	89 d1                	mov    %edx,%ecx
  801007:	d3 e8                	shr    %cl,%eax
  801009:	89 e9                	mov    %ebp,%ecx
  80100b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80100f:	d3 e3                	shl    %cl,%ebx
  801011:	89 c7                	mov    %eax,%edi
  801013:	89 d1                	mov    %edx,%ecx
  801015:	89 f0                	mov    %esi,%eax
  801017:	d3 e8                	shr    %cl,%eax
  801019:	89 e9                	mov    %ebp,%ecx
  80101b:	89 fa                	mov    %edi,%edx
  80101d:	d3 e6                	shl    %cl,%esi
  80101f:	09 d8                	or     %ebx,%eax
  801021:	f7 74 24 08          	divl   0x8(%esp)
  801025:	89 d1                	mov    %edx,%ecx
  801027:	89 f3                	mov    %esi,%ebx
  801029:	f7 64 24 0c          	mull   0xc(%esp)
  80102d:	89 c6                	mov    %eax,%esi
  80102f:	89 d7                	mov    %edx,%edi
  801031:	39 d1                	cmp    %edx,%ecx
  801033:	72 06                	jb     80103b <__umoddi3+0x10b>
  801035:	75 10                	jne    801047 <__umoddi3+0x117>
  801037:	39 c3                	cmp    %eax,%ebx
  801039:	73 0c                	jae    801047 <__umoddi3+0x117>
  80103b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80103f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801043:	89 d7                	mov    %edx,%edi
  801045:	89 c6                	mov    %eax,%esi
  801047:	89 ca                	mov    %ecx,%edx
  801049:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80104e:	29 f3                	sub    %esi,%ebx
  801050:	19 fa                	sbb    %edi,%edx
  801052:	89 d0                	mov    %edx,%eax
  801054:	d3 e0                	shl    %cl,%eax
  801056:	89 e9                	mov    %ebp,%ecx
  801058:	d3 eb                	shr    %cl,%ebx
  80105a:	d3 ea                	shr    %cl,%edx
  80105c:	09 d8                	or     %ebx,%eax
  80105e:	83 c4 1c             	add    $0x1c,%esp
  801061:	5b                   	pop    %ebx
  801062:	5e                   	pop    %esi
  801063:	5f                   	pop    %edi
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    
  801066:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80106d:	8d 76 00             	lea    0x0(%esi),%esi
  801070:	29 fe                	sub    %edi,%esi
  801072:	19 c3                	sbb    %eax,%ebx
  801074:	89 f2                	mov    %esi,%edx
  801076:	89 d9                	mov    %ebx,%ecx
  801078:	e9 1d ff ff ff       	jmp    800f9a <__umoddi3+0x6a>
