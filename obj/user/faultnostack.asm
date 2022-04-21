
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 27 00 00 00       	call   800058 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003d:	68 ab 03 80 00       	push   $0x8003ab
  800042:	6a 00                	push   $0x0
  800044:	e8 b0 02 00 00       	call   8002f9 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800049:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800050:	00 00 00 
}
  800053:	83 c4 10             	add    $0x10,%esp
  800056:	c9                   	leave  
  800057:	c3                   	ret    

00800058 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800058:	f3 0f 1e fb          	endbr32 
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	56                   	push   %esi
  800060:	53                   	push   %ebx
  800061:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800064:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800067:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  80006e:	00 00 00 
    envid_t envid = sys_getenvid();
  800071:	e8 de 00 00 00       	call   800154 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800076:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800083:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800088:	85 db                	test   %ebx,%ebx
  80008a:	7e 07                	jle    800093 <libmain+0x3b>
		binaryname = argv[0];
  80008c:	8b 06                	mov    (%esi),%eax
  80008e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800093:	83 ec 08             	sub    $0x8,%esp
  800096:	56                   	push   %esi
  800097:	53                   	push   %ebx
  800098:	e8 96 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009d:	e8 0a 00 00 00       	call   8000ac <exit>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a8:	5b                   	pop    %ebx
  8000a9:	5e                   	pop    %esi
  8000aa:	5d                   	pop    %ebp
  8000ab:	c3                   	ret    

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	f3 0f 1e fb          	endbr32 
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b6:	e8 05 05 00 00       	call   8005c0 <close_all>
	sys_env_destroy(0);
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	6a 00                	push   $0x0
  8000c0:	e8 4a 00 00 00       	call   80010f <sys_env_destroy>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ca:	f3 0f 1e fb          	endbr32 
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	57                   	push   %edi
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000df:	89 c3                	mov    %eax,%ebx
  8000e1:	89 c7                	mov    %eax,%edi
  8000e3:	89 c6                	mov    %eax,%esi
  8000e5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5f                   	pop    %edi
  8000ea:	5d                   	pop    %ebp
  8000eb:	c3                   	ret    

008000ec <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ec:	f3 0f 1e fb          	endbr32 
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	57                   	push   %edi
  8000f4:	56                   	push   %esi
  8000f5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fb:	b8 01 00 00 00       	mov    $0x1,%eax
  800100:	89 d1                	mov    %edx,%ecx
  800102:	89 d3                	mov    %edx,%ebx
  800104:	89 d7                	mov    %edx,%edi
  800106:	89 d6                	mov    %edx,%esi
  800108:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80010a:	5b                   	pop    %ebx
  80010b:	5e                   	pop    %esi
  80010c:	5f                   	pop    %edi
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    

0080010f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80010f:	f3 0f 1e fb          	endbr32 
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	57                   	push   %edi
  800117:	56                   	push   %esi
  800118:	53                   	push   %ebx
  800119:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80011c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800121:	8b 55 08             	mov    0x8(%ebp),%edx
  800124:	b8 03 00 00 00       	mov    $0x3,%eax
  800129:	89 cb                	mov    %ecx,%ebx
  80012b:	89 cf                	mov    %ecx,%edi
  80012d:	89 ce                	mov    %ecx,%esi
  80012f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800131:	85 c0                	test   %eax,%eax
  800133:	7f 08                	jg     80013d <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800135:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800138:	5b                   	pop    %ebx
  800139:	5e                   	pop    %esi
  80013a:	5f                   	pop    %edi
  80013b:	5d                   	pop    %ebp
  80013c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	50                   	push   %eax
  800141:	6a 03                	push   $0x3
  800143:	68 8a 1f 80 00       	push   $0x801f8a
  800148:	6a 23                	push   $0x23
  80014a:	68 a7 1f 80 00       	push   $0x801fa7
  80014f:	e8 96 0f 00 00       	call   8010ea <_panic>

00800154 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800154:	f3 0f 1e fb          	endbr32 
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	57                   	push   %edi
  80015c:	56                   	push   %esi
  80015d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015e:	ba 00 00 00 00       	mov    $0x0,%edx
  800163:	b8 02 00 00 00       	mov    $0x2,%eax
  800168:	89 d1                	mov    %edx,%ecx
  80016a:	89 d3                	mov    %edx,%ebx
  80016c:	89 d7                	mov    %edx,%edi
  80016e:	89 d6                	mov    %edx,%esi
  800170:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800172:	5b                   	pop    %ebx
  800173:	5e                   	pop    %esi
  800174:	5f                   	pop    %edi
  800175:	5d                   	pop    %ebp
  800176:	c3                   	ret    

00800177 <sys_yield>:

void
sys_yield(void)
{
  800177:	f3 0f 1e fb          	endbr32 
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	57                   	push   %edi
  80017f:	56                   	push   %esi
  800180:	53                   	push   %ebx
	asm volatile("int %1\n"
  800181:	ba 00 00 00 00       	mov    $0x0,%edx
  800186:	b8 0b 00 00 00       	mov    $0xb,%eax
  80018b:	89 d1                	mov    %edx,%ecx
  80018d:	89 d3                	mov    %edx,%ebx
  80018f:	89 d7                	mov    %edx,%edi
  800191:	89 d6                	mov    %edx,%esi
  800193:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800195:	5b                   	pop    %ebx
  800196:	5e                   	pop    %esi
  800197:	5f                   	pop    %edi
  800198:	5d                   	pop    %ebp
  800199:	c3                   	ret    

0080019a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80019a:	f3 0f 1e fb          	endbr32 
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	57                   	push   %edi
  8001a2:	56                   	push   %esi
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a7:	be 00 00 00 00       	mov    $0x0,%esi
  8001ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ba:	89 f7                	mov    %esi,%edi
  8001bc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001be:	85 c0                	test   %eax,%eax
  8001c0:	7f 08                	jg     8001ca <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c5:	5b                   	pop    %ebx
  8001c6:	5e                   	pop    %esi
  8001c7:	5f                   	pop    %edi
  8001c8:	5d                   	pop    %ebp
  8001c9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ca:	83 ec 0c             	sub    $0xc,%esp
  8001cd:	50                   	push   %eax
  8001ce:	6a 04                	push   $0x4
  8001d0:	68 8a 1f 80 00       	push   $0x801f8a
  8001d5:	6a 23                	push   $0x23
  8001d7:	68 a7 1f 80 00       	push   $0x801fa7
  8001dc:	e8 09 0f 00 00       	call   8010ea <_panic>

008001e1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e1:	f3 0f 1e fb          	endbr32 
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	57                   	push   %edi
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ff:	8b 75 18             	mov    0x18(%ebp),%esi
  800202:	cd 30                	int    $0x30
	if(check && ret > 0)
  800204:	85 c0                	test   %eax,%eax
  800206:	7f 08                	jg     800210 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800208:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020b:	5b                   	pop    %ebx
  80020c:	5e                   	pop    %esi
  80020d:	5f                   	pop    %edi
  80020e:	5d                   	pop    %ebp
  80020f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	50                   	push   %eax
  800214:	6a 05                	push   $0x5
  800216:	68 8a 1f 80 00       	push   $0x801f8a
  80021b:	6a 23                	push   $0x23
  80021d:	68 a7 1f 80 00       	push   $0x801fa7
  800222:	e8 c3 0e 00 00       	call   8010ea <_panic>

00800227 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800227:	f3 0f 1e fb          	endbr32 
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	57                   	push   %edi
  80022f:	56                   	push   %esi
  800230:	53                   	push   %ebx
  800231:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800234:	bb 00 00 00 00       	mov    $0x0,%ebx
  800239:	8b 55 08             	mov    0x8(%ebp),%edx
  80023c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023f:	b8 06 00 00 00       	mov    $0x6,%eax
  800244:	89 df                	mov    %ebx,%edi
  800246:	89 de                	mov    %ebx,%esi
  800248:	cd 30                	int    $0x30
	if(check && ret > 0)
  80024a:	85 c0                	test   %eax,%eax
  80024c:	7f 08                	jg     800256 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80024e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800251:	5b                   	pop    %ebx
  800252:	5e                   	pop    %esi
  800253:	5f                   	pop    %edi
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800256:	83 ec 0c             	sub    $0xc,%esp
  800259:	50                   	push   %eax
  80025a:	6a 06                	push   $0x6
  80025c:	68 8a 1f 80 00       	push   $0x801f8a
  800261:	6a 23                	push   $0x23
  800263:	68 a7 1f 80 00       	push   $0x801fa7
  800268:	e8 7d 0e 00 00       	call   8010ea <_panic>

0080026d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80026d:	f3 0f 1e fb          	endbr32 
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	57                   	push   %edi
  800275:	56                   	push   %esi
  800276:	53                   	push   %ebx
  800277:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027f:	8b 55 08             	mov    0x8(%ebp),%edx
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	b8 08 00 00 00       	mov    $0x8,%eax
  80028a:	89 df                	mov    %ebx,%edi
  80028c:	89 de                	mov    %ebx,%esi
  80028e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800290:	85 c0                	test   %eax,%eax
  800292:	7f 08                	jg     80029c <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800294:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800297:	5b                   	pop    %ebx
  800298:	5e                   	pop    %esi
  800299:	5f                   	pop    %edi
  80029a:	5d                   	pop    %ebp
  80029b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 08                	push   $0x8
  8002a2:	68 8a 1f 80 00       	push   $0x801f8a
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 a7 1f 80 00       	push   $0x801fa7
  8002ae:	e8 37 0e 00 00       	call   8010ea <_panic>

008002b3 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002b3:	f3 0f 1e fb          	endbr32 
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	57                   	push   %edi
  8002bb:	56                   	push   %esi
  8002bc:	53                   	push   %ebx
  8002bd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cb:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d0:	89 df                	mov    %ebx,%edi
  8002d2:	89 de                	mov    %ebx,%esi
  8002d4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d6:	85 c0                	test   %eax,%eax
  8002d8:	7f 08                	jg     8002e2 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e2:	83 ec 0c             	sub    $0xc,%esp
  8002e5:	50                   	push   %eax
  8002e6:	6a 09                	push   $0x9
  8002e8:	68 8a 1f 80 00       	push   $0x801f8a
  8002ed:	6a 23                	push   $0x23
  8002ef:	68 a7 1f 80 00       	push   $0x801fa7
  8002f4:	e8 f1 0d 00 00       	call   8010ea <_panic>

008002f9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002f9:	f3 0f 1e fb          	endbr32 
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
  800303:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800306:	bb 00 00 00 00       	mov    $0x0,%ebx
  80030b:	8b 55 08             	mov    0x8(%ebp),%edx
  80030e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800311:	b8 0a 00 00 00       	mov    $0xa,%eax
  800316:	89 df                	mov    %ebx,%edi
  800318:	89 de                	mov    %ebx,%esi
  80031a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80031c:	85 c0                	test   %eax,%eax
  80031e:	7f 08                	jg     800328 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800320:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800323:	5b                   	pop    %ebx
  800324:	5e                   	pop    %esi
  800325:	5f                   	pop    %edi
  800326:	5d                   	pop    %ebp
  800327:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800328:	83 ec 0c             	sub    $0xc,%esp
  80032b:	50                   	push   %eax
  80032c:	6a 0a                	push   $0xa
  80032e:	68 8a 1f 80 00       	push   $0x801f8a
  800333:	6a 23                	push   $0x23
  800335:	68 a7 1f 80 00       	push   $0x801fa7
  80033a:	e8 ab 0d 00 00       	call   8010ea <_panic>

0080033f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80033f:	f3 0f 1e fb          	endbr32 
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	57                   	push   %edi
  800347:	56                   	push   %esi
  800348:	53                   	push   %ebx
	asm volatile("int %1\n"
  800349:	8b 55 08             	mov    0x8(%ebp),%edx
  80034c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80034f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800354:	be 00 00 00 00       	mov    $0x0,%esi
  800359:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80035c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80035f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800361:	5b                   	pop    %ebx
  800362:	5e                   	pop    %esi
  800363:	5f                   	pop    %edi
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    

00800366 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800366:	f3 0f 1e fb          	endbr32 
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	57                   	push   %edi
  80036e:	56                   	push   %esi
  80036f:	53                   	push   %ebx
  800370:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800373:	b9 00 00 00 00       	mov    $0x0,%ecx
  800378:	8b 55 08             	mov    0x8(%ebp),%edx
  80037b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800380:	89 cb                	mov    %ecx,%ebx
  800382:	89 cf                	mov    %ecx,%edi
  800384:	89 ce                	mov    %ecx,%esi
  800386:	cd 30                	int    $0x30
	if(check && ret > 0)
  800388:	85 c0                	test   %eax,%eax
  80038a:	7f 08                	jg     800394 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80038c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80038f:	5b                   	pop    %ebx
  800390:	5e                   	pop    %esi
  800391:	5f                   	pop    %edi
  800392:	5d                   	pop    %ebp
  800393:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800394:	83 ec 0c             	sub    $0xc,%esp
  800397:	50                   	push   %eax
  800398:	6a 0d                	push   $0xd
  80039a:	68 8a 1f 80 00       	push   $0x801f8a
  80039f:	6a 23                	push   $0x23
  8003a1:	68 a7 1f 80 00       	push   $0x801fa7
  8003a6:	e8 3f 0d 00 00       	call   8010ea <_panic>

008003ab <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8003ab:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8003ac:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8003b1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8003b3:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  8003b6:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  8003ba:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  8003be:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  8003c1:	83 c4 08             	add    $0x8,%esp
    popa
  8003c4:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  8003c5:	83 c4 04             	add    $0x4,%esp
    popf
  8003c8:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  8003c9:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  8003cc:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  8003d0:	c3                   	ret    

008003d1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003d1:	f3 0f 1e fb          	endbr32 
  8003d5:	55                   	push   %ebp
  8003d6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003db:	05 00 00 00 30       	add    $0x30000000,%eax
  8003e0:	c1 e8 0c             	shr    $0xc,%eax
}
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    

008003e5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003e5:	f3 0f 1e fb          	endbr32 
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ef:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003f4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003f9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003fe:	5d                   	pop    %ebp
  8003ff:	c3                   	ret    

00800400 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800400:	f3 0f 1e fb          	endbr32 
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
  800407:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80040c:	89 c2                	mov    %eax,%edx
  80040e:	c1 ea 16             	shr    $0x16,%edx
  800411:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800418:	f6 c2 01             	test   $0x1,%dl
  80041b:	74 2d                	je     80044a <fd_alloc+0x4a>
  80041d:	89 c2                	mov    %eax,%edx
  80041f:	c1 ea 0c             	shr    $0xc,%edx
  800422:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800429:	f6 c2 01             	test   $0x1,%dl
  80042c:	74 1c                	je     80044a <fd_alloc+0x4a>
  80042e:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800433:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800438:	75 d2                	jne    80040c <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80043a:	8b 45 08             	mov    0x8(%ebp),%eax
  80043d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800443:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800448:	eb 0a                	jmp    800454 <fd_alloc+0x54>
			*fd_store = fd;
  80044a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80044d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80044f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800454:	5d                   	pop    %ebp
  800455:	c3                   	ret    

00800456 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800456:	f3 0f 1e fb          	endbr32 
  80045a:	55                   	push   %ebp
  80045b:	89 e5                	mov    %esp,%ebp
  80045d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800460:	83 f8 1f             	cmp    $0x1f,%eax
  800463:	77 30                	ja     800495 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800465:	c1 e0 0c             	shl    $0xc,%eax
  800468:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80046d:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800473:	f6 c2 01             	test   $0x1,%dl
  800476:	74 24                	je     80049c <fd_lookup+0x46>
  800478:	89 c2                	mov    %eax,%edx
  80047a:	c1 ea 0c             	shr    $0xc,%edx
  80047d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800484:	f6 c2 01             	test   $0x1,%dl
  800487:	74 1a                	je     8004a3 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800489:	8b 55 0c             	mov    0xc(%ebp),%edx
  80048c:	89 02                	mov    %eax,(%edx)
	return 0;
  80048e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800493:	5d                   	pop    %ebp
  800494:	c3                   	ret    
		return -E_INVAL;
  800495:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80049a:	eb f7                	jmp    800493 <fd_lookup+0x3d>
		return -E_INVAL;
  80049c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004a1:	eb f0                	jmp    800493 <fd_lookup+0x3d>
  8004a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004a8:	eb e9                	jmp    800493 <fd_lookup+0x3d>

008004aa <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004aa:	f3 0f 1e fb          	endbr32 
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004b7:	ba 34 20 80 00       	mov    $0x802034,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004bc:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8004c1:	39 08                	cmp    %ecx,(%eax)
  8004c3:	74 33                	je     8004f8 <dev_lookup+0x4e>
  8004c5:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8004c8:	8b 02                	mov    (%edx),%eax
  8004ca:	85 c0                	test   %eax,%eax
  8004cc:	75 f3                	jne    8004c1 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004ce:	a1 04 40 80 00       	mov    0x804004,%eax
  8004d3:	8b 40 48             	mov    0x48(%eax),%eax
  8004d6:	83 ec 04             	sub    $0x4,%esp
  8004d9:	51                   	push   %ecx
  8004da:	50                   	push   %eax
  8004db:	68 b8 1f 80 00       	push   $0x801fb8
  8004e0:	e8 ec 0c 00 00       	call   8011d1 <cprintf>
	*dev = 0;
  8004e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004ee:	83 c4 10             	add    $0x10,%esp
  8004f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004f6:	c9                   	leave  
  8004f7:	c3                   	ret    
			*dev = devtab[i];
  8004f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004fb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800502:	eb f2                	jmp    8004f6 <dev_lookup+0x4c>

00800504 <fd_close>:
{
  800504:	f3 0f 1e fb          	endbr32 
  800508:	55                   	push   %ebp
  800509:	89 e5                	mov    %esp,%ebp
  80050b:	57                   	push   %edi
  80050c:	56                   	push   %esi
  80050d:	53                   	push   %ebx
  80050e:	83 ec 24             	sub    $0x24,%esp
  800511:	8b 75 08             	mov    0x8(%ebp),%esi
  800514:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800517:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80051a:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80051b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800521:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800524:	50                   	push   %eax
  800525:	e8 2c ff ff ff       	call   800456 <fd_lookup>
  80052a:	89 c3                	mov    %eax,%ebx
  80052c:	83 c4 10             	add    $0x10,%esp
  80052f:	85 c0                	test   %eax,%eax
  800531:	78 05                	js     800538 <fd_close+0x34>
	    || fd != fd2)
  800533:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800536:	74 16                	je     80054e <fd_close+0x4a>
		return (must_exist ? r : 0);
  800538:	89 f8                	mov    %edi,%eax
  80053a:	84 c0                	test   %al,%al
  80053c:	b8 00 00 00 00       	mov    $0x0,%eax
  800541:	0f 44 d8             	cmove  %eax,%ebx
}
  800544:	89 d8                	mov    %ebx,%eax
  800546:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800549:	5b                   	pop    %ebx
  80054a:	5e                   	pop    %esi
  80054b:	5f                   	pop    %edi
  80054c:	5d                   	pop    %ebp
  80054d:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80054e:	83 ec 08             	sub    $0x8,%esp
  800551:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800554:	50                   	push   %eax
  800555:	ff 36                	pushl  (%esi)
  800557:	e8 4e ff ff ff       	call   8004aa <dev_lookup>
  80055c:	89 c3                	mov    %eax,%ebx
  80055e:	83 c4 10             	add    $0x10,%esp
  800561:	85 c0                	test   %eax,%eax
  800563:	78 1a                	js     80057f <fd_close+0x7b>
		if (dev->dev_close)
  800565:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800568:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80056b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800570:	85 c0                	test   %eax,%eax
  800572:	74 0b                	je     80057f <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800574:	83 ec 0c             	sub    $0xc,%esp
  800577:	56                   	push   %esi
  800578:	ff d0                	call   *%eax
  80057a:	89 c3                	mov    %eax,%ebx
  80057c:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80057f:	83 ec 08             	sub    $0x8,%esp
  800582:	56                   	push   %esi
  800583:	6a 00                	push   $0x0
  800585:	e8 9d fc ff ff       	call   800227 <sys_page_unmap>
	return r;
  80058a:	83 c4 10             	add    $0x10,%esp
  80058d:	eb b5                	jmp    800544 <fd_close+0x40>

0080058f <close>:

int
close(int fdnum)
{
  80058f:	f3 0f 1e fb          	endbr32 
  800593:	55                   	push   %ebp
  800594:	89 e5                	mov    %esp,%ebp
  800596:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800599:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80059c:	50                   	push   %eax
  80059d:	ff 75 08             	pushl  0x8(%ebp)
  8005a0:	e8 b1 fe ff ff       	call   800456 <fd_lookup>
  8005a5:	83 c4 10             	add    $0x10,%esp
  8005a8:	85 c0                	test   %eax,%eax
  8005aa:	79 02                	jns    8005ae <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8005ac:	c9                   	leave  
  8005ad:	c3                   	ret    
		return fd_close(fd, 1);
  8005ae:	83 ec 08             	sub    $0x8,%esp
  8005b1:	6a 01                	push   $0x1
  8005b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8005b6:	e8 49 ff ff ff       	call   800504 <fd_close>
  8005bb:	83 c4 10             	add    $0x10,%esp
  8005be:	eb ec                	jmp    8005ac <close+0x1d>

008005c0 <close_all>:

void
close_all(void)
{
  8005c0:	f3 0f 1e fb          	endbr32 
  8005c4:	55                   	push   %ebp
  8005c5:	89 e5                	mov    %esp,%ebp
  8005c7:	53                   	push   %ebx
  8005c8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005cb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005d0:	83 ec 0c             	sub    $0xc,%esp
  8005d3:	53                   	push   %ebx
  8005d4:	e8 b6 ff ff ff       	call   80058f <close>
	for (i = 0; i < MAXFD; i++)
  8005d9:	83 c3 01             	add    $0x1,%ebx
  8005dc:	83 c4 10             	add    $0x10,%esp
  8005df:	83 fb 20             	cmp    $0x20,%ebx
  8005e2:	75 ec                	jne    8005d0 <close_all+0x10>
}
  8005e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005e7:	c9                   	leave  
  8005e8:	c3                   	ret    

008005e9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005e9:	f3 0f 1e fb          	endbr32 
  8005ed:	55                   	push   %ebp
  8005ee:	89 e5                	mov    %esp,%ebp
  8005f0:	57                   	push   %edi
  8005f1:	56                   	push   %esi
  8005f2:	53                   	push   %ebx
  8005f3:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005f6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005f9:	50                   	push   %eax
  8005fa:	ff 75 08             	pushl  0x8(%ebp)
  8005fd:	e8 54 fe ff ff       	call   800456 <fd_lookup>
  800602:	89 c3                	mov    %eax,%ebx
  800604:	83 c4 10             	add    $0x10,%esp
  800607:	85 c0                	test   %eax,%eax
  800609:	0f 88 81 00 00 00    	js     800690 <dup+0xa7>
		return r;
	close(newfdnum);
  80060f:	83 ec 0c             	sub    $0xc,%esp
  800612:	ff 75 0c             	pushl  0xc(%ebp)
  800615:	e8 75 ff ff ff       	call   80058f <close>

	newfd = INDEX2FD(newfdnum);
  80061a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80061d:	c1 e6 0c             	shl    $0xc,%esi
  800620:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800626:	83 c4 04             	add    $0x4,%esp
  800629:	ff 75 e4             	pushl  -0x1c(%ebp)
  80062c:	e8 b4 fd ff ff       	call   8003e5 <fd2data>
  800631:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800633:	89 34 24             	mov    %esi,(%esp)
  800636:	e8 aa fd ff ff       	call   8003e5 <fd2data>
  80063b:	83 c4 10             	add    $0x10,%esp
  80063e:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800640:	89 d8                	mov    %ebx,%eax
  800642:	c1 e8 16             	shr    $0x16,%eax
  800645:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80064c:	a8 01                	test   $0x1,%al
  80064e:	74 11                	je     800661 <dup+0x78>
  800650:	89 d8                	mov    %ebx,%eax
  800652:	c1 e8 0c             	shr    $0xc,%eax
  800655:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80065c:	f6 c2 01             	test   $0x1,%dl
  80065f:	75 39                	jne    80069a <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800661:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800664:	89 d0                	mov    %edx,%eax
  800666:	c1 e8 0c             	shr    $0xc,%eax
  800669:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800670:	83 ec 0c             	sub    $0xc,%esp
  800673:	25 07 0e 00 00       	and    $0xe07,%eax
  800678:	50                   	push   %eax
  800679:	56                   	push   %esi
  80067a:	6a 00                	push   $0x0
  80067c:	52                   	push   %edx
  80067d:	6a 00                	push   $0x0
  80067f:	e8 5d fb ff ff       	call   8001e1 <sys_page_map>
  800684:	89 c3                	mov    %eax,%ebx
  800686:	83 c4 20             	add    $0x20,%esp
  800689:	85 c0                	test   %eax,%eax
  80068b:	78 31                	js     8006be <dup+0xd5>
		goto err;

	return newfdnum;
  80068d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800690:	89 d8                	mov    %ebx,%eax
  800692:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800695:	5b                   	pop    %ebx
  800696:	5e                   	pop    %esi
  800697:	5f                   	pop    %edi
  800698:	5d                   	pop    %ebp
  800699:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80069a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006a1:	83 ec 0c             	sub    $0xc,%esp
  8006a4:	25 07 0e 00 00       	and    $0xe07,%eax
  8006a9:	50                   	push   %eax
  8006aa:	57                   	push   %edi
  8006ab:	6a 00                	push   $0x0
  8006ad:	53                   	push   %ebx
  8006ae:	6a 00                	push   $0x0
  8006b0:	e8 2c fb ff ff       	call   8001e1 <sys_page_map>
  8006b5:	89 c3                	mov    %eax,%ebx
  8006b7:	83 c4 20             	add    $0x20,%esp
  8006ba:	85 c0                	test   %eax,%eax
  8006bc:	79 a3                	jns    800661 <dup+0x78>
	sys_page_unmap(0, newfd);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	56                   	push   %esi
  8006c2:	6a 00                	push   $0x0
  8006c4:	e8 5e fb ff ff       	call   800227 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006c9:	83 c4 08             	add    $0x8,%esp
  8006cc:	57                   	push   %edi
  8006cd:	6a 00                	push   $0x0
  8006cf:	e8 53 fb ff ff       	call   800227 <sys_page_unmap>
	return r;
  8006d4:	83 c4 10             	add    $0x10,%esp
  8006d7:	eb b7                	jmp    800690 <dup+0xa7>

008006d9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006d9:	f3 0f 1e fb          	endbr32 
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	53                   	push   %ebx
  8006e1:	83 ec 1c             	sub    $0x1c,%esp
  8006e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006ea:	50                   	push   %eax
  8006eb:	53                   	push   %ebx
  8006ec:	e8 65 fd ff ff       	call   800456 <fd_lookup>
  8006f1:	83 c4 10             	add    $0x10,%esp
  8006f4:	85 c0                	test   %eax,%eax
  8006f6:	78 3f                	js     800737 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006f8:	83 ec 08             	sub    $0x8,%esp
  8006fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006fe:	50                   	push   %eax
  8006ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800702:	ff 30                	pushl  (%eax)
  800704:	e8 a1 fd ff ff       	call   8004aa <dev_lookup>
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	85 c0                	test   %eax,%eax
  80070e:	78 27                	js     800737 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800710:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800713:	8b 42 08             	mov    0x8(%edx),%eax
  800716:	83 e0 03             	and    $0x3,%eax
  800719:	83 f8 01             	cmp    $0x1,%eax
  80071c:	74 1e                	je     80073c <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80071e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800721:	8b 40 08             	mov    0x8(%eax),%eax
  800724:	85 c0                	test   %eax,%eax
  800726:	74 35                	je     80075d <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800728:	83 ec 04             	sub    $0x4,%esp
  80072b:	ff 75 10             	pushl  0x10(%ebp)
  80072e:	ff 75 0c             	pushl  0xc(%ebp)
  800731:	52                   	push   %edx
  800732:	ff d0                	call   *%eax
  800734:	83 c4 10             	add    $0x10,%esp
}
  800737:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80073a:	c9                   	leave  
  80073b:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80073c:	a1 04 40 80 00       	mov    0x804004,%eax
  800741:	8b 40 48             	mov    0x48(%eax),%eax
  800744:	83 ec 04             	sub    $0x4,%esp
  800747:	53                   	push   %ebx
  800748:	50                   	push   %eax
  800749:	68 f9 1f 80 00       	push   $0x801ff9
  80074e:	e8 7e 0a 00 00       	call   8011d1 <cprintf>
		return -E_INVAL;
  800753:	83 c4 10             	add    $0x10,%esp
  800756:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075b:	eb da                	jmp    800737 <read+0x5e>
		return -E_NOT_SUPP;
  80075d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800762:	eb d3                	jmp    800737 <read+0x5e>

00800764 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800764:	f3 0f 1e fb          	endbr32 
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	57                   	push   %edi
  80076c:	56                   	push   %esi
  80076d:	53                   	push   %ebx
  80076e:	83 ec 0c             	sub    $0xc,%esp
  800771:	8b 7d 08             	mov    0x8(%ebp),%edi
  800774:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800777:	bb 00 00 00 00       	mov    $0x0,%ebx
  80077c:	eb 02                	jmp    800780 <readn+0x1c>
  80077e:	01 c3                	add    %eax,%ebx
  800780:	39 f3                	cmp    %esi,%ebx
  800782:	73 21                	jae    8007a5 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800784:	83 ec 04             	sub    $0x4,%esp
  800787:	89 f0                	mov    %esi,%eax
  800789:	29 d8                	sub    %ebx,%eax
  80078b:	50                   	push   %eax
  80078c:	89 d8                	mov    %ebx,%eax
  80078e:	03 45 0c             	add    0xc(%ebp),%eax
  800791:	50                   	push   %eax
  800792:	57                   	push   %edi
  800793:	e8 41 ff ff ff       	call   8006d9 <read>
		if (m < 0)
  800798:	83 c4 10             	add    $0x10,%esp
  80079b:	85 c0                	test   %eax,%eax
  80079d:	78 04                	js     8007a3 <readn+0x3f>
			return m;
		if (m == 0)
  80079f:	75 dd                	jne    80077e <readn+0x1a>
  8007a1:	eb 02                	jmp    8007a5 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007a3:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8007a5:	89 d8                	mov    %ebx,%eax
  8007a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007aa:	5b                   	pop    %ebx
  8007ab:	5e                   	pop    %esi
  8007ac:	5f                   	pop    %edi
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007af:	f3 0f 1e fb          	endbr32 
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	53                   	push   %ebx
  8007b7:	83 ec 1c             	sub    $0x1c,%esp
  8007ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c0:	50                   	push   %eax
  8007c1:	53                   	push   %ebx
  8007c2:	e8 8f fc ff ff       	call   800456 <fd_lookup>
  8007c7:	83 c4 10             	add    $0x10,%esp
  8007ca:	85 c0                	test   %eax,%eax
  8007cc:	78 3a                	js     800808 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ce:	83 ec 08             	sub    $0x8,%esp
  8007d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d4:	50                   	push   %eax
  8007d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d8:	ff 30                	pushl  (%eax)
  8007da:	e8 cb fc ff ff       	call   8004aa <dev_lookup>
  8007df:	83 c4 10             	add    $0x10,%esp
  8007e2:	85 c0                	test   %eax,%eax
  8007e4:	78 22                	js     800808 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ed:	74 1e                	je     80080d <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007f2:	8b 52 0c             	mov    0xc(%edx),%edx
  8007f5:	85 d2                	test   %edx,%edx
  8007f7:	74 35                	je     80082e <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007f9:	83 ec 04             	sub    $0x4,%esp
  8007fc:	ff 75 10             	pushl  0x10(%ebp)
  8007ff:	ff 75 0c             	pushl  0xc(%ebp)
  800802:	50                   	push   %eax
  800803:	ff d2                	call   *%edx
  800805:	83 c4 10             	add    $0x10,%esp
}
  800808:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080b:	c9                   	leave  
  80080c:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80080d:	a1 04 40 80 00       	mov    0x804004,%eax
  800812:	8b 40 48             	mov    0x48(%eax),%eax
  800815:	83 ec 04             	sub    $0x4,%esp
  800818:	53                   	push   %ebx
  800819:	50                   	push   %eax
  80081a:	68 15 20 80 00       	push   $0x802015
  80081f:	e8 ad 09 00 00       	call   8011d1 <cprintf>
		return -E_INVAL;
  800824:	83 c4 10             	add    $0x10,%esp
  800827:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082c:	eb da                	jmp    800808 <write+0x59>
		return -E_NOT_SUPP;
  80082e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800833:	eb d3                	jmp    800808 <write+0x59>

00800835 <seek>:

int
seek(int fdnum, off_t offset)
{
  800835:	f3 0f 1e fb          	endbr32 
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80083f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800842:	50                   	push   %eax
  800843:	ff 75 08             	pushl  0x8(%ebp)
  800846:	e8 0b fc ff ff       	call   800456 <fd_lookup>
  80084b:	83 c4 10             	add    $0x10,%esp
  80084e:	85 c0                	test   %eax,%eax
  800850:	78 0e                	js     800860 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  800852:	8b 55 0c             	mov    0xc(%ebp),%edx
  800855:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800858:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80085b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800860:	c9                   	leave  
  800861:	c3                   	ret    

00800862 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800862:	f3 0f 1e fb          	endbr32 
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	53                   	push   %ebx
  80086a:	83 ec 1c             	sub    $0x1c,%esp
  80086d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800870:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800873:	50                   	push   %eax
  800874:	53                   	push   %ebx
  800875:	e8 dc fb ff ff       	call   800456 <fd_lookup>
  80087a:	83 c4 10             	add    $0x10,%esp
  80087d:	85 c0                	test   %eax,%eax
  80087f:	78 37                	js     8008b8 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800881:	83 ec 08             	sub    $0x8,%esp
  800884:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800887:	50                   	push   %eax
  800888:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088b:	ff 30                	pushl  (%eax)
  80088d:	e8 18 fc ff ff       	call   8004aa <dev_lookup>
  800892:	83 c4 10             	add    $0x10,%esp
  800895:	85 c0                	test   %eax,%eax
  800897:	78 1f                	js     8008b8 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800899:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80089c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008a0:	74 1b                	je     8008bd <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8008a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008a5:	8b 52 18             	mov    0x18(%edx),%edx
  8008a8:	85 d2                	test   %edx,%edx
  8008aa:	74 32                	je     8008de <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	ff 75 0c             	pushl  0xc(%ebp)
  8008b2:	50                   	push   %eax
  8008b3:	ff d2                	call   *%edx
  8008b5:	83 c4 10             	add    $0x10,%esp
}
  8008b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    
			thisenv->env_id, fdnum);
  8008bd:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008c2:	8b 40 48             	mov    0x48(%eax),%eax
  8008c5:	83 ec 04             	sub    $0x4,%esp
  8008c8:	53                   	push   %ebx
  8008c9:	50                   	push   %eax
  8008ca:	68 d8 1f 80 00       	push   $0x801fd8
  8008cf:	e8 fd 08 00 00       	call   8011d1 <cprintf>
		return -E_INVAL;
  8008d4:	83 c4 10             	add    $0x10,%esp
  8008d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008dc:	eb da                	jmp    8008b8 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8008de:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008e3:	eb d3                	jmp    8008b8 <ftruncate+0x56>

008008e5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008e5:	f3 0f 1e fb          	endbr32 
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	53                   	push   %ebx
  8008ed:	83 ec 1c             	sub    $0x1c,%esp
  8008f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008f6:	50                   	push   %eax
  8008f7:	ff 75 08             	pushl  0x8(%ebp)
  8008fa:	e8 57 fb ff ff       	call   800456 <fd_lookup>
  8008ff:	83 c4 10             	add    $0x10,%esp
  800902:	85 c0                	test   %eax,%eax
  800904:	78 4b                	js     800951 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800906:	83 ec 08             	sub    $0x8,%esp
  800909:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80090c:	50                   	push   %eax
  80090d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800910:	ff 30                	pushl  (%eax)
  800912:	e8 93 fb ff ff       	call   8004aa <dev_lookup>
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	85 c0                	test   %eax,%eax
  80091c:	78 33                	js     800951 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80091e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800921:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800925:	74 2f                	je     800956 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800927:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80092a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800931:	00 00 00 
	stat->st_isdir = 0;
  800934:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80093b:	00 00 00 
	stat->st_dev = dev;
  80093e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800944:	83 ec 08             	sub    $0x8,%esp
  800947:	53                   	push   %ebx
  800948:	ff 75 f0             	pushl  -0x10(%ebp)
  80094b:	ff 50 14             	call   *0x14(%eax)
  80094e:	83 c4 10             	add    $0x10,%esp
}
  800951:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800954:	c9                   	leave  
  800955:	c3                   	ret    
		return -E_NOT_SUPP;
  800956:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80095b:	eb f4                	jmp    800951 <fstat+0x6c>

0080095d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80095d:	f3 0f 1e fb          	endbr32 
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	56                   	push   %esi
  800965:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800966:	83 ec 08             	sub    $0x8,%esp
  800969:	6a 00                	push   $0x0
  80096b:	ff 75 08             	pushl  0x8(%ebp)
  80096e:	e8 cf 01 00 00       	call   800b42 <open>
  800973:	89 c3                	mov    %eax,%ebx
  800975:	83 c4 10             	add    $0x10,%esp
  800978:	85 c0                	test   %eax,%eax
  80097a:	78 1b                	js     800997 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80097c:	83 ec 08             	sub    $0x8,%esp
  80097f:	ff 75 0c             	pushl  0xc(%ebp)
  800982:	50                   	push   %eax
  800983:	e8 5d ff ff ff       	call   8008e5 <fstat>
  800988:	89 c6                	mov    %eax,%esi
	close(fd);
  80098a:	89 1c 24             	mov    %ebx,(%esp)
  80098d:	e8 fd fb ff ff       	call   80058f <close>
	return r;
  800992:	83 c4 10             	add    $0x10,%esp
  800995:	89 f3                	mov    %esi,%ebx
}
  800997:	89 d8                	mov    %ebx,%eax
  800999:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	56                   	push   %esi
  8009a4:	53                   	push   %ebx
  8009a5:	89 c6                	mov    %eax,%esi
  8009a7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009a9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009b0:	74 27                	je     8009d9 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009b2:	6a 07                	push   $0x7
  8009b4:	68 00 50 80 00       	push   $0x805000
  8009b9:	56                   	push   %esi
  8009ba:	ff 35 00 40 80 00    	pushl  0x804000
  8009c0:	e8 5e 12 00 00       	call   801c23 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009c5:	83 c4 0c             	add    $0xc,%esp
  8009c8:	6a 00                	push   $0x0
  8009ca:	53                   	push   %ebx
  8009cb:	6a 00                	push   $0x0
  8009cd:	e8 fa 11 00 00       	call   801bcc <ipc_recv>
}
  8009d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009d5:	5b                   	pop    %ebx
  8009d6:	5e                   	pop    %esi
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009d9:	83 ec 0c             	sub    $0xc,%esp
  8009dc:	6a 01                	push   $0x1
  8009de:	e8 a6 12 00 00       	call   801c89 <ipc_find_env>
  8009e3:	a3 00 40 80 00       	mov    %eax,0x804000
  8009e8:	83 c4 10             	add    $0x10,%esp
  8009eb:	eb c5                	jmp    8009b2 <fsipc+0x12>

008009ed <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009ed:	f3 0f 1e fb          	endbr32 
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009fd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a05:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0f:	b8 02 00 00 00       	mov    $0x2,%eax
  800a14:	e8 87 ff ff ff       	call   8009a0 <fsipc>
}
  800a19:	c9                   	leave  
  800a1a:	c3                   	ret    

00800a1b <devfile_flush>:
{
  800a1b:	f3 0f 1e fb          	endbr32 
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a25:	8b 45 08             	mov    0x8(%ebp),%eax
  800a28:	8b 40 0c             	mov    0xc(%eax),%eax
  800a2b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a30:	ba 00 00 00 00       	mov    $0x0,%edx
  800a35:	b8 06 00 00 00       	mov    $0x6,%eax
  800a3a:	e8 61 ff ff ff       	call   8009a0 <fsipc>
}
  800a3f:	c9                   	leave  
  800a40:	c3                   	ret    

00800a41 <devfile_stat>:
{
  800a41:	f3 0f 1e fb          	endbr32 
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	53                   	push   %ebx
  800a49:	83 ec 04             	sub    $0x4,%esp
  800a4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a52:	8b 40 0c             	mov    0xc(%eax),%eax
  800a55:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5f:	b8 05 00 00 00       	mov    $0x5,%eax
  800a64:	e8 37 ff ff ff       	call   8009a0 <fsipc>
  800a69:	85 c0                	test   %eax,%eax
  800a6b:	78 2c                	js     800a99 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a6d:	83 ec 08             	sub    $0x8,%esp
  800a70:	68 00 50 80 00       	push   $0x805000
  800a75:	53                   	push   %ebx
  800a76:	e8 5f 0d 00 00       	call   8017da <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a7b:	a1 80 50 80 00       	mov    0x805080,%eax
  800a80:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a86:	a1 84 50 80 00       	mov    0x805084,%eax
  800a8b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a91:	83 c4 10             	add    $0x10,%esp
  800a94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9c:	c9                   	leave  
  800a9d:	c3                   	ret    

00800a9e <devfile_write>:
{
  800a9e:	f3 0f 1e fb          	endbr32 
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	83 ec 0c             	sub    $0xc,%esp
	panic("devfile_write not implemented");
  800aa8:	68 44 20 80 00       	push   $0x802044
  800aad:	68 90 00 00 00       	push   $0x90
  800ab2:	68 62 20 80 00       	push   $0x802062
  800ab7:	e8 2e 06 00 00       	call   8010ea <_panic>

00800abc <devfile_read>:
{
  800abc:	f3 0f 1e fb          	endbr32 
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	56                   	push   %esi
  800ac4:	53                   	push   %ebx
  800ac5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  800acb:	8b 40 0c             	mov    0xc(%eax),%eax
  800ace:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ad3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ad9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ade:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae3:	e8 b8 fe ff ff       	call   8009a0 <fsipc>
  800ae8:	89 c3                	mov    %eax,%ebx
  800aea:	85 c0                	test   %eax,%eax
  800aec:	78 1f                	js     800b0d <devfile_read+0x51>
	assert(r <= n);
  800aee:	39 f0                	cmp    %esi,%eax
  800af0:	77 24                	ja     800b16 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800af2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800af7:	7f 33                	jg     800b2c <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800af9:	83 ec 04             	sub    $0x4,%esp
  800afc:	50                   	push   %eax
  800afd:	68 00 50 80 00       	push   $0x805000
  800b02:	ff 75 0c             	pushl  0xc(%ebp)
  800b05:	e8 86 0e 00 00       	call   801990 <memmove>
	return r;
  800b0a:	83 c4 10             	add    $0x10,%esp
}
  800b0d:	89 d8                	mov    %ebx,%eax
  800b0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    
	assert(r <= n);
  800b16:	68 6d 20 80 00       	push   $0x80206d
  800b1b:	68 74 20 80 00       	push   $0x802074
  800b20:	6a 7c                	push   $0x7c
  800b22:	68 62 20 80 00       	push   $0x802062
  800b27:	e8 be 05 00 00       	call   8010ea <_panic>
	assert(r <= PGSIZE);
  800b2c:	68 89 20 80 00       	push   $0x802089
  800b31:	68 74 20 80 00       	push   $0x802074
  800b36:	6a 7d                	push   $0x7d
  800b38:	68 62 20 80 00       	push   $0x802062
  800b3d:	e8 a8 05 00 00       	call   8010ea <_panic>

00800b42 <open>:
{
  800b42:	f3 0f 1e fb          	endbr32 
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
  800b4b:	83 ec 1c             	sub    $0x1c,%esp
  800b4e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b51:	56                   	push   %esi
  800b52:	e8 40 0c 00 00       	call   801797 <strlen>
  800b57:	83 c4 10             	add    $0x10,%esp
  800b5a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b5f:	7f 6c                	jg     800bcd <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800b61:	83 ec 0c             	sub    $0xc,%esp
  800b64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b67:	50                   	push   %eax
  800b68:	e8 93 f8 ff ff       	call   800400 <fd_alloc>
  800b6d:	89 c3                	mov    %eax,%ebx
  800b6f:	83 c4 10             	add    $0x10,%esp
  800b72:	85 c0                	test   %eax,%eax
  800b74:	78 3c                	js     800bb2 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b76:	83 ec 08             	sub    $0x8,%esp
  800b79:	56                   	push   %esi
  800b7a:	68 00 50 80 00       	push   $0x805000
  800b7f:	e8 56 0c 00 00       	call   8017da <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b87:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b8f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b94:	e8 07 fe ff ff       	call   8009a0 <fsipc>
  800b99:	89 c3                	mov    %eax,%ebx
  800b9b:	83 c4 10             	add    $0x10,%esp
  800b9e:	85 c0                	test   %eax,%eax
  800ba0:	78 19                	js     800bbb <open+0x79>
	return fd2num(fd);
  800ba2:	83 ec 0c             	sub    $0xc,%esp
  800ba5:	ff 75 f4             	pushl  -0xc(%ebp)
  800ba8:	e8 24 f8 ff ff       	call   8003d1 <fd2num>
  800bad:	89 c3                	mov    %eax,%ebx
  800baf:	83 c4 10             	add    $0x10,%esp
}
  800bb2:	89 d8                	mov    %ebx,%eax
  800bb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    
		fd_close(fd, 0);
  800bbb:	83 ec 08             	sub    $0x8,%esp
  800bbe:	6a 00                	push   $0x0
  800bc0:	ff 75 f4             	pushl  -0xc(%ebp)
  800bc3:	e8 3c f9 ff ff       	call   800504 <fd_close>
		return r;
  800bc8:	83 c4 10             	add    $0x10,%esp
  800bcb:	eb e5                	jmp    800bb2 <open+0x70>
		return -E_BAD_PATH;
  800bcd:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800bd2:	eb de                	jmp    800bb2 <open+0x70>

00800bd4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bd4:	f3 0f 1e fb          	endbr32 
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bde:	ba 00 00 00 00       	mov    $0x0,%edx
  800be3:	b8 08 00 00 00       	mov    $0x8,%eax
  800be8:	e8 b3 fd ff ff       	call   8009a0 <fsipc>
}
  800bed:	c9                   	leave  
  800bee:	c3                   	ret    

00800bef <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bef:	f3 0f 1e fb          	endbr32 
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bfb:	83 ec 0c             	sub    $0xc,%esp
  800bfe:	ff 75 08             	pushl  0x8(%ebp)
  800c01:	e8 df f7 ff ff       	call   8003e5 <fd2data>
  800c06:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800c08:	83 c4 08             	add    $0x8,%esp
  800c0b:	68 95 20 80 00       	push   $0x802095
  800c10:	53                   	push   %ebx
  800c11:	e8 c4 0b 00 00       	call   8017da <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800c16:	8b 46 04             	mov    0x4(%esi),%eax
  800c19:	2b 06                	sub    (%esi),%eax
  800c1b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800c21:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c28:	00 00 00 
	stat->st_dev = &devpipe;
  800c2b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c32:	30 80 00 
	return 0;
}
  800c35:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c41:	f3 0f 1e fb          	endbr32 
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	53                   	push   %ebx
  800c49:	83 ec 0c             	sub    $0xc,%esp
  800c4c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c4f:	53                   	push   %ebx
  800c50:	6a 00                	push   $0x0
  800c52:	e8 d0 f5 ff ff       	call   800227 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c57:	89 1c 24             	mov    %ebx,(%esp)
  800c5a:	e8 86 f7 ff ff       	call   8003e5 <fd2data>
  800c5f:	83 c4 08             	add    $0x8,%esp
  800c62:	50                   	push   %eax
  800c63:	6a 00                	push   $0x0
  800c65:	e8 bd f5 ff ff       	call   800227 <sys_page_unmap>
}
  800c6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c6d:	c9                   	leave  
  800c6e:	c3                   	ret    

00800c6f <_pipeisclosed>:
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	57                   	push   %edi
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
  800c75:	83 ec 1c             	sub    $0x1c,%esp
  800c78:	89 c7                	mov    %eax,%edi
  800c7a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c7c:	a1 04 40 80 00       	mov    0x804004,%eax
  800c81:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c84:	83 ec 0c             	sub    $0xc,%esp
  800c87:	57                   	push   %edi
  800c88:	e8 39 10 00 00       	call   801cc6 <pageref>
  800c8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c90:	89 34 24             	mov    %esi,(%esp)
  800c93:	e8 2e 10 00 00       	call   801cc6 <pageref>
		nn = thisenv->env_runs;
  800c98:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c9e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800ca1:	83 c4 10             	add    $0x10,%esp
  800ca4:	39 cb                	cmp    %ecx,%ebx
  800ca6:	74 1b                	je     800cc3 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800ca8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800cab:	75 cf                	jne    800c7c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800cad:	8b 42 58             	mov    0x58(%edx),%eax
  800cb0:	6a 01                	push   $0x1
  800cb2:	50                   	push   %eax
  800cb3:	53                   	push   %ebx
  800cb4:	68 9c 20 80 00       	push   $0x80209c
  800cb9:	e8 13 05 00 00       	call   8011d1 <cprintf>
  800cbe:	83 c4 10             	add    $0x10,%esp
  800cc1:	eb b9                	jmp    800c7c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800cc3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800cc6:	0f 94 c0             	sete   %al
  800cc9:	0f b6 c0             	movzbl %al,%eax
}
  800ccc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <devpipe_write>:
{
  800cd4:	f3 0f 1e fb          	endbr32 
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
  800cde:	83 ec 28             	sub    $0x28,%esp
  800ce1:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800ce4:	56                   	push   %esi
  800ce5:	e8 fb f6 ff ff       	call   8003e5 <fd2data>
  800cea:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cec:	83 c4 10             	add    $0x10,%esp
  800cef:	bf 00 00 00 00       	mov    $0x0,%edi
  800cf4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cf7:	74 4f                	je     800d48 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cf9:	8b 43 04             	mov    0x4(%ebx),%eax
  800cfc:	8b 0b                	mov    (%ebx),%ecx
  800cfe:	8d 51 20             	lea    0x20(%ecx),%edx
  800d01:	39 d0                	cmp    %edx,%eax
  800d03:	72 14                	jb     800d19 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800d05:	89 da                	mov    %ebx,%edx
  800d07:	89 f0                	mov    %esi,%eax
  800d09:	e8 61 ff ff ff       	call   800c6f <_pipeisclosed>
  800d0e:	85 c0                	test   %eax,%eax
  800d10:	75 3b                	jne    800d4d <devpipe_write+0x79>
			sys_yield();
  800d12:	e8 60 f4 ff ff       	call   800177 <sys_yield>
  800d17:	eb e0                	jmp    800cf9 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d20:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d23:	89 c2                	mov    %eax,%edx
  800d25:	c1 fa 1f             	sar    $0x1f,%edx
  800d28:	89 d1                	mov    %edx,%ecx
  800d2a:	c1 e9 1b             	shr    $0x1b,%ecx
  800d2d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800d30:	83 e2 1f             	and    $0x1f,%edx
  800d33:	29 ca                	sub    %ecx,%edx
  800d35:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800d39:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d3d:	83 c0 01             	add    $0x1,%eax
  800d40:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800d43:	83 c7 01             	add    $0x1,%edi
  800d46:	eb ac                	jmp    800cf4 <devpipe_write+0x20>
	return i;
  800d48:	8b 45 10             	mov    0x10(%ebp),%eax
  800d4b:	eb 05                	jmp    800d52 <devpipe_write+0x7e>
				return 0;
  800d4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <devpipe_read>:
{
  800d5a:	f3 0f 1e fb          	endbr32 
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 18             	sub    $0x18,%esp
  800d67:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800d6a:	57                   	push   %edi
  800d6b:	e8 75 f6 ff ff       	call   8003e5 <fd2data>
  800d70:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d72:	83 c4 10             	add    $0x10,%esp
  800d75:	be 00 00 00 00       	mov    $0x0,%esi
  800d7a:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d7d:	75 14                	jne    800d93 <devpipe_read+0x39>
	return i;
  800d7f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d82:	eb 02                	jmp    800d86 <devpipe_read+0x2c>
				return i;
  800d84:	89 f0                	mov    %esi,%eax
}
  800d86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    
			sys_yield();
  800d8e:	e8 e4 f3 ff ff       	call   800177 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d93:	8b 03                	mov    (%ebx),%eax
  800d95:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d98:	75 18                	jne    800db2 <devpipe_read+0x58>
			if (i > 0)
  800d9a:	85 f6                	test   %esi,%esi
  800d9c:	75 e6                	jne    800d84 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d9e:	89 da                	mov    %ebx,%edx
  800da0:	89 f8                	mov    %edi,%eax
  800da2:	e8 c8 fe ff ff       	call   800c6f <_pipeisclosed>
  800da7:	85 c0                	test   %eax,%eax
  800da9:	74 e3                	je     800d8e <devpipe_read+0x34>
				return 0;
  800dab:	b8 00 00 00 00       	mov    $0x0,%eax
  800db0:	eb d4                	jmp    800d86 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800db2:	99                   	cltd   
  800db3:	c1 ea 1b             	shr    $0x1b,%edx
  800db6:	01 d0                	add    %edx,%eax
  800db8:	83 e0 1f             	and    $0x1f,%eax
  800dbb:	29 d0                	sub    %edx,%eax
  800dbd:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800dc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800dc8:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800dcb:	83 c6 01             	add    $0x1,%esi
  800dce:	eb aa                	jmp    800d7a <devpipe_read+0x20>

00800dd0 <pipe>:
{
  800dd0:	f3 0f 1e fb          	endbr32 
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
  800dd9:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800ddc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ddf:	50                   	push   %eax
  800de0:	e8 1b f6 ff ff       	call   800400 <fd_alloc>
  800de5:	89 c3                	mov    %eax,%ebx
  800de7:	83 c4 10             	add    $0x10,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	0f 88 23 01 00 00    	js     800f15 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df2:	83 ec 04             	sub    $0x4,%esp
  800df5:	68 07 04 00 00       	push   $0x407
  800dfa:	ff 75 f4             	pushl  -0xc(%ebp)
  800dfd:	6a 00                	push   $0x0
  800dff:	e8 96 f3 ff ff       	call   80019a <sys_page_alloc>
  800e04:	89 c3                	mov    %eax,%ebx
  800e06:	83 c4 10             	add    $0x10,%esp
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	0f 88 04 01 00 00    	js     800f15 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800e11:	83 ec 0c             	sub    $0xc,%esp
  800e14:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e17:	50                   	push   %eax
  800e18:	e8 e3 f5 ff ff       	call   800400 <fd_alloc>
  800e1d:	89 c3                	mov    %eax,%ebx
  800e1f:	83 c4 10             	add    $0x10,%esp
  800e22:	85 c0                	test   %eax,%eax
  800e24:	0f 88 db 00 00 00    	js     800f05 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e2a:	83 ec 04             	sub    $0x4,%esp
  800e2d:	68 07 04 00 00       	push   $0x407
  800e32:	ff 75 f0             	pushl  -0x10(%ebp)
  800e35:	6a 00                	push   $0x0
  800e37:	e8 5e f3 ff ff       	call   80019a <sys_page_alloc>
  800e3c:	89 c3                	mov    %eax,%ebx
  800e3e:	83 c4 10             	add    $0x10,%esp
  800e41:	85 c0                	test   %eax,%eax
  800e43:	0f 88 bc 00 00 00    	js     800f05 <pipe+0x135>
	va = fd2data(fd0);
  800e49:	83 ec 0c             	sub    $0xc,%esp
  800e4c:	ff 75 f4             	pushl  -0xc(%ebp)
  800e4f:	e8 91 f5 ff ff       	call   8003e5 <fd2data>
  800e54:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e56:	83 c4 0c             	add    $0xc,%esp
  800e59:	68 07 04 00 00       	push   $0x407
  800e5e:	50                   	push   %eax
  800e5f:	6a 00                	push   $0x0
  800e61:	e8 34 f3 ff ff       	call   80019a <sys_page_alloc>
  800e66:	89 c3                	mov    %eax,%ebx
  800e68:	83 c4 10             	add    $0x10,%esp
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	0f 88 82 00 00 00    	js     800ef5 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e73:	83 ec 0c             	sub    $0xc,%esp
  800e76:	ff 75 f0             	pushl  -0x10(%ebp)
  800e79:	e8 67 f5 ff ff       	call   8003e5 <fd2data>
  800e7e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e85:	50                   	push   %eax
  800e86:	6a 00                	push   $0x0
  800e88:	56                   	push   %esi
  800e89:	6a 00                	push   $0x0
  800e8b:	e8 51 f3 ff ff       	call   8001e1 <sys_page_map>
  800e90:	89 c3                	mov    %eax,%ebx
  800e92:	83 c4 20             	add    $0x20,%esp
  800e95:	85 c0                	test   %eax,%eax
  800e97:	78 4e                	js     800ee7 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e99:	a1 20 30 80 00       	mov    0x803020,%eax
  800e9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ea1:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800ea3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ea6:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800ead:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800eb0:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800eb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eb5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800ebc:	83 ec 0c             	sub    $0xc,%esp
  800ebf:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec2:	e8 0a f5 ff ff       	call   8003d1 <fd2num>
  800ec7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eca:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800ecc:	83 c4 04             	add    $0x4,%esp
  800ecf:	ff 75 f0             	pushl  -0x10(%ebp)
  800ed2:	e8 fa f4 ff ff       	call   8003d1 <fd2num>
  800ed7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eda:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800edd:	83 c4 10             	add    $0x10,%esp
  800ee0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee5:	eb 2e                	jmp    800f15 <pipe+0x145>
	sys_page_unmap(0, va);
  800ee7:	83 ec 08             	sub    $0x8,%esp
  800eea:	56                   	push   %esi
  800eeb:	6a 00                	push   $0x0
  800eed:	e8 35 f3 ff ff       	call   800227 <sys_page_unmap>
  800ef2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800ef5:	83 ec 08             	sub    $0x8,%esp
  800ef8:	ff 75 f0             	pushl  -0x10(%ebp)
  800efb:	6a 00                	push   $0x0
  800efd:	e8 25 f3 ff ff       	call   800227 <sys_page_unmap>
  800f02:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800f05:	83 ec 08             	sub    $0x8,%esp
  800f08:	ff 75 f4             	pushl  -0xc(%ebp)
  800f0b:	6a 00                	push   $0x0
  800f0d:	e8 15 f3 ff ff       	call   800227 <sys_page_unmap>
  800f12:	83 c4 10             	add    $0x10,%esp
}
  800f15:	89 d8                	mov    %ebx,%eax
  800f17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f1a:	5b                   	pop    %ebx
  800f1b:	5e                   	pop    %esi
  800f1c:	5d                   	pop    %ebp
  800f1d:	c3                   	ret    

00800f1e <pipeisclosed>:
{
  800f1e:	f3 0f 1e fb          	endbr32 
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f2b:	50                   	push   %eax
  800f2c:	ff 75 08             	pushl  0x8(%ebp)
  800f2f:	e8 22 f5 ff ff       	call   800456 <fd_lookup>
  800f34:	83 c4 10             	add    $0x10,%esp
  800f37:	85 c0                	test   %eax,%eax
  800f39:	78 18                	js     800f53 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800f3b:	83 ec 0c             	sub    $0xc,%esp
  800f3e:	ff 75 f4             	pushl  -0xc(%ebp)
  800f41:	e8 9f f4 ff ff       	call   8003e5 <fd2data>
  800f46:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f4b:	e8 1f fd ff ff       	call   800c6f <_pipeisclosed>
  800f50:	83 c4 10             	add    $0x10,%esp
}
  800f53:	c9                   	leave  
  800f54:	c3                   	ret    

00800f55 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f55:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800f59:	b8 00 00 00 00       	mov    $0x0,%eax
  800f5e:	c3                   	ret    

00800f5f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f5f:	f3 0f 1e fb          	endbr32 
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f69:	68 b4 20 80 00       	push   $0x8020b4
  800f6e:	ff 75 0c             	pushl  0xc(%ebp)
  800f71:	e8 64 08 00 00       	call   8017da <strcpy>
	return 0;
}
  800f76:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7b:	c9                   	leave  
  800f7c:	c3                   	ret    

00800f7d <devcons_write>:
{
  800f7d:	f3 0f 1e fb          	endbr32 
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	57                   	push   %edi
  800f85:	56                   	push   %esi
  800f86:	53                   	push   %ebx
  800f87:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f8d:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f92:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f98:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f9b:	73 31                	jae    800fce <devcons_write+0x51>
		m = n - tot;
  800f9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fa0:	29 f3                	sub    %esi,%ebx
  800fa2:	83 fb 7f             	cmp    $0x7f,%ebx
  800fa5:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800faa:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800fad:	83 ec 04             	sub    $0x4,%esp
  800fb0:	53                   	push   %ebx
  800fb1:	89 f0                	mov    %esi,%eax
  800fb3:	03 45 0c             	add    0xc(%ebp),%eax
  800fb6:	50                   	push   %eax
  800fb7:	57                   	push   %edi
  800fb8:	e8 d3 09 00 00       	call   801990 <memmove>
		sys_cputs(buf, m);
  800fbd:	83 c4 08             	add    $0x8,%esp
  800fc0:	53                   	push   %ebx
  800fc1:	57                   	push   %edi
  800fc2:	e8 03 f1 ff ff       	call   8000ca <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800fc7:	01 de                	add    %ebx,%esi
  800fc9:	83 c4 10             	add    $0x10,%esp
  800fcc:	eb ca                	jmp    800f98 <devcons_write+0x1b>
}
  800fce:	89 f0                	mov    %esi,%eax
  800fd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd3:	5b                   	pop    %ebx
  800fd4:	5e                   	pop    %esi
  800fd5:	5f                   	pop    %edi
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    

00800fd8 <devcons_read>:
{
  800fd8:	f3 0f 1e fb          	endbr32 
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 08             	sub    $0x8,%esp
  800fe2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800fe7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800feb:	74 21                	je     80100e <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800fed:	e8 fa f0 ff ff       	call   8000ec <sys_cgetc>
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	75 07                	jne    800ffd <devcons_read+0x25>
		sys_yield();
  800ff6:	e8 7c f1 ff ff       	call   800177 <sys_yield>
  800ffb:	eb f0                	jmp    800fed <devcons_read+0x15>
	if (c < 0)
  800ffd:	78 0f                	js     80100e <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800fff:	83 f8 04             	cmp    $0x4,%eax
  801002:	74 0c                	je     801010 <devcons_read+0x38>
	*(char*)vbuf = c;
  801004:	8b 55 0c             	mov    0xc(%ebp),%edx
  801007:	88 02                	mov    %al,(%edx)
	return 1;
  801009:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80100e:	c9                   	leave  
  80100f:	c3                   	ret    
		return 0;
  801010:	b8 00 00 00 00       	mov    $0x0,%eax
  801015:	eb f7                	jmp    80100e <devcons_read+0x36>

00801017 <cputchar>:
{
  801017:	f3 0f 1e fb          	endbr32 
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801021:	8b 45 08             	mov    0x8(%ebp),%eax
  801024:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801027:	6a 01                	push   $0x1
  801029:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80102c:	50                   	push   %eax
  80102d:	e8 98 f0 ff ff       	call   8000ca <sys_cputs>
}
  801032:	83 c4 10             	add    $0x10,%esp
  801035:	c9                   	leave  
  801036:	c3                   	ret    

00801037 <getchar>:
{
  801037:	f3 0f 1e fb          	endbr32 
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801041:	6a 01                	push   $0x1
  801043:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801046:	50                   	push   %eax
  801047:	6a 00                	push   $0x0
  801049:	e8 8b f6 ff ff       	call   8006d9 <read>
	if (r < 0)
  80104e:	83 c4 10             	add    $0x10,%esp
  801051:	85 c0                	test   %eax,%eax
  801053:	78 06                	js     80105b <getchar+0x24>
	if (r < 1)
  801055:	74 06                	je     80105d <getchar+0x26>
	return c;
  801057:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80105b:	c9                   	leave  
  80105c:	c3                   	ret    
		return -E_EOF;
  80105d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801062:	eb f7                	jmp    80105b <getchar+0x24>

00801064 <iscons>:
{
  801064:	f3 0f 1e fb          	endbr32 
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80106e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801071:	50                   	push   %eax
  801072:	ff 75 08             	pushl  0x8(%ebp)
  801075:	e8 dc f3 ff ff       	call   800456 <fd_lookup>
  80107a:	83 c4 10             	add    $0x10,%esp
  80107d:	85 c0                	test   %eax,%eax
  80107f:	78 11                	js     801092 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801081:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801084:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80108a:	39 10                	cmp    %edx,(%eax)
  80108c:	0f 94 c0             	sete   %al
  80108f:	0f b6 c0             	movzbl %al,%eax
}
  801092:	c9                   	leave  
  801093:	c3                   	ret    

00801094 <opencons>:
{
  801094:	f3 0f 1e fb          	endbr32 
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80109e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010a1:	50                   	push   %eax
  8010a2:	e8 59 f3 ff ff       	call   800400 <fd_alloc>
  8010a7:	83 c4 10             	add    $0x10,%esp
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	78 3a                	js     8010e8 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8010ae:	83 ec 04             	sub    $0x4,%esp
  8010b1:	68 07 04 00 00       	push   $0x407
  8010b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8010b9:	6a 00                	push   $0x0
  8010bb:	e8 da f0 ff ff       	call   80019a <sys_page_alloc>
  8010c0:	83 c4 10             	add    $0x10,%esp
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	78 21                	js     8010e8 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8010c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ca:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8010d0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8010d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010d5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8010dc:	83 ec 0c             	sub    $0xc,%esp
  8010df:	50                   	push   %eax
  8010e0:	e8 ec f2 ff ff       	call   8003d1 <fd2num>
  8010e5:	83 c4 10             	add    $0x10,%esp
}
  8010e8:	c9                   	leave  
  8010e9:	c3                   	ret    

008010ea <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010ea:	f3 0f 1e fb          	endbr32 
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	56                   	push   %esi
  8010f2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010f3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010f6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010fc:	e8 53 f0 ff ff       	call   800154 <sys_getenvid>
  801101:	83 ec 0c             	sub    $0xc,%esp
  801104:	ff 75 0c             	pushl  0xc(%ebp)
  801107:	ff 75 08             	pushl  0x8(%ebp)
  80110a:	56                   	push   %esi
  80110b:	50                   	push   %eax
  80110c:	68 c0 20 80 00       	push   $0x8020c0
  801111:	e8 bb 00 00 00       	call   8011d1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801116:	83 c4 18             	add    $0x18,%esp
  801119:	53                   	push   %ebx
  80111a:	ff 75 10             	pushl  0x10(%ebp)
  80111d:	e8 5a 00 00 00       	call   80117c <vcprintf>
	cprintf("\n");
  801122:	c7 04 24 ec 23 80 00 	movl   $0x8023ec,(%esp)
  801129:	e8 a3 00 00 00       	call   8011d1 <cprintf>
  80112e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801131:	cc                   	int3   
  801132:	eb fd                	jmp    801131 <_panic+0x47>

00801134 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801134:	f3 0f 1e fb          	endbr32 
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	53                   	push   %ebx
  80113c:	83 ec 04             	sub    $0x4,%esp
  80113f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801142:	8b 13                	mov    (%ebx),%edx
  801144:	8d 42 01             	lea    0x1(%edx),%eax
  801147:	89 03                	mov    %eax,(%ebx)
  801149:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80114c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801150:	3d ff 00 00 00       	cmp    $0xff,%eax
  801155:	74 09                	je     801160 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801157:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80115b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80115e:	c9                   	leave  
  80115f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801160:	83 ec 08             	sub    $0x8,%esp
  801163:	68 ff 00 00 00       	push   $0xff
  801168:	8d 43 08             	lea    0x8(%ebx),%eax
  80116b:	50                   	push   %eax
  80116c:	e8 59 ef ff ff       	call   8000ca <sys_cputs>
		b->idx = 0;
  801171:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801177:	83 c4 10             	add    $0x10,%esp
  80117a:	eb db                	jmp    801157 <putch+0x23>

0080117c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80117c:	f3 0f 1e fb          	endbr32 
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801189:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801190:	00 00 00 
	b.cnt = 0;
  801193:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80119a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80119d:	ff 75 0c             	pushl  0xc(%ebp)
  8011a0:	ff 75 08             	pushl  0x8(%ebp)
  8011a3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8011a9:	50                   	push   %eax
  8011aa:	68 34 11 80 00       	push   $0x801134
  8011af:	e8 20 01 00 00       	call   8012d4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8011b4:	83 c4 08             	add    $0x8,%esp
  8011b7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8011bd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8011c3:	50                   	push   %eax
  8011c4:	e8 01 ef ff ff       	call   8000ca <sys_cputs>

	return b.cnt;
}
  8011c9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8011cf:	c9                   	leave  
  8011d0:	c3                   	ret    

008011d1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8011d1:	f3 0f 1e fb          	endbr32 
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8011db:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8011de:	50                   	push   %eax
  8011df:	ff 75 08             	pushl  0x8(%ebp)
  8011e2:	e8 95 ff ff ff       	call   80117c <vcprintf>
	va_end(ap);

	return cnt;
}
  8011e7:	c9                   	leave  
  8011e8:	c3                   	ret    

008011e9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	57                   	push   %edi
  8011ed:	56                   	push   %esi
  8011ee:	53                   	push   %ebx
  8011ef:	83 ec 1c             	sub    $0x1c,%esp
  8011f2:	89 c7                	mov    %eax,%edi
  8011f4:	89 d6                	mov    %edx,%esi
  8011f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011fc:	89 d1                	mov    %edx,%ecx
  8011fe:	89 c2                	mov    %eax,%edx
  801200:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801203:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801206:	8b 45 10             	mov    0x10(%ebp),%eax
  801209:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80120c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80120f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801216:	39 c2                	cmp    %eax,%edx
  801218:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80121b:	72 3e                	jb     80125b <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80121d:	83 ec 0c             	sub    $0xc,%esp
  801220:	ff 75 18             	pushl  0x18(%ebp)
  801223:	83 eb 01             	sub    $0x1,%ebx
  801226:	53                   	push   %ebx
  801227:	50                   	push   %eax
  801228:	83 ec 08             	sub    $0x8,%esp
  80122b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80122e:	ff 75 e0             	pushl  -0x20(%ebp)
  801231:	ff 75 dc             	pushl  -0x24(%ebp)
  801234:	ff 75 d8             	pushl  -0x28(%ebp)
  801237:	e8 d4 0a 00 00       	call   801d10 <__udivdi3>
  80123c:	83 c4 18             	add    $0x18,%esp
  80123f:	52                   	push   %edx
  801240:	50                   	push   %eax
  801241:	89 f2                	mov    %esi,%edx
  801243:	89 f8                	mov    %edi,%eax
  801245:	e8 9f ff ff ff       	call   8011e9 <printnum>
  80124a:	83 c4 20             	add    $0x20,%esp
  80124d:	eb 13                	jmp    801262 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80124f:	83 ec 08             	sub    $0x8,%esp
  801252:	56                   	push   %esi
  801253:	ff 75 18             	pushl  0x18(%ebp)
  801256:	ff d7                	call   *%edi
  801258:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80125b:	83 eb 01             	sub    $0x1,%ebx
  80125e:	85 db                	test   %ebx,%ebx
  801260:	7f ed                	jg     80124f <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801262:	83 ec 08             	sub    $0x8,%esp
  801265:	56                   	push   %esi
  801266:	83 ec 04             	sub    $0x4,%esp
  801269:	ff 75 e4             	pushl  -0x1c(%ebp)
  80126c:	ff 75 e0             	pushl  -0x20(%ebp)
  80126f:	ff 75 dc             	pushl  -0x24(%ebp)
  801272:	ff 75 d8             	pushl  -0x28(%ebp)
  801275:	e8 a6 0b 00 00       	call   801e20 <__umoddi3>
  80127a:	83 c4 14             	add    $0x14,%esp
  80127d:	0f be 80 e3 20 80 00 	movsbl 0x8020e3(%eax),%eax
  801284:	50                   	push   %eax
  801285:	ff d7                	call   *%edi
}
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80128d:	5b                   	pop    %ebx
  80128e:	5e                   	pop    %esi
  80128f:	5f                   	pop    %edi
  801290:	5d                   	pop    %ebp
  801291:	c3                   	ret    

00801292 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801292:	f3 0f 1e fb          	endbr32 
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
  801299:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80129c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8012a0:	8b 10                	mov    (%eax),%edx
  8012a2:	3b 50 04             	cmp    0x4(%eax),%edx
  8012a5:	73 0a                	jae    8012b1 <sprintputch+0x1f>
		*b->buf++ = ch;
  8012a7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8012aa:	89 08                	mov    %ecx,(%eax)
  8012ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8012af:	88 02                	mov    %al,(%edx)
}
  8012b1:	5d                   	pop    %ebp
  8012b2:	c3                   	ret    

008012b3 <printfmt>:
{
  8012b3:	f3 0f 1e fb          	endbr32 
  8012b7:	55                   	push   %ebp
  8012b8:	89 e5                	mov    %esp,%ebp
  8012ba:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8012bd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012c0:	50                   	push   %eax
  8012c1:	ff 75 10             	pushl  0x10(%ebp)
  8012c4:	ff 75 0c             	pushl  0xc(%ebp)
  8012c7:	ff 75 08             	pushl  0x8(%ebp)
  8012ca:	e8 05 00 00 00       	call   8012d4 <vprintfmt>
}
  8012cf:	83 c4 10             	add    $0x10,%esp
  8012d2:	c9                   	leave  
  8012d3:	c3                   	ret    

008012d4 <vprintfmt>:
{
  8012d4:	f3 0f 1e fb          	endbr32 
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	57                   	push   %edi
  8012dc:	56                   	push   %esi
  8012dd:	53                   	push   %ebx
  8012de:	83 ec 3c             	sub    $0x3c,%esp
  8012e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8012e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012e7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012ea:	e9 4a 03 00 00       	jmp    801639 <vprintfmt+0x365>
		padc = ' ';
  8012ef:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012f3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012fa:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801301:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801308:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80130d:	8d 47 01             	lea    0x1(%edi),%eax
  801310:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801313:	0f b6 17             	movzbl (%edi),%edx
  801316:	8d 42 dd             	lea    -0x23(%edx),%eax
  801319:	3c 55                	cmp    $0x55,%al
  80131b:	0f 87 de 03 00 00    	ja     8016ff <vprintfmt+0x42b>
  801321:	0f b6 c0             	movzbl %al,%eax
  801324:	3e ff 24 85 20 22 80 	notrack jmp *0x802220(,%eax,4)
  80132b:	00 
  80132c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80132f:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801333:	eb d8                	jmp    80130d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801335:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801338:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80133c:	eb cf                	jmp    80130d <vprintfmt+0x39>
  80133e:	0f b6 d2             	movzbl %dl,%edx
  801341:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801344:	b8 00 00 00 00       	mov    $0x0,%eax
  801349:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80134c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80134f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801353:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801356:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801359:	83 f9 09             	cmp    $0x9,%ecx
  80135c:	77 55                	ja     8013b3 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80135e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801361:	eb e9                	jmp    80134c <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801363:	8b 45 14             	mov    0x14(%ebp),%eax
  801366:	8b 00                	mov    (%eax),%eax
  801368:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80136b:	8b 45 14             	mov    0x14(%ebp),%eax
  80136e:	8d 40 04             	lea    0x4(%eax),%eax
  801371:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801374:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801377:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80137b:	79 90                	jns    80130d <vprintfmt+0x39>
				width = precision, precision = -1;
  80137d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801380:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801383:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80138a:	eb 81                	jmp    80130d <vprintfmt+0x39>
  80138c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80138f:	85 c0                	test   %eax,%eax
  801391:	ba 00 00 00 00       	mov    $0x0,%edx
  801396:	0f 49 d0             	cmovns %eax,%edx
  801399:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80139c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80139f:	e9 69 ff ff ff       	jmp    80130d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8013a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8013a7:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8013ae:	e9 5a ff ff ff       	jmp    80130d <vprintfmt+0x39>
  8013b3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8013b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8013b9:	eb bc                	jmp    801377 <vprintfmt+0xa3>
			lflag++;
  8013bb:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8013be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8013c1:	e9 47 ff ff ff       	jmp    80130d <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8013c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c9:	8d 78 04             	lea    0x4(%eax),%edi
  8013cc:	83 ec 08             	sub    $0x8,%esp
  8013cf:	53                   	push   %ebx
  8013d0:	ff 30                	pushl  (%eax)
  8013d2:	ff d6                	call   *%esi
			break;
  8013d4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8013d7:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8013da:	e9 57 02 00 00       	jmp    801636 <vprintfmt+0x362>
			err = va_arg(ap, int);
  8013df:	8b 45 14             	mov    0x14(%ebp),%eax
  8013e2:	8d 78 04             	lea    0x4(%eax),%edi
  8013e5:	8b 00                	mov    (%eax),%eax
  8013e7:	99                   	cltd   
  8013e8:	31 d0                	xor    %edx,%eax
  8013ea:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013ec:	83 f8 0f             	cmp    $0xf,%eax
  8013ef:	7f 23                	jg     801414 <vprintfmt+0x140>
  8013f1:	8b 14 85 80 23 80 00 	mov    0x802380(,%eax,4),%edx
  8013f8:	85 d2                	test   %edx,%edx
  8013fa:	74 18                	je     801414 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8013fc:	52                   	push   %edx
  8013fd:	68 86 20 80 00       	push   $0x802086
  801402:	53                   	push   %ebx
  801403:	56                   	push   %esi
  801404:	e8 aa fe ff ff       	call   8012b3 <printfmt>
  801409:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80140c:	89 7d 14             	mov    %edi,0x14(%ebp)
  80140f:	e9 22 02 00 00       	jmp    801636 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  801414:	50                   	push   %eax
  801415:	68 fb 20 80 00       	push   $0x8020fb
  80141a:	53                   	push   %ebx
  80141b:	56                   	push   %esi
  80141c:	e8 92 fe ff ff       	call   8012b3 <printfmt>
  801421:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801424:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801427:	e9 0a 02 00 00       	jmp    801636 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  80142c:	8b 45 14             	mov    0x14(%ebp),%eax
  80142f:	83 c0 04             	add    $0x4,%eax
  801432:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801435:	8b 45 14             	mov    0x14(%ebp),%eax
  801438:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80143a:	85 d2                	test   %edx,%edx
  80143c:	b8 f4 20 80 00       	mov    $0x8020f4,%eax
  801441:	0f 45 c2             	cmovne %edx,%eax
  801444:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801447:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80144b:	7e 06                	jle    801453 <vprintfmt+0x17f>
  80144d:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801451:	75 0d                	jne    801460 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  801453:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801456:	89 c7                	mov    %eax,%edi
  801458:	03 45 e0             	add    -0x20(%ebp),%eax
  80145b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80145e:	eb 55                	jmp    8014b5 <vprintfmt+0x1e1>
  801460:	83 ec 08             	sub    $0x8,%esp
  801463:	ff 75 d8             	pushl  -0x28(%ebp)
  801466:	ff 75 cc             	pushl  -0x34(%ebp)
  801469:	e8 45 03 00 00       	call   8017b3 <strnlen>
  80146e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801471:	29 c2                	sub    %eax,%edx
  801473:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801476:	83 c4 10             	add    $0x10,%esp
  801479:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80147b:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80147f:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801482:	85 ff                	test   %edi,%edi
  801484:	7e 11                	jle    801497 <vprintfmt+0x1c3>
					putch(padc, putdat);
  801486:	83 ec 08             	sub    $0x8,%esp
  801489:	53                   	push   %ebx
  80148a:	ff 75 e0             	pushl  -0x20(%ebp)
  80148d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80148f:	83 ef 01             	sub    $0x1,%edi
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	eb eb                	jmp    801482 <vprintfmt+0x1ae>
  801497:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80149a:	85 d2                	test   %edx,%edx
  80149c:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a1:	0f 49 c2             	cmovns %edx,%eax
  8014a4:	29 c2                	sub    %eax,%edx
  8014a6:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8014a9:	eb a8                	jmp    801453 <vprintfmt+0x17f>
					putch(ch, putdat);
  8014ab:	83 ec 08             	sub    $0x8,%esp
  8014ae:	53                   	push   %ebx
  8014af:	52                   	push   %edx
  8014b0:	ff d6                	call   *%esi
  8014b2:	83 c4 10             	add    $0x10,%esp
  8014b5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014b8:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014ba:	83 c7 01             	add    $0x1,%edi
  8014bd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014c1:	0f be d0             	movsbl %al,%edx
  8014c4:	85 d2                	test   %edx,%edx
  8014c6:	74 4b                	je     801513 <vprintfmt+0x23f>
  8014c8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014cc:	78 06                	js     8014d4 <vprintfmt+0x200>
  8014ce:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014d2:	78 1e                	js     8014f2 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8014d4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014d8:	74 d1                	je     8014ab <vprintfmt+0x1d7>
  8014da:	0f be c0             	movsbl %al,%eax
  8014dd:	83 e8 20             	sub    $0x20,%eax
  8014e0:	83 f8 5e             	cmp    $0x5e,%eax
  8014e3:	76 c6                	jbe    8014ab <vprintfmt+0x1d7>
					putch('?', putdat);
  8014e5:	83 ec 08             	sub    $0x8,%esp
  8014e8:	53                   	push   %ebx
  8014e9:	6a 3f                	push   $0x3f
  8014eb:	ff d6                	call   *%esi
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	eb c3                	jmp    8014b5 <vprintfmt+0x1e1>
  8014f2:	89 cf                	mov    %ecx,%edi
  8014f4:	eb 0e                	jmp    801504 <vprintfmt+0x230>
				putch(' ', putdat);
  8014f6:	83 ec 08             	sub    $0x8,%esp
  8014f9:	53                   	push   %ebx
  8014fa:	6a 20                	push   $0x20
  8014fc:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8014fe:	83 ef 01             	sub    $0x1,%edi
  801501:	83 c4 10             	add    $0x10,%esp
  801504:	85 ff                	test   %edi,%edi
  801506:	7f ee                	jg     8014f6 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  801508:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80150b:	89 45 14             	mov    %eax,0x14(%ebp)
  80150e:	e9 23 01 00 00       	jmp    801636 <vprintfmt+0x362>
  801513:	89 cf                	mov    %ecx,%edi
  801515:	eb ed                	jmp    801504 <vprintfmt+0x230>
	if (lflag >= 2)
  801517:	83 f9 01             	cmp    $0x1,%ecx
  80151a:	7f 1b                	jg     801537 <vprintfmt+0x263>
	else if (lflag)
  80151c:	85 c9                	test   %ecx,%ecx
  80151e:	74 63                	je     801583 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  801520:	8b 45 14             	mov    0x14(%ebp),%eax
  801523:	8b 00                	mov    (%eax),%eax
  801525:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801528:	99                   	cltd   
  801529:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80152c:	8b 45 14             	mov    0x14(%ebp),%eax
  80152f:	8d 40 04             	lea    0x4(%eax),%eax
  801532:	89 45 14             	mov    %eax,0x14(%ebp)
  801535:	eb 17                	jmp    80154e <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  801537:	8b 45 14             	mov    0x14(%ebp),%eax
  80153a:	8b 50 04             	mov    0x4(%eax),%edx
  80153d:	8b 00                	mov    (%eax),%eax
  80153f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801542:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801545:	8b 45 14             	mov    0x14(%ebp),%eax
  801548:	8d 40 08             	lea    0x8(%eax),%eax
  80154b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80154e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801551:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801554:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  801559:	85 c9                	test   %ecx,%ecx
  80155b:	0f 89 bb 00 00 00    	jns    80161c <vprintfmt+0x348>
				putch('-', putdat);
  801561:	83 ec 08             	sub    $0x8,%esp
  801564:	53                   	push   %ebx
  801565:	6a 2d                	push   $0x2d
  801567:	ff d6                	call   *%esi
				num = -(long long) num;
  801569:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80156c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80156f:	f7 da                	neg    %edx
  801571:	83 d1 00             	adc    $0x0,%ecx
  801574:	f7 d9                	neg    %ecx
  801576:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801579:	b8 0a 00 00 00       	mov    $0xa,%eax
  80157e:	e9 99 00 00 00       	jmp    80161c <vprintfmt+0x348>
		return va_arg(*ap, int);
  801583:	8b 45 14             	mov    0x14(%ebp),%eax
  801586:	8b 00                	mov    (%eax),%eax
  801588:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80158b:	99                   	cltd   
  80158c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80158f:	8b 45 14             	mov    0x14(%ebp),%eax
  801592:	8d 40 04             	lea    0x4(%eax),%eax
  801595:	89 45 14             	mov    %eax,0x14(%ebp)
  801598:	eb b4                	jmp    80154e <vprintfmt+0x27a>
	if (lflag >= 2)
  80159a:	83 f9 01             	cmp    $0x1,%ecx
  80159d:	7f 1b                	jg     8015ba <vprintfmt+0x2e6>
	else if (lflag)
  80159f:	85 c9                	test   %ecx,%ecx
  8015a1:	74 2c                	je     8015cf <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  8015a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a6:	8b 10                	mov    (%eax),%edx
  8015a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015ad:	8d 40 04             	lea    0x4(%eax),%eax
  8015b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015b3:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8015b8:	eb 62                	jmp    80161c <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8015ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8015bd:	8b 10                	mov    (%eax),%edx
  8015bf:	8b 48 04             	mov    0x4(%eax),%ecx
  8015c2:	8d 40 08             	lea    0x8(%eax),%eax
  8015c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015c8:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8015cd:	eb 4d                	jmp    80161c <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8015cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d2:	8b 10                	mov    (%eax),%edx
  8015d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015d9:	8d 40 04             	lea    0x4(%eax),%eax
  8015dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015df:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8015e4:	eb 36                	jmp    80161c <vprintfmt+0x348>
	if (lflag >= 2)
  8015e6:	83 f9 01             	cmp    $0x1,%ecx
  8015e9:	7f 17                	jg     801602 <vprintfmt+0x32e>
	else if (lflag)
  8015eb:	85 c9                	test   %ecx,%ecx
  8015ed:	74 6e                	je     80165d <vprintfmt+0x389>
		return va_arg(*ap, long);
  8015ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f2:	8b 10                	mov    (%eax),%edx
  8015f4:	89 d0                	mov    %edx,%eax
  8015f6:	99                   	cltd   
  8015f7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015fa:	8d 49 04             	lea    0x4(%ecx),%ecx
  8015fd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801600:	eb 11                	jmp    801613 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  801602:	8b 45 14             	mov    0x14(%ebp),%eax
  801605:	8b 50 04             	mov    0x4(%eax),%edx
  801608:	8b 00                	mov    (%eax),%eax
  80160a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80160d:	8d 49 08             	lea    0x8(%ecx),%ecx
  801610:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  801613:	89 d1                	mov    %edx,%ecx
  801615:	89 c2                	mov    %eax,%edx
            base = 8;
  801617:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80161c:	83 ec 0c             	sub    $0xc,%esp
  80161f:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801623:	57                   	push   %edi
  801624:	ff 75 e0             	pushl  -0x20(%ebp)
  801627:	50                   	push   %eax
  801628:	51                   	push   %ecx
  801629:	52                   	push   %edx
  80162a:	89 da                	mov    %ebx,%edx
  80162c:	89 f0                	mov    %esi,%eax
  80162e:	e8 b6 fb ff ff       	call   8011e9 <printnum>
			break;
  801633:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  801636:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801639:	83 c7 01             	add    $0x1,%edi
  80163c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801640:	83 f8 25             	cmp    $0x25,%eax
  801643:	0f 84 a6 fc ff ff    	je     8012ef <vprintfmt+0x1b>
			if (ch == '\0')
  801649:	85 c0                	test   %eax,%eax
  80164b:	0f 84 ce 00 00 00    	je     80171f <vprintfmt+0x44b>
			putch(ch, putdat);
  801651:	83 ec 08             	sub    $0x8,%esp
  801654:	53                   	push   %ebx
  801655:	50                   	push   %eax
  801656:	ff d6                	call   *%esi
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	eb dc                	jmp    801639 <vprintfmt+0x365>
		return va_arg(*ap, int);
  80165d:	8b 45 14             	mov    0x14(%ebp),%eax
  801660:	8b 10                	mov    (%eax),%edx
  801662:	89 d0                	mov    %edx,%eax
  801664:	99                   	cltd   
  801665:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801668:	8d 49 04             	lea    0x4(%ecx),%ecx
  80166b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80166e:	eb a3                	jmp    801613 <vprintfmt+0x33f>
			putch('0', putdat);
  801670:	83 ec 08             	sub    $0x8,%esp
  801673:	53                   	push   %ebx
  801674:	6a 30                	push   $0x30
  801676:	ff d6                	call   *%esi
			putch('x', putdat);
  801678:	83 c4 08             	add    $0x8,%esp
  80167b:	53                   	push   %ebx
  80167c:	6a 78                	push   $0x78
  80167e:	ff d6                	call   *%esi
			num = (unsigned long long)
  801680:	8b 45 14             	mov    0x14(%ebp),%eax
  801683:	8b 10                	mov    (%eax),%edx
  801685:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80168a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80168d:	8d 40 04             	lea    0x4(%eax),%eax
  801690:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801693:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801698:	eb 82                	jmp    80161c <vprintfmt+0x348>
	if (lflag >= 2)
  80169a:	83 f9 01             	cmp    $0x1,%ecx
  80169d:	7f 1e                	jg     8016bd <vprintfmt+0x3e9>
	else if (lflag)
  80169f:	85 c9                	test   %ecx,%ecx
  8016a1:	74 32                	je     8016d5 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  8016a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8016a6:	8b 10                	mov    (%eax),%edx
  8016a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016ad:	8d 40 04             	lea    0x4(%eax),%eax
  8016b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016b3:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8016b8:	e9 5f ff ff ff       	jmp    80161c <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8016bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c0:	8b 10                	mov    (%eax),%edx
  8016c2:	8b 48 04             	mov    0x4(%eax),%ecx
  8016c5:	8d 40 08             	lea    0x8(%eax),%eax
  8016c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016cb:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8016d0:	e9 47 ff ff ff       	jmp    80161c <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8016d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8016d8:	8b 10                	mov    (%eax),%edx
  8016da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016df:	8d 40 04             	lea    0x4(%eax),%eax
  8016e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016e5:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8016ea:	e9 2d ff ff ff       	jmp    80161c <vprintfmt+0x348>
			putch(ch, putdat);
  8016ef:	83 ec 08             	sub    $0x8,%esp
  8016f2:	53                   	push   %ebx
  8016f3:	6a 25                	push   $0x25
  8016f5:	ff d6                	call   *%esi
			break;
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	e9 37 ff ff ff       	jmp    801636 <vprintfmt+0x362>
			putch('%', putdat);
  8016ff:	83 ec 08             	sub    $0x8,%esp
  801702:	53                   	push   %ebx
  801703:	6a 25                	push   $0x25
  801705:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801707:	83 c4 10             	add    $0x10,%esp
  80170a:	89 f8                	mov    %edi,%eax
  80170c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801710:	74 05                	je     801717 <vprintfmt+0x443>
  801712:	83 e8 01             	sub    $0x1,%eax
  801715:	eb f5                	jmp    80170c <vprintfmt+0x438>
  801717:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80171a:	e9 17 ff ff ff       	jmp    801636 <vprintfmt+0x362>
}
  80171f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801722:	5b                   	pop    %ebx
  801723:	5e                   	pop    %esi
  801724:	5f                   	pop    %edi
  801725:	5d                   	pop    %ebp
  801726:	c3                   	ret    

00801727 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801727:	f3 0f 1e fb          	endbr32 
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	83 ec 18             	sub    $0x18,%esp
  801731:	8b 45 08             	mov    0x8(%ebp),%eax
  801734:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801737:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80173a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80173e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801741:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801748:	85 c0                	test   %eax,%eax
  80174a:	74 26                	je     801772 <vsnprintf+0x4b>
  80174c:	85 d2                	test   %edx,%edx
  80174e:	7e 22                	jle    801772 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801750:	ff 75 14             	pushl  0x14(%ebp)
  801753:	ff 75 10             	pushl  0x10(%ebp)
  801756:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801759:	50                   	push   %eax
  80175a:	68 92 12 80 00       	push   $0x801292
  80175f:	e8 70 fb ff ff       	call   8012d4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801764:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801767:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80176a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80176d:	83 c4 10             	add    $0x10,%esp
}
  801770:	c9                   	leave  
  801771:	c3                   	ret    
		return -E_INVAL;
  801772:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801777:	eb f7                	jmp    801770 <vsnprintf+0x49>

00801779 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801779:	f3 0f 1e fb          	endbr32 
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801783:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801786:	50                   	push   %eax
  801787:	ff 75 10             	pushl  0x10(%ebp)
  80178a:	ff 75 0c             	pushl  0xc(%ebp)
  80178d:	ff 75 08             	pushl  0x8(%ebp)
  801790:	e8 92 ff ff ff       	call   801727 <vsnprintf>
	va_end(ap);

	return rc;
}
  801795:	c9                   	leave  
  801796:	c3                   	ret    

00801797 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801797:	f3 0f 1e fb          	endbr32 
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8017a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8017a6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8017aa:	74 05                	je     8017b1 <strlen+0x1a>
		n++;
  8017ac:	83 c0 01             	add    $0x1,%eax
  8017af:	eb f5                	jmp    8017a6 <strlen+0xf>
	return n;
}
  8017b1:	5d                   	pop    %ebp
  8017b2:	c3                   	ret    

008017b3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8017b3:	f3 0f 1e fb          	endbr32 
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017bd:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8017c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c5:	39 d0                	cmp    %edx,%eax
  8017c7:	74 0d                	je     8017d6 <strnlen+0x23>
  8017c9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8017cd:	74 05                	je     8017d4 <strnlen+0x21>
		n++;
  8017cf:	83 c0 01             	add    $0x1,%eax
  8017d2:	eb f1                	jmp    8017c5 <strnlen+0x12>
  8017d4:	89 c2                	mov    %eax,%edx
	return n;
}
  8017d6:	89 d0                	mov    %edx,%eax
  8017d8:	5d                   	pop    %ebp
  8017d9:	c3                   	ret    

008017da <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8017da:	f3 0f 1e fb          	endbr32 
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	53                   	push   %ebx
  8017e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8017e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ed:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8017f1:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8017f4:	83 c0 01             	add    $0x1,%eax
  8017f7:	84 d2                	test   %dl,%dl
  8017f9:	75 f2                	jne    8017ed <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8017fb:	89 c8                	mov    %ecx,%eax
  8017fd:	5b                   	pop    %ebx
  8017fe:	5d                   	pop    %ebp
  8017ff:	c3                   	ret    

00801800 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801800:	f3 0f 1e fb          	endbr32 
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	53                   	push   %ebx
  801808:	83 ec 10             	sub    $0x10,%esp
  80180b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80180e:	53                   	push   %ebx
  80180f:	e8 83 ff ff ff       	call   801797 <strlen>
  801814:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801817:	ff 75 0c             	pushl  0xc(%ebp)
  80181a:	01 d8                	add    %ebx,%eax
  80181c:	50                   	push   %eax
  80181d:	e8 b8 ff ff ff       	call   8017da <strcpy>
	return dst;
}
  801822:	89 d8                	mov    %ebx,%eax
  801824:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801827:	c9                   	leave  
  801828:	c3                   	ret    

00801829 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801829:	f3 0f 1e fb          	endbr32 
  80182d:	55                   	push   %ebp
  80182e:	89 e5                	mov    %esp,%ebp
  801830:	56                   	push   %esi
  801831:	53                   	push   %ebx
  801832:	8b 75 08             	mov    0x8(%ebp),%esi
  801835:	8b 55 0c             	mov    0xc(%ebp),%edx
  801838:	89 f3                	mov    %esi,%ebx
  80183a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80183d:	89 f0                	mov    %esi,%eax
  80183f:	39 d8                	cmp    %ebx,%eax
  801841:	74 11                	je     801854 <strncpy+0x2b>
		*dst++ = *src;
  801843:	83 c0 01             	add    $0x1,%eax
  801846:	0f b6 0a             	movzbl (%edx),%ecx
  801849:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80184c:	80 f9 01             	cmp    $0x1,%cl
  80184f:	83 da ff             	sbb    $0xffffffff,%edx
  801852:	eb eb                	jmp    80183f <strncpy+0x16>
	}
	return ret;
}
  801854:	89 f0                	mov    %esi,%eax
  801856:	5b                   	pop    %ebx
  801857:	5e                   	pop    %esi
  801858:	5d                   	pop    %ebp
  801859:	c3                   	ret    

0080185a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80185a:	f3 0f 1e fb          	endbr32 
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	56                   	push   %esi
  801862:	53                   	push   %ebx
  801863:	8b 75 08             	mov    0x8(%ebp),%esi
  801866:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801869:	8b 55 10             	mov    0x10(%ebp),%edx
  80186c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80186e:	85 d2                	test   %edx,%edx
  801870:	74 21                	je     801893 <strlcpy+0x39>
  801872:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801876:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801878:	39 c2                	cmp    %eax,%edx
  80187a:	74 14                	je     801890 <strlcpy+0x36>
  80187c:	0f b6 19             	movzbl (%ecx),%ebx
  80187f:	84 db                	test   %bl,%bl
  801881:	74 0b                	je     80188e <strlcpy+0x34>
			*dst++ = *src++;
  801883:	83 c1 01             	add    $0x1,%ecx
  801886:	83 c2 01             	add    $0x1,%edx
  801889:	88 5a ff             	mov    %bl,-0x1(%edx)
  80188c:	eb ea                	jmp    801878 <strlcpy+0x1e>
  80188e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801890:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801893:	29 f0                	sub    %esi,%eax
}
  801895:	5b                   	pop    %ebx
  801896:	5e                   	pop    %esi
  801897:	5d                   	pop    %ebp
  801898:	c3                   	ret    

00801899 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801899:	f3 0f 1e fb          	endbr32 
  80189d:	55                   	push   %ebp
  80189e:	89 e5                	mov    %esp,%ebp
  8018a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8018a6:	0f b6 01             	movzbl (%ecx),%eax
  8018a9:	84 c0                	test   %al,%al
  8018ab:	74 0c                	je     8018b9 <strcmp+0x20>
  8018ad:	3a 02                	cmp    (%edx),%al
  8018af:	75 08                	jne    8018b9 <strcmp+0x20>
		p++, q++;
  8018b1:	83 c1 01             	add    $0x1,%ecx
  8018b4:	83 c2 01             	add    $0x1,%edx
  8018b7:	eb ed                	jmp    8018a6 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8018b9:	0f b6 c0             	movzbl %al,%eax
  8018bc:	0f b6 12             	movzbl (%edx),%edx
  8018bf:	29 d0                	sub    %edx,%eax
}
  8018c1:	5d                   	pop    %ebp
  8018c2:	c3                   	ret    

008018c3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8018c3:	f3 0f 1e fb          	endbr32 
  8018c7:	55                   	push   %ebp
  8018c8:	89 e5                	mov    %esp,%ebp
  8018ca:	53                   	push   %ebx
  8018cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d1:	89 c3                	mov    %eax,%ebx
  8018d3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8018d6:	eb 06                	jmp    8018de <strncmp+0x1b>
		n--, p++, q++;
  8018d8:	83 c0 01             	add    $0x1,%eax
  8018db:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8018de:	39 d8                	cmp    %ebx,%eax
  8018e0:	74 16                	je     8018f8 <strncmp+0x35>
  8018e2:	0f b6 08             	movzbl (%eax),%ecx
  8018e5:	84 c9                	test   %cl,%cl
  8018e7:	74 04                	je     8018ed <strncmp+0x2a>
  8018e9:	3a 0a                	cmp    (%edx),%cl
  8018eb:	74 eb                	je     8018d8 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8018ed:	0f b6 00             	movzbl (%eax),%eax
  8018f0:	0f b6 12             	movzbl (%edx),%edx
  8018f3:	29 d0                	sub    %edx,%eax
}
  8018f5:	5b                   	pop    %ebx
  8018f6:	5d                   	pop    %ebp
  8018f7:	c3                   	ret    
		return 0;
  8018f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018fd:	eb f6                	jmp    8018f5 <strncmp+0x32>

008018ff <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8018ff:	f3 0f 1e fb          	endbr32 
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	8b 45 08             	mov    0x8(%ebp),%eax
  801909:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80190d:	0f b6 10             	movzbl (%eax),%edx
  801910:	84 d2                	test   %dl,%dl
  801912:	74 09                	je     80191d <strchr+0x1e>
		if (*s == c)
  801914:	38 ca                	cmp    %cl,%dl
  801916:	74 0a                	je     801922 <strchr+0x23>
	for (; *s; s++)
  801918:	83 c0 01             	add    $0x1,%eax
  80191b:	eb f0                	jmp    80190d <strchr+0xe>
			return (char *) s;
	return 0;
  80191d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801922:	5d                   	pop    %ebp
  801923:	c3                   	ret    

00801924 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801924:	f3 0f 1e fb          	endbr32 
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	8b 45 08             	mov    0x8(%ebp),%eax
  80192e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801932:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801935:	38 ca                	cmp    %cl,%dl
  801937:	74 09                	je     801942 <strfind+0x1e>
  801939:	84 d2                	test   %dl,%dl
  80193b:	74 05                	je     801942 <strfind+0x1e>
	for (; *s; s++)
  80193d:	83 c0 01             	add    $0x1,%eax
  801940:	eb f0                	jmp    801932 <strfind+0xe>
			break;
	return (char *) s;
}
  801942:	5d                   	pop    %ebp
  801943:	c3                   	ret    

00801944 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801944:	f3 0f 1e fb          	endbr32 
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	57                   	push   %edi
  80194c:	56                   	push   %esi
  80194d:	53                   	push   %ebx
  80194e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801951:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801954:	85 c9                	test   %ecx,%ecx
  801956:	74 31                	je     801989 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801958:	89 f8                	mov    %edi,%eax
  80195a:	09 c8                	or     %ecx,%eax
  80195c:	a8 03                	test   $0x3,%al
  80195e:	75 23                	jne    801983 <memset+0x3f>
		c &= 0xFF;
  801960:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801964:	89 d3                	mov    %edx,%ebx
  801966:	c1 e3 08             	shl    $0x8,%ebx
  801969:	89 d0                	mov    %edx,%eax
  80196b:	c1 e0 18             	shl    $0x18,%eax
  80196e:	89 d6                	mov    %edx,%esi
  801970:	c1 e6 10             	shl    $0x10,%esi
  801973:	09 f0                	or     %esi,%eax
  801975:	09 c2                	or     %eax,%edx
  801977:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801979:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80197c:	89 d0                	mov    %edx,%eax
  80197e:	fc                   	cld    
  80197f:	f3 ab                	rep stos %eax,%es:(%edi)
  801981:	eb 06                	jmp    801989 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801983:	8b 45 0c             	mov    0xc(%ebp),%eax
  801986:	fc                   	cld    
  801987:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801989:	89 f8                	mov    %edi,%eax
  80198b:	5b                   	pop    %ebx
  80198c:	5e                   	pop    %esi
  80198d:	5f                   	pop    %edi
  80198e:	5d                   	pop    %ebp
  80198f:	c3                   	ret    

00801990 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801990:	f3 0f 1e fb          	endbr32 
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	57                   	push   %edi
  801998:	56                   	push   %esi
  801999:	8b 45 08             	mov    0x8(%ebp),%eax
  80199c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80199f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8019a2:	39 c6                	cmp    %eax,%esi
  8019a4:	73 32                	jae    8019d8 <memmove+0x48>
  8019a6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8019a9:	39 c2                	cmp    %eax,%edx
  8019ab:	76 2b                	jbe    8019d8 <memmove+0x48>
		s += n;
		d += n;
  8019ad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019b0:	89 fe                	mov    %edi,%esi
  8019b2:	09 ce                	or     %ecx,%esi
  8019b4:	09 d6                	or     %edx,%esi
  8019b6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8019bc:	75 0e                	jne    8019cc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8019be:	83 ef 04             	sub    $0x4,%edi
  8019c1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8019c4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8019c7:	fd                   	std    
  8019c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019ca:	eb 09                	jmp    8019d5 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8019cc:	83 ef 01             	sub    $0x1,%edi
  8019cf:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8019d2:	fd                   	std    
  8019d3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8019d5:	fc                   	cld    
  8019d6:	eb 1a                	jmp    8019f2 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019d8:	89 c2                	mov    %eax,%edx
  8019da:	09 ca                	or     %ecx,%edx
  8019dc:	09 f2                	or     %esi,%edx
  8019de:	f6 c2 03             	test   $0x3,%dl
  8019e1:	75 0a                	jne    8019ed <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8019e3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8019e6:	89 c7                	mov    %eax,%edi
  8019e8:	fc                   	cld    
  8019e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019eb:	eb 05                	jmp    8019f2 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8019ed:	89 c7                	mov    %eax,%edi
  8019ef:	fc                   	cld    
  8019f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8019f2:	5e                   	pop    %esi
  8019f3:	5f                   	pop    %edi
  8019f4:	5d                   	pop    %ebp
  8019f5:	c3                   	ret    

008019f6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8019f6:	f3 0f 1e fb          	endbr32 
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801a00:	ff 75 10             	pushl  0x10(%ebp)
  801a03:	ff 75 0c             	pushl  0xc(%ebp)
  801a06:	ff 75 08             	pushl  0x8(%ebp)
  801a09:	e8 82 ff ff ff       	call   801990 <memmove>
}
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801a10:	f3 0f 1e fb          	endbr32 
  801a14:	55                   	push   %ebp
  801a15:	89 e5                	mov    %esp,%ebp
  801a17:	56                   	push   %esi
  801a18:	53                   	push   %ebx
  801a19:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a1f:	89 c6                	mov    %eax,%esi
  801a21:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a24:	39 f0                	cmp    %esi,%eax
  801a26:	74 1c                	je     801a44 <memcmp+0x34>
		if (*s1 != *s2)
  801a28:	0f b6 08             	movzbl (%eax),%ecx
  801a2b:	0f b6 1a             	movzbl (%edx),%ebx
  801a2e:	38 d9                	cmp    %bl,%cl
  801a30:	75 08                	jne    801a3a <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801a32:	83 c0 01             	add    $0x1,%eax
  801a35:	83 c2 01             	add    $0x1,%edx
  801a38:	eb ea                	jmp    801a24 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801a3a:	0f b6 c1             	movzbl %cl,%eax
  801a3d:	0f b6 db             	movzbl %bl,%ebx
  801a40:	29 d8                	sub    %ebx,%eax
  801a42:	eb 05                	jmp    801a49 <memcmp+0x39>
	}

	return 0;
  801a44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a49:	5b                   	pop    %ebx
  801a4a:	5e                   	pop    %esi
  801a4b:	5d                   	pop    %ebp
  801a4c:	c3                   	ret    

00801a4d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a4d:	f3 0f 1e fb          	endbr32 
  801a51:	55                   	push   %ebp
  801a52:	89 e5                	mov    %esp,%ebp
  801a54:	8b 45 08             	mov    0x8(%ebp),%eax
  801a57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a5a:	89 c2                	mov    %eax,%edx
  801a5c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a5f:	39 d0                	cmp    %edx,%eax
  801a61:	73 09                	jae    801a6c <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a63:	38 08                	cmp    %cl,(%eax)
  801a65:	74 05                	je     801a6c <memfind+0x1f>
	for (; s < ends; s++)
  801a67:	83 c0 01             	add    $0x1,%eax
  801a6a:	eb f3                	jmp    801a5f <memfind+0x12>
			break;
	return (void *) s;
}
  801a6c:	5d                   	pop    %ebp
  801a6d:	c3                   	ret    

00801a6e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a6e:	f3 0f 1e fb          	endbr32 
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	57                   	push   %edi
  801a76:	56                   	push   %esi
  801a77:	53                   	push   %ebx
  801a78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a7e:	eb 03                	jmp    801a83 <strtol+0x15>
		s++;
  801a80:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801a83:	0f b6 01             	movzbl (%ecx),%eax
  801a86:	3c 20                	cmp    $0x20,%al
  801a88:	74 f6                	je     801a80 <strtol+0x12>
  801a8a:	3c 09                	cmp    $0x9,%al
  801a8c:	74 f2                	je     801a80 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801a8e:	3c 2b                	cmp    $0x2b,%al
  801a90:	74 2a                	je     801abc <strtol+0x4e>
	int neg = 0;
  801a92:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801a97:	3c 2d                	cmp    $0x2d,%al
  801a99:	74 2b                	je     801ac6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a9b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801aa1:	75 0f                	jne    801ab2 <strtol+0x44>
  801aa3:	80 39 30             	cmpb   $0x30,(%ecx)
  801aa6:	74 28                	je     801ad0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801aa8:	85 db                	test   %ebx,%ebx
  801aaa:	b8 0a 00 00 00       	mov    $0xa,%eax
  801aaf:	0f 44 d8             	cmove  %eax,%ebx
  801ab2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801aba:	eb 46                	jmp    801b02 <strtol+0x94>
		s++;
  801abc:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801abf:	bf 00 00 00 00       	mov    $0x0,%edi
  801ac4:	eb d5                	jmp    801a9b <strtol+0x2d>
		s++, neg = 1;
  801ac6:	83 c1 01             	add    $0x1,%ecx
  801ac9:	bf 01 00 00 00       	mov    $0x1,%edi
  801ace:	eb cb                	jmp    801a9b <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ad0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ad4:	74 0e                	je     801ae4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801ad6:	85 db                	test   %ebx,%ebx
  801ad8:	75 d8                	jne    801ab2 <strtol+0x44>
		s++, base = 8;
  801ada:	83 c1 01             	add    $0x1,%ecx
  801add:	bb 08 00 00 00       	mov    $0x8,%ebx
  801ae2:	eb ce                	jmp    801ab2 <strtol+0x44>
		s += 2, base = 16;
  801ae4:	83 c1 02             	add    $0x2,%ecx
  801ae7:	bb 10 00 00 00       	mov    $0x10,%ebx
  801aec:	eb c4                	jmp    801ab2 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801aee:	0f be d2             	movsbl %dl,%edx
  801af1:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801af4:	3b 55 10             	cmp    0x10(%ebp),%edx
  801af7:	7d 3a                	jge    801b33 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801af9:	83 c1 01             	add    $0x1,%ecx
  801afc:	0f af 45 10          	imul   0x10(%ebp),%eax
  801b00:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801b02:	0f b6 11             	movzbl (%ecx),%edx
  801b05:	8d 72 d0             	lea    -0x30(%edx),%esi
  801b08:	89 f3                	mov    %esi,%ebx
  801b0a:	80 fb 09             	cmp    $0x9,%bl
  801b0d:	76 df                	jbe    801aee <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801b0f:	8d 72 9f             	lea    -0x61(%edx),%esi
  801b12:	89 f3                	mov    %esi,%ebx
  801b14:	80 fb 19             	cmp    $0x19,%bl
  801b17:	77 08                	ja     801b21 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801b19:	0f be d2             	movsbl %dl,%edx
  801b1c:	83 ea 57             	sub    $0x57,%edx
  801b1f:	eb d3                	jmp    801af4 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801b21:	8d 72 bf             	lea    -0x41(%edx),%esi
  801b24:	89 f3                	mov    %esi,%ebx
  801b26:	80 fb 19             	cmp    $0x19,%bl
  801b29:	77 08                	ja     801b33 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801b2b:	0f be d2             	movsbl %dl,%edx
  801b2e:	83 ea 37             	sub    $0x37,%edx
  801b31:	eb c1                	jmp    801af4 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801b33:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b37:	74 05                	je     801b3e <strtol+0xd0>
		*endptr = (char *) s;
  801b39:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b3c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801b3e:	89 c2                	mov    %eax,%edx
  801b40:	f7 da                	neg    %edx
  801b42:	85 ff                	test   %edi,%edi
  801b44:	0f 45 c2             	cmovne %edx,%eax
}
  801b47:	5b                   	pop    %ebx
  801b48:	5e                   	pop    %esi
  801b49:	5f                   	pop    %edi
  801b4a:	5d                   	pop    %ebp
  801b4b:	c3                   	ret    

00801b4c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801b4c:	f3 0f 1e fb          	endbr32 
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801b56:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801b5d:	74 0a                	je     801b69 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b62:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801b67:	c9                   	leave  
  801b68:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801b69:	83 ec 0c             	sub    $0xc,%esp
  801b6c:	68 df 23 80 00       	push   $0x8023df
  801b71:	e8 5b f6 ff ff       	call   8011d1 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  801b76:	83 c4 0c             	add    $0xc,%esp
  801b79:	6a 07                	push   $0x7
  801b7b:	68 00 f0 bf ee       	push   $0xeebff000
  801b80:	6a 00                	push   $0x0
  801b82:	e8 13 e6 ff ff       	call   80019a <sys_page_alloc>
  801b87:	83 c4 10             	add    $0x10,%esp
  801b8a:	85 c0                	test   %eax,%eax
  801b8c:	78 2a                	js     801bb8 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801b8e:	83 ec 08             	sub    $0x8,%esp
  801b91:	68 ab 03 80 00       	push   $0x8003ab
  801b96:	6a 00                	push   $0x0
  801b98:	e8 5c e7 ff ff       	call   8002f9 <sys_env_set_pgfault_upcall>
  801b9d:	83 c4 10             	add    $0x10,%esp
  801ba0:	85 c0                	test   %eax,%eax
  801ba2:	79 bb                	jns    801b5f <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  801ba4:	83 ec 04             	sub    $0x4,%esp
  801ba7:	68 1c 24 80 00       	push   $0x80241c
  801bac:	6a 25                	push   $0x25
  801bae:	68 0c 24 80 00       	push   $0x80240c
  801bb3:	e8 32 f5 ff ff       	call   8010ea <_panic>
            panic("Allocation of UXSTACK failed!");
  801bb8:	83 ec 04             	sub    $0x4,%esp
  801bbb:	68 ee 23 80 00       	push   $0x8023ee
  801bc0:	6a 22                	push   $0x22
  801bc2:	68 0c 24 80 00       	push   $0x80240c
  801bc7:	e8 1e f5 ff ff       	call   8010ea <_panic>

00801bcc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bcc:	f3 0f 1e fb          	endbr32 
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	56                   	push   %esi
  801bd4:	53                   	push   %ebx
  801bd5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801bd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bdb:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801bde:	85 c0                	test   %eax,%eax
  801be0:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801be5:	0f 44 c2             	cmove  %edx,%eax
  801be8:	83 ec 0c             	sub    $0xc,%esp
  801beb:	50                   	push   %eax
  801bec:	e8 75 e7 ff ff       	call   800366 <sys_ipc_recv>
  801bf1:	83 c4 10             	add    $0x10,%esp
  801bf4:	85 c0                	test   %eax,%eax
  801bf6:	78 24                	js     801c1c <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801bf8:	85 f6                	test   %esi,%esi
  801bfa:	74 0a                	je     801c06 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801bfc:	a1 04 40 80 00       	mov    0x804004,%eax
  801c01:	8b 40 78             	mov    0x78(%eax),%eax
  801c04:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801c06:	85 db                	test   %ebx,%ebx
  801c08:	74 0a                	je     801c14 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801c0a:	a1 04 40 80 00       	mov    0x804004,%eax
  801c0f:	8b 40 74             	mov    0x74(%eax),%eax
  801c12:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801c14:	a1 04 40 80 00       	mov    0x804004,%eax
  801c19:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c1c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c1f:	5b                   	pop    %ebx
  801c20:	5e                   	pop    %esi
  801c21:	5d                   	pop    %ebp
  801c22:	c3                   	ret    

00801c23 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c23:	f3 0f 1e fb          	endbr32 
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	57                   	push   %edi
  801c2b:	56                   	push   %esi
  801c2c:	53                   	push   %ebx
  801c2d:	83 ec 1c             	sub    $0x1c,%esp
  801c30:	8b 45 10             	mov    0x10(%ebp),%eax
  801c33:	85 c0                	test   %eax,%eax
  801c35:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801c3a:	0f 45 d0             	cmovne %eax,%edx
  801c3d:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801c3f:	be 01 00 00 00       	mov    $0x1,%esi
  801c44:	eb 1f                	jmp    801c65 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801c46:	e8 2c e5 ff ff       	call   800177 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801c4b:	83 c3 01             	add    $0x1,%ebx
  801c4e:	39 de                	cmp    %ebx,%esi
  801c50:	7f f4                	jg     801c46 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801c52:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801c54:	83 fe 11             	cmp    $0x11,%esi
  801c57:	b8 01 00 00 00       	mov    $0x1,%eax
  801c5c:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801c5f:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801c63:	75 1c                	jne    801c81 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801c65:	ff 75 14             	pushl  0x14(%ebp)
  801c68:	57                   	push   %edi
  801c69:	ff 75 0c             	pushl  0xc(%ebp)
  801c6c:	ff 75 08             	pushl  0x8(%ebp)
  801c6f:	e8 cb e6 ff ff       	call   80033f <sys_ipc_try_send>
  801c74:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801c77:	83 c4 10             	add    $0x10,%esp
  801c7a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c7f:	eb cd                	jmp    801c4e <ipc_send+0x2b>
}
  801c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c84:	5b                   	pop    %ebx
  801c85:	5e                   	pop    %esi
  801c86:	5f                   	pop    %edi
  801c87:	5d                   	pop    %ebp
  801c88:	c3                   	ret    

00801c89 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c89:	f3 0f 1e fb          	endbr32 
  801c8d:	55                   	push   %ebp
  801c8e:	89 e5                	mov    %esp,%ebp
  801c90:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c93:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c98:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c9b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ca1:	8b 52 50             	mov    0x50(%edx),%edx
  801ca4:	39 ca                	cmp    %ecx,%edx
  801ca6:	74 11                	je     801cb9 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801ca8:	83 c0 01             	add    $0x1,%eax
  801cab:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cb0:	75 e6                	jne    801c98 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801cb2:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb7:	eb 0b                	jmp    801cc4 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801cb9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801cbc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801cc1:	8b 40 48             	mov    0x48(%eax),%eax
}
  801cc4:	5d                   	pop    %ebp
  801cc5:	c3                   	ret    

00801cc6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cc6:	f3 0f 1e fb          	endbr32 
  801cca:	55                   	push   %ebp
  801ccb:	89 e5                	mov    %esp,%ebp
  801ccd:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cd0:	89 c2                	mov    %eax,%edx
  801cd2:	c1 ea 16             	shr    $0x16,%edx
  801cd5:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801cdc:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801ce1:	f6 c1 01             	test   $0x1,%cl
  801ce4:	74 1c                	je     801d02 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801ce6:	c1 e8 0c             	shr    $0xc,%eax
  801ce9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801cf0:	a8 01                	test   $0x1,%al
  801cf2:	74 0e                	je     801d02 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801cf4:	c1 e8 0c             	shr    $0xc,%eax
  801cf7:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801cfe:	ef 
  801cff:	0f b7 d2             	movzwl %dx,%edx
}
  801d02:	89 d0                	mov    %edx,%eax
  801d04:	5d                   	pop    %ebp
  801d05:	c3                   	ret    
  801d06:	66 90                	xchg   %ax,%ax
  801d08:	66 90                	xchg   %ax,%ax
  801d0a:	66 90                	xchg   %ax,%ax
  801d0c:	66 90                	xchg   %ax,%ax
  801d0e:	66 90                	xchg   %ax,%ax

00801d10 <__udivdi3>:
  801d10:	f3 0f 1e fb          	endbr32 
  801d14:	55                   	push   %ebp
  801d15:	57                   	push   %edi
  801d16:	56                   	push   %esi
  801d17:	53                   	push   %ebx
  801d18:	83 ec 1c             	sub    $0x1c,%esp
  801d1b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d1f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801d23:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d27:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801d2b:	85 d2                	test   %edx,%edx
  801d2d:	75 19                	jne    801d48 <__udivdi3+0x38>
  801d2f:	39 f3                	cmp    %esi,%ebx
  801d31:	76 4d                	jbe    801d80 <__udivdi3+0x70>
  801d33:	31 ff                	xor    %edi,%edi
  801d35:	89 e8                	mov    %ebp,%eax
  801d37:	89 f2                	mov    %esi,%edx
  801d39:	f7 f3                	div    %ebx
  801d3b:	89 fa                	mov    %edi,%edx
  801d3d:	83 c4 1c             	add    $0x1c,%esp
  801d40:	5b                   	pop    %ebx
  801d41:	5e                   	pop    %esi
  801d42:	5f                   	pop    %edi
  801d43:	5d                   	pop    %ebp
  801d44:	c3                   	ret    
  801d45:	8d 76 00             	lea    0x0(%esi),%esi
  801d48:	39 f2                	cmp    %esi,%edx
  801d4a:	76 14                	jbe    801d60 <__udivdi3+0x50>
  801d4c:	31 ff                	xor    %edi,%edi
  801d4e:	31 c0                	xor    %eax,%eax
  801d50:	89 fa                	mov    %edi,%edx
  801d52:	83 c4 1c             	add    $0x1c,%esp
  801d55:	5b                   	pop    %ebx
  801d56:	5e                   	pop    %esi
  801d57:	5f                   	pop    %edi
  801d58:	5d                   	pop    %ebp
  801d59:	c3                   	ret    
  801d5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d60:	0f bd fa             	bsr    %edx,%edi
  801d63:	83 f7 1f             	xor    $0x1f,%edi
  801d66:	75 48                	jne    801db0 <__udivdi3+0xa0>
  801d68:	39 f2                	cmp    %esi,%edx
  801d6a:	72 06                	jb     801d72 <__udivdi3+0x62>
  801d6c:	31 c0                	xor    %eax,%eax
  801d6e:	39 eb                	cmp    %ebp,%ebx
  801d70:	77 de                	ja     801d50 <__udivdi3+0x40>
  801d72:	b8 01 00 00 00       	mov    $0x1,%eax
  801d77:	eb d7                	jmp    801d50 <__udivdi3+0x40>
  801d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d80:	89 d9                	mov    %ebx,%ecx
  801d82:	85 db                	test   %ebx,%ebx
  801d84:	75 0b                	jne    801d91 <__udivdi3+0x81>
  801d86:	b8 01 00 00 00       	mov    $0x1,%eax
  801d8b:	31 d2                	xor    %edx,%edx
  801d8d:	f7 f3                	div    %ebx
  801d8f:	89 c1                	mov    %eax,%ecx
  801d91:	31 d2                	xor    %edx,%edx
  801d93:	89 f0                	mov    %esi,%eax
  801d95:	f7 f1                	div    %ecx
  801d97:	89 c6                	mov    %eax,%esi
  801d99:	89 e8                	mov    %ebp,%eax
  801d9b:	89 f7                	mov    %esi,%edi
  801d9d:	f7 f1                	div    %ecx
  801d9f:	89 fa                	mov    %edi,%edx
  801da1:	83 c4 1c             	add    $0x1c,%esp
  801da4:	5b                   	pop    %ebx
  801da5:	5e                   	pop    %esi
  801da6:	5f                   	pop    %edi
  801da7:	5d                   	pop    %ebp
  801da8:	c3                   	ret    
  801da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801db0:	89 f9                	mov    %edi,%ecx
  801db2:	b8 20 00 00 00       	mov    $0x20,%eax
  801db7:	29 f8                	sub    %edi,%eax
  801db9:	d3 e2                	shl    %cl,%edx
  801dbb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dbf:	89 c1                	mov    %eax,%ecx
  801dc1:	89 da                	mov    %ebx,%edx
  801dc3:	d3 ea                	shr    %cl,%edx
  801dc5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801dc9:	09 d1                	or     %edx,%ecx
  801dcb:	89 f2                	mov    %esi,%edx
  801dcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dd1:	89 f9                	mov    %edi,%ecx
  801dd3:	d3 e3                	shl    %cl,%ebx
  801dd5:	89 c1                	mov    %eax,%ecx
  801dd7:	d3 ea                	shr    %cl,%edx
  801dd9:	89 f9                	mov    %edi,%ecx
  801ddb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801ddf:	89 eb                	mov    %ebp,%ebx
  801de1:	d3 e6                	shl    %cl,%esi
  801de3:	89 c1                	mov    %eax,%ecx
  801de5:	d3 eb                	shr    %cl,%ebx
  801de7:	09 de                	or     %ebx,%esi
  801de9:	89 f0                	mov    %esi,%eax
  801deb:	f7 74 24 08          	divl   0x8(%esp)
  801def:	89 d6                	mov    %edx,%esi
  801df1:	89 c3                	mov    %eax,%ebx
  801df3:	f7 64 24 0c          	mull   0xc(%esp)
  801df7:	39 d6                	cmp    %edx,%esi
  801df9:	72 15                	jb     801e10 <__udivdi3+0x100>
  801dfb:	89 f9                	mov    %edi,%ecx
  801dfd:	d3 e5                	shl    %cl,%ebp
  801dff:	39 c5                	cmp    %eax,%ebp
  801e01:	73 04                	jae    801e07 <__udivdi3+0xf7>
  801e03:	39 d6                	cmp    %edx,%esi
  801e05:	74 09                	je     801e10 <__udivdi3+0x100>
  801e07:	89 d8                	mov    %ebx,%eax
  801e09:	31 ff                	xor    %edi,%edi
  801e0b:	e9 40 ff ff ff       	jmp    801d50 <__udivdi3+0x40>
  801e10:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801e13:	31 ff                	xor    %edi,%edi
  801e15:	e9 36 ff ff ff       	jmp    801d50 <__udivdi3+0x40>
  801e1a:	66 90                	xchg   %ax,%ax
  801e1c:	66 90                	xchg   %ax,%ax
  801e1e:	66 90                	xchg   %ax,%ax

00801e20 <__umoddi3>:
  801e20:	f3 0f 1e fb          	endbr32 
  801e24:	55                   	push   %ebp
  801e25:	57                   	push   %edi
  801e26:	56                   	push   %esi
  801e27:	53                   	push   %ebx
  801e28:	83 ec 1c             	sub    $0x1c,%esp
  801e2b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801e2f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801e33:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801e37:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e3b:	85 c0                	test   %eax,%eax
  801e3d:	75 19                	jne    801e58 <__umoddi3+0x38>
  801e3f:	39 df                	cmp    %ebx,%edi
  801e41:	76 5d                	jbe    801ea0 <__umoddi3+0x80>
  801e43:	89 f0                	mov    %esi,%eax
  801e45:	89 da                	mov    %ebx,%edx
  801e47:	f7 f7                	div    %edi
  801e49:	89 d0                	mov    %edx,%eax
  801e4b:	31 d2                	xor    %edx,%edx
  801e4d:	83 c4 1c             	add    $0x1c,%esp
  801e50:	5b                   	pop    %ebx
  801e51:	5e                   	pop    %esi
  801e52:	5f                   	pop    %edi
  801e53:	5d                   	pop    %ebp
  801e54:	c3                   	ret    
  801e55:	8d 76 00             	lea    0x0(%esi),%esi
  801e58:	89 f2                	mov    %esi,%edx
  801e5a:	39 d8                	cmp    %ebx,%eax
  801e5c:	76 12                	jbe    801e70 <__umoddi3+0x50>
  801e5e:	89 f0                	mov    %esi,%eax
  801e60:	89 da                	mov    %ebx,%edx
  801e62:	83 c4 1c             	add    $0x1c,%esp
  801e65:	5b                   	pop    %ebx
  801e66:	5e                   	pop    %esi
  801e67:	5f                   	pop    %edi
  801e68:	5d                   	pop    %ebp
  801e69:	c3                   	ret    
  801e6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e70:	0f bd e8             	bsr    %eax,%ebp
  801e73:	83 f5 1f             	xor    $0x1f,%ebp
  801e76:	75 50                	jne    801ec8 <__umoddi3+0xa8>
  801e78:	39 d8                	cmp    %ebx,%eax
  801e7a:	0f 82 e0 00 00 00    	jb     801f60 <__umoddi3+0x140>
  801e80:	89 d9                	mov    %ebx,%ecx
  801e82:	39 f7                	cmp    %esi,%edi
  801e84:	0f 86 d6 00 00 00    	jbe    801f60 <__umoddi3+0x140>
  801e8a:	89 d0                	mov    %edx,%eax
  801e8c:	89 ca                	mov    %ecx,%edx
  801e8e:	83 c4 1c             	add    $0x1c,%esp
  801e91:	5b                   	pop    %ebx
  801e92:	5e                   	pop    %esi
  801e93:	5f                   	pop    %edi
  801e94:	5d                   	pop    %ebp
  801e95:	c3                   	ret    
  801e96:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e9d:	8d 76 00             	lea    0x0(%esi),%esi
  801ea0:	89 fd                	mov    %edi,%ebp
  801ea2:	85 ff                	test   %edi,%edi
  801ea4:	75 0b                	jne    801eb1 <__umoddi3+0x91>
  801ea6:	b8 01 00 00 00       	mov    $0x1,%eax
  801eab:	31 d2                	xor    %edx,%edx
  801ead:	f7 f7                	div    %edi
  801eaf:	89 c5                	mov    %eax,%ebp
  801eb1:	89 d8                	mov    %ebx,%eax
  801eb3:	31 d2                	xor    %edx,%edx
  801eb5:	f7 f5                	div    %ebp
  801eb7:	89 f0                	mov    %esi,%eax
  801eb9:	f7 f5                	div    %ebp
  801ebb:	89 d0                	mov    %edx,%eax
  801ebd:	31 d2                	xor    %edx,%edx
  801ebf:	eb 8c                	jmp    801e4d <__umoddi3+0x2d>
  801ec1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ec8:	89 e9                	mov    %ebp,%ecx
  801eca:	ba 20 00 00 00       	mov    $0x20,%edx
  801ecf:	29 ea                	sub    %ebp,%edx
  801ed1:	d3 e0                	shl    %cl,%eax
  801ed3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ed7:	89 d1                	mov    %edx,%ecx
  801ed9:	89 f8                	mov    %edi,%eax
  801edb:	d3 e8                	shr    %cl,%eax
  801edd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801ee1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ee5:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ee9:	09 c1                	or     %eax,%ecx
  801eeb:	89 d8                	mov    %ebx,%eax
  801eed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ef1:	89 e9                	mov    %ebp,%ecx
  801ef3:	d3 e7                	shl    %cl,%edi
  801ef5:	89 d1                	mov    %edx,%ecx
  801ef7:	d3 e8                	shr    %cl,%eax
  801ef9:	89 e9                	mov    %ebp,%ecx
  801efb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801eff:	d3 e3                	shl    %cl,%ebx
  801f01:	89 c7                	mov    %eax,%edi
  801f03:	89 d1                	mov    %edx,%ecx
  801f05:	89 f0                	mov    %esi,%eax
  801f07:	d3 e8                	shr    %cl,%eax
  801f09:	89 e9                	mov    %ebp,%ecx
  801f0b:	89 fa                	mov    %edi,%edx
  801f0d:	d3 e6                	shl    %cl,%esi
  801f0f:	09 d8                	or     %ebx,%eax
  801f11:	f7 74 24 08          	divl   0x8(%esp)
  801f15:	89 d1                	mov    %edx,%ecx
  801f17:	89 f3                	mov    %esi,%ebx
  801f19:	f7 64 24 0c          	mull   0xc(%esp)
  801f1d:	89 c6                	mov    %eax,%esi
  801f1f:	89 d7                	mov    %edx,%edi
  801f21:	39 d1                	cmp    %edx,%ecx
  801f23:	72 06                	jb     801f2b <__umoddi3+0x10b>
  801f25:	75 10                	jne    801f37 <__umoddi3+0x117>
  801f27:	39 c3                	cmp    %eax,%ebx
  801f29:	73 0c                	jae    801f37 <__umoddi3+0x117>
  801f2b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801f2f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801f33:	89 d7                	mov    %edx,%edi
  801f35:	89 c6                	mov    %eax,%esi
  801f37:	89 ca                	mov    %ecx,%edx
  801f39:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801f3e:	29 f3                	sub    %esi,%ebx
  801f40:	19 fa                	sbb    %edi,%edx
  801f42:	89 d0                	mov    %edx,%eax
  801f44:	d3 e0                	shl    %cl,%eax
  801f46:	89 e9                	mov    %ebp,%ecx
  801f48:	d3 eb                	shr    %cl,%ebx
  801f4a:	d3 ea                	shr    %cl,%edx
  801f4c:	09 d8                	or     %ebx,%eax
  801f4e:	83 c4 1c             	add    $0x1c,%esp
  801f51:	5b                   	pop    %ebx
  801f52:	5e                   	pop    %esi
  801f53:	5f                   	pop    %edi
  801f54:	5d                   	pop    %ebp
  801f55:	c3                   	ret    
  801f56:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f5d:	8d 76 00             	lea    0x0(%esi),%esi
  801f60:	29 fe                	sub    %edi,%esi
  801f62:	19 c3                	sbb    %eax,%ebx
  801f64:	89 f2                	mov    %esi,%edx
  801f66:	89 d9                	mov    %ebx,%ecx
  801f68:	e9 1d ff ff ff       	jmp    801e8a <__umoddi3+0x6a>
