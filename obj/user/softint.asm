
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	f3 0f 1e fb          	endbr32 
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800049:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800050:	00 00 00 
    envid_t envid = sys_getenvid();
  800053:	e8 de 00 00 00       	call   800136 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800058:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800060:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800065:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006a:	85 db                	test   %ebx,%ebx
  80006c:	7e 07                	jle    800075 <libmain+0x3b>
		binaryname = argv[0];
  80006e:	8b 06                	mov    (%esi),%eax
  800070:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800075:	83 ec 08             	sub    $0x8,%esp
  800078:	56                   	push   %esi
  800079:	53                   	push   %ebx
  80007a:	e8 b4 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007f:	e8 0a 00 00 00       	call   80008e <exit>
}
  800084:	83 c4 10             	add    $0x10,%esp
  800087:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008a:	5b                   	pop    %ebx
  80008b:	5e                   	pop    %esi
  80008c:	5d                   	pop    %ebp
  80008d:	c3                   	ret    

0080008e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008e:	f3 0f 1e fb          	endbr32 
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800098:	e8 df 04 00 00       	call   80057c <close_all>
	sys_env_destroy(0);
  80009d:	83 ec 0c             	sub    $0xc,%esp
  8000a0:	6a 00                	push   $0x0
  8000a2:	e8 4a 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	f3 0f 1e fb          	endbr32 
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c1:	89 c3                	mov    %eax,%ebx
  8000c3:	89 c7                	mov    %eax,%edi
  8000c5:	89 c6                	mov    %eax,%esi
  8000c7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5f                   	pop    %edi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    

008000ce <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ce:	f3 0f 1e fb          	endbr32 
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	f3 0f 1e fb          	endbr32 
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	57                   	push   %edi
  8000f9:	56                   	push   %esi
  8000fa:	53                   	push   %ebx
  8000fb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800103:	8b 55 08             	mov    0x8(%ebp),%edx
  800106:	b8 03 00 00 00       	mov    $0x3,%eax
  80010b:	89 cb                	mov    %ecx,%ebx
  80010d:	89 cf                	mov    %ecx,%edi
  80010f:	89 ce                	mov    %ecx,%esi
  800111:	cd 30                	int    $0x30
	if(check && ret > 0)
  800113:	85 c0                	test   %eax,%eax
  800115:	7f 08                	jg     80011f <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800117:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011a:	5b                   	pop    %ebx
  80011b:	5e                   	pop    %esi
  80011c:	5f                   	pop    %edi
  80011d:	5d                   	pop    %ebp
  80011e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80011f:	83 ec 0c             	sub    $0xc,%esp
  800122:	50                   	push   %eax
  800123:	6a 03                	push   $0x3
  800125:	68 ea 1e 80 00       	push   $0x801eea
  80012a:	6a 23                	push   $0x23
  80012c:	68 07 1f 80 00       	push   $0x801f07
  800131:	e8 9c 0f 00 00       	call   8010d2 <_panic>

00800136 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800136:	f3 0f 1e fb          	endbr32 
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	57                   	push   %edi
  80013e:	56                   	push   %esi
  80013f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800140:	ba 00 00 00 00       	mov    $0x0,%edx
  800145:	b8 02 00 00 00       	mov    $0x2,%eax
  80014a:	89 d1                	mov    %edx,%ecx
  80014c:	89 d3                	mov    %edx,%ebx
  80014e:	89 d7                	mov    %edx,%edi
  800150:	89 d6                	mov    %edx,%esi
  800152:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800154:	5b                   	pop    %ebx
  800155:	5e                   	pop    %esi
  800156:	5f                   	pop    %edi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    

00800159 <sys_yield>:

void
sys_yield(void)
{
  800159:	f3 0f 1e fb          	endbr32 
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	57                   	push   %edi
  800161:	56                   	push   %esi
  800162:	53                   	push   %ebx
	asm volatile("int %1\n"
  800163:	ba 00 00 00 00       	mov    $0x0,%edx
  800168:	b8 0b 00 00 00       	mov    $0xb,%eax
  80016d:	89 d1                	mov    %edx,%ecx
  80016f:	89 d3                	mov    %edx,%ebx
  800171:	89 d7                	mov    %edx,%edi
  800173:	89 d6                	mov    %edx,%esi
  800175:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800177:	5b                   	pop    %ebx
  800178:	5e                   	pop    %esi
  800179:	5f                   	pop    %edi
  80017a:	5d                   	pop    %ebp
  80017b:	c3                   	ret    

0080017c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80017c:	f3 0f 1e fb          	endbr32 
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800189:	be 00 00 00 00       	mov    $0x0,%esi
  80018e:	8b 55 08             	mov    0x8(%ebp),%edx
  800191:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800194:	b8 04 00 00 00       	mov    $0x4,%eax
  800199:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019c:	89 f7                	mov    %esi,%edi
  80019e:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001a0:	85 c0                	test   %eax,%eax
  8001a2:	7f 08                	jg     8001ac <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a7:	5b                   	pop    %ebx
  8001a8:	5e                   	pop    %esi
  8001a9:	5f                   	pop    %edi
  8001aa:	5d                   	pop    %ebp
  8001ab:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ac:	83 ec 0c             	sub    $0xc,%esp
  8001af:	50                   	push   %eax
  8001b0:	6a 04                	push   $0x4
  8001b2:	68 ea 1e 80 00       	push   $0x801eea
  8001b7:	6a 23                	push   $0x23
  8001b9:	68 07 1f 80 00       	push   $0x801f07
  8001be:	e8 0f 0f 00 00       	call   8010d2 <_panic>

008001c3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c3:	f3 0f 1e fb          	endbr32 
  8001c7:	55                   	push   %ebp
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	57                   	push   %edi
  8001cb:	56                   	push   %esi
  8001cc:	53                   	push   %ebx
  8001cd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001db:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001de:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e1:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001e6:	85 c0                	test   %eax,%eax
  8001e8:	7f 08                	jg     8001f2 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ed:	5b                   	pop    %ebx
  8001ee:	5e                   	pop    %esi
  8001ef:	5f                   	pop    %edi
  8001f0:	5d                   	pop    %ebp
  8001f1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f2:	83 ec 0c             	sub    $0xc,%esp
  8001f5:	50                   	push   %eax
  8001f6:	6a 05                	push   $0x5
  8001f8:	68 ea 1e 80 00       	push   $0x801eea
  8001fd:	6a 23                	push   $0x23
  8001ff:	68 07 1f 80 00       	push   $0x801f07
  800204:	e8 c9 0e 00 00       	call   8010d2 <_panic>

00800209 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800209:	f3 0f 1e fb          	endbr32 
  80020d:	55                   	push   %ebp
  80020e:	89 e5                	mov    %esp,%ebp
  800210:	57                   	push   %edi
  800211:	56                   	push   %esi
  800212:	53                   	push   %ebx
  800213:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800216:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021b:	8b 55 08             	mov    0x8(%ebp),%edx
  80021e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800221:	b8 06 00 00 00       	mov    $0x6,%eax
  800226:	89 df                	mov    %ebx,%edi
  800228:	89 de                	mov    %ebx,%esi
  80022a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80022c:	85 c0                	test   %eax,%eax
  80022e:	7f 08                	jg     800238 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800230:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800233:	5b                   	pop    %ebx
  800234:	5e                   	pop    %esi
  800235:	5f                   	pop    %edi
  800236:	5d                   	pop    %ebp
  800237:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800238:	83 ec 0c             	sub    $0xc,%esp
  80023b:	50                   	push   %eax
  80023c:	6a 06                	push   $0x6
  80023e:	68 ea 1e 80 00       	push   $0x801eea
  800243:	6a 23                	push   $0x23
  800245:	68 07 1f 80 00       	push   $0x801f07
  80024a:	e8 83 0e 00 00       	call   8010d2 <_panic>

0080024f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80024f:	f3 0f 1e fb          	endbr32 
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	57                   	push   %edi
  800257:	56                   	push   %esi
  800258:	53                   	push   %ebx
  800259:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80025c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800261:	8b 55 08             	mov    0x8(%ebp),%edx
  800264:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800267:	b8 08 00 00 00       	mov    $0x8,%eax
  80026c:	89 df                	mov    %ebx,%edi
  80026e:	89 de                	mov    %ebx,%esi
  800270:	cd 30                	int    $0x30
	if(check && ret > 0)
  800272:	85 c0                	test   %eax,%eax
  800274:	7f 08                	jg     80027e <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800276:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800279:	5b                   	pop    %ebx
  80027a:	5e                   	pop    %esi
  80027b:	5f                   	pop    %edi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	50                   	push   %eax
  800282:	6a 08                	push   $0x8
  800284:	68 ea 1e 80 00       	push   $0x801eea
  800289:	6a 23                	push   $0x23
  80028b:	68 07 1f 80 00       	push   $0x801f07
  800290:	e8 3d 0e 00 00       	call   8010d2 <_panic>

00800295 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800295:	f3 0f 1e fb          	endbr32 
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	57                   	push   %edi
  80029d:	56                   	push   %esi
  80029e:	53                   	push   %ebx
  80029f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ad:	b8 09 00 00 00       	mov    $0x9,%eax
  8002b2:	89 df                	mov    %ebx,%edi
  8002b4:	89 de                	mov    %ebx,%esi
  8002b6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002b8:	85 c0                	test   %eax,%eax
  8002ba:	7f 08                	jg     8002c4 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002bf:	5b                   	pop    %ebx
  8002c0:	5e                   	pop    %esi
  8002c1:	5f                   	pop    %edi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c4:	83 ec 0c             	sub    $0xc,%esp
  8002c7:	50                   	push   %eax
  8002c8:	6a 09                	push   $0x9
  8002ca:	68 ea 1e 80 00       	push   $0x801eea
  8002cf:	6a 23                	push   $0x23
  8002d1:	68 07 1f 80 00       	push   $0x801f07
  8002d6:	e8 f7 0d 00 00       	call   8010d2 <_panic>

008002db <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002db:	f3 0f 1e fb          	endbr32 
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	57                   	push   %edi
  8002e3:	56                   	push   %esi
  8002e4:	53                   	push   %ebx
  8002e5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002f8:	89 df                	mov    %ebx,%edi
  8002fa:	89 de                	mov    %ebx,%esi
  8002fc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002fe:	85 c0                	test   %eax,%eax
  800300:	7f 08                	jg     80030a <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800302:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	50                   	push   %eax
  80030e:	6a 0a                	push   $0xa
  800310:	68 ea 1e 80 00       	push   $0x801eea
  800315:	6a 23                	push   $0x23
  800317:	68 07 1f 80 00       	push   $0x801f07
  80031c:	e8 b1 0d 00 00       	call   8010d2 <_panic>

00800321 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800321:	f3 0f 1e fb          	endbr32 
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80032b:	8b 55 08             	mov    0x8(%ebp),%edx
  80032e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800331:	b8 0c 00 00 00       	mov    $0xc,%eax
  800336:	be 00 00 00 00       	mov    $0x0,%esi
  80033b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80033e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800341:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800343:	5b                   	pop    %ebx
  800344:	5e                   	pop    %esi
  800345:	5f                   	pop    %edi
  800346:	5d                   	pop    %ebp
  800347:	c3                   	ret    

00800348 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800348:	f3 0f 1e fb          	endbr32 
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	57                   	push   %edi
  800350:	56                   	push   %esi
  800351:	53                   	push   %ebx
  800352:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800355:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035a:	8b 55 08             	mov    0x8(%ebp),%edx
  80035d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800362:	89 cb                	mov    %ecx,%ebx
  800364:	89 cf                	mov    %ecx,%edi
  800366:	89 ce                	mov    %ecx,%esi
  800368:	cd 30                	int    $0x30
	if(check && ret > 0)
  80036a:	85 c0                	test   %eax,%eax
  80036c:	7f 08                	jg     800376 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800371:	5b                   	pop    %ebx
  800372:	5e                   	pop    %esi
  800373:	5f                   	pop    %edi
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	50                   	push   %eax
  80037a:	6a 0d                	push   $0xd
  80037c:	68 ea 1e 80 00       	push   $0x801eea
  800381:	6a 23                	push   $0x23
  800383:	68 07 1f 80 00       	push   $0x801f07
  800388:	e8 45 0d 00 00       	call   8010d2 <_panic>

0080038d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80038d:	f3 0f 1e fb          	endbr32 
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800394:	8b 45 08             	mov    0x8(%ebp),%eax
  800397:	05 00 00 00 30       	add    $0x30000000,%eax
  80039c:	c1 e8 0c             	shr    $0xc,%eax
}
  80039f:	5d                   	pop    %ebp
  8003a0:	c3                   	ret    

008003a1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003a1:	f3 0f 1e fb          	endbr32 
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ab:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003b0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003b5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003bc:	f3 0f 1e fb          	endbr32 
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003c8:	89 c2                	mov    %eax,%edx
  8003ca:	c1 ea 16             	shr    $0x16,%edx
  8003cd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003d4:	f6 c2 01             	test   $0x1,%dl
  8003d7:	74 2d                	je     800406 <fd_alloc+0x4a>
  8003d9:	89 c2                	mov    %eax,%edx
  8003db:	c1 ea 0c             	shr    $0xc,%edx
  8003de:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003e5:	f6 c2 01             	test   $0x1,%dl
  8003e8:	74 1c                	je     800406 <fd_alloc+0x4a>
  8003ea:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003ef:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003f4:	75 d2                	jne    8003c8 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8003ff:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800404:	eb 0a                	jmp    800410 <fd_alloc+0x54>
			*fd_store = fd;
  800406:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800409:	89 01                	mov    %eax,(%ecx)
			return 0;
  80040b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    

00800412 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800412:	f3 0f 1e fb          	endbr32 
  800416:	55                   	push   %ebp
  800417:	89 e5                	mov    %esp,%ebp
  800419:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80041c:	83 f8 1f             	cmp    $0x1f,%eax
  80041f:	77 30                	ja     800451 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800421:	c1 e0 0c             	shl    $0xc,%eax
  800424:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800429:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80042f:	f6 c2 01             	test   $0x1,%dl
  800432:	74 24                	je     800458 <fd_lookup+0x46>
  800434:	89 c2                	mov    %eax,%edx
  800436:	c1 ea 0c             	shr    $0xc,%edx
  800439:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800440:	f6 c2 01             	test   $0x1,%dl
  800443:	74 1a                	je     80045f <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800445:	8b 55 0c             	mov    0xc(%ebp),%edx
  800448:	89 02                	mov    %eax,(%edx)
	return 0;
  80044a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80044f:	5d                   	pop    %ebp
  800450:	c3                   	ret    
		return -E_INVAL;
  800451:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800456:	eb f7                	jmp    80044f <fd_lookup+0x3d>
		return -E_INVAL;
  800458:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80045d:	eb f0                	jmp    80044f <fd_lookup+0x3d>
  80045f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800464:	eb e9                	jmp    80044f <fd_lookup+0x3d>

00800466 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800466:	f3 0f 1e fb          	endbr32 
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800473:	ba 94 1f 80 00       	mov    $0x801f94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800478:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80047d:	39 08                	cmp    %ecx,(%eax)
  80047f:	74 33                	je     8004b4 <dev_lookup+0x4e>
  800481:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800484:	8b 02                	mov    (%edx),%eax
  800486:	85 c0                	test   %eax,%eax
  800488:	75 f3                	jne    80047d <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80048a:	a1 04 40 80 00       	mov    0x804004,%eax
  80048f:	8b 40 48             	mov    0x48(%eax),%eax
  800492:	83 ec 04             	sub    $0x4,%esp
  800495:	51                   	push   %ecx
  800496:	50                   	push   %eax
  800497:	68 18 1f 80 00       	push   $0x801f18
  80049c:	e8 18 0d 00 00       	call   8011b9 <cprintf>
	*dev = 0;
  8004a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004aa:	83 c4 10             	add    $0x10,%esp
  8004ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004b2:	c9                   	leave  
  8004b3:	c3                   	ret    
			*dev = devtab[i];
  8004b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004b7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004be:	eb f2                	jmp    8004b2 <dev_lookup+0x4c>

008004c0 <fd_close>:
{
  8004c0:	f3 0f 1e fb          	endbr32 
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
  8004c7:	57                   	push   %edi
  8004c8:	56                   	push   %esi
  8004c9:	53                   	push   %ebx
  8004ca:	83 ec 24             	sub    $0x24,%esp
  8004cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004d3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004d6:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004d7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004dd:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004e0:	50                   	push   %eax
  8004e1:	e8 2c ff ff ff       	call   800412 <fd_lookup>
  8004e6:	89 c3                	mov    %eax,%ebx
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	78 05                	js     8004f4 <fd_close+0x34>
	    || fd != fd2)
  8004ef:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004f2:	74 16                	je     80050a <fd_close+0x4a>
		return (must_exist ? r : 0);
  8004f4:	89 f8                	mov    %edi,%eax
  8004f6:	84 c0                	test   %al,%al
  8004f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fd:	0f 44 d8             	cmove  %eax,%ebx
}
  800500:	89 d8                	mov    %ebx,%eax
  800502:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800505:	5b                   	pop    %ebx
  800506:	5e                   	pop    %esi
  800507:	5f                   	pop    %edi
  800508:	5d                   	pop    %ebp
  800509:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800510:	50                   	push   %eax
  800511:	ff 36                	pushl  (%esi)
  800513:	e8 4e ff ff ff       	call   800466 <dev_lookup>
  800518:	89 c3                	mov    %eax,%ebx
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	85 c0                	test   %eax,%eax
  80051f:	78 1a                	js     80053b <fd_close+0x7b>
		if (dev->dev_close)
  800521:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800524:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800527:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80052c:	85 c0                	test   %eax,%eax
  80052e:	74 0b                	je     80053b <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800530:	83 ec 0c             	sub    $0xc,%esp
  800533:	56                   	push   %esi
  800534:	ff d0                	call   *%eax
  800536:	89 c3                	mov    %eax,%ebx
  800538:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	56                   	push   %esi
  80053f:	6a 00                	push   $0x0
  800541:	e8 c3 fc ff ff       	call   800209 <sys_page_unmap>
	return r;
  800546:	83 c4 10             	add    $0x10,%esp
  800549:	eb b5                	jmp    800500 <fd_close+0x40>

0080054b <close>:

int
close(int fdnum)
{
  80054b:	f3 0f 1e fb          	endbr32 
  80054f:	55                   	push   %ebp
  800550:	89 e5                	mov    %esp,%ebp
  800552:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800555:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800558:	50                   	push   %eax
  800559:	ff 75 08             	pushl  0x8(%ebp)
  80055c:	e8 b1 fe ff ff       	call   800412 <fd_lookup>
  800561:	83 c4 10             	add    $0x10,%esp
  800564:	85 c0                	test   %eax,%eax
  800566:	79 02                	jns    80056a <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800568:	c9                   	leave  
  800569:	c3                   	ret    
		return fd_close(fd, 1);
  80056a:	83 ec 08             	sub    $0x8,%esp
  80056d:	6a 01                	push   $0x1
  80056f:	ff 75 f4             	pushl  -0xc(%ebp)
  800572:	e8 49 ff ff ff       	call   8004c0 <fd_close>
  800577:	83 c4 10             	add    $0x10,%esp
  80057a:	eb ec                	jmp    800568 <close+0x1d>

0080057c <close_all>:

void
close_all(void)
{
  80057c:	f3 0f 1e fb          	endbr32 
  800580:	55                   	push   %ebp
  800581:	89 e5                	mov    %esp,%ebp
  800583:	53                   	push   %ebx
  800584:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800587:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80058c:	83 ec 0c             	sub    $0xc,%esp
  80058f:	53                   	push   %ebx
  800590:	e8 b6 ff ff ff       	call   80054b <close>
	for (i = 0; i < MAXFD; i++)
  800595:	83 c3 01             	add    $0x1,%ebx
  800598:	83 c4 10             	add    $0x10,%esp
  80059b:	83 fb 20             	cmp    $0x20,%ebx
  80059e:	75 ec                	jne    80058c <close_all+0x10>
}
  8005a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005a3:	c9                   	leave  
  8005a4:	c3                   	ret    

008005a5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005a5:	f3 0f 1e fb          	endbr32 
  8005a9:	55                   	push   %ebp
  8005aa:	89 e5                	mov    %esp,%ebp
  8005ac:	57                   	push   %edi
  8005ad:	56                   	push   %esi
  8005ae:	53                   	push   %ebx
  8005af:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005b2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005b5:	50                   	push   %eax
  8005b6:	ff 75 08             	pushl  0x8(%ebp)
  8005b9:	e8 54 fe ff ff       	call   800412 <fd_lookup>
  8005be:	89 c3                	mov    %eax,%ebx
  8005c0:	83 c4 10             	add    $0x10,%esp
  8005c3:	85 c0                	test   %eax,%eax
  8005c5:	0f 88 81 00 00 00    	js     80064c <dup+0xa7>
		return r;
	close(newfdnum);
  8005cb:	83 ec 0c             	sub    $0xc,%esp
  8005ce:	ff 75 0c             	pushl  0xc(%ebp)
  8005d1:	e8 75 ff ff ff       	call   80054b <close>

	newfd = INDEX2FD(newfdnum);
  8005d6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005d9:	c1 e6 0c             	shl    $0xc,%esi
  8005dc:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005e2:	83 c4 04             	add    $0x4,%esp
  8005e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005e8:	e8 b4 fd ff ff       	call   8003a1 <fd2data>
  8005ed:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005ef:	89 34 24             	mov    %esi,(%esp)
  8005f2:	e8 aa fd ff ff       	call   8003a1 <fd2data>
  8005f7:	83 c4 10             	add    $0x10,%esp
  8005fa:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005fc:	89 d8                	mov    %ebx,%eax
  8005fe:	c1 e8 16             	shr    $0x16,%eax
  800601:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800608:	a8 01                	test   $0x1,%al
  80060a:	74 11                	je     80061d <dup+0x78>
  80060c:	89 d8                	mov    %ebx,%eax
  80060e:	c1 e8 0c             	shr    $0xc,%eax
  800611:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800618:	f6 c2 01             	test   $0x1,%dl
  80061b:	75 39                	jne    800656 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80061d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800620:	89 d0                	mov    %edx,%eax
  800622:	c1 e8 0c             	shr    $0xc,%eax
  800625:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80062c:	83 ec 0c             	sub    $0xc,%esp
  80062f:	25 07 0e 00 00       	and    $0xe07,%eax
  800634:	50                   	push   %eax
  800635:	56                   	push   %esi
  800636:	6a 00                	push   $0x0
  800638:	52                   	push   %edx
  800639:	6a 00                	push   $0x0
  80063b:	e8 83 fb ff ff       	call   8001c3 <sys_page_map>
  800640:	89 c3                	mov    %eax,%ebx
  800642:	83 c4 20             	add    $0x20,%esp
  800645:	85 c0                	test   %eax,%eax
  800647:	78 31                	js     80067a <dup+0xd5>
		goto err;

	return newfdnum;
  800649:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80064c:	89 d8                	mov    %ebx,%eax
  80064e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800651:	5b                   	pop    %ebx
  800652:	5e                   	pop    %esi
  800653:	5f                   	pop    %edi
  800654:	5d                   	pop    %ebp
  800655:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800656:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80065d:	83 ec 0c             	sub    $0xc,%esp
  800660:	25 07 0e 00 00       	and    $0xe07,%eax
  800665:	50                   	push   %eax
  800666:	57                   	push   %edi
  800667:	6a 00                	push   $0x0
  800669:	53                   	push   %ebx
  80066a:	6a 00                	push   $0x0
  80066c:	e8 52 fb ff ff       	call   8001c3 <sys_page_map>
  800671:	89 c3                	mov    %eax,%ebx
  800673:	83 c4 20             	add    $0x20,%esp
  800676:	85 c0                	test   %eax,%eax
  800678:	79 a3                	jns    80061d <dup+0x78>
	sys_page_unmap(0, newfd);
  80067a:	83 ec 08             	sub    $0x8,%esp
  80067d:	56                   	push   %esi
  80067e:	6a 00                	push   $0x0
  800680:	e8 84 fb ff ff       	call   800209 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800685:	83 c4 08             	add    $0x8,%esp
  800688:	57                   	push   %edi
  800689:	6a 00                	push   $0x0
  80068b:	e8 79 fb ff ff       	call   800209 <sys_page_unmap>
	return r;
  800690:	83 c4 10             	add    $0x10,%esp
  800693:	eb b7                	jmp    80064c <dup+0xa7>

00800695 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800695:	f3 0f 1e fb          	endbr32 
  800699:	55                   	push   %ebp
  80069a:	89 e5                	mov    %esp,%ebp
  80069c:	53                   	push   %ebx
  80069d:	83 ec 1c             	sub    $0x1c,%esp
  8006a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006a6:	50                   	push   %eax
  8006a7:	53                   	push   %ebx
  8006a8:	e8 65 fd ff ff       	call   800412 <fd_lookup>
  8006ad:	83 c4 10             	add    $0x10,%esp
  8006b0:	85 c0                	test   %eax,%eax
  8006b2:	78 3f                	js     8006f3 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006ba:	50                   	push   %eax
  8006bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006be:	ff 30                	pushl  (%eax)
  8006c0:	e8 a1 fd ff ff       	call   800466 <dev_lookup>
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	85 c0                	test   %eax,%eax
  8006ca:	78 27                	js     8006f3 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006cf:	8b 42 08             	mov    0x8(%edx),%eax
  8006d2:	83 e0 03             	and    $0x3,%eax
  8006d5:	83 f8 01             	cmp    $0x1,%eax
  8006d8:	74 1e                	je     8006f8 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006dd:	8b 40 08             	mov    0x8(%eax),%eax
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	74 35                	je     800719 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006e4:	83 ec 04             	sub    $0x4,%esp
  8006e7:	ff 75 10             	pushl  0x10(%ebp)
  8006ea:	ff 75 0c             	pushl  0xc(%ebp)
  8006ed:	52                   	push   %edx
  8006ee:	ff d0                	call   *%eax
  8006f0:	83 c4 10             	add    $0x10,%esp
}
  8006f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f6:	c9                   	leave  
  8006f7:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8006fd:	8b 40 48             	mov    0x48(%eax),%eax
  800700:	83 ec 04             	sub    $0x4,%esp
  800703:	53                   	push   %ebx
  800704:	50                   	push   %eax
  800705:	68 59 1f 80 00       	push   $0x801f59
  80070a:	e8 aa 0a 00 00       	call   8011b9 <cprintf>
		return -E_INVAL;
  80070f:	83 c4 10             	add    $0x10,%esp
  800712:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800717:	eb da                	jmp    8006f3 <read+0x5e>
		return -E_NOT_SUPP;
  800719:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80071e:	eb d3                	jmp    8006f3 <read+0x5e>

00800720 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800720:	f3 0f 1e fb          	endbr32 
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	57                   	push   %edi
  800728:	56                   	push   %esi
  800729:	53                   	push   %ebx
  80072a:	83 ec 0c             	sub    $0xc,%esp
  80072d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800730:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800733:	bb 00 00 00 00       	mov    $0x0,%ebx
  800738:	eb 02                	jmp    80073c <readn+0x1c>
  80073a:	01 c3                	add    %eax,%ebx
  80073c:	39 f3                	cmp    %esi,%ebx
  80073e:	73 21                	jae    800761 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800740:	83 ec 04             	sub    $0x4,%esp
  800743:	89 f0                	mov    %esi,%eax
  800745:	29 d8                	sub    %ebx,%eax
  800747:	50                   	push   %eax
  800748:	89 d8                	mov    %ebx,%eax
  80074a:	03 45 0c             	add    0xc(%ebp),%eax
  80074d:	50                   	push   %eax
  80074e:	57                   	push   %edi
  80074f:	e8 41 ff ff ff       	call   800695 <read>
		if (m < 0)
  800754:	83 c4 10             	add    $0x10,%esp
  800757:	85 c0                	test   %eax,%eax
  800759:	78 04                	js     80075f <readn+0x3f>
			return m;
		if (m == 0)
  80075b:	75 dd                	jne    80073a <readn+0x1a>
  80075d:	eb 02                	jmp    800761 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80075f:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800761:	89 d8                	mov    %ebx,%eax
  800763:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800766:	5b                   	pop    %ebx
  800767:	5e                   	pop    %esi
  800768:	5f                   	pop    %edi
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80076b:	f3 0f 1e fb          	endbr32 
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	53                   	push   %ebx
  800773:	83 ec 1c             	sub    $0x1c,%esp
  800776:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800779:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80077c:	50                   	push   %eax
  80077d:	53                   	push   %ebx
  80077e:	e8 8f fc ff ff       	call   800412 <fd_lookup>
  800783:	83 c4 10             	add    $0x10,%esp
  800786:	85 c0                	test   %eax,%eax
  800788:	78 3a                	js     8007c4 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80078a:	83 ec 08             	sub    $0x8,%esp
  80078d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800790:	50                   	push   %eax
  800791:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800794:	ff 30                	pushl  (%eax)
  800796:	e8 cb fc ff ff       	call   800466 <dev_lookup>
  80079b:	83 c4 10             	add    $0x10,%esp
  80079e:	85 c0                	test   %eax,%eax
  8007a0:	78 22                	js     8007c4 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007a5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007a9:	74 1e                	je     8007c9 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007ae:	8b 52 0c             	mov    0xc(%edx),%edx
  8007b1:	85 d2                	test   %edx,%edx
  8007b3:	74 35                	je     8007ea <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007b5:	83 ec 04             	sub    $0x4,%esp
  8007b8:	ff 75 10             	pushl  0x10(%ebp)
  8007bb:	ff 75 0c             	pushl  0xc(%ebp)
  8007be:	50                   	push   %eax
  8007bf:	ff d2                	call   *%edx
  8007c1:	83 c4 10             	add    $0x10,%esp
}
  8007c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007c9:	a1 04 40 80 00       	mov    0x804004,%eax
  8007ce:	8b 40 48             	mov    0x48(%eax),%eax
  8007d1:	83 ec 04             	sub    $0x4,%esp
  8007d4:	53                   	push   %ebx
  8007d5:	50                   	push   %eax
  8007d6:	68 75 1f 80 00       	push   $0x801f75
  8007db:	e8 d9 09 00 00       	call   8011b9 <cprintf>
		return -E_INVAL;
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e8:	eb da                	jmp    8007c4 <write+0x59>
		return -E_NOT_SUPP;
  8007ea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007ef:	eb d3                	jmp    8007c4 <write+0x59>

008007f1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007f1:	f3 0f 1e fb          	endbr32 
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007fe:	50                   	push   %eax
  8007ff:	ff 75 08             	pushl  0x8(%ebp)
  800802:	e8 0b fc ff ff       	call   800412 <fd_lookup>
  800807:	83 c4 10             	add    $0x10,%esp
  80080a:	85 c0                	test   %eax,%eax
  80080c:	78 0e                	js     80081c <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80080e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800811:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800814:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800817:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081c:	c9                   	leave  
  80081d:	c3                   	ret    

0080081e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80081e:	f3 0f 1e fb          	endbr32 
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	53                   	push   %ebx
  800826:	83 ec 1c             	sub    $0x1c,%esp
  800829:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80082c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80082f:	50                   	push   %eax
  800830:	53                   	push   %ebx
  800831:	e8 dc fb ff ff       	call   800412 <fd_lookup>
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	85 c0                	test   %eax,%eax
  80083b:	78 37                	js     800874 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083d:	83 ec 08             	sub    $0x8,%esp
  800840:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800843:	50                   	push   %eax
  800844:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800847:	ff 30                	pushl  (%eax)
  800849:	e8 18 fc ff ff       	call   800466 <dev_lookup>
  80084e:	83 c4 10             	add    $0x10,%esp
  800851:	85 c0                	test   %eax,%eax
  800853:	78 1f                	js     800874 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800855:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800858:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80085c:	74 1b                	je     800879 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80085e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800861:	8b 52 18             	mov    0x18(%edx),%edx
  800864:	85 d2                	test   %edx,%edx
  800866:	74 32                	je     80089a <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800868:	83 ec 08             	sub    $0x8,%esp
  80086b:	ff 75 0c             	pushl  0xc(%ebp)
  80086e:	50                   	push   %eax
  80086f:	ff d2                	call   *%edx
  800871:	83 c4 10             	add    $0x10,%esp
}
  800874:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800877:	c9                   	leave  
  800878:	c3                   	ret    
			thisenv->env_id, fdnum);
  800879:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80087e:	8b 40 48             	mov    0x48(%eax),%eax
  800881:	83 ec 04             	sub    $0x4,%esp
  800884:	53                   	push   %ebx
  800885:	50                   	push   %eax
  800886:	68 38 1f 80 00       	push   $0x801f38
  80088b:	e8 29 09 00 00       	call   8011b9 <cprintf>
		return -E_INVAL;
  800890:	83 c4 10             	add    $0x10,%esp
  800893:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800898:	eb da                	jmp    800874 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80089a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80089f:	eb d3                	jmp    800874 <ftruncate+0x56>

008008a1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008a1:	f3 0f 1e fb          	endbr32 
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	53                   	push   %ebx
  8008a9:	83 ec 1c             	sub    $0x1c,%esp
  8008ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008b2:	50                   	push   %eax
  8008b3:	ff 75 08             	pushl  0x8(%ebp)
  8008b6:	e8 57 fb ff ff       	call   800412 <fd_lookup>
  8008bb:	83 c4 10             	add    $0x10,%esp
  8008be:	85 c0                	test   %eax,%eax
  8008c0:	78 4b                	js     80090d <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008c2:	83 ec 08             	sub    $0x8,%esp
  8008c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008c8:	50                   	push   %eax
  8008c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008cc:	ff 30                	pushl  (%eax)
  8008ce:	e8 93 fb ff ff       	call   800466 <dev_lookup>
  8008d3:	83 c4 10             	add    $0x10,%esp
  8008d6:	85 c0                	test   %eax,%eax
  8008d8:	78 33                	js     80090d <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8008da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008dd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008e1:	74 2f                	je     800912 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008e3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008e6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008ed:	00 00 00 
	stat->st_isdir = 0;
  8008f0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008f7:	00 00 00 
	stat->st_dev = dev;
  8008fa:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800900:	83 ec 08             	sub    $0x8,%esp
  800903:	53                   	push   %ebx
  800904:	ff 75 f0             	pushl  -0x10(%ebp)
  800907:	ff 50 14             	call   *0x14(%eax)
  80090a:	83 c4 10             	add    $0x10,%esp
}
  80090d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800910:	c9                   	leave  
  800911:	c3                   	ret    
		return -E_NOT_SUPP;
  800912:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800917:	eb f4                	jmp    80090d <fstat+0x6c>

00800919 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800919:	f3 0f 1e fb          	endbr32 
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	56                   	push   %esi
  800921:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800922:	83 ec 08             	sub    $0x8,%esp
  800925:	6a 00                	push   $0x0
  800927:	ff 75 08             	pushl  0x8(%ebp)
  80092a:	e8 fb 01 00 00       	call   800b2a <open>
  80092f:	89 c3                	mov    %eax,%ebx
  800931:	83 c4 10             	add    $0x10,%esp
  800934:	85 c0                	test   %eax,%eax
  800936:	78 1b                	js     800953 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  800938:	83 ec 08             	sub    $0x8,%esp
  80093b:	ff 75 0c             	pushl  0xc(%ebp)
  80093e:	50                   	push   %eax
  80093f:	e8 5d ff ff ff       	call   8008a1 <fstat>
  800944:	89 c6                	mov    %eax,%esi
	close(fd);
  800946:	89 1c 24             	mov    %ebx,(%esp)
  800949:	e8 fd fb ff ff       	call   80054b <close>
	return r;
  80094e:	83 c4 10             	add    $0x10,%esp
  800951:	89 f3                	mov    %esi,%ebx
}
  800953:	89 d8                	mov    %ebx,%eax
  800955:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800958:	5b                   	pop    %ebx
  800959:	5e                   	pop    %esi
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	56                   	push   %esi
  800960:	53                   	push   %ebx
  800961:	89 c6                	mov    %eax,%esi
  800963:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800965:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80096c:	74 27                	je     800995 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80096e:	6a 07                	push   $0x7
  800970:	68 00 50 80 00       	push   $0x805000
  800975:	56                   	push   %esi
  800976:	ff 35 00 40 80 00    	pushl  0x804000
  80097c:	e8 0a 12 00 00       	call   801b8b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800981:	83 c4 0c             	add    $0xc,%esp
  800984:	6a 00                	push   $0x0
  800986:	53                   	push   %ebx
  800987:	6a 00                	push   $0x0
  800989:	e8 a6 11 00 00       	call   801b34 <ipc_recv>
}
  80098e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800991:	5b                   	pop    %ebx
  800992:	5e                   	pop    %esi
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800995:	83 ec 0c             	sub    $0xc,%esp
  800998:	6a 01                	push   $0x1
  80099a:	e8 52 12 00 00       	call   801bf1 <ipc_find_env>
  80099f:	a3 00 40 80 00       	mov    %eax,0x804000
  8009a4:	83 c4 10             	add    $0x10,%esp
  8009a7:	eb c5                	jmp    80096e <fsipc+0x12>

008009a9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009a9:	f3 0f 1e fb          	endbr32 
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b6:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cb:	b8 02 00 00 00       	mov    $0x2,%eax
  8009d0:	e8 87 ff ff ff       	call   80095c <fsipc>
}
  8009d5:	c9                   	leave  
  8009d6:	c3                   	ret    

008009d7 <devfile_flush>:
{
  8009d7:	f3 0f 1e fb          	endbr32 
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8009f6:	e8 61 ff ff ff       	call   80095c <fsipc>
}
  8009fb:	c9                   	leave  
  8009fc:	c3                   	ret    

008009fd <devfile_stat>:
{
  8009fd:	f3 0f 1e fb          	endbr32 
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	53                   	push   %ebx
  800a05:	83 ec 04             	sub    $0x4,%esp
  800a08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a11:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a16:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1b:	b8 05 00 00 00       	mov    $0x5,%eax
  800a20:	e8 37 ff ff ff       	call   80095c <fsipc>
  800a25:	85 c0                	test   %eax,%eax
  800a27:	78 2c                	js     800a55 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a29:	83 ec 08             	sub    $0x8,%esp
  800a2c:	68 00 50 80 00       	push   $0x805000
  800a31:	53                   	push   %ebx
  800a32:	e8 8b 0d 00 00       	call   8017c2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a37:	a1 80 50 80 00       	mov    0x805080,%eax
  800a3c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a42:	a1 84 50 80 00       	mov    0x805084,%eax
  800a47:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a4d:	83 c4 10             	add    $0x10,%esp
  800a50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a58:	c9                   	leave  
  800a59:	c3                   	ret    

00800a5a <devfile_write>:
{
  800a5a:	f3 0f 1e fb          	endbr32 
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	83 ec 0c             	sub    $0xc,%esp
  800a64:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  800a67:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a6c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a71:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a74:	8b 55 08             	mov    0x8(%ebp),%edx
  800a77:	8b 52 0c             	mov    0xc(%edx),%edx
  800a7a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a80:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a85:	50                   	push   %eax
  800a86:	ff 75 0c             	pushl  0xc(%ebp)
  800a89:	68 08 50 80 00       	push   $0x805008
  800a8e:	e8 e5 0e 00 00       	call   801978 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a93:	ba 00 00 00 00       	mov    $0x0,%edx
  800a98:	b8 04 00 00 00       	mov    $0x4,%eax
  800a9d:	e8 ba fe ff ff       	call   80095c <fsipc>
}
  800aa2:	c9                   	leave  
  800aa3:	c3                   	ret    

00800aa4 <devfile_read>:
{
  800aa4:	f3 0f 1e fb          	endbr32 
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	56                   	push   %esi
  800aac:	53                   	push   %ebx
  800aad:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	8b 40 0c             	mov    0xc(%eax),%eax
  800ab6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800abb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ac1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac6:	b8 03 00 00 00       	mov    $0x3,%eax
  800acb:	e8 8c fe ff ff       	call   80095c <fsipc>
  800ad0:	89 c3                	mov    %eax,%ebx
  800ad2:	85 c0                	test   %eax,%eax
  800ad4:	78 1f                	js     800af5 <devfile_read+0x51>
	assert(r <= n);
  800ad6:	39 f0                	cmp    %esi,%eax
  800ad8:	77 24                	ja     800afe <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800ada:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800adf:	7f 33                	jg     800b14 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae1:	83 ec 04             	sub    $0x4,%esp
  800ae4:	50                   	push   %eax
  800ae5:	68 00 50 80 00       	push   $0x805000
  800aea:	ff 75 0c             	pushl  0xc(%ebp)
  800aed:	e8 86 0e 00 00       	call   801978 <memmove>
	return r;
  800af2:	83 c4 10             	add    $0x10,%esp
}
  800af5:	89 d8                	mov    %ebx,%eax
  800af7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    
	assert(r <= n);
  800afe:	68 a4 1f 80 00       	push   $0x801fa4
  800b03:	68 ab 1f 80 00       	push   $0x801fab
  800b08:	6a 7c                	push   $0x7c
  800b0a:	68 c0 1f 80 00       	push   $0x801fc0
  800b0f:	e8 be 05 00 00       	call   8010d2 <_panic>
	assert(r <= PGSIZE);
  800b14:	68 cb 1f 80 00       	push   $0x801fcb
  800b19:	68 ab 1f 80 00       	push   $0x801fab
  800b1e:	6a 7d                	push   $0x7d
  800b20:	68 c0 1f 80 00       	push   $0x801fc0
  800b25:	e8 a8 05 00 00       	call   8010d2 <_panic>

00800b2a <open>:
{
  800b2a:	f3 0f 1e fb          	endbr32 
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	83 ec 1c             	sub    $0x1c,%esp
  800b36:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b39:	56                   	push   %esi
  800b3a:	e8 40 0c 00 00       	call   80177f <strlen>
  800b3f:	83 c4 10             	add    $0x10,%esp
  800b42:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b47:	7f 6c                	jg     800bb5 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800b49:	83 ec 0c             	sub    $0xc,%esp
  800b4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b4f:	50                   	push   %eax
  800b50:	e8 67 f8 ff ff       	call   8003bc <fd_alloc>
  800b55:	89 c3                	mov    %eax,%ebx
  800b57:	83 c4 10             	add    $0x10,%esp
  800b5a:	85 c0                	test   %eax,%eax
  800b5c:	78 3c                	js     800b9a <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b5e:	83 ec 08             	sub    $0x8,%esp
  800b61:	56                   	push   %esi
  800b62:	68 00 50 80 00       	push   $0x805000
  800b67:	e8 56 0c 00 00       	call   8017c2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6f:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b74:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b77:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7c:	e8 db fd ff ff       	call   80095c <fsipc>
  800b81:	89 c3                	mov    %eax,%ebx
  800b83:	83 c4 10             	add    $0x10,%esp
  800b86:	85 c0                	test   %eax,%eax
  800b88:	78 19                	js     800ba3 <open+0x79>
	return fd2num(fd);
  800b8a:	83 ec 0c             	sub    $0xc,%esp
  800b8d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b90:	e8 f8 f7 ff ff       	call   80038d <fd2num>
  800b95:	89 c3                	mov    %eax,%ebx
  800b97:	83 c4 10             	add    $0x10,%esp
}
  800b9a:	89 d8                	mov    %ebx,%eax
  800b9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    
		fd_close(fd, 0);
  800ba3:	83 ec 08             	sub    $0x8,%esp
  800ba6:	6a 00                	push   $0x0
  800ba8:	ff 75 f4             	pushl  -0xc(%ebp)
  800bab:	e8 10 f9 ff ff       	call   8004c0 <fd_close>
		return r;
  800bb0:	83 c4 10             	add    $0x10,%esp
  800bb3:	eb e5                	jmp    800b9a <open+0x70>
		return -E_BAD_PATH;
  800bb5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800bba:	eb de                	jmp    800b9a <open+0x70>

00800bbc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bbc:	f3 0f 1e fb          	endbr32 
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcb:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd0:	e8 87 fd ff ff       	call   80095c <fsipc>
}
  800bd5:	c9                   	leave  
  800bd6:	c3                   	ret    

00800bd7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bd7:	f3 0f 1e fb          	endbr32 
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800be3:	83 ec 0c             	sub    $0xc,%esp
  800be6:	ff 75 08             	pushl  0x8(%ebp)
  800be9:	e8 b3 f7 ff ff       	call   8003a1 <fd2data>
  800bee:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bf0:	83 c4 08             	add    $0x8,%esp
  800bf3:	68 d7 1f 80 00       	push   $0x801fd7
  800bf8:	53                   	push   %ebx
  800bf9:	e8 c4 0b 00 00       	call   8017c2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bfe:	8b 46 04             	mov    0x4(%esi),%eax
  800c01:	2b 06                	sub    (%esi),%eax
  800c03:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800c09:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c10:	00 00 00 
	stat->st_dev = &devpipe;
  800c13:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c1a:	30 80 00 
	return 0;
}
  800c1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c29:	f3 0f 1e fb          	endbr32 
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	53                   	push   %ebx
  800c31:	83 ec 0c             	sub    $0xc,%esp
  800c34:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c37:	53                   	push   %ebx
  800c38:	6a 00                	push   $0x0
  800c3a:	e8 ca f5 ff ff       	call   800209 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c3f:	89 1c 24             	mov    %ebx,(%esp)
  800c42:	e8 5a f7 ff ff       	call   8003a1 <fd2data>
  800c47:	83 c4 08             	add    $0x8,%esp
  800c4a:	50                   	push   %eax
  800c4b:	6a 00                	push   $0x0
  800c4d:	e8 b7 f5 ff ff       	call   800209 <sys_page_unmap>
}
  800c52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c55:	c9                   	leave  
  800c56:	c3                   	ret    

00800c57 <_pipeisclosed>:
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 1c             	sub    $0x1c,%esp
  800c60:	89 c7                	mov    %eax,%edi
  800c62:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c64:	a1 04 40 80 00       	mov    0x804004,%eax
  800c69:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c6c:	83 ec 0c             	sub    $0xc,%esp
  800c6f:	57                   	push   %edi
  800c70:	e8 b9 0f 00 00       	call   801c2e <pageref>
  800c75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c78:	89 34 24             	mov    %esi,(%esp)
  800c7b:	e8 ae 0f 00 00       	call   801c2e <pageref>
		nn = thisenv->env_runs;
  800c80:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c86:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c89:	83 c4 10             	add    $0x10,%esp
  800c8c:	39 cb                	cmp    %ecx,%ebx
  800c8e:	74 1b                	je     800cab <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c90:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c93:	75 cf                	jne    800c64 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c95:	8b 42 58             	mov    0x58(%edx),%eax
  800c98:	6a 01                	push   $0x1
  800c9a:	50                   	push   %eax
  800c9b:	53                   	push   %ebx
  800c9c:	68 de 1f 80 00       	push   $0x801fde
  800ca1:	e8 13 05 00 00       	call   8011b9 <cprintf>
  800ca6:	83 c4 10             	add    $0x10,%esp
  800ca9:	eb b9                	jmp    800c64 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800cab:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800cae:	0f 94 c0             	sete   %al
  800cb1:	0f b6 c0             	movzbl %al,%eax
}
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <devpipe_write>:
{
  800cbc:	f3 0f 1e fb          	endbr32 
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	57                   	push   %edi
  800cc4:	56                   	push   %esi
  800cc5:	53                   	push   %ebx
  800cc6:	83 ec 28             	sub    $0x28,%esp
  800cc9:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800ccc:	56                   	push   %esi
  800ccd:	e8 cf f6 ff ff       	call   8003a1 <fd2data>
  800cd2:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cd4:	83 c4 10             	add    $0x10,%esp
  800cd7:	bf 00 00 00 00       	mov    $0x0,%edi
  800cdc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cdf:	74 4f                	je     800d30 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800ce1:	8b 43 04             	mov    0x4(%ebx),%eax
  800ce4:	8b 0b                	mov    (%ebx),%ecx
  800ce6:	8d 51 20             	lea    0x20(%ecx),%edx
  800ce9:	39 d0                	cmp    %edx,%eax
  800ceb:	72 14                	jb     800d01 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800ced:	89 da                	mov    %ebx,%edx
  800cef:	89 f0                	mov    %esi,%eax
  800cf1:	e8 61 ff ff ff       	call   800c57 <_pipeisclosed>
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	75 3b                	jne    800d35 <devpipe_write+0x79>
			sys_yield();
  800cfa:	e8 5a f4 ff ff       	call   800159 <sys_yield>
  800cff:	eb e0                	jmp    800ce1 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d04:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d08:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d0b:	89 c2                	mov    %eax,%edx
  800d0d:	c1 fa 1f             	sar    $0x1f,%edx
  800d10:	89 d1                	mov    %edx,%ecx
  800d12:	c1 e9 1b             	shr    $0x1b,%ecx
  800d15:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800d18:	83 e2 1f             	and    $0x1f,%edx
  800d1b:	29 ca                	sub    %ecx,%edx
  800d1d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800d21:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d25:	83 c0 01             	add    $0x1,%eax
  800d28:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800d2b:	83 c7 01             	add    $0x1,%edi
  800d2e:	eb ac                	jmp    800cdc <devpipe_write+0x20>
	return i;
  800d30:	8b 45 10             	mov    0x10(%ebp),%eax
  800d33:	eb 05                	jmp    800d3a <devpipe_write+0x7e>
				return 0;
  800d35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <devpipe_read>:
{
  800d42:	f3 0f 1e fb          	endbr32 
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	57                   	push   %edi
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
  800d4c:	83 ec 18             	sub    $0x18,%esp
  800d4f:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800d52:	57                   	push   %edi
  800d53:	e8 49 f6 ff ff       	call   8003a1 <fd2data>
  800d58:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d5a:	83 c4 10             	add    $0x10,%esp
  800d5d:	be 00 00 00 00       	mov    $0x0,%esi
  800d62:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d65:	75 14                	jne    800d7b <devpipe_read+0x39>
	return i;
  800d67:	8b 45 10             	mov    0x10(%ebp),%eax
  800d6a:	eb 02                	jmp    800d6e <devpipe_read+0x2c>
				return i;
  800d6c:	89 f0                	mov    %esi,%eax
}
  800d6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d71:	5b                   	pop    %ebx
  800d72:	5e                   	pop    %esi
  800d73:	5f                   	pop    %edi
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    
			sys_yield();
  800d76:	e8 de f3 ff ff       	call   800159 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d7b:	8b 03                	mov    (%ebx),%eax
  800d7d:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d80:	75 18                	jne    800d9a <devpipe_read+0x58>
			if (i > 0)
  800d82:	85 f6                	test   %esi,%esi
  800d84:	75 e6                	jne    800d6c <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d86:	89 da                	mov    %ebx,%edx
  800d88:	89 f8                	mov    %edi,%eax
  800d8a:	e8 c8 fe ff ff       	call   800c57 <_pipeisclosed>
  800d8f:	85 c0                	test   %eax,%eax
  800d91:	74 e3                	je     800d76 <devpipe_read+0x34>
				return 0;
  800d93:	b8 00 00 00 00       	mov    $0x0,%eax
  800d98:	eb d4                	jmp    800d6e <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d9a:	99                   	cltd   
  800d9b:	c1 ea 1b             	shr    $0x1b,%edx
  800d9e:	01 d0                	add    %edx,%eax
  800da0:	83 e0 1f             	and    $0x1f,%eax
  800da3:	29 d0                	sub    %edx,%eax
  800da5:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800daa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dad:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800db0:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800db3:	83 c6 01             	add    $0x1,%esi
  800db6:	eb aa                	jmp    800d62 <devpipe_read+0x20>

00800db8 <pipe>:
{
  800db8:	f3 0f 1e fb          	endbr32 
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	56                   	push   %esi
  800dc0:	53                   	push   %ebx
  800dc1:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800dc4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dc7:	50                   	push   %eax
  800dc8:	e8 ef f5 ff ff       	call   8003bc <fd_alloc>
  800dcd:	89 c3                	mov    %eax,%ebx
  800dcf:	83 c4 10             	add    $0x10,%esp
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	0f 88 23 01 00 00    	js     800efd <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dda:	83 ec 04             	sub    $0x4,%esp
  800ddd:	68 07 04 00 00       	push   $0x407
  800de2:	ff 75 f4             	pushl  -0xc(%ebp)
  800de5:	6a 00                	push   $0x0
  800de7:	e8 90 f3 ff ff       	call   80017c <sys_page_alloc>
  800dec:	89 c3                	mov    %eax,%ebx
  800dee:	83 c4 10             	add    $0x10,%esp
  800df1:	85 c0                	test   %eax,%eax
  800df3:	0f 88 04 01 00 00    	js     800efd <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800df9:	83 ec 0c             	sub    $0xc,%esp
  800dfc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dff:	50                   	push   %eax
  800e00:	e8 b7 f5 ff ff       	call   8003bc <fd_alloc>
  800e05:	89 c3                	mov    %eax,%ebx
  800e07:	83 c4 10             	add    $0x10,%esp
  800e0a:	85 c0                	test   %eax,%eax
  800e0c:	0f 88 db 00 00 00    	js     800eed <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e12:	83 ec 04             	sub    $0x4,%esp
  800e15:	68 07 04 00 00       	push   $0x407
  800e1a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e1d:	6a 00                	push   $0x0
  800e1f:	e8 58 f3 ff ff       	call   80017c <sys_page_alloc>
  800e24:	89 c3                	mov    %eax,%ebx
  800e26:	83 c4 10             	add    $0x10,%esp
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	0f 88 bc 00 00 00    	js     800eed <pipe+0x135>
	va = fd2data(fd0);
  800e31:	83 ec 0c             	sub    $0xc,%esp
  800e34:	ff 75 f4             	pushl  -0xc(%ebp)
  800e37:	e8 65 f5 ff ff       	call   8003a1 <fd2data>
  800e3c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e3e:	83 c4 0c             	add    $0xc,%esp
  800e41:	68 07 04 00 00       	push   $0x407
  800e46:	50                   	push   %eax
  800e47:	6a 00                	push   $0x0
  800e49:	e8 2e f3 ff ff       	call   80017c <sys_page_alloc>
  800e4e:	89 c3                	mov    %eax,%ebx
  800e50:	83 c4 10             	add    $0x10,%esp
  800e53:	85 c0                	test   %eax,%eax
  800e55:	0f 88 82 00 00 00    	js     800edd <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e5b:	83 ec 0c             	sub    $0xc,%esp
  800e5e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e61:	e8 3b f5 ff ff       	call   8003a1 <fd2data>
  800e66:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e6d:	50                   	push   %eax
  800e6e:	6a 00                	push   $0x0
  800e70:	56                   	push   %esi
  800e71:	6a 00                	push   $0x0
  800e73:	e8 4b f3 ff ff       	call   8001c3 <sys_page_map>
  800e78:	89 c3                	mov    %eax,%ebx
  800e7a:	83 c4 20             	add    $0x20,%esp
  800e7d:	85 c0                	test   %eax,%eax
  800e7f:	78 4e                	js     800ecf <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e81:	a1 20 30 80 00       	mov    0x803020,%eax
  800e86:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e89:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e8e:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e95:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e98:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e9d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800ea4:	83 ec 0c             	sub    $0xc,%esp
  800ea7:	ff 75 f4             	pushl  -0xc(%ebp)
  800eaa:	e8 de f4 ff ff       	call   80038d <fd2num>
  800eaf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800eb4:	83 c4 04             	add    $0x4,%esp
  800eb7:	ff 75 f0             	pushl  -0x10(%ebp)
  800eba:	e8 ce f4 ff ff       	call   80038d <fd2num>
  800ebf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800ec5:	83 c4 10             	add    $0x10,%esp
  800ec8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ecd:	eb 2e                	jmp    800efd <pipe+0x145>
	sys_page_unmap(0, va);
  800ecf:	83 ec 08             	sub    $0x8,%esp
  800ed2:	56                   	push   %esi
  800ed3:	6a 00                	push   $0x0
  800ed5:	e8 2f f3 ff ff       	call   800209 <sys_page_unmap>
  800eda:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800edd:	83 ec 08             	sub    $0x8,%esp
  800ee0:	ff 75 f0             	pushl  -0x10(%ebp)
  800ee3:	6a 00                	push   $0x0
  800ee5:	e8 1f f3 ff ff       	call   800209 <sys_page_unmap>
  800eea:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800eed:	83 ec 08             	sub    $0x8,%esp
  800ef0:	ff 75 f4             	pushl  -0xc(%ebp)
  800ef3:	6a 00                	push   $0x0
  800ef5:	e8 0f f3 ff ff       	call   800209 <sys_page_unmap>
  800efa:	83 c4 10             	add    $0x10,%esp
}
  800efd:	89 d8                	mov    %ebx,%eax
  800eff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5d                   	pop    %ebp
  800f05:	c3                   	ret    

00800f06 <pipeisclosed>:
{
  800f06:	f3 0f 1e fb          	endbr32 
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f13:	50                   	push   %eax
  800f14:	ff 75 08             	pushl  0x8(%ebp)
  800f17:	e8 f6 f4 ff ff       	call   800412 <fd_lookup>
  800f1c:	83 c4 10             	add    $0x10,%esp
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	78 18                	js     800f3b <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800f23:	83 ec 0c             	sub    $0xc,%esp
  800f26:	ff 75 f4             	pushl  -0xc(%ebp)
  800f29:	e8 73 f4 ff ff       	call   8003a1 <fd2data>
  800f2e:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f33:	e8 1f fd ff ff       	call   800c57 <_pipeisclosed>
  800f38:	83 c4 10             	add    $0x10,%esp
}
  800f3b:	c9                   	leave  
  800f3c:	c3                   	ret    

00800f3d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f3d:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800f41:	b8 00 00 00 00       	mov    $0x0,%eax
  800f46:	c3                   	ret    

00800f47 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f47:	f3 0f 1e fb          	endbr32 
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f51:	68 f6 1f 80 00       	push   $0x801ff6
  800f56:	ff 75 0c             	pushl  0xc(%ebp)
  800f59:	e8 64 08 00 00       	call   8017c2 <strcpy>
	return 0;
}
  800f5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f63:	c9                   	leave  
  800f64:	c3                   	ret    

00800f65 <devcons_write>:
{
  800f65:	f3 0f 1e fb          	endbr32 
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	57                   	push   %edi
  800f6d:	56                   	push   %esi
  800f6e:	53                   	push   %ebx
  800f6f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f75:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f7a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f80:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f83:	73 31                	jae    800fb6 <devcons_write+0x51>
		m = n - tot;
  800f85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f88:	29 f3                	sub    %esi,%ebx
  800f8a:	83 fb 7f             	cmp    $0x7f,%ebx
  800f8d:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f92:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f95:	83 ec 04             	sub    $0x4,%esp
  800f98:	53                   	push   %ebx
  800f99:	89 f0                	mov    %esi,%eax
  800f9b:	03 45 0c             	add    0xc(%ebp),%eax
  800f9e:	50                   	push   %eax
  800f9f:	57                   	push   %edi
  800fa0:	e8 d3 09 00 00       	call   801978 <memmove>
		sys_cputs(buf, m);
  800fa5:	83 c4 08             	add    $0x8,%esp
  800fa8:	53                   	push   %ebx
  800fa9:	57                   	push   %edi
  800faa:	e8 fd f0 ff ff       	call   8000ac <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800faf:	01 de                	add    %ebx,%esi
  800fb1:	83 c4 10             	add    $0x10,%esp
  800fb4:	eb ca                	jmp    800f80 <devcons_write+0x1b>
}
  800fb6:	89 f0                	mov    %esi,%eax
  800fb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fbb:	5b                   	pop    %ebx
  800fbc:	5e                   	pop    %esi
  800fbd:	5f                   	pop    %edi
  800fbe:	5d                   	pop    %ebp
  800fbf:	c3                   	ret    

00800fc0 <devcons_read>:
{
  800fc0:	f3 0f 1e fb          	endbr32 
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	83 ec 08             	sub    $0x8,%esp
  800fca:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800fcf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fd3:	74 21                	je     800ff6 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800fd5:	e8 f4 f0 ff ff       	call   8000ce <sys_cgetc>
  800fda:	85 c0                	test   %eax,%eax
  800fdc:	75 07                	jne    800fe5 <devcons_read+0x25>
		sys_yield();
  800fde:	e8 76 f1 ff ff       	call   800159 <sys_yield>
  800fe3:	eb f0                	jmp    800fd5 <devcons_read+0x15>
	if (c < 0)
  800fe5:	78 0f                	js     800ff6 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800fe7:	83 f8 04             	cmp    $0x4,%eax
  800fea:	74 0c                	je     800ff8 <devcons_read+0x38>
	*(char*)vbuf = c;
  800fec:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fef:	88 02                	mov    %al,(%edx)
	return 1;
  800ff1:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800ff6:	c9                   	leave  
  800ff7:	c3                   	ret    
		return 0;
  800ff8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffd:	eb f7                	jmp    800ff6 <devcons_read+0x36>

00800fff <cputchar>:
{
  800fff:	f3 0f 1e fb          	endbr32 
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801009:	8b 45 08             	mov    0x8(%ebp),%eax
  80100c:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80100f:	6a 01                	push   $0x1
  801011:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801014:	50                   	push   %eax
  801015:	e8 92 f0 ff ff       	call   8000ac <sys_cputs>
}
  80101a:	83 c4 10             	add    $0x10,%esp
  80101d:	c9                   	leave  
  80101e:	c3                   	ret    

0080101f <getchar>:
{
  80101f:	f3 0f 1e fb          	endbr32 
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801029:	6a 01                	push   $0x1
  80102b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80102e:	50                   	push   %eax
  80102f:	6a 00                	push   $0x0
  801031:	e8 5f f6 ff ff       	call   800695 <read>
	if (r < 0)
  801036:	83 c4 10             	add    $0x10,%esp
  801039:	85 c0                	test   %eax,%eax
  80103b:	78 06                	js     801043 <getchar+0x24>
	if (r < 1)
  80103d:	74 06                	je     801045 <getchar+0x26>
	return c;
  80103f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801043:	c9                   	leave  
  801044:	c3                   	ret    
		return -E_EOF;
  801045:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80104a:	eb f7                	jmp    801043 <getchar+0x24>

0080104c <iscons>:
{
  80104c:	f3 0f 1e fb          	endbr32 
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801056:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801059:	50                   	push   %eax
  80105a:	ff 75 08             	pushl  0x8(%ebp)
  80105d:	e8 b0 f3 ff ff       	call   800412 <fd_lookup>
  801062:	83 c4 10             	add    $0x10,%esp
  801065:	85 c0                	test   %eax,%eax
  801067:	78 11                	js     80107a <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801069:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80106c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801072:	39 10                	cmp    %edx,(%eax)
  801074:	0f 94 c0             	sete   %al
  801077:	0f b6 c0             	movzbl %al,%eax
}
  80107a:	c9                   	leave  
  80107b:	c3                   	ret    

0080107c <opencons>:
{
  80107c:	f3 0f 1e fb          	endbr32 
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801086:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801089:	50                   	push   %eax
  80108a:	e8 2d f3 ff ff       	call   8003bc <fd_alloc>
  80108f:	83 c4 10             	add    $0x10,%esp
  801092:	85 c0                	test   %eax,%eax
  801094:	78 3a                	js     8010d0 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801096:	83 ec 04             	sub    $0x4,%esp
  801099:	68 07 04 00 00       	push   $0x407
  80109e:	ff 75 f4             	pushl  -0xc(%ebp)
  8010a1:	6a 00                	push   $0x0
  8010a3:	e8 d4 f0 ff ff       	call   80017c <sys_page_alloc>
  8010a8:	83 c4 10             	add    $0x10,%esp
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	78 21                	js     8010d0 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8010af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8010b8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8010ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010bd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8010c4:	83 ec 0c             	sub    $0xc,%esp
  8010c7:	50                   	push   %eax
  8010c8:	e8 c0 f2 ff ff       	call   80038d <fd2num>
  8010cd:	83 c4 10             	add    $0x10,%esp
}
  8010d0:	c9                   	leave  
  8010d1:	c3                   	ret    

008010d2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010d2:	f3 0f 1e fb          	endbr32 
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	56                   	push   %esi
  8010da:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010db:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010de:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010e4:	e8 4d f0 ff ff       	call   800136 <sys_getenvid>
  8010e9:	83 ec 0c             	sub    $0xc,%esp
  8010ec:	ff 75 0c             	pushl  0xc(%ebp)
  8010ef:	ff 75 08             	pushl  0x8(%ebp)
  8010f2:	56                   	push   %esi
  8010f3:	50                   	push   %eax
  8010f4:	68 04 20 80 00       	push   $0x802004
  8010f9:	e8 bb 00 00 00       	call   8011b9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010fe:	83 c4 18             	add    $0x18,%esp
  801101:	53                   	push   %ebx
  801102:	ff 75 10             	pushl  0x10(%ebp)
  801105:	e8 5a 00 00 00       	call   801164 <vcprintf>
	cprintf("\n");
  80110a:	c7 04 24 ef 1f 80 00 	movl   $0x801fef,(%esp)
  801111:	e8 a3 00 00 00       	call   8011b9 <cprintf>
  801116:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801119:	cc                   	int3   
  80111a:	eb fd                	jmp    801119 <_panic+0x47>

0080111c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80111c:	f3 0f 1e fb          	endbr32 
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	53                   	push   %ebx
  801124:	83 ec 04             	sub    $0x4,%esp
  801127:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80112a:	8b 13                	mov    (%ebx),%edx
  80112c:	8d 42 01             	lea    0x1(%edx),%eax
  80112f:	89 03                	mov    %eax,(%ebx)
  801131:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801134:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801138:	3d ff 00 00 00       	cmp    $0xff,%eax
  80113d:	74 09                	je     801148 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80113f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801143:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801146:	c9                   	leave  
  801147:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801148:	83 ec 08             	sub    $0x8,%esp
  80114b:	68 ff 00 00 00       	push   $0xff
  801150:	8d 43 08             	lea    0x8(%ebx),%eax
  801153:	50                   	push   %eax
  801154:	e8 53 ef ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  801159:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80115f:	83 c4 10             	add    $0x10,%esp
  801162:	eb db                	jmp    80113f <putch+0x23>

00801164 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801164:	f3 0f 1e fb          	endbr32 
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801171:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801178:	00 00 00 
	b.cnt = 0;
  80117b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801182:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801185:	ff 75 0c             	pushl  0xc(%ebp)
  801188:	ff 75 08             	pushl  0x8(%ebp)
  80118b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801191:	50                   	push   %eax
  801192:	68 1c 11 80 00       	push   $0x80111c
  801197:	e8 20 01 00 00       	call   8012bc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80119c:	83 c4 08             	add    $0x8,%esp
  80119f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8011a5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8011ab:	50                   	push   %eax
  8011ac:	e8 fb ee ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  8011b1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8011b7:	c9                   	leave  
  8011b8:	c3                   	ret    

008011b9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8011b9:	f3 0f 1e fb          	endbr32 
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8011c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8011c6:	50                   	push   %eax
  8011c7:	ff 75 08             	pushl  0x8(%ebp)
  8011ca:	e8 95 ff ff ff       	call   801164 <vcprintf>
	va_end(ap);

	return cnt;
}
  8011cf:	c9                   	leave  
  8011d0:	c3                   	ret    

008011d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	57                   	push   %edi
  8011d5:	56                   	push   %esi
  8011d6:	53                   	push   %ebx
  8011d7:	83 ec 1c             	sub    $0x1c,%esp
  8011da:	89 c7                	mov    %eax,%edi
  8011dc:	89 d6                	mov    %edx,%esi
  8011de:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e4:	89 d1                	mov    %edx,%ecx
  8011e6:	89 c2                	mov    %eax,%edx
  8011e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011eb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8011ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8011f1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011f7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8011fe:	39 c2                	cmp    %eax,%edx
  801200:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801203:	72 3e                	jb     801243 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801205:	83 ec 0c             	sub    $0xc,%esp
  801208:	ff 75 18             	pushl  0x18(%ebp)
  80120b:	83 eb 01             	sub    $0x1,%ebx
  80120e:	53                   	push   %ebx
  80120f:	50                   	push   %eax
  801210:	83 ec 08             	sub    $0x8,%esp
  801213:	ff 75 e4             	pushl  -0x1c(%ebp)
  801216:	ff 75 e0             	pushl  -0x20(%ebp)
  801219:	ff 75 dc             	pushl  -0x24(%ebp)
  80121c:	ff 75 d8             	pushl  -0x28(%ebp)
  80121f:	e8 4c 0a 00 00       	call   801c70 <__udivdi3>
  801224:	83 c4 18             	add    $0x18,%esp
  801227:	52                   	push   %edx
  801228:	50                   	push   %eax
  801229:	89 f2                	mov    %esi,%edx
  80122b:	89 f8                	mov    %edi,%eax
  80122d:	e8 9f ff ff ff       	call   8011d1 <printnum>
  801232:	83 c4 20             	add    $0x20,%esp
  801235:	eb 13                	jmp    80124a <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801237:	83 ec 08             	sub    $0x8,%esp
  80123a:	56                   	push   %esi
  80123b:	ff 75 18             	pushl  0x18(%ebp)
  80123e:	ff d7                	call   *%edi
  801240:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801243:	83 eb 01             	sub    $0x1,%ebx
  801246:	85 db                	test   %ebx,%ebx
  801248:	7f ed                	jg     801237 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80124a:	83 ec 08             	sub    $0x8,%esp
  80124d:	56                   	push   %esi
  80124e:	83 ec 04             	sub    $0x4,%esp
  801251:	ff 75 e4             	pushl  -0x1c(%ebp)
  801254:	ff 75 e0             	pushl  -0x20(%ebp)
  801257:	ff 75 dc             	pushl  -0x24(%ebp)
  80125a:	ff 75 d8             	pushl  -0x28(%ebp)
  80125d:	e8 1e 0b 00 00       	call   801d80 <__umoddi3>
  801262:	83 c4 14             	add    $0x14,%esp
  801265:	0f be 80 27 20 80 00 	movsbl 0x802027(%eax),%eax
  80126c:	50                   	push   %eax
  80126d:	ff d7                	call   *%edi
}
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801275:	5b                   	pop    %ebx
  801276:	5e                   	pop    %esi
  801277:	5f                   	pop    %edi
  801278:	5d                   	pop    %ebp
  801279:	c3                   	ret    

0080127a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80127a:	f3 0f 1e fb          	endbr32 
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801284:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801288:	8b 10                	mov    (%eax),%edx
  80128a:	3b 50 04             	cmp    0x4(%eax),%edx
  80128d:	73 0a                	jae    801299 <sprintputch+0x1f>
		*b->buf++ = ch;
  80128f:	8d 4a 01             	lea    0x1(%edx),%ecx
  801292:	89 08                	mov    %ecx,(%eax)
  801294:	8b 45 08             	mov    0x8(%ebp),%eax
  801297:	88 02                	mov    %al,(%edx)
}
  801299:	5d                   	pop    %ebp
  80129a:	c3                   	ret    

0080129b <printfmt>:
{
  80129b:	f3 0f 1e fb          	endbr32 
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8012a5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012a8:	50                   	push   %eax
  8012a9:	ff 75 10             	pushl  0x10(%ebp)
  8012ac:	ff 75 0c             	pushl  0xc(%ebp)
  8012af:	ff 75 08             	pushl  0x8(%ebp)
  8012b2:	e8 05 00 00 00       	call   8012bc <vprintfmt>
}
  8012b7:	83 c4 10             	add    $0x10,%esp
  8012ba:	c9                   	leave  
  8012bb:	c3                   	ret    

008012bc <vprintfmt>:
{
  8012bc:	f3 0f 1e fb          	endbr32 
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	57                   	push   %edi
  8012c4:	56                   	push   %esi
  8012c5:	53                   	push   %ebx
  8012c6:	83 ec 3c             	sub    $0x3c,%esp
  8012c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8012cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012cf:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012d2:	e9 4a 03 00 00       	jmp    801621 <vprintfmt+0x365>
		padc = ' ';
  8012d7:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012db:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012e2:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012e9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012f0:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012f5:	8d 47 01             	lea    0x1(%edi),%eax
  8012f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012fb:	0f b6 17             	movzbl (%edi),%edx
  8012fe:	8d 42 dd             	lea    -0x23(%edx),%eax
  801301:	3c 55                	cmp    $0x55,%al
  801303:	0f 87 de 03 00 00    	ja     8016e7 <vprintfmt+0x42b>
  801309:	0f b6 c0             	movzbl %al,%eax
  80130c:	3e ff 24 85 60 21 80 	notrack jmp *0x802160(,%eax,4)
  801313:	00 
  801314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801317:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80131b:	eb d8                	jmp    8012f5 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80131d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801320:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801324:	eb cf                	jmp    8012f5 <vprintfmt+0x39>
  801326:	0f b6 d2             	movzbl %dl,%edx
  801329:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80132c:	b8 00 00 00 00       	mov    $0x0,%eax
  801331:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801334:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801337:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80133b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80133e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801341:	83 f9 09             	cmp    $0x9,%ecx
  801344:	77 55                	ja     80139b <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  801346:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801349:	eb e9                	jmp    801334 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80134b:	8b 45 14             	mov    0x14(%ebp),%eax
  80134e:	8b 00                	mov    (%eax),%eax
  801350:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801353:	8b 45 14             	mov    0x14(%ebp),%eax
  801356:	8d 40 04             	lea    0x4(%eax),%eax
  801359:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80135c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80135f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801363:	79 90                	jns    8012f5 <vprintfmt+0x39>
				width = precision, precision = -1;
  801365:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801368:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80136b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801372:	eb 81                	jmp    8012f5 <vprintfmt+0x39>
  801374:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801377:	85 c0                	test   %eax,%eax
  801379:	ba 00 00 00 00       	mov    $0x0,%edx
  80137e:	0f 49 d0             	cmovns %eax,%edx
  801381:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801384:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801387:	e9 69 ff ff ff       	jmp    8012f5 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80138c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80138f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801396:	e9 5a ff ff ff       	jmp    8012f5 <vprintfmt+0x39>
  80139b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80139e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8013a1:	eb bc                	jmp    80135f <vprintfmt+0xa3>
			lflag++;
  8013a3:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8013a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8013a9:	e9 47 ff ff ff       	jmp    8012f5 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8013ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b1:	8d 78 04             	lea    0x4(%eax),%edi
  8013b4:	83 ec 08             	sub    $0x8,%esp
  8013b7:	53                   	push   %ebx
  8013b8:	ff 30                	pushl  (%eax)
  8013ba:	ff d6                	call   *%esi
			break;
  8013bc:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8013bf:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8013c2:	e9 57 02 00 00       	jmp    80161e <vprintfmt+0x362>
			err = va_arg(ap, int);
  8013c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ca:	8d 78 04             	lea    0x4(%eax),%edi
  8013cd:	8b 00                	mov    (%eax),%eax
  8013cf:	99                   	cltd   
  8013d0:	31 d0                	xor    %edx,%eax
  8013d2:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013d4:	83 f8 0f             	cmp    $0xf,%eax
  8013d7:	7f 23                	jg     8013fc <vprintfmt+0x140>
  8013d9:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  8013e0:	85 d2                	test   %edx,%edx
  8013e2:	74 18                	je     8013fc <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8013e4:	52                   	push   %edx
  8013e5:	68 bd 1f 80 00       	push   $0x801fbd
  8013ea:	53                   	push   %ebx
  8013eb:	56                   	push   %esi
  8013ec:	e8 aa fe ff ff       	call   80129b <printfmt>
  8013f1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8013f4:	89 7d 14             	mov    %edi,0x14(%ebp)
  8013f7:	e9 22 02 00 00       	jmp    80161e <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8013fc:	50                   	push   %eax
  8013fd:	68 3f 20 80 00       	push   $0x80203f
  801402:	53                   	push   %ebx
  801403:	56                   	push   %esi
  801404:	e8 92 fe ff ff       	call   80129b <printfmt>
  801409:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80140c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80140f:	e9 0a 02 00 00       	jmp    80161e <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  801414:	8b 45 14             	mov    0x14(%ebp),%eax
  801417:	83 c0 04             	add    $0x4,%eax
  80141a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80141d:	8b 45 14             	mov    0x14(%ebp),%eax
  801420:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801422:	85 d2                	test   %edx,%edx
  801424:	b8 38 20 80 00       	mov    $0x802038,%eax
  801429:	0f 45 c2             	cmovne %edx,%eax
  80142c:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80142f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801433:	7e 06                	jle    80143b <vprintfmt+0x17f>
  801435:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801439:	75 0d                	jne    801448 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80143b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80143e:	89 c7                	mov    %eax,%edi
  801440:	03 45 e0             	add    -0x20(%ebp),%eax
  801443:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801446:	eb 55                	jmp    80149d <vprintfmt+0x1e1>
  801448:	83 ec 08             	sub    $0x8,%esp
  80144b:	ff 75 d8             	pushl  -0x28(%ebp)
  80144e:	ff 75 cc             	pushl  -0x34(%ebp)
  801451:	e8 45 03 00 00       	call   80179b <strnlen>
  801456:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801459:	29 c2                	sub    %eax,%edx
  80145b:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80145e:	83 c4 10             	add    $0x10,%esp
  801461:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  801463:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801467:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80146a:	85 ff                	test   %edi,%edi
  80146c:	7e 11                	jle    80147f <vprintfmt+0x1c3>
					putch(padc, putdat);
  80146e:	83 ec 08             	sub    $0x8,%esp
  801471:	53                   	push   %ebx
  801472:	ff 75 e0             	pushl  -0x20(%ebp)
  801475:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801477:	83 ef 01             	sub    $0x1,%edi
  80147a:	83 c4 10             	add    $0x10,%esp
  80147d:	eb eb                	jmp    80146a <vprintfmt+0x1ae>
  80147f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801482:	85 d2                	test   %edx,%edx
  801484:	b8 00 00 00 00       	mov    $0x0,%eax
  801489:	0f 49 c2             	cmovns %edx,%eax
  80148c:	29 c2                	sub    %eax,%edx
  80148e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801491:	eb a8                	jmp    80143b <vprintfmt+0x17f>
					putch(ch, putdat);
  801493:	83 ec 08             	sub    $0x8,%esp
  801496:	53                   	push   %ebx
  801497:	52                   	push   %edx
  801498:	ff d6                	call   *%esi
  80149a:	83 c4 10             	add    $0x10,%esp
  80149d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014a0:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014a2:	83 c7 01             	add    $0x1,%edi
  8014a5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014a9:	0f be d0             	movsbl %al,%edx
  8014ac:	85 d2                	test   %edx,%edx
  8014ae:	74 4b                	je     8014fb <vprintfmt+0x23f>
  8014b0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014b4:	78 06                	js     8014bc <vprintfmt+0x200>
  8014b6:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014ba:	78 1e                	js     8014da <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8014bc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014c0:	74 d1                	je     801493 <vprintfmt+0x1d7>
  8014c2:	0f be c0             	movsbl %al,%eax
  8014c5:	83 e8 20             	sub    $0x20,%eax
  8014c8:	83 f8 5e             	cmp    $0x5e,%eax
  8014cb:	76 c6                	jbe    801493 <vprintfmt+0x1d7>
					putch('?', putdat);
  8014cd:	83 ec 08             	sub    $0x8,%esp
  8014d0:	53                   	push   %ebx
  8014d1:	6a 3f                	push   $0x3f
  8014d3:	ff d6                	call   *%esi
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	eb c3                	jmp    80149d <vprintfmt+0x1e1>
  8014da:	89 cf                	mov    %ecx,%edi
  8014dc:	eb 0e                	jmp    8014ec <vprintfmt+0x230>
				putch(' ', putdat);
  8014de:	83 ec 08             	sub    $0x8,%esp
  8014e1:	53                   	push   %ebx
  8014e2:	6a 20                	push   $0x20
  8014e4:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8014e6:	83 ef 01             	sub    $0x1,%edi
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	85 ff                	test   %edi,%edi
  8014ee:	7f ee                	jg     8014de <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8014f0:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8014f3:	89 45 14             	mov    %eax,0x14(%ebp)
  8014f6:	e9 23 01 00 00       	jmp    80161e <vprintfmt+0x362>
  8014fb:	89 cf                	mov    %ecx,%edi
  8014fd:	eb ed                	jmp    8014ec <vprintfmt+0x230>
	if (lflag >= 2)
  8014ff:	83 f9 01             	cmp    $0x1,%ecx
  801502:	7f 1b                	jg     80151f <vprintfmt+0x263>
	else if (lflag)
  801504:	85 c9                	test   %ecx,%ecx
  801506:	74 63                	je     80156b <vprintfmt+0x2af>
		return va_arg(*ap, long);
  801508:	8b 45 14             	mov    0x14(%ebp),%eax
  80150b:	8b 00                	mov    (%eax),%eax
  80150d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801510:	99                   	cltd   
  801511:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801514:	8b 45 14             	mov    0x14(%ebp),%eax
  801517:	8d 40 04             	lea    0x4(%eax),%eax
  80151a:	89 45 14             	mov    %eax,0x14(%ebp)
  80151d:	eb 17                	jmp    801536 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80151f:	8b 45 14             	mov    0x14(%ebp),%eax
  801522:	8b 50 04             	mov    0x4(%eax),%edx
  801525:	8b 00                	mov    (%eax),%eax
  801527:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80152a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80152d:	8b 45 14             	mov    0x14(%ebp),%eax
  801530:	8d 40 08             	lea    0x8(%eax),%eax
  801533:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801536:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801539:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80153c:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  801541:	85 c9                	test   %ecx,%ecx
  801543:	0f 89 bb 00 00 00    	jns    801604 <vprintfmt+0x348>
				putch('-', putdat);
  801549:	83 ec 08             	sub    $0x8,%esp
  80154c:	53                   	push   %ebx
  80154d:	6a 2d                	push   $0x2d
  80154f:	ff d6                	call   *%esi
				num = -(long long) num;
  801551:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801554:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801557:	f7 da                	neg    %edx
  801559:	83 d1 00             	adc    $0x0,%ecx
  80155c:	f7 d9                	neg    %ecx
  80155e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801561:	b8 0a 00 00 00       	mov    $0xa,%eax
  801566:	e9 99 00 00 00       	jmp    801604 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80156b:	8b 45 14             	mov    0x14(%ebp),%eax
  80156e:	8b 00                	mov    (%eax),%eax
  801570:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801573:	99                   	cltd   
  801574:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801577:	8b 45 14             	mov    0x14(%ebp),%eax
  80157a:	8d 40 04             	lea    0x4(%eax),%eax
  80157d:	89 45 14             	mov    %eax,0x14(%ebp)
  801580:	eb b4                	jmp    801536 <vprintfmt+0x27a>
	if (lflag >= 2)
  801582:	83 f9 01             	cmp    $0x1,%ecx
  801585:	7f 1b                	jg     8015a2 <vprintfmt+0x2e6>
	else if (lflag)
  801587:	85 c9                	test   %ecx,%ecx
  801589:	74 2c                	je     8015b7 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80158b:	8b 45 14             	mov    0x14(%ebp),%eax
  80158e:	8b 10                	mov    (%eax),%edx
  801590:	b9 00 00 00 00       	mov    $0x0,%ecx
  801595:	8d 40 04             	lea    0x4(%eax),%eax
  801598:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80159b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8015a0:	eb 62                	jmp    801604 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8015a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a5:	8b 10                	mov    (%eax),%edx
  8015a7:	8b 48 04             	mov    0x4(%eax),%ecx
  8015aa:	8d 40 08             	lea    0x8(%eax),%eax
  8015ad:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015b0:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8015b5:	eb 4d                	jmp    801604 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8015b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ba:	8b 10                	mov    (%eax),%edx
  8015bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015c1:	8d 40 04             	lea    0x4(%eax),%eax
  8015c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015c7:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8015cc:	eb 36                	jmp    801604 <vprintfmt+0x348>
	if (lflag >= 2)
  8015ce:	83 f9 01             	cmp    $0x1,%ecx
  8015d1:	7f 17                	jg     8015ea <vprintfmt+0x32e>
	else if (lflag)
  8015d3:	85 c9                	test   %ecx,%ecx
  8015d5:	74 6e                	je     801645 <vprintfmt+0x389>
		return va_arg(*ap, long);
  8015d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8015da:	8b 10                	mov    (%eax),%edx
  8015dc:	89 d0                	mov    %edx,%eax
  8015de:	99                   	cltd   
  8015df:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015e2:	8d 49 04             	lea    0x4(%ecx),%ecx
  8015e5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8015e8:	eb 11                	jmp    8015fb <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8015ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ed:	8b 50 04             	mov    0x4(%eax),%edx
  8015f0:	8b 00                	mov    (%eax),%eax
  8015f2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015f5:	8d 49 08             	lea    0x8(%ecx),%ecx
  8015f8:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8015fb:	89 d1                	mov    %edx,%ecx
  8015fd:	89 c2                	mov    %eax,%edx
            base = 8;
  8015ff:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  801604:	83 ec 0c             	sub    $0xc,%esp
  801607:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80160b:	57                   	push   %edi
  80160c:	ff 75 e0             	pushl  -0x20(%ebp)
  80160f:	50                   	push   %eax
  801610:	51                   	push   %ecx
  801611:	52                   	push   %edx
  801612:	89 da                	mov    %ebx,%edx
  801614:	89 f0                	mov    %esi,%eax
  801616:	e8 b6 fb ff ff       	call   8011d1 <printnum>
			break;
  80161b:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80161e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801621:	83 c7 01             	add    $0x1,%edi
  801624:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801628:	83 f8 25             	cmp    $0x25,%eax
  80162b:	0f 84 a6 fc ff ff    	je     8012d7 <vprintfmt+0x1b>
			if (ch == '\0')
  801631:	85 c0                	test   %eax,%eax
  801633:	0f 84 ce 00 00 00    	je     801707 <vprintfmt+0x44b>
			putch(ch, putdat);
  801639:	83 ec 08             	sub    $0x8,%esp
  80163c:	53                   	push   %ebx
  80163d:	50                   	push   %eax
  80163e:	ff d6                	call   *%esi
  801640:	83 c4 10             	add    $0x10,%esp
  801643:	eb dc                	jmp    801621 <vprintfmt+0x365>
		return va_arg(*ap, int);
  801645:	8b 45 14             	mov    0x14(%ebp),%eax
  801648:	8b 10                	mov    (%eax),%edx
  80164a:	89 d0                	mov    %edx,%eax
  80164c:	99                   	cltd   
  80164d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801650:	8d 49 04             	lea    0x4(%ecx),%ecx
  801653:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801656:	eb a3                	jmp    8015fb <vprintfmt+0x33f>
			putch('0', putdat);
  801658:	83 ec 08             	sub    $0x8,%esp
  80165b:	53                   	push   %ebx
  80165c:	6a 30                	push   $0x30
  80165e:	ff d6                	call   *%esi
			putch('x', putdat);
  801660:	83 c4 08             	add    $0x8,%esp
  801663:	53                   	push   %ebx
  801664:	6a 78                	push   $0x78
  801666:	ff d6                	call   *%esi
			num = (unsigned long long)
  801668:	8b 45 14             	mov    0x14(%ebp),%eax
  80166b:	8b 10                	mov    (%eax),%edx
  80166d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801672:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801675:	8d 40 04             	lea    0x4(%eax),%eax
  801678:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80167b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801680:	eb 82                	jmp    801604 <vprintfmt+0x348>
	if (lflag >= 2)
  801682:	83 f9 01             	cmp    $0x1,%ecx
  801685:	7f 1e                	jg     8016a5 <vprintfmt+0x3e9>
	else if (lflag)
  801687:	85 c9                	test   %ecx,%ecx
  801689:	74 32                	je     8016bd <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80168b:	8b 45 14             	mov    0x14(%ebp),%eax
  80168e:	8b 10                	mov    (%eax),%edx
  801690:	b9 00 00 00 00       	mov    $0x0,%ecx
  801695:	8d 40 04             	lea    0x4(%eax),%eax
  801698:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80169b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8016a0:	e9 5f ff ff ff       	jmp    801604 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8016a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8016a8:	8b 10                	mov    (%eax),%edx
  8016aa:	8b 48 04             	mov    0x4(%eax),%ecx
  8016ad:	8d 40 08             	lea    0x8(%eax),%eax
  8016b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016b3:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8016b8:	e9 47 ff ff ff       	jmp    801604 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8016bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c0:	8b 10                	mov    (%eax),%edx
  8016c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016c7:	8d 40 04             	lea    0x4(%eax),%eax
  8016ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016cd:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8016d2:	e9 2d ff ff ff       	jmp    801604 <vprintfmt+0x348>
			putch(ch, putdat);
  8016d7:	83 ec 08             	sub    $0x8,%esp
  8016da:	53                   	push   %ebx
  8016db:	6a 25                	push   $0x25
  8016dd:	ff d6                	call   *%esi
			break;
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	e9 37 ff ff ff       	jmp    80161e <vprintfmt+0x362>
			putch('%', putdat);
  8016e7:	83 ec 08             	sub    $0x8,%esp
  8016ea:	53                   	push   %ebx
  8016eb:	6a 25                	push   $0x25
  8016ed:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8016ef:	83 c4 10             	add    $0x10,%esp
  8016f2:	89 f8                	mov    %edi,%eax
  8016f4:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8016f8:	74 05                	je     8016ff <vprintfmt+0x443>
  8016fa:	83 e8 01             	sub    $0x1,%eax
  8016fd:	eb f5                	jmp    8016f4 <vprintfmt+0x438>
  8016ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801702:	e9 17 ff ff ff       	jmp    80161e <vprintfmt+0x362>
}
  801707:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80170a:	5b                   	pop    %ebx
  80170b:	5e                   	pop    %esi
  80170c:	5f                   	pop    %edi
  80170d:	5d                   	pop    %ebp
  80170e:	c3                   	ret    

0080170f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80170f:	f3 0f 1e fb          	endbr32 
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	83 ec 18             	sub    $0x18,%esp
  801719:	8b 45 08             	mov    0x8(%ebp),%eax
  80171c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80171f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801722:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801726:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801729:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801730:	85 c0                	test   %eax,%eax
  801732:	74 26                	je     80175a <vsnprintf+0x4b>
  801734:	85 d2                	test   %edx,%edx
  801736:	7e 22                	jle    80175a <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801738:	ff 75 14             	pushl  0x14(%ebp)
  80173b:	ff 75 10             	pushl  0x10(%ebp)
  80173e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801741:	50                   	push   %eax
  801742:	68 7a 12 80 00       	push   $0x80127a
  801747:	e8 70 fb ff ff       	call   8012bc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80174c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80174f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801752:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801755:	83 c4 10             	add    $0x10,%esp
}
  801758:	c9                   	leave  
  801759:	c3                   	ret    
		return -E_INVAL;
  80175a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80175f:	eb f7                	jmp    801758 <vsnprintf+0x49>

00801761 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801761:	f3 0f 1e fb          	endbr32 
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80176b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80176e:	50                   	push   %eax
  80176f:	ff 75 10             	pushl  0x10(%ebp)
  801772:	ff 75 0c             	pushl  0xc(%ebp)
  801775:	ff 75 08             	pushl  0x8(%ebp)
  801778:	e8 92 ff ff ff       	call   80170f <vsnprintf>
	va_end(ap);

	return rc;
}
  80177d:	c9                   	leave  
  80177e:	c3                   	ret    

0080177f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80177f:	f3 0f 1e fb          	endbr32 
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801789:	b8 00 00 00 00       	mov    $0x0,%eax
  80178e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801792:	74 05                	je     801799 <strlen+0x1a>
		n++;
  801794:	83 c0 01             	add    $0x1,%eax
  801797:	eb f5                	jmp    80178e <strlen+0xf>
	return n;
}
  801799:	5d                   	pop    %ebp
  80179a:	c3                   	ret    

0080179b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80179b:	f3 0f 1e fb          	endbr32 
  80179f:	55                   	push   %ebp
  8017a0:	89 e5                	mov    %esp,%ebp
  8017a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8017a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ad:	39 d0                	cmp    %edx,%eax
  8017af:	74 0d                	je     8017be <strnlen+0x23>
  8017b1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8017b5:	74 05                	je     8017bc <strnlen+0x21>
		n++;
  8017b7:	83 c0 01             	add    $0x1,%eax
  8017ba:	eb f1                	jmp    8017ad <strnlen+0x12>
  8017bc:	89 c2                	mov    %eax,%edx
	return n;
}
  8017be:	89 d0                	mov    %edx,%eax
  8017c0:	5d                   	pop    %ebp
  8017c1:	c3                   	ret    

008017c2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8017c2:	f3 0f 1e fb          	endbr32 
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	53                   	push   %ebx
  8017ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8017d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d5:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8017d9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8017dc:	83 c0 01             	add    $0x1,%eax
  8017df:	84 d2                	test   %dl,%dl
  8017e1:	75 f2                	jne    8017d5 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8017e3:	89 c8                	mov    %ecx,%eax
  8017e5:	5b                   	pop    %ebx
  8017e6:	5d                   	pop    %ebp
  8017e7:	c3                   	ret    

008017e8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017e8:	f3 0f 1e fb          	endbr32 
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	53                   	push   %ebx
  8017f0:	83 ec 10             	sub    $0x10,%esp
  8017f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8017f6:	53                   	push   %ebx
  8017f7:	e8 83 ff ff ff       	call   80177f <strlen>
  8017fc:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8017ff:	ff 75 0c             	pushl  0xc(%ebp)
  801802:	01 d8                	add    %ebx,%eax
  801804:	50                   	push   %eax
  801805:	e8 b8 ff ff ff       	call   8017c2 <strcpy>
	return dst;
}
  80180a:	89 d8                	mov    %ebx,%eax
  80180c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180f:	c9                   	leave  
  801810:	c3                   	ret    

00801811 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801811:	f3 0f 1e fb          	endbr32 
  801815:	55                   	push   %ebp
  801816:	89 e5                	mov    %esp,%ebp
  801818:	56                   	push   %esi
  801819:	53                   	push   %ebx
  80181a:	8b 75 08             	mov    0x8(%ebp),%esi
  80181d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801820:	89 f3                	mov    %esi,%ebx
  801822:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801825:	89 f0                	mov    %esi,%eax
  801827:	39 d8                	cmp    %ebx,%eax
  801829:	74 11                	je     80183c <strncpy+0x2b>
		*dst++ = *src;
  80182b:	83 c0 01             	add    $0x1,%eax
  80182e:	0f b6 0a             	movzbl (%edx),%ecx
  801831:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801834:	80 f9 01             	cmp    $0x1,%cl
  801837:	83 da ff             	sbb    $0xffffffff,%edx
  80183a:	eb eb                	jmp    801827 <strncpy+0x16>
	}
	return ret;
}
  80183c:	89 f0                	mov    %esi,%eax
  80183e:	5b                   	pop    %ebx
  80183f:	5e                   	pop    %esi
  801840:	5d                   	pop    %ebp
  801841:	c3                   	ret    

00801842 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801842:	f3 0f 1e fb          	endbr32 
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	56                   	push   %esi
  80184a:	53                   	push   %ebx
  80184b:	8b 75 08             	mov    0x8(%ebp),%esi
  80184e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801851:	8b 55 10             	mov    0x10(%ebp),%edx
  801854:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801856:	85 d2                	test   %edx,%edx
  801858:	74 21                	je     80187b <strlcpy+0x39>
  80185a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80185e:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801860:	39 c2                	cmp    %eax,%edx
  801862:	74 14                	je     801878 <strlcpy+0x36>
  801864:	0f b6 19             	movzbl (%ecx),%ebx
  801867:	84 db                	test   %bl,%bl
  801869:	74 0b                	je     801876 <strlcpy+0x34>
			*dst++ = *src++;
  80186b:	83 c1 01             	add    $0x1,%ecx
  80186e:	83 c2 01             	add    $0x1,%edx
  801871:	88 5a ff             	mov    %bl,-0x1(%edx)
  801874:	eb ea                	jmp    801860 <strlcpy+0x1e>
  801876:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801878:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80187b:	29 f0                	sub    %esi,%eax
}
  80187d:	5b                   	pop    %ebx
  80187e:	5e                   	pop    %esi
  80187f:	5d                   	pop    %ebp
  801880:	c3                   	ret    

00801881 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801881:	f3 0f 1e fb          	endbr32 
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80188b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80188e:	0f b6 01             	movzbl (%ecx),%eax
  801891:	84 c0                	test   %al,%al
  801893:	74 0c                	je     8018a1 <strcmp+0x20>
  801895:	3a 02                	cmp    (%edx),%al
  801897:	75 08                	jne    8018a1 <strcmp+0x20>
		p++, q++;
  801899:	83 c1 01             	add    $0x1,%ecx
  80189c:	83 c2 01             	add    $0x1,%edx
  80189f:	eb ed                	jmp    80188e <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8018a1:	0f b6 c0             	movzbl %al,%eax
  8018a4:	0f b6 12             	movzbl (%edx),%edx
  8018a7:	29 d0                	sub    %edx,%eax
}
  8018a9:	5d                   	pop    %ebp
  8018aa:	c3                   	ret    

008018ab <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8018ab:	f3 0f 1e fb          	endbr32 
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	53                   	push   %ebx
  8018b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018b9:	89 c3                	mov    %eax,%ebx
  8018bb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8018be:	eb 06                	jmp    8018c6 <strncmp+0x1b>
		n--, p++, q++;
  8018c0:	83 c0 01             	add    $0x1,%eax
  8018c3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8018c6:	39 d8                	cmp    %ebx,%eax
  8018c8:	74 16                	je     8018e0 <strncmp+0x35>
  8018ca:	0f b6 08             	movzbl (%eax),%ecx
  8018cd:	84 c9                	test   %cl,%cl
  8018cf:	74 04                	je     8018d5 <strncmp+0x2a>
  8018d1:	3a 0a                	cmp    (%edx),%cl
  8018d3:	74 eb                	je     8018c0 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8018d5:	0f b6 00             	movzbl (%eax),%eax
  8018d8:	0f b6 12             	movzbl (%edx),%edx
  8018db:	29 d0                	sub    %edx,%eax
}
  8018dd:	5b                   	pop    %ebx
  8018de:	5d                   	pop    %ebp
  8018df:	c3                   	ret    
		return 0;
  8018e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e5:	eb f6                	jmp    8018dd <strncmp+0x32>

008018e7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8018e7:	f3 0f 1e fb          	endbr32 
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018f5:	0f b6 10             	movzbl (%eax),%edx
  8018f8:	84 d2                	test   %dl,%dl
  8018fa:	74 09                	je     801905 <strchr+0x1e>
		if (*s == c)
  8018fc:	38 ca                	cmp    %cl,%dl
  8018fe:	74 0a                	je     80190a <strchr+0x23>
	for (; *s; s++)
  801900:	83 c0 01             	add    $0x1,%eax
  801903:	eb f0                	jmp    8018f5 <strchr+0xe>
			return (char *) s;
	return 0;
  801905:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80190a:	5d                   	pop    %ebp
  80190b:	c3                   	ret    

0080190c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80190c:	f3 0f 1e fb          	endbr32 
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	8b 45 08             	mov    0x8(%ebp),%eax
  801916:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80191a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80191d:	38 ca                	cmp    %cl,%dl
  80191f:	74 09                	je     80192a <strfind+0x1e>
  801921:	84 d2                	test   %dl,%dl
  801923:	74 05                	je     80192a <strfind+0x1e>
	for (; *s; s++)
  801925:	83 c0 01             	add    $0x1,%eax
  801928:	eb f0                	jmp    80191a <strfind+0xe>
			break;
	return (char *) s;
}
  80192a:	5d                   	pop    %ebp
  80192b:	c3                   	ret    

0080192c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80192c:	f3 0f 1e fb          	endbr32 
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	57                   	push   %edi
  801934:	56                   	push   %esi
  801935:	53                   	push   %ebx
  801936:	8b 7d 08             	mov    0x8(%ebp),%edi
  801939:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80193c:	85 c9                	test   %ecx,%ecx
  80193e:	74 31                	je     801971 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801940:	89 f8                	mov    %edi,%eax
  801942:	09 c8                	or     %ecx,%eax
  801944:	a8 03                	test   $0x3,%al
  801946:	75 23                	jne    80196b <memset+0x3f>
		c &= 0xFF;
  801948:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80194c:	89 d3                	mov    %edx,%ebx
  80194e:	c1 e3 08             	shl    $0x8,%ebx
  801951:	89 d0                	mov    %edx,%eax
  801953:	c1 e0 18             	shl    $0x18,%eax
  801956:	89 d6                	mov    %edx,%esi
  801958:	c1 e6 10             	shl    $0x10,%esi
  80195b:	09 f0                	or     %esi,%eax
  80195d:	09 c2                	or     %eax,%edx
  80195f:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801961:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801964:	89 d0                	mov    %edx,%eax
  801966:	fc                   	cld    
  801967:	f3 ab                	rep stos %eax,%es:(%edi)
  801969:	eb 06                	jmp    801971 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80196b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196e:	fc                   	cld    
  80196f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801971:	89 f8                	mov    %edi,%eax
  801973:	5b                   	pop    %ebx
  801974:	5e                   	pop    %esi
  801975:	5f                   	pop    %edi
  801976:	5d                   	pop    %ebp
  801977:	c3                   	ret    

00801978 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801978:	f3 0f 1e fb          	endbr32 
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	57                   	push   %edi
  801980:	56                   	push   %esi
  801981:	8b 45 08             	mov    0x8(%ebp),%eax
  801984:	8b 75 0c             	mov    0xc(%ebp),%esi
  801987:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80198a:	39 c6                	cmp    %eax,%esi
  80198c:	73 32                	jae    8019c0 <memmove+0x48>
  80198e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801991:	39 c2                	cmp    %eax,%edx
  801993:	76 2b                	jbe    8019c0 <memmove+0x48>
		s += n;
		d += n;
  801995:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801998:	89 fe                	mov    %edi,%esi
  80199a:	09 ce                	or     %ecx,%esi
  80199c:	09 d6                	or     %edx,%esi
  80199e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8019a4:	75 0e                	jne    8019b4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8019a6:	83 ef 04             	sub    $0x4,%edi
  8019a9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8019ac:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8019af:	fd                   	std    
  8019b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019b2:	eb 09                	jmp    8019bd <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8019b4:	83 ef 01             	sub    $0x1,%edi
  8019b7:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8019ba:	fd                   	std    
  8019bb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8019bd:	fc                   	cld    
  8019be:	eb 1a                	jmp    8019da <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019c0:	89 c2                	mov    %eax,%edx
  8019c2:	09 ca                	or     %ecx,%edx
  8019c4:	09 f2                	or     %esi,%edx
  8019c6:	f6 c2 03             	test   $0x3,%dl
  8019c9:	75 0a                	jne    8019d5 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8019cb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8019ce:	89 c7                	mov    %eax,%edi
  8019d0:	fc                   	cld    
  8019d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019d3:	eb 05                	jmp    8019da <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8019d5:	89 c7                	mov    %eax,%edi
  8019d7:	fc                   	cld    
  8019d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8019da:	5e                   	pop    %esi
  8019db:	5f                   	pop    %edi
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    

008019de <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8019de:	f3 0f 1e fb          	endbr32 
  8019e2:	55                   	push   %ebp
  8019e3:	89 e5                	mov    %esp,%ebp
  8019e5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8019e8:	ff 75 10             	pushl  0x10(%ebp)
  8019eb:	ff 75 0c             	pushl  0xc(%ebp)
  8019ee:	ff 75 08             	pushl  0x8(%ebp)
  8019f1:	e8 82 ff ff ff       	call   801978 <memmove>
}
  8019f6:	c9                   	leave  
  8019f7:	c3                   	ret    

008019f8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8019f8:	f3 0f 1e fb          	endbr32 
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	56                   	push   %esi
  801a00:	53                   	push   %ebx
  801a01:	8b 45 08             	mov    0x8(%ebp),%eax
  801a04:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a07:	89 c6                	mov    %eax,%esi
  801a09:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a0c:	39 f0                	cmp    %esi,%eax
  801a0e:	74 1c                	je     801a2c <memcmp+0x34>
		if (*s1 != *s2)
  801a10:	0f b6 08             	movzbl (%eax),%ecx
  801a13:	0f b6 1a             	movzbl (%edx),%ebx
  801a16:	38 d9                	cmp    %bl,%cl
  801a18:	75 08                	jne    801a22 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801a1a:	83 c0 01             	add    $0x1,%eax
  801a1d:	83 c2 01             	add    $0x1,%edx
  801a20:	eb ea                	jmp    801a0c <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801a22:	0f b6 c1             	movzbl %cl,%eax
  801a25:	0f b6 db             	movzbl %bl,%ebx
  801a28:	29 d8                	sub    %ebx,%eax
  801a2a:	eb 05                	jmp    801a31 <memcmp+0x39>
	}

	return 0;
  801a2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a31:	5b                   	pop    %ebx
  801a32:	5e                   	pop    %esi
  801a33:	5d                   	pop    %ebp
  801a34:	c3                   	ret    

00801a35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a35:	f3 0f 1e fb          	endbr32 
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a42:	89 c2                	mov    %eax,%edx
  801a44:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a47:	39 d0                	cmp    %edx,%eax
  801a49:	73 09                	jae    801a54 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a4b:	38 08                	cmp    %cl,(%eax)
  801a4d:	74 05                	je     801a54 <memfind+0x1f>
	for (; s < ends; s++)
  801a4f:	83 c0 01             	add    $0x1,%eax
  801a52:	eb f3                	jmp    801a47 <memfind+0x12>
			break;
	return (void *) s;
}
  801a54:	5d                   	pop    %ebp
  801a55:	c3                   	ret    

00801a56 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a56:	f3 0f 1e fb          	endbr32 
  801a5a:	55                   	push   %ebp
  801a5b:	89 e5                	mov    %esp,%ebp
  801a5d:	57                   	push   %edi
  801a5e:	56                   	push   %esi
  801a5f:	53                   	push   %ebx
  801a60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a66:	eb 03                	jmp    801a6b <strtol+0x15>
		s++;
  801a68:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801a6b:	0f b6 01             	movzbl (%ecx),%eax
  801a6e:	3c 20                	cmp    $0x20,%al
  801a70:	74 f6                	je     801a68 <strtol+0x12>
  801a72:	3c 09                	cmp    $0x9,%al
  801a74:	74 f2                	je     801a68 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801a76:	3c 2b                	cmp    $0x2b,%al
  801a78:	74 2a                	je     801aa4 <strtol+0x4e>
	int neg = 0;
  801a7a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801a7f:	3c 2d                	cmp    $0x2d,%al
  801a81:	74 2b                	je     801aae <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a83:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a89:	75 0f                	jne    801a9a <strtol+0x44>
  801a8b:	80 39 30             	cmpb   $0x30,(%ecx)
  801a8e:	74 28                	je     801ab8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a90:	85 db                	test   %ebx,%ebx
  801a92:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a97:	0f 44 d8             	cmove  %eax,%ebx
  801a9a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a9f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801aa2:	eb 46                	jmp    801aea <strtol+0x94>
		s++;
  801aa4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801aa7:	bf 00 00 00 00       	mov    $0x0,%edi
  801aac:	eb d5                	jmp    801a83 <strtol+0x2d>
		s++, neg = 1;
  801aae:	83 c1 01             	add    $0x1,%ecx
  801ab1:	bf 01 00 00 00       	mov    $0x1,%edi
  801ab6:	eb cb                	jmp    801a83 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ab8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801abc:	74 0e                	je     801acc <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801abe:	85 db                	test   %ebx,%ebx
  801ac0:	75 d8                	jne    801a9a <strtol+0x44>
		s++, base = 8;
  801ac2:	83 c1 01             	add    $0x1,%ecx
  801ac5:	bb 08 00 00 00       	mov    $0x8,%ebx
  801aca:	eb ce                	jmp    801a9a <strtol+0x44>
		s += 2, base = 16;
  801acc:	83 c1 02             	add    $0x2,%ecx
  801acf:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ad4:	eb c4                	jmp    801a9a <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801ad6:	0f be d2             	movsbl %dl,%edx
  801ad9:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801adc:	3b 55 10             	cmp    0x10(%ebp),%edx
  801adf:	7d 3a                	jge    801b1b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801ae1:	83 c1 01             	add    $0x1,%ecx
  801ae4:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ae8:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801aea:	0f b6 11             	movzbl (%ecx),%edx
  801aed:	8d 72 d0             	lea    -0x30(%edx),%esi
  801af0:	89 f3                	mov    %esi,%ebx
  801af2:	80 fb 09             	cmp    $0x9,%bl
  801af5:	76 df                	jbe    801ad6 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801af7:	8d 72 9f             	lea    -0x61(%edx),%esi
  801afa:	89 f3                	mov    %esi,%ebx
  801afc:	80 fb 19             	cmp    $0x19,%bl
  801aff:	77 08                	ja     801b09 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801b01:	0f be d2             	movsbl %dl,%edx
  801b04:	83 ea 57             	sub    $0x57,%edx
  801b07:	eb d3                	jmp    801adc <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801b09:	8d 72 bf             	lea    -0x41(%edx),%esi
  801b0c:	89 f3                	mov    %esi,%ebx
  801b0e:	80 fb 19             	cmp    $0x19,%bl
  801b11:	77 08                	ja     801b1b <strtol+0xc5>
			dig = *s - 'A' + 10;
  801b13:	0f be d2             	movsbl %dl,%edx
  801b16:	83 ea 37             	sub    $0x37,%edx
  801b19:	eb c1                	jmp    801adc <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801b1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b1f:	74 05                	je     801b26 <strtol+0xd0>
		*endptr = (char *) s;
  801b21:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b24:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801b26:	89 c2                	mov    %eax,%edx
  801b28:	f7 da                	neg    %edx
  801b2a:	85 ff                	test   %edi,%edi
  801b2c:	0f 45 c2             	cmovne %edx,%eax
}
  801b2f:	5b                   	pop    %ebx
  801b30:	5e                   	pop    %esi
  801b31:	5f                   	pop    %edi
  801b32:	5d                   	pop    %ebp
  801b33:	c3                   	ret    

00801b34 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b34:	f3 0f 1e fb          	endbr32 
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	56                   	push   %esi
  801b3c:	53                   	push   %ebx
  801b3d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b43:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801b46:	85 c0                	test   %eax,%eax
  801b48:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b4d:	0f 44 c2             	cmove  %edx,%eax
  801b50:	83 ec 0c             	sub    $0xc,%esp
  801b53:	50                   	push   %eax
  801b54:	e8 ef e7 ff ff       	call   800348 <sys_ipc_recv>
  801b59:	83 c4 10             	add    $0x10,%esp
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	78 24                	js     801b84 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801b60:	85 f6                	test   %esi,%esi
  801b62:	74 0a                	je     801b6e <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801b64:	a1 04 40 80 00       	mov    0x804004,%eax
  801b69:	8b 40 78             	mov    0x78(%eax),%eax
  801b6c:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801b6e:	85 db                	test   %ebx,%ebx
  801b70:	74 0a                	je     801b7c <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801b72:	a1 04 40 80 00       	mov    0x804004,%eax
  801b77:	8b 40 74             	mov    0x74(%eax),%eax
  801b7a:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801b7c:	a1 04 40 80 00       	mov    0x804004,%eax
  801b81:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b87:	5b                   	pop    %ebx
  801b88:	5e                   	pop    %esi
  801b89:	5d                   	pop    %ebp
  801b8a:	c3                   	ret    

00801b8b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b8b:	f3 0f 1e fb          	endbr32 
  801b8f:	55                   	push   %ebp
  801b90:	89 e5                	mov    %esp,%ebp
  801b92:	57                   	push   %edi
  801b93:	56                   	push   %esi
  801b94:	53                   	push   %ebx
  801b95:	83 ec 1c             	sub    $0x1c,%esp
  801b98:	8b 45 10             	mov    0x10(%ebp),%eax
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801ba2:	0f 45 d0             	cmovne %eax,%edx
  801ba5:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801ba7:	be 01 00 00 00       	mov    $0x1,%esi
  801bac:	eb 1f                	jmp    801bcd <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801bae:	e8 a6 e5 ff ff       	call   800159 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801bb3:	83 c3 01             	add    $0x1,%ebx
  801bb6:	39 de                	cmp    %ebx,%esi
  801bb8:	7f f4                	jg     801bae <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801bba:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801bbc:	83 fe 11             	cmp    $0x11,%esi
  801bbf:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc4:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801bc7:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801bcb:	75 1c                	jne    801be9 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801bcd:	ff 75 14             	pushl  0x14(%ebp)
  801bd0:	57                   	push   %edi
  801bd1:	ff 75 0c             	pushl  0xc(%ebp)
  801bd4:	ff 75 08             	pushl  0x8(%ebp)
  801bd7:	e8 45 e7 ff ff       	call   800321 <sys_ipc_try_send>
  801bdc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801bdf:	83 c4 10             	add    $0x10,%esp
  801be2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801be7:	eb cd                	jmp    801bb6 <ipc_send+0x2b>
}
  801be9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bec:	5b                   	pop    %ebx
  801bed:	5e                   	pop    %esi
  801bee:	5f                   	pop    %edi
  801bef:	5d                   	pop    %ebp
  801bf0:	c3                   	ret    

00801bf1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bf1:	f3 0f 1e fb          	endbr32 
  801bf5:	55                   	push   %ebp
  801bf6:	89 e5                	mov    %esp,%ebp
  801bf8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bfb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c00:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c03:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c09:	8b 52 50             	mov    0x50(%edx),%edx
  801c0c:	39 ca                	cmp    %ecx,%edx
  801c0e:	74 11                	je     801c21 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801c10:	83 c0 01             	add    $0x1,%eax
  801c13:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c18:	75 e6                	jne    801c00 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801c1a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c1f:	eb 0b                	jmp    801c2c <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c21:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c24:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c29:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c2c:	5d                   	pop    %ebp
  801c2d:	c3                   	ret    

00801c2e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c2e:	f3 0f 1e fb          	endbr32 
  801c32:	55                   	push   %ebp
  801c33:	89 e5                	mov    %esp,%ebp
  801c35:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c38:	89 c2                	mov    %eax,%edx
  801c3a:	c1 ea 16             	shr    $0x16,%edx
  801c3d:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c44:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c49:	f6 c1 01             	test   $0x1,%cl
  801c4c:	74 1c                	je     801c6a <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c4e:	c1 e8 0c             	shr    $0xc,%eax
  801c51:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c58:	a8 01                	test   $0x1,%al
  801c5a:	74 0e                	je     801c6a <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c5c:	c1 e8 0c             	shr    $0xc,%eax
  801c5f:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c66:	ef 
  801c67:	0f b7 d2             	movzwl %dx,%edx
}
  801c6a:	89 d0                	mov    %edx,%eax
  801c6c:	5d                   	pop    %ebp
  801c6d:	c3                   	ret    
  801c6e:	66 90                	xchg   %ax,%ax

00801c70 <__udivdi3>:
  801c70:	f3 0f 1e fb          	endbr32 
  801c74:	55                   	push   %ebp
  801c75:	57                   	push   %edi
  801c76:	56                   	push   %esi
  801c77:	53                   	push   %ebx
  801c78:	83 ec 1c             	sub    $0x1c,%esp
  801c7b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c7f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c83:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c87:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c8b:	85 d2                	test   %edx,%edx
  801c8d:	75 19                	jne    801ca8 <__udivdi3+0x38>
  801c8f:	39 f3                	cmp    %esi,%ebx
  801c91:	76 4d                	jbe    801ce0 <__udivdi3+0x70>
  801c93:	31 ff                	xor    %edi,%edi
  801c95:	89 e8                	mov    %ebp,%eax
  801c97:	89 f2                	mov    %esi,%edx
  801c99:	f7 f3                	div    %ebx
  801c9b:	89 fa                	mov    %edi,%edx
  801c9d:	83 c4 1c             	add    $0x1c,%esp
  801ca0:	5b                   	pop    %ebx
  801ca1:	5e                   	pop    %esi
  801ca2:	5f                   	pop    %edi
  801ca3:	5d                   	pop    %ebp
  801ca4:	c3                   	ret    
  801ca5:	8d 76 00             	lea    0x0(%esi),%esi
  801ca8:	39 f2                	cmp    %esi,%edx
  801caa:	76 14                	jbe    801cc0 <__udivdi3+0x50>
  801cac:	31 ff                	xor    %edi,%edi
  801cae:	31 c0                	xor    %eax,%eax
  801cb0:	89 fa                	mov    %edi,%edx
  801cb2:	83 c4 1c             	add    $0x1c,%esp
  801cb5:	5b                   	pop    %ebx
  801cb6:	5e                   	pop    %esi
  801cb7:	5f                   	pop    %edi
  801cb8:	5d                   	pop    %ebp
  801cb9:	c3                   	ret    
  801cba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cc0:	0f bd fa             	bsr    %edx,%edi
  801cc3:	83 f7 1f             	xor    $0x1f,%edi
  801cc6:	75 48                	jne    801d10 <__udivdi3+0xa0>
  801cc8:	39 f2                	cmp    %esi,%edx
  801cca:	72 06                	jb     801cd2 <__udivdi3+0x62>
  801ccc:	31 c0                	xor    %eax,%eax
  801cce:	39 eb                	cmp    %ebp,%ebx
  801cd0:	77 de                	ja     801cb0 <__udivdi3+0x40>
  801cd2:	b8 01 00 00 00       	mov    $0x1,%eax
  801cd7:	eb d7                	jmp    801cb0 <__udivdi3+0x40>
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	89 d9                	mov    %ebx,%ecx
  801ce2:	85 db                	test   %ebx,%ebx
  801ce4:	75 0b                	jne    801cf1 <__udivdi3+0x81>
  801ce6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ceb:	31 d2                	xor    %edx,%edx
  801ced:	f7 f3                	div    %ebx
  801cef:	89 c1                	mov    %eax,%ecx
  801cf1:	31 d2                	xor    %edx,%edx
  801cf3:	89 f0                	mov    %esi,%eax
  801cf5:	f7 f1                	div    %ecx
  801cf7:	89 c6                	mov    %eax,%esi
  801cf9:	89 e8                	mov    %ebp,%eax
  801cfb:	89 f7                	mov    %esi,%edi
  801cfd:	f7 f1                	div    %ecx
  801cff:	89 fa                	mov    %edi,%edx
  801d01:	83 c4 1c             	add    $0x1c,%esp
  801d04:	5b                   	pop    %ebx
  801d05:	5e                   	pop    %esi
  801d06:	5f                   	pop    %edi
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    
  801d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d10:	89 f9                	mov    %edi,%ecx
  801d12:	b8 20 00 00 00       	mov    $0x20,%eax
  801d17:	29 f8                	sub    %edi,%eax
  801d19:	d3 e2                	shl    %cl,%edx
  801d1b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d1f:	89 c1                	mov    %eax,%ecx
  801d21:	89 da                	mov    %ebx,%edx
  801d23:	d3 ea                	shr    %cl,%edx
  801d25:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d29:	09 d1                	or     %edx,%ecx
  801d2b:	89 f2                	mov    %esi,%edx
  801d2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d31:	89 f9                	mov    %edi,%ecx
  801d33:	d3 e3                	shl    %cl,%ebx
  801d35:	89 c1                	mov    %eax,%ecx
  801d37:	d3 ea                	shr    %cl,%edx
  801d39:	89 f9                	mov    %edi,%ecx
  801d3b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d3f:	89 eb                	mov    %ebp,%ebx
  801d41:	d3 e6                	shl    %cl,%esi
  801d43:	89 c1                	mov    %eax,%ecx
  801d45:	d3 eb                	shr    %cl,%ebx
  801d47:	09 de                	or     %ebx,%esi
  801d49:	89 f0                	mov    %esi,%eax
  801d4b:	f7 74 24 08          	divl   0x8(%esp)
  801d4f:	89 d6                	mov    %edx,%esi
  801d51:	89 c3                	mov    %eax,%ebx
  801d53:	f7 64 24 0c          	mull   0xc(%esp)
  801d57:	39 d6                	cmp    %edx,%esi
  801d59:	72 15                	jb     801d70 <__udivdi3+0x100>
  801d5b:	89 f9                	mov    %edi,%ecx
  801d5d:	d3 e5                	shl    %cl,%ebp
  801d5f:	39 c5                	cmp    %eax,%ebp
  801d61:	73 04                	jae    801d67 <__udivdi3+0xf7>
  801d63:	39 d6                	cmp    %edx,%esi
  801d65:	74 09                	je     801d70 <__udivdi3+0x100>
  801d67:	89 d8                	mov    %ebx,%eax
  801d69:	31 ff                	xor    %edi,%edi
  801d6b:	e9 40 ff ff ff       	jmp    801cb0 <__udivdi3+0x40>
  801d70:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d73:	31 ff                	xor    %edi,%edi
  801d75:	e9 36 ff ff ff       	jmp    801cb0 <__udivdi3+0x40>
  801d7a:	66 90                	xchg   %ax,%ax
  801d7c:	66 90                	xchg   %ax,%ax
  801d7e:	66 90                	xchg   %ax,%ax

00801d80 <__umoddi3>:
  801d80:	f3 0f 1e fb          	endbr32 
  801d84:	55                   	push   %ebp
  801d85:	57                   	push   %edi
  801d86:	56                   	push   %esi
  801d87:	53                   	push   %ebx
  801d88:	83 ec 1c             	sub    $0x1c,%esp
  801d8b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d8f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801d93:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d97:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d9b:	85 c0                	test   %eax,%eax
  801d9d:	75 19                	jne    801db8 <__umoddi3+0x38>
  801d9f:	39 df                	cmp    %ebx,%edi
  801da1:	76 5d                	jbe    801e00 <__umoddi3+0x80>
  801da3:	89 f0                	mov    %esi,%eax
  801da5:	89 da                	mov    %ebx,%edx
  801da7:	f7 f7                	div    %edi
  801da9:	89 d0                	mov    %edx,%eax
  801dab:	31 d2                	xor    %edx,%edx
  801dad:	83 c4 1c             	add    $0x1c,%esp
  801db0:	5b                   	pop    %ebx
  801db1:	5e                   	pop    %esi
  801db2:	5f                   	pop    %edi
  801db3:	5d                   	pop    %ebp
  801db4:	c3                   	ret    
  801db5:	8d 76 00             	lea    0x0(%esi),%esi
  801db8:	89 f2                	mov    %esi,%edx
  801dba:	39 d8                	cmp    %ebx,%eax
  801dbc:	76 12                	jbe    801dd0 <__umoddi3+0x50>
  801dbe:	89 f0                	mov    %esi,%eax
  801dc0:	89 da                	mov    %ebx,%edx
  801dc2:	83 c4 1c             	add    $0x1c,%esp
  801dc5:	5b                   	pop    %ebx
  801dc6:	5e                   	pop    %esi
  801dc7:	5f                   	pop    %edi
  801dc8:	5d                   	pop    %ebp
  801dc9:	c3                   	ret    
  801dca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801dd0:	0f bd e8             	bsr    %eax,%ebp
  801dd3:	83 f5 1f             	xor    $0x1f,%ebp
  801dd6:	75 50                	jne    801e28 <__umoddi3+0xa8>
  801dd8:	39 d8                	cmp    %ebx,%eax
  801dda:	0f 82 e0 00 00 00    	jb     801ec0 <__umoddi3+0x140>
  801de0:	89 d9                	mov    %ebx,%ecx
  801de2:	39 f7                	cmp    %esi,%edi
  801de4:	0f 86 d6 00 00 00    	jbe    801ec0 <__umoddi3+0x140>
  801dea:	89 d0                	mov    %edx,%eax
  801dec:	89 ca                	mov    %ecx,%edx
  801dee:	83 c4 1c             	add    $0x1c,%esp
  801df1:	5b                   	pop    %ebx
  801df2:	5e                   	pop    %esi
  801df3:	5f                   	pop    %edi
  801df4:	5d                   	pop    %ebp
  801df5:	c3                   	ret    
  801df6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dfd:	8d 76 00             	lea    0x0(%esi),%esi
  801e00:	89 fd                	mov    %edi,%ebp
  801e02:	85 ff                	test   %edi,%edi
  801e04:	75 0b                	jne    801e11 <__umoddi3+0x91>
  801e06:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0b:	31 d2                	xor    %edx,%edx
  801e0d:	f7 f7                	div    %edi
  801e0f:	89 c5                	mov    %eax,%ebp
  801e11:	89 d8                	mov    %ebx,%eax
  801e13:	31 d2                	xor    %edx,%edx
  801e15:	f7 f5                	div    %ebp
  801e17:	89 f0                	mov    %esi,%eax
  801e19:	f7 f5                	div    %ebp
  801e1b:	89 d0                	mov    %edx,%eax
  801e1d:	31 d2                	xor    %edx,%edx
  801e1f:	eb 8c                	jmp    801dad <__umoddi3+0x2d>
  801e21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e28:	89 e9                	mov    %ebp,%ecx
  801e2a:	ba 20 00 00 00       	mov    $0x20,%edx
  801e2f:	29 ea                	sub    %ebp,%edx
  801e31:	d3 e0                	shl    %cl,%eax
  801e33:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e37:	89 d1                	mov    %edx,%ecx
  801e39:	89 f8                	mov    %edi,%eax
  801e3b:	d3 e8                	shr    %cl,%eax
  801e3d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e41:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e45:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e49:	09 c1                	or     %eax,%ecx
  801e4b:	89 d8                	mov    %ebx,%eax
  801e4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e51:	89 e9                	mov    %ebp,%ecx
  801e53:	d3 e7                	shl    %cl,%edi
  801e55:	89 d1                	mov    %edx,%ecx
  801e57:	d3 e8                	shr    %cl,%eax
  801e59:	89 e9                	mov    %ebp,%ecx
  801e5b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e5f:	d3 e3                	shl    %cl,%ebx
  801e61:	89 c7                	mov    %eax,%edi
  801e63:	89 d1                	mov    %edx,%ecx
  801e65:	89 f0                	mov    %esi,%eax
  801e67:	d3 e8                	shr    %cl,%eax
  801e69:	89 e9                	mov    %ebp,%ecx
  801e6b:	89 fa                	mov    %edi,%edx
  801e6d:	d3 e6                	shl    %cl,%esi
  801e6f:	09 d8                	or     %ebx,%eax
  801e71:	f7 74 24 08          	divl   0x8(%esp)
  801e75:	89 d1                	mov    %edx,%ecx
  801e77:	89 f3                	mov    %esi,%ebx
  801e79:	f7 64 24 0c          	mull   0xc(%esp)
  801e7d:	89 c6                	mov    %eax,%esi
  801e7f:	89 d7                	mov    %edx,%edi
  801e81:	39 d1                	cmp    %edx,%ecx
  801e83:	72 06                	jb     801e8b <__umoddi3+0x10b>
  801e85:	75 10                	jne    801e97 <__umoddi3+0x117>
  801e87:	39 c3                	cmp    %eax,%ebx
  801e89:	73 0c                	jae    801e97 <__umoddi3+0x117>
  801e8b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801e8f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801e93:	89 d7                	mov    %edx,%edi
  801e95:	89 c6                	mov    %eax,%esi
  801e97:	89 ca                	mov    %ecx,%edx
  801e99:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801e9e:	29 f3                	sub    %esi,%ebx
  801ea0:	19 fa                	sbb    %edi,%edx
  801ea2:	89 d0                	mov    %edx,%eax
  801ea4:	d3 e0                	shl    %cl,%eax
  801ea6:	89 e9                	mov    %ebp,%ecx
  801ea8:	d3 eb                	shr    %cl,%ebx
  801eaa:	d3 ea                	shr    %cl,%edx
  801eac:	09 d8                	or     %ebx,%eax
  801eae:	83 c4 1c             	add    $0x1c,%esp
  801eb1:	5b                   	pop    %ebx
  801eb2:	5e                   	pop    %esi
  801eb3:	5f                   	pop    %edi
  801eb4:	5d                   	pop    %ebp
  801eb5:	c3                   	ret    
  801eb6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ebd:	8d 76 00             	lea    0x0(%esi),%esi
  801ec0:	29 fe                	sub    %edi,%esi
  801ec2:	19 c3                	sbb    %eax,%ebx
  801ec4:	89 f2                	mov    %esi,%edx
  801ec6:	89 d9                	mov    %ebx,%ecx
  801ec8:	e9 1d ff ff ff       	jmp    801dea <__umoddi3+0x6a>
