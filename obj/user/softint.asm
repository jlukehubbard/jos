
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
  800125:	68 ca 1e 80 00       	push   $0x801eca
  80012a:	6a 23                	push   $0x23
  80012c:	68 e7 1e 80 00       	push   $0x801ee7
  800131:	e8 70 0f 00 00       	call   8010a6 <_panic>

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
  8001b2:	68 ca 1e 80 00       	push   $0x801eca
  8001b7:	6a 23                	push   $0x23
  8001b9:	68 e7 1e 80 00       	push   $0x801ee7
  8001be:	e8 e3 0e 00 00       	call   8010a6 <_panic>

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
  8001f8:	68 ca 1e 80 00       	push   $0x801eca
  8001fd:	6a 23                	push   $0x23
  8001ff:	68 e7 1e 80 00       	push   $0x801ee7
  800204:	e8 9d 0e 00 00       	call   8010a6 <_panic>

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
  80023e:	68 ca 1e 80 00       	push   $0x801eca
  800243:	6a 23                	push   $0x23
  800245:	68 e7 1e 80 00       	push   $0x801ee7
  80024a:	e8 57 0e 00 00       	call   8010a6 <_panic>

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
  800284:	68 ca 1e 80 00       	push   $0x801eca
  800289:	6a 23                	push   $0x23
  80028b:	68 e7 1e 80 00       	push   $0x801ee7
  800290:	e8 11 0e 00 00       	call   8010a6 <_panic>

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
  8002ca:	68 ca 1e 80 00       	push   $0x801eca
  8002cf:	6a 23                	push   $0x23
  8002d1:	68 e7 1e 80 00       	push   $0x801ee7
  8002d6:	e8 cb 0d 00 00       	call   8010a6 <_panic>

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
  800310:	68 ca 1e 80 00       	push   $0x801eca
  800315:	6a 23                	push   $0x23
  800317:	68 e7 1e 80 00       	push   $0x801ee7
  80031c:	e8 85 0d 00 00       	call   8010a6 <_panic>

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
  80037c:	68 ca 1e 80 00       	push   $0x801eca
  800381:	6a 23                	push   $0x23
  800383:	68 e7 1e 80 00       	push   $0x801ee7
  800388:	e8 19 0d 00 00       	call   8010a6 <_panic>

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
  800473:	ba 74 1f 80 00       	mov    $0x801f74,%edx
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
  800497:	68 f8 1e 80 00       	push   $0x801ef8
  80049c:	e8 ec 0c 00 00       	call   80118d <cprintf>
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
  800705:	68 39 1f 80 00       	push   $0x801f39
  80070a:	e8 7e 0a 00 00       	call   80118d <cprintf>
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
  8007d6:	68 55 1f 80 00       	push   $0x801f55
  8007db:	e8 ad 09 00 00       	call   80118d <cprintf>
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
  800886:	68 18 1f 80 00       	push   $0x801f18
  80088b:	e8 fd 08 00 00       	call   80118d <cprintf>
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
  80092a:	e8 cf 01 00 00       	call   800afe <open>
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
  80097c:	e8 de 11 00 00       	call   801b5f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800981:	83 c4 0c             	add    $0xc,%esp
  800984:	6a 00                	push   $0x0
  800986:	53                   	push   %ebx
  800987:	6a 00                	push   $0x0
  800989:	e8 7a 11 00 00       	call   801b08 <ipc_recv>
}
  80098e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800991:	5b                   	pop    %ebx
  800992:	5e                   	pop    %esi
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800995:	83 ec 0c             	sub    $0xc,%esp
  800998:	6a 01                	push   $0x1
  80099a:	e8 26 12 00 00       	call   801bc5 <ipc_find_env>
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
  800a32:	e8 5f 0d 00 00       	call   801796 <strcpy>
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
	panic("devfile_write not implemented");
  800a64:	68 84 1f 80 00       	push   $0x801f84
  800a69:	68 90 00 00 00       	push   $0x90
  800a6e:	68 a2 1f 80 00       	push   $0x801fa2
  800a73:	e8 2e 06 00 00       	call   8010a6 <_panic>

00800a78 <devfile_read>:
{
  800a78:	f3 0f 1e fb          	endbr32 
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a8f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a95:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9f:	e8 b8 fe ff ff       	call   80095c <fsipc>
  800aa4:	89 c3                	mov    %eax,%ebx
  800aa6:	85 c0                	test   %eax,%eax
  800aa8:	78 1f                	js     800ac9 <devfile_read+0x51>
	assert(r <= n);
  800aaa:	39 f0                	cmp    %esi,%eax
  800aac:	77 24                	ja     800ad2 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800aae:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ab3:	7f 33                	jg     800ae8 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ab5:	83 ec 04             	sub    $0x4,%esp
  800ab8:	50                   	push   %eax
  800ab9:	68 00 50 80 00       	push   $0x805000
  800abe:	ff 75 0c             	pushl  0xc(%ebp)
  800ac1:	e8 86 0e 00 00       	call   80194c <memmove>
	return r;
  800ac6:	83 c4 10             	add    $0x10,%esp
}
  800ac9:	89 d8                	mov    %ebx,%eax
  800acb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    
	assert(r <= n);
  800ad2:	68 ad 1f 80 00       	push   $0x801fad
  800ad7:	68 b4 1f 80 00       	push   $0x801fb4
  800adc:	6a 7c                	push   $0x7c
  800ade:	68 a2 1f 80 00       	push   $0x801fa2
  800ae3:	e8 be 05 00 00       	call   8010a6 <_panic>
	assert(r <= PGSIZE);
  800ae8:	68 c9 1f 80 00       	push   $0x801fc9
  800aed:	68 b4 1f 80 00       	push   $0x801fb4
  800af2:	6a 7d                	push   $0x7d
  800af4:	68 a2 1f 80 00       	push   $0x801fa2
  800af9:	e8 a8 05 00 00       	call   8010a6 <_panic>

00800afe <open>:
{
  800afe:	f3 0f 1e fb          	endbr32 
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	83 ec 1c             	sub    $0x1c,%esp
  800b0a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b0d:	56                   	push   %esi
  800b0e:	e8 40 0c 00 00       	call   801753 <strlen>
  800b13:	83 c4 10             	add    $0x10,%esp
  800b16:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b1b:	7f 6c                	jg     800b89 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800b1d:	83 ec 0c             	sub    $0xc,%esp
  800b20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b23:	50                   	push   %eax
  800b24:	e8 93 f8 ff ff       	call   8003bc <fd_alloc>
  800b29:	89 c3                	mov    %eax,%ebx
  800b2b:	83 c4 10             	add    $0x10,%esp
  800b2e:	85 c0                	test   %eax,%eax
  800b30:	78 3c                	js     800b6e <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b32:	83 ec 08             	sub    $0x8,%esp
  800b35:	56                   	push   %esi
  800b36:	68 00 50 80 00       	push   $0x805000
  800b3b:	e8 56 0c 00 00       	call   801796 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b43:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b48:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b4b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b50:	e8 07 fe ff ff       	call   80095c <fsipc>
  800b55:	89 c3                	mov    %eax,%ebx
  800b57:	83 c4 10             	add    $0x10,%esp
  800b5a:	85 c0                	test   %eax,%eax
  800b5c:	78 19                	js     800b77 <open+0x79>
	return fd2num(fd);
  800b5e:	83 ec 0c             	sub    $0xc,%esp
  800b61:	ff 75 f4             	pushl  -0xc(%ebp)
  800b64:	e8 24 f8 ff ff       	call   80038d <fd2num>
  800b69:	89 c3                	mov    %eax,%ebx
  800b6b:	83 c4 10             	add    $0x10,%esp
}
  800b6e:	89 d8                	mov    %ebx,%eax
  800b70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    
		fd_close(fd, 0);
  800b77:	83 ec 08             	sub    $0x8,%esp
  800b7a:	6a 00                	push   $0x0
  800b7c:	ff 75 f4             	pushl  -0xc(%ebp)
  800b7f:	e8 3c f9 ff ff       	call   8004c0 <fd_close>
		return r;
  800b84:	83 c4 10             	add    $0x10,%esp
  800b87:	eb e5                	jmp    800b6e <open+0x70>
		return -E_BAD_PATH;
  800b89:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b8e:	eb de                	jmp    800b6e <open+0x70>

00800b90 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b90:	f3 0f 1e fb          	endbr32 
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9f:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba4:	e8 b3 fd ff ff       	call   80095c <fsipc>
}
  800ba9:	c9                   	leave  
  800baa:	c3                   	ret    

00800bab <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bab:	f3 0f 1e fb          	endbr32 
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bb7:	83 ec 0c             	sub    $0xc,%esp
  800bba:	ff 75 08             	pushl  0x8(%ebp)
  800bbd:	e8 df f7 ff ff       	call   8003a1 <fd2data>
  800bc2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bc4:	83 c4 08             	add    $0x8,%esp
  800bc7:	68 d5 1f 80 00       	push   $0x801fd5
  800bcc:	53                   	push   %ebx
  800bcd:	e8 c4 0b 00 00       	call   801796 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bd2:	8b 46 04             	mov    0x4(%esi),%eax
  800bd5:	2b 06                	sub    (%esi),%eax
  800bd7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bdd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800be4:	00 00 00 
	stat->st_dev = &devpipe;
  800be7:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bee:	30 80 00 
	return 0;
}
  800bf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bfd:	f3 0f 1e fb          	endbr32 
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	53                   	push   %ebx
  800c05:	83 ec 0c             	sub    $0xc,%esp
  800c08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c0b:	53                   	push   %ebx
  800c0c:	6a 00                	push   $0x0
  800c0e:	e8 f6 f5 ff ff       	call   800209 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c13:	89 1c 24             	mov    %ebx,(%esp)
  800c16:	e8 86 f7 ff ff       	call   8003a1 <fd2data>
  800c1b:	83 c4 08             	add    $0x8,%esp
  800c1e:	50                   	push   %eax
  800c1f:	6a 00                	push   $0x0
  800c21:	e8 e3 f5 ff ff       	call   800209 <sys_page_unmap>
}
  800c26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c29:	c9                   	leave  
  800c2a:	c3                   	ret    

00800c2b <_pipeisclosed>:
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 1c             	sub    $0x1c,%esp
  800c34:	89 c7                	mov    %eax,%edi
  800c36:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c38:	a1 04 40 80 00       	mov    0x804004,%eax
  800c3d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c40:	83 ec 0c             	sub    $0xc,%esp
  800c43:	57                   	push   %edi
  800c44:	e8 b9 0f 00 00       	call   801c02 <pageref>
  800c49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c4c:	89 34 24             	mov    %esi,(%esp)
  800c4f:	e8 ae 0f 00 00       	call   801c02 <pageref>
		nn = thisenv->env_runs;
  800c54:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c5a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c5d:	83 c4 10             	add    $0x10,%esp
  800c60:	39 cb                	cmp    %ecx,%ebx
  800c62:	74 1b                	je     800c7f <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c64:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c67:	75 cf                	jne    800c38 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c69:	8b 42 58             	mov    0x58(%edx),%eax
  800c6c:	6a 01                	push   $0x1
  800c6e:	50                   	push   %eax
  800c6f:	53                   	push   %ebx
  800c70:	68 dc 1f 80 00       	push   $0x801fdc
  800c75:	e8 13 05 00 00       	call   80118d <cprintf>
  800c7a:	83 c4 10             	add    $0x10,%esp
  800c7d:	eb b9                	jmp    800c38 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c7f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c82:	0f 94 c0             	sete   %al
  800c85:	0f b6 c0             	movzbl %al,%eax
}
  800c88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <devpipe_write>:
{
  800c90:	f3 0f 1e fb          	endbr32 
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	83 ec 28             	sub    $0x28,%esp
  800c9d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800ca0:	56                   	push   %esi
  800ca1:	e8 fb f6 ff ff       	call   8003a1 <fd2data>
  800ca6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800ca8:	83 c4 10             	add    $0x10,%esp
  800cab:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cb3:	74 4f                	je     800d04 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cb5:	8b 43 04             	mov    0x4(%ebx),%eax
  800cb8:	8b 0b                	mov    (%ebx),%ecx
  800cba:	8d 51 20             	lea    0x20(%ecx),%edx
  800cbd:	39 d0                	cmp    %edx,%eax
  800cbf:	72 14                	jb     800cd5 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800cc1:	89 da                	mov    %ebx,%edx
  800cc3:	89 f0                	mov    %esi,%eax
  800cc5:	e8 61 ff ff ff       	call   800c2b <_pipeisclosed>
  800cca:	85 c0                	test   %eax,%eax
  800ccc:	75 3b                	jne    800d09 <devpipe_write+0x79>
			sys_yield();
  800cce:	e8 86 f4 ff ff       	call   800159 <sys_yield>
  800cd3:	eb e0                	jmp    800cb5 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cdc:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cdf:	89 c2                	mov    %eax,%edx
  800ce1:	c1 fa 1f             	sar    $0x1f,%edx
  800ce4:	89 d1                	mov    %edx,%ecx
  800ce6:	c1 e9 1b             	shr    $0x1b,%ecx
  800ce9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cec:	83 e2 1f             	and    $0x1f,%edx
  800cef:	29 ca                	sub    %ecx,%edx
  800cf1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cf5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cf9:	83 c0 01             	add    $0x1,%eax
  800cfc:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cff:	83 c7 01             	add    $0x1,%edi
  800d02:	eb ac                	jmp    800cb0 <devpipe_write+0x20>
	return i;
  800d04:	8b 45 10             	mov    0x10(%ebp),%eax
  800d07:	eb 05                	jmp    800d0e <devpipe_write+0x7e>
				return 0;
  800d09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <devpipe_read>:
{
  800d16:	f3 0f 1e fb          	endbr32 
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	57                   	push   %edi
  800d1e:	56                   	push   %esi
  800d1f:	53                   	push   %ebx
  800d20:	83 ec 18             	sub    $0x18,%esp
  800d23:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800d26:	57                   	push   %edi
  800d27:	e8 75 f6 ff ff       	call   8003a1 <fd2data>
  800d2c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d2e:	83 c4 10             	add    $0x10,%esp
  800d31:	be 00 00 00 00       	mov    $0x0,%esi
  800d36:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d39:	75 14                	jne    800d4f <devpipe_read+0x39>
	return i;
  800d3b:	8b 45 10             	mov    0x10(%ebp),%eax
  800d3e:	eb 02                	jmp    800d42 <devpipe_read+0x2c>
				return i;
  800d40:	89 f0                	mov    %esi,%eax
}
  800d42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    
			sys_yield();
  800d4a:	e8 0a f4 ff ff       	call   800159 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d4f:	8b 03                	mov    (%ebx),%eax
  800d51:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d54:	75 18                	jne    800d6e <devpipe_read+0x58>
			if (i > 0)
  800d56:	85 f6                	test   %esi,%esi
  800d58:	75 e6                	jne    800d40 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d5a:	89 da                	mov    %ebx,%edx
  800d5c:	89 f8                	mov    %edi,%eax
  800d5e:	e8 c8 fe ff ff       	call   800c2b <_pipeisclosed>
  800d63:	85 c0                	test   %eax,%eax
  800d65:	74 e3                	je     800d4a <devpipe_read+0x34>
				return 0;
  800d67:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6c:	eb d4                	jmp    800d42 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d6e:	99                   	cltd   
  800d6f:	c1 ea 1b             	shr    $0x1b,%edx
  800d72:	01 d0                	add    %edx,%eax
  800d74:	83 e0 1f             	and    $0x1f,%eax
  800d77:	29 d0                	sub    %edx,%eax
  800d79:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d81:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d84:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d87:	83 c6 01             	add    $0x1,%esi
  800d8a:	eb aa                	jmp    800d36 <devpipe_read+0x20>

00800d8c <pipe>:
{
  800d8c:	f3 0f 1e fb          	endbr32 
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	56                   	push   %esi
  800d94:	53                   	push   %ebx
  800d95:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d9b:	50                   	push   %eax
  800d9c:	e8 1b f6 ff ff       	call   8003bc <fd_alloc>
  800da1:	89 c3                	mov    %eax,%ebx
  800da3:	83 c4 10             	add    $0x10,%esp
  800da6:	85 c0                	test   %eax,%eax
  800da8:	0f 88 23 01 00 00    	js     800ed1 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dae:	83 ec 04             	sub    $0x4,%esp
  800db1:	68 07 04 00 00       	push   $0x407
  800db6:	ff 75 f4             	pushl  -0xc(%ebp)
  800db9:	6a 00                	push   $0x0
  800dbb:	e8 bc f3 ff ff       	call   80017c <sys_page_alloc>
  800dc0:	89 c3                	mov    %eax,%ebx
  800dc2:	83 c4 10             	add    $0x10,%esp
  800dc5:	85 c0                	test   %eax,%eax
  800dc7:	0f 88 04 01 00 00    	js     800ed1 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800dcd:	83 ec 0c             	sub    $0xc,%esp
  800dd0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dd3:	50                   	push   %eax
  800dd4:	e8 e3 f5 ff ff       	call   8003bc <fd_alloc>
  800dd9:	89 c3                	mov    %eax,%ebx
  800ddb:	83 c4 10             	add    $0x10,%esp
  800dde:	85 c0                	test   %eax,%eax
  800de0:	0f 88 db 00 00 00    	js     800ec1 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de6:	83 ec 04             	sub    $0x4,%esp
  800de9:	68 07 04 00 00       	push   $0x407
  800dee:	ff 75 f0             	pushl  -0x10(%ebp)
  800df1:	6a 00                	push   $0x0
  800df3:	e8 84 f3 ff ff       	call   80017c <sys_page_alloc>
  800df8:	89 c3                	mov    %eax,%ebx
  800dfa:	83 c4 10             	add    $0x10,%esp
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	0f 88 bc 00 00 00    	js     800ec1 <pipe+0x135>
	va = fd2data(fd0);
  800e05:	83 ec 0c             	sub    $0xc,%esp
  800e08:	ff 75 f4             	pushl  -0xc(%ebp)
  800e0b:	e8 91 f5 ff ff       	call   8003a1 <fd2data>
  800e10:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e12:	83 c4 0c             	add    $0xc,%esp
  800e15:	68 07 04 00 00       	push   $0x407
  800e1a:	50                   	push   %eax
  800e1b:	6a 00                	push   $0x0
  800e1d:	e8 5a f3 ff ff       	call   80017c <sys_page_alloc>
  800e22:	89 c3                	mov    %eax,%ebx
  800e24:	83 c4 10             	add    $0x10,%esp
  800e27:	85 c0                	test   %eax,%eax
  800e29:	0f 88 82 00 00 00    	js     800eb1 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e2f:	83 ec 0c             	sub    $0xc,%esp
  800e32:	ff 75 f0             	pushl  -0x10(%ebp)
  800e35:	e8 67 f5 ff ff       	call   8003a1 <fd2data>
  800e3a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e41:	50                   	push   %eax
  800e42:	6a 00                	push   $0x0
  800e44:	56                   	push   %esi
  800e45:	6a 00                	push   $0x0
  800e47:	e8 77 f3 ff ff       	call   8001c3 <sys_page_map>
  800e4c:	89 c3                	mov    %eax,%ebx
  800e4e:	83 c4 20             	add    $0x20,%esp
  800e51:	85 c0                	test   %eax,%eax
  800e53:	78 4e                	js     800ea3 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e55:	a1 20 30 80 00       	mov    0x803020,%eax
  800e5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e5d:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e62:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e69:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e6c:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e71:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e78:	83 ec 0c             	sub    $0xc,%esp
  800e7b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e7e:	e8 0a f5 ff ff       	call   80038d <fd2num>
  800e83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e86:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e88:	83 c4 04             	add    $0x4,%esp
  800e8b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e8e:	e8 fa f4 ff ff       	call   80038d <fd2num>
  800e93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e96:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e99:	83 c4 10             	add    $0x10,%esp
  800e9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea1:	eb 2e                	jmp    800ed1 <pipe+0x145>
	sys_page_unmap(0, va);
  800ea3:	83 ec 08             	sub    $0x8,%esp
  800ea6:	56                   	push   %esi
  800ea7:	6a 00                	push   $0x0
  800ea9:	e8 5b f3 ff ff       	call   800209 <sys_page_unmap>
  800eae:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800eb1:	83 ec 08             	sub    $0x8,%esp
  800eb4:	ff 75 f0             	pushl  -0x10(%ebp)
  800eb7:	6a 00                	push   $0x0
  800eb9:	e8 4b f3 ff ff       	call   800209 <sys_page_unmap>
  800ebe:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800ec1:	83 ec 08             	sub    $0x8,%esp
  800ec4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec7:	6a 00                	push   $0x0
  800ec9:	e8 3b f3 ff ff       	call   800209 <sys_page_unmap>
  800ece:	83 c4 10             	add    $0x10,%esp
}
  800ed1:	89 d8                	mov    %ebx,%eax
  800ed3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed6:	5b                   	pop    %ebx
  800ed7:	5e                   	pop    %esi
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <pipeisclosed>:
{
  800eda:	f3 0f 1e fb          	endbr32 
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ee4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ee7:	50                   	push   %eax
  800ee8:	ff 75 08             	pushl  0x8(%ebp)
  800eeb:	e8 22 f5 ff ff       	call   800412 <fd_lookup>
  800ef0:	83 c4 10             	add    $0x10,%esp
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	78 18                	js     800f0f <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800ef7:	83 ec 0c             	sub    $0xc,%esp
  800efa:	ff 75 f4             	pushl  -0xc(%ebp)
  800efd:	e8 9f f4 ff ff       	call   8003a1 <fd2data>
  800f02:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f07:	e8 1f fd ff ff       	call   800c2b <_pipeisclosed>
  800f0c:	83 c4 10             	add    $0x10,%esp
}
  800f0f:	c9                   	leave  
  800f10:	c3                   	ret    

00800f11 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f11:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800f15:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1a:	c3                   	ret    

00800f1b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f1b:	f3 0f 1e fb          	endbr32 
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f25:	68 f4 1f 80 00       	push   $0x801ff4
  800f2a:	ff 75 0c             	pushl  0xc(%ebp)
  800f2d:	e8 64 08 00 00       	call   801796 <strcpy>
	return 0;
}
  800f32:	b8 00 00 00 00       	mov    $0x0,%eax
  800f37:	c9                   	leave  
  800f38:	c3                   	ret    

00800f39 <devcons_write>:
{
  800f39:	f3 0f 1e fb          	endbr32 
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	57                   	push   %edi
  800f41:	56                   	push   %esi
  800f42:	53                   	push   %ebx
  800f43:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f49:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f4e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f54:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f57:	73 31                	jae    800f8a <devcons_write+0x51>
		m = n - tot;
  800f59:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f5c:	29 f3                	sub    %esi,%ebx
  800f5e:	83 fb 7f             	cmp    $0x7f,%ebx
  800f61:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f66:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f69:	83 ec 04             	sub    $0x4,%esp
  800f6c:	53                   	push   %ebx
  800f6d:	89 f0                	mov    %esi,%eax
  800f6f:	03 45 0c             	add    0xc(%ebp),%eax
  800f72:	50                   	push   %eax
  800f73:	57                   	push   %edi
  800f74:	e8 d3 09 00 00       	call   80194c <memmove>
		sys_cputs(buf, m);
  800f79:	83 c4 08             	add    $0x8,%esp
  800f7c:	53                   	push   %ebx
  800f7d:	57                   	push   %edi
  800f7e:	e8 29 f1 ff ff       	call   8000ac <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f83:	01 de                	add    %ebx,%esi
  800f85:	83 c4 10             	add    $0x10,%esp
  800f88:	eb ca                	jmp    800f54 <devcons_write+0x1b>
}
  800f8a:	89 f0                	mov    %esi,%eax
  800f8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f8f:	5b                   	pop    %ebx
  800f90:	5e                   	pop    %esi
  800f91:	5f                   	pop    %edi
  800f92:	5d                   	pop    %ebp
  800f93:	c3                   	ret    

00800f94 <devcons_read>:
{
  800f94:	f3 0f 1e fb          	endbr32 
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	83 ec 08             	sub    $0x8,%esp
  800f9e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800fa3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fa7:	74 21                	je     800fca <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800fa9:	e8 20 f1 ff ff       	call   8000ce <sys_cgetc>
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	75 07                	jne    800fb9 <devcons_read+0x25>
		sys_yield();
  800fb2:	e8 a2 f1 ff ff       	call   800159 <sys_yield>
  800fb7:	eb f0                	jmp    800fa9 <devcons_read+0x15>
	if (c < 0)
  800fb9:	78 0f                	js     800fca <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800fbb:	83 f8 04             	cmp    $0x4,%eax
  800fbe:	74 0c                	je     800fcc <devcons_read+0x38>
	*(char*)vbuf = c;
  800fc0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc3:	88 02                	mov    %al,(%edx)
	return 1;
  800fc5:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800fca:	c9                   	leave  
  800fcb:	c3                   	ret    
		return 0;
  800fcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd1:	eb f7                	jmp    800fca <devcons_read+0x36>

00800fd3 <cputchar>:
{
  800fd3:	f3 0f 1e fb          	endbr32 
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe0:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800fe3:	6a 01                	push   $0x1
  800fe5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fe8:	50                   	push   %eax
  800fe9:	e8 be f0 ff ff       	call   8000ac <sys_cputs>
}
  800fee:	83 c4 10             	add    $0x10,%esp
  800ff1:	c9                   	leave  
  800ff2:	c3                   	ret    

00800ff3 <getchar>:
{
  800ff3:	f3 0f 1e fb          	endbr32 
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800ffd:	6a 01                	push   $0x1
  800fff:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801002:	50                   	push   %eax
  801003:	6a 00                	push   $0x0
  801005:	e8 8b f6 ff ff       	call   800695 <read>
	if (r < 0)
  80100a:	83 c4 10             	add    $0x10,%esp
  80100d:	85 c0                	test   %eax,%eax
  80100f:	78 06                	js     801017 <getchar+0x24>
	if (r < 1)
  801011:	74 06                	je     801019 <getchar+0x26>
	return c;
  801013:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801017:	c9                   	leave  
  801018:	c3                   	ret    
		return -E_EOF;
  801019:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80101e:	eb f7                	jmp    801017 <getchar+0x24>

00801020 <iscons>:
{
  801020:	f3 0f 1e fb          	endbr32 
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80102a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102d:	50                   	push   %eax
  80102e:	ff 75 08             	pushl  0x8(%ebp)
  801031:	e8 dc f3 ff ff       	call   800412 <fd_lookup>
  801036:	83 c4 10             	add    $0x10,%esp
  801039:	85 c0                	test   %eax,%eax
  80103b:	78 11                	js     80104e <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80103d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801040:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801046:	39 10                	cmp    %edx,(%eax)
  801048:	0f 94 c0             	sete   %al
  80104b:	0f b6 c0             	movzbl %al,%eax
}
  80104e:	c9                   	leave  
  80104f:	c3                   	ret    

00801050 <opencons>:
{
  801050:	f3 0f 1e fb          	endbr32 
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80105a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80105d:	50                   	push   %eax
  80105e:	e8 59 f3 ff ff       	call   8003bc <fd_alloc>
  801063:	83 c4 10             	add    $0x10,%esp
  801066:	85 c0                	test   %eax,%eax
  801068:	78 3a                	js     8010a4 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80106a:	83 ec 04             	sub    $0x4,%esp
  80106d:	68 07 04 00 00       	push   $0x407
  801072:	ff 75 f4             	pushl  -0xc(%ebp)
  801075:	6a 00                	push   $0x0
  801077:	e8 00 f1 ff ff       	call   80017c <sys_page_alloc>
  80107c:	83 c4 10             	add    $0x10,%esp
  80107f:	85 c0                	test   %eax,%eax
  801081:	78 21                	js     8010a4 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801083:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801086:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80108c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80108e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801091:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801098:	83 ec 0c             	sub    $0xc,%esp
  80109b:	50                   	push   %eax
  80109c:	e8 ec f2 ff ff       	call   80038d <fd2num>
  8010a1:	83 c4 10             	add    $0x10,%esp
}
  8010a4:	c9                   	leave  
  8010a5:	c3                   	ret    

008010a6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010a6:	f3 0f 1e fb          	endbr32 
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	56                   	push   %esi
  8010ae:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010af:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010b2:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010b8:	e8 79 f0 ff ff       	call   800136 <sys_getenvid>
  8010bd:	83 ec 0c             	sub    $0xc,%esp
  8010c0:	ff 75 0c             	pushl  0xc(%ebp)
  8010c3:	ff 75 08             	pushl  0x8(%ebp)
  8010c6:	56                   	push   %esi
  8010c7:	50                   	push   %eax
  8010c8:	68 00 20 80 00       	push   $0x802000
  8010cd:	e8 bb 00 00 00       	call   80118d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010d2:	83 c4 18             	add    $0x18,%esp
  8010d5:	53                   	push   %ebx
  8010d6:	ff 75 10             	pushl  0x10(%ebp)
  8010d9:	e8 5a 00 00 00       	call   801138 <vcprintf>
	cprintf("\n");
  8010de:	c7 04 24 ed 1f 80 00 	movl   $0x801fed,(%esp)
  8010e5:	e8 a3 00 00 00       	call   80118d <cprintf>
  8010ea:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010ed:	cc                   	int3   
  8010ee:	eb fd                	jmp    8010ed <_panic+0x47>

008010f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010f0:	f3 0f 1e fb          	endbr32 
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	53                   	push   %ebx
  8010f8:	83 ec 04             	sub    $0x4,%esp
  8010fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010fe:	8b 13                	mov    (%ebx),%edx
  801100:	8d 42 01             	lea    0x1(%edx),%eax
  801103:	89 03                	mov    %eax,(%ebx)
  801105:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801108:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80110c:	3d ff 00 00 00       	cmp    $0xff,%eax
  801111:	74 09                	je     80111c <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801113:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801117:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80111a:	c9                   	leave  
  80111b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80111c:	83 ec 08             	sub    $0x8,%esp
  80111f:	68 ff 00 00 00       	push   $0xff
  801124:	8d 43 08             	lea    0x8(%ebx),%eax
  801127:	50                   	push   %eax
  801128:	e8 7f ef ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  80112d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801133:	83 c4 10             	add    $0x10,%esp
  801136:	eb db                	jmp    801113 <putch+0x23>

00801138 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801138:	f3 0f 1e fb          	endbr32 
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801145:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80114c:	00 00 00 
	b.cnt = 0;
  80114f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801156:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801159:	ff 75 0c             	pushl  0xc(%ebp)
  80115c:	ff 75 08             	pushl  0x8(%ebp)
  80115f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801165:	50                   	push   %eax
  801166:	68 f0 10 80 00       	push   $0x8010f0
  80116b:	e8 20 01 00 00       	call   801290 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801170:	83 c4 08             	add    $0x8,%esp
  801173:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801179:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80117f:	50                   	push   %eax
  801180:	e8 27 ef ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  801185:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80118b:	c9                   	leave  
  80118c:	c3                   	ret    

0080118d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80118d:	f3 0f 1e fb          	endbr32 
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801197:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80119a:	50                   	push   %eax
  80119b:	ff 75 08             	pushl  0x8(%ebp)
  80119e:	e8 95 ff ff ff       	call   801138 <vcprintf>
	va_end(ap);

	return cnt;
}
  8011a3:	c9                   	leave  
  8011a4:	c3                   	ret    

008011a5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	57                   	push   %edi
  8011a9:	56                   	push   %esi
  8011aa:	53                   	push   %ebx
  8011ab:	83 ec 1c             	sub    $0x1c,%esp
  8011ae:	89 c7                	mov    %eax,%edi
  8011b0:	89 d6                	mov    %edx,%esi
  8011b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b8:	89 d1                	mov    %edx,%ecx
  8011ba:	89 c2                	mov    %eax,%edx
  8011bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011bf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8011c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8011c5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011cb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8011d2:	39 c2                	cmp    %eax,%edx
  8011d4:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8011d7:	72 3e                	jb     801217 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011d9:	83 ec 0c             	sub    $0xc,%esp
  8011dc:	ff 75 18             	pushl  0x18(%ebp)
  8011df:	83 eb 01             	sub    $0x1,%ebx
  8011e2:	53                   	push   %ebx
  8011e3:	50                   	push   %eax
  8011e4:	83 ec 08             	sub    $0x8,%esp
  8011e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ed:	ff 75 dc             	pushl  -0x24(%ebp)
  8011f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8011f3:	e8 58 0a 00 00       	call   801c50 <__udivdi3>
  8011f8:	83 c4 18             	add    $0x18,%esp
  8011fb:	52                   	push   %edx
  8011fc:	50                   	push   %eax
  8011fd:	89 f2                	mov    %esi,%edx
  8011ff:	89 f8                	mov    %edi,%eax
  801201:	e8 9f ff ff ff       	call   8011a5 <printnum>
  801206:	83 c4 20             	add    $0x20,%esp
  801209:	eb 13                	jmp    80121e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80120b:	83 ec 08             	sub    $0x8,%esp
  80120e:	56                   	push   %esi
  80120f:	ff 75 18             	pushl  0x18(%ebp)
  801212:	ff d7                	call   *%edi
  801214:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801217:	83 eb 01             	sub    $0x1,%ebx
  80121a:	85 db                	test   %ebx,%ebx
  80121c:	7f ed                	jg     80120b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80121e:	83 ec 08             	sub    $0x8,%esp
  801221:	56                   	push   %esi
  801222:	83 ec 04             	sub    $0x4,%esp
  801225:	ff 75 e4             	pushl  -0x1c(%ebp)
  801228:	ff 75 e0             	pushl  -0x20(%ebp)
  80122b:	ff 75 dc             	pushl  -0x24(%ebp)
  80122e:	ff 75 d8             	pushl  -0x28(%ebp)
  801231:	e8 2a 0b 00 00       	call   801d60 <__umoddi3>
  801236:	83 c4 14             	add    $0x14,%esp
  801239:	0f be 80 23 20 80 00 	movsbl 0x802023(%eax),%eax
  801240:	50                   	push   %eax
  801241:	ff d7                	call   *%edi
}
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801249:	5b                   	pop    %ebx
  80124a:	5e                   	pop    %esi
  80124b:	5f                   	pop    %edi
  80124c:	5d                   	pop    %ebp
  80124d:	c3                   	ret    

0080124e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80124e:	f3 0f 1e fb          	endbr32 
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801258:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80125c:	8b 10                	mov    (%eax),%edx
  80125e:	3b 50 04             	cmp    0x4(%eax),%edx
  801261:	73 0a                	jae    80126d <sprintputch+0x1f>
		*b->buf++ = ch;
  801263:	8d 4a 01             	lea    0x1(%edx),%ecx
  801266:	89 08                	mov    %ecx,(%eax)
  801268:	8b 45 08             	mov    0x8(%ebp),%eax
  80126b:	88 02                	mov    %al,(%edx)
}
  80126d:	5d                   	pop    %ebp
  80126e:	c3                   	ret    

0080126f <printfmt>:
{
  80126f:	f3 0f 1e fb          	endbr32 
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801279:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80127c:	50                   	push   %eax
  80127d:	ff 75 10             	pushl  0x10(%ebp)
  801280:	ff 75 0c             	pushl  0xc(%ebp)
  801283:	ff 75 08             	pushl  0x8(%ebp)
  801286:	e8 05 00 00 00       	call   801290 <vprintfmt>
}
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	c9                   	leave  
  80128f:	c3                   	ret    

00801290 <vprintfmt>:
{
  801290:	f3 0f 1e fb          	endbr32 
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	57                   	push   %edi
  801298:	56                   	push   %esi
  801299:	53                   	push   %ebx
  80129a:	83 ec 3c             	sub    $0x3c,%esp
  80129d:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012a3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012a6:	e9 4a 03 00 00       	jmp    8015f5 <vprintfmt+0x365>
		padc = ' ';
  8012ab:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012af:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012b6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012bd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012c4:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012c9:	8d 47 01             	lea    0x1(%edi),%eax
  8012cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012cf:	0f b6 17             	movzbl (%edi),%edx
  8012d2:	8d 42 dd             	lea    -0x23(%edx),%eax
  8012d5:	3c 55                	cmp    $0x55,%al
  8012d7:	0f 87 de 03 00 00    	ja     8016bb <vprintfmt+0x42b>
  8012dd:	0f b6 c0             	movzbl %al,%eax
  8012e0:	3e ff 24 85 60 21 80 	notrack jmp *0x802160(,%eax,4)
  8012e7:	00 
  8012e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8012eb:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8012ef:	eb d8                	jmp    8012c9 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8012f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012f4:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8012f8:	eb cf                	jmp    8012c9 <vprintfmt+0x39>
  8012fa:	0f b6 d2             	movzbl %dl,%edx
  8012fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801300:	b8 00 00 00 00       	mov    $0x0,%eax
  801305:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801308:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80130b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80130f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801312:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801315:	83 f9 09             	cmp    $0x9,%ecx
  801318:	77 55                	ja     80136f <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80131a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80131d:	eb e9                	jmp    801308 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80131f:	8b 45 14             	mov    0x14(%ebp),%eax
  801322:	8b 00                	mov    (%eax),%eax
  801324:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801327:	8b 45 14             	mov    0x14(%ebp),%eax
  80132a:	8d 40 04             	lea    0x4(%eax),%eax
  80132d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801330:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801333:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801337:	79 90                	jns    8012c9 <vprintfmt+0x39>
				width = precision, precision = -1;
  801339:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80133c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80133f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801346:	eb 81                	jmp    8012c9 <vprintfmt+0x39>
  801348:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80134b:	85 c0                	test   %eax,%eax
  80134d:	ba 00 00 00 00       	mov    $0x0,%edx
  801352:	0f 49 d0             	cmovns %eax,%edx
  801355:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801358:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80135b:	e9 69 ff ff ff       	jmp    8012c9 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801363:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80136a:	e9 5a ff ff ff       	jmp    8012c9 <vprintfmt+0x39>
  80136f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801372:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801375:	eb bc                	jmp    801333 <vprintfmt+0xa3>
			lflag++;
  801377:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80137a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80137d:	e9 47 ff ff ff       	jmp    8012c9 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  801382:	8b 45 14             	mov    0x14(%ebp),%eax
  801385:	8d 78 04             	lea    0x4(%eax),%edi
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	53                   	push   %ebx
  80138c:	ff 30                	pushl  (%eax)
  80138e:	ff d6                	call   *%esi
			break;
  801390:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801393:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801396:	e9 57 02 00 00       	jmp    8015f2 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80139b:	8b 45 14             	mov    0x14(%ebp),%eax
  80139e:	8d 78 04             	lea    0x4(%eax),%edi
  8013a1:	8b 00                	mov    (%eax),%eax
  8013a3:	99                   	cltd   
  8013a4:	31 d0                	xor    %edx,%eax
  8013a6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013a8:	83 f8 0f             	cmp    $0xf,%eax
  8013ab:	7f 23                	jg     8013d0 <vprintfmt+0x140>
  8013ad:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  8013b4:	85 d2                	test   %edx,%edx
  8013b6:	74 18                	je     8013d0 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8013b8:	52                   	push   %edx
  8013b9:	68 c6 1f 80 00       	push   $0x801fc6
  8013be:	53                   	push   %ebx
  8013bf:	56                   	push   %esi
  8013c0:	e8 aa fe ff ff       	call   80126f <printfmt>
  8013c5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8013c8:	89 7d 14             	mov    %edi,0x14(%ebp)
  8013cb:	e9 22 02 00 00       	jmp    8015f2 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8013d0:	50                   	push   %eax
  8013d1:	68 3b 20 80 00       	push   $0x80203b
  8013d6:	53                   	push   %ebx
  8013d7:	56                   	push   %esi
  8013d8:	e8 92 fe ff ff       	call   80126f <printfmt>
  8013dd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8013e0:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8013e3:	e9 0a 02 00 00       	jmp    8015f2 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8013e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8013eb:	83 c0 04             	add    $0x4,%eax
  8013ee:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8013f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8013f4:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8013f6:	85 d2                	test   %edx,%edx
  8013f8:	b8 34 20 80 00       	mov    $0x802034,%eax
  8013fd:	0f 45 c2             	cmovne %edx,%eax
  801400:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801403:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801407:	7e 06                	jle    80140f <vprintfmt+0x17f>
  801409:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80140d:	75 0d                	jne    80141c <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80140f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801412:	89 c7                	mov    %eax,%edi
  801414:	03 45 e0             	add    -0x20(%ebp),%eax
  801417:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80141a:	eb 55                	jmp    801471 <vprintfmt+0x1e1>
  80141c:	83 ec 08             	sub    $0x8,%esp
  80141f:	ff 75 d8             	pushl  -0x28(%ebp)
  801422:	ff 75 cc             	pushl  -0x34(%ebp)
  801425:	e8 45 03 00 00       	call   80176f <strnlen>
  80142a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80142d:	29 c2                	sub    %eax,%edx
  80142f:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801432:	83 c4 10             	add    $0x10,%esp
  801435:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  801437:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80143b:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80143e:	85 ff                	test   %edi,%edi
  801440:	7e 11                	jle    801453 <vprintfmt+0x1c3>
					putch(padc, putdat);
  801442:	83 ec 08             	sub    $0x8,%esp
  801445:	53                   	push   %ebx
  801446:	ff 75 e0             	pushl  -0x20(%ebp)
  801449:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80144b:	83 ef 01             	sub    $0x1,%edi
  80144e:	83 c4 10             	add    $0x10,%esp
  801451:	eb eb                	jmp    80143e <vprintfmt+0x1ae>
  801453:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801456:	85 d2                	test   %edx,%edx
  801458:	b8 00 00 00 00       	mov    $0x0,%eax
  80145d:	0f 49 c2             	cmovns %edx,%eax
  801460:	29 c2                	sub    %eax,%edx
  801462:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801465:	eb a8                	jmp    80140f <vprintfmt+0x17f>
					putch(ch, putdat);
  801467:	83 ec 08             	sub    $0x8,%esp
  80146a:	53                   	push   %ebx
  80146b:	52                   	push   %edx
  80146c:	ff d6                	call   *%esi
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801474:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801476:	83 c7 01             	add    $0x1,%edi
  801479:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80147d:	0f be d0             	movsbl %al,%edx
  801480:	85 d2                	test   %edx,%edx
  801482:	74 4b                	je     8014cf <vprintfmt+0x23f>
  801484:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801488:	78 06                	js     801490 <vprintfmt+0x200>
  80148a:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80148e:	78 1e                	js     8014ae <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  801490:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801494:	74 d1                	je     801467 <vprintfmt+0x1d7>
  801496:	0f be c0             	movsbl %al,%eax
  801499:	83 e8 20             	sub    $0x20,%eax
  80149c:	83 f8 5e             	cmp    $0x5e,%eax
  80149f:	76 c6                	jbe    801467 <vprintfmt+0x1d7>
					putch('?', putdat);
  8014a1:	83 ec 08             	sub    $0x8,%esp
  8014a4:	53                   	push   %ebx
  8014a5:	6a 3f                	push   $0x3f
  8014a7:	ff d6                	call   *%esi
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	eb c3                	jmp    801471 <vprintfmt+0x1e1>
  8014ae:	89 cf                	mov    %ecx,%edi
  8014b0:	eb 0e                	jmp    8014c0 <vprintfmt+0x230>
				putch(' ', putdat);
  8014b2:	83 ec 08             	sub    $0x8,%esp
  8014b5:	53                   	push   %ebx
  8014b6:	6a 20                	push   $0x20
  8014b8:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8014ba:	83 ef 01             	sub    $0x1,%edi
  8014bd:	83 c4 10             	add    $0x10,%esp
  8014c0:	85 ff                	test   %edi,%edi
  8014c2:	7f ee                	jg     8014b2 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8014c4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8014c7:	89 45 14             	mov    %eax,0x14(%ebp)
  8014ca:	e9 23 01 00 00       	jmp    8015f2 <vprintfmt+0x362>
  8014cf:	89 cf                	mov    %ecx,%edi
  8014d1:	eb ed                	jmp    8014c0 <vprintfmt+0x230>
	if (lflag >= 2)
  8014d3:	83 f9 01             	cmp    $0x1,%ecx
  8014d6:	7f 1b                	jg     8014f3 <vprintfmt+0x263>
	else if (lflag)
  8014d8:	85 c9                	test   %ecx,%ecx
  8014da:	74 63                	je     80153f <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8014dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014df:	8b 00                	mov    (%eax),%eax
  8014e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014e4:	99                   	cltd   
  8014e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014eb:	8d 40 04             	lea    0x4(%eax),%eax
  8014ee:	89 45 14             	mov    %eax,0x14(%ebp)
  8014f1:	eb 17                	jmp    80150a <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8014f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f6:	8b 50 04             	mov    0x4(%eax),%edx
  8014f9:	8b 00                	mov    (%eax),%eax
  8014fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801501:	8b 45 14             	mov    0x14(%ebp),%eax
  801504:	8d 40 08             	lea    0x8(%eax),%eax
  801507:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80150a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80150d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801510:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  801515:	85 c9                	test   %ecx,%ecx
  801517:	0f 89 bb 00 00 00    	jns    8015d8 <vprintfmt+0x348>
				putch('-', putdat);
  80151d:	83 ec 08             	sub    $0x8,%esp
  801520:	53                   	push   %ebx
  801521:	6a 2d                	push   $0x2d
  801523:	ff d6                	call   *%esi
				num = -(long long) num;
  801525:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801528:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80152b:	f7 da                	neg    %edx
  80152d:	83 d1 00             	adc    $0x0,%ecx
  801530:	f7 d9                	neg    %ecx
  801532:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801535:	b8 0a 00 00 00       	mov    $0xa,%eax
  80153a:	e9 99 00 00 00       	jmp    8015d8 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80153f:	8b 45 14             	mov    0x14(%ebp),%eax
  801542:	8b 00                	mov    (%eax),%eax
  801544:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801547:	99                   	cltd   
  801548:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80154b:	8b 45 14             	mov    0x14(%ebp),%eax
  80154e:	8d 40 04             	lea    0x4(%eax),%eax
  801551:	89 45 14             	mov    %eax,0x14(%ebp)
  801554:	eb b4                	jmp    80150a <vprintfmt+0x27a>
	if (lflag >= 2)
  801556:	83 f9 01             	cmp    $0x1,%ecx
  801559:	7f 1b                	jg     801576 <vprintfmt+0x2e6>
	else if (lflag)
  80155b:	85 c9                	test   %ecx,%ecx
  80155d:	74 2c                	je     80158b <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80155f:	8b 45 14             	mov    0x14(%ebp),%eax
  801562:	8b 10                	mov    (%eax),%edx
  801564:	b9 00 00 00 00       	mov    $0x0,%ecx
  801569:	8d 40 04             	lea    0x4(%eax),%eax
  80156c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80156f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  801574:	eb 62                	jmp    8015d8 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  801576:	8b 45 14             	mov    0x14(%ebp),%eax
  801579:	8b 10                	mov    (%eax),%edx
  80157b:	8b 48 04             	mov    0x4(%eax),%ecx
  80157e:	8d 40 08             	lea    0x8(%eax),%eax
  801581:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801584:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  801589:	eb 4d                	jmp    8015d8 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80158b:	8b 45 14             	mov    0x14(%ebp),%eax
  80158e:	8b 10                	mov    (%eax),%edx
  801590:	b9 00 00 00 00       	mov    $0x0,%ecx
  801595:	8d 40 04             	lea    0x4(%eax),%eax
  801598:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80159b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8015a0:	eb 36                	jmp    8015d8 <vprintfmt+0x348>
	if (lflag >= 2)
  8015a2:	83 f9 01             	cmp    $0x1,%ecx
  8015a5:	7f 17                	jg     8015be <vprintfmt+0x32e>
	else if (lflag)
  8015a7:	85 c9                	test   %ecx,%ecx
  8015a9:	74 6e                	je     801619 <vprintfmt+0x389>
		return va_arg(*ap, long);
  8015ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ae:	8b 10                	mov    (%eax),%edx
  8015b0:	89 d0                	mov    %edx,%eax
  8015b2:	99                   	cltd   
  8015b3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015b6:	8d 49 04             	lea    0x4(%ecx),%ecx
  8015b9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8015bc:	eb 11                	jmp    8015cf <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8015be:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c1:	8b 50 04             	mov    0x4(%eax),%edx
  8015c4:	8b 00                	mov    (%eax),%eax
  8015c6:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015c9:	8d 49 08             	lea    0x8(%ecx),%ecx
  8015cc:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8015cf:	89 d1                	mov    %edx,%ecx
  8015d1:	89 c2                	mov    %eax,%edx
            base = 8;
  8015d3:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8015d8:	83 ec 0c             	sub    $0xc,%esp
  8015db:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8015df:	57                   	push   %edi
  8015e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8015e3:	50                   	push   %eax
  8015e4:	51                   	push   %ecx
  8015e5:	52                   	push   %edx
  8015e6:	89 da                	mov    %ebx,%edx
  8015e8:	89 f0                	mov    %esi,%eax
  8015ea:	e8 b6 fb ff ff       	call   8011a5 <printnum>
			break;
  8015ef:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8015f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015f5:	83 c7 01             	add    $0x1,%edi
  8015f8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015fc:	83 f8 25             	cmp    $0x25,%eax
  8015ff:	0f 84 a6 fc ff ff    	je     8012ab <vprintfmt+0x1b>
			if (ch == '\0')
  801605:	85 c0                	test   %eax,%eax
  801607:	0f 84 ce 00 00 00    	je     8016db <vprintfmt+0x44b>
			putch(ch, putdat);
  80160d:	83 ec 08             	sub    $0x8,%esp
  801610:	53                   	push   %ebx
  801611:	50                   	push   %eax
  801612:	ff d6                	call   *%esi
  801614:	83 c4 10             	add    $0x10,%esp
  801617:	eb dc                	jmp    8015f5 <vprintfmt+0x365>
		return va_arg(*ap, int);
  801619:	8b 45 14             	mov    0x14(%ebp),%eax
  80161c:	8b 10                	mov    (%eax),%edx
  80161e:	89 d0                	mov    %edx,%eax
  801620:	99                   	cltd   
  801621:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801624:	8d 49 04             	lea    0x4(%ecx),%ecx
  801627:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80162a:	eb a3                	jmp    8015cf <vprintfmt+0x33f>
			putch('0', putdat);
  80162c:	83 ec 08             	sub    $0x8,%esp
  80162f:	53                   	push   %ebx
  801630:	6a 30                	push   $0x30
  801632:	ff d6                	call   *%esi
			putch('x', putdat);
  801634:	83 c4 08             	add    $0x8,%esp
  801637:	53                   	push   %ebx
  801638:	6a 78                	push   $0x78
  80163a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80163c:	8b 45 14             	mov    0x14(%ebp),%eax
  80163f:	8b 10                	mov    (%eax),%edx
  801641:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801646:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801649:	8d 40 04             	lea    0x4(%eax),%eax
  80164c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80164f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801654:	eb 82                	jmp    8015d8 <vprintfmt+0x348>
	if (lflag >= 2)
  801656:	83 f9 01             	cmp    $0x1,%ecx
  801659:	7f 1e                	jg     801679 <vprintfmt+0x3e9>
	else if (lflag)
  80165b:	85 c9                	test   %ecx,%ecx
  80165d:	74 32                	je     801691 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80165f:	8b 45 14             	mov    0x14(%ebp),%eax
  801662:	8b 10                	mov    (%eax),%edx
  801664:	b9 00 00 00 00       	mov    $0x0,%ecx
  801669:	8d 40 04             	lea    0x4(%eax),%eax
  80166c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80166f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  801674:	e9 5f ff ff ff       	jmp    8015d8 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  801679:	8b 45 14             	mov    0x14(%ebp),%eax
  80167c:	8b 10                	mov    (%eax),%edx
  80167e:	8b 48 04             	mov    0x4(%eax),%ecx
  801681:	8d 40 08             	lea    0x8(%eax),%eax
  801684:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801687:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80168c:	e9 47 ff ff ff       	jmp    8015d8 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  801691:	8b 45 14             	mov    0x14(%ebp),%eax
  801694:	8b 10                	mov    (%eax),%edx
  801696:	b9 00 00 00 00       	mov    $0x0,%ecx
  80169b:	8d 40 04             	lea    0x4(%eax),%eax
  80169e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016a1:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8016a6:	e9 2d ff ff ff       	jmp    8015d8 <vprintfmt+0x348>
			putch(ch, putdat);
  8016ab:	83 ec 08             	sub    $0x8,%esp
  8016ae:	53                   	push   %ebx
  8016af:	6a 25                	push   $0x25
  8016b1:	ff d6                	call   *%esi
			break;
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	e9 37 ff ff ff       	jmp    8015f2 <vprintfmt+0x362>
			putch('%', putdat);
  8016bb:	83 ec 08             	sub    $0x8,%esp
  8016be:	53                   	push   %ebx
  8016bf:	6a 25                	push   $0x25
  8016c1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8016c3:	83 c4 10             	add    $0x10,%esp
  8016c6:	89 f8                	mov    %edi,%eax
  8016c8:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8016cc:	74 05                	je     8016d3 <vprintfmt+0x443>
  8016ce:	83 e8 01             	sub    $0x1,%eax
  8016d1:	eb f5                	jmp    8016c8 <vprintfmt+0x438>
  8016d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016d6:	e9 17 ff ff ff       	jmp    8015f2 <vprintfmt+0x362>
}
  8016db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016de:	5b                   	pop    %ebx
  8016df:	5e                   	pop    %esi
  8016e0:	5f                   	pop    %edi
  8016e1:	5d                   	pop    %ebp
  8016e2:	c3                   	ret    

008016e3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8016e3:	f3 0f 1e fb          	endbr32 
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	83 ec 18             	sub    $0x18,%esp
  8016ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8016f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016f6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8016fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801704:	85 c0                	test   %eax,%eax
  801706:	74 26                	je     80172e <vsnprintf+0x4b>
  801708:	85 d2                	test   %edx,%edx
  80170a:	7e 22                	jle    80172e <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80170c:	ff 75 14             	pushl  0x14(%ebp)
  80170f:	ff 75 10             	pushl  0x10(%ebp)
  801712:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801715:	50                   	push   %eax
  801716:	68 4e 12 80 00       	push   $0x80124e
  80171b:	e8 70 fb ff ff       	call   801290 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801720:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801723:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801726:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801729:	83 c4 10             	add    $0x10,%esp
}
  80172c:	c9                   	leave  
  80172d:	c3                   	ret    
		return -E_INVAL;
  80172e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801733:	eb f7                	jmp    80172c <vsnprintf+0x49>

00801735 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801735:	f3 0f 1e fb          	endbr32 
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80173f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801742:	50                   	push   %eax
  801743:	ff 75 10             	pushl  0x10(%ebp)
  801746:	ff 75 0c             	pushl  0xc(%ebp)
  801749:	ff 75 08             	pushl  0x8(%ebp)
  80174c:	e8 92 ff ff ff       	call   8016e3 <vsnprintf>
	va_end(ap);

	return rc;
}
  801751:	c9                   	leave  
  801752:	c3                   	ret    

00801753 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801753:	f3 0f 1e fb          	endbr32 
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80175d:	b8 00 00 00 00       	mov    $0x0,%eax
  801762:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801766:	74 05                	je     80176d <strlen+0x1a>
		n++;
  801768:	83 c0 01             	add    $0x1,%eax
  80176b:	eb f5                	jmp    801762 <strlen+0xf>
	return n;
}
  80176d:	5d                   	pop    %ebp
  80176e:	c3                   	ret    

0080176f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80176f:	f3 0f 1e fb          	endbr32 
  801773:	55                   	push   %ebp
  801774:	89 e5                	mov    %esp,%ebp
  801776:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801779:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80177c:	b8 00 00 00 00       	mov    $0x0,%eax
  801781:	39 d0                	cmp    %edx,%eax
  801783:	74 0d                	je     801792 <strnlen+0x23>
  801785:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801789:	74 05                	je     801790 <strnlen+0x21>
		n++;
  80178b:	83 c0 01             	add    $0x1,%eax
  80178e:	eb f1                	jmp    801781 <strnlen+0x12>
  801790:	89 c2                	mov    %eax,%edx
	return n;
}
  801792:	89 d0                	mov    %edx,%eax
  801794:	5d                   	pop    %ebp
  801795:	c3                   	ret    

00801796 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801796:	f3 0f 1e fb          	endbr32 
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	53                   	push   %ebx
  80179e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8017a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8017a9:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8017ad:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8017b0:	83 c0 01             	add    $0x1,%eax
  8017b3:	84 d2                	test   %dl,%dl
  8017b5:	75 f2                	jne    8017a9 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8017b7:	89 c8                	mov    %ecx,%eax
  8017b9:	5b                   	pop    %ebx
  8017ba:	5d                   	pop    %ebp
  8017bb:	c3                   	ret    

008017bc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017bc:	f3 0f 1e fb          	endbr32 
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	53                   	push   %ebx
  8017c4:	83 ec 10             	sub    $0x10,%esp
  8017c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8017ca:	53                   	push   %ebx
  8017cb:	e8 83 ff ff ff       	call   801753 <strlen>
  8017d0:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8017d3:	ff 75 0c             	pushl  0xc(%ebp)
  8017d6:	01 d8                	add    %ebx,%eax
  8017d8:	50                   	push   %eax
  8017d9:	e8 b8 ff ff ff       	call   801796 <strcpy>
	return dst;
}
  8017de:	89 d8                	mov    %ebx,%eax
  8017e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e3:	c9                   	leave  
  8017e4:	c3                   	ret    

008017e5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8017e5:	f3 0f 1e fb          	endbr32 
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	56                   	push   %esi
  8017ed:	53                   	push   %ebx
  8017ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8017f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f4:	89 f3                	mov    %esi,%ebx
  8017f6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017f9:	89 f0                	mov    %esi,%eax
  8017fb:	39 d8                	cmp    %ebx,%eax
  8017fd:	74 11                	je     801810 <strncpy+0x2b>
		*dst++ = *src;
  8017ff:	83 c0 01             	add    $0x1,%eax
  801802:	0f b6 0a             	movzbl (%edx),%ecx
  801805:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801808:	80 f9 01             	cmp    $0x1,%cl
  80180b:	83 da ff             	sbb    $0xffffffff,%edx
  80180e:	eb eb                	jmp    8017fb <strncpy+0x16>
	}
	return ret;
}
  801810:	89 f0                	mov    %esi,%eax
  801812:	5b                   	pop    %ebx
  801813:	5e                   	pop    %esi
  801814:	5d                   	pop    %ebp
  801815:	c3                   	ret    

00801816 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801816:	f3 0f 1e fb          	endbr32 
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	56                   	push   %esi
  80181e:	53                   	push   %ebx
  80181f:	8b 75 08             	mov    0x8(%ebp),%esi
  801822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801825:	8b 55 10             	mov    0x10(%ebp),%edx
  801828:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80182a:	85 d2                	test   %edx,%edx
  80182c:	74 21                	je     80184f <strlcpy+0x39>
  80182e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801832:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801834:	39 c2                	cmp    %eax,%edx
  801836:	74 14                	je     80184c <strlcpy+0x36>
  801838:	0f b6 19             	movzbl (%ecx),%ebx
  80183b:	84 db                	test   %bl,%bl
  80183d:	74 0b                	je     80184a <strlcpy+0x34>
			*dst++ = *src++;
  80183f:	83 c1 01             	add    $0x1,%ecx
  801842:	83 c2 01             	add    $0x1,%edx
  801845:	88 5a ff             	mov    %bl,-0x1(%edx)
  801848:	eb ea                	jmp    801834 <strlcpy+0x1e>
  80184a:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80184c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80184f:	29 f0                	sub    %esi,%eax
}
  801851:	5b                   	pop    %ebx
  801852:	5e                   	pop    %esi
  801853:	5d                   	pop    %ebp
  801854:	c3                   	ret    

00801855 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801855:	f3 0f 1e fb          	endbr32 
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80185f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801862:	0f b6 01             	movzbl (%ecx),%eax
  801865:	84 c0                	test   %al,%al
  801867:	74 0c                	je     801875 <strcmp+0x20>
  801869:	3a 02                	cmp    (%edx),%al
  80186b:	75 08                	jne    801875 <strcmp+0x20>
		p++, q++;
  80186d:	83 c1 01             	add    $0x1,%ecx
  801870:	83 c2 01             	add    $0x1,%edx
  801873:	eb ed                	jmp    801862 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801875:	0f b6 c0             	movzbl %al,%eax
  801878:	0f b6 12             	movzbl (%edx),%edx
  80187b:	29 d0                	sub    %edx,%eax
}
  80187d:	5d                   	pop    %ebp
  80187e:	c3                   	ret    

0080187f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80187f:	f3 0f 1e fb          	endbr32 
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	53                   	push   %ebx
  801887:	8b 45 08             	mov    0x8(%ebp),%eax
  80188a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80188d:	89 c3                	mov    %eax,%ebx
  80188f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801892:	eb 06                	jmp    80189a <strncmp+0x1b>
		n--, p++, q++;
  801894:	83 c0 01             	add    $0x1,%eax
  801897:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80189a:	39 d8                	cmp    %ebx,%eax
  80189c:	74 16                	je     8018b4 <strncmp+0x35>
  80189e:	0f b6 08             	movzbl (%eax),%ecx
  8018a1:	84 c9                	test   %cl,%cl
  8018a3:	74 04                	je     8018a9 <strncmp+0x2a>
  8018a5:	3a 0a                	cmp    (%edx),%cl
  8018a7:	74 eb                	je     801894 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8018a9:	0f b6 00             	movzbl (%eax),%eax
  8018ac:	0f b6 12             	movzbl (%edx),%edx
  8018af:	29 d0                	sub    %edx,%eax
}
  8018b1:	5b                   	pop    %ebx
  8018b2:	5d                   	pop    %ebp
  8018b3:	c3                   	ret    
		return 0;
  8018b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b9:	eb f6                	jmp    8018b1 <strncmp+0x32>

008018bb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8018bb:	f3 0f 1e fb          	endbr32 
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018c9:	0f b6 10             	movzbl (%eax),%edx
  8018cc:	84 d2                	test   %dl,%dl
  8018ce:	74 09                	je     8018d9 <strchr+0x1e>
		if (*s == c)
  8018d0:	38 ca                	cmp    %cl,%dl
  8018d2:	74 0a                	je     8018de <strchr+0x23>
	for (; *s; s++)
  8018d4:	83 c0 01             	add    $0x1,%eax
  8018d7:	eb f0                	jmp    8018c9 <strchr+0xe>
			return (char *) s;
	return 0;
  8018d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018de:	5d                   	pop    %ebp
  8018df:	c3                   	ret    

008018e0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8018e0:	f3 0f 1e fb          	endbr32 
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ea:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018ee:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8018f1:	38 ca                	cmp    %cl,%dl
  8018f3:	74 09                	je     8018fe <strfind+0x1e>
  8018f5:	84 d2                	test   %dl,%dl
  8018f7:	74 05                	je     8018fe <strfind+0x1e>
	for (; *s; s++)
  8018f9:	83 c0 01             	add    $0x1,%eax
  8018fc:	eb f0                	jmp    8018ee <strfind+0xe>
			break;
	return (char *) s;
}
  8018fe:	5d                   	pop    %ebp
  8018ff:	c3                   	ret    

00801900 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801900:	f3 0f 1e fb          	endbr32 
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	57                   	push   %edi
  801908:	56                   	push   %esi
  801909:	53                   	push   %ebx
  80190a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80190d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801910:	85 c9                	test   %ecx,%ecx
  801912:	74 31                	je     801945 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801914:	89 f8                	mov    %edi,%eax
  801916:	09 c8                	or     %ecx,%eax
  801918:	a8 03                	test   $0x3,%al
  80191a:	75 23                	jne    80193f <memset+0x3f>
		c &= 0xFF;
  80191c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801920:	89 d3                	mov    %edx,%ebx
  801922:	c1 e3 08             	shl    $0x8,%ebx
  801925:	89 d0                	mov    %edx,%eax
  801927:	c1 e0 18             	shl    $0x18,%eax
  80192a:	89 d6                	mov    %edx,%esi
  80192c:	c1 e6 10             	shl    $0x10,%esi
  80192f:	09 f0                	or     %esi,%eax
  801931:	09 c2                	or     %eax,%edx
  801933:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801935:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801938:	89 d0                	mov    %edx,%eax
  80193a:	fc                   	cld    
  80193b:	f3 ab                	rep stos %eax,%es:(%edi)
  80193d:	eb 06                	jmp    801945 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80193f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801942:	fc                   	cld    
  801943:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801945:	89 f8                	mov    %edi,%eax
  801947:	5b                   	pop    %ebx
  801948:	5e                   	pop    %esi
  801949:	5f                   	pop    %edi
  80194a:	5d                   	pop    %ebp
  80194b:	c3                   	ret    

0080194c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80194c:	f3 0f 1e fb          	endbr32 
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	57                   	push   %edi
  801954:	56                   	push   %esi
  801955:	8b 45 08             	mov    0x8(%ebp),%eax
  801958:	8b 75 0c             	mov    0xc(%ebp),%esi
  80195b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80195e:	39 c6                	cmp    %eax,%esi
  801960:	73 32                	jae    801994 <memmove+0x48>
  801962:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801965:	39 c2                	cmp    %eax,%edx
  801967:	76 2b                	jbe    801994 <memmove+0x48>
		s += n;
		d += n;
  801969:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80196c:	89 fe                	mov    %edi,%esi
  80196e:	09 ce                	or     %ecx,%esi
  801970:	09 d6                	or     %edx,%esi
  801972:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801978:	75 0e                	jne    801988 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80197a:	83 ef 04             	sub    $0x4,%edi
  80197d:	8d 72 fc             	lea    -0x4(%edx),%esi
  801980:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801983:	fd                   	std    
  801984:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801986:	eb 09                	jmp    801991 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801988:	83 ef 01             	sub    $0x1,%edi
  80198b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80198e:	fd                   	std    
  80198f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801991:	fc                   	cld    
  801992:	eb 1a                	jmp    8019ae <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801994:	89 c2                	mov    %eax,%edx
  801996:	09 ca                	or     %ecx,%edx
  801998:	09 f2                	or     %esi,%edx
  80199a:	f6 c2 03             	test   $0x3,%dl
  80199d:	75 0a                	jne    8019a9 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80199f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8019a2:	89 c7                	mov    %eax,%edi
  8019a4:	fc                   	cld    
  8019a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019a7:	eb 05                	jmp    8019ae <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8019a9:	89 c7                	mov    %eax,%edi
  8019ab:	fc                   	cld    
  8019ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8019ae:	5e                   	pop    %esi
  8019af:	5f                   	pop    %edi
  8019b0:	5d                   	pop    %ebp
  8019b1:	c3                   	ret    

008019b2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8019b2:	f3 0f 1e fb          	endbr32 
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8019bc:	ff 75 10             	pushl  0x10(%ebp)
  8019bf:	ff 75 0c             	pushl  0xc(%ebp)
  8019c2:	ff 75 08             	pushl  0x8(%ebp)
  8019c5:	e8 82 ff ff ff       	call   80194c <memmove>
}
  8019ca:	c9                   	leave  
  8019cb:	c3                   	ret    

008019cc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8019cc:	f3 0f 1e fb          	endbr32 
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	56                   	push   %esi
  8019d4:	53                   	push   %ebx
  8019d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019db:	89 c6                	mov    %eax,%esi
  8019dd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019e0:	39 f0                	cmp    %esi,%eax
  8019e2:	74 1c                	je     801a00 <memcmp+0x34>
		if (*s1 != *s2)
  8019e4:	0f b6 08             	movzbl (%eax),%ecx
  8019e7:	0f b6 1a             	movzbl (%edx),%ebx
  8019ea:	38 d9                	cmp    %bl,%cl
  8019ec:	75 08                	jne    8019f6 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8019ee:	83 c0 01             	add    $0x1,%eax
  8019f1:	83 c2 01             	add    $0x1,%edx
  8019f4:	eb ea                	jmp    8019e0 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8019f6:	0f b6 c1             	movzbl %cl,%eax
  8019f9:	0f b6 db             	movzbl %bl,%ebx
  8019fc:	29 d8                	sub    %ebx,%eax
  8019fe:	eb 05                	jmp    801a05 <memcmp+0x39>
	}

	return 0;
  801a00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a05:	5b                   	pop    %ebx
  801a06:	5e                   	pop    %esi
  801a07:	5d                   	pop    %ebp
  801a08:	c3                   	ret    

00801a09 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a09:	f3 0f 1e fb          	endbr32 
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	8b 45 08             	mov    0x8(%ebp),%eax
  801a13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a16:	89 c2                	mov    %eax,%edx
  801a18:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a1b:	39 d0                	cmp    %edx,%eax
  801a1d:	73 09                	jae    801a28 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a1f:	38 08                	cmp    %cl,(%eax)
  801a21:	74 05                	je     801a28 <memfind+0x1f>
	for (; s < ends; s++)
  801a23:	83 c0 01             	add    $0x1,%eax
  801a26:	eb f3                	jmp    801a1b <memfind+0x12>
			break;
	return (void *) s;
}
  801a28:	5d                   	pop    %ebp
  801a29:	c3                   	ret    

00801a2a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a2a:	f3 0f 1e fb          	endbr32 
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	57                   	push   %edi
  801a32:	56                   	push   %esi
  801a33:	53                   	push   %ebx
  801a34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a3a:	eb 03                	jmp    801a3f <strtol+0x15>
		s++;
  801a3c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801a3f:	0f b6 01             	movzbl (%ecx),%eax
  801a42:	3c 20                	cmp    $0x20,%al
  801a44:	74 f6                	je     801a3c <strtol+0x12>
  801a46:	3c 09                	cmp    $0x9,%al
  801a48:	74 f2                	je     801a3c <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801a4a:	3c 2b                	cmp    $0x2b,%al
  801a4c:	74 2a                	je     801a78 <strtol+0x4e>
	int neg = 0;
  801a4e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801a53:	3c 2d                	cmp    $0x2d,%al
  801a55:	74 2b                	je     801a82 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a57:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a5d:	75 0f                	jne    801a6e <strtol+0x44>
  801a5f:	80 39 30             	cmpb   $0x30,(%ecx)
  801a62:	74 28                	je     801a8c <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a64:	85 db                	test   %ebx,%ebx
  801a66:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a6b:	0f 44 d8             	cmove  %eax,%ebx
  801a6e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a73:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801a76:	eb 46                	jmp    801abe <strtol+0x94>
		s++;
  801a78:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801a7b:	bf 00 00 00 00       	mov    $0x0,%edi
  801a80:	eb d5                	jmp    801a57 <strtol+0x2d>
		s++, neg = 1;
  801a82:	83 c1 01             	add    $0x1,%ecx
  801a85:	bf 01 00 00 00       	mov    $0x1,%edi
  801a8a:	eb cb                	jmp    801a57 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a8c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a90:	74 0e                	je     801aa0 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801a92:	85 db                	test   %ebx,%ebx
  801a94:	75 d8                	jne    801a6e <strtol+0x44>
		s++, base = 8;
  801a96:	83 c1 01             	add    $0x1,%ecx
  801a99:	bb 08 00 00 00       	mov    $0x8,%ebx
  801a9e:	eb ce                	jmp    801a6e <strtol+0x44>
		s += 2, base = 16;
  801aa0:	83 c1 02             	add    $0x2,%ecx
  801aa3:	bb 10 00 00 00       	mov    $0x10,%ebx
  801aa8:	eb c4                	jmp    801a6e <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801aaa:	0f be d2             	movsbl %dl,%edx
  801aad:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801ab0:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ab3:	7d 3a                	jge    801aef <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801ab5:	83 c1 01             	add    $0x1,%ecx
  801ab8:	0f af 45 10          	imul   0x10(%ebp),%eax
  801abc:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801abe:	0f b6 11             	movzbl (%ecx),%edx
  801ac1:	8d 72 d0             	lea    -0x30(%edx),%esi
  801ac4:	89 f3                	mov    %esi,%ebx
  801ac6:	80 fb 09             	cmp    $0x9,%bl
  801ac9:	76 df                	jbe    801aaa <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801acb:	8d 72 9f             	lea    -0x61(%edx),%esi
  801ace:	89 f3                	mov    %esi,%ebx
  801ad0:	80 fb 19             	cmp    $0x19,%bl
  801ad3:	77 08                	ja     801add <strtol+0xb3>
			dig = *s - 'a' + 10;
  801ad5:	0f be d2             	movsbl %dl,%edx
  801ad8:	83 ea 57             	sub    $0x57,%edx
  801adb:	eb d3                	jmp    801ab0 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801add:	8d 72 bf             	lea    -0x41(%edx),%esi
  801ae0:	89 f3                	mov    %esi,%ebx
  801ae2:	80 fb 19             	cmp    $0x19,%bl
  801ae5:	77 08                	ja     801aef <strtol+0xc5>
			dig = *s - 'A' + 10;
  801ae7:	0f be d2             	movsbl %dl,%edx
  801aea:	83 ea 37             	sub    $0x37,%edx
  801aed:	eb c1                	jmp    801ab0 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801aef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801af3:	74 05                	je     801afa <strtol+0xd0>
		*endptr = (char *) s;
  801af5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801af8:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801afa:	89 c2                	mov    %eax,%edx
  801afc:	f7 da                	neg    %edx
  801afe:	85 ff                	test   %edi,%edi
  801b00:	0f 45 c2             	cmovne %edx,%eax
}
  801b03:	5b                   	pop    %ebx
  801b04:	5e                   	pop    %esi
  801b05:	5f                   	pop    %edi
  801b06:	5d                   	pop    %ebp
  801b07:	c3                   	ret    

00801b08 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b08:	f3 0f 1e fb          	endbr32 
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	56                   	push   %esi
  801b10:	53                   	push   %ebx
  801b11:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b17:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b21:	0f 44 c2             	cmove  %edx,%eax
  801b24:	83 ec 0c             	sub    $0xc,%esp
  801b27:	50                   	push   %eax
  801b28:	e8 1b e8 ff ff       	call   800348 <sys_ipc_recv>
  801b2d:	83 c4 10             	add    $0x10,%esp
  801b30:	85 c0                	test   %eax,%eax
  801b32:	78 24                	js     801b58 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801b34:	85 f6                	test   %esi,%esi
  801b36:	74 0a                	je     801b42 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801b38:	a1 04 40 80 00       	mov    0x804004,%eax
  801b3d:	8b 40 78             	mov    0x78(%eax),%eax
  801b40:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801b42:	85 db                	test   %ebx,%ebx
  801b44:	74 0a                	je     801b50 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801b46:	a1 04 40 80 00       	mov    0x804004,%eax
  801b4b:	8b 40 74             	mov    0x74(%eax),%eax
  801b4e:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801b50:	a1 04 40 80 00       	mov    0x804004,%eax
  801b55:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b58:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b5b:	5b                   	pop    %ebx
  801b5c:	5e                   	pop    %esi
  801b5d:	5d                   	pop    %ebp
  801b5e:	c3                   	ret    

00801b5f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b5f:	f3 0f 1e fb          	endbr32 
  801b63:	55                   	push   %ebp
  801b64:	89 e5                	mov    %esp,%ebp
  801b66:	57                   	push   %edi
  801b67:	56                   	push   %esi
  801b68:	53                   	push   %ebx
  801b69:	83 ec 1c             	sub    $0x1c,%esp
  801b6c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b76:	0f 45 d0             	cmovne %eax,%edx
  801b79:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801b7b:	be 01 00 00 00       	mov    $0x1,%esi
  801b80:	eb 1f                	jmp    801ba1 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801b82:	e8 d2 e5 ff ff       	call   800159 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801b87:	83 c3 01             	add    $0x1,%ebx
  801b8a:	39 de                	cmp    %ebx,%esi
  801b8c:	7f f4                	jg     801b82 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801b8e:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801b90:	83 fe 11             	cmp    $0x11,%esi
  801b93:	b8 01 00 00 00       	mov    $0x1,%eax
  801b98:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801b9b:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801b9f:	75 1c                	jne    801bbd <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801ba1:	ff 75 14             	pushl  0x14(%ebp)
  801ba4:	57                   	push   %edi
  801ba5:	ff 75 0c             	pushl  0xc(%ebp)
  801ba8:	ff 75 08             	pushl  0x8(%ebp)
  801bab:	e8 71 e7 ff ff       	call   800321 <sys_ipc_try_send>
  801bb0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801bb3:	83 c4 10             	add    $0x10,%esp
  801bb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bbb:	eb cd                	jmp    801b8a <ipc_send+0x2b>
}
  801bbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc0:	5b                   	pop    %ebx
  801bc1:	5e                   	pop    %esi
  801bc2:	5f                   	pop    %edi
  801bc3:	5d                   	pop    %ebp
  801bc4:	c3                   	ret    

00801bc5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bc5:	f3 0f 1e fb          	endbr32 
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bcf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bd4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bd7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bdd:	8b 52 50             	mov    0x50(%edx),%edx
  801be0:	39 ca                	cmp    %ecx,%edx
  801be2:	74 11                	je     801bf5 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801be4:	83 c0 01             	add    $0x1,%eax
  801be7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bec:	75 e6                	jne    801bd4 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801bee:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf3:	eb 0b                	jmp    801c00 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801bf5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bf8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bfd:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c00:	5d                   	pop    %ebp
  801c01:	c3                   	ret    

00801c02 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c02:	f3 0f 1e fb          	endbr32 
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c0c:	89 c2                	mov    %eax,%edx
  801c0e:	c1 ea 16             	shr    $0x16,%edx
  801c11:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c18:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c1d:	f6 c1 01             	test   $0x1,%cl
  801c20:	74 1c                	je     801c3e <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c22:	c1 e8 0c             	shr    $0xc,%eax
  801c25:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c2c:	a8 01                	test   $0x1,%al
  801c2e:	74 0e                	je     801c3e <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c30:	c1 e8 0c             	shr    $0xc,%eax
  801c33:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c3a:	ef 
  801c3b:	0f b7 d2             	movzwl %dx,%edx
}
  801c3e:	89 d0                	mov    %edx,%eax
  801c40:	5d                   	pop    %ebp
  801c41:	c3                   	ret    
  801c42:	66 90                	xchg   %ax,%ax
  801c44:	66 90                	xchg   %ax,%ax
  801c46:	66 90                	xchg   %ax,%ax
  801c48:	66 90                	xchg   %ax,%ax
  801c4a:	66 90                	xchg   %ax,%ax
  801c4c:	66 90                	xchg   %ax,%ax
  801c4e:	66 90                	xchg   %ax,%ax

00801c50 <__udivdi3>:
  801c50:	f3 0f 1e fb          	endbr32 
  801c54:	55                   	push   %ebp
  801c55:	57                   	push   %edi
  801c56:	56                   	push   %esi
  801c57:	53                   	push   %ebx
  801c58:	83 ec 1c             	sub    $0x1c,%esp
  801c5b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c5f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c63:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c67:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c6b:	85 d2                	test   %edx,%edx
  801c6d:	75 19                	jne    801c88 <__udivdi3+0x38>
  801c6f:	39 f3                	cmp    %esi,%ebx
  801c71:	76 4d                	jbe    801cc0 <__udivdi3+0x70>
  801c73:	31 ff                	xor    %edi,%edi
  801c75:	89 e8                	mov    %ebp,%eax
  801c77:	89 f2                	mov    %esi,%edx
  801c79:	f7 f3                	div    %ebx
  801c7b:	89 fa                	mov    %edi,%edx
  801c7d:	83 c4 1c             	add    $0x1c,%esp
  801c80:	5b                   	pop    %ebx
  801c81:	5e                   	pop    %esi
  801c82:	5f                   	pop    %edi
  801c83:	5d                   	pop    %ebp
  801c84:	c3                   	ret    
  801c85:	8d 76 00             	lea    0x0(%esi),%esi
  801c88:	39 f2                	cmp    %esi,%edx
  801c8a:	76 14                	jbe    801ca0 <__udivdi3+0x50>
  801c8c:	31 ff                	xor    %edi,%edi
  801c8e:	31 c0                	xor    %eax,%eax
  801c90:	89 fa                	mov    %edi,%edx
  801c92:	83 c4 1c             	add    $0x1c,%esp
  801c95:	5b                   	pop    %ebx
  801c96:	5e                   	pop    %esi
  801c97:	5f                   	pop    %edi
  801c98:	5d                   	pop    %ebp
  801c99:	c3                   	ret    
  801c9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ca0:	0f bd fa             	bsr    %edx,%edi
  801ca3:	83 f7 1f             	xor    $0x1f,%edi
  801ca6:	75 48                	jne    801cf0 <__udivdi3+0xa0>
  801ca8:	39 f2                	cmp    %esi,%edx
  801caa:	72 06                	jb     801cb2 <__udivdi3+0x62>
  801cac:	31 c0                	xor    %eax,%eax
  801cae:	39 eb                	cmp    %ebp,%ebx
  801cb0:	77 de                	ja     801c90 <__udivdi3+0x40>
  801cb2:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb7:	eb d7                	jmp    801c90 <__udivdi3+0x40>
  801cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	89 d9                	mov    %ebx,%ecx
  801cc2:	85 db                	test   %ebx,%ebx
  801cc4:	75 0b                	jne    801cd1 <__udivdi3+0x81>
  801cc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ccb:	31 d2                	xor    %edx,%edx
  801ccd:	f7 f3                	div    %ebx
  801ccf:	89 c1                	mov    %eax,%ecx
  801cd1:	31 d2                	xor    %edx,%edx
  801cd3:	89 f0                	mov    %esi,%eax
  801cd5:	f7 f1                	div    %ecx
  801cd7:	89 c6                	mov    %eax,%esi
  801cd9:	89 e8                	mov    %ebp,%eax
  801cdb:	89 f7                	mov    %esi,%edi
  801cdd:	f7 f1                	div    %ecx
  801cdf:	89 fa                	mov    %edi,%edx
  801ce1:	83 c4 1c             	add    $0x1c,%esp
  801ce4:	5b                   	pop    %ebx
  801ce5:	5e                   	pop    %esi
  801ce6:	5f                   	pop    %edi
  801ce7:	5d                   	pop    %ebp
  801ce8:	c3                   	ret    
  801ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	89 f9                	mov    %edi,%ecx
  801cf2:	b8 20 00 00 00       	mov    $0x20,%eax
  801cf7:	29 f8                	sub    %edi,%eax
  801cf9:	d3 e2                	shl    %cl,%edx
  801cfb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cff:	89 c1                	mov    %eax,%ecx
  801d01:	89 da                	mov    %ebx,%edx
  801d03:	d3 ea                	shr    %cl,%edx
  801d05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d09:	09 d1                	or     %edx,%ecx
  801d0b:	89 f2                	mov    %esi,%edx
  801d0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d11:	89 f9                	mov    %edi,%ecx
  801d13:	d3 e3                	shl    %cl,%ebx
  801d15:	89 c1                	mov    %eax,%ecx
  801d17:	d3 ea                	shr    %cl,%edx
  801d19:	89 f9                	mov    %edi,%ecx
  801d1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d1f:	89 eb                	mov    %ebp,%ebx
  801d21:	d3 e6                	shl    %cl,%esi
  801d23:	89 c1                	mov    %eax,%ecx
  801d25:	d3 eb                	shr    %cl,%ebx
  801d27:	09 de                	or     %ebx,%esi
  801d29:	89 f0                	mov    %esi,%eax
  801d2b:	f7 74 24 08          	divl   0x8(%esp)
  801d2f:	89 d6                	mov    %edx,%esi
  801d31:	89 c3                	mov    %eax,%ebx
  801d33:	f7 64 24 0c          	mull   0xc(%esp)
  801d37:	39 d6                	cmp    %edx,%esi
  801d39:	72 15                	jb     801d50 <__udivdi3+0x100>
  801d3b:	89 f9                	mov    %edi,%ecx
  801d3d:	d3 e5                	shl    %cl,%ebp
  801d3f:	39 c5                	cmp    %eax,%ebp
  801d41:	73 04                	jae    801d47 <__udivdi3+0xf7>
  801d43:	39 d6                	cmp    %edx,%esi
  801d45:	74 09                	je     801d50 <__udivdi3+0x100>
  801d47:	89 d8                	mov    %ebx,%eax
  801d49:	31 ff                	xor    %edi,%edi
  801d4b:	e9 40 ff ff ff       	jmp    801c90 <__udivdi3+0x40>
  801d50:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d53:	31 ff                	xor    %edi,%edi
  801d55:	e9 36 ff ff ff       	jmp    801c90 <__udivdi3+0x40>
  801d5a:	66 90                	xchg   %ax,%ax
  801d5c:	66 90                	xchg   %ax,%ax
  801d5e:	66 90                	xchg   %ax,%ax

00801d60 <__umoddi3>:
  801d60:	f3 0f 1e fb          	endbr32 
  801d64:	55                   	push   %ebp
  801d65:	57                   	push   %edi
  801d66:	56                   	push   %esi
  801d67:	53                   	push   %ebx
  801d68:	83 ec 1c             	sub    $0x1c,%esp
  801d6b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d6f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801d73:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d77:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d7b:	85 c0                	test   %eax,%eax
  801d7d:	75 19                	jne    801d98 <__umoddi3+0x38>
  801d7f:	39 df                	cmp    %ebx,%edi
  801d81:	76 5d                	jbe    801de0 <__umoddi3+0x80>
  801d83:	89 f0                	mov    %esi,%eax
  801d85:	89 da                	mov    %ebx,%edx
  801d87:	f7 f7                	div    %edi
  801d89:	89 d0                	mov    %edx,%eax
  801d8b:	31 d2                	xor    %edx,%edx
  801d8d:	83 c4 1c             	add    $0x1c,%esp
  801d90:	5b                   	pop    %ebx
  801d91:	5e                   	pop    %esi
  801d92:	5f                   	pop    %edi
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    
  801d95:	8d 76 00             	lea    0x0(%esi),%esi
  801d98:	89 f2                	mov    %esi,%edx
  801d9a:	39 d8                	cmp    %ebx,%eax
  801d9c:	76 12                	jbe    801db0 <__umoddi3+0x50>
  801d9e:	89 f0                	mov    %esi,%eax
  801da0:	89 da                	mov    %ebx,%edx
  801da2:	83 c4 1c             	add    $0x1c,%esp
  801da5:	5b                   	pop    %ebx
  801da6:	5e                   	pop    %esi
  801da7:	5f                   	pop    %edi
  801da8:	5d                   	pop    %ebp
  801da9:	c3                   	ret    
  801daa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801db0:	0f bd e8             	bsr    %eax,%ebp
  801db3:	83 f5 1f             	xor    $0x1f,%ebp
  801db6:	75 50                	jne    801e08 <__umoddi3+0xa8>
  801db8:	39 d8                	cmp    %ebx,%eax
  801dba:	0f 82 e0 00 00 00    	jb     801ea0 <__umoddi3+0x140>
  801dc0:	89 d9                	mov    %ebx,%ecx
  801dc2:	39 f7                	cmp    %esi,%edi
  801dc4:	0f 86 d6 00 00 00    	jbe    801ea0 <__umoddi3+0x140>
  801dca:	89 d0                	mov    %edx,%eax
  801dcc:	89 ca                	mov    %ecx,%edx
  801dce:	83 c4 1c             	add    $0x1c,%esp
  801dd1:	5b                   	pop    %ebx
  801dd2:	5e                   	pop    %esi
  801dd3:	5f                   	pop    %edi
  801dd4:	5d                   	pop    %ebp
  801dd5:	c3                   	ret    
  801dd6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ddd:	8d 76 00             	lea    0x0(%esi),%esi
  801de0:	89 fd                	mov    %edi,%ebp
  801de2:	85 ff                	test   %edi,%edi
  801de4:	75 0b                	jne    801df1 <__umoddi3+0x91>
  801de6:	b8 01 00 00 00       	mov    $0x1,%eax
  801deb:	31 d2                	xor    %edx,%edx
  801ded:	f7 f7                	div    %edi
  801def:	89 c5                	mov    %eax,%ebp
  801df1:	89 d8                	mov    %ebx,%eax
  801df3:	31 d2                	xor    %edx,%edx
  801df5:	f7 f5                	div    %ebp
  801df7:	89 f0                	mov    %esi,%eax
  801df9:	f7 f5                	div    %ebp
  801dfb:	89 d0                	mov    %edx,%eax
  801dfd:	31 d2                	xor    %edx,%edx
  801dff:	eb 8c                	jmp    801d8d <__umoddi3+0x2d>
  801e01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e08:	89 e9                	mov    %ebp,%ecx
  801e0a:	ba 20 00 00 00       	mov    $0x20,%edx
  801e0f:	29 ea                	sub    %ebp,%edx
  801e11:	d3 e0                	shl    %cl,%eax
  801e13:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e17:	89 d1                	mov    %edx,%ecx
  801e19:	89 f8                	mov    %edi,%eax
  801e1b:	d3 e8                	shr    %cl,%eax
  801e1d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e21:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e25:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e29:	09 c1                	or     %eax,%ecx
  801e2b:	89 d8                	mov    %ebx,%eax
  801e2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e31:	89 e9                	mov    %ebp,%ecx
  801e33:	d3 e7                	shl    %cl,%edi
  801e35:	89 d1                	mov    %edx,%ecx
  801e37:	d3 e8                	shr    %cl,%eax
  801e39:	89 e9                	mov    %ebp,%ecx
  801e3b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e3f:	d3 e3                	shl    %cl,%ebx
  801e41:	89 c7                	mov    %eax,%edi
  801e43:	89 d1                	mov    %edx,%ecx
  801e45:	89 f0                	mov    %esi,%eax
  801e47:	d3 e8                	shr    %cl,%eax
  801e49:	89 e9                	mov    %ebp,%ecx
  801e4b:	89 fa                	mov    %edi,%edx
  801e4d:	d3 e6                	shl    %cl,%esi
  801e4f:	09 d8                	or     %ebx,%eax
  801e51:	f7 74 24 08          	divl   0x8(%esp)
  801e55:	89 d1                	mov    %edx,%ecx
  801e57:	89 f3                	mov    %esi,%ebx
  801e59:	f7 64 24 0c          	mull   0xc(%esp)
  801e5d:	89 c6                	mov    %eax,%esi
  801e5f:	89 d7                	mov    %edx,%edi
  801e61:	39 d1                	cmp    %edx,%ecx
  801e63:	72 06                	jb     801e6b <__umoddi3+0x10b>
  801e65:	75 10                	jne    801e77 <__umoddi3+0x117>
  801e67:	39 c3                	cmp    %eax,%ebx
  801e69:	73 0c                	jae    801e77 <__umoddi3+0x117>
  801e6b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801e6f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801e73:	89 d7                	mov    %edx,%edi
  801e75:	89 c6                	mov    %eax,%esi
  801e77:	89 ca                	mov    %ecx,%edx
  801e79:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801e7e:	29 f3                	sub    %esi,%ebx
  801e80:	19 fa                	sbb    %edi,%edx
  801e82:	89 d0                	mov    %edx,%eax
  801e84:	d3 e0                	shl    %cl,%eax
  801e86:	89 e9                	mov    %ebp,%ecx
  801e88:	d3 eb                	shr    %cl,%ebx
  801e8a:	d3 ea                	shr    %cl,%edx
  801e8c:	09 d8                	or     %ebx,%eax
  801e8e:	83 c4 1c             	add    $0x1c,%esp
  801e91:	5b                   	pop    %ebx
  801e92:	5e                   	pop    %esi
  801e93:	5f                   	pop    %edi
  801e94:	5d                   	pop    %ebp
  801e95:	c3                   	ret    
  801e96:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e9d:	8d 76 00             	lea    0x0(%esi),%esi
  801ea0:	29 fe                	sub    %edi,%esi
  801ea2:	19 c3                	sbb    %eax,%ebx
  801ea4:	89 f2                	mov    %esi,%edx
  801ea6:	89 d9                	mov    %ebx,%ecx
  801ea8:	e9 1d ff ff ff       	jmp    801dca <__umoddi3+0x6a>
