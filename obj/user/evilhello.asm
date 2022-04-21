
obj/user/evilhello:     file format elf32-i386


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

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003d:	6a 64                	push   $0x64
  80003f:	68 0c 00 10 f0       	push   $0xf010000c
  800044:	e8 77 00 00 00       	call   8000c0 <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

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
  800139:	68 ca 1e 80 00       	push   $0x801eca
  80013e:	6a 23                	push   $0x23
  800140:	68 e7 1e 80 00       	push   $0x801ee7
  800145:	e8 70 0f 00 00       	call   8010ba <_panic>

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
  8001c6:	68 ca 1e 80 00       	push   $0x801eca
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 e7 1e 80 00       	push   $0x801ee7
  8001d2:	e8 e3 0e 00 00       	call   8010ba <_panic>

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
  80020c:	68 ca 1e 80 00       	push   $0x801eca
  800211:	6a 23                	push   $0x23
  800213:	68 e7 1e 80 00       	push   $0x801ee7
  800218:	e8 9d 0e 00 00       	call   8010ba <_panic>

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
  800252:	68 ca 1e 80 00       	push   $0x801eca
  800257:	6a 23                	push   $0x23
  800259:	68 e7 1e 80 00       	push   $0x801ee7
  80025e:	e8 57 0e 00 00       	call   8010ba <_panic>

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
  800298:	68 ca 1e 80 00       	push   $0x801eca
  80029d:	6a 23                	push   $0x23
  80029f:	68 e7 1e 80 00       	push   $0x801ee7
  8002a4:	e8 11 0e 00 00       	call   8010ba <_panic>

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
  8002de:	68 ca 1e 80 00       	push   $0x801eca
  8002e3:	6a 23                	push   $0x23
  8002e5:	68 e7 1e 80 00       	push   $0x801ee7
  8002ea:	e8 cb 0d 00 00       	call   8010ba <_panic>

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
  800324:	68 ca 1e 80 00       	push   $0x801eca
  800329:	6a 23                	push   $0x23
  80032b:	68 e7 1e 80 00       	push   $0x801ee7
  800330:	e8 85 0d 00 00       	call   8010ba <_panic>

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
  800390:	68 ca 1e 80 00       	push   $0x801eca
  800395:	6a 23                	push   $0x23
  800397:	68 e7 1e 80 00       	push   $0x801ee7
  80039c:	e8 19 0d 00 00       	call   8010ba <_panic>

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
  800487:	ba 74 1f 80 00       	mov    $0x801f74,%edx
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
  8004ab:	68 f8 1e 80 00       	push   $0x801ef8
  8004b0:	e8 ec 0c 00 00       	call   8011a1 <cprintf>
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
  800719:	68 39 1f 80 00       	push   $0x801f39
  80071e:	e8 7e 0a 00 00       	call   8011a1 <cprintf>
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
  8007ea:	68 55 1f 80 00       	push   $0x801f55
  8007ef:	e8 ad 09 00 00       	call   8011a1 <cprintf>
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
  80089a:	68 18 1f 80 00       	push   $0x801f18
  80089f:	e8 fd 08 00 00       	call   8011a1 <cprintf>
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
  80093e:	e8 cf 01 00 00       	call   800b12 <open>
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
  800990:	e8 de 11 00 00       	call   801b73 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800995:	83 c4 0c             	add    $0xc,%esp
  800998:	6a 00                	push   $0x0
  80099a:	53                   	push   %ebx
  80099b:	6a 00                	push   $0x0
  80099d:	e8 7a 11 00 00       	call   801b1c <ipc_recv>
}
  8009a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009a5:	5b                   	pop    %ebx
  8009a6:	5e                   	pop    %esi
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009a9:	83 ec 0c             	sub    $0xc,%esp
  8009ac:	6a 01                	push   $0x1
  8009ae:	e8 26 12 00 00       	call   801bd9 <ipc_find_env>
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
  800a46:	e8 5f 0d 00 00       	call   8017aa <strcpy>
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
	panic("devfile_write not implemented");
  800a78:	68 84 1f 80 00       	push   $0x801f84
  800a7d:	68 90 00 00 00       	push   $0x90
  800a82:	68 a2 1f 80 00       	push   $0x801fa2
  800a87:	e8 2e 06 00 00       	call   8010ba <_panic>

00800a8c <devfile_read>:
{
  800a8c:	f3 0f 1e fb          	endbr32 
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	56                   	push   %esi
  800a94:	53                   	push   %ebx
  800a95:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a98:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a9e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800aa3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800aa9:	ba 00 00 00 00       	mov    $0x0,%edx
  800aae:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab3:	e8 b8 fe ff ff       	call   800970 <fsipc>
  800ab8:	89 c3                	mov    %eax,%ebx
  800aba:	85 c0                	test   %eax,%eax
  800abc:	78 1f                	js     800add <devfile_read+0x51>
	assert(r <= n);
  800abe:	39 f0                	cmp    %esi,%eax
  800ac0:	77 24                	ja     800ae6 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800ac2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac7:	7f 33                	jg     800afc <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ac9:	83 ec 04             	sub    $0x4,%esp
  800acc:	50                   	push   %eax
  800acd:	68 00 50 80 00       	push   $0x805000
  800ad2:	ff 75 0c             	pushl  0xc(%ebp)
  800ad5:	e8 86 0e 00 00       	call   801960 <memmove>
	return r;
  800ada:	83 c4 10             	add    $0x10,%esp
}
  800add:	89 d8                	mov    %ebx,%eax
  800adf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    
	assert(r <= n);
  800ae6:	68 ad 1f 80 00       	push   $0x801fad
  800aeb:	68 b4 1f 80 00       	push   $0x801fb4
  800af0:	6a 7c                	push   $0x7c
  800af2:	68 a2 1f 80 00       	push   $0x801fa2
  800af7:	e8 be 05 00 00       	call   8010ba <_panic>
	assert(r <= PGSIZE);
  800afc:	68 c9 1f 80 00       	push   $0x801fc9
  800b01:	68 b4 1f 80 00       	push   $0x801fb4
  800b06:	6a 7d                	push   $0x7d
  800b08:	68 a2 1f 80 00       	push   $0x801fa2
  800b0d:	e8 a8 05 00 00       	call   8010ba <_panic>

00800b12 <open>:
{
  800b12:	f3 0f 1e fb          	endbr32 
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	83 ec 1c             	sub    $0x1c,%esp
  800b1e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b21:	56                   	push   %esi
  800b22:	e8 40 0c 00 00       	call   801767 <strlen>
  800b27:	83 c4 10             	add    $0x10,%esp
  800b2a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b2f:	7f 6c                	jg     800b9d <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800b31:	83 ec 0c             	sub    $0xc,%esp
  800b34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b37:	50                   	push   %eax
  800b38:	e8 93 f8 ff ff       	call   8003d0 <fd_alloc>
  800b3d:	89 c3                	mov    %eax,%ebx
  800b3f:	83 c4 10             	add    $0x10,%esp
  800b42:	85 c0                	test   %eax,%eax
  800b44:	78 3c                	js     800b82 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b46:	83 ec 08             	sub    $0x8,%esp
  800b49:	56                   	push   %esi
  800b4a:	68 00 50 80 00       	push   $0x805000
  800b4f:	e8 56 0c 00 00       	call   8017aa <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b57:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b64:	e8 07 fe ff ff       	call   800970 <fsipc>
  800b69:	89 c3                	mov    %eax,%ebx
  800b6b:	83 c4 10             	add    $0x10,%esp
  800b6e:	85 c0                	test   %eax,%eax
  800b70:	78 19                	js     800b8b <open+0x79>
	return fd2num(fd);
  800b72:	83 ec 0c             	sub    $0xc,%esp
  800b75:	ff 75 f4             	pushl  -0xc(%ebp)
  800b78:	e8 24 f8 ff ff       	call   8003a1 <fd2num>
  800b7d:	89 c3                	mov    %eax,%ebx
  800b7f:	83 c4 10             	add    $0x10,%esp
}
  800b82:	89 d8                	mov    %ebx,%eax
  800b84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b87:	5b                   	pop    %ebx
  800b88:	5e                   	pop    %esi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    
		fd_close(fd, 0);
  800b8b:	83 ec 08             	sub    $0x8,%esp
  800b8e:	6a 00                	push   $0x0
  800b90:	ff 75 f4             	pushl  -0xc(%ebp)
  800b93:	e8 3c f9 ff ff       	call   8004d4 <fd_close>
		return r;
  800b98:	83 c4 10             	add    $0x10,%esp
  800b9b:	eb e5                	jmp    800b82 <open+0x70>
		return -E_BAD_PATH;
  800b9d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800ba2:	eb de                	jmp    800b82 <open+0x70>

00800ba4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ba4:	f3 0f 1e fb          	endbr32 
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bae:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb3:	b8 08 00 00 00       	mov    $0x8,%eax
  800bb8:	e8 b3 fd ff ff       	call   800970 <fsipc>
}
  800bbd:	c9                   	leave  
  800bbe:	c3                   	ret    

00800bbf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bbf:	f3 0f 1e fb          	endbr32 
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bcb:	83 ec 0c             	sub    $0xc,%esp
  800bce:	ff 75 08             	pushl  0x8(%ebp)
  800bd1:	e8 df f7 ff ff       	call   8003b5 <fd2data>
  800bd6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bd8:	83 c4 08             	add    $0x8,%esp
  800bdb:	68 d5 1f 80 00       	push   $0x801fd5
  800be0:	53                   	push   %ebx
  800be1:	e8 c4 0b 00 00       	call   8017aa <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800be6:	8b 46 04             	mov    0x4(%esi),%eax
  800be9:	2b 06                	sub    (%esi),%eax
  800beb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bf1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bf8:	00 00 00 
	stat->st_dev = &devpipe;
  800bfb:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c02:	30 80 00 
	return 0;
}
  800c05:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c11:	f3 0f 1e fb          	endbr32 
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	53                   	push   %ebx
  800c19:	83 ec 0c             	sub    $0xc,%esp
  800c1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c1f:	53                   	push   %ebx
  800c20:	6a 00                	push   $0x0
  800c22:	e8 f6 f5 ff ff       	call   80021d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c27:	89 1c 24             	mov    %ebx,(%esp)
  800c2a:	e8 86 f7 ff ff       	call   8003b5 <fd2data>
  800c2f:	83 c4 08             	add    $0x8,%esp
  800c32:	50                   	push   %eax
  800c33:	6a 00                	push   $0x0
  800c35:	e8 e3 f5 ff ff       	call   80021d <sys_page_unmap>
}
  800c3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c3d:	c9                   	leave  
  800c3e:	c3                   	ret    

00800c3f <_pipeisclosed>:
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	83 ec 1c             	sub    $0x1c,%esp
  800c48:	89 c7                	mov    %eax,%edi
  800c4a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c4c:	a1 04 40 80 00       	mov    0x804004,%eax
  800c51:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c54:	83 ec 0c             	sub    $0xc,%esp
  800c57:	57                   	push   %edi
  800c58:	e8 b9 0f 00 00       	call   801c16 <pageref>
  800c5d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c60:	89 34 24             	mov    %esi,(%esp)
  800c63:	e8 ae 0f 00 00       	call   801c16 <pageref>
		nn = thisenv->env_runs;
  800c68:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c6e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c71:	83 c4 10             	add    $0x10,%esp
  800c74:	39 cb                	cmp    %ecx,%ebx
  800c76:	74 1b                	je     800c93 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c78:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c7b:	75 cf                	jne    800c4c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c7d:	8b 42 58             	mov    0x58(%edx),%eax
  800c80:	6a 01                	push   $0x1
  800c82:	50                   	push   %eax
  800c83:	53                   	push   %ebx
  800c84:	68 dc 1f 80 00       	push   $0x801fdc
  800c89:	e8 13 05 00 00       	call   8011a1 <cprintf>
  800c8e:	83 c4 10             	add    $0x10,%esp
  800c91:	eb b9                	jmp    800c4c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c93:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c96:	0f 94 c0             	sete   %al
  800c99:	0f b6 c0             	movzbl %al,%eax
}
  800c9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <devpipe_write>:
{
  800ca4:	f3 0f 1e fb          	endbr32 
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	57                   	push   %edi
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
  800cae:	83 ec 28             	sub    $0x28,%esp
  800cb1:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800cb4:	56                   	push   %esi
  800cb5:	e8 fb f6 ff ff       	call   8003b5 <fd2data>
  800cba:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cbc:	83 c4 10             	add    $0x10,%esp
  800cbf:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cc7:	74 4f                	je     800d18 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cc9:	8b 43 04             	mov    0x4(%ebx),%eax
  800ccc:	8b 0b                	mov    (%ebx),%ecx
  800cce:	8d 51 20             	lea    0x20(%ecx),%edx
  800cd1:	39 d0                	cmp    %edx,%eax
  800cd3:	72 14                	jb     800ce9 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800cd5:	89 da                	mov    %ebx,%edx
  800cd7:	89 f0                	mov    %esi,%eax
  800cd9:	e8 61 ff ff ff       	call   800c3f <_pipeisclosed>
  800cde:	85 c0                	test   %eax,%eax
  800ce0:	75 3b                	jne    800d1d <devpipe_write+0x79>
			sys_yield();
  800ce2:	e8 86 f4 ff ff       	call   80016d <sys_yield>
  800ce7:	eb e0                	jmp    800cc9 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ce9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cec:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cf0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cf3:	89 c2                	mov    %eax,%edx
  800cf5:	c1 fa 1f             	sar    $0x1f,%edx
  800cf8:	89 d1                	mov    %edx,%ecx
  800cfa:	c1 e9 1b             	shr    $0x1b,%ecx
  800cfd:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800d00:	83 e2 1f             	and    $0x1f,%edx
  800d03:	29 ca                	sub    %ecx,%edx
  800d05:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800d09:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d0d:	83 c0 01             	add    $0x1,%eax
  800d10:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800d13:	83 c7 01             	add    $0x1,%edi
  800d16:	eb ac                	jmp    800cc4 <devpipe_write+0x20>
	return i;
  800d18:	8b 45 10             	mov    0x10(%ebp),%eax
  800d1b:	eb 05                	jmp    800d22 <devpipe_write+0x7e>
				return 0;
  800d1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <devpipe_read>:
{
  800d2a:	f3 0f 1e fb          	endbr32 
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	83 ec 18             	sub    $0x18,%esp
  800d37:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800d3a:	57                   	push   %edi
  800d3b:	e8 75 f6 ff ff       	call   8003b5 <fd2data>
  800d40:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d42:	83 c4 10             	add    $0x10,%esp
  800d45:	be 00 00 00 00       	mov    $0x0,%esi
  800d4a:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d4d:	75 14                	jne    800d63 <devpipe_read+0x39>
	return i;
  800d4f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d52:	eb 02                	jmp    800d56 <devpipe_read+0x2c>
				return i;
  800d54:	89 f0                	mov    %esi,%eax
}
  800d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    
			sys_yield();
  800d5e:	e8 0a f4 ff ff       	call   80016d <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d63:	8b 03                	mov    (%ebx),%eax
  800d65:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d68:	75 18                	jne    800d82 <devpipe_read+0x58>
			if (i > 0)
  800d6a:	85 f6                	test   %esi,%esi
  800d6c:	75 e6                	jne    800d54 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d6e:	89 da                	mov    %ebx,%edx
  800d70:	89 f8                	mov    %edi,%eax
  800d72:	e8 c8 fe ff ff       	call   800c3f <_pipeisclosed>
  800d77:	85 c0                	test   %eax,%eax
  800d79:	74 e3                	je     800d5e <devpipe_read+0x34>
				return 0;
  800d7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d80:	eb d4                	jmp    800d56 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d82:	99                   	cltd   
  800d83:	c1 ea 1b             	shr    $0x1b,%edx
  800d86:	01 d0                	add    %edx,%eax
  800d88:	83 e0 1f             	and    $0x1f,%eax
  800d8b:	29 d0                	sub    %edx,%eax
  800d8d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d98:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d9b:	83 c6 01             	add    $0x1,%esi
  800d9e:	eb aa                	jmp    800d4a <devpipe_read+0x20>

00800da0 <pipe>:
{
  800da0:	f3 0f 1e fb          	endbr32 
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
  800da9:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800dac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800daf:	50                   	push   %eax
  800db0:	e8 1b f6 ff ff       	call   8003d0 <fd_alloc>
  800db5:	89 c3                	mov    %eax,%ebx
  800db7:	83 c4 10             	add    $0x10,%esp
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	0f 88 23 01 00 00    	js     800ee5 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc2:	83 ec 04             	sub    $0x4,%esp
  800dc5:	68 07 04 00 00       	push   $0x407
  800dca:	ff 75 f4             	pushl  -0xc(%ebp)
  800dcd:	6a 00                	push   $0x0
  800dcf:	e8 bc f3 ff ff       	call   800190 <sys_page_alloc>
  800dd4:	89 c3                	mov    %eax,%ebx
  800dd6:	83 c4 10             	add    $0x10,%esp
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	0f 88 04 01 00 00    	js     800ee5 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800de1:	83 ec 0c             	sub    $0xc,%esp
  800de4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800de7:	50                   	push   %eax
  800de8:	e8 e3 f5 ff ff       	call   8003d0 <fd_alloc>
  800ded:	89 c3                	mov    %eax,%ebx
  800def:	83 c4 10             	add    $0x10,%esp
  800df2:	85 c0                	test   %eax,%eax
  800df4:	0f 88 db 00 00 00    	js     800ed5 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dfa:	83 ec 04             	sub    $0x4,%esp
  800dfd:	68 07 04 00 00       	push   $0x407
  800e02:	ff 75 f0             	pushl  -0x10(%ebp)
  800e05:	6a 00                	push   $0x0
  800e07:	e8 84 f3 ff ff       	call   800190 <sys_page_alloc>
  800e0c:	89 c3                	mov    %eax,%ebx
  800e0e:	83 c4 10             	add    $0x10,%esp
  800e11:	85 c0                	test   %eax,%eax
  800e13:	0f 88 bc 00 00 00    	js     800ed5 <pipe+0x135>
	va = fd2data(fd0);
  800e19:	83 ec 0c             	sub    $0xc,%esp
  800e1c:	ff 75 f4             	pushl  -0xc(%ebp)
  800e1f:	e8 91 f5 ff ff       	call   8003b5 <fd2data>
  800e24:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e26:	83 c4 0c             	add    $0xc,%esp
  800e29:	68 07 04 00 00       	push   $0x407
  800e2e:	50                   	push   %eax
  800e2f:	6a 00                	push   $0x0
  800e31:	e8 5a f3 ff ff       	call   800190 <sys_page_alloc>
  800e36:	89 c3                	mov    %eax,%ebx
  800e38:	83 c4 10             	add    $0x10,%esp
  800e3b:	85 c0                	test   %eax,%eax
  800e3d:	0f 88 82 00 00 00    	js     800ec5 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e43:	83 ec 0c             	sub    $0xc,%esp
  800e46:	ff 75 f0             	pushl  -0x10(%ebp)
  800e49:	e8 67 f5 ff ff       	call   8003b5 <fd2data>
  800e4e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e55:	50                   	push   %eax
  800e56:	6a 00                	push   $0x0
  800e58:	56                   	push   %esi
  800e59:	6a 00                	push   $0x0
  800e5b:	e8 77 f3 ff ff       	call   8001d7 <sys_page_map>
  800e60:	89 c3                	mov    %eax,%ebx
  800e62:	83 c4 20             	add    $0x20,%esp
  800e65:	85 c0                	test   %eax,%eax
  800e67:	78 4e                	js     800eb7 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e69:	a1 20 30 80 00       	mov    0x803020,%eax
  800e6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e71:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e73:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e76:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e7d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e80:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e85:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e8c:	83 ec 0c             	sub    $0xc,%esp
  800e8f:	ff 75 f4             	pushl  -0xc(%ebp)
  800e92:	e8 0a f5 ff ff       	call   8003a1 <fd2num>
  800e97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e9a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e9c:	83 c4 04             	add    $0x4,%esp
  800e9f:	ff 75 f0             	pushl  -0x10(%ebp)
  800ea2:	e8 fa f4 ff ff       	call   8003a1 <fd2num>
  800ea7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eaa:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800ead:	83 c4 10             	add    $0x10,%esp
  800eb0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb5:	eb 2e                	jmp    800ee5 <pipe+0x145>
	sys_page_unmap(0, va);
  800eb7:	83 ec 08             	sub    $0x8,%esp
  800eba:	56                   	push   %esi
  800ebb:	6a 00                	push   $0x0
  800ebd:	e8 5b f3 ff ff       	call   80021d <sys_page_unmap>
  800ec2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800ec5:	83 ec 08             	sub    $0x8,%esp
  800ec8:	ff 75 f0             	pushl  -0x10(%ebp)
  800ecb:	6a 00                	push   $0x0
  800ecd:	e8 4b f3 ff ff       	call   80021d <sys_page_unmap>
  800ed2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800ed5:	83 ec 08             	sub    $0x8,%esp
  800ed8:	ff 75 f4             	pushl  -0xc(%ebp)
  800edb:	6a 00                	push   $0x0
  800edd:	e8 3b f3 ff ff       	call   80021d <sys_page_unmap>
  800ee2:	83 c4 10             	add    $0x10,%esp
}
  800ee5:	89 d8                	mov    %ebx,%eax
  800ee7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eea:	5b                   	pop    %ebx
  800eeb:	5e                   	pop    %esi
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    

00800eee <pipeisclosed>:
{
  800eee:	f3 0f 1e fb          	endbr32 
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ef8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800efb:	50                   	push   %eax
  800efc:	ff 75 08             	pushl  0x8(%ebp)
  800eff:	e8 22 f5 ff ff       	call   800426 <fd_lookup>
  800f04:	83 c4 10             	add    $0x10,%esp
  800f07:	85 c0                	test   %eax,%eax
  800f09:	78 18                	js     800f23 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800f0b:	83 ec 0c             	sub    $0xc,%esp
  800f0e:	ff 75 f4             	pushl  -0xc(%ebp)
  800f11:	e8 9f f4 ff ff       	call   8003b5 <fd2data>
  800f16:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f1b:	e8 1f fd ff ff       	call   800c3f <_pipeisclosed>
  800f20:	83 c4 10             	add    $0x10,%esp
}
  800f23:	c9                   	leave  
  800f24:	c3                   	ret    

00800f25 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f25:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800f29:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2e:	c3                   	ret    

00800f2f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f2f:	f3 0f 1e fb          	endbr32 
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f39:	68 f4 1f 80 00       	push   $0x801ff4
  800f3e:	ff 75 0c             	pushl  0xc(%ebp)
  800f41:	e8 64 08 00 00       	call   8017aa <strcpy>
	return 0;
}
  800f46:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4b:	c9                   	leave  
  800f4c:	c3                   	ret    

00800f4d <devcons_write>:
{
  800f4d:	f3 0f 1e fb          	endbr32 
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	57                   	push   %edi
  800f55:	56                   	push   %esi
  800f56:	53                   	push   %ebx
  800f57:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f5d:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f62:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f68:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f6b:	73 31                	jae    800f9e <devcons_write+0x51>
		m = n - tot;
  800f6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f70:	29 f3                	sub    %esi,%ebx
  800f72:	83 fb 7f             	cmp    $0x7f,%ebx
  800f75:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f7a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f7d:	83 ec 04             	sub    $0x4,%esp
  800f80:	53                   	push   %ebx
  800f81:	89 f0                	mov    %esi,%eax
  800f83:	03 45 0c             	add    0xc(%ebp),%eax
  800f86:	50                   	push   %eax
  800f87:	57                   	push   %edi
  800f88:	e8 d3 09 00 00       	call   801960 <memmove>
		sys_cputs(buf, m);
  800f8d:	83 c4 08             	add    $0x8,%esp
  800f90:	53                   	push   %ebx
  800f91:	57                   	push   %edi
  800f92:	e8 29 f1 ff ff       	call   8000c0 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f97:	01 de                	add    %ebx,%esi
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	eb ca                	jmp    800f68 <devcons_write+0x1b>
}
  800f9e:	89 f0                	mov    %esi,%eax
  800fa0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa3:	5b                   	pop    %ebx
  800fa4:	5e                   	pop    %esi
  800fa5:	5f                   	pop    %edi
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    

00800fa8 <devcons_read>:
{
  800fa8:	f3 0f 1e fb          	endbr32 
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	83 ec 08             	sub    $0x8,%esp
  800fb2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800fb7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fbb:	74 21                	je     800fde <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800fbd:	e8 20 f1 ff ff       	call   8000e2 <sys_cgetc>
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	75 07                	jne    800fcd <devcons_read+0x25>
		sys_yield();
  800fc6:	e8 a2 f1 ff ff       	call   80016d <sys_yield>
  800fcb:	eb f0                	jmp    800fbd <devcons_read+0x15>
	if (c < 0)
  800fcd:	78 0f                	js     800fde <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800fcf:	83 f8 04             	cmp    $0x4,%eax
  800fd2:	74 0c                	je     800fe0 <devcons_read+0x38>
	*(char*)vbuf = c;
  800fd4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fd7:	88 02                	mov    %al,(%edx)
	return 1;
  800fd9:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800fde:	c9                   	leave  
  800fdf:	c3                   	ret    
		return 0;
  800fe0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe5:	eb f7                	jmp    800fde <devcons_read+0x36>

00800fe7 <cputchar>:
{
  800fe7:	f3 0f 1e fb          	endbr32 
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800ff1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff4:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800ff7:	6a 01                	push   $0x1
  800ff9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800ffc:	50                   	push   %eax
  800ffd:	e8 be f0 ff ff       	call   8000c0 <sys_cputs>
}
  801002:	83 c4 10             	add    $0x10,%esp
  801005:	c9                   	leave  
  801006:	c3                   	ret    

00801007 <getchar>:
{
  801007:	f3 0f 1e fb          	endbr32 
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801011:	6a 01                	push   $0x1
  801013:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801016:	50                   	push   %eax
  801017:	6a 00                	push   $0x0
  801019:	e8 8b f6 ff ff       	call   8006a9 <read>
	if (r < 0)
  80101e:	83 c4 10             	add    $0x10,%esp
  801021:	85 c0                	test   %eax,%eax
  801023:	78 06                	js     80102b <getchar+0x24>
	if (r < 1)
  801025:	74 06                	je     80102d <getchar+0x26>
	return c;
  801027:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80102b:	c9                   	leave  
  80102c:	c3                   	ret    
		return -E_EOF;
  80102d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801032:	eb f7                	jmp    80102b <getchar+0x24>

00801034 <iscons>:
{
  801034:	f3 0f 1e fb          	endbr32 
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80103e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801041:	50                   	push   %eax
  801042:	ff 75 08             	pushl  0x8(%ebp)
  801045:	e8 dc f3 ff ff       	call   800426 <fd_lookup>
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	85 c0                	test   %eax,%eax
  80104f:	78 11                	js     801062 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801051:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801054:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80105a:	39 10                	cmp    %edx,(%eax)
  80105c:	0f 94 c0             	sete   %al
  80105f:	0f b6 c0             	movzbl %al,%eax
}
  801062:	c9                   	leave  
  801063:	c3                   	ret    

00801064 <opencons>:
{
  801064:	f3 0f 1e fb          	endbr32 
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80106e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801071:	50                   	push   %eax
  801072:	e8 59 f3 ff ff       	call   8003d0 <fd_alloc>
  801077:	83 c4 10             	add    $0x10,%esp
  80107a:	85 c0                	test   %eax,%eax
  80107c:	78 3a                	js     8010b8 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80107e:	83 ec 04             	sub    $0x4,%esp
  801081:	68 07 04 00 00       	push   $0x407
  801086:	ff 75 f4             	pushl  -0xc(%ebp)
  801089:	6a 00                	push   $0x0
  80108b:	e8 00 f1 ff ff       	call   800190 <sys_page_alloc>
  801090:	83 c4 10             	add    $0x10,%esp
  801093:	85 c0                	test   %eax,%eax
  801095:	78 21                	js     8010b8 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801097:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80109a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8010a0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8010a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8010ac:	83 ec 0c             	sub    $0xc,%esp
  8010af:	50                   	push   %eax
  8010b0:	e8 ec f2 ff ff       	call   8003a1 <fd2num>
  8010b5:	83 c4 10             	add    $0x10,%esp
}
  8010b8:	c9                   	leave  
  8010b9:	c3                   	ret    

008010ba <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010ba:	f3 0f 1e fb          	endbr32 
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	56                   	push   %esi
  8010c2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010c3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010c6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010cc:	e8 79 f0 ff ff       	call   80014a <sys_getenvid>
  8010d1:	83 ec 0c             	sub    $0xc,%esp
  8010d4:	ff 75 0c             	pushl  0xc(%ebp)
  8010d7:	ff 75 08             	pushl  0x8(%ebp)
  8010da:	56                   	push   %esi
  8010db:	50                   	push   %eax
  8010dc:	68 00 20 80 00       	push   $0x802000
  8010e1:	e8 bb 00 00 00       	call   8011a1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010e6:	83 c4 18             	add    $0x18,%esp
  8010e9:	53                   	push   %ebx
  8010ea:	ff 75 10             	pushl  0x10(%ebp)
  8010ed:	e8 5a 00 00 00       	call   80114c <vcprintf>
	cprintf("\n");
  8010f2:	c7 04 24 ed 1f 80 00 	movl   $0x801fed,(%esp)
  8010f9:	e8 a3 00 00 00       	call   8011a1 <cprintf>
  8010fe:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801101:	cc                   	int3   
  801102:	eb fd                	jmp    801101 <_panic+0x47>

00801104 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801104:	f3 0f 1e fb          	endbr32 
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
  80110b:	53                   	push   %ebx
  80110c:	83 ec 04             	sub    $0x4,%esp
  80110f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801112:	8b 13                	mov    (%ebx),%edx
  801114:	8d 42 01             	lea    0x1(%edx),%eax
  801117:	89 03                	mov    %eax,(%ebx)
  801119:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80111c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801120:	3d ff 00 00 00       	cmp    $0xff,%eax
  801125:	74 09                	je     801130 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801127:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80112b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80112e:	c9                   	leave  
  80112f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801130:	83 ec 08             	sub    $0x8,%esp
  801133:	68 ff 00 00 00       	push   $0xff
  801138:	8d 43 08             	lea    0x8(%ebx),%eax
  80113b:	50                   	push   %eax
  80113c:	e8 7f ef ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  801141:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801147:	83 c4 10             	add    $0x10,%esp
  80114a:	eb db                	jmp    801127 <putch+0x23>

0080114c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80114c:	f3 0f 1e fb          	endbr32 
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801159:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801160:	00 00 00 
	b.cnt = 0;
  801163:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80116a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80116d:	ff 75 0c             	pushl  0xc(%ebp)
  801170:	ff 75 08             	pushl  0x8(%ebp)
  801173:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801179:	50                   	push   %eax
  80117a:	68 04 11 80 00       	push   $0x801104
  80117f:	e8 20 01 00 00       	call   8012a4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801184:	83 c4 08             	add    $0x8,%esp
  801187:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80118d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801193:	50                   	push   %eax
  801194:	e8 27 ef ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  801199:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80119f:	c9                   	leave  
  8011a0:	c3                   	ret    

008011a1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8011a1:	f3 0f 1e fb          	endbr32 
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8011ab:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8011ae:	50                   	push   %eax
  8011af:	ff 75 08             	pushl  0x8(%ebp)
  8011b2:	e8 95 ff ff ff       	call   80114c <vcprintf>
	va_end(ap);

	return cnt;
}
  8011b7:	c9                   	leave  
  8011b8:	c3                   	ret    

008011b9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	57                   	push   %edi
  8011bd:	56                   	push   %esi
  8011be:	53                   	push   %ebx
  8011bf:	83 ec 1c             	sub    $0x1c,%esp
  8011c2:	89 c7                	mov    %eax,%edi
  8011c4:	89 d6                	mov    %edx,%esi
  8011c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011cc:	89 d1                	mov    %edx,%ecx
  8011ce:	89 c2                	mov    %eax,%edx
  8011d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011d3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8011d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011df:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8011e6:	39 c2                	cmp    %eax,%edx
  8011e8:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8011eb:	72 3e                	jb     80122b <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011ed:	83 ec 0c             	sub    $0xc,%esp
  8011f0:	ff 75 18             	pushl  0x18(%ebp)
  8011f3:	83 eb 01             	sub    $0x1,%ebx
  8011f6:	53                   	push   %ebx
  8011f7:	50                   	push   %eax
  8011f8:	83 ec 08             	sub    $0x8,%esp
  8011fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011fe:	ff 75 e0             	pushl  -0x20(%ebp)
  801201:	ff 75 dc             	pushl  -0x24(%ebp)
  801204:	ff 75 d8             	pushl  -0x28(%ebp)
  801207:	e8 54 0a 00 00       	call   801c60 <__udivdi3>
  80120c:	83 c4 18             	add    $0x18,%esp
  80120f:	52                   	push   %edx
  801210:	50                   	push   %eax
  801211:	89 f2                	mov    %esi,%edx
  801213:	89 f8                	mov    %edi,%eax
  801215:	e8 9f ff ff ff       	call   8011b9 <printnum>
  80121a:	83 c4 20             	add    $0x20,%esp
  80121d:	eb 13                	jmp    801232 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80121f:	83 ec 08             	sub    $0x8,%esp
  801222:	56                   	push   %esi
  801223:	ff 75 18             	pushl  0x18(%ebp)
  801226:	ff d7                	call   *%edi
  801228:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80122b:	83 eb 01             	sub    $0x1,%ebx
  80122e:	85 db                	test   %ebx,%ebx
  801230:	7f ed                	jg     80121f <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801232:	83 ec 08             	sub    $0x8,%esp
  801235:	56                   	push   %esi
  801236:	83 ec 04             	sub    $0x4,%esp
  801239:	ff 75 e4             	pushl  -0x1c(%ebp)
  80123c:	ff 75 e0             	pushl  -0x20(%ebp)
  80123f:	ff 75 dc             	pushl  -0x24(%ebp)
  801242:	ff 75 d8             	pushl  -0x28(%ebp)
  801245:	e8 26 0b 00 00       	call   801d70 <__umoddi3>
  80124a:	83 c4 14             	add    $0x14,%esp
  80124d:	0f be 80 23 20 80 00 	movsbl 0x802023(%eax),%eax
  801254:	50                   	push   %eax
  801255:	ff d7                	call   *%edi
}
  801257:	83 c4 10             	add    $0x10,%esp
  80125a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125d:	5b                   	pop    %ebx
  80125e:	5e                   	pop    %esi
  80125f:	5f                   	pop    %edi
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    

00801262 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801262:	f3 0f 1e fb          	endbr32 
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80126c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801270:	8b 10                	mov    (%eax),%edx
  801272:	3b 50 04             	cmp    0x4(%eax),%edx
  801275:	73 0a                	jae    801281 <sprintputch+0x1f>
		*b->buf++ = ch;
  801277:	8d 4a 01             	lea    0x1(%edx),%ecx
  80127a:	89 08                	mov    %ecx,(%eax)
  80127c:	8b 45 08             	mov    0x8(%ebp),%eax
  80127f:	88 02                	mov    %al,(%edx)
}
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    

00801283 <printfmt>:
{
  801283:	f3 0f 1e fb          	endbr32 
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80128d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801290:	50                   	push   %eax
  801291:	ff 75 10             	pushl  0x10(%ebp)
  801294:	ff 75 0c             	pushl  0xc(%ebp)
  801297:	ff 75 08             	pushl  0x8(%ebp)
  80129a:	e8 05 00 00 00       	call   8012a4 <vprintfmt>
}
  80129f:	83 c4 10             	add    $0x10,%esp
  8012a2:	c9                   	leave  
  8012a3:	c3                   	ret    

008012a4 <vprintfmt>:
{
  8012a4:	f3 0f 1e fb          	endbr32 
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	57                   	push   %edi
  8012ac:	56                   	push   %esi
  8012ad:	53                   	push   %ebx
  8012ae:	83 ec 3c             	sub    $0x3c,%esp
  8012b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8012b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012b7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012ba:	e9 4a 03 00 00       	jmp    801609 <vprintfmt+0x365>
		padc = ' ';
  8012bf:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012c3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012ca:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012d1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012d8:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012dd:	8d 47 01             	lea    0x1(%edi),%eax
  8012e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012e3:	0f b6 17             	movzbl (%edi),%edx
  8012e6:	8d 42 dd             	lea    -0x23(%edx),%eax
  8012e9:	3c 55                	cmp    $0x55,%al
  8012eb:	0f 87 de 03 00 00    	ja     8016cf <vprintfmt+0x42b>
  8012f1:	0f b6 c0             	movzbl %al,%eax
  8012f4:	3e ff 24 85 60 21 80 	notrack jmp *0x802160(,%eax,4)
  8012fb:	00 
  8012fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8012ff:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801303:	eb d8                	jmp    8012dd <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801305:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801308:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80130c:	eb cf                	jmp    8012dd <vprintfmt+0x39>
  80130e:	0f b6 d2             	movzbl %dl,%edx
  801311:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801314:	b8 00 00 00 00       	mov    $0x0,%eax
  801319:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80131c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80131f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801323:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801326:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801329:	83 f9 09             	cmp    $0x9,%ecx
  80132c:	77 55                	ja     801383 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80132e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801331:	eb e9                	jmp    80131c <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801333:	8b 45 14             	mov    0x14(%ebp),%eax
  801336:	8b 00                	mov    (%eax),%eax
  801338:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80133b:	8b 45 14             	mov    0x14(%ebp),%eax
  80133e:	8d 40 04             	lea    0x4(%eax),%eax
  801341:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801344:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801347:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80134b:	79 90                	jns    8012dd <vprintfmt+0x39>
				width = precision, precision = -1;
  80134d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801350:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801353:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80135a:	eb 81                	jmp    8012dd <vprintfmt+0x39>
  80135c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80135f:	85 c0                	test   %eax,%eax
  801361:	ba 00 00 00 00       	mov    $0x0,%edx
  801366:	0f 49 d0             	cmovns %eax,%edx
  801369:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80136c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80136f:	e9 69 ff ff ff       	jmp    8012dd <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801374:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801377:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80137e:	e9 5a ff ff ff       	jmp    8012dd <vprintfmt+0x39>
  801383:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801386:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801389:	eb bc                	jmp    801347 <vprintfmt+0xa3>
			lflag++;
  80138b:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80138e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801391:	e9 47 ff ff ff       	jmp    8012dd <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  801396:	8b 45 14             	mov    0x14(%ebp),%eax
  801399:	8d 78 04             	lea    0x4(%eax),%edi
  80139c:	83 ec 08             	sub    $0x8,%esp
  80139f:	53                   	push   %ebx
  8013a0:	ff 30                	pushl  (%eax)
  8013a2:	ff d6                	call   *%esi
			break;
  8013a4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8013a7:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8013aa:	e9 57 02 00 00       	jmp    801606 <vprintfmt+0x362>
			err = va_arg(ap, int);
  8013af:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b2:	8d 78 04             	lea    0x4(%eax),%edi
  8013b5:	8b 00                	mov    (%eax),%eax
  8013b7:	99                   	cltd   
  8013b8:	31 d0                	xor    %edx,%eax
  8013ba:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013bc:	83 f8 0f             	cmp    $0xf,%eax
  8013bf:	7f 23                	jg     8013e4 <vprintfmt+0x140>
  8013c1:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  8013c8:	85 d2                	test   %edx,%edx
  8013ca:	74 18                	je     8013e4 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8013cc:	52                   	push   %edx
  8013cd:	68 c6 1f 80 00       	push   $0x801fc6
  8013d2:	53                   	push   %ebx
  8013d3:	56                   	push   %esi
  8013d4:	e8 aa fe ff ff       	call   801283 <printfmt>
  8013d9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8013dc:	89 7d 14             	mov    %edi,0x14(%ebp)
  8013df:	e9 22 02 00 00       	jmp    801606 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8013e4:	50                   	push   %eax
  8013e5:	68 3b 20 80 00       	push   $0x80203b
  8013ea:	53                   	push   %ebx
  8013eb:	56                   	push   %esi
  8013ec:	e8 92 fe ff ff       	call   801283 <printfmt>
  8013f1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8013f4:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8013f7:	e9 0a 02 00 00       	jmp    801606 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8013fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ff:	83 c0 04             	add    $0x4,%eax
  801402:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801405:	8b 45 14             	mov    0x14(%ebp),%eax
  801408:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80140a:	85 d2                	test   %edx,%edx
  80140c:	b8 34 20 80 00       	mov    $0x802034,%eax
  801411:	0f 45 c2             	cmovne %edx,%eax
  801414:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801417:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80141b:	7e 06                	jle    801423 <vprintfmt+0x17f>
  80141d:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801421:	75 0d                	jne    801430 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  801423:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801426:	89 c7                	mov    %eax,%edi
  801428:	03 45 e0             	add    -0x20(%ebp),%eax
  80142b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80142e:	eb 55                	jmp    801485 <vprintfmt+0x1e1>
  801430:	83 ec 08             	sub    $0x8,%esp
  801433:	ff 75 d8             	pushl  -0x28(%ebp)
  801436:	ff 75 cc             	pushl  -0x34(%ebp)
  801439:	e8 45 03 00 00       	call   801783 <strnlen>
  80143e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801441:	29 c2                	sub    %eax,%edx
  801443:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80144b:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80144f:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801452:	85 ff                	test   %edi,%edi
  801454:	7e 11                	jle    801467 <vprintfmt+0x1c3>
					putch(padc, putdat);
  801456:	83 ec 08             	sub    $0x8,%esp
  801459:	53                   	push   %ebx
  80145a:	ff 75 e0             	pushl  -0x20(%ebp)
  80145d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80145f:	83 ef 01             	sub    $0x1,%edi
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	eb eb                	jmp    801452 <vprintfmt+0x1ae>
  801467:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80146a:	85 d2                	test   %edx,%edx
  80146c:	b8 00 00 00 00       	mov    $0x0,%eax
  801471:	0f 49 c2             	cmovns %edx,%eax
  801474:	29 c2                	sub    %eax,%edx
  801476:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801479:	eb a8                	jmp    801423 <vprintfmt+0x17f>
					putch(ch, putdat);
  80147b:	83 ec 08             	sub    $0x8,%esp
  80147e:	53                   	push   %ebx
  80147f:	52                   	push   %edx
  801480:	ff d6                	call   *%esi
  801482:	83 c4 10             	add    $0x10,%esp
  801485:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801488:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80148a:	83 c7 01             	add    $0x1,%edi
  80148d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801491:	0f be d0             	movsbl %al,%edx
  801494:	85 d2                	test   %edx,%edx
  801496:	74 4b                	je     8014e3 <vprintfmt+0x23f>
  801498:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80149c:	78 06                	js     8014a4 <vprintfmt+0x200>
  80149e:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014a2:	78 1e                	js     8014c2 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8014a4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014a8:	74 d1                	je     80147b <vprintfmt+0x1d7>
  8014aa:	0f be c0             	movsbl %al,%eax
  8014ad:	83 e8 20             	sub    $0x20,%eax
  8014b0:	83 f8 5e             	cmp    $0x5e,%eax
  8014b3:	76 c6                	jbe    80147b <vprintfmt+0x1d7>
					putch('?', putdat);
  8014b5:	83 ec 08             	sub    $0x8,%esp
  8014b8:	53                   	push   %ebx
  8014b9:	6a 3f                	push   $0x3f
  8014bb:	ff d6                	call   *%esi
  8014bd:	83 c4 10             	add    $0x10,%esp
  8014c0:	eb c3                	jmp    801485 <vprintfmt+0x1e1>
  8014c2:	89 cf                	mov    %ecx,%edi
  8014c4:	eb 0e                	jmp    8014d4 <vprintfmt+0x230>
				putch(' ', putdat);
  8014c6:	83 ec 08             	sub    $0x8,%esp
  8014c9:	53                   	push   %ebx
  8014ca:	6a 20                	push   $0x20
  8014cc:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8014ce:	83 ef 01             	sub    $0x1,%edi
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	85 ff                	test   %edi,%edi
  8014d6:	7f ee                	jg     8014c6 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8014d8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8014db:	89 45 14             	mov    %eax,0x14(%ebp)
  8014de:	e9 23 01 00 00       	jmp    801606 <vprintfmt+0x362>
  8014e3:	89 cf                	mov    %ecx,%edi
  8014e5:	eb ed                	jmp    8014d4 <vprintfmt+0x230>
	if (lflag >= 2)
  8014e7:	83 f9 01             	cmp    $0x1,%ecx
  8014ea:	7f 1b                	jg     801507 <vprintfmt+0x263>
	else if (lflag)
  8014ec:	85 c9                	test   %ecx,%ecx
  8014ee:	74 63                	je     801553 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8014f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f3:	8b 00                	mov    (%eax),%eax
  8014f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f8:	99                   	cltd   
  8014f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ff:	8d 40 04             	lea    0x4(%eax),%eax
  801502:	89 45 14             	mov    %eax,0x14(%ebp)
  801505:	eb 17                	jmp    80151e <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  801507:	8b 45 14             	mov    0x14(%ebp),%eax
  80150a:	8b 50 04             	mov    0x4(%eax),%edx
  80150d:	8b 00                	mov    (%eax),%eax
  80150f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801512:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801515:	8b 45 14             	mov    0x14(%ebp),%eax
  801518:	8d 40 08             	lea    0x8(%eax),%eax
  80151b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80151e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801521:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801524:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  801529:	85 c9                	test   %ecx,%ecx
  80152b:	0f 89 bb 00 00 00    	jns    8015ec <vprintfmt+0x348>
				putch('-', putdat);
  801531:	83 ec 08             	sub    $0x8,%esp
  801534:	53                   	push   %ebx
  801535:	6a 2d                	push   $0x2d
  801537:	ff d6                	call   *%esi
				num = -(long long) num;
  801539:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80153c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80153f:	f7 da                	neg    %edx
  801541:	83 d1 00             	adc    $0x0,%ecx
  801544:	f7 d9                	neg    %ecx
  801546:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801549:	b8 0a 00 00 00       	mov    $0xa,%eax
  80154e:	e9 99 00 00 00       	jmp    8015ec <vprintfmt+0x348>
		return va_arg(*ap, int);
  801553:	8b 45 14             	mov    0x14(%ebp),%eax
  801556:	8b 00                	mov    (%eax),%eax
  801558:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80155b:	99                   	cltd   
  80155c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80155f:	8b 45 14             	mov    0x14(%ebp),%eax
  801562:	8d 40 04             	lea    0x4(%eax),%eax
  801565:	89 45 14             	mov    %eax,0x14(%ebp)
  801568:	eb b4                	jmp    80151e <vprintfmt+0x27a>
	if (lflag >= 2)
  80156a:	83 f9 01             	cmp    $0x1,%ecx
  80156d:	7f 1b                	jg     80158a <vprintfmt+0x2e6>
	else if (lflag)
  80156f:	85 c9                	test   %ecx,%ecx
  801571:	74 2c                	je     80159f <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  801573:	8b 45 14             	mov    0x14(%ebp),%eax
  801576:	8b 10                	mov    (%eax),%edx
  801578:	b9 00 00 00 00       	mov    $0x0,%ecx
  80157d:	8d 40 04             	lea    0x4(%eax),%eax
  801580:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801583:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  801588:	eb 62                	jmp    8015ec <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80158a:	8b 45 14             	mov    0x14(%ebp),%eax
  80158d:	8b 10                	mov    (%eax),%edx
  80158f:	8b 48 04             	mov    0x4(%eax),%ecx
  801592:	8d 40 08             	lea    0x8(%eax),%eax
  801595:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801598:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80159d:	eb 4d                	jmp    8015ec <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80159f:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a2:	8b 10                	mov    (%eax),%edx
  8015a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015a9:	8d 40 04             	lea    0x4(%eax),%eax
  8015ac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015af:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8015b4:	eb 36                	jmp    8015ec <vprintfmt+0x348>
	if (lflag >= 2)
  8015b6:	83 f9 01             	cmp    $0x1,%ecx
  8015b9:	7f 17                	jg     8015d2 <vprintfmt+0x32e>
	else if (lflag)
  8015bb:	85 c9                	test   %ecx,%ecx
  8015bd:	74 6e                	je     80162d <vprintfmt+0x389>
		return va_arg(*ap, long);
  8015bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c2:	8b 10                	mov    (%eax),%edx
  8015c4:	89 d0                	mov    %edx,%eax
  8015c6:	99                   	cltd   
  8015c7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015ca:	8d 49 04             	lea    0x4(%ecx),%ecx
  8015cd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8015d0:	eb 11                	jmp    8015e3 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8015d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d5:	8b 50 04             	mov    0x4(%eax),%edx
  8015d8:	8b 00                	mov    (%eax),%eax
  8015da:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015dd:	8d 49 08             	lea    0x8(%ecx),%ecx
  8015e0:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8015e3:	89 d1                	mov    %edx,%ecx
  8015e5:	89 c2                	mov    %eax,%edx
            base = 8;
  8015e7:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8015ec:	83 ec 0c             	sub    $0xc,%esp
  8015ef:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8015f3:	57                   	push   %edi
  8015f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f7:	50                   	push   %eax
  8015f8:	51                   	push   %ecx
  8015f9:	52                   	push   %edx
  8015fa:	89 da                	mov    %ebx,%edx
  8015fc:	89 f0                	mov    %esi,%eax
  8015fe:	e8 b6 fb ff ff       	call   8011b9 <printnum>
			break;
  801603:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  801606:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801609:	83 c7 01             	add    $0x1,%edi
  80160c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801610:	83 f8 25             	cmp    $0x25,%eax
  801613:	0f 84 a6 fc ff ff    	je     8012bf <vprintfmt+0x1b>
			if (ch == '\0')
  801619:	85 c0                	test   %eax,%eax
  80161b:	0f 84 ce 00 00 00    	je     8016ef <vprintfmt+0x44b>
			putch(ch, putdat);
  801621:	83 ec 08             	sub    $0x8,%esp
  801624:	53                   	push   %ebx
  801625:	50                   	push   %eax
  801626:	ff d6                	call   *%esi
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	eb dc                	jmp    801609 <vprintfmt+0x365>
		return va_arg(*ap, int);
  80162d:	8b 45 14             	mov    0x14(%ebp),%eax
  801630:	8b 10                	mov    (%eax),%edx
  801632:	89 d0                	mov    %edx,%eax
  801634:	99                   	cltd   
  801635:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801638:	8d 49 04             	lea    0x4(%ecx),%ecx
  80163b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80163e:	eb a3                	jmp    8015e3 <vprintfmt+0x33f>
			putch('0', putdat);
  801640:	83 ec 08             	sub    $0x8,%esp
  801643:	53                   	push   %ebx
  801644:	6a 30                	push   $0x30
  801646:	ff d6                	call   *%esi
			putch('x', putdat);
  801648:	83 c4 08             	add    $0x8,%esp
  80164b:	53                   	push   %ebx
  80164c:	6a 78                	push   $0x78
  80164e:	ff d6                	call   *%esi
			num = (unsigned long long)
  801650:	8b 45 14             	mov    0x14(%ebp),%eax
  801653:	8b 10                	mov    (%eax),%edx
  801655:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80165a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80165d:	8d 40 04             	lea    0x4(%eax),%eax
  801660:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801663:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801668:	eb 82                	jmp    8015ec <vprintfmt+0x348>
	if (lflag >= 2)
  80166a:	83 f9 01             	cmp    $0x1,%ecx
  80166d:	7f 1e                	jg     80168d <vprintfmt+0x3e9>
	else if (lflag)
  80166f:	85 c9                	test   %ecx,%ecx
  801671:	74 32                	je     8016a5 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  801673:	8b 45 14             	mov    0x14(%ebp),%eax
  801676:	8b 10                	mov    (%eax),%edx
  801678:	b9 00 00 00 00       	mov    $0x0,%ecx
  80167d:	8d 40 04             	lea    0x4(%eax),%eax
  801680:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801683:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  801688:	e9 5f ff ff ff       	jmp    8015ec <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80168d:	8b 45 14             	mov    0x14(%ebp),%eax
  801690:	8b 10                	mov    (%eax),%edx
  801692:	8b 48 04             	mov    0x4(%eax),%ecx
  801695:	8d 40 08             	lea    0x8(%eax),%eax
  801698:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80169b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8016a0:	e9 47 ff ff ff       	jmp    8015ec <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8016a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8016a8:	8b 10                	mov    (%eax),%edx
  8016aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016af:	8d 40 04             	lea    0x4(%eax),%eax
  8016b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016b5:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8016ba:	e9 2d ff ff ff       	jmp    8015ec <vprintfmt+0x348>
			putch(ch, putdat);
  8016bf:	83 ec 08             	sub    $0x8,%esp
  8016c2:	53                   	push   %ebx
  8016c3:	6a 25                	push   $0x25
  8016c5:	ff d6                	call   *%esi
			break;
  8016c7:	83 c4 10             	add    $0x10,%esp
  8016ca:	e9 37 ff ff ff       	jmp    801606 <vprintfmt+0x362>
			putch('%', putdat);
  8016cf:	83 ec 08             	sub    $0x8,%esp
  8016d2:	53                   	push   %ebx
  8016d3:	6a 25                	push   $0x25
  8016d5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8016d7:	83 c4 10             	add    $0x10,%esp
  8016da:	89 f8                	mov    %edi,%eax
  8016dc:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8016e0:	74 05                	je     8016e7 <vprintfmt+0x443>
  8016e2:	83 e8 01             	sub    $0x1,%eax
  8016e5:	eb f5                	jmp    8016dc <vprintfmt+0x438>
  8016e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016ea:	e9 17 ff ff ff       	jmp    801606 <vprintfmt+0x362>
}
  8016ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f2:	5b                   	pop    %ebx
  8016f3:	5e                   	pop    %esi
  8016f4:	5f                   	pop    %edi
  8016f5:	5d                   	pop    %ebp
  8016f6:	c3                   	ret    

008016f7 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8016f7:	f3 0f 1e fb          	endbr32 
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	83 ec 18             	sub    $0x18,%esp
  801701:	8b 45 08             	mov    0x8(%ebp),%eax
  801704:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801707:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80170a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80170e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801711:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801718:	85 c0                	test   %eax,%eax
  80171a:	74 26                	je     801742 <vsnprintf+0x4b>
  80171c:	85 d2                	test   %edx,%edx
  80171e:	7e 22                	jle    801742 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801720:	ff 75 14             	pushl  0x14(%ebp)
  801723:	ff 75 10             	pushl  0x10(%ebp)
  801726:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801729:	50                   	push   %eax
  80172a:	68 62 12 80 00       	push   $0x801262
  80172f:	e8 70 fb ff ff       	call   8012a4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801734:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801737:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80173a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80173d:	83 c4 10             	add    $0x10,%esp
}
  801740:	c9                   	leave  
  801741:	c3                   	ret    
		return -E_INVAL;
  801742:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801747:	eb f7                	jmp    801740 <vsnprintf+0x49>

00801749 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801749:	f3 0f 1e fb          	endbr32 
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801753:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801756:	50                   	push   %eax
  801757:	ff 75 10             	pushl  0x10(%ebp)
  80175a:	ff 75 0c             	pushl  0xc(%ebp)
  80175d:	ff 75 08             	pushl  0x8(%ebp)
  801760:	e8 92 ff ff ff       	call   8016f7 <vsnprintf>
	va_end(ap);

	return rc;
}
  801765:	c9                   	leave  
  801766:	c3                   	ret    

00801767 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801767:	f3 0f 1e fb          	endbr32 
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801771:	b8 00 00 00 00       	mov    $0x0,%eax
  801776:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80177a:	74 05                	je     801781 <strlen+0x1a>
		n++;
  80177c:	83 c0 01             	add    $0x1,%eax
  80177f:	eb f5                	jmp    801776 <strlen+0xf>
	return n;
}
  801781:	5d                   	pop    %ebp
  801782:	c3                   	ret    

00801783 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801783:	f3 0f 1e fb          	endbr32 
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80178d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801790:	b8 00 00 00 00       	mov    $0x0,%eax
  801795:	39 d0                	cmp    %edx,%eax
  801797:	74 0d                	je     8017a6 <strnlen+0x23>
  801799:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80179d:	74 05                	je     8017a4 <strnlen+0x21>
		n++;
  80179f:	83 c0 01             	add    $0x1,%eax
  8017a2:	eb f1                	jmp    801795 <strnlen+0x12>
  8017a4:	89 c2                	mov    %eax,%edx
	return n;
}
  8017a6:	89 d0                	mov    %edx,%eax
  8017a8:	5d                   	pop    %ebp
  8017a9:	c3                   	ret    

008017aa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8017aa:	f3 0f 1e fb          	endbr32 
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	53                   	push   %ebx
  8017b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8017b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8017bd:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8017c1:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8017c4:	83 c0 01             	add    $0x1,%eax
  8017c7:	84 d2                	test   %dl,%dl
  8017c9:	75 f2                	jne    8017bd <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8017cb:	89 c8                	mov    %ecx,%eax
  8017cd:	5b                   	pop    %ebx
  8017ce:	5d                   	pop    %ebp
  8017cf:	c3                   	ret    

008017d0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017d0:	f3 0f 1e fb          	endbr32 
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	53                   	push   %ebx
  8017d8:	83 ec 10             	sub    $0x10,%esp
  8017db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8017de:	53                   	push   %ebx
  8017df:	e8 83 ff ff ff       	call   801767 <strlen>
  8017e4:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8017e7:	ff 75 0c             	pushl  0xc(%ebp)
  8017ea:	01 d8                	add    %ebx,%eax
  8017ec:	50                   	push   %eax
  8017ed:	e8 b8 ff ff ff       	call   8017aa <strcpy>
	return dst;
}
  8017f2:	89 d8                	mov    %ebx,%eax
  8017f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f7:	c9                   	leave  
  8017f8:	c3                   	ret    

008017f9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8017f9:	f3 0f 1e fb          	endbr32 
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	56                   	push   %esi
  801801:	53                   	push   %ebx
  801802:	8b 75 08             	mov    0x8(%ebp),%esi
  801805:	8b 55 0c             	mov    0xc(%ebp),%edx
  801808:	89 f3                	mov    %esi,%ebx
  80180a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80180d:	89 f0                	mov    %esi,%eax
  80180f:	39 d8                	cmp    %ebx,%eax
  801811:	74 11                	je     801824 <strncpy+0x2b>
		*dst++ = *src;
  801813:	83 c0 01             	add    $0x1,%eax
  801816:	0f b6 0a             	movzbl (%edx),%ecx
  801819:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80181c:	80 f9 01             	cmp    $0x1,%cl
  80181f:	83 da ff             	sbb    $0xffffffff,%edx
  801822:	eb eb                	jmp    80180f <strncpy+0x16>
	}
	return ret;
}
  801824:	89 f0                	mov    %esi,%eax
  801826:	5b                   	pop    %ebx
  801827:	5e                   	pop    %esi
  801828:	5d                   	pop    %ebp
  801829:	c3                   	ret    

0080182a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80182a:	f3 0f 1e fb          	endbr32 
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	56                   	push   %esi
  801832:	53                   	push   %ebx
  801833:	8b 75 08             	mov    0x8(%ebp),%esi
  801836:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801839:	8b 55 10             	mov    0x10(%ebp),%edx
  80183c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80183e:	85 d2                	test   %edx,%edx
  801840:	74 21                	je     801863 <strlcpy+0x39>
  801842:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801846:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801848:	39 c2                	cmp    %eax,%edx
  80184a:	74 14                	je     801860 <strlcpy+0x36>
  80184c:	0f b6 19             	movzbl (%ecx),%ebx
  80184f:	84 db                	test   %bl,%bl
  801851:	74 0b                	je     80185e <strlcpy+0x34>
			*dst++ = *src++;
  801853:	83 c1 01             	add    $0x1,%ecx
  801856:	83 c2 01             	add    $0x1,%edx
  801859:	88 5a ff             	mov    %bl,-0x1(%edx)
  80185c:	eb ea                	jmp    801848 <strlcpy+0x1e>
  80185e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801860:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801863:	29 f0                	sub    %esi,%eax
}
  801865:	5b                   	pop    %ebx
  801866:	5e                   	pop    %esi
  801867:	5d                   	pop    %ebp
  801868:	c3                   	ret    

00801869 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801869:	f3 0f 1e fb          	endbr32 
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
  801870:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801873:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801876:	0f b6 01             	movzbl (%ecx),%eax
  801879:	84 c0                	test   %al,%al
  80187b:	74 0c                	je     801889 <strcmp+0x20>
  80187d:	3a 02                	cmp    (%edx),%al
  80187f:	75 08                	jne    801889 <strcmp+0x20>
		p++, q++;
  801881:	83 c1 01             	add    $0x1,%ecx
  801884:	83 c2 01             	add    $0x1,%edx
  801887:	eb ed                	jmp    801876 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801889:	0f b6 c0             	movzbl %al,%eax
  80188c:	0f b6 12             	movzbl (%edx),%edx
  80188f:	29 d0                	sub    %edx,%eax
}
  801891:	5d                   	pop    %ebp
  801892:	c3                   	ret    

00801893 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801893:	f3 0f 1e fb          	endbr32 
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	53                   	push   %ebx
  80189b:	8b 45 08             	mov    0x8(%ebp),%eax
  80189e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018a1:	89 c3                	mov    %eax,%ebx
  8018a3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8018a6:	eb 06                	jmp    8018ae <strncmp+0x1b>
		n--, p++, q++;
  8018a8:	83 c0 01             	add    $0x1,%eax
  8018ab:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8018ae:	39 d8                	cmp    %ebx,%eax
  8018b0:	74 16                	je     8018c8 <strncmp+0x35>
  8018b2:	0f b6 08             	movzbl (%eax),%ecx
  8018b5:	84 c9                	test   %cl,%cl
  8018b7:	74 04                	je     8018bd <strncmp+0x2a>
  8018b9:	3a 0a                	cmp    (%edx),%cl
  8018bb:	74 eb                	je     8018a8 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8018bd:	0f b6 00             	movzbl (%eax),%eax
  8018c0:	0f b6 12             	movzbl (%edx),%edx
  8018c3:	29 d0                	sub    %edx,%eax
}
  8018c5:	5b                   	pop    %ebx
  8018c6:	5d                   	pop    %ebp
  8018c7:	c3                   	ret    
		return 0;
  8018c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018cd:	eb f6                	jmp    8018c5 <strncmp+0x32>

008018cf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8018cf:	f3 0f 1e fb          	endbr32 
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018dd:	0f b6 10             	movzbl (%eax),%edx
  8018e0:	84 d2                	test   %dl,%dl
  8018e2:	74 09                	je     8018ed <strchr+0x1e>
		if (*s == c)
  8018e4:	38 ca                	cmp    %cl,%dl
  8018e6:	74 0a                	je     8018f2 <strchr+0x23>
	for (; *s; s++)
  8018e8:	83 c0 01             	add    $0x1,%eax
  8018eb:	eb f0                	jmp    8018dd <strchr+0xe>
			return (char *) s;
	return 0;
  8018ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f2:	5d                   	pop    %ebp
  8018f3:	c3                   	ret    

008018f4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8018f4:	f3 0f 1e fb          	endbr32 
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fe:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801902:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801905:	38 ca                	cmp    %cl,%dl
  801907:	74 09                	je     801912 <strfind+0x1e>
  801909:	84 d2                	test   %dl,%dl
  80190b:	74 05                	je     801912 <strfind+0x1e>
	for (; *s; s++)
  80190d:	83 c0 01             	add    $0x1,%eax
  801910:	eb f0                	jmp    801902 <strfind+0xe>
			break;
	return (char *) s;
}
  801912:	5d                   	pop    %ebp
  801913:	c3                   	ret    

00801914 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801914:	f3 0f 1e fb          	endbr32 
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	57                   	push   %edi
  80191c:	56                   	push   %esi
  80191d:	53                   	push   %ebx
  80191e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801921:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801924:	85 c9                	test   %ecx,%ecx
  801926:	74 31                	je     801959 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801928:	89 f8                	mov    %edi,%eax
  80192a:	09 c8                	or     %ecx,%eax
  80192c:	a8 03                	test   $0x3,%al
  80192e:	75 23                	jne    801953 <memset+0x3f>
		c &= 0xFF;
  801930:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801934:	89 d3                	mov    %edx,%ebx
  801936:	c1 e3 08             	shl    $0x8,%ebx
  801939:	89 d0                	mov    %edx,%eax
  80193b:	c1 e0 18             	shl    $0x18,%eax
  80193e:	89 d6                	mov    %edx,%esi
  801940:	c1 e6 10             	shl    $0x10,%esi
  801943:	09 f0                	or     %esi,%eax
  801945:	09 c2                	or     %eax,%edx
  801947:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801949:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80194c:	89 d0                	mov    %edx,%eax
  80194e:	fc                   	cld    
  80194f:	f3 ab                	rep stos %eax,%es:(%edi)
  801951:	eb 06                	jmp    801959 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801953:	8b 45 0c             	mov    0xc(%ebp),%eax
  801956:	fc                   	cld    
  801957:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801959:	89 f8                	mov    %edi,%eax
  80195b:	5b                   	pop    %ebx
  80195c:	5e                   	pop    %esi
  80195d:	5f                   	pop    %edi
  80195e:	5d                   	pop    %ebp
  80195f:	c3                   	ret    

00801960 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801960:	f3 0f 1e fb          	endbr32 
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	57                   	push   %edi
  801968:	56                   	push   %esi
  801969:	8b 45 08             	mov    0x8(%ebp),%eax
  80196c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80196f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801972:	39 c6                	cmp    %eax,%esi
  801974:	73 32                	jae    8019a8 <memmove+0x48>
  801976:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801979:	39 c2                	cmp    %eax,%edx
  80197b:	76 2b                	jbe    8019a8 <memmove+0x48>
		s += n;
		d += n;
  80197d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801980:	89 fe                	mov    %edi,%esi
  801982:	09 ce                	or     %ecx,%esi
  801984:	09 d6                	or     %edx,%esi
  801986:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80198c:	75 0e                	jne    80199c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80198e:	83 ef 04             	sub    $0x4,%edi
  801991:	8d 72 fc             	lea    -0x4(%edx),%esi
  801994:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801997:	fd                   	std    
  801998:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80199a:	eb 09                	jmp    8019a5 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80199c:	83 ef 01             	sub    $0x1,%edi
  80199f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8019a2:	fd                   	std    
  8019a3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8019a5:	fc                   	cld    
  8019a6:	eb 1a                	jmp    8019c2 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019a8:	89 c2                	mov    %eax,%edx
  8019aa:	09 ca                	or     %ecx,%edx
  8019ac:	09 f2                	or     %esi,%edx
  8019ae:	f6 c2 03             	test   $0x3,%dl
  8019b1:	75 0a                	jne    8019bd <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8019b3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8019b6:	89 c7                	mov    %eax,%edi
  8019b8:	fc                   	cld    
  8019b9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019bb:	eb 05                	jmp    8019c2 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8019bd:	89 c7                	mov    %eax,%edi
  8019bf:	fc                   	cld    
  8019c0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8019c2:	5e                   	pop    %esi
  8019c3:	5f                   	pop    %edi
  8019c4:	5d                   	pop    %ebp
  8019c5:	c3                   	ret    

008019c6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8019c6:	f3 0f 1e fb          	endbr32 
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8019d0:	ff 75 10             	pushl  0x10(%ebp)
  8019d3:	ff 75 0c             	pushl  0xc(%ebp)
  8019d6:	ff 75 08             	pushl  0x8(%ebp)
  8019d9:	e8 82 ff ff ff       	call   801960 <memmove>
}
  8019de:	c9                   	leave  
  8019df:	c3                   	ret    

008019e0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8019e0:	f3 0f 1e fb          	endbr32 
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	56                   	push   %esi
  8019e8:	53                   	push   %ebx
  8019e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019ef:	89 c6                	mov    %eax,%esi
  8019f1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019f4:	39 f0                	cmp    %esi,%eax
  8019f6:	74 1c                	je     801a14 <memcmp+0x34>
		if (*s1 != *s2)
  8019f8:	0f b6 08             	movzbl (%eax),%ecx
  8019fb:	0f b6 1a             	movzbl (%edx),%ebx
  8019fe:	38 d9                	cmp    %bl,%cl
  801a00:	75 08                	jne    801a0a <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801a02:	83 c0 01             	add    $0x1,%eax
  801a05:	83 c2 01             	add    $0x1,%edx
  801a08:	eb ea                	jmp    8019f4 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801a0a:	0f b6 c1             	movzbl %cl,%eax
  801a0d:	0f b6 db             	movzbl %bl,%ebx
  801a10:	29 d8                	sub    %ebx,%eax
  801a12:	eb 05                	jmp    801a19 <memcmp+0x39>
	}

	return 0;
  801a14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a19:	5b                   	pop    %ebx
  801a1a:	5e                   	pop    %esi
  801a1b:	5d                   	pop    %ebp
  801a1c:	c3                   	ret    

00801a1d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a1d:	f3 0f 1e fb          	endbr32 
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	8b 45 08             	mov    0x8(%ebp),%eax
  801a27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a2a:	89 c2                	mov    %eax,%edx
  801a2c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a2f:	39 d0                	cmp    %edx,%eax
  801a31:	73 09                	jae    801a3c <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a33:	38 08                	cmp    %cl,(%eax)
  801a35:	74 05                	je     801a3c <memfind+0x1f>
	for (; s < ends; s++)
  801a37:	83 c0 01             	add    $0x1,%eax
  801a3a:	eb f3                	jmp    801a2f <memfind+0x12>
			break;
	return (void *) s;
}
  801a3c:	5d                   	pop    %ebp
  801a3d:	c3                   	ret    

00801a3e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a3e:	f3 0f 1e fb          	endbr32 
  801a42:	55                   	push   %ebp
  801a43:	89 e5                	mov    %esp,%ebp
  801a45:	57                   	push   %edi
  801a46:	56                   	push   %esi
  801a47:	53                   	push   %ebx
  801a48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a4e:	eb 03                	jmp    801a53 <strtol+0x15>
		s++;
  801a50:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801a53:	0f b6 01             	movzbl (%ecx),%eax
  801a56:	3c 20                	cmp    $0x20,%al
  801a58:	74 f6                	je     801a50 <strtol+0x12>
  801a5a:	3c 09                	cmp    $0x9,%al
  801a5c:	74 f2                	je     801a50 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801a5e:	3c 2b                	cmp    $0x2b,%al
  801a60:	74 2a                	je     801a8c <strtol+0x4e>
	int neg = 0;
  801a62:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801a67:	3c 2d                	cmp    $0x2d,%al
  801a69:	74 2b                	je     801a96 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a6b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a71:	75 0f                	jne    801a82 <strtol+0x44>
  801a73:	80 39 30             	cmpb   $0x30,(%ecx)
  801a76:	74 28                	je     801aa0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a78:	85 db                	test   %ebx,%ebx
  801a7a:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a7f:	0f 44 d8             	cmove  %eax,%ebx
  801a82:	b8 00 00 00 00       	mov    $0x0,%eax
  801a87:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801a8a:	eb 46                	jmp    801ad2 <strtol+0x94>
		s++;
  801a8c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801a8f:	bf 00 00 00 00       	mov    $0x0,%edi
  801a94:	eb d5                	jmp    801a6b <strtol+0x2d>
		s++, neg = 1;
  801a96:	83 c1 01             	add    $0x1,%ecx
  801a99:	bf 01 00 00 00       	mov    $0x1,%edi
  801a9e:	eb cb                	jmp    801a6b <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801aa0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801aa4:	74 0e                	je     801ab4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801aa6:	85 db                	test   %ebx,%ebx
  801aa8:	75 d8                	jne    801a82 <strtol+0x44>
		s++, base = 8;
  801aaa:	83 c1 01             	add    $0x1,%ecx
  801aad:	bb 08 00 00 00       	mov    $0x8,%ebx
  801ab2:	eb ce                	jmp    801a82 <strtol+0x44>
		s += 2, base = 16;
  801ab4:	83 c1 02             	add    $0x2,%ecx
  801ab7:	bb 10 00 00 00       	mov    $0x10,%ebx
  801abc:	eb c4                	jmp    801a82 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801abe:	0f be d2             	movsbl %dl,%edx
  801ac1:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801ac4:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ac7:	7d 3a                	jge    801b03 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801ac9:	83 c1 01             	add    $0x1,%ecx
  801acc:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ad0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801ad2:	0f b6 11             	movzbl (%ecx),%edx
  801ad5:	8d 72 d0             	lea    -0x30(%edx),%esi
  801ad8:	89 f3                	mov    %esi,%ebx
  801ada:	80 fb 09             	cmp    $0x9,%bl
  801add:	76 df                	jbe    801abe <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801adf:	8d 72 9f             	lea    -0x61(%edx),%esi
  801ae2:	89 f3                	mov    %esi,%ebx
  801ae4:	80 fb 19             	cmp    $0x19,%bl
  801ae7:	77 08                	ja     801af1 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801ae9:	0f be d2             	movsbl %dl,%edx
  801aec:	83 ea 57             	sub    $0x57,%edx
  801aef:	eb d3                	jmp    801ac4 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801af1:	8d 72 bf             	lea    -0x41(%edx),%esi
  801af4:	89 f3                	mov    %esi,%ebx
  801af6:	80 fb 19             	cmp    $0x19,%bl
  801af9:	77 08                	ja     801b03 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801afb:	0f be d2             	movsbl %dl,%edx
  801afe:	83 ea 37             	sub    $0x37,%edx
  801b01:	eb c1                	jmp    801ac4 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801b03:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b07:	74 05                	je     801b0e <strtol+0xd0>
		*endptr = (char *) s;
  801b09:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b0c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801b0e:	89 c2                	mov    %eax,%edx
  801b10:	f7 da                	neg    %edx
  801b12:	85 ff                	test   %edi,%edi
  801b14:	0f 45 c2             	cmovne %edx,%eax
}
  801b17:	5b                   	pop    %ebx
  801b18:	5e                   	pop    %esi
  801b19:	5f                   	pop    %edi
  801b1a:	5d                   	pop    %ebp
  801b1b:	c3                   	ret    

00801b1c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b1c:	f3 0f 1e fb          	endbr32 
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	56                   	push   %esi
  801b24:	53                   	push   %ebx
  801b25:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2b:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801b2e:	85 c0                	test   %eax,%eax
  801b30:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b35:	0f 44 c2             	cmove  %edx,%eax
  801b38:	83 ec 0c             	sub    $0xc,%esp
  801b3b:	50                   	push   %eax
  801b3c:	e8 1b e8 ff ff       	call   80035c <sys_ipc_recv>
  801b41:	83 c4 10             	add    $0x10,%esp
  801b44:	85 c0                	test   %eax,%eax
  801b46:	78 24                	js     801b6c <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801b48:	85 f6                	test   %esi,%esi
  801b4a:	74 0a                	je     801b56 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801b4c:	a1 04 40 80 00       	mov    0x804004,%eax
  801b51:	8b 40 78             	mov    0x78(%eax),%eax
  801b54:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801b56:	85 db                	test   %ebx,%ebx
  801b58:	74 0a                	je     801b64 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801b5a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b5f:	8b 40 74             	mov    0x74(%eax),%eax
  801b62:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801b64:	a1 04 40 80 00       	mov    0x804004,%eax
  801b69:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b6f:	5b                   	pop    %ebx
  801b70:	5e                   	pop    %esi
  801b71:	5d                   	pop    %ebp
  801b72:	c3                   	ret    

00801b73 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b73:	f3 0f 1e fb          	endbr32 
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	57                   	push   %edi
  801b7b:	56                   	push   %esi
  801b7c:	53                   	push   %ebx
  801b7d:	83 ec 1c             	sub    $0x1c,%esp
  801b80:	8b 45 10             	mov    0x10(%ebp),%eax
  801b83:	85 c0                	test   %eax,%eax
  801b85:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b8a:	0f 45 d0             	cmovne %eax,%edx
  801b8d:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801b8f:	be 01 00 00 00       	mov    $0x1,%esi
  801b94:	eb 1f                	jmp    801bb5 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801b96:	e8 d2 e5 ff ff       	call   80016d <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801b9b:	83 c3 01             	add    $0x1,%ebx
  801b9e:	39 de                	cmp    %ebx,%esi
  801ba0:	7f f4                	jg     801b96 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801ba2:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801ba4:	83 fe 11             	cmp    $0x11,%esi
  801ba7:	b8 01 00 00 00       	mov    $0x1,%eax
  801bac:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801baf:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801bb3:	75 1c                	jne    801bd1 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801bb5:	ff 75 14             	pushl  0x14(%ebp)
  801bb8:	57                   	push   %edi
  801bb9:	ff 75 0c             	pushl  0xc(%ebp)
  801bbc:	ff 75 08             	pushl  0x8(%ebp)
  801bbf:	e8 71 e7 ff ff       	call   800335 <sys_ipc_try_send>
  801bc4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801bc7:	83 c4 10             	add    $0x10,%esp
  801bca:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bcf:	eb cd                	jmp    801b9e <ipc_send+0x2b>
}
  801bd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd4:	5b                   	pop    %ebx
  801bd5:	5e                   	pop    %esi
  801bd6:	5f                   	pop    %edi
  801bd7:	5d                   	pop    %ebp
  801bd8:	c3                   	ret    

00801bd9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bd9:	f3 0f 1e fb          	endbr32 
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801be3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801be8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801beb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bf1:	8b 52 50             	mov    0x50(%edx),%edx
  801bf4:	39 ca                	cmp    %ecx,%edx
  801bf6:	74 11                	je     801c09 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801bf8:	83 c0 01             	add    $0x1,%eax
  801bfb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c00:	75 e6                	jne    801be8 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801c02:	b8 00 00 00 00       	mov    $0x0,%eax
  801c07:	eb 0b                	jmp    801c14 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c09:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c0c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c11:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c14:	5d                   	pop    %ebp
  801c15:	c3                   	ret    

00801c16 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c16:	f3 0f 1e fb          	endbr32 
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c20:	89 c2                	mov    %eax,%edx
  801c22:	c1 ea 16             	shr    $0x16,%edx
  801c25:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c2c:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c31:	f6 c1 01             	test   $0x1,%cl
  801c34:	74 1c                	je     801c52 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c36:	c1 e8 0c             	shr    $0xc,%eax
  801c39:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c40:	a8 01                	test   $0x1,%al
  801c42:	74 0e                	je     801c52 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c44:	c1 e8 0c             	shr    $0xc,%eax
  801c47:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c4e:	ef 
  801c4f:	0f b7 d2             	movzwl %dx,%edx
}
  801c52:	89 d0                	mov    %edx,%eax
  801c54:	5d                   	pop    %ebp
  801c55:	c3                   	ret    
  801c56:	66 90                	xchg   %ax,%ax
  801c58:	66 90                	xchg   %ax,%ax
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
