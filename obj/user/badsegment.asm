
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
    envid_t envid = sys_getenvid();
  80004d:	e8 d6 00 00 00       	call   800128 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x31>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	f3 0f 1e fb          	endbr32 
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800092:	6a 00                	push   $0x0
  800094:	e8 4a 00 00 00       	call   8000e3 <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	f3 0f 1e fb          	endbr32 
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	f3 0f 1e fb          	endbr32 
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d4:	89 d1                	mov    %edx,%ecx
  8000d6:	89 d3                	mov    %edx,%ebx
  8000d8:	89 d7                	mov    %edx,%edi
  8000da:	89 d6                	mov    %edx,%esi
  8000dc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e3:	f3 0f 1e fb          	endbr32 
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f8:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fd:	89 cb                	mov    %ecx,%ebx
  8000ff:	89 cf                	mov    %ecx,%edi
  800101:	89 ce                	mov    %ecx,%esi
  800103:	cd 30                	int    $0x30
	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7f 08                	jg     800111 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800109:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5f                   	pop    %edi
  80010f:	5d                   	pop    %ebp
  800110:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800111:	83 ec 0c             	sub    $0xc,%esp
  800114:	50                   	push   %eax
  800115:	6a 03                	push   $0x3
  800117:	68 0a 10 80 00       	push   $0x80100a
  80011c:	6a 23                	push   $0x23
  80011e:	68 27 10 80 00       	push   $0x801027
  800123:	e8 11 02 00 00       	call   800339 <_panic>

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800128:	f3 0f 1e fb          	endbr32 
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	asm volatile("int %1\n"
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 02 00 00 00       	mov    $0x2,%eax
  80013c:	89 d1                	mov    %edx,%ecx
  80013e:	89 d3                	mov    %edx,%ebx
  800140:	89 d7                	mov    %edx,%edi
  800142:	89 d6                	mov    %edx,%esi
  800144:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_yield>:

void
sys_yield(void)
{
  80014b:	f3 0f 1e fb          	endbr32 
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	57                   	push   %edi
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
	asm volatile("int %1\n"
  800155:	ba 00 00 00 00       	mov    $0x0,%edx
  80015a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80015f:	89 d1                	mov    %edx,%ecx
  800161:	89 d3                	mov    %edx,%ebx
  800163:	89 d7                	mov    %edx,%edi
  800165:	89 d6                	mov    %edx,%esi
  800167:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800169:	5b                   	pop    %ebx
  80016a:	5e                   	pop    %esi
  80016b:	5f                   	pop    %edi
  80016c:	5d                   	pop    %ebp
  80016d:	c3                   	ret    

0080016e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016e:	f3 0f 1e fb          	endbr32 
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	57                   	push   %edi
  800176:	56                   	push   %esi
  800177:	53                   	push   %ebx
  800178:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80017b:	be 00 00 00 00       	mov    $0x0,%esi
  800180:	8b 55 08             	mov    0x8(%ebp),%edx
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	b8 04 00 00 00       	mov    $0x4,%eax
  80018b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018e:	89 f7                	mov    %esi,%edi
  800190:	cd 30                	int    $0x30
	if(check && ret > 0)
  800192:	85 c0                	test   %eax,%eax
  800194:	7f 08                	jg     80019e <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	50                   	push   %eax
  8001a2:	6a 04                	push   $0x4
  8001a4:	68 0a 10 80 00       	push   $0x80100a
  8001a9:	6a 23                	push   $0x23
  8001ab:	68 27 10 80 00       	push   $0x801027
  8001b0:	e8 84 01 00 00       	call   800339 <_panic>

008001b5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b5:	f3 0f 1e fb          	endbr32 
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	57                   	push   %edi
  8001bd:	56                   	push   %esi
  8001be:	53                   	push   %ebx
  8001bf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c8:	b8 05 00 00 00       	mov    $0x5,%eax
  8001cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001d8:	85 c0                	test   %eax,%eax
  8001da:	7f 08                	jg     8001e4 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001df:	5b                   	pop    %ebx
  8001e0:	5e                   	pop    %esi
  8001e1:	5f                   	pop    %edi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	50                   	push   %eax
  8001e8:	6a 05                	push   $0x5
  8001ea:	68 0a 10 80 00       	push   $0x80100a
  8001ef:	6a 23                	push   $0x23
  8001f1:	68 27 10 80 00       	push   $0x801027
  8001f6:	e8 3e 01 00 00       	call   800339 <_panic>

008001fb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001fb:	f3 0f 1e fb          	endbr32 
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	57                   	push   %edi
  800203:	56                   	push   %esi
  800204:	53                   	push   %ebx
  800205:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800208:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020d:	8b 55 08             	mov    0x8(%ebp),%edx
  800210:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800213:	b8 06 00 00 00       	mov    $0x6,%eax
  800218:	89 df                	mov    %ebx,%edi
  80021a:	89 de                	mov    %ebx,%esi
  80021c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80021e:	85 c0                	test   %eax,%eax
  800220:	7f 08                	jg     80022a <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80022a:	83 ec 0c             	sub    $0xc,%esp
  80022d:	50                   	push   %eax
  80022e:	6a 06                	push   $0x6
  800230:	68 0a 10 80 00       	push   $0x80100a
  800235:	6a 23                	push   $0x23
  800237:	68 27 10 80 00       	push   $0x801027
  80023c:	e8 f8 00 00 00       	call   800339 <_panic>

00800241 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800241:	f3 0f 1e fb          	endbr32 
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	57                   	push   %edi
  800249:	56                   	push   %esi
  80024a:	53                   	push   %ebx
  80024b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80024e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800253:	8b 55 08             	mov    0x8(%ebp),%edx
  800256:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800259:	b8 08 00 00 00       	mov    $0x8,%eax
  80025e:	89 df                	mov    %ebx,%edi
  800260:	89 de                	mov    %ebx,%esi
  800262:	cd 30                	int    $0x30
	if(check && ret > 0)
  800264:	85 c0                	test   %eax,%eax
  800266:	7f 08                	jg     800270 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800268:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026b:	5b                   	pop    %ebx
  80026c:	5e                   	pop    %esi
  80026d:	5f                   	pop    %edi
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	50                   	push   %eax
  800274:	6a 08                	push   $0x8
  800276:	68 0a 10 80 00       	push   $0x80100a
  80027b:	6a 23                	push   $0x23
  80027d:	68 27 10 80 00       	push   $0x801027
  800282:	e8 b2 00 00 00       	call   800339 <_panic>

00800287 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800287:	f3 0f 1e fb          	endbr32 
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	57                   	push   %edi
  80028f:	56                   	push   %esi
  800290:	53                   	push   %ebx
  800291:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800294:	bb 00 00 00 00       	mov    $0x0,%ebx
  800299:	8b 55 08             	mov    0x8(%ebp),%edx
  80029c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029f:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a4:	89 df                	mov    %ebx,%edi
  8002a6:	89 de                	mov    %ebx,%esi
  8002a8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002aa:	85 c0                	test   %eax,%eax
  8002ac:	7f 08                	jg     8002b6 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b1:	5b                   	pop    %ebx
  8002b2:	5e                   	pop    %esi
  8002b3:	5f                   	pop    %edi
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b6:	83 ec 0c             	sub    $0xc,%esp
  8002b9:	50                   	push   %eax
  8002ba:	6a 09                	push   $0x9
  8002bc:	68 0a 10 80 00       	push   $0x80100a
  8002c1:	6a 23                	push   $0x23
  8002c3:	68 27 10 80 00       	push   $0x801027
  8002c8:	e8 6c 00 00 00       	call   800339 <_panic>

008002cd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002cd:	f3 0f 1e fb          	endbr32 
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	57                   	push   %edi
  8002d5:	56                   	push   %esi
  8002d6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002dd:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002e2:	be 00 00 00 00       	mov    $0x0,%esi
  8002e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ea:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ed:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002ef:	5b                   	pop    %ebx
  8002f0:	5e                   	pop    %esi
  8002f1:	5f                   	pop    %edi
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002f4:	f3 0f 1e fb          	endbr32 
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	57                   	push   %edi
  8002fc:	56                   	push   %esi
  8002fd:	53                   	push   %ebx
  8002fe:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800301:	b9 00 00 00 00       	mov    $0x0,%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030e:	89 cb                	mov    %ecx,%ebx
  800310:	89 cf                	mov    %ecx,%edi
  800312:	89 ce                	mov    %ecx,%esi
  800314:	cd 30                	int    $0x30
	if(check && ret > 0)
  800316:	85 c0                	test   %eax,%eax
  800318:	7f 08                	jg     800322 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
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
  800326:	6a 0c                	push   $0xc
  800328:	68 0a 10 80 00       	push   $0x80100a
  80032d:	6a 23                	push   $0x23
  80032f:	68 27 10 80 00       	push   $0x801027
  800334:	e8 00 00 00 00       	call   800339 <_panic>

00800339 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800339:	f3 0f 1e fb          	endbr32 
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	56                   	push   %esi
  800341:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800342:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800345:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80034b:	e8 d8 fd ff ff       	call   800128 <sys_getenvid>
  800350:	83 ec 0c             	sub    $0xc,%esp
  800353:	ff 75 0c             	pushl  0xc(%ebp)
  800356:	ff 75 08             	pushl  0x8(%ebp)
  800359:	56                   	push   %esi
  80035a:	50                   	push   %eax
  80035b:	68 38 10 80 00       	push   $0x801038
  800360:	e8 bb 00 00 00       	call   800420 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800365:	83 c4 18             	add    $0x18,%esp
  800368:	53                   	push   %ebx
  800369:	ff 75 10             	pushl  0x10(%ebp)
  80036c:	e8 5a 00 00 00       	call   8003cb <vcprintf>
	cprintf("\n");
  800371:	c7 04 24 5b 10 80 00 	movl   $0x80105b,(%esp)
  800378:	e8 a3 00 00 00       	call   800420 <cprintf>
  80037d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800380:	cc                   	int3   
  800381:	eb fd                	jmp    800380 <_panic+0x47>

00800383 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800383:	f3 0f 1e fb          	endbr32 
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	53                   	push   %ebx
  80038b:	83 ec 04             	sub    $0x4,%esp
  80038e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800391:	8b 13                	mov    (%ebx),%edx
  800393:	8d 42 01             	lea    0x1(%edx),%eax
  800396:	89 03                	mov    %eax,(%ebx)
  800398:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80039f:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a4:	74 09                	je     8003af <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003a6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003ad:	c9                   	leave  
  8003ae:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003af:	83 ec 08             	sub    $0x8,%esp
  8003b2:	68 ff 00 00 00       	push   $0xff
  8003b7:	8d 43 08             	lea    0x8(%ebx),%eax
  8003ba:	50                   	push   %eax
  8003bb:	e8 de fc ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  8003c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003c6:	83 c4 10             	add    $0x10,%esp
  8003c9:	eb db                	jmp    8003a6 <putch+0x23>

008003cb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003cb:	f3 0f 1e fb          	endbr32 
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003df:	00 00 00 
	b.cnt = 0;
  8003e2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003ec:	ff 75 0c             	pushl  0xc(%ebp)
  8003ef:	ff 75 08             	pushl  0x8(%ebp)
  8003f2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f8:	50                   	push   %eax
  8003f9:	68 83 03 80 00       	push   $0x800383
  8003fe:	e8 20 01 00 00       	call   800523 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800403:	83 c4 08             	add    $0x8,%esp
  800406:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80040c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800412:	50                   	push   %eax
  800413:	e8 86 fc ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  800418:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80041e:	c9                   	leave  
  80041f:	c3                   	ret    

00800420 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800420:	f3 0f 1e fb          	endbr32 
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80042a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80042d:	50                   	push   %eax
  80042e:	ff 75 08             	pushl  0x8(%ebp)
  800431:	e8 95 ff ff ff       	call   8003cb <vcprintf>
	va_end(ap);

	return cnt;
}
  800436:	c9                   	leave  
  800437:	c3                   	ret    

00800438 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	57                   	push   %edi
  80043c:	56                   	push   %esi
  80043d:	53                   	push   %ebx
  80043e:	83 ec 1c             	sub    $0x1c,%esp
  800441:	89 c7                	mov    %eax,%edi
  800443:	89 d6                	mov    %edx,%esi
  800445:	8b 45 08             	mov    0x8(%ebp),%eax
  800448:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044b:	89 d1                	mov    %edx,%ecx
  80044d:	89 c2                	mov    %eax,%edx
  80044f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800452:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800455:	8b 45 10             	mov    0x10(%ebp),%eax
  800458:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80045b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800465:	39 c2                	cmp    %eax,%edx
  800467:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80046a:	72 3e                	jb     8004aa <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80046c:	83 ec 0c             	sub    $0xc,%esp
  80046f:	ff 75 18             	pushl  0x18(%ebp)
  800472:	83 eb 01             	sub    $0x1,%ebx
  800475:	53                   	push   %ebx
  800476:	50                   	push   %eax
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80047d:	ff 75 e0             	pushl  -0x20(%ebp)
  800480:	ff 75 dc             	pushl  -0x24(%ebp)
  800483:	ff 75 d8             	pushl  -0x28(%ebp)
  800486:	e8 15 09 00 00       	call   800da0 <__udivdi3>
  80048b:	83 c4 18             	add    $0x18,%esp
  80048e:	52                   	push   %edx
  80048f:	50                   	push   %eax
  800490:	89 f2                	mov    %esi,%edx
  800492:	89 f8                	mov    %edi,%eax
  800494:	e8 9f ff ff ff       	call   800438 <printnum>
  800499:	83 c4 20             	add    $0x20,%esp
  80049c:	eb 13                	jmp    8004b1 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	56                   	push   %esi
  8004a2:	ff 75 18             	pushl  0x18(%ebp)
  8004a5:	ff d7                	call   *%edi
  8004a7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004aa:	83 eb 01             	sub    $0x1,%ebx
  8004ad:	85 db                	test   %ebx,%ebx
  8004af:	7f ed                	jg     80049e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	56                   	push   %esi
  8004b5:	83 ec 04             	sub    $0x4,%esp
  8004b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004be:	ff 75 dc             	pushl  -0x24(%ebp)
  8004c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c4:	e8 e7 09 00 00       	call   800eb0 <__umoddi3>
  8004c9:	83 c4 14             	add    $0x14,%esp
  8004cc:	0f be 80 5d 10 80 00 	movsbl 0x80105d(%eax),%eax
  8004d3:	50                   	push   %eax
  8004d4:	ff d7                	call   *%edi
}
  8004d6:	83 c4 10             	add    $0x10,%esp
  8004d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004dc:	5b                   	pop    %ebx
  8004dd:	5e                   	pop    %esi
  8004de:	5f                   	pop    %edi
  8004df:	5d                   	pop    %ebp
  8004e0:	c3                   	ret    

008004e1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e1:	f3 0f 1e fb          	endbr32 
  8004e5:	55                   	push   %ebp
  8004e6:	89 e5                	mov    %esp,%ebp
  8004e8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004eb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ef:	8b 10                	mov    (%eax),%edx
  8004f1:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f4:	73 0a                	jae    800500 <sprintputch+0x1f>
		*b->buf++ = ch;
  8004f6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f9:	89 08                	mov    %ecx,(%eax)
  8004fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fe:	88 02                	mov    %al,(%edx)
}
  800500:	5d                   	pop    %ebp
  800501:	c3                   	ret    

00800502 <printfmt>:
{
  800502:	f3 0f 1e fb          	endbr32 
  800506:	55                   	push   %ebp
  800507:	89 e5                	mov    %esp,%ebp
  800509:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80050c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050f:	50                   	push   %eax
  800510:	ff 75 10             	pushl  0x10(%ebp)
  800513:	ff 75 0c             	pushl  0xc(%ebp)
  800516:	ff 75 08             	pushl  0x8(%ebp)
  800519:	e8 05 00 00 00       	call   800523 <vprintfmt>
}
  80051e:	83 c4 10             	add    $0x10,%esp
  800521:	c9                   	leave  
  800522:	c3                   	ret    

00800523 <vprintfmt>:
{
  800523:	f3 0f 1e fb          	endbr32 
  800527:	55                   	push   %ebp
  800528:	89 e5                	mov    %esp,%ebp
  80052a:	57                   	push   %edi
  80052b:	56                   	push   %esi
  80052c:	53                   	push   %ebx
  80052d:	83 ec 3c             	sub    $0x3c,%esp
  800530:	8b 75 08             	mov    0x8(%ebp),%esi
  800533:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800536:	8b 7d 10             	mov    0x10(%ebp),%edi
  800539:	e9 4a 03 00 00       	jmp    800888 <vprintfmt+0x365>
		padc = ' ';
  80053e:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800542:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800549:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800550:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800557:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80055c:	8d 47 01             	lea    0x1(%edi),%eax
  80055f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800562:	0f b6 17             	movzbl (%edi),%edx
  800565:	8d 42 dd             	lea    -0x23(%edx),%eax
  800568:	3c 55                	cmp    $0x55,%al
  80056a:	0f 87 de 03 00 00    	ja     80094e <vprintfmt+0x42b>
  800570:	0f b6 c0             	movzbl %al,%eax
  800573:	3e ff 24 85 20 11 80 	notrack jmp *0x801120(,%eax,4)
  80057a:	00 
  80057b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80057e:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800582:	eb d8                	jmp    80055c <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800584:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800587:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80058b:	eb cf                	jmp    80055c <vprintfmt+0x39>
  80058d:	0f b6 d2             	movzbl %dl,%edx
  800590:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800593:	b8 00 00 00 00       	mov    $0x0,%eax
  800598:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80059b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80059e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005a2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005a5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005a8:	83 f9 09             	cmp    $0x9,%ecx
  8005ab:	77 55                	ja     800602 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005ad:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005b0:	eb e9                	jmp    80059b <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8b 00                	mov    (%eax),%eax
  8005b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bd:	8d 40 04             	lea    0x4(%eax),%eax
  8005c0:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005c6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ca:	79 90                	jns    80055c <vprintfmt+0x39>
				width = precision, precision = -1;
  8005cc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d2:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005d9:	eb 81                	jmp    80055c <vprintfmt+0x39>
  8005db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005de:	85 c0                	test   %eax,%eax
  8005e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e5:	0f 49 d0             	cmovns %eax,%edx
  8005e8:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005ee:	e9 69 ff ff ff       	jmp    80055c <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005f6:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005fd:	e9 5a ff ff ff       	jmp    80055c <vprintfmt+0x39>
  800602:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800605:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800608:	eb bc                	jmp    8005c6 <vprintfmt+0xa3>
			lflag++;
  80060a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80060d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800610:	e9 47 ff ff ff       	jmp    80055c <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8d 78 04             	lea    0x4(%eax),%edi
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	53                   	push   %ebx
  80061f:	ff 30                	pushl  (%eax)
  800621:	ff d6                	call   *%esi
			break;
  800623:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800626:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800629:	e9 57 02 00 00       	jmp    800885 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 78 04             	lea    0x4(%eax),%edi
  800634:	8b 00                	mov    (%eax),%eax
  800636:	99                   	cltd   
  800637:	31 d0                	xor    %edx,%eax
  800639:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80063b:	83 f8 08             	cmp    $0x8,%eax
  80063e:	7f 23                	jg     800663 <vprintfmt+0x140>
  800640:	8b 14 85 80 12 80 00 	mov    0x801280(,%eax,4),%edx
  800647:	85 d2                	test   %edx,%edx
  800649:	74 18                	je     800663 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80064b:	52                   	push   %edx
  80064c:	68 7e 10 80 00       	push   $0x80107e
  800651:	53                   	push   %ebx
  800652:	56                   	push   %esi
  800653:	e8 aa fe ff ff       	call   800502 <printfmt>
  800658:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80065b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80065e:	e9 22 02 00 00       	jmp    800885 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800663:	50                   	push   %eax
  800664:	68 75 10 80 00       	push   $0x801075
  800669:	53                   	push   %ebx
  80066a:	56                   	push   %esi
  80066b:	e8 92 fe ff ff       	call   800502 <printfmt>
  800670:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800673:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800676:	e9 0a 02 00 00       	jmp    800885 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	83 c0 04             	add    $0x4,%eax
  800681:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800689:	85 d2                	test   %edx,%edx
  80068b:	b8 6e 10 80 00       	mov    $0x80106e,%eax
  800690:	0f 45 c2             	cmovne %edx,%eax
  800693:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800696:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80069a:	7e 06                	jle    8006a2 <vprintfmt+0x17f>
  80069c:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006a0:	75 0d                	jne    8006af <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006a5:	89 c7                	mov    %eax,%edi
  8006a7:	03 45 e0             	add    -0x20(%ebp),%eax
  8006aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ad:	eb 55                	jmp    800704 <vprintfmt+0x1e1>
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8006b5:	ff 75 cc             	pushl  -0x34(%ebp)
  8006b8:	e8 45 03 00 00       	call   800a02 <strnlen>
  8006bd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006c0:	29 c2                	sub    %eax,%edx
  8006c2:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006ca:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d1:	85 ff                	test   %edi,%edi
  8006d3:	7e 11                	jle    8006e6 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	53                   	push   %ebx
  8006d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8006dc:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006de:	83 ef 01             	sub    $0x1,%edi
  8006e1:	83 c4 10             	add    $0x10,%esp
  8006e4:	eb eb                	jmp    8006d1 <vprintfmt+0x1ae>
  8006e6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006e9:	85 d2                	test   %edx,%edx
  8006eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f0:	0f 49 c2             	cmovns %edx,%eax
  8006f3:	29 c2                	sub    %eax,%edx
  8006f5:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006f8:	eb a8                	jmp    8006a2 <vprintfmt+0x17f>
					putch(ch, putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	53                   	push   %ebx
  8006fe:	52                   	push   %edx
  8006ff:	ff d6                	call   *%esi
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800707:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800709:	83 c7 01             	add    $0x1,%edi
  80070c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800710:	0f be d0             	movsbl %al,%edx
  800713:	85 d2                	test   %edx,%edx
  800715:	74 4b                	je     800762 <vprintfmt+0x23f>
  800717:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80071b:	78 06                	js     800723 <vprintfmt+0x200>
  80071d:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800721:	78 1e                	js     800741 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800723:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800727:	74 d1                	je     8006fa <vprintfmt+0x1d7>
  800729:	0f be c0             	movsbl %al,%eax
  80072c:	83 e8 20             	sub    $0x20,%eax
  80072f:	83 f8 5e             	cmp    $0x5e,%eax
  800732:	76 c6                	jbe    8006fa <vprintfmt+0x1d7>
					putch('?', putdat);
  800734:	83 ec 08             	sub    $0x8,%esp
  800737:	53                   	push   %ebx
  800738:	6a 3f                	push   $0x3f
  80073a:	ff d6                	call   *%esi
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	eb c3                	jmp    800704 <vprintfmt+0x1e1>
  800741:	89 cf                	mov    %ecx,%edi
  800743:	eb 0e                	jmp    800753 <vprintfmt+0x230>
				putch(' ', putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	53                   	push   %ebx
  800749:	6a 20                	push   $0x20
  80074b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80074d:	83 ef 01             	sub    $0x1,%edi
  800750:	83 c4 10             	add    $0x10,%esp
  800753:	85 ff                	test   %edi,%edi
  800755:	7f ee                	jg     800745 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800757:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80075a:	89 45 14             	mov    %eax,0x14(%ebp)
  80075d:	e9 23 01 00 00       	jmp    800885 <vprintfmt+0x362>
  800762:	89 cf                	mov    %ecx,%edi
  800764:	eb ed                	jmp    800753 <vprintfmt+0x230>
	if (lflag >= 2)
  800766:	83 f9 01             	cmp    $0x1,%ecx
  800769:	7f 1b                	jg     800786 <vprintfmt+0x263>
	else if (lflag)
  80076b:	85 c9                	test   %ecx,%ecx
  80076d:	74 63                	je     8007d2 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80076f:	8b 45 14             	mov    0x14(%ebp),%eax
  800772:	8b 00                	mov    (%eax),%eax
  800774:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800777:	99                   	cltd   
  800778:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80077b:	8b 45 14             	mov    0x14(%ebp),%eax
  80077e:	8d 40 04             	lea    0x4(%eax),%eax
  800781:	89 45 14             	mov    %eax,0x14(%ebp)
  800784:	eb 17                	jmp    80079d <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800786:	8b 45 14             	mov    0x14(%ebp),%eax
  800789:	8b 50 04             	mov    0x4(%eax),%edx
  80078c:	8b 00                	mov    (%eax),%eax
  80078e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800791:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800794:	8b 45 14             	mov    0x14(%ebp),%eax
  800797:	8d 40 08             	lea    0x8(%eax),%eax
  80079a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80079d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007a0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007a3:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007a8:	85 c9                	test   %ecx,%ecx
  8007aa:	0f 89 bb 00 00 00    	jns    80086b <vprintfmt+0x348>
				putch('-', putdat);
  8007b0:	83 ec 08             	sub    $0x8,%esp
  8007b3:	53                   	push   %ebx
  8007b4:	6a 2d                	push   $0x2d
  8007b6:	ff d6                	call   *%esi
				num = -(long long) num;
  8007b8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007bb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007be:	f7 da                	neg    %edx
  8007c0:	83 d1 00             	adc    $0x0,%ecx
  8007c3:	f7 d9                	neg    %ecx
  8007c5:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007c8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007cd:	e9 99 00 00 00       	jmp    80086b <vprintfmt+0x348>
		return va_arg(*ap, int);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	8b 00                	mov    (%eax),%eax
  8007d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007da:	99                   	cltd   
  8007db:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007de:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e1:	8d 40 04             	lea    0x4(%eax),%eax
  8007e4:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e7:	eb b4                	jmp    80079d <vprintfmt+0x27a>
	if (lflag >= 2)
  8007e9:	83 f9 01             	cmp    $0x1,%ecx
  8007ec:	7f 1b                	jg     800809 <vprintfmt+0x2e6>
	else if (lflag)
  8007ee:	85 c9                	test   %ecx,%ecx
  8007f0:	74 2c                	je     80081e <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	8b 10                	mov    (%eax),%edx
  8007f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fc:	8d 40 04             	lea    0x4(%eax),%eax
  8007ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800802:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800807:	eb 62                	jmp    80086b <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800809:	8b 45 14             	mov    0x14(%ebp),%eax
  80080c:	8b 10                	mov    (%eax),%edx
  80080e:	8b 48 04             	mov    0x4(%eax),%ecx
  800811:	8d 40 08             	lea    0x8(%eax),%eax
  800814:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800817:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80081c:	eb 4d                	jmp    80086b <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80081e:	8b 45 14             	mov    0x14(%ebp),%eax
  800821:	8b 10                	mov    (%eax),%edx
  800823:	b9 00 00 00 00       	mov    $0x0,%ecx
  800828:	8d 40 04             	lea    0x4(%eax),%eax
  80082b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80082e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800833:	eb 36                	jmp    80086b <vprintfmt+0x348>
	if (lflag >= 2)
  800835:	83 f9 01             	cmp    $0x1,%ecx
  800838:	7f 17                	jg     800851 <vprintfmt+0x32e>
	else if (lflag)
  80083a:	85 c9                	test   %ecx,%ecx
  80083c:	74 6e                	je     8008ac <vprintfmt+0x389>
		return va_arg(*ap, long);
  80083e:	8b 45 14             	mov    0x14(%ebp),%eax
  800841:	8b 10                	mov    (%eax),%edx
  800843:	89 d0                	mov    %edx,%eax
  800845:	99                   	cltd   
  800846:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800849:	8d 49 04             	lea    0x4(%ecx),%ecx
  80084c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80084f:	eb 11                	jmp    800862 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800851:	8b 45 14             	mov    0x14(%ebp),%eax
  800854:	8b 50 04             	mov    0x4(%eax),%edx
  800857:	8b 00                	mov    (%eax),%eax
  800859:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80085c:	8d 49 08             	lea    0x8(%ecx),%ecx
  80085f:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800862:	89 d1                	mov    %edx,%ecx
  800864:	89 c2                	mov    %eax,%edx
            base = 8;
  800866:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80086b:	83 ec 0c             	sub    $0xc,%esp
  80086e:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800872:	57                   	push   %edi
  800873:	ff 75 e0             	pushl  -0x20(%ebp)
  800876:	50                   	push   %eax
  800877:	51                   	push   %ecx
  800878:	52                   	push   %edx
  800879:	89 da                	mov    %ebx,%edx
  80087b:	89 f0                	mov    %esi,%eax
  80087d:	e8 b6 fb ff ff       	call   800438 <printnum>
			break;
  800882:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800885:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800888:	83 c7 01             	add    $0x1,%edi
  80088b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80088f:	83 f8 25             	cmp    $0x25,%eax
  800892:	0f 84 a6 fc ff ff    	je     80053e <vprintfmt+0x1b>
			if (ch == '\0')
  800898:	85 c0                	test   %eax,%eax
  80089a:	0f 84 ce 00 00 00    	je     80096e <vprintfmt+0x44b>
			putch(ch, putdat);
  8008a0:	83 ec 08             	sub    $0x8,%esp
  8008a3:	53                   	push   %ebx
  8008a4:	50                   	push   %eax
  8008a5:	ff d6                	call   *%esi
  8008a7:	83 c4 10             	add    $0x10,%esp
  8008aa:	eb dc                	jmp    800888 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8008ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8008af:	8b 10                	mov    (%eax),%edx
  8008b1:	89 d0                	mov    %edx,%eax
  8008b3:	99                   	cltd   
  8008b4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008b7:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008ba:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008bd:	eb a3                	jmp    800862 <vprintfmt+0x33f>
			putch('0', putdat);
  8008bf:	83 ec 08             	sub    $0x8,%esp
  8008c2:	53                   	push   %ebx
  8008c3:	6a 30                	push   $0x30
  8008c5:	ff d6                	call   *%esi
			putch('x', putdat);
  8008c7:	83 c4 08             	add    $0x8,%esp
  8008ca:	53                   	push   %ebx
  8008cb:	6a 78                	push   $0x78
  8008cd:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d2:	8b 10                	mov    (%eax),%edx
  8008d4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008d9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008dc:	8d 40 04             	lea    0x4(%eax),%eax
  8008df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008e2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008e7:	eb 82                	jmp    80086b <vprintfmt+0x348>
	if (lflag >= 2)
  8008e9:	83 f9 01             	cmp    $0x1,%ecx
  8008ec:	7f 1e                	jg     80090c <vprintfmt+0x3e9>
	else if (lflag)
  8008ee:	85 c9                	test   %ecx,%ecx
  8008f0:	74 32                	je     800924 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  8008f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f5:	8b 10                	mov    (%eax),%edx
  8008f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008fc:	8d 40 04             	lea    0x4(%eax),%eax
  8008ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800902:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800907:	e9 5f ff ff ff       	jmp    80086b <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80090c:	8b 45 14             	mov    0x14(%ebp),%eax
  80090f:	8b 10                	mov    (%eax),%edx
  800911:	8b 48 04             	mov    0x4(%eax),%ecx
  800914:	8d 40 08             	lea    0x8(%eax),%eax
  800917:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80091a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80091f:	e9 47 ff ff ff       	jmp    80086b <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800924:	8b 45 14             	mov    0x14(%ebp),%eax
  800927:	8b 10                	mov    (%eax),%edx
  800929:	b9 00 00 00 00       	mov    $0x0,%ecx
  80092e:	8d 40 04             	lea    0x4(%eax),%eax
  800931:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800934:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800939:	e9 2d ff ff ff       	jmp    80086b <vprintfmt+0x348>
			putch(ch, putdat);
  80093e:	83 ec 08             	sub    $0x8,%esp
  800941:	53                   	push   %ebx
  800942:	6a 25                	push   $0x25
  800944:	ff d6                	call   *%esi
			break;
  800946:	83 c4 10             	add    $0x10,%esp
  800949:	e9 37 ff ff ff       	jmp    800885 <vprintfmt+0x362>
			putch('%', putdat);
  80094e:	83 ec 08             	sub    $0x8,%esp
  800951:	53                   	push   %ebx
  800952:	6a 25                	push   $0x25
  800954:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800956:	83 c4 10             	add    $0x10,%esp
  800959:	89 f8                	mov    %edi,%eax
  80095b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80095f:	74 05                	je     800966 <vprintfmt+0x443>
  800961:	83 e8 01             	sub    $0x1,%eax
  800964:	eb f5                	jmp    80095b <vprintfmt+0x438>
  800966:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800969:	e9 17 ff ff ff       	jmp    800885 <vprintfmt+0x362>
}
  80096e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800971:	5b                   	pop    %ebx
  800972:	5e                   	pop    %esi
  800973:	5f                   	pop    %edi
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800976:	f3 0f 1e fb          	endbr32 
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	83 ec 18             	sub    $0x18,%esp
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800986:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800989:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80098d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800990:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800997:	85 c0                	test   %eax,%eax
  800999:	74 26                	je     8009c1 <vsnprintf+0x4b>
  80099b:	85 d2                	test   %edx,%edx
  80099d:	7e 22                	jle    8009c1 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80099f:	ff 75 14             	pushl  0x14(%ebp)
  8009a2:	ff 75 10             	pushl  0x10(%ebp)
  8009a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009a8:	50                   	push   %eax
  8009a9:	68 e1 04 80 00       	push   $0x8004e1
  8009ae:	e8 70 fb ff ff       	call   800523 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009b6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009bc:	83 c4 10             	add    $0x10,%esp
}
  8009bf:	c9                   	leave  
  8009c0:	c3                   	ret    
		return -E_INVAL;
  8009c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009c6:	eb f7                	jmp    8009bf <vsnprintf+0x49>

008009c8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009c8:	f3 0f 1e fb          	endbr32 
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009d2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009d5:	50                   	push   %eax
  8009d6:	ff 75 10             	pushl  0x10(%ebp)
  8009d9:	ff 75 0c             	pushl  0xc(%ebp)
  8009dc:	ff 75 08             	pushl  0x8(%ebp)
  8009df:	e8 92 ff ff ff       	call   800976 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009e4:	c9                   	leave  
  8009e5:	c3                   	ret    

008009e6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009e6:	f3 0f 1e fb          	endbr32 
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009f9:	74 05                	je     800a00 <strlen+0x1a>
		n++;
  8009fb:	83 c0 01             	add    $0x1,%eax
  8009fe:	eb f5                	jmp    8009f5 <strlen+0xf>
	return n;
}
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a02:	f3 0f 1e fb          	endbr32 
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a14:	39 d0                	cmp    %edx,%eax
  800a16:	74 0d                	je     800a25 <strnlen+0x23>
  800a18:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a1c:	74 05                	je     800a23 <strnlen+0x21>
		n++;
  800a1e:	83 c0 01             	add    $0x1,%eax
  800a21:	eb f1                	jmp    800a14 <strnlen+0x12>
  800a23:	89 c2                	mov    %eax,%edx
	return n;
}
  800a25:	89 d0                	mov    %edx,%eax
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a29:	f3 0f 1e fb          	endbr32 
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	53                   	push   %ebx
  800a31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a37:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a40:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a43:	83 c0 01             	add    $0x1,%eax
  800a46:	84 d2                	test   %dl,%dl
  800a48:	75 f2                	jne    800a3c <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a4a:	89 c8                	mov    %ecx,%eax
  800a4c:	5b                   	pop    %ebx
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a4f:	f3 0f 1e fb          	endbr32 
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	53                   	push   %ebx
  800a57:	83 ec 10             	sub    $0x10,%esp
  800a5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a5d:	53                   	push   %ebx
  800a5e:	e8 83 ff ff ff       	call   8009e6 <strlen>
  800a63:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a66:	ff 75 0c             	pushl  0xc(%ebp)
  800a69:	01 d8                	add    %ebx,%eax
  800a6b:	50                   	push   %eax
  800a6c:	e8 b8 ff ff ff       	call   800a29 <strcpy>
	return dst;
}
  800a71:	89 d8                	mov    %ebx,%eax
  800a73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a78:	f3 0f 1e fb          	endbr32 
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	8b 75 08             	mov    0x8(%ebp),%esi
  800a84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a87:	89 f3                	mov    %esi,%ebx
  800a89:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a8c:	89 f0                	mov    %esi,%eax
  800a8e:	39 d8                	cmp    %ebx,%eax
  800a90:	74 11                	je     800aa3 <strncpy+0x2b>
		*dst++ = *src;
  800a92:	83 c0 01             	add    $0x1,%eax
  800a95:	0f b6 0a             	movzbl (%edx),%ecx
  800a98:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a9b:	80 f9 01             	cmp    $0x1,%cl
  800a9e:	83 da ff             	sbb    $0xffffffff,%edx
  800aa1:	eb eb                	jmp    800a8e <strncpy+0x16>
	}
	return ret;
}
  800aa3:	89 f0                	mov    %esi,%eax
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aa9:	f3 0f 1e fb          	endbr32 
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
  800ab2:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab8:	8b 55 10             	mov    0x10(%ebp),%edx
  800abb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800abd:	85 d2                	test   %edx,%edx
  800abf:	74 21                	je     800ae2 <strlcpy+0x39>
  800ac1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ac5:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800ac7:	39 c2                	cmp    %eax,%edx
  800ac9:	74 14                	je     800adf <strlcpy+0x36>
  800acb:	0f b6 19             	movzbl (%ecx),%ebx
  800ace:	84 db                	test   %bl,%bl
  800ad0:	74 0b                	je     800add <strlcpy+0x34>
			*dst++ = *src++;
  800ad2:	83 c1 01             	add    $0x1,%ecx
  800ad5:	83 c2 01             	add    $0x1,%edx
  800ad8:	88 5a ff             	mov    %bl,-0x1(%edx)
  800adb:	eb ea                	jmp    800ac7 <strlcpy+0x1e>
  800add:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800adf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ae2:	29 f0                	sub    %esi,%eax
}
  800ae4:	5b                   	pop    %ebx
  800ae5:	5e                   	pop    %esi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ae8:	f3 0f 1e fb          	endbr32 
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800af5:	0f b6 01             	movzbl (%ecx),%eax
  800af8:	84 c0                	test   %al,%al
  800afa:	74 0c                	je     800b08 <strcmp+0x20>
  800afc:	3a 02                	cmp    (%edx),%al
  800afe:	75 08                	jne    800b08 <strcmp+0x20>
		p++, q++;
  800b00:	83 c1 01             	add    $0x1,%ecx
  800b03:	83 c2 01             	add    $0x1,%edx
  800b06:	eb ed                	jmp    800af5 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b08:	0f b6 c0             	movzbl %al,%eax
  800b0b:	0f b6 12             	movzbl (%edx),%edx
  800b0e:	29 d0                	sub    %edx,%eax
}
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b12:	f3 0f 1e fb          	endbr32 
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	53                   	push   %ebx
  800b1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b20:	89 c3                	mov    %eax,%ebx
  800b22:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b25:	eb 06                	jmp    800b2d <strncmp+0x1b>
		n--, p++, q++;
  800b27:	83 c0 01             	add    $0x1,%eax
  800b2a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b2d:	39 d8                	cmp    %ebx,%eax
  800b2f:	74 16                	je     800b47 <strncmp+0x35>
  800b31:	0f b6 08             	movzbl (%eax),%ecx
  800b34:	84 c9                	test   %cl,%cl
  800b36:	74 04                	je     800b3c <strncmp+0x2a>
  800b38:	3a 0a                	cmp    (%edx),%cl
  800b3a:	74 eb                	je     800b27 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b3c:	0f b6 00             	movzbl (%eax),%eax
  800b3f:	0f b6 12             	movzbl (%edx),%edx
  800b42:	29 d0                	sub    %edx,%eax
}
  800b44:	5b                   	pop    %ebx
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    
		return 0;
  800b47:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4c:	eb f6                	jmp    800b44 <strncmp+0x32>

00800b4e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b4e:	f3 0f 1e fb          	endbr32 
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	8b 45 08             	mov    0x8(%ebp),%eax
  800b58:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b5c:	0f b6 10             	movzbl (%eax),%edx
  800b5f:	84 d2                	test   %dl,%dl
  800b61:	74 09                	je     800b6c <strchr+0x1e>
		if (*s == c)
  800b63:	38 ca                	cmp    %cl,%dl
  800b65:	74 0a                	je     800b71 <strchr+0x23>
	for (; *s; s++)
  800b67:	83 c0 01             	add    $0x1,%eax
  800b6a:	eb f0                	jmp    800b5c <strchr+0xe>
			return (char *) s;
	return 0;
  800b6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b73:	f3 0f 1e fb          	endbr32 
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b81:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b84:	38 ca                	cmp    %cl,%dl
  800b86:	74 09                	je     800b91 <strfind+0x1e>
  800b88:	84 d2                	test   %dl,%dl
  800b8a:	74 05                	je     800b91 <strfind+0x1e>
	for (; *s; s++)
  800b8c:	83 c0 01             	add    $0x1,%eax
  800b8f:	eb f0                	jmp    800b81 <strfind+0xe>
			break;
	return (char *) s;
}
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b93:	f3 0f 1e fb          	endbr32 
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
  800b9d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ba0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ba3:	85 c9                	test   %ecx,%ecx
  800ba5:	74 31                	je     800bd8 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ba7:	89 f8                	mov    %edi,%eax
  800ba9:	09 c8                	or     %ecx,%eax
  800bab:	a8 03                	test   $0x3,%al
  800bad:	75 23                	jne    800bd2 <memset+0x3f>
		c &= 0xFF;
  800baf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bb3:	89 d3                	mov    %edx,%ebx
  800bb5:	c1 e3 08             	shl    $0x8,%ebx
  800bb8:	89 d0                	mov    %edx,%eax
  800bba:	c1 e0 18             	shl    $0x18,%eax
  800bbd:	89 d6                	mov    %edx,%esi
  800bbf:	c1 e6 10             	shl    $0x10,%esi
  800bc2:	09 f0                	or     %esi,%eax
  800bc4:	09 c2                	or     %eax,%edx
  800bc6:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bc8:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800bcb:	89 d0                	mov    %edx,%eax
  800bcd:	fc                   	cld    
  800bce:	f3 ab                	rep stos %eax,%es:(%edi)
  800bd0:	eb 06                	jmp    800bd8 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd5:	fc                   	cld    
  800bd6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bd8:	89 f8                	mov    %edi,%eax
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5f                   	pop    %edi
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bdf:	f3 0f 1e fb          	endbr32 
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	8b 45 08             	mov    0x8(%ebp),%eax
  800beb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bf1:	39 c6                	cmp    %eax,%esi
  800bf3:	73 32                	jae    800c27 <memmove+0x48>
  800bf5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bf8:	39 c2                	cmp    %eax,%edx
  800bfa:	76 2b                	jbe    800c27 <memmove+0x48>
		s += n;
		d += n;
  800bfc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bff:	89 fe                	mov    %edi,%esi
  800c01:	09 ce                	or     %ecx,%esi
  800c03:	09 d6                	or     %edx,%esi
  800c05:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c0b:	75 0e                	jne    800c1b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c0d:	83 ef 04             	sub    $0x4,%edi
  800c10:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c13:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c16:	fd                   	std    
  800c17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c19:	eb 09                	jmp    800c24 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c1b:	83 ef 01             	sub    $0x1,%edi
  800c1e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c21:	fd                   	std    
  800c22:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c24:	fc                   	cld    
  800c25:	eb 1a                	jmp    800c41 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c27:	89 c2                	mov    %eax,%edx
  800c29:	09 ca                	or     %ecx,%edx
  800c2b:	09 f2                	or     %esi,%edx
  800c2d:	f6 c2 03             	test   $0x3,%dl
  800c30:	75 0a                	jne    800c3c <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c32:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c35:	89 c7                	mov    %eax,%edi
  800c37:	fc                   	cld    
  800c38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c3a:	eb 05                	jmp    800c41 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c3c:	89 c7                	mov    %eax,%edi
  800c3e:	fc                   	cld    
  800c3f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c45:	f3 0f 1e fb          	endbr32 
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c4f:	ff 75 10             	pushl  0x10(%ebp)
  800c52:	ff 75 0c             	pushl  0xc(%ebp)
  800c55:	ff 75 08             	pushl  0x8(%ebp)
  800c58:	e8 82 ff ff ff       	call   800bdf <memmove>
}
  800c5d:	c9                   	leave  
  800c5e:	c3                   	ret    

00800c5f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c5f:	f3 0f 1e fb          	endbr32 
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
  800c68:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c6e:	89 c6                	mov    %eax,%esi
  800c70:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c73:	39 f0                	cmp    %esi,%eax
  800c75:	74 1c                	je     800c93 <memcmp+0x34>
		if (*s1 != *s2)
  800c77:	0f b6 08             	movzbl (%eax),%ecx
  800c7a:	0f b6 1a             	movzbl (%edx),%ebx
  800c7d:	38 d9                	cmp    %bl,%cl
  800c7f:	75 08                	jne    800c89 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c81:	83 c0 01             	add    $0x1,%eax
  800c84:	83 c2 01             	add    $0x1,%edx
  800c87:	eb ea                	jmp    800c73 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800c89:	0f b6 c1             	movzbl %cl,%eax
  800c8c:	0f b6 db             	movzbl %bl,%ebx
  800c8f:	29 d8                	sub    %ebx,%eax
  800c91:	eb 05                	jmp    800c98 <memcmp+0x39>
	}

	return 0;
  800c93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c9c:	f3 0f 1e fb          	endbr32 
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ca9:	89 c2                	mov    %eax,%edx
  800cab:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cae:	39 d0                	cmp    %edx,%eax
  800cb0:	73 09                	jae    800cbb <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb2:	38 08                	cmp    %cl,(%eax)
  800cb4:	74 05                	je     800cbb <memfind+0x1f>
	for (; s < ends; s++)
  800cb6:	83 c0 01             	add    $0x1,%eax
  800cb9:	eb f3                	jmp    800cae <memfind+0x12>
			break;
	return (void *) s;
}
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cbd:	f3 0f 1e fb          	endbr32 
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ccd:	eb 03                	jmp    800cd2 <strtol+0x15>
		s++;
  800ccf:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800cd2:	0f b6 01             	movzbl (%ecx),%eax
  800cd5:	3c 20                	cmp    $0x20,%al
  800cd7:	74 f6                	je     800ccf <strtol+0x12>
  800cd9:	3c 09                	cmp    $0x9,%al
  800cdb:	74 f2                	je     800ccf <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800cdd:	3c 2b                	cmp    $0x2b,%al
  800cdf:	74 2a                	je     800d0b <strtol+0x4e>
	int neg = 0;
  800ce1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ce6:	3c 2d                	cmp    $0x2d,%al
  800ce8:	74 2b                	je     800d15 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cea:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cf0:	75 0f                	jne    800d01 <strtol+0x44>
  800cf2:	80 39 30             	cmpb   $0x30,(%ecx)
  800cf5:	74 28                	je     800d1f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cf7:	85 db                	test   %ebx,%ebx
  800cf9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cfe:	0f 44 d8             	cmove  %eax,%ebx
  800d01:	b8 00 00 00 00       	mov    $0x0,%eax
  800d06:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d09:	eb 46                	jmp    800d51 <strtol+0x94>
		s++;
  800d0b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d13:	eb d5                	jmp    800cea <strtol+0x2d>
		s++, neg = 1;
  800d15:	83 c1 01             	add    $0x1,%ecx
  800d18:	bf 01 00 00 00       	mov    $0x1,%edi
  800d1d:	eb cb                	jmp    800cea <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d1f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d23:	74 0e                	je     800d33 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d25:	85 db                	test   %ebx,%ebx
  800d27:	75 d8                	jne    800d01 <strtol+0x44>
		s++, base = 8;
  800d29:	83 c1 01             	add    $0x1,%ecx
  800d2c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d31:	eb ce                	jmp    800d01 <strtol+0x44>
		s += 2, base = 16;
  800d33:	83 c1 02             	add    $0x2,%ecx
  800d36:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d3b:	eb c4                	jmp    800d01 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d3d:	0f be d2             	movsbl %dl,%edx
  800d40:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d43:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d46:	7d 3a                	jge    800d82 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d48:	83 c1 01             	add    $0x1,%ecx
  800d4b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d4f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d51:	0f b6 11             	movzbl (%ecx),%edx
  800d54:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d57:	89 f3                	mov    %esi,%ebx
  800d59:	80 fb 09             	cmp    $0x9,%bl
  800d5c:	76 df                	jbe    800d3d <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800d5e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d61:	89 f3                	mov    %esi,%ebx
  800d63:	80 fb 19             	cmp    $0x19,%bl
  800d66:	77 08                	ja     800d70 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d68:	0f be d2             	movsbl %dl,%edx
  800d6b:	83 ea 57             	sub    $0x57,%edx
  800d6e:	eb d3                	jmp    800d43 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800d70:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d73:	89 f3                	mov    %esi,%ebx
  800d75:	80 fb 19             	cmp    $0x19,%bl
  800d78:	77 08                	ja     800d82 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d7a:	0f be d2             	movsbl %dl,%edx
  800d7d:	83 ea 37             	sub    $0x37,%edx
  800d80:	eb c1                	jmp    800d43 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d82:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d86:	74 05                	je     800d8d <strtol+0xd0>
		*endptr = (char *) s;
  800d88:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d8b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d8d:	89 c2                	mov    %eax,%edx
  800d8f:	f7 da                	neg    %edx
  800d91:	85 ff                	test   %edi,%edi
  800d93:	0f 45 c2             	cmovne %edx,%eax
}
  800d96:	5b                   	pop    %ebx
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    
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
