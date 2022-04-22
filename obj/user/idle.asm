
obj/user/idle:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003d:	c7 05 00 30 80 00 00 	movl   $0x801f00,0x803000
  800044:	1f 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800047:	e8 21 01 00 00       	call   80016d <sys_yield>
  80004c:	eb f9                	jmp    800047 <umain+0x14>

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	f3 0f 1e fb          	endbr32 
  800052:	55                   	push   %ebp
  800053:	89 e5                	mov    %esp,%ebp
  800055:	56                   	push   %esi
  800056:	53                   	push   %ebx
  800057:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005d:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800064:	00 00 00 
    envid_t envid = sys_getenvid();
  800067:	e8 de 00 00 00       	call   80014a <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  80006c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800071:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800074:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800079:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 db                	test   %ebx,%ebx
  800080:	7e 07                	jle    800089 <libmain+0x3b>
		binaryname = argv[0];
  800082:	8b 06                	mov    (%esi),%eax
  800084:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800089:	83 ec 08             	sub    $0x8,%esp
  80008c:	56                   	push   %esi
  80008d:	53                   	push   %ebx
  80008e:	e8 a0 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800093:	e8 0a 00 00 00       	call   8000a2 <exit>
}
  800098:	83 c4 10             	add    $0x10,%esp
  80009b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009e:	5b                   	pop    %ebx
  80009f:	5e                   	pop    %esi
  8000a0:	5d                   	pop    %ebp
  8000a1:	c3                   	ret    

008000a2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a2:	f3 0f 1e fb          	endbr32 
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ac:	e8 df 04 00 00       	call   800590 <close_all>
	sys_env_destroy(0);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	6a 00                	push   $0x0
  8000b6:	e8 4a 00 00 00       	call   800105 <sys_env_destroy>
}
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c0:	f3 0f 1e fb          	endbr32 
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d5:	89 c3                	mov    %eax,%ebx
  8000d7:	89 c7                	mov    %eax,%edi
  8000d9:	89 c6                	mov    %eax,%esi
  8000db:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000dd:	5b                   	pop    %ebx
  8000de:	5e                   	pop    %esi
  8000df:	5f                   	pop    %edi
  8000e0:	5d                   	pop    %ebp
  8000e1:	c3                   	ret    

008000e2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e2:	f3 0f 1e fb          	endbr32 
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	57                   	push   %edi
  8000ea:	56                   	push   %esi
  8000eb:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f6:	89 d1                	mov    %edx,%ecx
  8000f8:	89 d3                	mov    %edx,%ebx
  8000fa:	89 d7                	mov    %edx,%edi
  8000fc:	89 d6                	mov    %edx,%esi
  8000fe:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5f                   	pop    %edi
  800103:	5d                   	pop    %ebp
  800104:	c3                   	ret    

00800105 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800105:	f3 0f 1e fb          	endbr32 
  800109:	55                   	push   %ebp
  80010a:	89 e5                	mov    %esp,%ebp
  80010c:	57                   	push   %edi
  80010d:	56                   	push   %esi
  80010e:	53                   	push   %ebx
  80010f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800112:	b9 00 00 00 00       	mov    $0x0,%ecx
  800117:	8b 55 08             	mov    0x8(%ebp),%edx
  80011a:	b8 03 00 00 00       	mov    $0x3,%eax
  80011f:	89 cb                	mov    %ecx,%ebx
  800121:	89 cf                	mov    %ecx,%edi
  800123:	89 ce                	mov    %ecx,%esi
  800125:	cd 30                	int    $0x30
	if(check && ret > 0)
  800127:	85 c0                	test   %eax,%eax
  800129:	7f 08                	jg     800133 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800133:	83 ec 0c             	sub    $0xc,%esp
  800136:	50                   	push   %eax
  800137:	6a 03                	push   $0x3
  800139:	68 0f 1f 80 00       	push   $0x801f0f
  80013e:	6a 23                	push   $0x23
  800140:	68 2c 1f 80 00       	push   $0x801f2c
  800145:	e8 9c 0f 00 00       	call   8010e6 <_panic>

0080014a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014a:	f3 0f 1e fb          	endbr32 
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	57                   	push   %edi
  800152:	56                   	push   %esi
  800153:	53                   	push   %ebx
	asm volatile("int %1\n"
  800154:	ba 00 00 00 00       	mov    $0x0,%edx
  800159:	b8 02 00 00 00       	mov    $0x2,%eax
  80015e:	89 d1                	mov    %edx,%ecx
  800160:	89 d3                	mov    %edx,%ebx
  800162:	89 d7                	mov    %edx,%edi
  800164:	89 d6                	mov    %edx,%esi
  800166:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800168:	5b                   	pop    %ebx
  800169:	5e                   	pop    %esi
  80016a:	5f                   	pop    %edi
  80016b:	5d                   	pop    %ebp
  80016c:	c3                   	ret    

0080016d <sys_yield>:

void
sys_yield(void)
{
  80016d:	f3 0f 1e fb          	endbr32 
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	57                   	push   %edi
  800175:	56                   	push   %esi
  800176:	53                   	push   %ebx
	asm volatile("int %1\n"
  800177:	ba 00 00 00 00       	mov    $0x0,%edx
  80017c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800181:	89 d1                	mov    %edx,%ecx
  800183:	89 d3                	mov    %edx,%ebx
  800185:	89 d7                	mov    %edx,%edi
  800187:	89 d6                	mov    %edx,%esi
  800189:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80018b:	5b                   	pop    %ebx
  80018c:	5e                   	pop    %esi
  80018d:	5f                   	pop    %edi
  80018e:	5d                   	pop    %ebp
  80018f:	c3                   	ret    

00800190 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800190:	f3 0f 1e fb          	endbr32 
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	57                   	push   %edi
  800198:	56                   	push   %esi
  800199:	53                   	push   %ebx
  80019a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80019d:	be 00 00 00 00       	mov    $0x0,%esi
  8001a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a8:	b8 04 00 00 00       	mov    $0x4,%eax
  8001ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b0:	89 f7                	mov    %esi,%edi
  8001b2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	7f 08                	jg     8001c0 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bb:	5b                   	pop    %ebx
  8001bc:	5e                   	pop    %esi
  8001bd:	5f                   	pop    %edi
  8001be:	5d                   	pop    %ebp
  8001bf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	50                   	push   %eax
  8001c4:	6a 04                	push   $0x4
  8001c6:	68 0f 1f 80 00       	push   $0x801f0f
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 2c 1f 80 00       	push   $0x801f2c
  8001d2:	e8 0f 0f 00 00       	call   8010e6 <_panic>

008001d7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d7:	f3 0f 1e fb          	endbr32 
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7f 08                	jg     800206 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 05                	push   $0x5
  80020c:	68 0f 1f 80 00       	push   $0x801f0f
  800211:	6a 23                	push   $0x23
  800213:	68 2c 1f 80 00       	push   $0x801f2c
  800218:	e8 c9 0e 00 00       	call   8010e6 <_panic>

0080021d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80021d:	f3 0f 1e fb          	endbr32 
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80022a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022f:	8b 55 08             	mov    0x8(%ebp),%edx
  800232:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800235:	b8 06 00 00 00       	mov    $0x6,%eax
  80023a:	89 df                	mov    %ebx,%edi
  80023c:	89 de                	mov    %ebx,%esi
  80023e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7f 08                	jg     80024c <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800244:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800247:	5b                   	pop    %ebx
  800248:	5e                   	pop    %esi
  800249:	5f                   	pop    %edi
  80024a:	5d                   	pop    %ebp
  80024b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	50                   	push   %eax
  800250:	6a 06                	push   $0x6
  800252:	68 0f 1f 80 00       	push   $0x801f0f
  800257:	6a 23                	push   $0x23
  800259:	68 2c 1f 80 00       	push   $0x801f2c
  80025e:	e8 83 0e 00 00       	call   8010e6 <_panic>

00800263 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800263:	f3 0f 1e fb          	endbr32 
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027b:	b8 08 00 00 00       	mov    $0x8,%eax
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7f 08                	jg     800292 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80028a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028d:	5b                   	pop    %ebx
  80028e:	5e                   	pop    %esi
  80028f:	5f                   	pop    %edi
  800290:	5d                   	pop    %ebp
  800291:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 08                	push   $0x8
  800298:	68 0f 1f 80 00       	push   $0x801f0f
  80029d:	6a 23                	push   $0x23
  80029f:	68 2c 1f 80 00       	push   $0x801f2c
  8002a4:	e8 3d 0e 00 00       	call   8010e6 <_panic>

008002a9 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002a9:	f3 0f 1e fb          	endbr32 
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	57                   	push   %edi
  8002b1:	56                   	push   %esi
  8002b2:	53                   	push   %ebx
  8002b3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c1:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c6:	89 df                	mov    %ebx,%edi
  8002c8:	89 de                	mov    %ebx,%esi
  8002ca:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002cc:	85 c0                	test   %eax,%eax
  8002ce:	7f 08                	jg     8002d8 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d3:	5b                   	pop    %ebx
  8002d4:	5e                   	pop    %esi
  8002d5:	5f                   	pop    %edi
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	50                   	push   %eax
  8002dc:	6a 09                	push   $0x9
  8002de:	68 0f 1f 80 00       	push   $0x801f0f
  8002e3:	6a 23                	push   $0x23
  8002e5:	68 2c 1f 80 00       	push   $0x801f2c
  8002ea:	e8 f7 0d 00 00       	call   8010e6 <_panic>

008002ef <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ef:	f3 0f 1e fb          	endbr32 
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
  8002f9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800301:	8b 55 08             	mov    0x8(%ebp),%edx
  800304:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800307:	b8 0a 00 00 00       	mov    $0xa,%eax
  80030c:	89 df                	mov    %ebx,%edi
  80030e:	89 de                	mov    %ebx,%esi
  800310:	cd 30                	int    $0x30
	if(check && ret > 0)
  800312:	85 c0                	test   %eax,%eax
  800314:	7f 08                	jg     80031e <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800316:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800319:	5b                   	pop    %ebx
  80031a:	5e                   	pop    %esi
  80031b:	5f                   	pop    %edi
  80031c:	5d                   	pop    %ebp
  80031d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80031e:	83 ec 0c             	sub    $0xc,%esp
  800321:	50                   	push   %eax
  800322:	6a 0a                	push   $0xa
  800324:	68 0f 1f 80 00       	push   $0x801f0f
  800329:	6a 23                	push   $0x23
  80032b:	68 2c 1f 80 00       	push   $0x801f2c
  800330:	e8 b1 0d 00 00       	call   8010e6 <_panic>

00800335 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800335:	f3 0f 1e fb          	endbr32 
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	57                   	push   %edi
  80033d:	56                   	push   %esi
  80033e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80033f:	8b 55 08             	mov    0x8(%ebp),%edx
  800342:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800345:	b8 0c 00 00 00       	mov    $0xc,%eax
  80034a:	be 00 00 00 00       	mov    $0x0,%esi
  80034f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800352:	8b 7d 14             	mov    0x14(%ebp),%edi
  800355:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800357:	5b                   	pop    %ebx
  800358:	5e                   	pop    %esi
  800359:	5f                   	pop    %edi
  80035a:	5d                   	pop    %ebp
  80035b:	c3                   	ret    

0080035c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80035c:	f3 0f 1e fb          	endbr32 
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	57                   	push   %edi
  800364:	56                   	push   %esi
  800365:	53                   	push   %ebx
  800366:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800369:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036e:	8b 55 08             	mov    0x8(%ebp),%edx
  800371:	b8 0d 00 00 00       	mov    $0xd,%eax
  800376:	89 cb                	mov    %ecx,%ebx
  800378:	89 cf                	mov    %ecx,%edi
  80037a:	89 ce                	mov    %ecx,%esi
  80037c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80037e:	85 c0                	test   %eax,%eax
  800380:	7f 08                	jg     80038a <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800382:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800385:	5b                   	pop    %ebx
  800386:	5e                   	pop    %esi
  800387:	5f                   	pop    %edi
  800388:	5d                   	pop    %ebp
  800389:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80038a:	83 ec 0c             	sub    $0xc,%esp
  80038d:	50                   	push   %eax
  80038e:	6a 0d                	push   $0xd
  800390:	68 0f 1f 80 00       	push   $0x801f0f
  800395:	6a 23                	push   $0x23
  800397:	68 2c 1f 80 00       	push   $0x801f2c
  80039c:	e8 45 0d 00 00       	call   8010e6 <_panic>

008003a1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003a1:	f3 0f 1e fb          	endbr32 
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ab:	05 00 00 00 30       	add    $0x30000000,%eax
  8003b0:	c1 e8 0c             	shr    $0xc,%eax
}
  8003b3:	5d                   	pop    %ebp
  8003b4:	c3                   	ret    

008003b5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003b5:	f3 0f 1e fb          	endbr32 
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bf:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003c9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003ce:	5d                   	pop    %ebp
  8003cf:	c3                   	ret    

008003d0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003d0:	f3 0f 1e fb          	endbr32 
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
  8003d7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003dc:	89 c2                	mov    %eax,%edx
  8003de:	c1 ea 16             	shr    $0x16,%edx
  8003e1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e8:	f6 c2 01             	test   $0x1,%dl
  8003eb:	74 2d                	je     80041a <fd_alloc+0x4a>
  8003ed:	89 c2                	mov    %eax,%edx
  8003ef:	c1 ea 0c             	shr    $0xc,%edx
  8003f2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f9:	f6 c2 01             	test   $0x1,%dl
  8003fc:	74 1c                	je     80041a <fd_alloc+0x4a>
  8003fe:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800403:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800408:	75 d2                	jne    8003dc <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80040a:	8b 45 08             	mov    0x8(%ebp),%eax
  80040d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800413:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800418:	eb 0a                	jmp    800424 <fd_alloc+0x54>
			*fd_store = fd;
  80041a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80041f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800424:	5d                   	pop    %ebp
  800425:	c3                   	ret    

00800426 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800426:	f3 0f 1e fb          	endbr32 
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800430:	83 f8 1f             	cmp    $0x1f,%eax
  800433:	77 30                	ja     800465 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800435:	c1 e0 0c             	shl    $0xc,%eax
  800438:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80043d:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800443:	f6 c2 01             	test   $0x1,%dl
  800446:	74 24                	je     80046c <fd_lookup+0x46>
  800448:	89 c2                	mov    %eax,%edx
  80044a:	c1 ea 0c             	shr    $0xc,%edx
  80044d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800454:	f6 c2 01             	test   $0x1,%dl
  800457:	74 1a                	je     800473 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800459:	8b 55 0c             	mov    0xc(%ebp),%edx
  80045c:	89 02                	mov    %eax,(%edx)
	return 0;
  80045e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800463:	5d                   	pop    %ebp
  800464:	c3                   	ret    
		return -E_INVAL;
  800465:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80046a:	eb f7                	jmp    800463 <fd_lookup+0x3d>
		return -E_INVAL;
  80046c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800471:	eb f0                	jmp    800463 <fd_lookup+0x3d>
  800473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800478:	eb e9                	jmp    800463 <fd_lookup+0x3d>

0080047a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80047a:	f3 0f 1e fb          	endbr32 
  80047e:	55                   	push   %ebp
  80047f:	89 e5                	mov    %esp,%ebp
  800481:	83 ec 08             	sub    $0x8,%esp
  800484:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800487:	ba b8 1f 80 00       	mov    $0x801fb8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80048c:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800491:	39 08                	cmp    %ecx,(%eax)
  800493:	74 33                	je     8004c8 <dev_lookup+0x4e>
  800495:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800498:	8b 02                	mov    (%edx),%eax
  80049a:	85 c0                	test   %eax,%eax
  80049c:	75 f3                	jne    800491 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80049e:	a1 04 40 80 00       	mov    0x804004,%eax
  8004a3:	8b 40 48             	mov    0x48(%eax),%eax
  8004a6:	83 ec 04             	sub    $0x4,%esp
  8004a9:	51                   	push   %ecx
  8004aa:	50                   	push   %eax
  8004ab:	68 3c 1f 80 00       	push   $0x801f3c
  8004b0:	e8 18 0d 00 00       	call   8011cd <cprintf>
	*dev = 0;
  8004b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004c6:	c9                   	leave  
  8004c7:	c3                   	ret    
			*dev = devtab[i];
  8004c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004cb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d2:	eb f2                	jmp    8004c6 <dev_lookup+0x4c>

008004d4 <fd_close>:
{
  8004d4:	f3 0f 1e fb          	endbr32 
  8004d8:	55                   	push   %ebp
  8004d9:	89 e5                	mov    %esp,%ebp
  8004db:	57                   	push   %edi
  8004dc:	56                   	push   %esi
  8004dd:	53                   	push   %ebx
  8004de:	83 ec 24             	sub    $0x24,%esp
  8004e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004e7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004ea:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004eb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004f1:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004f4:	50                   	push   %eax
  8004f5:	e8 2c ff ff ff       	call   800426 <fd_lookup>
  8004fa:	89 c3                	mov    %eax,%ebx
  8004fc:	83 c4 10             	add    $0x10,%esp
  8004ff:	85 c0                	test   %eax,%eax
  800501:	78 05                	js     800508 <fd_close+0x34>
	    || fd != fd2)
  800503:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800506:	74 16                	je     80051e <fd_close+0x4a>
		return (must_exist ? r : 0);
  800508:	89 f8                	mov    %edi,%eax
  80050a:	84 c0                	test   %al,%al
  80050c:	b8 00 00 00 00       	mov    $0x0,%eax
  800511:	0f 44 d8             	cmove  %eax,%ebx
}
  800514:	89 d8                	mov    %ebx,%eax
  800516:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800519:	5b                   	pop    %ebx
  80051a:	5e                   	pop    %esi
  80051b:	5f                   	pop    %edi
  80051c:	5d                   	pop    %ebp
  80051d:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800524:	50                   	push   %eax
  800525:	ff 36                	pushl  (%esi)
  800527:	e8 4e ff ff ff       	call   80047a <dev_lookup>
  80052c:	89 c3                	mov    %eax,%ebx
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	85 c0                	test   %eax,%eax
  800533:	78 1a                	js     80054f <fd_close+0x7b>
		if (dev->dev_close)
  800535:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800538:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80053b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800540:	85 c0                	test   %eax,%eax
  800542:	74 0b                	je     80054f <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800544:	83 ec 0c             	sub    $0xc,%esp
  800547:	56                   	push   %esi
  800548:	ff d0                	call   *%eax
  80054a:	89 c3                	mov    %eax,%ebx
  80054c:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	56                   	push   %esi
  800553:	6a 00                	push   $0x0
  800555:	e8 c3 fc ff ff       	call   80021d <sys_page_unmap>
	return r;
  80055a:	83 c4 10             	add    $0x10,%esp
  80055d:	eb b5                	jmp    800514 <fd_close+0x40>

0080055f <close>:

int
close(int fdnum)
{
  80055f:	f3 0f 1e fb          	endbr32 
  800563:	55                   	push   %ebp
  800564:	89 e5                	mov    %esp,%ebp
  800566:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800569:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80056c:	50                   	push   %eax
  80056d:	ff 75 08             	pushl  0x8(%ebp)
  800570:	e8 b1 fe ff ff       	call   800426 <fd_lookup>
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	85 c0                	test   %eax,%eax
  80057a:	79 02                	jns    80057e <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  80057c:	c9                   	leave  
  80057d:	c3                   	ret    
		return fd_close(fd, 1);
  80057e:	83 ec 08             	sub    $0x8,%esp
  800581:	6a 01                	push   $0x1
  800583:	ff 75 f4             	pushl  -0xc(%ebp)
  800586:	e8 49 ff ff ff       	call   8004d4 <fd_close>
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	eb ec                	jmp    80057c <close+0x1d>

00800590 <close_all>:

void
close_all(void)
{
  800590:	f3 0f 1e fb          	endbr32 
  800594:	55                   	push   %ebp
  800595:	89 e5                	mov    %esp,%ebp
  800597:	53                   	push   %ebx
  800598:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80059b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005a0:	83 ec 0c             	sub    $0xc,%esp
  8005a3:	53                   	push   %ebx
  8005a4:	e8 b6 ff ff ff       	call   80055f <close>
	for (i = 0; i < MAXFD; i++)
  8005a9:	83 c3 01             	add    $0x1,%ebx
  8005ac:	83 c4 10             	add    $0x10,%esp
  8005af:	83 fb 20             	cmp    $0x20,%ebx
  8005b2:	75 ec                	jne    8005a0 <close_all+0x10>
}
  8005b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005b7:	c9                   	leave  
  8005b8:	c3                   	ret    

008005b9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005b9:	f3 0f 1e fb          	endbr32 
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	57                   	push   %edi
  8005c1:	56                   	push   %esi
  8005c2:	53                   	push   %ebx
  8005c3:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005c6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005c9:	50                   	push   %eax
  8005ca:	ff 75 08             	pushl  0x8(%ebp)
  8005cd:	e8 54 fe ff ff       	call   800426 <fd_lookup>
  8005d2:	89 c3                	mov    %eax,%ebx
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	85 c0                	test   %eax,%eax
  8005d9:	0f 88 81 00 00 00    	js     800660 <dup+0xa7>
		return r;
	close(newfdnum);
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	ff 75 0c             	pushl  0xc(%ebp)
  8005e5:	e8 75 ff ff ff       	call   80055f <close>

	newfd = INDEX2FD(newfdnum);
  8005ea:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005ed:	c1 e6 0c             	shl    $0xc,%esi
  8005f0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005f6:	83 c4 04             	add    $0x4,%esp
  8005f9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005fc:	e8 b4 fd ff ff       	call   8003b5 <fd2data>
  800601:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800603:	89 34 24             	mov    %esi,(%esp)
  800606:	e8 aa fd ff ff       	call   8003b5 <fd2data>
  80060b:	83 c4 10             	add    $0x10,%esp
  80060e:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800610:	89 d8                	mov    %ebx,%eax
  800612:	c1 e8 16             	shr    $0x16,%eax
  800615:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80061c:	a8 01                	test   $0x1,%al
  80061e:	74 11                	je     800631 <dup+0x78>
  800620:	89 d8                	mov    %ebx,%eax
  800622:	c1 e8 0c             	shr    $0xc,%eax
  800625:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80062c:	f6 c2 01             	test   $0x1,%dl
  80062f:	75 39                	jne    80066a <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800631:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800634:	89 d0                	mov    %edx,%eax
  800636:	c1 e8 0c             	shr    $0xc,%eax
  800639:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800640:	83 ec 0c             	sub    $0xc,%esp
  800643:	25 07 0e 00 00       	and    $0xe07,%eax
  800648:	50                   	push   %eax
  800649:	56                   	push   %esi
  80064a:	6a 00                	push   $0x0
  80064c:	52                   	push   %edx
  80064d:	6a 00                	push   $0x0
  80064f:	e8 83 fb ff ff       	call   8001d7 <sys_page_map>
  800654:	89 c3                	mov    %eax,%ebx
  800656:	83 c4 20             	add    $0x20,%esp
  800659:	85 c0                	test   %eax,%eax
  80065b:	78 31                	js     80068e <dup+0xd5>
		goto err;

	return newfdnum;
  80065d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800660:	89 d8                	mov    %ebx,%eax
  800662:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800665:	5b                   	pop    %ebx
  800666:	5e                   	pop    %esi
  800667:	5f                   	pop    %edi
  800668:	5d                   	pop    %ebp
  800669:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80066a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800671:	83 ec 0c             	sub    $0xc,%esp
  800674:	25 07 0e 00 00       	and    $0xe07,%eax
  800679:	50                   	push   %eax
  80067a:	57                   	push   %edi
  80067b:	6a 00                	push   $0x0
  80067d:	53                   	push   %ebx
  80067e:	6a 00                	push   $0x0
  800680:	e8 52 fb ff ff       	call   8001d7 <sys_page_map>
  800685:	89 c3                	mov    %eax,%ebx
  800687:	83 c4 20             	add    $0x20,%esp
  80068a:	85 c0                	test   %eax,%eax
  80068c:	79 a3                	jns    800631 <dup+0x78>
	sys_page_unmap(0, newfd);
  80068e:	83 ec 08             	sub    $0x8,%esp
  800691:	56                   	push   %esi
  800692:	6a 00                	push   $0x0
  800694:	e8 84 fb ff ff       	call   80021d <sys_page_unmap>
	sys_page_unmap(0, nva);
  800699:	83 c4 08             	add    $0x8,%esp
  80069c:	57                   	push   %edi
  80069d:	6a 00                	push   $0x0
  80069f:	e8 79 fb ff ff       	call   80021d <sys_page_unmap>
	return r;
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	eb b7                	jmp    800660 <dup+0xa7>

008006a9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006a9:	f3 0f 1e fb          	endbr32 
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
  8006b0:	53                   	push   %ebx
  8006b1:	83 ec 1c             	sub    $0x1c,%esp
  8006b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006ba:	50                   	push   %eax
  8006bb:	53                   	push   %ebx
  8006bc:	e8 65 fd ff ff       	call   800426 <fd_lookup>
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	85 c0                	test   %eax,%eax
  8006c6:	78 3f                	js     800707 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006c8:	83 ec 08             	sub    $0x8,%esp
  8006cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006ce:	50                   	push   %eax
  8006cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006d2:	ff 30                	pushl  (%eax)
  8006d4:	e8 a1 fd ff ff       	call   80047a <dev_lookup>
  8006d9:	83 c4 10             	add    $0x10,%esp
  8006dc:	85 c0                	test   %eax,%eax
  8006de:	78 27                	js     800707 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006e3:	8b 42 08             	mov    0x8(%edx),%eax
  8006e6:	83 e0 03             	and    $0x3,%eax
  8006e9:	83 f8 01             	cmp    $0x1,%eax
  8006ec:	74 1e                	je     80070c <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f1:	8b 40 08             	mov    0x8(%eax),%eax
  8006f4:	85 c0                	test   %eax,%eax
  8006f6:	74 35                	je     80072d <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006f8:	83 ec 04             	sub    $0x4,%esp
  8006fb:	ff 75 10             	pushl  0x10(%ebp)
  8006fe:	ff 75 0c             	pushl  0xc(%ebp)
  800701:	52                   	push   %edx
  800702:	ff d0                	call   *%eax
  800704:	83 c4 10             	add    $0x10,%esp
}
  800707:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80070a:	c9                   	leave  
  80070b:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80070c:	a1 04 40 80 00       	mov    0x804004,%eax
  800711:	8b 40 48             	mov    0x48(%eax),%eax
  800714:	83 ec 04             	sub    $0x4,%esp
  800717:	53                   	push   %ebx
  800718:	50                   	push   %eax
  800719:	68 7d 1f 80 00       	push   $0x801f7d
  80071e:	e8 aa 0a 00 00       	call   8011cd <cprintf>
		return -E_INVAL;
  800723:	83 c4 10             	add    $0x10,%esp
  800726:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80072b:	eb da                	jmp    800707 <read+0x5e>
		return -E_NOT_SUPP;
  80072d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800732:	eb d3                	jmp    800707 <read+0x5e>

00800734 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800734:	f3 0f 1e fb          	endbr32 
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	57                   	push   %edi
  80073c:	56                   	push   %esi
  80073d:	53                   	push   %ebx
  80073e:	83 ec 0c             	sub    $0xc,%esp
  800741:	8b 7d 08             	mov    0x8(%ebp),%edi
  800744:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800747:	bb 00 00 00 00       	mov    $0x0,%ebx
  80074c:	eb 02                	jmp    800750 <readn+0x1c>
  80074e:	01 c3                	add    %eax,%ebx
  800750:	39 f3                	cmp    %esi,%ebx
  800752:	73 21                	jae    800775 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800754:	83 ec 04             	sub    $0x4,%esp
  800757:	89 f0                	mov    %esi,%eax
  800759:	29 d8                	sub    %ebx,%eax
  80075b:	50                   	push   %eax
  80075c:	89 d8                	mov    %ebx,%eax
  80075e:	03 45 0c             	add    0xc(%ebp),%eax
  800761:	50                   	push   %eax
  800762:	57                   	push   %edi
  800763:	e8 41 ff ff ff       	call   8006a9 <read>
		if (m < 0)
  800768:	83 c4 10             	add    $0x10,%esp
  80076b:	85 c0                	test   %eax,%eax
  80076d:	78 04                	js     800773 <readn+0x3f>
			return m;
		if (m == 0)
  80076f:	75 dd                	jne    80074e <readn+0x1a>
  800771:	eb 02                	jmp    800775 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800773:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800775:	89 d8                	mov    %ebx,%eax
  800777:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80077a:	5b                   	pop    %ebx
  80077b:	5e                   	pop    %esi
  80077c:	5f                   	pop    %edi
  80077d:	5d                   	pop    %ebp
  80077e:	c3                   	ret    

0080077f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80077f:	f3 0f 1e fb          	endbr32 
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	53                   	push   %ebx
  800787:	83 ec 1c             	sub    $0x1c,%esp
  80078a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80078d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800790:	50                   	push   %eax
  800791:	53                   	push   %ebx
  800792:	e8 8f fc ff ff       	call   800426 <fd_lookup>
  800797:	83 c4 10             	add    $0x10,%esp
  80079a:	85 c0                	test   %eax,%eax
  80079c:	78 3a                	js     8007d8 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80079e:	83 ec 08             	sub    $0x8,%esp
  8007a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007a4:	50                   	push   %eax
  8007a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007a8:	ff 30                	pushl  (%eax)
  8007aa:	e8 cb fc ff ff       	call   80047a <dev_lookup>
  8007af:	83 c4 10             	add    $0x10,%esp
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	78 22                	js     8007d8 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007b9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007bd:	74 1e                	je     8007dd <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007c2:	8b 52 0c             	mov    0xc(%edx),%edx
  8007c5:	85 d2                	test   %edx,%edx
  8007c7:	74 35                	je     8007fe <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007c9:	83 ec 04             	sub    $0x4,%esp
  8007cc:	ff 75 10             	pushl  0x10(%ebp)
  8007cf:	ff 75 0c             	pushl  0xc(%ebp)
  8007d2:	50                   	push   %eax
  8007d3:	ff d2                	call   *%edx
  8007d5:	83 c4 10             	add    $0x10,%esp
}
  8007d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007dd:	a1 04 40 80 00       	mov    0x804004,%eax
  8007e2:	8b 40 48             	mov    0x48(%eax),%eax
  8007e5:	83 ec 04             	sub    $0x4,%esp
  8007e8:	53                   	push   %ebx
  8007e9:	50                   	push   %eax
  8007ea:	68 99 1f 80 00       	push   $0x801f99
  8007ef:	e8 d9 09 00 00       	call   8011cd <cprintf>
		return -E_INVAL;
  8007f4:	83 c4 10             	add    $0x10,%esp
  8007f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007fc:	eb da                	jmp    8007d8 <write+0x59>
		return -E_NOT_SUPP;
  8007fe:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800803:	eb d3                	jmp    8007d8 <write+0x59>

00800805 <seek>:

int
seek(int fdnum, off_t offset)
{
  800805:	f3 0f 1e fb          	endbr32 
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80080f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800812:	50                   	push   %eax
  800813:	ff 75 08             	pushl  0x8(%ebp)
  800816:	e8 0b fc ff ff       	call   800426 <fd_lookup>
  80081b:	83 c4 10             	add    $0x10,%esp
  80081e:	85 c0                	test   %eax,%eax
  800820:	78 0e                	js     800830 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  800822:	8b 55 0c             	mov    0xc(%ebp),%edx
  800825:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800828:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80082b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800830:	c9                   	leave  
  800831:	c3                   	ret    

00800832 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800832:	f3 0f 1e fb          	endbr32 
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	53                   	push   %ebx
  80083a:	83 ec 1c             	sub    $0x1c,%esp
  80083d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800840:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800843:	50                   	push   %eax
  800844:	53                   	push   %ebx
  800845:	e8 dc fb ff ff       	call   800426 <fd_lookup>
  80084a:	83 c4 10             	add    $0x10,%esp
  80084d:	85 c0                	test   %eax,%eax
  80084f:	78 37                	js     800888 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800851:	83 ec 08             	sub    $0x8,%esp
  800854:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800857:	50                   	push   %eax
  800858:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80085b:	ff 30                	pushl  (%eax)
  80085d:	e8 18 fc ff ff       	call   80047a <dev_lookup>
  800862:	83 c4 10             	add    $0x10,%esp
  800865:	85 c0                	test   %eax,%eax
  800867:	78 1f                	js     800888 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800869:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80086c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800870:	74 1b                	je     80088d <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800872:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800875:	8b 52 18             	mov    0x18(%edx),%edx
  800878:	85 d2                	test   %edx,%edx
  80087a:	74 32                	je     8008ae <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80087c:	83 ec 08             	sub    $0x8,%esp
  80087f:	ff 75 0c             	pushl  0xc(%ebp)
  800882:	50                   	push   %eax
  800883:	ff d2                	call   *%edx
  800885:	83 c4 10             	add    $0x10,%esp
}
  800888:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088b:	c9                   	leave  
  80088c:	c3                   	ret    
			thisenv->env_id, fdnum);
  80088d:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800892:	8b 40 48             	mov    0x48(%eax),%eax
  800895:	83 ec 04             	sub    $0x4,%esp
  800898:	53                   	push   %ebx
  800899:	50                   	push   %eax
  80089a:	68 5c 1f 80 00       	push   $0x801f5c
  80089f:	e8 29 09 00 00       	call   8011cd <cprintf>
		return -E_INVAL;
  8008a4:	83 c4 10             	add    $0x10,%esp
  8008a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ac:	eb da                	jmp    800888 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8008ae:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008b3:	eb d3                	jmp    800888 <ftruncate+0x56>

008008b5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008b5:	f3 0f 1e fb          	endbr32 
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	53                   	push   %ebx
  8008bd:	83 ec 1c             	sub    $0x1c,%esp
  8008c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008c6:	50                   	push   %eax
  8008c7:	ff 75 08             	pushl  0x8(%ebp)
  8008ca:	e8 57 fb ff ff       	call   800426 <fd_lookup>
  8008cf:	83 c4 10             	add    $0x10,%esp
  8008d2:	85 c0                	test   %eax,%eax
  8008d4:	78 4b                	js     800921 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d6:	83 ec 08             	sub    $0x8,%esp
  8008d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008dc:	50                   	push   %eax
  8008dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008e0:	ff 30                	pushl  (%eax)
  8008e2:	e8 93 fb ff ff       	call   80047a <dev_lookup>
  8008e7:	83 c4 10             	add    $0x10,%esp
  8008ea:	85 c0                	test   %eax,%eax
  8008ec:	78 33                	js     800921 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8008ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008f1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008f5:	74 2f                	je     800926 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008f7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008fa:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800901:	00 00 00 
	stat->st_isdir = 0;
  800904:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80090b:	00 00 00 
	stat->st_dev = dev;
  80090e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800914:	83 ec 08             	sub    $0x8,%esp
  800917:	53                   	push   %ebx
  800918:	ff 75 f0             	pushl  -0x10(%ebp)
  80091b:	ff 50 14             	call   *0x14(%eax)
  80091e:	83 c4 10             	add    $0x10,%esp
}
  800921:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800924:	c9                   	leave  
  800925:	c3                   	ret    
		return -E_NOT_SUPP;
  800926:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80092b:	eb f4                	jmp    800921 <fstat+0x6c>

0080092d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80092d:	f3 0f 1e fb          	endbr32 
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	56                   	push   %esi
  800935:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800936:	83 ec 08             	sub    $0x8,%esp
  800939:	6a 00                	push   $0x0
  80093b:	ff 75 08             	pushl  0x8(%ebp)
  80093e:	e8 fb 01 00 00       	call   800b3e <open>
  800943:	89 c3                	mov    %eax,%ebx
  800945:	83 c4 10             	add    $0x10,%esp
  800948:	85 c0                	test   %eax,%eax
  80094a:	78 1b                	js     800967 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80094c:	83 ec 08             	sub    $0x8,%esp
  80094f:	ff 75 0c             	pushl  0xc(%ebp)
  800952:	50                   	push   %eax
  800953:	e8 5d ff ff ff       	call   8008b5 <fstat>
  800958:	89 c6                	mov    %eax,%esi
	close(fd);
  80095a:	89 1c 24             	mov    %ebx,(%esp)
  80095d:	e8 fd fb ff ff       	call   80055f <close>
	return r;
  800962:	83 c4 10             	add    $0x10,%esp
  800965:	89 f3                	mov    %esi,%ebx
}
  800967:	89 d8                	mov    %ebx,%eax
  800969:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80096c:	5b                   	pop    %ebx
  80096d:	5e                   	pop    %esi
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	56                   	push   %esi
  800974:	53                   	push   %ebx
  800975:	89 c6                	mov    %eax,%esi
  800977:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800979:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800980:	74 27                	je     8009a9 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800982:	6a 07                	push   $0x7
  800984:	68 00 50 80 00       	push   $0x805000
  800989:	56                   	push   %esi
  80098a:	ff 35 00 40 80 00    	pushl  0x804000
  800990:	e8 0a 12 00 00       	call   801b9f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800995:	83 c4 0c             	add    $0xc,%esp
  800998:	6a 00                	push   $0x0
  80099a:	53                   	push   %ebx
  80099b:	6a 00                	push   $0x0
  80099d:	e8 a6 11 00 00       	call   801b48 <ipc_recv>
}
  8009a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009a5:	5b                   	pop    %ebx
  8009a6:	5e                   	pop    %esi
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009a9:	83 ec 0c             	sub    $0xc,%esp
  8009ac:	6a 01                	push   $0x1
  8009ae:	e8 52 12 00 00       	call   801c05 <ipc_find_env>
  8009b3:	a3 00 40 80 00       	mov    %eax,0x804000
  8009b8:	83 c4 10             	add    $0x10,%esp
  8009bb:	eb c5                	jmp    800982 <fsipc+0x12>

008009bd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009bd:	f3 0f 1e fb          	endbr32 
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8009cd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009da:	ba 00 00 00 00       	mov    $0x0,%edx
  8009df:	b8 02 00 00 00       	mov    $0x2,%eax
  8009e4:	e8 87 ff ff ff       	call   800970 <fsipc>
}
  8009e9:	c9                   	leave  
  8009ea:	c3                   	ret    

008009eb <devfile_flush>:
{
  8009eb:	f3 0f 1e fb          	endbr32 
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009fb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a00:	ba 00 00 00 00       	mov    $0x0,%edx
  800a05:	b8 06 00 00 00       	mov    $0x6,%eax
  800a0a:	e8 61 ff ff ff       	call   800970 <fsipc>
}
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <devfile_stat>:
{
  800a11:	f3 0f 1e fb          	endbr32 
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	53                   	push   %ebx
  800a19:	83 ec 04             	sub    $0x4,%esp
  800a1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	8b 40 0c             	mov    0xc(%eax),%eax
  800a25:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2f:	b8 05 00 00 00       	mov    $0x5,%eax
  800a34:	e8 37 ff ff ff       	call   800970 <fsipc>
  800a39:	85 c0                	test   %eax,%eax
  800a3b:	78 2c                	js     800a69 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a3d:	83 ec 08             	sub    $0x8,%esp
  800a40:	68 00 50 80 00       	push   $0x805000
  800a45:	53                   	push   %ebx
  800a46:	e8 8b 0d 00 00       	call   8017d6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a4b:	a1 80 50 80 00       	mov    0x805080,%eax
  800a50:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a56:	a1 84 50 80 00       	mov    0x805084,%eax
  800a5b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a61:	83 c4 10             	add    $0x10,%esp
  800a64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a6c:	c9                   	leave  
  800a6d:	c3                   	ret    

00800a6e <devfile_write>:
{
  800a6e:	f3 0f 1e fb          	endbr32 
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	83 ec 0c             	sub    $0xc,%esp
  800a78:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  800a7b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a80:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a85:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a88:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8b:	8b 52 0c             	mov    0xc(%edx),%edx
  800a8e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a94:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a99:	50                   	push   %eax
  800a9a:	ff 75 0c             	pushl  0xc(%ebp)
  800a9d:	68 08 50 80 00       	push   $0x805008
  800aa2:	e8 e5 0e 00 00       	call   80198c <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800aa7:	ba 00 00 00 00       	mov    $0x0,%edx
  800aac:	b8 04 00 00 00       	mov    $0x4,%eax
  800ab1:	e8 ba fe ff ff       	call   800970 <fsipc>
}
  800ab6:	c9                   	leave  
  800ab7:	c3                   	ret    

00800ab8 <devfile_read>:
{
  800ab8:	f3 0f 1e fb          	endbr32 
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac7:	8b 40 0c             	mov    0xc(%eax),%eax
  800aca:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800acf:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ad5:	ba 00 00 00 00       	mov    $0x0,%edx
  800ada:	b8 03 00 00 00       	mov    $0x3,%eax
  800adf:	e8 8c fe ff ff       	call   800970 <fsipc>
  800ae4:	89 c3                	mov    %eax,%ebx
  800ae6:	85 c0                	test   %eax,%eax
  800ae8:	78 1f                	js     800b09 <devfile_read+0x51>
	assert(r <= n);
  800aea:	39 f0                	cmp    %esi,%eax
  800aec:	77 24                	ja     800b12 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800aee:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800af3:	7f 33                	jg     800b28 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800af5:	83 ec 04             	sub    $0x4,%esp
  800af8:	50                   	push   %eax
  800af9:	68 00 50 80 00       	push   $0x805000
  800afe:	ff 75 0c             	pushl  0xc(%ebp)
  800b01:	e8 86 0e 00 00       	call   80198c <memmove>
	return r;
  800b06:	83 c4 10             	add    $0x10,%esp
}
  800b09:	89 d8                	mov    %ebx,%eax
  800b0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    
	assert(r <= n);
  800b12:	68 c8 1f 80 00       	push   $0x801fc8
  800b17:	68 cf 1f 80 00       	push   $0x801fcf
  800b1c:	6a 7c                	push   $0x7c
  800b1e:	68 e4 1f 80 00       	push   $0x801fe4
  800b23:	e8 be 05 00 00       	call   8010e6 <_panic>
	assert(r <= PGSIZE);
  800b28:	68 ef 1f 80 00       	push   $0x801fef
  800b2d:	68 cf 1f 80 00       	push   $0x801fcf
  800b32:	6a 7d                	push   $0x7d
  800b34:	68 e4 1f 80 00       	push   $0x801fe4
  800b39:	e8 a8 05 00 00       	call   8010e6 <_panic>

00800b3e <open>:
{
  800b3e:	f3 0f 1e fb          	endbr32 
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
  800b47:	83 ec 1c             	sub    $0x1c,%esp
  800b4a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b4d:	56                   	push   %esi
  800b4e:	e8 40 0c 00 00       	call   801793 <strlen>
  800b53:	83 c4 10             	add    $0x10,%esp
  800b56:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b5b:	7f 6c                	jg     800bc9 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800b5d:	83 ec 0c             	sub    $0xc,%esp
  800b60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b63:	50                   	push   %eax
  800b64:	e8 67 f8 ff ff       	call   8003d0 <fd_alloc>
  800b69:	89 c3                	mov    %eax,%ebx
  800b6b:	83 c4 10             	add    $0x10,%esp
  800b6e:	85 c0                	test   %eax,%eax
  800b70:	78 3c                	js     800bae <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b72:	83 ec 08             	sub    $0x8,%esp
  800b75:	56                   	push   %esi
  800b76:	68 00 50 80 00       	push   $0x805000
  800b7b:	e8 56 0c 00 00       	call   8017d6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b83:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b88:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b8b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b90:	e8 db fd ff ff       	call   800970 <fsipc>
  800b95:	89 c3                	mov    %eax,%ebx
  800b97:	83 c4 10             	add    $0x10,%esp
  800b9a:	85 c0                	test   %eax,%eax
  800b9c:	78 19                	js     800bb7 <open+0x79>
	return fd2num(fd);
  800b9e:	83 ec 0c             	sub    $0xc,%esp
  800ba1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ba4:	e8 f8 f7 ff ff       	call   8003a1 <fd2num>
  800ba9:	89 c3                	mov    %eax,%ebx
  800bab:	83 c4 10             	add    $0x10,%esp
}
  800bae:	89 d8                	mov    %ebx,%eax
  800bb0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    
		fd_close(fd, 0);
  800bb7:	83 ec 08             	sub    $0x8,%esp
  800bba:	6a 00                	push   $0x0
  800bbc:	ff 75 f4             	pushl  -0xc(%ebp)
  800bbf:	e8 10 f9 ff ff       	call   8004d4 <fd_close>
		return r;
  800bc4:	83 c4 10             	add    $0x10,%esp
  800bc7:	eb e5                	jmp    800bae <open+0x70>
		return -E_BAD_PATH;
  800bc9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800bce:	eb de                	jmp    800bae <open+0x70>

00800bd0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bd0:	f3 0f 1e fb          	endbr32 
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bda:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdf:	b8 08 00 00 00       	mov    $0x8,%eax
  800be4:	e8 87 fd ff ff       	call   800970 <fsipc>
}
  800be9:	c9                   	leave  
  800bea:	c3                   	ret    

00800beb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800beb:	f3 0f 1e fb          	endbr32 
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bf7:	83 ec 0c             	sub    $0xc,%esp
  800bfa:	ff 75 08             	pushl  0x8(%ebp)
  800bfd:	e8 b3 f7 ff ff       	call   8003b5 <fd2data>
  800c02:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800c04:	83 c4 08             	add    $0x8,%esp
  800c07:	68 fb 1f 80 00       	push   $0x801ffb
  800c0c:	53                   	push   %ebx
  800c0d:	e8 c4 0b 00 00       	call   8017d6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800c12:	8b 46 04             	mov    0x4(%esi),%eax
  800c15:	2b 06                	sub    (%esi),%eax
  800c17:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800c1d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c24:	00 00 00 
	stat->st_dev = &devpipe;
  800c27:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c2e:	30 80 00 
	return 0;
}
  800c31:	b8 00 00 00 00       	mov    $0x0,%eax
  800c36:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c3d:	f3 0f 1e fb          	endbr32 
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	53                   	push   %ebx
  800c45:	83 ec 0c             	sub    $0xc,%esp
  800c48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c4b:	53                   	push   %ebx
  800c4c:	6a 00                	push   $0x0
  800c4e:	e8 ca f5 ff ff       	call   80021d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c53:	89 1c 24             	mov    %ebx,(%esp)
  800c56:	e8 5a f7 ff ff       	call   8003b5 <fd2data>
  800c5b:	83 c4 08             	add    $0x8,%esp
  800c5e:	50                   	push   %eax
  800c5f:	6a 00                	push   $0x0
  800c61:	e8 b7 f5 ff ff       	call   80021d <sys_page_unmap>
}
  800c66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c69:	c9                   	leave  
  800c6a:	c3                   	ret    

00800c6b <_pipeisclosed>:
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	83 ec 1c             	sub    $0x1c,%esp
  800c74:	89 c7                	mov    %eax,%edi
  800c76:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c78:	a1 04 40 80 00       	mov    0x804004,%eax
  800c7d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c80:	83 ec 0c             	sub    $0xc,%esp
  800c83:	57                   	push   %edi
  800c84:	e8 b9 0f 00 00       	call   801c42 <pageref>
  800c89:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c8c:	89 34 24             	mov    %esi,(%esp)
  800c8f:	e8 ae 0f 00 00       	call   801c42 <pageref>
		nn = thisenv->env_runs;
  800c94:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c9a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c9d:	83 c4 10             	add    $0x10,%esp
  800ca0:	39 cb                	cmp    %ecx,%ebx
  800ca2:	74 1b                	je     800cbf <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800ca4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800ca7:	75 cf                	jne    800c78 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800ca9:	8b 42 58             	mov    0x58(%edx),%eax
  800cac:	6a 01                	push   $0x1
  800cae:	50                   	push   %eax
  800caf:	53                   	push   %ebx
  800cb0:	68 02 20 80 00       	push   $0x802002
  800cb5:	e8 13 05 00 00       	call   8011cd <cprintf>
  800cba:	83 c4 10             	add    $0x10,%esp
  800cbd:	eb b9                	jmp    800c78 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800cbf:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800cc2:	0f 94 c0             	sete   %al
  800cc5:	0f b6 c0             	movzbl %al,%eax
}
  800cc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <devpipe_write>:
{
  800cd0:	f3 0f 1e fb          	endbr32 
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	53                   	push   %ebx
  800cda:	83 ec 28             	sub    $0x28,%esp
  800cdd:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800ce0:	56                   	push   %esi
  800ce1:	e8 cf f6 ff ff       	call   8003b5 <fd2data>
  800ce6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800ce8:	83 c4 10             	add    $0x10,%esp
  800ceb:	bf 00 00 00 00       	mov    $0x0,%edi
  800cf0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cf3:	74 4f                	je     800d44 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cf5:	8b 43 04             	mov    0x4(%ebx),%eax
  800cf8:	8b 0b                	mov    (%ebx),%ecx
  800cfa:	8d 51 20             	lea    0x20(%ecx),%edx
  800cfd:	39 d0                	cmp    %edx,%eax
  800cff:	72 14                	jb     800d15 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800d01:	89 da                	mov    %ebx,%edx
  800d03:	89 f0                	mov    %esi,%eax
  800d05:	e8 61 ff ff ff       	call   800c6b <_pipeisclosed>
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	75 3b                	jne    800d49 <devpipe_write+0x79>
			sys_yield();
  800d0e:	e8 5a f4 ff ff       	call   80016d <sys_yield>
  800d13:	eb e0                	jmp    800cf5 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d18:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d1c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d1f:	89 c2                	mov    %eax,%edx
  800d21:	c1 fa 1f             	sar    $0x1f,%edx
  800d24:	89 d1                	mov    %edx,%ecx
  800d26:	c1 e9 1b             	shr    $0x1b,%ecx
  800d29:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800d2c:	83 e2 1f             	and    $0x1f,%edx
  800d2f:	29 ca                	sub    %ecx,%edx
  800d31:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800d35:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d39:	83 c0 01             	add    $0x1,%eax
  800d3c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800d3f:	83 c7 01             	add    $0x1,%edi
  800d42:	eb ac                	jmp    800cf0 <devpipe_write+0x20>
	return i;
  800d44:	8b 45 10             	mov    0x10(%ebp),%eax
  800d47:	eb 05                	jmp    800d4e <devpipe_write+0x7e>
				return 0;
  800d49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    

00800d56 <devpipe_read>:
{
  800d56:	f3 0f 1e fb          	endbr32 
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
  800d60:	83 ec 18             	sub    $0x18,%esp
  800d63:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800d66:	57                   	push   %edi
  800d67:	e8 49 f6 ff ff       	call   8003b5 <fd2data>
  800d6c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d6e:	83 c4 10             	add    $0x10,%esp
  800d71:	be 00 00 00 00       	mov    $0x0,%esi
  800d76:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d79:	75 14                	jne    800d8f <devpipe_read+0x39>
	return i;
  800d7b:	8b 45 10             	mov    0x10(%ebp),%eax
  800d7e:	eb 02                	jmp    800d82 <devpipe_read+0x2c>
				return i;
  800d80:	89 f0                	mov    %esi,%eax
}
  800d82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    
			sys_yield();
  800d8a:	e8 de f3 ff ff       	call   80016d <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d8f:	8b 03                	mov    (%ebx),%eax
  800d91:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d94:	75 18                	jne    800dae <devpipe_read+0x58>
			if (i > 0)
  800d96:	85 f6                	test   %esi,%esi
  800d98:	75 e6                	jne    800d80 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d9a:	89 da                	mov    %ebx,%edx
  800d9c:	89 f8                	mov    %edi,%eax
  800d9e:	e8 c8 fe ff ff       	call   800c6b <_pipeisclosed>
  800da3:	85 c0                	test   %eax,%eax
  800da5:	74 e3                	je     800d8a <devpipe_read+0x34>
				return 0;
  800da7:	b8 00 00 00 00       	mov    $0x0,%eax
  800dac:	eb d4                	jmp    800d82 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800dae:	99                   	cltd   
  800daf:	c1 ea 1b             	shr    $0x1b,%edx
  800db2:	01 d0                	add    %edx,%eax
  800db4:	83 e0 1f             	and    $0x1f,%eax
  800db7:	29 d0                	sub    %edx,%eax
  800db9:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800dbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc1:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800dc4:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800dc7:	83 c6 01             	add    $0x1,%esi
  800dca:	eb aa                	jmp    800d76 <devpipe_read+0x20>

00800dcc <pipe>:
{
  800dcc:	f3 0f 1e fb          	endbr32 
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	56                   	push   %esi
  800dd4:	53                   	push   %ebx
  800dd5:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800dd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ddb:	50                   	push   %eax
  800ddc:	e8 ef f5 ff ff       	call   8003d0 <fd_alloc>
  800de1:	89 c3                	mov    %eax,%ebx
  800de3:	83 c4 10             	add    $0x10,%esp
  800de6:	85 c0                	test   %eax,%eax
  800de8:	0f 88 23 01 00 00    	js     800f11 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dee:	83 ec 04             	sub    $0x4,%esp
  800df1:	68 07 04 00 00       	push   $0x407
  800df6:	ff 75 f4             	pushl  -0xc(%ebp)
  800df9:	6a 00                	push   $0x0
  800dfb:	e8 90 f3 ff ff       	call   800190 <sys_page_alloc>
  800e00:	89 c3                	mov    %eax,%ebx
  800e02:	83 c4 10             	add    $0x10,%esp
  800e05:	85 c0                	test   %eax,%eax
  800e07:	0f 88 04 01 00 00    	js     800f11 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800e0d:	83 ec 0c             	sub    $0xc,%esp
  800e10:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e13:	50                   	push   %eax
  800e14:	e8 b7 f5 ff ff       	call   8003d0 <fd_alloc>
  800e19:	89 c3                	mov    %eax,%ebx
  800e1b:	83 c4 10             	add    $0x10,%esp
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	0f 88 db 00 00 00    	js     800f01 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e26:	83 ec 04             	sub    $0x4,%esp
  800e29:	68 07 04 00 00       	push   $0x407
  800e2e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e31:	6a 00                	push   $0x0
  800e33:	e8 58 f3 ff ff       	call   800190 <sys_page_alloc>
  800e38:	89 c3                	mov    %eax,%ebx
  800e3a:	83 c4 10             	add    $0x10,%esp
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	0f 88 bc 00 00 00    	js     800f01 <pipe+0x135>
	va = fd2data(fd0);
  800e45:	83 ec 0c             	sub    $0xc,%esp
  800e48:	ff 75 f4             	pushl  -0xc(%ebp)
  800e4b:	e8 65 f5 ff ff       	call   8003b5 <fd2data>
  800e50:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e52:	83 c4 0c             	add    $0xc,%esp
  800e55:	68 07 04 00 00       	push   $0x407
  800e5a:	50                   	push   %eax
  800e5b:	6a 00                	push   $0x0
  800e5d:	e8 2e f3 ff ff       	call   800190 <sys_page_alloc>
  800e62:	89 c3                	mov    %eax,%ebx
  800e64:	83 c4 10             	add    $0x10,%esp
  800e67:	85 c0                	test   %eax,%eax
  800e69:	0f 88 82 00 00 00    	js     800ef1 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e6f:	83 ec 0c             	sub    $0xc,%esp
  800e72:	ff 75 f0             	pushl  -0x10(%ebp)
  800e75:	e8 3b f5 ff ff       	call   8003b5 <fd2data>
  800e7a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e81:	50                   	push   %eax
  800e82:	6a 00                	push   $0x0
  800e84:	56                   	push   %esi
  800e85:	6a 00                	push   $0x0
  800e87:	e8 4b f3 ff ff       	call   8001d7 <sys_page_map>
  800e8c:	89 c3                	mov    %eax,%ebx
  800e8e:	83 c4 20             	add    $0x20,%esp
  800e91:	85 c0                	test   %eax,%eax
  800e93:	78 4e                	js     800ee3 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e95:	a1 20 30 80 00       	mov    0x803020,%eax
  800e9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e9d:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ea2:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800ea9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800eac:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800eae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eb1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800eb8:	83 ec 0c             	sub    $0xc,%esp
  800ebb:	ff 75 f4             	pushl  -0xc(%ebp)
  800ebe:	e8 de f4 ff ff       	call   8003a1 <fd2num>
  800ec3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800ec8:	83 c4 04             	add    $0x4,%esp
  800ecb:	ff 75 f0             	pushl  -0x10(%ebp)
  800ece:	e8 ce f4 ff ff       	call   8003a1 <fd2num>
  800ed3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800ed9:	83 c4 10             	add    $0x10,%esp
  800edc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee1:	eb 2e                	jmp    800f11 <pipe+0x145>
	sys_page_unmap(0, va);
  800ee3:	83 ec 08             	sub    $0x8,%esp
  800ee6:	56                   	push   %esi
  800ee7:	6a 00                	push   $0x0
  800ee9:	e8 2f f3 ff ff       	call   80021d <sys_page_unmap>
  800eee:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800ef1:	83 ec 08             	sub    $0x8,%esp
  800ef4:	ff 75 f0             	pushl  -0x10(%ebp)
  800ef7:	6a 00                	push   $0x0
  800ef9:	e8 1f f3 ff ff       	call   80021d <sys_page_unmap>
  800efe:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800f01:	83 ec 08             	sub    $0x8,%esp
  800f04:	ff 75 f4             	pushl  -0xc(%ebp)
  800f07:	6a 00                	push   $0x0
  800f09:	e8 0f f3 ff ff       	call   80021d <sys_page_unmap>
  800f0e:	83 c4 10             	add    $0x10,%esp
}
  800f11:	89 d8                	mov    %ebx,%eax
  800f13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f16:	5b                   	pop    %ebx
  800f17:	5e                   	pop    %esi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <pipeisclosed>:
{
  800f1a:	f3 0f 1e fb          	endbr32 
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f24:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f27:	50                   	push   %eax
  800f28:	ff 75 08             	pushl  0x8(%ebp)
  800f2b:	e8 f6 f4 ff ff       	call   800426 <fd_lookup>
  800f30:	83 c4 10             	add    $0x10,%esp
  800f33:	85 c0                	test   %eax,%eax
  800f35:	78 18                	js     800f4f <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800f37:	83 ec 0c             	sub    $0xc,%esp
  800f3a:	ff 75 f4             	pushl  -0xc(%ebp)
  800f3d:	e8 73 f4 ff ff       	call   8003b5 <fd2data>
  800f42:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f47:	e8 1f fd ff ff       	call   800c6b <_pipeisclosed>
  800f4c:	83 c4 10             	add    $0x10,%esp
}
  800f4f:	c9                   	leave  
  800f50:	c3                   	ret    

00800f51 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f51:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800f55:	b8 00 00 00 00       	mov    $0x0,%eax
  800f5a:	c3                   	ret    

00800f5b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f5b:	f3 0f 1e fb          	endbr32 
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f65:	68 1a 20 80 00       	push   $0x80201a
  800f6a:	ff 75 0c             	pushl  0xc(%ebp)
  800f6d:	e8 64 08 00 00       	call   8017d6 <strcpy>
	return 0;
}
  800f72:	b8 00 00 00 00       	mov    $0x0,%eax
  800f77:	c9                   	leave  
  800f78:	c3                   	ret    

00800f79 <devcons_write>:
{
  800f79:	f3 0f 1e fb          	endbr32 
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	57                   	push   %edi
  800f81:	56                   	push   %esi
  800f82:	53                   	push   %ebx
  800f83:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f89:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f8e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f94:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f97:	73 31                	jae    800fca <devcons_write+0x51>
		m = n - tot;
  800f99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f9c:	29 f3                	sub    %esi,%ebx
  800f9e:	83 fb 7f             	cmp    $0x7f,%ebx
  800fa1:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800fa6:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800fa9:	83 ec 04             	sub    $0x4,%esp
  800fac:	53                   	push   %ebx
  800fad:	89 f0                	mov    %esi,%eax
  800faf:	03 45 0c             	add    0xc(%ebp),%eax
  800fb2:	50                   	push   %eax
  800fb3:	57                   	push   %edi
  800fb4:	e8 d3 09 00 00       	call   80198c <memmove>
		sys_cputs(buf, m);
  800fb9:	83 c4 08             	add    $0x8,%esp
  800fbc:	53                   	push   %ebx
  800fbd:	57                   	push   %edi
  800fbe:	e8 fd f0 ff ff       	call   8000c0 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800fc3:	01 de                	add    %ebx,%esi
  800fc5:	83 c4 10             	add    $0x10,%esp
  800fc8:	eb ca                	jmp    800f94 <devcons_write+0x1b>
}
  800fca:	89 f0                	mov    %esi,%eax
  800fcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fcf:	5b                   	pop    %ebx
  800fd0:	5e                   	pop    %esi
  800fd1:	5f                   	pop    %edi
  800fd2:	5d                   	pop    %ebp
  800fd3:	c3                   	ret    

00800fd4 <devcons_read>:
{
  800fd4:	f3 0f 1e fb          	endbr32 
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	83 ec 08             	sub    $0x8,%esp
  800fde:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800fe3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fe7:	74 21                	je     80100a <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800fe9:	e8 f4 f0 ff ff       	call   8000e2 <sys_cgetc>
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	75 07                	jne    800ff9 <devcons_read+0x25>
		sys_yield();
  800ff2:	e8 76 f1 ff ff       	call   80016d <sys_yield>
  800ff7:	eb f0                	jmp    800fe9 <devcons_read+0x15>
	if (c < 0)
  800ff9:	78 0f                	js     80100a <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800ffb:	83 f8 04             	cmp    $0x4,%eax
  800ffe:	74 0c                	je     80100c <devcons_read+0x38>
	*(char*)vbuf = c;
  801000:	8b 55 0c             	mov    0xc(%ebp),%edx
  801003:	88 02                	mov    %al,(%edx)
	return 1;
  801005:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80100a:	c9                   	leave  
  80100b:	c3                   	ret    
		return 0;
  80100c:	b8 00 00 00 00       	mov    $0x0,%eax
  801011:	eb f7                	jmp    80100a <devcons_read+0x36>

00801013 <cputchar>:
{
  801013:	f3 0f 1e fb          	endbr32 
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80101d:	8b 45 08             	mov    0x8(%ebp),%eax
  801020:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801023:	6a 01                	push   $0x1
  801025:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801028:	50                   	push   %eax
  801029:	e8 92 f0 ff ff       	call   8000c0 <sys_cputs>
}
  80102e:	83 c4 10             	add    $0x10,%esp
  801031:	c9                   	leave  
  801032:	c3                   	ret    

00801033 <getchar>:
{
  801033:	f3 0f 1e fb          	endbr32 
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80103d:	6a 01                	push   $0x1
  80103f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801042:	50                   	push   %eax
  801043:	6a 00                	push   $0x0
  801045:	e8 5f f6 ff ff       	call   8006a9 <read>
	if (r < 0)
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	85 c0                	test   %eax,%eax
  80104f:	78 06                	js     801057 <getchar+0x24>
	if (r < 1)
  801051:	74 06                	je     801059 <getchar+0x26>
	return c;
  801053:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801057:	c9                   	leave  
  801058:	c3                   	ret    
		return -E_EOF;
  801059:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80105e:	eb f7                	jmp    801057 <getchar+0x24>

00801060 <iscons>:
{
  801060:	f3 0f 1e fb          	endbr32 
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80106a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80106d:	50                   	push   %eax
  80106e:	ff 75 08             	pushl  0x8(%ebp)
  801071:	e8 b0 f3 ff ff       	call   800426 <fd_lookup>
  801076:	83 c4 10             	add    $0x10,%esp
  801079:	85 c0                	test   %eax,%eax
  80107b:	78 11                	js     80108e <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80107d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801080:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801086:	39 10                	cmp    %edx,(%eax)
  801088:	0f 94 c0             	sete   %al
  80108b:	0f b6 c0             	movzbl %al,%eax
}
  80108e:	c9                   	leave  
  80108f:	c3                   	ret    

00801090 <opencons>:
{
  801090:	f3 0f 1e fb          	endbr32 
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80109a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80109d:	50                   	push   %eax
  80109e:	e8 2d f3 ff ff       	call   8003d0 <fd_alloc>
  8010a3:	83 c4 10             	add    $0x10,%esp
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	78 3a                	js     8010e4 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8010aa:	83 ec 04             	sub    $0x4,%esp
  8010ad:	68 07 04 00 00       	push   $0x407
  8010b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8010b5:	6a 00                	push   $0x0
  8010b7:	e8 d4 f0 ff ff       	call   800190 <sys_page_alloc>
  8010bc:	83 c4 10             	add    $0x10,%esp
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	78 21                	js     8010e4 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8010c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8010cc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8010ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010d1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8010d8:	83 ec 0c             	sub    $0xc,%esp
  8010db:	50                   	push   %eax
  8010dc:	e8 c0 f2 ff ff       	call   8003a1 <fd2num>
  8010e1:	83 c4 10             	add    $0x10,%esp
}
  8010e4:	c9                   	leave  
  8010e5:	c3                   	ret    

008010e6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010e6:	f3 0f 1e fb          	endbr32 
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	56                   	push   %esi
  8010ee:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010ef:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010f2:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010f8:	e8 4d f0 ff ff       	call   80014a <sys_getenvid>
  8010fd:	83 ec 0c             	sub    $0xc,%esp
  801100:	ff 75 0c             	pushl  0xc(%ebp)
  801103:	ff 75 08             	pushl  0x8(%ebp)
  801106:	56                   	push   %esi
  801107:	50                   	push   %eax
  801108:	68 28 20 80 00       	push   $0x802028
  80110d:	e8 bb 00 00 00       	call   8011cd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801112:	83 c4 18             	add    $0x18,%esp
  801115:	53                   	push   %ebx
  801116:	ff 75 10             	pushl  0x10(%ebp)
  801119:	e8 5a 00 00 00       	call   801178 <vcprintf>
	cprintf("\n");
  80111e:	c7 04 24 13 20 80 00 	movl   $0x802013,(%esp)
  801125:	e8 a3 00 00 00       	call   8011cd <cprintf>
  80112a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80112d:	cc                   	int3   
  80112e:	eb fd                	jmp    80112d <_panic+0x47>

00801130 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801130:	f3 0f 1e fb          	endbr32 
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	53                   	push   %ebx
  801138:	83 ec 04             	sub    $0x4,%esp
  80113b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80113e:	8b 13                	mov    (%ebx),%edx
  801140:	8d 42 01             	lea    0x1(%edx),%eax
  801143:	89 03                	mov    %eax,(%ebx)
  801145:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801148:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80114c:	3d ff 00 00 00       	cmp    $0xff,%eax
  801151:	74 09                	je     80115c <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801153:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801157:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80115a:	c9                   	leave  
  80115b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80115c:	83 ec 08             	sub    $0x8,%esp
  80115f:	68 ff 00 00 00       	push   $0xff
  801164:	8d 43 08             	lea    0x8(%ebx),%eax
  801167:	50                   	push   %eax
  801168:	e8 53 ef ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  80116d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	eb db                	jmp    801153 <putch+0x23>

00801178 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801178:	f3 0f 1e fb          	endbr32 
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801185:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80118c:	00 00 00 
	b.cnt = 0;
  80118f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801196:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801199:	ff 75 0c             	pushl  0xc(%ebp)
  80119c:	ff 75 08             	pushl  0x8(%ebp)
  80119f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8011a5:	50                   	push   %eax
  8011a6:	68 30 11 80 00       	push   $0x801130
  8011ab:	e8 20 01 00 00       	call   8012d0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8011b0:	83 c4 08             	add    $0x8,%esp
  8011b3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8011b9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8011bf:	50                   	push   %eax
  8011c0:	e8 fb ee ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  8011c5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8011cb:	c9                   	leave  
  8011cc:	c3                   	ret    

008011cd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8011cd:	f3 0f 1e fb          	endbr32 
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8011d7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8011da:	50                   	push   %eax
  8011db:	ff 75 08             	pushl  0x8(%ebp)
  8011de:	e8 95 ff ff ff       	call   801178 <vcprintf>
	va_end(ap);

	return cnt;
}
  8011e3:	c9                   	leave  
  8011e4:	c3                   	ret    

008011e5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	57                   	push   %edi
  8011e9:	56                   	push   %esi
  8011ea:	53                   	push   %ebx
  8011eb:	83 ec 1c             	sub    $0x1c,%esp
  8011ee:	89 c7                	mov    %eax,%edi
  8011f0:	89 d6                	mov    %edx,%esi
  8011f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011f8:	89 d1                	mov    %edx,%ecx
  8011fa:	89 c2                	mov    %eax,%edx
  8011fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011ff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801202:	8b 45 10             	mov    0x10(%ebp),%eax
  801205:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801208:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80120b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801212:	39 c2                	cmp    %eax,%edx
  801214:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801217:	72 3e                	jb     801257 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801219:	83 ec 0c             	sub    $0xc,%esp
  80121c:	ff 75 18             	pushl  0x18(%ebp)
  80121f:	83 eb 01             	sub    $0x1,%ebx
  801222:	53                   	push   %ebx
  801223:	50                   	push   %eax
  801224:	83 ec 08             	sub    $0x8,%esp
  801227:	ff 75 e4             	pushl  -0x1c(%ebp)
  80122a:	ff 75 e0             	pushl  -0x20(%ebp)
  80122d:	ff 75 dc             	pushl  -0x24(%ebp)
  801230:	ff 75 d8             	pushl  -0x28(%ebp)
  801233:	e8 58 0a 00 00       	call   801c90 <__udivdi3>
  801238:	83 c4 18             	add    $0x18,%esp
  80123b:	52                   	push   %edx
  80123c:	50                   	push   %eax
  80123d:	89 f2                	mov    %esi,%edx
  80123f:	89 f8                	mov    %edi,%eax
  801241:	e8 9f ff ff ff       	call   8011e5 <printnum>
  801246:	83 c4 20             	add    $0x20,%esp
  801249:	eb 13                	jmp    80125e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80124b:	83 ec 08             	sub    $0x8,%esp
  80124e:	56                   	push   %esi
  80124f:	ff 75 18             	pushl  0x18(%ebp)
  801252:	ff d7                	call   *%edi
  801254:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801257:	83 eb 01             	sub    $0x1,%ebx
  80125a:	85 db                	test   %ebx,%ebx
  80125c:	7f ed                	jg     80124b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80125e:	83 ec 08             	sub    $0x8,%esp
  801261:	56                   	push   %esi
  801262:	83 ec 04             	sub    $0x4,%esp
  801265:	ff 75 e4             	pushl  -0x1c(%ebp)
  801268:	ff 75 e0             	pushl  -0x20(%ebp)
  80126b:	ff 75 dc             	pushl  -0x24(%ebp)
  80126e:	ff 75 d8             	pushl  -0x28(%ebp)
  801271:	e8 2a 0b 00 00       	call   801da0 <__umoddi3>
  801276:	83 c4 14             	add    $0x14,%esp
  801279:	0f be 80 4b 20 80 00 	movsbl 0x80204b(%eax),%eax
  801280:	50                   	push   %eax
  801281:	ff d7                	call   *%edi
}
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801289:	5b                   	pop    %ebx
  80128a:	5e                   	pop    %esi
  80128b:	5f                   	pop    %edi
  80128c:	5d                   	pop    %ebp
  80128d:	c3                   	ret    

0080128e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80128e:	f3 0f 1e fb          	endbr32 
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801298:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80129c:	8b 10                	mov    (%eax),%edx
  80129e:	3b 50 04             	cmp    0x4(%eax),%edx
  8012a1:	73 0a                	jae    8012ad <sprintputch+0x1f>
		*b->buf++ = ch;
  8012a3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8012a6:	89 08                	mov    %ecx,(%eax)
  8012a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ab:	88 02                	mov    %al,(%edx)
}
  8012ad:	5d                   	pop    %ebp
  8012ae:	c3                   	ret    

008012af <printfmt>:
{
  8012af:	f3 0f 1e fb          	endbr32 
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8012b9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012bc:	50                   	push   %eax
  8012bd:	ff 75 10             	pushl  0x10(%ebp)
  8012c0:	ff 75 0c             	pushl  0xc(%ebp)
  8012c3:	ff 75 08             	pushl  0x8(%ebp)
  8012c6:	e8 05 00 00 00       	call   8012d0 <vprintfmt>
}
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	c9                   	leave  
  8012cf:	c3                   	ret    

008012d0 <vprintfmt>:
{
  8012d0:	f3 0f 1e fb          	endbr32 
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	57                   	push   %edi
  8012d8:	56                   	push   %esi
  8012d9:	53                   	push   %ebx
  8012da:	83 ec 3c             	sub    $0x3c,%esp
  8012dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8012e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012e3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012e6:	e9 4a 03 00 00       	jmp    801635 <vprintfmt+0x365>
		padc = ' ';
  8012eb:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012ef:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012f6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012fd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801304:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801309:	8d 47 01             	lea    0x1(%edi),%eax
  80130c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80130f:	0f b6 17             	movzbl (%edi),%edx
  801312:	8d 42 dd             	lea    -0x23(%edx),%eax
  801315:	3c 55                	cmp    $0x55,%al
  801317:	0f 87 de 03 00 00    	ja     8016fb <vprintfmt+0x42b>
  80131d:	0f b6 c0             	movzbl %al,%eax
  801320:	3e ff 24 85 80 21 80 	notrack jmp *0x802180(,%eax,4)
  801327:	00 
  801328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80132b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80132f:	eb d8                	jmp    801309 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801334:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801338:	eb cf                	jmp    801309 <vprintfmt+0x39>
  80133a:	0f b6 d2             	movzbl %dl,%edx
  80133d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801340:	b8 00 00 00 00       	mov    $0x0,%eax
  801345:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801348:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80134b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80134f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801352:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801355:	83 f9 09             	cmp    $0x9,%ecx
  801358:	77 55                	ja     8013af <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80135a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80135d:	eb e9                	jmp    801348 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80135f:	8b 45 14             	mov    0x14(%ebp),%eax
  801362:	8b 00                	mov    (%eax),%eax
  801364:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801367:	8b 45 14             	mov    0x14(%ebp),%eax
  80136a:	8d 40 04             	lea    0x4(%eax),%eax
  80136d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801373:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801377:	79 90                	jns    801309 <vprintfmt+0x39>
				width = precision, precision = -1;
  801379:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80137c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80137f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801386:	eb 81                	jmp    801309 <vprintfmt+0x39>
  801388:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80138b:	85 c0                	test   %eax,%eax
  80138d:	ba 00 00 00 00       	mov    $0x0,%edx
  801392:	0f 49 d0             	cmovns %eax,%edx
  801395:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80139b:	e9 69 ff ff ff       	jmp    801309 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8013a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8013a3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8013aa:	e9 5a ff ff ff       	jmp    801309 <vprintfmt+0x39>
  8013af:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8013b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8013b5:	eb bc                	jmp    801373 <vprintfmt+0xa3>
			lflag++;
  8013b7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8013ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8013bd:	e9 47 ff ff ff       	jmp    801309 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8013c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c5:	8d 78 04             	lea    0x4(%eax),%edi
  8013c8:	83 ec 08             	sub    $0x8,%esp
  8013cb:	53                   	push   %ebx
  8013cc:	ff 30                	pushl  (%eax)
  8013ce:	ff d6                	call   *%esi
			break;
  8013d0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8013d3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8013d6:	e9 57 02 00 00       	jmp    801632 <vprintfmt+0x362>
			err = va_arg(ap, int);
  8013db:	8b 45 14             	mov    0x14(%ebp),%eax
  8013de:	8d 78 04             	lea    0x4(%eax),%edi
  8013e1:	8b 00                	mov    (%eax),%eax
  8013e3:	99                   	cltd   
  8013e4:	31 d0                	xor    %edx,%eax
  8013e6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013e8:	83 f8 0f             	cmp    $0xf,%eax
  8013eb:	7f 23                	jg     801410 <vprintfmt+0x140>
  8013ed:	8b 14 85 e0 22 80 00 	mov    0x8022e0(,%eax,4),%edx
  8013f4:	85 d2                	test   %edx,%edx
  8013f6:	74 18                	je     801410 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8013f8:	52                   	push   %edx
  8013f9:	68 e1 1f 80 00       	push   $0x801fe1
  8013fe:	53                   	push   %ebx
  8013ff:	56                   	push   %esi
  801400:	e8 aa fe ff ff       	call   8012af <printfmt>
  801405:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801408:	89 7d 14             	mov    %edi,0x14(%ebp)
  80140b:	e9 22 02 00 00       	jmp    801632 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  801410:	50                   	push   %eax
  801411:	68 63 20 80 00       	push   $0x802063
  801416:	53                   	push   %ebx
  801417:	56                   	push   %esi
  801418:	e8 92 fe ff ff       	call   8012af <printfmt>
  80141d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801420:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801423:	e9 0a 02 00 00       	jmp    801632 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  801428:	8b 45 14             	mov    0x14(%ebp),%eax
  80142b:	83 c0 04             	add    $0x4,%eax
  80142e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801431:	8b 45 14             	mov    0x14(%ebp),%eax
  801434:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801436:	85 d2                	test   %edx,%edx
  801438:	b8 5c 20 80 00       	mov    $0x80205c,%eax
  80143d:	0f 45 c2             	cmovne %edx,%eax
  801440:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801443:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801447:	7e 06                	jle    80144f <vprintfmt+0x17f>
  801449:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80144d:	75 0d                	jne    80145c <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80144f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801452:	89 c7                	mov    %eax,%edi
  801454:	03 45 e0             	add    -0x20(%ebp),%eax
  801457:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80145a:	eb 55                	jmp    8014b1 <vprintfmt+0x1e1>
  80145c:	83 ec 08             	sub    $0x8,%esp
  80145f:	ff 75 d8             	pushl  -0x28(%ebp)
  801462:	ff 75 cc             	pushl  -0x34(%ebp)
  801465:	e8 45 03 00 00       	call   8017af <strnlen>
  80146a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80146d:	29 c2                	sub    %eax,%edx
  80146f:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  801477:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80147b:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80147e:	85 ff                	test   %edi,%edi
  801480:	7e 11                	jle    801493 <vprintfmt+0x1c3>
					putch(padc, putdat);
  801482:	83 ec 08             	sub    $0x8,%esp
  801485:	53                   	push   %ebx
  801486:	ff 75 e0             	pushl  -0x20(%ebp)
  801489:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80148b:	83 ef 01             	sub    $0x1,%edi
  80148e:	83 c4 10             	add    $0x10,%esp
  801491:	eb eb                	jmp    80147e <vprintfmt+0x1ae>
  801493:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801496:	85 d2                	test   %edx,%edx
  801498:	b8 00 00 00 00       	mov    $0x0,%eax
  80149d:	0f 49 c2             	cmovns %edx,%eax
  8014a0:	29 c2                	sub    %eax,%edx
  8014a2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8014a5:	eb a8                	jmp    80144f <vprintfmt+0x17f>
					putch(ch, putdat);
  8014a7:	83 ec 08             	sub    $0x8,%esp
  8014aa:	53                   	push   %ebx
  8014ab:	52                   	push   %edx
  8014ac:	ff d6                	call   *%esi
  8014ae:	83 c4 10             	add    $0x10,%esp
  8014b1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014b4:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014b6:	83 c7 01             	add    $0x1,%edi
  8014b9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014bd:	0f be d0             	movsbl %al,%edx
  8014c0:	85 d2                	test   %edx,%edx
  8014c2:	74 4b                	je     80150f <vprintfmt+0x23f>
  8014c4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014c8:	78 06                	js     8014d0 <vprintfmt+0x200>
  8014ca:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014ce:	78 1e                	js     8014ee <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8014d0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014d4:	74 d1                	je     8014a7 <vprintfmt+0x1d7>
  8014d6:	0f be c0             	movsbl %al,%eax
  8014d9:	83 e8 20             	sub    $0x20,%eax
  8014dc:	83 f8 5e             	cmp    $0x5e,%eax
  8014df:	76 c6                	jbe    8014a7 <vprintfmt+0x1d7>
					putch('?', putdat);
  8014e1:	83 ec 08             	sub    $0x8,%esp
  8014e4:	53                   	push   %ebx
  8014e5:	6a 3f                	push   $0x3f
  8014e7:	ff d6                	call   *%esi
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	eb c3                	jmp    8014b1 <vprintfmt+0x1e1>
  8014ee:	89 cf                	mov    %ecx,%edi
  8014f0:	eb 0e                	jmp    801500 <vprintfmt+0x230>
				putch(' ', putdat);
  8014f2:	83 ec 08             	sub    $0x8,%esp
  8014f5:	53                   	push   %ebx
  8014f6:	6a 20                	push   $0x20
  8014f8:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8014fa:	83 ef 01             	sub    $0x1,%edi
  8014fd:	83 c4 10             	add    $0x10,%esp
  801500:	85 ff                	test   %edi,%edi
  801502:	7f ee                	jg     8014f2 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  801504:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801507:	89 45 14             	mov    %eax,0x14(%ebp)
  80150a:	e9 23 01 00 00       	jmp    801632 <vprintfmt+0x362>
  80150f:	89 cf                	mov    %ecx,%edi
  801511:	eb ed                	jmp    801500 <vprintfmt+0x230>
	if (lflag >= 2)
  801513:	83 f9 01             	cmp    $0x1,%ecx
  801516:	7f 1b                	jg     801533 <vprintfmt+0x263>
	else if (lflag)
  801518:	85 c9                	test   %ecx,%ecx
  80151a:	74 63                	je     80157f <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80151c:	8b 45 14             	mov    0x14(%ebp),%eax
  80151f:	8b 00                	mov    (%eax),%eax
  801521:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801524:	99                   	cltd   
  801525:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801528:	8b 45 14             	mov    0x14(%ebp),%eax
  80152b:	8d 40 04             	lea    0x4(%eax),%eax
  80152e:	89 45 14             	mov    %eax,0x14(%ebp)
  801531:	eb 17                	jmp    80154a <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  801533:	8b 45 14             	mov    0x14(%ebp),%eax
  801536:	8b 50 04             	mov    0x4(%eax),%edx
  801539:	8b 00                	mov    (%eax),%eax
  80153b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80153e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801541:	8b 45 14             	mov    0x14(%ebp),%eax
  801544:	8d 40 08             	lea    0x8(%eax),%eax
  801547:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80154a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80154d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801550:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  801555:	85 c9                	test   %ecx,%ecx
  801557:	0f 89 bb 00 00 00    	jns    801618 <vprintfmt+0x348>
				putch('-', putdat);
  80155d:	83 ec 08             	sub    $0x8,%esp
  801560:	53                   	push   %ebx
  801561:	6a 2d                	push   $0x2d
  801563:	ff d6                	call   *%esi
				num = -(long long) num;
  801565:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801568:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80156b:	f7 da                	neg    %edx
  80156d:	83 d1 00             	adc    $0x0,%ecx
  801570:	f7 d9                	neg    %ecx
  801572:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801575:	b8 0a 00 00 00       	mov    $0xa,%eax
  80157a:	e9 99 00 00 00       	jmp    801618 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80157f:	8b 45 14             	mov    0x14(%ebp),%eax
  801582:	8b 00                	mov    (%eax),%eax
  801584:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801587:	99                   	cltd   
  801588:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80158b:	8b 45 14             	mov    0x14(%ebp),%eax
  80158e:	8d 40 04             	lea    0x4(%eax),%eax
  801591:	89 45 14             	mov    %eax,0x14(%ebp)
  801594:	eb b4                	jmp    80154a <vprintfmt+0x27a>
	if (lflag >= 2)
  801596:	83 f9 01             	cmp    $0x1,%ecx
  801599:	7f 1b                	jg     8015b6 <vprintfmt+0x2e6>
	else if (lflag)
  80159b:	85 c9                	test   %ecx,%ecx
  80159d:	74 2c                	je     8015cb <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80159f:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a2:	8b 10                	mov    (%eax),%edx
  8015a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015a9:	8d 40 04             	lea    0x4(%eax),%eax
  8015ac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015af:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8015b4:	eb 62                	jmp    801618 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8015b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b9:	8b 10                	mov    (%eax),%edx
  8015bb:	8b 48 04             	mov    0x4(%eax),%ecx
  8015be:	8d 40 08             	lea    0x8(%eax),%eax
  8015c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015c4:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8015c9:	eb 4d                	jmp    801618 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8015cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ce:	8b 10                	mov    (%eax),%edx
  8015d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015d5:	8d 40 04             	lea    0x4(%eax),%eax
  8015d8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015db:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8015e0:	eb 36                	jmp    801618 <vprintfmt+0x348>
	if (lflag >= 2)
  8015e2:	83 f9 01             	cmp    $0x1,%ecx
  8015e5:	7f 17                	jg     8015fe <vprintfmt+0x32e>
	else if (lflag)
  8015e7:	85 c9                	test   %ecx,%ecx
  8015e9:	74 6e                	je     801659 <vprintfmt+0x389>
		return va_arg(*ap, long);
  8015eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ee:	8b 10                	mov    (%eax),%edx
  8015f0:	89 d0                	mov    %edx,%eax
  8015f2:	99                   	cltd   
  8015f3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015f6:	8d 49 04             	lea    0x4(%ecx),%ecx
  8015f9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8015fc:	eb 11                	jmp    80160f <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8015fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801601:	8b 50 04             	mov    0x4(%eax),%edx
  801604:	8b 00                	mov    (%eax),%eax
  801606:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801609:	8d 49 08             	lea    0x8(%ecx),%ecx
  80160c:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80160f:	89 d1                	mov    %edx,%ecx
  801611:	89 c2                	mov    %eax,%edx
            base = 8;
  801613:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  801618:	83 ec 0c             	sub    $0xc,%esp
  80161b:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80161f:	57                   	push   %edi
  801620:	ff 75 e0             	pushl  -0x20(%ebp)
  801623:	50                   	push   %eax
  801624:	51                   	push   %ecx
  801625:	52                   	push   %edx
  801626:	89 da                	mov    %ebx,%edx
  801628:	89 f0                	mov    %esi,%eax
  80162a:	e8 b6 fb ff ff       	call   8011e5 <printnum>
			break;
  80162f:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  801632:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801635:	83 c7 01             	add    $0x1,%edi
  801638:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80163c:	83 f8 25             	cmp    $0x25,%eax
  80163f:	0f 84 a6 fc ff ff    	je     8012eb <vprintfmt+0x1b>
			if (ch == '\0')
  801645:	85 c0                	test   %eax,%eax
  801647:	0f 84 ce 00 00 00    	je     80171b <vprintfmt+0x44b>
			putch(ch, putdat);
  80164d:	83 ec 08             	sub    $0x8,%esp
  801650:	53                   	push   %ebx
  801651:	50                   	push   %eax
  801652:	ff d6                	call   *%esi
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	eb dc                	jmp    801635 <vprintfmt+0x365>
		return va_arg(*ap, int);
  801659:	8b 45 14             	mov    0x14(%ebp),%eax
  80165c:	8b 10                	mov    (%eax),%edx
  80165e:	89 d0                	mov    %edx,%eax
  801660:	99                   	cltd   
  801661:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801664:	8d 49 04             	lea    0x4(%ecx),%ecx
  801667:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80166a:	eb a3                	jmp    80160f <vprintfmt+0x33f>
			putch('0', putdat);
  80166c:	83 ec 08             	sub    $0x8,%esp
  80166f:	53                   	push   %ebx
  801670:	6a 30                	push   $0x30
  801672:	ff d6                	call   *%esi
			putch('x', putdat);
  801674:	83 c4 08             	add    $0x8,%esp
  801677:	53                   	push   %ebx
  801678:	6a 78                	push   $0x78
  80167a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80167c:	8b 45 14             	mov    0x14(%ebp),%eax
  80167f:	8b 10                	mov    (%eax),%edx
  801681:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801686:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801689:	8d 40 04             	lea    0x4(%eax),%eax
  80168c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80168f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801694:	eb 82                	jmp    801618 <vprintfmt+0x348>
	if (lflag >= 2)
  801696:	83 f9 01             	cmp    $0x1,%ecx
  801699:	7f 1e                	jg     8016b9 <vprintfmt+0x3e9>
	else if (lflag)
  80169b:	85 c9                	test   %ecx,%ecx
  80169d:	74 32                	je     8016d1 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80169f:	8b 45 14             	mov    0x14(%ebp),%eax
  8016a2:	8b 10                	mov    (%eax),%edx
  8016a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016a9:	8d 40 04             	lea    0x4(%eax),%eax
  8016ac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016af:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8016b4:	e9 5f ff ff ff       	jmp    801618 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8016b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8016bc:	8b 10                	mov    (%eax),%edx
  8016be:	8b 48 04             	mov    0x4(%eax),%ecx
  8016c1:	8d 40 08             	lea    0x8(%eax),%eax
  8016c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016c7:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8016cc:	e9 47 ff ff ff       	jmp    801618 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8016d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8016d4:	8b 10                	mov    (%eax),%edx
  8016d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016db:	8d 40 04             	lea    0x4(%eax),%eax
  8016de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016e1:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8016e6:	e9 2d ff ff ff       	jmp    801618 <vprintfmt+0x348>
			putch(ch, putdat);
  8016eb:	83 ec 08             	sub    $0x8,%esp
  8016ee:	53                   	push   %ebx
  8016ef:	6a 25                	push   $0x25
  8016f1:	ff d6                	call   *%esi
			break;
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	e9 37 ff ff ff       	jmp    801632 <vprintfmt+0x362>
			putch('%', putdat);
  8016fb:	83 ec 08             	sub    $0x8,%esp
  8016fe:	53                   	push   %ebx
  8016ff:	6a 25                	push   $0x25
  801701:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801703:	83 c4 10             	add    $0x10,%esp
  801706:	89 f8                	mov    %edi,%eax
  801708:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80170c:	74 05                	je     801713 <vprintfmt+0x443>
  80170e:	83 e8 01             	sub    $0x1,%eax
  801711:	eb f5                	jmp    801708 <vprintfmt+0x438>
  801713:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801716:	e9 17 ff ff ff       	jmp    801632 <vprintfmt+0x362>
}
  80171b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80171e:	5b                   	pop    %ebx
  80171f:	5e                   	pop    %esi
  801720:	5f                   	pop    %edi
  801721:	5d                   	pop    %ebp
  801722:	c3                   	ret    

00801723 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801723:	f3 0f 1e fb          	endbr32 
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	83 ec 18             	sub    $0x18,%esp
  80172d:	8b 45 08             	mov    0x8(%ebp),%eax
  801730:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801733:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801736:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80173a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80173d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801744:	85 c0                	test   %eax,%eax
  801746:	74 26                	je     80176e <vsnprintf+0x4b>
  801748:	85 d2                	test   %edx,%edx
  80174a:	7e 22                	jle    80176e <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80174c:	ff 75 14             	pushl  0x14(%ebp)
  80174f:	ff 75 10             	pushl  0x10(%ebp)
  801752:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801755:	50                   	push   %eax
  801756:	68 8e 12 80 00       	push   $0x80128e
  80175b:	e8 70 fb ff ff       	call   8012d0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801760:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801763:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801766:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801769:	83 c4 10             	add    $0x10,%esp
}
  80176c:	c9                   	leave  
  80176d:	c3                   	ret    
		return -E_INVAL;
  80176e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801773:	eb f7                	jmp    80176c <vsnprintf+0x49>

00801775 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801775:	f3 0f 1e fb          	endbr32 
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80177f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801782:	50                   	push   %eax
  801783:	ff 75 10             	pushl  0x10(%ebp)
  801786:	ff 75 0c             	pushl  0xc(%ebp)
  801789:	ff 75 08             	pushl  0x8(%ebp)
  80178c:	e8 92 ff ff ff       	call   801723 <vsnprintf>
	va_end(ap);

	return rc;
}
  801791:	c9                   	leave  
  801792:	c3                   	ret    

00801793 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801793:	f3 0f 1e fb          	endbr32 
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80179d:	b8 00 00 00 00       	mov    $0x0,%eax
  8017a2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8017a6:	74 05                	je     8017ad <strlen+0x1a>
		n++;
  8017a8:	83 c0 01             	add    $0x1,%eax
  8017ab:	eb f5                	jmp    8017a2 <strlen+0xf>
	return n;
}
  8017ad:	5d                   	pop    %ebp
  8017ae:	c3                   	ret    

008017af <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8017af:	f3 0f 1e fb          	endbr32 
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8017bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c1:	39 d0                	cmp    %edx,%eax
  8017c3:	74 0d                	je     8017d2 <strnlen+0x23>
  8017c5:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8017c9:	74 05                	je     8017d0 <strnlen+0x21>
		n++;
  8017cb:	83 c0 01             	add    $0x1,%eax
  8017ce:	eb f1                	jmp    8017c1 <strnlen+0x12>
  8017d0:	89 c2                	mov    %eax,%edx
	return n;
}
  8017d2:	89 d0                	mov    %edx,%eax
  8017d4:	5d                   	pop    %ebp
  8017d5:	c3                   	ret    

008017d6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8017d6:	f3 0f 1e fb          	endbr32 
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	53                   	push   %ebx
  8017de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8017e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8017e9:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8017ed:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8017f0:	83 c0 01             	add    $0x1,%eax
  8017f3:	84 d2                	test   %dl,%dl
  8017f5:	75 f2                	jne    8017e9 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8017f7:	89 c8                	mov    %ecx,%eax
  8017f9:	5b                   	pop    %ebx
  8017fa:	5d                   	pop    %ebp
  8017fb:	c3                   	ret    

008017fc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017fc:	f3 0f 1e fb          	endbr32 
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	53                   	push   %ebx
  801804:	83 ec 10             	sub    $0x10,%esp
  801807:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80180a:	53                   	push   %ebx
  80180b:	e8 83 ff ff ff       	call   801793 <strlen>
  801810:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801813:	ff 75 0c             	pushl  0xc(%ebp)
  801816:	01 d8                	add    %ebx,%eax
  801818:	50                   	push   %eax
  801819:	e8 b8 ff ff ff       	call   8017d6 <strcpy>
	return dst;
}
  80181e:	89 d8                	mov    %ebx,%eax
  801820:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801823:	c9                   	leave  
  801824:	c3                   	ret    

00801825 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801825:	f3 0f 1e fb          	endbr32 
  801829:	55                   	push   %ebp
  80182a:	89 e5                	mov    %esp,%ebp
  80182c:	56                   	push   %esi
  80182d:	53                   	push   %ebx
  80182e:	8b 75 08             	mov    0x8(%ebp),%esi
  801831:	8b 55 0c             	mov    0xc(%ebp),%edx
  801834:	89 f3                	mov    %esi,%ebx
  801836:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801839:	89 f0                	mov    %esi,%eax
  80183b:	39 d8                	cmp    %ebx,%eax
  80183d:	74 11                	je     801850 <strncpy+0x2b>
		*dst++ = *src;
  80183f:	83 c0 01             	add    $0x1,%eax
  801842:	0f b6 0a             	movzbl (%edx),%ecx
  801845:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801848:	80 f9 01             	cmp    $0x1,%cl
  80184b:	83 da ff             	sbb    $0xffffffff,%edx
  80184e:	eb eb                	jmp    80183b <strncpy+0x16>
	}
	return ret;
}
  801850:	89 f0                	mov    %esi,%eax
  801852:	5b                   	pop    %ebx
  801853:	5e                   	pop    %esi
  801854:	5d                   	pop    %ebp
  801855:	c3                   	ret    

00801856 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801856:	f3 0f 1e fb          	endbr32 
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	56                   	push   %esi
  80185e:	53                   	push   %ebx
  80185f:	8b 75 08             	mov    0x8(%ebp),%esi
  801862:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801865:	8b 55 10             	mov    0x10(%ebp),%edx
  801868:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80186a:	85 d2                	test   %edx,%edx
  80186c:	74 21                	je     80188f <strlcpy+0x39>
  80186e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801872:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801874:	39 c2                	cmp    %eax,%edx
  801876:	74 14                	je     80188c <strlcpy+0x36>
  801878:	0f b6 19             	movzbl (%ecx),%ebx
  80187b:	84 db                	test   %bl,%bl
  80187d:	74 0b                	je     80188a <strlcpy+0x34>
			*dst++ = *src++;
  80187f:	83 c1 01             	add    $0x1,%ecx
  801882:	83 c2 01             	add    $0x1,%edx
  801885:	88 5a ff             	mov    %bl,-0x1(%edx)
  801888:	eb ea                	jmp    801874 <strlcpy+0x1e>
  80188a:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80188c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80188f:	29 f0                	sub    %esi,%eax
}
  801891:	5b                   	pop    %ebx
  801892:	5e                   	pop    %esi
  801893:	5d                   	pop    %ebp
  801894:	c3                   	ret    

00801895 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801895:	f3 0f 1e fb          	endbr32 
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80189f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8018a2:	0f b6 01             	movzbl (%ecx),%eax
  8018a5:	84 c0                	test   %al,%al
  8018a7:	74 0c                	je     8018b5 <strcmp+0x20>
  8018a9:	3a 02                	cmp    (%edx),%al
  8018ab:	75 08                	jne    8018b5 <strcmp+0x20>
		p++, q++;
  8018ad:	83 c1 01             	add    $0x1,%ecx
  8018b0:	83 c2 01             	add    $0x1,%edx
  8018b3:	eb ed                	jmp    8018a2 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8018b5:	0f b6 c0             	movzbl %al,%eax
  8018b8:	0f b6 12             	movzbl (%edx),%edx
  8018bb:	29 d0                	sub    %edx,%eax
}
  8018bd:	5d                   	pop    %ebp
  8018be:	c3                   	ret    

008018bf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8018bf:	f3 0f 1e fb          	endbr32 
  8018c3:	55                   	push   %ebp
  8018c4:	89 e5                	mov    %esp,%ebp
  8018c6:	53                   	push   %ebx
  8018c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018cd:	89 c3                	mov    %eax,%ebx
  8018cf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8018d2:	eb 06                	jmp    8018da <strncmp+0x1b>
		n--, p++, q++;
  8018d4:	83 c0 01             	add    $0x1,%eax
  8018d7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8018da:	39 d8                	cmp    %ebx,%eax
  8018dc:	74 16                	je     8018f4 <strncmp+0x35>
  8018de:	0f b6 08             	movzbl (%eax),%ecx
  8018e1:	84 c9                	test   %cl,%cl
  8018e3:	74 04                	je     8018e9 <strncmp+0x2a>
  8018e5:	3a 0a                	cmp    (%edx),%cl
  8018e7:	74 eb                	je     8018d4 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8018e9:	0f b6 00             	movzbl (%eax),%eax
  8018ec:	0f b6 12             	movzbl (%edx),%edx
  8018ef:	29 d0                	sub    %edx,%eax
}
  8018f1:	5b                   	pop    %ebx
  8018f2:	5d                   	pop    %ebp
  8018f3:	c3                   	ret    
		return 0;
  8018f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f9:	eb f6                	jmp    8018f1 <strncmp+0x32>

008018fb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8018fb:	f3 0f 1e fb          	endbr32 
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	8b 45 08             	mov    0x8(%ebp),%eax
  801905:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801909:	0f b6 10             	movzbl (%eax),%edx
  80190c:	84 d2                	test   %dl,%dl
  80190e:	74 09                	je     801919 <strchr+0x1e>
		if (*s == c)
  801910:	38 ca                	cmp    %cl,%dl
  801912:	74 0a                	je     80191e <strchr+0x23>
	for (; *s; s++)
  801914:	83 c0 01             	add    $0x1,%eax
  801917:	eb f0                	jmp    801909 <strchr+0xe>
			return (char *) s;
	return 0;
  801919:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80191e:	5d                   	pop    %ebp
  80191f:	c3                   	ret    

00801920 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801920:	f3 0f 1e fb          	endbr32 
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	8b 45 08             	mov    0x8(%ebp),%eax
  80192a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80192e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801931:	38 ca                	cmp    %cl,%dl
  801933:	74 09                	je     80193e <strfind+0x1e>
  801935:	84 d2                	test   %dl,%dl
  801937:	74 05                	je     80193e <strfind+0x1e>
	for (; *s; s++)
  801939:	83 c0 01             	add    $0x1,%eax
  80193c:	eb f0                	jmp    80192e <strfind+0xe>
			break;
	return (char *) s;
}
  80193e:	5d                   	pop    %ebp
  80193f:	c3                   	ret    

00801940 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801940:	f3 0f 1e fb          	endbr32 
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	57                   	push   %edi
  801948:	56                   	push   %esi
  801949:	53                   	push   %ebx
  80194a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80194d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801950:	85 c9                	test   %ecx,%ecx
  801952:	74 31                	je     801985 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801954:	89 f8                	mov    %edi,%eax
  801956:	09 c8                	or     %ecx,%eax
  801958:	a8 03                	test   $0x3,%al
  80195a:	75 23                	jne    80197f <memset+0x3f>
		c &= 0xFF;
  80195c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801960:	89 d3                	mov    %edx,%ebx
  801962:	c1 e3 08             	shl    $0x8,%ebx
  801965:	89 d0                	mov    %edx,%eax
  801967:	c1 e0 18             	shl    $0x18,%eax
  80196a:	89 d6                	mov    %edx,%esi
  80196c:	c1 e6 10             	shl    $0x10,%esi
  80196f:	09 f0                	or     %esi,%eax
  801971:	09 c2                	or     %eax,%edx
  801973:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801975:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801978:	89 d0                	mov    %edx,%eax
  80197a:	fc                   	cld    
  80197b:	f3 ab                	rep stos %eax,%es:(%edi)
  80197d:	eb 06                	jmp    801985 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80197f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801982:	fc                   	cld    
  801983:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801985:	89 f8                	mov    %edi,%eax
  801987:	5b                   	pop    %ebx
  801988:	5e                   	pop    %esi
  801989:	5f                   	pop    %edi
  80198a:	5d                   	pop    %ebp
  80198b:	c3                   	ret    

0080198c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80198c:	f3 0f 1e fb          	endbr32 
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	57                   	push   %edi
  801994:	56                   	push   %esi
  801995:	8b 45 08             	mov    0x8(%ebp),%eax
  801998:	8b 75 0c             	mov    0xc(%ebp),%esi
  80199b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80199e:	39 c6                	cmp    %eax,%esi
  8019a0:	73 32                	jae    8019d4 <memmove+0x48>
  8019a2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8019a5:	39 c2                	cmp    %eax,%edx
  8019a7:	76 2b                	jbe    8019d4 <memmove+0x48>
		s += n;
		d += n;
  8019a9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019ac:	89 fe                	mov    %edi,%esi
  8019ae:	09 ce                	or     %ecx,%esi
  8019b0:	09 d6                	or     %edx,%esi
  8019b2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8019b8:	75 0e                	jne    8019c8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8019ba:	83 ef 04             	sub    $0x4,%edi
  8019bd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8019c0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8019c3:	fd                   	std    
  8019c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019c6:	eb 09                	jmp    8019d1 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8019c8:	83 ef 01             	sub    $0x1,%edi
  8019cb:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8019ce:	fd                   	std    
  8019cf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8019d1:	fc                   	cld    
  8019d2:	eb 1a                	jmp    8019ee <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019d4:	89 c2                	mov    %eax,%edx
  8019d6:	09 ca                	or     %ecx,%edx
  8019d8:	09 f2                	or     %esi,%edx
  8019da:	f6 c2 03             	test   $0x3,%dl
  8019dd:	75 0a                	jne    8019e9 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8019df:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8019e2:	89 c7                	mov    %eax,%edi
  8019e4:	fc                   	cld    
  8019e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019e7:	eb 05                	jmp    8019ee <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8019e9:	89 c7                	mov    %eax,%edi
  8019eb:	fc                   	cld    
  8019ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8019ee:	5e                   	pop    %esi
  8019ef:	5f                   	pop    %edi
  8019f0:	5d                   	pop    %ebp
  8019f1:	c3                   	ret    

008019f2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8019f2:	f3 0f 1e fb          	endbr32 
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8019fc:	ff 75 10             	pushl  0x10(%ebp)
  8019ff:	ff 75 0c             	pushl  0xc(%ebp)
  801a02:	ff 75 08             	pushl  0x8(%ebp)
  801a05:	e8 82 ff ff ff       	call   80198c <memmove>
}
  801a0a:	c9                   	leave  
  801a0b:	c3                   	ret    

00801a0c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801a0c:	f3 0f 1e fb          	endbr32 
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	56                   	push   %esi
  801a14:	53                   	push   %ebx
  801a15:	8b 45 08             	mov    0x8(%ebp),%eax
  801a18:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a1b:	89 c6                	mov    %eax,%esi
  801a1d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a20:	39 f0                	cmp    %esi,%eax
  801a22:	74 1c                	je     801a40 <memcmp+0x34>
		if (*s1 != *s2)
  801a24:	0f b6 08             	movzbl (%eax),%ecx
  801a27:	0f b6 1a             	movzbl (%edx),%ebx
  801a2a:	38 d9                	cmp    %bl,%cl
  801a2c:	75 08                	jne    801a36 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801a2e:	83 c0 01             	add    $0x1,%eax
  801a31:	83 c2 01             	add    $0x1,%edx
  801a34:	eb ea                	jmp    801a20 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801a36:	0f b6 c1             	movzbl %cl,%eax
  801a39:	0f b6 db             	movzbl %bl,%ebx
  801a3c:	29 d8                	sub    %ebx,%eax
  801a3e:	eb 05                	jmp    801a45 <memcmp+0x39>
	}

	return 0;
  801a40:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a45:	5b                   	pop    %ebx
  801a46:	5e                   	pop    %esi
  801a47:	5d                   	pop    %ebp
  801a48:	c3                   	ret    

00801a49 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a49:	f3 0f 1e fb          	endbr32 
  801a4d:	55                   	push   %ebp
  801a4e:	89 e5                	mov    %esp,%ebp
  801a50:	8b 45 08             	mov    0x8(%ebp),%eax
  801a53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a56:	89 c2                	mov    %eax,%edx
  801a58:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a5b:	39 d0                	cmp    %edx,%eax
  801a5d:	73 09                	jae    801a68 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a5f:	38 08                	cmp    %cl,(%eax)
  801a61:	74 05                	je     801a68 <memfind+0x1f>
	for (; s < ends; s++)
  801a63:	83 c0 01             	add    $0x1,%eax
  801a66:	eb f3                	jmp    801a5b <memfind+0x12>
			break;
	return (void *) s;
}
  801a68:	5d                   	pop    %ebp
  801a69:	c3                   	ret    

00801a6a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a6a:	f3 0f 1e fb          	endbr32 
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	57                   	push   %edi
  801a72:	56                   	push   %esi
  801a73:	53                   	push   %ebx
  801a74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a7a:	eb 03                	jmp    801a7f <strtol+0x15>
		s++;
  801a7c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801a7f:	0f b6 01             	movzbl (%ecx),%eax
  801a82:	3c 20                	cmp    $0x20,%al
  801a84:	74 f6                	je     801a7c <strtol+0x12>
  801a86:	3c 09                	cmp    $0x9,%al
  801a88:	74 f2                	je     801a7c <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801a8a:	3c 2b                	cmp    $0x2b,%al
  801a8c:	74 2a                	je     801ab8 <strtol+0x4e>
	int neg = 0;
  801a8e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801a93:	3c 2d                	cmp    $0x2d,%al
  801a95:	74 2b                	je     801ac2 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a97:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a9d:	75 0f                	jne    801aae <strtol+0x44>
  801a9f:	80 39 30             	cmpb   $0x30,(%ecx)
  801aa2:	74 28                	je     801acc <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801aa4:	85 db                	test   %ebx,%ebx
  801aa6:	b8 0a 00 00 00       	mov    $0xa,%eax
  801aab:	0f 44 d8             	cmove  %eax,%ebx
  801aae:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801ab6:	eb 46                	jmp    801afe <strtol+0x94>
		s++;
  801ab8:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801abb:	bf 00 00 00 00       	mov    $0x0,%edi
  801ac0:	eb d5                	jmp    801a97 <strtol+0x2d>
		s++, neg = 1;
  801ac2:	83 c1 01             	add    $0x1,%ecx
  801ac5:	bf 01 00 00 00       	mov    $0x1,%edi
  801aca:	eb cb                	jmp    801a97 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801acc:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ad0:	74 0e                	je     801ae0 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801ad2:	85 db                	test   %ebx,%ebx
  801ad4:	75 d8                	jne    801aae <strtol+0x44>
		s++, base = 8;
  801ad6:	83 c1 01             	add    $0x1,%ecx
  801ad9:	bb 08 00 00 00       	mov    $0x8,%ebx
  801ade:	eb ce                	jmp    801aae <strtol+0x44>
		s += 2, base = 16;
  801ae0:	83 c1 02             	add    $0x2,%ecx
  801ae3:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ae8:	eb c4                	jmp    801aae <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801aea:	0f be d2             	movsbl %dl,%edx
  801aed:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801af0:	3b 55 10             	cmp    0x10(%ebp),%edx
  801af3:	7d 3a                	jge    801b2f <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801af5:	83 c1 01             	add    $0x1,%ecx
  801af8:	0f af 45 10          	imul   0x10(%ebp),%eax
  801afc:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801afe:	0f b6 11             	movzbl (%ecx),%edx
  801b01:	8d 72 d0             	lea    -0x30(%edx),%esi
  801b04:	89 f3                	mov    %esi,%ebx
  801b06:	80 fb 09             	cmp    $0x9,%bl
  801b09:	76 df                	jbe    801aea <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801b0b:	8d 72 9f             	lea    -0x61(%edx),%esi
  801b0e:	89 f3                	mov    %esi,%ebx
  801b10:	80 fb 19             	cmp    $0x19,%bl
  801b13:	77 08                	ja     801b1d <strtol+0xb3>
			dig = *s - 'a' + 10;
  801b15:	0f be d2             	movsbl %dl,%edx
  801b18:	83 ea 57             	sub    $0x57,%edx
  801b1b:	eb d3                	jmp    801af0 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801b1d:	8d 72 bf             	lea    -0x41(%edx),%esi
  801b20:	89 f3                	mov    %esi,%ebx
  801b22:	80 fb 19             	cmp    $0x19,%bl
  801b25:	77 08                	ja     801b2f <strtol+0xc5>
			dig = *s - 'A' + 10;
  801b27:	0f be d2             	movsbl %dl,%edx
  801b2a:	83 ea 37             	sub    $0x37,%edx
  801b2d:	eb c1                	jmp    801af0 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801b2f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b33:	74 05                	je     801b3a <strtol+0xd0>
		*endptr = (char *) s;
  801b35:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b38:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801b3a:	89 c2                	mov    %eax,%edx
  801b3c:	f7 da                	neg    %edx
  801b3e:	85 ff                	test   %edi,%edi
  801b40:	0f 45 c2             	cmovne %edx,%eax
}
  801b43:	5b                   	pop    %ebx
  801b44:	5e                   	pop    %esi
  801b45:	5f                   	pop    %edi
  801b46:	5d                   	pop    %ebp
  801b47:	c3                   	ret    

00801b48 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b48:	f3 0f 1e fb          	endbr32 
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	56                   	push   %esi
  801b50:	53                   	push   %ebx
  801b51:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b54:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b57:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801b5a:	85 c0                	test   %eax,%eax
  801b5c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b61:	0f 44 c2             	cmove  %edx,%eax
  801b64:	83 ec 0c             	sub    $0xc,%esp
  801b67:	50                   	push   %eax
  801b68:	e8 ef e7 ff ff       	call   80035c <sys_ipc_recv>
  801b6d:	83 c4 10             	add    $0x10,%esp
  801b70:	85 c0                	test   %eax,%eax
  801b72:	78 24                	js     801b98 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801b74:	85 f6                	test   %esi,%esi
  801b76:	74 0a                	je     801b82 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801b78:	a1 04 40 80 00       	mov    0x804004,%eax
  801b7d:	8b 40 78             	mov    0x78(%eax),%eax
  801b80:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801b82:	85 db                	test   %ebx,%ebx
  801b84:	74 0a                	je     801b90 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801b86:	a1 04 40 80 00       	mov    0x804004,%eax
  801b8b:	8b 40 74             	mov    0x74(%eax),%eax
  801b8e:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801b90:	a1 04 40 80 00       	mov    0x804004,%eax
  801b95:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b9b:	5b                   	pop    %ebx
  801b9c:	5e                   	pop    %esi
  801b9d:	5d                   	pop    %ebp
  801b9e:	c3                   	ret    

00801b9f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b9f:	f3 0f 1e fb          	endbr32 
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	57                   	push   %edi
  801ba7:	56                   	push   %esi
  801ba8:	53                   	push   %ebx
  801ba9:	83 ec 1c             	sub    $0x1c,%esp
  801bac:	8b 45 10             	mov    0x10(%ebp),%eax
  801baf:	85 c0                	test   %eax,%eax
  801bb1:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801bb6:	0f 45 d0             	cmovne %eax,%edx
  801bb9:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801bbb:	be 01 00 00 00       	mov    $0x1,%esi
  801bc0:	eb 1f                	jmp    801be1 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801bc2:	e8 a6 e5 ff ff       	call   80016d <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801bc7:	83 c3 01             	add    $0x1,%ebx
  801bca:	39 de                	cmp    %ebx,%esi
  801bcc:	7f f4                	jg     801bc2 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801bce:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801bd0:	83 fe 11             	cmp    $0x11,%esi
  801bd3:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd8:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801bdb:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801bdf:	75 1c                	jne    801bfd <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801be1:	ff 75 14             	pushl  0x14(%ebp)
  801be4:	57                   	push   %edi
  801be5:	ff 75 0c             	pushl  0xc(%ebp)
  801be8:	ff 75 08             	pushl  0x8(%ebp)
  801beb:	e8 45 e7 ff ff       	call   800335 <sys_ipc_try_send>
  801bf0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801bf3:	83 c4 10             	add    $0x10,%esp
  801bf6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bfb:	eb cd                	jmp    801bca <ipc_send+0x2b>
}
  801bfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c00:	5b                   	pop    %ebx
  801c01:	5e                   	pop    %esi
  801c02:	5f                   	pop    %edi
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    

00801c05 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c05:	f3 0f 1e fb          	endbr32 
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c0f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c14:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c17:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c1d:	8b 52 50             	mov    0x50(%edx),%edx
  801c20:	39 ca                	cmp    %ecx,%edx
  801c22:	74 11                	je     801c35 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801c24:	83 c0 01             	add    $0x1,%eax
  801c27:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c2c:	75 e6                	jne    801c14 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801c2e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c33:	eb 0b                	jmp    801c40 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c35:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c38:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c3d:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c40:	5d                   	pop    %ebp
  801c41:	c3                   	ret    

00801c42 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c42:	f3 0f 1e fb          	endbr32 
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c4c:	89 c2                	mov    %eax,%edx
  801c4e:	c1 ea 16             	shr    $0x16,%edx
  801c51:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c58:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c5d:	f6 c1 01             	test   $0x1,%cl
  801c60:	74 1c                	je     801c7e <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c62:	c1 e8 0c             	shr    $0xc,%eax
  801c65:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c6c:	a8 01                	test   $0x1,%al
  801c6e:	74 0e                	je     801c7e <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c70:	c1 e8 0c             	shr    $0xc,%eax
  801c73:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c7a:	ef 
  801c7b:	0f b7 d2             	movzwl %dx,%edx
}
  801c7e:	89 d0                	mov    %edx,%eax
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    
  801c82:	66 90                	xchg   %ax,%ax
  801c84:	66 90                	xchg   %ax,%ax
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
