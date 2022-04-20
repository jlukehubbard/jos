
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 27 00 00 00       	call   800058 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003d:	68 53 03 80 00       	push   $0x800353
  800042:	6a 00                	push   $0x0
  800044:	e8 58 02 00 00       	call   8002a1 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800049:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800050:	00 00 00 
}
  800053:	83 c4 10             	add    $0x10,%esp
  800056:	c9                   	leave  
  800057:	c3                   	ret    

00800058 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800058:	f3 0f 1e fb          	endbr32 
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	56                   	push   %esi
  800060:	53                   	push   %ebx
  800061:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800064:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    envid_t envid = sys_getenvid();
  800067:	e8 d6 00 00 00       	call   800142 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  80006c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800071:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800074:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800079:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 db                	test   %ebx,%ebx
  800080:	7e 07                	jle    800089 <libmain+0x31>
		binaryname = argv[0];
  800082:	8b 06                	mov    (%esi),%eax
  800084:	a3 00 20 80 00       	mov    %eax,0x802000

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
  8000a9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ac:	6a 00                	push   $0x0
  8000ae:	e8 4a 00 00 00       	call   8000fd <sys_env_destroy>
}
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b8:	f3 0f 1e fb          	endbr32 
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cd:	89 c3                	mov    %eax,%ebx
  8000cf:	89 c7                	mov    %eax,%edi
  8000d1:	89 c6                	mov    %eax,%esi
  8000d3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d5:	5b                   	pop    %ebx
  8000d6:	5e                   	pop    %esi
  8000d7:	5f                   	pop    %edi
  8000d8:	5d                   	pop    %ebp
  8000d9:	c3                   	ret    

008000da <sys_cgetc>:

int
sys_cgetc(void)
{
  8000da:	f3 0f 1e fb          	endbr32 
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	57                   	push   %edi
  8000e2:	56                   	push   %esi
  8000e3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ee:	89 d1                	mov    %edx,%ecx
  8000f0:	89 d3                	mov    %edx,%ebx
  8000f2:	89 d7                	mov    %edx,%edi
  8000f4:	89 d6                	mov    %edx,%esi
  8000f6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5f                   	pop    %edi
  8000fb:	5d                   	pop    %ebp
  8000fc:	c3                   	ret    

008000fd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fd:	f3 0f 1e fb          	endbr32 
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	57                   	push   %edi
  800105:	56                   	push   %esi
  800106:	53                   	push   %ebx
  800107:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80010a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010f:	8b 55 08             	mov    0x8(%ebp),%edx
  800112:	b8 03 00 00 00       	mov    $0x3,%eax
  800117:	89 cb                	mov    %ecx,%ebx
  800119:	89 cf                	mov    %ecx,%edi
  80011b:	89 ce                	mov    %ecx,%esi
  80011d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80011f:	85 c0                	test   %eax,%eax
  800121:	7f 08                	jg     80012b <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800123:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800126:	5b                   	pop    %ebx
  800127:	5e                   	pop    %esi
  800128:	5f                   	pop    %edi
  800129:	5d                   	pop    %ebp
  80012a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80012b:	83 ec 0c             	sub    $0xc,%esp
  80012e:	50                   	push   %eax
  80012f:	6a 03                	push   $0x3
  800131:	68 ca 10 80 00       	push   $0x8010ca
  800136:	6a 23                	push   $0x23
  800138:	68 e7 10 80 00       	push   $0x8010e7
  80013d:	e8 37 02 00 00       	call   800379 <_panic>

00800142 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800142:	f3 0f 1e fb          	endbr32 
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	57                   	push   %edi
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014c:	ba 00 00 00 00       	mov    $0x0,%edx
  800151:	b8 02 00 00 00       	mov    $0x2,%eax
  800156:	89 d1                	mov    %edx,%ecx
  800158:	89 d3                	mov    %edx,%ebx
  80015a:	89 d7                	mov    %edx,%edi
  80015c:	89 d6                	mov    %edx,%esi
  80015e:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800160:	5b                   	pop    %ebx
  800161:	5e                   	pop    %esi
  800162:	5f                   	pop    %edi
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <sys_yield>:

void
sys_yield(void)
{
  800165:	f3 0f 1e fb          	endbr32 
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	57                   	push   %edi
  80016d:	56                   	push   %esi
  80016e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80016f:	ba 00 00 00 00       	mov    $0x0,%edx
  800174:	b8 0a 00 00 00       	mov    $0xa,%eax
  800179:	89 d1                	mov    %edx,%ecx
  80017b:	89 d3                	mov    %edx,%ebx
  80017d:	89 d7                	mov    %edx,%edi
  80017f:	89 d6                	mov    %edx,%esi
  800181:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800183:	5b                   	pop    %ebx
  800184:	5e                   	pop    %esi
  800185:	5f                   	pop    %edi
  800186:	5d                   	pop    %ebp
  800187:	c3                   	ret    

00800188 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800188:	f3 0f 1e fb          	endbr32 
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	57                   	push   %edi
  800190:	56                   	push   %esi
  800191:	53                   	push   %ebx
  800192:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800195:	be 00 00 00 00       	mov    $0x0,%esi
  80019a:	8b 55 08             	mov    0x8(%ebp),%edx
  80019d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a8:	89 f7                	mov    %esi,%edi
  8001aa:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ac:	85 c0                	test   %eax,%eax
  8001ae:	7f 08                	jg     8001b8 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	50                   	push   %eax
  8001bc:	6a 04                	push   $0x4
  8001be:	68 ca 10 80 00       	push   $0x8010ca
  8001c3:	6a 23                	push   $0x23
  8001c5:	68 e7 10 80 00       	push   $0x8010e7
  8001ca:	e8 aa 01 00 00       	call   800379 <_panic>

008001cf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001cf:	f3 0f 1e fb          	endbr32 
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	57                   	push   %edi
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ea:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ed:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f0:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001f2:	85 c0                	test   %eax,%eax
  8001f4:	7f 08                	jg     8001fe <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f9:	5b                   	pop    %ebx
  8001fa:	5e                   	pop    %esi
  8001fb:	5f                   	pop    %edi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	50                   	push   %eax
  800202:	6a 05                	push   $0x5
  800204:	68 ca 10 80 00       	push   $0x8010ca
  800209:	6a 23                	push   $0x23
  80020b:	68 e7 10 80 00       	push   $0x8010e7
  800210:	e8 64 01 00 00       	call   800379 <_panic>

00800215 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800215:	f3 0f 1e fb          	endbr32 
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	57                   	push   %edi
  80021d:	56                   	push   %esi
  80021e:	53                   	push   %ebx
  80021f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800222:	bb 00 00 00 00       	mov    $0x0,%ebx
  800227:	8b 55 08             	mov    0x8(%ebp),%edx
  80022a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022d:	b8 06 00 00 00       	mov    $0x6,%eax
  800232:	89 df                	mov    %ebx,%edi
  800234:	89 de                	mov    %ebx,%esi
  800236:	cd 30                	int    $0x30
	if(check && ret > 0)
  800238:	85 c0                	test   %eax,%eax
  80023a:	7f 08                	jg     800244 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80023c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023f:	5b                   	pop    %ebx
  800240:	5e                   	pop    %esi
  800241:	5f                   	pop    %edi
  800242:	5d                   	pop    %ebp
  800243:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	50                   	push   %eax
  800248:	6a 06                	push   $0x6
  80024a:	68 ca 10 80 00       	push   $0x8010ca
  80024f:	6a 23                	push   $0x23
  800251:	68 e7 10 80 00       	push   $0x8010e7
  800256:	e8 1e 01 00 00       	call   800379 <_panic>

0080025b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80025b:	f3 0f 1e fb          	endbr32 
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	8b 55 08             	mov    0x8(%ebp),%edx
  800270:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800273:	b8 08 00 00 00       	mov    $0x8,%eax
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7f 08                	jg     80028a <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 08                	push   $0x8
  800290:	68 ca 10 80 00       	push   $0x8010ca
  800295:	6a 23                	push   $0x23
  800297:	68 e7 10 80 00       	push   $0x8010e7
  80029c:	e8 d8 00 00 00       	call   800379 <_panic>

008002a1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a1:	f3 0f 1e fb          	endbr32 
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b9:	b8 09 00 00 00       	mov    $0x9,%eax
  8002be:	89 df                	mov    %ebx,%edi
  8002c0:	89 de                	mov    %ebx,%esi
  8002c2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	7f 08                	jg     8002d0 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cb:	5b                   	pop    %ebx
  8002cc:	5e                   	pop    %esi
  8002cd:	5f                   	pop    %edi
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	50                   	push   %eax
  8002d4:	6a 09                	push   $0x9
  8002d6:	68 ca 10 80 00       	push   $0x8010ca
  8002db:	6a 23                	push   $0x23
  8002dd:	68 e7 10 80 00       	push   $0x8010e7
  8002e2:	e8 92 00 00 00       	call   800379 <_panic>

008002e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e7:	f3 0f 1e fb          	endbr32 
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002fc:	be 00 00 00 00       	mov    $0x0,%esi
  800301:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800304:	8b 7d 14             	mov    0x14(%ebp),%edi
  800307:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030e:	f3 0f 1e fb          	endbr32 
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	57                   	push   %edi
  800316:	56                   	push   %esi
  800317:	53                   	push   %ebx
  800318:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80031b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800320:	8b 55 08             	mov    0x8(%ebp),%edx
  800323:	b8 0c 00 00 00       	mov    $0xc,%eax
  800328:	89 cb                	mov    %ecx,%ebx
  80032a:	89 cf                	mov    %ecx,%edi
  80032c:	89 ce                	mov    %ecx,%esi
  80032e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800330:	85 c0                	test   %eax,%eax
  800332:	7f 08                	jg     80033c <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800334:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800337:	5b                   	pop    %ebx
  800338:	5e                   	pop    %esi
  800339:	5f                   	pop    %edi
  80033a:	5d                   	pop    %ebp
  80033b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	50                   	push   %eax
  800340:	6a 0c                	push   $0xc
  800342:	68 ca 10 80 00       	push   $0x8010ca
  800347:	6a 23                	push   $0x23
  800349:	68 e7 10 80 00       	push   $0x8010e7
  80034e:	e8 26 00 00 00       	call   800379 <_panic>

00800353 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800353:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800354:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800359:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80035b:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  80035e:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  800362:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  800366:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  800369:	83 c4 08             	add    $0x8,%esp
    popa
  80036c:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $0x4, %esp
  80036d:	83 c4 04             	add    $0x4,%esp
    popf
  800370:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  800371:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  800374:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  800378:	c3                   	ret    

00800379 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800379:	f3 0f 1e fb          	endbr32 
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
  800380:	56                   	push   %esi
  800381:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800382:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800385:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80038b:	e8 b2 fd ff ff       	call   800142 <sys_getenvid>
  800390:	83 ec 0c             	sub    $0xc,%esp
  800393:	ff 75 0c             	pushl  0xc(%ebp)
  800396:	ff 75 08             	pushl  0x8(%ebp)
  800399:	56                   	push   %esi
  80039a:	50                   	push   %eax
  80039b:	68 f8 10 80 00       	push   $0x8010f8
  8003a0:	e8 bb 00 00 00       	call   800460 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003a5:	83 c4 18             	add    $0x18,%esp
  8003a8:	53                   	push   %ebx
  8003a9:	ff 75 10             	pushl  0x10(%ebp)
  8003ac:	e8 5a 00 00 00       	call   80040b <vcprintf>
	cprintf("\n");
  8003b1:	c7 04 24 71 13 80 00 	movl   $0x801371,(%esp)
  8003b8:	e8 a3 00 00 00       	call   800460 <cprintf>
  8003bd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003c0:	cc                   	int3   
  8003c1:	eb fd                	jmp    8003c0 <_panic+0x47>

008003c3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003c3:	f3 0f 1e fb          	endbr32 
  8003c7:	55                   	push   %ebp
  8003c8:	89 e5                	mov    %esp,%ebp
  8003ca:	53                   	push   %ebx
  8003cb:	83 ec 04             	sub    $0x4,%esp
  8003ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003d1:	8b 13                	mov    (%ebx),%edx
  8003d3:	8d 42 01             	lea    0x1(%edx),%eax
  8003d6:	89 03                	mov    %eax,(%ebx)
  8003d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003db:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003df:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003e4:	74 09                	je     8003ef <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003e6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003ed:	c9                   	leave  
  8003ee:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003ef:	83 ec 08             	sub    $0x8,%esp
  8003f2:	68 ff 00 00 00       	push   $0xff
  8003f7:	8d 43 08             	lea    0x8(%ebx),%eax
  8003fa:	50                   	push   %eax
  8003fb:	e8 b8 fc ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  800400:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800406:	83 c4 10             	add    $0x10,%esp
  800409:	eb db                	jmp    8003e6 <putch+0x23>

0080040b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80040b:	f3 0f 1e fb          	endbr32 
  80040f:	55                   	push   %ebp
  800410:	89 e5                	mov    %esp,%ebp
  800412:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800418:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80041f:	00 00 00 
	b.cnt = 0;
  800422:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800429:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80042c:	ff 75 0c             	pushl  0xc(%ebp)
  80042f:	ff 75 08             	pushl  0x8(%ebp)
  800432:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800438:	50                   	push   %eax
  800439:	68 c3 03 80 00       	push   $0x8003c3
  80043e:	e8 20 01 00 00       	call   800563 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800443:	83 c4 08             	add    $0x8,%esp
  800446:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80044c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800452:	50                   	push   %eax
  800453:	e8 60 fc ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
}
  800458:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80045e:	c9                   	leave  
  80045f:	c3                   	ret    

00800460 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800460:	f3 0f 1e fb          	endbr32 
  800464:	55                   	push   %ebp
  800465:	89 e5                	mov    %esp,%ebp
  800467:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80046a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80046d:	50                   	push   %eax
  80046e:	ff 75 08             	pushl  0x8(%ebp)
  800471:	e8 95 ff ff ff       	call   80040b <vcprintf>
	va_end(ap);

	return cnt;
}
  800476:	c9                   	leave  
  800477:	c3                   	ret    

00800478 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800478:	55                   	push   %ebp
  800479:	89 e5                	mov    %esp,%ebp
  80047b:	57                   	push   %edi
  80047c:	56                   	push   %esi
  80047d:	53                   	push   %ebx
  80047e:	83 ec 1c             	sub    $0x1c,%esp
  800481:	89 c7                	mov    %eax,%edi
  800483:	89 d6                	mov    %edx,%esi
  800485:	8b 45 08             	mov    0x8(%ebp),%eax
  800488:	8b 55 0c             	mov    0xc(%ebp),%edx
  80048b:	89 d1                	mov    %edx,%ecx
  80048d:	89 c2                	mov    %eax,%edx
  80048f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800492:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800495:	8b 45 10             	mov    0x10(%ebp),%eax
  800498:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80049b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004a5:	39 c2                	cmp    %eax,%edx
  8004a7:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8004aa:	72 3e                	jb     8004ea <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004ac:	83 ec 0c             	sub    $0xc,%esp
  8004af:	ff 75 18             	pushl  0x18(%ebp)
  8004b2:	83 eb 01             	sub    $0x1,%ebx
  8004b5:	53                   	push   %ebx
  8004b6:	50                   	push   %eax
  8004b7:	83 ec 08             	sub    $0x8,%esp
  8004ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c0:	ff 75 dc             	pushl  -0x24(%ebp)
  8004c3:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c6:	e8 95 09 00 00       	call   800e60 <__udivdi3>
  8004cb:	83 c4 18             	add    $0x18,%esp
  8004ce:	52                   	push   %edx
  8004cf:	50                   	push   %eax
  8004d0:	89 f2                	mov    %esi,%edx
  8004d2:	89 f8                	mov    %edi,%eax
  8004d4:	e8 9f ff ff ff       	call   800478 <printnum>
  8004d9:	83 c4 20             	add    $0x20,%esp
  8004dc:	eb 13                	jmp    8004f1 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	56                   	push   %esi
  8004e2:	ff 75 18             	pushl  0x18(%ebp)
  8004e5:	ff d7                	call   *%edi
  8004e7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004ea:	83 eb 01             	sub    $0x1,%ebx
  8004ed:	85 db                	test   %ebx,%ebx
  8004ef:	7f ed                	jg     8004de <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004f1:	83 ec 08             	sub    $0x8,%esp
  8004f4:	56                   	push   %esi
  8004f5:	83 ec 04             	sub    $0x4,%esp
  8004f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004fe:	ff 75 dc             	pushl  -0x24(%ebp)
  800501:	ff 75 d8             	pushl  -0x28(%ebp)
  800504:	e8 67 0a 00 00       	call   800f70 <__umoddi3>
  800509:	83 c4 14             	add    $0x14,%esp
  80050c:	0f be 80 1b 11 80 00 	movsbl 0x80111b(%eax),%eax
  800513:	50                   	push   %eax
  800514:	ff d7                	call   *%edi
}
  800516:	83 c4 10             	add    $0x10,%esp
  800519:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80051c:	5b                   	pop    %ebx
  80051d:	5e                   	pop    %esi
  80051e:	5f                   	pop    %edi
  80051f:	5d                   	pop    %ebp
  800520:	c3                   	ret    

00800521 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800521:	f3 0f 1e fb          	endbr32 
  800525:	55                   	push   %ebp
  800526:	89 e5                	mov    %esp,%ebp
  800528:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80052b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80052f:	8b 10                	mov    (%eax),%edx
  800531:	3b 50 04             	cmp    0x4(%eax),%edx
  800534:	73 0a                	jae    800540 <sprintputch+0x1f>
		*b->buf++ = ch;
  800536:	8d 4a 01             	lea    0x1(%edx),%ecx
  800539:	89 08                	mov    %ecx,(%eax)
  80053b:	8b 45 08             	mov    0x8(%ebp),%eax
  80053e:	88 02                	mov    %al,(%edx)
}
  800540:	5d                   	pop    %ebp
  800541:	c3                   	ret    

00800542 <printfmt>:
{
  800542:	f3 0f 1e fb          	endbr32 
  800546:	55                   	push   %ebp
  800547:	89 e5                	mov    %esp,%ebp
  800549:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80054c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80054f:	50                   	push   %eax
  800550:	ff 75 10             	pushl  0x10(%ebp)
  800553:	ff 75 0c             	pushl  0xc(%ebp)
  800556:	ff 75 08             	pushl  0x8(%ebp)
  800559:	e8 05 00 00 00       	call   800563 <vprintfmt>
}
  80055e:	83 c4 10             	add    $0x10,%esp
  800561:	c9                   	leave  
  800562:	c3                   	ret    

00800563 <vprintfmt>:
{
  800563:	f3 0f 1e fb          	endbr32 
  800567:	55                   	push   %ebp
  800568:	89 e5                	mov    %esp,%ebp
  80056a:	57                   	push   %edi
  80056b:	56                   	push   %esi
  80056c:	53                   	push   %ebx
  80056d:	83 ec 3c             	sub    $0x3c,%esp
  800570:	8b 75 08             	mov    0x8(%ebp),%esi
  800573:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800576:	8b 7d 10             	mov    0x10(%ebp),%edi
  800579:	e9 4a 03 00 00       	jmp    8008c8 <vprintfmt+0x365>
		padc = ' ';
  80057e:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800582:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800589:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800590:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800597:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80059c:	8d 47 01             	lea    0x1(%edi),%eax
  80059f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a2:	0f b6 17             	movzbl (%edi),%edx
  8005a5:	8d 42 dd             	lea    -0x23(%edx),%eax
  8005a8:	3c 55                	cmp    $0x55,%al
  8005aa:	0f 87 de 03 00 00    	ja     80098e <vprintfmt+0x42b>
  8005b0:	0f b6 c0             	movzbl %al,%eax
  8005b3:	3e ff 24 85 e0 11 80 	notrack jmp *0x8011e0(,%eax,4)
  8005ba:	00 
  8005bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005be:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005c2:	eb d8                	jmp    80059c <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c7:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005cb:	eb cf                	jmp    80059c <vprintfmt+0x39>
  8005cd:	0f b6 d2             	movzbl %dl,%edx
  8005d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005db:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005de:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005e2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005e5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005e8:	83 f9 09             	cmp    $0x9,%ecx
  8005eb:	77 55                	ja     800642 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005ed:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005f0:	eb e9                	jmp    8005db <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8b 00                	mov    (%eax),%eax
  8005f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 40 04             	lea    0x4(%eax),%eax
  800600:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800603:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800606:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80060a:	79 90                	jns    80059c <vprintfmt+0x39>
				width = precision, precision = -1;
  80060c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80060f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800612:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800619:	eb 81                	jmp    80059c <vprintfmt+0x39>
  80061b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80061e:	85 c0                	test   %eax,%eax
  800620:	ba 00 00 00 00       	mov    $0x0,%edx
  800625:	0f 49 d0             	cmovns %eax,%edx
  800628:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80062b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80062e:	e9 69 ff ff ff       	jmp    80059c <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800633:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800636:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80063d:	e9 5a ff ff ff       	jmp    80059c <vprintfmt+0x39>
  800642:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800645:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800648:	eb bc                	jmp    800606 <vprintfmt+0xa3>
			lflag++;
  80064a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80064d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800650:	e9 47 ff ff ff       	jmp    80059c <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8d 78 04             	lea    0x4(%eax),%edi
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	53                   	push   %ebx
  80065f:	ff 30                	pushl  (%eax)
  800661:	ff d6                	call   *%esi
			break;
  800663:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800666:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800669:	e9 57 02 00 00       	jmp    8008c5 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80066e:	8b 45 14             	mov    0x14(%ebp),%eax
  800671:	8d 78 04             	lea    0x4(%eax),%edi
  800674:	8b 00                	mov    (%eax),%eax
  800676:	99                   	cltd   
  800677:	31 d0                	xor    %edx,%eax
  800679:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80067b:	83 f8 08             	cmp    $0x8,%eax
  80067e:	7f 23                	jg     8006a3 <vprintfmt+0x140>
  800680:	8b 14 85 40 13 80 00 	mov    0x801340(,%eax,4),%edx
  800687:	85 d2                	test   %edx,%edx
  800689:	74 18                	je     8006a3 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80068b:	52                   	push   %edx
  80068c:	68 3c 11 80 00       	push   $0x80113c
  800691:	53                   	push   %ebx
  800692:	56                   	push   %esi
  800693:	e8 aa fe ff ff       	call   800542 <printfmt>
  800698:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80069b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80069e:	e9 22 02 00 00       	jmp    8008c5 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8006a3:	50                   	push   %eax
  8006a4:	68 33 11 80 00       	push   $0x801133
  8006a9:	53                   	push   %ebx
  8006aa:	56                   	push   %esi
  8006ab:	e8 92 fe ff ff       	call   800542 <printfmt>
  8006b0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006b3:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8006b6:	e9 0a 02 00 00       	jmp    8008c5 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	83 c0 04             	add    $0x4,%eax
  8006c1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8006c9:	85 d2                	test   %edx,%edx
  8006cb:	b8 2c 11 80 00       	mov    $0x80112c,%eax
  8006d0:	0f 45 c2             	cmovne %edx,%eax
  8006d3:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006d6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006da:	7e 06                	jle    8006e2 <vprintfmt+0x17f>
  8006dc:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006e0:	75 0d                	jne    8006ef <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006e5:	89 c7                	mov    %eax,%edi
  8006e7:	03 45 e0             	add    -0x20(%ebp),%eax
  8006ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ed:	eb 55                	jmp    800744 <vprintfmt+0x1e1>
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	ff 75 d8             	pushl  -0x28(%ebp)
  8006f5:	ff 75 cc             	pushl  -0x34(%ebp)
  8006f8:	e8 45 03 00 00       	call   800a42 <strnlen>
  8006fd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800700:	29 c2                	sub    %eax,%edx
  800702:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80070a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80070e:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800711:	85 ff                	test   %edi,%edi
  800713:	7e 11                	jle    800726 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800715:	83 ec 08             	sub    $0x8,%esp
  800718:	53                   	push   %ebx
  800719:	ff 75 e0             	pushl  -0x20(%ebp)
  80071c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80071e:	83 ef 01             	sub    $0x1,%edi
  800721:	83 c4 10             	add    $0x10,%esp
  800724:	eb eb                	jmp    800711 <vprintfmt+0x1ae>
  800726:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800729:	85 d2                	test   %edx,%edx
  80072b:	b8 00 00 00 00       	mov    $0x0,%eax
  800730:	0f 49 c2             	cmovns %edx,%eax
  800733:	29 c2                	sub    %eax,%edx
  800735:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800738:	eb a8                	jmp    8006e2 <vprintfmt+0x17f>
					putch(ch, putdat);
  80073a:	83 ec 08             	sub    $0x8,%esp
  80073d:	53                   	push   %ebx
  80073e:	52                   	push   %edx
  80073f:	ff d6                	call   *%esi
  800741:	83 c4 10             	add    $0x10,%esp
  800744:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800747:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800749:	83 c7 01             	add    $0x1,%edi
  80074c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800750:	0f be d0             	movsbl %al,%edx
  800753:	85 d2                	test   %edx,%edx
  800755:	74 4b                	je     8007a2 <vprintfmt+0x23f>
  800757:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80075b:	78 06                	js     800763 <vprintfmt+0x200>
  80075d:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800761:	78 1e                	js     800781 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800763:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800767:	74 d1                	je     80073a <vprintfmt+0x1d7>
  800769:	0f be c0             	movsbl %al,%eax
  80076c:	83 e8 20             	sub    $0x20,%eax
  80076f:	83 f8 5e             	cmp    $0x5e,%eax
  800772:	76 c6                	jbe    80073a <vprintfmt+0x1d7>
					putch('?', putdat);
  800774:	83 ec 08             	sub    $0x8,%esp
  800777:	53                   	push   %ebx
  800778:	6a 3f                	push   $0x3f
  80077a:	ff d6                	call   *%esi
  80077c:	83 c4 10             	add    $0x10,%esp
  80077f:	eb c3                	jmp    800744 <vprintfmt+0x1e1>
  800781:	89 cf                	mov    %ecx,%edi
  800783:	eb 0e                	jmp    800793 <vprintfmt+0x230>
				putch(' ', putdat);
  800785:	83 ec 08             	sub    $0x8,%esp
  800788:	53                   	push   %ebx
  800789:	6a 20                	push   $0x20
  80078b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80078d:	83 ef 01             	sub    $0x1,%edi
  800790:	83 c4 10             	add    $0x10,%esp
  800793:	85 ff                	test   %edi,%edi
  800795:	7f ee                	jg     800785 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800797:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80079a:	89 45 14             	mov    %eax,0x14(%ebp)
  80079d:	e9 23 01 00 00       	jmp    8008c5 <vprintfmt+0x362>
  8007a2:	89 cf                	mov    %ecx,%edi
  8007a4:	eb ed                	jmp    800793 <vprintfmt+0x230>
	if (lflag >= 2)
  8007a6:	83 f9 01             	cmp    $0x1,%ecx
  8007a9:	7f 1b                	jg     8007c6 <vprintfmt+0x263>
	else if (lflag)
  8007ab:	85 c9                	test   %ecx,%ecx
  8007ad:	74 63                	je     800812 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8007af:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b2:	8b 00                	mov    (%eax),%eax
  8007b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b7:	99                   	cltd   
  8007b8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007be:	8d 40 04             	lea    0x4(%eax),%eax
  8007c1:	89 45 14             	mov    %eax,0x14(%ebp)
  8007c4:	eb 17                	jmp    8007dd <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	8b 50 04             	mov    0x4(%eax),%edx
  8007cc:	8b 00                	mov    (%eax),%eax
  8007ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	8d 40 08             	lea    0x8(%eax),%eax
  8007da:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007dd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007e0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007e3:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007e8:	85 c9                	test   %ecx,%ecx
  8007ea:	0f 89 bb 00 00 00    	jns    8008ab <vprintfmt+0x348>
				putch('-', putdat);
  8007f0:	83 ec 08             	sub    $0x8,%esp
  8007f3:	53                   	push   %ebx
  8007f4:	6a 2d                	push   $0x2d
  8007f6:	ff d6                	call   *%esi
				num = -(long long) num;
  8007f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007fb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007fe:	f7 da                	neg    %edx
  800800:	83 d1 00             	adc    $0x0,%ecx
  800803:	f7 d9                	neg    %ecx
  800805:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800808:	b8 0a 00 00 00       	mov    $0xa,%eax
  80080d:	e9 99 00 00 00       	jmp    8008ab <vprintfmt+0x348>
		return va_arg(*ap, int);
  800812:	8b 45 14             	mov    0x14(%ebp),%eax
  800815:	8b 00                	mov    (%eax),%eax
  800817:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80081a:	99                   	cltd   
  80081b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80081e:	8b 45 14             	mov    0x14(%ebp),%eax
  800821:	8d 40 04             	lea    0x4(%eax),%eax
  800824:	89 45 14             	mov    %eax,0x14(%ebp)
  800827:	eb b4                	jmp    8007dd <vprintfmt+0x27a>
	if (lflag >= 2)
  800829:	83 f9 01             	cmp    $0x1,%ecx
  80082c:	7f 1b                	jg     800849 <vprintfmt+0x2e6>
	else if (lflag)
  80082e:	85 c9                	test   %ecx,%ecx
  800830:	74 2c                	je     80085e <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800832:	8b 45 14             	mov    0x14(%ebp),%eax
  800835:	8b 10                	mov    (%eax),%edx
  800837:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083c:	8d 40 04             	lea    0x4(%eax),%eax
  80083f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800842:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800847:	eb 62                	jmp    8008ab <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800849:	8b 45 14             	mov    0x14(%ebp),%eax
  80084c:	8b 10                	mov    (%eax),%edx
  80084e:	8b 48 04             	mov    0x4(%eax),%ecx
  800851:	8d 40 08             	lea    0x8(%eax),%eax
  800854:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800857:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80085c:	eb 4d                	jmp    8008ab <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80085e:	8b 45 14             	mov    0x14(%ebp),%eax
  800861:	8b 10                	mov    (%eax),%edx
  800863:	b9 00 00 00 00       	mov    $0x0,%ecx
  800868:	8d 40 04             	lea    0x4(%eax),%eax
  80086b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80086e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800873:	eb 36                	jmp    8008ab <vprintfmt+0x348>
	if (lflag >= 2)
  800875:	83 f9 01             	cmp    $0x1,%ecx
  800878:	7f 17                	jg     800891 <vprintfmt+0x32e>
	else if (lflag)
  80087a:	85 c9                	test   %ecx,%ecx
  80087c:	74 6e                	je     8008ec <vprintfmt+0x389>
		return va_arg(*ap, long);
  80087e:	8b 45 14             	mov    0x14(%ebp),%eax
  800881:	8b 10                	mov    (%eax),%edx
  800883:	89 d0                	mov    %edx,%eax
  800885:	99                   	cltd   
  800886:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800889:	8d 49 04             	lea    0x4(%ecx),%ecx
  80088c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80088f:	eb 11                	jmp    8008a2 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800891:	8b 45 14             	mov    0x14(%ebp),%eax
  800894:	8b 50 04             	mov    0x4(%eax),%edx
  800897:	8b 00                	mov    (%eax),%eax
  800899:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80089c:	8d 49 08             	lea    0x8(%ecx),%ecx
  80089f:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8008a2:	89 d1                	mov    %edx,%ecx
  8008a4:	89 c2                	mov    %eax,%edx
            base = 8;
  8008a6:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008ab:	83 ec 0c             	sub    $0xc,%esp
  8008ae:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008b2:	57                   	push   %edi
  8008b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8008b6:	50                   	push   %eax
  8008b7:	51                   	push   %ecx
  8008b8:	52                   	push   %edx
  8008b9:	89 da                	mov    %ebx,%edx
  8008bb:	89 f0                	mov    %esi,%eax
  8008bd:	e8 b6 fb ff ff       	call   800478 <printnum>
			break;
  8008c2:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008c8:	83 c7 01             	add    $0x1,%edi
  8008cb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008cf:	83 f8 25             	cmp    $0x25,%eax
  8008d2:	0f 84 a6 fc ff ff    	je     80057e <vprintfmt+0x1b>
			if (ch == '\0')
  8008d8:	85 c0                	test   %eax,%eax
  8008da:	0f 84 ce 00 00 00    	je     8009ae <vprintfmt+0x44b>
			putch(ch, putdat);
  8008e0:	83 ec 08             	sub    $0x8,%esp
  8008e3:	53                   	push   %ebx
  8008e4:	50                   	push   %eax
  8008e5:	ff d6                	call   *%esi
  8008e7:	83 c4 10             	add    $0x10,%esp
  8008ea:	eb dc                	jmp    8008c8 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8008ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ef:	8b 10                	mov    (%eax),%edx
  8008f1:	89 d0                	mov    %edx,%eax
  8008f3:	99                   	cltd   
  8008f4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008f7:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008fa:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008fd:	eb a3                	jmp    8008a2 <vprintfmt+0x33f>
			putch('0', putdat);
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	53                   	push   %ebx
  800903:	6a 30                	push   $0x30
  800905:	ff d6                	call   *%esi
			putch('x', putdat);
  800907:	83 c4 08             	add    $0x8,%esp
  80090a:	53                   	push   %ebx
  80090b:	6a 78                	push   $0x78
  80090d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80090f:	8b 45 14             	mov    0x14(%ebp),%eax
  800912:	8b 10                	mov    (%eax),%edx
  800914:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800919:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80091c:	8d 40 04             	lea    0x4(%eax),%eax
  80091f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800922:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800927:	eb 82                	jmp    8008ab <vprintfmt+0x348>
	if (lflag >= 2)
  800929:	83 f9 01             	cmp    $0x1,%ecx
  80092c:	7f 1e                	jg     80094c <vprintfmt+0x3e9>
	else if (lflag)
  80092e:	85 c9                	test   %ecx,%ecx
  800930:	74 32                	je     800964 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800932:	8b 45 14             	mov    0x14(%ebp),%eax
  800935:	8b 10                	mov    (%eax),%edx
  800937:	b9 00 00 00 00       	mov    $0x0,%ecx
  80093c:	8d 40 04             	lea    0x4(%eax),%eax
  80093f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800942:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800947:	e9 5f ff ff ff       	jmp    8008ab <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80094c:	8b 45 14             	mov    0x14(%ebp),%eax
  80094f:	8b 10                	mov    (%eax),%edx
  800951:	8b 48 04             	mov    0x4(%eax),%ecx
  800954:	8d 40 08             	lea    0x8(%eax),%eax
  800957:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80095a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80095f:	e9 47 ff ff ff       	jmp    8008ab <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800964:	8b 45 14             	mov    0x14(%ebp),%eax
  800967:	8b 10                	mov    (%eax),%edx
  800969:	b9 00 00 00 00       	mov    $0x0,%ecx
  80096e:	8d 40 04             	lea    0x4(%eax),%eax
  800971:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800974:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800979:	e9 2d ff ff ff       	jmp    8008ab <vprintfmt+0x348>
			putch(ch, putdat);
  80097e:	83 ec 08             	sub    $0x8,%esp
  800981:	53                   	push   %ebx
  800982:	6a 25                	push   $0x25
  800984:	ff d6                	call   *%esi
			break;
  800986:	83 c4 10             	add    $0x10,%esp
  800989:	e9 37 ff ff ff       	jmp    8008c5 <vprintfmt+0x362>
			putch('%', putdat);
  80098e:	83 ec 08             	sub    $0x8,%esp
  800991:	53                   	push   %ebx
  800992:	6a 25                	push   $0x25
  800994:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800996:	83 c4 10             	add    $0x10,%esp
  800999:	89 f8                	mov    %edi,%eax
  80099b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80099f:	74 05                	je     8009a6 <vprintfmt+0x443>
  8009a1:	83 e8 01             	sub    $0x1,%eax
  8009a4:	eb f5                	jmp    80099b <vprintfmt+0x438>
  8009a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009a9:	e9 17 ff ff ff       	jmp    8008c5 <vprintfmt+0x362>
}
  8009ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009b1:	5b                   	pop    %ebx
  8009b2:	5e                   	pop    %esi
  8009b3:	5f                   	pop    %edi
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009b6:	f3 0f 1e fb          	endbr32 
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	83 ec 18             	sub    $0x18,%esp
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009c9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009cd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009d7:	85 c0                	test   %eax,%eax
  8009d9:	74 26                	je     800a01 <vsnprintf+0x4b>
  8009db:	85 d2                	test   %edx,%edx
  8009dd:	7e 22                	jle    800a01 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009df:	ff 75 14             	pushl  0x14(%ebp)
  8009e2:	ff 75 10             	pushl  0x10(%ebp)
  8009e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009e8:	50                   	push   %eax
  8009e9:	68 21 05 80 00       	push   $0x800521
  8009ee:	e8 70 fb ff ff       	call   800563 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009f6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009fc:	83 c4 10             	add    $0x10,%esp
}
  8009ff:	c9                   	leave  
  800a00:	c3                   	ret    
		return -E_INVAL;
  800a01:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a06:	eb f7                	jmp    8009ff <vsnprintf+0x49>

00800a08 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a08:	f3 0f 1e fb          	endbr32 
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a12:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a15:	50                   	push   %eax
  800a16:	ff 75 10             	pushl  0x10(%ebp)
  800a19:	ff 75 0c             	pushl  0xc(%ebp)
  800a1c:	ff 75 08             	pushl  0x8(%ebp)
  800a1f:	e8 92 ff ff ff       	call   8009b6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a24:	c9                   	leave  
  800a25:	c3                   	ret    

00800a26 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a26:	f3 0f 1e fb          	endbr32 
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a30:	b8 00 00 00 00       	mov    $0x0,%eax
  800a35:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a39:	74 05                	je     800a40 <strlen+0x1a>
		n++;
  800a3b:	83 c0 01             	add    $0x1,%eax
  800a3e:	eb f5                	jmp    800a35 <strlen+0xf>
	return n;
}
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a42:	f3 0f 1e fb          	endbr32 
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a54:	39 d0                	cmp    %edx,%eax
  800a56:	74 0d                	je     800a65 <strnlen+0x23>
  800a58:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a5c:	74 05                	je     800a63 <strnlen+0x21>
		n++;
  800a5e:	83 c0 01             	add    $0x1,%eax
  800a61:	eb f1                	jmp    800a54 <strnlen+0x12>
  800a63:	89 c2                	mov    %eax,%edx
	return n;
}
  800a65:	89 d0                	mov    %edx,%eax
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a69:	f3 0f 1e fb          	endbr32 
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	53                   	push   %ebx
  800a71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a77:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a80:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a83:	83 c0 01             	add    $0x1,%eax
  800a86:	84 d2                	test   %dl,%dl
  800a88:	75 f2                	jne    800a7c <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a8a:	89 c8                	mov    %ecx,%eax
  800a8c:	5b                   	pop    %ebx
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    

00800a8f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a8f:	f3 0f 1e fb          	endbr32 
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	53                   	push   %ebx
  800a97:	83 ec 10             	sub    $0x10,%esp
  800a9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a9d:	53                   	push   %ebx
  800a9e:	e8 83 ff ff ff       	call   800a26 <strlen>
  800aa3:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800aa6:	ff 75 0c             	pushl  0xc(%ebp)
  800aa9:	01 d8                	add    %ebx,%eax
  800aab:	50                   	push   %eax
  800aac:	e8 b8 ff ff ff       	call   800a69 <strcpy>
	return dst;
}
  800ab1:	89 d8                	mov    %ebx,%eax
  800ab3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ab6:	c9                   	leave  
  800ab7:	c3                   	ret    

00800ab8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ab8:	f3 0f 1e fb          	endbr32 
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac7:	89 f3                	mov    %esi,%ebx
  800ac9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800acc:	89 f0                	mov    %esi,%eax
  800ace:	39 d8                	cmp    %ebx,%eax
  800ad0:	74 11                	je     800ae3 <strncpy+0x2b>
		*dst++ = *src;
  800ad2:	83 c0 01             	add    $0x1,%eax
  800ad5:	0f b6 0a             	movzbl (%edx),%ecx
  800ad8:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800adb:	80 f9 01             	cmp    $0x1,%cl
  800ade:	83 da ff             	sbb    $0xffffffff,%edx
  800ae1:	eb eb                	jmp    800ace <strncpy+0x16>
	}
	return ret;
}
  800ae3:	89 f0                	mov    %esi,%eax
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ae9:	f3 0f 1e fb          	endbr32 
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
  800af2:	8b 75 08             	mov    0x8(%ebp),%esi
  800af5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af8:	8b 55 10             	mov    0x10(%ebp),%edx
  800afb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800afd:	85 d2                	test   %edx,%edx
  800aff:	74 21                	je     800b22 <strlcpy+0x39>
  800b01:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b05:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b07:	39 c2                	cmp    %eax,%edx
  800b09:	74 14                	je     800b1f <strlcpy+0x36>
  800b0b:	0f b6 19             	movzbl (%ecx),%ebx
  800b0e:	84 db                	test   %bl,%bl
  800b10:	74 0b                	je     800b1d <strlcpy+0x34>
			*dst++ = *src++;
  800b12:	83 c1 01             	add    $0x1,%ecx
  800b15:	83 c2 01             	add    $0x1,%edx
  800b18:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b1b:	eb ea                	jmp    800b07 <strlcpy+0x1e>
  800b1d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b1f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b22:	29 f0                	sub    %esi,%eax
}
  800b24:	5b                   	pop    %ebx
  800b25:	5e                   	pop    %esi
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b28:	f3 0f 1e fb          	endbr32 
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b32:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b35:	0f b6 01             	movzbl (%ecx),%eax
  800b38:	84 c0                	test   %al,%al
  800b3a:	74 0c                	je     800b48 <strcmp+0x20>
  800b3c:	3a 02                	cmp    (%edx),%al
  800b3e:	75 08                	jne    800b48 <strcmp+0x20>
		p++, q++;
  800b40:	83 c1 01             	add    $0x1,%ecx
  800b43:	83 c2 01             	add    $0x1,%edx
  800b46:	eb ed                	jmp    800b35 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b48:	0f b6 c0             	movzbl %al,%eax
  800b4b:	0f b6 12             	movzbl (%edx),%edx
  800b4e:	29 d0                	sub    %edx,%eax
}
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b52:	f3 0f 1e fb          	endbr32 
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	53                   	push   %ebx
  800b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b60:	89 c3                	mov    %eax,%ebx
  800b62:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b65:	eb 06                	jmp    800b6d <strncmp+0x1b>
		n--, p++, q++;
  800b67:	83 c0 01             	add    $0x1,%eax
  800b6a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b6d:	39 d8                	cmp    %ebx,%eax
  800b6f:	74 16                	je     800b87 <strncmp+0x35>
  800b71:	0f b6 08             	movzbl (%eax),%ecx
  800b74:	84 c9                	test   %cl,%cl
  800b76:	74 04                	je     800b7c <strncmp+0x2a>
  800b78:	3a 0a                	cmp    (%edx),%cl
  800b7a:	74 eb                	je     800b67 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b7c:	0f b6 00             	movzbl (%eax),%eax
  800b7f:	0f b6 12             	movzbl (%edx),%edx
  800b82:	29 d0                	sub    %edx,%eax
}
  800b84:	5b                   	pop    %ebx
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    
		return 0;
  800b87:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8c:	eb f6                	jmp    800b84 <strncmp+0x32>

00800b8e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b8e:	f3 0f 1e fb          	endbr32 
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	8b 45 08             	mov    0x8(%ebp),%eax
  800b98:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b9c:	0f b6 10             	movzbl (%eax),%edx
  800b9f:	84 d2                	test   %dl,%dl
  800ba1:	74 09                	je     800bac <strchr+0x1e>
		if (*s == c)
  800ba3:	38 ca                	cmp    %cl,%dl
  800ba5:	74 0a                	je     800bb1 <strchr+0x23>
	for (; *s; s++)
  800ba7:	83 c0 01             	add    $0x1,%eax
  800baa:	eb f0                	jmp    800b9c <strchr+0xe>
			return (char *) s;
	return 0;
  800bac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bb3:	f3 0f 1e fb          	endbr32 
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bc1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bc4:	38 ca                	cmp    %cl,%dl
  800bc6:	74 09                	je     800bd1 <strfind+0x1e>
  800bc8:	84 d2                	test   %dl,%dl
  800bca:	74 05                	je     800bd1 <strfind+0x1e>
	for (; *s; s++)
  800bcc:	83 c0 01             	add    $0x1,%eax
  800bcf:	eb f0                	jmp    800bc1 <strfind+0xe>
			break;
	return (char *) s;
}
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bd3:	f3 0f 1e fb          	endbr32 
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
  800bdd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800be0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800be3:	85 c9                	test   %ecx,%ecx
  800be5:	74 31                	je     800c18 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800be7:	89 f8                	mov    %edi,%eax
  800be9:	09 c8                	or     %ecx,%eax
  800beb:	a8 03                	test   $0x3,%al
  800bed:	75 23                	jne    800c12 <memset+0x3f>
		c &= 0xFF;
  800bef:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bf3:	89 d3                	mov    %edx,%ebx
  800bf5:	c1 e3 08             	shl    $0x8,%ebx
  800bf8:	89 d0                	mov    %edx,%eax
  800bfa:	c1 e0 18             	shl    $0x18,%eax
  800bfd:	89 d6                	mov    %edx,%esi
  800bff:	c1 e6 10             	shl    $0x10,%esi
  800c02:	09 f0                	or     %esi,%eax
  800c04:	09 c2                	or     %eax,%edx
  800c06:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c08:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c0b:	89 d0                	mov    %edx,%eax
  800c0d:	fc                   	cld    
  800c0e:	f3 ab                	rep stos %eax,%es:(%edi)
  800c10:	eb 06                	jmp    800c18 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c15:	fc                   	cld    
  800c16:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c18:	89 f8                	mov    %edi,%eax
  800c1a:	5b                   	pop    %ebx
  800c1b:	5e                   	pop    %esi
  800c1c:	5f                   	pop    %edi
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    

00800c1f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c1f:	f3 0f 1e fb          	endbr32 
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c31:	39 c6                	cmp    %eax,%esi
  800c33:	73 32                	jae    800c67 <memmove+0x48>
  800c35:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c38:	39 c2                	cmp    %eax,%edx
  800c3a:	76 2b                	jbe    800c67 <memmove+0x48>
		s += n;
		d += n;
  800c3c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c3f:	89 fe                	mov    %edi,%esi
  800c41:	09 ce                	or     %ecx,%esi
  800c43:	09 d6                	or     %edx,%esi
  800c45:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c4b:	75 0e                	jne    800c5b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c4d:	83 ef 04             	sub    $0x4,%edi
  800c50:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c53:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c56:	fd                   	std    
  800c57:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c59:	eb 09                	jmp    800c64 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c5b:	83 ef 01             	sub    $0x1,%edi
  800c5e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c61:	fd                   	std    
  800c62:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c64:	fc                   	cld    
  800c65:	eb 1a                	jmp    800c81 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c67:	89 c2                	mov    %eax,%edx
  800c69:	09 ca                	or     %ecx,%edx
  800c6b:	09 f2                	or     %esi,%edx
  800c6d:	f6 c2 03             	test   $0x3,%dl
  800c70:	75 0a                	jne    800c7c <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c72:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c75:	89 c7                	mov    %eax,%edi
  800c77:	fc                   	cld    
  800c78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c7a:	eb 05                	jmp    800c81 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c7c:	89 c7                	mov    %eax,%edi
  800c7e:	fc                   	cld    
  800c7f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c85:	f3 0f 1e fb          	endbr32 
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c8f:	ff 75 10             	pushl  0x10(%ebp)
  800c92:	ff 75 0c             	pushl  0xc(%ebp)
  800c95:	ff 75 08             	pushl  0x8(%ebp)
  800c98:	e8 82 ff ff ff       	call   800c1f <memmove>
}
  800c9d:	c9                   	leave  
  800c9e:	c3                   	ret    

00800c9f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c9f:	f3 0f 1e fb          	endbr32 
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cab:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cae:	89 c6                	mov    %eax,%esi
  800cb0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb3:	39 f0                	cmp    %esi,%eax
  800cb5:	74 1c                	je     800cd3 <memcmp+0x34>
		if (*s1 != *s2)
  800cb7:	0f b6 08             	movzbl (%eax),%ecx
  800cba:	0f b6 1a             	movzbl (%edx),%ebx
  800cbd:	38 d9                	cmp    %bl,%cl
  800cbf:	75 08                	jne    800cc9 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cc1:	83 c0 01             	add    $0x1,%eax
  800cc4:	83 c2 01             	add    $0x1,%edx
  800cc7:	eb ea                	jmp    800cb3 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800cc9:	0f b6 c1             	movzbl %cl,%eax
  800ccc:	0f b6 db             	movzbl %bl,%ebx
  800ccf:	29 d8                	sub    %ebx,%eax
  800cd1:	eb 05                	jmp    800cd8 <memcmp+0x39>
	}

	return 0;
  800cd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cdc:	f3 0f 1e fb          	endbr32 
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ce9:	89 c2                	mov    %eax,%edx
  800ceb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cee:	39 d0                	cmp    %edx,%eax
  800cf0:	73 09                	jae    800cfb <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf2:	38 08                	cmp    %cl,(%eax)
  800cf4:	74 05                	je     800cfb <memfind+0x1f>
	for (; s < ends; s++)
  800cf6:	83 c0 01             	add    $0x1,%eax
  800cf9:	eb f3                	jmp    800cee <memfind+0x12>
			break;
	return (void *) s;
}
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cfd:	f3 0f 1e fb          	endbr32 
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
  800d07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d0d:	eb 03                	jmp    800d12 <strtol+0x15>
		s++;
  800d0f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d12:	0f b6 01             	movzbl (%ecx),%eax
  800d15:	3c 20                	cmp    $0x20,%al
  800d17:	74 f6                	je     800d0f <strtol+0x12>
  800d19:	3c 09                	cmp    $0x9,%al
  800d1b:	74 f2                	je     800d0f <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d1d:	3c 2b                	cmp    $0x2b,%al
  800d1f:	74 2a                	je     800d4b <strtol+0x4e>
	int neg = 0;
  800d21:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d26:	3c 2d                	cmp    $0x2d,%al
  800d28:	74 2b                	je     800d55 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d2a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d30:	75 0f                	jne    800d41 <strtol+0x44>
  800d32:	80 39 30             	cmpb   $0x30,(%ecx)
  800d35:	74 28                	je     800d5f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d37:	85 db                	test   %ebx,%ebx
  800d39:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d3e:	0f 44 d8             	cmove  %eax,%ebx
  800d41:	b8 00 00 00 00       	mov    $0x0,%eax
  800d46:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d49:	eb 46                	jmp    800d91 <strtol+0x94>
		s++;
  800d4b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d4e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d53:	eb d5                	jmp    800d2a <strtol+0x2d>
		s++, neg = 1;
  800d55:	83 c1 01             	add    $0x1,%ecx
  800d58:	bf 01 00 00 00       	mov    $0x1,%edi
  800d5d:	eb cb                	jmp    800d2a <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d5f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d63:	74 0e                	je     800d73 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d65:	85 db                	test   %ebx,%ebx
  800d67:	75 d8                	jne    800d41 <strtol+0x44>
		s++, base = 8;
  800d69:	83 c1 01             	add    $0x1,%ecx
  800d6c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d71:	eb ce                	jmp    800d41 <strtol+0x44>
		s += 2, base = 16;
  800d73:	83 c1 02             	add    $0x2,%ecx
  800d76:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d7b:	eb c4                	jmp    800d41 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d7d:	0f be d2             	movsbl %dl,%edx
  800d80:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d83:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d86:	7d 3a                	jge    800dc2 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d88:	83 c1 01             	add    $0x1,%ecx
  800d8b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d8f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d91:	0f b6 11             	movzbl (%ecx),%edx
  800d94:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d97:	89 f3                	mov    %esi,%ebx
  800d99:	80 fb 09             	cmp    $0x9,%bl
  800d9c:	76 df                	jbe    800d7d <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800d9e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800da1:	89 f3                	mov    %esi,%ebx
  800da3:	80 fb 19             	cmp    $0x19,%bl
  800da6:	77 08                	ja     800db0 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800da8:	0f be d2             	movsbl %dl,%edx
  800dab:	83 ea 57             	sub    $0x57,%edx
  800dae:	eb d3                	jmp    800d83 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800db0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800db3:	89 f3                	mov    %esi,%ebx
  800db5:	80 fb 19             	cmp    $0x19,%bl
  800db8:	77 08                	ja     800dc2 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dba:	0f be d2             	movsbl %dl,%edx
  800dbd:	83 ea 37             	sub    $0x37,%edx
  800dc0:	eb c1                	jmp    800d83 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dc2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dc6:	74 05                	je     800dcd <strtol+0xd0>
		*endptr = (char *) s;
  800dc8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dcb:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800dcd:	89 c2                	mov    %eax,%edx
  800dcf:	f7 da                	neg    %edx
  800dd1:	85 ff                	test   %edi,%edi
  800dd3:	0f 45 c2             	cmovne %edx,%eax
}
  800dd6:	5b                   	pop    %ebx
  800dd7:	5e                   	pop    %esi
  800dd8:	5f                   	pop    %edi
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ddb:	f3 0f 1e fb          	endbr32 
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800de5:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800dec:	74 0a                	je     800df8 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
  800df1:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800df6:	c9                   	leave  
  800df7:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  800df8:	83 ec 0c             	sub    $0xc,%esp
  800dfb:	68 64 13 80 00       	push   $0x801364
  800e00:	e8 5b f6 ff ff       	call   800460 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  800e05:	83 c4 0c             	add    $0xc,%esp
  800e08:	6a 07                	push   $0x7
  800e0a:	68 00 f0 bf ee       	push   $0xeebff000
  800e0f:	6a 00                	push   $0x0
  800e11:	e8 72 f3 ff ff       	call   800188 <sys_page_alloc>
  800e16:	83 c4 10             	add    $0x10,%esp
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	78 2a                	js     800e47 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  800e1d:	83 ec 08             	sub    $0x8,%esp
  800e20:	68 53 03 80 00       	push   $0x800353
  800e25:	6a 00                	push   $0x0
  800e27:	e8 75 f4 ff ff       	call   8002a1 <sys_env_set_pgfault_upcall>
  800e2c:	83 c4 10             	add    $0x10,%esp
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	79 bb                	jns    800dee <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  800e33:	83 ec 04             	sub    $0x4,%esp
  800e36:	68 a0 13 80 00       	push   $0x8013a0
  800e3b:	6a 25                	push   $0x25
  800e3d:	68 91 13 80 00       	push   $0x801391
  800e42:	e8 32 f5 ff ff       	call   800379 <_panic>
            panic("Allocation of UXSTACK failed!");
  800e47:	83 ec 04             	sub    $0x4,%esp
  800e4a:	68 73 13 80 00       	push   $0x801373
  800e4f:	6a 22                	push   $0x22
  800e51:	68 91 13 80 00       	push   $0x801391
  800e56:	e8 1e f5 ff ff       	call   800379 <_panic>
  800e5b:	66 90                	xchg   %ax,%ax
  800e5d:	66 90                	xchg   %ax,%ax
  800e5f:	90                   	nop

00800e60 <__udivdi3>:
  800e60:	f3 0f 1e fb          	endbr32 
  800e64:	55                   	push   %ebp
  800e65:	57                   	push   %edi
  800e66:	56                   	push   %esi
  800e67:	53                   	push   %ebx
  800e68:	83 ec 1c             	sub    $0x1c,%esp
  800e6b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e6f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e73:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e77:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e7b:	85 d2                	test   %edx,%edx
  800e7d:	75 19                	jne    800e98 <__udivdi3+0x38>
  800e7f:	39 f3                	cmp    %esi,%ebx
  800e81:	76 4d                	jbe    800ed0 <__udivdi3+0x70>
  800e83:	31 ff                	xor    %edi,%edi
  800e85:	89 e8                	mov    %ebp,%eax
  800e87:	89 f2                	mov    %esi,%edx
  800e89:	f7 f3                	div    %ebx
  800e8b:	89 fa                	mov    %edi,%edx
  800e8d:	83 c4 1c             	add    $0x1c,%esp
  800e90:	5b                   	pop    %ebx
  800e91:	5e                   	pop    %esi
  800e92:	5f                   	pop    %edi
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    
  800e95:	8d 76 00             	lea    0x0(%esi),%esi
  800e98:	39 f2                	cmp    %esi,%edx
  800e9a:	76 14                	jbe    800eb0 <__udivdi3+0x50>
  800e9c:	31 ff                	xor    %edi,%edi
  800e9e:	31 c0                	xor    %eax,%eax
  800ea0:	89 fa                	mov    %edi,%edx
  800ea2:	83 c4 1c             	add    $0x1c,%esp
  800ea5:	5b                   	pop    %ebx
  800ea6:	5e                   	pop    %esi
  800ea7:	5f                   	pop    %edi
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    
  800eaa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800eb0:	0f bd fa             	bsr    %edx,%edi
  800eb3:	83 f7 1f             	xor    $0x1f,%edi
  800eb6:	75 48                	jne    800f00 <__udivdi3+0xa0>
  800eb8:	39 f2                	cmp    %esi,%edx
  800eba:	72 06                	jb     800ec2 <__udivdi3+0x62>
  800ebc:	31 c0                	xor    %eax,%eax
  800ebe:	39 eb                	cmp    %ebp,%ebx
  800ec0:	77 de                	ja     800ea0 <__udivdi3+0x40>
  800ec2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ec7:	eb d7                	jmp    800ea0 <__udivdi3+0x40>
  800ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	89 d9                	mov    %ebx,%ecx
  800ed2:	85 db                	test   %ebx,%ebx
  800ed4:	75 0b                	jne    800ee1 <__udivdi3+0x81>
  800ed6:	b8 01 00 00 00       	mov    $0x1,%eax
  800edb:	31 d2                	xor    %edx,%edx
  800edd:	f7 f3                	div    %ebx
  800edf:	89 c1                	mov    %eax,%ecx
  800ee1:	31 d2                	xor    %edx,%edx
  800ee3:	89 f0                	mov    %esi,%eax
  800ee5:	f7 f1                	div    %ecx
  800ee7:	89 c6                	mov    %eax,%esi
  800ee9:	89 e8                	mov    %ebp,%eax
  800eeb:	89 f7                	mov    %esi,%edi
  800eed:	f7 f1                	div    %ecx
  800eef:	89 fa                	mov    %edi,%edx
  800ef1:	83 c4 1c             	add    $0x1c,%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    
  800ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f00:	89 f9                	mov    %edi,%ecx
  800f02:	b8 20 00 00 00       	mov    $0x20,%eax
  800f07:	29 f8                	sub    %edi,%eax
  800f09:	d3 e2                	shl    %cl,%edx
  800f0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f0f:	89 c1                	mov    %eax,%ecx
  800f11:	89 da                	mov    %ebx,%edx
  800f13:	d3 ea                	shr    %cl,%edx
  800f15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f19:	09 d1                	or     %edx,%ecx
  800f1b:	89 f2                	mov    %esi,%edx
  800f1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f21:	89 f9                	mov    %edi,%ecx
  800f23:	d3 e3                	shl    %cl,%ebx
  800f25:	89 c1                	mov    %eax,%ecx
  800f27:	d3 ea                	shr    %cl,%edx
  800f29:	89 f9                	mov    %edi,%ecx
  800f2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f2f:	89 eb                	mov    %ebp,%ebx
  800f31:	d3 e6                	shl    %cl,%esi
  800f33:	89 c1                	mov    %eax,%ecx
  800f35:	d3 eb                	shr    %cl,%ebx
  800f37:	09 de                	or     %ebx,%esi
  800f39:	89 f0                	mov    %esi,%eax
  800f3b:	f7 74 24 08          	divl   0x8(%esp)
  800f3f:	89 d6                	mov    %edx,%esi
  800f41:	89 c3                	mov    %eax,%ebx
  800f43:	f7 64 24 0c          	mull   0xc(%esp)
  800f47:	39 d6                	cmp    %edx,%esi
  800f49:	72 15                	jb     800f60 <__udivdi3+0x100>
  800f4b:	89 f9                	mov    %edi,%ecx
  800f4d:	d3 e5                	shl    %cl,%ebp
  800f4f:	39 c5                	cmp    %eax,%ebp
  800f51:	73 04                	jae    800f57 <__udivdi3+0xf7>
  800f53:	39 d6                	cmp    %edx,%esi
  800f55:	74 09                	je     800f60 <__udivdi3+0x100>
  800f57:	89 d8                	mov    %ebx,%eax
  800f59:	31 ff                	xor    %edi,%edi
  800f5b:	e9 40 ff ff ff       	jmp    800ea0 <__udivdi3+0x40>
  800f60:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f63:	31 ff                	xor    %edi,%edi
  800f65:	e9 36 ff ff ff       	jmp    800ea0 <__udivdi3+0x40>
  800f6a:	66 90                	xchg   %ax,%ax
  800f6c:	66 90                	xchg   %ax,%ax
  800f6e:	66 90                	xchg   %ax,%ax

00800f70 <__umoddi3>:
  800f70:	f3 0f 1e fb          	endbr32 
  800f74:	55                   	push   %ebp
  800f75:	57                   	push   %edi
  800f76:	56                   	push   %esi
  800f77:	53                   	push   %ebx
  800f78:	83 ec 1c             	sub    $0x1c,%esp
  800f7b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f7f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f83:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f87:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	75 19                	jne    800fa8 <__umoddi3+0x38>
  800f8f:	39 df                	cmp    %ebx,%edi
  800f91:	76 5d                	jbe    800ff0 <__umoddi3+0x80>
  800f93:	89 f0                	mov    %esi,%eax
  800f95:	89 da                	mov    %ebx,%edx
  800f97:	f7 f7                	div    %edi
  800f99:	89 d0                	mov    %edx,%eax
  800f9b:	31 d2                	xor    %edx,%edx
  800f9d:	83 c4 1c             	add    $0x1c,%esp
  800fa0:	5b                   	pop    %ebx
  800fa1:	5e                   	pop    %esi
  800fa2:	5f                   	pop    %edi
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    
  800fa5:	8d 76 00             	lea    0x0(%esi),%esi
  800fa8:	89 f2                	mov    %esi,%edx
  800faa:	39 d8                	cmp    %ebx,%eax
  800fac:	76 12                	jbe    800fc0 <__umoddi3+0x50>
  800fae:	89 f0                	mov    %esi,%eax
  800fb0:	89 da                	mov    %ebx,%edx
  800fb2:	83 c4 1c             	add    $0x1c,%esp
  800fb5:	5b                   	pop    %ebx
  800fb6:	5e                   	pop    %esi
  800fb7:	5f                   	pop    %edi
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    
  800fba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fc0:	0f bd e8             	bsr    %eax,%ebp
  800fc3:	83 f5 1f             	xor    $0x1f,%ebp
  800fc6:	75 50                	jne    801018 <__umoddi3+0xa8>
  800fc8:	39 d8                	cmp    %ebx,%eax
  800fca:	0f 82 e0 00 00 00    	jb     8010b0 <__umoddi3+0x140>
  800fd0:	89 d9                	mov    %ebx,%ecx
  800fd2:	39 f7                	cmp    %esi,%edi
  800fd4:	0f 86 d6 00 00 00    	jbe    8010b0 <__umoddi3+0x140>
  800fda:	89 d0                	mov    %edx,%eax
  800fdc:	89 ca                	mov    %ecx,%edx
  800fde:	83 c4 1c             	add    $0x1c,%esp
  800fe1:	5b                   	pop    %ebx
  800fe2:	5e                   	pop    %esi
  800fe3:	5f                   	pop    %edi
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    
  800fe6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fed:	8d 76 00             	lea    0x0(%esi),%esi
  800ff0:	89 fd                	mov    %edi,%ebp
  800ff2:	85 ff                	test   %edi,%edi
  800ff4:	75 0b                	jne    801001 <__umoddi3+0x91>
  800ff6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ffb:	31 d2                	xor    %edx,%edx
  800ffd:	f7 f7                	div    %edi
  800fff:	89 c5                	mov    %eax,%ebp
  801001:	89 d8                	mov    %ebx,%eax
  801003:	31 d2                	xor    %edx,%edx
  801005:	f7 f5                	div    %ebp
  801007:	89 f0                	mov    %esi,%eax
  801009:	f7 f5                	div    %ebp
  80100b:	89 d0                	mov    %edx,%eax
  80100d:	31 d2                	xor    %edx,%edx
  80100f:	eb 8c                	jmp    800f9d <__umoddi3+0x2d>
  801011:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801018:	89 e9                	mov    %ebp,%ecx
  80101a:	ba 20 00 00 00       	mov    $0x20,%edx
  80101f:	29 ea                	sub    %ebp,%edx
  801021:	d3 e0                	shl    %cl,%eax
  801023:	89 44 24 08          	mov    %eax,0x8(%esp)
  801027:	89 d1                	mov    %edx,%ecx
  801029:	89 f8                	mov    %edi,%eax
  80102b:	d3 e8                	shr    %cl,%eax
  80102d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801031:	89 54 24 04          	mov    %edx,0x4(%esp)
  801035:	8b 54 24 04          	mov    0x4(%esp),%edx
  801039:	09 c1                	or     %eax,%ecx
  80103b:	89 d8                	mov    %ebx,%eax
  80103d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801041:	89 e9                	mov    %ebp,%ecx
  801043:	d3 e7                	shl    %cl,%edi
  801045:	89 d1                	mov    %edx,%ecx
  801047:	d3 e8                	shr    %cl,%eax
  801049:	89 e9                	mov    %ebp,%ecx
  80104b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80104f:	d3 e3                	shl    %cl,%ebx
  801051:	89 c7                	mov    %eax,%edi
  801053:	89 d1                	mov    %edx,%ecx
  801055:	89 f0                	mov    %esi,%eax
  801057:	d3 e8                	shr    %cl,%eax
  801059:	89 e9                	mov    %ebp,%ecx
  80105b:	89 fa                	mov    %edi,%edx
  80105d:	d3 e6                	shl    %cl,%esi
  80105f:	09 d8                	or     %ebx,%eax
  801061:	f7 74 24 08          	divl   0x8(%esp)
  801065:	89 d1                	mov    %edx,%ecx
  801067:	89 f3                	mov    %esi,%ebx
  801069:	f7 64 24 0c          	mull   0xc(%esp)
  80106d:	89 c6                	mov    %eax,%esi
  80106f:	89 d7                	mov    %edx,%edi
  801071:	39 d1                	cmp    %edx,%ecx
  801073:	72 06                	jb     80107b <__umoddi3+0x10b>
  801075:	75 10                	jne    801087 <__umoddi3+0x117>
  801077:	39 c3                	cmp    %eax,%ebx
  801079:	73 0c                	jae    801087 <__umoddi3+0x117>
  80107b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80107f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801083:	89 d7                	mov    %edx,%edi
  801085:	89 c6                	mov    %eax,%esi
  801087:	89 ca                	mov    %ecx,%edx
  801089:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80108e:	29 f3                	sub    %esi,%ebx
  801090:	19 fa                	sbb    %edi,%edx
  801092:	89 d0                	mov    %edx,%eax
  801094:	d3 e0                	shl    %cl,%eax
  801096:	89 e9                	mov    %ebp,%ecx
  801098:	d3 eb                	shr    %cl,%ebx
  80109a:	d3 ea                	shr    %cl,%edx
  80109c:	09 d8                	or     %ebx,%eax
  80109e:	83 c4 1c             	add    $0x1c,%esp
  8010a1:	5b                   	pop    %ebx
  8010a2:	5e                   	pop    %esi
  8010a3:	5f                   	pop    %edi
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    
  8010a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010ad:	8d 76 00             	lea    0x0(%esi),%esi
  8010b0:	29 fe                	sub    %edi,%esi
  8010b2:	19 c3                	sbb    %eax,%ebx
  8010b4:	89 f2                	mov    %esi,%edx
  8010b6:	89 d9                	mov    %ebx,%ecx
  8010b8:	e9 1d ff ff ff       	jmp    800fda <__umoddi3+0x6a>
