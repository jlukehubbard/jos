
obj/user/faultwritekernel:     file format elf32-i386


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
	*(unsigned*)0xf0100000 = 0;
  800037:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
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
  800125:	68 6a 10 80 00       	push   $0x80106a
  80012a:	6a 23                	push   $0x23
  80012c:	68 87 10 80 00       	push   $0x801087
  800131:	e8 57 02 00 00       	call   80038d <_panic>

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
  8001b2:	68 6a 10 80 00       	push   $0x80106a
  8001b7:	6a 23                	push   $0x23
  8001b9:	68 87 10 80 00       	push   $0x801087
  8001be:	e8 ca 01 00 00       	call   80038d <_panic>

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
  8001f8:	68 6a 10 80 00       	push   $0x80106a
  8001fd:	6a 23                	push   $0x23
  8001ff:	68 87 10 80 00       	push   $0x801087
  800204:	e8 84 01 00 00       	call   80038d <_panic>

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
  80023e:	68 6a 10 80 00       	push   $0x80106a
  800243:	6a 23                	push   $0x23
  800245:	68 87 10 80 00       	push   $0x801087
  80024a:	e8 3e 01 00 00       	call   80038d <_panic>

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
  800284:	68 6a 10 80 00       	push   $0x80106a
  800289:	6a 23                	push   $0x23
  80028b:	68 87 10 80 00       	push   $0x801087
  800290:	e8 f8 00 00 00       	call   80038d <_panic>

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
  8002ca:	68 6a 10 80 00       	push   $0x80106a
  8002cf:	6a 23                	push   $0x23
  8002d1:	68 87 10 80 00       	push   $0x801087
  8002d6:	e8 b2 00 00 00       	call   80038d <_panic>

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
  800310:	68 6a 10 80 00       	push   $0x80106a
  800315:	6a 23                	push   $0x23
  800317:	68 87 10 80 00       	push   $0x801087
  80031c:	e8 6c 00 00 00       	call   80038d <_panic>

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
  80037c:	68 6a 10 80 00       	push   $0x80106a
  800381:	6a 23                	push   $0x23
  800383:	68 87 10 80 00       	push   $0x801087
  800388:	e8 00 00 00 00       	call   80038d <_panic>

0080038d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80038d:	f3 0f 1e fb          	endbr32 
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	56                   	push   %esi
  800395:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800396:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800399:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80039f:	e8 92 fd ff ff       	call   800136 <sys_getenvid>
  8003a4:	83 ec 0c             	sub    $0xc,%esp
  8003a7:	ff 75 0c             	pushl  0xc(%ebp)
  8003aa:	ff 75 08             	pushl  0x8(%ebp)
  8003ad:	56                   	push   %esi
  8003ae:	50                   	push   %eax
  8003af:	68 98 10 80 00       	push   $0x801098
  8003b4:	e8 bb 00 00 00       	call   800474 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003b9:	83 c4 18             	add    $0x18,%esp
  8003bc:	53                   	push   %ebx
  8003bd:	ff 75 10             	pushl  0x10(%ebp)
  8003c0:	e8 5a 00 00 00       	call   80041f <vcprintf>
	cprintf("\n");
  8003c5:	c7 04 24 bb 10 80 00 	movl   $0x8010bb,(%esp)
  8003cc:	e8 a3 00 00 00       	call   800474 <cprintf>
  8003d1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003d4:	cc                   	int3   
  8003d5:	eb fd                	jmp    8003d4 <_panic+0x47>

008003d7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003d7:	f3 0f 1e fb          	endbr32 
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
  8003de:	53                   	push   %ebx
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003e5:	8b 13                	mov    (%ebx),%edx
  8003e7:	8d 42 01             	lea    0x1(%edx),%eax
  8003ea:	89 03                	mov    %eax,(%ebx)
  8003ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ef:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003f3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003f8:	74 09                	je     800403 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003fa:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800401:	c9                   	leave  
  800402:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800403:	83 ec 08             	sub    $0x8,%esp
  800406:	68 ff 00 00 00       	push   $0xff
  80040b:	8d 43 08             	lea    0x8(%ebx),%eax
  80040e:	50                   	push   %eax
  80040f:	e8 98 fc ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  800414:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80041a:	83 c4 10             	add    $0x10,%esp
  80041d:	eb db                	jmp    8003fa <putch+0x23>

0080041f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80041f:	f3 0f 1e fb          	endbr32 
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80042c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800433:	00 00 00 
	b.cnt = 0;
  800436:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80043d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800440:	ff 75 0c             	pushl  0xc(%ebp)
  800443:	ff 75 08             	pushl  0x8(%ebp)
  800446:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80044c:	50                   	push   %eax
  80044d:	68 d7 03 80 00       	push   $0x8003d7
  800452:	e8 20 01 00 00       	call   800577 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800457:	83 c4 08             	add    $0x8,%esp
  80045a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800460:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800466:	50                   	push   %eax
  800467:	e8 40 fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  80046c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800472:	c9                   	leave  
  800473:	c3                   	ret    

00800474 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800474:	f3 0f 1e fb          	endbr32 
  800478:	55                   	push   %ebp
  800479:	89 e5                	mov    %esp,%ebp
  80047b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80047e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800481:	50                   	push   %eax
  800482:	ff 75 08             	pushl  0x8(%ebp)
  800485:	e8 95 ff ff ff       	call   80041f <vcprintf>
	va_end(ap);

	return cnt;
}
  80048a:	c9                   	leave  
  80048b:	c3                   	ret    

0080048c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80048c:	55                   	push   %ebp
  80048d:	89 e5                	mov    %esp,%ebp
  80048f:	57                   	push   %edi
  800490:	56                   	push   %esi
  800491:	53                   	push   %ebx
  800492:	83 ec 1c             	sub    $0x1c,%esp
  800495:	89 c7                	mov    %eax,%edi
  800497:	89 d6                	mov    %edx,%esi
  800499:	8b 45 08             	mov    0x8(%ebp),%eax
  80049c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80049f:	89 d1                	mov    %edx,%ecx
  8004a1:	89 c2                	mov    %eax,%edx
  8004a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004a6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ac:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004b9:	39 c2                	cmp    %eax,%edx
  8004bb:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8004be:	72 3e                	jb     8004fe <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004c0:	83 ec 0c             	sub    $0xc,%esp
  8004c3:	ff 75 18             	pushl  0x18(%ebp)
  8004c6:	83 eb 01             	sub    $0x1,%ebx
  8004c9:	53                   	push   %ebx
  8004ca:	50                   	push   %eax
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d4:	ff 75 dc             	pushl  -0x24(%ebp)
  8004d7:	ff 75 d8             	pushl  -0x28(%ebp)
  8004da:	e8 11 09 00 00       	call   800df0 <__udivdi3>
  8004df:	83 c4 18             	add    $0x18,%esp
  8004e2:	52                   	push   %edx
  8004e3:	50                   	push   %eax
  8004e4:	89 f2                	mov    %esi,%edx
  8004e6:	89 f8                	mov    %edi,%eax
  8004e8:	e8 9f ff ff ff       	call   80048c <printnum>
  8004ed:	83 c4 20             	add    $0x20,%esp
  8004f0:	eb 13                	jmp    800505 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	56                   	push   %esi
  8004f6:	ff 75 18             	pushl  0x18(%ebp)
  8004f9:	ff d7                	call   *%edi
  8004fb:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004fe:	83 eb 01             	sub    $0x1,%ebx
  800501:	85 db                	test   %ebx,%ebx
  800503:	7f ed                	jg     8004f2 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	56                   	push   %esi
  800509:	83 ec 04             	sub    $0x4,%esp
  80050c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80050f:	ff 75 e0             	pushl  -0x20(%ebp)
  800512:	ff 75 dc             	pushl  -0x24(%ebp)
  800515:	ff 75 d8             	pushl  -0x28(%ebp)
  800518:	e8 e3 09 00 00       	call   800f00 <__umoddi3>
  80051d:	83 c4 14             	add    $0x14,%esp
  800520:	0f be 80 bd 10 80 00 	movsbl 0x8010bd(%eax),%eax
  800527:	50                   	push   %eax
  800528:	ff d7                	call   *%edi
}
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800530:	5b                   	pop    %ebx
  800531:	5e                   	pop    %esi
  800532:	5f                   	pop    %edi
  800533:	5d                   	pop    %ebp
  800534:	c3                   	ret    

00800535 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800535:	f3 0f 1e fb          	endbr32 
  800539:	55                   	push   %ebp
  80053a:	89 e5                	mov    %esp,%ebp
  80053c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80053f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800543:	8b 10                	mov    (%eax),%edx
  800545:	3b 50 04             	cmp    0x4(%eax),%edx
  800548:	73 0a                	jae    800554 <sprintputch+0x1f>
		*b->buf++ = ch;
  80054a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80054d:	89 08                	mov    %ecx,(%eax)
  80054f:	8b 45 08             	mov    0x8(%ebp),%eax
  800552:	88 02                	mov    %al,(%edx)
}
  800554:	5d                   	pop    %ebp
  800555:	c3                   	ret    

00800556 <printfmt>:
{
  800556:	f3 0f 1e fb          	endbr32 
  80055a:	55                   	push   %ebp
  80055b:	89 e5                	mov    %esp,%ebp
  80055d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800560:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800563:	50                   	push   %eax
  800564:	ff 75 10             	pushl  0x10(%ebp)
  800567:	ff 75 0c             	pushl  0xc(%ebp)
  80056a:	ff 75 08             	pushl  0x8(%ebp)
  80056d:	e8 05 00 00 00       	call   800577 <vprintfmt>
}
  800572:	83 c4 10             	add    $0x10,%esp
  800575:	c9                   	leave  
  800576:	c3                   	ret    

00800577 <vprintfmt>:
{
  800577:	f3 0f 1e fb          	endbr32 
  80057b:	55                   	push   %ebp
  80057c:	89 e5                	mov    %esp,%ebp
  80057e:	57                   	push   %edi
  80057f:	56                   	push   %esi
  800580:	53                   	push   %ebx
  800581:	83 ec 3c             	sub    $0x3c,%esp
  800584:	8b 75 08             	mov    0x8(%ebp),%esi
  800587:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80058d:	e9 4a 03 00 00       	jmp    8008dc <vprintfmt+0x365>
		padc = ' ';
  800592:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800596:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80059d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8005a4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8005ab:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	8d 47 01             	lea    0x1(%edi),%eax
  8005b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005b6:	0f b6 17             	movzbl (%edi),%edx
  8005b9:	8d 42 dd             	lea    -0x23(%edx),%eax
  8005bc:	3c 55                	cmp    $0x55,%al
  8005be:	0f 87 de 03 00 00    	ja     8009a2 <vprintfmt+0x42b>
  8005c4:	0f b6 c0             	movzbl %al,%eax
  8005c7:	3e ff 24 85 00 12 80 	notrack jmp *0x801200(,%eax,4)
  8005ce:	00 
  8005cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005d2:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005d6:	eb d8                	jmp    8005b0 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005db:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005df:	eb cf                	jmp    8005b0 <vprintfmt+0x39>
  8005e1:	0f b6 d2             	movzbl %dl,%edx
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ec:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005ef:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005f2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005f6:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005f9:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005fc:	83 f9 09             	cmp    $0x9,%ecx
  8005ff:	77 55                	ja     800656 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800601:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800604:	eb e9                	jmp    8005ef <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8b 00                	mov    (%eax),%eax
  80060b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 40 04             	lea    0x4(%eax),%eax
  800614:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800617:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80061a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80061e:	79 90                	jns    8005b0 <vprintfmt+0x39>
				width = precision, precision = -1;
  800620:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800623:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800626:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80062d:	eb 81                	jmp    8005b0 <vprintfmt+0x39>
  80062f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800632:	85 c0                	test   %eax,%eax
  800634:	ba 00 00 00 00       	mov    $0x0,%edx
  800639:	0f 49 d0             	cmovns %eax,%edx
  80063c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80063f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800642:	e9 69 ff ff ff       	jmp    8005b0 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800647:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80064a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800651:	e9 5a ff ff ff       	jmp    8005b0 <vprintfmt+0x39>
  800656:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800659:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065c:	eb bc                	jmp    80061a <vprintfmt+0xa3>
			lflag++;
  80065e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800661:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800664:	e9 47 ff ff ff       	jmp    8005b0 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8d 78 04             	lea    0x4(%eax),%edi
  80066f:	83 ec 08             	sub    $0x8,%esp
  800672:	53                   	push   %ebx
  800673:	ff 30                	pushl  (%eax)
  800675:	ff d6                	call   *%esi
			break;
  800677:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80067a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80067d:	e9 57 02 00 00       	jmp    8008d9 <vprintfmt+0x362>
			err = va_arg(ap, int);
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8d 78 04             	lea    0x4(%eax),%edi
  800688:	8b 00                	mov    (%eax),%eax
  80068a:	99                   	cltd   
  80068b:	31 d0                	xor    %edx,%eax
  80068d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80068f:	83 f8 0f             	cmp    $0xf,%eax
  800692:	7f 23                	jg     8006b7 <vprintfmt+0x140>
  800694:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  80069b:	85 d2                	test   %edx,%edx
  80069d:	74 18                	je     8006b7 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80069f:	52                   	push   %edx
  8006a0:	68 de 10 80 00       	push   $0x8010de
  8006a5:	53                   	push   %ebx
  8006a6:	56                   	push   %esi
  8006a7:	e8 aa fe ff ff       	call   800556 <printfmt>
  8006ac:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006af:	89 7d 14             	mov    %edi,0x14(%ebp)
  8006b2:	e9 22 02 00 00       	jmp    8008d9 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8006b7:	50                   	push   %eax
  8006b8:	68 d5 10 80 00       	push   $0x8010d5
  8006bd:	53                   	push   %ebx
  8006be:	56                   	push   %esi
  8006bf:	e8 92 fe ff ff       	call   800556 <printfmt>
  8006c4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006c7:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8006ca:	e9 0a 02 00 00       	jmp    8008d9 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	83 c0 04             	add    $0x4,%eax
  8006d5:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8006dd:	85 d2                	test   %edx,%edx
  8006df:	b8 ce 10 80 00       	mov    $0x8010ce,%eax
  8006e4:	0f 45 c2             	cmovne %edx,%eax
  8006e7:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006ea:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ee:	7e 06                	jle    8006f6 <vprintfmt+0x17f>
  8006f0:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006f4:	75 0d                	jne    800703 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006f9:	89 c7                	mov    %eax,%edi
  8006fb:	03 45 e0             	add    -0x20(%ebp),%eax
  8006fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800701:	eb 55                	jmp    800758 <vprintfmt+0x1e1>
  800703:	83 ec 08             	sub    $0x8,%esp
  800706:	ff 75 d8             	pushl  -0x28(%ebp)
  800709:	ff 75 cc             	pushl  -0x34(%ebp)
  80070c:	e8 45 03 00 00       	call   800a56 <strnlen>
  800711:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800714:	29 c2                	sub    %eax,%edx
  800716:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800719:	83 c4 10             	add    $0x10,%esp
  80071c:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80071e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800722:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800725:	85 ff                	test   %edi,%edi
  800727:	7e 11                	jle    80073a <vprintfmt+0x1c3>
					putch(padc, putdat);
  800729:	83 ec 08             	sub    $0x8,%esp
  80072c:	53                   	push   %ebx
  80072d:	ff 75 e0             	pushl  -0x20(%ebp)
  800730:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800732:	83 ef 01             	sub    $0x1,%edi
  800735:	83 c4 10             	add    $0x10,%esp
  800738:	eb eb                	jmp    800725 <vprintfmt+0x1ae>
  80073a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80073d:	85 d2                	test   %edx,%edx
  80073f:	b8 00 00 00 00       	mov    $0x0,%eax
  800744:	0f 49 c2             	cmovns %edx,%eax
  800747:	29 c2                	sub    %eax,%edx
  800749:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80074c:	eb a8                	jmp    8006f6 <vprintfmt+0x17f>
					putch(ch, putdat);
  80074e:	83 ec 08             	sub    $0x8,%esp
  800751:	53                   	push   %ebx
  800752:	52                   	push   %edx
  800753:	ff d6                	call   *%esi
  800755:	83 c4 10             	add    $0x10,%esp
  800758:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80075b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80075d:	83 c7 01             	add    $0x1,%edi
  800760:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800764:	0f be d0             	movsbl %al,%edx
  800767:	85 d2                	test   %edx,%edx
  800769:	74 4b                	je     8007b6 <vprintfmt+0x23f>
  80076b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80076f:	78 06                	js     800777 <vprintfmt+0x200>
  800771:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800775:	78 1e                	js     800795 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800777:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80077b:	74 d1                	je     80074e <vprintfmt+0x1d7>
  80077d:	0f be c0             	movsbl %al,%eax
  800780:	83 e8 20             	sub    $0x20,%eax
  800783:	83 f8 5e             	cmp    $0x5e,%eax
  800786:	76 c6                	jbe    80074e <vprintfmt+0x1d7>
					putch('?', putdat);
  800788:	83 ec 08             	sub    $0x8,%esp
  80078b:	53                   	push   %ebx
  80078c:	6a 3f                	push   $0x3f
  80078e:	ff d6                	call   *%esi
  800790:	83 c4 10             	add    $0x10,%esp
  800793:	eb c3                	jmp    800758 <vprintfmt+0x1e1>
  800795:	89 cf                	mov    %ecx,%edi
  800797:	eb 0e                	jmp    8007a7 <vprintfmt+0x230>
				putch(' ', putdat);
  800799:	83 ec 08             	sub    $0x8,%esp
  80079c:	53                   	push   %ebx
  80079d:	6a 20                	push   $0x20
  80079f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8007a1:	83 ef 01             	sub    $0x1,%edi
  8007a4:	83 c4 10             	add    $0x10,%esp
  8007a7:	85 ff                	test   %edi,%edi
  8007a9:	7f ee                	jg     800799 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8007ab:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007ae:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b1:	e9 23 01 00 00       	jmp    8008d9 <vprintfmt+0x362>
  8007b6:	89 cf                	mov    %ecx,%edi
  8007b8:	eb ed                	jmp    8007a7 <vprintfmt+0x230>
	if (lflag >= 2)
  8007ba:	83 f9 01             	cmp    $0x1,%ecx
  8007bd:	7f 1b                	jg     8007da <vprintfmt+0x263>
	else if (lflag)
  8007bf:	85 c9                	test   %ecx,%ecx
  8007c1:	74 63                	je     800826 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	8b 00                	mov    (%eax),%eax
  8007c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007cb:	99                   	cltd   
  8007cc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8d 40 04             	lea    0x4(%eax),%eax
  8007d5:	89 45 14             	mov    %eax,0x14(%ebp)
  8007d8:	eb 17                	jmp    8007f1 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8007da:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dd:	8b 50 04             	mov    0x4(%eax),%edx
  8007e0:	8b 00                	mov    (%eax),%eax
  8007e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8d 40 08             	lea    0x8(%eax),%eax
  8007ee:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007f4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007f7:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007fc:	85 c9                	test   %ecx,%ecx
  8007fe:	0f 89 bb 00 00 00    	jns    8008bf <vprintfmt+0x348>
				putch('-', putdat);
  800804:	83 ec 08             	sub    $0x8,%esp
  800807:	53                   	push   %ebx
  800808:	6a 2d                	push   $0x2d
  80080a:	ff d6                	call   *%esi
				num = -(long long) num;
  80080c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80080f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800812:	f7 da                	neg    %edx
  800814:	83 d1 00             	adc    $0x0,%ecx
  800817:	f7 d9                	neg    %ecx
  800819:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80081c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800821:	e9 99 00 00 00       	jmp    8008bf <vprintfmt+0x348>
		return va_arg(*ap, int);
  800826:	8b 45 14             	mov    0x14(%ebp),%eax
  800829:	8b 00                	mov    (%eax),%eax
  80082b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80082e:	99                   	cltd   
  80082f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800832:	8b 45 14             	mov    0x14(%ebp),%eax
  800835:	8d 40 04             	lea    0x4(%eax),%eax
  800838:	89 45 14             	mov    %eax,0x14(%ebp)
  80083b:	eb b4                	jmp    8007f1 <vprintfmt+0x27a>
	if (lflag >= 2)
  80083d:	83 f9 01             	cmp    $0x1,%ecx
  800840:	7f 1b                	jg     80085d <vprintfmt+0x2e6>
	else if (lflag)
  800842:	85 c9                	test   %ecx,%ecx
  800844:	74 2c                	je     800872 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800846:	8b 45 14             	mov    0x14(%ebp),%eax
  800849:	8b 10                	mov    (%eax),%edx
  80084b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800850:	8d 40 04             	lea    0x4(%eax),%eax
  800853:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800856:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80085b:	eb 62                	jmp    8008bf <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80085d:	8b 45 14             	mov    0x14(%ebp),%eax
  800860:	8b 10                	mov    (%eax),%edx
  800862:	8b 48 04             	mov    0x4(%eax),%ecx
  800865:	8d 40 08             	lea    0x8(%eax),%eax
  800868:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80086b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800870:	eb 4d                	jmp    8008bf <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800872:	8b 45 14             	mov    0x14(%ebp),%eax
  800875:	8b 10                	mov    (%eax),%edx
  800877:	b9 00 00 00 00       	mov    $0x0,%ecx
  80087c:	8d 40 04             	lea    0x4(%eax),%eax
  80087f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800882:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800887:	eb 36                	jmp    8008bf <vprintfmt+0x348>
	if (lflag >= 2)
  800889:	83 f9 01             	cmp    $0x1,%ecx
  80088c:	7f 17                	jg     8008a5 <vprintfmt+0x32e>
	else if (lflag)
  80088e:	85 c9                	test   %ecx,%ecx
  800890:	74 6e                	je     800900 <vprintfmt+0x389>
		return va_arg(*ap, long);
  800892:	8b 45 14             	mov    0x14(%ebp),%eax
  800895:	8b 10                	mov    (%eax),%edx
  800897:	89 d0                	mov    %edx,%eax
  800899:	99                   	cltd   
  80089a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80089d:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008a0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008a3:	eb 11                	jmp    8008b6 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8008a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a8:	8b 50 04             	mov    0x4(%eax),%edx
  8008ab:	8b 00                	mov    (%eax),%eax
  8008ad:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008b0:	8d 49 08             	lea    0x8(%ecx),%ecx
  8008b3:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8008b6:	89 d1                	mov    %edx,%ecx
  8008b8:	89 c2                	mov    %eax,%edx
            base = 8;
  8008ba:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008bf:	83 ec 0c             	sub    $0xc,%esp
  8008c2:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008c6:	57                   	push   %edi
  8008c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8008ca:	50                   	push   %eax
  8008cb:	51                   	push   %ecx
  8008cc:	52                   	push   %edx
  8008cd:	89 da                	mov    %ebx,%edx
  8008cf:	89 f0                	mov    %esi,%eax
  8008d1:	e8 b6 fb ff ff       	call   80048c <printnum>
			break;
  8008d6:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008dc:	83 c7 01             	add    $0x1,%edi
  8008df:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008e3:	83 f8 25             	cmp    $0x25,%eax
  8008e6:	0f 84 a6 fc ff ff    	je     800592 <vprintfmt+0x1b>
			if (ch == '\0')
  8008ec:	85 c0                	test   %eax,%eax
  8008ee:	0f 84 ce 00 00 00    	je     8009c2 <vprintfmt+0x44b>
			putch(ch, putdat);
  8008f4:	83 ec 08             	sub    $0x8,%esp
  8008f7:	53                   	push   %ebx
  8008f8:	50                   	push   %eax
  8008f9:	ff d6                	call   *%esi
  8008fb:	83 c4 10             	add    $0x10,%esp
  8008fe:	eb dc                	jmp    8008dc <vprintfmt+0x365>
		return va_arg(*ap, int);
  800900:	8b 45 14             	mov    0x14(%ebp),%eax
  800903:	8b 10                	mov    (%eax),%edx
  800905:	89 d0                	mov    %edx,%eax
  800907:	99                   	cltd   
  800908:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80090b:	8d 49 04             	lea    0x4(%ecx),%ecx
  80090e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800911:	eb a3                	jmp    8008b6 <vprintfmt+0x33f>
			putch('0', putdat);
  800913:	83 ec 08             	sub    $0x8,%esp
  800916:	53                   	push   %ebx
  800917:	6a 30                	push   $0x30
  800919:	ff d6                	call   *%esi
			putch('x', putdat);
  80091b:	83 c4 08             	add    $0x8,%esp
  80091e:	53                   	push   %ebx
  80091f:	6a 78                	push   $0x78
  800921:	ff d6                	call   *%esi
			num = (unsigned long long)
  800923:	8b 45 14             	mov    0x14(%ebp),%eax
  800926:	8b 10                	mov    (%eax),%edx
  800928:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80092d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800930:	8d 40 04             	lea    0x4(%eax),%eax
  800933:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800936:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80093b:	eb 82                	jmp    8008bf <vprintfmt+0x348>
	if (lflag >= 2)
  80093d:	83 f9 01             	cmp    $0x1,%ecx
  800940:	7f 1e                	jg     800960 <vprintfmt+0x3e9>
	else if (lflag)
  800942:	85 c9                	test   %ecx,%ecx
  800944:	74 32                	je     800978 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800946:	8b 45 14             	mov    0x14(%ebp),%eax
  800949:	8b 10                	mov    (%eax),%edx
  80094b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800950:	8d 40 04             	lea    0x4(%eax),%eax
  800953:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800956:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80095b:	e9 5f ff ff ff       	jmp    8008bf <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800960:	8b 45 14             	mov    0x14(%ebp),%eax
  800963:	8b 10                	mov    (%eax),%edx
  800965:	8b 48 04             	mov    0x4(%eax),%ecx
  800968:	8d 40 08             	lea    0x8(%eax),%eax
  80096b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80096e:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800973:	e9 47 ff ff ff       	jmp    8008bf <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800978:	8b 45 14             	mov    0x14(%ebp),%eax
  80097b:	8b 10                	mov    (%eax),%edx
  80097d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800982:	8d 40 04             	lea    0x4(%eax),%eax
  800985:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800988:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80098d:	e9 2d ff ff ff       	jmp    8008bf <vprintfmt+0x348>
			putch(ch, putdat);
  800992:	83 ec 08             	sub    $0x8,%esp
  800995:	53                   	push   %ebx
  800996:	6a 25                	push   $0x25
  800998:	ff d6                	call   *%esi
			break;
  80099a:	83 c4 10             	add    $0x10,%esp
  80099d:	e9 37 ff ff ff       	jmp    8008d9 <vprintfmt+0x362>
			putch('%', putdat);
  8009a2:	83 ec 08             	sub    $0x8,%esp
  8009a5:	53                   	push   %ebx
  8009a6:	6a 25                	push   $0x25
  8009a8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009aa:	83 c4 10             	add    $0x10,%esp
  8009ad:	89 f8                	mov    %edi,%eax
  8009af:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009b3:	74 05                	je     8009ba <vprintfmt+0x443>
  8009b5:	83 e8 01             	sub    $0x1,%eax
  8009b8:	eb f5                	jmp    8009af <vprintfmt+0x438>
  8009ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009bd:	e9 17 ff ff ff       	jmp    8008d9 <vprintfmt+0x362>
}
  8009c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009c5:	5b                   	pop    %ebx
  8009c6:	5e                   	pop    %esi
  8009c7:	5f                   	pop    %edi
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009ca:	f3 0f 1e fb          	endbr32 
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	83 ec 18             	sub    $0x18,%esp
  8009d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009da:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009dd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009e1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009eb:	85 c0                	test   %eax,%eax
  8009ed:	74 26                	je     800a15 <vsnprintf+0x4b>
  8009ef:	85 d2                	test   %edx,%edx
  8009f1:	7e 22                	jle    800a15 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009f3:	ff 75 14             	pushl  0x14(%ebp)
  8009f6:	ff 75 10             	pushl  0x10(%ebp)
  8009f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009fc:	50                   	push   %eax
  8009fd:	68 35 05 80 00       	push   $0x800535
  800a02:	e8 70 fb ff ff       	call   800577 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a07:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a0a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a10:	83 c4 10             	add    $0x10,%esp
}
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    
		return -E_INVAL;
  800a15:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a1a:	eb f7                	jmp    800a13 <vsnprintf+0x49>

00800a1c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a1c:	f3 0f 1e fb          	endbr32 
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a26:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a29:	50                   	push   %eax
  800a2a:	ff 75 10             	pushl  0x10(%ebp)
  800a2d:	ff 75 0c             	pushl  0xc(%ebp)
  800a30:	ff 75 08             	pushl  0x8(%ebp)
  800a33:	e8 92 ff ff ff       	call   8009ca <vsnprintf>
	va_end(ap);

	return rc;
}
  800a38:	c9                   	leave  
  800a39:	c3                   	ret    

00800a3a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a3a:	f3 0f 1e fb          	endbr32 
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
  800a49:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a4d:	74 05                	je     800a54 <strlen+0x1a>
		n++;
  800a4f:	83 c0 01             	add    $0x1,%eax
  800a52:	eb f5                	jmp    800a49 <strlen+0xf>
	return n;
}
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a56:	f3 0f 1e fb          	endbr32 
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a60:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
  800a68:	39 d0                	cmp    %edx,%eax
  800a6a:	74 0d                	je     800a79 <strnlen+0x23>
  800a6c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a70:	74 05                	je     800a77 <strnlen+0x21>
		n++;
  800a72:	83 c0 01             	add    $0x1,%eax
  800a75:	eb f1                	jmp    800a68 <strnlen+0x12>
  800a77:	89 c2                	mov    %eax,%edx
	return n;
}
  800a79:	89 d0                	mov    %edx,%eax
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a7d:	f3 0f 1e fb          	endbr32 
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	53                   	push   %ebx
  800a85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a90:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a94:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a97:	83 c0 01             	add    $0x1,%eax
  800a9a:	84 d2                	test   %dl,%dl
  800a9c:	75 f2                	jne    800a90 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a9e:	89 c8                	mov    %ecx,%eax
  800aa0:	5b                   	pop    %ebx
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aa3:	f3 0f 1e fb          	endbr32 
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	53                   	push   %ebx
  800aab:	83 ec 10             	sub    $0x10,%esp
  800aae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ab1:	53                   	push   %ebx
  800ab2:	e8 83 ff ff ff       	call   800a3a <strlen>
  800ab7:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800aba:	ff 75 0c             	pushl  0xc(%ebp)
  800abd:	01 d8                	add    %ebx,%eax
  800abf:	50                   	push   %eax
  800ac0:	e8 b8 ff ff ff       	call   800a7d <strcpy>
	return dst;
}
  800ac5:	89 d8                	mov    %ebx,%eax
  800ac7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aca:	c9                   	leave  
  800acb:	c3                   	ret    

00800acc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800acc:	f3 0f 1e fb          	endbr32 
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
  800ad5:	8b 75 08             	mov    0x8(%ebp),%esi
  800ad8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800adb:	89 f3                	mov    %esi,%ebx
  800add:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae0:	89 f0                	mov    %esi,%eax
  800ae2:	39 d8                	cmp    %ebx,%eax
  800ae4:	74 11                	je     800af7 <strncpy+0x2b>
		*dst++ = *src;
  800ae6:	83 c0 01             	add    $0x1,%eax
  800ae9:	0f b6 0a             	movzbl (%edx),%ecx
  800aec:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aef:	80 f9 01             	cmp    $0x1,%cl
  800af2:	83 da ff             	sbb    $0xffffffff,%edx
  800af5:	eb eb                	jmp    800ae2 <strncpy+0x16>
	}
	return ret;
}
  800af7:	89 f0                	mov    %esi,%eax
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800afd:	f3 0f 1e fb          	endbr32 
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
  800b06:	8b 75 08             	mov    0x8(%ebp),%esi
  800b09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0c:	8b 55 10             	mov    0x10(%ebp),%edx
  800b0f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b11:	85 d2                	test   %edx,%edx
  800b13:	74 21                	je     800b36 <strlcpy+0x39>
  800b15:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b19:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b1b:	39 c2                	cmp    %eax,%edx
  800b1d:	74 14                	je     800b33 <strlcpy+0x36>
  800b1f:	0f b6 19             	movzbl (%ecx),%ebx
  800b22:	84 db                	test   %bl,%bl
  800b24:	74 0b                	je     800b31 <strlcpy+0x34>
			*dst++ = *src++;
  800b26:	83 c1 01             	add    $0x1,%ecx
  800b29:	83 c2 01             	add    $0x1,%edx
  800b2c:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b2f:	eb ea                	jmp    800b1b <strlcpy+0x1e>
  800b31:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b33:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b36:	29 f0                	sub    %esi,%eax
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b3c:	f3 0f 1e fb          	endbr32 
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b46:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b49:	0f b6 01             	movzbl (%ecx),%eax
  800b4c:	84 c0                	test   %al,%al
  800b4e:	74 0c                	je     800b5c <strcmp+0x20>
  800b50:	3a 02                	cmp    (%edx),%al
  800b52:	75 08                	jne    800b5c <strcmp+0x20>
		p++, q++;
  800b54:	83 c1 01             	add    $0x1,%ecx
  800b57:	83 c2 01             	add    $0x1,%edx
  800b5a:	eb ed                	jmp    800b49 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b5c:	0f b6 c0             	movzbl %al,%eax
  800b5f:	0f b6 12             	movzbl (%edx),%edx
  800b62:	29 d0                	sub    %edx,%eax
}
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b66:	f3 0f 1e fb          	endbr32 
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	53                   	push   %ebx
  800b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b71:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b74:	89 c3                	mov    %eax,%ebx
  800b76:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b79:	eb 06                	jmp    800b81 <strncmp+0x1b>
		n--, p++, q++;
  800b7b:	83 c0 01             	add    $0x1,%eax
  800b7e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b81:	39 d8                	cmp    %ebx,%eax
  800b83:	74 16                	je     800b9b <strncmp+0x35>
  800b85:	0f b6 08             	movzbl (%eax),%ecx
  800b88:	84 c9                	test   %cl,%cl
  800b8a:	74 04                	je     800b90 <strncmp+0x2a>
  800b8c:	3a 0a                	cmp    (%edx),%cl
  800b8e:	74 eb                	je     800b7b <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b90:	0f b6 00             	movzbl (%eax),%eax
  800b93:	0f b6 12             	movzbl (%edx),%edx
  800b96:	29 d0                	sub    %edx,%eax
}
  800b98:	5b                   	pop    %ebx
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    
		return 0;
  800b9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba0:	eb f6                	jmp    800b98 <strncmp+0x32>

00800ba2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ba2:	f3 0f 1e fb          	endbr32 
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bb0:	0f b6 10             	movzbl (%eax),%edx
  800bb3:	84 d2                	test   %dl,%dl
  800bb5:	74 09                	je     800bc0 <strchr+0x1e>
		if (*s == c)
  800bb7:	38 ca                	cmp    %cl,%dl
  800bb9:	74 0a                	je     800bc5 <strchr+0x23>
	for (; *s; s++)
  800bbb:	83 c0 01             	add    $0x1,%eax
  800bbe:	eb f0                	jmp    800bb0 <strchr+0xe>
			return (char *) s;
	return 0;
  800bc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    

00800bc7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bc7:	f3 0f 1e fb          	endbr32 
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bd5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bd8:	38 ca                	cmp    %cl,%dl
  800bda:	74 09                	je     800be5 <strfind+0x1e>
  800bdc:	84 d2                	test   %dl,%dl
  800bde:	74 05                	je     800be5 <strfind+0x1e>
	for (; *s; s++)
  800be0:	83 c0 01             	add    $0x1,%eax
  800be3:	eb f0                	jmp    800bd5 <strfind+0xe>
			break;
	return (char *) s;
}
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800be7:	f3 0f 1e fb          	endbr32 
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bf4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bf7:	85 c9                	test   %ecx,%ecx
  800bf9:	74 31                	je     800c2c <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bfb:	89 f8                	mov    %edi,%eax
  800bfd:	09 c8                	or     %ecx,%eax
  800bff:	a8 03                	test   $0x3,%al
  800c01:	75 23                	jne    800c26 <memset+0x3f>
		c &= 0xFF;
  800c03:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c07:	89 d3                	mov    %edx,%ebx
  800c09:	c1 e3 08             	shl    $0x8,%ebx
  800c0c:	89 d0                	mov    %edx,%eax
  800c0e:	c1 e0 18             	shl    $0x18,%eax
  800c11:	89 d6                	mov    %edx,%esi
  800c13:	c1 e6 10             	shl    $0x10,%esi
  800c16:	09 f0                	or     %esi,%eax
  800c18:	09 c2                	or     %eax,%edx
  800c1a:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c1c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c1f:	89 d0                	mov    %edx,%eax
  800c21:	fc                   	cld    
  800c22:	f3 ab                	rep stos %eax,%es:(%edi)
  800c24:	eb 06                	jmp    800c2c <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c29:	fc                   	cld    
  800c2a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c2c:	89 f8                	mov    %edi,%eax
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c33:	f3 0f 1e fb          	endbr32 
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c42:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c45:	39 c6                	cmp    %eax,%esi
  800c47:	73 32                	jae    800c7b <memmove+0x48>
  800c49:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c4c:	39 c2                	cmp    %eax,%edx
  800c4e:	76 2b                	jbe    800c7b <memmove+0x48>
		s += n;
		d += n;
  800c50:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c53:	89 fe                	mov    %edi,%esi
  800c55:	09 ce                	or     %ecx,%esi
  800c57:	09 d6                	or     %edx,%esi
  800c59:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c5f:	75 0e                	jne    800c6f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c61:	83 ef 04             	sub    $0x4,%edi
  800c64:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c67:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c6a:	fd                   	std    
  800c6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c6d:	eb 09                	jmp    800c78 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c6f:	83 ef 01             	sub    $0x1,%edi
  800c72:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c75:	fd                   	std    
  800c76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c78:	fc                   	cld    
  800c79:	eb 1a                	jmp    800c95 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c7b:	89 c2                	mov    %eax,%edx
  800c7d:	09 ca                	or     %ecx,%edx
  800c7f:	09 f2                	or     %esi,%edx
  800c81:	f6 c2 03             	test   $0x3,%dl
  800c84:	75 0a                	jne    800c90 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c86:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c89:	89 c7                	mov    %eax,%edi
  800c8b:	fc                   	cld    
  800c8c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c8e:	eb 05                	jmp    800c95 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c90:	89 c7                	mov    %eax,%edi
  800c92:	fc                   	cld    
  800c93:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c99:	f3 0f 1e fb          	endbr32 
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ca3:	ff 75 10             	pushl  0x10(%ebp)
  800ca6:	ff 75 0c             	pushl  0xc(%ebp)
  800ca9:	ff 75 08             	pushl  0x8(%ebp)
  800cac:	e8 82 ff ff ff       	call   800c33 <memmove>
}
  800cb1:	c9                   	leave  
  800cb2:	c3                   	ret    

00800cb3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cb3:	f3 0f 1e fb          	endbr32 
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cc2:	89 c6                	mov    %eax,%esi
  800cc4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc7:	39 f0                	cmp    %esi,%eax
  800cc9:	74 1c                	je     800ce7 <memcmp+0x34>
		if (*s1 != *s2)
  800ccb:	0f b6 08             	movzbl (%eax),%ecx
  800cce:	0f b6 1a             	movzbl (%edx),%ebx
  800cd1:	38 d9                	cmp    %bl,%cl
  800cd3:	75 08                	jne    800cdd <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cd5:	83 c0 01             	add    $0x1,%eax
  800cd8:	83 c2 01             	add    $0x1,%edx
  800cdb:	eb ea                	jmp    800cc7 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800cdd:	0f b6 c1             	movzbl %cl,%eax
  800ce0:	0f b6 db             	movzbl %bl,%ebx
  800ce3:	29 d8                	sub    %ebx,%eax
  800ce5:	eb 05                	jmp    800cec <memcmp+0x39>
	}

	return 0;
  800ce7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cf0:	f3 0f 1e fb          	endbr32 
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cfd:	89 c2                	mov    %eax,%edx
  800cff:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d02:	39 d0                	cmp    %edx,%eax
  800d04:	73 09                	jae    800d0f <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d06:	38 08                	cmp    %cl,(%eax)
  800d08:	74 05                	je     800d0f <memfind+0x1f>
	for (; s < ends; s++)
  800d0a:	83 c0 01             	add    $0x1,%eax
  800d0d:	eb f3                	jmp    800d02 <memfind+0x12>
			break;
	return (void *) s;
}
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d11:	f3 0f 1e fb          	endbr32 
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	57                   	push   %edi
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
  800d1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d21:	eb 03                	jmp    800d26 <strtol+0x15>
		s++;
  800d23:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d26:	0f b6 01             	movzbl (%ecx),%eax
  800d29:	3c 20                	cmp    $0x20,%al
  800d2b:	74 f6                	je     800d23 <strtol+0x12>
  800d2d:	3c 09                	cmp    $0x9,%al
  800d2f:	74 f2                	je     800d23 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d31:	3c 2b                	cmp    $0x2b,%al
  800d33:	74 2a                	je     800d5f <strtol+0x4e>
	int neg = 0;
  800d35:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d3a:	3c 2d                	cmp    $0x2d,%al
  800d3c:	74 2b                	je     800d69 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d3e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d44:	75 0f                	jne    800d55 <strtol+0x44>
  800d46:	80 39 30             	cmpb   $0x30,(%ecx)
  800d49:	74 28                	je     800d73 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d4b:	85 db                	test   %ebx,%ebx
  800d4d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d52:	0f 44 d8             	cmove  %eax,%ebx
  800d55:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d5d:	eb 46                	jmp    800da5 <strtol+0x94>
		s++;
  800d5f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d62:	bf 00 00 00 00       	mov    $0x0,%edi
  800d67:	eb d5                	jmp    800d3e <strtol+0x2d>
		s++, neg = 1;
  800d69:	83 c1 01             	add    $0x1,%ecx
  800d6c:	bf 01 00 00 00       	mov    $0x1,%edi
  800d71:	eb cb                	jmp    800d3e <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d73:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d77:	74 0e                	je     800d87 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d79:	85 db                	test   %ebx,%ebx
  800d7b:	75 d8                	jne    800d55 <strtol+0x44>
		s++, base = 8;
  800d7d:	83 c1 01             	add    $0x1,%ecx
  800d80:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d85:	eb ce                	jmp    800d55 <strtol+0x44>
		s += 2, base = 16;
  800d87:	83 c1 02             	add    $0x2,%ecx
  800d8a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d8f:	eb c4                	jmp    800d55 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d91:	0f be d2             	movsbl %dl,%edx
  800d94:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d97:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d9a:	7d 3a                	jge    800dd6 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d9c:	83 c1 01             	add    $0x1,%ecx
  800d9f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800da3:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800da5:	0f b6 11             	movzbl (%ecx),%edx
  800da8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800dab:	89 f3                	mov    %esi,%ebx
  800dad:	80 fb 09             	cmp    $0x9,%bl
  800db0:	76 df                	jbe    800d91 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800db2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800db5:	89 f3                	mov    %esi,%ebx
  800db7:	80 fb 19             	cmp    $0x19,%bl
  800dba:	77 08                	ja     800dc4 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800dbc:	0f be d2             	movsbl %dl,%edx
  800dbf:	83 ea 57             	sub    $0x57,%edx
  800dc2:	eb d3                	jmp    800d97 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800dc4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dc7:	89 f3                	mov    %esi,%ebx
  800dc9:	80 fb 19             	cmp    $0x19,%bl
  800dcc:	77 08                	ja     800dd6 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dce:	0f be d2             	movsbl %dl,%edx
  800dd1:	83 ea 37             	sub    $0x37,%edx
  800dd4:	eb c1                	jmp    800d97 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dd6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dda:	74 05                	je     800de1 <strtol+0xd0>
		*endptr = (char *) s;
  800ddc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ddf:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800de1:	89 c2                	mov    %eax,%edx
  800de3:	f7 da                	neg    %edx
  800de5:	85 ff                	test   %edi,%edi
  800de7:	0f 45 c2             	cmovne %edx,%eax
}
  800dea:	5b                   	pop    %ebx
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    
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
