
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
  80011c:	68 6a 10 80 00       	push   $0x80106a
  800121:	6a 23                	push   $0x23
  800123:	68 87 10 80 00       	push   $0x801087
  800128:	e8 57 02 00 00       	call   800384 <_panic>

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
  8001a9:	68 6a 10 80 00       	push   $0x80106a
  8001ae:	6a 23                	push   $0x23
  8001b0:	68 87 10 80 00       	push   $0x801087
  8001b5:	e8 ca 01 00 00       	call   800384 <_panic>

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
  8001ef:	68 6a 10 80 00       	push   $0x80106a
  8001f4:	6a 23                	push   $0x23
  8001f6:	68 87 10 80 00       	push   $0x801087
  8001fb:	e8 84 01 00 00       	call   800384 <_panic>

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
  800235:	68 6a 10 80 00       	push   $0x80106a
  80023a:	6a 23                	push   $0x23
  80023c:	68 87 10 80 00       	push   $0x801087
  800241:	e8 3e 01 00 00       	call   800384 <_panic>

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
  80027b:	68 6a 10 80 00       	push   $0x80106a
  800280:	6a 23                	push   $0x23
  800282:	68 87 10 80 00       	push   $0x801087
  800287:	e8 f8 00 00 00       	call   800384 <_panic>

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
  8002c1:	68 6a 10 80 00       	push   $0x80106a
  8002c6:	6a 23                	push   $0x23
  8002c8:	68 87 10 80 00       	push   $0x801087
  8002cd:	e8 b2 00 00 00       	call   800384 <_panic>

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
  800307:	68 6a 10 80 00       	push   $0x80106a
  80030c:	6a 23                	push   $0x23
  80030e:	68 87 10 80 00       	push   $0x801087
  800313:	e8 6c 00 00 00       	call   800384 <_panic>

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
  800349:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80034c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800351:	8b 55 08             	mov    0x8(%ebp),%edx
  800354:	b8 0d 00 00 00       	mov    $0xd,%eax
  800359:	89 cb                	mov    %ecx,%ebx
  80035b:	89 cf                	mov    %ecx,%edi
  80035d:	89 ce                	mov    %ecx,%esi
  80035f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800361:	85 c0                	test   %eax,%eax
  800363:	7f 08                	jg     80036d <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800365:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800368:	5b                   	pop    %ebx
  800369:	5e                   	pop    %esi
  80036a:	5f                   	pop    %edi
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80036d:	83 ec 0c             	sub    $0xc,%esp
  800370:	50                   	push   %eax
  800371:	6a 0d                	push   $0xd
  800373:	68 6a 10 80 00       	push   $0x80106a
  800378:	6a 23                	push   $0x23
  80037a:	68 87 10 80 00       	push   $0x801087
  80037f:	e8 00 00 00 00       	call   800384 <_panic>

00800384 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800384:	f3 0f 1e fb          	endbr32 
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	56                   	push   %esi
  80038c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80038d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800390:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800396:	e8 92 fd ff ff       	call   80012d <sys_getenvid>
  80039b:	83 ec 0c             	sub    $0xc,%esp
  80039e:	ff 75 0c             	pushl  0xc(%ebp)
  8003a1:	ff 75 08             	pushl  0x8(%ebp)
  8003a4:	56                   	push   %esi
  8003a5:	50                   	push   %eax
  8003a6:	68 98 10 80 00       	push   $0x801098
  8003ab:	e8 bb 00 00 00       	call   80046b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003b0:	83 c4 18             	add    $0x18,%esp
  8003b3:	53                   	push   %ebx
  8003b4:	ff 75 10             	pushl  0x10(%ebp)
  8003b7:	e8 5a 00 00 00       	call   800416 <vcprintf>
	cprintf("\n");
  8003bc:	c7 04 24 bb 10 80 00 	movl   $0x8010bb,(%esp)
  8003c3:	e8 a3 00 00 00       	call   80046b <cprintf>
  8003c8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003cb:	cc                   	int3   
  8003cc:	eb fd                	jmp    8003cb <_panic+0x47>

008003ce <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003ce:	f3 0f 1e fb          	endbr32 
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
  8003d5:	53                   	push   %ebx
  8003d6:	83 ec 04             	sub    $0x4,%esp
  8003d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003dc:	8b 13                	mov    (%ebx),%edx
  8003de:	8d 42 01             	lea    0x1(%edx),%eax
  8003e1:	89 03                	mov    %eax,(%ebx)
  8003e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003ea:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003ef:	74 09                	je     8003fa <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003f1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003f8:	c9                   	leave  
  8003f9:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003fa:	83 ec 08             	sub    $0x8,%esp
  8003fd:	68 ff 00 00 00       	push   $0xff
  800402:	8d 43 08             	lea    0x8(%ebx),%eax
  800405:	50                   	push   %eax
  800406:	e8 98 fc ff ff       	call   8000a3 <sys_cputs>
		b->idx = 0;
  80040b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800411:	83 c4 10             	add    $0x10,%esp
  800414:	eb db                	jmp    8003f1 <putch+0x23>

00800416 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800416:	f3 0f 1e fb          	endbr32 
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800423:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80042a:	00 00 00 
	b.cnt = 0;
  80042d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800434:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800437:	ff 75 0c             	pushl  0xc(%ebp)
  80043a:	ff 75 08             	pushl  0x8(%ebp)
  80043d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800443:	50                   	push   %eax
  800444:	68 ce 03 80 00       	push   $0x8003ce
  800449:	e8 20 01 00 00       	call   80056e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80044e:	83 c4 08             	add    $0x8,%esp
  800451:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800457:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80045d:	50                   	push   %eax
  80045e:	e8 40 fc ff ff       	call   8000a3 <sys_cputs>

	return b.cnt;
}
  800463:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800469:	c9                   	leave  
  80046a:	c3                   	ret    

0080046b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80046b:	f3 0f 1e fb          	endbr32 
  80046f:	55                   	push   %ebp
  800470:	89 e5                	mov    %esp,%ebp
  800472:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800475:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800478:	50                   	push   %eax
  800479:	ff 75 08             	pushl  0x8(%ebp)
  80047c:	e8 95 ff ff ff       	call   800416 <vcprintf>
	va_end(ap);

	return cnt;
}
  800481:	c9                   	leave  
  800482:	c3                   	ret    

00800483 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800483:	55                   	push   %ebp
  800484:	89 e5                	mov    %esp,%ebp
  800486:	57                   	push   %edi
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	83 ec 1c             	sub    $0x1c,%esp
  80048c:	89 c7                	mov    %eax,%edi
  80048e:	89 d6                	mov    %edx,%esi
  800490:	8b 45 08             	mov    0x8(%ebp),%eax
  800493:	8b 55 0c             	mov    0xc(%ebp),%edx
  800496:	89 d1                	mov    %edx,%ecx
  800498:	89 c2                	mov    %eax,%edx
  80049a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80049d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8004a3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004b0:	39 c2                	cmp    %eax,%edx
  8004b2:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8004b5:	72 3e                	jb     8004f5 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004b7:	83 ec 0c             	sub    $0xc,%esp
  8004ba:	ff 75 18             	pushl  0x18(%ebp)
  8004bd:	83 eb 01             	sub    $0x1,%ebx
  8004c0:	53                   	push   %ebx
  8004c1:	50                   	push   %eax
  8004c2:	83 ec 08             	sub    $0x8,%esp
  8004c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004cb:	ff 75 dc             	pushl  -0x24(%ebp)
  8004ce:	ff 75 d8             	pushl  -0x28(%ebp)
  8004d1:	e8 1a 09 00 00       	call   800df0 <__udivdi3>
  8004d6:	83 c4 18             	add    $0x18,%esp
  8004d9:	52                   	push   %edx
  8004da:	50                   	push   %eax
  8004db:	89 f2                	mov    %esi,%edx
  8004dd:	89 f8                	mov    %edi,%eax
  8004df:	e8 9f ff ff ff       	call   800483 <printnum>
  8004e4:	83 c4 20             	add    $0x20,%esp
  8004e7:	eb 13                	jmp    8004fc <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	56                   	push   %esi
  8004ed:	ff 75 18             	pushl  0x18(%ebp)
  8004f0:	ff d7                	call   *%edi
  8004f2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004f5:	83 eb 01             	sub    $0x1,%ebx
  8004f8:	85 db                	test   %ebx,%ebx
  8004fa:	7f ed                	jg     8004e9 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	56                   	push   %esi
  800500:	83 ec 04             	sub    $0x4,%esp
  800503:	ff 75 e4             	pushl  -0x1c(%ebp)
  800506:	ff 75 e0             	pushl  -0x20(%ebp)
  800509:	ff 75 dc             	pushl  -0x24(%ebp)
  80050c:	ff 75 d8             	pushl  -0x28(%ebp)
  80050f:	e8 ec 09 00 00       	call   800f00 <__umoddi3>
  800514:	83 c4 14             	add    $0x14,%esp
  800517:	0f be 80 bd 10 80 00 	movsbl 0x8010bd(%eax),%eax
  80051e:	50                   	push   %eax
  80051f:	ff d7                	call   *%edi
}
  800521:	83 c4 10             	add    $0x10,%esp
  800524:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800527:	5b                   	pop    %ebx
  800528:	5e                   	pop    %esi
  800529:	5f                   	pop    %edi
  80052a:	5d                   	pop    %ebp
  80052b:	c3                   	ret    

0080052c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80052c:	f3 0f 1e fb          	endbr32 
  800530:	55                   	push   %ebp
  800531:	89 e5                	mov    %esp,%ebp
  800533:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800536:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80053a:	8b 10                	mov    (%eax),%edx
  80053c:	3b 50 04             	cmp    0x4(%eax),%edx
  80053f:	73 0a                	jae    80054b <sprintputch+0x1f>
		*b->buf++ = ch;
  800541:	8d 4a 01             	lea    0x1(%edx),%ecx
  800544:	89 08                	mov    %ecx,(%eax)
  800546:	8b 45 08             	mov    0x8(%ebp),%eax
  800549:	88 02                	mov    %al,(%edx)
}
  80054b:	5d                   	pop    %ebp
  80054c:	c3                   	ret    

0080054d <printfmt>:
{
  80054d:	f3 0f 1e fb          	endbr32 
  800551:	55                   	push   %ebp
  800552:	89 e5                	mov    %esp,%ebp
  800554:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800557:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80055a:	50                   	push   %eax
  80055b:	ff 75 10             	pushl  0x10(%ebp)
  80055e:	ff 75 0c             	pushl  0xc(%ebp)
  800561:	ff 75 08             	pushl  0x8(%ebp)
  800564:	e8 05 00 00 00       	call   80056e <vprintfmt>
}
  800569:	83 c4 10             	add    $0x10,%esp
  80056c:	c9                   	leave  
  80056d:	c3                   	ret    

0080056e <vprintfmt>:
{
  80056e:	f3 0f 1e fb          	endbr32 
  800572:	55                   	push   %ebp
  800573:	89 e5                	mov    %esp,%ebp
  800575:	57                   	push   %edi
  800576:	56                   	push   %esi
  800577:	53                   	push   %ebx
  800578:	83 ec 3c             	sub    $0x3c,%esp
  80057b:	8b 75 08             	mov    0x8(%ebp),%esi
  80057e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800581:	8b 7d 10             	mov    0x10(%ebp),%edi
  800584:	e9 4a 03 00 00       	jmp    8008d3 <vprintfmt+0x365>
		padc = ' ';
  800589:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80058d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800594:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80059b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8005a2:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005a7:	8d 47 01             	lea    0x1(%edi),%eax
  8005aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005ad:	0f b6 17             	movzbl (%edi),%edx
  8005b0:	8d 42 dd             	lea    -0x23(%edx),%eax
  8005b3:	3c 55                	cmp    $0x55,%al
  8005b5:	0f 87 de 03 00 00    	ja     800999 <vprintfmt+0x42b>
  8005bb:	0f b6 c0             	movzbl %al,%eax
  8005be:	3e ff 24 85 00 12 80 	notrack jmp *0x801200(,%eax,4)
  8005c5:	00 
  8005c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005c9:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005cd:	eb d8                	jmp    8005a7 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d2:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005d6:	eb cf                	jmp    8005a7 <vprintfmt+0x39>
  8005d8:	0f b6 d2             	movzbl %dl,%edx
  8005db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005de:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005e6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005e9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005ed:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005f0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005f3:	83 f9 09             	cmp    $0x9,%ecx
  8005f6:	77 55                	ja     80064d <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005f8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005fb:	eb e9                	jmp    8005e6 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8b 00                	mov    (%eax),%eax
  800602:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8d 40 04             	lea    0x4(%eax),%eax
  80060b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80060e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800611:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800615:	79 90                	jns    8005a7 <vprintfmt+0x39>
				width = precision, precision = -1;
  800617:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80061d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800624:	eb 81                	jmp    8005a7 <vprintfmt+0x39>
  800626:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800629:	85 c0                	test   %eax,%eax
  80062b:	ba 00 00 00 00       	mov    $0x0,%edx
  800630:	0f 49 d0             	cmovns %eax,%edx
  800633:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800636:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800639:	e9 69 ff ff ff       	jmp    8005a7 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80063e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800641:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800648:	e9 5a ff ff ff       	jmp    8005a7 <vprintfmt+0x39>
  80064d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800650:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800653:	eb bc                	jmp    800611 <vprintfmt+0xa3>
			lflag++;
  800655:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800658:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80065b:	e9 47 ff ff ff       	jmp    8005a7 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8d 78 04             	lea    0x4(%eax),%edi
  800666:	83 ec 08             	sub    $0x8,%esp
  800669:	53                   	push   %ebx
  80066a:	ff 30                	pushl  (%eax)
  80066c:	ff d6                	call   *%esi
			break;
  80066e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800671:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800674:	e9 57 02 00 00       	jmp    8008d0 <vprintfmt+0x362>
			err = va_arg(ap, int);
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	8d 78 04             	lea    0x4(%eax),%edi
  80067f:	8b 00                	mov    (%eax),%eax
  800681:	99                   	cltd   
  800682:	31 d0                	xor    %edx,%eax
  800684:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800686:	83 f8 0f             	cmp    $0xf,%eax
  800689:	7f 23                	jg     8006ae <vprintfmt+0x140>
  80068b:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  800692:	85 d2                	test   %edx,%edx
  800694:	74 18                	je     8006ae <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800696:	52                   	push   %edx
  800697:	68 de 10 80 00       	push   $0x8010de
  80069c:	53                   	push   %ebx
  80069d:	56                   	push   %esi
  80069e:	e8 aa fe ff ff       	call   80054d <printfmt>
  8006a3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006a6:	89 7d 14             	mov    %edi,0x14(%ebp)
  8006a9:	e9 22 02 00 00       	jmp    8008d0 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8006ae:	50                   	push   %eax
  8006af:	68 d5 10 80 00       	push   $0x8010d5
  8006b4:	53                   	push   %ebx
  8006b5:	56                   	push   %esi
  8006b6:	e8 92 fe ff ff       	call   80054d <printfmt>
  8006bb:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006be:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8006c1:	e9 0a 02 00 00       	jmp    8008d0 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	83 c0 04             	add    $0x4,%eax
  8006cc:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8006d4:	85 d2                	test   %edx,%edx
  8006d6:	b8 ce 10 80 00       	mov    $0x8010ce,%eax
  8006db:	0f 45 c2             	cmovne %edx,%eax
  8006de:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006e1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006e5:	7e 06                	jle    8006ed <vprintfmt+0x17f>
  8006e7:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006eb:	75 0d                	jne    8006fa <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ed:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006f0:	89 c7                	mov    %eax,%edi
  8006f2:	03 45 e0             	add    -0x20(%ebp),%eax
  8006f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f8:	eb 55                	jmp    80074f <vprintfmt+0x1e1>
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	ff 75 d8             	pushl  -0x28(%ebp)
  800700:	ff 75 cc             	pushl  -0x34(%ebp)
  800703:	e8 45 03 00 00       	call   800a4d <strnlen>
  800708:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80070b:	29 c2                	sub    %eax,%edx
  80070d:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800710:	83 c4 10             	add    $0x10,%esp
  800713:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800715:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800719:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80071c:	85 ff                	test   %edi,%edi
  80071e:	7e 11                	jle    800731 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800720:	83 ec 08             	sub    $0x8,%esp
  800723:	53                   	push   %ebx
  800724:	ff 75 e0             	pushl  -0x20(%ebp)
  800727:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800729:	83 ef 01             	sub    $0x1,%edi
  80072c:	83 c4 10             	add    $0x10,%esp
  80072f:	eb eb                	jmp    80071c <vprintfmt+0x1ae>
  800731:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800734:	85 d2                	test   %edx,%edx
  800736:	b8 00 00 00 00       	mov    $0x0,%eax
  80073b:	0f 49 c2             	cmovns %edx,%eax
  80073e:	29 c2                	sub    %eax,%edx
  800740:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800743:	eb a8                	jmp    8006ed <vprintfmt+0x17f>
					putch(ch, putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	53                   	push   %ebx
  800749:	52                   	push   %edx
  80074a:	ff d6                	call   *%esi
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800752:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800754:	83 c7 01             	add    $0x1,%edi
  800757:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80075b:	0f be d0             	movsbl %al,%edx
  80075e:	85 d2                	test   %edx,%edx
  800760:	74 4b                	je     8007ad <vprintfmt+0x23f>
  800762:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800766:	78 06                	js     80076e <vprintfmt+0x200>
  800768:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80076c:	78 1e                	js     80078c <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80076e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800772:	74 d1                	je     800745 <vprintfmt+0x1d7>
  800774:	0f be c0             	movsbl %al,%eax
  800777:	83 e8 20             	sub    $0x20,%eax
  80077a:	83 f8 5e             	cmp    $0x5e,%eax
  80077d:	76 c6                	jbe    800745 <vprintfmt+0x1d7>
					putch('?', putdat);
  80077f:	83 ec 08             	sub    $0x8,%esp
  800782:	53                   	push   %ebx
  800783:	6a 3f                	push   $0x3f
  800785:	ff d6                	call   *%esi
  800787:	83 c4 10             	add    $0x10,%esp
  80078a:	eb c3                	jmp    80074f <vprintfmt+0x1e1>
  80078c:	89 cf                	mov    %ecx,%edi
  80078e:	eb 0e                	jmp    80079e <vprintfmt+0x230>
				putch(' ', putdat);
  800790:	83 ec 08             	sub    $0x8,%esp
  800793:	53                   	push   %ebx
  800794:	6a 20                	push   $0x20
  800796:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800798:	83 ef 01             	sub    $0x1,%edi
  80079b:	83 c4 10             	add    $0x10,%esp
  80079e:	85 ff                	test   %edi,%edi
  8007a0:	7f ee                	jg     800790 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8007a2:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007a5:	89 45 14             	mov    %eax,0x14(%ebp)
  8007a8:	e9 23 01 00 00       	jmp    8008d0 <vprintfmt+0x362>
  8007ad:	89 cf                	mov    %ecx,%edi
  8007af:	eb ed                	jmp    80079e <vprintfmt+0x230>
	if (lflag >= 2)
  8007b1:	83 f9 01             	cmp    $0x1,%ecx
  8007b4:	7f 1b                	jg     8007d1 <vprintfmt+0x263>
	else if (lflag)
  8007b6:	85 c9                	test   %ecx,%ecx
  8007b8:	74 63                	je     80081d <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8007ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bd:	8b 00                	mov    (%eax),%eax
  8007bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c2:	99                   	cltd   
  8007c3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	8d 40 04             	lea    0x4(%eax),%eax
  8007cc:	89 45 14             	mov    %eax,0x14(%ebp)
  8007cf:	eb 17                	jmp    8007e8 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8007d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d4:	8b 50 04             	mov    0x4(%eax),%edx
  8007d7:	8b 00                	mov    (%eax),%eax
  8007d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	8d 40 08             	lea    0x8(%eax),%eax
  8007e5:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007e8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007eb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007ee:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007f3:	85 c9                	test   %ecx,%ecx
  8007f5:	0f 89 bb 00 00 00    	jns    8008b6 <vprintfmt+0x348>
				putch('-', putdat);
  8007fb:	83 ec 08             	sub    $0x8,%esp
  8007fe:	53                   	push   %ebx
  8007ff:	6a 2d                	push   $0x2d
  800801:	ff d6                	call   *%esi
				num = -(long long) num;
  800803:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800806:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800809:	f7 da                	neg    %edx
  80080b:	83 d1 00             	adc    $0x0,%ecx
  80080e:	f7 d9                	neg    %ecx
  800810:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800813:	b8 0a 00 00 00       	mov    $0xa,%eax
  800818:	e9 99 00 00 00       	jmp    8008b6 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80081d:	8b 45 14             	mov    0x14(%ebp),%eax
  800820:	8b 00                	mov    (%eax),%eax
  800822:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800825:	99                   	cltd   
  800826:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800829:	8b 45 14             	mov    0x14(%ebp),%eax
  80082c:	8d 40 04             	lea    0x4(%eax),%eax
  80082f:	89 45 14             	mov    %eax,0x14(%ebp)
  800832:	eb b4                	jmp    8007e8 <vprintfmt+0x27a>
	if (lflag >= 2)
  800834:	83 f9 01             	cmp    $0x1,%ecx
  800837:	7f 1b                	jg     800854 <vprintfmt+0x2e6>
	else if (lflag)
  800839:	85 c9                	test   %ecx,%ecx
  80083b:	74 2c                	je     800869 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80083d:	8b 45 14             	mov    0x14(%ebp),%eax
  800840:	8b 10                	mov    (%eax),%edx
  800842:	b9 00 00 00 00       	mov    $0x0,%ecx
  800847:	8d 40 04             	lea    0x4(%eax),%eax
  80084a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80084d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800852:	eb 62                	jmp    8008b6 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800854:	8b 45 14             	mov    0x14(%ebp),%eax
  800857:	8b 10                	mov    (%eax),%edx
  800859:	8b 48 04             	mov    0x4(%eax),%ecx
  80085c:	8d 40 08             	lea    0x8(%eax),%eax
  80085f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800862:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800867:	eb 4d                	jmp    8008b6 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800869:	8b 45 14             	mov    0x14(%ebp),%eax
  80086c:	8b 10                	mov    (%eax),%edx
  80086e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800873:	8d 40 04             	lea    0x4(%eax),%eax
  800876:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800879:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80087e:	eb 36                	jmp    8008b6 <vprintfmt+0x348>
	if (lflag >= 2)
  800880:	83 f9 01             	cmp    $0x1,%ecx
  800883:	7f 17                	jg     80089c <vprintfmt+0x32e>
	else if (lflag)
  800885:	85 c9                	test   %ecx,%ecx
  800887:	74 6e                	je     8008f7 <vprintfmt+0x389>
		return va_arg(*ap, long);
  800889:	8b 45 14             	mov    0x14(%ebp),%eax
  80088c:	8b 10                	mov    (%eax),%edx
  80088e:	89 d0                	mov    %edx,%eax
  800890:	99                   	cltd   
  800891:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800894:	8d 49 04             	lea    0x4(%ecx),%ecx
  800897:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80089a:	eb 11                	jmp    8008ad <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  80089c:	8b 45 14             	mov    0x14(%ebp),%eax
  80089f:	8b 50 04             	mov    0x4(%eax),%edx
  8008a2:	8b 00                	mov    (%eax),%eax
  8008a4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008a7:	8d 49 08             	lea    0x8(%ecx),%ecx
  8008aa:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8008ad:	89 d1                	mov    %edx,%ecx
  8008af:	89 c2                	mov    %eax,%edx
            base = 8;
  8008b1:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008b6:	83 ec 0c             	sub    $0xc,%esp
  8008b9:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008bd:	57                   	push   %edi
  8008be:	ff 75 e0             	pushl  -0x20(%ebp)
  8008c1:	50                   	push   %eax
  8008c2:	51                   	push   %ecx
  8008c3:	52                   	push   %edx
  8008c4:	89 da                	mov    %ebx,%edx
  8008c6:	89 f0                	mov    %esi,%eax
  8008c8:	e8 b6 fb ff ff       	call   800483 <printnum>
			break;
  8008cd:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008d3:	83 c7 01             	add    $0x1,%edi
  8008d6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008da:	83 f8 25             	cmp    $0x25,%eax
  8008dd:	0f 84 a6 fc ff ff    	je     800589 <vprintfmt+0x1b>
			if (ch == '\0')
  8008e3:	85 c0                	test   %eax,%eax
  8008e5:	0f 84 ce 00 00 00    	je     8009b9 <vprintfmt+0x44b>
			putch(ch, putdat);
  8008eb:	83 ec 08             	sub    $0x8,%esp
  8008ee:	53                   	push   %ebx
  8008ef:	50                   	push   %eax
  8008f0:	ff d6                	call   *%esi
  8008f2:	83 c4 10             	add    $0x10,%esp
  8008f5:	eb dc                	jmp    8008d3 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8008f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fa:	8b 10                	mov    (%eax),%edx
  8008fc:	89 d0                	mov    %edx,%eax
  8008fe:	99                   	cltd   
  8008ff:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800902:	8d 49 04             	lea    0x4(%ecx),%ecx
  800905:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800908:	eb a3                	jmp    8008ad <vprintfmt+0x33f>
			putch('0', putdat);
  80090a:	83 ec 08             	sub    $0x8,%esp
  80090d:	53                   	push   %ebx
  80090e:	6a 30                	push   $0x30
  800910:	ff d6                	call   *%esi
			putch('x', putdat);
  800912:	83 c4 08             	add    $0x8,%esp
  800915:	53                   	push   %ebx
  800916:	6a 78                	push   $0x78
  800918:	ff d6                	call   *%esi
			num = (unsigned long long)
  80091a:	8b 45 14             	mov    0x14(%ebp),%eax
  80091d:	8b 10                	mov    (%eax),%edx
  80091f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800924:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800927:	8d 40 04             	lea    0x4(%eax),%eax
  80092a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80092d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800932:	eb 82                	jmp    8008b6 <vprintfmt+0x348>
	if (lflag >= 2)
  800934:	83 f9 01             	cmp    $0x1,%ecx
  800937:	7f 1e                	jg     800957 <vprintfmt+0x3e9>
	else if (lflag)
  800939:	85 c9                	test   %ecx,%ecx
  80093b:	74 32                	je     80096f <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80093d:	8b 45 14             	mov    0x14(%ebp),%eax
  800940:	8b 10                	mov    (%eax),%edx
  800942:	b9 00 00 00 00       	mov    $0x0,%ecx
  800947:	8d 40 04             	lea    0x4(%eax),%eax
  80094a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80094d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800952:	e9 5f ff ff ff       	jmp    8008b6 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800957:	8b 45 14             	mov    0x14(%ebp),%eax
  80095a:	8b 10                	mov    (%eax),%edx
  80095c:	8b 48 04             	mov    0x4(%eax),%ecx
  80095f:	8d 40 08             	lea    0x8(%eax),%eax
  800962:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800965:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80096a:	e9 47 ff ff ff       	jmp    8008b6 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80096f:	8b 45 14             	mov    0x14(%ebp),%eax
  800972:	8b 10                	mov    (%eax),%edx
  800974:	b9 00 00 00 00       	mov    $0x0,%ecx
  800979:	8d 40 04             	lea    0x4(%eax),%eax
  80097c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80097f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800984:	e9 2d ff ff ff       	jmp    8008b6 <vprintfmt+0x348>
			putch(ch, putdat);
  800989:	83 ec 08             	sub    $0x8,%esp
  80098c:	53                   	push   %ebx
  80098d:	6a 25                	push   $0x25
  80098f:	ff d6                	call   *%esi
			break;
  800991:	83 c4 10             	add    $0x10,%esp
  800994:	e9 37 ff ff ff       	jmp    8008d0 <vprintfmt+0x362>
			putch('%', putdat);
  800999:	83 ec 08             	sub    $0x8,%esp
  80099c:	53                   	push   %ebx
  80099d:	6a 25                	push   $0x25
  80099f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009a1:	83 c4 10             	add    $0x10,%esp
  8009a4:	89 f8                	mov    %edi,%eax
  8009a6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009aa:	74 05                	je     8009b1 <vprintfmt+0x443>
  8009ac:	83 e8 01             	sub    $0x1,%eax
  8009af:	eb f5                	jmp    8009a6 <vprintfmt+0x438>
  8009b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009b4:	e9 17 ff ff ff       	jmp    8008d0 <vprintfmt+0x362>
}
  8009b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009bc:	5b                   	pop    %ebx
  8009bd:	5e                   	pop    %esi
  8009be:	5f                   	pop    %edi
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009c1:	f3 0f 1e fb          	endbr32 
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	83 ec 18             	sub    $0x18,%esp
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009d4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009d8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009e2:	85 c0                	test   %eax,%eax
  8009e4:	74 26                	je     800a0c <vsnprintf+0x4b>
  8009e6:	85 d2                	test   %edx,%edx
  8009e8:	7e 22                	jle    800a0c <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009ea:	ff 75 14             	pushl  0x14(%ebp)
  8009ed:	ff 75 10             	pushl  0x10(%ebp)
  8009f0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009f3:	50                   	push   %eax
  8009f4:	68 2c 05 80 00       	push   $0x80052c
  8009f9:	e8 70 fb ff ff       	call   80056e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a01:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a07:	83 c4 10             	add    $0x10,%esp
}
  800a0a:	c9                   	leave  
  800a0b:	c3                   	ret    
		return -E_INVAL;
  800a0c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a11:	eb f7                	jmp    800a0a <vsnprintf+0x49>

00800a13 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a13:	f3 0f 1e fb          	endbr32 
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a1d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a20:	50                   	push   %eax
  800a21:	ff 75 10             	pushl  0x10(%ebp)
  800a24:	ff 75 0c             	pushl  0xc(%ebp)
  800a27:	ff 75 08             	pushl  0x8(%ebp)
  800a2a:	e8 92 ff ff ff       	call   8009c1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a2f:	c9                   	leave  
  800a30:	c3                   	ret    

00800a31 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a31:	f3 0f 1e fb          	endbr32 
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a40:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a44:	74 05                	je     800a4b <strlen+0x1a>
		n++;
  800a46:	83 c0 01             	add    $0x1,%eax
  800a49:	eb f5                	jmp    800a40 <strlen+0xf>
	return n;
}
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a4d:	f3 0f 1e fb          	endbr32 
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a57:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5f:	39 d0                	cmp    %edx,%eax
  800a61:	74 0d                	je     800a70 <strnlen+0x23>
  800a63:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a67:	74 05                	je     800a6e <strnlen+0x21>
		n++;
  800a69:	83 c0 01             	add    $0x1,%eax
  800a6c:	eb f1                	jmp    800a5f <strnlen+0x12>
  800a6e:	89 c2                	mov    %eax,%edx
	return n;
}
  800a70:	89 d0                	mov    %edx,%eax
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a74:	f3 0f 1e fb          	endbr32 
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	53                   	push   %ebx
  800a7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a82:	b8 00 00 00 00       	mov    $0x0,%eax
  800a87:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a8b:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a8e:	83 c0 01             	add    $0x1,%eax
  800a91:	84 d2                	test   %dl,%dl
  800a93:	75 f2                	jne    800a87 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a95:	89 c8                	mov    %ecx,%eax
  800a97:	5b                   	pop    %ebx
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a9a:	f3 0f 1e fb          	endbr32 
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	53                   	push   %ebx
  800aa2:	83 ec 10             	sub    $0x10,%esp
  800aa5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aa8:	53                   	push   %ebx
  800aa9:	e8 83 ff ff ff       	call   800a31 <strlen>
  800aae:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800ab1:	ff 75 0c             	pushl  0xc(%ebp)
  800ab4:	01 d8                	add    %ebx,%eax
  800ab6:	50                   	push   %eax
  800ab7:	e8 b8 ff ff ff       	call   800a74 <strcpy>
	return dst;
}
  800abc:	89 d8                	mov    %ebx,%eax
  800abe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ac1:	c9                   	leave  
  800ac2:	c3                   	ret    

00800ac3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ac3:	f3 0f 1e fb          	endbr32 
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	56                   	push   %esi
  800acb:	53                   	push   %ebx
  800acc:	8b 75 08             	mov    0x8(%ebp),%esi
  800acf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad2:	89 f3                	mov    %esi,%ebx
  800ad4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ad7:	89 f0                	mov    %esi,%eax
  800ad9:	39 d8                	cmp    %ebx,%eax
  800adb:	74 11                	je     800aee <strncpy+0x2b>
		*dst++ = *src;
  800add:	83 c0 01             	add    $0x1,%eax
  800ae0:	0f b6 0a             	movzbl (%edx),%ecx
  800ae3:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ae6:	80 f9 01             	cmp    $0x1,%cl
  800ae9:	83 da ff             	sbb    $0xffffffff,%edx
  800aec:	eb eb                	jmp    800ad9 <strncpy+0x16>
	}
	return ret;
}
  800aee:	89 f0                	mov    %esi,%eax
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800af4:	f3 0f 1e fb          	endbr32 
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	8b 75 08             	mov    0x8(%ebp),%esi
  800b00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b03:	8b 55 10             	mov    0x10(%ebp),%edx
  800b06:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b08:	85 d2                	test   %edx,%edx
  800b0a:	74 21                	je     800b2d <strlcpy+0x39>
  800b0c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b10:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b12:	39 c2                	cmp    %eax,%edx
  800b14:	74 14                	je     800b2a <strlcpy+0x36>
  800b16:	0f b6 19             	movzbl (%ecx),%ebx
  800b19:	84 db                	test   %bl,%bl
  800b1b:	74 0b                	je     800b28 <strlcpy+0x34>
			*dst++ = *src++;
  800b1d:	83 c1 01             	add    $0x1,%ecx
  800b20:	83 c2 01             	add    $0x1,%edx
  800b23:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b26:	eb ea                	jmp    800b12 <strlcpy+0x1e>
  800b28:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b2a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b2d:	29 f0                	sub    %esi,%eax
}
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b33:	f3 0f 1e fb          	endbr32 
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b3d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b40:	0f b6 01             	movzbl (%ecx),%eax
  800b43:	84 c0                	test   %al,%al
  800b45:	74 0c                	je     800b53 <strcmp+0x20>
  800b47:	3a 02                	cmp    (%edx),%al
  800b49:	75 08                	jne    800b53 <strcmp+0x20>
		p++, q++;
  800b4b:	83 c1 01             	add    $0x1,%ecx
  800b4e:	83 c2 01             	add    $0x1,%edx
  800b51:	eb ed                	jmp    800b40 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b53:	0f b6 c0             	movzbl %al,%eax
  800b56:	0f b6 12             	movzbl (%edx),%edx
  800b59:	29 d0                	sub    %edx,%eax
}
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b5d:	f3 0f 1e fb          	endbr32 
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	53                   	push   %ebx
  800b65:	8b 45 08             	mov    0x8(%ebp),%eax
  800b68:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6b:	89 c3                	mov    %eax,%ebx
  800b6d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b70:	eb 06                	jmp    800b78 <strncmp+0x1b>
		n--, p++, q++;
  800b72:	83 c0 01             	add    $0x1,%eax
  800b75:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b78:	39 d8                	cmp    %ebx,%eax
  800b7a:	74 16                	je     800b92 <strncmp+0x35>
  800b7c:	0f b6 08             	movzbl (%eax),%ecx
  800b7f:	84 c9                	test   %cl,%cl
  800b81:	74 04                	je     800b87 <strncmp+0x2a>
  800b83:	3a 0a                	cmp    (%edx),%cl
  800b85:	74 eb                	je     800b72 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b87:	0f b6 00             	movzbl (%eax),%eax
  800b8a:	0f b6 12             	movzbl (%edx),%edx
  800b8d:	29 d0                	sub    %edx,%eax
}
  800b8f:	5b                   	pop    %ebx
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    
		return 0;
  800b92:	b8 00 00 00 00       	mov    $0x0,%eax
  800b97:	eb f6                	jmp    800b8f <strncmp+0x32>

00800b99 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b99:	f3 0f 1e fb          	endbr32 
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ba7:	0f b6 10             	movzbl (%eax),%edx
  800baa:	84 d2                	test   %dl,%dl
  800bac:	74 09                	je     800bb7 <strchr+0x1e>
		if (*s == c)
  800bae:	38 ca                	cmp    %cl,%dl
  800bb0:	74 0a                	je     800bbc <strchr+0x23>
	for (; *s; s++)
  800bb2:	83 c0 01             	add    $0x1,%eax
  800bb5:	eb f0                	jmp    800ba7 <strchr+0xe>
			return (char *) s;
	return 0;
  800bb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bbe:	f3 0f 1e fb          	endbr32 
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bcc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bcf:	38 ca                	cmp    %cl,%dl
  800bd1:	74 09                	je     800bdc <strfind+0x1e>
  800bd3:	84 d2                	test   %dl,%dl
  800bd5:	74 05                	je     800bdc <strfind+0x1e>
	for (; *s; s++)
  800bd7:	83 c0 01             	add    $0x1,%eax
  800bda:	eb f0                	jmp    800bcc <strfind+0xe>
			break;
	return (char *) s;
}
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bde:	f3 0f 1e fb          	endbr32 
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800beb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bee:	85 c9                	test   %ecx,%ecx
  800bf0:	74 31                	je     800c23 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bf2:	89 f8                	mov    %edi,%eax
  800bf4:	09 c8                	or     %ecx,%eax
  800bf6:	a8 03                	test   $0x3,%al
  800bf8:	75 23                	jne    800c1d <memset+0x3f>
		c &= 0xFF;
  800bfa:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bfe:	89 d3                	mov    %edx,%ebx
  800c00:	c1 e3 08             	shl    $0x8,%ebx
  800c03:	89 d0                	mov    %edx,%eax
  800c05:	c1 e0 18             	shl    $0x18,%eax
  800c08:	89 d6                	mov    %edx,%esi
  800c0a:	c1 e6 10             	shl    $0x10,%esi
  800c0d:	09 f0                	or     %esi,%eax
  800c0f:	09 c2                	or     %eax,%edx
  800c11:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c13:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c16:	89 d0                	mov    %edx,%eax
  800c18:	fc                   	cld    
  800c19:	f3 ab                	rep stos %eax,%es:(%edi)
  800c1b:	eb 06                	jmp    800c23 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c20:	fc                   	cld    
  800c21:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c23:	89 f8                	mov    %edi,%eax
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5f                   	pop    %edi
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c2a:	f3 0f 1e fb          	endbr32 
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	8b 45 08             	mov    0x8(%ebp),%eax
  800c36:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c39:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c3c:	39 c6                	cmp    %eax,%esi
  800c3e:	73 32                	jae    800c72 <memmove+0x48>
  800c40:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c43:	39 c2                	cmp    %eax,%edx
  800c45:	76 2b                	jbe    800c72 <memmove+0x48>
		s += n;
		d += n;
  800c47:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c4a:	89 fe                	mov    %edi,%esi
  800c4c:	09 ce                	or     %ecx,%esi
  800c4e:	09 d6                	or     %edx,%esi
  800c50:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c56:	75 0e                	jne    800c66 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c58:	83 ef 04             	sub    $0x4,%edi
  800c5b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c5e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c61:	fd                   	std    
  800c62:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c64:	eb 09                	jmp    800c6f <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c66:	83 ef 01             	sub    $0x1,%edi
  800c69:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c6c:	fd                   	std    
  800c6d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c6f:	fc                   	cld    
  800c70:	eb 1a                	jmp    800c8c <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c72:	89 c2                	mov    %eax,%edx
  800c74:	09 ca                	or     %ecx,%edx
  800c76:	09 f2                	or     %esi,%edx
  800c78:	f6 c2 03             	test   $0x3,%dl
  800c7b:	75 0a                	jne    800c87 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c7d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c80:	89 c7                	mov    %eax,%edi
  800c82:	fc                   	cld    
  800c83:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c85:	eb 05                	jmp    800c8c <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c87:	89 c7                	mov    %eax,%edi
  800c89:	fc                   	cld    
  800c8a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c90:	f3 0f 1e fb          	endbr32 
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c9a:	ff 75 10             	pushl  0x10(%ebp)
  800c9d:	ff 75 0c             	pushl  0xc(%ebp)
  800ca0:	ff 75 08             	pushl  0x8(%ebp)
  800ca3:	e8 82 ff ff ff       	call   800c2a <memmove>
}
  800ca8:	c9                   	leave  
  800ca9:	c3                   	ret    

00800caa <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800caa:	f3 0f 1e fb          	endbr32 
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cb9:	89 c6                	mov    %eax,%esi
  800cbb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cbe:	39 f0                	cmp    %esi,%eax
  800cc0:	74 1c                	je     800cde <memcmp+0x34>
		if (*s1 != *s2)
  800cc2:	0f b6 08             	movzbl (%eax),%ecx
  800cc5:	0f b6 1a             	movzbl (%edx),%ebx
  800cc8:	38 d9                	cmp    %bl,%cl
  800cca:	75 08                	jne    800cd4 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ccc:	83 c0 01             	add    $0x1,%eax
  800ccf:	83 c2 01             	add    $0x1,%edx
  800cd2:	eb ea                	jmp    800cbe <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800cd4:	0f b6 c1             	movzbl %cl,%eax
  800cd7:	0f b6 db             	movzbl %bl,%ebx
  800cda:	29 d8                	sub    %ebx,%eax
  800cdc:	eb 05                	jmp    800ce3 <memcmp+0x39>
	}

	return 0;
  800cde:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ce7:	f3 0f 1e fb          	endbr32 
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cf4:	89 c2                	mov    %eax,%edx
  800cf6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cf9:	39 d0                	cmp    %edx,%eax
  800cfb:	73 09                	jae    800d06 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cfd:	38 08                	cmp    %cl,(%eax)
  800cff:	74 05                	je     800d06 <memfind+0x1f>
	for (; s < ends; s++)
  800d01:	83 c0 01             	add    $0x1,%eax
  800d04:	eb f3                	jmp    800cf9 <memfind+0x12>
			break;
	return (void *) s;
}
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d08:	f3 0f 1e fb          	endbr32 
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	57                   	push   %edi
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
  800d12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d18:	eb 03                	jmp    800d1d <strtol+0x15>
		s++;
  800d1a:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d1d:	0f b6 01             	movzbl (%ecx),%eax
  800d20:	3c 20                	cmp    $0x20,%al
  800d22:	74 f6                	je     800d1a <strtol+0x12>
  800d24:	3c 09                	cmp    $0x9,%al
  800d26:	74 f2                	je     800d1a <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d28:	3c 2b                	cmp    $0x2b,%al
  800d2a:	74 2a                	je     800d56 <strtol+0x4e>
	int neg = 0;
  800d2c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d31:	3c 2d                	cmp    $0x2d,%al
  800d33:	74 2b                	je     800d60 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d35:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d3b:	75 0f                	jne    800d4c <strtol+0x44>
  800d3d:	80 39 30             	cmpb   $0x30,(%ecx)
  800d40:	74 28                	je     800d6a <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d42:	85 db                	test   %ebx,%ebx
  800d44:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d49:	0f 44 d8             	cmove  %eax,%ebx
  800d4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d51:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d54:	eb 46                	jmp    800d9c <strtol+0x94>
		s++;
  800d56:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d59:	bf 00 00 00 00       	mov    $0x0,%edi
  800d5e:	eb d5                	jmp    800d35 <strtol+0x2d>
		s++, neg = 1;
  800d60:	83 c1 01             	add    $0x1,%ecx
  800d63:	bf 01 00 00 00       	mov    $0x1,%edi
  800d68:	eb cb                	jmp    800d35 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d6a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d6e:	74 0e                	je     800d7e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d70:	85 db                	test   %ebx,%ebx
  800d72:	75 d8                	jne    800d4c <strtol+0x44>
		s++, base = 8;
  800d74:	83 c1 01             	add    $0x1,%ecx
  800d77:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d7c:	eb ce                	jmp    800d4c <strtol+0x44>
		s += 2, base = 16;
  800d7e:	83 c1 02             	add    $0x2,%ecx
  800d81:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d86:	eb c4                	jmp    800d4c <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d88:	0f be d2             	movsbl %dl,%edx
  800d8b:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d8e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d91:	7d 3a                	jge    800dcd <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d93:	83 c1 01             	add    $0x1,%ecx
  800d96:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d9a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d9c:	0f b6 11             	movzbl (%ecx),%edx
  800d9f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800da2:	89 f3                	mov    %esi,%ebx
  800da4:	80 fb 09             	cmp    $0x9,%bl
  800da7:	76 df                	jbe    800d88 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800da9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800dac:	89 f3                	mov    %esi,%ebx
  800dae:	80 fb 19             	cmp    $0x19,%bl
  800db1:	77 08                	ja     800dbb <strtol+0xb3>
			dig = *s - 'a' + 10;
  800db3:	0f be d2             	movsbl %dl,%edx
  800db6:	83 ea 57             	sub    $0x57,%edx
  800db9:	eb d3                	jmp    800d8e <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800dbb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dbe:	89 f3                	mov    %esi,%ebx
  800dc0:	80 fb 19             	cmp    $0x19,%bl
  800dc3:	77 08                	ja     800dcd <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dc5:	0f be d2             	movsbl %dl,%edx
  800dc8:	83 ea 37             	sub    $0x37,%edx
  800dcb:	eb c1                	jmp    800d8e <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dcd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dd1:	74 05                	je     800dd8 <strtol+0xd0>
		*endptr = (char *) s;
  800dd3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dd6:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800dd8:	89 c2                	mov    %eax,%edx
  800dda:	f7 da                	neg    %edx
  800ddc:	85 ff                	test   %edi,%edi
  800dde:	0f 45 c2             	cmovne %edx,%eax
}
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    
  800de6:	66 90                	xchg   %ax,%ax
  800de8:	66 90                	xchg   %ax,%ax
  800dea:	66 90                	xchg   %ax,%ax
  800dec:	66 90                	xchg   %ax,%ax
  800dee:	66 90                	xchg   %ax,%ax

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
