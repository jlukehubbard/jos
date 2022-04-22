
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 1a 00 00 00       	call   80004b <libmain>
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
	sys_cputs((char*)1, 1);
  80003d:	6a 01                	push   $0x1
  80003f:	6a 01                	push   $0x1
  800041:	e8 77 00 00 00       	call   8000bd <sys_cputs>
}
  800046:	83 c4 10             	add    $0x10,%esp
  800049:	c9                   	leave  
  80004a:	c3                   	ret    

0080004b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004b:	f3 0f 1e fb          	endbr32 
  80004f:	55                   	push   %ebp
  800050:	89 e5                	mov    %esp,%ebp
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800057:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005a:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800061:	00 00 00 
    envid_t envid = sys_getenvid();
  800064:	e8 de 00 00 00       	call   800147 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800069:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800071:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800076:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007b:	85 db                	test   %ebx,%ebx
  80007d:	7e 07                	jle    800086 <libmain+0x3b>
		binaryname = argv[0];
  80007f:	8b 06                	mov    (%esi),%eax
  800081:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800086:	83 ec 08             	sub    $0x8,%esp
  800089:	56                   	push   %esi
  80008a:	53                   	push   %ebx
  80008b:	e8 a3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800090:	e8 0a 00 00 00       	call   80009f <exit>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5e                   	pop    %esi
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    

0080009f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009f:	f3 0f 1e fb          	endbr32 
  8000a3:	55                   	push   %ebp
  8000a4:	89 e5                	mov    %esp,%ebp
  8000a6:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a9:	e8 df 04 00 00       	call   80058d <close_all>
	sys_env_destroy(0);
  8000ae:	83 ec 0c             	sub    $0xc,%esp
  8000b1:	6a 00                	push   $0x0
  8000b3:	e8 4a 00 00 00       	call   800102 <sys_env_destroy>
}
  8000b8:	83 c4 10             	add    $0x10,%esp
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bd:	f3 0f 1e fb          	endbr32 
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	57                   	push   %edi
  8000c5:	56                   	push   %esi
  8000c6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d2:	89 c3                	mov    %eax,%ebx
  8000d4:	89 c7                	mov    %eax,%edi
  8000d6:	89 c6                	mov    %eax,%esi
  8000d8:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_cgetc>:

int
sys_cgetc(void)
{
  8000df:	f3 0f 1e fb          	endbr32 
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	f3 0f 1e fb          	endbr32 
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	57                   	push   %edi
  80010a:	56                   	push   %esi
  80010b:	53                   	push   %ebx
  80010c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80010f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800114:	8b 55 08             	mov    0x8(%ebp),%edx
  800117:	b8 03 00 00 00       	mov    $0x3,%eax
  80011c:	89 cb                	mov    %ecx,%ebx
  80011e:	89 cf                	mov    %ecx,%edi
  800120:	89 ce                	mov    %ecx,%esi
  800122:	cd 30                	int    $0x30
	if(check && ret > 0)
  800124:	85 c0                	test   %eax,%eax
  800126:	7f 08                	jg     800130 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800128:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012b:	5b                   	pop    %ebx
  80012c:	5e                   	pop    %esi
  80012d:	5f                   	pop    %edi
  80012e:	5d                   	pop    %ebp
  80012f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800130:	83 ec 0c             	sub    $0xc,%esp
  800133:	50                   	push   %eax
  800134:	6a 03                	push   $0x3
  800136:	68 ea 1e 80 00       	push   $0x801eea
  80013b:	6a 23                	push   $0x23
  80013d:	68 07 1f 80 00       	push   $0x801f07
  800142:	e8 9c 0f 00 00       	call   8010e3 <_panic>

00800147 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800147:	f3 0f 1e fb          	endbr32 
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 02 00 00 00       	mov    $0x2,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_yield>:

void
sys_yield(void)
{
  80016a:	f3 0f 1e fb          	endbr32 
  80016e:	55                   	push   %ebp
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	57                   	push   %edi
  800172:	56                   	push   %esi
  800173:	53                   	push   %ebx
	asm volatile("int %1\n"
  800174:	ba 00 00 00 00       	mov    $0x0,%edx
  800179:	b8 0b 00 00 00       	mov    $0xb,%eax
  80017e:	89 d1                	mov    %edx,%ecx
  800180:	89 d3                	mov    %edx,%ebx
  800182:	89 d7                	mov    %edx,%edi
  800184:	89 d6                	mov    %edx,%esi
  800186:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800188:	5b                   	pop    %ebx
  800189:	5e                   	pop    %esi
  80018a:	5f                   	pop    %edi
  80018b:	5d                   	pop    %ebp
  80018c:	c3                   	ret    

0080018d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80018d:	f3 0f 1e fb          	endbr32 
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	57                   	push   %edi
  800195:	56                   	push   %esi
  800196:	53                   	push   %ebx
  800197:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80019a:	be 00 00 00 00       	mov    $0x0,%esi
  80019f:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a5:	b8 04 00 00 00       	mov    $0x4,%eax
  8001aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ad:	89 f7                	mov    %esi,%edi
  8001af:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b1:	85 c0                	test   %eax,%eax
  8001b3:	7f 08                	jg     8001bd <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b8:	5b                   	pop    %ebx
  8001b9:	5e                   	pop    %esi
  8001ba:	5f                   	pop    %edi
  8001bb:	5d                   	pop    %ebp
  8001bc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bd:	83 ec 0c             	sub    $0xc,%esp
  8001c0:	50                   	push   %eax
  8001c1:	6a 04                	push   $0x4
  8001c3:	68 ea 1e 80 00       	push   $0x801eea
  8001c8:	6a 23                	push   $0x23
  8001ca:	68 07 1f 80 00       	push   $0x801f07
  8001cf:	e8 0f 0f 00 00       	call   8010e3 <_panic>

008001d4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d4:	f3 0f 1e fb          	endbr32 
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	57                   	push   %edi
  8001dc:	56                   	push   %esi
  8001dd:	53                   	push   %ebx
  8001de:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e7:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ef:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	7f 08                	jg     800203 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fe:	5b                   	pop    %ebx
  8001ff:	5e                   	pop    %esi
  800200:	5f                   	pop    %edi
  800201:	5d                   	pop    %ebp
  800202:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800203:	83 ec 0c             	sub    $0xc,%esp
  800206:	50                   	push   %eax
  800207:	6a 05                	push   $0x5
  800209:	68 ea 1e 80 00       	push   $0x801eea
  80020e:	6a 23                	push   $0x23
  800210:	68 07 1f 80 00       	push   $0x801f07
  800215:	e8 c9 0e 00 00       	call   8010e3 <_panic>

0080021a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80021a:	f3 0f 1e fb          	endbr32 
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	57                   	push   %edi
  800222:	56                   	push   %esi
  800223:	53                   	push   %ebx
  800224:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800227:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022c:	8b 55 08             	mov    0x8(%ebp),%edx
  80022f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800232:	b8 06 00 00 00       	mov    $0x6,%eax
  800237:	89 df                	mov    %ebx,%edi
  800239:	89 de                	mov    %ebx,%esi
  80023b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80023d:	85 c0                	test   %eax,%eax
  80023f:	7f 08                	jg     800249 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800241:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800244:	5b                   	pop    %ebx
  800245:	5e                   	pop    %esi
  800246:	5f                   	pop    %edi
  800247:	5d                   	pop    %ebp
  800248:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	50                   	push   %eax
  80024d:	6a 06                	push   $0x6
  80024f:	68 ea 1e 80 00       	push   $0x801eea
  800254:	6a 23                	push   $0x23
  800256:	68 07 1f 80 00       	push   $0x801f07
  80025b:	e8 83 0e 00 00       	call   8010e3 <_panic>

00800260 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800260:	f3 0f 1e fb          	endbr32 
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	57                   	push   %edi
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80026d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800272:	8b 55 08             	mov    0x8(%ebp),%edx
  800275:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800278:	b8 08 00 00 00       	mov    $0x8,%eax
  80027d:	89 df                	mov    %ebx,%edi
  80027f:	89 de                	mov    %ebx,%esi
  800281:	cd 30                	int    $0x30
	if(check && ret > 0)
  800283:	85 c0                	test   %eax,%eax
  800285:	7f 08                	jg     80028f <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800287:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028a:	5b                   	pop    %ebx
  80028b:	5e                   	pop    %esi
  80028c:	5f                   	pop    %edi
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	50                   	push   %eax
  800293:	6a 08                	push   $0x8
  800295:	68 ea 1e 80 00       	push   $0x801eea
  80029a:	6a 23                	push   $0x23
  80029c:	68 07 1f 80 00       	push   $0x801f07
  8002a1:	e8 3d 0e 00 00       	call   8010e3 <_panic>

008002a6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002a6:	f3 0f 1e fb          	endbr32 
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	57                   	push   %edi
  8002ae:	56                   	push   %esi
  8002af:	53                   	push   %ebx
  8002b0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002be:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c3:	89 df                	mov    %ebx,%edi
  8002c5:	89 de                	mov    %ebx,%esi
  8002c7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002c9:	85 c0                	test   %eax,%eax
  8002cb:	7f 08                	jg     8002d5 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d0:	5b                   	pop    %ebx
  8002d1:	5e                   	pop    %esi
  8002d2:	5f                   	pop    %edi
  8002d3:	5d                   	pop    %ebp
  8002d4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d5:	83 ec 0c             	sub    $0xc,%esp
  8002d8:	50                   	push   %eax
  8002d9:	6a 09                	push   $0x9
  8002db:	68 ea 1e 80 00       	push   $0x801eea
  8002e0:	6a 23                	push   $0x23
  8002e2:	68 07 1f 80 00       	push   $0x801f07
  8002e7:	e8 f7 0d 00 00       	call   8010e3 <_panic>

008002ec <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ec:	f3 0f 1e fb          	endbr32 
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800301:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800304:	b8 0a 00 00 00       	mov    $0xa,%eax
  800309:	89 df                	mov    %ebx,%edi
  80030b:	89 de                	mov    %ebx,%esi
  80030d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80030f:	85 c0                	test   %eax,%eax
  800311:	7f 08                	jg     80031b <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800313:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800316:	5b                   	pop    %ebx
  800317:	5e                   	pop    %esi
  800318:	5f                   	pop    %edi
  800319:	5d                   	pop    %ebp
  80031a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80031b:	83 ec 0c             	sub    $0xc,%esp
  80031e:	50                   	push   %eax
  80031f:	6a 0a                	push   $0xa
  800321:	68 ea 1e 80 00       	push   $0x801eea
  800326:	6a 23                	push   $0x23
  800328:	68 07 1f 80 00       	push   $0x801f07
  80032d:	e8 b1 0d 00 00       	call   8010e3 <_panic>

00800332 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800332:	f3 0f 1e fb          	endbr32 
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	57                   	push   %edi
  80033a:	56                   	push   %esi
  80033b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80033c:	8b 55 08             	mov    0x8(%ebp),%edx
  80033f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800342:	b8 0c 00 00 00       	mov    $0xc,%eax
  800347:	be 00 00 00 00       	mov    $0x0,%esi
  80034c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80034f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800352:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800354:	5b                   	pop    %ebx
  800355:	5e                   	pop    %esi
  800356:	5f                   	pop    %edi
  800357:	5d                   	pop    %ebp
  800358:	c3                   	ret    

00800359 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800359:	f3 0f 1e fb          	endbr32 
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	57                   	push   %edi
  800361:	56                   	push   %esi
  800362:	53                   	push   %ebx
  800363:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800366:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036b:	8b 55 08             	mov    0x8(%ebp),%edx
  80036e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800373:	89 cb                	mov    %ecx,%ebx
  800375:	89 cf                	mov    %ecx,%edi
  800377:	89 ce                	mov    %ecx,%esi
  800379:	cd 30                	int    $0x30
	if(check && ret > 0)
  80037b:	85 c0                	test   %eax,%eax
  80037d:	7f 08                	jg     800387 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80037f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800382:	5b                   	pop    %ebx
  800383:	5e                   	pop    %esi
  800384:	5f                   	pop    %edi
  800385:	5d                   	pop    %ebp
  800386:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800387:	83 ec 0c             	sub    $0xc,%esp
  80038a:	50                   	push   %eax
  80038b:	6a 0d                	push   $0xd
  80038d:	68 ea 1e 80 00       	push   $0x801eea
  800392:	6a 23                	push   $0x23
  800394:	68 07 1f 80 00       	push   $0x801f07
  800399:	e8 45 0d 00 00       	call   8010e3 <_panic>

0080039e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80039e:	f3 0f 1e fb          	endbr32 
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a8:	05 00 00 00 30       	add    $0x30000000,%eax
  8003ad:	c1 e8 0c             	shr    $0xc,%eax
}
  8003b0:	5d                   	pop    %ebp
  8003b1:	c3                   	ret    

008003b2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003b2:	f3 0f 1e fb          	endbr32 
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bc:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003c1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003c6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003cd:	f3 0f 1e fb          	endbr32 
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003d9:	89 c2                	mov    %eax,%edx
  8003db:	c1 ea 16             	shr    $0x16,%edx
  8003de:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e5:	f6 c2 01             	test   $0x1,%dl
  8003e8:	74 2d                	je     800417 <fd_alloc+0x4a>
  8003ea:	89 c2                	mov    %eax,%edx
  8003ec:	c1 ea 0c             	shr    $0xc,%edx
  8003ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f6:	f6 c2 01             	test   $0x1,%dl
  8003f9:	74 1c                	je     800417 <fd_alloc+0x4a>
  8003fb:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800400:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800405:	75 d2                	jne    8003d9 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800407:	8b 45 08             	mov    0x8(%ebp),%eax
  80040a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800410:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800415:	eb 0a                	jmp    800421 <fd_alloc+0x54>
			*fd_store = fd;
  800417:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80041c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800421:	5d                   	pop    %ebp
  800422:	c3                   	ret    

00800423 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800423:	f3 0f 1e fb          	endbr32 
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80042d:	83 f8 1f             	cmp    $0x1f,%eax
  800430:	77 30                	ja     800462 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800432:	c1 e0 0c             	shl    $0xc,%eax
  800435:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80043a:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800440:	f6 c2 01             	test   $0x1,%dl
  800443:	74 24                	je     800469 <fd_lookup+0x46>
  800445:	89 c2                	mov    %eax,%edx
  800447:	c1 ea 0c             	shr    $0xc,%edx
  80044a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800451:	f6 c2 01             	test   $0x1,%dl
  800454:	74 1a                	je     800470 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800456:	8b 55 0c             	mov    0xc(%ebp),%edx
  800459:	89 02                	mov    %eax,(%edx)
	return 0;
  80045b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800460:	5d                   	pop    %ebp
  800461:	c3                   	ret    
		return -E_INVAL;
  800462:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800467:	eb f7                	jmp    800460 <fd_lookup+0x3d>
		return -E_INVAL;
  800469:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80046e:	eb f0                	jmp    800460 <fd_lookup+0x3d>
  800470:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800475:	eb e9                	jmp    800460 <fd_lookup+0x3d>

00800477 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800477:	f3 0f 1e fb          	endbr32 
  80047b:	55                   	push   %ebp
  80047c:	89 e5                	mov    %esp,%ebp
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800484:	ba 94 1f 80 00       	mov    $0x801f94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800489:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80048e:	39 08                	cmp    %ecx,(%eax)
  800490:	74 33                	je     8004c5 <dev_lookup+0x4e>
  800492:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800495:	8b 02                	mov    (%edx),%eax
  800497:	85 c0                	test   %eax,%eax
  800499:	75 f3                	jne    80048e <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80049b:	a1 04 40 80 00       	mov    0x804004,%eax
  8004a0:	8b 40 48             	mov    0x48(%eax),%eax
  8004a3:	83 ec 04             	sub    $0x4,%esp
  8004a6:	51                   	push   %ecx
  8004a7:	50                   	push   %eax
  8004a8:	68 18 1f 80 00       	push   $0x801f18
  8004ad:	e8 18 0d 00 00       	call   8011ca <cprintf>
	*dev = 0;
  8004b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004bb:	83 c4 10             	add    $0x10,%esp
  8004be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004c3:	c9                   	leave  
  8004c4:	c3                   	ret    
			*dev = devtab[i];
  8004c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004c8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cf:	eb f2                	jmp    8004c3 <dev_lookup+0x4c>

008004d1 <fd_close>:
{
  8004d1:	f3 0f 1e fb          	endbr32 
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
  8004d8:	57                   	push   %edi
  8004d9:	56                   	push   %esi
  8004da:	53                   	push   %ebx
  8004db:	83 ec 24             	sub    $0x24,%esp
  8004de:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004e4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004e7:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004e8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004ee:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004f1:	50                   	push   %eax
  8004f2:	e8 2c ff ff ff       	call   800423 <fd_lookup>
  8004f7:	89 c3                	mov    %eax,%ebx
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	78 05                	js     800505 <fd_close+0x34>
	    || fd != fd2)
  800500:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800503:	74 16                	je     80051b <fd_close+0x4a>
		return (must_exist ? r : 0);
  800505:	89 f8                	mov    %edi,%eax
  800507:	84 c0                	test   %al,%al
  800509:	b8 00 00 00 00       	mov    $0x0,%eax
  80050e:	0f 44 d8             	cmove  %eax,%ebx
}
  800511:	89 d8                	mov    %ebx,%eax
  800513:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800516:	5b                   	pop    %ebx
  800517:	5e                   	pop    %esi
  800518:	5f                   	pop    %edi
  800519:	5d                   	pop    %ebp
  80051a:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800521:	50                   	push   %eax
  800522:	ff 36                	pushl  (%esi)
  800524:	e8 4e ff ff ff       	call   800477 <dev_lookup>
  800529:	89 c3                	mov    %eax,%ebx
  80052b:	83 c4 10             	add    $0x10,%esp
  80052e:	85 c0                	test   %eax,%eax
  800530:	78 1a                	js     80054c <fd_close+0x7b>
		if (dev->dev_close)
  800532:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800535:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800538:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80053d:	85 c0                	test   %eax,%eax
  80053f:	74 0b                	je     80054c <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800541:	83 ec 0c             	sub    $0xc,%esp
  800544:	56                   	push   %esi
  800545:	ff d0                	call   *%eax
  800547:	89 c3                	mov    %eax,%ebx
  800549:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	56                   	push   %esi
  800550:	6a 00                	push   $0x0
  800552:	e8 c3 fc ff ff       	call   80021a <sys_page_unmap>
	return r;
  800557:	83 c4 10             	add    $0x10,%esp
  80055a:	eb b5                	jmp    800511 <fd_close+0x40>

0080055c <close>:

int
close(int fdnum)
{
  80055c:	f3 0f 1e fb          	endbr32 
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800566:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800569:	50                   	push   %eax
  80056a:	ff 75 08             	pushl  0x8(%ebp)
  80056d:	e8 b1 fe ff ff       	call   800423 <fd_lookup>
  800572:	83 c4 10             	add    $0x10,%esp
  800575:	85 c0                	test   %eax,%eax
  800577:	79 02                	jns    80057b <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800579:	c9                   	leave  
  80057a:	c3                   	ret    
		return fd_close(fd, 1);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	6a 01                	push   $0x1
  800580:	ff 75 f4             	pushl  -0xc(%ebp)
  800583:	e8 49 ff ff ff       	call   8004d1 <fd_close>
  800588:	83 c4 10             	add    $0x10,%esp
  80058b:	eb ec                	jmp    800579 <close+0x1d>

0080058d <close_all>:

void
close_all(void)
{
  80058d:	f3 0f 1e fb          	endbr32 
  800591:	55                   	push   %ebp
  800592:	89 e5                	mov    %esp,%ebp
  800594:	53                   	push   %ebx
  800595:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800598:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	53                   	push   %ebx
  8005a1:	e8 b6 ff ff ff       	call   80055c <close>
	for (i = 0; i < MAXFD; i++)
  8005a6:	83 c3 01             	add    $0x1,%ebx
  8005a9:	83 c4 10             	add    $0x10,%esp
  8005ac:	83 fb 20             	cmp    $0x20,%ebx
  8005af:	75 ec                	jne    80059d <close_all+0x10>
}
  8005b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005b4:	c9                   	leave  
  8005b5:	c3                   	ret    

008005b6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005b6:	f3 0f 1e fb          	endbr32 
  8005ba:	55                   	push   %ebp
  8005bb:	89 e5                	mov    %esp,%ebp
  8005bd:	57                   	push   %edi
  8005be:	56                   	push   %esi
  8005bf:	53                   	push   %ebx
  8005c0:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005c3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 08             	pushl  0x8(%ebp)
  8005ca:	e8 54 fe ff ff       	call   800423 <fd_lookup>
  8005cf:	89 c3                	mov    %eax,%ebx
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	85 c0                	test   %eax,%eax
  8005d6:	0f 88 81 00 00 00    	js     80065d <dup+0xa7>
		return r;
	close(newfdnum);
  8005dc:	83 ec 0c             	sub    $0xc,%esp
  8005df:	ff 75 0c             	pushl  0xc(%ebp)
  8005e2:	e8 75 ff ff ff       	call   80055c <close>

	newfd = INDEX2FD(newfdnum);
  8005e7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005ea:	c1 e6 0c             	shl    $0xc,%esi
  8005ed:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005f3:	83 c4 04             	add    $0x4,%esp
  8005f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005f9:	e8 b4 fd ff ff       	call   8003b2 <fd2data>
  8005fe:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800600:	89 34 24             	mov    %esi,(%esp)
  800603:	e8 aa fd ff ff       	call   8003b2 <fd2data>
  800608:	83 c4 10             	add    $0x10,%esp
  80060b:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80060d:	89 d8                	mov    %ebx,%eax
  80060f:	c1 e8 16             	shr    $0x16,%eax
  800612:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800619:	a8 01                	test   $0x1,%al
  80061b:	74 11                	je     80062e <dup+0x78>
  80061d:	89 d8                	mov    %ebx,%eax
  80061f:	c1 e8 0c             	shr    $0xc,%eax
  800622:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800629:	f6 c2 01             	test   $0x1,%dl
  80062c:	75 39                	jne    800667 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80062e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800631:	89 d0                	mov    %edx,%eax
  800633:	c1 e8 0c             	shr    $0xc,%eax
  800636:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80063d:	83 ec 0c             	sub    $0xc,%esp
  800640:	25 07 0e 00 00       	and    $0xe07,%eax
  800645:	50                   	push   %eax
  800646:	56                   	push   %esi
  800647:	6a 00                	push   $0x0
  800649:	52                   	push   %edx
  80064a:	6a 00                	push   $0x0
  80064c:	e8 83 fb ff ff       	call   8001d4 <sys_page_map>
  800651:	89 c3                	mov    %eax,%ebx
  800653:	83 c4 20             	add    $0x20,%esp
  800656:	85 c0                	test   %eax,%eax
  800658:	78 31                	js     80068b <dup+0xd5>
		goto err;

	return newfdnum;
  80065a:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80065d:	89 d8                	mov    %ebx,%eax
  80065f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800662:	5b                   	pop    %ebx
  800663:	5e                   	pop    %esi
  800664:	5f                   	pop    %edi
  800665:	5d                   	pop    %ebp
  800666:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800667:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80066e:	83 ec 0c             	sub    $0xc,%esp
  800671:	25 07 0e 00 00       	and    $0xe07,%eax
  800676:	50                   	push   %eax
  800677:	57                   	push   %edi
  800678:	6a 00                	push   $0x0
  80067a:	53                   	push   %ebx
  80067b:	6a 00                	push   $0x0
  80067d:	e8 52 fb ff ff       	call   8001d4 <sys_page_map>
  800682:	89 c3                	mov    %eax,%ebx
  800684:	83 c4 20             	add    $0x20,%esp
  800687:	85 c0                	test   %eax,%eax
  800689:	79 a3                	jns    80062e <dup+0x78>
	sys_page_unmap(0, newfd);
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	56                   	push   %esi
  80068f:	6a 00                	push   $0x0
  800691:	e8 84 fb ff ff       	call   80021a <sys_page_unmap>
	sys_page_unmap(0, nva);
  800696:	83 c4 08             	add    $0x8,%esp
  800699:	57                   	push   %edi
  80069a:	6a 00                	push   $0x0
  80069c:	e8 79 fb ff ff       	call   80021a <sys_page_unmap>
	return r;
  8006a1:	83 c4 10             	add    $0x10,%esp
  8006a4:	eb b7                	jmp    80065d <dup+0xa7>

008006a6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006a6:	f3 0f 1e fb          	endbr32 
  8006aa:	55                   	push   %ebp
  8006ab:	89 e5                	mov    %esp,%ebp
  8006ad:	53                   	push   %ebx
  8006ae:	83 ec 1c             	sub    $0x1c,%esp
  8006b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006b7:	50                   	push   %eax
  8006b8:	53                   	push   %ebx
  8006b9:	e8 65 fd ff ff       	call   800423 <fd_lookup>
  8006be:	83 c4 10             	add    $0x10,%esp
  8006c1:	85 c0                	test   %eax,%eax
  8006c3:	78 3f                	js     800704 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006cb:	50                   	push   %eax
  8006cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006cf:	ff 30                	pushl  (%eax)
  8006d1:	e8 a1 fd ff ff       	call   800477 <dev_lookup>
  8006d6:	83 c4 10             	add    $0x10,%esp
  8006d9:	85 c0                	test   %eax,%eax
  8006db:	78 27                	js     800704 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006e0:	8b 42 08             	mov    0x8(%edx),%eax
  8006e3:	83 e0 03             	and    $0x3,%eax
  8006e6:	83 f8 01             	cmp    $0x1,%eax
  8006e9:	74 1e                	je     800709 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ee:	8b 40 08             	mov    0x8(%eax),%eax
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	74 35                	je     80072a <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006f5:	83 ec 04             	sub    $0x4,%esp
  8006f8:	ff 75 10             	pushl  0x10(%ebp)
  8006fb:	ff 75 0c             	pushl  0xc(%ebp)
  8006fe:	52                   	push   %edx
  8006ff:	ff d0                	call   *%eax
  800701:	83 c4 10             	add    $0x10,%esp
}
  800704:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800707:	c9                   	leave  
  800708:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800709:	a1 04 40 80 00       	mov    0x804004,%eax
  80070e:	8b 40 48             	mov    0x48(%eax),%eax
  800711:	83 ec 04             	sub    $0x4,%esp
  800714:	53                   	push   %ebx
  800715:	50                   	push   %eax
  800716:	68 59 1f 80 00       	push   $0x801f59
  80071b:	e8 aa 0a 00 00       	call   8011ca <cprintf>
		return -E_INVAL;
  800720:	83 c4 10             	add    $0x10,%esp
  800723:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800728:	eb da                	jmp    800704 <read+0x5e>
		return -E_NOT_SUPP;
  80072a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80072f:	eb d3                	jmp    800704 <read+0x5e>

00800731 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800731:	f3 0f 1e fb          	endbr32 
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	57                   	push   %edi
  800739:	56                   	push   %esi
  80073a:	53                   	push   %ebx
  80073b:	83 ec 0c             	sub    $0xc,%esp
  80073e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800741:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800744:	bb 00 00 00 00       	mov    $0x0,%ebx
  800749:	eb 02                	jmp    80074d <readn+0x1c>
  80074b:	01 c3                	add    %eax,%ebx
  80074d:	39 f3                	cmp    %esi,%ebx
  80074f:	73 21                	jae    800772 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800751:	83 ec 04             	sub    $0x4,%esp
  800754:	89 f0                	mov    %esi,%eax
  800756:	29 d8                	sub    %ebx,%eax
  800758:	50                   	push   %eax
  800759:	89 d8                	mov    %ebx,%eax
  80075b:	03 45 0c             	add    0xc(%ebp),%eax
  80075e:	50                   	push   %eax
  80075f:	57                   	push   %edi
  800760:	e8 41 ff ff ff       	call   8006a6 <read>
		if (m < 0)
  800765:	83 c4 10             	add    $0x10,%esp
  800768:	85 c0                	test   %eax,%eax
  80076a:	78 04                	js     800770 <readn+0x3f>
			return m;
		if (m == 0)
  80076c:	75 dd                	jne    80074b <readn+0x1a>
  80076e:	eb 02                	jmp    800772 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800770:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800772:	89 d8                	mov    %ebx,%eax
  800774:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800777:	5b                   	pop    %ebx
  800778:	5e                   	pop    %esi
  800779:	5f                   	pop    %edi
  80077a:	5d                   	pop    %ebp
  80077b:	c3                   	ret    

0080077c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80077c:	f3 0f 1e fb          	endbr32 
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	53                   	push   %ebx
  800784:	83 ec 1c             	sub    $0x1c,%esp
  800787:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80078a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80078d:	50                   	push   %eax
  80078e:	53                   	push   %ebx
  80078f:	e8 8f fc ff ff       	call   800423 <fd_lookup>
  800794:	83 c4 10             	add    $0x10,%esp
  800797:	85 c0                	test   %eax,%eax
  800799:	78 3a                	js     8007d5 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80079b:	83 ec 08             	sub    $0x8,%esp
  80079e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007a1:	50                   	push   %eax
  8007a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007a5:	ff 30                	pushl  (%eax)
  8007a7:	e8 cb fc ff ff       	call   800477 <dev_lookup>
  8007ac:	83 c4 10             	add    $0x10,%esp
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	78 22                	js     8007d5 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007b6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ba:	74 1e                	je     8007da <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007bf:	8b 52 0c             	mov    0xc(%edx),%edx
  8007c2:	85 d2                	test   %edx,%edx
  8007c4:	74 35                	je     8007fb <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007c6:	83 ec 04             	sub    $0x4,%esp
  8007c9:	ff 75 10             	pushl  0x10(%ebp)
  8007cc:	ff 75 0c             	pushl  0xc(%ebp)
  8007cf:	50                   	push   %eax
  8007d0:	ff d2                	call   *%edx
  8007d2:	83 c4 10             	add    $0x10,%esp
}
  8007d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d8:	c9                   	leave  
  8007d9:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007da:	a1 04 40 80 00       	mov    0x804004,%eax
  8007df:	8b 40 48             	mov    0x48(%eax),%eax
  8007e2:	83 ec 04             	sub    $0x4,%esp
  8007e5:	53                   	push   %ebx
  8007e6:	50                   	push   %eax
  8007e7:	68 75 1f 80 00       	push   $0x801f75
  8007ec:	e8 d9 09 00 00       	call   8011ca <cprintf>
		return -E_INVAL;
  8007f1:	83 c4 10             	add    $0x10,%esp
  8007f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007f9:	eb da                	jmp    8007d5 <write+0x59>
		return -E_NOT_SUPP;
  8007fb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800800:	eb d3                	jmp    8007d5 <write+0x59>

00800802 <seek>:

int
seek(int fdnum, off_t offset)
{
  800802:	f3 0f 1e fb          	endbr32 
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80080c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80080f:	50                   	push   %eax
  800810:	ff 75 08             	pushl  0x8(%ebp)
  800813:	e8 0b fc ff ff       	call   800423 <fd_lookup>
  800818:	83 c4 10             	add    $0x10,%esp
  80081b:	85 c0                	test   %eax,%eax
  80081d:	78 0e                	js     80082d <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80081f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800822:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800825:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800828:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80082d:	c9                   	leave  
  80082e:	c3                   	ret    

0080082f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80082f:	f3 0f 1e fb          	endbr32 
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	53                   	push   %ebx
  800837:	83 ec 1c             	sub    $0x1c,%esp
  80083a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80083d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800840:	50                   	push   %eax
  800841:	53                   	push   %ebx
  800842:	e8 dc fb ff ff       	call   800423 <fd_lookup>
  800847:	83 c4 10             	add    $0x10,%esp
  80084a:	85 c0                	test   %eax,%eax
  80084c:	78 37                	js     800885 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80084e:	83 ec 08             	sub    $0x8,%esp
  800851:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800854:	50                   	push   %eax
  800855:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800858:	ff 30                	pushl  (%eax)
  80085a:	e8 18 fc ff ff       	call   800477 <dev_lookup>
  80085f:	83 c4 10             	add    $0x10,%esp
  800862:	85 c0                	test   %eax,%eax
  800864:	78 1f                	js     800885 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800866:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800869:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80086d:	74 1b                	je     80088a <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80086f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800872:	8b 52 18             	mov    0x18(%edx),%edx
  800875:	85 d2                	test   %edx,%edx
  800877:	74 32                	je     8008ab <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800879:	83 ec 08             	sub    $0x8,%esp
  80087c:	ff 75 0c             	pushl  0xc(%ebp)
  80087f:	50                   	push   %eax
  800880:	ff d2                	call   *%edx
  800882:	83 c4 10             	add    $0x10,%esp
}
  800885:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800888:	c9                   	leave  
  800889:	c3                   	ret    
			thisenv->env_id, fdnum);
  80088a:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80088f:	8b 40 48             	mov    0x48(%eax),%eax
  800892:	83 ec 04             	sub    $0x4,%esp
  800895:	53                   	push   %ebx
  800896:	50                   	push   %eax
  800897:	68 38 1f 80 00       	push   $0x801f38
  80089c:	e8 29 09 00 00       	call   8011ca <cprintf>
		return -E_INVAL;
  8008a1:	83 c4 10             	add    $0x10,%esp
  8008a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008a9:	eb da                	jmp    800885 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8008ab:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008b0:	eb d3                	jmp    800885 <ftruncate+0x56>

008008b2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008b2:	f3 0f 1e fb          	endbr32 
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	53                   	push   %ebx
  8008ba:	83 ec 1c             	sub    $0x1c,%esp
  8008bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008c3:	50                   	push   %eax
  8008c4:	ff 75 08             	pushl  0x8(%ebp)
  8008c7:	e8 57 fb ff ff       	call   800423 <fd_lookup>
  8008cc:	83 c4 10             	add    $0x10,%esp
  8008cf:	85 c0                	test   %eax,%eax
  8008d1:	78 4b                	js     80091e <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d3:	83 ec 08             	sub    $0x8,%esp
  8008d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008d9:	50                   	push   %eax
  8008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008dd:	ff 30                	pushl  (%eax)
  8008df:	e8 93 fb ff ff       	call   800477 <dev_lookup>
  8008e4:	83 c4 10             	add    $0x10,%esp
  8008e7:	85 c0                	test   %eax,%eax
  8008e9:	78 33                	js     80091e <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8008eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ee:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008f2:	74 2f                	je     800923 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008f4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008f7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008fe:	00 00 00 
	stat->st_isdir = 0;
  800901:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800908:	00 00 00 
	stat->st_dev = dev;
  80090b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800911:	83 ec 08             	sub    $0x8,%esp
  800914:	53                   	push   %ebx
  800915:	ff 75 f0             	pushl  -0x10(%ebp)
  800918:	ff 50 14             	call   *0x14(%eax)
  80091b:	83 c4 10             	add    $0x10,%esp
}
  80091e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800921:	c9                   	leave  
  800922:	c3                   	ret    
		return -E_NOT_SUPP;
  800923:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800928:	eb f4                	jmp    80091e <fstat+0x6c>

0080092a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80092a:	f3 0f 1e fb          	endbr32 
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	56                   	push   %esi
  800932:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800933:	83 ec 08             	sub    $0x8,%esp
  800936:	6a 00                	push   $0x0
  800938:	ff 75 08             	pushl  0x8(%ebp)
  80093b:	e8 fb 01 00 00       	call   800b3b <open>
  800940:	89 c3                	mov    %eax,%ebx
  800942:	83 c4 10             	add    $0x10,%esp
  800945:	85 c0                	test   %eax,%eax
  800947:	78 1b                	js     800964 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  800949:	83 ec 08             	sub    $0x8,%esp
  80094c:	ff 75 0c             	pushl  0xc(%ebp)
  80094f:	50                   	push   %eax
  800950:	e8 5d ff ff ff       	call   8008b2 <fstat>
  800955:	89 c6                	mov    %eax,%esi
	close(fd);
  800957:	89 1c 24             	mov    %ebx,(%esp)
  80095a:	e8 fd fb ff ff       	call   80055c <close>
	return r;
  80095f:	83 c4 10             	add    $0x10,%esp
  800962:	89 f3                	mov    %esi,%ebx
}
  800964:	89 d8                	mov    %ebx,%eax
  800966:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800969:	5b                   	pop    %ebx
  80096a:	5e                   	pop    %esi
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	56                   	push   %esi
  800971:	53                   	push   %ebx
  800972:	89 c6                	mov    %eax,%esi
  800974:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800976:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80097d:	74 27                	je     8009a6 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80097f:	6a 07                	push   $0x7
  800981:	68 00 50 80 00       	push   $0x805000
  800986:	56                   	push   %esi
  800987:	ff 35 00 40 80 00    	pushl  0x804000
  80098d:	e8 0a 12 00 00       	call   801b9c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800992:	83 c4 0c             	add    $0xc,%esp
  800995:	6a 00                	push   $0x0
  800997:	53                   	push   %ebx
  800998:	6a 00                	push   $0x0
  80099a:	e8 a6 11 00 00       	call   801b45 <ipc_recv>
}
  80099f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009a2:	5b                   	pop    %ebx
  8009a3:	5e                   	pop    %esi
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009a6:	83 ec 0c             	sub    $0xc,%esp
  8009a9:	6a 01                	push   $0x1
  8009ab:	e8 52 12 00 00       	call   801c02 <ipc_find_env>
  8009b0:	a3 00 40 80 00       	mov    %eax,0x804000
  8009b5:	83 c4 10             	add    $0x10,%esp
  8009b8:	eb c5                	jmp    80097f <fsipc+0x12>

008009ba <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009ba:	f3 0f 1e fb          	endbr32 
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ca:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009dc:	b8 02 00 00 00       	mov    $0x2,%eax
  8009e1:	e8 87 ff ff ff       	call   80096d <fsipc>
}
  8009e6:	c9                   	leave  
  8009e7:	c3                   	ret    

008009e8 <devfile_flush>:
{
  8009e8:	f3 0f 1e fb          	endbr32 
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800a02:	b8 06 00 00 00       	mov    $0x6,%eax
  800a07:	e8 61 ff ff ff       	call   80096d <fsipc>
}
  800a0c:	c9                   	leave  
  800a0d:	c3                   	ret    

00800a0e <devfile_stat>:
{
  800a0e:	f3 0f 1e fb          	endbr32 
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	53                   	push   %ebx
  800a16:	83 ec 04             	sub    $0x4,%esp
  800a19:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a22:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a27:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2c:	b8 05 00 00 00       	mov    $0x5,%eax
  800a31:	e8 37 ff ff ff       	call   80096d <fsipc>
  800a36:	85 c0                	test   %eax,%eax
  800a38:	78 2c                	js     800a66 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a3a:	83 ec 08             	sub    $0x8,%esp
  800a3d:	68 00 50 80 00       	push   $0x805000
  800a42:	53                   	push   %ebx
  800a43:	e8 8b 0d 00 00       	call   8017d3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a48:	a1 80 50 80 00       	mov    0x805080,%eax
  800a4d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a53:	a1 84 50 80 00       	mov    0x805084,%eax
  800a58:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a5e:	83 c4 10             	add    $0x10,%esp
  800a61:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a69:	c9                   	leave  
  800a6a:	c3                   	ret    

00800a6b <devfile_write>:
{
  800a6b:	f3 0f 1e fb          	endbr32 
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	83 ec 0c             	sub    $0xc,%esp
  800a75:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  800a78:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a7d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a82:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a85:	8b 55 08             	mov    0x8(%ebp),%edx
  800a88:	8b 52 0c             	mov    0xc(%edx),%edx
  800a8b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a91:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a96:	50                   	push   %eax
  800a97:	ff 75 0c             	pushl  0xc(%ebp)
  800a9a:	68 08 50 80 00       	push   $0x805008
  800a9f:	e8 e5 0e 00 00       	call   801989 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800aa4:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa9:	b8 04 00 00 00       	mov    $0x4,%eax
  800aae:	e8 ba fe ff ff       	call   80096d <fsipc>
}
  800ab3:	c9                   	leave  
  800ab4:	c3                   	ret    

00800ab5 <devfile_read>:
{
  800ab5:	f3 0f 1e fb          	endbr32 
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	56                   	push   %esi
  800abd:	53                   	push   %ebx
  800abe:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac4:	8b 40 0c             	mov    0xc(%eax),%eax
  800ac7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800acc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ad2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad7:	b8 03 00 00 00       	mov    $0x3,%eax
  800adc:	e8 8c fe ff ff       	call   80096d <fsipc>
  800ae1:	89 c3                	mov    %eax,%ebx
  800ae3:	85 c0                	test   %eax,%eax
  800ae5:	78 1f                	js     800b06 <devfile_read+0x51>
	assert(r <= n);
  800ae7:	39 f0                	cmp    %esi,%eax
  800ae9:	77 24                	ja     800b0f <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800aeb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800af0:	7f 33                	jg     800b25 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800af2:	83 ec 04             	sub    $0x4,%esp
  800af5:	50                   	push   %eax
  800af6:	68 00 50 80 00       	push   $0x805000
  800afb:	ff 75 0c             	pushl  0xc(%ebp)
  800afe:	e8 86 0e 00 00       	call   801989 <memmove>
	return r;
  800b03:	83 c4 10             	add    $0x10,%esp
}
  800b06:	89 d8                	mov    %ebx,%eax
  800b08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    
	assert(r <= n);
  800b0f:	68 a4 1f 80 00       	push   $0x801fa4
  800b14:	68 ab 1f 80 00       	push   $0x801fab
  800b19:	6a 7c                	push   $0x7c
  800b1b:	68 c0 1f 80 00       	push   $0x801fc0
  800b20:	e8 be 05 00 00       	call   8010e3 <_panic>
	assert(r <= PGSIZE);
  800b25:	68 cb 1f 80 00       	push   $0x801fcb
  800b2a:	68 ab 1f 80 00       	push   $0x801fab
  800b2f:	6a 7d                	push   $0x7d
  800b31:	68 c0 1f 80 00       	push   $0x801fc0
  800b36:	e8 a8 05 00 00       	call   8010e3 <_panic>

00800b3b <open>:
{
  800b3b:	f3 0f 1e fb          	endbr32 
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
  800b44:	83 ec 1c             	sub    $0x1c,%esp
  800b47:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b4a:	56                   	push   %esi
  800b4b:	e8 40 0c 00 00       	call   801790 <strlen>
  800b50:	83 c4 10             	add    $0x10,%esp
  800b53:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b58:	7f 6c                	jg     800bc6 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800b5a:	83 ec 0c             	sub    $0xc,%esp
  800b5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b60:	50                   	push   %eax
  800b61:	e8 67 f8 ff ff       	call   8003cd <fd_alloc>
  800b66:	89 c3                	mov    %eax,%ebx
  800b68:	83 c4 10             	add    $0x10,%esp
  800b6b:	85 c0                	test   %eax,%eax
  800b6d:	78 3c                	js     800bab <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b6f:	83 ec 08             	sub    $0x8,%esp
  800b72:	56                   	push   %esi
  800b73:	68 00 50 80 00       	push   $0x805000
  800b78:	e8 56 0c 00 00       	call   8017d3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b80:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b85:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b88:	b8 01 00 00 00       	mov    $0x1,%eax
  800b8d:	e8 db fd ff ff       	call   80096d <fsipc>
  800b92:	89 c3                	mov    %eax,%ebx
  800b94:	83 c4 10             	add    $0x10,%esp
  800b97:	85 c0                	test   %eax,%eax
  800b99:	78 19                	js     800bb4 <open+0x79>
	return fd2num(fd);
  800b9b:	83 ec 0c             	sub    $0xc,%esp
  800b9e:	ff 75 f4             	pushl  -0xc(%ebp)
  800ba1:	e8 f8 f7 ff ff       	call   80039e <fd2num>
  800ba6:	89 c3                	mov    %eax,%ebx
  800ba8:	83 c4 10             	add    $0x10,%esp
}
  800bab:	89 d8                	mov    %ebx,%eax
  800bad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    
		fd_close(fd, 0);
  800bb4:	83 ec 08             	sub    $0x8,%esp
  800bb7:	6a 00                	push   $0x0
  800bb9:	ff 75 f4             	pushl  -0xc(%ebp)
  800bbc:	e8 10 f9 ff ff       	call   8004d1 <fd_close>
		return r;
  800bc1:	83 c4 10             	add    $0x10,%esp
  800bc4:	eb e5                	jmp    800bab <open+0x70>
		return -E_BAD_PATH;
  800bc6:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800bcb:	eb de                	jmp    800bab <open+0x70>

00800bcd <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bcd:	f3 0f 1e fb          	endbr32 
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdc:	b8 08 00 00 00       	mov    $0x8,%eax
  800be1:	e8 87 fd ff ff       	call   80096d <fsipc>
}
  800be6:	c9                   	leave  
  800be7:	c3                   	ret    

00800be8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800be8:	f3 0f 1e fb          	endbr32 
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bf4:	83 ec 0c             	sub    $0xc,%esp
  800bf7:	ff 75 08             	pushl  0x8(%ebp)
  800bfa:	e8 b3 f7 ff ff       	call   8003b2 <fd2data>
  800bff:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800c01:	83 c4 08             	add    $0x8,%esp
  800c04:	68 d7 1f 80 00       	push   $0x801fd7
  800c09:	53                   	push   %ebx
  800c0a:	e8 c4 0b 00 00       	call   8017d3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800c0f:	8b 46 04             	mov    0x4(%esi),%eax
  800c12:	2b 06                	sub    (%esi),%eax
  800c14:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800c1a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c21:	00 00 00 
	stat->st_dev = &devpipe;
  800c24:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c2b:	30 80 00 
	return 0;
}
  800c2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c3a:	f3 0f 1e fb          	endbr32 
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	53                   	push   %ebx
  800c42:	83 ec 0c             	sub    $0xc,%esp
  800c45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c48:	53                   	push   %ebx
  800c49:	6a 00                	push   $0x0
  800c4b:	e8 ca f5 ff ff       	call   80021a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c50:	89 1c 24             	mov    %ebx,(%esp)
  800c53:	e8 5a f7 ff ff       	call   8003b2 <fd2data>
  800c58:	83 c4 08             	add    $0x8,%esp
  800c5b:	50                   	push   %eax
  800c5c:	6a 00                	push   $0x0
  800c5e:	e8 b7 f5 ff ff       	call   80021a <sys_page_unmap>
}
  800c63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c66:	c9                   	leave  
  800c67:	c3                   	ret    

00800c68 <_pipeisclosed>:
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
  800c6e:	83 ec 1c             	sub    $0x1c,%esp
  800c71:	89 c7                	mov    %eax,%edi
  800c73:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c75:	a1 04 40 80 00       	mov    0x804004,%eax
  800c7a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c7d:	83 ec 0c             	sub    $0xc,%esp
  800c80:	57                   	push   %edi
  800c81:	e8 b9 0f 00 00       	call   801c3f <pageref>
  800c86:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c89:	89 34 24             	mov    %esi,(%esp)
  800c8c:	e8 ae 0f 00 00       	call   801c3f <pageref>
		nn = thisenv->env_runs;
  800c91:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c97:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c9a:	83 c4 10             	add    $0x10,%esp
  800c9d:	39 cb                	cmp    %ecx,%ebx
  800c9f:	74 1b                	je     800cbc <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800ca1:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800ca4:	75 cf                	jne    800c75 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800ca6:	8b 42 58             	mov    0x58(%edx),%eax
  800ca9:	6a 01                	push   $0x1
  800cab:	50                   	push   %eax
  800cac:	53                   	push   %ebx
  800cad:	68 de 1f 80 00       	push   $0x801fde
  800cb2:	e8 13 05 00 00       	call   8011ca <cprintf>
  800cb7:	83 c4 10             	add    $0x10,%esp
  800cba:	eb b9                	jmp    800c75 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800cbc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800cbf:	0f 94 c0             	sete   %al
  800cc2:	0f b6 c0             	movzbl %al,%eax
}
  800cc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <devpipe_write>:
{
  800ccd:	f3 0f 1e fb          	endbr32 
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 28             	sub    $0x28,%esp
  800cda:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800cdd:	56                   	push   %esi
  800cde:	e8 cf f6 ff ff       	call   8003b2 <fd2data>
  800ce3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800ce5:	83 c4 10             	add    $0x10,%esp
  800ce8:	bf 00 00 00 00       	mov    $0x0,%edi
  800ced:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cf0:	74 4f                	je     800d41 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cf2:	8b 43 04             	mov    0x4(%ebx),%eax
  800cf5:	8b 0b                	mov    (%ebx),%ecx
  800cf7:	8d 51 20             	lea    0x20(%ecx),%edx
  800cfa:	39 d0                	cmp    %edx,%eax
  800cfc:	72 14                	jb     800d12 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800cfe:	89 da                	mov    %ebx,%edx
  800d00:	89 f0                	mov    %esi,%eax
  800d02:	e8 61 ff ff ff       	call   800c68 <_pipeisclosed>
  800d07:	85 c0                	test   %eax,%eax
  800d09:	75 3b                	jne    800d46 <devpipe_write+0x79>
			sys_yield();
  800d0b:	e8 5a f4 ff ff       	call   80016a <sys_yield>
  800d10:	eb e0                	jmp    800cf2 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d15:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d19:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d1c:	89 c2                	mov    %eax,%edx
  800d1e:	c1 fa 1f             	sar    $0x1f,%edx
  800d21:	89 d1                	mov    %edx,%ecx
  800d23:	c1 e9 1b             	shr    $0x1b,%ecx
  800d26:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800d29:	83 e2 1f             	and    $0x1f,%edx
  800d2c:	29 ca                	sub    %ecx,%edx
  800d2e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800d32:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d36:	83 c0 01             	add    $0x1,%eax
  800d39:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800d3c:	83 c7 01             	add    $0x1,%edi
  800d3f:	eb ac                	jmp    800ced <devpipe_write+0x20>
	return i;
  800d41:	8b 45 10             	mov    0x10(%ebp),%eax
  800d44:	eb 05                	jmp    800d4b <devpipe_write+0x7e>
				return 0;
  800d46:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <devpipe_read>:
{
  800d53:	f3 0f 1e fb          	endbr32 
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	57                   	push   %edi
  800d5b:	56                   	push   %esi
  800d5c:	53                   	push   %ebx
  800d5d:	83 ec 18             	sub    $0x18,%esp
  800d60:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800d63:	57                   	push   %edi
  800d64:	e8 49 f6 ff ff       	call   8003b2 <fd2data>
  800d69:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d6b:	83 c4 10             	add    $0x10,%esp
  800d6e:	be 00 00 00 00       	mov    $0x0,%esi
  800d73:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d76:	75 14                	jne    800d8c <devpipe_read+0x39>
	return i;
  800d78:	8b 45 10             	mov    0x10(%ebp),%eax
  800d7b:	eb 02                	jmp    800d7f <devpipe_read+0x2c>
				return i;
  800d7d:	89 f0                	mov    %esi,%eax
}
  800d7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	5f                   	pop    %edi
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    
			sys_yield();
  800d87:	e8 de f3 ff ff       	call   80016a <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d8c:	8b 03                	mov    (%ebx),%eax
  800d8e:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d91:	75 18                	jne    800dab <devpipe_read+0x58>
			if (i > 0)
  800d93:	85 f6                	test   %esi,%esi
  800d95:	75 e6                	jne    800d7d <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d97:	89 da                	mov    %ebx,%edx
  800d99:	89 f8                	mov    %edi,%eax
  800d9b:	e8 c8 fe ff ff       	call   800c68 <_pipeisclosed>
  800da0:	85 c0                	test   %eax,%eax
  800da2:	74 e3                	je     800d87 <devpipe_read+0x34>
				return 0;
  800da4:	b8 00 00 00 00       	mov    $0x0,%eax
  800da9:	eb d4                	jmp    800d7f <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800dab:	99                   	cltd   
  800dac:	c1 ea 1b             	shr    $0x1b,%edx
  800daf:	01 d0                	add    %edx,%eax
  800db1:	83 e0 1f             	and    $0x1f,%eax
  800db4:	29 d0                	sub    %edx,%eax
  800db6:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbe:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800dc1:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800dc4:	83 c6 01             	add    $0x1,%esi
  800dc7:	eb aa                	jmp    800d73 <devpipe_read+0x20>

00800dc9 <pipe>:
{
  800dc9:	f3 0f 1e fb          	endbr32 
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
  800dd2:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800dd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dd8:	50                   	push   %eax
  800dd9:	e8 ef f5 ff ff       	call   8003cd <fd_alloc>
  800dde:	89 c3                	mov    %eax,%ebx
  800de0:	83 c4 10             	add    $0x10,%esp
  800de3:	85 c0                	test   %eax,%eax
  800de5:	0f 88 23 01 00 00    	js     800f0e <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800deb:	83 ec 04             	sub    $0x4,%esp
  800dee:	68 07 04 00 00       	push   $0x407
  800df3:	ff 75 f4             	pushl  -0xc(%ebp)
  800df6:	6a 00                	push   $0x0
  800df8:	e8 90 f3 ff ff       	call   80018d <sys_page_alloc>
  800dfd:	89 c3                	mov    %eax,%ebx
  800dff:	83 c4 10             	add    $0x10,%esp
  800e02:	85 c0                	test   %eax,%eax
  800e04:	0f 88 04 01 00 00    	js     800f0e <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800e0a:	83 ec 0c             	sub    $0xc,%esp
  800e0d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e10:	50                   	push   %eax
  800e11:	e8 b7 f5 ff ff       	call   8003cd <fd_alloc>
  800e16:	89 c3                	mov    %eax,%ebx
  800e18:	83 c4 10             	add    $0x10,%esp
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	0f 88 db 00 00 00    	js     800efe <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e23:	83 ec 04             	sub    $0x4,%esp
  800e26:	68 07 04 00 00       	push   $0x407
  800e2b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e2e:	6a 00                	push   $0x0
  800e30:	e8 58 f3 ff ff       	call   80018d <sys_page_alloc>
  800e35:	89 c3                	mov    %eax,%ebx
  800e37:	83 c4 10             	add    $0x10,%esp
  800e3a:	85 c0                	test   %eax,%eax
  800e3c:	0f 88 bc 00 00 00    	js     800efe <pipe+0x135>
	va = fd2data(fd0);
  800e42:	83 ec 0c             	sub    $0xc,%esp
  800e45:	ff 75 f4             	pushl  -0xc(%ebp)
  800e48:	e8 65 f5 ff ff       	call   8003b2 <fd2data>
  800e4d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e4f:	83 c4 0c             	add    $0xc,%esp
  800e52:	68 07 04 00 00       	push   $0x407
  800e57:	50                   	push   %eax
  800e58:	6a 00                	push   $0x0
  800e5a:	e8 2e f3 ff ff       	call   80018d <sys_page_alloc>
  800e5f:	89 c3                	mov    %eax,%ebx
  800e61:	83 c4 10             	add    $0x10,%esp
  800e64:	85 c0                	test   %eax,%eax
  800e66:	0f 88 82 00 00 00    	js     800eee <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e6c:	83 ec 0c             	sub    $0xc,%esp
  800e6f:	ff 75 f0             	pushl  -0x10(%ebp)
  800e72:	e8 3b f5 ff ff       	call   8003b2 <fd2data>
  800e77:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e7e:	50                   	push   %eax
  800e7f:	6a 00                	push   $0x0
  800e81:	56                   	push   %esi
  800e82:	6a 00                	push   $0x0
  800e84:	e8 4b f3 ff ff       	call   8001d4 <sys_page_map>
  800e89:	89 c3                	mov    %eax,%ebx
  800e8b:	83 c4 20             	add    $0x20,%esp
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	78 4e                	js     800ee0 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e92:	a1 20 30 80 00       	mov    0x803020,%eax
  800e97:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e9a:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e9f:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800ea6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ea9:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800eab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eae:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800eb5:	83 ec 0c             	sub    $0xc,%esp
  800eb8:	ff 75 f4             	pushl  -0xc(%ebp)
  800ebb:	e8 de f4 ff ff       	call   80039e <fd2num>
  800ec0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800ec5:	83 c4 04             	add    $0x4,%esp
  800ec8:	ff 75 f0             	pushl  -0x10(%ebp)
  800ecb:	e8 ce f4 ff ff       	call   80039e <fd2num>
  800ed0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800ed6:	83 c4 10             	add    $0x10,%esp
  800ed9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ede:	eb 2e                	jmp    800f0e <pipe+0x145>
	sys_page_unmap(0, va);
  800ee0:	83 ec 08             	sub    $0x8,%esp
  800ee3:	56                   	push   %esi
  800ee4:	6a 00                	push   $0x0
  800ee6:	e8 2f f3 ff ff       	call   80021a <sys_page_unmap>
  800eeb:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800eee:	83 ec 08             	sub    $0x8,%esp
  800ef1:	ff 75 f0             	pushl  -0x10(%ebp)
  800ef4:	6a 00                	push   $0x0
  800ef6:	e8 1f f3 ff ff       	call   80021a <sys_page_unmap>
  800efb:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800efe:	83 ec 08             	sub    $0x8,%esp
  800f01:	ff 75 f4             	pushl  -0xc(%ebp)
  800f04:	6a 00                	push   $0x0
  800f06:	e8 0f f3 ff ff       	call   80021a <sys_page_unmap>
  800f0b:	83 c4 10             	add    $0x10,%esp
}
  800f0e:	89 d8                	mov    %ebx,%eax
  800f10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f13:	5b                   	pop    %ebx
  800f14:	5e                   	pop    %esi
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    

00800f17 <pipeisclosed>:
{
  800f17:	f3 0f 1e fb          	endbr32 
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f24:	50                   	push   %eax
  800f25:	ff 75 08             	pushl  0x8(%ebp)
  800f28:	e8 f6 f4 ff ff       	call   800423 <fd_lookup>
  800f2d:	83 c4 10             	add    $0x10,%esp
  800f30:	85 c0                	test   %eax,%eax
  800f32:	78 18                	js     800f4c <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800f34:	83 ec 0c             	sub    $0xc,%esp
  800f37:	ff 75 f4             	pushl  -0xc(%ebp)
  800f3a:	e8 73 f4 ff ff       	call   8003b2 <fd2data>
  800f3f:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f44:	e8 1f fd ff ff       	call   800c68 <_pipeisclosed>
  800f49:	83 c4 10             	add    $0x10,%esp
}
  800f4c:	c9                   	leave  
  800f4d:	c3                   	ret    

00800f4e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f4e:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800f52:	b8 00 00 00 00       	mov    $0x0,%eax
  800f57:	c3                   	ret    

00800f58 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f58:	f3 0f 1e fb          	endbr32 
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f62:	68 f6 1f 80 00       	push   $0x801ff6
  800f67:	ff 75 0c             	pushl  0xc(%ebp)
  800f6a:	e8 64 08 00 00       	call   8017d3 <strcpy>
	return 0;
}
  800f6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f74:	c9                   	leave  
  800f75:	c3                   	ret    

00800f76 <devcons_write>:
{
  800f76:	f3 0f 1e fb          	endbr32 
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	57                   	push   %edi
  800f7e:	56                   	push   %esi
  800f7f:	53                   	push   %ebx
  800f80:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f86:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f8b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f91:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f94:	73 31                	jae    800fc7 <devcons_write+0x51>
		m = n - tot;
  800f96:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f99:	29 f3                	sub    %esi,%ebx
  800f9b:	83 fb 7f             	cmp    $0x7f,%ebx
  800f9e:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800fa3:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800fa6:	83 ec 04             	sub    $0x4,%esp
  800fa9:	53                   	push   %ebx
  800faa:	89 f0                	mov    %esi,%eax
  800fac:	03 45 0c             	add    0xc(%ebp),%eax
  800faf:	50                   	push   %eax
  800fb0:	57                   	push   %edi
  800fb1:	e8 d3 09 00 00       	call   801989 <memmove>
		sys_cputs(buf, m);
  800fb6:	83 c4 08             	add    $0x8,%esp
  800fb9:	53                   	push   %ebx
  800fba:	57                   	push   %edi
  800fbb:	e8 fd f0 ff ff       	call   8000bd <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800fc0:	01 de                	add    %ebx,%esi
  800fc2:	83 c4 10             	add    $0x10,%esp
  800fc5:	eb ca                	jmp    800f91 <devcons_write+0x1b>
}
  800fc7:	89 f0                	mov    %esi,%eax
  800fc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fcc:	5b                   	pop    %ebx
  800fcd:	5e                   	pop    %esi
  800fce:	5f                   	pop    %edi
  800fcf:	5d                   	pop    %ebp
  800fd0:	c3                   	ret    

00800fd1 <devcons_read>:
{
  800fd1:	f3 0f 1e fb          	endbr32 
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	83 ec 08             	sub    $0x8,%esp
  800fdb:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800fe0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fe4:	74 21                	je     801007 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800fe6:	e8 f4 f0 ff ff       	call   8000df <sys_cgetc>
  800feb:	85 c0                	test   %eax,%eax
  800fed:	75 07                	jne    800ff6 <devcons_read+0x25>
		sys_yield();
  800fef:	e8 76 f1 ff ff       	call   80016a <sys_yield>
  800ff4:	eb f0                	jmp    800fe6 <devcons_read+0x15>
	if (c < 0)
  800ff6:	78 0f                	js     801007 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800ff8:	83 f8 04             	cmp    $0x4,%eax
  800ffb:	74 0c                	je     801009 <devcons_read+0x38>
	*(char*)vbuf = c;
  800ffd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801000:	88 02                	mov    %al,(%edx)
	return 1;
  801002:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801007:	c9                   	leave  
  801008:	c3                   	ret    
		return 0;
  801009:	b8 00 00 00 00       	mov    $0x0,%eax
  80100e:	eb f7                	jmp    801007 <devcons_read+0x36>

00801010 <cputchar>:
{
  801010:	f3 0f 1e fb          	endbr32 
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80101a:	8b 45 08             	mov    0x8(%ebp),%eax
  80101d:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801020:	6a 01                	push   $0x1
  801022:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801025:	50                   	push   %eax
  801026:	e8 92 f0 ff ff       	call   8000bd <sys_cputs>
}
  80102b:	83 c4 10             	add    $0x10,%esp
  80102e:	c9                   	leave  
  80102f:	c3                   	ret    

00801030 <getchar>:
{
  801030:	f3 0f 1e fb          	endbr32 
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80103a:	6a 01                	push   $0x1
  80103c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80103f:	50                   	push   %eax
  801040:	6a 00                	push   $0x0
  801042:	e8 5f f6 ff ff       	call   8006a6 <read>
	if (r < 0)
  801047:	83 c4 10             	add    $0x10,%esp
  80104a:	85 c0                	test   %eax,%eax
  80104c:	78 06                	js     801054 <getchar+0x24>
	if (r < 1)
  80104e:	74 06                	je     801056 <getchar+0x26>
	return c;
  801050:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801054:	c9                   	leave  
  801055:	c3                   	ret    
		return -E_EOF;
  801056:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80105b:	eb f7                	jmp    801054 <getchar+0x24>

0080105d <iscons>:
{
  80105d:	f3 0f 1e fb          	endbr32 
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801067:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80106a:	50                   	push   %eax
  80106b:	ff 75 08             	pushl  0x8(%ebp)
  80106e:	e8 b0 f3 ff ff       	call   800423 <fd_lookup>
  801073:	83 c4 10             	add    $0x10,%esp
  801076:	85 c0                	test   %eax,%eax
  801078:	78 11                	js     80108b <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80107a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80107d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801083:	39 10                	cmp    %edx,(%eax)
  801085:	0f 94 c0             	sete   %al
  801088:	0f b6 c0             	movzbl %al,%eax
}
  80108b:	c9                   	leave  
  80108c:	c3                   	ret    

0080108d <opencons>:
{
  80108d:	f3 0f 1e fb          	endbr32 
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801097:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80109a:	50                   	push   %eax
  80109b:	e8 2d f3 ff ff       	call   8003cd <fd_alloc>
  8010a0:	83 c4 10             	add    $0x10,%esp
  8010a3:	85 c0                	test   %eax,%eax
  8010a5:	78 3a                	js     8010e1 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8010a7:	83 ec 04             	sub    $0x4,%esp
  8010aa:	68 07 04 00 00       	push   $0x407
  8010af:	ff 75 f4             	pushl  -0xc(%ebp)
  8010b2:	6a 00                	push   $0x0
  8010b4:	e8 d4 f0 ff ff       	call   80018d <sys_page_alloc>
  8010b9:	83 c4 10             	add    $0x10,%esp
  8010bc:	85 c0                	test   %eax,%eax
  8010be:	78 21                	js     8010e1 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8010c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8010c9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8010cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ce:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8010d5:	83 ec 0c             	sub    $0xc,%esp
  8010d8:	50                   	push   %eax
  8010d9:	e8 c0 f2 ff ff       	call   80039e <fd2num>
  8010de:	83 c4 10             	add    $0x10,%esp
}
  8010e1:	c9                   	leave  
  8010e2:	c3                   	ret    

008010e3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010e3:	f3 0f 1e fb          	endbr32 
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	56                   	push   %esi
  8010eb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010ec:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010ef:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010f5:	e8 4d f0 ff ff       	call   800147 <sys_getenvid>
  8010fa:	83 ec 0c             	sub    $0xc,%esp
  8010fd:	ff 75 0c             	pushl  0xc(%ebp)
  801100:	ff 75 08             	pushl  0x8(%ebp)
  801103:	56                   	push   %esi
  801104:	50                   	push   %eax
  801105:	68 04 20 80 00       	push   $0x802004
  80110a:	e8 bb 00 00 00       	call   8011ca <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80110f:	83 c4 18             	add    $0x18,%esp
  801112:	53                   	push   %ebx
  801113:	ff 75 10             	pushl  0x10(%ebp)
  801116:	e8 5a 00 00 00       	call   801175 <vcprintf>
	cprintf("\n");
  80111b:	c7 04 24 ef 1f 80 00 	movl   $0x801fef,(%esp)
  801122:	e8 a3 00 00 00       	call   8011ca <cprintf>
  801127:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80112a:	cc                   	int3   
  80112b:	eb fd                	jmp    80112a <_panic+0x47>

0080112d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80112d:	f3 0f 1e fb          	endbr32 
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	53                   	push   %ebx
  801135:	83 ec 04             	sub    $0x4,%esp
  801138:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80113b:	8b 13                	mov    (%ebx),%edx
  80113d:	8d 42 01             	lea    0x1(%edx),%eax
  801140:	89 03                	mov    %eax,(%ebx)
  801142:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801145:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801149:	3d ff 00 00 00       	cmp    $0xff,%eax
  80114e:	74 09                	je     801159 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801150:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801154:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801157:	c9                   	leave  
  801158:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801159:	83 ec 08             	sub    $0x8,%esp
  80115c:	68 ff 00 00 00       	push   $0xff
  801161:	8d 43 08             	lea    0x8(%ebx),%eax
  801164:	50                   	push   %eax
  801165:	e8 53 ef ff ff       	call   8000bd <sys_cputs>
		b->idx = 0;
  80116a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801170:	83 c4 10             	add    $0x10,%esp
  801173:	eb db                	jmp    801150 <putch+0x23>

00801175 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801175:	f3 0f 1e fb          	endbr32 
  801179:	55                   	push   %ebp
  80117a:	89 e5                	mov    %esp,%ebp
  80117c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801182:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801189:	00 00 00 
	b.cnt = 0;
  80118c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801193:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801196:	ff 75 0c             	pushl  0xc(%ebp)
  801199:	ff 75 08             	pushl  0x8(%ebp)
  80119c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8011a2:	50                   	push   %eax
  8011a3:	68 2d 11 80 00       	push   $0x80112d
  8011a8:	e8 20 01 00 00       	call   8012cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8011ad:	83 c4 08             	add    $0x8,%esp
  8011b0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8011b6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8011bc:	50                   	push   %eax
  8011bd:	e8 fb ee ff ff       	call   8000bd <sys_cputs>

	return b.cnt;
}
  8011c2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8011c8:	c9                   	leave  
  8011c9:	c3                   	ret    

008011ca <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8011ca:	f3 0f 1e fb          	endbr32 
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8011d4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8011d7:	50                   	push   %eax
  8011d8:	ff 75 08             	pushl  0x8(%ebp)
  8011db:	e8 95 ff ff ff       	call   801175 <vcprintf>
	va_end(ap);

	return cnt;
}
  8011e0:	c9                   	leave  
  8011e1:	c3                   	ret    

008011e2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	57                   	push   %edi
  8011e6:	56                   	push   %esi
  8011e7:	53                   	push   %ebx
  8011e8:	83 ec 1c             	sub    $0x1c,%esp
  8011eb:	89 c7                	mov    %eax,%edi
  8011ed:	89 d6                	mov    %edx,%esi
  8011ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011f5:	89 d1                	mov    %edx,%ecx
  8011f7:	89 c2                	mov    %eax,%edx
  8011f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011fc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8011ff:	8b 45 10             	mov    0x10(%ebp),%eax
  801202:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801205:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801208:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80120f:	39 c2                	cmp    %eax,%edx
  801211:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801214:	72 3e                	jb     801254 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801216:	83 ec 0c             	sub    $0xc,%esp
  801219:	ff 75 18             	pushl  0x18(%ebp)
  80121c:	83 eb 01             	sub    $0x1,%ebx
  80121f:	53                   	push   %ebx
  801220:	50                   	push   %eax
  801221:	83 ec 08             	sub    $0x8,%esp
  801224:	ff 75 e4             	pushl  -0x1c(%ebp)
  801227:	ff 75 e0             	pushl  -0x20(%ebp)
  80122a:	ff 75 dc             	pushl  -0x24(%ebp)
  80122d:	ff 75 d8             	pushl  -0x28(%ebp)
  801230:	e8 4b 0a 00 00       	call   801c80 <__udivdi3>
  801235:	83 c4 18             	add    $0x18,%esp
  801238:	52                   	push   %edx
  801239:	50                   	push   %eax
  80123a:	89 f2                	mov    %esi,%edx
  80123c:	89 f8                	mov    %edi,%eax
  80123e:	e8 9f ff ff ff       	call   8011e2 <printnum>
  801243:	83 c4 20             	add    $0x20,%esp
  801246:	eb 13                	jmp    80125b <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801248:	83 ec 08             	sub    $0x8,%esp
  80124b:	56                   	push   %esi
  80124c:	ff 75 18             	pushl  0x18(%ebp)
  80124f:	ff d7                	call   *%edi
  801251:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801254:	83 eb 01             	sub    $0x1,%ebx
  801257:	85 db                	test   %ebx,%ebx
  801259:	7f ed                	jg     801248 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80125b:	83 ec 08             	sub    $0x8,%esp
  80125e:	56                   	push   %esi
  80125f:	83 ec 04             	sub    $0x4,%esp
  801262:	ff 75 e4             	pushl  -0x1c(%ebp)
  801265:	ff 75 e0             	pushl  -0x20(%ebp)
  801268:	ff 75 dc             	pushl  -0x24(%ebp)
  80126b:	ff 75 d8             	pushl  -0x28(%ebp)
  80126e:	e8 1d 0b 00 00       	call   801d90 <__umoddi3>
  801273:	83 c4 14             	add    $0x14,%esp
  801276:	0f be 80 27 20 80 00 	movsbl 0x802027(%eax),%eax
  80127d:	50                   	push   %eax
  80127e:	ff d7                	call   *%edi
}
  801280:	83 c4 10             	add    $0x10,%esp
  801283:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801286:	5b                   	pop    %ebx
  801287:	5e                   	pop    %esi
  801288:	5f                   	pop    %edi
  801289:	5d                   	pop    %ebp
  80128a:	c3                   	ret    

0080128b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80128b:	f3 0f 1e fb          	endbr32 
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801295:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801299:	8b 10                	mov    (%eax),%edx
  80129b:	3b 50 04             	cmp    0x4(%eax),%edx
  80129e:	73 0a                	jae    8012aa <sprintputch+0x1f>
		*b->buf++ = ch;
  8012a0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8012a3:	89 08                	mov    %ecx,(%eax)
  8012a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a8:	88 02                	mov    %al,(%edx)
}
  8012aa:	5d                   	pop    %ebp
  8012ab:	c3                   	ret    

008012ac <printfmt>:
{
  8012ac:	f3 0f 1e fb          	endbr32 
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8012b6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012b9:	50                   	push   %eax
  8012ba:	ff 75 10             	pushl  0x10(%ebp)
  8012bd:	ff 75 0c             	pushl  0xc(%ebp)
  8012c0:	ff 75 08             	pushl  0x8(%ebp)
  8012c3:	e8 05 00 00 00       	call   8012cd <vprintfmt>
}
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	c9                   	leave  
  8012cc:	c3                   	ret    

008012cd <vprintfmt>:
{
  8012cd:	f3 0f 1e fb          	endbr32 
  8012d1:	55                   	push   %ebp
  8012d2:	89 e5                	mov    %esp,%ebp
  8012d4:	57                   	push   %edi
  8012d5:	56                   	push   %esi
  8012d6:	53                   	push   %ebx
  8012d7:	83 ec 3c             	sub    $0x3c,%esp
  8012da:	8b 75 08             	mov    0x8(%ebp),%esi
  8012dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012e0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012e3:	e9 4a 03 00 00       	jmp    801632 <vprintfmt+0x365>
		padc = ' ';
  8012e8:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012ec:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012f3:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012fa:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801301:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801306:	8d 47 01             	lea    0x1(%edi),%eax
  801309:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80130c:	0f b6 17             	movzbl (%edi),%edx
  80130f:	8d 42 dd             	lea    -0x23(%edx),%eax
  801312:	3c 55                	cmp    $0x55,%al
  801314:	0f 87 de 03 00 00    	ja     8016f8 <vprintfmt+0x42b>
  80131a:	0f b6 c0             	movzbl %al,%eax
  80131d:	3e ff 24 85 60 21 80 	notrack jmp *0x802160(,%eax,4)
  801324:	00 
  801325:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801328:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80132c:	eb d8                	jmp    801306 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80132e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801331:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801335:	eb cf                	jmp    801306 <vprintfmt+0x39>
  801337:	0f b6 d2             	movzbl %dl,%edx
  80133a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80133d:	b8 00 00 00 00       	mov    $0x0,%eax
  801342:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801345:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801348:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80134c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80134f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801352:	83 f9 09             	cmp    $0x9,%ecx
  801355:	77 55                	ja     8013ac <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  801357:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80135a:	eb e9                	jmp    801345 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80135c:	8b 45 14             	mov    0x14(%ebp),%eax
  80135f:	8b 00                	mov    (%eax),%eax
  801361:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801364:	8b 45 14             	mov    0x14(%ebp),%eax
  801367:	8d 40 04             	lea    0x4(%eax),%eax
  80136a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80136d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801370:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801374:	79 90                	jns    801306 <vprintfmt+0x39>
				width = precision, precision = -1;
  801376:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801379:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80137c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801383:	eb 81                	jmp    801306 <vprintfmt+0x39>
  801385:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801388:	85 c0                	test   %eax,%eax
  80138a:	ba 00 00 00 00       	mov    $0x0,%edx
  80138f:	0f 49 d0             	cmovns %eax,%edx
  801392:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801398:	e9 69 ff ff ff       	jmp    801306 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80139d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8013a0:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8013a7:	e9 5a ff ff ff       	jmp    801306 <vprintfmt+0x39>
  8013ac:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8013af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8013b2:	eb bc                	jmp    801370 <vprintfmt+0xa3>
			lflag++;
  8013b4:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8013b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8013ba:	e9 47 ff ff ff       	jmp    801306 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8013bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c2:	8d 78 04             	lea    0x4(%eax),%edi
  8013c5:	83 ec 08             	sub    $0x8,%esp
  8013c8:	53                   	push   %ebx
  8013c9:	ff 30                	pushl  (%eax)
  8013cb:	ff d6                	call   *%esi
			break;
  8013cd:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8013d0:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8013d3:	e9 57 02 00 00       	jmp    80162f <vprintfmt+0x362>
			err = va_arg(ap, int);
  8013d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8013db:	8d 78 04             	lea    0x4(%eax),%edi
  8013de:	8b 00                	mov    (%eax),%eax
  8013e0:	99                   	cltd   
  8013e1:	31 d0                	xor    %edx,%eax
  8013e3:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013e5:	83 f8 0f             	cmp    $0xf,%eax
  8013e8:	7f 23                	jg     80140d <vprintfmt+0x140>
  8013ea:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  8013f1:	85 d2                	test   %edx,%edx
  8013f3:	74 18                	je     80140d <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8013f5:	52                   	push   %edx
  8013f6:	68 bd 1f 80 00       	push   $0x801fbd
  8013fb:	53                   	push   %ebx
  8013fc:	56                   	push   %esi
  8013fd:	e8 aa fe ff ff       	call   8012ac <printfmt>
  801402:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801405:	89 7d 14             	mov    %edi,0x14(%ebp)
  801408:	e9 22 02 00 00       	jmp    80162f <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  80140d:	50                   	push   %eax
  80140e:	68 3f 20 80 00       	push   $0x80203f
  801413:	53                   	push   %ebx
  801414:	56                   	push   %esi
  801415:	e8 92 fe ff ff       	call   8012ac <printfmt>
  80141a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80141d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801420:	e9 0a 02 00 00       	jmp    80162f <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  801425:	8b 45 14             	mov    0x14(%ebp),%eax
  801428:	83 c0 04             	add    $0x4,%eax
  80142b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80142e:	8b 45 14             	mov    0x14(%ebp),%eax
  801431:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801433:	85 d2                	test   %edx,%edx
  801435:	b8 38 20 80 00       	mov    $0x802038,%eax
  80143a:	0f 45 c2             	cmovne %edx,%eax
  80143d:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801440:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801444:	7e 06                	jle    80144c <vprintfmt+0x17f>
  801446:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80144a:	75 0d                	jne    801459 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80144c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80144f:	89 c7                	mov    %eax,%edi
  801451:	03 45 e0             	add    -0x20(%ebp),%eax
  801454:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801457:	eb 55                	jmp    8014ae <vprintfmt+0x1e1>
  801459:	83 ec 08             	sub    $0x8,%esp
  80145c:	ff 75 d8             	pushl  -0x28(%ebp)
  80145f:	ff 75 cc             	pushl  -0x34(%ebp)
  801462:	e8 45 03 00 00       	call   8017ac <strnlen>
  801467:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80146a:	29 c2                	sub    %eax,%edx
  80146c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  801474:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801478:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80147b:	85 ff                	test   %edi,%edi
  80147d:	7e 11                	jle    801490 <vprintfmt+0x1c3>
					putch(padc, putdat);
  80147f:	83 ec 08             	sub    $0x8,%esp
  801482:	53                   	push   %ebx
  801483:	ff 75 e0             	pushl  -0x20(%ebp)
  801486:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801488:	83 ef 01             	sub    $0x1,%edi
  80148b:	83 c4 10             	add    $0x10,%esp
  80148e:	eb eb                	jmp    80147b <vprintfmt+0x1ae>
  801490:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801493:	85 d2                	test   %edx,%edx
  801495:	b8 00 00 00 00       	mov    $0x0,%eax
  80149a:	0f 49 c2             	cmovns %edx,%eax
  80149d:	29 c2                	sub    %eax,%edx
  80149f:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8014a2:	eb a8                	jmp    80144c <vprintfmt+0x17f>
					putch(ch, putdat);
  8014a4:	83 ec 08             	sub    $0x8,%esp
  8014a7:	53                   	push   %ebx
  8014a8:	52                   	push   %edx
  8014a9:	ff d6                	call   *%esi
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014b1:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014b3:	83 c7 01             	add    $0x1,%edi
  8014b6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014ba:	0f be d0             	movsbl %al,%edx
  8014bd:	85 d2                	test   %edx,%edx
  8014bf:	74 4b                	je     80150c <vprintfmt+0x23f>
  8014c1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014c5:	78 06                	js     8014cd <vprintfmt+0x200>
  8014c7:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014cb:	78 1e                	js     8014eb <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8014cd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014d1:	74 d1                	je     8014a4 <vprintfmt+0x1d7>
  8014d3:	0f be c0             	movsbl %al,%eax
  8014d6:	83 e8 20             	sub    $0x20,%eax
  8014d9:	83 f8 5e             	cmp    $0x5e,%eax
  8014dc:	76 c6                	jbe    8014a4 <vprintfmt+0x1d7>
					putch('?', putdat);
  8014de:	83 ec 08             	sub    $0x8,%esp
  8014e1:	53                   	push   %ebx
  8014e2:	6a 3f                	push   $0x3f
  8014e4:	ff d6                	call   *%esi
  8014e6:	83 c4 10             	add    $0x10,%esp
  8014e9:	eb c3                	jmp    8014ae <vprintfmt+0x1e1>
  8014eb:	89 cf                	mov    %ecx,%edi
  8014ed:	eb 0e                	jmp    8014fd <vprintfmt+0x230>
				putch(' ', putdat);
  8014ef:	83 ec 08             	sub    $0x8,%esp
  8014f2:	53                   	push   %ebx
  8014f3:	6a 20                	push   $0x20
  8014f5:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8014f7:	83 ef 01             	sub    $0x1,%edi
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	85 ff                	test   %edi,%edi
  8014ff:	7f ee                	jg     8014ef <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  801501:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801504:	89 45 14             	mov    %eax,0x14(%ebp)
  801507:	e9 23 01 00 00       	jmp    80162f <vprintfmt+0x362>
  80150c:	89 cf                	mov    %ecx,%edi
  80150e:	eb ed                	jmp    8014fd <vprintfmt+0x230>
	if (lflag >= 2)
  801510:	83 f9 01             	cmp    $0x1,%ecx
  801513:	7f 1b                	jg     801530 <vprintfmt+0x263>
	else if (lflag)
  801515:	85 c9                	test   %ecx,%ecx
  801517:	74 63                	je     80157c <vprintfmt+0x2af>
		return va_arg(*ap, long);
  801519:	8b 45 14             	mov    0x14(%ebp),%eax
  80151c:	8b 00                	mov    (%eax),%eax
  80151e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801521:	99                   	cltd   
  801522:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801525:	8b 45 14             	mov    0x14(%ebp),%eax
  801528:	8d 40 04             	lea    0x4(%eax),%eax
  80152b:	89 45 14             	mov    %eax,0x14(%ebp)
  80152e:	eb 17                	jmp    801547 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  801530:	8b 45 14             	mov    0x14(%ebp),%eax
  801533:	8b 50 04             	mov    0x4(%eax),%edx
  801536:	8b 00                	mov    (%eax),%eax
  801538:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80153b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80153e:	8b 45 14             	mov    0x14(%ebp),%eax
  801541:	8d 40 08             	lea    0x8(%eax),%eax
  801544:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801547:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80154a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80154d:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  801552:	85 c9                	test   %ecx,%ecx
  801554:	0f 89 bb 00 00 00    	jns    801615 <vprintfmt+0x348>
				putch('-', putdat);
  80155a:	83 ec 08             	sub    $0x8,%esp
  80155d:	53                   	push   %ebx
  80155e:	6a 2d                	push   $0x2d
  801560:	ff d6                	call   *%esi
				num = -(long long) num;
  801562:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801565:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801568:	f7 da                	neg    %edx
  80156a:	83 d1 00             	adc    $0x0,%ecx
  80156d:	f7 d9                	neg    %ecx
  80156f:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801572:	b8 0a 00 00 00       	mov    $0xa,%eax
  801577:	e9 99 00 00 00       	jmp    801615 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80157c:	8b 45 14             	mov    0x14(%ebp),%eax
  80157f:	8b 00                	mov    (%eax),%eax
  801581:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801584:	99                   	cltd   
  801585:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801588:	8b 45 14             	mov    0x14(%ebp),%eax
  80158b:	8d 40 04             	lea    0x4(%eax),%eax
  80158e:	89 45 14             	mov    %eax,0x14(%ebp)
  801591:	eb b4                	jmp    801547 <vprintfmt+0x27a>
	if (lflag >= 2)
  801593:	83 f9 01             	cmp    $0x1,%ecx
  801596:	7f 1b                	jg     8015b3 <vprintfmt+0x2e6>
	else if (lflag)
  801598:	85 c9                	test   %ecx,%ecx
  80159a:	74 2c                	je     8015c8 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80159c:	8b 45 14             	mov    0x14(%ebp),%eax
  80159f:	8b 10                	mov    (%eax),%edx
  8015a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015a6:	8d 40 04             	lea    0x4(%eax),%eax
  8015a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015ac:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8015b1:	eb 62                	jmp    801615 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8015b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b6:	8b 10                	mov    (%eax),%edx
  8015b8:	8b 48 04             	mov    0x4(%eax),%ecx
  8015bb:	8d 40 08             	lea    0x8(%eax),%eax
  8015be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015c1:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8015c6:	eb 4d                	jmp    801615 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8015c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8015cb:	8b 10                	mov    (%eax),%edx
  8015cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015d2:	8d 40 04             	lea    0x4(%eax),%eax
  8015d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015d8:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8015dd:	eb 36                	jmp    801615 <vprintfmt+0x348>
	if (lflag >= 2)
  8015df:	83 f9 01             	cmp    $0x1,%ecx
  8015e2:	7f 17                	jg     8015fb <vprintfmt+0x32e>
	else if (lflag)
  8015e4:	85 c9                	test   %ecx,%ecx
  8015e6:	74 6e                	je     801656 <vprintfmt+0x389>
		return va_arg(*ap, long);
  8015e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8015eb:	8b 10                	mov    (%eax),%edx
  8015ed:	89 d0                	mov    %edx,%eax
  8015ef:	99                   	cltd   
  8015f0:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015f3:	8d 49 04             	lea    0x4(%ecx),%ecx
  8015f6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8015f9:	eb 11                	jmp    80160c <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8015fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8015fe:	8b 50 04             	mov    0x4(%eax),%edx
  801601:	8b 00                	mov    (%eax),%eax
  801603:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801606:	8d 49 08             	lea    0x8(%ecx),%ecx
  801609:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80160c:	89 d1                	mov    %edx,%ecx
  80160e:	89 c2                	mov    %eax,%edx
            base = 8;
  801610:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  801615:	83 ec 0c             	sub    $0xc,%esp
  801618:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80161c:	57                   	push   %edi
  80161d:	ff 75 e0             	pushl  -0x20(%ebp)
  801620:	50                   	push   %eax
  801621:	51                   	push   %ecx
  801622:	52                   	push   %edx
  801623:	89 da                	mov    %ebx,%edx
  801625:	89 f0                	mov    %esi,%eax
  801627:	e8 b6 fb ff ff       	call   8011e2 <printnum>
			break;
  80162c:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80162f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801632:	83 c7 01             	add    $0x1,%edi
  801635:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801639:	83 f8 25             	cmp    $0x25,%eax
  80163c:	0f 84 a6 fc ff ff    	je     8012e8 <vprintfmt+0x1b>
			if (ch == '\0')
  801642:	85 c0                	test   %eax,%eax
  801644:	0f 84 ce 00 00 00    	je     801718 <vprintfmt+0x44b>
			putch(ch, putdat);
  80164a:	83 ec 08             	sub    $0x8,%esp
  80164d:	53                   	push   %ebx
  80164e:	50                   	push   %eax
  80164f:	ff d6                	call   *%esi
  801651:	83 c4 10             	add    $0x10,%esp
  801654:	eb dc                	jmp    801632 <vprintfmt+0x365>
		return va_arg(*ap, int);
  801656:	8b 45 14             	mov    0x14(%ebp),%eax
  801659:	8b 10                	mov    (%eax),%edx
  80165b:	89 d0                	mov    %edx,%eax
  80165d:	99                   	cltd   
  80165e:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801661:	8d 49 04             	lea    0x4(%ecx),%ecx
  801664:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801667:	eb a3                	jmp    80160c <vprintfmt+0x33f>
			putch('0', putdat);
  801669:	83 ec 08             	sub    $0x8,%esp
  80166c:	53                   	push   %ebx
  80166d:	6a 30                	push   $0x30
  80166f:	ff d6                	call   *%esi
			putch('x', putdat);
  801671:	83 c4 08             	add    $0x8,%esp
  801674:	53                   	push   %ebx
  801675:	6a 78                	push   $0x78
  801677:	ff d6                	call   *%esi
			num = (unsigned long long)
  801679:	8b 45 14             	mov    0x14(%ebp),%eax
  80167c:	8b 10                	mov    (%eax),%edx
  80167e:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801683:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801686:	8d 40 04             	lea    0x4(%eax),%eax
  801689:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80168c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801691:	eb 82                	jmp    801615 <vprintfmt+0x348>
	if (lflag >= 2)
  801693:	83 f9 01             	cmp    $0x1,%ecx
  801696:	7f 1e                	jg     8016b6 <vprintfmt+0x3e9>
	else if (lflag)
  801698:	85 c9                	test   %ecx,%ecx
  80169a:	74 32                	je     8016ce <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80169c:	8b 45 14             	mov    0x14(%ebp),%eax
  80169f:	8b 10                	mov    (%eax),%edx
  8016a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016a6:	8d 40 04             	lea    0x4(%eax),%eax
  8016a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016ac:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8016b1:	e9 5f ff ff ff       	jmp    801615 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8016b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8016b9:	8b 10                	mov    (%eax),%edx
  8016bb:	8b 48 04             	mov    0x4(%eax),%ecx
  8016be:	8d 40 08             	lea    0x8(%eax),%eax
  8016c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016c4:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8016c9:	e9 47 ff ff ff       	jmp    801615 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8016ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8016d1:	8b 10                	mov    (%eax),%edx
  8016d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016d8:	8d 40 04             	lea    0x4(%eax),%eax
  8016db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016de:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8016e3:	e9 2d ff ff ff       	jmp    801615 <vprintfmt+0x348>
			putch(ch, putdat);
  8016e8:	83 ec 08             	sub    $0x8,%esp
  8016eb:	53                   	push   %ebx
  8016ec:	6a 25                	push   $0x25
  8016ee:	ff d6                	call   *%esi
			break;
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	e9 37 ff ff ff       	jmp    80162f <vprintfmt+0x362>
			putch('%', putdat);
  8016f8:	83 ec 08             	sub    $0x8,%esp
  8016fb:	53                   	push   %ebx
  8016fc:	6a 25                	push   $0x25
  8016fe:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	89 f8                	mov    %edi,%eax
  801705:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801709:	74 05                	je     801710 <vprintfmt+0x443>
  80170b:	83 e8 01             	sub    $0x1,%eax
  80170e:	eb f5                	jmp    801705 <vprintfmt+0x438>
  801710:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801713:	e9 17 ff ff ff       	jmp    80162f <vprintfmt+0x362>
}
  801718:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80171b:	5b                   	pop    %ebx
  80171c:	5e                   	pop    %esi
  80171d:	5f                   	pop    %edi
  80171e:	5d                   	pop    %ebp
  80171f:	c3                   	ret    

00801720 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801720:	f3 0f 1e fb          	endbr32 
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	83 ec 18             	sub    $0x18,%esp
  80172a:	8b 45 08             	mov    0x8(%ebp),%eax
  80172d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801730:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801733:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801737:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80173a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801741:	85 c0                	test   %eax,%eax
  801743:	74 26                	je     80176b <vsnprintf+0x4b>
  801745:	85 d2                	test   %edx,%edx
  801747:	7e 22                	jle    80176b <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801749:	ff 75 14             	pushl  0x14(%ebp)
  80174c:	ff 75 10             	pushl  0x10(%ebp)
  80174f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801752:	50                   	push   %eax
  801753:	68 8b 12 80 00       	push   $0x80128b
  801758:	e8 70 fb ff ff       	call   8012cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80175d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801760:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801763:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801766:	83 c4 10             	add    $0x10,%esp
}
  801769:	c9                   	leave  
  80176a:	c3                   	ret    
		return -E_INVAL;
  80176b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801770:	eb f7                	jmp    801769 <vsnprintf+0x49>

00801772 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801772:	f3 0f 1e fb          	endbr32 
  801776:	55                   	push   %ebp
  801777:	89 e5                	mov    %esp,%ebp
  801779:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80177c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80177f:	50                   	push   %eax
  801780:	ff 75 10             	pushl  0x10(%ebp)
  801783:	ff 75 0c             	pushl  0xc(%ebp)
  801786:	ff 75 08             	pushl  0x8(%ebp)
  801789:	e8 92 ff ff ff       	call   801720 <vsnprintf>
	va_end(ap);

	return rc;
}
  80178e:	c9                   	leave  
  80178f:	c3                   	ret    

00801790 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801790:	f3 0f 1e fb          	endbr32 
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80179a:	b8 00 00 00 00       	mov    $0x0,%eax
  80179f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8017a3:	74 05                	je     8017aa <strlen+0x1a>
		n++;
  8017a5:	83 c0 01             	add    $0x1,%eax
  8017a8:	eb f5                	jmp    80179f <strlen+0xf>
	return n;
}
  8017aa:	5d                   	pop    %ebp
  8017ab:	c3                   	ret    

008017ac <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8017ac:	f3 0f 1e fb          	endbr32 
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8017b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8017be:	39 d0                	cmp    %edx,%eax
  8017c0:	74 0d                	je     8017cf <strnlen+0x23>
  8017c2:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8017c6:	74 05                	je     8017cd <strnlen+0x21>
		n++;
  8017c8:	83 c0 01             	add    $0x1,%eax
  8017cb:	eb f1                	jmp    8017be <strnlen+0x12>
  8017cd:	89 c2                	mov    %eax,%edx
	return n;
}
  8017cf:	89 d0                	mov    %edx,%eax
  8017d1:	5d                   	pop    %ebp
  8017d2:	c3                   	ret    

008017d3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8017d3:	f3 0f 1e fb          	endbr32 
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	53                   	push   %ebx
  8017db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8017e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8017e6:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8017ea:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8017ed:	83 c0 01             	add    $0x1,%eax
  8017f0:	84 d2                	test   %dl,%dl
  8017f2:	75 f2                	jne    8017e6 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8017f4:	89 c8                	mov    %ecx,%eax
  8017f6:	5b                   	pop    %ebx
  8017f7:	5d                   	pop    %ebp
  8017f8:	c3                   	ret    

008017f9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017f9:	f3 0f 1e fb          	endbr32 
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	53                   	push   %ebx
  801801:	83 ec 10             	sub    $0x10,%esp
  801804:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801807:	53                   	push   %ebx
  801808:	e8 83 ff ff ff       	call   801790 <strlen>
  80180d:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801810:	ff 75 0c             	pushl  0xc(%ebp)
  801813:	01 d8                	add    %ebx,%eax
  801815:	50                   	push   %eax
  801816:	e8 b8 ff ff ff       	call   8017d3 <strcpy>
	return dst;
}
  80181b:	89 d8                	mov    %ebx,%eax
  80181d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801820:	c9                   	leave  
  801821:	c3                   	ret    

00801822 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801822:	f3 0f 1e fb          	endbr32 
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	56                   	push   %esi
  80182a:	53                   	push   %ebx
  80182b:	8b 75 08             	mov    0x8(%ebp),%esi
  80182e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801831:	89 f3                	mov    %esi,%ebx
  801833:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801836:	89 f0                	mov    %esi,%eax
  801838:	39 d8                	cmp    %ebx,%eax
  80183a:	74 11                	je     80184d <strncpy+0x2b>
		*dst++ = *src;
  80183c:	83 c0 01             	add    $0x1,%eax
  80183f:	0f b6 0a             	movzbl (%edx),%ecx
  801842:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801845:	80 f9 01             	cmp    $0x1,%cl
  801848:	83 da ff             	sbb    $0xffffffff,%edx
  80184b:	eb eb                	jmp    801838 <strncpy+0x16>
	}
	return ret;
}
  80184d:	89 f0                	mov    %esi,%eax
  80184f:	5b                   	pop    %ebx
  801850:	5e                   	pop    %esi
  801851:	5d                   	pop    %ebp
  801852:	c3                   	ret    

00801853 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801853:	f3 0f 1e fb          	endbr32 
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	56                   	push   %esi
  80185b:	53                   	push   %ebx
  80185c:	8b 75 08             	mov    0x8(%ebp),%esi
  80185f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801862:	8b 55 10             	mov    0x10(%ebp),%edx
  801865:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801867:	85 d2                	test   %edx,%edx
  801869:	74 21                	je     80188c <strlcpy+0x39>
  80186b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80186f:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801871:	39 c2                	cmp    %eax,%edx
  801873:	74 14                	je     801889 <strlcpy+0x36>
  801875:	0f b6 19             	movzbl (%ecx),%ebx
  801878:	84 db                	test   %bl,%bl
  80187a:	74 0b                	je     801887 <strlcpy+0x34>
			*dst++ = *src++;
  80187c:	83 c1 01             	add    $0x1,%ecx
  80187f:	83 c2 01             	add    $0x1,%edx
  801882:	88 5a ff             	mov    %bl,-0x1(%edx)
  801885:	eb ea                	jmp    801871 <strlcpy+0x1e>
  801887:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801889:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80188c:	29 f0                	sub    %esi,%eax
}
  80188e:	5b                   	pop    %ebx
  80188f:	5e                   	pop    %esi
  801890:	5d                   	pop    %ebp
  801891:	c3                   	ret    

00801892 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801892:	f3 0f 1e fb          	endbr32 
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80189c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80189f:	0f b6 01             	movzbl (%ecx),%eax
  8018a2:	84 c0                	test   %al,%al
  8018a4:	74 0c                	je     8018b2 <strcmp+0x20>
  8018a6:	3a 02                	cmp    (%edx),%al
  8018a8:	75 08                	jne    8018b2 <strcmp+0x20>
		p++, q++;
  8018aa:	83 c1 01             	add    $0x1,%ecx
  8018ad:	83 c2 01             	add    $0x1,%edx
  8018b0:	eb ed                	jmp    80189f <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8018b2:	0f b6 c0             	movzbl %al,%eax
  8018b5:	0f b6 12             	movzbl (%edx),%edx
  8018b8:	29 d0                	sub    %edx,%eax
}
  8018ba:	5d                   	pop    %ebp
  8018bb:	c3                   	ret    

008018bc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8018bc:	f3 0f 1e fb          	endbr32 
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	53                   	push   %ebx
  8018c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ca:	89 c3                	mov    %eax,%ebx
  8018cc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8018cf:	eb 06                	jmp    8018d7 <strncmp+0x1b>
		n--, p++, q++;
  8018d1:	83 c0 01             	add    $0x1,%eax
  8018d4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8018d7:	39 d8                	cmp    %ebx,%eax
  8018d9:	74 16                	je     8018f1 <strncmp+0x35>
  8018db:	0f b6 08             	movzbl (%eax),%ecx
  8018de:	84 c9                	test   %cl,%cl
  8018e0:	74 04                	je     8018e6 <strncmp+0x2a>
  8018e2:	3a 0a                	cmp    (%edx),%cl
  8018e4:	74 eb                	je     8018d1 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8018e6:	0f b6 00             	movzbl (%eax),%eax
  8018e9:	0f b6 12             	movzbl (%edx),%edx
  8018ec:	29 d0                	sub    %edx,%eax
}
  8018ee:	5b                   	pop    %ebx
  8018ef:	5d                   	pop    %ebp
  8018f0:	c3                   	ret    
		return 0;
  8018f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f6:	eb f6                	jmp    8018ee <strncmp+0x32>

008018f8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8018f8:	f3 0f 1e fb          	endbr32 
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801902:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801906:	0f b6 10             	movzbl (%eax),%edx
  801909:	84 d2                	test   %dl,%dl
  80190b:	74 09                	je     801916 <strchr+0x1e>
		if (*s == c)
  80190d:	38 ca                	cmp    %cl,%dl
  80190f:	74 0a                	je     80191b <strchr+0x23>
	for (; *s; s++)
  801911:	83 c0 01             	add    $0x1,%eax
  801914:	eb f0                	jmp    801906 <strchr+0xe>
			return (char *) s;
	return 0;
  801916:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80191b:	5d                   	pop    %ebp
  80191c:	c3                   	ret    

0080191d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80191d:	f3 0f 1e fb          	endbr32 
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	8b 45 08             	mov    0x8(%ebp),%eax
  801927:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80192b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80192e:	38 ca                	cmp    %cl,%dl
  801930:	74 09                	je     80193b <strfind+0x1e>
  801932:	84 d2                	test   %dl,%dl
  801934:	74 05                	je     80193b <strfind+0x1e>
	for (; *s; s++)
  801936:	83 c0 01             	add    $0x1,%eax
  801939:	eb f0                	jmp    80192b <strfind+0xe>
			break;
	return (char *) s;
}
  80193b:	5d                   	pop    %ebp
  80193c:	c3                   	ret    

0080193d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80193d:	f3 0f 1e fb          	endbr32 
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	57                   	push   %edi
  801945:	56                   	push   %esi
  801946:	53                   	push   %ebx
  801947:	8b 7d 08             	mov    0x8(%ebp),%edi
  80194a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80194d:	85 c9                	test   %ecx,%ecx
  80194f:	74 31                	je     801982 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801951:	89 f8                	mov    %edi,%eax
  801953:	09 c8                	or     %ecx,%eax
  801955:	a8 03                	test   $0x3,%al
  801957:	75 23                	jne    80197c <memset+0x3f>
		c &= 0xFF;
  801959:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80195d:	89 d3                	mov    %edx,%ebx
  80195f:	c1 e3 08             	shl    $0x8,%ebx
  801962:	89 d0                	mov    %edx,%eax
  801964:	c1 e0 18             	shl    $0x18,%eax
  801967:	89 d6                	mov    %edx,%esi
  801969:	c1 e6 10             	shl    $0x10,%esi
  80196c:	09 f0                	or     %esi,%eax
  80196e:	09 c2                	or     %eax,%edx
  801970:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801972:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801975:	89 d0                	mov    %edx,%eax
  801977:	fc                   	cld    
  801978:	f3 ab                	rep stos %eax,%es:(%edi)
  80197a:	eb 06                	jmp    801982 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80197c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80197f:	fc                   	cld    
  801980:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801982:	89 f8                	mov    %edi,%eax
  801984:	5b                   	pop    %ebx
  801985:	5e                   	pop    %esi
  801986:	5f                   	pop    %edi
  801987:	5d                   	pop    %ebp
  801988:	c3                   	ret    

00801989 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801989:	f3 0f 1e fb          	endbr32 
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
  801990:	57                   	push   %edi
  801991:	56                   	push   %esi
  801992:	8b 45 08             	mov    0x8(%ebp),%eax
  801995:	8b 75 0c             	mov    0xc(%ebp),%esi
  801998:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80199b:	39 c6                	cmp    %eax,%esi
  80199d:	73 32                	jae    8019d1 <memmove+0x48>
  80199f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8019a2:	39 c2                	cmp    %eax,%edx
  8019a4:	76 2b                	jbe    8019d1 <memmove+0x48>
		s += n;
		d += n;
  8019a6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019a9:	89 fe                	mov    %edi,%esi
  8019ab:	09 ce                	or     %ecx,%esi
  8019ad:	09 d6                	or     %edx,%esi
  8019af:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8019b5:	75 0e                	jne    8019c5 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8019b7:	83 ef 04             	sub    $0x4,%edi
  8019ba:	8d 72 fc             	lea    -0x4(%edx),%esi
  8019bd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8019c0:	fd                   	std    
  8019c1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019c3:	eb 09                	jmp    8019ce <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8019c5:	83 ef 01             	sub    $0x1,%edi
  8019c8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8019cb:	fd                   	std    
  8019cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8019ce:	fc                   	cld    
  8019cf:	eb 1a                	jmp    8019eb <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019d1:	89 c2                	mov    %eax,%edx
  8019d3:	09 ca                	or     %ecx,%edx
  8019d5:	09 f2                	or     %esi,%edx
  8019d7:	f6 c2 03             	test   $0x3,%dl
  8019da:	75 0a                	jne    8019e6 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8019dc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8019df:	89 c7                	mov    %eax,%edi
  8019e1:	fc                   	cld    
  8019e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019e4:	eb 05                	jmp    8019eb <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8019e6:	89 c7                	mov    %eax,%edi
  8019e8:	fc                   	cld    
  8019e9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8019eb:	5e                   	pop    %esi
  8019ec:	5f                   	pop    %edi
  8019ed:	5d                   	pop    %ebp
  8019ee:	c3                   	ret    

008019ef <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8019ef:	f3 0f 1e fb          	endbr32 
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8019f9:	ff 75 10             	pushl  0x10(%ebp)
  8019fc:	ff 75 0c             	pushl  0xc(%ebp)
  8019ff:	ff 75 08             	pushl  0x8(%ebp)
  801a02:	e8 82 ff ff ff       	call   801989 <memmove>
}
  801a07:	c9                   	leave  
  801a08:	c3                   	ret    

00801a09 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801a09:	f3 0f 1e fb          	endbr32 
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	56                   	push   %esi
  801a11:	53                   	push   %ebx
  801a12:	8b 45 08             	mov    0x8(%ebp),%eax
  801a15:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a18:	89 c6                	mov    %eax,%esi
  801a1a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a1d:	39 f0                	cmp    %esi,%eax
  801a1f:	74 1c                	je     801a3d <memcmp+0x34>
		if (*s1 != *s2)
  801a21:	0f b6 08             	movzbl (%eax),%ecx
  801a24:	0f b6 1a             	movzbl (%edx),%ebx
  801a27:	38 d9                	cmp    %bl,%cl
  801a29:	75 08                	jne    801a33 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801a2b:	83 c0 01             	add    $0x1,%eax
  801a2e:	83 c2 01             	add    $0x1,%edx
  801a31:	eb ea                	jmp    801a1d <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801a33:	0f b6 c1             	movzbl %cl,%eax
  801a36:	0f b6 db             	movzbl %bl,%ebx
  801a39:	29 d8                	sub    %ebx,%eax
  801a3b:	eb 05                	jmp    801a42 <memcmp+0x39>
	}

	return 0;
  801a3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a42:	5b                   	pop    %ebx
  801a43:	5e                   	pop    %esi
  801a44:	5d                   	pop    %ebp
  801a45:	c3                   	ret    

00801a46 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a46:	f3 0f 1e fb          	endbr32 
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a53:	89 c2                	mov    %eax,%edx
  801a55:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a58:	39 d0                	cmp    %edx,%eax
  801a5a:	73 09                	jae    801a65 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a5c:	38 08                	cmp    %cl,(%eax)
  801a5e:	74 05                	je     801a65 <memfind+0x1f>
	for (; s < ends; s++)
  801a60:	83 c0 01             	add    $0x1,%eax
  801a63:	eb f3                	jmp    801a58 <memfind+0x12>
			break;
	return (void *) s;
}
  801a65:	5d                   	pop    %ebp
  801a66:	c3                   	ret    

00801a67 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a67:	f3 0f 1e fb          	endbr32 
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	57                   	push   %edi
  801a6f:	56                   	push   %esi
  801a70:	53                   	push   %ebx
  801a71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a74:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a77:	eb 03                	jmp    801a7c <strtol+0x15>
		s++;
  801a79:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801a7c:	0f b6 01             	movzbl (%ecx),%eax
  801a7f:	3c 20                	cmp    $0x20,%al
  801a81:	74 f6                	je     801a79 <strtol+0x12>
  801a83:	3c 09                	cmp    $0x9,%al
  801a85:	74 f2                	je     801a79 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801a87:	3c 2b                	cmp    $0x2b,%al
  801a89:	74 2a                	je     801ab5 <strtol+0x4e>
	int neg = 0;
  801a8b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801a90:	3c 2d                	cmp    $0x2d,%al
  801a92:	74 2b                	je     801abf <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a94:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a9a:	75 0f                	jne    801aab <strtol+0x44>
  801a9c:	80 39 30             	cmpb   $0x30,(%ecx)
  801a9f:	74 28                	je     801ac9 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801aa1:	85 db                	test   %ebx,%ebx
  801aa3:	b8 0a 00 00 00       	mov    $0xa,%eax
  801aa8:	0f 44 d8             	cmove  %eax,%ebx
  801aab:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801ab3:	eb 46                	jmp    801afb <strtol+0x94>
		s++;
  801ab5:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801ab8:	bf 00 00 00 00       	mov    $0x0,%edi
  801abd:	eb d5                	jmp    801a94 <strtol+0x2d>
		s++, neg = 1;
  801abf:	83 c1 01             	add    $0x1,%ecx
  801ac2:	bf 01 00 00 00       	mov    $0x1,%edi
  801ac7:	eb cb                	jmp    801a94 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ac9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801acd:	74 0e                	je     801add <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801acf:	85 db                	test   %ebx,%ebx
  801ad1:	75 d8                	jne    801aab <strtol+0x44>
		s++, base = 8;
  801ad3:	83 c1 01             	add    $0x1,%ecx
  801ad6:	bb 08 00 00 00       	mov    $0x8,%ebx
  801adb:	eb ce                	jmp    801aab <strtol+0x44>
		s += 2, base = 16;
  801add:	83 c1 02             	add    $0x2,%ecx
  801ae0:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ae5:	eb c4                	jmp    801aab <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801ae7:	0f be d2             	movsbl %dl,%edx
  801aea:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801aed:	3b 55 10             	cmp    0x10(%ebp),%edx
  801af0:	7d 3a                	jge    801b2c <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801af2:	83 c1 01             	add    $0x1,%ecx
  801af5:	0f af 45 10          	imul   0x10(%ebp),%eax
  801af9:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801afb:	0f b6 11             	movzbl (%ecx),%edx
  801afe:	8d 72 d0             	lea    -0x30(%edx),%esi
  801b01:	89 f3                	mov    %esi,%ebx
  801b03:	80 fb 09             	cmp    $0x9,%bl
  801b06:	76 df                	jbe    801ae7 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801b08:	8d 72 9f             	lea    -0x61(%edx),%esi
  801b0b:	89 f3                	mov    %esi,%ebx
  801b0d:	80 fb 19             	cmp    $0x19,%bl
  801b10:	77 08                	ja     801b1a <strtol+0xb3>
			dig = *s - 'a' + 10;
  801b12:	0f be d2             	movsbl %dl,%edx
  801b15:	83 ea 57             	sub    $0x57,%edx
  801b18:	eb d3                	jmp    801aed <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801b1a:	8d 72 bf             	lea    -0x41(%edx),%esi
  801b1d:	89 f3                	mov    %esi,%ebx
  801b1f:	80 fb 19             	cmp    $0x19,%bl
  801b22:	77 08                	ja     801b2c <strtol+0xc5>
			dig = *s - 'A' + 10;
  801b24:	0f be d2             	movsbl %dl,%edx
  801b27:	83 ea 37             	sub    $0x37,%edx
  801b2a:	eb c1                	jmp    801aed <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801b2c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b30:	74 05                	je     801b37 <strtol+0xd0>
		*endptr = (char *) s;
  801b32:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b35:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801b37:	89 c2                	mov    %eax,%edx
  801b39:	f7 da                	neg    %edx
  801b3b:	85 ff                	test   %edi,%edi
  801b3d:	0f 45 c2             	cmovne %edx,%eax
}
  801b40:	5b                   	pop    %ebx
  801b41:	5e                   	pop    %esi
  801b42:	5f                   	pop    %edi
  801b43:	5d                   	pop    %ebp
  801b44:	c3                   	ret    

00801b45 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b45:	f3 0f 1e fb          	endbr32 
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	56                   	push   %esi
  801b4d:	53                   	push   %ebx
  801b4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b51:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b54:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801b57:	85 c0                	test   %eax,%eax
  801b59:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b5e:	0f 44 c2             	cmove  %edx,%eax
  801b61:	83 ec 0c             	sub    $0xc,%esp
  801b64:	50                   	push   %eax
  801b65:	e8 ef e7 ff ff       	call   800359 <sys_ipc_recv>
  801b6a:	83 c4 10             	add    $0x10,%esp
  801b6d:	85 c0                	test   %eax,%eax
  801b6f:	78 24                	js     801b95 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801b71:	85 f6                	test   %esi,%esi
  801b73:	74 0a                	je     801b7f <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801b75:	a1 04 40 80 00       	mov    0x804004,%eax
  801b7a:	8b 40 78             	mov    0x78(%eax),%eax
  801b7d:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801b7f:	85 db                	test   %ebx,%ebx
  801b81:	74 0a                	je     801b8d <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801b83:	a1 04 40 80 00       	mov    0x804004,%eax
  801b88:	8b 40 74             	mov    0x74(%eax),%eax
  801b8b:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801b8d:	a1 04 40 80 00       	mov    0x804004,%eax
  801b92:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b98:	5b                   	pop    %ebx
  801b99:	5e                   	pop    %esi
  801b9a:	5d                   	pop    %ebp
  801b9b:	c3                   	ret    

00801b9c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b9c:	f3 0f 1e fb          	endbr32 
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	57                   	push   %edi
  801ba4:	56                   	push   %esi
  801ba5:	53                   	push   %ebx
  801ba6:	83 ec 1c             	sub    $0x1c,%esp
  801ba9:	8b 45 10             	mov    0x10(%ebp),%eax
  801bac:	85 c0                	test   %eax,%eax
  801bae:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801bb3:	0f 45 d0             	cmovne %eax,%edx
  801bb6:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801bb8:	be 01 00 00 00       	mov    $0x1,%esi
  801bbd:	eb 1f                	jmp    801bde <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801bbf:	e8 a6 e5 ff ff       	call   80016a <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801bc4:	83 c3 01             	add    $0x1,%ebx
  801bc7:	39 de                	cmp    %ebx,%esi
  801bc9:	7f f4                	jg     801bbf <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801bcb:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801bcd:	83 fe 11             	cmp    $0x11,%esi
  801bd0:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd5:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801bd8:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801bdc:	75 1c                	jne    801bfa <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801bde:	ff 75 14             	pushl  0x14(%ebp)
  801be1:	57                   	push   %edi
  801be2:	ff 75 0c             	pushl  0xc(%ebp)
  801be5:	ff 75 08             	pushl  0x8(%ebp)
  801be8:	e8 45 e7 ff ff       	call   800332 <sys_ipc_try_send>
  801bed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bf8:	eb cd                	jmp    801bc7 <ipc_send+0x2b>
}
  801bfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfd:	5b                   	pop    %ebx
  801bfe:	5e                   	pop    %esi
  801bff:	5f                   	pop    %edi
  801c00:	5d                   	pop    %ebp
  801c01:	c3                   	ret    

00801c02 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c02:	f3 0f 1e fb          	endbr32 
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c0c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c11:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c14:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c1a:	8b 52 50             	mov    0x50(%edx),%edx
  801c1d:	39 ca                	cmp    %ecx,%edx
  801c1f:	74 11                	je     801c32 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801c21:	83 c0 01             	add    $0x1,%eax
  801c24:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c29:	75 e6                	jne    801c11 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801c2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c30:	eb 0b                	jmp    801c3d <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c32:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c35:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c3a:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c3d:	5d                   	pop    %ebp
  801c3e:	c3                   	ret    

00801c3f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c3f:	f3 0f 1e fb          	endbr32 
  801c43:	55                   	push   %ebp
  801c44:	89 e5                	mov    %esp,%ebp
  801c46:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c49:	89 c2                	mov    %eax,%edx
  801c4b:	c1 ea 16             	shr    $0x16,%edx
  801c4e:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c55:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c5a:	f6 c1 01             	test   $0x1,%cl
  801c5d:	74 1c                	je     801c7b <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c5f:	c1 e8 0c             	shr    $0xc,%eax
  801c62:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c69:	a8 01                	test   $0x1,%al
  801c6b:	74 0e                	je     801c7b <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c6d:	c1 e8 0c             	shr    $0xc,%eax
  801c70:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c77:	ef 
  801c78:	0f b7 d2             	movzwl %dx,%edx
}
  801c7b:	89 d0                	mov    %edx,%eax
  801c7d:	5d                   	pop    %ebp
  801c7e:	c3                   	ret    
  801c7f:	90                   	nop

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
