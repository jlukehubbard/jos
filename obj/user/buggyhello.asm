
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
  800136:	68 ca 1e 80 00       	push   $0x801eca
  80013b:	6a 23                	push   $0x23
  80013d:	68 e7 1e 80 00       	push   $0x801ee7
  800142:	e8 70 0f 00 00       	call   8010b7 <_panic>

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
  8001c3:	68 ca 1e 80 00       	push   $0x801eca
  8001c8:	6a 23                	push   $0x23
  8001ca:	68 e7 1e 80 00       	push   $0x801ee7
  8001cf:	e8 e3 0e 00 00       	call   8010b7 <_panic>

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
  800209:	68 ca 1e 80 00       	push   $0x801eca
  80020e:	6a 23                	push   $0x23
  800210:	68 e7 1e 80 00       	push   $0x801ee7
  800215:	e8 9d 0e 00 00       	call   8010b7 <_panic>

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
  80024f:	68 ca 1e 80 00       	push   $0x801eca
  800254:	6a 23                	push   $0x23
  800256:	68 e7 1e 80 00       	push   $0x801ee7
  80025b:	e8 57 0e 00 00       	call   8010b7 <_panic>

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
  800295:	68 ca 1e 80 00       	push   $0x801eca
  80029a:	6a 23                	push   $0x23
  80029c:	68 e7 1e 80 00       	push   $0x801ee7
  8002a1:	e8 11 0e 00 00       	call   8010b7 <_panic>

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
  8002db:	68 ca 1e 80 00       	push   $0x801eca
  8002e0:	6a 23                	push   $0x23
  8002e2:	68 e7 1e 80 00       	push   $0x801ee7
  8002e7:	e8 cb 0d 00 00       	call   8010b7 <_panic>

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
  800321:	68 ca 1e 80 00       	push   $0x801eca
  800326:	6a 23                	push   $0x23
  800328:	68 e7 1e 80 00       	push   $0x801ee7
  80032d:	e8 85 0d 00 00       	call   8010b7 <_panic>

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
  80038d:	68 ca 1e 80 00       	push   $0x801eca
  800392:	6a 23                	push   $0x23
  800394:	68 e7 1e 80 00       	push   $0x801ee7
  800399:	e8 19 0d 00 00       	call   8010b7 <_panic>

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
  800484:	ba 74 1f 80 00       	mov    $0x801f74,%edx
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
  8004a8:	68 f8 1e 80 00       	push   $0x801ef8
  8004ad:	e8 ec 0c 00 00       	call   80119e <cprintf>
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
  800716:	68 39 1f 80 00       	push   $0x801f39
  80071b:	e8 7e 0a 00 00       	call   80119e <cprintf>
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
  8007e7:	68 55 1f 80 00       	push   $0x801f55
  8007ec:	e8 ad 09 00 00       	call   80119e <cprintf>
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
  800897:	68 18 1f 80 00       	push   $0x801f18
  80089c:	e8 fd 08 00 00       	call   80119e <cprintf>
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
  80093b:	e8 cf 01 00 00       	call   800b0f <open>
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
  80098d:	e8 de 11 00 00       	call   801b70 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800992:	83 c4 0c             	add    $0xc,%esp
  800995:	6a 00                	push   $0x0
  800997:	53                   	push   %ebx
  800998:	6a 00                	push   $0x0
  80099a:	e8 7a 11 00 00       	call   801b19 <ipc_recv>
}
  80099f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009a2:	5b                   	pop    %ebx
  8009a3:	5e                   	pop    %esi
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009a6:	83 ec 0c             	sub    $0xc,%esp
  8009a9:	6a 01                	push   $0x1
  8009ab:	e8 26 12 00 00       	call   801bd6 <ipc_find_env>
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
  800a43:	e8 5f 0d 00 00       	call   8017a7 <strcpy>
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
	panic("devfile_write not implemented");
  800a75:	68 84 1f 80 00       	push   $0x801f84
  800a7a:	68 90 00 00 00       	push   $0x90
  800a7f:	68 a2 1f 80 00       	push   $0x801fa2
  800a84:	e8 2e 06 00 00       	call   8010b7 <_panic>

00800a89 <devfile_read>:
{
  800a89:	f3 0f 1e fb          	endbr32 
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
  800a92:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a95:	8b 45 08             	mov    0x8(%ebp),%eax
  800a98:	8b 40 0c             	mov    0xc(%eax),%eax
  800a9b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800aa0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800aa6:	ba 00 00 00 00       	mov    $0x0,%edx
  800aab:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab0:	e8 b8 fe ff ff       	call   80096d <fsipc>
  800ab5:	89 c3                	mov    %eax,%ebx
  800ab7:	85 c0                	test   %eax,%eax
  800ab9:	78 1f                	js     800ada <devfile_read+0x51>
	assert(r <= n);
  800abb:	39 f0                	cmp    %esi,%eax
  800abd:	77 24                	ja     800ae3 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800abf:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac4:	7f 33                	jg     800af9 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ac6:	83 ec 04             	sub    $0x4,%esp
  800ac9:	50                   	push   %eax
  800aca:	68 00 50 80 00       	push   $0x805000
  800acf:	ff 75 0c             	pushl  0xc(%ebp)
  800ad2:	e8 86 0e 00 00       	call   80195d <memmove>
	return r;
  800ad7:	83 c4 10             	add    $0x10,%esp
}
  800ada:	89 d8                	mov    %ebx,%eax
  800adc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    
	assert(r <= n);
  800ae3:	68 ad 1f 80 00       	push   $0x801fad
  800ae8:	68 b4 1f 80 00       	push   $0x801fb4
  800aed:	6a 7c                	push   $0x7c
  800aef:	68 a2 1f 80 00       	push   $0x801fa2
  800af4:	e8 be 05 00 00       	call   8010b7 <_panic>
	assert(r <= PGSIZE);
  800af9:	68 c9 1f 80 00       	push   $0x801fc9
  800afe:	68 b4 1f 80 00       	push   $0x801fb4
  800b03:	6a 7d                	push   $0x7d
  800b05:	68 a2 1f 80 00       	push   $0x801fa2
  800b0a:	e8 a8 05 00 00       	call   8010b7 <_panic>

00800b0f <open>:
{
  800b0f:	f3 0f 1e fb          	endbr32 
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	56                   	push   %esi
  800b17:	53                   	push   %ebx
  800b18:	83 ec 1c             	sub    $0x1c,%esp
  800b1b:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b1e:	56                   	push   %esi
  800b1f:	e8 40 0c 00 00       	call   801764 <strlen>
  800b24:	83 c4 10             	add    $0x10,%esp
  800b27:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b2c:	7f 6c                	jg     800b9a <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800b2e:	83 ec 0c             	sub    $0xc,%esp
  800b31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b34:	50                   	push   %eax
  800b35:	e8 93 f8 ff ff       	call   8003cd <fd_alloc>
  800b3a:	89 c3                	mov    %eax,%ebx
  800b3c:	83 c4 10             	add    $0x10,%esp
  800b3f:	85 c0                	test   %eax,%eax
  800b41:	78 3c                	js     800b7f <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b43:	83 ec 08             	sub    $0x8,%esp
  800b46:	56                   	push   %esi
  800b47:	68 00 50 80 00       	push   $0x805000
  800b4c:	e8 56 0c 00 00       	call   8017a7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b54:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b59:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b5c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b61:	e8 07 fe ff ff       	call   80096d <fsipc>
  800b66:	89 c3                	mov    %eax,%ebx
  800b68:	83 c4 10             	add    $0x10,%esp
  800b6b:	85 c0                	test   %eax,%eax
  800b6d:	78 19                	js     800b88 <open+0x79>
	return fd2num(fd);
  800b6f:	83 ec 0c             	sub    $0xc,%esp
  800b72:	ff 75 f4             	pushl  -0xc(%ebp)
  800b75:	e8 24 f8 ff ff       	call   80039e <fd2num>
  800b7a:	89 c3                	mov    %eax,%ebx
  800b7c:	83 c4 10             	add    $0x10,%esp
}
  800b7f:	89 d8                	mov    %ebx,%eax
  800b81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    
		fd_close(fd, 0);
  800b88:	83 ec 08             	sub    $0x8,%esp
  800b8b:	6a 00                	push   $0x0
  800b8d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b90:	e8 3c f9 ff ff       	call   8004d1 <fd_close>
		return r;
  800b95:	83 c4 10             	add    $0x10,%esp
  800b98:	eb e5                	jmp    800b7f <open+0x70>
		return -E_BAD_PATH;
  800b9a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b9f:	eb de                	jmp    800b7f <open+0x70>

00800ba1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ba1:	f3 0f 1e fb          	endbr32 
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bab:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb0:	b8 08 00 00 00       	mov    $0x8,%eax
  800bb5:	e8 b3 fd ff ff       	call   80096d <fsipc>
}
  800bba:	c9                   	leave  
  800bbb:	c3                   	ret    

00800bbc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bbc:	f3 0f 1e fb          	endbr32 
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
  800bc5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bc8:	83 ec 0c             	sub    $0xc,%esp
  800bcb:	ff 75 08             	pushl  0x8(%ebp)
  800bce:	e8 df f7 ff ff       	call   8003b2 <fd2data>
  800bd3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bd5:	83 c4 08             	add    $0x8,%esp
  800bd8:	68 d5 1f 80 00       	push   $0x801fd5
  800bdd:	53                   	push   %ebx
  800bde:	e8 c4 0b 00 00       	call   8017a7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800be3:	8b 46 04             	mov    0x4(%esi),%eax
  800be6:	2b 06                	sub    (%esi),%eax
  800be8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bee:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bf5:	00 00 00 
	stat->st_dev = &devpipe;
  800bf8:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bff:	30 80 00 
	return 0;
}
  800c02:	b8 00 00 00 00       	mov    $0x0,%eax
  800c07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c0e:	f3 0f 1e fb          	endbr32 
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	53                   	push   %ebx
  800c16:	83 ec 0c             	sub    $0xc,%esp
  800c19:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c1c:	53                   	push   %ebx
  800c1d:	6a 00                	push   $0x0
  800c1f:	e8 f6 f5 ff ff       	call   80021a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c24:	89 1c 24             	mov    %ebx,(%esp)
  800c27:	e8 86 f7 ff ff       	call   8003b2 <fd2data>
  800c2c:	83 c4 08             	add    $0x8,%esp
  800c2f:	50                   	push   %eax
  800c30:	6a 00                	push   $0x0
  800c32:	e8 e3 f5 ff ff       	call   80021a <sys_page_unmap>
}
  800c37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c3a:	c9                   	leave  
  800c3b:	c3                   	ret    

00800c3c <_pipeisclosed>:
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	57                   	push   %edi
  800c40:	56                   	push   %esi
  800c41:	53                   	push   %ebx
  800c42:	83 ec 1c             	sub    $0x1c,%esp
  800c45:	89 c7                	mov    %eax,%edi
  800c47:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c49:	a1 04 40 80 00       	mov    0x804004,%eax
  800c4e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c51:	83 ec 0c             	sub    $0xc,%esp
  800c54:	57                   	push   %edi
  800c55:	e8 b9 0f 00 00       	call   801c13 <pageref>
  800c5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c5d:	89 34 24             	mov    %esi,(%esp)
  800c60:	e8 ae 0f 00 00       	call   801c13 <pageref>
		nn = thisenv->env_runs;
  800c65:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c6b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c6e:	83 c4 10             	add    $0x10,%esp
  800c71:	39 cb                	cmp    %ecx,%ebx
  800c73:	74 1b                	je     800c90 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c75:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c78:	75 cf                	jne    800c49 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c7a:	8b 42 58             	mov    0x58(%edx),%eax
  800c7d:	6a 01                	push   $0x1
  800c7f:	50                   	push   %eax
  800c80:	53                   	push   %ebx
  800c81:	68 dc 1f 80 00       	push   $0x801fdc
  800c86:	e8 13 05 00 00       	call   80119e <cprintf>
  800c8b:	83 c4 10             	add    $0x10,%esp
  800c8e:	eb b9                	jmp    800c49 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c90:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c93:	0f 94 c0             	sete   %al
  800c96:	0f b6 c0             	movzbl %al,%eax
}
  800c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <devpipe_write>:
{
  800ca1:	f3 0f 1e fb          	endbr32 
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 28             	sub    $0x28,%esp
  800cae:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800cb1:	56                   	push   %esi
  800cb2:	e8 fb f6 ff ff       	call   8003b2 <fd2data>
  800cb7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cb9:	83 c4 10             	add    $0x10,%esp
  800cbc:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cc4:	74 4f                	je     800d15 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cc6:	8b 43 04             	mov    0x4(%ebx),%eax
  800cc9:	8b 0b                	mov    (%ebx),%ecx
  800ccb:	8d 51 20             	lea    0x20(%ecx),%edx
  800cce:	39 d0                	cmp    %edx,%eax
  800cd0:	72 14                	jb     800ce6 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800cd2:	89 da                	mov    %ebx,%edx
  800cd4:	89 f0                	mov    %esi,%eax
  800cd6:	e8 61 ff ff ff       	call   800c3c <_pipeisclosed>
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	75 3b                	jne    800d1a <devpipe_write+0x79>
			sys_yield();
  800cdf:	e8 86 f4 ff ff       	call   80016a <sys_yield>
  800ce4:	eb e0                	jmp    800cc6 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ced:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cf0:	89 c2                	mov    %eax,%edx
  800cf2:	c1 fa 1f             	sar    $0x1f,%edx
  800cf5:	89 d1                	mov    %edx,%ecx
  800cf7:	c1 e9 1b             	shr    $0x1b,%ecx
  800cfa:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cfd:	83 e2 1f             	and    $0x1f,%edx
  800d00:	29 ca                	sub    %ecx,%edx
  800d02:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800d06:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d0a:	83 c0 01             	add    $0x1,%eax
  800d0d:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800d10:	83 c7 01             	add    $0x1,%edi
  800d13:	eb ac                	jmp    800cc1 <devpipe_write+0x20>
	return i;
  800d15:	8b 45 10             	mov    0x10(%ebp),%eax
  800d18:	eb 05                	jmp    800d1f <devpipe_write+0x7e>
				return 0;
  800d1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <devpipe_read>:
{
  800d27:	f3 0f 1e fb          	endbr32 
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	57                   	push   %edi
  800d2f:	56                   	push   %esi
  800d30:	53                   	push   %ebx
  800d31:	83 ec 18             	sub    $0x18,%esp
  800d34:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800d37:	57                   	push   %edi
  800d38:	e8 75 f6 ff ff       	call   8003b2 <fd2data>
  800d3d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d3f:	83 c4 10             	add    $0x10,%esp
  800d42:	be 00 00 00 00       	mov    $0x0,%esi
  800d47:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d4a:	75 14                	jne    800d60 <devpipe_read+0x39>
	return i;
  800d4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d4f:	eb 02                	jmp    800d53 <devpipe_read+0x2c>
				return i;
  800d51:	89 f0                	mov    %esi,%eax
}
  800d53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    
			sys_yield();
  800d5b:	e8 0a f4 ff ff       	call   80016a <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d60:	8b 03                	mov    (%ebx),%eax
  800d62:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d65:	75 18                	jne    800d7f <devpipe_read+0x58>
			if (i > 0)
  800d67:	85 f6                	test   %esi,%esi
  800d69:	75 e6                	jne    800d51 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d6b:	89 da                	mov    %ebx,%edx
  800d6d:	89 f8                	mov    %edi,%eax
  800d6f:	e8 c8 fe ff ff       	call   800c3c <_pipeisclosed>
  800d74:	85 c0                	test   %eax,%eax
  800d76:	74 e3                	je     800d5b <devpipe_read+0x34>
				return 0;
  800d78:	b8 00 00 00 00       	mov    $0x0,%eax
  800d7d:	eb d4                	jmp    800d53 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d7f:	99                   	cltd   
  800d80:	c1 ea 1b             	shr    $0x1b,%edx
  800d83:	01 d0                	add    %edx,%eax
  800d85:	83 e0 1f             	and    $0x1f,%eax
  800d88:	29 d0                	sub    %edx,%eax
  800d8a:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d92:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d95:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d98:	83 c6 01             	add    $0x1,%esi
  800d9b:	eb aa                	jmp    800d47 <devpipe_read+0x20>

00800d9d <pipe>:
{
  800d9d:	f3 0f 1e fb          	endbr32 
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800da9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dac:	50                   	push   %eax
  800dad:	e8 1b f6 ff ff       	call   8003cd <fd_alloc>
  800db2:	89 c3                	mov    %eax,%ebx
  800db4:	83 c4 10             	add    $0x10,%esp
  800db7:	85 c0                	test   %eax,%eax
  800db9:	0f 88 23 01 00 00    	js     800ee2 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dbf:	83 ec 04             	sub    $0x4,%esp
  800dc2:	68 07 04 00 00       	push   $0x407
  800dc7:	ff 75 f4             	pushl  -0xc(%ebp)
  800dca:	6a 00                	push   $0x0
  800dcc:	e8 bc f3 ff ff       	call   80018d <sys_page_alloc>
  800dd1:	89 c3                	mov    %eax,%ebx
  800dd3:	83 c4 10             	add    $0x10,%esp
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	0f 88 04 01 00 00    	js     800ee2 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800dde:	83 ec 0c             	sub    $0xc,%esp
  800de1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800de4:	50                   	push   %eax
  800de5:	e8 e3 f5 ff ff       	call   8003cd <fd_alloc>
  800dea:	89 c3                	mov    %eax,%ebx
  800dec:	83 c4 10             	add    $0x10,%esp
  800def:	85 c0                	test   %eax,%eax
  800df1:	0f 88 db 00 00 00    	js     800ed2 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df7:	83 ec 04             	sub    $0x4,%esp
  800dfa:	68 07 04 00 00       	push   $0x407
  800dff:	ff 75 f0             	pushl  -0x10(%ebp)
  800e02:	6a 00                	push   $0x0
  800e04:	e8 84 f3 ff ff       	call   80018d <sys_page_alloc>
  800e09:	89 c3                	mov    %eax,%ebx
  800e0b:	83 c4 10             	add    $0x10,%esp
  800e0e:	85 c0                	test   %eax,%eax
  800e10:	0f 88 bc 00 00 00    	js     800ed2 <pipe+0x135>
	va = fd2data(fd0);
  800e16:	83 ec 0c             	sub    $0xc,%esp
  800e19:	ff 75 f4             	pushl  -0xc(%ebp)
  800e1c:	e8 91 f5 ff ff       	call   8003b2 <fd2data>
  800e21:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e23:	83 c4 0c             	add    $0xc,%esp
  800e26:	68 07 04 00 00       	push   $0x407
  800e2b:	50                   	push   %eax
  800e2c:	6a 00                	push   $0x0
  800e2e:	e8 5a f3 ff ff       	call   80018d <sys_page_alloc>
  800e33:	89 c3                	mov    %eax,%ebx
  800e35:	83 c4 10             	add    $0x10,%esp
  800e38:	85 c0                	test   %eax,%eax
  800e3a:	0f 88 82 00 00 00    	js     800ec2 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e40:	83 ec 0c             	sub    $0xc,%esp
  800e43:	ff 75 f0             	pushl  -0x10(%ebp)
  800e46:	e8 67 f5 ff ff       	call   8003b2 <fd2data>
  800e4b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e52:	50                   	push   %eax
  800e53:	6a 00                	push   $0x0
  800e55:	56                   	push   %esi
  800e56:	6a 00                	push   $0x0
  800e58:	e8 77 f3 ff ff       	call   8001d4 <sys_page_map>
  800e5d:	89 c3                	mov    %eax,%ebx
  800e5f:	83 c4 20             	add    $0x20,%esp
  800e62:	85 c0                	test   %eax,%eax
  800e64:	78 4e                	js     800eb4 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e66:	a1 20 30 80 00       	mov    0x803020,%eax
  800e6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e6e:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e70:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e73:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e7a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e7d:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e82:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e89:	83 ec 0c             	sub    $0xc,%esp
  800e8c:	ff 75 f4             	pushl  -0xc(%ebp)
  800e8f:	e8 0a f5 ff ff       	call   80039e <fd2num>
  800e94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e97:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e99:	83 c4 04             	add    $0x4,%esp
  800e9c:	ff 75 f0             	pushl  -0x10(%ebp)
  800e9f:	e8 fa f4 ff ff       	call   80039e <fd2num>
  800ea4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800eaa:	83 c4 10             	add    $0x10,%esp
  800ead:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb2:	eb 2e                	jmp    800ee2 <pipe+0x145>
	sys_page_unmap(0, va);
  800eb4:	83 ec 08             	sub    $0x8,%esp
  800eb7:	56                   	push   %esi
  800eb8:	6a 00                	push   $0x0
  800eba:	e8 5b f3 ff ff       	call   80021a <sys_page_unmap>
  800ebf:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800ec2:	83 ec 08             	sub    $0x8,%esp
  800ec5:	ff 75 f0             	pushl  -0x10(%ebp)
  800ec8:	6a 00                	push   $0x0
  800eca:	e8 4b f3 ff ff       	call   80021a <sys_page_unmap>
  800ecf:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800ed2:	83 ec 08             	sub    $0x8,%esp
  800ed5:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed8:	6a 00                	push   $0x0
  800eda:	e8 3b f3 ff ff       	call   80021a <sys_page_unmap>
  800edf:	83 c4 10             	add    $0x10,%esp
}
  800ee2:	89 d8                	mov    %ebx,%eax
  800ee4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee7:	5b                   	pop    %ebx
  800ee8:	5e                   	pop    %esi
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    

00800eeb <pipeisclosed>:
{
  800eeb:	f3 0f 1e fb          	endbr32 
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ef5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ef8:	50                   	push   %eax
  800ef9:	ff 75 08             	pushl  0x8(%ebp)
  800efc:	e8 22 f5 ff ff       	call   800423 <fd_lookup>
  800f01:	83 c4 10             	add    $0x10,%esp
  800f04:	85 c0                	test   %eax,%eax
  800f06:	78 18                	js     800f20 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800f08:	83 ec 0c             	sub    $0xc,%esp
  800f0b:	ff 75 f4             	pushl  -0xc(%ebp)
  800f0e:	e8 9f f4 ff ff       	call   8003b2 <fd2data>
  800f13:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f18:	e8 1f fd ff ff       	call   800c3c <_pipeisclosed>
  800f1d:	83 c4 10             	add    $0x10,%esp
}
  800f20:	c9                   	leave  
  800f21:	c3                   	ret    

00800f22 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f22:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800f26:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2b:	c3                   	ret    

00800f2c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f2c:	f3 0f 1e fb          	endbr32 
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f36:	68 f4 1f 80 00       	push   $0x801ff4
  800f3b:	ff 75 0c             	pushl  0xc(%ebp)
  800f3e:	e8 64 08 00 00       	call   8017a7 <strcpy>
	return 0;
}
  800f43:	b8 00 00 00 00       	mov    $0x0,%eax
  800f48:	c9                   	leave  
  800f49:	c3                   	ret    

00800f4a <devcons_write>:
{
  800f4a:	f3 0f 1e fb          	endbr32 
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	57                   	push   %edi
  800f52:	56                   	push   %esi
  800f53:	53                   	push   %ebx
  800f54:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f5a:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f5f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f65:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f68:	73 31                	jae    800f9b <devcons_write+0x51>
		m = n - tot;
  800f6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f6d:	29 f3                	sub    %esi,%ebx
  800f6f:	83 fb 7f             	cmp    $0x7f,%ebx
  800f72:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f77:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f7a:	83 ec 04             	sub    $0x4,%esp
  800f7d:	53                   	push   %ebx
  800f7e:	89 f0                	mov    %esi,%eax
  800f80:	03 45 0c             	add    0xc(%ebp),%eax
  800f83:	50                   	push   %eax
  800f84:	57                   	push   %edi
  800f85:	e8 d3 09 00 00       	call   80195d <memmove>
		sys_cputs(buf, m);
  800f8a:	83 c4 08             	add    $0x8,%esp
  800f8d:	53                   	push   %ebx
  800f8e:	57                   	push   %edi
  800f8f:	e8 29 f1 ff ff       	call   8000bd <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f94:	01 de                	add    %ebx,%esi
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	eb ca                	jmp    800f65 <devcons_write+0x1b>
}
  800f9b:	89 f0                	mov    %esi,%eax
  800f9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa0:	5b                   	pop    %ebx
  800fa1:	5e                   	pop    %esi
  800fa2:	5f                   	pop    %edi
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    

00800fa5 <devcons_read>:
{
  800fa5:	f3 0f 1e fb          	endbr32 
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	83 ec 08             	sub    $0x8,%esp
  800faf:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800fb4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fb8:	74 21                	je     800fdb <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800fba:	e8 20 f1 ff ff       	call   8000df <sys_cgetc>
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	75 07                	jne    800fca <devcons_read+0x25>
		sys_yield();
  800fc3:	e8 a2 f1 ff ff       	call   80016a <sys_yield>
  800fc8:	eb f0                	jmp    800fba <devcons_read+0x15>
	if (c < 0)
  800fca:	78 0f                	js     800fdb <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800fcc:	83 f8 04             	cmp    $0x4,%eax
  800fcf:	74 0c                	je     800fdd <devcons_read+0x38>
	*(char*)vbuf = c;
  800fd1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fd4:	88 02                	mov    %al,(%edx)
	return 1;
  800fd6:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800fdb:	c9                   	leave  
  800fdc:	c3                   	ret    
		return 0;
  800fdd:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe2:	eb f7                	jmp    800fdb <devcons_read+0x36>

00800fe4 <cputchar>:
{
  800fe4:	f3 0f 1e fb          	endbr32 
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fee:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff1:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800ff4:	6a 01                	push   $0x1
  800ff6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800ff9:	50                   	push   %eax
  800ffa:	e8 be f0 ff ff       	call   8000bd <sys_cputs>
}
  800fff:	83 c4 10             	add    $0x10,%esp
  801002:	c9                   	leave  
  801003:	c3                   	ret    

00801004 <getchar>:
{
  801004:	f3 0f 1e fb          	endbr32 
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80100e:	6a 01                	push   $0x1
  801010:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801013:	50                   	push   %eax
  801014:	6a 00                	push   $0x0
  801016:	e8 8b f6 ff ff       	call   8006a6 <read>
	if (r < 0)
  80101b:	83 c4 10             	add    $0x10,%esp
  80101e:	85 c0                	test   %eax,%eax
  801020:	78 06                	js     801028 <getchar+0x24>
	if (r < 1)
  801022:	74 06                	je     80102a <getchar+0x26>
	return c;
  801024:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801028:	c9                   	leave  
  801029:	c3                   	ret    
		return -E_EOF;
  80102a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80102f:	eb f7                	jmp    801028 <getchar+0x24>

00801031 <iscons>:
{
  801031:	f3 0f 1e fb          	endbr32 
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80103b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80103e:	50                   	push   %eax
  80103f:	ff 75 08             	pushl  0x8(%ebp)
  801042:	e8 dc f3 ff ff       	call   800423 <fd_lookup>
  801047:	83 c4 10             	add    $0x10,%esp
  80104a:	85 c0                	test   %eax,%eax
  80104c:	78 11                	js     80105f <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80104e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801051:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801057:	39 10                	cmp    %edx,(%eax)
  801059:	0f 94 c0             	sete   %al
  80105c:	0f b6 c0             	movzbl %al,%eax
}
  80105f:	c9                   	leave  
  801060:	c3                   	ret    

00801061 <opencons>:
{
  801061:	f3 0f 1e fb          	endbr32 
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80106b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80106e:	50                   	push   %eax
  80106f:	e8 59 f3 ff ff       	call   8003cd <fd_alloc>
  801074:	83 c4 10             	add    $0x10,%esp
  801077:	85 c0                	test   %eax,%eax
  801079:	78 3a                	js     8010b5 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80107b:	83 ec 04             	sub    $0x4,%esp
  80107e:	68 07 04 00 00       	push   $0x407
  801083:	ff 75 f4             	pushl  -0xc(%ebp)
  801086:	6a 00                	push   $0x0
  801088:	e8 00 f1 ff ff       	call   80018d <sys_page_alloc>
  80108d:	83 c4 10             	add    $0x10,%esp
  801090:	85 c0                	test   %eax,%eax
  801092:	78 21                	js     8010b5 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801094:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801097:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80109d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80109f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8010a9:	83 ec 0c             	sub    $0xc,%esp
  8010ac:	50                   	push   %eax
  8010ad:	e8 ec f2 ff ff       	call   80039e <fd2num>
  8010b2:	83 c4 10             	add    $0x10,%esp
}
  8010b5:	c9                   	leave  
  8010b6:	c3                   	ret    

008010b7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010b7:	f3 0f 1e fb          	endbr32 
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	56                   	push   %esi
  8010bf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010c0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010c3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010c9:	e8 79 f0 ff ff       	call   800147 <sys_getenvid>
  8010ce:	83 ec 0c             	sub    $0xc,%esp
  8010d1:	ff 75 0c             	pushl  0xc(%ebp)
  8010d4:	ff 75 08             	pushl  0x8(%ebp)
  8010d7:	56                   	push   %esi
  8010d8:	50                   	push   %eax
  8010d9:	68 00 20 80 00       	push   $0x802000
  8010de:	e8 bb 00 00 00       	call   80119e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010e3:	83 c4 18             	add    $0x18,%esp
  8010e6:	53                   	push   %ebx
  8010e7:	ff 75 10             	pushl  0x10(%ebp)
  8010ea:	e8 5a 00 00 00       	call   801149 <vcprintf>
	cprintf("\n");
  8010ef:	c7 04 24 ed 1f 80 00 	movl   $0x801fed,(%esp)
  8010f6:	e8 a3 00 00 00       	call   80119e <cprintf>
  8010fb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010fe:	cc                   	int3   
  8010ff:	eb fd                	jmp    8010fe <_panic+0x47>

00801101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801101:	f3 0f 1e fb          	endbr32 
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	53                   	push   %ebx
  801109:	83 ec 04             	sub    $0x4,%esp
  80110c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80110f:	8b 13                	mov    (%ebx),%edx
  801111:	8d 42 01             	lea    0x1(%edx),%eax
  801114:	89 03                	mov    %eax,(%ebx)
  801116:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801119:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80111d:	3d ff 00 00 00       	cmp    $0xff,%eax
  801122:	74 09                	je     80112d <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801124:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801128:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80112b:	c9                   	leave  
  80112c:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80112d:	83 ec 08             	sub    $0x8,%esp
  801130:	68 ff 00 00 00       	push   $0xff
  801135:	8d 43 08             	lea    0x8(%ebx),%eax
  801138:	50                   	push   %eax
  801139:	e8 7f ef ff ff       	call   8000bd <sys_cputs>
		b->idx = 0;
  80113e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	eb db                	jmp    801124 <putch+0x23>

00801149 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801149:	f3 0f 1e fb          	endbr32 
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
  801150:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801156:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80115d:	00 00 00 
	b.cnt = 0;
  801160:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801167:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80116a:	ff 75 0c             	pushl  0xc(%ebp)
  80116d:	ff 75 08             	pushl  0x8(%ebp)
  801170:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801176:	50                   	push   %eax
  801177:	68 01 11 80 00       	push   $0x801101
  80117c:	e8 20 01 00 00       	call   8012a1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801181:	83 c4 08             	add    $0x8,%esp
  801184:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80118a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801190:	50                   	push   %eax
  801191:	e8 27 ef ff ff       	call   8000bd <sys_cputs>

	return b.cnt;
}
  801196:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80119c:	c9                   	leave  
  80119d:	c3                   	ret    

0080119e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80119e:	f3 0f 1e fb          	endbr32 
  8011a2:	55                   	push   %ebp
  8011a3:	89 e5                	mov    %esp,%ebp
  8011a5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8011a8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8011ab:	50                   	push   %eax
  8011ac:	ff 75 08             	pushl  0x8(%ebp)
  8011af:	e8 95 ff ff ff       	call   801149 <vcprintf>
	va_end(ap);

	return cnt;
}
  8011b4:	c9                   	leave  
  8011b5:	c3                   	ret    

008011b6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	57                   	push   %edi
  8011ba:	56                   	push   %esi
  8011bb:	53                   	push   %ebx
  8011bc:	83 ec 1c             	sub    $0x1c,%esp
  8011bf:	89 c7                	mov    %eax,%edi
  8011c1:	89 d6                	mov    %edx,%esi
  8011c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c9:	89 d1                	mov    %edx,%ecx
  8011cb:	89 c2                	mov    %eax,%edx
  8011cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011d0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8011d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011dc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8011e3:	39 c2                	cmp    %eax,%edx
  8011e5:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8011e8:	72 3e                	jb     801228 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011ea:	83 ec 0c             	sub    $0xc,%esp
  8011ed:	ff 75 18             	pushl  0x18(%ebp)
  8011f0:	83 eb 01             	sub    $0x1,%ebx
  8011f3:	53                   	push   %ebx
  8011f4:	50                   	push   %eax
  8011f5:	83 ec 08             	sub    $0x8,%esp
  8011f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8011fe:	ff 75 dc             	pushl  -0x24(%ebp)
  801201:	ff 75 d8             	pushl  -0x28(%ebp)
  801204:	e8 57 0a 00 00       	call   801c60 <__udivdi3>
  801209:	83 c4 18             	add    $0x18,%esp
  80120c:	52                   	push   %edx
  80120d:	50                   	push   %eax
  80120e:	89 f2                	mov    %esi,%edx
  801210:	89 f8                	mov    %edi,%eax
  801212:	e8 9f ff ff ff       	call   8011b6 <printnum>
  801217:	83 c4 20             	add    $0x20,%esp
  80121a:	eb 13                	jmp    80122f <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80121c:	83 ec 08             	sub    $0x8,%esp
  80121f:	56                   	push   %esi
  801220:	ff 75 18             	pushl  0x18(%ebp)
  801223:	ff d7                	call   *%edi
  801225:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801228:	83 eb 01             	sub    $0x1,%ebx
  80122b:	85 db                	test   %ebx,%ebx
  80122d:	7f ed                	jg     80121c <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80122f:	83 ec 08             	sub    $0x8,%esp
  801232:	56                   	push   %esi
  801233:	83 ec 04             	sub    $0x4,%esp
  801236:	ff 75 e4             	pushl  -0x1c(%ebp)
  801239:	ff 75 e0             	pushl  -0x20(%ebp)
  80123c:	ff 75 dc             	pushl  -0x24(%ebp)
  80123f:	ff 75 d8             	pushl  -0x28(%ebp)
  801242:	e8 29 0b 00 00       	call   801d70 <__umoddi3>
  801247:	83 c4 14             	add    $0x14,%esp
  80124a:	0f be 80 23 20 80 00 	movsbl 0x802023(%eax),%eax
  801251:	50                   	push   %eax
  801252:	ff d7                	call   *%edi
}
  801254:	83 c4 10             	add    $0x10,%esp
  801257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125a:	5b                   	pop    %ebx
  80125b:	5e                   	pop    %esi
  80125c:	5f                   	pop    %edi
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    

0080125f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80125f:	f3 0f 1e fb          	endbr32 
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801269:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80126d:	8b 10                	mov    (%eax),%edx
  80126f:	3b 50 04             	cmp    0x4(%eax),%edx
  801272:	73 0a                	jae    80127e <sprintputch+0x1f>
		*b->buf++ = ch;
  801274:	8d 4a 01             	lea    0x1(%edx),%ecx
  801277:	89 08                	mov    %ecx,(%eax)
  801279:	8b 45 08             	mov    0x8(%ebp),%eax
  80127c:	88 02                	mov    %al,(%edx)
}
  80127e:	5d                   	pop    %ebp
  80127f:	c3                   	ret    

00801280 <printfmt>:
{
  801280:	f3 0f 1e fb          	endbr32 
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
  801287:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80128a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80128d:	50                   	push   %eax
  80128e:	ff 75 10             	pushl  0x10(%ebp)
  801291:	ff 75 0c             	pushl  0xc(%ebp)
  801294:	ff 75 08             	pushl  0x8(%ebp)
  801297:	e8 05 00 00 00       	call   8012a1 <vprintfmt>
}
  80129c:	83 c4 10             	add    $0x10,%esp
  80129f:	c9                   	leave  
  8012a0:	c3                   	ret    

008012a1 <vprintfmt>:
{
  8012a1:	f3 0f 1e fb          	endbr32 
  8012a5:	55                   	push   %ebp
  8012a6:	89 e5                	mov    %esp,%ebp
  8012a8:	57                   	push   %edi
  8012a9:	56                   	push   %esi
  8012aa:	53                   	push   %ebx
  8012ab:	83 ec 3c             	sub    $0x3c,%esp
  8012ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8012b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012b4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012b7:	e9 4a 03 00 00       	jmp    801606 <vprintfmt+0x365>
		padc = ' ';
  8012bc:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012c0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012c7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012ce:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012d5:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012da:	8d 47 01             	lea    0x1(%edi),%eax
  8012dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012e0:	0f b6 17             	movzbl (%edi),%edx
  8012e3:	8d 42 dd             	lea    -0x23(%edx),%eax
  8012e6:	3c 55                	cmp    $0x55,%al
  8012e8:	0f 87 de 03 00 00    	ja     8016cc <vprintfmt+0x42b>
  8012ee:	0f b6 c0             	movzbl %al,%eax
  8012f1:	3e ff 24 85 60 21 80 	notrack jmp *0x802160(,%eax,4)
  8012f8:	00 
  8012f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8012fc:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801300:	eb d8                	jmp    8012da <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801302:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801305:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801309:	eb cf                	jmp    8012da <vprintfmt+0x39>
  80130b:	0f b6 d2             	movzbl %dl,%edx
  80130e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801311:	b8 00 00 00 00       	mov    $0x0,%eax
  801316:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801319:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80131c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801320:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801323:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801326:	83 f9 09             	cmp    $0x9,%ecx
  801329:	77 55                	ja     801380 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80132b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80132e:	eb e9                	jmp    801319 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801330:	8b 45 14             	mov    0x14(%ebp),%eax
  801333:	8b 00                	mov    (%eax),%eax
  801335:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801338:	8b 45 14             	mov    0x14(%ebp),%eax
  80133b:	8d 40 04             	lea    0x4(%eax),%eax
  80133e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801341:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801344:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801348:	79 90                	jns    8012da <vprintfmt+0x39>
				width = precision, precision = -1;
  80134a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80134d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801350:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801357:	eb 81                	jmp    8012da <vprintfmt+0x39>
  801359:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80135c:	85 c0                	test   %eax,%eax
  80135e:	ba 00 00 00 00       	mov    $0x0,%edx
  801363:	0f 49 d0             	cmovns %eax,%edx
  801366:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80136c:	e9 69 ff ff ff       	jmp    8012da <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801371:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801374:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80137b:	e9 5a ff ff ff       	jmp    8012da <vprintfmt+0x39>
  801380:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801383:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801386:	eb bc                	jmp    801344 <vprintfmt+0xa3>
			lflag++;
  801388:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80138b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80138e:	e9 47 ff ff ff       	jmp    8012da <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  801393:	8b 45 14             	mov    0x14(%ebp),%eax
  801396:	8d 78 04             	lea    0x4(%eax),%edi
  801399:	83 ec 08             	sub    $0x8,%esp
  80139c:	53                   	push   %ebx
  80139d:	ff 30                	pushl  (%eax)
  80139f:	ff d6                	call   *%esi
			break;
  8013a1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8013a4:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8013a7:	e9 57 02 00 00       	jmp    801603 <vprintfmt+0x362>
			err = va_arg(ap, int);
  8013ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8013af:	8d 78 04             	lea    0x4(%eax),%edi
  8013b2:	8b 00                	mov    (%eax),%eax
  8013b4:	99                   	cltd   
  8013b5:	31 d0                	xor    %edx,%eax
  8013b7:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013b9:	83 f8 0f             	cmp    $0xf,%eax
  8013bc:	7f 23                	jg     8013e1 <vprintfmt+0x140>
  8013be:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  8013c5:	85 d2                	test   %edx,%edx
  8013c7:	74 18                	je     8013e1 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8013c9:	52                   	push   %edx
  8013ca:	68 c6 1f 80 00       	push   $0x801fc6
  8013cf:	53                   	push   %ebx
  8013d0:	56                   	push   %esi
  8013d1:	e8 aa fe ff ff       	call   801280 <printfmt>
  8013d6:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8013d9:	89 7d 14             	mov    %edi,0x14(%ebp)
  8013dc:	e9 22 02 00 00       	jmp    801603 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8013e1:	50                   	push   %eax
  8013e2:	68 3b 20 80 00       	push   $0x80203b
  8013e7:	53                   	push   %ebx
  8013e8:	56                   	push   %esi
  8013e9:	e8 92 fe ff ff       	call   801280 <printfmt>
  8013ee:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8013f1:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8013f4:	e9 0a 02 00 00       	jmp    801603 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8013f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8013fc:	83 c0 04             	add    $0x4,%eax
  8013ff:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801402:	8b 45 14             	mov    0x14(%ebp),%eax
  801405:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801407:	85 d2                	test   %edx,%edx
  801409:	b8 34 20 80 00       	mov    $0x802034,%eax
  80140e:	0f 45 c2             	cmovne %edx,%eax
  801411:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801414:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801418:	7e 06                	jle    801420 <vprintfmt+0x17f>
  80141a:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80141e:	75 0d                	jne    80142d <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  801420:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801423:	89 c7                	mov    %eax,%edi
  801425:	03 45 e0             	add    -0x20(%ebp),%eax
  801428:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80142b:	eb 55                	jmp    801482 <vprintfmt+0x1e1>
  80142d:	83 ec 08             	sub    $0x8,%esp
  801430:	ff 75 d8             	pushl  -0x28(%ebp)
  801433:	ff 75 cc             	pushl  -0x34(%ebp)
  801436:	e8 45 03 00 00       	call   801780 <strnlen>
  80143b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80143e:	29 c2                	sub    %eax,%edx
  801440:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801443:	83 c4 10             	add    $0x10,%esp
  801446:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  801448:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80144c:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80144f:	85 ff                	test   %edi,%edi
  801451:	7e 11                	jle    801464 <vprintfmt+0x1c3>
					putch(padc, putdat);
  801453:	83 ec 08             	sub    $0x8,%esp
  801456:	53                   	push   %ebx
  801457:	ff 75 e0             	pushl  -0x20(%ebp)
  80145a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80145c:	83 ef 01             	sub    $0x1,%edi
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	eb eb                	jmp    80144f <vprintfmt+0x1ae>
  801464:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801467:	85 d2                	test   %edx,%edx
  801469:	b8 00 00 00 00       	mov    $0x0,%eax
  80146e:	0f 49 c2             	cmovns %edx,%eax
  801471:	29 c2                	sub    %eax,%edx
  801473:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801476:	eb a8                	jmp    801420 <vprintfmt+0x17f>
					putch(ch, putdat);
  801478:	83 ec 08             	sub    $0x8,%esp
  80147b:	53                   	push   %ebx
  80147c:	52                   	push   %edx
  80147d:	ff d6                	call   *%esi
  80147f:	83 c4 10             	add    $0x10,%esp
  801482:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801485:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801487:	83 c7 01             	add    $0x1,%edi
  80148a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80148e:	0f be d0             	movsbl %al,%edx
  801491:	85 d2                	test   %edx,%edx
  801493:	74 4b                	je     8014e0 <vprintfmt+0x23f>
  801495:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801499:	78 06                	js     8014a1 <vprintfmt+0x200>
  80149b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80149f:	78 1e                	js     8014bf <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8014a1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014a5:	74 d1                	je     801478 <vprintfmt+0x1d7>
  8014a7:	0f be c0             	movsbl %al,%eax
  8014aa:	83 e8 20             	sub    $0x20,%eax
  8014ad:	83 f8 5e             	cmp    $0x5e,%eax
  8014b0:	76 c6                	jbe    801478 <vprintfmt+0x1d7>
					putch('?', putdat);
  8014b2:	83 ec 08             	sub    $0x8,%esp
  8014b5:	53                   	push   %ebx
  8014b6:	6a 3f                	push   $0x3f
  8014b8:	ff d6                	call   *%esi
  8014ba:	83 c4 10             	add    $0x10,%esp
  8014bd:	eb c3                	jmp    801482 <vprintfmt+0x1e1>
  8014bf:	89 cf                	mov    %ecx,%edi
  8014c1:	eb 0e                	jmp    8014d1 <vprintfmt+0x230>
				putch(' ', putdat);
  8014c3:	83 ec 08             	sub    $0x8,%esp
  8014c6:	53                   	push   %ebx
  8014c7:	6a 20                	push   $0x20
  8014c9:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8014cb:	83 ef 01             	sub    $0x1,%edi
  8014ce:	83 c4 10             	add    $0x10,%esp
  8014d1:	85 ff                	test   %edi,%edi
  8014d3:	7f ee                	jg     8014c3 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8014d5:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8014d8:	89 45 14             	mov    %eax,0x14(%ebp)
  8014db:	e9 23 01 00 00       	jmp    801603 <vprintfmt+0x362>
  8014e0:	89 cf                	mov    %ecx,%edi
  8014e2:	eb ed                	jmp    8014d1 <vprintfmt+0x230>
	if (lflag >= 2)
  8014e4:	83 f9 01             	cmp    $0x1,%ecx
  8014e7:	7f 1b                	jg     801504 <vprintfmt+0x263>
	else if (lflag)
  8014e9:	85 c9                	test   %ecx,%ecx
  8014eb:	74 63                	je     801550 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8014ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f0:	8b 00                	mov    (%eax),%eax
  8014f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f5:	99                   	cltd   
  8014f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fc:	8d 40 04             	lea    0x4(%eax),%eax
  8014ff:	89 45 14             	mov    %eax,0x14(%ebp)
  801502:	eb 17                	jmp    80151b <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  801504:	8b 45 14             	mov    0x14(%ebp),%eax
  801507:	8b 50 04             	mov    0x4(%eax),%edx
  80150a:	8b 00                	mov    (%eax),%eax
  80150c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80150f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801512:	8b 45 14             	mov    0x14(%ebp),%eax
  801515:	8d 40 08             	lea    0x8(%eax),%eax
  801518:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80151b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80151e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801521:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  801526:	85 c9                	test   %ecx,%ecx
  801528:	0f 89 bb 00 00 00    	jns    8015e9 <vprintfmt+0x348>
				putch('-', putdat);
  80152e:	83 ec 08             	sub    $0x8,%esp
  801531:	53                   	push   %ebx
  801532:	6a 2d                	push   $0x2d
  801534:	ff d6                	call   *%esi
				num = -(long long) num;
  801536:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801539:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80153c:	f7 da                	neg    %edx
  80153e:	83 d1 00             	adc    $0x0,%ecx
  801541:	f7 d9                	neg    %ecx
  801543:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801546:	b8 0a 00 00 00       	mov    $0xa,%eax
  80154b:	e9 99 00 00 00       	jmp    8015e9 <vprintfmt+0x348>
		return va_arg(*ap, int);
  801550:	8b 45 14             	mov    0x14(%ebp),%eax
  801553:	8b 00                	mov    (%eax),%eax
  801555:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801558:	99                   	cltd   
  801559:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80155c:	8b 45 14             	mov    0x14(%ebp),%eax
  80155f:	8d 40 04             	lea    0x4(%eax),%eax
  801562:	89 45 14             	mov    %eax,0x14(%ebp)
  801565:	eb b4                	jmp    80151b <vprintfmt+0x27a>
	if (lflag >= 2)
  801567:	83 f9 01             	cmp    $0x1,%ecx
  80156a:	7f 1b                	jg     801587 <vprintfmt+0x2e6>
	else if (lflag)
  80156c:	85 c9                	test   %ecx,%ecx
  80156e:	74 2c                	je     80159c <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  801570:	8b 45 14             	mov    0x14(%ebp),%eax
  801573:	8b 10                	mov    (%eax),%edx
  801575:	b9 00 00 00 00       	mov    $0x0,%ecx
  80157a:	8d 40 04             	lea    0x4(%eax),%eax
  80157d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801580:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  801585:	eb 62                	jmp    8015e9 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  801587:	8b 45 14             	mov    0x14(%ebp),%eax
  80158a:	8b 10                	mov    (%eax),%edx
  80158c:	8b 48 04             	mov    0x4(%eax),%ecx
  80158f:	8d 40 08             	lea    0x8(%eax),%eax
  801592:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801595:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80159a:	eb 4d                	jmp    8015e9 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80159c:	8b 45 14             	mov    0x14(%ebp),%eax
  80159f:	8b 10                	mov    (%eax),%edx
  8015a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015a6:	8d 40 04             	lea    0x4(%eax),%eax
  8015a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015ac:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8015b1:	eb 36                	jmp    8015e9 <vprintfmt+0x348>
	if (lflag >= 2)
  8015b3:	83 f9 01             	cmp    $0x1,%ecx
  8015b6:	7f 17                	jg     8015cf <vprintfmt+0x32e>
	else if (lflag)
  8015b8:	85 c9                	test   %ecx,%ecx
  8015ba:	74 6e                	je     80162a <vprintfmt+0x389>
		return va_arg(*ap, long);
  8015bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8015bf:	8b 10                	mov    (%eax),%edx
  8015c1:	89 d0                	mov    %edx,%eax
  8015c3:	99                   	cltd   
  8015c4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015c7:	8d 49 04             	lea    0x4(%ecx),%ecx
  8015ca:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8015cd:	eb 11                	jmp    8015e0 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8015cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d2:	8b 50 04             	mov    0x4(%eax),%edx
  8015d5:	8b 00                	mov    (%eax),%eax
  8015d7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015da:	8d 49 08             	lea    0x8(%ecx),%ecx
  8015dd:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8015e0:	89 d1                	mov    %edx,%ecx
  8015e2:	89 c2                	mov    %eax,%edx
            base = 8;
  8015e4:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8015e9:	83 ec 0c             	sub    $0xc,%esp
  8015ec:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8015f0:	57                   	push   %edi
  8015f1:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f4:	50                   	push   %eax
  8015f5:	51                   	push   %ecx
  8015f6:	52                   	push   %edx
  8015f7:	89 da                	mov    %ebx,%edx
  8015f9:	89 f0                	mov    %esi,%eax
  8015fb:	e8 b6 fb ff ff       	call   8011b6 <printnum>
			break;
  801600:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  801603:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801606:	83 c7 01             	add    $0x1,%edi
  801609:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80160d:	83 f8 25             	cmp    $0x25,%eax
  801610:	0f 84 a6 fc ff ff    	je     8012bc <vprintfmt+0x1b>
			if (ch == '\0')
  801616:	85 c0                	test   %eax,%eax
  801618:	0f 84 ce 00 00 00    	je     8016ec <vprintfmt+0x44b>
			putch(ch, putdat);
  80161e:	83 ec 08             	sub    $0x8,%esp
  801621:	53                   	push   %ebx
  801622:	50                   	push   %eax
  801623:	ff d6                	call   *%esi
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	eb dc                	jmp    801606 <vprintfmt+0x365>
		return va_arg(*ap, int);
  80162a:	8b 45 14             	mov    0x14(%ebp),%eax
  80162d:	8b 10                	mov    (%eax),%edx
  80162f:	89 d0                	mov    %edx,%eax
  801631:	99                   	cltd   
  801632:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801635:	8d 49 04             	lea    0x4(%ecx),%ecx
  801638:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80163b:	eb a3                	jmp    8015e0 <vprintfmt+0x33f>
			putch('0', putdat);
  80163d:	83 ec 08             	sub    $0x8,%esp
  801640:	53                   	push   %ebx
  801641:	6a 30                	push   $0x30
  801643:	ff d6                	call   *%esi
			putch('x', putdat);
  801645:	83 c4 08             	add    $0x8,%esp
  801648:	53                   	push   %ebx
  801649:	6a 78                	push   $0x78
  80164b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80164d:	8b 45 14             	mov    0x14(%ebp),%eax
  801650:	8b 10                	mov    (%eax),%edx
  801652:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801657:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80165a:	8d 40 04             	lea    0x4(%eax),%eax
  80165d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801660:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801665:	eb 82                	jmp    8015e9 <vprintfmt+0x348>
	if (lflag >= 2)
  801667:	83 f9 01             	cmp    $0x1,%ecx
  80166a:	7f 1e                	jg     80168a <vprintfmt+0x3e9>
	else if (lflag)
  80166c:	85 c9                	test   %ecx,%ecx
  80166e:	74 32                	je     8016a2 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  801670:	8b 45 14             	mov    0x14(%ebp),%eax
  801673:	8b 10                	mov    (%eax),%edx
  801675:	b9 00 00 00 00       	mov    $0x0,%ecx
  80167a:	8d 40 04             	lea    0x4(%eax),%eax
  80167d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801680:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  801685:	e9 5f ff ff ff       	jmp    8015e9 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80168a:	8b 45 14             	mov    0x14(%ebp),%eax
  80168d:	8b 10                	mov    (%eax),%edx
  80168f:	8b 48 04             	mov    0x4(%eax),%ecx
  801692:	8d 40 08             	lea    0x8(%eax),%eax
  801695:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801698:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80169d:	e9 47 ff ff ff       	jmp    8015e9 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8016a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8016a5:	8b 10                	mov    (%eax),%edx
  8016a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016ac:	8d 40 04             	lea    0x4(%eax),%eax
  8016af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016b2:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8016b7:	e9 2d ff ff ff       	jmp    8015e9 <vprintfmt+0x348>
			putch(ch, putdat);
  8016bc:	83 ec 08             	sub    $0x8,%esp
  8016bf:	53                   	push   %ebx
  8016c0:	6a 25                	push   $0x25
  8016c2:	ff d6                	call   *%esi
			break;
  8016c4:	83 c4 10             	add    $0x10,%esp
  8016c7:	e9 37 ff ff ff       	jmp    801603 <vprintfmt+0x362>
			putch('%', putdat);
  8016cc:	83 ec 08             	sub    $0x8,%esp
  8016cf:	53                   	push   %ebx
  8016d0:	6a 25                	push   $0x25
  8016d2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8016d4:	83 c4 10             	add    $0x10,%esp
  8016d7:	89 f8                	mov    %edi,%eax
  8016d9:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8016dd:	74 05                	je     8016e4 <vprintfmt+0x443>
  8016df:	83 e8 01             	sub    $0x1,%eax
  8016e2:	eb f5                	jmp    8016d9 <vprintfmt+0x438>
  8016e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016e7:	e9 17 ff ff ff       	jmp    801603 <vprintfmt+0x362>
}
  8016ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ef:	5b                   	pop    %ebx
  8016f0:	5e                   	pop    %esi
  8016f1:	5f                   	pop    %edi
  8016f2:	5d                   	pop    %ebp
  8016f3:	c3                   	ret    

008016f4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8016f4:	f3 0f 1e fb          	endbr32 
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	83 ec 18             	sub    $0x18,%esp
  8016fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801701:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801704:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801707:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80170b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80170e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801715:	85 c0                	test   %eax,%eax
  801717:	74 26                	je     80173f <vsnprintf+0x4b>
  801719:	85 d2                	test   %edx,%edx
  80171b:	7e 22                	jle    80173f <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80171d:	ff 75 14             	pushl  0x14(%ebp)
  801720:	ff 75 10             	pushl  0x10(%ebp)
  801723:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801726:	50                   	push   %eax
  801727:	68 5f 12 80 00       	push   $0x80125f
  80172c:	e8 70 fb ff ff       	call   8012a1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801731:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801734:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801737:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80173a:	83 c4 10             	add    $0x10,%esp
}
  80173d:	c9                   	leave  
  80173e:	c3                   	ret    
		return -E_INVAL;
  80173f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801744:	eb f7                	jmp    80173d <vsnprintf+0x49>

00801746 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801746:	f3 0f 1e fb          	endbr32 
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801750:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801753:	50                   	push   %eax
  801754:	ff 75 10             	pushl  0x10(%ebp)
  801757:	ff 75 0c             	pushl  0xc(%ebp)
  80175a:	ff 75 08             	pushl  0x8(%ebp)
  80175d:	e8 92 ff ff ff       	call   8016f4 <vsnprintf>
	va_end(ap);

	return rc;
}
  801762:	c9                   	leave  
  801763:	c3                   	ret    

00801764 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801764:	f3 0f 1e fb          	endbr32 
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80176e:	b8 00 00 00 00       	mov    $0x0,%eax
  801773:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801777:	74 05                	je     80177e <strlen+0x1a>
		n++;
  801779:	83 c0 01             	add    $0x1,%eax
  80177c:	eb f5                	jmp    801773 <strlen+0xf>
	return n;
}
  80177e:	5d                   	pop    %ebp
  80177f:	c3                   	ret    

00801780 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801780:	f3 0f 1e fb          	endbr32 
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80178a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80178d:	b8 00 00 00 00       	mov    $0x0,%eax
  801792:	39 d0                	cmp    %edx,%eax
  801794:	74 0d                	je     8017a3 <strnlen+0x23>
  801796:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80179a:	74 05                	je     8017a1 <strnlen+0x21>
		n++;
  80179c:	83 c0 01             	add    $0x1,%eax
  80179f:	eb f1                	jmp    801792 <strnlen+0x12>
  8017a1:	89 c2                	mov    %eax,%edx
	return n;
}
  8017a3:	89 d0                	mov    %edx,%eax
  8017a5:	5d                   	pop    %ebp
  8017a6:	c3                   	ret    

008017a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8017a7:	f3 0f 1e fb          	endbr32 
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	53                   	push   %ebx
  8017af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8017b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ba:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8017be:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8017c1:	83 c0 01             	add    $0x1,%eax
  8017c4:	84 d2                	test   %dl,%dl
  8017c6:	75 f2                	jne    8017ba <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8017c8:	89 c8                	mov    %ecx,%eax
  8017ca:	5b                   	pop    %ebx
  8017cb:	5d                   	pop    %ebp
  8017cc:	c3                   	ret    

008017cd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017cd:	f3 0f 1e fb          	endbr32 
  8017d1:	55                   	push   %ebp
  8017d2:	89 e5                	mov    %esp,%ebp
  8017d4:	53                   	push   %ebx
  8017d5:	83 ec 10             	sub    $0x10,%esp
  8017d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8017db:	53                   	push   %ebx
  8017dc:	e8 83 ff ff ff       	call   801764 <strlen>
  8017e1:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8017e4:	ff 75 0c             	pushl  0xc(%ebp)
  8017e7:	01 d8                	add    %ebx,%eax
  8017e9:	50                   	push   %eax
  8017ea:	e8 b8 ff ff ff       	call   8017a7 <strcpy>
	return dst;
}
  8017ef:	89 d8                	mov    %ebx,%eax
  8017f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f4:	c9                   	leave  
  8017f5:	c3                   	ret    

008017f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8017f6:	f3 0f 1e fb          	endbr32 
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	56                   	push   %esi
  8017fe:	53                   	push   %ebx
  8017ff:	8b 75 08             	mov    0x8(%ebp),%esi
  801802:	8b 55 0c             	mov    0xc(%ebp),%edx
  801805:	89 f3                	mov    %esi,%ebx
  801807:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80180a:	89 f0                	mov    %esi,%eax
  80180c:	39 d8                	cmp    %ebx,%eax
  80180e:	74 11                	je     801821 <strncpy+0x2b>
		*dst++ = *src;
  801810:	83 c0 01             	add    $0x1,%eax
  801813:	0f b6 0a             	movzbl (%edx),%ecx
  801816:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801819:	80 f9 01             	cmp    $0x1,%cl
  80181c:	83 da ff             	sbb    $0xffffffff,%edx
  80181f:	eb eb                	jmp    80180c <strncpy+0x16>
	}
	return ret;
}
  801821:	89 f0                	mov    %esi,%eax
  801823:	5b                   	pop    %ebx
  801824:	5e                   	pop    %esi
  801825:	5d                   	pop    %ebp
  801826:	c3                   	ret    

00801827 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801827:	f3 0f 1e fb          	endbr32 
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	56                   	push   %esi
  80182f:	53                   	push   %ebx
  801830:	8b 75 08             	mov    0x8(%ebp),%esi
  801833:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801836:	8b 55 10             	mov    0x10(%ebp),%edx
  801839:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80183b:	85 d2                	test   %edx,%edx
  80183d:	74 21                	je     801860 <strlcpy+0x39>
  80183f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801843:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801845:	39 c2                	cmp    %eax,%edx
  801847:	74 14                	je     80185d <strlcpy+0x36>
  801849:	0f b6 19             	movzbl (%ecx),%ebx
  80184c:	84 db                	test   %bl,%bl
  80184e:	74 0b                	je     80185b <strlcpy+0x34>
			*dst++ = *src++;
  801850:	83 c1 01             	add    $0x1,%ecx
  801853:	83 c2 01             	add    $0x1,%edx
  801856:	88 5a ff             	mov    %bl,-0x1(%edx)
  801859:	eb ea                	jmp    801845 <strlcpy+0x1e>
  80185b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80185d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801860:	29 f0                	sub    %esi,%eax
}
  801862:	5b                   	pop    %ebx
  801863:	5e                   	pop    %esi
  801864:	5d                   	pop    %ebp
  801865:	c3                   	ret    

00801866 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801866:	f3 0f 1e fb          	endbr32 
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801870:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801873:	0f b6 01             	movzbl (%ecx),%eax
  801876:	84 c0                	test   %al,%al
  801878:	74 0c                	je     801886 <strcmp+0x20>
  80187a:	3a 02                	cmp    (%edx),%al
  80187c:	75 08                	jne    801886 <strcmp+0x20>
		p++, q++;
  80187e:	83 c1 01             	add    $0x1,%ecx
  801881:	83 c2 01             	add    $0x1,%edx
  801884:	eb ed                	jmp    801873 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801886:	0f b6 c0             	movzbl %al,%eax
  801889:	0f b6 12             	movzbl (%edx),%edx
  80188c:	29 d0                	sub    %edx,%eax
}
  80188e:	5d                   	pop    %ebp
  80188f:	c3                   	ret    

00801890 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801890:	f3 0f 1e fb          	endbr32 
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	53                   	push   %ebx
  801898:	8b 45 08             	mov    0x8(%ebp),%eax
  80189b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80189e:	89 c3                	mov    %eax,%ebx
  8018a0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8018a3:	eb 06                	jmp    8018ab <strncmp+0x1b>
		n--, p++, q++;
  8018a5:	83 c0 01             	add    $0x1,%eax
  8018a8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8018ab:	39 d8                	cmp    %ebx,%eax
  8018ad:	74 16                	je     8018c5 <strncmp+0x35>
  8018af:	0f b6 08             	movzbl (%eax),%ecx
  8018b2:	84 c9                	test   %cl,%cl
  8018b4:	74 04                	je     8018ba <strncmp+0x2a>
  8018b6:	3a 0a                	cmp    (%edx),%cl
  8018b8:	74 eb                	je     8018a5 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8018ba:	0f b6 00             	movzbl (%eax),%eax
  8018bd:	0f b6 12             	movzbl (%edx),%edx
  8018c0:	29 d0                	sub    %edx,%eax
}
  8018c2:	5b                   	pop    %ebx
  8018c3:	5d                   	pop    %ebp
  8018c4:	c3                   	ret    
		return 0;
  8018c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ca:	eb f6                	jmp    8018c2 <strncmp+0x32>

008018cc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8018cc:	f3 0f 1e fb          	endbr32 
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018da:	0f b6 10             	movzbl (%eax),%edx
  8018dd:	84 d2                	test   %dl,%dl
  8018df:	74 09                	je     8018ea <strchr+0x1e>
		if (*s == c)
  8018e1:	38 ca                	cmp    %cl,%dl
  8018e3:	74 0a                	je     8018ef <strchr+0x23>
	for (; *s; s++)
  8018e5:	83 c0 01             	add    $0x1,%eax
  8018e8:	eb f0                	jmp    8018da <strchr+0xe>
			return (char *) s;
	return 0;
  8018ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ef:	5d                   	pop    %ebp
  8018f0:	c3                   	ret    

008018f1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8018f1:	f3 0f 1e fb          	endbr32 
  8018f5:	55                   	push   %ebp
  8018f6:	89 e5                	mov    %esp,%ebp
  8018f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018ff:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801902:	38 ca                	cmp    %cl,%dl
  801904:	74 09                	je     80190f <strfind+0x1e>
  801906:	84 d2                	test   %dl,%dl
  801908:	74 05                	je     80190f <strfind+0x1e>
	for (; *s; s++)
  80190a:	83 c0 01             	add    $0x1,%eax
  80190d:	eb f0                	jmp    8018ff <strfind+0xe>
			break;
	return (char *) s;
}
  80190f:	5d                   	pop    %ebp
  801910:	c3                   	ret    

00801911 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801911:	f3 0f 1e fb          	endbr32 
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	57                   	push   %edi
  801919:	56                   	push   %esi
  80191a:	53                   	push   %ebx
  80191b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80191e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801921:	85 c9                	test   %ecx,%ecx
  801923:	74 31                	je     801956 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801925:	89 f8                	mov    %edi,%eax
  801927:	09 c8                	or     %ecx,%eax
  801929:	a8 03                	test   $0x3,%al
  80192b:	75 23                	jne    801950 <memset+0x3f>
		c &= 0xFF;
  80192d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801931:	89 d3                	mov    %edx,%ebx
  801933:	c1 e3 08             	shl    $0x8,%ebx
  801936:	89 d0                	mov    %edx,%eax
  801938:	c1 e0 18             	shl    $0x18,%eax
  80193b:	89 d6                	mov    %edx,%esi
  80193d:	c1 e6 10             	shl    $0x10,%esi
  801940:	09 f0                	or     %esi,%eax
  801942:	09 c2                	or     %eax,%edx
  801944:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801946:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801949:	89 d0                	mov    %edx,%eax
  80194b:	fc                   	cld    
  80194c:	f3 ab                	rep stos %eax,%es:(%edi)
  80194e:	eb 06                	jmp    801956 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801950:	8b 45 0c             	mov    0xc(%ebp),%eax
  801953:	fc                   	cld    
  801954:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801956:	89 f8                	mov    %edi,%eax
  801958:	5b                   	pop    %ebx
  801959:	5e                   	pop    %esi
  80195a:	5f                   	pop    %edi
  80195b:	5d                   	pop    %ebp
  80195c:	c3                   	ret    

0080195d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80195d:	f3 0f 1e fb          	endbr32 
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	57                   	push   %edi
  801965:	56                   	push   %esi
  801966:	8b 45 08             	mov    0x8(%ebp),%eax
  801969:	8b 75 0c             	mov    0xc(%ebp),%esi
  80196c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80196f:	39 c6                	cmp    %eax,%esi
  801971:	73 32                	jae    8019a5 <memmove+0x48>
  801973:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801976:	39 c2                	cmp    %eax,%edx
  801978:	76 2b                	jbe    8019a5 <memmove+0x48>
		s += n;
		d += n;
  80197a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80197d:	89 fe                	mov    %edi,%esi
  80197f:	09 ce                	or     %ecx,%esi
  801981:	09 d6                	or     %edx,%esi
  801983:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801989:	75 0e                	jne    801999 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80198b:	83 ef 04             	sub    $0x4,%edi
  80198e:	8d 72 fc             	lea    -0x4(%edx),%esi
  801991:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801994:	fd                   	std    
  801995:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801997:	eb 09                	jmp    8019a2 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801999:	83 ef 01             	sub    $0x1,%edi
  80199c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80199f:	fd                   	std    
  8019a0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8019a2:	fc                   	cld    
  8019a3:	eb 1a                	jmp    8019bf <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019a5:	89 c2                	mov    %eax,%edx
  8019a7:	09 ca                	or     %ecx,%edx
  8019a9:	09 f2                	or     %esi,%edx
  8019ab:	f6 c2 03             	test   $0x3,%dl
  8019ae:	75 0a                	jne    8019ba <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8019b0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8019b3:	89 c7                	mov    %eax,%edi
  8019b5:	fc                   	cld    
  8019b6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019b8:	eb 05                	jmp    8019bf <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8019ba:	89 c7                	mov    %eax,%edi
  8019bc:	fc                   	cld    
  8019bd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8019bf:	5e                   	pop    %esi
  8019c0:	5f                   	pop    %edi
  8019c1:	5d                   	pop    %ebp
  8019c2:	c3                   	ret    

008019c3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8019c3:	f3 0f 1e fb          	endbr32 
  8019c7:	55                   	push   %ebp
  8019c8:	89 e5                	mov    %esp,%ebp
  8019ca:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8019cd:	ff 75 10             	pushl  0x10(%ebp)
  8019d0:	ff 75 0c             	pushl  0xc(%ebp)
  8019d3:	ff 75 08             	pushl  0x8(%ebp)
  8019d6:	e8 82 ff ff ff       	call   80195d <memmove>
}
  8019db:	c9                   	leave  
  8019dc:	c3                   	ret    

008019dd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8019dd:	f3 0f 1e fb          	endbr32 
  8019e1:	55                   	push   %ebp
  8019e2:	89 e5                	mov    %esp,%ebp
  8019e4:	56                   	push   %esi
  8019e5:	53                   	push   %ebx
  8019e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019ec:	89 c6                	mov    %eax,%esi
  8019ee:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019f1:	39 f0                	cmp    %esi,%eax
  8019f3:	74 1c                	je     801a11 <memcmp+0x34>
		if (*s1 != *s2)
  8019f5:	0f b6 08             	movzbl (%eax),%ecx
  8019f8:	0f b6 1a             	movzbl (%edx),%ebx
  8019fb:	38 d9                	cmp    %bl,%cl
  8019fd:	75 08                	jne    801a07 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8019ff:	83 c0 01             	add    $0x1,%eax
  801a02:	83 c2 01             	add    $0x1,%edx
  801a05:	eb ea                	jmp    8019f1 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801a07:	0f b6 c1             	movzbl %cl,%eax
  801a0a:	0f b6 db             	movzbl %bl,%ebx
  801a0d:	29 d8                	sub    %ebx,%eax
  801a0f:	eb 05                	jmp    801a16 <memcmp+0x39>
	}

	return 0;
  801a11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a16:	5b                   	pop    %ebx
  801a17:	5e                   	pop    %esi
  801a18:	5d                   	pop    %ebp
  801a19:	c3                   	ret    

00801a1a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a1a:	f3 0f 1e fb          	endbr32 
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	8b 45 08             	mov    0x8(%ebp),%eax
  801a24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a27:	89 c2                	mov    %eax,%edx
  801a29:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a2c:	39 d0                	cmp    %edx,%eax
  801a2e:	73 09                	jae    801a39 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a30:	38 08                	cmp    %cl,(%eax)
  801a32:	74 05                	je     801a39 <memfind+0x1f>
	for (; s < ends; s++)
  801a34:	83 c0 01             	add    $0x1,%eax
  801a37:	eb f3                	jmp    801a2c <memfind+0x12>
			break;
	return (void *) s;
}
  801a39:	5d                   	pop    %ebp
  801a3a:	c3                   	ret    

00801a3b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a3b:	f3 0f 1e fb          	endbr32 
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	57                   	push   %edi
  801a43:	56                   	push   %esi
  801a44:	53                   	push   %ebx
  801a45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a48:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a4b:	eb 03                	jmp    801a50 <strtol+0x15>
		s++;
  801a4d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801a50:	0f b6 01             	movzbl (%ecx),%eax
  801a53:	3c 20                	cmp    $0x20,%al
  801a55:	74 f6                	je     801a4d <strtol+0x12>
  801a57:	3c 09                	cmp    $0x9,%al
  801a59:	74 f2                	je     801a4d <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801a5b:	3c 2b                	cmp    $0x2b,%al
  801a5d:	74 2a                	je     801a89 <strtol+0x4e>
	int neg = 0;
  801a5f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801a64:	3c 2d                	cmp    $0x2d,%al
  801a66:	74 2b                	je     801a93 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a68:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a6e:	75 0f                	jne    801a7f <strtol+0x44>
  801a70:	80 39 30             	cmpb   $0x30,(%ecx)
  801a73:	74 28                	je     801a9d <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a75:	85 db                	test   %ebx,%ebx
  801a77:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a7c:	0f 44 d8             	cmove  %eax,%ebx
  801a7f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a84:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801a87:	eb 46                	jmp    801acf <strtol+0x94>
		s++;
  801a89:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801a8c:	bf 00 00 00 00       	mov    $0x0,%edi
  801a91:	eb d5                	jmp    801a68 <strtol+0x2d>
		s++, neg = 1;
  801a93:	83 c1 01             	add    $0x1,%ecx
  801a96:	bf 01 00 00 00       	mov    $0x1,%edi
  801a9b:	eb cb                	jmp    801a68 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a9d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801aa1:	74 0e                	je     801ab1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801aa3:	85 db                	test   %ebx,%ebx
  801aa5:	75 d8                	jne    801a7f <strtol+0x44>
		s++, base = 8;
  801aa7:	83 c1 01             	add    $0x1,%ecx
  801aaa:	bb 08 00 00 00       	mov    $0x8,%ebx
  801aaf:	eb ce                	jmp    801a7f <strtol+0x44>
		s += 2, base = 16;
  801ab1:	83 c1 02             	add    $0x2,%ecx
  801ab4:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ab9:	eb c4                	jmp    801a7f <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801abb:	0f be d2             	movsbl %dl,%edx
  801abe:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801ac1:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ac4:	7d 3a                	jge    801b00 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801ac6:	83 c1 01             	add    $0x1,%ecx
  801ac9:	0f af 45 10          	imul   0x10(%ebp),%eax
  801acd:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801acf:	0f b6 11             	movzbl (%ecx),%edx
  801ad2:	8d 72 d0             	lea    -0x30(%edx),%esi
  801ad5:	89 f3                	mov    %esi,%ebx
  801ad7:	80 fb 09             	cmp    $0x9,%bl
  801ada:	76 df                	jbe    801abb <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801adc:	8d 72 9f             	lea    -0x61(%edx),%esi
  801adf:	89 f3                	mov    %esi,%ebx
  801ae1:	80 fb 19             	cmp    $0x19,%bl
  801ae4:	77 08                	ja     801aee <strtol+0xb3>
			dig = *s - 'a' + 10;
  801ae6:	0f be d2             	movsbl %dl,%edx
  801ae9:	83 ea 57             	sub    $0x57,%edx
  801aec:	eb d3                	jmp    801ac1 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801aee:	8d 72 bf             	lea    -0x41(%edx),%esi
  801af1:	89 f3                	mov    %esi,%ebx
  801af3:	80 fb 19             	cmp    $0x19,%bl
  801af6:	77 08                	ja     801b00 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801af8:	0f be d2             	movsbl %dl,%edx
  801afb:	83 ea 37             	sub    $0x37,%edx
  801afe:	eb c1                	jmp    801ac1 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801b00:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b04:	74 05                	je     801b0b <strtol+0xd0>
		*endptr = (char *) s;
  801b06:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b09:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801b0b:	89 c2                	mov    %eax,%edx
  801b0d:	f7 da                	neg    %edx
  801b0f:	85 ff                	test   %edi,%edi
  801b11:	0f 45 c2             	cmovne %edx,%eax
}
  801b14:	5b                   	pop    %ebx
  801b15:	5e                   	pop    %esi
  801b16:	5f                   	pop    %edi
  801b17:	5d                   	pop    %ebp
  801b18:	c3                   	ret    

00801b19 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b19:	f3 0f 1e fb          	endbr32 
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	56                   	push   %esi
  801b21:	53                   	push   %ebx
  801b22:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b28:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b32:	0f 44 c2             	cmove  %edx,%eax
  801b35:	83 ec 0c             	sub    $0xc,%esp
  801b38:	50                   	push   %eax
  801b39:	e8 1b e8 ff ff       	call   800359 <sys_ipc_recv>
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	85 c0                	test   %eax,%eax
  801b43:	78 24                	js     801b69 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801b45:	85 f6                	test   %esi,%esi
  801b47:	74 0a                	je     801b53 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801b49:	a1 04 40 80 00       	mov    0x804004,%eax
  801b4e:	8b 40 78             	mov    0x78(%eax),%eax
  801b51:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801b53:	85 db                	test   %ebx,%ebx
  801b55:	74 0a                	je     801b61 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801b57:	a1 04 40 80 00       	mov    0x804004,%eax
  801b5c:	8b 40 74             	mov    0x74(%eax),%eax
  801b5f:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801b61:	a1 04 40 80 00       	mov    0x804004,%eax
  801b66:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b69:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b6c:	5b                   	pop    %ebx
  801b6d:	5e                   	pop    %esi
  801b6e:	5d                   	pop    %ebp
  801b6f:	c3                   	ret    

00801b70 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b70:	f3 0f 1e fb          	endbr32 
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	57                   	push   %edi
  801b78:	56                   	push   %esi
  801b79:	53                   	push   %ebx
  801b7a:	83 ec 1c             	sub    $0x1c,%esp
  801b7d:	8b 45 10             	mov    0x10(%ebp),%eax
  801b80:	85 c0                	test   %eax,%eax
  801b82:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b87:	0f 45 d0             	cmovne %eax,%edx
  801b8a:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801b8c:	be 01 00 00 00       	mov    $0x1,%esi
  801b91:	eb 1f                	jmp    801bb2 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801b93:	e8 d2 e5 ff ff       	call   80016a <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801b98:	83 c3 01             	add    $0x1,%ebx
  801b9b:	39 de                	cmp    %ebx,%esi
  801b9d:	7f f4                	jg     801b93 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801b9f:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801ba1:	83 fe 11             	cmp    $0x11,%esi
  801ba4:	b8 01 00 00 00       	mov    $0x1,%eax
  801ba9:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801bac:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801bb0:	75 1c                	jne    801bce <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801bb2:	ff 75 14             	pushl  0x14(%ebp)
  801bb5:	57                   	push   %edi
  801bb6:	ff 75 0c             	pushl  0xc(%ebp)
  801bb9:	ff 75 08             	pushl  0x8(%ebp)
  801bbc:	e8 71 e7 ff ff       	call   800332 <sys_ipc_try_send>
  801bc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801bc4:	83 c4 10             	add    $0x10,%esp
  801bc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bcc:	eb cd                	jmp    801b9b <ipc_send+0x2b>
}
  801bce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd1:	5b                   	pop    %ebx
  801bd2:	5e                   	pop    %esi
  801bd3:	5f                   	pop    %edi
  801bd4:	5d                   	pop    %ebp
  801bd5:	c3                   	ret    

00801bd6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bd6:	f3 0f 1e fb          	endbr32 
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801be0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801be5:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801be8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bee:	8b 52 50             	mov    0x50(%edx),%edx
  801bf1:	39 ca                	cmp    %ecx,%edx
  801bf3:	74 11                	je     801c06 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801bf5:	83 c0 01             	add    $0x1,%eax
  801bf8:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bfd:	75 e6                	jne    801be5 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801bff:	b8 00 00 00 00       	mov    $0x0,%eax
  801c04:	eb 0b                	jmp    801c11 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c06:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c09:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c0e:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c11:	5d                   	pop    %ebp
  801c12:	c3                   	ret    

00801c13 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c13:	f3 0f 1e fb          	endbr32 
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c1d:	89 c2                	mov    %eax,%edx
  801c1f:	c1 ea 16             	shr    $0x16,%edx
  801c22:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c29:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c2e:	f6 c1 01             	test   $0x1,%cl
  801c31:	74 1c                	je     801c4f <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c33:	c1 e8 0c             	shr    $0xc,%eax
  801c36:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c3d:	a8 01                	test   $0x1,%al
  801c3f:	74 0e                	je     801c4f <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c41:	c1 e8 0c             	shr    $0xc,%eax
  801c44:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c4b:	ef 
  801c4c:	0f b7 d2             	movzwl %dx,%edx
}
  801c4f:	89 d0                	mov    %edx,%eax
  801c51:	5d                   	pop    %ebp
  801c52:	c3                   	ret    
  801c53:	66 90                	xchg   %ax,%ax
  801c55:	66 90                	xchg   %ax,%ax
  801c57:	66 90                	xchg   %ax,%ax
  801c59:	66 90                	xchg   %ax,%ax
  801c5b:	66 90                	xchg   %ax,%ax
  801c5d:	66 90                	xchg   %ax,%ax
  801c5f:	90                   	nop

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
