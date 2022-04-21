
obj/user/faultevilhandler:     file format elf32-i386


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
  800046:	e8 60 01 00 00       	call   8001ab <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	68 20 00 10 f0       	push   $0xf0100020
  800053:	6a 00                	push   $0x0
  800055:	e8 b0 02 00 00       	call   80030a <sys_env_set_pgfault_upcall>
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
  800078:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  80007f:	00 00 00 
    envid_t envid = sys_getenvid();
  800082:	e8 de 00 00 00       	call   800165 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800087:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80008f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800094:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800099:	85 db                	test   %ebx,%ebx
  80009b:	7e 07                	jle    8000a4 <libmain+0x3b>
		binaryname = argv[0];
  80009d:	8b 06                	mov    (%esi),%eax
  80009f:	a3 00 30 80 00       	mov    %eax,0x803000

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
  8000c4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c7:	e8 df 04 00 00       	call   8005ab <close_all>
	sys_env_destroy(0);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	6a 00                	push   $0x0
  8000d1:	e8 4a 00 00 00       	call   800120 <sys_env_destroy>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000db:	f3 0f 1e fb          	endbr32 
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f0:	89 c3                	mov    %eax,%ebx
  8000f2:	89 c7                	mov    %eax,%edi
  8000f4:	89 c6                	mov    %eax,%esi
  8000f6:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5f                   	pop    %edi
  8000fb:	5d                   	pop    %ebp
  8000fc:	c3                   	ret    

008000fd <sys_cgetc>:

int
sys_cgetc(void)
{
  8000fd:	f3 0f 1e fb          	endbr32 
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	57                   	push   %edi
  800105:	56                   	push   %esi
  800106:	53                   	push   %ebx
	asm volatile("int %1\n"
  800107:	ba 00 00 00 00       	mov    $0x0,%edx
  80010c:	b8 01 00 00 00       	mov    $0x1,%eax
  800111:	89 d1                	mov    %edx,%ecx
  800113:	89 d3                	mov    %edx,%ebx
  800115:	89 d7                	mov    %edx,%edi
  800117:	89 d6                	mov    %edx,%esi
  800119:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800120:	f3 0f 1e fb          	endbr32 
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	57                   	push   %edi
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80012d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800132:	8b 55 08             	mov    0x8(%ebp),%edx
  800135:	b8 03 00 00 00       	mov    $0x3,%eax
  80013a:	89 cb                	mov    %ecx,%ebx
  80013c:	89 cf                	mov    %ecx,%edi
  80013e:	89 ce                	mov    %ecx,%esi
  800140:	cd 30                	int    $0x30
	if(check && ret > 0)
  800142:	85 c0                	test   %eax,%eax
  800144:	7f 08                	jg     80014e <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800146:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800149:	5b                   	pop    %ebx
  80014a:	5e                   	pop    %esi
  80014b:	5f                   	pop    %edi
  80014c:	5d                   	pop    %ebp
  80014d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80014e:	83 ec 0c             	sub    $0xc,%esp
  800151:	50                   	push   %eax
  800152:	6a 03                	push   $0x3
  800154:	68 ea 1e 80 00       	push   $0x801eea
  800159:	6a 23                	push   $0x23
  80015b:	68 07 1f 80 00       	push   $0x801f07
  800160:	e8 70 0f 00 00       	call   8010d5 <_panic>

00800165 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800165:	f3 0f 1e fb          	endbr32 
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	57                   	push   %edi
  80016d:	56                   	push   %esi
  80016e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80016f:	ba 00 00 00 00       	mov    $0x0,%edx
  800174:	b8 02 00 00 00       	mov    $0x2,%eax
  800179:	89 d1                	mov    %edx,%ecx
  80017b:	89 d3                	mov    %edx,%ebx
  80017d:	89 d7                	mov    %edx,%edi
  80017f:	89 d6                	mov    %edx,%esi
  800181:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800183:	5b                   	pop    %ebx
  800184:	5e                   	pop    %esi
  800185:	5f                   	pop    %edi
  800186:	5d                   	pop    %ebp
  800187:	c3                   	ret    

00800188 <sys_yield>:

void
sys_yield(void)
{
  800188:	f3 0f 1e fb          	endbr32 
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	57                   	push   %edi
  800190:	56                   	push   %esi
  800191:	53                   	push   %ebx
	asm volatile("int %1\n"
  800192:	ba 00 00 00 00       	mov    $0x0,%edx
  800197:	b8 0b 00 00 00       	mov    $0xb,%eax
  80019c:	89 d1                	mov    %edx,%ecx
  80019e:	89 d3                	mov    %edx,%ebx
  8001a0:	89 d7                	mov    %edx,%edi
  8001a2:	89 d6                	mov    %edx,%esi
  8001a4:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001a6:	5b                   	pop    %ebx
  8001a7:	5e                   	pop    %esi
  8001a8:	5f                   	pop    %edi
  8001a9:	5d                   	pop    %ebp
  8001aa:	c3                   	ret    

008001ab <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001ab:	f3 0f 1e fb          	endbr32 
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	57                   	push   %edi
  8001b3:	56                   	push   %esi
  8001b4:	53                   	push   %ebx
  8001b5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001b8:	be 00 00 00 00       	mov    $0x0,%esi
  8001bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c3:	b8 04 00 00 00       	mov    $0x4,%eax
  8001c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001cb:	89 f7                	mov    %esi,%edi
  8001cd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001cf:	85 c0                	test   %eax,%eax
  8001d1:	7f 08                	jg     8001db <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001db:	83 ec 0c             	sub    $0xc,%esp
  8001de:	50                   	push   %eax
  8001df:	6a 04                	push   $0x4
  8001e1:	68 ea 1e 80 00       	push   $0x801eea
  8001e6:	6a 23                	push   $0x23
  8001e8:	68 07 1f 80 00       	push   $0x801f07
  8001ed:	e8 e3 0e 00 00       	call   8010d5 <_panic>

008001f2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001f2:	f3 0f 1e fb          	endbr32 
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	57                   	push   %edi
  8001fa:	56                   	push   %esi
  8001fb:	53                   	push   %ebx
  8001fc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800205:	b8 05 00 00 00       	mov    $0x5,%eax
  80020a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80020d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800210:	8b 75 18             	mov    0x18(%ebp),%esi
  800213:	cd 30                	int    $0x30
	if(check && ret > 0)
  800215:	85 c0                	test   %eax,%eax
  800217:	7f 08                	jg     800221 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021c:	5b                   	pop    %ebx
  80021d:	5e                   	pop    %esi
  80021e:	5f                   	pop    %edi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800221:	83 ec 0c             	sub    $0xc,%esp
  800224:	50                   	push   %eax
  800225:	6a 05                	push   $0x5
  800227:	68 ea 1e 80 00       	push   $0x801eea
  80022c:	6a 23                	push   $0x23
  80022e:	68 07 1f 80 00       	push   $0x801f07
  800233:	e8 9d 0e 00 00       	call   8010d5 <_panic>

00800238 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800238:	f3 0f 1e fb          	endbr32 
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	57                   	push   %edi
  800240:	56                   	push   %esi
  800241:	53                   	push   %ebx
  800242:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800245:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024a:	8b 55 08             	mov    0x8(%ebp),%edx
  80024d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800250:	b8 06 00 00 00       	mov    $0x6,%eax
  800255:	89 df                	mov    %ebx,%edi
  800257:	89 de                	mov    %ebx,%esi
  800259:	cd 30                	int    $0x30
	if(check && ret > 0)
  80025b:	85 c0                	test   %eax,%eax
  80025d:	7f 08                	jg     800267 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80025f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800267:	83 ec 0c             	sub    $0xc,%esp
  80026a:	50                   	push   %eax
  80026b:	6a 06                	push   $0x6
  80026d:	68 ea 1e 80 00       	push   $0x801eea
  800272:	6a 23                	push   $0x23
  800274:	68 07 1f 80 00       	push   $0x801f07
  800279:	e8 57 0e 00 00       	call   8010d5 <_panic>

0080027e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80027e:	f3 0f 1e fb          	endbr32 
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	57                   	push   %edi
  800286:	56                   	push   %esi
  800287:	53                   	push   %ebx
  800288:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80028b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800290:	8b 55 08             	mov    0x8(%ebp),%edx
  800293:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800296:	b8 08 00 00 00       	mov    $0x8,%eax
  80029b:	89 df                	mov    %ebx,%edi
  80029d:	89 de                	mov    %ebx,%esi
  80029f:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002a1:	85 c0                	test   %eax,%eax
  8002a3:	7f 08                	jg     8002ad <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a8:	5b                   	pop    %ebx
  8002a9:	5e                   	pop    %esi
  8002aa:	5f                   	pop    %edi
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	50                   	push   %eax
  8002b1:	6a 08                	push   $0x8
  8002b3:	68 ea 1e 80 00       	push   $0x801eea
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 07 1f 80 00       	push   $0x801f07
  8002bf:	e8 11 0e 00 00       	call   8010d5 <_panic>

008002c4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002c4:	f3 0f 1e fb          	endbr32 
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	57                   	push   %edi
  8002cc:	56                   	push   %esi
  8002cd:	53                   	push   %ebx
  8002ce:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002dc:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e1:	89 df                	mov    %ebx,%edi
  8002e3:	89 de                	mov    %ebx,%esi
  8002e5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	7f 08                	jg     8002f3 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f3:	83 ec 0c             	sub    $0xc,%esp
  8002f6:	50                   	push   %eax
  8002f7:	6a 09                	push   $0x9
  8002f9:	68 ea 1e 80 00       	push   $0x801eea
  8002fe:	6a 23                	push   $0x23
  800300:	68 07 1f 80 00       	push   $0x801f07
  800305:	e8 cb 0d 00 00       	call   8010d5 <_panic>

0080030a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80030a:	f3 0f 1e fb          	endbr32 
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800317:	bb 00 00 00 00       	mov    $0x0,%ebx
  80031c:	8b 55 08             	mov    0x8(%ebp),%edx
  80031f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800322:	b8 0a 00 00 00       	mov    $0xa,%eax
  800327:	89 df                	mov    %ebx,%edi
  800329:	89 de                	mov    %ebx,%esi
  80032b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80032d:	85 c0                	test   %eax,%eax
  80032f:	7f 08                	jg     800339 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800331:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800334:	5b                   	pop    %ebx
  800335:	5e                   	pop    %esi
  800336:	5f                   	pop    %edi
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800339:	83 ec 0c             	sub    $0xc,%esp
  80033c:	50                   	push   %eax
  80033d:	6a 0a                	push   $0xa
  80033f:	68 ea 1e 80 00       	push   $0x801eea
  800344:	6a 23                	push   $0x23
  800346:	68 07 1f 80 00       	push   $0x801f07
  80034b:	e8 85 0d 00 00       	call   8010d5 <_panic>

00800350 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800350:	f3 0f 1e fb          	endbr32 
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	57                   	push   %edi
  800358:	56                   	push   %esi
  800359:	53                   	push   %ebx
	asm volatile("int %1\n"
  80035a:	8b 55 08             	mov    0x8(%ebp),%edx
  80035d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800360:	b8 0c 00 00 00       	mov    $0xc,%eax
  800365:	be 00 00 00 00       	mov    $0x0,%esi
  80036a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80036d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800370:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800372:	5b                   	pop    %ebx
  800373:	5e                   	pop    %esi
  800374:	5f                   	pop    %edi
  800375:	5d                   	pop    %ebp
  800376:	c3                   	ret    

00800377 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800377:	f3 0f 1e fb          	endbr32 
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	57                   	push   %edi
  80037f:	56                   	push   %esi
  800380:	53                   	push   %ebx
  800381:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800384:	b9 00 00 00 00       	mov    $0x0,%ecx
  800389:	8b 55 08             	mov    0x8(%ebp),%edx
  80038c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800391:	89 cb                	mov    %ecx,%ebx
  800393:	89 cf                	mov    %ecx,%edi
  800395:	89 ce                	mov    %ecx,%esi
  800397:	cd 30                	int    $0x30
	if(check && ret > 0)
  800399:	85 c0                	test   %eax,%eax
  80039b:	7f 08                	jg     8003a5 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80039d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003a0:	5b                   	pop    %ebx
  8003a1:	5e                   	pop    %esi
  8003a2:	5f                   	pop    %edi
  8003a3:	5d                   	pop    %ebp
  8003a4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8003a5:	83 ec 0c             	sub    $0xc,%esp
  8003a8:	50                   	push   %eax
  8003a9:	6a 0d                	push   $0xd
  8003ab:	68 ea 1e 80 00       	push   $0x801eea
  8003b0:	6a 23                	push   $0x23
  8003b2:	68 07 1f 80 00       	push   $0x801f07
  8003b7:	e8 19 0d 00 00       	call   8010d5 <_panic>

008003bc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003bc:	f3 0f 1e fb          	endbr32 
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8003cb:	c1 e8 0c             	shr    $0xc,%eax
}
  8003ce:	5d                   	pop    %ebp
  8003cf:	c3                   	ret    

008003d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003d0:	f3 0f 1e fb          	endbr32 
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003da:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003e4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003e9:	5d                   	pop    %ebp
  8003ea:	c3                   	ret    

008003eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003eb:	f3 0f 1e fb          	endbr32 
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003f7:	89 c2                	mov    %eax,%edx
  8003f9:	c1 ea 16             	shr    $0x16,%edx
  8003fc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800403:	f6 c2 01             	test   $0x1,%dl
  800406:	74 2d                	je     800435 <fd_alloc+0x4a>
  800408:	89 c2                	mov    %eax,%edx
  80040a:	c1 ea 0c             	shr    $0xc,%edx
  80040d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800414:	f6 c2 01             	test   $0x1,%dl
  800417:	74 1c                	je     800435 <fd_alloc+0x4a>
  800419:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80041e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800423:	75 d2                	jne    8003f7 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800425:	8b 45 08             	mov    0x8(%ebp),%eax
  800428:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80042e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800433:	eb 0a                	jmp    80043f <fd_alloc+0x54>
			*fd_store = fd;
  800435:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800438:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80043f:	5d                   	pop    %ebp
  800440:	c3                   	ret    

00800441 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800441:	f3 0f 1e fb          	endbr32 
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80044b:	83 f8 1f             	cmp    $0x1f,%eax
  80044e:	77 30                	ja     800480 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800450:	c1 e0 0c             	shl    $0xc,%eax
  800453:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800458:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80045e:	f6 c2 01             	test   $0x1,%dl
  800461:	74 24                	je     800487 <fd_lookup+0x46>
  800463:	89 c2                	mov    %eax,%edx
  800465:	c1 ea 0c             	shr    $0xc,%edx
  800468:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80046f:	f6 c2 01             	test   $0x1,%dl
  800472:	74 1a                	je     80048e <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800474:	8b 55 0c             	mov    0xc(%ebp),%edx
  800477:	89 02                	mov    %eax,(%edx)
	return 0;
  800479:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80047e:	5d                   	pop    %ebp
  80047f:	c3                   	ret    
		return -E_INVAL;
  800480:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800485:	eb f7                	jmp    80047e <fd_lookup+0x3d>
		return -E_INVAL;
  800487:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80048c:	eb f0                	jmp    80047e <fd_lookup+0x3d>
  80048e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800493:	eb e9                	jmp    80047e <fd_lookup+0x3d>

00800495 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800495:	f3 0f 1e fb          	endbr32 
  800499:	55                   	push   %ebp
  80049a:	89 e5                	mov    %esp,%ebp
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004a2:	ba 94 1f 80 00       	mov    $0x801f94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004a7:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8004ac:	39 08                	cmp    %ecx,(%eax)
  8004ae:	74 33                	je     8004e3 <dev_lookup+0x4e>
  8004b0:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8004b3:	8b 02                	mov    (%edx),%eax
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	75 f3                	jne    8004ac <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004b9:	a1 04 40 80 00       	mov    0x804004,%eax
  8004be:	8b 40 48             	mov    0x48(%eax),%eax
  8004c1:	83 ec 04             	sub    $0x4,%esp
  8004c4:	51                   	push   %ecx
  8004c5:	50                   	push   %eax
  8004c6:	68 18 1f 80 00       	push   $0x801f18
  8004cb:	e8 ec 0c 00 00       	call   8011bc <cprintf>
	*dev = 0;
  8004d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004e1:	c9                   	leave  
  8004e2:	c3                   	ret    
			*dev = devtab[i];
  8004e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004e6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ed:	eb f2                	jmp    8004e1 <dev_lookup+0x4c>

008004ef <fd_close>:
{
  8004ef:	f3 0f 1e fb          	endbr32 
  8004f3:	55                   	push   %ebp
  8004f4:	89 e5                	mov    %esp,%ebp
  8004f6:	57                   	push   %edi
  8004f7:	56                   	push   %esi
  8004f8:	53                   	push   %ebx
  8004f9:	83 ec 24             	sub    $0x24,%esp
  8004fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ff:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800502:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800505:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800506:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80050c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80050f:	50                   	push   %eax
  800510:	e8 2c ff ff ff       	call   800441 <fd_lookup>
  800515:	89 c3                	mov    %eax,%ebx
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	78 05                	js     800523 <fd_close+0x34>
	    || fd != fd2)
  80051e:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800521:	74 16                	je     800539 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800523:	89 f8                	mov    %edi,%eax
  800525:	84 c0                	test   %al,%al
  800527:	b8 00 00 00 00       	mov    $0x0,%eax
  80052c:	0f 44 d8             	cmove  %eax,%ebx
}
  80052f:	89 d8                	mov    %ebx,%eax
  800531:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800534:	5b                   	pop    %ebx
  800535:	5e                   	pop    %esi
  800536:	5f                   	pop    %edi
  800537:	5d                   	pop    %ebp
  800538:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80053f:	50                   	push   %eax
  800540:	ff 36                	pushl  (%esi)
  800542:	e8 4e ff ff ff       	call   800495 <dev_lookup>
  800547:	89 c3                	mov    %eax,%ebx
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	85 c0                	test   %eax,%eax
  80054e:	78 1a                	js     80056a <fd_close+0x7b>
		if (dev->dev_close)
  800550:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800553:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800556:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80055b:	85 c0                	test   %eax,%eax
  80055d:	74 0b                	je     80056a <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80055f:	83 ec 0c             	sub    $0xc,%esp
  800562:	56                   	push   %esi
  800563:	ff d0                	call   *%eax
  800565:	89 c3                	mov    %eax,%ebx
  800567:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80056a:	83 ec 08             	sub    $0x8,%esp
  80056d:	56                   	push   %esi
  80056e:	6a 00                	push   $0x0
  800570:	e8 c3 fc ff ff       	call   800238 <sys_page_unmap>
	return r;
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	eb b5                	jmp    80052f <fd_close+0x40>

0080057a <close>:

int
close(int fdnum)
{
  80057a:	f3 0f 1e fb          	endbr32 
  80057e:	55                   	push   %ebp
  80057f:	89 e5                	mov    %esp,%ebp
  800581:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800584:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800587:	50                   	push   %eax
  800588:	ff 75 08             	pushl  0x8(%ebp)
  80058b:	e8 b1 fe ff ff       	call   800441 <fd_lookup>
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	85 c0                	test   %eax,%eax
  800595:	79 02                	jns    800599 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800597:	c9                   	leave  
  800598:	c3                   	ret    
		return fd_close(fd, 1);
  800599:	83 ec 08             	sub    $0x8,%esp
  80059c:	6a 01                	push   $0x1
  80059e:	ff 75 f4             	pushl  -0xc(%ebp)
  8005a1:	e8 49 ff ff ff       	call   8004ef <fd_close>
  8005a6:	83 c4 10             	add    $0x10,%esp
  8005a9:	eb ec                	jmp    800597 <close+0x1d>

008005ab <close_all>:

void
close_all(void)
{
  8005ab:	f3 0f 1e fb          	endbr32 
  8005af:	55                   	push   %ebp
  8005b0:	89 e5                	mov    %esp,%ebp
  8005b2:	53                   	push   %ebx
  8005b3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005b6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005bb:	83 ec 0c             	sub    $0xc,%esp
  8005be:	53                   	push   %ebx
  8005bf:	e8 b6 ff ff ff       	call   80057a <close>
	for (i = 0; i < MAXFD; i++)
  8005c4:	83 c3 01             	add    $0x1,%ebx
  8005c7:	83 c4 10             	add    $0x10,%esp
  8005ca:	83 fb 20             	cmp    $0x20,%ebx
  8005cd:	75 ec                	jne    8005bb <close_all+0x10>
}
  8005cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005d2:	c9                   	leave  
  8005d3:	c3                   	ret    

008005d4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005d4:	f3 0f 1e fb          	endbr32 
  8005d8:	55                   	push   %ebp
  8005d9:	89 e5                	mov    %esp,%ebp
  8005db:	57                   	push   %edi
  8005dc:	56                   	push   %esi
  8005dd:	53                   	push   %ebx
  8005de:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005e1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005e4:	50                   	push   %eax
  8005e5:	ff 75 08             	pushl  0x8(%ebp)
  8005e8:	e8 54 fe ff ff       	call   800441 <fd_lookup>
  8005ed:	89 c3                	mov    %eax,%ebx
  8005ef:	83 c4 10             	add    $0x10,%esp
  8005f2:	85 c0                	test   %eax,%eax
  8005f4:	0f 88 81 00 00 00    	js     80067b <dup+0xa7>
		return r;
	close(newfdnum);
  8005fa:	83 ec 0c             	sub    $0xc,%esp
  8005fd:	ff 75 0c             	pushl  0xc(%ebp)
  800600:	e8 75 ff ff ff       	call   80057a <close>

	newfd = INDEX2FD(newfdnum);
  800605:	8b 75 0c             	mov    0xc(%ebp),%esi
  800608:	c1 e6 0c             	shl    $0xc,%esi
  80060b:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800611:	83 c4 04             	add    $0x4,%esp
  800614:	ff 75 e4             	pushl  -0x1c(%ebp)
  800617:	e8 b4 fd ff ff       	call   8003d0 <fd2data>
  80061c:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80061e:	89 34 24             	mov    %esi,(%esp)
  800621:	e8 aa fd ff ff       	call   8003d0 <fd2data>
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80062b:	89 d8                	mov    %ebx,%eax
  80062d:	c1 e8 16             	shr    $0x16,%eax
  800630:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800637:	a8 01                	test   $0x1,%al
  800639:	74 11                	je     80064c <dup+0x78>
  80063b:	89 d8                	mov    %ebx,%eax
  80063d:	c1 e8 0c             	shr    $0xc,%eax
  800640:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800647:	f6 c2 01             	test   $0x1,%dl
  80064a:	75 39                	jne    800685 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80064c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80064f:	89 d0                	mov    %edx,%eax
  800651:	c1 e8 0c             	shr    $0xc,%eax
  800654:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80065b:	83 ec 0c             	sub    $0xc,%esp
  80065e:	25 07 0e 00 00       	and    $0xe07,%eax
  800663:	50                   	push   %eax
  800664:	56                   	push   %esi
  800665:	6a 00                	push   $0x0
  800667:	52                   	push   %edx
  800668:	6a 00                	push   $0x0
  80066a:	e8 83 fb ff ff       	call   8001f2 <sys_page_map>
  80066f:	89 c3                	mov    %eax,%ebx
  800671:	83 c4 20             	add    $0x20,%esp
  800674:	85 c0                	test   %eax,%eax
  800676:	78 31                	js     8006a9 <dup+0xd5>
		goto err;

	return newfdnum;
  800678:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80067b:	89 d8                	mov    %ebx,%eax
  80067d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800680:	5b                   	pop    %ebx
  800681:	5e                   	pop    %esi
  800682:	5f                   	pop    %edi
  800683:	5d                   	pop    %ebp
  800684:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800685:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80068c:	83 ec 0c             	sub    $0xc,%esp
  80068f:	25 07 0e 00 00       	and    $0xe07,%eax
  800694:	50                   	push   %eax
  800695:	57                   	push   %edi
  800696:	6a 00                	push   $0x0
  800698:	53                   	push   %ebx
  800699:	6a 00                	push   $0x0
  80069b:	e8 52 fb ff ff       	call   8001f2 <sys_page_map>
  8006a0:	89 c3                	mov    %eax,%ebx
  8006a2:	83 c4 20             	add    $0x20,%esp
  8006a5:	85 c0                	test   %eax,%eax
  8006a7:	79 a3                	jns    80064c <dup+0x78>
	sys_page_unmap(0, newfd);
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	56                   	push   %esi
  8006ad:	6a 00                	push   $0x0
  8006af:	e8 84 fb ff ff       	call   800238 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006b4:	83 c4 08             	add    $0x8,%esp
  8006b7:	57                   	push   %edi
  8006b8:	6a 00                	push   $0x0
  8006ba:	e8 79 fb ff ff       	call   800238 <sys_page_unmap>
	return r;
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	eb b7                	jmp    80067b <dup+0xa7>

008006c4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006c4:	f3 0f 1e fb          	endbr32 
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	53                   	push   %ebx
  8006cc:	83 ec 1c             	sub    $0x1c,%esp
  8006cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006d5:	50                   	push   %eax
  8006d6:	53                   	push   %ebx
  8006d7:	e8 65 fd ff ff       	call   800441 <fd_lookup>
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	85 c0                	test   %eax,%eax
  8006e1:	78 3f                	js     800722 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006e3:	83 ec 08             	sub    $0x8,%esp
  8006e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006e9:	50                   	push   %eax
  8006ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006ed:	ff 30                	pushl  (%eax)
  8006ef:	e8 a1 fd ff ff       	call   800495 <dev_lookup>
  8006f4:	83 c4 10             	add    $0x10,%esp
  8006f7:	85 c0                	test   %eax,%eax
  8006f9:	78 27                	js     800722 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006fe:	8b 42 08             	mov    0x8(%edx),%eax
  800701:	83 e0 03             	and    $0x3,%eax
  800704:	83 f8 01             	cmp    $0x1,%eax
  800707:	74 1e                	je     800727 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800709:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070c:	8b 40 08             	mov    0x8(%eax),%eax
  80070f:	85 c0                	test   %eax,%eax
  800711:	74 35                	je     800748 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800713:	83 ec 04             	sub    $0x4,%esp
  800716:	ff 75 10             	pushl  0x10(%ebp)
  800719:	ff 75 0c             	pushl  0xc(%ebp)
  80071c:	52                   	push   %edx
  80071d:	ff d0                	call   *%eax
  80071f:	83 c4 10             	add    $0x10,%esp
}
  800722:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800725:	c9                   	leave  
  800726:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800727:	a1 04 40 80 00       	mov    0x804004,%eax
  80072c:	8b 40 48             	mov    0x48(%eax),%eax
  80072f:	83 ec 04             	sub    $0x4,%esp
  800732:	53                   	push   %ebx
  800733:	50                   	push   %eax
  800734:	68 59 1f 80 00       	push   $0x801f59
  800739:	e8 7e 0a 00 00       	call   8011bc <cprintf>
		return -E_INVAL;
  80073e:	83 c4 10             	add    $0x10,%esp
  800741:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800746:	eb da                	jmp    800722 <read+0x5e>
		return -E_NOT_SUPP;
  800748:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80074d:	eb d3                	jmp    800722 <read+0x5e>

0080074f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80074f:	f3 0f 1e fb          	endbr32 
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	57                   	push   %edi
  800757:	56                   	push   %esi
  800758:	53                   	push   %ebx
  800759:	83 ec 0c             	sub    $0xc,%esp
  80075c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80075f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800762:	bb 00 00 00 00       	mov    $0x0,%ebx
  800767:	eb 02                	jmp    80076b <readn+0x1c>
  800769:	01 c3                	add    %eax,%ebx
  80076b:	39 f3                	cmp    %esi,%ebx
  80076d:	73 21                	jae    800790 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80076f:	83 ec 04             	sub    $0x4,%esp
  800772:	89 f0                	mov    %esi,%eax
  800774:	29 d8                	sub    %ebx,%eax
  800776:	50                   	push   %eax
  800777:	89 d8                	mov    %ebx,%eax
  800779:	03 45 0c             	add    0xc(%ebp),%eax
  80077c:	50                   	push   %eax
  80077d:	57                   	push   %edi
  80077e:	e8 41 ff ff ff       	call   8006c4 <read>
		if (m < 0)
  800783:	83 c4 10             	add    $0x10,%esp
  800786:	85 c0                	test   %eax,%eax
  800788:	78 04                	js     80078e <readn+0x3f>
			return m;
		if (m == 0)
  80078a:	75 dd                	jne    800769 <readn+0x1a>
  80078c:	eb 02                	jmp    800790 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80078e:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800790:	89 d8                	mov    %ebx,%eax
  800792:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800795:	5b                   	pop    %ebx
  800796:	5e                   	pop    %esi
  800797:	5f                   	pop    %edi
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80079a:	f3 0f 1e fb          	endbr32 
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	53                   	push   %ebx
  8007a2:	83 ec 1c             	sub    $0x1c,%esp
  8007a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ab:	50                   	push   %eax
  8007ac:	53                   	push   %ebx
  8007ad:	e8 8f fc ff ff       	call   800441 <fd_lookup>
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	85 c0                	test   %eax,%eax
  8007b7:	78 3a                	js     8007f3 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b9:	83 ec 08             	sub    $0x8,%esp
  8007bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007bf:	50                   	push   %eax
  8007c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c3:	ff 30                	pushl  (%eax)
  8007c5:	e8 cb fc ff ff       	call   800495 <dev_lookup>
  8007ca:	83 c4 10             	add    $0x10,%esp
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	78 22                	js     8007f3 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007d8:	74 1e                	je     8007f8 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007dd:	8b 52 0c             	mov    0xc(%edx),%edx
  8007e0:	85 d2                	test   %edx,%edx
  8007e2:	74 35                	je     800819 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007e4:	83 ec 04             	sub    $0x4,%esp
  8007e7:	ff 75 10             	pushl  0x10(%ebp)
  8007ea:	ff 75 0c             	pushl  0xc(%ebp)
  8007ed:	50                   	push   %eax
  8007ee:	ff d2                	call   *%edx
  8007f0:	83 c4 10             	add    $0x10,%esp
}
  8007f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f6:	c9                   	leave  
  8007f7:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8007fd:	8b 40 48             	mov    0x48(%eax),%eax
  800800:	83 ec 04             	sub    $0x4,%esp
  800803:	53                   	push   %ebx
  800804:	50                   	push   %eax
  800805:	68 75 1f 80 00       	push   $0x801f75
  80080a:	e8 ad 09 00 00       	call   8011bc <cprintf>
		return -E_INVAL;
  80080f:	83 c4 10             	add    $0x10,%esp
  800812:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800817:	eb da                	jmp    8007f3 <write+0x59>
		return -E_NOT_SUPP;
  800819:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80081e:	eb d3                	jmp    8007f3 <write+0x59>

00800820 <seek>:

int
seek(int fdnum, off_t offset)
{
  800820:	f3 0f 1e fb          	endbr32 
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80082a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80082d:	50                   	push   %eax
  80082e:	ff 75 08             	pushl  0x8(%ebp)
  800831:	e8 0b fc ff ff       	call   800441 <fd_lookup>
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	85 c0                	test   %eax,%eax
  80083b:	78 0e                	js     80084b <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80083d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800840:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800843:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800846:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80084b:	c9                   	leave  
  80084c:	c3                   	ret    

0080084d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80084d:	f3 0f 1e fb          	endbr32 
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	53                   	push   %ebx
  800855:	83 ec 1c             	sub    $0x1c,%esp
  800858:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80085b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80085e:	50                   	push   %eax
  80085f:	53                   	push   %ebx
  800860:	e8 dc fb ff ff       	call   800441 <fd_lookup>
  800865:	83 c4 10             	add    $0x10,%esp
  800868:	85 c0                	test   %eax,%eax
  80086a:	78 37                	js     8008a3 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086c:	83 ec 08             	sub    $0x8,%esp
  80086f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800872:	50                   	push   %eax
  800873:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800876:	ff 30                	pushl  (%eax)
  800878:	e8 18 fc ff ff       	call   800495 <dev_lookup>
  80087d:	83 c4 10             	add    $0x10,%esp
  800880:	85 c0                	test   %eax,%eax
  800882:	78 1f                	js     8008a3 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800884:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800887:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80088b:	74 1b                	je     8008a8 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80088d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800890:	8b 52 18             	mov    0x18(%edx),%edx
  800893:	85 d2                	test   %edx,%edx
  800895:	74 32                	je     8008c9 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800897:	83 ec 08             	sub    $0x8,%esp
  80089a:	ff 75 0c             	pushl  0xc(%ebp)
  80089d:	50                   	push   %eax
  80089e:	ff d2                	call   *%edx
  8008a0:	83 c4 10             	add    $0x10,%esp
}
  8008a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a6:	c9                   	leave  
  8008a7:	c3                   	ret    
			thisenv->env_id, fdnum);
  8008a8:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008ad:	8b 40 48             	mov    0x48(%eax),%eax
  8008b0:	83 ec 04             	sub    $0x4,%esp
  8008b3:	53                   	push   %ebx
  8008b4:	50                   	push   %eax
  8008b5:	68 38 1f 80 00       	push   $0x801f38
  8008ba:	e8 fd 08 00 00       	call   8011bc <cprintf>
		return -E_INVAL;
  8008bf:	83 c4 10             	add    $0x10,%esp
  8008c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008c7:	eb da                	jmp    8008a3 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8008c9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008ce:	eb d3                	jmp    8008a3 <ftruncate+0x56>

008008d0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008d0:	f3 0f 1e fb          	endbr32 
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	53                   	push   %ebx
  8008d8:	83 ec 1c             	sub    $0x1c,%esp
  8008db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008e1:	50                   	push   %eax
  8008e2:	ff 75 08             	pushl  0x8(%ebp)
  8008e5:	e8 57 fb ff ff       	call   800441 <fd_lookup>
  8008ea:	83 c4 10             	add    $0x10,%esp
  8008ed:	85 c0                	test   %eax,%eax
  8008ef:	78 4b                	js     80093c <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008f1:	83 ec 08             	sub    $0x8,%esp
  8008f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008f7:	50                   	push   %eax
  8008f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008fb:	ff 30                	pushl  (%eax)
  8008fd:	e8 93 fb ff ff       	call   800495 <dev_lookup>
  800902:	83 c4 10             	add    $0x10,%esp
  800905:	85 c0                	test   %eax,%eax
  800907:	78 33                	js     80093c <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  800909:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80090c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800910:	74 2f                	je     800941 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800912:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800915:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80091c:	00 00 00 
	stat->st_isdir = 0;
  80091f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800926:	00 00 00 
	stat->st_dev = dev;
  800929:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80092f:	83 ec 08             	sub    $0x8,%esp
  800932:	53                   	push   %ebx
  800933:	ff 75 f0             	pushl  -0x10(%ebp)
  800936:	ff 50 14             	call   *0x14(%eax)
  800939:	83 c4 10             	add    $0x10,%esp
}
  80093c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80093f:	c9                   	leave  
  800940:	c3                   	ret    
		return -E_NOT_SUPP;
  800941:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800946:	eb f4                	jmp    80093c <fstat+0x6c>

00800948 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800948:	f3 0f 1e fb          	endbr32 
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	56                   	push   %esi
  800950:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800951:	83 ec 08             	sub    $0x8,%esp
  800954:	6a 00                	push   $0x0
  800956:	ff 75 08             	pushl  0x8(%ebp)
  800959:	e8 cf 01 00 00       	call   800b2d <open>
  80095e:	89 c3                	mov    %eax,%ebx
  800960:	83 c4 10             	add    $0x10,%esp
  800963:	85 c0                	test   %eax,%eax
  800965:	78 1b                	js     800982 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  800967:	83 ec 08             	sub    $0x8,%esp
  80096a:	ff 75 0c             	pushl  0xc(%ebp)
  80096d:	50                   	push   %eax
  80096e:	e8 5d ff ff ff       	call   8008d0 <fstat>
  800973:	89 c6                	mov    %eax,%esi
	close(fd);
  800975:	89 1c 24             	mov    %ebx,(%esp)
  800978:	e8 fd fb ff ff       	call   80057a <close>
	return r;
  80097d:	83 c4 10             	add    $0x10,%esp
  800980:	89 f3                	mov    %esi,%ebx
}
  800982:	89 d8                	mov    %ebx,%eax
  800984:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800987:	5b                   	pop    %ebx
  800988:	5e                   	pop    %esi
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	56                   	push   %esi
  80098f:	53                   	push   %ebx
  800990:	89 c6                	mov    %eax,%esi
  800992:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800994:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80099b:	74 27                	je     8009c4 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80099d:	6a 07                	push   $0x7
  80099f:	68 00 50 80 00       	push   $0x805000
  8009a4:	56                   	push   %esi
  8009a5:	ff 35 00 40 80 00    	pushl  0x804000
  8009ab:	e8 de 11 00 00       	call   801b8e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009b0:	83 c4 0c             	add    $0xc,%esp
  8009b3:	6a 00                	push   $0x0
  8009b5:	53                   	push   %ebx
  8009b6:	6a 00                	push   $0x0
  8009b8:	e8 7a 11 00 00       	call   801b37 <ipc_recv>
}
  8009bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009c0:	5b                   	pop    %ebx
  8009c1:	5e                   	pop    %esi
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009c4:	83 ec 0c             	sub    $0xc,%esp
  8009c7:	6a 01                	push   $0x1
  8009c9:	e8 26 12 00 00       	call   801bf4 <ipc_find_env>
  8009ce:	a3 00 40 80 00       	mov    %eax,0x804000
  8009d3:	83 c4 10             	add    $0x10,%esp
  8009d6:	eb c5                	jmp    80099d <fsipc+0x12>

008009d8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009d8:	f3 0f 1e fb          	endbr32 
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fa:	b8 02 00 00 00       	mov    $0x2,%eax
  8009ff:	e8 87 ff ff ff       	call   80098b <fsipc>
}
  800a04:	c9                   	leave  
  800a05:	c3                   	ret    

00800a06 <devfile_flush>:
{
  800a06:	f3 0f 1e fb          	endbr32 
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a10:	8b 45 08             	mov    0x8(%ebp),%eax
  800a13:	8b 40 0c             	mov    0xc(%eax),%eax
  800a16:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a20:	b8 06 00 00 00       	mov    $0x6,%eax
  800a25:	e8 61 ff ff ff       	call   80098b <fsipc>
}
  800a2a:	c9                   	leave  
  800a2b:	c3                   	ret    

00800a2c <devfile_stat>:
{
  800a2c:	f3 0f 1e fb          	endbr32 
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	53                   	push   %ebx
  800a34:	83 ec 04             	sub    $0x4,%esp
  800a37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a40:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a45:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4a:	b8 05 00 00 00       	mov    $0x5,%eax
  800a4f:	e8 37 ff ff ff       	call   80098b <fsipc>
  800a54:	85 c0                	test   %eax,%eax
  800a56:	78 2c                	js     800a84 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a58:	83 ec 08             	sub    $0x8,%esp
  800a5b:	68 00 50 80 00       	push   $0x805000
  800a60:	53                   	push   %ebx
  800a61:	e8 5f 0d 00 00       	call   8017c5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a66:	a1 80 50 80 00       	mov    0x805080,%eax
  800a6b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a71:	a1 84 50 80 00       	mov    0x805084,%eax
  800a76:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a7c:	83 c4 10             	add    $0x10,%esp
  800a7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a87:	c9                   	leave  
  800a88:	c3                   	ret    

00800a89 <devfile_write>:
{
  800a89:	f3 0f 1e fb          	endbr32 
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	83 ec 0c             	sub    $0xc,%esp
	panic("devfile_write not implemented");
  800a93:	68 a4 1f 80 00       	push   $0x801fa4
  800a98:	68 90 00 00 00       	push   $0x90
  800a9d:	68 c2 1f 80 00       	push   $0x801fc2
  800aa2:	e8 2e 06 00 00       	call   8010d5 <_panic>

00800aa7 <devfile_read>:
{
  800aa7:	f3 0f 1e fb          	endbr32 
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
  800ab0:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab6:	8b 40 0c             	mov    0xc(%eax),%eax
  800ab9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800abe:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ac4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac9:	b8 03 00 00 00       	mov    $0x3,%eax
  800ace:	e8 b8 fe ff ff       	call   80098b <fsipc>
  800ad3:	89 c3                	mov    %eax,%ebx
  800ad5:	85 c0                	test   %eax,%eax
  800ad7:	78 1f                	js     800af8 <devfile_read+0x51>
	assert(r <= n);
  800ad9:	39 f0                	cmp    %esi,%eax
  800adb:	77 24                	ja     800b01 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800add:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ae2:	7f 33                	jg     800b17 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae4:	83 ec 04             	sub    $0x4,%esp
  800ae7:	50                   	push   %eax
  800ae8:	68 00 50 80 00       	push   $0x805000
  800aed:	ff 75 0c             	pushl  0xc(%ebp)
  800af0:	e8 86 0e 00 00       	call   80197b <memmove>
	return r;
  800af5:	83 c4 10             	add    $0x10,%esp
}
  800af8:	89 d8                	mov    %ebx,%eax
  800afa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    
	assert(r <= n);
  800b01:	68 cd 1f 80 00       	push   $0x801fcd
  800b06:	68 d4 1f 80 00       	push   $0x801fd4
  800b0b:	6a 7c                	push   $0x7c
  800b0d:	68 c2 1f 80 00       	push   $0x801fc2
  800b12:	e8 be 05 00 00       	call   8010d5 <_panic>
	assert(r <= PGSIZE);
  800b17:	68 e9 1f 80 00       	push   $0x801fe9
  800b1c:	68 d4 1f 80 00       	push   $0x801fd4
  800b21:	6a 7d                	push   $0x7d
  800b23:	68 c2 1f 80 00       	push   $0x801fc2
  800b28:	e8 a8 05 00 00       	call   8010d5 <_panic>

00800b2d <open>:
{
  800b2d:	f3 0f 1e fb          	endbr32 
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
  800b36:	83 ec 1c             	sub    $0x1c,%esp
  800b39:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b3c:	56                   	push   %esi
  800b3d:	e8 40 0c 00 00       	call   801782 <strlen>
  800b42:	83 c4 10             	add    $0x10,%esp
  800b45:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b4a:	7f 6c                	jg     800bb8 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800b4c:	83 ec 0c             	sub    $0xc,%esp
  800b4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b52:	50                   	push   %eax
  800b53:	e8 93 f8 ff ff       	call   8003eb <fd_alloc>
  800b58:	89 c3                	mov    %eax,%ebx
  800b5a:	83 c4 10             	add    $0x10,%esp
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	78 3c                	js     800b9d <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b61:	83 ec 08             	sub    $0x8,%esp
  800b64:	56                   	push   %esi
  800b65:	68 00 50 80 00       	push   $0x805000
  800b6a:	e8 56 0c 00 00       	call   8017c5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b72:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b77:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b7a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7f:	e8 07 fe ff ff       	call   80098b <fsipc>
  800b84:	89 c3                	mov    %eax,%ebx
  800b86:	83 c4 10             	add    $0x10,%esp
  800b89:	85 c0                	test   %eax,%eax
  800b8b:	78 19                	js     800ba6 <open+0x79>
	return fd2num(fd);
  800b8d:	83 ec 0c             	sub    $0xc,%esp
  800b90:	ff 75 f4             	pushl  -0xc(%ebp)
  800b93:	e8 24 f8 ff ff       	call   8003bc <fd2num>
  800b98:	89 c3                	mov    %eax,%ebx
  800b9a:	83 c4 10             	add    $0x10,%esp
}
  800b9d:	89 d8                	mov    %ebx,%eax
  800b9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    
		fd_close(fd, 0);
  800ba6:	83 ec 08             	sub    $0x8,%esp
  800ba9:	6a 00                	push   $0x0
  800bab:	ff 75 f4             	pushl  -0xc(%ebp)
  800bae:	e8 3c f9 ff ff       	call   8004ef <fd_close>
		return r;
  800bb3:	83 c4 10             	add    $0x10,%esp
  800bb6:	eb e5                	jmp    800b9d <open+0x70>
		return -E_BAD_PATH;
  800bb8:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800bbd:	eb de                	jmp    800b9d <open+0x70>

00800bbf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bbf:	f3 0f 1e fb          	endbr32 
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bce:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd3:	e8 b3 fd ff ff       	call   80098b <fsipc>
}
  800bd8:	c9                   	leave  
  800bd9:	c3                   	ret    

00800bda <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bda:	f3 0f 1e fb          	endbr32 
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800be6:	83 ec 0c             	sub    $0xc,%esp
  800be9:	ff 75 08             	pushl  0x8(%ebp)
  800bec:	e8 df f7 ff ff       	call   8003d0 <fd2data>
  800bf1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bf3:	83 c4 08             	add    $0x8,%esp
  800bf6:	68 f5 1f 80 00       	push   $0x801ff5
  800bfb:	53                   	push   %ebx
  800bfc:	e8 c4 0b 00 00       	call   8017c5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800c01:	8b 46 04             	mov    0x4(%esi),%eax
  800c04:	2b 06                	sub    (%esi),%eax
  800c06:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800c0c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c13:	00 00 00 
	stat->st_dev = &devpipe;
  800c16:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c1d:	30 80 00 
	return 0;
}
  800c20:	b8 00 00 00 00       	mov    $0x0,%eax
  800c25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c2c:	f3 0f 1e fb          	endbr32 
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	53                   	push   %ebx
  800c34:	83 ec 0c             	sub    $0xc,%esp
  800c37:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c3a:	53                   	push   %ebx
  800c3b:	6a 00                	push   $0x0
  800c3d:	e8 f6 f5 ff ff       	call   800238 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c42:	89 1c 24             	mov    %ebx,(%esp)
  800c45:	e8 86 f7 ff ff       	call   8003d0 <fd2data>
  800c4a:	83 c4 08             	add    $0x8,%esp
  800c4d:	50                   	push   %eax
  800c4e:	6a 00                	push   $0x0
  800c50:	e8 e3 f5 ff ff       	call   800238 <sys_page_unmap>
}
  800c55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c58:	c9                   	leave  
  800c59:	c3                   	ret    

00800c5a <_pipeisclosed>:
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
  800c60:	83 ec 1c             	sub    $0x1c,%esp
  800c63:	89 c7                	mov    %eax,%edi
  800c65:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c67:	a1 04 40 80 00       	mov    0x804004,%eax
  800c6c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c6f:	83 ec 0c             	sub    $0xc,%esp
  800c72:	57                   	push   %edi
  800c73:	e8 b9 0f 00 00       	call   801c31 <pageref>
  800c78:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c7b:	89 34 24             	mov    %esi,(%esp)
  800c7e:	e8 ae 0f 00 00       	call   801c31 <pageref>
		nn = thisenv->env_runs;
  800c83:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c89:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c8c:	83 c4 10             	add    $0x10,%esp
  800c8f:	39 cb                	cmp    %ecx,%ebx
  800c91:	74 1b                	je     800cae <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c93:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c96:	75 cf                	jne    800c67 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c98:	8b 42 58             	mov    0x58(%edx),%eax
  800c9b:	6a 01                	push   $0x1
  800c9d:	50                   	push   %eax
  800c9e:	53                   	push   %ebx
  800c9f:	68 fc 1f 80 00       	push   $0x801ffc
  800ca4:	e8 13 05 00 00       	call   8011bc <cprintf>
  800ca9:	83 c4 10             	add    $0x10,%esp
  800cac:	eb b9                	jmp    800c67 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800cae:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800cb1:	0f 94 c0             	sete   %al
  800cb4:	0f b6 c0             	movzbl %al,%eax
}
  800cb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <devpipe_write>:
{
  800cbf:	f3 0f 1e fb          	endbr32 
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 28             	sub    $0x28,%esp
  800ccc:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800ccf:	56                   	push   %esi
  800cd0:	e8 fb f6 ff ff       	call   8003d0 <fd2data>
  800cd5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cd7:	83 c4 10             	add    $0x10,%esp
  800cda:	bf 00 00 00 00       	mov    $0x0,%edi
  800cdf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ce2:	74 4f                	je     800d33 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800ce4:	8b 43 04             	mov    0x4(%ebx),%eax
  800ce7:	8b 0b                	mov    (%ebx),%ecx
  800ce9:	8d 51 20             	lea    0x20(%ecx),%edx
  800cec:	39 d0                	cmp    %edx,%eax
  800cee:	72 14                	jb     800d04 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800cf0:	89 da                	mov    %ebx,%edx
  800cf2:	89 f0                	mov    %esi,%eax
  800cf4:	e8 61 ff ff ff       	call   800c5a <_pipeisclosed>
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	75 3b                	jne    800d38 <devpipe_write+0x79>
			sys_yield();
  800cfd:	e8 86 f4 ff ff       	call   800188 <sys_yield>
  800d02:	eb e0                	jmp    800ce4 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d07:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d0b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d0e:	89 c2                	mov    %eax,%edx
  800d10:	c1 fa 1f             	sar    $0x1f,%edx
  800d13:	89 d1                	mov    %edx,%ecx
  800d15:	c1 e9 1b             	shr    $0x1b,%ecx
  800d18:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800d1b:	83 e2 1f             	and    $0x1f,%edx
  800d1e:	29 ca                	sub    %ecx,%edx
  800d20:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800d24:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d28:	83 c0 01             	add    $0x1,%eax
  800d2b:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800d2e:	83 c7 01             	add    $0x1,%edi
  800d31:	eb ac                	jmp    800cdf <devpipe_write+0x20>
	return i;
  800d33:	8b 45 10             	mov    0x10(%ebp),%eax
  800d36:	eb 05                	jmp    800d3d <devpipe_write+0x7e>
				return 0;
  800d38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <devpipe_read>:
{
  800d45:	f3 0f 1e fb          	endbr32 
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	57                   	push   %edi
  800d4d:	56                   	push   %esi
  800d4e:	53                   	push   %ebx
  800d4f:	83 ec 18             	sub    $0x18,%esp
  800d52:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800d55:	57                   	push   %edi
  800d56:	e8 75 f6 ff ff       	call   8003d0 <fd2data>
  800d5b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d5d:	83 c4 10             	add    $0x10,%esp
  800d60:	be 00 00 00 00       	mov    $0x0,%esi
  800d65:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d68:	75 14                	jne    800d7e <devpipe_read+0x39>
	return i;
  800d6a:	8b 45 10             	mov    0x10(%ebp),%eax
  800d6d:	eb 02                	jmp    800d71 <devpipe_read+0x2c>
				return i;
  800d6f:	89 f0                	mov    %esi,%eax
}
  800d71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    
			sys_yield();
  800d79:	e8 0a f4 ff ff       	call   800188 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d7e:	8b 03                	mov    (%ebx),%eax
  800d80:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d83:	75 18                	jne    800d9d <devpipe_read+0x58>
			if (i > 0)
  800d85:	85 f6                	test   %esi,%esi
  800d87:	75 e6                	jne    800d6f <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d89:	89 da                	mov    %ebx,%edx
  800d8b:	89 f8                	mov    %edi,%eax
  800d8d:	e8 c8 fe ff ff       	call   800c5a <_pipeisclosed>
  800d92:	85 c0                	test   %eax,%eax
  800d94:	74 e3                	je     800d79 <devpipe_read+0x34>
				return 0;
  800d96:	b8 00 00 00 00       	mov    $0x0,%eax
  800d9b:	eb d4                	jmp    800d71 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d9d:	99                   	cltd   
  800d9e:	c1 ea 1b             	shr    $0x1b,%edx
  800da1:	01 d0                	add    %edx,%eax
  800da3:	83 e0 1f             	and    $0x1f,%eax
  800da6:	29 d0                	sub    %edx,%eax
  800da8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800dad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db0:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800db3:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800db6:	83 c6 01             	add    $0x1,%esi
  800db9:	eb aa                	jmp    800d65 <devpipe_read+0x20>

00800dbb <pipe>:
{
  800dbb:	f3 0f 1e fb          	endbr32 
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800dc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dca:	50                   	push   %eax
  800dcb:	e8 1b f6 ff ff       	call   8003eb <fd_alloc>
  800dd0:	89 c3                	mov    %eax,%ebx
  800dd2:	83 c4 10             	add    $0x10,%esp
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	0f 88 23 01 00 00    	js     800f00 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ddd:	83 ec 04             	sub    $0x4,%esp
  800de0:	68 07 04 00 00       	push   $0x407
  800de5:	ff 75 f4             	pushl  -0xc(%ebp)
  800de8:	6a 00                	push   $0x0
  800dea:	e8 bc f3 ff ff       	call   8001ab <sys_page_alloc>
  800def:	89 c3                	mov    %eax,%ebx
  800df1:	83 c4 10             	add    $0x10,%esp
  800df4:	85 c0                	test   %eax,%eax
  800df6:	0f 88 04 01 00 00    	js     800f00 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800dfc:	83 ec 0c             	sub    $0xc,%esp
  800dff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e02:	50                   	push   %eax
  800e03:	e8 e3 f5 ff ff       	call   8003eb <fd_alloc>
  800e08:	89 c3                	mov    %eax,%ebx
  800e0a:	83 c4 10             	add    $0x10,%esp
  800e0d:	85 c0                	test   %eax,%eax
  800e0f:	0f 88 db 00 00 00    	js     800ef0 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e15:	83 ec 04             	sub    $0x4,%esp
  800e18:	68 07 04 00 00       	push   $0x407
  800e1d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e20:	6a 00                	push   $0x0
  800e22:	e8 84 f3 ff ff       	call   8001ab <sys_page_alloc>
  800e27:	89 c3                	mov    %eax,%ebx
  800e29:	83 c4 10             	add    $0x10,%esp
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	0f 88 bc 00 00 00    	js     800ef0 <pipe+0x135>
	va = fd2data(fd0);
  800e34:	83 ec 0c             	sub    $0xc,%esp
  800e37:	ff 75 f4             	pushl  -0xc(%ebp)
  800e3a:	e8 91 f5 ff ff       	call   8003d0 <fd2data>
  800e3f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e41:	83 c4 0c             	add    $0xc,%esp
  800e44:	68 07 04 00 00       	push   $0x407
  800e49:	50                   	push   %eax
  800e4a:	6a 00                	push   $0x0
  800e4c:	e8 5a f3 ff ff       	call   8001ab <sys_page_alloc>
  800e51:	89 c3                	mov    %eax,%ebx
  800e53:	83 c4 10             	add    $0x10,%esp
  800e56:	85 c0                	test   %eax,%eax
  800e58:	0f 88 82 00 00 00    	js     800ee0 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e5e:	83 ec 0c             	sub    $0xc,%esp
  800e61:	ff 75 f0             	pushl  -0x10(%ebp)
  800e64:	e8 67 f5 ff ff       	call   8003d0 <fd2data>
  800e69:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e70:	50                   	push   %eax
  800e71:	6a 00                	push   $0x0
  800e73:	56                   	push   %esi
  800e74:	6a 00                	push   $0x0
  800e76:	e8 77 f3 ff ff       	call   8001f2 <sys_page_map>
  800e7b:	89 c3                	mov    %eax,%ebx
  800e7d:	83 c4 20             	add    $0x20,%esp
  800e80:	85 c0                	test   %eax,%eax
  800e82:	78 4e                	js     800ed2 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e84:	a1 20 30 80 00       	mov    0x803020,%eax
  800e89:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e8c:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e91:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e98:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e9b:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ea0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800ea7:	83 ec 0c             	sub    $0xc,%esp
  800eaa:	ff 75 f4             	pushl  -0xc(%ebp)
  800ead:	e8 0a f5 ff ff       	call   8003bc <fd2num>
  800eb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800eb7:	83 c4 04             	add    $0x4,%esp
  800eba:	ff 75 f0             	pushl  -0x10(%ebp)
  800ebd:	e8 fa f4 ff ff       	call   8003bc <fd2num>
  800ec2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800ec8:	83 c4 10             	add    $0x10,%esp
  800ecb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed0:	eb 2e                	jmp    800f00 <pipe+0x145>
	sys_page_unmap(0, va);
  800ed2:	83 ec 08             	sub    $0x8,%esp
  800ed5:	56                   	push   %esi
  800ed6:	6a 00                	push   $0x0
  800ed8:	e8 5b f3 ff ff       	call   800238 <sys_page_unmap>
  800edd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800ee0:	83 ec 08             	sub    $0x8,%esp
  800ee3:	ff 75 f0             	pushl  -0x10(%ebp)
  800ee6:	6a 00                	push   $0x0
  800ee8:	e8 4b f3 ff ff       	call   800238 <sys_page_unmap>
  800eed:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800ef0:	83 ec 08             	sub    $0x8,%esp
  800ef3:	ff 75 f4             	pushl  -0xc(%ebp)
  800ef6:	6a 00                	push   $0x0
  800ef8:	e8 3b f3 ff ff       	call   800238 <sys_page_unmap>
  800efd:	83 c4 10             	add    $0x10,%esp
}
  800f00:	89 d8                	mov    %ebx,%eax
  800f02:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f05:	5b                   	pop    %ebx
  800f06:	5e                   	pop    %esi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <pipeisclosed>:
{
  800f09:	f3 0f 1e fb          	endbr32 
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f16:	50                   	push   %eax
  800f17:	ff 75 08             	pushl  0x8(%ebp)
  800f1a:	e8 22 f5 ff ff       	call   800441 <fd_lookup>
  800f1f:	83 c4 10             	add    $0x10,%esp
  800f22:	85 c0                	test   %eax,%eax
  800f24:	78 18                	js     800f3e <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800f26:	83 ec 0c             	sub    $0xc,%esp
  800f29:	ff 75 f4             	pushl  -0xc(%ebp)
  800f2c:	e8 9f f4 ff ff       	call   8003d0 <fd2data>
  800f31:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800f33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f36:	e8 1f fd ff ff       	call   800c5a <_pipeisclosed>
  800f3b:	83 c4 10             	add    $0x10,%esp
}
  800f3e:	c9                   	leave  
  800f3f:	c3                   	ret    

00800f40 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f40:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800f44:	b8 00 00 00 00       	mov    $0x0,%eax
  800f49:	c3                   	ret    

00800f4a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f4a:	f3 0f 1e fb          	endbr32 
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f54:	68 14 20 80 00       	push   $0x802014
  800f59:	ff 75 0c             	pushl  0xc(%ebp)
  800f5c:	e8 64 08 00 00       	call   8017c5 <strcpy>
	return 0;
}
  800f61:	b8 00 00 00 00       	mov    $0x0,%eax
  800f66:	c9                   	leave  
  800f67:	c3                   	ret    

00800f68 <devcons_write>:
{
  800f68:	f3 0f 1e fb          	endbr32 
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	57                   	push   %edi
  800f70:	56                   	push   %esi
  800f71:	53                   	push   %ebx
  800f72:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f78:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f7d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f83:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f86:	73 31                	jae    800fb9 <devcons_write+0x51>
		m = n - tot;
  800f88:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f8b:	29 f3                	sub    %esi,%ebx
  800f8d:	83 fb 7f             	cmp    $0x7f,%ebx
  800f90:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f95:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f98:	83 ec 04             	sub    $0x4,%esp
  800f9b:	53                   	push   %ebx
  800f9c:	89 f0                	mov    %esi,%eax
  800f9e:	03 45 0c             	add    0xc(%ebp),%eax
  800fa1:	50                   	push   %eax
  800fa2:	57                   	push   %edi
  800fa3:	e8 d3 09 00 00       	call   80197b <memmove>
		sys_cputs(buf, m);
  800fa8:	83 c4 08             	add    $0x8,%esp
  800fab:	53                   	push   %ebx
  800fac:	57                   	push   %edi
  800fad:	e8 29 f1 ff ff       	call   8000db <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800fb2:	01 de                	add    %ebx,%esi
  800fb4:	83 c4 10             	add    $0x10,%esp
  800fb7:	eb ca                	jmp    800f83 <devcons_write+0x1b>
}
  800fb9:	89 f0                	mov    %esi,%eax
  800fbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fbe:	5b                   	pop    %ebx
  800fbf:	5e                   	pop    %esi
  800fc0:	5f                   	pop    %edi
  800fc1:	5d                   	pop    %ebp
  800fc2:	c3                   	ret    

00800fc3 <devcons_read>:
{
  800fc3:	f3 0f 1e fb          	endbr32 
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	83 ec 08             	sub    $0x8,%esp
  800fcd:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800fd2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fd6:	74 21                	je     800ff9 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800fd8:	e8 20 f1 ff ff       	call   8000fd <sys_cgetc>
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	75 07                	jne    800fe8 <devcons_read+0x25>
		sys_yield();
  800fe1:	e8 a2 f1 ff ff       	call   800188 <sys_yield>
  800fe6:	eb f0                	jmp    800fd8 <devcons_read+0x15>
	if (c < 0)
  800fe8:	78 0f                	js     800ff9 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800fea:	83 f8 04             	cmp    $0x4,%eax
  800fed:	74 0c                	je     800ffb <devcons_read+0x38>
	*(char*)vbuf = c;
  800fef:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ff2:	88 02                	mov    %al,(%edx)
	return 1;
  800ff4:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    
		return 0;
  800ffb:	b8 00 00 00 00       	mov    $0x0,%eax
  801000:	eb f7                	jmp    800ff9 <devcons_read+0x36>

00801002 <cputchar>:
{
  801002:	f3 0f 1e fb          	endbr32 
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80100c:	8b 45 08             	mov    0x8(%ebp),%eax
  80100f:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801012:	6a 01                	push   $0x1
  801014:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801017:	50                   	push   %eax
  801018:	e8 be f0 ff ff       	call   8000db <sys_cputs>
}
  80101d:	83 c4 10             	add    $0x10,%esp
  801020:	c9                   	leave  
  801021:	c3                   	ret    

00801022 <getchar>:
{
  801022:	f3 0f 1e fb          	endbr32 
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80102c:	6a 01                	push   $0x1
  80102e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801031:	50                   	push   %eax
  801032:	6a 00                	push   $0x0
  801034:	e8 8b f6 ff ff       	call   8006c4 <read>
	if (r < 0)
  801039:	83 c4 10             	add    $0x10,%esp
  80103c:	85 c0                	test   %eax,%eax
  80103e:	78 06                	js     801046 <getchar+0x24>
	if (r < 1)
  801040:	74 06                	je     801048 <getchar+0x26>
	return c;
  801042:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801046:	c9                   	leave  
  801047:	c3                   	ret    
		return -E_EOF;
  801048:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80104d:	eb f7                	jmp    801046 <getchar+0x24>

0080104f <iscons>:
{
  80104f:	f3 0f 1e fb          	endbr32 
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801059:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80105c:	50                   	push   %eax
  80105d:	ff 75 08             	pushl  0x8(%ebp)
  801060:	e8 dc f3 ff ff       	call   800441 <fd_lookup>
  801065:	83 c4 10             	add    $0x10,%esp
  801068:	85 c0                	test   %eax,%eax
  80106a:	78 11                	js     80107d <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80106c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80106f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801075:	39 10                	cmp    %edx,(%eax)
  801077:	0f 94 c0             	sete   %al
  80107a:	0f b6 c0             	movzbl %al,%eax
}
  80107d:	c9                   	leave  
  80107e:	c3                   	ret    

0080107f <opencons>:
{
  80107f:	f3 0f 1e fb          	endbr32 
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801089:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80108c:	50                   	push   %eax
  80108d:	e8 59 f3 ff ff       	call   8003eb <fd_alloc>
  801092:	83 c4 10             	add    $0x10,%esp
  801095:	85 c0                	test   %eax,%eax
  801097:	78 3a                	js     8010d3 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801099:	83 ec 04             	sub    $0x4,%esp
  80109c:	68 07 04 00 00       	push   $0x407
  8010a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8010a4:	6a 00                	push   $0x0
  8010a6:	e8 00 f1 ff ff       	call   8001ab <sys_page_alloc>
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	78 21                	js     8010d3 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8010b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8010bb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8010bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8010c7:	83 ec 0c             	sub    $0xc,%esp
  8010ca:	50                   	push   %eax
  8010cb:	e8 ec f2 ff ff       	call   8003bc <fd2num>
  8010d0:	83 c4 10             	add    $0x10,%esp
}
  8010d3:	c9                   	leave  
  8010d4:	c3                   	ret    

008010d5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010d5:	f3 0f 1e fb          	endbr32 
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	56                   	push   %esi
  8010dd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010de:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010e1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010e7:	e8 79 f0 ff ff       	call   800165 <sys_getenvid>
  8010ec:	83 ec 0c             	sub    $0xc,%esp
  8010ef:	ff 75 0c             	pushl  0xc(%ebp)
  8010f2:	ff 75 08             	pushl  0x8(%ebp)
  8010f5:	56                   	push   %esi
  8010f6:	50                   	push   %eax
  8010f7:	68 20 20 80 00       	push   $0x802020
  8010fc:	e8 bb 00 00 00       	call   8011bc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801101:	83 c4 18             	add    $0x18,%esp
  801104:	53                   	push   %ebx
  801105:	ff 75 10             	pushl  0x10(%ebp)
  801108:	e8 5a 00 00 00       	call   801167 <vcprintf>
	cprintf("\n");
  80110d:	c7 04 24 0d 20 80 00 	movl   $0x80200d,(%esp)
  801114:	e8 a3 00 00 00       	call   8011bc <cprintf>
  801119:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80111c:	cc                   	int3   
  80111d:	eb fd                	jmp    80111c <_panic+0x47>

0080111f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80111f:	f3 0f 1e fb          	endbr32 
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	53                   	push   %ebx
  801127:	83 ec 04             	sub    $0x4,%esp
  80112a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80112d:	8b 13                	mov    (%ebx),%edx
  80112f:	8d 42 01             	lea    0x1(%edx),%eax
  801132:	89 03                	mov    %eax,(%ebx)
  801134:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801137:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80113b:	3d ff 00 00 00       	cmp    $0xff,%eax
  801140:	74 09                	je     80114b <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801142:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801146:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801149:	c9                   	leave  
  80114a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80114b:	83 ec 08             	sub    $0x8,%esp
  80114e:	68 ff 00 00 00       	push   $0xff
  801153:	8d 43 08             	lea    0x8(%ebx),%eax
  801156:	50                   	push   %eax
  801157:	e8 7f ef ff ff       	call   8000db <sys_cputs>
		b->idx = 0;
  80115c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801162:	83 c4 10             	add    $0x10,%esp
  801165:	eb db                	jmp    801142 <putch+0x23>

00801167 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801167:	f3 0f 1e fb          	endbr32 
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801174:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80117b:	00 00 00 
	b.cnt = 0;
  80117e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801185:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801188:	ff 75 0c             	pushl  0xc(%ebp)
  80118b:	ff 75 08             	pushl  0x8(%ebp)
  80118e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801194:	50                   	push   %eax
  801195:	68 1f 11 80 00       	push   $0x80111f
  80119a:	e8 20 01 00 00       	call   8012bf <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80119f:	83 c4 08             	add    $0x8,%esp
  8011a2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8011a8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8011ae:	50                   	push   %eax
  8011af:	e8 27 ef ff ff       	call   8000db <sys_cputs>

	return b.cnt;
}
  8011b4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8011ba:	c9                   	leave  
  8011bb:	c3                   	ret    

008011bc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8011bc:	f3 0f 1e fb          	endbr32 
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8011c6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8011c9:	50                   	push   %eax
  8011ca:	ff 75 08             	pushl  0x8(%ebp)
  8011cd:	e8 95 ff ff ff       	call   801167 <vcprintf>
	va_end(ap);

	return cnt;
}
  8011d2:	c9                   	leave  
  8011d3:	c3                   	ret    

008011d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
  8011d7:	57                   	push   %edi
  8011d8:	56                   	push   %esi
  8011d9:	53                   	push   %ebx
  8011da:	83 ec 1c             	sub    $0x1c,%esp
  8011dd:	89 c7                	mov    %eax,%edi
  8011df:	89 d6                	mov    %edx,%esi
  8011e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e7:	89 d1                	mov    %edx,%ecx
  8011e9:	89 c2                	mov    %eax,%edx
  8011eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011ee:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8011f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8011f4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011fa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801201:	39 c2                	cmp    %eax,%edx
  801203:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801206:	72 3e                	jb     801246 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801208:	83 ec 0c             	sub    $0xc,%esp
  80120b:	ff 75 18             	pushl  0x18(%ebp)
  80120e:	83 eb 01             	sub    $0x1,%ebx
  801211:	53                   	push   %ebx
  801212:	50                   	push   %eax
  801213:	83 ec 08             	sub    $0x8,%esp
  801216:	ff 75 e4             	pushl  -0x1c(%ebp)
  801219:	ff 75 e0             	pushl  -0x20(%ebp)
  80121c:	ff 75 dc             	pushl  -0x24(%ebp)
  80121f:	ff 75 d8             	pushl  -0x28(%ebp)
  801222:	e8 59 0a 00 00       	call   801c80 <__udivdi3>
  801227:	83 c4 18             	add    $0x18,%esp
  80122a:	52                   	push   %edx
  80122b:	50                   	push   %eax
  80122c:	89 f2                	mov    %esi,%edx
  80122e:	89 f8                	mov    %edi,%eax
  801230:	e8 9f ff ff ff       	call   8011d4 <printnum>
  801235:	83 c4 20             	add    $0x20,%esp
  801238:	eb 13                	jmp    80124d <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80123a:	83 ec 08             	sub    $0x8,%esp
  80123d:	56                   	push   %esi
  80123e:	ff 75 18             	pushl  0x18(%ebp)
  801241:	ff d7                	call   *%edi
  801243:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801246:	83 eb 01             	sub    $0x1,%ebx
  801249:	85 db                	test   %ebx,%ebx
  80124b:	7f ed                	jg     80123a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80124d:	83 ec 08             	sub    $0x8,%esp
  801250:	56                   	push   %esi
  801251:	83 ec 04             	sub    $0x4,%esp
  801254:	ff 75 e4             	pushl  -0x1c(%ebp)
  801257:	ff 75 e0             	pushl  -0x20(%ebp)
  80125a:	ff 75 dc             	pushl  -0x24(%ebp)
  80125d:	ff 75 d8             	pushl  -0x28(%ebp)
  801260:	e8 2b 0b 00 00       	call   801d90 <__umoddi3>
  801265:	83 c4 14             	add    $0x14,%esp
  801268:	0f be 80 43 20 80 00 	movsbl 0x802043(%eax),%eax
  80126f:	50                   	push   %eax
  801270:	ff d7                	call   *%edi
}
  801272:	83 c4 10             	add    $0x10,%esp
  801275:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801278:	5b                   	pop    %ebx
  801279:	5e                   	pop    %esi
  80127a:	5f                   	pop    %edi
  80127b:	5d                   	pop    %ebp
  80127c:	c3                   	ret    

0080127d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80127d:	f3 0f 1e fb          	endbr32 
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801287:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80128b:	8b 10                	mov    (%eax),%edx
  80128d:	3b 50 04             	cmp    0x4(%eax),%edx
  801290:	73 0a                	jae    80129c <sprintputch+0x1f>
		*b->buf++ = ch;
  801292:	8d 4a 01             	lea    0x1(%edx),%ecx
  801295:	89 08                	mov    %ecx,(%eax)
  801297:	8b 45 08             	mov    0x8(%ebp),%eax
  80129a:	88 02                	mov    %al,(%edx)
}
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    

0080129e <printfmt>:
{
  80129e:	f3 0f 1e fb          	endbr32 
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8012a8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012ab:	50                   	push   %eax
  8012ac:	ff 75 10             	pushl  0x10(%ebp)
  8012af:	ff 75 0c             	pushl  0xc(%ebp)
  8012b2:	ff 75 08             	pushl  0x8(%ebp)
  8012b5:	e8 05 00 00 00       	call   8012bf <vprintfmt>
}
  8012ba:	83 c4 10             	add    $0x10,%esp
  8012bd:	c9                   	leave  
  8012be:	c3                   	ret    

008012bf <vprintfmt>:
{
  8012bf:	f3 0f 1e fb          	endbr32 
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	57                   	push   %edi
  8012c7:	56                   	push   %esi
  8012c8:	53                   	push   %ebx
  8012c9:	83 ec 3c             	sub    $0x3c,%esp
  8012cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8012cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012d2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012d5:	e9 4a 03 00 00       	jmp    801624 <vprintfmt+0x365>
		padc = ' ';
  8012da:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012de:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012e5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012ec:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012f3:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012f8:	8d 47 01             	lea    0x1(%edi),%eax
  8012fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012fe:	0f b6 17             	movzbl (%edi),%edx
  801301:	8d 42 dd             	lea    -0x23(%edx),%eax
  801304:	3c 55                	cmp    $0x55,%al
  801306:	0f 87 de 03 00 00    	ja     8016ea <vprintfmt+0x42b>
  80130c:	0f b6 c0             	movzbl %al,%eax
  80130f:	3e ff 24 85 80 21 80 	notrack jmp *0x802180(,%eax,4)
  801316:	00 
  801317:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80131a:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80131e:	eb d8                	jmp    8012f8 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801320:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801323:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801327:	eb cf                	jmp    8012f8 <vprintfmt+0x39>
  801329:	0f b6 d2             	movzbl %dl,%edx
  80132c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80132f:	b8 00 00 00 00       	mov    $0x0,%eax
  801334:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801337:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80133a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80133e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801341:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801344:	83 f9 09             	cmp    $0x9,%ecx
  801347:	77 55                	ja     80139e <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  801349:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80134c:	eb e9                	jmp    801337 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80134e:	8b 45 14             	mov    0x14(%ebp),%eax
  801351:	8b 00                	mov    (%eax),%eax
  801353:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801356:	8b 45 14             	mov    0x14(%ebp),%eax
  801359:	8d 40 04             	lea    0x4(%eax),%eax
  80135c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80135f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801362:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801366:	79 90                	jns    8012f8 <vprintfmt+0x39>
				width = precision, precision = -1;
  801368:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80136b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80136e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801375:	eb 81                	jmp    8012f8 <vprintfmt+0x39>
  801377:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80137a:	85 c0                	test   %eax,%eax
  80137c:	ba 00 00 00 00       	mov    $0x0,%edx
  801381:	0f 49 d0             	cmovns %eax,%edx
  801384:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801387:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80138a:	e9 69 ff ff ff       	jmp    8012f8 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80138f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801392:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801399:	e9 5a ff ff ff       	jmp    8012f8 <vprintfmt+0x39>
  80139e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8013a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8013a4:	eb bc                	jmp    801362 <vprintfmt+0xa3>
			lflag++;
  8013a6:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8013a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8013ac:	e9 47 ff ff ff       	jmp    8012f8 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8013b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b4:	8d 78 04             	lea    0x4(%eax),%edi
  8013b7:	83 ec 08             	sub    $0x8,%esp
  8013ba:	53                   	push   %ebx
  8013bb:	ff 30                	pushl  (%eax)
  8013bd:	ff d6                	call   *%esi
			break;
  8013bf:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8013c2:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8013c5:	e9 57 02 00 00       	jmp    801621 <vprintfmt+0x362>
			err = va_arg(ap, int);
  8013ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8013cd:	8d 78 04             	lea    0x4(%eax),%edi
  8013d0:	8b 00                	mov    (%eax),%eax
  8013d2:	99                   	cltd   
  8013d3:	31 d0                	xor    %edx,%eax
  8013d5:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013d7:	83 f8 0f             	cmp    $0xf,%eax
  8013da:	7f 23                	jg     8013ff <vprintfmt+0x140>
  8013dc:	8b 14 85 e0 22 80 00 	mov    0x8022e0(,%eax,4),%edx
  8013e3:	85 d2                	test   %edx,%edx
  8013e5:	74 18                	je     8013ff <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8013e7:	52                   	push   %edx
  8013e8:	68 e6 1f 80 00       	push   $0x801fe6
  8013ed:	53                   	push   %ebx
  8013ee:	56                   	push   %esi
  8013ef:	e8 aa fe ff ff       	call   80129e <printfmt>
  8013f4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8013f7:	89 7d 14             	mov    %edi,0x14(%ebp)
  8013fa:	e9 22 02 00 00       	jmp    801621 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8013ff:	50                   	push   %eax
  801400:	68 5b 20 80 00       	push   $0x80205b
  801405:	53                   	push   %ebx
  801406:	56                   	push   %esi
  801407:	e8 92 fe ff ff       	call   80129e <printfmt>
  80140c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80140f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801412:	e9 0a 02 00 00       	jmp    801621 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  801417:	8b 45 14             	mov    0x14(%ebp),%eax
  80141a:	83 c0 04             	add    $0x4,%eax
  80141d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801420:	8b 45 14             	mov    0x14(%ebp),%eax
  801423:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801425:	85 d2                	test   %edx,%edx
  801427:	b8 54 20 80 00       	mov    $0x802054,%eax
  80142c:	0f 45 c2             	cmovne %edx,%eax
  80142f:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801432:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801436:	7e 06                	jle    80143e <vprintfmt+0x17f>
  801438:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80143c:	75 0d                	jne    80144b <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80143e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801441:	89 c7                	mov    %eax,%edi
  801443:	03 45 e0             	add    -0x20(%ebp),%eax
  801446:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801449:	eb 55                	jmp    8014a0 <vprintfmt+0x1e1>
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	ff 75 d8             	pushl  -0x28(%ebp)
  801451:	ff 75 cc             	pushl  -0x34(%ebp)
  801454:	e8 45 03 00 00       	call   80179e <strnlen>
  801459:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80145c:	29 c2                	sub    %eax,%edx
  80145e:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  801466:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80146a:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80146d:	85 ff                	test   %edi,%edi
  80146f:	7e 11                	jle    801482 <vprintfmt+0x1c3>
					putch(padc, putdat);
  801471:	83 ec 08             	sub    $0x8,%esp
  801474:	53                   	push   %ebx
  801475:	ff 75 e0             	pushl  -0x20(%ebp)
  801478:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80147a:	83 ef 01             	sub    $0x1,%edi
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	eb eb                	jmp    80146d <vprintfmt+0x1ae>
  801482:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801485:	85 d2                	test   %edx,%edx
  801487:	b8 00 00 00 00       	mov    $0x0,%eax
  80148c:	0f 49 c2             	cmovns %edx,%eax
  80148f:	29 c2                	sub    %eax,%edx
  801491:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801494:	eb a8                	jmp    80143e <vprintfmt+0x17f>
					putch(ch, putdat);
  801496:	83 ec 08             	sub    $0x8,%esp
  801499:	53                   	push   %ebx
  80149a:	52                   	push   %edx
  80149b:	ff d6                	call   *%esi
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014a3:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014a5:	83 c7 01             	add    $0x1,%edi
  8014a8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014ac:	0f be d0             	movsbl %al,%edx
  8014af:	85 d2                	test   %edx,%edx
  8014b1:	74 4b                	je     8014fe <vprintfmt+0x23f>
  8014b3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014b7:	78 06                	js     8014bf <vprintfmt+0x200>
  8014b9:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014bd:	78 1e                	js     8014dd <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8014bf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014c3:	74 d1                	je     801496 <vprintfmt+0x1d7>
  8014c5:	0f be c0             	movsbl %al,%eax
  8014c8:	83 e8 20             	sub    $0x20,%eax
  8014cb:	83 f8 5e             	cmp    $0x5e,%eax
  8014ce:	76 c6                	jbe    801496 <vprintfmt+0x1d7>
					putch('?', putdat);
  8014d0:	83 ec 08             	sub    $0x8,%esp
  8014d3:	53                   	push   %ebx
  8014d4:	6a 3f                	push   $0x3f
  8014d6:	ff d6                	call   *%esi
  8014d8:	83 c4 10             	add    $0x10,%esp
  8014db:	eb c3                	jmp    8014a0 <vprintfmt+0x1e1>
  8014dd:	89 cf                	mov    %ecx,%edi
  8014df:	eb 0e                	jmp    8014ef <vprintfmt+0x230>
				putch(' ', putdat);
  8014e1:	83 ec 08             	sub    $0x8,%esp
  8014e4:	53                   	push   %ebx
  8014e5:	6a 20                	push   $0x20
  8014e7:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8014e9:	83 ef 01             	sub    $0x1,%edi
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	85 ff                	test   %edi,%edi
  8014f1:	7f ee                	jg     8014e1 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8014f3:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8014f6:	89 45 14             	mov    %eax,0x14(%ebp)
  8014f9:	e9 23 01 00 00       	jmp    801621 <vprintfmt+0x362>
  8014fe:	89 cf                	mov    %ecx,%edi
  801500:	eb ed                	jmp    8014ef <vprintfmt+0x230>
	if (lflag >= 2)
  801502:	83 f9 01             	cmp    $0x1,%ecx
  801505:	7f 1b                	jg     801522 <vprintfmt+0x263>
	else if (lflag)
  801507:	85 c9                	test   %ecx,%ecx
  801509:	74 63                	je     80156e <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80150b:	8b 45 14             	mov    0x14(%ebp),%eax
  80150e:	8b 00                	mov    (%eax),%eax
  801510:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801513:	99                   	cltd   
  801514:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801517:	8b 45 14             	mov    0x14(%ebp),%eax
  80151a:	8d 40 04             	lea    0x4(%eax),%eax
  80151d:	89 45 14             	mov    %eax,0x14(%ebp)
  801520:	eb 17                	jmp    801539 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  801522:	8b 45 14             	mov    0x14(%ebp),%eax
  801525:	8b 50 04             	mov    0x4(%eax),%edx
  801528:	8b 00                	mov    (%eax),%eax
  80152a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80152d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801530:	8b 45 14             	mov    0x14(%ebp),%eax
  801533:	8d 40 08             	lea    0x8(%eax),%eax
  801536:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801539:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80153c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80153f:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  801544:	85 c9                	test   %ecx,%ecx
  801546:	0f 89 bb 00 00 00    	jns    801607 <vprintfmt+0x348>
				putch('-', putdat);
  80154c:	83 ec 08             	sub    $0x8,%esp
  80154f:	53                   	push   %ebx
  801550:	6a 2d                	push   $0x2d
  801552:	ff d6                	call   *%esi
				num = -(long long) num;
  801554:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801557:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80155a:	f7 da                	neg    %edx
  80155c:	83 d1 00             	adc    $0x0,%ecx
  80155f:	f7 d9                	neg    %ecx
  801561:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801564:	b8 0a 00 00 00       	mov    $0xa,%eax
  801569:	e9 99 00 00 00       	jmp    801607 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80156e:	8b 45 14             	mov    0x14(%ebp),%eax
  801571:	8b 00                	mov    (%eax),%eax
  801573:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801576:	99                   	cltd   
  801577:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80157a:	8b 45 14             	mov    0x14(%ebp),%eax
  80157d:	8d 40 04             	lea    0x4(%eax),%eax
  801580:	89 45 14             	mov    %eax,0x14(%ebp)
  801583:	eb b4                	jmp    801539 <vprintfmt+0x27a>
	if (lflag >= 2)
  801585:	83 f9 01             	cmp    $0x1,%ecx
  801588:	7f 1b                	jg     8015a5 <vprintfmt+0x2e6>
	else if (lflag)
  80158a:	85 c9                	test   %ecx,%ecx
  80158c:	74 2c                	je     8015ba <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80158e:	8b 45 14             	mov    0x14(%ebp),%eax
  801591:	8b 10                	mov    (%eax),%edx
  801593:	b9 00 00 00 00       	mov    $0x0,%ecx
  801598:	8d 40 04             	lea    0x4(%eax),%eax
  80159b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80159e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8015a3:	eb 62                	jmp    801607 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8015a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a8:	8b 10                	mov    (%eax),%edx
  8015aa:	8b 48 04             	mov    0x4(%eax),%ecx
  8015ad:	8d 40 08             	lea    0x8(%eax),%eax
  8015b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015b3:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8015b8:	eb 4d                	jmp    801607 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8015ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8015bd:	8b 10                	mov    (%eax),%edx
  8015bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015c4:	8d 40 04             	lea    0x4(%eax),%eax
  8015c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015ca:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8015cf:	eb 36                	jmp    801607 <vprintfmt+0x348>
	if (lflag >= 2)
  8015d1:	83 f9 01             	cmp    $0x1,%ecx
  8015d4:	7f 17                	jg     8015ed <vprintfmt+0x32e>
	else if (lflag)
  8015d6:	85 c9                	test   %ecx,%ecx
  8015d8:	74 6e                	je     801648 <vprintfmt+0x389>
		return va_arg(*ap, long);
  8015da:	8b 45 14             	mov    0x14(%ebp),%eax
  8015dd:	8b 10                	mov    (%eax),%edx
  8015df:	89 d0                	mov    %edx,%eax
  8015e1:	99                   	cltd   
  8015e2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015e5:	8d 49 04             	lea    0x4(%ecx),%ecx
  8015e8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8015eb:	eb 11                	jmp    8015fe <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8015ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f0:	8b 50 04             	mov    0x4(%eax),%edx
  8015f3:	8b 00                	mov    (%eax),%eax
  8015f5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015f8:	8d 49 08             	lea    0x8(%ecx),%ecx
  8015fb:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8015fe:	89 d1                	mov    %edx,%ecx
  801600:	89 c2                	mov    %eax,%edx
            base = 8;
  801602:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  801607:	83 ec 0c             	sub    $0xc,%esp
  80160a:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80160e:	57                   	push   %edi
  80160f:	ff 75 e0             	pushl  -0x20(%ebp)
  801612:	50                   	push   %eax
  801613:	51                   	push   %ecx
  801614:	52                   	push   %edx
  801615:	89 da                	mov    %ebx,%edx
  801617:	89 f0                	mov    %esi,%eax
  801619:	e8 b6 fb ff ff       	call   8011d4 <printnum>
			break;
  80161e:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  801621:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801624:	83 c7 01             	add    $0x1,%edi
  801627:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80162b:	83 f8 25             	cmp    $0x25,%eax
  80162e:	0f 84 a6 fc ff ff    	je     8012da <vprintfmt+0x1b>
			if (ch == '\0')
  801634:	85 c0                	test   %eax,%eax
  801636:	0f 84 ce 00 00 00    	je     80170a <vprintfmt+0x44b>
			putch(ch, putdat);
  80163c:	83 ec 08             	sub    $0x8,%esp
  80163f:	53                   	push   %ebx
  801640:	50                   	push   %eax
  801641:	ff d6                	call   *%esi
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	eb dc                	jmp    801624 <vprintfmt+0x365>
		return va_arg(*ap, int);
  801648:	8b 45 14             	mov    0x14(%ebp),%eax
  80164b:	8b 10                	mov    (%eax),%edx
  80164d:	89 d0                	mov    %edx,%eax
  80164f:	99                   	cltd   
  801650:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801653:	8d 49 04             	lea    0x4(%ecx),%ecx
  801656:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801659:	eb a3                	jmp    8015fe <vprintfmt+0x33f>
			putch('0', putdat);
  80165b:	83 ec 08             	sub    $0x8,%esp
  80165e:	53                   	push   %ebx
  80165f:	6a 30                	push   $0x30
  801661:	ff d6                	call   *%esi
			putch('x', putdat);
  801663:	83 c4 08             	add    $0x8,%esp
  801666:	53                   	push   %ebx
  801667:	6a 78                	push   $0x78
  801669:	ff d6                	call   *%esi
			num = (unsigned long long)
  80166b:	8b 45 14             	mov    0x14(%ebp),%eax
  80166e:	8b 10                	mov    (%eax),%edx
  801670:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801675:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801678:	8d 40 04             	lea    0x4(%eax),%eax
  80167b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80167e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801683:	eb 82                	jmp    801607 <vprintfmt+0x348>
	if (lflag >= 2)
  801685:	83 f9 01             	cmp    $0x1,%ecx
  801688:	7f 1e                	jg     8016a8 <vprintfmt+0x3e9>
	else if (lflag)
  80168a:	85 c9                	test   %ecx,%ecx
  80168c:	74 32                	je     8016c0 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80168e:	8b 45 14             	mov    0x14(%ebp),%eax
  801691:	8b 10                	mov    (%eax),%edx
  801693:	b9 00 00 00 00       	mov    $0x0,%ecx
  801698:	8d 40 04             	lea    0x4(%eax),%eax
  80169b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80169e:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8016a3:	e9 5f ff ff ff       	jmp    801607 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8016a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8016ab:	8b 10                	mov    (%eax),%edx
  8016ad:	8b 48 04             	mov    0x4(%eax),%ecx
  8016b0:	8d 40 08             	lea    0x8(%eax),%eax
  8016b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016b6:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8016bb:	e9 47 ff ff ff       	jmp    801607 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8016c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c3:	8b 10                	mov    (%eax),%edx
  8016c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016ca:	8d 40 04             	lea    0x4(%eax),%eax
  8016cd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016d0:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8016d5:	e9 2d ff ff ff       	jmp    801607 <vprintfmt+0x348>
			putch(ch, putdat);
  8016da:	83 ec 08             	sub    $0x8,%esp
  8016dd:	53                   	push   %ebx
  8016de:	6a 25                	push   $0x25
  8016e0:	ff d6                	call   *%esi
			break;
  8016e2:	83 c4 10             	add    $0x10,%esp
  8016e5:	e9 37 ff ff ff       	jmp    801621 <vprintfmt+0x362>
			putch('%', putdat);
  8016ea:	83 ec 08             	sub    $0x8,%esp
  8016ed:	53                   	push   %ebx
  8016ee:	6a 25                	push   $0x25
  8016f0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8016f2:	83 c4 10             	add    $0x10,%esp
  8016f5:	89 f8                	mov    %edi,%eax
  8016f7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8016fb:	74 05                	je     801702 <vprintfmt+0x443>
  8016fd:	83 e8 01             	sub    $0x1,%eax
  801700:	eb f5                	jmp    8016f7 <vprintfmt+0x438>
  801702:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801705:	e9 17 ff ff ff       	jmp    801621 <vprintfmt+0x362>
}
  80170a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80170d:	5b                   	pop    %ebx
  80170e:	5e                   	pop    %esi
  80170f:	5f                   	pop    %edi
  801710:	5d                   	pop    %ebp
  801711:	c3                   	ret    

00801712 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801712:	f3 0f 1e fb          	endbr32 
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	83 ec 18             	sub    $0x18,%esp
  80171c:	8b 45 08             	mov    0x8(%ebp),%eax
  80171f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801722:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801725:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801729:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80172c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801733:	85 c0                	test   %eax,%eax
  801735:	74 26                	je     80175d <vsnprintf+0x4b>
  801737:	85 d2                	test   %edx,%edx
  801739:	7e 22                	jle    80175d <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80173b:	ff 75 14             	pushl  0x14(%ebp)
  80173e:	ff 75 10             	pushl  0x10(%ebp)
  801741:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801744:	50                   	push   %eax
  801745:	68 7d 12 80 00       	push   $0x80127d
  80174a:	e8 70 fb ff ff       	call   8012bf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80174f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801752:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801758:	83 c4 10             	add    $0x10,%esp
}
  80175b:	c9                   	leave  
  80175c:	c3                   	ret    
		return -E_INVAL;
  80175d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801762:	eb f7                	jmp    80175b <vsnprintf+0x49>

00801764 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801764:	f3 0f 1e fb          	endbr32 
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80176e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801771:	50                   	push   %eax
  801772:	ff 75 10             	pushl  0x10(%ebp)
  801775:	ff 75 0c             	pushl  0xc(%ebp)
  801778:	ff 75 08             	pushl  0x8(%ebp)
  80177b:	e8 92 ff ff ff       	call   801712 <vsnprintf>
	va_end(ap);

	return rc;
}
  801780:	c9                   	leave  
  801781:	c3                   	ret    

00801782 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801782:	f3 0f 1e fb          	endbr32 
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80178c:	b8 00 00 00 00       	mov    $0x0,%eax
  801791:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801795:	74 05                	je     80179c <strlen+0x1a>
		n++;
  801797:	83 c0 01             	add    $0x1,%eax
  80179a:	eb f5                	jmp    801791 <strlen+0xf>
	return n;
}
  80179c:	5d                   	pop    %ebp
  80179d:	c3                   	ret    

0080179e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80179e:	f3 0f 1e fb          	endbr32 
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8017ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b0:	39 d0                	cmp    %edx,%eax
  8017b2:	74 0d                	je     8017c1 <strnlen+0x23>
  8017b4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8017b8:	74 05                	je     8017bf <strnlen+0x21>
		n++;
  8017ba:	83 c0 01             	add    $0x1,%eax
  8017bd:	eb f1                	jmp    8017b0 <strnlen+0x12>
  8017bf:	89 c2                	mov    %eax,%edx
	return n;
}
  8017c1:	89 d0                	mov    %edx,%eax
  8017c3:	5d                   	pop    %ebp
  8017c4:	c3                   	ret    

008017c5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8017c5:	f3 0f 1e fb          	endbr32 
  8017c9:	55                   	push   %ebp
  8017ca:	89 e5                	mov    %esp,%ebp
  8017cc:	53                   	push   %ebx
  8017cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8017d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8017dc:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8017df:	83 c0 01             	add    $0x1,%eax
  8017e2:	84 d2                	test   %dl,%dl
  8017e4:	75 f2                	jne    8017d8 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8017e6:	89 c8                	mov    %ecx,%eax
  8017e8:	5b                   	pop    %ebx
  8017e9:	5d                   	pop    %ebp
  8017ea:	c3                   	ret    

008017eb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017eb:	f3 0f 1e fb          	endbr32 
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	53                   	push   %ebx
  8017f3:	83 ec 10             	sub    $0x10,%esp
  8017f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8017f9:	53                   	push   %ebx
  8017fa:	e8 83 ff ff ff       	call   801782 <strlen>
  8017ff:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801802:	ff 75 0c             	pushl  0xc(%ebp)
  801805:	01 d8                	add    %ebx,%eax
  801807:	50                   	push   %eax
  801808:	e8 b8 ff ff ff       	call   8017c5 <strcpy>
	return dst;
}
  80180d:	89 d8                	mov    %ebx,%eax
  80180f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801812:	c9                   	leave  
  801813:	c3                   	ret    

00801814 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801814:	f3 0f 1e fb          	endbr32 
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	56                   	push   %esi
  80181c:	53                   	push   %ebx
  80181d:	8b 75 08             	mov    0x8(%ebp),%esi
  801820:	8b 55 0c             	mov    0xc(%ebp),%edx
  801823:	89 f3                	mov    %esi,%ebx
  801825:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801828:	89 f0                	mov    %esi,%eax
  80182a:	39 d8                	cmp    %ebx,%eax
  80182c:	74 11                	je     80183f <strncpy+0x2b>
		*dst++ = *src;
  80182e:	83 c0 01             	add    $0x1,%eax
  801831:	0f b6 0a             	movzbl (%edx),%ecx
  801834:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801837:	80 f9 01             	cmp    $0x1,%cl
  80183a:	83 da ff             	sbb    $0xffffffff,%edx
  80183d:	eb eb                	jmp    80182a <strncpy+0x16>
	}
	return ret;
}
  80183f:	89 f0                	mov    %esi,%eax
  801841:	5b                   	pop    %ebx
  801842:	5e                   	pop    %esi
  801843:	5d                   	pop    %ebp
  801844:	c3                   	ret    

00801845 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801845:	f3 0f 1e fb          	endbr32 
  801849:	55                   	push   %ebp
  80184a:	89 e5                	mov    %esp,%ebp
  80184c:	56                   	push   %esi
  80184d:	53                   	push   %ebx
  80184e:	8b 75 08             	mov    0x8(%ebp),%esi
  801851:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801854:	8b 55 10             	mov    0x10(%ebp),%edx
  801857:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801859:	85 d2                	test   %edx,%edx
  80185b:	74 21                	je     80187e <strlcpy+0x39>
  80185d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801861:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801863:	39 c2                	cmp    %eax,%edx
  801865:	74 14                	je     80187b <strlcpy+0x36>
  801867:	0f b6 19             	movzbl (%ecx),%ebx
  80186a:	84 db                	test   %bl,%bl
  80186c:	74 0b                	je     801879 <strlcpy+0x34>
			*dst++ = *src++;
  80186e:	83 c1 01             	add    $0x1,%ecx
  801871:	83 c2 01             	add    $0x1,%edx
  801874:	88 5a ff             	mov    %bl,-0x1(%edx)
  801877:	eb ea                	jmp    801863 <strlcpy+0x1e>
  801879:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80187b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80187e:	29 f0                	sub    %esi,%eax
}
  801880:	5b                   	pop    %ebx
  801881:	5e                   	pop    %esi
  801882:	5d                   	pop    %ebp
  801883:	c3                   	ret    

00801884 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801884:	f3 0f 1e fb          	endbr32 
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80188e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801891:	0f b6 01             	movzbl (%ecx),%eax
  801894:	84 c0                	test   %al,%al
  801896:	74 0c                	je     8018a4 <strcmp+0x20>
  801898:	3a 02                	cmp    (%edx),%al
  80189a:	75 08                	jne    8018a4 <strcmp+0x20>
		p++, q++;
  80189c:	83 c1 01             	add    $0x1,%ecx
  80189f:	83 c2 01             	add    $0x1,%edx
  8018a2:	eb ed                	jmp    801891 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8018a4:	0f b6 c0             	movzbl %al,%eax
  8018a7:	0f b6 12             	movzbl (%edx),%edx
  8018aa:	29 d0                	sub    %edx,%eax
}
  8018ac:	5d                   	pop    %ebp
  8018ad:	c3                   	ret    

008018ae <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8018ae:	f3 0f 1e fb          	endbr32 
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	53                   	push   %ebx
  8018b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018bc:	89 c3                	mov    %eax,%ebx
  8018be:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8018c1:	eb 06                	jmp    8018c9 <strncmp+0x1b>
		n--, p++, q++;
  8018c3:	83 c0 01             	add    $0x1,%eax
  8018c6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8018c9:	39 d8                	cmp    %ebx,%eax
  8018cb:	74 16                	je     8018e3 <strncmp+0x35>
  8018cd:	0f b6 08             	movzbl (%eax),%ecx
  8018d0:	84 c9                	test   %cl,%cl
  8018d2:	74 04                	je     8018d8 <strncmp+0x2a>
  8018d4:	3a 0a                	cmp    (%edx),%cl
  8018d6:	74 eb                	je     8018c3 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8018d8:	0f b6 00             	movzbl (%eax),%eax
  8018db:	0f b6 12             	movzbl (%edx),%edx
  8018de:	29 d0                	sub    %edx,%eax
}
  8018e0:	5b                   	pop    %ebx
  8018e1:	5d                   	pop    %ebp
  8018e2:	c3                   	ret    
		return 0;
  8018e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e8:	eb f6                	jmp    8018e0 <strncmp+0x32>

008018ea <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8018ea:	f3 0f 1e fb          	endbr32 
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018f8:	0f b6 10             	movzbl (%eax),%edx
  8018fb:	84 d2                	test   %dl,%dl
  8018fd:	74 09                	je     801908 <strchr+0x1e>
		if (*s == c)
  8018ff:	38 ca                	cmp    %cl,%dl
  801901:	74 0a                	je     80190d <strchr+0x23>
	for (; *s; s++)
  801903:	83 c0 01             	add    $0x1,%eax
  801906:	eb f0                	jmp    8018f8 <strchr+0xe>
			return (char *) s;
	return 0;
  801908:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80190d:	5d                   	pop    %ebp
  80190e:	c3                   	ret    

0080190f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80190f:	f3 0f 1e fb          	endbr32 
  801913:	55                   	push   %ebp
  801914:	89 e5                	mov    %esp,%ebp
  801916:	8b 45 08             	mov    0x8(%ebp),%eax
  801919:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80191d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801920:	38 ca                	cmp    %cl,%dl
  801922:	74 09                	je     80192d <strfind+0x1e>
  801924:	84 d2                	test   %dl,%dl
  801926:	74 05                	je     80192d <strfind+0x1e>
	for (; *s; s++)
  801928:	83 c0 01             	add    $0x1,%eax
  80192b:	eb f0                	jmp    80191d <strfind+0xe>
			break;
	return (char *) s;
}
  80192d:	5d                   	pop    %ebp
  80192e:	c3                   	ret    

0080192f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80192f:	f3 0f 1e fb          	endbr32 
  801933:	55                   	push   %ebp
  801934:	89 e5                	mov    %esp,%ebp
  801936:	57                   	push   %edi
  801937:	56                   	push   %esi
  801938:	53                   	push   %ebx
  801939:	8b 7d 08             	mov    0x8(%ebp),%edi
  80193c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80193f:	85 c9                	test   %ecx,%ecx
  801941:	74 31                	je     801974 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801943:	89 f8                	mov    %edi,%eax
  801945:	09 c8                	or     %ecx,%eax
  801947:	a8 03                	test   $0x3,%al
  801949:	75 23                	jne    80196e <memset+0x3f>
		c &= 0xFF;
  80194b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80194f:	89 d3                	mov    %edx,%ebx
  801951:	c1 e3 08             	shl    $0x8,%ebx
  801954:	89 d0                	mov    %edx,%eax
  801956:	c1 e0 18             	shl    $0x18,%eax
  801959:	89 d6                	mov    %edx,%esi
  80195b:	c1 e6 10             	shl    $0x10,%esi
  80195e:	09 f0                	or     %esi,%eax
  801960:	09 c2                	or     %eax,%edx
  801962:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801964:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801967:	89 d0                	mov    %edx,%eax
  801969:	fc                   	cld    
  80196a:	f3 ab                	rep stos %eax,%es:(%edi)
  80196c:	eb 06                	jmp    801974 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80196e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801971:	fc                   	cld    
  801972:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801974:	89 f8                	mov    %edi,%eax
  801976:	5b                   	pop    %ebx
  801977:	5e                   	pop    %esi
  801978:	5f                   	pop    %edi
  801979:	5d                   	pop    %ebp
  80197a:	c3                   	ret    

0080197b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80197b:	f3 0f 1e fb          	endbr32 
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	57                   	push   %edi
  801983:	56                   	push   %esi
  801984:	8b 45 08             	mov    0x8(%ebp),%eax
  801987:	8b 75 0c             	mov    0xc(%ebp),%esi
  80198a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80198d:	39 c6                	cmp    %eax,%esi
  80198f:	73 32                	jae    8019c3 <memmove+0x48>
  801991:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801994:	39 c2                	cmp    %eax,%edx
  801996:	76 2b                	jbe    8019c3 <memmove+0x48>
		s += n;
		d += n;
  801998:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80199b:	89 fe                	mov    %edi,%esi
  80199d:	09 ce                	or     %ecx,%esi
  80199f:	09 d6                	or     %edx,%esi
  8019a1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8019a7:	75 0e                	jne    8019b7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8019a9:	83 ef 04             	sub    $0x4,%edi
  8019ac:	8d 72 fc             	lea    -0x4(%edx),%esi
  8019af:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8019b2:	fd                   	std    
  8019b3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019b5:	eb 09                	jmp    8019c0 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8019b7:	83 ef 01             	sub    $0x1,%edi
  8019ba:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8019bd:	fd                   	std    
  8019be:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8019c0:	fc                   	cld    
  8019c1:	eb 1a                	jmp    8019dd <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019c3:	89 c2                	mov    %eax,%edx
  8019c5:	09 ca                	or     %ecx,%edx
  8019c7:	09 f2                	or     %esi,%edx
  8019c9:	f6 c2 03             	test   $0x3,%dl
  8019cc:	75 0a                	jne    8019d8 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8019ce:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8019d1:	89 c7                	mov    %eax,%edi
  8019d3:	fc                   	cld    
  8019d4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019d6:	eb 05                	jmp    8019dd <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8019d8:	89 c7                	mov    %eax,%edi
  8019da:	fc                   	cld    
  8019db:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8019dd:	5e                   	pop    %esi
  8019de:	5f                   	pop    %edi
  8019df:	5d                   	pop    %ebp
  8019e0:	c3                   	ret    

008019e1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8019e1:	f3 0f 1e fb          	endbr32 
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8019eb:	ff 75 10             	pushl  0x10(%ebp)
  8019ee:	ff 75 0c             	pushl  0xc(%ebp)
  8019f1:	ff 75 08             	pushl  0x8(%ebp)
  8019f4:	e8 82 ff ff ff       	call   80197b <memmove>
}
  8019f9:	c9                   	leave  
  8019fa:	c3                   	ret    

008019fb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8019fb:	f3 0f 1e fb          	endbr32 
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	56                   	push   %esi
  801a03:	53                   	push   %ebx
  801a04:	8b 45 08             	mov    0x8(%ebp),%eax
  801a07:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a0a:	89 c6                	mov    %eax,%esi
  801a0c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a0f:	39 f0                	cmp    %esi,%eax
  801a11:	74 1c                	je     801a2f <memcmp+0x34>
		if (*s1 != *s2)
  801a13:	0f b6 08             	movzbl (%eax),%ecx
  801a16:	0f b6 1a             	movzbl (%edx),%ebx
  801a19:	38 d9                	cmp    %bl,%cl
  801a1b:	75 08                	jne    801a25 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801a1d:	83 c0 01             	add    $0x1,%eax
  801a20:	83 c2 01             	add    $0x1,%edx
  801a23:	eb ea                	jmp    801a0f <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801a25:	0f b6 c1             	movzbl %cl,%eax
  801a28:	0f b6 db             	movzbl %bl,%ebx
  801a2b:	29 d8                	sub    %ebx,%eax
  801a2d:	eb 05                	jmp    801a34 <memcmp+0x39>
	}

	return 0;
  801a2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a34:	5b                   	pop    %ebx
  801a35:	5e                   	pop    %esi
  801a36:	5d                   	pop    %ebp
  801a37:	c3                   	ret    

00801a38 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a38:	f3 0f 1e fb          	endbr32 
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a45:	89 c2                	mov    %eax,%edx
  801a47:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a4a:	39 d0                	cmp    %edx,%eax
  801a4c:	73 09                	jae    801a57 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a4e:	38 08                	cmp    %cl,(%eax)
  801a50:	74 05                	je     801a57 <memfind+0x1f>
	for (; s < ends; s++)
  801a52:	83 c0 01             	add    $0x1,%eax
  801a55:	eb f3                	jmp    801a4a <memfind+0x12>
			break;
	return (void *) s;
}
  801a57:	5d                   	pop    %ebp
  801a58:	c3                   	ret    

00801a59 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a59:	f3 0f 1e fb          	endbr32 
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	57                   	push   %edi
  801a61:	56                   	push   %esi
  801a62:	53                   	push   %ebx
  801a63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a66:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a69:	eb 03                	jmp    801a6e <strtol+0x15>
		s++;
  801a6b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801a6e:	0f b6 01             	movzbl (%ecx),%eax
  801a71:	3c 20                	cmp    $0x20,%al
  801a73:	74 f6                	je     801a6b <strtol+0x12>
  801a75:	3c 09                	cmp    $0x9,%al
  801a77:	74 f2                	je     801a6b <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801a79:	3c 2b                	cmp    $0x2b,%al
  801a7b:	74 2a                	je     801aa7 <strtol+0x4e>
	int neg = 0;
  801a7d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801a82:	3c 2d                	cmp    $0x2d,%al
  801a84:	74 2b                	je     801ab1 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a86:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a8c:	75 0f                	jne    801a9d <strtol+0x44>
  801a8e:	80 39 30             	cmpb   $0x30,(%ecx)
  801a91:	74 28                	je     801abb <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a93:	85 db                	test   %ebx,%ebx
  801a95:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a9a:	0f 44 d8             	cmove  %eax,%ebx
  801a9d:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801aa5:	eb 46                	jmp    801aed <strtol+0x94>
		s++;
  801aa7:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801aaa:	bf 00 00 00 00       	mov    $0x0,%edi
  801aaf:	eb d5                	jmp    801a86 <strtol+0x2d>
		s++, neg = 1;
  801ab1:	83 c1 01             	add    $0x1,%ecx
  801ab4:	bf 01 00 00 00       	mov    $0x1,%edi
  801ab9:	eb cb                	jmp    801a86 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801abb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801abf:	74 0e                	je     801acf <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801ac1:	85 db                	test   %ebx,%ebx
  801ac3:	75 d8                	jne    801a9d <strtol+0x44>
		s++, base = 8;
  801ac5:	83 c1 01             	add    $0x1,%ecx
  801ac8:	bb 08 00 00 00       	mov    $0x8,%ebx
  801acd:	eb ce                	jmp    801a9d <strtol+0x44>
		s += 2, base = 16;
  801acf:	83 c1 02             	add    $0x2,%ecx
  801ad2:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ad7:	eb c4                	jmp    801a9d <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801ad9:	0f be d2             	movsbl %dl,%edx
  801adc:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801adf:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ae2:	7d 3a                	jge    801b1e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801ae4:	83 c1 01             	add    $0x1,%ecx
  801ae7:	0f af 45 10          	imul   0x10(%ebp),%eax
  801aeb:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801aed:	0f b6 11             	movzbl (%ecx),%edx
  801af0:	8d 72 d0             	lea    -0x30(%edx),%esi
  801af3:	89 f3                	mov    %esi,%ebx
  801af5:	80 fb 09             	cmp    $0x9,%bl
  801af8:	76 df                	jbe    801ad9 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801afa:	8d 72 9f             	lea    -0x61(%edx),%esi
  801afd:	89 f3                	mov    %esi,%ebx
  801aff:	80 fb 19             	cmp    $0x19,%bl
  801b02:	77 08                	ja     801b0c <strtol+0xb3>
			dig = *s - 'a' + 10;
  801b04:	0f be d2             	movsbl %dl,%edx
  801b07:	83 ea 57             	sub    $0x57,%edx
  801b0a:	eb d3                	jmp    801adf <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801b0c:	8d 72 bf             	lea    -0x41(%edx),%esi
  801b0f:	89 f3                	mov    %esi,%ebx
  801b11:	80 fb 19             	cmp    $0x19,%bl
  801b14:	77 08                	ja     801b1e <strtol+0xc5>
			dig = *s - 'A' + 10;
  801b16:	0f be d2             	movsbl %dl,%edx
  801b19:	83 ea 37             	sub    $0x37,%edx
  801b1c:	eb c1                	jmp    801adf <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801b1e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b22:	74 05                	je     801b29 <strtol+0xd0>
		*endptr = (char *) s;
  801b24:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b27:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801b29:	89 c2                	mov    %eax,%edx
  801b2b:	f7 da                	neg    %edx
  801b2d:	85 ff                	test   %edi,%edi
  801b2f:	0f 45 c2             	cmovne %edx,%eax
}
  801b32:	5b                   	pop    %ebx
  801b33:	5e                   	pop    %esi
  801b34:	5f                   	pop    %edi
  801b35:	5d                   	pop    %ebp
  801b36:	c3                   	ret    

00801b37 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b37:	f3 0f 1e fb          	endbr32 
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
  801b3e:	56                   	push   %esi
  801b3f:	53                   	push   %ebx
  801b40:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b43:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b46:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b50:	0f 44 c2             	cmove  %edx,%eax
  801b53:	83 ec 0c             	sub    $0xc,%esp
  801b56:	50                   	push   %eax
  801b57:	e8 1b e8 ff ff       	call   800377 <sys_ipc_recv>
  801b5c:	83 c4 10             	add    $0x10,%esp
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	78 24                	js     801b87 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801b63:	85 f6                	test   %esi,%esi
  801b65:	74 0a                	je     801b71 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801b67:	a1 04 40 80 00       	mov    0x804004,%eax
  801b6c:	8b 40 78             	mov    0x78(%eax),%eax
  801b6f:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801b71:	85 db                	test   %ebx,%ebx
  801b73:	74 0a                	je     801b7f <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801b75:	a1 04 40 80 00       	mov    0x804004,%eax
  801b7a:	8b 40 74             	mov    0x74(%eax),%eax
  801b7d:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801b7f:	a1 04 40 80 00       	mov    0x804004,%eax
  801b84:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b8a:	5b                   	pop    %ebx
  801b8b:	5e                   	pop    %esi
  801b8c:	5d                   	pop    %ebp
  801b8d:	c3                   	ret    

00801b8e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b8e:	f3 0f 1e fb          	endbr32 
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	57                   	push   %edi
  801b96:	56                   	push   %esi
  801b97:	53                   	push   %ebx
  801b98:	83 ec 1c             	sub    $0x1c,%esp
  801b9b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b9e:	85 c0                	test   %eax,%eax
  801ba0:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801ba5:	0f 45 d0             	cmovne %eax,%edx
  801ba8:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801baa:	be 01 00 00 00       	mov    $0x1,%esi
  801baf:	eb 1f                	jmp    801bd0 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801bb1:	e8 d2 e5 ff ff       	call   800188 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801bb6:	83 c3 01             	add    $0x1,%ebx
  801bb9:	39 de                	cmp    %ebx,%esi
  801bbb:	7f f4                	jg     801bb1 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801bbd:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801bbf:	83 fe 11             	cmp    $0x11,%esi
  801bc2:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc7:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801bca:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801bce:	75 1c                	jne    801bec <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801bd0:	ff 75 14             	pushl  0x14(%ebp)
  801bd3:	57                   	push   %edi
  801bd4:	ff 75 0c             	pushl  0xc(%ebp)
  801bd7:	ff 75 08             	pushl  0x8(%ebp)
  801bda:	e8 71 e7 ff ff       	call   800350 <sys_ipc_try_send>
  801bdf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801be2:	83 c4 10             	add    $0x10,%esp
  801be5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bea:	eb cd                	jmp    801bb9 <ipc_send+0x2b>
}
  801bec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bef:	5b                   	pop    %ebx
  801bf0:	5e                   	pop    %esi
  801bf1:	5f                   	pop    %edi
  801bf2:	5d                   	pop    %ebp
  801bf3:	c3                   	ret    

00801bf4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bf4:	f3 0f 1e fb          	endbr32 
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bfe:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c03:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c06:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c0c:	8b 52 50             	mov    0x50(%edx),%edx
  801c0f:	39 ca                	cmp    %ecx,%edx
  801c11:	74 11                	je     801c24 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801c13:	83 c0 01             	add    $0x1,%eax
  801c16:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c1b:	75 e6                	jne    801c03 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801c1d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c22:	eb 0b                	jmp    801c2f <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c24:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c27:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c2c:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c2f:	5d                   	pop    %ebp
  801c30:	c3                   	ret    

00801c31 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c31:	f3 0f 1e fb          	endbr32 
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c3b:	89 c2                	mov    %eax,%edx
  801c3d:	c1 ea 16             	shr    $0x16,%edx
  801c40:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c47:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c4c:	f6 c1 01             	test   $0x1,%cl
  801c4f:	74 1c                	je     801c6d <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c51:	c1 e8 0c             	shr    $0xc,%eax
  801c54:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c5b:	a8 01                	test   $0x1,%al
  801c5d:	74 0e                	je     801c6d <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c5f:	c1 e8 0c             	shr    $0xc,%eax
  801c62:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c69:	ef 
  801c6a:	0f b7 d2             	movzwl %dx,%edx
}
  801c6d:	89 d0                	mov    %edx,%eax
  801c6f:	5d                   	pop    %ebp
  801c70:	c3                   	ret    
  801c71:	66 90                	xchg   %ax,%ax
  801c73:	66 90                	xchg   %ax,%ax
  801c75:	66 90                	xchg   %ax,%ax
  801c77:	66 90                	xchg   %ax,%ax
  801c79:	66 90                	xchg   %ax,%ax
  801c7b:	66 90                	xchg   %ax,%ax
  801c7d:	66 90                	xchg   %ax,%ax
  801c7f:	90                   	nop

00801c80 <__udivdi3>:
  801c80:	f3 0f 1e fb          	endbr32 
  801c84:	55                   	push   %ebp
  801c85:	57                   	push   %edi
  801c86:	56                   	push   %esi
  801c87:	53                   	push   %ebx
  801c88:	83 ec 1c             	sub    $0x1c,%esp
  801c8b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c8f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c93:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c97:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c9b:	85 d2                	test   %edx,%edx
  801c9d:	75 19                	jne    801cb8 <__udivdi3+0x38>
  801c9f:	39 f3                	cmp    %esi,%ebx
  801ca1:	76 4d                	jbe    801cf0 <__udivdi3+0x70>
  801ca3:	31 ff                	xor    %edi,%edi
  801ca5:	89 e8                	mov    %ebp,%eax
  801ca7:	89 f2                	mov    %esi,%edx
  801ca9:	f7 f3                	div    %ebx
  801cab:	89 fa                	mov    %edi,%edx
  801cad:	83 c4 1c             	add    $0x1c,%esp
  801cb0:	5b                   	pop    %ebx
  801cb1:	5e                   	pop    %esi
  801cb2:	5f                   	pop    %edi
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    
  801cb5:	8d 76 00             	lea    0x0(%esi),%esi
  801cb8:	39 f2                	cmp    %esi,%edx
  801cba:	76 14                	jbe    801cd0 <__udivdi3+0x50>
  801cbc:	31 ff                	xor    %edi,%edi
  801cbe:	31 c0                	xor    %eax,%eax
  801cc0:	89 fa                	mov    %edi,%edx
  801cc2:	83 c4 1c             	add    $0x1c,%esp
  801cc5:	5b                   	pop    %ebx
  801cc6:	5e                   	pop    %esi
  801cc7:	5f                   	pop    %edi
  801cc8:	5d                   	pop    %ebp
  801cc9:	c3                   	ret    
  801cca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cd0:	0f bd fa             	bsr    %edx,%edi
  801cd3:	83 f7 1f             	xor    $0x1f,%edi
  801cd6:	75 48                	jne    801d20 <__udivdi3+0xa0>
  801cd8:	39 f2                	cmp    %esi,%edx
  801cda:	72 06                	jb     801ce2 <__udivdi3+0x62>
  801cdc:	31 c0                	xor    %eax,%eax
  801cde:	39 eb                	cmp    %ebp,%ebx
  801ce0:	77 de                	ja     801cc0 <__udivdi3+0x40>
  801ce2:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce7:	eb d7                	jmp    801cc0 <__udivdi3+0x40>
  801ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	89 d9                	mov    %ebx,%ecx
  801cf2:	85 db                	test   %ebx,%ebx
  801cf4:	75 0b                	jne    801d01 <__udivdi3+0x81>
  801cf6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cfb:	31 d2                	xor    %edx,%edx
  801cfd:	f7 f3                	div    %ebx
  801cff:	89 c1                	mov    %eax,%ecx
  801d01:	31 d2                	xor    %edx,%edx
  801d03:	89 f0                	mov    %esi,%eax
  801d05:	f7 f1                	div    %ecx
  801d07:	89 c6                	mov    %eax,%esi
  801d09:	89 e8                	mov    %ebp,%eax
  801d0b:	89 f7                	mov    %esi,%edi
  801d0d:	f7 f1                	div    %ecx
  801d0f:	89 fa                	mov    %edi,%edx
  801d11:	83 c4 1c             	add    $0x1c,%esp
  801d14:	5b                   	pop    %ebx
  801d15:	5e                   	pop    %esi
  801d16:	5f                   	pop    %edi
  801d17:	5d                   	pop    %ebp
  801d18:	c3                   	ret    
  801d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d20:	89 f9                	mov    %edi,%ecx
  801d22:	b8 20 00 00 00       	mov    $0x20,%eax
  801d27:	29 f8                	sub    %edi,%eax
  801d29:	d3 e2                	shl    %cl,%edx
  801d2b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d2f:	89 c1                	mov    %eax,%ecx
  801d31:	89 da                	mov    %ebx,%edx
  801d33:	d3 ea                	shr    %cl,%edx
  801d35:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d39:	09 d1                	or     %edx,%ecx
  801d3b:	89 f2                	mov    %esi,%edx
  801d3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d41:	89 f9                	mov    %edi,%ecx
  801d43:	d3 e3                	shl    %cl,%ebx
  801d45:	89 c1                	mov    %eax,%ecx
  801d47:	d3 ea                	shr    %cl,%edx
  801d49:	89 f9                	mov    %edi,%ecx
  801d4b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d4f:	89 eb                	mov    %ebp,%ebx
  801d51:	d3 e6                	shl    %cl,%esi
  801d53:	89 c1                	mov    %eax,%ecx
  801d55:	d3 eb                	shr    %cl,%ebx
  801d57:	09 de                	or     %ebx,%esi
  801d59:	89 f0                	mov    %esi,%eax
  801d5b:	f7 74 24 08          	divl   0x8(%esp)
  801d5f:	89 d6                	mov    %edx,%esi
  801d61:	89 c3                	mov    %eax,%ebx
  801d63:	f7 64 24 0c          	mull   0xc(%esp)
  801d67:	39 d6                	cmp    %edx,%esi
  801d69:	72 15                	jb     801d80 <__udivdi3+0x100>
  801d6b:	89 f9                	mov    %edi,%ecx
  801d6d:	d3 e5                	shl    %cl,%ebp
  801d6f:	39 c5                	cmp    %eax,%ebp
  801d71:	73 04                	jae    801d77 <__udivdi3+0xf7>
  801d73:	39 d6                	cmp    %edx,%esi
  801d75:	74 09                	je     801d80 <__udivdi3+0x100>
  801d77:	89 d8                	mov    %ebx,%eax
  801d79:	31 ff                	xor    %edi,%edi
  801d7b:	e9 40 ff ff ff       	jmp    801cc0 <__udivdi3+0x40>
  801d80:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d83:	31 ff                	xor    %edi,%edi
  801d85:	e9 36 ff ff ff       	jmp    801cc0 <__udivdi3+0x40>
  801d8a:	66 90                	xchg   %ax,%ax
  801d8c:	66 90                	xchg   %ax,%ax
  801d8e:	66 90                	xchg   %ax,%ax

00801d90 <__umoddi3>:
  801d90:	f3 0f 1e fb          	endbr32 
  801d94:	55                   	push   %ebp
  801d95:	57                   	push   %edi
  801d96:	56                   	push   %esi
  801d97:	53                   	push   %ebx
  801d98:	83 ec 1c             	sub    $0x1c,%esp
  801d9b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d9f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801da3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801da7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dab:	85 c0                	test   %eax,%eax
  801dad:	75 19                	jne    801dc8 <__umoddi3+0x38>
  801daf:	39 df                	cmp    %ebx,%edi
  801db1:	76 5d                	jbe    801e10 <__umoddi3+0x80>
  801db3:	89 f0                	mov    %esi,%eax
  801db5:	89 da                	mov    %ebx,%edx
  801db7:	f7 f7                	div    %edi
  801db9:	89 d0                	mov    %edx,%eax
  801dbb:	31 d2                	xor    %edx,%edx
  801dbd:	83 c4 1c             	add    $0x1c,%esp
  801dc0:	5b                   	pop    %ebx
  801dc1:	5e                   	pop    %esi
  801dc2:	5f                   	pop    %edi
  801dc3:	5d                   	pop    %ebp
  801dc4:	c3                   	ret    
  801dc5:	8d 76 00             	lea    0x0(%esi),%esi
  801dc8:	89 f2                	mov    %esi,%edx
  801dca:	39 d8                	cmp    %ebx,%eax
  801dcc:	76 12                	jbe    801de0 <__umoddi3+0x50>
  801dce:	89 f0                	mov    %esi,%eax
  801dd0:	89 da                	mov    %ebx,%edx
  801dd2:	83 c4 1c             	add    $0x1c,%esp
  801dd5:	5b                   	pop    %ebx
  801dd6:	5e                   	pop    %esi
  801dd7:	5f                   	pop    %edi
  801dd8:	5d                   	pop    %ebp
  801dd9:	c3                   	ret    
  801dda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801de0:	0f bd e8             	bsr    %eax,%ebp
  801de3:	83 f5 1f             	xor    $0x1f,%ebp
  801de6:	75 50                	jne    801e38 <__umoddi3+0xa8>
  801de8:	39 d8                	cmp    %ebx,%eax
  801dea:	0f 82 e0 00 00 00    	jb     801ed0 <__umoddi3+0x140>
  801df0:	89 d9                	mov    %ebx,%ecx
  801df2:	39 f7                	cmp    %esi,%edi
  801df4:	0f 86 d6 00 00 00    	jbe    801ed0 <__umoddi3+0x140>
  801dfa:	89 d0                	mov    %edx,%eax
  801dfc:	89 ca                	mov    %ecx,%edx
  801dfe:	83 c4 1c             	add    $0x1c,%esp
  801e01:	5b                   	pop    %ebx
  801e02:	5e                   	pop    %esi
  801e03:	5f                   	pop    %edi
  801e04:	5d                   	pop    %ebp
  801e05:	c3                   	ret    
  801e06:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e0d:	8d 76 00             	lea    0x0(%esi),%esi
  801e10:	89 fd                	mov    %edi,%ebp
  801e12:	85 ff                	test   %edi,%edi
  801e14:	75 0b                	jne    801e21 <__umoddi3+0x91>
  801e16:	b8 01 00 00 00       	mov    $0x1,%eax
  801e1b:	31 d2                	xor    %edx,%edx
  801e1d:	f7 f7                	div    %edi
  801e1f:	89 c5                	mov    %eax,%ebp
  801e21:	89 d8                	mov    %ebx,%eax
  801e23:	31 d2                	xor    %edx,%edx
  801e25:	f7 f5                	div    %ebp
  801e27:	89 f0                	mov    %esi,%eax
  801e29:	f7 f5                	div    %ebp
  801e2b:	89 d0                	mov    %edx,%eax
  801e2d:	31 d2                	xor    %edx,%edx
  801e2f:	eb 8c                	jmp    801dbd <__umoddi3+0x2d>
  801e31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e38:	89 e9                	mov    %ebp,%ecx
  801e3a:	ba 20 00 00 00       	mov    $0x20,%edx
  801e3f:	29 ea                	sub    %ebp,%edx
  801e41:	d3 e0                	shl    %cl,%eax
  801e43:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e47:	89 d1                	mov    %edx,%ecx
  801e49:	89 f8                	mov    %edi,%eax
  801e4b:	d3 e8                	shr    %cl,%eax
  801e4d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e51:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e55:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e59:	09 c1                	or     %eax,%ecx
  801e5b:	89 d8                	mov    %ebx,%eax
  801e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e61:	89 e9                	mov    %ebp,%ecx
  801e63:	d3 e7                	shl    %cl,%edi
  801e65:	89 d1                	mov    %edx,%ecx
  801e67:	d3 e8                	shr    %cl,%eax
  801e69:	89 e9                	mov    %ebp,%ecx
  801e6b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e6f:	d3 e3                	shl    %cl,%ebx
  801e71:	89 c7                	mov    %eax,%edi
  801e73:	89 d1                	mov    %edx,%ecx
  801e75:	89 f0                	mov    %esi,%eax
  801e77:	d3 e8                	shr    %cl,%eax
  801e79:	89 e9                	mov    %ebp,%ecx
  801e7b:	89 fa                	mov    %edi,%edx
  801e7d:	d3 e6                	shl    %cl,%esi
  801e7f:	09 d8                	or     %ebx,%eax
  801e81:	f7 74 24 08          	divl   0x8(%esp)
  801e85:	89 d1                	mov    %edx,%ecx
  801e87:	89 f3                	mov    %esi,%ebx
  801e89:	f7 64 24 0c          	mull   0xc(%esp)
  801e8d:	89 c6                	mov    %eax,%esi
  801e8f:	89 d7                	mov    %edx,%edi
  801e91:	39 d1                	cmp    %edx,%ecx
  801e93:	72 06                	jb     801e9b <__umoddi3+0x10b>
  801e95:	75 10                	jne    801ea7 <__umoddi3+0x117>
  801e97:	39 c3                	cmp    %eax,%ebx
  801e99:	73 0c                	jae    801ea7 <__umoddi3+0x117>
  801e9b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801e9f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801ea3:	89 d7                	mov    %edx,%edi
  801ea5:	89 c6                	mov    %eax,%esi
  801ea7:	89 ca                	mov    %ecx,%edx
  801ea9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801eae:	29 f3                	sub    %esi,%ebx
  801eb0:	19 fa                	sbb    %edi,%edx
  801eb2:	89 d0                	mov    %edx,%eax
  801eb4:	d3 e0                	shl    %cl,%eax
  801eb6:	89 e9                	mov    %ebp,%ecx
  801eb8:	d3 eb                	shr    %cl,%ebx
  801eba:	d3 ea                	shr    %cl,%edx
  801ebc:	09 d8                	or     %ebx,%eax
  801ebe:	83 c4 1c             	add    $0x1c,%esp
  801ec1:	5b                   	pop    %ebx
  801ec2:	5e                   	pop    %esi
  801ec3:	5f                   	pop    %edi
  801ec4:	5d                   	pop    %ebp
  801ec5:	c3                   	ret    
  801ec6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ecd:	8d 76 00             	lea    0x0(%esi),%esi
  801ed0:	29 fe                	sub    %edi,%esi
  801ed2:	19 c3                	sbb    %eax,%ebx
  801ed4:	89 f2                	mov    %esi,%edx
  801ed6:	89 d9                	mov    %ebx,%ecx
  801ed8:	e9 1d ff ff ff       	jmp    801dfa <__umoddi3+0x6a>
