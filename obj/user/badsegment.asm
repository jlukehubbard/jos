
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	f3 0f 1e fb          	endbr32 
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004d:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800054:	00 00 00 
    envid_t envid = sys_getenvid();
  800057:	e8 de 00 00 00       	call   80013a <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  80005c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800061:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800064:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800069:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006e:	85 db                	test   %ebx,%ebx
  800070:	7e 07                	jle    800079 <libmain+0x3b>
		binaryname = argv[0];
  800072:	8b 06                	mov    (%esi),%eax
  800074:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	56                   	push   %esi
  80007d:	53                   	push   %ebx
  80007e:	e8 b0 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800083:	e8 0a 00 00 00       	call   800092 <exit>
}
  800088:	83 c4 10             	add    $0x10,%esp
  80008b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008e:	5b                   	pop    %ebx
  80008f:	5e                   	pop    %esi
  800090:	5d                   	pop    %ebp
  800091:	c3                   	ret    

00800092 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800092:	f3 0f 1e fb          	endbr32 
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009c:	e8 df 04 00 00       	call   800580 <close_all>
	sys_env_destroy(0);
  8000a1:	83 ec 0c             	sub    $0xc,%esp
  8000a4:	6a 00                	push   $0x0
  8000a6:	e8 4a 00 00 00       	call   8000f5 <sys_env_destroy>
}
  8000ab:	83 c4 10             	add    $0x10,%esp
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b0:	f3 0f 1e fb          	endbr32 
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	f3 0f 1e fb          	endbr32 
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e6:	89 d1                	mov    %edx,%ecx
  8000e8:	89 d3                	mov    %edx,%ebx
  8000ea:	89 d7                	mov    %edx,%edi
  8000ec:	89 d6                	mov    %edx,%esi
  8000ee:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    

008000f5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f5:	f3 0f 1e fb          	endbr32 
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	57                   	push   %edi
  8000fd:	56                   	push   %esi
  8000fe:	53                   	push   %ebx
  8000ff:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800102:	b9 00 00 00 00       	mov    $0x0,%ecx
  800107:	8b 55 08             	mov    0x8(%ebp),%edx
  80010a:	b8 03 00 00 00       	mov    $0x3,%eax
  80010f:	89 cb                	mov    %ecx,%ebx
  800111:	89 cf                	mov    %ecx,%edi
  800113:	89 ce                	mov    %ecx,%esi
  800115:	cd 30                	int    $0x30
	if(check && ret > 0)
  800117:	85 c0                	test   %eax,%eax
  800119:	7f 08                	jg     800123 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5f                   	pop    %edi
  800121:	5d                   	pop    %ebp
  800122:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800123:	83 ec 0c             	sub    $0xc,%esp
  800126:	50                   	push   %eax
  800127:	6a 03                	push   $0x3
  800129:	68 ea 1e 80 00       	push   $0x801eea
  80012e:	6a 23                	push   $0x23
  800130:	68 07 1f 80 00       	push   $0x801f07
  800135:	e8 9c 0f 00 00       	call   8010d6 <_panic>

0080013a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013a:	f3 0f 1e fb          	endbr32 
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	57                   	push   %edi
  800142:	56                   	push   %esi
  800143:	53                   	push   %ebx
	asm volatile("int %1\n"
  800144:	ba 00 00 00 00       	mov    $0x0,%edx
  800149:	b8 02 00 00 00       	mov    $0x2,%eax
  80014e:	89 d1                	mov    %edx,%ecx
  800150:	89 d3                	mov    %edx,%ebx
  800152:	89 d7                	mov    %edx,%edi
  800154:	89 d6                	mov    %edx,%esi
  800156:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800158:	5b                   	pop    %ebx
  800159:	5e                   	pop    %esi
  80015a:	5f                   	pop    %edi
  80015b:	5d                   	pop    %ebp
  80015c:	c3                   	ret    

0080015d <sys_yield>:

void
sys_yield(void)
{
  80015d:	f3 0f 1e fb          	endbr32 
  800161:	55                   	push   %ebp
  800162:	89 e5                	mov    %esp,%ebp
  800164:	57                   	push   %edi
  800165:	56                   	push   %esi
  800166:	53                   	push   %ebx
	asm volatile("int %1\n"
  800167:	ba 00 00 00 00       	mov    $0x0,%edx
  80016c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800171:	89 d1                	mov    %edx,%ecx
  800173:	89 d3                	mov    %edx,%ebx
  800175:	89 d7                	mov    %edx,%edi
  800177:	89 d6                	mov    %edx,%esi
  800179:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017b:	5b                   	pop    %ebx
  80017c:	5e                   	pop    %esi
  80017d:	5f                   	pop    %edi
  80017e:	5d                   	pop    %ebp
  80017f:	c3                   	ret    

00800180 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800180:	f3 0f 1e fb          	endbr32 
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	57                   	push   %edi
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80018d:	be 00 00 00 00       	mov    $0x0,%esi
  800192:	8b 55 08             	mov    0x8(%ebp),%edx
  800195:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800198:	b8 04 00 00 00       	mov    $0x4,%eax
  80019d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a0:	89 f7                	mov    %esi,%edi
  8001a2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001a4:	85 c0                	test   %eax,%eax
  8001a6:	7f 08                	jg     8001b0 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b0:	83 ec 0c             	sub    $0xc,%esp
  8001b3:	50                   	push   %eax
  8001b4:	6a 04                	push   $0x4
  8001b6:	68 ea 1e 80 00       	push   $0x801eea
  8001bb:	6a 23                	push   $0x23
  8001bd:	68 07 1f 80 00       	push   $0x801f07
  8001c2:	e8 0f 0f 00 00       	call   8010d6 <_panic>

008001c7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c7:	f3 0f 1e fb          	endbr32 
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	57                   	push   %edi
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001da:	b8 05 00 00 00       	mov    $0x5,%eax
  8001df:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ea:	85 c0                	test   %eax,%eax
  8001ec:	7f 08                	jg     8001f6 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f1:	5b                   	pop    %ebx
  8001f2:	5e                   	pop    %esi
  8001f3:	5f                   	pop    %edi
  8001f4:	5d                   	pop    %ebp
  8001f5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f6:	83 ec 0c             	sub    $0xc,%esp
  8001f9:	50                   	push   %eax
  8001fa:	6a 05                	push   $0x5
  8001fc:	68 ea 1e 80 00       	push   $0x801eea
  800201:	6a 23                	push   $0x23
  800203:	68 07 1f 80 00       	push   $0x801f07
  800208:	e8 c9 0e 00 00       	call   8010d6 <_panic>

0080020d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020d:	f3 0f 1e fb          	endbr32 
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	57                   	push   %edi
  800215:	56                   	push   %esi
  800216:	53                   	push   %ebx
  800217:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80021a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021f:	8b 55 08             	mov    0x8(%ebp),%edx
  800222:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800225:	b8 06 00 00 00       	mov    $0x6,%eax
  80022a:	89 df                	mov    %ebx,%edi
  80022c:	89 de                	mov    %ebx,%esi
  80022e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800230:	85 c0                	test   %eax,%eax
  800232:	7f 08                	jg     80023c <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800234:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800237:	5b                   	pop    %ebx
  800238:	5e                   	pop    %esi
  800239:	5f                   	pop    %edi
  80023a:	5d                   	pop    %ebp
  80023b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80023c:	83 ec 0c             	sub    $0xc,%esp
  80023f:	50                   	push   %eax
  800240:	6a 06                	push   $0x6
  800242:	68 ea 1e 80 00       	push   $0x801eea
  800247:	6a 23                	push   $0x23
  800249:	68 07 1f 80 00       	push   $0x801f07
  80024e:	e8 83 0e 00 00       	call   8010d6 <_panic>

00800253 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800253:	f3 0f 1e fb          	endbr32 
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	57                   	push   %edi
  80025b:	56                   	push   %esi
  80025c:	53                   	push   %ebx
  80025d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800260:	bb 00 00 00 00       	mov    $0x0,%ebx
  800265:	8b 55 08             	mov    0x8(%ebp),%edx
  800268:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026b:	b8 08 00 00 00       	mov    $0x8,%eax
  800270:	89 df                	mov    %ebx,%edi
  800272:	89 de                	mov    %ebx,%esi
  800274:	cd 30                	int    $0x30
	if(check && ret > 0)
  800276:	85 c0                	test   %eax,%eax
  800278:	7f 08                	jg     800282 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80027a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5e                   	pop    %esi
  80027f:	5f                   	pop    %edi
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	50                   	push   %eax
  800286:	6a 08                	push   $0x8
  800288:	68 ea 1e 80 00       	push   $0x801eea
  80028d:	6a 23                	push   $0x23
  80028f:	68 07 1f 80 00       	push   $0x801f07
  800294:	e8 3d 0e 00 00       	call   8010d6 <_panic>

00800299 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800299:	f3 0f 1e fb          	endbr32 
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	57                   	push   %edi
  8002a1:	56                   	push   %esi
  8002a2:	53                   	push   %ebx
  8002a3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b1:	b8 09 00 00 00       	mov    $0x9,%eax
  8002b6:	89 df                	mov    %ebx,%edi
  8002b8:	89 de                	mov    %ebx,%esi
  8002ba:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002bc:	85 c0                	test   %eax,%eax
  8002be:	7f 08                	jg     8002c8 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c3:	5b                   	pop    %ebx
  8002c4:	5e                   	pop    %esi
  8002c5:	5f                   	pop    %edi
  8002c6:	5d                   	pop    %ebp
  8002c7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c8:	83 ec 0c             	sub    $0xc,%esp
  8002cb:	50                   	push   %eax
  8002cc:	6a 09                	push   $0x9
  8002ce:	68 ea 1e 80 00       	push   $0x801eea
  8002d3:	6a 23                	push   $0x23
  8002d5:	68 07 1f 80 00       	push   $0x801f07
  8002da:	e8 f7 0d 00 00       	call   8010d6 <_panic>

008002df <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002df:	f3 0f 1e fb          	endbr32 
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
  8002e9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002fc:	89 df                	mov    %ebx,%edi
  8002fe:	89 de                	mov    %ebx,%esi
  800300:	cd 30                	int    $0x30
	if(check && ret > 0)
  800302:	85 c0                	test   %eax,%eax
  800304:	7f 08                	jg     80030e <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800306:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80030e:	83 ec 0c             	sub    $0xc,%esp
  800311:	50                   	push   %eax
  800312:	6a 0a                	push   $0xa
  800314:	68 ea 1e 80 00       	push   $0x801eea
  800319:	6a 23                	push   $0x23
  80031b:	68 07 1f 80 00       	push   $0x801f07
  800320:	e8 b1 0d 00 00       	call   8010d6 <_panic>

00800325 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800325:	f3 0f 1e fb          	endbr32 
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	57                   	push   %edi
  80032d:	56                   	push   %esi
  80032e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80032f:	8b 55 08             	mov    0x8(%ebp),%edx
  800332:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800335:	b8 0c 00 00 00       	mov    $0xc,%eax
  80033a:	be 00 00 00 00       	mov    $0x0,%esi
  80033f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800342:	8b 7d 14             	mov    0x14(%ebp),%edi
  800345:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800347:	5b                   	pop    %ebx
  800348:	5e                   	pop    %esi
  800349:	5f                   	pop    %edi
  80034a:	5d                   	pop    %ebp
  80034b:	c3                   	ret    

0080034c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80034c:	f3 0f 1e fb          	endbr32 
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	57                   	push   %edi
  800354:	56                   	push   %esi
  800355:	53                   	push   %ebx
  800356:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800359:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035e:	8b 55 08             	mov    0x8(%ebp),%edx
  800361:	b8 0d 00 00 00       	mov    $0xd,%eax
  800366:	89 cb                	mov    %ecx,%ebx
  800368:	89 cf                	mov    %ecx,%edi
  80036a:	89 ce                	mov    %ecx,%esi
  80036c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80036e:	85 c0                	test   %eax,%eax
  800370:	7f 08                	jg     80037a <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80037a:	83 ec 0c             	sub    $0xc,%esp
  80037d:	50                   	push   %eax
  80037e:	6a 0d                	push   $0xd
  800380:	68 ea 1e 80 00       	push   $0x801eea
  800385:	6a 23                	push   $0x23
  800387:	68 07 1f 80 00       	push   $0x801f07
  80038c:	e8 45 0d 00 00       	call   8010d6 <_panic>

00800391 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800391:	f3 0f 1e fb          	endbr32 
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800398:	8b 45 08             	mov    0x8(%ebp),%eax
  80039b:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a0:	c1 e8 0c             	shr    $0xc,%eax
}
  8003a3:	5d                   	pop    %ebp
  8003a4:	c3                   	ret    

008003a5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003a5:	f3 0f 1e fb          	endbr32 
  8003a9:	55                   	push   %ebp
  8003aa:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8003af:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003b4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003b9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003be:	5d                   	pop    %ebp
  8003bf:	c3                   	ret    

008003c0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003c0:	f3 0f 1e fb          	endbr32 
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
  8003c7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003cc:	89 c2                	mov    %eax,%edx
  8003ce:	c1 ea 16             	shr    $0x16,%edx
  8003d1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003d8:	f6 c2 01             	test   $0x1,%dl
  8003db:	74 2d                	je     80040a <fd_alloc+0x4a>
  8003dd:	89 c2                	mov    %eax,%edx
  8003df:	c1 ea 0c             	shr    $0xc,%edx
  8003e2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003e9:	f6 c2 01             	test   $0x1,%dl
  8003ec:	74 1c                	je     80040a <fd_alloc+0x4a>
  8003ee:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003f3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003f8:	75 d2                	jne    8003cc <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800403:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800408:	eb 0a                	jmp    800414 <fd_alloc+0x54>
			*fd_store = fd;
  80040a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80040d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80040f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800414:	5d                   	pop    %ebp
  800415:	c3                   	ret    

00800416 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800416:	f3 0f 1e fb          	endbr32 
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800420:	83 f8 1f             	cmp    $0x1f,%eax
  800423:	77 30                	ja     800455 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800425:	c1 e0 0c             	shl    $0xc,%eax
  800428:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80042d:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800433:	f6 c2 01             	test   $0x1,%dl
  800436:	74 24                	je     80045c <fd_lookup+0x46>
  800438:	89 c2                	mov    %eax,%edx
  80043a:	c1 ea 0c             	shr    $0xc,%edx
  80043d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800444:	f6 c2 01             	test   $0x1,%dl
  800447:	74 1a                	je     800463 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800449:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044c:	89 02                	mov    %eax,(%edx)
	return 0;
  80044e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800453:	5d                   	pop    %ebp
  800454:	c3                   	ret    
		return -E_INVAL;
  800455:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80045a:	eb f7                	jmp    800453 <fd_lookup+0x3d>
		return -E_INVAL;
  80045c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800461:	eb f0                	jmp    800453 <fd_lookup+0x3d>
  800463:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800468:	eb e9                	jmp    800453 <fd_lookup+0x3d>

0080046a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80046a:	f3 0f 1e fb          	endbr32 
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800477:	ba 94 1f 80 00       	mov    $0x801f94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80047c:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800481:	39 08                	cmp    %ecx,(%eax)
  800483:	74 33                	je     8004b8 <dev_lookup+0x4e>
  800485:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800488:	8b 02                	mov    (%edx),%eax
  80048a:	85 c0                	test   %eax,%eax
  80048c:	75 f3                	jne    800481 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80048e:	a1 04 40 80 00       	mov    0x804004,%eax
  800493:	8b 40 48             	mov    0x48(%eax),%eax
  800496:	83 ec 04             	sub    $0x4,%esp
  800499:	51                   	push   %ecx
  80049a:	50                   	push   %eax
  80049b:	68 18 1f 80 00       	push   $0x801f18
  8004a0:	e8 18 0d 00 00       	call   8011bd <cprintf>
	*dev = 0;
  8004a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004b6:	c9                   	leave  
  8004b7:	c3                   	ret    
			*dev = devtab[i];
  8004b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004bb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c2:	eb f2                	jmp    8004b6 <dev_lookup+0x4c>

008004c4 <fd_close>:
{
  8004c4:	f3 0f 1e fb          	endbr32 
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	57                   	push   %edi
  8004cc:	56                   	push   %esi
  8004cd:	53                   	push   %ebx
  8004ce:	83 ec 24             	sub    $0x24,%esp
  8004d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004d7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004da:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004db:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004e1:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004e4:	50                   	push   %eax
  8004e5:	e8 2c ff ff ff       	call   800416 <fd_lookup>
  8004ea:	89 c3                	mov    %eax,%ebx
  8004ec:	83 c4 10             	add    $0x10,%esp
  8004ef:	85 c0                	test   %eax,%eax
  8004f1:	78 05                	js     8004f8 <fd_close+0x34>
	    || fd != fd2)
  8004f3:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004f6:	74 16                	je     80050e <fd_close+0x4a>
		return (must_exist ? r : 0);
  8004f8:	89 f8                	mov    %edi,%eax
  8004fa:	84 c0                	test   %al,%al
  8004fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800501:	0f 44 d8             	cmove  %eax,%ebx
}
  800504:	89 d8                	mov    %ebx,%eax
  800506:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800509:	5b                   	pop    %ebx
  80050a:	5e                   	pop    %esi
  80050b:	5f                   	pop    %edi
  80050c:	5d                   	pop    %ebp
  80050d:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800514:	50                   	push   %eax
  800515:	ff 36                	pushl  (%esi)
  800517:	e8 4e ff ff ff       	call   80046a <dev_lookup>
  80051c:	89 c3                	mov    %eax,%ebx
  80051e:	83 c4 10             	add    $0x10,%esp
  800521:	85 c0                	test   %eax,%eax
  800523:	78 1a                	js     80053f <fd_close+0x7b>
		if (dev->dev_close)
  800525:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800528:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80052b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800530:	85 c0                	test   %eax,%eax
  800532:	74 0b                	je     80053f <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800534:	83 ec 0c             	sub    $0xc,%esp
  800537:	56                   	push   %esi
  800538:	ff d0                	call   *%eax
  80053a:	89 c3                	mov    %eax,%ebx
  80053c:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	56                   	push   %esi
  800543:	6a 00                	push   $0x0
  800545:	e8 c3 fc ff ff       	call   80020d <sys_page_unmap>
	return r;
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	eb b5                	jmp    800504 <fd_close+0x40>

0080054f <close>:

int
close(int fdnum)
{
  80054f:	f3 0f 1e fb          	endbr32 
  800553:	55                   	push   %ebp
  800554:	89 e5                	mov    %esp,%ebp
  800556:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800559:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80055c:	50                   	push   %eax
  80055d:	ff 75 08             	pushl  0x8(%ebp)
  800560:	e8 b1 fe ff ff       	call   800416 <fd_lookup>
  800565:	83 c4 10             	add    $0x10,%esp
  800568:	85 c0                	test   %eax,%eax
  80056a:	79 02                	jns    80056e <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  80056c:	c9                   	leave  
  80056d:	c3                   	ret    
		return fd_close(fd, 1);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	6a 01                	push   $0x1
  800573:	ff 75 f4             	pushl  -0xc(%ebp)
  800576:	e8 49 ff ff ff       	call   8004c4 <fd_close>
  80057b:	83 c4 10             	add    $0x10,%esp
  80057e:	eb ec                	jmp    80056c <close+0x1d>

00800580 <close_all>:

void
close_all(void)
{
  800580:	f3 0f 1e fb          	endbr32 
  800584:	55                   	push   %ebp
  800585:	89 e5                	mov    %esp,%ebp
  800587:	53                   	push   %ebx
  800588:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80058b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800590:	83 ec 0c             	sub    $0xc,%esp
  800593:	53                   	push   %ebx
  800594:	e8 b6 ff ff ff       	call   80054f <close>
	for (i = 0; i < MAXFD; i++)
  800599:	83 c3 01             	add    $0x1,%ebx
  80059c:	83 c4 10             	add    $0x10,%esp
  80059f:	83 fb 20             	cmp    $0x20,%ebx
  8005a2:	75 ec                	jne    800590 <close_all+0x10>
}
  8005a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005a7:	c9                   	leave  
  8005a8:	c3                   	ret    

008005a9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005a9:	f3 0f 1e fb          	endbr32 
  8005ad:	55                   	push   %ebp
  8005ae:	89 e5                	mov    %esp,%ebp
  8005b0:	57                   	push   %edi
  8005b1:	56                   	push   %esi
  8005b2:	53                   	push   %ebx
  8005b3:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005b9:	50                   	push   %eax
  8005ba:	ff 75 08             	pushl  0x8(%ebp)
  8005bd:	e8 54 fe ff ff       	call   800416 <fd_lookup>
  8005c2:	89 c3                	mov    %eax,%ebx
  8005c4:	83 c4 10             	add    $0x10,%esp
  8005c7:	85 c0                	test   %eax,%eax
  8005c9:	0f 88 81 00 00 00    	js     800650 <dup+0xa7>
		return r;
	close(newfdnum);
  8005cf:	83 ec 0c             	sub    $0xc,%esp
  8005d2:	ff 75 0c             	pushl  0xc(%ebp)
  8005d5:	e8 75 ff ff ff       	call   80054f <close>

	newfd = INDEX2FD(newfdnum);
  8005da:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005dd:	c1 e6 0c             	shl    $0xc,%esi
  8005e0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005e6:	83 c4 04             	add    $0x4,%esp
  8005e9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005ec:	e8 b4 fd ff ff       	call   8003a5 <fd2data>
  8005f1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005f3:	89 34 24             	mov    %esi,(%esp)
  8005f6:	e8 aa fd ff ff       	call   8003a5 <fd2data>
  8005fb:	83 c4 10             	add    $0x10,%esp
  8005fe:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800600:	89 d8                	mov    %ebx,%eax
  800602:	c1 e8 16             	shr    $0x16,%eax
  800605:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80060c:	a8 01                	test   $0x1,%al
  80060e:	74 11                	je     800621 <dup+0x78>
  800610:	89 d8                	mov    %ebx,%eax
  800612:	c1 e8 0c             	shr    $0xc,%eax
  800615:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80061c:	f6 c2 01             	test   $0x1,%dl
  80061f:	75 39                	jne    80065a <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800621:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800624:	89 d0                	mov    %edx,%eax
  800626:	c1 e8 0c             	shr    $0xc,%eax
  800629:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800630:	83 ec 0c             	sub    $0xc,%esp
  800633:	25 07 0e 00 00       	and    $0xe07,%eax
  800638:	50                   	push   %eax
  800639:	56                   	push   %esi
  80063a:	6a 00                	push   $0x0
  80063c:	52                   	push   %edx
  80063d:	6a 00                	push   $0x0
  80063f:	e8 83 fb ff ff       	call   8001c7 <sys_page_map>
  800644:	89 c3                	mov    %eax,%ebx
  800646:	83 c4 20             	add    $0x20,%esp
  800649:	85 c0                	test   %eax,%eax
  80064b:	78 31                	js     80067e <dup+0xd5>
		goto err;

	return newfdnum;
  80064d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800650:	89 d8                	mov    %ebx,%eax
  800652:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800655:	5b                   	pop    %ebx
  800656:	5e                   	pop    %esi
  800657:	5f                   	pop    %edi
  800658:	5d                   	pop    %ebp
  800659:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80065a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800661:	83 ec 0c             	sub    $0xc,%esp
  800664:	25 07 0e 00 00       	and    $0xe07,%eax
  800669:	50                   	push   %eax
  80066a:	57                   	push   %edi
  80066b:	6a 00                	push   $0x0
  80066d:	53                   	push   %ebx
  80066e:	6a 00                	push   $0x0
  800670:	e8 52 fb ff ff       	call   8001c7 <sys_page_map>
  800675:	89 c3                	mov    %eax,%ebx
  800677:	83 c4 20             	add    $0x20,%esp
  80067a:	85 c0                	test   %eax,%eax
  80067c:	79 a3                	jns    800621 <dup+0x78>
	sys_page_unmap(0, newfd);
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	56                   	push   %esi
  800682:	6a 00                	push   $0x0
  800684:	e8 84 fb ff ff       	call   80020d <sys_page_unmap>
	sys_page_unmap(0, nva);
  800689:	83 c4 08             	add    $0x8,%esp
  80068c:	57                   	push   %edi
  80068d:	6a 00                	push   $0x0
  80068f:	e8 79 fb ff ff       	call   80020d <sys_page_unmap>
	return r;
  800694:	83 c4 10             	add    $0x10,%esp
  800697:	eb b7                	jmp    800650 <dup+0xa7>

00800699 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800699:	f3 0f 1e fb          	endbr32 
  80069d:	55                   	push   %ebp
  80069e:	89 e5                	mov    %esp,%ebp
  8006a0:	53                   	push   %ebx
  8006a1:	83 ec 1c             	sub    $0x1c,%esp
  8006a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006aa:	50                   	push   %eax
  8006ab:	53                   	push   %ebx
  8006ac:	e8 65 fd ff ff       	call   800416 <fd_lookup>
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	85 c0                	test   %eax,%eax
  8006b6:	78 3f                	js     8006f7 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b8:	83 ec 08             	sub    $0x8,%esp
  8006bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006be:	50                   	push   %eax
  8006bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006c2:	ff 30                	pushl  (%eax)
  8006c4:	e8 a1 fd ff ff       	call   80046a <dev_lookup>
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	85 c0                	test   %eax,%eax
  8006ce:	78 27                	js     8006f7 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006d3:	8b 42 08             	mov    0x8(%edx),%eax
  8006d6:	83 e0 03             	and    $0x3,%eax
  8006d9:	83 f8 01             	cmp    $0x1,%eax
  8006dc:	74 1e                	je     8006fc <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e1:	8b 40 08             	mov    0x8(%eax),%eax
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	74 35                	je     80071d <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006e8:	83 ec 04             	sub    $0x4,%esp
  8006eb:	ff 75 10             	pushl  0x10(%ebp)
  8006ee:	ff 75 0c             	pushl  0xc(%ebp)
  8006f1:	52                   	push   %edx
  8006f2:	ff d0                	call   *%eax
  8006f4:	83 c4 10             	add    $0x10,%esp
}
  8006f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006fa:	c9                   	leave  
  8006fb:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006fc:	a1 04 40 80 00       	mov    0x804004,%eax
  800701:	8b 40 48             	mov    0x48(%eax),%eax
  800704:	83 ec 04             	sub    $0x4,%esp
  800707:	53                   	push   %ebx
  800708:	50                   	push   %eax
  800709:	68 59 1f 80 00       	push   $0x801f59
  80070e:	e8 aa 0a 00 00       	call   8011bd <cprintf>
		return -E_INVAL;
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80071b:	eb da                	jmp    8006f7 <read+0x5e>
		return -E_NOT_SUPP;
  80071d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800722:	eb d3                	jmp    8006f7 <read+0x5e>

00800724 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800724:	f3 0f 1e fb          	endbr32 
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	57                   	push   %edi
  80072c:	56                   	push   %esi
  80072d:	53                   	push   %ebx
  80072e:	83 ec 0c             	sub    $0xc,%esp
  800731:	8b 7d 08             	mov    0x8(%ebp),%edi
  800734:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800737:	bb 00 00 00 00       	mov    $0x0,%ebx
  80073c:	eb 02                	jmp    800740 <readn+0x1c>
  80073e:	01 c3                	add    %eax,%ebx
  800740:	39 f3                	cmp    %esi,%ebx
  800742:	73 21                	jae    800765 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800744:	83 ec 04             	sub    $0x4,%esp
  800747:	89 f0                	mov    %esi,%eax
  800749:	29 d8                	sub    %ebx,%eax
  80074b:	50                   	push   %eax
  80074c:	89 d8                	mov    %ebx,%eax
  80074e:	03 45 0c             	add    0xc(%ebp),%eax
  800751:	50                   	push   %eax
  800752:	57                   	push   %edi
  800753:	e8 41 ff ff ff       	call   800699 <read>
		if (m < 0)
  800758:	83 c4 10             	add    $0x10,%esp
  80075b:	85 c0                	test   %eax,%eax
  80075d:	78 04                	js     800763 <readn+0x3f>
			return m;
		if (m == 0)
  80075f:	75 dd                	jne    80073e <readn+0x1a>
  800761:	eb 02                	jmp    800765 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800763:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800765:	89 d8                	mov    %ebx,%eax
  800767:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076a:	5b                   	pop    %ebx
  80076b:	5e                   	pop    %esi
  80076c:	5f                   	pop    %edi
  80076d:	5d                   	pop    %ebp
  80076e:	c3                   	ret    

0080076f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80076f:	f3 0f 1e fb          	endbr32 
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	53                   	push   %ebx
  800777:	83 ec 1c             	sub    $0x1c,%esp
  80077a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80077d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800780:	50                   	push   %eax
  800781:	53                   	push   %ebx
  800782:	e8 8f fc ff ff       	call   800416 <fd_lookup>
  800787:	83 c4 10             	add    $0x10,%esp
  80078a:	85 c0                	test   %eax,%eax
  80078c:	78 3a                	js     8007c8 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80078e:	83 ec 08             	sub    $0x8,%esp
  800791:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800794:	50                   	push   %eax
  800795:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800798:	ff 30                	pushl  (%eax)
  80079a:	e8 cb fc ff ff       	call   80046a <dev_lookup>
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	85 c0                	test   %eax,%eax
  8007a4:	78 22                	js     8007c8 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007a9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ad:	74 1e                	je     8007cd <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007af:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007b2:	8b 52 0c             	mov    0xc(%edx),%edx
  8007b5:	85 d2                	test   %edx,%edx
  8007b7:	74 35                	je     8007ee <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007b9:	83 ec 04             	sub    $0x4,%esp
  8007bc:	ff 75 10             	pushl  0x10(%ebp)
  8007bf:	ff 75 0c             	pushl  0xc(%ebp)
  8007c2:	50                   	push   %eax
  8007c3:	ff d2                	call   *%edx
  8007c5:	83 c4 10             	add    $0x10,%esp
}
  8007c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007cb:	c9                   	leave  
  8007cc:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007cd:	a1 04 40 80 00       	mov    0x804004,%eax
  8007d2:	8b 40 48             	mov    0x48(%eax),%eax
  8007d5:	83 ec 04             	sub    $0x4,%esp
  8007d8:	53                   	push   %ebx
  8007d9:	50                   	push   %eax
  8007da:	68 75 1f 80 00       	push   $0x801f75
  8007df:	e8 d9 09 00 00       	call   8011bd <cprintf>
		return -E_INVAL;
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ec:	eb da                	jmp    8007c8 <write+0x59>
		return -E_NOT_SUPP;
  8007ee:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007f3:	eb d3                	jmp    8007c8 <write+0x59>

008007f5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007f5:	f3 0f 1e fb          	endbr32 
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800802:	50                   	push   %eax
  800803:	ff 75 08             	pushl  0x8(%ebp)
  800806:	e8 0b fc ff ff       	call   800416 <fd_lookup>
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	85 c0                	test   %eax,%eax
  800810:	78 0e                	js     800820 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  800812:	8b 55 0c             	mov    0xc(%ebp),%edx
  800815:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800818:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80081b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800820:	c9                   	leave  
  800821:	c3                   	ret    

00800822 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800822:	f3 0f 1e fb          	endbr32 
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	53                   	push   %ebx
  80082a:	83 ec 1c             	sub    $0x1c,%esp
  80082d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800830:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800833:	50                   	push   %eax
  800834:	53                   	push   %ebx
  800835:	e8 dc fb ff ff       	call   800416 <fd_lookup>
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	85 c0                	test   %eax,%eax
  80083f:	78 37                	js     800878 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800841:	83 ec 08             	sub    $0x8,%esp
  800844:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800847:	50                   	push   %eax
  800848:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084b:	ff 30                	pushl  (%eax)
  80084d:	e8 18 fc ff ff       	call   80046a <dev_lookup>
  800852:	83 c4 10             	add    $0x10,%esp
  800855:	85 c0                	test   %eax,%eax
  800857:	78 1f                	js     800878 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800859:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80085c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800860:	74 1b                	je     80087d <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800862:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800865:	8b 52 18             	mov    0x18(%edx),%edx
  800868:	85 d2                	test   %edx,%edx
  80086a:	74 32                	je     80089e <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80086c:	83 ec 08             	sub    $0x8,%esp
  80086f:	ff 75 0c             	pushl  0xc(%ebp)
  800872:	50                   	push   %eax
  800873:	ff d2                	call   *%edx
  800875:	83 c4 10             	add    $0x10,%esp
}
  800878:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087b:	c9                   	leave  
  80087c:	c3                   	ret    
			thisenv->env_id, fdnum);
  80087d:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800882:	8b 40 48             	mov    0x48(%eax),%eax
  800885:	83 ec 04             	sub    $0x4,%esp
  800888:	53                   	push   %ebx
  800889:	50                   	push   %eax
  80088a:	68 38 1f 80 00       	push   $0x801f38
  80088f:	e8 29 09 00 00       	call   8011bd <cprintf>
		return -E_INVAL;
  800894:	83 c4 10             	add    $0x10,%esp
  800897:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80089c:	eb da                	jmp    800878 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80089e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008a3:	eb d3                	jmp    800878 <ftruncate+0x56>

008008a5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008a5:	f3 0f 1e fb          	endbr32 
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	53                   	push   %ebx
  8008ad:	83 ec 1c             	sub    $0x1c,%esp
  8008b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008b6:	50                   	push   %eax
  8008b7:	ff 75 08             	pushl  0x8(%ebp)
  8008ba:	e8 57 fb ff ff       	call   800416 <fd_lookup>
  8008bf:	83 c4 10             	add    $0x10,%esp
  8008c2:	85 c0                	test   %eax,%eax
  8008c4:	78 4b                	js     800911 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008c6:	83 ec 08             	sub    $0x8,%esp
  8008c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008cc:	50                   	push   %eax
  8008cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d0:	ff 30                	pushl  (%eax)
  8008d2:	e8 93 fb ff ff       	call   80046a <dev_lookup>
  8008d7:	83 c4 10             	add    $0x10,%esp
  8008da:	85 c0                	test   %eax,%eax
  8008dc:	78 33                	js     800911 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8008de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008e5:	74 2f                	je     800916 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008e7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008ea:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008f1:	00 00 00 
	stat->st_isdir = 0;
  8008f4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008fb:	00 00 00 
	stat->st_dev = dev;
  8008fe:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800904:	83 ec 08             	sub    $0x8,%esp
  800907:	53                   	push   %ebx
  800908:	ff 75 f0             	pushl  -0x10(%ebp)
  80090b:	ff 50 14             	call   *0x14(%eax)
  80090e:	83 c4 10             	add    $0x10,%esp
}
  800911:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800914:	c9                   	leave  
  800915:	c3                   	ret    
		return -E_NOT_SUPP;
  800916:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80091b:	eb f4                	jmp    800911 <fstat+0x6c>

0080091d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80091d:	f3 0f 1e fb          	endbr32 
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	56                   	push   %esi
  800925:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800926:	83 ec 08             	sub    $0x8,%esp
  800929:	6a 00                	push   $0x0
  80092b:	ff 75 08             	pushl  0x8(%ebp)
  80092e:	e8 fb 01 00 00       	call   800b2e <open>
  800933:	89 c3                	mov    %eax,%ebx
  800935:	83 c4 10             	add    $0x10,%esp
  800938:	85 c0                	test   %eax,%eax
  80093a:	78 1b                	js     800957 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80093c:	83 ec 08             	sub    $0x8,%esp
  80093f:	ff 75 0c             	pushl  0xc(%ebp)
  800942:	50                   	push   %eax
  800943:	e8 5d ff ff ff       	call   8008a5 <fstat>
  800948:	89 c6                	mov    %eax,%esi
	close(fd);
  80094a:	89 1c 24             	mov    %ebx,(%esp)
  80094d:	e8 fd fb ff ff       	call   80054f <close>
	return r;
  800952:	83 c4 10             	add    $0x10,%esp
  800955:	89 f3                	mov    %esi,%ebx
}
  800957:	89 d8                	mov    %ebx,%eax
  800959:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80095c:	5b                   	pop    %ebx
  80095d:	5e                   	pop    %esi
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	56                   	push   %esi
  800964:	53                   	push   %ebx
  800965:	89 c6                	mov    %eax,%esi
  800967:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800969:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800970:	74 27                	je     800999 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800972:	6a 07                	push   $0x7
  800974:	68 00 50 80 00       	push   $0x805000
  800979:	56                   	push   %esi
  80097a:	ff 35 00 40 80 00    	pushl  0x804000
  800980:	e8 0a 12 00 00       	call   801b8f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800985:	83 c4 0c             	add    $0xc,%esp
  800988:	6a 00                	push   $0x0
  80098a:	53                   	push   %ebx
  80098b:	6a 00                	push   $0x0
  80098d:	e8 a6 11 00 00       	call   801b38 <ipc_recv>
}
  800992:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800995:	5b                   	pop    %ebx
  800996:	5e                   	pop    %esi
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800999:	83 ec 0c             	sub    $0xc,%esp
  80099c:	6a 01                	push   $0x1
  80099e:	e8 52 12 00 00       	call   801bf5 <ipc_find_env>
  8009a3:	a3 00 40 80 00       	mov    %eax,0x804000
  8009a8:	83 c4 10             	add    $0x10,%esp
  8009ab:	eb c5                	jmp    800972 <fsipc+0x12>

008009ad <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009ad:	f3 0f 1e fb          	endbr32 
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8009bd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cf:	b8 02 00 00 00       	mov    $0x2,%eax
  8009d4:	e8 87 ff ff ff       	call   800960 <fsipc>
}
  8009d9:	c9                   	leave  
  8009da:	c3                   	ret    

008009db <devfile_flush>:
{
  8009db:	f3 0f 1e fb          	endbr32 
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009eb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f5:	b8 06 00 00 00       	mov    $0x6,%eax
  8009fa:	e8 61 ff ff ff       	call   800960 <fsipc>
}
  8009ff:	c9                   	leave  
  800a00:	c3                   	ret    

00800a01 <devfile_stat>:
{
  800a01:	f3 0f 1e fb          	endbr32 
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	53                   	push   %ebx
  800a09:	83 ec 04             	sub    $0x4,%esp
  800a0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 40 0c             	mov    0xc(%eax),%eax
  800a15:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1f:	b8 05 00 00 00       	mov    $0x5,%eax
  800a24:	e8 37 ff ff ff       	call   800960 <fsipc>
  800a29:	85 c0                	test   %eax,%eax
  800a2b:	78 2c                	js     800a59 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a2d:	83 ec 08             	sub    $0x8,%esp
  800a30:	68 00 50 80 00       	push   $0x805000
  800a35:	53                   	push   %ebx
  800a36:	e8 8b 0d 00 00       	call   8017c6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a3b:	a1 80 50 80 00       	mov    0x805080,%eax
  800a40:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a46:	a1 84 50 80 00       	mov    0x805084,%eax
  800a4b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a51:	83 c4 10             	add    $0x10,%esp
  800a54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a5c:	c9                   	leave  
  800a5d:	c3                   	ret    

00800a5e <devfile_write>:
{
  800a5e:	f3 0f 1e fb          	endbr32 
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	83 ec 0c             	sub    $0xc,%esp
  800a68:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  800a6b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a70:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a75:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a78:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7b:	8b 52 0c             	mov    0xc(%edx),%edx
  800a7e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a84:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a89:	50                   	push   %eax
  800a8a:	ff 75 0c             	pushl  0xc(%ebp)
  800a8d:	68 08 50 80 00       	push   $0x805008
  800a92:	e8 e5 0e 00 00       	call   80197c <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a97:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9c:	b8 04 00 00 00       	mov    $0x4,%eax
  800aa1:	e8 ba fe ff ff       	call   800960 <fsipc>
}
  800aa6:	c9                   	leave  
  800aa7:	c3                   	ret    

00800aa8 <devfile_read>:
{
  800aa8:	f3 0f 1e fb          	endbr32 
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
  800ab1:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	8b 40 0c             	mov    0xc(%eax),%eax
  800aba:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800abf:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ac5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aca:	b8 03 00 00 00       	mov    $0x3,%eax
  800acf:	e8 8c fe ff ff       	call   800960 <fsipc>
  800ad4:	89 c3                	mov    %eax,%ebx
  800ad6:	85 c0                	test   %eax,%eax
  800ad8:	78 1f                	js     800af9 <devfile_read+0x51>
	assert(r <= n);
  800ada:	39 f0                	cmp    %esi,%eax
  800adc:	77 24                	ja     800b02 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800ade:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ae3:	7f 33                	jg     800b18 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae5:	83 ec 04             	sub    $0x4,%esp
  800ae8:	50                   	push   %eax
  800ae9:	68 00 50 80 00       	push   $0x805000
  800aee:	ff 75 0c             	pushl  0xc(%ebp)
  800af1:	e8 86 0e 00 00       	call   80197c <memmove>
	return r;
  800af6:	83 c4 10             	add    $0x10,%esp
}
  800af9:	89 d8                	mov    %ebx,%eax
  800afb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    
	assert(r <= n);
  800b02:	68 a4 1f 80 00       	push   $0x801fa4
  800b07:	68 ab 1f 80 00       	push   $0x801fab
  800b0c:	6a 7c                	push   $0x7c
  800b0e:	68 c0 1f 80 00       	push   $0x801fc0
  800b13:	e8 be 05 00 00       	call   8010d6 <_panic>
	assert(r <= PGSIZE);
  800b18:	68 cb 1f 80 00       	push   $0x801fcb
  800b1d:	68 ab 1f 80 00       	push   $0x801fab
  800b22:	6a 7d                	push   $0x7d
  800b24:	68 c0 1f 80 00       	push   $0x801fc0
  800b29:	e8 a8 05 00 00       	call   8010d6 <_panic>

00800b2e <open>:
{
  800b2e:	f3 0f 1e fb          	endbr32 
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
  800b37:	83 ec 1c             	sub    $0x1c,%esp
  800b3a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b3d:	56                   	push   %esi
  800b3e:	e8 40 0c 00 00       	call   801783 <strlen>
  800b43:	83 c4 10             	add    $0x10,%esp
  800b46:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b4b:	7f 6c                	jg     800bb9 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800b4d:	83 ec 0c             	sub    $0xc,%esp
  800b50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b53:	50                   	push   %eax
  800b54:	e8 67 f8 ff ff       	call   8003c0 <fd_alloc>
  800b59:	89 c3                	mov    %eax,%ebx
  800b5b:	83 c4 10             	add    $0x10,%esp
  800b5e:	85 c0                	test   %eax,%eax
  800b60:	78 3c                	js     800b9e <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b62:	83 ec 08             	sub    $0x8,%esp
  800b65:	56                   	push   %esi
  800b66:	68 00 50 80 00       	push   $0x805000
  800b6b:	e8 56 0c 00 00       	call   8017c6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b73:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b78:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b7b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b80:	e8 db fd ff ff       	call   800960 <fsipc>
  800b85:	89 c3                	mov    %eax,%ebx
  800b87:	83 c4 10             	add    $0x10,%esp
  800b8a:	85 c0                	test   %eax,%eax
  800b8c:	78 19                	js     800ba7 <open+0x79>
	return fd2num(fd);
  800b8e:	83 ec 0c             	sub    $0xc,%esp
  800b91:	ff 75 f4             	pushl  -0xc(%ebp)
  800b94:	e8 f8 f7 ff ff       	call   800391 <fd2num>
  800b99:	89 c3                	mov    %eax,%ebx
  800b9b:	83 c4 10             	add    $0x10,%esp
}
  800b9e:	89 d8                	mov    %ebx,%eax
  800ba0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    
		fd_close(fd, 0);
  800ba7:	83 ec 08             	sub    $0x8,%esp
  800baa:	6a 00                	push   $0x0
  800bac:	ff 75 f4             	pushl  -0xc(%ebp)
  800baf:	e8 10 f9 ff ff       	call   8004c4 <fd_close>
		return r;
  800bb4:	83 c4 10             	add    $0x10,%esp
  800bb7:	eb e5                	jmp    800b9e <open+0x70>
		return -E_BAD_PATH;
  800bb9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800bbe:	eb de                	jmp    800b9e <open+0x70>

00800bc0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bc0:	f3 0f 1e fb          	endbr32 
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bca:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcf:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd4:	e8 87 fd ff ff       	call   800960 <fsipc>
}
  800bd9:	c9                   	leave  
  800bda:	c3                   	ret    

00800bdb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bdb:	f3 0f 1e fb          	endbr32 
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800be7:	83 ec 0c             	sub    $0xc,%esp
  800bea:	ff 75 08             	pushl  0x8(%ebp)
  800bed:	e8 b3 f7 ff ff       	call   8003a5 <fd2data>
  800bf2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bf4:	83 c4 08             	add    $0x8,%esp
  800bf7:	68 d7 1f 80 00       	push   $0x801fd7
  800bfc:	53                   	push   %ebx
  800bfd:	e8 c4 0b 00 00       	call   8017c6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800c02:	8b 46 04             	mov    0x4(%esi),%eax
  800c05:	2b 06                	sub    (%esi),%eax
  800c07:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800c0d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c14:	00 00 00 
	stat->st_dev = &devpipe;
  800c17:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c1e:	30 80 00 
	return 0;
}
  800c21:	b8 00 00 00 00       	mov    $0x0,%eax
  800c26:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c2d:	f3 0f 1e fb          	endbr32 
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	53                   	push   %ebx
  800c35:	83 ec 0c             	sub    $0xc,%esp
  800c38:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c3b:	53                   	push   %ebx
  800c3c:	6a 00                	push   $0x0
  800c3e:	e8 ca f5 ff ff       	call   80020d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c43:	89 1c 24             	mov    %ebx,(%esp)
  800c46:	e8 5a f7 ff ff       	call   8003a5 <fd2data>
  800c4b:	83 c4 08             	add    $0x8,%esp
  800c4e:	50                   	push   %eax
  800c4f:	6a 00                	push   $0x0
  800c51:	e8 b7 f5 ff ff       	call   80020d <sys_page_unmap>
}
  800c56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c59:	c9                   	leave  
  800c5a:	c3                   	ret    

00800c5b <_pipeisclosed>:
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	83 ec 1c             	sub    $0x1c,%esp
  800c64:	89 c7                	mov    %eax,%edi
  800c66:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c68:	a1 04 40 80 00       	mov    0x804004,%eax
  800c6d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c70:	83 ec 0c             	sub    $0xc,%esp
  800c73:	57                   	push   %edi
  800c74:	e8 b9 0f 00 00       	call   801c32 <pageref>
  800c79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c7c:	89 34 24             	mov    %esi,(%esp)
  800c7f:	e8 ae 0f 00 00       	call   801c32 <pageref>
		nn = thisenv->env_runs;
  800c84:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c8a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c8d:	83 c4 10             	add    $0x10,%esp
  800c90:	39 cb                	cmp    %ecx,%ebx
  800c92:	74 1b                	je     800caf <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c94:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c97:	75 cf                	jne    800c68 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c99:	8b 42 58             	mov    0x58(%edx),%eax
  800c9c:	6a 01                	push   $0x1
  800c9e:	50                   	push   %eax
  800c9f:	53                   	push   %ebx
  800ca0:	68 de 1f 80 00       	push   $0x801fde
  800ca5:	e8 13 05 00 00       	call   8011bd <cprintf>
  800caa:	83 c4 10             	add    $0x10,%esp
  800cad:	eb b9                	jmp    800c68 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800caf:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800cb2:	0f 94 c0             	sete   %al
  800cb5:	0f b6 c0             	movzbl %al,%eax
}
  800cb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <devpipe_write>:
{
  800cc0:	f3 0f 1e fb          	endbr32 
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 28             	sub    $0x28,%esp
  800ccd:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800cd0:	56                   	push   %esi
  800cd1:	e8 cf f6 ff ff       	call   8003a5 <fd2data>
  800cd6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cd8:	83 c4 10             	add    $0x10,%esp
  800cdb:	bf 00 00 00 00       	mov    $0x0,%edi
  800ce0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ce3:	74 4f                	je     800d34 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800ce5:	8b 43 04             	mov    0x4(%ebx),%eax
  800ce8:	8b 0b                	mov    (%ebx),%ecx
  800cea:	8d 51 20             	lea    0x20(%ecx),%edx
  800ced:	39 d0                	cmp    %edx,%eax
  800cef:	72 14                	jb     800d05 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800cf1:	89 da                	mov    %ebx,%edx
  800cf3:	89 f0                	mov    %esi,%eax
  800cf5:	e8 61 ff ff ff       	call   800c5b <_pipeisclosed>
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	75 3b                	jne    800d39 <devpipe_write+0x79>
			sys_yield();
  800cfe:	e8 5a f4 ff ff       	call   80015d <sys_yield>
  800d03:	eb e0                	jmp    800ce5 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d08:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d0c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d0f:	89 c2                	mov    %eax,%edx
  800d11:	c1 fa 1f             	sar    $0x1f,%edx
  800d14:	89 d1                	mov    %edx,%ecx
  800d16:	c1 e9 1b             	shr    $0x1b,%ecx
  800d19:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800d1c:	83 e2 1f             	and    $0x1f,%edx
  800d1f:	29 ca                	sub    %ecx,%edx
  800d21:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800d25:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d29:	83 c0 01             	add    $0x1,%eax
  800d2c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800d2f:	83 c7 01             	add    $0x1,%edi
  800d32:	eb ac                	jmp    800ce0 <devpipe_write+0x20>
	return i;
  800d34:	8b 45 10             	mov    0x10(%ebp),%eax
  800d37:	eb 05                	jmp    800d3e <devpipe_write+0x7e>
				return 0;
  800d39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <devpipe_read>:
{
  800d46:	f3 0f 1e fb          	endbr32 
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
  800d50:	83 ec 18             	sub    $0x18,%esp
  800d53:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800d56:	57                   	push   %edi
  800d57:	e8 49 f6 ff ff       	call   8003a5 <fd2data>
  800d5c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d5e:	83 c4 10             	add    $0x10,%esp
  800d61:	be 00 00 00 00       	mov    $0x0,%esi
  800d66:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d69:	75 14                	jne    800d7f <devpipe_read+0x39>
	return i;
  800d6b:	8b 45 10             	mov    0x10(%ebp),%eax
  800d6e:	eb 02                	jmp    800d72 <devpipe_read+0x2c>
				return i;
  800d70:	89 f0                	mov    %esi,%eax
}
  800d72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d75:	5b                   	pop    %ebx
  800d76:	5e                   	pop    %esi
  800d77:	5f                   	pop    %edi
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    
			sys_yield();
  800d7a:	e8 de f3 ff ff       	call   80015d <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d7f:	8b 03                	mov    (%ebx),%eax
  800d81:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d84:	75 18                	jne    800d9e <devpipe_read+0x58>
			if (i > 0)
  800d86:	85 f6                	test   %esi,%esi
  800d88:	75 e6                	jne    800d70 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d8a:	89 da                	mov    %ebx,%edx
  800d8c:	89 f8                	mov    %edi,%eax
  800d8e:	e8 c8 fe ff ff       	call   800c5b <_pipeisclosed>
  800d93:	85 c0                	test   %eax,%eax
  800d95:	74 e3                	je     800d7a <devpipe_read+0x34>
				return 0;
  800d97:	b8 00 00 00 00       	mov    $0x0,%eax
  800d9c:	eb d4                	jmp    800d72 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d9e:	99                   	cltd   
  800d9f:	c1 ea 1b             	shr    $0x1b,%edx
  800da2:	01 d0                	add    %edx,%eax
  800da4:	83 e0 1f             	and    $0x1f,%eax
  800da7:	29 d0                	sub    %edx,%eax
  800da9:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800dae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db1:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800db4:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800db7:	83 c6 01             	add    $0x1,%esi
  800dba:	eb aa                	jmp    800d66 <devpipe_read+0x20>

00800dbc <pipe>:
{
  800dbc:	f3 0f 1e fb          	endbr32 
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
  800dc5:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800dc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dcb:	50                   	push   %eax
  800dcc:	e8 ef f5 ff ff       	call   8003c0 <fd_alloc>
  800dd1:	89 c3                	mov    %eax,%ebx
  800dd3:	83 c4 10             	add    $0x10,%esp
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	0f 88 23 01 00 00    	js     800f01 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dde:	83 ec 04             	sub    $0x4,%esp
  800de1:	68 07 04 00 00       	push   $0x407
  800de6:	ff 75 f4             	pushl  -0xc(%ebp)
  800de9:	6a 00                	push   $0x0
  800deb:	e8 90 f3 ff ff       	call   800180 <sys_page_alloc>
  800df0:	89 c3                	mov    %eax,%ebx
  800df2:	83 c4 10             	add    $0x10,%esp
  800df5:	85 c0                	test   %eax,%eax
  800df7:	0f 88 04 01 00 00    	js     800f01 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800dfd:	83 ec 0c             	sub    $0xc,%esp
  800e00:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e03:	50                   	push   %eax
  800e04:	e8 b7 f5 ff ff       	call   8003c0 <fd_alloc>
  800e09:	89 c3                	mov    %eax,%ebx
  800e0b:	83 c4 10             	add    $0x10,%esp
  800e0e:	85 c0                	test   %eax,%eax
  800e10:	0f 88 db 00 00 00    	js     800ef1 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e16:	83 ec 04             	sub    $0x4,%esp
  800e19:	68 07 04 00 00       	push   $0x407
  800e1e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e21:	6a 00                	push   $0x0
  800e23:	e8 58 f3 ff ff       	call   800180 <sys_page_alloc>
  800e28:	89 c3                	mov    %eax,%ebx
  800e2a:	83 c4 10             	add    $0x10,%esp
  800e2d:	85 c0                	test   %eax,%eax
  800e2f:	0f 88 bc 00 00 00    	js     800ef1 <pipe+0x135>
	va = fd2data(fd0);
  800e35:	83 ec 0c             	sub    $0xc,%esp
  800e38:	ff 75 f4             	pushl  -0xc(%ebp)
  800e3b:	e8 65 f5 ff ff       	call   8003a5 <fd2data>
  800e40:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e42:	83 c4 0c             	add    $0xc,%esp
  800e45:	68 07 04 00 00       	push   $0x407
  800e4a:	50                   	push   %eax
  800e4b:	6a 00                	push   $0x0
  800e4d:	e8 2e f3 ff ff       	call   800180 <sys_page_alloc>
  800e52:	89 c3                	mov    %eax,%ebx
  800e54:	83 c4 10             	add    $0x10,%esp
  800e57:	85 c0                	test   %eax,%eax
  800e59:	0f 88 82 00 00 00    	js     800ee1 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e5f:	83 ec 0c             	sub    $0xc,%esp
  800e62:	ff 75 f0             	pushl  -0x10(%ebp)
  800e65:	e8 3b f5 ff ff       	call   8003a5 <fd2data>
  800e6a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e71:	50                   	push   %eax
  800e72:	6a 00                	push   $0x0
  800e74:	56                   	push   %esi
  800e75:	6a 00                	push   $0x0
  800e77:	e8 4b f3 ff ff       	call   8001c7 <sys_page_map>
  800e7c:	89 c3                	mov    %eax,%ebx
  800e7e:	83 c4 20             	add    $0x20,%esp
  800e81:	85 c0                	test   %eax,%eax
  800e83:	78 4e                	js     800ed3 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e85:	a1 20 30 80 00       	mov    0x803020,%eax
  800e8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e8d:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e92:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e99:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e9c:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ea1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800ea8:	83 ec 0c             	sub    $0xc,%esp
  800eab:	ff 75 f4             	pushl  -0xc(%ebp)
  800eae:	e8 de f4 ff ff       	call   800391 <fd2num>
  800eb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800eb8:	83 c4 04             	add    $0x4,%esp
  800ebb:	ff 75 f0             	pushl  -0x10(%ebp)
  800ebe:	e8 ce f4 ff ff       	call   800391 <fd2num>
  800ec3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800ec9:	83 c4 10             	add    $0x10,%esp
  800ecc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed1:	eb 2e                	jmp    800f01 <pipe+0x145>
	sys_page_unmap(0, va);
  800ed3:	83 ec 08             	sub    $0x8,%esp
  800ed6:	56                   	push   %esi
  800ed7:	6a 00                	push   $0x0
  800ed9:	e8 2f f3 ff ff       	call   80020d <sys_page_unmap>
  800ede:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800ee1:	83 ec 08             	sub    $0x8,%esp
  800ee4:	ff 75 f0             	pushl  -0x10(%ebp)
  800ee7:	6a 00                	push   $0x0
  800ee9:	e8 1f f3 ff ff       	call   80020d <sys_page_unmap>
  800eee:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800ef1:	83 ec 08             	sub    $0x8,%esp
  800ef4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ef7:	6a 00                	push   $0x0
  800ef9:	e8 0f f3 ff ff       	call   80020d <sys_page_unmap>
  800efe:	83 c4 10             	add    $0x10,%esp
}
  800f01:	89 d8                	mov    %ebx,%eax
  800f03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f06:	5b                   	pop    %ebx
  800f07:	5e                   	pop    %esi
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    

00800f0a <pipeisclosed>:
{
  800f0a:	f3 0f 1e fb          	endbr32 
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f17:	50                   	push   %eax
  800f18:	ff 75 08             	pushl  0x8(%ebp)
  800f1b:	e8 f6 f4 ff ff       	call   800416 <fd_lookup>
  800f20:	83 c4 10             	add    $0x10,%esp
  800f23:	85 c0                	test   %eax,%eax
  800f25:	78 18                	js     800f3f <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800f27:	83 ec 0c             	sub    $0xc,%esp
  800f2a:	ff 75 f4             	pushl  -0xc(%ebp)
  800f2d:	e8 73 f4 ff ff       	call   8003a5 <fd2data>
  800f32:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f37:	e8 1f fd ff ff       	call   800c5b <_pipeisclosed>
  800f3c:	83 c4 10             	add    $0x10,%esp
}
  800f3f:	c9                   	leave  
  800f40:	c3                   	ret    

00800f41 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f41:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800f45:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4a:	c3                   	ret    

00800f4b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f4b:	f3 0f 1e fb          	endbr32 
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f55:	68 f6 1f 80 00       	push   $0x801ff6
  800f5a:	ff 75 0c             	pushl  0xc(%ebp)
  800f5d:	e8 64 08 00 00       	call   8017c6 <strcpy>
	return 0;
}
  800f62:	b8 00 00 00 00       	mov    $0x0,%eax
  800f67:	c9                   	leave  
  800f68:	c3                   	ret    

00800f69 <devcons_write>:
{
  800f69:	f3 0f 1e fb          	endbr32 
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	57                   	push   %edi
  800f71:	56                   	push   %esi
  800f72:	53                   	push   %ebx
  800f73:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f79:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f7e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f84:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f87:	73 31                	jae    800fba <devcons_write+0x51>
		m = n - tot;
  800f89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f8c:	29 f3                	sub    %esi,%ebx
  800f8e:	83 fb 7f             	cmp    $0x7f,%ebx
  800f91:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f96:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f99:	83 ec 04             	sub    $0x4,%esp
  800f9c:	53                   	push   %ebx
  800f9d:	89 f0                	mov    %esi,%eax
  800f9f:	03 45 0c             	add    0xc(%ebp),%eax
  800fa2:	50                   	push   %eax
  800fa3:	57                   	push   %edi
  800fa4:	e8 d3 09 00 00       	call   80197c <memmove>
		sys_cputs(buf, m);
  800fa9:	83 c4 08             	add    $0x8,%esp
  800fac:	53                   	push   %ebx
  800fad:	57                   	push   %edi
  800fae:	e8 fd f0 ff ff       	call   8000b0 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800fb3:	01 de                	add    %ebx,%esi
  800fb5:	83 c4 10             	add    $0x10,%esp
  800fb8:	eb ca                	jmp    800f84 <devcons_write+0x1b>
}
  800fba:	89 f0                	mov    %esi,%eax
  800fbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fbf:	5b                   	pop    %ebx
  800fc0:	5e                   	pop    %esi
  800fc1:	5f                   	pop    %edi
  800fc2:	5d                   	pop    %ebp
  800fc3:	c3                   	ret    

00800fc4 <devcons_read>:
{
  800fc4:	f3 0f 1e fb          	endbr32 
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	83 ec 08             	sub    $0x8,%esp
  800fce:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800fd3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fd7:	74 21                	je     800ffa <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800fd9:	e8 f4 f0 ff ff       	call   8000d2 <sys_cgetc>
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	75 07                	jne    800fe9 <devcons_read+0x25>
		sys_yield();
  800fe2:	e8 76 f1 ff ff       	call   80015d <sys_yield>
  800fe7:	eb f0                	jmp    800fd9 <devcons_read+0x15>
	if (c < 0)
  800fe9:	78 0f                	js     800ffa <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800feb:	83 f8 04             	cmp    $0x4,%eax
  800fee:	74 0c                	je     800ffc <devcons_read+0x38>
	*(char*)vbuf = c;
  800ff0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ff3:	88 02                	mov    %al,(%edx)
	return 1;
  800ff5:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800ffa:	c9                   	leave  
  800ffb:	c3                   	ret    
		return 0;
  800ffc:	b8 00 00 00 00       	mov    $0x0,%eax
  801001:	eb f7                	jmp    800ffa <devcons_read+0x36>

00801003 <cputchar>:
{
  801003:	f3 0f 1e fb          	endbr32 
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80100d:	8b 45 08             	mov    0x8(%ebp),%eax
  801010:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801013:	6a 01                	push   $0x1
  801015:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801018:	50                   	push   %eax
  801019:	e8 92 f0 ff ff       	call   8000b0 <sys_cputs>
}
  80101e:	83 c4 10             	add    $0x10,%esp
  801021:	c9                   	leave  
  801022:	c3                   	ret    

00801023 <getchar>:
{
  801023:	f3 0f 1e fb          	endbr32 
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80102d:	6a 01                	push   $0x1
  80102f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801032:	50                   	push   %eax
  801033:	6a 00                	push   $0x0
  801035:	e8 5f f6 ff ff       	call   800699 <read>
	if (r < 0)
  80103a:	83 c4 10             	add    $0x10,%esp
  80103d:	85 c0                	test   %eax,%eax
  80103f:	78 06                	js     801047 <getchar+0x24>
	if (r < 1)
  801041:	74 06                	je     801049 <getchar+0x26>
	return c;
  801043:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801047:	c9                   	leave  
  801048:	c3                   	ret    
		return -E_EOF;
  801049:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80104e:	eb f7                	jmp    801047 <getchar+0x24>

00801050 <iscons>:
{
  801050:	f3 0f 1e fb          	endbr32 
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80105a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80105d:	50                   	push   %eax
  80105e:	ff 75 08             	pushl  0x8(%ebp)
  801061:	e8 b0 f3 ff ff       	call   800416 <fd_lookup>
  801066:	83 c4 10             	add    $0x10,%esp
  801069:	85 c0                	test   %eax,%eax
  80106b:	78 11                	js     80107e <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80106d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801070:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801076:	39 10                	cmp    %edx,(%eax)
  801078:	0f 94 c0             	sete   %al
  80107b:	0f b6 c0             	movzbl %al,%eax
}
  80107e:	c9                   	leave  
  80107f:	c3                   	ret    

00801080 <opencons>:
{
  801080:	f3 0f 1e fb          	endbr32 
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80108a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80108d:	50                   	push   %eax
  80108e:	e8 2d f3 ff ff       	call   8003c0 <fd_alloc>
  801093:	83 c4 10             	add    $0x10,%esp
  801096:	85 c0                	test   %eax,%eax
  801098:	78 3a                	js     8010d4 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80109a:	83 ec 04             	sub    $0x4,%esp
  80109d:	68 07 04 00 00       	push   $0x407
  8010a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8010a5:	6a 00                	push   $0x0
  8010a7:	e8 d4 f0 ff ff       	call   800180 <sys_page_alloc>
  8010ac:	83 c4 10             	add    $0x10,%esp
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	78 21                	js     8010d4 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8010b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8010bc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8010be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8010c8:	83 ec 0c             	sub    $0xc,%esp
  8010cb:	50                   	push   %eax
  8010cc:	e8 c0 f2 ff ff       	call   800391 <fd2num>
  8010d1:	83 c4 10             	add    $0x10,%esp
}
  8010d4:	c9                   	leave  
  8010d5:	c3                   	ret    

008010d6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010d6:	f3 0f 1e fb          	endbr32 
  8010da:	55                   	push   %ebp
  8010db:	89 e5                	mov    %esp,%ebp
  8010dd:	56                   	push   %esi
  8010de:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010df:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010e2:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010e8:	e8 4d f0 ff ff       	call   80013a <sys_getenvid>
  8010ed:	83 ec 0c             	sub    $0xc,%esp
  8010f0:	ff 75 0c             	pushl  0xc(%ebp)
  8010f3:	ff 75 08             	pushl  0x8(%ebp)
  8010f6:	56                   	push   %esi
  8010f7:	50                   	push   %eax
  8010f8:	68 04 20 80 00       	push   $0x802004
  8010fd:	e8 bb 00 00 00       	call   8011bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801102:	83 c4 18             	add    $0x18,%esp
  801105:	53                   	push   %ebx
  801106:	ff 75 10             	pushl  0x10(%ebp)
  801109:	e8 5a 00 00 00       	call   801168 <vcprintf>
	cprintf("\n");
  80110e:	c7 04 24 ef 1f 80 00 	movl   $0x801fef,(%esp)
  801115:	e8 a3 00 00 00       	call   8011bd <cprintf>
  80111a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80111d:	cc                   	int3   
  80111e:	eb fd                	jmp    80111d <_panic+0x47>

00801120 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801120:	f3 0f 1e fb          	endbr32 
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	53                   	push   %ebx
  801128:	83 ec 04             	sub    $0x4,%esp
  80112b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80112e:	8b 13                	mov    (%ebx),%edx
  801130:	8d 42 01             	lea    0x1(%edx),%eax
  801133:	89 03                	mov    %eax,(%ebx)
  801135:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801138:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80113c:	3d ff 00 00 00       	cmp    $0xff,%eax
  801141:	74 09                	je     80114c <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801143:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801147:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80114a:	c9                   	leave  
  80114b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80114c:	83 ec 08             	sub    $0x8,%esp
  80114f:	68 ff 00 00 00       	push   $0xff
  801154:	8d 43 08             	lea    0x8(%ebx),%eax
  801157:	50                   	push   %eax
  801158:	e8 53 ef ff ff       	call   8000b0 <sys_cputs>
		b->idx = 0;
  80115d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801163:	83 c4 10             	add    $0x10,%esp
  801166:	eb db                	jmp    801143 <putch+0x23>

00801168 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801168:	f3 0f 1e fb          	endbr32 
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801175:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80117c:	00 00 00 
	b.cnt = 0;
  80117f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801186:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801189:	ff 75 0c             	pushl  0xc(%ebp)
  80118c:	ff 75 08             	pushl  0x8(%ebp)
  80118f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801195:	50                   	push   %eax
  801196:	68 20 11 80 00       	push   $0x801120
  80119b:	e8 20 01 00 00       	call   8012c0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8011a0:	83 c4 08             	add    $0x8,%esp
  8011a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8011a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8011af:	50                   	push   %eax
  8011b0:	e8 fb ee ff ff       	call   8000b0 <sys_cputs>

	return b.cnt;
}
  8011b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8011bb:	c9                   	leave  
  8011bc:	c3                   	ret    

008011bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8011bd:	f3 0f 1e fb          	endbr32 
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8011c7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8011ca:	50                   	push   %eax
  8011cb:	ff 75 08             	pushl  0x8(%ebp)
  8011ce:	e8 95 ff ff ff       	call   801168 <vcprintf>
	va_end(ap);

	return cnt;
}
  8011d3:	c9                   	leave  
  8011d4:	c3                   	ret    

008011d5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	57                   	push   %edi
  8011d9:	56                   	push   %esi
  8011da:	53                   	push   %ebx
  8011db:	83 ec 1c             	sub    $0x1c,%esp
  8011de:	89 c7                	mov    %eax,%edi
  8011e0:	89 d6                	mov    %edx,%esi
  8011e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e8:	89 d1                	mov    %edx,%ecx
  8011ea:	89 c2                	mov    %eax,%edx
  8011ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011ef:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8011f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8011f5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011fb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801202:	39 c2                	cmp    %eax,%edx
  801204:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801207:	72 3e                	jb     801247 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801209:	83 ec 0c             	sub    $0xc,%esp
  80120c:	ff 75 18             	pushl  0x18(%ebp)
  80120f:	83 eb 01             	sub    $0x1,%ebx
  801212:	53                   	push   %ebx
  801213:	50                   	push   %eax
  801214:	83 ec 08             	sub    $0x8,%esp
  801217:	ff 75 e4             	pushl  -0x1c(%ebp)
  80121a:	ff 75 e0             	pushl  -0x20(%ebp)
  80121d:	ff 75 dc             	pushl  -0x24(%ebp)
  801220:	ff 75 d8             	pushl  -0x28(%ebp)
  801223:	e8 58 0a 00 00       	call   801c80 <__udivdi3>
  801228:	83 c4 18             	add    $0x18,%esp
  80122b:	52                   	push   %edx
  80122c:	50                   	push   %eax
  80122d:	89 f2                	mov    %esi,%edx
  80122f:	89 f8                	mov    %edi,%eax
  801231:	e8 9f ff ff ff       	call   8011d5 <printnum>
  801236:	83 c4 20             	add    $0x20,%esp
  801239:	eb 13                	jmp    80124e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80123b:	83 ec 08             	sub    $0x8,%esp
  80123e:	56                   	push   %esi
  80123f:	ff 75 18             	pushl  0x18(%ebp)
  801242:	ff d7                	call   *%edi
  801244:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801247:	83 eb 01             	sub    $0x1,%ebx
  80124a:	85 db                	test   %ebx,%ebx
  80124c:	7f ed                	jg     80123b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80124e:	83 ec 08             	sub    $0x8,%esp
  801251:	56                   	push   %esi
  801252:	83 ec 04             	sub    $0x4,%esp
  801255:	ff 75 e4             	pushl  -0x1c(%ebp)
  801258:	ff 75 e0             	pushl  -0x20(%ebp)
  80125b:	ff 75 dc             	pushl  -0x24(%ebp)
  80125e:	ff 75 d8             	pushl  -0x28(%ebp)
  801261:	e8 2a 0b 00 00       	call   801d90 <__umoddi3>
  801266:	83 c4 14             	add    $0x14,%esp
  801269:	0f be 80 27 20 80 00 	movsbl 0x802027(%eax),%eax
  801270:	50                   	push   %eax
  801271:	ff d7                	call   *%edi
}
  801273:	83 c4 10             	add    $0x10,%esp
  801276:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801279:	5b                   	pop    %ebx
  80127a:	5e                   	pop    %esi
  80127b:	5f                   	pop    %edi
  80127c:	5d                   	pop    %ebp
  80127d:	c3                   	ret    

0080127e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80127e:	f3 0f 1e fb          	endbr32 
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801288:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80128c:	8b 10                	mov    (%eax),%edx
  80128e:	3b 50 04             	cmp    0x4(%eax),%edx
  801291:	73 0a                	jae    80129d <sprintputch+0x1f>
		*b->buf++ = ch;
  801293:	8d 4a 01             	lea    0x1(%edx),%ecx
  801296:	89 08                	mov    %ecx,(%eax)
  801298:	8b 45 08             	mov    0x8(%ebp),%eax
  80129b:	88 02                	mov    %al,(%edx)
}
  80129d:	5d                   	pop    %ebp
  80129e:	c3                   	ret    

0080129f <printfmt>:
{
  80129f:	f3 0f 1e fb          	endbr32 
  8012a3:	55                   	push   %ebp
  8012a4:	89 e5                	mov    %esp,%ebp
  8012a6:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8012a9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012ac:	50                   	push   %eax
  8012ad:	ff 75 10             	pushl  0x10(%ebp)
  8012b0:	ff 75 0c             	pushl  0xc(%ebp)
  8012b3:	ff 75 08             	pushl  0x8(%ebp)
  8012b6:	e8 05 00 00 00       	call   8012c0 <vprintfmt>
}
  8012bb:	83 c4 10             	add    $0x10,%esp
  8012be:	c9                   	leave  
  8012bf:	c3                   	ret    

008012c0 <vprintfmt>:
{
  8012c0:	f3 0f 1e fb          	endbr32 
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	57                   	push   %edi
  8012c8:	56                   	push   %esi
  8012c9:	53                   	push   %ebx
  8012ca:	83 ec 3c             	sub    $0x3c,%esp
  8012cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8012d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012d3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012d6:	e9 4a 03 00 00       	jmp    801625 <vprintfmt+0x365>
		padc = ' ';
  8012db:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012df:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012e6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012ed:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012f4:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012f9:	8d 47 01             	lea    0x1(%edi),%eax
  8012fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012ff:	0f b6 17             	movzbl (%edi),%edx
  801302:	8d 42 dd             	lea    -0x23(%edx),%eax
  801305:	3c 55                	cmp    $0x55,%al
  801307:	0f 87 de 03 00 00    	ja     8016eb <vprintfmt+0x42b>
  80130d:	0f b6 c0             	movzbl %al,%eax
  801310:	3e ff 24 85 60 21 80 	notrack jmp *0x802160(,%eax,4)
  801317:	00 
  801318:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80131b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80131f:	eb d8                	jmp    8012f9 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801321:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801324:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801328:	eb cf                	jmp    8012f9 <vprintfmt+0x39>
  80132a:	0f b6 d2             	movzbl %dl,%edx
  80132d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801330:	b8 00 00 00 00       	mov    $0x0,%eax
  801335:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801338:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80133b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80133f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801342:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801345:	83 f9 09             	cmp    $0x9,%ecx
  801348:	77 55                	ja     80139f <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80134a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80134d:	eb e9                	jmp    801338 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80134f:	8b 45 14             	mov    0x14(%ebp),%eax
  801352:	8b 00                	mov    (%eax),%eax
  801354:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801357:	8b 45 14             	mov    0x14(%ebp),%eax
  80135a:	8d 40 04             	lea    0x4(%eax),%eax
  80135d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801363:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801367:	79 90                	jns    8012f9 <vprintfmt+0x39>
				width = precision, precision = -1;
  801369:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80136c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80136f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801376:	eb 81                	jmp    8012f9 <vprintfmt+0x39>
  801378:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80137b:	85 c0                	test   %eax,%eax
  80137d:	ba 00 00 00 00       	mov    $0x0,%edx
  801382:	0f 49 d0             	cmovns %eax,%edx
  801385:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80138b:	e9 69 ff ff ff       	jmp    8012f9 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801393:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80139a:	e9 5a ff ff ff       	jmp    8012f9 <vprintfmt+0x39>
  80139f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8013a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8013a5:	eb bc                	jmp    801363 <vprintfmt+0xa3>
			lflag++;
  8013a7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8013aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8013ad:	e9 47 ff ff ff       	jmp    8012f9 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8013b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b5:	8d 78 04             	lea    0x4(%eax),%edi
  8013b8:	83 ec 08             	sub    $0x8,%esp
  8013bb:	53                   	push   %ebx
  8013bc:	ff 30                	pushl  (%eax)
  8013be:	ff d6                	call   *%esi
			break;
  8013c0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8013c3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8013c6:	e9 57 02 00 00       	jmp    801622 <vprintfmt+0x362>
			err = va_arg(ap, int);
  8013cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ce:	8d 78 04             	lea    0x4(%eax),%edi
  8013d1:	8b 00                	mov    (%eax),%eax
  8013d3:	99                   	cltd   
  8013d4:	31 d0                	xor    %edx,%eax
  8013d6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013d8:	83 f8 0f             	cmp    $0xf,%eax
  8013db:	7f 23                	jg     801400 <vprintfmt+0x140>
  8013dd:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  8013e4:	85 d2                	test   %edx,%edx
  8013e6:	74 18                	je     801400 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8013e8:	52                   	push   %edx
  8013e9:	68 bd 1f 80 00       	push   $0x801fbd
  8013ee:	53                   	push   %ebx
  8013ef:	56                   	push   %esi
  8013f0:	e8 aa fe ff ff       	call   80129f <printfmt>
  8013f5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8013f8:	89 7d 14             	mov    %edi,0x14(%ebp)
  8013fb:	e9 22 02 00 00       	jmp    801622 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  801400:	50                   	push   %eax
  801401:	68 3f 20 80 00       	push   $0x80203f
  801406:	53                   	push   %ebx
  801407:	56                   	push   %esi
  801408:	e8 92 fe ff ff       	call   80129f <printfmt>
  80140d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801410:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801413:	e9 0a 02 00 00       	jmp    801622 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  801418:	8b 45 14             	mov    0x14(%ebp),%eax
  80141b:	83 c0 04             	add    $0x4,%eax
  80141e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801421:	8b 45 14             	mov    0x14(%ebp),%eax
  801424:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801426:	85 d2                	test   %edx,%edx
  801428:	b8 38 20 80 00       	mov    $0x802038,%eax
  80142d:	0f 45 c2             	cmovne %edx,%eax
  801430:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801433:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801437:	7e 06                	jle    80143f <vprintfmt+0x17f>
  801439:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80143d:	75 0d                	jne    80144c <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80143f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801442:	89 c7                	mov    %eax,%edi
  801444:	03 45 e0             	add    -0x20(%ebp),%eax
  801447:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80144a:	eb 55                	jmp    8014a1 <vprintfmt+0x1e1>
  80144c:	83 ec 08             	sub    $0x8,%esp
  80144f:	ff 75 d8             	pushl  -0x28(%ebp)
  801452:	ff 75 cc             	pushl  -0x34(%ebp)
  801455:	e8 45 03 00 00       	call   80179f <strnlen>
  80145a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80145d:	29 c2                	sub    %eax,%edx
  80145f:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  801467:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80146b:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80146e:	85 ff                	test   %edi,%edi
  801470:	7e 11                	jle    801483 <vprintfmt+0x1c3>
					putch(padc, putdat);
  801472:	83 ec 08             	sub    $0x8,%esp
  801475:	53                   	push   %ebx
  801476:	ff 75 e0             	pushl  -0x20(%ebp)
  801479:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80147b:	83 ef 01             	sub    $0x1,%edi
  80147e:	83 c4 10             	add    $0x10,%esp
  801481:	eb eb                	jmp    80146e <vprintfmt+0x1ae>
  801483:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801486:	85 d2                	test   %edx,%edx
  801488:	b8 00 00 00 00       	mov    $0x0,%eax
  80148d:	0f 49 c2             	cmovns %edx,%eax
  801490:	29 c2                	sub    %eax,%edx
  801492:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801495:	eb a8                	jmp    80143f <vprintfmt+0x17f>
					putch(ch, putdat);
  801497:	83 ec 08             	sub    $0x8,%esp
  80149a:	53                   	push   %ebx
  80149b:	52                   	push   %edx
  80149c:	ff d6                	call   *%esi
  80149e:	83 c4 10             	add    $0x10,%esp
  8014a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014a4:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014a6:	83 c7 01             	add    $0x1,%edi
  8014a9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014ad:	0f be d0             	movsbl %al,%edx
  8014b0:	85 d2                	test   %edx,%edx
  8014b2:	74 4b                	je     8014ff <vprintfmt+0x23f>
  8014b4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014b8:	78 06                	js     8014c0 <vprintfmt+0x200>
  8014ba:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014be:	78 1e                	js     8014de <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8014c0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014c4:	74 d1                	je     801497 <vprintfmt+0x1d7>
  8014c6:	0f be c0             	movsbl %al,%eax
  8014c9:	83 e8 20             	sub    $0x20,%eax
  8014cc:	83 f8 5e             	cmp    $0x5e,%eax
  8014cf:	76 c6                	jbe    801497 <vprintfmt+0x1d7>
					putch('?', putdat);
  8014d1:	83 ec 08             	sub    $0x8,%esp
  8014d4:	53                   	push   %ebx
  8014d5:	6a 3f                	push   $0x3f
  8014d7:	ff d6                	call   *%esi
  8014d9:	83 c4 10             	add    $0x10,%esp
  8014dc:	eb c3                	jmp    8014a1 <vprintfmt+0x1e1>
  8014de:	89 cf                	mov    %ecx,%edi
  8014e0:	eb 0e                	jmp    8014f0 <vprintfmt+0x230>
				putch(' ', putdat);
  8014e2:	83 ec 08             	sub    $0x8,%esp
  8014e5:	53                   	push   %ebx
  8014e6:	6a 20                	push   $0x20
  8014e8:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8014ea:	83 ef 01             	sub    $0x1,%edi
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	85 ff                	test   %edi,%edi
  8014f2:	7f ee                	jg     8014e2 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8014f4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8014f7:	89 45 14             	mov    %eax,0x14(%ebp)
  8014fa:	e9 23 01 00 00       	jmp    801622 <vprintfmt+0x362>
  8014ff:	89 cf                	mov    %ecx,%edi
  801501:	eb ed                	jmp    8014f0 <vprintfmt+0x230>
	if (lflag >= 2)
  801503:	83 f9 01             	cmp    $0x1,%ecx
  801506:	7f 1b                	jg     801523 <vprintfmt+0x263>
	else if (lflag)
  801508:	85 c9                	test   %ecx,%ecx
  80150a:	74 63                	je     80156f <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80150c:	8b 45 14             	mov    0x14(%ebp),%eax
  80150f:	8b 00                	mov    (%eax),%eax
  801511:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801514:	99                   	cltd   
  801515:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801518:	8b 45 14             	mov    0x14(%ebp),%eax
  80151b:	8d 40 04             	lea    0x4(%eax),%eax
  80151e:	89 45 14             	mov    %eax,0x14(%ebp)
  801521:	eb 17                	jmp    80153a <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  801523:	8b 45 14             	mov    0x14(%ebp),%eax
  801526:	8b 50 04             	mov    0x4(%eax),%edx
  801529:	8b 00                	mov    (%eax),%eax
  80152b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80152e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801531:	8b 45 14             	mov    0x14(%ebp),%eax
  801534:	8d 40 08             	lea    0x8(%eax),%eax
  801537:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80153a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80153d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801540:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  801545:	85 c9                	test   %ecx,%ecx
  801547:	0f 89 bb 00 00 00    	jns    801608 <vprintfmt+0x348>
				putch('-', putdat);
  80154d:	83 ec 08             	sub    $0x8,%esp
  801550:	53                   	push   %ebx
  801551:	6a 2d                	push   $0x2d
  801553:	ff d6                	call   *%esi
				num = -(long long) num;
  801555:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801558:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80155b:	f7 da                	neg    %edx
  80155d:	83 d1 00             	adc    $0x0,%ecx
  801560:	f7 d9                	neg    %ecx
  801562:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801565:	b8 0a 00 00 00       	mov    $0xa,%eax
  80156a:	e9 99 00 00 00       	jmp    801608 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80156f:	8b 45 14             	mov    0x14(%ebp),%eax
  801572:	8b 00                	mov    (%eax),%eax
  801574:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801577:	99                   	cltd   
  801578:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80157b:	8b 45 14             	mov    0x14(%ebp),%eax
  80157e:	8d 40 04             	lea    0x4(%eax),%eax
  801581:	89 45 14             	mov    %eax,0x14(%ebp)
  801584:	eb b4                	jmp    80153a <vprintfmt+0x27a>
	if (lflag >= 2)
  801586:	83 f9 01             	cmp    $0x1,%ecx
  801589:	7f 1b                	jg     8015a6 <vprintfmt+0x2e6>
	else if (lflag)
  80158b:	85 c9                	test   %ecx,%ecx
  80158d:	74 2c                	je     8015bb <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80158f:	8b 45 14             	mov    0x14(%ebp),%eax
  801592:	8b 10                	mov    (%eax),%edx
  801594:	b9 00 00 00 00       	mov    $0x0,%ecx
  801599:	8d 40 04             	lea    0x4(%eax),%eax
  80159c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80159f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8015a4:	eb 62                	jmp    801608 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8015a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a9:	8b 10                	mov    (%eax),%edx
  8015ab:	8b 48 04             	mov    0x4(%eax),%ecx
  8015ae:	8d 40 08             	lea    0x8(%eax),%eax
  8015b1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015b4:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8015b9:	eb 4d                	jmp    801608 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8015bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8015be:	8b 10                	mov    (%eax),%edx
  8015c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015c5:	8d 40 04             	lea    0x4(%eax),%eax
  8015c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015cb:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8015d0:	eb 36                	jmp    801608 <vprintfmt+0x348>
	if (lflag >= 2)
  8015d2:	83 f9 01             	cmp    $0x1,%ecx
  8015d5:	7f 17                	jg     8015ee <vprintfmt+0x32e>
	else if (lflag)
  8015d7:	85 c9                	test   %ecx,%ecx
  8015d9:	74 6e                	je     801649 <vprintfmt+0x389>
		return va_arg(*ap, long);
  8015db:	8b 45 14             	mov    0x14(%ebp),%eax
  8015de:	8b 10                	mov    (%eax),%edx
  8015e0:	89 d0                	mov    %edx,%eax
  8015e2:	99                   	cltd   
  8015e3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015e6:	8d 49 04             	lea    0x4(%ecx),%ecx
  8015e9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8015ec:	eb 11                	jmp    8015ff <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8015ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f1:	8b 50 04             	mov    0x4(%eax),%edx
  8015f4:	8b 00                	mov    (%eax),%eax
  8015f6:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015f9:	8d 49 08             	lea    0x8(%ecx),%ecx
  8015fc:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8015ff:	89 d1                	mov    %edx,%ecx
  801601:	89 c2                	mov    %eax,%edx
            base = 8;
  801603:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  801608:	83 ec 0c             	sub    $0xc,%esp
  80160b:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80160f:	57                   	push   %edi
  801610:	ff 75 e0             	pushl  -0x20(%ebp)
  801613:	50                   	push   %eax
  801614:	51                   	push   %ecx
  801615:	52                   	push   %edx
  801616:	89 da                	mov    %ebx,%edx
  801618:	89 f0                	mov    %esi,%eax
  80161a:	e8 b6 fb ff ff       	call   8011d5 <printnum>
			break;
  80161f:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  801622:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801625:	83 c7 01             	add    $0x1,%edi
  801628:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80162c:	83 f8 25             	cmp    $0x25,%eax
  80162f:	0f 84 a6 fc ff ff    	je     8012db <vprintfmt+0x1b>
			if (ch == '\0')
  801635:	85 c0                	test   %eax,%eax
  801637:	0f 84 ce 00 00 00    	je     80170b <vprintfmt+0x44b>
			putch(ch, putdat);
  80163d:	83 ec 08             	sub    $0x8,%esp
  801640:	53                   	push   %ebx
  801641:	50                   	push   %eax
  801642:	ff d6                	call   *%esi
  801644:	83 c4 10             	add    $0x10,%esp
  801647:	eb dc                	jmp    801625 <vprintfmt+0x365>
		return va_arg(*ap, int);
  801649:	8b 45 14             	mov    0x14(%ebp),%eax
  80164c:	8b 10                	mov    (%eax),%edx
  80164e:	89 d0                	mov    %edx,%eax
  801650:	99                   	cltd   
  801651:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801654:	8d 49 04             	lea    0x4(%ecx),%ecx
  801657:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80165a:	eb a3                	jmp    8015ff <vprintfmt+0x33f>
			putch('0', putdat);
  80165c:	83 ec 08             	sub    $0x8,%esp
  80165f:	53                   	push   %ebx
  801660:	6a 30                	push   $0x30
  801662:	ff d6                	call   *%esi
			putch('x', putdat);
  801664:	83 c4 08             	add    $0x8,%esp
  801667:	53                   	push   %ebx
  801668:	6a 78                	push   $0x78
  80166a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80166c:	8b 45 14             	mov    0x14(%ebp),%eax
  80166f:	8b 10                	mov    (%eax),%edx
  801671:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801676:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801679:	8d 40 04             	lea    0x4(%eax),%eax
  80167c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80167f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801684:	eb 82                	jmp    801608 <vprintfmt+0x348>
	if (lflag >= 2)
  801686:	83 f9 01             	cmp    $0x1,%ecx
  801689:	7f 1e                	jg     8016a9 <vprintfmt+0x3e9>
	else if (lflag)
  80168b:	85 c9                	test   %ecx,%ecx
  80168d:	74 32                	je     8016c1 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80168f:	8b 45 14             	mov    0x14(%ebp),%eax
  801692:	8b 10                	mov    (%eax),%edx
  801694:	b9 00 00 00 00       	mov    $0x0,%ecx
  801699:	8d 40 04             	lea    0x4(%eax),%eax
  80169c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80169f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8016a4:	e9 5f ff ff ff       	jmp    801608 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8016a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8016ac:	8b 10                	mov    (%eax),%edx
  8016ae:	8b 48 04             	mov    0x4(%eax),%ecx
  8016b1:	8d 40 08             	lea    0x8(%eax),%eax
  8016b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016b7:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8016bc:	e9 47 ff ff ff       	jmp    801608 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8016c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c4:	8b 10                	mov    (%eax),%edx
  8016c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016cb:	8d 40 04             	lea    0x4(%eax),%eax
  8016ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016d1:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8016d6:	e9 2d ff ff ff       	jmp    801608 <vprintfmt+0x348>
			putch(ch, putdat);
  8016db:	83 ec 08             	sub    $0x8,%esp
  8016de:	53                   	push   %ebx
  8016df:	6a 25                	push   $0x25
  8016e1:	ff d6                	call   *%esi
			break;
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	e9 37 ff ff ff       	jmp    801622 <vprintfmt+0x362>
			putch('%', putdat);
  8016eb:	83 ec 08             	sub    $0x8,%esp
  8016ee:	53                   	push   %ebx
  8016ef:	6a 25                	push   $0x25
  8016f1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	89 f8                	mov    %edi,%eax
  8016f8:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8016fc:	74 05                	je     801703 <vprintfmt+0x443>
  8016fe:	83 e8 01             	sub    $0x1,%eax
  801701:	eb f5                	jmp    8016f8 <vprintfmt+0x438>
  801703:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801706:	e9 17 ff ff ff       	jmp    801622 <vprintfmt+0x362>
}
  80170b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80170e:	5b                   	pop    %ebx
  80170f:	5e                   	pop    %esi
  801710:	5f                   	pop    %edi
  801711:	5d                   	pop    %ebp
  801712:	c3                   	ret    

00801713 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801713:	f3 0f 1e fb          	endbr32 
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	83 ec 18             	sub    $0x18,%esp
  80171d:	8b 45 08             	mov    0x8(%ebp),%eax
  801720:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801723:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801726:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80172a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80172d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801734:	85 c0                	test   %eax,%eax
  801736:	74 26                	je     80175e <vsnprintf+0x4b>
  801738:	85 d2                	test   %edx,%edx
  80173a:	7e 22                	jle    80175e <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80173c:	ff 75 14             	pushl  0x14(%ebp)
  80173f:	ff 75 10             	pushl  0x10(%ebp)
  801742:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801745:	50                   	push   %eax
  801746:	68 7e 12 80 00       	push   $0x80127e
  80174b:	e8 70 fb ff ff       	call   8012c0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801750:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801753:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801756:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801759:	83 c4 10             	add    $0x10,%esp
}
  80175c:	c9                   	leave  
  80175d:	c3                   	ret    
		return -E_INVAL;
  80175e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801763:	eb f7                	jmp    80175c <vsnprintf+0x49>

00801765 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801765:	f3 0f 1e fb          	endbr32 
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80176f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801772:	50                   	push   %eax
  801773:	ff 75 10             	pushl  0x10(%ebp)
  801776:	ff 75 0c             	pushl  0xc(%ebp)
  801779:	ff 75 08             	pushl  0x8(%ebp)
  80177c:	e8 92 ff ff ff       	call   801713 <vsnprintf>
	va_end(ap);

	return rc;
}
  801781:	c9                   	leave  
  801782:	c3                   	ret    

00801783 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801783:	f3 0f 1e fb          	endbr32 
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80178d:	b8 00 00 00 00       	mov    $0x0,%eax
  801792:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801796:	74 05                	je     80179d <strlen+0x1a>
		n++;
  801798:	83 c0 01             	add    $0x1,%eax
  80179b:	eb f5                	jmp    801792 <strlen+0xf>
	return n;
}
  80179d:	5d                   	pop    %ebp
  80179e:	c3                   	ret    

0080179f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80179f:	f3 0f 1e fb          	endbr32 
  8017a3:	55                   	push   %ebp
  8017a4:	89 e5                	mov    %esp,%ebp
  8017a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017a9:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8017ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b1:	39 d0                	cmp    %edx,%eax
  8017b3:	74 0d                	je     8017c2 <strnlen+0x23>
  8017b5:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8017b9:	74 05                	je     8017c0 <strnlen+0x21>
		n++;
  8017bb:	83 c0 01             	add    $0x1,%eax
  8017be:	eb f1                	jmp    8017b1 <strnlen+0x12>
  8017c0:	89 c2                	mov    %eax,%edx
	return n;
}
  8017c2:	89 d0                	mov    %edx,%eax
  8017c4:	5d                   	pop    %ebp
  8017c5:	c3                   	ret    

008017c6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8017c6:	f3 0f 1e fb          	endbr32 
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	53                   	push   %ebx
  8017ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8017d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d9:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8017dd:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8017e0:	83 c0 01             	add    $0x1,%eax
  8017e3:	84 d2                	test   %dl,%dl
  8017e5:	75 f2                	jne    8017d9 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8017e7:	89 c8                	mov    %ecx,%eax
  8017e9:	5b                   	pop    %ebx
  8017ea:	5d                   	pop    %ebp
  8017eb:	c3                   	ret    

008017ec <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017ec:	f3 0f 1e fb          	endbr32 
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	53                   	push   %ebx
  8017f4:	83 ec 10             	sub    $0x10,%esp
  8017f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8017fa:	53                   	push   %ebx
  8017fb:	e8 83 ff ff ff       	call   801783 <strlen>
  801800:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801803:	ff 75 0c             	pushl  0xc(%ebp)
  801806:	01 d8                	add    %ebx,%eax
  801808:	50                   	push   %eax
  801809:	e8 b8 ff ff ff       	call   8017c6 <strcpy>
	return dst;
}
  80180e:	89 d8                	mov    %ebx,%eax
  801810:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801813:	c9                   	leave  
  801814:	c3                   	ret    

00801815 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801815:	f3 0f 1e fb          	endbr32 
  801819:	55                   	push   %ebp
  80181a:	89 e5                	mov    %esp,%ebp
  80181c:	56                   	push   %esi
  80181d:	53                   	push   %ebx
  80181e:	8b 75 08             	mov    0x8(%ebp),%esi
  801821:	8b 55 0c             	mov    0xc(%ebp),%edx
  801824:	89 f3                	mov    %esi,%ebx
  801826:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801829:	89 f0                	mov    %esi,%eax
  80182b:	39 d8                	cmp    %ebx,%eax
  80182d:	74 11                	je     801840 <strncpy+0x2b>
		*dst++ = *src;
  80182f:	83 c0 01             	add    $0x1,%eax
  801832:	0f b6 0a             	movzbl (%edx),%ecx
  801835:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801838:	80 f9 01             	cmp    $0x1,%cl
  80183b:	83 da ff             	sbb    $0xffffffff,%edx
  80183e:	eb eb                	jmp    80182b <strncpy+0x16>
	}
	return ret;
}
  801840:	89 f0                	mov    %esi,%eax
  801842:	5b                   	pop    %ebx
  801843:	5e                   	pop    %esi
  801844:	5d                   	pop    %ebp
  801845:	c3                   	ret    

00801846 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801846:	f3 0f 1e fb          	endbr32 
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	56                   	push   %esi
  80184e:	53                   	push   %ebx
  80184f:	8b 75 08             	mov    0x8(%ebp),%esi
  801852:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801855:	8b 55 10             	mov    0x10(%ebp),%edx
  801858:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80185a:	85 d2                	test   %edx,%edx
  80185c:	74 21                	je     80187f <strlcpy+0x39>
  80185e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801862:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801864:	39 c2                	cmp    %eax,%edx
  801866:	74 14                	je     80187c <strlcpy+0x36>
  801868:	0f b6 19             	movzbl (%ecx),%ebx
  80186b:	84 db                	test   %bl,%bl
  80186d:	74 0b                	je     80187a <strlcpy+0x34>
			*dst++ = *src++;
  80186f:	83 c1 01             	add    $0x1,%ecx
  801872:	83 c2 01             	add    $0x1,%edx
  801875:	88 5a ff             	mov    %bl,-0x1(%edx)
  801878:	eb ea                	jmp    801864 <strlcpy+0x1e>
  80187a:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80187c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80187f:	29 f0                	sub    %esi,%eax
}
  801881:	5b                   	pop    %ebx
  801882:	5e                   	pop    %esi
  801883:	5d                   	pop    %ebp
  801884:	c3                   	ret    

00801885 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801885:	f3 0f 1e fb          	endbr32 
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
  80188c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80188f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801892:	0f b6 01             	movzbl (%ecx),%eax
  801895:	84 c0                	test   %al,%al
  801897:	74 0c                	je     8018a5 <strcmp+0x20>
  801899:	3a 02                	cmp    (%edx),%al
  80189b:	75 08                	jne    8018a5 <strcmp+0x20>
		p++, q++;
  80189d:	83 c1 01             	add    $0x1,%ecx
  8018a0:	83 c2 01             	add    $0x1,%edx
  8018a3:	eb ed                	jmp    801892 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8018a5:	0f b6 c0             	movzbl %al,%eax
  8018a8:	0f b6 12             	movzbl (%edx),%edx
  8018ab:	29 d0                	sub    %edx,%eax
}
  8018ad:	5d                   	pop    %ebp
  8018ae:	c3                   	ret    

008018af <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8018af:	f3 0f 1e fb          	endbr32 
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	53                   	push   %ebx
  8018b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018bd:	89 c3                	mov    %eax,%ebx
  8018bf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8018c2:	eb 06                	jmp    8018ca <strncmp+0x1b>
		n--, p++, q++;
  8018c4:	83 c0 01             	add    $0x1,%eax
  8018c7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8018ca:	39 d8                	cmp    %ebx,%eax
  8018cc:	74 16                	je     8018e4 <strncmp+0x35>
  8018ce:	0f b6 08             	movzbl (%eax),%ecx
  8018d1:	84 c9                	test   %cl,%cl
  8018d3:	74 04                	je     8018d9 <strncmp+0x2a>
  8018d5:	3a 0a                	cmp    (%edx),%cl
  8018d7:	74 eb                	je     8018c4 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8018d9:	0f b6 00             	movzbl (%eax),%eax
  8018dc:	0f b6 12             	movzbl (%edx),%edx
  8018df:	29 d0                	sub    %edx,%eax
}
  8018e1:	5b                   	pop    %ebx
  8018e2:	5d                   	pop    %ebp
  8018e3:	c3                   	ret    
		return 0;
  8018e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e9:	eb f6                	jmp    8018e1 <strncmp+0x32>

008018eb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8018eb:	f3 0f 1e fb          	endbr32 
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018f9:	0f b6 10             	movzbl (%eax),%edx
  8018fc:	84 d2                	test   %dl,%dl
  8018fe:	74 09                	je     801909 <strchr+0x1e>
		if (*s == c)
  801900:	38 ca                	cmp    %cl,%dl
  801902:	74 0a                	je     80190e <strchr+0x23>
	for (; *s; s++)
  801904:	83 c0 01             	add    $0x1,%eax
  801907:	eb f0                	jmp    8018f9 <strchr+0xe>
			return (char *) s;
	return 0;
  801909:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80190e:	5d                   	pop    %ebp
  80190f:	c3                   	ret    

00801910 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801910:	f3 0f 1e fb          	endbr32 
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	8b 45 08             	mov    0x8(%ebp),%eax
  80191a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80191e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801921:	38 ca                	cmp    %cl,%dl
  801923:	74 09                	je     80192e <strfind+0x1e>
  801925:	84 d2                	test   %dl,%dl
  801927:	74 05                	je     80192e <strfind+0x1e>
	for (; *s; s++)
  801929:	83 c0 01             	add    $0x1,%eax
  80192c:	eb f0                	jmp    80191e <strfind+0xe>
			break;
	return (char *) s;
}
  80192e:	5d                   	pop    %ebp
  80192f:	c3                   	ret    

00801930 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801930:	f3 0f 1e fb          	endbr32 
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	57                   	push   %edi
  801938:	56                   	push   %esi
  801939:	53                   	push   %ebx
  80193a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80193d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801940:	85 c9                	test   %ecx,%ecx
  801942:	74 31                	je     801975 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801944:	89 f8                	mov    %edi,%eax
  801946:	09 c8                	or     %ecx,%eax
  801948:	a8 03                	test   $0x3,%al
  80194a:	75 23                	jne    80196f <memset+0x3f>
		c &= 0xFF;
  80194c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801950:	89 d3                	mov    %edx,%ebx
  801952:	c1 e3 08             	shl    $0x8,%ebx
  801955:	89 d0                	mov    %edx,%eax
  801957:	c1 e0 18             	shl    $0x18,%eax
  80195a:	89 d6                	mov    %edx,%esi
  80195c:	c1 e6 10             	shl    $0x10,%esi
  80195f:	09 f0                	or     %esi,%eax
  801961:	09 c2                	or     %eax,%edx
  801963:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801965:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801968:	89 d0                	mov    %edx,%eax
  80196a:	fc                   	cld    
  80196b:	f3 ab                	rep stos %eax,%es:(%edi)
  80196d:	eb 06                	jmp    801975 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80196f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801972:	fc                   	cld    
  801973:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801975:	89 f8                	mov    %edi,%eax
  801977:	5b                   	pop    %ebx
  801978:	5e                   	pop    %esi
  801979:	5f                   	pop    %edi
  80197a:	5d                   	pop    %ebp
  80197b:	c3                   	ret    

0080197c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80197c:	f3 0f 1e fb          	endbr32 
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	57                   	push   %edi
  801984:	56                   	push   %esi
  801985:	8b 45 08             	mov    0x8(%ebp),%eax
  801988:	8b 75 0c             	mov    0xc(%ebp),%esi
  80198b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80198e:	39 c6                	cmp    %eax,%esi
  801990:	73 32                	jae    8019c4 <memmove+0x48>
  801992:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801995:	39 c2                	cmp    %eax,%edx
  801997:	76 2b                	jbe    8019c4 <memmove+0x48>
		s += n;
		d += n;
  801999:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80199c:	89 fe                	mov    %edi,%esi
  80199e:	09 ce                	or     %ecx,%esi
  8019a0:	09 d6                	or     %edx,%esi
  8019a2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8019a8:	75 0e                	jne    8019b8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8019aa:	83 ef 04             	sub    $0x4,%edi
  8019ad:	8d 72 fc             	lea    -0x4(%edx),%esi
  8019b0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8019b3:	fd                   	std    
  8019b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019b6:	eb 09                	jmp    8019c1 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8019b8:	83 ef 01             	sub    $0x1,%edi
  8019bb:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8019be:	fd                   	std    
  8019bf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8019c1:	fc                   	cld    
  8019c2:	eb 1a                	jmp    8019de <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019c4:	89 c2                	mov    %eax,%edx
  8019c6:	09 ca                	or     %ecx,%edx
  8019c8:	09 f2                	or     %esi,%edx
  8019ca:	f6 c2 03             	test   $0x3,%dl
  8019cd:	75 0a                	jne    8019d9 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8019cf:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8019d2:	89 c7                	mov    %eax,%edi
  8019d4:	fc                   	cld    
  8019d5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019d7:	eb 05                	jmp    8019de <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8019d9:	89 c7                	mov    %eax,%edi
  8019db:	fc                   	cld    
  8019dc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8019de:	5e                   	pop    %esi
  8019df:	5f                   	pop    %edi
  8019e0:	5d                   	pop    %ebp
  8019e1:	c3                   	ret    

008019e2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8019e2:	f3 0f 1e fb          	endbr32 
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8019ec:	ff 75 10             	pushl  0x10(%ebp)
  8019ef:	ff 75 0c             	pushl  0xc(%ebp)
  8019f2:	ff 75 08             	pushl  0x8(%ebp)
  8019f5:	e8 82 ff ff ff       	call   80197c <memmove>
}
  8019fa:	c9                   	leave  
  8019fb:	c3                   	ret    

008019fc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8019fc:	f3 0f 1e fb          	endbr32 
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	56                   	push   %esi
  801a04:	53                   	push   %ebx
  801a05:	8b 45 08             	mov    0x8(%ebp),%eax
  801a08:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a0b:	89 c6                	mov    %eax,%esi
  801a0d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a10:	39 f0                	cmp    %esi,%eax
  801a12:	74 1c                	je     801a30 <memcmp+0x34>
		if (*s1 != *s2)
  801a14:	0f b6 08             	movzbl (%eax),%ecx
  801a17:	0f b6 1a             	movzbl (%edx),%ebx
  801a1a:	38 d9                	cmp    %bl,%cl
  801a1c:	75 08                	jne    801a26 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801a1e:	83 c0 01             	add    $0x1,%eax
  801a21:	83 c2 01             	add    $0x1,%edx
  801a24:	eb ea                	jmp    801a10 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801a26:	0f b6 c1             	movzbl %cl,%eax
  801a29:	0f b6 db             	movzbl %bl,%ebx
  801a2c:	29 d8                	sub    %ebx,%eax
  801a2e:	eb 05                	jmp    801a35 <memcmp+0x39>
	}

	return 0;
  801a30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a35:	5b                   	pop    %ebx
  801a36:	5e                   	pop    %esi
  801a37:	5d                   	pop    %ebp
  801a38:	c3                   	ret    

00801a39 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a39:	f3 0f 1e fb          	endbr32 
  801a3d:	55                   	push   %ebp
  801a3e:	89 e5                	mov    %esp,%ebp
  801a40:	8b 45 08             	mov    0x8(%ebp),%eax
  801a43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a46:	89 c2                	mov    %eax,%edx
  801a48:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a4b:	39 d0                	cmp    %edx,%eax
  801a4d:	73 09                	jae    801a58 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a4f:	38 08                	cmp    %cl,(%eax)
  801a51:	74 05                	je     801a58 <memfind+0x1f>
	for (; s < ends; s++)
  801a53:	83 c0 01             	add    $0x1,%eax
  801a56:	eb f3                	jmp    801a4b <memfind+0x12>
			break;
	return (void *) s;
}
  801a58:	5d                   	pop    %ebp
  801a59:	c3                   	ret    

00801a5a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a5a:	f3 0f 1e fb          	endbr32 
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	57                   	push   %edi
  801a62:	56                   	push   %esi
  801a63:	53                   	push   %ebx
  801a64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a6a:	eb 03                	jmp    801a6f <strtol+0x15>
		s++;
  801a6c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801a6f:	0f b6 01             	movzbl (%ecx),%eax
  801a72:	3c 20                	cmp    $0x20,%al
  801a74:	74 f6                	je     801a6c <strtol+0x12>
  801a76:	3c 09                	cmp    $0x9,%al
  801a78:	74 f2                	je     801a6c <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801a7a:	3c 2b                	cmp    $0x2b,%al
  801a7c:	74 2a                	je     801aa8 <strtol+0x4e>
	int neg = 0;
  801a7e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801a83:	3c 2d                	cmp    $0x2d,%al
  801a85:	74 2b                	je     801ab2 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a87:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a8d:	75 0f                	jne    801a9e <strtol+0x44>
  801a8f:	80 39 30             	cmpb   $0x30,(%ecx)
  801a92:	74 28                	je     801abc <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a94:	85 db                	test   %ebx,%ebx
  801a96:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a9b:	0f 44 d8             	cmove  %eax,%ebx
  801a9e:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801aa6:	eb 46                	jmp    801aee <strtol+0x94>
		s++;
  801aa8:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801aab:	bf 00 00 00 00       	mov    $0x0,%edi
  801ab0:	eb d5                	jmp    801a87 <strtol+0x2d>
		s++, neg = 1;
  801ab2:	83 c1 01             	add    $0x1,%ecx
  801ab5:	bf 01 00 00 00       	mov    $0x1,%edi
  801aba:	eb cb                	jmp    801a87 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801abc:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ac0:	74 0e                	je     801ad0 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801ac2:	85 db                	test   %ebx,%ebx
  801ac4:	75 d8                	jne    801a9e <strtol+0x44>
		s++, base = 8;
  801ac6:	83 c1 01             	add    $0x1,%ecx
  801ac9:	bb 08 00 00 00       	mov    $0x8,%ebx
  801ace:	eb ce                	jmp    801a9e <strtol+0x44>
		s += 2, base = 16;
  801ad0:	83 c1 02             	add    $0x2,%ecx
  801ad3:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ad8:	eb c4                	jmp    801a9e <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801ada:	0f be d2             	movsbl %dl,%edx
  801add:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801ae0:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ae3:	7d 3a                	jge    801b1f <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801ae5:	83 c1 01             	add    $0x1,%ecx
  801ae8:	0f af 45 10          	imul   0x10(%ebp),%eax
  801aec:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801aee:	0f b6 11             	movzbl (%ecx),%edx
  801af1:	8d 72 d0             	lea    -0x30(%edx),%esi
  801af4:	89 f3                	mov    %esi,%ebx
  801af6:	80 fb 09             	cmp    $0x9,%bl
  801af9:	76 df                	jbe    801ada <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801afb:	8d 72 9f             	lea    -0x61(%edx),%esi
  801afe:	89 f3                	mov    %esi,%ebx
  801b00:	80 fb 19             	cmp    $0x19,%bl
  801b03:	77 08                	ja     801b0d <strtol+0xb3>
			dig = *s - 'a' + 10;
  801b05:	0f be d2             	movsbl %dl,%edx
  801b08:	83 ea 57             	sub    $0x57,%edx
  801b0b:	eb d3                	jmp    801ae0 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801b0d:	8d 72 bf             	lea    -0x41(%edx),%esi
  801b10:	89 f3                	mov    %esi,%ebx
  801b12:	80 fb 19             	cmp    $0x19,%bl
  801b15:	77 08                	ja     801b1f <strtol+0xc5>
			dig = *s - 'A' + 10;
  801b17:	0f be d2             	movsbl %dl,%edx
  801b1a:	83 ea 37             	sub    $0x37,%edx
  801b1d:	eb c1                	jmp    801ae0 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801b1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b23:	74 05                	je     801b2a <strtol+0xd0>
		*endptr = (char *) s;
  801b25:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b28:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801b2a:	89 c2                	mov    %eax,%edx
  801b2c:	f7 da                	neg    %edx
  801b2e:	85 ff                	test   %edi,%edi
  801b30:	0f 45 c2             	cmovne %edx,%eax
}
  801b33:	5b                   	pop    %ebx
  801b34:	5e                   	pop    %esi
  801b35:	5f                   	pop    %edi
  801b36:	5d                   	pop    %ebp
  801b37:	c3                   	ret    

00801b38 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b38:	f3 0f 1e fb          	endbr32 
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	56                   	push   %esi
  801b40:	53                   	push   %ebx
  801b41:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b47:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801b4a:	85 c0                	test   %eax,%eax
  801b4c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b51:	0f 44 c2             	cmove  %edx,%eax
  801b54:	83 ec 0c             	sub    $0xc,%esp
  801b57:	50                   	push   %eax
  801b58:	e8 ef e7 ff ff       	call   80034c <sys_ipc_recv>
  801b5d:	83 c4 10             	add    $0x10,%esp
  801b60:	85 c0                	test   %eax,%eax
  801b62:	78 24                	js     801b88 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801b64:	85 f6                	test   %esi,%esi
  801b66:	74 0a                	je     801b72 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801b68:	a1 04 40 80 00       	mov    0x804004,%eax
  801b6d:	8b 40 78             	mov    0x78(%eax),%eax
  801b70:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801b72:	85 db                	test   %ebx,%ebx
  801b74:	74 0a                	je     801b80 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801b76:	a1 04 40 80 00       	mov    0x804004,%eax
  801b7b:	8b 40 74             	mov    0x74(%eax),%eax
  801b7e:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801b80:	a1 04 40 80 00       	mov    0x804004,%eax
  801b85:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b8b:	5b                   	pop    %ebx
  801b8c:	5e                   	pop    %esi
  801b8d:	5d                   	pop    %ebp
  801b8e:	c3                   	ret    

00801b8f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b8f:	f3 0f 1e fb          	endbr32 
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	57                   	push   %edi
  801b97:	56                   	push   %esi
  801b98:	53                   	push   %ebx
  801b99:	83 ec 1c             	sub    $0x1c,%esp
  801b9c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b9f:	85 c0                	test   %eax,%eax
  801ba1:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801ba6:	0f 45 d0             	cmovne %eax,%edx
  801ba9:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801bab:	be 01 00 00 00       	mov    $0x1,%esi
  801bb0:	eb 1f                	jmp    801bd1 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801bb2:	e8 a6 e5 ff ff       	call   80015d <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801bb7:	83 c3 01             	add    $0x1,%ebx
  801bba:	39 de                	cmp    %ebx,%esi
  801bbc:	7f f4                	jg     801bb2 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801bbe:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801bc0:	83 fe 11             	cmp    $0x11,%esi
  801bc3:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc8:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801bcb:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801bcf:	75 1c                	jne    801bed <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801bd1:	ff 75 14             	pushl  0x14(%ebp)
  801bd4:	57                   	push   %edi
  801bd5:	ff 75 0c             	pushl  0xc(%ebp)
  801bd8:	ff 75 08             	pushl  0x8(%ebp)
  801bdb:	e8 45 e7 ff ff       	call   800325 <sys_ipc_try_send>
  801be0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801be3:	83 c4 10             	add    $0x10,%esp
  801be6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801beb:	eb cd                	jmp    801bba <ipc_send+0x2b>
}
  801bed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf0:	5b                   	pop    %ebx
  801bf1:	5e                   	pop    %esi
  801bf2:	5f                   	pop    %edi
  801bf3:	5d                   	pop    %ebp
  801bf4:	c3                   	ret    

00801bf5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bf5:	f3 0f 1e fb          	endbr32 
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
  801bfc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bff:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c04:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c07:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c0d:	8b 52 50             	mov    0x50(%edx),%edx
  801c10:	39 ca                	cmp    %ecx,%edx
  801c12:	74 11                	je     801c25 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801c14:	83 c0 01             	add    $0x1,%eax
  801c17:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c1c:	75 e6                	jne    801c04 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801c1e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c23:	eb 0b                	jmp    801c30 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c25:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c28:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c2d:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    

00801c32 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c32:	f3 0f 1e fb          	endbr32 
  801c36:	55                   	push   %ebp
  801c37:	89 e5                	mov    %esp,%ebp
  801c39:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c3c:	89 c2                	mov    %eax,%edx
  801c3e:	c1 ea 16             	shr    $0x16,%edx
  801c41:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c48:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c4d:	f6 c1 01             	test   $0x1,%cl
  801c50:	74 1c                	je     801c6e <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c52:	c1 e8 0c             	shr    $0xc,%eax
  801c55:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c5c:	a8 01                	test   $0x1,%al
  801c5e:	74 0e                	je     801c6e <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c60:	c1 e8 0c             	shr    $0xc,%eax
  801c63:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c6a:	ef 
  801c6b:	0f b7 d2             	movzwl %dx,%edx
}
  801c6e:	89 d0                	mov    %edx,%eax
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    
  801c72:	66 90                	xchg   %ax,%ax
  801c74:	66 90                	xchg   %ax,%ax
  801c76:	66 90                	xchg   %ax,%ax
  801c78:	66 90                	xchg   %ax,%ax
  801c7a:	66 90                	xchg   %ax,%ax
  801c7c:	66 90                	xchg   %ax,%ax
  801c7e:	66 90                	xchg   %ax,%ax

00801c80 <__udivdi3>:
  801c80:	f3 0f 1e fb          	endbr32 
  801c84:	55                   	push   %ebp
  801c85:	57                   	push   %edi
  801c86:	56                   	push   %esi
  801c87:	53                   	push   %ebx
  801c88:	83 ec 1c             	sub    $0x1c,%esp
  801c8b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c8f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c93:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c97:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c9b:	85 d2                	test   %edx,%edx
  801c9d:	75 19                	jne    801cb8 <__udivdi3+0x38>
  801c9f:	39 f3                	cmp    %esi,%ebx
  801ca1:	76 4d                	jbe    801cf0 <__udivdi3+0x70>
  801ca3:	31 ff                	xor    %edi,%edi
  801ca5:	89 e8                	mov    %ebp,%eax
  801ca7:	89 f2                	mov    %esi,%edx
  801ca9:	f7 f3                	div    %ebx
  801cab:	89 fa                	mov    %edi,%edx
  801cad:	83 c4 1c             	add    $0x1c,%esp
  801cb0:	5b                   	pop    %ebx
  801cb1:	5e                   	pop    %esi
  801cb2:	5f                   	pop    %edi
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    
  801cb5:	8d 76 00             	lea    0x0(%esi),%esi
  801cb8:	39 f2                	cmp    %esi,%edx
  801cba:	76 14                	jbe    801cd0 <__udivdi3+0x50>
  801cbc:	31 ff                	xor    %edi,%edi
  801cbe:	31 c0                	xor    %eax,%eax
  801cc0:	89 fa                	mov    %edi,%edx
  801cc2:	83 c4 1c             	add    $0x1c,%esp
  801cc5:	5b                   	pop    %ebx
  801cc6:	5e                   	pop    %esi
  801cc7:	5f                   	pop    %edi
  801cc8:	5d                   	pop    %ebp
  801cc9:	c3                   	ret    
  801cca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cd0:	0f bd fa             	bsr    %edx,%edi
  801cd3:	83 f7 1f             	xor    $0x1f,%edi
  801cd6:	75 48                	jne    801d20 <__udivdi3+0xa0>
  801cd8:	39 f2                	cmp    %esi,%edx
  801cda:	72 06                	jb     801ce2 <__udivdi3+0x62>
  801cdc:	31 c0                	xor    %eax,%eax
  801cde:	39 eb                	cmp    %ebp,%ebx
  801ce0:	77 de                	ja     801cc0 <__udivdi3+0x40>
  801ce2:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce7:	eb d7                	jmp    801cc0 <__udivdi3+0x40>
  801ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	89 d9                	mov    %ebx,%ecx
  801cf2:	85 db                	test   %ebx,%ebx
  801cf4:	75 0b                	jne    801d01 <__udivdi3+0x81>
  801cf6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cfb:	31 d2                	xor    %edx,%edx
  801cfd:	f7 f3                	div    %ebx
  801cff:	89 c1                	mov    %eax,%ecx
  801d01:	31 d2                	xor    %edx,%edx
  801d03:	89 f0                	mov    %esi,%eax
  801d05:	f7 f1                	div    %ecx
  801d07:	89 c6                	mov    %eax,%esi
  801d09:	89 e8                	mov    %ebp,%eax
  801d0b:	89 f7                	mov    %esi,%edi
  801d0d:	f7 f1                	div    %ecx
  801d0f:	89 fa                	mov    %edi,%edx
  801d11:	83 c4 1c             	add    $0x1c,%esp
  801d14:	5b                   	pop    %ebx
  801d15:	5e                   	pop    %esi
  801d16:	5f                   	pop    %edi
  801d17:	5d                   	pop    %ebp
  801d18:	c3                   	ret    
  801d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d20:	89 f9                	mov    %edi,%ecx
  801d22:	b8 20 00 00 00       	mov    $0x20,%eax
  801d27:	29 f8                	sub    %edi,%eax
  801d29:	d3 e2                	shl    %cl,%edx
  801d2b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d2f:	89 c1                	mov    %eax,%ecx
  801d31:	89 da                	mov    %ebx,%edx
  801d33:	d3 ea                	shr    %cl,%edx
  801d35:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d39:	09 d1                	or     %edx,%ecx
  801d3b:	89 f2                	mov    %esi,%edx
  801d3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d41:	89 f9                	mov    %edi,%ecx
  801d43:	d3 e3                	shl    %cl,%ebx
  801d45:	89 c1                	mov    %eax,%ecx
  801d47:	d3 ea                	shr    %cl,%edx
  801d49:	89 f9                	mov    %edi,%ecx
  801d4b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d4f:	89 eb                	mov    %ebp,%ebx
  801d51:	d3 e6                	shl    %cl,%esi
  801d53:	89 c1                	mov    %eax,%ecx
  801d55:	d3 eb                	shr    %cl,%ebx
  801d57:	09 de                	or     %ebx,%esi
  801d59:	89 f0                	mov    %esi,%eax
  801d5b:	f7 74 24 08          	divl   0x8(%esp)
  801d5f:	89 d6                	mov    %edx,%esi
  801d61:	89 c3                	mov    %eax,%ebx
  801d63:	f7 64 24 0c          	mull   0xc(%esp)
  801d67:	39 d6                	cmp    %edx,%esi
  801d69:	72 15                	jb     801d80 <__udivdi3+0x100>
  801d6b:	89 f9                	mov    %edi,%ecx
  801d6d:	d3 e5                	shl    %cl,%ebp
  801d6f:	39 c5                	cmp    %eax,%ebp
  801d71:	73 04                	jae    801d77 <__udivdi3+0xf7>
  801d73:	39 d6                	cmp    %edx,%esi
  801d75:	74 09                	je     801d80 <__udivdi3+0x100>
  801d77:	89 d8                	mov    %ebx,%eax
  801d79:	31 ff                	xor    %edi,%edi
  801d7b:	e9 40 ff ff ff       	jmp    801cc0 <__udivdi3+0x40>
  801d80:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d83:	31 ff                	xor    %edi,%edi
  801d85:	e9 36 ff ff ff       	jmp    801cc0 <__udivdi3+0x40>
  801d8a:	66 90                	xchg   %ax,%ax
  801d8c:	66 90                	xchg   %ax,%ax
  801d8e:	66 90                	xchg   %ax,%ax

00801d90 <__umoddi3>:
  801d90:	f3 0f 1e fb          	endbr32 
  801d94:	55                   	push   %ebp
  801d95:	57                   	push   %edi
  801d96:	56                   	push   %esi
  801d97:	53                   	push   %ebx
  801d98:	83 ec 1c             	sub    $0x1c,%esp
  801d9b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d9f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801da3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801da7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dab:	85 c0                	test   %eax,%eax
  801dad:	75 19                	jne    801dc8 <__umoddi3+0x38>
  801daf:	39 df                	cmp    %ebx,%edi
  801db1:	76 5d                	jbe    801e10 <__umoddi3+0x80>
  801db3:	89 f0                	mov    %esi,%eax
  801db5:	89 da                	mov    %ebx,%edx
  801db7:	f7 f7                	div    %edi
  801db9:	89 d0                	mov    %edx,%eax
  801dbb:	31 d2                	xor    %edx,%edx
  801dbd:	83 c4 1c             	add    $0x1c,%esp
  801dc0:	5b                   	pop    %ebx
  801dc1:	5e                   	pop    %esi
  801dc2:	5f                   	pop    %edi
  801dc3:	5d                   	pop    %ebp
  801dc4:	c3                   	ret    
  801dc5:	8d 76 00             	lea    0x0(%esi),%esi
  801dc8:	89 f2                	mov    %esi,%edx
  801dca:	39 d8                	cmp    %ebx,%eax
  801dcc:	76 12                	jbe    801de0 <__umoddi3+0x50>
  801dce:	89 f0                	mov    %esi,%eax
  801dd0:	89 da                	mov    %ebx,%edx
  801dd2:	83 c4 1c             	add    $0x1c,%esp
  801dd5:	5b                   	pop    %ebx
  801dd6:	5e                   	pop    %esi
  801dd7:	5f                   	pop    %edi
  801dd8:	5d                   	pop    %ebp
  801dd9:	c3                   	ret    
  801dda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801de0:	0f bd e8             	bsr    %eax,%ebp
  801de3:	83 f5 1f             	xor    $0x1f,%ebp
  801de6:	75 50                	jne    801e38 <__umoddi3+0xa8>
  801de8:	39 d8                	cmp    %ebx,%eax
  801dea:	0f 82 e0 00 00 00    	jb     801ed0 <__umoddi3+0x140>
  801df0:	89 d9                	mov    %ebx,%ecx
  801df2:	39 f7                	cmp    %esi,%edi
  801df4:	0f 86 d6 00 00 00    	jbe    801ed0 <__umoddi3+0x140>
  801dfa:	89 d0                	mov    %edx,%eax
  801dfc:	89 ca                	mov    %ecx,%edx
  801dfe:	83 c4 1c             	add    $0x1c,%esp
  801e01:	5b                   	pop    %ebx
  801e02:	5e                   	pop    %esi
  801e03:	5f                   	pop    %edi
  801e04:	5d                   	pop    %ebp
  801e05:	c3                   	ret    
  801e06:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e0d:	8d 76 00             	lea    0x0(%esi),%esi
  801e10:	89 fd                	mov    %edi,%ebp
  801e12:	85 ff                	test   %edi,%edi
  801e14:	75 0b                	jne    801e21 <__umoddi3+0x91>
  801e16:	b8 01 00 00 00       	mov    $0x1,%eax
  801e1b:	31 d2                	xor    %edx,%edx
  801e1d:	f7 f7                	div    %edi
  801e1f:	89 c5                	mov    %eax,%ebp
  801e21:	89 d8                	mov    %ebx,%eax
  801e23:	31 d2                	xor    %edx,%edx
  801e25:	f7 f5                	div    %ebp
  801e27:	89 f0                	mov    %esi,%eax
  801e29:	f7 f5                	div    %ebp
  801e2b:	89 d0                	mov    %edx,%eax
  801e2d:	31 d2                	xor    %edx,%edx
  801e2f:	eb 8c                	jmp    801dbd <__umoddi3+0x2d>
  801e31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e38:	89 e9                	mov    %ebp,%ecx
  801e3a:	ba 20 00 00 00       	mov    $0x20,%edx
  801e3f:	29 ea                	sub    %ebp,%edx
  801e41:	d3 e0                	shl    %cl,%eax
  801e43:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e47:	89 d1                	mov    %edx,%ecx
  801e49:	89 f8                	mov    %edi,%eax
  801e4b:	d3 e8                	shr    %cl,%eax
  801e4d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e51:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e55:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e59:	09 c1                	or     %eax,%ecx
  801e5b:	89 d8                	mov    %ebx,%eax
  801e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e61:	89 e9                	mov    %ebp,%ecx
  801e63:	d3 e7                	shl    %cl,%edi
  801e65:	89 d1                	mov    %edx,%ecx
  801e67:	d3 e8                	shr    %cl,%eax
  801e69:	89 e9                	mov    %ebp,%ecx
  801e6b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e6f:	d3 e3                	shl    %cl,%ebx
  801e71:	89 c7                	mov    %eax,%edi
  801e73:	89 d1                	mov    %edx,%ecx
  801e75:	89 f0                	mov    %esi,%eax
  801e77:	d3 e8                	shr    %cl,%eax
  801e79:	89 e9                	mov    %ebp,%ecx
  801e7b:	89 fa                	mov    %edi,%edx
  801e7d:	d3 e6                	shl    %cl,%esi
  801e7f:	09 d8                	or     %ebx,%eax
  801e81:	f7 74 24 08          	divl   0x8(%esp)
  801e85:	89 d1                	mov    %edx,%ecx
  801e87:	89 f3                	mov    %esi,%ebx
  801e89:	f7 64 24 0c          	mull   0xc(%esp)
  801e8d:	89 c6                	mov    %eax,%esi
  801e8f:	89 d7                	mov    %edx,%edi
  801e91:	39 d1                	cmp    %edx,%ecx
  801e93:	72 06                	jb     801e9b <__umoddi3+0x10b>
  801e95:	75 10                	jne    801ea7 <__umoddi3+0x117>
  801e97:	39 c3                	cmp    %eax,%ebx
  801e99:	73 0c                	jae    801ea7 <__umoddi3+0x117>
  801e9b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801e9f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801ea3:	89 d7                	mov    %edx,%edi
  801ea5:	89 c6                	mov    %eax,%esi
  801ea7:	89 ca                	mov    %ecx,%edx
  801ea9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801eae:	29 f3                	sub    %esi,%ebx
  801eb0:	19 fa                	sbb    %edi,%edx
  801eb2:	89 d0                	mov    %edx,%eax
  801eb4:	d3 e0                	shl    %cl,%eax
  801eb6:	89 e9                	mov    %ebp,%ecx
  801eb8:	d3 eb                	shr    %cl,%ebx
  801eba:	d3 ea                	shr    %cl,%edx
  801ebc:	09 d8                	or     %ebx,%eax
  801ebe:	83 c4 1c             	add    $0x1c,%esp
  801ec1:	5b                   	pop    %ebx
  801ec2:	5e                   	pop    %esi
  801ec3:	5f                   	pop    %edi
  801ec4:	5d                   	pop    %ebp
  801ec5:	c3                   	ret    
  801ec6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ecd:	8d 76 00             	lea    0x0(%esi),%esi
  801ed0:	29 fe                	sub    %edi,%esi
  801ed2:	19 c3                	sbb    %eax,%ebx
  801ed4:	89 f2                	mov    %esi,%edx
  801ed6:	89 d9                	mov    %ebx,%ecx
  801ed8:	e9 1d ff ff ff       	jmp    801dfa <__umoddi3+0x6a>
