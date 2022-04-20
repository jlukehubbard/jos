
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
  800046:	e8 4e 01 00 00       	call   800199 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	68 ef be ad de       	push   $0xdeadbeef
  800053:	6a 00                	push   $0x0
  800055:	e8 58 02 00 00       	call   8002b2 <sys_env_set_pgfault_upcall>
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
    envid_t envid = sys_getenvid();
  800078:	e8 d6 00 00 00       	call   800153 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  80007d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800082:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800085:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008a:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008f:	85 db                	test   %ebx,%ebx
  800091:	7e 07                	jle    80009a <libmain+0x31>
		binaryname = argv[0];
  800093:	8b 06                	mov    (%esi),%eax
  800095:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009a:	83 ec 08             	sub    $0x8,%esp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	e8 8f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a4:	e8 0a 00 00 00       	call   8000b3 <exit>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5d                   	pop    %ebp
  8000b2:	c3                   	ret    

008000b3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b3:	f3 0f 1e fb          	endbr32 
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000bd:	6a 00                	push   $0x0
  8000bf:	e8 4a 00 00 00       	call   80010e <sys_env_destroy>
}
  8000c4:	83 c4 10             	add    $0x10,%esp
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    

008000c9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c9:	f3 0f 1e fb          	endbr32 
  8000cd:	55                   	push   %ebp
  8000ce:	89 e5                	mov    %esp,%ebp
  8000d0:	57                   	push   %edi
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000de:	89 c3                	mov    %eax,%ebx
  8000e0:	89 c7                	mov    %eax,%edi
  8000e2:	89 c6                	mov    %eax,%esi
  8000e4:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_cgetc>:

int
sys_cgetc(void)
{
  8000eb:	f3 0f 1e fb          	endbr32 
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	57                   	push   %edi
  8000f3:	56                   	push   %esi
  8000f4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ff:	89 d1                	mov    %edx,%ecx
  800101:	89 d3                	mov    %edx,%ebx
  800103:	89 d7                	mov    %edx,%edi
  800105:	89 d6                	mov    %edx,%esi
  800107:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800109:	5b                   	pop    %ebx
  80010a:	5e                   	pop    %esi
  80010b:	5f                   	pop    %edi
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    

0080010e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80010e:	f3 0f 1e fb          	endbr32 
  800112:	55                   	push   %ebp
  800113:	89 e5                	mov    %esp,%ebp
  800115:	57                   	push   %edi
  800116:	56                   	push   %esi
  800117:	53                   	push   %ebx
  800118:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80011b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800120:	8b 55 08             	mov    0x8(%ebp),%edx
  800123:	b8 03 00 00 00       	mov    $0x3,%eax
  800128:	89 cb                	mov    %ecx,%ebx
  80012a:	89 cf                	mov    %ecx,%edi
  80012c:	89 ce                	mov    %ecx,%esi
  80012e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800130:	85 c0                	test   %eax,%eax
  800132:	7f 08                	jg     80013c <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800134:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800137:	5b                   	pop    %ebx
  800138:	5e                   	pop    %esi
  800139:	5f                   	pop    %edi
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80013c:	83 ec 0c             	sub    $0xc,%esp
  80013f:	50                   	push   %eax
  800140:	6a 03                	push   $0x3
  800142:	68 4a 10 80 00       	push   $0x80104a
  800147:	6a 23                	push   $0x23
  800149:	68 67 10 80 00       	push   $0x801067
  80014e:	e8 11 02 00 00       	call   800364 <_panic>

00800153 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800153:	f3 0f 1e fb          	endbr32 
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	57                   	push   %edi
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015d:	ba 00 00 00 00       	mov    $0x0,%edx
  800162:	b8 02 00 00 00       	mov    $0x2,%eax
  800167:	89 d1                	mov    %edx,%ecx
  800169:	89 d3                	mov    %edx,%ebx
  80016b:	89 d7                	mov    %edx,%edi
  80016d:	89 d6                	mov    %edx,%esi
  80016f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800171:	5b                   	pop    %ebx
  800172:	5e                   	pop    %esi
  800173:	5f                   	pop    %edi
  800174:	5d                   	pop    %ebp
  800175:	c3                   	ret    

00800176 <sys_yield>:

void
sys_yield(void)
{
  800176:	f3 0f 1e fb          	endbr32 
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	57                   	push   %edi
  80017e:	56                   	push   %esi
  80017f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800180:	ba 00 00 00 00       	mov    $0x0,%edx
  800185:	b8 0a 00 00 00       	mov    $0xa,%eax
  80018a:	89 d1                	mov    %edx,%ecx
  80018c:	89 d3                	mov    %edx,%ebx
  80018e:	89 d7                	mov    %edx,%edi
  800190:	89 d6                	mov    %edx,%esi
  800192:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800199:	f3 0f 1e fb          	endbr32 
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a6:	be 00 00 00 00       	mov    $0x0,%esi
  8001ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b1:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b9:	89 f7                	mov    %esi,%edi
  8001bb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	7f 08                	jg     8001c9 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c4:	5b                   	pop    %ebx
  8001c5:	5e                   	pop    %esi
  8001c6:	5f                   	pop    %edi
  8001c7:	5d                   	pop    %ebp
  8001c8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 04                	push   $0x4
  8001cf:	68 4a 10 80 00       	push   $0x80104a
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 67 10 80 00       	push   $0x801067
  8001db:	e8 84 01 00 00       	call   800364 <_panic>

008001e0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e0:	f3 0f 1e fb          	endbr32 
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	57                   	push   %edi
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f3:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001fe:	8b 75 18             	mov    0x18(%ebp),%esi
  800201:	cd 30                	int    $0x30
	if(check && ret > 0)
  800203:	85 c0                	test   %eax,%eax
  800205:	7f 08                	jg     80020f <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800207:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020a:	5b                   	pop    %ebx
  80020b:	5e                   	pop    %esi
  80020c:	5f                   	pop    %edi
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	50                   	push   %eax
  800213:	6a 05                	push   $0x5
  800215:	68 4a 10 80 00       	push   $0x80104a
  80021a:	6a 23                	push   $0x23
  80021c:	68 67 10 80 00       	push   $0x801067
  800221:	e8 3e 01 00 00       	call   800364 <_panic>

00800226 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800226:	f3 0f 1e fb          	endbr32 
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	8b 55 08             	mov    0x8(%ebp),%edx
  80023b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023e:	b8 06 00 00 00       	mov    $0x6,%eax
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7f 08                	jg     800255 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80024d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800250:	5b                   	pop    %ebx
  800251:	5e                   	pop    %esi
  800252:	5f                   	pop    %edi
  800253:	5d                   	pop    %ebp
  800254:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800255:	83 ec 0c             	sub    $0xc,%esp
  800258:	50                   	push   %eax
  800259:	6a 06                	push   $0x6
  80025b:	68 4a 10 80 00       	push   $0x80104a
  800260:	6a 23                	push   $0x23
  800262:	68 67 10 80 00       	push   $0x801067
  800267:	e8 f8 00 00 00       	call   800364 <_panic>

0080026c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80026c:	f3 0f 1e fb          	endbr32 
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800279:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027e:	8b 55 08             	mov    0x8(%ebp),%edx
  800281:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800284:	b8 08 00 00 00       	mov    $0x8,%eax
  800289:	89 df                	mov    %ebx,%edi
  80028b:	89 de                	mov    %ebx,%esi
  80028d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80028f:	85 c0                	test   %eax,%eax
  800291:	7f 08                	jg     80029b <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800293:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800296:	5b                   	pop    %ebx
  800297:	5e                   	pop    %esi
  800298:	5f                   	pop    %edi
  800299:	5d                   	pop    %ebp
  80029a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80029b:	83 ec 0c             	sub    $0xc,%esp
  80029e:	50                   	push   %eax
  80029f:	6a 08                	push   $0x8
  8002a1:	68 4a 10 80 00       	push   $0x80104a
  8002a6:	6a 23                	push   $0x23
  8002a8:	68 67 10 80 00       	push   $0x801067
  8002ad:	e8 b2 00 00 00       	call   800364 <_panic>

008002b2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b2:	f3 0f 1e fb          	endbr32 
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	57                   	push   %edi
  8002ba:	56                   	push   %esi
  8002bb:	53                   	push   %ebx
  8002bc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ca:	b8 09 00 00 00       	mov    $0x9,%eax
  8002cf:	89 df                	mov    %ebx,%edi
  8002d1:	89 de                	mov    %ebx,%esi
  8002d3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d5:	85 c0                	test   %eax,%eax
  8002d7:	7f 08                	jg     8002e1 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dc:	5b                   	pop    %ebx
  8002dd:	5e                   	pop    %esi
  8002de:	5f                   	pop    %edi
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e1:	83 ec 0c             	sub    $0xc,%esp
  8002e4:	50                   	push   %eax
  8002e5:	6a 09                	push   $0x9
  8002e7:	68 4a 10 80 00       	push   $0x80104a
  8002ec:	6a 23                	push   $0x23
  8002ee:	68 67 10 80 00       	push   $0x801067
  8002f3:	e8 6c 00 00 00       	call   800364 <_panic>

008002f8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f8:	f3 0f 1e fb          	endbr32 
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	57                   	push   %edi
  800300:	56                   	push   %esi
  800301:	53                   	push   %ebx
	asm volatile("int %1\n"
  800302:	8b 55 08             	mov    0x8(%ebp),%edx
  800305:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800308:	b8 0b 00 00 00       	mov    $0xb,%eax
  80030d:	be 00 00 00 00       	mov    $0x0,%esi
  800312:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800315:	8b 7d 14             	mov    0x14(%ebp),%edi
  800318:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031a:	5b                   	pop    %ebx
  80031b:	5e                   	pop    %esi
  80031c:	5f                   	pop    %edi
  80031d:	5d                   	pop    %ebp
  80031e:	c3                   	ret    

0080031f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031f:	f3 0f 1e fb          	endbr32 
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80032c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800331:	8b 55 08             	mov    0x8(%ebp),%edx
  800334:	b8 0c 00 00 00       	mov    $0xc,%eax
  800339:	89 cb                	mov    %ecx,%ebx
  80033b:	89 cf                	mov    %ecx,%edi
  80033d:	89 ce                	mov    %ecx,%esi
  80033f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800341:	85 c0                	test   %eax,%eax
  800343:	7f 08                	jg     80034d <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800345:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800348:	5b                   	pop    %ebx
  800349:	5e                   	pop    %esi
  80034a:	5f                   	pop    %edi
  80034b:	5d                   	pop    %ebp
  80034c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80034d:	83 ec 0c             	sub    $0xc,%esp
  800350:	50                   	push   %eax
  800351:	6a 0c                	push   $0xc
  800353:	68 4a 10 80 00       	push   $0x80104a
  800358:	6a 23                	push   $0x23
  80035a:	68 67 10 80 00       	push   $0x801067
  80035f:	e8 00 00 00 00       	call   800364 <_panic>

00800364 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800364:	f3 0f 1e fb          	endbr32 
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	56                   	push   %esi
  80036c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80036d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800370:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800376:	e8 d8 fd ff ff       	call   800153 <sys_getenvid>
  80037b:	83 ec 0c             	sub    $0xc,%esp
  80037e:	ff 75 0c             	pushl  0xc(%ebp)
  800381:	ff 75 08             	pushl  0x8(%ebp)
  800384:	56                   	push   %esi
  800385:	50                   	push   %eax
  800386:	68 78 10 80 00       	push   $0x801078
  80038b:	e8 bb 00 00 00       	call   80044b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800390:	83 c4 18             	add    $0x18,%esp
  800393:	53                   	push   %ebx
  800394:	ff 75 10             	pushl  0x10(%ebp)
  800397:	e8 5a 00 00 00       	call   8003f6 <vcprintf>
	cprintf("\n");
  80039c:	c7 04 24 9b 10 80 00 	movl   $0x80109b,(%esp)
  8003a3:	e8 a3 00 00 00       	call   80044b <cprintf>
  8003a8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003ab:	cc                   	int3   
  8003ac:	eb fd                	jmp    8003ab <_panic+0x47>

008003ae <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003ae:	f3 0f 1e fb          	endbr32 
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	53                   	push   %ebx
  8003b6:	83 ec 04             	sub    $0x4,%esp
  8003b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003bc:	8b 13                	mov    (%ebx),%edx
  8003be:	8d 42 01             	lea    0x1(%edx),%eax
  8003c1:	89 03                	mov    %eax,(%ebx)
  8003c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003ca:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003cf:	74 09                	je     8003da <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003d1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003d8:	c9                   	leave  
  8003d9:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003da:	83 ec 08             	sub    $0x8,%esp
  8003dd:	68 ff 00 00 00       	push   $0xff
  8003e2:	8d 43 08             	lea    0x8(%ebx),%eax
  8003e5:	50                   	push   %eax
  8003e6:	e8 de fc ff ff       	call   8000c9 <sys_cputs>
		b->idx = 0;
  8003eb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003f1:	83 c4 10             	add    $0x10,%esp
  8003f4:	eb db                	jmp    8003d1 <putch+0x23>

008003f6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003f6:	f3 0f 1e fb          	endbr32 
  8003fa:	55                   	push   %ebp
  8003fb:	89 e5                	mov    %esp,%ebp
  8003fd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800403:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80040a:	00 00 00 
	b.cnt = 0;
  80040d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800414:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800417:	ff 75 0c             	pushl  0xc(%ebp)
  80041a:	ff 75 08             	pushl  0x8(%ebp)
  80041d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800423:	50                   	push   %eax
  800424:	68 ae 03 80 00       	push   $0x8003ae
  800429:	e8 20 01 00 00       	call   80054e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80042e:	83 c4 08             	add    $0x8,%esp
  800431:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800437:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80043d:	50                   	push   %eax
  80043e:	e8 86 fc ff ff       	call   8000c9 <sys_cputs>

	return b.cnt;
}
  800443:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800449:	c9                   	leave  
  80044a:	c3                   	ret    

0080044b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80044b:	f3 0f 1e fb          	endbr32 
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800455:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800458:	50                   	push   %eax
  800459:	ff 75 08             	pushl  0x8(%ebp)
  80045c:	e8 95 ff ff ff       	call   8003f6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800461:	c9                   	leave  
  800462:	c3                   	ret    

00800463 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800463:	55                   	push   %ebp
  800464:	89 e5                	mov    %esp,%ebp
  800466:	57                   	push   %edi
  800467:	56                   	push   %esi
  800468:	53                   	push   %ebx
  800469:	83 ec 1c             	sub    $0x1c,%esp
  80046c:	89 c7                	mov    %eax,%edi
  80046e:	89 d6                	mov    %edx,%esi
  800470:	8b 45 08             	mov    0x8(%ebp),%eax
  800473:	8b 55 0c             	mov    0xc(%ebp),%edx
  800476:	89 d1                	mov    %edx,%ecx
  800478:	89 c2                	mov    %eax,%edx
  80047a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80047d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800480:	8b 45 10             	mov    0x10(%ebp),%eax
  800483:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800486:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800489:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800490:	39 c2                	cmp    %eax,%edx
  800492:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800495:	72 3e                	jb     8004d5 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800497:	83 ec 0c             	sub    $0xc,%esp
  80049a:	ff 75 18             	pushl  0x18(%ebp)
  80049d:	83 eb 01             	sub    $0x1,%ebx
  8004a0:	53                   	push   %ebx
  8004a1:	50                   	push   %eax
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ab:	ff 75 dc             	pushl  -0x24(%ebp)
  8004ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b1:	e8 1a 09 00 00       	call   800dd0 <__udivdi3>
  8004b6:	83 c4 18             	add    $0x18,%esp
  8004b9:	52                   	push   %edx
  8004ba:	50                   	push   %eax
  8004bb:	89 f2                	mov    %esi,%edx
  8004bd:	89 f8                	mov    %edi,%eax
  8004bf:	e8 9f ff ff ff       	call   800463 <printnum>
  8004c4:	83 c4 20             	add    $0x20,%esp
  8004c7:	eb 13                	jmp    8004dc <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	56                   	push   %esi
  8004cd:	ff 75 18             	pushl  0x18(%ebp)
  8004d0:	ff d7                	call   *%edi
  8004d2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004d5:	83 eb 01             	sub    $0x1,%ebx
  8004d8:	85 db                	test   %ebx,%ebx
  8004da:	7f ed                	jg     8004c9 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	56                   	push   %esi
  8004e0:	83 ec 04             	sub    $0x4,%esp
  8004e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8004ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ef:	e8 ec 09 00 00       	call   800ee0 <__umoddi3>
  8004f4:	83 c4 14             	add    $0x14,%esp
  8004f7:	0f be 80 9d 10 80 00 	movsbl 0x80109d(%eax),%eax
  8004fe:	50                   	push   %eax
  8004ff:	ff d7                	call   *%edi
}
  800501:	83 c4 10             	add    $0x10,%esp
  800504:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800507:	5b                   	pop    %ebx
  800508:	5e                   	pop    %esi
  800509:	5f                   	pop    %edi
  80050a:	5d                   	pop    %ebp
  80050b:	c3                   	ret    

0080050c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80050c:	f3 0f 1e fb          	endbr32 
  800510:	55                   	push   %ebp
  800511:	89 e5                	mov    %esp,%ebp
  800513:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800516:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80051a:	8b 10                	mov    (%eax),%edx
  80051c:	3b 50 04             	cmp    0x4(%eax),%edx
  80051f:	73 0a                	jae    80052b <sprintputch+0x1f>
		*b->buf++ = ch;
  800521:	8d 4a 01             	lea    0x1(%edx),%ecx
  800524:	89 08                	mov    %ecx,(%eax)
  800526:	8b 45 08             	mov    0x8(%ebp),%eax
  800529:	88 02                	mov    %al,(%edx)
}
  80052b:	5d                   	pop    %ebp
  80052c:	c3                   	ret    

0080052d <printfmt>:
{
  80052d:	f3 0f 1e fb          	endbr32 
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800537:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80053a:	50                   	push   %eax
  80053b:	ff 75 10             	pushl  0x10(%ebp)
  80053e:	ff 75 0c             	pushl  0xc(%ebp)
  800541:	ff 75 08             	pushl  0x8(%ebp)
  800544:	e8 05 00 00 00       	call   80054e <vprintfmt>
}
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	c9                   	leave  
  80054d:	c3                   	ret    

0080054e <vprintfmt>:
{
  80054e:	f3 0f 1e fb          	endbr32 
  800552:	55                   	push   %ebp
  800553:	89 e5                	mov    %esp,%ebp
  800555:	57                   	push   %edi
  800556:	56                   	push   %esi
  800557:	53                   	push   %ebx
  800558:	83 ec 3c             	sub    $0x3c,%esp
  80055b:	8b 75 08             	mov    0x8(%ebp),%esi
  80055e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800561:	8b 7d 10             	mov    0x10(%ebp),%edi
  800564:	e9 4a 03 00 00       	jmp    8008b3 <vprintfmt+0x365>
		padc = ' ';
  800569:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80056d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800574:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80057b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800582:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800587:	8d 47 01             	lea    0x1(%edi),%eax
  80058a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80058d:	0f b6 17             	movzbl (%edi),%edx
  800590:	8d 42 dd             	lea    -0x23(%edx),%eax
  800593:	3c 55                	cmp    $0x55,%al
  800595:	0f 87 de 03 00 00    	ja     800979 <vprintfmt+0x42b>
  80059b:	0f b6 c0             	movzbl %al,%eax
  80059e:	3e ff 24 85 60 11 80 	notrack jmp *0x801160(,%eax,4)
  8005a5:	00 
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005a9:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005ad:	eb d8                	jmp    800587 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b2:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005b6:	eb cf                	jmp    800587 <vprintfmt+0x39>
  8005b8:	0f b6 d2             	movzbl %dl,%edx
  8005bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005be:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005c6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005c9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005cd:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005d0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005d3:	83 f9 09             	cmp    $0x9,%ecx
  8005d6:	77 55                	ja     80062d <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005d8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005db:	eb e9                	jmp    8005c6 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8b 00                	mov    (%eax),%eax
  8005e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8d 40 04             	lea    0x4(%eax),%eax
  8005eb:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f5:	79 90                	jns    800587 <vprintfmt+0x39>
				width = precision, precision = -1;
  8005f7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005fd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800604:	eb 81                	jmp    800587 <vprintfmt+0x39>
  800606:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800609:	85 c0                	test   %eax,%eax
  80060b:	ba 00 00 00 00       	mov    $0x0,%edx
  800610:	0f 49 d0             	cmovns %eax,%edx
  800613:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800616:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800619:	e9 69 ff ff ff       	jmp    800587 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80061e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800621:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800628:	e9 5a ff ff ff       	jmp    800587 <vprintfmt+0x39>
  80062d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800630:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800633:	eb bc                	jmp    8005f1 <vprintfmt+0xa3>
			lflag++;
  800635:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800638:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80063b:	e9 47 ff ff ff       	jmp    800587 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 78 04             	lea    0x4(%eax),%edi
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	53                   	push   %ebx
  80064a:	ff 30                	pushl  (%eax)
  80064c:	ff d6                	call   *%esi
			break;
  80064e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800651:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800654:	e9 57 02 00 00       	jmp    8008b0 <vprintfmt+0x362>
			err = va_arg(ap, int);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8d 78 04             	lea    0x4(%eax),%edi
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	99                   	cltd   
  800662:	31 d0                	xor    %edx,%eax
  800664:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800666:	83 f8 08             	cmp    $0x8,%eax
  800669:	7f 23                	jg     80068e <vprintfmt+0x140>
  80066b:	8b 14 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edx
  800672:	85 d2                	test   %edx,%edx
  800674:	74 18                	je     80068e <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800676:	52                   	push   %edx
  800677:	68 be 10 80 00       	push   $0x8010be
  80067c:	53                   	push   %ebx
  80067d:	56                   	push   %esi
  80067e:	e8 aa fe ff ff       	call   80052d <printfmt>
  800683:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800686:	89 7d 14             	mov    %edi,0x14(%ebp)
  800689:	e9 22 02 00 00       	jmp    8008b0 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  80068e:	50                   	push   %eax
  80068f:	68 b5 10 80 00       	push   $0x8010b5
  800694:	53                   	push   %ebx
  800695:	56                   	push   %esi
  800696:	e8 92 fe ff ff       	call   80052d <printfmt>
  80069b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80069e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8006a1:	e9 0a 02 00 00       	jmp    8008b0 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	83 c0 04             	add    $0x4,%eax
  8006ac:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8006b4:	85 d2                	test   %edx,%edx
  8006b6:	b8 ae 10 80 00       	mov    $0x8010ae,%eax
  8006bb:	0f 45 c2             	cmovne %edx,%eax
  8006be:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c5:	7e 06                	jle    8006cd <vprintfmt+0x17f>
  8006c7:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006cb:	75 0d                	jne    8006da <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cd:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006d0:	89 c7                	mov    %eax,%edi
  8006d2:	03 45 e0             	add    -0x20(%ebp),%eax
  8006d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d8:	eb 55                	jmp    80072f <vprintfmt+0x1e1>
  8006da:	83 ec 08             	sub    $0x8,%esp
  8006dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8006e0:	ff 75 cc             	pushl  -0x34(%ebp)
  8006e3:	e8 45 03 00 00       	call   800a2d <strnlen>
  8006e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006eb:	29 c2                	sub    %eax,%edx
  8006ed:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006f5:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fc:	85 ff                	test   %edi,%edi
  8006fe:	7e 11                	jle    800711 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800700:	83 ec 08             	sub    $0x8,%esp
  800703:	53                   	push   %ebx
  800704:	ff 75 e0             	pushl  -0x20(%ebp)
  800707:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800709:	83 ef 01             	sub    $0x1,%edi
  80070c:	83 c4 10             	add    $0x10,%esp
  80070f:	eb eb                	jmp    8006fc <vprintfmt+0x1ae>
  800711:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800714:	85 d2                	test   %edx,%edx
  800716:	b8 00 00 00 00       	mov    $0x0,%eax
  80071b:	0f 49 c2             	cmovns %edx,%eax
  80071e:	29 c2                	sub    %eax,%edx
  800720:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800723:	eb a8                	jmp    8006cd <vprintfmt+0x17f>
					putch(ch, putdat);
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	53                   	push   %ebx
  800729:	52                   	push   %edx
  80072a:	ff d6                	call   *%esi
  80072c:	83 c4 10             	add    $0x10,%esp
  80072f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800732:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800734:	83 c7 01             	add    $0x1,%edi
  800737:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80073b:	0f be d0             	movsbl %al,%edx
  80073e:	85 d2                	test   %edx,%edx
  800740:	74 4b                	je     80078d <vprintfmt+0x23f>
  800742:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800746:	78 06                	js     80074e <vprintfmt+0x200>
  800748:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80074c:	78 1e                	js     80076c <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80074e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800752:	74 d1                	je     800725 <vprintfmt+0x1d7>
  800754:	0f be c0             	movsbl %al,%eax
  800757:	83 e8 20             	sub    $0x20,%eax
  80075a:	83 f8 5e             	cmp    $0x5e,%eax
  80075d:	76 c6                	jbe    800725 <vprintfmt+0x1d7>
					putch('?', putdat);
  80075f:	83 ec 08             	sub    $0x8,%esp
  800762:	53                   	push   %ebx
  800763:	6a 3f                	push   $0x3f
  800765:	ff d6                	call   *%esi
  800767:	83 c4 10             	add    $0x10,%esp
  80076a:	eb c3                	jmp    80072f <vprintfmt+0x1e1>
  80076c:	89 cf                	mov    %ecx,%edi
  80076e:	eb 0e                	jmp    80077e <vprintfmt+0x230>
				putch(' ', putdat);
  800770:	83 ec 08             	sub    $0x8,%esp
  800773:	53                   	push   %ebx
  800774:	6a 20                	push   $0x20
  800776:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800778:	83 ef 01             	sub    $0x1,%edi
  80077b:	83 c4 10             	add    $0x10,%esp
  80077e:	85 ff                	test   %edi,%edi
  800780:	7f ee                	jg     800770 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800782:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800785:	89 45 14             	mov    %eax,0x14(%ebp)
  800788:	e9 23 01 00 00       	jmp    8008b0 <vprintfmt+0x362>
  80078d:	89 cf                	mov    %ecx,%edi
  80078f:	eb ed                	jmp    80077e <vprintfmt+0x230>
	if (lflag >= 2)
  800791:	83 f9 01             	cmp    $0x1,%ecx
  800794:	7f 1b                	jg     8007b1 <vprintfmt+0x263>
	else if (lflag)
  800796:	85 c9                	test   %ecx,%ecx
  800798:	74 63                	je     8007fd <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80079a:	8b 45 14             	mov    0x14(%ebp),%eax
  80079d:	8b 00                	mov    (%eax),%eax
  80079f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a2:	99                   	cltd   
  8007a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a9:	8d 40 04             	lea    0x4(%eax),%eax
  8007ac:	89 45 14             	mov    %eax,0x14(%ebp)
  8007af:	eb 17                	jmp    8007c8 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8007b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b4:	8b 50 04             	mov    0x4(%eax),%edx
  8007b7:	8b 00                	mov    (%eax),%eax
  8007b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c2:	8d 40 08             	lea    0x8(%eax),%eax
  8007c5:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007c8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007cb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007ce:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007d3:	85 c9                	test   %ecx,%ecx
  8007d5:	0f 89 bb 00 00 00    	jns    800896 <vprintfmt+0x348>
				putch('-', putdat);
  8007db:	83 ec 08             	sub    $0x8,%esp
  8007de:	53                   	push   %ebx
  8007df:	6a 2d                	push   $0x2d
  8007e1:	ff d6                	call   *%esi
				num = -(long long) num;
  8007e3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007e6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007e9:	f7 da                	neg    %edx
  8007eb:	83 d1 00             	adc    $0x0,%ecx
  8007ee:	f7 d9                	neg    %ecx
  8007f0:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007f8:	e9 99 00 00 00       	jmp    800896 <vprintfmt+0x348>
		return va_arg(*ap, int);
  8007fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800800:	8b 00                	mov    (%eax),%eax
  800802:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800805:	99                   	cltd   
  800806:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800809:	8b 45 14             	mov    0x14(%ebp),%eax
  80080c:	8d 40 04             	lea    0x4(%eax),%eax
  80080f:	89 45 14             	mov    %eax,0x14(%ebp)
  800812:	eb b4                	jmp    8007c8 <vprintfmt+0x27a>
	if (lflag >= 2)
  800814:	83 f9 01             	cmp    $0x1,%ecx
  800817:	7f 1b                	jg     800834 <vprintfmt+0x2e6>
	else if (lflag)
  800819:	85 c9                	test   %ecx,%ecx
  80081b:	74 2c                	je     800849 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80081d:	8b 45 14             	mov    0x14(%ebp),%eax
  800820:	8b 10                	mov    (%eax),%edx
  800822:	b9 00 00 00 00       	mov    $0x0,%ecx
  800827:	8d 40 04             	lea    0x4(%eax),%eax
  80082a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80082d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800832:	eb 62                	jmp    800896 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800834:	8b 45 14             	mov    0x14(%ebp),%eax
  800837:	8b 10                	mov    (%eax),%edx
  800839:	8b 48 04             	mov    0x4(%eax),%ecx
  80083c:	8d 40 08             	lea    0x8(%eax),%eax
  80083f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800842:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800847:	eb 4d                	jmp    800896 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800849:	8b 45 14             	mov    0x14(%ebp),%eax
  80084c:	8b 10                	mov    (%eax),%edx
  80084e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800853:	8d 40 04             	lea    0x4(%eax),%eax
  800856:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800859:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80085e:	eb 36                	jmp    800896 <vprintfmt+0x348>
	if (lflag >= 2)
  800860:	83 f9 01             	cmp    $0x1,%ecx
  800863:	7f 17                	jg     80087c <vprintfmt+0x32e>
	else if (lflag)
  800865:	85 c9                	test   %ecx,%ecx
  800867:	74 6e                	je     8008d7 <vprintfmt+0x389>
		return va_arg(*ap, long);
  800869:	8b 45 14             	mov    0x14(%ebp),%eax
  80086c:	8b 10                	mov    (%eax),%edx
  80086e:	89 d0                	mov    %edx,%eax
  800870:	99                   	cltd   
  800871:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800874:	8d 49 04             	lea    0x4(%ecx),%ecx
  800877:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80087a:	eb 11                	jmp    80088d <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  80087c:	8b 45 14             	mov    0x14(%ebp),%eax
  80087f:	8b 50 04             	mov    0x4(%eax),%edx
  800882:	8b 00                	mov    (%eax),%eax
  800884:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800887:	8d 49 08             	lea    0x8(%ecx),%ecx
  80088a:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80088d:	89 d1                	mov    %edx,%ecx
  80088f:	89 c2                	mov    %eax,%edx
            base = 8;
  800891:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800896:	83 ec 0c             	sub    $0xc,%esp
  800899:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80089d:	57                   	push   %edi
  80089e:	ff 75 e0             	pushl  -0x20(%ebp)
  8008a1:	50                   	push   %eax
  8008a2:	51                   	push   %ecx
  8008a3:	52                   	push   %edx
  8008a4:	89 da                	mov    %ebx,%edx
  8008a6:	89 f0                	mov    %esi,%eax
  8008a8:	e8 b6 fb ff ff       	call   800463 <printnum>
			break;
  8008ad:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008b3:	83 c7 01             	add    $0x1,%edi
  8008b6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008ba:	83 f8 25             	cmp    $0x25,%eax
  8008bd:	0f 84 a6 fc ff ff    	je     800569 <vprintfmt+0x1b>
			if (ch == '\0')
  8008c3:	85 c0                	test   %eax,%eax
  8008c5:	0f 84 ce 00 00 00    	je     800999 <vprintfmt+0x44b>
			putch(ch, putdat);
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	53                   	push   %ebx
  8008cf:	50                   	push   %eax
  8008d0:	ff d6                	call   *%esi
  8008d2:	83 c4 10             	add    $0x10,%esp
  8008d5:	eb dc                	jmp    8008b3 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8008d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008da:	8b 10                	mov    (%eax),%edx
  8008dc:	89 d0                	mov    %edx,%eax
  8008de:	99                   	cltd   
  8008df:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008e2:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008e5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008e8:	eb a3                	jmp    80088d <vprintfmt+0x33f>
			putch('0', putdat);
  8008ea:	83 ec 08             	sub    $0x8,%esp
  8008ed:	53                   	push   %ebx
  8008ee:	6a 30                	push   $0x30
  8008f0:	ff d6                	call   *%esi
			putch('x', putdat);
  8008f2:	83 c4 08             	add    $0x8,%esp
  8008f5:	53                   	push   %ebx
  8008f6:	6a 78                	push   $0x78
  8008f8:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fd:	8b 10                	mov    (%eax),%edx
  8008ff:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800904:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800907:	8d 40 04             	lea    0x4(%eax),%eax
  80090a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80090d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800912:	eb 82                	jmp    800896 <vprintfmt+0x348>
	if (lflag >= 2)
  800914:	83 f9 01             	cmp    $0x1,%ecx
  800917:	7f 1e                	jg     800937 <vprintfmt+0x3e9>
	else if (lflag)
  800919:	85 c9                	test   %ecx,%ecx
  80091b:	74 32                	je     80094f <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80091d:	8b 45 14             	mov    0x14(%ebp),%eax
  800920:	8b 10                	mov    (%eax),%edx
  800922:	b9 00 00 00 00       	mov    $0x0,%ecx
  800927:	8d 40 04             	lea    0x4(%eax),%eax
  80092a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80092d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800932:	e9 5f ff ff ff       	jmp    800896 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800937:	8b 45 14             	mov    0x14(%ebp),%eax
  80093a:	8b 10                	mov    (%eax),%edx
  80093c:	8b 48 04             	mov    0x4(%eax),%ecx
  80093f:	8d 40 08             	lea    0x8(%eax),%eax
  800942:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800945:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80094a:	e9 47 ff ff ff       	jmp    800896 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80094f:	8b 45 14             	mov    0x14(%ebp),%eax
  800952:	8b 10                	mov    (%eax),%edx
  800954:	b9 00 00 00 00       	mov    $0x0,%ecx
  800959:	8d 40 04             	lea    0x4(%eax),%eax
  80095c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80095f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800964:	e9 2d ff ff ff       	jmp    800896 <vprintfmt+0x348>
			putch(ch, putdat);
  800969:	83 ec 08             	sub    $0x8,%esp
  80096c:	53                   	push   %ebx
  80096d:	6a 25                	push   $0x25
  80096f:	ff d6                	call   *%esi
			break;
  800971:	83 c4 10             	add    $0x10,%esp
  800974:	e9 37 ff ff ff       	jmp    8008b0 <vprintfmt+0x362>
			putch('%', putdat);
  800979:	83 ec 08             	sub    $0x8,%esp
  80097c:	53                   	push   %ebx
  80097d:	6a 25                	push   $0x25
  80097f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800981:	83 c4 10             	add    $0x10,%esp
  800984:	89 f8                	mov    %edi,%eax
  800986:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80098a:	74 05                	je     800991 <vprintfmt+0x443>
  80098c:	83 e8 01             	sub    $0x1,%eax
  80098f:	eb f5                	jmp    800986 <vprintfmt+0x438>
  800991:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800994:	e9 17 ff ff ff       	jmp    8008b0 <vprintfmt+0x362>
}
  800999:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5f                   	pop    %edi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009a1:	f3 0f 1e fb          	endbr32 
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	83 ec 18             	sub    $0x18,%esp
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009b4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009b8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009c2:	85 c0                	test   %eax,%eax
  8009c4:	74 26                	je     8009ec <vsnprintf+0x4b>
  8009c6:	85 d2                	test   %edx,%edx
  8009c8:	7e 22                	jle    8009ec <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009ca:	ff 75 14             	pushl  0x14(%ebp)
  8009cd:	ff 75 10             	pushl  0x10(%ebp)
  8009d0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009d3:	50                   	push   %eax
  8009d4:	68 0c 05 80 00       	push   $0x80050c
  8009d9:	e8 70 fb ff ff       	call   80054e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009de:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009e1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009e7:	83 c4 10             	add    $0x10,%esp
}
  8009ea:	c9                   	leave  
  8009eb:	c3                   	ret    
		return -E_INVAL;
  8009ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009f1:	eb f7                	jmp    8009ea <vsnprintf+0x49>

008009f3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009f3:	f3 0f 1e fb          	endbr32 
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009fd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a00:	50                   	push   %eax
  800a01:	ff 75 10             	pushl  0x10(%ebp)
  800a04:	ff 75 0c             	pushl  0xc(%ebp)
  800a07:	ff 75 08             	pushl  0x8(%ebp)
  800a0a:	e8 92 ff ff ff       	call   8009a1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a11:	f3 0f 1e fb          	endbr32 
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a20:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a24:	74 05                	je     800a2b <strlen+0x1a>
		n++;
  800a26:	83 c0 01             	add    $0x1,%eax
  800a29:	eb f5                	jmp    800a20 <strlen+0xf>
	return n;
}
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a2d:	f3 0f 1e fb          	endbr32 
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a37:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3f:	39 d0                	cmp    %edx,%eax
  800a41:	74 0d                	je     800a50 <strnlen+0x23>
  800a43:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a47:	74 05                	je     800a4e <strnlen+0x21>
		n++;
  800a49:	83 c0 01             	add    $0x1,%eax
  800a4c:	eb f1                	jmp    800a3f <strnlen+0x12>
  800a4e:	89 c2                	mov    %eax,%edx
	return n;
}
  800a50:	89 d0                	mov    %edx,%eax
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a54:	f3 0f 1e fb          	endbr32 
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	53                   	push   %ebx
  800a5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a62:	b8 00 00 00 00       	mov    $0x0,%eax
  800a67:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a6b:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a6e:	83 c0 01             	add    $0x1,%eax
  800a71:	84 d2                	test   %dl,%dl
  800a73:	75 f2                	jne    800a67 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a75:	89 c8                	mov    %ecx,%eax
  800a77:	5b                   	pop    %ebx
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a7a:	f3 0f 1e fb          	endbr32 
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	53                   	push   %ebx
  800a82:	83 ec 10             	sub    $0x10,%esp
  800a85:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a88:	53                   	push   %ebx
  800a89:	e8 83 ff ff ff       	call   800a11 <strlen>
  800a8e:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a91:	ff 75 0c             	pushl  0xc(%ebp)
  800a94:	01 d8                	add    %ebx,%eax
  800a96:	50                   	push   %eax
  800a97:	e8 b8 ff ff ff       	call   800a54 <strcpy>
	return dst;
}
  800a9c:	89 d8                	mov    %ebx,%eax
  800a9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aa1:	c9                   	leave  
  800aa2:	c3                   	ret    

00800aa3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aa3:	f3 0f 1e fb          	endbr32 
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
  800aac:	8b 75 08             	mov    0x8(%ebp),%esi
  800aaf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab2:	89 f3                	mov    %esi,%ebx
  800ab4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab7:	89 f0                	mov    %esi,%eax
  800ab9:	39 d8                	cmp    %ebx,%eax
  800abb:	74 11                	je     800ace <strncpy+0x2b>
		*dst++ = *src;
  800abd:	83 c0 01             	add    $0x1,%eax
  800ac0:	0f b6 0a             	movzbl (%edx),%ecx
  800ac3:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ac6:	80 f9 01             	cmp    $0x1,%cl
  800ac9:	83 da ff             	sbb    $0xffffffff,%edx
  800acc:	eb eb                	jmp    800ab9 <strncpy+0x16>
	}
	return ret;
}
  800ace:	89 f0                	mov    %esi,%eax
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ad4:	f3 0f 1e fb          	endbr32 
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	56                   	push   %esi
  800adc:	53                   	push   %ebx
  800add:	8b 75 08             	mov    0x8(%ebp),%esi
  800ae0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae3:	8b 55 10             	mov    0x10(%ebp),%edx
  800ae6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ae8:	85 d2                	test   %edx,%edx
  800aea:	74 21                	je     800b0d <strlcpy+0x39>
  800aec:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800af0:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800af2:	39 c2                	cmp    %eax,%edx
  800af4:	74 14                	je     800b0a <strlcpy+0x36>
  800af6:	0f b6 19             	movzbl (%ecx),%ebx
  800af9:	84 db                	test   %bl,%bl
  800afb:	74 0b                	je     800b08 <strlcpy+0x34>
			*dst++ = *src++;
  800afd:	83 c1 01             	add    $0x1,%ecx
  800b00:	83 c2 01             	add    $0x1,%edx
  800b03:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b06:	eb ea                	jmp    800af2 <strlcpy+0x1e>
  800b08:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b0a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b0d:	29 f0                	sub    %esi,%eax
}
  800b0f:	5b                   	pop    %ebx
  800b10:	5e                   	pop    %esi
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b13:	f3 0f 1e fb          	endbr32 
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b20:	0f b6 01             	movzbl (%ecx),%eax
  800b23:	84 c0                	test   %al,%al
  800b25:	74 0c                	je     800b33 <strcmp+0x20>
  800b27:	3a 02                	cmp    (%edx),%al
  800b29:	75 08                	jne    800b33 <strcmp+0x20>
		p++, q++;
  800b2b:	83 c1 01             	add    $0x1,%ecx
  800b2e:	83 c2 01             	add    $0x1,%edx
  800b31:	eb ed                	jmp    800b20 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b33:	0f b6 c0             	movzbl %al,%eax
  800b36:	0f b6 12             	movzbl (%edx),%edx
  800b39:	29 d0                	sub    %edx,%eax
}
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b3d:	f3 0f 1e fb          	endbr32 
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	53                   	push   %ebx
  800b45:	8b 45 08             	mov    0x8(%ebp),%eax
  800b48:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b4b:	89 c3                	mov    %eax,%ebx
  800b4d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b50:	eb 06                	jmp    800b58 <strncmp+0x1b>
		n--, p++, q++;
  800b52:	83 c0 01             	add    $0x1,%eax
  800b55:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b58:	39 d8                	cmp    %ebx,%eax
  800b5a:	74 16                	je     800b72 <strncmp+0x35>
  800b5c:	0f b6 08             	movzbl (%eax),%ecx
  800b5f:	84 c9                	test   %cl,%cl
  800b61:	74 04                	je     800b67 <strncmp+0x2a>
  800b63:	3a 0a                	cmp    (%edx),%cl
  800b65:	74 eb                	je     800b52 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b67:	0f b6 00             	movzbl (%eax),%eax
  800b6a:	0f b6 12             	movzbl (%edx),%edx
  800b6d:	29 d0                	sub    %edx,%eax
}
  800b6f:	5b                   	pop    %ebx
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    
		return 0;
  800b72:	b8 00 00 00 00       	mov    $0x0,%eax
  800b77:	eb f6                	jmp    800b6f <strncmp+0x32>

00800b79 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b79:	f3 0f 1e fb          	endbr32 
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	8b 45 08             	mov    0x8(%ebp),%eax
  800b83:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b87:	0f b6 10             	movzbl (%eax),%edx
  800b8a:	84 d2                	test   %dl,%dl
  800b8c:	74 09                	je     800b97 <strchr+0x1e>
		if (*s == c)
  800b8e:	38 ca                	cmp    %cl,%dl
  800b90:	74 0a                	je     800b9c <strchr+0x23>
	for (; *s; s++)
  800b92:	83 c0 01             	add    $0x1,%eax
  800b95:	eb f0                	jmp    800b87 <strchr+0xe>
			return (char *) s;
	return 0;
  800b97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b9e:	f3 0f 1e fb          	endbr32 
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bac:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800baf:	38 ca                	cmp    %cl,%dl
  800bb1:	74 09                	je     800bbc <strfind+0x1e>
  800bb3:	84 d2                	test   %dl,%dl
  800bb5:	74 05                	je     800bbc <strfind+0x1e>
	for (; *s; s++)
  800bb7:	83 c0 01             	add    $0x1,%eax
  800bba:	eb f0                	jmp    800bac <strfind+0xe>
			break;
	return (char *) s;
}
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bbe:	f3 0f 1e fb          	endbr32 
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bcb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bce:	85 c9                	test   %ecx,%ecx
  800bd0:	74 31                	je     800c03 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bd2:	89 f8                	mov    %edi,%eax
  800bd4:	09 c8                	or     %ecx,%eax
  800bd6:	a8 03                	test   $0x3,%al
  800bd8:	75 23                	jne    800bfd <memset+0x3f>
		c &= 0xFF;
  800bda:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bde:	89 d3                	mov    %edx,%ebx
  800be0:	c1 e3 08             	shl    $0x8,%ebx
  800be3:	89 d0                	mov    %edx,%eax
  800be5:	c1 e0 18             	shl    $0x18,%eax
  800be8:	89 d6                	mov    %edx,%esi
  800bea:	c1 e6 10             	shl    $0x10,%esi
  800bed:	09 f0                	or     %esi,%eax
  800bef:	09 c2                	or     %eax,%edx
  800bf1:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bf3:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800bf6:	89 d0                	mov    %edx,%eax
  800bf8:	fc                   	cld    
  800bf9:	f3 ab                	rep stos %eax,%es:(%edi)
  800bfb:	eb 06                	jmp    800c03 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c00:	fc                   	cld    
  800c01:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c03:	89 f8                	mov    %edi,%eax
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c0a:	f3 0f 1e fb          	endbr32 
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	8b 45 08             	mov    0x8(%ebp),%eax
  800c16:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c19:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c1c:	39 c6                	cmp    %eax,%esi
  800c1e:	73 32                	jae    800c52 <memmove+0x48>
  800c20:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c23:	39 c2                	cmp    %eax,%edx
  800c25:	76 2b                	jbe    800c52 <memmove+0x48>
		s += n;
		d += n;
  800c27:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2a:	89 fe                	mov    %edi,%esi
  800c2c:	09 ce                	or     %ecx,%esi
  800c2e:	09 d6                	or     %edx,%esi
  800c30:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c36:	75 0e                	jne    800c46 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c38:	83 ef 04             	sub    $0x4,%edi
  800c3b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c3e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c41:	fd                   	std    
  800c42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c44:	eb 09                	jmp    800c4f <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c46:	83 ef 01             	sub    $0x1,%edi
  800c49:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c4c:	fd                   	std    
  800c4d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c4f:	fc                   	cld    
  800c50:	eb 1a                	jmp    800c6c <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c52:	89 c2                	mov    %eax,%edx
  800c54:	09 ca                	or     %ecx,%edx
  800c56:	09 f2                	or     %esi,%edx
  800c58:	f6 c2 03             	test   $0x3,%dl
  800c5b:	75 0a                	jne    800c67 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c5d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c60:	89 c7                	mov    %eax,%edi
  800c62:	fc                   	cld    
  800c63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c65:	eb 05                	jmp    800c6c <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c67:	89 c7                	mov    %eax,%edi
  800c69:	fc                   	cld    
  800c6a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c70:	f3 0f 1e fb          	endbr32 
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c7a:	ff 75 10             	pushl  0x10(%ebp)
  800c7d:	ff 75 0c             	pushl  0xc(%ebp)
  800c80:	ff 75 08             	pushl  0x8(%ebp)
  800c83:	e8 82 ff ff ff       	call   800c0a <memmove>
}
  800c88:	c9                   	leave  
  800c89:	c3                   	ret    

00800c8a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c8a:	f3 0f 1e fb          	endbr32 
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	8b 45 08             	mov    0x8(%ebp),%eax
  800c96:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c99:	89 c6                	mov    %eax,%esi
  800c9b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c9e:	39 f0                	cmp    %esi,%eax
  800ca0:	74 1c                	je     800cbe <memcmp+0x34>
		if (*s1 != *s2)
  800ca2:	0f b6 08             	movzbl (%eax),%ecx
  800ca5:	0f b6 1a             	movzbl (%edx),%ebx
  800ca8:	38 d9                	cmp    %bl,%cl
  800caa:	75 08                	jne    800cb4 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cac:	83 c0 01             	add    $0x1,%eax
  800caf:	83 c2 01             	add    $0x1,%edx
  800cb2:	eb ea                	jmp    800c9e <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800cb4:	0f b6 c1             	movzbl %cl,%eax
  800cb7:	0f b6 db             	movzbl %bl,%ebx
  800cba:	29 d8                	sub    %ebx,%eax
  800cbc:	eb 05                	jmp    800cc3 <memcmp+0x39>
	}

	return 0;
  800cbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cc7:	f3 0f 1e fb          	endbr32 
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cd4:	89 c2                	mov    %eax,%edx
  800cd6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cd9:	39 d0                	cmp    %edx,%eax
  800cdb:	73 09                	jae    800ce6 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cdd:	38 08                	cmp    %cl,(%eax)
  800cdf:	74 05                	je     800ce6 <memfind+0x1f>
	for (; s < ends; s++)
  800ce1:	83 c0 01             	add    $0x1,%eax
  800ce4:	eb f3                	jmp    800cd9 <memfind+0x12>
			break;
	return (void *) s;
}
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ce8:	f3 0f 1e fb          	endbr32 
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
  800cf2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf8:	eb 03                	jmp    800cfd <strtol+0x15>
		s++;
  800cfa:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800cfd:	0f b6 01             	movzbl (%ecx),%eax
  800d00:	3c 20                	cmp    $0x20,%al
  800d02:	74 f6                	je     800cfa <strtol+0x12>
  800d04:	3c 09                	cmp    $0x9,%al
  800d06:	74 f2                	je     800cfa <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d08:	3c 2b                	cmp    $0x2b,%al
  800d0a:	74 2a                	je     800d36 <strtol+0x4e>
	int neg = 0;
  800d0c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d11:	3c 2d                	cmp    $0x2d,%al
  800d13:	74 2b                	je     800d40 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d15:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d1b:	75 0f                	jne    800d2c <strtol+0x44>
  800d1d:	80 39 30             	cmpb   $0x30,(%ecx)
  800d20:	74 28                	je     800d4a <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d22:	85 db                	test   %ebx,%ebx
  800d24:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d29:	0f 44 d8             	cmove  %eax,%ebx
  800d2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d31:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d34:	eb 46                	jmp    800d7c <strtol+0x94>
		s++;
  800d36:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d39:	bf 00 00 00 00       	mov    $0x0,%edi
  800d3e:	eb d5                	jmp    800d15 <strtol+0x2d>
		s++, neg = 1;
  800d40:	83 c1 01             	add    $0x1,%ecx
  800d43:	bf 01 00 00 00       	mov    $0x1,%edi
  800d48:	eb cb                	jmp    800d15 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d4a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d4e:	74 0e                	je     800d5e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d50:	85 db                	test   %ebx,%ebx
  800d52:	75 d8                	jne    800d2c <strtol+0x44>
		s++, base = 8;
  800d54:	83 c1 01             	add    $0x1,%ecx
  800d57:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d5c:	eb ce                	jmp    800d2c <strtol+0x44>
		s += 2, base = 16;
  800d5e:	83 c1 02             	add    $0x2,%ecx
  800d61:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d66:	eb c4                	jmp    800d2c <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d68:	0f be d2             	movsbl %dl,%edx
  800d6b:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d6e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d71:	7d 3a                	jge    800dad <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d73:	83 c1 01             	add    $0x1,%ecx
  800d76:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d7a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d7c:	0f b6 11             	movzbl (%ecx),%edx
  800d7f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d82:	89 f3                	mov    %esi,%ebx
  800d84:	80 fb 09             	cmp    $0x9,%bl
  800d87:	76 df                	jbe    800d68 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800d89:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d8c:	89 f3                	mov    %esi,%ebx
  800d8e:	80 fb 19             	cmp    $0x19,%bl
  800d91:	77 08                	ja     800d9b <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d93:	0f be d2             	movsbl %dl,%edx
  800d96:	83 ea 57             	sub    $0x57,%edx
  800d99:	eb d3                	jmp    800d6e <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800d9b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d9e:	89 f3                	mov    %esi,%ebx
  800da0:	80 fb 19             	cmp    $0x19,%bl
  800da3:	77 08                	ja     800dad <strtol+0xc5>
			dig = *s - 'A' + 10;
  800da5:	0f be d2             	movsbl %dl,%edx
  800da8:	83 ea 37             	sub    $0x37,%edx
  800dab:	eb c1                	jmp    800d6e <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800db1:	74 05                	je     800db8 <strtol+0xd0>
		*endptr = (char *) s;
  800db3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800db6:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800db8:	89 c2                	mov    %eax,%edx
  800dba:	f7 da                	neg    %edx
  800dbc:	85 ff                	test   %edi,%edi
  800dbe:	0f 45 c2             	cmovne %edx,%eax
}
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    
  800dc6:	66 90                	xchg   %ax,%ax
  800dc8:	66 90                	xchg   %ax,%ax
  800dca:	66 90                	xchg   %ax,%ax
  800dcc:	66 90                	xchg   %ax,%ax
  800dce:	66 90                	xchg   %ax,%ax

00800dd0 <__udivdi3>:
  800dd0:	f3 0f 1e fb          	endbr32 
  800dd4:	55                   	push   %ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 1c             	sub    $0x1c,%esp
  800ddb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800ddf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800de3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800de7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800deb:	85 d2                	test   %edx,%edx
  800ded:	75 19                	jne    800e08 <__udivdi3+0x38>
  800def:	39 f3                	cmp    %esi,%ebx
  800df1:	76 4d                	jbe    800e40 <__udivdi3+0x70>
  800df3:	31 ff                	xor    %edi,%edi
  800df5:	89 e8                	mov    %ebp,%eax
  800df7:	89 f2                	mov    %esi,%edx
  800df9:	f7 f3                	div    %ebx
  800dfb:	89 fa                	mov    %edi,%edx
  800dfd:	83 c4 1c             	add    $0x1c,%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    
  800e05:	8d 76 00             	lea    0x0(%esi),%esi
  800e08:	39 f2                	cmp    %esi,%edx
  800e0a:	76 14                	jbe    800e20 <__udivdi3+0x50>
  800e0c:	31 ff                	xor    %edi,%edi
  800e0e:	31 c0                	xor    %eax,%eax
  800e10:	89 fa                	mov    %edi,%edx
  800e12:	83 c4 1c             	add    $0x1c,%esp
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    
  800e1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e20:	0f bd fa             	bsr    %edx,%edi
  800e23:	83 f7 1f             	xor    $0x1f,%edi
  800e26:	75 48                	jne    800e70 <__udivdi3+0xa0>
  800e28:	39 f2                	cmp    %esi,%edx
  800e2a:	72 06                	jb     800e32 <__udivdi3+0x62>
  800e2c:	31 c0                	xor    %eax,%eax
  800e2e:	39 eb                	cmp    %ebp,%ebx
  800e30:	77 de                	ja     800e10 <__udivdi3+0x40>
  800e32:	b8 01 00 00 00       	mov    $0x1,%eax
  800e37:	eb d7                	jmp    800e10 <__udivdi3+0x40>
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	89 d9                	mov    %ebx,%ecx
  800e42:	85 db                	test   %ebx,%ebx
  800e44:	75 0b                	jne    800e51 <__udivdi3+0x81>
  800e46:	b8 01 00 00 00       	mov    $0x1,%eax
  800e4b:	31 d2                	xor    %edx,%edx
  800e4d:	f7 f3                	div    %ebx
  800e4f:	89 c1                	mov    %eax,%ecx
  800e51:	31 d2                	xor    %edx,%edx
  800e53:	89 f0                	mov    %esi,%eax
  800e55:	f7 f1                	div    %ecx
  800e57:	89 c6                	mov    %eax,%esi
  800e59:	89 e8                	mov    %ebp,%eax
  800e5b:	89 f7                	mov    %esi,%edi
  800e5d:	f7 f1                	div    %ecx
  800e5f:	89 fa                	mov    %edi,%edx
  800e61:	83 c4 1c             	add    $0x1c,%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    
  800e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e70:	89 f9                	mov    %edi,%ecx
  800e72:	b8 20 00 00 00       	mov    $0x20,%eax
  800e77:	29 f8                	sub    %edi,%eax
  800e79:	d3 e2                	shl    %cl,%edx
  800e7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e7f:	89 c1                	mov    %eax,%ecx
  800e81:	89 da                	mov    %ebx,%edx
  800e83:	d3 ea                	shr    %cl,%edx
  800e85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e89:	09 d1                	or     %edx,%ecx
  800e8b:	89 f2                	mov    %esi,%edx
  800e8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e91:	89 f9                	mov    %edi,%ecx
  800e93:	d3 e3                	shl    %cl,%ebx
  800e95:	89 c1                	mov    %eax,%ecx
  800e97:	d3 ea                	shr    %cl,%edx
  800e99:	89 f9                	mov    %edi,%ecx
  800e9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e9f:	89 eb                	mov    %ebp,%ebx
  800ea1:	d3 e6                	shl    %cl,%esi
  800ea3:	89 c1                	mov    %eax,%ecx
  800ea5:	d3 eb                	shr    %cl,%ebx
  800ea7:	09 de                	or     %ebx,%esi
  800ea9:	89 f0                	mov    %esi,%eax
  800eab:	f7 74 24 08          	divl   0x8(%esp)
  800eaf:	89 d6                	mov    %edx,%esi
  800eb1:	89 c3                	mov    %eax,%ebx
  800eb3:	f7 64 24 0c          	mull   0xc(%esp)
  800eb7:	39 d6                	cmp    %edx,%esi
  800eb9:	72 15                	jb     800ed0 <__udivdi3+0x100>
  800ebb:	89 f9                	mov    %edi,%ecx
  800ebd:	d3 e5                	shl    %cl,%ebp
  800ebf:	39 c5                	cmp    %eax,%ebp
  800ec1:	73 04                	jae    800ec7 <__udivdi3+0xf7>
  800ec3:	39 d6                	cmp    %edx,%esi
  800ec5:	74 09                	je     800ed0 <__udivdi3+0x100>
  800ec7:	89 d8                	mov    %ebx,%eax
  800ec9:	31 ff                	xor    %edi,%edi
  800ecb:	e9 40 ff ff ff       	jmp    800e10 <__udivdi3+0x40>
  800ed0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ed3:	31 ff                	xor    %edi,%edi
  800ed5:	e9 36 ff ff ff       	jmp    800e10 <__udivdi3+0x40>
  800eda:	66 90                	xchg   %ax,%ax
  800edc:	66 90                	xchg   %ax,%ax
  800ede:	66 90                	xchg   %ax,%ax

00800ee0 <__umoddi3>:
  800ee0:	f3 0f 1e fb          	endbr32 
  800ee4:	55                   	push   %ebp
  800ee5:	57                   	push   %edi
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
  800ee8:	83 ec 1c             	sub    $0x1c,%esp
  800eeb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800eef:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ef3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ef7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800efb:	85 c0                	test   %eax,%eax
  800efd:	75 19                	jne    800f18 <__umoddi3+0x38>
  800eff:	39 df                	cmp    %ebx,%edi
  800f01:	76 5d                	jbe    800f60 <__umoddi3+0x80>
  800f03:	89 f0                	mov    %esi,%eax
  800f05:	89 da                	mov    %ebx,%edx
  800f07:	f7 f7                	div    %edi
  800f09:	89 d0                	mov    %edx,%eax
  800f0b:	31 d2                	xor    %edx,%edx
  800f0d:	83 c4 1c             	add    $0x1c,%esp
  800f10:	5b                   	pop    %ebx
  800f11:	5e                   	pop    %esi
  800f12:	5f                   	pop    %edi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    
  800f15:	8d 76 00             	lea    0x0(%esi),%esi
  800f18:	89 f2                	mov    %esi,%edx
  800f1a:	39 d8                	cmp    %ebx,%eax
  800f1c:	76 12                	jbe    800f30 <__umoddi3+0x50>
  800f1e:	89 f0                	mov    %esi,%eax
  800f20:	89 da                	mov    %ebx,%edx
  800f22:	83 c4 1c             	add    $0x1c,%esp
  800f25:	5b                   	pop    %ebx
  800f26:	5e                   	pop    %esi
  800f27:	5f                   	pop    %edi
  800f28:	5d                   	pop    %ebp
  800f29:	c3                   	ret    
  800f2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f30:	0f bd e8             	bsr    %eax,%ebp
  800f33:	83 f5 1f             	xor    $0x1f,%ebp
  800f36:	75 50                	jne    800f88 <__umoddi3+0xa8>
  800f38:	39 d8                	cmp    %ebx,%eax
  800f3a:	0f 82 e0 00 00 00    	jb     801020 <__umoddi3+0x140>
  800f40:	89 d9                	mov    %ebx,%ecx
  800f42:	39 f7                	cmp    %esi,%edi
  800f44:	0f 86 d6 00 00 00    	jbe    801020 <__umoddi3+0x140>
  800f4a:	89 d0                	mov    %edx,%eax
  800f4c:	89 ca                	mov    %ecx,%edx
  800f4e:	83 c4 1c             	add    $0x1c,%esp
  800f51:	5b                   	pop    %ebx
  800f52:	5e                   	pop    %esi
  800f53:	5f                   	pop    %edi
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    
  800f56:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f5d:	8d 76 00             	lea    0x0(%esi),%esi
  800f60:	89 fd                	mov    %edi,%ebp
  800f62:	85 ff                	test   %edi,%edi
  800f64:	75 0b                	jne    800f71 <__umoddi3+0x91>
  800f66:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6b:	31 d2                	xor    %edx,%edx
  800f6d:	f7 f7                	div    %edi
  800f6f:	89 c5                	mov    %eax,%ebp
  800f71:	89 d8                	mov    %ebx,%eax
  800f73:	31 d2                	xor    %edx,%edx
  800f75:	f7 f5                	div    %ebp
  800f77:	89 f0                	mov    %esi,%eax
  800f79:	f7 f5                	div    %ebp
  800f7b:	89 d0                	mov    %edx,%eax
  800f7d:	31 d2                	xor    %edx,%edx
  800f7f:	eb 8c                	jmp    800f0d <__umoddi3+0x2d>
  800f81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f88:	89 e9                	mov    %ebp,%ecx
  800f8a:	ba 20 00 00 00       	mov    $0x20,%edx
  800f8f:	29 ea                	sub    %ebp,%edx
  800f91:	d3 e0                	shl    %cl,%eax
  800f93:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f97:	89 d1                	mov    %edx,%ecx
  800f99:	89 f8                	mov    %edi,%eax
  800f9b:	d3 e8                	shr    %cl,%eax
  800f9d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fa1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fa5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fa9:	09 c1                	or     %eax,%ecx
  800fab:	89 d8                	mov    %ebx,%eax
  800fad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fb1:	89 e9                	mov    %ebp,%ecx
  800fb3:	d3 e7                	shl    %cl,%edi
  800fb5:	89 d1                	mov    %edx,%ecx
  800fb7:	d3 e8                	shr    %cl,%eax
  800fb9:	89 e9                	mov    %ebp,%ecx
  800fbb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fbf:	d3 e3                	shl    %cl,%ebx
  800fc1:	89 c7                	mov    %eax,%edi
  800fc3:	89 d1                	mov    %edx,%ecx
  800fc5:	89 f0                	mov    %esi,%eax
  800fc7:	d3 e8                	shr    %cl,%eax
  800fc9:	89 e9                	mov    %ebp,%ecx
  800fcb:	89 fa                	mov    %edi,%edx
  800fcd:	d3 e6                	shl    %cl,%esi
  800fcf:	09 d8                	or     %ebx,%eax
  800fd1:	f7 74 24 08          	divl   0x8(%esp)
  800fd5:	89 d1                	mov    %edx,%ecx
  800fd7:	89 f3                	mov    %esi,%ebx
  800fd9:	f7 64 24 0c          	mull   0xc(%esp)
  800fdd:	89 c6                	mov    %eax,%esi
  800fdf:	89 d7                	mov    %edx,%edi
  800fe1:	39 d1                	cmp    %edx,%ecx
  800fe3:	72 06                	jb     800feb <__umoddi3+0x10b>
  800fe5:	75 10                	jne    800ff7 <__umoddi3+0x117>
  800fe7:	39 c3                	cmp    %eax,%ebx
  800fe9:	73 0c                	jae    800ff7 <__umoddi3+0x117>
  800feb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800fef:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800ff3:	89 d7                	mov    %edx,%edi
  800ff5:	89 c6                	mov    %eax,%esi
  800ff7:	89 ca                	mov    %ecx,%edx
  800ff9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ffe:	29 f3                	sub    %esi,%ebx
  801000:	19 fa                	sbb    %edi,%edx
  801002:	89 d0                	mov    %edx,%eax
  801004:	d3 e0                	shl    %cl,%eax
  801006:	89 e9                	mov    %ebp,%ecx
  801008:	d3 eb                	shr    %cl,%ebx
  80100a:	d3 ea                	shr    %cl,%edx
  80100c:	09 d8                	or     %ebx,%eax
  80100e:	83 c4 1c             	add    $0x1c,%esp
  801011:	5b                   	pop    %ebx
  801012:	5e                   	pop    %esi
  801013:	5f                   	pop    %edi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    
  801016:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80101d:	8d 76 00             	lea    0x0(%esi),%esi
  801020:	29 fe                	sub    %edi,%esi
  801022:	19 c3                	sbb    %eax,%ebx
  801024:	89 f2                	mov    %esi,%edx
  801026:	89 d9                	mov    %ebx,%ecx
  801028:	e9 1d ff ff ff       	jmp    800f4a <__umoddi3+0x6a>
