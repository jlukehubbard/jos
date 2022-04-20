
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	f3 0f 1e fb          	endbr32 
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    envid_t envid = sys_getenvid();
  800049:	e8 d6 00 00 00       	call   800124 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x31>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	f3 0f 1e fb          	endbr32 
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008e:	6a 00                	push   $0x0
  800090:	e8 4a 00 00 00       	call   8000df <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	f3 0f 1e fb          	endbr32 
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	f3 0f 1e fb          	endbr32 
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	f3 0f 1e fb          	endbr32 
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f9:	89 cb                	mov    %ecx,%ebx
  8000fb:	89 cf                	mov    %ecx,%edi
  8000fd:	89 ce                	mov    %ecx,%esi
  8000ff:	cd 30                	int    $0x30
	if(check && ret > 0)
  800101:	85 c0                	test   %eax,%eax
  800103:	7f 08                	jg     80010d <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 03                	push   $0x3
  800113:	68 0a 10 80 00       	push   $0x80100a
  800118:	6a 23                	push   $0x23
  80011a:	68 27 10 80 00       	push   $0x801027
  80011f:	e8 11 02 00 00       	call   800335 <_panic>

00800124 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800124:	f3 0f 1e fb          	endbr32 
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 d1                	mov    %edx,%ecx
  80013a:	89 d3                	mov    %edx,%ebx
  80013c:	89 d7                	mov    %edx,%edi
  80013e:	89 d6                	mov    %edx,%esi
  800140:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_yield>:

void
sys_yield(void)
{
  800147:	f3 0f 1e fb          	endbr32 
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 0a 00 00 00       	mov    $0xa,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016a:	f3 0f 1e fb          	endbr32 
  80016e:	55                   	push   %ebp
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	57                   	push   %edi
  800172:	56                   	push   %esi
  800173:	53                   	push   %ebx
  800174:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800177:	be 00 00 00 00       	mov    $0x0,%esi
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800182:	b8 04 00 00 00       	mov    $0x4,%eax
  800187:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018a:	89 f7                	mov    %esi,%edi
  80018c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80018e:	85 c0                	test   %eax,%eax
  800190:	7f 08                	jg     80019a <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800192:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800195:	5b                   	pop    %ebx
  800196:	5e                   	pop    %esi
  800197:	5f                   	pop    %edi
  800198:	5d                   	pop    %ebp
  800199:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80019a:	83 ec 0c             	sub    $0xc,%esp
  80019d:	50                   	push   %eax
  80019e:	6a 04                	push   $0x4
  8001a0:	68 0a 10 80 00       	push   $0x80100a
  8001a5:	6a 23                	push   $0x23
  8001a7:	68 27 10 80 00       	push   $0x801027
  8001ac:	e8 84 01 00 00       	call   800335 <_panic>

008001b1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b1:	f3 0f 1e fb          	endbr32 
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	57                   	push   %edi
  8001b9:	56                   	push   %esi
  8001ba:	53                   	push   %ebx
  8001bb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001be:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cf:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001d4:	85 c0                	test   %eax,%eax
  8001d6:	7f 08                	jg     8001e0 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5f                   	pop    %edi
  8001de:	5d                   	pop    %ebp
  8001df:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e0:	83 ec 0c             	sub    $0xc,%esp
  8001e3:	50                   	push   %eax
  8001e4:	6a 05                	push   $0x5
  8001e6:	68 0a 10 80 00       	push   $0x80100a
  8001eb:	6a 23                	push   $0x23
  8001ed:	68 27 10 80 00       	push   $0x801027
  8001f2:	e8 3e 01 00 00       	call   800335 <_panic>

008001f7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f7:	f3 0f 1e fb          	endbr32 
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	57                   	push   %edi
  8001ff:	56                   	push   %esi
  800200:	53                   	push   %ebx
  800201:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800204:	bb 00 00 00 00       	mov    $0x0,%ebx
  800209:	8b 55 08             	mov    0x8(%ebp),%edx
  80020c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020f:	b8 06 00 00 00       	mov    $0x6,%eax
  800214:	89 df                	mov    %ebx,%edi
  800216:	89 de                	mov    %ebx,%esi
  800218:	cd 30                	int    $0x30
	if(check && ret > 0)
  80021a:	85 c0                	test   %eax,%eax
  80021c:	7f 08                	jg     800226 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800221:	5b                   	pop    %ebx
  800222:	5e                   	pop    %esi
  800223:	5f                   	pop    %edi
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800226:	83 ec 0c             	sub    $0xc,%esp
  800229:	50                   	push   %eax
  80022a:	6a 06                	push   $0x6
  80022c:	68 0a 10 80 00       	push   $0x80100a
  800231:	6a 23                	push   $0x23
  800233:	68 27 10 80 00       	push   $0x801027
  800238:	e8 f8 00 00 00       	call   800335 <_panic>

0080023d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80023d:	f3 0f 1e fb          	endbr32 
  800241:	55                   	push   %ebp
  800242:	89 e5                	mov    %esp,%ebp
  800244:	57                   	push   %edi
  800245:	56                   	push   %esi
  800246:	53                   	push   %ebx
  800247:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80024a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024f:	8b 55 08             	mov    0x8(%ebp),%edx
  800252:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800255:	b8 08 00 00 00       	mov    $0x8,%eax
  80025a:	89 df                	mov    %ebx,%edi
  80025c:	89 de                	mov    %ebx,%esi
  80025e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800260:	85 c0                	test   %eax,%eax
  800262:	7f 08                	jg     80026c <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	50                   	push   %eax
  800270:	6a 08                	push   $0x8
  800272:	68 0a 10 80 00       	push   $0x80100a
  800277:	6a 23                	push   $0x23
  800279:	68 27 10 80 00       	push   $0x801027
  80027e:	e8 b2 00 00 00       	call   800335 <_panic>

00800283 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800283:	f3 0f 1e fb          	endbr32 
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	57                   	push   %edi
  80028b:	56                   	push   %esi
  80028c:	53                   	push   %ebx
  80028d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800290:	bb 00 00 00 00       	mov    $0x0,%ebx
  800295:	8b 55 08             	mov    0x8(%ebp),%edx
  800298:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029b:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a0:	89 df                	mov    %ebx,%edi
  8002a2:	89 de                	mov    %ebx,%esi
  8002a4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002a6:	85 c0                	test   %eax,%eax
  8002a8:	7f 08                	jg     8002b2 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ad:	5b                   	pop    %ebx
  8002ae:	5e                   	pop    %esi
  8002af:	5f                   	pop    %edi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b2:	83 ec 0c             	sub    $0xc,%esp
  8002b5:	50                   	push   %eax
  8002b6:	6a 09                	push   $0x9
  8002b8:	68 0a 10 80 00       	push   $0x80100a
  8002bd:	6a 23                	push   $0x23
  8002bf:	68 27 10 80 00       	push   $0x801027
  8002c4:	e8 6c 00 00 00       	call   800335 <_panic>

008002c9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002c9:	f3 0f 1e fb          	endbr32 
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	57                   	push   %edi
  8002d1:	56                   	push   %esi
  8002d2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002de:	be 00 00 00 00       	mov    $0x0,%esi
  8002e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002e6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002e9:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002f0:	f3 0f 1e fb          	endbr32 
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	57                   	push   %edi
  8002f8:	56                   	push   %esi
  8002f9:	53                   	push   %ebx
  8002fa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800302:	8b 55 08             	mov    0x8(%ebp),%edx
  800305:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030a:	89 cb                	mov    %ecx,%ebx
  80030c:	89 cf                	mov    %ecx,%edi
  80030e:	89 ce                	mov    %ecx,%esi
  800310:	cd 30                	int    $0x30
	if(check && ret > 0)
  800312:	85 c0                	test   %eax,%eax
  800314:	7f 08                	jg     80031e <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
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
  800322:	6a 0c                	push   $0xc
  800324:	68 0a 10 80 00       	push   $0x80100a
  800329:	6a 23                	push   $0x23
  80032b:	68 27 10 80 00       	push   $0x801027
  800330:	e8 00 00 00 00       	call   800335 <_panic>

00800335 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800335:	f3 0f 1e fb          	endbr32 
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	56                   	push   %esi
  80033d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80033e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800341:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800347:	e8 d8 fd ff ff       	call   800124 <sys_getenvid>
  80034c:	83 ec 0c             	sub    $0xc,%esp
  80034f:	ff 75 0c             	pushl  0xc(%ebp)
  800352:	ff 75 08             	pushl  0x8(%ebp)
  800355:	56                   	push   %esi
  800356:	50                   	push   %eax
  800357:	68 38 10 80 00       	push   $0x801038
  80035c:	e8 bb 00 00 00       	call   80041c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800361:	83 c4 18             	add    $0x18,%esp
  800364:	53                   	push   %ebx
  800365:	ff 75 10             	pushl  0x10(%ebp)
  800368:	e8 5a 00 00 00       	call   8003c7 <vcprintf>
	cprintf("\n");
  80036d:	c7 04 24 5b 10 80 00 	movl   $0x80105b,(%esp)
  800374:	e8 a3 00 00 00       	call   80041c <cprintf>
  800379:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80037c:	cc                   	int3   
  80037d:	eb fd                	jmp    80037c <_panic+0x47>

0080037f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80037f:	f3 0f 1e fb          	endbr32 
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	53                   	push   %ebx
  800387:	83 ec 04             	sub    $0x4,%esp
  80038a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038d:	8b 13                	mov    (%ebx),%edx
  80038f:	8d 42 01             	lea    0x1(%edx),%eax
  800392:	89 03                	mov    %eax,(%ebx)
  800394:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800397:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80039b:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a0:	74 09                	je     8003ab <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003a2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a9:	c9                   	leave  
  8003aa:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003ab:	83 ec 08             	sub    $0x8,%esp
  8003ae:	68 ff 00 00 00       	push   $0xff
  8003b3:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b6:	50                   	push   %eax
  8003b7:	e8 de fc ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  8003bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003c2:	83 c4 10             	add    $0x10,%esp
  8003c5:	eb db                	jmp    8003a2 <putch+0x23>

008003c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c7:	f3 0f 1e fb          	endbr32 
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003db:	00 00 00 
	b.cnt = 0;
  8003de:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e8:	ff 75 0c             	pushl  0xc(%ebp)
  8003eb:	ff 75 08             	pushl  0x8(%ebp)
  8003ee:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f4:	50                   	push   %eax
  8003f5:	68 7f 03 80 00       	push   $0x80037f
  8003fa:	e8 20 01 00 00       	call   80051f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ff:	83 c4 08             	add    $0x8,%esp
  800402:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800408:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80040e:	50                   	push   %eax
  80040f:	e8 86 fc ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  800414:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80041a:	c9                   	leave  
  80041b:	c3                   	ret    

0080041c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80041c:	f3 0f 1e fb          	endbr32 
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800426:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800429:	50                   	push   %eax
  80042a:	ff 75 08             	pushl  0x8(%ebp)
  80042d:	e8 95 ff ff ff       	call   8003c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800432:	c9                   	leave  
  800433:	c3                   	ret    

00800434 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	57                   	push   %edi
  800438:	56                   	push   %esi
  800439:	53                   	push   %ebx
  80043a:	83 ec 1c             	sub    $0x1c,%esp
  80043d:	89 c7                	mov    %eax,%edi
  80043f:	89 d6                	mov    %edx,%esi
  800441:	8b 45 08             	mov    0x8(%ebp),%eax
  800444:	8b 55 0c             	mov    0xc(%ebp),%edx
  800447:	89 d1                	mov    %edx,%ecx
  800449:	89 c2                	mov    %eax,%edx
  80044b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80044e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800451:	8b 45 10             	mov    0x10(%ebp),%eax
  800454:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800457:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800461:	39 c2                	cmp    %eax,%edx
  800463:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800466:	72 3e                	jb     8004a6 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800468:	83 ec 0c             	sub    $0xc,%esp
  80046b:	ff 75 18             	pushl  0x18(%ebp)
  80046e:	83 eb 01             	sub    $0x1,%ebx
  800471:	53                   	push   %ebx
  800472:	50                   	push   %eax
  800473:	83 ec 08             	sub    $0x8,%esp
  800476:	ff 75 e4             	pushl  -0x1c(%ebp)
  800479:	ff 75 e0             	pushl  -0x20(%ebp)
  80047c:	ff 75 dc             	pushl  -0x24(%ebp)
  80047f:	ff 75 d8             	pushl  -0x28(%ebp)
  800482:	e8 19 09 00 00       	call   800da0 <__udivdi3>
  800487:	83 c4 18             	add    $0x18,%esp
  80048a:	52                   	push   %edx
  80048b:	50                   	push   %eax
  80048c:	89 f2                	mov    %esi,%edx
  80048e:	89 f8                	mov    %edi,%eax
  800490:	e8 9f ff ff ff       	call   800434 <printnum>
  800495:	83 c4 20             	add    $0x20,%esp
  800498:	eb 13                	jmp    8004ad <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80049a:	83 ec 08             	sub    $0x8,%esp
  80049d:	56                   	push   %esi
  80049e:	ff 75 18             	pushl  0x18(%ebp)
  8004a1:	ff d7                	call   *%edi
  8004a3:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004a6:	83 eb 01             	sub    $0x1,%ebx
  8004a9:	85 db                	test   %ebx,%ebx
  8004ab:	7f ed                	jg     80049a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	56                   	push   %esi
  8004b1:	83 ec 04             	sub    $0x4,%esp
  8004b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ba:	ff 75 dc             	pushl  -0x24(%ebp)
  8004bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c0:	e8 eb 09 00 00       	call   800eb0 <__umoddi3>
  8004c5:	83 c4 14             	add    $0x14,%esp
  8004c8:	0f be 80 5d 10 80 00 	movsbl 0x80105d(%eax),%eax
  8004cf:	50                   	push   %eax
  8004d0:	ff d7                	call   *%edi
}
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d8:	5b                   	pop    %ebx
  8004d9:	5e                   	pop    %esi
  8004da:	5f                   	pop    %edi
  8004db:	5d                   	pop    %ebp
  8004dc:	c3                   	ret    

008004dd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004dd:	f3 0f 1e fb          	endbr32 
  8004e1:	55                   	push   %ebp
  8004e2:	89 e5                	mov    %esp,%ebp
  8004e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004eb:	8b 10                	mov    (%eax),%edx
  8004ed:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f0:	73 0a                	jae    8004fc <sprintputch+0x1f>
		*b->buf++ = ch;
  8004f2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f5:	89 08                	mov    %ecx,(%eax)
  8004f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fa:	88 02                	mov    %al,(%edx)
}
  8004fc:	5d                   	pop    %ebp
  8004fd:	c3                   	ret    

008004fe <printfmt>:
{
  8004fe:	f3 0f 1e fb          	endbr32 
  800502:	55                   	push   %ebp
  800503:	89 e5                	mov    %esp,%ebp
  800505:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800508:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050b:	50                   	push   %eax
  80050c:	ff 75 10             	pushl  0x10(%ebp)
  80050f:	ff 75 0c             	pushl  0xc(%ebp)
  800512:	ff 75 08             	pushl  0x8(%ebp)
  800515:	e8 05 00 00 00       	call   80051f <vprintfmt>
}
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	c9                   	leave  
  80051e:	c3                   	ret    

0080051f <vprintfmt>:
{
  80051f:	f3 0f 1e fb          	endbr32 
  800523:	55                   	push   %ebp
  800524:	89 e5                	mov    %esp,%ebp
  800526:	57                   	push   %edi
  800527:	56                   	push   %esi
  800528:	53                   	push   %ebx
  800529:	83 ec 3c             	sub    $0x3c,%esp
  80052c:	8b 75 08             	mov    0x8(%ebp),%esi
  80052f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800532:	8b 7d 10             	mov    0x10(%ebp),%edi
  800535:	e9 4a 03 00 00       	jmp    800884 <vprintfmt+0x365>
		padc = ' ';
  80053a:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80053e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800545:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80054c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800553:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800558:	8d 47 01             	lea    0x1(%edi),%eax
  80055b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80055e:	0f b6 17             	movzbl (%edi),%edx
  800561:	8d 42 dd             	lea    -0x23(%edx),%eax
  800564:	3c 55                	cmp    $0x55,%al
  800566:	0f 87 de 03 00 00    	ja     80094a <vprintfmt+0x42b>
  80056c:	0f b6 c0             	movzbl %al,%eax
  80056f:	3e ff 24 85 20 11 80 	notrack jmp *0x801120(,%eax,4)
  800576:	00 
  800577:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80057a:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80057e:	eb d8                	jmp    800558 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800580:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800583:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800587:	eb cf                	jmp    800558 <vprintfmt+0x39>
  800589:	0f b6 d2             	movzbl %dl,%edx
  80058c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80058f:	b8 00 00 00 00       	mov    $0x0,%eax
  800594:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800597:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80059a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80059e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005a1:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005a4:	83 f9 09             	cmp    $0x9,%ecx
  8005a7:	77 55                	ja     8005fe <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005a9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005ac:	eb e9                	jmp    800597 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8b 00                	mov    (%eax),%eax
  8005b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 40 04             	lea    0x4(%eax),%eax
  8005bc:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005c2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c6:	79 90                	jns    800558 <vprintfmt+0x39>
				width = precision, precision = -1;
  8005c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ce:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005d5:	eb 81                	jmp    800558 <vprintfmt+0x39>
  8005d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005da:	85 c0                	test   %eax,%eax
  8005dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e1:	0f 49 d0             	cmovns %eax,%edx
  8005e4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005ea:	e9 69 ff ff ff       	jmp    800558 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005f2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005f9:	e9 5a ff ff ff       	jmp    800558 <vprintfmt+0x39>
  8005fe:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800601:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800604:	eb bc                	jmp    8005c2 <vprintfmt+0xa3>
			lflag++;
  800606:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800609:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80060c:	e9 47 ff ff ff       	jmp    800558 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8d 78 04             	lea    0x4(%eax),%edi
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	53                   	push   %ebx
  80061b:	ff 30                	pushl  (%eax)
  80061d:	ff d6                	call   *%esi
			break;
  80061f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800622:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800625:	e9 57 02 00 00       	jmp    800881 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8d 78 04             	lea    0x4(%eax),%edi
  800630:	8b 00                	mov    (%eax),%eax
  800632:	99                   	cltd   
  800633:	31 d0                	xor    %edx,%eax
  800635:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800637:	83 f8 08             	cmp    $0x8,%eax
  80063a:	7f 23                	jg     80065f <vprintfmt+0x140>
  80063c:	8b 14 85 80 12 80 00 	mov    0x801280(,%eax,4),%edx
  800643:	85 d2                	test   %edx,%edx
  800645:	74 18                	je     80065f <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800647:	52                   	push   %edx
  800648:	68 7e 10 80 00       	push   $0x80107e
  80064d:	53                   	push   %ebx
  80064e:	56                   	push   %esi
  80064f:	e8 aa fe ff ff       	call   8004fe <printfmt>
  800654:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800657:	89 7d 14             	mov    %edi,0x14(%ebp)
  80065a:	e9 22 02 00 00       	jmp    800881 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  80065f:	50                   	push   %eax
  800660:	68 75 10 80 00       	push   $0x801075
  800665:	53                   	push   %ebx
  800666:	56                   	push   %esi
  800667:	e8 92 fe ff ff       	call   8004fe <printfmt>
  80066c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80066f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800672:	e9 0a 02 00 00       	jmp    800881 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	83 c0 04             	add    $0x4,%eax
  80067d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800685:	85 d2                	test   %edx,%edx
  800687:	b8 6e 10 80 00       	mov    $0x80106e,%eax
  80068c:	0f 45 c2             	cmovne %edx,%eax
  80068f:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800692:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800696:	7e 06                	jle    80069e <vprintfmt+0x17f>
  800698:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80069c:	75 0d                	jne    8006ab <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80069e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006a1:	89 c7                	mov    %eax,%edi
  8006a3:	03 45 e0             	add    -0x20(%ebp),%eax
  8006a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006a9:	eb 55                	jmp    800700 <vprintfmt+0x1e1>
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8006b1:	ff 75 cc             	pushl  -0x34(%ebp)
  8006b4:	e8 45 03 00 00       	call   8009fe <strnlen>
  8006b9:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006bc:	29 c2                	sub    %eax,%edx
  8006be:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006c6:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cd:	85 ff                	test   %edi,%edi
  8006cf:	7e 11                	jle    8006e2 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8006d1:	83 ec 08             	sub    $0x8,%esp
  8006d4:	53                   	push   %ebx
  8006d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d8:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006da:	83 ef 01             	sub    $0x1,%edi
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	eb eb                	jmp    8006cd <vprintfmt+0x1ae>
  8006e2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006e5:	85 d2                	test   %edx,%edx
  8006e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ec:	0f 49 c2             	cmovns %edx,%eax
  8006ef:	29 c2                	sub    %eax,%edx
  8006f1:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006f4:	eb a8                	jmp    80069e <vprintfmt+0x17f>
					putch(ch, putdat);
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	53                   	push   %ebx
  8006fa:	52                   	push   %edx
  8006fb:	ff d6                	call   *%esi
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800703:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800705:	83 c7 01             	add    $0x1,%edi
  800708:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80070c:	0f be d0             	movsbl %al,%edx
  80070f:	85 d2                	test   %edx,%edx
  800711:	74 4b                	je     80075e <vprintfmt+0x23f>
  800713:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800717:	78 06                	js     80071f <vprintfmt+0x200>
  800719:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80071d:	78 1e                	js     80073d <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80071f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800723:	74 d1                	je     8006f6 <vprintfmt+0x1d7>
  800725:	0f be c0             	movsbl %al,%eax
  800728:	83 e8 20             	sub    $0x20,%eax
  80072b:	83 f8 5e             	cmp    $0x5e,%eax
  80072e:	76 c6                	jbe    8006f6 <vprintfmt+0x1d7>
					putch('?', putdat);
  800730:	83 ec 08             	sub    $0x8,%esp
  800733:	53                   	push   %ebx
  800734:	6a 3f                	push   $0x3f
  800736:	ff d6                	call   *%esi
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	eb c3                	jmp    800700 <vprintfmt+0x1e1>
  80073d:	89 cf                	mov    %ecx,%edi
  80073f:	eb 0e                	jmp    80074f <vprintfmt+0x230>
				putch(' ', putdat);
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	53                   	push   %ebx
  800745:	6a 20                	push   $0x20
  800747:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800749:	83 ef 01             	sub    $0x1,%edi
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	85 ff                	test   %edi,%edi
  800751:	7f ee                	jg     800741 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800753:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800756:	89 45 14             	mov    %eax,0x14(%ebp)
  800759:	e9 23 01 00 00       	jmp    800881 <vprintfmt+0x362>
  80075e:	89 cf                	mov    %ecx,%edi
  800760:	eb ed                	jmp    80074f <vprintfmt+0x230>
	if (lflag >= 2)
  800762:	83 f9 01             	cmp    $0x1,%ecx
  800765:	7f 1b                	jg     800782 <vprintfmt+0x263>
	else if (lflag)
  800767:	85 c9                	test   %ecx,%ecx
  800769:	74 63                	je     8007ce <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8b 00                	mov    (%eax),%eax
  800770:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800773:	99                   	cltd   
  800774:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	8d 40 04             	lea    0x4(%eax),%eax
  80077d:	89 45 14             	mov    %eax,0x14(%ebp)
  800780:	eb 17                	jmp    800799 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800782:	8b 45 14             	mov    0x14(%ebp),%eax
  800785:	8b 50 04             	mov    0x4(%eax),%edx
  800788:	8b 00                	mov    (%eax),%eax
  80078a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800790:	8b 45 14             	mov    0x14(%ebp),%eax
  800793:	8d 40 08             	lea    0x8(%eax),%eax
  800796:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800799:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80079c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80079f:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007a4:	85 c9                	test   %ecx,%ecx
  8007a6:	0f 89 bb 00 00 00    	jns    800867 <vprintfmt+0x348>
				putch('-', putdat);
  8007ac:	83 ec 08             	sub    $0x8,%esp
  8007af:	53                   	push   %ebx
  8007b0:	6a 2d                	push   $0x2d
  8007b2:	ff d6                	call   *%esi
				num = -(long long) num;
  8007b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007ba:	f7 da                	neg    %edx
  8007bc:	83 d1 00             	adc    $0x0,%ecx
  8007bf:	f7 d9                	neg    %ecx
  8007c1:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007c4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007c9:	e9 99 00 00 00       	jmp    800867 <vprintfmt+0x348>
		return va_arg(*ap, int);
  8007ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d1:	8b 00                	mov    (%eax),%eax
  8007d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d6:	99                   	cltd   
  8007d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007da:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dd:	8d 40 04             	lea    0x4(%eax),%eax
  8007e0:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e3:	eb b4                	jmp    800799 <vprintfmt+0x27a>
	if (lflag >= 2)
  8007e5:	83 f9 01             	cmp    $0x1,%ecx
  8007e8:	7f 1b                	jg     800805 <vprintfmt+0x2e6>
	else if (lflag)
  8007ea:	85 c9                	test   %ecx,%ecx
  8007ec:	74 2c                	je     80081a <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  8007ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f1:	8b 10                	mov    (%eax),%edx
  8007f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f8:	8d 40 04             	lea    0x4(%eax),%eax
  8007fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007fe:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800803:	eb 62                	jmp    800867 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800805:	8b 45 14             	mov    0x14(%ebp),%eax
  800808:	8b 10                	mov    (%eax),%edx
  80080a:	8b 48 04             	mov    0x4(%eax),%ecx
  80080d:	8d 40 08             	lea    0x8(%eax),%eax
  800810:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800813:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800818:	eb 4d                	jmp    800867 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80081a:	8b 45 14             	mov    0x14(%ebp),%eax
  80081d:	8b 10                	mov    (%eax),%edx
  80081f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800824:	8d 40 04             	lea    0x4(%eax),%eax
  800827:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80082a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80082f:	eb 36                	jmp    800867 <vprintfmt+0x348>
	if (lflag >= 2)
  800831:	83 f9 01             	cmp    $0x1,%ecx
  800834:	7f 17                	jg     80084d <vprintfmt+0x32e>
	else if (lflag)
  800836:	85 c9                	test   %ecx,%ecx
  800838:	74 6e                	je     8008a8 <vprintfmt+0x389>
		return va_arg(*ap, long);
  80083a:	8b 45 14             	mov    0x14(%ebp),%eax
  80083d:	8b 10                	mov    (%eax),%edx
  80083f:	89 d0                	mov    %edx,%eax
  800841:	99                   	cltd   
  800842:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800845:	8d 49 04             	lea    0x4(%ecx),%ecx
  800848:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80084b:	eb 11                	jmp    80085e <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  80084d:	8b 45 14             	mov    0x14(%ebp),%eax
  800850:	8b 50 04             	mov    0x4(%eax),%edx
  800853:	8b 00                	mov    (%eax),%eax
  800855:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800858:	8d 49 08             	lea    0x8(%ecx),%ecx
  80085b:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80085e:	89 d1                	mov    %edx,%ecx
  800860:	89 c2                	mov    %eax,%edx
            base = 8;
  800862:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800867:	83 ec 0c             	sub    $0xc,%esp
  80086a:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80086e:	57                   	push   %edi
  80086f:	ff 75 e0             	pushl  -0x20(%ebp)
  800872:	50                   	push   %eax
  800873:	51                   	push   %ecx
  800874:	52                   	push   %edx
  800875:	89 da                	mov    %ebx,%edx
  800877:	89 f0                	mov    %esi,%eax
  800879:	e8 b6 fb ff ff       	call   800434 <printnum>
			break;
  80087e:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800881:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800884:	83 c7 01             	add    $0x1,%edi
  800887:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80088b:	83 f8 25             	cmp    $0x25,%eax
  80088e:	0f 84 a6 fc ff ff    	je     80053a <vprintfmt+0x1b>
			if (ch == '\0')
  800894:	85 c0                	test   %eax,%eax
  800896:	0f 84 ce 00 00 00    	je     80096a <vprintfmt+0x44b>
			putch(ch, putdat);
  80089c:	83 ec 08             	sub    $0x8,%esp
  80089f:	53                   	push   %ebx
  8008a0:	50                   	push   %eax
  8008a1:	ff d6                	call   *%esi
  8008a3:	83 c4 10             	add    $0x10,%esp
  8008a6:	eb dc                	jmp    800884 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8008a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ab:	8b 10                	mov    (%eax),%edx
  8008ad:	89 d0                	mov    %edx,%eax
  8008af:	99                   	cltd   
  8008b0:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008b3:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008b6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008b9:	eb a3                	jmp    80085e <vprintfmt+0x33f>
			putch('0', putdat);
  8008bb:	83 ec 08             	sub    $0x8,%esp
  8008be:	53                   	push   %ebx
  8008bf:	6a 30                	push   $0x30
  8008c1:	ff d6                	call   *%esi
			putch('x', putdat);
  8008c3:	83 c4 08             	add    $0x8,%esp
  8008c6:	53                   	push   %ebx
  8008c7:	6a 78                	push   $0x78
  8008c9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ce:	8b 10                	mov    (%eax),%edx
  8008d0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008d5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008d8:	8d 40 04             	lea    0x4(%eax),%eax
  8008db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008de:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008e3:	eb 82                	jmp    800867 <vprintfmt+0x348>
	if (lflag >= 2)
  8008e5:	83 f9 01             	cmp    $0x1,%ecx
  8008e8:	7f 1e                	jg     800908 <vprintfmt+0x3e9>
	else if (lflag)
  8008ea:	85 c9                	test   %ecx,%ecx
  8008ec:	74 32                	je     800920 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  8008ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f1:	8b 10                	mov    (%eax),%edx
  8008f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008f8:	8d 40 04             	lea    0x4(%eax),%eax
  8008fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008fe:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800903:	e9 5f ff ff ff       	jmp    800867 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800908:	8b 45 14             	mov    0x14(%ebp),%eax
  80090b:	8b 10                	mov    (%eax),%edx
  80090d:	8b 48 04             	mov    0x4(%eax),%ecx
  800910:	8d 40 08             	lea    0x8(%eax),%eax
  800913:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800916:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80091b:	e9 47 ff ff ff       	jmp    800867 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800920:	8b 45 14             	mov    0x14(%ebp),%eax
  800923:	8b 10                	mov    (%eax),%edx
  800925:	b9 00 00 00 00       	mov    $0x0,%ecx
  80092a:	8d 40 04             	lea    0x4(%eax),%eax
  80092d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800930:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800935:	e9 2d ff ff ff       	jmp    800867 <vprintfmt+0x348>
			putch(ch, putdat);
  80093a:	83 ec 08             	sub    $0x8,%esp
  80093d:	53                   	push   %ebx
  80093e:	6a 25                	push   $0x25
  800940:	ff d6                	call   *%esi
			break;
  800942:	83 c4 10             	add    $0x10,%esp
  800945:	e9 37 ff ff ff       	jmp    800881 <vprintfmt+0x362>
			putch('%', putdat);
  80094a:	83 ec 08             	sub    $0x8,%esp
  80094d:	53                   	push   %ebx
  80094e:	6a 25                	push   $0x25
  800950:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800952:	83 c4 10             	add    $0x10,%esp
  800955:	89 f8                	mov    %edi,%eax
  800957:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80095b:	74 05                	je     800962 <vprintfmt+0x443>
  80095d:	83 e8 01             	sub    $0x1,%eax
  800960:	eb f5                	jmp    800957 <vprintfmt+0x438>
  800962:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800965:	e9 17 ff ff ff       	jmp    800881 <vprintfmt+0x362>
}
  80096a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80096d:	5b                   	pop    %ebx
  80096e:	5e                   	pop    %esi
  80096f:	5f                   	pop    %edi
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800972:	f3 0f 1e fb          	endbr32 
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	83 ec 18             	sub    $0x18,%esp
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800982:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800985:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800989:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80098c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800993:	85 c0                	test   %eax,%eax
  800995:	74 26                	je     8009bd <vsnprintf+0x4b>
  800997:	85 d2                	test   %edx,%edx
  800999:	7e 22                	jle    8009bd <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80099b:	ff 75 14             	pushl  0x14(%ebp)
  80099e:	ff 75 10             	pushl  0x10(%ebp)
  8009a1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009a4:	50                   	push   %eax
  8009a5:	68 dd 04 80 00       	push   $0x8004dd
  8009aa:	e8 70 fb ff ff       	call   80051f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009af:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009b2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b8:	83 c4 10             	add    $0x10,%esp
}
  8009bb:	c9                   	leave  
  8009bc:	c3                   	ret    
		return -E_INVAL;
  8009bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009c2:	eb f7                	jmp    8009bb <vsnprintf+0x49>

008009c4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009c4:	f3 0f 1e fb          	endbr32 
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009ce:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009d1:	50                   	push   %eax
  8009d2:	ff 75 10             	pushl  0x10(%ebp)
  8009d5:	ff 75 0c             	pushl  0xc(%ebp)
  8009d8:	ff 75 08             	pushl  0x8(%ebp)
  8009db:	e8 92 ff ff ff       	call   800972 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009e0:	c9                   	leave  
  8009e1:	c3                   	ret    

008009e2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009e2:	f3 0f 1e fb          	endbr32 
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009f5:	74 05                	je     8009fc <strlen+0x1a>
		n++;
  8009f7:	83 c0 01             	add    $0x1,%eax
  8009fa:	eb f5                	jmp    8009f1 <strlen+0xf>
	return n;
}
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009fe:	f3 0f 1e fb          	endbr32 
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a08:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a10:	39 d0                	cmp    %edx,%eax
  800a12:	74 0d                	je     800a21 <strnlen+0x23>
  800a14:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a18:	74 05                	je     800a1f <strnlen+0x21>
		n++;
  800a1a:	83 c0 01             	add    $0x1,%eax
  800a1d:	eb f1                	jmp    800a10 <strnlen+0x12>
  800a1f:	89 c2                	mov    %eax,%edx
	return n;
}
  800a21:	89 d0                	mov    %edx,%eax
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a25:	f3 0f 1e fb          	endbr32 
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	53                   	push   %ebx
  800a2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a33:	b8 00 00 00 00       	mov    $0x0,%eax
  800a38:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a3c:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a3f:	83 c0 01             	add    $0x1,%eax
  800a42:	84 d2                	test   %dl,%dl
  800a44:	75 f2                	jne    800a38 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a46:	89 c8                	mov    %ecx,%eax
  800a48:	5b                   	pop    %ebx
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a4b:	f3 0f 1e fb          	endbr32 
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	53                   	push   %ebx
  800a53:	83 ec 10             	sub    $0x10,%esp
  800a56:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a59:	53                   	push   %ebx
  800a5a:	e8 83 ff ff ff       	call   8009e2 <strlen>
  800a5f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a62:	ff 75 0c             	pushl  0xc(%ebp)
  800a65:	01 d8                	add    %ebx,%eax
  800a67:	50                   	push   %eax
  800a68:	e8 b8 ff ff ff       	call   800a25 <strcpy>
	return dst;
}
  800a6d:	89 d8                	mov    %ebx,%eax
  800a6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a72:	c9                   	leave  
  800a73:	c3                   	ret    

00800a74 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a74:	f3 0f 1e fb          	endbr32 
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a80:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a83:	89 f3                	mov    %esi,%ebx
  800a85:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a88:	89 f0                	mov    %esi,%eax
  800a8a:	39 d8                	cmp    %ebx,%eax
  800a8c:	74 11                	je     800a9f <strncpy+0x2b>
		*dst++ = *src;
  800a8e:	83 c0 01             	add    $0x1,%eax
  800a91:	0f b6 0a             	movzbl (%edx),%ecx
  800a94:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a97:	80 f9 01             	cmp    $0x1,%cl
  800a9a:	83 da ff             	sbb    $0xffffffff,%edx
  800a9d:	eb eb                	jmp    800a8a <strncpy+0x16>
	}
	return ret;
}
  800a9f:	89 f0                	mov    %esi,%eax
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aa5:	f3 0f 1e fb          	endbr32 
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	56                   	push   %esi
  800aad:	53                   	push   %ebx
  800aae:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab4:	8b 55 10             	mov    0x10(%ebp),%edx
  800ab7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ab9:	85 d2                	test   %edx,%edx
  800abb:	74 21                	je     800ade <strlcpy+0x39>
  800abd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ac1:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800ac3:	39 c2                	cmp    %eax,%edx
  800ac5:	74 14                	je     800adb <strlcpy+0x36>
  800ac7:	0f b6 19             	movzbl (%ecx),%ebx
  800aca:	84 db                	test   %bl,%bl
  800acc:	74 0b                	je     800ad9 <strlcpy+0x34>
			*dst++ = *src++;
  800ace:	83 c1 01             	add    $0x1,%ecx
  800ad1:	83 c2 01             	add    $0x1,%edx
  800ad4:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ad7:	eb ea                	jmp    800ac3 <strlcpy+0x1e>
  800ad9:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800adb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ade:	29 f0                	sub    %esi,%eax
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ae4:	f3 0f 1e fb          	endbr32 
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aee:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800af1:	0f b6 01             	movzbl (%ecx),%eax
  800af4:	84 c0                	test   %al,%al
  800af6:	74 0c                	je     800b04 <strcmp+0x20>
  800af8:	3a 02                	cmp    (%edx),%al
  800afa:	75 08                	jne    800b04 <strcmp+0x20>
		p++, q++;
  800afc:	83 c1 01             	add    $0x1,%ecx
  800aff:	83 c2 01             	add    $0x1,%edx
  800b02:	eb ed                	jmp    800af1 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b04:	0f b6 c0             	movzbl %al,%eax
  800b07:	0f b6 12             	movzbl (%edx),%edx
  800b0a:	29 d0                	sub    %edx,%eax
}
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b0e:	f3 0f 1e fb          	endbr32 
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	53                   	push   %ebx
  800b16:	8b 45 08             	mov    0x8(%ebp),%eax
  800b19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1c:	89 c3                	mov    %eax,%ebx
  800b1e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b21:	eb 06                	jmp    800b29 <strncmp+0x1b>
		n--, p++, q++;
  800b23:	83 c0 01             	add    $0x1,%eax
  800b26:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b29:	39 d8                	cmp    %ebx,%eax
  800b2b:	74 16                	je     800b43 <strncmp+0x35>
  800b2d:	0f b6 08             	movzbl (%eax),%ecx
  800b30:	84 c9                	test   %cl,%cl
  800b32:	74 04                	je     800b38 <strncmp+0x2a>
  800b34:	3a 0a                	cmp    (%edx),%cl
  800b36:	74 eb                	je     800b23 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b38:	0f b6 00             	movzbl (%eax),%eax
  800b3b:	0f b6 12             	movzbl (%edx),%edx
  800b3e:	29 d0                	sub    %edx,%eax
}
  800b40:	5b                   	pop    %ebx
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    
		return 0;
  800b43:	b8 00 00 00 00       	mov    $0x0,%eax
  800b48:	eb f6                	jmp    800b40 <strncmp+0x32>

00800b4a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b4a:	f3 0f 1e fb          	endbr32 
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	8b 45 08             	mov    0x8(%ebp),%eax
  800b54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b58:	0f b6 10             	movzbl (%eax),%edx
  800b5b:	84 d2                	test   %dl,%dl
  800b5d:	74 09                	je     800b68 <strchr+0x1e>
		if (*s == c)
  800b5f:	38 ca                	cmp    %cl,%dl
  800b61:	74 0a                	je     800b6d <strchr+0x23>
	for (; *s; s++)
  800b63:	83 c0 01             	add    $0x1,%eax
  800b66:	eb f0                	jmp    800b58 <strchr+0xe>
			return (char *) s;
	return 0;
  800b68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b6f:	f3 0f 1e fb          	endbr32 
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	8b 45 08             	mov    0x8(%ebp),%eax
  800b79:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b7d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b80:	38 ca                	cmp    %cl,%dl
  800b82:	74 09                	je     800b8d <strfind+0x1e>
  800b84:	84 d2                	test   %dl,%dl
  800b86:	74 05                	je     800b8d <strfind+0x1e>
	for (; *s; s++)
  800b88:	83 c0 01             	add    $0x1,%eax
  800b8b:	eb f0                	jmp    800b7d <strfind+0xe>
			break;
	return (char *) s;
}
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b8f:	f3 0f 1e fb          	endbr32 
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	57                   	push   %edi
  800b97:	56                   	push   %esi
  800b98:	53                   	push   %ebx
  800b99:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b9c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b9f:	85 c9                	test   %ecx,%ecx
  800ba1:	74 31                	je     800bd4 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ba3:	89 f8                	mov    %edi,%eax
  800ba5:	09 c8                	or     %ecx,%eax
  800ba7:	a8 03                	test   $0x3,%al
  800ba9:	75 23                	jne    800bce <memset+0x3f>
		c &= 0xFF;
  800bab:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800baf:	89 d3                	mov    %edx,%ebx
  800bb1:	c1 e3 08             	shl    $0x8,%ebx
  800bb4:	89 d0                	mov    %edx,%eax
  800bb6:	c1 e0 18             	shl    $0x18,%eax
  800bb9:	89 d6                	mov    %edx,%esi
  800bbb:	c1 e6 10             	shl    $0x10,%esi
  800bbe:	09 f0                	or     %esi,%eax
  800bc0:	09 c2                	or     %eax,%edx
  800bc2:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bc4:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800bc7:	89 d0                	mov    %edx,%eax
  800bc9:	fc                   	cld    
  800bca:	f3 ab                	rep stos %eax,%es:(%edi)
  800bcc:	eb 06                	jmp    800bd4 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd1:	fc                   	cld    
  800bd2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bd4:	89 f8                	mov    %edi,%eax
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bdb:	f3 0f 1e fb          	endbr32 
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	8b 45 08             	mov    0x8(%ebp),%eax
  800be7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bed:	39 c6                	cmp    %eax,%esi
  800bef:	73 32                	jae    800c23 <memmove+0x48>
  800bf1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bf4:	39 c2                	cmp    %eax,%edx
  800bf6:	76 2b                	jbe    800c23 <memmove+0x48>
		s += n;
		d += n;
  800bf8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bfb:	89 fe                	mov    %edi,%esi
  800bfd:	09 ce                	or     %ecx,%esi
  800bff:	09 d6                	or     %edx,%esi
  800c01:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c07:	75 0e                	jne    800c17 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c09:	83 ef 04             	sub    $0x4,%edi
  800c0c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c0f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c12:	fd                   	std    
  800c13:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c15:	eb 09                	jmp    800c20 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c17:	83 ef 01             	sub    $0x1,%edi
  800c1a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c1d:	fd                   	std    
  800c1e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c20:	fc                   	cld    
  800c21:	eb 1a                	jmp    800c3d <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c23:	89 c2                	mov    %eax,%edx
  800c25:	09 ca                	or     %ecx,%edx
  800c27:	09 f2                	or     %esi,%edx
  800c29:	f6 c2 03             	test   $0x3,%dl
  800c2c:	75 0a                	jne    800c38 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c2e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c31:	89 c7                	mov    %eax,%edi
  800c33:	fc                   	cld    
  800c34:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c36:	eb 05                	jmp    800c3d <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c38:	89 c7                	mov    %eax,%edi
  800c3a:	fc                   	cld    
  800c3b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c41:	f3 0f 1e fb          	endbr32 
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c4b:	ff 75 10             	pushl  0x10(%ebp)
  800c4e:	ff 75 0c             	pushl  0xc(%ebp)
  800c51:	ff 75 08             	pushl  0x8(%ebp)
  800c54:	e8 82 ff ff ff       	call   800bdb <memmove>
}
  800c59:	c9                   	leave  
  800c5a:	c3                   	ret    

00800c5b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c5b:	f3 0f 1e fb          	endbr32 
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
  800c64:	8b 45 08             	mov    0x8(%ebp),%eax
  800c67:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c6a:	89 c6                	mov    %eax,%esi
  800c6c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c6f:	39 f0                	cmp    %esi,%eax
  800c71:	74 1c                	je     800c8f <memcmp+0x34>
		if (*s1 != *s2)
  800c73:	0f b6 08             	movzbl (%eax),%ecx
  800c76:	0f b6 1a             	movzbl (%edx),%ebx
  800c79:	38 d9                	cmp    %bl,%cl
  800c7b:	75 08                	jne    800c85 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c7d:	83 c0 01             	add    $0x1,%eax
  800c80:	83 c2 01             	add    $0x1,%edx
  800c83:	eb ea                	jmp    800c6f <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800c85:	0f b6 c1             	movzbl %cl,%eax
  800c88:	0f b6 db             	movzbl %bl,%ebx
  800c8b:	29 d8                	sub    %ebx,%eax
  800c8d:	eb 05                	jmp    800c94 <memcmp+0x39>
	}

	return 0;
  800c8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c98:	f3 0f 1e fb          	endbr32 
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ca5:	89 c2                	mov    %eax,%edx
  800ca7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800caa:	39 d0                	cmp    %edx,%eax
  800cac:	73 09                	jae    800cb7 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cae:	38 08                	cmp    %cl,(%eax)
  800cb0:	74 05                	je     800cb7 <memfind+0x1f>
	for (; s < ends; s++)
  800cb2:	83 c0 01             	add    $0x1,%eax
  800cb5:	eb f3                	jmp    800caa <memfind+0x12>
			break;
	return (void *) s;
}
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    

00800cb9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cb9:	f3 0f 1e fb          	endbr32 
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
  800cc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cc9:	eb 03                	jmp    800cce <strtol+0x15>
		s++;
  800ccb:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800cce:	0f b6 01             	movzbl (%ecx),%eax
  800cd1:	3c 20                	cmp    $0x20,%al
  800cd3:	74 f6                	je     800ccb <strtol+0x12>
  800cd5:	3c 09                	cmp    $0x9,%al
  800cd7:	74 f2                	je     800ccb <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800cd9:	3c 2b                	cmp    $0x2b,%al
  800cdb:	74 2a                	je     800d07 <strtol+0x4e>
	int neg = 0;
  800cdd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ce2:	3c 2d                	cmp    $0x2d,%al
  800ce4:	74 2b                	je     800d11 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ce6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cec:	75 0f                	jne    800cfd <strtol+0x44>
  800cee:	80 39 30             	cmpb   $0x30,(%ecx)
  800cf1:	74 28                	je     800d1b <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cf3:	85 db                	test   %ebx,%ebx
  800cf5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cfa:	0f 44 d8             	cmove  %eax,%ebx
  800cfd:	b8 00 00 00 00       	mov    $0x0,%eax
  800d02:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d05:	eb 46                	jmp    800d4d <strtol+0x94>
		s++;
  800d07:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d0a:	bf 00 00 00 00       	mov    $0x0,%edi
  800d0f:	eb d5                	jmp    800ce6 <strtol+0x2d>
		s++, neg = 1;
  800d11:	83 c1 01             	add    $0x1,%ecx
  800d14:	bf 01 00 00 00       	mov    $0x1,%edi
  800d19:	eb cb                	jmp    800ce6 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d1b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d1f:	74 0e                	je     800d2f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d21:	85 db                	test   %ebx,%ebx
  800d23:	75 d8                	jne    800cfd <strtol+0x44>
		s++, base = 8;
  800d25:	83 c1 01             	add    $0x1,%ecx
  800d28:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d2d:	eb ce                	jmp    800cfd <strtol+0x44>
		s += 2, base = 16;
  800d2f:	83 c1 02             	add    $0x2,%ecx
  800d32:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d37:	eb c4                	jmp    800cfd <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d39:	0f be d2             	movsbl %dl,%edx
  800d3c:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d3f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d42:	7d 3a                	jge    800d7e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d44:	83 c1 01             	add    $0x1,%ecx
  800d47:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d4b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d4d:	0f b6 11             	movzbl (%ecx),%edx
  800d50:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d53:	89 f3                	mov    %esi,%ebx
  800d55:	80 fb 09             	cmp    $0x9,%bl
  800d58:	76 df                	jbe    800d39 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800d5a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d5d:	89 f3                	mov    %esi,%ebx
  800d5f:	80 fb 19             	cmp    $0x19,%bl
  800d62:	77 08                	ja     800d6c <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d64:	0f be d2             	movsbl %dl,%edx
  800d67:	83 ea 57             	sub    $0x57,%edx
  800d6a:	eb d3                	jmp    800d3f <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800d6c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d6f:	89 f3                	mov    %esi,%ebx
  800d71:	80 fb 19             	cmp    $0x19,%bl
  800d74:	77 08                	ja     800d7e <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d76:	0f be d2             	movsbl %dl,%edx
  800d79:	83 ea 37             	sub    $0x37,%edx
  800d7c:	eb c1                	jmp    800d3f <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d7e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d82:	74 05                	je     800d89 <strtol+0xd0>
		*endptr = (char *) s;
  800d84:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d87:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d89:	89 c2                	mov    %eax,%edx
  800d8b:	f7 da                	neg    %edx
  800d8d:	85 ff                	test   %edi,%edi
  800d8f:	0f 45 c2             	cmovne %edx,%eax
}
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    
  800d97:	66 90                	xchg   %ax,%ax
  800d99:	66 90                	xchg   %ax,%ax
  800d9b:	66 90                	xchg   %ax,%ax
  800d9d:	66 90                	xchg   %ax,%ax
  800d9f:	90                   	nop

00800da0 <__udivdi3>:
  800da0:	f3 0f 1e fb          	endbr32 
  800da4:	55                   	push   %ebp
  800da5:	57                   	push   %edi
  800da6:	56                   	push   %esi
  800da7:	53                   	push   %ebx
  800da8:	83 ec 1c             	sub    $0x1c,%esp
  800dab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800daf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800db3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800db7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800dbb:	85 d2                	test   %edx,%edx
  800dbd:	75 19                	jne    800dd8 <__udivdi3+0x38>
  800dbf:	39 f3                	cmp    %esi,%ebx
  800dc1:	76 4d                	jbe    800e10 <__udivdi3+0x70>
  800dc3:	31 ff                	xor    %edi,%edi
  800dc5:	89 e8                	mov    %ebp,%eax
  800dc7:	89 f2                	mov    %esi,%edx
  800dc9:	f7 f3                	div    %ebx
  800dcb:	89 fa                	mov    %edi,%edx
  800dcd:	83 c4 1c             	add    $0x1c,%esp
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    
  800dd5:	8d 76 00             	lea    0x0(%esi),%esi
  800dd8:	39 f2                	cmp    %esi,%edx
  800dda:	76 14                	jbe    800df0 <__udivdi3+0x50>
  800ddc:	31 ff                	xor    %edi,%edi
  800dde:	31 c0                	xor    %eax,%eax
  800de0:	89 fa                	mov    %edi,%edx
  800de2:	83 c4 1c             	add    $0x1c,%esp
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    
  800dea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800df0:	0f bd fa             	bsr    %edx,%edi
  800df3:	83 f7 1f             	xor    $0x1f,%edi
  800df6:	75 48                	jne    800e40 <__udivdi3+0xa0>
  800df8:	39 f2                	cmp    %esi,%edx
  800dfa:	72 06                	jb     800e02 <__udivdi3+0x62>
  800dfc:	31 c0                	xor    %eax,%eax
  800dfe:	39 eb                	cmp    %ebp,%ebx
  800e00:	77 de                	ja     800de0 <__udivdi3+0x40>
  800e02:	b8 01 00 00 00       	mov    $0x1,%eax
  800e07:	eb d7                	jmp    800de0 <__udivdi3+0x40>
  800e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e10:	89 d9                	mov    %ebx,%ecx
  800e12:	85 db                	test   %ebx,%ebx
  800e14:	75 0b                	jne    800e21 <__udivdi3+0x81>
  800e16:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1b:	31 d2                	xor    %edx,%edx
  800e1d:	f7 f3                	div    %ebx
  800e1f:	89 c1                	mov    %eax,%ecx
  800e21:	31 d2                	xor    %edx,%edx
  800e23:	89 f0                	mov    %esi,%eax
  800e25:	f7 f1                	div    %ecx
  800e27:	89 c6                	mov    %eax,%esi
  800e29:	89 e8                	mov    %ebp,%eax
  800e2b:	89 f7                	mov    %esi,%edi
  800e2d:	f7 f1                	div    %ecx
  800e2f:	89 fa                	mov    %edi,%edx
  800e31:	83 c4 1c             	add    $0x1c,%esp
  800e34:	5b                   	pop    %ebx
  800e35:	5e                   	pop    %esi
  800e36:	5f                   	pop    %edi
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	89 f9                	mov    %edi,%ecx
  800e42:	b8 20 00 00 00       	mov    $0x20,%eax
  800e47:	29 f8                	sub    %edi,%eax
  800e49:	d3 e2                	shl    %cl,%edx
  800e4b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e4f:	89 c1                	mov    %eax,%ecx
  800e51:	89 da                	mov    %ebx,%edx
  800e53:	d3 ea                	shr    %cl,%edx
  800e55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e59:	09 d1                	or     %edx,%ecx
  800e5b:	89 f2                	mov    %esi,%edx
  800e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e61:	89 f9                	mov    %edi,%ecx
  800e63:	d3 e3                	shl    %cl,%ebx
  800e65:	89 c1                	mov    %eax,%ecx
  800e67:	d3 ea                	shr    %cl,%edx
  800e69:	89 f9                	mov    %edi,%ecx
  800e6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e6f:	89 eb                	mov    %ebp,%ebx
  800e71:	d3 e6                	shl    %cl,%esi
  800e73:	89 c1                	mov    %eax,%ecx
  800e75:	d3 eb                	shr    %cl,%ebx
  800e77:	09 de                	or     %ebx,%esi
  800e79:	89 f0                	mov    %esi,%eax
  800e7b:	f7 74 24 08          	divl   0x8(%esp)
  800e7f:	89 d6                	mov    %edx,%esi
  800e81:	89 c3                	mov    %eax,%ebx
  800e83:	f7 64 24 0c          	mull   0xc(%esp)
  800e87:	39 d6                	cmp    %edx,%esi
  800e89:	72 15                	jb     800ea0 <__udivdi3+0x100>
  800e8b:	89 f9                	mov    %edi,%ecx
  800e8d:	d3 e5                	shl    %cl,%ebp
  800e8f:	39 c5                	cmp    %eax,%ebp
  800e91:	73 04                	jae    800e97 <__udivdi3+0xf7>
  800e93:	39 d6                	cmp    %edx,%esi
  800e95:	74 09                	je     800ea0 <__udivdi3+0x100>
  800e97:	89 d8                	mov    %ebx,%eax
  800e99:	31 ff                	xor    %edi,%edi
  800e9b:	e9 40 ff ff ff       	jmp    800de0 <__udivdi3+0x40>
  800ea0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ea3:	31 ff                	xor    %edi,%edi
  800ea5:	e9 36 ff ff ff       	jmp    800de0 <__udivdi3+0x40>
  800eaa:	66 90                	xchg   %ax,%ax
  800eac:	66 90                	xchg   %ax,%ax
  800eae:	66 90                	xchg   %ax,%ax

00800eb0 <__umoddi3>:
  800eb0:	f3 0f 1e fb          	endbr32 
  800eb4:	55                   	push   %ebp
  800eb5:	57                   	push   %edi
  800eb6:	56                   	push   %esi
  800eb7:	53                   	push   %ebx
  800eb8:	83 ec 1c             	sub    $0x1c,%esp
  800ebb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800ebf:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ec3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ec7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	75 19                	jne    800ee8 <__umoddi3+0x38>
  800ecf:	39 df                	cmp    %ebx,%edi
  800ed1:	76 5d                	jbe    800f30 <__umoddi3+0x80>
  800ed3:	89 f0                	mov    %esi,%eax
  800ed5:	89 da                	mov    %ebx,%edx
  800ed7:	f7 f7                	div    %edi
  800ed9:	89 d0                	mov    %edx,%eax
  800edb:	31 d2                	xor    %edx,%edx
  800edd:	83 c4 1c             	add    $0x1c,%esp
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    
  800ee5:	8d 76 00             	lea    0x0(%esi),%esi
  800ee8:	89 f2                	mov    %esi,%edx
  800eea:	39 d8                	cmp    %ebx,%eax
  800eec:	76 12                	jbe    800f00 <__umoddi3+0x50>
  800eee:	89 f0                	mov    %esi,%eax
  800ef0:	89 da                	mov    %ebx,%edx
  800ef2:	83 c4 1c             	add    $0x1c,%esp
  800ef5:	5b                   	pop    %ebx
  800ef6:	5e                   	pop    %esi
  800ef7:	5f                   	pop    %edi
  800ef8:	5d                   	pop    %ebp
  800ef9:	c3                   	ret    
  800efa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f00:	0f bd e8             	bsr    %eax,%ebp
  800f03:	83 f5 1f             	xor    $0x1f,%ebp
  800f06:	75 50                	jne    800f58 <__umoddi3+0xa8>
  800f08:	39 d8                	cmp    %ebx,%eax
  800f0a:	0f 82 e0 00 00 00    	jb     800ff0 <__umoddi3+0x140>
  800f10:	89 d9                	mov    %ebx,%ecx
  800f12:	39 f7                	cmp    %esi,%edi
  800f14:	0f 86 d6 00 00 00    	jbe    800ff0 <__umoddi3+0x140>
  800f1a:	89 d0                	mov    %edx,%eax
  800f1c:	89 ca                	mov    %ecx,%edx
  800f1e:	83 c4 1c             	add    $0x1c,%esp
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    
  800f26:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f2d:	8d 76 00             	lea    0x0(%esi),%esi
  800f30:	89 fd                	mov    %edi,%ebp
  800f32:	85 ff                	test   %edi,%edi
  800f34:	75 0b                	jne    800f41 <__umoddi3+0x91>
  800f36:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3b:	31 d2                	xor    %edx,%edx
  800f3d:	f7 f7                	div    %edi
  800f3f:	89 c5                	mov    %eax,%ebp
  800f41:	89 d8                	mov    %ebx,%eax
  800f43:	31 d2                	xor    %edx,%edx
  800f45:	f7 f5                	div    %ebp
  800f47:	89 f0                	mov    %esi,%eax
  800f49:	f7 f5                	div    %ebp
  800f4b:	89 d0                	mov    %edx,%eax
  800f4d:	31 d2                	xor    %edx,%edx
  800f4f:	eb 8c                	jmp    800edd <__umoddi3+0x2d>
  800f51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f58:	89 e9                	mov    %ebp,%ecx
  800f5a:	ba 20 00 00 00       	mov    $0x20,%edx
  800f5f:	29 ea                	sub    %ebp,%edx
  800f61:	d3 e0                	shl    %cl,%eax
  800f63:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f67:	89 d1                	mov    %edx,%ecx
  800f69:	89 f8                	mov    %edi,%eax
  800f6b:	d3 e8                	shr    %cl,%eax
  800f6d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f71:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f75:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f79:	09 c1                	or     %eax,%ecx
  800f7b:	89 d8                	mov    %ebx,%eax
  800f7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f81:	89 e9                	mov    %ebp,%ecx
  800f83:	d3 e7                	shl    %cl,%edi
  800f85:	89 d1                	mov    %edx,%ecx
  800f87:	d3 e8                	shr    %cl,%eax
  800f89:	89 e9                	mov    %ebp,%ecx
  800f8b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f8f:	d3 e3                	shl    %cl,%ebx
  800f91:	89 c7                	mov    %eax,%edi
  800f93:	89 d1                	mov    %edx,%ecx
  800f95:	89 f0                	mov    %esi,%eax
  800f97:	d3 e8                	shr    %cl,%eax
  800f99:	89 e9                	mov    %ebp,%ecx
  800f9b:	89 fa                	mov    %edi,%edx
  800f9d:	d3 e6                	shl    %cl,%esi
  800f9f:	09 d8                	or     %ebx,%eax
  800fa1:	f7 74 24 08          	divl   0x8(%esp)
  800fa5:	89 d1                	mov    %edx,%ecx
  800fa7:	89 f3                	mov    %esi,%ebx
  800fa9:	f7 64 24 0c          	mull   0xc(%esp)
  800fad:	89 c6                	mov    %eax,%esi
  800faf:	89 d7                	mov    %edx,%edi
  800fb1:	39 d1                	cmp    %edx,%ecx
  800fb3:	72 06                	jb     800fbb <__umoddi3+0x10b>
  800fb5:	75 10                	jne    800fc7 <__umoddi3+0x117>
  800fb7:	39 c3                	cmp    %eax,%ebx
  800fb9:	73 0c                	jae    800fc7 <__umoddi3+0x117>
  800fbb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800fbf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800fc3:	89 d7                	mov    %edx,%edi
  800fc5:	89 c6                	mov    %eax,%esi
  800fc7:	89 ca                	mov    %ecx,%edx
  800fc9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fce:	29 f3                	sub    %esi,%ebx
  800fd0:	19 fa                	sbb    %edi,%edx
  800fd2:	89 d0                	mov    %edx,%eax
  800fd4:	d3 e0                	shl    %cl,%eax
  800fd6:	89 e9                	mov    %ebp,%ecx
  800fd8:	d3 eb                	shr    %cl,%ebx
  800fda:	d3 ea                	shr    %cl,%edx
  800fdc:	09 d8                	or     %ebx,%eax
  800fde:	83 c4 1c             	add    $0x1c,%esp
  800fe1:	5b                   	pop    %ebx
  800fe2:	5e                   	pop    %esi
  800fe3:	5f                   	pop    %edi
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    
  800fe6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fed:	8d 76 00             	lea    0x0(%esi),%esi
  800ff0:	29 fe                	sub    %edi,%esi
  800ff2:	19 c3                	sbb    %eax,%ebx
  800ff4:	89 f2                	mov    %esi,%edx
  800ff6:	89 d9                	mov    %ebx,%ecx
  800ff8:	e9 1d ff ff ff       	jmp    800f1a <__umoddi3+0x6a>
