
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
  80014c:	68 6a 10 80 00       	push   $0x80106a
  800151:	6a 23                	push   $0x23
  800153:	68 87 10 80 00       	push   $0x801087
  800158:	e8 36 02 00 00       	call   800393 <_panic>

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
  8001d9:	68 6a 10 80 00       	push   $0x80106a
  8001de:	6a 23                	push   $0x23
  8001e0:	68 87 10 80 00       	push   $0x801087
  8001e5:	e8 a9 01 00 00       	call   800393 <_panic>

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
  80021f:	68 6a 10 80 00       	push   $0x80106a
  800224:	6a 23                	push   $0x23
  800226:	68 87 10 80 00       	push   $0x801087
  80022b:	e8 63 01 00 00       	call   800393 <_panic>

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
  800265:	68 6a 10 80 00       	push   $0x80106a
  80026a:	6a 23                	push   $0x23
  80026c:	68 87 10 80 00       	push   $0x801087
  800271:	e8 1d 01 00 00       	call   800393 <_panic>

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
  8002ab:	68 6a 10 80 00       	push   $0x80106a
  8002b0:	6a 23                	push   $0x23
  8002b2:	68 87 10 80 00       	push   $0x801087
  8002b7:	e8 d7 00 00 00       	call   800393 <_panic>

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
  8002f1:	68 6a 10 80 00       	push   $0x80106a
  8002f6:	6a 23                	push   $0x23
  8002f8:	68 87 10 80 00       	push   $0x801087
  8002fd:	e8 91 00 00 00       	call   800393 <_panic>

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
  800337:	68 6a 10 80 00       	push   $0x80106a
  80033c:	6a 23                	push   $0x23
  80033e:	68 87 10 80 00       	push   $0x801087
  800343:	e8 4b 00 00 00       	call   800393 <_panic>

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
	asm volatile("int %1\n"
  800379:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037e:	8b 55 08             	mov    0x8(%ebp),%edx
  800381:	b8 0d 00 00 00       	mov    $0xd,%eax
  800386:	89 cb                	mov    %ecx,%ebx
  800388:	89 cf                	mov    %ecx,%edi
  80038a:	89 ce                	mov    %ecx,%esi
  80038c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 0, (uint32_t)dstva, 0, 0, 0, 0);
}
  80038e:	5b                   	pop    %ebx
  80038f:	5e                   	pop    %esi
  800390:	5f                   	pop    %edi
  800391:	5d                   	pop    %ebp
  800392:	c3                   	ret    

00800393 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800393:	f3 0f 1e fb          	endbr32 
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	56                   	push   %esi
  80039b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80039c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80039f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8003a5:	e8 b3 fd ff ff       	call   80015d <sys_getenvid>
  8003aa:	83 ec 0c             	sub    $0xc,%esp
  8003ad:	ff 75 0c             	pushl  0xc(%ebp)
  8003b0:	ff 75 08             	pushl  0x8(%ebp)
  8003b3:	56                   	push   %esi
  8003b4:	50                   	push   %eax
  8003b5:	68 98 10 80 00       	push   $0x801098
  8003ba:	e8 bb 00 00 00       	call   80047a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003bf:	83 c4 18             	add    $0x18,%esp
  8003c2:	53                   	push   %ebx
  8003c3:	ff 75 10             	pushl  0x10(%ebp)
  8003c6:	e8 5a 00 00 00       	call   800425 <vcprintf>
	cprintf("\n");
  8003cb:	c7 04 24 bb 10 80 00 	movl   $0x8010bb,(%esp)
  8003d2:	e8 a3 00 00 00       	call   80047a <cprintf>
  8003d7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003da:	cc                   	int3   
  8003db:	eb fd                	jmp    8003da <_panic+0x47>

008003dd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003dd:	f3 0f 1e fb          	endbr32 
  8003e1:	55                   	push   %ebp
  8003e2:	89 e5                	mov    %esp,%ebp
  8003e4:	53                   	push   %ebx
  8003e5:	83 ec 04             	sub    $0x4,%esp
  8003e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003eb:	8b 13                	mov    (%ebx),%edx
  8003ed:	8d 42 01             	lea    0x1(%edx),%eax
  8003f0:	89 03                	mov    %eax,(%ebx)
  8003f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003f9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003fe:	74 09                	je     800409 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800400:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800404:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800407:	c9                   	leave  
  800408:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800409:	83 ec 08             	sub    $0x8,%esp
  80040c:	68 ff 00 00 00       	push   $0xff
  800411:	8d 43 08             	lea    0x8(%ebx),%eax
  800414:	50                   	push   %eax
  800415:	e8 b9 fc ff ff       	call   8000d3 <sys_cputs>
		b->idx = 0;
  80041a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800420:	83 c4 10             	add    $0x10,%esp
  800423:	eb db                	jmp    800400 <putch+0x23>

00800425 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800425:	f3 0f 1e fb          	endbr32 
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800432:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800439:	00 00 00 
	b.cnt = 0;
  80043c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800443:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800446:	ff 75 0c             	pushl  0xc(%ebp)
  800449:	ff 75 08             	pushl  0x8(%ebp)
  80044c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800452:	50                   	push   %eax
  800453:	68 dd 03 80 00       	push   $0x8003dd
  800458:	e8 20 01 00 00       	call   80057d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80045d:	83 c4 08             	add    $0x8,%esp
  800460:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800466:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80046c:	50                   	push   %eax
  80046d:	e8 61 fc ff ff       	call   8000d3 <sys_cputs>

	return b.cnt;
}
  800472:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80047a:	f3 0f 1e fb          	endbr32 
  80047e:	55                   	push   %ebp
  80047f:	89 e5                	mov    %esp,%ebp
  800481:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800484:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800487:	50                   	push   %eax
  800488:	ff 75 08             	pushl  0x8(%ebp)
  80048b:	e8 95 ff ff ff       	call   800425 <vcprintf>
	va_end(ap);

	return cnt;
}
  800490:	c9                   	leave  
  800491:	c3                   	ret    

00800492 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800492:	55                   	push   %ebp
  800493:	89 e5                	mov    %esp,%ebp
  800495:	57                   	push   %edi
  800496:	56                   	push   %esi
  800497:	53                   	push   %ebx
  800498:	83 ec 1c             	sub    $0x1c,%esp
  80049b:	89 c7                	mov    %eax,%edi
  80049d:	89 d6                	mov    %edx,%esi
  80049f:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a5:	89 d1                	mov    %edx,%ecx
  8004a7:	89 c2                	mov    %eax,%edx
  8004a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ac:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004af:	8b 45 10             	mov    0x10(%ebp),%eax
  8004b2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004bf:	39 c2                	cmp    %eax,%edx
  8004c1:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8004c4:	72 3e                	jb     800504 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004c6:	83 ec 0c             	sub    $0xc,%esp
  8004c9:	ff 75 18             	pushl  0x18(%ebp)
  8004cc:	83 eb 01             	sub    $0x1,%ebx
  8004cf:	53                   	push   %ebx
  8004d0:	50                   	push   %eax
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004da:	ff 75 dc             	pushl  -0x24(%ebp)
  8004dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8004e0:	e8 1b 09 00 00       	call   800e00 <__udivdi3>
  8004e5:	83 c4 18             	add    $0x18,%esp
  8004e8:	52                   	push   %edx
  8004e9:	50                   	push   %eax
  8004ea:	89 f2                	mov    %esi,%edx
  8004ec:	89 f8                	mov    %edi,%eax
  8004ee:	e8 9f ff ff ff       	call   800492 <printnum>
  8004f3:	83 c4 20             	add    $0x20,%esp
  8004f6:	eb 13                	jmp    80050b <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	56                   	push   %esi
  8004fc:	ff 75 18             	pushl  0x18(%ebp)
  8004ff:	ff d7                	call   *%edi
  800501:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800504:	83 eb 01             	sub    $0x1,%ebx
  800507:	85 db                	test   %ebx,%ebx
  800509:	7f ed                	jg     8004f8 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	56                   	push   %esi
  80050f:	83 ec 04             	sub    $0x4,%esp
  800512:	ff 75 e4             	pushl  -0x1c(%ebp)
  800515:	ff 75 e0             	pushl  -0x20(%ebp)
  800518:	ff 75 dc             	pushl  -0x24(%ebp)
  80051b:	ff 75 d8             	pushl  -0x28(%ebp)
  80051e:	e8 ed 09 00 00       	call   800f10 <__umoddi3>
  800523:	83 c4 14             	add    $0x14,%esp
  800526:	0f be 80 bd 10 80 00 	movsbl 0x8010bd(%eax),%eax
  80052d:	50                   	push   %eax
  80052e:	ff d7                	call   *%edi
}
  800530:	83 c4 10             	add    $0x10,%esp
  800533:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800536:	5b                   	pop    %ebx
  800537:	5e                   	pop    %esi
  800538:	5f                   	pop    %edi
  800539:	5d                   	pop    %ebp
  80053a:	c3                   	ret    

0080053b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80053b:	f3 0f 1e fb          	endbr32 
  80053f:	55                   	push   %ebp
  800540:	89 e5                	mov    %esp,%ebp
  800542:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800545:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800549:	8b 10                	mov    (%eax),%edx
  80054b:	3b 50 04             	cmp    0x4(%eax),%edx
  80054e:	73 0a                	jae    80055a <sprintputch+0x1f>
		*b->buf++ = ch;
  800550:	8d 4a 01             	lea    0x1(%edx),%ecx
  800553:	89 08                	mov    %ecx,(%eax)
  800555:	8b 45 08             	mov    0x8(%ebp),%eax
  800558:	88 02                	mov    %al,(%edx)
}
  80055a:	5d                   	pop    %ebp
  80055b:	c3                   	ret    

0080055c <printfmt>:
{
  80055c:	f3 0f 1e fb          	endbr32 
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800566:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800569:	50                   	push   %eax
  80056a:	ff 75 10             	pushl  0x10(%ebp)
  80056d:	ff 75 0c             	pushl  0xc(%ebp)
  800570:	ff 75 08             	pushl  0x8(%ebp)
  800573:	e8 05 00 00 00       	call   80057d <vprintfmt>
}
  800578:	83 c4 10             	add    $0x10,%esp
  80057b:	c9                   	leave  
  80057c:	c3                   	ret    

0080057d <vprintfmt>:
{
  80057d:	f3 0f 1e fb          	endbr32 
  800581:	55                   	push   %ebp
  800582:	89 e5                	mov    %esp,%ebp
  800584:	57                   	push   %edi
  800585:	56                   	push   %esi
  800586:	53                   	push   %ebx
  800587:	83 ec 3c             	sub    $0x3c,%esp
  80058a:	8b 75 08             	mov    0x8(%ebp),%esi
  80058d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800590:	8b 7d 10             	mov    0x10(%ebp),%edi
  800593:	e9 4a 03 00 00       	jmp    8008e2 <vprintfmt+0x365>
		padc = ' ';
  800598:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80059c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8005a3:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8005aa:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8005b1:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005b6:	8d 47 01             	lea    0x1(%edi),%eax
  8005b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005bc:	0f b6 17             	movzbl (%edi),%edx
  8005bf:	8d 42 dd             	lea    -0x23(%edx),%eax
  8005c2:	3c 55                	cmp    $0x55,%al
  8005c4:	0f 87 de 03 00 00    	ja     8009a8 <vprintfmt+0x42b>
  8005ca:	0f b6 c0             	movzbl %al,%eax
  8005cd:	3e ff 24 85 00 12 80 	notrack jmp *0x801200(,%eax,4)
  8005d4:	00 
  8005d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005d8:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005dc:	eb d8                	jmp    8005b6 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e1:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005e5:	eb cf                	jmp    8005b6 <vprintfmt+0x39>
  8005e7:	0f b6 d2             	movzbl %dl,%edx
  8005ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005f5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005f8:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005fc:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005ff:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800602:	83 f9 09             	cmp    $0x9,%ecx
  800605:	77 55                	ja     80065c <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800607:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80060a:	eb e9                	jmp    8005f5 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8b 00                	mov    (%eax),%eax
  800611:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 40 04             	lea    0x4(%eax),%eax
  80061a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80061d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800620:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800624:	79 90                	jns    8005b6 <vprintfmt+0x39>
				width = precision, precision = -1;
  800626:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800629:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80062c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800633:	eb 81                	jmp    8005b6 <vprintfmt+0x39>
  800635:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800638:	85 c0                	test   %eax,%eax
  80063a:	ba 00 00 00 00       	mov    $0x0,%edx
  80063f:	0f 49 d0             	cmovns %eax,%edx
  800642:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800645:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800648:	e9 69 ff ff ff       	jmp    8005b6 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80064d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800650:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800657:	e9 5a ff ff ff       	jmp    8005b6 <vprintfmt+0x39>
  80065c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80065f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800662:	eb bc                	jmp    800620 <vprintfmt+0xa3>
			lflag++;
  800664:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800667:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80066a:	e9 47 ff ff ff       	jmp    8005b6 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8d 78 04             	lea    0x4(%eax),%edi
  800675:	83 ec 08             	sub    $0x8,%esp
  800678:	53                   	push   %ebx
  800679:	ff 30                	pushl  (%eax)
  80067b:	ff d6                	call   *%esi
			break;
  80067d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800680:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800683:	e9 57 02 00 00       	jmp    8008df <vprintfmt+0x362>
			err = va_arg(ap, int);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8d 78 04             	lea    0x4(%eax),%edi
  80068e:	8b 00                	mov    (%eax),%eax
  800690:	99                   	cltd   
  800691:	31 d0                	xor    %edx,%eax
  800693:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800695:	83 f8 0f             	cmp    $0xf,%eax
  800698:	7f 23                	jg     8006bd <vprintfmt+0x140>
  80069a:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  8006a1:	85 d2                	test   %edx,%edx
  8006a3:	74 18                	je     8006bd <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8006a5:	52                   	push   %edx
  8006a6:	68 de 10 80 00       	push   $0x8010de
  8006ab:	53                   	push   %ebx
  8006ac:	56                   	push   %esi
  8006ad:	e8 aa fe ff ff       	call   80055c <printfmt>
  8006b2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006b5:	89 7d 14             	mov    %edi,0x14(%ebp)
  8006b8:	e9 22 02 00 00       	jmp    8008df <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8006bd:	50                   	push   %eax
  8006be:	68 d5 10 80 00       	push   $0x8010d5
  8006c3:	53                   	push   %ebx
  8006c4:	56                   	push   %esi
  8006c5:	e8 92 fe ff ff       	call   80055c <printfmt>
  8006ca:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006cd:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8006d0:	e9 0a 02 00 00       	jmp    8008df <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	83 c0 04             	add    $0x4,%eax
  8006db:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8006e3:	85 d2                	test   %edx,%edx
  8006e5:	b8 ce 10 80 00       	mov    $0x8010ce,%eax
  8006ea:	0f 45 c2             	cmovne %edx,%eax
  8006ed:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006f4:	7e 06                	jle    8006fc <vprintfmt+0x17f>
  8006f6:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006fa:	75 0d                	jne    800709 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fc:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006ff:	89 c7                	mov    %eax,%edi
  800701:	03 45 e0             	add    -0x20(%ebp),%eax
  800704:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800707:	eb 55                	jmp    80075e <vprintfmt+0x1e1>
  800709:	83 ec 08             	sub    $0x8,%esp
  80070c:	ff 75 d8             	pushl  -0x28(%ebp)
  80070f:	ff 75 cc             	pushl  -0x34(%ebp)
  800712:	e8 45 03 00 00       	call   800a5c <strnlen>
  800717:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80071a:	29 c2                	sub    %eax,%edx
  80071c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80071f:	83 c4 10             	add    $0x10,%esp
  800722:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800724:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800728:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80072b:	85 ff                	test   %edi,%edi
  80072d:	7e 11                	jle    800740 <vprintfmt+0x1c3>
					putch(padc, putdat);
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	53                   	push   %ebx
  800733:	ff 75 e0             	pushl  -0x20(%ebp)
  800736:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800738:	83 ef 01             	sub    $0x1,%edi
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	eb eb                	jmp    80072b <vprintfmt+0x1ae>
  800740:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800743:	85 d2                	test   %edx,%edx
  800745:	b8 00 00 00 00       	mov    $0x0,%eax
  80074a:	0f 49 c2             	cmovns %edx,%eax
  80074d:	29 c2                	sub    %eax,%edx
  80074f:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800752:	eb a8                	jmp    8006fc <vprintfmt+0x17f>
					putch(ch, putdat);
  800754:	83 ec 08             	sub    $0x8,%esp
  800757:	53                   	push   %ebx
  800758:	52                   	push   %edx
  800759:	ff d6                	call   *%esi
  80075b:	83 c4 10             	add    $0x10,%esp
  80075e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800761:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800763:	83 c7 01             	add    $0x1,%edi
  800766:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80076a:	0f be d0             	movsbl %al,%edx
  80076d:	85 d2                	test   %edx,%edx
  80076f:	74 4b                	je     8007bc <vprintfmt+0x23f>
  800771:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800775:	78 06                	js     80077d <vprintfmt+0x200>
  800777:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80077b:	78 1e                	js     80079b <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80077d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800781:	74 d1                	je     800754 <vprintfmt+0x1d7>
  800783:	0f be c0             	movsbl %al,%eax
  800786:	83 e8 20             	sub    $0x20,%eax
  800789:	83 f8 5e             	cmp    $0x5e,%eax
  80078c:	76 c6                	jbe    800754 <vprintfmt+0x1d7>
					putch('?', putdat);
  80078e:	83 ec 08             	sub    $0x8,%esp
  800791:	53                   	push   %ebx
  800792:	6a 3f                	push   $0x3f
  800794:	ff d6                	call   *%esi
  800796:	83 c4 10             	add    $0x10,%esp
  800799:	eb c3                	jmp    80075e <vprintfmt+0x1e1>
  80079b:	89 cf                	mov    %ecx,%edi
  80079d:	eb 0e                	jmp    8007ad <vprintfmt+0x230>
				putch(' ', putdat);
  80079f:	83 ec 08             	sub    $0x8,%esp
  8007a2:	53                   	push   %ebx
  8007a3:	6a 20                	push   $0x20
  8007a5:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8007a7:	83 ef 01             	sub    $0x1,%edi
  8007aa:	83 c4 10             	add    $0x10,%esp
  8007ad:	85 ff                	test   %edi,%edi
  8007af:	7f ee                	jg     80079f <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8007b1:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007b4:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b7:	e9 23 01 00 00       	jmp    8008df <vprintfmt+0x362>
  8007bc:	89 cf                	mov    %ecx,%edi
  8007be:	eb ed                	jmp    8007ad <vprintfmt+0x230>
	if (lflag >= 2)
  8007c0:	83 f9 01             	cmp    $0x1,%ecx
  8007c3:	7f 1b                	jg     8007e0 <vprintfmt+0x263>
	else if (lflag)
  8007c5:	85 c9                	test   %ecx,%ecx
  8007c7:	74 63                	je     80082c <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8007c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cc:	8b 00                	mov    (%eax),%eax
  8007ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d1:	99                   	cltd   
  8007d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d8:	8d 40 04             	lea    0x4(%eax),%eax
  8007db:	89 45 14             	mov    %eax,0x14(%ebp)
  8007de:	eb 17                	jmp    8007f7 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8007e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e3:	8b 50 04             	mov    0x4(%eax),%edx
  8007e6:	8b 00                	mov    (%eax),%eax
  8007e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007eb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f1:	8d 40 08             	lea    0x8(%eax),%eax
  8007f4:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007fd:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800802:	85 c9                	test   %ecx,%ecx
  800804:	0f 89 bb 00 00 00    	jns    8008c5 <vprintfmt+0x348>
				putch('-', putdat);
  80080a:	83 ec 08             	sub    $0x8,%esp
  80080d:	53                   	push   %ebx
  80080e:	6a 2d                	push   $0x2d
  800810:	ff d6                	call   *%esi
				num = -(long long) num;
  800812:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800815:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800818:	f7 da                	neg    %edx
  80081a:	83 d1 00             	adc    $0x0,%ecx
  80081d:	f7 d9                	neg    %ecx
  80081f:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800822:	b8 0a 00 00 00       	mov    $0xa,%eax
  800827:	e9 99 00 00 00       	jmp    8008c5 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80082c:	8b 45 14             	mov    0x14(%ebp),%eax
  80082f:	8b 00                	mov    (%eax),%eax
  800831:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800834:	99                   	cltd   
  800835:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800838:	8b 45 14             	mov    0x14(%ebp),%eax
  80083b:	8d 40 04             	lea    0x4(%eax),%eax
  80083e:	89 45 14             	mov    %eax,0x14(%ebp)
  800841:	eb b4                	jmp    8007f7 <vprintfmt+0x27a>
	if (lflag >= 2)
  800843:	83 f9 01             	cmp    $0x1,%ecx
  800846:	7f 1b                	jg     800863 <vprintfmt+0x2e6>
	else if (lflag)
  800848:	85 c9                	test   %ecx,%ecx
  80084a:	74 2c                	je     800878 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80084c:	8b 45 14             	mov    0x14(%ebp),%eax
  80084f:	8b 10                	mov    (%eax),%edx
  800851:	b9 00 00 00 00       	mov    $0x0,%ecx
  800856:	8d 40 04             	lea    0x4(%eax),%eax
  800859:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80085c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800861:	eb 62                	jmp    8008c5 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800863:	8b 45 14             	mov    0x14(%ebp),%eax
  800866:	8b 10                	mov    (%eax),%edx
  800868:	8b 48 04             	mov    0x4(%eax),%ecx
  80086b:	8d 40 08             	lea    0x8(%eax),%eax
  80086e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800871:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800876:	eb 4d                	jmp    8008c5 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800878:	8b 45 14             	mov    0x14(%ebp),%eax
  80087b:	8b 10                	mov    (%eax),%edx
  80087d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800882:	8d 40 04             	lea    0x4(%eax),%eax
  800885:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800888:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80088d:	eb 36                	jmp    8008c5 <vprintfmt+0x348>
	if (lflag >= 2)
  80088f:	83 f9 01             	cmp    $0x1,%ecx
  800892:	7f 17                	jg     8008ab <vprintfmt+0x32e>
	else if (lflag)
  800894:	85 c9                	test   %ecx,%ecx
  800896:	74 6e                	je     800906 <vprintfmt+0x389>
		return va_arg(*ap, long);
  800898:	8b 45 14             	mov    0x14(%ebp),%eax
  80089b:	8b 10                	mov    (%eax),%edx
  80089d:	89 d0                	mov    %edx,%eax
  80089f:	99                   	cltd   
  8008a0:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008a3:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008a6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008a9:	eb 11                	jmp    8008bc <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8008ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ae:	8b 50 04             	mov    0x4(%eax),%edx
  8008b1:	8b 00                	mov    (%eax),%eax
  8008b3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008b6:	8d 49 08             	lea    0x8(%ecx),%ecx
  8008b9:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8008bc:	89 d1                	mov    %edx,%ecx
  8008be:	89 c2                	mov    %eax,%edx
            base = 8;
  8008c0:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008c5:	83 ec 0c             	sub    $0xc,%esp
  8008c8:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008cc:	57                   	push   %edi
  8008cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8008d0:	50                   	push   %eax
  8008d1:	51                   	push   %ecx
  8008d2:	52                   	push   %edx
  8008d3:	89 da                	mov    %ebx,%edx
  8008d5:	89 f0                	mov    %esi,%eax
  8008d7:	e8 b6 fb ff ff       	call   800492 <printnum>
			break;
  8008dc:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008e2:	83 c7 01             	add    $0x1,%edi
  8008e5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008e9:	83 f8 25             	cmp    $0x25,%eax
  8008ec:	0f 84 a6 fc ff ff    	je     800598 <vprintfmt+0x1b>
			if (ch == '\0')
  8008f2:	85 c0                	test   %eax,%eax
  8008f4:	0f 84 ce 00 00 00    	je     8009c8 <vprintfmt+0x44b>
			putch(ch, putdat);
  8008fa:	83 ec 08             	sub    $0x8,%esp
  8008fd:	53                   	push   %ebx
  8008fe:	50                   	push   %eax
  8008ff:	ff d6                	call   *%esi
  800901:	83 c4 10             	add    $0x10,%esp
  800904:	eb dc                	jmp    8008e2 <vprintfmt+0x365>
		return va_arg(*ap, int);
  800906:	8b 45 14             	mov    0x14(%ebp),%eax
  800909:	8b 10                	mov    (%eax),%edx
  80090b:	89 d0                	mov    %edx,%eax
  80090d:	99                   	cltd   
  80090e:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800911:	8d 49 04             	lea    0x4(%ecx),%ecx
  800914:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800917:	eb a3                	jmp    8008bc <vprintfmt+0x33f>
			putch('0', putdat);
  800919:	83 ec 08             	sub    $0x8,%esp
  80091c:	53                   	push   %ebx
  80091d:	6a 30                	push   $0x30
  80091f:	ff d6                	call   *%esi
			putch('x', putdat);
  800921:	83 c4 08             	add    $0x8,%esp
  800924:	53                   	push   %ebx
  800925:	6a 78                	push   $0x78
  800927:	ff d6                	call   *%esi
			num = (unsigned long long)
  800929:	8b 45 14             	mov    0x14(%ebp),%eax
  80092c:	8b 10                	mov    (%eax),%edx
  80092e:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800933:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800936:	8d 40 04             	lea    0x4(%eax),%eax
  800939:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80093c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800941:	eb 82                	jmp    8008c5 <vprintfmt+0x348>
	if (lflag >= 2)
  800943:	83 f9 01             	cmp    $0x1,%ecx
  800946:	7f 1e                	jg     800966 <vprintfmt+0x3e9>
	else if (lflag)
  800948:	85 c9                	test   %ecx,%ecx
  80094a:	74 32                	je     80097e <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80094c:	8b 45 14             	mov    0x14(%ebp),%eax
  80094f:	8b 10                	mov    (%eax),%edx
  800951:	b9 00 00 00 00       	mov    $0x0,%ecx
  800956:	8d 40 04             	lea    0x4(%eax),%eax
  800959:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80095c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800961:	e9 5f ff ff ff       	jmp    8008c5 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800966:	8b 45 14             	mov    0x14(%ebp),%eax
  800969:	8b 10                	mov    (%eax),%edx
  80096b:	8b 48 04             	mov    0x4(%eax),%ecx
  80096e:	8d 40 08             	lea    0x8(%eax),%eax
  800971:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800974:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800979:	e9 47 ff ff ff       	jmp    8008c5 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80097e:	8b 45 14             	mov    0x14(%ebp),%eax
  800981:	8b 10                	mov    (%eax),%edx
  800983:	b9 00 00 00 00       	mov    $0x0,%ecx
  800988:	8d 40 04             	lea    0x4(%eax),%eax
  80098b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80098e:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800993:	e9 2d ff ff ff       	jmp    8008c5 <vprintfmt+0x348>
			putch(ch, putdat);
  800998:	83 ec 08             	sub    $0x8,%esp
  80099b:	53                   	push   %ebx
  80099c:	6a 25                	push   $0x25
  80099e:	ff d6                	call   *%esi
			break;
  8009a0:	83 c4 10             	add    $0x10,%esp
  8009a3:	e9 37 ff ff ff       	jmp    8008df <vprintfmt+0x362>
			putch('%', putdat);
  8009a8:	83 ec 08             	sub    $0x8,%esp
  8009ab:	53                   	push   %ebx
  8009ac:	6a 25                	push   $0x25
  8009ae:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009b0:	83 c4 10             	add    $0x10,%esp
  8009b3:	89 f8                	mov    %edi,%eax
  8009b5:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009b9:	74 05                	je     8009c0 <vprintfmt+0x443>
  8009bb:	83 e8 01             	sub    $0x1,%eax
  8009be:	eb f5                	jmp    8009b5 <vprintfmt+0x438>
  8009c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009c3:	e9 17 ff ff ff       	jmp    8008df <vprintfmt+0x362>
}
  8009c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009cb:	5b                   	pop    %ebx
  8009cc:	5e                   	pop    %esi
  8009cd:	5f                   	pop    %edi
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009d0:	f3 0f 1e fb          	endbr32 
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	83 ec 18             	sub    $0x18,%esp
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009e3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009e7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009f1:	85 c0                	test   %eax,%eax
  8009f3:	74 26                	je     800a1b <vsnprintf+0x4b>
  8009f5:	85 d2                	test   %edx,%edx
  8009f7:	7e 22                	jle    800a1b <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009f9:	ff 75 14             	pushl  0x14(%ebp)
  8009fc:	ff 75 10             	pushl  0x10(%ebp)
  8009ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a02:	50                   	push   %eax
  800a03:	68 3b 05 80 00       	push   $0x80053b
  800a08:	e8 70 fb ff ff       	call   80057d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a10:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a16:	83 c4 10             	add    $0x10,%esp
}
  800a19:	c9                   	leave  
  800a1a:	c3                   	ret    
		return -E_INVAL;
  800a1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a20:	eb f7                	jmp    800a19 <vsnprintf+0x49>

00800a22 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a22:	f3 0f 1e fb          	endbr32 
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a2c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a2f:	50                   	push   %eax
  800a30:	ff 75 10             	pushl  0x10(%ebp)
  800a33:	ff 75 0c             	pushl  0xc(%ebp)
  800a36:	ff 75 08             	pushl  0x8(%ebp)
  800a39:	e8 92 ff ff ff       	call   8009d0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a3e:	c9                   	leave  
  800a3f:	c3                   	ret    

00800a40 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a40:	f3 0f 1e fb          	endbr32 
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a53:	74 05                	je     800a5a <strlen+0x1a>
		n++;
  800a55:	83 c0 01             	add    $0x1,%eax
  800a58:	eb f5                	jmp    800a4f <strlen+0xf>
	return n;
}
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a5c:	f3 0f 1e fb          	endbr32 
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a66:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a69:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6e:	39 d0                	cmp    %edx,%eax
  800a70:	74 0d                	je     800a7f <strnlen+0x23>
  800a72:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a76:	74 05                	je     800a7d <strnlen+0x21>
		n++;
  800a78:	83 c0 01             	add    $0x1,%eax
  800a7b:	eb f1                	jmp    800a6e <strnlen+0x12>
  800a7d:	89 c2                	mov    %eax,%edx
	return n;
}
  800a7f:	89 d0                	mov    %edx,%eax
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a83:	f3 0f 1e fb          	endbr32 
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	53                   	push   %ebx
  800a8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a91:	b8 00 00 00 00       	mov    $0x0,%eax
  800a96:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a9a:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a9d:	83 c0 01             	add    $0x1,%eax
  800aa0:	84 d2                	test   %dl,%dl
  800aa2:	75 f2                	jne    800a96 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800aa4:	89 c8                	mov    %ecx,%eax
  800aa6:	5b                   	pop    %ebx
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aa9:	f3 0f 1e fb          	endbr32 
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	53                   	push   %ebx
  800ab1:	83 ec 10             	sub    $0x10,%esp
  800ab4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ab7:	53                   	push   %ebx
  800ab8:	e8 83 ff ff ff       	call   800a40 <strlen>
  800abd:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800ac0:	ff 75 0c             	pushl  0xc(%ebp)
  800ac3:	01 d8                	add    %ebx,%eax
  800ac5:	50                   	push   %eax
  800ac6:	e8 b8 ff ff ff       	call   800a83 <strcpy>
	return dst;
}
  800acb:	89 d8                	mov    %ebx,%eax
  800acd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ad0:	c9                   	leave  
  800ad1:	c3                   	ret    

00800ad2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ad2:	f3 0f 1e fb          	endbr32 
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	56                   	push   %esi
  800ada:	53                   	push   %ebx
  800adb:	8b 75 08             	mov    0x8(%ebp),%esi
  800ade:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae1:	89 f3                	mov    %esi,%ebx
  800ae3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae6:	89 f0                	mov    %esi,%eax
  800ae8:	39 d8                	cmp    %ebx,%eax
  800aea:	74 11                	je     800afd <strncpy+0x2b>
		*dst++ = *src;
  800aec:	83 c0 01             	add    $0x1,%eax
  800aef:	0f b6 0a             	movzbl (%edx),%ecx
  800af2:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800af5:	80 f9 01             	cmp    $0x1,%cl
  800af8:	83 da ff             	sbb    $0xffffffff,%edx
  800afb:	eb eb                	jmp    800ae8 <strncpy+0x16>
	}
	return ret;
}
  800afd:	89 f0                	mov    %esi,%eax
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b03:	f3 0f 1e fb          	endbr32 
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
  800b0c:	8b 75 08             	mov    0x8(%ebp),%esi
  800b0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b12:	8b 55 10             	mov    0x10(%ebp),%edx
  800b15:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b17:	85 d2                	test   %edx,%edx
  800b19:	74 21                	je     800b3c <strlcpy+0x39>
  800b1b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b1f:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b21:	39 c2                	cmp    %eax,%edx
  800b23:	74 14                	je     800b39 <strlcpy+0x36>
  800b25:	0f b6 19             	movzbl (%ecx),%ebx
  800b28:	84 db                	test   %bl,%bl
  800b2a:	74 0b                	je     800b37 <strlcpy+0x34>
			*dst++ = *src++;
  800b2c:	83 c1 01             	add    $0x1,%ecx
  800b2f:	83 c2 01             	add    $0x1,%edx
  800b32:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b35:	eb ea                	jmp    800b21 <strlcpy+0x1e>
  800b37:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b39:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b3c:	29 f0                	sub    %esi,%eax
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b42:	f3 0f 1e fb          	endbr32 
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b4f:	0f b6 01             	movzbl (%ecx),%eax
  800b52:	84 c0                	test   %al,%al
  800b54:	74 0c                	je     800b62 <strcmp+0x20>
  800b56:	3a 02                	cmp    (%edx),%al
  800b58:	75 08                	jne    800b62 <strcmp+0x20>
		p++, q++;
  800b5a:	83 c1 01             	add    $0x1,%ecx
  800b5d:	83 c2 01             	add    $0x1,%edx
  800b60:	eb ed                	jmp    800b4f <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b62:	0f b6 c0             	movzbl %al,%eax
  800b65:	0f b6 12             	movzbl (%edx),%edx
  800b68:	29 d0                	sub    %edx,%eax
}
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b6c:	f3 0f 1e fb          	endbr32 
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	53                   	push   %ebx
  800b74:	8b 45 08             	mov    0x8(%ebp),%eax
  800b77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7a:	89 c3                	mov    %eax,%ebx
  800b7c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b7f:	eb 06                	jmp    800b87 <strncmp+0x1b>
		n--, p++, q++;
  800b81:	83 c0 01             	add    $0x1,%eax
  800b84:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b87:	39 d8                	cmp    %ebx,%eax
  800b89:	74 16                	je     800ba1 <strncmp+0x35>
  800b8b:	0f b6 08             	movzbl (%eax),%ecx
  800b8e:	84 c9                	test   %cl,%cl
  800b90:	74 04                	je     800b96 <strncmp+0x2a>
  800b92:	3a 0a                	cmp    (%edx),%cl
  800b94:	74 eb                	je     800b81 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b96:	0f b6 00             	movzbl (%eax),%eax
  800b99:	0f b6 12             	movzbl (%edx),%edx
  800b9c:	29 d0                	sub    %edx,%eax
}
  800b9e:	5b                   	pop    %ebx
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    
		return 0;
  800ba1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba6:	eb f6                	jmp    800b9e <strncmp+0x32>

00800ba8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ba8:	f3 0f 1e fb          	endbr32 
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bb6:	0f b6 10             	movzbl (%eax),%edx
  800bb9:	84 d2                	test   %dl,%dl
  800bbb:	74 09                	je     800bc6 <strchr+0x1e>
		if (*s == c)
  800bbd:	38 ca                	cmp    %cl,%dl
  800bbf:	74 0a                	je     800bcb <strchr+0x23>
	for (; *s; s++)
  800bc1:	83 c0 01             	add    $0x1,%eax
  800bc4:	eb f0                	jmp    800bb6 <strchr+0xe>
			return (char *) s;
	return 0;
  800bc6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bcd:	f3 0f 1e fb          	endbr32 
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bdb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bde:	38 ca                	cmp    %cl,%dl
  800be0:	74 09                	je     800beb <strfind+0x1e>
  800be2:	84 d2                	test   %dl,%dl
  800be4:	74 05                	je     800beb <strfind+0x1e>
	for (; *s; s++)
  800be6:	83 c0 01             	add    $0x1,%eax
  800be9:	eb f0                	jmp    800bdb <strfind+0xe>
			break;
	return (char *) s;
}
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bed:	f3 0f 1e fb          	endbr32 
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bfa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bfd:	85 c9                	test   %ecx,%ecx
  800bff:	74 31                	je     800c32 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c01:	89 f8                	mov    %edi,%eax
  800c03:	09 c8                	or     %ecx,%eax
  800c05:	a8 03                	test   $0x3,%al
  800c07:	75 23                	jne    800c2c <memset+0x3f>
		c &= 0xFF;
  800c09:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c0d:	89 d3                	mov    %edx,%ebx
  800c0f:	c1 e3 08             	shl    $0x8,%ebx
  800c12:	89 d0                	mov    %edx,%eax
  800c14:	c1 e0 18             	shl    $0x18,%eax
  800c17:	89 d6                	mov    %edx,%esi
  800c19:	c1 e6 10             	shl    $0x10,%esi
  800c1c:	09 f0                	or     %esi,%eax
  800c1e:	09 c2                	or     %eax,%edx
  800c20:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c22:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c25:	89 d0                	mov    %edx,%eax
  800c27:	fc                   	cld    
  800c28:	f3 ab                	rep stos %eax,%es:(%edi)
  800c2a:	eb 06                	jmp    800c32 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2f:	fc                   	cld    
  800c30:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c32:	89 f8                	mov    %edi,%eax
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c39:	f3 0f 1e fb          	endbr32 
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	8b 45 08             	mov    0x8(%ebp),%eax
  800c45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c48:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c4b:	39 c6                	cmp    %eax,%esi
  800c4d:	73 32                	jae    800c81 <memmove+0x48>
  800c4f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c52:	39 c2                	cmp    %eax,%edx
  800c54:	76 2b                	jbe    800c81 <memmove+0x48>
		s += n;
		d += n;
  800c56:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c59:	89 fe                	mov    %edi,%esi
  800c5b:	09 ce                	or     %ecx,%esi
  800c5d:	09 d6                	or     %edx,%esi
  800c5f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c65:	75 0e                	jne    800c75 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c67:	83 ef 04             	sub    $0x4,%edi
  800c6a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c6d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c70:	fd                   	std    
  800c71:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c73:	eb 09                	jmp    800c7e <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c75:	83 ef 01             	sub    $0x1,%edi
  800c78:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c7b:	fd                   	std    
  800c7c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c7e:	fc                   	cld    
  800c7f:	eb 1a                	jmp    800c9b <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c81:	89 c2                	mov    %eax,%edx
  800c83:	09 ca                	or     %ecx,%edx
  800c85:	09 f2                	or     %esi,%edx
  800c87:	f6 c2 03             	test   $0x3,%dl
  800c8a:	75 0a                	jne    800c96 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c8c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c8f:	89 c7                	mov    %eax,%edi
  800c91:	fc                   	cld    
  800c92:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c94:	eb 05                	jmp    800c9b <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c96:	89 c7                	mov    %eax,%edi
  800c98:	fc                   	cld    
  800c99:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c9b:	5e                   	pop    %esi
  800c9c:	5f                   	pop    %edi
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c9f:	f3 0f 1e fb          	endbr32 
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ca9:	ff 75 10             	pushl  0x10(%ebp)
  800cac:	ff 75 0c             	pushl  0xc(%ebp)
  800caf:	ff 75 08             	pushl  0x8(%ebp)
  800cb2:	e8 82 ff ff ff       	call   800c39 <memmove>
}
  800cb7:	c9                   	leave  
  800cb8:	c3                   	ret    

00800cb9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cb9:	f3 0f 1e fb          	endbr32 
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cc8:	89 c6                	mov    %eax,%esi
  800cca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ccd:	39 f0                	cmp    %esi,%eax
  800ccf:	74 1c                	je     800ced <memcmp+0x34>
		if (*s1 != *s2)
  800cd1:	0f b6 08             	movzbl (%eax),%ecx
  800cd4:	0f b6 1a             	movzbl (%edx),%ebx
  800cd7:	38 d9                	cmp    %bl,%cl
  800cd9:	75 08                	jne    800ce3 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cdb:	83 c0 01             	add    $0x1,%eax
  800cde:	83 c2 01             	add    $0x1,%edx
  800ce1:	eb ea                	jmp    800ccd <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ce3:	0f b6 c1             	movzbl %cl,%eax
  800ce6:	0f b6 db             	movzbl %bl,%ebx
  800ce9:	29 d8                	sub    %ebx,%eax
  800ceb:	eb 05                	jmp    800cf2 <memcmp+0x39>
	}

	return 0;
  800ced:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cf6:	f3 0f 1e fb          	endbr32 
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800d00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d03:	89 c2                	mov    %eax,%edx
  800d05:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d08:	39 d0                	cmp    %edx,%eax
  800d0a:	73 09                	jae    800d15 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d0c:	38 08                	cmp    %cl,(%eax)
  800d0e:	74 05                	je     800d15 <memfind+0x1f>
	for (; s < ends; s++)
  800d10:	83 c0 01             	add    $0x1,%eax
  800d13:	eb f3                	jmp    800d08 <memfind+0x12>
			break;
	return (void *) s;
}
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d17:	f3 0f 1e fb          	endbr32 
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
  800d21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d24:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d27:	eb 03                	jmp    800d2c <strtol+0x15>
		s++;
  800d29:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d2c:	0f b6 01             	movzbl (%ecx),%eax
  800d2f:	3c 20                	cmp    $0x20,%al
  800d31:	74 f6                	je     800d29 <strtol+0x12>
  800d33:	3c 09                	cmp    $0x9,%al
  800d35:	74 f2                	je     800d29 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d37:	3c 2b                	cmp    $0x2b,%al
  800d39:	74 2a                	je     800d65 <strtol+0x4e>
	int neg = 0;
  800d3b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d40:	3c 2d                	cmp    $0x2d,%al
  800d42:	74 2b                	je     800d6f <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d44:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d4a:	75 0f                	jne    800d5b <strtol+0x44>
  800d4c:	80 39 30             	cmpb   $0x30,(%ecx)
  800d4f:	74 28                	je     800d79 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d51:	85 db                	test   %ebx,%ebx
  800d53:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d58:	0f 44 d8             	cmove  %eax,%ebx
  800d5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d60:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d63:	eb 46                	jmp    800dab <strtol+0x94>
		s++;
  800d65:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d68:	bf 00 00 00 00       	mov    $0x0,%edi
  800d6d:	eb d5                	jmp    800d44 <strtol+0x2d>
		s++, neg = 1;
  800d6f:	83 c1 01             	add    $0x1,%ecx
  800d72:	bf 01 00 00 00       	mov    $0x1,%edi
  800d77:	eb cb                	jmp    800d44 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d79:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d7d:	74 0e                	je     800d8d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d7f:	85 db                	test   %ebx,%ebx
  800d81:	75 d8                	jne    800d5b <strtol+0x44>
		s++, base = 8;
  800d83:	83 c1 01             	add    $0x1,%ecx
  800d86:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d8b:	eb ce                	jmp    800d5b <strtol+0x44>
		s += 2, base = 16;
  800d8d:	83 c1 02             	add    $0x2,%ecx
  800d90:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d95:	eb c4                	jmp    800d5b <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d97:	0f be d2             	movsbl %dl,%edx
  800d9a:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d9d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800da0:	7d 3a                	jge    800ddc <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800da2:	83 c1 01             	add    $0x1,%ecx
  800da5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800da9:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800dab:	0f b6 11             	movzbl (%ecx),%edx
  800dae:	8d 72 d0             	lea    -0x30(%edx),%esi
  800db1:	89 f3                	mov    %esi,%ebx
  800db3:	80 fb 09             	cmp    $0x9,%bl
  800db6:	76 df                	jbe    800d97 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800db8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800dbb:	89 f3                	mov    %esi,%ebx
  800dbd:	80 fb 19             	cmp    $0x19,%bl
  800dc0:	77 08                	ja     800dca <strtol+0xb3>
			dig = *s - 'a' + 10;
  800dc2:	0f be d2             	movsbl %dl,%edx
  800dc5:	83 ea 57             	sub    $0x57,%edx
  800dc8:	eb d3                	jmp    800d9d <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800dca:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dcd:	89 f3                	mov    %esi,%ebx
  800dcf:	80 fb 19             	cmp    $0x19,%bl
  800dd2:	77 08                	ja     800ddc <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dd4:	0f be d2             	movsbl %dl,%edx
  800dd7:	83 ea 37             	sub    $0x37,%edx
  800dda:	eb c1                	jmp    800d9d <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ddc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800de0:	74 05                	je     800de7 <strtol+0xd0>
		*endptr = (char *) s;
  800de2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800de5:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800de7:	89 c2                	mov    %eax,%edx
  800de9:	f7 da                	neg    %edx
  800deb:	85 ff                	test   %edi,%edi
  800ded:	0f 45 c2             	cmovne %edx,%eax
}
  800df0:	5b                   	pop    %ebx
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    
  800df5:	66 90                	xchg   %ax,%ax
  800df7:	66 90                	xchg   %ax,%ax
  800df9:	66 90                	xchg   %ax,%ax
  800dfb:	66 90                	xchg   %ax,%ax
  800dfd:	66 90                	xchg   %ax,%ax
  800dff:	90                   	nop

00800e00 <__udivdi3>:
  800e00:	f3 0f 1e fb          	endbr32 
  800e04:	55                   	push   %ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	83 ec 1c             	sub    $0x1c,%esp
  800e0b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e0f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e13:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e17:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e1b:	85 d2                	test   %edx,%edx
  800e1d:	75 19                	jne    800e38 <__udivdi3+0x38>
  800e1f:	39 f3                	cmp    %esi,%ebx
  800e21:	76 4d                	jbe    800e70 <__udivdi3+0x70>
  800e23:	31 ff                	xor    %edi,%edi
  800e25:	89 e8                	mov    %ebp,%eax
  800e27:	89 f2                	mov    %esi,%edx
  800e29:	f7 f3                	div    %ebx
  800e2b:	89 fa                	mov    %edi,%edx
  800e2d:	83 c4 1c             	add    $0x1c,%esp
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    
  800e35:	8d 76 00             	lea    0x0(%esi),%esi
  800e38:	39 f2                	cmp    %esi,%edx
  800e3a:	76 14                	jbe    800e50 <__udivdi3+0x50>
  800e3c:	31 ff                	xor    %edi,%edi
  800e3e:	31 c0                	xor    %eax,%eax
  800e40:	89 fa                	mov    %edi,%edx
  800e42:	83 c4 1c             	add    $0x1c,%esp
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    
  800e4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e50:	0f bd fa             	bsr    %edx,%edi
  800e53:	83 f7 1f             	xor    $0x1f,%edi
  800e56:	75 48                	jne    800ea0 <__udivdi3+0xa0>
  800e58:	39 f2                	cmp    %esi,%edx
  800e5a:	72 06                	jb     800e62 <__udivdi3+0x62>
  800e5c:	31 c0                	xor    %eax,%eax
  800e5e:	39 eb                	cmp    %ebp,%ebx
  800e60:	77 de                	ja     800e40 <__udivdi3+0x40>
  800e62:	b8 01 00 00 00       	mov    $0x1,%eax
  800e67:	eb d7                	jmp    800e40 <__udivdi3+0x40>
  800e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e70:	89 d9                	mov    %ebx,%ecx
  800e72:	85 db                	test   %ebx,%ebx
  800e74:	75 0b                	jne    800e81 <__udivdi3+0x81>
  800e76:	b8 01 00 00 00       	mov    $0x1,%eax
  800e7b:	31 d2                	xor    %edx,%edx
  800e7d:	f7 f3                	div    %ebx
  800e7f:	89 c1                	mov    %eax,%ecx
  800e81:	31 d2                	xor    %edx,%edx
  800e83:	89 f0                	mov    %esi,%eax
  800e85:	f7 f1                	div    %ecx
  800e87:	89 c6                	mov    %eax,%esi
  800e89:	89 e8                	mov    %ebp,%eax
  800e8b:	89 f7                	mov    %esi,%edi
  800e8d:	f7 f1                	div    %ecx
  800e8f:	89 fa                	mov    %edi,%edx
  800e91:	83 c4 1c             	add    $0x1c,%esp
  800e94:	5b                   	pop    %ebx
  800e95:	5e                   	pop    %esi
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    
  800e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	89 f9                	mov    %edi,%ecx
  800ea2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ea7:	29 f8                	sub    %edi,%eax
  800ea9:	d3 e2                	shl    %cl,%edx
  800eab:	89 54 24 08          	mov    %edx,0x8(%esp)
  800eaf:	89 c1                	mov    %eax,%ecx
  800eb1:	89 da                	mov    %ebx,%edx
  800eb3:	d3 ea                	shr    %cl,%edx
  800eb5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800eb9:	09 d1                	or     %edx,%ecx
  800ebb:	89 f2                	mov    %esi,%edx
  800ebd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ec1:	89 f9                	mov    %edi,%ecx
  800ec3:	d3 e3                	shl    %cl,%ebx
  800ec5:	89 c1                	mov    %eax,%ecx
  800ec7:	d3 ea                	shr    %cl,%edx
  800ec9:	89 f9                	mov    %edi,%ecx
  800ecb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ecf:	89 eb                	mov    %ebp,%ebx
  800ed1:	d3 e6                	shl    %cl,%esi
  800ed3:	89 c1                	mov    %eax,%ecx
  800ed5:	d3 eb                	shr    %cl,%ebx
  800ed7:	09 de                	or     %ebx,%esi
  800ed9:	89 f0                	mov    %esi,%eax
  800edb:	f7 74 24 08          	divl   0x8(%esp)
  800edf:	89 d6                	mov    %edx,%esi
  800ee1:	89 c3                	mov    %eax,%ebx
  800ee3:	f7 64 24 0c          	mull   0xc(%esp)
  800ee7:	39 d6                	cmp    %edx,%esi
  800ee9:	72 15                	jb     800f00 <__udivdi3+0x100>
  800eeb:	89 f9                	mov    %edi,%ecx
  800eed:	d3 e5                	shl    %cl,%ebp
  800eef:	39 c5                	cmp    %eax,%ebp
  800ef1:	73 04                	jae    800ef7 <__udivdi3+0xf7>
  800ef3:	39 d6                	cmp    %edx,%esi
  800ef5:	74 09                	je     800f00 <__udivdi3+0x100>
  800ef7:	89 d8                	mov    %ebx,%eax
  800ef9:	31 ff                	xor    %edi,%edi
  800efb:	e9 40 ff ff ff       	jmp    800e40 <__udivdi3+0x40>
  800f00:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f03:	31 ff                	xor    %edi,%edi
  800f05:	e9 36 ff ff ff       	jmp    800e40 <__udivdi3+0x40>
  800f0a:	66 90                	xchg   %ax,%ax
  800f0c:	66 90                	xchg   %ax,%ax
  800f0e:	66 90                	xchg   %ax,%ax

00800f10 <__umoddi3>:
  800f10:	f3 0f 1e fb          	endbr32 
  800f14:	55                   	push   %ebp
  800f15:	57                   	push   %edi
  800f16:	56                   	push   %esi
  800f17:	53                   	push   %ebx
  800f18:	83 ec 1c             	sub    $0x1c,%esp
  800f1b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f1f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f23:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f27:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f2b:	85 c0                	test   %eax,%eax
  800f2d:	75 19                	jne    800f48 <__umoddi3+0x38>
  800f2f:	39 df                	cmp    %ebx,%edi
  800f31:	76 5d                	jbe    800f90 <__umoddi3+0x80>
  800f33:	89 f0                	mov    %esi,%eax
  800f35:	89 da                	mov    %ebx,%edx
  800f37:	f7 f7                	div    %edi
  800f39:	89 d0                	mov    %edx,%eax
  800f3b:	31 d2                	xor    %edx,%edx
  800f3d:	83 c4 1c             	add    $0x1c,%esp
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    
  800f45:	8d 76 00             	lea    0x0(%esi),%esi
  800f48:	89 f2                	mov    %esi,%edx
  800f4a:	39 d8                	cmp    %ebx,%eax
  800f4c:	76 12                	jbe    800f60 <__umoddi3+0x50>
  800f4e:	89 f0                	mov    %esi,%eax
  800f50:	89 da                	mov    %ebx,%edx
  800f52:	83 c4 1c             	add    $0x1c,%esp
  800f55:	5b                   	pop    %ebx
  800f56:	5e                   	pop    %esi
  800f57:	5f                   	pop    %edi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    
  800f5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f60:	0f bd e8             	bsr    %eax,%ebp
  800f63:	83 f5 1f             	xor    $0x1f,%ebp
  800f66:	75 50                	jne    800fb8 <__umoddi3+0xa8>
  800f68:	39 d8                	cmp    %ebx,%eax
  800f6a:	0f 82 e0 00 00 00    	jb     801050 <__umoddi3+0x140>
  800f70:	89 d9                	mov    %ebx,%ecx
  800f72:	39 f7                	cmp    %esi,%edi
  800f74:	0f 86 d6 00 00 00    	jbe    801050 <__umoddi3+0x140>
  800f7a:	89 d0                	mov    %edx,%eax
  800f7c:	89 ca                	mov    %ecx,%edx
  800f7e:	83 c4 1c             	add    $0x1c,%esp
  800f81:	5b                   	pop    %ebx
  800f82:	5e                   	pop    %esi
  800f83:	5f                   	pop    %edi
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    
  800f86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f8d:	8d 76 00             	lea    0x0(%esi),%esi
  800f90:	89 fd                	mov    %edi,%ebp
  800f92:	85 ff                	test   %edi,%edi
  800f94:	75 0b                	jne    800fa1 <__umoddi3+0x91>
  800f96:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9b:	31 d2                	xor    %edx,%edx
  800f9d:	f7 f7                	div    %edi
  800f9f:	89 c5                	mov    %eax,%ebp
  800fa1:	89 d8                	mov    %ebx,%eax
  800fa3:	31 d2                	xor    %edx,%edx
  800fa5:	f7 f5                	div    %ebp
  800fa7:	89 f0                	mov    %esi,%eax
  800fa9:	f7 f5                	div    %ebp
  800fab:	89 d0                	mov    %edx,%eax
  800fad:	31 d2                	xor    %edx,%edx
  800faf:	eb 8c                	jmp    800f3d <__umoddi3+0x2d>
  800fb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fb8:	89 e9                	mov    %ebp,%ecx
  800fba:	ba 20 00 00 00       	mov    $0x20,%edx
  800fbf:	29 ea                	sub    %ebp,%edx
  800fc1:	d3 e0                	shl    %cl,%eax
  800fc3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc7:	89 d1                	mov    %edx,%ecx
  800fc9:	89 f8                	mov    %edi,%eax
  800fcb:	d3 e8                	shr    %cl,%eax
  800fcd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fd1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fd5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fd9:	09 c1                	or     %eax,%ecx
  800fdb:	89 d8                	mov    %ebx,%eax
  800fdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fe1:	89 e9                	mov    %ebp,%ecx
  800fe3:	d3 e7                	shl    %cl,%edi
  800fe5:	89 d1                	mov    %edx,%ecx
  800fe7:	d3 e8                	shr    %cl,%eax
  800fe9:	89 e9                	mov    %ebp,%ecx
  800feb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fef:	d3 e3                	shl    %cl,%ebx
  800ff1:	89 c7                	mov    %eax,%edi
  800ff3:	89 d1                	mov    %edx,%ecx
  800ff5:	89 f0                	mov    %esi,%eax
  800ff7:	d3 e8                	shr    %cl,%eax
  800ff9:	89 e9                	mov    %ebp,%ecx
  800ffb:	89 fa                	mov    %edi,%edx
  800ffd:	d3 e6                	shl    %cl,%esi
  800fff:	09 d8                	or     %ebx,%eax
  801001:	f7 74 24 08          	divl   0x8(%esp)
  801005:	89 d1                	mov    %edx,%ecx
  801007:	89 f3                	mov    %esi,%ebx
  801009:	f7 64 24 0c          	mull   0xc(%esp)
  80100d:	89 c6                	mov    %eax,%esi
  80100f:	89 d7                	mov    %edx,%edi
  801011:	39 d1                	cmp    %edx,%ecx
  801013:	72 06                	jb     80101b <__umoddi3+0x10b>
  801015:	75 10                	jne    801027 <__umoddi3+0x117>
  801017:	39 c3                	cmp    %eax,%ebx
  801019:	73 0c                	jae    801027 <__umoddi3+0x117>
  80101b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80101f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801023:	89 d7                	mov    %edx,%edi
  801025:	89 c6                	mov    %eax,%esi
  801027:	89 ca                	mov    %ecx,%edx
  801029:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80102e:	29 f3                	sub    %esi,%ebx
  801030:	19 fa                	sbb    %edi,%edx
  801032:	89 d0                	mov    %edx,%eax
  801034:	d3 e0                	shl    %cl,%eax
  801036:	89 e9                	mov    %ebp,%ecx
  801038:	d3 eb                	shr    %cl,%ebx
  80103a:	d3 ea                	shr    %cl,%edx
  80103c:	09 d8                	or     %ebx,%eax
  80103e:	83 c4 1c             	add    $0x1c,%esp
  801041:	5b                   	pop    %ebx
  801042:	5e                   	pop    %esi
  801043:	5f                   	pop    %edi
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    
  801046:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80104d:	8d 76 00             	lea    0x0(%esi),%esi
  801050:	29 fe                	sub    %edi,%esi
  801052:	19 c3                	sbb    %eax,%ebx
  801054:	89 f2                	mov    %esi,%edx
  801056:	89 d9                	mov    %ebx,%ecx
  801058:	e9 1d ff ff ff       	jmp    800f7a <__umoddi3+0x6a>
