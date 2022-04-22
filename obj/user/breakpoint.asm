
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	asm volatile("int $3");
  800037:	cc                   	int3   
}
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	f3 0f 1e fb          	endbr32 
  80003d:	55                   	push   %ebp
  80003e:	89 e5                	mov    %esp,%ebp
  800040:	56                   	push   %esi
  800041:	53                   	push   %ebx
  800042:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800045:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800048:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  80004f:	00 00 00 
    envid_t envid = sys_getenvid();
  800052:	e8 de 00 00 00       	call   800135 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x3b>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	f3 0f 1e fb          	endbr32 
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800097:	e8 df 04 00 00       	call   80057b <close_all>
	sys_env_destroy(0);
  80009c:	83 ec 0c             	sub    $0xc,%esp
  80009f:	6a 00                	push   $0x0
  8000a1:	e8 4a 00 00 00       	call   8000f0 <sys_env_destroy>
}
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	c9                   	leave  
  8000aa:	c3                   	ret    

008000ab <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ab:	f3 0f 1e fb          	endbr32 
  8000af:	55                   	push   %ebp
  8000b0:	89 e5                	mov    %esp,%ebp
  8000b2:	57                   	push   %edi
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c0:	89 c3                	mov    %eax,%ebx
  8000c2:	89 c7                	mov    %eax,%edi
  8000c4:	89 c6                	mov    %eax,%esi
  8000c6:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5f                   	pop    %edi
  8000cb:	5d                   	pop    %ebp
  8000cc:	c3                   	ret    

008000cd <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cd:	f3 0f 1e fb          	endbr32 
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	57                   	push   %edi
  8000d5:	56                   	push   %esi
  8000d6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e1:	89 d1                	mov    %edx,%ecx
  8000e3:	89 d3                	mov    %edx,%ebx
  8000e5:	89 d7                	mov    %edx,%edi
  8000e7:	89 d6                	mov    %edx,%esi
  8000e9:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000eb:	5b                   	pop    %ebx
  8000ec:	5e                   	pop    %esi
  8000ed:	5f                   	pop    %edi
  8000ee:	5d                   	pop    %ebp
  8000ef:	c3                   	ret    

008000f0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f0:	f3 0f 1e fb          	endbr32 
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	57                   	push   %edi
  8000f8:	56                   	push   %esi
  8000f9:	53                   	push   %ebx
  8000fa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800102:	8b 55 08             	mov    0x8(%ebp),%edx
  800105:	b8 03 00 00 00       	mov    $0x3,%eax
  80010a:	89 cb                	mov    %ecx,%ebx
  80010c:	89 cf                	mov    %ecx,%edi
  80010e:	89 ce                	mov    %ecx,%esi
  800110:	cd 30                	int    $0x30
	if(check && ret > 0)
  800112:	85 c0                	test   %eax,%eax
  800114:	7f 08                	jg     80011e <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800116:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800119:	5b                   	pop    %ebx
  80011a:	5e                   	pop    %esi
  80011b:	5f                   	pop    %edi
  80011c:	5d                   	pop    %ebp
  80011d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	50                   	push   %eax
  800122:	6a 03                	push   $0x3
  800124:	68 ea 1e 80 00       	push   $0x801eea
  800129:	6a 23                	push   $0x23
  80012b:	68 07 1f 80 00       	push   $0x801f07
  800130:	e8 9c 0f 00 00       	call   8010d1 <_panic>

00800135 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800135:	f3 0f 1e fb          	endbr32 
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	57                   	push   %edi
  80013d:	56                   	push   %esi
  80013e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013f:	ba 00 00 00 00       	mov    $0x0,%edx
  800144:	b8 02 00 00 00       	mov    $0x2,%eax
  800149:	89 d1                	mov    %edx,%ecx
  80014b:	89 d3                	mov    %edx,%ebx
  80014d:	89 d7                	mov    %edx,%edi
  80014f:	89 d6                	mov    %edx,%esi
  800151:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800153:	5b                   	pop    %ebx
  800154:	5e                   	pop    %esi
  800155:	5f                   	pop    %edi
  800156:	5d                   	pop    %ebp
  800157:	c3                   	ret    

00800158 <sys_yield>:

void
sys_yield(void)
{
  800158:	f3 0f 1e fb          	endbr32 
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	57                   	push   %edi
  800160:	56                   	push   %esi
  800161:	53                   	push   %ebx
	asm volatile("int %1\n"
  800162:	ba 00 00 00 00       	mov    $0x0,%edx
  800167:	b8 0b 00 00 00       	mov    $0xb,%eax
  80016c:	89 d1                	mov    %edx,%ecx
  80016e:	89 d3                	mov    %edx,%ebx
  800170:	89 d7                	mov    %edx,%edi
  800172:	89 d6                	mov    %edx,%esi
  800174:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5f                   	pop    %edi
  800179:	5d                   	pop    %ebp
  80017a:	c3                   	ret    

0080017b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80017b:	f3 0f 1e fb          	endbr32 
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	57                   	push   %edi
  800183:	56                   	push   %esi
  800184:	53                   	push   %ebx
  800185:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800188:	be 00 00 00 00       	mov    $0x0,%esi
  80018d:	8b 55 08             	mov    0x8(%ebp),%edx
  800190:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800193:	b8 04 00 00 00       	mov    $0x4,%eax
  800198:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019b:	89 f7                	mov    %esi,%edi
  80019d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80019f:	85 c0                	test   %eax,%eax
  8001a1:	7f 08                	jg     8001ab <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a6:	5b                   	pop    %ebx
  8001a7:	5e                   	pop    %esi
  8001a8:	5f                   	pop    %edi
  8001a9:	5d                   	pop    %ebp
  8001aa:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ab:	83 ec 0c             	sub    $0xc,%esp
  8001ae:	50                   	push   %eax
  8001af:	6a 04                	push   $0x4
  8001b1:	68 ea 1e 80 00       	push   $0x801eea
  8001b6:	6a 23                	push   $0x23
  8001b8:	68 07 1f 80 00       	push   $0x801f07
  8001bd:	e8 0f 0f 00 00       	call   8010d1 <_panic>

008001c2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c2:	f3 0f 1e fb          	endbr32 
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	57                   	push   %edi
  8001ca:	56                   	push   %esi
  8001cb:	53                   	push   %ebx
  8001cc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001dd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001e5:	85 c0                	test   %eax,%eax
  8001e7:	7f 08                	jg     8001f1 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ec:	5b                   	pop    %ebx
  8001ed:	5e                   	pop    %esi
  8001ee:	5f                   	pop    %edi
  8001ef:	5d                   	pop    %ebp
  8001f0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f1:	83 ec 0c             	sub    $0xc,%esp
  8001f4:	50                   	push   %eax
  8001f5:	6a 05                	push   $0x5
  8001f7:	68 ea 1e 80 00       	push   $0x801eea
  8001fc:	6a 23                	push   $0x23
  8001fe:	68 07 1f 80 00       	push   $0x801f07
  800203:	e8 c9 0e 00 00       	call   8010d1 <_panic>

00800208 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800208:	f3 0f 1e fb          	endbr32 
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800215:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021a:	8b 55 08             	mov    0x8(%ebp),%edx
  80021d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800220:	b8 06 00 00 00       	mov    $0x6,%eax
  800225:	89 df                	mov    %ebx,%edi
  800227:	89 de                	mov    %ebx,%esi
  800229:	cd 30                	int    $0x30
	if(check && ret > 0)
  80022b:	85 c0                	test   %eax,%eax
  80022d:	7f 08                	jg     800237 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5f                   	pop    %edi
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800237:	83 ec 0c             	sub    $0xc,%esp
  80023a:	50                   	push   %eax
  80023b:	6a 06                	push   $0x6
  80023d:	68 ea 1e 80 00       	push   $0x801eea
  800242:	6a 23                	push   $0x23
  800244:	68 07 1f 80 00       	push   $0x801f07
  800249:	e8 83 0e 00 00       	call   8010d1 <_panic>

0080024e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80024e:	f3 0f 1e fb          	endbr32 
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	57                   	push   %edi
  800256:	56                   	push   %esi
  800257:	53                   	push   %ebx
  800258:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80025b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800260:	8b 55 08             	mov    0x8(%ebp),%edx
  800263:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800266:	b8 08 00 00 00       	mov    $0x8,%eax
  80026b:	89 df                	mov    %ebx,%edi
  80026d:	89 de                	mov    %ebx,%esi
  80026f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800271:	85 c0                	test   %eax,%eax
  800273:	7f 08                	jg     80027d <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800275:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800278:	5b                   	pop    %ebx
  800279:	5e                   	pop    %esi
  80027a:	5f                   	pop    %edi
  80027b:	5d                   	pop    %ebp
  80027c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80027d:	83 ec 0c             	sub    $0xc,%esp
  800280:	50                   	push   %eax
  800281:	6a 08                	push   $0x8
  800283:	68 ea 1e 80 00       	push   $0x801eea
  800288:	6a 23                	push   $0x23
  80028a:	68 07 1f 80 00       	push   $0x801f07
  80028f:	e8 3d 0e 00 00       	call   8010d1 <_panic>

00800294 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800294:	f3 0f 1e fb          	endbr32 
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ac:	b8 09 00 00 00       	mov    $0x9,%eax
  8002b1:	89 df                	mov    %ebx,%edi
  8002b3:	89 de                	mov    %ebx,%esi
  8002b5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002b7:	85 c0                	test   %eax,%eax
  8002b9:	7f 08                	jg     8002c3 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002be:	5b                   	pop    %ebx
  8002bf:	5e                   	pop    %esi
  8002c0:	5f                   	pop    %edi
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c3:	83 ec 0c             	sub    $0xc,%esp
  8002c6:	50                   	push   %eax
  8002c7:	6a 09                	push   $0x9
  8002c9:	68 ea 1e 80 00       	push   $0x801eea
  8002ce:	6a 23                	push   $0x23
  8002d0:	68 07 1f 80 00       	push   $0x801f07
  8002d5:	e8 f7 0d 00 00       	call   8010d1 <_panic>

008002da <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002da:	f3 0f 1e fb          	endbr32 
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	57                   	push   %edi
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002f7:	89 df                	mov    %ebx,%edi
  8002f9:	89 de                	mov    %ebx,%esi
  8002fb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002fd:	85 c0                	test   %eax,%eax
  8002ff:	7f 08                	jg     800309 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800301:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800304:	5b                   	pop    %ebx
  800305:	5e                   	pop    %esi
  800306:	5f                   	pop    %edi
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800309:	83 ec 0c             	sub    $0xc,%esp
  80030c:	50                   	push   %eax
  80030d:	6a 0a                	push   $0xa
  80030f:	68 ea 1e 80 00       	push   $0x801eea
  800314:	6a 23                	push   $0x23
  800316:	68 07 1f 80 00       	push   $0x801f07
  80031b:	e8 b1 0d 00 00       	call   8010d1 <_panic>

00800320 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800320:	f3 0f 1e fb          	endbr32 
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	57                   	push   %edi
  800328:	56                   	push   %esi
  800329:	53                   	push   %ebx
	asm volatile("int %1\n"
  80032a:	8b 55 08             	mov    0x8(%ebp),%edx
  80032d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800330:	b8 0c 00 00 00       	mov    $0xc,%eax
  800335:	be 00 00 00 00       	mov    $0x0,%esi
  80033a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80033d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800340:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800342:	5b                   	pop    %ebx
  800343:	5e                   	pop    %esi
  800344:	5f                   	pop    %edi
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800347:	f3 0f 1e fb          	endbr32 
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	57                   	push   %edi
  80034f:	56                   	push   %esi
  800350:	53                   	push   %ebx
  800351:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800354:	b9 00 00 00 00       	mov    $0x0,%ecx
  800359:	8b 55 08             	mov    0x8(%ebp),%edx
  80035c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800361:	89 cb                	mov    %ecx,%ebx
  800363:	89 cf                	mov    %ecx,%edi
  800365:	89 ce                	mov    %ecx,%esi
  800367:	cd 30                	int    $0x30
	if(check && ret > 0)
  800369:	85 c0                	test   %eax,%eax
  80036b:	7f 08                	jg     800375 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800370:	5b                   	pop    %ebx
  800371:	5e                   	pop    %esi
  800372:	5f                   	pop    %edi
  800373:	5d                   	pop    %ebp
  800374:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800375:	83 ec 0c             	sub    $0xc,%esp
  800378:	50                   	push   %eax
  800379:	6a 0d                	push   $0xd
  80037b:	68 ea 1e 80 00       	push   $0x801eea
  800380:	6a 23                	push   $0x23
  800382:	68 07 1f 80 00       	push   $0x801f07
  800387:	e8 45 0d 00 00       	call   8010d1 <_panic>

0080038c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80038c:	f3 0f 1e fb          	endbr32 
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800393:	8b 45 08             	mov    0x8(%ebp),%eax
  800396:	05 00 00 00 30       	add    $0x30000000,%eax
  80039b:	c1 e8 0c             	shr    $0xc,%eax
}
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003a0:	f3 0f 1e fb          	endbr32 
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003aa:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003af:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003b4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003b9:	5d                   	pop    %ebp
  8003ba:	c3                   	ret    

008003bb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003bb:	f3 0f 1e fb          	endbr32 
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003c7:	89 c2                	mov    %eax,%edx
  8003c9:	c1 ea 16             	shr    $0x16,%edx
  8003cc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003d3:	f6 c2 01             	test   $0x1,%dl
  8003d6:	74 2d                	je     800405 <fd_alloc+0x4a>
  8003d8:	89 c2                	mov    %eax,%edx
  8003da:	c1 ea 0c             	shr    $0xc,%edx
  8003dd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003e4:	f6 c2 01             	test   $0x1,%dl
  8003e7:	74 1c                	je     800405 <fd_alloc+0x4a>
  8003e9:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003ee:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003f3:	75 d2                	jne    8003c7 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8003fe:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800403:	eb 0a                	jmp    80040f <fd_alloc+0x54>
			*fd_store = fd;
  800405:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800408:	89 01                	mov    %eax,(%ecx)
			return 0;
  80040a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80040f:	5d                   	pop    %ebp
  800410:	c3                   	ret    

00800411 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800411:	f3 0f 1e fb          	endbr32 
  800415:	55                   	push   %ebp
  800416:	89 e5                	mov    %esp,%ebp
  800418:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80041b:	83 f8 1f             	cmp    $0x1f,%eax
  80041e:	77 30                	ja     800450 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800420:	c1 e0 0c             	shl    $0xc,%eax
  800423:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800428:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80042e:	f6 c2 01             	test   $0x1,%dl
  800431:	74 24                	je     800457 <fd_lookup+0x46>
  800433:	89 c2                	mov    %eax,%edx
  800435:	c1 ea 0c             	shr    $0xc,%edx
  800438:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80043f:	f6 c2 01             	test   $0x1,%dl
  800442:	74 1a                	je     80045e <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800444:	8b 55 0c             	mov    0xc(%ebp),%edx
  800447:	89 02                	mov    %eax,(%edx)
	return 0;
  800449:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80044e:	5d                   	pop    %ebp
  80044f:	c3                   	ret    
		return -E_INVAL;
  800450:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800455:	eb f7                	jmp    80044e <fd_lookup+0x3d>
		return -E_INVAL;
  800457:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80045c:	eb f0                	jmp    80044e <fd_lookup+0x3d>
  80045e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800463:	eb e9                	jmp    80044e <fd_lookup+0x3d>

00800465 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800465:	f3 0f 1e fb          	endbr32 
  800469:	55                   	push   %ebp
  80046a:	89 e5                	mov    %esp,%ebp
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800472:	ba 94 1f 80 00       	mov    $0x801f94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800477:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80047c:	39 08                	cmp    %ecx,(%eax)
  80047e:	74 33                	je     8004b3 <dev_lookup+0x4e>
  800480:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800483:	8b 02                	mov    (%edx),%eax
  800485:	85 c0                	test   %eax,%eax
  800487:	75 f3                	jne    80047c <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800489:	a1 04 40 80 00       	mov    0x804004,%eax
  80048e:	8b 40 48             	mov    0x48(%eax),%eax
  800491:	83 ec 04             	sub    $0x4,%esp
  800494:	51                   	push   %ecx
  800495:	50                   	push   %eax
  800496:	68 18 1f 80 00       	push   $0x801f18
  80049b:	e8 18 0d 00 00       	call   8011b8 <cprintf>
	*dev = 0;
  8004a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004a9:	83 c4 10             	add    $0x10,%esp
  8004ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004b1:	c9                   	leave  
  8004b2:	c3                   	ret    
			*dev = devtab[i];
  8004b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004b6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bd:	eb f2                	jmp    8004b1 <dev_lookup+0x4c>

008004bf <fd_close>:
{
  8004bf:	f3 0f 1e fb          	endbr32 
  8004c3:	55                   	push   %ebp
  8004c4:	89 e5                	mov    %esp,%ebp
  8004c6:	57                   	push   %edi
  8004c7:	56                   	push   %esi
  8004c8:	53                   	push   %ebx
  8004c9:	83 ec 24             	sub    $0x24,%esp
  8004cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cf:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004d2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004d5:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004d6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004dc:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004df:	50                   	push   %eax
  8004e0:	e8 2c ff ff ff       	call   800411 <fd_lookup>
  8004e5:	89 c3                	mov    %eax,%ebx
  8004e7:	83 c4 10             	add    $0x10,%esp
  8004ea:	85 c0                	test   %eax,%eax
  8004ec:	78 05                	js     8004f3 <fd_close+0x34>
	    || fd != fd2)
  8004ee:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004f1:	74 16                	je     800509 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8004f3:	89 f8                	mov    %edi,%eax
  8004f5:	84 c0                	test   %al,%al
  8004f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fc:	0f 44 d8             	cmove  %eax,%ebx
}
  8004ff:	89 d8                	mov    %ebx,%eax
  800501:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800504:	5b                   	pop    %ebx
  800505:	5e                   	pop    %esi
  800506:	5f                   	pop    %edi
  800507:	5d                   	pop    %ebp
  800508:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800509:	83 ec 08             	sub    $0x8,%esp
  80050c:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80050f:	50                   	push   %eax
  800510:	ff 36                	pushl  (%esi)
  800512:	e8 4e ff ff ff       	call   800465 <dev_lookup>
  800517:	89 c3                	mov    %eax,%ebx
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	85 c0                	test   %eax,%eax
  80051e:	78 1a                	js     80053a <fd_close+0x7b>
		if (dev->dev_close)
  800520:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800523:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800526:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80052b:	85 c0                	test   %eax,%eax
  80052d:	74 0b                	je     80053a <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80052f:	83 ec 0c             	sub    $0xc,%esp
  800532:	56                   	push   %esi
  800533:	ff d0                	call   *%eax
  800535:	89 c3                	mov    %eax,%ebx
  800537:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	56                   	push   %esi
  80053e:	6a 00                	push   $0x0
  800540:	e8 c3 fc ff ff       	call   800208 <sys_page_unmap>
	return r;
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	eb b5                	jmp    8004ff <fd_close+0x40>

0080054a <close>:

int
close(int fdnum)
{
  80054a:	f3 0f 1e fb          	endbr32 
  80054e:	55                   	push   %ebp
  80054f:	89 e5                	mov    %esp,%ebp
  800551:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800554:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800557:	50                   	push   %eax
  800558:	ff 75 08             	pushl  0x8(%ebp)
  80055b:	e8 b1 fe ff ff       	call   800411 <fd_lookup>
  800560:	83 c4 10             	add    $0x10,%esp
  800563:	85 c0                	test   %eax,%eax
  800565:	79 02                	jns    800569 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800567:	c9                   	leave  
  800568:	c3                   	ret    
		return fd_close(fd, 1);
  800569:	83 ec 08             	sub    $0x8,%esp
  80056c:	6a 01                	push   $0x1
  80056e:	ff 75 f4             	pushl  -0xc(%ebp)
  800571:	e8 49 ff ff ff       	call   8004bf <fd_close>
  800576:	83 c4 10             	add    $0x10,%esp
  800579:	eb ec                	jmp    800567 <close+0x1d>

0080057b <close_all>:

void
close_all(void)
{
  80057b:	f3 0f 1e fb          	endbr32 
  80057f:	55                   	push   %ebp
  800580:	89 e5                	mov    %esp,%ebp
  800582:	53                   	push   %ebx
  800583:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800586:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80058b:	83 ec 0c             	sub    $0xc,%esp
  80058e:	53                   	push   %ebx
  80058f:	e8 b6 ff ff ff       	call   80054a <close>
	for (i = 0; i < MAXFD; i++)
  800594:	83 c3 01             	add    $0x1,%ebx
  800597:	83 c4 10             	add    $0x10,%esp
  80059a:	83 fb 20             	cmp    $0x20,%ebx
  80059d:	75 ec                	jne    80058b <close_all+0x10>
}
  80059f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005a2:	c9                   	leave  
  8005a3:	c3                   	ret    

008005a4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005a4:	f3 0f 1e fb          	endbr32 
  8005a8:	55                   	push   %ebp
  8005a9:	89 e5                	mov    %esp,%ebp
  8005ab:	57                   	push   %edi
  8005ac:	56                   	push   %esi
  8005ad:	53                   	push   %ebx
  8005ae:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005b1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005b4:	50                   	push   %eax
  8005b5:	ff 75 08             	pushl  0x8(%ebp)
  8005b8:	e8 54 fe ff ff       	call   800411 <fd_lookup>
  8005bd:	89 c3                	mov    %eax,%ebx
  8005bf:	83 c4 10             	add    $0x10,%esp
  8005c2:	85 c0                	test   %eax,%eax
  8005c4:	0f 88 81 00 00 00    	js     80064b <dup+0xa7>
		return r;
	close(newfdnum);
  8005ca:	83 ec 0c             	sub    $0xc,%esp
  8005cd:	ff 75 0c             	pushl  0xc(%ebp)
  8005d0:	e8 75 ff ff ff       	call   80054a <close>

	newfd = INDEX2FD(newfdnum);
  8005d5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005d8:	c1 e6 0c             	shl    $0xc,%esi
  8005db:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005e1:	83 c4 04             	add    $0x4,%esp
  8005e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005e7:	e8 b4 fd ff ff       	call   8003a0 <fd2data>
  8005ec:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005ee:	89 34 24             	mov    %esi,(%esp)
  8005f1:	e8 aa fd ff ff       	call   8003a0 <fd2data>
  8005f6:	83 c4 10             	add    $0x10,%esp
  8005f9:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005fb:	89 d8                	mov    %ebx,%eax
  8005fd:	c1 e8 16             	shr    $0x16,%eax
  800600:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800607:	a8 01                	test   $0x1,%al
  800609:	74 11                	je     80061c <dup+0x78>
  80060b:	89 d8                	mov    %ebx,%eax
  80060d:	c1 e8 0c             	shr    $0xc,%eax
  800610:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800617:	f6 c2 01             	test   $0x1,%dl
  80061a:	75 39                	jne    800655 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80061c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061f:	89 d0                	mov    %edx,%eax
  800621:	c1 e8 0c             	shr    $0xc,%eax
  800624:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80062b:	83 ec 0c             	sub    $0xc,%esp
  80062e:	25 07 0e 00 00       	and    $0xe07,%eax
  800633:	50                   	push   %eax
  800634:	56                   	push   %esi
  800635:	6a 00                	push   $0x0
  800637:	52                   	push   %edx
  800638:	6a 00                	push   $0x0
  80063a:	e8 83 fb ff ff       	call   8001c2 <sys_page_map>
  80063f:	89 c3                	mov    %eax,%ebx
  800641:	83 c4 20             	add    $0x20,%esp
  800644:	85 c0                	test   %eax,%eax
  800646:	78 31                	js     800679 <dup+0xd5>
		goto err;

	return newfdnum;
  800648:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80064b:	89 d8                	mov    %ebx,%eax
  80064d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800650:	5b                   	pop    %ebx
  800651:	5e                   	pop    %esi
  800652:	5f                   	pop    %edi
  800653:	5d                   	pop    %ebp
  800654:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800655:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80065c:	83 ec 0c             	sub    $0xc,%esp
  80065f:	25 07 0e 00 00       	and    $0xe07,%eax
  800664:	50                   	push   %eax
  800665:	57                   	push   %edi
  800666:	6a 00                	push   $0x0
  800668:	53                   	push   %ebx
  800669:	6a 00                	push   $0x0
  80066b:	e8 52 fb ff ff       	call   8001c2 <sys_page_map>
  800670:	89 c3                	mov    %eax,%ebx
  800672:	83 c4 20             	add    $0x20,%esp
  800675:	85 c0                	test   %eax,%eax
  800677:	79 a3                	jns    80061c <dup+0x78>
	sys_page_unmap(0, newfd);
  800679:	83 ec 08             	sub    $0x8,%esp
  80067c:	56                   	push   %esi
  80067d:	6a 00                	push   $0x0
  80067f:	e8 84 fb ff ff       	call   800208 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800684:	83 c4 08             	add    $0x8,%esp
  800687:	57                   	push   %edi
  800688:	6a 00                	push   $0x0
  80068a:	e8 79 fb ff ff       	call   800208 <sys_page_unmap>
	return r;
  80068f:	83 c4 10             	add    $0x10,%esp
  800692:	eb b7                	jmp    80064b <dup+0xa7>

00800694 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800694:	f3 0f 1e fb          	endbr32 
  800698:	55                   	push   %ebp
  800699:	89 e5                	mov    %esp,%ebp
  80069b:	53                   	push   %ebx
  80069c:	83 ec 1c             	sub    $0x1c,%esp
  80069f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006a5:	50                   	push   %eax
  8006a6:	53                   	push   %ebx
  8006a7:	e8 65 fd ff ff       	call   800411 <fd_lookup>
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	85 c0                	test   %eax,%eax
  8006b1:	78 3f                	js     8006f2 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006b9:	50                   	push   %eax
  8006ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006bd:	ff 30                	pushl  (%eax)
  8006bf:	e8 a1 fd ff ff       	call   800465 <dev_lookup>
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	85 c0                	test   %eax,%eax
  8006c9:	78 27                	js     8006f2 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006ce:	8b 42 08             	mov    0x8(%edx),%eax
  8006d1:	83 e0 03             	and    $0x3,%eax
  8006d4:	83 f8 01             	cmp    $0x1,%eax
  8006d7:	74 1e                	je     8006f7 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006dc:	8b 40 08             	mov    0x8(%eax),%eax
  8006df:	85 c0                	test   %eax,%eax
  8006e1:	74 35                	je     800718 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006e3:	83 ec 04             	sub    $0x4,%esp
  8006e6:	ff 75 10             	pushl  0x10(%ebp)
  8006e9:	ff 75 0c             	pushl  0xc(%ebp)
  8006ec:	52                   	push   %edx
  8006ed:	ff d0                	call   *%eax
  8006ef:	83 c4 10             	add    $0x10,%esp
}
  8006f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f5:	c9                   	leave  
  8006f6:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006f7:	a1 04 40 80 00       	mov    0x804004,%eax
  8006fc:	8b 40 48             	mov    0x48(%eax),%eax
  8006ff:	83 ec 04             	sub    $0x4,%esp
  800702:	53                   	push   %ebx
  800703:	50                   	push   %eax
  800704:	68 59 1f 80 00       	push   $0x801f59
  800709:	e8 aa 0a 00 00       	call   8011b8 <cprintf>
		return -E_INVAL;
  80070e:	83 c4 10             	add    $0x10,%esp
  800711:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800716:	eb da                	jmp    8006f2 <read+0x5e>
		return -E_NOT_SUPP;
  800718:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80071d:	eb d3                	jmp    8006f2 <read+0x5e>

0080071f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80071f:	f3 0f 1e fb          	endbr32 
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	57                   	push   %edi
  800727:	56                   	push   %esi
  800728:	53                   	push   %ebx
  800729:	83 ec 0c             	sub    $0xc,%esp
  80072c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80072f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800732:	bb 00 00 00 00       	mov    $0x0,%ebx
  800737:	eb 02                	jmp    80073b <readn+0x1c>
  800739:	01 c3                	add    %eax,%ebx
  80073b:	39 f3                	cmp    %esi,%ebx
  80073d:	73 21                	jae    800760 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80073f:	83 ec 04             	sub    $0x4,%esp
  800742:	89 f0                	mov    %esi,%eax
  800744:	29 d8                	sub    %ebx,%eax
  800746:	50                   	push   %eax
  800747:	89 d8                	mov    %ebx,%eax
  800749:	03 45 0c             	add    0xc(%ebp),%eax
  80074c:	50                   	push   %eax
  80074d:	57                   	push   %edi
  80074e:	e8 41 ff ff ff       	call   800694 <read>
		if (m < 0)
  800753:	83 c4 10             	add    $0x10,%esp
  800756:	85 c0                	test   %eax,%eax
  800758:	78 04                	js     80075e <readn+0x3f>
			return m;
		if (m == 0)
  80075a:	75 dd                	jne    800739 <readn+0x1a>
  80075c:	eb 02                	jmp    800760 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80075e:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800760:	89 d8                	mov    %ebx,%eax
  800762:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800765:	5b                   	pop    %ebx
  800766:	5e                   	pop    %esi
  800767:	5f                   	pop    %edi
  800768:	5d                   	pop    %ebp
  800769:	c3                   	ret    

0080076a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80076a:	f3 0f 1e fb          	endbr32 
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	53                   	push   %ebx
  800772:	83 ec 1c             	sub    $0x1c,%esp
  800775:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800778:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80077b:	50                   	push   %eax
  80077c:	53                   	push   %ebx
  80077d:	e8 8f fc ff ff       	call   800411 <fd_lookup>
  800782:	83 c4 10             	add    $0x10,%esp
  800785:	85 c0                	test   %eax,%eax
  800787:	78 3a                	js     8007c3 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800789:	83 ec 08             	sub    $0x8,%esp
  80078c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80078f:	50                   	push   %eax
  800790:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800793:	ff 30                	pushl  (%eax)
  800795:	e8 cb fc ff ff       	call   800465 <dev_lookup>
  80079a:	83 c4 10             	add    $0x10,%esp
  80079d:	85 c0                	test   %eax,%eax
  80079f:	78 22                	js     8007c3 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007a4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007a8:	74 1e                	je     8007c8 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007ad:	8b 52 0c             	mov    0xc(%edx),%edx
  8007b0:	85 d2                	test   %edx,%edx
  8007b2:	74 35                	je     8007e9 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007b4:	83 ec 04             	sub    $0x4,%esp
  8007b7:	ff 75 10             	pushl  0x10(%ebp)
  8007ba:	ff 75 0c             	pushl  0xc(%ebp)
  8007bd:	50                   	push   %eax
  8007be:	ff d2                	call   *%edx
  8007c0:	83 c4 10             	add    $0x10,%esp
}
  8007c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c6:	c9                   	leave  
  8007c7:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007c8:	a1 04 40 80 00       	mov    0x804004,%eax
  8007cd:	8b 40 48             	mov    0x48(%eax),%eax
  8007d0:	83 ec 04             	sub    $0x4,%esp
  8007d3:	53                   	push   %ebx
  8007d4:	50                   	push   %eax
  8007d5:	68 75 1f 80 00       	push   $0x801f75
  8007da:	e8 d9 09 00 00       	call   8011b8 <cprintf>
		return -E_INVAL;
  8007df:	83 c4 10             	add    $0x10,%esp
  8007e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e7:	eb da                	jmp    8007c3 <write+0x59>
		return -E_NOT_SUPP;
  8007e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007ee:	eb d3                	jmp    8007c3 <write+0x59>

008007f0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007f0:	f3 0f 1e fb          	endbr32 
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007fd:	50                   	push   %eax
  8007fe:	ff 75 08             	pushl  0x8(%ebp)
  800801:	e8 0b fc ff ff       	call   800411 <fd_lookup>
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	85 c0                	test   %eax,%eax
  80080b:	78 0e                	js     80081b <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80080d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800810:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800813:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800816:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081b:	c9                   	leave  
  80081c:	c3                   	ret    

0080081d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80081d:	f3 0f 1e fb          	endbr32 
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	53                   	push   %ebx
  800825:	83 ec 1c             	sub    $0x1c,%esp
  800828:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80082b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80082e:	50                   	push   %eax
  80082f:	53                   	push   %ebx
  800830:	e8 dc fb ff ff       	call   800411 <fd_lookup>
  800835:	83 c4 10             	add    $0x10,%esp
  800838:	85 c0                	test   %eax,%eax
  80083a:	78 37                	js     800873 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083c:	83 ec 08             	sub    $0x8,%esp
  80083f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800842:	50                   	push   %eax
  800843:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800846:	ff 30                	pushl  (%eax)
  800848:	e8 18 fc ff ff       	call   800465 <dev_lookup>
  80084d:	83 c4 10             	add    $0x10,%esp
  800850:	85 c0                	test   %eax,%eax
  800852:	78 1f                	js     800873 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800854:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800857:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80085b:	74 1b                	je     800878 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80085d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800860:	8b 52 18             	mov    0x18(%edx),%edx
  800863:	85 d2                	test   %edx,%edx
  800865:	74 32                	je     800899 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	ff 75 0c             	pushl  0xc(%ebp)
  80086d:	50                   	push   %eax
  80086e:	ff d2                	call   *%edx
  800870:	83 c4 10             	add    $0x10,%esp
}
  800873:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800876:	c9                   	leave  
  800877:	c3                   	ret    
			thisenv->env_id, fdnum);
  800878:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80087d:	8b 40 48             	mov    0x48(%eax),%eax
  800880:	83 ec 04             	sub    $0x4,%esp
  800883:	53                   	push   %ebx
  800884:	50                   	push   %eax
  800885:	68 38 1f 80 00       	push   $0x801f38
  80088a:	e8 29 09 00 00       	call   8011b8 <cprintf>
		return -E_INVAL;
  80088f:	83 c4 10             	add    $0x10,%esp
  800892:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800897:	eb da                	jmp    800873 <ftruncate+0x56>
		return -E_NOT_SUPP;
  800899:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80089e:	eb d3                	jmp    800873 <ftruncate+0x56>

008008a0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008a0:	f3 0f 1e fb          	endbr32 
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	53                   	push   %ebx
  8008a8:	83 ec 1c             	sub    $0x1c,%esp
  8008ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008b1:	50                   	push   %eax
  8008b2:	ff 75 08             	pushl  0x8(%ebp)
  8008b5:	e8 57 fb ff ff       	call   800411 <fd_lookup>
  8008ba:	83 c4 10             	add    $0x10,%esp
  8008bd:	85 c0                	test   %eax,%eax
  8008bf:	78 4b                	js     80090c <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008c1:	83 ec 08             	sub    $0x8,%esp
  8008c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008c7:	50                   	push   %eax
  8008c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008cb:	ff 30                	pushl  (%eax)
  8008cd:	e8 93 fb ff ff       	call   800465 <dev_lookup>
  8008d2:	83 c4 10             	add    $0x10,%esp
  8008d5:	85 c0                	test   %eax,%eax
  8008d7:	78 33                	js     80090c <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8008d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008dc:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008e0:	74 2f                	je     800911 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008e2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008e5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008ec:	00 00 00 
	stat->st_isdir = 0;
  8008ef:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008f6:	00 00 00 
	stat->st_dev = dev;
  8008f9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	53                   	push   %ebx
  800903:	ff 75 f0             	pushl  -0x10(%ebp)
  800906:	ff 50 14             	call   *0x14(%eax)
  800909:	83 c4 10             	add    $0x10,%esp
}
  80090c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80090f:	c9                   	leave  
  800910:	c3                   	ret    
		return -E_NOT_SUPP;
  800911:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800916:	eb f4                	jmp    80090c <fstat+0x6c>

00800918 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800918:	f3 0f 1e fb          	endbr32 
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	56                   	push   %esi
  800920:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800921:	83 ec 08             	sub    $0x8,%esp
  800924:	6a 00                	push   $0x0
  800926:	ff 75 08             	pushl  0x8(%ebp)
  800929:	e8 fb 01 00 00       	call   800b29 <open>
  80092e:	89 c3                	mov    %eax,%ebx
  800930:	83 c4 10             	add    $0x10,%esp
  800933:	85 c0                	test   %eax,%eax
  800935:	78 1b                	js     800952 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  800937:	83 ec 08             	sub    $0x8,%esp
  80093a:	ff 75 0c             	pushl  0xc(%ebp)
  80093d:	50                   	push   %eax
  80093e:	e8 5d ff ff ff       	call   8008a0 <fstat>
  800943:	89 c6                	mov    %eax,%esi
	close(fd);
  800945:	89 1c 24             	mov    %ebx,(%esp)
  800948:	e8 fd fb ff ff       	call   80054a <close>
	return r;
  80094d:	83 c4 10             	add    $0x10,%esp
  800950:	89 f3                	mov    %esi,%ebx
}
  800952:	89 d8                	mov    %ebx,%eax
  800954:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800957:	5b                   	pop    %ebx
  800958:	5e                   	pop    %esi
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	56                   	push   %esi
  80095f:	53                   	push   %ebx
  800960:	89 c6                	mov    %eax,%esi
  800962:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800964:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80096b:	74 27                	je     800994 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80096d:	6a 07                	push   $0x7
  80096f:	68 00 50 80 00       	push   $0x805000
  800974:	56                   	push   %esi
  800975:	ff 35 00 40 80 00    	pushl  0x804000
  80097b:	e8 0a 12 00 00       	call   801b8a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800980:	83 c4 0c             	add    $0xc,%esp
  800983:	6a 00                	push   $0x0
  800985:	53                   	push   %ebx
  800986:	6a 00                	push   $0x0
  800988:	e8 a6 11 00 00       	call   801b33 <ipc_recv>
}
  80098d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800990:	5b                   	pop    %ebx
  800991:	5e                   	pop    %esi
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800994:	83 ec 0c             	sub    $0xc,%esp
  800997:	6a 01                	push   $0x1
  800999:	e8 52 12 00 00       	call   801bf0 <ipc_find_env>
  80099e:	a3 00 40 80 00       	mov    %eax,0x804000
  8009a3:	83 c4 10             	add    $0x10,%esp
  8009a6:	eb c5                	jmp    80096d <fsipc+0x12>

008009a8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009a8:	f3 0f 1e fb          	endbr32 
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ca:	b8 02 00 00 00       	mov    $0x2,%eax
  8009cf:	e8 87 ff ff ff       	call   80095b <fsipc>
}
  8009d4:	c9                   	leave  
  8009d5:	c3                   	ret    

008009d6 <devfile_flush>:
{
  8009d6:	f3 0f 1e fb          	endbr32 
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f0:	b8 06 00 00 00       	mov    $0x6,%eax
  8009f5:	e8 61 ff ff ff       	call   80095b <fsipc>
}
  8009fa:	c9                   	leave  
  8009fb:	c3                   	ret    

008009fc <devfile_stat>:
{
  8009fc:	f3 0f 1e fb          	endbr32 
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	53                   	push   %ebx
  800a04:	83 ec 04             	sub    $0x4,%esp
  800a07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a10:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a15:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1a:	b8 05 00 00 00       	mov    $0x5,%eax
  800a1f:	e8 37 ff ff ff       	call   80095b <fsipc>
  800a24:	85 c0                	test   %eax,%eax
  800a26:	78 2c                	js     800a54 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a28:	83 ec 08             	sub    $0x8,%esp
  800a2b:	68 00 50 80 00       	push   $0x805000
  800a30:	53                   	push   %ebx
  800a31:	e8 8b 0d 00 00       	call   8017c1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a36:	a1 80 50 80 00       	mov    0x805080,%eax
  800a3b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a41:	a1 84 50 80 00       	mov    0x805084,%eax
  800a46:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a4c:	83 c4 10             	add    $0x10,%esp
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a57:	c9                   	leave  
  800a58:	c3                   	ret    

00800a59 <devfile_write>:
{
  800a59:	f3 0f 1e fb          	endbr32 
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	83 ec 0c             	sub    $0xc,%esp
  800a63:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  800a66:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a6b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a70:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a73:	8b 55 08             	mov    0x8(%ebp),%edx
  800a76:	8b 52 0c             	mov    0xc(%edx),%edx
  800a79:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a7f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a84:	50                   	push   %eax
  800a85:	ff 75 0c             	pushl  0xc(%ebp)
  800a88:	68 08 50 80 00       	push   $0x805008
  800a8d:	e8 e5 0e 00 00       	call   801977 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a92:	ba 00 00 00 00       	mov    $0x0,%edx
  800a97:	b8 04 00 00 00       	mov    $0x4,%eax
  800a9c:	e8 ba fe ff ff       	call   80095b <fsipc>
}
  800aa1:	c9                   	leave  
  800aa2:	c3                   	ret    

00800aa3 <devfile_read>:
{
  800aa3:	f3 0f 1e fb          	endbr32 
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
  800aac:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab2:	8b 40 0c             	mov    0xc(%eax),%eax
  800ab5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800aba:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ac0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac5:	b8 03 00 00 00       	mov    $0x3,%eax
  800aca:	e8 8c fe ff ff       	call   80095b <fsipc>
  800acf:	89 c3                	mov    %eax,%ebx
  800ad1:	85 c0                	test   %eax,%eax
  800ad3:	78 1f                	js     800af4 <devfile_read+0x51>
	assert(r <= n);
  800ad5:	39 f0                	cmp    %esi,%eax
  800ad7:	77 24                	ja     800afd <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800ad9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ade:	7f 33                	jg     800b13 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae0:	83 ec 04             	sub    $0x4,%esp
  800ae3:	50                   	push   %eax
  800ae4:	68 00 50 80 00       	push   $0x805000
  800ae9:	ff 75 0c             	pushl  0xc(%ebp)
  800aec:	e8 86 0e 00 00       	call   801977 <memmove>
	return r;
  800af1:	83 c4 10             	add    $0x10,%esp
}
  800af4:	89 d8                	mov    %ebx,%eax
  800af6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    
	assert(r <= n);
  800afd:	68 a4 1f 80 00       	push   $0x801fa4
  800b02:	68 ab 1f 80 00       	push   $0x801fab
  800b07:	6a 7c                	push   $0x7c
  800b09:	68 c0 1f 80 00       	push   $0x801fc0
  800b0e:	e8 be 05 00 00       	call   8010d1 <_panic>
	assert(r <= PGSIZE);
  800b13:	68 cb 1f 80 00       	push   $0x801fcb
  800b18:	68 ab 1f 80 00       	push   $0x801fab
  800b1d:	6a 7d                	push   $0x7d
  800b1f:	68 c0 1f 80 00       	push   $0x801fc0
  800b24:	e8 a8 05 00 00       	call   8010d1 <_panic>

00800b29 <open>:
{
  800b29:	f3 0f 1e fb          	endbr32 
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	83 ec 1c             	sub    $0x1c,%esp
  800b35:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b38:	56                   	push   %esi
  800b39:	e8 40 0c 00 00       	call   80177e <strlen>
  800b3e:	83 c4 10             	add    $0x10,%esp
  800b41:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b46:	7f 6c                	jg     800bb4 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800b48:	83 ec 0c             	sub    $0xc,%esp
  800b4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b4e:	50                   	push   %eax
  800b4f:	e8 67 f8 ff ff       	call   8003bb <fd_alloc>
  800b54:	89 c3                	mov    %eax,%ebx
  800b56:	83 c4 10             	add    $0x10,%esp
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	78 3c                	js     800b99 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b5d:	83 ec 08             	sub    $0x8,%esp
  800b60:	56                   	push   %esi
  800b61:	68 00 50 80 00       	push   $0x805000
  800b66:	e8 56 0c 00 00       	call   8017c1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b73:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b76:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7b:	e8 db fd ff ff       	call   80095b <fsipc>
  800b80:	89 c3                	mov    %eax,%ebx
  800b82:	83 c4 10             	add    $0x10,%esp
  800b85:	85 c0                	test   %eax,%eax
  800b87:	78 19                	js     800ba2 <open+0x79>
	return fd2num(fd);
  800b89:	83 ec 0c             	sub    $0xc,%esp
  800b8c:	ff 75 f4             	pushl  -0xc(%ebp)
  800b8f:	e8 f8 f7 ff ff       	call   80038c <fd2num>
  800b94:	89 c3                	mov    %eax,%ebx
  800b96:	83 c4 10             	add    $0x10,%esp
}
  800b99:	89 d8                	mov    %ebx,%eax
  800b9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    
		fd_close(fd, 0);
  800ba2:	83 ec 08             	sub    $0x8,%esp
  800ba5:	6a 00                	push   $0x0
  800ba7:	ff 75 f4             	pushl  -0xc(%ebp)
  800baa:	e8 10 f9 ff ff       	call   8004bf <fd_close>
		return r;
  800baf:	83 c4 10             	add    $0x10,%esp
  800bb2:	eb e5                	jmp    800b99 <open+0x70>
		return -E_BAD_PATH;
  800bb4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800bb9:	eb de                	jmp    800b99 <open+0x70>

00800bbb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bbb:	f3 0f 1e fb          	endbr32 
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bca:	b8 08 00 00 00       	mov    $0x8,%eax
  800bcf:	e8 87 fd ff ff       	call   80095b <fsipc>
}
  800bd4:	c9                   	leave  
  800bd5:	c3                   	ret    

00800bd6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bd6:	f3 0f 1e fb          	endbr32 
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800be2:	83 ec 0c             	sub    $0xc,%esp
  800be5:	ff 75 08             	pushl  0x8(%ebp)
  800be8:	e8 b3 f7 ff ff       	call   8003a0 <fd2data>
  800bed:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bef:	83 c4 08             	add    $0x8,%esp
  800bf2:	68 d7 1f 80 00       	push   $0x801fd7
  800bf7:	53                   	push   %ebx
  800bf8:	e8 c4 0b 00 00       	call   8017c1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bfd:	8b 46 04             	mov    0x4(%esi),%eax
  800c00:	2b 06                	sub    (%esi),%eax
  800c02:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800c08:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c0f:	00 00 00 
	stat->st_dev = &devpipe;
  800c12:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c19:	30 80 00 
	return 0;
}
  800c1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c21:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    

00800c28 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c28:	f3 0f 1e fb          	endbr32 
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	53                   	push   %ebx
  800c30:	83 ec 0c             	sub    $0xc,%esp
  800c33:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c36:	53                   	push   %ebx
  800c37:	6a 00                	push   $0x0
  800c39:	e8 ca f5 ff ff       	call   800208 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c3e:	89 1c 24             	mov    %ebx,(%esp)
  800c41:	e8 5a f7 ff ff       	call   8003a0 <fd2data>
  800c46:	83 c4 08             	add    $0x8,%esp
  800c49:	50                   	push   %eax
  800c4a:	6a 00                	push   $0x0
  800c4c:	e8 b7 f5 ff ff       	call   800208 <sys_page_unmap>
}
  800c51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c54:	c9                   	leave  
  800c55:	c3                   	ret    

00800c56 <_pipeisclosed>:
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
  800c5c:	83 ec 1c             	sub    $0x1c,%esp
  800c5f:	89 c7                	mov    %eax,%edi
  800c61:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c63:	a1 04 40 80 00       	mov    0x804004,%eax
  800c68:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	57                   	push   %edi
  800c6f:	e8 b9 0f 00 00       	call   801c2d <pageref>
  800c74:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c77:	89 34 24             	mov    %esi,(%esp)
  800c7a:	e8 ae 0f 00 00       	call   801c2d <pageref>
		nn = thisenv->env_runs;
  800c7f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c85:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c88:	83 c4 10             	add    $0x10,%esp
  800c8b:	39 cb                	cmp    %ecx,%ebx
  800c8d:	74 1b                	je     800caa <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c8f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c92:	75 cf                	jne    800c63 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c94:	8b 42 58             	mov    0x58(%edx),%eax
  800c97:	6a 01                	push   $0x1
  800c99:	50                   	push   %eax
  800c9a:	53                   	push   %ebx
  800c9b:	68 de 1f 80 00       	push   $0x801fde
  800ca0:	e8 13 05 00 00       	call   8011b8 <cprintf>
  800ca5:	83 c4 10             	add    $0x10,%esp
  800ca8:	eb b9                	jmp    800c63 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800caa:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800cad:	0f 94 c0             	sete   %al
  800cb0:	0f b6 c0             	movzbl %al,%eax
}
  800cb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <devpipe_write>:
{
  800cbb:	f3 0f 1e fb          	endbr32 
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	57                   	push   %edi
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
  800cc5:	83 ec 28             	sub    $0x28,%esp
  800cc8:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800ccb:	56                   	push   %esi
  800ccc:	e8 cf f6 ff ff       	call   8003a0 <fd2data>
  800cd1:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cd3:	83 c4 10             	add    $0x10,%esp
  800cd6:	bf 00 00 00 00       	mov    $0x0,%edi
  800cdb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cde:	74 4f                	je     800d2f <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800ce0:	8b 43 04             	mov    0x4(%ebx),%eax
  800ce3:	8b 0b                	mov    (%ebx),%ecx
  800ce5:	8d 51 20             	lea    0x20(%ecx),%edx
  800ce8:	39 d0                	cmp    %edx,%eax
  800cea:	72 14                	jb     800d00 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800cec:	89 da                	mov    %ebx,%edx
  800cee:	89 f0                	mov    %esi,%eax
  800cf0:	e8 61 ff ff ff       	call   800c56 <_pipeisclosed>
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	75 3b                	jne    800d34 <devpipe_write+0x79>
			sys_yield();
  800cf9:	e8 5a f4 ff ff       	call   800158 <sys_yield>
  800cfe:	eb e0                	jmp    800ce0 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d03:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d07:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d0a:	89 c2                	mov    %eax,%edx
  800d0c:	c1 fa 1f             	sar    $0x1f,%edx
  800d0f:	89 d1                	mov    %edx,%ecx
  800d11:	c1 e9 1b             	shr    $0x1b,%ecx
  800d14:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800d17:	83 e2 1f             	and    $0x1f,%edx
  800d1a:	29 ca                	sub    %ecx,%edx
  800d1c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800d20:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d24:	83 c0 01             	add    $0x1,%eax
  800d27:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800d2a:	83 c7 01             	add    $0x1,%edi
  800d2d:	eb ac                	jmp    800cdb <devpipe_write+0x20>
	return i;
  800d2f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d32:	eb 05                	jmp    800d39 <devpipe_write+0x7e>
				return 0;
  800d34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <devpipe_read>:
{
  800d41:	f3 0f 1e fb          	endbr32 
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
  800d4b:	83 ec 18             	sub    $0x18,%esp
  800d4e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800d51:	57                   	push   %edi
  800d52:	e8 49 f6 ff ff       	call   8003a0 <fd2data>
  800d57:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d59:	83 c4 10             	add    $0x10,%esp
  800d5c:	be 00 00 00 00       	mov    $0x0,%esi
  800d61:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d64:	75 14                	jne    800d7a <devpipe_read+0x39>
	return i;
  800d66:	8b 45 10             	mov    0x10(%ebp),%eax
  800d69:	eb 02                	jmp    800d6d <devpipe_read+0x2c>
				return i;
  800d6b:	89 f0                	mov    %esi,%eax
}
  800d6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    
			sys_yield();
  800d75:	e8 de f3 ff ff       	call   800158 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d7a:	8b 03                	mov    (%ebx),%eax
  800d7c:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d7f:	75 18                	jne    800d99 <devpipe_read+0x58>
			if (i > 0)
  800d81:	85 f6                	test   %esi,%esi
  800d83:	75 e6                	jne    800d6b <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d85:	89 da                	mov    %ebx,%edx
  800d87:	89 f8                	mov    %edi,%eax
  800d89:	e8 c8 fe ff ff       	call   800c56 <_pipeisclosed>
  800d8e:	85 c0                	test   %eax,%eax
  800d90:	74 e3                	je     800d75 <devpipe_read+0x34>
				return 0;
  800d92:	b8 00 00 00 00       	mov    $0x0,%eax
  800d97:	eb d4                	jmp    800d6d <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d99:	99                   	cltd   
  800d9a:	c1 ea 1b             	shr    $0x1b,%edx
  800d9d:	01 d0                	add    %edx,%eax
  800d9f:	83 e0 1f             	and    $0x1f,%eax
  800da2:	29 d0                	sub    %edx,%eax
  800da4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800da9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dac:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800daf:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800db2:	83 c6 01             	add    $0x1,%esi
  800db5:	eb aa                	jmp    800d61 <devpipe_read+0x20>

00800db7 <pipe>:
{
  800db7:	f3 0f 1e fb          	endbr32 
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
  800dc0:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800dc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dc6:	50                   	push   %eax
  800dc7:	e8 ef f5 ff ff       	call   8003bb <fd_alloc>
  800dcc:	89 c3                	mov    %eax,%ebx
  800dce:	83 c4 10             	add    $0x10,%esp
  800dd1:	85 c0                	test   %eax,%eax
  800dd3:	0f 88 23 01 00 00    	js     800efc <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd9:	83 ec 04             	sub    $0x4,%esp
  800ddc:	68 07 04 00 00       	push   $0x407
  800de1:	ff 75 f4             	pushl  -0xc(%ebp)
  800de4:	6a 00                	push   $0x0
  800de6:	e8 90 f3 ff ff       	call   80017b <sys_page_alloc>
  800deb:	89 c3                	mov    %eax,%ebx
  800ded:	83 c4 10             	add    $0x10,%esp
  800df0:	85 c0                	test   %eax,%eax
  800df2:	0f 88 04 01 00 00    	js     800efc <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800df8:	83 ec 0c             	sub    $0xc,%esp
  800dfb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dfe:	50                   	push   %eax
  800dff:	e8 b7 f5 ff ff       	call   8003bb <fd_alloc>
  800e04:	89 c3                	mov    %eax,%ebx
  800e06:	83 c4 10             	add    $0x10,%esp
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	0f 88 db 00 00 00    	js     800eec <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e11:	83 ec 04             	sub    $0x4,%esp
  800e14:	68 07 04 00 00       	push   $0x407
  800e19:	ff 75 f0             	pushl  -0x10(%ebp)
  800e1c:	6a 00                	push   $0x0
  800e1e:	e8 58 f3 ff ff       	call   80017b <sys_page_alloc>
  800e23:	89 c3                	mov    %eax,%ebx
  800e25:	83 c4 10             	add    $0x10,%esp
  800e28:	85 c0                	test   %eax,%eax
  800e2a:	0f 88 bc 00 00 00    	js     800eec <pipe+0x135>
	va = fd2data(fd0);
  800e30:	83 ec 0c             	sub    $0xc,%esp
  800e33:	ff 75 f4             	pushl  -0xc(%ebp)
  800e36:	e8 65 f5 ff ff       	call   8003a0 <fd2data>
  800e3b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e3d:	83 c4 0c             	add    $0xc,%esp
  800e40:	68 07 04 00 00       	push   $0x407
  800e45:	50                   	push   %eax
  800e46:	6a 00                	push   $0x0
  800e48:	e8 2e f3 ff ff       	call   80017b <sys_page_alloc>
  800e4d:	89 c3                	mov    %eax,%ebx
  800e4f:	83 c4 10             	add    $0x10,%esp
  800e52:	85 c0                	test   %eax,%eax
  800e54:	0f 88 82 00 00 00    	js     800edc <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e5a:	83 ec 0c             	sub    $0xc,%esp
  800e5d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e60:	e8 3b f5 ff ff       	call   8003a0 <fd2data>
  800e65:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e6c:	50                   	push   %eax
  800e6d:	6a 00                	push   $0x0
  800e6f:	56                   	push   %esi
  800e70:	6a 00                	push   $0x0
  800e72:	e8 4b f3 ff ff       	call   8001c2 <sys_page_map>
  800e77:	89 c3                	mov    %eax,%ebx
  800e79:	83 c4 20             	add    $0x20,%esp
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	78 4e                	js     800ece <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e80:	a1 20 30 80 00       	mov    0x803020,%eax
  800e85:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e88:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e8d:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e94:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e97:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e9c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800ea3:	83 ec 0c             	sub    $0xc,%esp
  800ea6:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea9:	e8 de f4 ff ff       	call   80038c <fd2num>
  800eae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800eb3:	83 c4 04             	add    $0x4,%esp
  800eb6:	ff 75 f0             	pushl  -0x10(%ebp)
  800eb9:	e8 ce f4 ff ff       	call   80038c <fd2num>
  800ebe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800ec4:	83 c4 10             	add    $0x10,%esp
  800ec7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ecc:	eb 2e                	jmp    800efc <pipe+0x145>
	sys_page_unmap(0, va);
  800ece:	83 ec 08             	sub    $0x8,%esp
  800ed1:	56                   	push   %esi
  800ed2:	6a 00                	push   $0x0
  800ed4:	e8 2f f3 ff ff       	call   800208 <sys_page_unmap>
  800ed9:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800edc:	83 ec 08             	sub    $0x8,%esp
  800edf:	ff 75 f0             	pushl  -0x10(%ebp)
  800ee2:	6a 00                	push   $0x0
  800ee4:	e8 1f f3 ff ff       	call   800208 <sys_page_unmap>
  800ee9:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800eec:	83 ec 08             	sub    $0x8,%esp
  800eef:	ff 75 f4             	pushl  -0xc(%ebp)
  800ef2:	6a 00                	push   $0x0
  800ef4:	e8 0f f3 ff ff       	call   800208 <sys_page_unmap>
  800ef9:	83 c4 10             	add    $0x10,%esp
}
  800efc:	89 d8                	mov    %ebx,%eax
  800efe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f01:	5b                   	pop    %ebx
  800f02:	5e                   	pop    %esi
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    

00800f05 <pipeisclosed>:
{
  800f05:	f3 0f 1e fb          	endbr32 
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f12:	50                   	push   %eax
  800f13:	ff 75 08             	pushl  0x8(%ebp)
  800f16:	e8 f6 f4 ff ff       	call   800411 <fd_lookup>
  800f1b:	83 c4 10             	add    $0x10,%esp
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	78 18                	js     800f3a <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800f22:	83 ec 0c             	sub    $0xc,%esp
  800f25:	ff 75 f4             	pushl  -0xc(%ebp)
  800f28:	e8 73 f4 ff ff       	call   8003a0 <fd2data>
  800f2d:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f32:	e8 1f fd ff ff       	call   800c56 <_pipeisclosed>
  800f37:	83 c4 10             	add    $0x10,%esp
}
  800f3a:	c9                   	leave  
  800f3b:	c3                   	ret    

00800f3c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f3c:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800f40:	b8 00 00 00 00       	mov    $0x0,%eax
  800f45:	c3                   	ret    

00800f46 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f46:	f3 0f 1e fb          	endbr32 
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f50:	68 f6 1f 80 00       	push   $0x801ff6
  800f55:	ff 75 0c             	pushl  0xc(%ebp)
  800f58:	e8 64 08 00 00       	call   8017c1 <strcpy>
	return 0;
}
  800f5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f62:	c9                   	leave  
  800f63:	c3                   	ret    

00800f64 <devcons_write>:
{
  800f64:	f3 0f 1e fb          	endbr32 
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	57                   	push   %edi
  800f6c:	56                   	push   %esi
  800f6d:	53                   	push   %ebx
  800f6e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f74:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f79:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f7f:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f82:	73 31                	jae    800fb5 <devcons_write+0x51>
		m = n - tot;
  800f84:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f87:	29 f3                	sub    %esi,%ebx
  800f89:	83 fb 7f             	cmp    $0x7f,%ebx
  800f8c:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f91:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f94:	83 ec 04             	sub    $0x4,%esp
  800f97:	53                   	push   %ebx
  800f98:	89 f0                	mov    %esi,%eax
  800f9a:	03 45 0c             	add    0xc(%ebp),%eax
  800f9d:	50                   	push   %eax
  800f9e:	57                   	push   %edi
  800f9f:	e8 d3 09 00 00       	call   801977 <memmove>
		sys_cputs(buf, m);
  800fa4:	83 c4 08             	add    $0x8,%esp
  800fa7:	53                   	push   %ebx
  800fa8:	57                   	push   %edi
  800fa9:	e8 fd f0 ff ff       	call   8000ab <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800fae:	01 de                	add    %ebx,%esi
  800fb0:	83 c4 10             	add    $0x10,%esp
  800fb3:	eb ca                	jmp    800f7f <devcons_write+0x1b>
}
  800fb5:	89 f0                	mov    %esi,%eax
  800fb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fba:	5b                   	pop    %ebx
  800fbb:	5e                   	pop    %esi
  800fbc:	5f                   	pop    %edi
  800fbd:	5d                   	pop    %ebp
  800fbe:	c3                   	ret    

00800fbf <devcons_read>:
{
  800fbf:	f3 0f 1e fb          	endbr32 
  800fc3:	55                   	push   %ebp
  800fc4:	89 e5                	mov    %esp,%ebp
  800fc6:	83 ec 08             	sub    $0x8,%esp
  800fc9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800fce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fd2:	74 21                	je     800ff5 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800fd4:	e8 f4 f0 ff ff       	call   8000cd <sys_cgetc>
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	75 07                	jne    800fe4 <devcons_read+0x25>
		sys_yield();
  800fdd:	e8 76 f1 ff ff       	call   800158 <sys_yield>
  800fe2:	eb f0                	jmp    800fd4 <devcons_read+0x15>
	if (c < 0)
  800fe4:	78 0f                	js     800ff5 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800fe6:	83 f8 04             	cmp    $0x4,%eax
  800fe9:	74 0c                	je     800ff7 <devcons_read+0x38>
	*(char*)vbuf = c;
  800feb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fee:	88 02                	mov    %al,(%edx)
	return 1;
  800ff0:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800ff5:	c9                   	leave  
  800ff6:	c3                   	ret    
		return 0;
  800ff7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffc:	eb f7                	jmp    800ff5 <devcons_read+0x36>

00800ffe <cputchar>:
{
  800ffe:	f3 0f 1e fb          	endbr32 
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801008:	8b 45 08             	mov    0x8(%ebp),%eax
  80100b:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80100e:	6a 01                	push   $0x1
  801010:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801013:	50                   	push   %eax
  801014:	e8 92 f0 ff ff       	call   8000ab <sys_cputs>
}
  801019:	83 c4 10             	add    $0x10,%esp
  80101c:	c9                   	leave  
  80101d:	c3                   	ret    

0080101e <getchar>:
{
  80101e:	f3 0f 1e fb          	endbr32 
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801028:	6a 01                	push   $0x1
  80102a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80102d:	50                   	push   %eax
  80102e:	6a 00                	push   $0x0
  801030:	e8 5f f6 ff ff       	call   800694 <read>
	if (r < 0)
  801035:	83 c4 10             	add    $0x10,%esp
  801038:	85 c0                	test   %eax,%eax
  80103a:	78 06                	js     801042 <getchar+0x24>
	if (r < 1)
  80103c:	74 06                	je     801044 <getchar+0x26>
	return c;
  80103e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801042:	c9                   	leave  
  801043:	c3                   	ret    
		return -E_EOF;
  801044:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801049:	eb f7                	jmp    801042 <getchar+0x24>

0080104b <iscons>:
{
  80104b:	f3 0f 1e fb          	endbr32 
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801055:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801058:	50                   	push   %eax
  801059:	ff 75 08             	pushl  0x8(%ebp)
  80105c:	e8 b0 f3 ff ff       	call   800411 <fd_lookup>
  801061:	83 c4 10             	add    $0x10,%esp
  801064:	85 c0                	test   %eax,%eax
  801066:	78 11                	js     801079 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801068:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80106b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801071:	39 10                	cmp    %edx,(%eax)
  801073:	0f 94 c0             	sete   %al
  801076:	0f b6 c0             	movzbl %al,%eax
}
  801079:	c9                   	leave  
  80107a:	c3                   	ret    

0080107b <opencons>:
{
  80107b:	f3 0f 1e fb          	endbr32 
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801085:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801088:	50                   	push   %eax
  801089:	e8 2d f3 ff ff       	call   8003bb <fd_alloc>
  80108e:	83 c4 10             	add    $0x10,%esp
  801091:	85 c0                	test   %eax,%eax
  801093:	78 3a                	js     8010cf <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801095:	83 ec 04             	sub    $0x4,%esp
  801098:	68 07 04 00 00       	push   $0x407
  80109d:	ff 75 f4             	pushl  -0xc(%ebp)
  8010a0:	6a 00                	push   $0x0
  8010a2:	e8 d4 f0 ff ff       	call   80017b <sys_page_alloc>
  8010a7:	83 c4 10             	add    $0x10,%esp
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	78 21                	js     8010cf <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8010ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8010b7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8010b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010bc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8010c3:	83 ec 0c             	sub    $0xc,%esp
  8010c6:	50                   	push   %eax
  8010c7:	e8 c0 f2 ff ff       	call   80038c <fd2num>
  8010cc:	83 c4 10             	add    $0x10,%esp
}
  8010cf:	c9                   	leave  
  8010d0:	c3                   	ret    

008010d1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010d1:	f3 0f 1e fb          	endbr32 
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	56                   	push   %esi
  8010d9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010da:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010dd:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010e3:	e8 4d f0 ff ff       	call   800135 <sys_getenvid>
  8010e8:	83 ec 0c             	sub    $0xc,%esp
  8010eb:	ff 75 0c             	pushl  0xc(%ebp)
  8010ee:	ff 75 08             	pushl  0x8(%ebp)
  8010f1:	56                   	push   %esi
  8010f2:	50                   	push   %eax
  8010f3:	68 04 20 80 00       	push   $0x802004
  8010f8:	e8 bb 00 00 00       	call   8011b8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010fd:	83 c4 18             	add    $0x18,%esp
  801100:	53                   	push   %ebx
  801101:	ff 75 10             	pushl  0x10(%ebp)
  801104:	e8 5a 00 00 00       	call   801163 <vcprintf>
	cprintf("\n");
  801109:	c7 04 24 ef 1f 80 00 	movl   $0x801fef,(%esp)
  801110:	e8 a3 00 00 00       	call   8011b8 <cprintf>
  801115:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801118:	cc                   	int3   
  801119:	eb fd                	jmp    801118 <_panic+0x47>

0080111b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80111b:	f3 0f 1e fb          	endbr32 
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	53                   	push   %ebx
  801123:	83 ec 04             	sub    $0x4,%esp
  801126:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801129:	8b 13                	mov    (%ebx),%edx
  80112b:	8d 42 01             	lea    0x1(%edx),%eax
  80112e:	89 03                	mov    %eax,(%ebx)
  801130:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801133:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801137:	3d ff 00 00 00       	cmp    $0xff,%eax
  80113c:	74 09                	je     801147 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80113e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801142:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801145:	c9                   	leave  
  801146:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801147:	83 ec 08             	sub    $0x8,%esp
  80114a:	68 ff 00 00 00       	push   $0xff
  80114f:	8d 43 08             	lea    0x8(%ebx),%eax
  801152:	50                   	push   %eax
  801153:	e8 53 ef ff ff       	call   8000ab <sys_cputs>
		b->idx = 0;
  801158:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80115e:	83 c4 10             	add    $0x10,%esp
  801161:	eb db                	jmp    80113e <putch+0x23>

00801163 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801163:	f3 0f 1e fb          	endbr32 
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801170:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801177:	00 00 00 
	b.cnt = 0;
  80117a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801181:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801184:	ff 75 0c             	pushl  0xc(%ebp)
  801187:	ff 75 08             	pushl  0x8(%ebp)
  80118a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801190:	50                   	push   %eax
  801191:	68 1b 11 80 00       	push   $0x80111b
  801196:	e8 20 01 00 00       	call   8012bb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80119b:	83 c4 08             	add    $0x8,%esp
  80119e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8011a4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8011aa:	50                   	push   %eax
  8011ab:	e8 fb ee ff ff       	call   8000ab <sys_cputs>

	return b.cnt;
}
  8011b0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8011b6:	c9                   	leave  
  8011b7:	c3                   	ret    

008011b8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8011b8:	f3 0f 1e fb          	endbr32 
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
  8011bf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8011c2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8011c5:	50                   	push   %eax
  8011c6:	ff 75 08             	pushl  0x8(%ebp)
  8011c9:	e8 95 ff ff ff       	call   801163 <vcprintf>
	va_end(ap);

	return cnt;
}
  8011ce:	c9                   	leave  
  8011cf:	c3                   	ret    

008011d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	57                   	push   %edi
  8011d4:	56                   	push   %esi
  8011d5:	53                   	push   %ebx
  8011d6:	83 ec 1c             	sub    $0x1c,%esp
  8011d9:	89 c7                	mov    %eax,%edi
  8011db:	89 d6                	mov    %edx,%esi
  8011dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e3:	89 d1                	mov    %edx,%ecx
  8011e5:	89 c2                	mov    %eax,%edx
  8011e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8011ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8011f0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011f6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8011fd:	39 c2                	cmp    %eax,%edx
  8011ff:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801202:	72 3e                	jb     801242 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801204:	83 ec 0c             	sub    $0xc,%esp
  801207:	ff 75 18             	pushl  0x18(%ebp)
  80120a:	83 eb 01             	sub    $0x1,%ebx
  80120d:	53                   	push   %ebx
  80120e:	50                   	push   %eax
  80120f:	83 ec 08             	sub    $0x8,%esp
  801212:	ff 75 e4             	pushl  -0x1c(%ebp)
  801215:	ff 75 e0             	pushl  -0x20(%ebp)
  801218:	ff 75 dc             	pushl  -0x24(%ebp)
  80121b:	ff 75 d8             	pushl  -0x28(%ebp)
  80121e:	e8 4d 0a 00 00       	call   801c70 <__udivdi3>
  801223:	83 c4 18             	add    $0x18,%esp
  801226:	52                   	push   %edx
  801227:	50                   	push   %eax
  801228:	89 f2                	mov    %esi,%edx
  80122a:	89 f8                	mov    %edi,%eax
  80122c:	e8 9f ff ff ff       	call   8011d0 <printnum>
  801231:	83 c4 20             	add    $0x20,%esp
  801234:	eb 13                	jmp    801249 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801236:	83 ec 08             	sub    $0x8,%esp
  801239:	56                   	push   %esi
  80123a:	ff 75 18             	pushl  0x18(%ebp)
  80123d:	ff d7                	call   *%edi
  80123f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801242:	83 eb 01             	sub    $0x1,%ebx
  801245:	85 db                	test   %ebx,%ebx
  801247:	7f ed                	jg     801236 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801249:	83 ec 08             	sub    $0x8,%esp
  80124c:	56                   	push   %esi
  80124d:	83 ec 04             	sub    $0x4,%esp
  801250:	ff 75 e4             	pushl  -0x1c(%ebp)
  801253:	ff 75 e0             	pushl  -0x20(%ebp)
  801256:	ff 75 dc             	pushl  -0x24(%ebp)
  801259:	ff 75 d8             	pushl  -0x28(%ebp)
  80125c:	e8 1f 0b 00 00       	call   801d80 <__umoddi3>
  801261:	83 c4 14             	add    $0x14,%esp
  801264:	0f be 80 27 20 80 00 	movsbl 0x802027(%eax),%eax
  80126b:	50                   	push   %eax
  80126c:	ff d7                	call   *%edi
}
  80126e:	83 c4 10             	add    $0x10,%esp
  801271:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801274:	5b                   	pop    %ebx
  801275:	5e                   	pop    %esi
  801276:	5f                   	pop    %edi
  801277:	5d                   	pop    %ebp
  801278:	c3                   	ret    

00801279 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801279:	f3 0f 1e fb          	endbr32 
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801283:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801287:	8b 10                	mov    (%eax),%edx
  801289:	3b 50 04             	cmp    0x4(%eax),%edx
  80128c:	73 0a                	jae    801298 <sprintputch+0x1f>
		*b->buf++ = ch;
  80128e:	8d 4a 01             	lea    0x1(%edx),%ecx
  801291:	89 08                	mov    %ecx,(%eax)
  801293:	8b 45 08             	mov    0x8(%ebp),%eax
  801296:	88 02                	mov    %al,(%edx)
}
  801298:	5d                   	pop    %ebp
  801299:	c3                   	ret    

0080129a <printfmt>:
{
  80129a:	f3 0f 1e fb          	endbr32 
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8012a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012a7:	50                   	push   %eax
  8012a8:	ff 75 10             	pushl  0x10(%ebp)
  8012ab:	ff 75 0c             	pushl  0xc(%ebp)
  8012ae:	ff 75 08             	pushl  0x8(%ebp)
  8012b1:	e8 05 00 00 00       	call   8012bb <vprintfmt>
}
  8012b6:	83 c4 10             	add    $0x10,%esp
  8012b9:	c9                   	leave  
  8012ba:	c3                   	ret    

008012bb <vprintfmt>:
{
  8012bb:	f3 0f 1e fb          	endbr32 
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	57                   	push   %edi
  8012c3:	56                   	push   %esi
  8012c4:	53                   	push   %ebx
  8012c5:	83 ec 3c             	sub    $0x3c,%esp
  8012c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8012cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012ce:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012d1:	e9 4a 03 00 00       	jmp    801620 <vprintfmt+0x365>
		padc = ' ';
  8012d6:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012da:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012e1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012e8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012ef:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012f4:	8d 47 01             	lea    0x1(%edi),%eax
  8012f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012fa:	0f b6 17             	movzbl (%edi),%edx
  8012fd:	8d 42 dd             	lea    -0x23(%edx),%eax
  801300:	3c 55                	cmp    $0x55,%al
  801302:	0f 87 de 03 00 00    	ja     8016e6 <vprintfmt+0x42b>
  801308:	0f b6 c0             	movzbl %al,%eax
  80130b:	3e ff 24 85 60 21 80 	notrack jmp *0x802160(,%eax,4)
  801312:	00 
  801313:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801316:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80131a:	eb d8                	jmp    8012f4 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80131c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80131f:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801323:	eb cf                	jmp    8012f4 <vprintfmt+0x39>
  801325:	0f b6 d2             	movzbl %dl,%edx
  801328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80132b:	b8 00 00 00 00       	mov    $0x0,%eax
  801330:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801333:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801336:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80133a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80133d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801340:	83 f9 09             	cmp    $0x9,%ecx
  801343:	77 55                	ja     80139a <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  801345:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801348:	eb e9                	jmp    801333 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80134a:	8b 45 14             	mov    0x14(%ebp),%eax
  80134d:	8b 00                	mov    (%eax),%eax
  80134f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801352:	8b 45 14             	mov    0x14(%ebp),%eax
  801355:	8d 40 04             	lea    0x4(%eax),%eax
  801358:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80135b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80135e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801362:	79 90                	jns    8012f4 <vprintfmt+0x39>
				width = precision, precision = -1;
  801364:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801367:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80136a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801371:	eb 81                	jmp    8012f4 <vprintfmt+0x39>
  801373:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801376:	85 c0                	test   %eax,%eax
  801378:	ba 00 00 00 00       	mov    $0x0,%edx
  80137d:	0f 49 d0             	cmovns %eax,%edx
  801380:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801386:	e9 69 ff ff ff       	jmp    8012f4 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80138b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80138e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801395:	e9 5a ff ff ff       	jmp    8012f4 <vprintfmt+0x39>
  80139a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80139d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8013a0:	eb bc                	jmp    80135e <vprintfmt+0xa3>
			lflag++;
  8013a2:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8013a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8013a8:	e9 47 ff ff ff       	jmp    8012f4 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8013ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b0:	8d 78 04             	lea    0x4(%eax),%edi
  8013b3:	83 ec 08             	sub    $0x8,%esp
  8013b6:	53                   	push   %ebx
  8013b7:	ff 30                	pushl  (%eax)
  8013b9:	ff d6                	call   *%esi
			break;
  8013bb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8013be:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8013c1:	e9 57 02 00 00       	jmp    80161d <vprintfmt+0x362>
			err = va_arg(ap, int);
  8013c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c9:	8d 78 04             	lea    0x4(%eax),%edi
  8013cc:	8b 00                	mov    (%eax),%eax
  8013ce:	99                   	cltd   
  8013cf:	31 d0                	xor    %edx,%eax
  8013d1:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013d3:	83 f8 0f             	cmp    $0xf,%eax
  8013d6:	7f 23                	jg     8013fb <vprintfmt+0x140>
  8013d8:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  8013df:	85 d2                	test   %edx,%edx
  8013e1:	74 18                	je     8013fb <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8013e3:	52                   	push   %edx
  8013e4:	68 bd 1f 80 00       	push   $0x801fbd
  8013e9:	53                   	push   %ebx
  8013ea:	56                   	push   %esi
  8013eb:	e8 aa fe ff ff       	call   80129a <printfmt>
  8013f0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8013f3:	89 7d 14             	mov    %edi,0x14(%ebp)
  8013f6:	e9 22 02 00 00       	jmp    80161d <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8013fb:	50                   	push   %eax
  8013fc:	68 3f 20 80 00       	push   $0x80203f
  801401:	53                   	push   %ebx
  801402:	56                   	push   %esi
  801403:	e8 92 fe ff ff       	call   80129a <printfmt>
  801408:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80140b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80140e:	e9 0a 02 00 00       	jmp    80161d <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  801413:	8b 45 14             	mov    0x14(%ebp),%eax
  801416:	83 c0 04             	add    $0x4,%eax
  801419:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80141c:	8b 45 14             	mov    0x14(%ebp),%eax
  80141f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801421:	85 d2                	test   %edx,%edx
  801423:	b8 38 20 80 00       	mov    $0x802038,%eax
  801428:	0f 45 c2             	cmovne %edx,%eax
  80142b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80142e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801432:	7e 06                	jle    80143a <vprintfmt+0x17f>
  801434:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801438:	75 0d                	jne    801447 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80143a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80143d:	89 c7                	mov    %eax,%edi
  80143f:	03 45 e0             	add    -0x20(%ebp),%eax
  801442:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801445:	eb 55                	jmp    80149c <vprintfmt+0x1e1>
  801447:	83 ec 08             	sub    $0x8,%esp
  80144a:	ff 75 d8             	pushl  -0x28(%ebp)
  80144d:	ff 75 cc             	pushl  -0x34(%ebp)
  801450:	e8 45 03 00 00       	call   80179a <strnlen>
  801455:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801458:	29 c2                	sub    %eax,%edx
  80145a:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80145d:	83 c4 10             	add    $0x10,%esp
  801460:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  801462:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801466:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801469:	85 ff                	test   %edi,%edi
  80146b:	7e 11                	jle    80147e <vprintfmt+0x1c3>
					putch(padc, putdat);
  80146d:	83 ec 08             	sub    $0x8,%esp
  801470:	53                   	push   %ebx
  801471:	ff 75 e0             	pushl  -0x20(%ebp)
  801474:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801476:	83 ef 01             	sub    $0x1,%edi
  801479:	83 c4 10             	add    $0x10,%esp
  80147c:	eb eb                	jmp    801469 <vprintfmt+0x1ae>
  80147e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801481:	85 d2                	test   %edx,%edx
  801483:	b8 00 00 00 00       	mov    $0x0,%eax
  801488:	0f 49 c2             	cmovns %edx,%eax
  80148b:	29 c2                	sub    %eax,%edx
  80148d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801490:	eb a8                	jmp    80143a <vprintfmt+0x17f>
					putch(ch, putdat);
  801492:	83 ec 08             	sub    $0x8,%esp
  801495:	53                   	push   %ebx
  801496:	52                   	push   %edx
  801497:	ff d6                	call   *%esi
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80149f:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014a1:	83 c7 01             	add    $0x1,%edi
  8014a4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014a8:	0f be d0             	movsbl %al,%edx
  8014ab:	85 d2                	test   %edx,%edx
  8014ad:	74 4b                	je     8014fa <vprintfmt+0x23f>
  8014af:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014b3:	78 06                	js     8014bb <vprintfmt+0x200>
  8014b5:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014b9:	78 1e                	js     8014d9 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8014bb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014bf:	74 d1                	je     801492 <vprintfmt+0x1d7>
  8014c1:	0f be c0             	movsbl %al,%eax
  8014c4:	83 e8 20             	sub    $0x20,%eax
  8014c7:	83 f8 5e             	cmp    $0x5e,%eax
  8014ca:	76 c6                	jbe    801492 <vprintfmt+0x1d7>
					putch('?', putdat);
  8014cc:	83 ec 08             	sub    $0x8,%esp
  8014cf:	53                   	push   %ebx
  8014d0:	6a 3f                	push   $0x3f
  8014d2:	ff d6                	call   *%esi
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	eb c3                	jmp    80149c <vprintfmt+0x1e1>
  8014d9:	89 cf                	mov    %ecx,%edi
  8014db:	eb 0e                	jmp    8014eb <vprintfmt+0x230>
				putch(' ', putdat);
  8014dd:	83 ec 08             	sub    $0x8,%esp
  8014e0:	53                   	push   %ebx
  8014e1:	6a 20                	push   $0x20
  8014e3:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8014e5:	83 ef 01             	sub    $0x1,%edi
  8014e8:	83 c4 10             	add    $0x10,%esp
  8014eb:	85 ff                	test   %edi,%edi
  8014ed:	7f ee                	jg     8014dd <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8014ef:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8014f2:	89 45 14             	mov    %eax,0x14(%ebp)
  8014f5:	e9 23 01 00 00       	jmp    80161d <vprintfmt+0x362>
  8014fa:	89 cf                	mov    %ecx,%edi
  8014fc:	eb ed                	jmp    8014eb <vprintfmt+0x230>
	if (lflag >= 2)
  8014fe:	83 f9 01             	cmp    $0x1,%ecx
  801501:	7f 1b                	jg     80151e <vprintfmt+0x263>
	else if (lflag)
  801503:	85 c9                	test   %ecx,%ecx
  801505:	74 63                	je     80156a <vprintfmt+0x2af>
		return va_arg(*ap, long);
  801507:	8b 45 14             	mov    0x14(%ebp),%eax
  80150a:	8b 00                	mov    (%eax),%eax
  80150c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80150f:	99                   	cltd   
  801510:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801513:	8b 45 14             	mov    0x14(%ebp),%eax
  801516:	8d 40 04             	lea    0x4(%eax),%eax
  801519:	89 45 14             	mov    %eax,0x14(%ebp)
  80151c:	eb 17                	jmp    801535 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80151e:	8b 45 14             	mov    0x14(%ebp),%eax
  801521:	8b 50 04             	mov    0x4(%eax),%edx
  801524:	8b 00                	mov    (%eax),%eax
  801526:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801529:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80152c:	8b 45 14             	mov    0x14(%ebp),%eax
  80152f:	8d 40 08             	lea    0x8(%eax),%eax
  801532:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801535:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801538:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80153b:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  801540:	85 c9                	test   %ecx,%ecx
  801542:	0f 89 bb 00 00 00    	jns    801603 <vprintfmt+0x348>
				putch('-', putdat);
  801548:	83 ec 08             	sub    $0x8,%esp
  80154b:	53                   	push   %ebx
  80154c:	6a 2d                	push   $0x2d
  80154e:	ff d6                	call   *%esi
				num = -(long long) num;
  801550:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801553:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801556:	f7 da                	neg    %edx
  801558:	83 d1 00             	adc    $0x0,%ecx
  80155b:	f7 d9                	neg    %ecx
  80155d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801560:	b8 0a 00 00 00       	mov    $0xa,%eax
  801565:	e9 99 00 00 00       	jmp    801603 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80156a:	8b 45 14             	mov    0x14(%ebp),%eax
  80156d:	8b 00                	mov    (%eax),%eax
  80156f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801572:	99                   	cltd   
  801573:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801576:	8b 45 14             	mov    0x14(%ebp),%eax
  801579:	8d 40 04             	lea    0x4(%eax),%eax
  80157c:	89 45 14             	mov    %eax,0x14(%ebp)
  80157f:	eb b4                	jmp    801535 <vprintfmt+0x27a>
	if (lflag >= 2)
  801581:	83 f9 01             	cmp    $0x1,%ecx
  801584:	7f 1b                	jg     8015a1 <vprintfmt+0x2e6>
	else if (lflag)
  801586:	85 c9                	test   %ecx,%ecx
  801588:	74 2c                	je     8015b6 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80158a:	8b 45 14             	mov    0x14(%ebp),%eax
  80158d:	8b 10                	mov    (%eax),%edx
  80158f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801594:	8d 40 04             	lea    0x4(%eax),%eax
  801597:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80159a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80159f:	eb 62                	jmp    801603 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8015a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a4:	8b 10                	mov    (%eax),%edx
  8015a6:	8b 48 04             	mov    0x4(%eax),%ecx
  8015a9:	8d 40 08             	lea    0x8(%eax),%eax
  8015ac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015af:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8015b4:	eb 4d                	jmp    801603 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8015b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b9:	8b 10                	mov    (%eax),%edx
  8015bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015c0:	8d 40 04             	lea    0x4(%eax),%eax
  8015c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015c6:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8015cb:	eb 36                	jmp    801603 <vprintfmt+0x348>
	if (lflag >= 2)
  8015cd:	83 f9 01             	cmp    $0x1,%ecx
  8015d0:	7f 17                	jg     8015e9 <vprintfmt+0x32e>
	else if (lflag)
  8015d2:	85 c9                	test   %ecx,%ecx
  8015d4:	74 6e                	je     801644 <vprintfmt+0x389>
		return va_arg(*ap, long);
  8015d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d9:	8b 10                	mov    (%eax),%edx
  8015db:	89 d0                	mov    %edx,%eax
  8015dd:	99                   	cltd   
  8015de:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015e1:	8d 49 04             	lea    0x4(%ecx),%ecx
  8015e4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8015e7:	eb 11                	jmp    8015fa <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8015e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ec:	8b 50 04             	mov    0x4(%eax),%edx
  8015ef:	8b 00                	mov    (%eax),%eax
  8015f1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015f4:	8d 49 08             	lea    0x8(%ecx),%ecx
  8015f7:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8015fa:	89 d1                	mov    %edx,%ecx
  8015fc:	89 c2                	mov    %eax,%edx
            base = 8;
  8015fe:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  801603:	83 ec 0c             	sub    $0xc,%esp
  801606:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80160a:	57                   	push   %edi
  80160b:	ff 75 e0             	pushl  -0x20(%ebp)
  80160e:	50                   	push   %eax
  80160f:	51                   	push   %ecx
  801610:	52                   	push   %edx
  801611:	89 da                	mov    %ebx,%edx
  801613:	89 f0                	mov    %esi,%eax
  801615:	e8 b6 fb ff ff       	call   8011d0 <printnum>
			break;
  80161a:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80161d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801620:	83 c7 01             	add    $0x1,%edi
  801623:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801627:	83 f8 25             	cmp    $0x25,%eax
  80162a:	0f 84 a6 fc ff ff    	je     8012d6 <vprintfmt+0x1b>
			if (ch == '\0')
  801630:	85 c0                	test   %eax,%eax
  801632:	0f 84 ce 00 00 00    	je     801706 <vprintfmt+0x44b>
			putch(ch, putdat);
  801638:	83 ec 08             	sub    $0x8,%esp
  80163b:	53                   	push   %ebx
  80163c:	50                   	push   %eax
  80163d:	ff d6                	call   *%esi
  80163f:	83 c4 10             	add    $0x10,%esp
  801642:	eb dc                	jmp    801620 <vprintfmt+0x365>
		return va_arg(*ap, int);
  801644:	8b 45 14             	mov    0x14(%ebp),%eax
  801647:	8b 10                	mov    (%eax),%edx
  801649:	89 d0                	mov    %edx,%eax
  80164b:	99                   	cltd   
  80164c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80164f:	8d 49 04             	lea    0x4(%ecx),%ecx
  801652:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801655:	eb a3                	jmp    8015fa <vprintfmt+0x33f>
			putch('0', putdat);
  801657:	83 ec 08             	sub    $0x8,%esp
  80165a:	53                   	push   %ebx
  80165b:	6a 30                	push   $0x30
  80165d:	ff d6                	call   *%esi
			putch('x', putdat);
  80165f:	83 c4 08             	add    $0x8,%esp
  801662:	53                   	push   %ebx
  801663:	6a 78                	push   $0x78
  801665:	ff d6                	call   *%esi
			num = (unsigned long long)
  801667:	8b 45 14             	mov    0x14(%ebp),%eax
  80166a:	8b 10                	mov    (%eax),%edx
  80166c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801671:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801674:	8d 40 04             	lea    0x4(%eax),%eax
  801677:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80167a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80167f:	eb 82                	jmp    801603 <vprintfmt+0x348>
	if (lflag >= 2)
  801681:	83 f9 01             	cmp    $0x1,%ecx
  801684:	7f 1e                	jg     8016a4 <vprintfmt+0x3e9>
	else if (lflag)
  801686:	85 c9                	test   %ecx,%ecx
  801688:	74 32                	je     8016bc <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80168a:	8b 45 14             	mov    0x14(%ebp),%eax
  80168d:	8b 10                	mov    (%eax),%edx
  80168f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801694:	8d 40 04             	lea    0x4(%eax),%eax
  801697:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80169a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80169f:	e9 5f ff ff ff       	jmp    801603 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8016a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8016a7:	8b 10                	mov    (%eax),%edx
  8016a9:	8b 48 04             	mov    0x4(%eax),%ecx
  8016ac:	8d 40 08             	lea    0x8(%eax),%eax
  8016af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016b2:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8016b7:	e9 47 ff ff ff       	jmp    801603 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8016bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8016bf:	8b 10                	mov    (%eax),%edx
  8016c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016c6:	8d 40 04             	lea    0x4(%eax),%eax
  8016c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016cc:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8016d1:	e9 2d ff ff ff       	jmp    801603 <vprintfmt+0x348>
			putch(ch, putdat);
  8016d6:	83 ec 08             	sub    $0x8,%esp
  8016d9:	53                   	push   %ebx
  8016da:	6a 25                	push   $0x25
  8016dc:	ff d6                	call   *%esi
			break;
  8016de:	83 c4 10             	add    $0x10,%esp
  8016e1:	e9 37 ff ff ff       	jmp    80161d <vprintfmt+0x362>
			putch('%', putdat);
  8016e6:	83 ec 08             	sub    $0x8,%esp
  8016e9:	53                   	push   %ebx
  8016ea:	6a 25                	push   $0x25
  8016ec:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8016ee:	83 c4 10             	add    $0x10,%esp
  8016f1:	89 f8                	mov    %edi,%eax
  8016f3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8016f7:	74 05                	je     8016fe <vprintfmt+0x443>
  8016f9:	83 e8 01             	sub    $0x1,%eax
  8016fc:	eb f5                	jmp    8016f3 <vprintfmt+0x438>
  8016fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801701:	e9 17 ff ff ff       	jmp    80161d <vprintfmt+0x362>
}
  801706:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801709:	5b                   	pop    %ebx
  80170a:	5e                   	pop    %esi
  80170b:	5f                   	pop    %edi
  80170c:	5d                   	pop    %ebp
  80170d:	c3                   	ret    

0080170e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80170e:	f3 0f 1e fb          	endbr32 
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	83 ec 18             	sub    $0x18,%esp
  801718:	8b 45 08             	mov    0x8(%ebp),%eax
  80171b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80171e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801721:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801725:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801728:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80172f:	85 c0                	test   %eax,%eax
  801731:	74 26                	je     801759 <vsnprintf+0x4b>
  801733:	85 d2                	test   %edx,%edx
  801735:	7e 22                	jle    801759 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801737:	ff 75 14             	pushl  0x14(%ebp)
  80173a:	ff 75 10             	pushl  0x10(%ebp)
  80173d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801740:	50                   	push   %eax
  801741:	68 79 12 80 00       	push   $0x801279
  801746:	e8 70 fb ff ff       	call   8012bb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80174b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80174e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801751:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801754:	83 c4 10             	add    $0x10,%esp
}
  801757:	c9                   	leave  
  801758:	c3                   	ret    
		return -E_INVAL;
  801759:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80175e:	eb f7                	jmp    801757 <vsnprintf+0x49>

00801760 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801760:	f3 0f 1e fb          	endbr32 
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80176a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80176d:	50                   	push   %eax
  80176e:	ff 75 10             	pushl  0x10(%ebp)
  801771:	ff 75 0c             	pushl  0xc(%ebp)
  801774:	ff 75 08             	pushl  0x8(%ebp)
  801777:	e8 92 ff ff ff       	call   80170e <vsnprintf>
	va_end(ap);

	return rc;
}
  80177c:	c9                   	leave  
  80177d:	c3                   	ret    

0080177e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80177e:	f3 0f 1e fb          	endbr32 
  801782:	55                   	push   %ebp
  801783:	89 e5                	mov    %esp,%ebp
  801785:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801788:	b8 00 00 00 00       	mov    $0x0,%eax
  80178d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801791:	74 05                	je     801798 <strlen+0x1a>
		n++;
  801793:	83 c0 01             	add    $0x1,%eax
  801796:	eb f5                	jmp    80178d <strlen+0xf>
	return n;
}
  801798:	5d                   	pop    %ebp
  801799:	c3                   	ret    

0080179a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80179a:	f3 0f 1e fb          	endbr32 
  80179e:	55                   	push   %ebp
  80179f:	89 e5                	mov    %esp,%ebp
  8017a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8017a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ac:	39 d0                	cmp    %edx,%eax
  8017ae:	74 0d                	je     8017bd <strnlen+0x23>
  8017b0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8017b4:	74 05                	je     8017bb <strnlen+0x21>
		n++;
  8017b6:	83 c0 01             	add    $0x1,%eax
  8017b9:	eb f1                	jmp    8017ac <strnlen+0x12>
  8017bb:	89 c2                	mov    %eax,%edx
	return n;
}
  8017bd:	89 d0                	mov    %edx,%eax
  8017bf:	5d                   	pop    %ebp
  8017c0:	c3                   	ret    

008017c1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8017c1:	f3 0f 1e fb          	endbr32 
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	53                   	push   %ebx
  8017c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8017cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d4:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8017d8:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8017db:	83 c0 01             	add    $0x1,%eax
  8017de:	84 d2                	test   %dl,%dl
  8017e0:	75 f2                	jne    8017d4 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8017e2:	89 c8                	mov    %ecx,%eax
  8017e4:	5b                   	pop    %ebx
  8017e5:	5d                   	pop    %ebp
  8017e6:	c3                   	ret    

008017e7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017e7:	f3 0f 1e fb          	endbr32 
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	53                   	push   %ebx
  8017ef:	83 ec 10             	sub    $0x10,%esp
  8017f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8017f5:	53                   	push   %ebx
  8017f6:	e8 83 ff ff ff       	call   80177e <strlen>
  8017fb:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8017fe:	ff 75 0c             	pushl  0xc(%ebp)
  801801:	01 d8                	add    %ebx,%eax
  801803:	50                   	push   %eax
  801804:	e8 b8 ff ff ff       	call   8017c1 <strcpy>
	return dst;
}
  801809:	89 d8                	mov    %ebx,%eax
  80180b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180e:	c9                   	leave  
  80180f:	c3                   	ret    

00801810 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801810:	f3 0f 1e fb          	endbr32 
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	56                   	push   %esi
  801818:	53                   	push   %ebx
  801819:	8b 75 08             	mov    0x8(%ebp),%esi
  80181c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80181f:	89 f3                	mov    %esi,%ebx
  801821:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801824:	89 f0                	mov    %esi,%eax
  801826:	39 d8                	cmp    %ebx,%eax
  801828:	74 11                	je     80183b <strncpy+0x2b>
		*dst++ = *src;
  80182a:	83 c0 01             	add    $0x1,%eax
  80182d:	0f b6 0a             	movzbl (%edx),%ecx
  801830:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801833:	80 f9 01             	cmp    $0x1,%cl
  801836:	83 da ff             	sbb    $0xffffffff,%edx
  801839:	eb eb                	jmp    801826 <strncpy+0x16>
	}
	return ret;
}
  80183b:	89 f0                	mov    %esi,%eax
  80183d:	5b                   	pop    %ebx
  80183e:	5e                   	pop    %esi
  80183f:	5d                   	pop    %ebp
  801840:	c3                   	ret    

00801841 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801841:	f3 0f 1e fb          	endbr32 
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	56                   	push   %esi
  801849:	53                   	push   %ebx
  80184a:	8b 75 08             	mov    0x8(%ebp),%esi
  80184d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801850:	8b 55 10             	mov    0x10(%ebp),%edx
  801853:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801855:	85 d2                	test   %edx,%edx
  801857:	74 21                	je     80187a <strlcpy+0x39>
  801859:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80185d:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80185f:	39 c2                	cmp    %eax,%edx
  801861:	74 14                	je     801877 <strlcpy+0x36>
  801863:	0f b6 19             	movzbl (%ecx),%ebx
  801866:	84 db                	test   %bl,%bl
  801868:	74 0b                	je     801875 <strlcpy+0x34>
			*dst++ = *src++;
  80186a:	83 c1 01             	add    $0x1,%ecx
  80186d:	83 c2 01             	add    $0x1,%edx
  801870:	88 5a ff             	mov    %bl,-0x1(%edx)
  801873:	eb ea                	jmp    80185f <strlcpy+0x1e>
  801875:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801877:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80187a:	29 f0                	sub    %esi,%eax
}
  80187c:	5b                   	pop    %ebx
  80187d:	5e                   	pop    %esi
  80187e:	5d                   	pop    %ebp
  80187f:	c3                   	ret    

00801880 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801880:	f3 0f 1e fb          	endbr32 
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80188a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80188d:	0f b6 01             	movzbl (%ecx),%eax
  801890:	84 c0                	test   %al,%al
  801892:	74 0c                	je     8018a0 <strcmp+0x20>
  801894:	3a 02                	cmp    (%edx),%al
  801896:	75 08                	jne    8018a0 <strcmp+0x20>
		p++, q++;
  801898:	83 c1 01             	add    $0x1,%ecx
  80189b:	83 c2 01             	add    $0x1,%edx
  80189e:	eb ed                	jmp    80188d <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8018a0:	0f b6 c0             	movzbl %al,%eax
  8018a3:	0f b6 12             	movzbl (%edx),%edx
  8018a6:	29 d0                	sub    %edx,%eax
}
  8018a8:	5d                   	pop    %ebp
  8018a9:	c3                   	ret    

008018aa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8018aa:	f3 0f 1e fb          	endbr32 
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	53                   	push   %ebx
  8018b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018b8:	89 c3                	mov    %eax,%ebx
  8018ba:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8018bd:	eb 06                	jmp    8018c5 <strncmp+0x1b>
		n--, p++, q++;
  8018bf:	83 c0 01             	add    $0x1,%eax
  8018c2:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8018c5:	39 d8                	cmp    %ebx,%eax
  8018c7:	74 16                	je     8018df <strncmp+0x35>
  8018c9:	0f b6 08             	movzbl (%eax),%ecx
  8018cc:	84 c9                	test   %cl,%cl
  8018ce:	74 04                	je     8018d4 <strncmp+0x2a>
  8018d0:	3a 0a                	cmp    (%edx),%cl
  8018d2:	74 eb                	je     8018bf <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8018d4:	0f b6 00             	movzbl (%eax),%eax
  8018d7:	0f b6 12             	movzbl (%edx),%edx
  8018da:	29 d0                	sub    %edx,%eax
}
  8018dc:	5b                   	pop    %ebx
  8018dd:	5d                   	pop    %ebp
  8018de:	c3                   	ret    
		return 0;
  8018df:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e4:	eb f6                	jmp    8018dc <strncmp+0x32>

008018e6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8018e6:	f3 0f 1e fb          	endbr32 
  8018ea:	55                   	push   %ebp
  8018eb:	89 e5                	mov    %esp,%ebp
  8018ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018f4:	0f b6 10             	movzbl (%eax),%edx
  8018f7:	84 d2                	test   %dl,%dl
  8018f9:	74 09                	je     801904 <strchr+0x1e>
		if (*s == c)
  8018fb:	38 ca                	cmp    %cl,%dl
  8018fd:	74 0a                	je     801909 <strchr+0x23>
	for (; *s; s++)
  8018ff:	83 c0 01             	add    $0x1,%eax
  801902:	eb f0                	jmp    8018f4 <strchr+0xe>
			return (char *) s;
	return 0;
  801904:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    

0080190b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80190b:	f3 0f 1e fb          	endbr32 
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	8b 45 08             	mov    0x8(%ebp),%eax
  801915:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801919:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80191c:	38 ca                	cmp    %cl,%dl
  80191e:	74 09                	je     801929 <strfind+0x1e>
  801920:	84 d2                	test   %dl,%dl
  801922:	74 05                	je     801929 <strfind+0x1e>
	for (; *s; s++)
  801924:	83 c0 01             	add    $0x1,%eax
  801927:	eb f0                	jmp    801919 <strfind+0xe>
			break;
	return (char *) s;
}
  801929:	5d                   	pop    %ebp
  80192a:	c3                   	ret    

0080192b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80192b:	f3 0f 1e fb          	endbr32 
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	57                   	push   %edi
  801933:	56                   	push   %esi
  801934:	53                   	push   %ebx
  801935:	8b 7d 08             	mov    0x8(%ebp),%edi
  801938:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80193b:	85 c9                	test   %ecx,%ecx
  80193d:	74 31                	je     801970 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80193f:	89 f8                	mov    %edi,%eax
  801941:	09 c8                	or     %ecx,%eax
  801943:	a8 03                	test   $0x3,%al
  801945:	75 23                	jne    80196a <memset+0x3f>
		c &= 0xFF;
  801947:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80194b:	89 d3                	mov    %edx,%ebx
  80194d:	c1 e3 08             	shl    $0x8,%ebx
  801950:	89 d0                	mov    %edx,%eax
  801952:	c1 e0 18             	shl    $0x18,%eax
  801955:	89 d6                	mov    %edx,%esi
  801957:	c1 e6 10             	shl    $0x10,%esi
  80195a:	09 f0                	or     %esi,%eax
  80195c:	09 c2                	or     %eax,%edx
  80195e:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801960:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801963:	89 d0                	mov    %edx,%eax
  801965:	fc                   	cld    
  801966:	f3 ab                	rep stos %eax,%es:(%edi)
  801968:	eb 06                	jmp    801970 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80196a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196d:	fc                   	cld    
  80196e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801970:	89 f8                	mov    %edi,%eax
  801972:	5b                   	pop    %ebx
  801973:	5e                   	pop    %esi
  801974:	5f                   	pop    %edi
  801975:	5d                   	pop    %ebp
  801976:	c3                   	ret    

00801977 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801977:	f3 0f 1e fb          	endbr32 
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	57                   	push   %edi
  80197f:	56                   	push   %esi
  801980:	8b 45 08             	mov    0x8(%ebp),%eax
  801983:	8b 75 0c             	mov    0xc(%ebp),%esi
  801986:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801989:	39 c6                	cmp    %eax,%esi
  80198b:	73 32                	jae    8019bf <memmove+0x48>
  80198d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801990:	39 c2                	cmp    %eax,%edx
  801992:	76 2b                	jbe    8019bf <memmove+0x48>
		s += n;
		d += n;
  801994:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801997:	89 fe                	mov    %edi,%esi
  801999:	09 ce                	or     %ecx,%esi
  80199b:	09 d6                	or     %edx,%esi
  80199d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8019a3:	75 0e                	jne    8019b3 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8019a5:	83 ef 04             	sub    $0x4,%edi
  8019a8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8019ab:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8019ae:	fd                   	std    
  8019af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019b1:	eb 09                	jmp    8019bc <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8019b3:	83 ef 01             	sub    $0x1,%edi
  8019b6:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8019b9:	fd                   	std    
  8019ba:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8019bc:	fc                   	cld    
  8019bd:	eb 1a                	jmp    8019d9 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019bf:	89 c2                	mov    %eax,%edx
  8019c1:	09 ca                	or     %ecx,%edx
  8019c3:	09 f2                	or     %esi,%edx
  8019c5:	f6 c2 03             	test   $0x3,%dl
  8019c8:	75 0a                	jne    8019d4 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8019ca:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8019cd:	89 c7                	mov    %eax,%edi
  8019cf:	fc                   	cld    
  8019d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019d2:	eb 05                	jmp    8019d9 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8019d4:	89 c7                	mov    %eax,%edi
  8019d6:	fc                   	cld    
  8019d7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8019d9:	5e                   	pop    %esi
  8019da:	5f                   	pop    %edi
  8019db:	5d                   	pop    %ebp
  8019dc:	c3                   	ret    

008019dd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8019dd:	f3 0f 1e fb          	endbr32 
  8019e1:	55                   	push   %ebp
  8019e2:	89 e5                	mov    %esp,%ebp
  8019e4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8019e7:	ff 75 10             	pushl  0x10(%ebp)
  8019ea:	ff 75 0c             	pushl  0xc(%ebp)
  8019ed:	ff 75 08             	pushl  0x8(%ebp)
  8019f0:	e8 82 ff ff ff       	call   801977 <memmove>
}
  8019f5:	c9                   	leave  
  8019f6:	c3                   	ret    

008019f7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8019f7:	f3 0f 1e fb          	endbr32 
  8019fb:	55                   	push   %ebp
  8019fc:	89 e5                	mov    %esp,%ebp
  8019fe:	56                   	push   %esi
  8019ff:	53                   	push   %ebx
  801a00:	8b 45 08             	mov    0x8(%ebp),%eax
  801a03:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a06:	89 c6                	mov    %eax,%esi
  801a08:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a0b:	39 f0                	cmp    %esi,%eax
  801a0d:	74 1c                	je     801a2b <memcmp+0x34>
		if (*s1 != *s2)
  801a0f:	0f b6 08             	movzbl (%eax),%ecx
  801a12:	0f b6 1a             	movzbl (%edx),%ebx
  801a15:	38 d9                	cmp    %bl,%cl
  801a17:	75 08                	jne    801a21 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801a19:	83 c0 01             	add    $0x1,%eax
  801a1c:	83 c2 01             	add    $0x1,%edx
  801a1f:	eb ea                	jmp    801a0b <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801a21:	0f b6 c1             	movzbl %cl,%eax
  801a24:	0f b6 db             	movzbl %bl,%ebx
  801a27:	29 d8                	sub    %ebx,%eax
  801a29:	eb 05                	jmp    801a30 <memcmp+0x39>
	}

	return 0;
  801a2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a30:	5b                   	pop    %ebx
  801a31:	5e                   	pop    %esi
  801a32:	5d                   	pop    %ebp
  801a33:	c3                   	ret    

00801a34 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a34:	f3 0f 1e fb          	endbr32 
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a41:	89 c2                	mov    %eax,%edx
  801a43:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a46:	39 d0                	cmp    %edx,%eax
  801a48:	73 09                	jae    801a53 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a4a:	38 08                	cmp    %cl,(%eax)
  801a4c:	74 05                	je     801a53 <memfind+0x1f>
	for (; s < ends; s++)
  801a4e:	83 c0 01             	add    $0x1,%eax
  801a51:	eb f3                	jmp    801a46 <memfind+0x12>
			break;
	return (void *) s;
}
  801a53:	5d                   	pop    %ebp
  801a54:	c3                   	ret    

00801a55 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a55:	f3 0f 1e fb          	endbr32 
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	57                   	push   %edi
  801a5d:	56                   	push   %esi
  801a5e:	53                   	push   %ebx
  801a5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a62:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a65:	eb 03                	jmp    801a6a <strtol+0x15>
		s++;
  801a67:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801a6a:	0f b6 01             	movzbl (%ecx),%eax
  801a6d:	3c 20                	cmp    $0x20,%al
  801a6f:	74 f6                	je     801a67 <strtol+0x12>
  801a71:	3c 09                	cmp    $0x9,%al
  801a73:	74 f2                	je     801a67 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801a75:	3c 2b                	cmp    $0x2b,%al
  801a77:	74 2a                	je     801aa3 <strtol+0x4e>
	int neg = 0;
  801a79:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801a7e:	3c 2d                	cmp    $0x2d,%al
  801a80:	74 2b                	je     801aad <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a82:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a88:	75 0f                	jne    801a99 <strtol+0x44>
  801a8a:	80 39 30             	cmpb   $0x30,(%ecx)
  801a8d:	74 28                	je     801ab7 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a8f:	85 db                	test   %ebx,%ebx
  801a91:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a96:	0f 44 d8             	cmove  %eax,%ebx
  801a99:	b8 00 00 00 00       	mov    $0x0,%eax
  801a9e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801aa1:	eb 46                	jmp    801ae9 <strtol+0x94>
		s++;
  801aa3:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801aa6:	bf 00 00 00 00       	mov    $0x0,%edi
  801aab:	eb d5                	jmp    801a82 <strtol+0x2d>
		s++, neg = 1;
  801aad:	83 c1 01             	add    $0x1,%ecx
  801ab0:	bf 01 00 00 00       	mov    $0x1,%edi
  801ab5:	eb cb                	jmp    801a82 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ab7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801abb:	74 0e                	je     801acb <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801abd:	85 db                	test   %ebx,%ebx
  801abf:	75 d8                	jne    801a99 <strtol+0x44>
		s++, base = 8;
  801ac1:	83 c1 01             	add    $0x1,%ecx
  801ac4:	bb 08 00 00 00       	mov    $0x8,%ebx
  801ac9:	eb ce                	jmp    801a99 <strtol+0x44>
		s += 2, base = 16;
  801acb:	83 c1 02             	add    $0x2,%ecx
  801ace:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ad3:	eb c4                	jmp    801a99 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801ad5:	0f be d2             	movsbl %dl,%edx
  801ad8:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801adb:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ade:	7d 3a                	jge    801b1a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801ae0:	83 c1 01             	add    $0x1,%ecx
  801ae3:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ae7:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801ae9:	0f b6 11             	movzbl (%ecx),%edx
  801aec:	8d 72 d0             	lea    -0x30(%edx),%esi
  801aef:	89 f3                	mov    %esi,%ebx
  801af1:	80 fb 09             	cmp    $0x9,%bl
  801af4:	76 df                	jbe    801ad5 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801af6:	8d 72 9f             	lea    -0x61(%edx),%esi
  801af9:	89 f3                	mov    %esi,%ebx
  801afb:	80 fb 19             	cmp    $0x19,%bl
  801afe:	77 08                	ja     801b08 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801b00:	0f be d2             	movsbl %dl,%edx
  801b03:	83 ea 57             	sub    $0x57,%edx
  801b06:	eb d3                	jmp    801adb <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801b08:	8d 72 bf             	lea    -0x41(%edx),%esi
  801b0b:	89 f3                	mov    %esi,%ebx
  801b0d:	80 fb 19             	cmp    $0x19,%bl
  801b10:	77 08                	ja     801b1a <strtol+0xc5>
			dig = *s - 'A' + 10;
  801b12:	0f be d2             	movsbl %dl,%edx
  801b15:	83 ea 37             	sub    $0x37,%edx
  801b18:	eb c1                	jmp    801adb <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801b1a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b1e:	74 05                	je     801b25 <strtol+0xd0>
		*endptr = (char *) s;
  801b20:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b23:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801b25:	89 c2                	mov    %eax,%edx
  801b27:	f7 da                	neg    %edx
  801b29:	85 ff                	test   %edi,%edi
  801b2b:	0f 45 c2             	cmovne %edx,%eax
}
  801b2e:	5b                   	pop    %ebx
  801b2f:	5e                   	pop    %esi
  801b30:	5f                   	pop    %edi
  801b31:	5d                   	pop    %ebp
  801b32:	c3                   	ret    

00801b33 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b33:	f3 0f 1e fb          	endbr32 
  801b37:	55                   	push   %ebp
  801b38:	89 e5                	mov    %esp,%ebp
  801b3a:	56                   	push   %esi
  801b3b:	53                   	push   %ebx
  801b3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b42:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801b45:	85 c0                	test   %eax,%eax
  801b47:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b4c:	0f 44 c2             	cmove  %edx,%eax
  801b4f:	83 ec 0c             	sub    $0xc,%esp
  801b52:	50                   	push   %eax
  801b53:	e8 ef e7 ff ff       	call   800347 <sys_ipc_recv>
  801b58:	83 c4 10             	add    $0x10,%esp
  801b5b:	85 c0                	test   %eax,%eax
  801b5d:	78 24                	js     801b83 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801b5f:	85 f6                	test   %esi,%esi
  801b61:	74 0a                	je     801b6d <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801b63:	a1 04 40 80 00       	mov    0x804004,%eax
  801b68:	8b 40 78             	mov    0x78(%eax),%eax
  801b6b:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801b6d:	85 db                	test   %ebx,%ebx
  801b6f:	74 0a                	je     801b7b <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801b71:	a1 04 40 80 00       	mov    0x804004,%eax
  801b76:	8b 40 74             	mov    0x74(%eax),%eax
  801b79:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801b7b:	a1 04 40 80 00       	mov    0x804004,%eax
  801b80:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b86:	5b                   	pop    %ebx
  801b87:	5e                   	pop    %esi
  801b88:	5d                   	pop    %ebp
  801b89:	c3                   	ret    

00801b8a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b8a:	f3 0f 1e fb          	endbr32 
  801b8e:	55                   	push   %ebp
  801b8f:	89 e5                	mov    %esp,%ebp
  801b91:	57                   	push   %edi
  801b92:	56                   	push   %esi
  801b93:	53                   	push   %ebx
  801b94:	83 ec 1c             	sub    $0x1c,%esp
  801b97:	8b 45 10             	mov    0x10(%ebp),%eax
  801b9a:	85 c0                	test   %eax,%eax
  801b9c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801ba1:	0f 45 d0             	cmovne %eax,%edx
  801ba4:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801ba6:	be 01 00 00 00       	mov    $0x1,%esi
  801bab:	eb 1f                	jmp    801bcc <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801bad:	e8 a6 e5 ff ff       	call   800158 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801bb2:	83 c3 01             	add    $0x1,%ebx
  801bb5:	39 de                	cmp    %ebx,%esi
  801bb7:	7f f4                	jg     801bad <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801bb9:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801bbb:	83 fe 11             	cmp    $0x11,%esi
  801bbe:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc3:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801bc6:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801bca:	75 1c                	jne    801be8 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801bcc:	ff 75 14             	pushl  0x14(%ebp)
  801bcf:	57                   	push   %edi
  801bd0:	ff 75 0c             	pushl  0xc(%ebp)
  801bd3:	ff 75 08             	pushl  0x8(%ebp)
  801bd6:	e8 45 e7 ff ff       	call   800320 <sys_ipc_try_send>
  801bdb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801be6:	eb cd                	jmp    801bb5 <ipc_send+0x2b>
}
  801be8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801beb:	5b                   	pop    %ebx
  801bec:	5e                   	pop    %esi
  801bed:	5f                   	pop    %edi
  801bee:	5d                   	pop    %ebp
  801bef:	c3                   	ret    

00801bf0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bf0:	f3 0f 1e fb          	endbr32 
  801bf4:	55                   	push   %ebp
  801bf5:	89 e5                	mov    %esp,%ebp
  801bf7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bfa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bff:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c02:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c08:	8b 52 50             	mov    0x50(%edx),%edx
  801c0b:	39 ca                	cmp    %ecx,%edx
  801c0d:	74 11                	je     801c20 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801c0f:	83 c0 01             	add    $0x1,%eax
  801c12:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c17:	75 e6                	jne    801bff <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801c19:	b8 00 00 00 00       	mov    $0x0,%eax
  801c1e:	eb 0b                	jmp    801c2b <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c20:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c23:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c28:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c2b:	5d                   	pop    %ebp
  801c2c:	c3                   	ret    

00801c2d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c2d:	f3 0f 1e fb          	endbr32 
  801c31:	55                   	push   %ebp
  801c32:	89 e5                	mov    %esp,%ebp
  801c34:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c37:	89 c2                	mov    %eax,%edx
  801c39:	c1 ea 16             	shr    $0x16,%edx
  801c3c:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c43:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c48:	f6 c1 01             	test   $0x1,%cl
  801c4b:	74 1c                	je     801c69 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c4d:	c1 e8 0c             	shr    $0xc,%eax
  801c50:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c57:	a8 01                	test   $0x1,%al
  801c59:	74 0e                	je     801c69 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c5b:	c1 e8 0c             	shr    $0xc,%eax
  801c5e:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c65:	ef 
  801c66:	0f b7 d2             	movzwl %dx,%edx
}
  801c69:	89 d0                	mov    %edx,%eax
  801c6b:	5d                   	pop    %ebp
  801c6c:	c3                   	ret    
  801c6d:	66 90                	xchg   %ax,%ax
  801c6f:	90                   	nop

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
