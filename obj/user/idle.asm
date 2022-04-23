
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
  80003d:	c7 05 00 20 80 00 40 	movl   $0x801040,0x802000
  800044:	10 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800047:	e8 19 01 00 00       	call   800165 <sys_yield>
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
  80005d:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800064:	00 00 00 
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
  800080:	7e 07                	jle    800089 <libmain+0x3b>
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
	//close_all();
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
  800131:	68 4f 10 80 00       	push   $0x80104f
  800136:	6a 23                	push   $0x23
  800138:	68 6c 10 80 00       	push   $0x80106c
  80013d:	e8 36 02 00 00       	call   800378 <_panic>

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
  800174:	b8 0b 00 00 00       	mov    $0xb,%eax
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
  8001be:	68 4f 10 80 00       	push   $0x80104f
  8001c3:	6a 23                	push   $0x23
  8001c5:	68 6c 10 80 00       	push   $0x80106c
  8001ca:	e8 a9 01 00 00       	call   800378 <_panic>

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
  800204:	68 4f 10 80 00       	push   $0x80104f
  800209:	6a 23                	push   $0x23
  80020b:	68 6c 10 80 00       	push   $0x80106c
  800210:	e8 63 01 00 00       	call   800378 <_panic>

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
  80024a:	68 4f 10 80 00       	push   $0x80104f
  80024f:	6a 23                	push   $0x23
  800251:	68 6c 10 80 00       	push   $0x80106c
  800256:	e8 1d 01 00 00       	call   800378 <_panic>

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
  800290:	68 4f 10 80 00       	push   $0x80104f
  800295:	6a 23                	push   $0x23
  800297:	68 6c 10 80 00       	push   $0x80106c
  80029c:	e8 d7 00 00 00       	call   800378 <_panic>

008002a1 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  8002c6:	7f 08                	jg     8002d0 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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
  8002d6:	68 4f 10 80 00       	push   $0x80104f
  8002db:	6a 23                	push   $0x23
  8002dd:	68 6c 10 80 00       	push   $0x80106c
  8002e2:	e8 91 00 00 00       	call   800378 <_panic>

008002e7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002e7:	f3 0f 1e fb          	endbr32 
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
  8002f1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800304:	89 df                	mov    %ebx,%edi
  800306:	89 de                	mov    %ebx,%esi
  800308:	cd 30                	int    $0x30
	if(check && ret > 0)
  80030a:	85 c0                	test   %eax,%eax
  80030c:	7f 08                	jg     800316 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80030e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800316:	83 ec 0c             	sub    $0xc,%esp
  800319:	50                   	push   %eax
  80031a:	6a 0a                	push   $0xa
  80031c:	68 4f 10 80 00       	push   $0x80104f
  800321:	6a 23                	push   $0x23
  800323:	68 6c 10 80 00       	push   $0x80106c
  800328:	e8 4b 00 00 00       	call   800378 <_panic>

0080032d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80032d:	f3 0f 1e fb          	endbr32 
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
	asm volatile("int %1\n"
  800337:	8b 55 08             	mov    0x8(%ebp),%edx
  80033a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800342:	be 00 00 00 00       	mov    $0x0,%esi
  800347:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80034a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80034d:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800354:	f3 0f 1e fb          	endbr32 
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	57                   	push   %edi
  80035c:	56                   	push   %esi
  80035d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80035e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800363:	8b 55 08             	mov    0x8(%ebp),%edx
  800366:	b8 0d 00 00 00       	mov    $0xd,%eax
  80036b:	89 cb                	mov    %ecx,%ebx
  80036d:	89 cf                	mov    %ecx,%edi
  80036f:	89 ce                	mov    %ecx,%esi
  800371:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 0, (uint32_t)dstva, 0, 0, 0, 0);
}
  800373:	5b                   	pop    %ebx
  800374:	5e                   	pop    %esi
  800375:	5f                   	pop    %edi
  800376:	5d                   	pop    %ebp
  800377:	c3                   	ret    

00800378 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800378:	f3 0f 1e fb          	endbr32 
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	56                   	push   %esi
  800380:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800381:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800384:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80038a:	e8 b3 fd ff ff       	call   800142 <sys_getenvid>
  80038f:	83 ec 0c             	sub    $0xc,%esp
  800392:	ff 75 0c             	pushl  0xc(%ebp)
  800395:	ff 75 08             	pushl  0x8(%ebp)
  800398:	56                   	push   %esi
  800399:	50                   	push   %eax
  80039a:	68 7c 10 80 00       	push   $0x80107c
  80039f:	e8 bb 00 00 00       	call   80045f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003a4:	83 c4 18             	add    $0x18,%esp
  8003a7:	53                   	push   %ebx
  8003a8:	ff 75 10             	pushl  0x10(%ebp)
  8003ab:	e8 5a 00 00 00       	call   80040a <vcprintf>
	cprintf("\n");
  8003b0:	c7 04 24 9f 10 80 00 	movl   $0x80109f,(%esp)
  8003b7:	e8 a3 00 00 00       	call   80045f <cprintf>
  8003bc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003bf:	cc                   	int3   
  8003c0:	eb fd                	jmp    8003bf <_panic+0x47>

008003c2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003c2:	f3 0f 1e fb          	endbr32 
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	53                   	push   %ebx
  8003ca:	83 ec 04             	sub    $0x4,%esp
  8003cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003d0:	8b 13                	mov    (%ebx),%edx
  8003d2:	8d 42 01             	lea    0x1(%edx),%eax
  8003d5:	89 03                	mov    %eax,(%ebx)
  8003d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003da:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003e3:	74 09                	je     8003ee <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003e5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003ec:	c9                   	leave  
  8003ed:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003ee:	83 ec 08             	sub    $0x8,%esp
  8003f1:	68 ff 00 00 00       	push   $0xff
  8003f6:	8d 43 08             	lea    0x8(%ebx),%eax
  8003f9:	50                   	push   %eax
  8003fa:	e8 b9 fc ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  8003ff:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800405:	83 c4 10             	add    $0x10,%esp
  800408:	eb db                	jmp    8003e5 <putch+0x23>

0080040a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80040a:	f3 0f 1e fb          	endbr32 
  80040e:	55                   	push   %ebp
  80040f:	89 e5                	mov    %esp,%ebp
  800411:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800417:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80041e:	00 00 00 
	b.cnt = 0;
  800421:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800428:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80042b:	ff 75 0c             	pushl  0xc(%ebp)
  80042e:	ff 75 08             	pushl  0x8(%ebp)
  800431:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800437:	50                   	push   %eax
  800438:	68 c2 03 80 00       	push   $0x8003c2
  80043d:	e8 20 01 00 00       	call   800562 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800442:	83 c4 08             	add    $0x8,%esp
  800445:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80044b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800451:	50                   	push   %eax
  800452:	e8 61 fc ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
}
  800457:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80045d:	c9                   	leave  
  80045e:	c3                   	ret    

0080045f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80045f:	f3 0f 1e fb          	endbr32 
  800463:	55                   	push   %ebp
  800464:	89 e5                	mov    %esp,%ebp
  800466:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800469:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80046c:	50                   	push   %eax
  80046d:	ff 75 08             	pushl  0x8(%ebp)
  800470:	e8 95 ff ff ff       	call   80040a <vcprintf>
	va_end(ap);

	return cnt;
}
  800475:	c9                   	leave  
  800476:	c3                   	ret    

00800477 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800477:	55                   	push   %ebp
  800478:	89 e5                	mov    %esp,%ebp
  80047a:	57                   	push   %edi
  80047b:	56                   	push   %esi
  80047c:	53                   	push   %ebx
  80047d:	83 ec 1c             	sub    $0x1c,%esp
  800480:	89 c7                	mov    %eax,%edi
  800482:	89 d6                	mov    %edx,%esi
  800484:	8b 45 08             	mov    0x8(%ebp),%eax
  800487:	8b 55 0c             	mov    0xc(%ebp),%edx
  80048a:	89 d1                	mov    %edx,%ecx
  80048c:	89 c2                	mov    %eax,%edx
  80048e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800491:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800494:	8b 45 10             	mov    0x10(%ebp),%eax
  800497:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80049a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004a4:	39 c2                	cmp    %eax,%edx
  8004a6:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8004a9:	72 3e                	jb     8004e9 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004ab:	83 ec 0c             	sub    $0xc,%esp
  8004ae:	ff 75 18             	pushl  0x18(%ebp)
  8004b1:	83 eb 01             	sub    $0x1,%ebx
  8004b4:	53                   	push   %ebx
  8004b5:	50                   	push   %eax
  8004b6:	83 ec 08             	sub    $0x8,%esp
  8004b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8004bf:	ff 75 dc             	pushl  -0x24(%ebp)
  8004c2:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c5:	e8 16 09 00 00       	call   800de0 <__udivdi3>
  8004ca:	83 c4 18             	add    $0x18,%esp
  8004cd:	52                   	push   %edx
  8004ce:	50                   	push   %eax
  8004cf:	89 f2                	mov    %esi,%edx
  8004d1:	89 f8                	mov    %edi,%eax
  8004d3:	e8 9f ff ff ff       	call   800477 <printnum>
  8004d8:	83 c4 20             	add    $0x20,%esp
  8004db:	eb 13                	jmp    8004f0 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	56                   	push   %esi
  8004e1:	ff 75 18             	pushl  0x18(%ebp)
  8004e4:	ff d7                	call   *%edi
  8004e6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004e9:	83 eb 01             	sub    $0x1,%ebx
  8004ec:	85 db                	test   %ebx,%ebx
  8004ee:	7f ed                	jg     8004dd <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	56                   	push   %esi
  8004f4:	83 ec 04             	sub    $0x4,%esp
  8004f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8004fd:	ff 75 dc             	pushl  -0x24(%ebp)
  800500:	ff 75 d8             	pushl  -0x28(%ebp)
  800503:	e8 e8 09 00 00       	call   800ef0 <__umoddi3>
  800508:	83 c4 14             	add    $0x14,%esp
  80050b:	0f be 80 a1 10 80 00 	movsbl 0x8010a1(%eax),%eax
  800512:	50                   	push   %eax
  800513:	ff d7                	call   *%edi
}
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80051b:	5b                   	pop    %ebx
  80051c:	5e                   	pop    %esi
  80051d:	5f                   	pop    %edi
  80051e:	5d                   	pop    %ebp
  80051f:	c3                   	ret    

00800520 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800520:	f3 0f 1e fb          	endbr32 
  800524:	55                   	push   %ebp
  800525:	89 e5                	mov    %esp,%ebp
  800527:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80052a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80052e:	8b 10                	mov    (%eax),%edx
  800530:	3b 50 04             	cmp    0x4(%eax),%edx
  800533:	73 0a                	jae    80053f <sprintputch+0x1f>
		*b->buf++ = ch;
  800535:	8d 4a 01             	lea    0x1(%edx),%ecx
  800538:	89 08                	mov    %ecx,(%eax)
  80053a:	8b 45 08             	mov    0x8(%ebp),%eax
  80053d:	88 02                	mov    %al,(%edx)
}
  80053f:	5d                   	pop    %ebp
  800540:	c3                   	ret    

00800541 <printfmt>:
{
  800541:	f3 0f 1e fb          	endbr32 
  800545:	55                   	push   %ebp
  800546:	89 e5                	mov    %esp,%ebp
  800548:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80054b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80054e:	50                   	push   %eax
  80054f:	ff 75 10             	pushl  0x10(%ebp)
  800552:	ff 75 0c             	pushl  0xc(%ebp)
  800555:	ff 75 08             	pushl  0x8(%ebp)
  800558:	e8 05 00 00 00       	call   800562 <vprintfmt>
}
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	c9                   	leave  
  800561:	c3                   	ret    

00800562 <vprintfmt>:
{
  800562:	f3 0f 1e fb          	endbr32 
  800566:	55                   	push   %ebp
  800567:	89 e5                	mov    %esp,%ebp
  800569:	57                   	push   %edi
  80056a:	56                   	push   %esi
  80056b:	53                   	push   %ebx
  80056c:	83 ec 3c             	sub    $0x3c,%esp
  80056f:	8b 75 08             	mov    0x8(%ebp),%esi
  800572:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800575:	8b 7d 10             	mov    0x10(%ebp),%edi
  800578:	e9 4a 03 00 00       	jmp    8008c7 <vprintfmt+0x365>
		padc = ' ';
  80057d:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800581:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800588:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80058f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800596:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80059b:	8d 47 01             	lea    0x1(%edi),%eax
  80059e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a1:	0f b6 17             	movzbl (%edi),%edx
  8005a4:	8d 42 dd             	lea    -0x23(%edx),%eax
  8005a7:	3c 55                	cmp    $0x55,%al
  8005a9:	0f 87 de 03 00 00    	ja     80098d <vprintfmt+0x42b>
  8005af:	0f b6 c0             	movzbl %al,%eax
  8005b2:	3e ff 24 85 e0 11 80 	notrack jmp *0x8011e0(,%eax,4)
  8005b9:	00 
  8005ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005bd:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005c1:	eb d8                	jmp    80059b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c6:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005ca:	eb cf                	jmp    80059b <vprintfmt+0x39>
  8005cc:	0f b6 d2             	movzbl %dl,%edx
  8005cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005da:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005dd:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005e1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005e4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005e7:	83 f9 09             	cmp    $0x9,%ecx
  8005ea:	77 55                	ja     800641 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005ec:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005ef:	eb e9                	jmp    8005da <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8b 00                	mov    (%eax),%eax
  8005f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8d 40 04             	lea    0x4(%eax),%eax
  8005ff:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800602:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800605:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800609:	79 90                	jns    80059b <vprintfmt+0x39>
				width = precision, precision = -1;
  80060b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80060e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800611:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800618:	eb 81                	jmp    80059b <vprintfmt+0x39>
  80061a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80061d:	85 c0                	test   %eax,%eax
  80061f:	ba 00 00 00 00       	mov    $0x0,%edx
  800624:	0f 49 d0             	cmovns %eax,%edx
  800627:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80062a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80062d:	e9 69 ff ff ff       	jmp    80059b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800632:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800635:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80063c:	e9 5a ff ff ff       	jmp    80059b <vprintfmt+0x39>
  800641:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800644:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800647:	eb bc                	jmp    800605 <vprintfmt+0xa3>
			lflag++;
  800649:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80064c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80064f:	e9 47 ff ff ff       	jmp    80059b <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8d 78 04             	lea    0x4(%eax),%edi
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	53                   	push   %ebx
  80065e:	ff 30                	pushl  (%eax)
  800660:	ff d6                	call   *%esi
			break;
  800662:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800665:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800668:	e9 57 02 00 00       	jmp    8008c4 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8d 78 04             	lea    0x4(%eax),%edi
  800673:	8b 00                	mov    (%eax),%eax
  800675:	99                   	cltd   
  800676:	31 d0                	xor    %edx,%eax
  800678:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80067a:	83 f8 0f             	cmp    $0xf,%eax
  80067d:	7f 23                	jg     8006a2 <vprintfmt+0x140>
  80067f:	8b 14 85 40 13 80 00 	mov    0x801340(,%eax,4),%edx
  800686:	85 d2                	test   %edx,%edx
  800688:	74 18                	je     8006a2 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80068a:	52                   	push   %edx
  80068b:	68 c2 10 80 00       	push   $0x8010c2
  800690:	53                   	push   %ebx
  800691:	56                   	push   %esi
  800692:	e8 aa fe ff ff       	call   800541 <printfmt>
  800697:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80069a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80069d:	e9 22 02 00 00       	jmp    8008c4 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8006a2:	50                   	push   %eax
  8006a3:	68 b9 10 80 00       	push   $0x8010b9
  8006a8:	53                   	push   %ebx
  8006a9:	56                   	push   %esi
  8006aa:	e8 92 fe ff ff       	call   800541 <printfmt>
  8006af:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006b2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8006b5:	e9 0a 02 00 00       	jmp    8008c4 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	83 c0 04             	add    $0x4,%eax
  8006c0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8006c8:	85 d2                	test   %edx,%edx
  8006ca:	b8 b2 10 80 00       	mov    $0x8010b2,%eax
  8006cf:	0f 45 c2             	cmovne %edx,%eax
  8006d2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006d9:	7e 06                	jle    8006e1 <vprintfmt+0x17f>
  8006db:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006df:	75 0d                	jne    8006ee <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006e4:	89 c7                	mov    %eax,%edi
  8006e6:	03 45 e0             	add    -0x20(%ebp),%eax
  8006e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ec:	eb 55                	jmp    800743 <vprintfmt+0x1e1>
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8006f4:	ff 75 cc             	pushl  -0x34(%ebp)
  8006f7:	e8 45 03 00 00       	call   800a41 <strnlen>
  8006fc:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006ff:	29 c2                	sub    %eax,%edx
  800701:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800709:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80070d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800710:	85 ff                	test   %edi,%edi
  800712:	7e 11                	jle    800725 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	53                   	push   %ebx
  800718:	ff 75 e0             	pushl  -0x20(%ebp)
  80071b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80071d:	83 ef 01             	sub    $0x1,%edi
  800720:	83 c4 10             	add    $0x10,%esp
  800723:	eb eb                	jmp    800710 <vprintfmt+0x1ae>
  800725:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800728:	85 d2                	test   %edx,%edx
  80072a:	b8 00 00 00 00       	mov    $0x0,%eax
  80072f:	0f 49 c2             	cmovns %edx,%eax
  800732:	29 c2                	sub    %eax,%edx
  800734:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800737:	eb a8                	jmp    8006e1 <vprintfmt+0x17f>
					putch(ch, putdat);
  800739:	83 ec 08             	sub    $0x8,%esp
  80073c:	53                   	push   %ebx
  80073d:	52                   	push   %edx
  80073e:	ff d6                	call   *%esi
  800740:	83 c4 10             	add    $0x10,%esp
  800743:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800746:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800748:	83 c7 01             	add    $0x1,%edi
  80074b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80074f:	0f be d0             	movsbl %al,%edx
  800752:	85 d2                	test   %edx,%edx
  800754:	74 4b                	je     8007a1 <vprintfmt+0x23f>
  800756:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80075a:	78 06                	js     800762 <vprintfmt+0x200>
  80075c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800760:	78 1e                	js     800780 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800762:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800766:	74 d1                	je     800739 <vprintfmt+0x1d7>
  800768:	0f be c0             	movsbl %al,%eax
  80076b:	83 e8 20             	sub    $0x20,%eax
  80076e:	83 f8 5e             	cmp    $0x5e,%eax
  800771:	76 c6                	jbe    800739 <vprintfmt+0x1d7>
					putch('?', putdat);
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	53                   	push   %ebx
  800777:	6a 3f                	push   $0x3f
  800779:	ff d6                	call   *%esi
  80077b:	83 c4 10             	add    $0x10,%esp
  80077e:	eb c3                	jmp    800743 <vprintfmt+0x1e1>
  800780:	89 cf                	mov    %ecx,%edi
  800782:	eb 0e                	jmp    800792 <vprintfmt+0x230>
				putch(' ', putdat);
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	53                   	push   %ebx
  800788:	6a 20                	push   $0x20
  80078a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80078c:	83 ef 01             	sub    $0x1,%edi
  80078f:	83 c4 10             	add    $0x10,%esp
  800792:	85 ff                	test   %edi,%edi
  800794:	7f ee                	jg     800784 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800796:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800799:	89 45 14             	mov    %eax,0x14(%ebp)
  80079c:	e9 23 01 00 00       	jmp    8008c4 <vprintfmt+0x362>
  8007a1:	89 cf                	mov    %ecx,%edi
  8007a3:	eb ed                	jmp    800792 <vprintfmt+0x230>
	if (lflag >= 2)
  8007a5:	83 f9 01             	cmp    $0x1,%ecx
  8007a8:	7f 1b                	jg     8007c5 <vprintfmt+0x263>
	else if (lflag)
  8007aa:	85 c9                	test   %ecx,%ecx
  8007ac:	74 63                	je     800811 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8007ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b1:	8b 00                	mov    (%eax),%eax
  8007b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b6:	99                   	cltd   
  8007b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bd:	8d 40 04             	lea    0x4(%eax),%eax
  8007c0:	89 45 14             	mov    %eax,0x14(%ebp)
  8007c3:	eb 17                	jmp    8007dc <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	8b 50 04             	mov    0x4(%eax),%edx
  8007cb:	8b 00                	mov    (%eax),%eax
  8007cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	8d 40 08             	lea    0x8(%eax),%eax
  8007d9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007dc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007df:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007e2:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007e7:	85 c9                	test   %ecx,%ecx
  8007e9:	0f 89 bb 00 00 00    	jns    8008aa <vprintfmt+0x348>
				putch('-', putdat);
  8007ef:	83 ec 08             	sub    $0x8,%esp
  8007f2:	53                   	push   %ebx
  8007f3:	6a 2d                	push   $0x2d
  8007f5:	ff d6                	call   *%esi
				num = -(long long) num;
  8007f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007fd:	f7 da                	neg    %edx
  8007ff:	83 d1 00             	adc    $0x0,%ecx
  800802:	f7 d9                	neg    %ecx
  800804:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800807:	b8 0a 00 00 00       	mov    $0xa,%eax
  80080c:	e9 99 00 00 00       	jmp    8008aa <vprintfmt+0x348>
		return va_arg(*ap, int);
  800811:	8b 45 14             	mov    0x14(%ebp),%eax
  800814:	8b 00                	mov    (%eax),%eax
  800816:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800819:	99                   	cltd   
  80081a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80081d:	8b 45 14             	mov    0x14(%ebp),%eax
  800820:	8d 40 04             	lea    0x4(%eax),%eax
  800823:	89 45 14             	mov    %eax,0x14(%ebp)
  800826:	eb b4                	jmp    8007dc <vprintfmt+0x27a>
	if (lflag >= 2)
  800828:	83 f9 01             	cmp    $0x1,%ecx
  80082b:	7f 1b                	jg     800848 <vprintfmt+0x2e6>
	else if (lflag)
  80082d:	85 c9                	test   %ecx,%ecx
  80082f:	74 2c                	je     80085d <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800831:	8b 45 14             	mov    0x14(%ebp),%eax
  800834:	8b 10                	mov    (%eax),%edx
  800836:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083b:	8d 40 04             	lea    0x4(%eax),%eax
  80083e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800841:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800846:	eb 62                	jmp    8008aa <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800848:	8b 45 14             	mov    0x14(%ebp),%eax
  80084b:	8b 10                	mov    (%eax),%edx
  80084d:	8b 48 04             	mov    0x4(%eax),%ecx
  800850:	8d 40 08             	lea    0x8(%eax),%eax
  800853:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800856:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80085b:	eb 4d                	jmp    8008aa <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80085d:	8b 45 14             	mov    0x14(%ebp),%eax
  800860:	8b 10                	mov    (%eax),%edx
  800862:	b9 00 00 00 00       	mov    $0x0,%ecx
  800867:	8d 40 04             	lea    0x4(%eax),%eax
  80086a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80086d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800872:	eb 36                	jmp    8008aa <vprintfmt+0x348>
	if (lflag >= 2)
  800874:	83 f9 01             	cmp    $0x1,%ecx
  800877:	7f 17                	jg     800890 <vprintfmt+0x32e>
	else if (lflag)
  800879:	85 c9                	test   %ecx,%ecx
  80087b:	74 6e                	je     8008eb <vprintfmt+0x389>
		return va_arg(*ap, long);
  80087d:	8b 45 14             	mov    0x14(%ebp),%eax
  800880:	8b 10                	mov    (%eax),%edx
  800882:	89 d0                	mov    %edx,%eax
  800884:	99                   	cltd   
  800885:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800888:	8d 49 04             	lea    0x4(%ecx),%ecx
  80088b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80088e:	eb 11                	jmp    8008a1 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800890:	8b 45 14             	mov    0x14(%ebp),%eax
  800893:	8b 50 04             	mov    0x4(%eax),%edx
  800896:	8b 00                	mov    (%eax),%eax
  800898:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80089b:	8d 49 08             	lea    0x8(%ecx),%ecx
  80089e:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8008a1:	89 d1                	mov    %edx,%ecx
  8008a3:	89 c2                	mov    %eax,%edx
            base = 8;
  8008a5:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008aa:	83 ec 0c             	sub    $0xc,%esp
  8008ad:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008b1:	57                   	push   %edi
  8008b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8008b5:	50                   	push   %eax
  8008b6:	51                   	push   %ecx
  8008b7:	52                   	push   %edx
  8008b8:	89 da                	mov    %ebx,%edx
  8008ba:	89 f0                	mov    %esi,%eax
  8008bc:	e8 b6 fb ff ff       	call   800477 <printnum>
			break;
  8008c1:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008c7:	83 c7 01             	add    $0x1,%edi
  8008ca:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008ce:	83 f8 25             	cmp    $0x25,%eax
  8008d1:	0f 84 a6 fc ff ff    	je     80057d <vprintfmt+0x1b>
			if (ch == '\0')
  8008d7:	85 c0                	test   %eax,%eax
  8008d9:	0f 84 ce 00 00 00    	je     8009ad <vprintfmt+0x44b>
			putch(ch, putdat);
  8008df:	83 ec 08             	sub    $0x8,%esp
  8008e2:	53                   	push   %ebx
  8008e3:	50                   	push   %eax
  8008e4:	ff d6                	call   *%esi
  8008e6:	83 c4 10             	add    $0x10,%esp
  8008e9:	eb dc                	jmp    8008c7 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8008eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ee:	8b 10                	mov    (%eax),%edx
  8008f0:	89 d0                	mov    %edx,%eax
  8008f2:	99                   	cltd   
  8008f3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008f6:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008f9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008fc:	eb a3                	jmp    8008a1 <vprintfmt+0x33f>
			putch('0', putdat);
  8008fe:	83 ec 08             	sub    $0x8,%esp
  800901:	53                   	push   %ebx
  800902:	6a 30                	push   $0x30
  800904:	ff d6                	call   *%esi
			putch('x', putdat);
  800906:	83 c4 08             	add    $0x8,%esp
  800909:	53                   	push   %ebx
  80090a:	6a 78                	push   $0x78
  80090c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80090e:	8b 45 14             	mov    0x14(%ebp),%eax
  800911:	8b 10                	mov    (%eax),%edx
  800913:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800918:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80091b:	8d 40 04             	lea    0x4(%eax),%eax
  80091e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800921:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800926:	eb 82                	jmp    8008aa <vprintfmt+0x348>
	if (lflag >= 2)
  800928:	83 f9 01             	cmp    $0x1,%ecx
  80092b:	7f 1e                	jg     80094b <vprintfmt+0x3e9>
	else if (lflag)
  80092d:	85 c9                	test   %ecx,%ecx
  80092f:	74 32                	je     800963 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800931:	8b 45 14             	mov    0x14(%ebp),%eax
  800934:	8b 10                	mov    (%eax),%edx
  800936:	b9 00 00 00 00       	mov    $0x0,%ecx
  80093b:	8d 40 04             	lea    0x4(%eax),%eax
  80093e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800941:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800946:	e9 5f ff ff ff       	jmp    8008aa <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80094b:	8b 45 14             	mov    0x14(%ebp),%eax
  80094e:	8b 10                	mov    (%eax),%edx
  800950:	8b 48 04             	mov    0x4(%eax),%ecx
  800953:	8d 40 08             	lea    0x8(%eax),%eax
  800956:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800959:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80095e:	e9 47 ff ff ff       	jmp    8008aa <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800963:	8b 45 14             	mov    0x14(%ebp),%eax
  800966:	8b 10                	mov    (%eax),%edx
  800968:	b9 00 00 00 00       	mov    $0x0,%ecx
  80096d:	8d 40 04             	lea    0x4(%eax),%eax
  800970:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800973:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800978:	e9 2d ff ff ff       	jmp    8008aa <vprintfmt+0x348>
			putch(ch, putdat);
  80097d:	83 ec 08             	sub    $0x8,%esp
  800980:	53                   	push   %ebx
  800981:	6a 25                	push   $0x25
  800983:	ff d6                	call   *%esi
			break;
  800985:	83 c4 10             	add    $0x10,%esp
  800988:	e9 37 ff ff ff       	jmp    8008c4 <vprintfmt+0x362>
			putch('%', putdat);
  80098d:	83 ec 08             	sub    $0x8,%esp
  800990:	53                   	push   %ebx
  800991:	6a 25                	push   $0x25
  800993:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800995:	83 c4 10             	add    $0x10,%esp
  800998:	89 f8                	mov    %edi,%eax
  80099a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80099e:	74 05                	je     8009a5 <vprintfmt+0x443>
  8009a0:	83 e8 01             	sub    $0x1,%eax
  8009a3:	eb f5                	jmp    80099a <vprintfmt+0x438>
  8009a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009a8:	e9 17 ff ff ff       	jmp    8008c4 <vprintfmt+0x362>
}
  8009ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009b0:	5b                   	pop    %ebx
  8009b1:	5e                   	pop    %esi
  8009b2:	5f                   	pop    %edi
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009b5:	f3 0f 1e fb          	endbr32 
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	83 ec 18             	sub    $0x18,%esp
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009c8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009cc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009d6:	85 c0                	test   %eax,%eax
  8009d8:	74 26                	je     800a00 <vsnprintf+0x4b>
  8009da:	85 d2                	test   %edx,%edx
  8009dc:	7e 22                	jle    800a00 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009de:	ff 75 14             	pushl  0x14(%ebp)
  8009e1:	ff 75 10             	pushl  0x10(%ebp)
  8009e4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009e7:	50                   	push   %eax
  8009e8:	68 20 05 80 00       	push   $0x800520
  8009ed:	e8 70 fb ff ff       	call   800562 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009f5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009fb:	83 c4 10             	add    $0x10,%esp
}
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    
		return -E_INVAL;
  800a00:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a05:	eb f7                	jmp    8009fe <vsnprintf+0x49>

00800a07 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a07:	f3 0f 1e fb          	endbr32 
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a11:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a14:	50                   	push   %eax
  800a15:	ff 75 10             	pushl  0x10(%ebp)
  800a18:	ff 75 0c             	pushl  0xc(%ebp)
  800a1b:	ff 75 08             	pushl  0x8(%ebp)
  800a1e:	e8 92 ff ff ff       	call   8009b5 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a23:	c9                   	leave  
  800a24:	c3                   	ret    

00800a25 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a25:	f3 0f 1e fb          	endbr32 
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a34:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a38:	74 05                	je     800a3f <strlen+0x1a>
		n++;
  800a3a:	83 c0 01             	add    $0x1,%eax
  800a3d:	eb f5                	jmp    800a34 <strlen+0xf>
	return n;
}
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a41:	f3 0f 1e fb          	endbr32 
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a53:	39 d0                	cmp    %edx,%eax
  800a55:	74 0d                	je     800a64 <strnlen+0x23>
  800a57:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a5b:	74 05                	je     800a62 <strnlen+0x21>
		n++;
  800a5d:	83 c0 01             	add    $0x1,%eax
  800a60:	eb f1                	jmp    800a53 <strnlen+0x12>
  800a62:	89 c2                	mov    %eax,%edx
	return n;
}
  800a64:	89 d0                	mov    %edx,%eax
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a68:	f3 0f 1e fb          	endbr32 
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	53                   	push   %ebx
  800a70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a76:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7b:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a7f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a82:	83 c0 01             	add    $0x1,%eax
  800a85:	84 d2                	test   %dl,%dl
  800a87:	75 f2                	jne    800a7b <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a89:	89 c8                	mov    %ecx,%eax
  800a8b:	5b                   	pop    %ebx
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a8e:	f3 0f 1e fb          	endbr32 
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	53                   	push   %ebx
  800a96:	83 ec 10             	sub    $0x10,%esp
  800a99:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a9c:	53                   	push   %ebx
  800a9d:	e8 83 ff ff ff       	call   800a25 <strlen>
  800aa2:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800aa5:	ff 75 0c             	pushl  0xc(%ebp)
  800aa8:	01 d8                	add    %ebx,%eax
  800aaa:	50                   	push   %eax
  800aab:	e8 b8 ff ff ff       	call   800a68 <strcpy>
	return dst;
}
  800ab0:	89 d8                	mov    %ebx,%eax
  800ab2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ab5:	c9                   	leave  
  800ab6:	c3                   	ret    

00800ab7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ab7:	f3 0f 1e fb          	endbr32 
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
  800ac0:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac6:	89 f3                	mov    %esi,%ebx
  800ac8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800acb:	89 f0                	mov    %esi,%eax
  800acd:	39 d8                	cmp    %ebx,%eax
  800acf:	74 11                	je     800ae2 <strncpy+0x2b>
		*dst++ = *src;
  800ad1:	83 c0 01             	add    $0x1,%eax
  800ad4:	0f b6 0a             	movzbl (%edx),%ecx
  800ad7:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ada:	80 f9 01             	cmp    $0x1,%cl
  800add:	83 da ff             	sbb    $0xffffffff,%edx
  800ae0:	eb eb                	jmp    800acd <strncpy+0x16>
	}
	return ret;
}
  800ae2:	89 f0                	mov    %esi,%eax
  800ae4:	5b                   	pop    %ebx
  800ae5:	5e                   	pop    %esi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ae8:	f3 0f 1e fb          	endbr32 
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	56                   	push   %esi
  800af0:	53                   	push   %ebx
  800af1:	8b 75 08             	mov    0x8(%ebp),%esi
  800af4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af7:	8b 55 10             	mov    0x10(%ebp),%edx
  800afa:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800afc:	85 d2                	test   %edx,%edx
  800afe:	74 21                	je     800b21 <strlcpy+0x39>
  800b00:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b04:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b06:	39 c2                	cmp    %eax,%edx
  800b08:	74 14                	je     800b1e <strlcpy+0x36>
  800b0a:	0f b6 19             	movzbl (%ecx),%ebx
  800b0d:	84 db                	test   %bl,%bl
  800b0f:	74 0b                	je     800b1c <strlcpy+0x34>
			*dst++ = *src++;
  800b11:	83 c1 01             	add    $0x1,%ecx
  800b14:	83 c2 01             	add    $0x1,%edx
  800b17:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b1a:	eb ea                	jmp    800b06 <strlcpy+0x1e>
  800b1c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b1e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b21:	29 f0                	sub    %esi,%eax
}
  800b23:	5b                   	pop    %ebx
  800b24:	5e                   	pop    %esi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b27:	f3 0f 1e fb          	endbr32 
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b31:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b34:	0f b6 01             	movzbl (%ecx),%eax
  800b37:	84 c0                	test   %al,%al
  800b39:	74 0c                	je     800b47 <strcmp+0x20>
  800b3b:	3a 02                	cmp    (%edx),%al
  800b3d:	75 08                	jne    800b47 <strcmp+0x20>
		p++, q++;
  800b3f:	83 c1 01             	add    $0x1,%ecx
  800b42:	83 c2 01             	add    $0x1,%edx
  800b45:	eb ed                	jmp    800b34 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b47:	0f b6 c0             	movzbl %al,%eax
  800b4a:	0f b6 12             	movzbl (%edx),%edx
  800b4d:	29 d0                	sub    %edx,%eax
}
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b51:	f3 0f 1e fb          	endbr32 
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	53                   	push   %ebx
  800b59:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5f:	89 c3                	mov    %eax,%ebx
  800b61:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b64:	eb 06                	jmp    800b6c <strncmp+0x1b>
		n--, p++, q++;
  800b66:	83 c0 01             	add    $0x1,%eax
  800b69:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b6c:	39 d8                	cmp    %ebx,%eax
  800b6e:	74 16                	je     800b86 <strncmp+0x35>
  800b70:	0f b6 08             	movzbl (%eax),%ecx
  800b73:	84 c9                	test   %cl,%cl
  800b75:	74 04                	je     800b7b <strncmp+0x2a>
  800b77:	3a 0a                	cmp    (%edx),%cl
  800b79:	74 eb                	je     800b66 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b7b:	0f b6 00             	movzbl (%eax),%eax
  800b7e:	0f b6 12             	movzbl (%edx),%edx
  800b81:	29 d0                	sub    %edx,%eax
}
  800b83:	5b                   	pop    %ebx
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    
		return 0;
  800b86:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8b:	eb f6                	jmp    800b83 <strncmp+0x32>

00800b8d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b8d:	f3 0f 1e fb          	endbr32 
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	8b 45 08             	mov    0x8(%ebp),%eax
  800b97:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b9b:	0f b6 10             	movzbl (%eax),%edx
  800b9e:	84 d2                	test   %dl,%dl
  800ba0:	74 09                	je     800bab <strchr+0x1e>
		if (*s == c)
  800ba2:	38 ca                	cmp    %cl,%dl
  800ba4:	74 0a                	je     800bb0 <strchr+0x23>
	for (; *s; s++)
  800ba6:	83 c0 01             	add    $0x1,%eax
  800ba9:	eb f0                	jmp    800b9b <strchr+0xe>
			return (char *) s;
	return 0;
  800bab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    

00800bb2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bb2:	f3 0f 1e fb          	endbr32 
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bc0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bc3:	38 ca                	cmp    %cl,%dl
  800bc5:	74 09                	je     800bd0 <strfind+0x1e>
  800bc7:	84 d2                	test   %dl,%dl
  800bc9:	74 05                	je     800bd0 <strfind+0x1e>
	for (; *s; s++)
  800bcb:	83 c0 01             	add    $0x1,%eax
  800bce:	eb f0                	jmp    800bc0 <strfind+0xe>
			break;
	return (char *) s;
}
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bd2:	f3 0f 1e fb          	endbr32 
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
  800bdc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bdf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800be2:	85 c9                	test   %ecx,%ecx
  800be4:	74 31                	je     800c17 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800be6:	89 f8                	mov    %edi,%eax
  800be8:	09 c8                	or     %ecx,%eax
  800bea:	a8 03                	test   $0x3,%al
  800bec:	75 23                	jne    800c11 <memset+0x3f>
		c &= 0xFF;
  800bee:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bf2:	89 d3                	mov    %edx,%ebx
  800bf4:	c1 e3 08             	shl    $0x8,%ebx
  800bf7:	89 d0                	mov    %edx,%eax
  800bf9:	c1 e0 18             	shl    $0x18,%eax
  800bfc:	89 d6                	mov    %edx,%esi
  800bfe:	c1 e6 10             	shl    $0x10,%esi
  800c01:	09 f0                	or     %esi,%eax
  800c03:	09 c2                	or     %eax,%edx
  800c05:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c07:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c0a:	89 d0                	mov    %edx,%eax
  800c0c:	fc                   	cld    
  800c0d:	f3 ab                	rep stos %eax,%es:(%edi)
  800c0f:	eb 06                	jmp    800c17 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c14:	fc                   	cld    
  800c15:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c17:	89 f8                	mov    %edi,%eax
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c1e:	f3 0f 1e fb          	endbr32 
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c2d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c30:	39 c6                	cmp    %eax,%esi
  800c32:	73 32                	jae    800c66 <memmove+0x48>
  800c34:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c37:	39 c2                	cmp    %eax,%edx
  800c39:	76 2b                	jbe    800c66 <memmove+0x48>
		s += n;
		d += n;
  800c3b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c3e:	89 fe                	mov    %edi,%esi
  800c40:	09 ce                	or     %ecx,%esi
  800c42:	09 d6                	or     %edx,%esi
  800c44:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c4a:	75 0e                	jne    800c5a <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c4c:	83 ef 04             	sub    $0x4,%edi
  800c4f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c52:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c55:	fd                   	std    
  800c56:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c58:	eb 09                	jmp    800c63 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c5a:	83 ef 01             	sub    $0x1,%edi
  800c5d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c60:	fd                   	std    
  800c61:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c63:	fc                   	cld    
  800c64:	eb 1a                	jmp    800c80 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c66:	89 c2                	mov    %eax,%edx
  800c68:	09 ca                	or     %ecx,%edx
  800c6a:	09 f2                	or     %esi,%edx
  800c6c:	f6 c2 03             	test   $0x3,%dl
  800c6f:	75 0a                	jne    800c7b <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c71:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c74:	89 c7                	mov    %eax,%edi
  800c76:	fc                   	cld    
  800c77:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c79:	eb 05                	jmp    800c80 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c7b:	89 c7                	mov    %eax,%edi
  800c7d:	fc                   	cld    
  800c7e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c84:	f3 0f 1e fb          	endbr32 
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c8e:	ff 75 10             	pushl  0x10(%ebp)
  800c91:	ff 75 0c             	pushl  0xc(%ebp)
  800c94:	ff 75 08             	pushl  0x8(%ebp)
  800c97:	e8 82 ff ff ff       	call   800c1e <memmove>
}
  800c9c:	c9                   	leave  
  800c9d:	c3                   	ret    

00800c9e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c9e:	f3 0f 1e fb          	endbr32 
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	56                   	push   %esi
  800ca6:	53                   	push   %ebx
  800ca7:	8b 45 08             	mov    0x8(%ebp),%eax
  800caa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cad:	89 c6                	mov    %eax,%esi
  800caf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb2:	39 f0                	cmp    %esi,%eax
  800cb4:	74 1c                	je     800cd2 <memcmp+0x34>
		if (*s1 != *s2)
  800cb6:	0f b6 08             	movzbl (%eax),%ecx
  800cb9:	0f b6 1a             	movzbl (%edx),%ebx
  800cbc:	38 d9                	cmp    %bl,%cl
  800cbe:	75 08                	jne    800cc8 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cc0:	83 c0 01             	add    $0x1,%eax
  800cc3:	83 c2 01             	add    $0x1,%edx
  800cc6:	eb ea                	jmp    800cb2 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800cc8:	0f b6 c1             	movzbl %cl,%eax
  800ccb:	0f b6 db             	movzbl %bl,%ebx
  800cce:	29 d8                	sub    %ebx,%eax
  800cd0:	eb 05                	jmp    800cd7 <memcmp+0x39>
	}

	return 0;
  800cd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cdb:	f3 0f 1e fb          	endbr32 
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ce8:	89 c2                	mov    %eax,%edx
  800cea:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ced:	39 d0                	cmp    %edx,%eax
  800cef:	73 09                	jae    800cfa <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf1:	38 08                	cmp    %cl,(%eax)
  800cf3:	74 05                	je     800cfa <memfind+0x1f>
	for (; s < ends; s++)
  800cf5:	83 c0 01             	add    $0x1,%eax
  800cf8:	eb f3                	jmp    800ced <memfind+0x12>
			break;
	return (void *) s;
}
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cfc:	f3 0f 1e fb          	endbr32 
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
  800d06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d09:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d0c:	eb 03                	jmp    800d11 <strtol+0x15>
		s++;
  800d0e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d11:	0f b6 01             	movzbl (%ecx),%eax
  800d14:	3c 20                	cmp    $0x20,%al
  800d16:	74 f6                	je     800d0e <strtol+0x12>
  800d18:	3c 09                	cmp    $0x9,%al
  800d1a:	74 f2                	je     800d0e <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d1c:	3c 2b                	cmp    $0x2b,%al
  800d1e:	74 2a                	je     800d4a <strtol+0x4e>
	int neg = 0;
  800d20:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d25:	3c 2d                	cmp    $0x2d,%al
  800d27:	74 2b                	je     800d54 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d29:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d2f:	75 0f                	jne    800d40 <strtol+0x44>
  800d31:	80 39 30             	cmpb   $0x30,(%ecx)
  800d34:	74 28                	je     800d5e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d36:	85 db                	test   %ebx,%ebx
  800d38:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d3d:	0f 44 d8             	cmove  %eax,%ebx
  800d40:	b8 00 00 00 00       	mov    $0x0,%eax
  800d45:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d48:	eb 46                	jmp    800d90 <strtol+0x94>
		s++;
  800d4a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d4d:	bf 00 00 00 00       	mov    $0x0,%edi
  800d52:	eb d5                	jmp    800d29 <strtol+0x2d>
		s++, neg = 1;
  800d54:	83 c1 01             	add    $0x1,%ecx
  800d57:	bf 01 00 00 00       	mov    $0x1,%edi
  800d5c:	eb cb                	jmp    800d29 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d5e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d62:	74 0e                	je     800d72 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d64:	85 db                	test   %ebx,%ebx
  800d66:	75 d8                	jne    800d40 <strtol+0x44>
		s++, base = 8;
  800d68:	83 c1 01             	add    $0x1,%ecx
  800d6b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d70:	eb ce                	jmp    800d40 <strtol+0x44>
		s += 2, base = 16;
  800d72:	83 c1 02             	add    $0x2,%ecx
  800d75:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d7a:	eb c4                	jmp    800d40 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d7c:	0f be d2             	movsbl %dl,%edx
  800d7f:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d82:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d85:	7d 3a                	jge    800dc1 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d87:	83 c1 01             	add    $0x1,%ecx
  800d8a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d8e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d90:	0f b6 11             	movzbl (%ecx),%edx
  800d93:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d96:	89 f3                	mov    %esi,%ebx
  800d98:	80 fb 09             	cmp    $0x9,%bl
  800d9b:	76 df                	jbe    800d7c <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800d9d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800da0:	89 f3                	mov    %esi,%ebx
  800da2:	80 fb 19             	cmp    $0x19,%bl
  800da5:	77 08                	ja     800daf <strtol+0xb3>
			dig = *s - 'a' + 10;
  800da7:	0f be d2             	movsbl %dl,%edx
  800daa:	83 ea 57             	sub    $0x57,%edx
  800dad:	eb d3                	jmp    800d82 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800daf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800db2:	89 f3                	mov    %esi,%ebx
  800db4:	80 fb 19             	cmp    $0x19,%bl
  800db7:	77 08                	ja     800dc1 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800db9:	0f be d2             	movsbl %dl,%edx
  800dbc:	83 ea 37             	sub    $0x37,%edx
  800dbf:	eb c1                	jmp    800d82 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dc1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dc5:	74 05                	je     800dcc <strtol+0xd0>
		*endptr = (char *) s;
  800dc7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dca:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800dcc:	89 c2                	mov    %eax,%edx
  800dce:	f7 da                	neg    %edx
  800dd0:	85 ff                	test   %edi,%edi
  800dd2:	0f 45 c2             	cmovne %edx,%eax
}
  800dd5:	5b                   	pop    %ebx
  800dd6:	5e                   	pop    %esi
  800dd7:	5f                   	pop    %edi
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    
  800dda:	66 90                	xchg   %ax,%ax
  800ddc:	66 90                	xchg   %ax,%ax
  800dde:	66 90                	xchg   %ax,%ax

00800de0 <__udivdi3>:
  800de0:	f3 0f 1e fb          	endbr32 
  800de4:	55                   	push   %ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	83 ec 1c             	sub    $0x1c,%esp
  800deb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800def:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800df3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800df7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800dfb:	85 d2                	test   %edx,%edx
  800dfd:	75 19                	jne    800e18 <__udivdi3+0x38>
  800dff:	39 f3                	cmp    %esi,%ebx
  800e01:	76 4d                	jbe    800e50 <__udivdi3+0x70>
  800e03:	31 ff                	xor    %edi,%edi
  800e05:	89 e8                	mov    %ebp,%eax
  800e07:	89 f2                	mov    %esi,%edx
  800e09:	f7 f3                	div    %ebx
  800e0b:	89 fa                	mov    %edi,%edx
  800e0d:	83 c4 1c             	add    $0x1c,%esp
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    
  800e15:	8d 76 00             	lea    0x0(%esi),%esi
  800e18:	39 f2                	cmp    %esi,%edx
  800e1a:	76 14                	jbe    800e30 <__udivdi3+0x50>
  800e1c:	31 ff                	xor    %edi,%edi
  800e1e:	31 c0                	xor    %eax,%eax
  800e20:	89 fa                	mov    %edi,%edx
  800e22:	83 c4 1c             	add    $0x1c,%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    
  800e2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e30:	0f bd fa             	bsr    %edx,%edi
  800e33:	83 f7 1f             	xor    $0x1f,%edi
  800e36:	75 48                	jne    800e80 <__udivdi3+0xa0>
  800e38:	39 f2                	cmp    %esi,%edx
  800e3a:	72 06                	jb     800e42 <__udivdi3+0x62>
  800e3c:	31 c0                	xor    %eax,%eax
  800e3e:	39 eb                	cmp    %ebp,%ebx
  800e40:	77 de                	ja     800e20 <__udivdi3+0x40>
  800e42:	b8 01 00 00 00       	mov    $0x1,%eax
  800e47:	eb d7                	jmp    800e20 <__udivdi3+0x40>
  800e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e50:	89 d9                	mov    %ebx,%ecx
  800e52:	85 db                	test   %ebx,%ebx
  800e54:	75 0b                	jne    800e61 <__udivdi3+0x81>
  800e56:	b8 01 00 00 00       	mov    $0x1,%eax
  800e5b:	31 d2                	xor    %edx,%edx
  800e5d:	f7 f3                	div    %ebx
  800e5f:	89 c1                	mov    %eax,%ecx
  800e61:	31 d2                	xor    %edx,%edx
  800e63:	89 f0                	mov    %esi,%eax
  800e65:	f7 f1                	div    %ecx
  800e67:	89 c6                	mov    %eax,%esi
  800e69:	89 e8                	mov    %ebp,%eax
  800e6b:	89 f7                	mov    %esi,%edi
  800e6d:	f7 f1                	div    %ecx
  800e6f:	89 fa                	mov    %edi,%edx
  800e71:	83 c4 1c             	add    $0x1c,%esp
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5f                   	pop    %edi
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    
  800e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e80:	89 f9                	mov    %edi,%ecx
  800e82:	b8 20 00 00 00       	mov    $0x20,%eax
  800e87:	29 f8                	sub    %edi,%eax
  800e89:	d3 e2                	shl    %cl,%edx
  800e8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e8f:	89 c1                	mov    %eax,%ecx
  800e91:	89 da                	mov    %ebx,%edx
  800e93:	d3 ea                	shr    %cl,%edx
  800e95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e99:	09 d1                	or     %edx,%ecx
  800e9b:	89 f2                	mov    %esi,%edx
  800e9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ea1:	89 f9                	mov    %edi,%ecx
  800ea3:	d3 e3                	shl    %cl,%ebx
  800ea5:	89 c1                	mov    %eax,%ecx
  800ea7:	d3 ea                	shr    %cl,%edx
  800ea9:	89 f9                	mov    %edi,%ecx
  800eab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800eaf:	89 eb                	mov    %ebp,%ebx
  800eb1:	d3 e6                	shl    %cl,%esi
  800eb3:	89 c1                	mov    %eax,%ecx
  800eb5:	d3 eb                	shr    %cl,%ebx
  800eb7:	09 de                	or     %ebx,%esi
  800eb9:	89 f0                	mov    %esi,%eax
  800ebb:	f7 74 24 08          	divl   0x8(%esp)
  800ebf:	89 d6                	mov    %edx,%esi
  800ec1:	89 c3                	mov    %eax,%ebx
  800ec3:	f7 64 24 0c          	mull   0xc(%esp)
  800ec7:	39 d6                	cmp    %edx,%esi
  800ec9:	72 15                	jb     800ee0 <__udivdi3+0x100>
  800ecb:	89 f9                	mov    %edi,%ecx
  800ecd:	d3 e5                	shl    %cl,%ebp
  800ecf:	39 c5                	cmp    %eax,%ebp
  800ed1:	73 04                	jae    800ed7 <__udivdi3+0xf7>
  800ed3:	39 d6                	cmp    %edx,%esi
  800ed5:	74 09                	je     800ee0 <__udivdi3+0x100>
  800ed7:	89 d8                	mov    %ebx,%eax
  800ed9:	31 ff                	xor    %edi,%edi
  800edb:	e9 40 ff ff ff       	jmp    800e20 <__udivdi3+0x40>
  800ee0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ee3:	31 ff                	xor    %edi,%edi
  800ee5:	e9 36 ff ff ff       	jmp    800e20 <__udivdi3+0x40>
  800eea:	66 90                	xchg   %ax,%ax
  800eec:	66 90                	xchg   %ax,%ax
  800eee:	66 90                	xchg   %ax,%ax

00800ef0 <__umoddi3>:
  800ef0:	f3 0f 1e fb          	endbr32 
  800ef4:	55                   	push   %ebp
  800ef5:	57                   	push   %edi
  800ef6:	56                   	push   %esi
  800ef7:	53                   	push   %ebx
  800ef8:	83 ec 1c             	sub    $0x1c,%esp
  800efb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800eff:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f03:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f07:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	75 19                	jne    800f28 <__umoddi3+0x38>
  800f0f:	39 df                	cmp    %ebx,%edi
  800f11:	76 5d                	jbe    800f70 <__umoddi3+0x80>
  800f13:	89 f0                	mov    %esi,%eax
  800f15:	89 da                	mov    %ebx,%edx
  800f17:	f7 f7                	div    %edi
  800f19:	89 d0                	mov    %edx,%eax
  800f1b:	31 d2                	xor    %edx,%edx
  800f1d:	83 c4 1c             	add    $0x1c,%esp
  800f20:	5b                   	pop    %ebx
  800f21:	5e                   	pop    %esi
  800f22:	5f                   	pop    %edi
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    
  800f25:	8d 76 00             	lea    0x0(%esi),%esi
  800f28:	89 f2                	mov    %esi,%edx
  800f2a:	39 d8                	cmp    %ebx,%eax
  800f2c:	76 12                	jbe    800f40 <__umoddi3+0x50>
  800f2e:	89 f0                	mov    %esi,%eax
  800f30:	89 da                	mov    %ebx,%edx
  800f32:	83 c4 1c             	add    $0x1c,%esp
  800f35:	5b                   	pop    %ebx
  800f36:	5e                   	pop    %esi
  800f37:	5f                   	pop    %edi
  800f38:	5d                   	pop    %ebp
  800f39:	c3                   	ret    
  800f3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f40:	0f bd e8             	bsr    %eax,%ebp
  800f43:	83 f5 1f             	xor    $0x1f,%ebp
  800f46:	75 50                	jne    800f98 <__umoddi3+0xa8>
  800f48:	39 d8                	cmp    %ebx,%eax
  800f4a:	0f 82 e0 00 00 00    	jb     801030 <__umoddi3+0x140>
  800f50:	89 d9                	mov    %ebx,%ecx
  800f52:	39 f7                	cmp    %esi,%edi
  800f54:	0f 86 d6 00 00 00    	jbe    801030 <__umoddi3+0x140>
  800f5a:	89 d0                	mov    %edx,%eax
  800f5c:	89 ca                	mov    %ecx,%edx
  800f5e:	83 c4 1c             	add    $0x1c,%esp
  800f61:	5b                   	pop    %ebx
  800f62:	5e                   	pop    %esi
  800f63:	5f                   	pop    %edi
  800f64:	5d                   	pop    %ebp
  800f65:	c3                   	ret    
  800f66:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f6d:	8d 76 00             	lea    0x0(%esi),%esi
  800f70:	89 fd                	mov    %edi,%ebp
  800f72:	85 ff                	test   %edi,%edi
  800f74:	75 0b                	jne    800f81 <__umoddi3+0x91>
  800f76:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7b:	31 d2                	xor    %edx,%edx
  800f7d:	f7 f7                	div    %edi
  800f7f:	89 c5                	mov    %eax,%ebp
  800f81:	89 d8                	mov    %ebx,%eax
  800f83:	31 d2                	xor    %edx,%edx
  800f85:	f7 f5                	div    %ebp
  800f87:	89 f0                	mov    %esi,%eax
  800f89:	f7 f5                	div    %ebp
  800f8b:	89 d0                	mov    %edx,%eax
  800f8d:	31 d2                	xor    %edx,%edx
  800f8f:	eb 8c                	jmp    800f1d <__umoddi3+0x2d>
  800f91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f98:	89 e9                	mov    %ebp,%ecx
  800f9a:	ba 20 00 00 00       	mov    $0x20,%edx
  800f9f:	29 ea                	sub    %ebp,%edx
  800fa1:	d3 e0                	shl    %cl,%eax
  800fa3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fa7:	89 d1                	mov    %edx,%ecx
  800fa9:	89 f8                	mov    %edi,%eax
  800fab:	d3 e8                	shr    %cl,%eax
  800fad:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fb1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fb5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fb9:	09 c1                	or     %eax,%ecx
  800fbb:	89 d8                	mov    %ebx,%eax
  800fbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fc1:	89 e9                	mov    %ebp,%ecx
  800fc3:	d3 e7                	shl    %cl,%edi
  800fc5:	89 d1                	mov    %edx,%ecx
  800fc7:	d3 e8                	shr    %cl,%eax
  800fc9:	89 e9                	mov    %ebp,%ecx
  800fcb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fcf:	d3 e3                	shl    %cl,%ebx
  800fd1:	89 c7                	mov    %eax,%edi
  800fd3:	89 d1                	mov    %edx,%ecx
  800fd5:	89 f0                	mov    %esi,%eax
  800fd7:	d3 e8                	shr    %cl,%eax
  800fd9:	89 e9                	mov    %ebp,%ecx
  800fdb:	89 fa                	mov    %edi,%edx
  800fdd:	d3 e6                	shl    %cl,%esi
  800fdf:	09 d8                	or     %ebx,%eax
  800fe1:	f7 74 24 08          	divl   0x8(%esp)
  800fe5:	89 d1                	mov    %edx,%ecx
  800fe7:	89 f3                	mov    %esi,%ebx
  800fe9:	f7 64 24 0c          	mull   0xc(%esp)
  800fed:	89 c6                	mov    %eax,%esi
  800fef:	89 d7                	mov    %edx,%edi
  800ff1:	39 d1                	cmp    %edx,%ecx
  800ff3:	72 06                	jb     800ffb <__umoddi3+0x10b>
  800ff5:	75 10                	jne    801007 <__umoddi3+0x117>
  800ff7:	39 c3                	cmp    %eax,%ebx
  800ff9:	73 0c                	jae    801007 <__umoddi3+0x117>
  800ffb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800fff:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801003:	89 d7                	mov    %edx,%edi
  801005:	89 c6                	mov    %eax,%esi
  801007:	89 ca                	mov    %ecx,%edx
  801009:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80100e:	29 f3                	sub    %esi,%ebx
  801010:	19 fa                	sbb    %edi,%edx
  801012:	89 d0                	mov    %edx,%eax
  801014:	d3 e0                	shl    %cl,%eax
  801016:	89 e9                	mov    %ebp,%ecx
  801018:	d3 eb                	shr    %cl,%ebx
  80101a:	d3 ea                	shr    %cl,%edx
  80101c:	09 d8                	or     %ebx,%eax
  80101e:	83 c4 1c             	add    $0x1c,%esp
  801021:	5b                   	pop    %ebx
  801022:	5e                   	pop    %esi
  801023:	5f                   	pop    %edi
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    
  801026:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80102d:	8d 76 00             	lea    0x0(%esi),%esi
  801030:	29 fe                	sub    %edi,%esi
  801032:	19 c3                	sbb    %eax,%ebx
  801034:	89 f2                	mov    %esi,%edx
  801036:	89 d9                	mov    %ebx,%ecx
  801038:	e9 1d ff ff ff       	jmp    800f5a <__umoddi3+0x6a>
