
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
  800129:	68 ca 1e 80 00       	push   $0x801eca
  80012e:	6a 23                	push   $0x23
  800130:	68 e7 1e 80 00       	push   $0x801ee7
  800135:	e8 70 0f 00 00       	call   8010aa <_panic>

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
  8001b6:	68 ca 1e 80 00       	push   $0x801eca
  8001bb:	6a 23                	push   $0x23
  8001bd:	68 e7 1e 80 00       	push   $0x801ee7
  8001c2:	e8 e3 0e 00 00       	call   8010aa <_panic>

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
  8001fc:	68 ca 1e 80 00       	push   $0x801eca
  800201:	6a 23                	push   $0x23
  800203:	68 e7 1e 80 00       	push   $0x801ee7
  800208:	e8 9d 0e 00 00       	call   8010aa <_panic>

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
  800242:	68 ca 1e 80 00       	push   $0x801eca
  800247:	6a 23                	push   $0x23
  800249:	68 e7 1e 80 00       	push   $0x801ee7
  80024e:	e8 57 0e 00 00       	call   8010aa <_panic>

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
  800288:	68 ca 1e 80 00       	push   $0x801eca
  80028d:	6a 23                	push   $0x23
  80028f:	68 e7 1e 80 00       	push   $0x801ee7
  800294:	e8 11 0e 00 00       	call   8010aa <_panic>

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
  8002ce:	68 ca 1e 80 00       	push   $0x801eca
  8002d3:	6a 23                	push   $0x23
  8002d5:	68 e7 1e 80 00       	push   $0x801ee7
  8002da:	e8 cb 0d 00 00       	call   8010aa <_panic>

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
  800314:	68 ca 1e 80 00       	push   $0x801eca
  800319:	6a 23                	push   $0x23
  80031b:	68 e7 1e 80 00       	push   $0x801ee7
  800320:	e8 85 0d 00 00       	call   8010aa <_panic>

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
  800380:	68 ca 1e 80 00       	push   $0x801eca
  800385:	6a 23                	push   $0x23
  800387:	68 e7 1e 80 00       	push   $0x801ee7
  80038c:	e8 19 0d 00 00       	call   8010aa <_panic>

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
  800477:	ba 74 1f 80 00       	mov    $0x801f74,%edx
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
  80049b:	68 f8 1e 80 00       	push   $0x801ef8
  8004a0:	e8 ec 0c 00 00       	call   801191 <cprintf>
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
  800709:	68 39 1f 80 00       	push   $0x801f39
  80070e:	e8 7e 0a 00 00       	call   801191 <cprintf>
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
  8007da:	68 55 1f 80 00       	push   $0x801f55
  8007df:	e8 ad 09 00 00       	call   801191 <cprintf>
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
  80088a:	68 18 1f 80 00       	push   $0x801f18
  80088f:	e8 fd 08 00 00       	call   801191 <cprintf>
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
  80092e:	e8 cf 01 00 00       	call   800b02 <open>
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
  800980:	e8 de 11 00 00       	call   801b63 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800985:	83 c4 0c             	add    $0xc,%esp
  800988:	6a 00                	push   $0x0
  80098a:	53                   	push   %ebx
  80098b:	6a 00                	push   $0x0
  80098d:	e8 7a 11 00 00       	call   801b0c <ipc_recv>
}
  800992:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800995:	5b                   	pop    %ebx
  800996:	5e                   	pop    %esi
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800999:	83 ec 0c             	sub    $0xc,%esp
  80099c:	6a 01                	push   $0x1
  80099e:	e8 26 12 00 00       	call   801bc9 <ipc_find_env>
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
  800a36:	e8 5f 0d 00 00       	call   80179a <strcpy>
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
	panic("devfile_write not implemented");
  800a68:	68 84 1f 80 00       	push   $0x801f84
  800a6d:	68 90 00 00 00       	push   $0x90
  800a72:	68 a2 1f 80 00       	push   $0x801fa2
  800a77:	e8 2e 06 00 00       	call   8010aa <_panic>

00800a7c <devfile_read>:
{
  800a7c:	f3 0f 1e fb          	endbr32 
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	56                   	push   %esi
  800a84:	53                   	push   %ebx
  800a85:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a93:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a99:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9e:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa3:	e8 b8 fe ff ff       	call   800960 <fsipc>
  800aa8:	89 c3                	mov    %eax,%ebx
  800aaa:	85 c0                	test   %eax,%eax
  800aac:	78 1f                	js     800acd <devfile_read+0x51>
	assert(r <= n);
  800aae:	39 f0                	cmp    %esi,%eax
  800ab0:	77 24                	ja     800ad6 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800ab2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ab7:	7f 33                	jg     800aec <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ab9:	83 ec 04             	sub    $0x4,%esp
  800abc:	50                   	push   %eax
  800abd:	68 00 50 80 00       	push   $0x805000
  800ac2:	ff 75 0c             	pushl  0xc(%ebp)
  800ac5:	e8 86 0e 00 00       	call   801950 <memmove>
	return r;
  800aca:	83 c4 10             	add    $0x10,%esp
}
  800acd:	89 d8                	mov    %ebx,%eax
  800acf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    
	assert(r <= n);
  800ad6:	68 ad 1f 80 00       	push   $0x801fad
  800adb:	68 b4 1f 80 00       	push   $0x801fb4
  800ae0:	6a 7c                	push   $0x7c
  800ae2:	68 a2 1f 80 00       	push   $0x801fa2
  800ae7:	e8 be 05 00 00       	call   8010aa <_panic>
	assert(r <= PGSIZE);
  800aec:	68 c9 1f 80 00       	push   $0x801fc9
  800af1:	68 b4 1f 80 00       	push   $0x801fb4
  800af6:	6a 7d                	push   $0x7d
  800af8:	68 a2 1f 80 00       	push   $0x801fa2
  800afd:	e8 a8 05 00 00       	call   8010aa <_panic>

00800b02 <open>:
{
  800b02:	f3 0f 1e fb          	endbr32 
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
  800b0b:	83 ec 1c             	sub    $0x1c,%esp
  800b0e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b11:	56                   	push   %esi
  800b12:	e8 40 0c 00 00       	call   801757 <strlen>
  800b17:	83 c4 10             	add    $0x10,%esp
  800b1a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b1f:	7f 6c                	jg     800b8d <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800b21:	83 ec 0c             	sub    $0xc,%esp
  800b24:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b27:	50                   	push   %eax
  800b28:	e8 93 f8 ff ff       	call   8003c0 <fd_alloc>
  800b2d:	89 c3                	mov    %eax,%ebx
  800b2f:	83 c4 10             	add    $0x10,%esp
  800b32:	85 c0                	test   %eax,%eax
  800b34:	78 3c                	js     800b72 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b36:	83 ec 08             	sub    $0x8,%esp
  800b39:	56                   	push   %esi
  800b3a:	68 00 50 80 00       	push   $0x805000
  800b3f:	e8 56 0c 00 00       	call   80179a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b44:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b47:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b4f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b54:	e8 07 fe ff ff       	call   800960 <fsipc>
  800b59:	89 c3                	mov    %eax,%ebx
  800b5b:	83 c4 10             	add    $0x10,%esp
  800b5e:	85 c0                	test   %eax,%eax
  800b60:	78 19                	js     800b7b <open+0x79>
	return fd2num(fd);
  800b62:	83 ec 0c             	sub    $0xc,%esp
  800b65:	ff 75 f4             	pushl  -0xc(%ebp)
  800b68:	e8 24 f8 ff ff       	call   800391 <fd2num>
  800b6d:	89 c3                	mov    %eax,%ebx
  800b6f:	83 c4 10             	add    $0x10,%esp
}
  800b72:	89 d8                	mov    %ebx,%eax
  800b74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    
		fd_close(fd, 0);
  800b7b:	83 ec 08             	sub    $0x8,%esp
  800b7e:	6a 00                	push   $0x0
  800b80:	ff 75 f4             	pushl  -0xc(%ebp)
  800b83:	e8 3c f9 ff ff       	call   8004c4 <fd_close>
		return r;
  800b88:	83 c4 10             	add    $0x10,%esp
  800b8b:	eb e5                	jmp    800b72 <open+0x70>
		return -E_BAD_PATH;
  800b8d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b92:	eb de                	jmp    800b72 <open+0x70>

00800b94 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b94:	f3 0f 1e fb          	endbr32 
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba3:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba8:	e8 b3 fd ff ff       	call   800960 <fsipc>
}
  800bad:	c9                   	leave  
  800bae:	c3                   	ret    

00800baf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800baf:	f3 0f 1e fb          	endbr32 
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bbb:	83 ec 0c             	sub    $0xc,%esp
  800bbe:	ff 75 08             	pushl  0x8(%ebp)
  800bc1:	e8 df f7 ff ff       	call   8003a5 <fd2data>
  800bc6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bc8:	83 c4 08             	add    $0x8,%esp
  800bcb:	68 d5 1f 80 00       	push   $0x801fd5
  800bd0:	53                   	push   %ebx
  800bd1:	e8 c4 0b 00 00       	call   80179a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bd6:	8b 46 04             	mov    0x4(%esi),%eax
  800bd9:	2b 06                	sub    (%esi),%eax
  800bdb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800be1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800be8:	00 00 00 
	stat->st_dev = &devpipe;
  800beb:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bf2:	30 80 00 
	return 0;
}
  800bf5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c01:	f3 0f 1e fb          	endbr32 
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	53                   	push   %ebx
  800c09:	83 ec 0c             	sub    $0xc,%esp
  800c0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c0f:	53                   	push   %ebx
  800c10:	6a 00                	push   $0x0
  800c12:	e8 f6 f5 ff ff       	call   80020d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c17:	89 1c 24             	mov    %ebx,(%esp)
  800c1a:	e8 86 f7 ff ff       	call   8003a5 <fd2data>
  800c1f:	83 c4 08             	add    $0x8,%esp
  800c22:	50                   	push   %eax
  800c23:	6a 00                	push   $0x0
  800c25:	e8 e3 f5 ff ff       	call   80020d <sys_page_unmap>
}
  800c2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c2d:	c9                   	leave  
  800c2e:	c3                   	ret    

00800c2f <_pipeisclosed>:
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	57                   	push   %edi
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	83 ec 1c             	sub    $0x1c,%esp
  800c38:	89 c7                	mov    %eax,%edi
  800c3a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c3c:	a1 04 40 80 00       	mov    0x804004,%eax
  800c41:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c44:	83 ec 0c             	sub    $0xc,%esp
  800c47:	57                   	push   %edi
  800c48:	e8 b9 0f 00 00       	call   801c06 <pageref>
  800c4d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c50:	89 34 24             	mov    %esi,(%esp)
  800c53:	e8 ae 0f 00 00       	call   801c06 <pageref>
		nn = thisenv->env_runs;
  800c58:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c5e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c61:	83 c4 10             	add    $0x10,%esp
  800c64:	39 cb                	cmp    %ecx,%ebx
  800c66:	74 1b                	je     800c83 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c68:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c6b:	75 cf                	jne    800c3c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c6d:	8b 42 58             	mov    0x58(%edx),%eax
  800c70:	6a 01                	push   $0x1
  800c72:	50                   	push   %eax
  800c73:	53                   	push   %ebx
  800c74:	68 dc 1f 80 00       	push   $0x801fdc
  800c79:	e8 13 05 00 00       	call   801191 <cprintf>
  800c7e:	83 c4 10             	add    $0x10,%esp
  800c81:	eb b9                	jmp    800c3c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c83:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c86:	0f 94 c0             	sete   %al
  800c89:	0f b6 c0             	movzbl %al,%eax
}
  800c8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <devpipe_write>:
{
  800c94:	f3 0f 1e fb          	endbr32 
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	57                   	push   %edi
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
  800c9e:	83 ec 28             	sub    $0x28,%esp
  800ca1:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800ca4:	56                   	push   %esi
  800ca5:	e8 fb f6 ff ff       	call   8003a5 <fd2data>
  800caa:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cac:	83 c4 10             	add    $0x10,%esp
  800caf:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cb7:	74 4f                	je     800d08 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cb9:	8b 43 04             	mov    0x4(%ebx),%eax
  800cbc:	8b 0b                	mov    (%ebx),%ecx
  800cbe:	8d 51 20             	lea    0x20(%ecx),%edx
  800cc1:	39 d0                	cmp    %edx,%eax
  800cc3:	72 14                	jb     800cd9 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800cc5:	89 da                	mov    %ebx,%edx
  800cc7:	89 f0                	mov    %esi,%eax
  800cc9:	e8 61 ff ff ff       	call   800c2f <_pipeisclosed>
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	75 3b                	jne    800d0d <devpipe_write+0x79>
			sys_yield();
  800cd2:	e8 86 f4 ff ff       	call   80015d <sys_yield>
  800cd7:	eb e0                	jmp    800cb9 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ce0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ce3:	89 c2                	mov    %eax,%edx
  800ce5:	c1 fa 1f             	sar    $0x1f,%edx
  800ce8:	89 d1                	mov    %edx,%ecx
  800cea:	c1 e9 1b             	shr    $0x1b,%ecx
  800ced:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cf0:	83 e2 1f             	and    $0x1f,%edx
  800cf3:	29 ca                	sub    %ecx,%edx
  800cf5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cf9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cfd:	83 c0 01             	add    $0x1,%eax
  800d00:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800d03:	83 c7 01             	add    $0x1,%edi
  800d06:	eb ac                	jmp    800cb4 <devpipe_write+0x20>
	return i;
  800d08:	8b 45 10             	mov    0x10(%ebp),%eax
  800d0b:	eb 05                	jmp    800d12 <devpipe_write+0x7e>
				return 0;
  800d0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <devpipe_read>:
{
  800d1a:	f3 0f 1e fb          	endbr32 
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 18             	sub    $0x18,%esp
  800d27:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800d2a:	57                   	push   %edi
  800d2b:	e8 75 f6 ff ff       	call   8003a5 <fd2data>
  800d30:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d32:	83 c4 10             	add    $0x10,%esp
  800d35:	be 00 00 00 00       	mov    $0x0,%esi
  800d3a:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d3d:	75 14                	jne    800d53 <devpipe_read+0x39>
	return i;
  800d3f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d42:	eb 02                	jmp    800d46 <devpipe_read+0x2c>
				return i;
  800d44:	89 f0                	mov    %esi,%eax
}
  800d46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    
			sys_yield();
  800d4e:	e8 0a f4 ff ff       	call   80015d <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d53:	8b 03                	mov    (%ebx),%eax
  800d55:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d58:	75 18                	jne    800d72 <devpipe_read+0x58>
			if (i > 0)
  800d5a:	85 f6                	test   %esi,%esi
  800d5c:	75 e6                	jne    800d44 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d5e:	89 da                	mov    %ebx,%edx
  800d60:	89 f8                	mov    %edi,%eax
  800d62:	e8 c8 fe ff ff       	call   800c2f <_pipeisclosed>
  800d67:	85 c0                	test   %eax,%eax
  800d69:	74 e3                	je     800d4e <devpipe_read+0x34>
				return 0;
  800d6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d70:	eb d4                	jmp    800d46 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d72:	99                   	cltd   
  800d73:	c1 ea 1b             	shr    $0x1b,%edx
  800d76:	01 d0                	add    %edx,%eax
  800d78:	83 e0 1f             	and    $0x1f,%eax
  800d7b:	29 d0                	sub    %edx,%eax
  800d7d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d85:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d88:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d8b:	83 c6 01             	add    $0x1,%esi
  800d8e:	eb aa                	jmp    800d3a <devpipe_read+0x20>

00800d90 <pipe>:
{
  800d90:	f3 0f 1e fb          	endbr32 
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
  800d99:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d9f:	50                   	push   %eax
  800da0:	e8 1b f6 ff ff       	call   8003c0 <fd_alloc>
  800da5:	89 c3                	mov    %eax,%ebx
  800da7:	83 c4 10             	add    $0x10,%esp
  800daa:	85 c0                	test   %eax,%eax
  800dac:	0f 88 23 01 00 00    	js     800ed5 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db2:	83 ec 04             	sub    $0x4,%esp
  800db5:	68 07 04 00 00       	push   $0x407
  800dba:	ff 75 f4             	pushl  -0xc(%ebp)
  800dbd:	6a 00                	push   $0x0
  800dbf:	e8 bc f3 ff ff       	call   800180 <sys_page_alloc>
  800dc4:	89 c3                	mov    %eax,%ebx
  800dc6:	83 c4 10             	add    $0x10,%esp
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	0f 88 04 01 00 00    	js     800ed5 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800dd1:	83 ec 0c             	sub    $0xc,%esp
  800dd4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dd7:	50                   	push   %eax
  800dd8:	e8 e3 f5 ff ff       	call   8003c0 <fd_alloc>
  800ddd:	89 c3                	mov    %eax,%ebx
  800ddf:	83 c4 10             	add    $0x10,%esp
  800de2:	85 c0                	test   %eax,%eax
  800de4:	0f 88 db 00 00 00    	js     800ec5 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dea:	83 ec 04             	sub    $0x4,%esp
  800ded:	68 07 04 00 00       	push   $0x407
  800df2:	ff 75 f0             	pushl  -0x10(%ebp)
  800df5:	6a 00                	push   $0x0
  800df7:	e8 84 f3 ff ff       	call   800180 <sys_page_alloc>
  800dfc:	89 c3                	mov    %eax,%ebx
  800dfe:	83 c4 10             	add    $0x10,%esp
  800e01:	85 c0                	test   %eax,%eax
  800e03:	0f 88 bc 00 00 00    	js     800ec5 <pipe+0x135>
	va = fd2data(fd0);
  800e09:	83 ec 0c             	sub    $0xc,%esp
  800e0c:	ff 75 f4             	pushl  -0xc(%ebp)
  800e0f:	e8 91 f5 ff ff       	call   8003a5 <fd2data>
  800e14:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e16:	83 c4 0c             	add    $0xc,%esp
  800e19:	68 07 04 00 00       	push   $0x407
  800e1e:	50                   	push   %eax
  800e1f:	6a 00                	push   $0x0
  800e21:	e8 5a f3 ff ff       	call   800180 <sys_page_alloc>
  800e26:	89 c3                	mov    %eax,%ebx
  800e28:	83 c4 10             	add    $0x10,%esp
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	0f 88 82 00 00 00    	js     800eb5 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e33:	83 ec 0c             	sub    $0xc,%esp
  800e36:	ff 75 f0             	pushl  -0x10(%ebp)
  800e39:	e8 67 f5 ff ff       	call   8003a5 <fd2data>
  800e3e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e45:	50                   	push   %eax
  800e46:	6a 00                	push   $0x0
  800e48:	56                   	push   %esi
  800e49:	6a 00                	push   $0x0
  800e4b:	e8 77 f3 ff ff       	call   8001c7 <sys_page_map>
  800e50:	89 c3                	mov    %eax,%ebx
  800e52:	83 c4 20             	add    $0x20,%esp
  800e55:	85 c0                	test   %eax,%eax
  800e57:	78 4e                	js     800ea7 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e59:	a1 20 30 80 00       	mov    0x803020,%eax
  800e5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e61:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e63:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e66:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e6d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e70:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e75:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e7c:	83 ec 0c             	sub    $0xc,%esp
  800e7f:	ff 75 f4             	pushl  -0xc(%ebp)
  800e82:	e8 0a f5 ff ff       	call   800391 <fd2num>
  800e87:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e8c:	83 c4 04             	add    $0x4,%esp
  800e8f:	ff 75 f0             	pushl  -0x10(%ebp)
  800e92:	e8 fa f4 ff ff       	call   800391 <fd2num>
  800e97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e9a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e9d:	83 c4 10             	add    $0x10,%esp
  800ea0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea5:	eb 2e                	jmp    800ed5 <pipe+0x145>
	sys_page_unmap(0, va);
  800ea7:	83 ec 08             	sub    $0x8,%esp
  800eaa:	56                   	push   %esi
  800eab:	6a 00                	push   $0x0
  800ead:	e8 5b f3 ff ff       	call   80020d <sys_page_unmap>
  800eb2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800eb5:	83 ec 08             	sub    $0x8,%esp
  800eb8:	ff 75 f0             	pushl  -0x10(%ebp)
  800ebb:	6a 00                	push   $0x0
  800ebd:	e8 4b f3 ff ff       	call   80020d <sys_page_unmap>
  800ec2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800ec5:	83 ec 08             	sub    $0x8,%esp
  800ec8:	ff 75 f4             	pushl  -0xc(%ebp)
  800ecb:	6a 00                	push   $0x0
  800ecd:	e8 3b f3 ff ff       	call   80020d <sys_page_unmap>
  800ed2:	83 c4 10             	add    $0x10,%esp
}
  800ed5:	89 d8                	mov    %ebx,%eax
  800ed7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eda:	5b                   	pop    %ebx
  800edb:	5e                   	pop    %esi
  800edc:	5d                   	pop    %ebp
  800edd:	c3                   	ret    

00800ede <pipeisclosed>:
{
  800ede:	f3 0f 1e fb          	endbr32 
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ee8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eeb:	50                   	push   %eax
  800eec:	ff 75 08             	pushl  0x8(%ebp)
  800eef:	e8 22 f5 ff ff       	call   800416 <fd_lookup>
  800ef4:	83 c4 10             	add    $0x10,%esp
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	78 18                	js     800f13 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800efb:	83 ec 0c             	sub    $0xc,%esp
  800efe:	ff 75 f4             	pushl  -0xc(%ebp)
  800f01:	e8 9f f4 ff ff       	call   8003a5 <fd2data>
  800f06:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f0b:	e8 1f fd ff ff       	call   800c2f <_pipeisclosed>
  800f10:	83 c4 10             	add    $0x10,%esp
}
  800f13:	c9                   	leave  
  800f14:	c3                   	ret    

00800f15 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f15:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800f19:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1e:	c3                   	ret    

00800f1f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f1f:	f3 0f 1e fb          	endbr32 
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f29:	68 f4 1f 80 00       	push   $0x801ff4
  800f2e:	ff 75 0c             	pushl  0xc(%ebp)
  800f31:	e8 64 08 00 00       	call   80179a <strcpy>
	return 0;
}
  800f36:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3b:	c9                   	leave  
  800f3c:	c3                   	ret    

00800f3d <devcons_write>:
{
  800f3d:	f3 0f 1e fb          	endbr32 
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	57                   	push   %edi
  800f45:	56                   	push   %esi
  800f46:	53                   	push   %ebx
  800f47:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f4d:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f52:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f58:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f5b:	73 31                	jae    800f8e <devcons_write+0x51>
		m = n - tot;
  800f5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f60:	29 f3                	sub    %esi,%ebx
  800f62:	83 fb 7f             	cmp    $0x7f,%ebx
  800f65:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f6a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f6d:	83 ec 04             	sub    $0x4,%esp
  800f70:	53                   	push   %ebx
  800f71:	89 f0                	mov    %esi,%eax
  800f73:	03 45 0c             	add    0xc(%ebp),%eax
  800f76:	50                   	push   %eax
  800f77:	57                   	push   %edi
  800f78:	e8 d3 09 00 00       	call   801950 <memmove>
		sys_cputs(buf, m);
  800f7d:	83 c4 08             	add    $0x8,%esp
  800f80:	53                   	push   %ebx
  800f81:	57                   	push   %edi
  800f82:	e8 29 f1 ff ff       	call   8000b0 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f87:	01 de                	add    %ebx,%esi
  800f89:	83 c4 10             	add    $0x10,%esp
  800f8c:	eb ca                	jmp    800f58 <devcons_write+0x1b>
}
  800f8e:	89 f0                	mov    %esi,%eax
  800f90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f93:	5b                   	pop    %ebx
  800f94:	5e                   	pop    %esi
  800f95:	5f                   	pop    %edi
  800f96:	5d                   	pop    %ebp
  800f97:	c3                   	ret    

00800f98 <devcons_read>:
{
  800f98:	f3 0f 1e fb          	endbr32 
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	83 ec 08             	sub    $0x8,%esp
  800fa2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800fa7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fab:	74 21                	je     800fce <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800fad:	e8 20 f1 ff ff       	call   8000d2 <sys_cgetc>
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	75 07                	jne    800fbd <devcons_read+0x25>
		sys_yield();
  800fb6:	e8 a2 f1 ff ff       	call   80015d <sys_yield>
  800fbb:	eb f0                	jmp    800fad <devcons_read+0x15>
	if (c < 0)
  800fbd:	78 0f                	js     800fce <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800fbf:	83 f8 04             	cmp    $0x4,%eax
  800fc2:	74 0c                	je     800fd0 <devcons_read+0x38>
	*(char*)vbuf = c;
  800fc4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc7:	88 02                	mov    %al,(%edx)
	return 1;
  800fc9:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800fce:	c9                   	leave  
  800fcf:	c3                   	ret    
		return 0;
  800fd0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd5:	eb f7                	jmp    800fce <devcons_read+0x36>

00800fd7 <cputchar>:
{
  800fd7:	f3 0f 1e fb          	endbr32 
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fe1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe4:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800fe7:	6a 01                	push   $0x1
  800fe9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fec:	50                   	push   %eax
  800fed:	e8 be f0 ff ff       	call   8000b0 <sys_cputs>
}
  800ff2:	83 c4 10             	add    $0x10,%esp
  800ff5:	c9                   	leave  
  800ff6:	c3                   	ret    

00800ff7 <getchar>:
{
  800ff7:	f3 0f 1e fb          	endbr32 
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801001:	6a 01                	push   $0x1
  801003:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801006:	50                   	push   %eax
  801007:	6a 00                	push   $0x0
  801009:	e8 8b f6 ff ff       	call   800699 <read>
	if (r < 0)
  80100e:	83 c4 10             	add    $0x10,%esp
  801011:	85 c0                	test   %eax,%eax
  801013:	78 06                	js     80101b <getchar+0x24>
	if (r < 1)
  801015:	74 06                	je     80101d <getchar+0x26>
	return c;
  801017:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80101b:	c9                   	leave  
  80101c:	c3                   	ret    
		return -E_EOF;
  80101d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801022:	eb f7                	jmp    80101b <getchar+0x24>

00801024 <iscons>:
{
  801024:	f3 0f 1e fb          	endbr32 
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80102e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801031:	50                   	push   %eax
  801032:	ff 75 08             	pushl  0x8(%ebp)
  801035:	e8 dc f3 ff ff       	call   800416 <fd_lookup>
  80103a:	83 c4 10             	add    $0x10,%esp
  80103d:	85 c0                	test   %eax,%eax
  80103f:	78 11                	js     801052 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801041:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801044:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80104a:	39 10                	cmp    %edx,(%eax)
  80104c:	0f 94 c0             	sete   %al
  80104f:	0f b6 c0             	movzbl %al,%eax
}
  801052:	c9                   	leave  
  801053:	c3                   	ret    

00801054 <opencons>:
{
  801054:	f3 0f 1e fb          	endbr32 
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80105e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801061:	50                   	push   %eax
  801062:	e8 59 f3 ff ff       	call   8003c0 <fd_alloc>
  801067:	83 c4 10             	add    $0x10,%esp
  80106a:	85 c0                	test   %eax,%eax
  80106c:	78 3a                	js     8010a8 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80106e:	83 ec 04             	sub    $0x4,%esp
  801071:	68 07 04 00 00       	push   $0x407
  801076:	ff 75 f4             	pushl  -0xc(%ebp)
  801079:	6a 00                	push   $0x0
  80107b:	e8 00 f1 ff ff       	call   800180 <sys_page_alloc>
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	85 c0                	test   %eax,%eax
  801085:	78 21                	js     8010a8 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801087:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80108a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801090:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801092:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801095:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80109c:	83 ec 0c             	sub    $0xc,%esp
  80109f:	50                   	push   %eax
  8010a0:	e8 ec f2 ff ff       	call   800391 <fd2num>
  8010a5:	83 c4 10             	add    $0x10,%esp
}
  8010a8:	c9                   	leave  
  8010a9:	c3                   	ret    

008010aa <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010aa:	f3 0f 1e fb          	endbr32 
  8010ae:	55                   	push   %ebp
  8010af:	89 e5                	mov    %esp,%ebp
  8010b1:	56                   	push   %esi
  8010b2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010b3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010b6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010bc:	e8 79 f0 ff ff       	call   80013a <sys_getenvid>
  8010c1:	83 ec 0c             	sub    $0xc,%esp
  8010c4:	ff 75 0c             	pushl  0xc(%ebp)
  8010c7:	ff 75 08             	pushl  0x8(%ebp)
  8010ca:	56                   	push   %esi
  8010cb:	50                   	push   %eax
  8010cc:	68 00 20 80 00       	push   $0x802000
  8010d1:	e8 bb 00 00 00       	call   801191 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010d6:	83 c4 18             	add    $0x18,%esp
  8010d9:	53                   	push   %ebx
  8010da:	ff 75 10             	pushl  0x10(%ebp)
  8010dd:	e8 5a 00 00 00       	call   80113c <vcprintf>
	cprintf("\n");
  8010e2:	c7 04 24 ed 1f 80 00 	movl   $0x801fed,(%esp)
  8010e9:	e8 a3 00 00 00       	call   801191 <cprintf>
  8010ee:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010f1:	cc                   	int3   
  8010f2:	eb fd                	jmp    8010f1 <_panic+0x47>

008010f4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010f4:	f3 0f 1e fb          	endbr32 
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	53                   	push   %ebx
  8010fc:	83 ec 04             	sub    $0x4,%esp
  8010ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801102:	8b 13                	mov    (%ebx),%edx
  801104:	8d 42 01             	lea    0x1(%edx),%eax
  801107:	89 03                	mov    %eax,(%ebx)
  801109:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80110c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801110:	3d ff 00 00 00       	cmp    $0xff,%eax
  801115:	74 09                	je     801120 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801117:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80111b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80111e:	c9                   	leave  
  80111f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801120:	83 ec 08             	sub    $0x8,%esp
  801123:	68 ff 00 00 00       	push   $0xff
  801128:	8d 43 08             	lea    0x8(%ebx),%eax
  80112b:	50                   	push   %eax
  80112c:	e8 7f ef ff ff       	call   8000b0 <sys_cputs>
		b->idx = 0;
  801131:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801137:	83 c4 10             	add    $0x10,%esp
  80113a:	eb db                	jmp    801117 <putch+0x23>

0080113c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80113c:	f3 0f 1e fb          	endbr32 
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801149:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801150:	00 00 00 
	b.cnt = 0;
  801153:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80115a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80115d:	ff 75 0c             	pushl  0xc(%ebp)
  801160:	ff 75 08             	pushl  0x8(%ebp)
  801163:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801169:	50                   	push   %eax
  80116a:	68 f4 10 80 00       	push   $0x8010f4
  80116f:	e8 20 01 00 00       	call   801294 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801174:	83 c4 08             	add    $0x8,%esp
  801177:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80117d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801183:	50                   	push   %eax
  801184:	e8 27 ef ff ff       	call   8000b0 <sys_cputs>

	return b.cnt;
}
  801189:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80118f:	c9                   	leave  
  801190:	c3                   	ret    

00801191 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801191:	f3 0f 1e fb          	endbr32 
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
  801198:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80119b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80119e:	50                   	push   %eax
  80119f:	ff 75 08             	pushl  0x8(%ebp)
  8011a2:	e8 95 ff ff ff       	call   80113c <vcprintf>
	va_end(ap);

	return cnt;
}
  8011a7:	c9                   	leave  
  8011a8:	c3                   	ret    

008011a9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	57                   	push   %edi
  8011ad:	56                   	push   %esi
  8011ae:	53                   	push   %ebx
  8011af:	83 ec 1c             	sub    $0x1c,%esp
  8011b2:	89 c7                	mov    %eax,%edi
  8011b4:	89 d6                	mov    %edx,%esi
  8011b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011bc:	89 d1                	mov    %edx,%ecx
  8011be:	89 c2                	mov    %eax,%edx
  8011c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011c3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8011c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8011c9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011cf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8011d6:	39 c2                	cmp    %eax,%edx
  8011d8:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8011db:	72 3e                	jb     80121b <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011dd:	83 ec 0c             	sub    $0xc,%esp
  8011e0:	ff 75 18             	pushl  0x18(%ebp)
  8011e3:	83 eb 01             	sub    $0x1,%ebx
  8011e6:	53                   	push   %ebx
  8011e7:	50                   	push   %eax
  8011e8:	83 ec 08             	sub    $0x8,%esp
  8011eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8011f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8011f7:	e8 54 0a 00 00       	call   801c50 <__udivdi3>
  8011fc:	83 c4 18             	add    $0x18,%esp
  8011ff:	52                   	push   %edx
  801200:	50                   	push   %eax
  801201:	89 f2                	mov    %esi,%edx
  801203:	89 f8                	mov    %edi,%eax
  801205:	e8 9f ff ff ff       	call   8011a9 <printnum>
  80120a:	83 c4 20             	add    $0x20,%esp
  80120d:	eb 13                	jmp    801222 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80120f:	83 ec 08             	sub    $0x8,%esp
  801212:	56                   	push   %esi
  801213:	ff 75 18             	pushl  0x18(%ebp)
  801216:	ff d7                	call   *%edi
  801218:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80121b:	83 eb 01             	sub    $0x1,%ebx
  80121e:	85 db                	test   %ebx,%ebx
  801220:	7f ed                	jg     80120f <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801222:	83 ec 08             	sub    $0x8,%esp
  801225:	56                   	push   %esi
  801226:	83 ec 04             	sub    $0x4,%esp
  801229:	ff 75 e4             	pushl  -0x1c(%ebp)
  80122c:	ff 75 e0             	pushl  -0x20(%ebp)
  80122f:	ff 75 dc             	pushl  -0x24(%ebp)
  801232:	ff 75 d8             	pushl  -0x28(%ebp)
  801235:	e8 26 0b 00 00       	call   801d60 <__umoddi3>
  80123a:	83 c4 14             	add    $0x14,%esp
  80123d:	0f be 80 23 20 80 00 	movsbl 0x802023(%eax),%eax
  801244:	50                   	push   %eax
  801245:	ff d7                	call   *%edi
}
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124d:	5b                   	pop    %ebx
  80124e:	5e                   	pop    %esi
  80124f:	5f                   	pop    %edi
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    

00801252 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801252:	f3 0f 1e fb          	endbr32 
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80125c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801260:	8b 10                	mov    (%eax),%edx
  801262:	3b 50 04             	cmp    0x4(%eax),%edx
  801265:	73 0a                	jae    801271 <sprintputch+0x1f>
		*b->buf++ = ch;
  801267:	8d 4a 01             	lea    0x1(%edx),%ecx
  80126a:	89 08                	mov    %ecx,(%eax)
  80126c:	8b 45 08             	mov    0x8(%ebp),%eax
  80126f:	88 02                	mov    %al,(%edx)
}
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    

00801273 <printfmt>:
{
  801273:	f3 0f 1e fb          	endbr32 
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80127d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801280:	50                   	push   %eax
  801281:	ff 75 10             	pushl  0x10(%ebp)
  801284:	ff 75 0c             	pushl  0xc(%ebp)
  801287:	ff 75 08             	pushl  0x8(%ebp)
  80128a:	e8 05 00 00 00       	call   801294 <vprintfmt>
}
  80128f:	83 c4 10             	add    $0x10,%esp
  801292:	c9                   	leave  
  801293:	c3                   	ret    

00801294 <vprintfmt>:
{
  801294:	f3 0f 1e fb          	endbr32 
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	57                   	push   %edi
  80129c:	56                   	push   %esi
  80129d:	53                   	push   %ebx
  80129e:	83 ec 3c             	sub    $0x3c,%esp
  8012a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012a7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012aa:	e9 4a 03 00 00       	jmp    8015f9 <vprintfmt+0x365>
		padc = ' ';
  8012af:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012b3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012ba:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012c1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012c8:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012cd:	8d 47 01             	lea    0x1(%edi),%eax
  8012d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012d3:	0f b6 17             	movzbl (%edi),%edx
  8012d6:	8d 42 dd             	lea    -0x23(%edx),%eax
  8012d9:	3c 55                	cmp    $0x55,%al
  8012db:	0f 87 de 03 00 00    	ja     8016bf <vprintfmt+0x42b>
  8012e1:	0f b6 c0             	movzbl %al,%eax
  8012e4:	3e ff 24 85 60 21 80 	notrack jmp *0x802160(,%eax,4)
  8012eb:	00 
  8012ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8012ef:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8012f3:	eb d8                	jmp    8012cd <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8012f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012f8:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8012fc:	eb cf                	jmp    8012cd <vprintfmt+0x39>
  8012fe:	0f b6 d2             	movzbl %dl,%edx
  801301:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801304:	b8 00 00 00 00       	mov    $0x0,%eax
  801309:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80130c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80130f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801313:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801316:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801319:	83 f9 09             	cmp    $0x9,%ecx
  80131c:	77 55                	ja     801373 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80131e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801321:	eb e9                	jmp    80130c <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801323:	8b 45 14             	mov    0x14(%ebp),%eax
  801326:	8b 00                	mov    (%eax),%eax
  801328:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80132b:	8b 45 14             	mov    0x14(%ebp),%eax
  80132e:	8d 40 04             	lea    0x4(%eax),%eax
  801331:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801334:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801337:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80133b:	79 90                	jns    8012cd <vprintfmt+0x39>
				width = precision, precision = -1;
  80133d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801340:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801343:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80134a:	eb 81                	jmp    8012cd <vprintfmt+0x39>
  80134c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80134f:	85 c0                	test   %eax,%eax
  801351:	ba 00 00 00 00       	mov    $0x0,%edx
  801356:	0f 49 d0             	cmovns %eax,%edx
  801359:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80135c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80135f:	e9 69 ff ff ff       	jmp    8012cd <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801364:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801367:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80136e:	e9 5a ff ff ff       	jmp    8012cd <vprintfmt+0x39>
  801373:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801376:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801379:	eb bc                	jmp    801337 <vprintfmt+0xa3>
			lflag++;
  80137b:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80137e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801381:	e9 47 ff ff ff       	jmp    8012cd <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  801386:	8b 45 14             	mov    0x14(%ebp),%eax
  801389:	8d 78 04             	lea    0x4(%eax),%edi
  80138c:	83 ec 08             	sub    $0x8,%esp
  80138f:	53                   	push   %ebx
  801390:	ff 30                	pushl  (%eax)
  801392:	ff d6                	call   *%esi
			break;
  801394:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801397:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80139a:	e9 57 02 00 00       	jmp    8015f6 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80139f:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a2:	8d 78 04             	lea    0x4(%eax),%edi
  8013a5:	8b 00                	mov    (%eax),%eax
  8013a7:	99                   	cltd   
  8013a8:	31 d0                	xor    %edx,%eax
  8013aa:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013ac:	83 f8 0f             	cmp    $0xf,%eax
  8013af:	7f 23                	jg     8013d4 <vprintfmt+0x140>
  8013b1:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  8013b8:	85 d2                	test   %edx,%edx
  8013ba:	74 18                	je     8013d4 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8013bc:	52                   	push   %edx
  8013bd:	68 c6 1f 80 00       	push   $0x801fc6
  8013c2:	53                   	push   %ebx
  8013c3:	56                   	push   %esi
  8013c4:	e8 aa fe ff ff       	call   801273 <printfmt>
  8013c9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8013cc:	89 7d 14             	mov    %edi,0x14(%ebp)
  8013cf:	e9 22 02 00 00       	jmp    8015f6 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8013d4:	50                   	push   %eax
  8013d5:	68 3b 20 80 00       	push   $0x80203b
  8013da:	53                   	push   %ebx
  8013db:	56                   	push   %esi
  8013dc:	e8 92 fe ff ff       	call   801273 <printfmt>
  8013e1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8013e4:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8013e7:	e9 0a 02 00 00       	jmp    8015f6 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8013ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ef:	83 c0 04             	add    $0x4,%eax
  8013f2:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8013f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8013f8:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8013fa:	85 d2                	test   %edx,%edx
  8013fc:	b8 34 20 80 00       	mov    $0x802034,%eax
  801401:	0f 45 c2             	cmovne %edx,%eax
  801404:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801407:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80140b:	7e 06                	jle    801413 <vprintfmt+0x17f>
  80140d:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801411:	75 0d                	jne    801420 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  801413:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801416:	89 c7                	mov    %eax,%edi
  801418:	03 45 e0             	add    -0x20(%ebp),%eax
  80141b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80141e:	eb 55                	jmp    801475 <vprintfmt+0x1e1>
  801420:	83 ec 08             	sub    $0x8,%esp
  801423:	ff 75 d8             	pushl  -0x28(%ebp)
  801426:	ff 75 cc             	pushl  -0x34(%ebp)
  801429:	e8 45 03 00 00       	call   801773 <strnlen>
  80142e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801431:	29 c2                	sub    %eax,%edx
  801433:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801436:	83 c4 10             	add    $0x10,%esp
  801439:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80143b:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80143f:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801442:	85 ff                	test   %edi,%edi
  801444:	7e 11                	jle    801457 <vprintfmt+0x1c3>
					putch(padc, putdat);
  801446:	83 ec 08             	sub    $0x8,%esp
  801449:	53                   	push   %ebx
  80144a:	ff 75 e0             	pushl  -0x20(%ebp)
  80144d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80144f:	83 ef 01             	sub    $0x1,%edi
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	eb eb                	jmp    801442 <vprintfmt+0x1ae>
  801457:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80145a:	85 d2                	test   %edx,%edx
  80145c:	b8 00 00 00 00       	mov    $0x0,%eax
  801461:	0f 49 c2             	cmovns %edx,%eax
  801464:	29 c2                	sub    %eax,%edx
  801466:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801469:	eb a8                	jmp    801413 <vprintfmt+0x17f>
					putch(ch, putdat);
  80146b:	83 ec 08             	sub    $0x8,%esp
  80146e:	53                   	push   %ebx
  80146f:	52                   	push   %edx
  801470:	ff d6                	call   *%esi
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801478:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80147a:	83 c7 01             	add    $0x1,%edi
  80147d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801481:	0f be d0             	movsbl %al,%edx
  801484:	85 d2                	test   %edx,%edx
  801486:	74 4b                	je     8014d3 <vprintfmt+0x23f>
  801488:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80148c:	78 06                	js     801494 <vprintfmt+0x200>
  80148e:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  801492:	78 1e                	js     8014b2 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  801494:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801498:	74 d1                	je     80146b <vprintfmt+0x1d7>
  80149a:	0f be c0             	movsbl %al,%eax
  80149d:	83 e8 20             	sub    $0x20,%eax
  8014a0:	83 f8 5e             	cmp    $0x5e,%eax
  8014a3:	76 c6                	jbe    80146b <vprintfmt+0x1d7>
					putch('?', putdat);
  8014a5:	83 ec 08             	sub    $0x8,%esp
  8014a8:	53                   	push   %ebx
  8014a9:	6a 3f                	push   $0x3f
  8014ab:	ff d6                	call   *%esi
  8014ad:	83 c4 10             	add    $0x10,%esp
  8014b0:	eb c3                	jmp    801475 <vprintfmt+0x1e1>
  8014b2:	89 cf                	mov    %ecx,%edi
  8014b4:	eb 0e                	jmp    8014c4 <vprintfmt+0x230>
				putch(' ', putdat);
  8014b6:	83 ec 08             	sub    $0x8,%esp
  8014b9:	53                   	push   %ebx
  8014ba:	6a 20                	push   $0x20
  8014bc:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8014be:	83 ef 01             	sub    $0x1,%edi
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	85 ff                	test   %edi,%edi
  8014c6:	7f ee                	jg     8014b6 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8014c8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8014cb:	89 45 14             	mov    %eax,0x14(%ebp)
  8014ce:	e9 23 01 00 00       	jmp    8015f6 <vprintfmt+0x362>
  8014d3:	89 cf                	mov    %ecx,%edi
  8014d5:	eb ed                	jmp    8014c4 <vprintfmt+0x230>
	if (lflag >= 2)
  8014d7:	83 f9 01             	cmp    $0x1,%ecx
  8014da:	7f 1b                	jg     8014f7 <vprintfmt+0x263>
	else if (lflag)
  8014dc:	85 c9                	test   %ecx,%ecx
  8014de:	74 63                	je     801543 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8014e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e3:	8b 00                	mov    (%eax),%eax
  8014e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014e8:	99                   	cltd   
  8014e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ef:	8d 40 04             	lea    0x4(%eax),%eax
  8014f2:	89 45 14             	mov    %eax,0x14(%ebp)
  8014f5:	eb 17                	jmp    80150e <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8014f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fa:	8b 50 04             	mov    0x4(%eax),%edx
  8014fd:	8b 00                	mov    (%eax),%eax
  8014ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801502:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801505:	8b 45 14             	mov    0x14(%ebp),%eax
  801508:	8d 40 08             	lea    0x8(%eax),%eax
  80150b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80150e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801511:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801514:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  801519:	85 c9                	test   %ecx,%ecx
  80151b:	0f 89 bb 00 00 00    	jns    8015dc <vprintfmt+0x348>
				putch('-', putdat);
  801521:	83 ec 08             	sub    $0x8,%esp
  801524:	53                   	push   %ebx
  801525:	6a 2d                	push   $0x2d
  801527:	ff d6                	call   *%esi
				num = -(long long) num;
  801529:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80152c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80152f:	f7 da                	neg    %edx
  801531:	83 d1 00             	adc    $0x0,%ecx
  801534:	f7 d9                	neg    %ecx
  801536:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801539:	b8 0a 00 00 00       	mov    $0xa,%eax
  80153e:	e9 99 00 00 00       	jmp    8015dc <vprintfmt+0x348>
		return va_arg(*ap, int);
  801543:	8b 45 14             	mov    0x14(%ebp),%eax
  801546:	8b 00                	mov    (%eax),%eax
  801548:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80154b:	99                   	cltd   
  80154c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80154f:	8b 45 14             	mov    0x14(%ebp),%eax
  801552:	8d 40 04             	lea    0x4(%eax),%eax
  801555:	89 45 14             	mov    %eax,0x14(%ebp)
  801558:	eb b4                	jmp    80150e <vprintfmt+0x27a>
	if (lflag >= 2)
  80155a:	83 f9 01             	cmp    $0x1,%ecx
  80155d:	7f 1b                	jg     80157a <vprintfmt+0x2e6>
	else if (lflag)
  80155f:	85 c9                	test   %ecx,%ecx
  801561:	74 2c                	je     80158f <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  801563:	8b 45 14             	mov    0x14(%ebp),%eax
  801566:	8b 10                	mov    (%eax),%edx
  801568:	b9 00 00 00 00       	mov    $0x0,%ecx
  80156d:	8d 40 04             	lea    0x4(%eax),%eax
  801570:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801573:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  801578:	eb 62                	jmp    8015dc <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80157a:	8b 45 14             	mov    0x14(%ebp),%eax
  80157d:	8b 10                	mov    (%eax),%edx
  80157f:	8b 48 04             	mov    0x4(%eax),%ecx
  801582:	8d 40 08             	lea    0x8(%eax),%eax
  801585:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801588:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80158d:	eb 4d                	jmp    8015dc <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80158f:	8b 45 14             	mov    0x14(%ebp),%eax
  801592:	8b 10                	mov    (%eax),%edx
  801594:	b9 00 00 00 00       	mov    $0x0,%ecx
  801599:	8d 40 04             	lea    0x4(%eax),%eax
  80159c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80159f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8015a4:	eb 36                	jmp    8015dc <vprintfmt+0x348>
	if (lflag >= 2)
  8015a6:	83 f9 01             	cmp    $0x1,%ecx
  8015a9:	7f 17                	jg     8015c2 <vprintfmt+0x32e>
	else if (lflag)
  8015ab:	85 c9                	test   %ecx,%ecx
  8015ad:	74 6e                	je     80161d <vprintfmt+0x389>
		return va_arg(*ap, long);
  8015af:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b2:	8b 10                	mov    (%eax),%edx
  8015b4:	89 d0                	mov    %edx,%eax
  8015b6:	99                   	cltd   
  8015b7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015ba:	8d 49 04             	lea    0x4(%ecx),%ecx
  8015bd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8015c0:	eb 11                	jmp    8015d3 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8015c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c5:	8b 50 04             	mov    0x4(%eax),%edx
  8015c8:	8b 00                	mov    (%eax),%eax
  8015ca:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015cd:	8d 49 08             	lea    0x8(%ecx),%ecx
  8015d0:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8015d3:	89 d1                	mov    %edx,%ecx
  8015d5:	89 c2                	mov    %eax,%edx
            base = 8;
  8015d7:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8015dc:	83 ec 0c             	sub    $0xc,%esp
  8015df:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8015e3:	57                   	push   %edi
  8015e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8015e7:	50                   	push   %eax
  8015e8:	51                   	push   %ecx
  8015e9:	52                   	push   %edx
  8015ea:	89 da                	mov    %ebx,%edx
  8015ec:	89 f0                	mov    %esi,%eax
  8015ee:	e8 b6 fb ff ff       	call   8011a9 <printnum>
			break;
  8015f3:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8015f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015f9:	83 c7 01             	add    $0x1,%edi
  8015fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801600:	83 f8 25             	cmp    $0x25,%eax
  801603:	0f 84 a6 fc ff ff    	je     8012af <vprintfmt+0x1b>
			if (ch == '\0')
  801609:	85 c0                	test   %eax,%eax
  80160b:	0f 84 ce 00 00 00    	je     8016df <vprintfmt+0x44b>
			putch(ch, putdat);
  801611:	83 ec 08             	sub    $0x8,%esp
  801614:	53                   	push   %ebx
  801615:	50                   	push   %eax
  801616:	ff d6                	call   *%esi
  801618:	83 c4 10             	add    $0x10,%esp
  80161b:	eb dc                	jmp    8015f9 <vprintfmt+0x365>
		return va_arg(*ap, int);
  80161d:	8b 45 14             	mov    0x14(%ebp),%eax
  801620:	8b 10                	mov    (%eax),%edx
  801622:	89 d0                	mov    %edx,%eax
  801624:	99                   	cltd   
  801625:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801628:	8d 49 04             	lea    0x4(%ecx),%ecx
  80162b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80162e:	eb a3                	jmp    8015d3 <vprintfmt+0x33f>
			putch('0', putdat);
  801630:	83 ec 08             	sub    $0x8,%esp
  801633:	53                   	push   %ebx
  801634:	6a 30                	push   $0x30
  801636:	ff d6                	call   *%esi
			putch('x', putdat);
  801638:	83 c4 08             	add    $0x8,%esp
  80163b:	53                   	push   %ebx
  80163c:	6a 78                	push   $0x78
  80163e:	ff d6                	call   *%esi
			num = (unsigned long long)
  801640:	8b 45 14             	mov    0x14(%ebp),%eax
  801643:	8b 10                	mov    (%eax),%edx
  801645:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80164a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80164d:	8d 40 04             	lea    0x4(%eax),%eax
  801650:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801653:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801658:	eb 82                	jmp    8015dc <vprintfmt+0x348>
	if (lflag >= 2)
  80165a:	83 f9 01             	cmp    $0x1,%ecx
  80165d:	7f 1e                	jg     80167d <vprintfmt+0x3e9>
	else if (lflag)
  80165f:	85 c9                	test   %ecx,%ecx
  801661:	74 32                	je     801695 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  801663:	8b 45 14             	mov    0x14(%ebp),%eax
  801666:	8b 10                	mov    (%eax),%edx
  801668:	b9 00 00 00 00       	mov    $0x0,%ecx
  80166d:	8d 40 04             	lea    0x4(%eax),%eax
  801670:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801673:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  801678:	e9 5f ff ff ff       	jmp    8015dc <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80167d:	8b 45 14             	mov    0x14(%ebp),%eax
  801680:	8b 10                	mov    (%eax),%edx
  801682:	8b 48 04             	mov    0x4(%eax),%ecx
  801685:	8d 40 08             	lea    0x8(%eax),%eax
  801688:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80168b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  801690:	e9 47 ff ff ff       	jmp    8015dc <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  801695:	8b 45 14             	mov    0x14(%ebp),%eax
  801698:	8b 10                	mov    (%eax),%edx
  80169a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80169f:	8d 40 04             	lea    0x4(%eax),%eax
  8016a2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016a5:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8016aa:	e9 2d ff ff ff       	jmp    8015dc <vprintfmt+0x348>
			putch(ch, putdat);
  8016af:	83 ec 08             	sub    $0x8,%esp
  8016b2:	53                   	push   %ebx
  8016b3:	6a 25                	push   $0x25
  8016b5:	ff d6                	call   *%esi
			break;
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	e9 37 ff ff ff       	jmp    8015f6 <vprintfmt+0x362>
			putch('%', putdat);
  8016bf:	83 ec 08             	sub    $0x8,%esp
  8016c2:	53                   	push   %ebx
  8016c3:	6a 25                	push   $0x25
  8016c5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8016c7:	83 c4 10             	add    $0x10,%esp
  8016ca:	89 f8                	mov    %edi,%eax
  8016cc:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8016d0:	74 05                	je     8016d7 <vprintfmt+0x443>
  8016d2:	83 e8 01             	sub    $0x1,%eax
  8016d5:	eb f5                	jmp    8016cc <vprintfmt+0x438>
  8016d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016da:	e9 17 ff ff ff       	jmp    8015f6 <vprintfmt+0x362>
}
  8016df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e2:	5b                   	pop    %ebx
  8016e3:	5e                   	pop    %esi
  8016e4:	5f                   	pop    %edi
  8016e5:	5d                   	pop    %ebp
  8016e6:	c3                   	ret    

008016e7 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8016e7:	f3 0f 1e fb          	endbr32 
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	83 ec 18             	sub    $0x18,%esp
  8016f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8016f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016fa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8016fe:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801701:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801708:	85 c0                	test   %eax,%eax
  80170a:	74 26                	je     801732 <vsnprintf+0x4b>
  80170c:	85 d2                	test   %edx,%edx
  80170e:	7e 22                	jle    801732 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801710:	ff 75 14             	pushl  0x14(%ebp)
  801713:	ff 75 10             	pushl  0x10(%ebp)
  801716:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801719:	50                   	push   %eax
  80171a:	68 52 12 80 00       	push   $0x801252
  80171f:	e8 70 fb ff ff       	call   801294 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801724:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801727:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80172a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80172d:	83 c4 10             	add    $0x10,%esp
}
  801730:	c9                   	leave  
  801731:	c3                   	ret    
		return -E_INVAL;
  801732:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801737:	eb f7                	jmp    801730 <vsnprintf+0x49>

00801739 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801739:	f3 0f 1e fb          	endbr32 
  80173d:	55                   	push   %ebp
  80173e:	89 e5                	mov    %esp,%ebp
  801740:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801743:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801746:	50                   	push   %eax
  801747:	ff 75 10             	pushl  0x10(%ebp)
  80174a:	ff 75 0c             	pushl  0xc(%ebp)
  80174d:	ff 75 08             	pushl  0x8(%ebp)
  801750:	e8 92 ff ff ff       	call   8016e7 <vsnprintf>
	va_end(ap);

	return rc;
}
  801755:	c9                   	leave  
  801756:	c3                   	ret    

00801757 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801757:	f3 0f 1e fb          	endbr32 
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801761:	b8 00 00 00 00       	mov    $0x0,%eax
  801766:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80176a:	74 05                	je     801771 <strlen+0x1a>
		n++;
  80176c:	83 c0 01             	add    $0x1,%eax
  80176f:	eb f5                	jmp    801766 <strlen+0xf>
	return n;
}
  801771:	5d                   	pop    %ebp
  801772:	c3                   	ret    

00801773 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801773:	f3 0f 1e fb          	endbr32 
  801777:	55                   	push   %ebp
  801778:	89 e5                	mov    %esp,%ebp
  80177a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80177d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801780:	b8 00 00 00 00       	mov    $0x0,%eax
  801785:	39 d0                	cmp    %edx,%eax
  801787:	74 0d                	je     801796 <strnlen+0x23>
  801789:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80178d:	74 05                	je     801794 <strnlen+0x21>
		n++;
  80178f:	83 c0 01             	add    $0x1,%eax
  801792:	eb f1                	jmp    801785 <strnlen+0x12>
  801794:	89 c2                	mov    %eax,%edx
	return n;
}
  801796:	89 d0                	mov    %edx,%eax
  801798:	5d                   	pop    %ebp
  801799:	c3                   	ret    

0080179a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80179a:	f3 0f 1e fb          	endbr32 
  80179e:	55                   	push   %ebp
  80179f:	89 e5                	mov    %esp,%ebp
  8017a1:	53                   	push   %ebx
  8017a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8017a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ad:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8017b1:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8017b4:	83 c0 01             	add    $0x1,%eax
  8017b7:	84 d2                	test   %dl,%dl
  8017b9:	75 f2                	jne    8017ad <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8017bb:	89 c8                	mov    %ecx,%eax
  8017bd:	5b                   	pop    %ebx
  8017be:	5d                   	pop    %ebp
  8017bf:	c3                   	ret    

008017c0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017c0:	f3 0f 1e fb          	endbr32 
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	53                   	push   %ebx
  8017c8:	83 ec 10             	sub    $0x10,%esp
  8017cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8017ce:	53                   	push   %ebx
  8017cf:	e8 83 ff ff ff       	call   801757 <strlen>
  8017d4:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8017d7:	ff 75 0c             	pushl  0xc(%ebp)
  8017da:	01 d8                	add    %ebx,%eax
  8017dc:	50                   	push   %eax
  8017dd:	e8 b8 ff ff ff       	call   80179a <strcpy>
	return dst;
}
  8017e2:	89 d8                	mov    %ebx,%eax
  8017e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e7:	c9                   	leave  
  8017e8:	c3                   	ret    

008017e9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8017e9:	f3 0f 1e fb          	endbr32 
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	56                   	push   %esi
  8017f1:	53                   	push   %ebx
  8017f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8017f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f8:	89 f3                	mov    %esi,%ebx
  8017fa:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017fd:	89 f0                	mov    %esi,%eax
  8017ff:	39 d8                	cmp    %ebx,%eax
  801801:	74 11                	je     801814 <strncpy+0x2b>
		*dst++ = *src;
  801803:	83 c0 01             	add    $0x1,%eax
  801806:	0f b6 0a             	movzbl (%edx),%ecx
  801809:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80180c:	80 f9 01             	cmp    $0x1,%cl
  80180f:	83 da ff             	sbb    $0xffffffff,%edx
  801812:	eb eb                	jmp    8017ff <strncpy+0x16>
	}
	return ret;
}
  801814:	89 f0                	mov    %esi,%eax
  801816:	5b                   	pop    %ebx
  801817:	5e                   	pop    %esi
  801818:	5d                   	pop    %ebp
  801819:	c3                   	ret    

0080181a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80181a:	f3 0f 1e fb          	endbr32 
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	56                   	push   %esi
  801822:	53                   	push   %ebx
  801823:	8b 75 08             	mov    0x8(%ebp),%esi
  801826:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801829:	8b 55 10             	mov    0x10(%ebp),%edx
  80182c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80182e:	85 d2                	test   %edx,%edx
  801830:	74 21                	je     801853 <strlcpy+0x39>
  801832:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801836:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801838:	39 c2                	cmp    %eax,%edx
  80183a:	74 14                	je     801850 <strlcpy+0x36>
  80183c:	0f b6 19             	movzbl (%ecx),%ebx
  80183f:	84 db                	test   %bl,%bl
  801841:	74 0b                	je     80184e <strlcpy+0x34>
			*dst++ = *src++;
  801843:	83 c1 01             	add    $0x1,%ecx
  801846:	83 c2 01             	add    $0x1,%edx
  801849:	88 5a ff             	mov    %bl,-0x1(%edx)
  80184c:	eb ea                	jmp    801838 <strlcpy+0x1e>
  80184e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801850:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801853:	29 f0                	sub    %esi,%eax
}
  801855:	5b                   	pop    %ebx
  801856:	5e                   	pop    %esi
  801857:	5d                   	pop    %ebp
  801858:	c3                   	ret    

00801859 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801859:	f3 0f 1e fb          	endbr32 
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
  801860:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801863:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801866:	0f b6 01             	movzbl (%ecx),%eax
  801869:	84 c0                	test   %al,%al
  80186b:	74 0c                	je     801879 <strcmp+0x20>
  80186d:	3a 02                	cmp    (%edx),%al
  80186f:	75 08                	jne    801879 <strcmp+0x20>
		p++, q++;
  801871:	83 c1 01             	add    $0x1,%ecx
  801874:	83 c2 01             	add    $0x1,%edx
  801877:	eb ed                	jmp    801866 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801879:	0f b6 c0             	movzbl %al,%eax
  80187c:	0f b6 12             	movzbl (%edx),%edx
  80187f:	29 d0                	sub    %edx,%eax
}
  801881:	5d                   	pop    %ebp
  801882:	c3                   	ret    

00801883 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801883:	f3 0f 1e fb          	endbr32 
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	53                   	push   %ebx
  80188b:	8b 45 08             	mov    0x8(%ebp),%eax
  80188e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801891:	89 c3                	mov    %eax,%ebx
  801893:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801896:	eb 06                	jmp    80189e <strncmp+0x1b>
		n--, p++, q++;
  801898:	83 c0 01             	add    $0x1,%eax
  80189b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80189e:	39 d8                	cmp    %ebx,%eax
  8018a0:	74 16                	je     8018b8 <strncmp+0x35>
  8018a2:	0f b6 08             	movzbl (%eax),%ecx
  8018a5:	84 c9                	test   %cl,%cl
  8018a7:	74 04                	je     8018ad <strncmp+0x2a>
  8018a9:	3a 0a                	cmp    (%edx),%cl
  8018ab:	74 eb                	je     801898 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8018ad:	0f b6 00             	movzbl (%eax),%eax
  8018b0:	0f b6 12             	movzbl (%edx),%edx
  8018b3:	29 d0                	sub    %edx,%eax
}
  8018b5:	5b                   	pop    %ebx
  8018b6:	5d                   	pop    %ebp
  8018b7:	c3                   	ret    
		return 0;
  8018b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018bd:	eb f6                	jmp    8018b5 <strncmp+0x32>

008018bf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8018bf:	f3 0f 1e fb          	endbr32 
  8018c3:	55                   	push   %ebp
  8018c4:	89 e5                	mov    %esp,%ebp
  8018c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018cd:	0f b6 10             	movzbl (%eax),%edx
  8018d0:	84 d2                	test   %dl,%dl
  8018d2:	74 09                	je     8018dd <strchr+0x1e>
		if (*s == c)
  8018d4:	38 ca                	cmp    %cl,%dl
  8018d6:	74 0a                	je     8018e2 <strchr+0x23>
	for (; *s; s++)
  8018d8:	83 c0 01             	add    $0x1,%eax
  8018db:	eb f0                	jmp    8018cd <strchr+0xe>
			return (char *) s;
	return 0;
  8018dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018e2:	5d                   	pop    %ebp
  8018e3:	c3                   	ret    

008018e4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8018e4:	f3 0f 1e fb          	endbr32 
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ee:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018f2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8018f5:	38 ca                	cmp    %cl,%dl
  8018f7:	74 09                	je     801902 <strfind+0x1e>
  8018f9:	84 d2                	test   %dl,%dl
  8018fb:	74 05                	je     801902 <strfind+0x1e>
	for (; *s; s++)
  8018fd:	83 c0 01             	add    $0x1,%eax
  801900:	eb f0                	jmp    8018f2 <strfind+0xe>
			break;
	return (char *) s;
}
  801902:	5d                   	pop    %ebp
  801903:	c3                   	ret    

00801904 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801904:	f3 0f 1e fb          	endbr32 
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	57                   	push   %edi
  80190c:	56                   	push   %esi
  80190d:	53                   	push   %ebx
  80190e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801911:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801914:	85 c9                	test   %ecx,%ecx
  801916:	74 31                	je     801949 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801918:	89 f8                	mov    %edi,%eax
  80191a:	09 c8                	or     %ecx,%eax
  80191c:	a8 03                	test   $0x3,%al
  80191e:	75 23                	jne    801943 <memset+0x3f>
		c &= 0xFF;
  801920:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801924:	89 d3                	mov    %edx,%ebx
  801926:	c1 e3 08             	shl    $0x8,%ebx
  801929:	89 d0                	mov    %edx,%eax
  80192b:	c1 e0 18             	shl    $0x18,%eax
  80192e:	89 d6                	mov    %edx,%esi
  801930:	c1 e6 10             	shl    $0x10,%esi
  801933:	09 f0                	or     %esi,%eax
  801935:	09 c2                	or     %eax,%edx
  801937:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801939:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80193c:	89 d0                	mov    %edx,%eax
  80193e:	fc                   	cld    
  80193f:	f3 ab                	rep stos %eax,%es:(%edi)
  801941:	eb 06                	jmp    801949 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801943:	8b 45 0c             	mov    0xc(%ebp),%eax
  801946:	fc                   	cld    
  801947:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801949:	89 f8                	mov    %edi,%eax
  80194b:	5b                   	pop    %ebx
  80194c:	5e                   	pop    %esi
  80194d:	5f                   	pop    %edi
  80194e:	5d                   	pop    %ebp
  80194f:	c3                   	ret    

00801950 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801950:	f3 0f 1e fb          	endbr32 
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	57                   	push   %edi
  801958:	56                   	push   %esi
  801959:	8b 45 08             	mov    0x8(%ebp),%eax
  80195c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80195f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801962:	39 c6                	cmp    %eax,%esi
  801964:	73 32                	jae    801998 <memmove+0x48>
  801966:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801969:	39 c2                	cmp    %eax,%edx
  80196b:	76 2b                	jbe    801998 <memmove+0x48>
		s += n;
		d += n;
  80196d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801970:	89 fe                	mov    %edi,%esi
  801972:	09 ce                	or     %ecx,%esi
  801974:	09 d6                	or     %edx,%esi
  801976:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80197c:	75 0e                	jne    80198c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80197e:	83 ef 04             	sub    $0x4,%edi
  801981:	8d 72 fc             	lea    -0x4(%edx),%esi
  801984:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801987:	fd                   	std    
  801988:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80198a:	eb 09                	jmp    801995 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80198c:	83 ef 01             	sub    $0x1,%edi
  80198f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801992:	fd                   	std    
  801993:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801995:	fc                   	cld    
  801996:	eb 1a                	jmp    8019b2 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801998:	89 c2                	mov    %eax,%edx
  80199a:	09 ca                	or     %ecx,%edx
  80199c:	09 f2                	or     %esi,%edx
  80199e:	f6 c2 03             	test   $0x3,%dl
  8019a1:	75 0a                	jne    8019ad <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8019a3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8019a6:	89 c7                	mov    %eax,%edi
  8019a8:	fc                   	cld    
  8019a9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019ab:	eb 05                	jmp    8019b2 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8019ad:	89 c7                	mov    %eax,%edi
  8019af:	fc                   	cld    
  8019b0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8019b2:	5e                   	pop    %esi
  8019b3:	5f                   	pop    %edi
  8019b4:	5d                   	pop    %ebp
  8019b5:	c3                   	ret    

008019b6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8019b6:	f3 0f 1e fb          	endbr32 
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8019c0:	ff 75 10             	pushl  0x10(%ebp)
  8019c3:	ff 75 0c             	pushl  0xc(%ebp)
  8019c6:	ff 75 08             	pushl  0x8(%ebp)
  8019c9:	e8 82 ff ff ff       	call   801950 <memmove>
}
  8019ce:	c9                   	leave  
  8019cf:	c3                   	ret    

008019d0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8019d0:	f3 0f 1e fb          	endbr32 
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	56                   	push   %esi
  8019d8:	53                   	push   %ebx
  8019d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019df:	89 c6                	mov    %eax,%esi
  8019e1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019e4:	39 f0                	cmp    %esi,%eax
  8019e6:	74 1c                	je     801a04 <memcmp+0x34>
		if (*s1 != *s2)
  8019e8:	0f b6 08             	movzbl (%eax),%ecx
  8019eb:	0f b6 1a             	movzbl (%edx),%ebx
  8019ee:	38 d9                	cmp    %bl,%cl
  8019f0:	75 08                	jne    8019fa <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8019f2:	83 c0 01             	add    $0x1,%eax
  8019f5:	83 c2 01             	add    $0x1,%edx
  8019f8:	eb ea                	jmp    8019e4 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8019fa:	0f b6 c1             	movzbl %cl,%eax
  8019fd:	0f b6 db             	movzbl %bl,%ebx
  801a00:	29 d8                	sub    %ebx,%eax
  801a02:	eb 05                	jmp    801a09 <memcmp+0x39>
	}

	return 0;
  801a04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a09:	5b                   	pop    %ebx
  801a0a:	5e                   	pop    %esi
  801a0b:	5d                   	pop    %ebp
  801a0c:	c3                   	ret    

00801a0d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a0d:	f3 0f 1e fb          	endbr32 
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	8b 45 08             	mov    0x8(%ebp),%eax
  801a17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a1a:	89 c2                	mov    %eax,%edx
  801a1c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a1f:	39 d0                	cmp    %edx,%eax
  801a21:	73 09                	jae    801a2c <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a23:	38 08                	cmp    %cl,(%eax)
  801a25:	74 05                	je     801a2c <memfind+0x1f>
	for (; s < ends; s++)
  801a27:	83 c0 01             	add    $0x1,%eax
  801a2a:	eb f3                	jmp    801a1f <memfind+0x12>
			break;
	return (void *) s;
}
  801a2c:	5d                   	pop    %ebp
  801a2d:	c3                   	ret    

00801a2e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a2e:	f3 0f 1e fb          	endbr32 
  801a32:	55                   	push   %ebp
  801a33:	89 e5                	mov    %esp,%ebp
  801a35:	57                   	push   %edi
  801a36:	56                   	push   %esi
  801a37:	53                   	push   %ebx
  801a38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a3e:	eb 03                	jmp    801a43 <strtol+0x15>
		s++;
  801a40:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801a43:	0f b6 01             	movzbl (%ecx),%eax
  801a46:	3c 20                	cmp    $0x20,%al
  801a48:	74 f6                	je     801a40 <strtol+0x12>
  801a4a:	3c 09                	cmp    $0x9,%al
  801a4c:	74 f2                	je     801a40 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801a4e:	3c 2b                	cmp    $0x2b,%al
  801a50:	74 2a                	je     801a7c <strtol+0x4e>
	int neg = 0;
  801a52:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801a57:	3c 2d                	cmp    $0x2d,%al
  801a59:	74 2b                	je     801a86 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a5b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a61:	75 0f                	jne    801a72 <strtol+0x44>
  801a63:	80 39 30             	cmpb   $0x30,(%ecx)
  801a66:	74 28                	je     801a90 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a68:	85 db                	test   %ebx,%ebx
  801a6a:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a6f:	0f 44 d8             	cmove  %eax,%ebx
  801a72:	b8 00 00 00 00       	mov    $0x0,%eax
  801a77:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801a7a:	eb 46                	jmp    801ac2 <strtol+0x94>
		s++;
  801a7c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801a7f:	bf 00 00 00 00       	mov    $0x0,%edi
  801a84:	eb d5                	jmp    801a5b <strtol+0x2d>
		s++, neg = 1;
  801a86:	83 c1 01             	add    $0x1,%ecx
  801a89:	bf 01 00 00 00       	mov    $0x1,%edi
  801a8e:	eb cb                	jmp    801a5b <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a90:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a94:	74 0e                	je     801aa4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801a96:	85 db                	test   %ebx,%ebx
  801a98:	75 d8                	jne    801a72 <strtol+0x44>
		s++, base = 8;
  801a9a:	83 c1 01             	add    $0x1,%ecx
  801a9d:	bb 08 00 00 00       	mov    $0x8,%ebx
  801aa2:	eb ce                	jmp    801a72 <strtol+0x44>
		s += 2, base = 16;
  801aa4:	83 c1 02             	add    $0x2,%ecx
  801aa7:	bb 10 00 00 00       	mov    $0x10,%ebx
  801aac:	eb c4                	jmp    801a72 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801aae:	0f be d2             	movsbl %dl,%edx
  801ab1:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801ab4:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ab7:	7d 3a                	jge    801af3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801ab9:	83 c1 01             	add    $0x1,%ecx
  801abc:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ac0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801ac2:	0f b6 11             	movzbl (%ecx),%edx
  801ac5:	8d 72 d0             	lea    -0x30(%edx),%esi
  801ac8:	89 f3                	mov    %esi,%ebx
  801aca:	80 fb 09             	cmp    $0x9,%bl
  801acd:	76 df                	jbe    801aae <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801acf:	8d 72 9f             	lea    -0x61(%edx),%esi
  801ad2:	89 f3                	mov    %esi,%ebx
  801ad4:	80 fb 19             	cmp    $0x19,%bl
  801ad7:	77 08                	ja     801ae1 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801ad9:	0f be d2             	movsbl %dl,%edx
  801adc:	83 ea 57             	sub    $0x57,%edx
  801adf:	eb d3                	jmp    801ab4 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801ae1:	8d 72 bf             	lea    -0x41(%edx),%esi
  801ae4:	89 f3                	mov    %esi,%ebx
  801ae6:	80 fb 19             	cmp    $0x19,%bl
  801ae9:	77 08                	ja     801af3 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801aeb:	0f be d2             	movsbl %dl,%edx
  801aee:	83 ea 37             	sub    $0x37,%edx
  801af1:	eb c1                	jmp    801ab4 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801af3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801af7:	74 05                	je     801afe <strtol+0xd0>
		*endptr = (char *) s;
  801af9:	8b 75 0c             	mov    0xc(%ebp),%esi
  801afc:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801afe:	89 c2                	mov    %eax,%edx
  801b00:	f7 da                	neg    %edx
  801b02:	85 ff                	test   %edi,%edi
  801b04:	0f 45 c2             	cmovne %edx,%eax
}
  801b07:	5b                   	pop    %ebx
  801b08:	5e                   	pop    %esi
  801b09:	5f                   	pop    %edi
  801b0a:	5d                   	pop    %ebp
  801b0b:	c3                   	ret    

00801b0c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b0c:	f3 0f 1e fb          	endbr32 
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	56                   	push   %esi
  801b14:	53                   	push   %ebx
  801b15:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b18:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1b:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b25:	0f 44 c2             	cmove  %edx,%eax
  801b28:	83 ec 0c             	sub    $0xc,%esp
  801b2b:	50                   	push   %eax
  801b2c:	e8 1b e8 ff ff       	call   80034c <sys_ipc_recv>
  801b31:	83 c4 10             	add    $0x10,%esp
  801b34:	85 c0                	test   %eax,%eax
  801b36:	78 24                	js     801b5c <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801b38:	85 f6                	test   %esi,%esi
  801b3a:	74 0a                	je     801b46 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801b3c:	a1 04 40 80 00       	mov    0x804004,%eax
  801b41:	8b 40 78             	mov    0x78(%eax),%eax
  801b44:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801b46:	85 db                	test   %ebx,%ebx
  801b48:	74 0a                	je     801b54 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801b4a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b4f:	8b 40 74             	mov    0x74(%eax),%eax
  801b52:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801b54:	a1 04 40 80 00       	mov    0x804004,%eax
  801b59:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b5f:	5b                   	pop    %ebx
  801b60:	5e                   	pop    %esi
  801b61:	5d                   	pop    %ebp
  801b62:	c3                   	ret    

00801b63 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b63:	f3 0f 1e fb          	endbr32 
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	57                   	push   %edi
  801b6b:	56                   	push   %esi
  801b6c:	53                   	push   %ebx
  801b6d:	83 ec 1c             	sub    $0x1c,%esp
  801b70:	8b 45 10             	mov    0x10(%ebp),%eax
  801b73:	85 c0                	test   %eax,%eax
  801b75:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b7a:	0f 45 d0             	cmovne %eax,%edx
  801b7d:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801b7f:	be 01 00 00 00       	mov    $0x1,%esi
  801b84:	eb 1f                	jmp    801ba5 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801b86:	e8 d2 e5 ff ff       	call   80015d <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801b8b:	83 c3 01             	add    $0x1,%ebx
  801b8e:	39 de                	cmp    %ebx,%esi
  801b90:	7f f4                	jg     801b86 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801b92:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801b94:	83 fe 11             	cmp    $0x11,%esi
  801b97:	b8 01 00 00 00       	mov    $0x1,%eax
  801b9c:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801b9f:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801ba3:	75 1c                	jne    801bc1 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801ba5:	ff 75 14             	pushl  0x14(%ebp)
  801ba8:	57                   	push   %edi
  801ba9:	ff 75 0c             	pushl  0xc(%ebp)
  801bac:	ff 75 08             	pushl  0x8(%ebp)
  801baf:	e8 71 e7 ff ff       	call   800325 <sys_ipc_try_send>
  801bb4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801bb7:	83 c4 10             	add    $0x10,%esp
  801bba:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bbf:	eb cd                	jmp    801b8e <ipc_send+0x2b>
}
  801bc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc4:	5b                   	pop    %ebx
  801bc5:	5e                   	pop    %esi
  801bc6:	5f                   	pop    %edi
  801bc7:	5d                   	pop    %ebp
  801bc8:	c3                   	ret    

00801bc9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bc9:	f3 0f 1e fb          	endbr32 
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bd3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bd8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bdb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801be1:	8b 52 50             	mov    0x50(%edx),%edx
  801be4:	39 ca                	cmp    %ecx,%edx
  801be6:	74 11                	je     801bf9 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801be8:	83 c0 01             	add    $0x1,%eax
  801beb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bf0:	75 e6                	jne    801bd8 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801bf2:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf7:	eb 0b                	jmp    801c04 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801bf9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bfc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c01:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c04:	5d                   	pop    %ebp
  801c05:	c3                   	ret    

00801c06 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c06:	f3 0f 1e fb          	endbr32 
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c10:	89 c2                	mov    %eax,%edx
  801c12:	c1 ea 16             	shr    $0x16,%edx
  801c15:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c1c:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c21:	f6 c1 01             	test   $0x1,%cl
  801c24:	74 1c                	je     801c42 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c26:	c1 e8 0c             	shr    $0xc,%eax
  801c29:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c30:	a8 01                	test   $0x1,%al
  801c32:	74 0e                	je     801c42 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c34:	c1 e8 0c             	shr    $0xc,%eax
  801c37:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c3e:	ef 
  801c3f:	0f b7 d2             	movzwl %dx,%edx
}
  801c42:	89 d0                	mov    %edx,%eax
  801c44:	5d                   	pop    %ebp
  801c45:	c3                   	ret    
  801c46:	66 90                	xchg   %ax,%ax
  801c48:	66 90                	xchg   %ax,%ax
  801c4a:	66 90                	xchg   %ax,%ax
  801c4c:	66 90                	xchg   %ax,%ax
  801c4e:	66 90                	xchg   %ax,%ax

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
