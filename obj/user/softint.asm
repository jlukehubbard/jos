
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
  800049:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800050:	00 00 00 
    envid_t envid = sys_getenvid();
  800053:	e8 d6 00 00 00       	call   80012e <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800058:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800060:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800065:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006a:	85 db                	test   %ebx,%ebx
  80006c:	7e 07                	jle    800075 <libmain+0x3b>
		binaryname = argv[0];
  80006e:	8b 06                	mov    (%esi),%eax
  800070:	a3 00 20 80 00       	mov    %eax,0x802000

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
  800095:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800098:	6a 00                	push   $0x0
  80009a:	e8 4a 00 00 00       	call   8000e9 <sys_env_destroy>
}
  80009f:	83 c4 10             	add    $0x10,%esp
  8000a2:	c9                   	leave  
  8000a3:	c3                   	ret    

008000a4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a4:	f3 0f 1e fb          	endbr32 
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	57                   	push   %edi
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b9:	89 c3                	mov    %eax,%ebx
  8000bb:	89 c7                	mov    %eax,%edi
  8000bd:	89 c6                	mov    %eax,%esi
  8000bf:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c1:	5b                   	pop    %ebx
  8000c2:	5e                   	pop    %esi
  8000c3:	5f                   	pop    %edi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c6:	f3 0f 1e fb          	endbr32 
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	f3 0f 1e fb          	endbr32 
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	57                   	push   %edi
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fe:	b8 03 00 00 00       	mov    $0x3,%eax
  800103:	89 cb                	mov    %ecx,%ebx
  800105:	89 cf                	mov    %ecx,%edi
  800107:	89 ce                	mov    %ecx,%esi
  800109:	cd 30                	int    $0x30
	if(check && ret > 0)
  80010b:	85 c0                	test   %eax,%eax
  80010d:	7f 08                	jg     800117 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	50                   	push   %eax
  80011b:	6a 03                	push   $0x3
  80011d:	68 6a 10 80 00       	push   $0x80106a
  800122:	6a 23                	push   $0x23
  800124:	68 87 10 80 00       	push   $0x801087
  800129:	e8 57 02 00 00       	call   800385 <_panic>

0080012e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012e:	f3 0f 1e fb          	endbr32 
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_yield>:

void
sys_yield(void)
{
  800151:	f3 0f 1e fb          	endbr32 
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	b8 0b 00 00 00       	mov    $0xb,%eax
  800165:	89 d1                	mov    %edx,%ecx
  800167:	89 d3                	mov    %edx,%ebx
  800169:	89 d7                	mov    %edx,%edi
  80016b:	89 d6                	mov    %edx,%esi
  80016d:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016f:	5b                   	pop    %ebx
  800170:	5e                   	pop    %esi
  800171:	5f                   	pop    %edi
  800172:	5d                   	pop    %ebp
  800173:	c3                   	ret    

00800174 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800174:	f3 0f 1e fb          	endbr32 
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	57                   	push   %edi
  80017c:	56                   	push   %esi
  80017d:	53                   	push   %ebx
  80017e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800181:	be 00 00 00 00       	mov    $0x0,%esi
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018c:	b8 04 00 00 00       	mov    $0x4,%eax
  800191:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800194:	89 f7                	mov    %esi,%edi
  800196:	cd 30                	int    $0x30
	if(check && ret > 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	7f 08                	jg     8001a4 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019f:	5b                   	pop    %ebx
  8001a0:	5e                   	pop    %esi
  8001a1:	5f                   	pop    %edi
  8001a2:	5d                   	pop    %ebp
  8001a3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a4:	83 ec 0c             	sub    $0xc,%esp
  8001a7:	50                   	push   %eax
  8001a8:	6a 04                	push   $0x4
  8001aa:	68 6a 10 80 00       	push   $0x80106a
  8001af:	6a 23                	push   $0x23
  8001b1:	68 87 10 80 00       	push   $0x801087
  8001b6:	e8 ca 01 00 00       	call   800385 <_panic>

008001bb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bb:	f3 0f 1e fb          	endbr32 
  8001bf:	55                   	push   %ebp
  8001c0:	89 e5                	mov    %esp,%ebp
  8001c2:	57                   	push   %edi
  8001c3:	56                   	push   %esi
  8001c4:	53                   	push   %ebx
  8001c5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ce:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d9:	8b 75 18             	mov    0x18(%ebp),%esi
  8001dc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001de:	85 c0                	test   %eax,%eax
  8001e0:	7f 08                	jg     8001ea <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e5:	5b                   	pop    %ebx
  8001e6:	5e                   	pop    %esi
  8001e7:	5f                   	pop    %edi
  8001e8:	5d                   	pop    %ebp
  8001e9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	50                   	push   %eax
  8001ee:	6a 05                	push   $0x5
  8001f0:	68 6a 10 80 00       	push   $0x80106a
  8001f5:	6a 23                	push   $0x23
  8001f7:	68 87 10 80 00       	push   $0x801087
  8001fc:	e8 84 01 00 00       	call   800385 <_panic>

00800201 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800201:	f3 0f 1e fb          	endbr32 
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	57                   	push   %edi
  800209:	56                   	push   %esi
  80020a:	53                   	push   %ebx
  80020b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80020e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800213:	8b 55 08             	mov    0x8(%ebp),%edx
  800216:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800219:	b8 06 00 00 00       	mov    $0x6,%eax
  80021e:	89 df                	mov    %ebx,%edi
  800220:	89 de                	mov    %ebx,%esi
  800222:	cd 30                	int    $0x30
	if(check && ret > 0)
  800224:	85 c0                	test   %eax,%eax
  800226:	7f 08                	jg     800230 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800228:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022b:	5b                   	pop    %ebx
  80022c:	5e                   	pop    %esi
  80022d:	5f                   	pop    %edi
  80022e:	5d                   	pop    %ebp
  80022f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	50                   	push   %eax
  800234:	6a 06                	push   $0x6
  800236:	68 6a 10 80 00       	push   $0x80106a
  80023b:	6a 23                	push   $0x23
  80023d:	68 87 10 80 00       	push   $0x801087
  800242:	e8 3e 01 00 00       	call   800385 <_panic>

00800247 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800247:	f3 0f 1e fb          	endbr32 
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	57                   	push   %edi
  80024f:	56                   	push   %esi
  800250:	53                   	push   %ebx
  800251:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800254:	bb 00 00 00 00       	mov    $0x0,%ebx
  800259:	8b 55 08             	mov    0x8(%ebp),%edx
  80025c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025f:	b8 08 00 00 00       	mov    $0x8,%eax
  800264:	89 df                	mov    %ebx,%edi
  800266:	89 de                	mov    %ebx,%esi
  800268:	cd 30                	int    $0x30
	if(check && ret > 0)
  80026a:	85 c0                	test   %eax,%eax
  80026c:	7f 08                	jg     800276 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800271:	5b                   	pop    %ebx
  800272:	5e                   	pop    %esi
  800273:	5f                   	pop    %edi
  800274:	5d                   	pop    %ebp
  800275:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800276:	83 ec 0c             	sub    $0xc,%esp
  800279:	50                   	push   %eax
  80027a:	6a 08                	push   $0x8
  80027c:	68 6a 10 80 00       	push   $0x80106a
  800281:	6a 23                	push   $0x23
  800283:	68 87 10 80 00       	push   $0x801087
  800288:	e8 f8 00 00 00       	call   800385 <_panic>

0080028d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028d:	f3 0f 1e fb          	endbr32 
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	57                   	push   %edi
  800295:	56                   	push   %esi
  800296:	53                   	push   %ebx
  800297:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80029a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029f:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a5:	b8 09 00 00 00       	mov    $0x9,%eax
  8002aa:	89 df                	mov    %ebx,%edi
  8002ac:	89 de                	mov    %ebx,%esi
  8002ae:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002b0:	85 c0                	test   %eax,%eax
  8002b2:	7f 08                	jg     8002bc <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b7:	5b                   	pop    %ebx
  8002b8:	5e                   	pop    %esi
  8002b9:	5f                   	pop    %edi
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002bc:	83 ec 0c             	sub    $0xc,%esp
  8002bf:	50                   	push   %eax
  8002c0:	6a 09                	push   $0x9
  8002c2:	68 6a 10 80 00       	push   $0x80106a
  8002c7:	6a 23                	push   $0x23
  8002c9:	68 87 10 80 00       	push   $0x801087
  8002ce:	e8 b2 00 00 00       	call   800385 <_panic>

008002d3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002d3:	f3 0f 1e fb          	endbr32 
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	57                   	push   %edi
  8002db:	56                   	push   %esi
  8002dc:	53                   	push   %ebx
  8002dd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002eb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002f0:	89 df                	mov    %ebx,%edi
  8002f2:	89 de                	mov    %ebx,%esi
  8002f4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002f6:	85 c0                	test   %eax,%eax
  8002f8:	7f 08                	jg     800302 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fd:	5b                   	pop    %ebx
  8002fe:	5e                   	pop    %esi
  8002ff:	5f                   	pop    %edi
  800300:	5d                   	pop    %ebp
  800301:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800302:	83 ec 0c             	sub    $0xc,%esp
  800305:	50                   	push   %eax
  800306:	6a 0a                	push   $0xa
  800308:	68 6a 10 80 00       	push   $0x80106a
  80030d:	6a 23                	push   $0x23
  80030f:	68 87 10 80 00       	push   $0x801087
  800314:	e8 6c 00 00 00       	call   800385 <_panic>

00800319 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800319:	f3 0f 1e fb          	endbr32 
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	57                   	push   %edi
  800321:	56                   	push   %esi
  800322:	53                   	push   %ebx
	asm volatile("int %1\n"
  800323:	8b 55 08             	mov    0x8(%ebp),%edx
  800326:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800329:	b8 0c 00 00 00       	mov    $0xc,%eax
  80032e:	be 00 00 00 00       	mov    $0x0,%esi
  800333:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800336:	8b 7d 14             	mov    0x14(%ebp),%edi
  800339:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80033b:	5b                   	pop    %ebx
  80033c:	5e                   	pop    %esi
  80033d:	5f                   	pop    %edi
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    

00800340 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800340:	f3 0f 1e fb          	endbr32 
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	57                   	push   %edi
  800348:	56                   	push   %esi
  800349:	53                   	push   %ebx
  80034a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80034d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800352:	8b 55 08             	mov    0x8(%ebp),%edx
  800355:	b8 0d 00 00 00       	mov    $0xd,%eax
  80035a:	89 cb                	mov    %ecx,%ebx
  80035c:	89 cf                	mov    %ecx,%edi
  80035e:	89 ce                	mov    %ecx,%esi
  800360:	cd 30                	int    $0x30
	if(check && ret > 0)
  800362:	85 c0                	test   %eax,%eax
  800364:	7f 08                	jg     80036e <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800366:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800369:	5b                   	pop    %ebx
  80036a:	5e                   	pop    %esi
  80036b:	5f                   	pop    %edi
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80036e:	83 ec 0c             	sub    $0xc,%esp
  800371:	50                   	push   %eax
  800372:	6a 0d                	push   $0xd
  800374:	68 6a 10 80 00       	push   $0x80106a
  800379:	6a 23                	push   $0x23
  80037b:	68 87 10 80 00       	push   $0x801087
  800380:	e8 00 00 00 00       	call   800385 <_panic>

00800385 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800385:	f3 0f 1e fb          	endbr32 
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	56                   	push   %esi
  80038d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80038e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800391:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800397:	e8 92 fd ff ff       	call   80012e <sys_getenvid>
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 75 0c             	pushl  0xc(%ebp)
  8003a2:	ff 75 08             	pushl  0x8(%ebp)
  8003a5:	56                   	push   %esi
  8003a6:	50                   	push   %eax
  8003a7:	68 98 10 80 00       	push   $0x801098
  8003ac:	e8 bb 00 00 00       	call   80046c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003b1:	83 c4 18             	add    $0x18,%esp
  8003b4:	53                   	push   %ebx
  8003b5:	ff 75 10             	pushl  0x10(%ebp)
  8003b8:	e8 5a 00 00 00       	call   800417 <vcprintf>
	cprintf("\n");
  8003bd:	c7 04 24 bb 10 80 00 	movl   $0x8010bb,(%esp)
  8003c4:	e8 a3 00 00 00       	call   80046c <cprintf>
  8003c9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003cc:	cc                   	int3   
  8003cd:	eb fd                	jmp    8003cc <_panic+0x47>

008003cf <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003cf:	f3 0f 1e fb          	endbr32 
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	53                   	push   %ebx
  8003d7:	83 ec 04             	sub    $0x4,%esp
  8003da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003dd:	8b 13                	mov    (%ebx),%edx
  8003df:	8d 42 01             	lea    0x1(%edx),%eax
  8003e2:	89 03                	mov    %eax,(%ebx)
  8003e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003eb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003f0:	74 09                	je     8003fb <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003f2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003f9:	c9                   	leave  
  8003fa:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003fb:	83 ec 08             	sub    $0x8,%esp
  8003fe:	68 ff 00 00 00       	push   $0xff
  800403:	8d 43 08             	lea    0x8(%ebx),%eax
  800406:	50                   	push   %eax
  800407:	e8 98 fc ff ff       	call   8000a4 <sys_cputs>
		b->idx = 0;
  80040c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800412:	83 c4 10             	add    $0x10,%esp
  800415:	eb db                	jmp    8003f2 <putch+0x23>

00800417 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800417:	f3 0f 1e fb          	endbr32 
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800424:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80042b:	00 00 00 
	b.cnt = 0;
  80042e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800435:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800438:	ff 75 0c             	pushl  0xc(%ebp)
  80043b:	ff 75 08             	pushl  0x8(%ebp)
  80043e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800444:	50                   	push   %eax
  800445:	68 cf 03 80 00       	push   $0x8003cf
  80044a:	e8 20 01 00 00       	call   80056f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80044f:	83 c4 08             	add    $0x8,%esp
  800452:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800458:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80045e:	50                   	push   %eax
  80045f:	e8 40 fc ff ff       	call   8000a4 <sys_cputs>

	return b.cnt;
}
  800464:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80046a:	c9                   	leave  
  80046b:	c3                   	ret    

0080046c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80046c:	f3 0f 1e fb          	endbr32 
  800470:	55                   	push   %ebp
  800471:	89 e5                	mov    %esp,%ebp
  800473:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800476:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800479:	50                   	push   %eax
  80047a:	ff 75 08             	pushl  0x8(%ebp)
  80047d:	e8 95 ff ff ff       	call   800417 <vcprintf>
	va_end(ap);

	return cnt;
}
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	57                   	push   %edi
  800488:	56                   	push   %esi
  800489:	53                   	push   %ebx
  80048a:	83 ec 1c             	sub    $0x1c,%esp
  80048d:	89 c7                	mov    %eax,%edi
  80048f:	89 d6                	mov    %edx,%esi
  800491:	8b 45 08             	mov    0x8(%ebp),%eax
  800494:	8b 55 0c             	mov    0xc(%ebp),%edx
  800497:	89 d1                	mov    %edx,%ecx
  800499:	89 c2                	mov    %eax,%edx
  80049b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80049e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8004a4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004aa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004b1:	39 c2                	cmp    %eax,%edx
  8004b3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8004b6:	72 3e                	jb     8004f6 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004b8:	83 ec 0c             	sub    $0xc,%esp
  8004bb:	ff 75 18             	pushl  0x18(%ebp)
  8004be:	83 eb 01             	sub    $0x1,%ebx
  8004c1:	53                   	push   %ebx
  8004c2:	50                   	push   %eax
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004cc:	ff 75 dc             	pushl  -0x24(%ebp)
  8004cf:	ff 75 d8             	pushl  -0x28(%ebp)
  8004d2:	e8 19 09 00 00       	call   800df0 <__udivdi3>
  8004d7:	83 c4 18             	add    $0x18,%esp
  8004da:	52                   	push   %edx
  8004db:	50                   	push   %eax
  8004dc:	89 f2                	mov    %esi,%edx
  8004de:	89 f8                	mov    %edi,%eax
  8004e0:	e8 9f ff ff ff       	call   800484 <printnum>
  8004e5:	83 c4 20             	add    $0x20,%esp
  8004e8:	eb 13                	jmp    8004fd <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	56                   	push   %esi
  8004ee:	ff 75 18             	pushl  0x18(%ebp)
  8004f1:	ff d7                	call   *%edi
  8004f3:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004f6:	83 eb 01             	sub    $0x1,%ebx
  8004f9:	85 db                	test   %ebx,%ebx
  8004fb:	7f ed                	jg     8004ea <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	56                   	push   %esi
  800501:	83 ec 04             	sub    $0x4,%esp
  800504:	ff 75 e4             	pushl  -0x1c(%ebp)
  800507:	ff 75 e0             	pushl  -0x20(%ebp)
  80050a:	ff 75 dc             	pushl  -0x24(%ebp)
  80050d:	ff 75 d8             	pushl  -0x28(%ebp)
  800510:	e8 eb 09 00 00       	call   800f00 <__umoddi3>
  800515:	83 c4 14             	add    $0x14,%esp
  800518:	0f be 80 bd 10 80 00 	movsbl 0x8010bd(%eax),%eax
  80051f:	50                   	push   %eax
  800520:	ff d7                	call   *%edi
}
  800522:	83 c4 10             	add    $0x10,%esp
  800525:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800528:	5b                   	pop    %ebx
  800529:	5e                   	pop    %esi
  80052a:	5f                   	pop    %edi
  80052b:	5d                   	pop    %ebp
  80052c:	c3                   	ret    

0080052d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80052d:	f3 0f 1e fb          	endbr32 
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800537:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80053b:	8b 10                	mov    (%eax),%edx
  80053d:	3b 50 04             	cmp    0x4(%eax),%edx
  800540:	73 0a                	jae    80054c <sprintputch+0x1f>
		*b->buf++ = ch;
  800542:	8d 4a 01             	lea    0x1(%edx),%ecx
  800545:	89 08                	mov    %ecx,(%eax)
  800547:	8b 45 08             	mov    0x8(%ebp),%eax
  80054a:	88 02                	mov    %al,(%edx)
}
  80054c:	5d                   	pop    %ebp
  80054d:	c3                   	ret    

0080054e <printfmt>:
{
  80054e:	f3 0f 1e fb          	endbr32 
  800552:	55                   	push   %ebp
  800553:	89 e5                	mov    %esp,%ebp
  800555:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800558:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80055b:	50                   	push   %eax
  80055c:	ff 75 10             	pushl  0x10(%ebp)
  80055f:	ff 75 0c             	pushl  0xc(%ebp)
  800562:	ff 75 08             	pushl  0x8(%ebp)
  800565:	e8 05 00 00 00       	call   80056f <vprintfmt>
}
  80056a:	83 c4 10             	add    $0x10,%esp
  80056d:	c9                   	leave  
  80056e:	c3                   	ret    

0080056f <vprintfmt>:
{
  80056f:	f3 0f 1e fb          	endbr32 
  800573:	55                   	push   %ebp
  800574:	89 e5                	mov    %esp,%ebp
  800576:	57                   	push   %edi
  800577:	56                   	push   %esi
  800578:	53                   	push   %ebx
  800579:	83 ec 3c             	sub    $0x3c,%esp
  80057c:	8b 75 08             	mov    0x8(%ebp),%esi
  80057f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800582:	8b 7d 10             	mov    0x10(%ebp),%edi
  800585:	e9 4a 03 00 00       	jmp    8008d4 <vprintfmt+0x365>
		padc = ' ';
  80058a:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80058e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800595:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80059c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8005a3:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005a8:	8d 47 01             	lea    0x1(%edi),%eax
  8005ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005ae:	0f b6 17             	movzbl (%edi),%edx
  8005b1:	8d 42 dd             	lea    -0x23(%edx),%eax
  8005b4:	3c 55                	cmp    $0x55,%al
  8005b6:	0f 87 de 03 00 00    	ja     80099a <vprintfmt+0x42b>
  8005bc:	0f b6 c0             	movzbl %al,%eax
  8005bf:	3e ff 24 85 00 12 80 	notrack jmp *0x801200(,%eax,4)
  8005c6:	00 
  8005c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005ca:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005ce:	eb d8                	jmp    8005a8 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d3:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005d7:	eb cf                	jmp    8005a8 <vprintfmt+0x39>
  8005d9:	0f b6 d2             	movzbl %dl,%edx
  8005dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005df:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005e7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005ea:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005ee:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005f1:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005f4:	83 f9 09             	cmp    $0x9,%ecx
  8005f7:	77 55                	ja     80064e <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005f9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005fc:	eb e9                	jmp    8005e7 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8b 00                	mov    (%eax),%eax
  800603:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 40 04             	lea    0x4(%eax),%eax
  80060c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80060f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800612:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800616:	79 90                	jns    8005a8 <vprintfmt+0x39>
				width = precision, precision = -1;
  800618:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80061e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800625:	eb 81                	jmp    8005a8 <vprintfmt+0x39>
  800627:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80062a:	85 c0                	test   %eax,%eax
  80062c:	ba 00 00 00 00       	mov    $0x0,%edx
  800631:	0f 49 d0             	cmovns %eax,%edx
  800634:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800637:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80063a:	e9 69 ff ff ff       	jmp    8005a8 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80063f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800642:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800649:	e9 5a ff ff ff       	jmp    8005a8 <vprintfmt+0x39>
  80064e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800651:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800654:	eb bc                	jmp    800612 <vprintfmt+0xa3>
			lflag++;
  800656:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800659:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80065c:	e9 47 ff ff ff       	jmp    8005a8 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800661:	8b 45 14             	mov    0x14(%ebp),%eax
  800664:	8d 78 04             	lea    0x4(%eax),%edi
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	ff 30                	pushl  (%eax)
  80066d:	ff d6                	call   *%esi
			break;
  80066f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800672:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800675:	e9 57 02 00 00       	jmp    8008d1 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8d 78 04             	lea    0x4(%eax),%edi
  800680:	8b 00                	mov    (%eax),%eax
  800682:	99                   	cltd   
  800683:	31 d0                	xor    %edx,%eax
  800685:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800687:	83 f8 0f             	cmp    $0xf,%eax
  80068a:	7f 23                	jg     8006af <vprintfmt+0x140>
  80068c:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  800693:	85 d2                	test   %edx,%edx
  800695:	74 18                	je     8006af <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800697:	52                   	push   %edx
  800698:	68 de 10 80 00       	push   $0x8010de
  80069d:	53                   	push   %ebx
  80069e:	56                   	push   %esi
  80069f:	e8 aa fe ff ff       	call   80054e <printfmt>
  8006a4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006a7:	89 7d 14             	mov    %edi,0x14(%ebp)
  8006aa:	e9 22 02 00 00       	jmp    8008d1 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8006af:	50                   	push   %eax
  8006b0:	68 d5 10 80 00       	push   $0x8010d5
  8006b5:	53                   	push   %ebx
  8006b6:	56                   	push   %esi
  8006b7:	e8 92 fe ff ff       	call   80054e <printfmt>
  8006bc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006bf:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8006c2:	e9 0a 02 00 00       	jmp    8008d1 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	83 c0 04             	add    $0x4,%eax
  8006cd:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8006d5:	85 d2                	test   %edx,%edx
  8006d7:	b8 ce 10 80 00       	mov    $0x8010ce,%eax
  8006dc:	0f 45 c2             	cmovne %edx,%eax
  8006df:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006e2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006e6:	7e 06                	jle    8006ee <vprintfmt+0x17f>
  8006e8:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006ec:	75 0d                	jne    8006fb <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ee:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006f1:	89 c7                	mov    %eax,%edi
  8006f3:	03 45 e0             	add    -0x20(%ebp),%eax
  8006f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f9:	eb 55                	jmp    800750 <vprintfmt+0x1e1>
  8006fb:	83 ec 08             	sub    $0x8,%esp
  8006fe:	ff 75 d8             	pushl  -0x28(%ebp)
  800701:	ff 75 cc             	pushl  -0x34(%ebp)
  800704:	e8 45 03 00 00       	call   800a4e <strnlen>
  800709:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80070c:	29 c2                	sub    %eax,%edx
  80070e:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800716:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80071a:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80071d:	85 ff                	test   %edi,%edi
  80071f:	7e 11                	jle    800732 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800721:	83 ec 08             	sub    $0x8,%esp
  800724:	53                   	push   %ebx
  800725:	ff 75 e0             	pushl  -0x20(%ebp)
  800728:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80072a:	83 ef 01             	sub    $0x1,%edi
  80072d:	83 c4 10             	add    $0x10,%esp
  800730:	eb eb                	jmp    80071d <vprintfmt+0x1ae>
  800732:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800735:	85 d2                	test   %edx,%edx
  800737:	b8 00 00 00 00       	mov    $0x0,%eax
  80073c:	0f 49 c2             	cmovns %edx,%eax
  80073f:	29 c2                	sub    %eax,%edx
  800741:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800744:	eb a8                	jmp    8006ee <vprintfmt+0x17f>
					putch(ch, putdat);
  800746:	83 ec 08             	sub    $0x8,%esp
  800749:	53                   	push   %ebx
  80074a:	52                   	push   %edx
  80074b:	ff d6                	call   *%esi
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800753:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800755:	83 c7 01             	add    $0x1,%edi
  800758:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80075c:	0f be d0             	movsbl %al,%edx
  80075f:	85 d2                	test   %edx,%edx
  800761:	74 4b                	je     8007ae <vprintfmt+0x23f>
  800763:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800767:	78 06                	js     80076f <vprintfmt+0x200>
  800769:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80076d:	78 1e                	js     80078d <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80076f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800773:	74 d1                	je     800746 <vprintfmt+0x1d7>
  800775:	0f be c0             	movsbl %al,%eax
  800778:	83 e8 20             	sub    $0x20,%eax
  80077b:	83 f8 5e             	cmp    $0x5e,%eax
  80077e:	76 c6                	jbe    800746 <vprintfmt+0x1d7>
					putch('?', putdat);
  800780:	83 ec 08             	sub    $0x8,%esp
  800783:	53                   	push   %ebx
  800784:	6a 3f                	push   $0x3f
  800786:	ff d6                	call   *%esi
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	eb c3                	jmp    800750 <vprintfmt+0x1e1>
  80078d:	89 cf                	mov    %ecx,%edi
  80078f:	eb 0e                	jmp    80079f <vprintfmt+0x230>
				putch(' ', putdat);
  800791:	83 ec 08             	sub    $0x8,%esp
  800794:	53                   	push   %ebx
  800795:	6a 20                	push   $0x20
  800797:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800799:	83 ef 01             	sub    $0x1,%edi
  80079c:	83 c4 10             	add    $0x10,%esp
  80079f:	85 ff                	test   %edi,%edi
  8007a1:	7f ee                	jg     800791 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8007a3:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007a6:	89 45 14             	mov    %eax,0x14(%ebp)
  8007a9:	e9 23 01 00 00       	jmp    8008d1 <vprintfmt+0x362>
  8007ae:	89 cf                	mov    %ecx,%edi
  8007b0:	eb ed                	jmp    80079f <vprintfmt+0x230>
	if (lflag >= 2)
  8007b2:	83 f9 01             	cmp    $0x1,%ecx
  8007b5:	7f 1b                	jg     8007d2 <vprintfmt+0x263>
	else if (lflag)
  8007b7:	85 c9                	test   %ecx,%ecx
  8007b9:	74 63                	je     80081e <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8007bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007be:	8b 00                	mov    (%eax),%eax
  8007c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c3:	99                   	cltd   
  8007c4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ca:	8d 40 04             	lea    0x4(%eax),%eax
  8007cd:	89 45 14             	mov    %eax,0x14(%ebp)
  8007d0:	eb 17                	jmp    8007e9 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	8b 50 04             	mov    0x4(%eax),%edx
  8007d8:	8b 00                	mov    (%eax),%eax
  8007da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007dd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e3:	8d 40 08             	lea    0x8(%eax),%eax
  8007e6:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007e9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007ec:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007ef:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007f4:	85 c9                	test   %ecx,%ecx
  8007f6:	0f 89 bb 00 00 00    	jns    8008b7 <vprintfmt+0x348>
				putch('-', putdat);
  8007fc:	83 ec 08             	sub    $0x8,%esp
  8007ff:	53                   	push   %ebx
  800800:	6a 2d                	push   $0x2d
  800802:	ff d6                	call   *%esi
				num = -(long long) num;
  800804:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800807:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80080a:	f7 da                	neg    %edx
  80080c:	83 d1 00             	adc    $0x0,%ecx
  80080f:	f7 d9                	neg    %ecx
  800811:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800814:	b8 0a 00 00 00       	mov    $0xa,%eax
  800819:	e9 99 00 00 00       	jmp    8008b7 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80081e:	8b 45 14             	mov    0x14(%ebp),%eax
  800821:	8b 00                	mov    (%eax),%eax
  800823:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800826:	99                   	cltd   
  800827:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80082a:	8b 45 14             	mov    0x14(%ebp),%eax
  80082d:	8d 40 04             	lea    0x4(%eax),%eax
  800830:	89 45 14             	mov    %eax,0x14(%ebp)
  800833:	eb b4                	jmp    8007e9 <vprintfmt+0x27a>
	if (lflag >= 2)
  800835:	83 f9 01             	cmp    $0x1,%ecx
  800838:	7f 1b                	jg     800855 <vprintfmt+0x2e6>
	else if (lflag)
  80083a:	85 c9                	test   %ecx,%ecx
  80083c:	74 2c                	je     80086a <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80083e:	8b 45 14             	mov    0x14(%ebp),%eax
  800841:	8b 10                	mov    (%eax),%edx
  800843:	b9 00 00 00 00       	mov    $0x0,%ecx
  800848:	8d 40 04             	lea    0x4(%eax),%eax
  80084b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80084e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800853:	eb 62                	jmp    8008b7 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800855:	8b 45 14             	mov    0x14(%ebp),%eax
  800858:	8b 10                	mov    (%eax),%edx
  80085a:	8b 48 04             	mov    0x4(%eax),%ecx
  80085d:	8d 40 08             	lea    0x8(%eax),%eax
  800860:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800863:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800868:	eb 4d                	jmp    8008b7 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80086a:	8b 45 14             	mov    0x14(%ebp),%eax
  80086d:	8b 10                	mov    (%eax),%edx
  80086f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800874:	8d 40 04             	lea    0x4(%eax),%eax
  800877:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80087a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80087f:	eb 36                	jmp    8008b7 <vprintfmt+0x348>
	if (lflag >= 2)
  800881:	83 f9 01             	cmp    $0x1,%ecx
  800884:	7f 17                	jg     80089d <vprintfmt+0x32e>
	else if (lflag)
  800886:	85 c9                	test   %ecx,%ecx
  800888:	74 6e                	je     8008f8 <vprintfmt+0x389>
		return va_arg(*ap, long);
  80088a:	8b 45 14             	mov    0x14(%ebp),%eax
  80088d:	8b 10                	mov    (%eax),%edx
  80088f:	89 d0                	mov    %edx,%eax
  800891:	99                   	cltd   
  800892:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800895:	8d 49 04             	lea    0x4(%ecx),%ecx
  800898:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80089b:	eb 11                	jmp    8008ae <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  80089d:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a0:	8b 50 04             	mov    0x4(%eax),%edx
  8008a3:	8b 00                	mov    (%eax),%eax
  8008a5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008a8:	8d 49 08             	lea    0x8(%ecx),%ecx
  8008ab:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8008ae:	89 d1                	mov    %edx,%ecx
  8008b0:	89 c2                	mov    %eax,%edx
            base = 8;
  8008b2:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008b7:	83 ec 0c             	sub    $0xc,%esp
  8008ba:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008be:	57                   	push   %edi
  8008bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8008c2:	50                   	push   %eax
  8008c3:	51                   	push   %ecx
  8008c4:	52                   	push   %edx
  8008c5:	89 da                	mov    %ebx,%edx
  8008c7:	89 f0                	mov    %esi,%eax
  8008c9:	e8 b6 fb ff ff       	call   800484 <printnum>
			break;
  8008ce:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008d4:	83 c7 01             	add    $0x1,%edi
  8008d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008db:	83 f8 25             	cmp    $0x25,%eax
  8008de:	0f 84 a6 fc ff ff    	je     80058a <vprintfmt+0x1b>
			if (ch == '\0')
  8008e4:	85 c0                	test   %eax,%eax
  8008e6:	0f 84 ce 00 00 00    	je     8009ba <vprintfmt+0x44b>
			putch(ch, putdat);
  8008ec:	83 ec 08             	sub    $0x8,%esp
  8008ef:	53                   	push   %ebx
  8008f0:	50                   	push   %eax
  8008f1:	ff d6                	call   *%esi
  8008f3:	83 c4 10             	add    $0x10,%esp
  8008f6:	eb dc                	jmp    8008d4 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8008f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fb:	8b 10                	mov    (%eax),%edx
  8008fd:	89 d0                	mov    %edx,%eax
  8008ff:	99                   	cltd   
  800900:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800903:	8d 49 04             	lea    0x4(%ecx),%ecx
  800906:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800909:	eb a3                	jmp    8008ae <vprintfmt+0x33f>
			putch('0', putdat);
  80090b:	83 ec 08             	sub    $0x8,%esp
  80090e:	53                   	push   %ebx
  80090f:	6a 30                	push   $0x30
  800911:	ff d6                	call   *%esi
			putch('x', putdat);
  800913:	83 c4 08             	add    $0x8,%esp
  800916:	53                   	push   %ebx
  800917:	6a 78                	push   $0x78
  800919:	ff d6                	call   *%esi
			num = (unsigned long long)
  80091b:	8b 45 14             	mov    0x14(%ebp),%eax
  80091e:	8b 10                	mov    (%eax),%edx
  800920:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800925:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800928:	8d 40 04             	lea    0x4(%eax),%eax
  80092b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80092e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800933:	eb 82                	jmp    8008b7 <vprintfmt+0x348>
	if (lflag >= 2)
  800935:	83 f9 01             	cmp    $0x1,%ecx
  800938:	7f 1e                	jg     800958 <vprintfmt+0x3e9>
	else if (lflag)
  80093a:	85 c9                	test   %ecx,%ecx
  80093c:	74 32                	je     800970 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80093e:	8b 45 14             	mov    0x14(%ebp),%eax
  800941:	8b 10                	mov    (%eax),%edx
  800943:	b9 00 00 00 00       	mov    $0x0,%ecx
  800948:	8d 40 04             	lea    0x4(%eax),%eax
  80094b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80094e:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800953:	e9 5f ff ff ff       	jmp    8008b7 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800958:	8b 45 14             	mov    0x14(%ebp),%eax
  80095b:	8b 10                	mov    (%eax),%edx
  80095d:	8b 48 04             	mov    0x4(%eax),%ecx
  800960:	8d 40 08             	lea    0x8(%eax),%eax
  800963:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800966:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80096b:	e9 47 ff ff ff       	jmp    8008b7 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800970:	8b 45 14             	mov    0x14(%ebp),%eax
  800973:	8b 10                	mov    (%eax),%edx
  800975:	b9 00 00 00 00       	mov    $0x0,%ecx
  80097a:	8d 40 04             	lea    0x4(%eax),%eax
  80097d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800980:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800985:	e9 2d ff ff ff       	jmp    8008b7 <vprintfmt+0x348>
			putch(ch, putdat);
  80098a:	83 ec 08             	sub    $0x8,%esp
  80098d:	53                   	push   %ebx
  80098e:	6a 25                	push   $0x25
  800990:	ff d6                	call   *%esi
			break;
  800992:	83 c4 10             	add    $0x10,%esp
  800995:	e9 37 ff ff ff       	jmp    8008d1 <vprintfmt+0x362>
			putch('%', putdat);
  80099a:	83 ec 08             	sub    $0x8,%esp
  80099d:	53                   	push   %ebx
  80099e:	6a 25                	push   $0x25
  8009a0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009a2:	83 c4 10             	add    $0x10,%esp
  8009a5:	89 f8                	mov    %edi,%eax
  8009a7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009ab:	74 05                	je     8009b2 <vprintfmt+0x443>
  8009ad:	83 e8 01             	sub    $0x1,%eax
  8009b0:	eb f5                	jmp    8009a7 <vprintfmt+0x438>
  8009b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009b5:	e9 17 ff ff ff       	jmp    8008d1 <vprintfmt+0x362>
}
  8009ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009bd:	5b                   	pop    %ebx
  8009be:	5e                   	pop    %esi
  8009bf:	5f                   	pop    %edi
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009c2:	f3 0f 1e fb          	endbr32 
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	83 ec 18             	sub    $0x18,%esp
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009d5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009d9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009e3:	85 c0                	test   %eax,%eax
  8009e5:	74 26                	je     800a0d <vsnprintf+0x4b>
  8009e7:	85 d2                	test   %edx,%edx
  8009e9:	7e 22                	jle    800a0d <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009eb:	ff 75 14             	pushl  0x14(%ebp)
  8009ee:	ff 75 10             	pushl  0x10(%ebp)
  8009f1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009f4:	50                   	push   %eax
  8009f5:	68 2d 05 80 00       	push   $0x80052d
  8009fa:	e8 70 fb ff ff       	call   80056f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a02:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a08:	83 c4 10             	add    $0x10,%esp
}
  800a0b:	c9                   	leave  
  800a0c:	c3                   	ret    
		return -E_INVAL;
  800a0d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a12:	eb f7                	jmp    800a0b <vsnprintf+0x49>

00800a14 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a14:	f3 0f 1e fb          	endbr32 
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a1e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a21:	50                   	push   %eax
  800a22:	ff 75 10             	pushl  0x10(%ebp)
  800a25:	ff 75 0c             	pushl  0xc(%ebp)
  800a28:	ff 75 08             	pushl  0x8(%ebp)
  800a2b:	e8 92 ff ff ff       	call   8009c2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a30:	c9                   	leave  
  800a31:	c3                   	ret    

00800a32 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a32:	f3 0f 1e fb          	endbr32 
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a41:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a45:	74 05                	je     800a4c <strlen+0x1a>
		n++;
  800a47:	83 c0 01             	add    $0x1,%eax
  800a4a:	eb f5                	jmp    800a41 <strlen+0xf>
	return n;
}
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a4e:	f3 0f 1e fb          	endbr32 
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a58:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a60:	39 d0                	cmp    %edx,%eax
  800a62:	74 0d                	je     800a71 <strnlen+0x23>
  800a64:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a68:	74 05                	je     800a6f <strnlen+0x21>
		n++;
  800a6a:	83 c0 01             	add    $0x1,%eax
  800a6d:	eb f1                	jmp    800a60 <strnlen+0x12>
  800a6f:	89 c2                	mov    %eax,%edx
	return n;
}
  800a71:	89 d0                	mov    %edx,%eax
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a75:	f3 0f 1e fb          	endbr32 
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	53                   	push   %ebx
  800a7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
  800a88:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a8c:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a8f:	83 c0 01             	add    $0x1,%eax
  800a92:	84 d2                	test   %dl,%dl
  800a94:	75 f2                	jne    800a88 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a96:	89 c8                	mov    %ecx,%eax
  800a98:	5b                   	pop    %ebx
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a9b:	f3 0f 1e fb          	endbr32 
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	53                   	push   %ebx
  800aa3:	83 ec 10             	sub    $0x10,%esp
  800aa6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aa9:	53                   	push   %ebx
  800aaa:	e8 83 ff ff ff       	call   800a32 <strlen>
  800aaf:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800ab2:	ff 75 0c             	pushl  0xc(%ebp)
  800ab5:	01 d8                	add    %ebx,%eax
  800ab7:	50                   	push   %eax
  800ab8:	e8 b8 ff ff ff       	call   800a75 <strcpy>
	return dst;
}
  800abd:	89 d8                	mov    %ebx,%eax
  800abf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ac2:	c9                   	leave  
  800ac3:	c3                   	ret    

00800ac4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ac4:	f3 0f 1e fb          	endbr32 
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
  800acd:	8b 75 08             	mov    0x8(%ebp),%esi
  800ad0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad3:	89 f3                	mov    %esi,%ebx
  800ad5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ad8:	89 f0                	mov    %esi,%eax
  800ada:	39 d8                	cmp    %ebx,%eax
  800adc:	74 11                	je     800aef <strncpy+0x2b>
		*dst++ = *src;
  800ade:	83 c0 01             	add    $0x1,%eax
  800ae1:	0f b6 0a             	movzbl (%edx),%ecx
  800ae4:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ae7:	80 f9 01             	cmp    $0x1,%cl
  800aea:	83 da ff             	sbb    $0xffffffff,%edx
  800aed:	eb eb                	jmp    800ada <strncpy+0x16>
	}
	return ret;
}
  800aef:	89 f0                	mov    %esi,%eax
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800af5:	f3 0f 1e fb          	endbr32 
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	56                   	push   %esi
  800afd:	53                   	push   %ebx
  800afe:	8b 75 08             	mov    0x8(%ebp),%esi
  800b01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b04:	8b 55 10             	mov    0x10(%ebp),%edx
  800b07:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b09:	85 d2                	test   %edx,%edx
  800b0b:	74 21                	je     800b2e <strlcpy+0x39>
  800b0d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b11:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b13:	39 c2                	cmp    %eax,%edx
  800b15:	74 14                	je     800b2b <strlcpy+0x36>
  800b17:	0f b6 19             	movzbl (%ecx),%ebx
  800b1a:	84 db                	test   %bl,%bl
  800b1c:	74 0b                	je     800b29 <strlcpy+0x34>
			*dst++ = *src++;
  800b1e:	83 c1 01             	add    $0x1,%ecx
  800b21:	83 c2 01             	add    $0x1,%edx
  800b24:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b27:	eb ea                	jmp    800b13 <strlcpy+0x1e>
  800b29:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b2b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b2e:	29 f0                	sub    %esi,%eax
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b34:	f3 0f 1e fb          	endbr32 
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b3e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b41:	0f b6 01             	movzbl (%ecx),%eax
  800b44:	84 c0                	test   %al,%al
  800b46:	74 0c                	je     800b54 <strcmp+0x20>
  800b48:	3a 02                	cmp    (%edx),%al
  800b4a:	75 08                	jne    800b54 <strcmp+0x20>
		p++, q++;
  800b4c:	83 c1 01             	add    $0x1,%ecx
  800b4f:	83 c2 01             	add    $0x1,%edx
  800b52:	eb ed                	jmp    800b41 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b54:	0f b6 c0             	movzbl %al,%eax
  800b57:	0f b6 12             	movzbl (%edx),%edx
  800b5a:	29 d0                	sub    %edx,%eax
}
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b5e:	f3 0f 1e fb          	endbr32 
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	53                   	push   %ebx
  800b66:	8b 45 08             	mov    0x8(%ebp),%eax
  800b69:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6c:	89 c3                	mov    %eax,%ebx
  800b6e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b71:	eb 06                	jmp    800b79 <strncmp+0x1b>
		n--, p++, q++;
  800b73:	83 c0 01             	add    $0x1,%eax
  800b76:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b79:	39 d8                	cmp    %ebx,%eax
  800b7b:	74 16                	je     800b93 <strncmp+0x35>
  800b7d:	0f b6 08             	movzbl (%eax),%ecx
  800b80:	84 c9                	test   %cl,%cl
  800b82:	74 04                	je     800b88 <strncmp+0x2a>
  800b84:	3a 0a                	cmp    (%edx),%cl
  800b86:	74 eb                	je     800b73 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b88:	0f b6 00             	movzbl (%eax),%eax
  800b8b:	0f b6 12             	movzbl (%edx),%edx
  800b8e:	29 d0                	sub    %edx,%eax
}
  800b90:	5b                   	pop    %ebx
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    
		return 0;
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
  800b98:	eb f6                	jmp    800b90 <strncmp+0x32>

00800b9a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b9a:	f3 0f 1e fb          	endbr32 
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ba8:	0f b6 10             	movzbl (%eax),%edx
  800bab:	84 d2                	test   %dl,%dl
  800bad:	74 09                	je     800bb8 <strchr+0x1e>
		if (*s == c)
  800baf:	38 ca                	cmp    %cl,%dl
  800bb1:	74 0a                	je     800bbd <strchr+0x23>
	for (; *s; s++)
  800bb3:	83 c0 01             	add    $0x1,%eax
  800bb6:	eb f0                	jmp    800ba8 <strchr+0xe>
			return (char *) s;
	return 0;
  800bb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bbf:	f3 0f 1e fb          	endbr32 
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bcd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bd0:	38 ca                	cmp    %cl,%dl
  800bd2:	74 09                	je     800bdd <strfind+0x1e>
  800bd4:	84 d2                	test   %dl,%dl
  800bd6:	74 05                	je     800bdd <strfind+0x1e>
	for (; *s; s++)
  800bd8:	83 c0 01             	add    $0x1,%eax
  800bdb:	eb f0                	jmp    800bcd <strfind+0xe>
			break;
	return (char *) s;
}
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bdf:	f3 0f 1e fb          	endbr32 
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bec:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bef:	85 c9                	test   %ecx,%ecx
  800bf1:	74 31                	je     800c24 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bf3:	89 f8                	mov    %edi,%eax
  800bf5:	09 c8                	or     %ecx,%eax
  800bf7:	a8 03                	test   $0x3,%al
  800bf9:	75 23                	jne    800c1e <memset+0x3f>
		c &= 0xFF;
  800bfb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bff:	89 d3                	mov    %edx,%ebx
  800c01:	c1 e3 08             	shl    $0x8,%ebx
  800c04:	89 d0                	mov    %edx,%eax
  800c06:	c1 e0 18             	shl    $0x18,%eax
  800c09:	89 d6                	mov    %edx,%esi
  800c0b:	c1 e6 10             	shl    $0x10,%esi
  800c0e:	09 f0                	or     %esi,%eax
  800c10:	09 c2                	or     %eax,%edx
  800c12:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c14:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c17:	89 d0                	mov    %edx,%eax
  800c19:	fc                   	cld    
  800c1a:	f3 ab                	rep stos %eax,%es:(%edi)
  800c1c:	eb 06                	jmp    800c24 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c21:	fc                   	cld    
  800c22:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c24:	89 f8                	mov    %edi,%eax
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c2b:	f3 0f 1e fb          	endbr32 
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	57                   	push   %edi
  800c33:	56                   	push   %esi
  800c34:	8b 45 08             	mov    0x8(%ebp),%eax
  800c37:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c3a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c3d:	39 c6                	cmp    %eax,%esi
  800c3f:	73 32                	jae    800c73 <memmove+0x48>
  800c41:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c44:	39 c2                	cmp    %eax,%edx
  800c46:	76 2b                	jbe    800c73 <memmove+0x48>
		s += n;
		d += n;
  800c48:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c4b:	89 fe                	mov    %edi,%esi
  800c4d:	09 ce                	or     %ecx,%esi
  800c4f:	09 d6                	or     %edx,%esi
  800c51:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c57:	75 0e                	jne    800c67 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c59:	83 ef 04             	sub    $0x4,%edi
  800c5c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c5f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c62:	fd                   	std    
  800c63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c65:	eb 09                	jmp    800c70 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c67:	83 ef 01             	sub    $0x1,%edi
  800c6a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c6d:	fd                   	std    
  800c6e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c70:	fc                   	cld    
  800c71:	eb 1a                	jmp    800c8d <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c73:	89 c2                	mov    %eax,%edx
  800c75:	09 ca                	or     %ecx,%edx
  800c77:	09 f2                	or     %esi,%edx
  800c79:	f6 c2 03             	test   $0x3,%dl
  800c7c:	75 0a                	jne    800c88 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c7e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c81:	89 c7                	mov    %eax,%edi
  800c83:	fc                   	cld    
  800c84:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c86:	eb 05                	jmp    800c8d <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c88:	89 c7                	mov    %eax,%edi
  800c8a:	fc                   	cld    
  800c8b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c91:	f3 0f 1e fb          	endbr32 
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c9b:	ff 75 10             	pushl  0x10(%ebp)
  800c9e:	ff 75 0c             	pushl  0xc(%ebp)
  800ca1:	ff 75 08             	pushl  0x8(%ebp)
  800ca4:	e8 82 ff ff ff       	call   800c2b <memmove>
}
  800ca9:	c9                   	leave  
  800caa:	c3                   	ret    

00800cab <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cab:	f3 0f 1e fb          	endbr32 
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	56                   	push   %esi
  800cb3:	53                   	push   %ebx
  800cb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cba:	89 c6                	mov    %eax,%esi
  800cbc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cbf:	39 f0                	cmp    %esi,%eax
  800cc1:	74 1c                	je     800cdf <memcmp+0x34>
		if (*s1 != *s2)
  800cc3:	0f b6 08             	movzbl (%eax),%ecx
  800cc6:	0f b6 1a             	movzbl (%edx),%ebx
  800cc9:	38 d9                	cmp    %bl,%cl
  800ccb:	75 08                	jne    800cd5 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ccd:	83 c0 01             	add    $0x1,%eax
  800cd0:	83 c2 01             	add    $0x1,%edx
  800cd3:	eb ea                	jmp    800cbf <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800cd5:	0f b6 c1             	movzbl %cl,%eax
  800cd8:	0f b6 db             	movzbl %bl,%ebx
  800cdb:	29 d8                	sub    %ebx,%eax
  800cdd:	eb 05                	jmp    800ce4 <memcmp+0x39>
	}

	return 0;
  800cdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ce8:	f3 0f 1e fb          	endbr32 
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cf5:	89 c2                	mov    %eax,%edx
  800cf7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cfa:	39 d0                	cmp    %edx,%eax
  800cfc:	73 09                	jae    800d07 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cfe:	38 08                	cmp    %cl,(%eax)
  800d00:	74 05                	je     800d07 <memfind+0x1f>
	for (; s < ends; s++)
  800d02:	83 c0 01             	add    $0x1,%eax
  800d05:	eb f3                	jmp    800cfa <memfind+0x12>
			break;
	return (void *) s;
}
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d09:	f3 0f 1e fb          	endbr32 
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d19:	eb 03                	jmp    800d1e <strtol+0x15>
		s++;
  800d1b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d1e:	0f b6 01             	movzbl (%ecx),%eax
  800d21:	3c 20                	cmp    $0x20,%al
  800d23:	74 f6                	je     800d1b <strtol+0x12>
  800d25:	3c 09                	cmp    $0x9,%al
  800d27:	74 f2                	je     800d1b <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d29:	3c 2b                	cmp    $0x2b,%al
  800d2b:	74 2a                	je     800d57 <strtol+0x4e>
	int neg = 0;
  800d2d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d32:	3c 2d                	cmp    $0x2d,%al
  800d34:	74 2b                	je     800d61 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d36:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d3c:	75 0f                	jne    800d4d <strtol+0x44>
  800d3e:	80 39 30             	cmpb   $0x30,(%ecx)
  800d41:	74 28                	je     800d6b <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d43:	85 db                	test   %ebx,%ebx
  800d45:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d4a:	0f 44 d8             	cmove  %eax,%ebx
  800d4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d52:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d55:	eb 46                	jmp    800d9d <strtol+0x94>
		s++;
  800d57:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d5a:	bf 00 00 00 00       	mov    $0x0,%edi
  800d5f:	eb d5                	jmp    800d36 <strtol+0x2d>
		s++, neg = 1;
  800d61:	83 c1 01             	add    $0x1,%ecx
  800d64:	bf 01 00 00 00       	mov    $0x1,%edi
  800d69:	eb cb                	jmp    800d36 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d6b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d6f:	74 0e                	je     800d7f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d71:	85 db                	test   %ebx,%ebx
  800d73:	75 d8                	jne    800d4d <strtol+0x44>
		s++, base = 8;
  800d75:	83 c1 01             	add    $0x1,%ecx
  800d78:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d7d:	eb ce                	jmp    800d4d <strtol+0x44>
		s += 2, base = 16;
  800d7f:	83 c1 02             	add    $0x2,%ecx
  800d82:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d87:	eb c4                	jmp    800d4d <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d89:	0f be d2             	movsbl %dl,%edx
  800d8c:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d8f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d92:	7d 3a                	jge    800dce <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d94:	83 c1 01             	add    $0x1,%ecx
  800d97:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d9b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d9d:	0f b6 11             	movzbl (%ecx),%edx
  800da0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800da3:	89 f3                	mov    %esi,%ebx
  800da5:	80 fb 09             	cmp    $0x9,%bl
  800da8:	76 df                	jbe    800d89 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800daa:	8d 72 9f             	lea    -0x61(%edx),%esi
  800dad:	89 f3                	mov    %esi,%ebx
  800daf:	80 fb 19             	cmp    $0x19,%bl
  800db2:	77 08                	ja     800dbc <strtol+0xb3>
			dig = *s - 'a' + 10;
  800db4:	0f be d2             	movsbl %dl,%edx
  800db7:	83 ea 57             	sub    $0x57,%edx
  800dba:	eb d3                	jmp    800d8f <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800dbc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dbf:	89 f3                	mov    %esi,%ebx
  800dc1:	80 fb 19             	cmp    $0x19,%bl
  800dc4:	77 08                	ja     800dce <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dc6:	0f be d2             	movsbl %dl,%edx
  800dc9:	83 ea 37             	sub    $0x37,%edx
  800dcc:	eb c1                	jmp    800d8f <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dce:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dd2:	74 05                	je     800dd9 <strtol+0xd0>
		*endptr = (char *) s;
  800dd4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dd7:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800dd9:	89 c2                	mov    %eax,%edx
  800ddb:	f7 da                	neg    %edx
  800ddd:	85 ff                	test   %edi,%edi
  800ddf:	0f 45 c2             	cmovne %edx,%eax
}
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    
  800de7:	66 90                	xchg   %ax,%ax
  800de9:	66 90                	xchg   %ax,%ax
  800deb:	66 90                	xchg   %ax,%ax
  800ded:	66 90                	xchg   %ax,%ax
  800def:	90                   	nop

00800df0 <__udivdi3>:
  800df0:	f3 0f 1e fb          	endbr32 
  800df4:	55                   	push   %ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	83 ec 1c             	sub    $0x1c,%esp
  800dfb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800dff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e03:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e07:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e0b:	85 d2                	test   %edx,%edx
  800e0d:	75 19                	jne    800e28 <__udivdi3+0x38>
  800e0f:	39 f3                	cmp    %esi,%ebx
  800e11:	76 4d                	jbe    800e60 <__udivdi3+0x70>
  800e13:	31 ff                	xor    %edi,%edi
  800e15:	89 e8                	mov    %ebp,%eax
  800e17:	89 f2                	mov    %esi,%edx
  800e19:	f7 f3                	div    %ebx
  800e1b:	89 fa                	mov    %edi,%edx
  800e1d:	83 c4 1c             	add    $0x1c,%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    
  800e25:	8d 76 00             	lea    0x0(%esi),%esi
  800e28:	39 f2                	cmp    %esi,%edx
  800e2a:	76 14                	jbe    800e40 <__udivdi3+0x50>
  800e2c:	31 ff                	xor    %edi,%edi
  800e2e:	31 c0                	xor    %eax,%eax
  800e30:	89 fa                	mov    %edi,%edx
  800e32:	83 c4 1c             	add    $0x1c,%esp
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    
  800e3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e40:	0f bd fa             	bsr    %edx,%edi
  800e43:	83 f7 1f             	xor    $0x1f,%edi
  800e46:	75 48                	jne    800e90 <__udivdi3+0xa0>
  800e48:	39 f2                	cmp    %esi,%edx
  800e4a:	72 06                	jb     800e52 <__udivdi3+0x62>
  800e4c:	31 c0                	xor    %eax,%eax
  800e4e:	39 eb                	cmp    %ebp,%ebx
  800e50:	77 de                	ja     800e30 <__udivdi3+0x40>
  800e52:	b8 01 00 00 00       	mov    $0x1,%eax
  800e57:	eb d7                	jmp    800e30 <__udivdi3+0x40>
  800e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e60:	89 d9                	mov    %ebx,%ecx
  800e62:	85 db                	test   %ebx,%ebx
  800e64:	75 0b                	jne    800e71 <__udivdi3+0x81>
  800e66:	b8 01 00 00 00       	mov    $0x1,%eax
  800e6b:	31 d2                	xor    %edx,%edx
  800e6d:	f7 f3                	div    %ebx
  800e6f:	89 c1                	mov    %eax,%ecx
  800e71:	31 d2                	xor    %edx,%edx
  800e73:	89 f0                	mov    %esi,%eax
  800e75:	f7 f1                	div    %ecx
  800e77:	89 c6                	mov    %eax,%esi
  800e79:	89 e8                	mov    %ebp,%eax
  800e7b:	89 f7                	mov    %esi,%edi
  800e7d:	f7 f1                	div    %ecx
  800e7f:	89 fa                	mov    %edi,%edx
  800e81:	83 c4 1c             	add    $0x1c,%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    
  800e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e90:	89 f9                	mov    %edi,%ecx
  800e92:	b8 20 00 00 00       	mov    $0x20,%eax
  800e97:	29 f8                	sub    %edi,%eax
  800e99:	d3 e2                	shl    %cl,%edx
  800e9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e9f:	89 c1                	mov    %eax,%ecx
  800ea1:	89 da                	mov    %ebx,%edx
  800ea3:	d3 ea                	shr    %cl,%edx
  800ea5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ea9:	09 d1                	or     %edx,%ecx
  800eab:	89 f2                	mov    %esi,%edx
  800ead:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800eb1:	89 f9                	mov    %edi,%ecx
  800eb3:	d3 e3                	shl    %cl,%ebx
  800eb5:	89 c1                	mov    %eax,%ecx
  800eb7:	d3 ea                	shr    %cl,%edx
  800eb9:	89 f9                	mov    %edi,%ecx
  800ebb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ebf:	89 eb                	mov    %ebp,%ebx
  800ec1:	d3 e6                	shl    %cl,%esi
  800ec3:	89 c1                	mov    %eax,%ecx
  800ec5:	d3 eb                	shr    %cl,%ebx
  800ec7:	09 de                	or     %ebx,%esi
  800ec9:	89 f0                	mov    %esi,%eax
  800ecb:	f7 74 24 08          	divl   0x8(%esp)
  800ecf:	89 d6                	mov    %edx,%esi
  800ed1:	89 c3                	mov    %eax,%ebx
  800ed3:	f7 64 24 0c          	mull   0xc(%esp)
  800ed7:	39 d6                	cmp    %edx,%esi
  800ed9:	72 15                	jb     800ef0 <__udivdi3+0x100>
  800edb:	89 f9                	mov    %edi,%ecx
  800edd:	d3 e5                	shl    %cl,%ebp
  800edf:	39 c5                	cmp    %eax,%ebp
  800ee1:	73 04                	jae    800ee7 <__udivdi3+0xf7>
  800ee3:	39 d6                	cmp    %edx,%esi
  800ee5:	74 09                	je     800ef0 <__udivdi3+0x100>
  800ee7:	89 d8                	mov    %ebx,%eax
  800ee9:	31 ff                	xor    %edi,%edi
  800eeb:	e9 40 ff ff ff       	jmp    800e30 <__udivdi3+0x40>
  800ef0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ef3:	31 ff                	xor    %edi,%edi
  800ef5:	e9 36 ff ff ff       	jmp    800e30 <__udivdi3+0x40>
  800efa:	66 90                	xchg   %ax,%ax
  800efc:	66 90                	xchg   %ax,%ax
  800efe:	66 90                	xchg   %ax,%ax

00800f00 <__umoddi3>:
  800f00:	f3 0f 1e fb          	endbr32 
  800f04:	55                   	push   %ebp
  800f05:	57                   	push   %edi
  800f06:	56                   	push   %esi
  800f07:	53                   	push   %ebx
  800f08:	83 ec 1c             	sub    $0x1c,%esp
  800f0b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f0f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f13:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f17:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	75 19                	jne    800f38 <__umoddi3+0x38>
  800f1f:	39 df                	cmp    %ebx,%edi
  800f21:	76 5d                	jbe    800f80 <__umoddi3+0x80>
  800f23:	89 f0                	mov    %esi,%eax
  800f25:	89 da                	mov    %ebx,%edx
  800f27:	f7 f7                	div    %edi
  800f29:	89 d0                	mov    %edx,%eax
  800f2b:	31 d2                	xor    %edx,%edx
  800f2d:	83 c4 1c             	add    $0x1c,%esp
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    
  800f35:	8d 76 00             	lea    0x0(%esi),%esi
  800f38:	89 f2                	mov    %esi,%edx
  800f3a:	39 d8                	cmp    %ebx,%eax
  800f3c:	76 12                	jbe    800f50 <__umoddi3+0x50>
  800f3e:	89 f0                	mov    %esi,%eax
  800f40:	89 da                	mov    %ebx,%edx
  800f42:	83 c4 1c             	add    $0x1c,%esp
  800f45:	5b                   	pop    %ebx
  800f46:	5e                   	pop    %esi
  800f47:	5f                   	pop    %edi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    
  800f4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f50:	0f bd e8             	bsr    %eax,%ebp
  800f53:	83 f5 1f             	xor    $0x1f,%ebp
  800f56:	75 50                	jne    800fa8 <__umoddi3+0xa8>
  800f58:	39 d8                	cmp    %ebx,%eax
  800f5a:	0f 82 e0 00 00 00    	jb     801040 <__umoddi3+0x140>
  800f60:	89 d9                	mov    %ebx,%ecx
  800f62:	39 f7                	cmp    %esi,%edi
  800f64:	0f 86 d6 00 00 00    	jbe    801040 <__umoddi3+0x140>
  800f6a:	89 d0                	mov    %edx,%eax
  800f6c:	89 ca                	mov    %ecx,%edx
  800f6e:	83 c4 1c             	add    $0x1c,%esp
  800f71:	5b                   	pop    %ebx
  800f72:	5e                   	pop    %esi
  800f73:	5f                   	pop    %edi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    
  800f76:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f7d:	8d 76 00             	lea    0x0(%esi),%esi
  800f80:	89 fd                	mov    %edi,%ebp
  800f82:	85 ff                	test   %edi,%edi
  800f84:	75 0b                	jne    800f91 <__umoddi3+0x91>
  800f86:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8b:	31 d2                	xor    %edx,%edx
  800f8d:	f7 f7                	div    %edi
  800f8f:	89 c5                	mov    %eax,%ebp
  800f91:	89 d8                	mov    %ebx,%eax
  800f93:	31 d2                	xor    %edx,%edx
  800f95:	f7 f5                	div    %ebp
  800f97:	89 f0                	mov    %esi,%eax
  800f99:	f7 f5                	div    %ebp
  800f9b:	89 d0                	mov    %edx,%eax
  800f9d:	31 d2                	xor    %edx,%edx
  800f9f:	eb 8c                	jmp    800f2d <__umoddi3+0x2d>
  800fa1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fa8:	89 e9                	mov    %ebp,%ecx
  800faa:	ba 20 00 00 00       	mov    $0x20,%edx
  800faf:	29 ea                	sub    %ebp,%edx
  800fb1:	d3 e0                	shl    %cl,%eax
  800fb3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fb7:	89 d1                	mov    %edx,%ecx
  800fb9:	89 f8                	mov    %edi,%eax
  800fbb:	d3 e8                	shr    %cl,%eax
  800fbd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fc1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fc5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fc9:	09 c1                	or     %eax,%ecx
  800fcb:	89 d8                	mov    %ebx,%eax
  800fcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fd1:	89 e9                	mov    %ebp,%ecx
  800fd3:	d3 e7                	shl    %cl,%edi
  800fd5:	89 d1                	mov    %edx,%ecx
  800fd7:	d3 e8                	shr    %cl,%eax
  800fd9:	89 e9                	mov    %ebp,%ecx
  800fdb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fdf:	d3 e3                	shl    %cl,%ebx
  800fe1:	89 c7                	mov    %eax,%edi
  800fe3:	89 d1                	mov    %edx,%ecx
  800fe5:	89 f0                	mov    %esi,%eax
  800fe7:	d3 e8                	shr    %cl,%eax
  800fe9:	89 e9                	mov    %ebp,%ecx
  800feb:	89 fa                	mov    %edi,%edx
  800fed:	d3 e6                	shl    %cl,%esi
  800fef:	09 d8                	or     %ebx,%eax
  800ff1:	f7 74 24 08          	divl   0x8(%esp)
  800ff5:	89 d1                	mov    %edx,%ecx
  800ff7:	89 f3                	mov    %esi,%ebx
  800ff9:	f7 64 24 0c          	mull   0xc(%esp)
  800ffd:	89 c6                	mov    %eax,%esi
  800fff:	89 d7                	mov    %edx,%edi
  801001:	39 d1                	cmp    %edx,%ecx
  801003:	72 06                	jb     80100b <__umoddi3+0x10b>
  801005:	75 10                	jne    801017 <__umoddi3+0x117>
  801007:	39 c3                	cmp    %eax,%ebx
  801009:	73 0c                	jae    801017 <__umoddi3+0x117>
  80100b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80100f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801013:	89 d7                	mov    %edx,%edi
  801015:	89 c6                	mov    %eax,%esi
  801017:	89 ca                	mov    %ecx,%edx
  801019:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80101e:	29 f3                	sub    %esi,%ebx
  801020:	19 fa                	sbb    %edi,%edx
  801022:	89 d0                	mov    %edx,%eax
  801024:	d3 e0                	shl    %cl,%eax
  801026:	89 e9                	mov    %ebp,%ecx
  801028:	d3 eb                	shr    %cl,%ebx
  80102a:	d3 ea                	shr    %cl,%edx
  80102c:	09 d8                	or     %ebx,%eax
  80102e:	83 c4 1c             	add    $0x1c,%esp
  801031:	5b                   	pop    %ebx
  801032:	5e                   	pop    %esi
  801033:	5f                   	pop    %edi
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    
  801036:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80103d:	8d 76 00             	lea    0x0(%esi),%esi
  801040:	29 fe                	sub    %edi,%esi
  801042:	19 c3                	sbb    %eax,%ebx
  801044:	89 f2                	mov    %esi,%edx
  801046:	89 d9                	mov    %ebx,%ecx
  801048:	e9 1d ff ff ff       	jmp    800f6a <__umoddi3+0x6a>
