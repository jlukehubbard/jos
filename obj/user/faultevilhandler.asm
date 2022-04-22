
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
  800154:	68 0a 1f 80 00       	push   $0x801f0a
  800159:	6a 23                	push   $0x23
  80015b:	68 27 1f 80 00       	push   $0x801f27
  800160:	e8 9c 0f 00 00       	call   801101 <_panic>

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
  8001e1:	68 0a 1f 80 00       	push   $0x801f0a
  8001e6:	6a 23                	push   $0x23
  8001e8:	68 27 1f 80 00       	push   $0x801f27
  8001ed:	e8 0f 0f 00 00       	call   801101 <_panic>

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
  800227:	68 0a 1f 80 00       	push   $0x801f0a
  80022c:	6a 23                	push   $0x23
  80022e:	68 27 1f 80 00       	push   $0x801f27
  800233:	e8 c9 0e 00 00       	call   801101 <_panic>

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
  80026d:	68 0a 1f 80 00       	push   $0x801f0a
  800272:	6a 23                	push   $0x23
  800274:	68 27 1f 80 00       	push   $0x801f27
  800279:	e8 83 0e 00 00       	call   801101 <_panic>

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
  8002b3:	68 0a 1f 80 00       	push   $0x801f0a
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 27 1f 80 00       	push   $0x801f27
  8002bf:	e8 3d 0e 00 00       	call   801101 <_panic>

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
  8002f9:	68 0a 1f 80 00       	push   $0x801f0a
  8002fe:	6a 23                	push   $0x23
  800300:	68 27 1f 80 00       	push   $0x801f27
  800305:	e8 f7 0d 00 00       	call   801101 <_panic>

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
  80033f:	68 0a 1f 80 00       	push   $0x801f0a
  800344:	6a 23                	push   $0x23
  800346:	68 27 1f 80 00       	push   $0x801f27
  80034b:	e8 b1 0d 00 00       	call   801101 <_panic>

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
  8003ab:	68 0a 1f 80 00       	push   $0x801f0a
  8003b0:	6a 23                	push   $0x23
  8003b2:	68 27 1f 80 00       	push   $0x801f27
  8003b7:	e8 45 0d 00 00       	call   801101 <_panic>

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
  8004a2:	ba b4 1f 80 00       	mov    $0x801fb4,%edx
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
  8004c6:	68 38 1f 80 00       	push   $0x801f38
  8004cb:	e8 18 0d 00 00       	call   8011e8 <cprintf>
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
  800734:	68 79 1f 80 00       	push   $0x801f79
  800739:	e8 aa 0a 00 00       	call   8011e8 <cprintf>
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
  800805:	68 95 1f 80 00       	push   $0x801f95
  80080a:	e8 d9 09 00 00       	call   8011e8 <cprintf>
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
  8008b5:	68 58 1f 80 00       	push   $0x801f58
  8008ba:	e8 29 09 00 00       	call   8011e8 <cprintf>
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
  800959:	e8 fb 01 00 00       	call   800b59 <open>
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
  8009ab:	e8 0a 12 00 00       	call   801bba <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009b0:	83 c4 0c             	add    $0xc,%esp
  8009b3:	6a 00                	push   $0x0
  8009b5:	53                   	push   %ebx
  8009b6:	6a 00                	push   $0x0
  8009b8:	e8 a6 11 00 00       	call   801b63 <ipc_recv>
}
  8009bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009c0:	5b                   	pop    %ebx
  8009c1:	5e                   	pop    %esi
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009c4:	83 ec 0c             	sub    $0xc,%esp
  8009c7:	6a 01                	push   $0x1
  8009c9:	e8 52 12 00 00       	call   801c20 <ipc_find_env>
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
  800a61:	e8 8b 0d 00 00       	call   8017f1 <strcpy>
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
  800a93:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  800a96:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a9b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800aa0:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800aa3:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa6:	8b 52 0c             	mov    0xc(%edx),%edx
  800aa9:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800aaf:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800ab4:	50                   	push   %eax
  800ab5:	ff 75 0c             	pushl  0xc(%ebp)
  800ab8:	68 08 50 80 00       	push   $0x805008
  800abd:	e8 e5 0e 00 00       	call   8019a7 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800ac2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac7:	b8 04 00 00 00       	mov    $0x4,%eax
  800acc:	e8 ba fe ff ff       	call   80098b <fsipc>
}
  800ad1:	c9                   	leave  
  800ad2:	c3                   	ret    

00800ad3 <devfile_read>:
{
  800ad3:	f3 0f 1e fb          	endbr32 
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
  800adc:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800adf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae2:	8b 40 0c             	mov    0xc(%eax),%eax
  800ae5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800aea:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800af0:	ba 00 00 00 00       	mov    $0x0,%edx
  800af5:	b8 03 00 00 00       	mov    $0x3,%eax
  800afa:	e8 8c fe ff ff       	call   80098b <fsipc>
  800aff:	89 c3                	mov    %eax,%ebx
  800b01:	85 c0                	test   %eax,%eax
  800b03:	78 1f                	js     800b24 <devfile_read+0x51>
	assert(r <= n);
  800b05:	39 f0                	cmp    %esi,%eax
  800b07:	77 24                	ja     800b2d <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800b09:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b0e:	7f 33                	jg     800b43 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b10:	83 ec 04             	sub    $0x4,%esp
  800b13:	50                   	push   %eax
  800b14:	68 00 50 80 00       	push   $0x805000
  800b19:	ff 75 0c             	pushl  0xc(%ebp)
  800b1c:	e8 86 0e 00 00       	call   8019a7 <memmove>
	return r;
  800b21:	83 c4 10             	add    $0x10,%esp
}
  800b24:	89 d8                	mov    %ebx,%eax
  800b26:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b29:	5b                   	pop    %ebx
  800b2a:	5e                   	pop    %esi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    
	assert(r <= n);
  800b2d:	68 c4 1f 80 00       	push   $0x801fc4
  800b32:	68 cb 1f 80 00       	push   $0x801fcb
  800b37:	6a 7c                	push   $0x7c
  800b39:	68 e0 1f 80 00       	push   $0x801fe0
  800b3e:	e8 be 05 00 00       	call   801101 <_panic>
	assert(r <= PGSIZE);
  800b43:	68 eb 1f 80 00       	push   $0x801feb
  800b48:	68 cb 1f 80 00       	push   $0x801fcb
  800b4d:	6a 7d                	push   $0x7d
  800b4f:	68 e0 1f 80 00       	push   $0x801fe0
  800b54:	e8 a8 05 00 00       	call   801101 <_panic>

00800b59 <open>:
{
  800b59:	f3 0f 1e fb          	endbr32 
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	83 ec 1c             	sub    $0x1c,%esp
  800b65:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b68:	56                   	push   %esi
  800b69:	e8 40 0c 00 00       	call   8017ae <strlen>
  800b6e:	83 c4 10             	add    $0x10,%esp
  800b71:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b76:	7f 6c                	jg     800be4 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800b78:	83 ec 0c             	sub    $0xc,%esp
  800b7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b7e:	50                   	push   %eax
  800b7f:	e8 67 f8 ff ff       	call   8003eb <fd_alloc>
  800b84:	89 c3                	mov    %eax,%ebx
  800b86:	83 c4 10             	add    $0x10,%esp
  800b89:	85 c0                	test   %eax,%eax
  800b8b:	78 3c                	js     800bc9 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b8d:	83 ec 08             	sub    $0x8,%esp
  800b90:	56                   	push   %esi
  800b91:	68 00 50 80 00       	push   $0x805000
  800b96:	e8 56 0c 00 00       	call   8017f1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ba3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ba6:	b8 01 00 00 00       	mov    $0x1,%eax
  800bab:	e8 db fd ff ff       	call   80098b <fsipc>
  800bb0:	89 c3                	mov    %eax,%ebx
  800bb2:	83 c4 10             	add    $0x10,%esp
  800bb5:	85 c0                	test   %eax,%eax
  800bb7:	78 19                	js     800bd2 <open+0x79>
	return fd2num(fd);
  800bb9:	83 ec 0c             	sub    $0xc,%esp
  800bbc:	ff 75 f4             	pushl  -0xc(%ebp)
  800bbf:	e8 f8 f7 ff ff       	call   8003bc <fd2num>
  800bc4:	89 c3                	mov    %eax,%ebx
  800bc6:	83 c4 10             	add    $0x10,%esp
}
  800bc9:	89 d8                	mov    %ebx,%eax
  800bcb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    
		fd_close(fd, 0);
  800bd2:	83 ec 08             	sub    $0x8,%esp
  800bd5:	6a 00                	push   $0x0
  800bd7:	ff 75 f4             	pushl  -0xc(%ebp)
  800bda:	e8 10 f9 ff ff       	call   8004ef <fd_close>
		return r;
  800bdf:	83 c4 10             	add    $0x10,%esp
  800be2:	eb e5                	jmp    800bc9 <open+0x70>
		return -E_BAD_PATH;
  800be4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800be9:	eb de                	jmp    800bc9 <open+0x70>

00800beb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800beb:	f3 0f 1e fb          	endbr32 
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bf5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfa:	b8 08 00 00 00       	mov    $0x8,%eax
  800bff:	e8 87 fd ff ff       	call   80098b <fsipc>
}
  800c04:	c9                   	leave  
  800c05:	c3                   	ret    

00800c06 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c06:	f3 0f 1e fb          	endbr32 
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
  800c0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800c12:	83 ec 0c             	sub    $0xc,%esp
  800c15:	ff 75 08             	pushl  0x8(%ebp)
  800c18:	e8 b3 f7 ff ff       	call   8003d0 <fd2data>
  800c1d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800c1f:	83 c4 08             	add    $0x8,%esp
  800c22:	68 f7 1f 80 00       	push   $0x801ff7
  800c27:	53                   	push   %ebx
  800c28:	e8 c4 0b 00 00       	call   8017f1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800c2d:	8b 46 04             	mov    0x4(%esi),%eax
  800c30:	2b 06                	sub    (%esi),%eax
  800c32:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800c38:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c3f:	00 00 00 
	stat->st_dev = &devpipe;
  800c42:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c49:	30 80 00 
	return 0;
}
  800c4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c58:	f3 0f 1e fb          	endbr32 
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	53                   	push   %ebx
  800c60:	83 ec 0c             	sub    $0xc,%esp
  800c63:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c66:	53                   	push   %ebx
  800c67:	6a 00                	push   $0x0
  800c69:	e8 ca f5 ff ff       	call   800238 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c6e:	89 1c 24             	mov    %ebx,(%esp)
  800c71:	e8 5a f7 ff ff       	call   8003d0 <fd2data>
  800c76:	83 c4 08             	add    $0x8,%esp
  800c79:	50                   	push   %eax
  800c7a:	6a 00                	push   $0x0
  800c7c:	e8 b7 f5 ff ff       	call   800238 <sys_page_unmap>
}
  800c81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c84:	c9                   	leave  
  800c85:	c3                   	ret    

00800c86 <_pipeisclosed>:
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	83 ec 1c             	sub    $0x1c,%esp
  800c8f:	89 c7                	mov    %eax,%edi
  800c91:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c93:	a1 04 40 80 00       	mov    0x804004,%eax
  800c98:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c9b:	83 ec 0c             	sub    $0xc,%esp
  800c9e:	57                   	push   %edi
  800c9f:	e8 b9 0f 00 00       	call   801c5d <pageref>
  800ca4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ca7:	89 34 24             	mov    %esi,(%esp)
  800caa:	e8 ae 0f 00 00       	call   801c5d <pageref>
		nn = thisenv->env_runs;
  800caf:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800cb5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800cb8:	83 c4 10             	add    $0x10,%esp
  800cbb:	39 cb                	cmp    %ecx,%ebx
  800cbd:	74 1b                	je     800cda <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800cbf:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800cc2:	75 cf                	jne    800c93 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800cc4:	8b 42 58             	mov    0x58(%edx),%eax
  800cc7:	6a 01                	push   $0x1
  800cc9:	50                   	push   %eax
  800cca:	53                   	push   %ebx
  800ccb:	68 fe 1f 80 00       	push   $0x801ffe
  800cd0:	e8 13 05 00 00       	call   8011e8 <cprintf>
  800cd5:	83 c4 10             	add    $0x10,%esp
  800cd8:	eb b9                	jmp    800c93 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800cda:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800cdd:	0f 94 c0             	sete   %al
  800ce0:	0f b6 c0             	movzbl %al,%eax
}
  800ce3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce6:	5b                   	pop    %ebx
  800ce7:	5e                   	pop    %esi
  800ce8:	5f                   	pop    %edi
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <devpipe_write>:
{
  800ceb:	f3 0f 1e fb          	endbr32 
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
  800cf5:	83 ec 28             	sub    $0x28,%esp
  800cf8:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800cfb:	56                   	push   %esi
  800cfc:	e8 cf f6 ff ff       	call   8003d0 <fd2data>
  800d01:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d03:	83 c4 10             	add    $0x10,%esp
  800d06:	bf 00 00 00 00       	mov    $0x0,%edi
  800d0b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d0e:	74 4f                	je     800d5f <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d10:	8b 43 04             	mov    0x4(%ebx),%eax
  800d13:	8b 0b                	mov    (%ebx),%ecx
  800d15:	8d 51 20             	lea    0x20(%ecx),%edx
  800d18:	39 d0                	cmp    %edx,%eax
  800d1a:	72 14                	jb     800d30 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800d1c:	89 da                	mov    %ebx,%edx
  800d1e:	89 f0                	mov    %esi,%eax
  800d20:	e8 61 ff ff ff       	call   800c86 <_pipeisclosed>
  800d25:	85 c0                	test   %eax,%eax
  800d27:	75 3b                	jne    800d64 <devpipe_write+0x79>
			sys_yield();
  800d29:	e8 5a f4 ff ff       	call   800188 <sys_yield>
  800d2e:	eb e0                	jmp    800d10 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d37:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d3a:	89 c2                	mov    %eax,%edx
  800d3c:	c1 fa 1f             	sar    $0x1f,%edx
  800d3f:	89 d1                	mov    %edx,%ecx
  800d41:	c1 e9 1b             	shr    $0x1b,%ecx
  800d44:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800d47:	83 e2 1f             	and    $0x1f,%edx
  800d4a:	29 ca                	sub    %ecx,%edx
  800d4c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800d50:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d54:	83 c0 01             	add    $0x1,%eax
  800d57:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800d5a:	83 c7 01             	add    $0x1,%edi
  800d5d:	eb ac                	jmp    800d0b <devpipe_write+0x20>
	return i;
  800d5f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d62:	eb 05                	jmp    800d69 <devpipe_write+0x7e>
				return 0;
  800d64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6c:	5b                   	pop    %ebx
  800d6d:	5e                   	pop    %esi
  800d6e:	5f                   	pop    %edi
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    

00800d71 <devpipe_read>:
{
  800d71:	f3 0f 1e fb          	endbr32 
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	57                   	push   %edi
  800d79:	56                   	push   %esi
  800d7a:	53                   	push   %ebx
  800d7b:	83 ec 18             	sub    $0x18,%esp
  800d7e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800d81:	57                   	push   %edi
  800d82:	e8 49 f6 ff ff       	call   8003d0 <fd2data>
  800d87:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d89:	83 c4 10             	add    $0x10,%esp
  800d8c:	be 00 00 00 00       	mov    $0x0,%esi
  800d91:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d94:	75 14                	jne    800daa <devpipe_read+0x39>
	return i;
  800d96:	8b 45 10             	mov    0x10(%ebp),%eax
  800d99:	eb 02                	jmp    800d9d <devpipe_read+0x2c>
				return i;
  800d9b:	89 f0                	mov    %esi,%eax
}
  800d9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    
			sys_yield();
  800da5:	e8 de f3 ff ff       	call   800188 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800daa:	8b 03                	mov    (%ebx),%eax
  800dac:	3b 43 04             	cmp    0x4(%ebx),%eax
  800daf:	75 18                	jne    800dc9 <devpipe_read+0x58>
			if (i > 0)
  800db1:	85 f6                	test   %esi,%esi
  800db3:	75 e6                	jne    800d9b <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800db5:	89 da                	mov    %ebx,%edx
  800db7:	89 f8                	mov    %edi,%eax
  800db9:	e8 c8 fe ff ff       	call   800c86 <_pipeisclosed>
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	74 e3                	je     800da5 <devpipe_read+0x34>
				return 0;
  800dc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc7:	eb d4                	jmp    800d9d <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800dc9:	99                   	cltd   
  800dca:	c1 ea 1b             	shr    $0x1b,%edx
  800dcd:	01 d0                	add    %edx,%eax
  800dcf:	83 e0 1f             	and    $0x1f,%eax
  800dd2:	29 d0                	sub    %edx,%eax
  800dd4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800dd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddc:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800ddf:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800de2:	83 c6 01             	add    $0x1,%esi
  800de5:	eb aa                	jmp    800d91 <devpipe_read+0x20>

00800de7 <pipe>:
{
  800de7:	f3 0f 1e fb          	endbr32 
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	56                   	push   %esi
  800def:	53                   	push   %ebx
  800df0:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800df3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800df6:	50                   	push   %eax
  800df7:	e8 ef f5 ff ff       	call   8003eb <fd_alloc>
  800dfc:	89 c3                	mov    %eax,%ebx
  800dfe:	83 c4 10             	add    $0x10,%esp
  800e01:	85 c0                	test   %eax,%eax
  800e03:	0f 88 23 01 00 00    	js     800f2c <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e09:	83 ec 04             	sub    $0x4,%esp
  800e0c:	68 07 04 00 00       	push   $0x407
  800e11:	ff 75 f4             	pushl  -0xc(%ebp)
  800e14:	6a 00                	push   $0x0
  800e16:	e8 90 f3 ff ff       	call   8001ab <sys_page_alloc>
  800e1b:	89 c3                	mov    %eax,%ebx
  800e1d:	83 c4 10             	add    $0x10,%esp
  800e20:	85 c0                	test   %eax,%eax
  800e22:	0f 88 04 01 00 00    	js     800f2c <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800e28:	83 ec 0c             	sub    $0xc,%esp
  800e2b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e2e:	50                   	push   %eax
  800e2f:	e8 b7 f5 ff ff       	call   8003eb <fd_alloc>
  800e34:	89 c3                	mov    %eax,%ebx
  800e36:	83 c4 10             	add    $0x10,%esp
  800e39:	85 c0                	test   %eax,%eax
  800e3b:	0f 88 db 00 00 00    	js     800f1c <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e41:	83 ec 04             	sub    $0x4,%esp
  800e44:	68 07 04 00 00       	push   $0x407
  800e49:	ff 75 f0             	pushl  -0x10(%ebp)
  800e4c:	6a 00                	push   $0x0
  800e4e:	e8 58 f3 ff ff       	call   8001ab <sys_page_alloc>
  800e53:	89 c3                	mov    %eax,%ebx
  800e55:	83 c4 10             	add    $0x10,%esp
  800e58:	85 c0                	test   %eax,%eax
  800e5a:	0f 88 bc 00 00 00    	js     800f1c <pipe+0x135>
	va = fd2data(fd0);
  800e60:	83 ec 0c             	sub    $0xc,%esp
  800e63:	ff 75 f4             	pushl  -0xc(%ebp)
  800e66:	e8 65 f5 ff ff       	call   8003d0 <fd2data>
  800e6b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e6d:	83 c4 0c             	add    $0xc,%esp
  800e70:	68 07 04 00 00       	push   $0x407
  800e75:	50                   	push   %eax
  800e76:	6a 00                	push   $0x0
  800e78:	e8 2e f3 ff ff       	call   8001ab <sys_page_alloc>
  800e7d:	89 c3                	mov    %eax,%ebx
  800e7f:	83 c4 10             	add    $0x10,%esp
  800e82:	85 c0                	test   %eax,%eax
  800e84:	0f 88 82 00 00 00    	js     800f0c <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e8a:	83 ec 0c             	sub    $0xc,%esp
  800e8d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e90:	e8 3b f5 ff ff       	call   8003d0 <fd2data>
  800e95:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e9c:	50                   	push   %eax
  800e9d:	6a 00                	push   $0x0
  800e9f:	56                   	push   %esi
  800ea0:	6a 00                	push   $0x0
  800ea2:	e8 4b f3 ff ff       	call   8001f2 <sys_page_map>
  800ea7:	89 c3                	mov    %eax,%ebx
  800ea9:	83 c4 20             	add    $0x20,%esp
  800eac:	85 c0                	test   %eax,%eax
  800eae:	78 4e                	js     800efe <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800eb0:	a1 20 30 80 00       	mov    0x803020,%eax
  800eb5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800eb8:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800eba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ebd:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800ec4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ec7:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800ec9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ecc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800ed3:	83 ec 0c             	sub    $0xc,%esp
  800ed6:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed9:	e8 de f4 ff ff       	call   8003bc <fd2num>
  800ede:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800ee3:	83 c4 04             	add    $0x4,%esp
  800ee6:	ff 75 f0             	pushl  -0x10(%ebp)
  800ee9:	e8 ce f4 ff ff       	call   8003bc <fd2num>
  800eee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800ef4:	83 c4 10             	add    $0x10,%esp
  800ef7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efc:	eb 2e                	jmp    800f2c <pipe+0x145>
	sys_page_unmap(0, va);
  800efe:	83 ec 08             	sub    $0x8,%esp
  800f01:	56                   	push   %esi
  800f02:	6a 00                	push   $0x0
  800f04:	e8 2f f3 ff ff       	call   800238 <sys_page_unmap>
  800f09:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800f0c:	83 ec 08             	sub    $0x8,%esp
  800f0f:	ff 75 f0             	pushl  -0x10(%ebp)
  800f12:	6a 00                	push   $0x0
  800f14:	e8 1f f3 ff ff       	call   800238 <sys_page_unmap>
  800f19:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800f1c:	83 ec 08             	sub    $0x8,%esp
  800f1f:	ff 75 f4             	pushl  -0xc(%ebp)
  800f22:	6a 00                	push   $0x0
  800f24:	e8 0f f3 ff ff       	call   800238 <sys_page_unmap>
  800f29:	83 c4 10             	add    $0x10,%esp
}
  800f2c:	89 d8                	mov    %ebx,%eax
  800f2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f31:	5b                   	pop    %ebx
  800f32:	5e                   	pop    %esi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <pipeisclosed>:
{
  800f35:	f3 0f 1e fb          	endbr32 
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f42:	50                   	push   %eax
  800f43:	ff 75 08             	pushl  0x8(%ebp)
  800f46:	e8 f6 f4 ff ff       	call   800441 <fd_lookup>
  800f4b:	83 c4 10             	add    $0x10,%esp
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	78 18                	js     800f6a <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800f52:	83 ec 0c             	sub    $0xc,%esp
  800f55:	ff 75 f4             	pushl  -0xc(%ebp)
  800f58:	e8 73 f4 ff ff       	call   8003d0 <fd2data>
  800f5d:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f62:	e8 1f fd ff ff       	call   800c86 <_pipeisclosed>
  800f67:	83 c4 10             	add    $0x10,%esp
}
  800f6a:	c9                   	leave  
  800f6b:	c3                   	ret    

00800f6c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f6c:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800f70:	b8 00 00 00 00       	mov    $0x0,%eax
  800f75:	c3                   	ret    

00800f76 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f76:	f3 0f 1e fb          	endbr32 
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f80:	68 16 20 80 00       	push   $0x802016
  800f85:	ff 75 0c             	pushl  0xc(%ebp)
  800f88:	e8 64 08 00 00       	call   8017f1 <strcpy>
	return 0;
}
  800f8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f92:	c9                   	leave  
  800f93:	c3                   	ret    

00800f94 <devcons_write>:
{
  800f94:	f3 0f 1e fb          	endbr32 
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	57                   	push   %edi
  800f9c:	56                   	push   %esi
  800f9d:	53                   	push   %ebx
  800f9e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800fa4:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800fa9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800faf:	3b 75 10             	cmp    0x10(%ebp),%esi
  800fb2:	73 31                	jae    800fe5 <devcons_write+0x51>
		m = n - tot;
  800fb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fb7:	29 f3                	sub    %esi,%ebx
  800fb9:	83 fb 7f             	cmp    $0x7f,%ebx
  800fbc:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800fc1:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800fc4:	83 ec 04             	sub    $0x4,%esp
  800fc7:	53                   	push   %ebx
  800fc8:	89 f0                	mov    %esi,%eax
  800fca:	03 45 0c             	add    0xc(%ebp),%eax
  800fcd:	50                   	push   %eax
  800fce:	57                   	push   %edi
  800fcf:	e8 d3 09 00 00       	call   8019a7 <memmove>
		sys_cputs(buf, m);
  800fd4:	83 c4 08             	add    $0x8,%esp
  800fd7:	53                   	push   %ebx
  800fd8:	57                   	push   %edi
  800fd9:	e8 fd f0 ff ff       	call   8000db <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800fde:	01 de                	add    %ebx,%esi
  800fe0:	83 c4 10             	add    $0x10,%esp
  800fe3:	eb ca                	jmp    800faf <devcons_write+0x1b>
}
  800fe5:	89 f0                	mov    %esi,%eax
  800fe7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fea:	5b                   	pop    %ebx
  800feb:	5e                   	pop    %esi
  800fec:	5f                   	pop    %edi
  800fed:	5d                   	pop    %ebp
  800fee:	c3                   	ret    

00800fef <devcons_read>:
{
  800fef:	f3 0f 1e fb          	endbr32 
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	83 ec 08             	sub    $0x8,%esp
  800ff9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800ffe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801002:	74 21                	je     801025 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801004:	e8 f4 f0 ff ff       	call   8000fd <sys_cgetc>
  801009:	85 c0                	test   %eax,%eax
  80100b:	75 07                	jne    801014 <devcons_read+0x25>
		sys_yield();
  80100d:	e8 76 f1 ff ff       	call   800188 <sys_yield>
  801012:	eb f0                	jmp    801004 <devcons_read+0x15>
	if (c < 0)
  801014:	78 0f                	js     801025 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801016:	83 f8 04             	cmp    $0x4,%eax
  801019:	74 0c                	je     801027 <devcons_read+0x38>
	*(char*)vbuf = c;
  80101b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80101e:	88 02                	mov    %al,(%edx)
	return 1;
  801020:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801025:	c9                   	leave  
  801026:	c3                   	ret    
		return 0;
  801027:	b8 00 00 00 00       	mov    $0x0,%eax
  80102c:	eb f7                	jmp    801025 <devcons_read+0x36>

0080102e <cputchar>:
{
  80102e:	f3 0f 1e fb          	endbr32 
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801038:	8b 45 08             	mov    0x8(%ebp),%eax
  80103b:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80103e:	6a 01                	push   $0x1
  801040:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801043:	50                   	push   %eax
  801044:	e8 92 f0 ff ff       	call   8000db <sys_cputs>
}
  801049:	83 c4 10             	add    $0x10,%esp
  80104c:	c9                   	leave  
  80104d:	c3                   	ret    

0080104e <getchar>:
{
  80104e:	f3 0f 1e fb          	endbr32 
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801058:	6a 01                	push   $0x1
  80105a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80105d:	50                   	push   %eax
  80105e:	6a 00                	push   $0x0
  801060:	e8 5f f6 ff ff       	call   8006c4 <read>
	if (r < 0)
  801065:	83 c4 10             	add    $0x10,%esp
  801068:	85 c0                	test   %eax,%eax
  80106a:	78 06                	js     801072 <getchar+0x24>
	if (r < 1)
  80106c:	74 06                	je     801074 <getchar+0x26>
	return c;
  80106e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801072:	c9                   	leave  
  801073:	c3                   	ret    
		return -E_EOF;
  801074:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801079:	eb f7                	jmp    801072 <getchar+0x24>

0080107b <iscons>:
{
  80107b:	f3 0f 1e fb          	endbr32 
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801085:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801088:	50                   	push   %eax
  801089:	ff 75 08             	pushl  0x8(%ebp)
  80108c:	e8 b0 f3 ff ff       	call   800441 <fd_lookup>
  801091:	83 c4 10             	add    $0x10,%esp
  801094:	85 c0                	test   %eax,%eax
  801096:	78 11                	js     8010a9 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801098:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80109b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8010a1:	39 10                	cmp    %edx,(%eax)
  8010a3:	0f 94 c0             	sete   %al
  8010a6:	0f b6 c0             	movzbl %al,%eax
}
  8010a9:	c9                   	leave  
  8010aa:	c3                   	ret    

008010ab <opencons>:
{
  8010ab:	f3 0f 1e fb          	endbr32 
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8010b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b8:	50                   	push   %eax
  8010b9:	e8 2d f3 ff ff       	call   8003eb <fd_alloc>
  8010be:	83 c4 10             	add    $0x10,%esp
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	78 3a                	js     8010ff <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8010c5:	83 ec 04             	sub    $0x4,%esp
  8010c8:	68 07 04 00 00       	push   $0x407
  8010cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8010d0:	6a 00                	push   $0x0
  8010d2:	e8 d4 f0 ff ff       	call   8001ab <sys_page_alloc>
  8010d7:	83 c4 10             	add    $0x10,%esp
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	78 21                	js     8010ff <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8010de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010e1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8010e7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8010e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ec:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8010f3:	83 ec 0c             	sub    $0xc,%esp
  8010f6:	50                   	push   %eax
  8010f7:	e8 c0 f2 ff ff       	call   8003bc <fd2num>
  8010fc:	83 c4 10             	add    $0x10,%esp
}
  8010ff:	c9                   	leave  
  801100:	c3                   	ret    

00801101 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801101:	f3 0f 1e fb          	endbr32 
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	56                   	push   %esi
  801109:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80110a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80110d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801113:	e8 4d f0 ff ff       	call   800165 <sys_getenvid>
  801118:	83 ec 0c             	sub    $0xc,%esp
  80111b:	ff 75 0c             	pushl  0xc(%ebp)
  80111e:	ff 75 08             	pushl  0x8(%ebp)
  801121:	56                   	push   %esi
  801122:	50                   	push   %eax
  801123:	68 24 20 80 00       	push   $0x802024
  801128:	e8 bb 00 00 00       	call   8011e8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80112d:	83 c4 18             	add    $0x18,%esp
  801130:	53                   	push   %ebx
  801131:	ff 75 10             	pushl  0x10(%ebp)
  801134:	e8 5a 00 00 00       	call   801193 <vcprintf>
	cprintf("\n");
  801139:	c7 04 24 0f 20 80 00 	movl   $0x80200f,(%esp)
  801140:	e8 a3 00 00 00       	call   8011e8 <cprintf>
  801145:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801148:	cc                   	int3   
  801149:	eb fd                	jmp    801148 <_panic+0x47>

0080114b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80114b:	f3 0f 1e fb          	endbr32 
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	53                   	push   %ebx
  801153:	83 ec 04             	sub    $0x4,%esp
  801156:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801159:	8b 13                	mov    (%ebx),%edx
  80115b:	8d 42 01             	lea    0x1(%edx),%eax
  80115e:	89 03                	mov    %eax,(%ebx)
  801160:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801163:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801167:	3d ff 00 00 00       	cmp    $0xff,%eax
  80116c:	74 09                	je     801177 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80116e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801172:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801175:	c9                   	leave  
  801176:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801177:	83 ec 08             	sub    $0x8,%esp
  80117a:	68 ff 00 00 00       	push   $0xff
  80117f:	8d 43 08             	lea    0x8(%ebx),%eax
  801182:	50                   	push   %eax
  801183:	e8 53 ef ff ff       	call   8000db <sys_cputs>
		b->idx = 0;
  801188:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80118e:	83 c4 10             	add    $0x10,%esp
  801191:	eb db                	jmp    80116e <putch+0x23>

00801193 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801193:	f3 0f 1e fb          	endbr32 
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8011a0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8011a7:	00 00 00 
	b.cnt = 0;
  8011aa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8011b1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8011b4:	ff 75 0c             	pushl  0xc(%ebp)
  8011b7:	ff 75 08             	pushl  0x8(%ebp)
  8011ba:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8011c0:	50                   	push   %eax
  8011c1:	68 4b 11 80 00       	push   $0x80114b
  8011c6:	e8 20 01 00 00       	call   8012eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8011cb:	83 c4 08             	add    $0x8,%esp
  8011ce:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8011d4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8011da:	50                   	push   %eax
  8011db:	e8 fb ee ff ff       	call   8000db <sys_cputs>

	return b.cnt;
}
  8011e0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8011e6:	c9                   	leave  
  8011e7:	c3                   	ret    

008011e8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8011e8:	f3 0f 1e fb          	endbr32 
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8011f2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8011f5:	50                   	push   %eax
  8011f6:	ff 75 08             	pushl  0x8(%ebp)
  8011f9:	e8 95 ff ff ff       	call   801193 <vcprintf>
	va_end(ap);

	return cnt;
}
  8011fe:	c9                   	leave  
  8011ff:	c3                   	ret    

00801200 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	57                   	push   %edi
  801204:	56                   	push   %esi
  801205:	53                   	push   %ebx
  801206:	83 ec 1c             	sub    $0x1c,%esp
  801209:	89 c7                	mov    %eax,%edi
  80120b:	89 d6                	mov    %edx,%esi
  80120d:	8b 45 08             	mov    0x8(%ebp),%eax
  801210:	8b 55 0c             	mov    0xc(%ebp),%edx
  801213:	89 d1                	mov    %edx,%ecx
  801215:	89 c2                	mov    %eax,%edx
  801217:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80121a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80121d:	8b 45 10             	mov    0x10(%ebp),%eax
  801220:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801223:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801226:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80122d:	39 c2                	cmp    %eax,%edx
  80122f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801232:	72 3e                	jb     801272 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801234:	83 ec 0c             	sub    $0xc,%esp
  801237:	ff 75 18             	pushl  0x18(%ebp)
  80123a:	83 eb 01             	sub    $0x1,%ebx
  80123d:	53                   	push   %ebx
  80123e:	50                   	push   %eax
  80123f:	83 ec 08             	sub    $0x8,%esp
  801242:	ff 75 e4             	pushl  -0x1c(%ebp)
  801245:	ff 75 e0             	pushl  -0x20(%ebp)
  801248:	ff 75 dc             	pushl  -0x24(%ebp)
  80124b:	ff 75 d8             	pushl  -0x28(%ebp)
  80124e:	e8 4d 0a 00 00       	call   801ca0 <__udivdi3>
  801253:	83 c4 18             	add    $0x18,%esp
  801256:	52                   	push   %edx
  801257:	50                   	push   %eax
  801258:	89 f2                	mov    %esi,%edx
  80125a:	89 f8                	mov    %edi,%eax
  80125c:	e8 9f ff ff ff       	call   801200 <printnum>
  801261:	83 c4 20             	add    $0x20,%esp
  801264:	eb 13                	jmp    801279 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801266:	83 ec 08             	sub    $0x8,%esp
  801269:	56                   	push   %esi
  80126a:	ff 75 18             	pushl  0x18(%ebp)
  80126d:	ff d7                	call   *%edi
  80126f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801272:	83 eb 01             	sub    $0x1,%ebx
  801275:	85 db                	test   %ebx,%ebx
  801277:	7f ed                	jg     801266 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801279:	83 ec 08             	sub    $0x8,%esp
  80127c:	56                   	push   %esi
  80127d:	83 ec 04             	sub    $0x4,%esp
  801280:	ff 75 e4             	pushl  -0x1c(%ebp)
  801283:	ff 75 e0             	pushl  -0x20(%ebp)
  801286:	ff 75 dc             	pushl  -0x24(%ebp)
  801289:	ff 75 d8             	pushl  -0x28(%ebp)
  80128c:	e8 1f 0b 00 00       	call   801db0 <__umoddi3>
  801291:	83 c4 14             	add    $0x14,%esp
  801294:	0f be 80 47 20 80 00 	movsbl 0x802047(%eax),%eax
  80129b:	50                   	push   %eax
  80129c:	ff d7                	call   *%edi
}
  80129e:	83 c4 10             	add    $0x10,%esp
  8012a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012a4:	5b                   	pop    %ebx
  8012a5:	5e                   	pop    %esi
  8012a6:	5f                   	pop    %edi
  8012a7:	5d                   	pop    %ebp
  8012a8:	c3                   	ret    

008012a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8012a9:	f3 0f 1e fb          	endbr32 
  8012ad:	55                   	push   %ebp
  8012ae:	89 e5                	mov    %esp,%ebp
  8012b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8012b3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8012b7:	8b 10                	mov    (%eax),%edx
  8012b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8012bc:	73 0a                	jae    8012c8 <sprintputch+0x1f>
		*b->buf++ = ch;
  8012be:	8d 4a 01             	lea    0x1(%edx),%ecx
  8012c1:	89 08                	mov    %ecx,(%eax)
  8012c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c6:	88 02                	mov    %al,(%edx)
}
  8012c8:	5d                   	pop    %ebp
  8012c9:	c3                   	ret    

008012ca <printfmt>:
{
  8012ca:	f3 0f 1e fb          	endbr32 
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8012d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012d7:	50                   	push   %eax
  8012d8:	ff 75 10             	pushl  0x10(%ebp)
  8012db:	ff 75 0c             	pushl  0xc(%ebp)
  8012de:	ff 75 08             	pushl  0x8(%ebp)
  8012e1:	e8 05 00 00 00       	call   8012eb <vprintfmt>
}
  8012e6:	83 c4 10             	add    $0x10,%esp
  8012e9:	c9                   	leave  
  8012ea:	c3                   	ret    

008012eb <vprintfmt>:
{
  8012eb:	f3 0f 1e fb          	endbr32 
  8012ef:	55                   	push   %ebp
  8012f0:	89 e5                	mov    %esp,%ebp
  8012f2:	57                   	push   %edi
  8012f3:	56                   	push   %esi
  8012f4:	53                   	push   %ebx
  8012f5:	83 ec 3c             	sub    $0x3c,%esp
  8012f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8012fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  801301:	e9 4a 03 00 00       	jmp    801650 <vprintfmt+0x365>
		padc = ' ';
  801306:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80130a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801311:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801318:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80131f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801324:	8d 47 01             	lea    0x1(%edi),%eax
  801327:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80132a:	0f b6 17             	movzbl (%edi),%edx
  80132d:	8d 42 dd             	lea    -0x23(%edx),%eax
  801330:	3c 55                	cmp    $0x55,%al
  801332:	0f 87 de 03 00 00    	ja     801716 <vprintfmt+0x42b>
  801338:	0f b6 c0             	movzbl %al,%eax
  80133b:	3e ff 24 85 80 21 80 	notrack jmp *0x802180(,%eax,4)
  801342:	00 
  801343:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801346:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80134a:	eb d8                	jmp    801324 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80134c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80134f:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801353:	eb cf                	jmp    801324 <vprintfmt+0x39>
  801355:	0f b6 d2             	movzbl %dl,%edx
  801358:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80135b:	b8 00 00 00 00       	mov    $0x0,%eax
  801360:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801363:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801366:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80136a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80136d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801370:	83 f9 09             	cmp    $0x9,%ecx
  801373:	77 55                	ja     8013ca <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  801375:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801378:	eb e9                	jmp    801363 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80137a:	8b 45 14             	mov    0x14(%ebp),%eax
  80137d:	8b 00                	mov    (%eax),%eax
  80137f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801382:	8b 45 14             	mov    0x14(%ebp),%eax
  801385:	8d 40 04             	lea    0x4(%eax),%eax
  801388:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80138b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80138e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801392:	79 90                	jns    801324 <vprintfmt+0x39>
				width = precision, precision = -1;
  801394:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801397:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80139a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8013a1:	eb 81                	jmp    801324 <vprintfmt+0x39>
  8013a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013a6:	85 c0                	test   %eax,%eax
  8013a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ad:	0f 49 d0             	cmovns %eax,%edx
  8013b0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8013b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8013b6:	e9 69 ff ff ff       	jmp    801324 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8013bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8013be:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8013c5:	e9 5a ff ff ff       	jmp    801324 <vprintfmt+0x39>
  8013ca:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8013cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8013d0:	eb bc                	jmp    80138e <vprintfmt+0xa3>
			lflag++;
  8013d2:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8013d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8013d8:	e9 47 ff ff ff       	jmp    801324 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8013dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8013e0:	8d 78 04             	lea    0x4(%eax),%edi
  8013e3:	83 ec 08             	sub    $0x8,%esp
  8013e6:	53                   	push   %ebx
  8013e7:	ff 30                	pushl  (%eax)
  8013e9:	ff d6                	call   *%esi
			break;
  8013eb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8013ee:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8013f1:	e9 57 02 00 00       	jmp    80164d <vprintfmt+0x362>
			err = va_arg(ap, int);
  8013f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013f9:	8d 78 04             	lea    0x4(%eax),%edi
  8013fc:	8b 00                	mov    (%eax),%eax
  8013fe:	99                   	cltd   
  8013ff:	31 d0                	xor    %edx,%eax
  801401:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801403:	83 f8 0f             	cmp    $0xf,%eax
  801406:	7f 23                	jg     80142b <vprintfmt+0x140>
  801408:	8b 14 85 e0 22 80 00 	mov    0x8022e0(,%eax,4),%edx
  80140f:	85 d2                	test   %edx,%edx
  801411:	74 18                	je     80142b <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  801413:	52                   	push   %edx
  801414:	68 dd 1f 80 00       	push   $0x801fdd
  801419:	53                   	push   %ebx
  80141a:	56                   	push   %esi
  80141b:	e8 aa fe ff ff       	call   8012ca <printfmt>
  801420:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801423:	89 7d 14             	mov    %edi,0x14(%ebp)
  801426:	e9 22 02 00 00       	jmp    80164d <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  80142b:	50                   	push   %eax
  80142c:	68 5f 20 80 00       	push   $0x80205f
  801431:	53                   	push   %ebx
  801432:	56                   	push   %esi
  801433:	e8 92 fe ff ff       	call   8012ca <printfmt>
  801438:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80143b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80143e:	e9 0a 02 00 00       	jmp    80164d <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  801443:	8b 45 14             	mov    0x14(%ebp),%eax
  801446:	83 c0 04             	add    $0x4,%eax
  801449:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80144c:	8b 45 14             	mov    0x14(%ebp),%eax
  80144f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801451:	85 d2                	test   %edx,%edx
  801453:	b8 58 20 80 00       	mov    $0x802058,%eax
  801458:	0f 45 c2             	cmovne %edx,%eax
  80145b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80145e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801462:	7e 06                	jle    80146a <vprintfmt+0x17f>
  801464:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801468:	75 0d                	jne    801477 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80146a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80146d:	89 c7                	mov    %eax,%edi
  80146f:	03 45 e0             	add    -0x20(%ebp),%eax
  801472:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801475:	eb 55                	jmp    8014cc <vprintfmt+0x1e1>
  801477:	83 ec 08             	sub    $0x8,%esp
  80147a:	ff 75 d8             	pushl  -0x28(%ebp)
  80147d:	ff 75 cc             	pushl  -0x34(%ebp)
  801480:	e8 45 03 00 00       	call   8017ca <strnlen>
  801485:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801488:	29 c2                	sub    %eax,%edx
  80148a:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80148d:	83 c4 10             	add    $0x10,%esp
  801490:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  801492:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801496:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801499:	85 ff                	test   %edi,%edi
  80149b:	7e 11                	jle    8014ae <vprintfmt+0x1c3>
					putch(padc, putdat);
  80149d:	83 ec 08             	sub    $0x8,%esp
  8014a0:	53                   	push   %ebx
  8014a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8014a4:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8014a6:	83 ef 01             	sub    $0x1,%edi
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	eb eb                	jmp    801499 <vprintfmt+0x1ae>
  8014ae:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8014b1:	85 d2                	test   %edx,%edx
  8014b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b8:	0f 49 c2             	cmovns %edx,%eax
  8014bb:	29 c2                	sub    %eax,%edx
  8014bd:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8014c0:	eb a8                	jmp    80146a <vprintfmt+0x17f>
					putch(ch, putdat);
  8014c2:	83 ec 08             	sub    $0x8,%esp
  8014c5:	53                   	push   %ebx
  8014c6:	52                   	push   %edx
  8014c7:	ff d6                	call   *%esi
  8014c9:	83 c4 10             	add    $0x10,%esp
  8014cc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014cf:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014d1:	83 c7 01             	add    $0x1,%edi
  8014d4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014d8:	0f be d0             	movsbl %al,%edx
  8014db:	85 d2                	test   %edx,%edx
  8014dd:	74 4b                	je     80152a <vprintfmt+0x23f>
  8014df:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014e3:	78 06                	js     8014eb <vprintfmt+0x200>
  8014e5:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014e9:	78 1e                	js     801509 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8014eb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014ef:	74 d1                	je     8014c2 <vprintfmt+0x1d7>
  8014f1:	0f be c0             	movsbl %al,%eax
  8014f4:	83 e8 20             	sub    $0x20,%eax
  8014f7:	83 f8 5e             	cmp    $0x5e,%eax
  8014fa:	76 c6                	jbe    8014c2 <vprintfmt+0x1d7>
					putch('?', putdat);
  8014fc:	83 ec 08             	sub    $0x8,%esp
  8014ff:	53                   	push   %ebx
  801500:	6a 3f                	push   $0x3f
  801502:	ff d6                	call   *%esi
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	eb c3                	jmp    8014cc <vprintfmt+0x1e1>
  801509:	89 cf                	mov    %ecx,%edi
  80150b:	eb 0e                	jmp    80151b <vprintfmt+0x230>
				putch(' ', putdat);
  80150d:	83 ec 08             	sub    $0x8,%esp
  801510:	53                   	push   %ebx
  801511:	6a 20                	push   $0x20
  801513:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801515:	83 ef 01             	sub    $0x1,%edi
  801518:	83 c4 10             	add    $0x10,%esp
  80151b:	85 ff                	test   %edi,%edi
  80151d:	7f ee                	jg     80150d <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80151f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801522:	89 45 14             	mov    %eax,0x14(%ebp)
  801525:	e9 23 01 00 00       	jmp    80164d <vprintfmt+0x362>
  80152a:	89 cf                	mov    %ecx,%edi
  80152c:	eb ed                	jmp    80151b <vprintfmt+0x230>
	if (lflag >= 2)
  80152e:	83 f9 01             	cmp    $0x1,%ecx
  801531:	7f 1b                	jg     80154e <vprintfmt+0x263>
	else if (lflag)
  801533:	85 c9                	test   %ecx,%ecx
  801535:	74 63                	je     80159a <vprintfmt+0x2af>
		return va_arg(*ap, long);
  801537:	8b 45 14             	mov    0x14(%ebp),%eax
  80153a:	8b 00                	mov    (%eax),%eax
  80153c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80153f:	99                   	cltd   
  801540:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801543:	8b 45 14             	mov    0x14(%ebp),%eax
  801546:	8d 40 04             	lea    0x4(%eax),%eax
  801549:	89 45 14             	mov    %eax,0x14(%ebp)
  80154c:	eb 17                	jmp    801565 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80154e:	8b 45 14             	mov    0x14(%ebp),%eax
  801551:	8b 50 04             	mov    0x4(%eax),%edx
  801554:	8b 00                	mov    (%eax),%eax
  801556:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801559:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80155c:	8b 45 14             	mov    0x14(%ebp),%eax
  80155f:	8d 40 08             	lea    0x8(%eax),%eax
  801562:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801565:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801568:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80156b:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  801570:	85 c9                	test   %ecx,%ecx
  801572:	0f 89 bb 00 00 00    	jns    801633 <vprintfmt+0x348>
				putch('-', putdat);
  801578:	83 ec 08             	sub    $0x8,%esp
  80157b:	53                   	push   %ebx
  80157c:	6a 2d                	push   $0x2d
  80157e:	ff d6                	call   *%esi
				num = -(long long) num;
  801580:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801583:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801586:	f7 da                	neg    %edx
  801588:	83 d1 00             	adc    $0x0,%ecx
  80158b:	f7 d9                	neg    %ecx
  80158d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801590:	b8 0a 00 00 00       	mov    $0xa,%eax
  801595:	e9 99 00 00 00       	jmp    801633 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80159a:	8b 45 14             	mov    0x14(%ebp),%eax
  80159d:	8b 00                	mov    (%eax),%eax
  80159f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015a2:	99                   	cltd   
  8015a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8015a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a9:	8d 40 04             	lea    0x4(%eax),%eax
  8015ac:	89 45 14             	mov    %eax,0x14(%ebp)
  8015af:	eb b4                	jmp    801565 <vprintfmt+0x27a>
	if (lflag >= 2)
  8015b1:	83 f9 01             	cmp    $0x1,%ecx
  8015b4:	7f 1b                	jg     8015d1 <vprintfmt+0x2e6>
	else if (lflag)
  8015b6:	85 c9                	test   %ecx,%ecx
  8015b8:	74 2c                	je     8015e6 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  8015ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8015bd:	8b 10                	mov    (%eax),%edx
  8015bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015c4:	8d 40 04             	lea    0x4(%eax),%eax
  8015c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015ca:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8015cf:	eb 62                	jmp    801633 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8015d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d4:	8b 10                	mov    (%eax),%edx
  8015d6:	8b 48 04             	mov    0x4(%eax),%ecx
  8015d9:	8d 40 08             	lea    0x8(%eax),%eax
  8015dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015df:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8015e4:	eb 4d                	jmp    801633 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8015e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e9:	8b 10                	mov    (%eax),%edx
  8015eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015f0:	8d 40 04             	lea    0x4(%eax),%eax
  8015f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015f6:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8015fb:	eb 36                	jmp    801633 <vprintfmt+0x348>
	if (lflag >= 2)
  8015fd:	83 f9 01             	cmp    $0x1,%ecx
  801600:	7f 17                	jg     801619 <vprintfmt+0x32e>
	else if (lflag)
  801602:	85 c9                	test   %ecx,%ecx
  801604:	74 6e                	je     801674 <vprintfmt+0x389>
		return va_arg(*ap, long);
  801606:	8b 45 14             	mov    0x14(%ebp),%eax
  801609:	8b 10                	mov    (%eax),%edx
  80160b:	89 d0                	mov    %edx,%eax
  80160d:	99                   	cltd   
  80160e:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801611:	8d 49 04             	lea    0x4(%ecx),%ecx
  801614:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801617:	eb 11                	jmp    80162a <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  801619:	8b 45 14             	mov    0x14(%ebp),%eax
  80161c:	8b 50 04             	mov    0x4(%eax),%edx
  80161f:	8b 00                	mov    (%eax),%eax
  801621:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801624:	8d 49 08             	lea    0x8(%ecx),%ecx
  801627:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80162a:	89 d1                	mov    %edx,%ecx
  80162c:	89 c2                	mov    %eax,%edx
            base = 8;
  80162e:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  801633:	83 ec 0c             	sub    $0xc,%esp
  801636:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80163a:	57                   	push   %edi
  80163b:	ff 75 e0             	pushl  -0x20(%ebp)
  80163e:	50                   	push   %eax
  80163f:	51                   	push   %ecx
  801640:	52                   	push   %edx
  801641:	89 da                	mov    %ebx,%edx
  801643:	89 f0                	mov    %esi,%eax
  801645:	e8 b6 fb ff ff       	call   801200 <printnum>
			break;
  80164a:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80164d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801650:	83 c7 01             	add    $0x1,%edi
  801653:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801657:	83 f8 25             	cmp    $0x25,%eax
  80165a:	0f 84 a6 fc ff ff    	je     801306 <vprintfmt+0x1b>
			if (ch == '\0')
  801660:	85 c0                	test   %eax,%eax
  801662:	0f 84 ce 00 00 00    	je     801736 <vprintfmt+0x44b>
			putch(ch, putdat);
  801668:	83 ec 08             	sub    $0x8,%esp
  80166b:	53                   	push   %ebx
  80166c:	50                   	push   %eax
  80166d:	ff d6                	call   *%esi
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	eb dc                	jmp    801650 <vprintfmt+0x365>
		return va_arg(*ap, int);
  801674:	8b 45 14             	mov    0x14(%ebp),%eax
  801677:	8b 10                	mov    (%eax),%edx
  801679:	89 d0                	mov    %edx,%eax
  80167b:	99                   	cltd   
  80167c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80167f:	8d 49 04             	lea    0x4(%ecx),%ecx
  801682:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801685:	eb a3                	jmp    80162a <vprintfmt+0x33f>
			putch('0', putdat);
  801687:	83 ec 08             	sub    $0x8,%esp
  80168a:	53                   	push   %ebx
  80168b:	6a 30                	push   $0x30
  80168d:	ff d6                	call   *%esi
			putch('x', putdat);
  80168f:	83 c4 08             	add    $0x8,%esp
  801692:	53                   	push   %ebx
  801693:	6a 78                	push   $0x78
  801695:	ff d6                	call   *%esi
			num = (unsigned long long)
  801697:	8b 45 14             	mov    0x14(%ebp),%eax
  80169a:	8b 10                	mov    (%eax),%edx
  80169c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8016a1:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8016a4:	8d 40 04             	lea    0x4(%eax),%eax
  8016a7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016aa:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8016af:	eb 82                	jmp    801633 <vprintfmt+0x348>
	if (lflag >= 2)
  8016b1:	83 f9 01             	cmp    $0x1,%ecx
  8016b4:	7f 1e                	jg     8016d4 <vprintfmt+0x3e9>
	else if (lflag)
  8016b6:	85 c9                	test   %ecx,%ecx
  8016b8:	74 32                	je     8016ec <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  8016ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8016bd:	8b 10                	mov    (%eax),%edx
  8016bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016c4:	8d 40 04             	lea    0x4(%eax),%eax
  8016c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016ca:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8016cf:	e9 5f ff ff ff       	jmp    801633 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8016d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8016d7:	8b 10                	mov    (%eax),%edx
  8016d9:	8b 48 04             	mov    0x4(%eax),%ecx
  8016dc:	8d 40 08             	lea    0x8(%eax),%eax
  8016df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016e2:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8016e7:	e9 47 ff ff ff       	jmp    801633 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8016ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8016ef:	8b 10                	mov    (%eax),%edx
  8016f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016f6:	8d 40 04             	lea    0x4(%eax),%eax
  8016f9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016fc:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  801701:	e9 2d ff ff ff       	jmp    801633 <vprintfmt+0x348>
			putch(ch, putdat);
  801706:	83 ec 08             	sub    $0x8,%esp
  801709:	53                   	push   %ebx
  80170a:	6a 25                	push   $0x25
  80170c:	ff d6                	call   *%esi
			break;
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	e9 37 ff ff ff       	jmp    80164d <vprintfmt+0x362>
			putch('%', putdat);
  801716:	83 ec 08             	sub    $0x8,%esp
  801719:	53                   	push   %ebx
  80171a:	6a 25                	push   $0x25
  80171c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80171e:	83 c4 10             	add    $0x10,%esp
  801721:	89 f8                	mov    %edi,%eax
  801723:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801727:	74 05                	je     80172e <vprintfmt+0x443>
  801729:	83 e8 01             	sub    $0x1,%eax
  80172c:	eb f5                	jmp    801723 <vprintfmt+0x438>
  80172e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801731:	e9 17 ff ff ff       	jmp    80164d <vprintfmt+0x362>
}
  801736:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801739:	5b                   	pop    %ebx
  80173a:	5e                   	pop    %esi
  80173b:	5f                   	pop    %edi
  80173c:	5d                   	pop    %ebp
  80173d:	c3                   	ret    

0080173e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80173e:	f3 0f 1e fb          	endbr32 
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	83 ec 18             	sub    $0x18,%esp
  801748:	8b 45 08             	mov    0x8(%ebp),%eax
  80174b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80174e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801751:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801755:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801758:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80175f:	85 c0                	test   %eax,%eax
  801761:	74 26                	je     801789 <vsnprintf+0x4b>
  801763:	85 d2                	test   %edx,%edx
  801765:	7e 22                	jle    801789 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801767:	ff 75 14             	pushl  0x14(%ebp)
  80176a:	ff 75 10             	pushl  0x10(%ebp)
  80176d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801770:	50                   	push   %eax
  801771:	68 a9 12 80 00       	push   $0x8012a9
  801776:	e8 70 fb ff ff       	call   8012eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80177b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80177e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801781:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801784:	83 c4 10             	add    $0x10,%esp
}
  801787:	c9                   	leave  
  801788:	c3                   	ret    
		return -E_INVAL;
  801789:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80178e:	eb f7                	jmp    801787 <vsnprintf+0x49>

00801790 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801790:	f3 0f 1e fb          	endbr32 
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80179a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80179d:	50                   	push   %eax
  80179e:	ff 75 10             	pushl  0x10(%ebp)
  8017a1:	ff 75 0c             	pushl  0xc(%ebp)
  8017a4:	ff 75 08             	pushl  0x8(%ebp)
  8017a7:	e8 92 ff ff ff       	call   80173e <vsnprintf>
	va_end(ap);

	return rc;
}
  8017ac:	c9                   	leave  
  8017ad:	c3                   	ret    

008017ae <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8017ae:	f3 0f 1e fb          	endbr32 
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8017b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8017bd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8017c1:	74 05                	je     8017c8 <strlen+0x1a>
		n++;
  8017c3:	83 c0 01             	add    $0x1,%eax
  8017c6:	eb f5                	jmp    8017bd <strlen+0xf>
	return n;
}
  8017c8:	5d                   	pop    %ebp
  8017c9:	c3                   	ret    

008017ca <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8017ca:	f3 0f 1e fb          	endbr32 
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8017d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8017dc:	39 d0                	cmp    %edx,%eax
  8017de:	74 0d                	je     8017ed <strnlen+0x23>
  8017e0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8017e4:	74 05                	je     8017eb <strnlen+0x21>
		n++;
  8017e6:	83 c0 01             	add    $0x1,%eax
  8017e9:	eb f1                	jmp    8017dc <strnlen+0x12>
  8017eb:	89 c2                	mov    %eax,%edx
	return n;
}
  8017ed:	89 d0                	mov    %edx,%eax
  8017ef:	5d                   	pop    %ebp
  8017f0:	c3                   	ret    

008017f1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8017f1:	f3 0f 1e fb          	endbr32 
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	53                   	push   %ebx
  8017f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8017ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801804:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801808:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80180b:	83 c0 01             	add    $0x1,%eax
  80180e:	84 d2                	test   %dl,%dl
  801810:	75 f2                	jne    801804 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  801812:	89 c8                	mov    %ecx,%eax
  801814:	5b                   	pop    %ebx
  801815:	5d                   	pop    %ebp
  801816:	c3                   	ret    

00801817 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801817:	f3 0f 1e fb          	endbr32 
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	53                   	push   %ebx
  80181f:	83 ec 10             	sub    $0x10,%esp
  801822:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801825:	53                   	push   %ebx
  801826:	e8 83 ff ff ff       	call   8017ae <strlen>
  80182b:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80182e:	ff 75 0c             	pushl  0xc(%ebp)
  801831:	01 d8                	add    %ebx,%eax
  801833:	50                   	push   %eax
  801834:	e8 b8 ff ff ff       	call   8017f1 <strcpy>
	return dst;
}
  801839:	89 d8                	mov    %ebx,%eax
  80183b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    

00801840 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801840:	f3 0f 1e fb          	endbr32 
  801844:	55                   	push   %ebp
  801845:	89 e5                	mov    %esp,%ebp
  801847:	56                   	push   %esi
  801848:	53                   	push   %ebx
  801849:	8b 75 08             	mov    0x8(%ebp),%esi
  80184c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80184f:	89 f3                	mov    %esi,%ebx
  801851:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801854:	89 f0                	mov    %esi,%eax
  801856:	39 d8                	cmp    %ebx,%eax
  801858:	74 11                	je     80186b <strncpy+0x2b>
		*dst++ = *src;
  80185a:	83 c0 01             	add    $0x1,%eax
  80185d:	0f b6 0a             	movzbl (%edx),%ecx
  801860:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801863:	80 f9 01             	cmp    $0x1,%cl
  801866:	83 da ff             	sbb    $0xffffffff,%edx
  801869:	eb eb                	jmp    801856 <strncpy+0x16>
	}
	return ret;
}
  80186b:	89 f0                	mov    %esi,%eax
  80186d:	5b                   	pop    %ebx
  80186e:	5e                   	pop    %esi
  80186f:	5d                   	pop    %ebp
  801870:	c3                   	ret    

00801871 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801871:	f3 0f 1e fb          	endbr32 
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
  801878:	56                   	push   %esi
  801879:	53                   	push   %ebx
  80187a:	8b 75 08             	mov    0x8(%ebp),%esi
  80187d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801880:	8b 55 10             	mov    0x10(%ebp),%edx
  801883:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801885:	85 d2                	test   %edx,%edx
  801887:	74 21                	je     8018aa <strlcpy+0x39>
  801889:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80188d:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80188f:	39 c2                	cmp    %eax,%edx
  801891:	74 14                	je     8018a7 <strlcpy+0x36>
  801893:	0f b6 19             	movzbl (%ecx),%ebx
  801896:	84 db                	test   %bl,%bl
  801898:	74 0b                	je     8018a5 <strlcpy+0x34>
			*dst++ = *src++;
  80189a:	83 c1 01             	add    $0x1,%ecx
  80189d:	83 c2 01             	add    $0x1,%edx
  8018a0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8018a3:	eb ea                	jmp    80188f <strlcpy+0x1e>
  8018a5:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8018a7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8018aa:	29 f0                	sub    %esi,%eax
}
  8018ac:	5b                   	pop    %ebx
  8018ad:	5e                   	pop    %esi
  8018ae:	5d                   	pop    %ebp
  8018af:	c3                   	ret    

008018b0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8018b0:	f3 0f 1e fb          	endbr32 
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
  8018b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8018bd:	0f b6 01             	movzbl (%ecx),%eax
  8018c0:	84 c0                	test   %al,%al
  8018c2:	74 0c                	je     8018d0 <strcmp+0x20>
  8018c4:	3a 02                	cmp    (%edx),%al
  8018c6:	75 08                	jne    8018d0 <strcmp+0x20>
		p++, q++;
  8018c8:	83 c1 01             	add    $0x1,%ecx
  8018cb:	83 c2 01             	add    $0x1,%edx
  8018ce:	eb ed                	jmp    8018bd <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8018d0:	0f b6 c0             	movzbl %al,%eax
  8018d3:	0f b6 12             	movzbl (%edx),%edx
  8018d6:	29 d0                	sub    %edx,%eax
}
  8018d8:	5d                   	pop    %ebp
  8018d9:	c3                   	ret    

008018da <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8018da:	f3 0f 1e fb          	endbr32 
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	53                   	push   %ebx
  8018e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e8:	89 c3                	mov    %eax,%ebx
  8018ea:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8018ed:	eb 06                	jmp    8018f5 <strncmp+0x1b>
		n--, p++, q++;
  8018ef:	83 c0 01             	add    $0x1,%eax
  8018f2:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8018f5:	39 d8                	cmp    %ebx,%eax
  8018f7:	74 16                	je     80190f <strncmp+0x35>
  8018f9:	0f b6 08             	movzbl (%eax),%ecx
  8018fc:	84 c9                	test   %cl,%cl
  8018fe:	74 04                	je     801904 <strncmp+0x2a>
  801900:	3a 0a                	cmp    (%edx),%cl
  801902:	74 eb                	je     8018ef <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801904:	0f b6 00             	movzbl (%eax),%eax
  801907:	0f b6 12             	movzbl (%edx),%edx
  80190a:	29 d0                	sub    %edx,%eax
}
  80190c:	5b                   	pop    %ebx
  80190d:	5d                   	pop    %ebp
  80190e:	c3                   	ret    
		return 0;
  80190f:	b8 00 00 00 00       	mov    $0x0,%eax
  801914:	eb f6                	jmp    80190c <strncmp+0x32>

00801916 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801916:	f3 0f 1e fb          	endbr32 
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	8b 45 08             	mov    0x8(%ebp),%eax
  801920:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801924:	0f b6 10             	movzbl (%eax),%edx
  801927:	84 d2                	test   %dl,%dl
  801929:	74 09                	je     801934 <strchr+0x1e>
		if (*s == c)
  80192b:	38 ca                	cmp    %cl,%dl
  80192d:	74 0a                	je     801939 <strchr+0x23>
	for (; *s; s++)
  80192f:	83 c0 01             	add    $0x1,%eax
  801932:	eb f0                	jmp    801924 <strchr+0xe>
			return (char *) s;
	return 0;
  801934:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801939:	5d                   	pop    %ebp
  80193a:	c3                   	ret    

0080193b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80193b:	f3 0f 1e fb          	endbr32 
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	8b 45 08             	mov    0x8(%ebp),%eax
  801945:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801949:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80194c:	38 ca                	cmp    %cl,%dl
  80194e:	74 09                	je     801959 <strfind+0x1e>
  801950:	84 d2                	test   %dl,%dl
  801952:	74 05                	je     801959 <strfind+0x1e>
	for (; *s; s++)
  801954:	83 c0 01             	add    $0x1,%eax
  801957:	eb f0                	jmp    801949 <strfind+0xe>
			break;
	return (char *) s;
}
  801959:	5d                   	pop    %ebp
  80195a:	c3                   	ret    

0080195b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80195b:	f3 0f 1e fb          	endbr32 
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	57                   	push   %edi
  801963:	56                   	push   %esi
  801964:	53                   	push   %ebx
  801965:	8b 7d 08             	mov    0x8(%ebp),%edi
  801968:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80196b:	85 c9                	test   %ecx,%ecx
  80196d:	74 31                	je     8019a0 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80196f:	89 f8                	mov    %edi,%eax
  801971:	09 c8                	or     %ecx,%eax
  801973:	a8 03                	test   $0x3,%al
  801975:	75 23                	jne    80199a <memset+0x3f>
		c &= 0xFF;
  801977:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80197b:	89 d3                	mov    %edx,%ebx
  80197d:	c1 e3 08             	shl    $0x8,%ebx
  801980:	89 d0                	mov    %edx,%eax
  801982:	c1 e0 18             	shl    $0x18,%eax
  801985:	89 d6                	mov    %edx,%esi
  801987:	c1 e6 10             	shl    $0x10,%esi
  80198a:	09 f0                	or     %esi,%eax
  80198c:	09 c2                	or     %eax,%edx
  80198e:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801990:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801993:	89 d0                	mov    %edx,%eax
  801995:	fc                   	cld    
  801996:	f3 ab                	rep stos %eax,%es:(%edi)
  801998:	eb 06                	jmp    8019a0 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80199a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199d:	fc                   	cld    
  80199e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8019a0:	89 f8                	mov    %edi,%eax
  8019a2:	5b                   	pop    %ebx
  8019a3:	5e                   	pop    %esi
  8019a4:	5f                   	pop    %edi
  8019a5:	5d                   	pop    %ebp
  8019a6:	c3                   	ret    

008019a7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8019a7:	f3 0f 1e fb          	endbr32 
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	57                   	push   %edi
  8019af:	56                   	push   %esi
  8019b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8019b9:	39 c6                	cmp    %eax,%esi
  8019bb:	73 32                	jae    8019ef <memmove+0x48>
  8019bd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8019c0:	39 c2                	cmp    %eax,%edx
  8019c2:	76 2b                	jbe    8019ef <memmove+0x48>
		s += n;
		d += n;
  8019c4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019c7:	89 fe                	mov    %edi,%esi
  8019c9:	09 ce                	or     %ecx,%esi
  8019cb:	09 d6                	or     %edx,%esi
  8019cd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8019d3:	75 0e                	jne    8019e3 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8019d5:	83 ef 04             	sub    $0x4,%edi
  8019d8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8019db:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8019de:	fd                   	std    
  8019df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019e1:	eb 09                	jmp    8019ec <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8019e3:	83 ef 01             	sub    $0x1,%edi
  8019e6:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8019e9:	fd                   	std    
  8019ea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8019ec:	fc                   	cld    
  8019ed:	eb 1a                	jmp    801a09 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019ef:	89 c2                	mov    %eax,%edx
  8019f1:	09 ca                	or     %ecx,%edx
  8019f3:	09 f2                	or     %esi,%edx
  8019f5:	f6 c2 03             	test   $0x3,%dl
  8019f8:	75 0a                	jne    801a04 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8019fa:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8019fd:	89 c7                	mov    %eax,%edi
  8019ff:	fc                   	cld    
  801a00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a02:	eb 05                	jmp    801a09 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  801a04:	89 c7                	mov    %eax,%edi
  801a06:	fc                   	cld    
  801a07:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801a09:	5e                   	pop    %esi
  801a0a:	5f                   	pop    %edi
  801a0b:	5d                   	pop    %ebp
  801a0c:	c3                   	ret    

00801a0d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a0d:	f3 0f 1e fb          	endbr32 
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801a17:	ff 75 10             	pushl  0x10(%ebp)
  801a1a:	ff 75 0c             	pushl  0xc(%ebp)
  801a1d:	ff 75 08             	pushl  0x8(%ebp)
  801a20:	e8 82 ff ff ff       	call   8019a7 <memmove>
}
  801a25:	c9                   	leave  
  801a26:	c3                   	ret    

00801a27 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801a27:	f3 0f 1e fb          	endbr32 
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	56                   	push   %esi
  801a2f:	53                   	push   %ebx
  801a30:	8b 45 08             	mov    0x8(%ebp),%eax
  801a33:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a36:	89 c6                	mov    %eax,%esi
  801a38:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a3b:	39 f0                	cmp    %esi,%eax
  801a3d:	74 1c                	je     801a5b <memcmp+0x34>
		if (*s1 != *s2)
  801a3f:	0f b6 08             	movzbl (%eax),%ecx
  801a42:	0f b6 1a             	movzbl (%edx),%ebx
  801a45:	38 d9                	cmp    %bl,%cl
  801a47:	75 08                	jne    801a51 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801a49:	83 c0 01             	add    $0x1,%eax
  801a4c:	83 c2 01             	add    $0x1,%edx
  801a4f:	eb ea                	jmp    801a3b <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801a51:	0f b6 c1             	movzbl %cl,%eax
  801a54:	0f b6 db             	movzbl %bl,%ebx
  801a57:	29 d8                	sub    %ebx,%eax
  801a59:	eb 05                	jmp    801a60 <memcmp+0x39>
	}

	return 0;
  801a5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a60:	5b                   	pop    %ebx
  801a61:	5e                   	pop    %esi
  801a62:	5d                   	pop    %ebp
  801a63:	c3                   	ret    

00801a64 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a64:	f3 0f 1e fb          	endbr32 
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a71:	89 c2                	mov    %eax,%edx
  801a73:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a76:	39 d0                	cmp    %edx,%eax
  801a78:	73 09                	jae    801a83 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a7a:	38 08                	cmp    %cl,(%eax)
  801a7c:	74 05                	je     801a83 <memfind+0x1f>
	for (; s < ends; s++)
  801a7e:	83 c0 01             	add    $0x1,%eax
  801a81:	eb f3                	jmp    801a76 <memfind+0x12>
			break;
	return (void *) s;
}
  801a83:	5d                   	pop    %ebp
  801a84:	c3                   	ret    

00801a85 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a85:	f3 0f 1e fb          	endbr32 
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	57                   	push   %edi
  801a8d:	56                   	push   %esi
  801a8e:	53                   	push   %ebx
  801a8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a92:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a95:	eb 03                	jmp    801a9a <strtol+0x15>
		s++;
  801a97:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801a9a:	0f b6 01             	movzbl (%ecx),%eax
  801a9d:	3c 20                	cmp    $0x20,%al
  801a9f:	74 f6                	je     801a97 <strtol+0x12>
  801aa1:	3c 09                	cmp    $0x9,%al
  801aa3:	74 f2                	je     801a97 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801aa5:	3c 2b                	cmp    $0x2b,%al
  801aa7:	74 2a                	je     801ad3 <strtol+0x4e>
	int neg = 0;
  801aa9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801aae:	3c 2d                	cmp    $0x2d,%al
  801ab0:	74 2b                	je     801add <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ab2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801ab8:	75 0f                	jne    801ac9 <strtol+0x44>
  801aba:	80 39 30             	cmpb   $0x30,(%ecx)
  801abd:	74 28                	je     801ae7 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801abf:	85 db                	test   %ebx,%ebx
  801ac1:	b8 0a 00 00 00       	mov    $0xa,%eax
  801ac6:	0f 44 d8             	cmove  %eax,%ebx
  801ac9:	b8 00 00 00 00       	mov    $0x0,%eax
  801ace:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801ad1:	eb 46                	jmp    801b19 <strtol+0x94>
		s++;
  801ad3:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801ad6:	bf 00 00 00 00       	mov    $0x0,%edi
  801adb:	eb d5                	jmp    801ab2 <strtol+0x2d>
		s++, neg = 1;
  801add:	83 c1 01             	add    $0x1,%ecx
  801ae0:	bf 01 00 00 00       	mov    $0x1,%edi
  801ae5:	eb cb                	jmp    801ab2 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ae7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801aeb:	74 0e                	je     801afb <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801aed:	85 db                	test   %ebx,%ebx
  801aef:	75 d8                	jne    801ac9 <strtol+0x44>
		s++, base = 8;
  801af1:	83 c1 01             	add    $0x1,%ecx
  801af4:	bb 08 00 00 00       	mov    $0x8,%ebx
  801af9:	eb ce                	jmp    801ac9 <strtol+0x44>
		s += 2, base = 16;
  801afb:	83 c1 02             	add    $0x2,%ecx
  801afe:	bb 10 00 00 00       	mov    $0x10,%ebx
  801b03:	eb c4                	jmp    801ac9 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801b05:	0f be d2             	movsbl %dl,%edx
  801b08:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801b0b:	3b 55 10             	cmp    0x10(%ebp),%edx
  801b0e:	7d 3a                	jge    801b4a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801b10:	83 c1 01             	add    $0x1,%ecx
  801b13:	0f af 45 10          	imul   0x10(%ebp),%eax
  801b17:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801b19:	0f b6 11             	movzbl (%ecx),%edx
  801b1c:	8d 72 d0             	lea    -0x30(%edx),%esi
  801b1f:	89 f3                	mov    %esi,%ebx
  801b21:	80 fb 09             	cmp    $0x9,%bl
  801b24:	76 df                	jbe    801b05 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801b26:	8d 72 9f             	lea    -0x61(%edx),%esi
  801b29:	89 f3                	mov    %esi,%ebx
  801b2b:	80 fb 19             	cmp    $0x19,%bl
  801b2e:	77 08                	ja     801b38 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801b30:	0f be d2             	movsbl %dl,%edx
  801b33:	83 ea 57             	sub    $0x57,%edx
  801b36:	eb d3                	jmp    801b0b <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801b38:	8d 72 bf             	lea    -0x41(%edx),%esi
  801b3b:	89 f3                	mov    %esi,%ebx
  801b3d:	80 fb 19             	cmp    $0x19,%bl
  801b40:	77 08                	ja     801b4a <strtol+0xc5>
			dig = *s - 'A' + 10;
  801b42:	0f be d2             	movsbl %dl,%edx
  801b45:	83 ea 37             	sub    $0x37,%edx
  801b48:	eb c1                	jmp    801b0b <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801b4a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b4e:	74 05                	je     801b55 <strtol+0xd0>
		*endptr = (char *) s;
  801b50:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b53:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801b55:	89 c2                	mov    %eax,%edx
  801b57:	f7 da                	neg    %edx
  801b59:	85 ff                	test   %edi,%edi
  801b5b:	0f 45 c2             	cmovne %edx,%eax
}
  801b5e:	5b                   	pop    %ebx
  801b5f:	5e                   	pop    %esi
  801b60:	5f                   	pop    %edi
  801b61:	5d                   	pop    %ebp
  801b62:	c3                   	ret    

00801b63 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b63:	f3 0f 1e fb          	endbr32 
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	56                   	push   %esi
  801b6b:	53                   	push   %ebx
  801b6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b72:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801b75:	85 c0                	test   %eax,%eax
  801b77:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b7c:	0f 44 c2             	cmove  %edx,%eax
  801b7f:	83 ec 0c             	sub    $0xc,%esp
  801b82:	50                   	push   %eax
  801b83:	e8 ef e7 ff ff       	call   800377 <sys_ipc_recv>
  801b88:	83 c4 10             	add    $0x10,%esp
  801b8b:	85 c0                	test   %eax,%eax
  801b8d:	78 24                	js     801bb3 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801b8f:	85 f6                	test   %esi,%esi
  801b91:	74 0a                	je     801b9d <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801b93:	a1 04 40 80 00       	mov    0x804004,%eax
  801b98:	8b 40 78             	mov    0x78(%eax),%eax
  801b9b:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801b9d:	85 db                	test   %ebx,%ebx
  801b9f:	74 0a                	je     801bab <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801ba1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ba6:	8b 40 74             	mov    0x74(%eax),%eax
  801ba9:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801bab:	a1 04 40 80 00       	mov    0x804004,%eax
  801bb0:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bb3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bb6:	5b                   	pop    %ebx
  801bb7:	5e                   	pop    %esi
  801bb8:	5d                   	pop    %ebp
  801bb9:	c3                   	ret    

00801bba <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bba:	f3 0f 1e fb          	endbr32 
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	57                   	push   %edi
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	83 ec 1c             	sub    $0x1c,%esp
  801bc7:	8b 45 10             	mov    0x10(%ebp),%eax
  801bca:	85 c0                	test   %eax,%eax
  801bcc:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801bd1:	0f 45 d0             	cmovne %eax,%edx
  801bd4:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801bd6:	be 01 00 00 00       	mov    $0x1,%esi
  801bdb:	eb 1f                	jmp    801bfc <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801bdd:	e8 a6 e5 ff ff       	call   800188 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801be2:	83 c3 01             	add    $0x1,%ebx
  801be5:	39 de                	cmp    %ebx,%esi
  801be7:	7f f4                	jg     801bdd <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801be9:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801beb:	83 fe 11             	cmp    $0x11,%esi
  801bee:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf3:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801bf6:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801bfa:	75 1c                	jne    801c18 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801bfc:	ff 75 14             	pushl  0x14(%ebp)
  801bff:	57                   	push   %edi
  801c00:	ff 75 0c             	pushl  0xc(%ebp)
  801c03:	ff 75 08             	pushl  0x8(%ebp)
  801c06:	e8 45 e7 ff ff       	call   800350 <sys_ipc_try_send>
  801c0b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801c0e:	83 c4 10             	add    $0x10,%esp
  801c11:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c16:	eb cd                	jmp    801be5 <ipc_send+0x2b>
}
  801c18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c1b:	5b                   	pop    %ebx
  801c1c:	5e                   	pop    %esi
  801c1d:	5f                   	pop    %edi
  801c1e:	5d                   	pop    %ebp
  801c1f:	c3                   	ret    

00801c20 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c20:	f3 0f 1e fb          	endbr32 
  801c24:	55                   	push   %ebp
  801c25:	89 e5                	mov    %esp,%ebp
  801c27:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c2a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c2f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c32:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c38:	8b 52 50             	mov    0x50(%edx),%edx
  801c3b:	39 ca                	cmp    %ecx,%edx
  801c3d:	74 11                	je     801c50 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801c3f:	83 c0 01             	add    $0x1,%eax
  801c42:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c47:	75 e6                	jne    801c2f <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801c49:	b8 00 00 00 00       	mov    $0x0,%eax
  801c4e:	eb 0b                	jmp    801c5b <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c50:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c53:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c58:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c5b:	5d                   	pop    %ebp
  801c5c:	c3                   	ret    

00801c5d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c5d:	f3 0f 1e fb          	endbr32 
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c67:	89 c2                	mov    %eax,%edx
  801c69:	c1 ea 16             	shr    $0x16,%edx
  801c6c:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c73:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c78:	f6 c1 01             	test   $0x1,%cl
  801c7b:	74 1c                	je     801c99 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c7d:	c1 e8 0c             	shr    $0xc,%eax
  801c80:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c87:	a8 01                	test   $0x1,%al
  801c89:	74 0e                	je     801c99 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c8b:	c1 e8 0c             	shr    $0xc,%eax
  801c8e:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c95:	ef 
  801c96:	0f b7 d2             	movzwl %dx,%edx
}
  801c99:	89 d0                	mov    %edx,%eax
  801c9b:	5d                   	pop    %ebp
  801c9c:	c3                   	ret    
  801c9d:	66 90                	xchg   %ax,%ax
  801c9f:	90                   	nop

00801ca0 <__udivdi3>:
  801ca0:	f3 0f 1e fb          	endbr32 
  801ca4:	55                   	push   %ebp
  801ca5:	57                   	push   %edi
  801ca6:	56                   	push   %esi
  801ca7:	53                   	push   %ebx
  801ca8:	83 ec 1c             	sub    $0x1c,%esp
  801cab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801caf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801cb3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cb7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801cbb:	85 d2                	test   %edx,%edx
  801cbd:	75 19                	jne    801cd8 <__udivdi3+0x38>
  801cbf:	39 f3                	cmp    %esi,%ebx
  801cc1:	76 4d                	jbe    801d10 <__udivdi3+0x70>
  801cc3:	31 ff                	xor    %edi,%edi
  801cc5:	89 e8                	mov    %ebp,%eax
  801cc7:	89 f2                	mov    %esi,%edx
  801cc9:	f7 f3                	div    %ebx
  801ccb:	89 fa                	mov    %edi,%edx
  801ccd:	83 c4 1c             	add    $0x1c,%esp
  801cd0:	5b                   	pop    %ebx
  801cd1:	5e                   	pop    %esi
  801cd2:	5f                   	pop    %edi
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    
  801cd5:	8d 76 00             	lea    0x0(%esi),%esi
  801cd8:	39 f2                	cmp    %esi,%edx
  801cda:	76 14                	jbe    801cf0 <__udivdi3+0x50>
  801cdc:	31 ff                	xor    %edi,%edi
  801cde:	31 c0                	xor    %eax,%eax
  801ce0:	89 fa                	mov    %edi,%edx
  801ce2:	83 c4 1c             	add    $0x1c,%esp
  801ce5:	5b                   	pop    %ebx
  801ce6:	5e                   	pop    %esi
  801ce7:	5f                   	pop    %edi
  801ce8:	5d                   	pop    %ebp
  801ce9:	c3                   	ret    
  801cea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cf0:	0f bd fa             	bsr    %edx,%edi
  801cf3:	83 f7 1f             	xor    $0x1f,%edi
  801cf6:	75 48                	jne    801d40 <__udivdi3+0xa0>
  801cf8:	39 f2                	cmp    %esi,%edx
  801cfa:	72 06                	jb     801d02 <__udivdi3+0x62>
  801cfc:	31 c0                	xor    %eax,%eax
  801cfe:	39 eb                	cmp    %ebp,%ebx
  801d00:	77 de                	ja     801ce0 <__udivdi3+0x40>
  801d02:	b8 01 00 00 00       	mov    $0x1,%eax
  801d07:	eb d7                	jmp    801ce0 <__udivdi3+0x40>
  801d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d10:	89 d9                	mov    %ebx,%ecx
  801d12:	85 db                	test   %ebx,%ebx
  801d14:	75 0b                	jne    801d21 <__udivdi3+0x81>
  801d16:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1b:	31 d2                	xor    %edx,%edx
  801d1d:	f7 f3                	div    %ebx
  801d1f:	89 c1                	mov    %eax,%ecx
  801d21:	31 d2                	xor    %edx,%edx
  801d23:	89 f0                	mov    %esi,%eax
  801d25:	f7 f1                	div    %ecx
  801d27:	89 c6                	mov    %eax,%esi
  801d29:	89 e8                	mov    %ebp,%eax
  801d2b:	89 f7                	mov    %esi,%edi
  801d2d:	f7 f1                	div    %ecx
  801d2f:	89 fa                	mov    %edi,%edx
  801d31:	83 c4 1c             	add    $0x1c,%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    
  801d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d40:	89 f9                	mov    %edi,%ecx
  801d42:	b8 20 00 00 00       	mov    $0x20,%eax
  801d47:	29 f8                	sub    %edi,%eax
  801d49:	d3 e2                	shl    %cl,%edx
  801d4b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d4f:	89 c1                	mov    %eax,%ecx
  801d51:	89 da                	mov    %ebx,%edx
  801d53:	d3 ea                	shr    %cl,%edx
  801d55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d59:	09 d1                	or     %edx,%ecx
  801d5b:	89 f2                	mov    %esi,%edx
  801d5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d61:	89 f9                	mov    %edi,%ecx
  801d63:	d3 e3                	shl    %cl,%ebx
  801d65:	89 c1                	mov    %eax,%ecx
  801d67:	d3 ea                	shr    %cl,%edx
  801d69:	89 f9                	mov    %edi,%ecx
  801d6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d6f:	89 eb                	mov    %ebp,%ebx
  801d71:	d3 e6                	shl    %cl,%esi
  801d73:	89 c1                	mov    %eax,%ecx
  801d75:	d3 eb                	shr    %cl,%ebx
  801d77:	09 de                	or     %ebx,%esi
  801d79:	89 f0                	mov    %esi,%eax
  801d7b:	f7 74 24 08          	divl   0x8(%esp)
  801d7f:	89 d6                	mov    %edx,%esi
  801d81:	89 c3                	mov    %eax,%ebx
  801d83:	f7 64 24 0c          	mull   0xc(%esp)
  801d87:	39 d6                	cmp    %edx,%esi
  801d89:	72 15                	jb     801da0 <__udivdi3+0x100>
  801d8b:	89 f9                	mov    %edi,%ecx
  801d8d:	d3 e5                	shl    %cl,%ebp
  801d8f:	39 c5                	cmp    %eax,%ebp
  801d91:	73 04                	jae    801d97 <__udivdi3+0xf7>
  801d93:	39 d6                	cmp    %edx,%esi
  801d95:	74 09                	je     801da0 <__udivdi3+0x100>
  801d97:	89 d8                	mov    %ebx,%eax
  801d99:	31 ff                	xor    %edi,%edi
  801d9b:	e9 40 ff ff ff       	jmp    801ce0 <__udivdi3+0x40>
  801da0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801da3:	31 ff                	xor    %edi,%edi
  801da5:	e9 36 ff ff ff       	jmp    801ce0 <__udivdi3+0x40>
  801daa:	66 90                	xchg   %ax,%ax
  801dac:	66 90                	xchg   %ax,%ax
  801dae:	66 90                	xchg   %ax,%ax

00801db0 <__umoddi3>:
  801db0:	f3 0f 1e fb          	endbr32 
  801db4:	55                   	push   %ebp
  801db5:	57                   	push   %edi
  801db6:	56                   	push   %esi
  801db7:	53                   	push   %ebx
  801db8:	83 ec 1c             	sub    $0x1c,%esp
  801dbb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801dbf:	8b 74 24 30          	mov    0x30(%esp),%esi
  801dc3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801dc7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	75 19                	jne    801de8 <__umoddi3+0x38>
  801dcf:	39 df                	cmp    %ebx,%edi
  801dd1:	76 5d                	jbe    801e30 <__umoddi3+0x80>
  801dd3:	89 f0                	mov    %esi,%eax
  801dd5:	89 da                	mov    %ebx,%edx
  801dd7:	f7 f7                	div    %edi
  801dd9:	89 d0                	mov    %edx,%eax
  801ddb:	31 d2                	xor    %edx,%edx
  801ddd:	83 c4 1c             	add    $0x1c,%esp
  801de0:	5b                   	pop    %ebx
  801de1:	5e                   	pop    %esi
  801de2:	5f                   	pop    %edi
  801de3:	5d                   	pop    %ebp
  801de4:	c3                   	ret    
  801de5:	8d 76 00             	lea    0x0(%esi),%esi
  801de8:	89 f2                	mov    %esi,%edx
  801dea:	39 d8                	cmp    %ebx,%eax
  801dec:	76 12                	jbe    801e00 <__umoddi3+0x50>
  801dee:	89 f0                	mov    %esi,%eax
  801df0:	89 da                	mov    %ebx,%edx
  801df2:	83 c4 1c             	add    $0x1c,%esp
  801df5:	5b                   	pop    %ebx
  801df6:	5e                   	pop    %esi
  801df7:	5f                   	pop    %edi
  801df8:	5d                   	pop    %ebp
  801df9:	c3                   	ret    
  801dfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e00:	0f bd e8             	bsr    %eax,%ebp
  801e03:	83 f5 1f             	xor    $0x1f,%ebp
  801e06:	75 50                	jne    801e58 <__umoddi3+0xa8>
  801e08:	39 d8                	cmp    %ebx,%eax
  801e0a:	0f 82 e0 00 00 00    	jb     801ef0 <__umoddi3+0x140>
  801e10:	89 d9                	mov    %ebx,%ecx
  801e12:	39 f7                	cmp    %esi,%edi
  801e14:	0f 86 d6 00 00 00    	jbe    801ef0 <__umoddi3+0x140>
  801e1a:	89 d0                	mov    %edx,%eax
  801e1c:	89 ca                	mov    %ecx,%edx
  801e1e:	83 c4 1c             	add    $0x1c,%esp
  801e21:	5b                   	pop    %ebx
  801e22:	5e                   	pop    %esi
  801e23:	5f                   	pop    %edi
  801e24:	5d                   	pop    %ebp
  801e25:	c3                   	ret    
  801e26:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e2d:	8d 76 00             	lea    0x0(%esi),%esi
  801e30:	89 fd                	mov    %edi,%ebp
  801e32:	85 ff                	test   %edi,%edi
  801e34:	75 0b                	jne    801e41 <__umoddi3+0x91>
  801e36:	b8 01 00 00 00       	mov    $0x1,%eax
  801e3b:	31 d2                	xor    %edx,%edx
  801e3d:	f7 f7                	div    %edi
  801e3f:	89 c5                	mov    %eax,%ebp
  801e41:	89 d8                	mov    %ebx,%eax
  801e43:	31 d2                	xor    %edx,%edx
  801e45:	f7 f5                	div    %ebp
  801e47:	89 f0                	mov    %esi,%eax
  801e49:	f7 f5                	div    %ebp
  801e4b:	89 d0                	mov    %edx,%eax
  801e4d:	31 d2                	xor    %edx,%edx
  801e4f:	eb 8c                	jmp    801ddd <__umoddi3+0x2d>
  801e51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e58:	89 e9                	mov    %ebp,%ecx
  801e5a:	ba 20 00 00 00       	mov    $0x20,%edx
  801e5f:	29 ea                	sub    %ebp,%edx
  801e61:	d3 e0                	shl    %cl,%eax
  801e63:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e67:	89 d1                	mov    %edx,%ecx
  801e69:	89 f8                	mov    %edi,%eax
  801e6b:	d3 e8                	shr    %cl,%eax
  801e6d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e71:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e75:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e79:	09 c1                	or     %eax,%ecx
  801e7b:	89 d8                	mov    %ebx,%eax
  801e7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e81:	89 e9                	mov    %ebp,%ecx
  801e83:	d3 e7                	shl    %cl,%edi
  801e85:	89 d1                	mov    %edx,%ecx
  801e87:	d3 e8                	shr    %cl,%eax
  801e89:	89 e9                	mov    %ebp,%ecx
  801e8b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e8f:	d3 e3                	shl    %cl,%ebx
  801e91:	89 c7                	mov    %eax,%edi
  801e93:	89 d1                	mov    %edx,%ecx
  801e95:	89 f0                	mov    %esi,%eax
  801e97:	d3 e8                	shr    %cl,%eax
  801e99:	89 e9                	mov    %ebp,%ecx
  801e9b:	89 fa                	mov    %edi,%edx
  801e9d:	d3 e6                	shl    %cl,%esi
  801e9f:	09 d8                	or     %ebx,%eax
  801ea1:	f7 74 24 08          	divl   0x8(%esp)
  801ea5:	89 d1                	mov    %edx,%ecx
  801ea7:	89 f3                	mov    %esi,%ebx
  801ea9:	f7 64 24 0c          	mull   0xc(%esp)
  801ead:	89 c6                	mov    %eax,%esi
  801eaf:	89 d7                	mov    %edx,%edi
  801eb1:	39 d1                	cmp    %edx,%ecx
  801eb3:	72 06                	jb     801ebb <__umoddi3+0x10b>
  801eb5:	75 10                	jne    801ec7 <__umoddi3+0x117>
  801eb7:	39 c3                	cmp    %eax,%ebx
  801eb9:	73 0c                	jae    801ec7 <__umoddi3+0x117>
  801ebb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801ebf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801ec3:	89 d7                	mov    %edx,%edi
  801ec5:	89 c6                	mov    %eax,%esi
  801ec7:	89 ca                	mov    %ecx,%edx
  801ec9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801ece:	29 f3                	sub    %esi,%ebx
  801ed0:	19 fa                	sbb    %edi,%edx
  801ed2:	89 d0                	mov    %edx,%eax
  801ed4:	d3 e0                	shl    %cl,%eax
  801ed6:	89 e9                	mov    %ebp,%ecx
  801ed8:	d3 eb                	shr    %cl,%ebx
  801eda:	d3 ea                	shr    %cl,%edx
  801edc:	09 d8                	or     %ebx,%eax
  801ede:	83 c4 1c             	add    $0x1c,%esp
  801ee1:	5b                   	pop    %ebx
  801ee2:	5e                   	pop    %esi
  801ee3:	5f                   	pop    %edi
  801ee4:	5d                   	pop    %ebp
  801ee5:	c3                   	ret    
  801ee6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801eed:	8d 76 00             	lea    0x0(%esi),%esi
  801ef0:	29 fe                	sub    %edi,%esi
  801ef2:	19 c3                	sbb    %eax,%ebx
  801ef4:	89 f2                	mov    %esi,%edx
  801ef6:	89 d9                	mov    %ebx,%ecx
  801ef8:	e9 1d ff ff ff       	jmp    801e1a <__umoddi3+0x6a>
