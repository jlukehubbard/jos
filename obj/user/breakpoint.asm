
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
  800124:	68 ca 1e 80 00       	push   $0x801eca
  800129:	6a 23                	push   $0x23
  80012b:	68 e7 1e 80 00       	push   $0x801ee7
  800130:	e8 70 0f 00 00       	call   8010a5 <_panic>

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
  8001b1:	68 ca 1e 80 00       	push   $0x801eca
  8001b6:	6a 23                	push   $0x23
  8001b8:	68 e7 1e 80 00       	push   $0x801ee7
  8001bd:	e8 e3 0e 00 00       	call   8010a5 <_panic>

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
  8001f7:	68 ca 1e 80 00       	push   $0x801eca
  8001fc:	6a 23                	push   $0x23
  8001fe:	68 e7 1e 80 00       	push   $0x801ee7
  800203:	e8 9d 0e 00 00       	call   8010a5 <_panic>

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
  80023d:	68 ca 1e 80 00       	push   $0x801eca
  800242:	6a 23                	push   $0x23
  800244:	68 e7 1e 80 00       	push   $0x801ee7
  800249:	e8 57 0e 00 00       	call   8010a5 <_panic>

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
  800283:	68 ca 1e 80 00       	push   $0x801eca
  800288:	6a 23                	push   $0x23
  80028a:	68 e7 1e 80 00       	push   $0x801ee7
  80028f:	e8 11 0e 00 00       	call   8010a5 <_panic>

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
  8002c9:	68 ca 1e 80 00       	push   $0x801eca
  8002ce:	6a 23                	push   $0x23
  8002d0:	68 e7 1e 80 00       	push   $0x801ee7
  8002d5:	e8 cb 0d 00 00       	call   8010a5 <_panic>

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
  80030f:	68 ca 1e 80 00       	push   $0x801eca
  800314:	6a 23                	push   $0x23
  800316:	68 e7 1e 80 00       	push   $0x801ee7
  80031b:	e8 85 0d 00 00       	call   8010a5 <_panic>

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
  80037b:	68 ca 1e 80 00       	push   $0x801eca
  800380:	6a 23                	push   $0x23
  800382:	68 e7 1e 80 00       	push   $0x801ee7
  800387:	e8 19 0d 00 00       	call   8010a5 <_panic>

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
  800472:	ba 74 1f 80 00       	mov    $0x801f74,%edx
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
  800496:	68 f8 1e 80 00       	push   $0x801ef8
  80049b:	e8 ec 0c 00 00       	call   80118c <cprintf>
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
  800704:	68 39 1f 80 00       	push   $0x801f39
  800709:	e8 7e 0a 00 00       	call   80118c <cprintf>
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
  8007d5:	68 55 1f 80 00       	push   $0x801f55
  8007da:	e8 ad 09 00 00       	call   80118c <cprintf>
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
  800885:	68 18 1f 80 00       	push   $0x801f18
  80088a:	e8 fd 08 00 00       	call   80118c <cprintf>
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
  800929:	e8 cf 01 00 00       	call   800afd <open>
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
  80097b:	e8 de 11 00 00       	call   801b5e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800980:	83 c4 0c             	add    $0xc,%esp
  800983:	6a 00                	push   $0x0
  800985:	53                   	push   %ebx
  800986:	6a 00                	push   $0x0
  800988:	e8 7a 11 00 00       	call   801b07 <ipc_recv>
}
  80098d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800990:	5b                   	pop    %ebx
  800991:	5e                   	pop    %esi
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800994:	83 ec 0c             	sub    $0xc,%esp
  800997:	6a 01                	push   $0x1
  800999:	e8 26 12 00 00       	call   801bc4 <ipc_find_env>
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
  800a31:	e8 5f 0d 00 00       	call   801795 <strcpy>
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
	panic("devfile_write not implemented");
  800a63:	68 84 1f 80 00       	push   $0x801f84
  800a68:	68 90 00 00 00       	push   $0x90
  800a6d:	68 a2 1f 80 00       	push   $0x801fa2
  800a72:	e8 2e 06 00 00       	call   8010a5 <_panic>

00800a77 <devfile_read>:
{
  800a77:	f3 0f 1e fb          	endbr32 
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	8b 40 0c             	mov    0xc(%eax),%eax
  800a89:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a8e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a94:	ba 00 00 00 00       	mov    $0x0,%edx
  800a99:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9e:	e8 b8 fe ff ff       	call   80095b <fsipc>
  800aa3:	89 c3                	mov    %eax,%ebx
  800aa5:	85 c0                	test   %eax,%eax
  800aa7:	78 1f                	js     800ac8 <devfile_read+0x51>
	assert(r <= n);
  800aa9:	39 f0                	cmp    %esi,%eax
  800aab:	77 24                	ja     800ad1 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800aad:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ab2:	7f 33                	jg     800ae7 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ab4:	83 ec 04             	sub    $0x4,%esp
  800ab7:	50                   	push   %eax
  800ab8:	68 00 50 80 00       	push   $0x805000
  800abd:	ff 75 0c             	pushl  0xc(%ebp)
  800ac0:	e8 86 0e 00 00       	call   80194b <memmove>
	return r;
  800ac5:	83 c4 10             	add    $0x10,%esp
}
  800ac8:	89 d8                	mov    %ebx,%eax
  800aca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    
	assert(r <= n);
  800ad1:	68 ad 1f 80 00       	push   $0x801fad
  800ad6:	68 b4 1f 80 00       	push   $0x801fb4
  800adb:	6a 7c                	push   $0x7c
  800add:	68 a2 1f 80 00       	push   $0x801fa2
  800ae2:	e8 be 05 00 00       	call   8010a5 <_panic>
	assert(r <= PGSIZE);
  800ae7:	68 c9 1f 80 00       	push   $0x801fc9
  800aec:	68 b4 1f 80 00       	push   $0x801fb4
  800af1:	6a 7d                	push   $0x7d
  800af3:	68 a2 1f 80 00       	push   $0x801fa2
  800af8:	e8 a8 05 00 00       	call   8010a5 <_panic>

00800afd <open>:
{
  800afd:	f3 0f 1e fb          	endbr32 
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
  800b06:	83 ec 1c             	sub    $0x1c,%esp
  800b09:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b0c:	56                   	push   %esi
  800b0d:	e8 40 0c 00 00       	call   801752 <strlen>
  800b12:	83 c4 10             	add    $0x10,%esp
  800b15:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b1a:	7f 6c                	jg     800b88 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800b1c:	83 ec 0c             	sub    $0xc,%esp
  800b1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b22:	50                   	push   %eax
  800b23:	e8 93 f8 ff ff       	call   8003bb <fd_alloc>
  800b28:	89 c3                	mov    %eax,%ebx
  800b2a:	83 c4 10             	add    $0x10,%esp
  800b2d:	85 c0                	test   %eax,%eax
  800b2f:	78 3c                	js     800b6d <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b31:	83 ec 08             	sub    $0x8,%esp
  800b34:	56                   	push   %esi
  800b35:	68 00 50 80 00       	push   $0x805000
  800b3a:	e8 56 0c 00 00       	call   801795 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b42:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b47:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b4a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4f:	e8 07 fe ff ff       	call   80095b <fsipc>
  800b54:	89 c3                	mov    %eax,%ebx
  800b56:	83 c4 10             	add    $0x10,%esp
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	78 19                	js     800b76 <open+0x79>
	return fd2num(fd);
  800b5d:	83 ec 0c             	sub    $0xc,%esp
  800b60:	ff 75 f4             	pushl  -0xc(%ebp)
  800b63:	e8 24 f8 ff ff       	call   80038c <fd2num>
  800b68:	89 c3                	mov    %eax,%ebx
  800b6a:	83 c4 10             	add    $0x10,%esp
}
  800b6d:	89 d8                	mov    %ebx,%eax
  800b6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b72:	5b                   	pop    %ebx
  800b73:	5e                   	pop    %esi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    
		fd_close(fd, 0);
  800b76:	83 ec 08             	sub    $0x8,%esp
  800b79:	6a 00                	push   $0x0
  800b7b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b7e:	e8 3c f9 ff ff       	call   8004bf <fd_close>
		return r;
  800b83:	83 c4 10             	add    $0x10,%esp
  800b86:	eb e5                	jmp    800b6d <open+0x70>
		return -E_BAD_PATH;
  800b88:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b8d:	eb de                	jmp    800b6d <open+0x70>

00800b8f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b8f:	f3 0f 1e fb          	endbr32 
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b99:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9e:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba3:	e8 b3 fd ff ff       	call   80095b <fsipc>
}
  800ba8:	c9                   	leave  
  800ba9:	c3                   	ret    

00800baa <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800baa:	f3 0f 1e fb          	endbr32 
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	56                   	push   %esi
  800bb2:	53                   	push   %ebx
  800bb3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bb6:	83 ec 0c             	sub    $0xc,%esp
  800bb9:	ff 75 08             	pushl  0x8(%ebp)
  800bbc:	e8 df f7 ff ff       	call   8003a0 <fd2data>
  800bc1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bc3:	83 c4 08             	add    $0x8,%esp
  800bc6:	68 d5 1f 80 00       	push   $0x801fd5
  800bcb:	53                   	push   %ebx
  800bcc:	e8 c4 0b 00 00       	call   801795 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bd1:	8b 46 04             	mov    0x4(%esi),%eax
  800bd4:	2b 06                	sub    (%esi),%eax
  800bd6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bdc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800be3:	00 00 00 
	stat->st_dev = &devpipe;
  800be6:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bed:	30 80 00 
	return 0;
}
  800bf0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bfc:	f3 0f 1e fb          	endbr32 
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	53                   	push   %ebx
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c0a:	53                   	push   %ebx
  800c0b:	6a 00                	push   $0x0
  800c0d:	e8 f6 f5 ff ff       	call   800208 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c12:	89 1c 24             	mov    %ebx,(%esp)
  800c15:	e8 86 f7 ff ff       	call   8003a0 <fd2data>
  800c1a:	83 c4 08             	add    $0x8,%esp
  800c1d:	50                   	push   %eax
  800c1e:	6a 00                	push   $0x0
  800c20:	e8 e3 f5 ff ff       	call   800208 <sys_page_unmap>
}
  800c25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c28:	c9                   	leave  
  800c29:	c3                   	ret    

00800c2a <_pipeisclosed>:
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	57                   	push   %edi
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
  800c30:	83 ec 1c             	sub    $0x1c,%esp
  800c33:	89 c7                	mov    %eax,%edi
  800c35:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c37:	a1 04 40 80 00       	mov    0x804004,%eax
  800c3c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c3f:	83 ec 0c             	sub    $0xc,%esp
  800c42:	57                   	push   %edi
  800c43:	e8 b9 0f 00 00       	call   801c01 <pageref>
  800c48:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c4b:	89 34 24             	mov    %esi,(%esp)
  800c4e:	e8 ae 0f 00 00       	call   801c01 <pageref>
		nn = thisenv->env_runs;
  800c53:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c59:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c5c:	83 c4 10             	add    $0x10,%esp
  800c5f:	39 cb                	cmp    %ecx,%ebx
  800c61:	74 1b                	je     800c7e <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c63:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c66:	75 cf                	jne    800c37 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c68:	8b 42 58             	mov    0x58(%edx),%eax
  800c6b:	6a 01                	push   $0x1
  800c6d:	50                   	push   %eax
  800c6e:	53                   	push   %ebx
  800c6f:	68 dc 1f 80 00       	push   $0x801fdc
  800c74:	e8 13 05 00 00       	call   80118c <cprintf>
  800c79:	83 c4 10             	add    $0x10,%esp
  800c7c:	eb b9                	jmp    800c37 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c7e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c81:	0f 94 c0             	sete   %al
  800c84:	0f b6 c0             	movzbl %al,%eax
}
  800c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <devpipe_write>:
{
  800c8f:	f3 0f 1e fb          	endbr32 
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 28             	sub    $0x28,%esp
  800c9c:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c9f:	56                   	push   %esi
  800ca0:	e8 fb f6 ff ff       	call   8003a0 <fd2data>
  800ca5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800ca7:	83 c4 10             	add    $0x10,%esp
  800caa:	bf 00 00 00 00       	mov    $0x0,%edi
  800caf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cb2:	74 4f                	je     800d03 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cb4:	8b 43 04             	mov    0x4(%ebx),%eax
  800cb7:	8b 0b                	mov    (%ebx),%ecx
  800cb9:	8d 51 20             	lea    0x20(%ecx),%edx
  800cbc:	39 d0                	cmp    %edx,%eax
  800cbe:	72 14                	jb     800cd4 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800cc0:	89 da                	mov    %ebx,%edx
  800cc2:	89 f0                	mov    %esi,%eax
  800cc4:	e8 61 ff ff ff       	call   800c2a <_pipeisclosed>
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	75 3b                	jne    800d08 <devpipe_write+0x79>
			sys_yield();
  800ccd:	e8 86 f4 ff ff       	call   800158 <sys_yield>
  800cd2:	eb e0                	jmp    800cb4 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cdb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cde:	89 c2                	mov    %eax,%edx
  800ce0:	c1 fa 1f             	sar    $0x1f,%edx
  800ce3:	89 d1                	mov    %edx,%ecx
  800ce5:	c1 e9 1b             	shr    $0x1b,%ecx
  800ce8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ceb:	83 e2 1f             	and    $0x1f,%edx
  800cee:	29 ca                	sub    %ecx,%edx
  800cf0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cf4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cf8:	83 c0 01             	add    $0x1,%eax
  800cfb:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cfe:	83 c7 01             	add    $0x1,%edi
  800d01:	eb ac                	jmp    800caf <devpipe_write+0x20>
	return i;
  800d03:	8b 45 10             	mov    0x10(%ebp),%eax
  800d06:	eb 05                	jmp    800d0d <devpipe_write+0x7e>
				return 0;
  800d08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <devpipe_read>:
{
  800d15:	f3 0f 1e fb          	endbr32 
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	83 ec 18             	sub    $0x18,%esp
  800d22:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800d25:	57                   	push   %edi
  800d26:	e8 75 f6 ff ff       	call   8003a0 <fd2data>
  800d2b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d2d:	83 c4 10             	add    $0x10,%esp
  800d30:	be 00 00 00 00       	mov    $0x0,%esi
  800d35:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d38:	75 14                	jne    800d4e <devpipe_read+0x39>
	return i;
  800d3a:	8b 45 10             	mov    0x10(%ebp),%eax
  800d3d:	eb 02                	jmp    800d41 <devpipe_read+0x2c>
				return i;
  800d3f:	89 f0                	mov    %esi,%eax
}
  800d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    
			sys_yield();
  800d49:	e8 0a f4 ff ff       	call   800158 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d4e:	8b 03                	mov    (%ebx),%eax
  800d50:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d53:	75 18                	jne    800d6d <devpipe_read+0x58>
			if (i > 0)
  800d55:	85 f6                	test   %esi,%esi
  800d57:	75 e6                	jne    800d3f <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d59:	89 da                	mov    %ebx,%edx
  800d5b:	89 f8                	mov    %edi,%eax
  800d5d:	e8 c8 fe ff ff       	call   800c2a <_pipeisclosed>
  800d62:	85 c0                	test   %eax,%eax
  800d64:	74 e3                	je     800d49 <devpipe_read+0x34>
				return 0;
  800d66:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6b:	eb d4                	jmp    800d41 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d6d:	99                   	cltd   
  800d6e:	c1 ea 1b             	shr    $0x1b,%edx
  800d71:	01 d0                	add    %edx,%eax
  800d73:	83 e0 1f             	and    $0x1f,%eax
  800d76:	29 d0                	sub    %edx,%eax
  800d78:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d80:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d83:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d86:	83 c6 01             	add    $0x1,%esi
  800d89:	eb aa                	jmp    800d35 <devpipe_read+0x20>

00800d8b <pipe>:
{
  800d8b:	f3 0f 1e fb          	endbr32 
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d9a:	50                   	push   %eax
  800d9b:	e8 1b f6 ff ff       	call   8003bb <fd_alloc>
  800da0:	89 c3                	mov    %eax,%ebx
  800da2:	83 c4 10             	add    $0x10,%esp
  800da5:	85 c0                	test   %eax,%eax
  800da7:	0f 88 23 01 00 00    	js     800ed0 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dad:	83 ec 04             	sub    $0x4,%esp
  800db0:	68 07 04 00 00       	push   $0x407
  800db5:	ff 75 f4             	pushl  -0xc(%ebp)
  800db8:	6a 00                	push   $0x0
  800dba:	e8 bc f3 ff ff       	call   80017b <sys_page_alloc>
  800dbf:	89 c3                	mov    %eax,%ebx
  800dc1:	83 c4 10             	add    $0x10,%esp
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	0f 88 04 01 00 00    	js     800ed0 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800dcc:	83 ec 0c             	sub    $0xc,%esp
  800dcf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dd2:	50                   	push   %eax
  800dd3:	e8 e3 f5 ff ff       	call   8003bb <fd_alloc>
  800dd8:	89 c3                	mov    %eax,%ebx
  800dda:	83 c4 10             	add    $0x10,%esp
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	0f 88 db 00 00 00    	js     800ec0 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de5:	83 ec 04             	sub    $0x4,%esp
  800de8:	68 07 04 00 00       	push   $0x407
  800ded:	ff 75 f0             	pushl  -0x10(%ebp)
  800df0:	6a 00                	push   $0x0
  800df2:	e8 84 f3 ff ff       	call   80017b <sys_page_alloc>
  800df7:	89 c3                	mov    %eax,%ebx
  800df9:	83 c4 10             	add    $0x10,%esp
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	0f 88 bc 00 00 00    	js     800ec0 <pipe+0x135>
	va = fd2data(fd0);
  800e04:	83 ec 0c             	sub    $0xc,%esp
  800e07:	ff 75 f4             	pushl  -0xc(%ebp)
  800e0a:	e8 91 f5 ff ff       	call   8003a0 <fd2data>
  800e0f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e11:	83 c4 0c             	add    $0xc,%esp
  800e14:	68 07 04 00 00       	push   $0x407
  800e19:	50                   	push   %eax
  800e1a:	6a 00                	push   $0x0
  800e1c:	e8 5a f3 ff ff       	call   80017b <sys_page_alloc>
  800e21:	89 c3                	mov    %eax,%ebx
  800e23:	83 c4 10             	add    $0x10,%esp
  800e26:	85 c0                	test   %eax,%eax
  800e28:	0f 88 82 00 00 00    	js     800eb0 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e2e:	83 ec 0c             	sub    $0xc,%esp
  800e31:	ff 75 f0             	pushl  -0x10(%ebp)
  800e34:	e8 67 f5 ff ff       	call   8003a0 <fd2data>
  800e39:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e40:	50                   	push   %eax
  800e41:	6a 00                	push   $0x0
  800e43:	56                   	push   %esi
  800e44:	6a 00                	push   $0x0
  800e46:	e8 77 f3 ff ff       	call   8001c2 <sys_page_map>
  800e4b:	89 c3                	mov    %eax,%ebx
  800e4d:	83 c4 20             	add    $0x20,%esp
  800e50:	85 c0                	test   %eax,%eax
  800e52:	78 4e                	js     800ea2 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e54:	a1 20 30 80 00       	mov    0x803020,%eax
  800e59:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e5c:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e61:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e68:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e6b:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e70:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e77:	83 ec 0c             	sub    $0xc,%esp
  800e7a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e7d:	e8 0a f5 ff ff       	call   80038c <fd2num>
  800e82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e85:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e87:	83 c4 04             	add    $0x4,%esp
  800e8a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e8d:	e8 fa f4 ff ff       	call   80038c <fd2num>
  800e92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e95:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e98:	83 c4 10             	add    $0x10,%esp
  800e9b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea0:	eb 2e                	jmp    800ed0 <pipe+0x145>
	sys_page_unmap(0, va);
  800ea2:	83 ec 08             	sub    $0x8,%esp
  800ea5:	56                   	push   %esi
  800ea6:	6a 00                	push   $0x0
  800ea8:	e8 5b f3 ff ff       	call   800208 <sys_page_unmap>
  800ead:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800eb0:	83 ec 08             	sub    $0x8,%esp
  800eb3:	ff 75 f0             	pushl  -0x10(%ebp)
  800eb6:	6a 00                	push   $0x0
  800eb8:	e8 4b f3 ff ff       	call   800208 <sys_page_unmap>
  800ebd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800ec0:	83 ec 08             	sub    $0x8,%esp
  800ec3:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec6:	6a 00                	push   $0x0
  800ec8:	e8 3b f3 ff ff       	call   800208 <sys_page_unmap>
  800ecd:	83 c4 10             	add    $0x10,%esp
}
  800ed0:	89 d8                	mov    %ebx,%eax
  800ed2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed5:	5b                   	pop    %ebx
  800ed6:	5e                   	pop    %esi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    

00800ed9 <pipeisclosed>:
{
  800ed9:	f3 0f 1e fb          	endbr32 
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ee3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ee6:	50                   	push   %eax
  800ee7:	ff 75 08             	pushl  0x8(%ebp)
  800eea:	e8 22 f5 ff ff       	call   800411 <fd_lookup>
  800eef:	83 c4 10             	add    $0x10,%esp
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	78 18                	js     800f0e <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800ef6:	83 ec 0c             	sub    $0xc,%esp
  800ef9:	ff 75 f4             	pushl  -0xc(%ebp)
  800efc:	e8 9f f4 ff ff       	call   8003a0 <fd2data>
  800f01:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f06:	e8 1f fd ff ff       	call   800c2a <_pipeisclosed>
  800f0b:	83 c4 10             	add    $0x10,%esp
}
  800f0e:	c9                   	leave  
  800f0f:	c3                   	ret    

00800f10 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f10:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800f14:	b8 00 00 00 00       	mov    $0x0,%eax
  800f19:	c3                   	ret    

00800f1a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f1a:	f3 0f 1e fb          	endbr32 
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f24:	68 f4 1f 80 00       	push   $0x801ff4
  800f29:	ff 75 0c             	pushl  0xc(%ebp)
  800f2c:	e8 64 08 00 00       	call   801795 <strcpy>
	return 0;
}
  800f31:	b8 00 00 00 00       	mov    $0x0,%eax
  800f36:	c9                   	leave  
  800f37:	c3                   	ret    

00800f38 <devcons_write>:
{
  800f38:	f3 0f 1e fb          	endbr32 
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	57                   	push   %edi
  800f40:	56                   	push   %esi
  800f41:	53                   	push   %ebx
  800f42:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f48:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f4d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f53:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f56:	73 31                	jae    800f89 <devcons_write+0x51>
		m = n - tot;
  800f58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f5b:	29 f3                	sub    %esi,%ebx
  800f5d:	83 fb 7f             	cmp    $0x7f,%ebx
  800f60:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f65:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f68:	83 ec 04             	sub    $0x4,%esp
  800f6b:	53                   	push   %ebx
  800f6c:	89 f0                	mov    %esi,%eax
  800f6e:	03 45 0c             	add    0xc(%ebp),%eax
  800f71:	50                   	push   %eax
  800f72:	57                   	push   %edi
  800f73:	e8 d3 09 00 00       	call   80194b <memmove>
		sys_cputs(buf, m);
  800f78:	83 c4 08             	add    $0x8,%esp
  800f7b:	53                   	push   %ebx
  800f7c:	57                   	push   %edi
  800f7d:	e8 29 f1 ff ff       	call   8000ab <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f82:	01 de                	add    %ebx,%esi
  800f84:	83 c4 10             	add    $0x10,%esp
  800f87:	eb ca                	jmp    800f53 <devcons_write+0x1b>
}
  800f89:	89 f0                	mov    %esi,%eax
  800f8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5f                   	pop    %edi
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <devcons_read>:
{
  800f93:	f3 0f 1e fb          	endbr32 
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	83 ec 08             	sub    $0x8,%esp
  800f9d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800fa2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fa6:	74 21                	je     800fc9 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800fa8:	e8 20 f1 ff ff       	call   8000cd <sys_cgetc>
  800fad:	85 c0                	test   %eax,%eax
  800faf:	75 07                	jne    800fb8 <devcons_read+0x25>
		sys_yield();
  800fb1:	e8 a2 f1 ff ff       	call   800158 <sys_yield>
  800fb6:	eb f0                	jmp    800fa8 <devcons_read+0x15>
	if (c < 0)
  800fb8:	78 0f                	js     800fc9 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800fba:	83 f8 04             	cmp    $0x4,%eax
  800fbd:	74 0c                	je     800fcb <devcons_read+0x38>
	*(char*)vbuf = c;
  800fbf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc2:	88 02                	mov    %al,(%edx)
	return 1;
  800fc4:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800fc9:	c9                   	leave  
  800fca:	c3                   	ret    
		return 0;
  800fcb:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd0:	eb f7                	jmp    800fc9 <devcons_read+0x36>

00800fd2 <cputchar>:
{
  800fd2:	f3 0f 1e fb          	endbr32 
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdf:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800fe2:	6a 01                	push   $0x1
  800fe4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fe7:	50                   	push   %eax
  800fe8:	e8 be f0 ff ff       	call   8000ab <sys_cputs>
}
  800fed:	83 c4 10             	add    $0x10,%esp
  800ff0:	c9                   	leave  
  800ff1:	c3                   	ret    

00800ff2 <getchar>:
{
  800ff2:	f3 0f 1e fb          	endbr32 
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800ffc:	6a 01                	push   $0x1
  800ffe:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801001:	50                   	push   %eax
  801002:	6a 00                	push   $0x0
  801004:	e8 8b f6 ff ff       	call   800694 <read>
	if (r < 0)
  801009:	83 c4 10             	add    $0x10,%esp
  80100c:	85 c0                	test   %eax,%eax
  80100e:	78 06                	js     801016 <getchar+0x24>
	if (r < 1)
  801010:	74 06                	je     801018 <getchar+0x26>
	return c;
  801012:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801016:	c9                   	leave  
  801017:	c3                   	ret    
		return -E_EOF;
  801018:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80101d:	eb f7                	jmp    801016 <getchar+0x24>

0080101f <iscons>:
{
  80101f:	f3 0f 1e fb          	endbr32 
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801029:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102c:	50                   	push   %eax
  80102d:	ff 75 08             	pushl  0x8(%ebp)
  801030:	e8 dc f3 ff ff       	call   800411 <fd_lookup>
  801035:	83 c4 10             	add    $0x10,%esp
  801038:	85 c0                	test   %eax,%eax
  80103a:	78 11                	js     80104d <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80103c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801045:	39 10                	cmp    %edx,(%eax)
  801047:	0f 94 c0             	sete   %al
  80104a:	0f b6 c0             	movzbl %al,%eax
}
  80104d:	c9                   	leave  
  80104e:	c3                   	ret    

0080104f <opencons>:
{
  80104f:	f3 0f 1e fb          	endbr32 
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801059:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80105c:	50                   	push   %eax
  80105d:	e8 59 f3 ff ff       	call   8003bb <fd_alloc>
  801062:	83 c4 10             	add    $0x10,%esp
  801065:	85 c0                	test   %eax,%eax
  801067:	78 3a                	js     8010a3 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801069:	83 ec 04             	sub    $0x4,%esp
  80106c:	68 07 04 00 00       	push   $0x407
  801071:	ff 75 f4             	pushl  -0xc(%ebp)
  801074:	6a 00                	push   $0x0
  801076:	e8 00 f1 ff ff       	call   80017b <sys_page_alloc>
  80107b:	83 c4 10             	add    $0x10,%esp
  80107e:	85 c0                	test   %eax,%eax
  801080:	78 21                	js     8010a3 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801082:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801085:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80108b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80108d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801090:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801097:	83 ec 0c             	sub    $0xc,%esp
  80109a:	50                   	push   %eax
  80109b:	e8 ec f2 ff ff       	call   80038c <fd2num>
  8010a0:	83 c4 10             	add    $0x10,%esp
}
  8010a3:	c9                   	leave  
  8010a4:	c3                   	ret    

008010a5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010a5:	f3 0f 1e fb          	endbr32 
  8010a9:	55                   	push   %ebp
  8010aa:	89 e5                	mov    %esp,%ebp
  8010ac:	56                   	push   %esi
  8010ad:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010ae:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010b1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010b7:	e8 79 f0 ff ff       	call   800135 <sys_getenvid>
  8010bc:	83 ec 0c             	sub    $0xc,%esp
  8010bf:	ff 75 0c             	pushl  0xc(%ebp)
  8010c2:	ff 75 08             	pushl  0x8(%ebp)
  8010c5:	56                   	push   %esi
  8010c6:	50                   	push   %eax
  8010c7:	68 00 20 80 00       	push   $0x802000
  8010cc:	e8 bb 00 00 00       	call   80118c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010d1:	83 c4 18             	add    $0x18,%esp
  8010d4:	53                   	push   %ebx
  8010d5:	ff 75 10             	pushl  0x10(%ebp)
  8010d8:	e8 5a 00 00 00       	call   801137 <vcprintf>
	cprintf("\n");
  8010dd:	c7 04 24 ed 1f 80 00 	movl   $0x801fed,(%esp)
  8010e4:	e8 a3 00 00 00       	call   80118c <cprintf>
  8010e9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010ec:	cc                   	int3   
  8010ed:	eb fd                	jmp    8010ec <_panic+0x47>

008010ef <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010ef:	f3 0f 1e fb          	endbr32 
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	53                   	push   %ebx
  8010f7:	83 ec 04             	sub    $0x4,%esp
  8010fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010fd:	8b 13                	mov    (%ebx),%edx
  8010ff:	8d 42 01             	lea    0x1(%edx),%eax
  801102:	89 03                	mov    %eax,(%ebx)
  801104:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801107:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80110b:	3d ff 00 00 00       	cmp    $0xff,%eax
  801110:	74 09                	je     80111b <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801112:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801116:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801119:	c9                   	leave  
  80111a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80111b:	83 ec 08             	sub    $0x8,%esp
  80111e:	68 ff 00 00 00       	push   $0xff
  801123:	8d 43 08             	lea    0x8(%ebx),%eax
  801126:	50                   	push   %eax
  801127:	e8 7f ef ff ff       	call   8000ab <sys_cputs>
		b->idx = 0;
  80112c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801132:	83 c4 10             	add    $0x10,%esp
  801135:	eb db                	jmp    801112 <putch+0x23>

00801137 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801137:	f3 0f 1e fb          	endbr32 
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801144:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80114b:	00 00 00 
	b.cnt = 0;
  80114e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801155:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801158:	ff 75 0c             	pushl  0xc(%ebp)
  80115b:	ff 75 08             	pushl  0x8(%ebp)
  80115e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801164:	50                   	push   %eax
  801165:	68 ef 10 80 00       	push   $0x8010ef
  80116a:	e8 20 01 00 00       	call   80128f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80116f:	83 c4 08             	add    $0x8,%esp
  801172:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801178:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80117e:	50                   	push   %eax
  80117f:	e8 27 ef ff ff       	call   8000ab <sys_cputs>

	return b.cnt;
}
  801184:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80118a:	c9                   	leave  
  80118b:	c3                   	ret    

0080118c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80118c:	f3 0f 1e fb          	endbr32 
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801196:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801199:	50                   	push   %eax
  80119a:	ff 75 08             	pushl  0x8(%ebp)
  80119d:	e8 95 ff ff ff       	call   801137 <vcprintf>
	va_end(ap);

	return cnt;
}
  8011a2:	c9                   	leave  
  8011a3:	c3                   	ret    

008011a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	57                   	push   %edi
  8011a8:	56                   	push   %esi
  8011a9:	53                   	push   %ebx
  8011aa:	83 ec 1c             	sub    $0x1c,%esp
  8011ad:	89 c7                	mov    %eax,%edi
  8011af:	89 d6                	mov    %edx,%esi
  8011b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b7:	89 d1                	mov    %edx,%ecx
  8011b9:	89 c2                	mov    %eax,%edx
  8011bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011be:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8011c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8011c4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8011d1:	39 c2                	cmp    %eax,%edx
  8011d3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8011d6:	72 3e                	jb     801216 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011d8:	83 ec 0c             	sub    $0xc,%esp
  8011db:	ff 75 18             	pushl  0x18(%ebp)
  8011de:	83 eb 01             	sub    $0x1,%ebx
  8011e1:	53                   	push   %ebx
  8011e2:	50                   	push   %eax
  8011e3:	83 ec 08             	sub    $0x8,%esp
  8011e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ec:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ef:	ff 75 d8             	pushl  -0x28(%ebp)
  8011f2:	e8 59 0a 00 00       	call   801c50 <__udivdi3>
  8011f7:	83 c4 18             	add    $0x18,%esp
  8011fa:	52                   	push   %edx
  8011fb:	50                   	push   %eax
  8011fc:	89 f2                	mov    %esi,%edx
  8011fe:	89 f8                	mov    %edi,%eax
  801200:	e8 9f ff ff ff       	call   8011a4 <printnum>
  801205:	83 c4 20             	add    $0x20,%esp
  801208:	eb 13                	jmp    80121d <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80120a:	83 ec 08             	sub    $0x8,%esp
  80120d:	56                   	push   %esi
  80120e:	ff 75 18             	pushl  0x18(%ebp)
  801211:	ff d7                	call   *%edi
  801213:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801216:	83 eb 01             	sub    $0x1,%ebx
  801219:	85 db                	test   %ebx,%ebx
  80121b:	7f ed                	jg     80120a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80121d:	83 ec 08             	sub    $0x8,%esp
  801220:	56                   	push   %esi
  801221:	83 ec 04             	sub    $0x4,%esp
  801224:	ff 75 e4             	pushl  -0x1c(%ebp)
  801227:	ff 75 e0             	pushl  -0x20(%ebp)
  80122a:	ff 75 dc             	pushl  -0x24(%ebp)
  80122d:	ff 75 d8             	pushl  -0x28(%ebp)
  801230:	e8 2b 0b 00 00       	call   801d60 <__umoddi3>
  801235:	83 c4 14             	add    $0x14,%esp
  801238:	0f be 80 23 20 80 00 	movsbl 0x802023(%eax),%eax
  80123f:	50                   	push   %eax
  801240:	ff d7                	call   *%edi
}
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801248:	5b                   	pop    %ebx
  801249:	5e                   	pop    %esi
  80124a:	5f                   	pop    %edi
  80124b:	5d                   	pop    %ebp
  80124c:	c3                   	ret    

0080124d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80124d:	f3 0f 1e fb          	endbr32 
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801257:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80125b:	8b 10                	mov    (%eax),%edx
  80125d:	3b 50 04             	cmp    0x4(%eax),%edx
  801260:	73 0a                	jae    80126c <sprintputch+0x1f>
		*b->buf++ = ch;
  801262:	8d 4a 01             	lea    0x1(%edx),%ecx
  801265:	89 08                	mov    %ecx,(%eax)
  801267:	8b 45 08             	mov    0x8(%ebp),%eax
  80126a:	88 02                	mov    %al,(%edx)
}
  80126c:	5d                   	pop    %ebp
  80126d:	c3                   	ret    

0080126e <printfmt>:
{
  80126e:	f3 0f 1e fb          	endbr32 
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801278:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80127b:	50                   	push   %eax
  80127c:	ff 75 10             	pushl  0x10(%ebp)
  80127f:	ff 75 0c             	pushl  0xc(%ebp)
  801282:	ff 75 08             	pushl  0x8(%ebp)
  801285:	e8 05 00 00 00       	call   80128f <vprintfmt>
}
  80128a:	83 c4 10             	add    $0x10,%esp
  80128d:	c9                   	leave  
  80128e:	c3                   	ret    

0080128f <vprintfmt>:
{
  80128f:	f3 0f 1e fb          	endbr32 
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	57                   	push   %edi
  801297:	56                   	push   %esi
  801298:	53                   	push   %ebx
  801299:	83 ec 3c             	sub    $0x3c,%esp
  80129c:	8b 75 08             	mov    0x8(%ebp),%esi
  80129f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012a2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012a5:	e9 4a 03 00 00       	jmp    8015f4 <vprintfmt+0x365>
		padc = ' ';
  8012aa:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012ae:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012b5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012bc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012c3:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012c8:	8d 47 01             	lea    0x1(%edi),%eax
  8012cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012ce:	0f b6 17             	movzbl (%edi),%edx
  8012d1:	8d 42 dd             	lea    -0x23(%edx),%eax
  8012d4:	3c 55                	cmp    $0x55,%al
  8012d6:	0f 87 de 03 00 00    	ja     8016ba <vprintfmt+0x42b>
  8012dc:	0f b6 c0             	movzbl %al,%eax
  8012df:	3e ff 24 85 60 21 80 	notrack jmp *0x802160(,%eax,4)
  8012e6:	00 
  8012e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8012ea:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8012ee:	eb d8                	jmp    8012c8 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8012f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012f3:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8012f7:	eb cf                	jmp    8012c8 <vprintfmt+0x39>
  8012f9:	0f b6 d2             	movzbl %dl,%edx
  8012fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8012ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801304:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801307:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80130a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80130e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801311:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801314:	83 f9 09             	cmp    $0x9,%ecx
  801317:	77 55                	ja     80136e <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  801319:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80131c:	eb e9                	jmp    801307 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80131e:	8b 45 14             	mov    0x14(%ebp),%eax
  801321:	8b 00                	mov    (%eax),%eax
  801323:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801326:	8b 45 14             	mov    0x14(%ebp),%eax
  801329:	8d 40 04             	lea    0x4(%eax),%eax
  80132c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80132f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801332:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801336:	79 90                	jns    8012c8 <vprintfmt+0x39>
				width = precision, precision = -1;
  801338:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80133b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80133e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801345:	eb 81                	jmp    8012c8 <vprintfmt+0x39>
  801347:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80134a:	85 c0                	test   %eax,%eax
  80134c:	ba 00 00 00 00       	mov    $0x0,%edx
  801351:	0f 49 d0             	cmovns %eax,%edx
  801354:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801357:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80135a:	e9 69 ff ff ff       	jmp    8012c8 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80135f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801362:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801369:	e9 5a ff ff ff       	jmp    8012c8 <vprintfmt+0x39>
  80136e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801371:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801374:	eb bc                	jmp    801332 <vprintfmt+0xa3>
			lflag++;
  801376:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80137c:	e9 47 ff ff ff       	jmp    8012c8 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  801381:	8b 45 14             	mov    0x14(%ebp),%eax
  801384:	8d 78 04             	lea    0x4(%eax),%edi
  801387:	83 ec 08             	sub    $0x8,%esp
  80138a:	53                   	push   %ebx
  80138b:	ff 30                	pushl  (%eax)
  80138d:	ff d6                	call   *%esi
			break;
  80138f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801392:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801395:	e9 57 02 00 00       	jmp    8015f1 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80139a:	8b 45 14             	mov    0x14(%ebp),%eax
  80139d:	8d 78 04             	lea    0x4(%eax),%edi
  8013a0:	8b 00                	mov    (%eax),%eax
  8013a2:	99                   	cltd   
  8013a3:	31 d0                	xor    %edx,%eax
  8013a5:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013a7:	83 f8 0f             	cmp    $0xf,%eax
  8013aa:	7f 23                	jg     8013cf <vprintfmt+0x140>
  8013ac:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  8013b3:	85 d2                	test   %edx,%edx
  8013b5:	74 18                	je     8013cf <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8013b7:	52                   	push   %edx
  8013b8:	68 c6 1f 80 00       	push   $0x801fc6
  8013bd:	53                   	push   %ebx
  8013be:	56                   	push   %esi
  8013bf:	e8 aa fe ff ff       	call   80126e <printfmt>
  8013c4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8013c7:	89 7d 14             	mov    %edi,0x14(%ebp)
  8013ca:	e9 22 02 00 00       	jmp    8015f1 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8013cf:	50                   	push   %eax
  8013d0:	68 3b 20 80 00       	push   $0x80203b
  8013d5:	53                   	push   %ebx
  8013d6:	56                   	push   %esi
  8013d7:	e8 92 fe ff ff       	call   80126e <printfmt>
  8013dc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8013df:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8013e2:	e9 0a 02 00 00       	jmp    8015f1 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8013e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ea:	83 c0 04             	add    $0x4,%eax
  8013ed:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8013f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8013f3:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8013f5:	85 d2                	test   %edx,%edx
  8013f7:	b8 34 20 80 00       	mov    $0x802034,%eax
  8013fc:	0f 45 c2             	cmovne %edx,%eax
  8013ff:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801402:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801406:	7e 06                	jle    80140e <vprintfmt+0x17f>
  801408:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80140c:	75 0d                	jne    80141b <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80140e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801411:	89 c7                	mov    %eax,%edi
  801413:	03 45 e0             	add    -0x20(%ebp),%eax
  801416:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801419:	eb 55                	jmp    801470 <vprintfmt+0x1e1>
  80141b:	83 ec 08             	sub    $0x8,%esp
  80141e:	ff 75 d8             	pushl  -0x28(%ebp)
  801421:	ff 75 cc             	pushl  -0x34(%ebp)
  801424:	e8 45 03 00 00       	call   80176e <strnlen>
  801429:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80142c:	29 c2                	sub    %eax,%edx
  80142e:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  801436:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80143a:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80143d:	85 ff                	test   %edi,%edi
  80143f:	7e 11                	jle    801452 <vprintfmt+0x1c3>
					putch(padc, putdat);
  801441:	83 ec 08             	sub    $0x8,%esp
  801444:	53                   	push   %ebx
  801445:	ff 75 e0             	pushl  -0x20(%ebp)
  801448:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80144a:	83 ef 01             	sub    $0x1,%edi
  80144d:	83 c4 10             	add    $0x10,%esp
  801450:	eb eb                	jmp    80143d <vprintfmt+0x1ae>
  801452:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801455:	85 d2                	test   %edx,%edx
  801457:	b8 00 00 00 00       	mov    $0x0,%eax
  80145c:	0f 49 c2             	cmovns %edx,%eax
  80145f:	29 c2                	sub    %eax,%edx
  801461:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801464:	eb a8                	jmp    80140e <vprintfmt+0x17f>
					putch(ch, putdat);
  801466:	83 ec 08             	sub    $0x8,%esp
  801469:	53                   	push   %ebx
  80146a:	52                   	push   %edx
  80146b:	ff d6                	call   *%esi
  80146d:	83 c4 10             	add    $0x10,%esp
  801470:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801473:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801475:	83 c7 01             	add    $0x1,%edi
  801478:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80147c:	0f be d0             	movsbl %al,%edx
  80147f:	85 d2                	test   %edx,%edx
  801481:	74 4b                	je     8014ce <vprintfmt+0x23f>
  801483:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801487:	78 06                	js     80148f <vprintfmt+0x200>
  801489:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80148d:	78 1e                	js     8014ad <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80148f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801493:	74 d1                	je     801466 <vprintfmt+0x1d7>
  801495:	0f be c0             	movsbl %al,%eax
  801498:	83 e8 20             	sub    $0x20,%eax
  80149b:	83 f8 5e             	cmp    $0x5e,%eax
  80149e:	76 c6                	jbe    801466 <vprintfmt+0x1d7>
					putch('?', putdat);
  8014a0:	83 ec 08             	sub    $0x8,%esp
  8014a3:	53                   	push   %ebx
  8014a4:	6a 3f                	push   $0x3f
  8014a6:	ff d6                	call   *%esi
  8014a8:	83 c4 10             	add    $0x10,%esp
  8014ab:	eb c3                	jmp    801470 <vprintfmt+0x1e1>
  8014ad:	89 cf                	mov    %ecx,%edi
  8014af:	eb 0e                	jmp    8014bf <vprintfmt+0x230>
				putch(' ', putdat);
  8014b1:	83 ec 08             	sub    $0x8,%esp
  8014b4:	53                   	push   %ebx
  8014b5:	6a 20                	push   $0x20
  8014b7:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8014b9:	83 ef 01             	sub    $0x1,%edi
  8014bc:	83 c4 10             	add    $0x10,%esp
  8014bf:	85 ff                	test   %edi,%edi
  8014c1:	7f ee                	jg     8014b1 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8014c3:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8014c6:	89 45 14             	mov    %eax,0x14(%ebp)
  8014c9:	e9 23 01 00 00       	jmp    8015f1 <vprintfmt+0x362>
  8014ce:	89 cf                	mov    %ecx,%edi
  8014d0:	eb ed                	jmp    8014bf <vprintfmt+0x230>
	if (lflag >= 2)
  8014d2:	83 f9 01             	cmp    $0x1,%ecx
  8014d5:	7f 1b                	jg     8014f2 <vprintfmt+0x263>
	else if (lflag)
  8014d7:	85 c9                	test   %ecx,%ecx
  8014d9:	74 63                	je     80153e <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8014db:	8b 45 14             	mov    0x14(%ebp),%eax
  8014de:	8b 00                	mov    (%eax),%eax
  8014e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014e3:	99                   	cltd   
  8014e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ea:	8d 40 04             	lea    0x4(%eax),%eax
  8014ed:	89 45 14             	mov    %eax,0x14(%ebp)
  8014f0:	eb 17                	jmp    801509 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8014f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f5:	8b 50 04             	mov    0x4(%eax),%edx
  8014f8:	8b 00                	mov    (%eax),%eax
  8014fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014fd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801500:	8b 45 14             	mov    0x14(%ebp),%eax
  801503:	8d 40 08             	lea    0x8(%eax),%eax
  801506:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801509:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80150c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80150f:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  801514:	85 c9                	test   %ecx,%ecx
  801516:	0f 89 bb 00 00 00    	jns    8015d7 <vprintfmt+0x348>
				putch('-', putdat);
  80151c:	83 ec 08             	sub    $0x8,%esp
  80151f:	53                   	push   %ebx
  801520:	6a 2d                	push   $0x2d
  801522:	ff d6                	call   *%esi
				num = -(long long) num;
  801524:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801527:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80152a:	f7 da                	neg    %edx
  80152c:	83 d1 00             	adc    $0x0,%ecx
  80152f:	f7 d9                	neg    %ecx
  801531:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801534:	b8 0a 00 00 00       	mov    $0xa,%eax
  801539:	e9 99 00 00 00       	jmp    8015d7 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80153e:	8b 45 14             	mov    0x14(%ebp),%eax
  801541:	8b 00                	mov    (%eax),%eax
  801543:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801546:	99                   	cltd   
  801547:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80154a:	8b 45 14             	mov    0x14(%ebp),%eax
  80154d:	8d 40 04             	lea    0x4(%eax),%eax
  801550:	89 45 14             	mov    %eax,0x14(%ebp)
  801553:	eb b4                	jmp    801509 <vprintfmt+0x27a>
	if (lflag >= 2)
  801555:	83 f9 01             	cmp    $0x1,%ecx
  801558:	7f 1b                	jg     801575 <vprintfmt+0x2e6>
	else if (lflag)
  80155a:	85 c9                	test   %ecx,%ecx
  80155c:	74 2c                	je     80158a <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80155e:	8b 45 14             	mov    0x14(%ebp),%eax
  801561:	8b 10                	mov    (%eax),%edx
  801563:	b9 00 00 00 00       	mov    $0x0,%ecx
  801568:	8d 40 04             	lea    0x4(%eax),%eax
  80156b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80156e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  801573:	eb 62                	jmp    8015d7 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  801575:	8b 45 14             	mov    0x14(%ebp),%eax
  801578:	8b 10                	mov    (%eax),%edx
  80157a:	8b 48 04             	mov    0x4(%eax),%ecx
  80157d:	8d 40 08             	lea    0x8(%eax),%eax
  801580:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801583:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  801588:	eb 4d                	jmp    8015d7 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80158a:	8b 45 14             	mov    0x14(%ebp),%eax
  80158d:	8b 10                	mov    (%eax),%edx
  80158f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801594:	8d 40 04             	lea    0x4(%eax),%eax
  801597:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80159a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80159f:	eb 36                	jmp    8015d7 <vprintfmt+0x348>
	if (lflag >= 2)
  8015a1:	83 f9 01             	cmp    $0x1,%ecx
  8015a4:	7f 17                	jg     8015bd <vprintfmt+0x32e>
	else if (lflag)
  8015a6:	85 c9                	test   %ecx,%ecx
  8015a8:	74 6e                	je     801618 <vprintfmt+0x389>
		return va_arg(*ap, long);
  8015aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ad:	8b 10                	mov    (%eax),%edx
  8015af:	89 d0                	mov    %edx,%eax
  8015b1:	99                   	cltd   
  8015b2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015b5:	8d 49 04             	lea    0x4(%ecx),%ecx
  8015b8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8015bb:	eb 11                	jmp    8015ce <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8015bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c0:	8b 50 04             	mov    0x4(%eax),%edx
  8015c3:	8b 00                	mov    (%eax),%eax
  8015c5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015c8:	8d 49 08             	lea    0x8(%ecx),%ecx
  8015cb:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8015ce:	89 d1                	mov    %edx,%ecx
  8015d0:	89 c2                	mov    %eax,%edx
            base = 8;
  8015d2:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8015d7:	83 ec 0c             	sub    $0xc,%esp
  8015da:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8015de:	57                   	push   %edi
  8015df:	ff 75 e0             	pushl  -0x20(%ebp)
  8015e2:	50                   	push   %eax
  8015e3:	51                   	push   %ecx
  8015e4:	52                   	push   %edx
  8015e5:	89 da                	mov    %ebx,%edx
  8015e7:	89 f0                	mov    %esi,%eax
  8015e9:	e8 b6 fb ff ff       	call   8011a4 <printnum>
			break;
  8015ee:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8015f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015f4:	83 c7 01             	add    $0x1,%edi
  8015f7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015fb:	83 f8 25             	cmp    $0x25,%eax
  8015fe:	0f 84 a6 fc ff ff    	je     8012aa <vprintfmt+0x1b>
			if (ch == '\0')
  801604:	85 c0                	test   %eax,%eax
  801606:	0f 84 ce 00 00 00    	je     8016da <vprintfmt+0x44b>
			putch(ch, putdat);
  80160c:	83 ec 08             	sub    $0x8,%esp
  80160f:	53                   	push   %ebx
  801610:	50                   	push   %eax
  801611:	ff d6                	call   *%esi
  801613:	83 c4 10             	add    $0x10,%esp
  801616:	eb dc                	jmp    8015f4 <vprintfmt+0x365>
		return va_arg(*ap, int);
  801618:	8b 45 14             	mov    0x14(%ebp),%eax
  80161b:	8b 10                	mov    (%eax),%edx
  80161d:	89 d0                	mov    %edx,%eax
  80161f:	99                   	cltd   
  801620:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801623:	8d 49 04             	lea    0x4(%ecx),%ecx
  801626:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801629:	eb a3                	jmp    8015ce <vprintfmt+0x33f>
			putch('0', putdat);
  80162b:	83 ec 08             	sub    $0x8,%esp
  80162e:	53                   	push   %ebx
  80162f:	6a 30                	push   $0x30
  801631:	ff d6                	call   *%esi
			putch('x', putdat);
  801633:	83 c4 08             	add    $0x8,%esp
  801636:	53                   	push   %ebx
  801637:	6a 78                	push   $0x78
  801639:	ff d6                	call   *%esi
			num = (unsigned long long)
  80163b:	8b 45 14             	mov    0x14(%ebp),%eax
  80163e:	8b 10                	mov    (%eax),%edx
  801640:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801645:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801648:	8d 40 04             	lea    0x4(%eax),%eax
  80164b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80164e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801653:	eb 82                	jmp    8015d7 <vprintfmt+0x348>
	if (lflag >= 2)
  801655:	83 f9 01             	cmp    $0x1,%ecx
  801658:	7f 1e                	jg     801678 <vprintfmt+0x3e9>
	else if (lflag)
  80165a:	85 c9                	test   %ecx,%ecx
  80165c:	74 32                	je     801690 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80165e:	8b 45 14             	mov    0x14(%ebp),%eax
  801661:	8b 10                	mov    (%eax),%edx
  801663:	b9 00 00 00 00       	mov    $0x0,%ecx
  801668:	8d 40 04             	lea    0x4(%eax),%eax
  80166b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80166e:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  801673:	e9 5f ff ff ff       	jmp    8015d7 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  801678:	8b 45 14             	mov    0x14(%ebp),%eax
  80167b:	8b 10                	mov    (%eax),%edx
  80167d:	8b 48 04             	mov    0x4(%eax),%ecx
  801680:	8d 40 08             	lea    0x8(%eax),%eax
  801683:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801686:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80168b:	e9 47 ff ff ff       	jmp    8015d7 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  801690:	8b 45 14             	mov    0x14(%ebp),%eax
  801693:	8b 10                	mov    (%eax),%edx
  801695:	b9 00 00 00 00       	mov    $0x0,%ecx
  80169a:	8d 40 04             	lea    0x4(%eax),%eax
  80169d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016a0:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8016a5:	e9 2d ff ff ff       	jmp    8015d7 <vprintfmt+0x348>
			putch(ch, putdat);
  8016aa:	83 ec 08             	sub    $0x8,%esp
  8016ad:	53                   	push   %ebx
  8016ae:	6a 25                	push   $0x25
  8016b0:	ff d6                	call   *%esi
			break;
  8016b2:	83 c4 10             	add    $0x10,%esp
  8016b5:	e9 37 ff ff ff       	jmp    8015f1 <vprintfmt+0x362>
			putch('%', putdat);
  8016ba:	83 ec 08             	sub    $0x8,%esp
  8016bd:	53                   	push   %ebx
  8016be:	6a 25                	push   $0x25
  8016c0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	89 f8                	mov    %edi,%eax
  8016c7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8016cb:	74 05                	je     8016d2 <vprintfmt+0x443>
  8016cd:	83 e8 01             	sub    $0x1,%eax
  8016d0:	eb f5                	jmp    8016c7 <vprintfmt+0x438>
  8016d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016d5:	e9 17 ff ff ff       	jmp    8015f1 <vprintfmt+0x362>
}
  8016da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016dd:	5b                   	pop    %ebx
  8016de:	5e                   	pop    %esi
  8016df:	5f                   	pop    %edi
  8016e0:	5d                   	pop    %ebp
  8016e1:	c3                   	ret    

008016e2 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8016e2:	f3 0f 1e fb          	endbr32 
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	83 ec 18             	sub    $0x18,%esp
  8016ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8016f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016f5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8016f9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801703:	85 c0                	test   %eax,%eax
  801705:	74 26                	je     80172d <vsnprintf+0x4b>
  801707:	85 d2                	test   %edx,%edx
  801709:	7e 22                	jle    80172d <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80170b:	ff 75 14             	pushl  0x14(%ebp)
  80170e:	ff 75 10             	pushl  0x10(%ebp)
  801711:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801714:	50                   	push   %eax
  801715:	68 4d 12 80 00       	push   $0x80124d
  80171a:	e8 70 fb ff ff       	call   80128f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80171f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801722:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801725:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801728:	83 c4 10             	add    $0x10,%esp
}
  80172b:	c9                   	leave  
  80172c:	c3                   	ret    
		return -E_INVAL;
  80172d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801732:	eb f7                	jmp    80172b <vsnprintf+0x49>

00801734 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801734:	f3 0f 1e fb          	endbr32 
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80173e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801741:	50                   	push   %eax
  801742:	ff 75 10             	pushl  0x10(%ebp)
  801745:	ff 75 0c             	pushl  0xc(%ebp)
  801748:	ff 75 08             	pushl  0x8(%ebp)
  80174b:	e8 92 ff ff ff       	call   8016e2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801750:	c9                   	leave  
  801751:	c3                   	ret    

00801752 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801752:	f3 0f 1e fb          	endbr32 
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80175c:	b8 00 00 00 00       	mov    $0x0,%eax
  801761:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801765:	74 05                	je     80176c <strlen+0x1a>
		n++;
  801767:	83 c0 01             	add    $0x1,%eax
  80176a:	eb f5                	jmp    801761 <strlen+0xf>
	return n;
}
  80176c:	5d                   	pop    %ebp
  80176d:	c3                   	ret    

0080176e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80176e:	f3 0f 1e fb          	endbr32 
  801772:	55                   	push   %ebp
  801773:	89 e5                	mov    %esp,%ebp
  801775:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801778:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80177b:	b8 00 00 00 00       	mov    $0x0,%eax
  801780:	39 d0                	cmp    %edx,%eax
  801782:	74 0d                	je     801791 <strnlen+0x23>
  801784:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801788:	74 05                	je     80178f <strnlen+0x21>
		n++;
  80178a:	83 c0 01             	add    $0x1,%eax
  80178d:	eb f1                	jmp    801780 <strnlen+0x12>
  80178f:	89 c2                	mov    %eax,%edx
	return n;
}
  801791:	89 d0                	mov    %edx,%eax
  801793:	5d                   	pop    %ebp
  801794:	c3                   	ret    

00801795 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801795:	f3 0f 1e fb          	endbr32 
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	53                   	push   %ebx
  80179d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8017a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8017a8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8017ac:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8017af:	83 c0 01             	add    $0x1,%eax
  8017b2:	84 d2                	test   %dl,%dl
  8017b4:	75 f2                	jne    8017a8 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8017b6:	89 c8                	mov    %ecx,%eax
  8017b8:	5b                   	pop    %ebx
  8017b9:	5d                   	pop    %ebp
  8017ba:	c3                   	ret    

008017bb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017bb:	f3 0f 1e fb          	endbr32 
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	53                   	push   %ebx
  8017c3:	83 ec 10             	sub    $0x10,%esp
  8017c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8017c9:	53                   	push   %ebx
  8017ca:	e8 83 ff ff ff       	call   801752 <strlen>
  8017cf:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8017d2:	ff 75 0c             	pushl  0xc(%ebp)
  8017d5:	01 d8                	add    %ebx,%eax
  8017d7:	50                   	push   %eax
  8017d8:	e8 b8 ff ff ff       	call   801795 <strcpy>
	return dst;
}
  8017dd:	89 d8                	mov    %ebx,%eax
  8017df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e2:	c9                   	leave  
  8017e3:	c3                   	ret    

008017e4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8017e4:	f3 0f 1e fb          	endbr32 
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	56                   	push   %esi
  8017ec:	53                   	push   %ebx
  8017ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8017f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f3:	89 f3                	mov    %esi,%ebx
  8017f5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017f8:	89 f0                	mov    %esi,%eax
  8017fa:	39 d8                	cmp    %ebx,%eax
  8017fc:	74 11                	je     80180f <strncpy+0x2b>
		*dst++ = *src;
  8017fe:	83 c0 01             	add    $0x1,%eax
  801801:	0f b6 0a             	movzbl (%edx),%ecx
  801804:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801807:	80 f9 01             	cmp    $0x1,%cl
  80180a:	83 da ff             	sbb    $0xffffffff,%edx
  80180d:	eb eb                	jmp    8017fa <strncpy+0x16>
	}
	return ret;
}
  80180f:	89 f0                	mov    %esi,%eax
  801811:	5b                   	pop    %ebx
  801812:	5e                   	pop    %esi
  801813:	5d                   	pop    %ebp
  801814:	c3                   	ret    

00801815 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801815:	f3 0f 1e fb          	endbr32 
  801819:	55                   	push   %ebp
  80181a:	89 e5                	mov    %esp,%ebp
  80181c:	56                   	push   %esi
  80181d:	53                   	push   %ebx
  80181e:	8b 75 08             	mov    0x8(%ebp),%esi
  801821:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801824:	8b 55 10             	mov    0x10(%ebp),%edx
  801827:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801829:	85 d2                	test   %edx,%edx
  80182b:	74 21                	je     80184e <strlcpy+0x39>
  80182d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801831:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801833:	39 c2                	cmp    %eax,%edx
  801835:	74 14                	je     80184b <strlcpy+0x36>
  801837:	0f b6 19             	movzbl (%ecx),%ebx
  80183a:	84 db                	test   %bl,%bl
  80183c:	74 0b                	je     801849 <strlcpy+0x34>
			*dst++ = *src++;
  80183e:	83 c1 01             	add    $0x1,%ecx
  801841:	83 c2 01             	add    $0x1,%edx
  801844:	88 5a ff             	mov    %bl,-0x1(%edx)
  801847:	eb ea                	jmp    801833 <strlcpy+0x1e>
  801849:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80184b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80184e:	29 f0                	sub    %esi,%eax
}
  801850:	5b                   	pop    %ebx
  801851:	5e                   	pop    %esi
  801852:	5d                   	pop    %ebp
  801853:	c3                   	ret    

00801854 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801854:	f3 0f 1e fb          	endbr32 
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80185e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801861:	0f b6 01             	movzbl (%ecx),%eax
  801864:	84 c0                	test   %al,%al
  801866:	74 0c                	je     801874 <strcmp+0x20>
  801868:	3a 02                	cmp    (%edx),%al
  80186a:	75 08                	jne    801874 <strcmp+0x20>
		p++, q++;
  80186c:	83 c1 01             	add    $0x1,%ecx
  80186f:	83 c2 01             	add    $0x1,%edx
  801872:	eb ed                	jmp    801861 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801874:	0f b6 c0             	movzbl %al,%eax
  801877:	0f b6 12             	movzbl (%edx),%edx
  80187a:	29 d0                	sub    %edx,%eax
}
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    

0080187e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80187e:	f3 0f 1e fb          	endbr32 
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	53                   	push   %ebx
  801886:	8b 45 08             	mov    0x8(%ebp),%eax
  801889:	8b 55 0c             	mov    0xc(%ebp),%edx
  80188c:	89 c3                	mov    %eax,%ebx
  80188e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801891:	eb 06                	jmp    801899 <strncmp+0x1b>
		n--, p++, q++;
  801893:	83 c0 01             	add    $0x1,%eax
  801896:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801899:	39 d8                	cmp    %ebx,%eax
  80189b:	74 16                	je     8018b3 <strncmp+0x35>
  80189d:	0f b6 08             	movzbl (%eax),%ecx
  8018a0:	84 c9                	test   %cl,%cl
  8018a2:	74 04                	je     8018a8 <strncmp+0x2a>
  8018a4:	3a 0a                	cmp    (%edx),%cl
  8018a6:	74 eb                	je     801893 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8018a8:	0f b6 00             	movzbl (%eax),%eax
  8018ab:	0f b6 12             	movzbl (%edx),%edx
  8018ae:	29 d0                	sub    %edx,%eax
}
  8018b0:	5b                   	pop    %ebx
  8018b1:	5d                   	pop    %ebp
  8018b2:	c3                   	ret    
		return 0;
  8018b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b8:	eb f6                	jmp    8018b0 <strncmp+0x32>

008018ba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8018ba:	f3 0f 1e fb          	endbr32 
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018c8:	0f b6 10             	movzbl (%eax),%edx
  8018cb:	84 d2                	test   %dl,%dl
  8018cd:	74 09                	je     8018d8 <strchr+0x1e>
		if (*s == c)
  8018cf:	38 ca                	cmp    %cl,%dl
  8018d1:	74 0a                	je     8018dd <strchr+0x23>
	for (; *s; s++)
  8018d3:	83 c0 01             	add    $0x1,%eax
  8018d6:	eb f0                	jmp    8018c8 <strchr+0xe>
			return (char *) s;
	return 0;
  8018d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018dd:	5d                   	pop    %ebp
  8018de:	c3                   	ret    

008018df <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8018df:	f3 0f 1e fb          	endbr32 
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018ed:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8018f0:	38 ca                	cmp    %cl,%dl
  8018f2:	74 09                	je     8018fd <strfind+0x1e>
  8018f4:	84 d2                	test   %dl,%dl
  8018f6:	74 05                	je     8018fd <strfind+0x1e>
	for (; *s; s++)
  8018f8:	83 c0 01             	add    $0x1,%eax
  8018fb:	eb f0                	jmp    8018ed <strfind+0xe>
			break;
	return (char *) s;
}
  8018fd:	5d                   	pop    %ebp
  8018fe:	c3                   	ret    

008018ff <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8018ff:	f3 0f 1e fb          	endbr32 
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	57                   	push   %edi
  801907:	56                   	push   %esi
  801908:	53                   	push   %ebx
  801909:	8b 7d 08             	mov    0x8(%ebp),%edi
  80190c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80190f:	85 c9                	test   %ecx,%ecx
  801911:	74 31                	je     801944 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801913:	89 f8                	mov    %edi,%eax
  801915:	09 c8                	or     %ecx,%eax
  801917:	a8 03                	test   $0x3,%al
  801919:	75 23                	jne    80193e <memset+0x3f>
		c &= 0xFF;
  80191b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80191f:	89 d3                	mov    %edx,%ebx
  801921:	c1 e3 08             	shl    $0x8,%ebx
  801924:	89 d0                	mov    %edx,%eax
  801926:	c1 e0 18             	shl    $0x18,%eax
  801929:	89 d6                	mov    %edx,%esi
  80192b:	c1 e6 10             	shl    $0x10,%esi
  80192e:	09 f0                	or     %esi,%eax
  801930:	09 c2                	or     %eax,%edx
  801932:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801934:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801937:	89 d0                	mov    %edx,%eax
  801939:	fc                   	cld    
  80193a:	f3 ab                	rep stos %eax,%es:(%edi)
  80193c:	eb 06                	jmp    801944 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80193e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801941:	fc                   	cld    
  801942:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801944:	89 f8                	mov    %edi,%eax
  801946:	5b                   	pop    %ebx
  801947:	5e                   	pop    %esi
  801948:	5f                   	pop    %edi
  801949:	5d                   	pop    %ebp
  80194a:	c3                   	ret    

0080194b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80194b:	f3 0f 1e fb          	endbr32 
  80194f:	55                   	push   %ebp
  801950:	89 e5                	mov    %esp,%ebp
  801952:	57                   	push   %edi
  801953:	56                   	push   %esi
  801954:	8b 45 08             	mov    0x8(%ebp),%eax
  801957:	8b 75 0c             	mov    0xc(%ebp),%esi
  80195a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80195d:	39 c6                	cmp    %eax,%esi
  80195f:	73 32                	jae    801993 <memmove+0x48>
  801961:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801964:	39 c2                	cmp    %eax,%edx
  801966:	76 2b                	jbe    801993 <memmove+0x48>
		s += n;
		d += n;
  801968:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80196b:	89 fe                	mov    %edi,%esi
  80196d:	09 ce                	or     %ecx,%esi
  80196f:	09 d6                	or     %edx,%esi
  801971:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801977:	75 0e                	jne    801987 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801979:	83 ef 04             	sub    $0x4,%edi
  80197c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80197f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801982:	fd                   	std    
  801983:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801985:	eb 09                	jmp    801990 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801987:	83 ef 01             	sub    $0x1,%edi
  80198a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80198d:	fd                   	std    
  80198e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801990:	fc                   	cld    
  801991:	eb 1a                	jmp    8019ad <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801993:	89 c2                	mov    %eax,%edx
  801995:	09 ca                	or     %ecx,%edx
  801997:	09 f2                	or     %esi,%edx
  801999:	f6 c2 03             	test   $0x3,%dl
  80199c:	75 0a                	jne    8019a8 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80199e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8019a1:	89 c7                	mov    %eax,%edi
  8019a3:	fc                   	cld    
  8019a4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019a6:	eb 05                	jmp    8019ad <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8019a8:	89 c7                	mov    %eax,%edi
  8019aa:	fc                   	cld    
  8019ab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8019ad:	5e                   	pop    %esi
  8019ae:	5f                   	pop    %edi
  8019af:	5d                   	pop    %ebp
  8019b0:	c3                   	ret    

008019b1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8019b1:	f3 0f 1e fb          	endbr32 
  8019b5:	55                   	push   %ebp
  8019b6:	89 e5                	mov    %esp,%ebp
  8019b8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8019bb:	ff 75 10             	pushl  0x10(%ebp)
  8019be:	ff 75 0c             	pushl  0xc(%ebp)
  8019c1:	ff 75 08             	pushl  0x8(%ebp)
  8019c4:	e8 82 ff ff ff       	call   80194b <memmove>
}
  8019c9:	c9                   	leave  
  8019ca:	c3                   	ret    

008019cb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8019cb:	f3 0f 1e fb          	endbr32 
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	56                   	push   %esi
  8019d3:	53                   	push   %ebx
  8019d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019da:	89 c6                	mov    %eax,%esi
  8019dc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019df:	39 f0                	cmp    %esi,%eax
  8019e1:	74 1c                	je     8019ff <memcmp+0x34>
		if (*s1 != *s2)
  8019e3:	0f b6 08             	movzbl (%eax),%ecx
  8019e6:	0f b6 1a             	movzbl (%edx),%ebx
  8019e9:	38 d9                	cmp    %bl,%cl
  8019eb:	75 08                	jne    8019f5 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8019ed:	83 c0 01             	add    $0x1,%eax
  8019f0:	83 c2 01             	add    $0x1,%edx
  8019f3:	eb ea                	jmp    8019df <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8019f5:	0f b6 c1             	movzbl %cl,%eax
  8019f8:	0f b6 db             	movzbl %bl,%ebx
  8019fb:	29 d8                	sub    %ebx,%eax
  8019fd:	eb 05                	jmp    801a04 <memcmp+0x39>
	}

	return 0;
  8019ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a04:	5b                   	pop    %ebx
  801a05:	5e                   	pop    %esi
  801a06:	5d                   	pop    %ebp
  801a07:	c3                   	ret    

00801a08 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a08:	f3 0f 1e fb          	endbr32 
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a15:	89 c2                	mov    %eax,%edx
  801a17:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a1a:	39 d0                	cmp    %edx,%eax
  801a1c:	73 09                	jae    801a27 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a1e:	38 08                	cmp    %cl,(%eax)
  801a20:	74 05                	je     801a27 <memfind+0x1f>
	for (; s < ends; s++)
  801a22:	83 c0 01             	add    $0x1,%eax
  801a25:	eb f3                	jmp    801a1a <memfind+0x12>
			break;
	return (void *) s;
}
  801a27:	5d                   	pop    %ebp
  801a28:	c3                   	ret    

00801a29 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a29:	f3 0f 1e fb          	endbr32 
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	57                   	push   %edi
  801a31:	56                   	push   %esi
  801a32:	53                   	push   %ebx
  801a33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a39:	eb 03                	jmp    801a3e <strtol+0x15>
		s++;
  801a3b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801a3e:	0f b6 01             	movzbl (%ecx),%eax
  801a41:	3c 20                	cmp    $0x20,%al
  801a43:	74 f6                	je     801a3b <strtol+0x12>
  801a45:	3c 09                	cmp    $0x9,%al
  801a47:	74 f2                	je     801a3b <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801a49:	3c 2b                	cmp    $0x2b,%al
  801a4b:	74 2a                	je     801a77 <strtol+0x4e>
	int neg = 0;
  801a4d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801a52:	3c 2d                	cmp    $0x2d,%al
  801a54:	74 2b                	je     801a81 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a56:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a5c:	75 0f                	jne    801a6d <strtol+0x44>
  801a5e:	80 39 30             	cmpb   $0x30,(%ecx)
  801a61:	74 28                	je     801a8b <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a63:	85 db                	test   %ebx,%ebx
  801a65:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a6a:	0f 44 d8             	cmove  %eax,%ebx
  801a6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a72:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801a75:	eb 46                	jmp    801abd <strtol+0x94>
		s++;
  801a77:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801a7a:	bf 00 00 00 00       	mov    $0x0,%edi
  801a7f:	eb d5                	jmp    801a56 <strtol+0x2d>
		s++, neg = 1;
  801a81:	83 c1 01             	add    $0x1,%ecx
  801a84:	bf 01 00 00 00       	mov    $0x1,%edi
  801a89:	eb cb                	jmp    801a56 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a8b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a8f:	74 0e                	je     801a9f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801a91:	85 db                	test   %ebx,%ebx
  801a93:	75 d8                	jne    801a6d <strtol+0x44>
		s++, base = 8;
  801a95:	83 c1 01             	add    $0x1,%ecx
  801a98:	bb 08 00 00 00       	mov    $0x8,%ebx
  801a9d:	eb ce                	jmp    801a6d <strtol+0x44>
		s += 2, base = 16;
  801a9f:	83 c1 02             	add    $0x2,%ecx
  801aa2:	bb 10 00 00 00       	mov    $0x10,%ebx
  801aa7:	eb c4                	jmp    801a6d <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801aa9:	0f be d2             	movsbl %dl,%edx
  801aac:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801aaf:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ab2:	7d 3a                	jge    801aee <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801ab4:	83 c1 01             	add    $0x1,%ecx
  801ab7:	0f af 45 10          	imul   0x10(%ebp),%eax
  801abb:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801abd:	0f b6 11             	movzbl (%ecx),%edx
  801ac0:	8d 72 d0             	lea    -0x30(%edx),%esi
  801ac3:	89 f3                	mov    %esi,%ebx
  801ac5:	80 fb 09             	cmp    $0x9,%bl
  801ac8:	76 df                	jbe    801aa9 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801aca:	8d 72 9f             	lea    -0x61(%edx),%esi
  801acd:	89 f3                	mov    %esi,%ebx
  801acf:	80 fb 19             	cmp    $0x19,%bl
  801ad2:	77 08                	ja     801adc <strtol+0xb3>
			dig = *s - 'a' + 10;
  801ad4:	0f be d2             	movsbl %dl,%edx
  801ad7:	83 ea 57             	sub    $0x57,%edx
  801ada:	eb d3                	jmp    801aaf <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801adc:	8d 72 bf             	lea    -0x41(%edx),%esi
  801adf:	89 f3                	mov    %esi,%ebx
  801ae1:	80 fb 19             	cmp    $0x19,%bl
  801ae4:	77 08                	ja     801aee <strtol+0xc5>
			dig = *s - 'A' + 10;
  801ae6:	0f be d2             	movsbl %dl,%edx
  801ae9:	83 ea 37             	sub    $0x37,%edx
  801aec:	eb c1                	jmp    801aaf <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801aee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801af2:	74 05                	je     801af9 <strtol+0xd0>
		*endptr = (char *) s;
  801af4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801af7:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801af9:	89 c2                	mov    %eax,%edx
  801afb:	f7 da                	neg    %edx
  801afd:	85 ff                	test   %edi,%edi
  801aff:	0f 45 c2             	cmovne %edx,%eax
}
  801b02:	5b                   	pop    %ebx
  801b03:	5e                   	pop    %esi
  801b04:	5f                   	pop    %edi
  801b05:	5d                   	pop    %ebp
  801b06:	c3                   	ret    

00801b07 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b07:	f3 0f 1e fb          	endbr32 
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	56                   	push   %esi
  801b0f:	53                   	push   %ebx
  801b10:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b16:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801b19:	85 c0                	test   %eax,%eax
  801b1b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b20:	0f 44 c2             	cmove  %edx,%eax
  801b23:	83 ec 0c             	sub    $0xc,%esp
  801b26:	50                   	push   %eax
  801b27:	e8 1b e8 ff ff       	call   800347 <sys_ipc_recv>
  801b2c:	83 c4 10             	add    $0x10,%esp
  801b2f:	85 c0                	test   %eax,%eax
  801b31:	78 24                	js     801b57 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801b33:	85 f6                	test   %esi,%esi
  801b35:	74 0a                	je     801b41 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801b37:	a1 04 40 80 00       	mov    0x804004,%eax
  801b3c:	8b 40 78             	mov    0x78(%eax),%eax
  801b3f:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801b41:	85 db                	test   %ebx,%ebx
  801b43:	74 0a                	je     801b4f <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801b45:	a1 04 40 80 00       	mov    0x804004,%eax
  801b4a:	8b 40 74             	mov    0x74(%eax),%eax
  801b4d:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801b4f:	a1 04 40 80 00       	mov    0x804004,%eax
  801b54:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b5a:	5b                   	pop    %ebx
  801b5b:	5e                   	pop    %esi
  801b5c:	5d                   	pop    %ebp
  801b5d:	c3                   	ret    

00801b5e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b5e:	f3 0f 1e fb          	endbr32 
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	57                   	push   %edi
  801b66:	56                   	push   %esi
  801b67:	53                   	push   %ebx
  801b68:	83 ec 1c             	sub    $0x1c,%esp
  801b6b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b75:	0f 45 d0             	cmovne %eax,%edx
  801b78:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801b7a:	be 01 00 00 00       	mov    $0x1,%esi
  801b7f:	eb 1f                	jmp    801ba0 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801b81:	e8 d2 e5 ff ff       	call   800158 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801b86:	83 c3 01             	add    $0x1,%ebx
  801b89:	39 de                	cmp    %ebx,%esi
  801b8b:	7f f4                	jg     801b81 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801b8d:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801b8f:	83 fe 11             	cmp    $0x11,%esi
  801b92:	b8 01 00 00 00       	mov    $0x1,%eax
  801b97:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801b9a:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801b9e:	75 1c                	jne    801bbc <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801ba0:	ff 75 14             	pushl  0x14(%ebp)
  801ba3:	57                   	push   %edi
  801ba4:	ff 75 0c             	pushl  0xc(%ebp)
  801ba7:	ff 75 08             	pushl  0x8(%ebp)
  801baa:	e8 71 e7 ff ff       	call   800320 <sys_ipc_try_send>
  801baf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801bb2:	83 c4 10             	add    $0x10,%esp
  801bb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bba:	eb cd                	jmp    801b89 <ipc_send+0x2b>
}
  801bbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bbf:	5b                   	pop    %ebx
  801bc0:	5e                   	pop    %esi
  801bc1:	5f                   	pop    %edi
  801bc2:	5d                   	pop    %ebp
  801bc3:	c3                   	ret    

00801bc4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bc4:	f3 0f 1e fb          	endbr32 
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bce:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bd3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bd6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bdc:	8b 52 50             	mov    0x50(%edx),%edx
  801bdf:	39 ca                	cmp    %ecx,%edx
  801be1:	74 11                	je     801bf4 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801be3:	83 c0 01             	add    $0x1,%eax
  801be6:	3d 00 04 00 00       	cmp    $0x400,%eax
  801beb:	75 e6                	jne    801bd3 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801bed:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf2:	eb 0b                	jmp    801bff <ipc_find_env+0x3b>
			return envs[i].env_id;
  801bf4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bf7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bfc:	8b 40 48             	mov    0x48(%eax),%eax
}
  801bff:	5d                   	pop    %ebp
  801c00:	c3                   	ret    

00801c01 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c01:	f3 0f 1e fb          	endbr32 
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
  801c08:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c0b:	89 c2                	mov    %eax,%edx
  801c0d:	c1 ea 16             	shr    $0x16,%edx
  801c10:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c17:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c1c:	f6 c1 01             	test   $0x1,%cl
  801c1f:	74 1c                	je     801c3d <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c21:	c1 e8 0c             	shr    $0xc,%eax
  801c24:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c2b:	a8 01                	test   $0x1,%al
  801c2d:	74 0e                	je     801c3d <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c2f:	c1 e8 0c             	shr    $0xc,%eax
  801c32:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c39:	ef 
  801c3a:	0f b7 d2             	movzwl %dx,%edx
}
  801c3d:	89 d0                	mov    %edx,%eax
  801c3f:	5d                   	pop    %ebp
  801c40:	c3                   	ret    
  801c41:	66 90                	xchg   %ax,%ax
  801c43:	66 90                	xchg   %ax,%ax
  801c45:	66 90                	xchg   %ax,%ax
  801c47:	66 90                	xchg   %ax,%ax
  801c49:	66 90                	xchg   %ax,%ax
  801c4b:	66 90                	xchg   %ax,%ax
  801c4d:	66 90                	xchg   %ax,%ax
  801c4f:	90                   	nop

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
