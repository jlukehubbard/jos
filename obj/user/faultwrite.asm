
obj/user/faultwrite:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	*(unsigned*)0 = 0;
  800037:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003e:	00 00 00 
}
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	f3 0f 1e fb          	endbr32 
  800046:	55                   	push   %ebp
  800047:	89 e5                	mov    %esp,%ebp
  800049:	56                   	push   %esi
  80004a:	53                   	push   %ebx
  80004b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800051:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800058:	00 00 00 
    envid_t envid = sys_getenvid();
  80005b:	e8 d6 00 00 00       	call   800136 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800060:	25 ff 03 00 00       	and    $0x3ff,%eax
  800065:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800068:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006d:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800072:	85 db                	test   %ebx,%ebx
  800074:	7e 07                	jle    80007d <libmain+0x3b>
		binaryname = argv[0];
  800076:	8b 06                	mov    (%esi),%eax
  800078:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007d:	83 ec 08             	sub    $0x8,%esp
  800080:	56                   	push   %esi
  800081:	53                   	push   %ebx
  800082:	e8 ac ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800087:	e8 0a 00 00 00       	call   800096 <exit>
}
  80008c:	83 c4 10             	add    $0x10,%esp
  80008f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800092:	5b                   	pop    %ebx
  800093:	5e                   	pop    %esi
  800094:	5d                   	pop    %ebp
  800095:	c3                   	ret    

00800096 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800096:	f3 0f 1e fb          	endbr32 
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
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
  800125:	68 4a 10 80 00       	push   $0x80104a
  80012a:	6a 23                	push   $0x23
  80012c:	68 67 10 80 00       	push   $0x801067
  800131:	e8 36 02 00 00       	call   80036c <_panic>

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
  8001b2:	68 4a 10 80 00       	push   $0x80104a
  8001b7:	6a 23                	push   $0x23
  8001b9:	68 67 10 80 00       	push   $0x801067
  8001be:	e8 a9 01 00 00       	call   80036c <_panic>

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
  8001f8:	68 4a 10 80 00       	push   $0x80104a
  8001fd:	6a 23                	push   $0x23
  8001ff:	68 67 10 80 00       	push   $0x801067
  800204:	e8 63 01 00 00       	call   80036c <_panic>

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
  80023e:	68 4a 10 80 00       	push   $0x80104a
  800243:	6a 23                	push   $0x23
  800245:	68 67 10 80 00       	push   $0x801067
  80024a:	e8 1d 01 00 00       	call   80036c <_panic>

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
  800284:	68 4a 10 80 00       	push   $0x80104a
  800289:	6a 23                	push   $0x23
  80028b:	68 67 10 80 00       	push   $0x801067
  800290:	e8 d7 00 00 00       	call   80036c <_panic>

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
  8002ca:	68 4a 10 80 00       	push   $0x80104a
  8002cf:	6a 23                	push   $0x23
  8002d1:	68 67 10 80 00       	push   $0x801067
  8002d6:	e8 91 00 00 00       	call   80036c <_panic>

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
  800310:	68 4a 10 80 00       	push   $0x80104a
  800315:	6a 23                	push   $0x23
  800317:	68 67 10 80 00       	push   $0x801067
  80031c:	e8 4b 00 00 00       	call   80036c <_panic>

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
	asm volatile("int %1\n"
  800352:	b9 00 00 00 00       	mov    $0x0,%ecx
  800357:	8b 55 08             	mov    0x8(%ebp),%edx
  80035a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80035f:	89 cb                	mov    %ecx,%ebx
  800361:	89 cf                	mov    %ecx,%edi
  800363:	89 ce                	mov    %ecx,%esi
  800365:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 0, (uint32_t)dstva, 0, 0, 0, 0);
}
  800367:	5b                   	pop    %ebx
  800368:	5e                   	pop    %esi
  800369:	5f                   	pop    %edi
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80036c:	f3 0f 1e fb          	endbr32 
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	56                   	push   %esi
  800374:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800375:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800378:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80037e:	e8 b3 fd ff ff       	call   800136 <sys_getenvid>
  800383:	83 ec 0c             	sub    $0xc,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	ff 75 08             	pushl  0x8(%ebp)
  80038c:	56                   	push   %esi
  80038d:	50                   	push   %eax
  80038e:	68 78 10 80 00       	push   $0x801078
  800393:	e8 bb 00 00 00       	call   800453 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800398:	83 c4 18             	add    $0x18,%esp
  80039b:	53                   	push   %ebx
  80039c:	ff 75 10             	pushl  0x10(%ebp)
  80039f:	e8 5a 00 00 00       	call   8003fe <vcprintf>
	cprintf("\n");
  8003a4:	c7 04 24 9b 10 80 00 	movl   $0x80109b,(%esp)
  8003ab:	e8 a3 00 00 00       	call   800453 <cprintf>
  8003b0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003b3:	cc                   	int3   
  8003b4:	eb fd                	jmp    8003b3 <_panic+0x47>

008003b6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003b6:	f3 0f 1e fb          	endbr32 
  8003ba:	55                   	push   %ebp
  8003bb:	89 e5                	mov    %esp,%ebp
  8003bd:	53                   	push   %ebx
  8003be:	83 ec 04             	sub    $0x4,%esp
  8003c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003c4:	8b 13                	mov    (%ebx),%edx
  8003c6:	8d 42 01             	lea    0x1(%edx),%eax
  8003c9:	89 03                	mov    %eax,(%ebx)
  8003cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ce:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003d2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003d7:	74 09                	je     8003e2 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003d9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003e0:	c9                   	leave  
  8003e1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003e2:	83 ec 08             	sub    $0x8,%esp
  8003e5:	68 ff 00 00 00       	push   $0xff
  8003ea:	8d 43 08             	lea    0x8(%ebx),%eax
  8003ed:	50                   	push   %eax
  8003ee:	e8 b9 fc ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8003f3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003f9:	83 c4 10             	add    $0x10,%esp
  8003fc:	eb db                	jmp    8003d9 <putch+0x23>

008003fe <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003fe:	f3 0f 1e fb          	endbr32 
  800402:	55                   	push   %ebp
  800403:	89 e5                	mov    %esp,%ebp
  800405:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80040b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800412:	00 00 00 
	b.cnt = 0;
  800415:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80041c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80041f:	ff 75 0c             	pushl  0xc(%ebp)
  800422:	ff 75 08             	pushl  0x8(%ebp)
  800425:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80042b:	50                   	push   %eax
  80042c:	68 b6 03 80 00       	push   $0x8003b6
  800431:	e8 20 01 00 00       	call   800556 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800436:	83 c4 08             	add    $0x8,%esp
  800439:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80043f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800445:	50                   	push   %eax
  800446:	e8 61 fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  80044b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800451:	c9                   	leave  
  800452:	c3                   	ret    

00800453 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800453:	f3 0f 1e fb          	endbr32 
  800457:	55                   	push   %ebp
  800458:	89 e5                	mov    %esp,%ebp
  80045a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80045d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800460:	50                   	push   %eax
  800461:	ff 75 08             	pushl  0x8(%ebp)
  800464:	e8 95 ff ff ff       	call   8003fe <vcprintf>
	va_end(ap);

	return cnt;
}
  800469:	c9                   	leave  
  80046a:	c3                   	ret    

0080046b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80046b:	55                   	push   %ebp
  80046c:	89 e5                	mov    %esp,%ebp
  80046e:	57                   	push   %edi
  80046f:	56                   	push   %esi
  800470:	53                   	push   %ebx
  800471:	83 ec 1c             	sub    $0x1c,%esp
  800474:	89 c7                	mov    %eax,%edi
  800476:	89 d6                	mov    %edx,%esi
  800478:	8b 45 08             	mov    0x8(%ebp),%eax
  80047b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80047e:	89 d1                	mov    %edx,%ecx
  800480:	89 c2                	mov    %eax,%edx
  800482:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800485:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800488:	8b 45 10             	mov    0x10(%ebp),%eax
  80048b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80048e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800491:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800498:	39 c2                	cmp    %eax,%edx
  80049a:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80049d:	72 3e                	jb     8004dd <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80049f:	83 ec 0c             	sub    $0xc,%esp
  8004a2:	ff 75 18             	pushl  0x18(%ebp)
  8004a5:	83 eb 01             	sub    $0x1,%ebx
  8004a8:	53                   	push   %ebx
  8004a9:	50                   	push   %eax
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b3:	ff 75 dc             	pushl  -0x24(%ebp)
  8004b6:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b9:	e8 12 09 00 00       	call   800dd0 <__udivdi3>
  8004be:	83 c4 18             	add    $0x18,%esp
  8004c1:	52                   	push   %edx
  8004c2:	50                   	push   %eax
  8004c3:	89 f2                	mov    %esi,%edx
  8004c5:	89 f8                	mov    %edi,%eax
  8004c7:	e8 9f ff ff ff       	call   80046b <printnum>
  8004cc:	83 c4 20             	add    $0x20,%esp
  8004cf:	eb 13                	jmp    8004e4 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	56                   	push   %esi
  8004d5:	ff 75 18             	pushl  0x18(%ebp)
  8004d8:	ff d7                	call   *%edi
  8004da:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004dd:	83 eb 01             	sub    $0x1,%ebx
  8004e0:	85 db                	test   %ebx,%ebx
  8004e2:	7f ed                	jg     8004d1 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	56                   	push   %esi
  8004e8:	83 ec 04             	sub    $0x4,%esp
  8004eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8004f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8004f7:	e8 e4 09 00 00       	call   800ee0 <__umoddi3>
  8004fc:	83 c4 14             	add    $0x14,%esp
  8004ff:	0f be 80 9d 10 80 00 	movsbl 0x80109d(%eax),%eax
  800506:	50                   	push   %eax
  800507:	ff d7                	call   *%edi
}
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80050f:	5b                   	pop    %ebx
  800510:	5e                   	pop    %esi
  800511:	5f                   	pop    %edi
  800512:	5d                   	pop    %ebp
  800513:	c3                   	ret    

00800514 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800514:	f3 0f 1e fb          	endbr32 
  800518:	55                   	push   %ebp
  800519:	89 e5                	mov    %esp,%ebp
  80051b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80051e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800522:	8b 10                	mov    (%eax),%edx
  800524:	3b 50 04             	cmp    0x4(%eax),%edx
  800527:	73 0a                	jae    800533 <sprintputch+0x1f>
		*b->buf++ = ch;
  800529:	8d 4a 01             	lea    0x1(%edx),%ecx
  80052c:	89 08                	mov    %ecx,(%eax)
  80052e:	8b 45 08             	mov    0x8(%ebp),%eax
  800531:	88 02                	mov    %al,(%edx)
}
  800533:	5d                   	pop    %ebp
  800534:	c3                   	ret    

00800535 <printfmt>:
{
  800535:	f3 0f 1e fb          	endbr32 
  800539:	55                   	push   %ebp
  80053a:	89 e5                	mov    %esp,%ebp
  80053c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80053f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800542:	50                   	push   %eax
  800543:	ff 75 10             	pushl  0x10(%ebp)
  800546:	ff 75 0c             	pushl  0xc(%ebp)
  800549:	ff 75 08             	pushl  0x8(%ebp)
  80054c:	e8 05 00 00 00       	call   800556 <vprintfmt>
}
  800551:	83 c4 10             	add    $0x10,%esp
  800554:	c9                   	leave  
  800555:	c3                   	ret    

00800556 <vprintfmt>:
{
  800556:	f3 0f 1e fb          	endbr32 
  80055a:	55                   	push   %ebp
  80055b:	89 e5                	mov    %esp,%ebp
  80055d:	57                   	push   %edi
  80055e:	56                   	push   %esi
  80055f:	53                   	push   %ebx
  800560:	83 ec 3c             	sub    $0x3c,%esp
  800563:	8b 75 08             	mov    0x8(%ebp),%esi
  800566:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800569:	8b 7d 10             	mov    0x10(%ebp),%edi
  80056c:	e9 4a 03 00 00       	jmp    8008bb <vprintfmt+0x365>
		padc = ' ';
  800571:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800575:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80057c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800583:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80058a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80058f:	8d 47 01             	lea    0x1(%edi),%eax
  800592:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800595:	0f b6 17             	movzbl (%edi),%edx
  800598:	8d 42 dd             	lea    -0x23(%edx),%eax
  80059b:	3c 55                	cmp    $0x55,%al
  80059d:	0f 87 de 03 00 00    	ja     800981 <vprintfmt+0x42b>
  8005a3:	0f b6 c0             	movzbl %al,%eax
  8005a6:	3e ff 24 85 e0 11 80 	notrack jmp *0x8011e0(,%eax,4)
  8005ad:	00 
  8005ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005b1:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005b5:	eb d8                	jmp    80058f <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ba:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005be:	eb cf                	jmp    80058f <vprintfmt+0x39>
  8005c0:	0f b6 d2             	movzbl %dl,%edx
  8005c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8005cb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005ce:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005d1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005d5:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005d8:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005db:	83 f9 09             	cmp    $0x9,%ecx
  8005de:	77 55                	ja     800635 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005e0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005e3:	eb e9                	jmp    8005ce <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8b 00                	mov    (%eax),%eax
  8005ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8d 40 04             	lea    0x4(%eax),%eax
  8005f3:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005f9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005fd:	79 90                	jns    80058f <vprintfmt+0x39>
				width = precision, precision = -1;
  8005ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800602:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800605:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80060c:	eb 81                	jmp    80058f <vprintfmt+0x39>
  80060e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800611:	85 c0                	test   %eax,%eax
  800613:	ba 00 00 00 00       	mov    $0x0,%edx
  800618:	0f 49 d0             	cmovns %eax,%edx
  80061b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80061e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800621:	e9 69 ff ff ff       	jmp    80058f <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800626:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800629:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800630:	e9 5a ff ff ff       	jmp    80058f <vprintfmt+0x39>
  800635:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800638:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063b:	eb bc                	jmp    8005f9 <vprintfmt+0xa3>
			lflag++;
  80063d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800640:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800643:	e9 47 ff ff ff       	jmp    80058f <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8d 78 04             	lea    0x4(%eax),%edi
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	53                   	push   %ebx
  800652:	ff 30                	pushl  (%eax)
  800654:	ff d6                	call   *%esi
			break;
  800656:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800659:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80065c:	e9 57 02 00 00       	jmp    8008b8 <vprintfmt+0x362>
			err = va_arg(ap, int);
  800661:	8b 45 14             	mov    0x14(%ebp),%eax
  800664:	8d 78 04             	lea    0x4(%eax),%edi
  800667:	8b 00                	mov    (%eax),%eax
  800669:	99                   	cltd   
  80066a:	31 d0                	xor    %edx,%eax
  80066c:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80066e:	83 f8 0f             	cmp    $0xf,%eax
  800671:	7f 23                	jg     800696 <vprintfmt+0x140>
  800673:	8b 14 85 40 13 80 00 	mov    0x801340(,%eax,4),%edx
  80067a:	85 d2                	test   %edx,%edx
  80067c:	74 18                	je     800696 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80067e:	52                   	push   %edx
  80067f:	68 be 10 80 00       	push   $0x8010be
  800684:	53                   	push   %ebx
  800685:	56                   	push   %esi
  800686:	e8 aa fe ff ff       	call   800535 <printfmt>
  80068b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80068e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800691:	e9 22 02 00 00       	jmp    8008b8 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800696:	50                   	push   %eax
  800697:	68 b5 10 80 00       	push   $0x8010b5
  80069c:	53                   	push   %ebx
  80069d:	56                   	push   %esi
  80069e:	e8 92 fe ff ff       	call   800535 <printfmt>
  8006a3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006a6:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8006a9:	e9 0a 02 00 00       	jmp    8008b8 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	83 c0 04             	add    $0x4,%eax
  8006b4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8006bc:	85 d2                	test   %edx,%edx
  8006be:	b8 ae 10 80 00       	mov    $0x8010ae,%eax
  8006c3:	0f 45 c2             	cmovne %edx,%eax
  8006c6:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006cd:	7e 06                	jle    8006d5 <vprintfmt+0x17f>
  8006cf:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006d3:	75 0d                	jne    8006e2 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006d8:	89 c7                	mov    %eax,%edi
  8006da:	03 45 e0             	add    -0x20(%ebp),%eax
  8006dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006e0:	eb 55                	jmp    800737 <vprintfmt+0x1e1>
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	ff 75 d8             	pushl  -0x28(%ebp)
  8006e8:	ff 75 cc             	pushl  -0x34(%ebp)
  8006eb:	e8 45 03 00 00       	call   800a35 <strnlen>
  8006f0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006f3:	29 c2                	sub    %eax,%edx
  8006f5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006f8:	83 c4 10             	add    $0x10,%esp
  8006fb:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006fd:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800701:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800704:	85 ff                	test   %edi,%edi
  800706:	7e 11                	jle    800719 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	53                   	push   %ebx
  80070c:	ff 75 e0             	pushl  -0x20(%ebp)
  80070f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800711:	83 ef 01             	sub    $0x1,%edi
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	eb eb                	jmp    800704 <vprintfmt+0x1ae>
  800719:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80071c:	85 d2                	test   %edx,%edx
  80071e:	b8 00 00 00 00       	mov    $0x0,%eax
  800723:	0f 49 c2             	cmovns %edx,%eax
  800726:	29 c2                	sub    %eax,%edx
  800728:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80072b:	eb a8                	jmp    8006d5 <vprintfmt+0x17f>
					putch(ch, putdat);
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	53                   	push   %ebx
  800731:	52                   	push   %edx
  800732:	ff d6                	call   *%esi
  800734:	83 c4 10             	add    $0x10,%esp
  800737:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80073a:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80073c:	83 c7 01             	add    $0x1,%edi
  80073f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800743:	0f be d0             	movsbl %al,%edx
  800746:	85 d2                	test   %edx,%edx
  800748:	74 4b                	je     800795 <vprintfmt+0x23f>
  80074a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80074e:	78 06                	js     800756 <vprintfmt+0x200>
  800750:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800754:	78 1e                	js     800774 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800756:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80075a:	74 d1                	je     80072d <vprintfmt+0x1d7>
  80075c:	0f be c0             	movsbl %al,%eax
  80075f:	83 e8 20             	sub    $0x20,%eax
  800762:	83 f8 5e             	cmp    $0x5e,%eax
  800765:	76 c6                	jbe    80072d <vprintfmt+0x1d7>
					putch('?', putdat);
  800767:	83 ec 08             	sub    $0x8,%esp
  80076a:	53                   	push   %ebx
  80076b:	6a 3f                	push   $0x3f
  80076d:	ff d6                	call   *%esi
  80076f:	83 c4 10             	add    $0x10,%esp
  800772:	eb c3                	jmp    800737 <vprintfmt+0x1e1>
  800774:	89 cf                	mov    %ecx,%edi
  800776:	eb 0e                	jmp    800786 <vprintfmt+0x230>
				putch(' ', putdat);
  800778:	83 ec 08             	sub    $0x8,%esp
  80077b:	53                   	push   %ebx
  80077c:	6a 20                	push   $0x20
  80077e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800780:	83 ef 01             	sub    $0x1,%edi
  800783:	83 c4 10             	add    $0x10,%esp
  800786:	85 ff                	test   %edi,%edi
  800788:	7f ee                	jg     800778 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80078a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80078d:	89 45 14             	mov    %eax,0x14(%ebp)
  800790:	e9 23 01 00 00       	jmp    8008b8 <vprintfmt+0x362>
  800795:	89 cf                	mov    %ecx,%edi
  800797:	eb ed                	jmp    800786 <vprintfmt+0x230>
	if (lflag >= 2)
  800799:	83 f9 01             	cmp    $0x1,%ecx
  80079c:	7f 1b                	jg     8007b9 <vprintfmt+0x263>
	else if (lflag)
  80079e:	85 c9                	test   %ecx,%ecx
  8007a0:	74 63                	je     800805 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8007a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a5:	8b 00                	mov    (%eax),%eax
  8007a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007aa:	99                   	cltd   
  8007ab:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b1:	8d 40 04             	lea    0x4(%eax),%eax
  8007b4:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b7:	eb 17                	jmp    8007d0 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8007b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bc:	8b 50 04             	mov    0x4(%eax),%edx
  8007bf:	8b 00                	mov    (%eax),%eax
  8007c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ca:	8d 40 08             	lea    0x8(%eax),%eax
  8007cd:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007d0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007d3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007d6:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007db:	85 c9                	test   %ecx,%ecx
  8007dd:	0f 89 bb 00 00 00    	jns    80089e <vprintfmt+0x348>
				putch('-', putdat);
  8007e3:	83 ec 08             	sub    $0x8,%esp
  8007e6:	53                   	push   %ebx
  8007e7:	6a 2d                	push   $0x2d
  8007e9:	ff d6                	call   *%esi
				num = -(long long) num;
  8007eb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007ee:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007f1:	f7 da                	neg    %edx
  8007f3:	83 d1 00             	adc    $0x0,%ecx
  8007f6:	f7 d9                	neg    %ecx
  8007f8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007fb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800800:	e9 99 00 00 00       	jmp    80089e <vprintfmt+0x348>
		return va_arg(*ap, int);
  800805:	8b 45 14             	mov    0x14(%ebp),%eax
  800808:	8b 00                	mov    (%eax),%eax
  80080a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80080d:	99                   	cltd   
  80080e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800811:	8b 45 14             	mov    0x14(%ebp),%eax
  800814:	8d 40 04             	lea    0x4(%eax),%eax
  800817:	89 45 14             	mov    %eax,0x14(%ebp)
  80081a:	eb b4                	jmp    8007d0 <vprintfmt+0x27a>
	if (lflag >= 2)
  80081c:	83 f9 01             	cmp    $0x1,%ecx
  80081f:	7f 1b                	jg     80083c <vprintfmt+0x2e6>
	else if (lflag)
  800821:	85 c9                	test   %ecx,%ecx
  800823:	74 2c                	je     800851 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800825:	8b 45 14             	mov    0x14(%ebp),%eax
  800828:	8b 10                	mov    (%eax),%edx
  80082a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082f:	8d 40 04             	lea    0x4(%eax),%eax
  800832:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800835:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80083a:	eb 62                	jmp    80089e <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80083c:	8b 45 14             	mov    0x14(%ebp),%eax
  80083f:	8b 10                	mov    (%eax),%edx
  800841:	8b 48 04             	mov    0x4(%eax),%ecx
  800844:	8d 40 08             	lea    0x8(%eax),%eax
  800847:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80084a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80084f:	eb 4d                	jmp    80089e <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800851:	8b 45 14             	mov    0x14(%ebp),%eax
  800854:	8b 10                	mov    (%eax),%edx
  800856:	b9 00 00 00 00       	mov    $0x0,%ecx
  80085b:	8d 40 04             	lea    0x4(%eax),%eax
  80085e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800861:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800866:	eb 36                	jmp    80089e <vprintfmt+0x348>
	if (lflag >= 2)
  800868:	83 f9 01             	cmp    $0x1,%ecx
  80086b:	7f 17                	jg     800884 <vprintfmt+0x32e>
	else if (lflag)
  80086d:	85 c9                	test   %ecx,%ecx
  80086f:	74 6e                	je     8008df <vprintfmt+0x389>
		return va_arg(*ap, long);
  800871:	8b 45 14             	mov    0x14(%ebp),%eax
  800874:	8b 10                	mov    (%eax),%edx
  800876:	89 d0                	mov    %edx,%eax
  800878:	99                   	cltd   
  800879:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80087c:	8d 49 04             	lea    0x4(%ecx),%ecx
  80087f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800882:	eb 11                	jmp    800895 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800884:	8b 45 14             	mov    0x14(%ebp),%eax
  800887:	8b 50 04             	mov    0x4(%eax),%edx
  80088a:	8b 00                	mov    (%eax),%eax
  80088c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80088f:	8d 49 08             	lea    0x8(%ecx),%ecx
  800892:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800895:	89 d1                	mov    %edx,%ecx
  800897:	89 c2                	mov    %eax,%edx
            base = 8;
  800899:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80089e:	83 ec 0c             	sub    $0xc,%esp
  8008a1:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008a5:	57                   	push   %edi
  8008a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8008a9:	50                   	push   %eax
  8008aa:	51                   	push   %ecx
  8008ab:	52                   	push   %edx
  8008ac:	89 da                	mov    %ebx,%edx
  8008ae:	89 f0                	mov    %esi,%eax
  8008b0:	e8 b6 fb ff ff       	call   80046b <printnum>
			break;
  8008b5:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008bb:	83 c7 01             	add    $0x1,%edi
  8008be:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008c2:	83 f8 25             	cmp    $0x25,%eax
  8008c5:	0f 84 a6 fc ff ff    	je     800571 <vprintfmt+0x1b>
			if (ch == '\0')
  8008cb:	85 c0                	test   %eax,%eax
  8008cd:	0f 84 ce 00 00 00    	je     8009a1 <vprintfmt+0x44b>
			putch(ch, putdat);
  8008d3:	83 ec 08             	sub    $0x8,%esp
  8008d6:	53                   	push   %ebx
  8008d7:	50                   	push   %eax
  8008d8:	ff d6                	call   *%esi
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	eb dc                	jmp    8008bb <vprintfmt+0x365>
		return va_arg(*ap, int);
  8008df:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e2:	8b 10                	mov    (%eax),%edx
  8008e4:	89 d0                	mov    %edx,%eax
  8008e6:	99                   	cltd   
  8008e7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008ea:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008ed:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008f0:	eb a3                	jmp    800895 <vprintfmt+0x33f>
			putch('0', putdat);
  8008f2:	83 ec 08             	sub    $0x8,%esp
  8008f5:	53                   	push   %ebx
  8008f6:	6a 30                	push   $0x30
  8008f8:	ff d6                	call   *%esi
			putch('x', putdat);
  8008fa:	83 c4 08             	add    $0x8,%esp
  8008fd:	53                   	push   %ebx
  8008fe:	6a 78                	push   $0x78
  800900:	ff d6                	call   *%esi
			num = (unsigned long long)
  800902:	8b 45 14             	mov    0x14(%ebp),%eax
  800905:	8b 10                	mov    (%eax),%edx
  800907:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80090c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80090f:	8d 40 04             	lea    0x4(%eax),%eax
  800912:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800915:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80091a:	eb 82                	jmp    80089e <vprintfmt+0x348>
	if (lflag >= 2)
  80091c:	83 f9 01             	cmp    $0x1,%ecx
  80091f:	7f 1e                	jg     80093f <vprintfmt+0x3e9>
	else if (lflag)
  800921:	85 c9                	test   %ecx,%ecx
  800923:	74 32                	je     800957 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800925:	8b 45 14             	mov    0x14(%ebp),%eax
  800928:	8b 10                	mov    (%eax),%edx
  80092a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80092f:	8d 40 04             	lea    0x4(%eax),%eax
  800932:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800935:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80093a:	e9 5f ff ff ff       	jmp    80089e <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80093f:	8b 45 14             	mov    0x14(%ebp),%eax
  800942:	8b 10                	mov    (%eax),%edx
  800944:	8b 48 04             	mov    0x4(%eax),%ecx
  800947:	8d 40 08             	lea    0x8(%eax),%eax
  80094a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80094d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800952:	e9 47 ff ff ff       	jmp    80089e <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800957:	8b 45 14             	mov    0x14(%ebp),%eax
  80095a:	8b 10                	mov    (%eax),%edx
  80095c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800961:	8d 40 04             	lea    0x4(%eax),%eax
  800964:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800967:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80096c:	e9 2d ff ff ff       	jmp    80089e <vprintfmt+0x348>
			putch(ch, putdat);
  800971:	83 ec 08             	sub    $0x8,%esp
  800974:	53                   	push   %ebx
  800975:	6a 25                	push   $0x25
  800977:	ff d6                	call   *%esi
			break;
  800979:	83 c4 10             	add    $0x10,%esp
  80097c:	e9 37 ff ff ff       	jmp    8008b8 <vprintfmt+0x362>
			putch('%', putdat);
  800981:	83 ec 08             	sub    $0x8,%esp
  800984:	53                   	push   %ebx
  800985:	6a 25                	push   $0x25
  800987:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800989:	83 c4 10             	add    $0x10,%esp
  80098c:	89 f8                	mov    %edi,%eax
  80098e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800992:	74 05                	je     800999 <vprintfmt+0x443>
  800994:	83 e8 01             	sub    $0x1,%eax
  800997:	eb f5                	jmp    80098e <vprintfmt+0x438>
  800999:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80099c:	e9 17 ff ff ff       	jmp    8008b8 <vprintfmt+0x362>
}
  8009a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009a4:	5b                   	pop    %ebx
  8009a5:	5e                   	pop    %esi
  8009a6:	5f                   	pop    %edi
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009a9:	f3 0f 1e fb          	endbr32 
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	83 ec 18             	sub    $0x18,%esp
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009bc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009c0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009ca:	85 c0                	test   %eax,%eax
  8009cc:	74 26                	je     8009f4 <vsnprintf+0x4b>
  8009ce:	85 d2                	test   %edx,%edx
  8009d0:	7e 22                	jle    8009f4 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009d2:	ff 75 14             	pushl  0x14(%ebp)
  8009d5:	ff 75 10             	pushl  0x10(%ebp)
  8009d8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009db:	50                   	push   %eax
  8009dc:	68 14 05 80 00       	push   $0x800514
  8009e1:	e8 70 fb ff ff       	call   800556 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009e9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ef:	83 c4 10             	add    $0x10,%esp
}
  8009f2:	c9                   	leave  
  8009f3:	c3                   	ret    
		return -E_INVAL;
  8009f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009f9:	eb f7                	jmp    8009f2 <vsnprintf+0x49>

008009fb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009fb:	f3 0f 1e fb          	endbr32 
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a05:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a08:	50                   	push   %eax
  800a09:	ff 75 10             	pushl  0x10(%ebp)
  800a0c:	ff 75 0c             	pushl  0xc(%ebp)
  800a0f:	ff 75 08             	pushl  0x8(%ebp)
  800a12:	e8 92 ff ff ff       	call   8009a9 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a17:	c9                   	leave  
  800a18:	c3                   	ret    

00800a19 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a19:	f3 0f 1e fb          	endbr32 
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
  800a28:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a2c:	74 05                	je     800a33 <strlen+0x1a>
		n++;
  800a2e:	83 c0 01             	add    $0x1,%eax
  800a31:	eb f5                	jmp    800a28 <strlen+0xf>
	return n;
}
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a35:	f3 0f 1e fb          	endbr32 
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
  800a47:	39 d0                	cmp    %edx,%eax
  800a49:	74 0d                	je     800a58 <strnlen+0x23>
  800a4b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a4f:	74 05                	je     800a56 <strnlen+0x21>
		n++;
  800a51:	83 c0 01             	add    $0x1,%eax
  800a54:	eb f1                	jmp    800a47 <strnlen+0x12>
  800a56:	89 c2                	mov    %eax,%edx
	return n;
}
  800a58:	89 d0                	mov    %edx,%eax
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a5c:	f3 0f 1e fb          	endbr32 
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	53                   	push   %ebx
  800a64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6f:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a73:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a76:	83 c0 01             	add    $0x1,%eax
  800a79:	84 d2                	test   %dl,%dl
  800a7b:	75 f2                	jne    800a6f <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a7d:	89 c8                	mov    %ecx,%eax
  800a7f:	5b                   	pop    %ebx
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a82:	f3 0f 1e fb          	endbr32 
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	53                   	push   %ebx
  800a8a:	83 ec 10             	sub    $0x10,%esp
  800a8d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a90:	53                   	push   %ebx
  800a91:	e8 83 ff ff ff       	call   800a19 <strlen>
  800a96:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a99:	ff 75 0c             	pushl  0xc(%ebp)
  800a9c:	01 d8                	add    %ebx,%eax
  800a9e:	50                   	push   %eax
  800a9f:	e8 b8 ff ff ff       	call   800a5c <strcpy>
	return dst;
}
  800aa4:	89 d8                	mov    %ebx,%eax
  800aa6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aa9:	c9                   	leave  
  800aaa:	c3                   	ret    

00800aab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aab:	f3 0f 1e fb          	endbr32 
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	56                   	push   %esi
  800ab3:	53                   	push   %ebx
  800ab4:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aba:	89 f3                	mov    %esi,%ebx
  800abc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800abf:	89 f0                	mov    %esi,%eax
  800ac1:	39 d8                	cmp    %ebx,%eax
  800ac3:	74 11                	je     800ad6 <strncpy+0x2b>
		*dst++ = *src;
  800ac5:	83 c0 01             	add    $0x1,%eax
  800ac8:	0f b6 0a             	movzbl (%edx),%ecx
  800acb:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ace:	80 f9 01             	cmp    $0x1,%cl
  800ad1:	83 da ff             	sbb    $0xffffffff,%edx
  800ad4:	eb eb                	jmp    800ac1 <strncpy+0x16>
	}
	return ret;
}
  800ad6:	89 f0                	mov    %esi,%eax
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800adc:	f3 0f 1e fb          	endbr32 
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
  800ae5:	8b 75 08             	mov    0x8(%ebp),%esi
  800ae8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aeb:	8b 55 10             	mov    0x10(%ebp),%edx
  800aee:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800af0:	85 d2                	test   %edx,%edx
  800af2:	74 21                	je     800b15 <strlcpy+0x39>
  800af4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800af8:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800afa:	39 c2                	cmp    %eax,%edx
  800afc:	74 14                	je     800b12 <strlcpy+0x36>
  800afe:	0f b6 19             	movzbl (%ecx),%ebx
  800b01:	84 db                	test   %bl,%bl
  800b03:	74 0b                	je     800b10 <strlcpy+0x34>
			*dst++ = *src++;
  800b05:	83 c1 01             	add    $0x1,%ecx
  800b08:	83 c2 01             	add    $0x1,%edx
  800b0b:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b0e:	eb ea                	jmp    800afa <strlcpy+0x1e>
  800b10:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b12:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b15:	29 f0                	sub    %esi,%eax
}
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b1b:	f3 0f 1e fb          	endbr32 
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b25:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b28:	0f b6 01             	movzbl (%ecx),%eax
  800b2b:	84 c0                	test   %al,%al
  800b2d:	74 0c                	je     800b3b <strcmp+0x20>
  800b2f:	3a 02                	cmp    (%edx),%al
  800b31:	75 08                	jne    800b3b <strcmp+0x20>
		p++, q++;
  800b33:	83 c1 01             	add    $0x1,%ecx
  800b36:	83 c2 01             	add    $0x1,%edx
  800b39:	eb ed                	jmp    800b28 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b3b:	0f b6 c0             	movzbl %al,%eax
  800b3e:	0f b6 12             	movzbl (%edx),%edx
  800b41:	29 d0                	sub    %edx,%eax
}
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b45:	f3 0f 1e fb          	endbr32 
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	53                   	push   %ebx
  800b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b50:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b53:	89 c3                	mov    %eax,%ebx
  800b55:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b58:	eb 06                	jmp    800b60 <strncmp+0x1b>
		n--, p++, q++;
  800b5a:	83 c0 01             	add    $0x1,%eax
  800b5d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b60:	39 d8                	cmp    %ebx,%eax
  800b62:	74 16                	je     800b7a <strncmp+0x35>
  800b64:	0f b6 08             	movzbl (%eax),%ecx
  800b67:	84 c9                	test   %cl,%cl
  800b69:	74 04                	je     800b6f <strncmp+0x2a>
  800b6b:	3a 0a                	cmp    (%edx),%cl
  800b6d:	74 eb                	je     800b5a <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b6f:	0f b6 00             	movzbl (%eax),%eax
  800b72:	0f b6 12             	movzbl (%edx),%edx
  800b75:	29 d0                	sub    %edx,%eax
}
  800b77:	5b                   	pop    %ebx
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    
		return 0;
  800b7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7f:	eb f6                	jmp    800b77 <strncmp+0x32>

00800b81 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b81:	f3 0f 1e fb          	endbr32 
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b8f:	0f b6 10             	movzbl (%eax),%edx
  800b92:	84 d2                	test   %dl,%dl
  800b94:	74 09                	je     800b9f <strchr+0x1e>
		if (*s == c)
  800b96:	38 ca                	cmp    %cl,%dl
  800b98:	74 0a                	je     800ba4 <strchr+0x23>
	for (; *s; s++)
  800b9a:	83 c0 01             	add    $0x1,%eax
  800b9d:	eb f0                	jmp    800b8f <strchr+0xe>
			return (char *) s;
	return 0;
  800b9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ba6:	f3 0f 1e fb          	endbr32 
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bb4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bb7:	38 ca                	cmp    %cl,%dl
  800bb9:	74 09                	je     800bc4 <strfind+0x1e>
  800bbb:	84 d2                	test   %dl,%dl
  800bbd:	74 05                	je     800bc4 <strfind+0x1e>
	for (; *s; s++)
  800bbf:	83 c0 01             	add    $0x1,%eax
  800bc2:	eb f0                	jmp    800bb4 <strfind+0xe>
			break;
	return (char *) s;
}
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bc6:	f3 0f 1e fb          	endbr32 
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	57                   	push   %edi
  800bce:	56                   	push   %esi
  800bcf:	53                   	push   %ebx
  800bd0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bd3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bd6:	85 c9                	test   %ecx,%ecx
  800bd8:	74 31                	je     800c0b <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bda:	89 f8                	mov    %edi,%eax
  800bdc:	09 c8                	or     %ecx,%eax
  800bde:	a8 03                	test   $0x3,%al
  800be0:	75 23                	jne    800c05 <memset+0x3f>
		c &= 0xFF;
  800be2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800be6:	89 d3                	mov    %edx,%ebx
  800be8:	c1 e3 08             	shl    $0x8,%ebx
  800beb:	89 d0                	mov    %edx,%eax
  800bed:	c1 e0 18             	shl    $0x18,%eax
  800bf0:	89 d6                	mov    %edx,%esi
  800bf2:	c1 e6 10             	shl    $0x10,%esi
  800bf5:	09 f0                	or     %esi,%eax
  800bf7:	09 c2                	or     %eax,%edx
  800bf9:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bfb:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800bfe:	89 d0                	mov    %edx,%eax
  800c00:	fc                   	cld    
  800c01:	f3 ab                	rep stos %eax,%es:(%edi)
  800c03:	eb 06                	jmp    800c0b <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c08:	fc                   	cld    
  800c09:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c0b:	89 f8                	mov    %edi,%eax
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c12:	f3 0f 1e fb          	endbr32 
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c21:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c24:	39 c6                	cmp    %eax,%esi
  800c26:	73 32                	jae    800c5a <memmove+0x48>
  800c28:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c2b:	39 c2                	cmp    %eax,%edx
  800c2d:	76 2b                	jbe    800c5a <memmove+0x48>
		s += n;
		d += n;
  800c2f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c32:	89 fe                	mov    %edi,%esi
  800c34:	09 ce                	or     %ecx,%esi
  800c36:	09 d6                	or     %edx,%esi
  800c38:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c3e:	75 0e                	jne    800c4e <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c40:	83 ef 04             	sub    $0x4,%edi
  800c43:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c46:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c49:	fd                   	std    
  800c4a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c4c:	eb 09                	jmp    800c57 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c4e:	83 ef 01             	sub    $0x1,%edi
  800c51:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c54:	fd                   	std    
  800c55:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c57:	fc                   	cld    
  800c58:	eb 1a                	jmp    800c74 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c5a:	89 c2                	mov    %eax,%edx
  800c5c:	09 ca                	or     %ecx,%edx
  800c5e:	09 f2                	or     %esi,%edx
  800c60:	f6 c2 03             	test   $0x3,%dl
  800c63:	75 0a                	jne    800c6f <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c65:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c68:	89 c7                	mov    %eax,%edi
  800c6a:	fc                   	cld    
  800c6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c6d:	eb 05                	jmp    800c74 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c6f:	89 c7                	mov    %eax,%edi
  800c71:	fc                   	cld    
  800c72:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c78:	f3 0f 1e fb          	endbr32 
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c82:	ff 75 10             	pushl  0x10(%ebp)
  800c85:	ff 75 0c             	pushl  0xc(%ebp)
  800c88:	ff 75 08             	pushl  0x8(%ebp)
  800c8b:	e8 82 ff ff ff       	call   800c12 <memmove>
}
  800c90:	c9                   	leave  
  800c91:	c3                   	ret    

00800c92 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c92:	f3 0f 1e fb          	endbr32 
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	56                   	push   %esi
  800c9a:	53                   	push   %ebx
  800c9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ca1:	89 c6                	mov    %eax,%esi
  800ca3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ca6:	39 f0                	cmp    %esi,%eax
  800ca8:	74 1c                	je     800cc6 <memcmp+0x34>
		if (*s1 != *s2)
  800caa:	0f b6 08             	movzbl (%eax),%ecx
  800cad:	0f b6 1a             	movzbl (%edx),%ebx
  800cb0:	38 d9                	cmp    %bl,%cl
  800cb2:	75 08                	jne    800cbc <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cb4:	83 c0 01             	add    $0x1,%eax
  800cb7:	83 c2 01             	add    $0x1,%edx
  800cba:	eb ea                	jmp    800ca6 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800cbc:	0f b6 c1             	movzbl %cl,%eax
  800cbf:	0f b6 db             	movzbl %bl,%ebx
  800cc2:	29 d8                	sub    %ebx,%eax
  800cc4:	eb 05                	jmp    800ccb <memcmp+0x39>
	}

	return 0;
  800cc6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ccf:	f3 0f 1e fb          	endbr32 
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cdc:	89 c2                	mov    %eax,%edx
  800cde:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ce1:	39 d0                	cmp    %edx,%eax
  800ce3:	73 09                	jae    800cee <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ce5:	38 08                	cmp    %cl,(%eax)
  800ce7:	74 05                	je     800cee <memfind+0x1f>
	for (; s < ends; s++)
  800ce9:	83 c0 01             	add    $0x1,%eax
  800cec:	eb f3                	jmp    800ce1 <memfind+0x12>
			break;
	return (void *) s;
}
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cf0:	f3 0f 1e fb          	endbr32 
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d00:	eb 03                	jmp    800d05 <strtol+0x15>
		s++;
  800d02:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d05:	0f b6 01             	movzbl (%ecx),%eax
  800d08:	3c 20                	cmp    $0x20,%al
  800d0a:	74 f6                	je     800d02 <strtol+0x12>
  800d0c:	3c 09                	cmp    $0x9,%al
  800d0e:	74 f2                	je     800d02 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d10:	3c 2b                	cmp    $0x2b,%al
  800d12:	74 2a                	je     800d3e <strtol+0x4e>
	int neg = 0;
  800d14:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d19:	3c 2d                	cmp    $0x2d,%al
  800d1b:	74 2b                	je     800d48 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d1d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d23:	75 0f                	jne    800d34 <strtol+0x44>
  800d25:	80 39 30             	cmpb   $0x30,(%ecx)
  800d28:	74 28                	je     800d52 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d2a:	85 db                	test   %ebx,%ebx
  800d2c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d31:	0f 44 d8             	cmove  %eax,%ebx
  800d34:	b8 00 00 00 00       	mov    $0x0,%eax
  800d39:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d3c:	eb 46                	jmp    800d84 <strtol+0x94>
		s++;
  800d3e:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d41:	bf 00 00 00 00       	mov    $0x0,%edi
  800d46:	eb d5                	jmp    800d1d <strtol+0x2d>
		s++, neg = 1;
  800d48:	83 c1 01             	add    $0x1,%ecx
  800d4b:	bf 01 00 00 00       	mov    $0x1,%edi
  800d50:	eb cb                	jmp    800d1d <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d52:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d56:	74 0e                	je     800d66 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d58:	85 db                	test   %ebx,%ebx
  800d5a:	75 d8                	jne    800d34 <strtol+0x44>
		s++, base = 8;
  800d5c:	83 c1 01             	add    $0x1,%ecx
  800d5f:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d64:	eb ce                	jmp    800d34 <strtol+0x44>
		s += 2, base = 16;
  800d66:	83 c1 02             	add    $0x2,%ecx
  800d69:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d6e:	eb c4                	jmp    800d34 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d70:	0f be d2             	movsbl %dl,%edx
  800d73:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d76:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d79:	7d 3a                	jge    800db5 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d7b:	83 c1 01             	add    $0x1,%ecx
  800d7e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d82:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d84:	0f b6 11             	movzbl (%ecx),%edx
  800d87:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d8a:	89 f3                	mov    %esi,%ebx
  800d8c:	80 fb 09             	cmp    $0x9,%bl
  800d8f:	76 df                	jbe    800d70 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800d91:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d94:	89 f3                	mov    %esi,%ebx
  800d96:	80 fb 19             	cmp    $0x19,%bl
  800d99:	77 08                	ja     800da3 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d9b:	0f be d2             	movsbl %dl,%edx
  800d9e:	83 ea 57             	sub    $0x57,%edx
  800da1:	eb d3                	jmp    800d76 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800da3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800da6:	89 f3                	mov    %esi,%ebx
  800da8:	80 fb 19             	cmp    $0x19,%bl
  800dab:	77 08                	ja     800db5 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dad:	0f be d2             	movsbl %dl,%edx
  800db0:	83 ea 37             	sub    $0x37,%edx
  800db3:	eb c1                	jmp    800d76 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800db5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800db9:	74 05                	je     800dc0 <strtol+0xd0>
		*endptr = (char *) s;
  800dbb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dbe:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800dc0:	89 c2                	mov    %eax,%edx
  800dc2:	f7 da                	neg    %edx
  800dc4:	85 ff                	test   %edi,%edi
  800dc6:	0f 45 c2             	cmovne %edx,%eax
}
  800dc9:	5b                   	pop    %ebx
  800dca:	5e                   	pop    %esi
  800dcb:	5f                   	pop    %edi
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    
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
