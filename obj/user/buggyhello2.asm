
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 21 00 00 00       	call   800052 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  80003d:	68 00 00 10 00       	push   $0x100000
  800042:	ff 35 00 30 80 00    	pushl  0x803000
  800048:	e8 77 00 00 00       	call   8000c4 <sys_cputs>
}
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	c9                   	leave  
  800051:	c3                   	ret    

00800052 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800052:	f3 0f 1e fb          	endbr32 
  800056:	55                   	push   %ebp
  800057:	89 e5                	mov    %esp,%ebp
  800059:	56                   	push   %esi
  80005a:	53                   	push   %ebx
  80005b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800061:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800068:	00 00 00 
    envid_t envid = sys_getenvid();
  80006b:	e8 de 00 00 00       	call   80014e <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x3b>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 0a 00 00 00       	call   8000a6 <exit>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	f3 0f 1e fb          	endbr32 
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b0:	e8 df 04 00 00       	call   800594 <close_all>
	sys_env_destroy(0);
  8000b5:	83 ec 0c             	sub    $0xc,%esp
  8000b8:	6a 00                	push   $0x0
  8000ba:	e8 4a 00 00 00       	call   800109 <sys_env_destroy>
}
  8000bf:	83 c4 10             	add    $0x10,%esp
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c4:	f3 0f 1e fb          	endbr32 
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d9:	89 c3                	mov    %eax,%ebx
  8000db:	89 c7                	mov    %eax,%edi
  8000dd:	89 c6                	mov    %eax,%esi
  8000df:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e1:	5b                   	pop    %ebx
  8000e2:	5e                   	pop    %esi
  8000e3:	5f                   	pop    %edi
  8000e4:	5d                   	pop    %ebp
  8000e5:	c3                   	ret    

008000e6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e6:	f3 0f 1e fb          	endbr32 
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	57                   	push   %edi
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000fa:	89 d1                	mov    %edx,%ecx
  8000fc:	89 d3                	mov    %edx,%ebx
  8000fe:	89 d7                	mov    %edx,%edi
  800100:	89 d6                	mov    %edx,%esi
  800102:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800104:	5b                   	pop    %ebx
  800105:	5e                   	pop    %esi
  800106:	5f                   	pop    %edi
  800107:	5d                   	pop    %ebp
  800108:	c3                   	ret    

00800109 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800109:	f3 0f 1e fb          	endbr32 
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	57                   	push   %edi
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800116:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011b:	8b 55 08             	mov    0x8(%ebp),%edx
  80011e:	b8 03 00 00 00       	mov    $0x3,%eax
  800123:	89 cb                	mov    %ecx,%ebx
  800125:	89 cf                	mov    %ecx,%edi
  800127:	89 ce                	mov    %ecx,%esi
  800129:	cd 30                	int    $0x30
	if(check && ret > 0)
  80012b:	85 c0                	test   %eax,%eax
  80012d:	7f 08                	jg     800137 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800137:	83 ec 0c             	sub    $0xc,%esp
  80013a:	50                   	push   %eax
  80013b:	6a 03                	push   $0x3
  80013d:	68 18 1f 80 00       	push   $0x801f18
  800142:	6a 23                	push   $0x23
  800144:	68 35 1f 80 00       	push   $0x801f35
  800149:	e8 9c 0f 00 00       	call   8010ea <_panic>

0080014e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014e:	f3 0f 1e fb          	endbr32 
  800152:	55                   	push   %ebp
  800153:	89 e5                	mov    %esp,%ebp
  800155:	57                   	push   %edi
  800156:	56                   	push   %esi
  800157:	53                   	push   %ebx
	asm volatile("int %1\n"
  800158:	ba 00 00 00 00       	mov    $0x0,%edx
  80015d:	b8 02 00 00 00       	mov    $0x2,%eax
  800162:	89 d1                	mov    %edx,%ecx
  800164:	89 d3                	mov    %edx,%ebx
  800166:	89 d7                	mov    %edx,%edi
  800168:	89 d6                	mov    %edx,%esi
  80016a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016c:	5b                   	pop    %ebx
  80016d:	5e                   	pop    %esi
  80016e:	5f                   	pop    %edi
  80016f:	5d                   	pop    %ebp
  800170:	c3                   	ret    

00800171 <sys_yield>:

void
sys_yield(void)
{
  800171:	f3 0f 1e fb          	endbr32 
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	57                   	push   %edi
  800179:	56                   	push   %esi
  80017a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80017b:	ba 00 00 00 00       	mov    $0x0,%edx
  800180:	b8 0b 00 00 00       	mov    $0xb,%eax
  800185:	89 d1                	mov    %edx,%ecx
  800187:	89 d3                	mov    %edx,%ebx
  800189:	89 d7                	mov    %edx,%edi
  80018b:	89 d6                	mov    %edx,%esi
  80018d:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80018f:	5b                   	pop    %ebx
  800190:	5e                   	pop    %esi
  800191:	5f                   	pop    %edi
  800192:	5d                   	pop    %ebp
  800193:	c3                   	ret    

00800194 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800194:	f3 0f 1e fb          	endbr32 
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a1:	be 00 00 00 00       	mov    $0x0,%esi
  8001a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ac:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b4:	89 f7                	mov    %esi,%edi
  8001b6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	7f 08                	jg     8001c4 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 04                	push   $0x4
  8001ca:	68 18 1f 80 00       	push   $0x801f18
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 35 1f 80 00       	push   $0x801f35
  8001d6:	e8 0f 0f 00 00       	call   8010ea <_panic>

008001db <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001db:	f3 0f 1e fb          	endbr32 
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f9:	8b 75 18             	mov    0x18(%ebp),%esi
  8001fc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001fe:	85 c0                	test   %eax,%eax
  800200:	7f 08                	jg     80020a <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800202:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800205:	5b                   	pop    %ebx
  800206:	5e                   	pop    %esi
  800207:	5f                   	pop    %edi
  800208:	5d                   	pop    %ebp
  800209:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80020a:	83 ec 0c             	sub    $0xc,%esp
  80020d:	50                   	push   %eax
  80020e:	6a 05                	push   $0x5
  800210:	68 18 1f 80 00       	push   $0x801f18
  800215:	6a 23                	push   $0x23
  800217:	68 35 1f 80 00       	push   $0x801f35
  80021c:	e8 c9 0e 00 00       	call   8010ea <_panic>

00800221 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800221:	f3 0f 1e fb          	endbr32 
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800239:	b8 06 00 00 00       	mov    $0x6,%eax
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7f 08                	jg     800250 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5f                   	pop    %edi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	50                   	push   %eax
  800254:	6a 06                	push   $0x6
  800256:	68 18 1f 80 00       	push   $0x801f18
  80025b:	6a 23                	push   $0x23
  80025d:	68 35 1f 80 00       	push   $0x801f35
  800262:	e8 83 0e 00 00       	call   8010ea <_panic>

00800267 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800267:	f3 0f 1e fb          	endbr32 
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	57                   	push   %edi
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800274:	bb 00 00 00 00       	mov    $0x0,%ebx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
  80027c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027f:	b8 08 00 00 00       	mov    $0x8,%eax
  800284:	89 df                	mov    %ebx,%edi
  800286:	89 de                	mov    %ebx,%esi
  800288:	cd 30                	int    $0x30
	if(check && ret > 0)
  80028a:	85 c0                	test   %eax,%eax
  80028c:	7f 08                	jg     800296 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80028e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800291:	5b                   	pop    %ebx
  800292:	5e                   	pop    %esi
  800293:	5f                   	pop    %edi
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	50                   	push   %eax
  80029a:	6a 08                	push   $0x8
  80029c:	68 18 1f 80 00       	push   $0x801f18
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 35 1f 80 00       	push   $0x801f35
  8002a8:	e8 3d 0e 00 00       	call   8010ea <_panic>

008002ad <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002ad:	f3 0f 1e fb          	endbr32 
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c5:	b8 09 00 00 00       	mov    $0x9,%eax
  8002ca:	89 df                	mov    %ebx,%edi
  8002cc:	89 de                	mov    %ebx,%esi
  8002ce:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	7f 08                	jg     8002dc <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d7:	5b                   	pop    %ebx
  8002d8:	5e                   	pop    %esi
  8002d9:	5f                   	pop    %edi
  8002da:	5d                   	pop    %ebp
  8002db:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002dc:	83 ec 0c             	sub    $0xc,%esp
  8002df:	50                   	push   %eax
  8002e0:	6a 09                	push   $0x9
  8002e2:	68 18 1f 80 00       	push   $0x801f18
  8002e7:	6a 23                	push   $0x23
  8002e9:	68 35 1f 80 00       	push   $0x801f35
  8002ee:	e8 f7 0d 00 00       	call   8010ea <_panic>

008002f3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002f3:	f3 0f 1e fb          	endbr32 
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
  8002fd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800300:	bb 00 00 00 00       	mov    $0x0,%ebx
  800305:	8b 55 08             	mov    0x8(%ebp),%edx
  800308:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800310:	89 df                	mov    %ebx,%edi
  800312:	89 de                	mov    %ebx,%esi
  800314:	cd 30                	int    $0x30
	if(check && ret > 0)
  800316:	85 c0                	test   %eax,%eax
  800318:	7f 08                	jg     800322 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80031a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80031d:	5b                   	pop    %ebx
  80031e:	5e                   	pop    %esi
  80031f:	5f                   	pop    %edi
  800320:	5d                   	pop    %ebp
  800321:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800322:	83 ec 0c             	sub    $0xc,%esp
  800325:	50                   	push   %eax
  800326:	6a 0a                	push   $0xa
  800328:	68 18 1f 80 00       	push   $0x801f18
  80032d:	6a 23                	push   $0x23
  80032f:	68 35 1f 80 00       	push   $0x801f35
  800334:	e8 b1 0d 00 00       	call   8010ea <_panic>

00800339 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800339:	f3 0f 1e fb          	endbr32 
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	57                   	push   %edi
  800341:	56                   	push   %esi
  800342:	53                   	push   %ebx
	asm volatile("int %1\n"
  800343:	8b 55 08             	mov    0x8(%ebp),%edx
  800346:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800349:	b8 0c 00 00 00       	mov    $0xc,%eax
  80034e:	be 00 00 00 00       	mov    $0x0,%esi
  800353:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800356:	8b 7d 14             	mov    0x14(%ebp),%edi
  800359:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80035b:	5b                   	pop    %ebx
  80035c:	5e                   	pop    %esi
  80035d:	5f                   	pop    %edi
  80035e:	5d                   	pop    %ebp
  80035f:	c3                   	ret    

00800360 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800360:	f3 0f 1e fb          	endbr32 
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	57                   	push   %edi
  800368:	56                   	push   %esi
  800369:	53                   	push   %ebx
  80036a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80036d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800372:	8b 55 08             	mov    0x8(%ebp),%edx
  800375:	b8 0d 00 00 00       	mov    $0xd,%eax
  80037a:	89 cb                	mov    %ecx,%ebx
  80037c:	89 cf                	mov    %ecx,%edi
  80037e:	89 ce                	mov    %ecx,%esi
  800380:	cd 30                	int    $0x30
	if(check && ret > 0)
  800382:	85 c0                	test   %eax,%eax
  800384:	7f 08                	jg     80038e <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800386:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800389:	5b                   	pop    %ebx
  80038a:	5e                   	pop    %esi
  80038b:	5f                   	pop    %edi
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80038e:	83 ec 0c             	sub    $0xc,%esp
  800391:	50                   	push   %eax
  800392:	6a 0d                	push   $0xd
  800394:	68 18 1f 80 00       	push   $0x801f18
  800399:	6a 23                	push   $0x23
  80039b:	68 35 1f 80 00       	push   $0x801f35
  8003a0:	e8 45 0d 00 00       	call   8010ea <_panic>

008003a5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003a5:	f3 0f 1e fb          	endbr32 
  8003a9:	55                   	push   %ebp
  8003aa:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8003af:	05 00 00 00 30       	add    $0x30000000,%eax
  8003b4:	c1 e8 0c             	shr    $0xc,%eax
}
  8003b7:	5d                   	pop    %ebp
  8003b8:	c3                   	ret    

008003b9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003b9:	f3 0f 1e fb          	endbr32 
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c3:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003cd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003d2:	5d                   	pop    %ebp
  8003d3:	c3                   	ret    

008003d4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003d4:	f3 0f 1e fb          	endbr32 
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 16             	shr    $0x16,%edx
  8003e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 2d                	je     80041e <fd_alloc+0x4a>
  8003f1:	89 c2                	mov    %eax,%edx
  8003f3:	c1 ea 0c             	shr    $0xc,%edx
  8003f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fd:	f6 c2 01             	test   $0x1,%dl
  800400:	74 1c                	je     80041e <fd_alloc+0x4a>
  800402:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800407:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80040c:	75 d2                	jne    8003e0 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80040e:	8b 45 08             	mov    0x8(%ebp),%eax
  800411:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800417:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80041c:	eb 0a                	jmp    800428 <fd_alloc+0x54>
			*fd_store = fd;
  80041e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800421:	89 01                	mov    %eax,(%ecx)
			return 0;
  800423:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800428:	5d                   	pop    %ebp
  800429:	c3                   	ret    

0080042a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80042a:	f3 0f 1e fb          	endbr32 
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800434:	83 f8 1f             	cmp    $0x1f,%eax
  800437:	77 30                	ja     800469 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800439:	c1 e0 0c             	shl    $0xc,%eax
  80043c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800441:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800447:	f6 c2 01             	test   $0x1,%dl
  80044a:	74 24                	je     800470 <fd_lookup+0x46>
  80044c:	89 c2                	mov    %eax,%edx
  80044e:	c1 ea 0c             	shr    $0xc,%edx
  800451:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800458:	f6 c2 01             	test   $0x1,%dl
  80045b:	74 1a                	je     800477 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80045d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800460:	89 02                	mov    %eax,(%edx)
	return 0;
  800462:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800467:	5d                   	pop    %ebp
  800468:	c3                   	ret    
		return -E_INVAL;
  800469:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80046e:	eb f7                	jmp    800467 <fd_lookup+0x3d>
		return -E_INVAL;
  800470:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800475:	eb f0                	jmp    800467 <fd_lookup+0x3d>
  800477:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80047c:	eb e9                	jmp    800467 <fd_lookup+0x3d>

0080047e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80047e:	f3 0f 1e fb          	endbr32 
  800482:	55                   	push   %ebp
  800483:	89 e5                	mov    %esp,%ebp
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80048b:	ba c0 1f 80 00       	mov    $0x801fc0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800490:	b8 08 30 80 00       	mov    $0x803008,%eax
		if (devtab[i]->dev_id == dev_id) {
  800495:	39 08                	cmp    %ecx,(%eax)
  800497:	74 33                	je     8004cc <dev_lookup+0x4e>
  800499:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80049c:	8b 02                	mov    (%edx),%eax
  80049e:	85 c0                	test   %eax,%eax
  8004a0:	75 f3                	jne    800495 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004a2:	a1 04 40 80 00       	mov    0x804004,%eax
  8004a7:	8b 40 48             	mov    0x48(%eax),%eax
  8004aa:	83 ec 04             	sub    $0x4,%esp
  8004ad:	51                   	push   %ecx
  8004ae:	50                   	push   %eax
  8004af:	68 44 1f 80 00       	push   $0x801f44
  8004b4:	e8 18 0d 00 00       	call   8011d1 <cprintf>
	*dev = 0;
  8004b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004bc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004c2:	83 c4 10             	add    $0x10,%esp
  8004c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ca:	c9                   	leave  
  8004cb:	c3                   	ret    
			*dev = devtab[i];
  8004cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004cf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d6:	eb f2                	jmp    8004ca <dev_lookup+0x4c>

008004d8 <fd_close>:
{
  8004d8:	f3 0f 1e fb          	endbr32 
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	57                   	push   %edi
  8004e0:	56                   	push   %esi
  8004e1:	53                   	push   %ebx
  8004e2:	83 ec 24             	sub    $0x24,%esp
  8004e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004eb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004ee:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004ef:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004f5:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004f8:	50                   	push   %eax
  8004f9:	e8 2c ff ff ff       	call   80042a <fd_lookup>
  8004fe:	89 c3                	mov    %eax,%ebx
  800500:	83 c4 10             	add    $0x10,%esp
  800503:	85 c0                	test   %eax,%eax
  800505:	78 05                	js     80050c <fd_close+0x34>
	    || fd != fd2)
  800507:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80050a:	74 16                	je     800522 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80050c:	89 f8                	mov    %edi,%eax
  80050e:	84 c0                	test   %al,%al
  800510:	b8 00 00 00 00       	mov    $0x0,%eax
  800515:	0f 44 d8             	cmove  %eax,%ebx
}
  800518:	89 d8                	mov    %ebx,%eax
  80051a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80051d:	5b                   	pop    %ebx
  80051e:	5e                   	pop    %esi
  80051f:	5f                   	pop    %edi
  800520:	5d                   	pop    %ebp
  800521:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800522:	83 ec 08             	sub    $0x8,%esp
  800525:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800528:	50                   	push   %eax
  800529:	ff 36                	pushl  (%esi)
  80052b:	e8 4e ff ff ff       	call   80047e <dev_lookup>
  800530:	89 c3                	mov    %eax,%ebx
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	85 c0                	test   %eax,%eax
  800537:	78 1a                	js     800553 <fd_close+0x7b>
		if (dev->dev_close)
  800539:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80053c:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80053f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800544:	85 c0                	test   %eax,%eax
  800546:	74 0b                	je     800553 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800548:	83 ec 0c             	sub    $0xc,%esp
  80054b:	56                   	push   %esi
  80054c:	ff d0                	call   *%eax
  80054e:	89 c3                	mov    %eax,%ebx
  800550:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	56                   	push   %esi
  800557:	6a 00                	push   $0x0
  800559:	e8 c3 fc ff ff       	call   800221 <sys_page_unmap>
	return r;
  80055e:	83 c4 10             	add    $0x10,%esp
  800561:	eb b5                	jmp    800518 <fd_close+0x40>

00800563 <close>:

int
close(int fdnum)
{
  800563:	f3 0f 1e fb          	endbr32 
  800567:	55                   	push   %ebp
  800568:	89 e5                	mov    %esp,%ebp
  80056a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80056d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800570:	50                   	push   %eax
  800571:	ff 75 08             	pushl  0x8(%ebp)
  800574:	e8 b1 fe ff ff       	call   80042a <fd_lookup>
  800579:	83 c4 10             	add    $0x10,%esp
  80057c:	85 c0                	test   %eax,%eax
  80057e:	79 02                	jns    800582 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800580:	c9                   	leave  
  800581:	c3                   	ret    
		return fd_close(fd, 1);
  800582:	83 ec 08             	sub    $0x8,%esp
  800585:	6a 01                	push   $0x1
  800587:	ff 75 f4             	pushl  -0xc(%ebp)
  80058a:	e8 49 ff ff ff       	call   8004d8 <fd_close>
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	eb ec                	jmp    800580 <close+0x1d>

00800594 <close_all>:

void
close_all(void)
{
  800594:	f3 0f 1e fb          	endbr32 
  800598:	55                   	push   %ebp
  800599:	89 e5                	mov    %esp,%ebp
  80059b:	53                   	push   %ebx
  80059c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80059f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005a4:	83 ec 0c             	sub    $0xc,%esp
  8005a7:	53                   	push   %ebx
  8005a8:	e8 b6 ff ff ff       	call   800563 <close>
	for (i = 0; i < MAXFD; i++)
  8005ad:	83 c3 01             	add    $0x1,%ebx
  8005b0:	83 c4 10             	add    $0x10,%esp
  8005b3:	83 fb 20             	cmp    $0x20,%ebx
  8005b6:	75 ec                	jne    8005a4 <close_all+0x10>
}
  8005b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005bb:	c9                   	leave  
  8005bc:	c3                   	ret    

008005bd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005bd:	f3 0f 1e fb          	endbr32 
  8005c1:	55                   	push   %ebp
  8005c2:	89 e5                	mov    %esp,%ebp
  8005c4:	57                   	push   %edi
  8005c5:	56                   	push   %esi
  8005c6:	53                   	push   %ebx
  8005c7:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005ca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005cd:	50                   	push   %eax
  8005ce:	ff 75 08             	pushl  0x8(%ebp)
  8005d1:	e8 54 fe ff ff       	call   80042a <fd_lookup>
  8005d6:	89 c3                	mov    %eax,%ebx
  8005d8:	83 c4 10             	add    $0x10,%esp
  8005db:	85 c0                	test   %eax,%eax
  8005dd:	0f 88 81 00 00 00    	js     800664 <dup+0xa7>
		return r;
	close(newfdnum);
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	ff 75 0c             	pushl  0xc(%ebp)
  8005e9:	e8 75 ff ff ff       	call   800563 <close>

	newfd = INDEX2FD(newfdnum);
  8005ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005f1:	c1 e6 0c             	shl    $0xc,%esi
  8005f4:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005fa:	83 c4 04             	add    $0x4,%esp
  8005fd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800600:	e8 b4 fd ff ff       	call   8003b9 <fd2data>
  800605:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800607:	89 34 24             	mov    %esi,(%esp)
  80060a:	e8 aa fd ff ff       	call   8003b9 <fd2data>
  80060f:	83 c4 10             	add    $0x10,%esp
  800612:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800614:	89 d8                	mov    %ebx,%eax
  800616:	c1 e8 16             	shr    $0x16,%eax
  800619:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800620:	a8 01                	test   $0x1,%al
  800622:	74 11                	je     800635 <dup+0x78>
  800624:	89 d8                	mov    %ebx,%eax
  800626:	c1 e8 0c             	shr    $0xc,%eax
  800629:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800630:	f6 c2 01             	test   $0x1,%dl
  800633:	75 39                	jne    80066e <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800635:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800638:	89 d0                	mov    %edx,%eax
  80063a:	c1 e8 0c             	shr    $0xc,%eax
  80063d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800644:	83 ec 0c             	sub    $0xc,%esp
  800647:	25 07 0e 00 00       	and    $0xe07,%eax
  80064c:	50                   	push   %eax
  80064d:	56                   	push   %esi
  80064e:	6a 00                	push   $0x0
  800650:	52                   	push   %edx
  800651:	6a 00                	push   $0x0
  800653:	e8 83 fb ff ff       	call   8001db <sys_page_map>
  800658:	89 c3                	mov    %eax,%ebx
  80065a:	83 c4 20             	add    $0x20,%esp
  80065d:	85 c0                	test   %eax,%eax
  80065f:	78 31                	js     800692 <dup+0xd5>
		goto err;

	return newfdnum;
  800661:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800664:	89 d8                	mov    %ebx,%eax
  800666:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800669:	5b                   	pop    %ebx
  80066a:	5e                   	pop    %esi
  80066b:	5f                   	pop    %edi
  80066c:	5d                   	pop    %ebp
  80066d:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80066e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800675:	83 ec 0c             	sub    $0xc,%esp
  800678:	25 07 0e 00 00       	and    $0xe07,%eax
  80067d:	50                   	push   %eax
  80067e:	57                   	push   %edi
  80067f:	6a 00                	push   $0x0
  800681:	53                   	push   %ebx
  800682:	6a 00                	push   $0x0
  800684:	e8 52 fb ff ff       	call   8001db <sys_page_map>
  800689:	89 c3                	mov    %eax,%ebx
  80068b:	83 c4 20             	add    $0x20,%esp
  80068e:	85 c0                	test   %eax,%eax
  800690:	79 a3                	jns    800635 <dup+0x78>
	sys_page_unmap(0, newfd);
  800692:	83 ec 08             	sub    $0x8,%esp
  800695:	56                   	push   %esi
  800696:	6a 00                	push   $0x0
  800698:	e8 84 fb ff ff       	call   800221 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80069d:	83 c4 08             	add    $0x8,%esp
  8006a0:	57                   	push   %edi
  8006a1:	6a 00                	push   $0x0
  8006a3:	e8 79 fb ff ff       	call   800221 <sys_page_unmap>
	return r;
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	eb b7                	jmp    800664 <dup+0xa7>

008006ad <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006ad:	f3 0f 1e fb          	endbr32 
  8006b1:	55                   	push   %ebp
  8006b2:	89 e5                	mov    %esp,%ebp
  8006b4:	53                   	push   %ebx
  8006b5:	83 ec 1c             	sub    $0x1c,%esp
  8006b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006be:	50                   	push   %eax
  8006bf:	53                   	push   %ebx
  8006c0:	e8 65 fd ff ff       	call   80042a <fd_lookup>
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	85 c0                	test   %eax,%eax
  8006ca:	78 3f                	js     80070b <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006cc:	83 ec 08             	sub    $0x8,%esp
  8006cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006d2:	50                   	push   %eax
  8006d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006d6:	ff 30                	pushl  (%eax)
  8006d8:	e8 a1 fd ff ff       	call   80047e <dev_lookup>
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	78 27                	js     80070b <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006e7:	8b 42 08             	mov    0x8(%edx),%eax
  8006ea:	83 e0 03             	and    $0x3,%eax
  8006ed:	83 f8 01             	cmp    $0x1,%eax
  8006f0:	74 1e                	je     800710 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f5:	8b 40 08             	mov    0x8(%eax),%eax
  8006f8:	85 c0                	test   %eax,%eax
  8006fa:	74 35                	je     800731 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006fc:	83 ec 04             	sub    $0x4,%esp
  8006ff:	ff 75 10             	pushl  0x10(%ebp)
  800702:	ff 75 0c             	pushl  0xc(%ebp)
  800705:	52                   	push   %edx
  800706:	ff d0                	call   *%eax
  800708:	83 c4 10             	add    $0x10,%esp
}
  80070b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800710:	a1 04 40 80 00       	mov    0x804004,%eax
  800715:	8b 40 48             	mov    0x48(%eax),%eax
  800718:	83 ec 04             	sub    $0x4,%esp
  80071b:	53                   	push   %ebx
  80071c:	50                   	push   %eax
  80071d:	68 85 1f 80 00       	push   $0x801f85
  800722:	e8 aa 0a 00 00       	call   8011d1 <cprintf>
		return -E_INVAL;
  800727:	83 c4 10             	add    $0x10,%esp
  80072a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80072f:	eb da                	jmp    80070b <read+0x5e>
		return -E_NOT_SUPP;
  800731:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800736:	eb d3                	jmp    80070b <read+0x5e>

00800738 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800738:	f3 0f 1e fb          	endbr32 
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	57                   	push   %edi
  800740:	56                   	push   %esi
  800741:	53                   	push   %ebx
  800742:	83 ec 0c             	sub    $0xc,%esp
  800745:	8b 7d 08             	mov    0x8(%ebp),%edi
  800748:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80074b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800750:	eb 02                	jmp    800754 <readn+0x1c>
  800752:	01 c3                	add    %eax,%ebx
  800754:	39 f3                	cmp    %esi,%ebx
  800756:	73 21                	jae    800779 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800758:	83 ec 04             	sub    $0x4,%esp
  80075b:	89 f0                	mov    %esi,%eax
  80075d:	29 d8                	sub    %ebx,%eax
  80075f:	50                   	push   %eax
  800760:	89 d8                	mov    %ebx,%eax
  800762:	03 45 0c             	add    0xc(%ebp),%eax
  800765:	50                   	push   %eax
  800766:	57                   	push   %edi
  800767:	e8 41 ff ff ff       	call   8006ad <read>
		if (m < 0)
  80076c:	83 c4 10             	add    $0x10,%esp
  80076f:	85 c0                	test   %eax,%eax
  800771:	78 04                	js     800777 <readn+0x3f>
			return m;
		if (m == 0)
  800773:	75 dd                	jne    800752 <readn+0x1a>
  800775:	eb 02                	jmp    800779 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800777:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800779:	89 d8                	mov    %ebx,%eax
  80077b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80077e:	5b                   	pop    %ebx
  80077f:	5e                   	pop    %esi
  800780:	5f                   	pop    %edi
  800781:	5d                   	pop    %ebp
  800782:	c3                   	ret    

00800783 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800783:	f3 0f 1e fb          	endbr32 
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	53                   	push   %ebx
  80078b:	83 ec 1c             	sub    $0x1c,%esp
  80078e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800791:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800794:	50                   	push   %eax
  800795:	53                   	push   %ebx
  800796:	e8 8f fc ff ff       	call   80042a <fd_lookup>
  80079b:	83 c4 10             	add    $0x10,%esp
  80079e:	85 c0                	test   %eax,%eax
  8007a0:	78 3a                	js     8007dc <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a2:	83 ec 08             	sub    $0x8,%esp
  8007a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007a8:	50                   	push   %eax
  8007a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ac:	ff 30                	pushl  (%eax)
  8007ae:	e8 cb fc ff ff       	call   80047e <dev_lookup>
  8007b3:	83 c4 10             	add    $0x10,%esp
  8007b6:	85 c0                	test   %eax,%eax
  8007b8:	78 22                	js     8007dc <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007bd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007c1:	74 1e                	je     8007e1 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007c6:	8b 52 0c             	mov    0xc(%edx),%edx
  8007c9:	85 d2                	test   %edx,%edx
  8007cb:	74 35                	je     800802 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007cd:	83 ec 04             	sub    $0x4,%esp
  8007d0:	ff 75 10             	pushl  0x10(%ebp)
  8007d3:	ff 75 0c             	pushl  0xc(%ebp)
  8007d6:	50                   	push   %eax
  8007d7:	ff d2                	call   *%edx
  8007d9:	83 c4 10             	add    $0x10,%esp
}
  8007dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007df:	c9                   	leave  
  8007e0:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007e1:	a1 04 40 80 00       	mov    0x804004,%eax
  8007e6:	8b 40 48             	mov    0x48(%eax),%eax
  8007e9:	83 ec 04             	sub    $0x4,%esp
  8007ec:	53                   	push   %ebx
  8007ed:	50                   	push   %eax
  8007ee:	68 a1 1f 80 00       	push   $0x801fa1
  8007f3:	e8 d9 09 00 00       	call   8011d1 <cprintf>
		return -E_INVAL;
  8007f8:	83 c4 10             	add    $0x10,%esp
  8007fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800800:	eb da                	jmp    8007dc <write+0x59>
		return -E_NOT_SUPP;
  800802:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800807:	eb d3                	jmp    8007dc <write+0x59>

00800809 <seek>:

int
seek(int fdnum, off_t offset)
{
  800809:	f3 0f 1e fb          	endbr32 
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800813:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800816:	50                   	push   %eax
  800817:	ff 75 08             	pushl  0x8(%ebp)
  80081a:	e8 0b fc ff ff       	call   80042a <fd_lookup>
  80081f:	83 c4 10             	add    $0x10,%esp
  800822:	85 c0                	test   %eax,%eax
  800824:	78 0e                	js     800834 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  800826:	8b 55 0c             	mov    0xc(%ebp),%edx
  800829:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80082f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800834:	c9                   	leave  
  800835:	c3                   	ret    

00800836 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800836:	f3 0f 1e fb          	endbr32 
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	83 ec 1c             	sub    $0x1c,%esp
  800841:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800844:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800847:	50                   	push   %eax
  800848:	53                   	push   %ebx
  800849:	e8 dc fb ff ff       	call   80042a <fd_lookup>
  80084e:	83 c4 10             	add    $0x10,%esp
  800851:	85 c0                	test   %eax,%eax
  800853:	78 37                	js     80088c <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800855:	83 ec 08             	sub    $0x8,%esp
  800858:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085b:	50                   	push   %eax
  80085c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80085f:	ff 30                	pushl  (%eax)
  800861:	e8 18 fc ff ff       	call   80047e <dev_lookup>
  800866:	83 c4 10             	add    $0x10,%esp
  800869:	85 c0                	test   %eax,%eax
  80086b:	78 1f                	js     80088c <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80086d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800870:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800874:	74 1b                	je     800891 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800876:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800879:	8b 52 18             	mov    0x18(%edx),%edx
  80087c:	85 d2                	test   %edx,%edx
  80087e:	74 32                	je     8008b2 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800880:	83 ec 08             	sub    $0x8,%esp
  800883:	ff 75 0c             	pushl  0xc(%ebp)
  800886:	50                   	push   %eax
  800887:	ff d2                	call   *%edx
  800889:	83 c4 10             	add    $0x10,%esp
}
  80088c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088f:	c9                   	leave  
  800890:	c3                   	ret    
			thisenv->env_id, fdnum);
  800891:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800896:	8b 40 48             	mov    0x48(%eax),%eax
  800899:	83 ec 04             	sub    $0x4,%esp
  80089c:	53                   	push   %ebx
  80089d:	50                   	push   %eax
  80089e:	68 64 1f 80 00       	push   $0x801f64
  8008a3:	e8 29 09 00 00       	call   8011d1 <cprintf>
		return -E_INVAL;
  8008a8:	83 c4 10             	add    $0x10,%esp
  8008ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008b0:	eb da                	jmp    80088c <ftruncate+0x56>
		return -E_NOT_SUPP;
  8008b2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008b7:	eb d3                	jmp    80088c <ftruncate+0x56>

008008b9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008b9:	f3 0f 1e fb          	endbr32 
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	53                   	push   %ebx
  8008c1:	83 ec 1c             	sub    $0x1c,%esp
  8008c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008ca:	50                   	push   %eax
  8008cb:	ff 75 08             	pushl  0x8(%ebp)
  8008ce:	e8 57 fb ff ff       	call   80042a <fd_lookup>
  8008d3:	83 c4 10             	add    $0x10,%esp
  8008d6:	85 c0                	test   %eax,%eax
  8008d8:	78 4b                	js     800925 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008da:	83 ec 08             	sub    $0x8,%esp
  8008dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008e0:	50                   	push   %eax
  8008e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008e4:	ff 30                	pushl  (%eax)
  8008e6:	e8 93 fb ff ff       	call   80047e <dev_lookup>
  8008eb:	83 c4 10             	add    $0x10,%esp
  8008ee:	85 c0                	test   %eax,%eax
  8008f0:	78 33                	js     800925 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8008f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008f5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008f9:	74 2f                	je     80092a <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008fb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008fe:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800905:	00 00 00 
	stat->st_isdir = 0;
  800908:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80090f:	00 00 00 
	stat->st_dev = dev;
  800912:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800918:	83 ec 08             	sub    $0x8,%esp
  80091b:	53                   	push   %ebx
  80091c:	ff 75 f0             	pushl  -0x10(%ebp)
  80091f:	ff 50 14             	call   *0x14(%eax)
  800922:	83 c4 10             	add    $0x10,%esp
}
  800925:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800928:	c9                   	leave  
  800929:	c3                   	ret    
		return -E_NOT_SUPP;
  80092a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80092f:	eb f4                	jmp    800925 <fstat+0x6c>

00800931 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800931:	f3 0f 1e fb          	endbr32 
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	56                   	push   %esi
  800939:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80093a:	83 ec 08             	sub    $0x8,%esp
  80093d:	6a 00                	push   $0x0
  80093f:	ff 75 08             	pushl  0x8(%ebp)
  800942:	e8 fb 01 00 00       	call   800b42 <open>
  800947:	89 c3                	mov    %eax,%ebx
  800949:	83 c4 10             	add    $0x10,%esp
  80094c:	85 c0                	test   %eax,%eax
  80094e:	78 1b                	js     80096b <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  800950:	83 ec 08             	sub    $0x8,%esp
  800953:	ff 75 0c             	pushl  0xc(%ebp)
  800956:	50                   	push   %eax
  800957:	e8 5d ff ff ff       	call   8008b9 <fstat>
  80095c:	89 c6                	mov    %eax,%esi
	close(fd);
  80095e:	89 1c 24             	mov    %ebx,(%esp)
  800961:	e8 fd fb ff ff       	call   800563 <close>
	return r;
  800966:	83 c4 10             	add    $0x10,%esp
  800969:	89 f3                	mov    %esi,%ebx
}
  80096b:	89 d8                	mov    %ebx,%eax
  80096d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800970:	5b                   	pop    %ebx
  800971:	5e                   	pop    %esi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	56                   	push   %esi
  800978:	53                   	push   %ebx
  800979:	89 c6                	mov    %eax,%esi
  80097b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80097d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800984:	74 27                	je     8009ad <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800986:	6a 07                	push   $0x7
  800988:	68 00 50 80 00       	push   $0x805000
  80098d:	56                   	push   %esi
  80098e:	ff 35 00 40 80 00    	pushl  0x804000
  800994:	e8 0a 12 00 00       	call   801ba3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800999:	83 c4 0c             	add    $0xc,%esp
  80099c:	6a 00                	push   $0x0
  80099e:	53                   	push   %ebx
  80099f:	6a 00                	push   $0x0
  8009a1:	e8 a6 11 00 00       	call   801b4c <ipc_recv>
}
  8009a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009a9:	5b                   	pop    %ebx
  8009aa:	5e                   	pop    %esi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009ad:	83 ec 0c             	sub    $0xc,%esp
  8009b0:	6a 01                	push   $0x1
  8009b2:	e8 52 12 00 00       	call   801c09 <ipc_find_env>
  8009b7:	a3 00 40 80 00       	mov    %eax,0x804000
  8009bc:	83 c4 10             	add    $0x10,%esp
  8009bf:	eb c5                	jmp    800986 <fsipc+0x12>

008009c1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009c1:	f3 0f 1e fb          	endbr32 
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009de:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e3:	b8 02 00 00 00       	mov    $0x2,%eax
  8009e8:	e8 87 ff ff ff       	call   800974 <fsipc>
}
  8009ed:	c9                   	leave  
  8009ee:	c3                   	ret    

008009ef <devfile_flush>:
{
  8009ef:	f3 0f 1e fb          	endbr32 
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ff:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a04:	ba 00 00 00 00       	mov    $0x0,%edx
  800a09:	b8 06 00 00 00       	mov    $0x6,%eax
  800a0e:	e8 61 ff ff ff       	call   800974 <fsipc>
}
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <devfile_stat>:
{
  800a15:	f3 0f 1e fb          	endbr32 
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	53                   	push   %ebx
  800a1d:	83 ec 04             	sub    $0x4,%esp
  800a20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	8b 40 0c             	mov    0xc(%eax),%eax
  800a29:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a33:	b8 05 00 00 00       	mov    $0x5,%eax
  800a38:	e8 37 ff ff ff       	call   800974 <fsipc>
  800a3d:	85 c0                	test   %eax,%eax
  800a3f:	78 2c                	js     800a6d <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a41:	83 ec 08             	sub    $0x8,%esp
  800a44:	68 00 50 80 00       	push   $0x805000
  800a49:	53                   	push   %ebx
  800a4a:	e8 8b 0d 00 00       	call   8017da <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a4f:	a1 80 50 80 00       	mov    0x805080,%eax
  800a54:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a5a:	a1 84 50 80 00       	mov    0x805084,%eax
  800a5f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a65:	83 c4 10             	add    $0x10,%esp
  800a68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a70:	c9                   	leave  
  800a71:	c3                   	ret    

00800a72 <devfile_write>:
{
  800a72:	f3 0f 1e fb          	endbr32 
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	83 ec 0c             	sub    $0xc,%esp
  800a7c:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  800a7f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a84:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a89:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8f:	8b 52 0c             	mov    0xc(%edx),%edx
  800a92:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a98:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a9d:	50                   	push   %eax
  800a9e:	ff 75 0c             	pushl  0xc(%ebp)
  800aa1:	68 08 50 80 00       	push   $0x805008
  800aa6:	e8 e5 0e 00 00       	call   801990 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800aab:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab0:	b8 04 00 00 00       	mov    $0x4,%eax
  800ab5:	e8 ba fe ff ff       	call   800974 <fsipc>
}
  800aba:	c9                   	leave  
  800abb:	c3                   	ret    

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
  800ae3:	e8 8c fe ff ff       	call   800974 <fsipc>
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
  800b16:	68 d0 1f 80 00       	push   $0x801fd0
  800b1b:	68 d7 1f 80 00       	push   $0x801fd7
  800b20:	6a 7c                	push   $0x7c
  800b22:	68 ec 1f 80 00       	push   $0x801fec
  800b27:	e8 be 05 00 00       	call   8010ea <_panic>
	assert(r <= PGSIZE);
  800b2c:	68 f7 1f 80 00       	push   $0x801ff7
  800b31:	68 d7 1f 80 00       	push   $0x801fd7
  800b36:	6a 7d                	push   $0x7d
  800b38:	68 ec 1f 80 00       	push   $0x801fec
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
  800b68:	e8 67 f8 ff ff       	call   8003d4 <fd_alloc>
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
  800b94:	e8 db fd ff ff       	call   800974 <fsipc>
  800b99:	89 c3                	mov    %eax,%ebx
  800b9b:	83 c4 10             	add    $0x10,%esp
  800b9e:	85 c0                	test   %eax,%eax
  800ba0:	78 19                	js     800bbb <open+0x79>
	return fd2num(fd);
  800ba2:	83 ec 0c             	sub    $0xc,%esp
  800ba5:	ff 75 f4             	pushl  -0xc(%ebp)
  800ba8:	e8 f8 f7 ff ff       	call   8003a5 <fd2num>
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
  800bc3:	e8 10 f9 ff ff       	call   8004d8 <fd_close>
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
  800be8:	e8 87 fd ff ff       	call   800974 <fsipc>
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
  800c01:	e8 b3 f7 ff ff       	call   8003b9 <fd2data>
  800c06:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800c08:	83 c4 08             	add    $0x8,%esp
  800c0b:	68 03 20 80 00       	push   $0x802003
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
  800c2b:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
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
  800c52:	e8 ca f5 ff ff       	call   800221 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c57:	89 1c 24             	mov    %ebx,(%esp)
  800c5a:	e8 5a f7 ff ff       	call   8003b9 <fd2data>
  800c5f:	83 c4 08             	add    $0x8,%esp
  800c62:	50                   	push   %eax
  800c63:	6a 00                	push   $0x0
  800c65:	e8 b7 f5 ff ff       	call   800221 <sys_page_unmap>
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
  800c88:	e8 b9 0f 00 00       	call   801c46 <pageref>
  800c8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c90:	89 34 24             	mov    %esi,(%esp)
  800c93:	e8 ae 0f 00 00       	call   801c46 <pageref>
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
  800cb4:	68 0a 20 80 00       	push   $0x80200a
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
  800ce5:	e8 cf f6 ff ff       	call   8003b9 <fd2data>
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
  800d12:	e8 5a f4 ff ff       	call   800171 <sys_yield>
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
  800d6b:	e8 49 f6 ff ff       	call   8003b9 <fd2data>
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
  800d8e:	e8 de f3 ff ff       	call   800171 <sys_yield>
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
  800de0:	e8 ef f5 ff ff       	call   8003d4 <fd_alloc>
  800de5:	89 c3                	mov    %eax,%ebx
  800de7:	83 c4 10             	add    $0x10,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	0f 88 23 01 00 00    	js     800f15 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df2:	83 ec 04             	sub    $0x4,%esp
  800df5:	68 07 04 00 00       	push   $0x407
  800dfa:	ff 75 f4             	pushl  -0xc(%ebp)
  800dfd:	6a 00                	push   $0x0
  800dff:	e8 90 f3 ff ff       	call   800194 <sys_page_alloc>
  800e04:	89 c3                	mov    %eax,%ebx
  800e06:	83 c4 10             	add    $0x10,%esp
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	0f 88 04 01 00 00    	js     800f15 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800e11:	83 ec 0c             	sub    $0xc,%esp
  800e14:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e17:	50                   	push   %eax
  800e18:	e8 b7 f5 ff ff       	call   8003d4 <fd_alloc>
  800e1d:	89 c3                	mov    %eax,%ebx
  800e1f:	83 c4 10             	add    $0x10,%esp
  800e22:	85 c0                	test   %eax,%eax
  800e24:	0f 88 db 00 00 00    	js     800f05 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e2a:	83 ec 04             	sub    $0x4,%esp
  800e2d:	68 07 04 00 00       	push   $0x407
  800e32:	ff 75 f0             	pushl  -0x10(%ebp)
  800e35:	6a 00                	push   $0x0
  800e37:	e8 58 f3 ff ff       	call   800194 <sys_page_alloc>
  800e3c:	89 c3                	mov    %eax,%ebx
  800e3e:	83 c4 10             	add    $0x10,%esp
  800e41:	85 c0                	test   %eax,%eax
  800e43:	0f 88 bc 00 00 00    	js     800f05 <pipe+0x135>
	va = fd2data(fd0);
  800e49:	83 ec 0c             	sub    $0xc,%esp
  800e4c:	ff 75 f4             	pushl  -0xc(%ebp)
  800e4f:	e8 65 f5 ff ff       	call   8003b9 <fd2data>
  800e54:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e56:	83 c4 0c             	add    $0xc,%esp
  800e59:	68 07 04 00 00       	push   $0x407
  800e5e:	50                   	push   %eax
  800e5f:	6a 00                	push   $0x0
  800e61:	e8 2e f3 ff ff       	call   800194 <sys_page_alloc>
  800e66:	89 c3                	mov    %eax,%ebx
  800e68:	83 c4 10             	add    $0x10,%esp
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	0f 88 82 00 00 00    	js     800ef5 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e73:	83 ec 0c             	sub    $0xc,%esp
  800e76:	ff 75 f0             	pushl  -0x10(%ebp)
  800e79:	e8 3b f5 ff ff       	call   8003b9 <fd2data>
  800e7e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e85:	50                   	push   %eax
  800e86:	6a 00                	push   $0x0
  800e88:	56                   	push   %esi
  800e89:	6a 00                	push   $0x0
  800e8b:	e8 4b f3 ff ff       	call   8001db <sys_page_map>
  800e90:	89 c3                	mov    %eax,%ebx
  800e92:	83 c4 20             	add    $0x20,%esp
  800e95:	85 c0                	test   %eax,%eax
  800e97:	78 4e                	js     800ee7 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e99:	a1 24 30 80 00       	mov    0x803024,%eax
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
  800ec2:	e8 de f4 ff ff       	call   8003a5 <fd2num>
  800ec7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eca:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800ecc:	83 c4 04             	add    $0x4,%esp
  800ecf:	ff 75 f0             	pushl  -0x10(%ebp)
  800ed2:	e8 ce f4 ff ff       	call   8003a5 <fd2num>
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
  800eed:	e8 2f f3 ff ff       	call   800221 <sys_page_unmap>
  800ef2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800ef5:	83 ec 08             	sub    $0x8,%esp
  800ef8:	ff 75 f0             	pushl  -0x10(%ebp)
  800efb:	6a 00                	push   $0x0
  800efd:	e8 1f f3 ff ff       	call   800221 <sys_page_unmap>
  800f02:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800f05:	83 ec 08             	sub    $0x8,%esp
  800f08:	ff 75 f4             	pushl  -0xc(%ebp)
  800f0b:	6a 00                	push   $0x0
  800f0d:	e8 0f f3 ff ff       	call   800221 <sys_page_unmap>
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
  800f2f:	e8 f6 f4 ff ff       	call   80042a <fd_lookup>
  800f34:	83 c4 10             	add    $0x10,%esp
  800f37:	85 c0                	test   %eax,%eax
  800f39:	78 18                	js     800f53 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800f3b:	83 ec 0c             	sub    $0xc,%esp
  800f3e:	ff 75 f4             	pushl  -0xc(%ebp)
  800f41:	e8 73 f4 ff ff       	call   8003b9 <fd2data>
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
  800f69:	68 22 20 80 00       	push   $0x802022
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
  800fc2:	e8 fd f0 ff ff       	call   8000c4 <sys_cputs>
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
  800fed:	e8 f4 f0 ff ff       	call   8000e6 <sys_cgetc>
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	75 07                	jne    800ffd <devcons_read+0x25>
		sys_yield();
  800ff6:	e8 76 f1 ff ff       	call   800171 <sys_yield>
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
  80102d:	e8 92 f0 ff ff       	call   8000c4 <sys_cputs>
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
  801049:	e8 5f f6 ff ff       	call   8006ad <read>
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
  801075:	e8 b0 f3 ff ff       	call   80042a <fd_lookup>
  80107a:	83 c4 10             	add    $0x10,%esp
  80107d:	85 c0                	test   %eax,%eax
  80107f:	78 11                	js     801092 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801081:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801084:	8b 15 40 30 80 00    	mov    0x803040,%edx
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
  8010a2:	e8 2d f3 ff ff       	call   8003d4 <fd_alloc>
  8010a7:	83 c4 10             	add    $0x10,%esp
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	78 3a                	js     8010e8 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8010ae:	83 ec 04             	sub    $0x4,%esp
  8010b1:	68 07 04 00 00       	push   $0x407
  8010b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8010b9:	6a 00                	push   $0x0
  8010bb:	e8 d4 f0 ff ff       	call   800194 <sys_page_alloc>
  8010c0:	83 c4 10             	add    $0x10,%esp
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	78 21                	js     8010e8 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8010c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ca:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8010d0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8010d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010d5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8010dc:	83 ec 0c             	sub    $0xc,%esp
  8010df:	50                   	push   %eax
  8010e0:	e8 c0 f2 ff ff       	call   8003a5 <fd2num>
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
  8010f6:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8010fc:	e8 4d f0 ff ff       	call   80014e <sys_getenvid>
  801101:	83 ec 0c             	sub    $0xc,%esp
  801104:	ff 75 0c             	pushl  0xc(%ebp)
  801107:	ff 75 08             	pushl  0x8(%ebp)
  80110a:	56                   	push   %esi
  80110b:	50                   	push   %eax
  80110c:	68 30 20 80 00       	push   $0x802030
  801111:	e8 bb 00 00 00       	call   8011d1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801116:	83 c4 18             	add    $0x18,%esp
  801119:	53                   	push   %ebx
  80111a:	ff 75 10             	pushl  0x10(%ebp)
  80111d:	e8 5a 00 00 00       	call   80117c <vcprintf>
	cprintf("\n");
  801122:	c7 04 24 1b 20 80 00 	movl   $0x80201b,(%esp)
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
  80116c:	e8 53 ef ff ff       	call   8000c4 <sys_cputs>
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
  8011c4:	e8 fb ee ff ff       	call   8000c4 <sys_cputs>

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
  801237:	e8 54 0a 00 00       	call   801c90 <__udivdi3>
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
  801275:	e8 26 0b 00 00       	call   801da0 <__umoddi3>
  80127a:	83 c4 14             	add    $0x14,%esp
  80127d:	0f be 80 53 20 80 00 	movsbl 0x802053(%eax),%eax
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
  801324:	3e ff 24 85 a0 21 80 	notrack jmp *0x8021a0(,%eax,4)
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
  8013f1:	8b 14 85 00 23 80 00 	mov    0x802300(,%eax,4),%edx
  8013f8:	85 d2                	test   %edx,%edx
  8013fa:	74 18                	je     801414 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8013fc:	52                   	push   %edx
  8013fd:	68 e9 1f 80 00       	push   $0x801fe9
  801402:	53                   	push   %ebx
  801403:	56                   	push   %esi
  801404:	e8 aa fe ff ff       	call   8012b3 <printfmt>
  801409:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80140c:	89 7d 14             	mov    %edi,0x14(%ebp)
  80140f:	e9 22 02 00 00       	jmp    801636 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  801414:	50                   	push   %eax
  801415:	68 6b 20 80 00       	push   $0x80206b
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
  80143c:	b8 64 20 80 00       	mov    $0x802064,%eax
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

00801b4c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b4c:	f3 0f 1e fb          	endbr32 
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	56                   	push   %esi
  801b54:	53                   	push   %ebx
  801b55:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b58:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b5b:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801b5e:	85 c0                	test   %eax,%eax
  801b60:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b65:	0f 44 c2             	cmove  %edx,%eax
  801b68:	83 ec 0c             	sub    $0xc,%esp
  801b6b:	50                   	push   %eax
  801b6c:	e8 ef e7 ff ff       	call   800360 <sys_ipc_recv>
  801b71:	83 c4 10             	add    $0x10,%esp
  801b74:	85 c0                	test   %eax,%eax
  801b76:	78 24                	js     801b9c <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801b78:	85 f6                	test   %esi,%esi
  801b7a:	74 0a                	je     801b86 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801b7c:	a1 04 40 80 00       	mov    0x804004,%eax
  801b81:	8b 40 78             	mov    0x78(%eax),%eax
  801b84:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801b86:	85 db                	test   %ebx,%ebx
  801b88:	74 0a                	je     801b94 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801b8a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b8f:	8b 40 74             	mov    0x74(%eax),%eax
  801b92:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801b94:	a1 04 40 80 00       	mov    0x804004,%eax
  801b99:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b9f:	5b                   	pop    %ebx
  801ba0:	5e                   	pop    %esi
  801ba1:	5d                   	pop    %ebp
  801ba2:	c3                   	ret    

00801ba3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ba3:	f3 0f 1e fb          	endbr32 
  801ba7:	55                   	push   %ebp
  801ba8:	89 e5                	mov    %esp,%ebp
  801baa:	57                   	push   %edi
  801bab:	56                   	push   %esi
  801bac:	53                   	push   %ebx
  801bad:	83 ec 1c             	sub    $0x1c,%esp
  801bb0:	8b 45 10             	mov    0x10(%ebp),%eax
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801bba:	0f 45 d0             	cmovne %eax,%edx
  801bbd:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801bbf:	be 01 00 00 00       	mov    $0x1,%esi
  801bc4:	eb 1f                	jmp    801be5 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801bc6:	e8 a6 e5 ff ff       	call   800171 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801bcb:	83 c3 01             	add    $0x1,%ebx
  801bce:	39 de                	cmp    %ebx,%esi
  801bd0:	7f f4                	jg     801bc6 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801bd2:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801bd4:	83 fe 11             	cmp    $0x11,%esi
  801bd7:	b8 01 00 00 00       	mov    $0x1,%eax
  801bdc:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801bdf:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801be3:	75 1c                	jne    801c01 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801be5:	ff 75 14             	pushl  0x14(%ebp)
  801be8:	57                   	push   %edi
  801be9:	ff 75 0c             	pushl  0xc(%ebp)
  801bec:	ff 75 08             	pushl  0x8(%ebp)
  801bef:	e8 45 e7 ff ff       	call   800339 <sys_ipc_try_send>
  801bf4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801bf7:	83 c4 10             	add    $0x10,%esp
  801bfa:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bff:	eb cd                	jmp    801bce <ipc_send+0x2b>
}
  801c01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c04:	5b                   	pop    %ebx
  801c05:	5e                   	pop    %esi
  801c06:	5f                   	pop    %edi
  801c07:	5d                   	pop    %ebp
  801c08:	c3                   	ret    

00801c09 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c09:	f3 0f 1e fb          	endbr32 
  801c0d:	55                   	push   %ebp
  801c0e:	89 e5                	mov    %esp,%ebp
  801c10:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c13:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c18:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c1b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c21:	8b 52 50             	mov    0x50(%edx),%edx
  801c24:	39 ca                	cmp    %ecx,%edx
  801c26:	74 11                	je     801c39 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801c28:	83 c0 01             	add    $0x1,%eax
  801c2b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c30:	75 e6                	jne    801c18 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801c32:	b8 00 00 00 00       	mov    $0x0,%eax
  801c37:	eb 0b                	jmp    801c44 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c39:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c3c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c41:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c44:	5d                   	pop    %ebp
  801c45:	c3                   	ret    

00801c46 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c46:	f3 0f 1e fb          	endbr32 
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c50:	89 c2                	mov    %eax,%edx
  801c52:	c1 ea 16             	shr    $0x16,%edx
  801c55:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c5c:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c61:	f6 c1 01             	test   $0x1,%cl
  801c64:	74 1c                	je     801c82 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c66:	c1 e8 0c             	shr    $0xc,%eax
  801c69:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c70:	a8 01                	test   $0x1,%al
  801c72:	74 0e                	je     801c82 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c74:	c1 e8 0c             	shr    $0xc,%eax
  801c77:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c7e:	ef 
  801c7f:	0f b7 d2             	movzwl %dx,%edx
}
  801c82:	89 d0                	mov    %edx,%eax
  801c84:	5d                   	pop    %ebp
  801c85:	c3                   	ret    
  801c86:	66 90                	xchg   %ax,%ax
  801c88:	66 90                	xchg   %ax,%ax
  801c8a:	66 90                	xchg   %ax,%ax
  801c8c:	66 90                	xchg   %ax,%ax
  801c8e:	66 90                	xchg   %ax,%ax

00801c90 <__udivdi3>:
  801c90:	f3 0f 1e fb          	endbr32 
  801c94:	55                   	push   %ebp
  801c95:	57                   	push   %edi
  801c96:	56                   	push   %esi
  801c97:	53                   	push   %ebx
  801c98:	83 ec 1c             	sub    $0x1c,%esp
  801c9b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c9f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801ca3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ca7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801cab:	85 d2                	test   %edx,%edx
  801cad:	75 19                	jne    801cc8 <__udivdi3+0x38>
  801caf:	39 f3                	cmp    %esi,%ebx
  801cb1:	76 4d                	jbe    801d00 <__udivdi3+0x70>
  801cb3:	31 ff                	xor    %edi,%edi
  801cb5:	89 e8                	mov    %ebp,%eax
  801cb7:	89 f2                	mov    %esi,%edx
  801cb9:	f7 f3                	div    %ebx
  801cbb:	89 fa                	mov    %edi,%edx
  801cbd:	83 c4 1c             	add    $0x1c,%esp
  801cc0:	5b                   	pop    %ebx
  801cc1:	5e                   	pop    %esi
  801cc2:	5f                   	pop    %edi
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    
  801cc5:	8d 76 00             	lea    0x0(%esi),%esi
  801cc8:	39 f2                	cmp    %esi,%edx
  801cca:	76 14                	jbe    801ce0 <__udivdi3+0x50>
  801ccc:	31 ff                	xor    %edi,%edi
  801cce:	31 c0                	xor    %eax,%eax
  801cd0:	89 fa                	mov    %edi,%edx
  801cd2:	83 c4 1c             	add    $0x1c,%esp
  801cd5:	5b                   	pop    %ebx
  801cd6:	5e                   	pop    %esi
  801cd7:	5f                   	pop    %edi
  801cd8:	5d                   	pop    %ebp
  801cd9:	c3                   	ret    
  801cda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ce0:	0f bd fa             	bsr    %edx,%edi
  801ce3:	83 f7 1f             	xor    $0x1f,%edi
  801ce6:	75 48                	jne    801d30 <__udivdi3+0xa0>
  801ce8:	39 f2                	cmp    %esi,%edx
  801cea:	72 06                	jb     801cf2 <__udivdi3+0x62>
  801cec:	31 c0                	xor    %eax,%eax
  801cee:	39 eb                	cmp    %ebp,%ebx
  801cf0:	77 de                	ja     801cd0 <__udivdi3+0x40>
  801cf2:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf7:	eb d7                	jmp    801cd0 <__udivdi3+0x40>
  801cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d00:	89 d9                	mov    %ebx,%ecx
  801d02:	85 db                	test   %ebx,%ebx
  801d04:	75 0b                	jne    801d11 <__udivdi3+0x81>
  801d06:	b8 01 00 00 00       	mov    $0x1,%eax
  801d0b:	31 d2                	xor    %edx,%edx
  801d0d:	f7 f3                	div    %ebx
  801d0f:	89 c1                	mov    %eax,%ecx
  801d11:	31 d2                	xor    %edx,%edx
  801d13:	89 f0                	mov    %esi,%eax
  801d15:	f7 f1                	div    %ecx
  801d17:	89 c6                	mov    %eax,%esi
  801d19:	89 e8                	mov    %ebp,%eax
  801d1b:	89 f7                	mov    %esi,%edi
  801d1d:	f7 f1                	div    %ecx
  801d1f:	89 fa                	mov    %edi,%edx
  801d21:	83 c4 1c             	add    $0x1c,%esp
  801d24:	5b                   	pop    %ebx
  801d25:	5e                   	pop    %esi
  801d26:	5f                   	pop    %edi
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    
  801d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d30:	89 f9                	mov    %edi,%ecx
  801d32:	b8 20 00 00 00       	mov    $0x20,%eax
  801d37:	29 f8                	sub    %edi,%eax
  801d39:	d3 e2                	shl    %cl,%edx
  801d3b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d3f:	89 c1                	mov    %eax,%ecx
  801d41:	89 da                	mov    %ebx,%edx
  801d43:	d3 ea                	shr    %cl,%edx
  801d45:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d49:	09 d1                	or     %edx,%ecx
  801d4b:	89 f2                	mov    %esi,%edx
  801d4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d51:	89 f9                	mov    %edi,%ecx
  801d53:	d3 e3                	shl    %cl,%ebx
  801d55:	89 c1                	mov    %eax,%ecx
  801d57:	d3 ea                	shr    %cl,%edx
  801d59:	89 f9                	mov    %edi,%ecx
  801d5b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d5f:	89 eb                	mov    %ebp,%ebx
  801d61:	d3 e6                	shl    %cl,%esi
  801d63:	89 c1                	mov    %eax,%ecx
  801d65:	d3 eb                	shr    %cl,%ebx
  801d67:	09 de                	or     %ebx,%esi
  801d69:	89 f0                	mov    %esi,%eax
  801d6b:	f7 74 24 08          	divl   0x8(%esp)
  801d6f:	89 d6                	mov    %edx,%esi
  801d71:	89 c3                	mov    %eax,%ebx
  801d73:	f7 64 24 0c          	mull   0xc(%esp)
  801d77:	39 d6                	cmp    %edx,%esi
  801d79:	72 15                	jb     801d90 <__udivdi3+0x100>
  801d7b:	89 f9                	mov    %edi,%ecx
  801d7d:	d3 e5                	shl    %cl,%ebp
  801d7f:	39 c5                	cmp    %eax,%ebp
  801d81:	73 04                	jae    801d87 <__udivdi3+0xf7>
  801d83:	39 d6                	cmp    %edx,%esi
  801d85:	74 09                	je     801d90 <__udivdi3+0x100>
  801d87:	89 d8                	mov    %ebx,%eax
  801d89:	31 ff                	xor    %edi,%edi
  801d8b:	e9 40 ff ff ff       	jmp    801cd0 <__udivdi3+0x40>
  801d90:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d93:	31 ff                	xor    %edi,%edi
  801d95:	e9 36 ff ff ff       	jmp    801cd0 <__udivdi3+0x40>
  801d9a:	66 90                	xchg   %ax,%ax
  801d9c:	66 90                	xchg   %ax,%ax
  801d9e:	66 90                	xchg   %ax,%ax

00801da0 <__umoddi3>:
  801da0:	f3 0f 1e fb          	endbr32 
  801da4:	55                   	push   %ebp
  801da5:	57                   	push   %edi
  801da6:	56                   	push   %esi
  801da7:	53                   	push   %ebx
  801da8:	83 ec 1c             	sub    $0x1c,%esp
  801dab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801daf:	8b 74 24 30          	mov    0x30(%esp),%esi
  801db3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801db7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dbb:	85 c0                	test   %eax,%eax
  801dbd:	75 19                	jne    801dd8 <__umoddi3+0x38>
  801dbf:	39 df                	cmp    %ebx,%edi
  801dc1:	76 5d                	jbe    801e20 <__umoddi3+0x80>
  801dc3:	89 f0                	mov    %esi,%eax
  801dc5:	89 da                	mov    %ebx,%edx
  801dc7:	f7 f7                	div    %edi
  801dc9:	89 d0                	mov    %edx,%eax
  801dcb:	31 d2                	xor    %edx,%edx
  801dcd:	83 c4 1c             	add    $0x1c,%esp
  801dd0:	5b                   	pop    %ebx
  801dd1:	5e                   	pop    %esi
  801dd2:	5f                   	pop    %edi
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    
  801dd5:	8d 76 00             	lea    0x0(%esi),%esi
  801dd8:	89 f2                	mov    %esi,%edx
  801dda:	39 d8                	cmp    %ebx,%eax
  801ddc:	76 12                	jbe    801df0 <__umoddi3+0x50>
  801dde:	89 f0                	mov    %esi,%eax
  801de0:	89 da                	mov    %ebx,%edx
  801de2:	83 c4 1c             	add    $0x1c,%esp
  801de5:	5b                   	pop    %ebx
  801de6:	5e                   	pop    %esi
  801de7:	5f                   	pop    %edi
  801de8:	5d                   	pop    %ebp
  801de9:	c3                   	ret    
  801dea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801df0:	0f bd e8             	bsr    %eax,%ebp
  801df3:	83 f5 1f             	xor    $0x1f,%ebp
  801df6:	75 50                	jne    801e48 <__umoddi3+0xa8>
  801df8:	39 d8                	cmp    %ebx,%eax
  801dfa:	0f 82 e0 00 00 00    	jb     801ee0 <__umoddi3+0x140>
  801e00:	89 d9                	mov    %ebx,%ecx
  801e02:	39 f7                	cmp    %esi,%edi
  801e04:	0f 86 d6 00 00 00    	jbe    801ee0 <__umoddi3+0x140>
  801e0a:	89 d0                	mov    %edx,%eax
  801e0c:	89 ca                	mov    %ecx,%edx
  801e0e:	83 c4 1c             	add    $0x1c,%esp
  801e11:	5b                   	pop    %ebx
  801e12:	5e                   	pop    %esi
  801e13:	5f                   	pop    %edi
  801e14:	5d                   	pop    %ebp
  801e15:	c3                   	ret    
  801e16:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e1d:	8d 76 00             	lea    0x0(%esi),%esi
  801e20:	89 fd                	mov    %edi,%ebp
  801e22:	85 ff                	test   %edi,%edi
  801e24:	75 0b                	jne    801e31 <__umoddi3+0x91>
  801e26:	b8 01 00 00 00       	mov    $0x1,%eax
  801e2b:	31 d2                	xor    %edx,%edx
  801e2d:	f7 f7                	div    %edi
  801e2f:	89 c5                	mov    %eax,%ebp
  801e31:	89 d8                	mov    %ebx,%eax
  801e33:	31 d2                	xor    %edx,%edx
  801e35:	f7 f5                	div    %ebp
  801e37:	89 f0                	mov    %esi,%eax
  801e39:	f7 f5                	div    %ebp
  801e3b:	89 d0                	mov    %edx,%eax
  801e3d:	31 d2                	xor    %edx,%edx
  801e3f:	eb 8c                	jmp    801dcd <__umoddi3+0x2d>
  801e41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e48:	89 e9                	mov    %ebp,%ecx
  801e4a:	ba 20 00 00 00       	mov    $0x20,%edx
  801e4f:	29 ea                	sub    %ebp,%edx
  801e51:	d3 e0                	shl    %cl,%eax
  801e53:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e57:	89 d1                	mov    %edx,%ecx
  801e59:	89 f8                	mov    %edi,%eax
  801e5b:	d3 e8                	shr    %cl,%eax
  801e5d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e61:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e65:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e69:	09 c1                	or     %eax,%ecx
  801e6b:	89 d8                	mov    %ebx,%eax
  801e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e71:	89 e9                	mov    %ebp,%ecx
  801e73:	d3 e7                	shl    %cl,%edi
  801e75:	89 d1                	mov    %edx,%ecx
  801e77:	d3 e8                	shr    %cl,%eax
  801e79:	89 e9                	mov    %ebp,%ecx
  801e7b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e7f:	d3 e3                	shl    %cl,%ebx
  801e81:	89 c7                	mov    %eax,%edi
  801e83:	89 d1                	mov    %edx,%ecx
  801e85:	89 f0                	mov    %esi,%eax
  801e87:	d3 e8                	shr    %cl,%eax
  801e89:	89 e9                	mov    %ebp,%ecx
  801e8b:	89 fa                	mov    %edi,%edx
  801e8d:	d3 e6                	shl    %cl,%esi
  801e8f:	09 d8                	or     %ebx,%eax
  801e91:	f7 74 24 08          	divl   0x8(%esp)
  801e95:	89 d1                	mov    %edx,%ecx
  801e97:	89 f3                	mov    %esi,%ebx
  801e99:	f7 64 24 0c          	mull   0xc(%esp)
  801e9d:	89 c6                	mov    %eax,%esi
  801e9f:	89 d7                	mov    %edx,%edi
  801ea1:	39 d1                	cmp    %edx,%ecx
  801ea3:	72 06                	jb     801eab <__umoddi3+0x10b>
  801ea5:	75 10                	jne    801eb7 <__umoddi3+0x117>
  801ea7:	39 c3                	cmp    %eax,%ebx
  801ea9:	73 0c                	jae    801eb7 <__umoddi3+0x117>
  801eab:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801eaf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801eb3:	89 d7                	mov    %edx,%edi
  801eb5:	89 c6                	mov    %eax,%esi
  801eb7:	89 ca                	mov    %ecx,%edx
  801eb9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801ebe:	29 f3                	sub    %esi,%ebx
  801ec0:	19 fa                	sbb    %edi,%edx
  801ec2:	89 d0                	mov    %edx,%eax
  801ec4:	d3 e0                	shl    %cl,%eax
  801ec6:	89 e9                	mov    %ebp,%ecx
  801ec8:	d3 eb                	shr    %cl,%ebx
  801eca:	d3 ea                	shr    %cl,%edx
  801ecc:	09 d8                	or     %ebx,%eax
  801ece:	83 c4 1c             	add    $0x1c,%esp
  801ed1:	5b                   	pop    %ebx
  801ed2:	5e                   	pop    %esi
  801ed3:	5f                   	pop    %edi
  801ed4:	5d                   	pop    %ebp
  801ed5:	c3                   	ret    
  801ed6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801edd:	8d 76 00             	lea    0x0(%esi),%esi
  801ee0:	29 fe                	sub    %edi,%esi
  801ee2:	19 c3                	sbb    %eax,%ebx
  801ee4:	89 f2                	mov    %esi,%edx
  801ee6:	89 d9                	mov    %ebx,%ecx
  801ee8:	e9 1d ff ff ff       	jmp    801e0a <__umoddi3+0x6a>
