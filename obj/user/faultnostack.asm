
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
  800143:	68 aa 1f 80 00       	push   $0x801faa
  800148:	6a 23                	push   $0x23
  80014a:	68 c7 1f 80 00       	push   $0x801fc7
  80014f:	e8 c2 0f 00 00       	call   801116 <_panic>

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
  8001d0:	68 aa 1f 80 00       	push   $0x801faa
  8001d5:	6a 23                	push   $0x23
  8001d7:	68 c7 1f 80 00       	push   $0x801fc7
  8001dc:	e8 35 0f 00 00       	call   801116 <_panic>

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
  800216:	68 aa 1f 80 00       	push   $0x801faa
  80021b:	6a 23                	push   $0x23
  80021d:	68 c7 1f 80 00       	push   $0x801fc7
  800222:	e8 ef 0e 00 00       	call   801116 <_panic>

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
  80025c:	68 aa 1f 80 00       	push   $0x801faa
  800261:	6a 23                	push   $0x23
  800263:	68 c7 1f 80 00       	push   $0x801fc7
  800268:	e8 a9 0e 00 00       	call   801116 <_panic>

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
  8002a2:	68 aa 1f 80 00       	push   $0x801faa
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 c7 1f 80 00       	push   $0x801fc7
  8002ae:	e8 63 0e 00 00       	call   801116 <_panic>

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
  8002e8:	68 aa 1f 80 00       	push   $0x801faa
  8002ed:	6a 23                	push   $0x23
  8002ef:	68 c7 1f 80 00       	push   $0x801fc7
  8002f4:	e8 1d 0e 00 00       	call   801116 <_panic>

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
  80032e:	68 aa 1f 80 00       	push   $0x801faa
  800333:	6a 23                	push   $0x23
  800335:	68 c7 1f 80 00       	push   $0x801fc7
  80033a:	e8 d7 0d 00 00       	call   801116 <_panic>

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
  80039a:	68 aa 1f 80 00       	push   $0x801faa
  80039f:	6a 23                	push   $0x23
  8003a1:	68 c7 1f 80 00       	push   $0x801fc7
  8003a6:	e8 6b 0d 00 00       	call   801116 <_panic>

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
  8004b7:	ba 54 20 80 00       	mov    $0x802054,%edx
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
  8004db:	68 d8 1f 80 00       	push   $0x801fd8
  8004e0:	e8 18 0d 00 00       	call   8011fd <cprintf>
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
  800749:	68 19 20 80 00       	push   $0x802019
  80074e:	e8 aa 0a 00 00       	call   8011fd <cprintf>
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
  80081a:	68 35 20 80 00       	push   $0x802035
  80081f:	e8 d9 09 00 00       	call   8011fd <cprintf>
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
  8008ca:	68 f8 1f 80 00       	push   $0x801ff8
  8008cf:	e8 29 09 00 00       	call   8011fd <cprintf>
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
  80096e:	e8 fb 01 00 00       	call   800b6e <open>
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
  8009c0:	e8 8a 12 00 00       	call   801c4f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009c5:	83 c4 0c             	add    $0xc,%esp
  8009c8:	6a 00                	push   $0x0
  8009ca:	53                   	push   %ebx
  8009cb:	6a 00                	push   $0x0
  8009cd:	e8 26 12 00 00       	call   801bf8 <ipc_recv>
}
  8009d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009d5:	5b                   	pop    %ebx
  8009d6:	5e                   	pop    %esi
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009d9:	83 ec 0c             	sub    $0xc,%esp
  8009dc:	6a 01                	push   $0x1
  8009de:	e8 d2 12 00 00       	call   801cb5 <ipc_find_env>
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
  800a76:	e8 8b 0d 00 00       	call   801806 <strcpy>
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
  800aa8:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  800aab:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800ab0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800ab5:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800ab8:	8b 55 08             	mov    0x8(%ebp),%edx
  800abb:	8b 52 0c             	mov    0xc(%edx),%edx
  800abe:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800ac4:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800ac9:	50                   	push   %eax
  800aca:	ff 75 0c             	pushl  0xc(%ebp)
  800acd:	68 08 50 80 00       	push   $0x805008
  800ad2:	e8 e5 0e 00 00       	call   8019bc <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800ad7:	ba 00 00 00 00       	mov    $0x0,%edx
  800adc:	b8 04 00 00 00       	mov    $0x4,%eax
  800ae1:	e8 ba fe ff ff       	call   8009a0 <fsipc>
}
  800ae6:	c9                   	leave  
  800ae7:	c3                   	ret    

00800ae8 <devfile_read>:
{
  800ae8:	f3 0f 1e fb          	endbr32 
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	56                   	push   %esi
  800af0:	53                   	push   %ebx
  800af1:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800af4:	8b 45 08             	mov    0x8(%ebp),%eax
  800af7:	8b 40 0c             	mov    0xc(%eax),%eax
  800afa:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800aff:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b05:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0f:	e8 8c fe ff ff       	call   8009a0 <fsipc>
  800b14:	89 c3                	mov    %eax,%ebx
  800b16:	85 c0                	test   %eax,%eax
  800b18:	78 1f                	js     800b39 <devfile_read+0x51>
	assert(r <= n);
  800b1a:	39 f0                	cmp    %esi,%eax
  800b1c:	77 24                	ja     800b42 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800b1e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b23:	7f 33                	jg     800b58 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b25:	83 ec 04             	sub    $0x4,%esp
  800b28:	50                   	push   %eax
  800b29:	68 00 50 80 00       	push   $0x805000
  800b2e:	ff 75 0c             	pushl  0xc(%ebp)
  800b31:	e8 86 0e 00 00       	call   8019bc <memmove>
	return r;
  800b36:	83 c4 10             	add    $0x10,%esp
}
  800b39:	89 d8                	mov    %ebx,%eax
  800b3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    
	assert(r <= n);
  800b42:	68 64 20 80 00       	push   $0x802064
  800b47:	68 6b 20 80 00       	push   $0x80206b
  800b4c:	6a 7c                	push   $0x7c
  800b4e:	68 80 20 80 00       	push   $0x802080
  800b53:	e8 be 05 00 00       	call   801116 <_panic>
	assert(r <= PGSIZE);
  800b58:	68 8b 20 80 00       	push   $0x80208b
  800b5d:	68 6b 20 80 00       	push   $0x80206b
  800b62:	6a 7d                	push   $0x7d
  800b64:	68 80 20 80 00       	push   $0x802080
  800b69:	e8 a8 05 00 00       	call   801116 <_panic>

00800b6e <open>:
{
  800b6e:	f3 0f 1e fb          	endbr32 
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	83 ec 1c             	sub    $0x1c,%esp
  800b7a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b7d:	56                   	push   %esi
  800b7e:	e8 40 0c 00 00       	call   8017c3 <strlen>
  800b83:	83 c4 10             	add    $0x10,%esp
  800b86:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b8b:	7f 6c                	jg     800bf9 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800b8d:	83 ec 0c             	sub    $0xc,%esp
  800b90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b93:	50                   	push   %eax
  800b94:	e8 67 f8 ff ff       	call   800400 <fd_alloc>
  800b99:	89 c3                	mov    %eax,%ebx
  800b9b:	83 c4 10             	add    $0x10,%esp
  800b9e:	85 c0                	test   %eax,%eax
  800ba0:	78 3c                	js     800bde <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800ba2:	83 ec 08             	sub    $0x8,%esp
  800ba5:	56                   	push   %esi
  800ba6:	68 00 50 80 00       	push   $0x805000
  800bab:	e8 56 0c 00 00       	call   801806 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800bb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb3:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bbb:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc0:	e8 db fd ff ff       	call   8009a0 <fsipc>
  800bc5:	89 c3                	mov    %eax,%ebx
  800bc7:	83 c4 10             	add    $0x10,%esp
  800bca:	85 c0                	test   %eax,%eax
  800bcc:	78 19                	js     800be7 <open+0x79>
	return fd2num(fd);
  800bce:	83 ec 0c             	sub    $0xc,%esp
  800bd1:	ff 75 f4             	pushl  -0xc(%ebp)
  800bd4:	e8 f8 f7 ff ff       	call   8003d1 <fd2num>
  800bd9:	89 c3                	mov    %eax,%ebx
  800bdb:	83 c4 10             	add    $0x10,%esp
}
  800bde:	89 d8                	mov    %ebx,%eax
  800be0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800be3:	5b                   	pop    %ebx
  800be4:	5e                   	pop    %esi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    
		fd_close(fd, 0);
  800be7:	83 ec 08             	sub    $0x8,%esp
  800bea:	6a 00                	push   $0x0
  800bec:	ff 75 f4             	pushl  -0xc(%ebp)
  800bef:	e8 10 f9 ff ff       	call   800504 <fd_close>
		return r;
  800bf4:	83 c4 10             	add    $0x10,%esp
  800bf7:	eb e5                	jmp    800bde <open+0x70>
		return -E_BAD_PATH;
  800bf9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800bfe:	eb de                	jmp    800bde <open+0x70>

00800c00 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c00:	f3 0f 1e fb          	endbr32 
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c14:	e8 87 fd ff ff       	call   8009a0 <fsipc>
}
  800c19:	c9                   	leave  
  800c1a:	c3                   	ret    

00800c1b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c1b:	f3 0f 1e fb          	endbr32 
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	ff 75 08             	pushl  0x8(%ebp)
  800c2d:	e8 b3 f7 ff ff       	call   8003e5 <fd2data>
  800c32:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800c34:	83 c4 08             	add    $0x8,%esp
  800c37:	68 97 20 80 00       	push   $0x802097
  800c3c:	53                   	push   %ebx
  800c3d:	e8 c4 0b 00 00       	call   801806 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800c42:	8b 46 04             	mov    0x4(%esi),%eax
  800c45:	2b 06                	sub    (%esi),%eax
  800c47:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800c4d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c54:	00 00 00 
	stat->st_dev = &devpipe;
  800c57:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c5e:	30 80 00 
	return 0;
}
  800c61:	b8 00 00 00 00       	mov    $0x0,%eax
  800c66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c6d:	f3 0f 1e fb          	endbr32 
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	53                   	push   %ebx
  800c75:	83 ec 0c             	sub    $0xc,%esp
  800c78:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c7b:	53                   	push   %ebx
  800c7c:	6a 00                	push   $0x0
  800c7e:	e8 a4 f5 ff ff       	call   800227 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c83:	89 1c 24             	mov    %ebx,(%esp)
  800c86:	e8 5a f7 ff ff       	call   8003e5 <fd2data>
  800c8b:	83 c4 08             	add    $0x8,%esp
  800c8e:	50                   	push   %eax
  800c8f:	6a 00                	push   $0x0
  800c91:	e8 91 f5 ff ff       	call   800227 <sys_page_unmap>
}
  800c96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c99:	c9                   	leave  
  800c9a:	c3                   	ret    

00800c9b <_pipeisclosed>:
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
  800ca1:	83 ec 1c             	sub    $0x1c,%esp
  800ca4:	89 c7                	mov    %eax,%edi
  800ca6:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800ca8:	a1 04 40 80 00       	mov    0x804004,%eax
  800cad:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800cb0:	83 ec 0c             	sub    $0xc,%esp
  800cb3:	57                   	push   %edi
  800cb4:	e8 39 10 00 00       	call   801cf2 <pageref>
  800cb9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800cbc:	89 34 24             	mov    %esi,(%esp)
  800cbf:	e8 2e 10 00 00       	call   801cf2 <pageref>
		nn = thisenv->env_runs;
  800cc4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800cca:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800ccd:	83 c4 10             	add    $0x10,%esp
  800cd0:	39 cb                	cmp    %ecx,%ebx
  800cd2:	74 1b                	je     800cef <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800cd4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800cd7:	75 cf                	jne    800ca8 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800cd9:	8b 42 58             	mov    0x58(%edx),%eax
  800cdc:	6a 01                	push   $0x1
  800cde:	50                   	push   %eax
  800cdf:	53                   	push   %ebx
  800ce0:	68 9e 20 80 00       	push   $0x80209e
  800ce5:	e8 13 05 00 00       	call   8011fd <cprintf>
  800cea:	83 c4 10             	add    $0x10,%esp
  800ced:	eb b9                	jmp    800ca8 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800cef:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800cf2:	0f 94 c0             	sete   %al
  800cf5:	0f b6 c0             	movzbl %al,%eax
}
  800cf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <devpipe_write>:
{
  800d00:	f3 0f 1e fb          	endbr32 
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
  800d0a:	83 ec 28             	sub    $0x28,%esp
  800d0d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800d10:	56                   	push   %esi
  800d11:	e8 cf f6 ff ff       	call   8003e5 <fd2data>
  800d16:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d18:	83 c4 10             	add    $0x10,%esp
  800d1b:	bf 00 00 00 00       	mov    $0x0,%edi
  800d20:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d23:	74 4f                	je     800d74 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d25:	8b 43 04             	mov    0x4(%ebx),%eax
  800d28:	8b 0b                	mov    (%ebx),%ecx
  800d2a:	8d 51 20             	lea    0x20(%ecx),%edx
  800d2d:	39 d0                	cmp    %edx,%eax
  800d2f:	72 14                	jb     800d45 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800d31:	89 da                	mov    %ebx,%edx
  800d33:	89 f0                	mov    %esi,%eax
  800d35:	e8 61 ff ff ff       	call   800c9b <_pipeisclosed>
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	75 3b                	jne    800d79 <devpipe_write+0x79>
			sys_yield();
  800d3e:	e8 34 f4 ff ff       	call   800177 <sys_yield>
  800d43:	eb e0                	jmp    800d25 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d48:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d4c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d4f:	89 c2                	mov    %eax,%edx
  800d51:	c1 fa 1f             	sar    $0x1f,%edx
  800d54:	89 d1                	mov    %edx,%ecx
  800d56:	c1 e9 1b             	shr    $0x1b,%ecx
  800d59:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800d5c:	83 e2 1f             	and    $0x1f,%edx
  800d5f:	29 ca                	sub    %ecx,%edx
  800d61:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800d65:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d69:	83 c0 01             	add    $0x1,%eax
  800d6c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800d6f:	83 c7 01             	add    $0x1,%edi
  800d72:	eb ac                	jmp    800d20 <devpipe_write+0x20>
	return i;
  800d74:	8b 45 10             	mov    0x10(%ebp),%eax
  800d77:	eb 05                	jmp    800d7e <devpipe_write+0x7e>
				return 0;
  800d79:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <devpipe_read>:
{
  800d86:	f3 0f 1e fb          	endbr32 
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 18             	sub    $0x18,%esp
  800d93:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800d96:	57                   	push   %edi
  800d97:	e8 49 f6 ff ff       	call   8003e5 <fd2data>
  800d9c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d9e:	83 c4 10             	add    $0x10,%esp
  800da1:	be 00 00 00 00       	mov    $0x0,%esi
  800da6:	3b 75 10             	cmp    0x10(%ebp),%esi
  800da9:	75 14                	jne    800dbf <devpipe_read+0x39>
	return i;
  800dab:	8b 45 10             	mov    0x10(%ebp),%eax
  800dae:	eb 02                	jmp    800db2 <devpipe_read+0x2c>
				return i;
  800db0:	89 f0                	mov    %esi,%eax
}
  800db2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    
			sys_yield();
  800dba:	e8 b8 f3 ff ff       	call   800177 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800dbf:	8b 03                	mov    (%ebx),%eax
  800dc1:	3b 43 04             	cmp    0x4(%ebx),%eax
  800dc4:	75 18                	jne    800dde <devpipe_read+0x58>
			if (i > 0)
  800dc6:	85 f6                	test   %esi,%esi
  800dc8:	75 e6                	jne    800db0 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800dca:	89 da                	mov    %ebx,%edx
  800dcc:	89 f8                	mov    %edi,%eax
  800dce:	e8 c8 fe ff ff       	call   800c9b <_pipeisclosed>
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	74 e3                	je     800dba <devpipe_read+0x34>
				return 0;
  800dd7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ddc:	eb d4                	jmp    800db2 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800dde:	99                   	cltd   
  800ddf:	c1 ea 1b             	shr    $0x1b,%edx
  800de2:	01 d0                	add    %edx,%eax
  800de4:	83 e0 1f             	and    $0x1f,%eax
  800de7:	29 d0                	sub    %edx,%eax
  800de9:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800dee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df1:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800df4:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800df7:	83 c6 01             	add    $0x1,%esi
  800dfa:	eb aa                	jmp    800da6 <devpipe_read+0x20>

00800dfc <pipe>:
{
  800dfc:	f3 0f 1e fb          	endbr32 
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	56                   	push   %esi
  800e04:	53                   	push   %ebx
  800e05:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800e08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e0b:	50                   	push   %eax
  800e0c:	e8 ef f5 ff ff       	call   800400 <fd_alloc>
  800e11:	89 c3                	mov    %eax,%ebx
  800e13:	83 c4 10             	add    $0x10,%esp
  800e16:	85 c0                	test   %eax,%eax
  800e18:	0f 88 23 01 00 00    	js     800f41 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e1e:	83 ec 04             	sub    $0x4,%esp
  800e21:	68 07 04 00 00       	push   $0x407
  800e26:	ff 75 f4             	pushl  -0xc(%ebp)
  800e29:	6a 00                	push   $0x0
  800e2b:	e8 6a f3 ff ff       	call   80019a <sys_page_alloc>
  800e30:	89 c3                	mov    %eax,%ebx
  800e32:	83 c4 10             	add    $0x10,%esp
  800e35:	85 c0                	test   %eax,%eax
  800e37:	0f 88 04 01 00 00    	js     800f41 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800e3d:	83 ec 0c             	sub    $0xc,%esp
  800e40:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e43:	50                   	push   %eax
  800e44:	e8 b7 f5 ff ff       	call   800400 <fd_alloc>
  800e49:	89 c3                	mov    %eax,%ebx
  800e4b:	83 c4 10             	add    $0x10,%esp
  800e4e:	85 c0                	test   %eax,%eax
  800e50:	0f 88 db 00 00 00    	js     800f31 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e56:	83 ec 04             	sub    $0x4,%esp
  800e59:	68 07 04 00 00       	push   $0x407
  800e5e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e61:	6a 00                	push   $0x0
  800e63:	e8 32 f3 ff ff       	call   80019a <sys_page_alloc>
  800e68:	89 c3                	mov    %eax,%ebx
  800e6a:	83 c4 10             	add    $0x10,%esp
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	0f 88 bc 00 00 00    	js     800f31 <pipe+0x135>
	va = fd2data(fd0);
  800e75:	83 ec 0c             	sub    $0xc,%esp
  800e78:	ff 75 f4             	pushl  -0xc(%ebp)
  800e7b:	e8 65 f5 ff ff       	call   8003e5 <fd2data>
  800e80:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e82:	83 c4 0c             	add    $0xc,%esp
  800e85:	68 07 04 00 00       	push   $0x407
  800e8a:	50                   	push   %eax
  800e8b:	6a 00                	push   $0x0
  800e8d:	e8 08 f3 ff ff       	call   80019a <sys_page_alloc>
  800e92:	89 c3                	mov    %eax,%ebx
  800e94:	83 c4 10             	add    $0x10,%esp
  800e97:	85 c0                	test   %eax,%eax
  800e99:	0f 88 82 00 00 00    	js     800f21 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e9f:	83 ec 0c             	sub    $0xc,%esp
  800ea2:	ff 75 f0             	pushl  -0x10(%ebp)
  800ea5:	e8 3b f5 ff ff       	call   8003e5 <fd2data>
  800eaa:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800eb1:	50                   	push   %eax
  800eb2:	6a 00                	push   $0x0
  800eb4:	56                   	push   %esi
  800eb5:	6a 00                	push   $0x0
  800eb7:	e8 25 f3 ff ff       	call   8001e1 <sys_page_map>
  800ebc:	89 c3                	mov    %eax,%ebx
  800ebe:	83 c4 20             	add    $0x20,%esp
  800ec1:	85 c0                	test   %eax,%eax
  800ec3:	78 4e                	js     800f13 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800ec5:	a1 20 30 80 00       	mov    0x803020,%eax
  800eca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ecd:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800ecf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ed2:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800ed9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800edc:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800ede:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800ee8:	83 ec 0c             	sub    $0xc,%esp
  800eeb:	ff 75 f4             	pushl  -0xc(%ebp)
  800eee:	e8 de f4 ff ff       	call   8003d1 <fd2num>
  800ef3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800ef8:	83 c4 04             	add    $0x4,%esp
  800efb:	ff 75 f0             	pushl  -0x10(%ebp)
  800efe:	e8 ce f4 ff ff       	call   8003d1 <fd2num>
  800f03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f06:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800f09:	83 c4 10             	add    $0x10,%esp
  800f0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f11:	eb 2e                	jmp    800f41 <pipe+0x145>
	sys_page_unmap(0, va);
  800f13:	83 ec 08             	sub    $0x8,%esp
  800f16:	56                   	push   %esi
  800f17:	6a 00                	push   $0x0
  800f19:	e8 09 f3 ff ff       	call   800227 <sys_page_unmap>
  800f1e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800f21:	83 ec 08             	sub    $0x8,%esp
  800f24:	ff 75 f0             	pushl  -0x10(%ebp)
  800f27:	6a 00                	push   $0x0
  800f29:	e8 f9 f2 ff ff       	call   800227 <sys_page_unmap>
  800f2e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800f31:	83 ec 08             	sub    $0x8,%esp
  800f34:	ff 75 f4             	pushl  -0xc(%ebp)
  800f37:	6a 00                	push   $0x0
  800f39:	e8 e9 f2 ff ff       	call   800227 <sys_page_unmap>
  800f3e:	83 c4 10             	add    $0x10,%esp
}
  800f41:	89 d8                	mov    %ebx,%eax
  800f43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f46:	5b                   	pop    %ebx
  800f47:	5e                   	pop    %esi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    

00800f4a <pipeisclosed>:
{
  800f4a:	f3 0f 1e fb          	endbr32 
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f57:	50                   	push   %eax
  800f58:	ff 75 08             	pushl  0x8(%ebp)
  800f5b:	e8 f6 f4 ff ff       	call   800456 <fd_lookup>
  800f60:	83 c4 10             	add    $0x10,%esp
  800f63:	85 c0                	test   %eax,%eax
  800f65:	78 18                	js     800f7f <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800f67:	83 ec 0c             	sub    $0xc,%esp
  800f6a:	ff 75 f4             	pushl  -0xc(%ebp)
  800f6d:	e8 73 f4 ff ff       	call   8003e5 <fd2data>
  800f72:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800f74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f77:	e8 1f fd ff ff       	call   800c9b <_pipeisclosed>
  800f7c:	83 c4 10             	add    $0x10,%esp
}
  800f7f:	c9                   	leave  
  800f80:	c3                   	ret    

00800f81 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f81:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800f85:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8a:	c3                   	ret    

00800f8b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f8b:	f3 0f 1e fb          	endbr32 
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f95:	68 b6 20 80 00       	push   $0x8020b6
  800f9a:	ff 75 0c             	pushl  0xc(%ebp)
  800f9d:	e8 64 08 00 00       	call   801806 <strcpy>
	return 0;
}
  800fa2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa7:	c9                   	leave  
  800fa8:	c3                   	ret    

00800fa9 <devcons_write>:
{
  800fa9:	f3 0f 1e fb          	endbr32 
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	57                   	push   %edi
  800fb1:	56                   	push   %esi
  800fb2:	53                   	push   %ebx
  800fb3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800fb9:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800fbe:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800fc4:	3b 75 10             	cmp    0x10(%ebp),%esi
  800fc7:	73 31                	jae    800ffa <devcons_write+0x51>
		m = n - tot;
  800fc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fcc:	29 f3                	sub    %esi,%ebx
  800fce:	83 fb 7f             	cmp    $0x7f,%ebx
  800fd1:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800fd6:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800fd9:	83 ec 04             	sub    $0x4,%esp
  800fdc:	53                   	push   %ebx
  800fdd:	89 f0                	mov    %esi,%eax
  800fdf:	03 45 0c             	add    0xc(%ebp),%eax
  800fe2:	50                   	push   %eax
  800fe3:	57                   	push   %edi
  800fe4:	e8 d3 09 00 00       	call   8019bc <memmove>
		sys_cputs(buf, m);
  800fe9:	83 c4 08             	add    $0x8,%esp
  800fec:	53                   	push   %ebx
  800fed:	57                   	push   %edi
  800fee:	e8 d7 f0 ff ff       	call   8000ca <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800ff3:	01 de                	add    %ebx,%esi
  800ff5:	83 c4 10             	add    $0x10,%esp
  800ff8:	eb ca                	jmp    800fc4 <devcons_write+0x1b>
}
  800ffa:	89 f0                	mov    %esi,%eax
  800ffc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fff:	5b                   	pop    %ebx
  801000:	5e                   	pop    %esi
  801001:	5f                   	pop    %edi
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    

00801004 <devcons_read>:
{
  801004:	f3 0f 1e fb          	endbr32 
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	83 ec 08             	sub    $0x8,%esp
  80100e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801013:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801017:	74 21                	je     80103a <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801019:	e8 ce f0 ff ff       	call   8000ec <sys_cgetc>
  80101e:	85 c0                	test   %eax,%eax
  801020:	75 07                	jne    801029 <devcons_read+0x25>
		sys_yield();
  801022:	e8 50 f1 ff ff       	call   800177 <sys_yield>
  801027:	eb f0                	jmp    801019 <devcons_read+0x15>
	if (c < 0)
  801029:	78 0f                	js     80103a <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  80102b:	83 f8 04             	cmp    $0x4,%eax
  80102e:	74 0c                	je     80103c <devcons_read+0x38>
	*(char*)vbuf = c;
  801030:	8b 55 0c             	mov    0xc(%ebp),%edx
  801033:	88 02                	mov    %al,(%edx)
	return 1;
  801035:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80103a:	c9                   	leave  
  80103b:	c3                   	ret    
		return 0;
  80103c:	b8 00 00 00 00       	mov    $0x0,%eax
  801041:	eb f7                	jmp    80103a <devcons_read+0x36>

00801043 <cputchar>:
{
  801043:	f3 0f 1e fb          	endbr32 
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80104d:	8b 45 08             	mov    0x8(%ebp),%eax
  801050:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801053:	6a 01                	push   $0x1
  801055:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801058:	50                   	push   %eax
  801059:	e8 6c f0 ff ff       	call   8000ca <sys_cputs>
}
  80105e:	83 c4 10             	add    $0x10,%esp
  801061:	c9                   	leave  
  801062:	c3                   	ret    

00801063 <getchar>:
{
  801063:	f3 0f 1e fb          	endbr32 
  801067:	55                   	push   %ebp
  801068:	89 e5                	mov    %esp,%ebp
  80106a:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80106d:	6a 01                	push   $0x1
  80106f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801072:	50                   	push   %eax
  801073:	6a 00                	push   $0x0
  801075:	e8 5f f6 ff ff       	call   8006d9 <read>
	if (r < 0)
  80107a:	83 c4 10             	add    $0x10,%esp
  80107d:	85 c0                	test   %eax,%eax
  80107f:	78 06                	js     801087 <getchar+0x24>
	if (r < 1)
  801081:	74 06                	je     801089 <getchar+0x26>
	return c;
  801083:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801087:	c9                   	leave  
  801088:	c3                   	ret    
		return -E_EOF;
  801089:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80108e:	eb f7                	jmp    801087 <getchar+0x24>

00801090 <iscons>:
{
  801090:	f3 0f 1e fb          	endbr32 
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80109a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80109d:	50                   	push   %eax
  80109e:	ff 75 08             	pushl  0x8(%ebp)
  8010a1:	e8 b0 f3 ff ff       	call   800456 <fd_lookup>
  8010a6:	83 c4 10             	add    $0x10,%esp
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	78 11                	js     8010be <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8010ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8010b6:	39 10                	cmp    %edx,(%eax)
  8010b8:	0f 94 c0             	sete   %al
  8010bb:	0f b6 c0             	movzbl %al,%eax
}
  8010be:	c9                   	leave  
  8010bf:	c3                   	ret    

008010c0 <opencons>:
{
  8010c0:	f3 0f 1e fb          	endbr32 
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8010ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010cd:	50                   	push   %eax
  8010ce:	e8 2d f3 ff ff       	call   800400 <fd_alloc>
  8010d3:	83 c4 10             	add    $0x10,%esp
  8010d6:	85 c0                	test   %eax,%eax
  8010d8:	78 3a                	js     801114 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8010da:	83 ec 04             	sub    $0x4,%esp
  8010dd:	68 07 04 00 00       	push   $0x407
  8010e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8010e5:	6a 00                	push   $0x0
  8010e7:	e8 ae f0 ff ff       	call   80019a <sys_page_alloc>
  8010ec:	83 c4 10             	add    $0x10,%esp
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	78 21                	js     801114 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8010f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010f6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8010fc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8010fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801101:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801108:	83 ec 0c             	sub    $0xc,%esp
  80110b:	50                   	push   %eax
  80110c:	e8 c0 f2 ff ff       	call   8003d1 <fd2num>
  801111:	83 c4 10             	add    $0x10,%esp
}
  801114:	c9                   	leave  
  801115:	c3                   	ret    

00801116 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801116:	f3 0f 1e fb          	endbr32 
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	56                   	push   %esi
  80111e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80111f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801122:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801128:	e8 27 f0 ff ff       	call   800154 <sys_getenvid>
  80112d:	83 ec 0c             	sub    $0xc,%esp
  801130:	ff 75 0c             	pushl  0xc(%ebp)
  801133:	ff 75 08             	pushl  0x8(%ebp)
  801136:	56                   	push   %esi
  801137:	50                   	push   %eax
  801138:	68 c4 20 80 00       	push   $0x8020c4
  80113d:	e8 bb 00 00 00       	call   8011fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801142:	83 c4 18             	add    $0x18,%esp
  801145:	53                   	push   %ebx
  801146:	ff 75 10             	pushl  0x10(%ebp)
  801149:	e8 5a 00 00 00       	call   8011a8 <vcprintf>
	cprintf("\n");
  80114e:	c7 04 24 ec 23 80 00 	movl   $0x8023ec,(%esp)
  801155:	e8 a3 00 00 00       	call   8011fd <cprintf>
  80115a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80115d:	cc                   	int3   
  80115e:	eb fd                	jmp    80115d <_panic+0x47>

00801160 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801160:	f3 0f 1e fb          	endbr32 
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	53                   	push   %ebx
  801168:	83 ec 04             	sub    $0x4,%esp
  80116b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80116e:	8b 13                	mov    (%ebx),%edx
  801170:	8d 42 01             	lea    0x1(%edx),%eax
  801173:	89 03                	mov    %eax,(%ebx)
  801175:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801178:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80117c:	3d ff 00 00 00       	cmp    $0xff,%eax
  801181:	74 09                	je     80118c <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801183:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801187:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80118a:	c9                   	leave  
  80118b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80118c:	83 ec 08             	sub    $0x8,%esp
  80118f:	68 ff 00 00 00       	push   $0xff
  801194:	8d 43 08             	lea    0x8(%ebx),%eax
  801197:	50                   	push   %eax
  801198:	e8 2d ef ff ff       	call   8000ca <sys_cputs>
		b->idx = 0;
  80119d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011a3:	83 c4 10             	add    $0x10,%esp
  8011a6:	eb db                	jmp    801183 <putch+0x23>

008011a8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8011a8:	f3 0f 1e fb          	endbr32 
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8011b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8011bc:	00 00 00 
	b.cnt = 0;
  8011bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8011c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8011c9:	ff 75 0c             	pushl  0xc(%ebp)
  8011cc:	ff 75 08             	pushl  0x8(%ebp)
  8011cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8011d5:	50                   	push   %eax
  8011d6:	68 60 11 80 00       	push   $0x801160
  8011db:	e8 20 01 00 00       	call   801300 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8011e0:	83 c4 08             	add    $0x8,%esp
  8011e3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8011e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8011ef:	50                   	push   %eax
  8011f0:	e8 d5 ee ff ff       	call   8000ca <sys_cputs>

	return b.cnt;
}
  8011f5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8011fb:	c9                   	leave  
  8011fc:	c3                   	ret    

008011fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8011fd:	f3 0f 1e fb          	endbr32 
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801207:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80120a:	50                   	push   %eax
  80120b:	ff 75 08             	pushl  0x8(%ebp)
  80120e:	e8 95 ff ff ff       	call   8011a8 <vcprintf>
	va_end(ap);

	return cnt;
}
  801213:	c9                   	leave  
  801214:	c3                   	ret    

00801215 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	57                   	push   %edi
  801219:	56                   	push   %esi
  80121a:	53                   	push   %ebx
  80121b:	83 ec 1c             	sub    $0x1c,%esp
  80121e:	89 c7                	mov    %eax,%edi
  801220:	89 d6                	mov    %edx,%esi
  801222:	8b 45 08             	mov    0x8(%ebp),%eax
  801225:	8b 55 0c             	mov    0xc(%ebp),%edx
  801228:	89 d1                	mov    %edx,%ecx
  80122a:	89 c2                	mov    %eax,%edx
  80122c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80122f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801232:	8b 45 10             	mov    0x10(%ebp),%eax
  801235:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801238:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80123b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801242:	39 c2                	cmp    %eax,%edx
  801244:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801247:	72 3e                	jb     801287 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801249:	83 ec 0c             	sub    $0xc,%esp
  80124c:	ff 75 18             	pushl  0x18(%ebp)
  80124f:	83 eb 01             	sub    $0x1,%ebx
  801252:	53                   	push   %ebx
  801253:	50                   	push   %eax
  801254:	83 ec 08             	sub    $0x8,%esp
  801257:	ff 75 e4             	pushl  -0x1c(%ebp)
  80125a:	ff 75 e0             	pushl  -0x20(%ebp)
  80125d:	ff 75 dc             	pushl  -0x24(%ebp)
  801260:	ff 75 d8             	pushl  -0x28(%ebp)
  801263:	e8 d8 0a 00 00       	call   801d40 <__udivdi3>
  801268:	83 c4 18             	add    $0x18,%esp
  80126b:	52                   	push   %edx
  80126c:	50                   	push   %eax
  80126d:	89 f2                	mov    %esi,%edx
  80126f:	89 f8                	mov    %edi,%eax
  801271:	e8 9f ff ff ff       	call   801215 <printnum>
  801276:	83 c4 20             	add    $0x20,%esp
  801279:	eb 13                	jmp    80128e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80127b:	83 ec 08             	sub    $0x8,%esp
  80127e:	56                   	push   %esi
  80127f:	ff 75 18             	pushl  0x18(%ebp)
  801282:	ff d7                	call   *%edi
  801284:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801287:	83 eb 01             	sub    $0x1,%ebx
  80128a:	85 db                	test   %ebx,%ebx
  80128c:	7f ed                	jg     80127b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80128e:	83 ec 08             	sub    $0x8,%esp
  801291:	56                   	push   %esi
  801292:	83 ec 04             	sub    $0x4,%esp
  801295:	ff 75 e4             	pushl  -0x1c(%ebp)
  801298:	ff 75 e0             	pushl  -0x20(%ebp)
  80129b:	ff 75 dc             	pushl  -0x24(%ebp)
  80129e:	ff 75 d8             	pushl  -0x28(%ebp)
  8012a1:	e8 aa 0b 00 00       	call   801e50 <__umoddi3>
  8012a6:	83 c4 14             	add    $0x14,%esp
  8012a9:	0f be 80 e7 20 80 00 	movsbl 0x8020e7(%eax),%eax
  8012b0:	50                   	push   %eax
  8012b1:	ff d7                	call   *%edi
}
  8012b3:	83 c4 10             	add    $0x10,%esp
  8012b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012b9:	5b                   	pop    %ebx
  8012ba:	5e                   	pop    %esi
  8012bb:	5f                   	pop    %edi
  8012bc:	5d                   	pop    %ebp
  8012bd:	c3                   	ret    

008012be <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8012be:	f3 0f 1e fb          	endbr32 
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8012c8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8012cc:	8b 10                	mov    (%eax),%edx
  8012ce:	3b 50 04             	cmp    0x4(%eax),%edx
  8012d1:	73 0a                	jae    8012dd <sprintputch+0x1f>
		*b->buf++ = ch;
  8012d3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8012d6:	89 08                	mov    %ecx,(%eax)
  8012d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012db:	88 02                	mov    %al,(%edx)
}
  8012dd:	5d                   	pop    %ebp
  8012de:	c3                   	ret    

008012df <printfmt>:
{
  8012df:	f3 0f 1e fb          	endbr32 
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8012e9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012ec:	50                   	push   %eax
  8012ed:	ff 75 10             	pushl  0x10(%ebp)
  8012f0:	ff 75 0c             	pushl  0xc(%ebp)
  8012f3:	ff 75 08             	pushl  0x8(%ebp)
  8012f6:	e8 05 00 00 00       	call   801300 <vprintfmt>
}
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	c9                   	leave  
  8012ff:	c3                   	ret    

00801300 <vprintfmt>:
{
  801300:	f3 0f 1e fb          	endbr32 
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	57                   	push   %edi
  801308:	56                   	push   %esi
  801309:	53                   	push   %ebx
  80130a:	83 ec 3c             	sub    $0x3c,%esp
  80130d:	8b 75 08             	mov    0x8(%ebp),%esi
  801310:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801313:	8b 7d 10             	mov    0x10(%ebp),%edi
  801316:	e9 4a 03 00 00       	jmp    801665 <vprintfmt+0x365>
		padc = ' ';
  80131b:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80131f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801326:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80132d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801334:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801339:	8d 47 01             	lea    0x1(%edi),%eax
  80133c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80133f:	0f b6 17             	movzbl (%edi),%edx
  801342:	8d 42 dd             	lea    -0x23(%edx),%eax
  801345:	3c 55                	cmp    $0x55,%al
  801347:	0f 87 de 03 00 00    	ja     80172b <vprintfmt+0x42b>
  80134d:	0f b6 c0             	movzbl %al,%eax
  801350:	3e ff 24 85 20 22 80 	notrack jmp *0x802220(,%eax,4)
  801357:	00 
  801358:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80135b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80135f:	eb d8                	jmp    801339 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801361:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801364:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801368:	eb cf                	jmp    801339 <vprintfmt+0x39>
  80136a:	0f b6 d2             	movzbl %dl,%edx
  80136d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801370:	b8 00 00 00 00       	mov    $0x0,%eax
  801375:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801378:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80137b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80137f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801382:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801385:	83 f9 09             	cmp    $0x9,%ecx
  801388:	77 55                	ja     8013df <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80138a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80138d:	eb e9                	jmp    801378 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80138f:	8b 45 14             	mov    0x14(%ebp),%eax
  801392:	8b 00                	mov    (%eax),%eax
  801394:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801397:	8b 45 14             	mov    0x14(%ebp),%eax
  80139a:	8d 40 04             	lea    0x4(%eax),%eax
  80139d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8013a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8013a3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013a7:	79 90                	jns    801339 <vprintfmt+0x39>
				width = precision, precision = -1;
  8013a9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8013ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013af:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8013b6:	eb 81                	jmp    801339 <vprintfmt+0x39>
  8013b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c2:	0f 49 d0             	cmovns %eax,%edx
  8013c5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8013c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8013cb:	e9 69 ff ff ff       	jmp    801339 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8013d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8013d3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8013da:	e9 5a ff ff ff       	jmp    801339 <vprintfmt+0x39>
  8013df:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8013e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8013e5:	eb bc                	jmp    8013a3 <vprintfmt+0xa3>
			lflag++;
  8013e7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8013ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8013ed:	e9 47 ff ff ff       	jmp    801339 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8013f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8013f5:	8d 78 04             	lea    0x4(%eax),%edi
  8013f8:	83 ec 08             	sub    $0x8,%esp
  8013fb:	53                   	push   %ebx
  8013fc:	ff 30                	pushl  (%eax)
  8013fe:	ff d6                	call   *%esi
			break;
  801400:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801403:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801406:	e9 57 02 00 00       	jmp    801662 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80140b:	8b 45 14             	mov    0x14(%ebp),%eax
  80140e:	8d 78 04             	lea    0x4(%eax),%edi
  801411:	8b 00                	mov    (%eax),%eax
  801413:	99                   	cltd   
  801414:	31 d0                	xor    %edx,%eax
  801416:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801418:	83 f8 0f             	cmp    $0xf,%eax
  80141b:	7f 23                	jg     801440 <vprintfmt+0x140>
  80141d:	8b 14 85 80 23 80 00 	mov    0x802380(,%eax,4),%edx
  801424:	85 d2                	test   %edx,%edx
  801426:	74 18                	je     801440 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  801428:	52                   	push   %edx
  801429:	68 7d 20 80 00       	push   $0x80207d
  80142e:	53                   	push   %ebx
  80142f:	56                   	push   %esi
  801430:	e8 aa fe ff ff       	call   8012df <printfmt>
  801435:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801438:	89 7d 14             	mov    %edi,0x14(%ebp)
  80143b:	e9 22 02 00 00       	jmp    801662 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  801440:	50                   	push   %eax
  801441:	68 ff 20 80 00       	push   $0x8020ff
  801446:	53                   	push   %ebx
  801447:	56                   	push   %esi
  801448:	e8 92 fe ff ff       	call   8012df <printfmt>
  80144d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801450:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801453:	e9 0a 02 00 00       	jmp    801662 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  801458:	8b 45 14             	mov    0x14(%ebp),%eax
  80145b:	83 c0 04             	add    $0x4,%eax
  80145e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801461:	8b 45 14             	mov    0x14(%ebp),%eax
  801464:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801466:	85 d2                	test   %edx,%edx
  801468:	b8 f8 20 80 00       	mov    $0x8020f8,%eax
  80146d:	0f 45 c2             	cmovne %edx,%eax
  801470:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801473:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801477:	7e 06                	jle    80147f <vprintfmt+0x17f>
  801479:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80147d:	75 0d                	jne    80148c <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80147f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801482:	89 c7                	mov    %eax,%edi
  801484:	03 45 e0             	add    -0x20(%ebp),%eax
  801487:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80148a:	eb 55                	jmp    8014e1 <vprintfmt+0x1e1>
  80148c:	83 ec 08             	sub    $0x8,%esp
  80148f:	ff 75 d8             	pushl  -0x28(%ebp)
  801492:	ff 75 cc             	pushl  -0x34(%ebp)
  801495:	e8 45 03 00 00       	call   8017df <strnlen>
  80149a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80149d:	29 c2                	sub    %eax,%edx
  80149f:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8014a2:	83 c4 10             	add    $0x10,%esp
  8014a5:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8014a7:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8014ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8014ae:	85 ff                	test   %edi,%edi
  8014b0:	7e 11                	jle    8014c3 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8014b2:	83 ec 08             	sub    $0x8,%esp
  8014b5:	53                   	push   %ebx
  8014b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8014b9:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8014bb:	83 ef 01             	sub    $0x1,%edi
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	eb eb                	jmp    8014ae <vprintfmt+0x1ae>
  8014c3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8014c6:	85 d2                	test   %edx,%edx
  8014c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8014cd:	0f 49 c2             	cmovns %edx,%eax
  8014d0:	29 c2                	sub    %eax,%edx
  8014d2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8014d5:	eb a8                	jmp    80147f <vprintfmt+0x17f>
					putch(ch, putdat);
  8014d7:	83 ec 08             	sub    $0x8,%esp
  8014da:	53                   	push   %ebx
  8014db:	52                   	push   %edx
  8014dc:	ff d6                	call   *%esi
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014e4:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014e6:	83 c7 01             	add    $0x1,%edi
  8014e9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014ed:	0f be d0             	movsbl %al,%edx
  8014f0:	85 d2                	test   %edx,%edx
  8014f2:	74 4b                	je     80153f <vprintfmt+0x23f>
  8014f4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014f8:	78 06                	js     801500 <vprintfmt+0x200>
  8014fa:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014fe:	78 1e                	js     80151e <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  801500:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801504:	74 d1                	je     8014d7 <vprintfmt+0x1d7>
  801506:	0f be c0             	movsbl %al,%eax
  801509:	83 e8 20             	sub    $0x20,%eax
  80150c:	83 f8 5e             	cmp    $0x5e,%eax
  80150f:	76 c6                	jbe    8014d7 <vprintfmt+0x1d7>
					putch('?', putdat);
  801511:	83 ec 08             	sub    $0x8,%esp
  801514:	53                   	push   %ebx
  801515:	6a 3f                	push   $0x3f
  801517:	ff d6                	call   *%esi
  801519:	83 c4 10             	add    $0x10,%esp
  80151c:	eb c3                	jmp    8014e1 <vprintfmt+0x1e1>
  80151e:	89 cf                	mov    %ecx,%edi
  801520:	eb 0e                	jmp    801530 <vprintfmt+0x230>
				putch(' ', putdat);
  801522:	83 ec 08             	sub    $0x8,%esp
  801525:	53                   	push   %ebx
  801526:	6a 20                	push   $0x20
  801528:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80152a:	83 ef 01             	sub    $0x1,%edi
  80152d:	83 c4 10             	add    $0x10,%esp
  801530:	85 ff                	test   %edi,%edi
  801532:	7f ee                	jg     801522 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  801534:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801537:	89 45 14             	mov    %eax,0x14(%ebp)
  80153a:	e9 23 01 00 00       	jmp    801662 <vprintfmt+0x362>
  80153f:	89 cf                	mov    %ecx,%edi
  801541:	eb ed                	jmp    801530 <vprintfmt+0x230>
	if (lflag >= 2)
  801543:	83 f9 01             	cmp    $0x1,%ecx
  801546:	7f 1b                	jg     801563 <vprintfmt+0x263>
	else if (lflag)
  801548:	85 c9                	test   %ecx,%ecx
  80154a:	74 63                	je     8015af <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80154c:	8b 45 14             	mov    0x14(%ebp),%eax
  80154f:	8b 00                	mov    (%eax),%eax
  801551:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801554:	99                   	cltd   
  801555:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801558:	8b 45 14             	mov    0x14(%ebp),%eax
  80155b:	8d 40 04             	lea    0x4(%eax),%eax
  80155e:	89 45 14             	mov    %eax,0x14(%ebp)
  801561:	eb 17                	jmp    80157a <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  801563:	8b 45 14             	mov    0x14(%ebp),%eax
  801566:	8b 50 04             	mov    0x4(%eax),%edx
  801569:	8b 00                	mov    (%eax),%eax
  80156b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80156e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801571:	8b 45 14             	mov    0x14(%ebp),%eax
  801574:	8d 40 08             	lea    0x8(%eax),%eax
  801577:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80157a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80157d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801580:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  801585:	85 c9                	test   %ecx,%ecx
  801587:	0f 89 bb 00 00 00    	jns    801648 <vprintfmt+0x348>
				putch('-', putdat);
  80158d:	83 ec 08             	sub    $0x8,%esp
  801590:	53                   	push   %ebx
  801591:	6a 2d                	push   $0x2d
  801593:	ff d6                	call   *%esi
				num = -(long long) num;
  801595:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801598:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80159b:	f7 da                	neg    %edx
  80159d:	83 d1 00             	adc    $0x0,%ecx
  8015a0:	f7 d9                	neg    %ecx
  8015a2:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8015a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8015aa:	e9 99 00 00 00       	jmp    801648 <vprintfmt+0x348>
		return va_arg(*ap, int);
  8015af:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b2:	8b 00                	mov    (%eax),%eax
  8015b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015b7:	99                   	cltd   
  8015b8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8015bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8015be:	8d 40 04             	lea    0x4(%eax),%eax
  8015c1:	89 45 14             	mov    %eax,0x14(%ebp)
  8015c4:	eb b4                	jmp    80157a <vprintfmt+0x27a>
	if (lflag >= 2)
  8015c6:	83 f9 01             	cmp    $0x1,%ecx
  8015c9:	7f 1b                	jg     8015e6 <vprintfmt+0x2e6>
	else if (lflag)
  8015cb:	85 c9                	test   %ecx,%ecx
  8015cd:	74 2c                	je     8015fb <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  8015cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d2:	8b 10                	mov    (%eax),%edx
  8015d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015d9:	8d 40 04             	lea    0x4(%eax),%eax
  8015dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015df:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8015e4:	eb 62                	jmp    801648 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8015e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e9:	8b 10                	mov    (%eax),%edx
  8015eb:	8b 48 04             	mov    0x4(%eax),%ecx
  8015ee:	8d 40 08             	lea    0x8(%eax),%eax
  8015f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015f4:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8015f9:	eb 4d                	jmp    801648 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8015fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8015fe:	8b 10                	mov    (%eax),%edx
  801600:	b9 00 00 00 00       	mov    $0x0,%ecx
  801605:	8d 40 04             	lea    0x4(%eax),%eax
  801608:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80160b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  801610:	eb 36                	jmp    801648 <vprintfmt+0x348>
	if (lflag >= 2)
  801612:	83 f9 01             	cmp    $0x1,%ecx
  801615:	7f 17                	jg     80162e <vprintfmt+0x32e>
	else if (lflag)
  801617:	85 c9                	test   %ecx,%ecx
  801619:	74 6e                	je     801689 <vprintfmt+0x389>
		return va_arg(*ap, long);
  80161b:	8b 45 14             	mov    0x14(%ebp),%eax
  80161e:	8b 10                	mov    (%eax),%edx
  801620:	89 d0                	mov    %edx,%eax
  801622:	99                   	cltd   
  801623:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801626:	8d 49 04             	lea    0x4(%ecx),%ecx
  801629:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80162c:	eb 11                	jmp    80163f <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  80162e:	8b 45 14             	mov    0x14(%ebp),%eax
  801631:	8b 50 04             	mov    0x4(%eax),%edx
  801634:	8b 00                	mov    (%eax),%eax
  801636:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801639:	8d 49 08             	lea    0x8(%ecx),%ecx
  80163c:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80163f:	89 d1                	mov    %edx,%ecx
  801641:	89 c2                	mov    %eax,%edx
            base = 8;
  801643:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  801648:	83 ec 0c             	sub    $0xc,%esp
  80164b:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80164f:	57                   	push   %edi
  801650:	ff 75 e0             	pushl  -0x20(%ebp)
  801653:	50                   	push   %eax
  801654:	51                   	push   %ecx
  801655:	52                   	push   %edx
  801656:	89 da                	mov    %ebx,%edx
  801658:	89 f0                	mov    %esi,%eax
  80165a:	e8 b6 fb ff ff       	call   801215 <printnum>
			break;
  80165f:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  801662:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801665:	83 c7 01             	add    $0x1,%edi
  801668:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80166c:	83 f8 25             	cmp    $0x25,%eax
  80166f:	0f 84 a6 fc ff ff    	je     80131b <vprintfmt+0x1b>
			if (ch == '\0')
  801675:	85 c0                	test   %eax,%eax
  801677:	0f 84 ce 00 00 00    	je     80174b <vprintfmt+0x44b>
			putch(ch, putdat);
  80167d:	83 ec 08             	sub    $0x8,%esp
  801680:	53                   	push   %ebx
  801681:	50                   	push   %eax
  801682:	ff d6                	call   *%esi
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	eb dc                	jmp    801665 <vprintfmt+0x365>
		return va_arg(*ap, int);
  801689:	8b 45 14             	mov    0x14(%ebp),%eax
  80168c:	8b 10                	mov    (%eax),%edx
  80168e:	89 d0                	mov    %edx,%eax
  801690:	99                   	cltd   
  801691:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801694:	8d 49 04             	lea    0x4(%ecx),%ecx
  801697:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80169a:	eb a3                	jmp    80163f <vprintfmt+0x33f>
			putch('0', putdat);
  80169c:	83 ec 08             	sub    $0x8,%esp
  80169f:	53                   	push   %ebx
  8016a0:	6a 30                	push   $0x30
  8016a2:	ff d6                	call   *%esi
			putch('x', putdat);
  8016a4:	83 c4 08             	add    $0x8,%esp
  8016a7:	53                   	push   %ebx
  8016a8:	6a 78                	push   $0x78
  8016aa:	ff d6                	call   *%esi
			num = (unsigned long long)
  8016ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8016af:	8b 10                	mov    (%eax),%edx
  8016b1:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8016b6:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8016b9:	8d 40 04             	lea    0x4(%eax),%eax
  8016bc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016bf:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8016c4:	eb 82                	jmp    801648 <vprintfmt+0x348>
	if (lflag >= 2)
  8016c6:	83 f9 01             	cmp    $0x1,%ecx
  8016c9:	7f 1e                	jg     8016e9 <vprintfmt+0x3e9>
	else if (lflag)
  8016cb:	85 c9                	test   %ecx,%ecx
  8016cd:	74 32                	je     801701 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  8016cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8016d2:	8b 10                	mov    (%eax),%edx
  8016d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016d9:	8d 40 04             	lea    0x4(%eax),%eax
  8016dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016df:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8016e4:	e9 5f ff ff ff       	jmp    801648 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8016e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8016ec:	8b 10                	mov    (%eax),%edx
  8016ee:	8b 48 04             	mov    0x4(%eax),%ecx
  8016f1:	8d 40 08             	lea    0x8(%eax),%eax
  8016f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016f7:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8016fc:	e9 47 ff ff ff       	jmp    801648 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  801701:	8b 45 14             	mov    0x14(%ebp),%eax
  801704:	8b 10                	mov    (%eax),%edx
  801706:	b9 00 00 00 00       	mov    $0x0,%ecx
  80170b:	8d 40 04             	lea    0x4(%eax),%eax
  80170e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801711:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  801716:	e9 2d ff ff ff       	jmp    801648 <vprintfmt+0x348>
			putch(ch, putdat);
  80171b:	83 ec 08             	sub    $0x8,%esp
  80171e:	53                   	push   %ebx
  80171f:	6a 25                	push   $0x25
  801721:	ff d6                	call   *%esi
			break;
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	e9 37 ff ff ff       	jmp    801662 <vprintfmt+0x362>
			putch('%', putdat);
  80172b:	83 ec 08             	sub    $0x8,%esp
  80172e:	53                   	push   %ebx
  80172f:	6a 25                	push   $0x25
  801731:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801733:	83 c4 10             	add    $0x10,%esp
  801736:	89 f8                	mov    %edi,%eax
  801738:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80173c:	74 05                	je     801743 <vprintfmt+0x443>
  80173e:	83 e8 01             	sub    $0x1,%eax
  801741:	eb f5                	jmp    801738 <vprintfmt+0x438>
  801743:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801746:	e9 17 ff ff ff       	jmp    801662 <vprintfmt+0x362>
}
  80174b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80174e:	5b                   	pop    %ebx
  80174f:	5e                   	pop    %esi
  801750:	5f                   	pop    %edi
  801751:	5d                   	pop    %ebp
  801752:	c3                   	ret    

00801753 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801753:	f3 0f 1e fb          	endbr32 
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	83 ec 18             	sub    $0x18,%esp
  80175d:	8b 45 08             	mov    0x8(%ebp),%eax
  801760:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801763:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801766:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80176a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80176d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801774:	85 c0                	test   %eax,%eax
  801776:	74 26                	je     80179e <vsnprintf+0x4b>
  801778:	85 d2                	test   %edx,%edx
  80177a:	7e 22                	jle    80179e <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80177c:	ff 75 14             	pushl  0x14(%ebp)
  80177f:	ff 75 10             	pushl  0x10(%ebp)
  801782:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801785:	50                   	push   %eax
  801786:	68 be 12 80 00       	push   $0x8012be
  80178b:	e8 70 fb ff ff       	call   801300 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801790:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801793:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801796:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801799:	83 c4 10             	add    $0x10,%esp
}
  80179c:	c9                   	leave  
  80179d:	c3                   	ret    
		return -E_INVAL;
  80179e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017a3:	eb f7                	jmp    80179c <vsnprintf+0x49>

008017a5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8017a5:	f3 0f 1e fb          	endbr32 
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8017af:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8017b2:	50                   	push   %eax
  8017b3:	ff 75 10             	pushl  0x10(%ebp)
  8017b6:	ff 75 0c             	pushl  0xc(%ebp)
  8017b9:	ff 75 08             	pushl  0x8(%ebp)
  8017bc:	e8 92 ff ff ff       	call   801753 <vsnprintf>
	va_end(ap);

	return rc;
}
  8017c1:	c9                   	leave  
  8017c2:	c3                   	ret    

008017c3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8017c3:	f3 0f 1e fb          	endbr32 
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8017cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8017d6:	74 05                	je     8017dd <strlen+0x1a>
		n++;
  8017d8:	83 c0 01             	add    $0x1,%eax
  8017db:	eb f5                	jmp    8017d2 <strlen+0xf>
	return n;
}
  8017dd:	5d                   	pop    %ebp
  8017de:	c3                   	ret    

008017df <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8017df:	f3 0f 1e fb          	endbr32 
  8017e3:	55                   	push   %ebp
  8017e4:	89 e5                	mov    %esp,%ebp
  8017e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8017ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f1:	39 d0                	cmp    %edx,%eax
  8017f3:	74 0d                	je     801802 <strnlen+0x23>
  8017f5:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8017f9:	74 05                	je     801800 <strnlen+0x21>
		n++;
  8017fb:	83 c0 01             	add    $0x1,%eax
  8017fe:	eb f1                	jmp    8017f1 <strnlen+0x12>
  801800:	89 c2                	mov    %eax,%edx
	return n;
}
  801802:	89 d0                	mov    %edx,%eax
  801804:	5d                   	pop    %ebp
  801805:	c3                   	ret    

00801806 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801806:	f3 0f 1e fb          	endbr32 
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	53                   	push   %ebx
  80180e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801811:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801814:	b8 00 00 00 00       	mov    $0x0,%eax
  801819:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80181d:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801820:	83 c0 01             	add    $0x1,%eax
  801823:	84 d2                	test   %dl,%dl
  801825:	75 f2                	jne    801819 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  801827:	89 c8                	mov    %ecx,%eax
  801829:	5b                   	pop    %ebx
  80182a:	5d                   	pop    %ebp
  80182b:	c3                   	ret    

0080182c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80182c:	f3 0f 1e fb          	endbr32 
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	53                   	push   %ebx
  801834:	83 ec 10             	sub    $0x10,%esp
  801837:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80183a:	53                   	push   %ebx
  80183b:	e8 83 ff ff ff       	call   8017c3 <strlen>
  801840:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801843:	ff 75 0c             	pushl  0xc(%ebp)
  801846:	01 d8                	add    %ebx,%eax
  801848:	50                   	push   %eax
  801849:	e8 b8 ff ff ff       	call   801806 <strcpy>
	return dst;
}
  80184e:	89 d8                	mov    %ebx,%eax
  801850:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801853:	c9                   	leave  
  801854:	c3                   	ret    

00801855 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801855:	f3 0f 1e fb          	endbr32 
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	56                   	push   %esi
  80185d:	53                   	push   %ebx
  80185e:	8b 75 08             	mov    0x8(%ebp),%esi
  801861:	8b 55 0c             	mov    0xc(%ebp),%edx
  801864:	89 f3                	mov    %esi,%ebx
  801866:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801869:	89 f0                	mov    %esi,%eax
  80186b:	39 d8                	cmp    %ebx,%eax
  80186d:	74 11                	je     801880 <strncpy+0x2b>
		*dst++ = *src;
  80186f:	83 c0 01             	add    $0x1,%eax
  801872:	0f b6 0a             	movzbl (%edx),%ecx
  801875:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801878:	80 f9 01             	cmp    $0x1,%cl
  80187b:	83 da ff             	sbb    $0xffffffff,%edx
  80187e:	eb eb                	jmp    80186b <strncpy+0x16>
	}
	return ret;
}
  801880:	89 f0                	mov    %esi,%eax
  801882:	5b                   	pop    %ebx
  801883:	5e                   	pop    %esi
  801884:	5d                   	pop    %ebp
  801885:	c3                   	ret    

00801886 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801886:	f3 0f 1e fb          	endbr32 
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	56                   	push   %esi
  80188e:	53                   	push   %ebx
  80188f:	8b 75 08             	mov    0x8(%ebp),%esi
  801892:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801895:	8b 55 10             	mov    0x10(%ebp),%edx
  801898:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80189a:	85 d2                	test   %edx,%edx
  80189c:	74 21                	je     8018bf <strlcpy+0x39>
  80189e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8018a2:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8018a4:	39 c2                	cmp    %eax,%edx
  8018a6:	74 14                	je     8018bc <strlcpy+0x36>
  8018a8:	0f b6 19             	movzbl (%ecx),%ebx
  8018ab:	84 db                	test   %bl,%bl
  8018ad:	74 0b                	je     8018ba <strlcpy+0x34>
			*dst++ = *src++;
  8018af:	83 c1 01             	add    $0x1,%ecx
  8018b2:	83 c2 01             	add    $0x1,%edx
  8018b5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8018b8:	eb ea                	jmp    8018a4 <strlcpy+0x1e>
  8018ba:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8018bc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8018bf:	29 f0                	sub    %esi,%eax
}
  8018c1:	5b                   	pop    %ebx
  8018c2:	5e                   	pop    %esi
  8018c3:	5d                   	pop    %ebp
  8018c4:	c3                   	ret    

008018c5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8018c5:	f3 0f 1e fb          	endbr32 
  8018c9:	55                   	push   %ebp
  8018ca:	89 e5                	mov    %esp,%ebp
  8018cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018cf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8018d2:	0f b6 01             	movzbl (%ecx),%eax
  8018d5:	84 c0                	test   %al,%al
  8018d7:	74 0c                	je     8018e5 <strcmp+0x20>
  8018d9:	3a 02                	cmp    (%edx),%al
  8018db:	75 08                	jne    8018e5 <strcmp+0x20>
		p++, q++;
  8018dd:	83 c1 01             	add    $0x1,%ecx
  8018e0:	83 c2 01             	add    $0x1,%edx
  8018e3:	eb ed                	jmp    8018d2 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8018e5:	0f b6 c0             	movzbl %al,%eax
  8018e8:	0f b6 12             	movzbl (%edx),%edx
  8018eb:	29 d0                	sub    %edx,%eax
}
  8018ed:	5d                   	pop    %ebp
  8018ee:	c3                   	ret    

008018ef <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8018ef:	f3 0f 1e fb          	endbr32 
  8018f3:	55                   	push   %ebp
  8018f4:	89 e5                	mov    %esp,%ebp
  8018f6:	53                   	push   %ebx
  8018f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018fd:	89 c3                	mov    %eax,%ebx
  8018ff:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801902:	eb 06                	jmp    80190a <strncmp+0x1b>
		n--, p++, q++;
  801904:	83 c0 01             	add    $0x1,%eax
  801907:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80190a:	39 d8                	cmp    %ebx,%eax
  80190c:	74 16                	je     801924 <strncmp+0x35>
  80190e:	0f b6 08             	movzbl (%eax),%ecx
  801911:	84 c9                	test   %cl,%cl
  801913:	74 04                	je     801919 <strncmp+0x2a>
  801915:	3a 0a                	cmp    (%edx),%cl
  801917:	74 eb                	je     801904 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801919:	0f b6 00             	movzbl (%eax),%eax
  80191c:	0f b6 12             	movzbl (%edx),%edx
  80191f:	29 d0                	sub    %edx,%eax
}
  801921:	5b                   	pop    %ebx
  801922:	5d                   	pop    %ebp
  801923:	c3                   	ret    
		return 0;
  801924:	b8 00 00 00 00       	mov    $0x0,%eax
  801929:	eb f6                	jmp    801921 <strncmp+0x32>

0080192b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80192b:	f3 0f 1e fb          	endbr32 
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	8b 45 08             	mov    0x8(%ebp),%eax
  801935:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801939:	0f b6 10             	movzbl (%eax),%edx
  80193c:	84 d2                	test   %dl,%dl
  80193e:	74 09                	je     801949 <strchr+0x1e>
		if (*s == c)
  801940:	38 ca                	cmp    %cl,%dl
  801942:	74 0a                	je     80194e <strchr+0x23>
	for (; *s; s++)
  801944:	83 c0 01             	add    $0x1,%eax
  801947:	eb f0                	jmp    801939 <strchr+0xe>
			return (char *) s;
	return 0;
  801949:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80194e:	5d                   	pop    %ebp
  80194f:	c3                   	ret    

00801950 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801950:	f3 0f 1e fb          	endbr32 
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	8b 45 08             	mov    0x8(%ebp),%eax
  80195a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80195e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801961:	38 ca                	cmp    %cl,%dl
  801963:	74 09                	je     80196e <strfind+0x1e>
  801965:	84 d2                	test   %dl,%dl
  801967:	74 05                	je     80196e <strfind+0x1e>
	for (; *s; s++)
  801969:	83 c0 01             	add    $0x1,%eax
  80196c:	eb f0                	jmp    80195e <strfind+0xe>
			break;
	return (char *) s;
}
  80196e:	5d                   	pop    %ebp
  80196f:	c3                   	ret    

00801970 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801970:	f3 0f 1e fb          	endbr32 
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	57                   	push   %edi
  801978:	56                   	push   %esi
  801979:	53                   	push   %ebx
  80197a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80197d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801980:	85 c9                	test   %ecx,%ecx
  801982:	74 31                	je     8019b5 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801984:	89 f8                	mov    %edi,%eax
  801986:	09 c8                	or     %ecx,%eax
  801988:	a8 03                	test   $0x3,%al
  80198a:	75 23                	jne    8019af <memset+0x3f>
		c &= 0xFF;
  80198c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801990:	89 d3                	mov    %edx,%ebx
  801992:	c1 e3 08             	shl    $0x8,%ebx
  801995:	89 d0                	mov    %edx,%eax
  801997:	c1 e0 18             	shl    $0x18,%eax
  80199a:	89 d6                	mov    %edx,%esi
  80199c:	c1 e6 10             	shl    $0x10,%esi
  80199f:	09 f0                	or     %esi,%eax
  8019a1:	09 c2                	or     %eax,%edx
  8019a3:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8019a5:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8019a8:	89 d0                	mov    %edx,%eax
  8019aa:	fc                   	cld    
  8019ab:	f3 ab                	rep stos %eax,%es:(%edi)
  8019ad:	eb 06                	jmp    8019b5 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8019af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b2:	fc                   	cld    
  8019b3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8019b5:	89 f8                	mov    %edi,%eax
  8019b7:	5b                   	pop    %ebx
  8019b8:	5e                   	pop    %esi
  8019b9:	5f                   	pop    %edi
  8019ba:	5d                   	pop    %ebp
  8019bb:	c3                   	ret    

008019bc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8019bc:	f3 0f 1e fb          	endbr32 
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	57                   	push   %edi
  8019c4:	56                   	push   %esi
  8019c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8019ce:	39 c6                	cmp    %eax,%esi
  8019d0:	73 32                	jae    801a04 <memmove+0x48>
  8019d2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8019d5:	39 c2                	cmp    %eax,%edx
  8019d7:	76 2b                	jbe    801a04 <memmove+0x48>
		s += n;
		d += n;
  8019d9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019dc:	89 fe                	mov    %edi,%esi
  8019de:	09 ce                	or     %ecx,%esi
  8019e0:	09 d6                	or     %edx,%esi
  8019e2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8019e8:	75 0e                	jne    8019f8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8019ea:	83 ef 04             	sub    $0x4,%edi
  8019ed:	8d 72 fc             	lea    -0x4(%edx),%esi
  8019f0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8019f3:	fd                   	std    
  8019f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019f6:	eb 09                	jmp    801a01 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8019f8:	83 ef 01             	sub    $0x1,%edi
  8019fb:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8019fe:	fd                   	std    
  8019ff:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801a01:	fc                   	cld    
  801a02:	eb 1a                	jmp    801a1e <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a04:	89 c2                	mov    %eax,%edx
  801a06:	09 ca                	or     %ecx,%edx
  801a08:	09 f2                	or     %esi,%edx
  801a0a:	f6 c2 03             	test   $0x3,%dl
  801a0d:	75 0a                	jne    801a19 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801a0f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801a12:	89 c7                	mov    %eax,%edi
  801a14:	fc                   	cld    
  801a15:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a17:	eb 05                	jmp    801a1e <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  801a19:	89 c7                	mov    %eax,%edi
  801a1b:	fc                   	cld    
  801a1c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801a1e:	5e                   	pop    %esi
  801a1f:	5f                   	pop    %edi
  801a20:	5d                   	pop    %ebp
  801a21:	c3                   	ret    

00801a22 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a22:	f3 0f 1e fb          	endbr32 
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801a2c:	ff 75 10             	pushl  0x10(%ebp)
  801a2f:	ff 75 0c             	pushl  0xc(%ebp)
  801a32:	ff 75 08             	pushl  0x8(%ebp)
  801a35:	e8 82 ff ff ff       	call   8019bc <memmove>
}
  801a3a:	c9                   	leave  
  801a3b:	c3                   	ret    

00801a3c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801a3c:	f3 0f 1e fb          	endbr32 
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	56                   	push   %esi
  801a44:	53                   	push   %ebx
  801a45:	8b 45 08             	mov    0x8(%ebp),%eax
  801a48:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a4b:	89 c6                	mov    %eax,%esi
  801a4d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a50:	39 f0                	cmp    %esi,%eax
  801a52:	74 1c                	je     801a70 <memcmp+0x34>
		if (*s1 != *s2)
  801a54:	0f b6 08             	movzbl (%eax),%ecx
  801a57:	0f b6 1a             	movzbl (%edx),%ebx
  801a5a:	38 d9                	cmp    %bl,%cl
  801a5c:	75 08                	jne    801a66 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801a5e:	83 c0 01             	add    $0x1,%eax
  801a61:	83 c2 01             	add    $0x1,%edx
  801a64:	eb ea                	jmp    801a50 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801a66:	0f b6 c1             	movzbl %cl,%eax
  801a69:	0f b6 db             	movzbl %bl,%ebx
  801a6c:	29 d8                	sub    %ebx,%eax
  801a6e:	eb 05                	jmp    801a75 <memcmp+0x39>
	}

	return 0;
  801a70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a75:	5b                   	pop    %ebx
  801a76:	5e                   	pop    %esi
  801a77:	5d                   	pop    %ebp
  801a78:	c3                   	ret    

00801a79 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a79:	f3 0f 1e fb          	endbr32 
  801a7d:	55                   	push   %ebp
  801a7e:	89 e5                	mov    %esp,%ebp
  801a80:	8b 45 08             	mov    0x8(%ebp),%eax
  801a83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a86:	89 c2                	mov    %eax,%edx
  801a88:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a8b:	39 d0                	cmp    %edx,%eax
  801a8d:	73 09                	jae    801a98 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a8f:	38 08                	cmp    %cl,(%eax)
  801a91:	74 05                	je     801a98 <memfind+0x1f>
	for (; s < ends; s++)
  801a93:	83 c0 01             	add    $0x1,%eax
  801a96:	eb f3                	jmp    801a8b <memfind+0x12>
			break;
	return (void *) s;
}
  801a98:	5d                   	pop    %ebp
  801a99:	c3                   	ret    

00801a9a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a9a:	f3 0f 1e fb          	endbr32 
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	57                   	push   %edi
  801aa2:	56                   	push   %esi
  801aa3:	53                   	push   %ebx
  801aa4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aa7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801aaa:	eb 03                	jmp    801aaf <strtol+0x15>
		s++;
  801aac:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801aaf:	0f b6 01             	movzbl (%ecx),%eax
  801ab2:	3c 20                	cmp    $0x20,%al
  801ab4:	74 f6                	je     801aac <strtol+0x12>
  801ab6:	3c 09                	cmp    $0x9,%al
  801ab8:	74 f2                	je     801aac <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801aba:	3c 2b                	cmp    $0x2b,%al
  801abc:	74 2a                	je     801ae8 <strtol+0x4e>
	int neg = 0;
  801abe:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801ac3:	3c 2d                	cmp    $0x2d,%al
  801ac5:	74 2b                	je     801af2 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ac7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801acd:	75 0f                	jne    801ade <strtol+0x44>
  801acf:	80 39 30             	cmpb   $0x30,(%ecx)
  801ad2:	74 28                	je     801afc <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801ad4:	85 db                	test   %ebx,%ebx
  801ad6:	b8 0a 00 00 00       	mov    $0xa,%eax
  801adb:	0f 44 d8             	cmove  %eax,%ebx
  801ade:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801ae6:	eb 46                	jmp    801b2e <strtol+0x94>
		s++;
  801ae8:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801aeb:	bf 00 00 00 00       	mov    $0x0,%edi
  801af0:	eb d5                	jmp    801ac7 <strtol+0x2d>
		s++, neg = 1;
  801af2:	83 c1 01             	add    $0x1,%ecx
  801af5:	bf 01 00 00 00       	mov    $0x1,%edi
  801afa:	eb cb                	jmp    801ac7 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801afc:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801b00:	74 0e                	je     801b10 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801b02:	85 db                	test   %ebx,%ebx
  801b04:	75 d8                	jne    801ade <strtol+0x44>
		s++, base = 8;
  801b06:	83 c1 01             	add    $0x1,%ecx
  801b09:	bb 08 00 00 00       	mov    $0x8,%ebx
  801b0e:	eb ce                	jmp    801ade <strtol+0x44>
		s += 2, base = 16;
  801b10:	83 c1 02             	add    $0x2,%ecx
  801b13:	bb 10 00 00 00       	mov    $0x10,%ebx
  801b18:	eb c4                	jmp    801ade <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801b1a:	0f be d2             	movsbl %dl,%edx
  801b1d:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801b20:	3b 55 10             	cmp    0x10(%ebp),%edx
  801b23:	7d 3a                	jge    801b5f <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801b25:	83 c1 01             	add    $0x1,%ecx
  801b28:	0f af 45 10          	imul   0x10(%ebp),%eax
  801b2c:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801b2e:	0f b6 11             	movzbl (%ecx),%edx
  801b31:	8d 72 d0             	lea    -0x30(%edx),%esi
  801b34:	89 f3                	mov    %esi,%ebx
  801b36:	80 fb 09             	cmp    $0x9,%bl
  801b39:	76 df                	jbe    801b1a <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801b3b:	8d 72 9f             	lea    -0x61(%edx),%esi
  801b3e:	89 f3                	mov    %esi,%ebx
  801b40:	80 fb 19             	cmp    $0x19,%bl
  801b43:	77 08                	ja     801b4d <strtol+0xb3>
			dig = *s - 'a' + 10;
  801b45:	0f be d2             	movsbl %dl,%edx
  801b48:	83 ea 57             	sub    $0x57,%edx
  801b4b:	eb d3                	jmp    801b20 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801b4d:	8d 72 bf             	lea    -0x41(%edx),%esi
  801b50:	89 f3                	mov    %esi,%ebx
  801b52:	80 fb 19             	cmp    $0x19,%bl
  801b55:	77 08                	ja     801b5f <strtol+0xc5>
			dig = *s - 'A' + 10;
  801b57:	0f be d2             	movsbl %dl,%edx
  801b5a:	83 ea 37             	sub    $0x37,%edx
  801b5d:	eb c1                	jmp    801b20 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801b5f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b63:	74 05                	je     801b6a <strtol+0xd0>
		*endptr = (char *) s;
  801b65:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b68:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801b6a:	89 c2                	mov    %eax,%edx
  801b6c:	f7 da                	neg    %edx
  801b6e:	85 ff                	test   %edi,%edi
  801b70:	0f 45 c2             	cmovne %edx,%eax
}
  801b73:	5b                   	pop    %ebx
  801b74:	5e                   	pop    %esi
  801b75:	5f                   	pop    %edi
  801b76:	5d                   	pop    %ebp
  801b77:	c3                   	ret    

00801b78 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801b78:	f3 0f 1e fb          	endbr32 
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801b82:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801b89:	74 0a                	je     801b95 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8e:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801b93:	c9                   	leave  
  801b94:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  801b95:	83 ec 0c             	sub    $0xc,%esp
  801b98:	68 df 23 80 00       	push   $0x8023df
  801b9d:	e8 5b f6 ff ff       	call   8011fd <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  801ba2:	83 c4 0c             	add    $0xc,%esp
  801ba5:	6a 07                	push   $0x7
  801ba7:	68 00 f0 bf ee       	push   $0xeebff000
  801bac:	6a 00                	push   $0x0
  801bae:	e8 e7 e5 ff ff       	call   80019a <sys_page_alloc>
  801bb3:	83 c4 10             	add    $0x10,%esp
  801bb6:	85 c0                	test   %eax,%eax
  801bb8:	78 2a                	js     801be4 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801bba:	83 ec 08             	sub    $0x8,%esp
  801bbd:	68 ab 03 80 00       	push   $0x8003ab
  801bc2:	6a 00                	push   $0x0
  801bc4:	e8 30 e7 ff ff       	call   8002f9 <sys_env_set_pgfault_upcall>
  801bc9:	83 c4 10             	add    $0x10,%esp
  801bcc:	85 c0                	test   %eax,%eax
  801bce:	79 bb                	jns    801b8b <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  801bd0:	83 ec 04             	sub    $0x4,%esp
  801bd3:	68 1c 24 80 00       	push   $0x80241c
  801bd8:	6a 25                	push   $0x25
  801bda:	68 0c 24 80 00       	push   $0x80240c
  801bdf:	e8 32 f5 ff ff       	call   801116 <_panic>
            panic("Allocation of UXSTACK failed!");
  801be4:	83 ec 04             	sub    $0x4,%esp
  801be7:	68 ee 23 80 00       	push   $0x8023ee
  801bec:	6a 22                	push   $0x22
  801bee:	68 0c 24 80 00       	push   $0x80240c
  801bf3:	e8 1e f5 ff ff       	call   801116 <_panic>

00801bf8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bf8:	f3 0f 1e fb          	endbr32 
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	56                   	push   %esi
  801c00:	53                   	push   %ebx
  801c01:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c07:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801c0a:	85 c0                	test   %eax,%eax
  801c0c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801c11:	0f 44 c2             	cmove  %edx,%eax
  801c14:	83 ec 0c             	sub    $0xc,%esp
  801c17:	50                   	push   %eax
  801c18:	e8 49 e7 ff ff       	call   800366 <sys_ipc_recv>
  801c1d:	83 c4 10             	add    $0x10,%esp
  801c20:	85 c0                	test   %eax,%eax
  801c22:	78 24                	js     801c48 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801c24:	85 f6                	test   %esi,%esi
  801c26:	74 0a                	je     801c32 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801c28:	a1 04 40 80 00       	mov    0x804004,%eax
  801c2d:	8b 40 78             	mov    0x78(%eax),%eax
  801c30:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801c32:	85 db                	test   %ebx,%ebx
  801c34:	74 0a                	je     801c40 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801c36:	a1 04 40 80 00       	mov    0x804004,%eax
  801c3b:	8b 40 74             	mov    0x74(%eax),%eax
  801c3e:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801c40:	a1 04 40 80 00       	mov    0x804004,%eax
  801c45:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c4b:	5b                   	pop    %ebx
  801c4c:	5e                   	pop    %esi
  801c4d:	5d                   	pop    %ebp
  801c4e:	c3                   	ret    

00801c4f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c4f:	f3 0f 1e fb          	endbr32 
  801c53:	55                   	push   %ebp
  801c54:	89 e5                	mov    %esp,%ebp
  801c56:	57                   	push   %edi
  801c57:	56                   	push   %esi
  801c58:	53                   	push   %ebx
  801c59:	83 ec 1c             	sub    $0x1c,%esp
  801c5c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801c66:	0f 45 d0             	cmovne %eax,%edx
  801c69:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801c6b:	be 01 00 00 00       	mov    $0x1,%esi
  801c70:	eb 1f                	jmp    801c91 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801c72:	e8 00 e5 ff ff       	call   800177 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801c77:	83 c3 01             	add    $0x1,%ebx
  801c7a:	39 de                	cmp    %ebx,%esi
  801c7c:	7f f4                	jg     801c72 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801c7e:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801c80:	83 fe 11             	cmp    $0x11,%esi
  801c83:	b8 01 00 00 00       	mov    $0x1,%eax
  801c88:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801c8b:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801c8f:	75 1c                	jne    801cad <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801c91:	ff 75 14             	pushl  0x14(%ebp)
  801c94:	57                   	push   %edi
  801c95:	ff 75 0c             	pushl  0xc(%ebp)
  801c98:	ff 75 08             	pushl  0x8(%ebp)
  801c9b:	e8 9f e6 ff ff       	call   80033f <sys_ipc_try_send>
  801ca0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801ca3:	83 c4 10             	add    $0x10,%esp
  801ca6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cab:	eb cd                	jmp    801c7a <ipc_send+0x2b>
}
  801cad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb0:	5b                   	pop    %ebx
  801cb1:	5e                   	pop    %esi
  801cb2:	5f                   	pop    %edi
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    

00801cb5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cb5:	f3 0f 1e fb          	endbr32 
  801cb9:	55                   	push   %ebp
  801cba:	89 e5                	mov    %esp,%ebp
  801cbc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801cbf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cc4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cc7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ccd:	8b 52 50             	mov    0x50(%edx),%edx
  801cd0:	39 ca                	cmp    %ecx,%edx
  801cd2:	74 11                	je     801ce5 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801cd4:	83 c0 01             	add    $0x1,%eax
  801cd7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cdc:	75 e6                	jne    801cc4 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801cde:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce3:	eb 0b                	jmp    801cf0 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801ce5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ce8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ced:	8b 40 48             	mov    0x48(%eax),%eax
}
  801cf0:	5d                   	pop    %ebp
  801cf1:	c3                   	ret    

00801cf2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cf2:	f3 0f 1e fb          	endbr32 
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cfc:	89 c2                	mov    %eax,%edx
  801cfe:	c1 ea 16             	shr    $0x16,%edx
  801d01:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801d08:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801d0d:	f6 c1 01             	test   $0x1,%cl
  801d10:	74 1c                	je     801d2e <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801d12:	c1 e8 0c             	shr    $0xc,%eax
  801d15:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d1c:	a8 01                	test   $0x1,%al
  801d1e:	74 0e                	je     801d2e <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d20:	c1 e8 0c             	shr    $0xc,%eax
  801d23:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801d2a:	ef 
  801d2b:	0f b7 d2             	movzwl %dx,%edx
}
  801d2e:	89 d0                	mov    %edx,%eax
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    
  801d32:	66 90                	xchg   %ax,%ax
  801d34:	66 90                	xchg   %ax,%ax
  801d36:	66 90                	xchg   %ax,%ax
  801d38:	66 90                	xchg   %ax,%ax
  801d3a:	66 90                	xchg   %ax,%ax
  801d3c:	66 90                	xchg   %ax,%ax
  801d3e:	66 90                	xchg   %ax,%ax

00801d40 <__udivdi3>:
  801d40:	f3 0f 1e fb          	endbr32 
  801d44:	55                   	push   %ebp
  801d45:	57                   	push   %edi
  801d46:	56                   	push   %esi
  801d47:	53                   	push   %ebx
  801d48:	83 ec 1c             	sub    $0x1c,%esp
  801d4b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d4f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801d53:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d57:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801d5b:	85 d2                	test   %edx,%edx
  801d5d:	75 19                	jne    801d78 <__udivdi3+0x38>
  801d5f:	39 f3                	cmp    %esi,%ebx
  801d61:	76 4d                	jbe    801db0 <__udivdi3+0x70>
  801d63:	31 ff                	xor    %edi,%edi
  801d65:	89 e8                	mov    %ebp,%eax
  801d67:	89 f2                	mov    %esi,%edx
  801d69:	f7 f3                	div    %ebx
  801d6b:	89 fa                	mov    %edi,%edx
  801d6d:	83 c4 1c             	add    $0x1c,%esp
  801d70:	5b                   	pop    %ebx
  801d71:	5e                   	pop    %esi
  801d72:	5f                   	pop    %edi
  801d73:	5d                   	pop    %ebp
  801d74:	c3                   	ret    
  801d75:	8d 76 00             	lea    0x0(%esi),%esi
  801d78:	39 f2                	cmp    %esi,%edx
  801d7a:	76 14                	jbe    801d90 <__udivdi3+0x50>
  801d7c:	31 ff                	xor    %edi,%edi
  801d7e:	31 c0                	xor    %eax,%eax
  801d80:	89 fa                	mov    %edi,%edx
  801d82:	83 c4 1c             	add    $0x1c,%esp
  801d85:	5b                   	pop    %ebx
  801d86:	5e                   	pop    %esi
  801d87:	5f                   	pop    %edi
  801d88:	5d                   	pop    %ebp
  801d89:	c3                   	ret    
  801d8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d90:	0f bd fa             	bsr    %edx,%edi
  801d93:	83 f7 1f             	xor    $0x1f,%edi
  801d96:	75 48                	jne    801de0 <__udivdi3+0xa0>
  801d98:	39 f2                	cmp    %esi,%edx
  801d9a:	72 06                	jb     801da2 <__udivdi3+0x62>
  801d9c:	31 c0                	xor    %eax,%eax
  801d9e:	39 eb                	cmp    %ebp,%ebx
  801da0:	77 de                	ja     801d80 <__udivdi3+0x40>
  801da2:	b8 01 00 00 00       	mov    $0x1,%eax
  801da7:	eb d7                	jmp    801d80 <__udivdi3+0x40>
  801da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801db0:	89 d9                	mov    %ebx,%ecx
  801db2:	85 db                	test   %ebx,%ebx
  801db4:	75 0b                	jne    801dc1 <__udivdi3+0x81>
  801db6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dbb:	31 d2                	xor    %edx,%edx
  801dbd:	f7 f3                	div    %ebx
  801dbf:	89 c1                	mov    %eax,%ecx
  801dc1:	31 d2                	xor    %edx,%edx
  801dc3:	89 f0                	mov    %esi,%eax
  801dc5:	f7 f1                	div    %ecx
  801dc7:	89 c6                	mov    %eax,%esi
  801dc9:	89 e8                	mov    %ebp,%eax
  801dcb:	89 f7                	mov    %esi,%edi
  801dcd:	f7 f1                	div    %ecx
  801dcf:	89 fa                	mov    %edi,%edx
  801dd1:	83 c4 1c             	add    $0x1c,%esp
  801dd4:	5b                   	pop    %ebx
  801dd5:	5e                   	pop    %esi
  801dd6:	5f                   	pop    %edi
  801dd7:	5d                   	pop    %ebp
  801dd8:	c3                   	ret    
  801dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801de0:	89 f9                	mov    %edi,%ecx
  801de2:	b8 20 00 00 00       	mov    $0x20,%eax
  801de7:	29 f8                	sub    %edi,%eax
  801de9:	d3 e2                	shl    %cl,%edx
  801deb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801def:	89 c1                	mov    %eax,%ecx
  801df1:	89 da                	mov    %ebx,%edx
  801df3:	d3 ea                	shr    %cl,%edx
  801df5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801df9:	09 d1                	or     %edx,%ecx
  801dfb:	89 f2                	mov    %esi,%edx
  801dfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e01:	89 f9                	mov    %edi,%ecx
  801e03:	d3 e3                	shl    %cl,%ebx
  801e05:	89 c1                	mov    %eax,%ecx
  801e07:	d3 ea                	shr    %cl,%edx
  801e09:	89 f9                	mov    %edi,%ecx
  801e0b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801e0f:	89 eb                	mov    %ebp,%ebx
  801e11:	d3 e6                	shl    %cl,%esi
  801e13:	89 c1                	mov    %eax,%ecx
  801e15:	d3 eb                	shr    %cl,%ebx
  801e17:	09 de                	or     %ebx,%esi
  801e19:	89 f0                	mov    %esi,%eax
  801e1b:	f7 74 24 08          	divl   0x8(%esp)
  801e1f:	89 d6                	mov    %edx,%esi
  801e21:	89 c3                	mov    %eax,%ebx
  801e23:	f7 64 24 0c          	mull   0xc(%esp)
  801e27:	39 d6                	cmp    %edx,%esi
  801e29:	72 15                	jb     801e40 <__udivdi3+0x100>
  801e2b:	89 f9                	mov    %edi,%ecx
  801e2d:	d3 e5                	shl    %cl,%ebp
  801e2f:	39 c5                	cmp    %eax,%ebp
  801e31:	73 04                	jae    801e37 <__udivdi3+0xf7>
  801e33:	39 d6                	cmp    %edx,%esi
  801e35:	74 09                	je     801e40 <__udivdi3+0x100>
  801e37:	89 d8                	mov    %ebx,%eax
  801e39:	31 ff                	xor    %edi,%edi
  801e3b:	e9 40 ff ff ff       	jmp    801d80 <__udivdi3+0x40>
  801e40:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801e43:	31 ff                	xor    %edi,%edi
  801e45:	e9 36 ff ff ff       	jmp    801d80 <__udivdi3+0x40>
  801e4a:	66 90                	xchg   %ax,%ax
  801e4c:	66 90                	xchg   %ax,%ax
  801e4e:	66 90                	xchg   %ax,%ax

00801e50 <__umoddi3>:
  801e50:	f3 0f 1e fb          	endbr32 
  801e54:	55                   	push   %ebp
  801e55:	57                   	push   %edi
  801e56:	56                   	push   %esi
  801e57:	53                   	push   %ebx
  801e58:	83 ec 1c             	sub    $0x1c,%esp
  801e5b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801e5f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801e63:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801e67:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	75 19                	jne    801e88 <__umoddi3+0x38>
  801e6f:	39 df                	cmp    %ebx,%edi
  801e71:	76 5d                	jbe    801ed0 <__umoddi3+0x80>
  801e73:	89 f0                	mov    %esi,%eax
  801e75:	89 da                	mov    %ebx,%edx
  801e77:	f7 f7                	div    %edi
  801e79:	89 d0                	mov    %edx,%eax
  801e7b:	31 d2                	xor    %edx,%edx
  801e7d:	83 c4 1c             	add    $0x1c,%esp
  801e80:	5b                   	pop    %ebx
  801e81:	5e                   	pop    %esi
  801e82:	5f                   	pop    %edi
  801e83:	5d                   	pop    %ebp
  801e84:	c3                   	ret    
  801e85:	8d 76 00             	lea    0x0(%esi),%esi
  801e88:	89 f2                	mov    %esi,%edx
  801e8a:	39 d8                	cmp    %ebx,%eax
  801e8c:	76 12                	jbe    801ea0 <__umoddi3+0x50>
  801e8e:	89 f0                	mov    %esi,%eax
  801e90:	89 da                	mov    %ebx,%edx
  801e92:	83 c4 1c             	add    $0x1c,%esp
  801e95:	5b                   	pop    %ebx
  801e96:	5e                   	pop    %esi
  801e97:	5f                   	pop    %edi
  801e98:	5d                   	pop    %ebp
  801e99:	c3                   	ret    
  801e9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ea0:	0f bd e8             	bsr    %eax,%ebp
  801ea3:	83 f5 1f             	xor    $0x1f,%ebp
  801ea6:	75 50                	jne    801ef8 <__umoddi3+0xa8>
  801ea8:	39 d8                	cmp    %ebx,%eax
  801eaa:	0f 82 e0 00 00 00    	jb     801f90 <__umoddi3+0x140>
  801eb0:	89 d9                	mov    %ebx,%ecx
  801eb2:	39 f7                	cmp    %esi,%edi
  801eb4:	0f 86 d6 00 00 00    	jbe    801f90 <__umoddi3+0x140>
  801eba:	89 d0                	mov    %edx,%eax
  801ebc:	89 ca                	mov    %ecx,%edx
  801ebe:	83 c4 1c             	add    $0x1c,%esp
  801ec1:	5b                   	pop    %ebx
  801ec2:	5e                   	pop    %esi
  801ec3:	5f                   	pop    %edi
  801ec4:	5d                   	pop    %ebp
  801ec5:	c3                   	ret    
  801ec6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ecd:	8d 76 00             	lea    0x0(%esi),%esi
  801ed0:	89 fd                	mov    %edi,%ebp
  801ed2:	85 ff                	test   %edi,%edi
  801ed4:	75 0b                	jne    801ee1 <__umoddi3+0x91>
  801ed6:	b8 01 00 00 00       	mov    $0x1,%eax
  801edb:	31 d2                	xor    %edx,%edx
  801edd:	f7 f7                	div    %edi
  801edf:	89 c5                	mov    %eax,%ebp
  801ee1:	89 d8                	mov    %ebx,%eax
  801ee3:	31 d2                	xor    %edx,%edx
  801ee5:	f7 f5                	div    %ebp
  801ee7:	89 f0                	mov    %esi,%eax
  801ee9:	f7 f5                	div    %ebp
  801eeb:	89 d0                	mov    %edx,%eax
  801eed:	31 d2                	xor    %edx,%edx
  801eef:	eb 8c                	jmp    801e7d <__umoddi3+0x2d>
  801ef1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ef8:	89 e9                	mov    %ebp,%ecx
  801efa:	ba 20 00 00 00       	mov    $0x20,%edx
  801eff:	29 ea                	sub    %ebp,%edx
  801f01:	d3 e0                	shl    %cl,%eax
  801f03:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f07:	89 d1                	mov    %edx,%ecx
  801f09:	89 f8                	mov    %edi,%eax
  801f0b:	d3 e8                	shr    %cl,%eax
  801f0d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801f11:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f15:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f19:	09 c1                	or     %eax,%ecx
  801f1b:	89 d8                	mov    %ebx,%eax
  801f1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f21:	89 e9                	mov    %ebp,%ecx
  801f23:	d3 e7                	shl    %cl,%edi
  801f25:	89 d1                	mov    %edx,%ecx
  801f27:	d3 e8                	shr    %cl,%eax
  801f29:	89 e9                	mov    %ebp,%ecx
  801f2b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f2f:	d3 e3                	shl    %cl,%ebx
  801f31:	89 c7                	mov    %eax,%edi
  801f33:	89 d1                	mov    %edx,%ecx
  801f35:	89 f0                	mov    %esi,%eax
  801f37:	d3 e8                	shr    %cl,%eax
  801f39:	89 e9                	mov    %ebp,%ecx
  801f3b:	89 fa                	mov    %edi,%edx
  801f3d:	d3 e6                	shl    %cl,%esi
  801f3f:	09 d8                	or     %ebx,%eax
  801f41:	f7 74 24 08          	divl   0x8(%esp)
  801f45:	89 d1                	mov    %edx,%ecx
  801f47:	89 f3                	mov    %esi,%ebx
  801f49:	f7 64 24 0c          	mull   0xc(%esp)
  801f4d:	89 c6                	mov    %eax,%esi
  801f4f:	89 d7                	mov    %edx,%edi
  801f51:	39 d1                	cmp    %edx,%ecx
  801f53:	72 06                	jb     801f5b <__umoddi3+0x10b>
  801f55:	75 10                	jne    801f67 <__umoddi3+0x117>
  801f57:	39 c3                	cmp    %eax,%ebx
  801f59:	73 0c                	jae    801f67 <__umoddi3+0x117>
  801f5b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801f5f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801f63:	89 d7                	mov    %edx,%edi
  801f65:	89 c6                	mov    %eax,%esi
  801f67:	89 ca                	mov    %ecx,%edx
  801f69:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801f6e:	29 f3                	sub    %esi,%ebx
  801f70:	19 fa                	sbb    %edi,%edx
  801f72:	89 d0                	mov    %edx,%eax
  801f74:	d3 e0                	shl    %cl,%eax
  801f76:	89 e9                	mov    %ebp,%ecx
  801f78:	d3 eb                	shr    %cl,%ebx
  801f7a:	d3 ea                	shr    %cl,%edx
  801f7c:	09 d8                	or     %ebx,%eax
  801f7e:	83 c4 1c             	add    $0x1c,%esp
  801f81:	5b                   	pop    %ebx
  801f82:	5e                   	pop    %esi
  801f83:	5f                   	pop    %edi
  801f84:	5d                   	pop    %ebp
  801f85:	c3                   	ret    
  801f86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f8d:	8d 76 00             	lea    0x0(%esi),%esi
  801f90:	29 fe                	sub    %edi,%esi
  801f92:	19 c3                	sbb    %eax,%ebx
  801f94:	89 f2                	mov    %esi,%edx
  801f96:	89 d9                	mov    %ebx,%ecx
  801f98:	e9 1d ff ff ff       	jmp    801eba <__umoddi3+0x6a>
