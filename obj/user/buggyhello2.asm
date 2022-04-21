
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
  80013d:	68 d8 1e 80 00       	push   $0x801ed8
  800142:	6a 23                	push   $0x23
  800144:	68 f5 1e 80 00       	push   $0x801ef5
  800149:	e8 70 0f 00 00       	call   8010be <_panic>

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
  8001ca:	68 d8 1e 80 00       	push   $0x801ed8
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 f5 1e 80 00       	push   $0x801ef5
  8001d6:	e8 e3 0e 00 00       	call   8010be <_panic>

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
  800210:	68 d8 1e 80 00       	push   $0x801ed8
  800215:	6a 23                	push   $0x23
  800217:	68 f5 1e 80 00       	push   $0x801ef5
  80021c:	e8 9d 0e 00 00       	call   8010be <_panic>

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
  800256:	68 d8 1e 80 00       	push   $0x801ed8
  80025b:	6a 23                	push   $0x23
  80025d:	68 f5 1e 80 00       	push   $0x801ef5
  800262:	e8 57 0e 00 00       	call   8010be <_panic>

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
  80029c:	68 d8 1e 80 00       	push   $0x801ed8
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 f5 1e 80 00       	push   $0x801ef5
  8002a8:	e8 11 0e 00 00       	call   8010be <_panic>

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
  8002e2:	68 d8 1e 80 00       	push   $0x801ed8
  8002e7:	6a 23                	push   $0x23
  8002e9:	68 f5 1e 80 00       	push   $0x801ef5
  8002ee:	e8 cb 0d 00 00       	call   8010be <_panic>

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
  800328:	68 d8 1e 80 00       	push   $0x801ed8
  80032d:	6a 23                	push   $0x23
  80032f:	68 f5 1e 80 00       	push   $0x801ef5
  800334:	e8 85 0d 00 00       	call   8010be <_panic>

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
  800394:	68 d8 1e 80 00       	push   $0x801ed8
  800399:	6a 23                	push   $0x23
  80039b:	68 f5 1e 80 00       	push   $0x801ef5
  8003a0:	e8 19 0d 00 00       	call   8010be <_panic>

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
  80048b:	ba 80 1f 80 00       	mov    $0x801f80,%edx
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
  8004af:	68 04 1f 80 00       	push   $0x801f04
  8004b4:	e8 ec 0c 00 00       	call   8011a5 <cprintf>
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
  80071d:	68 45 1f 80 00       	push   $0x801f45
  800722:	e8 7e 0a 00 00       	call   8011a5 <cprintf>
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
  8007ee:	68 61 1f 80 00       	push   $0x801f61
  8007f3:	e8 ad 09 00 00       	call   8011a5 <cprintf>
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
  80089e:	68 24 1f 80 00       	push   $0x801f24
  8008a3:	e8 fd 08 00 00       	call   8011a5 <cprintf>
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
  800942:	e8 cf 01 00 00       	call   800b16 <open>
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
  800994:	e8 de 11 00 00       	call   801b77 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800999:	83 c4 0c             	add    $0xc,%esp
  80099c:	6a 00                	push   $0x0
  80099e:	53                   	push   %ebx
  80099f:	6a 00                	push   $0x0
  8009a1:	e8 7a 11 00 00       	call   801b20 <ipc_recv>
}
  8009a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009a9:	5b                   	pop    %ebx
  8009aa:	5e                   	pop    %esi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009ad:	83 ec 0c             	sub    $0xc,%esp
  8009b0:	6a 01                	push   $0x1
  8009b2:	e8 26 12 00 00       	call   801bdd <ipc_find_env>
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
  800a4a:	e8 5f 0d 00 00       	call   8017ae <strcpy>
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
	panic("devfile_write not implemented");
  800a7c:	68 90 1f 80 00       	push   $0x801f90
  800a81:	68 90 00 00 00       	push   $0x90
  800a86:	68 ae 1f 80 00       	push   $0x801fae
  800a8b:	e8 2e 06 00 00       	call   8010be <_panic>

00800a90 <devfile_read>:
{
  800a90:	f3 0f 1e fb          	endbr32 
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
  800a99:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	8b 40 0c             	mov    0xc(%eax),%eax
  800aa2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800aa7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800aad:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab2:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab7:	e8 b8 fe ff ff       	call   800974 <fsipc>
  800abc:	89 c3                	mov    %eax,%ebx
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	78 1f                	js     800ae1 <devfile_read+0x51>
	assert(r <= n);
  800ac2:	39 f0                	cmp    %esi,%eax
  800ac4:	77 24                	ja     800aea <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800ac6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800acb:	7f 33                	jg     800b00 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800acd:	83 ec 04             	sub    $0x4,%esp
  800ad0:	50                   	push   %eax
  800ad1:	68 00 50 80 00       	push   $0x805000
  800ad6:	ff 75 0c             	pushl  0xc(%ebp)
  800ad9:	e8 86 0e 00 00       	call   801964 <memmove>
	return r;
  800ade:	83 c4 10             	add    $0x10,%esp
}
  800ae1:	89 d8                	mov    %ebx,%eax
  800ae3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae6:	5b                   	pop    %ebx
  800ae7:	5e                   	pop    %esi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    
	assert(r <= n);
  800aea:	68 b9 1f 80 00       	push   $0x801fb9
  800aef:	68 c0 1f 80 00       	push   $0x801fc0
  800af4:	6a 7c                	push   $0x7c
  800af6:	68 ae 1f 80 00       	push   $0x801fae
  800afb:	e8 be 05 00 00       	call   8010be <_panic>
	assert(r <= PGSIZE);
  800b00:	68 d5 1f 80 00       	push   $0x801fd5
  800b05:	68 c0 1f 80 00       	push   $0x801fc0
  800b0a:	6a 7d                	push   $0x7d
  800b0c:	68 ae 1f 80 00       	push   $0x801fae
  800b11:	e8 a8 05 00 00       	call   8010be <_panic>

00800b16 <open>:
{
  800b16:	f3 0f 1e fb          	endbr32 
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	56                   	push   %esi
  800b1e:	53                   	push   %ebx
  800b1f:	83 ec 1c             	sub    $0x1c,%esp
  800b22:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b25:	56                   	push   %esi
  800b26:	e8 40 0c 00 00       	call   80176b <strlen>
  800b2b:	83 c4 10             	add    $0x10,%esp
  800b2e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b33:	7f 6c                	jg     800ba1 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800b35:	83 ec 0c             	sub    $0xc,%esp
  800b38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b3b:	50                   	push   %eax
  800b3c:	e8 93 f8 ff ff       	call   8003d4 <fd_alloc>
  800b41:	89 c3                	mov    %eax,%ebx
  800b43:	83 c4 10             	add    $0x10,%esp
  800b46:	85 c0                	test   %eax,%eax
  800b48:	78 3c                	js     800b86 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b4a:	83 ec 08             	sub    $0x8,%esp
  800b4d:	56                   	push   %esi
  800b4e:	68 00 50 80 00       	push   $0x805000
  800b53:	e8 56 0c 00 00       	call   8017ae <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5b:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b60:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b63:	b8 01 00 00 00       	mov    $0x1,%eax
  800b68:	e8 07 fe ff ff       	call   800974 <fsipc>
  800b6d:	89 c3                	mov    %eax,%ebx
  800b6f:	83 c4 10             	add    $0x10,%esp
  800b72:	85 c0                	test   %eax,%eax
  800b74:	78 19                	js     800b8f <open+0x79>
	return fd2num(fd);
  800b76:	83 ec 0c             	sub    $0xc,%esp
  800b79:	ff 75 f4             	pushl  -0xc(%ebp)
  800b7c:	e8 24 f8 ff ff       	call   8003a5 <fd2num>
  800b81:	89 c3                	mov    %eax,%ebx
  800b83:	83 c4 10             	add    $0x10,%esp
}
  800b86:	89 d8                	mov    %ebx,%eax
  800b88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    
		fd_close(fd, 0);
  800b8f:	83 ec 08             	sub    $0x8,%esp
  800b92:	6a 00                	push   $0x0
  800b94:	ff 75 f4             	pushl  -0xc(%ebp)
  800b97:	e8 3c f9 ff ff       	call   8004d8 <fd_close>
		return r;
  800b9c:	83 c4 10             	add    $0x10,%esp
  800b9f:	eb e5                	jmp    800b86 <open+0x70>
		return -E_BAD_PATH;
  800ba1:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800ba6:	eb de                	jmp    800b86 <open+0x70>

00800ba8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ba8:	f3 0f 1e fb          	endbr32 
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb7:	b8 08 00 00 00       	mov    $0x8,%eax
  800bbc:	e8 b3 fd ff ff       	call   800974 <fsipc>
}
  800bc1:	c9                   	leave  
  800bc2:	c3                   	ret    

00800bc3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bc3:	f3 0f 1e fb          	endbr32 
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bcf:	83 ec 0c             	sub    $0xc,%esp
  800bd2:	ff 75 08             	pushl  0x8(%ebp)
  800bd5:	e8 df f7 ff ff       	call   8003b9 <fd2data>
  800bda:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bdc:	83 c4 08             	add    $0x8,%esp
  800bdf:	68 e1 1f 80 00       	push   $0x801fe1
  800be4:	53                   	push   %ebx
  800be5:	e8 c4 0b 00 00       	call   8017ae <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bea:	8b 46 04             	mov    0x4(%esi),%eax
  800bed:	2b 06                	sub    (%esi),%eax
  800bef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bf5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bfc:	00 00 00 
	stat->st_dev = &devpipe;
  800bff:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800c06:	30 80 00 
	return 0;
}
  800c09:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c15:	f3 0f 1e fb          	endbr32 
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	53                   	push   %ebx
  800c1d:	83 ec 0c             	sub    $0xc,%esp
  800c20:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c23:	53                   	push   %ebx
  800c24:	6a 00                	push   $0x0
  800c26:	e8 f6 f5 ff ff       	call   800221 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c2b:	89 1c 24             	mov    %ebx,(%esp)
  800c2e:	e8 86 f7 ff ff       	call   8003b9 <fd2data>
  800c33:	83 c4 08             	add    $0x8,%esp
  800c36:	50                   	push   %eax
  800c37:	6a 00                	push   $0x0
  800c39:	e8 e3 f5 ff ff       	call   800221 <sys_page_unmap>
}
  800c3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c41:	c9                   	leave  
  800c42:	c3                   	ret    

00800c43 <_pipeisclosed>:
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 1c             	sub    $0x1c,%esp
  800c4c:	89 c7                	mov    %eax,%edi
  800c4e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c50:	a1 04 40 80 00       	mov    0x804004,%eax
  800c55:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c58:	83 ec 0c             	sub    $0xc,%esp
  800c5b:	57                   	push   %edi
  800c5c:	e8 b9 0f 00 00       	call   801c1a <pageref>
  800c61:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c64:	89 34 24             	mov    %esi,(%esp)
  800c67:	e8 ae 0f 00 00       	call   801c1a <pageref>
		nn = thisenv->env_runs;
  800c6c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c72:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c75:	83 c4 10             	add    $0x10,%esp
  800c78:	39 cb                	cmp    %ecx,%ebx
  800c7a:	74 1b                	je     800c97 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c7c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c7f:	75 cf                	jne    800c50 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c81:	8b 42 58             	mov    0x58(%edx),%eax
  800c84:	6a 01                	push   $0x1
  800c86:	50                   	push   %eax
  800c87:	53                   	push   %ebx
  800c88:	68 e8 1f 80 00       	push   $0x801fe8
  800c8d:	e8 13 05 00 00       	call   8011a5 <cprintf>
  800c92:	83 c4 10             	add    $0x10,%esp
  800c95:	eb b9                	jmp    800c50 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c97:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c9a:	0f 94 c0             	sete   %al
  800c9d:	0f b6 c0             	movzbl %al,%eax
}
  800ca0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5f                   	pop    %edi
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <devpipe_write>:
{
  800ca8:	f3 0f 1e fb          	endbr32 
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	53                   	push   %ebx
  800cb2:	83 ec 28             	sub    $0x28,%esp
  800cb5:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800cb8:	56                   	push   %esi
  800cb9:	e8 fb f6 ff ff       	call   8003b9 <fd2data>
  800cbe:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cc0:	83 c4 10             	add    $0x10,%esp
  800cc3:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ccb:	74 4f                	je     800d1c <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800ccd:	8b 43 04             	mov    0x4(%ebx),%eax
  800cd0:	8b 0b                	mov    (%ebx),%ecx
  800cd2:	8d 51 20             	lea    0x20(%ecx),%edx
  800cd5:	39 d0                	cmp    %edx,%eax
  800cd7:	72 14                	jb     800ced <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800cd9:	89 da                	mov    %ebx,%edx
  800cdb:	89 f0                	mov    %esi,%eax
  800cdd:	e8 61 ff ff ff       	call   800c43 <_pipeisclosed>
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	75 3b                	jne    800d21 <devpipe_write+0x79>
			sys_yield();
  800ce6:	e8 86 f4 ff ff       	call   800171 <sys_yield>
  800ceb:	eb e0                	jmp    800ccd <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cf4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cf7:	89 c2                	mov    %eax,%edx
  800cf9:	c1 fa 1f             	sar    $0x1f,%edx
  800cfc:	89 d1                	mov    %edx,%ecx
  800cfe:	c1 e9 1b             	shr    $0x1b,%ecx
  800d01:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800d04:	83 e2 1f             	and    $0x1f,%edx
  800d07:	29 ca                	sub    %ecx,%edx
  800d09:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800d0d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d11:	83 c0 01             	add    $0x1,%eax
  800d14:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800d17:	83 c7 01             	add    $0x1,%edi
  800d1a:	eb ac                	jmp    800cc8 <devpipe_write+0x20>
	return i;
  800d1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d1f:	eb 05                	jmp    800d26 <devpipe_write+0x7e>
				return 0;
  800d21:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <devpipe_read>:
{
  800d2e:	f3 0f 1e fb          	endbr32 
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
  800d38:	83 ec 18             	sub    $0x18,%esp
  800d3b:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800d3e:	57                   	push   %edi
  800d3f:	e8 75 f6 ff ff       	call   8003b9 <fd2data>
  800d44:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d46:	83 c4 10             	add    $0x10,%esp
  800d49:	be 00 00 00 00       	mov    $0x0,%esi
  800d4e:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d51:	75 14                	jne    800d67 <devpipe_read+0x39>
	return i;
  800d53:	8b 45 10             	mov    0x10(%ebp),%eax
  800d56:	eb 02                	jmp    800d5a <devpipe_read+0x2c>
				return i;
  800d58:	89 f0                	mov    %esi,%eax
}
  800d5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5d:	5b                   	pop    %ebx
  800d5e:	5e                   	pop    %esi
  800d5f:	5f                   	pop    %edi
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    
			sys_yield();
  800d62:	e8 0a f4 ff ff       	call   800171 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d67:	8b 03                	mov    (%ebx),%eax
  800d69:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d6c:	75 18                	jne    800d86 <devpipe_read+0x58>
			if (i > 0)
  800d6e:	85 f6                	test   %esi,%esi
  800d70:	75 e6                	jne    800d58 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d72:	89 da                	mov    %ebx,%edx
  800d74:	89 f8                	mov    %edi,%eax
  800d76:	e8 c8 fe ff ff       	call   800c43 <_pipeisclosed>
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	74 e3                	je     800d62 <devpipe_read+0x34>
				return 0;
  800d7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d84:	eb d4                	jmp    800d5a <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d86:	99                   	cltd   
  800d87:	c1 ea 1b             	shr    $0x1b,%edx
  800d8a:	01 d0                	add    %edx,%eax
  800d8c:	83 e0 1f             	and    $0x1f,%eax
  800d8f:	29 d0                	sub    %edx,%eax
  800d91:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d99:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d9c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d9f:	83 c6 01             	add    $0x1,%esi
  800da2:	eb aa                	jmp    800d4e <devpipe_read+0x20>

00800da4 <pipe>:
{
  800da4:	f3 0f 1e fb          	endbr32 
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
  800dad:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800db0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800db3:	50                   	push   %eax
  800db4:	e8 1b f6 ff ff       	call   8003d4 <fd_alloc>
  800db9:	89 c3                	mov    %eax,%ebx
  800dbb:	83 c4 10             	add    $0x10,%esp
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	0f 88 23 01 00 00    	js     800ee9 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc6:	83 ec 04             	sub    $0x4,%esp
  800dc9:	68 07 04 00 00       	push   $0x407
  800dce:	ff 75 f4             	pushl  -0xc(%ebp)
  800dd1:	6a 00                	push   $0x0
  800dd3:	e8 bc f3 ff ff       	call   800194 <sys_page_alloc>
  800dd8:	89 c3                	mov    %eax,%ebx
  800dda:	83 c4 10             	add    $0x10,%esp
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	0f 88 04 01 00 00    	js     800ee9 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800de5:	83 ec 0c             	sub    $0xc,%esp
  800de8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800deb:	50                   	push   %eax
  800dec:	e8 e3 f5 ff ff       	call   8003d4 <fd_alloc>
  800df1:	89 c3                	mov    %eax,%ebx
  800df3:	83 c4 10             	add    $0x10,%esp
  800df6:	85 c0                	test   %eax,%eax
  800df8:	0f 88 db 00 00 00    	js     800ed9 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dfe:	83 ec 04             	sub    $0x4,%esp
  800e01:	68 07 04 00 00       	push   $0x407
  800e06:	ff 75 f0             	pushl  -0x10(%ebp)
  800e09:	6a 00                	push   $0x0
  800e0b:	e8 84 f3 ff ff       	call   800194 <sys_page_alloc>
  800e10:	89 c3                	mov    %eax,%ebx
  800e12:	83 c4 10             	add    $0x10,%esp
  800e15:	85 c0                	test   %eax,%eax
  800e17:	0f 88 bc 00 00 00    	js     800ed9 <pipe+0x135>
	va = fd2data(fd0);
  800e1d:	83 ec 0c             	sub    $0xc,%esp
  800e20:	ff 75 f4             	pushl  -0xc(%ebp)
  800e23:	e8 91 f5 ff ff       	call   8003b9 <fd2data>
  800e28:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e2a:	83 c4 0c             	add    $0xc,%esp
  800e2d:	68 07 04 00 00       	push   $0x407
  800e32:	50                   	push   %eax
  800e33:	6a 00                	push   $0x0
  800e35:	e8 5a f3 ff ff       	call   800194 <sys_page_alloc>
  800e3a:	89 c3                	mov    %eax,%ebx
  800e3c:	83 c4 10             	add    $0x10,%esp
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	0f 88 82 00 00 00    	js     800ec9 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e47:	83 ec 0c             	sub    $0xc,%esp
  800e4a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e4d:	e8 67 f5 ff ff       	call   8003b9 <fd2data>
  800e52:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e59:	50                   	push   %eax
  800e5a:	6a 00                	push   $0x0
  800e5c:	56                   	push   %esi
  800e5d:	6a 00                	push   $0x0
  800e5f:	e8 77 f3 ff ff       	call   8001db <sys_page_map>
  800e64:	89 c3                	mov    %eax,%ebx
  800e66:	83 c4 20             	add    $0x20,%esp
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	78 4e                	js     800ebb <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e6d:	a1 24 30 80 00       	mov    0x803024,%eax
  800e72:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e75:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e77:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e7a:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e81:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e84:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e86:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e89:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e90:	83 ec 0c             	sub    $0xc,%esp
  800e93:	ff 75 f4             	pushl  -0xc(%ebp)
  800e96:	e8 0a f5 ff ff       	call   8003a5 <fd2num>
  800e9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e9e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800ea0:	83 c4 04             	add    $0x4,%esp
  800ea3:	ff 75 f0             	pushl  -0x10(%ebp)
  800ea6:	e8 fa f4 ff ff       	call   8003a5 <fd2num>
  800eab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eae:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800eb1:	83 c4 10             	add    $0x10,%esp
  800eb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb9:	eb 2e                	jmp    800ee9 <pipe+0x145>
	sys_page_unmap(0, va);
  800ebb:	83 ec 08             	sub    $0x8,%esp
  800ebe:	56                   	push   %esi
  800ebf:	6a 00                	push   $0x0
  800ec1:	e8 5b f3 ff ff       	call   800221 <sys_page_unmap>
  800ec6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800ec9:	83 ec 08             	sub    $0x8,%esp
  800ecc:	ff 75 f0             	pushl  -0x10(%ebp)
  800ecf:	6a 00                	push   $0x0
  800ed1:	e8 4b f3 ff ff       	call   800221 <sys_page_unmap>
  800ed6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800ed9:	83 ec 08             	sub    $0x8,%esp
  800edc:	ff 75 f4             	pushl  -0xc(%ebp)
  800edf:	6a 00                	push   $0x0
  800ee1:	e8 3b f3 ff ff       	call   800221 <sys_page_unmap>
  800ee6:	83 c4 10             	add    $0x10,%esp
}
  800ee9:	89 d8                	mov    %ebx,%eax
  800eeb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eee:	5b                   	pop    %ebx
  800eef:	5e                   	pop    %esi
  800ef0:	5d                   	pop    %ebp
  800ef1:	c3                   	ret    

00800ef2 <pipeisclosed>:
{
  800ef2:	f3 0f 1e fb          	endbr32 
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800efc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eff:	50                   	push   %eax
  800f00:	ff 75 08             	pushl  0x8(%ebp)
  800f03:	e8 22 f5 ff ff       	call   80042a <fd_lookup>
  800f08:	83 c4 10             	add    $0x10,%esp
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	78 18                	js     800f27 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800f0f:	83 ec 0c             	sub    $0xc,%esp
  800f12:	ff 75 f4             	pushl  -0xc(%ebp)
  800f15:	e8 9f f4 ff ff       	call   8003b9 <fd2data>
  800f1a:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f1f:	e8 1f fd ff ff       	call   800c43 <_pipeisclosed>
  800f24:	83 c4 10             	add    $0x10,%esp
}
  800f27:	c9                   	leave  
  800f28:	c3                   	ret    

00800f29 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f29:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800f2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f32:	c3                   	ret    

00800f33 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f33:	f3 0f 1e fb          	endbr32 
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f3d:	68 00 20 80 00       	push   $0x802000
  800f42:	ff 75 0c             	pushl  0xc(%ebp)
  800f45:	e8 64 08 00 00       	call   8017ae <strcpy>
	return 0;
}
  800f4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4f:	c9                   	leave  
  800f50:	c3                   	ret    

00800f51 <devcons_write>:
{
  800f51:	f3 0f 1e fb          	endbr32 
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
  800f58:	57                   	push   %edi
  800f59:	56                   	push   %esi
  800f5a:	53                   	push   %ebx
  800f5b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f61:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f66:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f6c:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f6f:	73 31                	jae    800fa2 <devcons_write+0x51>
		m = n - tot;
  800f71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f74:	29 f3                	sub    %esi,%ebx
  800f76:	83 fb 7f             	cmp    $0x7f,%ebx
  800f79:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f7e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f81:	83 ec 04             	sub    $0x4,%esp
  800f84:	53                   	push   %ebx
  800f85:	89 f0                	mov    %esi,%eax
  800f87:	03 45 0c             	add    0xc(%ebp),%eax
  800f8a:	50                   	push   %eax
  800f8b:	57                   	push   %edi
  800f8c:	e8 d3 09 00 00       	call   801964 <memmove>
		sys_cputs(buf, m);
  800f91:	83 c4 08             	add    $0x8,%esp
  800f94:	53                   	push   %ebx
  800f95:	57                   	push   %edi
  800f96:	e8 29 f1 ff ff       	call   8000c4 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f9b:	01 de                	add    %ebx,%esi
  800f9d:	83 c4 10             	add    $0x10,%esp
  800fa0:	eb ca                	jmp    800f6c <devcons_write+0x1b>
}
  800fa2:	89 f0                	mov    %esi,%eax
  800fa4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa7:	5b                   	pop    %ebx
  800fa8:	5e                   	pop    %esi
  800fa9:	5f                   	pop    %edi
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <devcons_read>:
{
  800fac:	f3 0f 1e fb          	endbr32 
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	83 ec 08             	sub    $0x8,%esp
  800fb6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800fbb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fbf:	74 21                	je     800fe2 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800fc1:	e8 20 f1 ff ff       	call   8000e6 <sys_cgetc>
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	75 07                	jne    800fd1 <devcons_read+0x25>
		sys_yield();
  800fca:	e8 a2 f1 ff ff       	call   800171 <sys_yield>
  800fcf:	eb f0                	jmp    800fc1 <devcons_read+0x15>
	if (c < 0)
  800fd1:	78 0f                	js     800fe2 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800fd3:	83 f8 04             	cmp    $0x4,%eax
  800fd6:	74 0c                	je     800fe4 <devcons_read+0x38>
	*(char*)vbuf = c;
  800fd8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fdb:	88 02                	mov    %al,(%edx)
	return 1;
  800fdd:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800fe2:	c9                   	leave  
  800fe3:	c3                   	ret    
		return 0;
  800fe4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe9:	eb f7                	jmp    800fe2 <devcons_read+0x36>

00800feb <cputchar>:
{
  800feb:	f3 0f 1e fb          	endbr32 
  800fef:	55                   	push   %ebp
  800ff0:	89 e5                	mov    %esp,%ebp
  800ff2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800ff5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff8:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800ffb:	6a 01                	push   $0x1
  800ffd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801000:	50                   	push   %eax
  801001:	e8 be f0 ff ff       	call   8000c4 <sys_cputs>
}
  801006:	83 c4 10             	add    $0x10,%esp
  801009:	c9                   	leave  
  80100a:	c3                   	ret    

0080100b <getchar>:
{
  80100b:	f3 0f 1e fb          	endbr32 
  80100f:	55                   	push   %ebp
  801010:	89 e5                	mov    %esp,%ebp
  801012:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801015:	6a 01                	push   $0x1
  801017:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80101a:	50                   	push   %eax
  80101b:	6a 00                	push   $0x0
  80101d:	e8 8b f6 ff ff       	call   8006ad <read>
	if (r < 0)
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	85 c0                	test   %eax,%eax
  801027:	78 06                	js     80102f <getchar+0x24>
	if (r < 1)
  801029:	74 06                	je     801031 <getchar+0x26>
	return c;
  80102b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80102f:	c9                   	leave  
  801030:	c3                   	ret    
		return -E_EOF;
  801031:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801036:	eb f7                	jmp    80102f <getchar+0x24>

00801038 <iscons>:
{
  801038:	f3 0f 1e fb          	endbr32 
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801042:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801045:	50                   	push   %eax
  801046:	ff 75 08             	pushl  0x8(%ebp)
  801049:	e8 dc f3 ff ff       	call   80042a <fd_lookup>
  80104e:	83 c4 10             	add    $0x10,%esp
  801051:	85 c0                	test   %eax,%eax
  801053:	78 11                	js     801066 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801055:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801058:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80105e:	39 10                	cmp    %edx,(%eax)
  801060:	0f 94 c0             	sete   %al
  801063:	0f b6 c0             	movzbl %al,%eax
}
  801066:	c9                   	leave  
  801067:	c3                   	ret    

00801068 <opencons>:
{
  801068:	f3 0f 1e fb          	endbr32 
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801072:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801075:	50                   	push   %eax
  801076:	e8 59 f3 ff ff       	call   8003d4 <fd_alloc>
  80107b:	83 c4 10             	add    $0x10,%esp
  80107e:	85 c0                	test   %eax,%eax
  801080:	78 3a                	js     8010bc <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801082:	83 ec 04             	sub    $0x4,%esp
  801085:	68 07 04 00 00       	push   $0x407
  80108a:	ff 75 f4             	pushl  -0xc(%ebp)
  80108d:	6a 00                	push   $0x0
  80108f:	e8 00 f1 ff ff       	call   800194 <sys_page_alloc>
  801094:	83 c4 10             	add    $0x10,%esp
  801097:	85 c0                	test   %eax,%eax
  801099:	78 21                	js     8010bc <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80109b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80109e:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8010a4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8010a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8010b0:	83 ec 0c             	sub    $0xc,%esp
  8010b3:	50                   	push   %eax
  8010b4:	e8 ec f2 ff ff       	call   8003a5 <fd2num>
  8010b9:	83 c4 10             	add    $0x10,%esp
}
  8010bc:	c9                   	leave  
  8010bd:	c3                   	ret    

008010be <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010be:	f3 0f 1e fb          	endbr32 
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	56                   	push   %esi
  8010c6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010c7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010ca:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8010d0:	e8 79 f0 ff ff       	call   80014e <sys_getenvid>
  8010d5:	83 ec 0c             	sub    $0xc,%esp
  8010d8:	ff 75 0c             	pushl  0xc(%ebp)
  8010db:	ff 75 08             	pushl  0x8(%ebp)
  8010de:	56                   	push   %esi
  8010df:	50                   	push   %eax
  8010e0:	68 0c 20 80 00       	push   $0x80200c
  8010e5:	e8 bb 00 00 00       	call   8011a5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010ea:	83 c4 18             	add    $0x18,%esp
  8010ed:	53                   	push   %ebx
  8010ee:	ff 75 10             	pushl  0x10(%ebp)
  8010f1:	e8 5a 00 00 00       	call   801150 <vcprintf>
	cprintf("\n");
  8010f6:	c7 04 24 f9 1f 80 00 	movl   $0x801ff9,(%esp)
  8010fd:	e8 a3 00 00 00       	call   8011a5 <cprintf>
  801102:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801105:	cc                   	int3   
  801106:	eb fd                	jmp    801105 <_panic+0x47>

00801108 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801108:	f3 0f 1e fb          	endbr32 
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	53                   	push   %ebx
  801110:	83 ec 04             	sub    $0x4,%esp
  801113:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801116:	8b 13                	mov    (%ebx),%edx
  801118:	8d 42 01             	lea    0x1(%edx),%eax
  80111b:	89 03                	mov    %eax,(%ebx)
  80111d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801120:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801124:	3d ff 00 00 00       	cmp    $0xff,%eax
  801129:	74 09                	je     801134 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80112b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80112f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801132:	c9                   	leave  
  801133:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801134:	83 ec 08             	sub    $0x8,%esp
  801137:	68 ff 00 00 00       	push   $0xff
  80113c:	8d 43 08             	lea    0x8(%ebx),%eax
  80113f:	50                   	push   %eax
  801140:	e8 7f ef ff ff       	call   8000c4 <sys_cputs>
		b->idx = 0;
  801145:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80114b:	83 c4 10             	add    $0x10,%esp
  80114e:	eb db                	jmp    80112b <putch+0x23>

00801150 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801150:	f3 0f 1e fb          	endbr32 
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80115d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801164:	00 00 00 
	b.cnt = 0;
  801167:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80116e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801171:	ff 75 0c             	pushl  0xc(%ebp)
  801174:	ff 75 08             	pushl  0x8(%ebp)
  801177:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80117d:	50                   	push   %eax
  80117e:	68 08 11 80 00       	push   $0x801108
  801183:	e8 20 01 00 00       	call   8012a8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801188:	83 c4 08             	add    $0x8,%esp
  80118b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801191:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801197:	50                   	push   %eax
  801198:	e8 27 ef ff ff       	call   8000c4 <sys_cputs>

	return b.cnt;
}
  80119d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8011a3:	c9                   	leave  
  8011a4:	c3                   	ret    

008011a5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8011a5:	f3 0f 1e fb          	endbr32 
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8011af:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8011b2:	50                   	push   %eax
  8011b3:	ff 75 08             	pushl  0x8(%ebp)
  8011b6:	e8 95 ff ff ff       	call   801150 <vcprintf>
	va_end(ap);

	return cnt;
}
  8011bb:	c9                   	leave  
  8011bc:	c3                   	ret    

008011bd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	57                   	push   %edi
  8011c1:	56                   	push   %esi
  8011c2:	53                   	push   %ebx
  8011c3:	83 ec 1c             	sub    $0x1c,%esp
  8011c6:	89 c7                	mov    %eax,%edi
  8011c8:	89 d6                	mov    %edx,%esi
  8011ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d0:	89 d1                	mov    %edx,%ecx
  8011d2:	89 c2                	mov    %eax,%edx
  8011d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011d7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8011da:	8b 45 10             	mov    0x10(%ebp),%eax
  8011dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011e3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8011ea:	39 c2                	cmp    %eax,%edx
  8011ec:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8011ef:	72 3e                	jb     80122f <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011f1:	83 ec 0c             	sub    $0xc,%esp
  8011f4:	ff 75 18             	pushl  0x18(%ebp)
  8011f7:	83 eb 01             	sub    $0x1,%ebx
  8011fa:	53                   	push   %ebx
  8011fb:	50                   	push   %eax
  8011fc:	83 ec 08             	sub    $0x8,%esp
  8011ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  801202:	ff 75 e0             	pushl  -0x20(%ebp)
  801205:	ff 75 dc             	pushl  -0x24(%ebp)
  801208:	ff 75 d8             	pushl  -0x28(%ebp)
  80120b:	e8 50 0a 00 00       	call   801c60 <__udivdi3>
  801210:	83 c4 18             	add    $0x18,%esp
  801213:	52                   	push   %edx
  801214:	50                   	push   %eax
  801215:	89 f2                	mov    %esi,%edx
  801217:	89 f8                	mov    %edi,%eax
  801219:	e8 9f ff ff ff       	call   8011bd <printnum>
  80121e:	83 c4 20             	add    $0x20,%esp
  801221:	eb 13                	jmp    801236 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801223:	83 ec 08             	sub    $0x8,%esp
  801226:	56                   	push   %esi
  801227:	ff 75 18             	pushl  0x18(%ebp)
  80122a:	ff d7                	call   *%edi
  80122c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80122f:	83 eb 01             	sub    $0x1,%ebx
  801232:	85 db                	test   %ebx,%ebx
  801234:	7f ed                	jg     801223 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801236:	83 ec 08             	sub    $0x8,%esp
  801239:	56                   	push   %esi
  80123a:	83 ec 04             	sub    $0x4,%esp
  80123d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801240:	ff 75 e0             	pushl  -0x20(%ebp)
  801243:	ff 75 dc             	pushl  -0x24(%ebp)
  801246:	ff 75 d8             	pushl  -0x28(%ebp)
  801249:	e8 22 0b 00 00       	call   801d70 <__umoddi3>
  80124e:	83 c4 14             	add    $0x14,%esp
  801251:	0f be 80 2f 20 80 00 	movsbl 0x80202f(%eax),%eax
  801258:	50                   	push   %eax
  801259:	ff d7                	call   *%edi
}
  80125b:	83 c4 10             	add    $0x10,%esp
  80125e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801261:	5b                   	pop    %ebx
  801262:	5e                   	pop    %esi
  801263:	5f                   	pop    %edi
  801264:	5d                   	pop    %ebp
  801265:	c3                   	ret    

00801266 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801266:	f3 0f 1e fb          	endbr32 
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801270:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801274:	8b 10                	mov    (%eax),%edx
  801276:	3b 50 04             	cmp    0x4(%eax),%edx
  801279:	73 0a                	jae    801285 <sprintputch+0x1f>
		*b->buf++ = ch;
  80127b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80127e:	89 08                	mov    %ecx,(%eax)
  801280:	8b 45 08             	mov    0x8(%ebp),%eax
  801283:	88 02                	mov    %al,(%edx)
}
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    

00801287 <printfmt>:
{
  801287:	f3 0f 1e fb          	endbr32 
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801291:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801294:	50                   	push   %eax
  801295:	ff 75 10             	pushl  0x10(%ebp)
  801298:	ff 75 0c             	pushl  0xc(%ebp)
  80129b:	ff 75 08             	pushl  0x8(%ebp)
  80129e:	e8 05 00 00 00       	call   8012a8 <vprintfmt>
}
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	c9                   	leave  
  8012a7:	c3                   	ret    

008012a8 <vprintfmt>:
{
  8012a8:	f3 0f 1e fb          	endbr32 
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	57                   	push   %edi
  8012b0:	56                   	push   %esi
  8012b1:	53                   	push   %ebx
  8012b2:	83 ec 3c             	sub    $0x3c,%esp
  8012b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8012b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012bb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012be:	e9 4a 03 00 00       	jmp    80160d <vprintfmt+0x365>
		padc = ' ';
  8012c3:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012c7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012ce:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012d5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012dc:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012e1:	8d 47 01             	lea    0x1(%edi),%eax
  8012e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012e7:	0f b6 17             	movzbl (%edi),%edx
  8012ea:	8d 42 dd             	lea    -0x23(%edx),%eax
  8012ed:	3c 55                	cmp    $0x55,%al
  8012ef:	0f 87 de 03 00 00    	ja     8016d3 <vprintfmt+0x42b>
  8012f5:	0f b6 c0             	movzbl %al,%eax
  8012f8:	3e ff 24 85 80 21 80 	notrack jmp *0x802180(,%eax,4)
  8012ff:	00 
  801300:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801303:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801307:	eb d8                	jmp    8012e1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801309:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80130c:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801310:	eb cf                	jmp    8012e1 <vprintfmt+0x39>
  801312:	0f b6 d2             	movzbl %dl,%edx
  801315:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801318:	b8 00 00 00 00       	mov    $0x0,%eax
  80131d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801320:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801323:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801327:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80132a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80132d:	83 f9 09             	cmp    $0x9,%ecx
  801330:	77 55                	ja     801387 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  801332:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801335:	eb e9                	jmp    801320 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801337:	8b 45 14             	mov    0x14(%ebp),%eax
  80133a:	8b 00                	mov    (%eax),%eax
  80133c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80133f:	8b 45 14             	mov    0x14(%ebp),%eax
  801342:	8d 40 04             	lea    0x4(%eax),%eax
  801345:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801348:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80134b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80134f:	79 90                	jns    8012e1 <vprintfmt+0x39>
				width = precision, precision = -1;
  801351:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801354:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801357:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80135e:	eb 81                	jmp    8012e1 <vprintfmt+0x39>
  801360:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801363:	85 c0                	test   %eax,%eax
  801365:	ba 00 00 00 00       	mov    $0x0,%edx
  80136a:	0f 49 d0             	cmovns %eax,%edx
  80136d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801373:	e9 69 ff ff ff       	jmp    8012e1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80137b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801382:	e9 5a ff ff ff       	jmp    8012e1 <vprintfmt+0x39>
  801387:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80138a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80138d:	eb bc                	jmp    80134b <vprintfmt+0xa3>
			lflag++;
  80138f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801395:	e9 47 ff ff ff       	jmp    8012e1 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80139a:	8b 45 14             	mov    0x14(%ebp),%eax
  80139d:	8d 78 04             	lea    0x4(%eax),%edi
  8013a0:	83 ec 08             	sub    $0x8,%esp
  8013a3:	53                   	push   %ebx
  8013a4:	ff 30                	pushl  (%eax)
  8013a6:	ff d6                	call   *%esi
			break;
  8013a8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8013ab:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8013ae:	e9 57 02 00 00       	jmp    80160a <vprintfmt+0x362>
			err = va_arg(ap, int);
  8013b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b6:	8d 78 04             	lea    0x4(%eax),%edi
  8013b9:	8b 00                	mov    (%eax),%eax
  8013bb:	99                   	cltd   
  8013bc:	31 d0                	xor    %edx,%eax
  8013be:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013c0:	83 f8 0f             	cmp    $0xf,%eax
  8013c3:	7f 23                	jg     8013e8 <vprintfmt+0x140>
  8013c5:	8b 14 85 e0 22 80 00 	mov    0x8022e0(,%eax,4),%edx
  8013cc:	85 d2                	test   %edx,%edx
  8013ce:	74 18                	je     8013e8 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8013d0:	52                   	push   %edx
  8013d1:	68 d2 1f 80 00       	push   $0x801fd2
  8013d6:	53                   	push   %ebx
  8013d7:	56                   	push   %esi
  8013d8:	e8 aa fe ff ff       	call   801287 <printfmt>
  8013dd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8013e0:	89 7d 14             	mov    %edi,0x14(%ebp)
  8013e3:	e9 22 02 00 00       	jmp    80160a <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8013e8:	50                   	push   %eax
  8013e9:	68 47 20 80 00       	push   $0x802047
  8013ee:	53                   	push   %ebx
  8013ef:	56                   	push   %esi
  8013f0:	e8 92 fe ff ff       	call   801287 <printfmt>
  8013f5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8013f8:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8013fb:	e9 0a 02 00 00       	jmp    80160a <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  801400:	8b 45 14             	mov    0x14(%ebp),%eax
  801403:	83 c0 04             	add    $0x4,%eax
  801406:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801409:	8b 45 14             	mov    0x14(%ebp),%eax
  80140c:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80140e:	85 d2                	test   %edx,%edx
  801410:	b8 40 20 80 00       	mov    $0x802040,%eax
  801415:	0f 45 c2             	cmovne %edx,%eax
  801418:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80141b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80141f:	7e 06                	jle    801427 <vprintfmt+0x17f>
  801421:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801425:	75 0d                	jne    801434 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  801427:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80142a:	89 c7                	mov    %eax,%edi
  80142c:	03 45 e0             	add    -0x20(%ebp),%eax
  80142f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801432:	eb 55                	jmp    801489 <vprintfmt+0x1e1>
  801434:	83 ec 08             	sub    $0x8,%esp
  801437:	ff 75 d8             	pushl  -0x28(%ebp)
  80143a:	ff 75 cc             	pushl  -0x34(%ebp)
  80143d:	e8 45 03 00 00       	call   801787 <strnlen>
  801442:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801445:	29 c2                	sub    %eax,%edx
  801447:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80144f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801453:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801456:	85 ff                	test   %edi,%edi
  801458:	7e 11                	jle    80146b <vprintfmt+0x1c3>
					putch(padc, putdat);
  80145a:	83 ec 08             	sub    $0x8,%esp
  80145d:	53                   	push   %ebx
  80145e:	ff 75 e0             	pushl  -0x20(%ebp)
  801461:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801463:	83 ef 01             	sub    $0x1,%edi
  801466:	83 c4 10             	add    $0x10,%esp
  801469:	eb eb                	jmp    801456 <vprintfmt+0x1ae>
  80146b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80146e:	85 d2                	test   %edx,%edx
  801470:	b8 00 00 00 00       	mov    $0x0,%eax
  801475:	0f 49 c2             	cmovns %edx,%eax
  801478:	29 c2                	sub    %eax,%edx
  80147a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80147d:	eb a8                	jmp    801427 <vprintfmt+0x17f>
					putch(ch, putdat);
  80147f:	83 ec 08             	sub    $0x8,%esp
  801482:	53                   	push   %ebx
  801483:	52                   	push   %edx
  801484:	ff d6                	call   *%esi
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80148c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80148e:	83 c7 01             	add    $0x1,%edi
  801491:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801495:	0f be d0             	movsbl %al,%edx
  801498:	85 d2                	test   %edx,%edx
  80149a:	74 4b                	je     8014e7 <vprintfmt+0x23f>
  80149c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014a0:	78 06                	js     8014a8 <vprintfmt+0x200>
  8014a2:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014a6:	78 1e                	js     8014c6 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8014a8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014ac:	74 d1                	je     80147f <vprintfmt+0x1d7>
  8014ae:	0f be c0             	movsbl %al,%eax
  8014b1:	83 e8 20             	sub    $0x20,%eax
  8014b4:	83 f8 5e             	cmp    $0x5e,%eax
  8014b7:	76 c6                	jbe    80147f <vprintfmt+0x1d7>
					putch('?', putdat);
  8014b9:	83 ec 08             	sub    $0x8,%esp
  8014bc:	53                   	push   %ebx
  8014bd:	6a 3f                	push   $0x3f
  8014bf:	ff d6                	call   *%esi
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	eb c3                	jmp    801489 <vprintfmt+0x1e1>
  8014c6:	89 cf                	mov    %ecx,%edi
  8014c8:	eb 0e                	jmp    8014d8 <vprintfmt+0x230>
				putch(' ', putdat);
  8014ca:	83 ec 08             	sub    $0x8,%esp
  8014cd:	53                   	push   %ebx
  8014ce:	6a 20                	push   $0x20
  8014d0:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8014d2:	83 ef 01             	sub    $0x1,%edi
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	85 ff                	test   %edi,%edi
  8014da:	7f ee                	jg     8014ca <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8014dc:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8014df:	89 45 14             	mov    %eax,0x14(%ebp)
  8014e2:	e9 23 01 00 00       	jmp    80160a <vprintfmt+0x362>
  8014e7:	89 cf                	mov    %ecx,%edi
  8014e9:	eb ed                	jmp    8014d8 <vprintfmt+0x230>
	if (lflag >= 2)
  8014eb:	83 f9 01             	cmp    $0x1,%ecx
  8014ee:	7f 1b                	jg     80150b <vprintfmt+0x263>
	else if (lflag)
  8014f0:	85 c9                	test   %ecx,%ecx
  8014f2:	74 63                	je     801557 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8014f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f7:	8b 00                	mov    (%eax),%eax
  8014f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014fc:	99                   	cltd   
  8014fd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801500:	8b 45 14             	mov    0x14(%ebp),%eax
  801503:	8d 40 04             	lea    0x4(%eax),%eax
  801506:	89 45 14             	mov    %eax,0x14(%ebp)
  801509:	eb 17                	jmp    801522 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80150b:	8b 45 14             	mov    0x14(%ebp),%eax
  80150e:	8b 50 04             	mov    0x4(%eax),%edx
  801511:	8b 00                	mov    (%eax),%eax
  801513:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801516:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801519:	8b 45 14             	mov    0x14(%ebp),%eax
  80151c:	8d 40 08             	lea    0x8(%eax),%eax
  80151f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801522:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801525:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801528:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80152d:	85 c9                	test   %ecx,%ecx
  80152f:	0f 89 bb 00 00 00    	jns    8015f0 <vprintfmt+0x348>
				putch('-', putdat);
  801535:	83 ec 08             	sub    $0x8,%esp
  801538:	53                   	push   %ebx
  801539:	6a 2d                	push   $0x2d
  80153b:	ff d6                	call   *%esi
				num = -(long long) num;
  80153d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801540:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801543:	f7 da                	neg    %edx
  801545:	83 d1 00             	adc    $0x0,%ecx
  801548:	f7 d9                	neg    %ecx
  80154a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80154d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801552:	e9 99 00 00 00       	jmp    8015f0 <vprintfmt+0x348>
		return va_arg(*ap, int);
  801557:	8b 45 14             	mov    0x14(%ebp),%eax
  80155a:	8b 00                	mov    (%eax),%eax
  80155c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80155f:	99                   	cltd   
  801560:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801563:	8b 45 14             	mov    0x14(%ebp),%eax
  801566:	8d 40 04             	lea    0x4(%eax),%eax
  801569:	89 45 14             	mov    %eax,0x14(%ebp)
  80156c:	eb b4                	jmp    801522 <vprintfmt+0x27a>
	if (lflag >= 2)
  80156e:	83 f9 01             	cmp    $0x1,%ecx
  801571:	7f 1b                	jg     80158e <vprintfmt+0x2e6>
	else if (lflag)
  801573:	85 c9                	test   %ecx,%ecx
  801575:	74 2c                	je     8015a3 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  801577:	8b 45 14             	mov    0x14(%ebp),%eax
  80157a:	8b 10                	mov    (%eax),%edx
  80157c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801581:	8d 40 04             	lea    0x4(%eax),%eax
  801584:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801587:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80158c:	eb 62                	jmp    8015f0 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80158e:	8b 45 14             	mov    0x14(%ebp),%eax
  801591:	8b 10                	mov    (%eax),%edx
  801593:	8b 48 04             	mov    0x4(%eax),%ecx
  801596:	8d 40 08             	lea    0x8(%eax),%eax
  801599:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80159c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8015a1:	eb 4d                	jmp    8015f0 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8015a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a6:	8b 10                	mov    (%eax),%edx
  8015a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015ad:	8d 40 04             	lea    0x4(%eax),%eax
  8015b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015b3:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8015b8:	eb 36                	jmp    8015f0 <vprintfmt+0x348>
	if (lflag >= 2)
  8015ba:	83 f9 01             	cmp    $0x1,%ecx
  8015bd:	7f 17                	jg     8015d6 <vprintfmt+0x32e>
	else if (lflag)
  8015bf:	85 c9                	test   %ecx,%ecx
  8015c1:	74 6e                	je     801631 <vprintfmt+0x389>
		return va_arg(*ap, long);
  8015c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c6:	8b 10                	mov    (%eax),%edx
  8015c8:	89 d0                	mov    %edx,%eax
  8015ca:	99                   	cltd   
  8015cb:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015ce:	8d 49 04             	lea    0x4(%ecx),%ecx
  8015d1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8015d4:	eb 11                	jmp    8015e7 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8015d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d9:	8b 50 04             	mov    0x4(%eax),%edx
  8015dc:	8b 00                	mov    (%eax),%eax
  8015de:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015e1:	8d 49 08             	lea    0x8(%ecx),%ecx
  8015e4:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8015e7:	89 d1                	mov    %edx,%ecx
  8015e9:	89 c2                	mov    %eax,%edx
            base = 8;
  8015eb:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8015f0:	83 ec 0c             	sub    $0xc,%esp
  8015f3:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8015f7:	57                   	push   %edi
  8015f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8015fb:	50                   	push   %eax
  8015fc:	51                   	push   %ecx
  8015fd:	52                   	push   %edx
  8015fe:	89 da                	mov    %ebx,%edx
  801600:	89 f0                	mov    %esi,%eax
  801602:	e8 b6 fb ff ff       	call   8011bd <printnum>
			break;
  801607:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80160a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80160d:	83 c7 01             	add    $0x1,%edi
  801610:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801614:	83 f8 25             	cmp    $0x25,%eax
  801617:	0f 84 a6 fc ff ff    	je     8012c3 <vprintfmt+0x1b>
			if (ch == '\0')
  80161d:	85 c0                	test   %eax,%eax
  80161f:	0f 84 ce 00 00 00    	je     8016f3 <vprintfmt+0x44b>
			putch(ch, putdat);
  801625:	83 ec 08             	sub    $0x8,%esp
  801628:	53                   	push   %ebx
  801629:	50                   	push   %eax
  80162a:	ff d6                	call   *%esi
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	eb dc                	jmp    80160d <vprintfmt+0x365>
		return va_arg(*ap, int);
  801631:	8b 45 14             	mov    0x14(%ebp),%eax
  801634:	8b 10                	mov    (%eax),%edx
  801636:	89 d0                	mov    %edx,%eax
  801638:	99                   	cltd   
  801639:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80163c:	8d 49 04             	lea    0x4(%ecx),%ecx
  80163f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801642:	eb a3                	jmp    8015e7 <vprintfmt+0x33f>
			putch('0', putdat);
  801644:	83 ec 08             	sub    $0x8,%esp
  801647:	53                   	push   %ebx
  801648:	6a 30                	push   $0x30
  80164a:	ff d6                	call   *%esi
			putch('x', putdat);
  80164c:	83 c4 08             	add    $0x8,%esp
  80164f:	53                   	push   %ebx
  801650:	6a 78                	push   $0x78
  801652:	ff d6                	call   *%esi
			num = (unsigned long long)
  801654:	8b 45 14             	mov    0x14(%ebp),%eax
  801657:	8b 10                	mov    (%eax),%edx
  801659:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80165e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801661:	8d 40 04             	lea    0x4(%eax),%eax
  801664:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801667:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80166c:	eb 82                	jmp    8015f0 <vprintfmt+0x348>
	if (lflag >= 2)
  80166e:	83 f9 01             	cmp    $0x1,%ecx
  801671:	7f 1e                	jg     801691 <vprintfmt+0x3e9>
	else if (lflag)
  801673:	85 c9                	test   %ecx,%ecx
  801675:	74 32                	je     8016a9 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  801677:	8b 45 14             	mov    0x14(%ebp),%eax
  80167a:	8b 10                	mov    (%eax),%edx
  80167c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801681:	8d 40 04             	lea    0x4(%eax),%eax
  801684:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801687:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80168c:	e9 5f ff ff ff       	jmp    8015f0 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  801691:	8b 45 14             	mov    0x14(%ebp),%eax
  801694:	8b 10                	mov    (%eax),%edx
  801696:	8b 48 04             	mov    0x4(%eax),%ecx
  801699:	8d 40 08             	lea    0x8(%eax),%eax
  80169c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80169f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8016a4:	e9 47 ff ff ff       	jmp    8015f0 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8016a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8016ac:	8b 10                	mov    (%eax),%edx
  8016ae:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016b3:	8d 40 04             	lea    0x4(%eax),%eax
  8016b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016b9:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8016be:	e9 2d ff ff ff       	jmp    8015f0 <vprintfmt+0x348>
			putch(ch, putdat);
  8016c3:	83 ec 08             	sub    $0x8,%esp
  8016c6:	53                   	push   %ebx
  8016c7:	6a 25                	push   $0x25
  8016c9:	ff d6                	call   *%esi
			break;
  8016cb:	83 c4 10             	add    $0x10,%esp
  8016ce:	e9 37 ff ff ff       	jmp    80160a <vprintfmt+0x362>
			putch('%', putdat);
  8016d3:	83 ec 08             	sub    $0x8,%esp
  8016d6:	53                   	push   %ebx
  8016d7:	6a 25                	push   $0x25
  8016d9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	89 f8                	mov    %edi,%eax
  8016e0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8016e4:	74 05                	je     8016eb <vprintfmt+0x443>
  8016e6:	83 e8 01             	sub    $0x1,%eax
  8016e9:	eb f5                	jmp    8016e0 <vprintfmt+0x438>
  8016eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016ee:	e9 17 ff ff ff       	jmp    80160a <vprintfmt+0x362>
}
  8016f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f6:	5b                   	pop    %ebx
  8016f7:	5e                   	pop    %esi
  8016f8:	5f                   	pop    %edi
  8016f9:	5d                   	pop    %ebp
  8016fa:	c3                   	ret    

008016fb <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8016fb:	f3 0f 1e fb          	endbr32 
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	83 ec 18             	sub    $0x18,%esp
  801705:	8b 45 08             	mov    0x8(%ebp),%eax
  801708:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80170b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80170e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801712:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801715:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80171c:	85 c0                	test   %eax,%eax
  80171e:	74 26                	je     801746 <vsnprintf+0x4b>
  801720:	85 d2                	test   %edx,%edx
  801722:	7e 22                	jle    801746 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801724:	ff 75 14             	pushl  0x14(%ebp)
  801727:	ff 75 10             	pushl  0x10(%ebp)
  80172a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80172d:	50                   	push   %eax
  80172e:	68 66 12 80 00       	push   $0x801266
  801733:	e8 70 fb ff ff       	call   8012a8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801738:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80173b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80173e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801741:	83 c4 10             	add    $0x10,%esp
}
  801744:	c9                   	leave  
  801745:	c3                   	ret    
		return -E_INVAL;
  801746:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80174b:	eb f7                	jmp    801744 <vsnprintf+0x49>

0080174d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80174d:	f3 0f 1e fb          	endbr32 
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801757:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80175a:	50                   	push   %eax
  80175b:	ff 75 10             	pushl  0x10(%ebp)
  80175e:	ff 75 0c             	pushl  0xc(%ebp)
  801761:	ff 75 08             	pushl  0x8(%ebp)
  801764:	e8 92 ff ff ff       	call   8016fb <vsnprintf>
	va_end(ap);

	return rc;
}
  801769:	c9                   	leave  
  80176a:	c3                   	ret    

0080176b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80176b:	f3 0f 1e fb          	endbr32 
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801775:	b8 00 00 00 00       	mov    $0x0,%eax
  80177a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80177e:	74 05                	je     801785 <strlen+0x1a>
		n++;
  801780:	83 c0 01             	add    $0x1,%eax
  801783:	eb f5                	jmp    80177a <strlen+0xf>
	return n;
}
  801785:	5d                   	pop    %ebp
  801786:	c3                   	ret    

00801787 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801787:	f3 0f 1e fb          	endbr32 
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801791:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801794:	b8 00 00 00 00       	mov    $0x0,%eax
  801799:	39 d0                	cmp    %edx,%eax
  80179b:	74 0d                	je     8017aa <strnlen+0x23>
  80179d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8017a1:	74 05                	je     8017a8 <strnlen+0x21>
		n++;
  8017a3:	83 c0 01             	add    $0x1,%eax
  8017a6:	eb f1                	jmp    801799 <strnlen+0x12>
  8017a8:	89 c2                	mov    %eax,%edx
	return n;
}
  8017aa:	89 d0                	mov    %edx,%eax
  8017ac:	5d                   	pop    %ebp
  8017ad:	c3                   	ret    

008017ae <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8017ae:	f3 0f 1e fb          	endbr32 
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	53                   	push   %ebx
  8017b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8017bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8017c5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8017c8:	83 c0 01             	add    $0x1,%eax
  8017cb:	84 d2                	test   %dl,%dl
  8017cd:	75 f2                	jne    8017c1 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8017cf:	89 c8                	mov    %ecx,%eax
  8017d1:	5b                   	pop    %ebx
  8017d2:	5d                   	pop    %ebp
  8017d3:	c3                   	ret    

008017d4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017d4:	f3 0f 1e fb          	endbr32 
  8017d8:	55                   	push   %ebp
  8017d9:	89 e5                	mov    %esp,%ebp
  8017db:	53                   	push   %ebx
  8017dc:	83 ec 10             	sub    $0x10,%esp
  8017df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8017e2:	53                   	push   %ebx
  8017e3:	e8 83 ff ff ff       	call   80176b <strlen>
  8017e8:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8017eb:	ff 75 0c             	pushl  0xc(%ebp)
  8017ee:	01 d8                	add    %ebx,%eax
  8017f0:	50                   	push   %eax
  8017f1:	e8 b8 ff ff ff       	call   8017ae <strcpy>
	return dst;
}
  8017f6:	89 d8                	mov    %ebx,%eax
  8017f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017fb:	c9                   	leave  
  8017fc:	c3                   	ret    

008017fd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8017fd:	f3 0f 1e fb          	endbr32 
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	56                   	push   %esi
  801805:	53                   	push   %ebx
  801806:	8b 75 08             	mov    0x8(%ebp),%esi
  801809:	8b 55 0c             	mov    0xc(%ebp),%edx
  80180c:	89 f3                	mov    %esi,%ebx
  80180e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801811:	89 f0                	mov    %esi,%eax
  801813:	39 d8                	cmp    %ebx,%eax
  801815:	74 11                	je     801828 <strncpy+0x2b>
		*dst++ = *src;
  801817:	83 c0 01             	add    $0x1,%eax
  80181a:	0f b6 0a             	movzbl (%edx),%ecx
  80181d:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801820:	80 f9 01             	cmp    $0x1,%cl
  801823:	83 da ff             	sbb    $0xffffffff,%edx
  801826:	eb eb                	jmp    801813 <strncpy+0x16>
	}
	return ret;
}
  801828:	89 f0                	mov    %esi,%eax
  80182a:	5b                   	pop    %ebx
  80182b:	5e                   	pop    %esi
  80182c:	5d                   	pop    %ebp
  80182d:	c3                   	ret    

0080182e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80182e:	f3 0f 1e fb          	endbr32 
  801832:	55                   	push   %ebp
  801833:	89 e5                	mov    %esp,%ebp
  801835:	56                   	push   %esi
  801836:	53                   	push   %ebx
  801837:	8b 75 08             	mov    0x8(%ebp),%esi
  80183a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80183d:	8b 55 10             	mov    0x10(%ebp),%edx
  801840:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801842:	85 d2                	test   %edx,%edx
  801844:	74 21                	je     801867 <strlcpy+0x39>
  801846:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80184a:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80184c:	39 c2                	cmp    %eax,%edx
  80184e:	74 14                	je     801864 <strlcpy+0x36>
  801850:	0f b6 19             	movzbl (%ecx),%ebx
  801853:	84 db                	test   %bl,%bl
  801855:	74 0b                	je     801862 <strlcpy+0x34>
			*dst++ = *src++;
  801857:	83 c1 01             	add    $0x1,%ecx
  80185a:	83 c2 01             	add    $0x1,%edx
  80185d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801860:	eb ea                	jmp    80184c <strlcpy+0x1e>
  801862:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801864:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801867:	29 f0                	sub    %esi,%eax
}
  801869:	5b                   	pop    %ebx
  80186a:	5e                   	pop    %esi
  80186b:	5d                   	pop    %ebp
  80186c:	c3                   	ret    

0080186d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80186d:	f3 0f 1e fb          	endbr32 
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801877:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80187a:	0f b6 01             	movzbl (%ecx),%eax
  80187d:	84 c0                	test   %al,%al
  80187f:	74 0c                	je     80188d <strcmp+0x20>
  801881:	3a 02                	cmp    (%edx),%al
  801883:	75 08                	jne    80188d <strcmp+0x20>
		p++, q++;
  801885:	83 c1 01             	add    $0x1,%ecx
  801888:	83 c2 01             	add    $0x1,%edx
  80188b:	eb ed                	jmp    80187a <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80188d:	0f b6 c0             	movzbl %al,%eax
  801890:	0f b6 12             	movzbl (%edx),%edx
  801893:	29 d0                	sub    %edx,%eax
}
  801895:	5d                   	pop    %ebp
  801896:	c3                   	ret    

00801897 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801897:	f3 0f 1e fb          	endbr32 
  80189b:	55                   	push   %ebp
  80189c:	89 e5                	mov    %esp,%ebp
  80189e:	53                   	push   %ebx
  80189f:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018a5:	89 c3                	mov    %eax,%ebx
  8018a7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8018aa:	eb 06                	jmp    8018b2 <strncmp+0x1b>
		n--, p++, q++;
  8018ac:	83 c0 01             	add    $0x1,%eax
  8018af:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8018b2:	39 d8                	cmp    %ebx,%eax
  8018b4:	74 16                	je     8018cc <strncmp+0x35>
  8018b6:	0f b6 08             	movzbl (%eax),%ecx
  8018b9:	84 c9                	test   %cl,%cl
  8018bb:	74 04                	je     8018c1 <strncmp+0x2a>
  8018bd:	3a 0a                	cmp    (%edx),%cl
  8018bf:	74 eb                	je     8018ac <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8018c1:	0f b6 00             	movzbl (%eax),%eax
  8018c4:	0f b6 12             	movzbl (%edx),%edx
  8018c7:	29 d0                	sub    %edx,%eax
}
  8018c9:	5b                   	pop    %ebx
  8018ca:	5d                   	pop    %ebp
  8018cb:	c3                   	ret    
		return 0;
  8018cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d1:	eb f6                	jmp    8018c9 <strncmp+0x32>

008018d3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8018d3:	f3 0f 1e fb          	endbr32 
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018e1:	0f b6 10             	movzbl (%eax),%edx
  8018e4:	84 d2                	test   %dl,%dl
  8018e6:	74 09                	je     8018f1 <strchr+0x1e>
		if (*s == c)
  8018e8:	38 ca                	cmp    %cl,%dl
  8018ea:	74 0a                	je     8018f6 <strchr+0x23>
	for (; *s; s++)
  8018ec:	83 c0 01             	add    $0x1,%eax
  8018ef:	eb f0                	jmp    8018e1 <strchr+0xe>
			return (char *) s;
	return 0;
  8018f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f6:	5d                   	pop    %ebp
  8018f7:	c3                   	ret    

008018f8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8018f8:	f3 0f 1e fb          	endbr32 
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801902:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801906:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801909:	38 ca                	cmp    %cl,%dl
  80190b:	74 09                	je     801916 <strfind+0x1e>
  80190d:	84 d2                	test   %dl,%dl
  80190f:	74 05                	je     801916 <strfind+0x1e>
	for (; *s; s++)
  801911:	83 c0 01             	add    $0x1,%eax
  801914:	eb f0                	jmp    801906 <strfind+0xe>
			break;
	return (char *) s;
}
  801916:	5d                   	pop    %ebp
  801917:	c3                   	ret    

00801918 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801918:	f3 0f 1e fb          	endbr32 
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	57                   	push   %edi
  801920:	56                   	push   %esi
  801921:	53                   	push   %ebx
  801922:	8b 7d 08             	mov    0x8(%ebp),%edi
  801925:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801928:	85 c9                	test   %ecx,%ecx
  80192a:	74 31                	je     80195d <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80192c:	89 f8                	mov    %edi,%eax
  80192e:	09 c8                	or     %ecx,%eax
  801930:	a8 03                	test   $0x3,%al
  801932:	75 23                	jne    801957 <memset+0x3f>
		c &= 0xFF;
  801934:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801938:	89 d3                	mov    %edx,%ebx
  80193a:	c1 e3 08             	shl    $0x8,%ebx
  80193d:	89 d0                	mov    %edx,%eax
  80193f:	c1 e0 18             	shl    $0x18,%eax
  801942:	89 d6                	mov    %edx,%esi
  801944:	c1 e6 10             	shl    $0x10,%esi
  801947:	09 f0                	or     %esi,%eax
  801949:	09 c2                	or     %eax,%edx
  80194b:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80194d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801950:	89 d0                	mov    %edx,%eax
  801952:	fc                   	cld    
  801953:	f3 ab                	rep stos %eax,%es:(%edi)
  801955:	eb 06                	jmp    80195d <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801957:	8b 45 0c             	mov    0xc(%ebp),%eax
  80195a:	fc                   	cld    
  80195b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80195d:	89 f8                	mov    %edi,%eax
  80195f:	5b                   	pop    %ebx
  801960:	5e                   	pop    %esi
  801961:	5f                   	pop    %edi
  801962:	5d                   	pop    %ebp
  801963:	c3                   	ret    

00801964 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801964:	f3 0f 1e fb          	endbr32 
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	57                   	push   %edi
  80196c:	56                   	push   %esi
  80196d:	8b 45 08             	mov    0x8(%ebp),%eax
  801970:	8b 75 0c             	mov    0xc(%ebp),%esi
  801973:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801976:	39 c6                	cmp    %eax,%esi
  801978:	73 32                	jae    8019ac <memmove+0x48>
  80197a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80197d:	39 c2                	cmp    %eax,%edx
  80197f:	76 2b                	jbe    8019ac <memmove+0x48>
		s += n;
		d += n;
  801981:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801984:	89 fe                	mov    %edi,%esi
  801986:	09 ce                	or     %ecx,%esi
  801988:	09 d6                	or     %edx,%esi
  80198a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801990:	75 0e                	jne    8019a0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801992:	83 ef 04             	sub    $0x4,%edi
  801995:	8d 72 fc             	lea    -0x4(%edx),%esi
  801998:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80199b:	fd                   	std    
  80199c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80199e:	eb 09                	jmp    8019a9 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8019a0:	83 ef 01             	sub    $0x1,%edi
  8019a3:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8019a6:	fd                   	std    
  8019a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8019a9:	fc                   	cld    
  8019aa:	eb 1a                	jmp    8019c6 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019ac:	89 c2                	mov    %eax,%edx
  8019ae:	09 ca                	or     %ecx,%edx
  8019b0:	09 f2                	or     %esi,%edx
  8019b2:	f6 c2 03             	test   $0x3,%dl
  8019b5:	75 0a                	jne    8019c1 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8019b7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8019ba:	89 c7                	mov    %eax,%edi
  8019bc:	fc                   	cld    
  8019bd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019bf:	eb 05                	jmp    8019c6 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8019c1:	89 c7                	mov    %eax,%edi
  8019c3:	fc                   	cld    
  8019c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8019c6:	5e                   	pop    %esi
  8019c7:	5f                   	pop    %edi
  8019c8:	5d                   	pop    %ebp
  8019c9:	c3                   	ret    

008019ca <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8019ca:	f3 0f 1e fb          	endbr32 
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8019d4:	ff 75 10             	pushl  0x10(%ebp)
  8019d7:	ff 75 0c             	pushl  0xc(%ebp)
  8019da:	ff 75 08             	pushl  0x8(%ebp)
  8019dd:	e8 82 ff ff ff       	call   801964 <memmove>
}
  8019e2:	c9                   	leave  
  8019e3:	c3                   	ret    

008019e4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8019e4:	f3 0f 1e fb          	endbr32 
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	56                   	push   %esi
  8019ec:	53                   	push   %ebx
  8019ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019f3:	89 c6                	mov    %eax,%esi
  8019f5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019f8:	39 f0                	cmp    %esi,%eax
  8019fa:	74 1c                	je     801a18 <memcmp+0x34>
		if (*s1 != *s2)
  8019fc:	0f b6 08             	movzbl (%eax),%ecx
  8019ff:	0f b6 1a             	movzbl (%edx),%ebx
  801a02:	38 d9                	cmp    %bl,%cl
  801a04:	75 08                	jne    801a0e <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801a06:	83 c0 01             	add    $0x1,%eax
  801a09:	83 c2 01             	add    $0x1,%edx
  801a0c:	eb ea                	jmp    8019f8 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801a0e:	0f b6 c1             	movzbl %cl,%eax
  801a11:	0f b6 db             	movzbl %bl,%ebx
  801a14:	29 d8                	sub    %ebx,%eax
  801a16:	eb 05                	jmp    801a1d <memcmp+0x39>
	}

	return 0;
  801a18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a1d:	5b                   	pop    %ebx
  801a1e:	5e                   	pop    %esi
  801a1f:	5d                   	pop    %ebp
  801a20:	c3                   	ret    

00801a21 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a21:	f3 0f 1e fb          	endbr32 
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a2e:	89 c2                	mov    %eax,%edx
  801a30:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a33:	39 d0                	cmp    %edx,%eax
  801a35:	73 09                	jae    801a40 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a37:	38 08                	cmp    %cl,(%eax)
  801a39:	74 05                	je     801a40 <memfind+0x1f>
	for (; s < ends; s++)
  801a3b:	83 c0 01             	add    $0x1,%eax
  801a3e:	eb f3                	jmp    801a33 <memfind+0x12>
			break;
	return (void *) s;
}
  801a40:	5d                   	pop    %ebp
  801a41:	c3                   	ret    

00801a42 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a42:	f3 0f 1e fb          	endbr32 
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	57                   	push   %edi
  801a4a:	56                   	push   %esi
  801a4b:	53                   	push   %ebx
  801a4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a52:	eb 03                	jmp    801a57 <strtol+0x15>
		s++;
  801a54:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801a57:	0f b6 01             	movzbl (%ecx),%eax
  801a5a:	3c 20                	cmp    $0x20,%al
  801a5c:	74 f6                	je     801a54 <strtol+0x12>
  801a5e:	3c 09                	cmp    $0x9,%al
  801a60:	74 f2                	je     801a54 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801a62:	3c 2b                	cmp    $0x2b,%al
  801a64:	74 2a                	je     801a90 <strtol+0x4e>
	int neg = 0;
  801a66:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801a6b:	3c 2d                	cmp    $0x2d,%al
  801a6d:	74 2b                	je     801a9a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a6f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a75:	75 0f                	jne    801a86 <strtol+0x44>
  801a77:	80 39 30             	cmpb   $0x30,(%ecx)
  801a7a:	74 28                	je     801aa4 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a7c:	85 db                	test   %ebx,%ebx
  801a7e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a83:	0f 44 d8             	cmove  %eax,%ebx
  801a86:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801a8e:	eb 46                	jmp    801ad6 <strtol+0x94>
		s++;
  801a90:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801a93:	bf 00 00 00 00       	mov    $0x0,%edi
  801a98:	eb d5                	jmp    801a6f <strtol+0x2d>
		s++, neg = 1;
  801a9a:	83 c1 01             	add    $0x1,%ecx
  801a9d:	bf 01 00 00 00       	mov    $0x1,%edi
  801aa2:	eb cb                	jmp    801a6f <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801aa4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801aa8:	74 0e                	je     801ab8 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801aaa:	85 db                	test   %ebx,%ebx
  801aac:	75 d8                	jne    801a86 <strtol+0x44>
		s++, base = 8;
  801aae:	83 c1 01             	add    $0x1,%ecx
  801ab1:	bb 08 00 00 00       	mov    $0x8,%ebx
  801ab6:	eb ce                	jmp    801a86 <strtol+0x44>
		s += 2, base = 16;
  801ab8:	83 c1 02             	add    $0x2,%ecx
  801abb:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ac0:	eb c4                	jmp    801a86 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801ac2:	0f be d2             	movsbl %dl,%edx
  801ac5:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801ac8:	3b 55 10             	cmp    0x10(%ebp),%edx
  801acb:	7d 3a                	jge    801b07 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801acd:	83 c1 01             	add    $0x1,%ecx
  801ad0:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ad4:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801ad6:	0f b6 11             	movzbl (%ecx),%edx
  801ad9:	8d 72 d0             	lea    -0x30(%edx),%esi
  801adc:	89 f3                	mov    %esi,%ebx
  801ade:	80 fb 09             	cmp    $0x9,%bl
  801ae1:	76 df                	jbe    801ac2 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801ae3:	8d 72 9f             	lea    -0x61(%edx),%esi
  801ae6:	89 f3                	mov    %esi,%ebx
  801ae8:	80 fb 19             	cmp    $0x19,%bl
  801aeb:	77 08                	ja     801af5 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801aed:	0f be d2             	movsbl %dl,%edx
  801af0:	83 ea 57             	sub    $0x57,%edx
  801af3:	eb d3                	jmp    801ac8 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801af5:	8d 72 bf             	lea    -0x41(%edx),%esi
  801af8:	89 f3                	mov    %esi,%ebx
  801afa:	80 fb 19             	cmp    $0x19,%bl
  801afd:	77 08                	ja     801b07 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801aff:	0f be d2             	movsbl %dl,%edx
  801b02:	83 ea 37             	sub    $0x37,%edx
  801b05:	eb c1                	jmp    801ac8 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801b07:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b0b:	74 05                	je     801b12 <strtol+0xd0>
		*endptr = (char *) s;
  801b0d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b10:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801b12:	89 c2                	mov    %eax,%edx
  801b14:	f7 da                	neg    %edx
  801b16:	85 ff                	test   %edi,%edi
  801b18:	0f 45 c2             	cmovne %edx,%eax
}
  801b1b:	5b                   	pop    %ebx
  801b1c:	5e                   	pop    %esi
  801b1d:	5f                   	pop    %edi
  801b1e:	5d                   	pop    %ebp
  801b1f:	c3                   	ret    

00801b20 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b20:	f3 0f 1e fb          	endbr32 
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	56                   	push   %esi
  801b28:	53                   	push   %ebx
  801b29:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2f:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801b32:	85 c0                	test   %eax,%eax
  801b34:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b39:	0f 44 c2             	cmove  %edx,%eax
  801b3c:	83 ec 0c             	sub    $0xc,%esp
  801b3f:	50                   	push   %eax
  801b40:	e8 1b e8 ff ff       	call   800360 <sys_ipc_recv>
  801b45:	83 c4 10             	add    $0x10,%esp
  801b48:	85 c0                	test   %eax,%eax
  801b4a:	78 24                	js     801b70 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801b4c:	85 f6                	test   %esi,%esi
  801b4e:	74 0a                	je     801b5a <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801b50:	a1 04 40 80 00       	mov    0x804004,%eax
  801b55:	8b 40 78             	mov    0x78(%eax),%eax
  801b58:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801b5a:	85 db                	test   %ebx,%ebx
  801b5c:	74 0a                	je     801b68 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801b5e:	a1 04 40 80 00       	mov    0x804004,%eax
  801b63:	8b 40 74             	mov    0x74(%eax),%eax
  801b66:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801b68:	a1 04 40 80 00       	mov    0x804004,%eax
  801b6d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b73:	5b                   	pop    %ebx
  801b74:	5e                   	pop    %esi
  801b75:	5d                   	pop    %ebp
  801b76:	c3                   	ret    

00801b77 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b77:	f3 0f 1e fb          	endbr32 
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	57                   	push   %edi
  801b7f:	56                   	push   %esi
  801b80:	53                   	push   %ebx
  801b81:	83 ec 1c             	sub    $0x1c,%esp
  801b84:	8b 45 10             	mov    0x10(%ebp),%eax
  801b87:	85 c0                	test   %eax,%eax
  801b89:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b8e:	0f 45 d0             	cmovne %eax,%edx
  801b91:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801b93:	be 01 00 00 00       	mov    $0x1,%esi
  801b98:	eb 1f                	jmp    801bb9 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801b9a:	e8 d2 e5 ff ff       	call   800171 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801b9f:	83 c3 01             	add    $0x1,%ebx
  801ba2:	39 de                	cmp    %ebx,%esi
  801ba4:	7f f4                	jg     801b9a <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801ba6:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801ba8:	83 fe 11             	cmp    $0x11,%esi
  801bab:	b8 01 00 00 00       	mov    $0x1,%eax
  801bb0:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801bb3:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801bb7:	75 1c                	jne    801bd5 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801bb9:	ff 75 14             	pushl  0x14(%ebp)
  801bbc:	57                   	push   %edi
  801bbd:	ff 75 0c             	pushl  0xc(%ebp)
  801bc0:	ff 75 08             	pushl  0x8(%ebp)
  801bc3:	e8 71 e7 ff ff       	call   800339 <sys_ipc_try_send>
  801bc8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801bcb:	83 c4 10             	add    $0x10,%esp
  801bce:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bd3:	eb cd                	jmp    801ba2 <ipc_send+0x2b>
}
  801bd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd8:	5b                   	pop    %ebx
  801bd9:	5e                   	pop    %esi
  801bda:	5f                   	pop    %edi
  801bdb:	5d                   	pop    %ebp
  801bdc:	c3                   	ret    

00801bdd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bdd:	f3 0f 1e fb          	endbr32 
  801be1:	55                   	push   %ebp
  801be2:	89 e5                	mov    %esp,%ebp
  801be4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801be7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bec:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bef:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bf5:	8b 52 50             	mov    0x50(%edx),%edx
  801bf8:	39 ca                	cmp    %ecx,%edx
  801bfa:	74 11                	je     801c0d <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801bfc:	83 c0 01             	add    $0x1,%eax
  801bff:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c04:	75 e6                	jne    801bec <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801c06:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0b:	eb 0b                	jmp    801c18 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c0d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c10:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c15:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c18:	5d                   	pop    %ebp
  801c19:	c3                   	ret    

00801c1a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c1a:	f3 0f 1e fb          	endbr32 
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c24:	89 c2                	mov    %eax,%edx
  801c26:	c1 ea 16             	shr    $0x16,%edx
  801c29:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c30:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c35:	f6 c1 01             	test   $0x1,%cl
  801c38:	74 1c                	je     801c56 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c3a:	c1 e8 0c             	shr    $0xc,%eax
  801c3d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c44:	a8 01                	test   $0x1,%al
  801c46:	74 0e                	je     801c56 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c48:	c1 e8 0c             	shr    $0xc,%eax
  801c4b:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c52:	ef 
  801c53:	0f b7 d2             	movzwl %dx,%edx
}
  801c56:	89 d0                	mov    %edx,%eax
  801c58:	5d                   	pop    %ebp
  801c59:	c3                   	ret    
  801c5a:	66 90                	xchg   %ax,%ax
  801c5c:	66 90                	xchg   %ax,%ax
  801c5e:	66 90                	xchg   %ax,%ax

00801c60 <__udivdi3>:
  801c60:	f3 0f 1e fb          	endbr32 
  801c64:	55                   	push   %ebp
  801c65:	57                   	push   %edi
  801c66:	56                   	push   %esi
  801c67:	53                   	push   %ebx
  801c68:	83 ec 1c             	sub    $0x1c,%esp
  801c6b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c6f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c73:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c77:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c7b:	85 d2                	test   %edx,%edx
  801c7d:	75 19                	jne    801c98 <__udivdi3+0x38>
  801c7f:	39 f3                	cmp    %esi,%ebx
  801c81:	76 4d                	jbe    801cd0 <__udivdi3+0x70>
  801c83:	31 ff                	xor    %edi,%edi
  801c85:	89 e8                	mov    %ebp,%eax
  801c87:	89 f2                	mov    %esi,%edx
  801c89:	f7 f3                	div    %ebx
  801c8b:	89 fa                	mov    %edi,%edx
  801c8d:	83 c4 1c             	add    $0x1c,%esp
  801c90:	5b                   	pop    %ebx
  801c91:	5e                   	pop    %esi
  801c92:	5f                   	pop    %edi
  801c93:	5d                   	pop    %ebp
  801c94:	c3                   	ret    
  801c95:	8d 76 00             	lea    0x0(%esi),%esi
  801c98:	39 f2                	cmp    %esi,%edx
  801c9a:	76 14                	jbe    801cb0 <__udivdi3+0x50>
  801c9c:	31 ff                	xor    %edi,%edi
  801c9e:	31 c0                	xor    %eax,%eax
  801ca0:	89 fa                	mov    %edi,%edx
  801ca2:	83 c4 1c             	add    $0x1c,%esp
  801ca5:	5b                   	pop    %ebx
  801ca6:	5e                   	pop    %esi
  801ca7:	5f                   	pop    %edi
  801ca8:	5d                   	pop    %ebp
  801ca9:	c3                   	ret    
  801caa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cb0:	0f bd fa             	bsr    %edx,%edi
  801cb3:	83 f7 1f             	xor    $0x1f,%edi
  801cb6:	75 48                	jne    801d00 <__udivdi3+0xa0>
  801cb8:	39 f2                	cmp    %esi,%edx
  801cba:	72 06                	jb     801cc2 <__udivdi3+0x62>
  801cbc:	31 c0                	xor    %eax,%eax
  801cbe:	39 eb                	cmp    %ebp,%ebx
  801cc0:	77 de                	ja     801ca0 <__udivdi3+0x40>
  801cc2:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc7:	eb d7                	jmp    801ca0 <__udivdi3+0x40>
  801cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	89 d9                	mov    %ebx,%ecx
  801cd2:	85 db                	test   %ebx,%ebx
  801cd4:	75 0b                	jne    801ce1 <__udivdi3+0x81>
  801cd6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cdb:	31 d2                	xor    %edx,%edx
  801cdd:	f7 f3                	div    %ebx
  801cdf:	89 c1                	mov    %eax,%ecx
  801ce1:	31 d2                	xor    %edx,%edx
  801ce3:	89 f0                	mov    %esi,%eax
  801ce5:	f7 f1                	div    %ecx
  801ce7:	89 c6                	mov    %eax,%esi
  801ce9:	89 e8                	mov    %ebp,%eax
  801ceb:	89 f7                	mov    %esi,%edi
  801ced:	f7 f1                	div    %ecx
  801cef:	89 fa                	mov    %edi,%edx
  801cf1:	83 c4 1c             	add    $0x1c,%esp
  801cf4:	5b                   	pop    %ebx
  801cf5:	5e                   	pop    %esi
  801cf6:	5f                   	pop    %edi
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    
  801cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d00:	89 f9                	mov    %edi,%ecx
  801d02:	b8 20 00 00 00       	mov    $0x20,%eax
  801d07:	29 f8                	sub    %edi,%eax
  801d09:	d3 e2                	shl    %cl,%edx
  801d0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d0f:	89 c1                	mov    %eax,%ecx
  801d11:	89 da                	mov    %ebx,%edx
  801d13:	d3 ea                	shr    %cl,%edx
  801d15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d19:	09 d1                	or     %edx,%ecx
  801d1b:	89 f2                	mov    %esi,%edx
  801d1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d21:	89 f9                	mov    %edi,%ecx
  801d23:	d3 e3                	shl    %cl,%ebx
  801d25:	89 c1                	mov    %eax,%ecx
  801d27:	d3 ea                	shr    %cl,%edx
  801d29:	89 f9                	mov    %edi,%ecx
  801d2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d2f:	89 eb                	mov    %ebp,%ebx
  801d31:	d3 e6                	shl    %cl,%esi
  801d33:	89 c1                	mov    %eax,%ecx
  801d35:	d3 eb                	shr    %cl,%ebx
  801d37:	09 de                	or     %ebx,%esi
  801d39:	89 f0                	mov    %esi,%eax
  801d3b:	f7 74 24 08          	divl   0x8(%esp)
  801d3f:	89 d6                	mov    %edx,%esi
  801d41:	89 c3                	mov    %eax,%ebx
  801d43:	f7 64 24 0c          	mull   0xc(%esp)
  801d47:	39 d6                	cmp    %edx,%esi
  801d49:	72 15                	jb     801d60 <__udivdi3+0x100>
  801d4b:	89 f9                	mov    %edi,%ecx
  801d4d:	d3 e5                	shl    %cl,%ebp
  801d4f:	39 c5                	cmp    %eax,%ebp
  801d51:	73 04                	jae    801d57 <__udivdi3+0xf7>
  801d53:	39 d6                	cmp    %edx,%esi
  801d55:	74 09                	je     801d60 <__udivdi3+0x100>
  801d57:	89 d8                	mov    %ebx,%eax
  801d59:	31 ff                	xor    %edi,%edi
  801d5b:	e9 40 ff ff ff       	jmp    801ca0 <__udivdi3+0x40>
  801d60:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d63:	31 ff                	xor    %edi,%edi
  801d65:	e9 36 ff ff ff       	jmp    801ca0 <__udivdi3+0x40>
  801d6a:	66 90                	xchg   %ax,%ax
  801d6c:	66 90                	xchg   %ax,%ax
  801d6e:	66 90                	xchg   %ax,%ax

00801d70 <__umoddi3>:
  801d70:	f3 0f 1e fb          	endbr32 
  801d74:	55                   	push   %ebp
  801d75:	57                   	push   %edi
  801d76:	56                   	push   %esi
  801d77:	53                   	push   %ebx
  801d78:	83 ec 1c             	sub    $0x1c,%esp
  801d7b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d7f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801d83:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d87:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d8b:	85 c0                	test   %eax,%eax
  801d8d:	75 19                	jne    801da8 <__umoddi3+0x38>
  801d8f:	39 df                	cmp    %ebx,%edi
  801d91:	76 5d                	jbe    801df0 <__umoddi3+0x80>
  801d93:	89 f0                	mov    %esi,%eax
  801d95:	89 da                	mov    %ebx,%edx
  801d97:	f7 f7                	div    %edi
  801d99:	89 d0                	mov    %edx,%eax
  801d9b:	31 d2                	xor    %edx,%edx
  801d9d:	83 c4 1c             	add    $0x1c,%esp
  801da0:	5b                   	pop    %ebx
  801da1:	5e                   	pop    %esi
  801da2:	5f                   	pop    %edi
  801da3:	5d                   	pop    %ebp
  801da4:	c3                   	ret    
  801da5:	8d 76 00             	lea    0x0(%esi),%esi
  801da8:	89 f2                	mov    %esi,%edx
  801daa:	39 d8                	cmp    %ebx,%eax
  801dac:	76 12                	jbe    801dc0 <__umoddi3+0x50>
  801dae:	89 f0                	mov    %esi,%eax
  801db0:	89 da                	mov    %ebx,%edx
  801db2:	83 c4 1c             	add    $0x1c,%esp
  801db5:	5b                   	pop    %ebx
  801db6:	5e                   	pop    %esi
  801db7:	5f                   	pop    %edi
  801db8:	5d                   	pop    %ebp
  801db9:	c3                   	ret    
  801dba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801dc0:	0f bd e8             	bsr    %eax,%ebp
  801dc3:	83 f5 1f             	xor    $0x1f,%ebp
  801dc6:	75 50                	jne    801e18 <__umoddi3+0xa8>
  801dc8:	39 d8                	cmp    %ebx,%eax
  801dca:	0f 82 e0 00 00 00    	jb     801eb0 <__umoddi3+0x140>
  801dd0:	89 d9                	mov    %ebx,%ecx
  801dd2:	39 f7                	cmp    %esi,%edi
  801dd4:	0f 86 d6 00 00 00    	jbe    801eb0 <__umoddi3+0x140>
  801dda:	89 d0                	mov    %edx,%eax
  801ddc:	89 ca                	mov    %ecx,%edx
  801dde:	83 c4 1c             	add    $0x1c,%esp
  801de1:	5b                   	pop    %ebx
  801de2:	5e                   	pop    %esi
  801de3:	5f                   	pop    %edi
  801de4:	5d                   	pop    %ebp
  801de5:	c3                   	ret    
  801de6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ded:	8d 76 00             	lea    0x0(%esi),%esi
  801df0:	89 fd                	mov    %edi,%ebp
  801df2:	85 ff                	test   %edi,%edi
  801df4:	75 0b                	jne    801e01 <__umoddi3+0x91>
  801df6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfb:	31 d2                	xor    %edx,%edx
  801dfd:	f7 f7                	div    %edi
  801dff:	89 c5                	mov    %eax,%ebp
  801e01:	89 d8                	mov    %ebx,%eax
  801e03:	31 d2                	xor    %edx,%edx
  801e05:	f7 f5                	div    %ebp
  801e07:	89 f0                	mov    %esi,%eax
  801e09:	f7 f5                	div    %ebp
  801e0b:	89 d0                	mov    %edx,%eax
  801e0d:	31 d2                	xor    %edx,%edx
  801e0f:	eb 8c                	jmp    801d9d <__umoddi3+0x2d>
  801e11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e18:	89 e9                	mov    %ebp,%ecx
  801e1a:	ba 20 00 00 00       	mov    $0x20,%edx
  801e1f:	29 ea                	sub    %ebp,%edx
  801e21:	d3 e0                	shl    %cl,%eax
  801e23:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e27:	89 d1                	mov    %edx,%ecx
  801e29:	89 f8                	mov    %edi,%eax
  801e2b:	d3 e8                	shr    %cl,%eax
  801e2d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e31:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e35:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e39:	09 c1                	or     %eax,%ecx
  801e3b:	89 d8                	mov    %ebx,%eax
  801e3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e41:	89 e9                	mov    %ebp,%ecx
  801e43:	d3 e7                	shl    %cl,%edi
  801e45:	89 d1                	mov    %edx,%ecx
  801e47:	d3 e8                	shr    %cl,%eax
  801e49:	89 e9                	mov    %ebp,%ecx
  801e4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e4f:	d3 e3                	shl    %cl,%ebx
  801e51:	89 c7                	mov    %eax,%edi
  801e53:	89 d1                	mov    %edx,%ecx
  801e55:	89 f0                	mov    %esi,%eax
  801e57:	d3 e8                	shr    %cl,%eax
  801e59:	89 e9                	mov    %ebp,%ecx
  801e5b:	89 fa                	mov    %edi,%edx
  801e5d:	d3 e6                	shl    %cl,%esi
  801e5f:	09 d8                	or     %ebx,%eax
  801e61:	f7 74 24 08          	divl   0x8(%esp)
  801e65:	89 d1                	mov    %edx,%ecx
  801e67:	89 f3                	mov    %esi,%ebx
  801e69:	f7 64 24 0c          	mull   0xc(%esp)
  801e6d:	89 c6                	mov    %eax,%esi
  801e6f:	89 d7                	mov    %edx,%edi
  801e71:	39 d1                	cmp    %edx,%ecx
  801e73:	72 06                	jb     801e7b <__umoddi3+0x10b>
  801e75:	75 10                	jne    801e87 <__umoddi3+0x117>
  801e77:	39 c3                	cmp    %eax,%ebx
  801e79:	73 0c                	jae    801e87 <__umoddi3+0x117>
  801e7b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801e7f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801e83:	89 d7                	mov    %edx,%edi
  801e85:	89 c6                	mov    %eax,%esi
  801e87:	89 ca                	mov    %ecx,%edx
  801e89:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801e8e:	29 f3                	sub    %esi,%ebx
  801e90:	19 fa                	sbb    %edi,%edx
  801e92:	89 d0                	mov    %edx,%eax
  801e94:	d3 e0                	shl    %cl,%eax
  801e96:	89 e9                	mov    %ebp,%ecx
  801e98:	d3 eb                	shr    %cl,%ebx
  801e9a:	d3 ea                	shr    %cl,%edx
  801e9c:	09 d8                	or     %ebx,%eax
  801e9e:	83 c4 1c             	add    $0x1c,%esp
  801ea1:	5b                   	pop    %ebx
  801ea2:	5e                   	pop    %esi
  801ea3:	5f                   	pop    %edi
  801ea4:	5d                   	pop    %ebp
  801ea5:	c3                   	ret    
  801ea6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ead:	8d 76 00             	lea    0x0(%esi),%esi
  801eb0:	29 fe                	sub    %edi,%esi
  801eb2:	19 c3                	sbb    %eax,%ebx
  801eb4:	89 f2                	mov    %esi,%edx
  801eb6:	89 d9                	mov    %ebx,%ecx
  801eb8:	e9 1d ff ff ff       	jmp    801dda <__umoddi3+0x6a>
