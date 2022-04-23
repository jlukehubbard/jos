
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
  800048:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80004f:	00 00 00 
    envid_t envid = sys_getenvid();
  800052:	e8 d6 00 00 00       	call   80012d <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x3b>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 20 80 00       	mov    %eax,0x802000

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
  800094:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800097:	6a 00                	push   $0x0
  800099:	e8 4a 00 00 00       	call   8000e8 <sys_env_destroy>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	c9                   	leave  
  8000a2:	c3                   	ret    

008000a3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a3:	f3 0f 1e fb          	endbr32 
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c5:	f3 0f 1e fb          	endbr32 
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	57                   	push   %edi
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d9:	89 d1                	mov    %edx,%ecx
  8000db:	89 d3                	mov    %edx,%ebx
  8000dd:	89 d7                	mov    %edx,%edi
  8000df:	89 d6                	mov    %edx,%esi
  8000e1:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5f                   	pop    %edi
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    

008000e8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e8:	f3 0f 1e fb          	endbr32 
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fd:	b8 03 00 00 00       	mov    $0x3,%eax
  800102:	89 cb                	mov    %ecx,%ebx
  800104:	89 cf                	mov    %ecx,%edi
  800106:	89 ce                	mov    %ecx,%esi
  800108:	cd 30                	int    $0x30
	if(check && ret > 0)
  80010a:	85 c0                	test   %eax,%eax
  80010c:	7f 08                	jg     800116 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800111:	5b                   	pop    %ebx
  800112:	5e                   	pop    %esi
  800113:	5f                   	pop    %edi
  800114:	5d                   	pop    %ebp
  800115:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800116:	83 ec 0c             	sub    $0xc,%esp
  800119:	50                   	push   %eax
  80011a:	6a 03                	push   $0x3
  80011c:	68 4a 10 80 00       	push   $0x80104a
  800121:	6a 23                	push   $0x23
  800123:	68 67 10 80 00       	push   $0x801067
  800128:	e8 36 02 00 00       	call   800363 <_panic>

0080012d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012d:	f3 0f 1e fb          	endbr32 
  800131:	55                   	push   %ebp
  800132:	89 e5                	mov    %esp,%ebp
  800134:	57                   	push   %edi
  800135:	56                   	push   %esi
  800136:	53                   	push   %ebx
	asm volatile("int %1\n"
  800137:	ba 00 00 00 00       	mov    $0x0,%edx
  80013c:	b8 02 00 00 00       	mov    $0x2,%eax
  800141:	89 d1                	mov    %edx,%ecx
  800143:	89 d3                	mov    %edx,%ebx
  800145:	89 d7                	mov    %edx,%edi
  800147:	89 d6                	mov    %edx,%esi
  800149:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014b:	5b                   	pop    %ebx
  80014c:	5e                   	pop    %esi
  80014d:	5f                   	pop    %edi
  80014e:	5d                   	pop    %ebp
  80014f:	c3                   	ret    

00800150 <sys_yield>:

void
sys_yield(void)
{
  800150:	f3 0f 1e fb          	endbr32 
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	57                   	push   %edi
  800158:	56                   	push   %esi
  800159:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015a:	ba 00 00 00 00       	mov    $0x0,%edx
  80015f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800164:	89 d1                	mov    %edx,%ecx
  800166:	89 d3                	mov    %edx,%ebx
  800168:	89 d7                	mov    %edx,%edi
  80016a:	89 d6                	mov    %edx,%esi
  80016c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016e:	5b                   	pop    %ebx
  80016f:	5e                   	pop    %esi
  800170:	5f                   	pop    %edi
  800171:	5d                   	pop    %ebp
  800172:	c3                   	ret    

00800173 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800173:	f3 0f 1e fb          	endbr32 
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	57                   	push   %edi
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800180:	be 00 00 00 00       	mov    $0x0,%esi
  800185:	8b 55 08             	mov    0x8(%ebp),%edx
  800188:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018b:	b8 04 00 00 00       	mov    $0x4,%eax
  800190:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800193:	89 f7                	mov    %esi,%edi
  800195:	cd 30                	int    $0x30
	if(check && ret > 0)
  800197:	85 c0                	test   %eax,%eax
  800199:	7f 08                	jg     8001a3 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019e:	5b                   	pop    %ebx
  80019f:	5e                   	pop    %esi
  8001a0:	5f                   	pop    %edi
  8001a1:	5d                   	pop    %ebp
  8001a2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	50                   	push   %eax
  8001a7:	6a 04                	push   $0x4
  8001a9:	68 4a 10 80 00       	push   $0x80104a
  8001ae:	6a 23                	push   $0x23
  8001b0:	68 67 10 80 00       	push   $0x801067
  8001b5:	e8 a9 01 00 00       	call   800363 <_panic>

008001ba <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ba:	f3 0f 1e fb          	endbr32 
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	57                   	push   %edi
  8001c2:	56                   	push   %esi
  8001c3:	53                   	push   %ebx
  8001c4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d8:	8b 75 18             	mov    0x18(%ebp),%esi
  8001db:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001dd:	85 c0                	test   %eax,%eax
  8001df:	7f 08                	jg     8001e9 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e4:	5b                   	pop    %ebx
  8001e5:	5e                   	pop    %esi
  8001e6:	5f                   	pop    %edi
  8001e7:	5d                   	pop    %ebp
  8001e8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	50                   	push   %eax
  8001ed:	6a 05                	push   $0x5
  8001ef:	68 4a 10 80 00       	push   $0x80104a
  8001f4:	6a 23                	push   $0x23
  8001f6:	68 67 10 80 00       	push   $0x801067
  8001fb:	e8 63 01 00 00       	call   800363 <_panic>

00800200 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800200:	f3 0f 1e fb          	endbr32 
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	57                   	push   %edi
  800208:	56                   	push   %esi
  800209:	53                   	push   %ebx
  80020a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80020d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800212:	8b 55 08             	mov    0x8(%ebp),%edx
  800215:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800218:	b8 06 00 00 00       	mov    $0x6,%eax
  80021d:	89 df                	mov    %ebx,%edi
  80021f:	89 de                	mov    %ebx,%esi
  800221:	cd 30                	int    $0x30
	if(check && ret > 0)
  800223:	85 c0                	test   %eax,%eax
  800225:	7f 08                	jg     80022f <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800227:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022a:	5b                   	pop    %ebx
  80022b:	5e                   	pop    %esi
  80022c:	5f                   	pop    %edi
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80022f:	83 ec 0c             	sub    $0xc,%esp
  800232:	50                   	push   %eax
  800233:	6a 06                	push   $0x6
  800235:	68 4a 10 80 00       	push   $0x80104a
  80023a:	6a 23                	push   $0x23
  80023c:	68 67 10 80 00       	push   $0x801067
  800241:	e8 1d 01 00 00       	call   800363 <_panic>

00800246 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800246:	f3 0f 1e fb          	endbr32 
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	57                   	push   %edi
  80024e:	56                   	push   %esi
  80024f:	53                   	push   %ebx
  800250:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800253:	bb 00 00 00 00       	mov    $0x0,%ebx
  800258:	8b 55 08             	mov    0x8(%ebp),%edx
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025e:	b8 08 00 00 00       	mov    $0x8,%eax
  800263:	89 df                	mov    %ebx,%edi
  800265:	89 de                	mov    %ebx,%esi
  800267:	cd 30                	int    $0x30
	if(check && ret > 0)
  800269:	85 c0                	test   %eax,%eax
  80026b:	7f 08                	jg     800275 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800270:	5b                   	pop    %ebx
  800271:	5e                   	pop    %esi
  800272:	5f                   	pop    %edi
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	50                   	push   %eax
  800279:	6a 08                	push   $0x8
  80027b:	68 4a 10 80 00       	push   $0x80104a
  800280:	6a 23                	push   $0x23
  800282:	68 67 10 80 00       	push   $0x801067
  800287:	e8 d7 00 00 00       	call   800363 <_panic>

0080028c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028c:	f3 0f 1e fb          	endbr32 
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800299:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029e:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a4:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a9:	89 df                	mov    %ebx,%edi
  8002ab:	89 de                	mov    %ebx,%esi
  8002ad:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002af:	85 c0                	test   %eax,%eax
  8002b1:	7f 08                	jg     8002bb <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002bb:	83 ec 0c             	sub    $0xc,%esp
  8002be:	50                   	push   %eax
  8002bf:	6a 09                	push   $0x9
  8002c1:	68 4a 10 80 00       	push   $0x80104a
  8002c6:	6a 23                	push   $0x23
  8002c8:	68 67 10 80 00       	push   $0x801067
  8002cd:	e8 91 00 00 00       	call   800363 <_panic>

008002d2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002d2:	f3 0f 1e fb          	endbr32 
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ea:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ef:	89 df                	mov    %ebx,%edi
  8002f1:	89 de                	mov    %ebx,%esi
  8002f3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002f5:	85 c0                	test   %eax,%eax
  8002f7:	7f 08                	jg     800301 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800301:	83 ec 0c             	sub    $0xc,%esp
  800304:	50                   	push   %eax
  800305:	6a 0a                	push   $0xa
  800307:	68 4a 10 80 00       	push   $0x80104a
  80030c:	6a 23                	push   $0x23
  80030e:	68 67 10 80 00       	push   $0x801067
  800313:	e8 4b 00 00 00       	call   800363 <_panic>

00800318 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800318:	f3 0f 1e fb          	endbr32 
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	57                   	push   %edi
  800320:	56                   	push   %esi
  800321:	53                   	push   %ebx
	asm volatile("int %1\n"
  800322:	8b 55 08             	mov    0x8(%ebp),%edx
  800325:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800328:	b8 0c 00 00 00       	mov    $0xc,%eax
  80032d:	be 00 00 00 00       	mov    $0x0,%esi
  800332:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800335:	8b 7d 14             	mov    0x14(%ebp),%edi
  800338:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80033a:	5b                   	pop    %ebx
  80033b:	5e                   	pop    %esi
  80033c:	5f                   	pop    %edi
  80033d:	5d                   	pop    %ebp
  80033e:	c3                   	ret    

0080033f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80033f:	f3 0f 1e fb          	endbr32 
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	57                   	push   %edi
  800347:	56                   	push   %esi
  800348:	53                   	push   %ebx
	asm volatile("int %1\n"
  800349:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034e:	8b 55 08             	mov    0x8(%ebp),%edx
  800351:	b8 0d 00 00 00       	mov    $0xd,%eax
  800356:	89 cb                	mov    %ecx,%ebx
  800358:	89 cf                	mov    %ecx,%edi
  80035a:	89 ce                	mov    %ecx,%esi
  80035c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 0, (uint32_t)dstva, 0, 0, 0, 0);
}
  80035e:	5b                   	pop    %ebx
  80035f:	5e                   	pop    %esi
  800360:	5f                   	pop    %edi
  800361:	5d                   	pop    %ebp
  800362:	c3                   	ret    

00800363 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800363:	f3 0f 1e fb          	endbr32 
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
  80036a:	56                   	push   %esi
  80036b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80036c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80036f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800375:	e8 b3 fd ff ff       	call   80012d <sys_getenvid>
  80037a:	83 ec 0c             	sub    $0xc,%esp
  80037d:	ff 75 0c             	pushl  0xc(%ebp)
  800380:	ff 75 08             	pushl  0x8(%ebp)
  800383:	56                   	push   %esi
  800384:	50                   	push   %eax
  800385:	68 78 10 80 00       	push   $0x801078
  80038a:	e8 bb 00 00 00       	call   80044a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80038f:	83 c4 18             	add    $0x18,%esp
  800392:	53                   	push   %ebx
  800393:	ff 75 10             	pushl  0x10(%ebp)
  800396:	e8 5a 00 00 00       	call   8003f5 <vcprintf>
	cprintf("\n");
  80039b:	c7 04 24 9b 10 80 00 	movl   $0x80109b,(%esp)
  8003a2:	e8 a3 00 00 00       	call   80044a <cprintf>
  8003a7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003aa:	cc                   	int3   
  8003ab:	eb fd                	jmp    8003aa <_panic+0x47>

008003ad <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003ad:	f3 0f 1e fb          	endbr32 
  8003b1:	55                   	push   %ebp
  8003b2:	89 e5                	mov    %esp,%ebp
  8003b4:	53                   	push   %ebx
  8003b5:	83 ec 04             	sub    $0x4,%esp
  8003b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003bb:	8b 13                	mov    (%ebx),%edx
  8003bd:	8d 42 01             	lea    0x1(%edx),%eax
  8003c0:	89 03                	mov    %eax,(%ebx)
  8003c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003c9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003ce:	74 09                	je     8003d9 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003d0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003d7:	c9                   	leave  
  8003d8:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003d9:	83 ec 08             	sub    $0x8,%esp
  8003dc:	68 ff 00 00 00       	push   $0xff
  8003e1:	8d 43 08             	lea    0x8(%ebx),%eax
  8003e4:	50                   	push   %eax
  8003e5:	e8 b9 fc ff ff       	call   8000a3 <sys_cputs>
		b->idx = 0;
  8003ea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003f0:	83 c4 10             	add    $0x10,%esp
  8003f3:	eb db                	jmp    8003d0 <putch+0x23>

008003f5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003f5:	f3 0f 1e fb          	endbr32 
  8003f9:	55                   	push   %ebp
  8003fa:	89 e5                	mov    %esp,%ebp
  8003fc:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800402:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800409:	00 00 00 
	b.cnt = 0;
  80040c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800413:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800416:	ff 75 0c             	pushl  0xc(%ebp)
  800419:	ff 75 08             	pushl  0x8(%ebp)
  80041c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800422:	50                   	push   %eax
  800423:	68 ad 03 80 00       	push   $0x8003ad
  800428:	e8 20 01 00 00       	call   80054d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80042d:	83 c4 08             	add    $0x8,%esp
  800430:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800436:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80043c:	50                   	push   %eax
  80043d:	e8 61 fc ff ff       	call   8000a3 <sys_cputs>

	return b.cnt;
}
  800442:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800448:	c9                   	leave  
  800449:	c3                   	ret    

0080044a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80044a:	f3 0f 1e fb          	endbr32 
  80044e:	55                   	push   %ebp
  80044f:	89 e5                	mov    %esp,%ebp
  800451:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800454:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800457:	50                   	push   %eax
  800458:	ff 75 08             	pushl  0x8(%ebp)
  80045b:	e8 95 ff ff ff       	call   8003f5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800460:	c9                   	leave  
  800461:	c3                   	ret    

00800462 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	57                   	push   %edi
  800466:	56                   	push   %esi
  800467:	53                   	push   %ebx
  800468:	83 ec 1c             	sub    $0x1c,%esp
  80046b:	89 c7                	mov    %eax,%edi
  80046d:	89 d6                	mov    %edx,%esi
  80046f:	8b 45 08             	mov    0x8(%ebp),%eax
  800472:	8b 55 0c             	mov    0xc(%ebp),%edx
  800475:	89 d1                	mov    %edx,%ecx
  800477:	89 c2                	mov    %eax,%edx
  800479:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80047c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80047f:	8b 45 10             	mov    0x10(%ebp),%eax
  800482:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800485:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800488:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80048f:	39 c2                	cmp    %eax,%edx
  800491:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800494:	72 3e                	jb     8004d4 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800496:	83 ec 0c             	sub    $0xc,%esp
  800499:	ff 75 18             	pushl  0x18(%ebp)
  80049c:	83 eb 01             	sub    $0x1,%ebx
  80049f:	53                   	push   %ebx
  8004a0:	50                   	push   %eax
  8004a1:	83 ec 08             	sub    $0x8,%esp
  8004a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8004ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b0:	e8 1b 09 00 00       	call   800dd0 <__udivdi3>
  8004b5:	83 c4 18             	add    $0x18,%esp
  8004b8:	52                   	push   %edx
  8004b9:	50                   	push   %eax
  8004ba:	89 f2                	mov    %esi,%edx
  8004bc:	89 f8                	mov    %edi,%eax
  8004be:	e8 9f ff ff ff       	call   800462 <printnum>
  8004c3:	83 c4 20             	add    $0x20,%esp
  8004c6:	eb 13                	jmp    8004db <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004c8:	83 ec 08             	sub    $0x8,%esp
  8004cb:	56                   	push   %esi
  8004cc:	ff 75 18             	pushl  0x18(%ebp)
  8004cf:	ff d7                	call   *%edi
  8004d1:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004d4:	83 eb 01             	sub    $0x1,%ebx
  8004d7:	85 db                	test   %ebx,%ebx
  8004d9:	7f ed                	jg     8004c8 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	56                   	push   %esi
  8004df:	83 ec 04             	sub    $0x4,%esp
  8004e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8004eb:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ee:	e8 ed 09 00 00       	call   800ee0 <__umoddi3>
  8004f3:	83 c4 14             	add    $0x14,%esp
  8004f6:	0f be 80 9d 10 80 00 	movsbl 0x80109d(%eax),%eax
  8004fd:	50                   	push   %eax
  8004fe:	ff d7                	call   *%edi
}
  800500:	83 c4 10             	add    $0x10,%esp
  800503:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800506:	5b                   	pop    %ebx
  800507:	5e                   	pop    %esi
  800508:	5f                   	pop    %edi
  800509:	5d                   	pop    %ebp
  80050a:	c3                   	ret    

0080050b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80050b:	f3 0f 1e fb          	endbr32 
  80050f:	55                   	push   %ebp
  800510:	89 e5                	mov    %esp,%ebp
  800512:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800515:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800519:	8b 10                	mov    (%eax),%edx
  80051b:	3b 50 04             	cmp    0x4(%eax),%edx
  80051e:	73 0a                	jae    80052a <sprintputch+0x1f>
		*b->buf++ = ch;
  800520:	8d 4a 01             	lea    0x1(%edx),%ecx
  800523:	89 08                	mov    %ecx,(%eax)
  800525:	8b 45 08             	mov    0x8(%ebp),%eax
  800528:	88 02                	mov    %al,(%edx)
}
  80052a:	5d                   	pop    %ebp
  80052b:	c3                   	ret    

0080052c <printfmt>:
{
  80052c:	f3 0f 1e fb          	endbr32 
  800530:	55                   	push   %ebp
  800531:	89 e5                	mov    %esp,%ebp
  800533:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800536:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800539:	50                   	push   %eax
  80053a:	ff 75 10             	pushl  0x10(%ebp)
  80053d:	ff 75 0c             	pushl  0xc(%ebp)
  800540:	ff 75 08             	pushl  0x8(%ebp)
  800543:	e8 05 00 00 00       	call   80054d <vprintfmt>
}
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	c9                   	leave  
  80054c:	c3                   	ret    

0080054d <vprintfmt>:
{
  80054d:	f3 0f 1e fb          	endbr32 
  800551:	55                   	push   %ebp
  800552:	89 e5                	mov    %esp,%ebp
  800554:	57                   	push   %edi
  800555:	56                   	push   %esi
  800556:	53                   	push   %ebx
  800557:	83 ec 3c             	sub    $0x3c,%esp
  80055a:	8b 75 08             	mov    0x8(%ebp),%esi
  80055d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800560:	8b 7d 10             	mov    0x10(%ebp),%edi
  800563:	e9 4a 03 00 00       	jmp    8008b2 <vprintfmt+0x365>
		padc = ' ';
  800568:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80056c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800573:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80057a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800581:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800586:	8d 47 01             	lea    0x1(%edi),%eax
  800589:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80058c:	0f b6 17             	movzbl (%edi),%edx
  80058f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800592:	3c 55                	cmp    $0x55,%al
  800594:	0f 87 de 03 00 00    	ja     800978 <vprintfmt+0x42b>
  80059a:	0f b6 c0             	movzbl %al,%eax
  80059d:	3e ff 24 85 e0 11 80 	notrack jmp *0x8011e0(,%eax,4)
  8005a4:	00 
  8005a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005a8:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005ac:	eb d8                	jmp    800586 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b1:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005b5:	eb cf                	jmp    800586 <vprintfmt+0x39>
  8005b7:	0f b6 d2             	movzbl %dl,%edx
  8005ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005c5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005c8:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005cc:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005cf:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005d2:	83 f9 09             	cmp    $0x9,%ecx
  8005d5:	77 55                	ja     80062c <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005d7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005da:	eb e9                	jmp    8005c5 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8b 00                	mov    (%eax),%eax
  8005e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ea:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f4:	79 90                	jns    800586 <vprintfmt+0x39>
				width = precision, precision = -1;
  8005f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005fc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800603:	eb 81                	jmp    800586 <vprintfmt+0x39>
  800605:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800608:	85 c0                	test   %eax,%eax
  80060a:	ba 00 00 00 00       	mov    $0x0,%edx
  80060f:	0f 49 d0             	cmovns %eax,%edx
  800612:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800615:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800618:	e9 69 ff ff ff       	jmp    800586 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80061d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800620:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800627:	e9 5a ff ff ff       	jmp    800586 <vprintfmt+0x39>
  80062c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80062f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800632:	eb bc                	jmp    8005f0 <vprintfmt+0xa3>
			lflag++;
  800634:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800637:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80063a:	e9 47 ff ff ff       	jmp    800586 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8d 78 04             	lea    0x4(%eax),%edi
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	53                   	push   %ebx
  800649:	ff 30                	pushl  (%eax)
  80064b:	ff d6                	call   *%esi
			break;
  80064d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800650:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800653:	e9 57 02 00 00       	jmp    8008af <vprintfmt+0x362>
			err = va_arg(ap, int);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8d 78 04             	lea    0x4(%eax),%edi
  80065e:	8b 00                	mov    (%eax),%eax
  800660:	99                   	cltd   
  800661:	31 d0                	xor    %edx,%eax
  800663:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800665:	83 f8 0f             	cmp    $0xf,%eax
  800668:	7f 23                	jg     80068d <vprintfmt+0x140>
  80066a:	8b 14 85 40 13 80 00 	mov    0x801340(,%eax,4),%edx
  800671:	85 d2                	test   %edx,%edx
  800673:	74 18                	je     80068d <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800675:	52                   	push   %edx
  800676:	68 be 10 80 00       	push   $0x8010be
  80067b:	53                   	push   %ebx
  80067c:	56                   	push   %esi
  80067d:	e8 aa fe ff ff       	call   80052c <printfmt>
  800682:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800685:	89 7d 14             	mov    %edi,0x14(%ebp)
  800688:	e9 22 02 00 00       	jmp    8008af <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  80068d:	50                   	push   %eax
  80068e:	68 b5 10 80 00       	push   $0x8010b5
  800693:	53                   	push   %ebx
  800694:	56                   	push   %esi
  800695:	e8 92 fe ff ff       	call   80052c <printfmt>
  80069a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80069d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8006a0:	e9 0a 02 00 00       	jmp    8008af <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	83 c0 04             	add    $0x4,%eax
  8006ab:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8006b3:	85 d2                	test   %edx,%edx
  8006b5:	b8 ae 10 80 00       	mov    $0x8010ae,%eax
  8006ba:	0f 45 c2             	cmovne %edx,%eax
  8006bd:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006c0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c4:	7e 06                	jle    8006cc <vprintfmt+0x17f>
  8006c6:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006ca:	75 0d                	jne    8006d9 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cc:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006cf:	89 c7                	mov    %eax,%edi
  8006d1:	03 45 e0             	add    -0x20(%ebp),%eax
  8006d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d7:	eb 55                	jmp    80072e <vprintfmt+0x1e1>
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	ff 75 d8             	pushl  -0x28(%ebp)
  8006df:	ff 75 cc             	pushl  -0x34(%ebp)
  8006e2:	e8 45 03 00 00       	call   800a2c <strnlen>
  8006e7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006ea:	29 c2                	sub    %eax,%edx
  8006ec:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006f4:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fb:	85 ff                	test   %edi,%edi
  8006fd:	7e 11                	jle    800710 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8006ff:	83 ec 08             	sub    $0x8,%esp
  800702:	53                   	push   %ebx
  800703:	ff 75 e0             	pushl  -0x20(%ebp)
  800706:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800708:	83 ef 01             	sub    $0x1,%edi
  80070b:	83 c4 10             	add    $0x10,%esp
  80070e:	eb eb                	jmp    8006fb <vprintfmt+0x1ae>
  800710:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800713:	85 d2                	test   %edx,%edx
  800715:	b8 00 00 00 00       	mov    $0x0,%eax
  80071a:	0f 49 c2             	cmovns %edx,%eax
  80071d:	29 c2                	sub    %eax,%edx
  80071f:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800722:	eb a8                	jmp    8006cc <vprintfmt+0x17f>
					putch(ch, putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	53                   	push   %ebx
  800728:	52                   	push   %edx
  800729:	ff d6                	call   *%esi
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800731:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800733:	83 c7 01             	add    $0x1,%edi
  800736:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80073a:	0f be d0             	movsbl %al,%edx
  80073d:	85 d2                	test   %edx,%edx
  80073f:	74 4b                	je     80078c <vprintfmt+0x23f>
  800741:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800745:	78 06                	js     80074d <vprintfmt+0x200>
  800747:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80074b:	78 1e                	js     80076b <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80074d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800751:	74 d1                	je     800724 <vprintfmt+0x1d7>
  800753:	0f be c0             	movsbl %al,%eax
  800756:	83 e8 20             	sub    $0x20,%eax
  800759:	83 f8 5e             	cmp    $0x5e,%eax
  80075c:	76 c6                	jbe    800724 <vprintfmt+0x1d7>
					putch('?', putdat);
  80075e:	83 ec 08             	sub    $0x8,%esp
  800761:	53                   	push   %ebx
  800762:	6a 3f                	push   $0x3f
  800764:	ff d6                	call   *%esi
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	eb c3                	jmp    80072e <vprintfmt+0x1e1>
  80076b:	89 cf                	mov    %ecx,%edi
  80076d:	eb 0e                	jmp    80077d <vprintfmt+0x230>
				putch(' ', putdat);
  80076f:	83 ec 08             	sub    $0x8,%esp
  800772:	53                   	push   %ebx
  800773:	6a 20                	push   $0x20
  800775:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800777:	83 ef 01             	sub    $0x1,%edi
  80077a:	83 c4 10             	add    $0x10,%esp
  80077d:	85 ff                	test   %edi,%edi
  80077f:	7f ee                	jg     80076f <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800781:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800784:	89 45 14             	mov    %eax,0x14(%ebp)
  800787:	e9 23 01 00 00       	jmp    8008af <vprintfmt+0x362>
  80078c:	89 cf                	mov    %ecx,%edi
  80078e:	eb ed                	jmp    80077d <vprintfmt+0x230>
	if (lflag >= 2)
  800790:	83 f9 01             	cmp    $0x1,%ecx
  800793:	7f 1b                	jg     8007b0 <vprintfmt+0x263>
	else if (lflag)
  800795:	85 c9                	test   %ecx,%ecx
  800797:	74 63                	je     8007fc <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	8b 00                	mov    (%eax),%eax
  80079e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a1:	99                   	cltd   
  8007a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a8:	8d 40 04             	lea    0x4(%eax),%eax
  8007ab:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ae:	eb 17                	jmp    8007c7 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8007b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b3:	8b 50 04             	mov    0x4(%eax),%edx
  8007b6:	8b 00                	mov    (%eax),%eax
  8007b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007be:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c1:	8d 40 08             	lea    0x8(%eax),%eax
  8007c4:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007c7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007ca:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007cd:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007d2:	85 c9                	test   %ecx,%ecx
  8007d4:	0f 89 bb 00 00 00    	jns    800895 <vprintfmt+0x348>
				putch('-', putdat);
  8007da:	83 ec 08             	sub    $0x8,%esp
  8007dd:	53                   	push   %ebx
  8007de:	6a 2d                	push   $0x2d
  8007e0:	ff d6                	call   *%esi
				num = -(long long) num;
  8007e2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007e5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007e8:	f7 da                	neg    %edx
  8007ea:	83 d1 00             	adc    $0x0,%ecx
  8007ed:	f7 d9                	neg    %ecx
  8007ef:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007f7:	e9 99 00 00 00       	jmp    800895 <vprintfmt+0x348>
		return va_arg(*ap, int);
  8007fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ff:	8b 00                	mov    (%eax),%eax
  800801:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800804:	99                   	cltd   
  800805:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800808:	8b 45 14             	mov    0x14(%ebp),%eax
  80080b:	8d 40 04             	lea    0x4(%eax),%eax
  80080e:	89 45 14             	mov    %eax,0x14(%ebp)
  800811:	eb b4                	jmp    8007c7 <vprintfmt+0x27a>
	if (lflag >= 2)
  800813:	83 f9 01             	cmp    $0x1,%ecx
  800816:	7f 1b                	jg     800833 <vprintfmt+0x2e6>
	else if (lflag)
  800818:	85 c9                	test   %ecx,%ecx
  80081a:	74 2c                	je     800848 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80081c:	8b 45 14             	mov    0x14(%ebp),%eax
  80081f:	8b 10                	mov    (%eax),%edx
  800821:	b9 00 00 00 00       	mov    $0x0,%ecx
  800826:	8d 40 04             	lea    0x4(%eax),%eax
  800829:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80082c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800831:	eb 62                	jmp    800895 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800833:	8b 45 14             	mov    0x14(%ebp),%eax
  800836:	8b 10                	mov    (%eax),%edx
  800838:	8b 48 04             	mov    0x4(%eax),%ecx
  80083b:	8d 40 08             	lea    0x8(%eax),%eax
  80083e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800841:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800846:	eb 4d                	jmp    800895 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800848:	8b 45 14             	mov    0x14(%ebp),%eax
  80084b:	8b 10                	mov    (%eax),%edx
  80084d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800852:	8d 40 04             	lea    0x4(%eax),%eax
  800855:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800858:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80085d:	eb 36                	jmp    800895 <vprintfmt+0x348>
	if (lflag >= 2)
  80085f:	83 f9 01             	cmp    $0x1,%ecx
  800862:	7f 17                	jg     80087b <vprintfmt+0x32e>
	else if (lflag)
  800864:	85 c9                	test   %ecx,%ecx
  800866:	74 6e                	je     8008d6 <vprintfmt+0x389>
		return va_arg(*ap, long);
  800868:	8b 45 14             	mov    0x14(%ebp),%eax
  80086b:	8b 10                	mov    (%eax),%edx
  80086d:	89 d0                	mov    %edx,%eax
  80086f:	99                   	cltd   
  800870:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800873:	8d 49 04             	lea    0x4(%ecx),%ecx
  800876:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800879:	eb 11                	jmp    80088c <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  80087b:	8b 45 14             	mov    0x14(%ebp),%eax
  80087e:	8b 50 04             	mov    0x4(%eax),%edx
  800881:	8b 00                	mov    (%eax),%eax
  800883:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800886:	8d 49 08             	lea    0x8(%ecx),%ecx
  800889:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80088c:	89 d1                	mov    %edx,%ecx
  80088e:	89 c2                	mov    %eax,%edx
            base = 8;
  800890:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800895:	83 ec 0c             	sub    $0xc,%esp
  800898:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80089c:	57                   	push   %edi
  80089d:	ff 75 e0             	pushl  -0x20(%ebp)
  8008a0:	50                   	push   %eax
  8008a1:	51                   	push   %ecx
  8008a2:	52                   	push   %edx
  8008a3:	89 da                	mov    %ebx,%edx
  8008a5:	89 f0                	mov    %esi,%eax
  8008a7:	e8 b6 fb ff ff       	call   800462 <printnum>
			break;
  8008ac:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008b2:	83 c7 01             	add    $0x1,%edi
  8008b5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008b9:	83 f8 25             	cmp    $0x25,%eax
  8008bc:	0f 84 a6 fc ff ff    	je     800568 <vprintfmt+0x1b>
			if (ch == '\0')
  8008c2:	85 c0                	test   %eax,%eax
  8008c4:	0f 84 ce 00 00 00    	je     800998 <vprintfmt+0x44b>
			putch(ch, putdat);
  8008ca:	83 ec 08             	sub    $0x8,%esp
  8008cd:	53                   	push   %ebx
  8008ce:	50                   	push   %eax
  8008cf:	ff d6                	call   *%esi
  8008d1:	83 c4 10             	add    $0x10,%esp
  8008d4:	eb dc                	jmp    8008b2 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8008d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d9:	8b 10                	mov    (%eax),%edx
  8008db:	89 d0                	mov    %edx,%eax
  8008dd:	99                   	cltd   
  8008de:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008e1:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008e4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008e7:	eb a3                	jmp    80088c <vprintfmt+0x33f>
			putch('0', putdat);
  8008e9:	83 ec 08             	sub    $0x8,%esp
  8008ec:	53                   	push   %ebx
  8008ed:	6a 30                	push   $0x30
  8008ef:	ff d6                	call   *%esi
			putch('x', putdat);
  8008f1:	83 c4 08             	add    $0x8,%esp
  8008f4:	53                   	push   %ebx
  8008f5:	6a 78                	push   $0x78
  8008f7:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fc:	8b 10                	mov    (%eax),%edx
  8008fe:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800903:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800906:	8d 40 04             	lea    0x4(%eax),%eax
  800909:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80090c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800911:	eb 82                	jmp    800895 <vprintfmt+0x348>
	if (lflag >= 2)
  800913:	83 f9 01             	cmp    $0x1,%ecx
  800916:	7f 1e                	jg     800936 <vprintfmt+0x3e9>
	else if (lflag)
  800918:	85 c9                	test   %ecx,%ecx
  80091a:	74 32                	je     80094e <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80091c:	8b 45 14             	mov    0x14(%ebp),%eax
  80091f:	8b 10                	mov    (%eax),%edx
  800921:	b9 00 00 00 00       	mov    $0x0,%ecx
  800926:	8d 40 04             	lea    0x4(%eax),%eax
  800929:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80092c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800931:	e9 5f ff ff ff       	jmp    800895 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800936:	8b 45 14             	mov    0x14(%ebp),%eax
  800939:	8b 10                	mov    (%eax),%edx
  80093b:	8b 48 04             	mov    0x4(%eax),%ecx
  80093e:	8d 40 08             	lea    0x8(%eax),%eax
  800941:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800944:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800949:	e9 47 ff ff ff       	jmp    800895 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80094e:	8b 45 14             	mov    0x14(%ebp),%eax
  800951:	8b 10                	mov    (%eax),%edx
  800953:	b9 00 00 00 00       	mov    $0x0,%ecx
  800958:	8d 40 04             	lea    0x4(%eax),%eax
  80095b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80095e:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800963:	e9 2d ff ff ff       	jmp    800895 <vprintfmt+0x348>
			putch(ch, putdat);
  800968:	83 ec 08             	sub    $0x8,%esp
  80096b:	53                   	push   %ebx
  80096c:	6a 25                	push   $0x25
  80096e:	ff d6                	call   *%esi
			break;
  800970:	83 c4 10             	add    $0x10,%esp
  800973:	e9 37 ff ff ff       	jmp    8008af <vprintfmt+0x362>
			putch('%', putdat);
  800978:	83 ec 08             	sub    $0x8,%esp
  80097b:	53                   	push   %ebx
  80097c:	6a 25                	push   $0x25
  80097e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800980:	83 c4 10             	add    $0x10,%esp
  800983:	89 f8                	mov    %edi,%eax
  800985:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800989:	74 05                	je     800990 <vprintfmt+0x443>
  80098b:	83 e8 01             	sub    $0x1,%eax
  80098e:	eb f5                	jmp    800985 <vprintfmt+0x438>
  800990:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800993:	e9 17 ff ff ff       	jmp    8008af <vprintfmt+0x362>
}
  800998:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80099b:	5b                   	pop    %ebx
  80099c:	5e                   	pop    %esi
  80099d:	5f                   	pop    %edi
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009a0:	f3 0f 1e fb          	endbr32 
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	83 ec 18             	sub    $0x18,%esp
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009b3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009b7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009c1:	85 c0                	test   %eax,%eax
  8009c3:	74 26                	je     8009eb <vsnprintf+0x4b>
  8009c5:	85 d2                	test   %edx,%edx
  8009c7:	7e 22                	jle    8009eb <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009c9:	ff 75 14             	pushl  0x14(%ebp)
  8009cc:	ff 75 10             	pushl  0x10(%ebp)
  8009cf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009d2:	50                   	push   %eax
  8009d3:	68 0b 05 80 00       	push   $0x80050b
  8009d8:	e8 70 fb ff ff       	call   80054d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009e0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009e6:	83 c4 10             	add    $0x10,%esp
}
  8009e9:	c9                   	leave  
  8009ea:	c3                   	ret    
		return -E_INVAL;
  8009eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009f0:	eb f7                	jmp    8009e9 <vsnprintf+0x49>

008009f2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009f2:	f3 0f 1e fb          	endbr32 
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009fc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009ff:	50                   	push   %eax
  800a00:	ff 75 10             	pushl  0x10(%ebp)
  800a03:	ff 75 0c             	pushl  0xc(%ebp)
  800a06:	ff 75 08             	pushl  0x8(%ebp)
  800a09:	e8 92 ff ff ff       	call   8009a0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a0e:	c9                   	leave  
  800a0f:	c3                   	ret    

00800a10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a10:	f3 0f 1e fb          	endbr32 
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a23:	74 05                	je     800a2a <strlen+0x1a>
		n++;
  800a25:	83 c0 01             	add    $0x1,%eax
  800a28:	eb f5                	jmp    800a1f <strlen+0xf>
	return n;
}
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a2c:	f3 0f 1e fb          	endbr32 
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a36:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a39:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3e:	39 d0                	cmp    %edx,%eax
  800a40:	74 0d                	je     800a4f <strnlen+0x23>
  800a42:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a46:	74 05                	je     800a4d <strnlen+0x21>
		n++;
  800a48:	83 c0 01             	add    $0x1,%eax
  800a4b:	eb f1                	jmp    800a3e <strnlen+0x12>
  800a4d:	89 c2                	mov    %eax,%edx
	return n;
}
  800a4f:	89 d0                	mov    %edx,%eax
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a53:	f3 0f 1e fb          	endbr32 
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	53                   	push   %ebx
  800a5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a61:	b8 00 00 00 00       	mov    $0x0,%eax
  800a66:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a6a:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a6d:	83 c0 01             	add    $0x1,%eax
  800a70:	84 d2                	test   %dl,%dl
  800a72:	75 f2                	jne    800a66 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a74:	89 c8                	mov    %ecx,%eax
  800a76:	5b                   	pop    %ebx
  800a77:	5d                   	pop    %ebp
  800a78:	c3                   	ret    

00800a79 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a79:	f3 0f 1e fb          	endbr32 
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	53                   	push   %ebx
  800a81:	83 ec 10             	sub    $0x10,%esp
  800a84:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a87:	53                   	push   %ebx
  800a88:	e8 83 ff ff ff       	call   800a10 <strlen>
  800a8d:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a90:	ff 75 0c             	pushl  0xc(%ebp)
  800a93:	01 d8                	add    %ebx,%eax
  800a95:	50                   	push   %eax
  800a96:	e8 b8 ff ff ff       	call   800a53 <strcpy>
	return dst;
}
  800a9b:	89 d8                	mov    %ebx,%eax
  800a9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aa0:	c9                   	leave  
  800aa1:	c3                   	ret    

00800aa2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aa2:	f3 0f 1e fb          	endbr32 
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
  800aab:	8b 75 08             	mov    0x8(%ebp),%esi
  800aae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab1:	89 f3                	mov    %esi,%ebx
  800ab3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab6:	89 f0                	mov    %esi,%eax
  800ab8:	39 d8                	cmp    %ebx,%eax
  800aba:	74 11                	je     800acd <strncpy+0x2b>
		*dst++ = *src;
  800abc:	83 c0 01             	add    $0x1,%eax
  800abf:	0f b6 0a             	movzbl (%edx),%ecx
  800ac2:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ac5:	80 f9 01             	cmp    $0x1,%cl
  800ac8:	83 da ff             	sbb    $0xffffffff,%edx
  800acb:	eb eb                	jmp    800ab8 <strncpy+0x16>
	}
	return ret;
}
  800acd:	89 f0                	mov    %esi,%eax
  800acf:	5b                   	pop    %ebx
  800ad0:	5e                   	pop    %esi
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ad3:	f3 0f 1e fb          	endbr32 
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
  800adc:	8b 75 08             	mov    0x8(%ebp),%esi
  800adf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae2:	8b 55 10             	mov    0x10(%ebp),%edx
  800ae5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ae7:	85 d2                	test   %edx,%edx
  800ae9:	74 21                	je     800b0c <strlcpy+0x39>
  800aeb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800aef:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800af1:	39 c2                	cmp    %eax,%edx
  800af3:	74 14                	je     800b09 <strlcpy+0x36>
  800af5:	0f b6 19             	movzbl (%ecx),%ebx
  800af8:	84 db                	test   %bl,%bl
  800afa:	74 0b                	je     800b07 <strlcpy+0x34>
			*dst++ = *src++;
  800afc:	83 c1 01             	add    $0x1,%ecx
  800aff:	83 c2 01             	add    $0x1,%edx
  800b02:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b05:	eb ea                	jmp    800af1 <strlcpy+0x1e>
  800b07:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b09:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b0c:	29 f0                	sub    %esi,%eax
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b12:	f3 0f 1e fb          	endbr32 
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b1f:	0f b6 01             	movzbl (%ecx),%eax
  800b22:	84 c0                	test   %al,%al
  800b24:	74 0c                	je     800b32 <strcmp+0x20>
  800b26:	3a 02                	cmp    (%edx),%al
  800b28:	75 08                	jne    800b32 <strcmp+0x20>
		p++, q++;
  800b2a:	83 c1 01             	add    $0x1,%ecx
  800b2d:	83 c2 01             	add    $0x1,%edx
  800b30:	eb ed                	jmp    800b1f <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b32:	0f b6 c0             	movzbl %al,%eax
  800b35:	0f b6 12             	movzbl (%edx),%edx
  800b38:	29 d0                	sub    %edx,%eax
}
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b3c:	f3 0f 1e fb          	endbr32 
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	53                   	push   %ebx
  800b44:	8b 45 08             	mov    0x8(%ebp),%eax
  800b47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b4a:	89 c3                	mov    %eax,%ebx
  800b4c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b4f:	eb 06                	jmp    800b57 <strncmp+0x1b>
		n--, p++, q++;
  800b51:	83 c0 01             	add    $0x1,%eax
  800b54:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b57:	39 d8                	cmp    %ebx,%eax
  800b59:	74 16                	je     800b71 <strncmp+0x35>
  800b5b:	0f b6 08             	movzbl (%eax),%ecx
  800b5e:	84 c9                	test   %cl,%cl
  800b60:	74 04                	je     800b66 <strncmp+0x2a>
  800b62:	3a 0a                	cmp    (%edx),%cl
  800b64:	74 eb                	je     800b51 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b66:	0f b6 00             	movzbl (%eax),%eax
  800b69:	0f b6 12             	movzbl (%edx),%edx
  800b6c:	29 d0                	sub    %edx,%eax
}
  800b6e:	5b                   	pop    %ebx
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    
		return 0;
  800b71:	b8 00 00 00 00       	mov    $0x0,%eax
  800b76:	eb f6                	jmp    800b6e <strncmp+0x32>

00800b78 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b78:	f3 0f 1e fb          	endbr32 
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b82:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b86:	0f b6 10             	movzbl (%eax),%edx
  800b89:	84 d2                	test   %dl,%dl
  800b8b:	74 09                	je     800b96 <strchr+0x1e>
		if (*s == c)
  800b8d:	38 ca                	cmp    %cl,%dl
  800b8f:	74 0a                	je     800b9b <strchr+0x23>
	for (; *s; s++)
  800b91:	83 c0 01             	add    $0x1,%eax
  800b94:	eb f0                	jmp    800b86 <strchr+0xe>
			return (char *) s;
	return 0;
  800b96:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b9d:	f3 0f 1e fb          	endbr32 
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bab:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bae:	38 ca                	cmp    %cl,%dl
  800bb0:	74 09                	je     800bbb <strfind+0x1e>
  800bb2:	84 d2                	test   %dl,%dl
  800bb4:	74 05                	je     800bbb <strfind+0x1e>
	for (; *s; s++)
  800bb6:	83 c0 01             	add    $0x1,%eax
  800bb9:	eb f0                	jmp    800bab <strfind+0xe>
			break;
	return (char *) s;
}
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bbd:	f3 0f 1e fb          	endbr32 
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
  800bc7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bcd:	85 c9                	test   %ecx,%ecx
  800bcf:	74 31                	je     800c02 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bd1:	89 f8                	mov    %edi,%eax
  800bd3:	09 c8                	or     %ecx,%eax
  800bd5:	a8 03                	test   $0x3,%al
  800bd7:	75 23                	jne    800bfc <memset+0x3f>
		c &= 0xFF;
  800bd9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bdd:	89 d3                	mov    %edx,%ebx
  800bdf:	c1 e3 08             	shl    $0x8,%ebx
  800be2:	89 d0                	mov    %edx,%eax
  800be4:	c1 e0 18             	shl    $0x18,%eax
  800be7:	89 d6                	mov    %edx,%esi
  800be9:	c1 e6 10             	shl    $0x10,%esi
  800bec:	09 f0                	or     %esi,%eax
  800bee:	09 c2                	or     %eax,%edx
  800bf0:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bf2:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800bf5:	89 d0                	mov    %edx,%eax
  800bf7:	fc                   	cld    
  800bf8:	f3 ab                	rep stos %eax,%es:(%edi)
  800bfa:	eb 06                	jmp    800c02 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bfc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bff:	fc                   	cld    
  800c00:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c02:	89 f8                	mov    %edi,%eax
  800c04:	5b                   	pop    %ebx
  800c05:	5e                   	pop    %esi
  800c06:	5f                   	pop    %edi
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c09:	f3 0f 1e fb          	endbr32 
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	8b 45 08             	mov    0x8(%ebp),%eax
  800c15:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c18:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c1b:	39 c6                	cmp    %eax,%esi
  800c1d:	73 32                	jae    800c51 <memmove+0x48>
  800c1f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c22:	39 c2                	cmp    %eax,%edx
  800c24:	76 2b                	jbe    800c51 <memmove+0x48>
		s += n;
		d += n;
  800c26:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c29:	89 fe                	mov    %edi,%esi
  800c2b:	09 ce                	or     %ecx,%esi
  800c2d:	09 d6                	or     %edx,%esi
  800c2f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c35:	75 0e                	jne    800c45 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c37:	83 ef 04             	sub    $0x4,%edi
  800c3a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c3d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c40:	fd                   	std    
  800c41:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c43:	eb 09                	jmp    800c4e <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c45:	83 ef 01             	sub    $0x1,%edi
  800c48:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c4b:	fd                   	std    
  800c4c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c4e:	fc                   	cld    
  800c4f:	eb 1a                	jmp    800c6b <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c51:	89 c2                	mov    %eax,%edx
  800c53:	09 ca                	or     %ecx,%edx
  800c55:	09 f2                	or     %esi,%edx
  800c57:	f6 c2 03             	test   $0x3,%dl
  800c5a:	75 0a                	jne    800c66 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c5c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c5f:	89 c7                	mov    %eax,%edi
  800c61:	fc                   	cld    
  800c62:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c64:	eb 05                	jmp    800c6b <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c66:	89 c7                	mov    %eax,%edi
  800c68:	fc                   	cld    
  800c69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c6f:	f3 0f 1e fb          	endbr32 
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c79:	ff 75 10             	pushl  0x10(%ebp)
  800c7c:	ff 75 0c             	pushl  0xc(%ebp)
  800c7f:	ff 75 08             	pushl  0x8(%ebp)
  800c82:	e8 82 ff ff ff       	call   800c09 <memmove>
}
  800c87:	c9                   	leave  
  800c88:	c3                   	ret    

00800c89 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c89:	f3 0f 1e fb          	endbr32 
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	8b 45 08             	mov    0x8(%ebp),%eax
  800c95:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c98:	89 c6                	mov    %eax,%esi
  800c9a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c9d:	39 f0                	cmp    %esi,%eax
  800c9f:	74 1c                	je     800cbd <memcmp+0x34>
		if (*s1 != *s2)
  800ca1:	0f b6 08             	movzbl (%eax),%ecx
  800ca4:	0f b6 1a             	movzbl (%edx),%ebx
  800ca7:	38 d9                	cmp    %bl,%cl
  800ca9:	75 08                	jne    800cb3 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cab:	83 c0 01             	add    $0x1,%eax
  800cae:	83 c2 01             	add    $0x1,%edx
  800cb1:	eb ea                	jmp    800c9d <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800cb3:	0f b6 c1             	movzbl %cl,%eax
  800cb6:	0f b6 db             	movzbl %bl,%ebx
  800cb9:	29 d8                	sub    %ebx,%eax
  800cbb:	eb 05                	jmp    800cc2 <memcmp+0x39>
	}

	return 0;
  800cbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cc6:	f3 0f 1e fb          	endbr32 
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cd3:	89 c2                	mov    %eax,%edx
  800cd5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cd8:	39 d0                	cmp    %edx,%eax
  800cda:	73 09                	jae    800ce5 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cdc:	38 08                	cmp    %cl,(%eax)
  800cde:	74 05                	je     800ce5 <memfind+0x1f>
	for (; s < ends; s++)
  800ce0:	83 c0 01             	add    $0x1,%eax
  800ce3:	eb f3                	jmp    800cd8 <memfind+0x12>
			break;
	return (void *) s;
}
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ce7:	f3 0f 1e fb          	endbr32 
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	57                   	push   %edi
  800cef:	56                   	push   %esi
  800cf0:	53                   	push   %ebx
  800cf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf7:	eb 03                	jmp    800cfc <strtol+0x15>
		s++;
  800cf9:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800cfc:	0f b6 01             	movzbl (%ecx),%eax
  800cff:	3c 20                	cmp    $0x20,%al
  800d01:	74 f6                	je     800cf9 <strtol+0x12>
  800d03:	3c 09                	cmp    $0x9,%al
  800d05:	74 f2                	je     800cf9 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d07:	3c 2b                	cmp    $0x2b,%al
  800d09:	74 2a                	je     800d35 <strtol+0x4e>
	int neg = 0;
  800d0b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d10:	3c 2d                	cmp    $0x2d,%al
  800d12:	74 2b                	je     800d3f <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d14:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d1a:	75 0f                	jne    800d2b <strtol+0x44>
  800d1c:	80 39 30             	cmpb   $0x30,(%ecx)
  800d1f:	74 28                	je     800d49 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d21:	85 db                	test   %ebx,%ebx
  800d23:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d28:	0f 44 d8             	cmove  %eax,%ebx
  800d2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d30:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d33:	eb 46                	jmp    800d7b <strtol+0x94>
		s++;
  800d35:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d38:	bf 00 00 00 00       	mov    $0x0,%edi
  800d3d:	eb d5                	jmp    800d14 <strtol+0x2d>
		s++, neg = 1;
  800d3f:	83 c1 01             	add    $0x1,%ecx
  800d42:	bf 01 00 00 00       	mov    $0x1,%edi
  800d47:	eb cb                	jmp    800d14 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d49:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d4d:	74 0e                	je     800d5d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d4f:	85 db                	test   %ebx,%ebx
  800d51:	75 d8                	jne    800d2b <strtol+0x44>
		s++, base = 8;
  800d53:	83 c1 01             	add    $0x1,%ecx
  800d56:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d5b:	eb ce                	jmp    800d2b <strtol+0x44>
		s += 2, base = 16;
  800d5d:	83 c1 02             	add    $0x2,%ecx
  800d60:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d65:	eb c4                	jmp    800d2b <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d67:	0f be d2             	movsbl %dl,%edx
  800d6a:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d6d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d70:	7d 3a                	jge    800dac <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d72:	83 c1 01             	add    $0x1,%ecx
  800d75:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d79:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d7b:	0f b6 11             	movzbl (%ecx),%edx
  800d7e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d81:	89 f3                	mov    %esi,%ebx
  800d83:	80 fb 09             	cmp    $0x9,%bl
  800d86:	76 df                	jbe    800d67 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800d88:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d8b:	89 f3                	mov    %esi,%ebx
  800d8d:	80 fb 19             	cmp    $0x19,%bl
  800d90:	77 08                	ja     800d9a <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d92:	0f be d2             	movsbl %dl,%edx
  800d95:	83 ea 57             	sub    $0x57,%edx
  800d98:	eb d3                	jmp    800d6d <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800d9a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d9d:	89 f3                	mov    %esi,%ebx
  800d9f:	80 fb 19             	cmp    $0x19,%bl
  800da2:	77 08                	ja     800dac <strtol+0xc5>
			dig = *s - 'A' + 10;
  800da4:	0f be d2             	movsbl %dl,%edx
  800da7:	83 ea 37             	sub    $0x37,%edx
  800daa:	eb c1                	jmp    800d6d <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800db0:	74 05                	je     800db7 <strtol+0xd0>
		*endptr = (char *) s;
  800db2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800db5:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800db7:	89 c2                	mov    %eax,%edx
  800db9:	f7 da                	neg    %edx
  800dbb:	85 ff                	test   %edi,%edi
  800dbd:	0f 45 c2             	cmovne %edx,%eax
}
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    
  800dc5:	66 90                	xchg   %ax,%ax
  800dc7:	66 90                	xchg   %ax,%ax
  800dc9:	66 90                	xchg   %ax,%ax
  800dcb:	66 90                	xchg   %ax,%ax
  800dcd:	66 90                	xchg   %ax,%ax
  800dcf:	90                   	nop

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
